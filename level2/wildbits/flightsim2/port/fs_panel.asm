* fs_panel.asm - FS (Flight Simulator II), part of the port: altimeter, airspeed, VSI, slip ball, control markers, ADF, sky/ground fill, attitude indicator,
* turn coordinator, the display-list interpreter ($1BFC-$3262)
* Assembled by fs.asm (use); absolute self-references are label+ModBase.

* DrawAltimeter: If <$EB bit3: altitude <$05 + vElev ($0132) plus $073D scaled, band mark $0D1F and needles <$3D/<$3E (probably altimeter)
DrawAltimeter               lda       <vInstActive1
                    anda      #InstAltimeter
                    beq       UpdFuelGaugeDone
                    ldd       <vAlt+1
                    std       >vAltCopy
                    addd      >vElev
                    std       >vAltMsl
                    addd      >vAltimErr
                    std       <vMulA
                    ldd       #AltimeterStepsPerM
                    std       <vMulB
                    jsr       >MulQ15Vars+ModBase
                    clr       <vAltBands
* DrawAltimeterBand: DrawAltimeter: count $0370 bands into <$DD
DrawAltimeterBand               inc       <vAltBands
                    subd      #AltimeterBandSteps
                    bpl       DrawAltimeterBand
                    addd      #AltimeterBandSteps
                    std       <vAltBandRem
                    std       <vMulA
                    cmpd      #AltimeterHalfBand
                    pshs      cc
                    lda       <vAltBands
                    deca
                    cmpa      #AltimeterLastBand
                    bls       DrawAltimeterHalf
                    puls      cc
                    lda       #AltimeterLastMark
                    bra       DrawAltimeterMark
* DrawAltimeterHalf: DrawAltimeter: band mark doubled, +1 in the upper half
DrawAltimeterHalf               asla
                    puls      cc
                    blt       DrawAltimeterMark
                    inca
* DrawAltimeterMark: DrawAltimeter: XOR-move the band marker when it changed
DrawAltimeterMark               cmpa      >vAltBandMark
                    beq       DrawAltimeterNeedle1
                    ldb       >vAltBandMark
                    sta       >vAltBandMark
                    jsr       >XorAltDialMarker+ModBase
                    ldb       >vAltBandMark
                    jsr       >XorAltDialMarker+ModBase
* DrawAltimeterNeedle1: DrawAltimeter: compute first needle position <$3D (0-87)
DrawAltimeterNeedle1               ldd       #Q15Tenth
                    std       <vMulB
                    jsr       >MulQ15Vars+ModBase
                    comb
                    addb      #DialQuarter
                    bpl       DrawAltimeterClamp1
                    addb      #DialSteps
* DrawAltimeterClamp1: DrawAltimeter: wrap first needle position
DrawAltimeterClamp1               cmpb      #DialSteps
                    blo       DrawAltimeterStore1
                    lda       #DialLast
* DrawAltimeterStore1: DrawAltimeter: store first needle position
DrawAltimeterStore1               stb       <vAltSmallHand
                    ldd       <vAltBandRem
* DrawAltimeterNeedle2: DrawAltimeter: second needle position = remainder mod 88
DrawAltimeterNeedle2               subd      #DialSteps
                    bpl       DrawAltimeterNeedle2
                    comb
                    addb      #DialQuarterLessTurn
                    bpl       AltimeterClampBigHand
                    addb      #DialSteps
* AltimeterClampBigHand: altimeter update (probably): clamps the big-hand dial position to 0..$57
AltimeterClampBigHand               cmpb      #DialSteps
                    blo       AltimeterRedrawHands
                    lda       #DialLast
* AltimeterRedrawHands: altimeter: if the big-hand position changed, erase both hands and redraw them
AltimeterRedrawHands               stb       <vAltBigHand
                    ldd       #AltimeterCenter
                    std       <vNeedleCtr
                    lda       >vAltBigDrawn
                    cmpa      <vAltBigHand
                    lbeq      AltimeterDone
                    ldx       #vNeedleLong
                    ldu       #EraseNeedleRestoreBg+ModBase
                    stu       <vNeedleRtn
                    ldu       #vAltBigHandBg
                    jsr       >DrawDialNeedle+ModBase
                    ldd       #AltimeterCenter
                    std       <vNeedleCtr
                    ldx       #vNeedleShort
                    lda       >vAltSmallDrawn
                    cmpa      <vAltSmallHand
                    beq       AltimeterDrawBigHand
                    ldu       #EraseNeedleRestoreBg+ModBase
                    stu       <vNeedleRtn
                    ldu       #vAltSmallHandBg
                    jsr       >DrawDialNeedle+ModBase
* AltimeterDrawSmallHand: altimeter: store the small-hand position <$3D in $0D1D and draw that hand (needle shape $16E8)
AltimeterDrawSmallHand               ldd       #AltimeterCenter
                    std       <vNeedleCtr
                    ldx       #vNeedleShort
                    lda       <vAltSmallHand
                    sta       >vAltSmallDrawn
                    ldu       #DrawNeedleSaveBg+ModBase
                    stu       <vNeedleRtn
                    ldu       #vAltSmallHandBg
                    jsr       >DrawDialNeedle+ModBase
* AltimeterDrawBigHand: altimeter: store the big-hand position <$3E in $0D1E and draw that hand (needle shape $16B8)
AltimeterDrawBigHand               ldd       #AltimeterCenter
                    std       <vNeedleCtr
                    ldx       #vNeedleLong
                    lda       <vAltBigHand
                    sta       >vAltBigDrawn
                    ldu       #DrawNeedleSaveBg+ModBase
                    stu       <vNeedleRtn
                    ldu       #vAltBigHandBg
                    jmp       >DrawDialNeedle+ModBase
* InitAltimeterHands: panel init: if the altimeter is enabled (<$EB bit 3) XOR the marker at position 0 and draw both hands
InitAltimeterHands               lda       <vInstActive1
                    anda      #InstAltimeter
                    beq       AltimeterDone
                    clrb
                    jsr       >XorAltDialMarker+ModBase
                    bra       AltimeterDrawSmallHand
* AltimeterDone: altimeter routines: common rts
AltimeterDone               rts
* XorAltDialMarker: WildBits (2026-10-20): FS's CoCo panel is not drawn (the dash, fsp, draws every instrument):
* the altimeter dial marker and its position table are gone, their 85 bytes zero so no FS address moves
XorAltDialMarker               rts
                    zmb       84
* CalcAirspeedNeedle: computes the airspeed needle target $07F3 from airspeed $07BB (clamped to 90) by interpolating TblAirspeedDial
CalcAirspeedNeedle               lda       <vInstActive1
                    anda      #InstAirspeed
                    beq       AirspeedNeedleDone
                    ldb       >vAirspeed
                    cmpb      #AirspeedDialTop
                    blo       CalcAirspeedNeedleLookup
                    ldb       #AirspeedDialTop
* CalcAirspeedNeedleLookup: airspeed: table lookup and interpolation with the fraction bits
CalcAirspeedNeedleLookup               stb       >vAsiSpeedHi
                    lsrb
                    lsrb
                    ldx       #TblAirspeedDial+ModBase
                    abx
                    ldb       1,x
                    subb      ,x
                    lda       >vAirspeed+1
                    rola
                    lda       >vAsiSpeedHi
                    rola
                    anda      #AirspeedStepFrac
                    asla
                    asla
                    asla
                    asla
                    jsr       >MulSigned8+ModBase
                    adda      ,x
                    sta       >vAsiTarget
* AirspeedNeedleDone: airspeed routines: common rts
AirspeedNeedleDone               rts
* UpdAirspeedNeedle: moves the airspeed needle a quarter of the way toward $07F3 (erase old, draw new), if <$EB bit 0 is set
UpdAirspeedNeedle               lda       <vInstActive1
                    lsra
                    bhs       AirspeedNeedleDone
                    ldd       #AirspeedCenter
                    std       <vNeedleCtr
                    lda       >vAsiNeedle
                    cmpa      >vAsiTarget
                    beq       AirspeedNeedleDone
                    ldu       #EraseNeedleRestoreBg+ModBase
                    stu       <vNeedleRtn
                    jsr       >AirspeedNeedleWrap+ModBase
                    ldd       #AirspeedCenter
                    std       <vNeedleCtr
                    lda       >vAsiTarget
                    suba      >vAsiNeedle
                    asra
                    asra
                    bpl       UpdAirspeedNeedleStep
                    deca
* UpdAirspeedNeedleStep: airspeed: adds the at-least-one step to the old position
UpdAirspeedNeedleStep               inca
                    adda      >vAsiNeedle
* DrawAirspeedNeedleAt: airspeed: stores A as the needle position $0D20 and draws the needle there
DrawAirspeedNeedleAt               sta       >vAsiNeedle
                    ldu       #DrawNeedleSaveBg+ModBase
                    stu       <vNeedleRtn
* AirspeedNeedleWrap: airspeed: wraps the position modulo $58 and draws/erases the needle via DrawDialNeedle
AirspeedNeedleWrap               cmpa      #DialSteps
                    blo       AirspeedNeedleCall
                    suba      #DialSteps
* AirspeedNeedleCall: airspeed: sets needle shape $16B8 and save buffer $0D62, jumps to DrawDialNeedle
AirspeedNeedleCall               ldx       #vNeedleLong
                    ldu       #vAirspeedNeedleBg
                    jmp       >DrawDialNeedle+ModBase
* InitAirspeedNeedle: panel init: draws the airspeed needle at position 0
InitAirspeedNeedle               lda       <vInstActive1
                    anda      #InstAirspeed
                    beq       AirspeedNeedleDone
                    ldd       #AirspeedCenter
                    std       <vNeedleCtr
                    clra
                    bra       DrawAirspeedNeedleAt
* TblAirspeedDial: 23 needle positions, one per 4 knots of airspeed (nonlinear airspeed dial scale)
TblAirspeedDial               fcc       /nljhfda^ZUPKGC>951,&"/
                    fcb       $1F,$1C,$1A
