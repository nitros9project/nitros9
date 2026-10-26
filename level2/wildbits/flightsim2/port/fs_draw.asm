* fs_draw.asm - FS (Flight Simulator II), part of the port: polygon fill, glyphs and text, number conversion, panel readouts (compass, radios, clock, DME,
* tach, switches), overlay switching and data-block loading, throttle/trim/flaps/oil/fuel markers ($11E1-$1BFB)
* Assembled by fs.asm (use); absolute self-references are label+ModBase.

* FillPolygon: Close the polygon built by PolyBegin/PolyAddVertex and scan-fill it row by row from min Y <$DB to max Y <$DC with color $0178
FillPolygon               ldx       >vPolyLast
                    ldd       >vPolyFirst
                    cmpb      >vPolyLast+1
                    blo       FillPolygonSetup
                    exg       d,x
* FillPolygonSetup: FillPolygon: add closing edge, compute row count and first screen row address ($1538 row table + $0CD9 base) into $0CCB
FillPolygonSetup               jsr       >PolyAddVertexStore+ModBase
                    lda       <vPolyLastRow
                    suba      <vPolyRow
                    sta       >vPolyRows
                    ldx       #vRowAddrTbl
                    ldb       <vPolyRow
                    aslb
                    abx
                    ldx       ,x
                    ldd       >vViewScr
                    leax      d,x
                    stx       >vPolyRowAdr
* FillPolygonRowLoop: FillPolygon: per-scanline loop, advances $0CCB by 80 bytes per row
FillPolygonRowLoop               lda       <vPolyRow
                    bsr       FillPolyScanline
                    ldx       >vPolyRowAdr
                    leax      <FsRowBytes,x
                    stx       >vPolyRowAdr
                    inc       <vPolyRow
                    dec       >vPolyRows
                    bpl       FillPolygonRowLoop
                    rts
* FillPolyScanline: Fill one scanline A=<$DB: walk edge list $0AC6, collect X crossings at $0C46, draw spans with DrawHLine
FillPolyScanline               ldy       #vPolyEdgeRecs
                    ldx       #vPolyXings
                    lda       >vPolyEdges
                    sta       >vPolyEdgeLeft
* FillPolyEdgeLoop: FillPolyScanline: loop over the $0CC8 edge records (6 bytes each)
FillPolyEdgeLoop               lda       >vPolyEdgeLeft
                    lda       <vPolyRow
                    ldb       ,y
                    cmpa      ,y+
                    bge       FillPolyEdgeActive
                    leay      5,y
                    dec       >vPolyEdgeLeft
                    bne       FillPolyEdgeLoop
                    bra       FillPolySpans
* FillPolyEdgeActive: FillPolyScanline: edge spans this row; store X crossing and step its fixed-point X by the slope
FillPolyEdgeActive               ldb       ,y
                    cmpa      ,y+
                    lbeq      FillPolyEdgeEnd
                    ldd       ,y
                    aslb
                    rola
                    sta       ,x+
                    ldd       ,y++
                    addd      ,y++
                    std       -4,y
* FillPolyNextEdge: FillPolyScanline: next edge (re-entered from the edge-end paths)
FillPolyNextEdge               dec       >vPolyEdgeLeft
                    lbne      FillPolyEdgeLoop
* FillPolySpans: FillPolyScanline: count crossings and pick 2-crossing, 4-crossing or sorted general case
FillPolySpans               tfr       x,d
                    ldx       #vPolyXings
                    subd      #vPolyXings
                    beq       FillPolyScanDone
                    cmpb      #TwoSpanXings
                    lbgt      FillPolySortX
                    beq       FillPolyTwoSpans
                    ldd       ,x+
                    cmpa      ,x+
                    bhs       FillPolyOneSpan
                    exg       a,b
* FillPolyOneSpan: FillPolyScanline: draw the single span between two crossings
FillPolyOneSpan               ldx       >vPolyRowAdr
                    jsr       >DrawHLine+ModBase
* FillPolyScanDone: FillPolyScanline: return (no crossings)
FillPolyScanDone               rts
* FillPolyTwoSpans: FillPolyScanline: 4 crossings - order the two pairs and draw two spans
FillPolyTwoSpans               ldd       ,x+
                    cmpa      ,x+
                    bhs       FillPolyTwoSpansB
                    exg       a,b
* FillPolyTwoSpansB: FillPolyScanline: 4-crossing case, second pair ordering
FillPolyTwoSpansB               tfr       d,y
                    ldd       ,x+
                    cmpa      ,x
                    bhs       FillPolyTwoSpansC
                    exg       a,b
* FillPolyTwoSpansC: FillPolyScanline: 4-crossing case, merge first pair into <$B1/<$B2
FillPolyTwoSpansC               sty       <vSpan2Right
                    cmpb      <vSpan2Left
                    blo       FillPolyTwoSpansD
                    exg       d,y
                    sty       <vSpan2Right
* FillPolyTwoSpansD: FillPolyScanline: 4-crossing case, final swap before drawing
FillPolyTwoSpansD               cmpa      <vSpan2Left
                    blo       FillPolyTwoSpansDraw1
                    pshs      b
                    ldb       <vSpan2Left
                    sta       <vSpan2Left
                    tfr       b,a
                    puls      b
* FillPolyTwoSpansDraw1: FillPolyScanline: draw first span of the 4-crossing case
FillPolyTwoSpansDraw1               ldx       >vPolyRowAdr
                    jsr       >DrawHLine+ModBase
                    ldd       <vSpan2Right
                    cmpa      <vSpan2Left
                    bhs       FillPolyTwoSpansDraw2
                    exg       a,b
* FillPolyTwoSpansDraw2: FillPolyScanline: draw second span of the 4-crossing case (tail jump to DrawHLine)
FillPolyTwoSpansDraw2               ldx       >vPolyRowAdr
                    jmp       >DrawHLine+ModBase
* FillPolySortX: FillPolyScanline: more than 4 crossings - sort the X list at $0C46
FillPolySortX               stb       <vCrossCount
                    decb
* FillPolySortOuter: FillPolySortX: outer pass of the exchange sort
FillPolySortOuter               stb       <vXSortSlot
                    leay      b,x
                    lda       ,y
                    stb       <vXSortLeft
* FillPolySortInner: FillPolySortX: inner compare/swap loop
FillPolySortInner               cmpa      ,-y
                    bhs       FillPolySortNext
                    ldb       ,y
                    sta       ,y
                    tfr       b,a
* FillPolySortNext: FillPolySortX: inner loop counter step
FillPolySortNext               dec       <vXSortLeft
                    lbne      FillPolySortInner
                    ldb       <vXSortSlot
                    sta       b,x
                    decb
                    lbne      FillPolySortOuter
* FillPolyDrawPairs: FillPolyScanline: draw spans between successive sorted crossing pairs
FillPolyDrawPairs               ldd       ,x++
                    exg       a,b
                    pshs      x
                    ldx       >vPolyRowAdr
                    jsr       >DrawHLine+ModBase
                    puls      x
                    dec       <vCrossCount
                    dec       <vCrossCount
                    bne       FillPolyDrawPairs
                    rts
