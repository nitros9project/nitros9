* Native nonblocking attract play. The arcade's $0DBE demo sweeps
* between the horizontal limits while firing. Use the actual native
* wave/player/collision routines, with no score awards in demo. As in the
* original demo tables, effects are muted; recruitment speech has its own cadence.
* Native help replaces the cabinet coin/settings pages, not game waves.
* X game/Y video/U process. Preserve pointers; D/CC scratch.
BeginAttractDemo lda       #1
                    sta       GS_DemoActive,x
                    sta       GS_Level,x
                    sta       GS_LivesPlayer1,x
                    clr       GS_CurrentPlayer,x
                    clr       GS_DemoDirection,x
                    clr       GS_LevelLifeLost,x
                    clr       GS_LevelOverheat,x
                    clr       GS_DoubleScore,x
                    lda       #SP_PhraseAttract
                    lbsr      QueueSpeech
                    lbsr      PrepareAstroLife
                    lbsr      InitializeFuel
                    lbra      InitializeWaveSequence

* A=1/2 starts a paid game; A=0 runs demo. No invented 20-second restart.
UpdateDemoControls
                    ldb       AD_Buttons,u
                    lbsr      UpdateStartControls
                    tsta
                    bne       DemoControlsReturn
                    lda       GS_PlayerObject+OB_TileY,x
                    cmpa      #PLAYER_LEFT_ROW
                    bhi       DemoCheckRightEdge
                    lda       #1
                    sta       GS_DemoDirection,x
                    bra       DemoChooseDirection
DemoCheckRightEdge cmpa    #PLAYER_RIGHT_ROW
                    blo       DemoChooseDirection
                    clr       GS_DemoDirection,x
DemoChooseDirection
                    clr       GS_LeftPressed,x
                    clr       GS_RightPressed,x
                    tst       GS_DemoDirection,x
                    beq       DemoGoLeft
                    inc       GS_RightPressed,x
                    bra       DemoFire
DemoGoLeft       inc       GS_LeftPressed,x
DemoFire         ldb       #CONTROL_FIRE
                    stb       AD_Buttons,u
                    clra
DemoControlsReturn rts

* Original $0CD8 advances the demonstration after the ship is lost; it does
* not return to the help page and replay the announcement after every death.
AdvanceAttractWave
                    ldy       GS_WaveCursor,x
                    tst       ,y
                    beq       AttractNextSector
                    leay      AD_Video,u
                    lbsr      PrepareAstroLife
                    lbsr      InitializeFuel
                    inc       GS_WaveState,x
                    lbra      InitializeWave
AttractNextSector  inc       GS_Level,x
                    lda       GS_Level,x
                    cmpa      #8
                    blo       AttractSectorReady
                    lda       #1
                    sta       GS_Level,x
AttractSectorReady bita      #1
                    beq       AttractSectorSilent
* Original $0EB1 is called on alternate sector boundaries (3,5,7,...).
                    lda       #SP_PhraseAttract
                    lbsr      QueueSpeech
AttractSectorSilent
                    leay      AD_Video,u
                    lbsr      PrepareAstroLife
                    lbsr      InitializeFuel
                    lbra      InitializeWaveSequence

DrawTitleCredits pshs     d,x,y,u
                    lda       GS_CreditsBCD,x
                    leay      TITLE_CREDIT_CELL,y
                    lbsr      BonusDrawBCD
                    puls      d,x,y,u,pc

* Original $84FC..$8550: the Gremlin/SEGA marquee. Tile map and chars $00-$80
* of both planes come from astro.dat, palette entries 0-35 from the ROM; 36-63 are 0.
* X = game, U = process. Preserve D,X,Y,U.
BeginMarquee     pshs      d,x,y,u
                    ldx       #MARQUEE_DAT_OFFSET/65536
                    lda       AD_AssetPath,u
                    pshs      u
                    ldu       #MARQUEE_DAT_OFFSET&$FFFF
                    os9       I$Seek
                    puls      u
                    leax      AD_Video,u
                    ldy       #MARQUEE_TILE_BYTES
                    lda       AD_AssetPath,u
                    os9       I$Read
                    leax      AD_Video+G80_PLANE0_OFFSET,u
                    ldy       #MARQUEE_GLYPH_BYTES
                    lda       AD_AssetPath,u
                    os9       I$Read
                    leax      AD_Video+G80_PLANE0_OFFSET+G80_PLANE_SPACING,u
                    ldy       #MARQUEE_GLYPH_BYTES
                    lda       AD_AssetPath,u
                    os9       I$Read
                    ldx       2,s       stack offset: saved game base
                    leay      GS_PaletteSource,x
                    leax      MarqueePalette,pcr
                    ldb       #MARQUEE_PALETTE_ENTRIES
