# NitrOS-9

NitrOS-9 is a community-maintained distribution of Microware OS-9 for the
Motorola 6809 and Hitachi 6309 processors. It supports the Tandy Color
Computer family and several other 6809-based systems.

## Repository layout

- `level1/`, `level2/`, and `level3/` contain operating-system source arranged
  by OS level and target platform.
- `defs/` contains shared assembler definitions.
- `lib/` contains shared libraries.
- `recipes/` contains the supported disk-image and distribution builds.
- `scripts/` contains repository maintenance, formatting, and
  reverse-engineering utilities.
- `archive/` preserves unsupported and historical material.

See [Repository layout](docs/repository-layout.md) for details and
[Supported ports](docs/supported-ports.md) for the current target matrix.

## Building

Install the following tools and ensure they are on `PATH`:

- [LWTOOLS](http://lwtools.projects.l-w.ca), including `lwasm`, `lwlink`, and
  `lwar`
- [ToolShed](https://github.com/n6il/toolshed), including the `os9` utilities
- `make`

Recipes that package BASIC09 require a sibling checkout of
[nitros9-languages](https://github.com/nitros9project/nitros9-languages).
Some expanded recipes also use
[nitros9-apps](https://github.com/nitros9project/nitros9-apps):

```text
parent/
  nitros9/
  nitros9-apps/
  nitros9-languages/
```

Set `NITROS9_APPS_DIR` or `LANGUAGES` to use another layout.

To build the CoCo 3 Level 2 floppy image:

```sh
export NITROS9DIR=$HOME/nitros9
make -C recipes/coco3/floppy
```

Each recipe writes its output into its own directory. See the
[recipe documentation](recipes/README.md) for the available builds.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution and commit guidance.

Historical release notes and migrated project files are retained under
[`archive/project-history`](archive/project-history/README.md).
