* Native wave selection and initialization, original $27C7..$29B7.
* X game, Y video. Preserve D,X,Y,U. All data comes from native records
* generated from the seven original level sequences, not invented waves.
InitializeWaveSequence
                    pshs      d,x,y,u
                    leay      NativeLevels,pcr
                    lda       GS_Level,x
                    deca
                    lsla
                    ldd       a,y       level 1..7, word offset 0..12
                    leay      d,y
                    sty       GS_LevelSequence,x
                    sty       GS_WaveCursor,x
                    clr       GS_LevelComplete,x
                    clr       GS_Stage,x
                    lda       #1
                    sta       GS_WaveState,x
                    puls      d,x,y,u
                    lbra      InitializeWave

InitializeWave pshs       d,x,y,u
                    ldu       GS_WaveCursor,x
                    ldb       ,u+
                    bne       WaveHasRecord
                    lda       #1
                    sta       GS_LevelComplete,x
                    lbra      WaveInitReturn
WaveHasRecord   stu       GS_WaveCursor,x
                    ldu       WI_Sequence,s ; stack offset: process base
                    lbsr      LoadWaveData
                    lbcs      WaveInitReturn
                    tfr       x,y
                    ldx       WI_Game,s ; stack offset: game base
                    sty       GS_WaveDescriptor,x
                    ldd       W_YMotion,y
                    leau      d,y
                    stu       GS_YMotionStart,x
                    stu       GS_FormationYCursor,x
                    ldd       W_XEntry,y
                    leau      d,y
                    stu       GS_XMotionEntry,x
                    stu       GS_FormationXCursor,x
                    ldd       W_XLoop,y
                    leau      d,y
                    stu       GS_XMotionLoop,x
                    ldd       W_Explosion,y
                    leau      d,y
                    stu       GS_ExplosionTemplate,x
                    ldd       W_ExplosionShape,y
                    leau      d,y
                    stu       GS_ExplosionShape,x
                    ldd       W_DiveShape,y
                    beq       WaveNoDiveShape
                    leau      d,y
                    stu       GS_DiveShape,x
WaveNoDiveShape  lda       W_Speed,y
                    sta       GS_FormationSpeed,x
                    lda       W_FireChance,y
                    sta       GS_EnemyFireChance,x
                    lda       W_KillPoints,y
                    sta       GS_KillPoints,x
                    lda       W_Mode,y
                    sta       GS_FormationMode,x
                    ldd       W_Kind,y
                    stb       GS_FormationType,x
                    lda       W_AnimationPeriod,y
                    sta       GS_FormationFramePeriod,x
                    sta       GS_FormationFrameClock,x
                    lda       W_Color1,y
                    sta       GS_EnemyColor01,x
                    sta       GS_EnemyColor11,x
                    lda       W_Color2,y
                    sta       GS_EnemyColor02,x
                    sta       GS_EnemyColor12,x
                    lda       #$FF
                    sta       GS_EnemyColor00,x
                    sta       GS_EnemyColor10,x
                    lda       #$F8
                    sta       GS_EnemyColor03,x
                    sta       GS_EnemyColor13,x
                    lda       #1
                    sta       GS_PaletteDirty,x
                    sta       GS_FormationClock,x
                    sta       GS_WaveClock,x
                    clr       GS_WaveComplete,x
                    clr       GS_BonusPrepared,x
                    clr       GS_ShotMissed,x
                    clr       GS_WaveReentered,x
                    clr       GS_DiverMissed,x
                    clr       GS_KillOrderBad,x
                    clr       GS_KillSequence,x
                    clr       GS_DiverActive,x
                    clr       GS_DiverEscaped,x
                    ldd       W_Object,y
                    leau      d,y
                    leay      GS_EnemyObject,x
                    tfr       u,x
                    ldu       #PLAYER_OBJECT_BYTES
                    lbsr      CopyBytes
                    ldx       WI_Game,s ; stack offset
                    ldy       GS_WaveDescriptor,x
                    ldd       W_Shape,y
                    leau      d,y
                    stu       GS_EnemyObject+OB_ShapePointer,x
                    ldd       W_Positions,y
                    leau      d,y
                    lda       ,u
                    lsla
                    adda      #2
                    tfr       a,b
                    clra
                    leay      GS_FormationOriginal,x
                    tfr       u,x
                    tfr       d,u
                    lbsr      CopyBytes
                    ldx       WI_Game,s ; stack offset
                    lbsr      ResetFormationPass
                    lda       GS_FormationType,x
                    cmpa      #WAVE_DIVERS
                    beq       WaveInitVariant
                    lda       #1
                    sta       GS_DiverMissed,x ; only divers can earn bonus 12
