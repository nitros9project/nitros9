# OS-9 debugging helpers

`list2crc.pl` converts an `lwasm` listing into files named for the CRC of each
module. `os9.gdb` provides GDB commands that use those files to associate a
loaded OS-9 module with its assembly listing.

The GDB commands assume `gvim` is available for displaying source. These are
specialized debugging aids rather than build dependencies.
