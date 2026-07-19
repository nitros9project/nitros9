# Repository layout

The maintained repository is organized around OS level, reusable source, and
product recipes.

```text
archive/   historical and unsupported material
defs/      shared assembler definitions
docs/      project and contributor documentation
level1/    Level 1 shared and platform-specific source
level2/    Level 2 shared and platform-specific source
level3/    experimental Level 3 source
lib/       reusable OS-9 libraries
recipes/   supported disk-image and distribution builds
scripts/   maintenance, formatting, and reverse-engineering utilities
```

## OS source

Each maintained OS level separates shared components from target-specific
components:

- `cmds/` contains commands shared by ports at that level.
- `modules/` contains kernels, file managers, drivers, descriptors, and other
  boot modules shared by multiple ports.
- `sys/` contains system data such as help, fonts, and configuration files.
- platform directories such as `level2/coco3/` contain port definitions and
  platform-specific source.

The `port.mak` files describe target-specific compiler and assembler settings.
They are build inputs, not the primary user entry points.

## Recipes

The supported build entry points are under `recipes/`. A recipe selects a
port, boot modules, commands, system files, and disk format, then creates a
complete image in its own directory.

Shared recipe mechanics live in `recipes/rules.mak`, `recipes/libs.mak`, and
the platform-level `.mak` files. Small reusable generation makefiles live in
`recipes/support/`.

## Scripts

The supported maintenance, formatting, and reverse-engineering helpers live
under `scripts/`. See the [script inventory](../scripts/README.md) for their
purpose and requirements. Obsolete release-building and publishing utilities
are retained under `archive/scripts/` for historical reference only.

## Archive

Nothing under `archive/` is part of the supported build. Archived material may
be incomplete, duplicated, tied to obsolete hardware, or governed by distinct
licensing terms. See the [archive manifest](../archive/MANIFEST.md).
