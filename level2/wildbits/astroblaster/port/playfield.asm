* Display portions of original $0EEB..$10B2 and $80AD..$810F.
* All addresses are offsets in the caller's owned 8K video buffer.
* These routines preserve D,X,Y,U. They do not change hardware or game
* control flow: the main initialization will call them in original order.

* X = video buffer. Install the final glyphs used by the game/status UI.
InitializeGameGlyphs
                    pshs      d,x,y,u
                    leax      G80_PLANE0_OFFSET+G80_PLANE_SPACING,x
                    ldu       #G80_VIDEO_BYTES-G80_PLANE0_OFFSET-G80_PLANE_SPACING
                    clra
                    lbsr      FillBytes
                    ldx       PF_SavedVideo,s ; stack offset: original video base
                    leax      G80_STATUS_HIGH_ON,x
                    ldu       #16
                    lda       #$FF
                    lbsr      FillBytes
                    ldx       PF_SavedVideo,s ; stack offset
                    leax      G80_DIGIT_LOW1,x
                    ldu       #G80_DIGIT_PLANE_BYTES
                    lbsr      FillBytes
                    ldx       PF_SavedVideo,s ; stack offset
                    leax      G80_DIGIT_LOW0,x
                    clra
                    lbsr      FillBytes
                    ldx       PF_SavedVideo,s ; stack offset
                    leax      G80_EMPTY_STATUS_FONT,x
                    ldu       #G80_STATUS_HIGH_BYTES
                    lbsr      FillBytes
                    ldy       PF_SavedVideo,s ; stack offset
                    leax      GameGlyphSpans,pcr
                    lbsr      CopyOwnedSpans
                    puls      d,x,y,u,pc

GameGlyphSpans
GlyphStatusShapes fdb       G80_STATUS_SHAPES,OriginalStatusShapes-GlyphStatusShapes,32
GlyphFuelCap      fdb       G80_FUEL_CAP_GLYPH,OriginalStatusShapes+16-GlyphFuelCap,8
GlyphDigitsHigh0  fdb       G80_DIGIT_HIGH0,OriginalDigitPlane-GlyphDigitsHigh0,G80_DIGIT_PLANE_BYTES
GlyphDigitsHigh1  fdb       G80_DIGIT_HIGH1,OriginalDigitPlane-GlyphDigitsHigh1,G80_DIGIT_PLANE_BYTES
GlyphStatusLow    fdb       G80_STATUS_LOW_FONT,OriginalStatusGlyphs-GlyphStatusLow,G80_STATUS_GLYPH_BYTES
GlyphStatusHigh   fdb       G80_STATUS_HIGH_FONT,OriginalStatusHighPlane-GlyphStatusHigh,G80_STATUS_HIGH_BYTES
GlyphGameFont     fdb       G80_GAME_FONT,OriginalDigitGlyphs-GlyphGameFont,G80_GAME_FONT_BYTES
GlyphPatternALow  fdb       G80_PATTERN_A_LOW,OriginalPattern151A-GlyphPatternALow,G80_STATUS_PATTERN_BYTES
GlyphPatternAHigh fdb       G80_PATTERN_A_HIGH,OriginalPattern1A9A-GlyphPatternAHigh,G80_STATUS_PATTERN_BYTES
GlyphPatternBLow  fdb       G80_PATTERN_B_LOW,OriginalPattern14DA-GlyphPatternBLow,G80_STATUS_PATTERN_BYTES
GlyphPatternBHigh fdb       G80_PATTERN_B_HIGH,OriginalPattern1A9A-GlyphPatternBHigh,G80_STATUS_PATTERN_BYTES
GlyphSpansEnd     fdb       0,0,0

