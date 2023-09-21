               IFNE      COCOVTIO.D-1
COCOVTIO.D     SET       1

               IFEQ      Level-1

********************************************************************
* VTIODefs - Video Terminal I/O Definitions for CoCo 1/2
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2004/11/29  P.Harvey-Smith.
* Added symbolic defines for bits in V.CoLoad.
*
*          2004/12/02  P.Harvey-Smith.
* Moved over all variables from co51.asm
*
*          2005/04/09  P.Harvey-Smith.
* Decoded rest of the CoHR memory locations.
*
*	       2005/04/24  P.Harvey-Smith.
* Added variables for cursor flash, currently only implemented in co51
*
               NAM       VTIODefs  
               TTL       Video Terminal I/O Definitions for CoCo 1/2

********************
* VTIO Static Memory
*
               ORG       V.SCF
V.ScrnA        RMB       2                   (2) screen start address in system memory
V.ScrnE        RMB       2                   (2) address of end of screen
V.CrsrA        RMB       1                   (2) cursor address
V.CrsAL        RMB       1                   cursor address low
V.CChar        RMB       1                   value of character under cursor
V.Mode         RMB       1                   mode: 0=256x192 x2, 1=128x192 x4
V.NGChr        RMB       1                   number of additional characters to get
V.RTAdd        RMB       2                   (2) return address after getting characters
V.NChar        RMB       1                   character to process
V.NChr2        RMB       1                   and the next one
               RMB       1                   (I assume reserved for a 3rd parameter byte)
