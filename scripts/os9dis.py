#!/usr/bin/env python3
"""os9dis.py - Disassemble OS-9 FCB-format .asm files to lwasm-compatible assembly.

Pipeline:
  1. Parse FCB-format .asm file to extract the raw binary.
  2. Parse the OS-9 module header (entry point, data size, module name).
  3. Generate an f9dasm info file that marks the fixed header region as data.
  4. Run f9dasm -noconv -os9 on the binary.
  5. Post-process the f9dasm output to lwasm-compatible format, including:
     - Lowercase mnemonics and register names
     - Proper OS-9 module header directives (mod, rmb, fcs, etc.)
     - Unified label naming (Lxxxx for all in-module addresses)
     - Numeric literals for immediate constants that aren't code addresses
     - Stripped hex-dump noise comments

Requires: f9dasm in PATH (http://www.magicdomain.com/f9dasm/).

Usage:
    python3 scripts/os9dis.py input.asm > output.asm
    python3 scripts/os9dis.py input.asm -o output.asm
"""

import sys
import re
import os
import subprocess
import tempfile
import argparse
from typing import Optional


# ---------------------------------------------------------------------------
# Register names for lowercasing
# ---------------------------------------------------------------------------
REGS = frozenset(['a', 'b', 'd', 'e', 'f', 'w', 'q',
                  'x', 'y', 'u', 's', 'pc', 'dp', 'cc', 'v',
                  'pcr'])


# ---------------------------------------------------------------------------
# Step 1: extract raw binary from FCB-format .asm file
# ---------------------------------------------------------------------------

def parse_fcb_file(path: str) -> bytes:
    data: list[int] = []
    with open(path, 'r', errors='replace') as fh:
        for line in fh:
            m = re.search(
                r'\bfcb\s+((?:\$[0-9A-Fa-f]{1,2},?\s*)+)',
                line, re.IGNORECASE)
            if m:
                for tok in re.findall(r'\$([0-9A-Fa-f]{1,2})', m.group(1)):
                    data.append(int(tok, 16))
    return bytes(data)


# ---------------------------------------------------------------------------
# Step 2: parse OS-9 module header
# ---------------------------------------------------------------------------

def parse_os9_header(data: bytes) -> dict:
    if len(data) < 13:
        raise ValueError('binary too short for OS-9 header')
    if data[0] != 0x87 or data[1] != 0xCD:
        raise ValueError(f'bad sync bytes ${data[0]:02X},${data[1]:02X}')

    mod_size  = (data[2] << 8) | data[3]
    name_off  = (data[4] << 8) | data[5]
    type_lang = data[6]
    attr_rev  = data[7]
    exec_off  = (data[9] << 8) | data[10]
    data_size = (data[11] << 8) | data[12]

    # Decode FCS module name (last byte has high bit set)
    name_chars: list[str] = []
    i = name_off
    while i < len(data):
        b = data[i]
        name_chars.append(chr(b & 0x7F))
        i += 1
        if b & 0x80:
            break
    mod_name = ''.join(name_chars)
    edition = data[i] if i < len(data) else 0

    mod_type = (type_lang >> 4) & 0xF
    language = type_lang & 0xF
    attr     = (attr_rev >> 4) & 0xF
    rev      = attr_rev & 0xF

    type_str = {0x1: 'Prgrm', 0x2: 'Systm', 0xB: 'FlMgr',
                0xC: 'Drivr', 0xD: 'Devic'}.get(mod_type, f'${type_lang:02X}')
    lang_str = {0x1: 'Objct', 0x2: 'ICode', 0x3: 'PCode',
                0x4: 'CCode'}.get(language, '')
    tylg_val = f'{type_str}+{lang_str}' if lang_str else type_str

    attr_str = 'ReEnt' if attr & 0x8 else 'Objct'
    atrv_val = f'{attr_str}+rev' if rev else attr_str

    return {
        'mod_size':    mod_size,
        'name_off':    name_off,
        'name_end':    i - 1,       # last byte of FCS name
        'edition_off': i,           # byte position of edition
        'code_start':  i + 1,       # first byte after edition
        'exec_off':    exec_off,
        'data_size':   data_size,
        'mod_name':    mod_name,
        'edition':     edition,
        'tylg_val':    tylg_val,
        'atrv_val':    atrv_val,
        'rev':         rev,
    }


