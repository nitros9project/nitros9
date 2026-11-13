#!/usr/bin/env python3
"""Execute deldir on MC6809 with syscall peers; real recursion is tested in MAME."""
import importlib.util
import tempfile
from pathlib import Path

spec=importlib.util.spec_from_file_location('rename_tests',Path(__file__).with_name('test-rename.py'))
t=importlib.util.module_from_spec(spec);spec.loader.exec_module(t)


def tests(binary,s,level):
    def run(device=4,child_error=0,read_error=0,attr_error=0,seek_error=0,regular=False,legacy=False):
        cfg=t.TestCfg({'trace':False,'verbosity':0});m=t.Memory(cfg);c=t.CPU(m,cfg)
        m.load(t.BASE,binary);m.load(0x1400,b'tree\r')
        c.user_stack_pointer.set(0x1000);c.direct_page.set(0x10);c.index_x.set(0x1400)
        c.system_stack_pointer.set(0x7800);c.program_counter.set(t.BASE+s['start'])
        forks=[];deleted=[];given=False;closed=False;raw_index=0
        def get(a,n):return bytes(m.read_byte(a+i) for i in range(n))
        def line(a):return get(a,80).split(b'\r',1)[0]
        for _ in range(100000):
            pc=c.program_counter.value
            if get(pc,2)!=b'\x10\x3f':c.get_and_call_next_op();continue
            op=m.read_byte(pc+2);c.C=0
            if op==s['F$Exit']:return c.accu_b.value,forks,deleted
            if op==s['I$Open']:
                if not regular and c.accu_a.value==3:c.C=1;c.accu_b.set(s['E$FNA'])
                else:c.accu_a.set(3)
            elif op==s['F$PrsNam']:
                x=c.index_x.value;y=x
                while m.read_byte(y) not in (13,32):
                    ch=m.read_byte(y);y+=1
                    if ch&128:break
                c.index_y.set(y);c.accu_b.set(y-x)
            elif op==s['I$GetStt']:
                if c.accu_b.value==s['SS.Opt']:m.load(c.index_x.value,bytes([device])+bytes(31))
                else:
                    assert c.accu_b.value==s['SS.ReadDir'] and c.index_y.value==32
                    if legacy:c.C=1;c.accu_b.set(s['E$UnkSvc'])
                    elif read_error or given:c.C=1;c.accu_b.set(read_error or s['E$EOF'])
                    else:m.load(c.index_x.value,t.entry('x'*29,0x123456));given=True
            elif op==s['I$Read']:
                assert legacy and c.index_y.value==32
                records=[t.entry('.',10),t.entry('..',10),bytes(32),t.entry('x'*29,0x123456)]
                if read_error or raw_index==len(records):c.C=1;c.accu_b.set(read_error or s['E$EOF'])
                else:m.load(c.index_x.value,records[raw_index]);raw_index+=1
            elif op==s['I$Seek']:
                assert c.index_x.value==0 and c.user_stack_pointer.value==0
                if seek_error:c.C=1;c.accu_b.set(seek_error)
            elif op==s['I$ReadLn']:m.load(c.index_x.value,b'd\r')
            elif op==s['I$WritLn']:pass
            elif op==s['I$ChgDir']:assert c.accu_a.value==s['READ.']
            elif op==s['F$Fork']:
                name=line(c.index_x.value);params=get(c.user_stack_pointer.value,c.index_y.value)
                forks.append((name,params));c.accu_a.set(2)
            elif op==s['F$Wait']:
                c.accu_a.set(2);c.accu_b.set(attr_error if forks[-1][0]==b'ATTR' else child_error)
            elif op==s['I$Close']:closed=True
            elif op==s['I$Delete']:
                assert closed;deleted.append(line(c.index_x.value));c.index_x.set(c.index_x.value+4)
            else:raise AssertionError(('unexpected syscall',op))
            c.program_counter.set(pc+3)
        raise AssertionError('deldir did not exit')
    status,forks,deleted=run()
    assert status==0 and deleted==[b'tree'] and forks==[(b'DELDIR',b'x'*29+b'\r')],(status,forks,deleted)
    status,forks,deleted=run(device=s['DT.RBF'],legacy=True)
    assert status==0 and deleted==[b'tree'] and forks[0]==(b'DELDIR',b'x'*29+b'\r')
    status,forks,deleted=run(device=s['DT.RBF'])
    assert status==0 and deleted==[b'tree'] and forks[-1]==(b'ATTR',b'tree -d\r')
    for error in (1,s['E$Share'],s['E$FNA']):
        status,forks,deleted=run(child_error=error)
        assert status==error and not deleted and len(forks)==1,(status,forks,deleted)
    for error in (s['E$Read'],):
        status,forks,deleted=run(read_error=error)
        assert status==error and not forks and not deleted
    status,forks,deleted=run(device=s['DT.RBF'],attr_error=s['E$FNA'])
    assert status==s['E$FNA'] and not deleted
    status,forks,deleted=run(seek_error=s['E$Seek'])
    assert status==s['E$Seek'] and not forks and not deleted
    status,forks,deleted=run(regular=True)
    assert status==0 and not forks and deleted==[b'tree']
    print(f'Level {level}: deldir portable enumeration, 29-character names, RBF ATTR, child/status failures, file deletion PASS')


if __name__=='__main__':
    with tempfile.TemporaryDirectory() as folder:
        for level in (1,2):
            binary,symbols=t.assemble(Path(folder),level,'level1/cmds/deldir.asm')
            tests(binary,symbols,level)
