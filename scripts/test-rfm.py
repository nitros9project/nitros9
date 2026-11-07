#!/usr/bin/env python3
"""Execute assembled RFM on MC6809 with a deterministic DriveWire peer.
Requires MC6809 (pip install MC6809) and lwasm. No running OS/server required.
"""
import os, re, subprocess, tempfile, logging
logging.disable(logging.CRITICAL)
from pathlib import Path
from MC6809.components.cpu6809 import CPU
from MC6809.components.memory import Memory
from MC6809.tests.test_config import TestCfg
ROOT = Path(__file__).resolve().parents[1]
BASE, PD, REGS, BUF, DATA = 0x2000, 0x600, 0x700, 0x1000, 0x4000

def assemble(tmp, level, source="rfm.asm"):
    defs = tmp / 'defsfile'
    defs.write_text(f'Level equ {level}\n use os9.d\n use scf.d\n use rbf.d\n use coco.d\n')
    subprocess.run([os.environ.get('LWASM','lwasm'), '--6309', '--format=os9',
        '--pragma=pcaspcr,nosymbolcase,condundefzero,undefextern,dollarnotlocal,noforwardrefmax',
        '--includedir='+str(tmp), '--includedir='+str(ROOT/'defs'), '-DH6309=0', '-DCoCo=3',
        str(ROOT/'level1/modules'/source), '-o'+str(tmp/'rfm'),
        '--symbol-dump='+str(tmp/'symbols')],check=True,capture_output=True)
    syms = dict((n,int(v,16)) for n,v in re.findall(r'^(\S+) (?:EQU|SET) \$([0-9A-Fa-f]+)$',(tmp/'symbols').read_text(),re.M))
    return (tmp/'rfm').read_bytes(), syms

