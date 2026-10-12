* Enemy fire from $2A2F..$2A81 and $1E48..$2015.
* X game, Y video. Preserve D,X,Y,U. These are original glyph bullets,
* including their two half-cell phases and pixel test against the ship.
RequestFormationShot
                    pshs      d,x,y,u
                    tst       GS_FormationAlive,x
                    beq       EnemyRequestReturn
                    lbsr      NextGameRandom
                    cmpa      GS_EnemyFireChance,x
                    bhi       EnemyRequestReturn
                    lbsr      NextGameRandom
EnemyRandomIndex cmpa      GS_FormationCount,x
                    blo       EnemyIndexReady
                    suba      GS_FormationCount,x
                    bra       EnemyRandomIndex
EnemyIndexReady  lsla
                    leay      GS_FormationPositions,x
                    leay      a,y       0..30, signed-index safe
                    lda       ,y
                    cmpa      #FORMATION_END
                    beq       EnemyRequestReturn
                    ldb       1,y
                    beq       EnemyRequestReturn
                    cmpb      #G80_VISIBLE_TILE_ROWS-1
                    bhs       EnemyRequestReturn
                    std       GS_EnemyShotX,x
                    lda       GS_EnemyObject+OB_PixelY,x
                    anda      #6
                    sta       GS_EnemyShotPixel,x
                    lda       #1
                    sta       GS_EnemyShotRequest,x
EnemyRequestReturn puls    d,x,y,u,pc

UpdateEnemyShots pshs      d,x,y,u
                    leas      -ES_FrameBytes,s
                    dec       GS_EnemyShotClock,x
                    bne       EnemyBeginSlots
                    lda       GS_GameSpeed,x
                    lsla
                    sta       GS_EnemyShotClock,x
                    tst       GS_EnemyShotRequest,x
                    beq       EnemyBeginSlots
                    lbsr      AllocateEnemyShot
EnemyBeginSlots  ldu       ES_SavedVideo,s ; stack offset: video
                    ldx       ES_SavedGame,s ; stack offset
                    leax      GS_EightSlotPool,x
                    stx       ES_Record,s ; stack offset
                    lda       #GS_PoolCount
                    sta       ES_Count,s ; stack offset
EnemyNextSlot    ldx       ES_Record,s ; stack offset
                    lda       EB_Flags,x
                    bita      #EB_Used
                    lbeq      EnemyAdvanceSlot
                    bita      #EB_OnScreen
                    bne       EnemyExistingShot
                    ora       #EB_OnScreen
                    sta       EB_Flags,x
                    lbra      EnemyCheckNextCell
EnemyExistingShot
                    lbsr      EnemyCellAddress
                    sty       ES_Cell,s ; stack offset
                    lda       ,y
                    anda      #$E0
                    cmpa      #EB_PlayerClass
                    lbeq      EnemyLeavingShip
                    anda      #$C0
                    cmpa      #$80
                    lbeq      EnemyOverOtherObject
                    lda       ,y
                    anda      #$F0
                    cmpa      #SHOT_PATTERN_BASE
                    lbeq      EnemyOverOtherObject
EnemyUnobstructed
                    lda       EB_Flags,x
                    bita      #EB_Half
                    lbne      EnemyStampBullet
EnemyMovePhase  ldx       ES_SavedGame,s ; stack offset
                    lda       GS_GameSpeed,x
                    lsla
                    deca
                    cmpa      GS_EnemyShotClock,x
                    lbne      EnemyTogglePhase
                    ldx       ES_Record,s ; stack offset
                    ldy       ES_Cell,s ; stack offset
                    lda       ,y
                    anda      #$F0
                    cmpa      #EB_Pattern
                    bne       EnemyMoveCell
                    lda       #G80_BLANK_TILE
                    sta       ,y
EnemyMoveCell   dec       EB_X,x
EnemyCheckNextCell
                    lda       EB_X,x
                    anda      #G80_TILEMAP_STRIDE-1
                    cmpa      #G80_DRAW_FIRST_COL
                    lblo      EnemyRemoveShot
                    lbsr      EnemyCellAddress
                    sty       ES_Cell,s ; stack offset
                    lda       ,y
                    anda      #$F0
                    cmpa      #SHOT_PATTERN_BASE
                    beq       EnemyTogglePhase
                    anda      #$E0
                    cmpa      #EB_PlayerClass
                    beq       EnemyEnteringShip
                    anda      #$C0
                    cmpa      #$80
                    beq       EnemyTogglePhase
EnemyStampBullet lda      EB_Tile,x
                    sta       ,y
EnemyTogglePhase ldx      ES_SavedGame,s ; stack offset
                    lda       GS_GameSpeed,x
                    lsla
                    cmpa      GS_EnemyShotClock,x
                    bne       EnemyAdvanceSlot
                    ldx       ES_Record,s ; stack offset
                    lda       EB_Tile,x
                    eora      #1
                    sta       EB_Tile,x
                    lda       EB_Flags,x
                    eora      #EB_Half
                    sta       EB_Flags,x
EnemyAdvanceSlot ldx      ES_Record,s ; stack offset
                    leax      GS_PoolStride,x
                    stx       ES_Record,s ; stack offset
                    dec       ES_Count,s ; stack offset
                    lbne      EnemyNextSlot
                    leas      ES_FrameBytes,s
                    puls      d,x,y,u,pc

