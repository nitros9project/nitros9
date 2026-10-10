"""Execute actual post-load view reset and cursor remapping on a 6809."""
import re
from test_midi_import import CPU,Memory,TestCfg,BaseCPUTestCase,ROOT

def setup(module,suffix):
    sy={k:int(v,16)+0x4000 for k,v in re.findall(r'^(\w+) EQU \$([0-9A-F]+)',(ROOT/f'.mods/{module}_{suffix}.sym').read_text(),re.M)}
    cfg=TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT);c=CPU(Memory(cfg),cfg);cfg.ROM_START=0x10000
    c.memory.load(0x4000,(ROOT/'.mods/CMDS'/module).read_bytes()[:0xa000])
    c.index_y.set(0);c.user_stack_pointer.set(0x3456)
    return c,sy

def execute(c):
    for _ in range(1000):
        if c.program_counter.value==0x3f00:return
        c.get_and_call_next_op()
    raise AssertionError('did not return')

def test():
    for write,kind in [(0,'u'),(1,'u'),(0,'i'),(0,'p')]:
        c,sy=setup('s9d','browser');m=c.memory;s=0x1e42
        for addr in range(0x85,0x91,2):m.write_word(addr,12000)
        m.write_byte(s+0xc5,write);m.write_byte(s+0xc7,ord(kind))
        m.write_word(s+0xbc,0x3456);m.write_word(s+0xbe,0x3f00)
        c.system_stack_pointer.set(s);c.program_counter.set(sy['MainReturnOne']);execute(c)
        want=0 if not write and kind=='u' else 12000
        assert all(m.read_word(a)==want for a in range(0x85,0x91,2))
        assert (c.accu_d.value,c.system_stack_pointer.value,c.index_y.value,c.user_stack_pointer.value)==(1,0x1f02,0,0x3456)
        if want==0:assert m.read_byte(0x7c)==1 and m.read_byte(0x7f)==1
    c,sy=setup('s9','view');m=c.memory
    m.write_word(0x2b,927);m.write_word(0x23,0xaaaa);m.write_word(0x25,0x2000);m.write_word(0x2f,1)
    m.write_word(0x3000,0x3456);m.write_word(0x3002,0x3f00)
    c.system_stack_pointer.set(0x3000);c.program_counter.set(sy['ResetScoreCursor']);execute(c)
    assert m.read_word(0x2b)==0 and m.read_word(0x23)==0x2000
    assert (c.system_stack_pointer.value,c.index_y.value,c.user_stack_pointer.value)==(0x3004,0,0x3456)
    print('PASS score reads reset six view indices; saves/other files preserve view; actual i2p restores event-zero pointer; stack/Y/U preserved')
if __name__=='__main__':test()
