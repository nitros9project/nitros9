********************************************************************
* CoVDG - CoCo 3 VDG I/O module
*
* $Id$
*
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   4      2003/01/09  Boisy G. Pitre
* Quite a few changes:
* - Merged in CoCo 2 gfx code from original OS-9 Level 2 code.
* - Incorporated code tweaks for 6809 and 6309 code from the vdgint_small
*   and vdgint_tiny source files.
* - Fixed long-standing cursor color bug.
* - Fixed long-standing F$SRtMem bug in CoCo 2 "graphics end" code $12
*   (see comments)
*
*   4r1    2003/09/16  Robert Gault
* Added patch to work 1MB and 2MB CoCo 3s.
*
*   1      2005/11/26  Boisy G. Pitre
* Renamed from VDGInt, reset edition.
*
*          2006/01/17  Robert Gault
* Changed the Select routine to permit the use of display 1b 21 within
* scripts when changing from a window to a vdg screen. See descriptions
* in cowin.asm. RG
*
*          2007/02/28  Robert Gault
* Changed the Line drawing routine to set the error at half the largest
* change to improve symmetry. Most noticeable in lines with either dX or
* dY = 1.
*
*          2018/12/15  LCB
* Reinstated Select checks to fix problems with VIEW, VIEWGIF and BOUNCE (would do Select
* calls to different windows even if user not on active screen).
* NEED TO ADD OPTIMIZATIONS TO LEVEL 1 FUNCTIONS THAT I ADDED TO LEVEL 1 COVDG!
*
*          2019/03/11  LCB
* Implemented Erik Gavriluk's more mathematically accurate composite color conversion
* table @ L012A
*          2019/03/12  LCB
* Shortened some branches, etc. to save a little room
*   2      2020/06/27  LCB
* Changed SS.ComSt SetStat to just lda R$Y,x (instead of D) since B immediately overrode anyways.
*          2022/07/12-18 LCB
* LINE fixed:
*   1) bad single bit pixel mask table
*   2) Missing initialization to 0 of a 16 bit number on stack

                    nam       CoVDG
                    ttl       CoCo 3 VDG I/O module

* Disassembled 98/09/31 12:15:57 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    use       cocovtio.d
                    use       vdgdefs
                    endc

FFStSz              equ       512                 flood fill stack size in bytes

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       2
COCO2               set       1                   1=Keep Coco 2 instructions

skip2               equ       $8C                 cmpx instruction

                    mod       eom,name,tylg,atrv,start,size

* Stack offsets for LINE command
                    org       0
LnPxMsk1            rmb       1                   (0) Pixel mask for byte from current Gfx Cursor X,Y coord of line
LnPxMsk2            rmb       1                   (1) Pixel mask for byte from caller specified X,Y coord
LnAddr1             rmb       2                   (2-3) Address on screen for user specified X,Y coord byte
LnCoords            rmb       2                   (4-5) Inited to $0000
LnXDir              rmb       1                   (6) X direction/offset (-1 or +1)
LnYDir              rmb       1                   (7) Y direction/offset (-32 or +32)
LnXDist             rmb       2                   (8-9) Distance between X coords
LnYDist             rmb       2                   ($A-$B) Distance between Y coords
LnX1                rmb       1                   ($C) User specified X coord for start of line
LnY1                rmb       1                   ($D) User specified Y coord for start of line
LnUnk3              rmb       1                   ($E) Unknown so far
LnStkSz             equ       .                   Size of Line temp stack


u0000               rmb       0
size                equ       .

                    fcb       $07

name                fcs       /CoVDG/
                    fcb       edition

* Init VDG screen (allocate memory, etc)
Init                pshs      u,y,x               save regs
                    bsr       SetupPal            set up palettes
                    lda       #$AF                Blue VDG char
                    sta       <VD.CColr,u         save as default color cursor
                    pshs      u
                    ldd       #768                gets 1 page on an odd page boundary
                    os9       F$SRqMem            request from top of sys ram
                    bcs       L00D6               error out of no system mem
                    tfr       u,d                 U = addr of memory
                    leax      ,u
                    bita      #$01                test to see if on even page
                    beq       IsEven              branch if even
                    leax      >256,x              else point 100 bytes into mem
                    bra       IsOdd               and free

IsEven              leau      >512,u              we only need 2 pages for the screen memory
IsOdd               ldd       #256                1 page return
                    os9       F$SRtMem            return system memory
                    puls      u
                    stx       <VD.ScrnA,u         save start address of the screen
                    stx       <VD.CrsrA,u         and cursor address
                    leax      >512,x              point to end of screen+1
                    stx       <VD.ScrnE,u         save it
                    lda       #$60                get default character (space)
                    sta       <VD.CChar,u         save as character under the cursor
* LCB: This should save to VD.CChar instead, and free VD.Chr1 up for some other use
                    sta       <VD.Chr1,u          only referenced here ??
                    lbsr      ClrScrn             clear the screen
                    inc       <VD.Start,u         increment VDG screen in use
                    ldd       <VD.Strt1,u         seemling useless??
                    lbsr      L054C               set to true lowercase, screen size
                    leax      <VD.NChar,u         Point to buffer where extra parameter bytes will be
                    stx       <VD.EPlt1,u         Save it
* LCB: Unused, should be able to remove & repurpose the 2 bytes
                    stx       <VD.EPlt2,u         And a copy
                    ldu       <D.CCMem            Get ptr to global mem
                    IFNE      H6309
                    oim       #$02,<G.BCFFlg,u    Flag VDGINT found
                    ELSE
                    ldb       <G.BCFFlg,u
                    orb       #$02                Flag VDGINT found
                    stb       <G.BCFFlg,u
                    ENDC
                    clrb                          No error & return
L00D6               puls      pc,u,y,x

SetupPal            pshs      u,y,x,d
* Apparently next two lines unused. I suspect something to do with Level 3 upgrade. Palette
*  flag of some sort. Maybe bits for palettes have changing, or palette animation enabled, or
*  palette animation speed?
                    lda       #$08
                    sta       <VD.PlFlg,u
                    leax      <L011A,pcr          Point to default 16 color palette table
                    leay      <VD.Palet,u         Point to where to put it for current VDG device (in it's static mem)
L00E6               leau      <L00F8,pcr          Point to "leave the RGB color alone" routine
                    IFNE      H6309
L00EA               tfr       u,w                 Move color conversion routine ptr to W
                    ELSE
L00EA               pshs      u                   Save color conversion routine ptr on stack
                    ENDC
                    leau      <L012A,pcr          Point to 64 color CMP to RGB conversion table
                    ldb       #16                 16 palettes to copy/convert
L00F2               lda       ,x+                 Get color from default
                    IFNE      H6309
                    jmp       ,w                  Convert or store, depending if composite or not
                    ELSE
                    jmp       [,s]
                    ENDC

* NOTE: Depending where this routine came from, Y can be a table for converted palettes in
*  RAM, or onto the actually GIME palette registers. While this may save a little code space,
*  this *will* cause GIME sparklies, as it can change palette register settings in the middle
*  of scanlines! This should be split apart like VDGInt 1.16 did. Or a flag set that we are
*  updating palettes, and let VSYNC IRQ check to see if flag set, and do palette settings with
*  HSYNC/SYNC safely to eliminate sparklies (in latter case, GRFDRV can do the same) LCB
* Cheap and dirty way is to set the HSYNC flag on PIA, and trigger each palette with SYNC
* instruction (similar to 1.16, but will take 16 syncs to finish, not 2 or 3).
L00F6               lda       a,u                 Get converted color
L00F8               sta       ,y+                 and save RGB version
                    decb                          Are we done all 16?
                    bne       L00F2               No, keep going until done
                    IFEQ      H6309
                    leas      2,s                 clean up stack
                    ENDC
L00FF               puls      pc,u,y,x,d

* If active screen, update actual palette registers (including RGB/Comp conversion if needed)
SetPals             pshs      u,y,x,d             puts palette data in.
                    lda       >WGlobal+G.CrDvFl   Are we on currently displayed screen?
                    beq       L00FF               0 = not active, exit without updating hardware
                    leax      <VD.Palet,u         point X to palette table
                    ldy       #$FFB0              point Y to palette register
                    lda       >WGlobal+G.MonTyp   Universal RGB/CMP 0 = CMP, 1 = RGB, 2 = MONO
                    bne       L00E6               if not composite, set U vector to not re-map colors
                    leau      <L00F6,pcr          else do re-map colors to composite
                    bra       L00EA

* Default palette data
L011A               fcb       $12,$36,$09,$24     Green, Yellow, Blue, Red
                    fcb       $3f,$1b,$2d,$26     Buff, Cyan, Magenta, Orange
                    fcb       $00,$12,$00,$3f     Black, Green, Black, Buff
                    fcb       $00,$12,$00,$26     Black, Green, Black, Orange

* converts CMP to RGB

* New table based on Erik Gavriluk's conversion chart. Will experiment with, but
*  Nick Marentes swears it is closer than the original table
L012A               fcb       $00,$0A,$03,$0E,$06,$09,$04,$10 0-7
                    fcb       $1B,$1B,$1C,$1C,$1A,$1B,$1C,$2B 8-15
                    fcb       $12,$1F,$22,$21,$13,$1F,$22,$21 16-23
                    fcb       $1E,$2D,$2F,$3E,$1E,$2C,$2F,$3E 24-31
                    fcb       $16,$18,$15,$17,$16,$27,$26,$26 32-39
                    fcb       $19,$2A,$29,$2A,$28,$29,$27,$39 40-47
                    fcb       $24,$24,$23,$22,$25,$25,$34,$34 48-55
                    fcb       $20,$3B,$31,$3D,$36,$38,$33,$30 56-63

* Original table
*L012A    fcb   $00,$0c,$02,$0e,$07,$09,$05,$10  $00-$07
*         fcb   $1c,$2c,$0d,$1d,$0b,$1b,$0a,$2b  $08-$0F
*         fcb   $22,$11,$12,$21,$03,$01,$13,$32  $10-$17
*         fcb   $1e,$2d,$1f,$2e,$0f,$3c,$2f,$3d  $18-$1F
*         fcb   $17,$08,$15,$06,$27,$16,$26,$36  $20-$27
*         fcb   $19,$2a,$1a,$3a,$18,$29,$28,$38  $28-$2F
*         fcb   $14,$04,$23,$33,$25,$35,$24,$34  $30-$37
*         fcb   $20,$3b,$31,$3e,$37,$39,$3f,$30  $38-$3F

* Terminate device
Term                pshs      u,y,x
                    ldb       #$03
L004E               pshs      b
                    lbsr      GetScrn             get screen table entry into X
                    lbsr      FreeBlks            free blocks used by screen
                    puls      b                   get count
                    decb                          decrement
                    bne       L004E               branch until zero
                    clr       <VD.Start,u         no screens in use
                    ldd       #512                size of alpha screen
                    ldu       <VD.ScrnA,u         get pointer to alpha screen
                    beq       ClrStat             branch if none
                    os9       F$SRtMem            else return memory

* 6809/6309 stack blast clear or TFM (vector once installed)
ClrStat             ldb       #$E1                size of 1 page -$1D (SCF memory requirements)
                    leax      <VD.Strt1,u         point to start of VDG statics
L006F               clr       ,x+                 set stored byte to zero
                    decb                          decrement
                    bne       L006F               until zero
                    clrb
                    puls      pc,u,y,x

* Entry point from VTIO. Eventually, we will want to change the Write routine to
*  handle buffered writes (will require changing SCF as well, I think) like CoWin/Grf
*  & grfdrv do). Ultimately by device driver & descriptor
start               lbra      Init                Initialize VDG window
                    bra       Write               Write character (also sets up multi-byte parm count/vector)
                    nop       Can                 use for a constant
                    lbra      GetStat             Co-module GetStat calls
                    lbra      SetStat             Co-moudle SetStat calls
                    bra       Term
                    nop       Can                 use for a constant
