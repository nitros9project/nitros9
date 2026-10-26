* fs_systems.asm - FS (Flight Simulator II), part of the port: yaw term, engine model, timer ticks, radio navigation (VOR, ILS, DME, markers), failures,
* instrument cover masks, module padding ($52A5-end)
* Assembled by fs.asm (use); absolute self-references are label+ModBase.

* ComputeYawTerm: $078C = $0812 times $07E9 (or $07EB when stalled), probably a rudder/yaw term
ComputeYawTerm               ldd       >vAileron
                    std       <vMulA
                    ldd       >vAilLiftK
                    tst       >vStallTime
                    beq       ElevTermMulStore
                    ldd       >vAilStallK
* ElevTermMulStore: Inside ComputeYawTerm: multiply the selected coefficient (D) by $0812 (probably elevator) and store the product at $078C
ElevTermMulStore               jsr       >MulQ15+ModBase
                    std       >vAilLift
* UpdatePitchCtlTerms: Probably pitch-control terms: $0761=(($0812/2)-($082B/2))<<8 (probably elevator minus trim), scales $07DF/$07D7/$07D9/$07D5 into $0784/$0763/$07B5/$0765, sets $0790/$0792 = $0794+$0751 -/+ $078C
UpdatePitchCtlTerms               lda       >vRudder
                    asra
                    sta       <vRudderHalf
                    lda       >vAileron
                    asra
                    suba      <vRudderHalf
                    clrb
                    std       >vSlip
                    std       <vMulA
                    ldd       >vSlipDragK
                    jsr       >MulQ15+ModBase
                    std       >vSlipDrag
                    ldd       >vSlip
                    std       <vMulA
                    ldd       >vSlipTurnK
                    jsr       >MulQ15+ModBase
                    std       >vSlipTurn
                    ldd       >vSlip
                    std       <vMulA
                    ldd       >vSlipTrackK
                    jsr       >MulQ15+ModBase
                    std       >vTrackOfs
                    ldd       >vSlip
                    std       <vMulA
                    ldd       >vSlipRollK
                    jsr       >MulQ15+ModBase
                    std       >vSlipRoll
                    ldd       >vFlapLift
                    addd      >vLiftBaseK
                    tfr       d,y
                    subd      >vAilLift
                    std       >vWingCoefR
                    tfr       y,d
                    addd      >vAilLift
                    addd      >vSlipRoll
                    std       >vWingCoefL
                    rts
* TblRpmByThrottle: 32-byte engine RPM gauge value indexed by (throttle high byte - drops)/4
TblRpmByThrottle               fcb       $0D,$0F,$11,$13,$15,$16,$18,$19
                    fcb       $1B,$1C,$1D,$1E,$1F
                    fcc       / !"#$%&'()*+,-./
                    fcb       $2F
                    fcc       /012/
* TblWindmillRpmByAirspeed: 32-byte minimum (windmilling) RPM value indexed by airspeed $07BB/4
TblWindmillRpmByAirspeed               fcb       $00,$02,$07,$09,$0D,$10,$11,$12
                    fcb       $13,$16,$19,$1C,$1E
                    fcc       / "$&(*-369<?BEHKNQT/
* UpdateEngine: Engine model run every 2 sim seconds: running flag $0738 (magnetos, tank fuel, starter/windmill restart), target RPM $072D, thrust $07B7, oil temp $0739 / pressure $073B ramps, fuel burn and leaks
UpdateEngine               lda       >vEurope1917
                    bne       UpdateEngineChkFuel
                    lda       >vReality
                    beq       UpdateEngineChkFuel
                    lda       >vMag1
                    anda      >vMag1Ok
                    sta       <vMag1Fires
                    lda       >vMag2
                    anda      >vMag2Ok
                    ora       <vMag1Fires
                    bne       UpdateEngineChkFuel
* UpdateEngineStop: Engine dies: clear running flag $0738, then compute RPM
UpdateEngineStop               clr       >vEngineOn
                    jmp       >UpdateEngineCalcRpm+ModBase
* UpdateEngineChkFuel: Check fuel in the selected tank ($0735: 0 = left $0731, else right $0734)
UpdateEngineChkFuel               lda       >vFuelTank
                    bne       UpdateEngineChkRight
                    lda       >vFuelL
                    beq       UpdateEngineStop
                    bne       UpdateEngineChkStart
* UpdateEngineChkRight: Right tank selected: stop engine if $0734 is empty
UpdateEngineChkRight               lda       >vFuelR
                    beq       UpdateEngineStop
* UpdateEngineChkStart: Fuel present: keep running, auto-start when $0305 clear, restart by windmill (airspeed >= $25) or key in START ($0825=4)
UpdateEngineChkStart               lda       >vReality
                    ora       >vEngineOn
                    beq       UpdateEngineSetRunning
                    lda       >vEngineOn
                    bne       UpdateEngineCalcRpm
                    lda       >vAirspeed
                    cmpa      #WindmillRestartSpd
                    bhs       UpdateEngineSetRunning
                    lda       >vMagSw
                    cmpa      #MagSwStart
                    bne       UpdateEngineCalcRpm
                    ldx       #CrankLoopsOuter
* UpdateEngineCrankOuter: Starter cranking delay, outer loop (X=5)
UpdateEngineCrankOuter               ldy       #CrankLoopsInner
* UpdateEngineCrankInner: Starter cranking delay, inner loop (Y=$FF)
UpdateEngineCrankInner               leay      -1,y
                    bne       UpdateEngineCrankInner
                    leax      -1,x
                    bne       UpdateEngineCrankOuter
                    lda       #MagSwBoth
                    jsr       >SetMagnetoSwitch+ModBase
* UpdateEngineSetRunning: Set engine running flag $0738=1
UpdateEngineSetRunning               lda       #EngineRunning
                    sta       >vEngineOn
* UpdateEngineCalcRpm: Compute RPM: windmill minimum into $A7 from airspeed, throttle $0837 into B
UpdateEngineCalcRpm               lda       >vAirspeed
                    lsra
                    lsra
                    cmpa      #WindmillTblLast
                    blo       UpdateEngineWindmillLook
                    lda       #WindmillTblLast
