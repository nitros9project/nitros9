* VICKY tile-layer display of the original 32x28 G80 tile screen.
* Hardware facts from the core RTL (TyVKY_TileMap_SM.v): an 8x8 tile is 64
* bytes, one byte per pixel, offset y*8+x; a map cell is two bytes, tile
* index then attribute (bits 2:0 tile set, 4:3 CLUT); the map stride is
* SizeX*2; pixel value 0 is transparent; tiles always show at 320x240.
* Upright screen: original row r is tile column r, original column c is
* tile row 31-c. Columns 31 and 0 (top and bottom border rows) do not fit
* in 240 lines; tile rows 1-30 show as map rows 0-29.
* Pixels hold 4*group+pen+1 so nothing is transparent; CLUT 0 entries
* 1-64 are the G80 palette and entry 65 is black for the margin tile.
* U is the process base throughout. All map access uses the one spare
* process slot through F$MapBlk/ReleaseDisplayMapping.

* A = block within the tile allocation: map it. Exit X = address, C/B.
TileMapBlock     pshs      a
                    ldd       AP_FirstBlock,u
                    addb      ,s+
                    adca      #0
                    tfr       d,x
                    ldb       #1
                    pshs      u
                    os9       F$MapBlk
                    tfr       u,x
                    puls      u
                    bcs       TileMapReturn
                    stx       AP_MapAddress,u
                    inc       AP_HasMapping,u
                    cmpx      #LAST_SAFE_BLOCK_MAP
                    bls       TileMapOK
                    ldb       #E$MemFul
                    orcc      #1
                    rts
TileMapOK        clrb
TileMapReturn    rts

* Allocate the tile memory and clear it: tile set 0 in blocks 0-1, the map
* in block 2 filled with margin cells, tile set 1 (one black tile) at
* TV_BlankOffset in block 2. Exit C/B.
InitializeTileMemory
                    ldx       #TV_Blocks
                    lda       #ASTRO_OUTPUT_PATH
                    ldb       #SS.GfxAlloc
                    os9       I$SetStt
                    bcs       TileInitReturn
                    stx       AP_FirstBlock,u
                    inc       AP_OwnsBitmap,u
                    clra
TileClearSet     pshs      a
                    bsr       TileMapBlock
                    bcs       TileInitFail
                    ldy       #SCREEN_BLOCK_BYTES/2
                    ldd       #0
TileClearWord    std       ,x++
                    leay      -1,y
                    bne       TileClearWord
                    lbsr      ReleaseDisplayMapping
                    bcs       TileInitFail
                    puls      a
                    inca
                    cmpa      #TV_MapBlock
                    blo       TileClearSet
                    bsr       TileMapBlock
                    bcs       TileInitReturn
                    ldy       #SCREEN_BLOCK_BYTES/2
                    ldd       #TV_BlankAttr  index 0 in tile set 1
TileFillCell     std       ,x++
                    leay      -1,y
                    bne       TileFillCell
                    ldx       AP_MapAddress,u
                    leax      TV_BlankOffset,x
                    ldb       #64
                    lda       #TV_BlackPixel
TileFillBlack    sta       ,x+
                    decb
                    bne       TileFillBlack
                    clr       AD_CacheValid,u
                    lbra      ReleaseDisplayMapping
TileInitFail     leas      1,s
TileInitReturn   rts

