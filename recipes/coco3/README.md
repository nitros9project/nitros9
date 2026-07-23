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
- `nitros9-languages` is checked out beside NitrOS-9, or `LANGUAGES` points to it
- for `dw_mega`, `nitros9-apps` is checked out beside NitrOS-9, or
  `NITROS9_APPS_DIR` points to it

## Build Directories

- [`floppy/`](floppy/) builds CoCo 3 Level 2 double-sided floppy disk images
- [`dw/`](dw/) builds a CoCo 3 DriveWire-oriented disk image
- [`dw_mega/`](dw_mega/) builds an expanded CoCo 3 DriveWire image with third-party software

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

Set `FUJINET=1` in `recipe.mak` to include these FujiNet utilities:

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

Set `FUJINET=1` in `recipe.mak` to include the FujiNet utility commands listed
above.

## Mega DriveWire Build ([`coco3/dw_mega`](dw_mega/))

```sh
cd dw_mega
make
```

Primary output:

- `l2_coco3_dw_mega.dsk`

In addition to the normal recipe prerequisites, this build needs `git`, CMOC,
and the CMOC OS-9 runtime. By default it expects the usual coco-shelf layout:
`bin/cmoc` and `cmoc_os9/` alongside the `nitros9/` checkout. Set
`COCO_SHELF=/path/to/coco-shelf` if yours differs.

The mega recipe extends the existing [`dw/`](dw/) recipe and adds OS-9
software and story files fetched from pinned upstream revisions:

- [`drpitre/forth09`](https://github.com/drpitre/forth09), installed as the
  `forth09` command, with its test program in `/FORTH09/forthtest.4th`
- [`rlucente-retro/infocom-os9-port`](https://github.com/rlucente-retro/infocom-os9-port),
  installed as the `infocom` command
- the Version 3 Zork I-III story files under `/GAMES/INFOCOM`, installed as
  `zork1.dat`, `zork2.dat`, and `zork3.dat`
- the Version 3 [`drpitre/raakatu`](https://github.com/drpitre/raakatu) story,
  installed as `/GAMES/INFOCOM/raakatu.z3`
- the OS-9 Level 2 BBS from `nitros9-apps/os9l2bbs`, with its commands merged
  into `/CMDS` and its menus, configuration, and data installed under `/BBS`;
  `inetd` serves its login on TCP port 6909 by default
- the native C compiler from `nitros9-languages/ccompiler`, including its
  commands, libraries, headers, and source distribution

The upstream checkouts are kept in `dw_mega/.external` and removed by `make
clean`. The pinned `FORTH09_REF`, `INFOCOM_REF`, and `RAAKATU_REF` values make
normal builds repeatable; all repository URLs and revisions can be overridden
on the `make` command line.

After booting, start an Infocom title by passing its story file to the native
interpreter:

```text
forth09
forth09 </dd/FORTH09/forthtest.4th
infocom /dd/GAMES/INFOCOM/zork1.dat
infocom /dd/GAMES/INFOCOM/raakatu.z3
chd /dd/BBS
runbbs
```

From another computer, connect directly to the BBS with a character-at-a-time
raw TCP terminal, such as Serial on macOS, on port 6909. A Telnet client is not
suitable because its protocol negotiation interferes with the BBS input. Set
`BBS_PORT` on the `make` command line to select another port.

`INFOCOM_STORY_DIR` and `INFOCOM_STORIES` may be overridden to package another
legally obtained Version 3 story-file collection:

```sh
make INFOCOM_STORY_DIR=/path/to/stories \
  INFOCOM_STORIES="ZORK1.DAT PLANETFALL.DAT WITNESS.DAT"
```

## Notes

- Shared CoCo 3 build logic is in [`coco3.mak`](coco3.mak).
- Game-specific recipes, including Sierra AGI support, are maintained in
  [nitros9-games](https://github.com/nitros9project/nitros9-games).
- This recipe targets a practical default CoCo 3 floppy boot configuration.
- Use `recipe.mak` to extend command/module selections without editing shared makefiles.
