# Script inventory

This directory contains the helpers used to maintain or inspect the current
source tree.

| Script | Purpose |
| --- | --- |
| `asmprettyprint.py` | Applies canonical assembly columns and normalizes instruction comments to lowercase `; ...` form |
| `pre-commit` | Formats staged assembly source before a commit |
| `dis6809.py` | Disassembles 6809 machine code for reverse-engineering work |
| `os9dis.py` | Disassembles OS-9 modules and data structures |
| `fcb2bin.py` | Converts assembly `fcb` byte declarations to binary data |
| `debug/list2crc.pl` | Converts an `lwasm` listing into CRC-named listing files |
| `debug/os9.gdb` | Defines GDB helpers that consume CRC-named listings |

The debugging helpers are documented in [debug/README.md](debug/README.md).
Historical distribution and publishing utilities are preserved under
[`archive/scripts`](../archive/scripts/README.md); they are not part of the
supported build.