* fall through - CoWinSpc Special processing entry point (special to Level II) - last entry table
* Called from VTIO
* Entry:  A = function code
*           0 = select new window to be active (should set screen mode, address & palettes)
*           1 = update mouse packet
*          >1 = only used by CoGrf/CoWin
*         U = device memory pointer
*         X = path descriptor pointer
                    tsta                          Select new window to be active?
                    bne       L0035               No, try next function code
* Select new window to be active
                    ldb       <VD.DGBuf,u         Yes, get number of currently displayed buffer
                    lbne      ShowS               Not primary buffer, go handle
                    ldd       <VD.TFlg1,u         Primary, get bits to set in $FF22 and VD.Alpha (0=alpha mode)
                    lbra      DispAlfa            Update the hardware

L0035               deca                          Update mouse packet function code?
                    beq       L003B               branch if so
                    clrb                          Nothing CoVDG handles, exit with no errors
                    rts

* Update mouse packet (basically copies current actual mouse X,Y coords to window relative
*   versions).
L003B               ldx       <D.CCMem            pointer to start of CoWin global memory
                    leax      <G.Mouse+Pt.AcX,x   Point to actual X,Y coord of mouse in mouse packet
                    IFNE      H6309
                    ldq       ,x                  get actual mouse X,Y coordinate
                    stq       Pt.WRX-Pt.AcX,x     ($04,x) copy to window relative mouse X,Y coordinate
                    ELSE
                    ldd       ,x                  Get actual mouse X coord
                    std       Pt.WRX-Pt.AcX,x     ($04,x) Copy to window relative mouse X coord
                    ldd       Pt.AcY-Pt.AcX,x     ($02,x) Get actual mouse Y coord
                    std       Pt.WRY-Pt.AcX,x     ($06,x) Copy to window relative mouse Y coord
                    ENDC
NoOp                clrb
                    rts

* NOTE: We should change this to use the 32 byte write buffer like grfdrv does (requires
* change to SCF as well). Buffer might be part of static mem? LCB
* Also use proposed SCF buffered write attribute bit
* Entry: A = char to write
*        Y = path desc ptr
Write               equ       *
                    IFNE      COCO2
                    cmpa      #$0F                Special control char (including Coco 1/2 graphics commands)
                    ELSE
                    cmpa      #$0E                Special control char (not including Coco 1/2 graphics commands)
                    ENDC
                    bls       Dispatch            Yes, dispatch from table
                    cmpa      #$1B                escape code?
                    lbeq      Escape              yes, do escape immediately
                    IFNE      COCO2
                    cmpa      #$1E                $10-1E codes (Coco 1/2 graphics commands)?
                    blo       Do1E                Yes, go do
                    cmpa      #$1F                Any other control codes go to dispatch table
                    bls       Dispatch
                    ELSE
                    cmpa      #$1F
                    bls       NoOp                ignore gfx codes if not CoCo 2 compatible
                    ENDC
                    tsta                          Non control char; is it a high bit char?
                    bmi       L01BA               Yes, go convert to appropriate VDG char
                    ldb       <VD.CFlag,u         Get true lowercase flag
                    beq       L019A               Uppercase only, skip ahead
* Special char replacements if true lowercase enabled (either Coco 3 or Coco 2/T1-VDG)
                    cmpa      #'^                 $5E carat symbol?
                    bne       L018A               No, check next
                    clra                          Carat is VDG char 0 (when true lowercase enabled)
                    bra       L01BA               Put it on screen

L018A               cmpa      #$5F                '_' Underscore char?
                    bne       L0192               No, check next
                    lda       #$1F                VDG underscore char (when true lowercase enabled)
                    bra       L01BA

L0192               cmpa      #$60                ' single quote char?
                    bne       L01AA               No, check next
                    lda       #$67                VDG single quote char (when true lowercase enabled)
                    bra       L01BA

* char replacements for uppercase only/inverse video mode
L019A               cmpa      #$7C                Pipe '|' char?
                    bne       L01A2               No, check next
                    lda       #$21                Inverted exclamation mark char
                    bra       L01BA               Put on screen

L01A2               cmpa      #$7E                '~' tilde char?
                    bne       L01AA               No, all other chars have common conversion between both modes
                    lda       #$2D                VDG inverted '-' char
                    bra       L01BA               Put on screen

* char replacements for both text modes
L01AA               cmpa      #$60                Possible alphabetic char?
                    blo       L01B2               Yes, finish alphabetic check
                    suba      #$60                Anything higher than CHR$($5F) shifts down $60 for VDG
                    bra       L01BA               Write that to screen

L01B2               cmpa      #$40                Char below $40?
                    blo       L01B8               Yes, flip case bit only
                    suba      #$40                Drop for VDG
L01B8               eora      #$40                Force to non-inverse chars on regular VDG
L01BA               ldx       <VD.CrsrA,u         Get address of cursor
                    sta       ,x+                 Save char to screen at that address
                    stx       <VD.CrsrA,u         Save updated cursor address
                    cmpx      <VD.ScrnE,u         Hit end of screen?
                    blo       L01CA               No, update cursor display on screen & return
                    lbsr      SScrl               Yes, scroll screen
L01CA               lbra      ShowCrsr            Display cursor in new position, return from theres

                    IFNE      COCO2
Do1E                lbsr      ChkDvRdy            Is device ready to handle characters?
                    bcc       Dispatch            Yes go process, else return
                    rts
                    ENDC

* Entry: A=CHR$() code
Dispatch            leax      <DCodeTbl,pcr       Point to dispatch table
                    lsla                          2 bytes/entry
                    ldd       a,x                 Get offset to subroutine we want
                    jmp       d,x                 And jump to it

DCodeTbl            fdb       NoOp-DCodeTbl       $00 - No Operation
                    fdb       CurHome-DCodeTbl    $01 - Home Cursor
                    fdb       CurXY-DCodeTbl      $02 - Move Cursor
                    fdb       DelLine-DCodeTbl    $03 - Delete Line
                    fdb       ErEOLine-DCodeTbl   $04 - Erase to End Of Line
                    fdb       CrsrSw-DCodeTbl     $05 - Switch Cursor Color
                    fdb       CurRght-DCodeTbl    $06 - Move Cursor Right
                    fdb       NoOp-DCodeTbl       $07 - Bell (Handled by VTIO)
                    fdb       CurLeft-DCodeTbl    $08 - Move Cursor Left
                    fdb       CurUp-DCodeTbl      $09 - Move Cursor Up
                    fdb       CurDown-DCodeTbl    $0A - Move Cursor Down
                    fdb       ErEOScrn-DCodeTbl   $0B - Erase to End Of Screen
                    fdb       ClrScrn-DCodeTbl    $0C - Clear Screen
                    fdb       Retrn-DCodeTbl      $0D - Carriage Return
                    fdb       Do0E-DCodeTbl       $0E - Display Alpha Screen

* Coco 1/2 graphics mode commands
                    IFNE      COCO2
                    fdb       Do0F-DCodeTbl       $0F - Display Graphics
                    fdb       Do10-DCodeTbl       $10 - Preset Screen
                    fdb       Do11-DCodeTbl       $11 - Set Color
                    fdb       Do12-DCodeTbl       $12 - End Graphics
                    fdb       Do13-DCodeTbl       $13 - Erase Graphics
                    fdb       Do14-DCodeTbl       $14 - Home Graphics Cursor
                    fdb       Do15-DCodeTbl       $15 - Set Graphics Cursor
                    fdb       Do16-DCodeTbl       $16 - Draw Line
                    fdb       Do17-DCodeTbl       $17 - Erase Line
                    fdb       Do18-DCodeTbl       $18 - Set Point
                    fdb       Do19-DCodeTbl       $19 - Erase Point
                    fdb       Do1A-DCodeTbl       $1A - Draw Circle
                    fdb       Escape-DCodeTbl     $1B - Escape
                    fdb       Do1C-DCodeTbl       $1C - Erase Circle
                    fdb       Do1D-DCodeTbl       $1D - Flood Fill
                    fdb       NoOp-DCodeTbl       $1E - No Operation
                    fdb       NoOp-DCodeTbl       $1F - No Operation
                    ENDC

* $1B does palette changes
Escape              ldx       <VD.EPlt1,u         now X points to level
                    lda       ,x                  get char following
                    cmpa      #$30                Set default colors?
                    bne       L0209               No, check next
                    lbsr      SetupPal            Yes, reset palettes to default
                    bra       L026E               And copy to active palette for device (and screen if we are active device)

L0209               cmpa      #$31                change palette?
                    IFNE      COCO2
                    beq       PalProc             branch if so
                    cmpa      #$21                Select?
                    bne       L0248               No, return without error
                    ldx       PD.RGS,y            Yes, get ptr to callers registers
                    lda       R$A,x               get path
                    ldx       <D.Proc             get current proc
                    cmpa      >P$SelP,x           Is selected window path the same as the active processes?
                    beq       L0249               Yes, nothing to do, so return
                    ldb       >P$SelP,x           No, Get current processes' active window path
                    sta       >P$SelP,x           replace with path to selected window
                    pshs      y                   save our path desc ptr
                    bsr       L024A               get ptr to device table entry for path into Y
                    ldy       V$STAT,y            get static mem ptr for that window
                    ldx       <D.CCMem            get ptr to CoWin global memory
                    cmpy      <G.CurDev,x         Static mem ptr for new window path same as current viewed window?
                    puls      y                   restore our path desc ptr
                    bne       L0248               Not on viewable screen; don't change anything else and return
                    inc       <VD.DFlag,u         We ARE on viewable screen (different window on screen)
                    ldy       <G.CurDev,x         get static mem ptr to current device window
                    sty       <G.PrWMPt,x         Save as "previous" device window
                    stu       <G.CurDev,x         Save newly selected device window as current viewable device window
* Give system a chance to stabilize. RG
* LCB - Once we fix up Clock to handle properly setting GIME/VDG registers for new windows, palettes,
*  etc., then we should be able to eliminate this Sleep call.
                    ldx       #2
                    os9       F$Sleep
