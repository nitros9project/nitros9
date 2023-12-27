
OS9.D               SET       1

********************************************************************
* os9.d - NitrOS-9 System Definitions
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          1985/08/29  KMZ
* Fixed DT.SBF/NFM values to 3/4
*
*          1985/09/01  KMZ
* Added SS.FDInf, SS.Attr to accept 68K request thru NET.
*
*          1985/09/03  KMZ/Robert F. Doggett
* Eliminated E$BPrcID, made Error #238 become E$DNE for
* 68000 compatability.
*
*          1986/04/15  Mark G. Hawkins
* F$AlHRAM System call added for COCO.
*
*          1986/09/08  Mark G. Hawkins
* F$Alarm for COCO Clock Module.
*
*          1986/09/17  Mark G. Hawkins
* SS.Tone For COCO.
*
*          1986/09/23  Mark G. Hawkins
* Added F$NMLink and F$NMLoad for COCO.
*
*          1986/09/30  Mark G. Hawkins
* Added Reserved User $70 to $7f in sytem calls.
*
*          1986/09/30  Mark G. Hawkins
* Created Color Computer 3 Version of OS9Defs.
*
*          1998/10/03  Boisy G. Pitre
* Consoldated Level 1/Level 2 os9defs.
*
*          2002/04/04  Boisy G. Pitre
* Consoldated Level 2/Level 2 V3 os9defs.
*
*          2002/04/30  Boisy G. Pitre
* Added NitrOS-9 definitions.
*
*          2003/05/30  Boisy G. Pitre
* Added WD1002 sys vars to Level One section.
*
*          2003/06/02  Boisy G. Pitre
* Fixed incorrectly ordered D.X*** system globals for OS-9 Level One and
* changed the sizes from 2 to 3 bytes.
* DT.NFM is now the same for both Level One and Level Two.
* Added DT.CDFM type for future CD-ROM file manager
*
*          2003/11/05  Robert Gault
* Fixed MouseInf. Made it rmb 2 as it should be. Also changes to init and cc3io.
*
*	       2005/11/02  P.Harvey-Smith
* Added definitions for boot areas on Dragon computers.
*
*	       2006/03/03  Boisy G. Pitre
* Added F$Debug and D.DbgMem areas, common to all levels of NitrOS-9

                    NAM       os9.d
                    TTL       NitrOS-9            Level 1 System Symbol Definitions

* Common definitions
true                EQU       1                   useful name
false               EQU       0                   useful name

                    PAG
*****************************************
* System Service Request Code Definitions
*
                    ORG       0
F$Link              RMB       1                   Link to Module
F$Load              RMB       1                   Load Module from File
F$UnLink            RMB       1                   Unlink Module
F$Fork              RMB       1                   Start New Process
F$Wait              RMB       1                   Wait for Child Process to Die
F$Chain             RMB       1                   Chain Process to New Module
F$Exit              RMB       1                   Terminate Process
F$Mem               RMB       1                   Set Memory Size
F$Send              RMB       1                   Send Signal to Process
F$Icpt              RMB       1                   Set Signal Intercept
F$Sleep             RMB       1                   Suspend Process
F$SSpd              RMB       1                   Suspend Process
F$ID                RMB       1                   Return Process ID
F$SPrior            RMB       1                   Set Process Priority
F$SSWI              RMB       1                   Set Software Interrupt
F$PErr              RMB       1                   Print Error
F$PrsNam            RMB       1                   Parse Pathlist Name
F$CmpNam            RMB       1                   Compare Two Names
F$SchBit            RMB       1                   Search Bit Map
F$AllBit            RMB       1                   Allocate in Bit Map
F$DelBit            RMB       1                   Deallocate in Bit Map
F$Time              RMB       1                   Get Current Time
F$STime             RMB       1                   Set Current Time
F$CRC               RMB       1                   Generate CRC ($17)


* NitrOS-9 Level 2 system calls


* NitrOS-9 Level 1 system call padding
                    RMB       11


F$Debug             RMB       1                   Drop the system into the debugger ($23)




                    ORG       $27                 Beginning of System Reserved Calls
* NitrOS-9 common system calls
F$VIRQ              RMB       1                   Install/Delete Virtual IRQ
F$SRqMem            RMB       1                   System Memory Request
F$SRtMem            RMB       1                   System Memory Return
F$IRQ               RMB       1                   Enter IRQ Polling Table
F$IOQu              RMB       1                   Enter I/O Queue
F$AProc             RMB       1                   Enter Active Process Queue
F$NProc             RMB       1                   Start Next Process
F$VModul            RMB       1                   Validate Module
F$Find64            RMB       1                   Find Process/Path Descriptor
F$All64             RMB       1                   Allocate Process/Path Descriptor
F$Ret64             RMB       1                   Return Process/Path Descriptor
F$SSvc              RMB       1                   Service Request Table Initialization
F$IODel             RMB       1                   Delete I/O Module



* Alan DeKok additions


