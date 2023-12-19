*******************************************************************
* CoGrf/CoWin - NitrOS-9 Text/Graphics Window Module
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  19r0    2003/09/23  Robert Gault
* Many new patches for 6809 code use.
*
*  19r1    2003/11/14  Robert Gault
* Patches to scrollbar windows to recover arrows and markers.
* Includes new stdfonts with graphics added to the end.
*
*  1       2005/11/26  Boisy G. Pitre
* Renamed from WindInt/GrfInt, reset edition.
*
*          2006/01/09  Robert Gault
* Changed Select window routine so that it will work within a script and
* DWSet routine so that it will not require a [CLEAR] if the active window
* is killed with a display 1b 24 and restarted with a display 1b 20; ie
* DWSet. Changes are compatible with MultiVue and all test procedures
* tried. Short Sleep added to stabilize the screen change.
*
*  2       2007/08/22  Boisy G. Pitre
* Fixed crash bug in case where grfdrv wasn't loaded.  See comments at
* Term label.
*  EOU Beta 2
*  3       2018/11/13  Bill Nobel
* Change code (along with Grfdrv) so that loading Grfdrv takes place outside
*   of the 64K System workspace, which allows >8K grfdrv to boot properly on
*   systems with <16k free in the system memory map.
*  EOU Beta 3
*           2018/12/14  Bill Nobel
* Removed Robert Gault's modifications to Select (caused any Select call, even on windows
*  not currently viewed on screen, to take over the screen).
*  Bill Nobel & Robert Gault confirmed that fixes Select bug.
* EOU Beta 5 - minor optimizations. 6809 DefColr shrunk & sped up.
*           2019/06/24  L. Curtis Boyle
* Various gr00B5 (W copies) stores removed that are never used
* Sped up copying of ARC clip coords by 50 cycles on 6809 (around L0A2Db)/same size
* Curtis planning on adding vectors for block copies and block clears (see level 1 CoVDG),
*   16 bit scratch var in static mem (can't use Grfdrv global, since IRQ's can switch between
* CoWin/Grf devices) (to use DP addressing instead of pshs (8 or 16 bit)
*   /puls to speed various routines up a little bit, like font expansion.
*   Eventually, Krn module will get the mini stack blast copy/clear routines
*   and set up the vectors to call them in direct page, so that all of the system process
*   can access them easily. Grfdrv, since it gets it's own 64k map, will have it's own
*   copies and vectors.

                    nam       CoGrf/CoWin
                    ttl       NitrOS-9 Window Module

                    ifp1
                    use       defsfile
                    use       cocovtio.d
                    endc

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             equ       2

* Color table for 3D look stuff & others
* This should now match VIEW's color table (darkest to lightest for predictable
* brightness). Any color scheme following that rule shouldn't look bad.
WColor0             equ       0                   black (Darkest)
WColor1             equ       1                   dark grey (Dark)
WColor2             equ       2                   light grey (Light)
WColor3             equ       3                   (white) (Lightest)

                    mod       eom,name,tylg,atrv,entry,size
size                equ       .

name                equ       *
                    IFEQ      CoGrf-1
                    fcs       /CoGrf/
                    ELSE
                    fcs       /CoWin/
                    ENDC
                    fcb       edition

****************************
* Escape code parameter vector table
* Format: Byte 1  : Length of parameters required (in bytes)
*         Byte 2  : Internal function code for GrfDrv
*         Byte 3-4: Vector offset of routine from Byte 1

L0027               fcb       7,$04               DWSet
                    fdb       DWSet-*+2
                    fcb       0,$10               Select
                    fdb       Select-*+2
                    fcb       7,$0A               OWSet
                    fdb       OWSet-*+2
                    fcb       0,$0C               OWEnd
                    fdb       OWEnd-*+2
                    fcb       0,$08               DWEnd
                    fdb       DWEnd-*+2
                    fcb       4,$0E               CWArea
                    fdb       CWArea-*+2
                    fcb       $ff,$00             Blank (free for new function)
                    fdb       $0000
                    fcb       $ff,$00             Blank (free for new function)
                    fdb       $0000
                    fcb       $ff,$00             Blank (free for new function)
                    fdb       $0000
                    fcb       4,$2C               DefGPB
                    fdb       DefGPB-*+2
                    fcb       2,$2E               KillBuf
                    fdb       KillBuf-*+2
                    fcb       9,$30               GPLoad
                    fdb       GPLoad-*+2
                    fcb       10,$34              GetBlk
                    fdb       GetBlk-*+2
                    fcb       6,$36               PutBlk
                    fdb       PutBlk-*+2
                    fcb       2,$12               PSet
                    fdb       PSet-*+2
                    fcb       1,$1E               LSet
                    fdb       LSet-*+2
                    fcb       0,$1C               DefPal
                    fdb       DefPal-*+2
                    fcb       2,$16               Palette
                    fdb       Palette-*+2
                    fcb       1,$20               FColor
                    fdb       FColor-*+2
                    fcb       1,$22               BColor
                    fdb       BColor-*+2
                    fcb       1,$14               Border
                    fdb       Border-*+2
                    fcb       1,$28               ScaleSw
                    fdb       ScaleSw-*+2
                    fcb       1,$06               DWProtSw
                    fdb       DWProtSw-*+2
                    fcb       $ff,$00             Blank (free for new function)
                    fdb       $0000
                    fcb       $ff,$00             Blank (free for new function)
                    fdb       $0000
                    fcb       2,$1A               GCSet
                    fdb       L060C-*+2
                    fcb       2,$18               Font
                    fdb       Font-*+2
                    fcb       $ff,$00             Blank (free for new function)
                    fdb       $0000
                    fcb       1,$24               TCharSw
                    fdb       TCharSw-*+2
                    fcb       1,$2A               Bold
                    fdb       BoldSw-*+2
                    fcb       $ff,$00             Blank (free for new function)
                    fdb       $0000
                    fcb       1,$26               PropSw
                    fdb       PropSw-*+2
                    fcb       4,$00               SetDP
                    fdb       SetDPtr-*+2
                    fcb       4,$00               RSetDPtr
                    fdb       RSetDPtr-*+2
                    fcb       4,$48               Point
                    fdb       Point-*+2
                    fcb       4,$48               RPoint
                    fdb       RPoint-*+2
                    fcb       4,$4A               Line
                    fdb       Line-*+2
                    fcb       4,$4A               RLine
                    fdb       RLine-*+2
                    fcb       4,$4A               LineM
                    fdb       LineM-*+2
                    fcb       4,$4A               RLineM
                    fdb       RLineM-*+2
                    fcb       4,$4C               Box
                    fdb       Box-*+2
                    fcb       4,$4C               RBox
                    fdb       RBox-*+2
                    fcb       4,$4E               Bar
                    fdb       Bar-*+2
                    fcb       4,$4E               RBar
                    fdb       RBar-*+2
                    fcb       $ff,$00             Blank
                    fdb       $0000
                    fcb       $ff,$00             Blank
                    fdb       $0000
                    fcb       4,$44               PutGC
                    fdb       PutGC-*+2
                    fcb       0,$56               FFill
                    fdb       FFill-*+2
                    fcb       2,$50               Circle
                    fdb       Circle-*+2
                    fcb       4,$52               Ellipse
                    fdb       Ellipse-*+2
                    fcb       12,$54              Arc
                    fdb       Arc-*+2
                    fcb       2,$50               Filled Circle (flag set to differentiate) $53
                    fdb       Filled-*+2
                    fcb       4,$52               Filled Ellipse (flag set to differentiate) $54
                    fdb       Filled-*+2
                    fcb       $ff,$00             Blank (free for new function)
                    fdb       $0000

L0129               fcc       "../CMDS/"
L0131               fcs       "grfdrv"

******************************
*
* Initialization routine
Init                pshs      u,y                 Preserve regs
                    ldd       >WGlobal+G.GrfEnt   Grfdrv there?
                    lbne      L01DB               Yes, go on
* Setup window allocation bit map table
                    IFNE      H6309
                    clrd
                    clrw
                    stq       >WGlobal+G.WUseTb   Set all 32 windows to be unused
                    ELSE
                    clra
                    clrb
                    std       >GrfMem+gr00B5
                    std       >WGlobal+G.WUseTb
                    std       >WGlobal+G.WUseTb+2
                    ENDC
* Get grfdrv setup
                    leax      <L0131,pc           Point to grfdrv module name
                    lbsr      L01FB               Does it exist in memory?
                    bcc       L0169               Yes, go on
                    cmpb      #E$MNF              Module not found?
                    bne       L0166               No, exit with error
L0159               leax      <L0129,pc           Point to full pathname
                    lbsr      L021F               Load ok?
* Initialize grfdrv
                    bcc       L0169               It's ok, go on
L0166               coma                          Set carry
L0167               puls      y,u,pc              Return

* Default palette color settings
L02F3               fcb       $3f,$09,$00,$12     Colors 0-3 & 8-11 (white,blue,black,green)
L02F7               fcb       $24,$36,$2d,$1b     Colors 4-7 & 12-15 (red, yellow, magenta, cyan)

* Execute Grfdrv's init routine
* Grfdrv will move itself over to task 1 & setup it's own memory map
L0169               lda       #'G                 debug: signal that we are in GrfDrv Init
                    jsr       >D.BtBug            ---
                    IFNE      H6309
                    lde       #GrfMem/256         Direct page for GrfDrv
                    tfr       e,dp
                    ELSE
                    pshs      a
                    lda       #GrfMem/256
                    tfr       a,dp
                    puls      a
                    ENDC
                    ldu       #GrfMem             Point to GRFDRV global mem
* Code moved from GrfDrv's Init routine.
                    coma
                    sta       >WGlobal+g0038      Put it back
* Initialize window entries
                    ldx       #WinBase-$10        Point to start of window tbl entries
                    IFNE      H6309
                    ldq       #$2040FFFF          Max # window/size of each entry/Table init code
L0097               stw       ,x                  Initialize table pointer
                    abx                           Move to next entry
                    deca                          Done?
                    bne       L0097               No keep going
                    ELSE
                    pshs      u
                    ldd       #$2040
                    ldu       #$FFFF
L0097               stu       ,x
                    abx
                    deca
                    bne       L0097
                    stu       <$B5
                    puls      u
                    ENDC
* Initialize screen tables
                    ldx       #STblBse+1          Point to 2nd byte of scrn tbls - 1st block # used
                    ldd       #$1020              smaller than the ldb/lde
* ATD: doing CLR is slightly slower than STA, but this code is executed only
* once, so we optimize for size, not speed
L00A9               clr       ,x                  Set first block # used (A=0 from L0097 loop)
                    abx                           Move to next entry
                    deca                          Done?
                    bne       L00A9               No, keep goin
* Initialize DAT image
                    clrb                          Set System bank as first one (a already 0)
                    std       <$87
                    IFNE      H6309
                    ldq       #$333E333E          Get blank image
                    std       <$89                Save it in rest
* NOTE: IF 16K GRFDRV DONE,CHANGE FOLLOWING LINE TO STD <$8F
* Set entire table as this will be reset below as needed. RG.
                    stq       <$8D
                    stq       <$91
                    std       <$95
                    ELSE
                    ldd       #$333E              Since 6809 version is >8K save some steps
                    std       <$89
                    std       <$8F
                    std       <$91
                    std       <$93
                    std       <$95
                    ENDC
* New code to find GrfDrv in memory and setup DAT - BN
                    lda       #Systm+Objct        Get module type
                    IFNE      H6309
                    leax      <L0131,pc           Point to grfdrv name
                    ELSE
                    leax      >L0131,pc           Point to grfdrv name
                    ENDC
                    ldy       >D.SysPrc           Get system process dsc. ptr.
                    leay      <P$DATImg,y         Point to the DAT image
                    os9       F$FModul            Get module directory pointer to grfdrv
* End of new code
                    bcs       L0167
                    ldy       MD$MPDAT,u          get DAT offset
                    ldd       ,y
                    std       <$8B                save first block
                    ldd       2,y                 is it >8K?
                    beq       L0101a
                    std       <$8D
L0101a              ldy       >D.TskIPt           Get task image pointer
                    ldx       #GrfMem+gr0087      Point to grfdrv DAT image tbl
                    stx       2,y                 Save it as second task
* ATD: changed from $1C98 for more lee-way on the stack. Mainly used by FFill
                    ldd       #$1CB0              low address for stack: L1DC4, L1DEE
                    std       <$3B                Save in GRFDRV mem
                    IFNE      H6309
                    clrd                          Get screen table initialization
                    clrw                          (CLRQ)
                    stq       <$2e                Init current screen table ptr & window entry
                    stq       <$3d                Init X/Y coords Gfx cursor was last ON at
                    ELSE
                    clra
                    clrb
                    std       <$2e
                    std       <$30
                    std       <$3d
                    std       <$3f
*         std   <$B5
                    ENDC
                    stb       <$32                Clear out block #'s for G/P buffer (Current,
                    stb       <$35                previous)
                    std       <$39                Text cursor & gfx cursors off
L0102               clra
                    tfr       a,dp                Set DP to 0 for Wind/CoGrf, which need it there
                    inc       MD$Link+1,u         Increment it's link count
* new code to get GrfDrv exec addr. BN
                    ldd       #0
                    ldx       #M$Exec
                    ldy       #$118B
                    os9       F$LDDDXY
                    ora       #$40
* end of new code
                    std       >WGlobal+G.GrfEnt   Save it
                    IFNE      H6309
                    oim       #$80,>WGlobal+G.BCFFlg Indicate that Grfdrv has been found?
                    ELSE
                    lda       >WGlobal+G.BCFFlg
                    ora       #$80
                    sta       >WGlobal+G.BCFFlg
                    ENDC
* Initialize GFX tables.
                    ldd       #$02FF              Get how many bytes we need
                    os9       F$SRqMem            Reserve it (note: only $2cf is used so far)
                    lbcs      L0166               Can't get memory, exit
                    stu       >WGlobal+G.GfxTbl   Save the pointer to GFX tables (NOT IN GLOBAL!)
* Later, when we make Grfdrv specific generic fast clear routine vector, have
*   both sets of clears call it (both 6809 and 6309) LCB
                    IFNE      H6309
                    tfr       d,w                 Move mem size to W
                    leay      <Nul0+2,pc          Clear them all to NUL's
                    tfm       y,u+
                    stw       >WGlobal+G.PrWMPt   initialize previous window table pointer to 0
                    ldu       #WGlobal+G.WrkWTb   Point to work window table
Nul0                ldw       #$0040
                    tfm       y,u+
                    ELSE
ClrLp1              clr       ,u+
                    subd      #$0001
                    bne       ClrLp1
                    std       >WGlobal+G.PrWMPt   initialize previous window table pointer to 0
                    ldu       #WGlobal+G.WrkWTb   Point to work window table
                    ldb       #$0040
ClrLp2              clr       ,u+
                    decb
                    bne       ClrLp2
                    ENDC
* Set default palettes. May be able to use stack blast copy vector here
* (once added). LCB. At the very least, use U as source ptr, and pulu a couple
* of 16 bit registers (d,x) to make it faster/smaller.
                    ldy       #$10c7              Point to default palette register buffer
                    sty       >WGlobal+G.DefPal   Save it
                    IFNE      H6309
                    ldq       L02F3,pc            Get 4 of default palettes
                    stq       ,y                  Save 0-3
                    stq       8,y                 Save 8-11
                    ldq       L02F7,pc            Get other 4 default palettes
                    stq       4,y                 Save 4-7
                    stq       12,y                Save 12-15
                    ELSE
                    ldd       L02F7+2,pc
                    std       6,y
                    std       14,y
                    ldd       L02F3+2,pc
                    std       2,y
                    std       10,y
                    ldd       L02F3,pc
                    std       ,y
                    std       8,y
                    ldd       L02F7,pc
                    std       4,y
                    std       12,y
                    ENDC
L01DB               ldu       2,s                 Get device static mem
                    ldy       ,s                  Get path descriptor pointer
                    leax      CC3Parm,u           Point to parameters
                    stx       V.PrmStrt,u         Save it as param start pointer
                    stx       V.NxtPrm,u          Save it as pointer to next param
                    ldb       IT.WND,y            Get window # from device dsc
                    stb       V.DWNum,u           Save it as window # in static mem
