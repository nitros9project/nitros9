#!/usr/bin/env python3
"""dis6809.py - 6809 disassembler for OS-9 module FCB-format files.

Converts FCB hex-dump .asm files (as produced by older disassemblers or
hand-dumped binaries) into proper lwasm-compatible 6809 assembly.

Performs control-flow analysis from the module's execution entry point so
that code bytes are disassembled as instructions and data bytes are emitted
as fcb/fdb/fcc directives.

Usage:
    python3 scripts/dis6809.py input.asm > output.asm
    python3 scripts/dis6809.py input.asm -o output.asm
"""

import sys
import re
import argparse
from typing import Dict, List, Optional, Set, Tuple

# ---------------------------------------------------------------------------
# OS-9 service call names
# ---------------------------------------------------------------------------
OS9_CALLS: Dict[int, str] = {
    0x00: 'F$Link',   0x01: 'F$Load',   0x02: 'F$UnLink', 0x03: 'F$Fork',
    0x04: 'F$Wait',   0x05: 'F$Chain',  0x06: 'F$Exit',   0x07: 'F$Mem',
    0x08: 'F$Send',   0x09: 'F$Icpt',   0x0A: 'F$Sleep',  0x0B: 'F$SSpd',
    0x0C: 'F$ID',     0x0D: 'F$SPrior', 0x0E: 'F$SSWI',   0x0F: 'F$PErr',
    0x10: 'F$PrsNam', 0x11: 'F$CmpNam', 0x12: 'F$SchBit', 0x13: 'F$AllBit',
    0x14: 'F$DelBit', 0x15: 'F$Time',   0x16: 'F$STime',  0x17: 'F$CRC',
    0x18: 'F$GPrDsc', 0x19: 'F$GBlkMp', 0x1A: 'F$GModDr', 0x1B: 'F$CpyMem',
    0x1C: 'F$SUser',  0x1D: 'F$UnLoad', 0x1E: 'F$Alarm',
    0x21: 'F$NMLink', 0x22: 'F$NMLoad', 0x23: 'F$Debug',
    0x24: 'F$TPS',    0x25: 'F$TimAlm',
    0x80: 'I$Attach', 0x81: 'I$Detach', 0x82: 'I$Dup',    0x83: 'I$Delete',
    0x84: 'I$Seek',   0x85: 'I$Read',   0x86: 'I$Write',  0x87: 'I$ReadLn',
    0x88: 'I$WritLn', 0x89: 'I$GetStt', 0x8A: 'I$SetStt', 0x8B: 'I$Close',
    0x8C: 'I$MakDir', 0x8D: 'I$ChgDir', 0x8E: 'I$Open',   0x8F: 'I$MakFil',
    0x90: 'I$GStat',  0x91: 'I$SStat',  0x92: 'I$Creat',
}

# ---------------------------------------------------------------------------
# Register tables
# ---------------------------------------------------------------------------
IDX_REGS = {0: 'x', 1: 'y', 2: 'u', 3: 's'}

TFR_REGS = {
    0x0: 'd', 0x1: 'x', 0x2: 'y', 0x3: 'u',
    0x4: 's', 0x5: 'pc',
    0x8: 'a', 0x9: 'b', 0xA: 'cc', 0xB: 'dp',
    # 6309 extras
    0x6: 'w', 0x7: 'v', 0xC: '0', 0xE: 'e', 0xF: 'f',
}

# Register bit positions in PSHS/PULS postbyte (bit -> name)
RLIST_BITS_S = [(0, 'cc'), (1, 'a'), (2, 'b'), (3, 'dp'),
                (4, 'x'),  (5, 'y'), (6, 'u'), (7, 'pc')]
RLIST_BITS_U = [(0, 'cc'), (1, 'a'), (2, 'b'), (3, 'dp'),
                (4, 'x'),  (5, 'y'), (6, 's'), (7, 'pc')]

# ---------------------------------------------------------------------------
# Instruction tables
# Format: opcode -> (mnemonic, mode, terminates_flow)
# mode values: INH, IMM1, IMM2, IMM4, DIR, EXT, IDX,
#              REL1, REL2, REGS, RLIST_S, RLIST_U, OS9
# ---------------------------------------------------------------------------

