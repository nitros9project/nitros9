                    nam       astro
                    ttl       Astro Blaster native 6809 development port
                    use       defsfile
                    use       wildbits_vtio.d
                    use       equates.asm
                    use       sound_defs.asm
                    mod       AstroEnd,AstroName,Prgrm+Objct,ReEnt+1,AstroEntry,AD_MemoryBytes

* Process layout: AP must be first because F$Icpt receives this U.
* Source image, comparison image, game state and stack are private to
* this instance. The driver owns the separate ten-block display bitmap.
                    org       0
AD_Platform       rmb       AP_StateBytes
AD_ErrorCode      rmb       1
AD_ErrorContext   rmb       2
AD_Keys           rmb       ASTRO_KEY_BYTES
AD_Buttons        rmb       1
AD_AssetPath      rmb       1
AD_AssetOpen      rmb       1
AD_AssetError     rmb       1
AD_AssetLength    rmb       2
AD_AssetDirectory rmb       AS_HeaderBytes
AD_WaveBuffer     rmb       AS_BufferBytes
AD_Render         rmb       RF_ArgumentsBytes
AD_Palette        rmb       PW_Bytes
AD_PaletteChanged rmb       1
AD_PaletteLimited rmb       1
AD_PaletteOldMap rmb        64
AD_PaletteGroups rmb        16
AD_PaletteGlyphs  rmb       G80_TILE_COUNT
AD_Speech         rmb       SP_StateBytes
AD_SoundLink      rmb       2
AD_SoundPath      rmb       1
AD_SoundOpen      rmb       1
AD_SoundDataPath  rmb       1
AD_SoundDataOpen  rmb       1
AD_SoundPause     rmb       1
AD_SoundPending   rmb       1
AD_SoundError     rmb       1
AD_SoundName      rmb       48
AD_Game           rmb       GS_Extent
AD_Video          rmb       G80_VIDEO_BYTES
AD_PreviousVideo  rmb       G80_VISIBLE_TILES+4096
AD_TileCLUT       rmb       TV_CLUTEntries*CLUT_EntryBytes
AD_TileRecord     rmb       12
AD_TileWork       rmb       16
AD_PageRow        rmb       TV_MapCols*2
AD_PageGlyphs     rmb       G80_VISIBLE_TILE_ROWS
AD_PageText       rmb       2
AD_PageOffset     rmb       2
AD_PageScore      rmb       2
AD_PageBlock      rmb       1
AD_PageLines      rmb       1
AD_PageRows       rmb       1
AD_PageLeft       rmb       1
AD_DirtyCells     rmb       G80_VISIBLE_TILES
AD_CacheValid     rmb       1
AD_LogicTicks     rmb       1
AD_InputButtons   rmb       1
AD_FastRender     rmb       FR_StateBytes
AD_StripTable    rmb       2
AD_StripColumn   rmb       1
AD_DirtyGlyphs    rmb       G80_TILE_COUNT
AD_DirtyColumns   rmb       G80_TILEMAP_STRIDE
AD_Scanline       rmb       0         retired: renderer writes changed cells directly
AD_StaticBytes    equ       .
AD_Stack          rmb       512
AD_MemoryBytes    equ       .

AstroName        fcs       /astro/
                    fcb       1
* No pathname parameters: load companion files from /dd/astro.
* Clear private state, then use the reserved stack before any calls.
AstroEntry       leax      ,u
                    ldy       #AD_StaticBytes
AstroClearState  clr       ,x+
                    leay      -1,y
                    bne       AstroClearState
                    leas      AD_MemoryBytes,u
                    lbsr      OpenAstroData
                    lbcs      AstroAssetFailure
                    leax      AstroDevelopment,pcr
                    stx       AD_ErrorContext,u
                    ldy       #AstroDevelopmentEnd-AstroDevelopment
                    lda       #2
                    os9       I$WritLn
                    lbcs      AstroFailure
                    leax      AstroContextDisplay,pcr
                    stx       AD_ErrorContext,u
                    leax      AstroStageDisplay,pcr
                    lbsr      ReportStartupStage
                    lbsr      PrepareDisplay
                    lbcs      AstroFailure
                    leax      AstroContextInput,pcr
                    stx       AD_ErrorContext,u
                    leax      AD_Keys,u
                    lbsr      ReadTerminalKeys
                    lbcs      AstroFailure
                    leax      AstroContextSpeech,pcr
                    stx       AD_ErrorContext,u
                    leax      AstroStageSpeech,pcr
                    lbsr      ReportStartupStage
                    lbsr      InitializeSpeech
                    lbcs      AstroFailure
                    leax      AstroContextSound,pcr
                    stx       AD_ErrorContext,u
                    lbsr      InitializeAstroSound
                    lbcs      AstroFailure
                    leax      AstroStageFrame,pcr
                    lbsr      ReportStartupStage
                    lbsr      InitializeAstroScene
                    tst       AD_AssetError,u
                    lbne      AstroAssetFailure
                    leax      AstroContextPalette,pcr
                    stx       AD_ErrorContext,u
                    lbsr      RefreshAstroPalette
                    lbcs      AstroFailure
                    leax      AstroContextFrame,pcr
                    stx       AD_ErrorContext,u
                    lbsr      TileSync
                    lbcs      AstroFailure
                    leax      AstroStageShow,pcr
                    lbsr      ReportStartupStage
                    lbsr      ShowDisplay
                    lbcs      AstroFailure
                    leax      AstroContextClock,pcr
                    stx       AD_ErrorContext,u
                    lbsr      InitializeFrameClock
                    lbcs      AstroFailure
                    leax      AstroContextSound,pcr
                    stx       AD_ErrorContext,u
                    lbsr      StartAstroSound
                    lbcs      AstroFailure