* FillPolyEdgeEnd: FillPolyScanline: edge ends on this row - plot its end pixel (high nibble for even X) and retire it
FillPolyEdgeEnd               cmpa      -2,y
                    beq       FillPolyFlatEdge
                    ldd       ,y++
                    aslb
                    rola
                    leay      2,y
                    pshs      x
                    jmp       >FswEdgePix         WildBits: the end pixel to the line engine; on at FillPolyRetireEdge
                    lsra
                    blo       FillPolyPlotOddPix
                    ldb       a,x
                    andb      #PixOddNib
                    stb       a,x
                    ldb       >vFillPat
                    andb      #PixEvenNib
                    orb       a,x
                    stb       a,x
                    bra       FillPolyRetireEdge
* FillPolyPlotOddPix: FillPolyEdgeEnd: plot end pixel into the low nibble (odd X)
FillPolyPlotOddPix               ldb       a,x
                    andb      #PixEvenNib
                    stb       a,x
                    ldb       >vFillPat
                    andb      #PixOddNib
                    orb       a,x
                    stb       a,x
* FillPolyRetireEdge: FillPolyScanline: mark edge finished (Y=$7F) and continue with the next edge
FillPolyRetireEdge               lda       #EdgeRetired
                    sta       -6,y
                    puls      x
                    jmp       >FillPolyNextEdge+ModBase
* FillPolyFlatEdge: FillPolyScanline: horizontal edge on this row - draw it as a span and retire it
FillPolyFlatEdge               ldd       ,y++
                    aslb
                    rola
                    ldb       ,y
                    cmpa      ,y++
                    bhs       FillPolyFlatEdgeDraw
                    exg       a,b
* FillPolyFlatEdgeDraw: FillPolyFlatEdge: draw the span with DrawHLine
FillPolyFlatEdgeDraw               pshs      x,y
                    ldx       >vPolyRowAdr
                    jsr       >DrawHLine+ModBase
                    puls      x,y
                    lda       #EdgeRetired
                    sta       -6,y
                    jmp       >FillPolyNextEdge+ModBase
                    fcb       $39
* DrawGlyph: Draw one 3x5 font glyph B=char-$20 (font $14C0) at Y=(x,row) on screen base U, color mask $0201
DrawGlyph               equ       *
* WildBits: no text on the CoCo view rows (fsw)
                    jmp       >FswGlyph
                    aslb
                    abx
                    ldd       ,x
                    ora       #GlyphStopBit
                    std       <vGlyphBits
                    tfr       y,d
                    pshs      a
                    ldx       #vRowAddrTbl
                    aslb
                    abx
                    ldx       ,x
                    tfr       u,d
                    leax      d,x
                    lsr       ,s
                    bhs       DrawGlyphEvenX
                    ldy       #TblGlyphNibOdd+ModBase
                    ldd       #GlyphKeepOdd
                    bra       DrawGlyphSetup
* DrawGlyphEvenX: DrawGlyph: even pixel column - use TblGlyphNibEven and keep mask $000F
DrawGlyphEvenX               ldy       #TblGlyphNibEven+ModBase
                    ldd       #GlyphKeepEven
* DrawGlyphSetup: DrawGlyph: save keep-mask in <$7D, point X at the screen byte
DrawGlyphSetup               std       <vGlyphKeep
                    puls      b
                    abx
                    ldb       <vGlyphBits+1
* DrawGlyphRowLoop: DrawGlyph: expand 3 glyph bits per row to pixels, merge with color, next row until sentinel
DrawGlyphRowLoop               andb      #GlyphRowMask
                    aslb
                    ldd       b,y
                    anda      >vTextColor
                    andb      >vTextColor
                    std       <vGlyphRowPix
                    ldd       ,x
                    anda      <vGlyphKeep
                    andb      <vGlyphKeep+1
                    ora       <vGlyphRowPix
                    orb       <vGlyphRowPix+1
                    std       ,x
                    ldd       <vGlyphBits
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    cmpd      #GlyphStopEnd
                    beq       DrawGlyphDone
                    std       <vGlyphBits
                    leax      <FsRowBytes,x
                    bra       DrawGlyphRowLoop
* DrawGlyphDone: DrawGlyph: return
DrawGlyphDone               rts
* TblGlyphNibOdd: 3-bit glyph row to 4bpp pixel word table for odd X start
TblGlyphNibOdd               fcb       $00,$00,$00,$0F,$00,$F0,$00,$FF
                    fcb       $0F,$00,$0F,$0F,$0F,$F0,$0F,$FF
* TblGlyphNibEven: 3-bit glyph row to 4bpp pixel word table for even X start
TblGlyphNibEven               fcb       $00,$00,$00,$F0,$0F,$00,$0F,$F0
                    fcb       $F0,$00,$F0,$F0,$FF,$00,$FF,$F0
* DrawTextString: Draw text record at X: position word (x,row) then chars ending in 0; 4 pixels per char; screen base U
DrawTextString               ldd       ,x++
                    std       <vTextPos
* DrawTextCharLoop: DrawTextString: per-character loop
DrawTextCharLoop               ldy       <vTextPos
                    ldb       ,x+
                    beq       DrawTextDone
                    subb      #FontFirstChar
                    pshs      x
                    jsr       >DrawGlyph+ModBase
                    puls      x
                    lda       #CharStep
                    adda      <vTextPos
                    sta       <vTextPos
                    bra       DrawTextCharLoop
* DrawTextDone: DrawTextString: return at the 0 terminator
DrawTextDone               rts
* FillRect: Fill rectangle: A=x1 B=y1 (D), X=(x2,y2), Y=screen base; one DrawHLine span per row
FillRect               equ       *
* WildBits: no fills on the CoCo view rows (fsw)
                    jmp       >FswRect
                    nop
                    tfr       b,a
                    suba      <vRectY2
                    nega
                    inca
                    sta       <vRectRows
                    lda       #ScreenBytesPerRow
                    mul
                    leax      d,y
                    lda       <vRectX2
                    ldb       <vRectX1
* FillRectRowLoop: FillRect: per-row loop
FillRectRowLoop               pshs      a,b,x
                    jsr       >DrawHLine+ModBase
                    puls      a,b,x
                    leax      <FsRowBytes,x
                    dec       <vRectRows
                    bne       FillRectRowLoop
                    rts
* DrawMagCompassOff: DrawMagCompass: return when the compass is not enabled
DrawMagCompassOff               rts
* DrawMagCompass: If <$EC bit4: heading <$16 less $014A/$0148, damped toward $0216 (1/8 step), shown as 3 digits at $09BB (probably magnetic compass)
DrawMagCompass               lda       <vInstActive2
                    anda      #InstCompass
                    beq       DrawMagCompassOff
                    ldd       <vHdg
                    subd      >vHdgOfs2
                    subd      >vHdgOfs1
                    std       <vCompassTarget
                    subd      >vCompassHdg
                    asra
                    rorb
                    asra
                    rorb
                    asra
                    rorb
                    bne       DrawMagCompassStep
                    ldd       <vCompassTarget
                    bra       DrawMagCompassStore
                    fcb       $43,$53,$C3,$00,$01
