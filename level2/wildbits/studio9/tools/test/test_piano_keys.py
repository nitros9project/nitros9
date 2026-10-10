"""test_piano_keys.py (2026-09-28): UMusE3's piano keys - whole key images painted into banner rows 205-229.

UMusE3 runs on the MC6809 emulator; F$MapBlk / F$ClrBlk are modeled on slot 7 ($E000) as during playback (the
score page mapped there, GPMapped 1; slot 6 busy with the overlay): PianoHook (the MIDI-OUT dispatcher, its
synth call stubbed) gets raw bytes; a Note On must paint the Highlight image of the key, a Note Off (or velocity
0) the clean image, from UmeSymbols16's second bank (tail block, PianoSym) into block 8 of BOTH bitmaps - a
transparent write, rows 23-24 of a white key left alone (slot 7 hides them) - and leave the score page mapped
again at $E000, touching no dot outside the key. Even and odd x, running status, the octave fold, A0 and C8.

    python tools/test/test_piano_keys.py <UMusE3 module> <symbol dump>
"""
import re
import sys
from pathlib import Path
from MC6809.components.cpu6809 import CPU
from MC6809.components.memory import Memory
from MC6809.tests.test_config import TestCfg
from MC6809.tests.test_base import BaseCPUTestCase

ROOT = Path(__file__).resolve().parents[2]
MOD, SYM = Path(sys.argv[1]), Path(sys.argv[2])
BASE, STOP, SLOT7 = 0x2000, 0x1F80, 0xE000
GPTAB, GPMAPPED, GPADDR, PIANOBM, PIANOBM1, PIANOSTAT, PIANOPEND, PIANOSYM = 0x1000, 0x1040, 0x1042, 0x1044, 0x1045, 0x1046, 0x1047, 0x10B0
BM0, BM1, PAGE, SYMB = 0x10, 0x20, 0x40, 0x30
TOP = 205                                          # the banner's first picture row
BANK2 = 0x1B00                                     # the symbol bank's second part starts here in the tail block

def bank_bytes():
    text = (ROOT / "cmds/UmeSymbols16.asm").read_bytes().decode("latin-1").replace("\r\n", "\n")
    out = bytearray()
    for line in text.split("\n"):
        m = re.match(r"\s+fcb\s+(.*)", line)
        if not m:
            continue
        for tok in m.group(1).split(","):
            tok = tok.strip().split()[0] if tok.strip() else ""
            if tok.startswith("$"):
                out.append(int(tok[1:], 16))
            else:
                break
    return bytes(out)

def sprites():
    text = (ROOT / "cmds/UmeSymbols16.asm").read_bytes().decode("latin-1").replace("\r\n", "\n")
    out = {}
    for m in re.finditer(r"@sprite (\w+) width=(\d+) height=(\d+) offset=\$([0-9A-Fa-f]+)", text):
        out[m.group(1)] = (int(m.group(2)), int(m.group(3)), int(m.group(4), 16))
    return out

BANK = bank_bytes()
SPR = sprites()
assert len(BANK) == 11456, len(BANK)
def image(name):
    w, h, off = SPR[name]
    wb = w // 2
    return [BANK[off + r * wb: off + (r + 1) * wb] for r in range(h)]

cfg = TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT)
cfg.ROM_START = 0x10000
cpu = CPU(Memory(cfg), cfg)
mem = cpu.memory
mem.load(BASE, MOD.read_bytes())
sym = {k.lower(): int(v, 16) + BASE for k, v in re.findall(r"^(\w+) EQU \$([0-9A-F]+)", SYM.read_text(), re.M)}
PIANOHOOK, SYNTH = sym["pianohook"], sym["midisendselected"]

phys = {}
def block(n):
    return phys.setdefault(n, bytearray(0x2000))
block(SYMB)[:len(BANK) - BANK2] = BANK[BANK2:]
slot7 = [PAGE]
calls = []
def slot_in(n):
    for i in range(0x2000):
        mem.write_byte(SLOT7 + i, block(n)[i])