* UpdateEngineWindmillLook: Look up TblWindmillRpmByAirspeed with clamped index
UpdateEngineWindmillLook               ldx       #TblWindmillRpmByAirspeed+ModBase
                    lda       a,x
                    sta       >vWindmillRpm
                    ldb       >vThrottle
                    lda       >vEngineOn
                    beq       UpdateEngineNoPower
                    lda       >vCarbHeat
                    beq       UpdateEngineDamageLimit
                    lda       #CarbHeatDrop
                    tst       >vCarbIce
                    beq       UpdateEngineCarbDrop
                    lda       #CarbIceDrop
                    dec       >vCarbIce
* UpdateEngineCarbDrop: Add throttle to the carburetor drop (-8, or -$20 while ice counter $0DCD runs); probably carb heat/icing effect
UpdateEngineCarbDrop               adda      >vThrottle
                    tfr       a,b
                    bpl       UpdateEngineDamageLimit
* UpdateEngineNoPower: Engine off or negative result: B=0 power
UpdateEngineNoPower               clrb
* UpdateEngineDamageLimit: Engine damage bits ($072E bits 0-1) limit power to $10
UpdateEngineDamageLimit               lda       >vDamageBits
                    anda      #DmgEngine
                    beq       UpdateEngineMagDrop
                    cmpb      #DmgPowerMax
                    blo       UpdateEngineMagDrop
                    ldb       #DmgPowerMax
* UpdateEngineMagDrop: If only one magneto works ($0DCB&$0736 / $0DCC&$0737) subtract 4 (mag drop)
UpdateEngineMagDrop               lda       >vMag1
                    anda      >vMag1Ok
                    beq       UpdateEngineSubMag
                    lda       >vMag2
                    anda      >vMag2Ok
                    bne       UpdateEngineRpmLookup
* UpdateEngineSubMag: Subtract the single-magneto drop, floor at 0
UpdateEngineSubMag               subb      #MagDrop
                    bpl       UpdateEngineRpmLookup
                    clrb
* UpdateEngineRpmLookup: B/4 indexes TblRpmByThrottle; RPM 0 if engine stopped
UpdateEngineRpmLookup               lsrb
                    lsrb
                    ldx       #TblRpmByThrottle+ModBase
                    lda       b,x
                    ldx       >vEngineOn
                    bne       UpdateEngineStoreRpm
                    clra
* UpdateEngineStoreRpm: Store target RPM $072D; below $0E counts as 0 for thrust
UpdateEngineStoreRpm               sta       >vRpmTarget
                    cmpa      #ThrustRpmMin
                    bhs       UpdateEngineThrust
                    clra
* UpdateEngineThrust: $07B7 = RPM * $07D0 * $0749 (probably thrust); apply windmill minimum
UpdateEngineThrust               sta       <vMulA
                    clr       <vMulA+1
                    ldd       #ThrustRpmScale
                    jsr       >MulQ15Store+ModBase
                    ldd       >vAirDensity
                    jsr       >MulQ15+ModBase
                    std       >vThrust
                    lda       >vWindmillRpm
                    cmpa      >vRpmTarget
                    bmi       UpdateEngineIdleMin
                    sta       >vRpmTarget
* UpdateEngineIdleMin: When $0305 clear, keep target RPM at least $0D
UpdateEngineIdleMin               lda       >vReality
                    bne       UpdateEngineOilTemp
                    lda       >vRpmTarget
                    cmpa      #RpmIdle
                    bhs       UpdateEngineOilTemp
                    lda       #RpmIdle
                    sta       >vRpmTarget
* UpdateEngineOilTemp: Oil temperature target (0, 9, or $12 with damage bit0 clear) - probably
UpdateEngineOilTemp               clrb
                    lda       >vEngineOn
                    beq       UpdateEngineOilTempRamp
                    ldb       #OilTempRun
                    lda       >vDamageBits
                    anda      #DmgOilHot
                    beq       UpdateEngineOilTempRamp
                    ldb       #OilTempHot
* UpdateEngineOilTempRamp: Compare target with $0739 and step it by $0019
UpdateEngineOilTempRamp               cmpb      >vOilTemp
                    beq       UpdateEngineOilPress
                    blo       UpdateEngineOilTempDown
                    ldd       >vOilTemp
                    addd      #OilTempStep
                    bra       UpdateEngineOilTempStore
* UpdateEngineOilTempDown: Step $0739 down by $0019
UpdateEngineOilTempDown               ldd       >vOilTemp
                    subd      #OilTempStep
* UpdateEngineOilTempStore: Store new $0739
UpdateEngineOilTempStore               std       >vOilTemp
* UpdateEngineOilPress: Oil pressure target (0, or $0A while running without damage bit1) - probably
UpdateEngineOilPress               clrb
                    lda       >vEngineOn
                    beq       UpdateEngineOilPressRamp
                    lda       >vDamageBits
                    anda      #DmgOilPress
                    bne       UpdateEngineOilPressRamp
                    ldb       #OilPressRun
* UpdateEngineOilPressRamp: Compare target with $073B and step it by $00FA
UpdateEngineOilPressRamp               cmpb      >vOilPress
                    beq       UpdateEngineFuelBurn
                    blo       UpdateEngineOilPressDown
                    ldd       >vOilPress
                    addd      #OilPressStep
                    bra       UpdateEngineOilPressStore
* UpdateEngineOilPressDown: Step $073B down by $00FA
UpdateEngineOilPressDown               ldd       >vOilPress
                    subd      #OilPressStep
* UpdateEngineOilPressStore: Store new $073B
UpdateEngineOilPressStore               std       >vOilPress
* UpdateEngineFuelBurn: If running and seconds bit1: fuel rate = $FB (x8 when $0307, probably WWI mode) * throttle
UpdateEngineFuelBurn               lda       >vEngineOn
                    lbeq      UpdateEngineDone
                    lda       >vSecond
                    anda      #FuelBurnSecBit
                    lbeq      UpdateEngineDone
                    ldb       #FuelBurnRate
                    lda       >vEurope1917
                    beq       UpdateEngineFuelRate
                    aslb
                    aslb
                    aslb
* UpdateEngineFuelRate: Signed multiply rate by throttle into <$90; left tank leak if $072E bit2
UpdateEngineFuelRate               lda       >vThrottle
                    jsr       >MulSigned8+ModBase
                    std       <vFuelBurnStep
                    lda       >vDamageBits
                    anda      #DmgLeakL
                    beq       UpdateEngineBurnLeft
                    dec       >vFuelL
                    bpl       UpdateEngineBurnLeft
                    inc       >vFuelL
