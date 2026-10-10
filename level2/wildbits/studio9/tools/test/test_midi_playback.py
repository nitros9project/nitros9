"""Exercise real playback instructions for notation-only notes and raw stop."""
import re
from test_midi_import import CPU, Memory, TestCfg, BaseCPUTestCase, ROOT


def test():
    syms = {k: int(v, 16)+0x4000 for k, v in re.findall(
        r'^(\w+) EQU \$([0-9A-F]+)', (ROOT/'.mods/Um3P_import.sym').read_text(), re.M)}
    for raw, filing in [(1, 0), (0, 0), (1, 1)]:
        cfg = TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT)
        c = CPU(Memory(cfg), cfg); cfg.ROM_START = 0x10000
        m = c.memory; m.load(0x4000, (ROOT/'.mods/CMDS/s9p').read_bytes())
        m.write_byte(0x44, raw); m.write_byte(0x84, filing)
        m.write_word(0x381, 0x3200); m.write_word(0x1f00, 0x3100)
        c.system_stack_pointer.set(0x1f00); c.program_counter.set(syms['StopRawNotes'])
        sent = []; flushes = 0
        for _ in range(4000):
            pc = c.program_counter.value
            if pc == 0x3100: break
            if pc == syms['PutMidiByte']:
                sent.append(m.read_word(c.system_stack_pointer.value+2))
                c.program_counter.set(c.pull_word(c.system_stack_pointer))
            elif pc == 0x3200:
                flushes += 1
                c.program_counter.set(c.pull_word(c.system_stack_pointer))
            else: c.get_and_call_next_op()
        else: raise AssertionError('stop did not return')
        expected = [v for ch in range(16) for v in (0xb0+ch, 120, 0)] if raw and not filing else []
        assert sent == expected and flushes == bool(expected), (sent, flushes)
        assert c.system_stack_pointer.value == 0x1f02
        for marker in (0x82, 2):
            c.user_stack_pointer.set(0x3000); m.write_byte(0x3007, marker)
            c.program_counter.set(syms['NoteEvent'])
            for _ in range(3): c.get_and_call_next_op()
            assert (c.program_counter.value == syms['FetchNextEvent']) == (marker == 0x82)
        m.write_byte(0x44, 0); m.write_byte(0x84, 0); m.write_byte(0x3f3, 0)
        m.load(0x3000, bytes([0,0,0,0x90,60,0x1e,0x40,0x80|100]))
        c.user_stack_pointer.set(0x3000); c.program_counter.set(syms['EvRawMidi'])
        sent=[]
        for _ in range(1000):
            pc=c.program_counter.value
            if pc==syms['EvDone']: break
            if pc==syms['PutMidiByte']:
                sent.append(m.read_word(c.system_stack_pointer.value+2)&255)
                c.program_counter.set(c.pull_word(c.system_stack_pointer))
            else: c.get_and_call_next_op()
        else: raise AssertionError('raw event did not finish')
        assert sent==[0x90,60,100] and m.read_byte(0x44)==1,sent
    for bpm,tag in [(120,b'\0\0'),(255,b'\0\0'),(320,b'LY'),(4800,b'LY')]:
        cfg=TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT)
        c=CPU(Memory(cfg),cfg); cfg.ROM_START=0x10000; m=c.memory
        m.load(0x4000,(ROOT/'.mods/CMDS/s9p').read_bytes())
        m.load(0x3000,bytes([0,0,0,bpm&255,bpm>>8,0x19])+tag)
        m.write_word(0xaa,0xffff)
        c.user_stack_pointer.set(0x3000);c.system_stack_pointer.set(0x1f00)
        c.program_counter.set(syms['EvTempo'])
        for _ in range(20):
            c.get_and_call_next_op()
            if m.read_word(0xaa)!=0xffff:break
        assert m.read_word(0xaa)==bpm,(bpm,m.read_word(0xaa))
        assert c.system_stack_pointer.value==0x1f00
        m.write_word(0xae,1200);m.write_word(5,4);m.write_byte(0x7b,0)
        m.write_word(0x1f00,0x3100);c.program_counter.set(syms['CalcTickScale'])
        for _ in range(10000):
            if c.program_counter.value==0x3100:break
            c.get_and_call_next_op()
        else:raise AssertionError('tick scale did not return')
        assert m.read_word(0xac)==4800//bpm,(bpm,m.read_word(0xac))
        assert c.system_stack_pointer.value==0x1f02 and c.user_stack_pointer.value==0x3000
    print('PASS: imported notation/raw playback; legacy and wide Lyra tempos (320/4800 BPM) preserve full value, tick scale and stack')


if __name__ == '__main__': test()
