COCO.D              SET       1

********************************************************************
* CoCoDefs - NitrOS-9 System Definitions for the Tandy Color Computer
*
* $Id$
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
                    TTL       NitrOS-9            System Definitions for the Tandy Color Computer


**********************
* CPU Type Definitions
*
Color               SET       1
Color3              SET       2
CPUType             SET       Color


******************************
* Clock Speed Type Definitions
*
OneMHz              EQU       1
TwoMHz              EQU       2
CPUSpeed            SET       OneMHz


**********************************
* Power Line Frequency Definitions
*
Hz50                EQU       1                   Assemble clock for 50 hz power
Hz60                EQU       2                   Assemble clock for 60 hz power
PwrLnFrq            SET       Hz60                Set to Appropriate freq


**********************************
* Ticks per second
*
TkPerSec            SET       60


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



*************************************************
*
* NitrOS-9 Level 1 Section
*
*************************************************

HW.Page             SET       $FF                 Device descriptor hardware page


*************************************************
*
* NitrOS-9 Level 2 Section
*
*************************************************

****************************************
* Dynamic Address Translator Definitions
*
* NOTE: this check assumes any NotRAM with a module will
*       always start with $87CD in first two bytes of block

***************************
* Color Computer 3 Specific
*

********************
* Hardware addresses
*