* DrawMagCompassStep: DrawMagCompass: add the damped step to the old value
DrawMagCompassStep               addd      >vCompassHdg
* DrawMagCompassStore: DrawMagCompass: store $0216, convert to degrees and print
DrawMagCompassStore               std       >vCompassHdg
                    bsr       AngleToDegrees360
                    ldx       #vCompassDigits
                    bsr       Dec3ToAscii
                    ldx       #vCompassTxt
                    jmp       >PrintPanelTextF+ModBase
* DrawHeadingInd: If <$EB bit2: heading <$16+$0210 less $014A/$0148 in degrees to $09AA, printed with reciprocal (probably directional gyro)
DrawHeadingInd               lda       <vInstActive1
                    anda      #InstHdgInd
                    beq       WrapNegDegreesDone
                    ldd       <vHdg
                    addd      >vDgOffset
                    subd      >vHdgOfs2
                    subd      >vHdgOfs1
                    cmpd      #Ang180W
                    bne       DrawHeadingIndConv
                    ldb       #Ang180FixLo
* DrawHeadingIndConv: DrawHeadingInd: convert to degrees, skip if unchanged
DrawHeadingIndConv               bsr       AngleToDegrees360
                    cmpd      >vHdgDeg
                    beq       WrapNegDegreesDone
                    std       >vHdgDeg
                    ldx       #vHdgIndDigits
                    bsr       Dec3ToAscii
                    ldx       #vHdgIndTxt
                    jsr       >PrintPanelText4+ModBase
                    ldd       >vHdgDeg
                    subd      #DegPerHalfTurn
                    bsr       WrapNegDegrees
                    ldx       #vHdgRecipDigits
                    bsr       Dec3ToAscii
                    ldx       #vHdgRecipTxt
                    jmp       >PrintPanelText4+ModBase
* AngleToDegrees360: D=16-bit angle -> D=degrees 0-359 (scaled by 180 via MulQ15Vars, wrapped)
AngleToDegrees360               std       <vMulA
                    ldd       #DegPerHalfTurn
                    std       <vMulB
                    jsr       >MulQ15Vars+ModBase
* WrapNegDegrees: Add 360 to D when negative
WrapNegDegrees               cmpa      #NegHighByteMin
                    blo       WrapNegDegreesDone
                    addd      #DegPerTurn
* WrapNegDegreesDone: WrapNegDegrees: return (also shared exit of DrawHeadingInd)
WrapNegDegreesDone               rts
* Dec3ToAscii: D (0-999) -> 3 ASCII digits at X..X+2
Dec3ToAscii               std       <vDecRest
* Dec3ToAsciiDigits: Dec3ToAscii: emit hundreds, tens, units of <$9A (also tail of Dec5ToAscii)
Dec3ToAsciiDigits               ldd       #DecPlace100
                    bsr       DecDigitBySub
                    leax      1,x
                    ldd       #DecPlace10
                    bsr       DecDigitBySub
                    lda       <vDecRest+1
                    ora       #AsciiZero
                    sta       1,x
                    rts
                    fcb       $DD,$9A,$20,$09
* Dec5ToAscii: D (0-65535) -> 5 ASCII digits at X..X+4
Dec5ToAscii               std       <vDecRest
                    ldd       #DecPlace10000
                    bsr       DecDigitBySub
                    leax      1,x
                    ldd       #DecPlace1000
                    bsr       DecDigitBySub
                    leax      1,x
                    bra       Dec3ToAsciiDigits
* DecDigitBySub: One ASCII digit at ,X: count how many times divisor D fits in <$9A, leave remainder in <$9A
DecDigitBySub               std       <vDecPlace
                    lda       #AsciiZero
                    sta       ,x
                    ldd       <vDecRest
* DecDigitBySubLoop: DecDigitBySub: subtract loop
DecDigitBySubLoop               subd      <vDecPlace
                    bmi       DecDigitBySubDone
                    inc       ,x
                    bra       DecDigitBySubLoop
* DecDigitBySubDone: DecDigitBySub: restore remainder and return
DecDigitBySubDone               addd      <vDecPlace
                    std       <vDecRest
                    rts
* Ascii4ToBcd: Four ASCII digits at X -> packed BCD in D
Ascii4ToBcd               lda       ,x+
                    asla
                    asla
                    asla
                    asla
                    sta       <vBcdHiNib
                    lda       ,x+
                    anda      #DigitValMask
                    ora       <vBcdHiNib
                    ldb       ,x+
                    aslb
                    aslb
                    aslb
                    aslb
                    stb       <vBcdHiNib
                    ldb       ,x
                    andb      #DigitValMask
                    orb       <vBcdHiNib
                    rts
* SetNav1Freq: If panel shown: print NAV1 text $09D0; its digits -> BCD $0291/$01F4, flag retune. WildBits
* (2026-10-21): the CoCo panel is never shown, so only the print waits for it; the tuning always happens (the
* same bytes, the branch moved)
SetNav1Freq               lda       <vInstActive2
                    bpl       SetNav1FreqBcd
                    ldx       #vNav1Txt
                    jsr       >PrintPanelText4+ModBase
SetNav1FreqBcd               ldx       #vNav1Digits
                    lbsr      Ascii4ToBcd
                    std       >vNav1Bcd
                    std       >vRadioNav1
* FlagNav1Retune: Clear $028E bit0 and set $028C (NAV1 station must be re-searched)
FlagNav1Retune               lda       #Nav1RxOff
                    bra       FlagNavRetuneMask
* SetNav2Freq: If no ADF: (panel shown) print NAV2 text $09D8; digits -> BCD $028F/$01F6, flag retune. WildBits
* (2026-10-21): the tuning without the CoCo panel too (the same bytes, the tests swapped)
SetNav2Freq               lda       >vAdfEnable
                    bne       SetNavFreqDone
                    lda       <vInstActive2
                    bpl       SetNav2FreqBcd
                    ldx       #vNav2Txt
                    jsr       >PrintPanelText4+ModBase
SetNav2FreqBcd               ldx       #vNav2Digits
                    lbsr      Ascii4ToBcd
                    std       >vNav2Bcd
                    std       >vRadioNav2
* FlagNav2Retune: Clear $028E bit1 and set $028C (NAV2 station must be re-searched)
FlagNav2Retune               lda       #Nav2RxOff
* FlagNavRetuneMask: AND $028E with A, set $028C=1
FlagNavRetuneMask               anda      >vNavRx
                    sta       >vNavRx
                    lda       #NavRetuned
                    sta       >vNavSearch
