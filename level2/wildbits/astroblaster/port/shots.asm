* Player laser, original $2016..$2194. X game state, Y video buffer.
* UpdatePlayerShot preserves D,X,Y,U; RequestPlayerShot changes D/CC.
* Hit events feed the enemy update; there is no invented
* bounding-box collision in place of the original two-plane pixel check.
RequestPlayerShot
                    lda       GS_PlayerDisabled,x
                    bne       ShotRequestReturn
                    tst       GS_ShotState,x
                    bne       ShotRequestReturn
                    ldd       GS_LaserCooldown,x
                    bne       ShotRequestReturn
                    lda       #SHOT_REQUESTED
                    sta       GS_ShotState,x
ShotRequestReturn rts

UpdatePlayerShot pshs      d,x,y,u
                    tfr       y,u
                    lda       GS_ShotState,x
                    bita      #SHOT_REQUESTED
                    lbeq      ShotReturn
                    bita      #SHOT_ACTIVE
                    lbeq      ShotStart
                    ldy       GS_ShotCell,x
                    lda       ,y
                    cmpa      #G80_BLANK_TILE
                    beq       ShotErasePrevious
                    anda      #$E0
                    cmpa      #SHOT_PASS_CLASS
                    beq       ShotAdvance
                    anda      #$C0
                    cmpa      #SHOT_TARGET_CLASS
                    beq       ShotLeavingTarget
                    tst       GS_SpecialTarget,x
                    beq       ShotErasePrevious
                    lda       ,y
                    anda      #$F0
                    cmpa      #SHOT_SPECIAL_CLASS
                    bne       ShotErasePrevious
                    lda       #1
                    sta       GS_SpecialTarget,x
ShotLeavingTarget
                    lda       ,y
                    cmpa      GS_ShotOverlayTile,x
                    bne       ShotCheckPreviousPixel
                    lda       GS_ShotUnderlyingTile,x
                    sta       ,y
                    bra       ShotAdvance
ShotCheckPreviousPixel
                    lbsr      ShotPixelOverlap
                    tsta
                    lbne      ShotRecordHit
                    bra       ShotAdvance
ShotErasePrevious lda      #G80_BLANK_TILE
                    sta       ,y
ShotAdvance      inc       GS_ShotX,x
                    ldy       GS_ShotCell,x
                    leay      1,y
                    sty       GS_ShotCell,x
ShotCheckNext    lda       ,y
                    cmpa      #PF_BorderTile
                    bne       ShotCheckTarget
                    lda       #$FF
                    sta       GS_ShotMissed,x
                    lbra      ShotStop
ShotCheckTarget  anda      #$E0
                    cmpa      #SHOT_PASS_CLASS
                    lbeq      ShotReturn
                    anda      #$C0
                    cmpa      #SHOT_TARGET_CLASS
                    beq       ShotEnteringTarget
                    tst       GS_SpecialTarget,x
                    beq       ShotStampPlain
                    lda       ,y
                    anda      #$F0
                    cmpa      #SHOT_SPECIAL_CLASS
                    bne       ShotStampPlain
                    lda       #1
                    sta       GS_SpecialTarget,x
ShotEnteringTarget
                    lbsr      ShotPixelOverlap
                    tsta
                    bne       ShotRecordHit
                    lbsr      ShotOverlayPattern
                    lbra      ShotReturn
ShotStampPlain   lda       GS_ShotTile,x
                    sta       ,y
                    lbra      ShotReturn

ShotStart        lda       GS_WaveState,x
                    cmpa      #SHOT_LAST_WAVE
                    lbeq      ShotReturn
                    tst       GS_LaserLocked,x
                    lbne      ShotReturn
                    lda       #SFX_LASER
                    lbsr      QueueAstroSound
                    lda       #$FF
                    sta       GS_LaserFired,x
                    lda       #SHOT_REQUESTED+SHOT_ACTIVE
                    sta       GS_ShotState,x
                    lda       GS_PlayerObject+OB_TileX,x
                    adda      #3
                    sta       GS_ShotX,x
                    lda       GS_PlayerObject+OB_TileY,x
                    inca
                    sta       GS_ShotY,x
                    ldb       #G80_TILEMAP_STRIDE
                    mul
                    orb       GS_ShotX,x
                    leay      d,u
                    sty       GS_ShotCell,x
                    lda       GS_PlayerObject+OB_PixelY,x
                    anda      #6
                    sta       GS_ShotSubpixel,x
                    adda      #SHOT_PATTERN_BASE
                    sta       GS_ShotTile,x
                    lbra      ShotCheckNext
