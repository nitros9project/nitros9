#!/usr/bin/env python3
"""Execute assembled RBF SS.ReadDir with deterministic sector I/O.
The scanner, cursor arithmetic, filtering and result copies execute on MC6809.
"""
import importlib.util, tempfile
from pathlib import Path
spec=importlib.util.spec_from_file_location('rename_tests',Path(__file__).with_name('test-rename.py'))
t=importlib.util.module_from_spec(spec);spec.loader.exec_module(t)

class Reader(t.RBF):
    def __init__(self,b,s,level):
        super().__init__(b,s,level)
        self.disk=bytearray(t.entry('..',10)+t.entry('.',10)+bytes(32)+t.entry('one',20)+t.entry('x'*29,21))
        self.m.load(t.PD+s['PD.CP'],bytes(4));self.m.load(t.PD+s['PD.SIZ'],len(self.disk).to_bytes(4,'big'))
        self.m.write_byte(t.PD+s['PD.MOD'],0x81)
        self.fd_reads=0;self.sector_reads=0;self.fail_fd=False
        self.metadata=bytes([0x0b,0,2,126,11,8,14,30,1,0,0,1,2])
    def run(self,count=32):
        s=self.s;c=self.c
        self.w(t.REGS+s['R$X'],t.DATA);self.w(t.REGS+s['R$Y'],count);self.m.write_byte(t.REGS+s['R$B'],s['SS.ReadDir'])
        self.m.load(t.DATA,b'\x55'*64)
        c.index_y.set(t.PD);c.user_stack_pointer.set(t.REGS);c.system_stack_pointer.set(0x7800);self.w(0x7800,0x1fff);c.program_counter.set(t.BASE+s['GetStat'])
        traps={t.BASE+s[n]:n for n in ['L1098','L1256','ReadCurrentSector']}
        if self.level==2:traps.update({t.BASE+s[n]:n for n in ['L0B0C','L0B02']})
        for _ in range(100000):
            pc=c.program_counter.value
            if pc==0x1fff:break
            name=traps.get(pc)
            if name:
                if name=='L1256':
                    self.sector_reads+=1
                    start=self.pos()&~255;self.m.load(t.BUF,bytes(self.disk[start:start+256]).ljust(256,b'\0'))
                    self.m.write_byte(t.PD+s['PD.SMF'],s['SINBUF']|s.get('BufBusy',0));self.result(s['E$Read'] if self.fail_read else 0)
                elif name=='ReadCurrentSector':
                    self.fd_reads+=1;assert c.accu_b.value==0 and c.index_x.value in (20,21)
                    self.m.load(t.BUF,self.metadata+bytes(243));self.result(s['E$Read'] if self.fail_fd else 0)
                elif name=='L0B02':self.locked=False # preserve C/B
                elif name=='L0B0C':self.result(s['E$Lock'] if self.fail_lock else 0)
                else:self.result()
                self.ret()
            elif self.get(pc,2)==b'\x10\x3f':
                assert self.m.read_byte(pc+2)==s['F$Move']
                if self.fail_move:self.result(s['E$IBA'])
                else:self.m.load(c.user_stack_pointer.value,self.get(c.index_x.value,c.index_y.value));self.result()
                c.program_counter.set(pc+3)
            else:c.get_and_call_next_op()
        else:raise AssertionError('ReadDir did not return')
        assert c.index_y.value==t.PD and c.user_stack_pointer.value==t.REGS
        assert c.system_stack_pointer.value==0x7802
        return c.accu_b.value if c.C else 0

def tests(b,s,level):
    p=Reader(b,s,level)
    assert p.run()==0 and p.get(t.DATA,32)==t.entry('one',20) and p.pos()==128
    assert p.get(t.DATA+32,1)==b'\x55'
    assert p.run()==0 and p.get(t.DATA,32)==t.entry('x'*29,21) and p.pos()==160
    assert p.fd_reads==0 and p.sector_reads==1,(p.fd_reads,p.sector_reads)
    assert p.run()==s['E$EOF'] and p.run()==s['E$EOF']
    p=Reader(b,s,level)
    assert p.run(45)==0 and p.get(t.DATA,45)==t.entry('one',20)+p.metadata
    assert p.run(45)==0 and p.fd_reads==2 and p.sector_reads==2
    for n in (0,31,33,44,46,256):
        p=Reader(b,s,level);assert p.run(n)==s['E$BPNam'] and p.pos()==0
    for mode in (1,0x80,0x82):
        p=Reader(b,s,level);p.m.write_byte(t.PD+s['PD.MOD'],mode);assert p.run()==s['E$FNA']
    p=Reader(b,s,level);p.w(t.PD+s['PD.CP']+2,1);assert p.run()==s['E$BPNam'] and p.pos()==1
    p=Reader(b,s,level);p.fail_fd=True
    assert p.run(45)==s['E$Read'] and p.pos()==96
    p.fail_fd=False;assert p.run(45)==0 and p.pos()==128
    p=Reader(b,s,level);p.fail_read=True;assert p.run()==s['E$Read'] and p.pos()==0
    if level==2:
        p=Reader(b,s,level);p.fail_move=True;assert p.run()==s['E$IBA'] and p.pos()==96
    if level==2:
        p=Reader(b,s,level);p.fail_lock=True;assert p.run()==s['E$Lock'] and p.pos()==0
    p=Reader(b,s,level);p.disk=bytearray(bytes(256)+t.entry('one',20));p.m.load(t.PD+s['PD.SIZ'],len(p.disk).to_bytes(4,'big'))
    assert p.run()==0 and p.pos()==288 and p.sector_reads==2
    p=Reader(b,s,level);p.disk=bytearray(bytes(65504)+t.entry('one',20));p.m.load(t.PD+s['PD.SIZ'],len(p.disk).to_bytes(4,'big'));p.w(t.PD+s['PD.CP']+2,65504)
    assert p.run()==0 and p.pos()==65536 and p.run()==s['E$EOF']
    print(f'Level {level}: ReadDir filtering, metadata, cached sectors, cursor, EOF, modes and failure retry PASS')

