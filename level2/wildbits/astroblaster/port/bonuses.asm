* Original $2C0A/$3A51 eligibility and $314D award box, cooperatively
* paced rather than blocking the VT. X game, Y video; preserve D/X/Y/U.
QueueWaveBonuses pshs      d,x,y,u
                    clr       GS_BonusCount,x
                    tst       GS_ShotMissed,x
                    bne       BonusWaveReentry
                    lda       GS_FormationMode,x
                    bita      #1
                    beq       BonusWaveReentry
                    ldd       #10*256+$03
                    lbsr      AppendBonusAward
BonusWaveReentry tst       GS_WaveReentered,x
                    bne       BonusWaveDiver
                    ldd       #7*256+$04
                    lbsr      AppendBonusAward
BonusWaveDiver   tst       GS_DiverMissed,x
                    bne       BonusWaveOrder
                    ldd       #7*256+$12
                    lbsr      AppendBonusAward
BonusWaveOrder   tst       GS_KillOrderBad,x
                    bne       BonusWaveReady
                    lda       GS_FormationMode,x
                    bita      #$81
                    beq       BonusWaveReady
                    lda       GS_Level,x
                    ldb       #5
                    mul
                    tfr       b,a       five hundreds per level
                    ldb       GS_Level,x
                    addb      #$12      original bonus identifier (not a score)
                    lbsr      AppendBonusAward
BonusWaveReady   lbsr      BeginBonusQueue
                    puls      d,x,y,u,pc

QueueAsteroidBonuses pshs  d,x,y,u
                    clr       GS_BonusCount,x
                    tst       GS_LevelLifeLost,x
                    bne       BonusCheckPods
                    ldd       #5*256+$25
                    lbsr      AppendBonusAward
BonusCheckPods   tst       GS_PodsMissed,x
                    bne       BonusCheckHeat
                    ldd       #20*256+$01
                    lbsr      AppendBonusAward
BonusCheckHeat   tst       GS_LevelOverheat,x
                    bne       BonusAsteroidReady
                    ldd       #6*256+$22
                    lbsr      AppendBonusAward
BonusAsteroidReady lbsr    BeginBonusQueue
                    puls      d,x,y,u,pc

* A hundreds, B original identifier. Four entries maximum, no wrap.
AppendBonusAward pshs      d,y
                    lda       GS_BonusCount,x
                    cmpa      #BONUS_MAX
                    bhs       BonusAppendReturn
                    lsla
                    leay      GS_BonusQueue,x
                    leay      a,y
                    ldd       ,s        stack offset: saved amount/identifier
                    std       ,y
                    inc       GS_BonusCount,x
BonusAppendReturn puls     d,y,pc

BeginBonusQueue  tst       GS_BonusCount,x
                    beq       BonusBeginReturn
                    clr       GS_BonusNext,x
                    lda       #PHASE_BONUS
                    sta       GS_Phase,x
                    lbsr      ShowNextBonus
BonusBeginReturn rts

ShowNextBonus   pshs      d,x,y,u
                    lda       GS_BonusNext,x
                    lsla
                    leau      GS_BonusQueue,x
                    leau      a,u
                    ldd       ,u
                    sta       GS_BonusLeft,x
                    stb       GS_BonusID,x
                    lda       #BONUS_INTRO_TICKS
                    sta       GS_BonusClock,x
                    lda       #SFX_BONUS ; original $3253: deedle as the amount appears
                    lbsr      QueueAstroSound
* Original saves only the visible tile map, not its character patterns.
                    tfr       y,x
                    leay      BONUS_TILE_BACKUP,y
                    ldu       #G80_VISIBLE_TILES
                    lbsr      CopyBytes
                    ldy       BO_Video,s ; stack offset: original video
                    leay      BONUS_PATTERN_LOW,y
                    leax      OriginalBonusLow,pcr
                    ldu       #BONUS_PATTERN_BYTES
                    lbsr      CopyBytes
                    ldy       BO_Video,s ; stack offset
                    leay      BONUS_PATTERN_HIGH,y
                    leax      OriginalBonusHigh,pcr
                    ldu       #BONUS_PATTERN_BYTES
                    lbsr      CopyBytes
                    ldy       BO_Game,s ; stack offset: game
                    leay      BONUS_COLORS,y
                    leax      OriginalBonusColors,pcr
                    ldu       #4
                    lbsr      CopyBytes
                    ldu       BO_Video,s ; stack offset: video
                    lda       #$73
                    sta       BONUS_TOP_LEFT,u
                    lda       #$75
                    sta       BONUS_TOP_RIGHT,u
                    lda       #$77
                    sta       BONUS_BOTTOM_RIGHT,u
                    lda       #$79
                    sta       BONUS_BOTTOM_LEFT,u
                    leay      BONUS_LEFT_INNER,u
                    lda       #$7A
                    ldb       #5
