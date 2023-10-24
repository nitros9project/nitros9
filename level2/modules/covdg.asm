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
edition             set       1

skip2               equ       $8C                 cmpx instruction

                    mod       eom,name,tylg,atrv,start,size

u0000               rmb       0
size                equ       .

                    fcb       $07

name                fcs       /CoVDG/
                    fcb       edition

start               lbra      Read                actually more like INIZ...
                    lbra      Write
                    lbra      GetStat
                    lbra      SetStat
                    lbra      Term

* Update Window
* Called from VTIO
* Entry:  A = function code
*           0 = select new window to be active
*           1 = update mouse packet
*          >1 = only used by CoGrf/CoWin
*         U = device memory pointer
*         X = path descriptor pointer

                    tsta                          zero?
                    bne       L0035               branch if not
                    ldb       <VD.DGBuf,u         get number of currently displayed buffer
                    lbne      ShowS               branch if not zero
                    ldd       <VD.TFlg1,u
                    lbra      DispAlfa

L0035               deca                          set x,y size of window?
                    beq       L003B               branch if so
                    clrb                          no errors
                    rts

L003B               ldx       <D.CCMem            pointer to start of CC memory
                    leax      <G.Mouse+Pt.AcX,x   to X,Y coor, X,Y window
*         leax  <$54,x          to X,Y coor, X,Y window
                    ifne      H6309
                    ldq       ,x                  get X,Y coordinate
                    stq       $04,x               copy to window relative X,Y
                    else
                    ldd       ,x
                    std       $04,x
                    ldd       $02,x
                    std       $06,x
                    endc
                    clrb
                    rts

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
ClrStat             ldb       #$E1                size of 1 page -$1D (SCF memory requirements)
                    leax      <VD.Strt1,u         point to start of VDG statics
L006F               clr       ,x+                 set stored byte to zero
                    decb                          decrement
                    bne       L006F               until zero
                    bra       L00D5               and exit

* Read bytes from IN
* Actually, this is more like an INIZ of the device.
Read                pshs      u,y,x               save regs
                    bsr       SetupPal            set up palettes
                    lda       #$AF
                    sta       <VD.CColr,u         default color cursor
                    pshs      u
                    ldd       #768                gets 1 page on an odd page boundary
                    os9       F$SRqMem            request from top of sys ram
                    bcs       L00D6               error out of no system mem
                    tfr       u,d                 U = addr of memory
                    tfr       u,x
                    bita      #$01                test to see if on even page
                    beq       IsEven              branch if even
                    leax      >256,x              else point 100 bytes into mem
                    bra       IsOdd               and free
IsEven              leau      >512,u              we only need 2 pages for the screen memory
IsOdd               ldd       #256                1 page return
                    os9       F$SRtMem            return system memory
                    puls      u
                    stx       <VD.ScrnA,u         save start address of the screen
                    stx       <VD.CrsrA,u         and start cursor position
                    leax      >512,x              point to end of screen
                    stx       <VD.ScrnE,u         save it
                    lda       #$60                get default character
                    sta       <VD.CChar,u         put character under the cursor
                    sta       <VD.Chr1,u          only referenced here ??
                    lbsr      ClrScrn             clear the screen
                    inc       <VD.Start,u         increment VDG screen in use
                    ldd       <VD.Strt1,u         seemling useless??
                    lbsr      L054C               set to true lowercase, screen size
                    leax      <VD.NChar,u
                    stx       <VD.EPlt1,u         where to get next character from
                    stx       <VD.EPlt2,u
                    ldu       <D.CCMem
                    ifne      H6309
                    oim       #$02,<G.BCFFlg,u    set to VDGINT found
                    else
                    ldb       <G.BCFFlg,u
                    orb       #$02                set to VDGINT found
                    stb       <G.BCFFlg,u
                    endc
L00D5               clrb
L00D6               puls      pc,u,y,x

SetupPal            pshs      u,y,x,b,a
                    lda       #$08
                    sta       <VD.PlFlg,u
                    leax      >L011A,pcr          default palette
                    leay      <VD.Palet,u
L00E6               leau      >L00F8,pcr          CMP to RGB conversion
                    ifne      H6309
L00EA               tfr       u,w
                    else
L00EA               pshs      u
                    endc
                    leau      >L012A,pcr
                    ldb       #16
L00F2               lda       ,x+
                    ifne      H6309
                    jmp       ,w
                    else
                    jmp       [,s]
                    endc
L00F6               lda       a,u                 remap to CMP values
L00F8               sta       ,y+                 and save RGB data
                    decb
                    bne       L00F2
                    ifeq      H6309
                    leas      $02,s               clean up stack
                    endc
L00FF               puls      pc,u,y,x,b,a

SetPals             pshs      u,y,x,b,a           puts palette data in.
                    lda       >WGlobal+G.CrDvFl   is this screen active?
                    beq       L00FF               0 = not active
                    leax      <VD.Palet,u         point X to palette table
                    ldy       #$FFB0              point Y to palette register
                    lda       >WGlobal+G.MonTyp   universal RGB/CMP 0 = CMP, 1 = RGB, 2 = MONO
                    bne       L00E6               if not 0 (CMP) don't re-map colors
                    leau      >L00F6,pcr          else do re-map colors
                    bra       L00EA

L011A               fcb       $12,$36,$09,$24     default palette data
                    fcb       $3f,$1b,$2d,$26
                    fcb       $00,$12,$00,$3f
                    fcb       $00,$12,$00,$26