L0248               clrb
L0249               rts

* Only called from L0209 above (could embed, shrink code a tiny bit)
* Entry: A = path to process
* Exit: Y=ptr to device table entry for requested path
L024A               leax      <P$Path,x           point to path table in process descriptor
                    lda       b,x                 get system path number
                    ldx       <D.PthDBT           point to path descriptor base table
* protect regB incase of error report. RG
* LCB - I am confused here - This ends up eating any error code from F$Find64 (although it
*   will leave carry set).
                    pshs      b
                    os9       F$Find64            Get ptr to path descriptor for path # in A
                    ldy       PD.DEV,y            Get device table entry ptr for path
                    puls      b,pc
                    ELSE
                    bne       NoOp
                    ENDC

PalProc             leax      <DoPals,pcr         Point to update palette register routine
                    ldb       #$02                Get 2 more chars from input to get palette register # & color #
                    lbra      GChar               and go to DoPals when done

* Update palette register (1b 31 rr pp)
DoPals              ldx       <VD.EPlt1,u         Get ptr to parameter byte(s). hardcode value now, change later when buffering added
                    ldd       ,x                  Get 2 parameter bytes
                    cmpa      #16                 Make sure palette # in range
                    lbhi      IllArg
                    cmpb      #63                 Make sure color in range
                    lbhi      IllArg
                    leax      <VD.Palet,u         Point to current palette settings
                    stb       a,x                 save new value
L026E               lbsr      SetPals             Actually change palette
                    clrb
                    rts

*         anda  #$0F
*         andb  #$3F
*         leax  <VD.Palet,u
*         stb   a,x
*L026E    inc   <VD.DFlag,u
*         clrb
*         rts

* Screen scroll.
SScrl               ldx       <VD.ScrnA,u         Get ptr to 32x16 screen
                    IFNE      H6309
                    ldd       #$2060              A=width of line in bytes, B=VDG space char
                    leay      a,x                 Y=screen address + down one line
                    ldw       #512-32             Block move 15 of 16 lines
                    tfm       y+,x+               scroll screen up
                    stx       <VD.CrsrA,u         save new cursor address (1st char on last line)
                    ELSE
* Replace with StkBlCpy vector later for 6809 portion
                    leax      <32,x               Point to start of 2nd line
L0279               ldd       ,x++                Grab 2 chars
                    std       <-34,x              Save on line above
                    cmpx      <VD.ScrnE,u         Done screen?
                    blo       L0279               No, keep scrolling
                    leax      <-32,x              Done, point 1ast char on last line
                    stx       <VD.CrsrA,u         Save as new cursor position
                    lda       #32                 # chars to clear on last line
                    ldb       #$60                VDG char for space
                    ENDC
* 6809 - StkBlClr, 6309 - TFM
L028D               stb       ,x+                 Clear last line
                    deca
                    bne       L028D
                    rts

* $0D - carriage return
Retrn               bsr       HideCrsr            hide cursor
                    IFNE      H6309
                    aim       #$E0,<VD.CrsAL,u    strip out bits 0-4
                    ELSE
                    tfr       x,d
                    andb      #$E0                strip out bits 0-4
                    stb       <VD.CrsAL,u         save updated cursor address
                    ENDC
ShowCrsr            ldx       <VD.CrsrA,u         get cursor address
                    lda       ,x                  get char at cursor position
                    sta       <VD.CChar,u         save it
                    lda       <VD.CColr,u         get cursor character
                    beq       RtsOk               If none, don't save anything to screen
L02A9               sta       ,x                  Display cursor on screen
RtsOk               clrb
                    rts

* $0A - moves cursor down
CurDown             bsr       HideCrsr            hide cursor
                    leax      <32,x               move X down one line
                    cmpx      <VD.ScrnE,u         at the end of the screen?
                    bcs       L02C1               branch if not
                    leax      <-32,x              else go back up one line
                    pshs      x                   save X
                    bsr       SScrl               and scroll the screen
                    puls      x                   and restore pointer
L02C1               stx       <VD.CrsrA,u         save cursor pointer
                    bra       ShowCrsr            show cursor

* $08 - moves cursor left one
CurLeft             bsr       HideCrsr            hide cursor
                    cmpx      <VD.ScrnA,u         compare against start of screen
                    bls       ShowCrsr            ignore it if at the screen start
                    leax      -$01,x              else back up one
                    stx       <VD.CrsrA,u         save updated pointer
                    bra       ShowCrsr            and show cur

* $06 - moves cursor right one
CurRght             bsr       HideCrsr            hide cursor
                    leax      1,x                 move to the right
                    cmpx      <VD.ScrnE,u         compare against start of screen
                    bhs       ShowCrsr            if past end, ignore it
                    stx       <VD.CrsrA,u         else save updated pointer
                    bra       ShowCrsr            and show cursor

* $0B - erase from current char to end of screen
ErEOScrn            bsr       HideCrsr            kill the cursor
                    fcb       skip2
* $0C - clear screen & home cursor
ClrScrn             bsr       CurHome             home cursor (returns X pointing to start of screen)
                    lda       #$60                get default char
ClrSLoop            sta       ,x+                 save at location
                    cmpx      <VD.ScrnE,u         end of screen?
                    blo       ClrSLoop            branch if not
                    bra       ShowCrsr            now show cursor

* $01 - Homes the cursor
CurHome             bsr       HideCrsr            hide cursor
                    ldx       <VD.ScrnA,u         get pointer to screen
                    stx       <VD.CrsrA,u         save as new cursor position
                    bra       ShowCrsr            and show it

* Hides the cursor from the screen
* Exit: X = address of cursor
HideCrsr            ldx       <VD.CrsrA,u         get address of cursor in X
                    lda       <VD.CChar,u         get value of char under cursor
                    sta       ,x                  put char in place of cursor
                    clrb                          must be here, in general, for [...] BRA HideCrsr
                    rts

* $05 - turns cursor on/off, color
CrsrSw              lda       <VD.NChar,u         get next char
                    suba      #C$SPAC             adjust to 0 & up
                    bne       L0313               Cursor on, go process
                    sta       <VD.CColr,u         else save cursor color zero (no cursor)
                    bra       HideCrsr            and hide cursor

L0313               cmpa      #$0B                greater than $0A (max color allowed)?
                    bge       RtsOk               yep, just ignore it
                    cmpa      #$01                is it one (default blue cursor)?
                    bgt       L031F               No, specific color requested
                    lda       #$AF                Yes, default blue cursor color
                    bra       L032F               and save cursor color

L031F               cmpa      #$02                is it two (default black cursor)?
                    bgt       L0327               Yes, specific color requested by user
                    lda       #$A0                else save  black cursor color
                    bra       L032F

L0327               suba      #$03                Adjust for color
                    lsla                          shift into upper nibble
                    lsla
                    lsla
                    lsla
                    ora       #$8F                merge full 2x2 semigraphics block base character
L032F               sta       <VD.CColr,u         save new cursor
                    ldx       <VD.CrsrA,u         get cursor address
                    lbra      L02A9               branch to save cursor in X

* $02 - moves cursor to X,Y
CurXY               ldb       #$02                we want to claim the next two chars
                    leax      <DoCurXY,pcr        point to processing routine
                    lbra      GChar               get two chars

DoCurXY             bsr       HideCrsr            hide cursor
                    ldb       <VD.NChr2,u         get ASCII Y-pos
                    subb      #C$SPAC             adjust to base 0
                    lda       #32                 * 32 chars/line
                    mul
                    addb      <VD.NChar,u         add in X-pos
                    adca      #$00
                    subd      #C$SPAC             take out another ASCII space
                    addd      <VD.ScrnA,u         add top of screen address
                    cmpd      <VD.ScrnE,u         at end of the screen?
                    lbhs      RtsOk               exit if off the screen
                    std       <VD.CrsrA,u         otherwise save new cursor address
                    lbra      ShowCrsr            and show cursor

* $04 - clear characters to end of line
ErEOLine            bsr       HideCrsr            hide cursor
                    tfr       x,d                 move current cursor position to D
                    andb      #$1F                number of characters put on this line
                    negb                          negative
                    bra       L0374               and clear one line

* $03 - erase line cursor is on
DelLine             lbsr      Retrn               do a carriage return
L0374               addb      #32                 B = $00 from Retrn
L0376               lda       #$60                get default VDG space char
                    ldx       <VD.CrsrA,u         get cursor address
* 6809-May be able to use StkBlClr, and 6309 TFM
L037B               sta       ,x+                 save default char
                    decb                          decrement
                    bne       L037B               and branch if not end
                    lbra      ShowCrsr            else show cursor

* $09 - moves cursor up one line
CurUp               lbsr      HideCrsr            hide cursor
                    leax      <-32,x              move X up one line
                    cmpx      <VD.ScrnA,u         compare against start of screen
                    lbcs      ShowCrsr            branch if we went beyond
                    stx       <VD.CrsrA,u         else store updated X
L0391               lbra      ShowCrsr            and show cursor

* $0E - switches from graphics to alpha mode
Do0E                equ       *
                    IFNE      H6309
                    clrd
                    ELSE
                    clra
                    clrb
                    ENDC
* Entry: A=video bits to merge into $FF22
*        B=video type (0=text screen, else medium res graphics)
DispAlfa            pshs      x,y,a               Preserve regs (A=video bits to merge into $FF22)
                    IFNE      COCO2
                    stb       <VD.Alpha,u         0=Alpha mode, else graphics mode
                    ENDC
                    clr       <VD.DGBuf,u         Clear currently displayed medium res buffer # (inactive)
                    lda       >PIA1Base+2         Get current screen mode settings byte from PIA
                    anda      #%00000111          Only keep non-video bits
                    ora       ,s+                 Merge in video bits we saved on stack
                    tstb                          Are we in text or graphics mode?
                    bne       L03AD               Graphics, skip ahead
                    anda      #%11101111          Zero out true lowercase flag
                    ora       <VD.CFlag,u         merge in current display true lowercase flag
L03AD               sta       <VD.TFlg1,u         save updated VDG info
                    tst       >WGlobal+G.CrDvFl   Are we active device?
                    lbeq      L0440               No, skip ahead
                    sta       >PIA1Base+2         Yes, set lowercase in hardware
                    ldy       #$FFC6              Ok, now set up via old CoCo 2 mode the graphics video mode.
                    IFNE      COCO2
                    tstb                          Text screen?
                    bne       L03CB               No, set up for graphics
                    ENDC
* Set up VDG screen for text
                    stb       -6,y                $FFC0
                    stb       -4,y                $FFC2
                    stb       -2,y                $FFC4
                    lda       <VD.ScrnA,u         Get start screen address MSB (always even $200)
                    IFNE      COCO2
                    bra       L03D7

* Set up VDG screen for graphics
L03CB               stb       -6,y                $FFC0
                    stb       -3,y                $FFC3
                    stb       -1,y                $FFC5
                    lda       <VD.SBAdd,u         Get address of block screen is in
                    ENDC
