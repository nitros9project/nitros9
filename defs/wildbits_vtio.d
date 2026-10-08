                  IFNE    WILDBITS_VTIO.D-1
WILDBITS_VTIO.D     SET       1

********************************************************************
* vtio definitions for the Wildbits 6809
*
* Everything that the vtio driver needs is defined here, including
* static memory definitions.

* Constant definitions.
KBufSz              EQU       8         the circular buffer size

* Driver static memory.
                    ORG       V.SCF
V.CurRow            RMB       1         current row where the next character goes
V.CurCol            RMB       1         current column where the next character goes
                  IFGT    Level-1
V.CurPos	    RMB	      2		offset position of cursor in textmap
                  ENDC
V.CapsLck           RMB       1         CAPS LOCK key up/down flag ($00 = up)
V.KySns             RMB       1         key sense flags
V.LastCh            RMB       1         Last character for key repeat
V.CurLastCh         RMB       1
V.KRTimer           RMB       1         Key Repeat Timer
V.LEDStates         RMB       1         PS/2 LED flags (bit 2 = CAPS Lock, bit 1 = NUM Lock, bit 0 = Scroll Lock)
                  IFGT    Level-1
V.WriteState        RMB       1         state of write
V.EscCount	    RMB	      1		escape code + paramters captured so far
V.EscNeed	    RMB	      1		escape code characters still needed
                  ENDC
V.EscHandler	    RMB	      2		handler for escape code
V.EscVect           EQU       V.EscHandler        the Level 1 vtio's name for it
V.Reverse           RMB       1         reverse video flag ($00 = off, $FF = on)
V.IBufH             RMB       1         input buffer head pointer
V.IBufT             RMB       1         input buffer tail pointer
V.SSigID            RMB       1         data ready process ID
V.SSigSg            RMB       1         data ready signal code
V.ScTyp             RMB       1         screen type
V.WWidth            RMB       1         window width
V.WHeight           RMB       1         window height
                  IFGT    Level-1
V.ScreenSize	    RMB	      2		Number of bytes to scroll screen
                  ENDC
V.FBCol             RMB       1         currently selected foreground and background color
V.BordCol           RMB       1         currently selected border color
V.KeyDrvMPtr        RMB       2         keydrv module address
V.KeyDrvEPtr        RMB       2         keydrv entry point address
                  IFGT    Level-1
V.MSDrvMPtr         RMB       2         mouse module address
V.MSDrvEPtr         RMB       2         mouse entry point address
V.MouseVect         RMB       2
V.MSButtons         RMB       1         keeps the buttons for the SetStat call
V.MSTimer           RMB       1         this hides the cursor if inactive for more than 4 seconds
V.MEMP              RMB       1         Code to check PS2_STAT for empty buffer (channel 1 or 2)
V.MS_IN             RMB       2         Address of Channel 1 or 2
V.M_WR              RMB       1         PS2 Control Write Channel
V.MCLR              RMB       1         PS2 Clear FIFO Channel 1 or 2
V.INT_PS2_MOUSE     RMB       1         Interrupt Flag for Channel 1 or 2
V.MSByte0           RMB       1         mouse packet byte 1
V.MSByte1           RMB       1         mouse packet byte 2
V.MSByte2           RMB       1         mouse packet byte 3
V.MSByteCnt         RMB       1         mouse packet byte counter
V.TermID            RMB       1
V.TermLive          RMB       1		1=live term,0=shadow term
V.TermBufBlk        RMB       1
                  ENDC
V.KeyDrvStat        equ       .
                    RMB       8

V.EscParms          RMB       20
* DWSet Parameters
V.DWType            set       V.EscParms+0
V.DWStartX          set       V.EscParms+1
V.DWStartY          set       V.EscParms+2
V.DWWidth           set       V.EscParms+3
V.DWHeight          set       V.EscParms+4
V.DWFore            set       V.EscParms+5
V.DWBack            set       V.EscParms+6
V.DWBorder          set       V.EscParms+7



                  IFGT    Level-1


********************************************************************
* vtio graphics definitions - 53 bytes +
********************************************************************

V.ST                RMB       1         screen type 0=Term 1=Gfx

* VICKY MASTER CONTROL REGISTER to enable graphics and capabilities
* | 7 |   6   |    5   |   4  |    3   |   2   |   1   |   0  |
* | X | GAMMA | SPRITE | TILE | BITMAP | GRAPH | OVRLY | TEXT |
* |   -----   | FON_SET|FON_OV| MON_SLP| DBL_Y | DBL_X | CLK70|
* $FFC0 MASTER_CTRL_REG_L, MASTER_CTRL_REG_H
* See constants below for settings used with SS.DSCrn in vtio

V.V_MCR             RMB       2         2 bytes for Vicky Control Register