* UpdateEngineBurnLeft: Left tank selected: subtract burn from $0731:$072F
UpdateEngineBurnLeft               lda       >vFuelTank
                    bne       UpdateEngineLeakRight
                    ldd       <vFuelBurnStep
                    beq       UpdateEngineDone
                    addd      >vFuelLFrac
                    std       >vFuelLFrac
                    lda       #FuelBurnSignExt
                    adca      >vFuelL
                    bmi       UpdateEngineLeakRight
                    sta       >vFuelL
* UpdateEngineLeakRight: Right tank leak if $072E bit3
UpdateEngineLeakRight               lda       >vDamageBits
                    anda      #DmgLeakR
                    beq       UpdateEngineBurnRight
                    dec       >vFuelR
                    bpl       UpdateEngineBurnRight
                    inc       >vFuelR
* UpdateEngineBurnRight: Right tank selected: subtract burn from $0734:$0732
UpdateEngineBurnRight               lda       >vFuelTank
                    beq       UpdateEngineDone
                    ldd       <vFuelBurnStep
                    beq       UpdateEngineDone
                    addd      >vFuelRFrac
                    std       >vFuelRFrac
                    lda       #FuelBurnSignExt
                    adca      >vFuelR
                    bmi       UpdateEngineDone
                    sta       >vFuelR
* UpdateEngineDone: Return
UpdateEngineDone               rts
* SmoothRpmNeedle: Move displayed RPM $072C toward target $072D by 2 per tick
SmoothRpmNeedle               lda       >vRpm
                    cmpa      >vRpmTarget
                    beq       SmoothRpmNeedleDone
                    blo       SmoothRpmNeedleUp
                    suba      #RpmStep
                    cmpa      #RpmBelowZero
                    bhs       SmoothRpmNeedleSnap
                    cmpa      >vRpmTarget
                    bhs       SmoothRpmNeedleStore
* SmoothRpmNeedleSnap: Overshoot/underflow: take target value
SmoothRpmNeedleSnap               lda       >vRpmTarget
* SmoothRpmNeedleStore: Store new $072C
SmoothRpmNeedleStore               sta       >vRpm
* SmoothRpmNeedleDone: Return
SmoothRpmNeedleDone               rts
* SmoothRpmNeedleUp: Step displayed RPM up by 2
SmoothRpmNeedleUp               adda      #RpmStep
                    cmpa      >vRpmTarget
                    bhs       SmoothRpmNeedleSnap
                    bra       SmoothRpmNeedleStore
* SignalIntercept: F$Icpt signal handler (code stored as fcb): on signal $80 set pending tick $0896=1 and decrement $0289 if nonzero, then RTI
SignalIntercept               fcb       $C1,$80,$10,$26,$00,$0D,$C6,$01
                    fcb       $F7,$08,$96,$B6,$02,$89,$27,$03
                    fcb       $7A,$02,$89,$3B
* ProcessTimerTicks: Run pending ticks ($0896): RPM smoothing, ComputeAerodynamics/UpdAirspeedNeedle/UpdVsiNeedle; every 5 ticks advance clock sec $0287 / min $0322 / hour $0321; every 2 s StepElevatorDrift and UpdateEngine
ProcessTimerTicks               lda       >vPaused
                    bne       ProcessTimerTicksNext
                    jsr       >SmoothRpmNeedle+ModBase
                    jsr       >ComputeAerodynamics+ModBase
                    jsr       >UpdAirspeedNeedle+ModBase
                    jsr       >UpdVsiNeedle+ModBase
                    inc       >vSecTicks
                    bne       ProcessTimerTicksNext
                    lda       #SecTicksStart
                    sta       >vSecTicks
                    ldb       >vSecond
                    cmpb      #ClockLastSec
                    bne       ProcessTimerTicksSecStore
                    lda       >vMinute
                    cmpa      #ClockLastMin
                    bne       ProcessTimerTicksMinStore
                    inc       >vHour
                    lda       >vHour
                    cmpa      #ClockHours
                    bne       ProcessTimerTicksMinZero
                    clr       >vHour
* ProcessTimerTicksMinZero: Hour advanced (wrap 24): minutes restart at 0
ProcessTimerTicksMinZero               lda       #ClockZeroLess1
* ProcessTimerTicksMinStore: Store minutes $0322; seconds restart at 0
ProcessTimerTicksMinStore               inca
                    sta       >vMinute
                    ldb       #ClockZeroLess1
* ProcessTimerTicksSecStore: Store seconds $0287, redraw clock, count 2-second phase $028A
ProcessTimerTicksSecStore               incb
                    stb       >vSecond
                    jsr       >DrawClockSeconds+ModBase
                    inc       >vSecCount
                    lda       >vSecCount
                    anda      #TwoSecondBit
                    bne       ProcessTimerTicksNext
                    jsr       >StepElevatorDrift+ModBase
                    jsr       >UpdateEngine+ModBase
* ProcessTimerTicksNext: Decrement pending tick count $0896, loop
ProcessTimerTicksNext               dec       >vTickPend
                    bne       ProcessTimerTicks
                    rts
* UpdateNav1: NAV1: OBS $09A8 (or ILS course from $0154 when $029F), station record $029B; sets TO/FROM $0723, CDI target $071E, then glideslope/DME
UpdateNav1               lda       >vNav1Obs
                    tst       >vNav1Loc
                    beq       UpdateNav1Calc
                    ldd       >vIlsCourse
                    std       >vMulA
                    ldd       #IlsCourseToObs
                    jsr       >MulQ15+ModBase
                    tfr       b,a
* UpdateNav1Calc: Compute NAV1 deviation and flag
UpdateNav1Calc               ldb       #Nav1Rx
                    ldx       #vNav1StnRec
                    jsr       >ComputeVorDeviation+ModBase
                    sta       >vNav1Flag
                    jsr       >CdiDeviationToNeedle+ModBase
                    stb       >vNav1CdiGoal
                    jmp       >UpdateGlideslopeDme+ModBase
* ComputeVorDeviation: In A=OBS (2-degree units), B=receiver bit, X=station; out A=TO/FROM/OFF flag, <$A3=deviation (0 if $028E says no signal)
ComputeVorDeviation               andb      >vNavRx
                    bne       ComputeVorDeviationRx
                    clra
                    std       <vVorDev
                    rts
