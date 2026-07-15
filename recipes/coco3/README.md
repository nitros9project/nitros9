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
- `AFLAGS_EXTRA` / `LFLAGS_EXTRA` for extra flags

## Prerequisites

From the repository root, ensure:

- `NITROS9DIR` is set to your NitrOS-9 source tree
- toolchain is on `PATH`: `make`, `lwasm`, `lwlink`, `lwar`, `os9`

## Build Directories

- [`floppy/`](floppy/) builds CoCo 3 Level 2 double-sided floppy disk images
- [`dw/`](dw/) builds a CoCo 3 DriveWire-oriented disk image
- [`dw_mega/`](dw_mega/) builds an expanded CoCo 3 DriveWire image with third-party software
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

## Mega DriveWire Build ([`coco3/dw_mega`](dw_mega/))

```sh
cd dw_mega
make
```

Primary output:

- `l2_coco3_mega.dsk`

In addition to the normal recipe prerequisites, this build needs `git`, CMOC,
and the CMOC OS-9 runtime. By default it expects the usual coco-shelf layout:
`bin/cmoc` and `cmoc_os9/` alongside the `nitros9/` checkout. Set
`COCO_SHELF=/path/to/coco-shelf` if yours differs.

The mega recipe extends the existing [`dw/`](dw/) recipe and adds native OS-9
software fetched and built from pinned upstream revisions:

- [`drpitre/raakatu`](https://github.com/drpitre/raakatu), installed as the
  `raakatu` command
- [`drpitre/forth09`](https://github.com/drpitre/forth09), installed as the
  `forth09` command, with its test program in `/FORTH09/forthtest.4th`
- [`rlucente-retro/infocom-os9-port`](https://github.com/rlucente-retro/infocom-os9-port),
  installed as the `infocom` command
- the Version 3 Zork I-III story files under `/GAMES/INFOCOM`

The upstream checkouts are kept in `dw_mega/.external` and removed by `make
clean`. The pinned `FORTH09_REF`, `INFOCOM_REF`, and `RAAKATU_REF` values make
normal builds repeatable; all repository URLs and revisions can be overridden
on the `make` command line.

After booting, run Raaka-Tu directly. Start an Infocom title by passing its
story file to the native interpreter:

```text
raakatu
forth09
forth09 </dd/FORTH09/forthtest.4th
infocom /dd/GAMES/INFOCOM/ZORK1.DAT
```

`INFOCOM_STORY_DIR` and `INFOCOM_STORIES` may be overridden to package another
legally obtained Version 3 story-file collection:

```sh
make INFOCOM_STORY_DIR=/path/to/stories \
  INFOCOM_STORIES="ZORK1.DAT PLANETFALL.DAT WITNESS.DAT"
```

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
