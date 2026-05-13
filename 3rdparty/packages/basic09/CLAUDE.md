# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build

Requires `NITROS9DIR` to point to the NitrOS-9 project root. The assembler (`lwasm`) and all tool variables come from `$(NITROS9DIR)/rules.mak`.

```bash
make                 # all modules
make basic09_6809    # 6809 variant
make basic09_6309    # 6309 variant (H6309 optimizations)
make dsk             # disk image (Basic09_v010100.dsk)
make clean
```

There is no test suite. Validation requires running on CoCo hardware or an emulator.

## Architecture of basic09.asm

A single ~13,000-line source file produces both `basic09_6809` and `basic09_6309` via the `H6309` preprocessor flag (`-DH6309=1`). It contains the full BASIC09 system in three logical sections:

1. **Pre-`start:` data and tables** — OS-9 module header, DP-resident data area (`u0000`–`u00xx` via `rmb`), jump-vector initialization table (`L000D`), keyword/token scan table (116 entries starting at `L0140`), and intro text.
2. **Runtime initialization (`start:`)** — clears the DP area, sets up all six jump vectors, opens I/O paths, then falls into the interactive editor loop.
3. **Editor, compiler, and I-Code interpreter** — the bulk of the file. The editor/compiler front-end tokenizes BASIC09 source into I-Code bytecode; the interpreter executes it.

### DP-page jump-vector dispatch

The central dispatch mechanism: six 3-byte JMP vectors live in the DP-resident data area at `u001B`–`u002A`, initialized at startup from `L000D`. Code invokes them as `JSR <u001E / FCB n`, where the FCB byte is an offset that selects a function from the table rooted at that vector. This pattern is used throughout the file for the compiler, runtime, assignment, and math subsystems.

| DP slot | Default target | Role |
|---------|---------------|------|
| `u001B` | `L00DC` | General ops (DIRLNK, error print, EXIT, KILLEX, …) |
| `u001E` | `L1CA5` | I-Code execution dispatch |
| `u0021` | `PLREF` | Parse / variable reference |
| `u0024` | `L31E8` | Compiler dispatch |
| `u0027` | `L3C09` | Assignment dispatch |
| `u002A` | `L5084` | Math / output dispatch |

### Real-number arithmetic includes

The floating-point routines are factored into separate files pulled into `basic09.asm` at build time. Edit the `.63` variant for 6309-optimized paths, `.68` for 6809:

- `basic09.real.add.63/68.asm`
- `basic09.real.mul.63/68.asm`
- `basic09.real.div.63/68.asm`

### Conditional assembly flags

- `H6309=1` — enables all `ifne H6309` blocks: the startup DP-clear loop (TFM), interrupt handler (OIM), I-Code integer/real arithmetic (MULD, DIVQ, INCD, Q/W register ops), and the `.63` real-math includes.
- `wildbits` — optional extensions; currently only affects the intro screen (`ifne wildbits` at the intro FCB).

### OS-9 module conventions

The module opens with `mod eom,name,Prgrm+Objct,ReEnt+0,start,size` and closes with `eom equ .`. The DP-resident data area (declared with `rmb` before `start`) is addressed throughout via `<uXXXX` direct-page addressing — this is intentional and load-address-independent.
