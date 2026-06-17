#!/usr/bin/env python3
"""
mk_diskload_srec.py - Package diskload.bin as a standalone Pico-Thing SREC.

Produces an SREC file that the Pico loads into 6809 RAM before releasing
reset, without any NitrOS-9 modules.  Contains:

  $0200  diskload binary (CMOC --coco-basic output, header stripped)
  $FE00  DAT RAM: task 0 identity map
  $FFF0  6809 hardware vectors, all pointing to LOAD_ADDR

Usage:
    # 1. Compile diskload.c with CMOC:
    cmoc --coco-basic --org=0x0200 -o diskload.bin scripts/diskload.c

    # 2. Generate SREC:
    python3 scripts/mk_diskload_srec.py diskload.bin > diskload.srec

Notes:
    - CMOC --coco-basic prepends a 5-byte DECB header ($00 + 4 address bytes)
      which this script strips automatically.
    - The stack is set up by CMOC's startup code embedded in the binary.
    - LOAD_ADDR must match the --org value used with CMOC.
"""

import sys

LOAD_ADDR = 0x0200   # must match --org in the cmoc invocation
DAT_ADDR  = 0xFE00   # DAT RAM: task 0 identity mapping
VEC_ADDR  = 0xFFF0   # 6809 hardware vector table


def make_srec(stype, address, data):
    body = bytes([2 + len(data) + 1, (address >> 8) & 0xFF, address & 0xFF]) + bytes(data)
    ck = (~sum(body)) & 0xFF
    return f'S{stype}{body.hex().upper()}{ck:02X}'


def emit(address, data, chunk=32):
    for i in range(0, len(data), chunk):
        yield make_srec('1', address + i, data[i:i + chunk])


def main():
    path = sys.argv[1] if len(sys.argv) > 1 else 'diskload.bin'

    with open(path, 'rb') as fh:
        binary = fh.read()

    # Strip the 5-byte DECB header that CMOC --coco-basic prepends
    if len(binary) > 5 and binary[0] == 0x00:
        print(f'Stripping 5-byte DECB header', file=sys.stderr)
        binary = binary[5:]

    print(f'diskload: {len(binary)} bytes at ${LOAD_ADDR:04X}', file=sys.stderr)

    # DAT RAM: task 0 identity map (slot N -> physical page N)
    dat = bytes(range(8))

    # All 8 hardware vectors point to LOAD_ADDR (RESET + trap handler)
    rh = (LOAD_ADDR >> 8) & 0xFF
    rl = LOAD_ADDR & 0xFF
    vec = bytes([rh, rl] * 8)

    lines = [make_srec('0', 0, b'Pico-Thing diskload')]
    lines += list(emit(LOAD_ADDR, binary))
    lines += list(emit(DAT_ADDR, dat))
    lines += list(emit(VEC_ADDR, vec))
    lines.append(make_srec('9', LOAD_ADDR, b''))

    print('\n'.join(lines))
    print(f'Total S1 records: {len(lines) - 2}', file=sys.stderr)


if __name__ == '__main__':
    main()
