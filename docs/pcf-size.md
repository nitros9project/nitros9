# pcf size audit

Current modules after all software review fixes: **7,500 bytes (Level 2)** and
**7,491 bytes (Level 1)** for both CPUs. Parent-directory timestamp updates and
cache coherence add **441 bytes** per level to the preceding review fix.
Per-path workspace remains **1,792 bytes**: the parent-cluster field fits in the
existing gap, and timestamp traversal reuses the path's record/sector buffers.
All thirteen ABI slots remain three bytes.

The earlier review fixes added 368 bytes per level relative to the last size
pass and reduced per-path storage from 2,048 to 1,792 bytes. Together, the review
work adds **809 bytes** to each pcf module. Compared with the measured
**5,454-byte Level 2 RBF**, current pcf is **2,046 bytes (37.5%) larger**, excluding
drivers. The following historical measurements remain as an audit trail.

The VHD booter remains exactly **464 bytes** on both CPUs with signature,
FAT32-layout/version, FAT-count, file-type, reserved-cluster and address-overflow
checks. Space comes from direct page-aligned DMA, saved size/image values on
the private stack, shared error unwinding, normalized FAT shift counts and
nearby routine placement. No root/file fragmentation support was removed.

Allocation resumes after the path's preceding allocation and wraps once;
appending preserves the cached chain cursor. FAT years saturate at 2107.
Parent timestamp maintenance adds synchronous lookup/write work; no throughput
improvement is claimed. Other timestamp defaults and half-second behavior remain.

## Timestamp packing, cluster encoding and position updates

| Build | Before | After | Saved |
|---|---:|---:|---:|
| Level 2, 6809/6309 | 6,749 | 6,691 | 58 |
| Level 1, 6809/6309 | 6,740 | 6,682 | 58 |

| Change | Bytes saved |
|---|---:|
| Pack month with MUL instead of separate high/low shifts | 7 |
| Pack minutes once for both time bytes | 15 |
| Decode month using carry instead of temporary memory | 8 |
| Reuse EntryCluster when committing a file's metadata | 14 |
| Share three 32-bit position additions, including the new helper | 14 |
| **Total** | **58** |

Timestamp packing retains the existing year/month/day defaults, half-second
rounding, byte truncation and out-of-range behavior. The CPU suite tests every
possible byte independently in all six input clock fields (1,536 vectors per
level), plus 3,036 date-decoding boundary combinations per level. The shared
position adder preserves Val and X/Y/U, including full-width carry on overflow.
Cluster encoding reuses the same four byte stores already used for directories.

All four builds assemble. Validation includes Level 1/2 read/write/rename tests,
MAME mutations/rejections and cold-boot persistence, 600 randomized operations
against host files, and fsck after both MAME boots and on the four CPU images.

## Shared transfers, arithmetic, copies and returns

| Build | Before | After | Saved |
|---|---:|---:|---:|
| Level 2, 6809/6309 | 6,847 | 6,749 | 98 |
| Level 1, 6809/6309 | 6,836 | 6,740 | 96 |

| Change | Level 2 saved | Level 1 saved |
|---|---:|---:|
| Share MoveIn/MoveOut setup and transfer | 22 | 20 |
| Share unsigned word additions to 32-bit values | 36 | 36 |
| Share three field-increment sequences | 14 | 14 |
| Reuse the byte-copy loop for clock, name and entry copies | 12 | 12 |
| Share read/write count and status return | 12 | 12 |
| Shorten one additional branch | 2 | 2 |
| **Total** | **98** | **96** |

MoveIn and MoveOut retain the caller-buffer interface, register restoration,
zero-length behavior and error propagation. Level 2 uses the original source
and destination task IDs with F$Move; Level 1 uses one guarded byte-copy loop
for both directions. The CPU harness checks Level 2 task direction explicitly.

AddWord shares the existing full-width increment arithmetic and returns the
32-bit carry. IncField retains the updated value, destination pointer and carry
of the former load/increment/store sequence. Tests include wraparound, signed
boundaries, 16-bit carries and preservation of E/F/I. ADCA retains its normal
half-carry behavior. Metadata byte copies preserve the original clock interrupt
masking, and read/write returns still restore both the byte count and error.

All four builds assemble. Validation covers the Level 1/2 read/write/rename
suites, the complete writable MAME run and cold boot, 600 randomized operations
against host-reference files, and fsck on both MAME boots and all four CPU-test
images. Some shared helpers add call overhead; no throughput gain is claimed.