* ComputeVorDeviationRx: Receiving: bearing to station, OBS-bearing scaled by $021C, classify
ComputeVorDeviationRx               sta       <vVorObs
                    jsr       >ComputeStationBearing+ModBase
                    ldb       <vVorObs
                    clra
                    std       >vMulA
                    ldd       #ObsToAngle
                    jsr       >MulU16Mid+ModBase
                    ldd       <vMulProd+2
                    subd      <vStnBearing
                    std       >vMulA
                    ldd       #DevHalfTurn
                    jsr       >MulQ15+ModBase
                    std       <vVorDev
                    jmp       >ComputeToFromFlag+ModBase
* UpdateNav2: NAV2: OBS $09A9, station record $0293; sets TO/FROM $0724 and CDI target $0720
UpdateNav2               ldb       #Nav2Rx
                    lda       >vNav2Obs
                    ldx       #vNav2StnRec
                    jsr       >ComputeVorDeviation+ModBase
                    sta       >vNav2Flag
                    jsr       >CdiDeviationToNeedle+ModBase
                    stb       >vNav2CdiGoal
                    rts
* DrawNav1Indicator: If NAV1 shown ($EB bit5): redraw TO/FROM icon on change, step CDI $071D toward $071E and glideslope $0721 toward $0722 (XOR), then marker lights
DrawNav1Indicator               lda       >vInstActive1
                    anda      #InstNav1
                    beq       DrawNav1IndDone
                    lda       >vNav1Flag
                    cmpa      >vNav1FlagShown
                    beq       DrawNav1IndCdi
                    sta       >vNav1FlagShown
                    ldb       >vNav1Cdi
                    pshs      b
                    jsr       >XorNav1CdiNeedle+ModBase
                    lda       >vGsNeedle
                    pshs      a
                    jsr       >XorGlideslopeNeedle+ModBase
                    ldb       >vNav1Flag
                    jsr       >DrawNavFlagIcon+ModBase
                    puls      a
                    jsr       >XorGlideslopeNeedle+ModBase
                    puls      b
                    jsr       >XorNav1CdiNeedle+ModBase
* DrawNav1IndCdi: Step NAV1 CDI needle one position
DrawNav1IndCdi               ldb       >vNav1Cdi
                    cmpb      >vNav1CdiGoal
                    beq       DrawNav1IndGs
                    pshs      cc,b
                    jsr       >XorNav1CdiNeedle+ModBase
                    puls      cc,b
                    bgt       DrawNav1IndCdiStep
                    addb      #StepFlip
* DrawNav1IndCdiStep: Apply -1/+1 to CDI position and redraw
DrawNav1IndCdiStep               subb      #NeedleStep
                    stb       >vNav1Cdi
                    jsr       >XorNav1CdiNeedle+ModBase
* DrawNav1IndGs: Step glideslope needle one position
DrawNav1IndGs               lda       >vGsNeedle
                    cmpa      >vGsGoal
                    beq       DrawNav1IndMarkers
                    pshs      cc,a
                    jsr       >XorGlideslopeNeedle+ModBase
                    puls      cc,a
                    bgt       DrawNav1IndGsStep
                    adda      #StepFlip
* DrawNav1IndGsStep: Apply -1/+1 to glideslope position and redraw
DrawNav1IndGsStep               suba      #NeedleStep
                    sta       >vGsNeedle
                    jsr       >XorGlideslopeNeedle+ModBase
* DrawNav1IndMarkers: Draw marker beacon lights
DrawNav1IndMarkers               jsr       >DrawMarkerLights+ModBase
* DrawNav1IndDone: Return
DrawNav1IndDone               rts
* DrawNav2Indicator: If NAV2 shown ($ED bit3) and $0348 clear: redraw TO/FROM icon on change, step CDI $071F toward $0720
DrawNav2Indicator               lda       >vInstActive3
                    anda      #InstNav2
                    beq       DrawNav2IndDone
                    lda       >vAdfEnable
                    bne       DrawNav2IndDone
                    lda       >vNav2Flag
                    cmpa      >vNav2FlagShown
                    beq       DrawNav2IndCdi
                    sta       >vNav2FlagShown
                    ldb       >vNav2Cdi
                    pshs      b
                    jsr       >XorNav2CdiNeedle+ModBase
                    ldb       >vNav2Flag
                    addb      #Nav2FlagRec
                    jsr       >DrawNavFlagIcon+ModBase
                    puls      b
                    jsr       >XorNav2CdiNeedle+ModBase
* DrawNav2IndCdi: Step NAV2 CDI needle one position
DrawNav2IndCdi               ldb       >vNav2Cdi
                    cmpb      >vNav2CdiGoal
                    beq       DrawNav2IndDone
                    pshs      cc,b
                    jsr       >XorNav2CdiNeedle+ModBase
                    puls      cc,b
                    bgt       DrawNav2IndCdiStep
                    addb      #StepFlip
* DrawNav2IndCdiStep: Apply -1/+1 to NAV2 CDI position and redraw
DrawNav2IndCdiStep               subb      #NeedleStep
                    stb       >vNav2Cdi
                    jsr       >XorNav2CdiNeedle+ModBase
* DrawNav2IndDone: Return
DrawNav2IndDone               rts
* XorGlideslopeNeedle: WildBits (2026-10-20): FS's CoCo panel glideslope needle is not drawn (the dash, fsp, draws the
* instruments; the callers keep stepping $0721); the XOR drawing is gone, its bytes zero so no FS address moves
XorGlideslopeNeedle               rts
                    zmb       29
* XorGlideslopeNeedleDone: Return
XorGlideslopeNeedleDone               rts
* DrawNavFlagIcon: B=flag icon index (NAV1 0-2, NAV2 3-5): draw text record $0A3B+8*B in white
DrawNavFlagIcon               aslb
                    aslb
                    aslb
                    ldx       #vNavFlagTxt
                    abx
                    jmp       >PrintPanelTextF+ModBase
* ComputeStationBearing: X=station record: deltas to aircraft position (<$00-03, <$08-0B) into $0728/$072A, normalized, <$A3 = atan2 bearing minus $014A and $0148 (probably magnetic variation)
ComputeStationBearing               ldd       <vPosZ+2
                    subd      4,x
                    tfr       d,y
                    ldd       <vPosZ
                    sbcb      7,x
                    sbca      6,x
                    jsr       >Shl32By4DY+ModBase
                    std       >vStationDZ
                    std       <vAtanY
                    sty       <vAtanYLo
                    ldd       <vPosX+2
                    subd      ,x
                    tfr       d,y
                    ldd       <vPosX
                    sbcb      3,x
                    sbca      2,x
                    jsr       >Shl32By4DY+ModBase
                    std       >vStationDX
                    std       <vAtanX
                    sty       <vAtanXLo
