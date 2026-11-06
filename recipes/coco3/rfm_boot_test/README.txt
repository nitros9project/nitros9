CoCo 3 boot with an RFM system device
====================================

This recipe boots the kernel track from a local floppy, fetches OS9Boot as a
plain file from Swift DriveWire, and uses an RFM descriptor as /DD. There is
no RBF file manager or disk driver in the bootfile and no virtual disk mounted
on the server. The bootstrap floppy has only a kernel track: its root is empty
and its local OS9Boot address and length fields are zero.

Build and check from this directory:

    make check DRIVEWIRE_CLI=/path/to/drivewire-cli

The matching Swift DriveWire server must include immutable directory cookies
and device-root parent clamping: /DD/.. stays /DD. CoWin needs this when it
loads ../CMDS/grfdrv before SysGo runs. Set MAME_BINARY and MAME_ROMPATH if
needed; ROMs default to ~/.local/share/mame/roms. TCP 65504 must be free. The
runner starts its own Swift server and stops its processes after the check.

The check verifies remote loads of OS9Boot, grfdrv, SysGo, and Shell; a live
module listing containing RFM/RFMDrv/DWIO/DD and no RBF drivers; a /DD directory
listing; and a completion marker written back through RFM. No startup file is
installed. Test commands are posted explicitly after boot.

For a visible, interactive shell (no automatic test commands):

    make run DRIVEWIRE_CLI=/path/to/drivewire-cli

Generated files are under .rfm-boot:

    host/OS9Boot       plain bootfile fetched by boot_rfm_becker
    host/DD/sysgo      initial process loaded through RFM
    host/DD/CMDS       shell, graphics driver, and utilities
    host/DD/SYS        system data files
    host/DD/boot*      output from the automated check
    swift.log         actual Swift server transactions
    screen.png        emulator screenshot
    result.json       verification result

This demonstrates a fully RFM-backed NitrOS-9 filesystem after the local
bootstrap track. It does not claim ROM/network-only initial bootstrap.