## Compact field access and shared block transfers

| Build | Before | After | Saved |
|---|---:|---:|---:|
| Level 2, 6809/6309 | 6,978 | 6,847 | 131 |
| Level 1, 6809/6309 | 6,967 | 6,836 | 131 |

| Change | Net bytes saved |
|---|---:|
| Share 76 workspace field loads/stores, including both new helpers | 106 |
| Share read/write block setup and completion checks, including branch adjustments | 16 |
| Shorten six additional branches/calls | 9 |
| **Total** | **131** |

`LoadField` and `StoreField` use A as a signed displacement from U+128,
covering all unsigned byte offsets without clearing carry to form an address.
Their tails are the existing LoadVal/StoreVal routines. Differential CPU tests
compare memory, registers and condition codes against the original sequence,
including high-bit offsets and zero, signed-boundary and all-ones values.
Small offsets that offer no saving and fields beyond byte-offset range retain
the direct sequence. These wrappers add a few instructions per access.

ReadBlock and WriteBlock now share request-LBA setup, driver dispatch, error
propagation and the requirement that exactly one block complete. All four
OS-level/CPU combinations assemble. The Level 1/2 read/write/rename suites,
MAME write/rejection/persistence checks, and 600 randomized CPU operations
validate the smaller module; fsck checks both MAME boots and all four final
CPU-test images.

After that pass, pcf was **1,393 bytes (25.5%) larger** than the measured
5,454-byte Level 2 RBF module, excluding drivers.

## Compact dispatch and shared 32-bit copies

| Build | Before | After | Saved |
|---|---:|---:|---:|
| Level 2, 6809/6309 | 7,316 | 6,978 | 338 |
| Level 1, 6809/6309 | 7,305 | 6,967 | 338 |

| Change | Net bytes saved |
|---|---:|
| Share 34 four-byte workspace copies, including the new helper | 236 |
| Replace individual entry wrappers with one relative dispatch table | 64 |
| Shorten 22 branches/calls whose destinations now fit | 38 |
| **Total** | **338** |

`CopyVal` takes unsigned source/destination workspace offsets in A/B. It matches
the previous LoadVal/StoreVal sequence, including the retained arithmetic value,
final X/D registers and carry flag. An assembly-time guard keeps all eligible
fields within byte-offset range. The copy from F.Record, which is outside that
range, retains the original sequence.

All thirteen file-manager ABI slots remain three bytes. Each calls the common
lock dispatcher and supplies a one-byte selector into a position-independent
relative-offset table. The dispatcher retains the existing volume lock, cache
invalidation, error handling, register restoration and interrupt masks. The
header now contains the dispatcher; its increased section size is offset by
removal of the old wrappers from the mutation section.

These changes trade extra dispatch/copy instructions for smaller code; no
throughput improvement is claimed. Branch ranges were assembled and checked
for all four OS-level/CPU combinations.

Validation includes differential copy/condition-code checks, all thirteen ABI
slots under contention, the existing Level 1/2 read/write/rename suites, and the
writable MAME recipe with a fresh cold boot and read-only fsck after each boot.
The randomized CPU suite compares 600 operations with host files and checks
both FAT copies and all four final images with fsck. Commands and artifact
locations are documented in [pcf-testing.md](pcf-testing.md).

## Earlier files-only optimization

Directory creation added 254 bytes to each build; empty-directory removal and
in-use checks added 392/394 bytes; same-directory rename added 461 bytes.
The historical breakdown below records the preceding files-only implementation,
before those additions and the latest compact-dispatch/copy pass.

Measured 6809 Level 2 OS-9 modules, including header and CRC. This compares
this audit's starting source with the branch, workspace-layout, and shared-decoder changes;
it does not compare against the older read-only implementation in git.
Section boundaries follow routine labels, so shared helpers are counted once.