*
* Numbers $70 through $7F are reserved for user definitions
*
                    ORG       $70


                    RMB       16                  Reserved for user definition




                    PAG
**************************************
* I/O Service Request Code Definitions
*
                    ORG       $80
I$Attach            RMB       1                   Attach I/O Device
I$Detach            RMB       1                   Detach I/O Device
I$Dup               RMB       1                   Duplicate Path
I$Create            RMB       1                   Create New File
I$Open              RMB       1                   Open Existing File
I$MakDir            RMB       1                   Make Directory File
I$ChgDir            RMB       1                   Change Default Directory
I$Delete            RMB       1                   Delete File
I$Seek              RMB       1                   Change Current Position
I$Read              RMB       1                   Read Data
I$Write             RMB       1                   Write Data
I$ReadLn            RMB       1                   Read Line of ASCII Data
I$WritLn            RMB       1                   Write Line of ASCII Data
I$GetStt            RMB       1                   Get Path Status
I$SetStt            RMB       1                   Set Path Status
I$Close             RMB       1                   Close Path
I$DeletX            RMB       1                   Delete from current exec dir

*******************
* File Access Modes
*
READ.               EQU       %00000001
WRITE.              EQU       %00000010
UPDAT.              EQU       READ.+WRITE.
EXEC.               EQU       %00000100
PREAD.              EQU       %00001000
PWRIT.              EQU       %00010000
PEXEC.              EQU       %00100000
SHARE.              EQU       %01000000
DIR.                EQU       %10000000
ISIZ.               EQU       %00100000

**************
* Signal Codes
*
                    ORG       0
S$Kill              RMB       1                   Non-Interceptable Abort
S$Wake              RMB       1                   Wake-up Sleeping Process
S$Abort             RMB       1                   Keyboard Abort
S$Intrpt            RMB       1                   Keyboard Interrupt
S$Window            RMB       1                   Window Change
S$HUP               EQU       S$Window            Hang Up
S$Alarm             RMB       1                   CoCo individual process' alarm signal

                    PAG
**********************************
* Status Codes for GetStat/GetStat
*
                    ORG       0
SS.Opt              RMB       1                   Read/Write PD Options
SS.Ready            RMB       1                   Check for Device Ready
SS.Size             RMB       1                   Read/Write File Size
SS.Reset            RMB       1                   Device Restore
SS.WTrk             RMB       1                   Device Write Track
SS.Pos              RMB       1                   Get File Current Position
SS.EOF              RMB       1                   Test for End of File
SS.Link             RMB       1                   Link to Status routines
SS.ULink            RMB       1                   Unlink Status routines
SS.Feed             RMB       1                   Issue form feed
SS.Frz              RMB       1                   Freeze DD. information
SS.SPT              RMB       1                   Set DD.TKS to given value
SS.SQD              RMB       1                   Sequence down hard disk
SS.DCmd             RMB       1                   Send direct command to disk
SS.DevNm            RMB       1                   Return Device name (32-bytes at [X])
SS.FD               RMB       1                   Return File Descriptor (Y-bytes at [X])
SS.Ticks            RMB       1                   Set Lockout honor duration
SS.Lock             RMB       1                   Lock/Release record
SS.DStat            RMB       1                   Return Display Status (CoCo)
SS.Joy              RMB       1                   Return Joystick Value (CoCo)
SS.BlkRd            RMB       1                   Block Read
SS.BlkWr            RMB       1                   Block Write
SS.Reten            RMB       1                   Retension cycle
SS.WFM              RMB       1                   Write File Mark
SS.RFM              RMB       1                   Read past File Mark
SS.ELog             RMB       1                   Read Error Log
SS.SSig             RMB       1                   Send signal on data ready
SS.Relea            RMB       1                   Release device
SS.AlfaS            RMB       1                   Return Alfa Display Status (CoCo, SCF/GetStat)
SS.Attr             EQU       SS.AlfaS            To serve 68K/RBF/SetStat only, thru NET
SS.Break            RMB       1                   Send break signal out acia
SS.RsBit            RMB       1                   Reserve bitmap sector (do not allocate in) LSB(X)=sct#
                    RMB       1                   Reserved
SS.FDInf            EQU       $20                 To serve 68K/RBF/GetStat only, thru NET
SS.DirEnt           RMB       1                   Reserve bitmap sector (do not allocate in) LSB(X)=sct#
                    RMB       3                   Reserve $20-$23 for Japanese version (Hoshi)
SS.SetMF            RMB       1                   Reserve $24 for Gimix G68 (Flex compatability?)
SS.Cursr            RMB       1                   Cursor information for COCO
SS.ScSiz            RMB       1                   Return screen size for COCO
SS.KySns            RMB       1                   Getstat/SetStat for COCO keyboard
SS.ComSt            RMB       1                   Getstat/SetStat for Baud/Parity
SS.Open             RMB       1                   SetStat to tell driver a path was opened
SS.Close            RMB       1                   SetStat to tell driver a path was closed
SS.HngUp            RMB       1                   SetStat to tell driver to hangup phone
SS.FSig             RMB       1                   New signal for temp locked files
SS.DSize            EQU       SS.ScSiz            Return disk size (RBF GetStat)
SS.VarSect          EQU       SS.DStat            Variable Sector Size (RBF GetStat)

