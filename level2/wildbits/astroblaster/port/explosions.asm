* Enemy hit explosion, original $307F..$314C. X game, Y video; preserve
* D,X,Y,U. The active pointer also inhibits another laser as in $0DE2.
UpdateEnemyExplosion
                    pshs      d,x,y,u
                    ldd       GS_ExplosionX,x
                    beq       ExplosionAdvance
                    ldd       GS_LaserCooldown,x
                    bne       ExplosionAdvance
                    lda       #SFX_ENEMY
                    lbsr      QueueAstroSound
                    lda       #0
                    sta       GS_ExplosionColor0,x
                    lda       #$F8
                    sta       GS_ExplosionColor1,x
                    lda       #$C0
                    sta       GS_ExplosionColor2,x
                    lda       #1
                    sta       GS_PaletteDirty,x
                    ldy       GS_ExplosionShape,x
                    sty       GS_LaserCooldown,x
                    leay      GS_ExplosionObject,x
                    ldx       GS_ExplosionTemplate,x
                    ldu       #PLAYER_OBJECT_BYTES
                    lbsr      CopyBytes
                    ldx       PM_SavedGame,s ; stack offset
                    ldy       GS_LaserCooldown,x
                    sty       GS_ExplosionObject+OB_ShapePointer,x
                    ldd       GS_ExplosionX,x
                    std       GS_ExplosionObject+OB_TileX,x
                    ldd       GS_ExplosionPixelX,x
                    std       GS_ExplosionObject+OB_PixelX,x
                    clr       GS_ExplosionX,x
                    clr       GS_ExplosionY,x
                    lda       #EXPLOSION_FRAMES
                    sta       GS_ExplosionFrames,x
                    lda       #EXPLOSION_PERIOD
                    sta       GS_ExplosionClock,x
ExplosionAdvance ldd       GS_LaserCooldown,x
                    beq       ExplosionReturn
                    dec       GS_ExplosionClock,x
                    bne       ExplosionReturn
                    lda       #EXPLOSION_PERIOD
                    sta       GS_ExplosionClock,x
                    ldy       GS_ExplosionObject+OB_ShapePointer,x
                    ldu       PM_SavedVideo,s ; stack offset
                    dec       GS_ExplosionFrames,x
                    beq       ExplosionErase
                    leax      GS_ExplosionObject,x
                    lbsr      MoveObject
                    lbsr      AdvanceObjectPattern
                    lbsr      RenderObjectPatterns
                    lbsr      StampObjectTiles
                    bra       ExplosionReturn
ExplosionErase  leax      GS_ExplosionObject,x
                    lbsr      EraseObjectBody
                    ldx       PM_SavedGame,s ; stack offset
                    clr       GS_LaserCooldown,x
                    clr       GS_LaserCooldown+1,x
ExplosionReturn puls      d,x,y,u,pc