* CalcVsiNeedle: computes the vertical speed needle position <$3F from $07BF (clamped to +-9), if <$EB bit 7 is set
CalcVsiNeedle               lda       <vInstActive1
                    bpl       VsiNeedleDone
                    ldd       >vVertSpeed
                    bmi       CalcVsiNeedleNeg
                    cmpa      #VsiLimit
                    bls       CalcVsiNeedleScale
                    lda       #VsiLimit
                    bra       CalcVsiNeedleScale
* CalcVsiNeedleNeg: VSI: clamps a negative vertical speed to -9
CalcVsiNeedleNeg               cmpa      #VsiLimitNeg
                    bhs       CalcVsiNeedleScale
                    lda       #VsiLimitNeg
* CalcVsiNeedleScale: VSI: scales the clamped value into a dial position
CalcVsiNeedleScale               aslb
                    rola
                    aslb
                    rola
                    nega
                    adda      #VsiZeroPos
* CalcVsiNeedleWrap: VSI: wraps the dial position modulo $58
CalcVsiNeedleWrap               cmpa      #DialSteps
                    blo       CalcVsiNeedleStore
                    suba      #DialSteps
                    bne       CalcVsiNeedleWrap
* CalcVsiNeedleStore: VSI: stores the target position in <$3F
CalcVsiNeedleStore               sta       <vVsiTarget
* VsiNeedleDone: VSI routines: common rts
VsiNeedleDone               rts
* UpdVsiNeedle: moves the vertical speed needle one step toward <$3F (erase, then draw at $0D21)
UpdVsiNeedle               lda       <vInstActive1
                    bpl       VsiNeedleDone
                    ldd       #VsiCenter
                    std       <vNeedleCtr
                    lda       >vVsiNeedle
                    cmpa      <vVsiTarget
                    beq       VsiNeedleDone
                    pshs      cc,a
                    ldu       #EraseNeedleRestoreBg+ModBase
                    stu       <vNeedleRtn
                    ldu       #vVsiNeedleBg
                    ldx       #vNeedleShort
                    jsr       >DrawDialNeedle+ModBase
                    ldd       #VsiCenter
                    std       <vNeedleCtr
                    puls      cc,a
                    blo       UpdVsiNeedleStep
                    suba      #StepFlip
* UpdVsiNeedleStep: VSI: increments/decrements the needle position by one
UpdVsiNeedleStep               inca
* DrawVsiNeedleAt: VSI: stores A in $0D21 and draws the needle there (shape $16E8, buffer $0D89)
DrawVsiNeedleAt               sta       >vVsiNeedle
                    ldu       #DrawNeedleSaveBg+ModBase
                    stu       <vNeedleRtn
                    ldu       #vVsiNeedleBg
                    ldx       #vNeedleShort
                    jmp       >DrawDialNeedle+ModBase
* InitVsiNeedle: panel init: draws the vertical speed needle at position 0
InitVsiNeedle               lda       <vInstActive1
                    bpl       VsiNeedleDone
                    ldd       #VsiCenter
                    std       <vNeedleCtr
                    clra
                    bra       DrawVsiNeedleAt
* DrawDialNeedle: draws or erases a dial needle: A = position 0..$57, X = needle shape table, U = background buffer, <$20/<$21 = center, <$39 = draw/erase routine
DrawDialNeedle               sta       >vDialNeedlePos
                    cmpa      #DialThreeQuarters
                    bhs       DrawDialNeedleQ3
                    cmpa      #DialHalf
                    bhs       DrawDialNeedleQ2
                    cmpa      #DialQuarter
                    bhs       DrawDialNeedleQ1
                    lbsr      NeedleSetNoMirror
                    lbsr      NeedleSetRowsUp
                    lda       >vDialNeedlePos
                    bra       DrawDialNeedleGo
* DrawDialNeedleQ1: needle positions $16-$2B: mirrored, rows upward
DrawDialNeedleQ1               lbsr      NeedleSetMirror
                    lbsr      NeedleSetRowsUp
                    lda       #DialHalf
                    suba      >vDialNeedlePos
                    bra       DrawDialNeedleGo
* DrawDialNeedleQ2: needle positions $2C-$41: mirrored, rows downward
DrawDialNeedleQ2               lbsr      NeedleSetMirror
                    lbsr      NeedleSetRowsDown
                    lda       >vDialNeedlePos
                    suba      #DialHalf
                    bra       DrawDialNeedleGo
* DrawDialNeedleQ3: needle positions $42-$57: not mirrored, rows downward
DrawDialNeedleQ3               lbsr      NeedleSetNoMirror
                    lbsr      NeedleSetRowsDown
                    lda       #DialSteps
                    suba      >vDialNeedlePos
* DrawDialNeedleGo: fetches the shape for the quadrant index, the center screen address, and jumps through <$39
DrawDialNeedleGo               asla
                    ldy       a,x
                    ldx       #vRowAddrTbl
                    lda       <vNeedleCtr
                    leax      a,x
                    ldx       a,x
                    ldd       >vPanelScr
                    leax      d,x
                    jmp       [>vNeedleRtn]
* NeedleSetRowsDown: needle setup: row step +$50 (downward) and center adjustment
NeedleSetRowsDown               lda       #ScreenBytesPerRow
                    sta       <vNeedleRowStep
                    dec       <vNeedleCtr
                    cmpx      #vNeedleShort
                    beq       NeedleSetRowsDownRts
                    dec       <vNeedleCtr
                    dec       <vNeedleCtr
                    dec       <vNeedleCtr
* NeedleSetRowsDownRts: rts of NeedleSetRowsDown
NeedleSetRowsDownRts               rts
* NeedleSetRowsUp: needle setup: row step -$50 (upward)
NeedleSetRowsUp               lda       #ScreenRowUp
                    sta       <vNeedleRowStep
                    rts
* NeedleSetNoMirror: needle setup: clears the horizontal mirror flag <$3B
NeedleSetNoMirror               clr       <vNeedleMirror
                    rts
* NeedleSetMirror: needle setup: sets the horizontal mirror flag <$3B and adjusts the center column
NeedleSetMirror               lda       #NeedleMirrored
                    sta       <vNeedleMirror
                    inc       <vNeedleCtr+1
                    cmpx      #vNeedleShort
                    beq       NeedleSetMirrorRts
                    inc       <vNeedleCtr+1
                    inc       <vNeedleCtr+1
* NeedleSetMirrorRts: rts of NeedleSetMirror
NeedleSetMirrorRts               rts
* DrawNeedleSaveBg, EraseNeedleRestoreBg: WildBits (2026-10-20): FS's CoCo panel needles (every dial's and the slip
* ball, drawn and erased through these two by <$39) are not drawn: the dash (fsp) draws every instrument. The callers
* still compute their needle positions ($0D20, $0D21, the altimeter's hands <$3D/<$3E, the slip ball $0E0A ...),
* which the dash reads. The drawing loops are gone, their bytes zero so no FS address moves.
DrawNeedleSaveBg               rts
                    zmb       74
EraseNeedleRestoreBg               clra                         D = 0 bytes restored
                    clrb
                    rts
                    zmb       48
* EraseNeedleRestoreRts: rts (also used as an early exit by UpdSlipBall)
EraseNeedleRestoreRts               rts
* UpdSlipBall: turn coordinator inclinometer ball (probably): position from $0761, or from -rudder $082B; redraws when it changes, if <$EB bit 1 is set
UpdSlipBall               lda       <vInstActive1
                    anda      #InstTurnCoord
                    beq       EraseNeedleRestoreRts
                    lda       >vOnGnd
                    bne       UpdSlipBallRudder
                    lda       >vSlip
                    bra       UpdSlipBallScale
* UpdSlipBallRudder: slip ball: uses the negated rudder $082B when airspeed $07BB is nonzero
UpdSlipBallRudder               clra
                    ldb       >vAirspeed
                    beq       UpdSlipBallScale
                    suba      >vRudder
* UpdSlipBallScale: slip ball: scales and centers the value
UpdSlipBallScale               adda      #SlipBias
                    lsra
                    lsra
                    suba      #SlipBiasDiv4
                    bmi       UpdSlipBallClampNeg
                    cmpa      #SlipBallLimit
                    bls       UpdSlipBallBias
                    lda       #SlipBallLimit
                    bra       UpdSlipBallBias
* UpdSlipBallClampNeg: slip ball: clamps the negative side to -8
UpdSlipBallClampNeg               cmpa      #SlipBallLimitNeg
                    bhs       UpdSlipBallBias
                    lda       #SlipBallLimitNeg
* UpdSlipBallBias: slip ball: biases the position to 1..17
UpdSlipBallBias               adda      #SlipBallCenter
                    bra       UpdSlipBallCompare
* UpdSlipBallCompare: slip ball: compares with $0E0A, erases the old ball and draws the new one
UpdSlipBallCompare               cmpa      >vSlipBall
                    beq       EraseNeedleRestoreRts
                    ldb       >vSlipBall
                    sta       >vSlipBall
                    ldy       #vSlipBallShape
                    ldu       #vSlipBallBg
                    ldx       >vPanelScr
                    addb      #SlipBallCol0
                    stb       <vNeedleCtr+1
                    ldd       #SlipBallRowOfs
                    leax      d,x
                    clr       <vNeedleMirror
                    lda       #ScreenBytesPerRow
                    sta       <vNeedleRowStep
                    jsr       >EraseNeedleRestoreBg+ModBase
                    ldb       >vSlipBall
* DrawSlipBallAt: draws the slip ball shape $1BF2 at column B+3 (background saved to $0DB9)
DrawSlipBallAt               ldy       #vSlipBallShape
                    ldu       #vSlipBallBg
                    ldx       >vPanelScr
                    addb      #SlipBallCol0
                    stb       <vNeedleCtr+1
                    ldd       #SlipBallRowOfs
                    leax      d,x
                    clr       <vNeedleMirror
                    lda       #ScreenBytesPerRow
                    sta       <vNeedleRowStep
                    jmp       >DrawNeedleSaveBg+ModBase
* InitSlipBall: panel init: draws the slip ball at position 0
InitSlipBall               ldb       #SlipBallInitPos
                    stb       >vSlipBall
                    bra       DrawSlipBallAt
* (GetScreenRowAddr, gone: nothing called it)
                    zmb       13
* UpdAileronMarker: moves the aileron position marker (probably; called with the $0812 value 0..15) from $0E0C to A
UpdAileronMarker               ldb       >vAileronMark
                    sta       >vAileronMark
                    std       >vMarkerNew
                    ldd       #AileronMarkerAt
                    std       <vMarkerPos
                    lda       #SlideMarkerRows
                    ldb       #SlideMarkerWide
                    jmp       >MoveSlideMarker+ModBase
* InitAileronMarker: panel init: draws the aileron position marker at the center (7)
InitAileronMarker               lda       #SlideMarkerCenter
                    sta       >vMarkerNew
                    sta       >vAileronMark
                    ldd       #AileronMarkerAt
                    std       <vMarkerPos
                    lda       #SlideMarkerRows
                    ldb       #SlideMarkerWide
                    stb       <vMarkerWide
                    jmp       >DrawSlideMarker+ModBase
* UpdRudderMarker: moves the rudder position marker (probably; called with the $082B value 0..15) from $0E0D to A
UpdRudderMarker               ldb       >vRudderMark
                    sta       >vRudderMark
                    std       >vMarkerNew
                    ldd       #RudderMarkerAt
                    std       <vMarkerPos
                    lda       #SlideMarkerRows
                    ldb       #SlideMarkerWide
                    bra       MoveSlideMarker
* InitRudderMarker: panel init: draws the rudder position marker at the center (7)
InitRudderMarker               lda       #SlideMarkerCenter
                    sta       >vMarkerNew
                    sta       >vRudderMark
                    ldd       #RudderMarkerAt
                    std       <vMarkerPos
                    lda       #SlideMarkerRows
                    ldb       #SlideMarkerWide
                    stb       <vMarkerWide
                    lbra      DrawSlideMarker
* MoveSlideMarker, DrawSlideMarker: WildBits (2026-10-20): FS's CoCo panel slide markers (fuel, oil, rudder,
* aileron, trim, throttle ...) are not drawn: the dash (fsp) draws every instrument from the values the callers keep
* storing ($0205/$0206, $080A-$080D, $0E0D ...). The XOR drawing is gone, its bytes zero so no FS address moves.
MoveSlideMarker               rts
                    zmb       20