* System Specific and User defined codes above $80
                    ORG       $80
SS.AAGBf            RMB       1                   SetStat to Allocate Additional Graphic Buffer
SS.SLGBf            RMB       1                   SetStat to Select a different Graphic Buffer
SS.Mount            RMB       1                   Network 4 Mount Setstat
SS.RdNet            RMB       1                   Read Raw Sector from Network 4 Omnidrive
SS.MpGPB            RMB       1                   SetStat to request a Get/Put Buffer be mapped in workspace
SS.Slots            RMB       1                   Network 4 slots? getstat

*               IFGT      Level-1
* Level 2 Windowing
SS.WnSet            RMB       1                   Set up High Level Windowing Information
SS.MnSel            RMB       1                   Request High level Menu Handler take determine next event
SS.SBar             RMB       1                   SetStat to set position block on Window scroll bars
SS.Mouse            RMB       1                   Return Mouse information packet (COCO)
SS.MsSig            RMB       1                   SetStat to tell driver to send signal on mouse event
SS.AScrn            RMB       1                   Allocate a screen for application poking
SS.DScrn            RMB       1                   Display a screen allocated by SS.AScrn
SS.FScrn            RMB       1                   Free a screen allocated by SS.AScrn
SS.PScrn            RMB       1                   Polymorph Screen into different screen type
SS.ScInf            RMB       1                   Get Current screen info for direct writes
                    RMB       1                   Reserved
SS.Palet            RMB       1                   Return palette information
SS.Montr            RMB       1                   Get and Set Monitor Type
SS.ScTyp            RMB       1                   Get screen type information
SS.GIP              RMB       1                   Global Input Parameters (SetStat)
SS.UMBar            RMB       1                   update menu bar (SetStat)
SS.FBRgs            RMB       1                   return color registers (GetStat)
SS.DfPal            RMB       1                   set/return default palette registers (Getstat/Setstat)
SS.Tone             RMB       1                   Generate a tone using 6 bit sound
SS.GIP2             RMB       1                   Global Input Params #2 (L2V3)
SS.AnPal            RMB       1                   Animate palettes (L2V3)
SS.FndBf            RMB       1                   Find named buffer (L2V3)

* sc6551 defined
SS.CDSta            EQU       SS.GIP2
SS.CDSig            EQU       SS.AnPal
SS.CDRel            EQU       SS.FndBf
* These are wide open in Level 1

* sc6551 defined

                    ORG       $A0
*
* New Default SCF input buffer Set status call
SS.Fill             RMB       1                   Pre-load SCF device input buffer
SS.Hist             RMB       1                   Enable command-line history easily


                    ORG       $B0
*
* New WDDisk get/set status calls
SS.ECC              RMB       1                   ECC corrected data error enable/disable (GetStat/SetStat)

*

* VRN get/set status calls.  Named by Alan DeKok.


* SDisk 3 Definition Equates


                    TTL       Direct              Page Definitions
                    PAG

**********************************
* Direct Page Variable Definitions
*
                    ORG       $00
D.WDAddr            RMB       2                   FHL/Isted WD1002-05 interface base address
D.WDBtDr            RMB       1                   FHL/Isted WD1002-05 boot physical device drive num.
D.SWPage            RMB       1                   SmartWatch page # (see clock2_smart)
                    RMB       5
D.COCOXT            RMB       1                   Busy flag for CoCo-XT driver (one drive at a time)
D.DbgMem            RMB       2                   Debug memory pointer
D.DWSubAddr         RMB       2                   DriveWire subroutine module pointer
D.DWStat            RMB       2                   DriveWire statics page
D.DWSrvID           RMB       1                   DriveWire server ID

                    ORG       $20