* If normal window # (0-31), mark as used in window bit table
* If high bit set (like /W's $FF), don't allocate, let SS.Open call use next
*  available one and let it mark which one it found
                    bmi       L01F4               Skip ahead if /w type (Wildcard)
                    clra                          Clear MSB of window #
                    bsr       L024A               Allocate window in 32 bit window used table
L01F4               lbsr      L07B0               Find empty window tbl entry & put in linked list
                    clrb                          No error & return
                    puls      u,y,pc

* Link to module
L01FB               leas      -2,s                Make buffer for current process dsc.
                    bsr       L0238               Swap to system process
                    lda       #Systm+Objct        Link module
                    os9       F$NMLink
                    bsr       L0244               Swap back to current process
                    bra       L022C               Return

* Load a module
L021F               leas      -2,s                Make a buffer for current process ptr
                    bsr       L0238               Switch to system process descriptor
                    lda       #Systm+Objct        Load module
                    ldu       <D.Proc
                    os9       F$NMLoad
L022A               bsr       L0244               Swap back to current process
L022C               leas      2,s                 Purge stack & return
                    rts

* Switch to system process descriptor
L0238               pshs      d                   Preserve D
                    ldd       <D.Proc             Get current process dsc. ptr
                    std       4,s                 Preserve on stack
                    ldd       <D.SysPrc           Get system process dsc. ptr
                    std       <D.Proc             Make it the current process
                    puls      d,pc                Restore D & return

* Switch back to current process
L0244               pshs      d                   Preserve D
                    ldd       4,s                 Get current process ptr
                    std       <D.Proc             Make it the current process
                    puls      d,pc                Restore D & return

* Allocate a window
* Entry: D=Window # to allocate
L024A               pshs      d,u                 Preserve U
                    bsr       L0238               Swap to system process dsc
                    bsr       L0279               Get pointer to window allocation table
                    os9       F$AllBit            Allocate it
L0255               bsr       L0244               Swap back to current process
                    leas      2,s                 Purge stack
                    puls      u,pc                Restore U & return

* Search for a free window
* Entry: D=Starting window #
L025B               pshs      d,u                 Preserve U
                    bsr       L0238               Swap to system process dsc
                    bsr       L0279               Get ptr to window map
                    leau      4,x                 Point to end of map
                    os9       F$SchBit            Find it
                    bra       L0255               Return with it

* De-Allocate a window
* Entry: D=Window # to delete
L026A               bmi       L0282               Illegal window #
                    pshs      d,u                 Preserve U
                    bsr       L0238               Swap to system process dsc
                    bsr       L0279               Get ptr to window map
                    os9       F$DelBit            Delete it & return
                    bra       L0255

* Point to window allocation table
L0279               ldx       #WGlobal+G.WUseTb   Point to window bit table
                    ldy       #1                  Get # windows to allocate/de-allocate
L0282               rts                           Return

******************************
* Terminate routine
* Entry: U=Static mem ptr
*        Y=Path dsc. ptr
Term
* Next two lines added by Boisy on 08/22/2007
* This test is necessary to prevent a crash in the case that grfdrv cannot be
* loaded.  If grfdrv isn't properly initialized, then the high bit of BCFFlg will
* be clear.  Without this check, the test for Wt.STbl,y to be equal to $FF would fail,
* and a DWEnd would be attempted.  Since grfdrv's init routine sets Wt.STBl,y to $FFFF
* for each window table entry, this wasn't getting done, and the call to DWEnd would
* be vectored to grfdrv, which wasn't to be found!
                    tst       WGlobal+G.BCFFlg    was Grfdrv found? (hi bit set if so)
                    bpl       TermEx              if not, no nothing got initialized, so leave quietly
                    clra                          Get start window # for de-allocate
                    ldb       V.DWNum,u           Get device window # from static mem
                    pshs      u,y                 Preserve static mem & path dsc. ptrs
                    bsr       L026A               De-allocate it from window map
                    lbsr      L06AE               Get window table pointer
                    lda       Wt.STbl,y           Get MSB of screen table ptr
                    cmpa      #$FF                Set?
                    bne       L0298               Yes, go on
                    sta       Wt.STbl+1,y         Get rid of table ptr
                    bra       L02A5               Go on

* Send DWEnd to grfdrv
L0298               ldy       ,s                  Get path dsc. ptr
                    ldu       2,s                 Get static mem ptr
                    ldb       #$08                Get callcode for DWEnd
                    stb       V.CallCde,u         Save it in static mem area
                    lbsr      L0452               Go do it
* Clear out device static memory. 6809 Use Mini stack blast clear vector later
L02A5               puls      u,y                 Restore static mem & path dsc. ptrs
                    leax      V.WinNum,u          Point to window entry #
                    IFNE      H6309
                    leay      <Nul1+2,pc          Point to NUL byte
Nul1                ldw       #CC3DSiz-V.WinNum   Size of block to clear
                    tfm       y,x+
                    ELSE
                    ldd       #CC3DSiz-V.WinNum
Lp4                 sta       ,x+
                    decb
                    bne       Lp4
                    ENDC
                    clr       V.InfVld,u          Clear 'rest of info valid' flag
* Scan window tables for a valid window
                    ldx       #WinBase            Point to base of window tables
                    ldd       #MaxWind*256+Wt.Siz # of window tables & Size of each table
L02B9               equ       *
                    IFNE      H6309
                    ldw       Wt.STbl,x           Get screen table ptr
                    cmpe      #$FF                MSB indicate unused?
                    bne       L02F1               No, exit without error
* Just a guess, but if 2nd byte is $FE with 1st being $FF, could be a flag
*  for that this is a "copy" of a window to do overlapped device windows
                    cmpf      #$FF                LSB indicate unused?
                    bne       L02F1               No, exit without error
                    ELSE
                    pshs      d
                    ldd       Wt.STbl,x
                    std       >GrfMem+gr00B5
                    cmpa      #$FF
                    bne       L02F1B
                    cmpb      #$FF
                    bne       L02F1B              No, exit without error
                    puls      d
                    ENDC
                    abx                           Point to next window table
                    deca                          Decrement counter
                    bne       L02B9               Do until all 32 entries are checked
* All windows are unallocated, terminate GRFDRV
                    tfr       x,y                 Move to proper register again
                    ldb       #$02                get grfdrv terminate code
                    lbsr      L0101               go do it
                    ldd       >WGlobal+G.GrfEnt   get grfdrv address
                    clrb                          Make it even page
                    tfr       d,u                 Move to proper reg for Unlink
                    os9       F$UnLink            Unlink GRFDRV
                    bcs       L02F2               If error unlinking, exit
                    IFNE      H6309
                    clrd
                    ELSE
                    clra
                    clrb
                    ENDC
                    std       >WGlobal+G.GrfEnt   GRFDRV address to non-existant
                    ldu       >WGlobal+G.GfxTbl   Get ptr to gfx tables
                    ldd       #$02FF              Size of graphics tables
                    os9       F$SRtMem            Return graphics table memory to system
                    bcs       L02F2               If error, exit with it
TermEx              clrb
                    rts

                    IFEQ      H6309
L02F1B              puls      d
                    ENDC
L02F1               clrb                          No error & return
                    tfr       x,y                 Move to proper register
L02F2               rts

****************************
* Main Entry point from VTIO
* Entry: U=Device memory pointer
*        Y=Path descriptor pointer

entry               lbra      Init                (CoInit $00) Initialization
                    bra       Write               (CoWrite $03) Write
                    nop
                    lbra      GetStt              (CoGetStt $06) Get status
                    lbra      SetStt              (CoSetStt $09) Set status
                    lbra      Term                (CoTerm $0C) Terminate
                    lbra      L0C68               (CoWinSpc $0F) Window special processing

L0A96               comb                          Set error flag
                    ldb       #E$UnkSvc           Unknown service error
                    rts

****************************
* Write routine: Optimized for normal text
* Entry: A=Char to write
*        U=Device memory pointer
*        Y=Path descriptor pointer
Write               ldb       #$3a                get grfdrv function for Alpha put as default
                    cmpa      #C$SPAC             Space or higher?
                    bhs       L03A1               Yes, do alpha put
                    cmpa      #$1B                Escape code?
                    bne       L0347               No, keep checking
                    ldb       [V.PrmStrt,u]       get first parameter from parameter area
                    cmpb      #$55                Past maximum supported escape code?
                    bhi       L0A96               Yes, exit with error
                    subb      #$20                Adjust it down for table offset
                    bmi       L0A96               Below minimum supported code, exit with error
                    lslb                          Adjust for 4 bytes/entry
                    lslb
                    leax      >L0027,pc           Point to ESC code vector table
                    abx                           Point to 4 byte entry
                    IFNE      H6309
                    ldq       ,x                  A=# param bytes,B=GRFDRV code,W=vector offset
                    ELSE
                    ldd       2,x
                    std       >GrfMem+gr00B5
                    ldd       ,x
                    ENDC
                    stb       V.CallCde,u         Save GRFDRV code in Static mem (need for L00F7)
                    tsta                          Any parameter bytes needed?
                    beq       L0339               No, just go do function
                    bmi       L0A96               $FF=Empty, exit with error
                    sta       V.ParmCnt,u         Preserve for VTIO to get the rest
L032F               equ       *
                    IFNE      H6309
                    addr      w,x                 Point to vector
                    ELSE
* 6809 - might use DP scratch var here instead of pshs/puls b. LCB
                    pshs      b
                    ldd       2,x
                    leax      d,x
                    puls      b
                    ENDC
                    stx       V.ParmVct,u         Save vector for VTIO to call
                    clra                          No error & return so VTIO can get rest of parms
                    rts

* No param calls go here
L0339               equ       *
                    IFNE      H6309
                    jmp       w,x                 Go execute function
                    ELSE
* 6809 - use DP scratch var here instead of pshs/puls d. LCB
                    pshs      d
                    ldd       >GrfMem+gr00B5
                    leax      d,x
                    puls      d
                    jmp       ,x
                    ENDC

* Check special display codes
L0347               cmpa      #$1F                $1F codes?
                    beq       L038D               Yes, go process them
L034D               cmpa      #$02                Cursor X,Y?
                    bne       L0356               No, check next
                    leax      <L036E,pc           Point to Cursor X,Y routine
                    bra       L0362               Let VTIO get rest of parms

L0356               cmpa      #$05                Cursor On/Off?
                    beq       L0396               Go to cursor on/off routine
L039F               ldb       #$3C                Otherwise, GrfDrv function: Control codes
L03A1               pshs      d                   Preserve write char & GrfDrv function code
                    lbsr      L06A0               Get window table ptr & verify it
                    bcs       UnDef               Couldn't, exit with Window Undefined error
                    puls      d                   Get back write char & GrfDrv function code
* Execute GrfDrv
* Entry: @ L0101 : B=Callcode for GRFDRV
* All regs are thrown onto stack for 'fake' RTI done by [D.Flip1] (in vector
* page RAM at the top of OS9p1) after switching to System Task #1 (GRFDRV)
* Added protection for regE; RG 2003/10/15
L0101               ldx       >WGlobal+G.GrfEnt   Get GrfDrv entry address
                    orcc      #Entire             Set up 'pull all regs' for RTI
                    IFNE      H6309
                    pshsw
                    tfr       cc,e
                    ste       >WGlobal+g0005
                    pulsw
                    ELSE
* 6809 - use DP scratch var here instead of pshs/puls d. LCB
                    pshs      d
                    ldd       >GrfMem+gr00B5
                    std       >GrfMem+gr00B5
                    tfr       cc,a
                    sta       >WGlobal+g0005
                    puls      d
                    ENDC
                    orcc      #IntMasks           Disable IRQ's
                    sts       >WGlobal+G.GrfStk   Save stack ptr for GRFDRV
                    lds       <D.CCStk            Get new stack ptr
* Dump all registers to stack for fake RTI
                    pshs      dp,x,y,u,pc         dump all registers to stack for fake RTI
                    IFNE      H6309
                    pshsw     no                  register to push for 6809
                    lde       >WGlobal+g0005      get back regDP
                    ENDC
                    pshs      cc,d
                    stx       R$PC,s              Save grfdrv entry address as the PC on stack
                    IFNE      H6309
                    ste       R$CC,s              Save CC bitE into CC on stack
                    ste       >WGlobal+G.GfBusy   Flag grfdrv busy
                    ELSE
                    lda       >WGlobal+g0005
                    sta       R$CC,s
                    sta       >WGlobal+G.GfBusy   Flag grfdrv busy
                    lda       R$A,s               may not be needed
                    ENDC
                    jmp       [>D.Flip1]          Flip to GRFDRV and execute it

* GRFDRV will execute function, then call [D.Flip0] to switch back to here. It
* will use an RTS to return to the code here that called L00F7 or L0101 in the
* first place. Only SP,PC & CC are set up- ALL OTHER REGISTERS MAY BE MODIFIED

* Entry point for GRFDRV for most GFX commands
L00F7               ldx       >WGlobal+G.CurDvM   Get current device memory ptr
                    ldb       V.CallCde,x         Get callcode from it
                    bra       L0101               Go call GRFDRV

UnDef               leas      2,s                 Eat stack
UnDef2              ldb       #E$WUndef           Undefined Window error
                    rts

* Set counts up for CC3/TC9IO to get rest of needed parms
L0362               sta       V.ParmCnt,u         Store # bytes to get for params in static mem
                    stx       V.ParmVct,u         Store vector to function in static mem
                    clra                          No error & return so VTIO can get rest of parms
                    rts

* Process CurXY after parms are gotten
* Entry: U=Static mem ptr
L036E               pshs      u                   Save static mem ptr (in case DWSet modifies U)
                    lbsr      L06A0               Get window table ptr
                    puls      u                   Get back static mem ptr
                    bcs       UnDef2              Couldn't, exit with Window undefined error
                    ldd       [V.PrmStrt,u]       get the coords requested
L0380               sta       >GrfMem+gr0047      Save X coord
                    stb       >GrfMem+gr0049      Save Y coord
                    ldb       #$42                Gcurrv function: Goto X/Y
L038A               bra       L0101               Execute Grfdrv

* Process $1f display codes
L038D               lda       [V.PrmStrt,u]       get type of $1f function
                    ldb       #$40                GrfDrv function: $1F codes
                    bra       L03A1               Go get window tbl ptr & execute GRFDRV

* Cursor on/off
L0396               lda       [V.PrmStrt,u]       get cursor on/off parameter byte
                    ldb       #$3E                GrfDrv function: Cursor on/off
                    bra       L03A1               Go get window tbl ptr & execute GRFDRV

******************************
* DWSet entry point
* Entry: U=Device static mem pointer
*        Y=Path descriptor
*        X=Param pointer
DWSet               pshs      y,u                 preserve static mem & path descriptor pointers
                    lbsr      L06AE               get window table pointer for current window
* Window already defined?
                    lda       Wt.STbl,y           Get MSB of screen table ptr
                    cmpa      #$FF                Already defined?
                    beq       L03BF               No, skip ahead
                    comb                          Exit with Window Already Defined error
                    ldb       #E$WADef            get window already defined error
                    puls      u,y,pc              Restore regs & return

* Check screen type
L03BF               lda       ,x+                 Get screen type from parameters
                    lbsr      L07E0               Convert it to internal code
                    bcc       L03CB               it's good, skip ahead
                    puls      u,y                 Exit with Illegal Window Definition error
                    lbra      L0697               return illegal window definition error

* Legal window type, make sure coords & size are at least reasonable
L03CB               stb       >GrfMem+Gr.STYMk    Save screen type in Grfdrv Mem
                    bsr       L0413               Move coord's, size & pals. to window table
                    bcc       L03D7               Legal values, skip ahead
                    ldb       #E$IWDef            Illegal Window Definition
                    puls      pc,u,y              restore regs & return with error

* Coordinates & size are within 0-127, continue
L03D7               cmpb      #$FF                is it same screen?
                    beq       L03F2               yes, don't bother getting border color
                    leax      <L03E5,pc           point to processor for border color
                    lda       #$01                get # bytes to get
                    puls      u,y                 purge stack
                    bra       L0362               let VTIO get it for me

* If the window was not on the current screen grab the optional border color
L03E5               pshs      u,y                 Preserve static mem & path dsc. ptrs
                    lbsr      L06AE               get window table pointer into Y
                    lda       ,x                  get border color
                    sta       >GrfMem+gr005A      save it in grfdrv mem
                    bra       L03F9               continue processing

* Current displayed screen or current process screen goes here
L03F2               ldx       ,s                  get path descriptor pointer
                    lbsr      L075C               check validity of screen table
                    bcs       L0408               error, return
* all parameters are moved, let grfdrv do the rest
L03F9               lbsr      L00F7               let grfdrv take over
                    bcs       L040A               grfdrv error, return
                    ldu       2,s                 get static mem pointer
                    inc       V.InfVld,u          Set flag to indicate rest of static mem valid
                    IFNE      H6309
                    ldw       >WGlobal+G.CurDev   Get current window ptr
                    ELSE
                    ldy       >WGlobal+G.CurDev
                    sty       >GrfMem+gr00B5
                    ENDC
                    beq       Nowin               None, skip ahead
                    IFNE      H6309
                    lda       >V.ULCase,w         Get special keyflags
                    ELSE
                    lda       >V.ULCase,y
                    ENDC
                    sta       >V.ULCase,u         Save in new window
Nowin               ldy       ,s                  get path descriptor pointer
                    bsr       L0436               setup lines per page
                    ldb       >GrfMem+Gr.STYMk    get screen type from Grfdrv Mem
                    cmpb      #1                  Is it an overlay?
                    bls       L0408               don't flag screen if overlay
                    inc       V.ScrChg,u          Flag that screen has changed for AltIRQ routine
L0408               puls      pc,u,y              all done, return

* DWSet didn't work, flag window table entry as free again
L040A               ldu       #$FFFF              get table free value
                    stu       Wt.STbl,y           put it in window table
                    puls      y,u,pc              restore & return

* Move co-ordinates/size & fore/back colors into window table
L0413               pshs      d                   Preserve D
                    bsr       L0423               Move coordinates & size
                    bcs       L041F               Error in size, return the error
                    ldd       ,x++                Get foreground/background colors
                    std       Wt.Fore,y           Put it in window table
L041D               puls      d,pc                Restore D & return

L041F               stb       1,s                 Save error code into B on stack
                    puls      d,pc                Restore D & return

* Move start coordinates & size into window table
* Entry: X=Pointer to co-rdinates
*        Y=Window table pointer
L0423               ldd       ,x++                Get start coordinates
                    std       Wt.CPX,y            Save 'em
                    lda       ,x+                 Get X size
                    ble       L042F               Too big or 0, exit with error
                    ldb       ,x+                 Get Y size
                    bgt       L0432               Above 0, go on
L042F               lbra      L0697               Return error

L0432               std       Wt.SZX,y            Save size to window table
                    clrb                          Clear error & return
                    rts

* Setup lines/page variables
* Entry: Y=Path descriptor pointer
*        U=Device static mem pointer for new window
L0436               pshs      y                   L06AE resets y
                    lbsr      L06AE               get window table pointer
                    ldb       Wt.SZY,y            Get Y size
                    puls      y                   restore reg
                    stb       V.LINE,u            save it in static mem for SCF
                    stb       PD.PAG,y            Save it as the default in path descriptor
                    clrb                          clear errors
                    rts                           return

****************************
* DWEnd entry point
* Entry: U=Static memory pointer
*        Y=Path descriptor pointer
DWEnd               pshs      u
                    bsr       L0452               process it
                    puls      u
                    bcs       L0451               error, return
                    clr       V.InfVld,u          clear flag - static mem no longer valid & return
L0451               rts

* Check for legal screen table (PRESERVES U)
L0452               lbsr      L06AE               get pointer to window table into Y
                    lda       Wt.STbl,y           screen table exist?
                    bpl       L0461               screen table exists, skip ahead
                    comb                          set carry for error
                    lbra      L069D               return undefined window error

* Window legal, Delete any overlays (PRESERVES U)
L0461               lda       Wt.BLnk,y           Any overlay windows?
                    bmi       L0479               No, skip ahead
                    pshs      a,u                 save parent window # & static mem
                    bsr       L04EA               Do a CWArea to full size
                    ldb       #$0C                Grfdrv function: Overlay window end
                    lbsr      L0101
                    puls      a,u                 restore parent & static mem
                    sta       V.WinNum,u          save parent as current
                    lbsr      L06AE               get it's window table pointer
                    bra       L0461               keep going

* Change to full window size & clear out the graphics table entry
*   clear out the current window & screen table ptrs
L0479               pshs      u                   save static mem pointer
                    bsr       L04EA               Do a CWArea to full size
* clear out gfx table entry
                    puls      u                   Restore static mem ptr
                    lbsr      L06B9               Point to gfx table entry for this window
                    IFNE      H6309
                    leau      <Nul2+2,pc
Nul2                ldw       #$0012
                    tfm       u,x+
                    ELSE
* 6809 - use DP scratch var here instead of pshs/puls b. LCB
* Or, pshs  u, lda #9 / ldu #0 / stu ,x++ / deca / bne / puls u
                    pshs      b
                    ldd       #$0012
Nul2                sta       ,x+
                    decb
                    bne       Nul2
                    puls      b
                    ENDC
                    lda       >WGlobal+G.WinType  is this a window?
                    bmi       L0499               no, return
                    IFNE      H6309
                    clrd
                    stq       >GrfMem+gr002E      clear window & screen table entrys
                    ELSE
                    clra
                    clrb
                    std       >GrfMem+gr00B5
                    std       >GrfMem+gr002E      clear window & screen table entrys
                    std       >GrfMem+gr002E+2
                    ENDC
L0499               lbra      L00F7               let grfdrv do the rest

*****************************
* OWSet entry point
* Entry: U=Device static mem pointer
*        Y=Path descriptor pointer
*        X=Parameter pointer
OWSet               pshs      y,u                 preserve path descriptor & static mem pointers
                    lbsr      L06A0               verify window table
                    puls      u,y                 restore pointers
                    lbcs      L069D               not a legal window, return undefined window error
                    pshs      u,y                 preserve path descriptor & static mem pointers
                    lbsr      L07B0               get a blank window table pointer
                    bcc       L04B6               we found one, skip ahead
                    puls      u,y,pc              purge stack & return

L04B2               puls      u,y
                    bra       L04D5

* We have a new window table for overlay, so process parameters
L04B6               lda       ,x+                 get save switch from parameters
                    sta       >GrfMem+gr0059      save it in grfdrv mem
                    lbsr      L0413               move rest of parameters to grfdrv mem
                    bcs       L04B2               error, return
                    pshs      y                   preserve window table pointer
                    lbsr      L00F7               let grfdrv create overlay
                    puls      y                   restore window table pointer
                    bcs       L04D1               error from grfdrv, return
                    puls      u,y                 restore path descriptor & static mem pointers
                    lbra      L0436               setup lines per page & return from there

L04D1               leas      2,s                 Eat path dsc. ptr
                    puls      u                   Get static mem ptr back
* Could not find a window table for overlay, get rid of links & return
L04D5               lda       Wt.BLnk,y           Get back window # link
                    sta       V.WinNum,u          Store it as current window #
                    IFNE      H6309
                    ldw       #$FFFF              Set screen table ptr to unused
                    stw       Wt.STbl,y
                    ELSE
* 6809 - use DP scratch var here instead of pshs/puls x. LCB
                    pshs      x
                    ldx       #$FFFF
                    stx       >GrfMem+gr00B5
                    stx       Wt.STbl,y
                    puls      x
                    ENDC
                    coma                          Set carry for error
L04E7               rts

* Change window to full size reported in window table
* Relocated lines and removed regW; regE bug; RG
L04EA               ldd       Wt.DfSZX,y          Get default size of window
                    std       Wt.CPX+2,y          Save current size
                    std       >GrfMem+gr00B5
                    IFNE      H6309
                    clrd                          set start coords to 0,0
                    ELSE
                    clra
                    clrb
                    ENDC
                    std       Wt.CPX,y            Store coords
                    ldb       #$0E                GrfDrv function: CWArea
                    pshs      y                   preserve window table ptr
                    lbsr      L0101               Send it to GrfDrv
                    puls      y,pc                Restore reg & return

****************************
* OWEnd entry point
* Entry: U=Device static mem pointer
*        Y=Path descriptor pointer
OWEnd               pshs      u,y                 preserve path descriptor & static mem pointers
                    lbsr      L06A0               get pointer to window table & verify it
                    bcc       L0508               went ok, skip ahead
                    puls      u,y                 Restore regs
                    lbra      L069D               Exit with undefined window error

L0508               lda       Wt.BLnk,y           is this an overlay?
                    bpl       L0511               yes, go remove it
                    puls      u,y                 purge stack
                    lbra      L0697               return with illegal window definition error

* We are in overlay, remove it
L0511               ldu       2,s                 get static mem pointer
                    lbsr      L06B9               get pointer to graphics table for this window
                    IFNE      H6309
                    lde       ,x                  get menuing system screen type
                    ELSE
                    lda       ,x
                    sta       >GrfMem+gr00B5
                    ENDC
                    lda       Wt.BLnk,y           get parent window # of this overlay
* We know this is a overlay window, continue
                    sta       V.WinNum,u          save new window #
                    bsr       L04EA               change to the full size window
                    ldb       #$0C                get grfdrv function for OWEnd
                    lbsr      L0101               let grfdrv do the rest
                    bcc       L052E               grfdrv went ok, skip ahead
L052C               puls      y,u,pc              restore & return

* Overlay removed, check if we activate menu bar on parent window
L052E               puls      y,u                 Restore static mem & path dsc. ptrs
                    lbsr      L0436               set lines per page in path descriptor
                    IFNE      CoGrf-1
                    IFNE      H6309
                    tste                          is screen type a regular no box window?
                    ELSE
                    tst       >GrfMem+gr00B5
                    ENDC
                    beq       L04E7               yes, return
                    IFNE      H6309
                    cmpe      #WT.FSWin           do we have a menu bar on window?
                    ELSE
* Can't use DP trick here - needs flags preserved
                    pshs      a
                    lda       >GrfMem+gr00B5
                    cmpa      #WT.FSWin
                    puls      a
                    ENDC
                    bhi       L04E7               no, return
                    lda       >WGlobal+G.CrDvFl   Are we the current active window?
                    beq       L0591               no, skip updating menu bar
                    lbra      L13F5               set menu bar to active state
                    ELSE
                    rts                           If just CoGrf, we didn't need to do any MultiVue checks
                    ENDC

****************************
* Select entry point
* Entry: U=Static memory pointer
*        Y=Path descriptor pointer
Select              ldx       PD.RGS,y            get register stack pointer
                    lda       R$A,x               get path # to new window
                    ldx       <D.Proc             get current process pointer
                    cmpa      P$SelP,x            Is path requested the same as current process' active path?
                    beq       L0591               yes, nothing to change so return
                    ldb       P$SelP,x            No, get the current processes' active window path
                    sta       P$SelP,x            save new path (to window Selected)
                    pshs      y                   save path descriptor pointer
                    bsr       L0592               Get the device table ptr for current process
                    ldx       V$STAT,y            Get static mem ptr for current process
                    cmpx      >WGlobal+G.CurDev   Same as current device? (same screen (not window))?
                    puls      y                   restore path descriptor pointer
                    bne       L0590               no match on old device, return (don't update GIME if we aren't on same screen)
                    pshs      b                   Same screen; save current processes' window path block #
                    leax      ,u                  point X to static mem ptr of window
                    lbsr      L06A0               verify window table of new window
                    puls      b                   restore old window path block #
                    bcc       L0582               window exists, skip ahead
                    ldx       <D.Proc             Doesn't exist, get current process pointer back
                    stb       P$SelP,x            save old window path number back
                    lbra      L069D               return undefined window error

* New window exists, update screen to it
L0582               ldu       >WGlobal+G.CurDev   Get current device mem ptr
                    stu       >WGlobal+G.PrWMPt   Save as previous device mem ptr
                    stx       >WGlobal+G.CurDev   Save new current device mem ptr
                    inc       V.ScrChg,x          Flag screen has changed for AltIRQ routine
* LCB - once we get clock to do such updates properly, we should be able to eliminate
*  this Sleep call. Grfdrv is non-reentrant, so it won't come back in here to change stuff while
*  it is changing, anyways.

* Give system a chance to stabilize. RG
                    ldx       #2
                    os9       F$Sleep
L0590               clrb                          clear errors
L0591               rts                           return

* Get ptr to device table
* Entry: X=Pointer to process descriptor
*        B=Path block # to get
* Exit : Y=Pointer to device table entry
L0592               leax      P$Path,x            get pointer to path #'s
* Added next line to protect regB from os9 F$Find64 error report. RG
                    pshs      b
                    lda       b,x                 get path block
                    ldx       <D.PthDBT           get pointer to descriptor block table
                    os9       F$Find64            get pointer to path descriptor
                    ldy       PD.DEV,y            get pointer to device table entry
                    puls      b,pc                return

****************************
* CWArea entry point
* Entry: U=Static memory pointer
*        Y=Path descriptor pointer
*        X=Pointer to parameters
CWArea              pshs      y,u                 Save device mem ptr & path dsc. ptr on stack
                    lbsr      L06A0               verify window table
                    IFNE      H6309
                    ldq       Wt.CPX,y            get original start & size
                    pshsw     preserve            them on the stack
                    ELSE
                    ldd       Wt.CPX+2,y
                    std       >GrfMem+gr00B5
                    pshs      d
                    ldd       Wt.CPX,y
                    ENDC
                    pshs      d
                    lbsr      L0423               move coords to window table
                    bcs       L0609               didn't pan out, restore originals & return error
* The rest of this is unique to CoWin.  What it does is calculate the
* maximum allowable window sizes based on the window type defined in the
* menuing system.
* NOTE: MAY BE ABLE TO USE E & F FOR SOME OF THE ,S STUFF
                    ldu       6,s                 get device static memory pointer
                    lbsr      L06B9               get graphics table entry pointer for this window
                    IFNE      H6309
                    clrd                          set starting X/Y coords to 0
                    ELSE
                    clra
                    clrb
                    ENDC
                    pshs      d
                    ldd       Wt.DfSZX,y          Get default X/Y sizes from window table
                    pshs      d                   Make them the ending X,Y coords
                    IFNE      CoGrf-1
* Beginning of CoWin only code
                    lda       ,x                  get graphics table window type
                    beq       L05E3               If normal window, skip all adjustments
                    deca                          Is it a WT.FWin (framed window=1)?
                    bne       L05CB               no, check for scroll bars
                    dec       1,s                 Yes, subtract 1 from Y size
                    inc       3,s                 Add 1 to Y start
                    bra       L05E3

L05CB               deca                          Is it a WT.FSWin (scroll barred window=2)?
                    bne       L05D3               No, has to be Shadowed,double or plain, skip ahead
                    dec       ,s                  decrement X size by 1 for right scroll bar
                    bra       L05DD               skip ahead

* Shadowed, double & plain go here - 1 char border on all 4 sides
L05D3               inc       2,s                 add 1 to X start for left border
                    dec       ,s                  decrement X size by 2 for left & right borders
                    dec       ,s
L05DD               inc       3,s                 add 1 to Y start for menu bar
                    dec       1,s                 decrement Y size by 2 for menu & bottom borders
                    dec       1,s
                    ENDC

L05E3               ldd       Wt.SZX,y            get current X/Y sizes
                    cmpa      ,s                  will X size fit?
                    bhi       L0606               no return error
                    cmpb      1,s                 will Y size fit?
                    bhi       L0606               no, return error
                    ldd       Wt.CPX,y            get current X/Y start
                    cmpa      2,s                 will X start fit?
                    bcs       L0606               no, return error
                    cmpb      3,s                 will Y start fit?
                    blo       L0606               no, return error
                    lbsr      L00F7               let grfdrv do the rest
                    bcs       L0606               error from grfdrv, return
                    leas      8,s                 eat local data
                    puls      y,u                 Get back path dsc. ptr & device mem ptr
                    lbra      L0436               setup lines per page

L0606               leas      4,s                 Eat stack buffer & return
L0609               equ       *
                    IFNE      H6309
                    puls      d                   Restore originals
                    pulsw
                    stq       Wt.CPX,y
                    ELSE
                    ldd       2,s
                    std       Wt.CPX+2,y
                    std       >GrfMem+gr00B5
                    ldd       ,s
                    std       Wt.CPX,y
                    leas      4,s                 eat the stack
                    ENDC
                    comb                          Illegal coordinates error
                    ldb       #E$ICoord
                    puls      y,u,pc

****************************
* GCSet entry point
* Entry: U=Static mem pointer
*        Y=path descriptor pointer
*        X=Parameter pointer
L060C               pshs      u                   save static mem pointer
                    lbsr      L06A0               verify window exists, or create it if it isn't
                    lbcs      L069B               couldn't create, exit with error
                    ldd       ,x                  get group/buffer from parameters
                    std       >GrfMem+gr0057      Save in Grfdrv mem
                    lbsr      L00F7               let grfdrv do the rest
                    puls      u                   restore static mem pointer
                    lbsr      L06B9               get graphics table pointer
                    lda       Wt.GBlk,y           Get graphics cursor memory block #
                    sta       Gt.GBlk,x           save it in graphics table
                    ldd       Wt.GOff,y           Get graphics cursor offset
                    std       Gt.GOff,x           save it in graphics table & return
                    rts

****************************
* LSet entry point
LSet                equ       *
                    IFNE      H6309
                    bsr       L06A0               verify window table
                    bcs       L069D               no good, return error
                    ELSE
                    lbsr      L06A0
                    bcs       L069D               no good, return error
                    ENDC
                    lda       ,x                  Get LSET type from params
                    sta       Wt.LSet,y           store it in window table
                    lbra      L00F7               let grfdrv do the rest

****************************
* Border entry point
Border              pshs      u                   preserve static mem
                    bsr       L06A0               verify window table
                    bcs       L069B               not good, return error
                    lda       ,x                  Get border color from parm area
                    ldx       Wt.STbl,y           Get screen table ptr
                    sta       St.Brdr,x           Save as border color in screen tbl
                    bra       L0669               Flag for GIME update & exit

****************************
* FColor/BColor entry point
BColor
FColor              bsr       L06A0               verify window table
                    bcs       L069D               not good, return error
                    lda       ,x                  Get palette # from param area
                    sta       >GrfMem+gr005A      Put in GRFDRV's working palette #
L064B               lbra      L00F7               Go into GrfDrv

****************************
* DefPal entry point
DefPal              pshs      u                   preserve static mem pointer
                    bsr       L06A0               verify window
                    bcs       L069B               not good, return error
                    ldx       Wt.STbl,y           Get ptr to screen table
                    leax      St.Pals,x           Point to palettes in screen table
                    IFNE      H6309
                    ldd       >WGlobal+G.DefPal   Get ptr to system default palettes
                    ldw       #16                 # palette registers to copy
                    tfm       d+,x+               Copy into screen table
                    ELSE
* 6809 LCB NOTE: Change to use grfdrv copy vector later. Or at least use U to transfer
* 2 bytes at a time. U is restored in L0669, so we can use it freely here
                    pshs      y
                    ldy       >WGlobal+G.DefPal   Get ptr to system default palettes
                    ldb       #8                  16 bytes to transfer
L064Eb              ldu       ,y++
                    stu       ,x++
                    decb
                    bne       L064Eb
* Since we are about to exit CoWin anyways, no need to preserve W
*         clra
*         std   >GrfMem+gr00B5
                    puls      y
                    ENDC
                    bra       L0669               Flag for GIME update & exit

****************************
* Palette entry point
Palette             pshs      u                   preserve static mem pointer
                    bsr       L06A0               verify window table
                    bcs       L069B               not good, return error
                    ldd       ,x                  Get palette # & color
                    ldx       Wt.STbl,y           Get screen table ptr
                    anda      #$0f                Only allow palettes 0-15
                    adda      #St.Pals            Palette tbl starts @ +$10
                    stb       a,x                 Save in scrn tbl's palette
L0669               clrb                          No error
                    puls      u                   restore static mem pointer
                    lda       >WGlobal+G.CrDvFl   Are we the current device?
                    beq       L0673               No, we are done
                    inc       V.ScrChg,u          Yes, flag AltIRQ for screen update & return
L0673               rts

****************************
* PSet/Font entry point
Font
PSet                bsr       L06A0               verify window table
                    bcs       L069D               not good, return error
                    ldd       ,x                  Get group & buffer #'s from parm area
                    beq       L0682               If caller wants to disable pattern set, skip
                    tstb                          Is buffer=0?
                    lbeq      L0812               Yes, illegal
L0682               std       >GrfMem+gr0057      Save group & buffer #'s
                    lbra      L00F7               Go to GrfDrv

****************************
* KillBuf entry point
KillBuf             bsr       L06A0               verify window table
                    bcs       L069D               not good, return error
                    ldd       ,x                  Get buffer & group #
                    bra       L0682               Save them

* Return undefined window error
L069B               leas      2,s                 Eat stack
L069D               ldb       #E$WUndef           Window undefined error
                    rts

* Get window table pointer & verify it
* Entry: X=parm ptr
*        Y=Path dsc. ptr
*        U=Device mem ptr
* Exit: Y=Window tbl ptr
*       X=Parm ptr
L06A0               ldb       V.WinNum,u          Get window # from device mem
                    lda       #Wt.Siz             Size of each entry
                    mul                           Calculate window table offset
                    addd      #WinBase            Point to specific window table entry
                    IFNE      H6309
                    tfr       d,w                 Move to W (has indexing mode)
                    lda       Wt.STbl,w           Get MSB of scrn tbl ptr
                    ELSE
* Can't use DP scratch var since need flags preserved
                    pshs      y
                    tfr       d,y
                    std       >GrfMem+gr00B5
                    lda       Wt.STbl,y
                    puls      y
                    ENDC
                    bgt       VerExit             If $01-$7f, should be ok
                    cmpa      #$ff                Unused?
                    bne       L0697               No, in range of $80-$FE or $00, illegal
                    IFNE      H6309
                    pshsw     Preserve            window tbl ptr
                    pshs      x                   Preserve param ptr
                    tfr       y,x                 Move path dsc. ptr to X
                    tfr       w,y                 Move window tbl ptr to Y
                    ELSE
                    pshs      x,y
                    ldx       >GrfMem+gr00B5
                    stx       2,s                 pshsw
                    exg       y,x                 tfr y,x; tfr w,y
                    ENDC
                    bsr       L06DD               Window doesn't exist, see if we can create
                    puls      x,y,pc              Get parm ptr, window tbl ptr & return

* X still parm ptr, just move window tbl ptr & return
VerExit             clra                          No error
                    IFNE      H6309
                    tfr       w,y                 Move window tbl ptr to Y
                    ELSE
                    ldy       >GrfMem+gr00B5
                    ENDC
                    rts

* Return illegal window definition error
L0697               comb                          set carry
                    ldb       #E$IWDef            Illegal window definition error
                    rts

* Get window table ptr for current window
* Entry: U=Static memory pointer
* Exit : Y=Window tbl ptr
L06AE               ldb       V.WinNum,u          Get window # from device mem
                    lda       #Wt.Siz             Size of each entry
                    mul                           Calculate window table offset
                    addd      #WinBase            Point to specific window tbl entry
                    tfr       d,y                 Put into Y & return
                    rts

* Get graphics table pointer for current window
* Entry: U=Static memory pointer
L06B9               pshs      d                   Preserve D
                    lda       V.WinNum,u          Get window #
                    ldb       #GTabSz             Size of each entry
                    mul                           Calculate offset
                    ldx       >WGlobal+G.GfxTbl   Get ptr to GFX tables
                    IFNE      H6309
                    addr      d,x                 Point to table entry
                    ELSE
                    leax      d,x                 Point to table entry
                    ENDC
                    puls      d,pc                Restore D & return

* Verify window table
* Entry: Y=Window table ptr
* Unused window, check if device dsc. default is valid
L06DD               pshs      x                   Preserve path dsc ptr
                    ldx       PD.DEV,x            Get device table ptr
                    pshs      x                   Preserve it
                    ldx       V$DESC,x            Get device dsc ptr
                    ldb       IT.VAL,x            Window dsc contain a valid type?
                    bne       L06EE               Yes, skip ahead
                    coma                          Otherwise, exit with error
L06EB               leas      4,s                 Eat stack & return
                    rts

* Unused window with valid device dsc type
* X=Ptr to window's device dsc.
L06EE               lda       IT.STY,x            Get descriptor's screen type
                    lbsr      L07E0               Go get GrfDrv internal screen type
                    bcc       L06FA               Good window type found, continue
                    leas      4,s                 Eat stack & exit with error
                    bra       L0697

* Valid screen type
L06FA               stb       >GrfMem+Gr.STYMk    Preserve GrfDrv window type
                    cmpb      #$FF                Current screen?
                    beq       L070B               Yes, skip ahead
                    lda       IT.BDC,x            Get default border color
                    sta       >GrfMem+gr005A      Put into palette area in grfdrv mem
                    bra       L070F

* If window is supposed to be on same screen, do this
L070B               pshs      x                   preserve device descriptor pointer
                    ldx       4,s                 get path descriptor pointer
                    bsr       L075C               Set up screen table ptr in window table
                    puls      x                   restore device descriptor pointer
                    bcs       L06EB               If error, eat stack & leave

L070F               ldd       IT.CPX,x            Get start X coordinate from dsc
                    IFNE      H6309
                    ldw       IT.COL,x
                    stq       Wt.CPX,y            Put into window table
                    ELSE
                    std       Wt.CPX,y
                    ldd       IT.COL,x
                    std       >GrfMem+gr00B5
                    std       Wt.CPX+2,y
                    ENDC
                    ldd       IT.FGC,x            Get foreground & background default colors
                    std       Wt.Fore,y           Save in window table
                    ldb       #$04                GrfDrv function: DWSet
                    lbsr      L0101               Go make the window
                    puls      x                   Get device dsc. ptr back
                    bcc       L0730               no error, skip ahead
                    ldd       #$FFFF              Error, Reset window table entry as 'unused'
                    std       Wt.STbl,y
                    leas      2,s                 Eat stack & return
L075B               rts

* Last part of DWSet
L0730               ldx       V$STAT,x            Get device's static mem ptr
                    inc       V.InfVld,x          Set flag indicating rest of table is valid
                    leau      ,x                  Point U to static storage
                    tfr       y,d                 Move window table ptr to D
                    puls      y                   Get path dsc. ptr back into Y
                    pshs      d                   Save window table ptr on stack
                    lbsr      L0436               Set up some default size values
                    puls      y                   Get window table ptr back
                    tst       >WGlobal+G.CrDvFl   Are we current device?
                    beq       L075B               No, skip ahead
                    IFNE      H6309
                    ldw       >WGlobal+G.CurDev   Get current device's static mem ptr
                    stw       >WGlobal+G.PrWMPt   Move to old device's static mem ptr
                    lda       >V.ULCase,w         Get old device's special keyboard flags
                    ELSE
* 6809 - use DP scratch var here instead of pshs/puls x. LCB
                    pshs      x
                    ldx       >WGlobal+G.CurDev   Get current device's static mem ptr
                    stx       >WGlobal+G.PrWMPt   Move to old device's static mem ptr
                    stx       >GrfMem+gr00B5
                    lda       >V.ULCase,x         Get old device's special keyboard flags
                    puls      x
                    ENDC
                    sta       V.ULCase,x          Save in new device (kybrd mouse in Gshell)
                    stx       >WGlobal+G.CurDev   Make it the current device's static mem ptr
                    lbra      L0C86               Select the window & do setmouse in VTIO

* If current screen window, go here
* Entry: A=Screen type from caller
*        B=Internal screen type
*        X=Path descriptor ptr
*        Y=Window table ptr
* Exit: Screen table ptr in window dsc. table is set
L075C               cmpa      #$FF                Current displayed screen?
                    bne       L076D               No, must be process' current screen
                    ldd       >GrfMem+gr0030      Get current screen table ptr
                    bne       L076A               There is one, continue
                    comb                          Otherwise, window undefined error
                    lbra      L069D

L076A               std       Wt.STbl,y           Store screen table ptr in window table & return
                    rts

* Verify that current process window is compatible with current window
* Entry: X=Path descriptor pointer
*        Y=Window table pointer of current window
L076D               pshs      x,y                 Preserve window table ptr & path dsc. ptr
                    ldx       <D.Proc             Get current process dsc. ptr
                    ldb       P$SelP,x            Get selected path for current window
                    lbsr      L0592               Get device table ptr for the path (into Y)
                    ldx       ,s                  Get back path dsc. ptr
                    ldx       PD.DEV,x            Get device table entry address
                    ldd       V$DRIV,x            drivers match?
                    cmpd      V$DRIV,y
                    bne       L07AB               No, they aren't compatible, exit with error
                    ldy       V$STAT,y            Get device driver static storage ptr
                    lda       V.TYPE,y            Get device type
                    bpl       L07AB               not a window, exit with error
                    lda       V.WinType,y         Get type of window flag
                    bne       L07AB               If not a Grf/CoWin window, error
                    lda       V.InfVld,y          Get 'device mem info is valid' flag
                    beq       L07AB               If clear, error
                    leau      ,y                  Point U to static mem
                    lbsr      L06AE               Get window table ptr for process window
                    lda       Wt.STbl,y           screen table active?
                    bmi       L07AB               no, exit with illegal window def. error
                    leas      2,s                 Eat window device dsc. ptr
                    ldd       Wt.STbl,y           Get screen table ptr of process window
                    puls      y                   Get window tbl ptr
                    std       Wt.STbl,y           Put into current window's screen tbl ptr
                    clra                          No error & return
                    rts

L07AB               puls      y,x                 Restore regs & illegal window definition error
                    lbra      L0697

* Search for empty window table & setup window links
* Entry: U=Device static mem ptr
* Exit : Y=New window table pointer
L07B0               pshs      d,x                 Save regs used
                    leay      ,u                  Point to device static storage
                    ldx       #WinBase            swap it into X for ABX
                    ldd       #Wt.Siz             A=Start entry #(0), B=Entry size
                    IFNE      H6309
L07B8               ldw       Wt.STbl,x           get screen table pointer
                    ELSE
* Can't use scratch var since need flags preserved
L07B8               pshs      y
                    ldy       Wt.STbl,x
                    sty       >GrfMem+gr00B5
                    puls      y
                    ENDC
                    bpl       L07CF               if high bit clear, table used, skip to next
                    IFNE      H6309
                    cmpf      #$FF                if LSB not a $ff, then check next one
                    ELSE
* Can't use scratch var since need flags preserved
                    pshs      b
                    ldb       >GrfMem+gr00B5+1
                    cmpb      #$FF
                    puls      b
                    ENDC
                    bne       L07CF
* Found empty entry, link it in & make current device (static mem) point to
* new table entry
                    ldb       V.WinNum,y          Get current window table #
                    stb       Wt.BLnk,x           Save it as back link #
                    sta       V.WinNum,y          Save new window table entry #
                    dec       Wt.STbl+1,x         make LSB of screen table ptr $fe
                    tfr       x,y                 move window table pointer to Y
                    clrb                          Clear carry
                    puls      d,x,pc              Restore & return

L07CF               inca                          Move to next table #
                    cmpa      #$20                Past max table #?
                    bhi       L07D9               Yes, exit with error
                    abx                           Nope, point to next one
                    bra       L07B8               Go try again

* BUG @ approx L1789, it calls this routine, but does NOT check for a window
* table full error... it just stores Y assuming it worked.
L07D9               tfr       x,y                 move window table pointer to Y
                    comb                          Set carry
                    ldb       #E$TblFul           Get table full error code
                    stb       1,s                 Save it in B on stack for restore
                    puls      d,x,pc              Restore & return

* Convert STY mark to internal type
* Entry: A=Requested screen type from parameters
* Exit : B=Internal screen type marker
L07E0               pshs      a,y                 Preserve sty & window entry
                    inca                          Bump up so $FF type is now 0
                    cmpa      #9                  Past maximum allowable?
                    bhi       L07F5               Yes, exit with error
                    leay      <L07F9,pc           Point to conversion table (base 0)
                    ldb       a,y                 Get internal code
                    cmpb      #$FE                Invalid?
                    beq       L07F5               Yes, exit
                    clra                          Clear carry
                    puls      a,y,pc              Restore & return

L07F5               comb                          Set carry
                    puls      y,a,pc              Restore regs & return

* Screen type conversion table
L07F9               fcb       $ff                 Current screen, sty=$ff
                    fcb       $ff                 Current screen, sty=$00
                    fcb       $86                 40 column, sty=$01
                    fcb       $85                 80 column, sty=$02
                    fcb       $fe                 Invalid, sty=$03
                    fcb       $fe                 Invalid, sty=$04
                    fcb       $01                 640 2 color, sty=$05
                    fcb       $02                 320 4 color, sty=$06
                    fcb       $03                 640 4 color, sty=$07
                    fcb       $04                 320 16 color, sty=$08

BadDef              comb
                    ldb       #E$IllArg
                    rts

****************************
* DefGPB entry point
* Entry: U=Static memory pointer
*        Y=Path descriptor pointer
*        X=Parameter pointer
DefGPB              lbsr      L06A0               verify window table
                    lbcs      L069D               not good, return error
                    IFNE      H6309
                    ldq       ,x                  D=Group/Buffer W=Length
                    ELSE
                    ldd       2,x
                    std       >GrfMem+gr00B5
                    ldd       ,x
                    ENDC
                    tsta                          group a zero?
                    beq       L0812               yes, illegal return error
                    cmpa      #$FF                Trying to use overlay group?
                    bne       L0816               no, go on
* Return bad buffer error
L0812               comb                          set carry
                    ldb       #E$BadBuf           get error code
                    rts                           return to caller

* check buffer #
L0816               tstb                          buffer a zero?
                    beq       L0812               yes, illegal return error
                    IFNE      H6309
                    tstw                          length a zero?
                    ELSE
* Can't use scratch var since need flags preserved
                    pshs      d
                    ldd       >GrfMem+gr00B5
                    puls      d
                    ENDC
                    beq       BadDef              yes, return error
                    std       >GrfMem+gr0057      save group/buffer #'s in global mem
                    IFNE      H6309
                    stw       >GrfMem+gr0080      save length in global mem
                    ELSE
* 6809 LCB - *Might* be able to use scratch DP var instead of pshs/puls D.
                    pshs      d
                    ldd       >GrfMem+gr00B5
                    std       >GrfMem+gr0080      save length in global mem
                    puls      d
                    ENDC
L0822               lbra      L00F7               let grfdrv do the rest

****************************
* GetBlk entry point
* Entry: U=Static memory pointer
*        Y=Path descriptor pointer
*        X=Parameter pointer
GetBlk              lbsr      L06A0               verify window table
                    lbcs      L069D               couldn't get it, return error
                    bsr       L0849               check group/buffer #'s & move upper left coords
                    bcs       L0812               error, return bad buffer
                    bsr       L085C               get X/Y sizes
                    lbcc      L00F7               let grfdrv do the rest if no error
SmlBuf              ldb       #E$BufSiz           get error code & return
                    rts

****************************
* PutBlk entry point
PutBlk              lbsr      L06A0               verify window table
                    lbcs      L069D               exit if error
                    bsr       L0849               get parameters
                    bcs       L0812               exit if error
                    lbra      L00F7               let grfdrv do rest

* Check passed Group & buffer parameters and move start co-ordinates
L0849               ldd       ,x++                get group/buffer #'s
                    tsta                          group a zero?
                    beq       L086E               yes, return error
                    cmpa      #$FF                trying to use overlay?
                    beq       L086E               yes, return error
                    tstb                          buffer a zero?
                    beq       L086E               yes, return error
                    std       >GrfMem+gr0057      save group/buffer to global memory
                    lbsr      L0A32               move start coords
                    clra                          clear error & return
                    rts

* Parse passed X/Y sizes & move if ok
* Entry: X=Parameter pointer
* Exit : X - Incremented by 4
                    IFNE      H6309
L085C               ldq       ,x                  D=X Size, W=Y size
                    tstd                          X size a zero?
                    ELSE
L085C               ldd       2,x
                    std       >GrfMem+gr00B5
                    ldd       ,x
                    ENDC
                    beq       L086E               yes, return error
                    IFNE      H6309
                    tstw                          Y size a zero?
                    ELSE
                    ldd       2,x
                    ENDC
                    beq       L086E               yes, return error
                    IFNE      H6309
                    stq       >GrfMem+gr004F      save sizes into grfdrv mem
                    ELSE
                    std       >GrfMem+gr004F+2    save sizes into grfdrv mem
                    ldd       ,x
                    std       >GrfMem+gr004F      save sizes into grfdrv mem
                    ENDC
                    ldb       #4                  adjust parameter pointer
                    abx
L086C               clra                          clear errors & return
                    rts

L086E               coma                          Flag error & return
                    rts

****************************
* GPLoad entry point
* Entry: U=Static memory pointer
*        Y=Path descriptor pointer
*        X=Parameter pointer
GPLoad              pshs      u,y                 save regs
                    lbsr      L06AE               get window table pointer for this window
                    ldd       ,x++                get group & buffer
                    tsta                          group a zero?
                    beq       L087D               yes, return error
                    cmpa      #$FF                Overlay window group?
                    bne       L0881               no, so far so good
L087D               puls      u,y                 Yes, not allowed for user group, purge stack
                    IFNE      H6309
                    bra       L0812               return error
                    ELSE
                    lbra      L0812
                    ENDC

* parse buffer & screen type parameters
L0881               tstb                          buffer a zero?
                    beq       L087D               yes, return error
                    std       >GrfMem+gr0057      save it in grfdrv mem.
                    lda       ,x+                 get screen type
                    lbsr      L07E0               convert it to internal screen type
                    tstb                          is it a graphics screen?
                    bpl       L0894               yes, skip ahead
                    puls      u,y                 restore regs
                    lbra      L0697               return illegal window definition error

* parse X/Y size & buffer size parameters
L0894               stb       >GrfMem+Gr.STYMk    save screen type
                    bsr       L085C               get X/Y sizes
                    bcc       GdSiz               no error, skip ahead
                    leas      4,s                 eat stack
                    bra       SmlBuf              return error

GdSiz               ldd       ,x++                get size of buffer
                    std       Wt.BLen,y           save it in window table as a counter
                    pshs      y                   preserve global mem & window table pointer
                    lbsr      L00F7               let grfdrv do some work
                    puls      y                   restore pointers
                    bcs       L08CA               error from grfdrv, eat stack & return
* get buffer count grfdrv made & start the move process
L08A8               ldd       Wt.BLen,y           get buffer counter
                    cmpd      #gb0000             more than 72 bytes (get/put copy buffer size) left?
                    bhi       L08CD               yes, go to multiple block copy routine
* last gpload buffer move
                    stb       >WGlobal+g0070      save LSB of count
                    tfr       b,a                 copy count to A
                    leax      <L08BE,pc           get vector to buffer move processor
L08B9               puls      u,y                 restore static mem & path descriptor pointers
                    lbra      L0362               save into parameter area of static mem.

* last buffer move parameter processor
L08BE               pshs      u,y                 preserve static mem & path descriptor pointers
                    lbsr      L06AE               get window table pointer
                    bsr       L08EA               Move data to shared buffer & then Grfdrv
L08CA               leas      4,s                 purge stack
                    rts                           return

* multi gpload buffer move
L08CD               subd      #gb0000             subtract 72 (gp copy buffer size) from count
                    std       Wt.BLen,y           save count
                    lda       #gb0000             72
                    sta       >WGlobal+g0070
                    leax      <L08DD,pc           get vector
                    bra       L08B9               save into parameter area of static mem.

* Place VTIO comes to for next gpload sub-buffer
L08DD               pshs      u,y                 Preserve static & path dsc. ptrs
                    lbsr      L06AE               Get window tbl ptr
                    bsr       L08EA               Move data to shared buffer & then Grfdrv
                    bcc       L08A8               Continue moving until whole GPLoad done
                    bra       L08CA               Error from Grfdrv, exit with it

* Move buffer to global area for GrfDrv
L08EA               ldu       #GPBuf              $1200 Point to global move area
                    IFNE      H6309
                    ldf       >WGlobal+g0070      get byte count
                    clre
                    tfm       x+,u+               move it
                    ELSE
                    pshs      a
                    ldb       >WGlobal+g0070      get byte count
L08EAb              lda       ,x+
                    sta       ,u+
                    decb
                    bne       L08EAb
                    clra
                    std       >GrfMem+gr00B5
                    puls      a
                    ENDC
* Send move buffer to GrfDrv
* Special problem. Seems to pass info via regF.
L08FC               equ       *
                    IFNE      H6309
                    ldf       >WGlobal+g0070      get count
                    ELSE
                    ldb       >WGlobal+g0070
*         stb   >GrfMem+$B6    grfdrv regF
                    stb       >GrfMem+gr00B5+1    cowin regF
                    ENDC
                    ldb       #$32                get move buffer code
                    lbra      L0101               send it to grfdrv & return from there

****************************
* PutGC entry point
PutGC               lbsr      L06A0               verify window
                    lbcs      L069D
                    IFNE      H6309
                    ldq       ,x                  get position requested
                    stq       >GrfMem+gr005B      save in grfdrv mem
                    ELSE
                    ldd       2,x
                    std       >GrfMem+gr005B+2    save in grfdrv mem
                    std       >GrfMem+gr00B5
                    ldd       ,x
                    std       >GrfMem+gr005B      save in grfdrv mem
                    ENDC
                    lbra      L00F7               go do it

****************************
* SetDPtr entry point
SetDPtr             pshs      x,u                 preserve static mem & param pointers
                    lbsr      L06A0               Verify/Create window
                    bcc       L092A               Got window, continue
L0925               puls      x,u                 Restore regs & exit with error
                    lbra      L069D

L092A               pshs      y                   save window table pointer
                    bsr       L098D               Get graphics table ptr into y
                    IFNE      H6309
                    ldq       ,x                  get co-ordinates from parameters
                    stq       Gt.GXCur,y          put co-ordinates into graphics table
                    ELSE
                    ldd       2,x
                    std       Gt.GXCur+2,y        put co-ordinates into graphics table
                    std       >GrfMem+gr00B5
                    ldd       ,x
                    std       Gt.GXCur,y          put co-ordinates into graphics table
                    ENDC
L0934               puls      y
                    leas      4,s
                    clrb
                    rts

****************************
* RSetDPtr
RSetDPtr            pshs      u,x
                    lbsr      L06A0               Verify/create window
                    bcs       L0925
                    pshs      y
                    bsr       L098D               Get graphics table ptr into y
                    IFNE      H6309
                    ldq       ,x                  Get graphics cursor coords
                    addd      Gt.GXCur,y          Add to graphics cursor coords
                    addw      Gt.GYCur,y
                    stq       Gt.GXCur,y          Save update cursor coords
                    ELSE
                    ldd       2,x
                    addd      Gt.GYCur,y
                    std       Gt.GXCur+2,y
                    std       >GrfMem+gr00B5
                    ldd       ,x
                    addd      Gt.GXCur,y
                    std       Gt.GXCur,y
                    ENDC
                    bra       L0934

****************************
* Point entry point
Point               pshs      u,x
                    lbsr      L06A0
                    bcs       L0925
                    pshs      y
                    bsr       L098D
                    lbsr      L0A32
L0961               puls      y
                    leas      4,s
                    lbra      L00F7

****************************
* RPoint entry point
RPoint              pshs      u,x
                    lbsr      L06A0
                    bcs       L0925
                    pshs      y
                    bsr       L098D
                    IFNE      H6309
                    ldq       ,x                  Get coord offsets
                    addd      Gt.GXCur,y          Add to X
                    addw      Gt.GYCur,y          Add to Y
                    stq       >GrfMem+gr0047      Save in GRFDRV mem
                    ELSE
                    ldd       2,x
                    addd      Gt.GYCur,y
                    std       >GrfMem+gr0047+2
                    std       >GrfMem+gr00B5
                    ldd       ,x
                    addd      Gt.GXCur,y
                    std       >GrfMem+gr0047
                    ENDC
                    bra       L0961

****************************
* Line/Box/Bar entry point
Line
Bar
Box                 pshs      u,x
                    lbsr      L06A0
                    bcs       L0925
L0984               pshs      y
                    bsr       L098D
                    lbsr      L0A51
L098B               bra       L0961

* Get graphics table pointer into Y
L098D               ldu       6,s                 get static mem pointer
                    lbsr      L06B9               get graphics table pointer
                    leay      ,x                  Move it to Y
                    ldx       4,s                 get parameter pointer
                    rts                           return

****************************
* RLine/RBox/RBar entry point
* Entry: U=Static memory pointer
*        Y=Path descriptor pointer
*        X=Parameter pointer
RLine
RBox
RBar                pshs      u,x                 save static & parameter pointers
                    lbsr      L06A0               get window table pointer
                    IFNE      H6309
                    bcs       L0925
                    ELSE
                    lbcs      L0925
                    ENDC
L09A3               pshs      y                   preserve window table pointer
                    bsr       L098D               get graphics table pointer
                    lbsr      L0A5E
                    bra       L0961

****************************
* LineM entry point
LineM               pshs      u,x
                    lbsr      L06A0
                    lbcs      L0925
                    pshs      y
                    bsr       L098D
                    IFNE      H6309
                    bsr       L0A51
                    ELSE
                    lbsr      L0A51
                    ENDC

L09BC               equ       *
                    IFNE      H6309
                    ldq       >GrfMem+gr004B
                    stq       Gt.GXCur,y
                    ELSE
                    ldd       >GrfMem+gr004B+2
                    std       Gt.GXCur+2,y
                    std       >GrfMem+gr00B5
                    ldd       >GrfMem+gr004B
                    std       Gt.GXCur,y
                    ENDC
                    bra       L0961

****************************
* RLineM entry point
RLineM              pshs      u,x
                    lbsr      L06A0
                    lbcs      L0925
                    pshs      y
                    bsr       L098D
                    IFNE      H6309
                    bsr       L0A5E
                    ELSE
                    lbsr      L0A5E
                    ENDC
                    bra       L09BC

* Filled Circle/Ellipse entry point
Filled              lda       #1                  Filled flag
                    sta       >GrfMem+gr00B2      Save flag
                    bra       FlagSet             skip ahead

* FFill/Circle/Ellipse/Arc entry point
Circle
Ellipse
Arc
FFill               clr       >GrfMem+gr00B2      Clear filled flag
FlagSet             pshs      u,x                 Preserve regs
                    lbsr      L06A0               verify window table
                    lbcs      L0925               error, return
                    pshs      y                   preserve window table pointer
                    ldu       4,s                 get device static mem pointer
                    ldb       V.CallCde,u         get grfdrv call #
                    pshs      b                   save it
                    lbsr      L06B9               get graphics table pointer
                    leay      ,x                  move it to Y
                    ldx       3,s                 get parameter pointer
                    IFNE      H6309
                    ldq       Gt.GXCur,y          Get Current graphics cursor coords from graphics table
                    stq       >GrfMem+gr0047      Save in GRFDRV mem
                    ELSE
                    ldd       Gt.GXCur+2,y        Get current graphics cursor Y coord from graphics table
                    std       >GrfMem+gr0047+2    Save in GRFDRV mem
                    ldd       Gt.GXCur,y          Get current graphics cursor X coord from graphics table
                    std       >GrfMem+gr0047      Save in GRFDRV mem
                    ENDC
                    puls      b                   restore callcode
                    cmpb      #$56                is it flood fill?
                    beq       L0A2D               yes, have all needed parms copied; let grfdrv do it
                    IFNE      H6309
                    ldw       ,x++                get X radius from parameters
                    stw       >GrfMem+gr0053      save it in grfdrv mem
                    ELSE
                    ldy       ,x++                get X radius from parameters
                    sty       >GrfMem+gr0053      save it in grfdrv mem
                    ENDC
                    cmpb      #$50                is it circle?
                    beq       L0A2D               yes, have all need parms copied; let grfdrv do it
                    IFNE      H6309
                    ldw       ,x++                get Y radius from parameters
                    stw       >GrfMem+gr0055      save it in grfdrv mem
                    ELSE
                    ldy       ,x++                get Y radius from parameters
                    sty       >GrfMem+gr0055      save it in grfdrv mem
                    ENDC
                    cmpb      #$52                is it ellipse?
                    beq       L0A2D               yes, have all need parms copied; let grfdrv do it
                    ldy       #GrfMem+gr0020      Move x1,y1-x2,y2 clip line coordinate parameters for ARC
                    IFNE      H6309
                    ldw       #8
                    tfm       x+,y+
                    ELSE
* 6809 - 50 cycles faster than original copy routine, same size LCB
                    pshs      u
                    ldb       #4
L0A2Db              ldu       ,x++
                    stu       ,y++
                    decb
                    bne       L0A2Db
                    puls      u
                    ENDC
L0A2D               lbra      L0961               let grfdrv do the rest (NOTE: L0961 immediately puls Y, then loads x/b)

* Move X/Y co-ordinates from parameters into GrfDrv memory
L0A32               equ       *
                    IFNE      H6309
                    ldq       ,x                  Get X/Y coords
                    stq       >GrfMem+gr0047      Save in GRFDRV mem
                    ELSE
                    ldd       2,x                 Get Y coord
                    std       >GrfMem+gr0047+2    Save in GRFDRV mem
                    ldd       ,x                  Get X coord
                    std       >GrfMem+gr0047      Save in GRFDRV mem
                    ENDC
                    ldb       #4                  Bump param ptr up
                    abx
                    rts

* Move current draw pointer co-ordinates from graphics table
* and destination co-ordinates from parameters into GrfDrv memory
* Entry: X=Parameter pointer
*        Y=Graphics table pointer
                    IFNE      H6309
L0A51               ldq       Gt.GXCur,y          Get X/Y graphics cursor coords from graphics table
                    stq       >GrfMem+gr0047      Save in GRFDRV mem
                    ldq       ,x                  Get X/Y coords from params
L0A59               stq       >GrfMem+gr004B      Save in GRFDRV mem
                    ELSE
L0A51               ldd       Gt.GXCur,y          Get X coord from graphics table
                    std       >GrfMem+gr0047      Save in GRFDRV mem
                    ldd       Gt.GXCur+2,y        Get Y coord from graphics table
                    std       >GrfMem+gr0047+2    Save in GRFDRV mem
                    ldd       2,x                 Get Y coord from params
* 6809 - should be able to optimize this. check external calls to L0A59 first.
                    std       >GrfMem+gr00B5      Save in "W" register copy
                    ldd       ,x                  Get X coord from params
L0A59               pshs      d                   Save on stack
                    ldd       >GrfMem+gr00B5      Get "W" register copy *Y coord)
                    std       >GrfMem+gr004B+2    Save in GRFDRV mem
                    puls      d                   Get X coord from parms back
                    std       >GrfMem+gr004B      Save in GRFDRV mem
                    ENDC
                    ldb       #4                  Bump param ptr past bytes we got
                    abx
                    rts

