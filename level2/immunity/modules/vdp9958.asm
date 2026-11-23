********************************************************************
* vdp9958.asm  v3 - V9958 text layer for the SuperSprite-FM+
*
* Register tables, palette, font layout and the optional MPI slot
* handling come from T1INSTE2.ASM (40 columns) and T2INSTE2.ASM
* (80 columns).
*
* DRAFT: lwasm syntax, NOT assembled, NOT tested.
*
* Included by ssfm.asm, which defines (as offsets from U, aliases of
* unused VDG statics) V9.Cols V9.CurX V9.CurY V9.CurSv V9.CurOn
* V9.VNest V9.SvCC V9.SvSlot V9.Base V9.Page V9.Attr V9.Alt V9.AltUsed V9.R12, and the options
* MPI and SLOTSW.
*
* VRAM layout (as in the V9938 programmer's guide, Text 2 example): each
* screen has a $2000 page, number n at n*$2000: name table at +$0000,
* blink table at +$0A00 (80 columns). The font is shared and lives in
* page 0 ($0800 for 40 columns, $1000 for 80). Screen n is displayed by
* pointing R#2, R#3 and R#10 at its page (VdpSelPage).
*
*   MPI=1    board jumpered to $FF58-$FF5E (MPI / MultiPack)
*   MPI=0    board jumpered to $FF78-$FF7E (Y-cable module)
*   SLOTSW=1 also select the SuperSprite's MPI slot ($FF7F) around VDP
*            accesses, as your T1/T2 drivers do. Off by default: the
*            ranges above are not slot dependent.
*
* Low-level routines (VdpPutAt, VdpGetAt, VdpFill, ...) must be called
* between VdpOpen and VdpClose. VdpDo and VdpPutChar do that themselves.
********************************************************************

                  IFNE    MPI
VDPDAT              equ       $FF58     port 0: VRAM data
VDPCMD              equ       $FF59     port 1: status, registers, VRAM address
VDPPAL              equ       $FF5A     port 2: palette
VIDMUX              equ       $FF5E     0 = V9958, 1 = MC6847
                  ELSE
VDPDAT              equ       $FF78
VDPCMD              equ       $FF79
VDPPAL              equ       $FF7A
VIDMUX              equ       $FF7E
                  ENDC
MPICFG              equ       $FF7F     MPI slot select register
* V9SLOT: value written to MPICFG to select the SuperSprite's slot
* (slot 1 = 0, slot 2 = $11, slot 3 = $22, slot 4 = $33). Only used with
* SLOTSW=1.
                    IFNDEF    V9SLOT
V9SLOT              equ       0
                  ENDC

V9ROWS              equ       24        your T2 driver uses 26 (with V9R9 = $80)
V9R9                equ       $00       R#9: $00 = 192 lines (24 rows), $80 = 212 lines
V9CUR               equ       63+32     software cursor glyph (the underscore)
V9BLNK              equ       260       Text 2 blink table size in bytes
V9CWCLR             equ       1         1: CWArea clears the whole window (1B 28 0 / 1
*                           changes it per screen); 0: it leaves the text
V9HDR               equ       13        size of an overlay record in the upper VRAM
V9CHNK              equ       10        copy chunk (stack buffer): rows of both the name
*                           table (40/80 bytes) and the blink table (10 bytes)
*                           are multiples of it
V9ALT               equ       $C1       default R#12: palette 12 on palette 1 (the alternate
*                           colours of flagged characters, 80 columns)
V9COL               equ       $51       default R#7: palette 5 (yellow) on palette 1 (blue)
V9STRD              equ       1         1: read the status register (S#0) when the VDP is
*                           closed, to clear a pending interrupt flag
V9FG0               equ       1         1: colour 0 as a foreground (R#7 high nibble, R#12
*                           high nibble) is drawn with palette entry 8, and
*                           $1B $31 0 also sets entry 8. On the V9938/V9958
*                           text modes colour code 0 is transparent whatever
*                           the TP bit says (no R#8 value changed it on a
*                           SuperSprite-FM+). Colour 0 as a background (R#7
*                           or R#12 low nibble) obeys the palette, so it is
*                           not redirected.
V9R8                equ       $28       R#8: VR + TP (sprites enabled). TP has no effect in
*                           the text modes; it only matters for graphics modes
*                           and sprites if another program takes over the VDP.

********************************************************************
* VdpOpen / VdpClose - bracket every VDP access.
*   Masks IRQ and FIRQ (the VDP address and register writes are two-byte
*   sequences nothing may interrupt) and, with SLOTSW=1, selects the
*   SuperSprite's slot and restores the old one at the end. Calls nest;
*   only the outermost pair does the work. Registers and condition codes
*   are preserved (except the interrupt masks while open).
********************************************************************
VdpOpen
                    pshs      a,cc
                    orcc      #$50
                    tst       V9.VNest,u
                    lbne      VdpO1
                    lda       ,s        ; flags at entry
                    anda      #$50
                    sta       V9.SvCC,u ; remember the interrupt masks
                  IFNE    SLOTSW
                    lda       MPICFG
                    sta       V9.SvSlot,u
                    lda       #V9SLOT
                    sta       MPICFG    ; select the SuperSprite's slot
                  ENDC
VdpO1               inc       V9.VNest,u
                    lda       ,s
                    ora       #$50
                    sta       ,s        ; keep the masks set after the PULS
                    puls      cc,a,pc

VdpClose
                    pshs      a,cc
                    dec       V9.VNest,u
                    lbne      VdpC1
                  IFNE    V9STRD
                    lda       VDPCMD    ; clears the frame / line interrupt flag
                  ENDC
                  IFNE    SLOTSW
                    lda       V9.SvSlot,u
                    sta       MPICFG
                  ENDC
                    lda       ,s
                    anda      #$AF      ; clear the interrupt masks...
                    ora       V9.SvCC,u ; ...then put back what they were
                    sta       ,s
VdpC1               puls      cc,a,pc

********************************************************************
* VdpMux - route the monitor. A = 0: V9958, A = 1: MC6847.
*   Self-contained (stack only, no statics): CoVDG's DispAlfa calls it
*   too. Preserves B and X.
********************************************************************
VdpMux
                    pshs      cc,b
                    orcc      #$50
                  IFNE    SLOTSW
                    ldb       MPICFG
                    pshs      b
                    ldb       #V9SLOT
                    stb       MPICFG
                  ENDC
                    sta       VIDMUX
                  IFNE    SLOTSW
                    puls      b
                    stb       MPICFG
                  ENDC
                    puls      cc,b,pc

VdpShow             clra
                    lbra      VdpMux
VdpHide             lda       #1
                    lbra      VdpMux

********************************************************************
* Low-level VDP access (between VdpOpen and VdpClose)
********************************************************************
* VdpReg: A = value, B = register number
VdpReg              sta       VDPCMD
                    orb       #$80
                    stb       VDPCMD
                    rts

* X = VRAM address ($0000-$FFFF, A16 = 0). Sets R#14 (A16-A14) first
* because the screens' pages are spread over 64K. Clobbers A,B.
VdpSetWr
                    tfr       x,d       ; a = high byte, B = low byte
                    pshs      d
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra                ; a = A15-A14
                    ora       V9.Hi,u   ; + A16 (4) when working in the upper 64K
                    sta       VDPCMD
                    lda       #$8E
                    sta       VDPCMD    ; r#14
                    puls      d
                    stb       VDPCMD
                    anda      #$3F
                    ora       #$40
                    sta       VDPCMD
                    rts

VdpSetRd
                    tfr       x,d
                    pshs      d
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra
                    ora       V9.Hi,u
                    sta       VDPCMD
                    lda       #$8E
                    sta       VDPCMD
                    puls      d
                    stb       VDPCMD
                    anda      #$3F
                    sta       VDPCMD
                    rts

* VdpPutAt: A = screen code, X = VRAM offset
VdpPutAt
                    pshs      a
                    lbsr      VdpSetWr
                    puls      a
                    sta       VDPDAT
                    rts

* VdpGetAt: X = VRAM offset, returns A = screen code
VdpGetAt
                    lbsr      VdpSetRd
                    lda       VDPDAT
                    rts

* VdpFill: X = VRAM offset, Y = count, A = value
VdpFill
                    pshs      a
                    lbsr      VdpSetWr
                    puls      a
VdpF1               sta       VDPDAT
                    leay      -1,y
                    bne       VdpF1
                    rts

* VdpStream: send B bytes from X to port 1 (value,register|$80 pairs)
VdpStream
VdpS1               lda       ,x+
                    sta       VDPCMD
                    decb
                    bne       VdpS1
                    rts

* VdpPalette: R#16 = 0, then the 16 colours (RB,0G byte pairs)
VdpPalette
                    clra
                    sta       VDPCMD
                    lda       #$90
                    sta       VDPCMD
                    leax      VdpDefPal,pcr
                    ldb       #32
VdpP1               lda       ,x+
                    sta       VDPPAL
                    decb
                    bne       VdpP1
                    rts

* VdpSetPal: A = palette register (0-15), B = CoCo 3 colour (0-63, bits:
* 0 blue low, 1 green low, 2 red low, 3 blue high, 4 green high, 5 red
* high), converted to the V9958's 3 bits per channel with VdpCol.
VdpSetPal
                    pshs      d
                    anda      #$0F
                    sta       VDPCMD
                    lda       #$90
                    sta       VDPCMD    ; r#16 = palette register
                    ldb       1,s
                    andb      #$3F
                    aslb
                    leax      VdpCol,pcr
                    abx                 ; x = VdpCol + 2*colour
                    lda       ,x+
                    sta       VDPPAL    ; rb
                    lda       ,x
                    sta       VDPPAL    ; 0G
                    puls      d,pc

* VdpLoadFont: X = VRAM address of the pattern table. The normal glyphs
* (screen codes 0-95) go first; then an inverted copy at screen codes
* 128-223 (pattern table + $0400), used for reverse video: a character is
* shown in reverse by setting bit 7 of its screen code.
VdpLoadFont
                    pshs      x
                    lbsr      VdpSetWr
                    leax      VdpFont,pcr
                    ldy       #V9FLEN
VdpL1               lda       ,x+
                    sta       VDPDAT
                    leay      -1,y
                    bne       VdpL1
                    puls      x
                    leax      $0400,x   ; glyph 128
                    lbsr      VdpSetWr
                    leax      VdpFont,pcr
                    ldy       #V9FLEN
VdpL2               lda       ,x+
                    coma
                    sta       VDPDAT
                    leay      -1,y
                    bne       VdpL2
                    rts

* VdpAscii: A = ASCII, returns A = screen code (ASCII - $20, else space)
VdpAscii
                    cmpa      #$20
                    blo       VdpA0
                    cmpa      #$7F
                    bhi       VdpA0
                    suba      #$20
                    rts
VdpA0               clra
                    rts

* VdpPos: X = VRAM address of the cursor: page base + (area row + cursor
* row) * cols + area column + cursor column. Clobbers A,B.
VdpPos
                    lda       V9.CurY,u
                    lbsr      VdpRowAddr
                    ldb       V9.CurX,u
                    abx
                    rts

VdpCurHide
                    lbsr      VdpPos
                    lda       V9.CurSv,u
                    lbra      VdpPutAt

VdpCurShow
                    lbsr      VdpPos
                    lbsr      VdpGetAt
                    sta       V9.CurSv,u
                    tst       V9.CurOn,u ; cursor switched off?
                    beq       VdpCS9
                    lda       #V9CUR
                    lbra      VdpPutAt
VdpCS9              rts

********************************************************************
* VdpInitMode - program the VDP for Text 1 (V9.Cols = 40) or Text 2 (80)
* with page 0, load the palette and the font. Done once, for the first
* screen opened (/Term, page 0).
********************************************************************
VdpInitMode
                    lbsr      VdpOpen
                  IFNE    V9STRD
                    lda       VDPCMD    ; also resets the port's address latch
                  ENDC
                    lda       V9.Cols,u
                    cmpa      #80
                    beq       VdpIm80
                    leax      VdpT1Tab,pcr
                    ldb       #V9T1LEN
                    lbsr      VdpStream
                    ldx       #$0800    ; text 1 pattern table
                    lbra      VdpIm9
VdpIm80             leax      VdpT2Tab,pcr
                    ldb       #V9T2LEN
                    lbsr      VdpStream
                    ldx       #$1000    ; text 2 pattern table
VdpIm9              pshs      x         ; vdpPalette uses X, keep the table address
                    lbsr      VdpPalette
                    puls      x
                    lbsr      VdpLoadFont
                    lbra      VdpClose

********************************************************************
* VdpInitPage - prepare this screen's own page: clear the blink table
* (80 columns; random bits would make characters blink), clear the name
* table, home the cursor and draw it. Done for every screen.
********************************************************************
VdpInitPage
                    lbsr      VdpOpen
                    lda       V9.Cols,u
                    cmpa      #80
                    bne       VdpIp1
                    ldd       V9.Base,u
                    addd      #$0A00    ; blink table of this page
                    tfr       d,x
                    ldy       #V9BLNK
                    clra
                    lbsr      VdpFill
VdpIp1              lbsr      OpCls
                    lbsr      VdpCurShow
                    lbra      VdpClose

********************************************************************
* VdpSelPage - point R#2 (and in 80 columns R#3, R#10) at this screen's
* page, and R#7 at its colours. Call between VdpOpen and VdpClose.
* n = V9.Page:
*   Text 1: R#2 = 8n
*   Text 2: R#2 = 8n+3, R#3 = ((16*(n&1)+5)<<3)|7, R#10 = (n>>1)&7
*   R#7 = V9.R7
********************************************************************
VdpSelPage
                    lda       V9.Cols,u
                    cmpa      #80
                    beq       VdpSp80
                    lda       V9.Page,u
                    asla
                    asla
                    asla                ; 8n
                    ldb       #2
                    lbsr      VdpReg
                    lbra      VdpSpEnd
VdpSp80             lda       V9.Page,u
                    asla
                    asla
                    asla
                    ora       #3
                    ldb       #2
                    lbsr      VdpReg
                    lda       V9.Page,u
                    anda      #1
                    asla
                    asla
                    asla
                    asla                ; 16*(n&1)
                    adda      #5
                    asla
                    asla
                    asla
                    ora       #7
                    ldb       #3
                    lbsr      VdpReg
                    lda       V9.Page,u
                    lsra
                    anda      #7
                    ldb       #10
                    lbsr      VdpReg
VdpSpEnd
                    lda       V9.R12,u  ; this screen's alternate colours
                    ldb       #12
                    lbsr      VdpReg
                    lda       V9.R7,u   ; this screen's text/background colours
                    ldb       #7
                    lbra      VdpReg

* Text 1: 40x24. Name table $0000, pattern table $0800.
* Pairs of (value, register|$80), as in tm1Data of T1INSTE2.ASM.
VdpT1Tab            fcb       $00,$80   R#0
                    fcb       $50,$81   R#1  display on, M1
                    fcb       $00,$82   R#2  name table $0000
                    fcb       $2F,$83   R#3
                    fcb       $00,$8A   R#10
                    fcb       $01,$84   R#4  pattern table $0800
                    fcb       V9R8,$88  R#8  VR + TP (see V9R8)
                    fcb       V9COL,$87 R#7  text / background colours
                    fcb       V9R9,$89  R#9
                    fcb       V9ALT,$8C R#12 alternate colours
                    fcb       $F0,$8D   R#13 blink rate
                    fcb       $04,$92   R#18 centre the image
                    fcb       $00,$99   R#25
                    fcb       $00,$8E   R#14 VRAM A16-A14 = 0
                    fcb       $00,$40   VRAM write address $0000
V9T1LEN             equ       *-VdpT1Tab

* Text 2: 80x24. Name table $0000, blink table $0A00, pattern $1000.
VdpT2Tab            fcb       $04,$80   R#0  M4
                    fcb       $50,$81   R#1
                    fcb       $03,$82   R#2
                    fcb       $2F,$83   R#3  blink table at $0A00
                    fcb       $00,$8A   R#10
                    fcb       $02,$84   R#4  pattern table $1000
                    fcb       V9R8,$88  R#8
                    fcb       V9COL,$87 R#7
                    fcb       V9R9,$89  R#9
                    fcb       V9ALT,$8C R#12
                    fcb       $F0,$8D   R#13
                    fcb       $04,$92   R#18
                    fcb       $00,$99   R#25
                    fcb       $00,$8E   R#14
                    fcb       $00,$40
V9T2LEN             equ       *-VdpT2Tab

* Default palette (power-up and DefColr, $1B $30), RB,0G byte pairs. The
* order is the NitrOS-9 manual's: 0 white, 1 blue, 2 black, 3 green, 4 red,
* 5 yellow, 6 magenta, 7 cyan. The colour values come from your AGD palette
* (the MSX2 one); entries 9-15 are only my first guess at brighter versions
* of 1-7, change them freely.
VdpDefPal
                    fcb       $77,$07   0 white   (7,7,7)
                    fcb       $07,$00   1 blue    (0,0,7)  AGD 4
                    fcb       $00,$00   2 black
                    fcb       $22,$07   3 green   (2,7,2)  AGD 3
                    fcb       $70,$00   4 red     (7,0,0)  AGD 8
                    fcb       $62,$06   5 yellow  (6,6,2)  AGD 11
                    fcb       $77,$02   6 magenta (7,2,7)  AGD 13
                    fcb       $27,$07   7 cyan    (2,7,7)  AGD 7
                    fcb       $77,$07   8 white
                    fcb       $27,$03   9 light blue (2,3,7)  AGD 5
                    fcb       $55,$05   10 grey (5,5,5)       AGD 14
                    fcb       $33,$07   11 light green (3,7,3)
                    fcb       $73,$03   12 light red (7,3,3)
                    fcb       $73,$07   13 light yellow (7,7,3)
                    fcb       $77,$03   14 light magenta (7,3,7)
                    fcb       $37,$07   15 light cyan (3,7,7)

* CoCo 3 colour (6 bits: 0 blue low, 1 green low, 2 red low, 3 blue high,
* 4 green high, 5 red high) to the V9958 palette bytes (RB, 0G), 3 bits per
* channel: each 2-bit level 0-3 becomes 0, 2, 5, 7.
VdpCol
                    fcb       $00,$00,$02,$00,$00,$02,$02,$02 ; 0-3
                    fcb       $20,$00,$22,$00,$20,$02,$22,$02 ; 4-7
                    fcb       $05,$00,$07,$00,$05,$02,$07,$02 ; 8-11
                    fcb       $25,$00,$27,$00,$25,$02,$27,$02 ; 12-15
                    fcb       $00,$05,$02,$05,$00,$07,$02,$07 ; 16-19
                    fcb       $20,$05,$22,$05,$20,$07,$22,$07 ; 20-23
                    fcb       $05,$05,$07,$05,$05,$07,$07,$07 ; 24-27
                    fcb       $25,$05,$27,$05,$25,$07,$27,$07 ; 28-31
                    fcb       $50,$00,$52,$00,$50,$02,$52,$02 ; 32-35
                    fcb       $70,$00,$72,$00,$70,$02,$72,$02 ; 36-39
                    fcb       $55,$00,$57,$00,$55,$02,$57,$02 ; 40-43
                    fcb       $75,$00,$77,$00,$75,$02,$77,$02 ; 44-47
                    fcb       $50,$05,$52,$05,$50,$07,$52,$07 ; 48-51
                    fcb       $70,$05,$72,$05,$70,$07,$72,$07 ; 52-55
                    fcb       $55,$05,$57,$05,$55,$07,$57,$07 ; 56-59
                    fcb       $75,$05,$77,$05,$75,$07,$77,$07 ; 60-63

********************************************************************
* Operations. Each runs inside VdpDo with the cursor already hidden
* and VdpOpen held, and gets the caller's A and B. Cursor positions are
* relative to the working area (V9.AX, V9.AY, V9.AW, V9.AH), which is the
* whole screen unless $1B $20 (DWSet), $1B $25 (CWArea) or an overlay
* has narrowed it.
********************************************************************
OpNone              rts

OpCR                clr       V9.CurX,u
                    rts

OpHome              clr       V9.CurX,u
                    clr       V9.CurY,u
                    rts

* OpLeft / OpRight move through the area like CoVDG's linear cursor: left
* at the start of a row goes to the end of the row above, right at the end
* of a row goes to the start of the next one. Nothing happens at the first
* and last cell of the area. (SCF's line editing relies on this when a
* command spans several rows.)
OpLeft              lda       V9.CurX,u
                    beq       OpL1
                    dec       V9.CurX,u
                    rts
OpL1                lda       V9.CurY,u
                    beq       OpL9
                    dec       V9.CurY,u
                    lda       V9.AW,u
                    deca
                    sta       V9.CurX,u
OpL9                rts

OpRight             lda       V9.CurX,u
                    inca
                    cmpa      V9.AW,u
                    bhs       OpR1
                    sta       V9.CurX,u
                    rts
OpR1                lda       V9.CurY,u
                    inca
                    cmpa      V9.AH,u
                    bhs       OpR9
                    sta       V9.CurY,u
                    clr       V9.CurX,u
OpR9                rts

OpUp                lda       V9.CurY,u
                    beq       OpU9
                    dec       V9.CurY,u
OpU9                rts

OpDown              lbra      VdpLF

* OpGoto: A = column, B = row (0-based, inside the area). Ignored if
* outside it.
OpGoto              cmpa      V9.AW,u
                    bhs       OpG9
                    cmpb      V9.AH,u
                    bhs       OpG9
                    sta       V9.CurX,u
                    stb       V9.CurY,u
OpG9                rts

* OpDelLine falls into OpEraseEOL
OpDelLine
                    clr       V9.CurX,u
OpEraseEOL
                    clra
                    ldb       V9.AW,u
                    subb      V9.CurX,u
                    tfr       d,y       ; y = cells from the cursor to the end of the row
                    lbsr      VdpPos
                    pshs      y
                    clra
                    lbsr      VdpFill
                    puls      y
                    lda       V9.AY,u
                    adda      V9.CurY,u
                    ldb       #80
                    mul                 ; d = row * 80
                    pshs      d
                    ldb       V9.AX,u
                    addb      V9.CurX,u
                    clra
                    addd      ,s++      ; d = first cell in the blink table
                    lbra      VdpBlkRng

OpEraseEOS
                    lbsr      OpEraseEOL
                    lda       V9.CurY,u
                    inca
                    pshs      a         ; row
VdpEs1              lda       ,s
                    cmpa      V9.AH,u
                    bhs       VdpEs9
                    lbsr      VdpRowBlank
                    inc       ,s
                    bra       VdpEs1
VdpEs9              leas      1,s
                    rts

OpCls               clr       V9.CurX,u
                    clr       V9.CurY,u
                    lbsr      VdpBlkFull
                    clra
                    pshs      a         ; row
VdpCl1              lda       ,s
                    cmpa      V9.AH,u
                    bhs       VdpCl9
                    lbsr      VdpRowBlank
                    inc       ,s
                    bra       VdpCl1
VdpCl9              leas      1,s
                    rts

* VdpLF: line feed, scrolling the area when it passes its last row
VdpLF               inc       V9.CurY,u
                    lda       V9.CurY,u
                    cmpa      V9.AH,u
                    blo       VdpLF9
                    lda       V9.AH,u
                    deca
                    sta       V9.CurY,u
                    clra
                    lbra      VdpRowsUp ; scroll = delete row 0
VdpLF9              rts

* OpInsLn (1F 30): insert a line at the cursor row; the rows below move
* down and the last one is lost.
OpInsLn
                    lda       V9.AH,u
                    suba      V9.CurY,u
                    deca                ; a = rows to move
                    beq       VdpIn3
                    pshs      a         ; n
                    lda       V9.AH,u
                    suba      #2
                    pshs      a         ; r = AH-2
VdpIn1              lda       ,s
                    tfr       a,b
                    incb                ; destination r+1
                    lbsr      VdpRowCopy
                    dec       ,s
                    dec       1,s
                    bne       VdpIn1
                    leas      2,s
VdpIn3              lda       V9.CurY,u
                    lbra      VdpRowBlank

* OpDelLn (1F 31): delete the cursor row; the rows below move up and the
* last one is blanked.
OpDelLn             lda       V9.CurY,u
                    lbra      VdpRowsUp

* VdpRowsUp: A = first row. Rows A+1..AH-1 move up one row, the last row
* is blanked.
VdpRowsUp
                    pshs      a         ; r
VdpRu1              lda       ,s
                    inca
                    cmpa      V9.AH,u
                    bhs       VdpRu2
                    ldb       ,s        ; destination r
                    lbsr      VdpRowCopy ; a = source r+1
                    inc       ,s
                    bra       VdpRu1
VdpRu2              leas      1,s
                    lda       V9.AH,u
                    deca
                    lbra      VdpRowBlank

* VdpRowAddr: A = row relative to the area; X = VRAM address of its
* first cell. Clobbers A,B.
VdpRowAddr
                    adda      V9.AY,u
                    ldb       V9.Cols,u
                    mul
                    addd      V9.Base,u
                    pshs      d
                    ldb       V9.AX,u
                    clra
                    addd      ,s++
                    tfr       d,x
                    rts

* VdpBlkRowAddr: A = row relative to the area; X = address of the blink
* table byte holding the first cell of that row (80 columns).
VdpBlkRowAddr
                    adda      V9.AY,u
                    ldb       #10
                    mul
                    addd      V9.Base,u
                    addd      #$0A00
                    pshs      d
                    ldb       V9.AX,u
                    lsrb
                    lsrb
                    lsrb
                    clra
                    addd      ,s++
                    tfr       d,x
                    rts

* VdpRowCopy: A = source row, B = destination row (relative to the area,
* different rows). Copies the area's cells of the row, and their flag
* bits when the blink table is in use: byte-wise if the area is aligned to
* 8 columns, otherwise the flags of the destination row are cleared.
VdpRowCopy
                    pshs      d         ; a at ,s  B at 1,s
                    lbsr      VdpRowAddr
                    pshs      x
                    lda       3,s       ; destination row
                    lbsr      VdpRowAddr
                    tfr       x,y
                    puls      x
                    clra
                    ldb       V9.AW,u
                    lbsr      VdpMvUp
                    lbsr      VdpBlkAct
                    beq       VdpRc9
                    tst       V9.BAl,u
                    beq       VdpRc8
                    lda       ,s
                    lbsr      VdpBlkRowAddr
                    pshs      x
                    lda       3,s
                    lbsr      VdpBlkRowAddr
                    tfr       x,y
                    puls      x
                    clra
                    ldb       V9.AW,u
                    lsrb
                    lsrb
                    lsrb
                    lbsr      VdpMvUp
                    bra       VdpRc9
VdpRc8              lda       1,s
                    lbsr      VdpBlkRowRng ; unaligned: drop the destination row's flags
VdpRc9              puls      d,pc

* VdpRowBlank: A = row relative to the area. Blank its cells and flags.
VdpRowBlank
                    pshs      a
                    lbsr      VdpRowAddr
                    clra
                    ldb       V9.AW,u
                    tfr       d,y
                    clra
                    lbsr      VdpFill
                    puls      a
* VdpBlkRowRng: clear the flags of the area's cells in row A
VdpBlkRowRng
                    adda      V9.AY,u
                    ldb       #80
                    mul
                    pshs      d
                    ldb       V9.AX,u
                    clra
                    addd      ,s++      ; d = first cell
                    pshs      d
                    clra
                    ldb       V9.AW,u
                    tfr       d,y       ; y = number of cells
                    puls      d
                    lbra      VdpBlkRng

* VdpChunk: copy B (1..V9CHNK) bytes from VRAM X to VRAM Y through a
* buffer on the stack. V9.SHi / V9.DHi (4 or 0) say whether the source /
* destination is in the upper 64K of VRAM (address bit 16). Clobbers A,B,X,Y.
VdpChunk
                    pshs      b
                    leas      -V9CHNK,s
                    lda       V9.SHi,u  ; source in the upper 64K? (4) or the lower (0)
                    sta       V9.Hi,u
                    lbsr      VdpSetRd
                    leax      ,s
                    ldb       V9CHNK,s
VdpCk1              lda       VDPDAT
                    sta       ,x+
                    decb
                    bne       VdpCk1
                    tfr       y,x
                    lda       V9.DHi,u
                    sta       V9.Hi,u
                    lbsr      VdpSetWr
                    leax      ,s
                    ldb       V9CHNK,s
VdpCk2              lda       ,x+
                    sta       VDPDAT
                    decb
                    bne       VdpCk2
                    clr       V9.Hi,u
                    leas      V9CHNK+1,s
                    rts

* VdpMvUp: copy D bytes (any count, may be 0) from VRAM X to VRAM Y,
* ascending. The ranges must not overlap.
VdpMvUp
                    pshs      d
VdpMu1              ldd       ,s
                    beq       VdpMu9
                    cmpd      #V9CHNK
                    bls       VdpMu2
                    ldb       #V9CHNK
VdpMu2              pshs      b
                    pshs      x,y
                    lbsr      VdpChunk
                    puls      x,y
                    ldb       ,s
                    abx
                    leay      b,y
                    ldd       1,s
                    subb      ,s
                    sbca      #0
                    std       1,s
                    leas      1,s
                    bra       VdpMu1
VdpMu9              leas      2,s
                    rts

* VdpAlign: V9.BAl = 1 when the area's left edge and width are multiples
* of 8 (flag bits can then be moved byte-wise).
VdpAlign
                    lda       V9.AX,u
                    ora       V9.AW,u
                    anda      #7
                    beq       VdpAl1
                    clr       V9.BAl,u
                    rts
VdpAl1              lda       #1
                    sta       V9.BAl,u
                    rts

* OpSetDW: the device window becomes V9.NX..NH; the working area becomes
* the same window. The whole page is cleared first (the text outside the
* new window could never be reached again), then the cursor goes to the
* window's top left.
OpSetDW             clr       V9.AX,u
                    clr       V9.AY,u
                    lda       V9.Cols,u
                    sta       V9.AW,u
                    lda       #V9ROWS
                    sta       V9.AH,u
                    lda       #1
                    sta       V9.BAl,u
                    lbsr      OpCls
                    ldd       V9.NX,u
                    std       V9.DX,u
                    std       V9.AX,u
                    std       V9.WX,u
                    ldd       V9.NW,u
                    std       V9.DW,u
                    std       V9.AW,u
                    std       V9.WW,u
                    ldd       #0
                    std       V9.OvTop,u ; any overlay is gone
                    ldd       V9.Base,u
                    addd      #16
                    std       V9.OvEnd,u
                    lbra      VdpAlign

* OpSetCW: the working area becomes V9.NX..NH, relative to the current
* window (the device window, or the top overlay); home the cursor. If
* V9.CwClr is set, the whole window (inside the new area and outside it)
* is cleared.
OpSetCW             lda       V9.WX,u
                    adda      V9.NX,u
                    sta       V9.AX,u
                    lda       V9.WY,u
                    adda      V9.NY,u
                    sta       V9.AY,u
                    ldd       V9.NW,u
                    std       V9.AW,u
                    lbsr      VdpAlign
                    clr       V9.CurX,u
                    clr       V9.CurY,u
                    tst       V9.CwClr,u
                    beq       VdpCw9
                    ldd       V9.WX,u   ; clear the whole window, inside the new
                    std       V9.NX,u   ; area too: the new text must not mix
                    ldd       V9.WW,u   ; with the old
                    std       V9.NW,u
                    lbsr      VdpClrRect
VdpCw9              rts

* VdpClrRect: blank the cells and flags of the rectangle V9.NX..NH
* (absolute). Nothing if its width or height is 0.
VdpClrRect
                    lda       V9.NW,u
                    beq       VdpCr9
                    lda       V9.NH,u
                    beq       VdpCr9
                    clra
                    pshs      a         ; row counter
VdpCr1              lda       ,s
                    cmpa      V9.NH,u
                    bhs       VdpCr8
                    adda      V9.NY,u
                    ldb       V9.Cols,u
                    mul
                    addd      V9.Base,u
                    pshs      d
                    ldb       V9.NX,u
                    clra
                    addd      ,s++
                    tfr       d,x
                    clra
                    ldb       V9.NW,u
                    tfr       d,y
                    clra
                    lbsr      VdpFill
                    lda       ,s
                    adda      V9.NY,u
                    ldb       #80
                    mul
                    pshs      d
                    ldb       V9.NX,u
                    clra
                    addd      ,s++
                    pshs      d
                    clra
                    ldb       V9.NW,u
                    tfr       d,y
                    puls      d
                    lbsr      VdpBlkRng
                    inc       ,s
                    bra       VdpCr1
VdpCr8              leas      1,s
VdpCr9              rts

********************************************************************
* Overlay windows. The area under an overlay is saved in the upper 64K of
* VRAM, 8K per screen: screen n uses $10000 + n*$2000 (V9.Base + $10000).
* Records are stacked there; V9.OvTop is the newest one (0 = none) and
* V9.OvEnd the first free byte. A record (V9HDR bytes) holds: +0 the
* previous OvTop, +2 flags (bit 0: the area was saved, bit 1: its flag
* bits too), +3 the previous working area, +7 the previous window, +11 the
* previous cursor; then the saved cells (rows of the overlay's width), then
* the saved flag bytes. Overlays take the colours of their parent.
********************************************************************
* VdpHdrPut: copy B bytes from RAM at Y to the upper VRAM at X.
VdpHdrPut
                    pshs      b
                    lda       #4
                    sta       V9.Hi,u
                    lbsr      VdpSetWr
                    ldb       ,s+
VdpHp1              lda       ,y+
                    sta       VDPDAT
                    decb
                    bne       VdpHp1
                    clr       V9.Hi,u
                    rts

* VdpHdrGet: copy B bytes from the upper VRAM at X to RAM at Y.
VdpHdrGet
                    pshs      b
                    lda       #4
                    sta       V9.Hi,u
                    lbsr      VdpSetRd
                    ldb       ,s+
VdpHg1              lda       VDPDAT
                    sta       ,y+
                    decb
                    bne       VdpHg1
                    clr       V9.Hi,u
                    rts

* VdpRxMv: D bytes between X (lower VRAM) and Y (upper VRAM). V9.RMode 0:
* save (X -> Y), 1: restore (Y -> X).
VdpRxMv
                    pshs      d         ; (LDA #4 below would destroy the count)
                    tst       V9.RMode,u
                    bne       VdpRm1
                    lda       #4
                    sta       V9.DHi,u
                    bra       VdpRm2
VdpRm1              exg       x,y
                    lda       #4
                    sta       V9.SHi,u
VdpRm2              puls      d
                    lbsr      VdpMvUp
                    clr       V9.SHi,u
                    clr       V9.DHi,u
                    rts

* VdpRectX: move the cells of the rectangle V9.NX..NH (absolute) and, if
* V9.RFl is set, their flag bytes, between the screen and the save area
* (V9.RPtr, V9.RFPtr), row by row. V9.RMode as in VdpRxMv.
VdpRectX
                    clr       V9.RRow,u
VdpRx1              lda       V9.RRow,u
                    cmpa      V9.NH,u
                    lbhs      VdpRx9
                    adda      V9.NY,u
                    ldb       V9.Cols,u
                    mul
                    addd      V9.Base,u
                    pshs      d
                    ldb       V9.NX,u
                    clra
                    addd      ,s++
                    tfr       d,x       ; x = the row's first cell
                    ldy       V9.RPtr,u ; y = its place in the save area
                    clra
                    ldb       V9.NW,u
                    lbsr      VdpRxMv
                    ldd       V9.RPtr,u
                    pshs      d
                    clra
                    ldb       V9.NW,u
                    addd      ,s++
                    std       V9.RPtr,u
                    tst       V9.RFl,u
                    beq       VdpRx5
                    lda       V9.RRow,u
                    adda      V9.NY,u
                    ldb       #10
                    mul
                    addd      V9.Base,u
                    addd      #$0A00
                    pshs      d
                    ldb       V9.NX,u
                    lsrb
                    lsrb
                    lsrb
                    clra
                    addd      ,s++
                    tfr       d,x       ; x = the row's first flag byte
                    ldy       V9.RFPtr,u
                    clra
                    ldb       V9.NW,u
                    lsrb
                    lsrb
                    lsrb                ; d = flag bytes in the row
                    pshs      d
                    lbsr      VdpRxMv
                    puls      d
                    addd      V9.RFPtr,u
                    std       V9.RFPtr,u
VdpRx5              inc       V9.RRow,u
                    lbra      VdpRx1
VdpRx9              rts

* VdpBlkRectClr: clear the flag bits of the rectangle V9.NX..NH (absolute).
VdpBlkRectClr
                    clr       V9.RRow,u
VdpBc1              lda       V9.RRow,u
                    cmpa      V9.NH,u
                    bhs       VdpBc9
                    adda      V9.NY,u
                    ldb       #80
                    mul
                    pshs      d
                    ldb       V9.NX,u
                    clra
                    addd      ,s++
                    pshs      d         ; first cell
                    clra
                    ldb       V9.NW,u
                    tfr       d,y       ; y = number of cells
                    puls      d
                    lbsr      VdpBlkRng
                    inc       V9.RRow,u
                    bra       VdpBc1
VdpBc9              rts

* OpOvSet: open an overlay on the rectangle V9.NX..NH (relative to the
* device window; V9.Sv = save switch). With the save switch on, the area
* under it is saved and then cleared. On failure V9.Err gets an error code
* and nothing changes.
OpOvSet             lda       V9.DX,u
                    adda      V9.NX,u
                    sta       V9.NX,u   ; absolute column
                    lda       V9.DY,u
                    adda      V9.NY,u
                    sta       V9.NY,u   ; absolute row
                    clr       V9.RFl,u
                    ldd       #V9HDR
                    pshs      d         ; record size, at ,s
                    tst       V9.Sv,u
                    beq       VdpOv2
                    lda       V9.NW,u
                    ldb       V9.NH,u
                    mul
                    addd      ,s
                    std       ,s        ; + the cells
                    lbsr      VdpBlkAct
                    beq       VdpOv2
                    lda       V9.NX,u
                    ora       V9.NW,u
                    anda      #7
                    bne       VdpOv2    ; unaligned overlay: flags are not saved
                    lda       #1
                    sta       V9.RFl,u
                    lda       V9.NW,u
                    lsra
                    lsra
                    lsra
                    ldb       V9.NH,u
                    mul
                    addd      ,s
                    std       ,s        ; + the flag bytes
VdpOv2              ldd       V9.OvEnd,u
                    subd      V9.Base,u
                    pshs      d         ; used
                    ldd       #$2000
                    subd      ,s++      ; d = free bytes of this screen's save area
                    cmpd      ,s
                    bhs       VdpOv3
                    leas      2,s
                    lda       #E$NoRAM
                    sta       V9.Err,u
                    rts
VdpOv3              leas      -V9HDR,s  ; record header, built on the stack
                    ldd       V9.OvTop,u
                    std       0,s
                    clr       2,s
                    tst       V9.Sv,u
                    beq       VdpOv4
                    lda       #1
                    sta       2,s
VdpOv4              tst       V9.RFl,u
                    beq       VdpOv5
                    lda       2,s
                    ora       #2
                    sta       2,s
VdpOv5              ldd       V9.AX,u
                    std       3,s
                    ldd       V9.AW,u
                    std       5,s
                    ldd       V9.WX,u
                    std       7,s
                    ldd       V9.WW,u
                    std       9,s
                    ldd       V9.CurX,u
                    std       11,s
                    ldx       V9.OvEnd,u
                    leay      ,s
                    ldb       #V9HDR
                    lbsr      VdpHdrPut
                    leas      V9HDR,s
                    tst       V9.Sv,u
                    beq       VdpOv6
                    ldd       V9.OvEnd,u
                    addd      #V9HDR
                    std       V9.RPtr,u
                    lda       V9.NW,u
                    ldb       V9.NH,u
                    mul
                    addd      V9.RPtr,u
                    std       V9.RFPtr,u
                    clr       V9.RMode,u
                    lbsr      VdpRectX  ; save the cells (and flags) under the overlay
VdpOv6              ldd       V9.OvEnd,u
                    std       V9.OvTop,u ; the new record
                    addd      ,s++
                    std       V9.OvEnd,u
                    ldd       V9.NX,u
                    std       V9.WX,u
                    std       V9.AX,u
                    ldd       V9.NW,u
                    std       V9.WW,u
                    std       V9.AW,u
                    lbsr      VdpAlign
                    tst       V9.Sv,u
                    beq       VdpOv7
                    lbra      OpCls     ; clear the overlay and home the cursor
VdpOv7              clr       V9.CurX,u
                    clr       V9.CurY,u
                    rts

* OpOvEnd: close the top overlay: restore what it covered (if it saved it),
* then the previous window, working area and cursor.
OpOvEnd             ldd       V9.OvTop,u
                    bne       VdpOe1
                    lda       #E$IWDef
                    sta       V9.Err,u
                    rts
VdpOe1              tfr       d,x
                    leas      -V9HDR,s
                    leay      ,s
                    ldb       #V9HDR
                    lbsr      VdpHdrGet
                    lda       2,s
                    anda      #1
                    beq       VdpOe3    ; opened without saving: nothing to restore
                    ldd       V9.WX,u   ; the overlay's own rectangle
                    std       V9.NX,u
                    ldd       V9.WW,u
                    std       V9.NW,u
                    ldd       V9.OvTop,u
                    addd      #V9HDR
                    std       V9.RPtr,u
                    lda       V9.NW,u
                    ldb       V9.NH,u
                    mul
                    addd      V9.RPtr,u
                    std       V9.RFPtr,u
                    clr       V9.RFl,u
                    lda       2,s
                    anda      #2
                    beq       VdpOe2
                    lda       #1
                    sta       V9.RFl,u
                    sta       V9.AltUsed,u ; restored flags are in use again
VdpOe2              lda       #1
                    sta       V9.RMode,u
                    lbsr      VdpRectX
                    tst       V9.RFl,u
                    bne       VdpOe3
                    lbsr      VdpBlkRectClr ; no saved flags: the rectangle has none
VdpOe3              ldd       3,s
                    std       V9.AX,u
                    ldd       5,s
                    std       V9.AW,u
                    ldd       7,s
                    std       V9.WX,u
                    ldd       9,s
                    std       V9.WW,u
                    ldd       11,s
                    std       V9.CurX,u
                    ldd       V9.OvTop,u
                    std       V9.OvEnd,u ; the record's space is free again
                    ldd       0,s
                    std       V9.OvTop,u
                    leas      V9HDR,s
                    lbra      VdpAlign

********************************************************************
* Alternate colours / blink (80 columns). Text 2 has a blink table, one
* bit per cell (10 bytes per row) at page + $0A00: a cell whose bit is set
* is shown in the R#12 colours and, depending on R#13, alternates with the
* R#7 colours (blink) or shows only the R#12 colours (R#13 = $F0, the
* default). The table is kept up to date only while it is in use
* (V9.AltUsed), so ordinary text costs nothing extra.
********************************************************************
* VdpBlkAct: A = 0 and Z set when the blink table is not in use.
VdpBlkAct
                    lda       V9.AltUsed,u
                    beq       VdpBaX
                    lda       V9.Cols,u
                    cmpa      #80
                    beq       VdpBaY
                    clra
                    rts
VdpBaY              lda       #1
VdpBaX              rts

* VdpBlkAll: clear the whole blink table of this page and the in-use flag.
VdpBlkAll
                    clr       V9.AltUsed,u
                    lda       V9.Cols,u
                    cmpa      #80
                    bne       VdpBlA9
                    ldd       V9.Base,u
                    addd      #$0A00
                    tfr       d,x
                    ldy       #V9BLNK
                    clra
                    lbra      VdpFill
VdpBlA9             rts

* VdpBlkFull: VdpBlkAll, but only if the area is the whole screen.
VdpBlkFull
                    lda       V9.AX,u
                    ora       V9.AY,u
                    bne       VdpBf9
                    lda       V9.AW,u
                    cmpa      V9.Cols,u
                    bne       VdpBf9
                    lda       V9.AH,u
                    cmpa      #V9ROWS
                    bne       VdpBf9
                    lbra      VdpBlkAll
VdpBf9              rts

* VdpBlkPut: set (V9.Alt on) or clear the bit of the cell at the cursor.
VdpBlkPut
                    tst       V9.Alt,u
                    beq       VdpBp0
                    tst       V9.BAl,u  ; flags can only be set in aligned areas
                    beq       VdpBp0
                    lda       #1
                    sta       V9.AltUsed,u
VdpBp0              lbsr      VdpBlkAct
                    lbeq      VdpBp9
                    lda       V9.AY,u
                    adda      V9.CurY,u
                    ldb       #10
                    mul                 ; d = row * 10
                    pshs      d
                    ldb       V9.AX,u
                    addb      V9.CurX,u ; column
                    pshs      b
                    lsrb
                    lsrb
                    lsrb
                    clra
                    addd      1,s       ; d = row*10 + column/8
                    leas      3,s
                    addd      V9.Base,u
                    addd      #$0A00
                    tfr       d,x       ; x = address of the byte
                    ldb       V9.AX,u
                    addb      V9.CurX,u
                    andb      #7
                    lda       #$80
                    tstb
                    beq       VdpBp2
VdpBp1              lsra
                    decb
                    bne       VdpBp1    ; a = mask of the cell's bit
VdpBp2              pshs      a
                    lbsr      VdpGetAt  ; a = the byte
                    ldb       ,s+       ; b = mask
                    tst       V9.Alt,u
                    beq       VdpBp3
                    tst       V9.BAl,u
                    beq       VdpBp3
                    pshs      b
                    ora       ,s+
                    bra       VdpBp4
VdpBp3              comb
                    pshs      b
                    anda      ,s+
VdpBp4              lbsr      VdpPutAt
VdpBp9              rts

* VdpBlkRng: clear the blink bits of the cells D .. D+Y-1 (D = first cell
* index in the blink table, Y = count). Any alignment. No effect when the
* blink table is not in use.
VdpBlkRng
                    pshs      d,y
                    lbsr      VdpBlkAct
                    puls      d,y       ; (PULS leaves the flags of VdpBlkAct alone)
                    lbeq      VdpBr9
                    std       V9.T1,u   ; c = first cell
                    tfr       y,d
                    addd      V9.T1,u
                    std       V9.T2,u   ; end (exclusive)
VdpBr1              ldd       V9.T1,u
                    cmpd      V9.T2,u
                    lbhs      VdpBr9
                    pshs      d
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    addd      V9.Base,u
                    addd      #$0A00
                    tfr       d,x       ; x = address of the byte holding cell c
                    puls      d
                    andb      #7        ; b = bit offset o in the byte
                    stb       V9.T4,u
                    lda       #8
                    suba      V9.T4,u   ; a = 8 - o
                    pshs      a
                    ldd       V9.T2,u
                    subd      V9.T1,u   ; d = cells left
                    tsta
                    bne       VdpBr2
                    cmpb      ,s
                    bhs       VdpBr2
                    leas      1,s       ; fewer cells left than fit in the byte:
                    tfr       b,a       ; n = cells left
                    bra       VdpBr3
VdpBr2              puls      a         ; n = 8 - o
VdpBr3              pshs      a         ; n
                    ldd       V9.T1,u
                    addb      ,s        ; c += n
                    adca      #0
                    std       V9.T1,u
                    lda       #$FF
                    ldb       V9.T4,u
                    beq       VdpBr5
VdpBr4              lsra
                    decb
                    bne       VdpBr4    ; a = $FF >> o
VdpBr5              pshs      a
                    lda       #$FF
                    ldb       V9.T4,u
                    addb      1,s       ; b = o + n
VdpBr6              lsra
                    decb
                    bne       VdpBr6    ; a = $FF >> (o+n)
                    eora      ,s+       ; a = bits o .. o+n-1
                    leas      1,s       ; drop n
                    coma                ; bits to keep
                    pshs      a
                    lbsr      VdpGetAt
                    anda      ,s+
                    lbsr      VdpPutAt
                    lbra      VdpBr1
VdpBr9              rts

********************************************************************
* Entry points for the co-module
*
* VdpDo: Y = one of the Op routines above, A/B = its parameters.
*   Opens the VDP, hides the cursor, runs the operation, shows the
*   cursor again, closes the VDP. Preserves A, B and X.
* VdpPutChar: A = ASCII character; puts it at the cursor and advances
*   (wrapping to the next line, scrolling at the bottom).
********************************************************************
VdpDo               pshs      d,x
                    lbsr      VdpOpen
                    lbsr      VdpCurHide
                    ldd       ,s
                    jsr       ,y
                    lbsr      VdpCurShow
                    lbsr      VdpClose
                    puls      d,x,pc

VdpPutChar
                    pshs      d,x,y
                    lbsr      VdpOpen
                    lbsr      VdpCurHide
                    lbsr      VdpPos
                    lda       ,s        ; the character
                    lbsr      VdpAscii
                    ora       V9.Attr,u ; $80 = reverse video
                    lbsr      VdpPutAt
                    lbsr      VdpBlkPut ; blink-table bit of the cell (80 columns)
                    inc       V9.CurX,u
                    lda       V9.CurX,u
                    cmpa      V9.AW,u
                    blo       VdpPc1
                    clr       V9.CurX,u
                    lbsr      VdpLF
VdpPc1              lbsr      VdpCurShow
                    lbsr      VdpClose
                    puls      d,x,y,pc

* The glyph table (VdpFont, V9FLEN) comes from vdpfont.asm
                    use       vdpfont.asm