* Level 1 DP vars
D.FMBM              RMB       4                   Free memory bit map pointers
D.MLIM              RMB       2                   Memory limit $24
D.ModDir            RMB       4                   Module directory $26
D.Init              RMB       2                   Rom base address $2A
D.SWI3              RMB       2                   Swi3 vector $2C
D.SWI2              RMB       2                   Swi2 vector $2E
D.FIRQ              RMB       2                   Firq vector $30
D.IRQ               RMB       2                   Irq vector $32
D.SWI               RMB       2                   Swi vector $34
D.NMI               RMB       2                   Nmi vector $36
D.SvcIRQ            RMB       2                   Interrupt service entry $38
D.Poll              RMB       2                   Interrupt polling routine $3A
D.UsrIRQ            RMB       2                   User irq routine $3C
D.SysIRQ            RMB       2                   System irq routine $3E
D.UsrSvc            RMB       2                   User service request routine $40
D.SysSvc            RMB       2                   System service request routine $42
D.UsrDis            RMB       2                   User service request dispatch table
D.SysDis            RMB       2                   System service reuest dispatch table
D.Slice             RMB       1                   Process time slice count $48
D.PrcDBT            RMB       2                   Process descriptor block address  $49
D.Proc              RMB       2                   Process descriptor address $4B
D.AProcQ            RMB       2                   Active process queue $4D
D.WProcQ            RMB       2                   Waiting process queue $4F
D.SProcQ            RMB       2                   Sleeping process queue $51
D.Time              EQU       .                   Time
D.Year              RMB       1                   $53
D.Month             RMB       1                   $54
D.Day               RMB       1                   $55
D.Hour              RMB       1                   $56
D.Min               RMB       1                   $57
D.Sec               RMB       1                   $58
D.Tick              RMB       1                   $59
D.TSec              RMB       1                   Ticks / second $5A
D.TSlice            RMB       1                   Ticks / time-slice $5B
D.IOML              RMB       2                   I/O mgr free memory low bound $5C
D.IOMH              RMB       2                   I/O mgr free memory hi  bound $5E
D.DevTbl            RMB       2                   Device driver table addr $60
D.PolTbl            RMB       2                   Irq polling table addr $62
D.PthDBT            RMB       2                   Path descriptor block table addr $64
D.BTLO              RMB       2                   Bootstrap low address $66
D.BTHI              RMB       2                   Bootstrap hi address $68
D.DMAReq            RMB       1                   DMA in use flag $6A
D.AltIRQ            RMB       2                   Alternate IRQ vector (CC) $6B
D.KbdSta            RMB       2                   Keyboard scanner static storage (CC) $6D
D.DskTmr            RMB       2                   Disk Motor Timer (CC) $6F
D.CBStrt            RMB       16                  reserved for CC warmstart ($71)
D.Clock             RMB       2                   Address of Clock Tick Routine (CC) $81
D.Boot              RMB       1                   Bootstrap attempted flag
D.URtoSs            RMB       2                   address of user to system routine (VIRQ) $84
D.CLTb              RMB       2                   Pointer to clock interrupt table (VIRQ) $86
D.MDREG             RMB       1                   6309 MD (mode) shadow register $88 (added in V2.01.00)
D.CRC               RMB       1                   CRC checking mode flag $89 (added in V2.01.00)
D.Clock2            RMB       2                   CC Clock2 entry address

                    ORG       $100
*D.XSWI3        RMB       3
*D.XSWI2        RMB       3
*D.XFIRQ        RMB       3
*D.XIRQ         RMB       3
*D.XSWI         RMB       3
*D.XNMI         RMB       3

D.XSWI3             RMB       3
D.XSWI2             RMB       3
D.XSWI              RMB       3
D.XNMI              RMB       3
D.XIRQ              RMB       3
D.XFIRQ             RMB       3

* Table Sizes
BMAPSZ              EQU       32                  Bitmap table size
SVCTNM              EQU       2                   Number of service request tables
SVCTSZ              EQU       (256-BMAPSZ)/SVCTNM-2 Service request table size


* Level 2 DP vars







********
* CoCo 3 STUFF COMES NEXT
* This area is used for the CoCo Hardware Registers
*

*************************
* Level 2 Block Map flags
*
*
* Service Dispatch Table special entries
*


                    TTL       Structure           Formats
                    PAG
************************************
* Module Directory Entry Definitions
*
                    ORG       0
MD$MPtr             RMB       2                   Module ptr
MD$Link             RMB       2                   Module Link count
MD$ESize            EQU       .                   Module Directory Entry size

************************************
* Module Definitions
*
* Universal Module Offsets
*
                    ORG       0
M$ID                RMB       2                   ID Code
M$Size              RMB       2                   Module Size
M$Name              RMB       2                   Module Name
M$Type              RMB       1                   Type / Language
M$Revs              RMB       1                   Attributes / Revision Level
M$Parity            RMB       1                   Header Parity
M$IDSize            EQU       .                   Module ID Size
*
* Type-Dependent Module Offsets
*
* System, File Manager, Device Driver, Program Module
*
M$Exec              RMB       2                   Execution Entry Offset
*
* Device Driver, Program Module
*
M$Mem               RMB       2                   Stack Requirement
*
* Device Driver, Device Descriptor Module
*
M$Mode              RMB       1                   Device Driver Mode Capabilities
*
* Device Descriptor Module
*
                    ORG       M$IDSize
M$FMgr              RMB       2                   File Manager Name Offset
M$PDev              RMB       2                   Device Driver Name Offset
                    RMB       1                   M$Mode (defined above)
M$Port              RMB       3                   Port Address
M$Opt               RMB       1                   Device Default Options
M$DTyp              RMB       1                   Device Type
IT.DTP              EQU       M$DTyp              Descriptor type offset
*
* Configuration Module Entry Offsets
*
                    ORG       M$IDSize