WaveInitVariant
                    lda       GS_FormationType,x
                    cmpa      #WAVE_INDEPENDENT
                    bne       WaveInitReturn
                    leay      GS_IndependentObjects,x
                    ldb       #IM_Count*IM_Bytes
WaveClearIndependent clr   ,y+
                    decb
                    bne       WaveClearIndependent
                    leay      GS_IndependentObjects,x
                    ldu       GS_YMotionStart,x
                    ldb       #IM_Count
WaveInitIndependent
                    lda       ,u+
                    sta       IM_Timer,y
                    pshs      b         stack offset: remaining independent ships
                    ldd       ,u++
                    addd      GS_YMotionStart,x
                    std       IM_Cursor,y
                    puls      b
                    leay      IM_Bytes,y
                    decb
                    bne       WaveInitIndependent
                    lda       #$81
                    sta       GS_IndependentBank,x
WaveInitReturn  puls      d,x,y,u,pc

* Original $2951..$299E restarts an escaped formation, keeping destroyed
* positions marked $80 in the original list. X game; preserve all.
ResetFormationPass
                    pshs      d,x,y,u
                    lda       GS_FormationMode,x
                    bita      #2
                    bne       FormationCopyPass
                    lda       #1
                    sta       GS_WaveReentered,x
                    lda       #$FF
                    leay      GS_OriginalPositions,x
                    ldb       GS_OriginalCount,x
FormationFindMinimum cmpa  ,y
                    bls       FormationMinimumNext
                    lda       ,y
FormationMinimumNext leay  FORMATION_POSITION_BYTES,y
                    decb
                    bne       FormationFindMinimum
                    suba      #G80_TILEMAP_STRIDE
                    pshs      a         stack offset: origin adjustment
                    leay      GS_OriginalPositions,x
                    ldb       GS_OriginalCount,x
FormationNormalizePass lda ,y
                    cmpa      #FORMATION_END
                    beq       FormationNormalizeNext
                    suba      ,s        stack offset: origin adjustment
                    sta       ,y
FormationNormalizeNext leay FORMATION_POSITION_BYTES,y
                    decb
                    bne       FormationNormalizePass
                    leas      1,s       discard local origin adjustment
FormationCopyPass lda      GS_OriginalCount,x
                    lsla
                    adda      #2
                    tfr       a,b
                    clra
                    leay      GS_FormationCells,x
                    leax      GS_FormationOriginal,x
                    tfr       d,u
                    lbsr      CopyBytes
                    ldx       WI_Game,s ; stack offset
                    ldd       GS_YMotionStart,x
                    std       GS_FormationYCursor,x
                    ldd       GS_XMotionEntry,x
                    std       GS_FormationXCursor,x
                    lda       #1
                    sta       GS_FormationClock,x
                    puls      d,x,y,u,pc

