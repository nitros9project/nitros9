# blkdrv native-block interface (ABI 1)

blkdrv is an experimental OS-9 device driver for a new file manager. It transfers
whole device blocks. RBSuper's deblocking serves RBF's 256-byte-sector interface;
blkdrv does not need that compatibility layer. There is no 256-byte translation,
partition offset, HDB-DOS adjustment, read-modify-write cache, or FAT code here.

The implementation consists of `defs/blkdrv.d`, `level1/modules/blkdrv.asm`,
`level1/modules/llmemblk.asm`, and
`level1/wildbits/modules/llwbsdblk.asm`. Existing RBSuper modules are unchanged.
These modules do not yet provide a mountable FAT32 device: a file manager and its
descriptors must be implemented separately.

## Building and testing

From the repository root:

```sh
make -C recipes/wildbits/l1 NITROS9DIR="$PWD" blkdrv-modules
make -C recipes/wildbits/l2 NITROS9DIR="$PWD" blkdrv-modules
python3 -m venv /tmp/blkdrv-venv
/tmp/blkdrv-venv/bin/pip install MC6809
/tmp/blkdrv-venv/bin/python scripts/test-blkdrv.py
```

`LWASM` overrides the test assembler executable. Builds produce `blkdrv`,
`llwbsdblk`, and `llmemblk` in the recipe's `.mods` directory. They are deliberately
absent from default boot lists. The tests assemble for Level 1/2 and 6809/6309,
and execute the 6809 binaries with simulated OS-9 memory/link services. The SD
peer operates on SPI register bytes, exercising the actual backend command,
response, capacity-decoding and transfer instructions. Physical Wildbits hardware
and full IOMan attachment remain to be validated.

## Calling the driver

The six standard driver vector slots are Init, Read, Write, GetInfo, Flush, Term,
at offsets 0, 3, 6, 9, 12, 15 from the execution entry. GetInfo and Flush occupy
GetStat and SetStat slots but use this **kernel-only calling convention**, not
user `I$GetStt`/`I$SetStt` register frames or existing SS codes. The future file
manager must explicitly marshal requests; these are not RBF-compatible calls.

- Init: Y = device descriptor, U = OS-9 driver static storage.
- Read/Write: X = request, Y = path descriptor, U = driver static storage.
- GetInfo: X = information record, Y = path descriptor, U = driver statics.
- Flush: Y = path descriptor, U = driver statics; X is unused.
- Term: Y = descriptor, U = driver statics; X is unused.

All entries preserve X/Y/U and caller interrupt masks. Carry clear and B=0 means
success; carry set and B=an OS-9 error means failure. A and other condition flags
are unspecified. Requests, info records and buffers must be valid system-space
memory throughout synchronous calls. They must not overlap each other, driver
state, code, or hardware registers. The caller owns allocation and mapping of
these objects; blkdrv is not a user-memory validation boundary.

All multibyte interface values are **big endian**. Disk format byte order belongs
to the file manager. The implemented block size is 512 bytes. Unsupported sizes
are rejected rather than translated. Addresses are unsigned 32-bit device LBAs:
`$00000000` through `$FFFFFFFF`, or a 2 TiB address space for 512-byte blocks.
A device can report a smaller accessible range. Crossing `$00FFFFFF` is tested
because the former three-byte interface wrapped at that boundary; it is not a
limit of this ABI.

### Transfer request

| Offset | Symbol | Size | Meaning |
| ---: | --- | ---: | --- |
| 0 | BR.Size | 1 | Exactly 16 |
| 1 | BR.Version | 1 | Exactly 1 |
| 2 | BR.Unit | 1 | Must match the attached configuration |
| 3 | BR.Flags | 1 | Zero; reserved |
| 4 | BR.LBA | 4 | Absolute device block address |
| 8 | BR.Count | 2 | Number of whole blocks, 1..127 in this implementation |
| 10 | BR.Buffer | 2 | System-space buffer address |
| 12 | BR.Bytes | 2 | Available buffer bytes |
| 14 | BR.Done | 2 | Completed prefix, initialized by blkdrv |

blkdrv checks the request version, flags, unit, write protection, capacity,
backend transfer limit, buffer length and address arithmetic. Buffer end must
not wrap the 16-bit address space. A malformed short request is rejected before
writing Done. An unacquired lock or unattached device also leaves Done untouched.
Once the lock is acquired and Size is valid, Done starts at zero even if later
validation fails. Inputs are otherwise unchanged.

