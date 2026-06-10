#!/usr/bin/env python3
"""asm-normalize: normalize 6809/6309 assembly source to one-space rule.

Each field (label, opcode, operand, comment) is separated by exactly one
space.  Content inside string directive delimiters is preserved verbatim.
Lines whose first non-whitespace character is *, ;, or # are passed through
unchanged, as are blank lines.

Usage:
  Single file (in-place):  asm-normalize.py file.asm [file2.asm ...]
  Filter (stdin→stdout):   asm-normalize.py
"""

import os
import re
import sys

# Directives whose operand is a delimited string; internal spaces must be kept.
STRING_DIRECTIVES = frozenset({
    'fcc', 'fcs', 'fcn', 'fct', 'fcs2',
})

# If the first operand character matches this pattern it is NOT a string
# delimiter — fall back to plain token parsing instead.
# % and $ are only non-delimiters when followed by their numeric digit sets
# (%[01] = binary literal, $[0-9A-Fa-f] = hex literal); bare % or $ IS a
# valid fcc/fcs delimiter and must be treated as such.
_NOT_A_DELIM = re.compile(r'^(?:\w|[$&@]|%[01])')


def _normalize_line(line: str) -> str:
    # Preserve line ending
    if line.endswith('\r\n'):
        eol, line = '\r\n', line[:-2]
    elif line.endswith('\n'):
        eol, line = '\n', line[:-1]
    else:
        eol = ''

    # Blank line
    if not line.strip():
        return eol

    # Comment / preprocessor directive: *, ;, or # as first non-whitespace char
    first_nws = line.lstrip()
    if first_nws[0] in ('*', ';', '#'):
        return line + eol

    # --- Parse label -------------------------------------------------------
    label = ''
    if line[0] not in (' ', '\t'):
        m = re.match(r'(\S+)[ \t]*(.*)', line)
        if not m:
            return line.rstrip() + eol     # label-only line
        label, rest = m.group(1), m.group(2)
    else:
        rest = line.lstrip()

    # --- Parse opcode -------------------------------------------------------
    rest = rest.lstrip()
    if not rest:
        return label + eol                 # label with nothing after it

    m = re.match(r'(\S+)[ \t]*(.*)', rest)
    if not m:
        pfx = (label + ' ') if label else ' '
        return pfx + rest + eol

    opcode, rest = m.group(1), m.group(2)

    # --- Parse operand (and comment) ----------------------------------------
    operand = ''
    comment = ''
    rest = rest.lstrip()

    if rest:
        if opcode.lower() in STRING_DIRECTIVES and not _NOT_A_DELIM.match(rest):
            # Delimited string: preserve everything between the two delimiters
            delim = rest[0]
            close = rest.find(delim, 1)
            if close != -1:
                operand = rest[:close + 1]
                comment = rest[close + 1:].lstrip()
            else:
                operand = rest              # malformed: no closing delimiter
        else:
            m = re.match(r'(\S+)[ \t]*(.*)', rest)
            if m:
                operand = m.group(1)
                comment = m.group(2).strip()

    # --- Reconstruct with single spaces -------------------------------------
    tokens = [t for t in (opcode, operand, comment) if t]
    body = ' '.join(tokens)

    if label:
        result = label + (' ' + body if body else '')
    else:
        result = (' ' + body) if body else ''

    return result + eol


def normalize_file(path: str) -> None:
    with open(path, 'r', encoding='latin-1') as fh:
        lines = fh.readlines()
    normalized = [_normalize_line(l) for l in lines]
    # Write to a sibling temp file first; rename atomically so a failure
    # never leaves the original file truncated or partially written.
    tmp = path + '.norm~'
    try:
        with open(tmp, 'w', encoding='latin-1') as fh:
            fh.writelines(normalized)
        os.replace(tmp, path)
    except Exception:
        try:
            os.unlink(tmp)
        except OSError:
            pass
        raise


def normalize_stream(fin, fout) -> None:
    for line in fin:
        fout.write(_normalize_line(line))


if __name__ == '__main__':
    if len(sys.argv) == 1:
        normalize_stream(sys.stdin, sys.stdout)
    else:
        for path in sys.argv[1:]:
            normalize_file(path)