def slot_out(n):
    b = block(n)
    for i in range(0x2000):
        b[i] = mem.read_byte(SLOT7 + i)
def os9(code):
    if code == 0x4F:                                   # F$MapBlk X = block, B = count -> U
        blk, n = cpu.index_x.value, cpu.accu_b.value
        assert n == 1 and slot7[0] is None, "F$MapBlk into a busy slot 7 (%r)" % slot7[0]
        slot7[0] = blk; slot_in(blk); calls.append(("map", blk))
        cpu.user_stack_pointer.set(SLOT7); cpu.C = 0
    elif code == 0x50:                                 # F$ClrBlk U = address, B = count
        assert cpu.user_stack_pointer.value == SLOT7 and slot7[0] is not None, "F$ClrBlk of a free slot"
        slot_out(slot7[0]); calls.append(("clr", slot7[0])); slot7[0] = None; cpu.C = 0
    else:
        raise AssertionError("unexpected OS-9 call $%02X at $%04X" % (code, cpu.program_counter.value))

synth = []
def midi(byte):
    """As MidiHwSend hands a byte over: the byte in the caller's word at 2,s, then the jump through pMidiSend."""
    cpu.system_stack_pointer.set(0x1F00)
    cpu.push_word(cpu.system_stack_pointer, byte)
    cpu.push_word(cpu.system_stack_pointer, STOP)
    cpu.program_counter.set(PIANOHOOK)
    n0 = len(calls)
    for _ in range(3_000_000):
        pc = cpu.program_counter.value
        if pc == STOP:
            break
        if pc == SYNTH:
            synth.append((mem.read_byte(cpu.system_stack_pointer.value + 3), len(calls) - n0))
            cpu.program_counter.set(cpu.pull_word(cpu.system_stack_pointer))
            continue
        if mem.read_byte(pc) == 0x10 and mem.read_byte(pc + 1) == 0x3F:
            os9(mem.read_byte(pc + 2)); cpu.program_counter.set(pc + 3)
            continue
        cpu.get_and_call_next_op()
    else:
        raise AssertionError("PianoHook did not return")
    assert synth and synth[-1][0] == byte and synth[-1][1] == 0, "byte $%02X: the synth did not get it first" % byte
    assert slot7[0] == PAGE and mem.read_word(GPADDR) == SLOT7, "the score page is not back after byte $%02X" % byte

# the keyboard: white i at 12i + (7i+16)//24, a black key 8 right of the white key on its left
WHITE_IN_OCT = [0, None, 1, None, 2, 3, None, 4, None, 5, None, 6]
KIND = {0: "PianoWhiteCF", 2: "PianoWhiteDGA", 4: "PianoWhiteEB", 5: "PianoWhiteCF", 7: "PianoWhiteDGA", 9: "PianoWhiteDGA", 11: "PianoWhiteEB"}
def geometry(note):
    o, pc = divmod(note, 12)
    black = WHITE_IN_OCT[pc] is None
    w = WHITE_IN_OCT[pc - 1] if black else WHITE_IN_OCT[pc]
    i = 7 * o + w - 12
    x = 12 * i + (7 * i + 16) // 24 + (8 if black else 0)
    return x, "PianoBlack" if black else KIND[pc]