MarqueePaletteCopy lda     ,x+
                    coma                the source holds complemented bytes
                    sta       ,y+
                    decb
                    bne       MarqueePaletteCopy
                    lda       #$FF      raw 0
                    ldb       #G80_PALETTE_ENTRIES-MARQUEE_PALETTE_ENTRIES
MarqueePaletteRest sta     ,y+
                    decb
                    bne       MarqueePaletteRest
                    ldx       2,s       stack offset: saved game base
                    sta       GS_PaletteDirty,x
                    lda       #1
                    sta       GS_AttractPage,x
                    ldd       #MARQUEE_PULSE_FRAMES
                    std       GS_TitleClock,x
                    puls      d,x,y,u,pc

* One marquee tick. Original $8556..$85B0: entries 19/23/27/31 step their
* red level each frame for 256 frames, then 8 fades of 6 frames move every
* entry toward pure blue. A credit ends it. X = game, U = process.
UpdateMarquee    tst       GS_CreditsBCD,x
                    lbne      BeginScrollPage
                    lda       GS_AttractPage,x
                    cmpa      #1
                    bne       MarqueeFade
                    lda       GS_PaletteSource+19,x
                    coma
                    inca
                    anda      #7
                    coma
                    sta       GS_PaletteSource+19,x
                    sta       GS_PaletteSource+23,x
                    sta       GS_PaletteSource+27,x
                    sta       GS_PaletteSource+31,x
                    lda       #$FF
                    sta       GS_PaletteDirty,x
                    ldd       GS_TitleClock,x
                    subd      #1
                    std       GS_TitleClock,x
                    bne       MarqueeReturn
                    lda       #2
                    sta       GS_AttractPage,x
                    lda       #MARQUEE_FADE_STEPS
                    sta       GS_AttractStep,x
                    ldd       #MARQUEE_FADE_FRAMES
                    std       GS_TitleClock,x
MarqueeReturn    rts
MarqueeFade      ldd       GS_TitleClock,x
                    subd      #1
                    std       GS_TitleClock,x
                    bne       MarqueeReturn
                    ldd       #MARQUEE_FADE_FRAMES
                    std       GS_TitleClock,x
                    tst       GS_AttractStep,x
                    lbeq      BeginScrollPage
                    dec       GS_AttractStep,x
                    pshs      x
                    leax      GS_PaletteSource,x
                    ldb       #G80_PALETTE_ENTRIES
MarqueeFadeEntry lda       ,x
                    coma                raw BBGGGRRR
                    pshs      b
                    tfr       a,b
                    andb      #$C0
                    cmpb      #$C0
                    beq       fadeg@
                    adda      #$40      blue up to 3
fadeg@           tfr       a,b
                    andb      #$38
                    beq       fader@
                    suba      #$08      green down to 0
fader@           tfr       a,b
                    andb      #$07
                    beq       fadest@
                    deca                red down to 0
fadest@          coma
                    sta       ,x+
                    puls      b
                    decb
                    bne       MarqueeFadeEntry
                    puls      x
                    lda       #$FF
                    sta       GS_PaletteDirty,x
                    rts

* Rebuild the game screen after an attract page. X = game, U = process.
* Preserve X,U.
RestoreGameScreen clr      GS_AttractPage,x
                    pshs      x
                    leax      AD_Video,u
                    lbsr      InitializeVideoMemory
                    lbsr      InitializeGameGlyphs
                    lbsr      InitializePlayfieldTiles
                    lbsr      DrawStatusLabels
                    leay      AD_Game,u
                    lbsr      DrawPlayerScores
                    lbsr      DrawRemainingLives
                    lbsr      DrawFuelGauge
                    puls      x
                    lbra      LoadGamePalette