def command_tests(binary,s):
    def run(options='',width=80,error=0,empty=False,legacy=False,raw_error=0):
        cfg=t.TestCfg({'trace':False,'verbosity':0});m=t.Memory(cfg);c=t.CPU(m,cfg)
        m.load(t.BASE,binary);m.load(0x1400,(options+' /dd\r').encode())
        c.user_stack_pointer.set(0x1000);c.direct_page.set(0x10);c.index_x.set(0x1400)
        c.system_stack_pointer.set(0x7800);c.program_counter.set(t.BASE+s['start'])
        calls=[];output=bytearray();given=False;raw_index=0
        metadata=bytes([0x0b,0,2,126,11,8,14,30,1,0,0,1,2])
        def get(a,n):return bytes(m.read_byte(a+i) for i in range(n))
        for _ in range(100000):
            pc=c.program_counter.value
            if get(pc,2)!=b'\x10\x3f':c.get_and_call_next_op();continue
            op=m.read_byte(pc+2);c.C=0
            if op==s['F$Exit']:return c.accu_b.value,bytes(output),calls
            if op==s['I$GetStt']:
                stat=c.accu_b.value
                if stat==s['SS.ScSiz']:c.index_x.set(width)
                else:
                    if stat==s['SS.FDInf']:
                        assert legacy and c.index_y.value==13 and c.user_stack_pointer.value==20
                        m.load(c.index_x.value,metadata);c.program_counter.set(pc+3);continue
                    assert stat==s['SS.ReadDir'],'unexpected status'
                    if legacy:
                        c.C=1;c.accu_b.set(s['E$UnkSvc']);c.program_counter.set(pc+3);continue
                    count=c.index_y.value;calls.append(count)
                    if error or given or empty:c.C=1;c.accu_b.set(error or s['E$EOF'])
                    else:
                        data=t.entry('hello',20)+bytes([0x0b,0,2,126,11,8,14,30,1,0,0,1,2])
                        m.load(c.index_x.value,data[:count]);given=True
            elif op==s['I$Read']:
                assert legacy and c.index_y.value==32
                records=[t.entry('.',10),t.entry('..',10),bytes(32),t.entry('hello',20)]
                if raw_error or raw_index==len(records):c.C=1;c.accu_b.set(raw_error or s['E$EOF'])
                else:m.load(c.index_x.value,records[raw_index]);raw_index+=1
            elif op==s['I$Open']:assert c.accu_a.value&0x81==0x81;c.accu_a.set(3)
            elif op==s['I$ChgDir']:
                x=c.index_x.value
                while m.read_byte(x) not in (13,32):x+=1
                c.index_x.set(x)
            elif op==s['F$Time']:m.load(c.index_x.value,bytes([126,11,8,14,30,0]))
            elif op in (s['I$Write'],s['I$WritLn']):
                data=get(c.index_x.value,c.index_y.value)
                if op==s['I$WritLn']:data=data.split(b'\r')[0]+b'\r'
                output.extend(data)
            else:raise AssertionError(('unexpected dir syscall',op))
            c.program_counter.set(pc+3)
        raise AssertionError('dir failed to exit')
    for options in ('','-e','-x','-ex'):
        for width in (32,80):
            status,output,calls=run(options,width)
            assert status==0 and b'hello' in output,(options,width,status,output)
            assert calls==([45,45] if 'e' in options else [32,32]),calls
            if 'e' in options:assert b'ID' in output and b'Sector' not in output and b'102' in output,output
    assert run(error=s['E$Read'])[0]==s['E$Read']
    for options in ('','-e','-x','-ex'):
        for width in (32,80):
            status,output,_=run(options,width,legacy=True)
            assert status==0 and b'hello' in output,(options,width,status,output)
            if 'e' in options:assert b'102' in output
    assert run(legacy=True,raw_error=s['E$Read'])[0]==s['E$Read']
    assert run(empty=True)[0]==0
    print('dir: names, extended, execution, narrow/wide, EOF and error propagation PASS')

if __name__=='__main__':
    with tempfile.TemporaryDirectory() as folder:
        tmp=Path(folder)
        for level in (1,2):
            b,s=t.assemble(tmp,level,f'level{level}/modules/rbf.asm');tests(b,s,level)
        b,s=t.assemble(tmp,1,'level1/cmds/dir.asm');command_tests(b,s)