# ---------------------------------------------------------------------------
# Step 3: build f9dasm info file
# ---------------------------------------------------------------------------

def find_string_regions(data: bytes, start: int, end: int) -> list[tuple[int, int]]:
    """Return list of (start, end) byte ranges for high-confidence string data.

    Two terminator styles are recognised, both requiring a run of printable
    ASCII that starts with a letter, '*', '/', '(', '"', '#', or '%' (never a
    digit or control character) and contains at least two different letters:

      - CR-terminated ($0D): at least 16 bytes total (long banner/message text).
      - NUL-terminated ($00): at least 4 printable characters before the $00.
        These are the short C string constants ("Init", "C.PREP ", paths, ...)
        that would otherwise be decoded as code; because they are often odd in
        length they push the decoder out of phase into the routine that follows
        them, so catching them also rescues that routine's real entry point.

    The terminator is included in the returned region so the decoder resumes
    cleanly on the byte after it.  FCS-terminated strings are deliberately
    excluded: they are much harder to tell from code bytes with bit 7 set.
    """
    CR_MIN_LEN      = 16    # CR-terminated: total bytes incl. the $0D
    NUL_MIN_CONTENT = 4     # NUL-terminated: printable chars before the $00
    regions: list[tuple[int, int]] = []
    i = start
    while i < end:
        first = data[i]
        # String must start with a letter or specific printable symbol
        if not (chr(first).isalpha() or first in b'*/(\"#%'):
            i += 1
            continue
        # Scan forward for a CR or NUL terminator over printable ASCII
        j = i
        letters: set[int] = set()
        term: int | None = None
        while j < end:
            b = data[j]
            if b == 0x0D or b == 0x00:  # terminator found
                term = b
                j += 1
                break
            if 0x20 <= b <= 0x7E:       # printable ASCII (no high bit)
                if chr(b).isalpha():
                    letters.add(b)
                j += 1
            else:
                break                   # non-text byte: not a clean string
        if term is None:                # hit a non-text byte or ran off the end
            i += 1
            continue

        total = j - i                   # printable run plus the terminator
        accept = len(letters) >= 2 and (
            (term == 0x0D and total >= CR_MIN_LEN) or
            (term == 0x00 and total - 1 >= NUL_MIN_CONTENT))
        if accept:
            regions.append((i, j - 1))  # include the terminator byte
            i = j
        else:
            i += 1
    return regions


def make_info(hdr: dict, data: bytes = b'') -> str:
    n0  = hdr['name_off']
    ne  = hdr['name_end']
    ed  = hdr['edition_off']
    ex  = hdr['exec_off']
    mod_size = hdr['mod_size']
    code_start = hdr['code_start']
    header_end = n0 - 1

    rows = [
        'OPTION nohex',
        'OPTION noconv',
        'OPTION os9',
        '',
        '* OS-9 module fixed header (sync bytes through data-size field)',
        f'DATA 00-{header_end:02X}',
        '',
        '* module name FCS string',
        f'CHAR {n0:02X}-{ne:02X}',
        '',
        '* edition byte',
        f'DATA {ed:02X}',
        '',
        '* execution entry point',
        f'LABEL {ex:04X} start',
    ]

    # Mark known data string regions so f9dasm doesn't decode them as code.
    # Scan for printable strings in the code body (excluding the CRC at end).
    if data:
        code_end = mod_size - 3  # last 3 bytes are the CRC
        string_regions = find_string_regions(data, code_start, code_end)
        if string_regions:
            rows.append('')
            rows.append('* detected string/data regions')
            for s, e in string_regions:
                rows.append(f'CHAR {s:04X}-{e:04X}')

    return '\n'.join(rows) + '\n'