* converts CMP to RGB
L012A               fdb       $000c,$020e,$0709,$0510
                    fdb       $1c2c,$0d1d,$0b1b,$0a2b
                    fdb       $2211,$1221,$0301,$1332
                    fdb       $1e2d,$1f2e,$0f3c,$2f3d
                    fdb       $1708,$1506,$2716,$2636
                    fdb       $192a,$1a3a,$1829,$2838
                    fdb       $1404,$2333,$2535,$2434
                    fdb       $203B,$313E,$3739,$3F30

* Entry: A = char to write
*        Y = path desc ptr
Write               equ       *
                    ifne      COCO2
                    cmpa      #$0F
                    else
                    cmpa      #$0E
                    endc
                    bls       Dispatch
                    cmpa      #$1B                escape code?
                    lbeq      Escape              yes, do escape immediately
                    ifne      COCO2
                    cmpa      #$1E
                    bcs       Do1E
                    cmpa      #$1F
                    bls       Dispatch
                    else
                    cmpa      #$1F
                    lbls      NoOp                ignore gfx codes if not CoCo 2 compatible
                    endc
                    tsta
                    bmi       L01BA
                    ldb       <VD.CFlag,u
                    beq       L019A
                    cmpa      #$5E
                    bne       L018A               re-map characters from ASCII-VDG
                    clra
                    bra       L01BA
L018A               cmpa      #$5F
                    bne       L0192
                    lda       #$1F
                    bra       L01BA
L0192               cmpa      #$60
                    bne       L01AA
                    lda       #$67
                    bra       L01BA

L019A               cmpa      #$7C                true lowercase
                    bne       L01A2
                    lda       #$21
                    bra       L01BA
L01A2               cmpa      #$7E
                    bne       L01AA
                    lda       #$2D
                    bra       L01BA
L01AA               cmpa      #$60
                    bcs       L01B2               re-map ASCII
                    suba      #$60
                    bra       L01BA
L01B2               cmpa      #$40
                    bcs       L01B8
                    suba      #$40
L01B8               eora      #$40
L01BA               ldx       <VD.CrsrA,u
                    sta       ,x+
                    stx       <VD.CrsrA,u
                    cmpx      <VD.ScrnE,u
                    bcs       L01CA
                    lbsr      SScrl               if at end of screen, scroll it
L01CA               lbsr      ShowCrsr            ends with a CLRB/RTS anyhow
NoOp                clrb
                    rts

                    ifne      COCO2
Do1E                lbsr      ChkDvRdy
                    bcc       Dispatch
                    rts
                    endc

Dispatch            leax      >DCodeTbl,pcr
                    lsla
                    ldd       a,x
                    jmp       d,x

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

                    ifne      COCO2
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
                    endc

* Code fragment from original CoCo 3 VDGInt by Tandy - not referenced
*         comb
*         ldb   #E$Write
*         rts

* $1B does palette changes
Escape              ldx       <VD.EPlt1,u         now X points to VD.NChar
                    lda       ,x                  get char following
                    cmpa      #$30                default color?
                    bne       L0209               branch if not
                    lbsr      SetupPal            do default palette
                    lbra      L026E               put palette and exit

* The reasons for the commented out lines below are discussed in cowin.asm
* where the functions are identical. RG
L0209               cmpa      #$31                change palette?
                    ifne      COCO2
                    lbeq      PalProc             branch if so
                    cmpa      #$21
                    lbne      NoOp                return without error
                    ldx       PD.RGS,y            get registers
                    lda       R$A,x               get path
                    ldx       <D.Proc             get current proc
* There does not seem to be a reason for the next two lines. RG
*         cmpa  >P$SelP,x     compare against selected path
*         beq   L0249          branch if empty
                    ldb       >P$SelP,x           else load selected path from process descriptor
                    sta       >P$SelP,x           and store passed path
                    pshs      y                   save our path desc ptr
                    bsr       L024A               get device table entry for path
                    ldy       V$STAT,y            get driver statics
                    ldx       <D.CCMem            get CoCo memory
* Again, there does not seem to be a reason for this or the next branch. RG
*         cmpy  <G.CurDev,x
                    puls      y                   restore our path desc ptr
*         bne   L0248
                    inc       <VD.DFlag,u
                    ldy       <G.CurDev,x         get current static mem
                    sty       <G.PrWMPt,x         copy to previous
                    stu       <G.CurDev,x         and save new static mem ptr
* Give system a chance to stabilize. RG
                    ldx       #2
                    os9       F$Sleep
L0248               clrb
L0249               rts

* Entry: A = path to process
L024A               leax      <P$Path,x           point to path table in process descriptor
                    lda       b,x                 get system path number
                    ldx       <D.PthDBT           point to path descriptor base table
* protect regB incase of error report. RG
                    pshs      b
                    os9       F$Find64            put found path descriptor in Y
                    ldy       PD.DEV,y            load Y with device table entry
                    puls      b,pc
                    else
                    bne       NoOp
                    endc

PalProc             leax      <DoPals,pcr
                    ldb       #$02
                    lbra      GChar

DoPals              ldx       <VD.EPlt1,u
                    ldd       ,x
                    cmpa      #16                 max 16 palettes
                    lbhi      IllArg
                    cmpb      #63                 color has max. 63
                    lbhi      IllArg
                    leax      <VD.Palet,u         to palette buffer
                    stb       a,x                 save it
L026E               lbsr      SetPals
                    clrb
                    rts

*         anda  #$0F
*         andb  #$3F
*         leax  <VD.Palet,u
*         stb   a,x
*L026E    inc   <VD.DFlag,u
*         clrb
*         rts

* Screen scroll
SScrl               ldx       <VD.ScrnA,u
                    ifne      H6309
                    ldd       #$2060
                    leay      a,x                 down one line
                    ldw       #512-32
                    tfm       y+,x+               scroll screen up
                    stx       <VD.CrsrA,u         save new cursor address
                    else
                    leax      <32,x