Success means Done equals Count. On failure, Done counts only fully completed
blocks; the next block may be partially transferred or changed. A failed write
is not rolled back. File managers must account for that uncertainty before
retrying or modifying metadata. Requests execute in order; no asynchronous or
software write-back queue exists.

### Information record

The caller sets Size=12 and Version=1. Remaining fields are outputs.

| Offset | Symbol | Size | Meaning |
| ---: | --- | ---: | --- |
| 0 | BI.Size | 1 | 12 |
| 1 | BI.Version | 1 | 1 |
| 2 | BI.Unit | 1 | Attached unit |
| 3 | BI.Flags | 1 | ReadOnly=1, Removable=2, Flush=4 |
| 4 | BI.BlockSize | 2 | Bytes per device block (512) |
| 6 | BI.Last | 4 | Inclusive last accessible LBA |
| 10 | BI.MaxCount | 2 | Maximum blocks per request (127) |

Reporting the last address allows all 2^32 blocks to be represented without a
zero-count special case. GetInfo is called before every transfer to check media
presence and write protection. Neither current backend advertises reliable
media-change generation tracking. Flush means completion of earlier writes at
the backend's supported device interface; it does not promise atomic metadata
updates or protection against power failure inside a card.

## Backend module and configuration

A backend is a `Sbrtn+Objct` module with six **three-byte branch slots** using the
same order as blkdrv. Immediately after them is the ABI header:

| Offset from execution entry | Contents |
| ---: | --- |
| 18 | Word `$4244` (BD) |
| 20 | Byte ABI version 1 |
| 21 | Byte header length 24 |
| 22 | Word private-state byte requirement, 1..$FF00 |

The legacy RBSuper ABI is not accepted. blkdrv links the backend, validates the
header, allocates and zeroes private system memory, then calls Init. Link and
allocation failures unwind resources. Term attempts Flush and backend Term,
then releases memory and the module link even if a backend reports an error:
IOMan discards driver statics after invoking Term. Term returns the first backend
error. File managers should Flush explicitly before final detach so they can
handle failures while the device is still attached.

Backend calls receive X=request/info (unused for lifecycle/flush), Y=configuration,
and U=private state. X/Y/U and interrupt masks are preserved. Backends may trust
blkdrv's transfer validation. They must leave request inputs unchanged and update
Done only after each completed block. Error returns must preserve the completed
prefix. Buffers are not inferred from PD.BUF, and no RBSuper variables are shared.

The descriptor extension follows the standard `M$DTyp` byte:

| Symbol | Contents |
| --- | --- |
| BT.Version | Byte 1 |
| BT.Backend | Word offset from descriptor module start to backend name |
| BT.Config | Configuration below, embedded in descriptor |

The configuration is copied into driver statics, since IOMan can share statics
across aliases after the first descriptor is detached.

| Config offset | Symbol | Size | Meaning |
| ---: | --- | ---: | --- |
| 0 | BC.Port | 2 | Mapped hardware port; must agree with descriptor hardware identity |
| 2 | BC.Unit | 1 | Unit; Wildbits backend accepts zero |
| 3 | BC.Flags | 1 | RAM backend ReadOnly flag; zero for Wildbits |
| 4 | BC.Ram | 2 | RAM backend backing-store address |
| 6 | BC.Blocks | 2 | RAM backend backing-store size in 512-byte blocks |
| 8 | BC.Base | 4 | RAM backend sparse test window's first LBA |
| 12 | BC.FailAfter | 2 | RAM backend failure threshold; $FFFF disables |

Wildbits ignores the RAM fields. A future FAT descriptor should refer to blkdrv
and llwbsdblk and use a consistent hardware port/page identity. This is not an
RBF descriptor option table and cannot be substituted into an existing RBF path.

## Ownership and concurrency

IOMan shares static storage for matching driver and hardware-port identities.
blkdrv's lock lives in that shared storage and covers info lookup, validation,
and the entire backend transfer. Acquisition is atomic with interrupts briefly
masked; contention returns E$DevBsy without sleeping or changing the existing
owner's lock. The caller can yield and retry. There is no long interrupt-masked
region around SD traffic.

