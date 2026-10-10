"""Execute the piano definition stream and final MIDI-output highlighter hook."""
import re
from pathlib import Path

from test_midi_import import CPU, Memory, TestCfg, BaseCPUTestCase, ROOT


def load_module(name):
    cfg = TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT)
    cpu = CPU(Memory(cfg), cfg)
    cfg.ROM_START = 0x10000
    mem = cpu.memory
    mem.load(0x2000, (ROOT / f".mods/CMDS/{name}").read_bytes())
    text = (ROOT / f".mods/{name}_piano.sym").read_text()
    symbols = {key.lower(): int(value, 16) + 0x2000 for key, value in re.findall(
        r"^(\w+) EQU \$([0-9A-F]+)", text, re.M)}
    return cpu, mem, symbols


# s9c 'k' must define all 88 keys using complete 15-byte Fran commands.
cpu, mem, sym = load_module("s9c")
mem.write_word(0x0383, 0x1900)  # putchar
mem.write_word(0x0379, 0x1910)  # flush
cpu.system_stack_pointer.set(0x1f00)
mem.write_word(0x1f00, 0x1800)
mem.write_word(0x1f02, ord("k"))
cpu.user_stack_pointer.set(0x4567)
cpu.program_counter.set(sym["start"])
definition = []
flushes = 0
for _ in range(2_000_000):
    pc = cpu.program_counter.value
    if pc == 0x1800:
        break
    if pc == 0x1900:
        stack = cpu.system_stack_pointer.value
        definition.append(mem.read_byte(stack + 3))
        cpu.program_counter.set(cpu.pull_word(cpu.system_stack_pointer))
    elif pc == 0x1910:
        flushes += 1
        cpu.program_counter.set(cpu.pull_word(cpu.system_stack_pointer))
    else:
        cpu.get_and_call_next_op()
else:
    raise AssertionError("s9c piano definition did not return")
assert len(definition) == 88 * 15
records = [definition[i:i + 15] for i in range(0, len(definition), 15)]
assert all(row[0:2] == [0xC5, 0] and row[6:] == [0] * 9 for row in records)
assert [row[2] for row in records] == list(range(21, 109))
assert flushes == 1
assert cpu.system_stack_pointer.value == 0x1f02
assert cpu.user_stack_pointer.value == 0x4567


# The final output hook must preserve running status and emit highlight/restore commands.
cpu, mem, sym = load_module("s9")
mem.write_byte(0x10FE, 0)
mem.write_byte(0x10FF, 0xFF)
emitted = []
flushes = 0


def send(value):
    global flushes
    cpu.system_stack_pointer.set(0x1f00)
    mem.write_word(0x1f00, 0x1800)
    mem.write_word(0x1f02, value)
    cpu.accu_d.set(0xA500 | value)
    cpu.index_x.set(0x3456)
    cpu.index_y.set(0x5678)
    cpu.user_stack_pointer.set(0x789A)
    cpu.program_counter.set(sym["pianohook"])
    start = len(emitted)
    for _ in range(20_000):
        pc = cpu.program_counter.value
        if pc == sym["midisendselected"]:
            break
        if pc == sym["phput"]:
            emitted.append(cpu.accu_d.value & 0xFF)
            cpu.program_counter.set(cpu.pull_word(cpu.system_stack_pointer))
        elif pc == sym["fflush"]:
            flushes += 1
            cpu.program_counter.set(cpu.pull_word(cpu.system_stack_pointer))
        else:
            cpu.get_and_call_next_op()
    else:
        raise AssertionError(f"PianoHook did not delegate after MIDI ${value:02X}")
    assert cpu.system_stack_pointer.value == 0x1f00
    assert mem.read_word(0x1f02) == value
    assert (cpu.accu_d.value, cpu.index_x.value, cpu.index_y.value,
            cpu.user_stack_pointer.value) == (0xA500 | value, 0x3456, 0x5678, 0x789A)
    return emitted[start:]


assert send(0x90) == []
assert send(60) == []
actual = send(100)
assert actual == [0xC5, 1, 60, 1] + [0] * 11, actual
assert send(61) == []                 # running status
assert send(0) == [0xC5, 1, 61, 0] + [0] * 11
assert send(0x80) == []
assert send(60) == []
assert send(64) == [0xC5, 1, 60, 0] + [0] * 11
assert send(0xB0) == []
assert send(123) == []
assert send(0) == [0xC5, 2] + [0] * 13
assert send(0xFC) == [0xC5, 2] + [0] * 13
assert flushes == 5
print("PASS: 88 key definitions; Note On, velocity-zero, Note Off, running status and silence commands")
