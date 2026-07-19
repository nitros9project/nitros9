# Pico-Thing Build Recipes

Build recipes for the Pico-Thing (RP2350 / MC6809 SBC) port of NitrOS-9.

## Prerequisites

From the repository root, ensure:

- `NITROS9DIR` is set to your NitrOS-9 source tree
- toolchain is on `PATH`: `make`, `lwasm`, `lwlink`, `lwar`, `os9`

```sh
export NITROS9DIR=$HOME/nitros9
```

## Build Directories

| Recipe | Level | CPU | Boot | Output image |
| --- | --- | --- | --- | --- |
| [`l1/`](l1/)             | 1 | 6809 | PATA IDE  | `NOS9_6809_L1_DEV_picothing.dsk` |
| [`l1dw/`](l1dw/)         | 1 | 6809 | DriveWire | `NOS9_6809_L1_DEV_picothing_dw.dsk` |
| [`l2/`](l2/)             | 2 | 6809 | PATA IDE  | `NOS9_6809_L2_DEV_picothing.dsk` |
| [`l2dw/`](l2dw/)         | 2 | 6809 | DriveWire | `NOS9_6809_L2_DEV_picothing_dw.dsk` |
| [`l1_6309/`](l1_6309/)   | 1 | 6309 | PATA IDE  | `NOS9_6309_L1_DEV_picothing.dsk` |
| [`l1dw_6309/`](l1dw_6309/) | 1 | 6309 | DriveWire | `NOS9_6309_L1_DEV_picothing_dw.dsk` |
| [`l2_6309/`](l2_6309/)   | 2 | 6309 | PATA IDE  | `NOS9_6309_L2_DEV_picothing.dsk` |
| [`l2dw_6309/`](l2dw_6309/) | 2 | 6309 | DriveWire | `NOS9_6309_L2_DEV_picothing_dw.dsk` |

```sh
cd l2
make
```

Object, library and module intermediates stay local to each build
directory in `.obj/`, `.lib/` and `.mods/`.

Useful targets: `make` (same as `make all`), `make clean`.

The 6309 recipes set `CPU = 6309` and `AFLAGS_EXTRA += -DH6309=1` in their
leaf makefile (the `--6309` switch only enables instruction parsing;
`H6309` is the conditional symbol that turns on native-mode code). `PORT`
stays `picothing` for every variant, so all sources and the port
`defsfile` (which sets `Level`) resolve to the shared `level1/picothing`
and `level2/picothing` trees.

## How the Pico-Thing boots

Unlike the CoCo ports, the Pico-Thing carries **two** boot files on the
disk rather than a single `OS9Boot`:

- `OS9Kernel` — the boot module padded to 1024 bytes, immediately followed
  by `krn`. A small raw REL loader (`rel_picothing`, built alongside as a
  `.srec` for firmware/`usim09pt` loading) runs at `Bt.Start` ($E800),
  loads `OS9Kernel`, then hands control to the kernel.
- `OS9Boot` — the merged bootfile (`krnp2`, `krnp3_perr`, `init`, `ioman`,
  the RBF/IDE stack, SCF console, clocks, pipes, ramdisk, the DriveWire
  stack, `sysgo` and the shell). Everything else the port supports is
  loadable from `/Modules` on the disk (graphical console, extra DriveWire
  descriptors).

The IDE and DriveWire recipes build the identical module set and bootfile;
they differ only in which boot module `OS9Kernel` carries —
`boot_picothing` (PATA IDE) versus `boot_dw_pt` (DriveWire).

The two levels compose those two files differently:

- **Level 2** `OS9Kernel` is the boot module padded to 1024 bytes followed
  by `krn`; `OS9Boot` holds `krnp2 krnp3_perr init ioman`, the driver
  stack, `sysgo` and a merged shell. The base image also carries a
  `/Modules` directory (graphical console, extra DriveWire descriptors).
- **Level 1** `OS9Kernel` is a plain merge of `krn krnp2 init boot` (no
  pad); `OS9Boot` starts with `ioman sysgo`, and the standalone `shell_21`
  module is renamed to `shell` on the disk. Level 1 links against
  `libcoco` rather than the level system library.

## Customizing

Copy `l2/` (or `l2dw/`) to a new directory and drop in a `recipe.mak` to
override, for example:

- `RECIPE`         — changes the output disk-image name
- `OS9KERNEL`      — `os9kernel` (IDE) or `os9kernel_dw` (DriveWire)
- `CMDS_EXTRA`     — extra commands copied into `/CMDS`
- `BOOTMODS_EXTRA` — extra modules merged into the bootfile
- `AFLAGS_EXTRA` / `LFLAGS_EXTRA` — extra assembler / linker flags

## Not yet converted

These pieces of the old top-level build have not been carried into recipes;
none are needed to boot or run the base images:

- The large `_i0` / `_x0` volumes (the giant bootable IDE/DriveWire images
  that also carry `/Modules`, BASIC09 and the `bf` interpreter) and the
  `/3rdparty` population step from the old `dskcopy` target.
- The on-disk `/DD/DEFS` reference directory that the old Level 1 build
  generated (preprocessed `os9.d`/`rbf.d`/`scf.d`/`picothing.d`). It is
  developer reference material only.