* ComputeStationBearingNorm: Shift both deltas left until one leaves the +/-$10xx range
ComputeStationBearingNorm               lda       <vAtanY
                    adda      #StnNormBias
                    cmpa      #StnNormSpan
                    bhs       ComputeStationBearingAtan
                    lda       <vAtanX
                    adda      #StnNormBias
                    cmpa      #StnNormSpan
                    bhs       ComputeStationBearingAtan
                    orcc      #Carry
                    rol       <vAtanYLo
                    rol       <vAtanY+1
                    rol       <vAtanY
                    asl       <vAtanXLo
                    rol       <vAtanX+1
                    rol       <vAtanX
                    bra       ComputeStationBearingNorm
* ComputeStationBearingAtan: Atan2 of deltas and correction
ComputeStationBearingAtan               jsr       >Atan2Angle+ModBase
                    subd      >vHdgOfs2
                    subd      >vHdgOfs1
                    std       <vStnBearing
                    rts
* Shl32By4DY: Shift 32-bit value D:Y (D high) left 4 bits
Shl32By4DY               exg       d,y
                    aslb
                    rola
                    exg       y,d
                    rolb
                    rola
                    exg       d,y
                    aslb
                    rola
                    exg       y,d
                    rolb
                    rola
                    exg       d,y
                    aslb
                    rola
                    exg       y,d
                    rolb
                    rola
                    exg       d,y
                    aslb
                    rola
                    exg       y,d
                    rolb
                    rola
                    rts
* ComputeToFromFlag: Classify scaled deviation D: |D|<$100 A=2 (probably TO), $100-$12B A=0 and <$A3=0 (OFF), else reflect around +/-$021C and A=1 (probably FROM)
ComputeToFromFlag               tsta
                    bmi       ComputeToFromFlagNeg
                    cmpa      #DevOffHi
                    blo       ComputeToFromFlagTo
                    bne       ComputeToFromFlagFromPos
                    cmpb      #DevOffEndLo
                    blo       ComputeToFromFlagOff
                    bra       ComputeToFromFlagFromPos
* ComputeToFromFlagNeg: Negative deviation cases
ComputeToFromFlagNeg               cmpa      #DevOffNegHi
                    blo       ComputeToFromFlagFromNeg
                    bne       ComputeToFromFlagTo
                    cmpb      #DevOffNegEndLo
                    blo       ComputeToFromFlagFromNeg
                    bra       ComputeToFromFlagOff
* ComputeToFromFlagFromPos: Positive: <$A3 = $021C - <$A3
ComputeToFromFlagFromPos               ldd       #DevHalfTurn
                    bra       ComputeToFromFlagReflect
* ComputeToFromFlagFromNeg: Negative: <$A3 = -$021C - <$A3
ComputeToFromFlagFromNeg               ldd       #DevHalfTurnNeg
* ComputeToFromFlagReflect: Store reflected deviation, A=1
ComputeToFromFlagReflect               subd      <vVorDev
                    std       <vVorDev
                    lda       #NavFlagTo
                    rts
* ComputeToFromFlagTo: A=2, deviation unchanged
ComputeToFromFlagTo               lda       #NavFlagFrom
                    rts
* ComputeToFromFlagOff: Deviation 0, A=0
ComputeToFromFlagOff               clra
                    clrb
                    std       <vVorDev
                    rts
* XorNav2CdiNeedle, XorNav1CdiNeedle, XorCdiNeedleCommon: WildBits (2026-10-20): FS's CoCo panel CDI needles are not
* drawn (the dash, fsp, draws NAV1 and NAV2 from $071E / $0720; the callers keep stepping $071D / $071F); the XOR
* drawing is gone, its bytes zero so no FS address moves
XorNav2CdiNeedle               rts
                    zmb       11
XorNav1CdiNeedle               rts
                    zmb       4
XorCdiNeedleCommon               rts
                    zmb       60
* XorCdiNeedleDone: Return
XorCdiNeedleDone               rts
* CdiDeviationToNeedle: Clamp <$A3 to +/-30, return B=(dev+30)/2 needle position 0-30
CdiDeviationToNeedle               ldd       <vVorDev
                    cmpd      #CdiDevMax
                    bgt       CdiDeviationToNeedleMax
                    cmpd      #CdiDevMin
                    bgt       CdiDeviationToNeedleScale
                    ldb       #CdiDevMinLo
                    bra       CdiDeviationToNeedleScale
* CdiDeviationToNeedleMax: Clamp to +30
CdiDeviationToNeedleMax               ldb       #CdiDevMax
* CdiDeviationToNeedleScale: Offset and halve
CdiDeviationToNeedleScale               addb      #CdiDevMax
                    lsrb
                    rts
* UpdateGlideslopeDme: Glideslope target $0722 from altitude $07F9 / distance vs $0152 (cleared after), then DME: $071C.$071B distance, $0719 no signal, $071A redraw
UpdateGlideslopeDme               ldd       >vGlideSlope
                    beq       UpdateGlideslopeDmeDme
                    lsra
                    rorb
                    std       <vGsSlopeHalf
                    jsr       >ApproxStationDistance+ModBase
                    ldd       >vAltCopy
                    lsra
                    rorb
                    cmpd      <vStnDist
                    blo       UpdateGlideslopeDmeAngle
                    ldb       #GsNeedleLast
                    bra       UpdateGlideslopeDmeStoreGs
* UpdateGlideslopeDmeAngle: Altitude/distance ratio minus beam angle, clamp 0-$18
UpdateGlideslopeDmeAngle               std       <vGsHgtHalf
                    ldd       <vStnDist
                    std       >vDivisor
                    ldd       <vGsHgtHalf
                    jsr       >DivQ15Signed+ModBase
                    ldd       >vDivQuot
                    subd      <vGsSlopeHalf
                    addd      #GsDevCenter
                    cmpd      #GsDevSpan
                    tfr       a,b
                    blo       UpdateGlideslopeDmeStoreGs
                    ldb       #GsNeedleLast
                    tsta
                    bpl       UpdateGlideslopeDmeStoreGs
                    clrb
