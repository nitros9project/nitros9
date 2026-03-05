#!/usr/bin/env python3
"""
mk_picothing_srec.py - Generate S-record boot image for the Pico-Thing board.

Produces an SREC file on stdout that the Pico firmware loads into 6809 RAM
before releasing reset.  Contains:

  $E800  boot_picothing module, padded to 1024 bytes (= BOOT_MOD_PAD)
  $EC00  krn module (= Where / Bt.Start + BOOT_MOD_PAD)
  $FE00  DAT RAM: task 0 identity map (slot N -> physical page N)
  $FFF0  6809 hardware vectors

Boot memory layout after SREC load (task 0, identity-mapped):
  $E800-$EBFF  boot_picothing (padded)   -- found by I.VBlock scan
  $EC00-$....  krn                        -- Where = $EC00
  $FE00-$FE07  DAT RAM task 0 image
  $FFF0-$FFFF  6809 vectors (if Pico reads from RAM; else configure in firmware)

Usage:
    python3 scripts/mk_picothing_srec.py [nitros9dir] > boot_picothing.srec

nitros9dir defaults to the current directory.
"""

import os
import struct
import sys
from datetime import datetime

BOOT_MOD_ADDR = 0xE800   # virtual/physical address for boot_picothing
BOOT_MOD_PAD  = 1024     # pad boot_picothing to this many bytes
KRN_ADDR      = 0xEC00   # virtual/physical address for krn  (= Where)
DAT_RAM_ADDR  = 0xFE00   # DAT RAM base (32 tasks x 8 slots x 1 byte)
VEC_ADDR      = 0xFFF0   # 6809 hardware vector table start

# Level 2 page-zero D.X* interrupt vector variables (os9.d ORG $E0)
DPVAR_XSWI3   = 0x00E2
DPVAR_XSWI2   = 0x00E4
DPVAR_XFIRQ   = 0x00E6
DPVAR_XIRQ    = 0x00E8
DPVAR_XSWI    = 0x00EA
DPVAR_XNMI    = 0x00EC


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


