* Mother-ship arrival, tractor, doors, bonus and refueling.
* Original $420B..$465F. X game/Y video/U process; preserve all.
InitializeDocking
                    pshs      d,x,y,u
                    leas      -DI_FrameBytes,s
                    ldb       #AS_DockingPack
                    lbsr      LoadWaveData
                    lbcs      DockInitReturn
                    ldy       DI_Game,s ; stack offset
                    stx       GS_StageRoot,y
                    tfr       x,u
                    clr       DI_Index,s ; stack offset
DockInitObject   ldd       DK_Objects,u
                    leax      d,u
                    lda       DI_Index,s ; stack offset
                    lsla
                    ldd       a,x
                    leax      d,u
                    lda       #PLAYER_OBJECT_BYTES
                    ldb       DI_Index,s ; stack offset
                    mul
                    ldy       DI_Game,s ; stack offset
                    leay      GS_DockObjects,y
                    leay      d,y
                    lbsr      CopyStageObject
                    inc       DI_Index,s ; stack offset
                    lda       DI_Index,s ; stack offset
                    cmpa      #DOCK_OBJECT_COUNT
                    blo       DockInitObject
                    ldy       DI_Game,s ; stack offset
                    leay      GS_EnemyColor00,y
                    ldd       DK_Colors,u
                    leax      d,u
                    pshs      u
                    ldu       #16
                    lbsr      CopyBytes
                    puls      u
                    ldy       DI_Game,s ; stack offset
                    leay      DOCK_PALETTE_E,y
                    ldd       DK_Colors,u
                    leax      d,u
                    pshs      u
                    ldu       #8
                    lbsr      CopyBytes
                    puls      u
                    ldy       DI_Game,s ; stack offset
                    leay      DOCK_PALETTE_3,y
                    ldd       DK_Colors,u
                    leax      d,u
                    pshs      u
                    ldu       #4
                    lbsr      CopyBytes
                    puls      u
                    ldy       DI_Game,s ; stack offset
                    leay      GS_PodColors,y
                    ldd       DK_TractorColors,u
                    leax      d,u
                    pshs      u
                    ldu       #4
                    lbsr      CopyBytes
                    puls      u
                    ldy       DI_Video,s ; stack offset
                    leay      DOCK_TRACTOR_LOW,y
                    ldd       DK_TractorLow,u
                    leax      d,u
                    pshs      u
                    ldu       #16
                    lbsr      CopyBytes
                    puls      u
                    ldy       DI_Video,s ; stack offset
                    leay      DOCK_TRACTOR_HIGH,y
                    ldd       DK_TractorHigh,u
                    leax      d,u
                    pshs      u
                    ldu       #16
                    lbsr      CopyBytes
                    puls      u
                    ldx       DI_Game,s ; stack offset
                    clr       GS_Docked,x
                    clr       GS_DockComplete,x
                    clr       GS_DockFailed,x
                    clr       GS_DockTouch,x
                    clr       GS_DockAdvancing,x
                    clr       GS_DockCorrected,x
                    clr       GS_DockDoorsStarted,x
                    clr       GS_LevelComplete,x
                    clr       GS_SpecialTarget,x
                    lda       #1
                    sta       GS_PaletteDirty,x
                    sta       GS_DockArriving,x
                    sta       GS_DockAction,x
                    lda       #STAGE_DOCK
                    sta       GS_Stage,x
                    lda       #SHOT_LAST_WAVE
                    sta       GS_WaveState,x
                    lda       #DOCK_DOOR_PERIOD
                    sta       GS_DockDoorClock,x
                    lda       #DOCK_BONUS_PERIOD
                    sta       GS_DockBonusClock,x
                    lda       #DOCK_THRUST_PERIOD
                    sta       GS_DockThrustClock,x
                    lda       #DOCK_TRACTOR_PERIOD
                    sta       GS_TractorClock,x
                    lda       #DOCK_COLOR_PERIOD
                    sta       GS_TractorColorClock,x
                    ldy       DI_Video,s ; stack offset
                    leay      HEAT_ORIGIN,y
                    ldb       #HEAT_LOW_CELLS+HEAT_HIGH_CELLS
                    lda       #G80_BLANK_TILE
DockClearHeat    sta       ,y
                    leay      G80_TILEMAP_STRIDE,y
                    decb
                    bne       DockClearHeat
