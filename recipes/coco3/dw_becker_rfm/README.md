# CoCo 3 Becker RFM system

`make` builds a Becker-port DriveWire bootstrap and installs the operating system
as plain host files directly in this recipe folder:

- `bootstrap.dsk`: kernel bootstrap track only, for HDB-DOS `DOS`
- `OS9Boot`: boot modules fetched over RFM
- `CMDS/`, `SYS/`, `sysgo`, `startup`: the running system
- `DD/`: guest system directory, with links to `../CMDS`, `../SYS`,
  `../sysgo`, and `../startup`; build files are not visible in `/DD`

OS9Boot contains `RFM`, `RFMDrv`, `DWIO`, and an RFM `/DD` descriptor.
It contains no RBF, RBDW, or X descriptors. The bootstrap image has no local
OS9Boot or system files; its virtual drive is used only by HDB-DOS to load the
initial kernel track. The kernel then fetches this folder's `OS9Boot` through
RFM, and the running system uses host files for all filesystem access.

## Build and serve

From this directory, with the NitrOS-9 toolchain on PATH:

```sh
make
make serve DRIVEWIRE_SERVER=/path/to/drivewire-server
```

`DW_BIND` defaults to 127.0.0.1 and `DW_PORT` to 65504. The server's RFM root
is **this recipe folder**, not a subdirectory. Equivalent server invocation:

```sh
drivewire-server --bind 127.0.0.1 --tcp-port 65504 \
  --disk0 "$PWD/bootstrap.dsk" --rfm-root "$PWD"
```

Use a server implementing context-aware RFM ($11-$15). TCP requires no
bitbanger receive-boundary pacing. `make run` launches MAME; set `MAME_ROMPATH`
and `HDBDOS_ROM` for your installation and enable its Becker port. Start the
server separately before launching MAME.

Boot using `DOS` in DriveWire HDB-DOS. At the NitrOS-9 prompt:

```text
mdir
dir /dd
dir /dd/cmds
echo RFM works >/dd/rfm-check.txt
list /dd/rfm-check.txt
```

`rfm-check.txt` appears in this recipe folder's `DD/` directory. RFM writes modify host
files immediately. Rebuilding refreshes generated system files but does not
remove guest-created files. Previous disk-backed images are obsolete; use `bootstrap.dsk`.

## Regression checks

Install `MC6809==0.7.2` in a Python virtual environment, then run
`python scripts/test-rfm.py` from the repository root with `lwasm` on PATH.
The tests execute Level 1/2 modules against deterministic fixtures; they do not
model physical serial timing.