* SetNavFreqDone: Shared return of the radio display routines
SetNavFreqDone               rts
* SetComFreq: If panel shown: print text $09C8, digits -> BCD $0203/$01F2, set $02AD/$02A3 (probably COM radio)
SetComFreq               lda       <vInstActive2
                    bpl       SetNavFreqDone
                    ldx       #vCom1Txt
                    jsr       >PrintPanelText4+ModBase
                    ldx       #vCom1Digits
                    lbsr      Ascii4ToBcd
                    std       >vComBcd
                    std       >vRadioCom
                    lda       #ComRetuned
                    sta       >vComMsgDone
                    sta       >vComSearch
                    rts
* DrawNav1Obs: If <$EB&$14: OBS $09A8 (2-degree units) and its reciprocal as digits at $09E2/$09E8, print both
DrawNav1Obs               lda       <vInstActive1
                    anda      #ObsShowBits
                    beq       SetNavFreqDone
                    lda       >vNav1Obs
                    ldx       #vObs1Digits
                    bsr       HalfDegToAscii3
                    lda       >vNav1Obs
                    suba      #Obs180Deg
                    bhs       DrawNav1ObsRecip
                    adda      #Obs360Deg
* DrawNav1ObsRecip: DrawNav1Obs: reciprocal course digits
DrawNav1ObsRecip               ldx       #vObs1RecipDigits
                    bsr       HalfDegToAscii3
                    ldx       #vObs1Txt
                    jsr       >PrintPanelTextF+ModBase
                    ldx       #vObs1RecipTxt
                    jmp       >PrintPanelTextB+ModBase
* DrawNav2Obs: If <$ED&$14 and no ADF: OBS $09A9 and reciprocal as digits at $09EE/$09F4, print both
DrawNav2Obs               lda       <vInstActive3
                    anda      #ObsShowBits
                    lbeq      SetNavFreqDone
                    lda       >vAdfEnable
                    bne       SetNavFreqDone
                    lda       >vNav2Obs
                    ldx       #vObs2Digits
                    bsr       HalfDegToAscii3
                    lda       >vNav2Obs
                    suba      #Obs180Deg
                    bhs       DrawNav2ObsRecip
                    adda      #Obs360Deg
* DrawNav2ObsRecip: DrawNav2Obs: reciprocal course digits
DrawNav2ObsRecip               ldx       #vObs2RecipDigits
                    bsr       HalfDegToAscii3
                    ldx       #vObs2Txt
                    jsr       >PrintPanelTextF+ModBase
                    ldx       #vObs2RecipTxt
                    jmp       >PrintPanelTextB+ModBase
* HalfDegToAscii3: A = angle in 2-degree units (0-179) -> 3 ASCII degree digits at X
HalfDegToAscii3               ldb       #AsciiZeroLess1
* HalfDegHundredsLoop: HalfDegToAscii3: hundreds digit loop
HalfDegHundredsLoop               incb
                    suba      #Obs100Deg
                    bhs       HalfDegHundredsLoop
                    adda      #Obs100Deg
                    asla
                    stb       ,x+
                    ldb       #AsciiZeroLess1
* HalfDegTensLoop: HalfDegToAscii3: tens digit loop
HalfDegTensLoop               incb
                    suba      #DecPlace10
                    bhs       HalfDegTensLoop
                    stb       ,x+
                    adda      #AsciiZeroPlus10
                    sta       ,x
* DrawClockDone: Shared return of the clock/DME routines
DrawClockDone               rts
* DrawClockSeconds: If panel shown: clock seconds $0287 as 2 digits at $0A12; when 0 also redraw hours/minutes
DrawClockSeconds               lda       <vInstActive2
                    bpl       DrawClockDone
                    ldb       >vSecond
                    lda       #AsciiZeroLess1
* DrawClockSecTens: DrawClockSeconds: tens loop
DrawClockSecTens               inca
                    subb      #DecPlace10
                    bhs       DrawClockSecTens
                    addb      #AsciiZeroPlus10
                    std       >vSecondDigits
                    ldx       #vClockSecTxt
                    jsr       >PrintPanelText4+ModBase
                    lda       >vSecond
                    bne       DrawClockDone
* DrawClockHourMin: If panel shown: minutes $0322 at $0A0D and hours $0321 at $0A08, printed
DrawClockHourMin               lda       <vInstActive2
                    bpl       DrawClockDone
                    ldb       >vMinute
                    lda       #AsciiZeroLess1
* DrawClockMinTens: DrawClockHourMin: minutes tens loop
DrawClockMinTens               inca
                    subb      #DecPlace10
                    bhs       DrawClockMinTens
                    addb      #AsciiZeroPlus10
                    std       >vMinuteDigits
                    ldx       #vClockMinTxt
                    jsr       >PrintPanelText4+ModBase
                    ldb       >vHour
                    lda       #AsciiZeroLess1
* DrawClockHourTens: DrawClockHourMin: hours tens loop
DrawClockHourTens               inca
                    subb      #DecPlace10
                    bhs       DrawClockHourTens
                    addb      #AsciiZeroPlus10
                    std       >vHourDigits
                    ldx       #vClockHrTxt
                    jmp       >PrintPanelText4+ModBase
* DrawDmeReadout: If panel shown and $071A update bit: DME distance $071C.$071B at $0A17, blanks when $0719 set (probably DME)
DrawDmeReadout               lda       <vInstActive2
                    bpl       DrawClockDone
                    lsr       >vDmeRedraw
                    lbhs      DrawClockDone
                    lda       >vDmeOff
                    bne       DrawDmeBlank
                    lda       >vDmeTenths
                    adda      #AsciiZero
                    sta       >vDmeDigits+2
                    ldb       >vDmeNm
                    lda       #AsciiZeroLess1
* DrawDmeTensLoop: DrawDmeReadout: tens loop
DrawDmeTensLoop               inca
                    subb      #DecPlace10
                    bhs       DrawDmeTensLoop
                    addb      #AsciiZeroPlus10
                    std       >vDmeDigits
* DrawDmePrint: DrawDmeReadout: print text $0A15
DrawDmePrint               ldx       #vDmeTxt
                    jmp       >PrintPanelText4+ModBase
* DrawDmeBlank: DrawDmeReadout: no station - blank the digits
DrawDmeBlank               ldd       #TwoSpaces
                    std       >vDmeDigits
                    sta       >vDmeDigits+2
                    bra       DrawDmePrint
* DrawEngineSwitches: Print $0A36 or $0A31 by $0818 (probably carb heat), then $0A27/$0A2C by $0824 and magneto text via TblMagnetoText
DrawEngineSwitches               ldb       >vCarbHeat
                    bne       DrawEngineSwitchesOn
                    ldx       #vCarbOffTxt
                    jsr       >PrintPanelText6+ModBase
                    bra       DrawEngineSwitchesPanel
* DrawEngineSwitchesOn: DrawEngineSwitches: $0818 set - print $0A31 in color 4
DrawEngineSwitchesOn               ldx       #vCarbOnTxt
                    jsr       >PrintPanelText4+ModBase
