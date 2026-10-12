* The original attract instruction scroll and HIGH SCORES list ($85B1..$882A).
* The original shifts its font in character RAM to rise one pixel every four
* frames; here the whole page is laid into its own tile map (blocks 4-5,
* font in tile set 2) and the VICKY Y scroll moves it. A text line is 16
* pixels: code c in the lower tile row, c+1 above it. When the text ends the
* colors redden for 7 ticks, hold 256 frames, darken, stay black 120 frames.
* X = game, U = process throughout.

* Build and show the page. Credits pick the original's credits variant.
BeginScrollPage  pshs      d,x,y
                    lda       GS_CreditsBCD,x
                    sta       GS_ScrollCredits,x
                    lda       #TV_FontBlock
                    lbsr      TileMapBlock
                    lbcs      PageFail
                    ldb       #SCROLL_FONT_FIRST
PageFontGlyph    pshs      b
                    subb      #SCROLL_FONT_FIRST
                    lda       #G80_GLYPH_BYTES
                    mul
                    leay      ScrollFont0,pcr
                    leay      d,y
                    leax      AD_TileWork,u
                    ldd       0,y
                    std       0,x
                    ldd       2,y
                    std       2,x
                    ldd       4,y
                    std       4,x
                    ldd       6,y
                    std       6,x
                    leay      SCROLL_FONT_BYTES,y ; ScrollFont1 follows ScrollFont0
                    ldd       0,y
                    std       8,x
                    ldd       2,y
                    std       10,x
                    ldd       4,y
                    std       12,x
                    ldd       6,y
                    std       14,x
                    ldb       ,s
                    lbsr      TileConvertWork
                    puls      b
                    incb
                    cmpb      #SCROLL_FONT_FIRST+SCROLL_FONT_GLYPHS
                    blo       PageFontGlyph
* The original's space $78 (and $79 above it) lie outside the font: pen 0.
                    leax      AD_TileWork,u
                    ldb       #16
PageClearWork    clr       ,x+
                    decb
                    bne       PageClearWork
                    ldb       #TV_PageBlank
                    lbsr      TileConvertWork
                    ldb       #TV_PageBlank+1
                    lbsr      TileConvertWork
                    lbsr      ReleaseDisplayMapping
* Blue background, yellow text in every color group.
                    ldx       2,s       stack offset: saved game base
                    leay      GS_PaletteSource,x
                    ldb       #16
PagePalette      lda       #$3F      complement of $C0
                    sta       ,y+
                    lda       #$C0      complement of $3F
                    sta       ,y+
                    lda       #$FF
                    sta       ,y+
                    lda       #$C0
                    sta       ,y+
                    decb
                    bne       PagePalette
                    lda       #$FF
                    sta       GS_PaletteDirty,x
* Lay the text into the page map.
                    leay      ScrollText,pcr
                    tst       GS_CreditsBCD,x
                    beq       PageHaveText
                    leay      ScrollCreditText,pcr
PageHaveText     sty       AD_PageText,u
                    lda       #$FF
                    sta       AD_PageBlock,u
                    clr       AD_PageOffset,u
                    clr       AD_PageOffset+1,u
                    clr       AD_PageLines,u
                    clr       AD_PageRows,u
PagePadRow       lda       AD_PageRows,u
                    cmpa      #TV_PageTop
                    bhs       PageTextLines
                    lbsr      PageBlankRow
                    ldx       2,s
                    tst       GS_ScrollCredits,x
                    beq       PageEmitPad
                    lda       AD_PageRows,u ; credits word at original column 8
                    cmpa      #TV_PageTop-9 ; upper half (column 9)
                    beq       PageCreditRow
                    cmpa      #TV_PageTop-8 ; lower half (column 8)
                    bne       PageEmitPad
PageCreditRow    lbsr      PageCreditGlyphs
                    lda       AD_PageRows,u
                    suba      #TV_PageTop-9 ; 0 upper, 1 lower
                    eora      #1
                    lbsr      PageGlyphRow
PageEmitPad      lbsr      PageEmitRow
                    bra       PagePadRow
