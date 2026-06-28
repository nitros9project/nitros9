# CoCo 1/2 Build Recipes

This document covers building shared CoCo 1/2 targets from this repository.

## Creating Your Own Recipe (Copy Workflow)

You can clone the base recipe folder with minimal makefile edits.

Example from [`coco/`](./). The template file is [`recipe-template.mak`](recipe-template.mak).

```sh
cp -R floppy myrecipe
cp recipe-template.mak myrecipe/recipe.mak
cd myrecipe
make
```

Only edit `myrecipe/recipe.mak` for common customization:

- `RECIPE` to change output name
- `CMDS_EXTRA` to add disk commands
- `BOOTMODS_EXTRA` to add boot modules
- `AFLAGS_EXTRA` / `LFLAGS_EXTRA` for extra flags

## Prerequisites

From the repository root, ensure:

- `NITROS9DIR` is set to your NitrOS-9 source tree
- toolchain is on `PATH`: `make`, `lwasm`, `lwlink`, `lwar`, `os9`

## Build Directories

- [`floppy/`](floppy/) builds CoCo 1/2 Level 1 double-sided floppy disk images
- [`40d/`](40d/) builds the legacy CoCo 1/2 Level 1 40-track double-sided disk image
- [`dw/`](dw/) builds a CoCo 1/2 DriveWire-oriented Level 1 disk image

Each build directory keeps intermediate artifacts local:

- `.obj/` object files
- `.lib/` static libraries

## Level 1 Floppy Build ([`coco/floppy`](floppy/))

```sh
cd floppy
make
make TRACKS=80
make MINIMAL=1
```

Primary output:

- `l1_coco.dsk` (default)
- `l1_coco_minimal.dsk` (`MINIMAL=1`)

This recipe defaults to `TRACKS=40`. Use `TRACKS=80` for an 80-track floppy image.
Use `MINIMAL=1` for a smaller bootable disk with only the core boot modules and shell.

Use `KEYRPT=0` to build a generated startup file that disables OS-9 key repeat,
which helps faster-than-real-time MAME runs avoid rapid repeated keys. Leave
`KEYRPT` unset to keep the normal startup file.

## DriveWire Build ([`coco/dw`](dw/))

```sh
cd dw
make
```

Primary output:

- `l1_coco_dw.dsk` (default)

This recipe defaults to:

- DriveWire kernel booter (`boot_dw`)
- DriveWire RBF modules/descriptors (`rbdw`, `dwio`, `ddx0`, `x1`, `x2`, `x3`)
- `clock2_dw`
- DriveWire-friendly disk format settings (`$(OS9FORMAT_DW)`)
- network/userland commands: `dw`, `inetd`, `telnet`, `httpd`

## Notes

- Shared build logic is in [`coco.mak`](coco.mak).
- Internally this recipe uses the NitrOS-9 `coco1` port tree, which supports both CoCo 1 and CoCo 2.
- The kernel track is generated separately and applied with `os9 gen`.