DockInitReturn   leas      DI_FrameBytes,s
                    puls      d,x,y,u,pc

UpdateDocking    pshs      d,x,y,u
                    tst       GS_DockArriving,x
                    lbeq      DockStationary
                    lda       GS_DockObjects+OB_PixelX,x
                    cmpa      #4
                    bne       DockCheckPosition
                    lda       #SFX_SONAR ; original $437F: sonar with the flash
                    lbsr      QueueAstroSound
                    leau      DockFlashGroups,pcr
DockFlashGroup  lda       ,u+
                    bmi       DockCheckPosition
                    leay      GS_PaletteSource,x
                    leay      a,y
                    lda       ,y
                    eora      #$7A
                    sta       ,y
                    lda       #1
                    sta       GS_PaletteDirty,x
                    bra       DockFlashGroup
DockCheckPosition lda     GS_DockObjects+OB_TileX,x
                    cmpa      #DOCK_FINAL_X
                    bne       DockMoveArrival
                    tst       GS_DockObjects+OB_PixelX,x
                    bne       DockMoveArrival
                    clr       GS_DockArriving,x
                    lda       #1
                    sta       GS_PlayerObject+OB_DeltaX,x
                    clr       GS_DockObjects+OB_DeltaX,x
                    clr       GS_DockObjects+PLAYER_OBJECT_BYTES+OB_DeltaX,x
                    clr       GS_DockObjects+4*PLAYER_OBJECT_BYTES+OB_DeltaX,x
                    bra       DockReturn
DockMoveArrival leau      DockArrivalOrder,pcr
DockMoveNext    lda       ,u+
                    bmi       DockReturn
                    ldy       WI_Video,s ; stack offset
                    lbsr      DrawDockObject
                    bra       DockMoveNext
DockStationary  ldy       WI_Video,s ; stack offset
* Original $461F redraws these three pieces while waiting for contact.
* MoveObject still flips the pattern bank with zero displacement.
                    tst       GS_Docked,x
                    bne       DockStationaryTractor
                    clra
                    lbsr      DrawDockObject
                    lda       #1
                    lbsr      DrawDockObject
                    lda       #4
                    lbsr      DrawDockObject
DockStationaryTractor
                    lbsr      UpdateTractorBeam
                    tst       GS_Docked,x
                    beq       DockReturn
                    lda       GS_DockAction,x
                    cmpa      #1
                    beq       DockDoors
                    cmpa      #2
                    beq       DockFuelBonus
                    lbsr      RefillDockFuel
DockReturn       puls      d,x,y,u,pc
DockDoors        dec       GS_DockDoorClock,x
                    bne       DockReturn
                    lda       #DOCK_DOOR_PERIOD
                    sta       GS_DockDoorClock,x
                    tst       GS_DockDoorsStarted,x
                    bne       DockDrawDoors
                    inc       GS_DockDoorsStarted,x
                    lda       #SFX_DOCK ; original $4513: long explosion + sonar
                    lbsr      QueueAstroSound
                    lda       #SFX_SONAR
                    lbsr      QueueAstroSound
                    ldd       GS_DockObjects+OB_TileX,x
                    std       GS_DockObjects+9*PLAYER_OBJECT_BYTES+OB_TileX,x
                    lda       GS_DockObjects+OB_PixelX,x
                    sta       GS_DockObjects+9*PLAYER_OBJECT_BYTES+OB_PixelX,x
                    ldd       GS_DockObjects+PLAYER_OBJECT_BYTES+OB_TileX,x
                    decb
                    std       GS_DockObjects+10*PLAYER_OBJECT_BYTES+OB_TileX,x
                    lda       GS_DockObjects+PLAYER_OBJECT_BYTES+OB_PixelX,x
                    sta       GS_DockObjects+10*PLAYER_OBJECT_BYTES+OB_PixelX,x
                    lbsr      AwardDockAlignment
DockDrawDoors    lda       #10
                    lbsr      DrawDockObject
                    lda       #9
                    lbsr      DrawDockObject
                    lda       GS_DockObjects+9*PLAYER_OBJECT_BYTES+OB_Frame,x
                    cmpa      #6
                    bne       DockReturn
                    lda       #SFX_ENEMY ; original $4583: short explosion
                    lbsr      QueueAstroSound
                    lda       #2
                    sta       GS_DockAction,x
                    bra       DockReturn
