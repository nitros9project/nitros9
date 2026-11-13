# SS.Rename

`SS.Rename` (`$2D`) renames an entry within an open parent directory. It is
implemented by Level 1 and Level 2 RBF and pcf, and by RFM with a matching DriveWire
server. The child file or directory is not opened: its read/write permission
bits do not control whether its name may change.

## Calling convention

- A: parent directory path, opened with `DIR.!WRITE.`.
- B: `SS.Rename`.
- X: address of a 60-byte request record.
- Y: 60.
- Record bytes 0–29: old basename, NUL-terminated and zero-padded.
- Record bytes 30–59: new basename, NUL-terminated and zero-padded.
- Carry clear: success. Carry set: B contains an OS-9 error.

Names must contain 1–29 printable ASCII bytes, excluding spaces, `/`, `\`,
and `:`. `.` and `..` are rejected. This operation does not move entries to
another directory or overwrite an existing destination. Case-only changes
are permitted. The `rename` utility retains normal OS-9 pathname parsing;
only the source argument may contain a directory path.

RBF checks the parent's current owner/public write permission using the calling
process's user ID. RFM uses the server process's host filesystem permissions;
it does not map guest user IDs to host users. Both require a writable directory
path mode. A writable child does not override a non-writable parent, and a
non-writable child does not prevent rename through a writable parent.

RBF updates only the name portion of the existing directory entry. Its FD
pointer, the child FD, contents, and directory position are unchanged. Level 2
holds the parent directory's whole-file lock through duplicate detection and
the update; all exits release the lock and restore the caller's position.
Pre-existing caller locks are rejected with `E$Share` rather than discarded.
Level 1 uses its existing RBF buffering and driver serialization; it does not
provide Level 2's record-locking facility.

RFM preserves numeric directory cookies and updates paths for open descendants
and legacy working directories. Renaming a symbolic link renames the link,
not its target. Host filesystem restrictions on open-file renames still apply.

Typical errors are `E$BPNam` for malformed names/records, `E$FNA` for permission
or path-mode failure, `E$PNNF` for an absent source, and `E$CEF` for a destination
collision. RBF propagates disk, lock, and transfer errors.

## pcf FAT32 behavior

pcf accepts case-insensitive ASCII 8.3 basenames through the same 60-byte
interface. It changes the existing short directory entry in place, preserves
its cluster, size, attributes and timestamps, and leaves the parent's directory
position unchanged. New aliases are uppercase; a case-only request is a
successful no-op. FAT lowercase display flags are cleared when changing a name.
No clusters are allocated or freed, and a renamed directory retains its children
and `..` link because its parent does not change.

The parent must be opened with `DIR.!WRITE.` on a writable descriptor and must
not have the FAT read-only attribute. The child's read-only attribute does not
prevent rename. Raw directory writes and resizing remain forbidden. Sources
with preceding long-name entries are rejected with `E$FNA`; cross-directory
moves, replacement of an existing destination, and LFN mutation are unsupported.

An open source file, an open source directory, or a source directory held as any
live process's data or execution directory returns `E$Share`, including references
through `/dd` and `/pc0`. Duplicated paths remain busy until the final close.
pcf holds its device-wide operation lock through lookup, collision checking and
update. Validation and sharing rejections do not write to disk. Driver errors
propagate; sector writes are not transactional under media failure or power loss.

## DriveWire framing

```
probe:   D6 0B path-number 2D -> status-byte (0 = supported)
request: D6 0C path-number 2D old-name[30] new-name[30]
reply:   status-byte (0 = success)
```

The server waits for the complete fixed-length request before acting and
returns exactly one status byte. The RFM guest copies and validates the record
before touching the wire, then masks interrupts through send/receive. Other
SetStat requests remain unsupported. RFM probes support before sending the
rename payload. A probe timeout on an older server returns `E$UnkSvc` without
sending a SetStat payload, leaving the wire parser aligned.

Install the new RFM module and the matching server together. Released
DriveWire v0.2.0-rc.2 does not implement this request. Older file managers return
`E$UnkSvc`; the updated command does not fall back to editing raw directories.

## Regression checks

With `MC6809` installed and `LWASM` set to the assembler:

```
python scripts/test-rename.py
python scripts/test-rfm.py
python scripts/test-pcf-rename.py
```

The first executes both assembled RBF implementations with deterministic disk
and lock peers, plus the assembled command with system-call peers. It covers
parent owner/public permissions, names, collisions, cross-sector entries,
case changes, position restoration, and I/O failures. The second exercises the
actual assembled RFM framing, validation, task-memory copying, and error reply.
DriveWire's Swift suite also tests real host filesystem renames, symlinks,
cookies, open descendants, and permission failures.

The pcf test executes both OS levels, including malformed records, 8.3 validation,
LFN rejection, collisions across sectors, parent state preservation, in-use
directories, and injected copy/read/write failures. The writable MAME recipe
runs 25 real parent/child rename checks, verifies zero disk writes during 16
rejections, exercises the `rename` command on files and directories, and checks
names and contents after a cold boot. Both boots end with a read-only FAT check.

```sh
make -C recipes/coco3/pcf_write_mame_test check-rename
make -C recipes/coco3/pcf_write_mame_test check
# To watch the same guest tests:
make -C recipes/coco3/pcf_write_mame_test demo
```
