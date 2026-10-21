********************************************************************
* CoHR/Co42 - Hi-Res text console co-modules for VTIO (Level 2)
*
* A text screen drawn on a PMODE 4 (256x192) graphics screen, for the
* CoCo 1/2 with an i-MMU-nity MMU. This one source makes two modules:
*   CoHR: 51x24, a 4x8 font in 5x8 cells (the Level 1 CoHR's,
*         level1/coco1/modules/cohr.asm)
*   Co42: 42x24, a 5x8 font in 6x8 cells (the Level 1 Co42's,
*         level1/coco1/modules/co42.asm), assembled with USECO42=1
* Co42 reads better on an NTSC TV: its cells are an even number of pixels
* wide, so every character gets the same artifact colours, while CoHR's
* change from one column to the next.
*
* CoHR (USECOHR=1) or Co42 (USECO42=1) replaces CoVDG (recipe flag HIRES=51
* or HIRES=42). Both keep the module name CoVDG so that the CoCo 3 VTIO,
* which links its VDG co-module by that name, uses them unchanged. The
* entry table, control codes and VD.xxxx statics are CoVDG's:
*   $01 home, $02 xx yy cursor X,Y, $03 erase line, $04 erase to end of
*   line, $05 xx cursor off ($20)/on, $06 right, $08 left, $09 up,
*   $0A down, $0B erase to end of screen (Co51: home not implemented, see below),
*   $0C clear screen, $0D return, $0E show this screen. The VDG graphics
*   codes ($0F-$1D) are ignored.
*   $1F $20/$21 reverse video on/off, $1F $22/$23 underline on/off (as on
*   CoWin).
* CoHR (51x24) also supports the Dragon Data GO51 sequences, as the Level 1
* driver does (VTIO passes $1B xx on to this module):
*   $1B A xx yy cursor to column xx (0-50), row yy (0-23), raw bytes
*   $1B B erase to end of line, C right, D up, E down
*   $1B F/G reverse on/off, H/I underline on/off, J erase to end of screen
* and GO51's $0B is cursor HOME, where COVDG's $0B erases to the end of
* the screen (the Level 1 driver chose COVDG's). We keep COVDG's $0B;
* in both, $1B J erases to the end of the screen.
* Text is light on black: green, or buff with USEBUFF=1 (recipe flag
* HIRES_BUFF=1). Reverse is dark on light. USEINV=1 (HIRES_INVERSE=1)
* swaps them: black text on green (or buff), as the Level 1 drivers do. On NTSC, 1-pixel strokes in
* PMODE 4 come out in artifact colours, which makes the text hard to read.
* With a CoCoDV, USECODV=1 (recipe flag HIRES_CODV=1) has the first CoHR
* screen set the CoCoDV to monochrome (no artifact colours) with green
* text on a dark green background, as in the manual's NORMAL.BAS.
* The cursor is a block that inverts its cell. It does not flash.
*
* Screen memory: the VDG only displays motherboard RAM, so each screen is
* a block from the VDG pool (motherboard blocks $38-$3D, marked NotRAM by
* krn; a free one is exactly NotRAM, claimed by setting RAMinUse): up to
* 5 screens. The 6K bitmap is at the start of the block, and a copy of
* the text (Cols x Rows ASCII) after it, for SS.Cursr.
*
* The screens are not kept in system address space. Like CoDV (and GrfDrv
* with its windows), CoHR maps the screen it is working on into slot 1 of
* the system map ($2000-$3FFF, which normally holds Bt.Block) on entry and
* puts Bt.Block back on exit. Showing a screen needs no mapping: the SAM is
* pointed at the block's motherboard address.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2004/12/02  P.Harvey-Smith
* Level 1 CoHR, from the Dragon Data 51 column driver.
*   1      2026/10/01
* Level 2 version for the i-MMU-nity port.

                  IFNE    USECO42
                    nam       Co42
                    ttl       Hi-Res 42x24 text console for VTIO
                  ELSE
                    nam       CoHR
                    ttl       Hi-Res 51x24 text console for VTIO
                  ENDC

                  IFP1
                    use       defsfile
                    use       cocovtio.d
                    use       vdgdefs
                  ENDC

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                  IFNE    USECO42
Cols                equ       42
CellW               equ       6         cell width in pixels
CellBits            equ       $FC       a cell's pixels, from bit 7
FontH               equ       8         font bytes per character
                  ELSE
Cols                equ       51
CellW               equ       5
CellBits            equ       $F8
FontH               equ       4
                  ENDC
Rows                equ       24
BmSize              equ       $1800     PMODE 4 bitmap: 24 rows x 8 lines x 32 bytes
                  IFNE    USEINV
BgByte              equ       $FF       eight pixels of background (lit)
NrmAttr             equ       CellBits  Attr for normal video: ink pixels clear
RevAttr             equ       $00       Attr for reverse video: ink pixels set
                  ELSE
BgByte              equ       $00       eight pixels of background (black)
NrmAttr             equ       $00       Attr for normal video: ink pixels set
RevAttr             equ       CellBits  Attr for reverse video: ink pixels clear
                  ENDC
                  IFNE    USEBUFF
VdgMode             equ       $F8       PMODE 4, CSS=1: buff and black
                  ELSE
VdgMode             equ       $F0       PMODE 4, CSS=0: green and black
                  ENDC
ScrBase             equ       $2000     screens are mapped in system slot 1
ShBase              equ       ScrBase+BmSize the text copy, Cols*Rows bytes
ShCopy              equ       (Cols*(Rows-1)+7)&$FFF8 text bytes moved by a scroll (multiple of 8)
ScrSlot             equ       1
MMUSlot             equ       $FFA0+ScrSlot system task (task 0) MMU register
PIA1B               equ       $FF22     VDG mode pins

* CoHR's own statics, in VDG graphics fields it doesn't use
CurX                equ       VD.GCrsX  cursor column (0 to Cols-1)
CurY                equ       VD.GCrsY  cursor row (0-23), after CurX
PixSh               equ       VD.PixBt  pixel position of the cell in its byte (0-7)
CelMsk              equ       VD.Msk1   2 bytes: the cell's pixels (CellBits*256 shifted)
Attr                equ       VD.MCol   XORed onto glyph rows: NrmAttr or RevAttr
UndrLn              equ       VD.MCol2  0 = no underline
CrsOn               equ       VD.FF1    cursor is drawn on the screen

                    mod       eom,name,tylg,atrv,start,size

u0000               rmb       0
size                equ       .

                    fcb       $07

name                fcs       /CoVDG/           VTIO links CoVDG (this is CoHR or Co42)
                    fcb       edition

* Entry table (the same offsets as CoVDG)
start               lbra      Init
                    lbra      Write
                    lbra      GetStat
                    lbra      SetStat
                    lbra      Term
* CoWinSpc special processing entry (called from VTIO)
* Entry: A = 0: select this screen (set the display), 1: update mouse packet
                    tsta
                    bne       Spc1
                    tst       >WGlobal+G.CrDvFl ; are we the displayed device?
                    beq       NoOp
                    lbra      SetVid
Spc1                deca
                    bne       NoOp
                    ldx       <D.CCMem  ; copy actual mouse X,Y to window relative
                    leax      <G.Mouse+Pt.AcX,x
                    ldd       ,x
                    std       Pt.WRX-Pt.AcX,x
                    ldd       Pt.AcY-Pt.AcX,x
                    std       Pt.WRY-Pt.AcX,x
NoOp                clrb
                    rts

**************************************************
* Init: get a screen and clear it
Init                pshs      u,y,x
                    lbsr      GetBlk    ; b = VDG pool block
                    lbcs      InitRts
                    stb       <VD.GBuff,u
                    lbsr      MapScr
                    ldx       #ScrBase
                    stx       <VD.ScrnA,u
                    ldd       #Cols*256+Rows
                    std       <VD.Col,u
                    leax      <VD.NChar,u ; where VTIO puts parameter bytes
                    stx       <VD.EPlt1,u
                    stx       <VD.EPlt2,u
                    lda       #NrmAttr  ; normal video
                    sta       <Attr,u
                    clr       <UndrLn,u
                    clr       <CrsOn,u
                    lda       #1        ; cursor on
                    sta       <VD.CColr,u
                    inc       <VD.Start,u
                  IFNE    USECODV
                    ldx       <D.CCMem
                    lda       <G.BCFFlg,x
                    bita      #$02      ; first CoHR screen?
                    bne       InitClr
                    lbsr      DVSetup   ; set up the CoCoDV colours
InitClr             equ       *
                  ENDC
                    lbsr      ClrScrn
                    lbsr      ShowCrsr
                    clrb
                    lbsr      UnMap
* The first CoHR screen (/term at boot) replaces the boot screen display
                    ldx       <D.CCMem
                    ldb       <G.BCFFlg,x
                    bitb      #$02      ; vdg co-module already set up?
                    beq       InitShow
                    tst       >WGlobal+G.CrDvFl ; are we the displayed device?
                    beq       InitFlg
InitShow            lbsr      SetVid
InitFlg             ldx       <D.CCMem
                    ldb       <G.BCFFlg,x
                    orb       #$02      ; vdg co-module found
                    stb       <G.BCFFlg,x
                    clrb
InitRts             puls      pc,u,y,x

**************************************************
* Term: give the screen back
Term                pshs      u,y,x
                    clr       <VD.Start,u
                    lbsr      FreeBlk   ; give the screen block back to the pool
                    ldb       #$E1      ; clear the VDG statics
                    leax      <VD.Strt1,u
TermLp              clr       ,x+
                    decb
                    bne       TermLp
                    clrb
                    puls      pc,u,y,x

**************************************************
* Write
* Entry: A = char to write, Y = path descriptor, U = device statics
Write               leax      WriteIn,pcr

* Run a screen routine: map the screen in, take the cursor off, call it,
* put the cursor back, map the screen out. CC and B come from the routine.
* Entry: X = routine, A = its parameter
Enter               lbsr      MapScr
                    pshs      y
                    pshs      x,a
                    lbsr      HideCrsr
                    puls      a,x
                    jsr       ,x
                    pshs      cc,b
                    lbsr      ShowCrsr
                    puls      cc,b
                    puls      y
                    lbra      UnMap

WriteIn             cmpa      #$0E
                    bls       Dispatch
                    cmpa      #$1B      ; escape
                    lbeq      Escape
                    cmpa      #$1F      ; attributes
                    lbeq      DoAttr
                    lblo      NoOp      ; graphics codes: ignore
                    cmpa      #$7F
                    lbhs      NoOp
* A printable character: into the text copy and onto the screen
PutChr              pshs      a
                    lbsr      ShAdr
                    puls      a
                    sta       ,x
                    lbsr      DrawChr
                    lda       <CurX,u
                    inca
                    cmpa      #Cols
                    blo       StoX
                    clr       <CurX,u   ; past the end of the line: next line
                    bra       CurDown

Dispatch            leax      <DCodeTbl,pcr
                    lsla
                    ldd       a,x
                    jmp       d,x

DCodeTbl            fdb       NoOp-DCodeTbl $00 no-op
                    fdb       CurHome-DCodeTbl $01 home cursor
                    fdb       CurXY-DCodeTbl $02 cursor X,Y
                    fdb       DelLine-DCodeTbl $03 erase line
                    fdb       ErEOLine-DCodeTbl $04 erase to end of line
                    fdb       CrsrSw-DCodeTbl $05 cursor on/off (byte from VTIO)
                    fdb       CurRght-DCodeTbl $06 cursor right
                    fdb       NoOp-DCodeTbl $07 bell (VTIO)
                    fdb       CurLeft-DCodeTbl $08 cursor left
                    fdb       CurUp-DCodeTbl $09 cursor up
                    fdb       CurDown-DCodeTbl $0A cursor down
* Since few applications use CoHR $0B, support COVDG $0B instead
                    fdb       ErEOScrn-DCodeTbl $0B erase to end of screen (COVDG)
*                   fdb       CurHome-DCodeTbl $0B home cursor (GO51)
                    fdb       ClrScrn-DCodeTbl $0C clear screen
                    fdb       Retrn-DCodeTbl $0D carriage return
                    fdb       Do0E-DCodeTbl $0E show this screen

* $0A - cursor down (scrolls at the bottom)
CurDown             lda       <CurY,u
                    inca
                    cmpa      #Rows
                    lbhs      ScrlUp
StoY                sta       <CurY,u
RtsOk               clrb
                    rts

* $0D - carriage return
Retrn               clr       <CurX,u
                    clrb
                    rts

* $06 - cursor right (to the next line at the end of one)
CurRght             lda       <CurX,u
                    inca
                    cmpa      #Cols
                    blo       StoX
                    lda       <CurY,u
                    inca
                    cmpa      #Rows
                    bhs       RtsOk     ; not past the end of the screen
                    sta       <CurY,u
                    clra
StoX                sta       <CurX,u
                    clrb
                    rts

* $08 - cursor left (to the end of the line above at the start of one)
CurLeft             lda       <CurX,u
                    bne       CurLf1
                    lda       <CurY,u
                    beq       RtsOk     ; not past the start of the screen
                    deca
                    sta       <CurY,u
                    lda       #Cols
CurLf1              deca
                    bra       StoX

* $09 - cursor up
CurUp               lda       <CurY,u
                    beq       RtsOk
                    deca
                    bra       StoY

* $01 - home cursor
CurHome             clra
                    clrb
                    std       <CurX,u   ; curX and CurY
                    rts                 ; (carry clear)

* $0E - show this screen
Do0E                tst       >WGlobal+G.CrDvFl
                    beq       RtsOk
                    lbra      SetVid

* $05 xx - cursor off (xx=$20) or on (anything else; no colours)
CrsrSw              lda       <VD.NChar,u
                    suba      #C$SPAC
                    beq       CrsrSw1
                    lda       #1
CrsrSw1             sta       <VD.CColr,u
                    clrb
                    rts

* $02 xx yy - cursor to column xx-32, row yy-32
CurXY               ldb       #2
                    leax      <DoCurXYM,pcr
                    stb       <VD.NGChr,u
                    stx       <VD.RTAdd,u
                    clrb
                    rts

* Called by VTIO when it has the two bytes, so map the screen here too
DoCurXYM            leax      <DoCurXY,pcr
                    lbra      Enter

DoCurXY             lda       <VD.NChar,u
                    suba      #C$SPAC
                    cmpa      #Cols
                    bhs       RtsOk     ; off the screen: ignored
                    ldb       <VD.NChr2,u
                    subb      #C$SPAC
                    cmpb      #Rows
                    bhs       RtsOk
                    std       <CurX,u
                    clrb
                    rts

* $1B xx: VTIO has collected xx.
*   $31 rr cc : palette, swallow 2 more bytes
*   $41-$4A   : the Level 1 CoHR / GO51 ESC A-J sequences
*   anything else is ignored
Escape              lda       <VD.NChar,u
                    cmpa      #$31
                    beq       EscPal
                    suba      #$41      ; ESC A..J = 0..9
                    lbcs      RtsOk
                    cmpa      #9
                    lbhi      RtsOk
                    leax      EscTbl,pcr
                    lsla
                    ldd       a,x
                    jmp       d,x
EscPal              leax      RtsOk,pcr
                    bra       Get2
* $1B A xx yy: ask VTIO for 2 more bytes
EscGoto             leax      <EscGotoM,pcr
Get2                ldb       #2
                    stb       <VD.NGChr,u
                    stx       <VD.RTAdd,u
                    clrb
                    rts
* Called by VTIO when it has the two bytes, so map the screen here too
EscGotoM            leax      <EscGoXY,pcr
                    lbra      Enter
* xx = column, yy = row, raw bytes, clamped as in the Level 1 DoGotoXY
EscGoXY             lda       <VD.NChar,u
                    cmpa      #Cols
                    blo       EscGo1
                    lda       #Cols-1
EscGo1              ldb       <VD.NChr2,u
                    cmpb      #Rows
                    blo       EscGo2
                    ldb       #Rows-1
EscGo2              std       <CurX,u
                    clrb
                    rts
EscTbl              fdb       EscGoto-EscTbl    A cursor to column, row
                    fdb       ErEOLine-EscTbl   B erase to end of line
                    fdb       CurRght-EscTbl    C cursor right
                    fdb       CurUp-EscTbl      D cursor up
                    fdb       CurDown-EscTbl    E cursor down
                    fdb       RevOn-EscTbl      F reverse on
                    fdb       RevOff-EscTbl     G reverse off
                    fdb       UndOn-EscTbl      H underline on
                    fdb       UndOff-EscTbl     I underline off
                    fdb       ErEOScrn-EscTbl   J erase to end of screen

* $1F xx: $20 reverse on, $21 reverse off, $22 underline on, $23 off
DoAttr              lda       <VD.NChar,u
                    suba      #$20
                    beq       RevOn
                    deca
                    beq       RevOff
                    deca
                    beq       UndOn
                    deca
                    lbne      RtsOk
UndOff              clr       <UndrLn,u ; underline off
                    clrb
                    rts
UndOn               lda       #$FF
                    sta       <UndrLn,u
                    clrb
                    rts
RevOn               lda       #RevAttr
                    bra       SetAttr
RevOff              lda       #NrmAttr
SetAttr             sta       <Attr,u
                    clrb
                    rts

* $03 - erase the line the cursor is on
DelLine             clr       <CurX,u

* $04 - erase from the cursor to the end of the line
ErEOLine            bsr       ShAdr     ; the text copy
                    ldb       #Cols
                    subb      <CurX,u
                    leay      b,x
                    lda       #C$SPAC
                    lbsr      FillB
                    lda       <CurX,u   ; now the bitmap
                    ldb       #CellW
                    mul                 ; d = pixel column (A = 0)
                    pshs      b
                    andb      #7        ; b = pixels of the first byte to keep
                    lda       #$FF
ErShf               tstb
                    beq       ErShfX
                    lsra
                    decb
                    bra       ErShf
ErShfX              puls      b
                    lsrb
                    lsrb
                    lsrb                ; b = first byte in the line
                    pshs      b,a       ; 1,s = first byte, ,s = its pixels to erase
                    lda       <CurY,u
                    addd      #ScrBase
                    tfr       d,x
                    lda       #8        ; 8 pixel lines
                    pshs      a
ErLine              lda       1,s       ; the first byte: keep its other pixels
                    coma
                    anda      ,x
                    ldb       1,s
                    andb      #BgByte
                    pshs      b
                    ora       ,s+
                    sta       ,x
                    leay      1,x
                    ldb       2,s
                    lda       #BgByte
ErByte              incb
                    cmpb      #32
                    bhs       ErLineN
                    sta       ,y+
                    bra       ErByte
ErLineN             leax      32,x
                    dec       ,s
                    bne       ErLine
                    leas      3,s
                    clrb
                    rts

* $0C - clear screen and home the cursor
ClrScrn             lbsr      CurHome
* $0B - erase from the cursor to the end of the screen
ErEOScrn            bsr       ErEOLine
                    lda       <CurY,u
ErEOSLp             inca
                    cmpa      #Rows
                    lbhs      RtsOk
                    pshs      a
                    bsr       ClrRow
                    puls      a
                    bra       ErEOSLp

* Address of the cursor in the text copy
* Exit: X = address
ShAdr               lda       <CurY,u
                    ldb       #Cols
                    mul
                    addb      <CurX,u
                    adca      #0
                    addd      #ShBase
                    tfr       d,x
                    rts

* Scroll the screen up one line (the cursor stays on the last line)
ScrlUp              ldx       #ScrBase+256
                    ldy       #ScrBase
                    ldd       #BmSize-256
                    bsr       Copy8
                    ldx       #ShBase+Cols
                    ldy       #ShBase
                    ldd       #ShCopy
                    bsr       Copy8
                    lda       #Rows-1
* Clear row A, bitmap and text copy
ClrRow              pshs      a
                    clrb
                    addd      #ScrBase
                    tfr       d,x
                    leay      256,x
                    pshs      y
                    ldd       #BgByte*256+BgByte
ClrRowLp            std       ,x++
                    cmpx      ,s
                    blo       ClrRowLp
                    puls      y
                    puls      a
                    ldb       #Cols
                    mul
                    addd      #ShBase
                    tfr       d,x
                    leay      Cols,x
                    lda       #C$SPAC
* Fill bytes from X up to Y with A
FillB               pshs      y
FillBLp             sta       ,x+
                    cmpx      ,s
                    blo       FillBLp
                    puls      y,pc

* Copy D bytes (a multiple of 8) from X up to Y
Copy8               pshs      x
                    addd      ,s
                    std       ,s        ; end of the source
Copy8Lp             ldd       ,x
                    std       ,y
                    ldd       2,x
                    std       2,y
                    ldd       4,x
                    std       4,y
                    ldd       6,x
                    std       6,y
                    leax      8,x
                    leay      8,y
                    cmpx      ,s
                    blo       Copy8Lp
                    puls      x,pc

**************************************************
* Drawing

* Cursor: invert the cursor's cell. CrsOn stops it being done twice.
HideCrsr            tst       <CrsOn,u
                    beq       CrsrX
                    clr       <CrsOn,u
                    bra       XorCell
ShowCrsr            tst       <VD.CColr,u ; cursor switched off?
                    beq       CrsrX
                    tst       <CrsOn,u
                    bne       CrsrX
                    inc       <CrsOn,u
XorCell             bsr       CellAdr
                    ldb       #8
                    pshs      b
XorLp               ldd       <CelMsk,u
                    eora      ,x
                    eorb      1,x
                    std       ,x
                    leax      32,x
                    dec       ,s
                    bne       XorLp
                    puls      b
CrsrX               clrb
                    rts

* Where the cursor's cell is in the bitmap
* Exit: X = its top byte, PixSh = its pixel position in the byte,
*       CelMsk = its pixels in that byte and the next. Y is kept.
CellAdr             lda       <CurX,u
                    ldb       #CellW
                    mul                 ; d = pixel column (A = 0)
                    pshs      b
                    lsrb
                    lsrb
                    lsrb
                    lda       <CurY,u   ; 8 lines of 32 bytes per row
                    addd      #ScrBase
                    tfr       d,x
                    puls      b
                    andb      #7
                    stb       <PixSh,u
                    ldd       #CellBits*256
* Shift D right by PixSh. All registers but D are kept.
ShiftD              pshs      d
                    ldb       <PixSh,u
                    beq       ShiftX
ShiftLp             lsr       ,s
                    ror       1,s
                    decb
                    bne       ShiftLp
ShiftX              puls      d
                    std       <CelMsk,u ; (only kept by CellAdr's call)
                    rts

* Draw character A ($20-$7E) in the cursor's cell
DrawChr             suba      #C$SPAC
                    ldb       #FontH
                    mul
                    leay      CharacterShapes,pcr
                    leay      d,y
                    bsr       CellAdr
                  IFNE    USECO42
                    lda       #8        ; a byte per line
                    pshs      a
DrawLp              lda       ,y+
                    bsr       PutLine
                  ELSE
                    lda       #4        ; a nibble per line
                    pshs      a
DrawLp              lda       ,y        ; even line: high nibble
                    anda      #$F0
                    bsr       PutLine
                    lda       ,y+       ; odd line: low nibble
                    lsla
                    lsla
                    lsla
                    lsla
                    bsr       PutLine
                  ENDC
                    dec       ,s
                    bne       DrawLp
                    puls      a
                    tst       <UndrLn,u
                    beq       DrawX
                    leax      -32,x     ; underline: the cell's last line
                    lda       #CellBits
                    bsr       PutLine
DrawX               rts

* Put one pixel line of the cell on the screen
* Entry: A = the glyph's pixels from bit 7 (set = ink), X = screen byte
* Exit:  X = the same byte one line down
PutLine             eora      <Attr,u   ; to screen pixels
                    clrb
                    pshs      d
                    ldd       <CelMsk,u
                    pshs      d
                    ldb       <PixSh,u  ; shift the pixels like the mask
                    beq       PutLn2
PutLn1              lsr       2,s
                    ror       3,s
                    decb
                    bne       PutLn1
PutLn2              ldd       2,s
                    anda      ,s        ; only the cell's pixels
                    andb      1,s
                    std       2,s
                    puls      d         ; the mask
                    coma
                    comb
                    anda      ,x        ; keep the rest of the screen
                    andb      1,x
                    ora       ,s+
                    orb       ,s+
                    std       ,x
                    leax      32,x
                    rts

**************************************************
* GetStat
GetStat             ldx       PD.RGS,y
                    cmpa      #SS.ScSiz
                    beq       Rt.ScSiz
                    cmpa      #SS.Cursr
                    beq       Rt.Cursr
                    comb
                    ldb       #E$UnkSvc
                    rts

* Exit: X = columns, Y = rows
Rt.ScSiz            ldd       #Cols
                    std       R$X,x
                    ldd       #Rows
                    std       R$Y,x
                    clrb
                    rts

* Exit: X = column+$20, Y = row+$20, A = the character under the cursor
Rt.Cursr            clra
                    ldb       <CurX,u
                    addb      #C$SPAC
                    std       R$X,x
                    ldb       <CurY,u
                    addb      #C$SPAC
                    std       R$Y,x
                    pshs      x
                    bsr       MapScr
                    lbsr      ShAdr
                    lda       ,x
                    puls      x
                    sta       R$A,x
                    clrb
                    bra       UnMap

**************************************************
* SetStat: SS.ComSt (true lower case) is accepted and ignored
SetStat             cmpa      #SS.ComSt
                    lbeq      NoOp
                    comb
                    ldb       #E$UnkSvc
                    rts

**************************************************
* Screen memory (as CoDV)

* Get a VDG pool block (skips Bt.Block, which holds the boot/text screens,
* and $3E, where DAT.Free maps unused slots)
* Exit: B = block number, or carry set and B = error
GetBlk              ldx       <D.BlkMap
                    ldb       #$38
GetBlkLp            cmpb      #Bt.Block
                    beq       GetBlkNx
                    lda       b,x
                    cmpa      #NotRAM
                    beq       GetBlkOk
GetBlkNx            incb
                    cmpb      #$3E
                    blo       GetBlkLp
                    comb
                    ldb       #E$NoRAM
                    rts
GetBlkOk            lda       #NotRAM+RAMinUse
                    sta       b,x
                    clra                ; d = block number, carry clear
                    rts

* Return the pool block
FreeBlk             clra
                    ldb       <VD.GBuff,u
                    beq       FreeBlkX
                    tfr       d,x
                    ldb       #1
                    os9       F$DelRAM
                    clr       <VD.GBuff,u
FreeBlkX            rts

* Put this screen's block in system slot 1 ($2000-$3FFF): the DAT image
* entry and the task 0 MMU register. All registers are kept.
MapScr              pshs      x,b
                    ldb       <VD.GBuff,u
                    ldx       <D.SysDAT
                    stb       ScrSlot*2+1,x
                    stb       >MMUSlot
                    puls      x,b,pc

* Put Bt.Block back in slot 1. CC and B (the error status) are kept.
UnMap               pshs      x,b,cc
                    ldb       #Bt.Block
                    ldx       <D.SysDAT
                    stb       ScrSlot*2+1,x
                    stb       >MMUSlot
                    puls      cc,b,x,pc

**************************************************
* Display hardware

* Show this screen: SAM mode 6R (V=110) at the block's motherboard
* address, VDG PMODE 4 (G/A=1 GM=111, CSS from VdgMode)
SetVid              lda       >PIA1B
                    anda      #%00000111
                    ora       #VdgMode
                    sta       >PIA1B
                    sta       >$FFC0    ; v0 = 0
                    sta       >$FFC3    ; v1 = 1
                    sta       >$FFC5    ; v2 = 1
                    lda       <VD.GBuff,u ; motherboard block: address/$200 = (blk&7)*16
                    anda      #$07
                    lsla
                    lsla
                    lsla
                    lsla
                    ldx       #$FFC6    ; f0
                    ldb       #7
SetVidLp            lsra
                    bcc       SetVidCl
                    sta       1,x       ; odd address sets the bit
                    bra       SetVidNx
SetVidCl            sta       ,x        ; even address clears it
SetVidNx            leax      2,x
                    decb
                    bne       SetVidLp
                    clrb
                    rts

                  IFNE    USECODV
**************************************************
* CoCoDV setup, done once by the first CoHR screen. The registers are put
* at the start of the displayed screen and the unlock code is sent on the
* VDG mode pins ($FF22), the way the manual's BASIC examples do it (as in
* CoDV, the CoCoDV console on the cocodv branch).
DVSetup             pshs      cc
                    orcc      #IntMasks
                    lbsr      SetVid
                    leax      DVRegs,pcr
                    ldy       <VD.ScrnA,u
                    ldb       #DVRegsL
DVCopy              lda       ,x+
                    sta       ,y+
                    decb
                    bne       DVCopy
                    lda       #$08      ; css = 1: configuration registers
                    bsr       Config
                    lbsr      SetVid    ; back to PMODE 4
                    puls      cc,pc

* One CoCoDV register transfer from the start of the screen
* Entry: A = $08 (configuration registers)
Config              pshs      a
                    ora       #$F0      ; pmode 4, CSS as for the unlock
                    sta       >PIA1B
                    bsr       Delay
                    lda       ,s
                    bsr       Unlock
                    bsr       Delay     ; let it read the screen
                    ldx       <VD.ScrnA,u
                    clr       ,x        ; reg00 = 0 locks the registers
                    bsr       Delay
                    clr       >PIA1B
                    bsr       Delay
                    puls      a,pc

* About four frames (7500 x 8 cycles at 0.89MHz), not tied to the PIA
Delay               ldx       #7500
DelayLp             leax      -1,x
                    bne       DelayLp
                    rts

* Unlock sequence on the VDG mode pins: $90 $D0 $C0 $E0 $F0, plus A
* Each value is held about 1.3ms, like BASIC's POKEs
Unlock              ora       #$90
                    bsr       UnlkPut
                    eora      #%01000000
                    bsr       UnlkPut
                    eora      #%00010000
                    bsr       UnlkPut
                    eora      #%00100000
                    bsr       UnlkPut
                    eora      #%00010000
UnlkPut             sta       >PIA1B
                    ldx       #150      ; 150 x 8 cycles
UnlkDly             leax      -1,x
                    bne       UnlkDly
                    rts

* Registers 1-13 for PMODE 4 in two greens (NORMAL.BAS's colours)
DVRegs              fcb       $03       REG00: update registers 1-15
                    fcb       $20       REG01: monochrome (no artifact colours)
                    fcb       $01       REG02
                    fcb       $00       REG03: no tile mode
                    fcb       $00,$00,$00 REG04-06
                    fcb       $07       REG07: override border, background, foreground
                    fdb       $0000     REG08-09: border black
                    fdb       $01E0     REG10-11: background dark green
                    fdb       $07E0     REG12-13: foreground green
                    fdb       $0000     REG14-15
DVRegsL             equ       *-DVRegs
                  ENDC

                  IFNE    USECO42
                    use       co42font.asm
                  ELSE
CharacterShapes
* 4x8 bitmap table for characters $20-$7f
* each nibble represents a row of 4 dots
* chars 20-27
                    fcb       $00,$00,$00,$00 ....  .@..  .@.@  .@@.  ..@.  @..@  .@..  .@..
                    fcb       $44,$40,$40,$00 ....  .@..  .@.@  @@@@  .@@@  ...@  @.@.  .@..
                    fcb       $55,$00,$00,$00 ....  .@..  ....  .@@.  @...  ..@.  .@..  ....
                    fcb       $6F,$6F,$60,$00 ....  ....  ....  @@@@  .@@.  .@..  @.@.  ....
                    fcb       $27,$86,$1E,$20 ....  .@..  ....  .@@.  ...@  @...  @@.@  ....
                    fcb       $91,$24,$89,$00 ....  ....  ....  ....  @@@.  @..@  ....  ....
                    fcb       $4A,$4A,$D0,$00 ....  ....  ....  ....  ..@.  ....  ....  ....
                    fcb       $44,$00,$00,$00 ....  ....  ....  ....  ....  ....  ....  ....
* chars 29-2f
                    fcb       $24,$44,$20,$00 ..@.  .@..  @..@  .@..  ....  ....  ....  ....
                    fcb       $42,$22,$40,$00 .@..  ..@.  .@@.  .@..  ....  ....  ....  ...@
                    fcb       $96,$F6,$90,$00 .@..  ..@.  @@@@  @@@.  ....  @@@@  ....  ..@.
                    fcb       $44,$E4,$40,$00 .@..  ..@.  .@@.  .@..  ..@.  ....  .@@.  .@..
                    fcb       $00,$02,$24,$00 ..@.  .@..  @..@  .@..  ..@.  ....  .@@.  @...
                    fcb       $00,$F0,$00,$00 ....  ....  ....  ....  .@..  ....  ....  ....
                    fcb       $00,$06,$60,$00 ....  ....  ....  ....  ....  ....  ....  ....
                    fcb       $01,$24,$80,$00 ....  ....  ....  ....  ....  ....  ....  ....
* chars 30-37
                    fcb       $69,$BD,$60,$00 .@@.  ..@.  .@@.  @@@.  ..@.  @@@@  .@@@  @@@@
                    fcb       $26,$22,$70,$00 @..@  .@@.  @..@  ...@  .@@.  @...  @...  ...@
                    fcb       $69,$2C,$F0,$00 @.@@  ..@.  ..@.  .@@.  @.@.  @@@.  @@@.  ..@.
                    fcb       $E1,$61,$E0,$00 @@.@  ..@.  @@..  ...@  @@@@  ...@  @..@  .@..
                    fcb       $26,$AF,$20,$00 .@@.  .@@@  @@@@  @@@.  ..@.  @@@.  .@@.  .@..
                    fcb       $F8,$E1,$E0,$00 ....  ....  ....  ....  ....  ....  ....  ....
                    fcb       $78,$E9,$60,$00 ....  ....  ....  ....  ....  ....  ....  ....
                    fcb       $F1,$24,$40,$00 ....  ....  ....  ....  ....  ....  ....  ....
* chars 38-3f
                    fcb       $69,$69,$60,$00 .@@.  .@@.  ....  ....  ..@.  ....  .@..  .@@.
                    fcb       $69,$71,$60,$00 @..@  @..@  ....  ....  .@..  @@@@  ..@.  @..@
                    fcb       $00,$40,$40,$00 .@@.  .@@@  .@..  ..@.  @...  ....  ...@  ..@.
                    fcb       $00,$20,$24,$00 @..@  ...@  ....  ....  .@..  @@@@  ..@.  ..@.
                    fcb       $24,$84,$20,$00 .@@.  .@@.  .@..  ..@.  ..@.  ....  .@..  ....
                    fcb       $0F,$0F,$00,$00 ....  ....  ....  .@..  ....  ....  ....  ..@.
                    fcb       $42,$12,$40,$00 ....  ....  ....  ....  ....  ....  ....  ....
                    fcb       $69,$22,$02,$00 ....  ....  ....  ....  ....  ....  ....  ....
* chars 40-47
                    fcb       $69,$BB,$87,$00 .@@.  .@@.  @@@.  .@@@  @@@.  @@@@  @@@@  .@@@
                    fcb       $69,$F9,$90,$00 @..@  @..@  @..@  @...  @..@  @...  @...  @...
                    fcb       $E9,$E9,$E0,$00 @.@@  @@@@  @@@.  @...  @..@  @@@.  @@@.  @.@@
                    fcb       $78,$88,$70,$00 @.@@  @..@  @..@  @...  @..@  @...  @...  @..@
                    fcb       $E9,$99,$E0,$00 @...  @..@  @@@.  .@@@  @@@.  @@@@  @...  .@@@
                    fcb       $F8,$E8,$F0,$00 .@@@  ....  ....  ....  ....  ....  ....  ....
                    fcb       $F8,$E8,$80,$00 ....  ....  ....  ....  ....  ....  ....  ....
                    fcb       $78,$B9,$70,$00 ....  ....  ....  ....  ....  ....  ....  ....
* chars 48-4f
                    fcb       $99,$F9,$90,$00 @..@  @@@.  @@@@  @..@  @...  @@@@  @..@  .@@.
                    fcb       $E4,$44,$E0,$00 @..@  .@..  ..@.  @.@.  @...  @@.@  @@.@  @..@
                    fcb       $F2,$2A,$40,$00 @@@@  .@..  ..@.  @@..  @...  @@.@  @.@@  @..@
                    fcb       $9A,$CA,$90,$00 @..@  .@..  @.@.  @.@.  @...  @..@  @..@  @..@
                    fcb       $88,$88,$F0,$00 @..@  @@@.  .@..  @..@  @@@@  @..@  @..@  .@@.
                    fcb       $FD,$D9,$90,$00 ....  ....  ....  ....  ....  ....  ....  ....
                    fcb       $9D,$B9,$90,$00 ....  ....  ....  ....  ....  ....  ....  ....
                    fcb       $69,$99,$60,$00 ....  ....  ....  ....  ....  ....  ....  ....
* chars 50-57
                    fcb       $E9,$E8,$80,$00 @@@.  .@@.  @@@.  .@@@  @@@.  @..@  @..@  @..@
                    fcb       $69,$9B,$70,$00 @..@  @..@  @..@  @...  .@..  @..@  @..@  @..@
                    fcb       $E9,$EA,$90,$00 @@@.  @..@  @@@.  .@@.  .@..  @..@  @..@  @@.@
                    fcb       $78,$61,$E0,$00 @...  @.@@  @.@.  ...@  .@..  @..@  .@@.  @@.@
                    fcb       $E4,$44,$40,$00 @...  .@@@  @..@  @@@.  .@..  .@@.  .@@.  @@@@
                    fcb       $99,$99,$60,$00 ....  ....  ....  ....  ....  ....  ....  ....
                    fcb       $99,$96,$60,$00 ....  ....  ....  ....  ....  ....  ....  ....
                    fcb       $99,$DD,$F0,$00 ....  ....  ....  ....  ....  ....  ....  ....
* chars 58-5f
                    fcb       $99,$69,$90,$00 @..@  @..@  @@@@  @@@.  ....  .@@@  .@@.  ....
                    fcb       $99,$71,$E0,$00 @..@  @..@  ...@  @...  @...  ...@  @..@  ....
                    fcb       $F1,$68,$F0,$00 .@@.  .@@@  .@@.  @...  .@..  ...@  ....  ....
                    fcb       $E8,$88,$E0,$00 @..@  ...@  @...  @...  ..@.  ...@  ....  ....
                    fcb       $08,$42,$10,$00 @..@  @@@.  @@@@  @@@.  ...@  .@@@  ....  ....
                    fcb       $71,$11,$70,$00 ....  ....  ....  ....  ....  ....  ....  @@@@
                    fcb       $69,$00,$00,$00 ....  ....  ....  ....  ....  ....  ....  ....
                    fcb       $00,$00,$0F,$00 ....  ....  ....  ....  ....  ....  ....  ....
* chars 60-67
                    fcb       $22,$00,$00,$00 ..@.  ....  @...  ....  ...@  ....  ..@@  ....
                    fcb       $07,$99,$70,$00 ..@.  .@@@  @@@.  .@@@  .@@@  .@@@  .@..  .@@.
                    fcb       $8E,$99,$E0,$00 ....  @..@  @..@  @...  @..@  @.@.  @@@@  @..@
                    fcb       $07,$88,$70,$00 ....  @..@  @..@  @...  @..@  @@..  .@..  @..@
                    fcb       $17,$99,$70,$00 ....  .@@@  @@@.  .@@@  .@@@  .@@@  .@..  .@@@
                    fcb       $07,$AC,$70,$00 ....  ....  ....  ....  ....  ....  ....  ...@
                    fcb       $34,$F4,$40,$00 ....  ....  ....  ....  ....  ....  ....  @@@.
                    fcb       $06,$99,$71,$E0 ....  ....  ....  ....  ....  ....  ....  ....
* chars 68-6f
                    fcb       $8E,$99,$90,$00 @...  .@..  ..@.  @...  .@..  ....  ....  ....
                    fcb       $40,$44,$40,$00 @@@.  ....  ....  @.@.  .@..  .@@@  .@@@  .@@.
                    fcb       $20,$22,$22,$C0 @..@  .@..  ..@.  @@..  .@..  @@.@  @..@  @..@
                    fcb       $8A,$CA,$90,$00 @..@  .@..  ..@.  @.@.  .@..  @@.@  @..@  @..@
                    fcb       $44,$44,$40,$00 @..@  .@..  ..@.  @..@  .@..  @..@  @..@  .@@.
                    fcb       $0E,$DD,$90,$00 ....  ....  ..@.  ....  ....  ....  ....  ....
                    fcb       $0E,$99,$90,$00 ....  ....  @@..  ....  ....  ....  ....  ....
                    fcb       $06,$99,$60,$00 ....  ....  ....  ....  ....  ....  ....  ....
* chars 70-77
                    fcb       $0E,$99,$E8,$80 ....  ....  ....  ....  .@..  ....  ....  ....
                    fcb       $07,$99,$71,$10 @@@.  .@@@  .@@@  .@@@  @@@@  @..@  @..@  @..@
                    fcb       $07,$88,$80,$00 @..@  @..@  @...  @@..  .@..  @..@  @..@  @@.@
                    fcb       $07,$C3,$E0,$00 @..@  @..@  @...  ..@@  .@..  @..@  .@@.  @@.@
                    fcb       $4F,$44,$30,$00 @@@.  .@@@  @...  @@@.  ..@@  .@@@  .@@.  .@@.
                    fcb       $09,$99,$70,$00 @...  ...@  ....  ....  ....  ....  ....  ....
                    fcb       $09,$96,$60,$00 @...  ...@  ....  ....  ....  ....  ....  ....
                    fcb       $09,$DD,$60,$00 ....  ....  ....  ....  ....  ....  ....  ....
* chars 78-7f
                    fcb       $09,$66,$90,$00 ....  ....  ....  ..@@  .@..  @@..  ....  @@@@
                    fcb       $09,$99,$71,$E0 @..@  @..@  @@@@  .@..  .@..  ..@.  .@.@  @@@@
                    fcb       $0F,$24,$F0,$00 .@@.  @..@  ..@.  @@..  ....  ..@@  @.@.  @@@@
                    fcb       $34,$C4,$30,$00 .@@.  @..@  .@..  .@..  .@..  ..@.  ....  @@@@
                    fcb       $44,$04,$40,$00 @..@  .@@@  @@@@  ..@@  .@..  @@..  ....  @@@@
                    fcb       $C2,$32,$C0,$00 ....  ...@  ....  ....  ....  ....  ....  @@@@
                    fcb       $05,$A0,$00,$00 ....  @@@.  ....  ....  ....  ....  ....  @@@@
                    fcb       $FF,$FF,$FF,$F0 ....  ....  ....  ....  ....  ....  ....  ....
                  ENDC

                    emod
eom                 equ       *
                    end