* Point the hardware at the tile memory and show tile map 0 alone.
* Exit C/B.
ShowTileDisplay  ldx       AP_FirstBlock,u
                    ldy       #0         CFG 0 (linear), tile set 0
                    pshs      u
                    ldu       #0
                    lda       #ASTRO_OUTPUT_PATH
                    ldb       #SS.TsSet
                    os9       I$SetStt
                    puls      u
                    bcs       TileShowReturn
                    ldd       AP_FirstBlock,u
                    addd      #TV_MapBlock
                    tfr       d,x
                    ldy       #1         CFG 0, tile set 1
                    pshs      u
                    ldu       #TV_BlankOffset
                    lda       #ASTRO_OUTPUT_PATH
                    ldb       #SS.TsSet
                    os9       I$SetStt
                    puls      u
                    bcs       TileShowReturn
                    ldd       AP_FirstBlock,u
                    addd      #TV_FontBlock
                    tfr       d,x
                    ldy       #2         CFG 0, tile set 2: the attract font
                    pshs      u
                    ldu       #0
                    lda       #ASTRO_OUTPUT_PATH
                    ldb       #SS.TsSet
                    os9       I$SetStt
                    puls      u
                    bcs       TileShowReturn
                    bsr       SetGameTileMap
                    bcs       TileShowReturn
                    ldx       #0         layer 0 (front) = tile map 0
                    ldy       #4
                    lda       #ASTRO_OUTPUT_PATH
                    ldb       #SS.Layer
                    os9       I$SetStt
                    bcs       TileShowReturn
                    ldx       #1         layers 1 and 2 blank
                    ldy       #3
                    lda       #ASTRO_OUTPUT_PATH
                    ldb       #SS.Layer
                    os9       I$SetStt
                    bcs       TileShowReturn
                    ldx       #2
                    ldy       #3
                    lda       #ASTRO_OUTPUT_PATH
                    ldb       #SS.Layer
                    os9       I$SetStt
TileShowReturn   rts

* Point tile map 0 at the game map, scroll 0. Exit C/B.
SetGameTileMap   leax      AD_TileRecord,u
                    ldd       #TV_MapControl*256
                    std       ,x         CTRL, block (set below)
                    ldd       AP_FirstBlock,u
                    addd      #TV_MapBlock
                    stb       1,x
                    ldd       #0
                    std       2,x        offset $0000
                    ldd       #TV_MapCols
                    std       4,x        SIZE_X
                    ldd       #TV_MapRows
                    std       6,x        SIZE_Y
                    ldd       #0
                    std       8,x        X window 0: map column 1 is screen column 0
                    std       10,x       Y window 0
                    ldy       #0         tile map 0
                    lda       #ASTRO_OUTPUT_PATH
                    ldb       #SS.TmSet
                    os9       I$SetStt
                    pshs      cc,b
                    ldx       #0
                    ldy       #0
                    pshs      u
                    ldu       #0
                    lda       #ASTRO_OUTPUT_PATH
                    ldb       #SS.TmScrl
                    os9       I$SetStt
                    puls      u
                    puls      cc,b,pc

* Turn the tile map off and free the tile memory. Exit C/B.
CloseTileDisplay leax      AD_TileRecord,u
                    ldb       #12
TileZeroRecord   clr       ,x+
                    decb
                    bne       TileZeroRecord
                    leax      AD_TileRecord,u
                    ldy       #0
                    lda       #ASTRO_OUTPUT_PATH
                    ldb       #SS.TmSet
                    os9       I$SetStt
                    bcs       TileCloseReturn
                    ldx       AP_FirstBlock,u
                    pshs      u
                    ldu       #TV_Blocks
                    lda       #ASTRO_OUTPUT_PATH
                    ldb       #SS.GfxFree
                    os9       I$SetStt
                    puls      u
TileCloseReturn  rts

* Bring the hardware in line with the owned G80 video buffer: upload the
* glyphs whose two planes changed, then the map cells whose tile changed.
* Colors live in the CLUT, so a palette change needs neither. Exit C/B.
TileSync         pshs      x,y
                    leas      -TS_FrameBytes,s
                    clr       TS_Glyph,s
                    clr       TS_AnyLow,s
                    clr       TS_AnyHigh,s
                    leax      AD_Video+G80_PLANE0_OFFSET,u
                    leay      AD_PreviousVideo+G80_VISIBLE_TILES,u