L0279               ldd       ,x++
                    std       <-34,x
                    cmpx      <VD.ScrnE,u
                    bcs       L0279
                    leax      <-32,x
                    stx       <VD.CrsrA,u
                    lda       #32
                    ldb       #$60
                    endc
L028D               stb       ,x+
                    deca
                    bne       L028D
                    rts

* $0D - carriage return
Retrn               bsr       HideCrsr            hide cursor
                    ifne      H6309
                    aim       #$E0,<VD.CrsAL,u
                    else
                    tfr       x,d
                    andb      #$E0                strip out bits 0-4
                    stb       <VD.CrsAL,u         save updated cursor address
                    endc
ShowCrsr            ldx       <VD.CrsrA,u         get cursor address
                    lda       ,x                  get char at cursor position
                    sta       <VD.CChar,u         save it
                    lda       <VD.CColr,u         get cusor character
                    beq       RtsOk               branch if none
L02A9               sta       ,x                  else turn on cursor
RtsOk               clrb
                    rts

* $0A - moves cursor down
CurDown             bsr       HideCrsr            hide cursor
                    leax      <32,x               move X down one line
                    cmpx      <VD.SCrnE,u         at the end of the screen?
                    bcs       L02C1               branch if not
                    leax      <-32,x              else go back up one line
                    pshs      x                   save X
                    lbsr      SScrl               and scroll the screen
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
                    cmpx      <VD.SCrnE,u         compare against start of screen
                    bcc       ShowCrsr            if past end, ignore it
                    stx       <VD.CrsrA,u         else save updated pointer
                    bra       ShowCrsr            and show cursor

* $0B - erase from current char to end of screen
ErEOScrn            bsr       HideCrsr            kill the cursor
*         bra   L02E8          and clear the rest of the screen
                    fcb       skip2

* $0C - clear screen & home cursor
ClrScrn             bsr       CurHome             home cursor (returns X pointing to start of screen)
                    lda       #$60                get default char
ClrSLoop            sta       ,x+                 save at location
                    cmpx      <VD.SCrnE,u         end of screen?
                    bcs       ClrSLoop            branch if not
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
                    suba      #C$SPAC             take out ASCII space
                    bne       L0313               branch if not zero
                    sta       <VD.CColr,u         else save cursor color zero (no cursor)
                    bra       HideCrsr            and hide cursor
L0313               cmpa      #$0B                greater than $0B?
                    bge       RtsOk               yep, just ignore byte
                    cmpa      #$01                is it one?
                    bgt       L031F               branch if greater
                    lda       #$AF                else get default blue cursor color
                    bra       L032F               and save cursor color
L031F               cmpa      #$02                is it two?
                    bgt       L0327               branch if larger
                    lda       #$A0                else get black cursor color
                    bra       L032F               and save it
** BUG ** BUG ** BUG ** BUG
L0327               suba      #$03                ** BUG FIXED ! **  !!! Was SUBB
                    lsla                          shift into upper nibble
                    lsla
                    lsla
                    lsla
                    ora       #$8F
L032F               sta       <VD.CColr,u         save new cursor
                    ldx       <VD.CrsrA,u         get cursor address
                    lbra      L02A9               branch to save cursor in X

* $02 - moves cursor to X,Y
CurXY               ldb       #$02                we want to claim the next two chars
                    leax      <DoCurXY,pcr        point to processing routine
                    lbra      GChar               get two chars

DoCurXY             bsr       HideCrsr            hide cursor
                    ldb       <VD.NChr2,u         get ASCII Y-pos
                    subb      #C$SPAC             take out ASCII space
                    lda       #32                 go down
                    mul                           multiply it
                    addb      <VD.NChar,u         add in X-pos
                    adca      #$00
                    subd      #C$SPAC             take out another ASCII space
                    addd      <VD.ScrnA,u         add top of screen address
                    cmpd      <VD.ScrnE,u         at end of the screen?
                    lbcc      RtsOk               exit if off the screen
                    std       <VD.CrsrA,u         otherwise save new cursor address
                    lbra      ShowCrsr            and show cursor

* $04 - clear characters to end of line
ErEOLine            bsr       HideCrsr            hide cursor
                    tfr       x,d                 move current cursor position to D
                    andb      #$1F                number of characters put on this line
                    negb                          negative
                    bra       L0374               and clear one line
*         pshs  b
*         ldb   #32
*         subb  ,s+
*         bra   L0376          and clear one line

* $03 - erase line cursor is on
DelLine             lbsr      Retrn               do a carriage return
*         ldb   #32          B = $00 from Retrn
L0374               addb      #32                 B = $00 from Retrn
L0376               lda       #$60                get default char
                    ldx       <VD.CrsrA,u         get cursor address
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
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
DispAlfa            pshs      x,y,a
                    ifne      COCO2
                    stb       <VD.Alpha,u
                    endc
                    clr       <VD.DGBuf,u
                    lda       >PIA1Base+2
                    anda      #$07
                    ora       ,s+
                    tstb
                    bne       L03AD
                    anda      #$EF
                    ora       <VD.CFlag,u         lowercase flag
L03AD               sta       <VD.TFlg1,u         save VDG info
                    tst       >WGlobal+G.CrDvFl   is this screen currently showing?
                    lbeq      L0440
                    sta       >PIA1Base+2         set lowercase in hardware
                    ldy       #$FFC6              Ok, now set up via old CoCo 2 mode
                    ifne      COCO2
                    tstb
                    bne       L03CB
                    endc
* Set up VDG screen for text
                    stb       -6,y                $FFC0
                    stb       -4,y                $FFC2
                    stb       -2,y                $FFC4
                    lda       <VD.ScrnA,u
                    ifne      COCO2
                    bra       L03D7
