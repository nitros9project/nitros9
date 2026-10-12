* Nonblocking outer session. U process base; D/X/Y scratch.
* Original blocking loops return through the VT-aware frame scheduler.
UpdateAstroSession
                    leax      AD_Game,u
                    leay      AD_Video,u
                    tst       GS_DemoActive,x
                    beq       SessionDispatchPhase
                    lbsr      UpdateDemoControls
                    lbmi      ShowAstroTitle
                    tsta
                    lbne      SessionStartGame
SessionDispatchPhase
                    lda       GS_Phase,x
                    lbeq      SessionTitle
                    cmpa      #PHASE_DEATH_WAIT
                    lbeq      SessionDeathWait
                    cmpa      #PHASE_GAME_OVER
                    lbeq      SessionGameOver
                    cmpa      #PHASE_BONUS
                    lbeq      UpdateBonusAward
                    cmpa      #PHASE_INITIALS
                    lbeq      UpdateRecordInitials
                    ldb       AD_Buttons,u
                    lbsr      UpdateWarp
                    lda       GS_Stage,x
                    cmpa      #STAGE_DOCK
                    beq       SessionDocking
                    lbsr      UpdateLaserHeat
                    lda       GS_Stage,x
                    cmpa      #STAGE_ASTEROIDS
                    beq       SessionAsteroids
                    lbsr      UpdateWaves
                    bra       SessionCheckAssets
SessionAsteroids lbsr     UpdateAsteroids
                    bra       SessionCheckAssets
SessionDocking  lbsr      UpdateDocking
SessionCheckAssets
                    tst       AD_AssetError,u
                    lbne      SessionReturn
                    lda       GS_Phase,x
                    cmpa      #PHASE_BONUS
                    lbeq      SessionReturn
                    lbsr      UpdatePlayerMotion
                    ldb       AD_Buttons,u
                    bitb      #CONTROL_FIRE
                    beq       SessionAdvanceObjects
                    lbsr      RequestPlayerShot
SessionAdvanceObjects
                    lbsr      UpdatePlayerShot
                    lbsr      UpdatePlayerDeath
                    lbsr      UpdateEnemyExplosion
                    lbsr      UpdateEnemyShots
                    lbsr      UpdateStars
                    tst       GS_LifeEnded,x
                    lbne      SessionStartDeathWait
                    lda       GS_Stage,x
                    cmpa      #STAGE_DOCK
                    beq       SessionDockProgress
                    lbsr      UpdateFuel
                    tst       GS_FuelEmpty,x
                    bne       SessionFuelOut
                    tst       GS_LevelComplete,x
                    lbeq      SessionReturn
                    ldd       GS_LaserCooldown,x
                    lbne      SessionReturn
                    lda       GS_ShotState,x
                    bita      #SHOT_ACTIVE
                    lbne      SessionReturn
                    lda       GS_Stage,x
                    cmpa      #STAGE_ASTEROIDS
                    lbeq      InitializeDocking
                    lbra      InitializeAsteroids
SessionDockProgress tst   GS_DockComplete,x
                    lbeq      SessionReturn
                    inc       GS_Level,x
                    lda       GS_Level,x
                    cmpa      #8
                    blo       SessionLevelReady
                    lda       #1
                    sta       GS_Level,x
SessionLevelReady lbsr     SwitchLivingPlayer
                    clr       GS_LevelLifeLost,x
                    clr       GS_LevelOverheat,x
                    clr       GS_DoubleScore,x
                    lbsr      PrepareAstroLife
                    lbsr      InitializeFuel
                    lbra      InitializeWaveSequence
SessionFuelOut   lda       #1
                    sta       GS_PlayerDisabled,x
                    leay      GS_LivesPlayer1,x
                    tst       GS_CurrentPlayer,x
                    beq       SessionClearLives
                    leay      GS_LivesPlayer2,x
SessionClearLives clr      ,y
                    rts
SessionStartDeathWait
                    tst       GS_DemoActive,x
                    lbne      AdvanceAttractWave
                    lda       GS_Stage,x
                    cmpa      #STAGE_DOCK
                    bne       SessionDeathDelay
                    leay      GS_LivesPlayer1,x
                    tst       GS_CurrentPlayer,x
                    beq       SessionDockLifeEnd
                    leay      GS_LivesPlayer2,x