def dot(bm, row, col):
    off = row * 320 + col // 2
    b = block(bm + off // 0x2000)[off % 0x2000]
    return b >> 4 if col % 2 == 0 else b & 15
def set_dot(bm, row, col, v):
    off = row * 320 + col // 2
    blk = block(bm + off // 0x2000); i = off % 0x2000
    blk[i] = (v << 4) | (blk[i] & 15) if col % 2 == 0 else (blk[i] & 0xF0) | v

def painted(note, pressed):
    """{(row, col): nibble} the key's image puts on the picture (zero nibbles and the hidden rows left out)."""
    x, name = geometry(note)
    rows = image(name + ("Highlight" if pressed else ""))
    limit = 15 if name == "PianoBlack" else 23
    out = {}
    for r, row in enumerate(rows[:limit]):
        nibs = [n for b in row for n in (b >> 4, b & 15)]
        for c, n in enumerate(nibs):
            if n:
                out[(TOP + r, x + c)] = n
    return out

mem.write_word(GPMAPPED, 1); mem.write_word(GPADDR, SLOT7); mem.write_byte(GPTAB + 1, PAGE)
mem.write_byte(PIANOBM, BM0); mem.write_byte(PIANOBM1, BM1); mem.write_byte(PIANOSYM, SYMB)
mem.write_byte(PIANOSTAT, 0); mem.write_byte(PIANOPEND, 0xFF)
slot_in(PAGE)
for n in range(10):
    block(BM0 + n); block(BM1 + n)
for bm in (BM0, BM1):                               # a banner of C, then every clean key on it
    for row in range(TOP, TOP + 25):
        for col in range(640):
            set_dot(bm, row, col, 0xC)
    for note in range(21, 109):
        for (r, c), n in painted(note, False).items():
            set_dot(bm, r, c, n)
snapshot = {bm: [bytes(block(bm + n)) for n in range(10)] for bm in (BM0, BM1)}

failures = 0
def check(note, pressed, label):
    global failures
    want = painted(note, pressed)
    x, name = geometry(note)
    for bm in (BM0, BM1):
        bad = [(r, c, dot(bm, r, c), n) for (r, c), n in want.items() if dot(bm, r, c) != n]
        if bad:
            failures += 1
            print("FAIL %s bitmap $%02X: %d dots wrong, first (row, col, got, want) %r" % (label, bm, len(bad), bad[0]))
            return
        for n in range(10):
            cur = bytes(block(bm + n)); old = snapshot[bm][n]
            for i in range(0x2000):
                if cur[i] != old[i]:
                    off = n * 0x2000 + i; row, col = divmod(off, 320)
                    if (row, col * 2) not in want and (row, col * 2 + 1) not in want:
                        failures += 1
                        print("FAIL %s bitmap $%02X: a dot outside the key changed at row %d byte %d" % (label, bm, row, col))
                        return
    print("%-32s note %3d x %3d %-13s %s: OK" % (label, note, x, name, "pressed" if pressed else "clean"))

for seq, note, on, label in (((0x90, 60, 100), 60, True, "note on C4"), ((60, 0), 60, False, "running status, velocity 0"),
                             ((0x91, 61, 90), 61, True, "channel 2 note on C#4"), ((0xF8, 0x81, 61, 64), 61, False, "clock, then note off"),
                             ((0x90, 21, 64), 21, True, "A0"), ((0x80, 21, 0), 21, False, "A0 off"),
                             ((0x90, 108, 64), 108, True, "C8"), ((0x80, 108, 0), 108, False, "C8 off"),
                             ((0x90, 65, 64), 65, True, "F4 (even x)"), ((0x80, 65, 0), 65, False, "F4 off"),
                             ((0x90, 70, 64), 70, True, "A#4 (even x, black)"), ((0x80, 70, 0), 70, False, "A#4 off"),
                             ((0x90, 9, 64), 21, True, "fold 9 -> A0"), ((0x80, 9, 0), 21, False, "fold 9 -> A0 off"),
                             ((0x90, 120, 64), 108, True, "fold 120 -> C8"), ((0x80, 120, 0), 108, False, "fold 120 -> C8 off")):
    for b in seq:
        midi(b)
    check(note, on, label)
    if not on:
        for bm in (BM0, BM1):
            assert [bytes(block(bm + n)) for n in range(10)] == snapshot[bm], "%s: the banner is not back" % label
print("RESULT: %d failures, %d map/clr calls, %d synth bytes" % (failures, len(calls), len(synth)))
sys.exit(1 if failures else 0)