L03D7               lbsr      SetPals             Set palettes
                    ldb       <D.HINIT            Get current GIME Init0 ghost register settings
                    orb       #$80                set CoCo 2 compatible mode
                    stb       <D.HINIT            Save updated ghost copy
                    stb       >$FF90              And to actual GIME
                    ldb       <D.VIDMD            Get current GIME Video mode ghost register settings
                    andb      #%01111000          text mode, 1 line per row
                    stb       >$FF98              Save onto actual GIME
                    stb       <D.VIDMD            and ghost register copy
                    pshs      a                   Save MSB of screen address
                    IFNE      H6309
                    clrd
                    ELSE
                    clra
                    clrb
                    ENDC
                    std       >$FF99              set resolution AND border color (to black)
                    std       <D.VIDRS            And save ghost copies
                    puls      a                   Get MSB of screen address back
                    tfr       a,b                 Dupe into B
                    anda      #$1F
                    pshs      a
                    andb      #$E0                Calc 8K MMU block offset
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    ldx       <D.SysDAT           Get ptr to system process DAT image
                    abx                           Point to block we will map screen into
* PATCH START: Mod for >512K systems, Robert Gault
                    ldb       1,x                 get block number to use
                    pshs      b
                    andb      #$F8                keep high bits only
                    clra
                    lslb
                    rola
                    lslb
                    rola
                    sta       >$FF9B              Select 512K video bank for >512K machines
                    tfr       b,a
                    clrb
* PATCH END: Mod for >512K systems, Robert Gault
                    std       <D.VOFF1            Save ghost copy of vertical offset register
                    std       >$FF9D              And to actual GIME
                    ldd       #$0F07              Vertical smooth scroll=$0F, 7 SAM register bit settings to set for screen address
                    sta       <D.VOFF2            Save ghost copy of vertical smooth scroll setting
                    sta       >$FF9C              And to actual GIME
                    puls      a                   Shift out address offset for VDG/SAM registers
                    asla
                    asla
                    asla
                    asla
                    asla
                    ora       ,s+
                    lsra
L0430               lsra                          Write to $FFC6+ - 0 bits are even addresses, 1 bits are odd addresses
                    bcc       L041A               Even, clear SAM bit
                    leay      1,y                 Odd, set SAM bit
                    sta       ,y+
                    fcb       skip2               skip 2 bytes
L041A               sta       ,y++                rather than additional leax 1,x on next line
                    decb                          Are we done all 7 SAM video address registers?
                    bne       L0430               No, keep doing until done
L0440               clrb                          No error & return
                    puls      pc,y,x

GChar1              ldb       #$01                Flag that we need 1 more parameter byte
GChar               stb       <VD.NGChr,u         Save # of parameter bytes needed for command currently being processed
                    stx       <VD.RTAdd,u         Save address to go to once we have all parameter bytes
                    clrb                          No error & return
                    rts

                    IFNE      COCO2
* $0F - display graphics
Do0F                leax      <DispGfx,pcr        Point to Display graphics routine
                    ldb       #$02                And we need to 2 more parameter bytes
                    bra       GChar               Go get them, then call routine

DispGfx             ldb       <VD.Rdy,u           memory already allocated (and thus ready)?
                    bne       L0468               Yes, skip ahead
                    lbsr      Get8KHi             else get an 8k block from high ram
                    bcs       L0486               branch if error
                    stb       <VD.GBuff,u         save as start block # if high res graphics
                    stb       <VD.Blk,u           save starting block number if semigraphics or medium res
                    tfr       d,x
                    ldd       <D.Proc             Get current process desc. ptr
                    pshs      u,d                 Save regs
                    ldd       <D.SysPrc           get system proc desc
                    std       <D.Proc             make current
                    ldb       #$01                one block
                    os9       F$MapBlk            map it in to our space
                    leax      ,u                  get address into x
                    puls      u,d                 restore other regs
                    std       <D.Proc             restore process pointer
                    bcs       L0486               exit if error mapping block
                    stx       <VD.SBAdd,u         else store address of gfx mem
                    inc       <VD.Rdy,u           Flag that video RAM is ready
                    ldd       #$0120              A=$01 (mark system pages as used), $20=32 pages to mark (1 full 8K blocks worth)
                    bsr       L04D9               Go mark that 8K block of system RAM as used
                    lbsr      Do13                erase gfx screen
L0468               lda       <VD.NChr2,u         get color set parameter byte
                    sta       <VD.PMask,u         store color set (0-3)
                    anda      #$03                mask off pertinent bits
                    leax      >Mode1Clr,pcr       point to color mask full byte table
                    lda       a,x                 get color mask full byte for color A
                    sta       <VD.Msk1,u          save color mask
                    sta       <VD.Msk2,u          and here
                    lda       <VD.NChar,u         get mode parameter byte (0=2 color, 1=4 color)
                    cmpa      #$01                compare against max allowed
                    bls       L0487               process if valid
                    comb
                    ldb       #E$BMode            else exit with Bad Mode error
L0486               rts

L0487               tsta                          test user supplied mode byte
                    beq       L04A7               If 256x192x2, go set up for that
* 128 x 192 x 4 set up
                    ldd       #$C003              128x192x4, save first and last pixel in a byte masks
                    std       <VD.MCol,u
                    lda       #$01                Save 128x192x4 mode
                    sta       <VD.Mode,u
                    lda       #$E0                VDG byte base setting for $FF22 defaults to PMODE 3
                    ldb       <VD.NChr2,u         Get color/color set byte again
                    andb      #$08                Just keep "pure" graphics mode vs. artificated colors bit
                    beq       L04A0               If pure mode, keep $E0 VDG setting
                    lda       #$F0                If artifact, change to $F0 (PMODE 4)
L04A0               ldb       #%00000011          Mask of bits per pixel
                    leax      <L04EB,pcr          Point to table of four 4 color pixel masks
                    bra       L04C4

* 256 x 192 x 2 set up
L04A7               ldd       #$8001              256x192x2, save first and last pixel in a byte masks
                    std       <VD.MCol,u
                    lda       #$FF                Hi bit set=2 color PMODE 4 mode, and full color mask byte (all white/2 color)
                    tst       <VD.Msk1,u          Is there a mask set up?
                    beq       L04BA               No, skip ahead
                    sta       <VD.Msk1,u          Save full byte color mask
                    sta       <VD.Msk2,u          and again
L04BA               sta       <VD.Mode,u          256x192 mode (hi bit set to indicate 2 color/256 x 192)
                    ldd       #$F007
                    leax      <L04EF,pcr          Point to 8 pixel masks for 2 color mode
L04C4               stb       <VD.PixBt,u         # of pixels per byte (base 0)
                    stx       <VD.MTabl,u         Save ptr to 2 color mode pixel mask table
                    ldb       <VD.NChr2,u
                    andb      #$04
                    lslb
* 6309 - ORR B,A replaces 2 lines
                    pshs      b
                    ora       ,s+
                    ldb       #$01
* Indicate screen is current; next line is critical for >512K - Robert Gault
                    stb       >WGlobal+G.CrDvFl   is this screen currently showing?
                    lbra      DispAlfa

* Entry: X=ptr to screen as mapped into system space
*        B=# of 256 byte pages to mark
*        A=mark flag (0=deallocate system pages, 1=allocated system pages)
L04D9               pshs      x,d                 Save screen ptr & (de)allocate parameters
                    clra
                    ldb       2,s                 Get high byte of screen ptr
                    ldx       <D.SysMem           Get ptr to system memory map
                    leax      d,x                 Point to that MMU block offset
                    puls      d                   Get allocate flag & number of 256 byte system pages to mark
L04E4               sta       ,x+                 Mark them
                    decb
                    bne       L04E4
                    puls      pc,x                Restore X & return

* 4 color pixel masks
L04EB               fcb       %11000000
                    fcb       %00110000
                    fcb       %00001100
                    fcb       %00000011

* 2 color pixel masks
L04EF               fcb       %10000000
                    fcb       %01000000
                    fcb       %00100000
                    fcb       %00010000
                    fcb       %00001000
                    fcb       %00000100
                    fcb       %00000010
                    fcb       %00000001

* $11 - set color
Do11                leax      <SetColor,pcr       Point to Set color routine
                    lbra      GChar1              Get 1 more parameter, then call routine

SetColor            lda       <VD.NChar,u         get foreground color #
                    sta       <VD.NChr2,u         save copy
L0503               clr       <VD.NChar,u         clear original parameter byte
                    lda       <VD.Mode,u          which mode?
                    bmi       L050E               if 256x192, leave 1st parameter byte as 0
                    inc       <VD.NChar,u         If 128x192, change 1st parameter byte to 1
L050E               lbra      L0468               Set things up

* $12 - end graphics
Do12                ldx       <VD.SBAdd,u         get address of where 8K block with graphics screen is
                    beq       L051B               None, skip ahead
                    ldd       #$0020              A=0 (deallocate) B=32 (32 system pages (256 bytes each))
                    bsr       L04D9               Deallocate 8K system RAM from system map
L051B               leay      <VD.GBuff,u         point Y to graphics screen block numbers
                    ldb       #$03                number of possible screens allocated starting at VD.GBuff
                    pshs      u,b                 save our static pointer, and counter (3)
L0522               lda       ,y+                 get next medium res screen block #
                    beq       L052D               unused, continue
                    clrb                          Use, move block # to X
                    tfr       d,x
                    incb                          1 block to deallocate
                    os9       F$DelRAM            deallocate it from main RAM
L052D               dec       ,s                  dec # of screens to check
                    bgt       L0522               until all 3 possible medium res screens are done.
                    ldu       VD.FFMem-VD.HiRes,y Get flood fill stack memory ptr
                    beq       L053B               No flood fill stack, so skip returning RAM
                    ldd       #FFStSz             flood fill stack size
                    os9       F$SRtMem            Return flood fill stack memory to system (512 bytes)
L053B               puls      u,b                 Restore stack mem ptr & eat counter
                    clr       <VD.Rdy,u           Flag that device not ready (no screen allocated)
                    lbra      Do0E                Switch to alpha text screen and return from there

* $10 - preset screen to a specific color
Do10                leax      <PrstScrn,pcr       Point to routine to Preset screen
                    lbra      GChar1              Go get 1 more parameter (preset color)

PrstScrn            lda       <VD.NChar,u         Get PRESET color
                    tst       <VD.Mode,u          which mode?
                    bpl       L0559               branch if 128x192 4 color
                    ldb       #$FF                assume we will clear with $FF
                    anda      #$01                mask out all but 1 bit (2 colors)
                    beq       Do13                erase graphic screen with color $00
                    bra       L0564               else erase with color $FF

L0559               anda      #$03                mask out all but 2 bits (4 colors)
                    leax      >Mode1Clr,pcr       point to color table
                    ldb       a,x                 get appropriate color mask byte
* 6809/6309 - change to fcb $20 (BRN) to save a byte
                    bra       L0564               and start the clearing

