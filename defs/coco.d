                    IFNE      COCO.D-1
COCO.D              SET       1

********************************************************************
* CoCoDefs - NitrOS-9 System Definitions for the Tandy Color Computer
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          1998/10/13  Boisy G. Pitre
* Added defs by Bruce Isted from his Eliminator archive.
*
*          1998/10/31  Boisy G. Pitre
* Merged cc3global.defs into this file.
*
*          2002/04/30  Boisy G. Pitre
* Merged Level One and Level Two sysdefs.
*
*          2002/06/22  Boisy G. Pitre
* Removed PIA.U4 and PIA.U8, improved comments
*
*          2003/11/05  Robert Gault
* Made changes in window globals and grfdrv memory to handle regW
* in 6809 systems.
*
*          2003/11/30  Boisy G. Pitre
* Statics now are prefaced with V. to identify them easier in source.
*
*          2004/07/18  Boisy G. Pitre
* Moved CoCo 3 Window stuff into cc3iodefs
*
*          2012/02/24  Boisy G. Pitre
* Consolidated all CoCo-specific defs files into here.

                    NAM       CoCoDefs
                    IFEQ      Level-1
                    TTL       NitrOS-9            System Definitions for the Tandy Color Computer
                    ELSE
                    IFEQ      Level-2
                    TTL       NitrOS-9            Level 2 System Type Definitions
                    ELSE
                    IFEQ      Level-3
                    TTL       NitrOS-9            Level 3 System Type Definitions
                    ENDC
                    ENDC
                    ENDC


**********************
* CPU Type Definitions
*
Color               SET       1
Color3              SET       2
                    IFEQ      Level-1
CPUType             SET       Color
                    ELSE
CPUType             SET       Color3
                    ENDC


******************************
* Clock Speed Type Definitions
*
OneMHz              EQU       1
TwoMHz              EQU       2
                    IFEQ      CPUType-Color
CPUSpeed            SET       OneMHz
                    ELSE
CPUSpeed            SET       TwoMHz
                    ENDC


**********************************
* Power Line Frequency Definitions
*
Hz50                EQU       1                   Assemble clock for 50 hz power
Hz60                EQU       2                   Assemble clock for 60 hz power
                    IFNDEF    PwrLnFrq
PwrLnFrq            SET       Hz60                Set to Appropriate freq
                    ENDC


**********************************
* Ticks per second
*
                    IFNDEF    TkPerSec
                    IFEQ      PwrLnFrq-Hz50
TkPerSec            SET       50
                    ELSE
TkPerSec            SET       60
                    ENDC
                    ENDC


******************
* ACIA type set up
*
                    ORG       1
ACIA6850            RMB       1                   MC6850 acia.
ACIA6551            RMB       1                   SY6551 acia.
ACIA2661            RMB       1                   SC2661 acia.
ACIATYPE            SET       ACIA6551


****************************************
* Special character Bit position equates
*
SHIFTBIT            EQU       %00000001
CNTRLBIT            EQU       %00000010
ALTERBIT            EQU       %00000100
UPBIT               EQU       %00001000
DOWNBIT             EQU       %00010000
LEFTBIT             EQU       %00100000
RIGHTBIT            EQU       %01000000
SPACEBIT            EQU       %10000000


******************
* Device addresses for miscellaneous hardware
*
A.AciaP             SET       $FF68               Aciapak Address
A.ModP              SET       $FF6C               ModPak Address
DPort               SET       $FF40               Disk controller base address
MPI.Slct            SET       $FF7F               Multi-Pak slot select
MPI.Slot            SET       $03                 Multi-Pak default slot
PIA0Base            EQU       $FF00
PIA1Base            EQU       $FF20


******************
* VDG Devices
*
A.TermV             SET       $FFC0               VDG Term
A.V1                SET       $FFC1               Possible additional VDG Devices
A.V2                SET       $FFC2
A.V3                SET       $FFC3
A.V4                SET       $FFC4
A.V5                SET       $FFC5
A.V6                SET       $FFC6
A.V7                SET       $FFC7


                    IFEQ      Level-1

********************************
* Boot defs for NitrOS-9 Level 1
*
* These defs are not strictly for 'Boot', but are for booting the
* system.
*
Bt.Start            EQU       $EE00               Start address of the boot track in memory

                    ELSE

