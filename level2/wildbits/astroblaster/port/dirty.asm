* U is the process base. Cached glyphs are rotated 2-bpp, 16 bytes each.
* Detect exact glyph/cell changes; dirty flags persist until drawing succeeds.
DetectVideoChanges
                    pshs      d,x,y
                    leas      -DC_FrameBytes,s
                    clr       DC_Glyph,s
                    leax      AD_Video+G80_PLANE0_OFFSET,u
                    leay      AD_PreviousVideo+G80_VISIBLE_TILES,u
DetectNextGlyph  tst       AD_CacheValid,u
                    beq       DetectChangedGlyph
                    ldd       0,x
                    cmpd      0,y
                    bne       DetectChangedGlyph
                    ldd       2,x
                    cmpd      2,y
                    bne       DetectChangedGlyph
                    ldd       4,x
                    cmpd      4,y
                    bne       DetectChangedGlyph
                    ldd       6,x
                    cmpd      6,y
                    bne       DetectChangedGlyph
                    ldd       G80_PLANE_SPACING+0,x
                    cmpd      2048,y
                    bne       DetectChangedGlyph
                    ldd       G80_PLANE_SPACING+2,x
                    cmpd      2050,y
                    bne       DetectChangedGlyph
                    ldd       G80_PLANE_SPACING+4,x
                    cmpd      2052,y
                    bne       DetectChangedGlyph
                    ldd       G80_PLANE_SPACING+6,x
                    cmpd      2054,y
                    bne       DetectChangedGlyph
                    clra
                    lbra      DetectGlyphFlag
DetectChangedGlyph
                    clr DC_Mask,s
                    lda 0,x
                    eora 0,y
                    ora DC_Mask,s
                    sta DC_Mask,s
                    lda G80_PLANE_SPACING+0,x
                    eora 2048+0,y
                    ora DC_Mask,s
                    sta DC_Mask,s
                    lda 1,x
                    eora 1,y
                    ora DC_Mask,s
                    sta DC_Mask,s
                    lda G80_PLANE_SPACING+1,x
                    eora 2048+1,y
                    ora DC_Mask,s
                    sta DC_Mask,s
                    lda 2,x
                    eora 2,y
                    ora DC_Mask,s
                    sta DC_Mask,s
                    lda G80_PLANE_SPACING+2,x
                    eora 2048+2,y
                    ora DC_Mask,s
                    sta DC_Mask,s
                    lda 3,x
                    eora 3,y
                    ora DC_Mask,s
                    sta DC_Mask,s
                    lda G80_PLANE_SPACING+3,x
                    eora 2048+3,y
                    ora DC_Mask,s
                    sta DC_Mask,s
                    lda 4,x
                    eora 4,y
                    ora DC_Mask,s
                    sta DC_Mask,s
                    lda G80_PLANE_SPACING+4,x
                    eora 2048+4,y
                    ora DC_Mask,s
                    sta DC_Mask,s
                    lda 5,x
                    eora 5,y
                    ora DC_Mask,s
                    sta DC_Mask,s
                    lda G80_PLANE_SPACING+5,x
                    eora 2048+5,y
                    ora DC_Mask,s
                    sta DC_Mask,s
                    lda 6,x
                    eora 6,y
                    ora DC_Mask,s
                    sta DC_Mask,s
                    lda G80_PLANE_SPACING+6,x
                    eora 2048+6,y
                    ora DC_Mask,s
                    sta DC_Mask,s
                    lda 7,x
                    eora 7,y
                    ora DC_Mask,s
                    sta DC_Mask,s
                    lda G80_PLANE_SPACING+7,x
                    eora 2048+7,y
                    ora DC_Mask,s
                    sta DC_Mask,s
                    ldd       0,x
                    std       0,y
                    ldd       2,x
                    std       2,y
                    ldd       4,x
                    std       4,y
                    ldd       6,x
                    std       6,y
                    ldd       G80_PLANE_SPACING+0,x
                    std       2048,y
                    ldd       G80_PLANE_SPACING+2,x
                    std       2050,y
                    ldd       G80_PLANE_SPACING+4,x
                    std       2052,y
                    ldd       G80_PLANE_SPACING+6,x
                    std       2054,y
                    pshs      x,y
                    ldb       DC_Glyph+4,s ; stack offset past saved X/Y
                    clra
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    leay      AD_GlyphCache,u
                    leay      d,y
                    lbsr      CacheRotatedGlyph
                    lbsr      FeedSpeech
                    puls      x,y
                    lda       DC_Mask,s