* Move current draw pointer co-ordinates from graphics table & calculate
* Destination draw pointer from parameters & move into GrfDrv memory
* Entry: X=Parameter pointer
*        Y=Graphics table pointer
                    IFNE      H6309
L0A5E               ldq       Gt.GXCur,y          Get coords from graphics table
                    stq       >GrfMem+gr0047      Save in GRFDRV mem
                    ldq       ,x                  Get X/Y coords from params
                    addd      Gt.GXCur,y          Make relative
                    addw      Gt.GYCur,y
                    ELSE
L0A5E               ldd       Gt.GXCur,y          Get X coord from graphics table
                    std       >GrfMem+gr0047      Save in GRFDRV mem
                    ldd       Gt.GXCur+2,y        Get Y coord from graphics table
                    std       >GrfMem+gr0047+2    Save in GRFDRV mem
                    ldd       2,x                 Get Y coord from parms
                    addd      Gt.GYCur,y          Add to current graphics cursor Y coord
                    std       >GrfMem+gr00B5      Save "W" temp
                    ldd       ,x                  Get X coord from params
                    addd      Gt.GXCur,y          Add to current graphics cursor X coord
                    ENDC
                    bra       L0A59               Save & bump param ptr

****************************
* Get status entry point
* Entry: A=Function call #
GetStt              cmpa      #SS.ScSiz           get screen size?
                    beq       L0A9A               yes, go process
                    cmpa      #SS.Palet           get palettes?
                    beq       L0AA7               yes, go process
                    cmpa      #SS.ScTyp           get screen type?
                    beq       L0AD5               yes, go process
                    cmpa      #SS.FBRgs           get colors?
                    lbeq      L0AF4               yes, go process
                    cmpa      #SS.DfPal           get default colors?
                    beq       L0AC3               yes, go process
                    IFNE      CoGrf-1
                    cmpa      #SS.MnSel           menu select?  (CoWin ONLY)
                    lbeq      L1515               yes, go process
                    ENDC
                    cmpa      #SS.ScInf           screen info?
                    beq       SS.SInf             yes, go process
                    lbra      L0A96               All others illegal