* DrawEngineSwitchesPanel: DrawEngineSwitches: panel part ($0824 and magnetos)
DrawEngineSwitchesPanel               lda       <vInstActive2
                    bpl       SetAdfFreqDone
                    ldx       #vLightsOnTxt
                    ldb       >vLights
                    bne       DrawEngineSwitchesMag
                    ldx       #vLightsOffTxt
* DrawEngineSwitchesMag: DrawEngineSwitches: print the magneto position text for $0825
DrawEngineSwitchesMag               jsr       >PrintPanelTextF+ModBase
                    lda       >vMagSw
                    asla
                    ldx       #TblMagnetoText+ModBase
                    ldx       a,x
                    jmp       >PrintPanelTextF+ModBase
* SetAdfFreq: If ADF mode $0348 and panel shown: print $09C1, its 3 digits -> $09A5/$09A6, flag retune
SetAdfFreq               lda       >vAdfEnable
                    beq       SetAdfFreqDone
                    lda       <vInstActive2
                    bpl       SetAdfFreqDone
                    ldx       #vAdfTxt
                    jsr       >PrintPanelText4+ModBase
                    lda       >vAdfDigits+1
                    asla
                    asla
                    asla
                    asla
                    sta       <vBcdHiNib
                    lda       >vAdfDigits+2
                    anda      #DigitValMask
                    ora       <vBcdHiNib
                    sta       >vAdfFreq+1
                    lda       >vAdfDigits
                    anda      #DigitValMask
                    sta       >vAdfFreq
* FlagAdfRetune: Clear $09A4 and set $020E=$FF (ADF must re-search)
FlagAdfRetune               clr       >vAdfFound
                    lda       #AdfRetuned
                    sta       >vAdfSearch
* SetAdfFreqDone: Shared return of the ADF/tach/xpdr routines
SetAdfFreqDone               rts
* DrawTachRpm: If <$EB bit6 and panel shown: RPM $072C (changed vs $09AC) as digits at $0A01-$0A03, print $09FF
DrawTachRpm               lda       <vInstActive1
                    anda      #InstTach
                    beq       SetAdfFreqDone
                    lda       <vInstActive2
                    bpl       SetAdfFreqDone
                    ldb       >vRpm
                    cmpb      >vRpmShown
                    beq       SetAdfFreqDone
                    stb       >vRpmShown
                    lda       #AsciiZero
                    lsrb
                    bhs       DrawTachRpmHalf
                    lda       #AsciiFive
* DrawTachRpmHalf: DrawTachRpm: store 0 or 5 for the odd half step
DrawTachRpmHalf               sta       >vRpmDigits+2
                    lda       #AsciiZeroLess1
* DrawTachRpmTens: DrawTachRpm: tens loop
DrawTachRpmTens               inca
                    subb      #DecPlace10
                    bhs       DrawTachRpmTens
                    addb      #AsciiZeroPlus10
                    std       >vRpmDigits
                    ldx       #vTachTxt
                    jmp       >PrintPanelText4+ModBase
* SetXpdrCode: Digits at $09FA -> BCD $01F8, print $09F8 if panel shown (probably transponder)
SetXpdrCode               ldx       #vXpdrDigits
                    lbsr      Ascii4ToBcd
                    std       >vXpdrCode
                    lda       <vInstActive2
                    bpl       SetAdfFreqDone
                    ldx       #vXpdrTxt
                    jmp       >PrintPanelText4+ModBase
* TblMagnetoText: 5 pointers to magneto position texts $0A6B-$0A7B (probably OFF/R/L/BOTH/START)
TblMagnetoText               fcb       $0A,$6B,$0A,$6F,$0A,$73,$0A,$77
                    fcb       $0A,$7B
* DrawSlewPosition: If $0304 (probably slew mode): clear top band, print $0309/$030B as 5-digit north/east position
DrawSlewPosition               lda       >vSlew
                    beq       DrawSlewPosDone
                    lda       #SlewBandColor
                    jsr       >SetFillColor+ModBase
                    ldb       #SlewBandRows
                    ldx       >vViewScr
* DrawSlewPosClear: DrawSlewPosition: clear 6 rows loop
DrawSlewPosClear               pshs      b,x
* WildBits: the band in view units
                    fcb       $CC,$C6,$28
                    jsr       >DrawHLine+ModBase
                    puls      b,x
                    leax      <FsRowBytes,x
                    decb
                    bne       DrawSlewPosClear
                    ldd       #TxtWhite
                    std       >vTextColor
                    ldd       >vModeNorth
                    ldx       #vSlewNDigits
                    jsr       >Dec5ToAscii+ModBase
                    ldx       #vSlewNTxt
* WildBits: text onto the CoCo screen
                    fcb       $FE,$0C,$CF
                    jsr       >DrawTextString+ModBase
                    ldd       >vModeEast
                    ldx       #vSlewEDigits
                    jsr       >Dec5ToAscii+ModBase
                    ldx       #vSlewETxt
* WildBits: text onto the CoCo screen
                    fcb       $FE,$0C,$CF
                    jsr       >DrawTextString+ModBase
* DrawSlewPosDone: DrawSlewPosition: return
DrawSlewPosDone               rts
* PrintPanelText5: Print text record X on the panel ($0CD3) in color 5
PrintPanelText5               ldd       #TxtGray
                    bra       PrintPanelTextColor
* PrintPanelText0: Print text record X on the panel in color 0 (erase)
PrintPanelText0               ldd       #TxtBlack
                    bra       PrintPanelTextColor
* PrintPanelText4: Print text record X on the panel in color 4
PrintPanelText4               ldd       #TxtRed
                    bra       PrintPanelTextColor
* PrintPanelTextF: Print text record X on the panel in color 15
PrintPanelTextF               ldd       #TxtWhite
                    bra       PrintPanelTextColor
* PrintPanelText6: Print text record X on the panel in color 6
PrintPanelText6               ldd       #TxtBlue
                    bra       PrintPanelTextColor
* PrintPanelTextB: Print text record X on the panel in color 11
PrintPanelTextB               ldd       #TxtGreen
* PrintPanelTextColor: Store color word D in $0201 and print text record X on screen $0CD3
PrintPanelTextColor               std       >vTextColor
                    pshs      u
                    ldu       >vPanelScr
                    jsr       >DrawTextString+ModBase
                    puls      u
                    rts
* TblOverlayNames: 8 pointers to overlay module names, followed by the names f2..f9
TblOverlayNames               fcb       $B7,$88,$B7,$8B,$B7,$8E,$B7,$91
                    fcb       $B7,$94,$B7,$97,$B7,$9A,$B7,$9D
                    fcb       $66,$32,$0D,$66,$33,$0D,$66,$34
                    fcb       $0D,$66,$35,$0D,$66,$36,$0D,$66
                    fcb       $37,$0D,$66,$38,$0D,$66,$39,$0D
* StrFsdModName: Name of the data module fsd linked with each overlay
StrFsdModName               fcc       /fsd/
                    fcb       $0D
