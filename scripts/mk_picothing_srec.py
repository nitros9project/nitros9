#!/usr/bin/env python3
"""
mk_picothing_srec.py - Generate S-record boot image for the Pico-Thing board.

Produces an SREC file on stdout that the Pico firmware loads into 6809 RAM
before releasing reset.  Contains:

  $E800  boot_picothing module, padded to 1024 bytes (= BOOT_MOD_PAD)
  $EC00  krn module (= Where / Bt.Start + BOOT_MOD_PAD)
  $FC00  dbgmon debug monitor (512 bytes, optional)
  $FE00  DAT RAM: task 0 identity map (slot N -> physical page N)
  $FFF0  6809 hardware vectors

Boot memory layout after SREC load (task 0, identity-mapped):
  $E800-$EBFF  boot_picothing (padded)   -- found by I.VBlock scan
  $EC00-$....  krn                        -- Where = $EC00
  $FE00-$FEFF  DAT RAM (32 tasks x 8 slots)
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
DBGMON_ADDR   = 0xFC00   # debug monitor routines (512 bytes)
DAT_RAM_ADDR  = 0xFE00   # DAT RAM base (32 tasks x 8 slots x 1 byte)
DAT_TASK_CT   = 32       # number of hardware task slots
DAT_RAM_SIZE  = DAT_TASK_CT * 8  # 256 bytes total
KRN_PAGE      = 0x07     # physical page holding the kernel (slot 7)
VEC_ADDR      = 0xFFF0   # 6809 hardware vector table start

# Number of BRA+NOP stubs at the end of the krn module (before CRC).
# Order: SWI3, SWI2, FIRQ, IRQ, SWI, NMI — each 3 bytes (BRA rel + NOP).
KRN_VCT_STUB_CT = 6
KRN_VCT_STUB_SZ = 3   # bytes per stub (BRA + offset + NOP)
KRN_CRC_SZ      = 3   # OS-9 module CRC size


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


ACIA_DATA = 0xFFC4   # Pico-Thing ACIA data register for debug output
DAT_TASK  = 0xFFC0   # Pico-Thing DAT task register


def make_jmp_stub(target_addr, debug_char=None):
    """Build a stub that JMPs to the kernel's VCT handler.

    On Pico-Thing, the kernel code (slot 7 = KrnBlk) is visible in ALL
    hardware tasks, just like CoCo3's constant block.  Stubs must NOT
    switch to task 0 — the VCT handlers do it at the right point.

    This is critical for SWI/SWI2/SWI3: SWICall reads [R$PC,s] (user
    memory) BEFORE switching to task 0 at line 1470.  If the stub
    switches early, SWICall reads garbage from task 0's mapping.

    For IRQ/FIRQ/NMI, the L0EB8 handler switches to task 0 immediately,
    so the stub doesn't need to either.

    Encoding:
      [optional debug: LDA #char $86 ch + STA >ACIA.Data $B7 hi lo = 5 bytes]
      JMP >target     $7E hi lo        (3 bytes)
    """
    code = b''
    if debug_char is not None:
        code += bytes([
            0x86, ord(debug_char),                  # LDA #char
            0xB7, (ACIA_DATA >> 8) & 0xFF, ACIA_DATA & 0xFF,  # STA >ACIA.Data
        ])
    code += bytes([0x7E, (target_addr >> 8) & 0xFF, target_addr & 0xFF])
    return code


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

    boot_path   = os.path.join(nitros9dir, 'level2', 'picothing', 'modules', 'boot_picothing')
    krn_path    = os.path.join(nitros9dir, 'level2', 'picothing', 'modules', 'krn')
    dbgmon_path = os.path.join(nitros9dir, 'level2', 'picothing', 'modules', 'dbgmon')

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

    # Parse the BRA stubs at the end of the krn module.
    # The last thing before emod/CRC is a table of 6 BRA+NOP pairs:
    #   bra SWI3VCT / nop
    #   bra SWI2VCT / nop
    #   bra FIRQVCT / nop
    #   bra IRQVCT  / nop
    #   bra SWIVCT  / nop
    #   bra NMIVCT  / nop
    # On CoCo3, these end up in the "constant block" ($FExx) and the
    # hardware vectors at $FFF0 point to them.  We parse the BRA targets
    # to get the absolute addresses of SWI2VCT, IRQVCT, etc.
    #
    # The BRA stubs are in the POST-MODULE area (after emod, before end),
    # so they live at the very end of the file, not inside the module.
    module_size = struct.unpack('>H', krn_data[2:4])[0]
    stubs_off = len(krn_data) - KRN_VCT_STUB_CT * KRN_VCT_STUB_SZ
    vct_names = ['SWI3VCT', 'SWI2VCT', 'FIRQVCT', 'IRQVCT', 'SWIVCT', 'NMIVCT']
    vct_addrs = {}
    print('VCT stubs (from BRA table):', file=sys.stderr)
    for i, name in enumerate(vct_names):
        off = stubs_off + i * KRN_VCT_STUB_SZ
        opcode = krn_data[off]
        if opcode != 0x20:
            raise ValueError(
                f'Expected BRA ($20) at stub {name} offset {off:#x}, '
                f'got ${opcode:02X}'
            )
        # BRA is PC-relative: target = (stub_offset + 2) + signed_byte_offset
        bra_rel = struct.unpack('b', krn_data[off+1:off+2])[0]
        target_off = off + 2 + bra_rel
        target_abs = KRN_ADDR + target_off
        vct_addrs[name] = target_abs
        print(f'  {name:10s} = ${target_abs:04X}', file=sys.stderr)

    # --- dbgmon (debug monitor) -------------------------------------------
    if os.path.exists(dbgmon_path):
        with open(dbgmon_path, 'rb') as fh:
            dbgmon_data = fh.read()
        print(f'dbgmon:         {len(dbgmon_data)} bytes @ ${DBGMON_ADDR:04X}', file=sys.stderr)
        dbgmon_end = DBGMON_ADDR + len(dbgmon_data)
        if dbgmon_end > DAT_RAM_ADDR:
            raise ValueError(
                f'dbgmon ends at ${dbgmon_end:04X}, overflowing into '
                f'DAT RAM at ${DAT_RAM_ADDR:04X}'
            )
    else:
        dbgmon_data = None
        print('dbgmon:         not found, skipping', file=sys.stderr)

    # --- Post-module data (SWIStack + interrupt stubs) --------------------
    # krn.asm's SWICall contains  leay <SWIStack,pc  which references the
    # SWIStack area immediately after emod via PC-relative addressing.
    # We must place the correct data there so the kernel can copy the
    # register stack during user-state SWI2 processing.
    #
    # After SWIStack we place interrupt stubs for the hardware vectors.
    # Each stub forces task 0 then JMPs directly to the kernel's VCT
    # handler (SWI2VCT, IRQVCT, etc.) — the same targets that CoCo3's
    # constant-block BRA stubs branch to.  This ensures all SWI2s go
    # through SWI2VCT → SWICall (which sets DP=0 and handles task
    # switching), rather than through the software D.XSWI2 variable
    # which changes at runtime.
    swistack_addr = KRN_ADDR + len(krn_data)
    # SWIStack: must match krn.asm's  fcc /REGISTER STACK/  (14 bytes for 6809)
    # followed by $55 (D.ErrRst marker).  SWICall references this via
    # leay <SWIStack,pc — the PC-relative offset is baked into the krn binary.
    swistack_data = b'REGISTER STACK' + bytes([0x55])   # 15 bytes

    stub_addr = swistack_addr + len(swistack_data)
    # Build each stub individually so we can compute offsets for the vector table.
    # Stubs do NOT switch tasks — VCT handlers do it at the right point.
    # This is critical for SWI/SWI2/SWI3: SWICall must read [R$PC,s] from
    # the user's task before switching to task 0.
    stubs = [
        ('SWI3', make_jmp_stub(vct_addrs['SWI3VCT'])),
        ('SWI2', make_jmp_stub(vct_addrs['SWI2VCT'])),
        ('SWI',  make_jmp_stub(vct_addrs['SWIVCT'])),
        ('IRQ',  make_jmp_stub(vct_addrs['IRQVCT'])),
        ('FIRQ', make_jmp_stub(vct_addrs['FIRQVCT'])),
        ('NMI',  make_jmp_stub(vct_addrs['NMIVCT'])),
    ]
    # Compute each stub's starting address.
    stub_offsets = {}
    offset = 0
    for name, data in stubs:
        stub_offsets[name] = stub_addr + offset
        offset += len(data)
    stub_data = b''.join(data for _, data in stubs)

    print(f'SWIStack:       ${swistack_addr:04X}-${swistack_addr + len(swistack_data) - 1:04X}  '
          f'({len(swistack_data)} bytes)', file=sys.stderr)
    print(f'stubs:          ${stub_addr:04X}-${stub_addr + len(stub_data) - 1:04X}  '
          f'({len(stub_data)} bytes)', file=sys.stderr)
    for name, _ in stubs:
        print(f'  {name:5s} stub @ ${stub_offsets[name]:04X}  ({len(dict(stubs)[name])} bytes)',
              file=sys.stderr)

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

    # --- DAT RAM --------------------------------------------------------------
    # DAT RAM ($FE00-$FEFF) is NOT written by the SREC — the Pico firmware
    # protects it.  Instead, the kernel init code in krn.asm initializes
    # tasks 1-31 (slot 7 = KrnBlk, slots 0-6 = 0).  Task 0 is identity-
    # mapped by the Pico firmware at power-on.

    # --- 6809 hardware vector table ($FFF0-$FFFF) -------------------------
    # Each vector points to the corresponding stub above.  Stubs just JMP
    # to the kernel's VCT handler (like CoCo3's constant-block BRA stubs).
    # The VCT handlers switch tasks at the right point.
    #
    # 6809/6309 vector layout:
    #   $FFF0  Reserved (6309: illegal opcode / div-by-zero trap)
    #   $FFF2  SWI3    $FFF4  SWI2    $FFF6  FIRQ
    #   $FFF8  IRQ         $FFFA  SWI     $FFFC  NMI     $FFFE  RESET
    DBGMON_ILLOP = DBGMON_ADDR + 0x12   # DBG.IllegalOp entry point
    def w(v):
        return bytes([(v >> 8) & 0xFF, v & 0xFF])
    vec_data = (
        w(DBGMON_ILLOP)             +   # $FFF0 6309 illegal opcode trap → dbgmon
        w(stub_offsets['SWI3'])     +   # $FFF2 SWI3
        w(stub_offsets['SWI2'])     +   # $FFF4 SWI2
        w(stub_offsets['FIRQ'])     +   # $FFF6 FIRQ
        w(stub_offsets['IRQ'])      +   # $FFF8 IRQ
        w(stub_offsets['SWI'])      +   # $FFFA SWI
        w(stub_offsets['NMI'])      +   # $FFFC NMI
        w(reset_vec)                    # $FFFE RESET
    )

    # --- Emit SREC --------------------------------------------------------
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    lines = [s0(f'Pico-Thing NitrOS-9 {timestamp}')]

    lines += list(emit_block(BOOT_MOD_ADDR, boot_padded))
    lines += list(emit_block(KRN_ADDR,      krn_data))
    lines += list(emit_block(swistack_addr, swistack_data))
    lines += list(emit_block(stub_addr,     stub_data))
    if dbgmon_data is not None:
        lines += list(emit_block(DBGMON_ADDR, dbgmon_data))
    lines += list(emit_block(VEC_ADDR,      vec_data))

    lines.append(s9(reset_vec))

    print('\n'.join(lines))
    print(f'total S1 records: {len(lines) - 2}', file=sys.stderr)


if __name__ == '__main__':
    main()
