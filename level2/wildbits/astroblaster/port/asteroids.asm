* Asteroid field and fuel pods, original $389A..$3F4F.
* X game, Y video, U process on entry; preserve all.
InitializeAsteroids
                    pshs      d,x,y,u
                    ldb       #AS_AsteroidPack
                    lbsr      LoadWaveData
                    lbcs      AsteroidInitReturn
                    tfr       x,u
                    ldx       WI_Game,s ; stack offset
                    stu       GS_StageRoot,x
                    ldd       AR_Object,u
                    leax      d,u
                    ldy       WI_Game,s ; stack offset
                    leay      GS_EnemyObject,y
                    lbsr      CopyStageObject
                    ldx       WI_Game,s ; stack offset
                    ldd       AR_Positions,u
                    leax      d,u
                    ldy       WI_Game,s ; stack offset
                    leay      GS_FormationCells,y
                    pshs      u
                    ldu       #ASTEROID_POSITION_BYTES
                    lbsr      CopyBytes
                    puls      u
                    ldx       WI_Game,s ; stack offset
                    ldd       AR_Explosion,u
                    leay      d,u
                    sty       GS_ExplosionTemplate,x
                    ldd       OB_ShapePointer,y
                    leay      d,u
                    sty       GS_ExplosionShape,x
                    ldd       AR_Pod,u
                    leax      d,u
                    ldy       WI_Game,s ; stack offset
                    leay      GS_PodObject,y
                    lbsr      CopyStageObject
                    ldx       WI_Game,s ; stack offset
                    lda       GS_Stage,x
                    cmpa      #STAGE_ASTEROIDS
                    beq       AsteroidResumeTimer
                    ldd       AR_Durations,u
                    leay      d,u
                    lda       GS_Level,x
                    deca
                    lsla
                    ldd       a,y
                    std       GS_AsteroidTicks,x
                    bra       AsteroidTimerReady
AsteroidResumeTimer lda   GS_AsteroidTicks,x
                    bne       AsteroidTimerReady
                    lda       #1
                    sta       GS_AsteroidTicks,x
AsteroidTimerReady
                    leay      GS_AsteroidRows,x
                    ldb       #ASTEROID_ROWS
AsteroidClearRow clr       ,y+
                    decb
                    bne       AsteroidClearRow
                    clr       GS_PodsMissed,x
                    clr       GS_SpecialTarget,x
                    clr       GS_SpecialHit,x
                    clr       GS_LevelComplete,x
                    lda       #ASTEROID_FIRST_SPAWN
                    sta       GS_AsteroidSpawnClock,x
                    lda       #1
                    sta       GS_Stage,x
                    sta       GS_AsteroidClock,x
                    sta       GS_PaletteDirty,x
                    sta       GS_FormationMode,x
                    lda       #$3E
                    sta       GS_WaveState,x
                    lda       #$F8
                    sta       GS_EnemyColor03,x
                    lda       #$3F
                    sta       GS_EnemyColor02,x
                    clr       GS_EnemyColor01,x
AsteroidInitReturn puls    d,x,y,u,pc

* X raw object, Y owned object, U pack root. Convert the root-relative
* shape pointer to a native address after copying. Preserve all.
CopyStageObject pshs      d,x,y,u
                    pshs      u
                    ldu       #PLAYER_OBJECT_BYTES
                    lbsr      CopyBytes
                    puls      u
                    ldx       WI_Game,s ; stack offset: original source object
                    ldy       WI_Video,s ; stack offset: original destination
                    ldd       OB_ShapePointer,x
                    leax      d,u
                    stx       OB_ShapePointer,y
                    puls      d,x,y,u,pc

UpdateAsteroids pshs      d,x,y,u
                    tst       GS_LevelComplete,x
                    lbne      AsteroidReturn
                    lbsr      UpdateFuelPod
                    clr       GS_EnemyObject+OB_DeltaX,x
                    dec       GS_AsteroidClock,x
                    lbne      AsteroidDrawOnly
                    lda       GS_GameSpeed,x
                    sta       GS_AsteroidClock,x
                    lda       #-2
                    sta       GS_EnemyObject+OB_DeltaX,x
                    lbsr      DrawFormationMotion
                    leay      GS_FormationPositions,x
                    ldb       GS_FormationCount,x
