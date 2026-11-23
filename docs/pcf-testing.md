# Running the PCF and RBF regressions locally

From the repository root, these recipe targets build their own disposable test
images. They do not use an attached physical disk and do not record video.
MAME runs a 512K CoCo 3 with an 80-column screen and `-nothrottle`.

## Nightly CI on main

The [Build workflow](../.github/workflows/build.yml) runs the full build and
filesystem regressions every night on `main` at **09:17 UTC** (03:17 Central
Standard Time or 04:17 Central Daylight Time). Pushes still run quick checks.
GitHub scheduled runs use the workflow committed to the default branch.

The nightly run includes:

- Full product recipe builds and OS-9/Rogue boot smoke checks on both CPUs.
- All deterministic assembled-code filesystem suites: block drivers, VHD,
  FAT32 reads/writes, rename, review-failure recovery, parent timestamps,
  FAT32 boot validation, directory enumeration/removal, and RFM/its fixture.
  These suites cover Levels 1 and 2; the block-driver suite also checks both
  CPU assembly variants.
- Randomized CPU tests with fixed seeds `17` and `20261108`, plus the UTC date
  as a daily seed. Each seed runs 150 operations on each OS level, retaining
  replay traces, images, independent FAT checks, and host reference files.
- Seven independent emulator jobs: writable PCF with cold-boot persistence
  and its deeper CPU checks; read-only FAT32 root; PCF from an RBF floppy;
  FAT32 OS9Boot loading; RBF recursive removal/integrity; full RFM integration;
  and RFM directory/execution checks under IRQ polling stress.

The PCF and RBF emulator jobs together run every goal in the existing
`check-all` target. Separate jobs and a non-fail-fast matrix keep a failure in
one filesystem from suppressing the others. The filesystem emulator recipes
currently exercise the 6809 CoCo 3; native 6309 system/game smoke checks run
separately. RFM integration uses the local protocol fixture, without an
external DriveWire server.

Run the same suites manually on a selected branch:

```sh
gh workflow run build.yml --ref main -f suite=filesystems
# Include the full build and system/game smoke checks too:
gh workflow run build.yml --ref main -f suite=all -f game=rogue
```

CPU logs and replay evidence are uploaded as `filesystem-cpu-results`.
Each integration uploads `filesystem-SUITE-results`, including its console,
screenshots, integrity reports and test images. These artifacts are retained
for 14 days, including failed runs. All emulator jobs share the pinned MAME
0.289 setup and checksum-verified ROM cache.

## Local invocation

```sh
# Watch both integrations: FAT32 (including randomized operations), then RBF.
make -C recipes/coco3/pcf_write_mame_test demo-all

# Watch either integration by itself.
make -C recipes/coco3/pcf_write_mame_test demo
make -C recipes/coco3/rbf_mame_test demo

# Run both integrations and the deeper CPU stress tests without MAME windows.
make -C recipes/coco3/pcf_write_mame_test check-all
```

Dependencies: the normal NitrOS-9 build tools (`lwasm`, `lwlink`, `os9`, and the
languages checkout), MAME with legally obtained CoCo 3/Disk BASIC ROMs, and a
Python 3.11+ environment containing `pyfatfs` and `MC6809`. On this workstation:

```sh
make -C recipes/coco3/pcf_write_mame_test demo-all \
  LANGUAGES=/Users/boisy/Projects/coco-shelf/nitros9-languages \
  PYTHON=/private/tmp/blkdev-venv/bin/python
```

`MAME_BINARY` and `MAME_ROMPATH` override the executable and ROM directory.
`FAT_CHECK` selects the read-only FAT checker (default `/sbin/fsck_msdos`;
on Linux, use `FAT_CHECK=fsck.fat`). It is required for FAT32 test success.
The default ROM directory is `~/Documents/Resources/Computing/mame/roms`.
Close a MAME window early to abort that run; incomplete runs fail verification.
Each finished window closes automatically, and the terminal prints PASS only
after the host-side checks succeed. The only emulated keyboard input is `DOS`
to boot. All test commands run from disk through the normal OS-9 shell; Lua
observes output and stops MAME after the completion marker and a short settling
interval. There is no character injection or inter-command keyboard delay.