DockFuelBonus    dec       GS_DockBonusClock,x
                    bne       DockReturn
                    lda       #DOCK_BONUS_PERIOD
                    sta       GS_DockBonusClock,x
                    lda       #$01
                    lbsr      AddPlayerScore
                    lda       #1
                    sta       GS_FuelClock,x
                    lbsr      UpdateFuel
                    tst       GS_FuelEmpty,x
                    lbeq      DockReturn
                    clr       GS_FuelEmpty,x
                    lda       #4
                    sta       GS_DockAction,x
                    lbra      DockReturn

* A index, X game/Y video; preserve all. Immutable shape data stays in
* the stage pack; object subpixel/frame state is process-owned.
DrawDockObject  pshs      d,x,y,u
                    ldb       #PLAYER_OBJECT_BYTES
                    mul
                    leax      GS_DockObjects,x
                    leax      d,x
                    tfr       y,u
                    ldy       OB_ShapePointer,x
                    lbsr      MoveObject
                    lbsr      AdvanceObjectPattern
                    lbsr      RenderObjectPatterns
                    lbsr      DrawObjectTiles
                    puls      d,x,y,u,pc

* Called from player motion. A=1 suppresses normal movement; A=0 permits
* it with docking's one-pixel lateral speed and half-rate forward thrust.
ConfigureDockPlayer
                    tst       GS_DockArriving,x
                    lbne      DockSuppressPlayer
                    tst       GS_Docked,x
                    lbne      DockSuppressPlayer
                    lda       GS_PlayerObject+OB_DeltaX,x
                    beq       DockChooseThrust
                    lda       #1
                    sta       GS_DockAdvancing,x
DockChooseThrust clr       GS_PlayerObject+OB_DeltaX,x
                    dec       GS_DockThrustClock,x
                    bne       DockCheckTouch
                    lda       #DOCK_THRUST_PERIOD
                    sta       GS_DockThrustClock,x
                    lda       GS_DockAdvancing,x
                    sta       GS_PlayerObject+OB_DeltaX,x
                    beq       DockCheckTouch
                    lda       #SFX_SONAR ; original $2281: each powered thrust step
                    lbsr      QueueAstroSound
                    lda       GS_LeftPressed,x
                    ora       GS_RightPressed,x
                    ora       GS_DockCorrected,x
                    sta       GS_DockCorrected,x
DockCheckTouch   tst       GS_DockTouch,x
                    beq       DockPlayerSpeed
                    clr       GS_DockTouch,x
                    lda       GS_PlayerObject+OB_TileY,x
                    sta       GS_DockAlignmentRow,x
                    lda       GS_PlayerObject+OB_PixelY,x
                    sta       GS_DockAlignmentPixel,x
                    lda       #1
                    sta       GS_Docked,x
                    clr       GS_PlayerObject+OB_DeltaX,x
                    clr       GS_PlayerObject+OB_DeltaY,x
                    clr       GS_LeftPressed,x
                    clr       GS_RightPressed,x
                    lda       GS_DockObjects+4*PLAYER_OBJECT_BYTES+OB_TileY,x
                    deca
                    sta       GS_PlayerObject+OB_TileY,x
                    lda       #4
                    sta       GS_PlayerObject+OB_PixelY,x
DockPlayerSpeed  lda       #1
                    sta       GS_MovePositive,x
                    nega
                    sta       GS_MoveNegative,x
                    clra
                    rts
DockSuppressPlayer lda    #1
                    rts

UpdateTractorBeam pshs     d,x,y,u
                    dec       GS_TractorClock,x
                    bne       TractorColors
                    lda       #DOCK_TRACTOR_PERIOD
                    sta       GS_TractorClock,x
                    lda       GS_DockObjects+5*PLAYER_OBJECT_BYTES+OB_TileY,x
                    ldb       GS_DockObjects+5*PLAYER_OBJECT_BYTES+OB_TileX,x
TractorLeft      deca
                    decb
                    pshs      d
                    lbsr      TractorCell
                    lda       ,y
                    cmpa      #PF_BorderTile
                    beq       TractorRightSetup
                    cmpa      #$71
                    beq       TractorLeftContinue
                    lda       #$71
                    sta       ,y
                    puls      d
                    bra       TractorRightStart