AsteroidFindExit lda       ,y
                    cmpa      #4
                    blo       AsteroidExited
                    leay      FORMATION_POSITION_BYTES,y
                    decb
                    bne       AsteroidFindExit
                    bra       AsteroidCheckSpawn
AsteroidExited   lbsr      RecycleAsteroid
AsteroidCheckSpawn dec     GS_AsteroidSpawnClock,x
                    bne       AsteroidCheckHit
                    lda       #ASTEROID_SPAWN_PERIOD
                    sta       GS_AsteroidSpawnClock,x
                    leay      GS_FormationPositions,x
                    ldb       GS_FormationCount,x
AsteroidFindSpawn lda      ,y
                    cmpa      #G80_TILEMAP_STRIDE
                    bne       AsteroidNextSpawn
                    tst       1,y
                    bne       AsteroidNextSpawn
                    lbsr      ChooseAsteroidRow
                    sta       1,y
                    bra       AsteroidCheckHit
AsteroidNextSpawn leay     FORMATION_POSITION_BYTES,y
                    decb
                    bne       AsteroidFindSpawn
AsteroidCheckHit tst       GS_ShotHitX,x
                    beq       AsteroidTick
                    leay      GS_FormationPositions,x
                    ldb       GS_FormationCount,x
AsteroidFindHit  lda       GS_ShotHitY,x
                    cmpa      1,y
                    bne       AsteroidNextHit
                    lda       GS_ShotHitX,x
                    suba      ,y
                    adda      #2
                    cmpa      #4
                    blo       AsteroidHit
AsteroidNextHit  leay      FORMATION_POSITION_BYTES,y
                    decb
                    bne       AsteroidFindHit
                    bra       AsteroidTick
AsteroidHit      pshs      y         stack offset: struck position
                    ldd       ,y
                    std       GS_ExplosionX,x
                    std       GS_EnemyObject+OB_TileX,x
                    ldd       GS_EnemyObject+OB_PixelX,x
                    std       GS_ExplosionPixelX,x
                    leax      GS_EnemyObject,x
                    ldy       OB_ShapePointer,x
                    ldu       WI_Video+2,s ; stack offset past position pointer
                    lbsr      EraseObjectBody
                    ldx       WI_Game+2,s ; stack offset
                    puls      y
                    lbsr      RecycleAsteroid
                    clr       GS_ShotHitX,x
                    clr       GS_ShotHitY,x
                    lda       #$10
                    lbsr      AddPlayerScore
AsteroidTick     ldd       GS_AsteroidTicks,x
                    beq       AsteroidDone
                    subd      #1
                    std       GS_AsteroidTicks,x
                    bne       AsteroidReturn
AsteroidDone     tst       GS_PlayerDisabled,x
                    bne       AsteroidReturn
                    lda       #1
                    sta       GS_LevelComplete,x
                    ldy       WI_Video,s ; stack offset: original video
                    lbsr      QueueAsteroidBonuses
AsteroidReturn   puls      d,x,y,u,pc
AsteroidDrawOnly lbsr      DrawFormationMotion
                    puls      d,x,y,u,pc

* X game/Y coordinate pair. Release its row and recycle at X=34 until
* the last 130 field ticks, then retire it. Preserve D/X/Y/U.
RecycleAsteroid pshs      d,x,y,u
                    lda       1,y
                    lbsr      ReleaseAsteroidRow
                    ldd       GS_AsteroidTicks,x
                    cmpd      #ASTEROID_DRAIN_TICKS
                    blo       AsteroidRetire
                    ldd       #34*256
                    bra       AsteroidRecycleStore
AsteroidRetire   ldd       #FORMATION_END*256+FORMATION_END
AsteroidRecycleStore std   ,y
                    puls      d,x,y,u,pc
ReleaseAsteroidRow pshs    d,y
                    tsta
                    beq       AsteroidRowReleased
                    cmpa      #ASTEROID_ROWS
                    bhi       AsteroidRowReleased
                    deca
                    leay      GS_AsteroidRows,x
                    clr       a,y
AsteroidRowReleased puls   d,y,pc