TileNextGlyph    tst       AD_CacheValid,u
                    beq       TileGlyphChanged
                    ldd       0,x
                    cmpd      0,y
                    bne       TileGlyphChanged
                    ldd       2,x
                    cmpd      2,y
                    bne       TileGlyphChanged
                    ldd       4,x
                    cmpd      4,y
                    bne       TileGlyphChanged
                    ldd       6,x
                    cmpd      6,y
                    bne       TileGlyphChanged
                    ldd       G80_PLANE_SPACING+0,x
                    cmpd      2048,y
                    bne       TileGlyphChanged
                    ldd       G80_PLANE_SPACING+2,x
                    cmpd      2050,y
                    bne       TileGlyphChanged
                    ldd       G80_PLANE_SPACING+4,x
                    cmpd      2052,y
                    bne       TileGlyphChanged
                    ldd       G80_PLANE_SPACING+6,x
                    cmpd      2054,y
                    bne       TileGlyphChanged
                    clra
                    bra       TileGlyphFlag
TileGlyphChanged ldd       0,x
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
                    lda       #1
                    tst       TS_Glyph,s
                    bmi       TileAnyHigh
                    sta       TS_AnyLow,s
                    bra       TileGlyphFlag
TileAnyHigh      sta       TS_AnyHigh,s
TileGlyphFlag    pshs      x
                    leax      AD_DirtyGlyphs,u
                    ldb       TS_Glyph+2,s ; stack offset past saved X
                    abx
                    sta       ,x
                    puls      x
                    leax      8,x
                    leay      8,y
                    inc       TS_Glyph,s
                    lbne      TileNextGlyph
* Upload changed glyphs, one tile-set block per half.
                    clr       TS_Glyph,s
                    tst       TS_AnyLow,s
                    beq       TileSkipLow
                    clra
                    lbsr      TileMapBlock
                    lbcs      TileSyncFail
                    lbsr      TileUploadHalf
                    lbsr      ReleaseDisplayMapping
                    lbcs      TileSyncFail
TileSkipLow      lda       #128
                    sta       TS_Glyph,s
                    tst       TS_AnyHigh,s
                    beq       TileSkipHigh
                    lda       #1
                    lbsr      TileMapBlock
                    lbcs      TileSyncFail
                    lbsr      TileUploadHalf
                    lbsr      ReleaseDisplayMapping
                    lbcs      TileSyncFail
TileSkipHigh
* Cells: original columns 30 down to 1 are map rows 0-29.
                    lda       #TV_MapBlock
                    lbsr      TileMapBlock
                    lbcs      TileSyncFail
                    lda       #30
                    sta       TS_Column,s
                    ldx       AP_MapAddress,u
                    leax      TV_FirstMapCol*2,x
                    stx       TS_Cell,s
TileNextColumn   clra
                    ldb       TS_Column,s
                    leax      AD_Video,u
                    leax      d,x
                    leay      AD_PreviousVideo,u
                    leay      d,y
                    lda       #G80_VISIBLE_TILE_ROWS
                    sta       TS_Rows,s
                    ldd       TS_Cell,s
                    pshs      d          stack offset 0: next map cell
TileNextCell     lda       ,x
                    tst       AD_CacheValid,u
                    beq       TileCellChanged
                    cmpa      ,y
                    beq       TileCellSame
TileCellChanged  sta       ,y
                    pshs      x
                    ldx       2,s        stack offset past saved X: map cell
                    clrb               tile set 0, CLUT 0
                    std       ,x
                    puls      x
TileCellSame     ldd       ,s
                    addd      #2
                    std       ,s
                    leax      G80_TILEMAP_STRIDE,x
                    leay      G80_TILEMAP_STRIDE,y
                    dec       TS_Rows+2,s ; stack offset past the cell pointer
                    bne       TileNextCell
                    leas      2,s
                    ldd       TS_Cell,s
                    addd      #TV_MapCols*2
                    std       TS_Cell,s
                    dec       TS_Column,s
                    bne       TileNextColumn
                    lbsr      ReleaseDisplayMapping
                    bcs       TileSyncFail
                    lda       #1
                    sta       AD_CacheValid,u
                    clrb
                    leas      TS_FrameBytes,s
                    puls      x,y,pc
TileSyncFail     pshs      b
                    lbsr      ReleaseDisplayMapping
                    puls      b
                    leas      TS_FrameBytes,s
                    orcc      #1
                    puls      x,y,pc

* Convert the 128 glyphs from TS_Glyph (0 or 128) whose flag is set into
* the mapped tile-set block. Called with the TileSync frame 2 bytes up.
TileUploadHalf   lda       #128
                    sta       TS_Left+2,s ; stack offset past the return address