* MsgFatalSysError: Text-screen message Fatal System Error ! Address=
MsgFatalSysError    equ       *
* WildBits: no ESC $31 (CoCo palette) on the WildBits terminal: four $00 no-ops each, the same length
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $0C,$02
                    fcc       /''Fatal System Error !/
                    fcb       $02
                    fcc       /&)Address= /
* MsgFatalCode: Text Code= for the fatal error message
MsgFatalCode               fcc       / Code= /
* SwitchOverlay: Make overlay $0221 current: unlink old, link/load fN at $4000 plus fsd, call its entry [$021D]
SwitchOverlay               lda       >vOvlReq
                    cmpa      >vOvlCur
                    bne       SwitchOverlayChange
                    tsta
                    bne       SwitchOverlayRunCur
                    rts
* SwitchOverlayRunCur: SwitchOverlay: same overlay already in - jump to its entry
SwitchOverlayRunCur               jmp       [>vOvlEntry]
* SwitchOverlayChange: SwitchOverlay: overlay changes - allocate memory or unlink the old one
SwitchOverlayChange               tst       >vOvlCur
                    bne       SwitchOverlayUnlink
                    ldd       #WbWinStart
                    std       >vListEnd
                    os9       F$Mem
                    lblo      SwitchOverlayFatal
                    lbra      SwitchOverlayLink
* SwitchOverlayUnlink: SwitchOverlay: unlink current overlay and its fsd module
SwitchOverlayUnlink               ldu       >vOvlModule
                    os9       F$UnLink
                    lblo      SwitchOverlayFatal
                    tst       >vFsdModule
                    beq       SwitchOverlayUnlinked
                    ldu       >vFsdModule
                    os9       F$UnLink
                    lblo      SwitchOverlayFatal
                    clr       >vFsdModule
* SwitchOverlayUnlinked: SwitchOverlay: old one gone - link new or go to no-overlay state
SwitchOverlayUnlinked               lda       >vOvlReq
                    bne       SwitchOverlayLink
* SwitchOverlayNone: SwitchOverlay: no overlay - give $4000-$5FFF to data, load the data block
* WildBits: the window runs on to WbWinEnd through WbAScrn's block at $6000; FS's data memory still ends at $5FFF
SwitchOverlayNone               sta       >vOvlCur
                    ldd       #WbWinStart
                    std       >vListStart
                    ldd       #WbWinEnd
                    std       >vListEnd
                    ldd       #WbWin2
                    os9       F$Mem
                    blo       SwitchOverlayFatal
                    jmp       >LoadDataBlock+ModBase
* SwitchOverlayLink: SwitchOverlay: link module fN from TblOverlayNames
SwitchOverlayLink               lda       >vOvlReq
                    sta       >vOvlCur
                    deca
                    asla
                    ldx       #TblOverlayNames+ModBase
                    ldx       a,x
                    stx       >vOvlNamePtr
                    lda       #OvlTypeLang
                    ldx       >vOvlNamePtr
                    os9       F$Link
                    bhs       SwitchOverlayLinked
* SwitchOverlayLoad: SwitchOverlay: F$Load the overlay, retry after disk prompt on missing file errors
SwitchOverlayLoad               lda       #OvlTypeLang
                    ldx       >vOvlNamePtr
                    os9       F$Load
                    bhs       SwitchOverlayLinked
                    cmpb      #ErrPathNotFound
                    beq       SwitchOverlayAskDisk
                    cmpb      #ErrNotAccessible
                    beq       SwitchOverlayAskDisk
                    cmpb      #ErrBadSector
                    beq       SwitchOverlayAskDisk
                    cmpb      #ErrBadMediaType
                    beq       SwitchOverlayAskDisk
                    bra       SwitchOverlayFatal
* SwitchOverlayAskDisk: SwitchOverlay: prompt for disk; on abort fall back to no overlay
SwitchOverlayAskDisk               clra
                    jsr       >PromptProgDisk+ModBase
                    bne       SwitchOverlayLoad
                    clr       >vOvlReq
                    bra       SwitchOverlayNone
* SwitchOverlayLinked: SwitchOverlay: save entry/address, link fsd and load the data block
SwitchOverlayLinked               sty       >vOvlEntry
                    stu       >vOvlModule
                    ldd       #WbWinStart
                    std       >vListStart
                    std       >vListEnd
                    clr       >vFsdModule
                    lda       #FsdTypeLang
                    ldx       #StrFsdModName+ModBase
                    os9       F$Link
                    blo       SwitchOverlayEnter
                    sty       >vListStart
                    stu       >vFsdModule
                    tfr       u,d
                    addd      2,u
                    subd      #ModCrcLen
                    std       >vListEnd
                    jsr       >LoadDataBlock+ModBase
* SwitchOverlayEnter: SwitchOverlay: jump to the overlay entry [$021D]
SwitchOverlayEnter               jmp       [>vOvlEntry]
* SwitchOverlayFatal: SwitchOverlay: unrecoverable error - fatal system error
SwitchOverlayFatal               jsr       >FatalSystemError+ModBase
* LoadDataBlock: Read block $0249 of the data file named at $0250 (magic $DD01, 6-byte index) into $0247..$0244
LoadDataBlock               lda       #BlkNone
                    sta       >vBaseArea
                    sta       >vLoadSlot
                    inca
                    sta       >vLoadArea
                    ldd       >vListStart
                    std       >vLoadAddr
                    ldx       #vBlkCache
                    ldb       >vLoadSlot
                    lda       >vLoadArea
                    cmpa      b,x
                    bne       LoadDataBlockMark
                    rts
* LoadDataBlockMark: LoadDataBlock: record block in cache $024C and invalidate the rest
LoadDataBlockMark               sta       b,x
                    lda       #BlkNone
* LoadDataBlockInvLoop: LoadDataBlock: invalidate remaining cache slots
LoadDataBlockInvLoop               cmpb      #BlkCacheLast
                    beq       LoadDataBlockOpen
                    incb
                    sta       b,x
                    bra       LoadDataBlockInvLoop
* LoadDataBlockOpen: LoadDataBlock: open the file, prompt for disk if not found
LoadDataBlockOpen               lda       #OpenRead
* WildBits: ldx #$0250 in fsw, which marks the scenery window for the SceneEngine
                    jsr       >FswSeLoad
                    os9       I$Open
                    bhs       LoadDataBlockOpened
                    cmpb      #ErrPathNotFound
                    lbne      LoadDataBlockFail
                    clra
                    jsr       >PromptDataDisk+ModBase
                    lbeq      LoadDataBlockFail
                    bra       LoadDataBlockOpen