class Peer:
    def __init__(self, binary, syms):
        cfg=TestCfg({'trace':False,'verbosity':0}); self.m=Memory(cfg); self.c=CPU(self.m,cfg); self.sy=syms
        self.m.load(BASE, binary); self.tx=[]; self.rx=[]; self.freed=[]; self.fail_move=False; self.fail_alloc=False; self.move_count=0; self.fail_move_at=0
        self.wire_active=False; self.wire_op=0; self.wire_phase=0; self.wire_count=0; self.gaps=[]
        self.setw(PD+syms['PD.BUF'],BUF); self.setw(PD+syms['PD.DEV'],0x800)
        self.setw(0x800+syms['V$STAT'],0x900)
        self.m.write_byte(PD+syms['PD.PD'],7)
        self.setw(syms['D.Proc'],0xa00)
        if 'P$Task' in syms:self.m.write_byte(0xa00+syms['P$Task'],3)
        if 'D.SysTsk' in syms:self.m.write_byte(syms['D.SysTsk'],0)
        self.setw(syms['D.DWSubAddr'],0x1800)
    def setw(self,a,v):self.m.write_word(a,v)
    def word(self,a):return self.m.read_word(a)
    def get(self,a,n):return bytes(self.m.read_byte(a+i) for i in range(n))
    def ret(self):
        s=self.c.system_stack_pointer.value
        self.c.program_counter.set(self.word(s));self.c.system_stack_pointer.set(s+2)
    def run(self,name,n=0,status=0,data=b'',responses=(),initial_cc=0):
        c=self.c;s=self.sy;self.tx=[];self.rx=list(responses)
        self.m.load(DATA,data or b'\x00'); self.setw(REGS+s['R$X'],DATA)
        self.setw(REGS+s['R$Y'],n);self.m.write_byte(REGS+s['R$B'],status)
        c.index_y.set(PD);c.user_stack_pointer.set(REGS);c.system_stack_pointer.set(0x7000)
        self.setw(0x7000,0x1fff);c.program_counter.set(BASE+s[name]);c.set_cc(initial_cc)
        for _ in range(300000):
            pc=c.program_counter.value
            if self.wire_active and (c.get_cc_value() & 0x50) != 0x50:
                self.gaps.append(pc)
            if pc==0x1fff:break
            if pc==0x1806:
                packet=self.get(c.index_x.value,c.index_y.value)
                self.tx.append(packet)
                assert c.get_cc_value() & 0x50 == 0x50, ('unmasked DriveWire send',name,hex(pc))
                if not self.wire_active:
                    assert packet[0]==0xd6,packet
                    self.wire_op=packet[1];self.wire_phase=0
                    self.wire_count=int.from_bytes(packet[3:5],'big') if self.wire_op in (7,8,9,10) else 0
                    self.wire_active=not (self.wire_op in (8,10) and self.wire_count==0)
                elif self.wire_op in (8,10):
                    self.wire_active=False
                c.index_x.set((c.index_x.value+c.index_y.value)&65535);c.index_y.set(0);self.ret()
            elif pc==0x1803:
                assert c.get_cc_value() & 0x50 == 0x50, ('unmasked DriveWire receive',name,hex(pc))
                response=self.rx.pop(0) if self.rx else None
                if response is None:
                    self.wire_active=False
                elif self.wire_op in (7,9) and self.wire_phase==0:
                    count=int.from_bytes(response,'big')
                    self.wire_active=0<count<=self.wire_count
                    self.wire_phase=1
                elif self.wire_op==0x14 and self.wire_phase==0 and response==b'\x00':
                    self.wire_phase=1
                else:
                    self.wire_active=False
                if response is None:c.C=1;c.Z=0
                else:
                    assert len(response)==c.index_y.value,(len(response),c.index_y.value,name)
                    self.m.load(c.index_x.value,response);c.index_y.set(sum(response)&65535);c.C=0;c.Z=1
                self.ret()
            elif self.get(pc,2)==b'\x10\x3f':
                op=self.m.read_byte(pc+2)
                if op==s.get('F$Move',-1):
                    self.move_count+=1
                    if self.fail_move or self.move_count==self.fail_move_at:c.accu_b.set(s['E$IBA']);c.C=1
                    else:self.m.load(c.user_stack_pointer.value,self.get(c.index_x.value,c.index_y.value));c.C=0
                    c.I=0;c.F=0 # Real Level 2 F$Move permits IRQs after restoring MMU slots.
                elif op==s['F$SRtMem']:self.freed.append(c.user_stack_pointer.value);c.C=0
                elif op==s['F$SRqMem']:
                    if self.fail_alloc:c.accu_b.set(s['E$MemFul']);c.C=1
                    else:c.user_stack_pointer.set(BUF);c.C=0
                elif op==s.get('F$LDABX',-1):c.accu_a.set(self.m.read_byte(c.index_x.value))
                else:raise AssertionError(('unexpected syscall',hex(op),hex(pc)))
                c.program_counter.set(pc+3)
            else:c.get_and_call_next_op()
        else:raise AssertionError(('did not return',name,hex(c.program_counter.value)))
        assert c.get_cc_value() & 0x50 == initial_cc & 0x50, ('caller interrupt masks changed',name)
        assert not self.gaps, ('IRQ poller can steal an RFM reply',name,[hex(pc) for pc in self.gaps[:5]])
        assert c.system_stack_pointer.value==0x7002,hex(c.system_stack_pointer.value)
        assert c.index_y.value==PD and c.user_stack_pointer.value==REGS
        return c.C,c.accu_b.value,self.word(REGS+s['R$Y'])

