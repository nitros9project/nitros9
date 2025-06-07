                    IFNE      OS9.D-1

OS9.D               SET       1

********************************************************************
* os9.d - NitrOS-9 System Definitions
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------ 
*          1983/03/01
* Six new Status codes added: SS.BlkRd - SS.ELog.
*
*          1983/03/08
* New status code added: SS.SSig.
*
*          1983/04/21
* Added new F$ call for 7 day clock function for control level II.
*
*          1983/05/04  William G. Phelps
* F$CMDir service request added for NCM.
*
*          1983/06/29
* Added ProfFlag to init module offsets.
*
*          1983/07/12  Mark G. Hawkins
* Added SS.Atlas for CoCo.
*
*          1983/10/08  Robert E. Sorensen
* Added SS.Break for ACIA Break command.
*
*          1983/11/29
* Added SS.RsBit to reserve (not allocate in) bitmap sector.
*
*          1984/02/17
* Added reserved status codes for Hoshi and Gimix.
*
*          1984/03/07  Mark G. Hawkins
* Added SS.Cursr and SS.ScSiz for CoCo.
* Added New signal code S$Window ... CoCo future.
*
*          1984/04/11  Mark G. Hawkins
* Added SS.Sound for CoCo.
*
*          1984/05/05  Mark G. Hawkins
* Added label SS.SetMF to Gimix Reserved byte
* Changed SS.Sound to SS.KySns.
*
*          1985/05/24  Mark G. Hawkins
* Added SS.ComSt Communication Set (Parity,Baud).
*
*          1985/05/28  Tim A. Harris
* Added F$VIRQ for Virtual IRQ.
*
*          1985/07/30  Mark G. Hawkins
* Added SS.Open, SS.Close, SS.HngUP.
*
*          1985/07/30  Mark G. Hawkins
* Added E$HangUp error for CDC Lost.
*
*          1985/08/24  Doug J. Nicholson
* Added DT.NFM device type.
*
*          1985/06/20  Mark G. Hawkins
* Added SS.MAGBf, SS.SLCBf.
*
*          1985/08/29  Ken Mizuno
* Fixed DT.SBF/NFM values to 3/4.
*
*          1985/09/01  Ken Mizuno
* Added SS.FDInf, SS.Attr to accept 68K request thru NET.
*
*          1985/09/03  Ken Mizuno/Robert F. Doggett
* Eliminated E$BPrcID, made Error #238 become E$DNE for
* 68000 compatability.
*
*          1986/04/15  Mark G. Hawkins
* F$AlHRAM System call added for CoCo.
*
*          1986/09/08  Mark G. Hawkins
* F$Alarm for CoCo Clock Module.
*
*          1986/09/17  Mark G. Hawkins
* SS.Tone For CoCo.
*
*          1986/09/23  Mark G. Hawkins
* Added F$NMLink and F$NMLoad for CoCo.
*
*          1986/09/30  Mark G. Hawkins
* Added Reserved User $70 to $7f in system calls.
*
*          1986/09/30  Mark G. Hawkins
* Created Color Computer 3 Version of OS9Defs.
*
*          1998/10/03  Boisy G. Pitre
* Consolidated Level 1/Level 2 os9defs.
*
*          2002/04/04  Boisy G. Pitre
* Consolidated Level 2/Level 2 V3 os9defs.
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
*
*        2019/10/30  Bill Nobel, from discussions with L. Curtis Boyle
* Added I$ModDsc call (modify device descriptor in system memory) BN/LCB
*
*        2019/12/27 L. Curtis Boyle
* Added D.IRQTmp for faster temp vars (currently used in Krn F$Move/6809,
*   can be used elsewheres later, in small routines with IRQ's turned off).
*
*        2019/10/30  Bill Nobel, from discussions with L. Curtis Boyle
* Added S$FS2Sig & S$KQ3Sig (both $80) FS2 & KQ3 (VRN) signal codes added (LCB).

                    NAM       os9.d
                    IFEQ      Level-1
                    TTL       NitrOS-9            Level 1 System Symbol Definitions
                    ELSE
                    IFEQ      Level-2
                    TTL       NitrOS-9            Level 2 System Symbol Definitions
                    ELSE
                    TTL       NitrOS-9            Level 3 System Symbol Definitions
                    ENDC
                    ENDC

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

                    IFGT      Level-1

* NitrOS-9 Level 2 system calls
F$GPrDsc            RMB       1                   Get Process Descriptor copy ($18)
F$GBlkMp            RMB       1                   Get System Block Map copy ($19)
F$GModDr            RMB       1                   Get Module Directory copy ($1A)
F$CpyMem            RMB       1                   Copy External Memory ($1B)
F$SUser             RMB       1                   Set User ID number ($1C)
F$UnLoad            RMB       1                   Unlink Module by name ($1D)
F$Alarm             RMB       1                   Color Computer 3 Alarm Call ($1E)
                    RMB       2                   Reserved - For overlap of other systems ($1F)
F$NMLink            RMB       1                   Color Computer 3 Non-Mapping Link ($21)
F$NMLoad            RMB       1                   Color Computer 3 Non-Mapping Load ($22)

                    ELSE

* NitrOS-9 Level 1 system call padding
                    RMB       11

                    ENDC

F$Debug             RMB       1                   Drop the system into the debugger ($23)

                    IFGT      Level-1

                    ORG       $25
F$TPS               RMB       1                   Return System's Ticks Per Second
F$TimAlm            RMB       1                   CoCo individual process alarm call

                    ENDC

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

                    IFGT      Level-1

F$SLink             RMB       1                   System Link
F$Boot              RMB       1                   Bootstrap System
F$BtMem             RMB       1                   Bootstrap Memory Request
F$GProcP            RMB       1                   Get Process ptr
F$Move              RMB       1                   Move Data (low bound first)
F$AllRAM            RMB       1                   Allocate RAM blocks
F$AllImg            RMB       1                   Allocate Image RAM blocks
F$DelImg            RMB       1                   Deallocate Image RAM blocks
F$SetImg            RMB       1                   Set Process DAT Image
F$FreeLB            RMB       1                   Get Free Low Block
F$FreeHB            RMB       1                   Get Free High Block
F$AllTsk            RMB       1                   Allocate Process Task number
F$DelTsk            RMB       1                   Deallocate Process Task number
F$SetTsk            RMB       1                   Set Process Task DAT registers
F$ResTsk            RMB       1                   Reserve Task number
F$RelTsk            RMB       1                   Release Task number
F$DATLog            RMB       1                   Convert DAT Block/Offset to Logical
F$DATTmp            RMB       1                   Make temporary DAT image (Obsolete)
F$LDAXY             RMB       1                   Load A [X,[Y]]
F$LDAXYP            RMB       1                   Load A [X+,[Y]]
F$LDDDXY            RMB       1                   Load D [D+X,[Y]]
F$LDABX             RMB       1                   Load A from 0,X in task B
F$STABX             RMB       1                   Store A at 0,X in task B
F$AllPrc            RMB       1                   Allocate Process Descriptor
F$DelPrc            RMB       1                   Deallocate Process Descriptor
F$ELink             RMB       1                   Link using Module Directory Entry
F$FModul            RMB       1                   Find Module Directory Entry
F$MapBlk            RMB       1                   Map Specific Block
F$ClrBlk            RMB       1                   Clear Specific Block
F$DelRAM            RMB       1                   Deallocate RAM blocks
F$GCMDir            RMB       1                   Pack module directory
F$AlHRAM            RMB       1                   Allocate HIGH RAM Blocks

* Alan DeKok additions
F$ReBoot            RMB       1                   Reboot machine (reload OS9Boot) or drop to RSDOS
F$CRCMod            RMB       1                   CRC mode, toggle or report current status
F$XTime             RMB       1                   Get Extended time packet from RTC (fractions of second)
F$VBlock            RMB       1                   Verify modules in a block of memory, add to module directory

                    ENDC

*
* Numbers $70 through $7F are reserved for user definitions
*
                    ORG       $70

                    IFEQ      Level-1

                    RMB       16                  Reserved for user definition

                    ELSE

F$RegDmp            RMB       1                   Ron Lammardo's debugging register dump
F$NVRAM             RMB       1                   Non Volatile RAM (RTC battery backed static) read/write

                    RMB       $80-.               Reserved for user definitions
                    ENDC

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
I$ModDsc            RMB       1                   Modify SCF/RBF Descriptor in Memory

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

                    ifgt      Level-1
                    ORG       $80
S$FS2Sig            RMB       1                   FS2 VIRQ Signal code (VRN)
S$KQ3Sig            EQU       S$FS2Sig            KQ3 VIRQ Signal code (VRN)
                    endc

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
                    IFNE      1
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
                    ELSE
* These are wide open in Level 1
                    RMB       19

* sc6551 defined
SS.CDSta            RMB       1
SS.CDSig            RMB       1
SS.CDRel            RMB       1
                    ENDC

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
                    IFGT      Level-1

* VRN get/set status calls.  Named by Alan DeKok.
SS.VCtr             EQU       $80                 Return FS2 total VIRQ counter
SS.VSig             EQU       $81                 Return FS2 number of signals sent

SS.FClr             EQU       $81                 Set/clear FS2 VIRQ
SS.FSet             EQU       $C7                 Set FS2+ VIRQ
SS.KSet             EQU       $C8                 Set KQ3 VIRQ
SS.KClr             EQU       $C9                 Clr KQ3 VIRQ
SS.ARAM             EQU       $CA                 Allocate RAM blocks
SS.DRAM             EQU       $CB                 De-allocate RAM blocks

* SDisk 3 Definition Equates
SS.DRead            EQU       SS.AAGBf            SDisk3 Direct Sector Read ($80)
SS.DWrit            EQU       SS.DRead            SDisk3 Direct sector Write ($80)
SS.UnFrz            EQU       SS.SLGBf            SDisk3 UNFreeze DD info ($81)
SS.MOFF             EQU       SS.Mount            SDisk3 fast motor off call ($82)
SS.MoTim            EQU       SS.RdNet            SDisk3 Set motor shut off time ($83)
SS.SDRD             EQU       SS.MpGPB            SDisk3 System direct read ($84)
SS.SDWRT            EQU       SS.SDRD             SDisk3 System direct writes ($84)
SS.Sleep            EQU       SS.Slots            SDisk3 (DMC ONLY) Enable/disable F$Sleep calls in read/write 1773 I/O ($85)
SS.DrvCh            EQU       SS.WnSet            SDisk3 (DMC ONLY) Set drive number to cache, or return drive number being cached ($86)

                    ENDC

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
D.IRQTmp            RMB       2                   1 or 2 byte DP scratch var (for when IRQ's are off)
D.WizFiStat         rmb       2                   WizFi statics page

                    ORG       $20

                    IFEQ      Level-1

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

                    ELSE

* Level 2 DP vars
D.Tasks             RMB       2                   Task User Table
D.TmpDAT            RMB       2                   Temporary DAT Image stack
D.Init              RMB       2                   Initialization Module ptr
D.Poll              RMB       2                   Interrupt Polling Routine ptr
D.Time              EQU       .                   System Time
D.Year              RMB       1
D.Month             RMB       1
D.Day               RMB       1
D.Hour              RMB       1
D.Min               RMB       1
D.Sec               RMB       1
D.Tick              RMB       1
D.Slice             RMB       1                   current slice remaining
D.TSlice            RMB       1                   Ticks per Slice
D.Boot              RMB       1                   Bootstrap attempted flag
D.MotOn             RMB       1                   Floppy Disk Motor-On time out
D.ErrCod            RMB       1                   Reset Error Code
D.Daywk             RMB       1                   day of week, com-trol clock
D.TkCnt             RMB       1                   Tick Counter
D.BtPtr             RMB       2                   Address of Boot in System Address space
D.BtSz              RMB       2                   Size of Boot

                    IFNE      H6309
D.MDREG             RMB       1                   6309 MD (mode) shadow register
                    ELSE
                    RMB       1                   Currently unused in NitrOS-9/6809
                    ENDC

D.CRC               RMB       1                   CRC checking mode flag

D.Tenths            RMB       1                   Tenths and hundredths of second for F$Xtime
D.Task1N            RMB       1                   Map type 1 task number*2 - offset into [D.TskIPt]
D.Quick             RMB       1                   Quick system call return flag - 0 =stack is at $FEE1
D.QIRQ              RMB       1                   Quick IRQ flag - 0 =IRQ wasn't clock, so quick return

                    ORG       $40
D.BlkMap            RMB       4                   Memory Block Map ptr
D.ModDir            RMB       4                   Module Directory ptrs
D.PrcDBT            RMB       2                   Process Descriptor Block Table ptr
D.SysPrc            RMB       2                   System Process Descriptor ptr
D.SysDAT            RMB       2                   System DAT Image ptr
D.SysMem            RMB       2                   System Memory Map ptr
D.Proc              RMB       2                   Current Process ptr
D.AProcQ            RMB       2                   Active Process Queue
D.WProcQ            RMB       2                   Waiting Process Queue
D.SProcQ            RMB       2                   Sleeping Process Queue
D.ModEnd            RMB       2                   Module Directory end ptr
D.ModDAT            RMB       2                   Module Dir DAT image end ptr
D.CldRes            RMB       2                   Cold Restart vector
D.BtBug             RMB       3                   Boot debug information
D.Pipe              RMB       2

                    ORG       $6B
D.Crash             RMB       6                   Pointer to CC Crash Routine
D.CBStrt            RMB       $B                  Reserved for CC warmstart ($71)
D.QCnt              RMB       1                   Count of number of quick system calls performed

                    ORG       $80
D.DevTbl            RMB       2                   I/O Device Table
D.PolTbl            RMB       2                   I/O Polling Table
                    RMB       4                   reserved
D.PthDBT            RMB       2                   Path Descriptor Block Table ptr
D.DMAReq            RMB       1                   DMA Request flag

********
* CoCo 3 STUFF COMES NEXT
* This area is used for the CoCo Hardware Registers
*
                    ORG       $90
D.HINIT             RMB       1                   GIME INIT0 register (hardware setup $FF90)
D.TINIT             RMB       1                   GIME INIT1 register (timer/task register $FF91)
D.IRQER             RMB       1                   Interrupt enable regsiter ($FF92)
D.FRQER             RMB       1                   Fast Interrupt enable register ($FF93)
D.TIMMS             RMB       1                   Timer most significant nibble ($FF94)
D.TIMLS             RMB       1                   Timer least significant byte ($FF95)
D.RESV1             RMB       1                   reserved register ($FF96)
D.RESV2             RMB       1                   reserved register ($FF97)
D.VIDMD             RMB       1                   video mode register ($FF98)
D.VIDRS             RMB       1                   video resolution register ($FF99)
D.BORDR             RMB       1                   border register ($FF9A)
D.RESV3             RMB       1                   reserved register ($FF9B)
D.VOFF2             RMB       1                   vertical scroll/offset 2 register ($FF9C)
D.VOFF1             RMB       1                   vertical offset 1 register ($FF9D)
D.VOFF0             RMB       1                   vertical offset 0 register ($FF9E)
D.HOFF0             RMB       1                   horizontal offset 0 register ($FF9F)
D.Speed             RMB       1                   Speed of COCO CPU 0=slow,1=fast ($A0)
D.TskIPt            RMB       2                   Task image Pointer table (CC) ($A1)
D.MemSz             RMB       1                   128/512K memory flag (CC) ($A3)
D.SSTskN            RMB       1                   System State Task Number (COCO) ($A4)
D.CCMem             RMB       2                   Pointer to beginning of CC Memory ($A5)
D.CCStk             RMB       2                   Pointer to top of CC Memory ($A7)
D.Flip0             RMB       2                   Change to Task 0 ($A9)
D.Flip1             RMB       2                   Change to reserved Task 1 ($AB)
D.VIRQ              RMB       2                   VIRQ Polling routine ($AD)
D.IRQS              RMB       1                   IRQ shadow register (CC Temporary) ($AF)
D.CLTb              RMB       2                   VIRQ Table address ($B0)
D.AltIRQ            RMB       2                   Alternate IRQ Vector (CC) ($B2)
D.GPoll             RMB       2                   CC GIME IRQ enable/disable toggle
D.Clock2            RMB       2                   CC Clock2 entry address
                    ORG       $C0
D.SysSvc            RMB       2                   System Service Routine entry
D.SysDis            RMB       2                   System Service Dispatch Table ptr
D.SysIRQ            RMB       2                   System IRQ Routine entry
D.UsrSvc            RMB       2                   User Service Routine entry
D.UsrDis            RMB       2                   User Service Dispatch Table ptr
D.UsrIRQ            RMB       2                   User IRQ Routine entry
D.SysStk            RMB       2                   System stack
D.SvcIRQ            RMB       2                   In-System IRQ service
D.SysTsk            RMB       1                   System Task number
                    ORG       $E0
D.Clock             RMB       2
D.XSWI3             RMB       2
D.XSWI2             RMB       2
D.XFIRQ             RMB       2
D.XIRQ              RMB       2
D.XSWI              RMB       2
D.XNMI              RMB       2
D.ErrRst            RMB       2
D.SysVec            RMB       2                   F$xxx system call vector for NitrOS-9 Level 3
D.SWI3              RMB       2
D.SWI2              RMB       2
D.FIRQ              RMB       2
D.IRQ               RMB       2
D.SWI               RMB       2
D.NMI               RMB       2

*************************
* Level 2 flags used for bytes in the memory block map at D.BlkMap
* and for bytes in the system memory map at D.SysMem.
* A value of 0 indicates an unused/unassigned block.
* In the code, block assignment often involves incrementing a value
* from 0 to 1 rather than explict use of RAMinUse.
*
NotRAM              EQU       %10000000           Block Not RAM flag
VidRAM              EQU       %00000100           Block is being used as Video RAM
ModBlock            EQU       %00000010           Module in Block
RAMinUse            EQU       %00000001           RAM Block in use flag
*
* Service Dispatch Table special entries
*
IOEntry             EQU       254

                    ENDC

                    TTL       Structure           Formats
                    PAG
************************************
* Module Directory Entry Definitions
*
                    ORG       0
                    IFGT      Level-1
MD$MPDAT            RMB       2                   Module DAT Image ptr
MD$MBSiz            RMB       2                   Memory Block size
                    ENDC
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

                    IFGT      Level-1
* -- VTIO area -- (NitrOS-9 Level 2 and above) *
MonType             RMB       1                   Monitor type (0=CMP,1=RGB,2=MONO)
MouseInf            RMB       2                   Mouse resolution/Mouse port; was 1, major error RG.
KeyRptS             RMB       1                   Key repeat start constant
KeyRptD             RMB       1                   Key repeat delay constant
                    ENDC

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
BufWrits            EQU       ModProt             SCF buffered read supported (Coco only at this point)
BufReads            EQU       %00010000           SCF buffered write supported (Coco only at this point)
* LCB - propose we add Buffered Read/Buffered Write attribute bits for Coco (in descriptors and
*   drivers for SCF), with one of them replacing ModProt. SCF would check Read/ReadLn and Write/WritLn
*   calls, and if both the driver and descriptor have the appropriate bit set, it would do buffered 32
*   byte (for now) reads/writes like the Grfdrv write call does now, for all bytes that are ASCII >$1F
*   (ie non-control chars, which need special processing)


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
                    IFEQ      Level-1

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

                    ELSE

* Level 2 process descriptor defs
DefIOSiz            EQU       16                  Default I/O Data Length
NefIOSiz            EQU       12                  On-Net Default I/O Data Length
NumPaths            EQU       16                  Number of Local Paths

                    ORG       0
P$ID                RMB       1                   Process ID
P$PID               RMB       1                   Parent's ID
P$SID               RMB       1                   Sibling's ID
P$CID               RMB       1                   Child's ID
P$SP                RMB       2                   Stack ptr
P$Task              RMB       1                   Task Number
P$PagCnt            RMB       1                   Memory Page Count
P$User              RMB       2                   User Index
P$Prior             RMB       1                   Priority
P$Age               RMB       1                   Age
P$State             RMB       1                   Status
P$Queue             RMB       2                   Queue Link (Process ptr)
P$IOQP              RMB       1                   Previous I/O Queue Link (Process ID)
P$IOQN              RMB       1                   Next I/O Queue Link (Process ID)
P$PModul            RMB       2                   Primary Module
P$SWI               RMB       2                   SWI Entry Point
P$SWI2              RMB       2                   SWI2 Entry Point
P$SWI3              RMB       2                   SWI3 Entry Point
P$Signal            RMB       1                   Signal Code
P$SigVec            RMB       2                   Signal Intercept Vector
P$SigDat            RMB       2                   Signal Intercept Data Address
P$DeadLk            RMB       1                   Dominant proc ID if I/O locked
                    RMB       $20-.               unused
P$DIO               RMB       DefIOSiz            Default I/O ptrs
P$Path              RMB       NumPaths            I/O Path Table
P$DATImg            RMB       64                  DAT Image
P$Links             RMB       32                  Block Link counts
P$NIO               RMB       6*2                 additional DIO ptrs for net, compatible  with 68k
P$SelP              RMB       1                   Selected Path for COCO Windows (Default 0)
P$UTicks            RMB       4                   proc User Tick counter        (L2V3)
P$STicks            RMB       4                   proc System Tick counter      (L2V3)
P$FCalls            RMB       4                   proc F$ call counter          (L2V3)
P$ICalls            RMB       4                   proc I$ call counter          (L2V3)
P$DatBeg            RMB       3                   proc Date of creation (Y/M/D) (L2V3)
P$TimBeg            RMB       3                   proc Time of creation (H/M/S) (L2V3)
P$Alarm             RMB       6
                    RMB       $200-.              Local stack
P$Stack             EQU       .                   Top of Stack
P$Size              EQU       .                   Size of Process Descriptor

*
* Process State Flags
*
SysState            EQU       %10000000
TimSleep            EQU       %01000000
TimOut              EQU       %00100000
ImgChg              EQU       %00010000
Suspend             EQU       %00001000
Condem              EQU       %00000010
Dead                EQU       %00000001

                    ENDC

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
                    IFGT      Level-1
V$DRIVEX            RMB       2                   Device Driver execution address
V$FMGREX            RMB       2                   File Manager execution address
                    ENDC
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
                    IFGT      Level-1
Q$MAP               RMB       2                   NitrOS-9 Level 2 and above
                    ENDC
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
                    IFNE      H6309
R$E                 EQU       3                   E Accumulator
R$F                 EQU       4                   F Accumulator
R$W                 EQU       R$E                 Combined E:F Accumulator
R$Q                 EQU       R$A                 Combined A:B:E:F Accumulator
R$DP                EQU       5                   Direct Page register
R$X                 EQU       6                   X Index register
R$Y                 EQU       8                   Y Index register
R$U                 EQU       10                  User Stack register
R$PC                EQU       12                  Program Counter register
R$Size              EQU       14                  Total register package size
                    ELSE
R$DP                EQU       3                   Direct Page register
R$X                 EQU       4                   X Index register
R$Y                 EQU       6                   Y Index register
R$U                 EQU       8                   User Stack register
R$PC                EQU       10                  Program Counter register
R$Size              EQU       12                  Total register package size
                    ENDC

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


                    IFGT      Level-2
***************************
* Level 3 Defs
*
* These definitions apply to NitrOS-9 Level 3
*
L3.Start            EQU       $2000               Start off at slot 1
L3.Size             EQU       $40                 Go for 64 pages: 2 slots total
L3.Blks             EQU       L3.Size/$20         Number of slots
L3.End              EQU       L3.Start+L3.Size*$0100 end of L3 memory
L3.SCF              EQU       $0660               SCF block ptr
L3.RBF              EQU       L3.SCF+1            RBF block ptr
                    ENDC

                    ENDC