* Set up VDG screen for graphics
L03CB               stb       -6,y                $FFC0
                    stb       -3,y                $FFC3
                    stb       -1,y                $FFC5
                    lda       <VD.SBAdd,u
                    endc
L03D7               lbsr      SetPals
                    ldb       <D.HINIT
                    orb       #$80                set CoCo 2 compatible mode
                    stb       <D.HINIT
                    stb       >$FF90
                    ldb       <D.VIDMD
                    andb      #$78
                    stb       >$FF98
                    stb       <D.VIDMD
                    pshs      a
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       >$FF99              set resolution AND border color
                    std       <D.VIDRS
                    puls      a
                    tfr       a,b
                    anda      #$1F
                    pshs      a
                    andb      #$E0
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    ldx       <D.SysDAT
*         leax  a,x
                    abx
*         lda   $01,x          get block number to use
*         pshs  a
*         anda  #$F8          keep high bits only
*         lsla
*         lsla
*         clrb
* PATCH START: Mod for >512K systems, Robert Gault
                    ldb       1,x                 get block number to use
                    pshs      b
                    andb      #$F8                keep high bits only
                    clra
                    lslb
                    rola
                    lslb
                    rola
                    sta       >$FF9B
                    tfr       b,a
                    clrb
* PATCH END: Mod for >512K systems, Robert Gault
                    std       <D.VOFF1            display it
                    std       >$FF9D
                    ldd       #$0F07
                    sta       <D.VOFF2
                    sta       >$FF9C
                    puls      a
                    asla
                    asla
                    asla
                    asla
                    asla
                    ora       ,s+
* Y now holds $FFC6, so we don't need to work with X here
*         ldx   #$FFC6
                    lsra
L0430               lsra
                    bcc       L041A
                    leay      1,y
                    sta       ,y+
                    fcb       skip2               skip 2 bytes
L041A               sta       ,y++                rather than additional leax 1,x on next line
                    decb
                    bne       L0430
L0440               clrb
                    puls      pc,y,x

GChar1              ldb       #$01
GChar               stb       <VD.NGChr,u
                    stx       <VD.RTAdd,u
                    clrb
                    rts

                    ifne      COCO2
* $0F - display graphics
Do0F                leax      <DispGfx,pcr
                    ldb       #$02
                    bra       GChar

DispGfx             ldb       <VD.Rdy,u           memory already alloced?
                    bne       L0468               branch if so
                    lbsr      Get8KHi             else get an 8k block from high ram
                    bcs       L0486               branch if error
                    stb       <VD.GBuff,u         save starting block number
                    stb       <VD.Blk,u
                    tfr       d,x
                    ldd       <D.Proc
                    pshs      u,b,a
                    ldd       <D.SysPrc           get system proc desc
                    std       <D.Proc             make current
                    ldb       #$01                one block
                    os9       F$MapBlk            map it in to our space
                    tfr       u,x                 get address into x
                    puls      u,b,a               restore other regs
                    std       <D.Proc             restore process pointer
                    bcs       L0486               branch if error occurred
                    stx       <VD.SBAdd,u         else store address of gfx mem
                    inc       <VD.Rdy,u           we're ready
                    lda       #$01
                    ldb       #$20
                    bsr       L04D9
                    lbsr      Do13                erase gfx screen
L0468               lda       <VD.NChr2,u         get character after next
                    sta       <VD.PMask,u         store color set (0-3)
                    anda      #$03                mask off pertinent bytes
                    leax      >Mode1Clr,pcr       point to mask byte table
                    lda       a,x                 get byte
                    sta       <VD.Msk1,u          save mask byte here
                    sta       <VD.Msk2,u          and here
                    lda       <VD.NChar,u         get next char, mode byte (0-1)
                    cmpa      #$01                compare against max
                    bls       L0487               branch if valid
                    comb
                    ldb       #E$BMode            else invalid mode specified, send error
L0486               rts

L0487               tsta                          test user supplied mode byte
                    beq       L04A7               branch if 256x192
                    ldd       #$C003
                    std       <VD.MCol,u
                    lda       #$01
                    sta       <VD.Mode,u          128x192 mode
                    lda       #$E0
                    ldb       <VD.NChr2,u
                    andb      #$08
                    beq       L04A0
                    lda       #$F0
L04A0               ldb       #$03
                    leax      <L04EB,pcr
                    bra       L04C4
L04A7               ldd       #$8001
                    std       <VD.MCol,u
                    lda       #$FF
                    tst       <VD.Msk1,u
                    beq       L04BA
                    sta       <VD.Msk1,u
                    sta       <VD.Msk2,u
L04BA               sta       <VD.Mode,u          256x192 mode
                    lda       #$F0
                    ldb       #$07
                    leax      <L04EF,pcr
L04C4               stb       <VD.PixBt,u
                    stx       <VD.MTabl,u
                    ldb       <VD.NChr2,u
                    andb      #$04
                    lslb
                    pshs      b
                    ora       ,s+
                    ldb       #$01
* Indicate screen is current; next line is critical for >512K - Robert Gault
                    stb       >WGlobal+G.CrDvFl   is this screen currently showing?
                    lbra      DispAlfa

L04D9               pshs      x,b,a
                    clra
                    ldb       $02,s
                    ldx       <D.SysMem
                    leax      d,x
                    puls      b,a
L04E4               sta       ,x+
                    decb
                    bne       L04E4
                    puls      pc,x

L04EB               fdb       $C030,$0C03

L04EF               fcb       $80,$40,$20,$10,$08,$04,$02,$01

* $11 - set color
Do11                leax      <SetColor,pcr
                    lbra      GChar1