* X = video buffer. Original $0F7A..$0FE7, excluding state/palette writes.
InitializePlayfieldTiles
                    pshs      d,x,y,u
                    ldu       #G80_VISIBLE_TILES
                    lda       #G80_BLANK_TILE
                    lbsr      FillBytes
                    ldx       PF_SavedVideo,s ; stack offset
                    ldu       #G80_TILEMAP_STRIDE
                    lda       #PF_BorderTile
                    lbsr      FillBytes
                    ldx       PF_SavedVideo,s ; stack offset
                    leax      PF_LastTileRow,x
                    lbsr      FillBytes
                    ldx       PF_SavedVideo,s ; stack offset
                    leax      PF_SideOrigin,x
                    ldb       #PF_SideRows
PlayfieldSideRow  pshs      x
                    ldu       #PF_SideSpan
                    lbsr      FillBytes
                    puls      x
                    leax      G80_TILEMAP_STRIDE,x
                    decb
                    bne       PlayfieldSideRow
                    puls      d,x,y,u,pc

* X = tile-code bytes, Y = first destination cell, B = nonzero count.
* A row in the upright image is strided in the original rotated tile map.
DrawStatusTileRun pshs      d,x,y
StatusNextTile    lda       ,x+
                    sta       ,y
                    leay      G80_TILEMAP_STRIDE,y
                    decb
                    bne       StatusNextTile
                    puls      d,x,y,pc

* X = video buffer. Original labels drawn by $80C3..$810F.
DrawStatusLabels  pshs      d,x,y,u
                    tfr       x,u
                    leax      StatusPlayerLabel,pcr
                    leay      PF_Player1Label,u
                    ldb       #PF_LabelTiles
                    bsr       DrawStatusTileRun
                    leay      PF_Player2Label,u
                    bsr       DrawStatusTileRun
                    leax      StatusLeftLabel,pcr
                    leay      PF_LabelLeft,u
                    ldb       #4
                    bsr       DrawStatusTileRun
                    leax      StatusRightLabel,pcr
                    leay      PF_LabelRight,u
                    bsr       DrawStatusTileRun
                    leax      StatusCenterLabel,pcr
                    leay      PF_CenterLabel,u
                    ldb       #6
                    bsr       DrawStatusTileRun
                    puls      d,x,y,u,pc
StatusPlayerLabel fcb       $0F,$10,$11,$12,$13
StatusLeftLabel   fcb       $02,$03,$04,$68
StatusRightLabel  fcb       $69,$65,$66,$67
StatusCenterLabel fcb       $0F,$13,$10,$17,$11,$12

* D = packed four-digit BCD score, X = first tile, Y = game state.
* Original $4170..$41FA displays four digits followed by a fixed zero.
* GS_ScoreAltDigits selects the same original digit bank. Preserve the input BCD;
* the original CB3B/CB3C pair was scratch for Z80's destructive RLD.
DrawPackedScore   pshs      d,x,y,u
                    leas      -DS_FrameBytes,s
                    std       DS_BCDValue,s ; stack offset: packed score
                    lda       #PF_ScoreZeroTile
                    tst       GS_ScoreAltDigits,y
                    beq       ScoreBankReady
                    lda       #PF_AltScoreZero
ScoreBankReady    sta       DS_ZeroTile,s ; stack offset
                    ldb       #PF_ScoreDigits
                    stb       DS_DigitsLeft,s ; stack offset
ScoreNextDigit    lda       DS_BCDValue,s ; stack offset: most significant byte
                    lsra
                    lsra
                    lsra
                    lsra
                    adda      DS_ZeroTile,s ; stack offset
                    sta       ,x
                    leax      G80_TILEMAP_STRIDE,x
                    ldb       #4
                    stb       DS_ShiftsLeft,s ; stack offset
ScoreShiftNibble  asl       DS_BCDValue+1,s ; stack offset: low byte
                    rol       DS_BCDValue,s ; stack offset: high byte
                    dec       DS_ShiftsLeft,s ; stack offset
                    bne       ScoreShiftNibble
                    dec       DS_DigitsLeft,s ; stack offset
                    bne       ScoreNextDigit
                    lda       DS_ZeroTile,s ; stack offset
                    sta       ,x
                    leas      DS_FrameBytes,s
                    puls      d,x,y,u,pc

