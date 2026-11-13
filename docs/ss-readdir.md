# SS.ReadDir ($2E)

`I$GetStt` returns the next directory entry through the file manager. `dir`
uses this interface for ordinary and extended listings, with a compatibility
fallback for older RBF implementations.

## Calling convention

- A: directory path opened with `DIR.!READ.` (additional modes allowed).
- B: `SS.ReadDir`.
- X: caller-owned output buffer.
- Y: exactly `RD.NameSize` (32), or `RD.Size` (45) for metadata.
- Success: carry clear, Y unchanged, one complete result in the buffer.
- Failure: carry set, B is the OS-9 error. `E$EOF` ends enumeration.

Definitions are in `defs/readdir.d`. The 32-byte form returns a name of
1–29 characters with the last character's high bit set, followed at offset
29 by a three-byte **opaque ID**. Name padding is unspecified. The ID is
for display/identity within the file manager, not an address that the caller
can use to read disk sectors. `dir -e` labels this column `ID`.

The 45-byte form adds attributes (1), owner (2), modification date
(year since 1900, month, day, hour, minute), link count (1), and byte size (4).
All multi-byte integers are big-endian. The fields deliberately match the
existing RBF metadata prefix internally, allowing a direct copy without a
resident conversion routine. Callers use only `RD.*` definitions.

Deleted entries, `.` and `..` are skipped by the file manager. Enumeration
uses the open path's existing position; `I$Seek` to zero rewinds it. Other
positions are file-manager-specific, and unaligned positions return
`E$BPNam`. Close/open starts a fresh enumeration. Directory changes during
enumeration are not a transactional snapshot guarantee. Failed calls may
have skipped entries or consumed a remote result; do not assume automatic
retry after transport or caller-buffer errors.

Invalid counts return `E$BPNam`; a path without directory/read mode returns
`E$FNA`. RBF uses its normal read locking and buffer lifecycle. It reads child
metadata only for the extended form and retains the directory sector cache
for names-only enumeration. No path descriptor or permanent buffer grows.
RFM uses the server's existing directory snapshot and cursor; host attributes
are fetched only for extended results.

## DriveWire framing

1. Guest sends `D6 0B path 2E`.
2. Server replies with one status byte. Zero means ready for the count.
3. Guest sends the two-byte big-endian count (32 or 45).
4. Server replies with one status byte, then the requested record on success.

The server emits the record through `dataAvailableAfterReceiveBoundary`,
allowing the real CoCo bitbanger to enter its next receive call. RFM keeps
interrupts masked until the full wire transaction has finished. An older
server ignores the unknown status; the bounded ready timeout returns
`E$UnkSvc` without sending a stray count into its opcode parser.

On `E$UnkSvc` only, `dir` and `deldir` fall back to 32-byte `I$Read`
records, filtering free entries and exact `.`/`..` names. Extended `dir` uses
`SS.FDInf` to append the 13-byte metadata prefix. Other errors propagate without
fallback. This preserves older RBFs and older RFM servers that implement those
legacy interfaces. File managers with neither enumeration interface still fail.

The DriveWire record bytes are the same guest ABI, not a host-native structure:

| Record offset | Bytes | Value |
| --- | ---: | --- |
| 0 | 29 | Name, final character high bit set; padding unspecified |
| 29 | 3 | Opaque ID, big-endian |
| 32 | 1 | OS-9 attribute bits (extended form only) |
| 33 | 2 | Owner, big-endian |
| 35 | 5 | Modification year since 1900, month, day, hour, minute |
| 40 | 1 | Link count |
| 41 | 4 | Byte size, big-endian |

The first server status acknowledges the opcode before any count is sent.
The second status acknowledges the requested count; nonzero status is an OS-9
error byte and has no following record. Success sends exactly 32 or 45 bytes,
without another length prefix. End-of-directory is `E$EOF`; malformed counts
return `E$BPNam`. The server must retain its snapshot/cursor between requests
and implement rewind through the existing seek operation.

## Size and verification

Compared with NitrOS-9 commit `96d547b4`, using lwasm's OS-9 output and the
same Level/CPU settings on both sides (including module header and CRC):

| Module | Before | After | Change |
|---|---:|---:|---:|
| Level 1 RBF, 6809 or 6309 | 3,935 | 4,106 | +171 |
| Level 2 RBF, 6809 | 5,279 | 5,454 | +175 |
| Level 2 RBF, 6309 | 5,184 | 5,359 | +175 |
| Level 1 RFM, either CPU | 1,623 | 1,712 | +89 |
| Level 2 RFM, either CPU | 1,659 | 1,748 | +89 |
| dir, either level/CPU | 927 | 896 | −31 |

There is no additional resident data. A Level 2 system containing both file
managers gains 264 resident code bytes; an RFM-only boot gains 89. The
transient command saving is separate.

`scripts/test-readdir.py` executes assembled RBF and `dir` code on MC6809.
It covers filtering, maximum names, cached sectors, optional metadata,
cursor advancement, rewind constraints, EOF, invalid modes/counts, copy and
I/O failures, and narrow/wide ordinary/extended command output.
`scripts/test-rfm.py` covers the wire handshake, interrupt masks, old-server
timeout, EOF/error propagation, and caller-copy errors on both levels.
The existing rename regression tests also pass. All 6809/6309 variants
assemble. The DriveWire tests cover server enumeration, metadata failure,
rewind, fragmented counts, and the serial receive boundary.

`deldir` uses names-only SS.ReadDir records for recursive deletion. It retains
RBF-specific attribute clearing only for RBF devices; pcf removes directories
directly. MAME verifies nested FAT32 deletion and cancellation.

Real CoCo validation of ReadDir is still pending; existing running servers
have not been restarted by this change.
