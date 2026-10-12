* Diving-ship variant, original $2C9D..$2DD4. X game,Y video; preserve all.
UpdateDiver     pshs      d,x,y,u
                    dec       GS_FormationFrameClock,x
                    bne       DiverCheckActive
                    lda       GS_FormationFramePeriod,x
                    sta       GS_FormationFrameClock,x
                    inc       GS_EnemyColor01,x
                    lda       GS_EnemyColor01,x
                    sta       GS_EnemyColor11,x
                    lda       #1
                    sta       GS_PaletteDirty,x
DiverCheckActive tst      GS_DiverActive,x
                    lbne      DiverCheckHit
                    lbsr      NextGameRandom
DiverRandom     cmpa      #DIVER_PERIOD_RANDOM
                    blo       DiverRandomReady
                    suba      #DIVER_PERIOD_RANDOM
                    bra       DiverRandom
DiverRandomReady tsta
                    lbne      DiverReturn
                    leay      GS_FormationPositions,x
                    ldb       GS_FormationCount,x
DiverFindShip   lda       ,y
                    cmpa      #FORMATION_END
                    bne       DiverFoundShip
                    leay      FORMATION_POSITION_BYTES,y
                    decb
                    bne       DiverFindShip
                    lbra      DiverReturn
DiverFoundShip  tsta
                    lbmi      DiverReturn
                    sta       GS_DiverActive,x
                    ldd       ,y
                    std       GS_DiverObject+OB_TileX,x
                    ldd       #FORMATION_END*256+FORMATION_END
                    std       ,y
                    pshs      x
                    leay      GS_DiverObject,x
                    leax      GS_EnemyObject,x
                    ldu       #OB_TileX
                    lbsr      CopyBytes
                    puls      x
                    ldd       GS_EnemyObject+OB_PixelX,x
                    std       GS_DiverObject+OB_PixelX,x
                    lda       #DIVER_SPEED
                    sta       GS_DiverObject+OB_DeltaX,x
                    clr       GS_DiverObject+OB_DeltaY,x
                    clr       GS_DiverObject+OB_Frame,x
                    ldy       GS_DiveShape,x
                    sty       GS_DiverObject+OB_ShapePointer,x
                    lda       SH_TileBankA,y
                    sta       GS_DiverObject+OB_TargetTile,x
DiverCheckHit   tst       GS_ShotHitX,x
                    beq       DiverCheckEscape
                    ldy       GS_DiveShape,x
                    lda       GS_LastHitTile,x
                    cmpa      SH_TileBankA,y
                    blo       DiverCheckEscape
                    ldd       GS_DiverObject+OB_TileX,x
                    std       GS_ExplosionX,x
                    ldd       GS_DiverObject+OB_PixelX,x
                    std       GS_ExplosionPixelX,x
                    ldu       PM_SavedVideo,s ; stack offset
                    leax      GS_DiverObject,x
                    lbsr      EraseObjectBody
                    ldx       PM_SavedGame,s ; stack offset
                    clr       GS_ShotHitX,x
                    clr       GS_ShotHitY,x
                    clr       GS_LastHitTile,x
                    clr       GS_DiverActive,x
                    lda       GS_KillPoints,x
                    adda      GS_KillPoints,x
                    daa
                    lbsr      AddPlayerScore
* Original $2DA2 removes the first surviving original-list record.
                    leay      GS_OriginalPositions,x
                    ldb       GS_OriginalCount,x
DiverRemoveOriginal lda    ,y
                    cmpa      #FORMATION_END
                    bne       DiverRemoveFound
                    leay      FORMATION_POSITION_BYTES,y
                    decb
                    bne       DiverRemoveOriginal
                    bra       DiverReturn
DiverRemoveFound ldd       #FORMATION_END*256+FORMATION_END
                    std       ,y
                    dec       GS_OriginalAlive,x
                    dec       GS_FormationAlive,x
                    bra       DiverReturn
DiverCheckEscape lda      GS_DiverObject+OB_TileX,x
                    bne       DiverDraw
                    clr       GS_DiverActive,x
                    lda       #$FF
                    sta       GS_DiverEscaped,x
                    sta       GS_DiverMissed,x
                    dec       GS_FormationAlive,x
                    bra       DiverReturn
DiverDraw        leax      GS_DiverObject,x
                    ldy       OB_ShapePointer,x
                    ldu       PM_SavedVideo,s ; stack offset
                    lbsr      MoveObject
                    lbsr      AdvanceObjectPattern
                    lbsr      RenderObjectPatterns
                    lbsr      DrawObjectTiles
DiverReturn      puls      d,x,y,u,pc