# Page 0 (no prefix)
P0: Dict[int, Tuple[str, str, bool]] = {
    0x00: ('neg',   'DIR',    False), 0x03: ('com',   'DIR',    False),
    0x04: ('lsr',   'DIR',    False), 0x06: ('ror',   'DIR',    False),
    0x07: ('asr',   'DIR',    False), 0x08: ('asl',   'DIR',    False),
    0x09: ('rol',   'DIR',    False), 0x0A: ('dec',   'DIR',    False),
    0x0C: ('inc',   'DIR',    False), 0x0D: ('tst',   'DIR',    False),
    0x0E: ('jmp',   'DIR',    True),  0x0F: ('clr',   'DIR',    False),
    0x12: ('nop',   'INH',    False), 0x13: ('sync',  'INH',    True),
    0x16: ('lbra',  'REL2',   True),  0x17: ('lbsr',  'REL2',   False),
    0x19: ('daa',   'INH',    False), 0x1A: ('orcc',  'IMM1',   False),
    0x1C: ('andcc', 'IMM1',   False), 0x1D: ('sex',   'INH',    False),
    0x1E: ('exg',   'REGS',   False), 0x1F: ('tfr',   'REGS',   False),
    0x20: ('bra',   'REL1',   True),  0x21: ('brn',   'REL1',   False),
    0x22: ('bhi',   'REL1',   False), 0x23: ('bls',   'REL1',   False),
    0x24: ('bcc',   'REL1',   False), 0x25: ('bcs',   'REL1',   False),
    0x26: ('bne',   'REL1',   False), 0x27: ('beq',   'REL1',   False),
    0x28: ('bvc',   'REL1',   False), 0x29: ('bvs',   'REL1',   False),
    0x2A: ('bpl',   'REL1',   False), 0x2B: ('bmi',   'REL1',   False),
    0x2C: ('bge',   'REL1',   False), 0x2D: ('blt',   'REL1',   False),
    0x2E: ('bgt',   'REL1',   False), 0x2F: ('ble',   'REL1',   False),
    0x30: ('leax',  'IDX',    False), 0x31: ('leay',  'IDX',    False),
    0x32: ('leas',  'IDX',    False), 0x33: ('leau',  'IDX',    False),
    0x34: ('pshs',  'RLIST_S',False), 0x35: ('puls',  'RLIST_S',False),
    0x36: ('pshu',  'RLIST_U',False), 0x37: ('pulu',  'RLIST_U',False),
    0x39: ('rts',   'INH',    True),  0x3A: ('abx',   'INH',    False),
    0x3B: ('rti',   'INH',    True),  0x3C: ('cwai',  'IMM1',   True),
    0x3D: ('mul',   'INH',    False), 0x3F: ('swi',   'OS9',    False),
    0x40: ('nega',  'INH',    False), 0x43: ('coma',  'INH',    False),
    0x44: ('lsra',  'INH',    False), 0x46: ('rora',  'INH',    False),
    0x47: ('asra',  'INH',    False), 0x48: ('asla',  'INH',    False),
    0x49: ('rola',  'INH',    False), 0x4A: ('deca',  'INH',    False),
    0x4C: ('inca',  'INH',    False), 0x4D: ('tsta',  'INH',    False),
    0x4F: ('clra',  'INH',    False), 0x50: ('negb',  'INH',    False),
    0x53: ('comb',  'INH',    False), 0x54: ('lsrb',  'INH',    False),
    0x56: ('rorb',  'INH',    False), 0x57: ('asrb',  'INH',    False),
    0x58: ('aslb',  'INH',    False), 0x59: ('rolb',  'INH',    False),
    0x5A: ('decb',  'INH',    False), 0x5C: ('incb',  'INH',    False),
    0x5D: ('tstb',  'INH',    False), 0x5F: ('clrb',  'INH',    False),
    0x60: ('neg',   'IDX',    False), 0x63: ('com',   'IDX',    False),
    0x64: ('lsr',   'IDX',    False), 0x66: ('ror',   'IDX',    False),
    0x67: ('asr',   'IDX',    False), 0x68: ('asl',   'IDX',    False),
    0x69: ('rol',   'IDX',    False), 0x6A: ('dec',   'IDX',    False),
    0x6C: ('inc',   'IDX',    False), 0x6D: ('tst',   'IDX',    False),
    0x6E: ('jmp',   'IDX',    True),  0x6F: ('clr',   'IDX',    False),
    0x70: ('neg',   'EXT',    False), 0x73: ('com',   'EXT',    False),
    0x74: ('lsr',   'EXT',    False), 0x76: ('ror',   'EXT',    False),
    0x77: ('asr',   'EXT',    False), 0x78: ('asl',   'EXT',    False),
    0x79: ('rol',   'EXT',    False), 0x7A: ('dec',   'EXT',    False),
    0x7C: ('inc',   'EXT',    False), 0x7D: ('tst',   'EXT',    False),
    0x7E: ('jmp',   'EXT',    True),  0x7F: ('clr',   'EXT',    False),
    0x80: ('suba',  'IMM1',   False), 0x81: ('cmpa',  'IMM1',   False),
    0x82: ('sbca',  'IMM1',   False), 0x83: ('subd',  'IMM2',   False),
    0x84: ('anda',  'IMM1',   False), 0x85: ('bita',  'IMM1',   False),
    0x86: ('lda',   'IMM1',   False), 0x88: ('eora',  'IMM1',   False),
    0x89: ('adca',  'IMM1',   False), 0x8A: ('ora',   'IMM1',   False),
    0x8B: ('adda',  'IMM1',   False), 0x8C: ('cmpx',  'IMM2',   False),
    0x8D: ('bsr',   'REL1',   False), 0x8E: ('ldx',   'IMM2',   False),
    0x90: ('suba',  'DIR',    False), 0x91: ('cmpa',  'DIR',    False),
    0x92: ('sbca',  'DIR',    False), 0x93: ('subd',  'DIR',    False),
    0x94: ('anda',  'DIR',    False), 0x95: ('bita',  'DIR',    False),
    0x96: ('lda',   'DIR',    False), 0x97: ('sta',   'DIR',    False),
    0x98: ('eora',  'DIR',    False), 0x99: ('adca',  'DIR',    False),
    0x9A: ('ora',   'DIR',    False), 0x9B: ('adda',  'DIR',    False),
    0x9C: ('cmpx',  'DIR',    False), 0x9D: ('jsr',   'DIR',    False),
    0x9E: ('ldx',   'DIR',    False), 0x9F: ('stx',   'DIR',    False),
    0xA0: ('suba',  'IDX',    False), 0xA1: ('cmpa',  'IDX',    False),
    0xA2: ('sbca',  'IDX',    False), 0xA3: ('subd',  'IDX',    False),
    0xA4: ('anda',  'IDX',    False), 0xA5: ('bita',  'IDX',    False),
    0xA6: ('lda',   'IDX',    False), 0xA7: ('sta',   'IDX',    False),
    0xA8: ('eora',  'IDX',    False), 0xA9: ('adca',  'IDX',    False),
    0xAA: ('ora',   'IDX',    False), 0xAB: ('adda',  'IDX',    False),
    0xAC: ('cmpx',  'IDX',    False), 0xAD: ('jsr',   'IDX',    False),
    0xAE: ('ldx',   'IDX',    False), 0xAF: ('stx',   'IDX',    False),
    0xB0: ('suba',  'EXT',    False), 0xB1: ('cmpa',  'EXT',    False),
    0xB2: ('sbca',  'EXT',    False), 0xB3: ('subd',  'EXT',    False),
    0xB4: ('anda',  'EXT',    False), 0xB5: ('bita',  'EXT',    False),
    0xB6: ('lda',   'EXT',    False), 0xB7: ('sta',   'EXT',    False),
    0xB8: ('eora',  'EXT',    False), 0xB9: ('adca',  'EXT',    False),
    0xBA: ('ora',   'EXT',    False), 0xBB: ('adda',  'EXT',    False),
    0xBC: ('cmpx',  'EXT',    False), 0xBD: ('jsr',   'EXT',    False),
    0xBE: ('ldx',   'EXT',    False), 0xBF: ('stx',   'EXT',    False),
    0xC0: ('subb',  'IMM1',   False), 0xC1: ('cmpb',  'IMM1',   False),
    0xC2: ('sbcb',  'IMM1',   False), 0xC3: ('addd',  'IMM2',   False),
    0xC4: ('andb',  'IMM1',   False), 0xC5: ('bitb',  'IMM1',   False),
    0xC6: ('ldb',   'IMM1',   False), 0xC8: ('eorb',  'IMM1',   False),
    0xC9: ('adcb',  'IMM1',   False), 0xCA: ('orb',   'IMM1',   False),
    0xCB: ('addb',  'IMM1',   False), 0xCC: ('ldd',   'IMM2',   False),
    0xCE: ('ldu',   'IMM2',   False),
    0xD0: ('subb',  'DIR',    False), 0xD1: ('cmpb',  'DIR',    False),
    0xD2: ('sbcb',  'DIR',    False), 0xD3: ('addd',  'DIR',    False),
    0xD4: ('andb',  'DIR',    False), 0xD5: ('bitb',  'DIR',    False),
    0xD6: ('ldb',   'DIR',    False), 0xD7: ('stb',   'DIR',    False),
    0xD8: ('eorb',  'DIR',    False), 0xD9: ('adcb',  'DIR',    False),
    0xDA: ('orb',   'DIR',    False), 0xDB: ('addb',  'DIR',    False),
    0xDC: ('ldd',   'DIR',    False), 0xDD: ('std',   'DIR',    False),
    0xDE: ('ldu',   'DIR',    False), 0xDF: ('stu',   'DIR',    False),
    0xE0: ('subb',  'IDX',    False), 0xE1: ('cmpb',  'IDX',    False),
    0xE2: ('sbcb',  'IDX',    False), 0xE3: ('addd',  'IDX',    False),
    0xE4: ('andb',  'IDX',    False), 0xE5: ('bitb',  'IDX',    False),
    0xE6: ('ldb',   'IDX',    False), 0xE7: ('stb',   'IDX',    False),
    0xE8: ('eorb',  'IDX',    False), 0xE9: ('adcb',  'IDX',    False),
    0xEA: ('orb',   'IDX',    False), 0xEB: ('addb',  'IDX',    False),
    0xEC: ('ldd',   'IDX',    False), 0xED: ('std',   'IDX',    False),
    0xEE: ('ldu',   'IDX',    False), 0xEF: ('stu',   'IDX',    False),
    0xF0: ('subb',  'EXT',    False), 0xF1: ('cmpb',  'EXT',    False),
    0xF2: ('sbcb',  'EXT',    False), 0xF3: ('addd',  'EXT',    False),
    0xF4: ('andb',  'EXT',    False), 0xF5: ('bitb',  'EXT',    False),
    0xF6: ('ldb',   'EXT',    False), 0xF7: ('stb',   'EXT',    False),
    0xF8: ('eorb',  'EXT',    False), 0xF9: ('adcb',  'EXT',    False),
    0xFA: ('orb',   'EXT',    False), 0xFB: ('addb',  'EXT',    False),
    0xFC: ('ldd',   'EXT',    False), 0xFD: ('std',   'EXT',    False),
    0xFE: ('ldu',   'EXT',    False), 0xFF: ('stu',   'EXT',    False),
}

