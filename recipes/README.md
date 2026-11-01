# NitrOS-9 Build Recipes

This repository contains standalone build recipes for NitrOS-9 ports, separated from the main NitrOS-9 source tree.

## What This Repository Does

- Defines reusable build rules in [`rules.mak`](rules.mak)
- Defines shared library build rules in [`libs.mak`](libs.mak)
- Hosts platform-specific recipe folders (for example, [`wildbits/`](wildbits/), [`coco/`](coco/), and [`coco3/`](coco3/))

Platform-specific usage, targets, and workflows should be documented in each platform folder README.

## Prerequisites

You need these tools available on your `PATH`:

- `make`
- `lwasm`, `lwlink`, `lwar` (LWTOOLS)
- `os9` command suite (used for `format`, `copy`, `attr`, `padrom`, etc.)
- `zip` (for FEU packaging targets)

You must set:

- `NITROS9DIR` to the root of your NitrOS-9 source tree

Recipes that package BASIC09 expect `nitros9-languages` beside the NitrOS-9
checkout. Expanded application recipes may also expect `nitros9-apps` there.
Override `LANGUAGES` or `NITROS9_APPS_DIR` for another checkout layout.

Example:

```sh
export NITROS9DIR=/Users/boisy/Projects/coco-shelf/nitros9
```

## Reproducible Builds

Set `SOURCE_DATE_EPOCH` to a Unix timestamp to use a fixed UTC build date:

```sh
export SOURCE_DATE_EPOCH="$(git log -1 --format=%ct)"
make -C recipes/coco3/floppy -j1
```

The shared rules export the epoch to ToolShed and recursive builds, and set
`TZ=UTC` and `LC_ALL=C`. Build-info modules, the FEU startup date banner,
and FEU zip member timestamps use that epoch. This requires a ToolShed
version that supports `SOURCE_DATE_EPOCH`; use the same tool versions when
comparing images byte for byte, since padding can differ between versions.
ZIP member timestamps have two-second resolution.

Without `SOURCE_DATE_EPOCH`, build-info modules retain the last commit date
and the FEU banner uses the current date. The date helper supports both GNU
and BSD `date`.

Rebuild existing images and packaged dependencies when changing the epoch;
make does not track environment-variable changes for every output. FEU
startup files are regenerated on each build, and Wildbits startup generation
overwrites the file rather than appending duplicate commands.

## Build Artifact Layout

Object and library intermediates are now isolated per build directory:

- `$(OBJDIR)` defaults to `.obj`
- `$(LIBDIR)` defaults to `.lib`

So when you build from [`wildbits/l1`](wildbits/l1/), [`wildbits/l2`](wildbits/l2/), or [`wildbits/feu`](wildbits/feu/), that directory will contain:

- `.obj/` for intermediate objects (`*.o`)
- `.lib/` for generated libraries (`*.a`)
- final outputs as defined by the local platform makefile in that directory

## Repository Structure

- [`rules.mak`](rules.mak): shared compiler/linker/tool definitions and pattern rules
- [`libs.mak`](libs.mak): shared library targets consumed by port makefiles
- [`support/`](support/): small reusable generators and compatibility rules
- `<platform>/`: platform-specific recipes and usage documentation

## Platform Documentation

- Wildbits: see [`wildbits/README.md`](wildbits/README.md)
- CoCo 1/2: see [`coco/README.md`](coco/README.md)
- CoCo 3: see [`coco3/README.md`](coco3/README.md)