* X = video buffer, Y = game state. Original score placements $1013..$102E.
DrawPlayerScores  pshs      d,x,y,u
                    leax      PF_Player1Score,x
                    ldd       GS_ScorePlayer1,y
                    bsr       DrawPackedScore
                    ldx       PF_SavedVideo,s ; stack offset
                    leax      PF_Player2Score,x
                    ldd       GS_ScorePlayer2,y
                    bsr       DrawPackedScore
                    lda       GS_Phase,y
                    cmpa      #PHASE_PLAY
                    beq       DrawScoreRanks
                    cmpa      #PHASE_DEATH_WAIT
                    bne       DrawScoresDone
DrawScoreRanks   ldx       PF_SavedVideo,s ; stack offset: saved video base
                    ldd       GS_RankPlayer1,y
                    adda      #PF_AltScoreZero
                    addb      #PF_AltScoreZero
                    sta       SCORE_RANK1_CELL,x
                    stb       SCORE_RANK1_CELL+G80_TILEMAP_STRIDE,x
                    lda       GS_PlayerMode,y
                    cmpa      #2
                    bne       DrawScoresDone
                    ldd       GS_RankPlayer2,y
                    adda      #PF_AltScoreZero
                    addb      #PF_AltScoreZero
                    sta       SCORE_RANK2_CELL,x
                    stb       SCORE_RANK2_CELL+G80_TILEMAP_STRIDE,x
DrawScoresDone
                    puls      d,x,y,u,pc

* X = video buffer, Y = game state. Original $10EE..$1129.
* Original counters are 0..5. Keep this precondition in the game logic.
DrawRemainingLives
                    pshs      d,x,y,u
                    leax      PF_Player1Lives,x
                    ldb       GS_LivesPlayer1,y
                    bsr       DrawLivesRow
                    lda       GS_PlayerMode,y
                    cmpa      #1
                    beq       DrawLivesDone
                    ldx       PF_SavedVideo,s ; stack offset
                    leax      PF_Player2Lives,x
                    ldb       GS_LivesPlayer2,y
                    bsr       DrawLivesRow
DrawLivesDone     puls      d,x,y,u,pc
* X first cell; B remaining lives. Preserve D,X,Y,U.
DrawLivesRow      pshs      d,x,y,u
                    ldu       #PF_MaxLives
LivesEmptyCell    lda       #PF_BorderTile
                    sta       ,x
                    leax      G80_TILEMAP_STRIDE,x
                    leau      -1,u
                    cmpu      #0        test remaining cells, not the X address
                    bne       LivesEmptyCell
                    ldx       PF_SavedVideo,s ; stack offset: saved X cell address
                    tstb
                    beq       DrawLivesRowDone
LivesPresentCell  clr       ,x
                    leax      G80_TILEMAP_STRIDE,x
                    decb
                    bne       LivesPresentCell
DrawLivesRowDone  puls      d,x,y,u,pc

* X = video buffer, Y = game state. Original $12CC..$12ED.
* Fuel is 0..25: full segments, one cap, then empty segments, 26 total.
DrawFuelGauge     pshs      d,x,y,u
                    leax      PF_FuelOrigin,x
                    ldb       GS_FuelLevel,y
                    ldu       #PF_FuelSegments
                    tstb
                    beq       FuelCap
                    lda       #PF_FuelFullTile
FuelFull          sta       ,x
                    leax      G80_TILEMAP_STRIDE,x
                    leau      -1,u
                    decb
                    bne       FuelFull
FuelCap           lda       #PF_FuelCapTile
                    sta       ,x
                    leau      -1,u
                    cmpu      #0        LEAU does not set Z
                    beq       FuelDone
                    lda       #PF_FuelEmptyTile
FuelEmpty         leax      G80_TILEMAP_STRIDE,x
                    sta       ,x
                    leau      -1,u
                    cmpu      #0        LEAU does not set Z
                    bne       FuelEmpty
FuelDone          puls      d,x,y,u,pc
