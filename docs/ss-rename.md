# SS.Rename

`SS.Rename` (`$2D`) renames an entry within an open parent directory. It is
implemented by Level 1 and Level 2 RBF, and by RFM with a matching DriveWire
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
```

The first executes both assembled RBF implementations with deterministic disk
and lock peers, plus the assembled command with system-call peers. It covers
parent owner/public permissions, names, collisions, cross-sector entries,
case changes, position restoration, and I/O failures. The second exercises the
actual assembled RFM framing, validation, task-memory copying, and error reply.
DriveWire's Swift suite also tests real host filesystem renames, symlinks,
cookies, open descendants, and permission failures.
