# CoCo 2 + i-MMU-nity Build Recipes

NitrOS-9 Level 2 for a Color Computer 1/2 fitted with an i-MMU-nity MMU board.
The console is the 32x16 VDG screen (`covdg.io`). There is no GIME, so the CoCo 3
window system (CoWin, GrfDrv) is not available.

## Build Directories

- [`floppy/`](floppy/) builds `l2_immunity_floppy.dsk` (`TRACKS=40` default, or 80)
- [`sdc/`](sdc/) builds `l2_immunity_sdc.dsk` for the CoCo SDC (the floppy
  driver is included as well)

```sh
export NITROS9DIR=/path/to/nitros9
make -C recipes/immunity/floppy
make -C recipes/immunity/sdc
```

Boot from Disk BASIC with `DOS`.

## Options

Put options on the make command line or in a `recipe.mak`:

- `VDG_T1=1` selects a 6847T1 VDG with true lower case (some CoCo 2B models).
  The default suits the plain MC6847 in most CoCo 1/2s: lower case is shown as
  inverse capitals. Software can't tell the two VDGs apart.
- `UPPERCASE=1` makes CoVDG show lower case letters as normal capitals, and
  `` { } | ~ ` `` as plain `[ ] ! - '` instead of inverse characters. This is
  display only; typed input is unchanged.
- `VDG_WINDOWS=n` (0-7, default 7) adds `/V1` to `/Vn`, extra 32x16 screens.
  CLEAR and SHIFT-CLEAR switch between the screens that have a path open.
  Start a shell on one with `shell i=/v1&`.
- `PwrLnFrq=50` gives a 50Hz (PAL) clock.
- `AFLAGS_EXTRA`, `BOOTMODS_EXTRA` and `CMDS_EXTRA` work as in the CoCo 3
  recipes. `RECIPE=name` changes the image name.

Run `make clean` when you change an option: make doesn't rebuild modules when
only a flag changes. The same applies after editing a file that a module
includes with `use`, such as the kernel's `f*.asm` files. `make clean` also
deletes the `.dsk` images in the recipe directory.

## Emulation

XRoar's `-machine-opt immunity` emulates the i-MMU-nity MMU. In `floppy/`,
`make run` boots the image with the XRoar given by `XROAR`, which defaults to
`$(NITROS9DIR)/../xroar/run-memjr.sh`. Add `-vdg-type 6847` to XRoar for a plain
MC6847 (its CoCo 2B machine has a 6847T1).

XRoar has no CoCo SDC emulation, so test the `sdc` image on real hardware. On
floppy, allow a minute or so after boot for the startup commands to load.

## Status

Boots and runs on a real CoCo 2 with a 1MB i-MMU-nity, from the CoCo SDC:

- Shell, the clock (PIA VSYNC interrupt), and memory sizing (512K/1M/2M)
- The VDG text console `/term`, plus up to seven extra screens `/V1`-`/V7`
- VDG graphics (PMODE screens from the motherboard RAM pool)
- `reboot` returns to Disk BASIC, and so does the RESET button (it turns the
  MMU off); type `DOS` to boot again

Besides the CoCo 3 standard commands, `CMDS` has `mmap`, `pmap` and `reboot`.

Known limitations:

- There is no runtime switch between the plain MC6847 and 6847T1 character
  sets; choose one at build time with `VDG_T1`.
- On floppy, the clock loses ticks while the drive is busy. This comes from the
  stock rb1773 driver.

See `level2/immunity/modules/README.md` for the hardware differences from the
CoCo 3 and the memory layout this port uses.