* UpdateGlideslopeDmeStoreGs: Store glideslope target $0722
UpdateGlideslopeDmeStoreGs               stb       >vGsGoal
* UpdateGlideslopeDmeDme: Clear $0152, check NAV1 signal bit for DME
UpdateGlideslopeDmeDme               clrb
                    clra
                    std       >vGlideSlope
                    lda       >vNavRx
                    rora
                    blo       UpdateGlideslopeDmeCalc
                    lda       #DmeNoSignal
                    sta       >vDmeOff
                    bra       UpdateGlideslopeDmeRedraw
* UpdateGlideslopeDmeCalc: DME distance = ApproxStationDistance/$011B, split into whole $071C and tenths $071B
UpdateGlideslopeDmeCalc               clr       >vDmeOff
                    jsr       >ApproxStationDistance+ModBase
                    std       >vMulA
                    ldd       #DmeNmScale
                    jsr       >MulU16Mid+ModBase
                    aslb
                    rola
                    sta       >vDmeNm
                    lsrb
                    lda       #DmeTenthsScale
                    jsr       >MulSigned8+ModBase
                    cmpa      >vDmeTenths
                    beq       UpdateGlideslopeDmeDone
                    sta       >vDmeTenths
* UpdateGlideslopeDmeRedraw: Set DME redraw flag $071A
UpdateGlideslopeDmeRedraw               lda       #DmeRedraw
                    sta       >vDmeRedraw
* UpdateGlideslopeDmeDone: Return
UpdateGlideslopeDmeDone               rts
* Atan2Angle: In <$A5 (x) and <$A7 (y) signed: return D = 16-bit binary angle
Atan2Angle               ldd       <vAtanX
                    bpl       Atan2AngleYSign
                    coma
                    comb
                    addd      #NegCarry
                    std       <vAtanX
                    jsr       >Atan2AngleYSign+ModBase
                    coma
                    comb
                    addd      #NegCarry
                    rts
* Atan2AngleYSign: Handle sign of <$A7 (adds half turn)
Atan2AngleYSign               ldd       <vAtanY
                    bpl       Atan2AngleOctant
                    coma
                    comb
                    addd      #NegCarry
                    std       <vAtanY
                    jsr       >Atan2AngleOctant+ModBase
                    coma
                    comb
                    addd      #NegCarry
                    eora      #Angle8Half
                    rts
* Atan2AngleOctant: Both positive: swap to keep ratio <= 1 (adds quarter turn)
Atan2AngleOctant               ldd       <vAtanX
                    cmpd      <vAtanY
                    blo       AtanRatioLookup
                    bne       Atan2AngleSwap
                    addd      #AtanTieNudge
                    std       <vAtanX
* Atan2AngleSwap: Swap <$A5/<$A7 and complement
Atan2AngleSwap               ldd       <vAtanX
                    ldy       <vAtanY
                    std       <vAtanY
                    sty       <vAtanX
                    jsr       >AtanRatioLookup+ModBase
                    coma
                    comb
                    addd      #NegCarry
                    adda      #Angle8Quarter
                    rts
* AtanRatioLookup: Ratio <$A5/<$A7 (<= 1): interpolate arctangent table at $10F4, return D
AtanRatioLookup               ldd       <vAtanY
                    std       >vDivisor
                    ldd       <vAtanX
                    jsr       >DivQ15Signed+ModBase
* WildBits: the table step r >> 11 (a word index), the fraction (r & $7FF) << 4 as Q15 (FS's lost bit 0 of the
* ratio's high byte and counted its low byte double: a +-0.47 degree sawtooth that shook the spot camera's aim)
                    ldb       >vDivQuot
                    lsrb
                    lsrb
                    andb      #EvenMask
                    pshs      b
                    ldd       >vDivQuot
                    anda      #AtanFracHiBits
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    std       >vMulA
                    puls      b
                    nop                           (the same length: no FS address moves)
                    nop
                    nop
                    nop
                    ldx       #vAtanTbl
                    abx
                    ldd       ,x++
                    std       <vAtanTblEntry
                    subd      ,x
                    jsr       >MulQ15+ModBase
                    subd      <vAtanTblEntry
                    coma
                    comb
                    rts
* DrawMarkerLights: Marker beacon lights: outer ($014D), middle ($014F), inner ($0151) bit0 shifted out: lit or blank; skipped when $0307
DrawMarkerLights               lda       >vEurope1917
                    bne       DrawMarkerLightsDone
                    ldx       #vOuterMkrTxt
                    lsr       >vMkrInner
                    bhs       DrawMarkerLightsOmOff
                    jsr       >PrintPanelTextF+ModBase
                    bra       DrawMarkerLightsMm
* DrawMarkerLightsOmOff: Blank outer marker light
DrawMarkerLightsOmOff               jsr       >PrintPanelText0+ModBase
* DrawMarkerLightsMm: Middle marker light
DrawMarkerLightsMm               ldx       #vMiddleMkrTxt
                    lsr       >vMkrOuter
                    bhs       DrawMarkerLightsMmOff
                    jsr       >PrintPanelText6+ModBase
                    bra       DrawMarkerLightsIm
* DrawMarkerLightsMmOff: Blank middle marker light
DrawMarkerLightsMmOff               jsr       >PrintPanelText0+ModBase
* DrawMarkerLightsIm: Inner marker light
DrawMarkerLightsIm               ldx       #vInnerMkrTxt
                    lsr       >vMkrMiddle
                    bhs       DrawMarkerLightsImOff
                    jsr       >PrintPanelText4+ModBase
                    bra       DrawMarkerLightsDone
* DrawMarkerLightsImOff: Blank inner marker light
DrawMarkerLightsImOff               jsr       >PrintPanelText0+ModBase
* DrawMarkerLightsDone: Return
DrawMarkerLightsDone               rts
* ApproxStationDistance: |$0728|, |$072A|: return D and <$AB = max + min*min/(2*max) (approximate distance)
ApproxStationDistance               ldd       >vStationDZ
                    bpl       ApproxStationDistAbsX
                    coma
                    comb
                    addd      #NegCarry
* ApproxStationDistAbsX: Take absolute value of $072A
ApproxStationDistAbsX               std       <vStnDist
                    ldd       >vStationDX
                    bpl       ApproxStationDistOrder
                    coma
                    comb
                    addd      #NegCarry
* ApproxStationDistOrder: Order the two values into min/max
ApproxStationDistOrder               cmpd      <vStnDist
                    bhs       ApproxStationDistCalc
                    tfr       d,y
                    ldd       <vStnDist
                    sty       <vStnDist
