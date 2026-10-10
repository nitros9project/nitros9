"""CPU check of s9c 'k': may the palette note go on the clicked rest, and the bonk when it may not.
Assembles cmds/s9c.asm itself (lwasm on PATH) so it runs before or after a build."""
import re, subprocess, tempfile
from pathlib import Path
from test_midi_import import CPU, Memory, TestCfg, BaseCPUTestCase, ROOT

FLAGS = ['--no-warn=ifp1', '--6309', '--format=os9',
         '--pragma=pcaspcr,nosymbolcase,condundefzero,undefextern,dollarnotlocal,noforwardrefmax',
         '--includedir=../../../defs', '-I..', '-Dwildbits=1', '-DNOS9VER=3', '-DNOS9MAJ=3', '-DNOS9MIN=0']
RAW = [384, 576, 672, 256]           # cod2raw: a whole note by modifier, shifted right by the duration code


def build():
    tmp = Path(tempfile.mkdtemp())
    subprocess.run(['lwasm', *FLAGS, f'--symbol-dump={tmp / "s9c.sym"}', f'--output={tmp / "s9c"}', 'cmds/s9c.asm'],
                   cwd=ROOT, check=True)
    sy = {k: int(v, 16) for k, v in re.findall(r'^([^ ]+) EQU \$([0-9A-F]+)', (tmp / 's9c.sym').read_text(), re.M)}
    return (tmp / 's9c').read_bytes(), sy


def ev(part, tick, dur, mod, slot, artic=2):
    return bytes([part, tick >> 8, tick & 255, dur, mod, slot & 255, 1, artic])


BAR = bytes([0, 0, 0, 0, 0, 0, 0, 0])
# index: 0 bar | 1 note | 2 REST | 3 note | 4 REST | 5 bar | 6 REST | 7 other part's note | 8 REST | 9 tempo mark | 10 REST
SCORE = [BAR, ev(4, 0, 3, 0, 1), ev(4, 48, 3, 0, 32), ev(4, 96, 3, 0, 2), ev(4, 144, 3, 0, 32), BAR,
         ev(4, 192, 3, 0, 32), ev(1, 192, 3, 0, 5), ev(4, 240, 3, 0, 32), bytes([0, 1, 32, 0, 0, 0x19, 0, 0]),
         ev(4, 288, 4, 0, 32)]
BONK = [0x9F, 40, 100, 40, 0, 33, 100, 33, 0]


def run(module, sy, index, brush):
    cfg = TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT); c = CPU(Memory(cfg), cfg); cfg.ROM_START = 0x10000; m = c.memory
    m.load(0x4000, module)
    for i, e in enumerate(SCORE): m.load(0xE000 + 8 * i, e)
    m.load(sy['UmeData_brush'], bytes(brush))
    m.write_word(sy['pMidiEventPtr'], 0x3200); m.write_word(sy['vCod2raw'], 0x3220); m.write_word(sy['pMidiSend'], 0x3240)
    m.write_word(sy['vEvents'], len(SCORE))
    m.write_byte(sy['UmeData_runstat'], 0x90); m.write_byte(sy['UmeData_reserved_00CE'], 0x90)
    m.write_word(0x1F00, 0x3100); m.write_word(0x1F02, ord('k')); m.write_word(0x1F04, index)
    c.system_stack_pointer.set(0x1F00); c.index_y.set(0x1357); c.user_stack_pointer.set(0x1234)
    c.program_counter.set(0x4000 + sy['start'])
    sent, sleeps, asked = [], [], []
    for _ in range(20000):
        pc = c.program_counter.value; sp = c.system_stack_pointer.value
        if pc == 0x3100: break
        d = None
        if pc == 0x3200:
            i = m.read_word(sp + 2); asked.append(i); d = 0xE000 + 8 * i if i < len(SCORE) else 0
        elif pc == 0x3220:
            d = RAW[m.read_word(sp + 4) & 255] >> (m.read_word(sp + 2) & 255)
        elif pc == 0x3240:
            sent.append(m.read_word(sp + 2) & 255); d = c.accu_d.value
        if d is not None:
            c.accu_d.set(d); c.program_counter.set(c.pull_word(c.system_stack_pointer)); continue
        if m.read_byte(pc) == 0x10 and m.read_byte(pc + 1) == 0x3F:      # os9 F$Sleep: X = ticks
            sleeps.append(c.index_x.value); c.program_counter.set(pc + 3); continue
        c.get_and_call_next_op()
    else:
        raise AssertionError(('fit check did not return', hex(c.program_counter.value)))
    assert c.system_stack_pointer.value == 0x1F02 and c.user_stack_pointer.value == 0x1234 and c.index_y.value == 0x1357
    assert asked[-1] == index, ('the clicked page is not mapped last', asked)
    stat = (m.read_byte(sy['UmeData_runstat']), m.read_byte(sy['UmeData_reserved_00CE']))
    return c.accu_d.value, sent, sleeps, stat


def main():
    module, sy = build()
    Q, H, W, E8, S64 = [3, 0, 5, 1, 2], [2, 0, 5, 1, 2], [1, 0, 5, 1, 2], [4, 0, 5, 1, 2], [7, 0, 5, 1, 2]
    DQ = [3, 1, 5, 1, 2]                     # dotted quarter = 72
    cases = [
        ('quarter on a quarter rest', 2, Q, 0), ('eighth on a quarter rest', 2, E8, 0), ('64th on a quarter rest', 2, S64, 0),
        ('half on a quarter rest followed by a note', 2, H, 1), ('dotted quarter on a quarter rest followed by a note', 2, DQ, 1),
        ('half on a quarter rest followed by a bar line', 4, H, 1), ('quarter on the last rest of the bar', 4, Q, 0),
        ('half over two quarter rests with another part between', 6, H, 0),
        ('whole over rests a tempo mark apart: 48+48+24 < 192, the score ends', 6, W, 1),
        ('dotted quarter over two quarter rests', 6, DQ, 0),
        ('a palette rest is not a note entry', 2, [2, 0, 32, 1, 2], 0),
    ]
    for name, index, brush, want in cases:
        got, sent, sleeps, stat = run(module, sy, index, brush)
        assert got == want, (name, got, want)
        if want:
            assert sent == BONK and sleeps == [5, 11] and stat == (0, 0), (name, sent, sleeps, stat)
        else:
            assert sent == [] and sleeps == [] and stat == (0x90, 0x90), (name, sent, sleeps, stat)
    print('PASS s9c k:', len(cases), 'cases - fits only inside consecutive rests of the part, bonk bytes and pauses, '
          'stack/U/Y kept, clicked page mapped last')


if __name__ == '__main__':
    main()