def tests(binary,s,level):
    def peer():return Peer(binary,s)
    for cc in (0,0x10,0x40,0x50):
        for operation,n,status,responses in (
                ('read',1,0,[b'\x00\x01',b'x']),
                ('write',1,0,[]),('seek',0,0,[b'\x00']),
                ('close',0,0,[b'\x00']),
                ('getstt',0,s['SS.Size'],[b'\x00'*4]),
                ('getstt',1,s['SS.FD'],[b'x']),
                ('getstt',0,s['SS.Opt'],[]),
                ('open',0,0,[b'\x00']),
                ('chgdir',0,0,[b'\x00',b'\x60\x00\x01'])):
            p=peer()
            assert p.run(operation,n,status,data=b'/y0/file\r',responses=responses,initial_cc=cc)[0]==0
    for n in (0,1,255,256,257,513,1024):
        p=peer();payload=bytes(i%251 for i in range(n))
        assert p.run('write',n,data=payload)==(0,0,n)
        assert b''.join(p.tx[i] for i in range(1,len(p.tx),2))==payload
        for packet in p.tx[::2]:assert len(packet)==5 and int.from_bytes(packet[3:],'big')<=256
    p=peer();assert p.run('read',0)==(0,0,0) and not p.tx
    for n in (1,255,256,257,1024):
        p=peer();data=bytes(i%251 for i in range(n));responses=[]
        for offset in range(0,n,256):
            chunk=data[offset:offset+256];responses += [len(chunk).to_bytes(2,'big'),chunk]
        assert p.run('read',n,responses=responses)==(0,0,n)
        assert p.get(DATA,n)==data
    p=peer();assert p.run('read',512,responses=[b'\x01\x00',b'x'*255+b'\r',b'\x01\x00',b'y'*256])==(0,0,512)
    p=peer();assert p.run('read',1024,responses=[b'\x01\x00',b'x'*256,b'\x00\x00'])==(0,0,256)
    p=peer();assert p.run('readln',600,responses=[b'\x01\x00',b'a'*256,b'\x00\x2d',b'a'*44+b'\r'])==(0,0,301)
    p=peer();assert p.run('read',99,responses=[b'\x00\x00'])==(1,s['E$EOF'],0)
    p=peer();assert p.run('read',2,responses=[b'\x01\x01'])==(1,s['E$Read'],0)
    p=peer();assert p.run('read',8,responses=[None])==(1,s['E$Read'],0)
    p=peer();assert p.run('writln',600,data=b'a'*300+b'\r'+b'b'*299)==(0,0,301)
    assert b''.join(p.tx[i] for i in range(1,len(p.tx),2))==b'a'*300+b'\r'
    for status in ('SS.FD',):
        p=peer();data=bytes(range(64));assert p.run('getstt',64,s[status],responses=[data])[:2]==(0,0)
        assert p.get(DATA,64)==data
        p=peer();assert p.run('getstt',257,s[status])[0]==1 and not p.tx
    p=peer();options=bytes([6])+bytes(range(1,32))
    p.m.load(PD+s['PD.OPT'],options)
    assert p.run('getstt',0,s['SS.Opt'])[:2]==(0,0) and not p.tx
    assert p.get(DATA,32)==options
    p=peer();assert p.run('getstt',0,s['SS.Ready'])[:2]==(0,0) and not p.tx
    p=peer();assert p.run('getstt',0,0xfe)[0]==1 and not p.tx
    p=peer();assert p.run('setstt',4,s['SS.Size'])[0]==1 and not p.tx
    p=peer();assert p.run('getstt',0,s['SS.Size'],responses=[b'\x00\x01\x02\x03'])[:2]==(0,0)
    assert p.word(REGS+s['R$X'])==1 and p.word(REGS+s['R$U'])==0x203
    p=peer();p.m.write_byte(PD+s['PD.CNT'],1)
    assert p.run('close')[:2]==(0,0) and not p.tx and not p.freed
    for response in (b'\x00',b'\xd8',None):
        p=peer();p.run('close',responses=[response]);assert p.freed==[BUF] and p.word(PD+s['PD.BUF'])==0
    # Fork copies the two directory cookies; the path header must use the
    # selected copy, never PID/PPID. Exercise the actual assembled instructions.
    for mode,offset in ((0x81,2),(0x84,8),(0x85,8)):
        p=peer();p.m.write_byte(PD+s['PD.MOD'],mode)
        p.m.load(0xa00+s['P$DIO']+offset,b'\x60\x12\x34')
        assert p.run('open',data=b'.\r',responses=[b'\x00'])[:2]==(0,0)
        assert p.tx[0]==bytes([0xd6,0x12,7,0,0x60,0x12,0x34,mode]),p.tx
        p=peer();p.m.write_byte(PD+s['PD.MOD'],mode)
        p.m.load(0xa00+s['P$DIO'],bytes(range(12)))
        before=p.get(0xa00+s['P$DIO'],12)
        assert p.run('chgdir',data=b'/y0/data\r',responses=[b'\x00',b'\x60\x56\x78'])[:2]==(0,0)
        after=bytearray(before)
        for target,mask in ((2,0x1b),(8,0x24)):
            if mode&mask:after[target:target+3]=b'\x60\x56\x78'
        assert p.get(0xa00+s['P$DIO'],12)==after
        for responses in ([b'\xd8'],[b'\x00',None]):
            p=peer();p.m.write_byte(PD+s['PD.MOD'],mode)
            p.m.load(0xa00+s['P$DIO'],before)
            assert p.run('chgdir',data=b'/y0/missing\r',responses=responses)[0]==1
            assert p.get(0xa00+s['P$DIO'],12)==before
    for length in (1,255):
        p=peer();name=b'a'*length
        assert p.run('open',data=name+b'\r',responses=[b'\x00'])[:2]==(0,0)
        assert p.tx[1]==name+b'\r' and not p.freed
    for name in (b'\r',b'a'*256+b'\r'):
        p=peer();assert p.run('open',data=name)[0]==1 and not p.tx and p.freed==[BUF]
    p=peer();assert p.run('open',data=b'ab\xe3',responses=[b'\x00'])[:2]==(0,0)
    assert p.tx[1]==b'abc\r' and p.get(DATA,3)==b'ab\xe3'
    p=peer();assert p.run('open',data=b'file\r',responses=[None])[:2]==(1,s['E$Read'])
    assert p.freed==[BUF]
    p=peer();p.fail_alloc=True
    assert p.run('open',data=b'file\r')[:2]==(1,s['E$MemFul']) and not p.tx and not p.freed
    p=peer();assert p.run('getstt',32,s['SS.FDInf'],responses=[bytes(range(256))])[:2]==(0,0)
    assert p.get(DATA,32)==bytes(range(32)) and p.get(DATA+32,1)==b'\x00'
    if level==2:
        p=peer();p.fail_move_at=2
        assert p.run('write',513,data=b'x'*513)==(1,s['E$IBA'],256)
        assert len(p.tx)==2
        p=peer();p.fail_move=True
        assert p.run('write',7,data=b'1234567')[:2]==(1,s['E$IBA']) and not p.tx
    print(f'Level {level}: transfer, status, errors, line boundary and Close PASS')

