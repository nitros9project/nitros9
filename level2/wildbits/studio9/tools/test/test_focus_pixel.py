"""Exhaustively execute s9gui's packed-pixel highlighting and check its ABI."""
from test_midi_import import CPU, Memory, TestCfg, BaseCPUTestCase, ROOT
import re

cfg = TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT)
cpu = CPU(Memory(cfg), cfg)
cfg.ROM_START = 0x10000
mem = cpu.memory
mem.load(0x4000, (ROOT/'.mods/CMDS/s9gui').read_bytes())
syms = {k.lower(): int(v, 16) for k, v in re.findall(
    r'^(\w+) EQU \$([0-9A-F]+)', (ROOT/'.mods/s9gui_focus.sym').read_text(), re.M)}
for under in (0, 1):
 for focus in (0, 1):
    for opaque in (0, 1):
        for packed in range(256):
            mem.write_byte(syms['frunder'], under)
            mem.write_byte(syms['frfocusink'], focus)
            mem.write_byte(syms['fropaque'], opaque)
            cpu.accu_a.set(packed)
            cpu.accu_b.set(0xA5)
            cpu.index_x.set(0x1234)
            cpu.index_y.set(0x5678)
            cpu.user_stack_pointer.set(0x2345)
            cpu.system_stack_pointer.set(0x1F00)
            mem.write_word(0x1F00, 0x3000)
            cpu.program_counter.set(0x4000 + syms['focuspixel'])
            for _ in range(80):
                if cpu.program_counter.value == 0x3000:
                    break
                cpu.get_and_call_next_op()
            def pixel(n):
                if under: return n
                if focus and n > 9:  # palette 9 is the red 128th-note marker
                    n -= 9
                return 1 if opaque and n == 0 else n
            expected = pixel(packed >> 4)*16 + pixel(packed & 15)
            assert cpu.accu_a.value == expected, (focus, opaque, packed, cpu.accu_a.value)
            assert cpu.accu_b.value == 0xA5
            assert cpu.index_x.value == 0x1234 and cpu.index_y.value == 0x5678
            assert cpu.user_stack_pointer.value == 0x2345
            assert cpu.system_stack_pointer.value == 0x1F02
            assert cpu.program_counter.value == 0x3000
print('PASS FocusPixel: all 2048 packed-pixel/focus/opacity combinations; B/X/Y/U/S preserved')

# Real one-bit ledger expansion: chrome cannot turn it white, and the
# sheet's dotted-line option must apply to both halves of every strip byte.
for dots in (0,1):
    for chrome in (0,1):
        for packed in range(256):
            mem.write_byte(syms['frunder'],1)
            mem.write_byte(syms['frstaffdots'],dots)
            mem.write_byte(syms['frchrome'],chrome)
            cpu.accu_b.set(packed)
            cpu.system_stack_pointer.set(0x1f00)
            mem.write_word(0x1f00,0x3000)
            cpu.program_counter.set(0x4000+syms['expbspr'])
            for _ in range(80):
                if cpu.program_counter.value==0x3000: break
                cpu.get_and_call_next_op()
            pattern=packed & (0xaa if dots else 0xff)
            expected=0
            for bit in range(7,-1,-1): expected=(expected<<4)|(syms['staffink'] if pattern&(1<<bit) else 0)
            assert (cpu.accu_d.value<<16)|cpu.index_x.value==expected,(dots,chrome,packed)
            assert cpu.system_stack_pointer.value==0x1f02
print('PASS ledger strips: 1024 pattern/dotted/chrome combinations; stack balanced')