DrawSlideMarker               rts
                    zmb       58
* UpdElevatorMarker: moves the elevator position marker (probably; from $081A) vertically from $0E0B to the new position
UpdElevatorMarker               suba      #ElevatorMarkerSpan
                    nega
                    ldb       >vElevatorMark
                    sta       >vElevatorMark
                    std       >vMarkerNew
                    ldd       #ElevatorMarkerAt
                    std       <vMarkerPos
                    lda       #VertMarkerRows
                    bra       MoveVertMarker
* InitElevatorMarker: panel init: draws the elevator position marker at the center ($0A)
InitElevatorMarker               lda       #ElevatorMarkerCenter
                    sta       >vMarkerNew
                    sta       >vElevatorMark
                    ldd       #ElevatorMarkerAt
                    std       <vMarkerPos
                    lda       #VertMarkerRows
                    lbra      DrawVertMarker
* MoveVertMarker, DrawVertMarker: WildBits (2026-10-20): FS's CoCo panel vertical markers (the elevator's ...) are
* not drawn (the dash, fsp, reads $081A itself); the XOR drawing is gone, its bytes zero so no FS address moves.
MoveVertMarker               rts
                    zmb       17
DrawVertMarker               rts
                    zmb       28
* UpdAdfNeedle: ADF needle (probably): if $0348 is set, computes the bearing to the station at $0293 relative to heading and redraws the needle when it changes
UpdAdfNeedle               lda       >vAdfEnable
                    lbeq      AdfNeedleDone
                    lda       >vInstActive3
                    anda      #InstNav2
                    lbeq      AdfNeedleDone
                    ldd       #AdfNoStation
                    tst       >vAdfFound
                    beq       UpdAdfNeedleScale
                    ldx       #vNav2StnRec
                    jsr       >ComputeStationBearing+ModBase
                    ldd       <vStnBearing
                    subd      <vHdg
                    addd      #Angle16Quarter
                    addd      >vHdgOfs2
                    addd      >vHdgOfs1
* UpdAdfNeedleScale: ADF: scales the 16-bit angle to a dial position 0..$57
UpdAdfNeedleScale               lsra
                    rorb
                    std       <vMulA
                    std       <vAdfNeedleAng
                    ldd       #DialLast
                    jsr       >MulQ15+ModBase
                    comb
                    addb      #DialSteps
                    cmpb      >vAdfNeedle
                    lbeq      AdfNeedleDone
                    lda       >vAdfNeedle
                    stb       >vAdfNeedle
                    sta       >vAdfErasePos
                    ldd       #AdfCenter
                    std       <vNeedleCtr
                    ldx       #vNeedleShort
                    ldu       #EraseNeedleRestoreBg+ModBase
                    stu       <vNeedleRtn
                    ldu       #vAdfNeedleBg
                    lda       >vAdfErasePos
                    jsr       >DrawDialNeedle+ModBase
* DrawAdfNeedleNew: ADF: draws the needle at $09A7 (shape $16E8, buffer $0DA1)
DrawAdfNeedleNew               ldd       #AdfCenter
                    std       <vNeedleCtr
                    ldx       #vNeedleShort
                    lda       >vAdfNeedle
                    ldu       #DrawNeedleSaveBg+ModBase
                    stu       <vNeedleRtn
                    ldu       #vAdfNeedleBg
                    jmp       >DrawDialNeedle+ModBase
* InitAdfNeedle: panel init: draws the ADF needle at position 0
InitAdfNeedle               clr       >vAdfNeedle
                    bra       DrawAdfNeedleNew
* AdfNeedleDone: ADF routines: common rts
AdfNeedleDone               rts
* DrawSkyGround: 3D view: builds and projects the horizon line from the bank/pitch angles, then fills the view rows with the sky and ground colors
DrawSkyGround               ldd       <vDispListPtr
                    std       <vDispListSave
                    lda       #HzNoLine
                    sta       <vLineEnd1Row
                    lda       <vViewHdg
                    suba      #HzEndAngle
                    pshs      a
                    jsr       >Sin8+ModBase
                    std       >vHorizonSin1
                    puls      a
                    jsr       >Cos8+ModBase
                    std       >vHorizonCos1
                    lda       <vViewHdg
                    adda      #HzEndAngle
                    pshs      a
                    jsr       >Sin8+ModBase
                    std       >vHorizonSin2
                    puls      a
                    jsr       >Cos8+ModBase
                    std       >vHorizonCos2
                    ldd       #vHorizonList
                    std       <vDispListPtr
                    ldd       <vEyeX
                    std       <vEyeXSave
                    ldd       <vEyeZ
                    std       <vEyeZSave
                    ldd       #HzListZero
                    std       <vEyeX
                    std       <vEyeZ
                    std       <vBaseSumX
                    std       <vBaseSumXLo
                    std       <vBaseSumY+1
                    std       <vBaseSumZ
                    sta       <vBaseSumZLo
                    lda       #HzDeadLoad
                    lda       >vHorizonList
                    anda      #DlOpBits
                    sta       >vHorizonList
                    jsr       >RunDisplayListAt+ModBase
                    clr       <vSkyGndUnread
                    ldd       <vEyeXSave
                    std       <vEyeX
                    ldd       <vEyeZSave
                    std       <vEyeZ
                    ldd       <vDispListSave
                    std       <vDispListPtr
                    ldu       >vViewScr
* WildBits: the view bottom, 127 rows of 80
                    fcb       $33,$C9,$27,$B0
                    lda       >vGndCol
                    ldy       #TblColorPattern+ModBase
                    anda      #ColorNibble
                    asla
                    ldd       a,y
                    std       <vPatBelowHz
                    lda       >vSkyCol
                    anda      #ColorNibble
                    asla
                    ldd       a,y
                    std       <vPatAboveHz
                    clr       <vHzBotRow
* WildBits: 127 view rows
                    fcb       $86,$7F
                    sta       <vHzTopRow
                    lda       <vLineEnd1Row
                    bpl       DrawSkyGroundVisible
                    ldd       #NoHorizonList
                    std       >vHorizonPtr
                    dec       <vHzBotRow
                    lda       <vViewPitch
                    bpl       DrawSkyGroundNoHorizon
                    jsr       >SwapSkyGroundColors+ModBase
* DrawSkyGroundNoHorizon: sky/ground: horizon not visible, fills all $63 rows with one color
DrawSkyGroundNoHorizon equ       *
* WildBits: 127 view rows
                    fcb       $86,$7F
                    sta       <vFillRowCount
                    jmp       >FillViewRows+ModBase
* (TrackHorizonRowRange, gone: only the old horizon fill used it)
                    zmb       14
* DrawSkyGroundVisible: sky/ground: horizon visible, computes the rows spanned by its endpoints
DrawSkyGroundVisible equ       *
* WildBits: the scenery's white horizon line (its op 9 call through $0192) only at dawn, dusk and night; the sky
* and the ground exactly from the horizon line (fsw; returns from DrawSkyGround)
                    jmp       >FswHorizon