SessionDockLifeEnd clr     ,y
SessionDeathDelay
                    lda       #PHASE_DEATH_WAIT
                    sta       GS_Phase,x
                    lda       #DEATH_WAIT_TICKS
                    sta       GS_PhaseClock,x
                    rts
SessionTitle     ldb       AD_Buttons,u
                    lbsr      UpdateStartControls
                    tsta
                    beq       SessionTitleIdle
                    tst       GS_AttractPage,x
                    beq       SessionStartGame
                    pshs      a,y
                    lbsr      EndAttractPages
                    puls      a,y
SessionStartGame
                    clr       GS_DemoActive,x
                    sta       GS_PlayerMode,x
                    lbsr      ResetPlayerScores
                    clr       GS_CurrentPlayer,x
                    clr       GS_LevelLifeLost,x
                    clr       GS_LevelOverheat,x
                    clr       GS_DoubleScore,x
                    lda       #INITIAL_LIVES
                    sta       GS_LivesPlayer1,x
                    sta       GS_LivesPlayer2,x
                    lda       #1
                    sta       GS_Level,x
                    sta       GS_OtherLevel,x
                    clr       GS_ScorePlayer1,x
                    clr       GS_ScorePlayer1+1,x
                    clr       GS_ScorePlayer2,x
                    clr       GS_ScorePlayer2+1,x
                    lbsr      PrepareAstroLife
                    lbsr      InitializeFuel
                    lbsr      InitializeWaveSequence
                    rts
SessionTitleIdle lda       GS_AttractPage,x
                    beq       SessionNativeTitle
                    cmpa      #PAGE_SCROLL
                    lbhs      UpdatePages
                    lbra      UpdateMarquee
SessionNativeTitle
                    lbsr      DrawTitleCredits
                    ldd       GS_TitleClock,x
                    subd      #1
                    std       GS_TitleClock,x
                    lbne      SessionReturn
                    lbra      BeginAttractDemo
SessionDeathWait lbsr      UpdateStars
                    dec       GS_PhaseClock,x
                    bne       SessionReturn
                    lda       GS_CurrentPlayer,x
                    beq       SessionPlayerOneLives
                    lda       GS_LivesPlayer2,x
                    bra       SessionCheckLives
SessionPlayerOneLives lda  GS_LivesPlayer1,x
SessionCheckLives tsta
                    beq       SessionEndPlayer
                    lda       GS_Stage,x
                    cmpa      #STAGE_ASTEROIDS
                    bne       SessionRepeatOrdinary
                    lbsr      PrepareAstroLife
                    lbra      InitializeAsteroids
SessionRepeatOrdinary
                    lda       GS_FormationMode,x
                    bita      #1
                    bne       SessionRepeatWave
                    cmpa      #$80
                    bne       SessionNextWave
                    tst       GS_FormationAlive,x
                    beq       SessionNextWave
SessionRepeatWave
                    ldd       GS_WaveCursor,x
                    subd      #1
                    std       GS_WaveCursor,x
SessionNextWave lbsr      PrepareAstroLife
                    lbsr      InitializeWave
SessionReturn    rts
SessionEndPlayer lda      GS_PlayerMode,x
                    cmpa      #2
                    bne       SessionAllOver
                    lbsr      SwitchLivingPlayer
                    tsta
                    beq       SessionAllOver
                    clr       GS_LevelLifeLost,x
                    clr       GS_LevelOverheat,x
                    clr       GS_DoubleScore,x
                    lbsr      PrepareAstroLife
                    lbsr      InitializeFuel
                    lbsr      InitializeWaveSequence
                    rts
* Switch after a completed level or game-over, as original $0BF6.
* X game; A=1 switched, 0 stayed. Preserve B,X,Y,U.
SwitchLivingPlayer
                    lda       GS_PlayerMode,x
                    cmpa      #2
                    bne       SessionNoSwitch
                    tst       GS_CurrentPlayer,x
                    beq       SessionCheckOtherTwo
                    tst       GS_LivesPlayer1,x
                    bra       SessionOtherAlive