# Page 1 ($10 prefix) - standard 6809
P1: Dict[int, Tuple[str, str, bool]] = {
    0x21: ('lbrn',  'REL2',   False), 0x22: ('lbhi',  'REL2',   False),
    0x23: ('lbls',  'REL2',   False), 0x24: ('lbcc',  'REL2',   False),
    0x25: ('lbcs',  'REL2',   False), 0x26: ('lbne',  'REL2',   False),
    0x27: ('lbeq',  'REL2',   False), 0x28: ('lbvc',  'REL2',   False),
    0x29: ('lbvs',  'REL2',   False), 0x2A: ('lbpl',  'REL2',   False),
    0x2B: ('lbmi',  'REL2',   False), 0x2C: ('lbge',  'REL2',   False),
    0x2D: ('lblt',  'REL2',   False), 0x2E: ('lbgt',  'REL2',   False),
    0x2F: ('lble',  'REL2',   False),
    0x3F: ('swi2',  'INH',    True),
    0x83: ('cmpd',  'IMM2',   False), 0x8C: ('cmpy',  'IMM2',   False),
    0x8E: ('ldy',   'IMM2',   False),
    0x93: ('cmpd',  'DIR',    False), 0x9C: ('cmpy',  'DIR',    False),
    0x9E: ('ldy',   'DIR',    False), 0x9F: ('sty',   'DIR',    False),
    0xA3: ('cmpd',  'IDX',    False), 0xAC: ('cmpy',  'IDX',    False),
    0xAE: ('ldy',   'IDX',    False), 0xAF: ('sty',   'IDX',    False),
    0xB3: ('cmpd',  'EXT',    False), 0xBC: ('cmpy',  'EXT',    False),
    0xBE: ('ldy',   'EXT',    False), 0xBF: ('sty',   'EXT',    False),
    0xCE: ('lds',   'IMM2',   False),
    0xDE: ('lds',   'DIR',    False), 0xDF: ('sts',   'DIR',    False),
    0xEE: ('lds',   'IDX',    False), 0xEF: ('sts',   'IDX',    False),
    0xFE: ('lds',   'EXT',    False), 0xFF: ('sts',   'EXT',    False),
}

