# Sierra AGI sound extractor tools

Tools for converting Sierra AGI v2 PC sound resources (`SNDDIR` + `VOL.*`)
into a SID-stream sidecar pair (`sidDir` + `sidSnd`) consumed at runtime by
the polyphonic SID playback engine in `objs/mnln.asm`.

The CoCo X-SID cartridge has a MOS 8580 SID chip with 3 voices.  The
existing `vol.*` files on the CoCo disks store sounds in a flattened
mono format that bit-bangs the DAC; this loses the original 3-voice +
1-noise PCjr polyphony.  These tools re-extract that polyphonic content
from a PC AGI install and emit a parallel SID-format sound resource
file that the engine plays through the X-SID when present, falling back
to the existing mono path when the X-SID is absent.

## Status (Phase 2 — complete)

| Step                                     | Status     |
| ---------------------------------------- | ---------- |
| Parser for AGI v2 sound resources        | done       |
| PC-AGI → SID-stream converter            | done       |
| `sidDir` / `sidSnd` on-disk format       | done       |
| Build integration (makefile) — SQ0       | done       |
| Build integration (makefile) — all 14    | done       |
| Polyphonic SID playback engine in mnln   | done       |
| End-to-end audio verification            | done       |
| Asset-discovery helper (`sync_pc_assets.py`) | done   |

### Polyphonic SID enabled per game

All 14 Sierra games now ship polyphonic SID sidcars on their data
disks (out of the box, after running `make dskcopy` with the
PCASSETS dirs populated via `sync_pc_assets.py`).

The AGI v2 sound data needed for extraction already ships in every
game's NitrOS-9 source directory (as `sndDir` + `vol.*`), so the
scanner auto-bootstraps the PCASSETS directories from those files —
no external downloads required.  Users who own the original PC AGI
installs can override the in-tree files via GOG/Steam scanning (see
the next section), and any per-game `<GAME>_PCASSETS` env var.

|                      | sidcar source            | notes |
| -------------------- | ------------------------ | ----- |
| `blackcauldron`      | in-tree                  | |
| `christmas86`        | in-tree (Sierra freeware) | |
| `goldrush`           | in-tree                  | |
| `kingsquest1`–`4`    | in-tree                  | |
| `leisuresuitlarry`   | in-tree                  | |
| `manhunter1`–`2`     | in-tree                  | |
| `policequest1`       | GOG / disc (or in-tree)  | |
| `spacequest0`        | freeware SQ0:R           | |
| `spacequest1`        | GOG / disc (or in-tree)  | |
| `spacequest2`        | GOG / disc (or in-tree)  | 80D variant omits sidcars (capacity) |

## Setup

1. Acquire the freeware fan-game **Space Quest 0: Replicated** (Jeff
   Stewart, 2003).  It's available on archive.org as
   `SpaceQuest0Replicated`.  The downloadable is a 7-Zip SFX
   `Space Quest 0 - Replicated.exe`; extract with `7z x` (no install
   needed).
2. Copy or symlink the extracted AGI assets to `~/sq0r-pcassets/`:
   ```
   ~/sq0r-pcassets/
     SNDDIR
     VOL.0
     (LOGDIR, PICDIR, VIEWDIR, OBJECT, WORDS.TOK are not needed for
      sound extraction but are typically present from the same install)
   ```
   Override the default with `make SQ0R_PCASSETS=/some/other/path ...`.
3. Build as normal:
   ```
   cd ~/coco-shelf/nitros9/3rdparty/packages/sierra/spacequest0
   make dskclean && make dskcopy
   ```
   If `$(SQ0R_PCASSETS)/SNDDIR` exists, `sidDir` and `sidSnd` are
   regenerated and copied onto every disk variant.  If it doesn't, the
   build proceeds without the sidecar files (engine falls back to mono
   playback).

## Per-game PC-asset env vars (Phase 2 retrofit)

The same `SIDFILES` wiring exists in all 14 Sierra game makefiles.
Drop a PC AGI install at the per-game default location and run
`make dskclean && make dskcopy` in that game's directory; the build
will automatically extract `sidDir`/`sidSnd` and bake them onto the
data disks.  Absent the assets the build proceeds normally with
Phase-1 mono-only fallback.