PageTextLines    ldy       AD_PageText,u
                    lda       ,y
                    cmpa      #$FF
                    beq       PageTail
                    lbsr      PageParseLine
                    sty       AD_PageText,u
                    inc       AD_PageLines,u
                    lda       #1
                    lbsr      PageGlyphRow
                    lbsr      PageEmitRow
                    clra
                    lbsr      PageGlyphRow
                    lbsr      PageEmitRow
                    bra       PageTextLines
PageTail         lda       #TV_PageTail
                    sta       AD_PageLeft,u
PageTailRow      lbsr      PageBlankRow
                    lbsr      PageEmitRow
                    dec       AD_PageLeft,u
                    bne       PageTailRow
                    lbsr      ReleaseDisplayMapping
* Point tile map 0 at the page.
                    leax      AD_TileRecord,u
                    ldd       #TV_MapControl*256
                    std       ,x
                    ldd       AP_FirstBlock,u
                    addd      #TV_PageMapBlock
                    stb       1,x
                    ldd       #0
                    std       2,x
                    ldd       #TV_MapCols
                    std       4,x
                    clra
                    ldb       AD_PageRows,u
                    std       6,x
                    ldd       #0
                    std       8,x
                    std       10,x
                    ldy       #0
                    lda       #ASTRO_OUTPUT_PATH
                    ldb       #SS.TmSet
                    os9       I$SetStt
* Start rising: 16 pixels a line, ending 16 below the last line.
                    ldx       2,s
                    clr       GS_ScrollPixels,x
                    clr       GS_ScrollPixels+1,x
                    lda       AD_PageLines,u
                    inca
                    ldb       #16
                    mul
                    std       GS_ScrollEnd,x
                    clr       GS_ScrollHold,x
                    tst       GS_ScrollCredits,x
                    beq       PageNoHold
                    lda       #PAGE_CREDIT_HOLD
                    sta       GS_ScrollHold,x
PageNoHold       ldd       #4
                    std       GS_TitleClock,x
                    lda       #PAGE_SCROLL
                    sta       GS_AttractPage,x
                    puls      d,x,y,pc
PageFail         puls      d,x,y
                    lbra      EndAttractPages

* AD_PageRow = a blank row: black margins, pen-0 cells across the playfield.
PageBlankRow     leax      AD_PageRow,u
                    ldb       #TV_FirstMapCol
                    ldy       #TV_BlankAttr
PageBlankLeft    sty       ,x++
                    decb
                    bne       PageBlankLeft
                    ldb       #G80_VISIBLE_TILE_ROWS
                    ldy       #TV_PageBlank*256+TV_PageAttr
PageBlankMid     sty       ,x++
                    decb
                    bne       PageBlankMid
                    ldb       #TV_MapCols-TV_FirstMapCol-G80_VISIBLE_TILE_ROWS
                    ldy       #TV_BlankAttr
PageBlankRight   sty       ,x++
                    decb
                    bne       PageBlankRight
                    rts

* A = 1 upper (c+1) or 0 lower (c) half: AD_PageGlyphs into AD_PageRow.
PageGlyphRow     pshs      a
                    leax      AD_PageGlyphs,u
                    leay      AD_PageRow+TV_FirstMapCol*2,u
                    ldb       #G80_VISIBLE_TILE_ROWS
PageGlyphCell    lda       ,x+
                    cmpa      #TV_PageBlank
                    beq       PageGlyphStore
                    adda      ,s
PageGlyphStore   sta       ,y++
                    decb
                    bne       PageGlyphCell
                    puls      a,pc

* Blank glyph line.
PageClearGlyphs  leax      AD_PageGlyphs,u
                    ldb       #G80_VISIBLE_TILE_ROWS
                    lda       #TV_PageBlank
PageClearGlyph   sta       ,x+
                    decb
                    bne       PageClearGlyph
                    rts

* Y = text: one line ($00-ended codes, or a $8n high-score slot) into
* AD_PageGlyphs. Exit Y past it.
PageParseLine    lbsr      PageClearGlyphs
                    lda       ,y
                    anda      #$E0
                    cmpa      #$80
                    beq       PageSlot
                    leax      AD_PageGlyphs,u
                    ldb       #G80_VISIBLE_TILE_ROWS