* ApproxStationDistCalc: Compute max + min^2/(2*max)
ApproxStationDistCalc               std       <vStnDistMax
                    aslb
                    rola
                    std       >vDivisor
                    ldd       <vStnDist
                    jsr       >DivQ15Signed+ModBase
                    ldd       <vStnDist
                    jsr       >MulQ15+ModBase
                    addd      <vStnDistMax
                    std       <vStnDist
                    rts
* TblFailureHandlers: 8 addresses of the random aircraft-failure handlers (code bytes after TriggerAircraftFailure)
TblFailureHandlers               fcb       $FA,$56,$FA,$5F,$FA,$68,$FA,$6C
                    fcb       $FA,$70,$FA,$74,$FA,$78,$FA,$7C
* MsgAircraftProblem: Text record (position + "AIRCRAFT PROBLEM !!!!", 0-terminated)
MsgAircraftProblem               fcb       $14
                    fcc       /2AIRCRAFT PROBLEM !!!!/
                    fcb       $00
* UpdateReliability: If $0305 (probably reliability mode): every 10 frames random failure check vs $0342; ramp $073D toward $073F; $0210 += 2; start carb ice counter $0DCD in vSeason=2 at low throttle
UpdateReliability               lda       >vReality
                    lbeq      UpdateReliabilityOff
                    dec       >vFailTimer
                    bpl       UpdateReliabilityRamp
                    lda       #FailRollPasses
                    sta       >vFailTimer
                    lda       <vPosZ+2
                    adda      <vPosX+2
                    cmpa      #FailRollEnd
                    bhs       UpdateReliabilityRamp
                    cmpa      >vReliability
                    blo       UpdateReliabilityRamp
                    jsr       >TriggerAircraftFailure+ModBase
* UpdateReliabilityRamp: Step $073D toward $073F by 2
UpdateReliabilityRamp               ldd       >vAltimErr
                    cmpd      >vAltimErrGoal
                    beq       UpdateReliabilityTimer
                    blt       UpdateReliabilityRampAdd