## Disk-resident scripts and interactive answers

Preparation installs `TEST.CMD` and adds `shell /dd/test.cmd` to startup.
The writable FAT32 startup uses `ex shell /dd/test.cmd`, replacing the startup
shell and releasing its script path to conserve system RAM. It selects
`ex shell /dd/reopen.cmd` when `/dd/testdone` exists;
the first script creates that file at the end of its operations. This lets
the second boot select the persistence checks without host edits to the image.
The second boot must still leave the entire image hash unchanged.

Both directory-removal tests use ordinary input redirection:

```text
deldir /pc0/tree </dd/cancel.in
deldir /dd/tree </dd/delete.in
```

`CANCEL.IN` contains `l`, `y`, `q`; `DELETE.IN` contains four `d` responses,
with OS-9 carriage-return line endings. Recursive children inherit the answer
path and consume subsequent lines normally. The RBF test uses `/dd/tree` for
both calls. The generated scripts print numbered `RUN` progress lines and
use `-x` so expected rejection/quit cases do not abort execution. Host checks
still require the exact expected errors, file contents, and integrity results;
a guest completion message alone does not mark a test as passing.

The FAT32 read trace must include the selected script and, on the first
writable boot, both answer files. `REOPEN.CMD` is checked on the second boot.

## Rename coverage

The FAT32 `check` and `demo` targets include 25 real parent/child `SS.Rename`
checks. They cover files and directories, case-only names, collision/missing-name
errors, bad names/records/modes, open and duplicated paths, and directories held
as another process's cwd/cxd. All 16 rejections must produce zero VHD writes.
The standard `rename` command then renames a file and a nonempty directory;
the cold boot verifies their new names, contents, and parent traversal.

```sh
# CPU-level PCF/RBF rename and command regression tests, included in check-all.
make -C recipes/coco3/pcf_write_mame_test check-rename
```

These CPU checks add LFN rejection, parent position and metadata preservation,
cross-sector collisions, and injected I/O failures. Rename supports short names
within one parent directory; it does not move entries between directories.

## Randomized coverage and replay

The visible FAT32 run generates 120 operations using a recorded seed. It
creates nested directories, creates/appends/copies/deletes files, and removes
empty directories. A separate host directory receives the equivalent operations.
After MAME exits, PyFatFS independently compares every surviving name, directory,
and file byte with that host reference. Unexpected guest errors fail the run.
A second cold boot uses the written image; its hash must remain unchanged and
the host comparison must still pass. Each boot is followed by a mandatory
`fsck_msdos -n` integrity check, with its full output saved in `fsck.log`.
A nonzero checker result fails the target; the checker must leave the image
hash unchanged. The CPU suite applies the same check to each final image.

```sh
make -C recipes/coco3/pcf_write_mame_test demo RANDOM_SEED=42 RANDOM_STEPS=120
make -C recipes/coco3/pcf_write_mame_test check-random \
  RANDOM_CPU_SEEDS="17 20261108" RANDOM_CPU_STEPS=150
```

`check-random` executes the assembled pcf/blkdrv/VHD code on MC6809 for Levels
1 and 2. It adds binary overwrites, append, truncation/extension, sector-boundary
writes, and zero-filled seek gaps. Every surviving changed file is read back
through pcf and compared with a real host file. Every 25 operations, and at the
end, an independently opened FAT32 image is compared with the entire host
reference and both FAT copies are compared. This tests file-manager code with
mocked kernel services; it does not replace the real OS-9 MAME integration.

## Evidence saved by the targets

Paths below are relative to each recipe directory:

