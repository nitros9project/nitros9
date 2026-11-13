#!/usr/bin/env python3
"""Execute assembled pcf SS.Rename on both OS levels, including failure paths."""
import importlib.util
from pathlib import Path
import tempfile
spec=importlib.util.spec_from_file_location('write_tests',Path(__file__).with_name('test-pcf-write.py'))
w=importlib.util.module_from_spec(spec);spec.loader.exec_module(w)
f=w.f


def packet(old,new):return old.encode().ljust(30,b'\0')+new.encode().ljust(30,b'\0')


def tests(tmp,level):
    v=f.Volume()
    for lba,data in list(v.sectors.items()):
        if v.base+32<=lba<v.base+32+v.fatsize:v.sectors[lba+v.fatsize]=bytearray(data)
    p=w.build(tmp,level,v)
    def ok(name,**kw):
        r=p.call(name,**kw);assert not r[0],(level,name,kw,r);return r
    def state():
        return (p.data(f.WORK+p.fs['F.Start'],40),p.data(f.WORK+p.fs['F.DirLBA'],6),p.data(f.WORK+p.fs['F.Pos'],4))
    def rename(old,new,error=None,count=60,data=None):
        before=state();writes=len(p.writes)
        p.m.load(f.OUTPUT,data if data is not None else packet(old,new))
        result=p.call('SetStat',status=p.s['SS.Rename'],count=count)
        assert state()==before,('parent state or cursor changed',old,new,result)
        assert result[:2]==((1,p.s[error]) if error else (0,0)),(level,old,new,error,result)
        if error not in (None,'E$Write'):assert len(p.writes)==writes,('rejected rename wrote',error)
    ok('Open',mode=0x83,path='/pc0');ok('Seek',position=32)
    for old,new in [('HELLO.TXT',''),('.','A'),('..','A'),('...','A'),('HELLO.TXT','A/B'),('HELLO.TXT','A\\B'),('HELLO.TXT','A:B'),('HELLO.TXT','TOOLONGNAME.TXT'),('HELLO.TXT','A.LONG'),('HELLO.TXT','A*')]:rename(old,new,'E$BPNam')
    for count in (0,59,61):rename('HELLO.TXT','HI.TXT','E$BPNam',count=count)
    bad=bytearray(packet('HELLO.TXT','HI.TXT'));bad[20]=1
    rename('','','E$BPNam',data=bad)
    rename('NOFILE','NEW','E$PNNF');rename('HELLO.TXT','FRAG.BIN','E$CEF')
    writes=len(p.writes);rename('hello.txt','HELLO.TXT');assert len(p.writes)==writes
    v.sectors[v.data][11]|=1 # Child read-only attribute does not control parent rename.
    v.sectors[v.data][12]=0xff # Clear only NT lowercase flags when the alias changes.
    old=bytearray(v.sectors[v.data][:32]);old[12]&=0xe7
    rename('HELLO.TXT','HI.TXT')
    assert v.sectors[v.data][:11]==b'HI      TXT' and v.sectors[v.data][11:32]==old[11:]
    rename('HI.TXT','HELLO.TXT')
    if level==2:
        p.fail_move=True;rename('HELLO.TXT','HI.TXT','E$IBA');p.fail_move=False
    p.fail_read=v.data*2+1;rename('HELLO.TXT','HI.TXT','E$Read');p.fail_read=None
    p.fail_write=len(p.writes)+1;rename('HELLO.TXT','HI.TXT','E$Write');p.fail_write=None
    rename('HELLO.TXT','HI.TXT');rename('HI.TXT','HELLO.TXT')
    rename('SUBDIR','RENAMED');ok('Close')
    ok('Open',mode=1,path='/pc0/RENAMED/NEST.TXT');ok('Read',count=7)
    assert p.data(f.OUTPUT,7)==b'NESTED\r';ok('Close')
    ok('ChgDir',mode=1,path='/pc0/RENAMED/CHILD');ok('ChgDir',mode=1,path='..')
    ok('Open',mode=1,path='NEST.TXT');ok('Read',count=7);assert p.data(f.OUTPUT,7)==b'NESTED\r';ok('Close')
    ok('ChgDir',mode=1,path='/pc0/RENAMED')
    ok('Open',mode=0x82,path='/pc0');rename('RENAMED','SUBDIR','E$Share');ok('Close')
    ok('ChgDir',mode=1,path='/pc0')
    ok('ChgDir',mode=4,path='/pc0/RENAMED')
    ok('Open',mode=0x82,path='/pc0');rename('RENAMED','SUBDIR','E$Share');ok('Close')
    ok('ChgDir',mode=4,path='/pc0')
    ok('Open',mode=0x82,path='/pc0');rename('RENAMED','SUBDIR');ok('Close')
    for mode,path in [(0x81,'/pc0'),(1,'/pc0/FRAG.BIN'),(3,'/pc0/FRAG.BIN')]:
        ok('Open',mode=mode,path=path);rename('HELLO.TXT','HI.TXT','E$FNA');ok('Close')
    ok('Open',mode=0x82,path='/pc0')
    for service,kw in [('Write',{'count':1}),('SetStat',{'status':p.s['SS.Size'],'position':0})]:
        result=p.call(service,**kw);assert result[:2]==(1,p.s['E$FNA']),result
    ok('Close')
    # Root growth and distant source/destination entries require separate reads.
    for i in range(25):ok('Create',mode=3,path=f'/pc0/F{i}.TXT');ok('Close')
    ok('Open',mode=0x82,path='/pc0')
    rename('F24.TXT','F0.TXT','E$CEF');rename('F24.TXT','LAST.TXT');rename('F0.TXT','FIRST.TXT')
    ok('Close')
    # A preceding LFN entry forbids mutation of its short-name alias.
    ok('MkDir',path='/pc0/LFNDIR');ok('Create',mode=3,path='/pc0/LFNDIR/ALIAS.TXT');ok('Close')
    ok('Open',mode=0x82,path='/pc0/LFNDIR')
    cluster=int.from_bytes(p.data(f.WORK+p.fs['F.Start'],4),'big');sector=v.sectors[v.data+cluster-2]
    sector[96:128]=sector[64:96];sector[64:96]=v.entry('LONGNAME',0,0,0x0f)
    checksum=0
    for char in sector[96:107]:checksum=(((checksum&1)<<7)+(checksum>>1)+char)&255
    sector[77]=checksum  # LFN checksum must actually belong to ALIAS.TXT
    rename('ALIAS.TXT','OTHER.TXT','E$FNA');ok('Close')
    assert p.allocations==[w.b.STATE]
    print(f'PASS Level {level}: SS.Rename names/collisions/case/modes/LFN/live cwd+cxd/metadata/position/cross-sector/I/O failures',flush=True)

if __name__=='__main__':
    with tempfile.TemporaryDirectory(prefix='pcf-rename-') as folder:
        for level in (1,2):tests(Path(folder),level)