ShotRecordHit    lda       GS_SpecialTarget,x
                    cmpa      #1
                    bne       ShotRecordOrdinaryHit
                    lda       #$FF
                    sta       GS_SpecialHit,x
                    bra       ShotStop
ShotRecordOrdinaryHit
                    lda       ,y
                    sta       GS_LastHitTile,x
                    ldd       GS_ShotX,x ; native pair: column, row
                    std       GS_ShotHitX,x
                    lda       GS_ShotSubpixel,x
                    sta       GS_ShotHitSubpixel,x
ShotStop         clr       GS_ShotState,x
ShotReturn       puls      d,x,y,u,pc

* X game, Y tile cell, U video. Return A=OR of the two struck rows in
* BOTH planes; preserve B,X,Y,U. Original $217F does not compare a box.
ShotPixelOverlap pshs      d,x,y,u
                    ldb       ,y
                    lda       #G80_GLYPH_BYTES
                    mul
                    addb      GS_ShotSubpixel,x
                    adca      #0
                    leay      G80_PLANE0_OFFSET,u
                    leay      d,y
                    lda       ,y
                    ora       1,y
                    ora       G80_PLANE_SPACING,y
                    ora       G80_PLANE_SPACING+1,y
                    sta       BS_SavedD,s ; stack offset: returned A
                    puls      d,x,y,u,pc

* A tile, B subpixel row (0,2,4,6), U video. A returns the two-row,
* two-plane OR. B,X,Y,U preserved; shared by enemy shots and ship tests.
PixelPairOverlap pshs      d,x,y,u
                    tfr       a,b
                    lda       #G80_GLYPH_BYTES
                    mul
                    addb      PP_SavedRow,s ; stack offset: input B
                    adca      #0
                    leay      G80_PLANE0_OFFSET,u
                    leay      d,y
                    lda       ,y
                    ora       1,y
                    ora       G80_PLANE_SPACING,y
                    ora       G80_PLANE_SPACING+1,y
                    sta       PP_SavedResult,s ; stack offset: return A
                    puls      d,x,y,u,pc

* Original $2138 overlays the beam in a spare tile of the target group,
* retaining the underlying tile for restoration on the following step.
ShotOverlayPattern
                    pshs      d,x,y,u
                    lda       ,y
                    sta       GS_ShotUnderlyingTile,x
                    anda      #$F0
                    cmpa      #SHOT_SPECIAL_CLASS
                    beq       ShotOverlayClassReady
                    anda      #$E0
ShotOverlayClassReady
                    sta       GS_ShotOverlayTile,x
                    tfr       a,b
                    lda       #G80_GLYPH_BYTES
                    mul
                    leay      G80_PLANE0_OFFSET,u
                    leay      d,y
                    ldb       GS_ShotUnderlyingTile,x
                    lda       #G80_GLYPH_BYTES
                    mul
                    leax      G80_PLANE0_OFFSET,u
                    leax      d,x
                    ldb       #G80_GLYPH_BYTES
ShotOverlayRow   lda       ,x
                    sta       ,y
                    lda       G80_PLANE_SPACING,x
                    sta       G80_PLANE_SPACING,y
                    leax      1,x
                    leay      1,y
                    decb
                    bne       ShotOverlayRow
                    leay      -G80_GLYPH_BYTES,y
                    ldx       BS_SavedGame,s ; stack offset: restore game base
                    ldb       GS_ShotSubpixel,x
                    leay      b,y       subpixel is 0,2,4,6; signed-index safe
                    lda       #$FF
                    sta       ,y
                    sta       G80_PLANE_SPACING,y
                    ldy       BS_SavedCell,s ; stack offset: original tile cell
                    lda       GS_ShotOverlayTile,x
                    sta       ,y
                    puls      d,x,y,u,pc