# Page 2 ($11 prefix) - standard 6809
P2: Dict[int, Tuple[str, str, bool]] = {
    0x3F: ('swi3',  'INH',    True),
    0x83: ('cmpu',  'IMM2',   False), 0x8C: ('cmps',  'IMM2',   False),
    0x93: ('cmpu',  'DIR',    False), 0x9C: ('cmps',  'DIR',    False),
    0xA3: ('cmpu',  'IDX',    False), 0xAC: ('cmps',  'IDX',    False),
    0xB3: ('cmpu',  'EXT',    False), 0xBC: ('cmps',  'EXT',    False),
}

# ---------------------------------------------------------------------------
# Indexed addressing mode decoder
# ---------------------------------------------------------------------------

def decode_indexed(data: bytes, pos: int, instr_base: int) -> Tuple[str, int]:
    """Decode indexed post-byte at data[pos].

    instr_base: absolute byte offset of the instruction's opcode byte (used
                for PC-relative offset calculations).

    Returns (operand_text, bytes_consumed_including_postbyte).
    """
    if pos >= len(data):
        return '?', 1
    pb = data[pos]
    r = IDX_REGS[(pb >> 5) & 3]

    if not (pb & 0x80):
        # 5-bit signed constant offset, no extra bytes
        offset = pb & 0x1F
        if offset & 0x10:
            offset -= 0x20
        if offset == 0:
            return f',{r}', 1
        elif offset > 0:
            return f'<${offset:02X},{r}', 1
        else:
            return f'<-${(-offset):02X},{r}', 1

    indirect = (pb & 0x10) != 0
    mode = pb & 0x0F
    inner: Optional[str] = None
    extra = 1  # just the postbyte

    if mode == 0x00:
        inner = f',{r}+'
    elif mode == 0x01:
        inner = f',{r}++'
    elif mode == 0x02:
        inner = f',-{r}'
    elif mode == 0x03:
        inner = f',--{r}'
    elif mode == 0x04:
        inner = f',{r}'
    elif mode == 0x05:
        inner = f'b,{r}'
    elif mode == 0x06:
        inner = f'a,{r}'
    elif mode == 0x07:
        inner = f'e,{r}'     # 6309
    elif mode == 0x08:
        if pos + 1 >= len(data):
            return '?', 1
        off8 = data[pos + 1]
        if off8 & 0x80:
            off8 -= 0x100
        inner = (f'<${off8:02X},{r}' if off8 >= 0 else f'<-${(-off8):02X},{r}')
        extra = 2
    elif mode == 0x09:
        if pos + 2 >= len(data):
            return '?', 1
        off16 = (data[pos + 1] << 8) | data[pos + 2]
        if off16 & 0x8000:
            off16 -= 0x10000
        inner = (f'>${off16:04X},{r}' if off16 >= 0 else f'>-${(-off16):04X},{r}')
        extra = 3
    elif mode == 0x0A:
        inner = f'f,{r}'     # 6309
    elif mode == 0x0B:
        inner = f'd,{r}'
    elif mode == 0x0C:
        # 8-bit PC-relative offset.  Target = (address after postbyte+offset) + offset
        if pos + 1 >= len(data):
            return '?', 1
        off8 = data[pos + 1]
        if off8 & 0x80:
            off8 -= 0x100
        # The pc value at decode time is instr_base + (pos - instr_base) + 2
        target = pos + 2 + off8   # pos is offset within data array = absolute addr
        inner = f'>L{target:04X},pcr'
        extra = 2
    elif mode == 0x0D:
        # 16-bit PC-relative offset
        if pos + 2 >= len(data):
            return '?', 1
        off16 = (data[pos + 1] << 8) | data[pos + 2]
        if off16 & 0x8000:
            off16 -= 0x10000
        target = pos + 3 + off16
        inner = f'>L{target:04X},pcr'
        extra = 3
    elif mode == 0x0E:
        inner = f'w,{r}'     # 6309
    elif mode == 0x0F:
        # Extended indirect
        if pos + 2 >= len(data):
            return '?', 1
        addr = (data[pos + 1] << 8) | data[pos + 2]
        return f'[>${addr:04X}]', 3
    else:
        return f'${pb:02X}', 1

    if inner is None:
        return f'${pb:02X}', 1

    if indirect:
        return f'[{inner}]', extra
    return inner, extra


