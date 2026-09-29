# CoCo 2 + CocoMEM Jr Build Recipes

NitrOS-9 Level 2 for a Color Computer 1/2 fitted with a CocoMEM Jr MMU board.
The console is the 32x16 VDG screen (`covdg.io`); there is no GIME, so the CoCo 3
window system (cowin, grfdrv) is not available.

## Build Directories

- [`floppy/`](floppy/) builds `l2_cocomemjr_floppy.dsk` (`TRACKS=40` default, or 80)
- [`sdc/`](sdc/) builds `l2_cocomemjr_sdc.dsk` for the CoCo SDC

```sh
export NITROS9DIR=/path/to/nitros9
make -C recipes/cocomemjr/floppy
make -C recipes/cocomemjr/sdc
```

Options (on the make command line or in a `recipe.mak`):

- `VDG_T1=1` for a 6847T1 VDG with true lower case (some CoCo 2B models). The
  default suits the plain MC6847 in most CoCo 1/2s: lower case is shown as
  inverse capitals. Software can't tell the two VDGs apart.
- `UPPERCASE=1` makes CoVDG show lower case letters as normal capitals
  (display only; typed input is unchanged).
- `PwrLnFrq=50` for a 50Hz (PAL) clock.
- `AFLAGS_EXTRA`, `BOOTMODS_EXTRA`, `CMDS_EXTRA`, as in the CoCo 3 recipes.

## Emulation

XRoar's `-machine-opt immunity` emulates the CocoMEM Jr MMU. `make run` in
`floppy/` boots the image with the XRoar configured by `XROAR`, which defaults to
`$(NITROS9DIR)/../xroar/run-memjr.sh`. XRoar has no CoCo SDC emulation, so
test the `sdc` image on real hardware.

## Status

Work in progress. See `level2/cocomemjr/modules/README.md` for the hardware
differences from the CoCo 3.
