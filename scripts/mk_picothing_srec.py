#!/usr/bin/env python3
"""
mk_picothing_srec.py - Generate S-record boot image for the Pico-Thing board.

Produces an SREC file on stdout that the Pico firmware loads into 6809 RAM
before releasing reset.  Contains:

  $EC00  boot_picothing module, padded to 512 bytes (= BOOT_MOD_PAD)
  $EE00  krn module (= Where / Bt.Start + BOOT_MOD_PAD)
  $FE00  DAT RAM: task 0 identity map (slot N -> physical page N)
  $FFF0  6809 hardware vectors

Boot memory layout after SREC load (task 0, identity-mapped):
  $EC00-$EDFF  boot_picothing (padded)   -- found by I.VBlock scan
  $EE00-$....  krn                        -- Where = $EE00
  $FE00-$FE07  DAT RAM task 0 image
  $FFF0-$FFFF  6809 vectors (if Pico reads from RAM; else configure in firmware)

Usage:
    python3 scripts/mk_picothing_srec.py [nitros9dir] > boot_picothing.srec

nitros9dir defaults to the current directory.
"""

import os
import struct
import sys

BOOT_MOD_ADDR = 0xEC00   # virtual/physical address for boot_picothing
BOOT_MOD_PAD  = 512      # pad boot_picothing to this many bytes
KRN_ADDR      = 0xEE00   # virtual/physical address for krn  (= Where)
DAT_RAM_ADDR  = 0xFE00   # DAT RAM base (32 tasks x 8 slots x 1 byte)
VEC_ADDR      = 0xFFF0   # 6809 hardware vector table start


# ---------------------------------------------------------------------------
# S-record helpers
# ---------------------------------------------------------------------------

def _srec(stype, address, data):
    """Build one S-record line.

    stype  -- single digit string: '0', '1', '9'
    address -- 16-bit integer
    data    -- bytes-like object (may be empty for S9)
    """
    body = bytes([
        2 + len(data) + 1,          # length: address(2) + data + checksum(1)
        (address >> 8) & 0xFF,
        address & 0xFF,
    ]) + bytes(data)
    checksum = (~sum(body)) & 0xFF
    return f'S{stype}{body.hex().upper()}{checksum:02X}'


def s0(text):
    """S0 header record (address = 0)."""
    return _srec('0', 0, text.encode('ascii'))


def s9(start_addr=0):
    """S9 end-of-file record."""
    return _srec('9', start_addr, b'')


def emit_block(address, data, chunk=32):
    """Yield S1 records for a block of data."""
    for offset in range(0, len(data), chunk):
        yield _srec('1', address + offset, data[offset:offset + chunk])


# ---------------------------------------------------------------------------
# OS-9 module header parsing
# ---------------------------------------------------------------------------

def parse_exec_offset(data):
    """Return the execution offset from an OS-9 module header."""
    if len(data) < 12:
        raise ValueError('module too small to have a valid header')
    if data[0] != 0x87 or data[1] != 0xCD:
        raise ValueError(f'not an OS-9 module (sync={data[0]:02X}{data[1]:02X})')
    return struct.unpack('>H', data[9:11])[0]


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    nitros9dir = sys.argv[1] if len(sys.argv) > 1 else '.'

    boot_path = os.path.join(nitros9dir, 'level2', 'picothing', 'modules', 'boot_picothing')
    krn_path  = os.path.join(nitros9dir, 'level2', 'picothing', 'modules', 'krn')

    # --- boot_picothing ---------------------------------------------------
    with open(boot_path, 'rb') as fh:
        boot_data = fh.read()
    print(f'boot_picothing: {len(boot_data)} bytes', file=sys.stderr)
    if len(boot_data) > BOOT_MOD_PAD:
        raise ValueError(
            f'boot_picothing ({len(boot_data)} bytes) exceeds padding '
            f'size {BOOT_MOD_PAD} -- increase BOOT_MOD_PAD or shrink the module'
        )
    boot_padded = boot_data + bytes(BOOT_MOD_PAD - len(boot_data))

    # --- krn --------------------------------------------------------------
    with open(krn_path, 'rb') as fh:
        krn_data = fh.read()
    print(f'krn:            {len(krn_data)} bytes', file=sys.stderr)
    exec_off = parse_exec_offset(krn_data)
    print(f'krn exec_off:   0x{exec_off:04X}', file=sys.stderr)

    # Sanity check: krn must start at KRN_ADDR = Where
    # entry is at KRN_ADDR + exec_off; Vectors handler is 3 bytes before entry
    # (a single 3-byte JMP instruction: "jmp [<offset,x]")
    reset_vec  = KRN_ADDR + exec_off
    others_vec = KRN_ADDR + exec_off - 3   # Vectors label = entry - 3
    print(f'RESET  vector:  ${reset_vec:04X}', file=sys.stderr)
    print(f'Others vector:  ${others_vec:04X}', file=sys.stderr)

    # Check that the boot area fits before DAT RAM
    boot_end = BOOT_MOD_ADDR + BOOT_MOD_PAD + len(krn_data)
    print(
        f'boot area:      ${BOOT_MOD_ADDR:04X}-${boot_end - 1:04X}  '
        f'(DAT RAM at ${DAT_RAM_ADDR:04X})',
        file=sys.stderr,
    )
    if boot_end > DAT_RAM_ADDR:
        raise ValueError(
            f'boot area ends at ${boot_end:04X}, overflowing into '
            f'DAT RAM at ${DAT_RAM_ADDR:04X}'
        )
    print(f'headroom:       {DAT_RAM_ADDR - boot_end} bytes', file=sys.stderr)

    # --- DAT RAM: task 0 identity map -------------------------------------
    # Slot N -> physical page N  (N = 0..7)
    # This gives the 6809 an identity mapping so virtual == physical.
    dat_data = bytes(range(8))

    # --- 6809 hardware vector table ($FFF0-$FFFF) -------------------------
    # $FFF0-FFF1: reserved   -> others_vec
    # $FFF2-FFF3: SWI3       -> others_vec
    # $FFF4-FFF5: SWI2       -> others_vec
    # $FFF6-FFF7: SWI        -> others_vec
    # $FFF8-FFF9: IRQ        -> others_vec
    # $FFFA-FFFB: FIRQ       -> others_vec
    # $FFFC-FFFD: NMI        -> others_vec
    # $FFFE-FFFF: RESET      -> reset_vec
    oh, ol = (others_vec >> 8) & 0xFF, others_vec & 0xFF
    rh, rl = (reset_vec  >> 8) & 0xFF, reset_vec  & 0xFF
    vec_data = bytearray()
    for _ in range(7):           # 7 pairs: reserved + SWI3/2, SWI, IRQ, FIRQ, NMI
        vec_data += bytes([oh, ol])
    vec_data += bytes([rh, rl])  # RESET

    # --- Emit SREC --------------------------------------------------------
    lines = [s0('Pico-Thing NitrOS-9 boot image')]

    lines += list(emit_block(BOOT_MOD_ADDR, boot_padded))
    lines += list(emit_block(KRN_ADDR,      krn_data))
    lines += list(emit_block(DAT_RAM_ADDR,  dat_data))
    lines += list(emit_block(VEC_ADDR,      vec_data))

    lines.append(s9(reset_vec))

    print('\n'.join(lines))
    print(f'total S1 records: {len(lines) - 2}', file=sys.stderr)


if __name__ == '__main__':
    main()