SetColor            lda       <VD.NChar,u         get next char
                    sta       <VD.NChr2,u         save in next after
L0503               clr       <VD.NChar,u         and clear next
                    lda       <VD.Mode,u          which mode?
                    bmi       L050E               branch if 256x192
                    inc       <VD.NChar,u
L050E               lbra      L0468

* $12 - end graphics
Do12                ldx       <VD.SBAdd,u         get screen address
                    beq       L051B               branch if empty
                    clra
                    ldb       #$20
                    bsr       L04D9
L051B               leay      <VD.GBuff,u         point Y to graphics buffer block numbers
                    ldb       #$03                number of blocks starting at VD.GBuff
                    pshs      u,b                 save our static pointer, and counter (3)
L0522               lda       ,y+                 get next block
                    beq       L052D               if empty, continue
                    clrb                          else clear B
                    tfr       d,x                 transfer D to X
                    incb                          1 block to deallocate
                    os9       F$DelRAM            deallocate it
L052D               dec       ,s                  dec counter
                    bgt       L0522               if not zero, get more
* Note: this seems to be a bug.  Here, Y is pointing to VD.HiRes ($4D), which
* is the block number of any CoCo 3 Hi-Res screen.  This $0E command just
* deals with CoCo 2 graphics modes.  What I think should happen here is
* that the byte flood fill buffer should be checked for non-zero,
* then freed.  It looks as though this code would work IF the Hi-Res
* variables from $4D-$5B, which are CoCo 3 specific, didn't exist.  So
* this bug was introduced when the CoCo 3 specific static vars were added
* between VD.AGBuf and VD.FFMem
                    ldu       VD.FFMem-VD.HiRes,y get flood fill stack memory ptr
                    beq       L053B
                    ldd       #FFStSz             get flood fill stack size
                    os9       F$SRtMem
L053B               puls      u,b
                    clr       <VD.Rdy,u
                    lbra      Do0E

* $10 - preset screen to a specific color
Do10                leax      <PrstScrn,pcr
                    lbra      GChar1

PrstScrn            lda       <VD.NChar,u         get next char
                    tst       <VD.Mode,u          which mode?
                    bpl       L0559               branch if 128x192 4 color
                    ldb       #$FF                assume we will clear with $FF
                    anda      #$01                mask out all but 1 bit (2 colors)
                    beq       Do13                erase graphic screen with color $00
                    bra       L0564               else erase with color $FF
L0559               anda      #$03                mask out all but 2 bits (4 colors)
                    leax      >Mode1Clr,pcr       point to color table
                    ldb       a,x                 get appropriate byte
                    bra       L0564               and start the clearing

* $13 - erase graphics
Do13                clrb
L0564               ldx       <VD.SBAdd,u
                    ifne      H6309
* Note: 6309 version clears from top to bottom
*       6809 version clears from bottom to top
                    ldw       #$1800
                    pshs      b
                    tfm       s,x+
                    puls      b
                    else
                    leax      >$1801,x
L056B               stb       ,-x
                    cmpx      <VD.SBAdd,u
                    bhi       L056B
                    endc

* $14 - home graphics cursor
Do14                equ       *
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       <VD.GCrsX,u
                    rts

* 128x192 4 color pixel table
Mode1Clr            fcb       $00,$55,$aa,$ff

* Fix X/Y coords:
*  - if Y > 191 then cap it at 191
*  - adjust X coord if in 128x192 mode
FixXY               ldd       <VD.NChar,u         get next 2 chars
                    cmpb      #192                Y greater than max?
                    bcs       L0585               branch if lower than
                    ldb       #191
L0585               tst       <VD.Mode,u          which mode?
                    bmi       L058B               branch if 256x192
                    lsra                          else divide X by 2
L058B               std       <VD.NChar,u         and save
                    rts

* $15 - set graphics cursor
Do15                leax      <SetGC,pcr
GChar2              ldb       #$02
                    lbra      GChar

SetGC               bsr       FixXY               fix coords
                    std       <VD.GCrsX,u         and save new gfx cursor pos
                    clrb
                    rts

* $19 - erase point
Do19                clr       <VD.Msk1,u
* $18 - set point
Do18                leax      <DrawPnt,pcr
                    bra       GChar2

DrawPnt             bsr       FixXY               fix coords
                    std       <VD.GCrsX,u         save as new gfx cursor pos
                    bsr       DrwPt2
                    lbra      L067C
DrwPt2              lbsr      XY2Addr
L05B3               tfr       a,b
                    comb
                    andb      ,x
                    stb       ,x
                    anda      <VD.Msk1,u
                    ora       ,x
                    sta       ,x
                    rts

* $17 - erase line
Do17                clr       <VD.Msk1,u

* $16 - draw line
Do16                leax      <DrawLine,pcr
                    bra       GChar2

DrawLine            bsr       FixXY               fix up coords
                    leas      -$0E,s
                    std       $0C,s
                    lbsr      XY2Addr
                    stx       $02,s
                    sta       $01,s
                    ldd       <VD.GCrsX,u
                    lbsr      XY2Addr
                    sta       ,s
*         IFNE  H6309         no longer needed RG
*         clrd
*         ELSE
*         clra
*         clrb
*         ENDC
*         std   $04,s
                    lda       #$BF
                    suba      <VD.GCrsY,u
                    sta       <VD.GCrsY,u
                    lda       #$BF
                    suba      <VD.NChr2,u
                    sta       <VD.NChr2,u
                    lda       #$FF
                    sta       $06,s
                    clra
                    ldb       <VD.GCrsX,u
                    subb      <VD.NChar,u
                    sbca      #$00
                    bpl       L0608
                    ifne      H6309
                    negd
                    else
                    nega
                    negb
                    sbca      #$00
                    endc
                    neg       $06,s
