"""Execute s9r initialization, checking every SCI word and success/error ABI."""
from pathlib import Path
import re
from test_midi_import import CPU, Memory, TestCfg, BaseCPUTestCase, ROOT

syms={k.lower():int(v,16) for k,v in re.findall(r'^(\w+) EQU \$([0-9A-F]+)',(ROOT/'.mods/Um3R_new.sym').read_text(),re.M)}
binary=(ROOT/'.mods/CMDS/s9r').read_bytes()
plugin=binary[syms['vsplugin']:syms['vsplugin_end']]
words=[int.from_bytes(plugin[i:i+2],'big') for i in range(0,len(plugin),2)]
expected=[];i=0
while i<len(words):
    reg,n=words[i:i+2];i+=2
    if n&0x8000:
        expected.extend([(reg,words[i])]*(n&0x7fff));i+=1
    else:
        expected.extend((reg,v) for v in words[i:i+n]);i+=n
assert i==len(words) and expected[-1]==(10,0x50)
expected=[(1,0x40),(11,0),(3,0xc000)]+expected+[(11,0)]

for fail_at in (None,1,15,len(expected)):
    cfg=TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT);cpu=CPU(Memory(cfg),cfg);cfg.ROM_START=0x10000
    m=cpu.memory;m.load(0x4000,binary)
    cpu.system_stack_pointer.set(0x1f00);m.write_word(0x1f00,0x1800)
    cpu.accu_d.set(0x5678);cpu.index_x.set(0x1234);cpu.index_y.set(0);cpu.user_stack_pointer.set(0x2468)
    cpu.program_counter.set(0x4000+syms['vssynthstart'])
    m.write_byte(0x105d,1);m.write_word(0x37b,0x1900)
    sci=[];controls=[];sleeps=[];polls=[0];alerts=[]
    def control(c,pc,a,v):
        controls.append(v)
        if v&1:
            sci.append((m.read_byte(0xff51),m.read_word(0xff52)));polls[0]=0
        return v
    def status(c,pc,a):
        polls[0]+=1
        return 0x80 if len(sci)==fail_at or polls[0]<3 else 0
    m._write_byte_middleware[0xff50]=control;m._read_byte_callbacks[0xff50]=status
    for step in range(800000):
        pc=cpu.program_counter.value
        if pc==0x1800: break
        if pc==0x1900:
            s=cpu.system_stack_pointer.value
            assert m.read_word(s+4)==0 and cpu.index_y.value==0
            p=m.read_word(s+2);msg=[]
            while m.read_byte(p): msg.append(m.read_byte(p));p+=1
            alerts.append(bytes(msg))
            cpu.program_counter.set(cpu.pull_word(cpu.system_stack_pointer))
        elif m.read_byte(pc)==0x10 and m.read_byte(pc+1)==0x3f:
            assert m.read_byte(pc+2)==0x0a
            sleeps.append(cpu.index_x.value);cpu.program_counter.set(pc+3);cpu.C=0
        else: cpu.get_and_call_next_op()
    else: raise AssertionError(('init did not return',fail_at,hex(pc)))
    assert controls[:2]==[8,0],controls[:2]
    assert sci==expected[:fail_at] if fail_at else sci==expected
    assert cpu.system_stack_pointer.value==0x1f02
    assert (cpu.accu_d.value,cpu.index_x.value,cpu.index_y.value,cpu.user_stack_pointer.value)==(0x5678,0x1234,0,0x2468)
    assert bool(alerts)==bool(fail_at) and m.read_byte(0x105d)==int(fail_at is None)
    if not fail_at: assert sleeps==[1,3,6,3],sleeps
print('PASS VS initialization: exact plugin SCI stream, clock, reset, FIFO flush, bounded early/mid/late failures and D/X/Y/U/S.')