AstroNextFrame   lbsr      WaitGameFrame
                    lbcs      AstroFailure
                    leax      AD_Game,u
                    stb       AD_LogicTicks,u
                    leax      AstroContextInput,pcr
                    stx       AD_ErrorContext,u
                    leax      AD_Keys,u
                    lbsr      ReadTerminalKeys
                    lbcs      AstroFailure
                    lbsr      TranslateControls
                    stb       AD_InputButtons,u
                    bitb      #CONTROL_EXIT
                    lbne      AstroQuit
AstroLogicTick  ldb       AD_InputButtons,u
                    stb       AD_Buttons,u
                    leax      AD_Game,u
                    inc       GS_FrameCounter,x
                    tfr       b,a
                    anda      #CONTROL_LEFT
                    sta       GS_LeftPressed,x
                    tfr       b,a
                    anda      #CONTROL_RIGHT
                    sta       GS_RightPressed,x
                    leay      AD_Video,u
                    lbsr      UpdateAstroSession
                    tst       AD_AssetError,u
                    lbne      AstroAssetFailure
                    lbsr      FlushAstroSound
                    ldb       AD_SoundError,u
                    beq       AstroSoundOK
                    leax      AstroContextSound,pcr
                    stx       AD_ErrorContext,u
                    lbra      AstroFailure
AstroSoundOK
                    lbsr      UpdateSpeechEvents
                    lbsr      ServiceSpeech
                    dec       AD_LogicTicks,u
                    lbne      AstroLogicTick
                    tst       AD_Game+GS_AttractPage,u
                    bne       AstroPagesDrawn ; attract pages own the whole screen
                    leax      AD_Video,u
                    leay      AD_Game,u
                    lbsr      DrawPlayerScores
                    lbsr      DrawRemainingLives
AstroPagesDrawn
                    leax      AstroContextPalette,pcr
                    stx       AD_ErrorContext,u
                    lbsr      RefreshAstroPalette
                    lbcs      AstroFailure
AstroDrawChanges leax      AstroContextFrame,pcr
                    stx       AD_ErrorContext,u
                    lbsr      TileSync
                    lbcs      AstroFailure
                    leax      AstroContextClock,pcr
                    stx       AD_ErrorContext,u
                    lbra      AstroNextFrame

AstroQuit        clrb
                    bra       AstroFailure
AstroAssetFailure
                    ldb       AD_AssetError,u
                    leax      AstroContextAssets,pcr
                    stx       AD_ErrorContext,u
AstroFailure     stb       AD_ErrorCode,u
                    lbsr      CloseAstroSound
                    lbsr      CloseSpeech
                    lbsr      CloseDisplay
                    bcc       AstroReportResult
* Prefer the initiating error; otherwise report cleanup failure.
                    tst       AD_ErrorCode,u
                    bne       AstroReportResult
                    stb       AD_ErrorCode,u
                    leax      AstroContextCleanup,pcr
                    stx       AD_ErrorContext,u
AstroReportResult
                    lbsr      CloseAstroData
                    bcc       AstroHaveResult
                    tst       AD_ErrorCode,u
                    bne       AstroHaveResult
                    stb       AD_ErrorCode,u
                    leax      AstroContextAssets,pcr
                    stx       AD_ErrorContext,u
AstroHaveResult
                    tst       AD_ErrorCode,u
                    beq       AstroExitClean
                    ldx       AD_ErrorContext,u
                    ldy       #80
                    lda       #2
                    os9       I$WritLn
                    ldb       AD_ErrorCode,u
                    bra       AstroExitOS
AstroExitClean   clrb
AstroExitOS      os9       F$Exit

* Report before a potentially blocking startup operation. Preserve the entire
* caller register set, including carry, so reporting cannot change its result.
ReportStartupStage pshs     cc,d,x,y,u
                    ldy       #80
                    lda       #2
                    os9       I$WritLn
                    puls      cc,d,x,y,u,pc
AstroStageDisplay fcc       "Astro: allocate tile memory"
                    fcb       C$CR
AstroStageSpeech  fcc       "Astro: load speech"
                    fcb       C$CR