L0608               std       $08,s
                    bne       L0611
                    ldd       #$FFFF
                    std       $04,s
L0611               lda       #$E0
                    sta       $07,s
                    clra
                    ldb       <VD.GCrsY,u
                    subb      <VD.NChr2,u
                    sbca      #$00
                    bpl       L0626
                    ifne      H6309
                    negd
                    else
                    nega
                    negb
                    sbca      #$00
                    endc
                    neg       $07,s
L0626               std       $0A,s
* New routine to halve the error value RG
                    cmpd      $08,s               is dX>dY
                    pshs      cc                  save answer
                    ifne      H6309               assume true and negate regD
                    negd
                    else
                    nega
                    negb
                    sbca      #0
                    endc
                    puls      cc
                    bhs       ch1
                    ldd       $08,s               get dY
ch1                 equ       *
                    ifne      H6309
                    asrd
                    else
                    asra
                    rorb
                    endc
                    cmpd      #0
                    beq       L0632               error must not be zero
* End of new routine RG
                    std       $04,s
                    bra       L0632
L062A               sta       ,s
                    ldd       $04,s
                    subd      $0A,s
                    std       $04,s
L0632               lda       ,s
                    lbsr      L05B3
                    cmpx      $02,s
                    bne       L0641
                    lda       ,s
                    cmpa      $01,s
                    beq       L0675
L0641               ldd       $04,s
                    bpl       L064F
                    addd      $08,s
                    std       $04,s
                    lda       $07,s
                    leax      a,x
                    bra       L0632
L064F               lda       ,s
                    ldb       $06,s
                    bpl       L0665
                    lsla
                    ldb       <VD.Mode,u          which mode?
                    bmi       L065C               branch if 256x192
                    lsla
L065C               bcc       L062A
                    lda       <VD.MCol2,u
                    leax      -$01,x
                    bra       L062A
L0665               lsra
                    ldb       <VD.Mode,u          which mode?
                    bmi       L066C               branch if 256x192
                    lsra
L066C               bcc       L062A
                    lda       <VD.MCol,u
                    leax      $01,x
                    bra       L062A
L0675               ldd       $0C,s
                    std       <VD.GCrsX,u
                    leas      $0E,s
L067C               lda       <VD.Msk2,u
                    sta       <VD.Msk1,u
                    clrb
                    rts

* $1C - erase circle
Do1C                clr       <VD.Msk1,u
* $1A - draw circle
Do1A                leax      <Circle,pcr
                    lbra      GChar1

Circle              leas      -$04,s
                    ldb       <VD.NChar,u         get radius
                    stb       $01,s               store on stack
                    clra
                    sta       ,s
                    addb      $01,s
                    adca      #$00
                    ifne      H6309
                    negd
                    else
                    nega
                    negb
                    sbca      #$00
                    endc
                    addd      #$0003
                    std       $02,s
L06AB               lda       ,s
                    cmpa      $01,s
                    bcc       L06DD
                    ldb       $01,s
                    bsr       L06EB
                    clra
                    ldb       $02,s
                    bpl       L06C5
                    ldb       ,s
                    ifne      H6309
                    lsld
                    lsld
                    else
                    lslb
                    rola
                    lslb
                    rola
                    endc
                    addd      #$0006
                    bra       L06D5
L06C5               dec       $01,s
                    clra
                    ldb       ,s
                    subb      $01,s
                    sbca      #$00
                    ifne      H6309
                    lsld
                    lsld
                    else
                    lslb
                    rola
                    lslb
                    rola
                    endc
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
                    ifne      H6309
                    negd
                    else
                    nega
                    negb
                    sbca      #$00
                    endc
                    std       $06,s
                    ldb       ,s
                    clra
                    std       ,s
                    ifne      H6309
                    negd
                    else
                    nega
                    negb
                    sbca      #$00
                    endc
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
L0734               pshs      b,a
                    ldb       <VD.GCrsY,u
                    clra
                    leax      d,x
                    cmpx      #$0000
                    bmi       L0746
                    cmpx      #$00BF
                    ble       L0748
L0746               puls      pc,b,a
L0748               ldb       <VD.GCrsX,u
                    clra
                    tst       <VD.Mode,u          which mode?
                    bmi       L0753               branch if 256x192
                    ifne      H6309
                    lsld
                    else
                    lslb                          else multiply D by 2
                    rola
                    endc
L0753               addd      ,s++
                    tsta
                    beq       L0759
                    rts
L0759               pshs      b
                    tfr       x,d
                    puls      a
                    tst       <VD.Mode,u          which mode?
                    lbmi      DrwPt2              branch if 256x192
                    lsra                          else divide a by 2
                    lbra      DrwPt2

* $1D - flood fill
Do1D                clr       <VD.FF6,u
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
L0883               pshs      b,a
                    cmpb      #191
                    bhi       L08B2
                    tst       <VD.Mode,u          which mode?
                    bmi       L0892               branch if 256x192
                    cmpa      #$7F
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
                    puls      pc,b,a
L08B2               orcc      #Carry
                    puls      pc,b,a
L08B6               pshs      b,a
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
                    puls      pc,b,a
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
                    bra       L08E5               do a clean return

L0905               pshs      b,a
                    ldd       <VD.FFSPt,u
                    subd      #$0004
                    cmpd      <VD.FFMem,u
                    bcs       L0924
                    std       <VD.FFSPt,u
                    tfr       d,y
                    lda       <VD.FFFlg,u
                    sta       ,y
                    stx       $01,y
                    puls      b,a
                    sta       $03,y
                    rts