* A free row, at most 25 probes. Fourteen rocks and one pod cannot fill
* all 25 rows. Keep returned coordinate paired with its reservation.
ChooseAsteroidRow pshs     b
                    lbsr      NextGameRandom
                    ldb       #ASTEROID_ROWS
                    lbsr      Remainder8
                    inca
                    puls      b
* A desired row (1..25); keep searching from it if it is occupied.
AsteroidReserveCandidate
                    pshs      b,x,y,u
                    leay      GS_AsteroidRows,x
                    leay      -1,y
                    ldb       #ASTEROID_ROWS
AsteroidRowProbe tst       a,y
                    beq       AsteroidReserveRow
                    inca
                    cmpa      #ASTEROID_ROWS
                    bls       AsteroidProbeNext
                    lda       #1
AsteroidProbeNext decb
                    bne       AsteroidRowProbe
                    clra                no unbounded search on corrupted state
                    bra       AsteroidRowChosen
AsteroidReserveRow inc     a,y
AsteroidRowChosen puls     b,x,y,u,pc

UpdateFuelPod    pshs      d,x,y,u
                    tst       GS_SpecialTarget,x
                    beq       PodTrySpawn
                    tst       GS_SpecialHit,x
                    lbne      PodHit
                    clr       GS_PodObject+OB_DeltaX,x
                    dec       GS_PodClock,x
                    bne       PodMove
                    lda       GS_GameSpeed,x
                    sta       GS_PodClock,x
                    lda       #-3
                    sta       GS_PodObject+OB_DeltaX,x
PodMove          lda       GS_PodObject+OB_TileX,x
                    cmpa      #4
                    blo       PodMissed
                    leax      GS_PodObject,x
                    ldy       OB_ShapePointer,x
                    ldu       WI_Video,s ; stack offset
                    lbsr      MoveObject
                    lbsr      AdvanceObjectPattern
                    lbsr      RenderObjectPatterns
                    lbsr      DrawObjectTiles
                    bra       PodReturn
PodTrySpawn      ldd       GS_AsteroidTicks,x
                    cmpd      #ASTEROID_DRAIN_TICKS
                    blo       PodReturn
                    ldu       GS_StageRoot,x
                    ldd       AR_PodColors,u
                    leay      d,u
                    pshs      x
                    leax      GS_PodColors,x
                    ldb       #4
PodCopyColor     lda       ,y+
                    sta       ,x+
                    decb
                    bne       PodCopyColor
                    puls      x
* Original $3EC4: random % 24, +2, clear bit zero, then reserve.
                    lbsr      NextGameRandom
                    ldb       #24
                    lbsr      Remainder8
                    adda      #2
                    anda      #$FE
                    lbsr      AsteroidReserveCandidate
                    sta       GS_PodObject+OB_TileY,x
                    lda       #32
                    sta       GS_PodObject+OB_TileX,x
                    lda       #$FF      pod present; $01 means beam struck pod class
                    sta       GS_SpecialTarget,x
                    lda       #1
                    sta       GS_PodClock,x
                    sta       GS_PaletteDirty,x
                    clr       GS_SpecialHit,x
PodReturn        puls      d,x,y,u,pc
PodMissed        lda       #1
                    sta       GS_PodsMissed,x
                    bra       PodRemove
PodHit           lda       GS_FuelLevel,x
                    cmpa      #FUEL_MAX
                    bhs       PodQueueExplosion
                    inc       GS_FuelLevel,x
                    pshs      x,y
                    exg       x,y
                    lbsr      DrawFuelGauge
                    puls      x,y
PodQueueExplosion ldd      GS_PodObject+OB_TileX,x
                    std       GS_ExplosionX,x
                    ldd       GS_PodObject+OB_PixelX,x
                    std       GS_ExplosionPixelX,x
PodRemove        lda       GS_PodObject+OB_TileY,x
                    lbsr      ReleaseAsteroidRow
                    clr       GS_SpecialTarget,x
                    clr       GS_SpecialHit,x
                    leax      GS_PodObject,x
                    ldy       OB_ShapePointer,x
                    ldu       WI_Video,s ; stack offset
                    lbsr      EraseObjectBody
                    puls      d,x,y,u,pc