MaxMem              RMB       3                   Maximum Free Memory
PollCnt             RMB       1                   Entries in Interrupt Polling Table
DevCnt              RMB       1                   Entries in Device Table
InitStr             RMB       2                   Initial Module Name
SysStr              RMB       2                   System Device Name
StdStr              RMB       2                   Standard I/O Pathlist
BootStr             RMB       2                   Bootstrap Module name
ProtFlag            RMB       1                   Write protect enable flag

OSLevel             RMB       1                   OS level
OSVer               RMB       1                   OS version
OSMajor             RMB       1                   OS major
OSMinor             RMB       1                   OS minor
Feature1            RMB       1                   feature byte 1
Feature2            RMB       1                   feature byte 2
OSName              RMB       2                   OS revision name string (nul terminated)
InstallName         RMB       2                   installation name string (nul terminated)
                    RMB       4                   reserved for future use

* -- VTIO area -- (NitrOS-9 Level 2 and above) *

* Feature1 byte definitions
CRCOn               EQU       %00000001           CRC checking on
CRCOff              EQU       %00000000           CRC checking off
Proc6809            EQU       %00000000           6809 procesor
Proc6309            EQU       %00000010           6309 procesor

                    PAG
**************************
* Module Field Definitions
*
* ID Field - First two bytes of a NitrOS-9 module
*
M$ID1               EQU       $87                 Module ID code byte one
M$ID2               EQU       $CD                 Module ID code byte two
M$ID12              EQU       M$ID1*256+M$ID2

*
* Module Type/Language Field Masks
*
TypeMask            EQU       %11110000           Type Field
LangMask            EQU       %00001111           Language Field

*
* Module Type Values
*
Devic               EQU       $F0                 Device Descriptor Module
Drivr               EQU       $E0                 Physical Device Driver
FlMgr               EQU       $D0                 File Manager
Systm               EQU       $C0                 System Module
ShellSub            EQU       $50                 Shell+ shell sub module
Data                EQU       $40                 Data Module
Multi               EQU       $30                 Multi-Module
Sbrtn               EQU       $20                 Subroutine Module
Prgrm               EQU       $10                 Program Module

*
* Module Language Values
*
Objct               EQU       1                   6809 Object Code Module
ICode               EQU       2                   Basic09 I-code
PCode               EQU       3                   Pascal P-code
CCode               EQU       4                   C I-code
CblCode             EQU       5                   Cobol I-code
FrtnCode            EQU       6                   Fortran I-code
Obj6309             EQU       7                   6309 object code
*
* Module Attributes / Revision byte
*
* Field Masks
*
AttrMask            EQU       %11110000           Attributes Field
RevsMask            EQU       %00001111           Revision Level Field
*
* Attribute Flags
*
ReEnt               EQU       %10000000           Re-Entrant Module
ModProt             EQU       %01000000           Gimix Module protect bit (0=protected, 1=write enable)
ModNat              EQU       %00100000           6309 native mode attribute

********************
* Device Type Values
*
* These values define various classes of devices, which are
* managed by a file manager module.  The Device Type is embedded
* in a device's device descriptor.
*
DT.SCF              EQU       0                   Sequential Character File Manager
DT.RBF              EQU       1                   Random Block File Manager
DT.Pipe             EQU       2                   Pipe File Manager
DT.SBF              EQU       3                   Sequential Block File Manager
DT.NFM              EQU       4                   Network File Manager
DT.CDFM             EQU       5                   CD-ROM File Manager
DT.RFM              EQU       6                   Remote File Manager

*********************
* CRC Result Constant
*
CRCCon1             EQU       $80
CRCCon23            EQU       $0FE3

                    TTL       Process             Information
                    PAG
********************************
* Process Descriptor Definitions
*

* Level 1 process descriptor defs
DefIOSiz            EQU       12
NumPaths            EQU       16                  Number of Local Paths

                    ORG       0
P$ID                RMB       1                   Process ID
P$PID               RMB       1                   Parent's ID
P$SID               RMB       1                   Sibling's ID
P$CID               RMB       1                   Child's ID
P$SP                RMB       2                   Stack ptr
P$CHAP              RMB       1                   process chapter number
P$ADDR              RMB       1                   user address beginning page number
P$PagCnt            RMB       1                   Memory Page Count
P$User              RMB       2                   User Index $09
P$Prior             RMB       1                   Priority $0B
P$Age               RMB       1                   Age $0C
P$State             RMB       1                   Status $0D
P$Queue             RMB       2                   Queue Link (Process ptr) $0E
P$IOQP              RMB       1                   Previous I/O Queue Link (Process ID) $10
P$IOQN              RMB       1                   Next     I/O Queue Link (Process ID)
P$PModul            RMB       2                   Primary Module
P$SWI               RMB       2                   SWI Entry Point
P$SWI2              RMB       2                   SWI2 Entry Point
P$SWI3              RMB       2                   SWI3 Entry Point $18
P$DIO               RMB       DefIOSiz            default I/O ptrs $1A
P$PATH              RMB       NumPaths            I/O path table $26
P$Signal            RMB       1                   Signal Code $36
P$SigVec            RMB       2                   Signal Intercept Vector
P$SigDat            RMB       2                   Signal Intercept Data Address
P$NIO               RMB       4                   additional dio pointers for net
                    RMB       $40-.               unused
