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
| `test-level1-srqmem.py` | Runs the assembled Level 1 system allocator and bitmap code on an external usim CPU, checking allocation/return rounding, exhaustion and bitmap bounds |
| `mkvidgfx.py` | Generates the committed data tables (`wgfxdat.asm`, `gemtestdat.asm`) for the Pico-Thing video demos `wgfx` and `gemtest`; `--check` reports stale tables |
| `debug/list2crc.pl` | Converts an `lwasm` listing into CRC-named listing files |
| `debug/os9.gdb` | Defines GDB helpers that consume CRC-named listings |

The debugging helpers are documented in [debug/README.md](debug/README.md).

The allocator regression test needs LWASM, a C++20 compiler and a local
[usim](https://github.com/raybellis/usim) checkout:

```sh
python3 scripts/test-level1-srqmem.py --usim-dir /path/to/usim --assembler lwasm
```

It builds only temporary test ROMs and a minimal RAM test board; it does not boot
the complete OS or use a replacement kernel. Use `--baseline HEAD` to exercise
the committed sources rather than working-tree edits. The pre-fix allocator
fails the zero-size and rounding-overflow cases by writing past its bitmap.

Add `--return-memory` to check `F$SRtMem`: zero-length returns and null
addresses are no-ops; rounding overflow, unaligned addresses and extents past
`$10000` return `E$BPAddr` without changing the bitmap. A range ending exactly
at `$10000` remains valid. These cases include partial-byte bitmap positions
where the original zero-count path writes beyond the map.

Historical distribution and publishing utilities are preserved under
[`archive/scripts`](../archive/scripts/README.md); they are not part of the
supported build.