AstroStageFrame   fcc       "Astro: prepare first frame"
                    fcb       C$CR
AstroStageShow    fcc       "Astro: show graphics"
                    fcb       C$CR

* Own buffer addresses are formed at runtime; no assembly offsets are
* mistaken for native pointers. U remains the process base throughout.
InitializeAstroScene
                    leax      AD_Video,u
                    stx       AD_Render+RF_Video,u
                    leax      AD_PreviousVideo,u
                    stx       AD_Render+RF_PreviousVideo,u
                    leax      AD_DirtyGlyphs,u
                    stx       AD_Render+RF_DirtyGlyphs,u
                    leax      AD_DirtyColumns,u
                    stx       AD_Render+RF_DirtyColumns,u
                    leax      AD_Scanline,u
                    stx       AD_Render+RF_Scanline,u
                    leax      AD_Palette+PW_Map,u
                    stx       AD_Render+RF_ColorMap,u
                    leax      AD_Game,u
                    lbsr      InitializeGameState
                    lbsr      EnterAttractState
                    lbsr      ResetEightSlotPool
                    lda       #1
                    sta       GS_EnemyShotClock,x
                    sta       GS_GameSpeed,x
                    lda       #$10
                    sta       GS_EnemyFireChance,x
                    lda       #3
                    sta       GS_LivesPlayer1,x
                    sta       GS_LivesPlayer2,x
                    lda       #25
                    sta       GS_FuelLevel,x
                    lbsr      LoadGamePalette
                    leax      AD_Video,u
                    lbsr      InitializeVideoMemory
                    lbsr      InitializeGameGlyphs
                    lbsr      InitializePlayfieldTiles
                    lbsr      DrawStatusLabels
                    leay      AD_Game,u
                    lbsr      DrawPlayerScores
                    lbsr      DrawRemainingLives
                    lbsr      DrawFuelGauge
                    leax      AD_Game,u
                    leay      AD_Video,u
                    lbsr      InitializeStars
                    lbsr      InitializePlayer
                    lbsr      ShowAstroTitle
                    lbsr      UpdateSpeechEvents
                    rts

* Reconsider visible colors every frame; explosions and wave changes add
* colors not present at startup. Retain the current map unless a visible
* color lacks a mapping or the original palette itself changed.
RefreshAstroPalette
                    leax AD_Game,u
                    tst GS_PaletteDirty,x
                    bne AstroPaletteUpdate
                    clrb
                    rts
AstroPaletteUpdate
                    leay AD_Palette+PW_Raw,u
                    lbsr UpdateGamePalette
                    lbra InstallTilePalette

AstroDevelopment fcc       "Astro Blaster: S start/shoot; 5 coin; arrows move; Ctrl warp; Q exit."
                    fcb       C$CR
AstroDevelopmentEnd equ    *
AstroContextSpeech fcc "Astro: SP0250 speech asset setup failed."
                    fcb C$CR
AstroContextSound fcc "Astro: sound setup/playback failed (astro/astrosnd, astro/astro.snd)."
                    fcb C$CR
AstroContextDisplay fcc    /Astro: display setup failed./
                    fcb       C$CR
AstroContextInput fcc      /Astro: terminal live-key input failed./
                    fcb       C$CR
AstroContextPalette fcc    /Astro: palette setup failed./
                    fcb       C$CR
AstroContextFrame fcc      /Astro: bitmap update failed./
                    fcb       C$CR
AstroContextClock fcc      /Astro: frame clock or terminal wait failed./
                    fcb       C$CR
AstroContextCleanup fcc    /Astro: display cleanup failed./
                    fcb       C$CR
AstroContextAssets fcc     "Astro: cannot open/read /dd/astro/astro.dat."
                    fcb       C$CR

                    use       input.asm
                    use       datafile.asm
                    use       tiles.asm
                    use       terminal.asm
                    use       game_state.asm
                    use       blit.asm
                    use       memory.asm
                    use       playfield.asm
                    use       stars.asm
                    use       objects.asm
                    use       object_tiles.asm
                    use       player.asm
                    use       player_collision.asm
                    use       resources.asm
                    use       asteroids.asm
                    use       docking.asm
                    use       session.asm
                    use       attract.asm
                    use       marquee_assets.asm
                    use       pages.asm
                    use       scroll_assets.asm
                    use       shots.asm
                    use       formation.asm
                    use       waves.asm
                    use       independent.asm
                    use       diver.asm
                    use       scoring.asm
                    use       highscores.asm
                    use       audio.asm
                    use       speech.asm
                    use       speech_assets.asm
                    use       bonuses.asm
                    use       explosions.asm
                    use       enemy_shots.asm
                    use       laser_heat.asm
                    use       player_death.asm
                    use       bitmap.asm
                    use       signals.asm
                    use       timing.asm
                    use       palette.asm
                    use       text.asm
                    use       assets.asm
                    use       wave_assets.asm
                    use       controls.asm
                    use       tilevideo.asm
                    emod
AstroEnd         equ       *
