* Fuel ($116F) and warp ($23B8), without speech/sound hardware writes.
* X game, Y owned video. D,X,Y,U preserved. No blocking waits.
InitializeFuel   pshs      d,x,y,u
                    lda       #FUEL_MAX
                    sta       GS_FuelLevel,x
                    lda       #FUEL_PERIOD
                    sta       GS_FuelClock,x
                    clr       GS_FuelEmpty,x
                    leax      G80_FUEL_FULL_PATTERN,y
                    leay      G80_STATUS_HIGH_ON,y
                    ldu       #G80_GLYPH_BYTES
                    lbsr      CopyBytes
                    ldx       PM_SavedVideo,s ; stack offset: video
                    ldy       PM_SavedGame,s ; stack offset: game
                    lbsr      DrawFuelGauge
                    puls      d,x,y,u,pc

UpdateFuel       pshs      d,x,y,u
                    tst       GS_FuelEmpty,x
                    lbne      FuelUpdateReturn
                    dec       GS_FuelClock,x
                    lbne      FuelUpdateReturn
                    lda       #FUEL_PERIOD
                    sta       GS_FuelClock,x
FuelFindPixel    leau      G80_STATUS_HIGH_ON+G80_GLYPH_BYTES,y
                    ldb       #G80_GLYPH_BYTES
FuelScanPixel    lda       ,-u
                    bne       FuelRemovePixel
                    decb
                    bne       FuelScanPixel
                    dec       GS_FuelLevel,x
                    pshs      x,y
                    leax      G80_FUEL_FULL_PATTERN,y
                    leay      G80_STATUS_HIGH_ON,y
                    ldu       #G80_GLYPH_BYTES
                    lbsr      CopyBytes
                    puls      x,y
                    pshs      x,y
                    exg       x,y
                    lbsr      DrawFuelGauge
                    puls      x,y
                    bra       FuelFindPixel
FuelRemovePixel  clr       ,u
                    cmpb      #1
                    bne       FuelSetWarning
                    tst       GS_FuelLevel,x
                    bne       FuelSetWarning
                    inc       GS_FuelEmpty,x
                    clr       GS_DoubleScore,x
                    bra       FuelUpdateReturn
FuelSetWarning   tst       GS_Docked,x ; original $124B skips both while docked
                    bne       FuelUpdateReturn
                    clrb
                    lda       GS_FuelLevel,x
                    cmpa      #9
                    bhs       FuelWarningReady
                    ldb       #$C0
                    cmpa      #3
                    bhs       FuelWarningReady
                    ldb       #$F0
                    lda       GS_DoubleScore,x
                    bne       FuelToggleScore
                    lda       #2
FuelToggleScore eora      #3
                    sta       GS_DoubleScore,x
FuelWarningReady stb      GS_FuelColor,x
                    lda       #1
                    sta       GS_PaletteDirty,x
FuelUpdateReturn puls     d,x,y,u,pc

* B current normalized buttons, X game. Preserve D,X,Y,U.
* Warp slows enemies by the original factor ten for 840 game ticks.
UpdateWarp       pshs      d,x,y,u
                    tst       GS_PlayerDisabled,x
                    bne       WarpReturn
                    lda       GS_GameSpeed,x
                    cmpa      #1
                    beq       WarpCheckButton
                    ldd       GS_WarpTicks,x
                    subd      #1
                    std       GS_WarpTicks,x
                    bne       WarpReturn
                    lda       #1
                    sta       GS_GameSpeed,x
                    bra       WarpReturn
WarpCheckButton  bitb      #CONTROL_WARP
                    beq       WarpReturn
                    tst       GS_WarpAvailable,x
                    beq       WarpReturn
                    lda       GS_WaveState,x
                    cmpa      #SHOT_LAST_WAVE
                    beq       WarpReturn
                    lda       #WARP_SLOW_FACTOR
                    sta       GS_GameSpeed,x
                    lda       #SFX_WARP
                    lbsr      QueueAstroSound
                    ldd       #WARP_DURATION
                    std       GS_WarpTicks,x
                    clr       GS_WarpAvailable,x
WarpReturn       puls      d,x,y,u,pc