P$Size              EQU       .                   Size of Process Descriptor

*
* Process State Flags
*
SysState            EQU       %10000000
TimSleep            EQU       %01000000
TimOut              EQU       %00100000
ImgChg              EQU       %00010000
Condem              EQU       %00000010
Dead                EQU       %00000001


* Level 2 process descriptor defs


*
* Process State Flags
*


                    TTL       NitrOS-9            I/O Symbolic Definitions
                    PAG
*************************
* Path Descriptor Offsets
*
                    ORG       0
PD.PD               RMB       1                   Path Number
PD.MOD              RMB       1                   Mode (Read/Write/Update)
PD.CNT              RMB       1                   Number of Open Images
PD.DEV              RMB       2                   Device Table Entry Address
PD.CPR              RMB       1                   Current Process
PD.RGS              RMB       2                   Caller's Register Stack
PD.BUF              RMB       2                   Buffer Address
PD.FST              RMB       32-.                File Manager's Storage
PD.OPT              EQU       .                   PD GetSts(0) Options
PD.DTP              RMB       1                   Device Type
                    RMB       64-.                Path options
PDSIZE              EQU       .

*
* Pathlist Special Symbols
*
PDELIM              EQU       '/                  Pathlist Name Separator
PDIR                EQU       '.                  Directory
PENTIR              EQU       '@                  Entire Device

                    PAG
****************************
* File Manager Entry Offsets
*
                    ORG       0
FMCREA              RMB       3                   Create (Open New) File
FMOPEN              RMB       3                   Open File
FMMDIR              RMB       3                   Make Directory
FMCDIR              RMB       3                   Change Directory
FMDLET              RMB       3                   Delete File
FMSEEK              RMB       3                   Position File
FMREAD              RMB       3                   Read from File
FMWRIT              RMB       3                   Write to File
FMRDLN              RMB       3                   ReadLn
FMWRLN              RMB       3                   WritLn
FMGSTA              RMB       3                   Get File Status
FMSSTA              RMB       3                   Set File Status
FMCLOS              RMB       3                   Close File

*****************************
* Device Driver Entry Offsets
*
                    ORG       0
D$INIT              RMB       3                   Device Initialization
D$READ              RMB       3                   Read from Device
D$WRIT              RMB       3                   Write to Device
D$GSTA              RMB       3                   Get Device Status
D$PSTA              RMB       3                   Put Device Status
D$TERM              RMB       3                   Device Termination

*********************
* Device Table Format
*
                    ORG       0
V$DRIV              RMB       2                   Device Driver module
V$STAT              RMB       2                   Device Driver Static storage
V$DESC              RMB       2                   Device Descriptor module
V$FMGR              RMB       2                   File Manager module
V$USRS              RMB       1                   use count
DEVSIZ              EQU       .

*******************************
* Device Static Storage Offsets
*
                    ORG       0
V.PAGE              RMB       1                   Port Extended Address
V.PORT              RMB       2                   Device 'Base' Port Address
V.LPRC              RMB       1                   Last Active Process ID
V.BUSY              RMB       1                   Active Process ID (0=UnBusy)
V.WAKE              RMB       1                   Active PD if Driver MUST Wake-up
V.USER              EQU       .                   Driver Allocation Origin

********************************
* Interrupt Polling Table Format
*
                    ORG       0
Q$POLL              RMB       2                   Absolute Polling Address
Q$FLIP              RMB       1                   Flip (EOR) Byte ..normally Zero
Q$MASK              RMB       1                   Polling Mask (after Flip)
Q$SERV              RMB       2                   Absolute Service routine Address
Q$STAT              RMB       2                   Static Storage Address
Q$PRTY              RMB       1                   Priority (Low Numbers=Top Priority)
POLSIZ              EQU       .

********************
* VIRQ packet format
*
                    ORG       0
Vi.Cnt              RMB       2                   count down counter
Vi.Rst              RMB       2                   reset value for counter
Vi.Stat             RMB       1                   status byte
Vi.PkSz             EQU       .

Vi.IFlag            EQU       %00000001           status byte virq flag

                    PAG
*************************************
* Machine Characteristics Definitions
*
R$CC                EQU       0                   Condition Codes register
R$A                 EQU       1                   A Accumulator
R$B                 EQU       2                   B Accumulator
R$D                 EQU       R$A                 Combined A:B Accumulator
R$DP                EQU       3                   Direct Page register
R$X                 EQU       4                   X Index register
R$Y                 EQU       6                   Y Index register
R$U                 EQU       8                   User Stack register
R$PC                EQU       10                  Program Counter register
R$Size              EQU       12                  Total register package size