def decode_rlist(pb: int, bits: list) -> str:
    """Decode PSHS/PULS/PSHU/PULU register list postbyte."""
    parts = [name for bit, name in bits if pb & (1 << bit)]
    return ','.join(parts) if parts else '0'


def decode_regs(pb: int) -> str:
    """Decode TFR/EXG register pair postbyte."""
    src = TFR_REGS.get(pb >> 4, f'${pb >> 4:X}')
    dst = TFR_REGS.get(pb & 0xF, f'${pb & 0xF:X}')
    return f'{src},{dst}'


# ---------------------------------------------------------------------------
# Single instruction decoder
# ---------------------------------------------------------------------------

def decode_instr(data: bytes, pos: int) -> Tuple[str, str, int, bool, List[int]]:
    """Decode one instruction at data[pos].

    Returns:
        (mnemonic, operand_text, length_in_bytes, terminates_flow, branch_targets)
        branch_targets: list of absolute byte offsets that this instruction
                        may transfer control to (not counting fall-through).
    """
    if pos >= len(data):
        return 'fcb', f'${data[pos]:02X}' if pos < len(data) else '?', 1, False, []

    b0 = data[pos]
    table = P0
    pfx_len = 0

    if b0 == 0x10:
        if pos + 1 >= len(data):
            return 'fcb', f'$10', 1, False, []
        b1 = data[pos + 1]
        entry = P1.get(b1)
        if entry:
            table = P1
            b0 = b1
            pfx_len = 1
        else:
            # Unknown $10 xx - emit as fcb pair
            return 'fcb', f'$10,${b1:02X}', 2, False, []
    elif b0 == 0x11:
        if pos + 1 >= len(data):
            return 'fcb', f'$11', 1, False, []
        b1 = data[pos + 1]
        entry = P2.get(b1)
        if entry:
            table = P2
            b0 = b1
            pfx_len = 1
        else:
            return 'fcb', f'$11,${b1:02X}', 2, False, []
    else:
        entry = P0.get(b0)

    if entry is None:
        return 'fcb', f'${data[pos]:02X}', 1, False, []

    mnem, mode, terminates = entry
    base = pos + pfx_len + 1   # offset of first operand byte in data
    targets: List[int] = []
    operand = ''
    length = pfx_len + 1       # prefix + opcode byte

    if mode == 'INH':
        operand = ''
    elif mode == 'OS9':
        # $3F nn - OS9 trap
        if base < len(data):
            svc = data[base]
            name = OS9_CALLS.get(svc, f'${svc:02X}')
            operand = name
            length += 1
            terminates = False  # execution continues after os9 call
        else:
            operand = '?'
            length += 1
    elif mode == 'IMM1':
        if base < len(data):
            operand = f'#${data[base]:02X}'
        length += 1
    elif mode == 'IMM2':
        if base + 1 < len(data):
            val = (data[base] << 8) | data[base + 1]
            operand = f'#${val:04X}'
        length += 2
    elif mode == 'IMM4':
        if base + 3 < len(data):
            val = ((data[base] << 24) | (data[base+1] << 16) |
                   (data[base+2] << 8) | data[base+3])
            operand = f'#${val:08X}'
        length += 4
    elif mode == 'DIR':
        if base < len(data):
            operand = f'<${data[base]:02X}'
        length += 1
    elif mode == 'EXT':
        if base + 1 < len(data):
            addr = (data[base] << 8) | data[base + 1]
            operand = f'>L{addr:04X}'
            targets.append(addr) if mnem == 'jmp' else None
        length += 2
    elif mode == 'IDX':
        op_text, extra = decode_indexed(data, base, pos)
        operand = op_text
        length += extra
        # If indexed JMP/JSR, target is unknown (indirect)
    elif mode == 'REL1':
        if base < len(data):
            off = data[base]
            if off & 0x80:
                off -= 0x100
            target = base + 1 + off   # base+1 = address after offset byte
            operand = f'>L{target:04X}'
            targets.append(target)
        length += 1
    elif mode == 'REL2':
        if base + 1 < len(data):
            off = (data[base] << 8) | data[base + 1]
            if off & 0x8000:
                off -= 0x10000
            target = base + 2 + off
            operand = f'>L{target:04X}'
            targets.append(target)
        length += 2
    elif mode == 'REGS':
        if base < len(data):
            operand = decode_regs(data[base])
        length += 1
    elif mode == 'RLIST_S':
        if base < len(data):
            pb = data[base]
            operand = decode_rlist(pb, RLIST_BITS_S)
            # puls pc,... terminates sequential flow
            if mnem == 'puls' and (pb & 0x80):
                terminates = True
            # pulu pc,... terminates
            length += 1
    elif mode == 'RLIST_U':
        if base < len(data):
            pb = data[base]
            operand = decode_rlist(pb, RLIST_BITS_U)
            if mnem == 'pulu' and (pb & 0x80):
                terminates = True
            length += 1

    return mnem, operand, length, terminates, targets