DetectGlyphFlag pshs a,y
                    ldb DC_Glyph+3,s ; stack offset past A/Y
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    leay AD_PaletteGroups,u
                    tst b,y
                    beq DetectSamePaletteGroup
                    lda #$FF
                    sta ,s          stack offset: glyph dirty result
DetectSamePaletteGroup puls a,y
                    pshs      y
                    leay      AD_DirtyGlyphs,u
                    ldb       DC_Glyph+2,s ; stack offset past saved Y
                    pshs      a
                    clra
                    leay      d,y
                    puls      a
                    sta       ,y
                    puls      y
                    leax      8,x
                    leay      8,y
                    inc       DC_Glyph,s
                    lbne      DetectNextGlyph
                    lda       #1
                    sta       AD_CacheValid,u
                    leax      AD_Video,u
                    leay      AD_PreviousVideo,u
                    leas      DC_FrameBytes,s
                    pshs u
                    leau AD_DirtyCells,u
                    leax G80_VISIBLE_TILES,x
                    pshs x          stack offset 0: tile-map end; 2: process base
                    leax -G80_VISIBLE_TILES,x
                    ldd 2,s
                    addd #AD_DirtyGlyphs
                    pshs d          stack offset 0: dirty glyph base; 2: tile end
DetectNextCell   ldb ,x+
                    cmpb ,y
                    bne DetectDifferentTile
                    pshs x
                    ldx 2,s         stack offset past saved X: dirty glyph base
                    clra
                    lda d,x
                    puls x
                    tsta
                    beq DetectCellUnchanged
                    bra DetectChangedCell
DetectDifferentTile lda #$FF
DetectChangedCell ora ,u
                    sta ,u
                    pshs d,x
                    tfr x,d
                    subd 6,s        stack offset: end of tile map
                    decb
                    andb #31
                    ldx 8,s         stack offset: process base
                    leax AD_DirtyColumns,x
                    abx
                    lda #1
                    sta ,x
                    puls d,x
DetectCellUnchanged stb ,y+
                    leau 1,u
                    cmpx 2,s        stack offset: tile-map end
                    bne DetectNextCell
                    leas 4,s
                    puls u
                    leax AD_PaletteGroups,u
                    ldb #16
DetectClearGroups clr ,x+
                    decb
                    bne DetectClearGroups
                    puls d,x,y,pc

* X = two-plane glyph, Y = its 16-byte rotated cache. Preserve X/Y/U.
CacheRotatedGlyph pshs d,x,y
                    leas -GC_FrameBytes,s
                    ldd 0,x
                    std GC_Low+0,s
                    ldd G80_PLANE_SPACING+0,x
                    std GC_High+0,s
                    ldd 2,x
                    std GC_Low+2,s
                    ldd G80_PLANE_SPACING+2,x
                    std GC_High+2,s
                    ldd 4,x
                    std GC_Low+4,s
                    ldd G80_PLANE_SPACING+4,x
                    std GC_High+4,s
                    ldd 6,x
                    std GC_Low+6,s
                    ldd G80_PLANE_SPACING+6,x
                    std GC_High+6,s
                    ldb #8
                    stb GC_Columns,s
CacheGlyphColumn
                    clra
                    lsl GC_High+0,s
                    rola
                    lsl GC_Low+0,s
                    rola
                    lsl GC_High+1,s
                    rola
                    lsl GC_Low+1,s
                    rola
                    lsl GC_High+2,s
                    rola
                    lsl GC_Low+2,s
                    rola
                    lsl GC_High+3,s
                    rola
                    lsl GC_Low+3,s
                    rola
                    sta ,y+
                    clra
                    lsl GC_High+4,s
                    rola
                    lsl GC_Low+4,s
                    rola
                    lsl GC_High+5,s
                    rola
                    lsl GC_Low+5,s
                    rola
                    lsl GC_High+6,s
                    rola
                    lsl GC_Low+6,s
                    rola
                    lsl GC_High+7,s
                    rola
                    lsl GC_Low+7,s
                    rola
                    sta ,y+
                    dec GC_Columns,s
                    bne CacheGlyphColumn
                    leas GC_FrameBytes,s
                    puls d,x,y,pc

InvalidatePortraitFrame
                    pshs      d,x,y
                    leax AD_DirtyColumns,u
                    ldb #32
                    lda #1
InvalidateStrip sta ,x+
                    decb
                    bne InvalidateStrip
                    leax      AD_DirtyCells,u
                    ldy       #G80_VISIBLE_TILES/2
                    ldd       #$FFFF
InvalidateCell  std       ,x++
                    leay      -1,y
                    bne       InvalidateCell
                    puls      d,x,y,pc
