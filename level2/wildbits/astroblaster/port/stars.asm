* Original $1C71..$1DA5: animated star field and its random generator.
* X = owned game state, Y = owned video buffer; preserve D,X,Y,U unless
* a function explicitly returns D/A. Original pointer fields now hold
* native big-endian addresses in the owned video buffer.

* Original $1D62..$1D7F. Return A = low byte of next seed; B/CC scratch.
* Feedback = seed bits 15 xor 13 xor 4 xor 0. The original RRCA rotations
* may be logical shifts here because only their eventual bit 0 is used.
* Preserve X,Y,U. A zero result uses the original $733C fallback.
NextGameRandom   lda       GS_RandomSeed,x
                    lsra
                    lsra
                    eora      GS_RandomSeed,x
                    lsra
                    eora      GS_RandomSeed+1,x
                    lsra
                    lsra
                    lsra
                    lsra
                    eora      GS_RandomSeed+1,x
                    lsra                carry is the feedback bit
                    ldd       GS_RandomSeed,x ; LDD preserves carry
                    rolb
                    rola
                    std       GS_RandomSeed,x
                    bne       RandomValueReady
                    ldd       #GS_RandomFallback
                    std       GS_RandomSeed,x
RandomValueReady tfr       b,a
                    rts

* Original $1D80: return D = tile offset, row 1..27 and column 0..31.
* X = game state; preserve X,Y,U. Exact modulo distribution from the ROM.
RandomStarOffset leas      -RO_FrameBytes,s
                    bsr       NextGameRandom
                    anda      #G80_TILEMAP_STRIDE-1
                    sta       RO_Column,s ; stack offset
                    bsr       NextGameRandom
RandomStarRow    cmpa      #G80_VISIBLE_TILE_ROWS-1
                    blo       RandomStarRowReady
                    suba      #G80_VISIBLE_TILE_ROWS-1
                    bra       RandomStarRow
RandomStarRowReady inca
                    ldb       #G80_TILEMAP_STRIDE
                    mul
                    orb       RO_Column,s ; stack offset
                    leas      RO_FrameBytes,s
                    rts

InitializeStars  pshs      d,x,y,u
                    leas      -ST_FrameBytes,s
                    lda       GS_StateFlags,x
                    anda      #$FF-GS_INIT_STARS
                    sta       GS_StateFlags,x
                    leax      G80_STAR_GLYPHS,y
                    ldu       #2*G80_GLYPH_BYTES
                    clra
                    lbsr      FillBytes
                    lda       #1
                    sta       G80_STAR_GLYPHS+3,y
                    lda       #2
                    sta       G80_STAR_GLYPHS+G80_GLYPH_BYTES+3,y
                    ldx       ST_SavedState,s ; stack offset
                    lda       #GS_StarFirstTile
                    sta       GS_StarTile,x
                    leau      GS_StarCells,x
                    lda       #GS_StarCount
                    sta       ST_Count,s ; stack offset
InitializeStarCell lbsr     RandomStarOffset
                    addd      ST_SavedVideo,s ; stack offset: native video base
                    std       ,u++
                    dec       ST_Count,s ; stack offset
                    bne       InitializeStarCell
                    lda       #GS_StarPeriod
                    sta       GS_StarCountdown,x
                    leas      ST_FrameBytes,s
                    puls      d,x,y,u,pc

UpdateStars      pshs      d,x,y,u
                    leas      -ST_FrameBytes,s
                    lda       GS_StateFlags,x
                    bita      #GS_INIT_STARS
                    beq       StarsAlreadyInitialized
                    bsr       InitializeStars
StarsAlreadyInitialized
                    dec       GS_StarCountdown,x
                    lbne      StarsReturn
                    lda       #GS_StarPeriod
                    sta       GS_StarCountdown,x
                    clr       ST_Move,s ; stack offset
                    lda       #G80_GLYPH_BYTES
                    ldb       GS_StarTile,x
                    mul
                    pshs      y
                    leay      G80_PLANE0_OFFSET,y
                    leay      d,y
                    lda       3,y       original glyph row 3
                    lsla
                    adca      #0        circular rotate, original RLC
                    lsla
                    adca      #0
                    sta       3,y
                    puls      y
                    cmpa      #1
                    bne       StarsPreparePass
                    inc       ST_Move,s ; stack offset
StarsPreparePass leau      GS_StarCells,x
                    lda       #GS_StarCount
                    sta       ST_Count,s ; stack offset
StarsNextCell    ldy       ,u
                    tst       ST_Move,s ; stack offset
                    beq       StarsBlinkCell
                    lda       ,y
                    suba      #GS_StarFirstTile
                    anda      #$FE
                    bne       StarsMoveCell
                    lda       #G80_BLANK_TILE
                    sta       ,y
StarsMoveCell    leay      -1,y
                    cmpy      ST_SavedVideo,s ; stack offset
                    bne       StarsMovedCell
                    leay      G80_STAR_WRAP_CELL,y
StarsMovedCell   lda       ,y
                    cmpa      #G80_BLANK_TILE
                    bne       StarsRememberCell
                    bra       StarsChooseVisibility
StarsBlinkCell   lda       ,y
                    cmpa      #G80_BLANK_TILE
                    beq       StarsChooseVisibility
                    suba      #GS_StarFirstTile
                    anda      #$FE
                    bne       StarsRememberCell
StarsChooseVisibility
                    lbsr      NextGameRandom
                    cmpa      #GS_StarThreshold
                    bhs       StarsVisible
                    lda       #G80_BLANK_TILE
                    bra       StarsWriteCell
StarsVisible     lda       GS_StarTile,x
StarsWriteCell   sta       ,y
StarsRememberCell sty      ,u++
                    dec       ST_Count,s ; stack offset
                    bne       StarsNextCell
                    lda       GS_StarTile,x
                    eora      #GS_StarToggle
                    sta       GS_StarTile,x
StarsReturn      leas      ST_FrameBytes,s
                    puls      d,x,y,u,pc