* WildBits: steps of 1 (FS's 2 never reached an odd distance: the altimeter flipped a dial step back and forth)
                    addd      #AltErrStepFlip
* UpdateReliabilityRampAdd: Add the step and store $073D
UpdateReliabilityRampAdd               addd      #AltErrStep
                    std       >vAltimErr
* UpdateReliabilityTimer: $0210 += 2; check carb-ice conditions
UpdateReliabilityTimer               ldd       >vDgOffset
                    addd      #GyroDriftStep
                    std       >vDgOffset
                    ldd       >vFrameCount
                    anda      #IceCheckMaskHi
                    bne       UpdateReliabilityDone
                    andb      #IceCheckMaskLo
                    bne       UpdateReliabilityDone
                    ldd       >vThrottle
                    cmpd      #CarbIceThrottle
                    bhi       UpdateReliabilityDone
                    lda       >vSeason
                    cmpa      #SeasonSpring
                    bne       UpdateReliabilityDone
                    lda       #CarbIceSteps
                    sta       >vCarbIce
* UpdateReliabilityDone: Return
UpdateReliabilityDone               rts
* StepElevatorDrift: If $0305: move $081A one step toward $081C (stored to $081B), then redraw indicator (ShowElevatorPos); probably elevator/trim drift
StepElevatorDrift               lda       >vReality
                    lbeq      StepElevatorDriftDone
                    lda       >vElevator
                    tfr       a,b
                    suba      >vElevTrim
                    bvc       StepElevatorDriftNoOvf
                    bpl       StepElevatorDriftStore
                    bmi       StepElevatorDriftDown
* StepElevatorDriftNoOvf: No-overflow comparison branch
StepElevatorDriftNoOvf               beq       StepElevatorDriftDraw
                    bmi       StepElevatorDriftStore
* StepElevatorDriftDown: Step down by 1
StepElevatorDriftDown               subb      #StepFlip
* StepElevatorDriftStore: Store stepped value at $081B
StepElevatorDriftStore               addb      #ElevDriftStep
                    stb       >vElevator+1
* StepElevatorDriftDraw: Redraw the indicator
StepElevatorDriftDraw               jsr       >ShowElevatorPos+ModBase
* StepElevatorDriftDone: Return
StepElevatorDriftDone               rts
* UpdateReliabilityOff: Mode off: clear $073D and $0210
UpdateReliabilityOff               clra
                    clrb
                    std       >vAltimErr
                    std       >vDgOffset
                    rts
* TriggerAircraftFailure: Clear view, print MsgAircraftProblem, pause, jump to a random handler from TblFailureHandlers (clears $02AE instrument bits or sets $072E damage)
TriggerAircraftFailure               jsr       >ClearViewWindow+ModBase
                    ldx       #MsgAircraftProblem+ModBase
                    ldd       #TxtWhite
                    std       >vTextColor
                    ldu       >FsScreen
                    jsr       >DrawTextString+ModBase
                    lda       #FailMsgDelay
                    jsr       >DelayA+ModBase
                    ldb       >vFrameCount
                    adcb      <vAlt+2
                    andb      #FailHandlerIx
                    ldx       #TblFailureHandlers+ModBase
                    ldx       b,x
                    jmp       ,x
                    fcb       $86,$FE,$B4,$02,$AE,$B7,$02,$AE
                    fcb       $39,$86,$03,$BA,$07,$2E,$B7,$07
                    fcb       $2E,$39,$86,$FB,$20,$EC,$86,$F7
                    fcb       $20,$E8,$86,$0C,$20,$ED,$86,$DF
                    fcb       $20,$E0,$86,$BF,$20,$DC,$86,$7F
                    fcb       $20,$D8
* SetPanelLightMask: Night/dusk ($013F bit0 clear) and panel lights $0824 off: visible mask $02B1-$02B3 = $0080/$01; else copy $0233-$0235
* WildBits: the instruments always run (the dash is lit day and night, as a real panel; FS stopped all but one
* at dusk and night with the panel lights off): the day branch is taken always, the same length
SetPanelLightMask               lda       >vLight
                    lsra
                    bra       SetPanelLightMaskAll
                    ldd       #NightVisible12
                    std       >vInstVis
                    lda       #NightVisible3
                    sta       >vInstVis+2
                    lda       >vLights
                    beq       SetPanelLightMaskDone
* SetPanelLightMaskAll: Copy normal visibility mask $0233-$0235
SetPanelLightMaskAll               ldd       >vInstLit
                    std       >vInstVis
                    lda       >vInstLit+2
                    sta       >vInstVis+2
* SetPanelLightMaskDone: Return
SetPanelLightMaskDone               rts
* TblInstCoverEB: 8 x 5-byte cover records (color, D, X rectangle) for instrument bits of <$EB
TblInstCoverEB               fcb       $AA,$00,$0F,$1A,$3D,$AA,$02,$3F
                    fcb       $19,$5C,$AA,$1B
                    fcs       /81[*/
                    fcb       $35,$06,$4E,$32,$AA,$1B,$08,$34
                    fcb       $31,$AA,$4F,$06,$69,$32,$00,$8E
                    fcb       $4F,$9C,$54,$AA
                    fcc       /88L\/
* TblInstCoverEC: 8 x 5-byte cover records for instrument bits of <$EC
TblInstCoverEC               fcb       $00,$71,$4F,$7F,$54,$00,$88,$41
                    fcb       $9E,$45,$00,$71,$33,$82,$37,$00
                    fcb       $71,$25,$82,$29,$00,$70,$03,$80
                    fcb       $0E,$00,$82,$03,$9E,$12,$00,$82
                    fcb       $13,$9E,$21,$00,$00,$00,$00,$00
* TblInstCoverED: 4 x 5-byte cover records for instrument bits of <$ED
TblInstCoverED               fcb       $00
                    fcc       /gWm[/
                    fcb       $00,$71,$41,$82,$45,$00,$88,$33
                    fcb       $96,$37,$AA
                    fcc       /N2i\/
* UpdateInstrumentMasks: Active instruments <$EB/<$EC/<$ED = present ($0344-) & working ($02AE-) & visible ($02B1-); redraw panel if any came on; draw covers for changed bits
UpdateInstrumentMasks               clr       <vInstNewOn
                    lda       <vInstActive3
                    pshs      a
                    lda       <vInstActive2
                    pshs      a
                    lda       <vInstActive1
                    pshs      a
                    lda       >vInstPresent
                    anda      >vInstWork
                    anda      >vInstVis
                    sta       <vInstMaskNew
                    eora      <vInstActive1
                    beq       UpdateInstMasksEC
                    ldb       <vInstMaskNew
                    stb       <vInstActive1
                    anda      <vInstMaskNew
                    beq       UpdateInstMasksEC
                    inc       <vInstNewOn
* UpdateInstMasksEC: Second mask byte (<$EC, bit7 forced on)
UpdateInstMasksEC               lda       >vInstPresent+1
                    anda      >vInstWork+1
                    anda      >vInstVis+1
                    sta       <vInstMaskNew
                    eora      <vInstActive2
                    beq       UpdateInstMasksED
                    ldb       <vInstMaskNew
                    orb       #InstReadouts
                    stb       <vInstActive2
                    anda      <vInstMaskNew
                    beq       UpdateInstMasksED
                    inc       <vInstNewOn
* UpdateInstMasksED: Third mask byte (<$ED, bits $F1 forced on)
UpdateInstMasksED               lda       >vInstPresent+2
                    anda      >vInstWork+2
                    anda      >vInstVis+2
                    sta       <vInstMaskNew
                    eora      <vInstActive3
                    beq       UpdateInstMasksRedraw
                    ldb       <vInstMaskNew
                    orb       #InstForced3
                    stb       <vInstActive3
                    anda      <vInstMaskNew
                    beq       UpdateInstMasksRedraw
                    inc       <vInstNewOn
* UpdateInstMasksRedraw: Any instrument newly enabled: full panel redraw
UpdateInstMasksRedraw               lda       <vInstNewOn
                    beq       UpdateInstMasksCoverEB
                    jsr       >LoadPanelPicture+ModBase
                    lda       >vAdfEnable
                    beq       UpdateInstMasksPanel
                    jsr       >LoadPictureFa+ModBase
                    lda       #PanelBlank
                    jsr       >SetFillColor+ModBase
                    ldd       #AdfAreaTopLeft
                    ldx       #AdfAreaBotRight
                    ldy       >vPanelScr
                    jsr       >FillRect+ModBase
                    ldx       #vAdfLabel
                    ldy       >vPanelScr
                    jsr       >PrintPanelText5+ModBase
                    jsr       >SetAdfFreq+ModBase
* UpdateInstMasksPanel: Draw the panel instruments (RedrawAllInstruments)
UpdateInstMasksPanel               jsr       >RedrawAllInstruments+ModBase
* UpdateInstMasksCoverEB: Draw covers for changed <$EB bits
UpdateInstMasksCoverEB               lda       <vInstActive1
                    tfr       a,b
                    eora      ,s+
                    beq       UpdateInstMasksCoverEC
                    tfr       b,a
                    ldy       #TblInstCoverEB+ModBase
                    lbsr      DrawInstrumentCovers
* UpdateInstMasksCoverEC: Draw covers for changed <$EC bits
UpdateInstMasksCoverEC               lda       <vInstActive2
                    tfr       a,b
                    eora      ,s+
                    beq       UpdateInstMasksCoverED
                    tfr       b,a
                    ldy       #TblInstCoverEC+ModBase
                    bsr       DrawInstrumentCovers
* UpdateInstMasksCoverED: Draw covers for changed <$ED bits
UpdateInstMasksCoverED               lda       <vInstActive3
                    tfr       a,b
                    eora      ,s+
                    beq       UpdateInstMasksDone
                    tfr       b,a
                    ldy       #TblInstCoverED+ModBase
                    bra       DrawInstrumentCovers
* UpdateInstMasksDone: Return
UpdateInstMasksDone               rts
* DrawInstrumentCovers: A=changed bits, Y=5-byte record table: fill each flagged instrument rectangle (color via SetFillColor, rect via FillRect)
DrawInstrumentCovers               ldb       #CoverRecCount
* DrawInstCoversLoop: Test next bit
DrawInstCoversLoop               lsra
                    blo       DrawInstCoversSkip
                    pshs      a,b
                    lda       ,y+
                    pshs      y
                    jsr       >SetFillColor+ModBase
                    puls      y
                    ldd       ,y++
                    ldx       ,y++
                    pshs      y
                    ldy       >vPanelScr
                    jsr       >FillRect+ModBase
                    puls      y
                    puls      a,b
* DrawInstCoversNext: Count bits
DrawInstCoversNext               decb
                    bne       DrawInstCoversLoop
                    rts
* DrawInstCoversSkip: Bit clear: skip 5-byte record
DrawInstCoversSkip               leay      5,y
                    bra       DrawInstCoversNext
