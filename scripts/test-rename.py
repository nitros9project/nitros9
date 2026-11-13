#!/usr/bin/env python3
"""Execute SS.Rename in both assembled RBFs with a deterministic sector peer.
Requires MC6809 and lwasm. Disk I/O and lock scheduling are intercepted; name
validation, permissions, scanning, updates, and cleanup execute as real 6809.
"""
import os, re, subprocess, tempfile, logging
from pathlib import Path
from MC6809.components.cpu6809 import CPU
from MC6809.components.memory import Memory
from MC6809.tests.test_config import TestCfg
logging.disable(logging.CRITICAL)
ROOT=Path(__file__).resolve().parents[1]
BASE,PD,REGS,BUF,DATA,EXT,PROC=0x2000,0x600,0x700,0x5000,0x5400,0x800,0x900

def assemble(tmp,level,source):
    (tmp/'defsfile').write_text(f'Level equ {level}\n use os9.d\n use scf.d\n use rbf.d\n use coco.d\n')
    (tmp/'source.asm').write_text((ROOT/source).read_text())
    subprocess.run([os.environ.get('LWASM','lwasm'),'--6309','--format=os9',
        '--pragma=pcaspcr,nosymbolcase,condundefzero,undefextern,dollarnotlocal,noforwardrefmax',
        '-I'+str(tmp),'-I'+str(ROOT/'defs'),'-DH6309=0','-DCoCo=3',str(tmp/'source.asm'),
        '-o'+str(tmp/'module'),'--symbol-dump='+str(tmp/'symbols')],check=True,capture_output=True)
    sy=dict((n,int(v,16)) for n,v in re.findall(r'^(\S+) (?:EQU|SET) \$([0-9A-Fa-f]+)$',(tmp/'symbols').read_text(),re.M))
    return (tmp/'module').read_bytes(),sy

def entry(name,fd):
    b=bytearray(32);n=name.encode();b[:len(n)]=n;b[len(n)-1]|=128;b[29:]=fd.to_bytes(3,'big');return b

def record(old,new):return old.encode().ljust(30,b'\0')+new.encode().ljust(30,b'\0')

class RBF:
    def __init__(self,binary,s,level,attrs=0x82,owner=1,user=1):
        cfg=TestCfg({'trace':False,'verbosity':0});self.m=Memory(cfg);self.c=CPU(self.m,cfg);self.s=s;self.level=level
        self.m.load(BASE,binary);self.disk=bytearray().join([entry('..',10),entry('.',10),entry('old',20),entry('taken',21)])
        self.writes=0;self.locked=False;self.fail_write=False;self.fail_move=False;self.fail_read=False;self.fail_lock=False
        self.fd=bytearray(256);self.fd[s['FD.ATT']]=attrs;self.fd[s['FD.OWN']:s['FD.OWN']+2]=owner.to_bytes(2,'big')
        self.w(PD+s['PD.BUF'],BUF);self.w(PD+s['PD.Exten'],EXT);self.w(EXT+s.get('PE.Confl',0),EXT)
        self.w(s['D.Proc'],PROC);self.w(PROC+s['P$User'],user);self.w(PD+s['PD.RGS'],REGS)
        self.m.write_byte(PD+s['PD.MOD'],0x82)
        self.w(PD+s['PD.CP']+2,96)
    def w(self,a,v):self.m.write_word(a,v)
    def get(self,a,n):return bytes(self.m.read_byte(a+i) for i in range(n))
    def pos(self):return int.from_bytes(self.get(PD+self.s['PD.CP'],4),'big')
    def ret(self):
        p=self.c.system_stack_pointer.value;self.c.program_counter.set(self.m.read_word(p));self.c.system_stack_pointer.set(p+2)
    def result(self,error=0):self.c.C=int(error!=0);self.c.accu_b.set(error)
    def run(self,packet=None,count=60):
        s=self.s;c=self.c;self.m.load(DATA,packet or record('old','new'))
        self.w(REGS+s['R$X'],DATA);self.w(REGS+s['R$Y'],count);self.m.write_byte(REGS+s['R$B'],s['SS.Rename'])
        c.index_y.set(PD);c.user_stack_pointer.set(REGS);c.system_stack_pointer.set(0x7800);self.w(0x7800,0x1fff);c.program_counter.set(BASE+s['SetStat'])
        traps={BASE+s[n]:n for n in ['RdFlDscr','L1237','L0957','L0942','L1205']}
        if self.level==2:traps.update({BASE+s[n]:n for n in ['L0B1B','L0ACF']})
        for _ in range(100000):
            pc=c.program_counter.value
            if pc==0x1fff:break
            name=traps.get(pc)
            if name:
                if name=='RdFlDscr':
                    self.fd[s['FD.SIZ']:s['FD.SIZ']+4]=len(self.disk).to_bytes(4,'big');self.m.load(BUF,self.fd);c.user_stack_pointer.set(BUF);self.result()
                elif name=='L1237':self.m.write_byte(PD+s['PD.SMF'],0);self.result()
                elif name=='L0B1B':self.locked=not self.fail_lock;self.result(s['E$Lock'] if self.fail_lock else 0)
                elif name=='L0ACF':self.locked=False;self.m.write_byte(EXT+s['PE.Lock'],0);self.result()
                elif name in ('L0957','L0942'):
                    if self.level==2:assert self.locked,'scan without directory lock'
                    pos=self.pos()+(32 if name=='L0942' else 0);self.m.load(PD+s['PD.CP'],pos.to_bytes(4,'big'))
                    if self.fail_read:self.result(s['E$Read'])
                    elif pos>=len(self.disk):self.result(s['E$EOF'])
                    else:
                        start=pos&~255;self.m.load(BUF,bytes(self.disk[start:start+256]).ljust(256,b'\0'));c.index_x.set(BUF+(pos&255));self.result()
                elif name=='L1205':
                    if self.level==2:assert self.locked,'write without directory lock'
                    self.writes+=1
                    if self.fail_write:self.result(s['E$Write'])
                    else:
                        start=self.pos()&~255;n=min(256,len(self.disk)-start);self.disk[start:start+n]=self.get(BUF,n);self.result()
                self.ret()
            elif self.get(pc,2)==b'\x10\x3f':
                op=self.m.read_byte(pc+2)
                assert op==s['F$Move'],(hex(op),hex(pc))
                if self.fail_move:self.result(s['E$IBA'])
                else:self.m.load(c.user_stack_pointer.value,self.get(c.index_x.value,c.index_y.value));self.result()
                c.program_counter.set(pc+3)
            else:c.get_and_call_next_op()
        else:raise AssertionError('RBF rename did not return')
        assert self.pos()==96,('position changed',self.pos())
        assert c.index_y.value==PD and c.user_stack_pointer.value==REGS
        assert c.system_stack_pointer.value==0x7802
        assert not self.locked
        return c.accu_b.value if c.C else 0