* WildBits: LineEq (FS's line routine at $CC04 calls it first, in place of its lda <$B7 / anda <$C0): a ground
* line's two ends to one scale before FS clips it. Each ground point carries its own scale (the exponent: <$4D for
* the <$C1 end, $0271 for the <$B8 end, 64 + the bits it was shifted up), and FS's clipper mixed them: on the
* ground the near end of a runway line got a cut point up to 4 times off, so the line bent and jumped. The end
* with the larger exponent is halved until they match, as FS's own long-line op does; only when the line will be
* clipped (an end outside, not both off one side) and both ends are ground points (3D points' exponent is 0).
* Exit: A = <$B7 & <$C0 with its flags, as the two instructions it replaces. (In the room of FS's own
* sloped-horizon code, which fsw's Horizon replaced.)
LineEq              lda       <vEnd1Clip
                    ora       <vEnd2Clip
                    beq       le9@                no end outside: no clip
                    lda       <vEnd1Clip
                    anda      <vEnd2Clip
                    bne       le9@                both off one side: not drawn
                    lda       <vPointExp
                    cmpa      #GroundPtExpMin
                    blo       le9@
                    lda       >vPrevPointExp
                    cmpa      #GroundPtExpMin
                    blo       le9@
le1@                lda       <vPointExp
                    cmpa      >vPrevPointExp
                    beq       le9@
                    bhi       le2@
                    asr       <vEnd1X             the <$B8 end halved
                    ror       <vEnd1X+1
                    asr       <vEnd1Y
                    ror       <vEnd1Y+1
                    asr       <vEnd1Z
                    ror       <vEnd1Z+1
                    dec       >vPrevPointExp
                    bra       le1@
le2@                asr       <vEnd2X             the <$C1 end halved
                    ror       <vEnd2X+1
                    asr       <vEnd2Y
                    ror       <vEnd2Y+1
                    asr       <vEnd2Z
                    ror       <vEnd2Z+1
                    dec       <vPointExp
                    bra       le1@
le9@                lda       <vEnd1Clip
                    anda      <vEnd2Clip
                    rts
                    zmb       $228B-*
* SwapSkyGroundColors: swaps the two fill color words <$D7 and <$D9
SwapSkyGroundColors               ldd       <vPatBelowHz
                    ldx       <vPatAboveHz
                    stx       <vPatBelowHz
                    std       <vPatAboveHz
                    rts
* FillViewRows: fills <$DD view rows with color <$D7 (via FillRow80)
FillViewRows               ldd       <vPatBelowHz
                    std       >vFillPat
* FillViewRowsLoop: fill rows: per-row loop
FillViewRowsLoop               jsr       >FillRow80+ModBase
                    dec       <vFillRowCount
                    bne       FillViewRowsLoop
                    rts
* (FS's sloped-horizon fill, FillHorizonSlope .. SplitRowFillTail, gone: fsw's Horizon draws the sky and ground)
                    zmb       341
* TblAttPitchRow: attitude indicator: pitch -> horizon offset table (signed, nonlinear), indexed by (pitch+$20)/2
TblAttPitchRow               fcb       $C1,$CF,$D4,$D9,$DD,$E1,$E4,$E7
                    fcb       $EA,$ED,$EF,$F2,$F4,$F7,$F9,$FC
                    fcb       $FE,$00,$02,$05,$07,$0A,$0C,$0F
                    fcb       $12,$15,$18,$1B,$1E
                    fcc       /"&+1@/
* MulSignedHi8: signed A * signed B, returns the rounded high byte in A
MulSignedHi8               tsta
                    bpl       MulSignedHi8APos
                    nega
                    tstb
                    bpl       MulSignedHi8Neg
                    negb
* MulSignedHi8Pos: signed multiply: positive result
MulSignedHi8Pos               mul
                    adca      #CarryOnly
                    rts
* MulSignedHi8APos: signed multiply: A positive, tests B
MulSignedHi8APos               tstb
                    bpl       MulSignedHi8Pos
                    negb
* MulSignedHi8Neg: signed multiply: negative result
MulSignedHi8Neg               mul
                    adca      #CarryOnly
                    nega
                    rts
* SwapAttColors: swaps the attitude indicator sky/ground colors $115A/$115B
SwapAttColors               lda       >vAttUpperCol
                    ldb       >vAttLowerCol
                    sta       >vAttLowerCol
                    stb       >vAttUpperCol
                    rts
* UpdAttitudeInd: attitude indicator: when pitch <$12 or bank <$14 changed, redraws the ball (sky, ground, sloped horizon) and the reference marks, if <$EB bit 4 is set
UpdAttitudeInd               lda       <vInstActive1
                    anda      #InstAttitude
                    beq       UpdAttitudeIndRts
                    lda       <vBank
                    suba      >vAttBankShown
                    anda      #AttMoveMask
                    beq       UpdAttitudeIndPitch
                    cmpa      #AttMoveBack
                    bne       UpdAttitudeIndRedraw
* UpdAttitudeIndPitch: attitude: checks the pitch change
UpdAttitudeIndPitch               lda       <vPitch
                    suba      >vAttPitchShown
                    anda      #AttMoveMask
                    beq       UpdAttitudeIndRts
                    cmpa      #AttMoveBack
                    bne       UpdAttitudeIndRedraw
* UpdAttitudeIndRts: attitude: no change, rts
UpdAttitudeIndRts               rts
* UpdAttitudeIndRedraw: attitude: saves pitch/bank and redraws
UpdAttitudeIndRedraw               lda       <vPitch
                    sta       >vAttPitchShown
                    lda       <vBank
                    sta       >vAttBankShown
                    lda       #AttSkyColor
                    ldb       <vPitch
                    addb      #AttPitchOfs
                    bmi       UpdAttitudeIndSolid
                    cmpb      #AttPitchSpan
                    blo       UpdAttitudeIndNormal
                    lda       #AttGroundColor
* UpdAttitudeIndSolid: attitude: pitch out of range, fills the whole ball in one color
UpdAttitudeIndSolid               jsr       >SetFillColor+ModBase
                    ldy       #TblAttBallSpans+ModBase
                    ldx       #vRowAddrTbl
                    ldb       #AttBallRow0
                    aslb
                    abx
                    ldx       ,x
                    ldd       >vPanelScr
                    leax      d,x
                    ldb       #AttBallRows
                    jsr       >FillAttBallRows+ModBase
                    jmp       >DrawAttRefMarks+ModBase
* UpdAttitudeIndNormal: attitude: sets the default colors, swaps them when inverted
UpdAttitudeIndNormal               lda       #AttSkyColor
                    sta       >vAttUpperCol
                    lda       #AttGroundColor
                    sta       >vAttLowerCol
                    ldb       <vBank
                    stb       >vAttBankShown
                    addb      #Angle8Quarter
                    bpl       UpdAttitudeIndEnds
                    jsr       >SwapAttColors+ModBase
* UpdAttitudeIndEnds: attitude: computes the horizon endpoints <$D3..<$D6 from pitch and bank (sin/cos)
UpdAttitudeIndEnds               lda       <vPitch
                    adda      #AttPitchOfs
                    lsra
                    ldx       #TblAttPitchRow+ModBase
                    lda       a,x
                    sta       <vAttPitchOfs
                    suba      <vBank
                    nega
                    sta       <vAttEndAngle
                    jsr       >Cos8+ModBase
                    ldb       #AttHzHalfLen
                    lbsr      MulSignedHi8
                    adda      #AttBallCX
                    sta       <vAttHzX1
                    lda       <vAttEndAngle
                    jsr       >Sin8+ModBase
                    asra
                    asra
                    asra
                    adda      #AttBallCY
                    sta       <vAttHzRow1
                    lda       <vBank
                    eora      #Angle8Half
                    adda      <vAttPitchOfs
                    sta       <vAttEndAngle
                    jsr       >Cos8+ModBase
                    ldb       #AttHzHalfLen
                    lbsr      MulSignedHi8
                    adda      #AttBallCX
                    sta       <vAttHzX2
                    lda       <vAttEndAngle
                    jsr       >Sin8+ModBase
                    asra
                    asra
                    asra
                    adda      #AttBallCY
                    sta       <vAttHzRow2
                    ldd       <vAttHzX1
                    cmpb      <vAttHzRow2
                    bls       UpdAttitudeIndTop
                    ldy       <vAttHzX2
                    std       <vAttHzX2
                    sty       <vAttHzX1
* UpdAttitudeIndTop: attitude: fills the rows above the horizon
UpdAttitudeIndTop               lda       >vAttUpperCol
                    jsr       >SetFillColor+ModBase
                    ldy       #TblAttBallSpans+ModBase
                    ldx       #vRowAddrTbl
                    ldb       #AttBallRow0
                    aslb
                    abx
                    ldx       ,x
                    ldd       >vPanelScr
                    leax      d,x
                    ldb       <vAttHzRow1
                    subb      #AttBallRow0
                    beq       UpdAttitudeIndColors
                    jsr       >FillAttBallRows+ModBase
* UpdAttitudeIndColors: attitude: chooses the left/right colors for the sloped rows
UpdAttitudeIndColors               lda       <vAttHzX1
                    cmpa      <vAttHzX2
                    blo       UpdAttitudeIndColors2
                    lda       >vAttLowerCol
                    sta       >vAttRightCol
                    lda       >vAttUpperCol
                    sta       >vAttLeftCol
                    bra       UpdAttitudeIndSlope
* UpdAttitudeIndColors2: attitude: colors for the other slope direction
UpdAttitudeIndColors2               lda       >vAttUpperCol
                    sta       >vAttRightCol
                    lda       >vAttLowerCol
                    sta       >vAttLeftCol
* UpdAttitudeIndSlope: attitude: draws the sloped rows, then fills the rows below
UpdAttitudeIndSlope               jsr       >FillAttSlopeRows+ModBase
                    pshs      y
                    lda       >vAttLowerCol
                    jsr       >SetFillColor+ModBase
                    puls      y
                    ldb       #AttBallLastRow
                    subb      <vAttHzRow2
                    beq       DrawAttRefMarks
                    jsr       >FillAttBallRows+ModBase
                    bra       DrawAttRefMarks
* DrawAttRefMarks: WildBits (2026-10-20): FS's CoCo attitude indicator's miniature airplane is not drawn (the dash,
* fsp, draws the attitude ball); the drawing and its table are gone, their 92 bytes zero so no FS address moves
DrawAttRefMarks               rts
                    zmb       91
* FillAttBallRows: fills B rows of the attitude ball in the current color, row spans from Y (TblAttBallSpans)
FillAttBallRows               stb       <vFillRowCount
* FillAttBallRowsLoop: ball rows: per-row loop
FillAttBallRowsLoop               pshs      x
                    jsr       >DrawAttRowSpan+ModBase
                    puls      x
                    leax      <FsRowBytes,x
                    dec       <vFillRowCount
                    bne       FillAttBallRowsLoop
                    rts
* FillAttSlopeRows: draws the attitude ball rows crossed by the sloped horizon in two colors
FillAttSlopeRows               ldd       <vAttHzX1
                    cmpb      <vAttHzRow2
                    bra       FillAttSlopeRowsCalc
                    fcb       $23,$0F,$5F,$96,$D3,$44,$56,$DD
                    fcb       $DE,$DC,$D5,$D0,$D4,$90,$D3,$20
                    fcb       $0B
* FillAttSlopeRowsCalc: ball slope: sets up the x position and step
FillAttSlopeRowsCalc               clrb
                    lsra
                    rorb
                    std       <vAttSplitX
                    ldd       <vAttHzX2
                    subb      <vAttHzRow1
                    suba      <vAttHzX1
                    pshs      cc
                    bhs       FillAttSlopeRowsDiv
                    nega
* FillAttSlopeRowsDiv: ball slope: computes the step (via DivFrac8)
FillAttSlopeRowsDiv               stb       <vFillRowCount
                    pshs      x
                    jsr       >DivFrac8+ModBase
                    puls      x
                    puls      cc
                    bhs       FillAttSlopeRowsStep
                    coma
                    comb
                    addd      #NegCarry
* FillAttSlopeRowsStep: ball slope: stores the step in <$E0
FillAttSlopeRowsStep               asra
                    rorb
                    std       <vAttSplitStep
                    ldd       <vAttSplitX
* FillAttSlopeRowsLoop: ball slope: per-row loop
FillAttSlopeRowsLoop               aslb
                    rola
                    pshs      x
                    jsr       >DrawAttSplitRow+ModBase
                    puls      x
                    leax      <FsRowBytes,x
                    ldd       <vAttSplitX
                    addd      <vAttSplitStep
                    std       <vAttSplitX
                    dec       <vFillRowCount
                    bpl       FillAttSlopeRowsLoop
                    rts
                    fcb       $34,$10,$8D,$0F,$35,$10,$30,$88
                    fcb       $50,$39,$FC,$00,$D7,$BD,$AE,$D7
                    fcb       $7E,$C6,$2C
* DrawAttRowSpan: draws one ball row span (right, left from Y) in the current color (via DrawHLine)
DrawAttRowSpan               ldd       ,y++
                    pshs      y
                    jsr       >DrawHLine+ModBase
                    puls      y,pc
* DrawAttSplitRow: draws one ball row split at x = A: left part color <$D9, right part color <$D7
DrawAttSplitRow               cmpa      1,y
                    bhs       DrawAttSplitRowRight
                    lda       >vAttRightCol
                    pshs      y
                    jsr       >SetFillColor+ModBase
                    puls      y
                    bra       DrawAttRowSpan
* DrawAttSplitRowRight: split row: boundary right of the span, whole row in <$D7
DrawAttSplitRowRight               cmpa      ,y
                    bls       DrawAttSplitRowBoth
                    lda       >vAttLeftCol
                    pshs      y
                    jsr       >SetFillColor+ModBase
                    puls      y
                    bra       DrawAttRowSpan
* DrawAttSplitRowBoth: split row: draws both parts
DrawAttSplitRowBoth               pshs      a
                    ldb       1,y
                    pshs      y
                    pshs      x
                    pshs      a,b
                    lda       >vAttLeftCol
                    jsr       >SetFillColor+ModBase
                    puls      a,b
                    jsr       >DrawHLine+ModBase
                    puls      x
                    puls      y
                    puls      b
                    lda       ,y++
                    pshs      y
                    pshs      a,b
                    lda       >vAttRightCol
                    jsr       >SetFillColor+ModBase
                    puls      a,b
                    jsr       >DrawHLine+ModBase
                    puls      y
                    rts
* TblAttBallSpans: attitude ball shape: per-row (right, left) x pairs of the circle
TblAttBallSpans               fcc       /+$,#-"-".!.!.!/
                    fcb       $2F,$20,$2F,$20,$2F,$20,$2F,$20
                    fcb       $2F,$20,$30,$1F,$30,$1F,$30,$1F
                    fcb       $30,$1F,$30,$1F,$30,$1F,$30,$1F
                    fcb       $30,$1F,$2F,$20,$2F,$20,$2F,$20
                    fcb       $2F,$20,$2F
                    fcc       / .!.!.!-"-"-",#,#+$)&('/
* TurnCoordDone: turn coordinator: rts
TurnCoordDone               rts
* InitTurnCoord: panel init: draws the turn coordinator airplane at index 0
InitTurnCoord               clra
                    bra       UpdTurnCoordDrawNew
* UpdTurnCoord: turn coordinator airplane: index from turn rate $076D (0..15); erases the old and draws the new, if <$EB bit 1 is set
UpdTurnCoord               lda       <vInstActive1
                    anda      #InstTurnCoord
                    beq       TurnCoordDone
                    ldd       >vTurnRate
                    aslb
                    rola
                    std       <vTcRateX2
                    aslb
                    rola
                    addd      <vTcRateX2
                    adda      #TurnCoordMid
                    bmi       UpdTurnCoordClampLo
                    cmpa      #TurnCoordLast
                    bls       UpdTurnCoordStore
                    lda       #TurnCoordLast
                    bra       UpdTurnCoordStore
* UpdTurnCoordClampLo: turn coordinator: clamps a negative index to 0
UpdTurnCoordClampLo               clra
* UpdTurnCoordStore: turn coordinator: compares with $0800, erases the old airplane
UpdTurnCoordStore               sta       <vTcNewIndex
                    lda       #TurnCoordErase
                    jsr       >SetLineColor+ModBase
                    lda       >vTurnIndex
                    cmpa      <vTcNewIndex
                    beq       TurnCoordDone
                    bsr       DrawTurnCoordPlane
                    lda       <vTcNewIndex
* UpdTurnCoordDrawNew: turn coordinator: stores the index in $0800 and draws in the draw color
UpdTurnCoordDrawNew               sta       >vTurnIndex
                    lda       #TurnCoordColor
                    jsr       >SetLineColor+ModBase
                    lda       >vTurnIndex
* DrawTurnCoordPlane: draws the turn coordinator airplane (wing line and tail line via DrawLine) for index A
DrawTurnCoordPlane               asla
                    asla
                    pshs      a
                    ldx       #TblTurnCoordPlane+ModBase
                    leax      a,x
                    lda       ,x
                    adda      #TurnCoordX
                    ldb       1,x
                    addb      #TurnCoordY
                    std       <vTcWingEnd
                    lda       #TurnCoordX
                    suba      ,x
                    ldb       #TurnCoordY
                    subb      1,x
                    ldx       <vTcWingEnd
                    ldy       >vPanelScr
                    jsr       >DrawLine+ModBase
                    ldx       #TblTurnCoordPlane+ModBase
                    puls      a
                    leax      a,x
                    lda       #TurnCoordX
                    adda      2,x
                    ldb       #TurnCoordY
                    addb      3,x
                    ldx       #TurnCoordXY
                    ldy       >vPanelScr
                    jmp       >DrawLine+ModBase
* TblTurnCoordPlane: 16 entries (wing dx, dy, tail dx, dy) for the turn coordinator airplane
TblTurnCoordPlane               fcb       $03,$FB,$FF,$FD,$03,$FB,$FF,$FD
                    fcb       $03,$FC,$FF,$FD,$03,$FD,$FF,$FD
                    fcb       $04,$FE,$00,$FC,$04,$FE,$00,$FC
                    fcb       $04,$FF,$00,$FC,$04,$FF,$00,$FC
                    fcb       $04,$00,$00,$FC,$04,$01,$00,$FC
                    fcb       $04,$01,$00,$FC,$04,$02,$00,$FC
                    fcb       $04,$02,$00,$FC,$04,$03,$01,$FD
                    fcb       $03,$04,$01,$FD,$03,$05,$01,$FD
                    fcb       $C9,$95,$C9,$A5,$CA,$9A,$C8,$C2
                    fcb       $C8,$C2,$C8,$C2,$C8,$C2,$C8,$C2
                    fcb       $C8,$C2,$C8,$C2,$C8,$C2,$C8,$C2
                    fcb       $C8,$C2,$C8,$C2,$C8,$C2,$C8,$C2
                    fcb       $C8,$C2,$C8,$C2,$C8,$C2,$C8,$C2
                    fcb       $C8,$C2,$C8,$C2,$C8,$C2,$C8,$C2
                    fcb       $C8,$C2,$C8,$C2,$C8,$C2,$C8,$C2
                    fcb       $C8,$C2,$C8,$C2,$C8,$C2,$C8,$C2
                    fcb       $C8,$C2,$C8,$C2,$C8,$C2,$C8,$C2
                    fcb       $C8,$C2,$C8,$C2,$C8,$C2,$C8,$C2
                    fcb       $C8,$C2,$C8,$C2,$C8,$C2,$C8,$C2
                    fcb       $C8,$C2,$C8,$C2,$C8,$C2,$C8,$C2
                    fcb       $C8,$C2,$C8,$C2,$C8,$C2,$C8,$C2
                    fcb       $C8,$C2,$C8,$C2,$C8,$C2,$C8,$C2
                    fcb       $C8,$C2,$C8,$B6,$C8,$C2,$C8,$C2
                    fcb       $C8,$C2,$C8,$C2,$C8,$C2,$C8,$C2
* TblDispListOps: middle of the display-list opcode jump table ($2788-$2887): opcode*2 as a signed offset; $C8C2 = no-op handler
TblDispListOps               fcb       $CB,$3C,$C9,$8F,$C9,$9F,$D0,$B8
                    fcb       $CF,$BC,$D1,$A0,$CC,$A3,$CE,$8A
                    fcb       $C8,$C2,$C8,$DF,$C8,$C2,$CF,$A5
                    fcb       $C8,$C2,$D1,$83,$C8,$C2,$C8,$C2
                    fcb       $C8,$C2,$C8,$A2,$D0,$B0,$CF,$EE
                    fcb       $CF,$F4,$C8,$C2,$C8,$C2,$C8,$C2
                    fcb       $C8,$C9,$C8,$F5,$CF,$AE,$D1,$6C
                    fcb       $D1,$74,$D1,$CE,$D2,$27,$C8,$C2
                    fcb       $D0,$39,$D0,$45,$D0,$54,$D0,$77
                    fcb       $CD,$16,$CF,$B5,$C8,$C2,$C8,$C2
                    fcb       $D0,$8E,$C8,$FF,$C8,$C2,$CB,$58
                    fcb       $C8,$C2,$C8,$C2,$C8,$C2,$C8,$F6
                    fcb       $C8,$C2,$CA,$74,$C9,$B8,$C9,$FF
                    fcb       $C8,$C2,$CB,$12,$C8,$C2,$C8,$C2
                    fcb       $C8,$C2,$C8,$C2,$C8,$C2,$C8,$C2
                    fcb       $C8,$C2,$C8,$C2,$C8,$C2,$C8,$C2
* RunDisplayList: runs the scenery display list at <$7B after saving the previous-frame flags ($028C, $02A3, $020E)
RunDisplayList               lda       >vNavSearch
                    sta       >vNavSearchNow
                    lda       >vComSearch
                    sta       >vComSearchNow
                    lda       >vAdfSearch
                    sta       >vAdfSearchNow
* RunDisplayListAt: runs the display list at <$7B (also used by DrawSkyGround for the horizon line)
RunDisplayListAt               clra
                    sta       >vEnd1Cut
                    sta       <vEnd2Cut
                    ldu       <vDispListPtr
                    stu       <vDispListPtr
                    lda       >vTickPend
                    beq       DispListDispatch
                    jsr       >ProcessTimerTicks+ModBase
* DispListDispatch: display list: reads the next opcode byte and jumps through TblDispListOps
DispListDispatch               ldu       <vDispListPtr
                    ldb       ,u+
                    ldx       #TblDispListOps+ModBase
                    aslb
                    jmp       [b,x]
                    fcb       $86,$00,$B7,$02,$A4,$B7,$02,$8D
                    fcb       $B7,$02,$0F,$39,$C6,$90
                    fcs       /4@~9/
                    fcb       $ED,$37,$06,$D3,$7B,$DD
                    fcc       /{4@|/
                    fcb       $02,$70,$BD,$C8,$A4,$7A,$02
                    fcs       /p5@~H/
                    fcb       $A2,$AE,$D1,$9F
                    fcc       /{4@'/
                    fcb       $09,$7C,$02,$70,$BD,$C8,$A4,$7A
                    fcb       $02
                    fcs       /p5@~H/
                    fcb       $A2,$39,$86,$FF,$97,$41,$0F,$C0
                    fcb       $7E,$C8,$A2,$BD,$AE,$D4,$DF,$7B
                    fcb       $96
                    fcc       /A&!/
                    fcb       $8E,$00,$29,$10,$8E,$00,$C0,$EC
                    fcb       $81,$ED,$A1,$EC,$81,$ED,$A1,$EC
                    fcb       $81,$ED,$A1,$EC,$81,$ED,$A1,$A6
                    fcb       $84,$A7,$A4,$BD,$CC,$04,$7E,$C8
                    fcb       $A4,$96,$C0,$2B,$03,$BD,$E4,$9E
                    fcb       $0F,$41,$7E,$C8,$A4
                    fcc       /xyzy/
                    fcb       $8E,$00,$B8,$AD,$A4,$96,$41,$27
                    fcb       $09,$BD,$E2,$59,$96,$BC,$97,$C0
                    fcb       $20,$0A,$BD,$E5,$E0,$96,$B7,$26
                    fcb       $03,$BD,$D5,$5D,$8E,$00,$B7,$10
                    fcb       $8E,$00,$29,$EC,$81,$ED,$A1,$EC
                    fcb       $81,$ED,$A1,$EC,$81,$ED,$A1,$EC
                    fcb       $81,$ED,$A1,$A6,$84,$A7,$A4,$39
                    fcb       $8E,$00,$C1,$AD,$A4,$96,$41,$27
                    fcb       $0A,$96,$C5,$94,$C0,$97,$C0,$BD
                    fcb       $E3,$28,$39,$BD,$E6,$1B,$96,$C0
                    fcb       $26,$03,$BD,$D5,$6D,$39,$10,$8E
                    fcb       $DB,$DC,$20,$04,$10,$8E,$D9,$C5
                    fcb       $BD,$C9,$39,$7E,$C8,$A4,$10,$8E
                    fcb       $DB,$DC,$20,$04,$10,$8E,$D9,$C5
                    fcb       $BD,$C9,$71,$96,$41,$10,$26,$FE
                    fcb       $F2,$BD,$CC,$04,$7E,$C8,$A4,$37
                    fcb       $04,$DF,$7B,$BD,$CA,$FF,$0F,$B7
                    fcb       $0F,$29,$9E,$4B,$10,$8E,$00,$B8
                    fcb       $CE,$00,$2A,$EC,$81,$ED,$A1,$ED
                    fcb       $C1,$EC,$81,$ED,$A1,$ED,$C1,$EC
                    fcb       $81,$ED,$A1,$ED,$C1,$EC,$84,$ED
                    fcb       $A4,$ED,$C4,$96,$41,$26,$0D,$96
                    fcb       $BF,$2A,$06,$96,$BE,$97,$B7,$97
                    fcb       $29,$7E,$C8,$A4,$96,$C5,$97,$C0
                    fcb       $BD,$E2,$59,$7E,$C8,$A4,$37,$04
                    fcb       $DF,$7B,$BD,$CA,$FF,$96
                    fcc       /A&&/
                    fcb       $0F,$C0,$9E,$4B,$10,$8E,$00,$C1
                    fcb       $EC,$81,$ED,$A1,$EC,$81,$ED,$A1
                    fcb       $EC,$81,$ED,$A1,$EC,$81,$ED,$A1
                    fcb       $96,$C8,$2A,$04,$96,$C7,$97,$C0
                    fcb       $BD,$CC,$04,$7E,$C8,$A4,$9E,$4B
                    fcb       $10,$8E,$00,$C1,$EC,$81,$ED,$A1
                    fcb       $EC,$81,$ED,$A1,$EC,$81,$ED,$A1
                    fcb       $96,$C5,$94,$C0,$97,$C0,$BD,$E3
                    fcb       $28,$7E,$C8,$A4,$BD,$E5,$E0,$96
                    fcb       $B7,$26,$03,$BD,$D5,$5D,$8E,$00
                    fcb       $B7,$10,$8E,$00,$29,$EC,$81,$ED
                    fcb       $A1,$EC,$81,$ED,$A1,$EC,$81,$ED
                    fcb       $A1,$EC,$81,$ED,$A1,$A6,$84,$A7
                    fcb       $A4,$39,$37,$04,$BD,$CA,$FF,$8E
                    fcb       $00,$C0,$10,$8E,$00,$C9,$EC,$81
                    fcb       $ED,$A1,$EC,$81,$ED,$A1,$EC,$81
                    fcb       $ED,$A1,$EC,$81,$ED,$A1,$A6,$84
                    fcb       $A7,$A4,$10,$8E,$DB,$DC
                    fcc       / $7/
                    fcb       $04,$BD,$CA,$FF,$8E,$00,$C0,$10
                    fcb       $8E,$00,$C9,$EC,$81,$ED,$A1,$EC
                    fcb       $81,$ED,$A1,$EC,$81,$ED,$A1,$EC
                    fcb       $81,$ED,$A1,$A6,$84,$A7,$A4,$10
                    fcb       $8E,$D9,$C5,$86,$FF,$97,$C8,$BD
                    fcb       $C9,$71,$96,$C0,$27,$02,$97,$C7
                    fcb       $8E,$00,$C1,$10,$9E,$4B,$EC,$81
                    fcb       $ED,$A1,$EC,$81,$ED,$A1,$EC,$81
                    fcb       $ED,$A1,$EC,$81,$ED,$A1,$8E,$00
                    fcb       $C9,$10,$8E,$00,$C0,$EC,$81,$ED
                    fcb       $A1,$EC,$81,$ED,$A1,$EC,$81,$ED
                    fcb       $A1,$EC,$81,$ED,$A1,$A6,$84,$A7
                    fcb       $A4,$7E,$C8,$A4,$4F,$C1,$1E,$23
                    fcb       $02,$C6,$1D
                    fcs       /XIXIXIC/
                    fcb       $08,$B3,$DD
                    fcc       /K97/
                    fcb       $04,$DF,$7B,$BD,$CA,$FF,$0F,$B7
                    fcb       $9E,$4B,$10,$8E,$00,$B8,$EC,$81
                    fcb       $ED,$A1,$EC,$81,$ED,$A1,$EC,$81
                    fcb       $ED,$A1,$EC,$81,$ED,$A1,$96,$BF
                    fcb       $2A,$0E,$96,$BE,$97,$B7,$7E,$CB
                    fcb       $43,$10,$8E,$DB,$DC,$BD,$C9,$39
                    fcb       $96,$B7,$10,$26,$FD,$5B,$BD,$D5
                    fcb       $5D,$DC,$BE,$10,$BE,$0C,$D9,$BD
* WildBits: the DOT op's pixel from the light's camera point (fsw Dot), not PlotPixel at its view units
                    fdb       FswDot
                    fcb       $7E,$C8,$A4,$10,$8E,$D9
                    fcb       $C5,$BD,$C9,$39,$DE,$7B,$10,$8E
                    fcb       $D9,$C5,$BD,$C9,$71,$96,$B7,$94
                    fcb       $C0,$26,$E7,$96,$4D,$B1,$02,$71
                    fcb       $27,$17,$24,$0B,$8E,$00,$B8,$BD
                    fcb       $CB,$F7,$7A,$02,$71,$20,$EC,$8E
                    fcb       $00,$C1,$BD,$CB,$F7,$0A,$4D,$20
                    fcb       $E2,$DC,$C1,$93,$B8,$DD,$89,$DC
                    fcb       $C3,$93,$BA,$DD,$8B,$DC,$C5,$93
                    fcb       $BC,$DD,$8D
* WildBits: the long line steps exactly (LlInit)
                    jsr       >LlInit+ModBase
                    fcb       $12,$12,$12,$12,$12,$12,$12,$12
                    fcb       $12,$12,$12,$12,$86,$08,$B7,$08
                    fcb       $10,$BD,$E5,$E0,$96,$B7,$26,$03
                    fcb       $BD,$D5,$5D,$8E,$00,$C1
* WildBits: the long line steps exactly (LlStep)
                    jsr       >LlStep+ModBase
                    fcb       $12,$12,$12,$12,$12,$12,$12,$12
                    fcb       $12,$12,$12,$12,$BD,$E6,$1B,$96
                    fcb       $C0,$26,$03,$BD,$D5,$6D,$BD,$CC
                    fcb       $04,$8E,$00,$B8
* WildBits: the long line steps exactly (LlStep)
                    jsr       >LlStep+ModBase
                    fcb       $12,$12,$12,$12,$12,$12,$12,$12
                    fcb       $12,$12,$12,$12,$7A,$08,$10,$10
                    fcb       $26,$FF,$BE,$7E,$C8,$A4,$67,$00
                    fcb       $66,$01,$67,$02,$66,$03,$67,$04
                    fcb       $66,$05,$39
* WildBits: FS's line routine ($CC04) first brings a ground line's ends to one scale (LineEq)
                    jsr       >LineEq+ModBase
                    nop
                    fcb       $10,$26,$00
                    fcb       $56,$96,$B7,$10,$27,$00,$0C,$BD
                    fcb       $E6,$56,$7C,$02,$82,$96,$B7,$10
                    fcb       $26,$00,$44,$96,$C0,$10,$27,$00
                    fcb       $20,$8E,$00,$C0,$10,$8E,$00,$C9
                    fcb       $EC,$81,$ED,$A1,$EC,$81,$ED,$A1
                    fcb       $EC,$81,$ED,$A1,$A6,$84,$A7,$A4
                    fcb       $BD,$E6,$9A,$0C,$7A,$96,$C0,$26
                    fcb       $1E,$B6,$02,$82,$27,$03,$BD,$D5
                    fcb       $5D,$96,$7A,$27,$03,$BD,$D5,$6D
                    fcb       $DC,$BE,$DD,$D3,$9E,$C7,$9F,$D5
* WildBits: the 3D line projected exactly by fsw
                    fcb       $10,$BE,$0C,$D9
                    jsr       >FswLine3
                    fcb       $96
                    fcb       $7A,$10,$27,$00,$19,$8E,$00,$C9
                    fcb       $10,$8E,$00,$B7,$EC,$81,$ED,$A1
                    fcb       $EC,$81,$ED,$A1,$EC,$81,$ED,$A1
                    fcb       $A6,$84,$A7,$A4,$20,$1B,$8E,$00
                    fcb       $C0,$10,$8E,$00,$B7,$EC,$81,$ED
                    fcb       $A1,$EC,$81,$ED,$A1,$EC,$81,$ED
                    fcb       $A1,$EC,$81,$ED,$A1,$A6,$84,$A7
                    fcb       $A4,$4F,$97,$7A,$B7,$02,$82,$39
                    fcb       $37,$16,$DF,$7B,$10,$BE,$0C,$D9
                    fcb       $BD,$AF,$43,$7E,$C8,$A4,$D6,$01
                    fcb       $A3,$C1,$D7,$0C,$DC,$02,$58,$49
                    fcb       $09,$0C,$58,$49,$09,$0C,$58,$49
                    fcb       $09,$0C,$58,$49,$09,$0C,$97,$0D
                    fcb       $7D,$01,$39,$27,$05,$F6,$01,$8B
                    fcb       $20,$02,$D6,$05,$A3,$C1,$D7,$0E
                    fcb       $7D,$01,$39,$27,$05,$FC,$01,$8C
                    fcb       $20,$02,$DC,$06,$58,$49,$09,$0E
                    fcb       $58,$49,$09,$0E,$58,$49,$09,$0E
                    fcb       $58,$49,$09,$0E,$97,$0F,$D6,$09
                    fcb       $A3,$C1,$D7,$10,$DC,$0A,$58,$49
                    fcb       $09,$10,$58,$49,$09,$10,$58,$49
                    fcb       $09,$10,$58,$49,$09,$10,$97,$11
                    fcb       $16,$00,$82,$37,$02,$10,$27,$00
                    fcb       $2F,$80,$04,$10,$2B,$FF,$8F,$10
                    fcb       $27,$00,$40,$81,$02,$10,$27,$00
                    fcb       $7F,$DC,$00,$A3,$C1,$DD,$0C,$7D
                    fcb       $01,$39,$27,$05,$FC,$01,$8A,$20
                    fcb       $02,$DC,$04,$A3,$C1,$DD,$0E,$DC
                    fcb       $08,$A3,$C1,$DD,$10,$16,$00,$4D
                    fcb       $DC,$02,$DD,$0C,$7D,$01,$39,$27
                    fcb       $05,$FC,$01,$8C,$20,$02,$DC,$06
                    fcb       $DD,$0E,$DC,$0A,$DD,$10,$33,$46
                    fcb       $16,$00,$32,$D6,$01,$A3,$C1,$D7
                    fcb       $0C,$96,$02,$97,$0D,$7D,$01,$39
                    fcb       $27,$05,$F6,$01,$8B,$20,$02,$D6
                    fcb       $05,$A3,$C1,$D7,$0E,$7D,$01,$39
                    fcb       $27,$05,$B6,$01,$8C,$20,$02,$96
                    fcb       $06,$97,$0F,$D6,$09,$A3,$C1,$D7
                    fcb       $10,$96,$0A,$97,$11,$DC,$0E,$26
                    fcb       $02,$0C,$0F,$10,$93,$53,$27,$05
                    fcb       $DD,$53,$BD,$D9,$4A,$7E,$C8,$A2
                    fcb       $DC,$00,$A3,$C1,$DD,$0C,$96,$0D
                    fcb       $D6,$02,$58,$49,$09,$0C,$58,$49
                    fcb       $09,$0C,$58,$49,$09,$0C,$58,$49
                    fcb       $09,$0C,$97,$0D,$7D,$01,$39,$27
                    fcb       $05,$FC,$01,$8A,$20,$02,$DC,$04
                    fcb       $A3,$C1,$DD,$0E,$96,$0F,$7D,$01
                    fcb       $39,$27,$05,$F6,$01,$8C,$20,$02
                    fcb       $D6,$06,$58,$49,$09,$0E,$58,$49
                    fcb       $09,$0E,$58,$49,$09,$0E,$58,$49
                    fcb       $09,$0E,$97,$0F,$DC,$08,$A3,$C1
                    fcb       $DD,$10,$96,$11,$D6,$0A,$58,$49
                    fcb       $09,$10,$58,$49,$09,$10,$58,$49
                    fcb       $09,$10,$58,$49,$09,$10,$97,$11
                    fcb       $16,$FF,$82,$DC,$02,$A3,$C4,$DD
                    fcb       $0C,$D6,$01,$E2,$43,$57,$06,$0C
                    fcb       $06,$0D,$57,$06,$0C,$06,$0D,$57
                    fcb       $06,$0C,$06,$0D,$57,$06,$0C,$06
                    fcb       $0D,$33,$44,$B6,$01,$39,$27,$0C
                    fcb       $FC,$01,$8C,$A3,$C4,$DD,$0E,$F6
                    fcb       $01,$8B,$20,$08,$DC,$06,$A3,$C4
                    fcb       $DD,$0E,$D6,$05,$E2,$43,$57,$06
                    fcb       $0E,$06,$0F,$57,$06,$0E,$06,$0F
                    fcb       $57,$06,$0E,$06,$0F,$57,$06,$0E
                    fcb       $06,$0F,$33,$44,$DC,$0A,$A3,$C4
                    fcb       $DD,$10,$D6,$09,$E2,$43,$57,$06
                    fcb       $10,$06,$11,$57,$06,$10,$06,$11
                    fcb       $57,$06,$10,$06,$11,$57,$06,$10
                    fcb       $06,$11,$33,$44,$16,$FF,$0E,$37
                    fcb       $02,$10,$27,$00,$46,$80,$04,$10
                    fcb       $2B,$FF,$80,$10,$27,$00,$61,$81
                    fcb       $02,$10,$27,$00,$97,$DC,$02,$A3
                    fcb       $C1,$DC,$00,$E2,$41,$A2,$C1,$DD
                    fcb       $0C,$B6,$01,$39,$27,$0A,$FC,$01
                    fcb       $8C,$A3,$C1,$FC,$01,$8A,$20,$06
                    fcb       $DC,$06,$A3,$C1,$DC,$04,$E2,$41
                    fcb       $A2,$C1,$DD,$0E,$DC,$0A,$A3,$C1
                    fcb       $DC,$08,$E2,$41,$A2,$C1,$DD,$10
                    fcb       $16,$FE,$C2,$DC,$02,$A3,$C1,$DD
                    fcb       $0C
                    fcc       /3B}/
                    fcb       $01,$39,$27,$05,$FC,$01,$8C,$20
                    fcb       $02,$DC,$06,$A3,$C1,$DD,$0E,$33
                    fcb       $42,$DC,$0A,$A3,$C1,$DD,$10,$33
                    fcb       $42,$16,$FE,$9D,$96,$03,$A0,$41
                    fcb       $DC,$01,$E2,$C4,$A2,$43,$DD,$0C
                    fcb       $33,$44,$B6,$01,$39,$27,$0A,$B6
                    fcb       $01,$8D,$A0,$41,$FC,$01,$8B,$20
                    fcb       $06,$96,$07,$A0,$41,$DC,$05,$E2
                    fcb       $C4,$A2,$43,$DD,$0E,$33,$44,$96
                    fcb       $0B,$A0,$41,$DC,$09,$E2,$C4,$A2
                    fcb       $43,$DD,$10
                    fcs       /3D~M/
                    fcb       $98,$DC,$02,$A3,$C1,$97,$0D,$DC
                    fcb       $00,$E2,$41,$A2,$C1,$47,$56,$06
                    fcb       $0D,$47,$56,$06,$0D,$47,$56,$06
                    fcb       $0D,$47,$56,$06,$0D,$D7,$0C,$B6
                    fcb       $01,$39,$27,$0C,$FC,$01,$8C,$A3
                    fcb       $C1,$97,$0F,$FC,$01,$8A,$20,$08
                    fcb       $DC,$06,$A3,$C1,$97,$0F,$DC,$04
                    fcb       $E2,$41,$A2,$C1,$47,$56,$06,$0F
                    fcb       $47,$56,$06,$0F,$47,$56,$06,$0F
                    fcb       $47,$56,$06,$0F,$D7,$0E,$DC,$0A
                    fcb       $A3,$C1,$97,$11,$DC,$08,$E2,$41
                    fcb       $A2,$C1,$47,$56,$06,$11,$47,$56
                    fcb       $06,$11,$47,$56,$06,$11,$47,$56
                    fcb       $06,$11,$D7,$10,$16,$FD,$F3,$37
                    fcb       $06,$D3,$7B,$DD,$7B,$7E,$C8,$A4
                    fcb       $EC,$D1,$ED,$D1,$7E,$C8,$A2,$37
                    fcb       $16,$ED,$84,$7E,$C8,$A2,$37,$06
                    fcb       $D3,$7B,$DD,$7B,$86,$F8,$97,$C9
                    fcb       $E6,$C0,$10,$2B,$00,$19,$BD,$CA
                    fcb       $FF,$9E,$4B,$A6,$07,$2B,$07,$A6
                    fcb       $C0,$2A,$FC,$7E,$C8,$A2,$A6,$06
                    fcb       $94,$C9,$97,$C9,$16,$FF,$E1,$96
                    fcb       $C9,$10,$27,$F8,$B7,$7E,$C8,$A4
                    fcb       $BD,$D0,$0D,$7E,$C8,$A2,$BD,$D0
                    fcb       $0D,$B6,$01,$39,$27,$05,$FC,$01
                    fcb       $8A,$20,$02,$DC,$04,$10,$A3,$5E
                    fcb       $10,$2A,$F8,$9A,$7E,$C8,$A2,$37
                    fcb       $06,$D3,$7B,$DD,$7B,$37,$06,$93
                    fcb       $08,$2A,$05,$43,$53,$C3,$00,$01
                    fcb       $10,$A3,$42,$2A,$11,$37,$06,$93
                    fcb       $00,$2A,$05,$43,$53,$C3,$00,$01
                    fcb       $10,$A3,$C1,$2A,$01
                    fcs       /92b~H/
                    fcb       $A4,$37,$06,$D3,$7B,$DD,$7B,$BD
                    fcb       $D0,$66,$7E,$C8,$A2,$37,$06,$D3
                    fcb       $7B,$DD,$7B,$BD,$D0,$66,$BD,$D0
                    fcb       $66,$7E,$C8,$A2,$37,$06,$D3,$7B
                    fcb       $DD,$7B,$BD,$D0,$66,$BD,$D0,$66
                    fcb       $BD,$D0,$66,$7E,$C8,$A2,$EC,$D1
                    fcb       $10,$A3,$C1,$10,$2D,$FF,$C5,$10
                    fcb       $A3,$C1,$10,$2E,$FF,$BE,$39,$37
                    fcb       $06,$D3,$7B,$DD,$7B,$EC,$D1,$A4
                    fcb       $C1,$10,$26,$F8,$1D,$E4,$5F,$10
                    fcb       $27,$F8,$19,$7E,$C8,$A2,$8E,$D0
                    fcb       $AA,$37,$02,$EC,$86,$FD,$D0,$A3
                    fcb       $37,$06,$D3,$7B,$DD,$7B,$EC,$D1
                    fcb       $10,$A3,$D1,$10,$21,$F7,$FD,$7E
                    fcb       $C8,$A2,$10,$27,$10,$2E,$10,$2D
                    fcb       $37,$02,$BD,$AE,$C8,$7E,$C8,$A2
                    fcb       $37,$02,$BB,$01,$4A,$BB,$01,$48
                    fcb       $43,$8B,$41,$97,$E2,$BD,$D3,$AB
                    fcb       $DD,$94,$96,$E2,$BD,$D3,$AE,$DD
                    fcb       $AB,$DD,$B1,$37,$06,$DD,$57,$DD
                    fcb       $AF,$BD,$D2,$83,$DD,$5D,$FD,$0E
                    fcb       $03,$43,$53,$C3,$00,$01,$FD,$0E
                    fcb       $07,$DC,$94,$DD,$B1,$DC,$57,$DD
                    fcb       $AF,$BD,$D2,$83,$DD,$60,$FD,$0E
                    fcb       $01,$43,$53,$C3,$00,$01,$FD,$0E
                    fcb       $05,$37,$06,$DD,$85,$DD,$AF,$DC
                    fcb       $AB,$DD,$B1,$BD,$D2,$83,$DD,$63
                    fcb       $DC,$85,$DD,$AF,$DC,$94,$DD,$B1
                    fcb       $BD,$D2,$83,$DD,$94,$D3,$5D,$FD
                    fcb       $0D,$ED,$43,$53,$C3,$00,$01,$FD
                    fcb       $0D,$F7,$DC,$60,$D3,$63,$FD,$0D
                    fcb       $F0,$43,$53,$C3,$00,$01,$FD,$0D
                    fcb       $FA,$DC,$60,$93,$63,$FD,$0D,$EB
                    fcb       $43,$53,$C3,$00,$01,$FD,$0D,$F5
                    fcb       $DC,$5D,$93,$94,$FD,$0D,$F2,$43
                    fcb       $53,$C3,$00,$01,$FD,$0D,$FC,$34
                    fcb       $40,$CC,$0D,$E9,$DD,$7B,$CC,$00
                    fcb       $00,$FD,$01,$78,$BD,$C8,$88
                    fcs       /5@~H/
                    fcb       $A2,$86,$FF,$BD,$AE,$C8,$7E,$C8
                    fcb       $A2,$B6,$01,$3F,$84,$01,$26,$05
                    fcb       $86,$EE,$BD,$AE,$C8,$7E,$C8,$A2
                    fcb       $1F,$31,$37,$02,$B7,$02,$49,$37
                    fcb       $06,$D3,$7B,$FD,$02,$47,$37,$06
                    fcb       $F7,$02
                    fcs       /J4@=/
                    fcb       $B8,$C2
                    fcs       /5@~H/
                    fcb       $A2,$30,$48,$9F,$7B,$B6,$02,$0F
                    fcb       $27,$22,$7F,$02,$0E,$37,$06,$10
                    fcb       $B3,$09,$A5,$26,$17,$8E,$02,$93
                    fcs       /_7"m/
                    fcb       $81,$10,$AF,$81,$37,$22,$ED,$81
                    fcb       $10,$AF,$81,$86,$01,$B7,$09,$A4
                    fcb       $7E,$C8,$A4,$30,$4A,$9F,$7B,$B6
                    fcb       $02,$8D,$27,$4D,$7F,$02,$8C
                    fcc       /4@7/
                    fcb       $06,$10,$B3,$02,$91,$26,$19,$8E
                    fcb       $02,$9B,$37,$26,$ED,$81,$10,$AF
                    fcb       $81,$37,$26,$ED,$81,$10,$AF,$81
                    fcb       $86,$01,$BA,$02,$8E,$B7,$02,$8E
                    fcc       /5@4@7/
                    fcb       $06,$10,$B3,$02,$8F,$26,$19,$8E
                    fcb       $02,$93,$37,$26,$ED,$81,$10,$AF
                    fcb       $81,$37,$26,$ED,$81,$10,$AF,$81
                    fcb       $86,$02,$BA,$02,$8E,$B7,$02,$8E
                    fcs       /5@~H/
                    fcb       $A4,$37,$06,$D3,$7B,$DD,$7B,$B6
                    fcb       $02,$A4,$27,$2E,$7F,$02,$A3,$EC
                    fcb       $C1,$10,$83,$FF,$FF,$26,$03,$FD
                    fcb       $02,$03,$10,$B3,$02,$03,$26,$1A
                    fcb       $8E,$02,$A5,$37,$26,$ED,$81,$10
                    fcb       $AF,$81,$37,$26,$ED,$81,$10,$AF
                    fcb       $81,$FF,$02,$C4,$7F,$02,$AD,$BD
                    fcb       $EA,$51,$7E,$C8,$9A