* $13 - erase graphics
Do13                clrb                          Color 0 by default
L0564               ldx       <VD.SBAdd,u         Get ptr to screen
* Note: 6309 version clears from top to bottom
*       6809 version clears from bottom to top
                    IFNE      H6309
                    ldw       #$1800              All medium res screens are 6144 bytes (PMODE 3/4)
                    pshs      b                   Save color byte to clear with
                    tfm       s,x+                Clear the screen
                    puls      b                   eat clear value
                    ELSE
* 6809 - change to mini stack blast clear later
                    leax      >$1801,x            Point to end of screen
L056B               stb       ,-x                 Clear byte
                    cmpx      <VD.SBAdd,u         Done whole gfx screen?
                    bhi       L056B               No, keep going until done
                    ENDC

* $14 - home graphics cursor
Do14                equ       *
                    IFNE      H6309
                    clrd
                    ELSE
                    clra
                    clrb
                    ENDC
                    std       <VD.GCrsX,u         Set gfx cursor X,Y coords both to 0
                    rts

* 128x192 4 color pixel table
Mode1Clr            fcb       $00,$55,$aa,$ff

* Fix X/Y coords:
*  - if Y > 191 then cap it at 191
*  - adjust X coord if in 128x192 mode
FixXY               ldd       <VD.NChar,u         get next 2 chars
                    cmpb      #192                Y greater than max?
                    blo       L0585               No, use Y coord as is
                    ldb       #191                Yes, force to 191
L0585               tst       <VD.Mode,u          which mode?
                    bmi       L058B               branch if 256x192 (2 color)
                    lsra                          If 4 color, divide X by 2 (128)
L058B               std       <VD.NChar,u         and save
                    rts

* $15 - set graphics cursor
Do15                leax      <SetGC,pcr          Point to SetGC routine to go to once we have all parameters
GChar2              ldb       #$02                Two parameter bytes required
                    lbra      GChar               Go get them

SetGC               bsr       FixXY               fix X coord based on mode
                    std       <VD.GCrsX,u         and save new gfx cursor X&Y pos
                    clrb                          No error & return
                    rts

* $19 - erase point
Do19                clr       <VD.Msk1,u          Clear color mask byte
* $18 - set point
Do18                leax      <DrawPnt,pcr        Point to Draw Point routine to go to once we have all parameters
                    bra       GChar2              Get the 2 bytes of parameters

DrawPnt             bsr       FixXY               fix X coord based on resolution
                    std       <VD.GCrsX,u         save as new gfx cursor pos
                    bsr       DrwPt2              Draw the point
                    lbra      L067C               Copy VD.Msk2 to VD.Msk1 & return without error

DrwPt2              lbsr      XY2Addr
L05B3               tfr       a,b                 Dupe pixel mask
                    comb                          Make background "hole" mask
                    andb      ,x
                    stb       ,x
                    anda      <VD.Msk1,u
                    ora       ,x
                    sta       ,x
                    rts

* $17 - erase line
Do17                clr       <VD.Msk1,u          Clear pixel mask
* $16 - draw line
Do16                leax      <DrawLine,pcr       Point to Line routine to go to once we have all parameters
                    bra       GChar2              Get the 2 bytes of parameters

* Temp stack layout:
* $0,s    - Pixel mask for graphics cursor (source) coord
* $1,s    - Pixel mask for final destination coord
* $2-$3,s - Ptr to byte on screen for destination coord
* $4-5,s  - ???
* $6,s    - ? Direction (-1 / +1)?
* $7-B,s  - ???
* $C,s    - resolution adjusted X coordinate (0-127 or 0-255)
* $D,s    - resolution adjusted Y coordinate (0-191 (forces to 191 if >191))
* $E,s    - ???

DrawLine            bsr       FixXY               fix X coords based on resolution
                    leas      -LnStkSz,s          make room on stack for line vars
                    std       LnX1,s              save caller supplied (and fixed up) X,Y
                    lbsr      XY2Addr             Calculate screen ptr and pixel mask to destination coord
                    stx       LnAddr1,s           save on stack
                    sta       LnPxMsk2,s          and it's pixel mask too
                    ldd       <VD.GCrsX,u         Get graphics cursor X value
                    lbsr      XY2Addr             Calculate screen ptr and pixel mask to gfx cursor coord
                    sta       ,s                  Save pixel mask for gfx cursor position
* NEXT 3 LINES ARE IN LEVEL 1, NOT IN LEVEL 2!
                    clra
                    clrb
                    std       LnCoords,s          Init to $0000
* 6809/6309 - ldd #191*256+191, then skip second lda #191 and change 2nd suba/sta
*   to subb/stb (shorter/faster)
                    lda       #191                Lo res has Y coord 0 on bottom of screen, not top.
                    suba      <VD.GCrsY,u         Subtract gfx cursor Y coord
                    sta       <VD.GCrsY,u         Save flipped version
                    lda       #191                Lo res has Y coord 0 on bottom of screen, not top.
                    suba      <VD.NChr2,u         Subtract destination Y coord
                    sta       <VD.NChr2,u         Save flipped version
                    lda       #-1                 Init X direction to -1
                    sta       LnXDir,s
                    clra                          D=graphics cursor X position
                    ldb       <VD.GCrsX,u
                    subb      <VD.NChar,u         Subtract destination X coord
                    sbca      #$00
                    bpl       L0608               width of line positive, skip ahead
                    IFNE      H6309
                    negd                          was negative, change to positive
                    ELSE
                    nega                          was negative, change to positive
                    negb
                    sbca      #$00
                    ENDC
                    neg       LnXDir,s            Flip X direction to +1
L0608               std       LnXDist,s           Save # pixels between X coords
                    bne       L0611               Not vertical line (0 distance), skip ahead
                    ldd       #-1                 If vertical line, change 4,s to $FFFF (-1 / -1)
                    std       LnCoords,s
L0611               lda       #-32                Init Y direction/increment to -32 (1 line on screen)
                    sta       LnYDir,s
                    clra
                    ldb       <VD.GCrsY,u         D=Gfx cursor Y coord
                    subb      <VD.NChr2,u         Subtract (as 16 bit) caller Y coord
                    sbca      #$00
                    bpl       L0626               If positive # (callers is below gfx cursor), done
                    IFNE      H6309
                    negd                          If negative, flip to positive
                    ELSE
                    nega                          If negative, flip to positive
                    negb
                    sbca      #$00
                    ENDC
                    neg       LnYDir,s            Change Y direction/offset to +32
L0626               std       LnYDist,s           Save # pixels between Y coords
* New routine to halve the error value RG
                    cmpd      LnXDist,s           is dX>dY
                    pshs      cc                  save answer
                    IFNE      H6309
                    negd                          assume true and negate regD
                    ELSE
                    nega                          assume true and negate regD
                    negb
                    sbca      #0
                    ENDC
                    puls      cc
                    bhs       ch1
                    ldd       LnXDist,s           get dY
ch1                 equ       *
                    IFNE      H6309
                    asrd
* LCB slight 6309 optimization
                    tstd                          0?
                    ELSE
                    asra
                    rorb
                    cmpd      #0
                    ENDC
                    beq       L0632               error must not be zero
* End of new routine RG
                    std       LnCoords,s
                    bra       L0632

* Main line drawing loop
L062A               sta       ,s                  Save new shifted pixel mask
                    ldd       LnCoords,s
                    subd      LnYDist,s           Subtract distance between Y coords
                    std       LnCoords,s          Save updated value
L0632               lda       ,s                  Get current pixel mask for Gfx Cursor X,Y coord
                    lbsr      L05B3               Draw point on screen
                    cmpx      LnAddr1,s           Are we still at same address on screen as we started?
                    bne       L0641               No, skip ahead
                    lda       ,s                  Get Gfx Cursor X,Y coord pixel mask back
                    cmpa      LnPxMsk2,s          Same as pixel mask for caller's X,Y coord?
                    beq       L0675               Yes, skip ahead