| Game directory     | env var                | default location              |
| ------------------ | ---------------------- | ----------------------------- |
| `blackcauldron`    | `BLACKCAULDRON_PCASSETS` | `$HOME/blackcauldron-pcassets` |
| `christmas86`      | `CHRISTMAS86_PCASSETS` | `$HOME/christmas86-pcassets`  |
| `goldrush`         | `GOLDRUSH_PCASSETS`    | `$HOME/goldrush-pcassets`     |
| `kingsquest1`      | `KQ1_PCASSETS`         | `$HOME/kingsquest1-pcassets`  |
| `kingsquest2`      | `KQ2_PCASSETS`         | `$HOME/kingsquest2-pcassets`  |
| `kingsquest3`      | `KQ3_PCASSETS`         | `$HOME/kingsquest3-pcassets`  |
| `kingsquest4`      | `KQ4_PCASSETS`         | `$HOME/kingsquest4-pcassets`  |
| `leisuresuitlarry` | `LSL_PCASSETS`         | `$HOME/leisuresuitlarry-pcassets` |
| `manhunter1`       | `MH1_PCASSETS`         | `$HOME/manhunter1-pcassets`   |
| `manhunter2`       | `MH2_PCASSETS`         | `$HOME/manhunter2-pcassets`   |
| `policequest1`     | `PQ1_PCASSETS`         | `$HOME/policequest1-pcassets` |
| `spacequest0`      | `SQ0R_PCASSETS`        | `$HOME/sq0r-pcassets`         |
| `spacequest1`      | `SQ1_PCASSETS`         | `$HOME/spacequest1-pcassets`  |
| `spacequest2`      | `SQ2_PCASSETS`         | `$HOME/spacequest2-pcassets`  |

Each PC-asset directory must contain at minimum `SNDDIR` and `VOL.*`
(typically all of `VOL.0`–`VOL.N` referenced by `SNDDIR`).  The
extractor parses uppercase or lowercase filenames automatically.

PC AGI installs of the freeware/abandonware Sierra games can be
sourced legally — for example **Christmas86** is freeware (Sierra
released it as a holiday give-away) and its AGI sound data already
ships in the NitrOS-9 source tree.  Commercial Sierra titles require
a legally owned copy.

The wiring is generated by `add_sidfiles_wiring.py` (idempotent;
re-run after pulling a fresh makefile change to re-apply).

## Asset discovery helper

`sync_pc_assets.py` automates populating the per-game PCASSETS
directories from local GOG / Steam installs (does **not** download
from the internet — copyright concerns).  Typical usage:

```
python3 sync_pc_assets.py --dry-run   # see what it finds, no copies
python3 sync_pc_assets.py             # copy detected installs
python3 sync_pc_assets.py --list      # show known games + dir hints
```

It scans common Windows install roots via WSL `/mnt/c|d|e/...` paths:
- `/mnt/c/Program Files (x86)/GOG Galaxy/Games`
- `/mnt/c/GOG Games`, `/mnt/d/GOG Games`, etc.
- Steam `steamapps/common`
- Pass `--extra-root /mnt/x/Other` for custom paths.

For each detected install the script copies just the files needed
for SID extraction (`SNDDIR` + `VOL.*`) into
`$HOME/<game>-pcassets/`.  For GOG bundles that ship both AGI and
later-engine versions (e.g. PoliceQuest packs AGI under `EGA/` and
SCI in the root), the script picks the AGI subdirectory automatically.

Christmas86 is auto-bootstrapped from the NitrOS-9 source tree (since
those files are Sierra freeware and already in the repo).

## Files

| File                       | Purpose                                       |
| -------------------------- | --------------------------------------------- |
| `agi_snd_parser.py`        | Library: parse AGI v2 SNDDIR + VOL.* + sound resources |
| `agi_sid_extract.py`       | CLI: write `sidDir` + `sidSnd`                |
| `sync_pc_assets.py`        | CLI: populate PCASSETS dirs from local GOG/Steam installs and/or in-tree files |
| `fat12_extract.py`         | CLI: extract `SNDDIR`+`VOL.*` from raw FAT12 floppy `.img` files |
| `add_sidfiles_wiring.py`   | One-shot retrofit script for `SIDFILES` makefile wiring |
| `sid_format.md`            | On-disk format specification                  |
| `engine_design.md`         | Design notes for the mnln SID engine          |

## CLI examples

```
# Parse and summarise all sound resources in an AGI install
python3 agi_snd_parser.py ~/sq0r-pcassets

# Dump every note of sound #5
python3 agi_snd_parser.py ~/sq0r-pcassets --sound 5 --full

# Build the sidecar files
python3 agi_sid_extract.py ~/sq0r-pcassets \
    --sid-dir sidDir --sid-snd sidSnd -v

# Build with a non-default SID clock (e.g. for non-MAME emulators or
# hardware that uses a different SID clock)
python3 agi_sid_extract.py ~/sq0r-pcassets --sid-clock 985248
```

## Sizes (for SQ0:R reference)

* `sidDir`  404 bytes  (101 entries × 4)
* `sidSnd`  ~52 KB    (63 sounds, 0.07–13 KB each, max 116-sec cue)

The 80-track and DriveWire CoCo disk variants comfortably accommodate
these.  The 360 KB single-sided 40-track variant is very tight; users
who need SID polyphony are expected to use 80D or DW.