PageParseCode    lda       ,y+
                    beq       PageParseDone
                    tstb
                    beq       PageParseCode
                    sta       ,x+
                    decb
                    bra       PageParseCode
PageParseDone    rts
* Original $87B4: initials at columns 8-10, score digits 13-16 and a 0 at 17;
* an empty (zero) score leaves a blank line.
PageSlot         ldb       ,y
                    andb      #$1F
                    leay      2,y
                    pshs      b,y       stack offset 0: slot n, 1: next text
                    lslb
                    leax      AD_Game+GS_HighScores,u
                    abx
                    ldd       ,x        A = low BCD byte, B = high (little-endian)
                    std       AD_PageScore,u
                    bne       PageSlotScore
                    puls      b,y,pc
PageSlotScore    leay      AD_PageGlyphs,u
                    lda       AD_PageScore+1,u
                    lbsr      PageDigitPair
                    sta       13,y
                    stb       14,y
                    lda       AD_PageScore,u
                    lbsr      PageDigitPair
                    sta       15,y
                    stb       16,y
                    lda       #$44      the trailing 0
                    sta       17,y
                    ldb       ,s
                    lslb
                    lslb                4n
                    leax      AD_Game+GS_Initials,u
                    abx
                    leay      AD_PageGlyphs+8,u
                    ldb       #3
PageSlotLetter   lda       ,x+
                    suba      #$4A      game alphabet A = $4A
                    lsla
                    adda      #$10      page font A = $10
                    sta       ,y+
                    decb
                    bne       PageSlotLetter
                    puls      b,y,pc

* A = packed BCD: A = glyph of the high digit, B = glyph of the low digit.
PageDigitPair    tfr       a,b
                    andb      #15
                    lslb
                    addb      #$44
                    lsra
                    lsra
                    lsra
                    lsra
                    lsla
                    adda      #$44
                    rts

* Credits variant: "CREDITS" and two digits at original rows 8-17.
PageCreditGlyphs lbsr      PageClearGlyphs
                    leax      ScrollCreditsWord,pcr
                    leay      AD_PageGlyphs+8,u
                    ldb       #7
PageCreditLetter lda       ,x+
                    sta       ,y+
                    decb
                    bne       PageCreditLetter
                    lda       AD_Game+GS_CreditsBCD,u
                    lbsr      PageDigitPair
                    sta       AD_PageGlyphs+16,u
                    stb       AD_PageGlyphs+17,u
                    rts

* Append AD_PageRow to the page map, mapping each 8K block as it is reached.
PageEmitRow      leay      AD_PageRow,u
                    ldb       #TV_MapCols*2
PageEmitByte     pshs      b
                    lda       AD_PageOffset,u
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra
                    cmpa      AD_PageBlock,u
                    beq       PageEmitMapped
                    sta       AD_PageBlock,u
                    lbsr      ReleaseDisplayMapping
                    lda       AD_PageBlock,u
                    adda      #TV_PageMapBlock
                    lbsr      TileMapBlock
PageEmitMapped   ldd       AD_PageOffset,u
                    anda      #$1F
                    ldx       AP_MapAddress,u
                    leax      d,x
                    lda       ,y+
                    sta       ,x
                    ldd       AD_PageOffset,u
                    addd      #1
                    std       AD_PageOffset,u
                    puls      b
                    decb
                    bne       PageEmitByte
                    inc       AD_PageRows,u
                    rts

* One tick of the page. Original $86C5/$86D2: a credit change restarts it.
UpdatePages      lda       GS_CreditsBCD,x
                    cmpa      GS_ScrollCredits,x
                    lbne      BeginScrollPage
                    lda       GS_AttractPage,x
                    cmpa      #PAGE_SCROLL
                    beq       PageRise
                    cmpa      #PAGE_REDDEN
                    beq       PageRedden
                    cmpa      #PAGE_HOLD
                    lbeq      PageHold
                    cmpa      #PAGE_DARKEN
                    lbeq      PageDarken
                    lbra      PageBlack
PageRise         tst       GS_ScrollHold,x
                    beq       PageRiseTick
                    dec       GS_ScrollHold,x
                    rts