| Section | Before | After | Saved |
|---|---:|---:|---:|
| Header, dispatch, errors, arithmetic | 265 | 224 | 41 |
| Driver calls and sector caches | 146 | 111 | 35 |
| Mount and geometry validation | 589 | 542 | 47 |
| Cluster traversal and cycle checks | 554 | 474 | 80 |
| Open/create setup and pathname parsing | 861 | 706 | 155 |
| Directory lookup and entry adoption | 372 | 320 | 52 |
| Read, ReadLn, directory records, path lifecycle | 745 | 638 | 107 |
| Status, SS.ReadDir, OS-9 metadata | 707 | 553 | 154 |
| Operation lock, sharing, write permissions | 450 | 399 | 51 |
| Write geometry, block I/O, FAT/FSInfo updates | 473 | 413 | 60 |
| Cluster allocation and freeing | 391 | 344 | 47 |
| Timestamps, directory updates, create/grow | 677 | 611 | 66 |
| Write, WriteLn, zero-filled gaps | 494 | 415 | 79 |
| Delete and file resizing | 442 | 394 | 48 |
| WriteLn terminator scan | 75 | 62 | 13 |
| Module CRC | 3 | 3 | 0 |
| **Total** | **7,244** | **6,209** | **1,035** |

## Changes applied

- Short branches/subroutine calls where the assembled displacement fits:
  **750 bytes saved** in Level 2 (7,244 → 6,494). All candidates were checked
  against Level 1/2 and 6809/6309 builds. The fixed three-byte entry table is
  unchanged. There are 426 changed source sites, including conditional code
  that is not emitted in every variant.
- Move `F.Val`, `F.Move`, and `F.Pos` to the beginning of the private path
  workspace: **201 additional bytes saved** (6,494 → 6,293). These fields now
  use compact indexed operands. No workspace fields or buffers were removed.
  Some other accesses became slightly larger; the figure is the net saving.

- Share ReadData/ReadFat cache filling: **21 additional bytes saved**
  (6,293 → 6,272). Each cache descriptor has a valid byte followed by its LBA;
  the common routine keeps Y as the OS-9 path descriptor during driver calls.
  Failed fills invalidate the affected cache and retain the original error.
- Share direct FAT-entry metadata decoding between SS.FD/SS.FDInf and
  SS.ReadDir: **63 additional bytes saved** (6,272 → 6,209). The portable
  record's name remains in place while metadata is written immediately after
  it. Removed the entry scratch copy and name/metadata save-and-restore loops.
  The unused 32-byte F.Meta field was removed; fixed buffer offsets and the
  2,048-byte workspace allocation remain unchanged.

Total Level 2 saving: **1,035 bytes (14.3%)**. The measured RBF module is 5,454
bytes, so pcf is now **755 bytes (13.8%) larger**, down from 1,790 bytes (32.8%).
Level 1 changed from 7,237 to 6,196 bytes. Both CPU assembly modes have the
same size for a given OS level. Per-open workspace remains **2,048 bytes**,
with data and FAT buffers still at offsets $400 and $600. `blkdrv`, backend
modules, descriptors, and workspace allocations are excluded from the table.

## Remaining opportunities

1. **Pathname handling.** Parsing and opening remain large sections. Any
   consolidation must preserve dot traversal, caller pathname consumption,
   error handling, and short-name creation rules.
2. **Workspace ordering.** More frequently accessed flags could be moved nearer
   the base. Measure the net instruction-size change: making one field cheaper
   can make another more expensive. Keep the fixed sector-buffer boundaries.
3. **Local control-flow layout.** There are still long branches whose destinations
   genuinely lie outside short range. Moving error exits nearer their callers
   may help, but duplicated exits cost bytes and increase maintenance work.

Do not reduce block addresses or file sizes to 24 bits, remove chain validation,
or drop sharing checks simply to match RBF's module size. No such changes were
made here. This audit addresses code size, not runtime memory reduction or a
performance benchmark.

## Reproducing the breakdown

Assemble with lwasm's `--symbol-dump=/tmp/pcf.sym`, then run:

```
python3 scripts/pcf-size.py /tmp/pcf.sym
python3 scripts/pcf-size.py /tmp/pcf-after.sym --before /tmp/pcf-before.sym
```

Use matching CPU and OS-level configurations for comparisons. The script
computes section lengths from the symbol offsets and accounts for the CRC.

## Validation

All four Level 1/2 × 6809/6309 variants assembled. The Level 1/2 read and write
CPU regression suites passed, including added tests for second-half data/FAT
read failures, invalidation and retry, byte-for-byte metadata equivalence across
SS.ReadDir and SS.FDInf, and full SS.FD clearing without caller-buffer overrun. The 6809 Level 2 writable-root MAME recipe passed
boot, startup, file operations, the four RBF-specific utilities' E$BTyp (249) rejections and portable recursive deldir, 13 parent/child
sharing checks, independent reader positions, and unsupported SS.Lock reporting.
The post-test image passed `fsck_msdos -n`. The recorded video was not changed.
