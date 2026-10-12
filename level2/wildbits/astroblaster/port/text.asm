* Original $01F0..$0217: center an $80-terminated sequence of tile codes.
* X = valid tile-code string; Y = owned G80 video-buffer base; A = offset.
* The G80 raster is rotated: adding 32 tile cells advances an upright
* screen column. Keep original layout here; scale only in the renderer.
* Caller supplies a string/offset whose destination stays in the tile map.
* Preserves D,X,Y,U. CC scratch. No hardware writes.
DrawCenteredTiles  pshs      d,x,y
                    nega
                    adda      #CT_ColumnOrigin
                    tfr       a,b
                    lda       #CT_ColumnPage
                    leay      d,y
CountTilePair      lda       ,x+
                    cmpa      #G80_TEXT_END
                    beq       CenterTilesReady
                    lda       ,x+
                    cmpa      #G80_TEXT_END
                    beq       CenterTilesReady
                    leay      -G80_TILEMAP_STRIDE,y
                    bra       CountTilePair
CenterTilesReady   ldx       CT_SavedSource,s ; stack offset: original source X
DrawNextTextTile   lda       ,x+
                    cmpa      #G80_TEXT_END
                    beq       CenterTilesDone
                    sta       ,y
                    leay      G80_TILEMAP_STRIDE,y
                    bra       DrawNextTextTile
CenterTilesDone    puls      d,x,y,pc

* Memory half of original $0219..$0250, using owned buffers.
* The three LDIR fills overlap their final source byte. Exact final ranges:
* $0000..$07FE = $20, $07FF..$0AFD = 0, $0AFE..$1FFD = $FF.
* $1FFE/$1FFF remain as they were, exactly as in the original routine.
* X = complete 8K G80 video buffer. Preserves D,X,Y,U; CC scratch.
* Palette-port initialization is intentionally not mixed with VRAM fills.
InitializeVideoMemory
                    pshs      d,x,y,u
                    tfr       x,u
                    ldy       #G80_INIT_TILE_BYTES
                    lda       #G80_BLANK_TILE
InitializeTileMap  sta       ,x+
                    leay      -1,y
                    bne       InitializeTileMap
                    ldy       #G80_FONT_ZERO_BYTES
InitializeZeroFont clr       ,x+
                    leay      -1,y
                    bne       InitializeZeroFont
                    ldy       #G80_VIDEO_FILL_BYTES
                    lda       #$FF
InitializeHighFont sta       ,x+
                    leay      -1,y
                    bne       InitializeHighFont
                    leax      OriginalDigitGlyphs,pcr
                    leay      G80_FONT_DIGITS,u
                    ldb       #G80_DIGIT_COUNT*G80_GLYPH_BYTES
CopyDigitGlyphs    lda       ,x+
                    sta       ,y+
                    decb
                    bne       CopyDigitGlyphs
                    leay      G80_FONT_LETTERS,u
                    ldb       #G80_LETTER_COUNT*G80_GLYPH_BYTES
CopyLetterGlyphs   lda       ,x+
                    sta       ,y+
                    decb
                    bne       CopyLetterGlyphs
                    leax      OriginalAsteriskGlyph,pcr
                    leay      G80_FONT_ASTERISK,u
                    ldb       #G80_GLYPH_BYTES
CopyAsteriskGlyph  lda       ,x+
                    sta       ,y+
                    decb
                    bne       CopyAsteriskGlyph
                    puls      d,x,y,u,pc