L0641               ldd       LnCoords,s
                    bpl       L064F               If >0, skip ahead
                    addd      LnXDist,s           Add to distance between X coords
                    std       LnCoords,s          Save overtop as new value
                    lda       LnYDir,s            Get Y direction/increment
                    leax      a,x                 Bump Y coord up or down as appropriate (SIGNED, so can't use abx)
                    bra       L0632

L064F               lda       ,s                  Get current pixel mask for Gfx Cursor X,Y coord
                    ldb       LnXDir,s            Get X direction/offset
                    bpl       L0665               If positive, skip ahead
                    lsla                          If negative, shift pixel mask left 1 bit
                    ldb       <VD.Mode,u          which mode?
                    bmi       L065C               If 256x192, that's all we need.
                    lsla                          4 color mode, shift 2nd time (2 bits/pixel)
L065C               bcc       L062A               If we didn't hit the end of the byte, do next pixel in this byte
                    lda       <VD.MCol2,u         Get mask for last pixel in a byte for current mode
                    leax      -1,x                Bump screen ptr to left by one
                    bra       L062A               Back to the drawing loop

* X going offset in positive direction
L0665               lsra                          Shift active pixel mask to right 1 bit
                    ldb       <VD.Mode,u          which mode?
                    bmi       L066C               If 2 color, we are done shifting
                    lsra                          4 color, shift 1 more (2 bits/pixel)
L066C               bcc       L062A               Still more pixels in current byte, do next pixel
                    lda       <VD.MCol,u          Get mask for first pixel in a byte for current mode
                    leax      1,x                 Bump screen ptr to right by one
                    bra       L062A               Back to drawing loop

L0675               ldd       LnX1,s              Get destination X,Y coords from caller
                    std       <VD.GCrsX,u         Save them as the new graphics cursor position
                    leas      LnStkSz,s           Eat temp Line stack
L067C               lda       <VD.Msk2,u          Get full byte color mask for current foreground color?
                    sta       <VD.Msk1,u          Save in another mask
                    clrb                          Return w/o error
                    rts

* $1C - erase circle
Do1C                clr       <VD.Msk1,u
* $1A - draw circle
Do1A                leax      <Circle,pcr         Point to Circle routine to go to once we have all parameters
                    lbra      GChar1              1 parameter byte (radius) to get

Circle              leas      -4,s                Reserve 4 bytes on stack
                    ldb       <VD.NChar,u         get radius
                    stb       $01,s               store on stack
                    clra
                    sta       ,s
                    addb      $01,s
                    adca      #$00
                    IFNE      H6309
                    negd
                    ELSE
                    nega
                    negb
                    sbca      #$00
                    ENDC
                    addd      #$0003
                    std       $02,s
L06AB               lda       ,s
                    cmpa      $01,s
                    bhs       L06DD
                    ldb       $01,s
                    bsr       L06EB
                    clra
                    ldb       $02,s
                    bpl       L06C5
                    ldb       ,s
                    IFNE      H6309
                    lsld
                    lsld
                    ELSE
                    lslb
                    rola
                    lslb
                    rola
                    ENDC
                    addd      #$0006
                    bra       L06D5

L06C5               dec       $01,s
                    clra
                    ldb       ,s
                    subb      $01,s
                    sbca      #$00
                    IFNE      H6309
                    lsld
                    lsld
                    ELSE
                    lslb
                    rola
                    lslb
                    rola
                    ENDC
                    addd      #$000A
L06D5               addd      $02,s
                    std       $02,s
                    inc       ,s
                    bra       L06AB

L06DD               lda       ,s
                    cmpa      $01,s
                    bne       L06E7
                    ldb       $01,s
                    bsr       L06EB
L06E7               leas      $04,s
                    bra       L067C

L06EB               leas      -$08,s
                    sta       ,s
                    clra
                    std       $02,s
                    IFNE      H6309
                    negd
                    ELSE
                    nega
                    negb
                    sbca      #$00
                    ENDC
                    std       $06,s
                    ldb       ,s
                    clra
                    std       ,s
                    IFNE      H6309
                    negd
                    ELSE
                    nega
                    negb
                    sbca      #$00
                    ENDC
                    std       $04,s
                    ldx       $06,s
                    bsr       L0734
                    ldd       $04,s
                    ldx       $02,s
                    bsr       L0734
                    ldd       ,s
                    ldx       $02,s
                    bsr       L0734
                    ldd       ,s
                    ldx       $06,s
                    bsr       L0734
                    ldd       $02,s
                    ldx       ,s
                    bsr       L0734
                    ldd       $02,s
                    ldx       $04,s
                    bsr       L0734
                    ldd       $06,s
                    ldx       $04,s
                    bsr       L0734
                    ldd       $06,s
                    ldx       ,s
                    bsr       L0734
                    leas      $08,s
                    rts

L0734               pshs      d
                    ldb       <VD.GCrsY,u
* 6809/6309 - ABX to replace next 2 lines (CLRA forces to positive number)
                    clra
                    leax      d,x
                    cmpx      #$0000
                    bmi       L0746
                    cmpx      #191
                    ble       L0748
L0746               puls      pc,d

L0748               ldb       <VD.GCrsX,u
                    clra
                    tst       <VD.Mode,u          which mode?
                    bmi       L0753               branch if 256x192
                    IFNE      H6309
                    lsld
                    ELSE
                    lslb                          else multiply D by 2
                    rola
                    ENDC
L0753               addd      ,s++
                    tsta
                    beq       L0759
                    rts

L0759               pshs      b
                    tfr       x,d
                    puls      a
                    tst       <VD.Mode,u          which mode?
                    lbmi      DrwPt2              branch if 256x192
                    lsra                          else divide a by 2 1st
                    lbra      DrwPt2

* $1D - flood fill
Do1D                clr       <VD.FF6,u           Clear flag
                    leas      -$07,s
                    lbsr      L08DD
                    lbcs      L0878
                    lda       #$FF
                    sta       <VD.FFFlg,u
                    ldd       <VD.GCrsX,u
                    lbsr      L0883
                    lda       <VD.FF1,u
                    sta       <VD.FF2,u
                    tst       <VD.Mode,u          which mode?
                    bpl       L0793               branch if 128x192
                    tsta
                    beq       L0799
                    lda       #$FF
                    bra       L0799

L0793               leax      >Mode1Clr,pcr
                    lda       a,x
L0799               sta       <VD.FFMsk,u
                    cmpa      <VD.Msk1,u
                    lbeq      L0878
                    ldd       <VD.GCrsX,u
L07A6               suba      #$01
                    bcs       L07B1
                    lbsr      L0883
                    bcs       L07B1
                    beq       L07A6
L07B1               inca
                    std       $01,s
L07B4               lbsr      L08B6
                    adda      #$01
                    bcs       L07C2
                    lbsr      L0883
                    bcs       L07C2
                    beq       L07B4
L07C2               deca
                    ldx       $01,s
                    lbsr      L0905
                    neg       <VD.FFFlg,u
                    lbsr      L0905
L07CE               lbsr      L092B
                    lbcs      L0878
                    tst       <VD.FFFlg,u
                    bpl       L07E5
                    subb      #$01
                    bcs       L07CE
                    std       $03,s
                    tfr       x,d
                    decb
                    bra       L07EF

L07E5               incb
                    cmpb      #$BF
                    bhi       L07CE
                    std       $03,s
                    tfr       x,d
                    incb
L07EF               std       $01,s
                    lbsr      L0883
                    bcs       L07CE
L07F6               bne       L0804
                    suba      #$01
                    bcc       L07FF
                    inca
                    bra       L0808

L07FF               lbsr      L0883
                    bcc       L07F6
L0804               adda      #$01
                    bcs       L07CE
L0808               cmpd      $03,s
                    bhi       L07CE
                    bsr       L0883
                    bcs       L07CE
                    bne       L0804
                    std       $05,s
                    cmpd      $01,s
                    bcc       L082D
                    ldd       $01,s
                    decb
                    cmpd      $05,s
                    beq       L082D
                    neg       <VD.FFFlg,u
                    ldx       $05,s
                    lbsr      L0905
                    neg       <VD.FFFlg,u
L082D               ldd       $05,s
L082F               std       $01,s
L0831               bsr       L0883
                    bcs       L083D
                    bne       L083D
                    bsr       L08B6
                    adda      #$01
                    bcc       L0831
L083D               deca
                    ldx       $01,s
                    lbsr      L0905
                    std       $05,s
                    adda      #$01
                    bcs       L0858
L0849               cmpd      $03,s
                    bcc       L0858
                    adda      #$01
                    bsr       L0883
                    bcs       L0858
                    bne       L0849
                    bra       L082F

L0858               inc       $03,s
                    inc       $03,s
                    ldd       $03,s
                    cmpa      #$02
                    lbcs      L07CE
                    ldd       $05,s
                    cmpd      $03,s
                    lbcs      L07CE
                    neg       <VD.FFFlg,u
                    ldx       $03,s
                    lbsr      L0905
                    lbra      L07CE

L0878               leas      $07,s
                    clrb
                    ldb       <VD.FF6,u
                    beq       L0882
L0880               orcc      #$01
L0882               rts

L0883               pshs      d
                    cmpb      #191
                    bhi       L08B2
                    tst       <VD.Mode,u          which mode?
                    bmi       L0892               branch if 256x192
                    cmpa      #127                Past max X coord for 4 color mode?
                    bhi       L08B2
L0892               lbsr      XY2Addr
                    tfr       a,b
                    andb      ,x
L0899               bita      #$01
                    bne       L08A8
                    lsra
                    lsrb
                    tst       <VD.Mode,u          which mode?
                    bmi       L0899               branch if 256x192
                    lsra
                    lsrb
                    bra       L0899

L08A8               stb       <VD.FF1,u
                    cmpb      <VD.FF2,u
                    andcc     #^Carry
                    puls      pc,d

L08B2               orcc      #Carry
                    puls      pc,d

L08B6               pshs      d
                    lbsr      XY2Addr
                    bita      #$80
                    beq       L08D8
                    ldb       <VD.FFMsk,u
                    cmpb      ,x
                    bne       L08D8
                    ldb       <VD.Msk1,u
                    stb       ,x
                    puls      b,a
                    tst       <VD.Mode,u          which mode?
                    bmi       L08D5               branch if 256x192
                    adda      #$03
                    rts

L08D5               adda      #$07
                    rts

L08D8               lbsr      L05B3
                    puls      pc,d

L08DD               ldx       <VD.FFSTp,u         get top of flood fill stack
                    beq       AlcFFStk            if zero, we need to allocate stack
                    stx       <VD.FFSPt,u         else reset flood fill stack ptr
L08E5               clrb
                    rts

* Allocate Flood Fill Stack
AlcFFStk            pshs      u                   save U for now
                    ldd       #FFStSz             get 512 bytes
                    os9       F$SRqMem            from system
                    bcc       AllocOk             branch if ok
                    puls      pc,u                else pull out with error

AllocOk             tfr       u,d                 move pointer to alloced mem to D
                    puls      u                   get stat pointer we saved earlier
                    std       <VD.FFMem,u         save pointer to alloc'ed mem
                    addd      #FFStSz             point D to end of alloc'ed mem
                    std       <VD.FFSTp,u         and save here as top of fill stack
                    std       <VD.FFSPt,u         and here
                    clrb                          Do a clean return
                    rts

* Add FFill stack entry (4 bytes). Max of 128 entries allowed.
L0905               pshs      d
                    ldd       <VD.FFSPt,u         Get current FFill stack ptr
                    subd      #$0004              Add 4 bytes to it
                    cmpd      <VD.FFMem,u         Have we filled all 512 bytes?
                    blo       L0924               Yes, error out
                    std       <VD.FFSPt,u         No, Save new FFill stack ptr
                    tfr       d,y                 Move new ptr to indexable register
                    lda       <VD.FFFlg,u         Get? (direction flag, maybe?)
                    sta       ,y                  Save on stack
                    stx       $01,y               Save (mem ptr on screen, I think?)
                    puls      d                   Get ?? back
                    sta       $03,y               Save A to FFill stack entry & return
                    rts

L0924               ldb       #E$Write            $F5 Write Error if FFill stack overflows
                    stb       <VD.FF6,u           Save error code
                    puls      pc,d

* Remove FFill stack entry (4 bytes)
L092B               ldd       <VD.FFSPt,u         Get current FFill stack ptr
                    cmpd      <VD.FFSTp,u         Have we already emptied stack?
                    lbhs      L0880               Yes, stack empty, exit with carry set
                    tfr       d,y                 No, move to indexable register
                    addd      #$0004              Add 4 to it (eat 4 bytes from stack)
                    std       <VD.FFSPt,u         Save as new FFill stack ptr
                    lda       ,y                  Get byte from original FFill stack position
                    sta       <VD.FFFlg,u         Save it
                    ldd       $01,y               Get ? (mem ptr on screen, I think?)
                    tfr       d,x                 Move to indexable register
                    lda       $03,y
                    andcc     #^Carry
                    rts
                    ENDC

* Entry: Y=Ptr to path descriptor
*        A=GetStat code
GetStat             ldx       PD.RGS,y            Get ptr to users stack
                    cmpa      #SS.AlfaS           Alfa Display Status?
                    beq       Rt.AlfaS
                    cmpa      #SS.ScSiz           Screen size?
                    beq       Rt.ScSiz
                    cmpa      #SS.Cursr           Cursor info?
                    beq       Rt.Cursr
                    IFNE      COCO2
                    cmpa      #SS.DStat           Medium graphics Display Status?
                    lbeq      Rt.DSTAT
                    ENDC
                    cmpa      #SS.Palet           Get current palette settings?
                    beq       Rt.Palet
                    comb                          Anything else, return with Unknown Service error
                    ldb       #E$UnkSvc
                    rts

* Returns window or screen size. Currently hardcoded 32x16 for Coco 3/level 2. Level 1 now
* has CocoVGA support, so it uses the static mem values.
* Exit: X = X screen size (32)
*       Y = Y screen size (16)
Rt.ScSiz            equ       *
                    IFNE      H6309
                    ldq       #$00200010          Always returns 32x16
                    stq       R$X,x
                    ELSE
*         ldb   <VD.Col,u
                    ldd       #$0020              Always returns 32x16
                    std       R$X,x
*         ldb   <VD.Row,u
                    ldb       #$10
                    std       R$Y,x
                    ENDC
                    clrb
                    rts

* Get palette information
* Exit: 16 byte packet pointed to by X has the 16 current palette register values
Rt.Palet            pshs      u,y,x
                    leay      <VD.Palet,u         point to palette data in proc desc
                    ldu       R$X,x               pointer to 16 byte palette buffer
                    ldx       <D.Proc             current proc desc
                    ldb       P$Task,x            destination task number
                    clra                          from task 0
                    leax      ,y
                    ldy       #16                 move 16 bytes
                    os9       F$Move
                    puls      pc,u,y,x

* Return VDG alpha screen memory info
* Exit: X = address of screen
*       Y = address of cursor
*       A = Capslock status
Rt.AlfaS            ldd       <VD.ScrnA,u         Get screen address
                    anda      #$E0                keep bits 4-6
                    lsra
                    lsra
                    lsra
                    lsra                          move to bits 0-2 (for MMU block #)
                    ldy       <D.SysDAT           Get system process DAT image ptr
                    ldd       a,y                 Get MMU block # text screen is in
                    lbsr      L06E1               map it in the process' memory area
                    bcs       L0521               If error, return with it
                    pshs      d                   offset to block address
                    ldd       <VD.ScrnA,u         Get ptr to text screen again
                    anda      #$1F                make sure it's within the block
                    addd      ,s
                    std       R$X,x               save start memory address of the screen to caller
                    ldd       <VD.CrsrA,u         Get current cursor address
                    anda      #$1F
                    addd      ,s++
                    std       R$Y,x               save cursor address to caller
                    lda       <VD.Caps,u          save caps lock status in A and exit
                    bra       L051E

* SS.Cursr GetStat
* Returns VDG alpha screen cursor info
* Exit: X = Cursor X position (includes +$20)
*       Y = Cursor Y position (includes +$20)
*       A = character code at the current cursor address
Rt.Cursr            ldd       <VD.CrsrA,u
                    subd      <VD.ScrnA,u
                    pshs      d
                    clra
                    andb      #$1F
                    addb      #$20
                    std       R$X,x               save column position in ASCII
                    puls      d                   then divide by 32
                    lsra
                    rolb
                    rolb
                    rolb
                    rolb
                    clra
                    andb      #$0F                only 16 lines to a screen
                    addb      #$20
                    std       R$Y,x
                    ldb       <VD.CFlag,u         Get true lowercase flag
                    lda       <VD.CChar,u         Get character that is under cursor
                    bmi       L051E               If graphic block, return with it
                    cmpa      #$60                For other chars, adjustments may be needed (from VDG to ASCII)
                    bhs       L0509
                    cmpa      #$20
                    bhs       L050D
                    tstb                          Is true lowercase on?
                    beq       L0507               No, skip ahead
                    tsta                          VDG char 0?
                    bne       L04FF               No, skip ahead
                    lda       #$5E                Return ^ caret symbol
                    bra       L051E               save it and exit

L04FF               cmpa      #$1F                VDG $1F?
                    bne       L0507               No, check next
                    lda       #$5F                Yes, return underscore _
                    bra       L051E

L0507               ora       #$20                turn it into ASCII from VDG codes
L0509               eora      #$40
                    bra       L051E

L050D               tstb                          Is true lowercase on?
                    bne       L051E               Yes, just return value as ASCII
                    cmpa      #$21                VDG $21?
                    bne       L0518               No, check next
                    lda       #$7C                Yes, return pipe |
                    bra       L051E

L0518               cmpa      #$2D                VDG $2D?
                    bne       L051E               No, return character as is
                    lda       #$7E                Yes, return tilde ~
L051E               sta       R$A,x               Save ASCII value to caller in A & return
                    clrb
L0521               rts

                    IFNE      COCO2
* SS.DStat (return graphics display status)
* Exit: A = color code of the pixel at gfx cursor address
*       X = address of graphics display memory
*       Y = graphics cursor position (MSB = X, LSB = Y)
Rt.DSTAT            bsr       ChkDvRdy
                    bcs       L0A4F
                    ldd       <VD.GCrsX,u
                    bsr       XY2Addr
                    tfr       a,b
                    andb      ,x
L0A23               bita      #$01
                    bne       L0A32
                    lsra
                    lsrb
                    tst       <VD.Mode,u          which mode?
                    bmi       L0A23               branch if 256x192
                    lsra
                    lsrb
                    bra       L0A23

L0A32               pshs      b
                    ldb       <VD.PMask,u
                    andb      #%11111100
                    orb       ,s+
                    ldx       PD.RGS,y            Get callers register stack ptr
                    stb       R$A,x               Save color of pixel at gfx cursor address
                    ldd       <VD.GCrsX,u         Get gfx cursor X & Y coords
                    std       R$Y,x               Save to caller's Y register
                    ldb       <VD.Blk,u           Get MMU block # of screen
                    lbsr      L06E1               Figure out address of screen
                    bcs       L0A4F               Error, exit with it
                    std       R$X,x               Save address of medium res screen to caller's X
L0A4E               clrb
L0A4F               rts

ChkDvRdy            ldb       <VD.Rdy,u           is device ready (screen RAM allocated, etc.)?
                    bne       L0A4E               Yes, return w/o error
                    lbra      NotReady            else return error

* Calc screen address & pixel mask given X,Y coordinates
* Entry: A = X coord
*        B = Y coord
*        U = static mem ptr
* Exit:  A = pixel mask for pixel we wanted
*        X = ptr to byte on screen where pixel is that we wanted
*        Y is preserved
XY2Addr             pshs      y,d                 Make room on stack (and temporarily save X,Y coord)
                    ldb       <VD.Mode,u          get video mode
                    bpl       L0A60               branch if 128x192 (divide A by 4)
                    lsra                          else divide A by 8
L0A60               lsra
                    lsra
                    pshs      a                   Save horizontal byte offset
                    ldb       #191                get max Y
                    subb      2,s                 subtract Y on stack
                    lda       #32                 bytes per line
                    mul                           Calculate offset to line we want
                    addb      ,s+                 add X byte offset
                    adca      #$00
* 6809/6309 - since we are restoring X,Y from stack anyways, use X instead of Y here
*  to save space and be slightly faster)
                    ldy       <VD.SBAdd,u         get screen's base address
                    leay      d,y                 Point to specific byte on screen we want
                    lda       ,s                  Get original X coord back
                    sty       ,s                  Save ptr to byte on screen we are using
                    anda      <VD.PixBt,u         Mask for pixel within byte
                    ldx       <VD.MTabl,u         Get pixel mask ptr for our mode
                    lda       a,x                 Get pixel mask for pixel within byte we want
                    puls      pc,y,x              X = offset address, Y = base
                    ENDC

SetStat             ldx       PD.RGS,y            Get caller's register stack ptr
                    cmpa      #SS.ComSt           Caller changing true lowercase on/off on VDG window?
                    beq       Rt.ComSt
                    IFNE      COCO2
                    cmpa      #SS.AAGBf
                    beq       Rt.AAGBf
                    cmpa      #SS.SLGBf
                    beq       Rt.SLGBf
                    ENDC
                    cmpa      #SS.ScInf           new NitrOS-9 call
                    lbeq      Rt.ScInf
                    cmpa      #SS.DScrn
                    lbeq      Rt.DScrn
                    cmpa      #SS.PScrn
                    lbeq      Rt.PScrn
                    cmpa      #SS.AScrn
                    lbeq      Rt.AScrn
                    cmpa      #SS.FScrn
                    lbeq      Rt.FScrn
                    comb
                    ldb       #E$UnkSvc
                    rts

* Allow switch between true/inverse lowercase
* Entry: Y = least sig bit of MSB: 0=true lowercase, 1=inverse
Rt.ComSt            lda       R$Y,x               Get MSB of Y (least sig bit is lowercase/inverse flag)
L054C               ldb       #$10                default to true lowercase
                    bita      #$01                Y = 0 = true lowercase, Y = 1 = inverse?
                    bne       L0553               Caller wants true lowercase, skip ahead
                    clrb                          Inverse video instead
L0553               stb       <VD.CFlag,u
                    ldd       #$2010              32x16
                    inc       <VD.DFlag,u         Flag that we need to update video hardware
                    std       <VD.Col,u           Save screen size
                    rts

                    IFNE      COCO2
Rt.AAGBf            ldb       <VD.Rdy,u
                    beq       NotReady
                    ldd       #$0201
                    leay      <VD.AGBuf,u
                    lbsr      L06C7
                    bcs       L0AEB
                    pshs      a
                    lbsr      Get8KHi
                    bcs       L0AEC
                    stb       ,y
                    lbsr      L06E1
                    bcs       L0AEC
                    std       R$X,x
                    puls      b
                    clra
                    std       R$Y,x
L0AEB               rts

L0AEC               puls      pc,a

NotReady            comb
                    ldb       #E$NotRdy
                    rts

Rt.SLGBf            ldb       <VD.Rdy,u
                    beq       NotReady
                    ldd       R$Y,x
                    cmpd      #$0002
                    lbhi      IllArg
                    leay      <VD.GBuff,u
                    ldb       b,y
                    lbeq      IllArg
                    pshs      x
                    stb       <VD.Blk,u
                    lda       <VD.SBAdd,u
                    anda      #$E0
                    lsra
                    lsra
                    lsra
                    lsra
                    ldx       <D.SysPrc
                    leax      <P$DATImg,x
                    leax      a,x
                    clra
                    std       ,x
                    ldx       <D.SysPrc
                    os9       F$SetTsk
                    puls      x
                    ldd       R$X,x
                    beq       L0B2B
                    ldb       #$01
L0B2B               stb       <VD.DFlag,u
                    clrb
                    rts
                    ENDC

* Display Table
* 1st entry = display code
* 2nd entry = # of 8K blocks
DTabl               fcb       $14,$02             0: 640x192, 2 color, 16K
                    fcb       $15,$02             1: 320x192, 4 color, 16K
                    fcb       $16,$02             2: 160x192, 16 color, 16K
                    fcb       $1D,$04             3: 640x192, 4 color, 32K
                    fcb       $1E,$04             4: 320x192, 16 color, 32K

* Allocates and maps a hires screen into process address
* LCB proposals:
*   1) type 5 to be 160x192x256 color for GIME-X
*   2) Allow high byte of X to have a bit (default 0), if set, to mean
*      x200 screen. Maybe even 2 bits and support x225 as well, although
*      that means adding 1 block to each of the above tables, and will require
*      more checks for how many screens we can fit in our address space.
Rt.AScrn            ldd       R$X,x               get screen type from caller's X
* LCB - add support for 160x192x256 here as type 5 for GIME-X
                    cmpd      #$0004              screen type 0-4
                    bhi       IllArg              if higher than legal limit, return error
                    pshs      y,x,d               else save off regs
                    ldd       #$0303
                    leay      <VD.HiRes,u         pointer to screen descriptor
                    lbsr      L06C7               gets next free screen descriptor
                    bcs       L05AF               branch if none found
                    sta       ,s                  save screen descriptor on stack
                    ldb       $01,s               get screen type
                    stb       (VD.SType-VD.HiRes),y and store in VD.SType
                    leax      >DTabl,pcr          point to display table
                    lslb                          multiply index by 2 (word entries)
                    abx                           point to display code, #blocks
                    ldb       $01,x               get number of blocks
                    stb       (VD.NBlk-VD.HiRes),y VD.NBlk
                    lda       #$FF                start off with zero screens allocated