* LoadDataBlockOpened: LoadDataBlock: read header and index entry, seek and read the block
LoadDataBlockOpened               sta       >vFilePath
                    lda       >vFilePath
                    ldx       #SeekFileStart
                    tfr       x,u
                    os9       I$Seek
                    lblo      LoadDataBlockFail
                    lda       >vFilePath
                    ldx       #vFileHdr
                    ldy       #DataHdrLen
                    os9       I$Read
                    lblo      LoadDataBlockFail
                    ldd       >vSfMagic
                    cmpd      #DataFileMagic
                    lbne      LoadDataBlockFail
                    lda       >vLoadArea
                    inca
                    cmpa      >vSfAreaCount
                    lbhi      LoadDataBlockFail
                    deca
                    ldb       #DataIdxLen
                    mul
                    addd      #DataHdrLen
                    tfr       d,u
                    ldx       #SeekIndexHi
                    lda       >vFilePath
                    os9       I$Seek
                    lda       >vFilePath
                    ldx       #vFileHdr
                    ldy       #DataIdxLen
                    os9       I$Read
                    lblo      LoadDataBlockFail
                    lda       >vFilePath
                    ldx       >vIdxOffset
                    ldu       >vIdxOffset+2
                    os9       I$Seek
                    lblo      LoadDataBlockFail
                    ldd       >vLoadAddr
                    addd      >vIdxLength
                    cmpd      >vListEnd
                    bhs       LoadDataBlockTooBig
                    ldx       >vLoadAddr
                    ldy       >vIdxLength
                    lda       >vFilePath
                    os9       I$Read
                    blo       LoadDataBlockFail
                    lda       >vFilePath
                    os9       I$Close
                    blo       LoadDataBlockFail
                    rts
* LoadDataBlockTooBig: LoadDataBlock: block does not fit - error $0B
LoadDataBlockTooBig               ldb       #ErrBlockTooBig
* LoadDataBlockFail: LoadDataBlock: error B - invalidate slot and fill buffer with $0079
LoadDataBlockFail               pshs      b
                    ldx       #vBlkCache
                    ldb       >vLoadSlot
                    lda       #BlkNone
                    sta       b,x
                    ldx       >vLoadAddr
                    lda       >vViewMZZ+1
* LoadDataBlockFillLoop: LoadDataBlockFail: buffer fill loop
LoadDataBlockFillLoop               sta       ,x+
                    cmpx      >vListEnd
                    blo       LoadDataBlockFillLoop
                    puls      b
                    rts
* PromptProgDisk: Show message $115C on the text screen and wait for a key (probably insert program disk); Z if key $90
PromptProgDisk               ldx       #vFsDiskMsg
                    ldy       #FsDiskMsgLen
                    bra       ShowTextMsgWaitKey
* PromptDataDisk: Show message $11BE on the text screen and wait for a key (probably insert data disk); Z if key $90
PromptDataDisk               ldx       #vSceneryDiskMsg
                    ldy       #SceneryDiskMsgLen
* ShowTextMsgWaitKey: Switch to text screen, write X/Y message, wait for a key, restore graphics unless A<>0; Z if key $90
ShowTextMsgWaitKey               pshs      a
                    pshs      x,y
                    lda       >FsPath
                    ldy       #DScrnText
                    jsr       >WbDScrn+ModBase            WildBits SS.DScrn (fs_wb.asm)
                    nop
                    nop
                    lda       >FsPath
                    puls      x,y
                    os9       I$Write
* ShowTextMsgKeyLoop: ShowTextMsgWaitKey: key wait loop
ShowTextMsgKeyLoop               jsr       >PollKey+ModBase
                    beq       ShowTextMsgKeyLoop
                    puls      a
                    pshs      b
                    tsta
                    bne       ShowTextMsgDone
                    jsr       >WriteTermResetStr+ModBase
                    lda       >FsPath
                    ldy       >WbScrBlks
                    jsr       >WbDScrn+ModBase            WildBits SS.DScrn (fs_wb.asm)
                    nop
                    nop
* ShowTextMsgDone: ShowTextMsgWaitKey: compare key with $90 and return
ShowTextMsgDone               puls      b
                    cmpb      #KeyQuit
                    rts
* FatalSystemError: Show Fatal System Error with address and error code in hex, wait for key $90, exit via QuitProgram
FatalSystemError               jsr       >ByteToHexAscii+ModBase
                    std       >vFatalCode
                    puls      b
                    jsr       >ByteToHexAscii+ModBase
                    std       >vFatalAddr
                    puls      b
                    jsr       >ByteToHexAscii+ModBase
                    std       >vFatalAddr+2
                    lda       >FsPath
                    ldx       #MsgFatalSysError+ModBase
                    ldy       #FatalMsgLen
                    os9       I$Write
                    lda       >FsPath
                    ldx       #vFatalAddrHex
                    ldy       #HexWordLen
                    os9       I$Write
                    lda       >FsPath
                    ldx       #MsgFatalCode+ModBase
                    ldy       #FatalCodeMsgLen
                    os9       I$Write
                    lda       >FsPath
                    ldx       #vFatalCodeHex
                    ldy       #HexByteLen
                    os9       I$Write
                    lda       >FsPath
                    ldy       #DScrnText
                    jsr       >WbDScrn+ModBase            WildBits SS.DScrn (fs_wb.asm)
                    nop
                    nop
* FatalSystemErrorWait: FatalSystemError: wait for key $90
FatalSystemErrorWait               jsr       >PollKey+ModBase
                    beq       FatalSystemErrorWait
                    cmpb      #KeyQuit
                    bne       FatalSystemErrorWait
                    jmp       >QuitProgram+ModBase
* ByteToHexAscii: B -> two ASCII hex digits in D
ByteToHexAscii               tfr       b,a
                    lsra
                    lsra
                    lsra
                    lsra
                    andb      #HexLoDigit
                    addd      #AsciiZeros
                    cmpa      #AsciiNine
                    bls       ByteToHexLow
                    adda      #HexLetterGap
* ByteToHexLow: ByteToHexAscii: low digit adjust
ByteToHexLow               cmpb      #AsciiNine
                    bls       ByteToHexDone
                    addb      #HexLetterGap
* ByteToHexDone: ByteToHexAscii: return
ByteToHexDone               rts
* MoveThrottleMarker: A=new position: XOR-move panel marker $0806 at (col $36,row $51) (probably throttle, from $0837)
MoveThrottleMarker               ldb       >vThrottleMark
                    sta       >vThrottleMark
                    std       >vMarkerNew
                    ldd       #ThrottleMarkBase
                    std       <vMarkerPos
                    lda       #ThrottleMarkRows
                    jmp       >MoveVertMarker+ModBase
* InitThrottleMarker: Draw marker $0806 at position 0 (probably throttle)
InitThrottleMarker               lda       #ThrottleMarkIdle
                    sta       >vMarkerNew
                    sta       >vThrottleMark
                    ldd       #ThrottleMarkBase
                    std       <vMarkerPos
                    lda       #ThrottleMarkRows
                    jmp       >DrawVertMarker+ModBase
                    fcb       $80,$0A,$40,$F6,$08,$08,$B7,$08
                    fcb       $08,$FD,$02,$05,$CC,$36,$24,$DD
                    fcb       $20,$86,$02,$7E,$C0,$B3