* SS.ScInf processor ($8F)
* New call to get info on current screen for use with direct mapped video
*  Programmer can even handle non-full sized window
*  Programmer will still have to get screen type to determine # bytes/line &
*  # of rows
* Returns: X=Offset into first block of screen start
*          A=# 8k blocks required for screen
*          B=Start block #
*          Y=High byte=X start of window
*            Low byte= X size of window
*          U=High byte=Y start of window
*            Low byte= Y size of window
* It should be noted that these are the current working area, not the original
*  window start/sizes

SS.SInf             bsr       L0ACB               get register & window table pointers
                    ldd       Wt.LStrt,y          get current screen logical start
                    suba      #$80                make it a offset into 1st block
                    std       R$X,x               save it to caller
                    IFNE      H6309
                    ldq       Wt.CPX,y            Get X&Y coord starts & X/Y sizes
                    exg       b,e                 Swap so registers easier for programmer
                    stq       R$Y,x               Save X values & Y values into callers Y & U
                    ELSE
                    ldd       Wt.CPX,y            Get upper left X/Y coord start for window
                    sta       R$Y,x               Save X start in high byte of Y
                    stb       R$U,x               Save Y start in high byte of U
                    ldd       Wt.SZX,y            Get X/Y sizes of window
                    sta       R$Y+1,x             Save X size in low byte of Y
                    stb       R$U+1,x             Save Y size in low byte of U
                    ENDC
                    ldd       [Wt.STbl,y]         get screen type & start block #
                    anda      #$0f                make it fit table (could anda #$07, I think, to make it safer)
                    leau      <NmBlks-1,pc        point to # blocks needed for screen type (-1 since base 1, not 0)
                    lda       a,u                 get # blocks
                    std       R$D,x               save it to caller
                    rts

NmBlks              fcb       2,2,4,4,1,1