BA010               inca                          count up by one
                    ldb       (VD.NBlk-VD.HiRes),y get number of blocks
                    pshs      a                   needed to protect regA; RG.
                    os9       F$AlHRAM            allocate a screen
                    puls      a
                    bcs       DeAll               de-allocate ALL allocated blocks on error
                    pshs      b                   save starting block number of the screen
                    andb      #$3F                keep block BL= block MOD 63
                    pshs      b
                    addb      (VD.NBlk-VD.HiRes),y add in the block size of the screen
                    decb                          in case last block is $3F,$7F,$BF,$FF; RG.
                    andb      #$3F                (BL+S) mod 63 < BL? (overlap 512k bank)
                    cmpb      ,s+                 is all of it in this bank?
                    blo       BA010               if not, allocate another screen
                    puls      b                   restore the block number for this screen
                    stb       ,y                  VD.HiRes - save starting block number
                    bsr       DeMost              deallocate all of the other screens
                    leas      a,s                 move from within DeMost; RG.
                    ldb       ,y                  Restore the starting block number again
                    lda       1,x                 number of blocks
                    lbsr      L06E3
                    bcs       L05AF
                    ldx       $02,s
                    std       R$X,x
                    ldb       ,s
                    clra
                    std       R$Y,x
L05AF               leas      2,s
                    puls      pc,y,x

