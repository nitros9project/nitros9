"""Execute MIDrv IRQ capture and Fran's indicator using assembled 6809 code."""
import re
from collections import deque
from test_midi_import import CPU, Memory, TestCfg, BaseCPUTestCase, ROOT

def symbols(name):
    return {k:int(v,16) for k,v in re.findall(r'^([^ ]+) EQU \$([0-9A-F]+)',
        (ROOT/f'.mods/{name}_input.sym').read_text(),re.M)}

class Rig:
    def __init__(self,name,base):
        self.s=symbols(name); self.base=base
        cfg=TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT)
        self.c=CPU(Memory(cfg),cfg); cfg.ROM_START=0x10000
        self.m=self.c.memory; self.m.load(base,(ROOT/f'.mods/CMDS/{name}').read_bytes())
    def call(self,name,u=0x1500,y=0x1700,hook=None):
        c,m=self.c,self.m
        c.system_stack_pointer.set(0x1f00);m.write_word(0x1f00,0x1900)
        c.user_stack_pointer.set(u);c.index_y.set(y)
        c.program_counter.set(self.base+self.s[name])
        for _ in range(250000):
            pc=c.program_counter.value
            if pc==0x1900: break
            if hook and hook(pc):continue
            c.get_and_call_next_op()
        else:raise AssertionError((name,hex(c.program_counter.value)))
        assert c.system_stack_pointer.value==0x1f02,(name,hex(c.system_stack_pointer.value))

def capture():
    r=Rig('MIDrv',0xc000);c,m,s=r.c,r.m,r.s;u=0x1500;fifo=deque();reads=[]
    m.write_word(u+s['Ring'],0x4000)
    m._read_byte_callbacks[s['MIDI.Base']]=lambda *args:4 if not fifo else 0
    def pop(*args):
        b=fifo.popleft();reads.append(b);return b
    m._read_byte_callbacks[s['MIDI.Base']+1]=pop
    m.write_byte(s['D.Sec'],10);m.write_byte(s['D.Tick'],60)
    # Multiple bursts wrap the 2K ring; every received value survives in order.
    for burst in range(9):
        data=bytes((i+burst)&255 for i in range(513));fifo.extend(data);r.call('Service')
        assert not fifo and m.read_word(u+s['Count'])==513
        got=[]
        for _ in data:
            r.call('Read');assert not c.C;got.append(c.accu_a.value)
        assert bytes(got)==data and m.read_word(u+s['Count'])==0
    r.call('Read');assert c.C and c.accu_b.value==s['E$NotRdy']
    fifo.extend(range(256));fifo.extend([0x90]*1856);r.call('Service')
    assert m.read_word(u+s['Count'])==2048 and m.read_word(u+s['Lost'])==64
    assert len(reads)==9*513+2112 and not fifo
    # Activity expires after six ticks and stays erased, including minute rollover.
    m.write_word(0x1700+s['PD.RGS'],0x1800)
    def activity(sec,tick):
        m.write_byte(s['D.Sec'],sec);m.write_byte(s['D.Tick'],tick)
        c.accu_a.set(0xd6);r.call('GetStat');assert not c.C
        return m.read_byte(0x1800+s['R$B'])
    assert activity(10,55)==1 and activity(10,54)==0
    assert activity(11,59)==0
    m.write_byte(u+s['Active'],1);m.write_byte(u+s['LastSec'],59);m.write_byte(u+s['LastTick'],2)
    assert activity(0,59)==1 and activity(0,56)==0
    # The application byte API returns a queued byte without touching the hardware.
    before=len(reads);c.accu_a.set(0xd7);r.call('GetStat')
    assert not c.C and m.read_byte(0x1800+s['R$B'])==0 and len(reads)==before
    print('PASS actual MIDrv: 6729 captured bytes; ring wrap, full-ring overflow, queue API, activity expiry/minute rollover; balanced stacks')

def indicator():
    r=Rig('s9gui',0x2000);c,m,s=r.c,r.m,r.s
    m.load(0x099f,(ROOT/'.mods/SYS/Chars16.img').read_bytes())
    m.load(s['FrDriveText'],bytes([76,32,68,68,0])+bytes(25))
    m.write_byte(s['FrMidiPath'],4);m.write_byte(s['FrMidiShown'],0xff)
    m.write_byte(s['FrBM0'],1);m.write_byte(s['FrBMShown'],2)
    active=[1];positions=[]
    def hook(pc):
        if pc==0x2000+s['ScrPos']:
            assert c.index_x.value==75 and c.accu_d.value==190
            positions.append(c.index_x.value)
            c.user_stack_pointer.set(0x8000 if m.read_byte(s['FrBM0'])==1 else 0xa000)
            c.program_counter.set(c.pull_word(c.system_stack_pointer));return True
        if m.read_byte(pc)==0x10 and m.read_byte(pc+1)==0x3f:
            assert m.read_byte(pc+2)==s['I$GetStt'] and c.accu_b.value==s['SS.MidiActivity']
            c.accu_b.set(active[0]);c.C=0;c.program_counter.set(pc+3);return True
        return False
    for value in (1,0):
        active[0]=value;r.call('MidiIndicator',hook=hook)
        glyph=ord('I') if value else 32
        expected=(ROOT/'.mods/SYS/Chars16.img').read_bytes()[(glyph-32)*24:(glyph-31)*24]
        expected=bytes(b^255 for b in expected)
        for base in (0x8000,0xa000):
            got=bytes(m.read_byte(base+row*320+i) for row in range(6) for i in range(4))
            assert got==expected
        assert m.read_byte(s['FrBM0'])==1 and m.read_byte(s['FrBMShown'])==2
    r.call('MidiIndicator',hook=hook);assert len(positions)==4
    print('PASS actual Fran indicator: I/space at one space before DD, both pages, no repeated redraw, balanced stacks')

if __name__=='__main__':capture();indicator()