* Wave gate from original $2745, with the dispatch represented by a
* named enum rather than a jump into original ROM.
UpdateWaves      pshs      d,x,y,u
                    tst       GS_LevelComplete,x
                    bne       WavesReturn
                    tst       GS_WaveComplete,x
                    beq       WaveCheckClock
                    ldd       GS_LaserCooldown,x
                    bne       WavesReturn
                    lda       GS_ShotState,x
                    bita      #SHOT_ACTIVE
                    bne       WavesReturn
                    tst       GS_PlayerDisabled,x
                    bne       WavesReturn
                    tst       GS_BonusPrepared,x
                    bne       WaveBonusPrepared
                    inc       GS_BonusPrepared,x
                    lbsr      QueueWaveBonuses
                    bra       WavesReturn
WaveBonusPrepared
                    tst       GS_WaveDelay,x
                    beq       WaveNext
                    lda       #SFX_ENEMY_SHOT ; original $2763..$2778: laser2 and
                    lbsr      QueueAstroSound ; sonar every frame of the delay
                    lda       #SFX_SONAR
                    lbsr      QueueAstroSound
                    dec       GS_WaveDelay,x
                    bra       WavesReturn
WaveNext         inc       GS_WaveState,x
                    lbsr      InitializeWave
                    bra       WavesReturn
WaveCheckClock   dec       GS_WaveClock,x
                    bne       WavesReturn
                    lda       GS_GameSpeed,x
                    sta       GS_WaveClock,x
                    lda       GS_FormationType,x
                    cmpa      #WAVE_INDEPENDENT
                    beq       WaveIndependent
                    cmpa      #WAVE_DIVERS
                    bne       WaveOrdinary
                    lbsr      UpdateDiver
WaveOrdinary     lbsr      UpdateFormationMotion
                    bra       WaveCheckHits
WaveIndependent lbsr      UpdateIndependentFormation
WaveCheckHits    lbsr      ConsumeFormationHit
                    lbsr      RequestFormationShot
                    lbsr      CheckFormationPass
WavesReturn      puls      d,x,y,u,pc

* Original $2B8F row wrapping, offscreen re-entry and completion.
CheckFormationPass
                    pshs      d,x,y,u
                    tst       GS_OriginalAlive,x
                    beq       WaveFinished
                    clr       ,--s      stack offset: any nonnegative X flag
                    leay      GS_FormationPositions,x
                    ldb       GS_FormationCount,x
WavePosition     lda       ,y
                    cmpa      #FORMATION_END
                    beq       WavePositionNext
                    tsta
                    bmi       WaveWrapY
                    inc       ,s        stack offset: visible/entering ship
                    cmpa      #6
                    bhs       WaveWrapY
                    pshs      b         stack offset: remaining positions
                    ldd       GS_XMotionEntry,x
                    std       GS_FormationXCursor,x
                    puls      b
WaveWrapY        lda       GS_FormationMode,x
                    bita      #8
                    bne       WaveWrapUp
                    lda       1,y
                    cmpa      #G80_VISIBLE_TILE_ROWS
                    bne       WavePositionNext
                    lda       #$FE
                    sta       1,y
                    lda       #1
                    sta       GS_WaveReentered,x
                    bra       WavePositionNext
WaveWrapUp       lda       1,y
                    cmpa      #$FE
                    bne       WavePositionNext
                    lda       #G80_VISIBLE_TILE_ROWS
                    sta       1,y
                    lda       #1
                    sta       GS_WaveReentered,x
WavePositionNext leay      FORMATION_POSITION_BYTES,y
                    decb
                    bne       WavePosition
                    lda       ,s++      stack offset: remove two-byte local flag
                    bne       WavePassReturn
                    tst       GS_DiverActive,x
                    bne       WavePassReturn
                    lda       GS_FormationType,x
                    cmpa      #WAVE_INDEPENDENT
                    beq       WavePassReturn
                    lda       GS_FormationMode,x
                    bita      #1
                    beq       WaveFinished
                    lbsr      ResetFormationPass
WavePassReturn   puls      d,x,y,u,pc
WaveFinished     lda       #1
                    sta       GS_WaveComplete,x
                    lda       #WAVE_INTERVAL
                    sta       GS_WaveDelay,x
                    puls      d,x,y,u,pc