* MD register masks
* 6309 definitions
DIV0                EQU       %10000000           division by 0 trap flag       : 1 = trap occured
badinstr            EQU       %01000000           illegal instruction trap flag : 1 = trap occured

Entire              EQU       %10000000           Full Register Stack flag
FIRQMask            EQU       %01000000           Fast-Interrupt Mask bit
HalfCrry            EQU       %00100000           Half Carry flag
IRQMask             EQU       %00010000           Interrupt Mask bit
Negative            EQU       %00001000           Negative flag
Zero                EQU       %00000100           Zero flag
TwosOvfl            EQU       %00000010           Two's Comp Overflow flag
Carry               EQU       %00000001           Carry bit
IntMasks            EQU       IRQMask+FIRQMask
Sign                EQU       %10000000           sign bit

                    TTL       Error               Code Definitions
                    PAG
************************
* Error Code Definitions
*
* Basic09 Error Codes
*
                    ORG       10
E$UnkSym            RMB       1                   Unknown symbol
E$ExcVrb            RMB       1                   Excessive verbage
E$IllStC            RMB       1                   Illegal statement construction
E$ICOvf             RMB       1                   I-code overflow
E$IChRef            RMB       1                   Illegal channel reference
E$IllMod            RMB       1                   Illegal mode
E$IllNum            RMB       1                   Illegal number
E$IllPrf            RMB       1                   Illegal prefix
E$IllOpd            RMB       1                   Illegal operand
E$IllOpr            RMB       1                   Illegal operator
E$IllRFN            RMB       1                   Illegal record field name
E$IllDim            RMB       1                   Illegal dimension
E$IllLit            RMB       1                   Illegal literal
E$IllRet            RMB       1                   Illegal relational
E$IllSfx            RMB       1                   Illegal type suffix
E$DimLrg            RMB       1                   Dimension too large
E$LinLrg            RMB       1                   Line number too large
E$NoAssg            RMB       1                   Missing assignment statement
E$NoPath            RMB       1                   Missing path number
E$NoComa            RMB       1                   Missing coma
E$NoDim             RMB       1                   Missing dimension
E$NoDO              RMB       1                   Missing DO statement
E$MFull             RMB       1                   Memory full
E$NoGoto            RMB       1                   Missing GOTO
E$NoLPar            RMB       1                   Missing left parenthesis
E$NoLRef            RMB       1                   Missing line reference
E$NoOprd            RMB       1                   Missing operand
E$NoRPar            RMB       1                   Missing right parenthesis
E$NoTHEN            RMB       1                   Missing THEN statement
E$NoTO              RMB       1                   Missing TO statement
E$NoVRef            RMB       1                   Missing variable reference
E$EndQou            RMB       1                   Missing end quote
E$SubLrg            RMB       1                   Too many subscripts
E$UnkPrc            RMB       1                   Unknown procedure
E$MulPrc            RMB       1                   Multiply defined procedure
E$DivZer            RMB       1                   Divice by zero
E$TypMis            RMB       1                   Operand type mismatch
E$StrOvf            RMB       1                   String stack overflow
E$NoRout            RMB       1                   Unimplemented routine
E$UndVar            RMB       1                   Undefined variable
E$FltOvf            RMB       1                   Floating Overflow
E$LnComp            RMB       1                   Line with compiler error
E$ValRng            RMB       1                   Value out of range for destination
E$SubOvf            RMB       1                   Subroutine stack overflow
E$SubUnd            RMB       1                   Subroutine stack underflow
E$SubRng            RMB       1                   Subscript out of range
E$ParmEr            RMB       1                   Paraemter error
E$SysOvf            RMB       1                   System stack overflow
E$IOMism            RMB       1                   I/O type mismatch
E$IONum             RMB       1                   I/O numeric input format bad
E$IOConv            RMB       1                   I/O conversion: number out of range
E$IllInp            RMB       1                   Illegal input format
E$IOFRpt            RMB       1                   I/O format repeat error
E$IOFSyn            RMB       1                   I/O format syntax error
E$IllPNm            RMB       1                   Illegal path number
E$WrSub             RMB       1                   Wrong number of subscripts
E$NonRcO            RMB       1                   Non-record type operand
E$IllA              RMB       1                   Illegal argument
E$IllCnt            RMB       1                   Illegal control structure
E$UnmCnt            RMB       1                   Unmatched control structure
E$IllFOR            RMB       1                   Illegal FOR variable
E$IllExp            RMB       1                   Illegal expression type
E$IllDec            RMB       1                   Illegal declarative statement
E$ArrOvf            RMB       1                   Array size overflow
E$UndLin            RMB       1                   Undefined line number
E$MltLin            RMB       1                   Multiply defined line number
E$MltVar            RMB       1                   Multiply defined variable
E$IllIVr            RMB       1                   Illegal input variable
E$SeekRg            RMB       1                   Seek out of range
E$NoData            RMB       1                   Missing data statement

*
* System Dependent Error Codes
*

* Level 2 windowing error codes
                    ORG       183