| Recipe/output | Evidence |
| --- | --- |
| `pcf_write_mame_test/.fat-root/` | `result.json`, `screen.png`, `console.txt`, `errors.log`, `fsck.log`, disk read/write traces |
| `.fat-root/system/` | Installed `STARTUP`, `TEST.CMD`, `REOPEN.CMD`, and answer files |
| `.fat-root/reference/` | Independently generated expected files and directories |
| `.fat-root/random-trace.json` | Seed and ordered guest operations |
| `.fat-root/random-verified.json` | Verified file sizes and SHA-256 hashes |
| `.fat-root/reopen/` | Cold-boot console, screenshot, and verification result |
| `pcf_write_mame_test/.random-cpu/` | Per-level/seed replay traces, host files, resulting images, and results |
| `rbf_mame_test/.rbf-test/` | RBF screenshot, console, `result.json`, `dcheck.log`, and written floppy |

The RBF run exercises listing and cancellation inside a subtree, recursive
removal of a three-level tree and empty sibling, regular-file deletion, and
preservation of an unrelated file. It verifies disk contents using host OS-9
Tools. `dcheck` reports the reserved 18-sector kernel track as allocated outside
the file structure; it is not an orphan introduced by directory deletion.

All images and screenshots are generated outputs. Re-running a target replaces
its previous evidence, so copy it elsewhere before starting another seed if
needed. A passing finite regression is not a proof for every input, concurrent
schedule, media failure, or hardware configuration. Real Wildbits hardware and
power-loss behavior still need separate validation.

## Review failure regressions

`LWASM=lwasm.orig python3 scripts/test-pcf-review.py` executes both OS levels
against injected first/second-half FAT and directory write failures. It checks
truncate identity restoration, subsequent writes on the same path, reclamation
of failed first allocations and links, advisory FSInfo failures, execution-mode
delete selection, WRITE-only directory changes, readonly `SS.Opt`, and orphaned
LFN checksums. `test-readdir.py` and `test-deldir.py` also exercise legacy raw
RBF fallback, including dot/free filtering and extended metadata.

`make -C recipes/coco3/pcf_write_mame_test check-review PYTHON=/path/to/python`
runs the review-failure, parent-time and booter suites. `check-all` includes this target.
`test-pcf-parent-time.py` checks parent timestamps after create/mkdir/delete/rmdir
and rename, child metadata preservation, relative cwd operation, open-directory
cache refresh, partition isolation, zero-write case-only rename, and both halves
of failed parent-sector writes. Namespace changes can precede a timestamp error.

`test-boot-fat32.py` models F$BtMem's returned page-rounded allocation and guards
the kernel tables and system memory map. It exercises signature/layout/version,
FAT-count and OS9BOOT attribute failures; reserved/high clusters; overflow in
reserved/FAT/data addresses and cluster scaling; and the final VHD record versus
an attempted wrapped read. Both CPU builds must remain exactly 464 bytes.

The `fat_mame_test` and `fat_boot_mame_test` suites also execute their commands
from a disk-resident startup script. Their artifacts include console output,
VHD read/write traces, and a completion marker. The FAT boot case removes the
floppy OS9Boot and clears its boot pointer before starting MAME. Both verify
file contents, fragmented reads, directory metadata, and an unchanged FAT image.
`test-sysgo-startup.py` checks resident-module mapping release and dynamic-module
reclamation on MC6809, plus SysGo's descriptor-buffer allocation.

The `module-groups` MAME job runs a guest program against the real Level 2
kernel. It loads two distinct callable modules from one file, tests both unlink
orders, and repeats for a one-block file, a file spanning two 8 KB blocks, and
two resident bootfile modules. After the first unlink the survivor must still
execute. At each stage the guest records its process DAT image, block link
counts, and physical block allocation flags. The host verifies that the final
unlink releases the group's mappings, reclaims dynamic module storage, and
preserves resident storage. Reloading/relinking repeats each case in reverse
order. Artifacts include `group.report`, decoded `result.json`, console logs,
and the guest disk under `module_group_mame_test/.group-test/`.