TractorLeftContinue puls   d
                    bra       TractorLeft
TractorRightSetup puls    d
TractorRightStart lda     GS_DockObjects+6*PLAYER_OBJECT_BYTES+OB_TileY,x
                    ldb       GS_DockObjects+6*PLAYER_OBJECT_BYTES+OB_TileX,x
TractorRight     inca
                    decb
                    pshs      d
                    lbsr      TractorCell
                    lda       ,y
                    cmpa      #PF_BorderTile
                    beq       TractorRightDone
                    cmpa      #$70
                    beq       TractorRightContinue
                    lda       #$70
                    sta       ,y
                    puls      d
                    bra       TractorColors
TractorRightContinue puls  d
                    bra       TractorRight
TractorRightDone puls     d
TractorColors    dec       GS_TractorColorClock,x
                    bne       TractorReturn
                    lda       #DOCK_COLOR_PERIOD
                    sta       GS_TractorColorClock,x
                    ldd       GS_PodColors+1,x
                    pshs      d
                    lda       GS_PodColors+3,x
                    sta       GS_PodColors+1,x
                    puls      d
                    std       GS_PodColors+2,x
                    lda       #1
                    sta       GS_PaletteDirty,x
TractorReturn    puls      d,x,y,u,pc
* A row/B column -> Y cell; original diagonals terminate at border.
* The saved video pointer is above the temporary D and return PC.
TractorCell      pshs      b
                    ldb       #G80_TILEMAP_STRIDE
                    mul
                    orb       ,s+       stack offset: column
                    ldy       WI_Video+4,s ; stack offset: parent saved Y
                    leay      d,y
                    rts

AwardDockAlignment pshs    d,x,y,u
                    tst       GS_DockCorrected,x
                    bne       DockAwardReturn
                    ldb       GS_DockAlignmentPixel,x
                    lda       GS_DockAlignmentRow,x
                    cmpa      #11
                    bne       DockAwardRow12
                    subb      #5
                    bra       DockAwardLookup
DockAwardRow12   cmpa      #12
                    bne       DockAwardOtherRow
                    addb      #3
                    bra       DockAwardLookup
DockAwardOtherRow addb     #11
DockAwardLookup  cmpb      #15
                    bhs       DockAwardReturn
                    pshs      b         stack offset: alignment table index
                    ldu       GS_StageRoot,x
                    ldd       DK_Awards,u
                    leay      d,u
                    puls      b
                    ldb       b,y       bounded 0..14 table index
                    beq       DockAwardReturn
                    lda       #SFX_BONUS ; original $4510 shows a deedle box
                    lbsr      QueueAstroSound
DockAwardHundred lda      #$10       each table unit awards 100
                    lbsr      AddPlayerScore
                    decb
                    bne       DockAwardHundred
DockAwardReturn puls      d,x,y,u,pc

RefillDockFuel   pshs      d,x,y,u
                    leau      G80_STATUS_HIGH_ON,y
                    leay      G80_FUEL_FULL_PATTERN,y
                    ldb       #G80_GLYPH_BYTES
DockRefillPixel  tst       ,u
                    beq       DockWriteFuelPixel
                    leau      1,u
                    leay      1,y
                    decb
                    bne       DockRefillPixel
                    lda       GS_FuelLevel,x
                    cmpa      #FUEL_MAX
                    beq       DockRefuelComplete
                    inc       GS_FuelLevel,x
                    ldy       WI_Video,s ; stack offset
                    leau      G80_STATUS_HIGH_ON+1,y
                    ldb       #G80_GLYPH_BYTES-1
DockClearFuelRows clr      ,u+
                    decb
                    bne       DockClearFuelRows
                    exg       x,y
                    lbsr      DrawFuelGauge
                    bra       DockRefillReturn
DockWriteFuelPixel lda     ,y
                    sta       ,u
                    bra       DockRefillReturn
DockRefuelComplete lda    #1
                    sta       GS_DockComplete,x
DockRefillReturn puls      d,x,y,u,pc
DockArrivalOrder fcb       6,1,8,3,4,7,2,0,5,$FF
DockFlashGroups fcb        15,35,39,43,47,59,$FF
