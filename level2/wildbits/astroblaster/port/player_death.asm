* Player destruction from $2EBB..$2F3D. X game, Y video; preserve all.
* Signals GS_LifeEnded to the outer game state instead of blocking inside
* the animation or recursively entering the main loop.
UpdatePlayerDeath
                    pshs      d,x,y,u
                    tst       GS_PlayerDisabled,x
                    lbeq      PlayerDeathReturn
                    tst       GS_LifeEnded,x
                    lbne      PlayerDeathReturn
                    tst       GS_PlayerDeathClock,x
                    bne       PlayerDeathTick
                    lda       #SFX_PLAYER
                    lbsr      QueueAstroSound
                    lda       #PLAYER_DEATH_FIRST_PERIOD
                    sta       GS_PlayerDeathClock,x
                    lda       #1
                    sta       GS_LevelLifeLost,x
                    lda       #PLAYER_DEATH_STEPS
                    sta       GS_PlayerDeathSteps,x
                    leay      PlayerDeathColors,pcr
                    sty       GS_PlayerDeathColors,x
                    leay      PlayerDeathShape,pcr
                    sty       GS_PlayerObject+OB_ShapePointer,x
                    leay      GS_LivesPlayer1,x
                    tst       GS_CurrentPlayer,x
                    beq       PlayerLoseLife
                    leay      GS_LivesPlayer2,x
PlayerLoseLife  tst       ,y
                    beq       PlayerDeathStep
                    dec       ,y
                    bra       PlayerDeathStep
PlayerDeathTick dec       GS_PlayerDeathClock,x
                    bne       PlayerDeathReturn
                    lda       #PLAYER_DEATH_PERIOD
                    sta       GS_PlayerDeathClock,x
PlayerDeathStep ldy       GS_PlayerDeathColors,x
                    lda       ,y+
                    sty       GS_PlayerDeathColors,x
                    sta       GS_PlayerDeathColorA,x
                    sta       GS_PlayerDeathColorB,x
                    lda       #1
                    sta       GS_PaletteDirty,x
                    tst       GS_ShotHitX,x
                    bne       PlayerDeathHasHit
                    ldd       GS_ShipHitX,x
                    std       GS_ShotHitX,x
PlayerDeathHasHit
                    clr       GS_PlayerObject+OB_DeltaX,x
                    clr       GS_PlayerObject+OB_DeltaY,x
                    leax      GS_PlayerObject,x
                    ldy       OB_ShapePointer,x
                    ldu       PM_SavedVideo,s ; stack offset
                    lbsr      MoveObject
                    lbsr      AdvanceObjectPattern
                    lbsr      RenderObjectPatterns
                    lbsr      StampObjectTiles
                    ldx       PM_SavedGame,s ; stack offset
                    dec       GS_PlayerDeathSteps,x
                    bne       PlayerDeathReturn
                    lda       #1
                    sta       GS_LifeEnded,x
                    sta       GS_GameSpeed,x
                    sta       GS_WarpAvailable,x
PlayerDeathReturn puls     d,x,y,u,pc
