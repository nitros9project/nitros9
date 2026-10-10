"""Execute MidiSettings through repeated redraws; check its C varargs and stack."""
import re
from test_midi_import import CPU, Memory, TestCfg, BaseCPUTestCase, ROOT

def test():
    cfg = TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT)
    cpu = CPU(Memory(cfg), cfg)
    cfg.ROM_START = 0x10000
    mem = cpu.memory
    mem.load(0x4000, (ROOT / '.mods/CMDS/s9m').read_bytes())
    symbols = {k: int(v, 16)+0x4000 for k,v in re.findall(
        r'^(\w+) EQU \$([0-9A-F]+)', (ROOT / '.mods/Um3M_modes.sym').read_text(), re.M)}
    mem.write_word(0x035f, 0x3000)
    mem.write_word(0x1103, 0x3010)
    mem.write_word(0x74, 7)
    mem.write_word(0x1f00, 0x3100)
    cpu.system_stack_pointer.set(0x1f00)
    cpu.user_stack_pointer.set(0x1234)
    cpu.index_y.set(0x2345)
    cpu.program_counter.set(symbols['MidiSettings'])
    draws = calls = 0
    def ret(value=0):
        cpu.accu_d.set(value)
        cpu.program_counter.set(cpu.pull_word(cpu.system_stack_pointer))
    for _ in range(100000):
        pc = cpu.program_counter.value
        s = cpu.system_stack_pointer.value
        if pc == 0x3100:
            assert (s, cpu.user_stack_pointer.value, cpu.index_y.value) == (0x1f02, 0x1234, 0x2345)
            assert draws == 65 and calls == 130
            print('PASS: 65 redraws, both sprintf argument frames, saved window and S/U/Y return preserved')
            return
        if pc == 0x3000:
            assert s == 0x1ee7, hex(s)  # frame $1efb - 18 argument bytes - return
            dest, fmt = mem.read_word(s+2), mem.read_word(s+4)
            if calls % 2 == 0:
                assert dest == 0x1105 and fmt == symbols['fmtSevenFlags']
                raw = bytes(mem.read_byte(fmt+i) for i in range(15))
                assert raw == b'%d%d%d%d%d%d%d\0'
            else:
                assert dest == 0x110c and fmt == symbols['fmtSettingsVals']
            calls += 1
            ret()
        elif pc == 0x3010:
            assert s == 0x1ef5, hex(s)
            assert mem.read_word(s+2) == symbols['descMidiModes']
            assert mem.read_word(s+4) == 0x1105
            draws += 1
            ret(ord('i') if draws <= 64 else 13)
        elif pc == symbols['SelectWindow']:
            assert mem.read_word(s+2) == (2 if draws == 0 else 7)
            ret()
        elif pc == symbols['FlushDisplay']:
            ret()
        else:
            cpu.get_and_call_next_op()
    raise AssertionError('instruction limit')

if __name__ == '__main__':
    test()
