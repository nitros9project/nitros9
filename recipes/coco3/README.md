# CoCo 3 Build Recipes

This document covers building shared CoCo 3 targets from this repository.

## Creating Your Own Recipe (Copy Workflow)

You can clone the base recipe folder with minimal makefile edits.

Example from [`coco3/`](./). The template file is [`recipe-template.mak`](recipe-template.mak).

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
- `FUJINET=1` to include the FujiNet utility commands
- `AFLAGS_EXTRA` / `LFLAGS_EXTRA` for extra flags

## Prerequisites

From the repository root, ensure:

- `NITROS9DIR` is set to your NitrOS-9 source tree
- toolchain is on `PATH`: `make`, `lwasm`, `lwlink`, `lwar`, `os9`

## Build Directories

- [`floppy/`](floppy/) builds CoCo 3 Level 2 double-sided floppy disk images
- [`dw/`](dw/) builds a CoCo 3 DriveWire-oriented disk image
- [`sierra/`](sierra/) builds Sierra AGI CoCo 3 disk images and holds the shared Sierra recipe logic

Each build directory keeps intermediate artifacts local:

- `.obj/` object files
- `.lib/` static libraries

## Level 2 Floppy Build ([`coco3/floppy`](floppy/))

```sh
cd floppy
make
make TRACKS=80
make MINIMAL=1
```

Primary output:

- `l2_coco3.dsk` (default)
- `l2_coco3_minimal.dsk` (`MINIMAL=1`)

This recipe defaults to `TRACKS=40`. Use `TRACKS=80` for an 80-track floppy image.
Use `MINIMAL=1` for a smaller bootable disk with only the core boot modules,
one floppy descriptor, `shell`, and `grfdrv`.

Use `KEYRPT=0` to build a generated startup file that disables OS-9 key repeat,
which helps faster-than-real-time MAME runs avoid rapid repeated keys. Leave
`KEYRPT` unset to keep the normal startup file. `MAME=1` is accepted as a
compatibility alias for `KEYRPT=0`.

Optional features:

- add `FUJINET=1` in `recipe.mak` to include:
  - `fngetdevfile`
  - `fnsetdevfile`
  - `fnlisthosts`
  - `fngethost`
  - `fnsethost`
  - `fnlistdevs`
  - `fnmount`
  - `fnstatus`

## DriveWire Build ([`coco3/dw`](dw/))

```sh
cd dw
make
```

Primary output:

- `l2_coco3_dw.dsk` (default)

This recipe defaults to:

- DriveWire RBF modules (`rbdw`, `dwio`, `x*` descriptors)
- DriveWire virtual terminal modules (`scdwv` + `n*` descriptors)
- `startup.dw`
- DriveWire disk format settings (`$(OS9FORMAT_DW)`)

Optional features:

- add `FUJINET=1` in `recipe.mak` to include the FujiNet utility commands listed above

## Sierra Build ([`coco3/sierra`](sierra/))

```sh
cd sierra
make
```

Primary output:

- `l2_coco3_kingsquest3.dsk` (default)

This entrypoint currently defaults to `GAME=kingsquest3` and builds:

- a 32-column Sierra-compatible terminal stack (`covdg_small.io` + `term_vdg.dt`)
- the `vrn.dr` and `vi.dd` modules required by King's Quest III
- KQ3 command modules (`sierra`, `mnln`, `scrn`, `shdw`)
- the original Sierra-style root layout with `AutoEx`, `tOC`, and game data at the disk root
- a minimal startup script that links `shell` and loads `utilpak1`

The shared Sierra base contains:

- common CoCo 3 Sierra boot-module defaults
- the small Sierra-compatible `shell`
- rules to package Sierra runtime modules and game data from `3rdparty/packages/sierra/<game>`
- shared TOC generation

Game-specific values now live in [`sierra/recipe.mak`](sierra/recipe.mak).

Examples:

```sh
cd sierra
make GAME=kingsquest1
make GAME=kingsquest3
make GAME=goldrush
```

Currently supported `GAME` values:

- `blackcauldron`
- `christmas86`
- `goldrush`
- `kingsquest1`
- `kingsquest2`
- `kingsquest3`
- `kingsquest4`
- `leisuresuitlarry`
- `manhunter1`
- `manhunter2`
- `policequest1`
- `spacequest0`
- `spacequest1`
- `spacequest2`

The recipe automatically chooses the appropriate single-image media type for each title:

- `80d` for single-disk 80-track floppy games
- `dw` for titles that need a single DriveWire-style image

## Notes

- Shared CoCo 3 build logic is in [`coco3.mak`](coco3.mak).
- Shared Sierra recipe logic is in [`sierra/sierra.mak`](sierra/sierra.mak).
- This recipe targets a practical default CoCo 3 floppy boot configuration.
- Use `recipe.mak` to extend command/module selections without editing shared makefiles.