L05B3X              leas      2,s
IllArg              comb
                    ldb       #E$IllArg
                    rts

* De-allocate the screens
DeAll               bsr       DeMost              de-allocate all of the screens
                    bra       L05AF               restore stack and exit

DeMost              tsta
                    beq       DA020               quick exit if zero additional screens
                    ldb       (VD.NBlk-VD.HiRes),y get # blocks of screen to de-allocate
                    pshs      a                   save count of blocks for later
                    pshs      d,y,x               save rest of regs
                    leay      9,s                 account for d,y,x,a,calling PC
                    clra
DA010               ldb       ,y+                 get starting block number
                    tfr       d,x                 in X
                    ldb       1,s                 get size of the screen to de-allocate
                    pshs      a                   needed to protect regA; RG.
                    os9       F$DelRAM            de-allocate the blocks *** IGNORING ERRORS ***
                    puls      a
                    dec       ,s                  count down
                    bne       DA010
                    puls      d,y,x               restore registers
                    puls      a                   and count of extra bytes on the stack
DA020               rts                           and exit

* Get current screen info for direct writes - added in NitrOS-9
Rt.ScInf            pshs      x                   save caller's regs ptr
                    ldd       R$Y,x               get ??? (Y from caller)
* 6809/6309: This can actually skip one instruction to the ldb R$Y+1,x since X hasn't changed
                    bmi       L05C8               If high bit set, skip ahead
                    bsr       L05DE
                    bcs       L05DC
                    lbsr      L06FF
                    bcs       L05DC
L05C8               ldx       ,s                  get caller's regs ptr from stack
                    ldb       R$Y+1,x
                    bmi       L05DB
                    bsr       L05DE
                    bcs       L05DC
                    lbsr      L06E3
                    bcs       L05DC
                    ldx       ,s
                    std       R$X,x               Return in caller's X
L05DB               clrb
L05DC               puls      pc,x

L05DE               beq       IllArg
                    cmpb      #$03
                    bhi       IllArg
                    bsr       GetScrn
                    beq       IllArg
                    ldb       ,x
                    beq       IllArg
                    lda       $01,x
                    andcc     #^Carry
                    rts

* Convert screen to a different type
Rt.PScrn            ldd       R$X,x
                    cmpd      #$0004
                    bhi       IllArg
                    pshs      b,a                 save screen type, and a zero
                    leax      >DTabl,pcr
                    lslb
                    incb
                    lda       b,x                 get number of blocks the screen requires
                    sta       ,s                  kill 'A' on the stack
                    ldx       PD.RGS,y
                    bsr       L061B
                    bcs       L05B3X
                    lda       ,s
                    cmpa      $01,x
                    lbhi      L05B3X              if new one takes more blocks than old
                    lda       $01,s
                    sta       $02,x
                    leas      $02,s
                    bra       L0633

L061B               ldd       R$Y,x
                    beq       L0633
                    cmpd      #$0003
                    lbgt      IllArg
                    bsr       GetScrn             point X to 3 byte screen descriptor
                    lbeq      IllArg
                    clra
                    rts

* Displays screen
Rt.DScrn            bsr       L061B
                    bcs       L063A
L0633               stb       <VD.DGBuf,u
                    inc       <VD.DFlag,u
                    clrb
L063A               rts

* Entry: B = screen 1-3
* Exit:  X = ptr to screen entry
*GetScrn  pshs  b,a
*         leax  <VD.GBuff,u
*         lda   #$03
*         mul
*         leax  b,x
*         puls  pc,b,a
GetScrn             leax      <VD.GBuff,U         point X to screen descriptor table
                    abx
                    abx
                    abx
                    tst       ,x                  is this screen valid? (0 = not)
                    rts

* Frees memory of screen allocated by SS.AScrn
Rt.FScrn            ldd       R$Y,x
                    lbeq      IllArg
                    cmpd      #$03
                    lbhi      IllArg
                    cmpb      <VD.DGBuf,u
                    lbeq      IllArg              illegal arg if screen is being displayed
                    bsr       GetScrn             point to buffer
                    lbeq      IllArg              error if screen unallocated
* Entry: X = pointer to screen table entry
FreeBlks            lda       $01,x               get number of blocks
                    ldb       ,x                  get starting block
                    beq       L066D               branch if none
                    pshs      a                   else save count
                    clra                          clear A
                    sta       ,x                  clear block # in entry
                    tfr       d,x                 put starting block # in X
                    puls      b                   get block numbers
                    os9       F$DelRAM            delete
L066D               rts                           and return

* Entry: B=Which graphics buffer to make active display
ShowS               cmpb      #$03                no more than 3 graphics buffers
                    bhi       L066D               Exit if past maximum
                    bsr       GetScrn             point X to appropriate screen descriptor
                    beq       L066D               branch if not allocated
                    ldb       $02,x               VD.SType - screen type 0-4
* LCB Change to allow for 160x192x256 for GIME-X
                    cmpb      #$04
                    bhi       L066D               Not a valid screen type, return
                    lslb
                    pshs      x
                    leax      >DTabl,pcr
                    lda       b,x                 get proper display code
                    puls      x
* LCB - this should be timed HSYNC or VSYNC to cut sparklies (see VDGINT 1.16 source)
                    clrb
                    std       >$FF99              set border color, too
                    std       >D.VIDRS
                    lda       >D.HINIT
                    anda      #$7F                make coco 3 only mode
                    sta       >D.HINIT
                    sta       >$FF90
                    lda       >D.VIDMD
                    ora       #$80                graphics mode
                    anda      #$F8                1 line/character row
                    sta       >D.VIDMD
                    sta       >$FF98
*         lda   ,x          get block #
*         lsla
*         lsla
*** start of 2MB patch by RG
                    ldb       ,x                  get block # (2Meg patch)
                    clra
                    lslb
                    rola
                    lslb
                    rola
                    sta       >$FF9B
                    tfr       b,a
*** end of 2MB patch by RG
                    clrb
                    std       <D.VOFF1            display it
                    std       >$FF9D
                    clr       >D.VOFF2
                    clr       >$FF9C
                    lbra      SetPals

* Get next free screen descriptor
L06C7               clr       ,-s                 clear an area on the stack
                    inc       ,s                  set to 1
L06CB               tst       ,y                  check block #
                    beq       L06D9               if not used yet
                    leay      b,y                 go to next screen descriptor
                    inc       ,s                  increment count on stack
                    deca                          decrement A
                    bne       L06CB
                    comb
                    ldb       #E$BMode
L06D9               puls      pc,a

* Get B 8K blocks from high RAM
Get8KHi             ldb       #$01                1 8k block needed (semigraphics or medium res
L06DDX              os9       F$AlHRAM            allocate a screen from end of RAM
                    rts

L06E1               lda       #$01                map screen into memory
L06E3               pshs      u,x,d
                    bsr       L0710
                    bcc       L06F9
                    clra
                    ldb       $01,s
                    tfr       d,x
                    ldb       ,s
                    os9       F$MapBlk
                    stb       $01,s               save error code if any
                    tfr       u,d
                    bcs       L06FD
L06F9               leas      $02,s               destroy D on no error
                    puls      pc,u,x

L06FD               puls      pc,u,x,d            if error, then restore D

L06FF               pshs      y,x,a               deallocate screen
                    bsr       L0710
                    bcs       L070E
                    ldd       #DAT.Free           set memory to unused
L0708               std       ,x++
                    dec       ,s
                    bne       L0708
L070E               puls      pc,y,x,a

L0710               equ       *
                    IFNE      H6309
                    pshs      a
                    lde       #$08
                    ELSE
                    pshs      d
                    lda       #$08                number of blocks to check
                    sta       $01,s
                    ENDC
                    ldx       <D.Proc
                    leax      <P$DATImg+$10,x     to end of CoCo's DAT image map
                    clra
                    addb      ,s
                    decb
L071F               cmpd      ,--x
                    beq       L072A
                    IFNE      H6309
                    dece
                    ELSE
                    dec       $01,s
                    ENDC
                    bne       L071F
                    bra       L0743
L072A               equ       *
                    IFNE      H6309
                    dece
                    ELSE
                    dec       $01,s
                    ENDC
                    dec       ,s
                    beq       L0738
                    decb
                    cmpd      ,--x
                    beq       L072A
                    bra       L0743

L0738               equ       *
                    IFNE      H6309
                    tfr       e,a
                    ELSE
                    lda       $01,s               get lowest block number found
                    ENDC
                    lsla
                    lsla
                    lsla
                    lsla
                    lsla                          multiply by 32 (convert to address)
                    clrb                          clear carry
                    IFNE      H6309
                    puls      b,pc

L0743               puls      a
                    ELSE
                    leas      $02,s
                    rts

L0743               puls      d
                    ENDC
                    comb
                    ldb       #E$BPAddr           bad page address
                    rts

                    emod
eom                 equ       *
                    end
