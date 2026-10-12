* Player initialization and normal horizontal motion from $21B1..$235B.
* X = game workspace, Y = video buffer; preserve D,X,Y,U.
* Boss movement, collision/death, fire and warp are separate game steps.
InitializePlayer
                    pshs      d,x,y,u
                    leay      GS_PlayerObject,x
                    leax      OriginalPlayerRecord,pcr
                    ldu       #PLAYER_OBJECT_BYTES
                    lbsr      CopyBytes
                    ldx       PM_SavedGame,s ; stack offset: game state
                    leay      PlayerShape,pcr
                    sty       GS_PlayerObject+OB_ShapePointer,x
                    lda       #2
                    sta       GS_MovePositive,x
                    nega
                    sta       GS_MoveNegative,x
                    clr       GS_PlayerDisabled,x
                    lda       #PLAYER_FLASH_PERIOD
                    sta       GS_PlayerFlash,x
                    leax      GS_PlayerObject,x
* Original initializes with a one-pixel step before the first stamp.
                    lda       #1
                    sta       OB_DeltaY,x
                    lbsr      MoveObject
                    lbsr      AdvanceObjectPattern
                    ldu       PM_SavedVideo,s ; stack offset
                    lbsr      RenderObjectPatterns
                    lbsr      DrawObjectTiles
                    puls      d,x,y,u,pc

UpdatePlayerMotion
                    pshs      d,x,y,u
                    tst       GS_PlayerDisabled,x
                    lbne      PlayerMotionReturn
                    dec       GS_PlayerFlash,x
                    bne       PlayerReadDirections
                    lda       #PLAYER_FLASH_PERIOD
                    sta       GS_PlayerFlash,x
                    lda       GS_PlayerColor1,x
                    eora      #$05
                    ora       #$FA
                    sta       GS_PlayerColor1,x
                    sta       GS_PlayerColor2,x
                    lda       #1
                    sta       GS_PaletteDirty,x
PlayerReadDirections
                    lda       GS_WaveState,x
                    cmpa      #SHOT_LAST_WAVE
                    bne       PlayerNormalDirections
                    lbsr      ConfigureDockPlayer
                    tsta
                    bne       PlayerMotionReturn
PlayerNormalDirections
                    leau      GS_PlayerObject,x
                    clr       OB_DeltaY,u
                    tst       GS_LeftPressed,x
                    beq       PlayerCheckRight
                    lda       OB_TileY,u
                    cmpa      #PLAYER_LEFT_ROW
                    bne       PlayerGoLeft
                    lda       OB_PixelY,u
                    cmpa      #PLAYER_LEFT_PIXEL
                    beq       PlayerCheckRight
PlayerGoLeft     lda       GS_MoveNegative,x
                    sta       OB_DeltaY,u
PlayerCheckRight tst       GS_RightPressed,x
                    beq       PlayerApplyMotion
                    lda       OB_TileY,u
                    cmpa      #PLAYER_RIGHT_ROW
                    bne       PlayerGoRight
                    lda       OB_PixelY,u
                    cmpa      #PLAYER_RIGHT_PIXEL
                    beq       PlayerApplyMotion
PlayerGoRight    lda       GS_MovePositive,x
                    sta       OB_DeltaY,u
PlayerApplyMotion
                    tfr       u,x
                    ldy       OB_ShapePointer,x
                    ldu       PM_SavedVideo,s ; stack offset
                    lbsr      MoveObject
                    lbsr      AdvanceObjectPattern
                    lbsr      RenderObjectPatterns
                    ldx       PM_SavedGame,s ; stack offset: game
                    ldy       PM_SavedVideo,s ; stack offset: video
                    lbsr      CheckPlayerCollision
                    leax      GS_PlayerObject,x
                    ldy       OB_ShapePointer,x
                    lbsr      DrawObjectTiles
PlayerMotionReturn
                    puls      d,x,y,u,pc
