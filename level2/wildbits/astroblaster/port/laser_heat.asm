* Original laser heat $25AC..$2744. X game, Y video; preserve D,X,Y,U.
* Heat advances four eighth-cell steps per shot, cools once per thirteen
* frames, locks at 13+7/8 cells and unlocks after cooling below nine.
InitializeLaserHeat
                    clr       GS_HeatUnits,x
                    clr       GS_HeatPixels,x
                    clr       GS_LaserLocked,x
                    clr       GS_LaserFired,x
                    lda       #HEAT_FIRST_PERIOD
                    sta       GS_HeatClock,x
                    lbra      DrawLaserHeat

UpdateLaserHeat pshs      d,x,y,u
                    clr       GS_HeatChanged,x
                    dec       GS_HeatClock,x
                    bne       HeatCheckShot
                    lda       #HEAT_PERIOD
                    sta       GS_HeatClock,x
                    tst       GS_LaserFired,x
                    bne       HeatCheckShot
                    lda       #1
                    sta       GS_HeatChanged,x
                    lda       GS_HeatPixels,x
                    bne       HeatCoolPixel
                    tst       GS_HeatUnits,x
                    beq       HeatCheckShot
                    lda       #HEAT_FULL_PIXELS
                    sta       GS_HeatPixels,x
                    dec       GS_HeatUnits,x
                    lda       GS_HeatUnits,x
                    cmpa      #HEAT_UNLOCK_UNITS
                    bne       HeatCheckShot
                    tst       GS_LaserLocked,x
                    beq       HeatUnlock
                    lda       #$BF
                    lbsr      SetLaserHeatColor
HeatUnlock      clr       GS_LaserLocked,x
                    bra       HeatCheckShot
HeatCoolPixel   dec       GS_HeatPixels,x
HeatCheckShot   tst       GS_LaserFired,x
                    beq       HeatDrawIfChanged
                    clr       GS_LaserFired,x
                    lda       #1
                    sta       GS_HeatChanged,x
                    ldb       #4
HeatAddPixel    lda       GS_HeatPixels,x
                    cmpa      #HEAT_FULL_PIXELS
                    bne       HeatAddPartial
                    clr       GS_HeatPixels,x
                    inc       GS_HeatUnits,x
                    lda       GS_HeatUnits,x
                    cmpa      #HEAT_MAX_UNITS+1
                    bne       HeatNextPixel
                    dec       GS_HeatUnits,x
                    lda       #HEAT_FULL_PIXELS
                    sta       GS_HeatPixels,x
                    tst       GS_LaserLocked,x
                    bne       HeatAlreadyLocked
                    lda       #$F8
                    lbsr      SetLaserHeatColor
HeatAlreadyLocked lda     #$FF
                    sta       GS_LaserLocked,x
                    sta       GS_LevelOverheat,x
                    bra       HeatNextPixel
HeatAddPartial  inc       GS_HeatPixels,x
HeatNextPixel   decb
                    bne       HeatAddPixel
HeatDrawIfChanged tst     GS_HeatChanged,x
                    beq       HeatReturn
                    lbsr      DrawLaserHeat
HeatReturn      puls      d,x,y,u,pc

SetLaserHeatColor sta      GS_HeatColor1,x
                    sta       GS_HeatColor2,x
                    lda       #1
                    sta       GS_PaletteDirty,x
                    rts

DrawLaserHeat   pshs      d,x,y,u
                    tfr       y,u
                    leay      HEAT_ORIGIN,u
                    lda       #HEAT_LOW_EMPTY
                    ldb       #HEAT_LOW_CELLS
HeatEmptyLow    sta       ,y
                    leay      G80_TILEMAP_STRIDE,y
                    decb
                    bne       HeatEmptyLow
                    lda       #HEAT_HIGH_EMPTY
                    ldb       #HEAT_HIGH_CELLS
HeatEmptyHigh   sta       ,y
                    leay      G80_TILEMAP_STRIDE,y
                    decb
                    bne       HeatEmptyHigh
                    leay      HEAT_PARTIAL_GLYPH,u
                    lda       #HEAT_EMPTY_ROW
                    ldb       #G80_GLYPH_BYTES
HeatClearPartial sta      ,y+
                    decb
                    bne       HeatClearPartial
                    leay      HEAT_PARTIAL_GLYPH,u
                    ldb       GS_HeatPixels,x
                    beq       HeatCopyWarning
                    leax      HEAT_FULL_GLYPH,u
HeatPartialRows lda       ,x+
                    sta       ,y+
                    decb
                    bne       HeatPartialRows
HeatCopyWarning leax      HEAT_PARTIAL_GLYPH,u
                    leay      HEAT_HIGH_GLYPH,u
                    ldb       #G80_GLYPH_BYTES
HeatWarningRows lda       ,x+
                    sta       ,y+
                    decb
                    bne       HeatWarningRows
                    ldx       PM_SavedGame,s ; stack offset
                    lda       GS_HeatUnits,x
                    ldb       #G80_TILEMAP_STRIDE
                    mul
                    leay      HEAT_ORIGIN,u
                    leay      d,y
                    ldb       GS_HeatUnits,x
                    lda       #HEAT_LOW_PARTIAL
                    cmpb      #HEAT_LOW_CELLS
                    blo       HeatPartialCell
                    lda       #HEAT_HIGH_PARTIAL
HeatPartialCell sta       ,y
                    tstb
                    beq       HeatGaugeDone
HeatFilledCell  leay      -G80_TILEMAP_STRIDE,y
                    lda       #HEAT_LOW_FULL
                    cmpb      #HEAT_LOW_CELLS+1
                    blo       HeatFullCell
                    lda       #HEAT_HIGH_FULL
HeatFullCell    sta       ,y
                    decb
                    bne       HeatFilledCell
HeatGaugeDone   puls      d,x,y,u,pc