ABI 1 supports one configuration/unit per shared driver instance. Descriptor
aliases for the same hardware identity must use the same backend/configuration.
Do not attach incompatible aliases. Partition base/length belong in file-manager
volume state; do not invent different hardware identities for partitions.

**Do not access the same controller concurrently through RBSuper/llwbsd and
blkdrv/llwbsdblk.** They do not share arbitration or caches. This opt-in backend
requires exclusive controller ownership; it neither modifies nor claims to
serialize the legacy driver. Different controllers can be used independently.
Also avoid concurrent overlapping mounted volumes even if a controller lock
serializes individual transfers. Term requires that the file manager has no
outstanding requests.

## Wildbits backend

The backend uses the existing Wildbits SPI register definitions. It implements
CMD0, CMD8, CMD55/ACMD41, CMD58, CMD16 for byte-addressed cards, and CMD9/CSD
capacity discovery. SDSC CSD v1 and SDHC/SDXC CSD v2 are accepted. MMC, SDUC/CSD v3,
other sector sizes and hardware beyond this interface are not supported.

CMD17/CMD24 transfer one native 512-byte block at a time. Four address bytes and
full-width increments are used. SDSC byte-address conversion checks overflow.
Every SPI-busy, response, token, card-initialization and programming-busy loop is
bounded. These are poll-count bounds, not calibrated wall-clock deadlines.
Read CRC bytes are consumed; SPI CRC checking is not enabled in this version.
Writes check the masked data-response token, wait for programming to finish, and
check both CMD13 status bytes before advancing Done. Flush waits for ready; there
is no deferred backend write queue. Chip select is released after transactions,
including error paths.

Card detect and socket/CSD write-protection are checked. An observed removal
invalidates the initialized state and requires detach/reattach. A removal and
replacement entirely between calls is not reliably detectable; live hot-swap
without unmounting is unsupported. Mounting code must not assume media identity
is stable merely because GetInfo succeeds.

Protocol reference: [SD Association Physical Layer Simplified Specification,
version 6.00](https://www.sdcard.org/cms/wp-content/themes/sdcard-org/dl.php?f=Part1_Physical_Layer_Simplified_Specification_Ver6.00.pdf),
CSD and SPI-mode sections. Tests simulate the wire protocol; actual cards still
need hardware validation, especially timeout margins and removal behavior.

## Memory test backend

The caller supplies 1..127 blocks of system RAM; the backend does not allocate or
clear that backing store. Its lifetime must span attachment. All current buffers
and backing store must be disjoint. Flush/Term are successful no-ops.

Normally Base=0 models a small disk. Nonzero Base exposes a **sparse test window**
so high addresses and 32-bit carries can be exercised with a few kilobytes of
RAM. GetInfo reports Base+Blocks-1; addresses below Base return E$Sect. This mode
is a test fixture, not a general mountable disk.

FailAfter=N returns E$Read/E$Write before block N of each request, with Done=N;
zero fails immediately and $FFFF disables injection. Reaching Count succeeds,
even if FailAfter equals Count. ReadOnly causes blkdrv to reject writes before
calling the backend. The test suite checks content round trips, range failures,
partial transfers, ABI rejection, resource cleanup, and register/interrupt-mask
preservation in addition to SD protocol behavior.

## Wildbits hardware verification

The native SD backend interprets `SYS0` bit `SYS_SD_WP` as active-high write
protection, in addition to the card's CSD protection flags. This polarity has
not been confirmed on physical Wildbits hardware, including a socket without
a write-protect switch. The legacy driver accidentally masked away the bit,
so its behavior is not evidence for either polarity. Confirm both switch
positions and the no-switch level before deploying writes on hardware; the
software SPI-peer tests cannot establish the electrical polarity.

A transient card-detect error returns `E$NotRdy` without permanently clearing
the initialized state, allowing a subsequent read of the same card to recover.
Replacing the card still requires detaching and reattaching the device, so an
open mount cannot silently use cached geometry for a different card. CMD0 has
a bounded retry loop for warm-reset cards still leaving a busy state.

For the VHD backend, a zero FAT partition length selects the remainder of the
24-bit-record address space (`BI.Last=$007FFFFF`), not an autodetected image
length. The emulator does not expose the actual host-image size; out-of-image
I/O still fails through the backend. Use an explicit length when known.
