#!/usr/bin/env python3
"""Execute PCF + blkdrv + VHD on MC6809 against mutable FAT32 sector maps."""
import importlib.util
from pathlib import Path
import tempfile
spec=importlib.util.spec_from_file_location('fat',Path(__file__).with_name('test-fat32.py'))
f=importlib.util.module_from_spec(spec);spec.loader.exec_module(f)
b=f.blk
class Machine(f.FatMachine):
    def ok(self,name,**kw):
        if name=='Init':
            self.word(self.config+self.s['BC.Port'],0xff80)
            self.word(b.STAT+self.s['V.PORT'],0xff80)
            self.long(self.config+self.s['BC.Base'],self.volume.base+self.volume.total-1)
            self.byte(self.config+self.s['BC.Flags'],0)
            self.reg=bytearray(7);self.status=0;self.writes=[];self.fail_write=None;self.fail_read=None
            for a in range(0xff80,0xff87):self.m.add_write_byte_callback(self.device,a)
            self.m.add_read_byte_callback(lambda *_:self.status,0xff83)
        return super().ok(name,**kw)
    def device(self,cycles,pc,address,value):
        self.reg[address-0xff80]=value
        if address!=0xff83:return
        assert value in (0,1)
        record=int.from_bytes(self.reg[:3],'big');buf=int.from_bytes(self.reg[4:6],'big')
        sector=self.volume.sectors.setdefault(record//2,bytearray(512))
        off=256*(record&1);self.status=0
        if value:
            self.writes.append(record)
            if len(self.writes)==self.fail_write:self.status=6;return
            sector[off:off+256]=self.data(buf,256)
        elif record==self.fail_read:self.status=6
        else:self.m.load(buf,sector[off:off+256])

def build(tmp,level,v):
    modules=b.assemble(tmp,level)
    modules['fixture']=f.assemble_source(tmp,level,f.ROOT/'level1/modules/llcocovhd.asm','vhd')
    pcf=f.assemble_source(tmp,level,f.ROOT/'level1/modules/pcf.asm','pcf')
    return Machine(modules,pcf,v)

def main():
    with tempfile.TemporaryDirectory(prefix='pcf-write-') as d:
        for level in (1,2):
            tmp=Path(d);v=f.Volume(base=2048)
            # Populate the mirrored copy as a real formatter would.
            for lba,data in list(v.sectors.items()):
                if v.base+32<=lba<v.base+32+v.fatsize:v.sectors[lba+v.fatsize]=bytearray(data)
            p=build(tmp,level,v)
            def ok(name,**kw):
                r=p.call(name,**kw);assert not r[0],(level,name,r);return r
            def error(name,code,**kw):
                r=p.call(name,**kw);assert r[:2]==(1,p.s[code]),(name,r,code)
            def put(data,line=False):
                p.m.load(f.OUTPUT,data)
                return ok('WriteLn' if line else 'Write',count=len(data))
            # A second-half transfer failure must invalidate either cache and
            # propagate E$Read; retry must fetch the complete sector afresh.
            for offset,record,valid in (
                (0,(v.data+8)*2+1,'F.DataValid'),
                (512,(v.base+32)*2+1,'F.FatValid'),
            ):
                ok('Open',mode=1,path='/pc0/frag.bin')
                ok('Seek',position=offset)
                p.fail_read=record
                error('Read','E$Read',count=512)
                assert p.byte(f.WORK+p.fs[valid])==0,(level,valid)
                assert p.data(f.WORK+p.fs['F.Pos'],4)==offset.to_bytes(4,'big')
                p.fail_read=None
                assert ok('Read',count=512)[2]==512
                assert p.data(f.OUTPUT,512)==v.fragment[offset:offset+512]
                ok('Close')
            # Directory children are initialized before the parent entry appears.
            ok('MkDir',path='/pc0/ONE')
            ok('MkDir',path='/pc0/ONE/TWO')
            error('MkDir','E$CEF',path='/pc0/ONE')
            error('MkDir','E$PNNF',path='/pc0/MISSING/CHILD')
            error('MkDir','E$PNNF',path='/pc0/HELLO.TXT/CHILD')
            parents=[0]
            for path in ('/pc0/ONE','/pc0/ONE/TWO'):
                ok('Open',mode=0x81,path=path)
                cluster=int.from_bytes(p.data(f.WORK+p.fs['F.Start'],4),'big')
                raw=v.sectors[v.data+(cluster-2)*v.spc]
                def cluster_at(off):
                    return int.from_bytes(raw[off+20:off+22],'little')*65536+int.from_bytes(raw[off+26:off+28],'little')
                assert raw[:11]==b'.          ' and raw[32:43]==b'..         '
                assert raw[11]==raw[43]==0x10
                assert cluster_at(0)==cluster and cluster_at(32)==parents[-1]
                assert raw[28:32]==raw[60:64]==bytes(4)
                if path.endswith('/TWO'):assert raw[64:]==bytes(448)
                parents.append(cluster);ok('Close')
            ok('Create',mode=3,path='/pc0/ONE/TWO/NOTE.TXT');put(b'PERSIST\r');ok('Close')
            ok('ChgDir',mode=1,path='/pc0/ONE/TWO')
            ok('ChgDir',mode=1,path='..')
            ok('Open',mode=1,path='TWO/NOTE.TXT');ok('Read',count=32)
            assert p.data(f.OUTPUT,8)==b'PERSIST\r';ok('Close')
            ok('ChgDir',mode=1,path='/pc0')
            # Empty directories can be removed; live entries and default data/
            # execution directory references (even without open paths) forbid it.
            before=len(p.writes)
            error('Delete','E$DNE',path='/pc0/ONE/TWO')
            error('Delete','E$DNE',path='/pc0/ONE')
            error('Delete','E$FNA',path='/pc0')
            error('Delete','E$FNA',path='/pc0/ONE/TWO/.')
            assert len(p.writes)==before
            ok('MkDir',path='/pc0/EMPTY')
            ok('ChgDir',mode=1,path='/pc0/EMPTY')
            before=len(p.writes);error('Delete','E$Share',path='/pc0/EMPTY')
            assert len(p.writes)==before
            ok('ChgDir',mode=1,path='/pc0')
            ok('ChgDir',mode=4,path='/pc0/EMPTY')
            before=len(p.writes);error('Delete','E$Share',path='/pc0/EMPTY')
            assert len(p.writes)==before
            ok('ChgDir',mode=4,path='/pc0')
            ok('Delete',path='/pc0/EMPTY')
            error('Open','E$PNNF',mode=0x81,path='/pc0/EMPTY')
            ok('Delete',path='/pc0/ONE/TWO/NOTE.TXT')
            ok('Delete',path='/pc0/ONE/TWO')
            ok('Delete',path='/pc0/ONE')
            # Reclaim a directory chain after deleting all entries, including
            # slots beyond its initial cluster. Reject cyclic chains first.
            ok('MkDir',path='/pc0/CHAIN')
            for i in range(18):
                ok('Create',mode=3,path=f'/pc0/CHAIN/F{i}.TXT');ok('Close')
            for i in range(18):ok('Delete',path=f'/pc0/CHAIN/F{i}.TXT')
            ok('Delete',path='/pc0/CHAIN')
            ok('MkDir',path='/pc0/CYCLE')
            ok('Open',mode=0x81,path='/pc0/CYCLE')
            cluster=int.from_bytes(p.data(f.WORK+p.fs['F.Start'],4),'big');ok('Close')
            v.fat(cluster,cluster)
            before=len(p.writes);error('Delete','E$BTyp',path='/pc0/CYCLE')
            assert len(p.writes)==before
            v.fat(cluster,0x0fffffff);ok('Delete',path='/pc0/CYCLE')
            # Fail the dot-entry sector write after zeroing and mirrored FAT
            # allocation; the unpublished child must be reclaimed.
            for half in (7,8):
                before={n:bytes(data) for n,data in v.sectors.items() if v.base+32<=n<v.data}
                p.fail_write=len(p.writes)+half
                error('MkDir','E$Write',path='/pc0/FAILED')
                p.fail_write=None
                error('Open','E$PNNF',mode=0x81,path='/pc0/FAILED')
                assert all(bytes(v.sectors[n])==data for n,data in before.items()),'directory rollback leaked a FAT allocation'
                assert p.allocations==[b.STATE]
            payload=bytes((i*37+11)&255 for i in range(1800))
            ok('Create',mode=3,path='/pc0/new.bin')
            assert put(payload)[2]==len(payload)
            ok('Seek',position=0);assert ok('Read',count=2000)[2]==len(payload)
            assert p.data(f.OUTPUT,len(payload))==payload
            ok('Seek',position=510);assert put(b'XY\rBAD',True)[2]==3
            expected=payload[:510]+b'XY\r'+payload[513:]
            ok('Seek',position=0);ok('Read',count=2000)
            assert p.data(f.OUTPUT,len(expected))==expected,'WriteLn changed bytes after CR'
            ok('Seek',position=2300);put(b'END')
            expected+=bytes(500)+b'END'
            ok('Seek',position=0);ok('Read',count=3000)
            assert p.data(f.OUTPUT,len(expected))==expected,'seek gap'
            ok('SetStat',status=p.s['SS.Size'],position=513)
            ok('SetStat',status=p.s['SS.Size'],position=1400)
            expected=expected[:513]+bytes(887)
            ok('Seek',position=0);assert ok('Read',count=2000)[2]==1400
            assert p.data(f.OUTPUT,1400)==expected,'resize'
            ok('Close')
            error('Create','E$CEF',mode=3,path='/pc0/new.bin')
            ok('Open',mode=1,path='/pc0/new.bin');ok('Read',count=2000)
            assert p.data(f.OUTPUT,1400)==expected
            ok('Close');ok('Delete',path='/pc0/new.bin')
            error('Open','E$PNNF',mode=1,path='/pc0/new.bin')
            for i in range(24):
                ok('Create',mode=3,path=f'/pc0/N{i}.TXT');put(b'hello\r');ok('Close')
            for i in range(24):ok('Delete',path=f'/pc0/N{i}.TXT')
            for lba,data in v.sectors.items():
                if v.base+32<=lba<v.base+32+v.fatsize:
                    assert data==v.sectors.get(lba+v.fatsize,bytearray(512)),('FAT mirrors',lba)
            assert p.allocations==[b.STATE],p.allocations
            print(f'PASS Level {level}: rmdir/nonempty/in-use/root/dot rejection/mkdir/nested/dot entries/rollback/cache failure/retry/create/read/write/WriteLn/seek gaps/resize/reopen/delete/directory growth/mirrors',flush=True)
if __name__=='__main__':main()
