#!/usr/bin/env python3
"""Review regressions: directory modes and recoverable metadata/FAT I/O failures."""
import importlib.util
import tempfile
from pathlib import Path

spec = importlib.util.spec_from_file_location('write_tests', Path(__file__).with_name('test-pcf-write.py'))
w = importlib.util.module_from_spec(spec)
spec.loader.exec_module(w)
f, b = w.f, w.b


def main():
    with tempfile.TemporaryDirectory(prefix='pcf-review-') as folder:
        for level in (1, 2):
            tmp = Path(folder)
            modules = b.assemble(tmp, level)
            modules['fixture'] = f.assemble_source(tmp, level, f.ROOT/'level1/modules/llcocovhd.asm', 'vhd')
            pcf = f.assemble_source(tmp, level, f.ROOT/'level1/modules/pcf.asm', 'pcf')

            def fresh():
                v = f.Volume()
                for lba, data in list(v.sectors.items()):
                    if v.base+32 <= lba < v.base+32+v.fatsize:
                        v.sectors[lba+v.fatsize] = bytearray(data)
                p = w.Machine(modules, pcf, v)
                return p, v

            def ok(p, name, **kw):
                result = p.call(name, **kw)
                assert not result[0], (level, name, kw, result)
                return result

            def field(p, name, count=4):
                return p.data(f.WORK+p.fs[name], count)

            def fat(v):
                return {n: bytes(data) for n, data in v.sectors.items()
                        if v.base+32 <= n < v.data}

            p, v = fresh()
            for directory in ('DATA', 'CMDS'):
                ok(p, 'MkDir', path='/pc0/'+directory)
                ok(p, 'Create', mode=3, path='/pc0/'+directory+'/SAME')
                ok(p, 'Close')
            ok(p, 'ChgDir', mode=1, path='/pc0/DATA')
            ok(p, 'ChgDir', mode=4, path='/pc0/CMDS')
            ok(p, 'Delete', mode=4, path='SAME')
            ok(p, 'Open', mode=1, path='/pc0/DATA/SAME')
            ok(p, 'Close')
            assert p.call('Open', mode=1, path='/pc0/CMDS/SAME')[:2] == (1, p.s['E$PNNF'])
            ok(p, 'ChgDir', mode=2, path='/pc0/CMDS')
            ok(p, 'Create', mode=3, path='WRITEONL')
            ok(p, 'Close')
            ok(p, 'Open', mode=1, path='/pc0/CMDS/WRITEONL')
            # SS.Opt succeeds without writing even when the mounted medium is readonly.
            p.byte(f.WORK+p.fs['F.Info']+p.s['BI.Flags'], p.s['BF.ReadOnly'])
            before = len(p.writes)
            ok(p, 'SetStat', status=p.s['SS.Opt'])
            assert len(p.writes) == before
            ok(p, 'Close')

            # A directory write can fail in either half; restore memory and disk,
            # then continue writing through the SAME path without losing the chain.
            for size in (0, 513):
                for half in (1, 2):
                    p, v = fresh()
                    ok(p, 'Open', mode=3, path='/pc0/FRAG.BIN')
                    original = field(p, 'F.Start', 40)
                    old_fat = fat(v)
                    p.fail_write = len(p.writes)+half
                    result = p.call('SetStat', status=p.s['SS.Size'], position=size)
                    assert result[:2] == (1, p.s['E$Write']), (size, half, result)
                    p.fail_write = None
                    assert field(p, 'F.Start', 40) == original, ('identity rollback', size, half)
                    assert fat(v) == old_fat, ('truncate FAT rollback', size, half)
                    p.m.load(f.OUTPUT, b'RETRY')
                    ok(p, 'Write', count=5)
                    ok(p, 'Close')
                    ok(p, 'Open', mode=1, path='/pc0/FRAG.BIN')
                    ok(p, 'Read', count=len(v.fragment))
                    assert p.data(f.OUTPUT, len(v.fragment)) == b'RETRY'+v.fragment[5:]
                    ok(p, 'Close')

            # Fail each FAT mirror half and each directory-publication half of
            # an empty file's first allocation. No orphan may remain on retry.
            for failure in range(3, 9):
                p, v = fresh()
                ok(p, 'Open', mode=3, path='/pc0/EMPTY.TXT')
                original = field(p, 'F.Start', 40)
                old_fat = fat(v)
                p.fail_write = len(p.writes)+failure
                p.m.load(f.OUTPUT, b'NEW')
                result = p.call('Write', count=3)
                assert result[:2] == (1, p.s['E$Write']), (failure, result)
                p.fail_write = None
                assert field(p, 'F.Start', 40) == original, ('allocation identity', failure)
                assert fat(v) == old_fat, ('unpublished allocation', failure)
                p.m.load(f.OUTPUT, b'RETRY')
                ok(p, 'Write', count=5)
                ok(p, 'Close')
                ok(p, 'Open', mode=1, path='/pc0/EMPTY.TXT')
                ok(p, 'Read', count=5)
                assert p.data(f.OUTPUT, 5) == b'RETRY'
                ok(p, 'Close')

            # Fail each half of each FAT copy while linking onto an existing
            # chain. The former tail must remain EOC and the new cluster free.
            for failure in range(7, 11):
                p, v = fresh()
                ok(p, 'Open', mode=3, path='/pc0/HELLO.TXT')
                old_fat = fat(v)
                ok(p, 'Seek', position=512)
                p.m.load(f.OUTPUT, b'X')
                p.fail_write = len(p.writes)+failure
                result = p.call('Write', count=1)
                assert result[:2] == (1, p.s['E$Write']), (failure, result)
                p.fail_write = None
                assert fat(v) == old_fat, ('link rollback', failure)
                ok(p, 'Close')

            # Optional FSInfo I/O cannot invalidate an authoritative allocation.
            for failed_read in (False, True):
                p, v = fresh()
                hint = bytearray(512)
                hint[:8] = bytes.fromhex('5252614100000000')
                hint[484:488] = bytes.fromhex('72724161')
                hint[488:492] = (65000).to_bytes(4, 'little')
                hint[492:496] = (2).to_bytes(4, 'little')
                hint[508:512] = bytes.fromhex('000055aa')
                v.sectors[v.base+1] = hint
                v.sectors[v.base+7] = bytearray(hint)
                ok(p, 'Open', mode=3, path='/pc0/EMPTY.TXT')
                if failed_read:
                    p.fail_read = (v.base+1)*2
                else:
                    p.fail_write = len(p.writes)+7
                p.m.load(f.OUTPUT, b'OK')
                ok(p, 'Write', count=2)
                p.fail_read = p.fail_write = None
                ok(p, 'Close')
                ok(p, 'Open', mode=1, path='/pc0/EMPTY.TXT')
                ok(p, 'Read', count=2)
                assert p.data(f.OUTPUT, 2) == b'OK'
                ok(p, 'Close')

            # Orphaned LFN records with a mismatched alias checksum must not
            # prevent mutation of a new short-name file in the following slot.
            p, v = fresh()
            ok(p, 'MkDir', path='/pc0/ORPHAN')
            ok(p, 'Open', mode=0x81, path='/pc0/ORPHAN')
            cluster = int.from_bytes(field(p, 'F.Start'), 'big')
            ok(p, 'Close')
            sector = v.sectors[v.data+(cluster-2)*v.spc]
            sector[64:96] = bytes([0x41])+bytes(10)+bytes([0x0f, 0, 0x17])+bytes(18)
            ok(p, 'Create', mode=3, path='/pc0/ORPHAN/NEW')
            ok(p, 'Close')
            ok(p, 'Open', mode=3, path='/pc0/ORPHAN/NEW')
            p.m.load(f.OUTPUT, b'OK')
            ok(p, 'Write', count=2)
            ok(p, 'Close')
            ok(p, 'Delete', path='/pc0/ORPHAN/NEW')
            # OEM high-bit bytes and escaped $E5 cannot become early OS-9
            # terminators. Unsupported codepage characters display as '?'.
            p, v = fresh()
            root = v.sectors[v.data]
            root[224:256] = v.entry('AB.TXT', 0, 0)
            root[224:226] = bytes([5, 0x82])
            ok(p, 'Open', mode=0x81, path='/pc0')
            found = False
            while True:
                result = p.call('GetStat', status=p.s['SS.ReadDir'], count=32)
                if result[0]:
                    assert result[1] == p.s['E$EOF']
                    break
                record = p.data(f.OUTPUT, 32)
                if record[:5] == b'??.TX':
                    assert record[5] == ord('T') | 128
                    found = True
            assert found, 'OEM name was truncated or skipped'
            ok(p, 'Close')
            print(f'PASS Level {level}: DeletX, WRITE chdir, readonly SS.Opt, truncate/allocation/link rollback, orphan LFN', flush=True)


if __name__ == '__main__':
    main()