def cpu_fixture(binary):
    cfg=TestCfg({'trace':False,'verbosity':0});m=Memory(cfg);c=CPU(m,cfg)
    m.load(BASE,binary);c.system_stack_pointer.set(0x7000);m.write_word(0x7000,0x1fff)
    c.user_stack_pointer.set(0x1234);c.set_cc(0)
    return m,c

def run_until_return(c,hook=lambda:False):
    for _ in range(400000):
        if c.program_counter.value==0x1fff:
            assert c.system_stack_pointer.value==0x7002
            return
        if not hook():c.get_and_call_next_op()
    raise AssertionError('instruction budget exhausted')

def transport_tests(tmp):
    source=tmp/'transport.asm'
    source.write_text(' org $2000\nIntMasks equ $50\nNOINTMASK equ 0\n use dwread/dwread_becker.asm\n use dwwrite/dwwrite_becker.asm\n')
    subprocess.run([os.environ.get('LWASM','lwasm'),'--format=raw',str(source),
        '--includedir='+str(ROOT/'level1/modules'),'-o'+str(tmp/'transport'),
        '--symbol-dump='+str(tmp/'transport.sym')],check=True,capture_output=True)
    symbols=dict((n,int(v,16)) for n,v in re.findall(r'^(\S+) (?:EQU|SET) \$([0-9A-Fa-f]+)$',(tmp/'transport.sym').read_text(),re.M))
    for payload,count,timeout in [(b'',0,False),(b'abc',3,False),(b'',1,True),(b'a',2,True)]:
        m,c=cpu_fixture((tmp/'transport').read_bytes());incoming=list(payload)
        m.add_read_byte_callback(lambda *args:2 if incoming else 0,0xff41)
        m.add_read_byte_callback(lambda *args:incoming.pop(0),0xff42)
        c.index_x.set(DATA);c.index_y.set(count);c.set_cc(0x40)
        c.program_counter.set(symbols['DWRead']);run_until_return(c)
        assert c.C==int(timeout) and c.Z==int(not timeout)
        assert c.index_x.value==DATA and c.user_stack_pointer.value==0x1234
        assert c.get_cc_value()&0x50==0x40
        if not timeout:assert c.index_y.value==sum(payload)
    for count in (0,1,256):
        m,c=cpu_fixture((tmp/'transport').read_bytes());out=[]
        m.load(DATA,b'a'*count);m.add_write_byte_callback(lambda cycles,pc,address,value:out.append(value),0xff42)
        c.index_x.set(DATA);c.index_y.set(count);c.program_counter.set(symbols['DWWrite'])
        run_until_return(c);assert bytes(out)==b'a'*count
    print('Becker transport: empty calls, checksum, timeout, partial timeout and mask restoration PASS')