* SS.ScSiz processing - Current size (with CWArea's in effect), not DWSet size
L0A9A               bsr       L0ACB               get register stack pointer & window table pointer
                    clra
                    ldb       Wt.SZX,y            get X size
                    std       R$X,x               save it to caller
                    ldb       Wt.SZY,y            get Y size
                    std       R$Y,x               save it to caller
                    clrb                          No error and return
                    rts

* SS.Palet processing
L0AA7               bsr       L0ACB               get register stack & window table pointers
                    ldy       Wt.STbl,y           get screen table pointer
                    leay      St.Pals,y           point to palettes
L0AAF               ldu       R$X,x               get callers buffer pointer
                    ldx       <D.Proc             get task # of caller
                    ldb       P$Task,x
                    ldx       <D.SysPrc           get task # of system
                    lda       P$Task,x
                    tfr       y,x
L0ABB               ldy       #16                 get # bytes to move
                    os9       F$Move              move 'em
                    rts                           return

* SS.DfPal processing
L0AC3               ldx       PD.RGS,y            get register stack pointer
                    ldy       >WGlobal+G.DefPal   get pointer to default palettes
                    bra       L0AAF               go move 'em

* Get register stack pointer into X, window table pointer into Y & global mem
L0ACB               ldx       PD.RGS,y            Get ptr to caller's register stack
                    lbsr      L06A0               Go find window table entry
                    lbcs      L069B               Error, exit
                    rts                           Return

* SS.ScTyp processing
L0AD5               bsr       L0ACB               get register stack & window table pointers
                    ldb       [Wt.STbl,y]         get screen type
                    bmi       L0AE2               text, skip ahead
                    addb      #$04                add 4 to make it a user screen type
                    bra       L0AEC               go save it

L0AE2               cmpb      #$86                40 column text?
                    bne       L0AEA               no, skip ahead
                    ldb       #$01                get screen type for 40 column text
                    bra       L0AEC               save it

L0AEA               ldb       #$02                get screen type for 80 column text
L0AEC               stb       R$A,x               save it to caller
                    clrb
                    rts

* Color mask for fore/back palette registers
L0AF0               fcb       %00000001           $01 2 color screens
                    fcb       %00000011           $03 4 color screens
                    fcb       %00001111           $0f 16 color screens
                    fcb       %00001111           $0f 16 color screens

* SS.FBRgs processing
L0AF4               bsr       L0ACB               get register stack & window table pointers
                    bsr       L0B01               Go get fore/back ground colors
                    std       R$D,x               Save in caller's D
                    ldb       St.Brdr,u           Get border register
                    clra                          D=border color
                    std       R$X,x               Save in caller's X & return
                    rts

L0B01               ldb       [Wt.STbl,y]         Get screen type from screen table
                    andb      #$07                Mask off text mode, etc.
                    lsrb                          Divide by 2 (for similiar screens)
                    leau      <L0AF0,pc           Point to masking table
                    ldb       b,u                 Get table entry
                    tfr       b,a                 Dupe for background color too
                    IFNE      H6309
                    andd      Wt.Fore,y           Mask with fore/bckground colors from window tbl
                    ELSE
                    anda      Wt.Fore,y
                    andb      Wt.Fore+1,y
                    ENDC
                    ldu       Wt.STbl,y           Get screen table ptr for border reg
                    rts

****************************
* Set status entry point
* Entry: U=Static memory pointer
*        Y=Path descriptor pointer
*        A=SetStat call #
SetStt              cmpa      #SS.Open            Open window call (for /W)
                    beq       L0B4B
                    cmpa      #SS.MpGPB           Map Get/Put buffer into callers program space
                    lbeq      L0BD1
                    cmpa      #SS.DfPal           Set default palettes
                    beq       L0B38
                    IFNE      CoGrf-1
* Remaining SetStat's are CoWin ONLY
                    cmpa      #SS.WnSet
                    lbeq      L0D23
                    cmpa      #SS.SBar
                    lbeq      L1AB9
                    cmpa      #SS.UMBar           Update menu bar
                    lbeq      L13F5
                    ENDC
                    lbra      L0A96               Unknown SetStat, return with error

* SS.DfPal entry point
L0B38               ldx       PD.RGS,y            get register stack pointer
                    ldx       R$X,x               get pointer to palettes
                    ldu       <D.Proc             get task # of caller
                    lda       P$Task,u
                    ldu       <D.SysPrc           get task # of system
                    ldb       P$Task,u
                    ldu       >WGlobal+G.DefPal   get pointer to destination of palettes
                    lbra      L0ABB               move 'em

* SS.Open processor
* Entry: X=Register stack pointer
*        U=Static memory pointer
*        Y=Path descriptor pointer
L0B4B               pshs      u,y                 preserve registers
                    ldx       PD.DEV,y            get pointer to device table entry
                    ldx       V$DESC,x            get pointer to descriptor
                    ldb       IT.WND,x            get window # from descriptor
                    bpl       L0BCD               not a legal window descriptor, return
                    pshs      x                   save device descriptor pointer
L0B58               equ       *
                    IFNE      H6309
                    clrd                          start window #=0
                    ELSE
                    clra
                    clrb
                    ENDC
                    lbsr      L025B               find a free window in bit map
                    bcc       L0B65               got one, skip ahead
                    puls      u,y,x               purge stack
                    comb                          set carry
                    ldb       #E$MNF              get module not found error
                    rts                           return

* Found a free window
L0B65               pshs      b                   save window # of free entry
                    lbsr      L024A               allocate the window we found
                    ldy       #$1200              Point to a buffer area (GPLoad area)
                    ldb       #'w                 get window name prefix
                    stb       ,y+                 put it in buffer
                    ldb       ,s                  get window # that was free
* Convert window # in B to ASCII equivalent with high bit set
                    IFNE      H6309
                    divd      #10                 divide it by 10
                    ELSE
                    lda       #-1
L0B87b              inca
                    subb      #10
                    bcc       L0B87b
                    addb      #10
                    exg       a,b
                    tstb
                    ENDC
                    beq       L0B87               if answer is 0 there is only 1 digit, skip ahead
                    orb       #$30                make first digit ASCII
                    stb       ,y+                 put it in buffer
L0B87               ora       #$B0                make remainder ASCII with high bit set
                    sta       ,y+                 put it in buffer
L0B92               leas      -2,s                make a buffer for process decriptor pointer
                    lbsr      L0238               switch to system process descriptor
                    ldx       #$1200              Point to calculated dsc. name
                    lda       #Devic+Objct        get module type
                    os9       F$Link              try & link it
                    lbsr      L0244               switch back to current process
                    leas      2,s                 purge stack
                    bcc       L0BAB               it's linked, skip ahead
L0BA7               leas      1,s                 purge window #
                    bra       L0B58               go look for another one

* Got a device descriptor, put into device table & save window # into static
L0BAB               lda       IT.PAR,u            valid window?
                    bpl       L0BA7               no, go look for another one
                    ldy       3,s                 get path descriptor pointer
                    ldx       PD.DEV,y            get pointer to device table
                    stu       V$DESC,x            save pointer to descriptor into it
                    ldb       ,s                  get window #
                    ldu       5,s                 get static mem pointer
                    stb       V.DWNum,u           save window # as active window in static mem
                    ldu       1,s                 get pointer to descriptor
                    os9       F$UnLink            unlink it from system map
                    ldu       5,s                 get static mem pointer
                    leas      7,s                 purge stack
                    rts                           Return with or without error

L0BCD               clrb                          No error
                    puls      u,y,pc              Restore regs & return

* SS.MpGPB (map get/put buffer)
* Parameters: X=Group/Buffer #'s
*             Y=Map/Un-Map flag, 0=Un-Map, 1+=Map
* Returns   : X=Start address of buffer in 64k user map
*             Y=Length of buffer
* Entry: U=Static memory pointer
*        Y=Path descriptor pointer
L0BD1               ldx       PD.RGS,y            get register stack pointer
                    pshs      x                   preserve it
                    lbsr      L06A0               verify window table
                    ldd       R$X,x               get group/buffer #'s
                    std       >GrfMem+gr0057      save it to grfdrv mem
                    ldb       #$38                get grfdrv function call to map
                    lbsr      L0101               let grfdrv calculate block # & count
                    ldb       >GrfMem+gr0097      get block #
                    lda       >GrfMem+gr0099      get # blocks long
                    puls      x                   Get register stack ptr back
                    tst       R$Y+1,x             mapping or un-mapping?
                    beq       L0C1F               un-map, remove it from process space
* Map the get/put buffer into process space
                    pshs      d,x,u               save block #/# of blocks, reg stack & global
                    bsr       L0C31               Make sure all blocks needed are there
                    bcc       L0C1B               Yes, exit
                    clra
                    ldb       1,s                 get starting block #
                    tfr       d,x
                    ldb       ,s                  get # blocks
                    os9       F$MapBlk            map blocks into process space
                    stb       1,s                 save error code if any
                    bcs       L0C19               return if there was a error
                    tfr       u,d                 copy start address to D
                    ldx       2,s                 get register stack pointer
                    addd      >GrfMem+gr009D      add in offset to buffer
                    std       R$X,x               save offset into block of buffer
                    ldd       >GrfMem+gr009B      get length of buffer
                    std       R$Y,x               save it into callers Y
L0C19               puls      d,x,u,pc            restore regs & return

L0C1B               leas      2,s                 purge stack
                    puls      pc,u,x

* Remove get/put buffer from process space
L0C1F               pshs      a,x,y               preserve # blocks, register stack & window table
                    bsr       L0C31               Go verify all blocks are correct & contiguous
                    bcs       L0C2E               Nope, exit with error
                    IFNE      H6309
                    lde       ,s                  Get counter back
                    ELSE
                    lda       ,s                  Get counter back
                    sta       >GrfMem+gr00B5      Save "E" copy
                    ENDC
                    ldd       #DAT.Free           Empty DAT marker
L0C28               std       ,x++                Save them in DAT image
                    IFNE      H6309
                    dece                          Keep marking unused blocks until done
                    ELSE
                    dec       >GrfMem+gr00B5
                    ENDC
                    bne       L0C28
L0C2E               puls      a,x,y,pc            Restore regs & return

* Verify blocks in process DAT image
* Entry: A=# blocks in GP buffer
*        B=Start block #
*        X=Caller's register stack ptr
* Exit:  A=block #*16 in DAT image
                    IFNE      H6309
L0C31               tfr       a,e                 copy start block
                    ldf       #8                  get # DAT slots
                    ELSE
L0C31               pshs      b
                    ldb       #8                  get # of DAT slots
                    std       >GrfMem+gr00B5      Save # of blocks in GP buffer & # DAT slots
                    puls      b
                    ENDC
                    ldx       <D.Proc             get current process pointer
                    leax      P$DATImg+16,x       point to end of DAT image
                    IFNE      H6309
                    addr      e,b                 Add # blocks to start block #
                    ELSE
                    addb      >GrfMem+gr00B5
                    ENDC
                    clra                          Clear high byte of D
                    decb                          Adjust for zero based
L0C40               cmpd      ,--x                Same block as DAT image?
                    beq       L0C4B               yes, skip ahead
                    IFNE      H6309
                    decf                          No, dec block counter
                    ELSE
                    dec       >GrfMem+gr00B5+1
                    ENDC
                    bne       L0C40               Do until all 8 blocks are checked
L0C62               comb                          Exit with boundary (bad page address) error
                    ldb       #E$BPAddr
                    rts

L0C4B               equ       *
                    IFNE      H6309
                    decf                          Dec block # counter
                    dece                          Dec # blocks in buffer counter
                    ELSE
                    dec       >GrfMem+gr00B5+1
                    dec       >GrfMem+gr00B5
                    ENDC
                    beq       L0C58               Do until GP blocks are checked
                    decb                          Dec block #
                    cmpb      ,--x                Same as previous one in DAT image
                    beq       L0C4B               Yes, keep going
                    bra       L0C62               No, exit with bad page address error

                    IFNE      H6309
L0C58               tfr       f,a                 Move block # within DAT to proper reg
                    ELSE
L0C58               lda       >GrfMem+gr00B5+1    Move block # within DAT to proper reg
                    ENDC
                    lsla                          Multiply x 16
                    lsla
                    lsla
                    lsla
                    clrb
L0CF1               rts                           return

******************************
* Special windowing processor (called from AltIRQ in VTIO)
* Entry: A=$00 - Screen has changed in some way (needs to update GIME hardware - palettes, mode,etc.)
*          $01 - Update mouse packet window region (Pt.Stat)
*          $02 - Update text & graphics cursor
*          $03 - Update auto follow mouse
L0C68               tsta                          Screen change?
                    beq       L0C7F               Yes, go do
                    deca                          Update mouse packet?
* TODO: Does update mouse packet go in CoGrf? LCB - Yes, it was in CoGrf.
                    IFNE      CoGrf-1
                    lbeq      L1CC8               Yes, go do
                    ENDC
                    deca                          Update cursors?
                    beq       L0CE7               Yes, go do
* TODO: Does auto-follow mouse go in CoGrf? LCB - I think this was CoWin only.
                    IFNE      CoGrf-1
                    deca                          Update auto-follow mouse?
                    lbeq      L1B4D               Yes, go do
                    ENDC
                    lbra      L0A96               Unknown sub-function, return with Unknown Service error

* Active window has changed, update everything
L0C7F               lbsr      L06AE               Get window table pointer
                    ldd       Wt.STbl,y           Screen table active?
* NOTE: IS THIS THE WHITE SCREEN BUG???
                    bmi       L0CF1               No, return
* Check for de-activation of previous window
L0C86               clr       ,-s                 clear activate/deactivate flag
                    ldx       >WGlobal+G.PrWMPt   get previous window static mem pointer
                    cmpx      >WGlobal+G.CurDev   Same as current device?
                    beq       L0CB3               Yes, activate current window
                    inc       ,s                  flag de-activation of last used window
                    ldu       >WGlobal+G.PrWMPt   get previous device static mem pointer
                    beq       L0CB3               nothing there, skip ahead
                    pshs      y                   preserve new window table pointer
                    bsr       L0CF2               any overlay windows or frames?
                    IFNE      CoGrf-1
                    bcs       L0CA3               no, skip ahead
                    lbsr      L1034               set menu bar to in-active state
                    ENDC
L0CA3               lda       >WGlobal+g00BE      get new window table flag
                    bmi       L0CB1               not used, skip ahead
                    ldu       >WGlobal+G.PrWMPt   get previous device static mem pointer
                    sta       V.WinNum,u          save window table # into it
L0CB1               puls      y                   restore window table pointer
* Send select to grfdrv
L0CB3               ldb       #$10                Get select callcode
                    lbsr      L0101               Send it to grfdrv
                    ldu       >WGlobal+G.CurDev   Get current device static mem pointer
* Check for activation of current window
                    tst       ,s                  did we de-activate last used window?
                    beq       L0CE1               no, skip activate
                    pshs      y,u                 Preserve regs
                    bsr       L0CF2               any overlay or framed windows?
                    IFNE      CoGrf-1
                    bcs       L0CCA               no, skip ahead
                    lbsr      L13E9               set menu bar to active state
                    ENDC
L0CCA               ldu       >WGlobal+G.CurDev   get current device mem pointer
                    stu       >WGlobal+G.PrWMPt   save it as previous
                    puls      u,y                 Get Y & static mem ptr back for possible overlay
                    lda       >WGlobal+g00BE      get overlay window #
                    bmi       L0CE1               Wasn't an overlay, skip ahead
                    sta       V.WinNum,u          save it as current
L0CE1               leas      1,s                 purge stack
                    jmp       [>WGlobal+G.MsInit] initialize mouse & return

* Update text & mouse cursors
L0CE7               lbsr      L06A0               verify window table
                    bcs       L0CF1               not good, return error
L0CEC               ldb       #$46                get set window code
                    lbra      L0101               send it to grfdrv

* Checks for any overlay windows & framed or scroll barred windows
* Entry: U=Static mem pointer
* Exit : Carry set=No overlay windows & No framed/scroll barred window
*                  $BE in global mem will be $FF
*        Carry clear=There is 2 possibilitys here 1: Framed or scroll barred
*                    window or 2: Overlay window is present, $BE in global
*                    will contain the current window table # & $35 in static
*                    memory of current device will be switched to the
*                    parent window of the overlay
L0CF2               lda       #$FF                initialize new window table flag
                    sta       >WGlobal+g00BE
L0CFA               lbsr      L06AE               get window table pointer of this window
                    IFNE      CoGrf-1
                    lbsr      L0E34               framed or scroll barred window?
                    bcs       L0D06               no, skip ahead
                    rts
                    ENDC

* No framed or scroll barred window, check for overlay window
L0D06               lda       Wt.BLnk,y           is this a overlay window?
                    bmi       L0D20               no, return carry set
                    ldb       V.WinNum,u          get current window table #
                    tst       >WGlobal+g00BE      already have one?
                    bpl       L0D1B               yes, skip ahead
                    stb       >WGlobal+g00BE      save current window #
L0D1B               sta       V.WinNum,u          save back link as current window in static mem
                    bra       L0CFA               go check it out

L0D20               coma                          set carry & return
                    rts

                    IFNE      CoGrf-1
* SS.WnSet SetStt call processor
L0D23               lbsr      L1358               setup the graphics table entry
                    ldx       PD.RGS,y            get register stack pointer
                    ldb       R$Y+1,x             get requested window type
                    cmpb      #WT.PBox            past maximum?
                    lbhi      L0697               yes, return error
                    lslb                          adjust for 2 bytes/entry
                    leax      <L0D3C,pc           point to vector table
                    ldd       b,x                 get offset
                    jmp       d,x                 continue from there

L0D3C               fdb       L0F9A-L0D3C         No box
                    fdb       L0D48-L0D3C         Framed window
                    fdb       L0DE8-L0D3C         Framed scroll barred window
                    fdb       L0E68-L0D3C         shadowed window
                    fdb       L0EFC-L0D3C         double box
                    fdb       L0FF2-L0D3C         plain box

* Process framed window setstat
L0D48               lbsr      L0E04               is this an overlay window?
                    bcc       L0D55               no, skip ahead
                    tst       >WGlobal+G.CrDvFl   are we the active device?
                    beq       L0D55               No, skip ahead
                    lbsr      L0E13               de-activate parent window's menu bar
L0D55               lbsr      L115F               copy window table & check for graphics screen
                    lda       #WT.FWin            get window type
                    bsr       L0D80               get window descriptor & setup graphics table entry
                    bcc       L0D6A               went ok, skip ahead
* Error, re-draw parent window & return
L0D5E               pshs      cc,b                Preserve error
                    tst       >WGlobal+G.CrDvFl   Are we active device?
                    beq       L0D68               No, exit with error
                    lbsr      L0E4B               activate parent window's menu bar
L0D68               puls      cc,b,pc             Exit with error

* Window descriptor is good, print it according to active/in-active
L0D6A               tst       >WGlobal+G.CrDvFl   are we the active window?
                    beq       L0D74               no, skip ahead
                    lbsr      L13FA               print menu in active state
                    bra       L0D77               skip ahead

L0D74               lbsr      L1037               print menu in in-active state
L0D77               bcs       L0D7F               error on printing, return
                    lbra      L11F3               change window working size for frame & exit

* Setup graphics table entry with window type & check sizes
* Entry: A=Window type (Not related to grfdrv, cowin specific)
*        X=Graphics table entry pointer
*        Y=Path descriptor pointer
L0D80               leas      -WN.SIZ,s           make a buffer to preserve current window desc.
                    sta       ,x                  save window type
                    ldu       PD.RGS,y            get pointer to register stack
                    ldu       R$X,u               get pointer to window descriptor
                    stu       Gt.DPtr,x           save it in graphics table
                    IFNE      H6309
                    ldw       <D.Proc             get process ID of creator
                    lda       P$ID,w
                    sta       Gt.Proc,x           save it in graphics table
                    ste       Gt.PBlk,x           Save process block # into graphics table
                    ELSE
                    pshs      y
                    ldy       <D.Proc             get process ID of creator
                    sty       >GrfMem+gr00B5      Save "W" copy
                    lda       <D.Proc             Get process block #
                    sta       Gt.PBlk,x           ste  - Save process block # into graphics table
                    lda       P$ID,y              Get process ID # of creator
                    sta       Gt.Proc,x           Save in graphics table
                    puls      y
                    ENDC
                    leau      ,s                  point to buffer
                    pshs      x                   save graphics table pointer
                    ldx       >WGlobal+G.GfxTbl   get graphics table pointer
                    leax      >$0240,x            point to window descriptor buffer
                    IFNE      H6309
                    ldw       #WN.SIZ             Preserve window descriptor in stack buffer
                    tfm       x+,u+
                    ELSE
* 6809 - eventually use mini stack blast copy (34 byte copy)
                    pshs      d
                    ldb       #WN.SIZ             Copy from window descriptor buffer to temp stack copy
L0D80b              lda       ,x+
                    sta       ,u+
                    decb
                    bne       L0D80b
                    std       >GrfMem+gr00B5
                    puls      d
                    ENDC
                    ldx       ,s                  restore graphics table entry pointer
                    lbsr      L1371               get window descriptor from caller
                    ldy       >WGlobal+g00BB      Get ptr to work window table
                    leau      ,x                  point to window descriptor
                    puls      x                   restore graphics table entry pointer
* Check if window will fit
                    lda       Wt.SZX,y            get current X size from window table
                    cmpa      WN.XMIN,u           will it fit?
                    blo       L0DC0               no, clear entry & return
                    lda       Wt.SZY,y            get current Y size from window table
                    cmpa      WN.YMIN,u           will it fit?
                    bhs       L0DD6               yes, return
* Window descriptor won't fit on window, restore old & return
L0DC0               clr       Gt.WTyp,x           clear graphics table entry
                    ldu       >WGlobal+G.GfxTbl   get graphics table pointer
                    leau      >$0240,u            point to working buffer
                    IFNE      H6309
                    ldw       #WN.SIZ             Restore window descriptor from stack copy
                    tfm       s+,u+
                    ELSE
* 6809 - use Mini stack blast copy here, then leas WN.SIZ,s to eat temp stack copy when done
                    pshs      a                   Restore window descriptor from stack copy
                    lda       #WN.SIZ
L0DC0b              ldb       ,s+
                    stb       ,u+
                    deca
                    bne       L0DC0b
                    sta       >GrfMem+gr00B5
                    puls      a
                    ENDC
                    comb                          set carry
                    ldb       #E$ICoord           get illegal co-ordinates error
L0D7F               rts                           return

* Window table is good, return
L0DD6               leas      WN.SIZ,s            purge stack
                    lda       Gt.WTyp,x           get screen type
                    cmpa      #WT.FSWin           scroll barred?
                    lbeq      FSWin               yes, do 3D frame
                    lbra      L0FFC               draw 3D frame & return

* Process a framed scroll barred window
L0DE8               bsr       L0E04               is this a overlay window?
                    bcc       L0DF3               no, skip ahead
                    tst       >WGlobal+G.CrDvFl   current device?
                    beq       L0DF3               no, skip ahead
                    bsr       L0E13               de-activate menu bar on parent window
L0DF3               lbsr      L115F               setup window table & check if graphics screen
                    lda       #WT.FSWin           get code for scroll barred window
                    IFNE      H6309
                    bsr       L0D80               setup graphics table entry & check window desc.
                    ELSE
                    lbsr      L0D80
                    ENDC
                    lbcs      L0D5E               error, return
                    lbsr      L108C               go draw window
                    lbra      L0D6A               finish up by drawing menu bar & return

* Check if this is a overlay window
L0E04               pshs      y,u                 preserve regs
                    lbsr      L06AE               get window table pointer
                    coma                          set carry
                    lda       Wt.BLnk,y           any overlays?
                    bpl       L0E10               yes, return carry set
                    clra                          clear carry
L0E10               puls      y,u,pc              return

* Place parent window in a in-active state if it's a framed or scroll barred
* window.
L0E13               pshs      y,u                 preserve registers
                    lbsr      L06AE               get pointer to window table entry
                    lda       Wt.BLnk,y           get overlay window back link
                    ldu       2,s                 get static mem pointer
                    ldy       ,s                  get path descriptor pointer
                    ldb       V.WinNum,u          get current window #
                    pshs      b                   save it
                    sta       V.WinNum,u          make overlay back link current
                    bsr       L0E34               framed or scroll barred?
                    bcs       L0E2E               no, skip ahead
                    lbsr      L1034               set menu bar to inactive state
L0E2E               puls      b,y,u               restore
                    stb       V.WinNum,u          restore active window & return
                    rts

* Check whether current window has a framed or framed scrolled barred window
* Entry: U=Static mem pointer
* Exit:  CC: Carry set if window is scroll barred or framed
L0E34               pshs      a,x                 preserve registers
                    tst       V.TYPE,u            is this a window?
                    bpl       L0E48               no, return with carry
                    lbsr      L06B9               get graphics table pointer
                    lda       Gt.WTyp,x           get cowin screen type
                    beq       L0E48               if no box, return with carry set
                    cmpa      #WT.FSWin           scroll barred or framed?
                    bhi       L0E48               no, return carry set
                    clra                          return with carry clear
                    puls      a,x,pc

L0E48               coma                          return with carry set
                    puls      a,x,pc

* Place parent window in a active state if it's a framed or scroll barred
* window.
L0E4B               ldu       >WGlobal+g00B7      get static mem pointer
L0E51               lda       Wt.BLnk,y           get overlay window link
                    ldb       V.WinNum,u          get current window #
                    pshs      b,u                 save current window # & static mem
                    sta       V.WinNum,u          save back link as current
                    bsr       L0E34               framed or scroll barred?
                    bcs       L0E62               no, skip ahead
                    lbsr      L13F5               update menu bar
L0E62               puls      b,u                 restore static mem & current window #
                    stb       V.WinNum,u          restore static mem to current window & return
                    rts

* Process a shadowed window. NOTE: The "garbarge" pixels left in the lower left/upper right
*  corners are from clearing the window itself
L0E68               lbsr      L0FBB               update parent window if any
                    lbsr      L115F               check for graphic window
                    lda       #WT.SBox            save window type in graphics table entry
                    sta       Gt.WTyp,x
                    ldy       >WGlobal+g00BB      Get ptr to work window table
                    lbsr      L12BE               clear window
                    leax      <SBox1,pc           point to draw table for 640 wide screen
                    IFNE      H6309
                    tim       #$01,>WGlobal+g00BD 640 wide screen?
                    ELSE
                    lda       >WGlobal+g00BD      640 wide screen?
                    anda      #$01
                    ENDC
                    bne       L0E91               no, skip ahead
                    leax      <SBox2,pc           point to draw table for 320 wide screen
L0E91               lda       #$03                get # entrys in draw table
                    lbsr      DrawBar             draw window
                    lbsr      L11F3               change window to working size
                    clrb                          clear errors
                    rts                           return

* LCB - may want to tweak a tiny bit - I think it is drawing extra pixel on the upper
*   right and lower left corners (instead of leaving background). Will have to fiddle with
*   and see if it looks ok with varied fore/background colors
* Draw table for shadowed window on 640 wide screen
* Draw table for Light Grey Box
SBox1               fcb       WColor2             Light Grey
                    fdb       0                   Start X=0
                    fdb       0                   Start Y=0
                    fdb       -3                  End X=Width of window-3
                    fdb       -1                  End Y=Height of window-1
                    fcb       $4c                 Box function in GRFDRV

* Draw table for Dark Grey shadow on right side
                    fcb       WColor1             Color 1 (dark grey)
                    fdb       -2                  Start X=Width of window-2
                    fdb       2                   Start Y=2
                    fdb       $8000               End X=Width of window
                    fdb       $8000               End Y=Height of window
                    fcb       $4e                 Bar function in GRFDRV

* Draw table for Dark Grey shadow on bottom
                    fcb       WColor1             Color 1 (dark grey)
                    fdb       2                   Start X=2
                    fdb       $8000               Start Y=Height of window
                    fdb       $8000               End X=Width of window
                    fdb       $8000               End Y=Height of window
                    fcb       $4a                 Line function in GRFDRV

* Draw table for shadowed window on 320 wide screen
* Draw table for Light Grey Box
SBox2               fcb       WColor2             Light Grey
                    fdb       0                   Start X=0
                    fdb       0                   Start Y=0
                    fdb       -1                  End X=Width of window-1
                    fdb       -1                  End Y=Height of window-1
                    fcb       $4c                 Box function in GRFDRV

* Draw table for Dark Grey shadow on right side
                    fcb       WColor1             Color 1 (dark grey)
                    fdb       $8000               Start X=Width of window
                    fdb       2                   Start Y=2
                    fdb       $8000               End X=Width of window
                    fdb       $8000               End Y=Height of window
                    fcb       $4a                 Line function in GRFDRV

* Draw table for Dark Grey shadow on bottom
                    fcb       WColor1             Color 1 (dark grey)
                    fdb       2                   Start X=2
                    fdb       $8000               Start Y=Height of window
                    fdb       $8000               End X=Width of window
                    fdb       $8000               End Y=Height of window
                    fcb       $4a                 Line function in GRFDRV

* Process a double box window
L0EFC               bsr       L0FBB               update parent window if we have to
                    lbsr      L115F               if this comes back it's a graphic window
                    lda       #WT.DBox            get window type
                    sta       Gt.WTyp,x           save it into graphics table entry
                    ldy       >WGlobal+g00BB      Get ptr to work window table
                    lbsr      L12BE               clear window
                    bsr       L1257               set text co-ordinates to 0,0
                    leax      <DBox,pc            point to draw table
                    lda       #3                  get # entries
                    lbsr      DrawBar             go draw it
                    lbsr      L11F3               setup window working area & return
                    clrb
                    rts

* Draw table for double box window
* Outside Box
DBox                fcb       WColor1             Color 1 (dark grey)
                    fdb       $0000               Start X=0
                    fdb       $0000               Start Y=0
                    fdb       $8000               End X=Width of window
                    fdb       $8000               End Y=Height of window
                    fcb       $4c                 Box function in GRFDRV

* Doubled up inside box - next 2
                    fcb       WColor1             Color 1 (dark grey)
                    fdb       $0002               Start X=2
                    fdb       $0002               Start Y=2
                    fdb       -2                  End X=Width of window-2
                    fdb       -2                  End Y=Height of window-2
                    fcb       $4c                 Box function

                    fcb       WColor1             Color 1 (dark grey)
                    fdb       $0003               Start X=3
                    fdb       $0003               Start Y=3
                    fdb       -3                  End X=Width of window-3
                    fdb       -3                  End Y=Height of window-3
                    fcb       $4c                 Box function

* Process a no box window
L0F9A               bsr       L0FBB               update parent window if we have to
                    lbsr      L116C               copy window table to working buffer
                    clra                          Wt.NBox =0
                    sta       Gt.WTyp,x
                    ldy       >WGlobal+g00B9      get pointer to window table
                    clrb                          set start coord
                    std       Wt.CPX,y
                    ldd       Wt.DfSZX,y          get default size
                    pshs      u,y
                    lbsr      L1204               set default size
                    puls      u,y
                    lbra      L12BE               clear screen & return from there

* Check if we have to update a parent window
L0FBB               pshs      y,u                 preserve registers
                    lbsr      L0E04               we an overlay window?
                    bcc       L0FF0               no, return
                    lbsr      L06B9               get graphics table pointer
                    lda       Gt.WTyp,x           get cowin screen type
                    beq       L0FF0               it's a plain window, return
                    cmpa      #WT.FSWin           framed or scroll barred window?
                    bhi       L0FF0               no, return
                    tst       >WGlobal+G.CrDvFl   Are we the current active device?
                    beq       L0FF0               no, return
                    ldu       2,s                 get static memory pointer
                    lbsr      L06AE               get window table pointer
                    ldu       2,s                 get static memory pointer
                    lda       V.WinNum,u          get window #
                    pshs      a                   save it
                    lda       Wt.BLnk,y           get back window link
                    sta       V.WinNum,u          save it as current
                    lbsr      L0E34               get framed or scroll barred window flag for this one
                    puls      a                   restore window #
                    sta       V.WinNum,u          save it
                    bcs       L0FF0               if not a framed or scroll barred window, return
                    lbsr      L0E51               place parent window into a active state
L0FF0               puls      y,u,pc              restore & return

* Set current X/Y draw pointer to 0,0
L1257               equ       *
                    IFNE      H6309
                    clrd
                    clrw
                    stq       >GrfMem+gr0047      Save X&Y coords
                    ELSE
                    clra
                    clrb
                    std       >GrfMem+gr0047      Save X&Y coords
                    std       >GrfMem+gr0047+2
                    std       >GrfMem+gr00B5
                    ENDC
                    rts

* Process a plain box window
L0FF2               bsr       L0FBB               update parent window if we have to
                    lbsr      L115F               Copy window table & check for graphics screen
                    lda       #WT.PBox            Plain box window type
                    sta       Gt.WTyp,x
* Draw a frame around full window
L0FFC               ldy       >WGlobal+g00BB      Get ptr to work window table
                    lbsr      L12BE               clear window
                    bsr       L1257               set text co-ordinates to 0,0
                    IFNE      H6309
                    lde       Wt.Fore,y           get current foreground color mask to preserve
                    ELSE
                    lda       Wt.Fore,y           Get current foreground color mask to preserve
                    sta       >GrfMem+gr00B5
                    ENDC
*** IS THIS A BUG? A IS NOT USED BY GETCOLR - B IS. IT *RETURNS* A
                    lda       #1                  ??? I THINK THIS SHOULD BE A LDB INSTEAD? LCB
                    lbsr      GetColr             convert it to mask
                    sta       Wt.Fore,y
                    lbsr      L1013               calculate X size
                    std       >GrfMem+gr004B
                    lbsr      L100F               calculate Y size
                    lbsr      L122B               draw the box
                    IFNE      H6309
                    ste       Wt.Fore,y           Save foreground palette #
                    rts

                    ELSE
                    pshs      a
                    lda       >GrfMem+gr00B5
                    sta       Wt.Fore,y           Save foreground palette #
                    puls      a,pc
                    ENDC

                    IFNE      CoGrf-1
* Draw a 3D frame around window for scroll barred window
FSWin               ldy       >WGlobal+g00BB      Get ptr to work window table
                    lbsr      L12BE               clear window
                    bsr       L1257               set text co-ordinates to 0,0
                    pshs      x                   preserve graphics table pointer
                    lda       #11                 get # entries
                    leax      <FSWinTbl,pc        point to draw table
                    lbsr      DrawBar
                    puls      x,pc

* Draw table for 3D Frame around window
FSWinTbl            fcb       WColor2             left bar (light grey)
                    fdb       0                   From 0,8 to 7,bottom
                    fdb       8
                    fdb       7
                    fdb       $8000
                    fcb       $4e                 Bar command for GRFDRV

                    fcb       WColor2             bottom bar (light grey)
                    fdb       8                   From 8,(bottom-7) to (Right-8),bottom
                    fdb       -7
                    fdb       -8
                    fdb       $8000
                    fcb       $4e

                    fcb       WColor2             right bar (light grey)
                    fdb       -7
                    fdb       8
                    fdb       $8000
                    fdb       $8000
                    fcb       $4e

                    fcb       WColor3             left bar 3D look
                    fdb       0
                    fdb       8
                    fdb       7
                    fdb       8
                    fcb       $4a

                    fcb       WColor3             White - 0,8 to 0,bottom-1
                    fdb       0
                    fdb       8
                    fdb       0
                    fdb       -1
                    fcb       $4a

                    fcb       WColor1             Dark grey - 7,9 to 7,bottom-7
                    fdb       7
                    fdb       9
                    fdb       7
                    fdb       -7
                    fcb       $4a

* Bottom bar 3D look
                    fcb       WColor3             White
                    fdb       9                   From 9,(bottom-7) to (right-7),(bottom-7)
                    fdb       -7
                    fdb       -7
                    fdb       -7
                    fcb       $4a                 Line

                    fcb       WColor1             Dark grey
                    fdb       1                   From 1,(bottom-1) to Right,(bottom-1)
                    fdb       -1
                    fdb       $8000
                    fdb       -1
                    fcb       $4a                 Line

                    fcb       WColor3             right bar 3D look
                    fdb       -7                  right-7,8 to right,8
                    fdb       8
                    fdb       $8000
                    fdb       8
                    fcb       $4a

                    fcb       WColor3
                    fdb       -7                  left+7,9 to left+7,bottom-8
                    fdb       9
                    fdb       -7
                    fdb       -8
                    fcb       $4a

                    fcb       WColor1             Dark Grey
                    fdb       $8000               left,9 to right,bottom-1
                    fdb       9
                    fdb       $8000
                    fdb       -1
                    fcb       $4a

* Set Menu bar to in-active state by printing the window title
L1034               lbsr      L116C               setup work window table
L1037               lbsr      L1240               draw 3D bar
* Swap foreground/background colors
                    ldd       Wt.Fore,y           Get fore/background colors
                    sta       Wt.Back,y           Swap them
                    stb       Wt.Fore,y
                    lbsr      L1013               calculate X size in pixels
                    IFNE      H6309
                    decd      take                off 1 of X co-ordinate
                    ELSE
                    subd      #$0001
                    ENDC
                    lbsr      L1371               get window descriptor pointer
                    bne       L107A               Not valid dsc., exit
                    ldd       #$0100              Valid, get X/Y text start coord
                    lbsr      L128E               place in grfdrv mem
                    IFNE      H6309
                    aim       #^TChr,Wt.BSW,y     Turn on transparency
                    oim       #Prop,Wt.BSW,y      Turn on proportional spacing
                    ELSE
                    ldb       Wt.BSW,y
                    andb      #^TChr              Turn on transparency
                    orb       #Prop               Turn on proportional spacing
                    stb       Wt.BSW,y
                    ENDC
                    lbsr      L12A2               calculate string length of menu title
                    subb      #$02                subtract 2 to give 1 space on either side
                    cmpb      Wt.SZX,y            bigger than window?
                    bls       L1075               no, skip ahead
                    ldb       Wt.SZX,y            Use X size of window as length
                    lbra      L12AE               Print menu bar title & return from there

L1075               addb      #2                  get length back
                    lbra      L12AE               print menu bar title & return from there

L107A               rts                           return

* Draw a framed scroll barred window
L108C               ldy       >WGlobal+g00BB      Get ptr to work window table
                    IFNE      H6309
                    aim       #^TChr,Wt.BSW,y     Turn on transparency
                    ELSE
                    lda       Wt.BSW,y            Turn on transparency
                    anda      #^TChr
                    sta       Wt.BSW,y
                    ENDC
                    pshs      x                   Preserve old X
                    leas      -10,s               Make enough room for BS stack for R$X/Y
                    leax      ,s                  Point X to stack
                    IFNE      H6309
                    clrd                          get text co-ordinates
                    ELSE
                    clra
                    clrb
                    ENDC
                    std       R$X,x
                    std       R$Y,x
                    lbsr      DfltBar             Draw scroll bar markers
                    bsr       DrawArr             draw the 4 arrows
                    lda       #7                  Draw 3D shading stuff
                    leax      <ScBar,pc           point to draw table
                    lbsr      DrawBar
                    leas      10,s                Restore stack to normal
                    puls      x,pc                restore X

* Draw scroll bar arrows
* Entry: Y=Window table pointer
*        U=Global mem pointer
* Exit : A=$00
*        All other regs. preserved
DrawArr             lda       #4                  Get # arrows
                    pshs      x,a                 preserve X & arrow counter
                    leax      <ScArr,pc           point to table
NxtArr              ldd       ,x++                get group/buffer
                    std       >GrfMem+gr0057      save it to grfdrv mem
                    lbsr      CalXCord            calculate X start co-ordinate
                    std       >GrfMem+gr0047      save it in grfdrv mem.
                    lbsr      CalYCord            calculate Y start co-ordinate
                    std       >GrfMem+gr0049      save it in grfdrv mem
                    ldb       #$36                get grfdrv function code for PutBlk
* NOTE: SHOULDN'T NEED U PRESERVED
                    pshs      x,y,u               preserve regs
                    lbsr      L0101               let grfdrv do the rest
                    puls      x,y,u               restore regs
                    dec       ,s                  done?
                    bne       NxtArr              keep going till we're done
                    puls      a,x,pc

* Draw table for scroll barred window arrows
* This seems a major error in group number. $CE does not exist. RG
* LCB - It did, but wasn't included in the NitrOS9 repository for some reason.
* $CE was reserved for the 4 color/3D look (thus leaving the original 2
* color, 2D ones alone for backwards compatibility with other programs)
* and was included in /dd/sys/stdwnd. It is properly there in the EOU.
ScArr               fdb       $ce01               group/buffer for up arrow
                    fdb       -7
                    fdb       8

                    fdb       $ce02               group/buffer for down arrow
                    fdb       -7
                    fdb       -15

                    fdb       $ce03               group/buffer for left arrow
                    fdb       0
                    fdb       -7

                    fdb       $ce04               group/buffer for right arrow
                    fdb       -15
                    fdb       -7

* Draw table for for various lines on a scroll barred window
ScBar               fcb       WColor3             white line below up arrow
                    fdb       -7
                    fdb       16
                    fdb       $8000
                    fdb       16
                    fcb       $4a

                    fcb       WColor1             Dark gray line above down arrow
                    fdb       -7
                    fdb       -16
                    fdb       $8000
                    fdb       -16
                    fcb       $4a

                    fcb       WColor3             white line to the right of left arrow
                    fdb       8
                    fdb       -7
                    fdb       8
                    fdb       -1
                    fcb       $4a

                    fcb       WColor1             Dark gray line to the left of right arrow
                    fdb       -16
                    fdb       -7
                    fdb       -16
                    fdb       -1
                    fcb       $4a

                    fcb       WColor1             Dark gray line above left arrow
                    fdb       0
                    fdb       -8
                    fdb       7
                    fdb       -8
                    fcb       $4a

                    fcb       WColor3             white line to the right of right arrow
                    fdb       -7
                    fdb       -7
                    fdb       $8000
                    fdb       -7
                    fcb       $4a

                    fcb       WColor3             white line below the down arrow
                    fdb       -7
                    fdb       -7
                    fdb       -7
                    fdb       -1
                    fcb       $4a

                    ENDC

* Check if window is a graphic window
L115F               bsr       L116C               copy window table to work table
                    lda       >WGlobal+g00BD      Get current screen type
                    bpl       L116B               graphics, skip ahead
                    leas      2,s                 purge return address
                    comb                          Exit with Illegal Window type error
                    ldb       #E$IWTyp
L116B               rts

* Copy current window table into work table & set all default sizes in work
* table
L116C               pshs      y                   save path descriptor pointer
                    stu       >WGlobal+g00B7      save device static in global
                    sty       >WGlobal+g00C0      save path descriptor in global
                    lbsr      L06A0               verify window table
                    sty       >WGlobal+g00B9      save window table pointer
                    lda       [Wt.STbl,y]         get screen type
                    sta       >WGlobal+g00BD      save it in global
                    ldu       >WGlobal+g00B7      get static mem back
                    lbsr      L06B9               get graphics table pointer for this window
                    ldy       #WGlobal+G.WrkWTb+$10 Point to work window table
                    sty       >WGlobal+g00BB      save the pointer to work table
                    ldu       >WGlobal+g00B9      get pointer to current window table
                    IFNE      H6309
                    ldq       Wt.LStDf,u          get default logical start address & start X/Y co-ordinates
                    stq       Wt.LStrt,y          save it in window table as current values
                    ELSE
                    ldd       Wt.DfCPX,u          Get default X,Y coord start
                    std       Wt.CPX,y            Save in work window table as current X,Y coord start
* 6809 - Not needed, since Q was re-used below. Remove line
*         std   >GrfMem+gr00B5 Save "W" copy (may not be needed)
                    ldd       Wt.LStDf,u          Get screen logical start adress
                    std       Wt.LStrt,y          Save in work window table
                    ENDC
                    ldd       Wt.DfSZX,u          get default X/Y sizes
                    std       Wt.SZX,y            save as current working area
                    ldd       Wt.STbl,u           get screen table pointer
                    std       Wt.STbl,y           save it in new
                    lda       Wt.BLnk,u           get overlay window link
                    sta       Wt.BLnk,y           save it in new
                    ldd       Wt.Cur,u            get cursor address
                    std       Wt.Cur,y            save it
                    ldd       Wt.CurX,u           get X/Y coord of cursor
                    std       Wt.CurX,y           save it
                    IFNE      H6309
                    ldq       Wt.XBCnt,u          Get width of window in bytes, bytes wide per text char & bytes/text row
                    stq       Wt.XBCnt,y          save it in new window table
                    ELSE
                    ldd       Wt.BRow,u           Get # bytes/row
                    std       Wt.BRow,y           save it
* 6809 - likely not needed, but will need testing
                    std       >GrfMem+gr00B5      Save "W" copy (may not be needed)
                    ldd       Wt.XBCnt,u          Get width of window in bytes & bytes wide each text chr is
                    std       Wt.XBCnt,y          Save in new
                    ENDC
                    lda       Wt.FBlk,u           get block # for font
                    sta       Wt.FBlk,y           save it
                    ldd       Wt.FOff,u           get offset for font
                    std       Wt.FOff,y
                    clr       Wt.BSW,y            clear window switches
                    lbsr      L1337               set pattern to normal plot
                    lbsr      L1342               set logic type to nothing
                    ldb       Wt.DfSZX,u          get X size
                    lbsr      L1015               multiply by 8
                    std       Wt.MaxX,y           save max X coord
                    ldb       Wt.DfSZY,u          get Y size
                    lbsr      L1015               multiply by 8
                    std       Wt.MaxY,y           save max Y co-ordinate
                    ldd       Gt.FClr,x           get fore/back colors
                    std       Wt.Fore,y           save 'em
                    puls      y,pc                restore path descriptor ptr & return

* Change window size to leave a 1 character space on all 4 sides
L11F3               ldy       >WGlobal+g00B9      get current window table pointer
                    ldd       #$0101              set X/Y start co-ordinate
                    std       Wt.CPX,y            save it
                    ldd       Wt.DfSZX,y          get default X/Y sizes
L1200               subd      #$0202              Subtract 2 from both
L1204               std       Wt.SZX,y            save X/Y size
                    ldb       #$0E                get grfdrv function for CWArea
                    lbsr      L0101
                    bcs       L11F2
                    ldu       >WGlobal+g00B7      get static mem pointer
                    ldy       >WGlobal+g00C0      get path descriptor pointer
                    lbra      L0436               go setup lines per page & return

* NOTE: ALL OF THESE MAY NOT NEED U PRESERVED ANYMORE
* Draw a box
L122B               std       >GrfMem+gr004D
                    pshs      u,y,x
                    ldb       #$4C                get code for box
L1232               lbsr      L0101               Send code to grfdrv
                    puls      pc,u,y,x

* Draw a line
L1237               std       >GrfMem+gr004D      save current Y coord
L123A               pshs      u,y,x               preserve regs
                    ldb       #$4A                get grfdrv function for line
                    bra       L1232               send it to grfdrv

* Draw a bar with current color
L124E               std       >GrfMem+gr004D
                    pshs      u,y,x
                    ldb       #$4E                Code for Bar
                    bra       L1232               Send it to grfdrv

* Draw a 3D bar starting at 0,0 to 639,7 in current colors
L1240               ldy       >WGlobal+g00BB      Get ptr to work window table
                    pshs      x                   preserve X
                    leax      <TopBar,pc          point to draw table for top bar
                    lda       #4                  get entry count
                    bsr       DrawBar             draw the bar
                    puls      x,pc                restore & return

* Draw a graphic sequence that requires start & end co-ordinates
* If the co-ordinate in draw table is negative, This will calculate the
* co-ordinate based on the size of the window in pixels.
* Entry: A=Number of draw table entrys
*        X=Pointer to draw table
*        Y=Pointer to window table
*        U=Global mem pointer
DrawBar             ldb       Wt.Fore,y           get current color
                    pshs      d                   save it and entry count
DrawNxt             lda       ,x+                 get foreground color
                    bsr       GetColr             get color mask
                    sta       Wt.Fore,y           put it in window table
                    bsr       CalXCord            calculate X start co-ordinate
                    std       >GrfMem+gr0047      save it in grfdrv mem.
                    bsr       CalYCord            calculate Y start co-ordinate
                    std       >GrfMem+gr0049      save it in grfdrv mem
                    bsr       CalXCord            calculate X end co-ordinate
                    std       >GrfMem+gr004B      save it in grfdrv mem
                    bsr       CalYCord            calculate Y end co-ordinate
                    std       >GrfMem+gr004D      save it in grfdrv mem
                    ldb       ,x+                 get grfdrv function code
                    pshs      x,y,u               preserve regs
                    lbsr      L0101               let grfdrv do the rest
                    puls      x,y,u               restore regs
                    dec       ,s                  done?
                    bne       DrawNxt             keep going till we're done
                    puls      d                   restore current color & purge stack
                    stb       Wt.Fore,y           put it back in window table
L11F2               rts

* Calculate X coord based on the size of window
CalXCord            bsr       L1013               get window X size in pixels
                    bra       CalCord

* Calculate Y co-ordinate based on the size of window
CalYCord            bsr       L100F               get window Y size in pixels
CalCord             pshs      d                   preserve size
                    ldd       ,x++                get coord
                    bpl       PosCord             it's positive, return coord
                    cmpd      #$8000              use actual size?
                    bne       NegCord             no, skip ahead
                    clra                          clear MSB to zero D
NegCord             addd      ,s                  add it to the size (signed add!!)
PosCord             leas      2,s                 purge size from stack
                    rts                           return

* Get window Y size in pixels - NEED TO CHANGE TO ADJUST FOR 200 LINE ONLY
L100F               ldb       Wt.SZY,y            Get window Y size in chars
                    bra       L1015

* Get window X size in pixels
* Exit: D=window X size in pixels (or other X value if entered at L1015)
L1013               ldb       Wt.SZX,y            Get window X size in chars
L1015               clra                          Clear MSB
* NOTE: HOW OFTEN WILL WE GET A WINDOW SIZE OF ZERO? SHOULD CHANGE TO NOT
* BOTHER WITH EITHER TSTB OR BEQ (UNLESS CALLING ROUTINE CHECKS FLAG)
                    tstb                          0?
                    beq       L101E               Yes, don't bother with multiply
                    IFNE      H6309
                    lsld                          Multiply by 8
                    lsld
                    lsld
                    decd      0                   base
                    ELSE
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    subd      #$0001
                    ENDC
L101E               rts

* Get color mask
GetColr             pshs      b,x                 save color & table pointer
                    ldb       >WGlobal+g00BD      get screen type
                    leax      <ColrMsk-1,pc       point to color mask table (-1 since base 0)
                    ldb       b,x
                    mul
                    tfr       b,a
                    puls      b,x,pc              restore & return

ColrMsk             fcb       $ff,$55,$55,$11

* Draw table for top menu bar
TopBar              fcb       WColor2             Color 1 (light grey) - Draw Bar from 1,1 to (Right-1,6)
                    fdb       1                   (Changed from original 0,0-Right,7)
                    fdb       1
                    fdb       -1
                    fdb       6
                    fcb       $4e                 Grfdrv BAR function code

                    fcb       WColor3             Color 3-Draw Box from 0,0 to Right,7)
                    fdb       0
                    fdb       0
                    fdb       $8000
                    fdb       7
                    fcb       $4c                 Grfdrv BOX function code

                    fcb       WColor1             Dark grey
                    fdb       $0000               Start X co-ordinate
                    fdb       $0007               Start Y co-ordinate
                    fdb       $8000               End X
                    fdb       $0007               End Y
                    fcb       $4a                 Grfdrv LINE function code

                    fcb       WColor1             Dark Grey
                    fdb       $8000               Start X co-ordinate
                    fdb       $0000               Start Y co-ordinate
                    fdb       $8000               End X
                    fdb       $0007               End Y
                    fcb       $4a                 Grfdrv LINE function code

* Print close box
L127B               lda       #$C7                CHR$ for Close box symbol
* Generic routine for calling graphics font (font $c803) & resetting to normal
L1271               bsr       L12C2               Go select graphics font
                    bsr       L1285               Print char on screen
                    bra       L12D7               Revert to normal font, return from there.

* Print tandy menu icon
L127F               lda       #$CB                CHR$ for Tandy icon character
                    bra       L1271               Put on screen

* Print a space
L1283               lda       #C$SPAC             Space char
* Print a single character
* Entry: A=character to print
L1285               pshs      d,x,y,u
                    ldb       #$3A                Regular alpha put grfdrv
L1289               lbsr      L0101
                    puls      d,x,y,u,pc