# ---------------------------------------------------------------------------
# FCB file parser
# ---------------------------------------------------------------------------

def parse_fcb_file(path: str) -> Tuple[bytes, Dict[int, str]]:
    """Parse an FCB-format .asm file.

    Returns:
        (data_bytes, label_map)
        label_map: offset -> label_name for labels found in the file
    """
    data_list: List[int] = []
    label_map: Dict[int, str] = {}

    with open(path, 'r', errors='replace') as fh:
        for line in fh:
            line = line.rstrip('\r\n')

            # Skip pure comment lines or blank lines
            stripped = line.strip()
            if not stripped or stripped.startswith('*'):
                continue

            # Look for lines that begin with a label (Lxxxx or similar) followed by fcb
            m = re.match(
                r'^([A-Za-z_][A-Za-z0-9_]*)\s+fcb\s+((?:\$[0-9A-Fa-f]{1,2},?)+)',
                stripped, re.IGNORECASE)
            if m:
                label = m.group(1)
                bytes_str = m.group(2)
                # Derive the offset from the label if it's Lhhhh / Uhhhh etc.
                lm = re.match(r'^[A-Za-z]([0-9A-Fa-f]{4})$', label)
                if lm:
                    off = int(lm.group(1), 16)
                    label_map[off] = label
                for bstr in bytes_str.split(','):
                    bstr = bstr.strip()
                    if bstr.startswith('$') or bstr.startswith('0x'):
                        data_list.append(int(bstr.replace('$', ''), 16))
                continue

            # Lines without a leading label: just fcb data
            m2 = re.match(r'^\s+fcb\s+((?:\$[0-9A-Fa-f]{1,2},?)+)', line, re.IGNORECASE)
            if m2:
                for bstr in m2.group(1).split(','):
                    bstr = bstr.strip()
                    if bstr.startswith('$') or bstr.startswith('0x'):
                        data_list.append(int(bstr.replace('$', ''), 16))
                continue

    return bytes(data_list), label_map


# ---------------------------------------------------------------------------
# OS-9 module header parser
# ---------------------------------------------------------------------------

def parse_os9_header(data: bytes) -> dict:
    """Parse OS-9 module header. Returns dict with header fields or raises."""
    if len(data) < 13:
        raise ValueError('Module too small for OS-9 header')
    if data[0] != 0x87 or data[1] != 0xCD:
        raise ValueError(f'Bad sync bytes: ${data[0]:02X},${data[1]:02X}')

    mod_size   = (data[2] << 8) | data[3]
    name_off   = (data[4] << 8) | data[5]
    type_lang  = data[6]
    attr_rev   = data[7]
    # parity    = data[8]  (not used for disassembly)
    exec_off   = (data[9] << 8) | data[10]
    data_size  = (data[11] << 8) | data[12]

    mod_type = (type_lang >> 4) & 0xF
    language = type_lang & 0xF

    # Decode module name (FCS - last byte has high bit set)
    name_bytes = []
    i = name_off
    while i < len(data):
        b = data[i]
        name_bytes.append(chr(b & 0x7F))
        i += 1
        if b & 0x80:
            break
    mod_name = ''.join(name_bytes)

    # Edition byte follows name
    edition = data[i] if i < len(data) else 0

    # Determine type/attr strings for assembly header
    type_str = {
        0x1: 'Prgrm', 0x2: 'Systm', 0xB: 'FlMgr',
        0xC: 'Drivr', 0xD: 'Devic',
    }.get(mod_type, f'${type_lang:02X}')

    lang_str = {
        0x1: 'Objct', 0x2: 'ICode', 0x3: 'PCode',
        0x4: 'CCode', 0x5: 'CblCode', 0x6: 'FCode',
    }.get(language, f'')

    tylg_val = f'{type_str}+{lang_str}' if lang_str else type_str

    # Attr: upper nibble, Rev: lower nibble
    attr = (attr_rev >> 4) & 0xF
    rev  = attr_rev & 0xF
    attr_str = 'ReEnt' if attr & 0x8 else 'Objct'
    atrv_val = f'{attr_str}+rev' if rev else attr_str

    return {
        'mod_size':   mod_size,
        'name_off':   name_off,
        'exec_off':   exec_off,
        'data_size':  data_size,
        'mod_name':   mod_name,
        'edition':    edition,
        'name_end':   i,          # offset of edition byte
        'code_start': i + 1,      # first byte after edition
        'tylg_val':   tylg_val,
        'atrv_val':   atrv_val,
        'rev':        rev,
        'attr_rev':   attr_rev,
        'type_lang':  type_lang,
        'mod_type':   mod_type,
    }


