* Portable SS.ReadDir result. Multi-byte integers are big-endian.
* Name has 1..29 characters, final character high bit set; bytes after it
* are unspecified. ID is opaque, never a disk address to the caller.
RD.Name             equ       0         ; define constant or offset
RD.ID               equ       29        ; define constant or offset
RD.NameSize         equ       32        ; define constant or offset
RD.Attr             equ       32        ; define constant or offset
RD.Owner            equ       33        ; define constant or offset
RD.Modified         equ       35                  year since 1900, month, day, hour, minute
RD.Links            equ       40        ; define constant or offset
RD.Bytes            equ       41        ; define constant or offset
RD.Size             equ       45        ; define constant or offset