* Set cursor co-ordinates
* Entry: A=X co-ordinate
*        B=Y co-ordinate
L128E               addd      #$2020              Set up for GRFDRV CurXY call
                    pshs      u,y,x
                    lbsr      L0380
                    puls      pc,u,y,x

L1299               bsr       L12A2               Calculate length of NUL terminated string @,X
                    cmpb      #15                 >15 chars?
                    bls       L12A1               No, return
                    ldb       #15                 Force to 15 chars
L12A1               rts

* Get length of a NULL terminated text string (not greater than 128)
* Entry: X=Pointer to string
* Exit : B=Length of string
L12A2               pshs      a                   preserve a
                    ldb       #-1                 Init count to -1 (loop entry will bump to 0)
L12A5               incb                          Bump char count up
                    lda       b,x                 Get char
                    bne       L12A5               Not end of string yet, keep looking
L12AC               puls      a,pc                restore a & return

* Print a string of specific length
* NOTE: ASSUMES LENGTH NEVER >128 CHARS! NOTE: Grfdrv's buffered write is limited to 32 bytes
* Entry: B=Length of string
*        X=Pointer to string
L12AE               pshs      d,x,y,u             Save regs
                    IFNE      H6309
                    clre
                    tfr       b,f                 W=String length
                    ldu       #$0180              Point to buffered write buffer
                    tfm       x+,u+               Copy to GRFDRV buffer
                    ELSE
* 6809 - Change to mini stack blast copy eventually
                    pshs      b
                    ldu       #$0180
L12AEb              lda       ,x+
                    sta       ,u+
                    decb
                    bne       L12AEb
                    clra
                    std       >GrfMem+gr00B5
                    puls      b
                    ENDC
                    ldu       #$0180              Point to buffered write buffer for GRFDRV
                    tfr       b,a                 Move size of buffer to A for GRFDRV
                    ldb       #$06                Buffered Write call code for GRFDRV
                    lbsr      L0101               Call GRFDRV
                    puls      d,x,y,u,pc          Restore regs & return

* Erase to end of line
L12B6               lda       #$04
L12B8               pshs      u,y,x,d
                    ldb       #$3C
                    bra       L1289

* Clear screen
L12BE               lda       #$0C
                    bra       L12B8

L12C2               pshs      u,y,x,d
                    ldx       >WGlobal+G.GfxTbl   Get graphics table ptr
                    leax      >$02B9,x            Offset into menu table ($240,x) + 121/$79 it???
                    lda       Grf.Bck,x           DOUBT THIS IS RIGHT
                    beq       L12E9
L12CF               sta       Wt.FBlk,y
                    ldd       Grf.Off,x
                    std       Wt.FOff,y
                    puls      pc,u,y,x,d

* Switch to text font
L12D7               pshs      u,y,x,d
                    ldx       >WGlobal+G.GfxTbl   Get graphics tables ptr
                    leax      >$02B6,x            Offset to ???
                    lda       Grf.Bck,x           Get ???
                    bne       L12CF               If non-0, copy 3 bytes back to original state
                    ldd       #$C827              Normal 8x8 text font (Actually, it's 8x8 size, but 8x7 in font data)
                    bra       L12EC               Call grfdrv to set font

* Switch to graphic font
L12E9               ldd       #$C803              Graphics font/buffer #
L12EC               pshs      u,y,x
                    std       >GrfMem+gr0057      Save in Grfdrv mem
                    ldb       #$18                Set font command
                    lbsr      L0101               Set font in grfdrv
                    puls      u,y,x
                    lda       Wt.FBlk,y           Copy stuff back (Font MMU block)
                    sta       Grf.Bck,x
                    ldd       Wt.FOff,y           (Offset into MMU block where font is)
                    std       Grf.Off,x
                    puls      pc,u,y,x,d          Restore & return

* Turn inverse on
L1329               pshs      u,y,x
                    ldd       #$2040              Inverse ON
L130D               lbsr      L0101               Go execute in grfdrv
                    puls      pc,u,y,x

* Turn inverse off
L1331               pshs      u,y,x
                    ldd       #$2140              Inverse off
                    bra       L130D

* Set pattern
L1337               pshs      u,y,x
                    IFNE      H6309
                    clrd
                    ELSE
                    clra
                    clrb
                    ENDC
                    std       >GrfMem+gr0057      Save in Grfdrv Mem
                    ldb       #$12
                    bra       L130D

* Set logic type to 0 (normal gfx)
L1342               pshs      u,y,x
* 6809/6309 - ldd #$001E is slightly faster on 6809, same on 6309
                    clra
                    sta       Wt.LSet,y
                    ldb       #$1E
                    bra       L130D

* Setup graphics table entry
L1358               pshs      d,x,y,u
                    lbsr      L06A0               verify window table
                    ldu       6,s                 get static memory pointer
                    lbsr      L06B9               get graphics table pointer
                    ldd       Wt.Fore,y           get current foreground/background colors
                    std       Gt.FClr,x           save it in graphics table
                    lbsr      L0B01               get mask value
                    std       Gt.FMsk,x           save it into graphics table
                    IFNE      H6309
                    clrd                          init pointer to window descriptor
                    ELSE
                    clra
                    clrb
                    ENDC
                    std       Gt.DPtr,x
                    puls      d,x,y,u,pc

* Copy a window descriptor from caller's process area
* Entry: None
L1371               pshs      d,y,u               preserve regs
                    bsr       L139E               is it the owner of the window?
                    bcs       L1397               no, return
                    ldx       Gt.DPtr,x           get pointer to window descriptor
                    leau      >$0240,u            point to a work buffer
                    ldy       #WN.SIZ             get size of descriptor
L1381               leas      -2,s                make a buffer for current process
                    lbsr      L0238               switch to system process
                    os9       F$CpyMem            copy the window descriptor from process space
                    lbsr      L0244               switch back to current process
                    leas      2,s                 purge stack
                    tfr       u,x                 move destination to X
                    ldd       WN.SYNC,x           get sync bytes
                    cmpd      #WINSYNC            set flags for compare
L1397               puls      d,y,u,pc            restore & return

* Entry:
* Exit : B=Offset to DAT image
L139B               lbsr      L06B9               get pointer to graphics table entry
L139E               ldu       >WGlobal+G.GfxTbl   get pointer to start of graphics table
                    ldy       <D.PrcDBT           get process descriptor block table pointer
                    ldb       Gt.Proc,x           get process number of owner
                    lda       b,y                 get process # of user
                    cmpa      Gt.PBlk,x           match?
                    bne       L13B1               no, set carry & return
                    ldb       #P$DATImg           get offset to DAT image into D
                    andcc     #^Carry             clear carry
L13B0               rts                           return

L13B1               orcc      #Carry              set carry
                    rts                           return

* Copy a menu descriptor from caller's process space
L13B5               pshs      u,y,d
                    pshs      x
                    bsr       L139B               Get DAT image offset to copy menu descriptor from
                    puls      x
                    bcs       L1397
                    leau      >$0262,u
                    ldy       #MN.SIZ
                    bra       L1381               Copy the memory

* Set the root window menu bar to active state (Called from VTIO special calls)
L13E9               lbsr      L116C               setup working window table
                    leas      -8,s                make a buffer
                    clr       2,s                 clear a flag?
                    lbsr      L1240               draw 3D bar
                    bra       L1404               go print it

* SS.UmBar enry point
L13F5               lbsr      L116C               setup working window table

* Called from SS.WnSet
L13FA               lbsr      L1240               draw a 3D bar
                    leas      -8,s
                    clr       2,s
                    ldy       >WGlobal+g00BB      Get ptr to work window table

* Print menu bar in active state
L1404               lbsr      L1329               turn inverse on
                    IFNE      H6309
                    aim       #^TChr,Wt.BSW,y     Turn on transparency
                    ELSE
                    pshs      a
                    lda       Wt.BSW,y
                    anda      #^TChr
                    sta       Wt.BSW,y
                    puls      a
                    ENDC
                    lbsr      L12D7               set to text font
                    IFNE      H6309
                    clrd                          x,y both to 0
                    ELSE
                    clra
                    clrb
                    ENDC
                    sta       5,s
                    lbsr      L128E               Set Text cursor to 0,0
                    ldb       Wt.SZX,y            get current window X size
                    subb      #2                  take off 2 for space on either side of text
                    stb       ,s                  save it
                    ldb       #2                  get current text size (just the spaces so far)
                    stb       1,s                 save it in buffer
                    lbsr      L1283               print leading space for menu
                    IFNE      H6309
                    aim       #^Bold,Wt.BSW,y     Turn off Bold print
                    ELSE
                    pshs      a
                    lda       Wt.BSW,y
                    anda      #^Bold
                    sta       Wt.BSW,y
                    puls      a
                    ENDC
                    lbsr      L127B               print close box
                    ldy       >WGlobal+G.GfxTbl   Get graphics table ptr
                    leay      >$028E,y            point to handling table
                    clr       MnuXNum,y           Menu entry number=0
                    lbsr      L1371               get window descriptor pointer
                    lbne      L14E3               valid?
                    lda       WN.NMNS,x           yes, get number of menus in menu bar
                    lbeq      L14E3               none to print, return
                    cmpa      #10                 more than 10?
                    lbhi      L14E3               yes, return
                    sta       4,s                 save count
                    ldx       WN.BAR,x            get pointer to menu descriptor
L144A               stx       6,s                 save menu descriptor pointer
                    pshs      u
                    ldu       >WGlobal+g00B7      get pointer to static mem
                    IFNE      H6309
                    bsr       L13B5               get menu descriptor
                    ELSE
                    lbsr      L13B5
                    ENDC
                    puls      u
                    ldy       >WGlobal+g00BB      Get ptr to work window table
                    lda       MN.ENBL,x           is menu enabled?
                    beq       L1466               no, skip ahead
                    IFNE      H6309
                    oim       #Bold,Wt.BSW,y      Turn on Bold print
                    ELSE
                    lda       Wt.BSW,y
                    ora       #Bold
                    sta       Wt.BSW,y
                    ENDC
                    bra       L1469               skip ahead

L1466               equ       *
                    IFNE      H6309
                    aim       #^Bold,Wt.BSW,y     Turn off Bold print
                    ELSE
                    lda       Wt.BSW,y
                    anda      #^Bold
                    sta       Wt.BSW,y
                    ENDC
L1469               lda       MN.ID,x             get ID number
                    cmpa      #MId.Tdy            is it tandy menu?
                    bne       L148D               no, skip ahead
* Print Tandy menu
* 6809/6309 note: Some of these multi char prints should be changed to use the FastChr multi-char
* Write that Alan added (like space/tandy/space below) to speed them up (like L12AE does for titles,
* etc.) as long as they are using 8x8 font
                    ldy       >WGlobal+g00BB      Get ptr to work window table
                    lbsr      L1283               print a space
                    lbsr      L127F               print the tandy character
                    lbsr      L1283               print a space
                    ldb       #1                  get this menu's length
                    stb       3,s                 save it
                    pshs      b
                    bsr       L14EE               add it into handling table
                    leas      1,s
                    ldb       ,s                  get window size
                    subb      #3                  take off length for tandy menu
                    stb       ,s                  save it back
                    bra       L14C6               go to next entry

* Print normal menu entry
L148D               leax      MN.TTL,x            point to text
                    lbsr      L1299               get length of it up to maximum of 15
                    stb       3,s                 save it
                    cmpb      ,s                  will it fit in window?
                    bls       L14A4               yes, skip ahead
                    ldb       ,s                  get window X size
                    subb      #1
                    bls       L14E3               no, return
                    inc       2,s                 flag only 1 space
* Print menu title text
L14A4               pshs      b                   save length of text
                    ldy       >WGlobal+g00BB      Get ptr to work window table
                    lbsr      L1283               print a space
                    lbsr      L12AE               print menu text
                    tst       3,s                 was there anything to print?
                    bne       L14B6               yes, skip ahead
                    lbsr      L1283               print a space
L14B6               bsr       L14EE               add menu to handling table
                    puls      a                   get length of menu text
                    adda      #2                  add 2 for space on each side
                    ldb       ,s                  get size
                    IFNE      H6309
                    subr      a,b                 subtract width from size left
                    ELSE
                    pshs      a
                    subb      ,s+
                    ENDC
                    stb       ,s                  save size left
* Move to next menu descriptor
L14C6               ldx       6,s                 get menu descriptor pointer
                    leax      MN.SIZ,x            point to next menu descriptor
                    inc       5,s                 add 1 to menu total
                    dec       4,s                 done all descriptors?
                    lbne      L144A               no, go print next one
L14E3               ldy       >WGlobal+g00BB      Get ptr to work window table
                    lbsr      L1331               turn inverse off
                    leas      8,s                 purge stack & return
                    rts

* Add menu entry to internal handling table.
* Entry: Stack buffer pre loaded
* This table is 4 bytes long for each entry and consists of:
*        $00 - Menu # (starts at 1)
*        $01 - X start co-ordinate
*        $02 - X End co-ordinate
*        $03 - Reserved as far as I can tell (possibly use for menu type
*              flag: 0=normal, 1="sticky", etc.)
L14EE               pshs      d,x
                    ldx       >WGlobal+G.GfxTbl   get pointer to special windowing table
                    leax      >$028E,x            point to menu handling table
                    ldb       12,s                get menu number
                    clra                          multiply it by 4 (size of handling table entries)
                    IFNE      H6309
                    lsld
                    lsld
                    addr      d,x                 add to handling table start
                    ELSE
                    lslb
                    rola
                    lslb
                    rola
                    leax      d,x                 add to handling table start
                    ENDC
                    ldb       12,s                get menu number
                    incb                          Bump up by 1
                    stb       MnuXNum,x           save menu number
                    ldb       8,s                 get X start coord
                    stb       MnuXStrt,x          save it
                    addb      10,s                add length
                    incb                          add 1 for space
                    stb       MnuXEnd,x           save end X coord
                    incb
                    stb       8,s
                    clr       MnuHSiz,x           make sure next entry is clear
                    puls      d,x,pc

* SS.MnSel entry point
* Buffer breakdown:
* $00-$01,s : Static mem ptr
* $02-$04,s : ???
* $05-$06,s : current mouse X position pixel coord within window
* $07-$08,s : current mouse Y position pixel coord within window
* $09-$0A,s : ???
* $0B,s     : calculated X text coord of some sort
* $0C,s     : calculated Y text coord of some sort
* $0D-$0E,s : window X end pixel coord
* $0F-$10,s : window Y end pixel coord
* $11-$12,s : ???
* $13,s     : Current mouse X text position coord
* $14-$16,s : ???
* $17,s     : ???
* $18-$19,s : Path descriptor ptr
* $1A-$20,s : ???
* $21,s     : Mouse signal process #
* $22,s     : ??? (Flag of some sort)
* $23,s     : ???
L1515               leas      <-$23,s             make a buffer
                    stu       ,s                  save static mem pointer
                    sty       $18,s               save path descriptor pointer
                    clr       $22,s               clear a flag
                    tst       >WGlobal+G.CrDvFl   Are we the current active device?
                    beq       L160A               No, return with nothing
                    ldx       #WGlobal+G.Mouse    Get ptr to mouse packet
                    clr       >WGlobal+G.WIBusy   flag cowin free
L1530               tst       Pt.CBSA,x           button A still down?
                    bne       L1530               yes, wait for release
                    inc       >WGlobal+G.WIBusy   flag cowin busy
                    lbsr      L06A0               verify window
                    lbsr      L1D24               copy current mouse coords to work cords.
                    leax      Pt.Siz,x            point to my work coords (hidden outside packet)
                    lbsr      L1C19               mouse on current window?
                    bcs       L160A               no, return with nothing
                    lbsr      L161B               calculate window start & end coords in pixels
                    ldd       7,s                 get current mouse Y coord?
                    cmpd      #7                  is it in the menu bar?
                    bhi       L158B               no, skip ahead
                    ldb       <$13,s              get current mouse text X coord
                    cmpb      #$01                past close box?
                    bgt       L155E               yes, skip ahead
                    lda       #MId.Cls            No, menu id=Close box
                    bra       L160C               return menu info

* It wasn't close box; scan menu handling table
L155E               ldx       >WGlobal+G.GfxTbl   get graphics table pointer
                    leax      >$028E,x            point to menu handling table
L1565               lda       MnuXNum,x           last entry?
                    beq       L160A               yes, return D=0
                    cmpb      MnuXEnd,x           within max X range?
                    bhi       L1587               no, point to next entry
                    lbsr      L16E6               process menu pulldown
                    pshs      a,u                 save menu ID & global mem ptr
                    ldu       0+3,s               get static mem pointer
                    lda       <$21+3,s            get mouse signal process #
                    sta       V.MSigID,u          save it in static mem
                    clr       >WGlobal+G.MsSig    Clear mouse signal flag
                    puls      a,u                 Restore menu id # & global mem ptr
                    bra       L160C               Return menu id # & entry # to caller

L1587               leax      MnuHSiz,x           move to next entry in handling table
                    bra       L1565               keep looking

* Return no menu information received
L160A               equ       *
                    IFNE      H6309
                    clrd                          Menu # & ID # =0
                    ELSE
                    clra                          Menu # & ID # =0
                    clrb
                    ENDC
                    bra       L160C

* Mouse wasn't on menu bar check scroll bars
* NOTE: SHOULD ADD SO THAT IF MOUSE CLICKED BETWEEN SCROLL BARS, IT WILL
*       RETURN THE POSITION (IN TEXT CHARS) ACROSS OR UP/DOWN WITHIN SCROLL
*       BAR AREA
L158B               pshs      u,y,x
                    ldu       0+6,s               get static mem pointer
                    lbsr      L06B9               get graphics table entry pointer
                    lda       ,x                  get window type
                    cmpa      #WT.FSWin           do we have scroll bars?
                    puls      u,y,x
                    bne       L160A               no, no need to check more return nothing
* Check for left scroll bar arrow
                    ldd       5,s                 get mouse X pixel coord
                    cmpd      #7                  X in range for left scroll bar arrow?
                    bhi       L15B0               no, check up arrow
                    ldd       $0F,s               Get window Y end pixel coord
                    subd      #7
                    cmpd      7,s                 Mouse Y pixel coord
                    bhi       L15B0
                    lda       #MId.SLt            get menu ID for left scroll bar arrow
* Return menu ID & item to caller
* Entry: A=Menu ID
*        B=Menu item #
*        Y=Path descriptor pointer
L160C               ldy       <$18,s              get path descriptor pointer
                    ldx       PD.RGS,y            get register stack pointer
                    std       R$D,x               save menu & item # back to caller
                    leas      <$23,s              Eat stack buffer
                    clrb                          No error & return
                    rts

* Check for up scroll bar arrow
L15B0               ldd       7,s                 get current mouse pixel Y coord
                    cmpd      #15                 in range of up arrow?
                    bhi       L15C6               no, check right arrow
                    ldd       $D,s                get window X pixel end coord
                    subd      #7                  subtract 7
                    cmpd      5,s                 mouse X coord in range?
                    bhi       L15C6               no, check right arrow
                    lda       #MId.SUp            get menu ID for scroll up arrow
                    bra       L160C               return with menu ID

* Check for right scroll bar arrow
L15C6               ldd       $0F,s               get window Y pixel end coord
                    subd      #7                  subtract 7
                    cmpd      7,s                 mouse in range for Y
                    bhi       L15E8               no, check down arrow
                    ldd       $0D,s               get window X end pixel coord
                    subd      #8                  subtract 8
                    cmpd      5,s                 mouse X pixel coord below maximum range?
                    blo       L15E8               no, check down arrow
                    ldd       $0D,s               Get window X end pixel coord again
                    subd      #15                 subtract 15 (2 char width)
                    cmpd      5,s                 Is current mouse X pixel coord in range?
                    bhi       L15E8               No, check down arrow
                    lda       #MId.SRt            get menu ID for right scroll arrow
                    bra       L160C               return with menu ID

* Check for down scroll bar arrow
L15E8               ldd       $0D,s               Get window X end pixel coord
                    subd      #$0007              subtract 7 (1 char width)
                    cmpd      5,s                 Is mouse X pixel coord in range?
                    bhi       L160A               No, not on scroll bars, so exit with D=0
                    ldd       $0F,s               Get window Y end pixel coord
                    subd      #$0008              Subtract 8 (1 char height)
                    cmpd      7,s                 Is current mouse Y pixel coord in range?
                    blo       L160A               No, not on scroll bars, so exit with D=0
                    ldd       $0F,s               Get window Y end pixel coord again
                    subd      #15                 Subtract 15 (2 char height)
                    cmpd      7,s                 Is current mouse Y pixel coord in range?
                    lbhi      L160A               No, not on scroll bars, so exit with D=0
                    lda       #MId.SDn            get menu ID for down scroll arrow
                    bra       L160C               save it to caller & return

* Calculate window start & end coords in pixels
L161B               equ       *
                    IFNE      H6309
                    clrd
                    ELSE
                    clra
                    clrb
                    ENDC
                    std       $0B+2,s             Init X/Y text coords to 0
                    pshs      d
                    bsr       L1667               calculate X/Y char coords into $B,s/$C,s
                    puls      d
                    ldb       Wt.DfCPX,y          get full window X start char coord
                    addb      $0B+2,s             add it to calculated X char coord
                    lbsr      L1015               D=size in pixels
                    IFNE      H6309
                    tfr       d,w                 copy it to W
                    ldd       ,x                  get mouse X co-ordinate
                    subr      w,d                 calculate relative coord in window
                    ELSE
                    std       >GrfMem+gr00B5      Save X size in pixels
                    ldd       ,x                  get mouse X co-ordinate
                    subd      >GrfMem+gr00B5      calculate relative coord in window
                    ENDC
                    std       5+2,s               save it on stack
                    bsr       L1027               divide it by 8
                    stb       <$13+2,s            save it as mouse text X coord
                    ldb       Wt.DfCPY,y          get window default Y start coord
                    addb      $0C+2,s             add calculated X text coord
                    lbsr      L1015               calculate window height in pixels
                    IFNE      H6309
                    ldw       $02,x               get mouse Y coord
                    subr      d,w                 calculate relative Y coord within window
                    stw       7+2,s               save it
                    ELSE
* 6809/6309 - should be able to optimize this - Y pixel coord always has high byte=0
* Could use CLRA and eliminate pshs/pulsing A then.
                    pshs      d,dp                Save D, and reserve 1 extra byte on stack
                    sta       2,s                 Save 0 on stack
                    ldd       2,x                 get mouse Y coord
                    subd      ,s++                calculate relative Y coord within window
                    std       7+3,s               Save it
* 6809/6309 - following line likely not needed
                    std       >GrfMem+gr00B5
                    puls      a                   Restore 0 from stack
                    ENDC
                    ldb       Wt.DfCPX,y          get window default text X start coord
                    addb      $0B+2,s             Add calculated X text coord
                    addb      Wt.DfSZX,y          Add original maximum X text size
                    lbsr      L1015               calculate size in pixels
                    std       $0D+2,s             Save as window X end pixel coord
                    ldb       Wt.DfCPY,y          get window default text Y start coord
                    addb      $0C+2,s             add calculated Y text coord
                    addb      Wt.DfSZY,y          Add original maximum Y text size
                    lbsr      L1015               calculate size in pixels
                    std       <$0F+2,s            Save as window Y end pixel coord & return
                    rts

