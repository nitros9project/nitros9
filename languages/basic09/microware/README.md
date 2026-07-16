# Basic09 / RunB — Microware Original Source

This directory contains the original Microware multi-file source layout for
Basic09 and RunB:

- `comand.asm`
- `compil.asm`
- `binder.asm`
- `stmts.asm`
- `exprsn.asm`
- `cnvio.asm`

Supporting files — `defs`, `b09defs`, `b09type`, `jmpdefs`, `linkage`,
`editor` — replicate the original Microware build environment.

## Reproducing the Tandy binary

Commit `081ec321` is the point at which these sources assemble byte-for-byte
to the original Tandy-distributed Basic09 and RunB binaries.  The historical
build assembled the six source files separately, merged them in the order
listed above, patched the module size and jump table in `comand`, then ran
OS-9 `verify ... u` to update the header parity and module CRC.  The
`build-modular-basic09.py` script in this directory reproduces those steps.

Local compatibility edits for lwasm and the NitrOS-9 tree:

- `defs` includes the repository `os9.d` instead of `/h0/defs/os9defs`.
- `b09type` lets make pass `INCLUDED=RUNTIM+MATHPAK` for RunB builds.
- `cnvio.asm` reserves the final three CRC bytes explicitly.

## Canonical source

This modular layout is the sole source of truth for Basic09 and RunB in this
repository. Both the 6809 and 6309 modules shipped by the package are built
from these files. The older monolithic disassemblies and their extracted
floating-point fragments have been removed.

## 6309 optimizations

Beyond `081ec321`, the sources have been extended with HD6309-specific
optimizations: native multiply and divide (`MULD`/`DIVQ`), block transfer
(`TFM`), immediate bit-manipulation (`OIM`), quad-word load/store
(`LDQ`/`STQ`), and others. These are conditioned on the `H6309` assembly flag
and do not affect the 6809 output.