TileUploadNext   clra
                    ldb       TS_Glyph+2,s
                    leax      AD_DirtyGlyphs,u
                    abx
                    tst       ,x
                    beq       TileUploadSkip
                    clr       ,x
                    lbsr      TileConvertGlyph
TileUploadSkip   inc       TS_Glyph+2,s
                    dec       TS_Left+2,s
                    bne       TileUploadNext
                    rts

* B = glyph: write its 64 upright pixels at AP_MapAddress+(B&127)*64.
* Upright pixel (x,y) is bit y of plane row x; value 4*group+pen+1.
TileConvertGlyph pshs      b
                    leax      AD_TileWork,u
                    leay      AD_Video+G80_PLANE0_OFFSET,u
                    lda       #G80_GLYPH_BYTES
                    mul
                    leay      d,y
                    ldd       0,y
                    std       0,x
                    ldd       2,y
                    std       2,x
                    ldd       4,y
                    std       4,x
                    ldd       6,y
                    std       6,x
                    ldd       G80_PLANE_SPACING+0,y
                    std       8,x
                    ldd       G80_PLANE_SPACING+2,y
                    std       10,x
                    ldd       G80_PLANE_SPACING+4,y
                    std       12,x
                    ldd       G80_PLANE_SPACING+6,y
                    std       14,x
                    puls      b
* B = glyph, AD_TileWork = its two planes (8 bytes each): convert.
TileConvertWork  pshs      b
                    leax      AD_TileWork,u
                    andb      #127
                    lda       #64
                    mul
                    ldy       AP_MapAddress,u
                    leay      d,y
                    lda       ,s
                    lsra
                    lsra
                    anda      #$3C       4*group
                    inca
                    sta       ,s         stack offset 0: pixel base
                    ldb       #8
                    pshs      b          stack offset 0: rows left, 1: base
TileConvertRow   clra
                    lsr       8,x
                    rola
                    lsr       0,x
                    rola
                    adda      1,s
                    sta       ,y+
                    clra
                    lsr       9,x
                    rola
                    lsr       1,x
                    rola
                    adda      1,s
                    sta       ,y+
                    clra
                    lsr       10,x
                    rola
                    lsr       2,x
                    rola
                    adda      1,s
                    sta       ,y+
                    clra
                    lsr       11,x
                    rola
                    lsr       3,x
                    rola
                    adda      1,s
                    sta       ,y+
                    clra
                    lsr       12,x
                    rola
                    lsr       4,x
                    rola
                    adda      1,s
                    sta       ,y+
                    clra
                    lsr       13,x
                    rola
                    lsr       5,x
                    rola
                    adda      1,s
                    sta       ,y+
                    clra
                    lsr       14,x
                    rola
                    lsr       6,x
                    rola
                    adda      1,s
                    sta       ,y+
                    clra
                    lsr       15,x
                    rola
                    lsr       7,x
                    rola
                    adda      1,s
                    sta       ,y+
                    dec       ,s
                    bne       TileConvertRow
                    leas      2,s
                    rts

* Decode the G80 palette into CLUT 0 entries 1-64, entry 65 black.
* Exit C/B from SS.ClutWrite.
InstallTilePalette
                    leay      AD_Palette+PW_Raw,u
                    leax      AD_TileCLUT,u
                    ldb       #G80_PALETTE_ENTRIES
TileDecodeColor  lda       ,y+
                    pshs      b          DecodeG80Color uses B
                    lbsr      DecodeG80Color
                    puls      b
                    leax      CLUT_EntryBytes,x
                    decb
                    bne       TileDecodeColor
                    clr       ,x+
                    clr       ,x+
                    clr       ,x+
                    clr       ,x+
                    leax      AD_TileCLUT,u
                    ldy       #1         CLUT 0, first entry 1
                    pshs      u
                    ldu       #TV_CLUTEntries
                    lda       #ASTRO_OUTPUT_PATH
                    ldb       #SS.ClutWrite
                    os9       I$SetStt
                    puls      u,pc