def make_jmp_indirect(dpvar):
    """Build a 4-byte JMP [extended-indirect] stub for a page-zero D.X* variable.

    6809 encoding: $6E $9F addr_hi addr_lo
    At runtime the CPU reads the 2-byte address from dpvar and jumps there.
    This lets the kernel change D.XSWI2 etc. dynamically (SysCall vs XSWI2).
    """
    return bytes([0x6E, 0x9F, (dpvar >> 8) & 0xFF, dpvar & 0xFF])


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

    # The reset vector is the kernel entry point.
    reset_vec = KRN_ADDR + exec_off
    print(f'RESET  vector:  ${reset_vec:04X}', file=sys.stderr)

    # Parse the DisTable from the krn binary to get per-interrupt handler addresses.
    # DisTable is a sequence of 9 FDB entries (18 bytes) that the kernel copies to
    # D.Clock, D.XSWI3, D.XSWI2, D.XFIRQ, D.XIRQ, D.XSWI, D.XNMI, D.ErrRst, D.SVC.
    # Each entry is already an absolute address (handler offset + KRN_ADDR).
    # Locate DisTable by the D.Crash signature: $006B appears at entry[3] and entry[6],
    # and $0055 appears at entry[7].
    name_off = struct.unpack('>H', krn_data[4:6])[0]
    dis_off = None
    for i in range(name_off, exec_off - 18):
        if (krn_data[i + 6] == 0x00 and krn_data[i + 7] == 0x6B and
                krn_data[i + 12] == 0x00 and krn_data[i + 13] == 0x6B and
                krn_data[i + 14] == 0x00 and krn_data[i + 15] == 0x55):
            dis_off = i
            break
    if dis_off is None:
        raise ValueError('Cannot find DisTable in krn binary (D.Crash/D.ErrRst signature not found)')
    dis = [struct.unpack('>H', krn_data[dis_off + i*2: dis_off + i*2 + 2])[0] for i in range(9)]
    dis_labels = ['D.Clock', 'D.XSWI3', 'D.XSWI2', 'D.XFIRQ', 'D.XIRQ', 'D.XSWI', 'D.XNMI', 'D.ErrRst', 'D.SVC']
    print('DisTable:', file=sys.stderr)
    for label, val in zip(dis_labels, dis):
        print(f'  {label:10s} = ${val:04X}', file=sys.stderr)

    # --- Post-module data (SWIStack + interrupt stubs) --------------------
    # krn.asm's SWICall contains  leay <SWIStack,pc  which references the
    # SWIStack area immediately after emod via PC-relative addressing.
    # We must place the correct data there so the kernel can copy the
    # register stack during user-state SWI2 processing.
    #
    # After SWIStack we place JMP [>D.Xxx] stubs for the hardware vectors.
    # The Pico firmware may or may not use the vectors at $FFF0-$FFFF.
    # The krn XSWI2 handler now has a picothing-specific patch that reads B
    # and dispatches system-state calls via SysCall, so the stubs are
    # belt-and-suspenders for the case where the firmware does honour them.
    swistack_addr = KRN_ADDR + len(krn_data)
    # SWIStack: must match krn.asm's  fcc /REGISTER STACK/  (14 bytes for 6809)
    # followed by $55 (D.ErrRst marker).  SWICall references this via
    # leay <SWIStack,pc — the PC-relative offset is baked into the krn binary.
    swistack_data = b'REGISTER STACK' + bytes([0x55])   # 15 bytes

    stub_addr = swistack_addr + len(swistack_data)
    stub_data = (
        make_jmp_indirect(DPVAR_XSWI3) +           # +0  SWI3 stub  (4 bytes)
        make_jmp_indirect(DPVAR_XSWI2) +            # +4  SWI2 stub  (4 bytes)
        make_jmp_indirect(DPVAR_XSWI)  +            # +8  SWI  stub  (4 bytes)
        make_jmp_indirect(DPVAR_XIRQ)  +            # +12 IRQ  stub  (4 bytes)
        make_jmp_indirect(DPVAR_XFIRQ) +            # +16 FIRQ stub  (4 bytes)
        make_jmp_indirect(DPVAR_XNMI)               # +20 NMI  stub  (4 bytes)
    )
    print(f'SWIStack:       ${swistack_addr:04X}-${swistack_addr + len(swistack_data) - 1:04X}  '
          f'({len(swistack_data)} bytes)', file=sys.stderr)
    print(f'stubs:          ${stub_addr:04X}-${stub_addr + len(stub_data) - 1:04X}  '
          f'({len(stub_data)} bytes, 6 x JMP [>D.Xxx])', file=sys.stderr)

    # Check that the boot area + post-module data fits before DAT RAM
    boot_end = stub_addr + len(stub_data)
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
    # Each vector points to the corresponding indirect-jump stub above so the
    # kernel can dynamically reroute interrupts by updating D.XSWI2 etc.
    # $FFF0-FFF1: reserved -> RESET (safe fallback)
    # $FFF2-FFF3: SWI3     -> stub → JMP [>D.XSWI3]
    # $FFF4-FFF5: SWI2     -> stub → JMP [>D.XSWI2]
    # $FFF6-FFF7: SWI      -> stub → JMP [>D.XSWI]
    # $FFF8-FFF9: IRQ      -> stub → JMP [>D.XIRQ]
    # $FFFA-FFFB: FIRQ     -> stub → JMP [>D.XFIRQ]
    # $FFFC-FFFD: NMI      -> stub → JMP [>D.XNMI]
    # $FFFE-FFFF: RESET    -> reset_vec
    def w(v):
        return bytes([(v >> 8) & 0xFF, v & 0xFF])
    vec_data = (
        w(reset_vec)        +   # $FFF0 reserved → RESET
        w(stub_addr + 0)    +   # $FFF2 SWI3
        w(stub_addr + 4)    +   # $FFF4 SWI2
        w(stub_addr + 8)    +   # $FFF6 SWI
        w(stub_addr + 12)   +   # $FFF8 IRQ
        w(stub_addr + 16)   +   # $FFFA FIRQ
        w(stub_addr + 20)   +   # $FFFC NMI
        w(reset_vec)            # $FFFE RESET
    )

    # --- Emit SREC --------------------------------------------------------
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    lines = [s0(f'Pico-Thing NitrOS-9 {timestamp}')]

    lines += list(emit_block(BOOT_MOD_ADDR, boot_padded))
    lines += list(emit_block(KRN_ADDR,      krn_data))
    lines += list(emit_block(swistack_addr, swistack_data))
    lines += list(emit_block(stub_addr,     stub_data))
    lines += list(emit_block(DAT_RAM_ADDR,  dat_data))
    lines += list(emit_block(VEC_ADDR,      vec_data))

    lines.append(s9(reset_vec))

    print('\n'.join(lines))
    print(f'total S1 records: {len(lines) - 2}', file=sys.stderr)


if __name__ == '__main__':
    main()
