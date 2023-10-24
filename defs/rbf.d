                    IFNE      RBF.D-1

RBF.D               SET       1

********************************************************************
* rbf.d - Random Block File Manager Definitions
*
* $Id$
*
* RBF stands for 'Random Block Filemanager' and is a package of subroutines
* that define the logical structure of a disk and allows access to the files
* in that structure.
*
* The data structures in this file give RBF its 'personality' and are used
* by RBF itself, as well as applications that will require disk I/O.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          1982/07/13  Robert F. Doggett
* PD.Exten added to path descriptor and PE Entries defined.
*
*          1982/07/15  Robert F. Doggett
* V.FileHd inserted in driver static storage.
*
*          1982/09/10  WGP
* Level One/Level Two condionals added.
*
*          1982/09/17  WGP
*
*          1982/09/17  Robert F. Doggett
* PD.SLE renamed to PD.Creat.
*
*          1982/09/17  Robert F. Doggett
* V.DiskID, V.BMapSz, V.MapSct added for smart multi-sector bitmap searching.
*
*          1982/09/20  Robert F. Doggett
* Reserved areas added in static storage.

*          1983/06/07  Robert F. Doggett
* Added InDriver flag in PD.SMF.
*
*          1983/06/13  Robert F. Doggett
* Added PE.Req tmp save for PE.Lock.
*
*          1983/08/08  Robert F. Doggett
* Reserved PD.SToff for Japanese.
*
*          1983/11/19  Robert F. Doggett
* Added V.ResBit in drive tables.
*
*          1983/12/12  Robert F. Doggett
* Added PE.Prior to save process priority.
*
*          1983/12/13  Robert F. Doggett
* Added BufBusy bit in state flag (PD.SMF).
*
*          1984/07/06  Mark G. Hawkins
* Added Bit Definitions for DD.FMT.
*
*          1987/06/23  Kevin K. Darling
* Updated with Dev Desc Info
*
*          2003/06/02  Boisy G. Pitre
* Updated comments for clarity.
* Added TYP.256-TYP.2048 definitions for future expansion.
*
*          2004/04/14  Boisy G. Pitre
* Added new entries to device descriptor as per OS-9 Level One V2.00.00
* addendum.  Pointed out by Rodney Hamilton.
*
*	       2005/05/31  P.Harvey-Smith.
* Added defines for bit 2 of IT.DNS, which the format command uses to
* determine if a drive should have it's track 0 as single or double density
*
*          2005/11/23  Robert Gault
* Added IT.MPI giving it duplicate location with IT.TFM. This will not be
* transferred to the path descriptor, thus the  equ *  rahter than  rmb 1.
*
*          2005/12/11  Boisy G. Pitre
* Added IT.SOFF1-ITSOFF3 and IT.LLDRV for SuperDrivers.

                    NAM       rbf.d
                    TTL       Random              Block File Manager Definitions

                    PAG
*******************************
* RBF Device Descriptor Offsets
*
* These definitions are for RBF device descriptors.

                    ORG       M$DTyp
                    RMB       1                   Device type (DT.RBF)