def boot_tests(tmp):
    for level in (1,2):
        (tmp/'defsfile').write_text(f'Level equ {level}\n use os9.d\n use scf.d\n use rbf.d\n use coco.d\n')
        subprocess.run([os.environ.get('LWASM','lwasm'),'--6309','--format=os9',
            '--pragma=pcaspcr,nosymbolcase,condundefzero,undefextern,dollarnotlocal,noforwardrefmax',
            '--includedir='+str(tmp),'--includedir='+str(ROOT/'defs'),'--includedir='+str(ROOT/'level1/modules'),
            '-DH6309=0','-DCoCo=3','-DBECKER=1',str(ROOT/'level1/coco1/modules/boot_rfm.asm'),
            '-o'+str(tmp/'boot'),'--symbol-dump='+str(tmp/'boot.sym')],check=True,capture_output=True)
        sy=dict((n,int(v,16)) for n,v in re.findall(r'^(\S+) (?:EQU|SET) \$([0-9A-Fa-f]+)$',(tmp/'boot.sym').read_text(),re.M))
        valid=[b'\x00',b'\x00\x00\x01\x01',b'\x01\x00',b'a'*256,b'\x00\x01',b'b',b'\x00\x00',b'\x00']
        cases=[(valid,False),( [None],True),([b'\x00',b'\x00\x01\x00\x01'],True),
            ([b'\x00',b'\x00'*4],True),([b'\x00',b'\x00\x00\x01\x01',b'\x00\x00'],True),
            ([b'\x00',b'\x00\x00\x01\x01',b'\x01\x01'],True),
            ([b'\x00',b'\x00\x00\x00\x01',b'\x00\x02'],True)]
        for responses,error in cases:
            m,c=cpu_fixture((tmp/'boot').read_bytes());rx=list(responses);dots=[];chunks=[]
            def ret():
                sp=c.system_stack_pointer.value;c.program_counter.set(m.read_word(sp));c.system_stack_pointer.set(sp+2)
            def hook():
                pc=c.program_counter.value
                if pc==sy.get('D.BtBug',-1):
                    dots.append(c.accu_a.value);ret();return True
                if pc==BASE+sy['DWInit']:
                    ret();return True
                if pc==BASE+sy['DWWrite']:
                    c.index_x.set(c.index_x.value+c.index_y.value);c.index_y.set(0);ret();return True
                if pc==BASE+sy['DWRead']:
                    response=rx.pop(0)
                    if response is None:c.C=1;c.Z=0
                    else:
                        assert len(response)==c.index_y.value
                        if DATA<=c.index_x.value<DATA+257:chunks.append(response)
                        m.load(c.index_x.value,response);c.index_y.set(sum(response)&65535);c.C=0;c.Z=1
                    ret();return True
                if m.read_byte(pc)==0x10 and m.read_byte(pc+1)==0x3f:
                    assert m.read_byte(pc+2)==sy['F$BtMem' if level==2 else 'F$SRqMem']
                    c.user_stack_pointer.set(DATA);c.C=0;c.program_counter.set(pc+3);return True
                return False
            c.program_counter.set(BASE+sy['start']);run_until_return(c,hook)
            assert c.C==int(error),(level,error,c.C)
            assert dots==([ord('.')] * len(chunks) if level==2 else []),(level,dots,len(chunks))
            if not error:
                assert c.index_x.value==DATA and c.accu_d.value==257
                assert bytes(m.read_byte(DATA+i) for i in range(257))==b'a'*256+b'b'
        print(f'Level {level}: boot success, timeout, size overflow/zero, early EOF and oversized chunks PASS')