EnemyLeavingShip lda      ,y
                    cmpa      EB_Overlay,x
                    bne       EnemyTestOldShip
                    lda       EB_Underlying,x
                    sta       ,y
                    bra       EnemyOldShipClear
EnemyTestOldShip ldb       EB_Pixel,x
                    lbsr      PixelPairOverlap
                    tsta
                    bne       EnemyShipHit
EnemyOldShipClear lda      EB_Flags,x
                    bita      #EB_Half
                    lbeq      EnemyMovePhase
                    lda       #EB_HighHalf
                    lbsr      OverlayEnemyShot
                    bra       EnemyTogglePhase
EnemyOverOtherObject lda   EB_Flags,x
                    bita      #EB_Half
                    lbeq      EnemyMovePhase
                    bra       EnemyTogglePhase
EnemyEnteringShip lda      ,y
                    ldb       EB_Pixel,x
                    lbsr      PixelPairOverlap
                    tsta
                    bne       EnemyShipHit
                    lda       #EB_LowHalf
                    lbsr      OverlayEnemyShot
                    bra       EnemyTogglePhase
EnemyShipHit    ldx       ES_SavedGame,s ; stack offset
                    lda       #$FF
                    sta       GS_PlayerDisabled,x
EnemyRemoveShot ldx       ES_SavedGame,s ; stack offset
                    dec       GS_EnemyShotCount,x
                    ldx       ES_Record,s ; stack offset
                    clr       EB_Flags,x
                    lbra      EnemyAdvanceSlot

* X pool entry, U video. Y receives its cell. D scratch; X,U preserved.
EnemyCellAddress lda      EB_Y,x
                    ldb       #G80_TILEMAP_STRIDE
                    mul
                    orb       EB_X,x
                    leay      d,u
                    rts

* Original $1F2F: bounded allocation, no overwriting a live slot.
* X game, Y video. Preserve D,X,Y,U.
AllocateEnemyShot pshs     d,x,y,u
                    clr       GS_EnemyShotRequest,x
                    lda       GS_EnemyShotCount,x
                    cmpa      #GS_PoolCount
                    bhs       EnemyAllocationReturn
                    lda       GS_EnemyShotX,x
                    cmpa      #EB_MinColumn
                    blo       EnemyAllocationReturn
                    cmpa      #EB_MaxColumn
                    bhi       EnemyAllocationReturn
                    tfr       y,u
                    lda       GS_EnemyShotY,x
                    ldb       #G80_TILEMAP_STRIDE
                    mul
                    orb       GS_EnemyShotX,x
                    leay      d,u
                    lda       -1,y
                    anda      #$F0
                    cmpa      #EB_Pattern
                    beq       EnemyAllocationReturn
                    lda       1,y
                    anda      #$F0
                    cmpa      #EB_Pattern
                    beq       EnemyAllocationReturn
                    leay      GS_EightSlotPool,x
                    ldb       #GS_PoolCount
EnemyFindSlot   tst       EB_Flags,y
                    beq       EnemyAllocateSlot
                    leay      GS_PoolStride,y
                    decb
                    bne       EnemyFindSlot
                    bra       EnemyAllocationReturn
EnemyAllocateSlot lda     #SFX_ENEMY_SHOT ; original $1F75: laser 2
                    lbsr      QueueAstroSound
                    ldd       GS_EnemyShotX,x
                    std       EB_X,y
                    lda       #EB_Used
                    sta       EB_Flags,y
                    lda       GS_EnemyShotPixel,x
                    sta       EB_Pixel,y
                    adda      #EB_Pattern
                    sta       EB_Tile,y
                    inc       GS_EnemyShotCount,x
EnemyAllocationReturn puls d,x,y,u,pc

* X bullet, Y ship cell, U video; A half-beam mask. Preserve all.
* Copies both ship planes to its group's spare glyph, inserts the half
* beam, and records the source tile for restoration on the next step.
OverlayEnemyShot pshs     d,x,y,u
                    lda       ,y
                    sta       EB_Underlying,x
                    anda      #$E0
                    sta       EB_Overlay,x
                    tfr       a,b
                    lda       #G80_GLYPH_BYTES
                    mul
                    leay      G80_PLANE0_OFFSET,u
                    leay      d,y
                    ldb       EB_Underlying,x
                    lda       #G80_GLYPH_BYTES
                    mul
                    leax      G80_PLANE0_OFFSET,u
                    leax      d,x
                    ldb       #G80_GLYPH_BYTES
EnemyOverlayRow lda       ,x
                    sta       ,y
                    lda       G80_PLANE_SPACING,x
                    sta       G80_PLANE_SPACING,y
                    leax      1,x
                    leay      1,y
                    decb
                    bne       EnemyOverlayRow
                    leay      -G80_GLYPH_BYTES,y
                    ldx       EO_SavedRecord,s ; stack offset
                    ldb       EB_Pixel,x
                    leay      b,y       subpixel 0,2,4,6
                    lda       EO_SavedMask,s ; stack offset
                    sta       ,y
                    sta       G80_PLANE_SPACING,y
                    ldy       EO_SavedCell,s ; stack offset
                    lda       EB_Overlay,x
                    sta       ,y
                    puls      d,x,y,u,pc