IT.DRV              RMB       1                   Drive number
IT.STP              RMB       1                   Step rate
IT.TYP              RMB       1                   Disk device type information
IT.DNS              RMB       1                   Density capability
IT.CYL              RMB       2                   Number of cylinders
IT.SID              RMB       1                   Number of surfaces
IT.VFY              RMB       1                   Verify disk writes (0 = verify, 1 = don't)
IT.SCT              RMB       2                   Default sectors/track
IT.T0S              RMB       2                   Default sectors/track for track 0 sector 0
IT.ILV              RMB       1                   Sector interleave offset
IT.SAS              RMB       1                   Segment allocation size
* The following fields are from the OS-9 Level One V2.00.00 Addendum
IT.TFM              RMB       1                   DMA Transfer Mode
IT.Exten            RMB       2                   Path Extension (PE) for record locking
IT.SToff            RMB       1                   Sector/Track offsets (for "foreign" disk formats)
* The following fields are not copied to the path descriptor
IT.WPC              RMB       1                   Write precomp cyl/4 (HD)
IT.OFS              RMB       2                   Starting cylinder offset (HD)
IT.RWC              RMB       2                   Reduced write current cylinder (HD)
* These fields have been added because of SuperDriver.  They probably
* can be used in other drivers
                    ORG       IT.WPC
IT.SOFF1            RMB       1
IT.SOFF2            RMB       1
IT.SOFF3            RMB       1
IT.LLDRV            RMB       2
IT.MPI              RMB       1


* IT.TYP Definitions
*
TYP.HARD            EQU       %10000000           Hard disk
TYP.FLP             EQU       %00000000           Floppy disk
TYP.NSF             EQU       %01000000           Non-standard format
TYP.SOF             EQU       %00000000           Standard NitrOS-9 format

* IT.TYP bit definitions if bit 7 of IT.TYP is set (hard disk)
TYPH.256            EQU       %00000000           256 byte sector media
TYPH.512            EQU       %00000001           512 byte sector media
TYPH.1024           EQU       %00000010           1024 byte sector media
TYPH.2048           EQU       %00000011           2048 byte sector media
TYPH.SSM            EQU       %00000011           Sector size mask
TYPH.DRSV           EQU       %00001100           Driver-reserved bits
TYPH.DSQ            EQU       %00010000           Drive size query flag

* IT.TYP bit definitions if bit 7 of IT.TYP is clear (floppy disk)
TYP.5               EQU       %00000000           5" media
TYP.3               EQU       %00000001           3.5" media
TYP.SBO             EQU       %00000010           Sector base offset (clear = 0; sect = 1)
TYP.256             EQU       %00000000           256 byte sector media
TYP.512             EQU       %00000100           512 byte sector media
TYP.CCF             EQU       %00100000           CoCo format
TYP.NCCF            EQU       %00000000           Non-CoCo format

* IT.DNS Definitions
*

* If bit 7 of IT.TYP is set, IT.DNS is driver-dependent

* IT.DNS bit definitions if bit 7 of IT.TYP is clear (floppy disk)
DNS.FM              EQU       %00000000           Single-density (FM)
DNS.MFM             EQU       %00000001           Double-density (MFM)
DNS.STD             EQU       %00000000           Single track distance (48/135 tpi)
DNS.DTD             EQU       %00000010           Double track distance (96 tpi)

* Added PHS,2005-05-31, as format seems to use these
DNS.FM0             EQU       %00000000           Single density track 0
DNS.MFM0            EQU       %00000100           Double density track 0

* Floppy disk step rate definitions
STP.30ms            EQU       0                   30ms step rate
STP.20ms            EQU       1                   20ms step rate
STP.12ms            EQU       2                   12ms step rate
STP.6ms             EQU       3                   6ms step rate

                    PAG
*************************************
* Random Block Path Descriptor Format
*
* A path descriptor is created for every new path that is open
* via the I$Open system call (processed by IOMan).  Process
* descriptors track state information of a path.
*
                    ORG       PD.FST
PD.SMF              RMB       1                   State flags
PD.CP               RMB       4                   Current logical byte position
PD.SIZ              RMB       4                   File size
PD.SBL              RMB       3                   Segment beginning lsn
PD.SBP              RMB       3                   Segment beginning psn
PD.SSZ              RMB       3                   Segment size
PD.DSK              RMB       2                   Disk id
PD.DTB              RMB       2                   Drive table ptr
                    ORG       PD.OPT
                    RMB       1                   Device type
PD.DRV              RMB       1                   Drive number
PD.STP              RMB       1                   Step rate
PD.TYP              RMB       1                   Disk device type (5" 8" other)
PD.DNS              RMB       1                   Density capability
PD.CYL              RMB       2                   Number of cylinders
PD.SID              RMB       1                   Number of surfaces
PD.VFY              RMB       1                   0=verify disk writes
PD.SCT              RMB       2                   Default sectors/track
PD.T0S              RMB       2                   Default sectors/track tr00,s0
PD.ILV              RMB       1                   Sector interleave offset
PD.SAS              RMB       1                   Segment allocation size
PD.TFM              RMB       1                   DMA Transfer Mode
PD.Exten            RMB       2                   Path Extension (PE) for record locking
PD.SToff            RMB       1                   Sector/Track offsets (for "foreign" disk formats)
PD.ATT              RMB       1                   File attributes
PD.FD               RMB       3                   File descriptor psn
PD.DFD              RMB       3                   Directory file descriptor psn
PD.DCP              RMB       4                   File directory entry ptr
PD.DVT              RMB       2                   User readable dev tbl ptr

* State Flags
BUFMOD              EQU       $01                 Buffer modified
SINBUF              EQU       $02                 Sector in buffer
FDBUF               EQU       $04                 File descriptor in buffer
*EOFSEC equ $08 End of file sector
*EOF equ $10 End of file
InDriver            EQU       $20                 Currently in Disk Driver, or queued
BufBusy             EQU       $40                 Buffer is currently busy

                    IFNE      Level-1
************************************
* Random Block Path Extension Format
*
* RBF paths under Level Two have additional information that
* is referenced by the path extension area.
*
                    ORG       0
PE.PE               RMB       1                   PE path number
PE.PDptr            RMB       2                   Back ptr to this PE's Path Descriptor
PE.NxFil            RMB       2                   Drive Open-File list ptr
PE.Confl            RMB       2                   Circular File Conflict list
PE.Lock             RMB       1                   Path lockout status
PE.LoLck            RMB       4                   Low Locked Logical addr
PE.HiLck            RMB       4                   High Locked Logical addr
PE.Wait             RMB       2                   PE ptr to (next) locked-out PE
PE.TmOut            RMB       2                   Max ticks to wait for locked segment
PE.Owner            RMB       1                   Process ID of owner of locked segment
PE.Req              RMB       1                   Temp for PE.Lock in GAIN when LockSeg fails
PE.Prior            RMB       1                   Temp for process priority while in driver
PE.SigSg            RMB       1                   Signal code to send
PE.SigID            RMB       1                   Process ID to send the signal to
                    RMB       32-.                Reserved
PE.FilNm            RMB       32                  Temp for filename during directory search

* PE.Lock status codes
Unlocked            EQU       0                   No portion of file is locked
RcdLock             EQU       1                   Record from LoLck to HiLck locked
FileLock            EQU       2                   Entire file locked
EofLock             EQU       4                   End of file is locked
                    ENDC


                    PAG
***********************
* LSN0 Disk Data Format
*
* Logical Sector Number 0 is the first sector on an RBF formatted device
* and contains information about the device's size and format.
*
                    ORG       0
DD.TOT              RMB       3                   Total number of sectors
DD.TKS              RMB       1                   Track size in sectors
DD.MAP              RMB       2                   Number of bytes in allocation bit map
DD.BIT              RMB       2                   Number of sectors/bit
DD.DIR              RMB       3                   Address of root directory fd
DD.OWN              RMB       2                   Owner
DD.ATT              RMB       1                   Attributes
DD.DSK              RMB       2                   Disk ID
DD.FMT              RMB       1                   Disk format; density/sides
DD.SPT              RMB       2                   Sectors/track
DD.RES              RMB       2                   Reserved for future use
DD.SIZ              EQU       .                   Device descriptor minimum size
DD.BT               RMB       3                   System bootstrap sector
DD.BSZ              RMB       2                   Size of system bootstrap
DD.DAT              RMB       5                   Creation date
DD.NAM              RMB       32                  Volume name
DD.OPT              RMB       32                  Option area

*************************
* 2012/11/09 Gene Heskett - Some additions for bootlink etc use.
                    ORG       $60                 More options from device descriptor
VD.STP              RMB       1                   This is for the /sh and /ih virtual disks in HDBDOS
VD.OFS              RMB       3                   This is DT.WPC and DT.OSF combined, might be more

* DD.FMT Bit Definitions - valid only if device is a floppy disk
FMT.SIDE            EQU       %00000001           Single Sided=0, Double Sided=1
FMT.DNS             EQU       %00000010           Single Density=0, Double Density=1
FMT.TDNS            EQU       %00000100           Track Density: 48/135 TPI=0, 96 TPI=1
FMT.T0DN            EQU       %00100000           Track 0 Density, see FMT.DNS


                    PAG
************************
* File Descriptor Format
*
* The file descriptor is a sector that is present for every file
* on an RBF device.  It contains attributes, modification dates,
* and segment information on a file.
*
                    ORG       0
FD.ATT              RMB       1                   Attributes
FD.OWN              RMB       2                   Owner
FD.DAT              RMB       5                   Date last modified
FD.LNK              RMB       1                   Link count
FD.SIZ              RMB       4                   File size
FD.Creat            RMB       3                   File creation date (YY/MM/DD)
FD.SEG              EQU       .                   Beginning of segment list
* Segment List Entry Format
                    ORG       0
FDSL.A              RMB       3                   Segment beginning physical sector number
FDSL.B              RMB       2                   Segment size
FDSL.S              EQU       .                   Segment list entry size
FD.LS1              EQU       FD.SEG+((256-FD.SEG)/FDSL.S-1)*FDSL.S
FD.LS2              EQU       (256/FDSL.S-1)*FDSL.S
MINSEC              SET       16


                    PAG
************************
* Directory Entry Format
*
* Directory entries are part of a directory and define the name
* of the file, as well as a pointer to its file descriptor.
*
                    ORG       0
DIR.NM              RMB       29                  File name
DIR.FD              RMB       3                   File descriptor physical sector number
DIR.SZ              EQU       .                   Directory record size


                    PAG
********************
* RBF Static Storage
*
* Overall Disk Static Storage
*
* Note:  This does not reserve any memory for drive tables.  Each
*        driver is responsible for reserving sufficient memory for
*        the appropriate number of tables.
*
                    ORG       V.USER              Reserve required           ($06)
V.NDRV              RMB       1                   Number of drives           ($07)
                    RMB       8                   reserved                   ($08)
DRVBEG              EQU       .                   Beginning of drive tables  ($10)


                    PAG
****************
* Global Storage For Disk Drive Tables
*
* Each table contains the first 'DD.SIZ' bytes from
* LSN 0, and the current track, stepping rate,
* bitmap use flag, and disk type.
*
                    ORG       0
                    RMB       DD.SIZ              Device descriptor, LSN 0
V.TRAK              RMB       2                   Current track
V.BMB               RMB       1                   Bit-map use flag
V.FileHd            RMB       2                   Open file list for this drive
V.DiskID            RMB       2                   Disk ID
V.BMapSz            RMB       1                   Bitmap Size
V.MapSct            RMB       1                   Lowest reasonable bitmap sector
V.ResBit            RMB       1                   Reserved bitmap sector (for compaction)
V.ScTkOf            RMB       1                   Sector/Track byte (Combined from descriptor)
V.ScOfst            RMB       1                   Sector offset split from byte above
V.TkOfst            RMB       1                   Track offset split from byte above
                    RMB       4                   Reserved
DRVMEM              EQU       .

                    ENDC

