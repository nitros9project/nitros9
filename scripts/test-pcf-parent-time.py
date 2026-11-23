#!/usr/bin/env python3
"""Execute parent-directory timestamp updates and cache/error behavior on MC6809."""
import importlib.util
import tempfile
from pathlib import Path

spec = importlib.util.spec_from_file_location('write_tests', Path(__file__).with_name('test-pcf-write.py'))
w = importlib.util.module_from_spec(spec)
spec.loader.exec_module(w)
f, b = w.f, w.b


def main():
    with tempfile.TemporaryDirectory(prefix='pcf-parent-time-') as folder:
        for level in (1, 2):
            v = f.Volume()
            for lba, data in list(v.sectors.items()):
                if v.base+32 <= lba < v.base+32+v.fatsize:
                    v.sectors[lba+v.fatsize] = bytearray(data)
            p = w.build(Path(folder), level, v)

            def ok(name, **kw):
                result = p.call(name, **kw)
                assert not result[0], (level, name, kw, result)
                return result

            def clock(day, minute):
                value = bytes([126, 11, day, 9, minute, 12])
                p.m.load(p.s['D.Time'], value)
                time = (9 << 11) | (minute << 5) | 6
                date = (46 << 9) | (11 << 5) | day
                return time.to_bytes(2, 'little')+date.to_bytes(2, 'little')

            def slot(cluster, name):
                alias = v.entry(name, 0, 0)[:11]
                while True:
                    for sector in range(v.spc):
                        data = v.sectors.get(v.data+(cluster-2)*v.spc+sector, bytearray(512))
                        for off in range(0, 512, 32):
                            if data[off:off+11] == alias:
                                return data, off
                    fat = v.sectors[v.base+32+cluster//128]
                    cluster = int.from_bytes(fat[(cluster%128)*4:(cluster%128)*4+4], 'little') & 0xfffffff
                    assert cluster < 0xffffff8, ('missing host entry', name)

            def entry(cluster, name):
                data, offset = slot(cluster, name)
                return bytes(data[offset:offset+32])

            def child_cluster(raw):
                return int.from_bytes(raw[20:22], 'little')*65536+int.from_bytes(raw[26:28], 'little')

            def parent_is(expected):
                raw = entry(2, 'PARENT')
                assert raw[22:26] == expected, ('parent modification time', raw[22:26], expected)
                assert raw[:22] == original[:22] and raw[26:] == original[26:], 'unrelated parent metadata changed'

            clock(13, 1)
            ok('MkDir', path='/pc0/PARENT')
            original = entry(2, 'PARENT')
            parent = child_cluster(original)
            expected = clock(14, 2)
            ok('Create', mode=3, path='/pc0/PARENT/ONE.TXT')
            ok('Close')
            parent_is(expected)
            file_before = entry(parent, 'ONE.TXT')
            expected = clock(15, 3)
            ok('MkDir', path='/pc0/PARENT/CHILD')
            parent_is(expected)

            # A successful rename modifies the containing directory, preserving
            # child timestamps and updating the caller's cached SS.FD identity.
            ok('Open', mode=0x83, path='/pc0/PARENT')
            expected = clock(16, 4)
            p.m.load(f.OUTPUT, b'ONE.TXT'.ljust(30, b'\0')+b'TWO.TXT'.ljust(30, b'\0'))
            ok('SetStat', status=p.s['SS.Rename'], count=60)
            parent_is(expected)
            assert entry(parent, 'TWO.TXT')[11:] == file_before[11:]
            assert p.data(f.WORK+p.fs['F.Entry']+22, 4) == expected, 'open parent cache is stale'
            before = len(p.writes)
            clock(17, 5)
            p.m.load(f.OUTPUT, b'two.txt'.ljust(30, b'\0')+b'TWO.TXT'.ljust(30, b'\0'))
            ok('SetStat', status=p.s['SS.Rename'], count=60)
            assert len(p.writes) == before, 'case-only no-op touched parent'
            parent_is(expected)
            ok('Close')

            # Relative cwd paths have only a cluster, not a retained full path.
            ok('ChgDir', mode=1, path='/pc0/PARENT')
            expected = clock(18, 6)
            ok('Delete', path='TWO.TXT')
            parent_is(expected)
            expected = clock(19, 7)
            ok('Delete', path='CHILD')
            parent_is(expected)
            ok('ChgDir', mode=1, path='/pc0')

            # Keep a directory reader alive across another path's mutation.
            # A foreign-partition cache with the same cluster must stay unchanged.
            ok('Open', mode=0x81, path='/pc0/PARENT')
            p.m.cfg.RAM_END = 0xfeff
            p.m.cfg.ROM_START = 0xff00
            cached = p.data(f.WORK, p.fs['F.Len'])
            for address in (0x9000, 0xa000):
                p.m.load(address, cached)
            p.word(0x9000+p.fs['F.NextPath'], 0xa000)
            p.word(0xa000+p.fs['F.NextPath'], 0)
            p.long(0xa000+p.fs['F.Base'], v.base+1000)
            p.word(f.WORK+p.fs['F.NextPath'], 0x9000)
            ok('Close')
            expected = clock(20, 8)
            ok('Create', mode=3, path='/pc0/PARENT/THREE')
            parent_is(expected)
            assert p.data(0x9000+p.fs['F.Entry']+22, 4) == expected
            assert p.data(0xa000+p.fs['F.Entry']+22, 4) != expected
            ok('Close')
            p.word(b.STAT+p.s['BV.FMPaths'], 0)

            # Fail the parent timestamp write after the name has committed.
            # Preserve path identity/cursor; report the partial mutation error.
            for half in (3, 4):
                ok('Open', mode=0x83, path='/pc0/PARENT')
                identity = p.data(f.WORK+p.fs['F.Start'], 40)
                old = b'THREE' if half == 3 else b'FOUR'
                new = b'FOUR' if half == 3 else b'FIVE'
                clock(21, half)
                p.m.load(f.OUTPUT, old.ljust(30, b'\0')+new.ljust(30, b'\0'))
                p.fail_write = len(p.writes)+half
                result = p.call('SetStat', status=p.s['SS.Rename'], count=60)
                assert result[:2] == (1, p.s['E$Write']), (half, result)
                p.fail_write = None
                assert p.data(f.WORK+p.fs['F.Start'], 40) == identity
                assert entry(parent, new.decode())[:11] == v.entry(new.decode(), 0, 0)[:11]
                ok('Close')
            print(f'PASS Level {level}: create/mkdir/delete/rmdir/rename parent times, relative cwd, no-op, live caches, partition isolation, partial-write errors', flush=True)


if __name__ == '__main__':
    main()
