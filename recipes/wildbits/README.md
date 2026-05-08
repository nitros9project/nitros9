# Wildbits Build Recipes

This document covers building Wildbits targets from this repository.

## Creating Your Own Recipe (Copy Workflow)

You can clone an existing recipe folder with minimal makefile edits.

Example from [`wildbits/`](./). The template file is [`recipe-template.mak`](recipe-template.mak).

```sh
cp -R l1 myrecipe
cp recipe-template.mak myrecipe/recipe.mak
cd myrecipe
make
```

Only edit `myrecipe/recipe.mak` for common customization:

- `RECIPE` to change output name
- `CMDS_EXTRA` to add disk commands
- `BOOTMODS_EXTRA` to add boot modules
- `AFLAGS_EXTRA` / `LFLAGS_EXTRA` for extra flags

This avoids modifying large shared makefiles.

## Prerequisites

From the repository root, ensure:

- `NITROS9DIR` is set to your NitrOS-9 source tree
- toolchain is on `PATH`: `make`, `lwasm`, `lwlink`, `lwar`, `os9`, `zip`

Example:

```sh
export NITROS9DIR=/Users/boisy/Projects/coco-shelf/nitros9
```

## Build Directories

- [`l1/`](l1/) builds Wildbits Level 1 disk images
- [`l2/`](l2/) builds Wildbits Level 2 disk images
- [`l1dw/`](l1dw/) builds Wildbits Level 1 DriveWire disk images
- [`l2dw/`](l2dw/) builds Wildbits Level 2 DriveWire disk images
- [`feu/`](feu/) builds FEU artifacts (`bootfile`, `booter`, flash packages)

Each build directory keeps intermediate artifacts local:

- `.obj/` object files
- `.lib/` static libraries

## Platform Selection

Supported `PLATFORM` values:

- `k2` (default)
- `jr2`

Use as:

```sh
make PLATFORM=jr2
make PLATFORM=k2
```

## Level 1 Build ([`wildbits/l1`](l1/))

```sh
cd l1
make
```

Primary output:

- `l1_wildbitsk2.dsk` (or `l1_wildbitsjr2.dsk` when `PLATFORM=jr2`)

Useful targets:

- `make all` (same as `make`)
- `make clean`

## Level 1 DriveWire Build ([`wildbits/l1dw`](l1dw/))

```sh
cd l1dw
make
```

Primary output:

- `l1_wildbits_dwjr2.dsk` (or `l1_wildbits_dwk2.dsk`, etc.)

## Level 2 Build ([`wildbits/l2`](l2/))

```sh
cd l2
make
```

Primary output:

- `l2_wildbitsk2.dsk` (or `l2_wildbitsjr2.dsk` when `PLATFORM=jr2`)

Useful targets:

- `make all` (same as `make`)
- `make clean`

## Level 2 DriveWire Build ([`wildbits/l2dw`](l2dw/))

```sh
cd l2dw
make
```

Primary output:

- `l2_wildbits_dwjr2.dsk` (or `l2_wildbits_dwk2.dsk`, etc.)

## FEU Build ([`wildbits/feu`](feu/))

```sh
cd feu
make
```

Primary outputs:

- `bootfile`
- `booter`

Additional FEU targets:

- `make booter`
- `make f0.dsk`
- `make f0.zip`
- `make booter.zip`
- `make flash`
- `make upload`
- `make clean`

FEU disk image name pattern:

- `feu_wildbitsk2.dsk` or `feu_wildbitsjr2.dsk` (when that target is built)

## Notes

- `startup` in FEU includes a build date line when generated.
- Incremental builds are enabled by dependency tracking in makefiles.

## Troubleshooting

- Missing module/source errors: verify `NITROS9DIR` points to a valid NitrOS-9 checkout.
- `os9` command failures: ensure OS-9 tools are installed and accessible on `PATH`.
- Link errors for Wildbits libraries: run `make clean && make` in the active build directory.