* InitElevTrimMarker: Draw marker $0808 at its middle position 5, col $36 row $24 (probably elevator trim)
InitElevTrimMarker               lda       #TrimMarkMid
                    sta       >vMarkerNew
                    sta       >vTrimMark
                    ldd       #TrimMarkBase
                    std       <vMarkerPos
                    lda       #TrimMarkRows
                    jmp       >DrawVertMarker+ModBase
                    fcb       $80,$06,$40,$F6,$08,$07,$B7,$08
                    fcb       $07,$FD,$02,$05,$CC,$36,$10,$DD
                    fcb       $20,$86,$01,$7E,$C0,$B3
* InitFlapsMarker: Draw marker $0807 at position 6, col $36 row $10 (probably flaps)
InitFlapsMarker               lda       #FlapsMarkUp
                    sta       >vMarkerNew
                    sta       >vFlapsMark
                    ldd       #FlapsMarkBase
                    std       <vMarkerPos
                    lda       #FlapsMarkRows
                    jmp       >DrawVertMarker+ModBase
* UpdOilTempGauge: If <$EC bit6 and $0739 changed: move gauge marker $080C at ($41,$15) (probably oil temperature)
UpdOilTempGauge               lda       <vInstActive2
                    anda      #InstOilGauges
                    beq       UpdOilGaugeDone
                    lda       >vOilTemp
                    cmpa      >vOilTempMark
                    beq       UpdOilGaugeDone
                    ldb       >vOilTempMark
                    sta       >vOilTempMark
                    std       >vMarkerNew
                    ldd       #OilTempMarkBase
                    std       <vMarkerPos
                    lda       #GaugeMarkRows
                    clrb
                    jmp       >MoveSlideMarker+ModBase
* InitOilTempGauge: Draw oil temperature gauge marker at 0
InitOilTempGauge               lda       #GaugeMarkMin
                    sta       >vMarkerNew
                    sta       >vOilTempMark
                    ldd       #OilTempMarkBase
                    std       <vMarkerPos
                    lda       #GaugeMarkRows
                    clr       <vMarkerWide
                    lbra      DrawSlideMarker
* UpdOilGaugeDone: Shared return of the oil gauge routines
UpdOilGaugeDone               rts
* UpdOilPressGauge: If <$EC bit6 and $073B changed: move gauge marker $080D at ($49,$15) (probably oil pressure)
UpdOilPressGauge               lda       <vInstActive2
                    anda      #InstOilGauges
                    beq       UpdOilGaugeDone
                    lda       >vOilPress
                    cmpa      >vOilPressMark
                    beq       UpdOilGaugeDone
                    ldb       >vOilPressMark
                    sta       >vOilPressMark
                    std       >vMarkerNew
                    ldd       #OilPressMarkBase
                    std       <vMarkerPos
                    lda       #GaugeMarkRows
                    clrb
                    jmp       >MoveSlideMarker+ModBase
* InitOilPressGauge: Draw oil pressure gauge marker at 0
InitOilPressGauge               lda       #GaugeMarkMin
                    sta       >vMarkerNew
                    sta       >vOilPressMark
                    ldd       #OilPressMarkBase
                    std       <vMarkerPos
                    lda       #GaugeMarkRows
                    clr       <vMarkerWide
                    lbra      DrawSlideMarker
* DrawFuelTankSel: If <$EC bit5: draw selector glyph at col $84 or $99 by $0735, erase the other (probably fuel tank selector)
DrawFuelTankSel               lda       <vInstActive2
                    anda      #InstFuelGauges
                    beq       UpdOilGaugeDone
                    ldd       #TxtBlack
                    std       >vTextColor
                    ldu       >vPanelScr
                    ldy       #FuelSelTank1
                    tst       >vFuelTank
                    bne       DrawFuelTankSelErase
                    ldy       #FuelSelTank2
* DrawFuelTankSelErase: DrawFuelTankSel: erase glyph at the unselected tank
DrawFuelTankSelErase               ldb       #FuelSelGlyph
                    jsr       >DrawGlyph+ModBase
                    ldd       #TxtYellow
                    std       >vTextColor
                    ldu       >vPanelScr
                    ldy       #FuelSelTank2
                    tst       >vFuelTank
                    bne       DrawFuelTankSelDraw
                    ldy       #FuelSelTank1
* DrawFuelTankSelDraw: DrawFuelTankSel: draw glyph at the selected tank
DrawFuelTankSelDraw               ldb       #FuelSelGlyph
                    jmp       >DrawGlyph+ModBase
* UpdFuelGauge1: If <$EC bit5 and $0731/4 changed: move gauge marker $080A at ($42,$0B) (probably fuel tank 1)
UpdFuelGauge1               lda       <vInstActive2
                    anda      #InstFuelGauges
                    beq       UpdFuelGaugeDone
                    lda       >vFuelL
                    asra
                    asra
                    cmpa      >vFuelLMark
                    beq       UpdFuelGaugeDone
                    ldb       >vFuelLMark
                    sta       >vFuelLMark
                    std       >vMarkerNew
                    ldd       #Fuel1MarkBase
                    std       <vMarkerPos
                    lda       #GaugeMarkRows
                    clrb
                    jmp       >MoveSlideMarker+ModBase
* InitFuelGauge1: Draw fuel tank 1 gauge marker at $0731/4
InitFuelGauge1               lda       >vFuelL
                    lsra
                    lsra
                    sta       >vMarkerNew
                    sta       >vFuelLMark
                    ldd       #Fuel1MarkBase
                    std       <vMarkerPos
                    lda       #GaugeMarkRows
* InitFuelGauge1Draw: InitFuelGauge1: draw step (address also used only as color constant $BBBB by PrintPanelTextB)
InitFuelGauge1Draw               clr       <vMarkerWide
                    jmp       >DrawSlideMarker+ModBase
* UpdFuelGauge2: If <$EC bit5 and $0734/4 changed: move gauge marker $080B at ($4A,$0B) (probably fuel tank 2)
UpdFuelGauge2               lda       <vInstActive2
                    anda      #InstFuelGauges
                    beq       UpdFuelGaugeDone
                    lda       >vFuelR
                    asra
                    asra
                    cmpa      >vFuelRMark
                    beq       UpdFuelGaugeDone
                    ldb       >vFuelRMark
                    sta       >vFuelRMark
                    std       >vMarkerNew
                    ldd       #Fuel2MarkBase
                    std       <vMarkerPos
                    lda       #GaugeMarkRows
                    clrb
                    jmp       >MoveSlideMarker+ModBase
* InitFuelGauge2: Draw fuel tank 2 gauge marker at $0734/4
InitFuelGauge2               lda       >vFuelR
                    lsra
                    lsra
                    sta       >vMarkerNew
                    sta       >vFuelRMark
                    ldd       #Fuel2MarkBase
                    std       <vMarkerPos
                    lda       #GaugeMarkRows
                    clr       <vMarkerWide
                    jmp       >DrawSlideMarker+ModBase
* UpdFuelGaugeDone: Shared return of the fuel gauge and altimeter routines
UpdFuelGaugeDone               rts