E$IWTyp             RMB       1                   Illegal window type
E$WADef             RMB       1                   Window already defined
E$NFont             RMB       1                   Font not found
E$StkOvf            RMB       1                   Stack overflow
E$IllArg            RMB       1                   Illegal argument
                    RMB       1                   reserved
E$ICoord            RMB       1                   Illegal coordinates
E$Bug               RMB       1                   Bug (should never be returned)
E$BufSiz            RMB       1                   Buffer size is too small
E$IllCmd            RMB       1                   Illegal command
E$TblFul            RMB       1                   Screen or window table is full
E$BadBuf            RMB       1                   Bad/Undefined buffer number
E$IWDef             RMB       1                   Illegal window definition
E$WUndef            RMB       1                   Window undefined

E$Up                RMB       1                   Up arrow pressed on SCF I$ReadLn with PD.UP enabled
E$Dn                RMB       1                   Down arrow pressed on SCF I$ReadLn with PD.DOWN enabled
E$Alias             RMB       1


*
* Standard NitrOS-9 Error Codes
*
                    ORG       200
E$PthFul            RMB       1                   Path Table full
E$BPNum             RMB       1                   Bad Path Number
E$Poll              RMB       1                   Polling Table Full
E$BMode             RMB       1                   Bad Mode
E$DevOvf            RMB       1                   Device Table Overflow
E$BMID              RMB       1                   Bad Module ID
E$DirFul            RMB       1                   Module Directory Full
E$MemFul            RMB       1                   Process Memory Full
E$UnkSvc            RMB       1                   Unknown Service Code
E$ModBsy            RMB       1                   Module Busy
E$BPAddr            RMB       1                   Bad Page Address
E$EOF               RMB       1                   End of File
                    RMB       1
E$NES               RMB       1                   Non-Existing Segment
E$FNA               RMB       1                   File Not Accesible
E$BPNam             RMB       1                   Bad Path Name
E$PNNF              RMB       1                   Path Name Not Found
E$SLF               RMB       1                   Segment List Full
E$CEF               RMB       1                   Creating Existing File
E$IBA               RMB       1                   Illegal Block Address
E$HangUp            RMB       1                   Carrier Detect Lost
E$MNF               RMB       1                   Module Not Found
                    RMB       1
E$DelSP             RMB       1                   Deleting Stack Pointer memory
E$IPrcID            RMB       1                   Illegal Process ID
E$BPrcID            EQU       E$IPrcID            Bad Process ID (formerly #238)
                    RMB       1
E$NoChld            RMB       1                   No Children
E$ISWI              RMB       1                   Illegal SWI code
E$PrcAbt            RMB       1                   Process Aborted
E$PrcFul            RMB       1                   Process Table Full
E$IForkP            RMB       1                   Illegal Fork Parameter
E$KwnMod            RMB       1                   Known Module
E$BMCRC             RMB       1                   Bad Module CRC
E$USigP             RMB       1                   Unprocessed Signal Pending
E$NEMod             RMB       1                   Non Existing Module
E$BNam              RMB       1                   Bad Name
E$BMHP              RMB       1                   (bad module header parity)
E$NoRAM             RMB       1                   No (System) RAM Available
E$DNE               RMB       1                   Directory not empty
E$NoTask            RMB       1                   No available Task number
                    RMB       $F0-.               reserved
E$Unit              RMB       1                   Illegal Unit (drive)
E$Sect              RMB       1                   Bad Sector number
E$WP                RMB       1                   Write Protect
E$CRC               RMB       1                   Bad Check Sum
E$Read              RMB       1                   Read Error
E$Write             RMB       1                   Write Error
E$NotRdy            RMB       1                   Device Not Ready
E$Seek              RMB       1                   Seek Error
E$Full              RMB       1                   Media Full
E$BTyp              RMB       1                   Bad Type (incompatable) media
E$DevBsy            RMB       1                   Device Busy
E$DIDC              RMB       1                   Disk ID Change
E$Lock              RMB       1                   Record is busy (locked out)
E$Share             RMB       1                   Non-sharable file busy
E$DeadLk            RMB       1                   I/O Deadlock error



********************************
* Boot defs for NitrOS-9 Level 1
*
* These defs are not strictly for 'Boot', but are for booting the
* system.
*
Bt.Start            EQU       $EE00               Start address of the boot track in memory

* Boot area size on Dragon is only 16 sectors=4K
Bt.Size             EQU       $1080               Maximum size of bootfile


******************************************
* Boot defs for NitrOS-9 Level 2 and above
*
* These defs are not strictly for 'Boot', but are for booting the
* system.
*


* Boot area on the Dragon starts on track 0 sector 2, imediatly
* after the blockmap.
* On the CoCo, the boot track is all of track 34

Bt.Track            EQU       34                  Boot track
Bt.Sec              EQU       0                   Start LSN of boot area on boot track


***************************
* Level 3 Defs
*
* These definitions apply to NitrOS-9 Level 3
*