L0924               ldb       #$F5
                    stb       <VD.FF6,u
                    puls      pc,b,a
L092B               ldd       <VD.FFSPt,u
                    cmpd      <VD.FFSTp,u         top of flood fill stack?
                    lbcc      L0880
                    tfr       d,y
                    addd      #$0004
                    std       <VD.FFSPt,u
                    lda       ,y
                    sta       <VD.FFFlg,u
                    ldd       $01,y
                    tfr       d,x
                    lda       $03,y
                    andcc     #^Carry
                    rts
                    endc

GetStat             ldx       PD.RGS,y
                    cmpa      #SS.AlfaS
                    beq       Rt.AlfaS
                    cmpa      #SS.ScSiz
                    beq       Rt.ScSiz
                    cmpa      #SS.Cursr
                    beq       Rt.Cursr
                    ifne      COCO2
                    cmpa      #SS.DSTAT
                    lbeq      Rt.DSTAT
                    endc
                    cmpa      #SS.Palet
                    lbeq      Rt.Palet
                    comb
                    ldb       #E$UnkSvc
                    rts

* Returns window or screen size
Rt.ScSiz            equ       *
                    ifne      H6309
                    ldq       #$00200010          a fast cheat
                    stq       R$X,x
                    else
*         ldb   <VD.Col,u
                    ldd       #$0020
                    std       R$X,x
*         ldb   <VD.Row,u
                    ldb       #$10
                    std       R$Y,x
                    endc
                    clrb
                    rts

* Get palette information
Rt.Palet            pshs      u,y,x
                    leay      <VD.Palet,u         point to palette data in proc desc
                    ldu       R$X,x               pointer to 16 byte palette buffer
                    ldx       <D.Proc             current proc desc
                    ldb       P$Task,x            destination task number
                    clra                          from task 0
                    tfr       y,x
                    ldy       #16                 move 16 bytes
                    os9       F$Move
                    puls      pc,u,y,x

* Return VDG alpha screen memory info
Rt.AlfaS            ldd       <VD.ScrnA,u
                    anda      #$E0                keep bits 4-6
                    lsra
                    lsra
                    lsra
                    lsra                          move to bits 0-2
                    ldy       <D.SysDAT
                    ldd       a,y
                    lbsr      L06E1               map it in the process' memory area
                    bcs       L0521
                    pshs      b,a                 offset to block address
                    ldd       <VD.ScrnA,u
                    anda      #$1F                make sure it's within the block
                    addd      ,s
                    std       R$X,x               memory address of the buffer
                    ldd       <VD.CrsrA,u
                    anda      #$1F
                    addd      ,s++
                    std       R$Y,x               memory address of the cursor
                    lda       <VD.Caps,u          save caps lock status in A and exit
                    bra       L051E

* Returns VDG alpha screen cursor info
Rt.Cursr            ldd       <VD.CrsrA,u
                    subd      <VD.ScrnA,u
                    pshs      b,a
                    clra
                    andb      #$1F
                    addb      #$20
                    std       R$X,x               save column position in ASCII
                    puls      b,a                 then divide by 32
                    lsra
                    rolb
                    rolb
                    rolb
                    rolb
                    clra
                    andb      #$0F                only 16 lines to a screen
                    addb      #$20
                    std       R$Y,x
                    ldb       <VD.CFlag,u
                    lda       <VD.CChar,u
                    bmi       L051E
                    cmpa      #$60
                    bcc       L0509
                    cmpa      #$20
                    bcc       L050D
                    tstb
                    beq       L0507
                    cmpa      #$00
                    bne       L04FF
                    lda       #$5E
                    bra       L051E               save it and exit

L04FF               cmpa      #$1F
                    bne       L0507
                    lda       #$5F
                    bra       L051E
L0507               ora       #$20                turn it into ASCII from VDG codes
L0509               eora      #$40
                    bra       L051E
L050D               tstb
                    bne       L051E
                    cmpa      #$21                remap specific codes
                    bne       L0518
                    lda       #$7C
                    bra       L051E
L0518               cmpa      #$2D
                    bne       L051E
                    lda       #$7E
L051E               sta       R$A,x
                    clrb
L0521               rts

                    ifne      COCO2
Rt.DSTAT            bsr       ChkDvRdy
                    bcs       L0A4F
                    ldd       <VD.GCrsX,u
                    lbsr      XY2Addr
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
                    andb      #$FC
                    orb       ,s+
                    ldx       PD.RGS,y
                    stb       R$A,x
                    ldd       <VD.GCrsX,u
                    std       R$Y,x
                    ldb       <VD.Blk,u
                    lbsr      L06E1
                    bcs       L0A4F
                    std       R$X,x
L0A4E               clrb
L0A4F               rts

ChkDvRdy            ldb       <VD.Rdy,u           is device ready?
                    bne       L0A4E               branch if so
                    lbra      NotReady            else return error

* Entry: A = X coor, B = Y coor
XY2Addr             pshs      y,b,a               save off
                    ldb       <VD.Mode,u          get video mode
                    bpl       L0A60               branch if 128x192 (divide A by 4)
                    lsra                          else divide A by 8
L0A60               lsra
                    lsra
                    pshs      a                   save on stack
                    ldb       #191                get max Y
                    subb      $02,s               subtract from Y on stack
                    lda       #32                 bytes per line
                    mul
                    addb      ,s+                 add offset on stack
                    adca      #$00
                    ldy       <VD.SBAdd,u         get base address
                    leay      d,y                 move D bytes into address
                    lda       ,s                  pick up original X coor
                    sty       ,s                  put offset addr on stack
                    anda      <VD.PixBt,u
                    ldx       <VD.MTabl,u
                    lda       a,x
                    puls      pc,y,x              X = offset address, Y = base
                    endc

