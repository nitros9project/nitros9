* Portable SS.ReadDir result. Multi-byte integers are big-endian.
* Name has 1..29 characters, final character high bit set; bytes after it
* are unspecified. ID is opaque, never a disk address to the caller.
RD.Name             equ       0
RD.ID               equ       29
RD.NameSize         equ       32
RD.Attr             equ       32
RD.Owner            equ       33
RD.Modified         equ       35                  year since 1900, month, day, hour, minute
RD.Links            equ       40
RD.Bytes            equ       41
RD.Size             equ       45