V.Chr1         RMB       1                   same as under cursor character
V.CColr        RMB       1                   cursor color
V.Col          RMB       1                   number of columns for this screen
V.Row          RMB       1                   number of rows
V.Alpha        RMB       1                   0 when in alpha mode
V.PIA1         RMB       1                   PIA1Base value
V.Rdy          RMB       1                   device ready (see SS.DStat 0=not ready)
V.CFlg1        RMB       1                   VDG display code values
V.SBAdd        RMB       2                   (2) address of block screen is in
V.GBuff        RMB       2                   allocation for graphics buffers (block#)
V.AGBuf        RMB       4                   (2) additional graphics buffer
V.FFMem        RMB       2                   Flood fill alloc'ed mem
V.FFSPt        RMB       2                   Flood fill current stack pointer
V.FFSTp        RMB       1                   Flood fill stack top
V.FF6          RMB       1                   flood fill flag
V.FFFlag       RMB       1                   Error in FloodFill - E$Write if FFill stack overflows, 0 if no error
V.MTabl        RMB       2                   (2) address of mask table for pixels in byte
V.PixBt        RMB       1                   bit mask for modes (0=$07, 1=$03 )#pixels/byte
V.GCrsX        RMB       1                   graphics cursor X value
V.GCrsY        RMB       1                   graphics cursor Y
V.Msk1         RMB       1                   mask byte 1
V.Msk2         RMB       1                   mask byte 2 (00,55,AA,FF) Full byte Color Mask
V.MCol         RMB       1                   Start pixel in a byte mask ($C0=4 color, $80=2 color)
V.4A           RMB       1                   End pixel in a byte mask ($03=4 color,$01=2 color)
V.PMask        RMB       1                   Full byte pixel mask for colors (i.e. $55, $CC etc)
V.4C           RMB       1
V.4D           RMB       1
V.4E           RMB       1                   Flood Fill full byte color mask
V.4F           RMB       1
V.Caps         RMB       1                   caps lock info: $00=lower $FF=upper
V.ClkCnt       RMB       1                   clock count ??
V.WrChr        RMB       1                   character to write
V.CurCo        RMB       1                   current CO-module in use
* start of CoWP-specific static memory
V.Co80X        RMB       1                   V.54
V.Co80Y        RMB       1                   V.55
V.ColPtr       RMB       1                   V.56
V.RowPtr       RMB       1                   V.57
V.C80X         RMB       1                   CoWP X position
V.C80Y         RMB       1                   CoWP Y position
V.Invers       RMB       1
* end of CoWP-specific static memory
V.DspVct       RMB       2                   vector to display screen
V.CnvVct       RMB       2                   vector to X/Y to address conversion
V.LKeyCd       RMB       1                   last key code
V.2Key1        RMB       1                   2nd Key 1
V.2Key2        RMB       1                   2nd Key 2
V.2Key3        RMB       1                   2nd Key 3
V.Key1         RMB       1                   Key 1
V.Key2         RMB       1                   Key 2
V.Key3         RMB       1                   Key 3
V.ShftDn       RMB       1                   SHIFT/CTRL state
V.CtrlDn       RMB       1                   CTRL key down
V.KeyFlg       RMB       1                   key flag
V.AltDwn       RMB       1                   ALT key down
V.KySns        RMB       1                   key sense flags
V.KySame       RMB       1                   key same as last flag
V.KySnsF       RMB       1                   key sense flag
V.Spcl         RMB       1
V.KTblLC       RMB       1                   key table entry #
V.6F           RMB       1                   ???
V.COLoad       RMB       1                   CO-module loaded flags
V.CFlag        RMB       1                   true lowercase flag $10=true, $00=false
V.GrfDrvE      RMB       2                   GrfDrv entry point
V.CoVDGE       RMB       2                   CoVDG entry point
V.CoWPE        RMB       2                   CoWP entry point
V.CoHRE        RMB       2                   CoHR entry point
V.Co42E        RMB       2                   Co42 entry point
V.CoVGAE       RMB       2                   CoVGA entry point
V.Co80E        RMB       2                   Co80 entry point
V.CoDPlusE     RMB       2                   CoDPlus entry point
V.Flash        RMB       2                   Cursor flash routine address.
v.FlashTime    RMB       1                   Cursor flash time
v.FlashCount   RMB       1                   Cursor flash count
V.NoFlash      RMB       1                   When this is non-zero do not flash cursor
* If we make ClrBlk vector, throw it in here so the various comoduels, as well as VTIO,
* can all use it (clearing text/graphics screens, clearing full width line (pure text or
* CoHr/Co42 graphics lines), and possibly Clear to end of line could all use it.
V.ClrBlk       RMB       2                   Vector to mini-stack blast clearing routine
V.CpyBlk       RMB       2                   Vector to mini-stack blast copying routine
* CoHR vars
V.51ScrnA      RMB       2                   * Screen address.
V.51XPos       RMB       1                   * X co-ordinate
V.51YPos       RMB       1                   * Y co-ordinate
V.51EscSeq     RMB       1                   * In escape sequence
V.51ReverseFlag RMB       1                  * Reverse video flag
V.51UnderlineFlag RMB       1                * Underline flag
V.51CtrlDispatch RMB       2                 * Ctrl char dispatch address, currently processing
V.51BytePixOffset RMB       1                * byte offset in screen line, of character X position        
V.51OldCursorPosX RMB       1                * Position of old cursor before update        
V.51OldCursorPosY RMB       1
V.51CursorChanged RMB       1                * Has cursor position changed ? 1=yes,0=no
V.51CursorOn   RMB       1                   * Is cursor on ? 1=yes 0=no		         
V.51XORFlag    RMB       1                   * and data to screen (0) or Xor (1)  		       
V.51ScreenMask1 RMB       1                  * screen masks for drawing characters on screen         
V.51ScreenMask2 RMB       1
* End of CoHR vars
**** Note these have to come at the end of the defs, or the keyboard ****
**** code can clobber variables defined after these !                ****
V.IBufH        RMB       1                   input buffer head
V.IBufT        RMB       1                   input buffer tail
V.InBuf        RMB       1                   input buffer ptr
V.51End        RMB       1
               RMB       250-.
V.Last         EQU       .


* Unknown for now
*VD.FFMem rmb   2  (2) bottom of stack for flood fill
*VD.FFSPt rmb   2  (2) flood fill stack pointer
*VD.FFSTp rmb   2  (2) flood fill stack top pointer
*VD.FF6   rmb   1   flood fill flag
*VD.MCol2 rmb   1  color
*VD.FF1   rmb   1  data for flood fill
*VD.FF2   rmb   1  data for flood fill
*VD.FFMsk rmb   1  flood fill mask
*VD.FFFlg rmb   1  flood fill flag
*VD.Palet rmb   16 (16) current palette values
*VD.PlFlg rmb   1  initialized to $08 by L00DB, and then unused!

*
* Defs for V.COLoad flags.
* 

ModCoVDG       EQU       %00000010           CoVDG, Built-in VDG 32x16.
ModCoWP        EQU       %00000100           CoWP, WordPak, 80x25
ModCoHR        EQU       %00001000           CoHR, PMODE 4 51x25 text
ModCo42        EQU       %00010000           Co42, PMODE 4 42x25 text
ModCoVGA       EQU       %00100000           CoVGA, 64x32 text
ModCo80        EQU       %01000000           Co80, CRT9128 WordPak, 80x25
ModCoDPlus     EQU       %10000000           Dragon Plus, 6545, 80x24

*
* Defs for cursor flash counter
*

CFlash50hz     EQU       25                  * 50Hz flash counter
CFlash60Hz     EQU       30                  * 60Hz flash counter

               ELSE
               
********************************************************************
* VTIODefs - Video Terminal I/O Definitions for CoCo 3
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2004/07/18  Boisy G. Pitre
* Started from systype

               NAM       VTIODefs
               TTL       Video Terminal I/O Definitions for CoCo 3

****************
* Window Devices
*
               ORG       $FF9F
A.W            RMB       1                   $FF9F Generic Window Descriptor
A.TermW        RMB       1                   $FFA0 Windowing Term
A.W1           RMB       1                   $FFA1
A.W2           RMB       1                   $FFA2
A.W3           RMB       1                   $FFA3
A.W4           RMB       1                   $FFA4
A.W5           RMB       1                   $FFA5
A.W6           RMB       1                   $FFA6
A.W7           RMB       1                   $FFA7
A.W8           RMB       1                   $FFA8
A.W9           RMB       1                   $FFA9
A.W10          RMB       1                   $FFAA
A.W11          RMB       1                   $FFAB
A.W12          RMB       1                   $FFAC
A.W13          RMB       1                   $FFAD
A.W14          RMB       1                   $FFAE
A.W15          RMB       1                   $FFAF

**********************************
* Pointer Device Packet Definition
*
               ORG       0
Pt.Valid       RMB       1                   Is returned info valid (0=no/1=yes)
Pt.Actv        RMB       1                   Active Side 0=off/1=Right/2=left
Pt.ToTm        RMB       1                   Time out Initial value
               RMB       2                   reserved
Pt.TTTo        RMB       1                   Time Till Timeout
Pt.TSSt        RMB       2                   Time Since Start Counter
Pt.CBSA        RMB       1                   Current Button State Button A
Pt.CBSB        RMB       1                   Current Button State Button B
Pt.CCtA        RMB       1                   Click Count Button A
Pt.CCtB        RMB       1                   Click Count Button B
Pt.TTSA        RMB       1                   Time This State Counter Button A
Pt.TTSB        RMB       1                   Time This State Counter Button B
Pt.TLSA        RMB       1                   Time Last State Counter Button A
Pt.TLSB        RMB       1                   Time Last State Counter Button B
               RMB       2                   Reserved
Pt.BDX         RMB       2                   Button down X value EXPERIMENTAL
Pt.BDY         RMB       2                   Button down Y value
Pt.Stat        RMB       1                   Window Pointer type location
Pt.Res         RMB       1                   Resolution (0..640 by: 0=ten/1=one)
Pt.AcX         RMB       2                   Actual X Value
Pt.AcY         RMB       2                   Actual Y Value
Pt.WRX         RMB       2                   Window Relative X
Pt.WRY         RMB       2                   Window Relative Y
Pt.Siz         EQU       .                   Packet Size 32 bytes

**************************
* window regions for mouse
*
WR.Cntnt       EQU       0                   content region
WR.Cntrl       EQU       1                   control region
WR.OfWin       EQU       2                   off window

*************************************
* Standard system get/put buffer defs
*
*
* system group numbers
*
               ORG       200
Grp.Fnt        RMB       1                   font group
Grp.Clip       RMB       1                   clipboard group
Grp.Ptr        RMB       1                   pointer group
Grp.Pat2       RMB       1                   pattern group 2 color
Grp.Pat4       RMB       1                   pattern group 4 color
Grp.Pat6       RMB       1                   pattern group 16 color
*
* font buffer numbers
*
               ORG       1
Fnt.S8x8       RMB       1                   standard 8x8 font
Fnt.S6x8       RMB       1                   standard 6x8 font
Fnt.G8x8       RMB       1                   standard graphics 8x8 font
*
* pattern buffer numbers
*
               ORG       1
Pat.Dot        RMB       1
Pat.Vrt        RMB       1
Pat.Hrz        RMB       1
Pat.XHtc       RMB       1
Pat.LSnt       RMB       1
Pat.RSnt       RMB       1
Pat.SDot       RMB       1
Pat.BDot       RMB       1
*
* pointer buffer numbers
*
               ORG       1
Ptr.Arr        RMB       1                   Arrow pointer
Ptr.Pen        RMB       1                   Pencil pointer
Ptr.LCH        RMB       1                   Large cross hair pointer
Ptr.Slp        RMB       1                   Wait timer pointer
Ptr.Ill        RMB       1                   Illegal action pointer
Ptr.Txt        RMB       1                   Text pointer
Ptr.SCH        RMB       1                   Small cross hair pointer

**********************
* KeyDrv Entry Points
               ORG       0
K$Init         RMB       3                   joystick initialization
K$Term         RMB       3                   joystick termination
K$FnKey        RMB       3                   get function key states
K$RdKey        RMB       3                   get key states

**********************
* JoyDrv Entry Points
               ORG       0
J$Init         RMB       3                   joystick initialization
J$Term         RMB       3                   joystick termination
J$MsBtn        RMB       3                   get mouse button states
J$MsXY         RMB       3                   get mouse X/Y coordinates
J$JyBtn        RMB       3                   get joystick button states
J$JyXY         RMB       3                   get joystick X/Y coordinates

**********************
* SndDrv Entry Points
               ORG       0
S$Init         RMB       3                   joystick initialization
S$GetStt       RMB       3                   joystick termination
S$SetStt       RMB       3                   joystick termination
S$Term         RMB       3                   get joystick X/Y coordinates

********************************
* Window/Menu Bar Data Structure
*
* To be used in SS.WnSet SETSTAT to set up a Framed Window
* for use in the high level windowing package.
*
NUMMENS        EQU       10                  maximum number of menus on menu bar
NUMITMS        EQU       20                  maximum number of items in a menu
MXTTLEN        EQU       15                  max chars for menu and item names
WINSYNC        EQU       $C0C0               synch bytes for window validation
*
* Menu Item Descriptor : (MN.ITEMS)
* one required for each item within the menu
*
               ORG       0
MI.TTL         RMB       MXTTLEN             item name
MI.ENBL        RMB       1                   enable flag
MI.RES         RMB       5                   reserved bytes
MI.SIZ         EQU       .                   size of menu item descriptor
*
* Menu Descriptor :
* one for each menu on the manu bar
* each is pointed to by MB.MPTR below
*
               ORG       0
MN.TTL         RMB       MXTTLEN             menu title
MN.ID          RMB       1                   menu id number (1-255)
MN.XSIZ        RMB       1                   horiz. size of desired pull down
MN.NITS        RMB       1                   number of items in menu
MN.ENBL        RMB       1                   enable flag
MN.RES         RMB       2                   reserved bytes
MN.ITEMS       RMB       2                   pointer to array of menu items
MN.SIZ         EQU       .                   size of menu descriptor
*
* Window Descriptor:
* one required for each application in a framed window
*
               ORG       0
WN.TTL         RMB       20                  title of window for title bar
WN.NMNS        RMB       1                   number of menus in menu bar
WN.XMIN        RMB       1                   minimal horiz. size for application to run
WN.YMIN        RMB       1                   minimal vert. size for application to run
WN.SYNC        RMB       2                   synch bytes ($C0C0)
WN.RES         RMB       7                   reserved bytes
WN.BAR         RMB       2                   pointer to arry of menu descriptors
WN.SIZ         EQU       .                   size of window/menu bar descriptor

*************************
* Window Type Definitions
*
* To be used in setting up the border of the window in
* the SS.WnSel SETSTAT
*
               ORG       0
WT.NBox        RMB       1                   No Box
WT.FWin        RMB       1                   Framed Window
WT.FSWin       RMB       1                   Framed Window w/Scroll Bars
WT.SBox        RMB       1                   Shadowed Box
WT.DBox        RMB       1                   Double Box
WT.PBox        RMB       1                   Plain Box

*************************************
* Pre-Defined Menu IDs for the system
*
               ORG       1
MId.Mov        RMB       1                   move box
MId.Cls        RMB       1                   close box
MId.Grw        RMB       1                   grow box
MId.SUp        RMB       1                   scroll up
MId.SDn        RMB       1                   scroll down
MId.SRt        RMB       1                   scroll right
MId.SLt        RMB       1                   scroll left
MId.Chr        RMB       1                   character was depressed
               ORG       20
MId.Tdy        RMB       1                   Tandy menu
MId.Fil        RMB       1                   Files Menu
MId.Edt        RMB       1                   Edit Menu
MId.Sty        RMB       1                   Styles menu
MId.Fnt        RMB       1                   Font menu


******************************************************************************
******************************************************************************
**                                                                          **
** NitrOS-9 Windowing system Global data definitions                        **
**                                                                          **
******************************************************************************
******************************************************************************
**                                                                          **
** System memory block 0 layout:                                            **
**                                                                          **
** $0000-$0001 : FHL/Isted WD 1002-05 - interface base address              **
** $0002       : FHL/Isted WD 1002-05 - boot device physical drive #        **
** $0008       : Bruce Isted Serial mouse - button counter & rx count       **
** $0009-$000B : Bruce Isted Serial mouse - RX buffer                       **
** $000C-$000D : Bruce Isted Serial mouse - Current X position              **
** $000E-$000F : Bruce Isted Serial mouse - Current Y position              **
** $0010-$001F : unused (User definable)                                    **
** $0020-$00FF : system direct page & some IRQ vectors                      **
** $0100-$011F : Task usage table                                           **
** $0120-$01FF : Virtual DAT tasks (pointed to by <D.TskIPt)                **
** $0200-$02FF : memory block usage map ($80=Not RAM,$01=in use,$02=module) **
** $0300-$03FF : system's system call dispatch table                        **
** $0400-$04FF : user's system call dispatch table                          **
** $0500-$05FF : process descriptor pointer table                           **
** $0600-$07FF : System task (Task 0, ID 1) process descriptor              **
** $0800-$08FF : System's stack space (initial ptr is $0900)                **
** $0900-$09FF : SMAP table ($01=in used, $80=NOT RAM)                      **
** $0A00-$0FFF : module directory DAT Images (8 bytes each)                 **
** $1000-$10FF : System Global memory (pointed to by D.CCMem)               **
** $1100-$11FF : GRFDRV global memory (DP=$11 in GRFDRV)                    **
** $1200-$1247 : shared buffer between Grf/WindInt & GRFDRV (GP buffers)    **
** $1248-$127F : ????                                                       **
** $1280-$1A7F : the window tables (32 of $40 bytes each)                   **
** $1A80-$1C7F : the screen tables (16 of $20 bytes each)                   **
** $1C80-$2000 : the CC3 global mem stack (for windowing)                   **
**                                                                          **
******************************************************************************
******************************************************************************

* User settable values for VTIO/TC9IO/GrfInt/WindInt & GrfDrv
MaxLines       EQU       25                  Max. Y coord text value
Meg            SET       false               "true" if 1 or 2 meg machine

COMP           EQU       0                   composite monitor
RGB            EQU       1                   RGB Analog monitor 
MONO           EQU       2                   monochrome monitor

Monitor        SET       RGB

* Global definitions
KeyMse         EQU       %00000001           keyboard mouse enabled
NumLck         EQU       %00000010           Numlock enabled (TC-9 use only)
CapsLck        EQU       %00000100           Capslock enabled
MaxRows        EQU       640                 maximum X co-ordinate allowed on mouse
             IFEQ      MaxLines-25
MaxLine        EQU       198                 maximum Y co-ordinate allowed on mouse
             ELSE      
MaxLine        EQU       191                 maximum Y co-ordinate allowed on mouse
             ENDC      

*****************************************************************************
* Static memory area for each window (VTIO/TC9IO)
* Should set up a write buffer (using parm area?) between SCF, VTIO & Grfdrv
* so we can 'burst mode' text output (copy up to 48 chars to Grfdrv's parm
* area, and have grfdrv loop through & write all 48 chars to screen in 1 loop
* May have to have smaller limit for text to gfx screens, as it will run much
* slower, unless GrfDrv is made Partially/Fully Re-Entrant
*
* STRONG CAUTION:  scfdefs MUST be included first before this file if
* V.SCF is to be resolved properly in pass 1!!
               ORG       V.SCF
V.WinType      RMB       1                   window type (0=Windint/GrfInt,2=VDGInt)      $1D
V.InfVld       RMB       1                   Rest of info here valid? (0=NO, >0 = YES)    $1E
V.DevPar       RMB       2                   high bit=window device                       $1F
V.ULCase       RMB       1                   special key flags (Capslck & keyboard mouse) $21
V.KySnsFlg     RMB       1                   flag for key sense setstat                   $22
V.ScrChg       RMB       1                   screen change flag                           $23
V.SSigID       RMB       1                   data ready process ID                        $24
V.SSigSg       RMB       1                   data ready signal code                       $25
V.MSigID       RMB       1                   mouse signal process ID                      $26
V.MSigSg       RMB       1                   mouse signal signal code                     $27
V.MSmpl        RMB       1                   mouse sample rate                            $28
V.MTime        RMB       1                   mouse timeout value                          $29
               RMB       1                   unused                                       $2A
V.MAutoF       RMB       1                   auto follow mouse flag                       $2B
V.ParmCnt      RMB       1                   parameter count                              $2C
V.ParmVct      RMB       2                   parameter vector                             $2D
V.PrmStrt      RMB       2                   pointer to params start                      $2F
V.NxtPrm       RMB       2                   pointer to next param storage                $31
V.EndPtr       RMB       1                   last character read offset                   $33
V.InpPtr       RMB       1                   next character read offset                   $34
V.WinNum       RMB       1                   window table entry #                         $35
V.DWNum        RMB       1                   dwnum from descriptor                        $36
V.CallCde      RMB       1                   internal comod call code #                   $37
CC3Parm        RMB       128-.               global parameter area
ReadBuf        RMB       256-.               read input buffer (keyboard)
CC3DSiz        EQU       .

*****************************************************************************
* GrfInt/WindInt global memory area
* This area sits in system block 0 from $1000 to $10ff
WGlobal        EQU       $1000               useful value (points to address starting below)
               ORG       0
G.CurTik       RMB       1                   Constant - # Clock ticks/cursor updates (2)
G.CntTik       RMB       1                   Current tick count for cursor updates
G.GfBusy       RMB       1                   Grfdrv is busy flag (1=busy)
G.OrgAlt       RMB       2                   Place to store D.AltIRQ before altering
*g0003    rmb   2          NEW: UNUSED
g0005          RMB       2                   Temp save in Windint RG
G.GrfStk       RMB       2                   grfdrv stack pointer ($07)
G.MonTyp       RMB       1                   monitor type
g000A          EQU       .                   Old label for compatibility
G.CrDvFl       RMB       1  Are we current device flag (only set when all
*                           Parms have been moved to Dev Mem)
*                           0=We are not on our device
*                           1=We are the current device
*                           (Used by comod (GRF/WIND/VDGInt) to determine
*                           whether or not to update GIME regs themselves
*                           If not current device, they don't.)
G.WinType      RMB       1                   current device's V.TYPE
G.CurDvM       RMB       2                   current device memory pointer for co-module use
G.WIBusy       RMB       1                   WindInt is busy flag (1=busy)
G.AlPckt       RMB       6                   F$Alarm time packet
G.AlPID        RMB       1                   F$Alarm proc ID ($15)
G.AlSig        RMB       1                   F$Alarm signal code ($16)
G.BelVec       RMB       2                   BELL routine vector
G.DefPal       RMB       2                   pointer to default palette data in global mem
G.TnCnt        RMB       1                   SS.Tone duration counter
G.BelTnF       RMB       1                   BELL tone flag
g001D          RMB       3
G.CurDev       RMB       2                   current device's static memory pointer ($20)
G.PrWMPt       RMB       2                   previous window static mem pointer $(22)
G.BCFFlg       RMB       1                   bit coded co-module found flags ($24)
*                           00000010 : VDGInt found
*                           10000000 : GrfDrv found
g0025          RMB       1
G.KTblLC       RMB       1                   Key table entry# last checked (1-3)
*         IFEQ  TC9-true
*CurLght  rmb   1          current keyboard light settings
*         ELSE  
G.LastCh       RMB       1                   last keyboard character (ASCII value)
*         ENDC  
G.LKeyCd       RMB       1                   last keyboard code
G.KyRept       RMB       1                   key repeat counter
* A secondary 3 key table (same format as g002D below)
G.2Key1        RMB       1                   $2A
G.2Key2        RMB       1                   $2B
G.2Key3        RMB       1
* Up to 3 keys can be registerd at once, and they are stored here. If more
* than 3 are hit, the last key is overwritten with the very last key down that
* was checked. Format for all three is the same as the PIA column/row byte @
* KeyFlag below.
G.Key1         RMB       1                   Key 1 being held down (Row/Column #)
G.Key2         RMB       1                   Key 2 being held down (Row/Column #)
G.Key3         RMB       1                   Key 3 being held down (Row/Column #)
G.ShftDn       RMB       1                   SHIFT key down flag (COM'd) ($30)
G.CntlDn       RMB       1                   CTRL key down flag (0=NO)
G.KeyFlg       RMB       1                   Keyboard PIA bit #'s for columns/rows
*                           %00000111-Column # (Output, 0-7)
*                           %00111000-Row # (Input, 0-6)
G.AltDwn       RMB       1                   ALT key down flag (0=NO)
G.KySns        RMB       1                   key sense byte
G.KySame       RMB       1                   same key flag
G.CapLok       RMB       1                   CapsLock/SysRq key down flag
               RMB       1
g0038          RMB       1                   grfdrv initialized flag
               RMB       2
G.MSmpRt       RMB       1                   Current mouse sample # (# ticks till next read)
G.Mouse        RMB       Pt.Siz              mouse packet ($3C)
g005C          RMB       2                   Temp for relative mouse X coord calculation
g005E          RMB       2                   Temp for relative mouse Y coord calculation
G.MSmpRV       RMB       1                   Mouse sample reset value (# ticks till next read)
G.KyDly        RMB       1                   initial key repeat delay constant ($61)
G.KySpd        RMB       1                   secondary key repeat delay constant
*         IFEQ  TC9-true
*KeyParm  rmb   1          keyboard command parameter byte
*         ELSE  
G.KyMse        RMB       1                   keyboard mouse flag ($63)
*         ENDC  
G.Clear        RMB       1                   "one-shot" CapsLock/SysRq key flag ($64)
G.KyButt       RMB       1                   keyboard F1 and F2 "fire" button info ($65)
G.AutoMs       RMB       1                   Auto-follow mouse flag for current device (0=NO)
G.MseMv        RMB       1                   mouse moved flag ($67)
G.CoTble       RMB       6                   co-module table ($68)
G.GrfEnt       RMB       2                   GRFDRV Entry address ($6E)
g0070          RMB       1                   # bytes to move in 1 block (1-72)
G.WUseTb       RMB       4                   windows in use bit table (0=unused, 32 windows) ($71)
G.GfxTbl       RMB       2                   Pointer to GFX tables ($75)
G.WrkWTb       RMB       $40                 Work window table. WindInt only ($77)
g00B7          RMB       2                   Current Device static mem ptr for WindInt
g00B9          RMB       2                   Current window table ptr for WindInt
g00BB          RMB       2                   Pointer to work window table (g0077+$10)
g00BD          RMB       1                   Current screen type for work window table
g00BE          RMB       1                   Topmost overlay window # when check for title bars
g00BF          RMB       1                   Flag for keypress while processing menu select
g00C0          RMB       2                   Ptr to current path descriptor
G.WindBk       RMB       2                   shift-clear routine vector
G.MsInit       RMB       2                   set mouse routine vector
G.MsSig        RMB       1                   mouse signal flag
G.DefPls       RMB       16                  Default palettes (2 repeats of 8 is default) ($C7)
g00D7          RMB       9
G.KeyEnt       RMB       2                   entry to keydrv subroutine module ($E0)
G.KeyMem       RMB       8                   static memory for keydrv subroutine module
G.JoyEnt       RMB       2                   entry to joydrv subroutine module ($EA)
G.JoyMem       RMB       8                   static memory for joydrv subroutine module
G.SndEnt       RMB       2                   entry to snddrv subroutine module ($F4)
G.SndMem       RMB       8                   static memory for snddrv subroutine module

*****************************************************************************
* GrfDrv global memory data definitions
* This area sits in system block 0 from $1100 to $119E
GrfMem         EQU       $1100               useful label used to point to mem starting below
               ORG       0
gr0000         RMB       1                   Pixel mask for 1st byte of GP line
gr0001         RMB       1                   Pixel mask for last byte of a GP line
gr0002         RMB       2                   Ptr to table of bit masks for colors
gr0004         RMB       1                   # of bytes wide GP buffer is (including partials)
gr0005         RMB       1                   # pixels per byte in GP Buffer
gr0006         RMB       1                   # of pixels used in 1st byte of GP buffer line
gr0007         RMB       1                   # of pixels used in last byte of GP buffer line
gr0008         RMB       1                   Bit mask that is common to both screen & GP buffer
gr0009         RMB       1                   # bytes for width of overlay window
gr000A         RMB       1                   # bytes to offset to get to next line after
*                             overlay width has been copied
gr000B         RMB       1
gr000C         RMB       2                   Cursor address for proportional spacing?
gr000E         RMB       1
gr000F         RMB       1                   Left-based bit mask for proportional spacing?
gr0010         RMB       2                   Vector for text to gfx screen (either prop. or normal)
gr0012         RMB       6
gr0018         RMB       2                   Working Center X coord for Circle/Ellipse
gr001A         RMB       2                   Working Center Y coord for Circle/Ellipse
gr001C         RMB       2                   Some variable for Circle/Ellipse (initially 0)
gr001E         RMB       2                   Working Y radius value for Circle/Ellipse
gr0020         RMB       2                   Arc 'clip line' X01
gr0022         RMB       2                   Arc 'clip line' Y01
gr0024         RMB       2                   Arc 'clip line' X02
gr0026         RMB       2                   Arc 'clip line' Y02
gr0028         RMB       1                   full-byte background color to FFILL on mask
gr0029         RMB       1                   pixels per byte: set up by FFILL
gr002A         RMB       1                   Flag for FFill: 1=no error, 0=Stack overflow error
gr002B         RMB       1                   current Y-direction to travel in FFILL
gr002C         RMB       2
gr002E         RMB       2                   current window table entry
gr0030         RMB       2                   current screen table ptr
gr0032         RMB       1                   Last block # we used for buffers
gr0033         RMB       2                   Last offset we used for buffers
gr0035         RMB       1                   group
gr0036         RMB       2                   offset
gr0038         RMB       1                   group returned (new)
gr0039         RMB       1                   0=Text cursor inverted off, >0 is inverted on
gr003A         RMB       1                   0=Graphics cursor XOR'd off,>0 is XOR'd on scrn
gr003B         RMB       2                   end of vars ptr?
gr003D         RMB       2                   Last X coordinate Graphics cursor was ON at
gr003F         RMB       2                   Last Y coordinate Graphics cursor was ON at
gr0041         RMB       2                   Screen address for start of current gfx cursor
gr0043         RMB       1                   Pixel mask for start of gfx cursor
gr0044         RMB       1                   Block # Graphics cursor is in
gr0045         RMB       2                   Offset in block Graphics cursor is in
gr0047         RMB       2                   'Working' X coordinate
gr0049         RMB       2                   'Working' Y coordinate
gr004B         RMB       2                   current X
gr004D         RMB       2                   current Y
gr004F         RMB       2                   X Size (in bytes)
gr0051         RMB       2                   Y Size (in bytes)
gr0053         RMB       2                   Horizontal radius (circle/ellipse/arc)
gr0055         RMB       2                   Vertical radius (circle/ellipse/arc)
gr0057         RMB       1                   group
gr0058         RMB       1                   buffer #
gr0059         RMB       1                   save switch for overlay
gr005A         RMB       1                   PRN
gr005B         RMB       2                   X coordinate of Graphics cursor
gr005D         RMB       2                   Y coordinate of Graphics cursor
gr005F         RMB       1                   ATD: new video mode for 24/25/28-line windows
Gr.STYMk       RMB       1                   STY marker
gr0061         RMB       1                   foreground RGB data
gr0062         RMB       1                   background RGB data
gr0063         RMB       1                   bytes/row (on current screen...not window)
gr0064         RMB       2                   PSet vector
gr0066         RMB       2                   pset offset
gr0068         RMB       2                   LSet vector
gr006A         RMB       2                   max X co-ordinate
gr006C         RMB       2                   max Y co-ordinate
gr006E         RMB       2                   X pixel count
gr0070         RMB       2                   Y pixel count
gr0072         RMB       2                   Screen address of pixel we are doing
gr0074         RMB       1                   Pixel mask for pixel we are doing
gr0075         RMB       2                   ??? Pixel mask for last byte of GP buffer?
gr0077         RMB       2                   Vector for right direction FFill
gr0079         RMB       1                   bit mask for 1st pixel in byte for right dir. FFill
gr007A         RMB       2                   Vector for left direction FFill
gr007C         RMB       1                   bit mask for last pixel in byte for left dir. FFill
gr007D         RMB       1                   buffer block #
gr007E         RMB       2                   buffer offset #
gr0080         RMB       2                   Buffer length (in bytes)
gr0082         RMB       3                   3 byte extended screen address
gr0085         RMB       2                   temp
gr0087         RMB       16                  grfdrv (sysmap 1) DAT image
gr0097         RMB       1                   temp
gr0098         RMB       1                   temp
* In ARC, 97-98 is the width of the clip line in pixels (after scaling)
gr0099         RMB       2                   temp
* In ARC, 99-9A is the height of the clip line in pixels (after scaling)
gr009B         RMB       1                   counter temp
gr009C         RMB       1
gr009D         RMB       2                   offset to buffer in block
gr009F         RMB       1
gr00A0         RMB       1                   # lines left to do of GP buffer onto screen
gr00A1         RMB       2                   vector routine for (changes lots)
* In ARC A1-A2 is the vector to the proper clipping routine
gr00A3         RMB       2                   Vector for shifting GP buffers
gr00A5         RMB       2                   Vector for shifting GP buffers (can dupe A1)
gr00A7         RMB       2
gr00A9         RMB       2                   NEW: Window tbl ptr for last window GRFDRV used
grBigFnt       RMB       2                   Flag for 224 char font/gfx mode on (0=No) V2.00a
gr00AD         RMB       2                   FFill:orig. start X coord|Circ/Ell saved start X
gr00AF         RMB       2                   FFill:orig. start Y coord|Circ/Ell saved end X
gr00B1         RMB       1                   Flag in FFill: 1=1st time through, 0=not 1st time
gr00B2         RMB       1                   Filled (circle,ellipse) flag 0=Not filled
*gr00B3   rmb    256-.       ??? UNUSED
gr00B3         RMB       1                   temp variable grfdrv
gr00B4         RMB       1                   temp variable grfdrv
gr00B5         RMB       1                   regW for grfdrv
gr00B6         RMB       1
gr00B7         RMB       2
gr00B9         RMB       2                   previously used in grfdrv at $B2 but not for Filled Flag
gr00BB         RMB       2                   previously used in grfdrv at $B4
gr00BD         RMB       2                   previously used in grfdrv at $B6
gr00BF         RMB       256-.
* GPLoad buffer - $1200 in system block 0
GPBuf          RMB       72                  common move buffer for gpload/get/put
gb0000         EQU       72                  Size of get/put buffer ($48)

*****************************************************************************
* Window table entry structure
* These tables sit in system block 0 and there is 1 for every window init'd
* including any overlay windows.
MaxWind        EQU       32                  maximum allowable window tables
WinBase        EQU       $1290               base address to start of window tables
               ORG       -$10
Wt.STbl        RMB       2                   Screen table pointer ($FFFF=Not used)       -$10
Wt.BLnk        RMB       1                   overlay window parent entry # ($FF=base)    -$0E
Wt.LStrt       RMB       2                   screen logical start address                -$0D
Wt.CPX         RMB       1                   current X coord. start                      -$0B
Wt.CPY         RMB       1                   current Y coord. start                      -$0A
Wt.SZX         RMB       1                   current X size (CWArea)                     -$09
Wt.SZY         RMB       1                   current Y size (CWArea)                     -$08
Wt.SXFct       RMB       1                   X scaling factor                            -$07
Wt.SYFct       RMB       1                   Y scaling factor (0=no scaling)             -$06
Wt.Cur         RMB       2                   cursor physical address on screen           -$05
Wt.FMsk        RMB       1                   font bit mask (based from left)             -$03
Wt.CurX        RMB       2                   X coord of cursor                           -$02
Wt.CurY        RMB       2                   Y Coord of cursor                            $00
Wt.XBCnt       RMB       1                   width of window (in bytes)                   $02
Wt.CWTmp       RMB       1                   bytes wide each text chr (1,2,4)             $03
Wt.BRow        RMB       2                   bytes/text row (8x width in gfx)             $04
Wt.Fore        RMB       1                   foreground palette #                         $06
Wt.Back        RMB       1                   background palette #                         $07
Wt.Attr        RMB       1                   default attributes (FUTTTBBB)                $08
Wt.BSW         RMB       1                   character BSW switches                       $09
Wt.LSet        RMB       1                   LSet type                                    $0A
Wt.FBlk        RMB       1                   Font memory block #                          $0B
Wt.FOff        RMB       2                   Font offset in block                         $0C
Wt.PBlk        RMB       1                   PSet memory block #                          $0E
Wt.POff        RMB       2                   PSet offset in block                         $0F
Wt.OBlk        RMB       1                   Overlay memory block #                       $11
Wt.OOff        RMB       2                   Overlay offset in block                      $12
Wt.LVec        RMB       2                   LSet vector                                  $14
Wt.PVec        RMB       2                   PSet vector                                  $16
Wt.GBlk        RMB       1                   GCursor memory block #                       $18
Wt.GOff        RMB       2                   GCursor offset in block                      $19
Wt.MaxX        RMB       2                   Maximum X cord. (0-79,0-639)                 $1B
Wt.MaxY        RMB       2                   Maximum Y cord. (0-24,0-191)                 $1D
Wt.BLen        RMB       2                   bytes left in GPLoad block below             $1F
Wt.NBlk        RMB       1                   memory block # for next GPLoad               $21
Wt.NOff        RMB       2                   Offset in block for next GPLoad              $22
Wt.LStDf       RMB       2                   screen logical start default                 $24
* NOTE: The following default settings are what the window was initialized
*       with, and thus are the MAXIMUM start/size the window can handle
*       until it is restarted (DWEnd & DWSet)
*       They also appear to be used in WindInt to determine the coords &
*       sizes for control+content regions
Wt.DfCPX       RMB       1                   default X cord. start                        $26
Wt.DfCPY       RMB       1                   default Y cord. start                        $27
Wt.DfSZX       RMB       1                   default X size                               $28
Wt.DfSZY       RMB       1                   default Y size                               $29
Wt.Res         RMB       6                   unused                                   $2A-$2F
Wt.Siz         EQU       .+$10

*****************************************************************************
* Screen table entrys
* These tables sit in system block 0 base=$1A80

STblMax        EQU       16                  Maximum number of screen tables
STblBse        EQU       $1A80               base address of screen tables
               ORG       0
St.Sty         RMB       1                   Screen type                         $00
St.SBlk        RMB       1                   Ram block start #                   $01
St.LStrt       RMB       2                   Screen logical start (for GIME)     $02
St.BRow        RMB       1                   Bytes per row                       $04
St.Brdr        RMB       1                   Border palette register #           $05
St.Fore        RMB       1                   Foreground palette register #       $06
St.Back        RMB       1                   Background palette register #       $07
St.ScSiz       RMB       1                   screen size: 24..28 lines           $08
St.Res         RMB       7                   UNUSED???                           $09
* NOTE: SHOULD USE ONE OF THESE UNUSED BYTES TO KEEP THE # OF DEVICE WINDOW
* TABLES THAT ARE USING THIS SCREEN TABLE. DWSET & DWEND WOULD KEEP TRACK OF
* THESE, AND THE WINDINT TITLE BAR ROUTINE WOULD CHECK IT. IF IT IS ONLY 1,
* IT WON'T BOTHER CHANGING THE TITLE BAR WHEN SELECTING WINDOWS
St.Pals        RMB       16                  Palette register contents           $10
St.Siz         EQU       .

*****************************************************************************
* Graphics buffer tables
* They contain a 20 byte header (shown below), followed by the raw pixel
* data.
               ORG       0
Grf.Bck        RMB       1                   back block link #                   $00
Grf.Off        RMB       2                   back block header offset            $01
Grf.Grp        RMB       1                   group #                             $03
Grf.Buff       RMB       1                   buffer #                            $04
Grf.BSz        RMB       2                   buffer size (not including header)  $05
Grf.XSz        RMB       2                   X size (in pixels)                  $07
Grf.YSz        RMB       2                   Y size (in pixels/bytes)            $09
Grf.XBSz       RMB       1                   X size in bytes                     $0B
Grf.LfPx       RMB       1                   # pixels used in first byte of line $0C
Grf.RtPx       RMB       1                   # pixels used in last byte of line  $0D
Grf.STY        RMB       1                   Screen type buffer intended for     $0E
Grf.NBlk       RMB       1                   number blocks used                  $0F
Grf.Pal        RMB       16                  Copy of palette registers?          $10
Grf.Siz        EQU       .                   $20

*****************************************************************************
* GFX tables (1 for each window, 18 ($12) bytes each) pointed to by
* $1075-$0176
* GRFINT only uses gt0001-gt0004, the rest is exclusive to WINDINT
               ORG       0
Gt.WTyp        RMB       1                   WindInt window type (Framed, Scroll Bar, etc.) $00
Gt.GXCur       RMB       2                   X coord of graphics cursor                     $01
Gt.GYCur       RMB       2                   Y coord of graphics cursor                     $03
Gt.DPtr        RMB       2                   Ptr to WindInt window descriptor               $05
Gt.FClr        RMB       1                   Foreground color                               $07
Gt.BClr        RMB       1                   Background color                               $08
Gt.FMsk        RMB       1                   Foreground mask                                $09
Gt.BMsk        RMB       1                   Background mask                                $0A
Gt.GBlk        RMB       1                   Block # of graphics cursor                     $0B
Gt.GOff        RMB       2                   Offset into block of graphics cursor           $0C
Gt.Proc        RMB       1                   Process # of window creator                    $0E
Gt.PBlk        RMB       1                   Process descriptor block # of creator          $0F
Gt.Res         RMB       2                   ??? RESERVED ???                               $10
GTabSz         EQU       .

*****************************************************************************
* This table is located in the graphics table memory and is offset from
* graphics table pointer stored at $1075-$1076. This is used exclusively by
* WindInt.
* NOTE: USING UNUSED BYTES IN CC3 GLOBAL MEM, SET UP SEPARATE PTRS FOR EACH
*  OF THE BELOW SO WE CAN SPEED UP ACCESS BY NOT HAVING TO DO A LOAD/LEAx
*  COMBINATION EVERY TIME
               ORG       $0240
               RMB       WN.SIZ              copy of last accessed window descriptor
               RMB       MN.SIZ              copy of last accessed menu descriptor
               RMB       MI.SIZ              copy of last accessed item descriptor
               RMB       65                  menu handling table (16 entrys of 4 bytes)

*****************************************************************************
* WindInt menu handling table entry definition
               ORG       0
MnuXNum        RMB       1                   menu #
MnuXStrt       RMB       1                   X start text co-ordinate
MnuXEnd        RMB       1                   X end text co-ordinate
               RMB       1                   unused?
MnuHSiz        EQU       .

*****************************************************************************
* Character binary switches
TChr           EQU       %10000000           transparent characters
Under          EQU       %01000000           underline characters
Bold           EQU       %00100000           bold characters
Prop           EQU       %00010000           proportional spacing of characters
Scale          EQU       %00001000           automatic window scaling
Invers         EQU       %00000100           inverse characters
NoCurs         EQU       %00000010           no cursor display
Protect        EQU       %00000001           device window protection

*****************************************************************************
* Screen types (high bit set=hardware text, else graphics) in GRFDRV
Current        EQU       $ff                 Current screen
*         equ   1          640x200x2
*         equ   2          320x200x4
*         equ   3          640x200x4
*         equ   4          320x200x16
*         equ   $85        80 column text
*         equ   $86        40 column text

*************************************
* Window default palette color codes
*
               ORG       0
White.         RMB       1
Blue.          RMB       1
Black.         RMB       1
Green.         RMB       1
Red.           RMB       1
Yellow.        RMB       1
Magenta.       RMB       1
Cyan.          RMB       1

               ENDC      
               ENDC      