SessionCheckOtherTwo tst   GS_LivesPlayer2,x
SessionOtherAlive beq      SessionNoSwitch
                    pshs      b
                    lda       GS_Level,x
                    ldb       GS_OtherLevel,x
                    sta       GS_OtherLevel,x
                    stb       GS_Level,x
                    lda       GS_CurrentPlayer,x
                    eora      #1
                    sta       GS_CurrentPlayer,x
                    puls      b
                    lda       #1
                    rts
SessionNoSwitch  clra
                    rts
SessionAllOver   lda       #PHASE_GAME_OVER
                    sta       GS_Phase,x
                    lda       #$FF
                    sta       GS_RecordPlayer,x ; records follow the GAME OVER delay
                    lda       #GAME_OVER_TICKS
                    sta       GS_PhaseClock,x
                    leax      SessionGameOverText,pcr
                    lda       #14
                    lbra      DrawCenteredTiles
SessionGameOver  dec       GS_PhaseClock,x
                    lbne      SessionReturn
                    tst       GS_RecordPlayer,x
                    lbmi      BeginScoreRecords
                    lbra      ShowAstroTitle

* Reset owned display and transient state for a life. Preserve score,
* fuel, active player's level and the wave cursor. X game/Y video.
PrepareAstroLife pshs      d,x,y,u
                    clr       GS_LifeEnded,x
                    clr       GS_PlayerDeathClock,x
                    clr       GS_ShipHitX,x
                    clr       GS_ShipHitY,x
                    clr       GS_ShotHitX,x
                    clr       GS_ShotHitY,x
                    clr       GS_LaserCooldown,x
                    clr       GS_LaserCooldown+1,x
                    clr       GS_ExplosionX,x
                    clr       GS_ExplosionY,x
                    clr       GS_ExplosionClock,x
                    clr       GS_FuelEmpty,x
                    lda       #1
                    sta       GS_GameSpeed,x
                    sta       GS_WarpAvailable,x
                    sta       GS_EnemyShotClock,x
                    sta       GS_Phase,x
                    lbsr      ResetEightSlotPool
                    lbsr      LoadGamePalette
                    pshs      x,y
                    leax      G80_STATUS_HIGH_ON,y
                    leas      -G80_GLYPH_BYTES,s
                    leay      ,s
                    pshs      u
                    ldu       #G80_GLYPH_BYTES
                    lbsr      CopyBytes
                    puls      u
                    ldx       G80_GLYPH_BYTES,s ; stack offset: saved game
                    ldy       G80_GLYPH_BYTES+2,s ; stack offset: saved video
                    exg       x,y
                    lbsr      InitializeGameGlyphs
                    lbsr      InitializePlayfieldTiles
                    lbsr      DrawStatusLabels
                    lbsr      DrawFuelGauge
                    pshs      x,y,u
                    leax      6,s      stack offset: saved fuel glyph after X/Y/U
                    ldy       0,s      stack offset: video before EXG below
                    leay      G80_STATUS_HIGH_ON,y
                    ldu       #G80_GLYPH_BYTES
                    lbsr      CopyBytes
                    puls      x,y,u
                    leas      G80_GLYPH_BYTES,s
                    puls      x,y
                    lbsr      InitializeStars
                    lbsr      InitializePlayer
                    lbsr      InitializeLaserHeat
                    puls      d,x,y,u,pc

ShowAstroTitle   leax      AD_Game,u
                    clr       GS_DemoActive,x
                    clr       GS_SoundPending,x
                    ldd       #TITLE_DURATION
                    std       GS_TitleClock,x
                    lbsr      EnterAttractState
                    lbsr      LoadGamePalette
                    clr       GS_Phase,x
                    tst       GS_CreditsBCD,x ; original $84F9: credits skip the marquee
                    lbeq      BeginMarquee
                    lbra      BeginScrollPage
SessionGameOverText
                    fcb       $50,$4A,$56,$4E,$20,$58,$5F,$4E,$5B,$80