BonusDrawLeft    sta       ,y+
                    decb
                    bne       BonusDrawLeft
                    leay      BONUS_RIGHT_INNER,u
                    lda       #$76
                    ldb       #5
BonusDrawRight   sta       ,y+
                    decb
                    bne       BonusDrawRight
                    leay      BONUS_TOP_INNER,u
                    lda       #$74
                    ldb       #14
                    lbsr      BonusTileRun
                    leay      BONUS_BOTTOM_INNER,u
                    lda       #$78
                    ldb       #14
                    lbsr      BonusTileRun
                    leax      BONUS_INSIDE,u
                    ldb       #5
BonusClearRow    pshs      b
                    tfr       x,y
                    lda       #G80_BLANK_TILE
                    ldb       #14
                    lbsr      BonusTileRun
                    leax      1,x
                    puls      b
                    decb
                    bne       BonusClearRow
                    leax      OriginalBonusTitle,pcr
                    leay      BONUS_TEXT1,u
                    lbsr      BonusTextRun
                    leax      OriginalBonusNumber,pcr
                    leay      BONUS_TEXT2,u
                    lbsr      BonusTextRun
                    ldx       BO_Game,s ; stack offset
                    lda       GS_BonusID,x
                    leay      BONUS_NUMBER,u
                    lbsr      BonusDrawBCD
                    tfr       u,y
                    lbsr      DrawBonusAmount
                    lda       #1
                    sta       GS_PaletteDirty,x
                    puls      d,x,y,u,pc

* A repeated tile/B count or X zero-terminated text; Y destination.
BonusTileRun    sta       ,y
                    leay      G80_TILEMAP_STRIDE,y
                    decb
                    bne       BonusTileRun
                    rts
BonusTextRun    lda       ,x+
                    beq       BonusTextDone
                    sta       ,y
                    leay      G80_TILEMAP_STRIDE,y
                    bra       BonusTextRun
BonusTextDone   rts

* A packed decimal, Y destination. A/B/Y scratch.
BonusDrawBCD    tfr       a,b
                    lsra
                    lsra
                    lsra
                    lsra
                    adda      #PF_AltScoreZero
                    sta       ,y
                    leay      G80_TILEMAP_STRIDE,y
                    andb      #$0F
                    addb      #PF_AltScoreZero
                    stb       ,y
                    leay      G80_TILEMAP_STRIDE,y
                    rts

DrawBonusAmount pshs      d,x,y,u
                    lda       GS_BonusLeft,x
                    clrb
BonusAmountTens cmpa      #10
                    blo       BonusAmountReady
                    suba      #10
                    incb
                    bra       BonusAmountTens
BonusAmountReady leay     BONUS_AMOUNT,y
                    addb      #PF_AltScoreZero
                    stb       ,y
                    adda      #PF_AltScoreZero
                    sta       G80_TILEMAP_STRIDE,y
                    lda       #PF_AltScoreZero
                    sta       2*G80_TILEMAP_STRIDE,y
                    sta       3*G80_TILEMAP_STRIDE,y
                    puls      d,x,y,u,pc

UpdateBonusAward pshs     d,x,y,u
* Same three-color rotation as $320D, while the rest of gameplay pauses.
                    ldd       BONUS_COLORS+1,x
                    pshs      d
                    lda       BONUS_COLORS+3,x
                    sta       BONUS_COLORS+1,x
                    puls      d
                    std       BONUS_COLORS+2,x
                    lda       #1
                    sta       GS_PaletteDirty,x
                    dec       GS_BonusClock,x
                    bne       BonusUpdateReturn
                    lda       #BONUS_COUNT_TICKS
                    sta       GS_BonusClock,x
                    lda       #SFX_BONUS
                    lbsr      QueueAstroSound
                    lda       #$10
                    lbsr      AddPlayerScore
                    dec       GS_BonusLeft,x
                    lbsr      DrawBonusAmount
                    tst       GS_BonusLeft,x
                    bne       BonusUpdateReturn
                    leax      BONUS_TILE_BACKUP,y
                    ldu       #G80_VISIBLE_TILES
                    lbsr      CopyBytes
                    ldx       BO_Game,s ; stack offset
                    ldy       BO_Video,s ; stack offset
                    inc       GS_BonusNext,x
                    lda       GS_BonusNext,x
                    cmpa      GS_BonusCount,x
                    bhs       BonusQueueDone
                    lbsr      ShowNextBonus
                    bra       BonusUpdateReturn
BonusQueueDone  lda       #PHASE_PLAY
                    sta       GS_Phase,x
BonusUpdateReturn puls    d,x,y,u,pc