* Get root device window table ptr
* Entry: X=some sort of window tbl ptr
*        Y=Some sort of window tbl ptr
*        $B,s = X text coord (enters here with 0)
*        $C,s = Y text coord (enters here with 0)
* Exit:  A=root device window entry #
*        $B,s = calculated X text coord
*        $C,s = calculated Y text coord
L1667               pshs      y,x                 Save regs
                    lda       Wt.BLnk,y           Get back window link (window #)
L166B               bmi       L1688               Not an overlay, we found root window, return
                    lbsr      L1CBC               point X to the window table entry
                    ldd       Wt.DfCPX,x          get window default start X&Y text coords
                    addd      <10+$B,s            ($15,s) Add to calculated X&Y text coords
                    ldy       Wt.LStDf,x          get window logical start address
                    cmpy      Wt.LStrt,x          match current?
                    beq       L1681               yes, skip ahead
                    addd      Wt.CPX,x            No, add CWArea start X&Y coords
L1681               std       <10+$B,s            ($15,s) Save calculated X/Y text coords
                    lda       Wt.BLnk,x           get back window link (window #)
                    bra       L166B               Keep going up chain until root device window

L1688               puls      pc,y,x              Restore regs, return with A=window table entry # for root window

* Signed Divide by 8
* ONLY CALLED TWICE...SHOULD EMBED
L1027               equ       *
                    IFNE      H6309
                    asrd
                    asrd
                    asrd
                    ELSE
                    asra
                    rorb
                    asra
                    rorb
                    asra
                    rorb
                    ENDC
                    rts

* Calculate the current mouse Y text coord within a overlay window
* used for menu pull down updates
L168A               pshs      x,u                 preserve pointer to mouse coords & global mem
                    lda       Wt.BLnk,y           get parent window # of this overlay
                    lbsr      L1CBC               point X to window table entry
                    lda       Wt.BLnk,x           parent window a overlay?
                    bpl       L169D               yes, skip ahead
                    ldb       Wt.DfCPY,y          get current overlay window Y default start
                    addb      Wt.DfCPY,x          add it to parent window default Y start
                    bra       L16A6               skip ahead

L169D               ldb       Wt.DfCPY,y          get default Y co-ordinate of current window
                    bsr       L16BC
                    tfr       a,b
L16A6               ldx       ,s                  get mouse coordinate pointer
                    lbsr      L1015               calculate it in pixels
                    IFNE      H6309
                    incd                          Add 1
                    tfr       d,w                 copy it to W
                    ldd       2,x                 get mouse Y co-ordinate
                    subr      w,d                 calculate the relative co-ordinate in window
                    ELSE
                    addd      #$0001              Add 1
                    std       >GrfMem+gr00B5
                    pshs      d
                    ldd       2,x                 get mouse Y co-ordinate
                    subd      ,s++                calculate the relative co-ordinate in window
                    ENDC
                    bsr       L1027               divide it by 8
                    decb                          subtract 1
                    tfr       b,a                 copy it to A
                    puls      x,u,pc              restore & return

* Calculate the current mouse Y text co-ordinate
L16BC               pshs      x,y                 preserve current & parent window table pointers
                    clrb
                    pshs      b
                    tfr       y,x
L16C3               lda       Wt.BLnk,x           get window # of parent window
                    bmi       L16D3               we're at the bottom, skip ahead
                    lbsr      L1CBC               go calculate
                    ldb       Wt.DfCPY,x          get parent window default Y start
                    addb      ,s                  add it to current
                    stb       ,s                  save it
                    bra       L16C3               keep going

L16D3               ldy       Wt.LStDf,x          Get screen logical start address when it was initialized
                    cmpy      Wt.LStrt,x          Same as current logical start address?
                    beq       L16E2               Yes, skip ahead
                    ldb       Wt.CPY,x            No, get current Y coord start of window
                    addb      ,s                  Add to Y value
                    stb       ,s
L16E2               inc       ,s                  Bump up Y value
                    puls      a,x,y,pc

* Process a selected menu item on menu bar
* Entry: A=Menu # from menu handling table
*        X=Pointer to menu handling entry
L16E6               stx       $0B,s               save current menu handling entry pointer
                    ldy       <$1A,s              get path descriptor pointer
                    ldu       $02,s               get static mem pointer
                    ldb       V.MSigID,u          get process ID of mouse signal reciever
                    stb       <$23,s              save it
                    clr       V.MSigID,u          clear it in device mem
                    lbsr      L1A3C               copy window table
                    stx       <$1E,s              save pointer to graphics table entry
                    sty       <$13,s              save pointer to window table
                    ldx       >WGlobal+G.GfxTbl   get graphics table pointer
                    leax      >$0240,x            point to working window descriptor
                    ldx       WN.BAR,x            get pointer to array of menu descriptors
                    deca                          adjust current menu # to start at 0
                    ldb       #MN.SIZ             get size of menu descriptor
                    mul                           calculate offset
                    IFNE      H6309
                    addr      d,x                 add it to menu array pointer
                    ELSE
                    leax      d,x                 add it to menu array pointer
                    ENDC
                    ldu       2,s                 get static mem pointer
                    lbsr      L13B5               copy menu descriptor from user space
                    stx       5,s                 save menu entry pointer
                    lda       MN.ENBL,x           menu enabled?
                    bne       L1728               yes, process pulldown
                    IFNE      H6309
                    clrd                          clear menu ID & item #
                    ELSE
                    clra                          clear menu ID & item #
                    clrb
                    ENDC
                    lbra      L193A               restore window table & return

* Print selected menu text
L1728               ldu       $0B,s               get menu handling entry pointer
                    ldy       <$13,s              get window table pointer
                    lda       MnuXStrt,u          get start X co-ordinate
                    clrb                          get start Y co-ordinate
                    pshs      y,x                 preserve regs
                    lbsr      L12D7               switch to text font
                    lbsr      L128E               set text coords
                    IFNE      H6309
                    oim       #Bold+TChr,Wt.BSW,y Turn Bold ON/Transparency OFF
                    ELSE
                    pshs      a
                    lda       Wt.BSW,y            Turn Bold ON/Transparency OFF
                    ora       #Bold+TChr
                    sta       Wt.BSW,y
                    puls      a
                    ENDC
                    puls      y,x                 restore regs
                    lbsr      L1299               get length of text to a maximum of 15
                    lbsr      L1A88               calculate if we can print a space after menu text
                    lbsr      L1283               print a space
                    lda       MN.ID,x             get menu ID
                    cmpa      #MId.Tdy            is it tandy menu?
                    bne       L1757               no, skip ahead
                    lbsr      L127F               Yes, print tandy icon
                    bra       L175A               skip ahead

L1757               lbsr      L12AE               print menu text
L175A               tst       <$19,s              can we print a space here?
                    bne       L1762               no, skip ahead
                    lbsr      L1283               print a space
L1762               equ       *
                    IFNE      H6309
                    aim       #^Bold,Wt.BSW,y     Turn BOLD OFF
                    ELSE
                    lda       Wt.BSW,y            Turn BOLD OFF
                    anda      #^Bold
                    sta       Wt.BSW,y
                    ENDC
                    ldx       $05,s               get pointer to menu descriptor
                    lda       MN.NITS,x           any items to print?
                    bne       L1772               yes, skip ahead
                    lda       MN.ID,x             get menu ID
                    clrb                          clear item
                    lbra      L193A               return with menu info

* Calculate X start position and size of pull down
L1772               lda       MN.XSIZ,x           get horizontal size of pull down
                    adda      #$02                add 2 for the borders
                    pshs      a                   save window width
                    ldu       $0C,s               get pointer to handling entry
                    adda      MnuXStrt,u          add in the start coord to get end coord
                    cmpa      Wt.SZX,y            will it fit in current window?
                    bhs       L1785               no, skip ahead
                    lda       MnuXStrt,u          Yes, get start coord
                    bra       L1789

L1785               lda       Wt.SZX,y            get current window size
                    suba      ,s                  subtract calculated width
L1789               puls      b                   restore width of pull down
                    ldu       2,s                 get static mem pointer
                    lbsr      L07B0               find a new window table & link it to current
                    sty       <$1C,s              save the pointer to new window table
                    pshs      y                   preserve new window table pointer
                    ldy       <$15,s              get old window table pointer
                    tst       Wt.BLnk,y           Is it an overlay window?
                    bmi       L17A5               No, skip ahead
L17A2               adda      Wt.DfCPX,y          Yes, add to Default X coord start
L17A5               puls      y                   Get new window table ptr back
                    sta       Wt.CPX,y            Save new current X coord start
                    stb       Wt.SZX,y            Save new current X size
                    pshs      y                   Save new window table ptr again
                    ldy       <$15,s              get working window table pointer?
                    tst       Wt.BLnk,y           this a overlay window?
                    bpl       L17B9               yes, skip ahead
                    puls      y
                    bra       L17C1

L17B9               lda       Wt.DfCPY,y          get full window Y start
                    inca                          add 1
                    puls      y                   restore
                    bra       L17C3               skip ahead

* Calculate Y start & size of pull down
L17C1               lda       #$01                get Y co-ordinate start
L17C3               sta       Wt.CPY,y            save it as current window Y start
                    sta       >GrfMem+gr0059      save it as save switch too
                    lda       MN.NITS,x           get # items in this menu
                    adda      #$02                add 2 to put a blank line on top & bottom
                    pshs      x                   save pointer to menu descriptor
                    ldx       <$15,s              Get ptr to window table
                    cmpa      Wt.SZY,x            lower than current Y size of window?
                    blt       L17E5               Yes, skip ahead
                    lda       Wt.SZY,x            No, get current Y size
                    deca                          drop by 1
                    sta       Wt.SZY,y            Save it back as new current Y size
                    suba      #2                  Subtract two more
                    puls      x                   restore menu descriptor pointer
                    sta       MN.NITS,x           save as # items in menu descriptor
                    bra       L17E9

L17E5               puls      x                   restore menu descriptor pointer
                    sta       Wt.SZY,y            save overlay window size
* Place pull down on screen
L17E9               ldx       <$1E,s              get graphics table pointer
                    ldd       Gt.FMsk,x           get the foreground/background masks
                    std       Wt.Fore,y           set foreground/background masks in window table
                    pshs      y                   Preserve window tbl ptr
                    ldb       #$0A                get code for OWSet
                    lbsr      L0101               do a overlay window
                    puls      y                   Get window tbl ptr back
                    bcc       L181D               no errors on OWSet, print menu items
                    lda       Wt.BLnk,y           Error, get parent window #
                    ldu       2,s                 Get static mem ptr
                    sta       V.WinNum,u          Save parent window
                    ldd       #$FFFF              Mark window table as unused
                    std       Wt.STbl,y
                    lbsr      L19F1               Print menu descriptor text
                    IFNE      H6309
                    clrd
                    ELSE
                    clra
                    clrb
                    ENDC
                    lbra      L193A               Something involving copying a window table

* Move a menu item descriptor from caller
* Exit: X=Ptr to destination
L13C9               pshs      b,y,u               preserve regs
                    ldu       <D.Proc             get source task #
                    lda       P$Task,u
                    ldu       <D.SysPrc           get system task #
                    ldb       P$Task,u
                    ldu       >WGlobal+G.GfxTbl   get destination pointer
                    leau      >$0279,u
                    ldy       #MI.SIZ             get size of item descriptor
                    os9       F$Move              move it
                    tfr       u,x                 make X point to destination
                    puls      b,y,u,pc

* Setup for printing the item text in the pull down
L181D               ldu       $02,s               get static memory pointer
                    lbsr      L1358               setup graphics table entry
                    ldy       <$1A,s              get working window table pointer
                    lbsr      L0E68               do a shadowed window on this overlay
                    lbcs      L1935               error, return nothing
                    ldy       <$1C,s              get window table pointer
                    pshs      y
                    ldd       #$203E              turn cursor off
                    lbsr      L0101
                    puls      y
                    ldx       $05,s               get pointer to menu descriptor
                    ldb       MN.NITS,x           get # items in menu
                    stb       <$18,s              save it as a counter
                    clra
                    sta       <$17,s
                    ldx       MN.ITEMS,x          get pointer to item descriptor
                    lbsr      L12D7               switch to text font
* Print all items in the pull down
L1852               stx       <$20,s              save pointer to item descriptor
                    bsr       L13C9               get item descriptor from caller
                    tst       MI.ENBL,x           item enabled?
                    bne       L1861               yes, turn bold on
                    IFNE      H6309
                    aim       #^Bold,Wt.BSW,y     Turn BOLD OFF
                    ELSE
                    lda       Wt.BSW,y            Turn BOLD OFF
                    anda      #^Bold
                    sta       Wt.BSW,y
                    ENDC
                    bra       L1864               skip to printing

L1861               equ       *
                    IFNE      H6309
                    oim       #Bold,Wt.BSW,y      Turn BOLD ON
                    ELSE
                    lda       Wt.BSW,y            Turn BOLD ON
                    ora       #Bold
                    sta       Wt.BSW,y
                    ENDC
L1864               clra                          set X co-ordinate
                    ldb       <$17,s              get Y co-ordinate
                    pshs      x                   preserve item pointer
                    lbsr      L128E               set text co-ordinate
                    puls      x                   restore item pointer
                    lbsr      L1299               get length of text to a maximum of 15
                    lbsr      L12AE               print item text
                    ldx       <$20,s              get pointer to item descriptor
                    leax      MI.SIZ,x            move to next item
                    inc       <$17,s              add another item
                    dec       <$18,s              done all items?
                    bne       L1852               no, keep going
* Setup some variables
                    lda       #$FF                set current selected item state
                    sta       $04,s
                    sta       >WGlobal+g00BF
                    lda       >WGlobal+G.MSmpRV   get current mouse scan rate
                    sta       <$22,s              preserve it
                    lda       #$02                set new mouse scan rate in global mem
                    sta       >WGlobal+G.MSmpRV
                    sta       >WGlobal+G.MSmpRt
* Main pointer processing loop for a pulldown
* waits for either a keypress or a mouse button click while updating
* item text in pull down
L18A5               clr       >WGlobal+G.WIBusy   flag cowin not busy
                    ldx       #1                  let VTIO scan keyboard & update mouse pointer
                    os9       F$Sleep
                    inc       >WGlobal+G.WIBusy   flag cowin busy
                    lda       >WGlobal+g00BF      was a key pressed?
                    bmi       L18CB               no, skip ahead
                    beq       L1943               already processed, remove pull down & return
                    clr       >WGlobal+g00BF      clear key press flag
                    lda       #MId.Chr            get menu ID for key press
                    bra       L1937               remove pull down & return

L18CB               ldx       #WGlobal+G.Mouse    Point to mouse packet
                    tst       Pt.CBSA,x           button A down?
                    bne       L1911               yes, go check out where it is
* No mouse button, check if mouse is in window
                    lbsr      L1D24               copy mouse co-ordinates to system co-ordinates
                    leax      Pt.Siz,x            point to 'em
                    lbsr      L1C25               mouse in current working area?
                    bcc       L18FC               yes, check for item update
                    bsr       L194A               print current item in non-inverse state
                    ldx       #WGlobal+g005C      Get ptr to work mouse coords
                    lbsr      L1C19               mouse in current window?
                    bcs       L18F5               no, skip ahead
                    lda       #$01                set mouse in pulldown flag
                    sta       <$24,s
                    lda       #$FF                flag no current item selected
                    sta       $04,s
                    bra       L18A5               go back & wait

L18F5               tst       <$24,s              mouse still in pull down?
                    bne       L1935               no, remove pulldown & return nothing
                    bra       L18A5               go back & wait

* Check if we update current item text
L18FC               lda       #$01                set mouse in pull down flag
                    sta       <$24,s
                    lbsr      L168A               calculate text Y co-ordinate from mouse
                    sta       <$16,s              save current Y co-ordinate
                    cmpa      $04,s               match current item?
                    beq       L18A5               yes, go back & wait
                    bsr       L194A               print item text
                    bsr       L1972               print next item in inverse state
                    bra       L18A5               go back & wait

* Mouse button down but not released, check if it's a menu item
L1911               lbsr      L1A33               wait for button release
                    lbsr      L1D24               get current mouse co-ordinates
                    leax      Pt.Siz,x            point to 'em
                    lbsr      L1C25               mouse still in current working area?
                    bcs       L1935               no, return nothing
                    lda       $04,s               get current item #
                    leas      -2,s
                    IFNE      H6309
                    bsr       L19A8               get item descriptor from caller
                    ELSE
                    lbsr      L19A8               get item descriptor from caller
                    ENDC
                    leas      2,s
                    lda       MI.ENBL,x           item enabled?
                    beq       L1935               no, return nothing
                    ldx       $05,s               get menu descriptor pointer
                    lda       MN.ID,x             get ID
                    ldb       $04,s               get item #
                    incb                          add 1 to it (can't use zero)
                    bra       L1937               return with ID & item #

L1935               equ       *
                    IFNE      H6309
                    clrd                          clear menu ID & item #
                    ELSE
                    clra
                    clrb
                    ENDC
L1937               equ       *
                    IFNE      H6309
                    bsr       L19B9               remove pulldown & redraw menu bar
                    ELSE
                    lbsr      L19B9               remove pulldown & redraw menu bar
                    ENDC
L193A               pshs      d                   preserve menu id & item #
                    ldu       $04,s               get static mem pointer
                    lbsr      L1A61               copy the window table
                    puls      d,pc                restore & return

L1943               equ       *
                    IFNE      H6309
                    clrd
                    bsr       L19CA               Remove pulldown menu
                    ELSE
                    clra
                    clrb
                    lbsr      L19CA               Remove pulldown menu
                    ENDC
                    bra       L193A

* Print non-inversed item text
L194A               lda       $06,s               get current item #
                    bmi       L1971               no item, return
                    pshs      a                   preserve it
                    lbsr      L1331               turn inverse off
                    puls      a                   restore item #
                    bsr       L19A8               get item descriptor from caller
                    tst       MI.ENBL,x           enabled?
                    beq       L1971               no, return
                    IFNE      H6309
                    oim       #Bold,Wt.BSW,y      Turn BOLD ON
                    ELSE
                    pshs      a
                    lda       Wt.BSW,y            Turn BOLD ON
                    ora       #Bold
                    sta       Wt.BSW,y
                    puls      a
                    ENDC
                    lbsr      L1299               get length of item text
                    pshs      b                   save length
                    clra                          get text X co-ordinate
                    ldb       $07,s               get text Y co-ordinate of item
                    lbsr      L128E               set them
                    lbsr      L12B6               erase to end of line
                    puls      b                   restore item text length
                    lbra      L12AE               print item text & return from there

* Print inversed item text
L1972               lbsr      L1329               turn inverse on
                    lda       <$18,s              get item #
                    bsr       L19A8               get item descriptor from caller
                    tst       MI.ENBL,x           enabled?
                    beq       L19A2               no, return
                    IFNE      H6309
                    oim       #Bold,Wt.BSW,y      Turn BOLD ON
                    ELSE
                    pshs      a
                    lda       Wt.BSW,y            Turn BOLD ON
                    ora       #Bold
                    sta       Wt.BSW,y
                    puls      a
                    ENDC
                    lbsr      L1299               calculate length
                    pshs      b                   save it
                    clra                          get X coord of item
                    ldb       <$19,s              get Y coord of item
                    lbsr      L128E               set cursor
                    ldb       ,s                  get length
                    lbsr      L12AE               print item text
                    ldx       $08,s               get menu descriptor pointer
                    ldb       MN.XSIZ,x           get width of pull down
                    subb      ,s+                 subtract from text length
                    decb                          take one off
L199A               decb                          done printing?
                    bmi       L19A2               yes, return
                    lbsr      L1283               print a space
                    bra       L199A               keep going till done

L19A2               lda       <$18,s              get new item #
                    sta       6,s                 save as current & return
L1971               rts

* Get a item descriptor from caller
* Entry: A=Item #
L19A8               ldx       $09,s               get menu descriptor pointer
                    ldx       MN.ITEMS,x          get pointer to item descriptor array
                    ldb       #MI.SIZ             get size of item descriptor
                    mul                           calculate offset
                    IFNE      H6309
                    addr      d,x                 add it to pointer
                    ELSE
                    leax      d,x                 add it to pointer
                    ENDC
                    lbra      L13C9               get item descriptor from caller & return

* Remove pull down menu & redraw menu bar
L19B9               pshs      d                   preserve menu ID and item number
                    bsr       L19D0               remove pull down overlay
                    lda       <$26,s              restore mouse sample rate
                    sta       >WGlobal+G.MSmpRV   Save in global (Reset default # ticks till next read)
                    sta       >WGlobal+G.MSmpRt   And reset tick counter for next read
                    bra       L19F3               redo menu text

L19CA               pshs      d                   preserve menu ID & item #
                    bsr       L19D0               remove pull down
                    puls      d,pc

* Remove menu bar pull down
L19D0               ldy       <$22,s              get window table pointer
                    ldu       $08,s               get static mem pointer
                    lda       Wt.BLnk,y           get window back link #
                    sta       V.WinNum,u          save as current window
                    ldd       Wt.LStDf,y          get screen logical start of full window
                    std       Wt.LStrt,y          save it as current
                    IFNE      H6309
                    ldq       Wt.DfCPX,y          get init'ed window start co-ordinates & sizes
                    stq       Wt.CPX,y            save 'em as current
                    ELSE
* changed from original Wt.DfCPX+2 and Wt.CPX+2 for clarity LCB
                    ldd       Wt.DfSZX,y
                    std       Wt.SZX,y
                    std       >GrfMem+gr00B5
                    ldd       Wt.DfCPX,y
                    std       Wt.CPX,y
                    ENDC
                    ldb       #$0C                get code for OWEnd
                    lbra      L0101

* Print menu descriptor text
* ENTRY: X=ptr to NUL terminated menu text
L19F1               pshs      d                   preserve menu ID & item #
L19F3               ldu       $F,s                get pointer to menu handling entry
                    ldy       <$17,s              get window table pointer
                    ldx       $9,s                get menu text pointer
                    lda       MnuXStrt,u          get start X coord
                    clrb                          Y coord=0
                    lbsr      L128E               Do CurXY (preserves u,y,x)
* Shut scaling off so it works properly (may be able to use A or B instead)
                    IFNE      H6309
                    oim       #Bold,Wt.BSW,y      BOLD ON
                    aim       #^(TChr+Scale),Wt.BSW,y Transparency on / Scaling off
                    ELSE
                    lda       Wt.BSW,y            Get current switch settings
                    ora       #Bold               BOLD ON
                    anda      #^(TChr+Scale)      Transparency/Scaling both off
                    sta       Wt.BSW,y            Save new settings
                    ENDC
                    lbsr      L1329               turn inverse on (preserves u,y,x)
                    lbsr      L1299               get length of text (up to 15) into B
                    bsr       L1A8F               Get size that we print into A/U=menu table ptr
                    lbsr      FixMenu             Draw the graphics under current menu option
                    lbsr      L1283               print a space
                    lda       MN.ID,x             get menu ID
                    cmpa      #MId.Tdy            tandy menu?
                    bne       L1A23               no, print normal text
                    lbsr      L127F               print tandy icon (no spaces)
                    bra       L1A2E               return

L1A23               lbsr      L12AE               print menu text
L1A2E               equ       *
                    IFNE      H6309
                    aim       #^Bold,Wt.BSW,y     turn BOLD OFF
                    ELSE
                    lda       Wt.BSW,y            turn BOLD OFF
                    anda      #^Bold
                    sta       Wt.BSW,y
                    ENDC
                    puls      d,pc

* Wait for mouse button release
L1A33               tst       Pt.CBSA,x           button A down?
                    bne       L1A33               yes, wait for release
                    clr       Pt.CCtA,x           clear click count
                    clr       Pt.TTSA,x           clear time this state
                    rts                           return

* Copy window table into a buffer for preservation while cowin is processing
* the menu bar selections. It does this for ease of restoration of window
* to do overlays & such
L1A3C               pshs      d                   preserve registers
                    lbsr      L06AE               get window table pointer
                    ldx       >WGlobal+G.GfxTbl   point to a buffer for window table
                    leax      >$02CF,x            Point to buffer to preserve original window tbl
                    bsr       L1A6E               copy current window table into buffer
                    lbsr      L04EA               change window to full size
                    ldu       6,s
                    lbsr      L06B9               get graphics table pointer
                    ldd       Gt.FClr,x
                    std       Wt.Fore,y           save it into window table
                    IFNE      H6309
                    aim       #^Prop,Wt.BSW,y     Proportional OFF
                    ELSE
                    lda       Wt.BSW,y
                    anda      #^Prop
                    sta       Wt.BSW,y
                    ENDC
                    lbsr      L1337               set draw pattern to nothing
                    lbsr      L1342               set logic type to nothing
                    puls      d,pc                restore & return

* Restore window table to original state
L1A61               lbsr      L06AE
                    leax      ,y
                    ldy       >WGlobal+G.GfxTbl   Get ptr to CoWin graphics tables
                    leay      >$02CF,y            Point to "temp" entry
* Copy a window table
* Entry: Y=Source pointer
*        X=Destination pointer
* Exit:  X,Y preserved
L1A6E               pshs      x,y
                    leax      Wt.STbl,x           Point X to beginning of destination window table entry (-$10,x)
                    leay      Wt.STbl,y           Point Y to beginning of destination window table entry (-$10,y)
                    IFNE      H6309
                    ldw       #Wt.Siz
                    tfm       y+,x+
                    ELSE
* 6809 - Eventually use StkBlCpy vector (64 byte copy)
                    pshs      d
                    ldb       #Wt.Siz
L1A6Eb              lda       ,y+
                    sta       ,x+
                    decb
                    bne       L1A6Eb
                    clra
                    std       >GrfMem+gr00B5
                    puls      d
                    ENDC
                    puls      x,y,pc

L1A88               leas      -2,s                adjust stack for L1a8f routine
                    bsr       L1A8F               Calc End X coord for menu entry
                    leas      2,s                 restore stack & return
                    rts

* Calculate what size of text we will write (preferably with 1 space in
*   front & back). Set flag @ <$1d on stack as to whether spaces fit or not.
* Entry: B=Size of text entry
* Exit: <$1d,s (after puls a,pc) = 0 if fits with lead & trailing spaces
*       <$1d,s = 1 if did not fit
*       A=End X coord on menu bar of TEXT ONLY, NOT INCLUDING SPACES
*       B=Maximum size of text to write (IF CAN'T FIT WITH 2 SPACES)
*       U=menu table ptr
*       E=End X coord including spaces
* NOTE: A does calculate real end in the routine, but only to set flag on
*       stack. It destroys the result before exiting.
L1A8F               ldu       <$11,s              get menu table pointer
                    lda       MnuXStrt,u          get X start co-ordinate
                    IFNE      H6309
                    addr      b,a                 add size of text to it
                    ELSE
                    pshs      b
                    adda      ,s+                 add size of text to it
                    ENDC
                    pshs      a                   save result (end coord)
                    inca                          add 2 for space on either side
                    inca
* Changed to use E
                    IFNE      H6309
                    tfr       a,e                 Move to register we can preserve
                    cmpe      Wt.SZX,y            still fit in window?
                    bls       L1AB0               yes, skip ahead
                    dece                          Subtract one of the 2 spaces
                    cmpe      Wt.SZX,y            fit in window now?
                    ELSE
                    sta       >GrfMem+gr00B5
                    cmpa      Wt.SZX,y            still fit in window?
                    bls       L1AB0               Yes, skip ahead
                    deca                          Subtract one of the 2 spaces
                    sta       >GrfMem+gr00B5
                    cmpa      Wt.SZX,y            Fit in window now?
                    ENDC
                    bls       L1AAC               yes, skip ahead
                    ldb       Wt.SZX,y            get window size
                    subb      MnuXStrt,u          take off start coord
                    decb                          take off another for space in front
                    IFNE      H6309
                    tfr       b,e
                    ELSE
                    stb       >GrfMem+gr00B5
                    ENDC
L1AAC               lda       #$01                Set flag that it doesn't fit
                    bra       L1AB1

L1AB0               clra                          Flag that it fits
L1AB1               sta       <$20,s
                    puls      a,pc                restore new X coord & return

* SS.SBar entry point
L1AB9               lbsr      L116C               setup working window table
                    ldx       PD.RGS,y            get register stack pointer
                    ldy       >WGlobal+g00BB      Get ptr to work window table
* Theoretically, this is where setting up a FSWIN should draw the scroll bars
DfltBar             pshs      x                   preserve register stack pointer
                    lda       #2                  point to draw table to erase old markers
                    leax      <SBarErs,pc
                    lbsr      DrawBar             erase old markers
                    puls      x
* Draw horizontal scroll bar marker
                    ldb       R$X+1,x             get requested coord
                    addb      #$05                Add 5 to it (min. size of horiz. scroll bar)
                    cmpb      Wt.SZX,y            Still within X size of window?
                    ble       L1B1E               Yes, bump X pos. back by 4 & go draw it
                    ldb       Wt.SZX,y            No, get X size of Window
                    subb      #$03                Bump down by 3
                    bra       L1B20               Go draw it

L1B1E               subb      #$04
L1B20               clra                          Multiply x 8
                    IFNE      H6309
                    lsld
                    lsld
                    lsld
                    ELSE
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    ENDC
                    std       >GrfMem+gr0047      save X coord
                    ldb       Wt.SZY,y            get window Y size
                    decb                          subtract 1 to start at 0
                    clra                          Multiply x 8
                    IFNE      H6309
                    lsld
                    lsld
                    lsld
                    incd                          Bump down for new marker size
                    ELSE
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    addd      #$0001              Bump down for new marker size
                    ENDC
                    std       >GrfMem+gr0049
                    ldd       #$ce06              get group/buffer
                    bsr       DrawScrl            Go PutBlk on screen
* Draw vertical scroll bar marker
                    ldb       Wt.SZX,y            get window X size
                    decb                          subtract 1 to start at 0
                    clra                          Multiply x 8
                    IFNE      H6309
                    lsld
                    lsld
                    lsld
                    incd                          added RG
                    ELSE
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    addd      #1                  added RG
                    ENDC
                    std       >GrfMem+gr0047
                    ldb       R$Y+1,x             get requested Y position
                    addb      #$06
                    cmpb      Wt.SZY,y            will it fit in window?
                    ble       L1B3D
                    ldb       Wt.SZY,y
                    subb      #$03
                    bra       L1B3F

L1B3D               subb      #4
L1B3F               clra                          Multiply x 8
                    IFNE      H6309
                    lsld
                    lsld
                    lsld
                    ELSE
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    ENDC
                    std       >GrfMem+gr0049
                    ldd       #$ce05              get group/buffer
DrawScrl            std       >GrfMem+gr0057
                    ldb       #$36                get grfdrv funtion for putblk
                    pshs      x,y
                    lbsr      L0101
                    puls      x,y,pc

* Draw table for erasing scroll bars
SBarErs             fcb       WColor2             Background of bar color (light grey)
                    fdb       9                   9,(bottom+6) to (Right-17),(Bottom -1)
                    fdb       -6
                    fdb       -17
                    fdb       -2
                    fcb       $4e

                    fcb       WColor2             Background of bar color (light grey)
                    fdb       -6                  (Right-6),17 to (Right-1),(Bottom-17)
                    fdb       17
                    fdb       -1
                    fdb       -17
                    fcb       $4e

* Update auto follow mouse cursor - ADD CHECK FOR MOUSE BUTTON DOWN ON AREA
*  NOT IN OUR WINDOW, DO SELECT IF IN ANOTHER WINDOW
* NOTE: THE AUTO-FOLLOW MOUSE FLAG REMAINS SET _EVEN_ IF WE END UP ON A TEXT
*    WINDOW!!!
* Theoretically, entry is:
*   U=static mem ptr for current active window
*   Y=Path descriptor (64 bytes) ptr for current active window
L1B4D               leas      -5,s                make a buffer for flag & current mouse coords
                    clr       4,s                 clear a flag (for different gfx cursor required)
                    ldx       #WGlobal+G.Mouse+Pt.AcX Point to mouse current coords
                    ldu       >WGlobal+G.CurDev   get current device static mem pointer
                    lbsr      L06A0               Go point to & verify window dsc. (preserves X)
                    IFNE      H6309
                    ldq       ,x                  Get current X&Y Coords
                    tim       #$01,[Wt.STbl,y]    320 or 640 pixel wide screen?
                    ELSE
                    ldd       2,x
                    std       >GrfMem+gr00B5
                    ldd       ,x
                    pshs      a
                    lda       [Wt.STbl,y]         320 or 640 pixel wide screen?
                    bita      #$01
                    puls      a
                    ENDC
                    bne       L1B72               640, skip ahead
                    IFNE      H6309
                    lsrd                          Divide X coord by 2
L1B72               stq       ,s                  Save current mouse coords
                    ELSE
                    lsra                          Divide X coord by 2
                    rorb
L1B72               std       ,s                  Save current mouse coords
                    ldd       >GrfMem+gr00B5
                    std       2,s
                    ldd       ,s
                    ENDC
                    leax      ,s                  point to coord info
*  1ST TRY - NEW ROUTINE
                    lbsr      L1C19               Check if mouse coord in current window at all
                    bcs       L1B8D               No, check to see if we switch windows
* Mouse cursor within current physical window
                    lbsr      L1C25               Check if mouse coord in CWArea of current window
                    lbcs      AdjstCrs            No, must be in control region, adjust gfx cursor
                    ldu       >WGlobal+G.CurDev   get current device static mem
                    lbsr      L06B9               get gfx table pointer for this window
                    ldd       Gt.GOff,x           get offset into block of graphics cursor
                    cmpd      Wt.GOff,y           Same as ptr in window table itself?
                    lbeq      L1BD8               Yes, skip ahead
                    inc       4,s                 No, set flag & then skip ahead
                    lbra      L1BD8

* Mouse cursor not within current window's CWArea. Please note that if running
*   in a bordered window, this means it could be in the menu bar or scroll bar
*   areas (within DWSet range, but not CWArea)
* Gets here ok when cursor on different window
* REQUIRES VTIO TO SET MSEMOVE FLAG WHEN BUTTON PRESSED (DONE IN TC9IO)
* May want to change to send MsSig here in CoWin instead - then we can leave
* Tc9/CC3 IO alone.
* NOTE: WE _WILL_ HAVE TO MAKE SURE IT IS A WINDOW LINKED WITH A PROCESS IN
*   SOME WAY (AS TC9IO'S CLEAR ROUTINE DOES), AS IT WILL SELECT "GHOST"
*   WINDOWS FOR GSHELL (I THINK)
L1B8D               ldd       >Pt.CBSA+G.Mouse+WGlobal Get both buttons
                    lbeq      AdjstCrs            Neither down, continue normally
* Search through window tables looking for ones on the same screen (NO overlay
                    ldu       Wt.STbl,y           Get our screen table for comparison purposes
                    ldx       #WinBase            Point to start of internal window tables
                    ldd       #$2040              32 windows to check, $40 bytes/table entry
                    IFNE      H6309
SrchLoop            ldw       Wt.STbl,x           Get screen tbl ptr
                    cmpw      #$FFFF              unused, skip
                    beq       TryNext
                    cmpr      x,y                 Our own ptr?
                    beq       TryNext
                    cmpr      w,u                 On same screen?
                    ELSE
SrchLoop            pshs      x
                    ldx       Wt.STbl,x           Get screen tbl ptr
                    stx       >GrfMem+gr00B5
                    cmpx      #-1                 Unused, skip
                    puls      x
                    beq       TryNext
                    pshs      x
                    cmpy      ,s++                Our own ptr?
                    beq       TryNext
                    cmpu      >GrfMem+gr00B5      On same screen?
                    ENDC
                    beq       CheckScn            Yes, check if mouse clicked on it.
* inc >BordReg        Debug code to see if we got here
TryNext             abx                           No, bump ptr up
                    deca                          Dec # windows left to check
                    bne       SrchLoop
                    bra       AdjstCrs

CheckScn            equ       *
                    IFNE      H6309
                    lde       Wt.BLnk,x           Is this an overlay window?
                    ELSE
                    pshs      a
                    lda       Wt.BLnk,x           Is this an overlay window?
                    sta       >GrfMem+gr00B5
                    puls      a
                    ENDC
                    bpl       TryNext             Yes, don't bother with it (MAY BE WRONG?)
                    pshs      u,y,x,d             Preserve regs
                    leax      8,s                 Point to mouse packet
*         ldx   #WGlobal+G.Mouse+Pt.AcX   Point to mouse current coords
                    lbsr      L1C19               See if mouse on this window
                    puls      u,y,x,d             Restore regs
                    bcs       TryNext             Not on this window either, continue through table
* Found window mouse was clicked on. Now, we must find the ptr to _this_
*   windows' device mem ptr, load it into X, lbsr L0582 & bra L1C16
* See TC9IO source, but basically, get Device Table ptr, get # of devices max,
*   use that as range, Get our V$DRIV, check for match (going through Device
*   table), if match, get V$STAT for static storage. Go in there, make sure
*   $1d indicates GRFDRV/CoWin, $1e >0 (Valid window). If so, we found our
*   ptr. If not, skip to AdjstCrs. Do NOT have to go back in loop, as only
*   one window can be in same area (at this time... until movable/resizable
*   windows are implemented in 16K grfdrv)
* This routine should preserve Y (window table ptr)
* SEEMS TO WORK TO HERE NOW.
* Entry: A=32-window entry #
* NOTE: IF IT ALLOWS SELECTING THE UNDERLYING GSHELL "GHOST" WINDOW, WE ALSO
*   HAVE TO ADD CODE TO MAKE SURE A PROCESS IS ACTIVE FOR THE WINDOW... WHICH
*   MEANS RE-SEARCHING (PAST LAST FOUND POINT) THE WINDOW TABLE ITSELF
                    ldb       #$20                Invert window entry #
                    IFNE      H6309
                    subr      a,b
                    ELSE
                    pshs      a
                    subb      ,s+
                    ENDC
                    pshs      b,y                 Preserve window entry # & Window table ptr
                    ldx       >WGlobal+G.CurDev   Get ptr to current device static mem
                    ldx       V.PORT,x            Get ptr to our device table entry
                    IFNE      H6309
                    ldw       V$DRIV,x            Get original window's driver ptr
                    ELSE
                    ldx       V$DRIV,x            Get original window's driver ptr
                    stx       >GrfMem+gr00B5
                    ENDC
                    ldb       #DEVSIZ             Size of each device table entry
                    ldx       <D.Init             Get ptr to INIT module
                    lda       DevCnt,x            Get # of entries allowed in device table
                    ldx       <D.DevTbl           Get start of device table
                    mul                           Calculate offset to end of device table
                    leay      d,x                 Point Y to end of Device table
                    ldb       #DEVSIZ             Get device table entry size again
DevLoop             ldu       V$DRIV,x            Get driver ptr for device we are checking
                    IFNE      H6309
                    cmpr      u,w                 Same as original window?
                    ELSE
                    cmpu      >GrfMem+gr00B5
                    ENDC
                    bne       NextEnt             No, skip to next entry
                    ldu       V$STAT,x            Get static mem ptr for CC3/TC9IO device
                    lda       V.WinType,u         Is this a Windint/Grfint window?
                    bne       NextEnt             No, VDGINT so skip
                    lda       V.InfVld,u          Is this static mem properly initialized?
                    beq       NextEnt             No, skip
                    lda       V.WinNum,u          Get window table entry #
                    cmpa      ,s                  Same as one we are looking for?
                    bne       NextEnt             No, wrong window
* In some cases, it DOES deactivate the original window
                    ldd       >WGlobal+G.CurDev   Copy old static mem ptr to previous
                    std       >WGlobal+G.PrWMPt
                    stu       >WGlobal+G.CurDev   Found it, save as current device
                    inc       V.ScrChg,u          Flag that screen update needed
                    clr       >WGlobal+g000A      Flag that we are not active device anymore
                    clr       >WGlobal+g00BF      Clear Windint's key pressed flag
                    leas      8,s                 Eat temp vars
                    rts

NextEnt             abx                           Point to next entry in device table
                    IFNE      H6309
                    cmpr      y,x                 Past end of table?
                    ELSE
                    pshs      y                   Past end of table?
                    cmpx      ,s++
                    ENDC
                    blo       DevLoop             No, keep trying
NoGo                puls      b,y                 Yes, restore window table ptr
AdjstCrs            ldx       >WGlobal+G.GfxTbl   get pointer to graphics table
                    ldd       >$02BC,x            graphics cursor been initialized?
                    bne       L1BB5               yes, skip ahead
                    ldd       #$CA01              get default group/buffer for arrow
                    std       >GrfMem+gr0057      Save in Grfdrv mem
                    pshs      y,x
                    ldb       #$1A                get function call for GCSet
                    lbsr      L0101               let grfdrv do it
                    puls      y,x
                    lda       Wt.GBlk,y           get graphics cursor block #
                    sta       >$02BC,x            save it in Gfx table mem
                    ldd       Wt.GOff,y           get offset in block to graphics cursor
                    std       >$02BD,x            save it
                    bra       L1BD1

* Change mouse cursor if necessary
L1BB5               pshs      a                   save gcursor block #
                    ldd       Wt.GOff,y           get offset into block
                    cmpd      >$02BD,x            match current?
                    puls      a                   restore block #
                    beq       L1BD8               Yes, skip next bit
L1BC5               sta       Wt.GBlk,y           save it into window table
                    ldd       >$02BD,x            get offset from global mem
                    std       Wt.GOff,y           save it as offset in window table
L1BD1               pshs      y,x                 Preserve regs
                    lbsr      L0CEC               Update cursors in Grfdrv
                    puls      y,x                 Restore regs

L1BD8               equ       *
                    IFNE      H6309
                    ldq       ,s                  get X&Y coords
                    stq       >GrfMem+gr005B      save them in grfdrv mem
                    ELSE
                    ldd       2,s                 get X&Y coords & save them in grfdrv mem
                    std       >GrfMem+gr005B+2
                    std       >GrfMem+gr00B5
                    ldd       ,s
                    std       >GrfMem+gr005B
                    ENDC
                    ldb       #$44                get function call for PutGC
                    pshs      y                   Preserve regs
                    lbsr      L0101               Put mouse cursor on screen
                    puls      y                   Restore regs
                    tst       4,s                 Was gfx cursor in window same as in gfx table?
                    beq       L1C16               Yes, skip ahead
                    ldu       >WGlobal+G.CurDev   No, get ptr to current device
                    lbsr      L06B9               get pointer to graphics tables for this window
                    lda       Gt.GBlk,x           Get gfx table block # for gfx cursor
                    bne       L1C07               There is one, make the it the same in window table
                    lda       Wt.GBlk,y           Isn't one, copy from window table to gfx table
                    sta       Gt.GBlk,x
                    ldd       Wt.GOff,y
                    std       Gt.GOff,x
                    bra       L1C11               Go update the cursors on screen

L1C07               sta       Wt.GBlk,y           set block # of graphics cursor in window table
                    ldd       Gt.GOff,x           get offset into block
                    std       Wt.GOff,y
L1C11               lbsr      L0CEC               Update cursors in GrfDrv
L1C16               leas      5,s                 Eat stack & return
                    rts

* Check if mouse is in current window (DWSet area)
* Entry: X=pointer to current mouse coordinates in mouse packet
*        Y=Pointer to window table
* Stack use: 0,s   current window table pointer
*            2,s   window start cords.
*            4,s   window size
L1C19               leas      -6,s                make a buffer
                    sty       ,s                  save window table pointer
                    leay      Wt.DfCPX,y          point to window default co-ordinates
                    bsr       L1C84               calculate co-ordinates
                    bra       L1C2E               go calculate it

* Check if mouse is in current working area (CWArea)
* Entry: X=pointer to current mouse coordinates in mouse packet
*        Y=Pointer to window table
* Stack use: 0,s   current window table pointer
*            2,s   window start cords.
*            4,s   window size
* Exit: Carry clear - on current window area
*       Carry set, off of current window area
* Preserves X
L1C25               leas      -6,s                make a buffer
                    sty       ,s                  save window table pointer
                    leay      Wt.CPX,y            point to current window co-ordinates
                    bsr       L1C64               (preserves X)
L1C2E               ldb       2,s                 get window X co-ordinate max.
                    clra                          Multiply x 8
                    IFNE      H6309
                    lsld
                    lsld
                    lsld
                    ELSE
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    ENDC
                    cmpd      ,x                  higher or lower than current mouse X co-ordinate
                    bhi       L1C5D               higher not in window, return carry set
                    ldb       $02,s               get window X co-ordinate
                    addb      $04,s               add it to size
                    clra                          Multiply x 8
                    IFNE      H6309
                    lsld
                    lsld
                    lsld
                    ELSE
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    ENDC
                    cmpd      ,x                  within range?
                    bls       L1C5D
* Check if mouse is within range of maximum Y co-ordinate of window
                    ldb       $03,s               get
                    clra                          Multiply x 8
                    IFNE      H6309
                    lsld
                    lsld
                    lsld
                    ELSE
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    ENDC
                    cmpd      $02,x
                    bhi       L1C5D
* Check if mouse is within Y lower range of window
                    ldb       $03,s               get Y co-ordinate of window
                    addb      $05,s               add in the size
                    clra                          Multiply x 8
                    IFNE      H6309
                    lsld
                    lsld
                    lsld
                    ELSE
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    ENDC
                    cmpd      $02,x               higher or lower than current mouse Y co-ordinate?
                    bls       L1C5D               lower, return mouse off window
                    clra                          flag mouse pointer is on this window
                    bra       L1C5E               return

L1C5D               coma                          flag pointer is off this window
L1C5E               ldy       ,s                  restore window table pointer
                    leas      6,s                 purge stack
                    rts                           return

L1C64               pshs      x                   preserve pointer to mouse working co-ordinates
                    pshs      y                   save pointer to window X/Y start co-ordinates
                    ldy       6,s                 get window table pointer
                    ldd       Wt.CPX,y            get current X & Y start co-ordinates
                    IFNE      H6309
                    ldw       Wt.LStDf,y          get screen logical start of full window
                    cmpw      Wt.LStrt,y          match current working area?
                    ELSE
                    pshs      x
                    ldx       Wt.LStDf,y          get screen logical start of full window
                    stx       >GrfMem+gr00B5
                    cmpx      Wt.LStrt,y          match current working area?
                    puls      x
                    ENDC
                    beq       L1C80               yes, skip ahead
                    addd      Wt.DfCPX,y          add current X/Y start to actual X/Y start
                    puls      y
                    bra       L1C88

L1C80               puls      y                   restore pointer to window X/Y start coords
                    bra       L1C86               skip ahead

L1C84               pshs      x                   preserve pointer to mouse working coords
L1C86               ldd       ,y                  get active window start X/Y default coords
L1C88               std       6,s                 save 'em
                    ldd       2,y                 get active window default sizes
                    std       8,s                 save 'em
                    ldx       4,s                 get current window table pointer
                    lda       Wt.BLnk,x           this a overlay window?
                    bmi       L1CBA               no we are the only window, return
L1C94               bsr       L1CBC               get window table pointer to the parent window
                    lda       Wt.BLnk,x           we at the bottom of the pile?
                    bpl       L1C94               no, keep going
                    ldd       $06,s               get active window start coords
                    IFNE      H6309
                    ldw       Wt.LStDf,x          get window logical start
                    cmpw      Wt.LStrt,x          same as current working area?
                    ELSE
                    pshs      y
                    ldy       Wt.LStDf,x          get window logical start
                    sty       >GrfMem+gr00B5
                    cmpy      Wt.LStrt,x          same as current working area?
                    puls      y
                    ENDC
                    bne       L1CB1               no, skip ahead
                    addd      Wt.DfCPX,x          add the start coord defaults of parent window
                    bra       L1CB8               save & return

L1CB1               addd      Wt.DfCPX,x          Add to original window default X,Y coord start
                    addd      Wt.CPX,x            add current window X,Y start coords of parent window
L1CB8               std       $06,s               save window start coords
L1CBA               puls      x,pc                restore & return

* Get pointer to window table entry
* Entry: A=Window table entry #
* Exit : X=Pointer to window table entry
L1CBC               ldb       #Wt.Siz             get size of entrys
                    mul                           calculate offset
                    ldx       #WinBase            Point X to window table start
                    IFNE      H6309
                    addr      d,x                 add offset
                    ELSE
                    leax      d,x                 add offset
                    ENDC
                    rts                           return

* Update mouse packet pointer status based on where it is (called from VTIO)
* This first checks the current CWArea (so does not include menu bar, or menu bar/scroll bars
*   (depending on whindow type).
* Entry: None
* Exit: Pt.Stat in mouse packet will contain:
*       0=Mouse in content region (current CWArea, ignoring any active overlay windows)
*       1=Mouse in control region (menu bar area or border/scroll area if CWArea not changed)
*       2=Mouse outside of current interactive window entirely
L1CC8               lbsr      L06A0               verify window (don't care about errors)
                    bsr       L1D24               copy current mouse coords to work area
                    pshs      x                   save pointer to mouse packet
                    leax      Pt.Siz,x            point to working coord copies
                    lbsr      L1C25               mouse in current working area of window? (not including menu bar/scroll areas)
                    bcs       L1CE2               No, clear relative coords in mouse packet & figure out if control region
                    bsr       L1CFA               Yes, update window relative mouse coords
                    clra                          get code for content region
L1CDD               puls      x                   restore mouse packet pointer
                    sta       Pt.Stat,x           save pointer type
                    clrb                          clear errors
                    rts

* Mouse is either in control region or off window, calculate which
L1CE2               equ       *
                    IFNE      H6309
                    clrd
                    clrw
                    stq       -4,x                clear out relative coords in mouse packet
                    ELSE
                    clra
                    clrb
                    std       >GrfMem+gr00B5      clear out relative coords in mouse packet
                    std       -4,x
                    std       -2,x
                    ENDC
                    lbsr      L1C19               mouse on full size of window (ignoring CWArea)?
                    lda       #WR.Cntrl           Default to Control Region (doesn't affect carry)
                    bcc       L1CDD               Yes, leave flag alone
                    inca                          Not on window, change flag to 2
                    bra       L1CDD

* Update window relative coords in mouse packet
* Entry: X=Ptr to mouse working coords
*        Y=Ptr to current window table
L1CFA               leas      -6,s                make a buffer
                    sty       ,s                  save window table pointer
                    leay      Wt.CPX,y            point to current window start coords
                    lbsr      L1C64               calculate window
                    ldb       2,s                 get window X size
                    clra                          Multiply x 8
                    IFNE      H6309
                    lsld
                    lsld
                    lsld
                    ldw       ,x                  get current mouse X coord
                    subr      d,w                 subtract it from size
                    stw       -4,x                save window relative X coord in mouse packet
                    ELSE
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    pshs      d
                    ldd       ,x                  get current mouse X coord
                    subd      ,s                  subtract it from size
                    std       -4,x                save window relative X coord in mouse packet
                    puls      d
                    ENDC
                    ldb       3,s                 get window Y size
                    clra                          Multiply x 8
                    IFNE      H6309
                    lsld
                    lsld
                    lsld
                    ldw       2,x                 get current mouse Y coord
                    subr      d,w                 subtract it from size
                    stw       -2,x                save window relative Y coord in mouse packet
                    ELSE
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    pshs      d
                    ldd       2,x                 get current mouse Y coord
                    subd      ,s                  subtract it from size
                    std       >GrfMem+gr00B5
                    std       -2,x                save window relative Y coord in mouse packet
                    puls      d
                    ENDC
                    ldy       ,s                  get window table pointer
                    leas      6,s                 purge stack & return
                    rts

* Copy current mouse coords to working area
L1D24               ldx       #WGlobal+G.Mouse    Point to mouse packet in global mem
                    IFNE      H6309
                    ldq       Pt.AcX,x            get current mouse coords
                    tim       #$01,[Wt.STbl,y]    640 pixel wide screen?
                    ELSE
                    ldd       Pt.AcY,x            Copy current mouse Y coord
                    std       >GrfMem+gr00B5
                    ldd       Pt.AcX,x            Get current mouse X coord
                    pshs      a
                    lda       [Wt.STbl,y]         640 pixel wide screen?
                    anda      #$01
                    puls      a
                    ENDC
                    bne       L1D47               yes, skip ahead
                    IFNE      H6309
                    lsrd                          320, divide X coord by 2
L1D47               stq       Pt.Siz,x            Save X&Y coords in working area (g005C/g005E)
                    ELSE
                    lsra                          320, divide X coord by 2
                    rorb
L1D47               pshs      d
                    ldd       >GrfMem+gr00B5
                    std       Pt.Siz+2,x          Save Y coord in working area (g005E)
                    puls      d
                    std       Pt.Siz,x            Save X coord in working area (g005C)
                    ENDC
                    rts                           return

                    ENDC

****************************
* Scale/DWProtSw/TCharSw/BoldSw
DWProtSw
TCharSw
BoldSw
PropSw
ScaleSw             lbsr      L06A0               verify window table
                    bcs       NoWind              not good, return error
                    lda       ,x                  Get switch
                    ldx       >WGlobal+G.CurDvM   Get current devices' static mem ptr
                    ldb       V.CallCde,x         Get which switch we will be setting
                    subb      #$22                Bump down to 0-8 range
                    bpl       doswitch            If anything but DWProtSW, skip ahead
                    clrb                          0=DWProtSW
doswitch            leax      <SwtchTbl,pc        Point to switch table
                    tsta                          On or Off?
                    bne       SwOn                On, go do
                    leax      10,x                Off, adjust for 2nd table
SwOn                jmp       b,x                 Go set/reset bit flag

NoWind              ldb       #E$WUndef           Window Undefined error
                    rts

* Table for switches
SwtchTbl            bra       DProtOn             Device window protect On
                    bra       TChrOn              Transparent chars On
                    bra       PropOn              Proportional On
                    bra       ScaleOn             Scaling On
                    bra       BoldOn              Bold On
                    bra       DProtOff            Device window protect Off
                    bra       TChrOff             Transparent chars Off
                    bra       PropOff             Proportional Off
                    bra       ScaleOff            Scaling Off
                    bra       BoldOff             Bold Off

DProtOn             equ       *
                    IFNE      H6309
                    oim       #Protect,Wt.BSW,y   Turn Device window protect on
                    ELSE
                    ldb       Wt.BSW,y            Turn Device window protect on
                    orb       #Protect
                    stb       Wt.BSW,y
                    ENDC
                    clrb                          No error & return
                    rts

DProtOff            equ       *
                    IFNE      H6309
                    aim       #^Protect,Wt.BSW,y  Turn Device window protect off
                    ELSE
                    ldb       Wt.BSW,y            Turn Device window protect off
                    andb      #^Protect
                    stb       Wt.BSW,y
                    ENDC
                    clrb                          No error & return
                    rts

TChrOff             equ       *
                    IFNE      H6309
                    oim       #TChr,Wt.BSW,y      Turn Transparency off
                    ELSE
                    ldb       Wt.BSW,y            Turn Transparency off
                    orb       #TChr
                    stb       Wt.BSW,y
                    ENDC
                    clrb                          No error & return
                    rts

TChrOn              equ       *
                    IFNE      H6309
                    aim       #^TChr,Wt.BSW,y     Turn Transparency on
                    ELSE
                    ldb       Wt.BSW,y            Turn Transparency on
                    andb      #^TChr
                    stb       Wt.BSW,y
                    ENDC
                    clrb                          No error & return
                    rts

PropOn              equ       *
                    IFNE      H6309
                    oim       #Prop,Wt.BSW,y      Turn Proportional on
                    ELSE
                    ldb       Wt.BSW,y            Turn Proportional on
                    orb       #Prop
                    stb       Wt.BSW,y
                    ENDC
                    clrb                          No error & return
                    rts

PropOff             equ       *
                    IFNE      H6309
                    aim       #^Prop,Wt.BSW,y     Turn Proportional off
                    ELSE
                    ldb       Wt.BSW,y            Turn Proportional off
                    andb      #^Prop
                    stb       Wt.BSW,y
                    ENDC
                    clrb                          No error & return
                    rts

ScaleOn             equ       *
                    IFNE      H6309
                    oim       #Scale,Wt.BSW,y     Turn Scaling on
                    ELSE
                    ldb       Wt.BSW,y            Turn Scaling on
                    orb       #Scale
                    stb       Wt.BSW,y
                    ENDC
                    clrb                          No error & return
                    rts

ScaleOff            equ       *
                    IFNE      H6309
                    aim       #^Scale,Wt.BSW,y    Turn Scaling off
                    ELSE
                    ldb       Wt.BSW,y            Turn Scaling off
                    andb      #^Scale
                    stb       Wt.BSW,y
                    ENDC
                    clrb                          No error & return
                    rts

BoldOn              equ       *
                    IFNE      H6309
                    oim       #Bold,Wt.BSW,y      Turn Bold on
                    ELSE
                    ldb       Wt.BSW,y            Turn Bold on
                    orb       #Bold
                    stb       Wt.BSW,y
                    ENDC
                    clrb                          No error & return
                    rts

BoldOff             equ       *
                    IFNE      H6309
                    aim       #^Bold,Wt.BSW,y     Turn Bold off
                    ELSE
                    ldb       Wt.BSW,y            Turn Bold off
                    andb      #^Bold
                    stb       Wt.BSW,y
                    ENDC
                    clrb                          No error & return
                    rts

                    IFNE      CoGrf-1
* FIXMENU - redos the graphics on the menu bar affected by menu pulldown
* Entry: X=Ptr to menu text (NUL terminated)
*        Y=Window table ptr
*        U=Ptr to menu handling table entry (4 byte packets)
*        B=Size of text to write (dont' need here)
*        A=End X coord of menu entry
* Exit: preserves x,y,u registers
* Stack offsets for temp stack:
fixcolor            equ       0
fixstrtx            equ       1
fixstrty            equ       3
fixendx             equ       5
fixendy             equ       7
fixcode             equ       9

* 1st, redo background
FixMenu             pshs      d,x                 Save # of chars & menu text ptr
                    leas      -10,s               Make room on stack for graphics "chunk"
                    IFNE      H6309
                    tfr       e,b                 Move calculated End X coord to D
                    ELSE
                    ldb       >GrfMem+gr00B5      Move calculated End X coord to D
                    ENDC
                    lda       MN.ID,x             Get menu ID #
                    cmpa      #MId.Tdy            Tandy menu (in which case E is fried)
                    bne       normalmn
                    ldb       MnuXEnd,u           Get real end coord
                    incb                          For space between it & next coord
* Draw 6 pixel high bar in middle
normalmn            clra
                    IFNE      H6309
                    lsld                          D=D*8 (for graphics X coord)
                    lsld
                    lsld
                    ELSE
                    lslb                          D=D*8 (for graphics X coord)
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    ENDC
                    std       fixendx,s           Save End X Coord
                    ldb       #WColor2            Light grey
                    stb       fixcolor,s          Save it
                    ldd       #1                  Y Pix start=1 (added since WColor now changeable)
                    std       fixstrty,s
                    ldb       #6                  Save Y pixel end
                    std       fixendy,s
                    ldb       MnuXStrt,u          Get start X coord
                    IFNE      H6309
                    lsld                          D=X coord in pixels
                    lsld
                    lsld
                    ELSE
                    lslb                          D=X coord in pixels
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    ENDC
                    std       fixstrtx,s          Save X pixel start
                    ldd       #$014e              1 function & GRFDRV Bar function code
                    stb       fixcode,s
                    leax      ,s                  Point to our "chunk"
                    lbsr      DrawBar             Draw the top line again
* Now redo top line
                    lda       #WColor3            Color 3
                    sta       fixcolor,s
                    IFNE      H6309
                    clrd                          Y coord=0
                    ELSE
                    clra
                    clrb
                    ENDC
                    std       fixstrty,s
                    std       fixendy,s
                    ldd       #$014a              1 function & Draw line GRFDRV function code
                    stb       fixcode,s
                    leax      ,s                  Point to our "chunk"
                    lbsr      DrawBar
* Now redo bottom line
                    lda       #WColor1            Dark Grey
                    sta       fixcolor,s
                    ldd       #7                  Y coord=7
                    std       fixstrty,s
                    std       fixendy,s
                    ldd       #$014a              1 function & GRFDRV Draw Line function code
                    stb       fixcode,s
                    leax      ,s                  Point to our "chunk"
                    lbsr      DrawBar
                    leas      10,s                Restore stack
                    puls      d,x,pc              Restore regs & return
                    ENDC

                    emod
eom                 equ       *
                    end