******************************************
* Boot defs for NitrOS-9 Level 2 and above
*
* These defs are not strictly for 'Boot', but are for booting the
* system.
*
Bt.Start            SET       $ED00               Start address of the boot track in memory
Bt.Block            EQU       $3B                 Block to map in for the 'OS9BOOT' screen
Bt.Flag             EQU       $8A34               Flag in Bt.Block to verify that it's unchanged
Bt.Offst            EQU       2                   Offset into the screen where the current ptr is

                    ENDC

* On the CoCo, the boot track is all of track 34

Bt.Track            EQU       34                  Boot track
Bt.Sec              EQU       0                   Start LSN of boot area on boot track


Bt.Size             EQU       $1080               Maximum size of bootfile


                    IFEQ      Level-1

*************************************************
*
* NitrOS-9 Level 1 Section
*
*************************************************

HW.Page             SET       $FF                 Device descriptor hardware page

                    ELSE

*************************************************
*
* NitrOS-9 Level 2 Section
*
*************************************************

****************************************
* Dynamic Address Translator Definitions
*
DAT.BlCt            EQU       8                   D.A.T. blocks/address space
DAT.BlSz            EQU       (256/DAT.BlCt)*256  D.A.T. block size
DAT.ImSz            EQU       DAT.BlCt*2          D.A.T. Image size
DAT.Addr            EQU       -(DAT.BlSz/256)     D.A.T. MSB Address bits
DAT.Task            EQU       $FF91               Task Register address
DAT.TkCt            EQU       32                  Number of DAT Tasks
DAT.Regs            EQU       $FFA0               DAT Block Registers base address
DAT.Free            EQU       $333E               Free Block Number
DAT.BlMx            EQU       $3F                 Maximum Block number
DAT.BMSz            EQU       $40                 Memory Block Map size
DAT.WrPr            EQU       0                   no write protect
DAT.WrEn            EQU       0                   no write enable
SysTask             EQU       0                   Coco System Task number
IOBlock             EQU       $3F
ROMBlock            EQU       $3F
IOAddr              EQU       $7F
ROMCount            EQU       1                   number of blocks of ROM (High RAM Block)
RAMCount            EQU       1                   initial blocks of RAM
MoveBlks            EQU       DAT.BlCt-ROMCount-2 Block numbers used for copies
BlockTyp            EQU       1                   chk only first bytes of RAM block
ByteType            EQU       2                   chk entire block of RAM
Limited             EQU       1                   chk only upper memory for ROM modules
UnLimitd            EQU       2                   chk all NotRAM for modules
* NOTE: this check assumes any NotRAM with a module will
*       always start with $87CD in first two bytes of block
RAMCheck            EQU       BlockTyp            chk only beg bytes of block
ROMCheck            EQU       Limited             chk only upper few blocks for ROM
LastRAM             EQU       IOBlock             maximum RAM block number

***************************
* Color Computer 3 Specific
*
MappedIO            EQU       true                (Actually False but it works better this way)

********************
* Hardware addresses
*
GIMERegs            EQU       $FF00               Base address of GIME registers
IrqEnR              EQU       $FF92               GIME IRQ enable/status register
BordReg             EQU       $FF9A               Border color register
PalAdr              EQU       $FFB0               Palette registers

HW.Page             SET       $07                 Device descriptor hardware page

* KrnBlk defines the block number of the 8K RAM block that is mapped to
* the top of CPU address space ($E000-$FFFF) for the system process, and
* which holds the Kernel. The top 2 pages of this CPU address space ($FFE0-
* $FFFF) has two special properties. Firstly, it contains the I/O space.
* Secondly, the parts that contain RAM map are not affected by the DAT
* mappings but, instead, *always* map that RAM to a fixed RAM block
* (KrnBlk). When a user process is mapped in, and requests enough memory,
* it will end up with its own block assigned for CPU address space $E000-
* $FFFF but the top of the address space is unusable by the user process:
* it still contains the I/O and the bit of RAM that's mapped to KrnBlk.
* Usually, the value of KrnBlk is fixed for a particular hardware design;
* For the COCO GIME, it's always $3F.
KrnBlk              SET       $3F

                    ENDC
                    ENDC