def tests(binary,s,level):
    for old,new in [('old','new'),('OLD','old'),('old','x'*29),('old','old')]:
        p=RBF(binary,s,level);before=bytes(p.disk);assert p.run(record(old,new))==0
        assert p.disk[64:96]==entry(new,20);assert p.disk[:64]==before[:64] and p.disk[96:]==before[96:]
    p=RBF(binary,s,level);p.disk+=b''.join(entry('f'+str(i),30+i) for i in range(12));p.disk+=entry('far',90)
    assert p.run(record('far','newfar'))==0 and p.disk[-32:]==entry('newfar',90)
    for old,new,error in [('old','taken','E$CEF'),('absent','new','E$PNNF'),('.','new','E$BPNam'),('old','..','E$BPNam'),('old','a/b','E$BPNam'),('old','','E$BPNam')]:
        p=RBF(binary,s,level);before=bytes(p.disk);assert p.run(record(old,new))==s[error],(old,new);assert bytes(p.disk)==before and p.writes==0
    # Fixed-field boundaries and padding must remain strict after compaction.
    for offset in (0,30):
        for bad in (b'x'*30, b'a\0'+b'x'+bytes(27), bytes([0x80])+bytes(29), b'a/b'+bytes(27), b'a:b'+bytes(27), b'a\\b'+bytes(27)):
            packet=bytearray(record('old','new'));packet[offset:offset+30]=bad
            p=RBF(binary,s,level);before=bytes(p.disk)
            assert p.run(bytes(packet))==s['E$BPNam'] and p.writes==0
            assert bytes(p.disk)==before and p.get(DATA,60)==packet
    for name in ('x', 'x'*28, 'x'*29, '..x', 'x..', 'a@', 'a`'):
        p=RBF(binary,s,level);p.disk[64:96]=entry(name,20)
        assert p.run(record(name,'NEW'))==0 and p.disk[64:96]==entry('NEW',20)
    for attrs,owner,user,want in [(0x80,1,1,'E$FNA'),(0x82,2,1,'E$FNA'),(0x90,2,1,None),(0x82,1,1,None)]:
        p=RBF(binary,s,level,attrs,owner,user);assert p.run()==(0 if want is None else s[want])
    for flag,error in [('fail_read','E$Read'),('fail_write','E$Write')]+([('fail_move','E$IBA'),('fail_lock','E$Lock')] if level==2 else []):
        p=RBF(binary,s,level);setattr(p,flag,True);before=bytes(p.disk);result=p.run();assert result==s[error],(flag,result,s[error]);assert bytes(p.disk)==before
    p=RBF(binary,s,level);assert p.run(count=59)==s['E$BPNam'] and p.writes==0
    p=RBF(binary,s,level);p.m.write_byte(PD+s['PD.MOD'],0x81);assert p.run()==s['E$FNA']
    p=RBF(binary,s,level);p.disk+=entry('a@',44);assert p.run(record('a`','other'))==s['E$PNNF']
    if level==2:
        p=RBF(binary,s,level);p.m.write_byte(EXT+s['PE.Lock'],s['RcdLock'])
        assert p.run()==s['E$Share'] and p.m.read_byte(EXT+s['PE.Lock'])==s['RcdLock']
    print(f'Level {level}: RBF rename permissions, collisions, case, sectors, locks, failure cleanup PASS')