PageRiseTick     lbsr      PageEveryFour
                    bne       PageReturn
                    lbsr      PageStep
                    ldd       GS_ScrollPixels,x
                    cmpd      GS_ScrollEnd,x
                    blo       PageReturn
                    lda       #PAGE_REDDEN
                    sta       GS_AttractPage,x
                    lda       #7
                    sta       GS_AttractStep,x
PageReturn       rts
* Original $882A: background toward red, text toward black, still rising.
PageRedden       lbsr      PageEveryFour
                    bne       PageReturn
                    lbsr      PageStep
                    leay      GS_PaletteSource,x
                    ldb       #16
PageReddenGroup  lda       ,y
                    coma
                    beq       PageReddenText
                    suba      #$40
                    inca
                    coma
                    sta       ,y
PageReddenText   lda       1,y
                    coma
                    beq       PageReddenNext
                    suba      #9
                    coma
                    sta       1,y
                    sta       3,y
PageReddenNext   leay      4,y
                    decb
                    bne       PageReddenGroup
                    lda       #$FF
                    sta       GS_PaletteDirty,x
                    dec       GS_AttractStep,x
                    bne       PageReturn
                    lda       #PAGE_HOLD
                    sta       GS_AttractPage,x
                    ldd       #256
                    std       GS_TitleClock,x
                    rts
PageHold         ldd       GS_TitleClock,x
                    subd      #1
                    std       GS_TitleClock,x
                    bne       PageReturn
                    lda       #PAGE_DARKEN
                    sta       GS_AttractPage,x
                    ldd       #6
                    std       GS_TitleClock,x
                    rts
* Original $85BB: the background loses one red step every 6 frames.
PageDarken       ldd       GS_TitleClock,x
                    subd      #1
                    std       GS_TitleClock,x
                    bne       PageReturn
                    ldd       #6
                    std       GS_TitleClock,x
                    leay      GS_PaletteSource,x
                    lda       ,y
                    coma
                    beq       PageDark
                    ldb       #16
PageDarkenGroup  lda       ,y
                    coma
                    beq       PageDarkenNext
                    deca
                    coma
                    sta       ,y
PageDarkenNext   leay      4,y
                    decb
                    bne       PageDarkenGroup
                    lda       #$FF
                    sta       GS_PaletteDirty,x
                    rts
PageDark         lda       #PAGE_BLACK
                    sta       GS_AttractPage,x
                    ldd       #120
                    std       GS_TitleClock,x
                    rts
PageBlack        ldd       GS_TitleClock,x
                    subd      #1
                    std       GS_TitleClock,x
                    lbne       PageReturn
                    tst       GS_CreditsBCD,x
                    lbne      BeginScrollPage
                    lbsr      EndAttractPages
                    leay      AD_Video,u
                    lbra      BeginAttractDemo

* Z set once every four calls.
PageEveryFour    ldd       GS_TitleClock,x
                    subd      #1
                    std       GS_TitleClock,x
                    bne       PageFourReturn
                    ldd       #4
                    std       GS_TitleClock,x
                    clra                set Z
PageFourReturn   rts

* Rise one pixel: Y window = pixels/8 in bits 13:4, fine scroll bits 2:0.
PageStep         ldd       GS_ScrollPixels,x
                    addd      #1
                    std       GS_ScrollPixels,x
                    pshs      x
                    andb      #$F8
                    lslb
                    rola
                    pshs      d
                    ldx       2,s       stack offset: saved game base
                    ldb       GS_ScrollPixels+1,x
                    andb      #7
                    orb       1,s
                    stb       1,s
                    ldx       #0
                    ldy       #0
                    pshs      u
                    ldu       2,s       stack offset past saved U: Y word
                    lda       #ASTRO_OUTPUT_PATH
                    ldb       #SS.TmScrl
                    os9       I$SetStt
                    puls      u
                    leas      2,s
                    puls      x,pc

* Leave the pages: game tile map back, game screen rebuilt. Preserve X,U.
EndAttractPages  clr       GS_AttractPage,x
                    pshs      x
                    lbsr      SetGameTileMap
                    puls      x
                    lbra      RestoreGameScreen