# ---------------------------------------------------------------------------
# Control-flow analysis
# ---------------------------------------------------------------------------

def collect_code_addrs(data: bytes, entry: int, code_end: int) -> Set[int]:
    """BFS/DFS from entry point, marking all reachable instruction addresses."""
    visited: Set[int] = set()
    worklist = [entry]

    while worklist:
        pos = worklist.pop()
        if pos in visited or pos < 0 or pos >= code_end:
            continue
        visited.add(pos)

        mnem, operand, length, terminates, targets = decode_instr(data, pos)

        # Queue branch/call targets
        for t in targets:
            if 0 <= t < code_end and t not in visited:
                worklist.append(t)

        # Follow fall-through unless flow terminates
        if not terminates:
            nxt = pos + length
            if nxt < code_end and nxt not in visited:
                worklist.append(nxt)

    return visited


# ---------------------------------------------------------------------------
# String detector
# ---------------------------------------------------------------------------

def _is_printable(b: int) -> bool:
    return 0x20 <= b <= 0x7E or b == 0x0D or b == 0x0A or b == 0x09


def find_string_at(data: bytes, pos: int, min_len: int = 3) -> int:
    """Return length of printable string starting at pos (including terminator $0D or FCS high bit).
    Returns 0 if no string found."""
    i = pos
    while i < len(data):
        b = data[i]
        if b & 0x80:
            # FCS-terminated
            if _is_printable(b & 0x7F) and i - pos >= min_len - 1:
                return i - pos + 1
            return 0
        if b == 0x0D:
            # CR-terminated
            if i - pos >= min_len:
                return i - pos + 1
            return 0
        if not _is_printable(b):
            return 0
        i += 1
    return 0


# ---------------------------------------------------------------------------
# Output formatter
# ---------------------------------------------------------------------------

COL_LABEL  = 20
COL_MNEM   = 30
COL_OPERAND = 50

def fmt_line(label: str, mnem: str, operand: str, comment: str = '') -> str:
    line = label.ljust(COL_LABEL) + mnem.ljust(COL_MNEM - COL_LABEL)
    if operand:
        line += operand.ljust(COL_OPERAND - COL_MNEM)
    if comment:
        line += f'; {comment}'
    return line.rstrip()


def label_for(addr: int, known: Dict[int, str]) -> str:
    if addr in known:
        return known[addr]
    return f'L{addr:04X}'


# ---------------------------------------------------------------------------
# Main disassembler
# ---------------------------------------------------------------------------

