* Ordinary formation motion ($29BE) and placement ($17C7).
* X game state, Y video; preserve D,X,Y,U.
* Shared draw pass used by the asteroid field after selecting its delta.
DrawFormationMotion
                    pshs      d,x,y,u
                    leas      -FM_FrameBytes,s
                    lbra      FormationAnimate

UpdateFormationMotion
                    pshs      d,x,y,u
                    leas      -FM_FrameBytes,s
                    tst       GS_FormationAlive,x
                    lbeq      FormationReturn
                    dec       GS_FormationClock,x
                    bne       FormationMove
                    lda       GS_FormationSpeed,x
                    sta       GS_FormationClock,x
                    ldy       GS_FormationYCursor,x
                    lda       ,y+
                    cmpa      #FORMATION_END
                    bne       FormationYReady
                    ldy       GS_YMotionStart,x
                    lda       ,y+
FormationYReady  sty       GS_FormationYCursor,x
                    sta       GS_EnemyObject+OB_DeltaY,x
                    ldy       GS_FormationXCursor,x
                    lda       ,y+
                    cmpa      #FORMATION_END
                    bne       FormationXReady
                    ldy       GS_XMotionLoop,x
                    lda       ,y+
FormationXReady  sty       GS_FormationXCursor,x
                    sta       GS_EnemyObject+OB_DeltaX,x
FormationMove    lda       GS_FormationType,x
                    cmpa      #WAVE_DIVERS
                    beq       FormationAnimate
                    lda       GS_FormationFramePeriod,x
                    beq       FormationAnimate
                    dec       GS_FormationFrameClock,x
                    beq       FormationAnimationDue
                    dec       GS_EnemyObject+OB_Frame,x
                    bra       FormationAnimate
FormationAnimationDue sta GS_FormationFrameClock,x
FormationAnimate leax      GS_EnemyObject,x
                    clr       OB_TileX,x
                    clr       OB_TileY,x
                    ldy       OB_ShapePointer,x
                    lbsr      MoveObject
                    lbsr      AdvanceObjectPattern
                    ldu       FM_SavedVideo,s ; stack offset
                    lbsr      RenderObjectPatterns
                    lda       OB_TileX,x
                    sta       FM_DeltaX,s ; stack offset
                    lda       OB_TileY,x
                    sta       FM_DeltaY,s ; stack offset
                    ldx       FM_SavedGame,s ; stack offset
                    lda       GS_FormationCount,x
                    sta       FM_Count,s ; stack offset
                    leay      GS_FormationPositions,x
                    sty       FM_Cells,s ; stack offset
FormationNextShip
                    ldy       FM_Cells,s ; stack offset
                    lda       ,y
                    cmpa      #FORMATION_END
                    beq       FormationAdvanceShip
                    adda      FM_DeltaX,s ; stack offset
                    sta       ,y
                    lda       1,y
                    adda      FM_DeltaY,s ; stack offset
                    sta       1,y
FormationAdvanceShip
                    ldy       FM_Cells,s ; stack offset
                    leay      2,y
                    sty       FM_Cells,s ; stack offset
                    dec       FM_Count,s ; stack offset
                    bne       FormationNextShip
                    clr       FM_Pass,s ; stack offset: erase pass first
FormationBeginPass
                    ldx       FM_SavedGame,s ; stack offset
                    lda       GS_FormationCount,x
                    sta       FM_Count,s ; stack offset
                    leay      GS_FormationPositions,x
                    sty       FM_Cells,s ; stack offset
FormationDrawShip ldy      FM_Cells,s ; stack offset
                    lda       ,y
                    cmpa      #FORMATION_END
                    beq       FormationDrawNext
                    ldx       FM_SavedGame,s ; stack offset
                    leax      GS_EnemyObject,x
                    ldd       ,y
                    std       OB_TileX,x
                    ldy       OB_ShapePointer,x
                    tst       FM_Pass,s ; stack offset
                    bne       FormationStampShip
                    lbsr      EraseObjectTrail
                    bra       FormationDrawNext
FormationStampShip lbsr    StampObjectTiles
FormationDrawNext ldy      FM_Cells,s ; stack offset
                    leay      FORMATION_POSITION_BYTES,y
                    sty       FM_Cells,s ; stack offset
                    dec       FM_Count,s ; stack offset
                    bne       FormationDrawShip
                    inc       FM_Pass,s ; stack offset
                    lda       FM_Pass,s ; stack offset
                    cmpa      #2
                    blo       FormationBeginPass