* VICKY LAYER CONTROL REGISTER to set bitmaps and/or tile maps for display
* | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
* | - |   LAYER1  | - |  LAYER 0  |
* |       ------      |  LAYER 2  |
* 000=BM0 001=BM1 010=BM2 100=TM0 101=TM1 110=TM2
* 011 and 111 = NOTHING: the core's default arm clears both the bitmap and
*   the tile map enable for that layer (TinyVickyCoreModule.v:775-782), so
*   either value blanks a layer.  Undocumented until 2026-09-20 and the only
*   way to hide a bitmap without freeing it.
* $FFC2 VKY_RESERVED_00, VKY_RESERVED_01
* See SS.PScrn in vtio

V.V_LayerCTL        RMB       2
V.BordBack          RMB       12

* $FFCA - "VKY Master Ctrl Reg 2", whose bit 0 is the REAL enable for the
* line drawing engine (VKY_MCR2/VKY_MCR2_LineDraw in wildbits.d; the line
* control register's own bit 0 is dead).  It is the seventh byte of the
* border/background block, which means it is inside the 16-byte
* $FFC0-$FFCF span PullCore copies on every terminal switch - so the
* line-draw enable is per-terminal state that survives a switch already,
* for free, and SS.BmLine only has to set it in the mirror.
* An EQU, not an RMB: it names a byte that is already there.
V.V_MCR2            EQU       V.BordBack+6
* BITMAPS
* Store starting page for bitmaps, and CLUT# and bitmap enable bits.
* Longview with FLASHDIS: SRAM $00_0000-$1F_7FFF (blocks $00-$FB).
* Byte 1 of Bitmap register is CLUT(4 CLUTS:0-3)/Enable
* | 7 | 6 | 5 | 4 | 3 | 2 | 1 |   0    |
* |       -----       |  CLUT | ENABLE |
* Next 3 bytes in register hold the physical bitmap byte address.
* Longview SRAM addresses use 21 bits; allocated bitmap storage must fit RAM.
* Store block# and convert to the physical byte address: block * $2000.

V.BM0Cl_En          RMB       1         bitmap0 |clut|enable|
V.BM0Blk            RMB       1         bitmap0 block
V.BM1Cl_En          RMB       1         bitmap1 |clut|enable|
V.BM1Blk            RMB       1         bitmap1 block
V.BM2Cl_En          RMB       1         bitmap2 |clut|enable|
V.BM2Blk            RMB       1         bitmap2 block

* One byte recording, per bitmap, HOW BIG it is and WHO OWNS it.
*
* The size half fixes a real defect.  SS.AScrn chose 10 blocks or 8 from
* the CALLER'S screen type while SS.FScrn chose it from the CURRENT
* display mode's CLK_70 bit - two sources of truth for one number.  A
* program that changed the display mode between allocating and freeing
* therefore freed the wrong count: too few leaked, and too many handed
* live blocks back to the free pool while their real owner was still
* using them.  src/gfx.a and jstview/jstview.asm both carry the same
* compensating comment and deliberately free their bitmaps BEFORE
* restoring the display mode.  Recording the count removes the need.
*
* The ownership half tells a bitmap the driver allocated (SS.BmAlloc, and
* SS.AScrn through it) from one a program merely pointed at its own blocks
* with SS.BmDef.  Whoever allocated, frees: SS.BmKill and a terminal close
* free the driver's blocks and never touch the program's.
*
* It sits inside the span GF.TermNew wipes (V.BM0Cl_En..V.GCX), so a new
* terminal starts with every bitmap unowned and 10-block by default.
V.BMFlags           RMB       1         bits 0-2 size, bits 4-6 ownership

* The offset within V.BMxBlk at which each bitmap starts, 0-$1FFF.
*
* V.BMxBlk alone could only ever name a block BOUNDARY, which made the
* bitmap the one asset whose address the API could not express the way
* the tile calls already do - SS.TsSet and SS.TmSet have taken a block
* AND an offset since the tile rework, and SS.BmDef now matches them.
* That is what lets a program make one allocation for a slew of assets
* and lay them out inside it, instead of having to spend a whole block
* boundary on every one.
*
* V.BMxBlk keeps its name and meaning rather than being widened to a
* 24-bit address, because level1/wildbits/modules/vtio.asm still refers
* to it and nothing is gained by breaking a file the L1 recipe can find.
* The pair is turned into the register's 24-bit address by BmRegAddr,
* which is the only place that arithmetic happens.
V.BM0Off            RMB       2         offset within V.BM0Blk
V.BM1Off            RMB       2
V.BM2Off            RMB       2

BM.Small            equ       %00000001 bitmap 0's "8 blocks, not 10" bit
BM.Owned            equ       %00010000 bitmap 0's "the driver allocated it" bit
BmBlk240            equ       10        blocks in a 320x240 bitmap (76,800 bytes)
BmBlk200            equ       8         blocks in a 320x200 bitmap (64,000 bytes)

* The bytes a bitmap can DISPLAY, which is what SS.BmClear fills.
* Deliberately neither the allocation (BmBlk240*8192 = 81,920) nor what
* the current video mode happens to fetch.  Filling the allocation would
* wipe the slack that a program laying a slew of assets into one
* SS.GfxAlloc slab may have put the next asset in; filling what the mode
* fetches would make the result depend on a mode that may legally change
* afterwards, which is the two-sources-of-truth shape of the defect
* SS.FScrn used to have.  A 640x240 4bpp bitmap is the same 76,800 bytes.
BmPixels            equ       320*240


* CLUT - need to store mirror of CLUT data so switching windows will work
* Store block# where high 4k is CLUT mirror.  Could store in last 4k of BM blocks.

V.CLUTBlk           RMB       1         block where high 4k mirrored CLUT data,0=Default CLUT
V.CLUT              RMB       1         which CLUTs are active 00001111

* TILE MAPS - 3 tile maps.  Registers are 12 bytes, 2 are reserved and
* 3 are the plysical address for the Tile Set.  Use Blk# for address here.
* So only need 8 bytes per tile map.  In the Map each tile is 2 bytes
* byte0=Tile number, byte1=CLUT+Tile Set. So relationship between Tile Map
* and Tile Set is set in the actual tile map data, not here.
* A tile map could be 2.4K (40x30) to 132K (256x256).  The size fields
* are 10 bits wide in the core (TinyVicky_TL_Registers.v), not 8, so a
* map may be up to 1024 tiles on a side; the RSRV/RESRV bytes beside
* MapX/MapY are the high halves, not padding.

V.TM0               RMB       1         bit4 is yile size (1=8x8,0=16x16) bit0 is enable
V.TM0AddrH          RMB       1
V.TM0AddrM          RMB       1
V.TM0AddrL          RMB       1
V.TM0MapX           RMB       1         map size X low byte (the field is 10-bit: max 1024)
V.TM0RSRV1          RMB       1
V.TM0MapY           RMB       1         map size Y low byte (10-bit: max 1024)
V.TM0RESRV2         RMB       1
V.TM0ScrlX          RMB       2         2 bytes for scroll X info
V.TM0ScrlY          RMB       2         2 bytes for scroll Y info

V.TM1               RMB       1         bit4 is yile size (1=8x8,0=16x16) bit0 is enable
V.TM1AddrH          RMB       1
V.TM1AddrM          RMB       1
V.TM1AddrL          RMB       1
V.TM1MapX           RMB       1         map size X low byte (10-bit: max 1024)
V.TM1RSRV1          RMB       1
V.TM1MapY           RMB       1         map size Y low byte (10-bit: max 1024)
V.TM1RESRV2         RMB       1
V.TM1ScrlX          RMB       2         2 bytes for scroll X info
V.TM1ScrlY          RMB       2         2 bytes for scroll Y info

V.TM2               RMB       1         bit4 is yile size (1=8x8,0=16x16) bit0 is enable
V.TM2AddrH          RMB       1
V.TM2AddrM          RMB       1
V.TM2AddrL          RMB       1
V.TM2MapX           RMB       1         map size X low byte (10-bit: max 1024)
V.TM2RSRV1          RMB       1
V.TM2MapY           RMB       1         map size Y low byte (10-bit: max 1024)
V.TM2RESRV2         RMB       1
V.TM2ScrlX          RMB       2         2 bytes for scroll X info
V.TM2ScrlY          RMB       2         2 bytes for scroll Y info

* V.TM0Blk-V.TM2Blk were here: the map's first block, computed and stored
* by SSTmSet and read by NOTHING.  Deleted 2026-09-20.  Unlike a bitmap,
* whose register takes a block and whose mirror is the only record of it,
* a tile map register holds the whole address, so the block is derivable
* and was never needed.  11 bytes back into the 250-byte DSS budget.
* TILE SETS - there are 8 tile sets.  Tile Set registers contain a physical address, and
* a Square bit to determine if Tile Set is LINEAR or SQUARE
* Tile Sets are either 16K (8x8) or 64K (16x16)


V.TS0AddrH          RMB       1
V.TS0AddrM          RMB       1
V.TS0AddrL          RMB       1
V.TS0SQR            RMB       1         square or linear (bit 3)

V.TS1AddrH          RMB       1
V.TS1AddrM          RMB       1
V.TS1AddrL          RMB       1
V.TS1SQR            RMB       1         square or linear (bit 3)

V.TS2AddrH          RMB       1
V.TS2AddrM          RMB       1
V.TS2AddrL          RMB       1
V.TS2SQR            RMB       1         square or linear (bit 3)

V.TS3AddrH          RMB       1
V.TS3AddrM          RMB       1
V.TS3AddrL          RMB       1
V.TS3SQR            RMB       1         square or linear (bit 3)

V.TS4AddrH          RMB       1
V.TS4AddrM          RMB       1
V.TS4AddrL          RMB       1
V.TS4SQR            RMB       1         square or linear (bit 3)

V.TS5AddrH          RMB       1
V.TS5AddrM          RMB       1
V.TS5AddrL          RMB       1
V.TS5SQR            RMB       1         square or linear (bit 3)

V.TS6AddrH          RMB       1
V.TS6AddrM          RMB       1
V.TS6AddrL          RMB       1
V.TS6SQR            RMB       1         square or linear (bit 3)

V.TS7AddrH          RMB       1
V.TS7AddrM          RMB       1
V.TS7AddrL          RMB       1
V.TS7SQR            RMB       1         square or linear (bit 3)


* V.TS0Blk-V.TS7Blk were here, and went the same way.
* GRAPHICS CURSORS,LINES, COLORS
V.GCX               RMB       2         graphics cursor X
V.GCY               RMB       1         graphics cursor Y
V.GCOLOR            RMB       1         graphics color
V.LX                RMB       2         line coordiate for X
V.LY                RMB       1         line coordinate for Y
V.GCADDR            RMB       3         address of cursor on screen
V.GCAD8K            RMB       2         address in 8K window
V.GMAPBLK           RMB       2         mapped in logical address of block
		  ELSE
* L1 vtio needs this		  
V.MapSav            RMB       1                   saved MMU map-window slot value (vtio: no stack use inside a mapped window)		  
                  ENDC

V.InBuf             RMB       KBufSz    the input buffer
V.KSBuf             RMB       KBufSz
* SS.WSig ($E1): who to signal when this terminal's visibility changes.
* Kept here, not in a shadow block, because vtio reads it - see the design
* note in docs/grfdrv256-api.md.  A code of 0 means "do not signal that
* transition"; an id of 0 means nobody is registered.
                  IFGT    Level-1
V.WSigID            RMB       1         registrant's process ID, 0 = none
V.WSigBg            RMB       1         signal code for going background
V.WSigFg            RMB       1         signal code for coming forward
                  ENDC
* grfdrv256 SetBlkC2C3 maps the DSS through ONE MMU slot (slot 5).
* Safe only while the whole area fits a single 256-byte page: F$SRqMem
* hands out page-aligned pages and 256 divides 8192, so <=256 bytes
* can never span two 8K blocks.  Past a page, slot 5 must become a
* 2-slot window.
                    ifgt      .-256
                    error     vtio device static > 256 bytes - fix grfdrv256 DSS mapping
                    endc

                    RMB       250-.
V.Last              EQU       .

* Borrow DP after D.IRQTmp; stays below $20 so it does not hit Level 2 D.Tasks.
                    org       D.IRQTmp
D.Bell              rmb       2
D.TnCnt             rmb       1
D.OrgAlt            rmb       2
D.SndPrcID          rmb       1
D.KySns             rmb       1
                  IFGT    Level-1
* 2-byte pointer to the active vtio static. Do not alias 1-byte D.Boot.
* Placed after D.IRQTmp so it stays below $20 (Level 2 D.Tasks).
* Level 1 already has D.KbdSta at $6D in os9.d.
D.KbdSta            rmb       2
                  ENDC

* K-specific section
* Borrow 9 bytes from "CoCo" specific area of system globals for platform use.
                    org       D.WDAddr
D.RowState          RMB       9
D.WBKKyDn           RMB       1

*******************************************************************
* F256 Graphics Driver Global Memory
*
* This is SHARED between system and grfdrv (lives in Block 0)
*******************************************************************

GrfMem              equ       $1100     ; GrfDrv data area (256 bytes)
F256Gfx             equ       $1200     ; F256-specific graphics data (256 bytes)
*******************************************************************
* The sprite registration page.
*
* A program that draws sprites keeps the ONLY copy of its 8-byte
* records and registers where it is (SS.SprReg); the driver keeps no
* copy at all.  A terminal switch copies straight out of the program's
* memory, so what is on screen is always what some terminal's
* registered table says.  See docs/sprite-registration-plan.md in the
* joust tree.
*
* It lives here, in the driver's globals, rather than in a terminal's
* device static storage because a switch needs the INCOMING terminal's
* registration BEFORE it has mapped anything of that terminal's.  Rows
* are 8 bytes so the index gr.TermTbl already computes (id * 8)
* addresses this table too.
*
* The blocks are the program's own.  The row therefore dies with the
* terminal (GF.TermGone) and a program deregisters before it frees or
* reuses the memory; a stale row would put a stranger's memory on
* screen as sprite records.
*******************************************************************
                    org       F256Gfx
gr.SprTbl           rmb       G.TermMax*8   ; one row per terminal, below
gr.SprDirty         rmb       1         ; 0 = every sprite control byte is known clear
* Row layout (org 0, like the terminal table's T.*)
                    org       0
SB.Flags            rmb       1         ; SB.Reg, SB.Span
SB.Blk0             rmb       1         ; block holding the start of the table
SB.Blk1             rmb       1         ; the next block, when the table crosses into it
SB.Off              rmb       2         ; offset WITHIN SB.Blk0, $0000-$1FFF - not a logical address
SB.Cnt              rmb       1         ; records 1-128; the table is records 0 to SB.Cnt-1
                    rmb       2         ; spare, keeps the row at 8
SB.Size             equ       8

SB.Reg              equ       %00000001 ; this terminal has registered a table
SB.Span             equ       %00000010 ; it crosses into SB.Blk1
SPR.Max             equ       128       ; hardware sprite records
SPR.RecL            equ       8         ; bytes each
GrfMod              equ       $C000     ; Logical location of module in task 1

*******************************************************************
* GrfMem Offsets - Corrected for 8-byte DAT
*******************************************************************
                    org       $1100
gr.DATImg           RMB       16        ; GrfDrv DAT image (16 BYTES)
gr.Stack            RMB       2         ; GrfDrv Stack pointer (2 bytes)
gr.SysStk           RMB       2         ; Saved System Stack (during flip)
gr.Entry            RMB       2         ; GrfDrv entry point (2 bytes)
gr.WriteCharLive    RMB	      2		; WriteCharLive entry point (2 bytes)
gr.WriteCharShadow  RMB	      2		; WriteCharShadow entry point (2 bytes)
gr.ScrollLive	    RMB	      2		; ScrollLive entry point (2 bytes)
gr.ScrollShadow	    RMB	      2		; ScrollShadow entry point (2 bytes)
gr.Busy             RMB       1         ; Busy flag (1 byte)
gr.CurScr           RMB       1         ; Current screen (1 byte)
gr.Error            RMB       1         ; Error code (1 byte)
gr.Flags            RMB       1         ; Flags (1 byte)
gr.Temp             RMB       1         ; Temp Variable
gr.RGSADR           RMB       2         ; Address of PD.RGS
gr.PDRGS            RMB       R$Size    ; GrfDrv copy of PD.RGS
gr.PDAT             RMB       16
gr.PTask            RMB       1         ; Virtual Task Number
gr.FirstInitDone    RMB       1         ; Keyboard Init
gr.TermCnt          RMB       1         ; number of open terminals
gr.TermBlk          RMB       1         ; Current Terminal Block for Buffer Operations
gr.VStaStorU        rmb       2         ; Static Storage
gr.VBlk             rmb       1         ; block # containing static storage
gr.U5		    rmb	      2		; Static storage in grfdrv for slot 5
gr.SwitchTerm	    rmb	      1		; target terminal id for SW.Goto (1B 21)
gr.SwitchReq	    rmb	      1
SW.None		    equ	      $00
SW.Prev		    equ	      $FF
SW.Next		    equ	      $01
SW.Goto		    equ	      $02       ; switch to the id in gr.SwitchTerm
* Screen table (9 screens × 4 bytes = 36 bytes)
gr.LiveTerm         rmb       1         ; this is the active terminal
gr.TermSz           equ       8         ; Size per entry (8 bytes to make idx math easier)
gr.TermTbl          RMB       72        ; Screen table base
KeyLiveSz           equ       6         ; slots in gr.KeyLive (SS.LiveKeys returns R$X/R$Y/R$U)
gr.KeyLive          RMB       KeyLiveSz ; unshifted codes of the ordinary keys held down; 0 = empty
* SS.WSig staging.  grfdrv256 makes no OS-9 calls at all, so the switch
* records who to tell here and vtio's AltISR does the F$Send - the same
* AltISR that already sends S$Wake for sound.  Process id 0 = nothing
* pending.  Two slots because one switch is both a background and a
* foreground event, for two different processes.
gr.SigBgID          rmb       1         ; process whose terminal just went background
gr.SigBgCode        rmb       1         ; the signal code it registered
gr.SigFgID          rmb       1         ; process whose terminal just came forward
gr.SigFgCode        rmb       1         ; the signal code it registered
*******************************************************************
* GrfDrv parameter registers.
*
* vtio reaches grfdrv through a register-bank flip (CallGrfDrv2 ->
* jmp [D.Flip1]) and so cannot pass arguments in CPU registers.  It
* snapshots them into this block first, in the system task, before
* Flip1.  Do not index U after LUT 1 has stolen slots.
*
* Named by size and number, not by meaning: bN = 1 byte, dN = 2 bytes
* ("double").  Each register carries something different per GF.* op,
* so a descriptive name would be a lie at most call sites.  This table
* is the ABI; every store/load site also names its value inline.
*
*   op                   b2          b3           b4     b5     d1         d2
*   -------------------- ----------- ------------ ------ ------ ---------- ---------
*   GF.PSGBell  (14)     -           volume 0-15  -      -      frequency  -
*   GF.Cell     (16)     glyph       colour attr  dest   -      cell off   -
*   GF.Blank    (18)     fill glyph  fill colour  -      -      -          -
*   GF.Pal      (19)     pal reg #   -            dest   0=FG   LUT byte   LUT byte
*                                                        1=BG   0-1 (B,G)  2-3 (R,A)
*   GF.BmEnable (20)     bitmap #    ctrl byte    -      -      phys addr  -
*   GF.BmFree   (21)     bitmap #    -            -      -      -          -
*   GF.BmPalet  (22)     bitmap #    CLUT#|enable -      -      -          -
*   ScrollLive/Shadow    -           -            -      -      start off  end off
*     (direct calls, A = width; start = CurRow*WWidth or 0, end = V.ScreenSize)
*
* b1 is GF.TermNew's and GF.TermGone's terminal id, and GF.GetStt/GF.SetStt's
*   status code.  d1 is GF.TermNew's and GF.TermGone's device static (its
*   system address).  (It was the GF.Write sub-op selector before that layer went.)
* b4 "dest" is set by vtio's SetWDest: WD.Buf = the 16K terminal backup
*   buffer at LUT1 $6000, WD.Vicky = the live $C2/$C3 planes.
* d1/d2 halves are addressed gr.d1 / gr.d1+1 the way D splits into A/B.
* WriteCharLive/Shadow bypass this block entirely - A/B/Y only.
*   ScrollLive/Shadow take width in A but start/end in d1/d2.
*
* HAZARD: GF.ClrScrn (17) and the erase family (GF.EraseLine 10 /
*   GF.ErEOLine 11 / GF.ErEOScrn 12) take no parameters here, but both
*   CLOBBER b3 - they spill V.FBCol into it because U gets reused as the
*   colour-plane pointer.  Nothing may hold a live b3 across those calls.
*
* The physical order below (b1 b2 d1 d2 b3 b4 b5) is historical, not
* meaningful; it is kept so GrfMem offsets did not move in the rename.
*******************************************************************
gr.b1               rmb       1         ; GF.TermNew, GF.TermGone: terminal id / GF.GetStt, GF.SetStt: status code
gr.b2               rmb       1         ; glyph / palette reg # / bitmap #
gr.d1               rmb       2         ; cell offset / PSG freq / BM addr / LUT b0-1 / GF.TermNew, GF.TermGone: static
gr.d2               rmb       2         ; GF.Pal LUT bytes 2-3 / scroll end offset
gr.b3               rmb       1         ; colour attr / PSG volume / BM ctrl byte
gr.b4               rmb       1         ; WD.Buf (16K backup) / WD.Vicky ($C2/$C3)
gr.b5               rmb       1         ; GF.Pal 0=FG 1=BG LUT select
                    org       0
T.Flags             rmb       1         ; Acrive Flag - only one screen should be active
T.Block             rmb       1
T.StatPtr           rmb       2         ; Pointer to Static Vars (V. vars ) for screen
T.VBlk		    rmb	      1		; block containing static vars
T.grU5		    rmb	      2         ; U in grfdrv if in mmu slot 5
T.Unused	    rmb	      1		; Unused
* Term table row is 8 bytes to make the math easier for indexing.
* can use lsr to compute index instead of multiplying by 5
* Plus we have 1 unused byte for future use without breaking anything else
* Note:  Driver Static Storage will never span 2 blocks because of 256 byte pages
* Driver Static Storage will always be 256 bytes on a 256 byte boundary

T.Init              equ       %00000001 ; Terminal is initialized/open
T.Live              equ       %00000010 ; Terminal is currently active (optional redundancy


* Rest available for F256-specific data
gr.UserData         equ       $60       ; User area (~160 bytes to $FF

E$Param             equ       $05

*******************************************************************
* Terminal Management Constants
*******************************************************************
G.TermMax           equ       9         ; Maximum terminals (0-8)

*******************************************************************
* GrfDrv Function Codes
* These are sequential indexes; CallGrfDrv does ASLB before dispatch.
*******************************************************************
GF.Init             equ       0         ; Initialize
GF.Term             equ       1         ; Terminate
* 2 was GF.GSMouse, 3 GF.GSDScrn, 6 GF.SSDScrn: never called, and the first
* two read Vicky back.  SS.Mouse and SS.DScrn go through GF.GetStt/GF.SetStt;
* the three FuncTbl slots return E$UnkSvc so the numbering holds.
GF.GSFntChar        equ       4         ; GetStat font char
* 5 was GF.SSFntLoadF - load a font from a file inside grfdrv.  Deleted: it
* was never reachable (vtio's SSFntLoadF does the whole job itself and never
* dispatched here), and the body was already dead-ended by a 'bra errorclose@'
* placed before its I$Open.  grfdrv cannot do file I/O anyway - it is entered
* through a register-bank flip onto one shared D.CCStk with gr.Stack holding a
* single caller's S, and nothing gates the foreground path, so a blocking read
* would let a second entrant overwrite the sleeper rather than serialise.
* Ops above it renumbered down one.
GF.SSFntChar        equ       5         ; SetStat font char
GF.PushBuf          equ       7         ; Push Vicky state to term buffer
GF.PullBuf          equ       8         ; Pull term buffer to Vicky
GF.EraseLine	    equ	      9
GF.ErEOLine	    equ	      10
GF.ErEOScrn         equ       11        ; Erase End of Screen
GF.PSGInit	    equ	      12
GF.PSGBell	    equ	      13
GF.PSGOff	    equ	      14
GF.Cell             equ       15        ; one cell: b2 glyph, b3 colour, d1 offset
GF.ClrScrn          equ       16        ; clear whole screen (dims read from DSS)
GF.Blank            equ       17        ; blank the 16K term buffer
* 18 was GF.InitDisp - gamma ramp, font + text-LUT install, $C2/$C3 fill.
* Deleted: the FPGA (and MAME's device_reset) preload the font and the text
* palettes, vtio never sets Mstr_Ctrl_GAMMA_En so the gamma LUT is unused,
* and the $C2/$C3 fill is GF.ClrScrn's job.  Its vtio caller InitDisplayMem
* was already gone.  Ops above it renumbered down one.
GF.Pal              equ       18        ; one text-LUT entry (1B 60 / 1B 61)
GF.BmEnable         equ       19        ; bitmap: enable + phys addr
GF.BmFree           equ       20        ; bitmap: zero the four registers
GF.BmPalet          equ       21        ; bitmap: assign CLUT
GF.InsLine          equ       22        ; 1F 30 insert line at V.CurRow (reads DSS)
GF.Switch           equ       23        ; change live terminal per gr.SwitchReq (AltISR)
GF.TermGone         equ       24        ; terminal id gr.b1, static gr.d1, is closing (vtio TermTerm)
GF.DfPal            equ       25        ; SS.DfPal: 1K at caller R$Y -> CLUT R$X (buffer + live)
GF.AScrn            equ       26        ; SS.AScrn: allocate bitmap R$Y, block back in R$X
GF.GetStt           equ       27        ; GetStat codes vtio does not keep: code in gr.b1, results in gr.PDRGS
GF.SetStt           equ       28        ; SetStat codes vtio does not keep: code in gr.b1
GF.InitDisp         equ       29        ; first terminal: seed + program the $FFC0-$FFCF mirror, cursor (not old 18)
GF.TermNew          equ       30        ; set up terminal id gr.b1 for static gr.d1 (vtio InitTerm)
WD.Buf              equ       0         ; 16K TermBlk at LUT1 $6000
WD.Vicky            equ       1         ; live $C2/$C3 at LUT1 $2000/$4000

*******************************************************************
* 16K termainal storage for switching screens = excactly 16384
*
* Beyond the character and colour planes, a terminal switch can also
* carry four regions of Vicky memory.  Each is gated separately so they
* can be brought back ONE AT A TIME on real hardware: saving them means
* READING Vicky back, and with all four on, the first Alt-arrow switch
* blacked the screen and never recovered (coming back restores the other
* terminal's equally-garbage capture).  MAME models all of it as plain
* RAM, so it cannot tell us which one - only the board can.
*
* Addresses verified against the F256 Revision E map, 2026-03-13.
*
*   switch            region                    Vicky        bytes
*   ----------------- ------------------------- ------------ -----
*   TermSaveFont0     font memory bank 0        $C1+$0000     2048
*   TermSaveTextLUT   text LUT foreground+bg    $C0+$1700      128
*   TermSaveCLUT      graphics LUT0-3           $C1+$1000     4096
*
* Sprite records are NOT in this list any more.  They are not shadowed
* and never read back: PullBuf fills $C0+$1300 from the incoming
* terminal's own registered table (gr.SprTbl) and clears the records that
* table does not cover, and PushBuf does nothing with sprites at all.
*
* Each byte here costs twice per switch: GF.Switch runs PushBuf on the
* terminal it leaves and PullBuf on the one it enters.  All four on is
* 6784 bytes per routine, 13568 per switch, against 9600/19200 for the
* two planes that are always carried.
*
* Whatever stays off is global, shared by every terminal.
*
* A region that does not read back can still be made per-terminal: only
* the CAPTURE is broken, writing is fine.  So PushBuf skips it while
* PullBuf still programs it, and the buffer copy becomes a write-only
* mirror that vtio maintains - exactly what was done for the
* $FFC0-$FFCF registers.  For the text LUT that is nearly in place
* already: GFPal writes T.FLUT/T.BLUT for a shadow terminal.  What is
* missing is writing the buffer copy for a LIVE terminal too (it
* currently writes hardware or buffer, not both) and seeding T.FLUT/
* T.BLUT for a new terminal.  That, not TermSaveTextLUT, is how 1B 60 /
* 1B 61 per-terminal palettes come back.
*******************************************************************
* Bisected on real hardware, one region per build.  Settled:
*
*   Font0    WORKS   - font memory bank 0 reads back.  Three terminals with
*                      independent fonts and colours switch cleanly.
*   TextLUT  BROKEN  - the text LUT does NOT read back on the current FPGA.
*                      This is the one that blacked the screen: PushBuf
*                      captured a dead palette and PullBuf programmed it,
*                      black on black, in BOTH directions - which is why
*                      Alt-arrow could never recover.  128 bytes, and it cost
*                      the whole investigation.
*   Sprite0  WORKS   - no breakage in text mode (see the caveat below).
*   CLUT     WORKS   - likewise.
*
* CAVEAT on the last two: sprite records only matter with sprites enabled and
* the graphics CLUTs only in bitmap/tile mode, so a clean console switch shows
* they do not BREAK anything, not that they read back correctly.  Confirming
* those needs a graphics test rather than a console one.
*
* TermSaveTextLUT: a future FPGA release will support reading the text LUT, at
* which point setting this to 1 works - but only on that FPGA and later.  The
* mirror approach described below works on every version, so prefer it unless
* you control which bitstream the board is running.
*
* THAT RELEASE HAS LANDED (noted 2026-09-20, read from the RTL, NOT TESTED).
* TinyVKY2K2_IO_Page0_Devices.v carries "wb 2026-09-08: text FG/BG LUT
* read-back (shadow copies)": the core keeps TEXT_FG_Shadow / TEXT_BG_Shadow
* and returns them for $18_1700-$18_177F.  So this CAN go to 1 now, subject
* to which bitstream is actually flashed - the same open question as the DMA
* halt.  LEFT AT 0 DELIBERATELY: flipping it is a behaviour change to the
* terminal switch path and wants a hardware run of its own.  See the open
* item in docs/status.md.
TermSaveFont0       equ       1         font bank 0     - CONFIRMED works
TermSaveTextLUT     equ       0         text LUT fg/bg  - BROKEN before the FPGA fix
* TermSaveSprite0 is gone with T.SPRITE0: PushBuf no longer reads the
* sprite registers back, and PullBuf fills them from the incoming
* terminal's registered table.
TermSaveCLUT        equ       1         graphics LUT0-3 - CONFIRMED, text mode
* PullBuf's graphics-CLUT restore, split out from PushBuf's capture so the
* two can disagree.  They only need to disagree if the board says the
* graphics CLUTs are write-only, and the test for that is now runnable:
* see "Bitmaps" in docs/wildbits-vtio-rewrite.md.  Setting
*   TermSaveCLUT 0 / TermRestCLUT 1
* makes T.CLUT0-3 a pure write-only mirror - SS.DfPal writes both the
* buffer copy and the live CLUT, PushBuf never reads Vicky back, PullBuf
* programs the hardware from the buffer.  The cost of that setting is
* that fadein/fadeout map $C1 into their own process and write the CLUT
* behind the driver's back, so their fades would become global rather
* than per terminal until they are moved onto SS.DfPal.
TermRestCLUT        equ       1         PullBuf restores graphics LUT0-3
                    org       0
T.TXT               rmb       4800      ; 80x60 text screen
T.TXTCOLOR          rmb       4800      ; 80x60 color matrix
T.FLUT              rmb       64        ; foreground LUT
T.BLUT              rmb       64        ; background LUT
* T.SPRITE0 (512 bytes) was here.  Sprite records are no longer shadowed
* per terminal: the program owns the only copy and registers it
* (gr.SprTbl above).  The 512 bytes are free at the end of the buffer.
T.FONT0             rmb       2048
T.CLUT0             rmb       1024      ; CLUT 0 Copy
T.CLUT1             rmb       1024      ; CLUT 1 Copy
T.CLUT2             rmb       1024      ; CLUT 2 Copy
T.CLUT3             rmb       1024      ; CLUT 3 Copy

* SS.KySns bit locations
SHIFTBIT            equ       %00000001
CTRLBIT             equ       %00000010
ALTBIT              equ       %00000100
UPBIT               equ       %00001000
DOWNBIT             equ       %00010000
LEFTBIT             equ       %00100000
RIGHTBIT            equ       %01000000
SPACEBIT            equ       %10000000
KEYDELAY            equ       5
KEYDELAY1           equ       30

                  ENDC