# ---------------------------------------------------------------------------
# Step 5: post-process f9dasm output -> lwasm format
# ---------------------------------------------------------------------------

# Mnemonics that terminate sequential execution flow.
TERMINATORS = frozenset(['rts', 'rti', 'bra', 'lbra', 'jmp', 'swi',
                         'swi2', 'swi3', 'sync', 'cwai'])

# All f9dasm inline comments are hex-dump noise (";'x'" style) — strip them all.
_NOISE_COMMENT = re.compile(r"\s*;.*$")


def postprocess(raw: str, hdr: dict, data: bytes = b'') -> str:
    """Convert f9dasm output to lwasm-compatible assembly."""

    mod_size    = hdr['mod_size']
    mod_name    = hdr['mod_name']
    exec_off    = hdr['exec_off']
    data_size   = hdr['data_size']
    edition     = hdr['edition']
    tylg_val    = hdr['tylg_val']
    atrv_val    = hdr['atrv_val']
    rev         = hdr['rev']
    edition_off = hdr['edition_off']
    crc_start   = mod_size - 3

    lines_raw = raw.splitlines()

    # ── collect EQU definitions and defined instruction labels ───────────────
    # f9dasm emits EQUs for every address referenced in operands.
    # Those outside module bounds are numeric constants, not code addresses.
    ext_equ: dict[str, int] = {}   # f9dasm label → value (external only)
    all_equ: dict[str, int] = {}   # f9dasm label → value (all)
    # defined_labels: f9dasm labels that appear as actual instruction/data labels
    # (not just EQU entries).  Only labels above edition_off are relevant —
    # header-region labels are suppressed in the output and must not become Lxxxx.
    defined_labels: set[str] = set()

    for line in lines_raw:
        m = re.match(r'^([A-Za-z][0-9A-Fa-f]{4})\s+EQU\s+\$([0-9A-Fa-f]+)', line)
        if m:
            val = int(m.group(2), 16)
            all_equ[m.group(1)] = val
            if val >= mod_size:
                ext_equ[m.group(1)] = val
        else:
            # Instruction / data label (non-EQU line with a leading M/Z label)
            m2 = re.match(r'^([MZ][0-9A-Fa-f]{4})\s+', line)
            if m2:
                lbl = m2.group(1)
                val = int(lbl[1:], 16)
                if val > edition_off:   # exclude header-region labels
                    defined_labels.add(lbl)

    # ── label normaliser ────────────────────────────────────────────────────
    def norm_lbl(tok: str, in_immediate: bool = False) -> str:
        """Convert f9dasm M/Z label to L label or literal.

        Only labels that actually appear as instruction/data labels in f9dasm
        output (i.e. are in defined_labels) become Lxxxx references.  Labels
        that exist only in the EQU section — mid-instruction bytes, header
        addresses used as numeric constants, etc. — are emitted as $xxxx
        literals so the assembler never sees an undefined reference.
        """
        m = re.match(r'^([MZ])([0-9A-Fa-f]{4})$', tok)
        if not m:
            return tok
        val = int(m.group(2), 16)
        # External (out of module) → always literal
        if tok in ext_equ:
            return f'${val:04X}'
        # Immediate context → always literal (numeric constant, not code addr)
        if in_immediate:
            return f'${val:04X}'
        # Label only in EQU section (not at an instruction boundary) → literal
        if tok not in defined_labels:
            return f'${val:04X}'
        return f'L{val:04X}'

    # ── operand rewriter ────────────────────────────────────────────────────
    def rewrite_op(raw_op: str, mnem: str) -> str:
        """Normalise addressing, label names and register case."""
        if not raw_op:
            return ''

        op = raw_op

        # ── FCC: "text" → /text/ — do this BEFORE any identifier processing
        # so that the string content is never treated as identifiers/registers.
        if mnem == 'fcc':
            op = _NOISE_COMMENT.sub('', op).strip()
            op = re.sub(r'^"(.*)"$', r'/\1/', op)
            return op

        # ── FCB quoted chars: 'c → $xx ─────────────────────────────────────
        # Apply BEFORE stripping the comment so that f9dasm's "' " encoding
        # (single-quote then space) for 0x20 is converted before the leading
        # spaces of "  ;..." are consumed by the comment stripper.
        op = re.sub(r"'(.)", lambda m: f'${ord(m.group(1)):02X}', op)
        # A trailing lone "'" remains when the space in "' " was at the very
        # end of the field abutting the comment separator; treat it as $27.
        op = re.sub(r"'$", '$27', op)

        # Strip f9dasm noise comment inside the operand field
        op = _NOISE_COMMENT.sub('', op).strip()

        # Is this an immediate operand?
        is_imm = op.startswith('#')

        # ── replace all identifier tokens ──────────────────────────────────
        def _repl(m: re.Match) -> str:
            tok = m.group(0)
            tl  = tok.lower()
            # Register names → force lowercase
            if tl in REGS:
                return tl
            # Keep known assembler keywords
            if tl in {'start', 'size', 'name', 'eom', 'edition'}:
                return tl
            # OS-9 service call names (F$SUser, I$Write, etc.) contain '$' and
            # must keep their exact case to match definitions in os9.d.
            if '$' in tok:
                return tok
            return norm_lbl(tok, in_immediate=is_imm)

        # Include '$' in the identifier pattern so OS-9 call names like
        # F$SUser are matched as a single token (not split at the '$').
        op = re.sub(r'[A-Za-z][A-Za-z0-9_$]*', _repl, op)

        # lwasm treats '$00,R' (hex zero) differently from '0,R' (decimal zero)
        # for indexed addressing: '$00,R' → canonical zero-offset post-byte
        # ($84/$A4/etc.) while '0,R' → 5-bit form ($00/$20/etc.).  The
        # original Microware binaries use the 5-bit form, so convert all
        # '$00,R' to '0,R' here.
        op = re.sub(r'\$00,([XYUSxyus]\b)', lambda m: f'0,{m.group(1).lower()}', op)

        return op

        # ── force 16-bit indirect indexed addressing ─────────────────────────
        # f9dasm uses M-labels (which become $XXXX 4-digit hex) for 16-bit
        # indirect indexed post-bytes ($B9/$D9/$F9/$99 etc.) and uses raw
        # hex literals ($XX 1-2 digits) for 8-bit forms ($B8/$D8/$F8/$98).
        # Likewise, L-labels inside brackets were 16-bit in the original.
        # Without '>', lwasm auto-selects 8-bit when the value fits, producing
        # shorter (wrong) code.  Add '>' inside the brackets to force 16-bit.
        op = re.sub(
            r'\[([>]?)(\$[0-9A-Fa-f]{4}|L[0-9A-Fa-f]{4}),([XYUSxyus])\]',
            lambda m: f'[>{m.group(2)},{m.group(3)}]',
            op)

        return op

    # ── column formatter ────────────────────────────────────────────────────
    C_LABEL = 20
    C_MNEM  = 10

    def fmt(label: str, mnem: str, operand: str, comment: str = '') -> str:
        s = label.ljust(C_LABEL) + mnem.ljust(C_MNEM)
        if operand:
            s += operand
        if comment:
            s = s.ljust(C_LABEL + C_MNEM + 20) + comment
        return s.rstrip()

    # ── skip-line predicates ────────────────────────────────────────────────
    SKIP = [
        re.compile(r'^\s*$'),
        re.compile(r'^f9dasm:'),
        re.compile(r'^Loaded'),
        re.compile(r'^\*[\s*]'),
        re.compile(r'^\s*ORG\s'),
        re.compile(r'^\s*END\s*$'),
    ]

    def skip(line: str) -> bool:
        return any(p.match(line) for p in SKIP)

    # ── pre-pass: detect instructions that straddle the CRC boundary ─────────
    # An instruction that starts before crc_start but whose next instruction
    # starts PAST crc_start extends into the CRC area.  We cannot simply emit
    # it; instead we replace it with raw fcb bytes for the pre-CRC portion and
    # let emod regenerate the CRC.
    _idx_addr: list[tuple[int, int]] = []   # (line_index, module_address)
    for _i, _line in enumerate(lines_raw):
        if skip(_line):
            continue
        if re.match(r'^[A-Za-z][0-9A-Fa-f]{4}\s+EQU\s', _line):
            continue
        _am = re.search(r';\s*([0-9A-Fa-f]{4})\b', _line)
        if _am:
            _idx_addr.append((_i, int(_am.group(1), 16)))
        else:
            _lm = re.match(r'^([MZ])([0-9A-Fa-f]{4})\s', _line)
            if _lm:
                _idx_addr.append((_i, int(_lm.group(2), 16)))

    _crc_overlap: set[int] = set()
    for _k, (_li, _addr) in enumerate(_idx_addr):
        if _addr >= crc_start:
            continue
        if _k + 1 < len(_idx_addr) and _idx_addr[_k + 1][1] > crc_start:
            _crc_overlap.add(_li)

    # ── build output ─────────────────────────────────────────────────────────
    out: list[str] = []

    # Module header
    out += [
        fmt('', 'nam', mod_name),
        fmt('', 'ttl', 'program module'),
        '',
        fmt('', 'use', 'defsfile'),
        '',
        fmt('tylg', 'set', tylg_val),
        fmt('atrv', 'set', atrv_val),
        fmt('rev', 'set', f'${rev:02X}'),
        fmt('edition', 'set', f'${edition:02X}'),
        '',
        fmt('', 'mod', 'eom,name,tylg,atrv,start,size'),
        '',
    ]
    if data_size > 0:
        out.append(fmt('u0000', 'rmb', str(data_size)))
    out += [
        fmt('size', 'equ', '.'),
        '',
        fmt('name', 'equ', '*'),
        fmt('', 'fcs', f'/{mod_name}/'),
        fmt('', 'fcb', 'edition'),
        '',
    ]

    current_addr: Optional[int] = None
    prev_mnem = ''   # for deciding when to emit a blank separator line

    for _line_idx, line in enumerate(lines_raw):
        if skip(line):
            continue

        # Skip EQU lines entirely
        if re.match(r'^[A-Za-z][0-9A-Fa-f]{4}\s+EQU\s', line):
            continue

        # Parse: [label]  mnemonic  [rest]
        pm = re.match(
            r'^([A-Za-z_][A-Za-z0-9_.]*)?'
            r'\s+'
            r'([A-Za-z][A-Za-z0-9]*)'
            r'(?:\s+(.*?))?'
            r'\s*$',
            line)
        if not pm:
            continue

        raw_label = (pm.group(1) or '').strip()
        raw_mnem  = pm.group(2).strip()
        raw_rest  = (pm.group(3) or '').strip()

        # Extract the module address from the f9dasm trailing comment (format
        # "; ADDR  'ASCII'" — emitted when OPTION noaddr is NOT set in the
        # info file).  This gives us an accurate address for every instruction,
        # including unlabelled ones that follow a labelled instruction.
        addr_m = re.search(r';\s*([0-9A-Fa-f]{4})\b', raw_rest)
        if addr_m:
            current_addr = int(addr_m.group(1), 16)

        mnem = raw_mnem.lower()

        # Track current module offset from the label (fallback when no comment)
        lm = re.match(r'^[MZ]([0-9A-Fa-f]{4})$', raw_label)
        if lm:
            current_addr = int(lm.group(1), 16)
        elif raw_label.lower() == 'start':
            current_addr = exec_off

        # Suppress header FCB/FCC/FDB rows (replaced by mod/fcs/fcb edition)
        if current_addr is not None and current_addr <= edition_off:
            if mnem in ('fcb', 'fcc', 'fdb', 'rmb'):
                continue

        # Suppress the 3 CRC bytes at the end of the module.
        # emod recalculates and emits the CRC; we must not include these bytes.
        # Also handle instructions that START before crc_start but EXTEND into
        # the CRC area: replace them with raw fcb bytes for the content portion.
        if current_addr is not None:
            if current_addr >= crc_start:
                continue
            if _line_idx in _crc_overlap:
                # Determine the label for this line
                if raw_label:
                    if raw_label.lower() == 'start':
                        _fcb_label = 'start'
                    else:
                        _fcb_label = norm_lbl(raw_label)
                else:
                    _fcb_label = ''
                # Emit only the bytes before the CRC boundary
                pre_crc = data[current_addr:crc_start] if data else b''
                if pre_crc:
                    byte_str = ','.join(f'${b:02X}' for b in pre_crc)
                    out.append(fmt(_fcb_label, 'fcb', byte_str))
                continue

        # Normalise label
        if raw_label:
            if raw_label.lower() == 'start':
                label_out = 'start'
            else:
                label_out = norm_lbl(raw_label)
        else:
            label_out = ''

        # Normalise operand
        operand = rewrite_op(raw_rest, mnem)

        # ── blank line logic ────────────────────────────────────────────────
        # Emit a blank line before a labelled instruction when the previous
        # instruction was a flow terminator (rts, bra, etc.) to create natural
        # function boundaries.  Don't spam blank lines everywhere.
        if label_out and mnem not in ('fcb', 'fcc', 'fdb', 'rmb', 'equ'):
            if prev_mnem in TERMINATORS:
                out.append('')

        # ── OS-9 trap ────────────────────────────────────────────────────────
        if mnem == 'os9':
            out.append(fmt(label_out, 'os9', operand))
            prev_mnem = 'os9'
            continue

        # ── pshu with no registers ($36,$00) ─────────────────────────────────
        # f9dasm emits "PSHU" with an empty operand for byte $36 $00.
        # lwasm requires at least one register name, so use fcb instead.
        if mnem == 'pshu' and not operand:
            out.append(fmt(label_out, 'fcb', '$36,$00'))
            prev_mnem = 'fcb'
            continue

        # ── tfr/exg with unknown register ("??") ──────────────────────────────
        # f9dasm emits "??" when the inter-register operand byte contains an
        # undefined register code (e.g. code 7 = W in 6309, but undefined in
        # 6809 mode).  lwasm rejects "??"; emit the raw bytes instead.
        if mnem in ('tfr', 'exg') and '??' in operand:
            _REG_NIBBLE = {
                'd': 0, 'x': 1, 'y': 2, 'u': 3, 's': 4, 'pc': 5,
                'a': 8, 'b': 9, 'cc': 0xA, 'dp': 0xB,
            }
            _opbyte = 0x1F if mnem == 'tfr' else 0x1E
            import re as _re
            _m = _re.match(r'^([^,]+),\?{2}$', operand.strip())
            if _m:
                _rn = _m.group(1).strip().lower()
                _hi = _REG_NIBBLE.get(_rn, 0xF)
                _lo = 7   # unknown register code 7
                out.append(fmt(label_out, 'fcb', f'${_opbyte:02X},${(_hi<<4)|_lo:02X}'))
            else:
                _m2 = _re.match(r'^\?{2},([^,]+)$', operand.strip())
                if _m2:
                    _rn = _m2.group(1).strip().lower()
                    _lo = _REG_NIBBLE.get(_rn, 0xF)
                    out.append(fmt(label_out, 'fcb', f'${_opbyte:02X},${0x70|_lo:02X}'))
                else:
                    # Fallback: just emit as comment + fcb
                    out.append(fmt(label_out, 'fcb', f'${_opbyte:02X},$07'))
            prev_mnem = 'fcb'
            continue

        # ── reset ($3E) — undocumented 6809 opcode ────────────────────────────
        # f9dasm emits "RESET" for byte $3E; lwasm does not support this
        # mnemonic (it is only accepted in 6309 mode but means something
        # different there).  Emit as a raw fcb byte.
        if mnem == 'reset':
            out.append(fmt(label_out, 'fcb', '$3E'))
            prev_mnem = 'fcb'
            continue

        # PULS/PULU pc terminates flow
        if mnem in ('puls', 'pulu'):
            if operand and 'pc' in operand.lower():
                prev_mnem = 'rts'  # treated as terminator
            else:
                prev_mnem = mnem

        out.append(fmt(label_out, mnem, operand))
        prev_mnem = mnem

    # End of module — emod emits the 3-byte CRC; eom is defined AFTER emod so
    # it captures the address past the CRC, giving the total module size as
    # the size field (matching the NitrOS-9/Microware convention).
    out += [
        '',
        fmt('', 'emod', ''),
        fmt('eom', 'equ', '*'),
        fmt('', 'end', ''),
        '',
    ]

    return '\n'.join(out)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    ap = argparse.ArgumentParser(
        description='Disassemble OS-9 FCB-format .asm → lwasm-compatible .asm')
    ap.add_argument('input',   help='Input file (.asm FCB-format or .bin with --binary)')
    ap.add_argument('-o', '--output', help='Output file (default: stdout)')
    ap.add_argument('-b', '--binary', action='store_true',
                    help='Input is a raw OS-9 binary, not an FCB-format .asm')
    ap.add_argument('-f', '--f9dasm', default='f9dasm',
                    help='Path to f9dasm binary (default: f9dasm in PATH)')
    args = ap.parse_args()

    # 1. extract binary
    if args.binary:
        try:
            with open(args.input, 'rb') as fh:
                data = fh.read()
        except OSError as e:
            sys.exit(f'error reading {args.input}: {e}')
    else:
        try:
            data = parse_fcb_file(args.input)
        except Exception as e:
            sys.exit(f'error reading {args.input}: {e}')
        if not data:
            sys.exit(f'no FCB data found in {args.input}')

    # 2. parse header
    try:
        hdr = parse_os9_header(data)
    except ValueError as e:
        sys.exit(f'OS-9 header error: {e}')

    print(f'Module: {hdr["mod_name"]}  '
          f'size=${hdr["mod_size"]:04X}  '
          f'exec=${hdr["exec_off"]:04X}  '
          f'data=${hdr["data_size"]:04X}',
          file=sys.stderr)

    with tempfile.TemporaryDirectory() as tmpdir:
        bin_path  = os.path.join(tmpdir, 'module.bin')
        info_path = os.path.join(tmpdir, 'module.info')

        with open(bin_path,  'wb') as fh:
            fh.write(data)
        with open(info_path, 'w') as fh:
            fh.write(make_info(hdr, data))

        # 4. run f9dasm
        try:
            result = subprocess.run(
                [args.f9dasm, '-info', info_path, bin_path],
                capture_output=True, text=True, check=False)
        except FileNotFoundError:
            sys.exit(f'f9dasm not found: {args.f9dasm}')

        raw_dis = result.stdout

    # 5. post-process
    lwasm_src = postprocess(raw_dis, hdr, data)

    if args.output:
        with open(args.output, 'w') as fh:
            fh.write(lwasm_src)
    else:
        sys.stdout.write(lwasm_src)


if __name__ == '__main__':
    main()