SetStat             ldx       PD.RGS,y
                    cmpa      #SS.ComSt
                    beq       Rt.ComSt
                    ifne      COCO2
                    cmpa      #SS.AAGBf
                    beq       Rt.AAGBf
                    cmpa      #SS.SLGBf
                    beq       Rt.SLGBf
                    endc
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

* Allow switch between true/fake lowercase
Rt.ComSt            ldd       R$Y,x
L054C               ldb       #$10                sets screen to lowercase
                    bita      #$01                Y = 0 = true lowercase, Y = 1 = fake lower
                    bne       L0553
                    clrb
L0553               stb       <VD.CFlag,u
                    ldd       #$2010              32x16
                    inc       <VD.DFlag,u
                    std       <VD.Col,u
                    rts

                    ifne      COCO2
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
                    endc

* Display Table
* 1st entry = display code
* 2nd entry = # of 8K blocks
DTabl               fcb       $14                 0: 640x192, 2 color
                    fcb       $02                 16K
                    fcb       $15                 1: 320x192, 4 color
                    fcb       $02                 16K
                    fcb       $16                 2: 160x192, 16 color
                    fcb       $02                 16K
                    fcb       $1D                 3: 640x192, 4 color
                    fcb       $04                 32K
                    fcb       $1E                 4: 320x192, 16 color
                    fcb       $04                 32K

* Allocates and maps a hires screen into process address
Rt.AScrn            ldd       R$X,x               get screen type from caller's X
                    cmpd      #$0004              screen type 0-4
                    lbhi      IllArg              if higher than legal limit, return error
                    pshs      y,x,b,a             else save off regs
                    ldd       #$0303
                    leay      <VD.HiRes,u         pointer to screen descriptor
                    lbsr      L06C7               gets next free screen descriptor
                    bcs       L05AF               branch if none found
                    sta       ,s                  save screen descriptor on stack
                    ldb       $01,s               get screen type
*         stb   $02,y          and store in VD.SType
                    stb       (VD.SType-VD.HiRes),y and store in VD.SType
                    leax      >DTabl,pcr          point to display table
                    lslb                          multiply index by 2 (word entries)
                    abx                           point to display code, #blocks
                    ldb       $01,x               get number of blocks
*         stb   $01,y          VD.NBlk
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
                    ldb       ,y                  restore the starting block number again

                    lda       $01,x               number of blocks
                    lbsr      L06E3
                    bcs       L05AF
                    ldx       $02,s
                    std       R$X,x
                    ldb       ,s
                    clra
                    std       R$Y,x
L05AF               leas      $02,s
                    puls      pc,y,x
L05B3X              leas      $02,s

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
*         leas  a,s          removed because it yanks wrong data; RG.
DA020               rts                           and exit

* Get current screen info for direct writes - added in NitrOS-9
Rt.ScInf            pshs      x                   save caller's regs ptr
                    ldd       R$Y,x               get screen
                    bmi       L05C8
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
                    std       R$X,x
L05DB               clrb
L05DC               puls      pc,x
L05DE               beq       L05F1
                    cmpb      #$03
                    bhi       L05F1
                    bsr       GetScrn
                    beq       L05F1
                    ldb       ,x
                    beq       L05F1
                    lda       $01,x
                    andcc     #^Carry
                    rts
L05F1               bra       IllArg

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

ShowS               cmpb      #$03                no more than 3 graphics buffers
                    bhi       L066D
                    bsr       GetScrn             point X to appropriate screen descriptor
                    beq       L066D               branch if not allocated
                    ldb       $02,x               VD.SType - screen type 0-4
                    cmpb      #$04
                    bhi       L066D
                    lslb
                    pshs      x
                    leax      >DTabl,pcr
                    lda       b,x                 get proper display code
                    puls      x
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
Get8KHi             ldb       #$01
L06DDX              os9       F$AlHRAM            allocate a screen
                    rts

L06E1               lda       #$01                map screen into memory
L06E3               pshs      u,x,b,a
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

L06FD               puls      pc,u,x,b,a          if error, then restore D

L06FF               pshs      y,x,a               deallocate screen
                    bsr       L0710
                    bcs       L070E
                    ldd       #DAT.Free           set memory to unused
L0708               std       ,x++
                    dec       ,s
                    bne       L0708
L070E               puls      pc,y,x,a

L0710               equ       *
                    ifne      H6309
                    pshs      a
                    lde       #$08
                    else
                    pshs      b,a
                    lda       #$08                number of blocks to check
                    sta       $01,s
                    endc
                    ldx       <D.Proc
                    leax      <P$DATImg+$10,x     to end of CoCo's DAT image map
                    clra
                    addb      ,s
                    decb
L071F               cmpd      ,--x
                    beq       L072A
                    ifne      H6309
                    dece
                    else
                    dec       $01,s
                    endc
                    bne       L071F
                    bra       L0743
L072A               equ       *
                    ifne      H6309
                    dece
                    else
                    dec       $01,s
                    endc
                    dec       ,s
                    beq       L0738
                    decb
                    cmpd      ,--x
                    beq       L072A
                    bra       L0743
L0738               equ       *
                    ifne      H6309
                    tfr       e,a
                    else
                    lda       $01,s               get lowest block number found
                    endc
                    lsla
                    lsla
                    lsla
                    lsla
                    lsla                          multiply by 32 (convert to address)
                    clrb                          clear carry
                    ifne      H6309
                    puls      b,pc
L0743               puls      a
                    else
                    leas      $02,s
                    rts
L0743               puls      b,a
                    endc
                    comb
                    ldb       #E$BPAddr           bad page address
                    rts

                    emod
eom                 equ       *
                    end