def command_tests(binary,s):
    def run(text,stat_error=0,close_error=0):
        cfg=TestCfg({'trace':False,'verbosity':0});m=Memory(cfg);c=CPU(m,cfg)
        m.load(BASE,binary);m.load(0x1200,text.encode()+b'\r');c.user_stack_pointer.set(0x1000);c.direct_page.set(0x10)
        c.index_x.set(0x1200);c.accu_d.set(len(text)+1);c.system_stack_pointer.set(0x7800);c.program_counter.set(BASE+s['start'])
        opens=[];packets=[];closes=[]
        def get(a,n):return bytes(m.read_byte(a+i) for i in range(n))
        for _ in range(10000):
            pc=c.program_counter.value
            if get(pc,2)!=b'\x10\x3f':c.get_and_call_next_op();continue
            op=m.read_byte(pc+2)
            if op==s['F$Exit']:return c.accu_b.value,opens,packets,closes
            if op==s['F$PrsNam']:
                original=c.index_x.value;x=original+(m.read_byte(original)==47);y=x
                def valid(b,first=False):return chr(b&127).isalnum() or b==95 or (not first and b==46)
                if not valid(m.read_byte(y),True):
                    while m.read_byte(y) in (32,44):y+=1
                    c.index_y.set(y);c.accu_a.set(m.read_byte(y));c.accu_b.set(s['E$BNam']);c.C=1
                else:
                    while valid(m.read_byte(y)):
                        b=m.read_byte(y);y+=1
                        if b&128:break
                    c.index_x.set(x);c.index_y.set(y);c.accu_a.set(m.read_byte(y));c.accu_b.set(y-x);c.C=0
            elif op==s['I$Open']:
                x=c.index_x.value;name=bytearray()
                while m.read_byte(x)!=13:name.append(m.read_byte(x));x+=1
                opens.append((name.decode(),c.accu_a.value));c.accu_a.set(3);c.C=0
            elif op==s['I$SetStt']:
                assert c.accu_a.value==3 and c.accu_b.value==s['SS.Rename'] and c.index_y.value==60
                packets.append(get(c.index_x.value,60))
                if stat_error:c.accu_b.set(stat_error)
                c.C=int(stat_error!=0)
            elif op==s['I$Close']:
                closes.append(c.accu_a.value);c.accu_b.set(close_error);c.C=int(close_error!=0)
            else:raise AssertionError(('unexpected command syscall',op))
            c.program_counter.set(pc+3)
        raise AssertionError('command did not exit')
    for text,parent,old,new in [('old new','.','old','new'),('/dd/sys/old new','/dd/sys','old','new'),('sys/old NEW','sys','old','NEW'),('old   new','.','old','new'),('  old new','.','old','new'),('../old new','..','old','new')]:
        result,opens,packets,closes=run(text)
        assert (result,opens,packets,closes)==(0,[(parent,0x82)],[record(old,new)],[3]),(text,result,opens,packets,closes)
    for text in ['old','old ..','old a/b','x'*30+' new']:
        result,opens,packets,closes=run(text);assert result and not opens and not packets,text
    for se,ce in [(218,0),(0,245),(218,245)]:
        result,opens,packets,closes=run('old new',se,ce);assert result==(se or ce) and closes==[3],(se,ce,result)
    print('rename command: parent-only open, path splitting, packet, validation and close errors PASS')

if __name__=='__main__':
    with tempfile.TemporaryDirectory() as folder:
        tmp=Path(folder)
        for level in (1,2):
            b,s=assemble(tmp,level,f'level{level}/modules/rbf.asm');tests(b,s,level)

        b,s=assemble(tmp,1,'level1/cmds/rename.asm');command_tests(b,s)