def disassemble(data: bytes, hdr: dict) -> List[str]:
    """Disassemble the code section of an OS-9 module binary.

    Returns lines of assembly text (without trailing newlines).
    """
    lines: List[str] = []
    exec_off   = hdr['exec_off']
    data_size  = hdr['data_size']
    code_start = hdr['code_start']
    mod_size   = hdr['mod_size']
    name_off   = hdr['name_off']

    # The code lives from code_start to mod_size - 3 (last 3 bytes = CRC)
    code_end = mod_size - 3

    # Collect all reachable code addresses
    code_addrs = collect_code_addrs(data, exec_off, code_end)

    # Build label map: address -> label string
    # Pre-populate with code branch targets
    labels: Dict[int, str] = {}
    for addr in sorted(code_addrs):
        # Will add labels lazily during second pass
        pass

    # Determine which addresses need labels (branch/call targets)
    target_addrs: Set[int] = set()
    for pos in sorted(code_addrs):
        _, _, length, _, targets = decode_instr(data, pos)
        for t in targets:
            target_addrs.add(t)
        if pos == exec_off:
            target_addrs.add(pos)

    # The entry point always gets a label
    target_addrs.add(exec_off)

    # Also label the start of any run of code that is preceded by data
    prev_was_data = True
    for pos in range(code_start, code_end):
        if pos in code_addrs:
            if prev_was_data:
                target_addrs.add(pos)
            prev_was_data = False
        else:
            prev_was_data = True

    def lbl(addr: int) -> str:
        return f'L{addr:04X}'

    # ── Emit module header ──────────────────────────────────────────────────
    mod_name = hdr['mod_name']
    lines.append(fmt_line('', 'nam', mod_name))
    lines.append(fmt_line('', 'ttl', f'program module'))
    lines.append('')
    lines.append(fmt_line('', 'use', 'defsfile'))
    lines.append('')
    lines.append(fmt_line('tylg', 'set', hdr['tylg_val']))
    lines.append(fmt_line('atrv', 'set', hdr['atrv_val']))
    lines.append(fmt_line('rev', 'set', f'${hdr["rev"]:02X}'))
    lines.append(fmt_line('edition', 'set', f'${hdr["edition"]:02X}'))
    lines.append('')

    # ── Emit data segment (rmb block) ───────────────────────────────────────
    # The data segment size is in the header.  We emit a single block for now;
    # a more detailed analysis would break it into named fields.
    if data_size > 0:
        lines.append(fmt_line('', 'mod', f'eom,name,tylg,atrv,start,size'))
        lines.append('')
        lines.append(fmt_line('u0000', 'rmb', str(data_size),
                               f'data segment ({data_size} bytes)'))
        lines.append(fmt_line('size', 'equ', '.'))
    else:
        lines.append(fmt_line('', 'mod', f'eom,name,tylg,atrv,start,size'))
        lines.append(fmt_line('size', 'equ', '0'))

    lines.append('')

    # ── Emit module name and edition ────────────────────────────────────────
    lines.append(fmt_line('name', 'equ', '*'))
    lines.append(fmt_line('', 'fcs', f'/{mod_name}/'))
    lines.append(fmt_line('', 'fcb', f'edition'))
    lines.append('')

    # ── Emit code/data body ─────────────────────────────────────────────────
    # Bytes between code_start and exec_off may be small data tables or
    # helper subroutines placed before the main entry.
    pos = code_start

    def emit_fcb_run(start_pos: int, end_pos: int, lbl_name: str = '') -> None:
        """Emit bytes from start_pos to end_pos-1 as fcb/fcc."""
        i = start_pos
        while i < end_pos:
            label_here = lbl_name if i == start_pos else (lbl(i) if i in target_addrs else '')
            # Try to detect a printable string
            slen = find_string_at(data, i)
            if slen >= 4 and i + slen <= end_pos:
                raw = data[i:i+slen]
                # Check if it's FCS or CR-terminated
                last = raw[-1]
                if last & 0x80:
                    text = ''.join(chr(b & 0x7F) for b in raw)
                    directive = 'fcs'
                else:
                    text = ''.join(chr(b) for b in raw[:-1])
                    directive = 'fcc'
                    lines.append(fmt_line(label_here, directive, f'/{text}/'))
                    if last == 0x0D:
                        lines.append(fmt_line('', 'fcb', '$0D'))
                    i += slen
                    continue
                lines.append(fmt_line(label_here, directive, f'/{text}/'))
                i += slen
                continue

            # Emit up to 8 bytes as fcb
            chunk = min(8, end_pos - i)
            hex_vals = ','.join(f'${b:02X}' for b in data[i:i+chunk])
            lines.append(fmt_line(label_here, 'fcb', hex_vals))
            i += chunk

    while pos < code_end:
        if pos in code_addrs:
            # Emit label if needed
            label_here = ''
            if pos in target_addrs:
                label_here = ('start' if pos == exec_off else lbl(pos))

            mnem, operand, length, terminates, targets = decode_instr(data, pos)

            # Special case: 'os9' instruction
            if mnem == 'swi' and operand:
                # operand already contains the OS9 call name
                lines.append(fmt_line(label_here, 'os9', operand))
            elif operand:
                lines.append(fmt_line(label_here, mnem, operand))
            else:
                lines.append(fmt_line(label_here, mnem, ''))

            pos += length
        else:
            # Data byte(s) - collect a run
            run_start = pos
            while pos < code_end and pos not in code_addrs:
                pos += 1
            label_here = lbl(run_start) if run_start in target_addrs else ''
            emit_fcb_run(run_start, pos, label_here)

    # ── eom ────────────────────────────────────────────────────────────────
    lines.append('')
    lines.append(fmt_line('eom', 'equ', '*'))
    lines.append(fmt_line('', 'end'))
    lines.append('')

    return lines


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main() -> None:
    parser = argparse.ArgumentParser(
        description='Disassemble OS-9 FCB-format .asm files to 6809 assembly')
    parser.add_argument('input', help='Input FCB-format .asm file')
    parser.add_argument('-o', '--output', help='Output file (default: stdout)')
    args = parser.parse_args()

    try:
        data, orig_labels = parse_fcb_file(args.input)
    except Exception as e:
        print(f'Error reading {args.input}: {e}', file=sys.stderr)
        sys.exit(1)

    if not data:
        print(f'No FCB data found in {args.input}', file=sys.stderr)
        sys.exit(1)

    try:
        hdr = parse_os9_header(data)
    except ValueError as e:
        print(f'OS-9 header error: {e}', file=sys.stderr)
        sys.exit(1)

    print(f'Module: {hdr["mod_name"]}  size=${hdr["mod_size"]:04X}  '
          f'exec=${hdr["exec_off"]:04X}  data=${hdr["data_size"]:04X}',
          file=sys.stderr)

    result = disassemble(data, hdr)

    out_lines = '\n'.join(result) + '\n'

    if args.output:
        with open(args.output, 'w') as fh:
            fh.write(out_lines)
    else:
        sys.stdout.write(out_lines)


if __name__ == '__main__':
    main()