* Hit matching needs the crossed-cell delta, not the last enemy's X/Y.
                    ldx       FM_SavedGame,s ; stack offset
                    lda       FM_DeltaX,s ; stack offset
                    sta       GS_EnemyObject+OB_TileX,x
                    lda       FM_DeltaY,s ; stack offset
                    sta       GS_EnemyObject+OB_TileY,x
FormationReturn  leas      FM_FrameBytes,s
                    puls      d,x,y,u,pc

* Original $2ADE..$2B85. The laser already tested actual pattern pixels.
* Match that hit to its owning position after accounting for this frame's
* crossed-cell motion. The shared glyph itself must remain intact.
ConsumeFormationHit
                    pshs      d,x,y,u
                    leas      -FH_FrameBytes,s
                    tst       GS_ShotHitX,x
                    lbeq      FormationHitReturn
                    lda       GS_FormationCount,x
                    sta       FH_Count,s ; stack offset
                    clr       FH_Index,s ; stack offset
                    leay      GS_FormationPositions,x
                    ldu       GS_EnemyObject+OB_ShapePointer,x
                    lda       GS_FormationType,x
                    cmpa      #WAVE_INDEPENDENT
                    bne       FormationFindHit
                    lda       GS_LastHitTile,x
                    suba      #$81
                    lblo      FormationHitReturn
                    cmpa      #IM_Count*8
                    lbhs      FormationHitReturn
                    lsra
                    lsra
                    lsra
                    sta       FH_Index,s ; stack offset
                    lsla
                    leay      a,y       four positions, offset 0..6
                    tst       ,y
                    lbmi      FormationHitReturn
                    lbra      FormationHitFound
FormationFindHit lda       ,y
                    cmpa      #FORMATION_END
                    beq       FormationHitNext
                    lda       GS_ShotHitX,x
                    adda      GS_EnemyObject+OB_TileX,x
                    suba      ,y
                    cmpa      SH_TileWidth,u
                    bhs       FormationHitNext
                    lda       GS_ShotHitY,x
                    adda      GS_EnemyObject+OB_TileY,x
                    suba      1,y
                    cmpa      SH_TileHeight,u
                    blo       FormationHitFound
FormationHitNext leay      FORMATION_POSITION_BYTES,y
                    inc       FH_Index,s ; stack offset
                    dec       FH_Count,s ; stack offset
                    bne       FormationFindHit
                    bra       FormationHitReturn
FormationHitFound
                    lda       GS_KillSequence,x
                    cmpa      FH_Index,s ; stack offset: original position index
                    beq       FormationHitInSequence
                    lda       #1
                    sta       GS_KillOrderBad,x
FormationHitInSequence inc GS_KillSequence,x
                    sty       FH_Cells,s ; stack offset
                    ldd       GS_EnemyObject+OB_TileX,x
                    std       FH_Delta,s ; stack offset
                    ldd       ,y
                    std       GS_ExplosionX,x
                    std       GS_EnemyObject+OB_TileX,x
                    ldd       GS_EnemyObject+OB_PixelX,x
                    std       GS_ExplosionPixelX,x
                    tfr       u,y
                    ldu       FH_SavedVideo,s ; stack offset
                    leax      GS_EnemyObject,x
                    lbsr      EraseObjectBody
                    ldx       FH_SavedGame,s ; stack offset
                    ldd       FH_Delta,s ; stack offset
                    std       GS_EnemyObject+OB_TileX,x
                    ldy       FH_Cells,s ; stack offset
                    ldd       #FORMATION_END*256+FORMATION_END
                    std       ,y
                    ldb       FH_Index,s ; stack offset
                    lslb
                    leay      GS_OriginalPositions,x
                    leay      b,y       at most 19 positions: offset 0..36
                    ldd       #FORMATION_END*256+FORMATION_END
                    std       ,y
                    clr       GS_ShotHitX,x
                    clr       GS_ShotHitY,x
                    dec       GS_FormationAlive,x
                    dec       GS_OriginalAlive,x
                    lda       GS_KillPoints,x
                    lbsr      AddPlayerScore
FormationHitReturn
                    leas      FH_FrameBytes,s
                    puls      d,x,y,u,pc
