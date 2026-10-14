# i-MMU-nity port-specific modules

Sources here override same-named files elsewhere on the recipe vpath
(`level2/immunity/modules` is searched first when `PORT=immunity`).

- `rel.asm`: REL for the CoCo 1/2. It sets up the MMU and the alternate
  vectors, puts up the boot screen and debug output, and copies REL/BOOT/KRN to
  `$ED00`. It must stay exactly `$130` bytes, because the boot track is full.
- `covdg.asm`: CoVDG, the VDG console. A copy of the CoCo 3 port's
  `level2/coco3/modules/covdg.asm` with the CoCo 2 code always in. Text and
  graphics screens live in motherboard RAM and are shown through the SAM.
  A graphics screen takes no system slot: each graphics call maps it into
  slot 1 in place of the text block and puts the text block back on return.
  `-DALLCAPS=1` shows lower case letters as normal capitals.
- `term_vdg.asm`: the `/Term` descriptor, the Level 2 VDG case of
  `level1/coco1/modules/term_vdg.asm`.
- `vdgwin.asm`: the `/V1`-`/V7` VDG window descriptors, one source assembled
  with `-DWNUM=1..7`.

All the video modules are here except VTIO, which is the CoCo 3 port's. Both
descriptors take `-DPLAIN6847=1` for a plain MC6847: CoVDG then uses its
inverse lower case mode instead of 6847T1 true lower case.

All other modules are shared with the CoCo 3 port. The port-specific parts of
shared files are inside `IFNE immunity` blocks, in `krn.asm`, `clock.asm`,
`fdebug.asm`, `reboot.asm` and `init.asm`.

## Hardware

The i-MMU-nity is an MMU board for the CoCo 1/2. It is register-compatible with
the CoCo 3 GIME MMU (`$FF90`/`$FF91`, `$FFA0-$FFAF`), with these differences:

- MMU blocks `$38-$3F` are the 64K motherboard RAM: block `$38+n` is the
  8K at motherboard address `n * $2000`. This is the only RAM the SAM/VDG can
  display. Every other block number is i-MMU-nity RAM.
- `$FF90` bit 6 enables the MMU and bit 3 (MC3) pins `$FExx` to block `$3F`.
  Bit 7 is inverted compared with the GIME: 0 enables the alternate vectors
  (CPU `$FFE0-$FFFF` come from i-MMU-nity RAM), and 1 selects the CoCo 1/2 ROM
  vectors. Writing a CoCo 3 value with bit 7 set turns the alternate vectors
  off.
- With the MMU on, CPU `$FFxx` is always I/O.
- There is no GIME video, timer or interrupt controller. Video is the VDG, with
  the display address set in the SAM (F0-F6, `$200` units, motherboard
  addresses only). The clock is the PIA0 VSYNC interrupt.
- Never write `$FFD9` (SAM fast mode): on a CoCo 1/2 it stops video and DRAM
  refresh.
- `$FF22` bit 4 (VDG GM0) selects lower case on a 6847T1 in text mode. It must
  stay 0 on a plain MC6847.

## Memory layout

| MMU block | Physical | Use |
| --- | --- | --- |
| `$00` | i-MMU-nity | system globals (block map `$0200`, page map), as on the CoCo 3 |
| `$01-$37`, `$40`+ | i-MMU-nity | OS9Boot and general RAM |
| `$38-$3D` | motherboard `$0000-$BFFF` | VDG pool: `NotRAM` in the block map; CoVDG claims graphics screens by setting `RAMinUse` and maps one into system slot 1 only while a graphics call runs |
| `$3B` (`Bt.Block`) | motherboard `$6000-$7FFF` | text screens; in system slot 1 (`$2000`) except while a graphics call runs, pages `$20-$3F` reserved; `RAMinUse` in the block map |
| `$3E` | motherboard `$C000-$DFFF` | reserved; `DAT.Free` maps unused slots here |
| `$3F` (`KrnBlk`) | motherboard `$E000-$FFFF` | REL/BOOT/KRN at `$ED00-$FEFF`, as on the CoCo 3 |

Block `$3B` is laid out as follows:

- `+$0000-$01FF`: the BtDebug cursor and, after boot, hidden breadcrumb and
  crash code storage.
- `+$0200-$03FF`: the boot screen. `/term` takes it over.
- `+$0400` up: further 512-byte text screens for `/V1`-`/V7`, up to 15
  screens in all.

The kernel changes are size-neutral: the 6809 CoCo krn is a fixed `$F00`
bytes, with only an 8-byte padding string. The i-MMU-nity changes trade against the
CoCo 3's 128K-machine code and that padding string. 11 bytes of padding remain.
