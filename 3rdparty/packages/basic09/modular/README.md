This directory preserves the original Microware multi-file Basic09 layout:

- `comand.asm`
- `compil.asm`
- `binder.asm`
- `stmts.asm`
- `exprsn.asm`
- `cnvio.asm`

The historical build assembled those pieces separately, merged them in that
order, patched the module size and jump table in `comand`, then ran OS-9
`verify ... u` to update the header parity and module CRC.  The repository
target `basic09_mod_6809` / `runb_mod_6809` reproduces those host-side steps
with `build-modular-basic09.pl`.

Local compatibility edits for lwasm and the NitrOS-9 tree:

- `defs` includes the repository `os9.d` instead of `/h0/defs/os9defs`.
- `b09type` lets make pass `INCLUDED=RUNTIM+MATHPAK` for RunB builds.
- `cnvio.asm` reserves the final three CRC bytes explicitly.
