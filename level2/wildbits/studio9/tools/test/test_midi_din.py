"""Execute DIN fanout and the SAM analog switch, including backpressure and ABI."""
import re
from test_midi_import import CPU, Memory, TestCfg, BaseCPUTestCase, ROOT

def setup(name, entry):
    cfg = TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT)
    cpu = CPU(Memory(cfg), cfg)
    cfg.ROM_START = 0x10000
    m = cpu.memory
    m.load(0x2000, (ROOT / f'.mods/CMDS/{name}').read_bytes())
    symbols = {k.lower(): int(v, 16) + 0x2000 for k, v in re.findall(
        r'^(\w+) EQU \$([0-9A-F]+)', (ROOT / f'.mods/{name}_new.sym').read_text(), re.M)}
    cpu.system_stack_pointer.set(0x1f00)
    m.write_word(0x1f00, 0x1800)
    cpu.index_x.set(0x1234)
    cpu.index_y.set(0x4567)
    cpu.user_stack_pointer.set(0x789a)
    cpu.program_counter.set(symbols[entry.lower()])
    return cpu, m

def finish(cpu, d):
    assert (cpu.accu_d.value, cpu.index_x.value, cpu.index_y.value,
            cpu.user_stack_pointer.value, cpu.system_stack_pointer.value) == (
                d, 0x1234, 0x4567, 0x789a, 0x1f02)

for sam, vs in ((0, 0), (1, 0), (0, 1)):
    for value in range(256):
        cpu, m = setup('s9', 'MidiSynthSend')
        cpu.accu_d.set(0xa500 | value)
        m.write_byte(0x3c, sam)
        m.write_byte(0x105d, vs)
        writes, counts = [], {0xff30: 0, 0xff54: 0}
        def status(c, pc, addr):
            counts[addr] += 1
            ready = counts[addr] % 3 == 0
            return (8 if ready else 0) if addr == 0xff30 else (0 if ready else 0x40)
        def out(c, pc, addr, value):
            writes.append((addr, value))
            return value
        for addr in counts:
            m._read_byte_callbacks[addr] = status
        for addr in (0xff31, 0xff57):
            m._write_byte_middleware[addr] = out
        for _ in range(300):
            if cpu.program_counter.value == 0x1800:
                break
            cpu.get_and_call_next_op()
        else:
            raise AssertionError('fanout did not return')
        assert writes == [(0xff31, value)] + ([(0xff57, 0), (0xff57, value)] if vs else [])
        assert counts == {0xff30: 3, 0xff54: 6 if vs else 0}
        finish(cpu, 0xa500 | value)

for sam, stuck in ((0, False), (1, False), (0, True)):
    cpu, m = setup('s9r', 'SamAudioMix')
    cpu.accu_d.set(0x4567)
    m.write_byte(0x3c, sam)
    m.write_word(0x37b, 0x1900)
    writes, alerts, reads = [], [], [0]
    def busy(c, pc, addr):
        reads[0] += 1
        return int(stuck or reads[0] < 4)
    def codec(c, pc, addr, value):
        writes.append((addr, value))
        return value
    m._read_byte_callbacks[0xfe72] = busy
    for addr in (0xfe70, 0xfe71, 0xfe72):
        m._write_byte_middleware[addr] = codec
    for _ in range(400000):
        pc = cpu.program_counter.value
        if pc == 0x1800:
            break
        if pc == 0x1900:
            s = cpu.system_stack_pointer.value
            assert m.read_word(s+4) == 0 and cpu.index_y.value == 0x4567
            assert m.read_byte(m.read_word(s+2)) == ord('C')
            alerts.append(True)
            cpu.program_counter.set(cpu.pull_word(cpu.system_stack_pointer))
        else:
            cpu.get_and_call_next_op()
    else:
        raise AssertionError('codec switch did not return')
    assert writes == ([] if stuck else [(0xfe71, 0x2a), (0xfe70, 0x1f if sam else 0x1c), (0xfe72, 1)])
    assert bool(alerts) == stuck
    finish(cpu, 0x4567)

symbols = {k.lower(): int(v, 16) + 0x2000 for k, v in re.findall(
    r'^(\w+) EQU \$([0-9A-F]+)', (ROOT / '.mods/Um3M_new.sym').read_text(), re.M)}
for key, initial, expected in (
        ('ToggleWildbitsOut', (1, 0), (0, 0)),
        ('ToggleWildbitsOut', (0, 1), (1, 0)),
        ('ToggleVs1053Out', (1, 0), (0, 1)),
        ('ToggleVs1053Out', (0, 1), (0, 0))):
    cpu, m = setup('s9m', key)
    m.write_byte(0x3c, initial[0])
    m.write_byte(0x105d, initial[1])
    m.write_word(0x363, 0x1900)
    calls = []
    for _ in range(1000):
        pc = cpu.program_counter.value
        if pc == symbols['settingsloopend']:
            break
        if pc == 0x1900:
            s = cpu.system_stack_pointer.value
            assert m.read_word(s+2) == ord('R')
            calls.append(chr(m.read_word(s+4)))
            assert cpu.index_y.value == 0x4567
            cpu.program_counter.set(cpu.pull_word(cpu.system_stack_pointer))
        else:
            cpu.get_and_call_next_op()
    else:
        raise AssertionError('menu switch did not finish')
    assert calls == (['v', 'c'] if key == 'ToggleVs1053Out' and expected[1] else ['c'])
    assert (m.read_byte(0x3c), m.read_byte(0x105d)) == expected
    assert cpu.system_stack_pointer.value == 0x1f00
    assert (cpu.index_y.value, cpu.user_stack_pointer.value) == (0x4567, 0x789a)

print('PASS: all256 bytes to DIN with SAM on/off and VS on; FIFO waits, codec mute/unmute/timeout, menu exclusivity/call frames and D/X/Y/U/S preserved')