def driver_tests(tmp):
    for level in (1, 2):
        binary,sy=assemble(tmp,level,'rfmdrv.asm')
        for scenario in ('first', 'existing', 'missing', 'init-failure'):
            m,c=cpu_fixture(binary);linked=[];initialized=[];unlinked=[];sent=[]
            m.write_word(sy['D.Proc'],0xa00)
            if level==2:m.write_word(sy['D.SysPrc'],0xc00)
            m.write_word(sy['D.DWSubAddr'],0x3100 if scenario=='existing' else 0)
            c.index_x.set(0x800);c.index_y.set(0x900);c.user_stack_pointer.set(0xa80)
            def ret():
                sp=c.system_stack_pointer.value;c.program_counter.set(m.read_word(sp));c.system_stack_pointer.set(sp+2)
            def hook():
                pc=c.program_counter.value
                if pc==0x3100:
                    assert c.user_stack_pointer.value==0xa80 and c.index_y.value==0x900
                    assert m.read_word(sy['D.Proc'])==0xa00
                    initialized.append(True)
                    c.accu_b.set(207 if scenario=='init-failure' else 0)
                    c.C=int(scenario=='init-failure');ret();return True
                if pc==0x3106:
                    sent.append(bytes(m.read_byte(c.index_x.value+i) for i in range(c.index_y.value)))
                    ret();return True
                if m.read_byte(pc)==0x10 and m.read_byte(pc+1)==0x3f:
                    op=m.read_byte(pc+2)
                    if op==sy['F$Link']:
                        assert m.read_word(sy['D.Proc'])==(0xc00 if level==2 else 0xa00)
                        linked.append(True);c.user_stack_pointer.set(0x3000);c.index_y.set(0x3100)
                        c.accu_b.set(221 if scenario=='missing' else 0);c.C=int(scenario=='missing')
                    elif op==sy['F$UnLink']:
                        assert c.user_stack_pointer.value==0x3000
                        unlinked.append(True);c.accu_b.set(0);c.C=0
                    else:raise AssertionError(op)
                    c.program_counter.set(pc+3);return True
                return False
            c.program_counter.set(BASE+sy['Init']);run_until_return(c,hook)
            assert (c.index_x.value,c.index_y.value,c.user_stack_pointer.value)==(0x800,0x900,0xa80)
            assert m.read_word(sy['D.Proc'])==0xa00
            assert len(linked)==int(scenario!='existing')
            assert len(initialized)==int(scenario in ('first','init-failure'))
            assert len(unlinked)==int(scenario=='init-failure')
            assert sent==([b'I'] if scenario=='first' else [])
            assert m.read_word(sy['D.DWSubAddr'])==(0x3100 if scenario in ('first','existing') else 0)
            assert (c.C,c.accu_b.value)==((1,221) if scenario=='missing' else (1,207) if scenario=='init-failure' else (0,0))
        print(f'Level {level}: RFM-first DWIO initialization, existing transport, missing module and failure cleanup PASS')

with tempfile.TemporaryDirectory(prefix='rfm-test-') as d:
    for level in (1,2):
        binary,syms=assemble(Path(d),level);tests(binary,syms,level)
    transport_tests(Path(d))
    boot_tests(Path(d))
    driver_tests(Path(d))
