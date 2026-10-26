********************************************************************
* fst.asm - FS (Flight Simulator II), WildBits port: traffic. Included by fsx.asm (TRAFFIC defined: the K2's fsx;
* the Jr2's has no GPU and keeps the block for ac.archer): fsx's block, its 32-bit and Q15 helpers, its GPU
* record senders. fsw's Ovl calls FsxTraffic (TfEntry) in every frame that is not a spot frame; fsx's TfDraw calls
* TfRun after the spot view's aircraft. Needs rc26's GPU with the spot view's meshes loaded (GpOn).
*
* Actor 1: the traffic jet flying the plan in fst_plan.asm (plan_ord_circuit.py): a list of points; from point i
* it flies to point NEXT(i) in DUR(i) ticks of FS's clock (5 a second) on a straight line at a constant step, its
* heading, pitch and bank blended from point i's to NEXT(i)'s, moved every frame by the frame's own time as FS
* moves the user's aircraft (TfTick: 60 ticks a second, the plan's DUR x 12); at a point with a gate it waits (GATE_WAIT;
* GATE_RWY: and then until the runway box is clear of the user's aircraft), goes around (GATE_APP: the box busy,
* on to the go-around chain) or jumps (GATE_JMP: to a point at the same position). It runs from FS's start,
* whatever reality mode is, from point PlLoop.
*
* Drawing: SETMAT with M = C^T x Cv (Cv: BuildViewMatrix's rotation for the actor's heading and pitch, bank 0,
* unscaled; C's columns carry FS's scales, so M's rows do, as the spot view's Archer), T = (d . C) >> 7 with d
* the actor's position from the eye in 1/64 m (48-bit products on the math block), then MESH the airframe. Only
* within 64 km of the eye and in front of it; far away the mesh is drawn 2^s times its size (SETMAT's scale) so
* it stays a few dots: s = the bit count of the view depth past 2^22 (a kilometer), to 7. Records as fsx's GpDraw: the scenery's fed first, the light and the
* projection resent, then the actor's. TfMode: 0 no drawing (the map view), 1 the forward view (the eye
* <$00-<$0B, the view matrix <$68), 2 the spot view (fsx's SpEye and SpM).
* Constants: the values fst's instructions use, by name (here, not in fsx.asm: fsx includes fst.asm
* only for the K2, ifdef WBTRAF)
BdLtDirEnd          equ       BdLt+6              the end of BdLt's light direction (three Q15 words)
BdScale             equ       3                   the buildings' SETMAT scale: 3, 1/8 m units
CbBlocks            equ       1                   the blocks CbIn / CbOut clear or map at $4000: one 8 KB block
ClockZero           equ       0                   a tick count's start (TfT, TfTrT): 0
ComplementBits      equ       $FF                 eor with it: a byte's one's complement (every bit flipped)
DegPerByteFrac      equ       104                 an angle byte to degrees: h + h x 104 / 256 (360 / 256)
FsclMax             equ       $2000               fscl's most bytes: its one 8 KB block, I$Read's count (fscl.asm's ClMaxB)
PlGateEnd           equ       $FF                 PlGates' end marker: a point $FF (fst_plan.asm)
PuffScaleAdd        equ       2                   a puff's scale over the actor's: 4 times its magnification
PuffScaleMax        equ       15                  a puff's largest SETMAT scale
Q15Zero             equ       0                   a Q15 zero: a matrix entry
QuotStart           equ       0                   a division by repeated subtraction: the quotient's start
RemStart            equ       0                   TfDiv's remainder's start: 0
StepPerTick         equ       546                 FS's time step $077C per tick (ticks x 546)
TfBehind            equ       4                   TfTrans's A (and TfDiag): 4 behind the eye
TfBoxReach          equ       128                 map units: a runway box reaches this far from its center each way
TfBoxReachNeg       equ       -128                -TfBoxReach
TfCvEnd             equ       TfCv+18             the end of TfCv (nine Q15 words)
TfDiagMap           equ       5                   TfDiag 5: the map view, no drawing
TfDivBits           equ       32                  TfDiv's steps: the dividend's bits
TfDrawn             equ       2                   TfDiag 2: the actor drawn
TfDstMax            equ       999                 the readout's largest distance, hundreds of m (999: past it, none)
TfDstMeters         equ       100                 FswTfDst's unit: meters (hundreds of m)
TfFar               equ       3                   TfTrans's A (and TfDiag): 3 out of range (64 km)
TfFlying            equ       1                   TfOn 1: the actor flies
TfFMax              equ       255                 TfF's top: the leg's fraction gone, 255/256
TfJumpDist          equ       2                   map units: the user's aircraft moved this far in a frame jumped (the actor starts over)
TfJumpNeg           equ       -2                  -TfJumpDist
TfModeFwd           equ       1                   TfMode 1: the forward view (FS's eye and matrix)
TfOnLeg             equ       1                   TfLeg 1: on the leg from TfPt to its NEXT
TfPosZ              equ       TfPos+8             TfPos's Z (32 bits)
TfRangeBot          equ       $C0                 -64 as a byte: TfD's byte 1 at or above it, top byte $FF: within 64 km behind
TfRangeTop          equ       64                  TfD's byte 1 (1/64 m) under it, top byte 0: within 64 km ahead
TfScaleMax          equ       7                   the actor's largest SETMAT scale
TfScaleTop          equ       4                   TfScale's least when the depth's top byte is set (2^24 and up, 4 km)
TfTrailTicks        equ       120                 ticks between the smoke trail's samples (2 s)
TfTShift            equ       7                   T = (d . C) >> 7: TfShr7's shift
TfVelY              equ       TfVel+4             TfVel's Y step (32 bits)
TfVelZ              equ       TfVel+8             TfVel's Z step (32 bits)
TicksPerSec         equ       60                  TfT's ticks a second (FS's clock, TfTick)
TickStep            equ       1                   TfDt's countdown: one tick a pass


* The plan's records (plan_ord_circuit.py, 2026-10-19): a point's NEXT is the point after it, the last point's is
* PlLoop; the gates are in PlGates (point, gate, param high, param low; $FF ends). Heading, pitch and bank are
* blended from a point's to its NEXT's along the leg.
PlRec               equ       12
PlX                 equ       0                   X, Z: meters from the plan's origin (PlOX, PlOZ: FS's position, 1/256 m)
PlZ                 equ       2
PlY                 equ       4                   meters above the ground (2)
PlH                 equ       6                   heading (2, FS's angle)
PlP                 equ       8                   pitch, nose up positive (the angle's high byte)
PlB                 equ       9                   bank, right wing down positive (the angle's high byte)
PlDur               equ       10                  the leg's ticks (2)
PlBoxRec            equ       14                  a runway box: Xlo, Xhi, Zlo, Zhi (meters words), top (m), center X, Z (map)
GATE_WAIT           equ       1
GATE_RWY            equ       2
GATE_JMP            equ       4                   on to the point in the low byte (at the same position)

* Variables
TfMode              fcb       0                   this frame's A
TfOn                fcb       0                   1: the actor flies (0: TfStart at the next frame)
TfDiag              fcb       0                   DIAGNOSTIC: the last frame's traffic state (see TfRun)
TfPt                fcb       0                   the point the actor is at or has left
TfLeg               fcb       0                   1: on the leg from TfPt to its NEXT
TfT                 fdb       0                   ticks (60 a second) into the gate wait or the leg
TfDt                fdb       0                   this frame's ticks (TfTick)
TfDur               fdb       0                   the leg's ticks (the plan's DUR x 12)
TfPos               zmb       12                  the actor: X, Y, Z (32-bit, 1/256 m)
TfVel               zmb       12                  the leg's step a tick (60 a second)
TfH                 fdb       0                   heading, pitch (FS's: positive nose down), bank (right wing down)
TfP                 fdb       0
TfB                 fdb       0
TfF                 fcb       0                   the leg's fraction gone (0-255): the blend
TfN                 zmb       4                   TfDiv's dividend, then the quotient
TfRem               zmb       3
TfCnt               fcb       0
TfSgn               fcb       0
TfEye               fdb       0                   the eye and the view matrix this frame
TfC                 fdb       0
TfD                 zmb       12                  the actor from the eye, 1/64 m
TfAcc               zmb       6                   a 48-bit sum
TfPr                zmb       6                   a 48-bit product
TfDabs              zmb       4
TfCabs              fdb       0
TfSg                fcb       0
TfI                 fcb       0
TfJ                 fcb       0
TfK                 fcb       0
TfSum               fdb       0
TfTrail             zmb       ACTOR_TRAIL_LENGTH*12  the smoke trail: the actor's positions, one every 2 s (a ring)
TfTrN               fcb       0                   positions held (to ACTOR_TRAIL_LENGTH)
TfTrI               fcb       0                   the next slot
TfTrT               fdb       0                   ticks since the last sample
GpMeshS             fdb       GpSF,GpNfS,GpSF+GpNfS  MESH: the smoke puff
                    fcb       0
TfUx                fdb       0                   the user's map square last frame (X, Z): a jump restarts the actor
TfUz                fdb       0
TfDx                fdb       0                   the readout's |dx| or the smaller of |dx|, |dz|
TfSh                fdb       0                   the actor's sines and cosines
TfCh                fdb       0
TfSp                fdb       0
TfCp                fdb       0
TfCv                zmb       18                  the actor's rotation
TfM                 zmb       18                  SETMAT's payload: M, T, scale, pad (35 bytes: five units)
TfT3                zmb       12
TfScale             zmb       5
BdC                 zmb       18                  BdDraw: C with its columns a rotation again
BdLt                zmb       6                   SETLIGHT: the sun in the view, AMB, DIF
                    fcb       72,183
                    zmb       6
BdPos               zmb       12                  a mesh's origin (X, Y, Z: 1/256 m)
* TfEntry (FsxTraffic, fsw's Ovl in a frame that is not a spot frame): the forward view, or no drawing in the
* map view. TfRun: A = the mode. FS's DP 0. Registers clobbered.
TfEntry             lda       #TfModeFwd
                    tst       >vMapView
                    beq       TfRun
                    clra
TfRun               sta       TfMode              the traffic runs whatever reality mode is (Roger 2026-10-18)
* DIAGNOSTIC (TfDiag, fst's own: FswSeFlt is the SceneEngine's fault count): 2 drawn, 3 out of range, 4 behind
* the eye, 5 the map view
fr1@                tst       TfOn
                    bne       fr1a@
                    lbsr      TfStart
                    lbra      fr5@
fr1a@               ldd       <vPosX              the user's aircraft jumped a map square or more (a crash
                    subd      TfUx                reset, a position edit): everything starts over
                    cmpd      #TfJumpDist
                    bge       fr1b@
                    cmpd      #TfJumpNeg
                    ble       fr1b@
                    ldd       <vPosZ
                    subd      TfUz
                    cmpd      #TfJumpDist
                    bge       fr1b@
                    cmpd      #TfJumpNeg
                    bgt       fr2@
fr1b@               lbsr      TfStart
                    lbra      fr5@
fr2@                ldd       <vPosX
                    std       TfUx
                    ldd       <vPosZ
                    std       TfUz
                    lbsr      TfTick                D = the ticks since last frame
                    std       TfDt
                    addd      TfT
                    std       TfT
                    tst       TfLeg
                    bne       fr4@
                    lbsr      TfGate                at a point: its gate (X = its PlGates entry)
                    bcc       frgo@
                    lda       1,x
                    cmpa      #GATE_WAIT
                    bne       frg2@
                    lda       3,x                 seconds (the parameter's low byte) x 60
                    ldb       #TicksPerSec
                    mul
                    cmpd      TfT
                    lbhi      fr5@                not yet
                    lbra      frgo@
frg2@               cmpa      #GATE_JMP
                    beq       frgj@
                    cmpa      #GATE_RWY
                    bne       frg3@
                    lda       3,x
                    ldb       #TicksPerSec
                    mul
                    cmpd      TfT
                    lbhi      fr5@
                    ldb       2,x                 the runway box
                    lbsr      TfInBox
                    lbcs      fr5@                the user's aircraft on it: wait
                    lbra      frgo@
frg3@               ldb       2,x                 GATE_APP: the box busy, off to the point in the low byte
                    pshs      x                   (TfInBox clobbers X: the jump read the box before 2026-10-19)
                    lbsr      TfInBox
                    puls      x
                    lbcc      frgo@
frgj@               lda       3,x
                    sta       TfPt
                    clr       TfLeg
                    ldd       #ClockZero
                    std       TfT
                    lbsr      TfAtPt
                    lbra      fr5@
frgo@               lbsr      TfGo
                    lbra      fr5@
fr4@                ldd       TfT                 on the leg: arrived?
                    cmpd      TfDur
                    blo       fr4a@
                    lbsr      TfNext              B = the NEXT point
                    tfr       b,a
                    cmpa      TfPt                the plan loops back (a lap, the circle's start): the trail
                    bhi       fr4c@               vanishes and starts over (Roger 2026-10-17)
                    clr       TfTrN
                    clr       TfTrI
fr4c@               sta       TfPt
                    clr       TfLeg
                    ldd       #ClockZero
                    std       TfT
                    lbsr      TfAtPt
                    lbra      fr5@
fr4a@               ldd       TfDt                the step for each tick
                    beq       fr5@
                    addd      TfTrT               the trail's clock first: the loop counts TfDt down to 0
                    std       TfTrT
fr4b@               ldx       #TfPos
                    ldu       #TfVel
                    lbsr      Add32
                    leax      4,x
                    leau      4,u
                    lbsr      Add32
                    leax      4,x
                    leau      4,u
                    lbsr      Add32
                    ldd       TfDt
                    subd      #TickStep
                    std       TfDt
                    bne       fr4b@
                    ldd       TfTrT               the trail: a sample every 120 ticks (2 s) on the move
                    cmpd      #TfTrailTicks
                    blo       fr5@
                    ldd       #ClockZero
                    std       TfTrT
                    ldb       TfTrI
                    lda       #Pos32Size
                    mul
                    ldu       #TfTrail
                    leau      d,u
                    ldx       #TfPos
                    ldb       #Pos32Size
                    lbsr      CpB
                    inc       TfTrI
                    lda       TfTrI
                    cmpa      #ACTOR_TRAIL_LENGTH
                    blo       fr4d@
                    clr       TfTrI
fr4d@               lda       TfTrN
                    cmpa      #ACTOR_TRAIL_LENGTH
                    bhs       fr5@
                    inc       TfTrN
fr5@                tst       TfLeg               on a leg: heading, pitch and bank blended
                    beq       fr5a@
                    lbsr      TfBlend
fr5a@               lbsr      TfFind              the readout: where the actor is from the user's nose
                    lbsr      BdDraw              the buildings' meshes (and their flag, in the map view too)
                    tst       TfMode
                    beq       fr8@
                    tst       TfOn
                    beq       fr9@
                    lbra      TfDraw
fr8@                lda       #TfDiagMap
                    sta       TfDiag
fr9@                rts

* TfFind: the rate panel's readout (fsw's TfBrgV, TfDstV): the actor's bearing from the user's nose in degrees
* clockwise and its distance in hundreds of meters, from the meters words of the positions (FS's Atan2Angle on
* the difference, halved until both parts fit its $1FFF; the length as the larger part plus 3/8 of the smaller).
TfFind              ldd       TfPos+1             dx, meters
                    subd      <vPosX+1
                    std       <vAtanX
                    ldd       TfPos+9             dz
                    subd      <vPosZ+1
                    std       <vAtanY
tf1@                ldd       <vAtanX
                    bpl       tf2@
                    lbsr      TfNegD
tf2@                cmpd      #Atan2Max
                    bhs       tf3@
                    ldd       <vAtanY
                    bpl       tf2a@
                    lbsr      TfNegD
tf2a@               cmpd      #Atan2Max
                    blo       tf4@
tf3@                asr       <vAtanX             too long for Atan2Angle: halved (the distance keeps the
                    ror       <vAtanX+1           original below)
                    asr       <vAtanY
                    ror       <vAtanY+1
                    bra       tf1@
tf4@                ldd       TfPos+1             the distance: |dx|, |dz|
                    subd      <vPosX+1
                    bpl       tf5@
                    lbsr      TfNegD
tf5@                std       TfDx
                    ldd       TfPos+9
                    subd      <vPosZ+1
                    bpl       tf6@
                    lbsr      TfNegD
tf6@                cmpd      TfDx                D = the larger, TfDx the smaller
                    bhs       tf7@
                    ldx       TfDx
                    std       TfDx
                    tfr       x,d
tf7@                pshs      d
                    ldd       TfDx                3/8 of the smaller
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    std       TfDx
                    lsra
                    rorb
                    addd      TfDx
                    addd      ,s++
                    bcs       tf8@                past 65 km
                    ldx       #QuotStart          / 100
tf7a@               subd      #TfDstMeters
                    bcs       tf7b@
                    leax      1,x
                    bra       tf7a@
tf7b@               cmpx      #TfDstMax
                    blo       tf9@
tf8@                ldx       #TfDstMax
tf9@                stx       >FswTfDst
                    jsr       >FsAtan2            the bearing of (dx, dz), FS's angle
                    subd      >vHdg               from the user's heading
                    tfr       a,b                 degrees = h + (h x 104) / 256 (h: the angle's high byte)
                    clra
                    pshs      d
                    lda       #DegPerByteFrac
                    mul
                    tfr       a,b
                    clra
                    addd      ,s++
                    std       >FswTfBrg
                    rts

* TfStart: the plan from point 0, the clock marked.
TfStart             lda       #TfFlying
                    sta       TfOn
                    clr       TfTrN               the trail starts afresh
                    clr       TfTrI
                    ldd       #ClockZero
                    std       TfTrT
                    ldd       <vPosX              the user's map square, for the jump test
                    std       TfUx
                    ldd       <vPosZ
                    std       TfUz
                    lda       #PlLoop             the plan's start
                    sta       TfPt
                    clr       TfLeg
                    ldd       #ClockZero
                    std       TfT
                    lbra      TfAtPt

* TfTick: D = this frame's ticks (60 a second), the time the user's aircraft moves by: FS's UpdateFlightPhysics
* reads them from /FTDD (SS.VCtr) each frame and keeps them x 546 as its time step $077C (at most 59: $7Fxx), so
* the actor moves every frame as the Piper does, not in fifths of a second. X kept.
TfTick                pshs      x
                    ldd       >vTimeStep
                    ldx       #QuotStart
tk1@                subd      #StepPerTick
                    blo       tk2@
                    leax      1,x
                    bra       tk1@
tk2@                tfr       x,d
                    puls      x,pc

* TfRec: X = point TfPt's record; TfRecB: X = point B's. D clobbered.
TfRec                 ldb       TfPt
TfRecB                lda       #PlRec
                    mul
                    ldx       #Plan
                    leax      d,x
                    rts

* TfNext: B = point TfPt's NEXT (the point after it; after the last, PlLoop).
TfNext                ldb       TfPt
                    incb
                    cmpb      #PlN
                    blo       nx1@
                    ldb       #PlLoop
nx1@                rts

* TfGate: carry set and X = point TfPt's PlGates entry, if it has one. A clobbered.
TfGate                ldx       #PlGates
gt1@                lda       ,x
                    cmpa      #PlGateEnd
                    beq       gt8@
                    cmpa      TfPt
                    beq       gt9@
                    leax      4,x
                    bra       gt1@
gt8@                andcc     #^Carry
                    rts
gt9@                orcc      #Carry
                    rts

* TfAtPt: the actor at point TfPt: its position, heading, pitch and bank.
TfAtPt                lda       TfPt              the tower sees the point (fswc's twr.asm)
                    sta       >FswTfPt
                    bsr       TfRec
                    pshs      x
                    ldd       PlX,x               X: the origin + the meters << 8
                    ldu       #TfPos
                    ldx       #PlOX
                    bsr       TfMet
                    ldx       ,s
                    ldd       PlZ,x               Z
                    ldu       #TfPosZ
                    ldx       #PlOZ
                    bsr       TfMet
                    puls      x
                    ldu       #TfPos
                    ldd       PlY,x               meters -> 1/256 m: the meters word at bytes 1-2
                    std       5,u
                    clr       7,u
                    clr       4,u
                    tsta
                    bpl       ap1@
                    com       4,u
ap1@                ldd       PlH,x
                    std       TfH
                    lda       PlP,x
                    ldb       PlB,x
                    bra       TfPB

* TfMet: ,u (32-bit) = the 32-bit origin at X + D (signed meters) << 8. D and X clobbered, U kept.
TfMet                 std       1,u
                    clr       3,u
                    clr       ,u
                    tsta
                    bpl       mt1@
                    com       ,u
mt1@                exg       x,u                 ,x (the actor) += ,u (the origin)
                    lbsr      Add32
                    exg       x,u
                    rts

* TfPB: A = pitch (nose up positive), B = bank (the angles' high bytes) -> TfP (FS's: nose down positive), TfB.
TfPB                  pshs      b
                    clrb
                    coma
                    comb
                    addd      #NegCarry
                    std       TfP
                    puls      a
                    clrb
                    std       TfB
                    rts

* TfBlend: on the leg, the heading, pitch and bank from point TfPt's to its NEXT's by TfF = TfT x 256 / TfDur.
TfBlend               ldd       TfT
                    std       TfN+1
                    clr       TfN
                    clr       TfN+3
                    lbsr      TfDiv               TfN = TfT x 256 / TfDur
                    lda       TfN+3
                    tst       TfN+2
                    beq       bl1@
                    lda       #TfFMax
bl1@                sta       TfF
                    lbsr      TfRec
                    pshs      x
                    lbsr      TfNext
                    lbsr      TfRecB
                    tfr       x,y                 Y = the NEXT point
                    puls      x
                    ldd       PlH,y               the heading, the short way round
                    subd      PlH,x
                    bsr       TfLerp
                    addd      PlH,x
                    std       TfH
                    ldb       #PlP                the pitch
                    bsr       TfLerpB
                    pshs      a
                    ldb       #PlB                the bank
                    bsr       TfLerpB
                    tfr       a,b
                    puls      a
                    bra       TfPB

* TfLerpB: A = the angle byte at offset B blended from point X's to point Y's by TfF. X, Y kept.
TfLerpB               pshs      b
                    lda       b,x
                    sta       TfN                 point X's, << 8
                    clr       TfN+1
                    lda       b,y
                    clrb
                    subd      TfN
                    bsr       TfLerp
                    addd      TfN
                    leas      1,s
                    rts

* TfLerp: D = D (signed) x TfF / 256. X, Y kept.
TfLerp                pshs      d
                    lda       1,s                 the low byte x TfF: its high byte
                    ldb       TfF
                    mul
                    sta       1,s
                    lda       ,s                  the high byte (signed) x TfF
                    bpl       lp1@
                    nega
                    ldb       TfF
                    mul
                    coma
                    comb
                    addd      #NegCarry
                    bra       lp2@
lp1@                ldb       TfF
                    mul
lp2@                addb      1,s
                    adca      #CarryOnly
                    leas      2,s
                    rts

* TfGo: the leg from point TfPt to its NEXT begins: the step a tick for X, Y, Z (the meters' difference << 8 /
* DUR).
TfGo                  lbsr      TfRec
                    ldd       PlDur,x             the plan's ticks (5 a second) x 12: 60 a second
                    lslb
                    rola
                    lslb
                    rola
                    std       TfDur
                    lslb
                    rola
                    addd      TfDur
                    std       TfDur
                    pshs      x
                    lbsr      TfNext
                    lbsr      TfRecB
                    tfr       x,y                 Y = the NEXT point
                    puls      x
                    ldb       #PlX
                    ldu       #TfVel
                    bsr       TfStep
                    ldb       #PlY
                    ldu       #TfVelY
                    bsr       TfStep
                    ldb       #PlZ
                    ldu       #TfVelZ
                    bsr       TfStep
                    lda       #TfOnLeg
                    sta       TfLeg
                    ldd       #ClockZero
                    std       TfT
                    rts

* TfStep: ,u (32-bit) = (the meters word at offset B of point Y - point X's) << 8 / TfDur. X, Y, U kept.
TfStep                pshs      x,y
                    leax      b,x                 the field in each point
                    leay      b,y
                    ldd       ,y
                    subd      ,x
                    puls      x,y
                    std       TfN+1
                    clr       TfN+3
                    clr       TfN
                    tsta
                    bpl       st1@
                    com       TfN
st1@                bsr       TfDiv
                    ldd       TfN
                    std       ,u
                    ldd       TfN+2
                    std       2,u
                    rts

* TfDiv: TfN (32-bit signed) / TfDur (16-bit, at least 1) -> TfN, toward zero. X, Y kept.
TfDiv               pshs      x
                    clr       TfSgn
                    tst       TfN
                    bpl       dv1@
                    ldx       #TfN
                    lbsr      TfNeg32
                    com       TfSgn
dv1@                clr       TfRem
                    ldd       #RemStart
                    std       TfRem+1
                    lda       #TfDivBits
                    sta       TfCnt
dv2@                lsl       TfN+3
                    rol       TfN+2
                    rol       TfN+1
                    rol       TfN
                    rol       TfRem+2
                    rol       TfRem+1
                    rol       TfRem
                    tst       TfRem
                    bne       dv3@
                    ldd       TfRem+1
                    cmpd      TfDur
                    blo       dv4@
dv3@                ldd       TfRem+1
                    subd      TfDur
                    std       TfRem+1
                    lda       TfRem
                    sbca      #CarryOnly
                    sta       TfRem
                    inc       TfN+3
dv4@                dec       TfCnt
                    bne       dv2@
                    tst       TfSgn
                    beq       dv9@
                    ldx       #TfN
                    lbsr      TfNeg32
dv9@                puls      x,pc

* TfNeg32: the 32-bit value at X negated. Add32: ,x += ,u. Sub32: ,x -= ,u. D clobbered, X and U kept.
TfNeg32               ldd       2,x
                    eora      #ComplementBits
                    eorb      #ComplementBits
                    addd      #NegCarry
                    std       2,x
                    ldd       ,x
                    eora      #ComplementBits
                    eorb      #ComplementBits
                    adcb      #CarryOnly
                    adca      #CarryOnly
                    std       ,x
                    rts
* TfInBox: carry set when the user's aircraft (<$00 X, <$04 Y, <$08 Z) is in runway box B and under its top:
* within 128 map units of its center, its meters words in the box's ranges.
TfInBox               lda       #PlBoxRec
                    mul
                    ldx       #PlBox
                    leax      d,x
                    ldd       <vPosX
                    subd      10,x
                    cmpd      #TfBoxReach
                    bge       ib8@
                    cmpd      #TfBoxReachNeg
                    blt       ib8@
                    ldd       <vPosZ
                    subd      12,x
                    cmpd      #TfBoxReach
                    bge       ib8@
                    cmpd      #TfBoxReachNeg
                    blt       ib8@
                    ldd       <vPosX+1
                    cmpd      ,x
                    blo       ib8@
                    cmpd      2,x
                    bhi       ib8@
                    ldd       <vPosZ+1
                    cmpd      4,x
                    blo       ib8@
                    cmpd      6,x
                    bhi       ib8@
                    ldd       <vAlt+1
                    cmpd      8,x
                    bhs       ib8@
                    orcc      #Carry
                    rts
ib8@                andcc     #^Carry
                    rts

* TfDraw: the actor in this frame's view.
TfDraw              lda       #TfFar
                    sta       TfDiag
                    lda       TfMode
                    cmpa      #TfModeSpot
                    beq       dw1@
                    ldx       #vPosX              the forward view: FS's eye and matrix
                    ldu       #vViewM
                    bra       dw2@
dw1@                ldx       #SpEye             the spot view: fsx's
                    ldu       #SpM
dw2@                stx       TfEye
                    stu       TfC
                    ldx       #TfPos
                    lbsr      TfTrans             TfD, TfT3 for the actor
                    bcc       dw6@
                    sta       TfDiag
dw9@                rts
dw6@                ldd       TfH                 Cv: BuildViewMatrix's rotation for the heading and pitch, unscaled
                    jsr       >FsSin16
                    std       TfSh
                    ldd       TfH
                    jsr       >FsCos16
                    std       TfCh
                    ldd       TfP
                    jsr       >FsSin16
                    std       TfSp
                    ldd       TfP
                    jsr       >FsCos16
                    std       TfCp
                    ldd       TfCh                x: cos h, sin p sin h, sin h cos p
                    std       TfCv
                    ldd       TfSp
                    ldx       TfSh
                    lbsr      MqXY
                    std       TfCv+2
                    ldd       TfSh
                    ldx       TfCp
                    lbsr      MqXY
                    std       TfCv+4
                    ldd       #Q15Zero            y: 0, cos p, -sin p
                    std       TfCv+6
                    ldd       TfCp
                    std       TfCv+8
                    ldd       TfSp
                    lbsr      TfNegD
                    std       TfCv+10
                    ldd       TfSh                z: -sin h, sin p cos h, cos h cos p
                    lbsr      TfNegD
                    std       TfCv+12
                    ldd       TfSp
                    ldx       TfCh
                    lbsr      MqXY
                    std       TfCv+14
                    ldd       TfCh
                    ldx       TfCp
                    lbsr      MqXY
                    std       TfCv+16
                    ldd       TfB                 the bank: the model's x and y columns rolled about z (right
                    beq       rl9@                wing down positive): x' = cb x - sb y, y' = sb x + cb y
                    jsr       >FsSin16
                    std       TfAcc
                    ldd       TfB
                    jsr       >FsCos16
                    std       TfAcc+2
                    ldu       #TfCv
rl1@                pshs      u
                    ldd       ,u
                    ldx       TfAcc+2
                    lbsr      MqXY                cb x
                    std       TfAcc+4
                    ldu       ,s
                    ldd       2,u
                    ldx       TfAcc
                    lbsr      MqXY                sb y
                    pshs      d
                    ldd       TfAcc+4
                    subd      ,s++
                    pshs      d                   x'
                    ldu       2,s
                    ldd       ,u
                    ldx       TfAcc
                    lbsr      MqXY                sb x
                    std       TfAcc+4
                    ldu       2,s
                    ldd       2,u
                    ldx       TfAcc+2
                    lbsr      MqXY                cb y
                    addd      TfAcc+4
                    ldu       2,s
                    std       2,u                 y'
                    puls      d
                    std       ,u                  x'
                    puls      u
                    leau      6,u
                    cmpu      #TfCvEnd
                    blo       rl1@
rl9@                clr       TfI                 M[r][c] = sum over k of C[k][r] Cv[k][c]
dw7@                clr       TfJ
dw7a@               ldd       #SumInit
                    std       TfSum
                    ldx       TfC
                    ldb       TfI
                    lslb
                    abx
                    ldu       #TfCv
                    ldb       TfJ
                    lslb
                    leau      b,u
                    lda       #AxisCount
                    sta       TfK
dw7b@               ldd       ,x
                    std       <vMulA
                    ldd       ,u
                    std       <vMulB
                    jsr       >FswMq
                    addd      TfSum
                    std       TfSum
                    leax      6,x
                    leau      6,u
                    dec       TfK
                    bne       dw7b@
                    ldb       TfI
                    lda       #AxisCount
                    mul
                    addb      TfJ
                    lslb
                    ldx       #TfM
                    abx
                    ldd       TfSum
                    std       ,x
                    inc       TfJ
                    lda       TfJ
                    cmpa      #AxisCount
                    blo       dw7a@
                    inc       TfI
                    lda       TfI
                    cmpa      #AxisCount
                    blo       dw7@
                    lbsr      TfScaleZ            the far actor enlarged: s from the depth's magnitude
                    lda       #TfDrawn
                    sta       TfDiag
                    lbsr      TfPre               the scenery's records, the light and the projection
                    ldx       #TfM                SETMAT, MESH
                    lda       #GpuOpSetMat
                    ldb       #SetMatUnits
                    lbsr      GpUnits
                    ldx       #GpMeshB
                    lda       #GpuOpMesh
                    ldb       #MeshUnits
                    lbsr      GpUnits
                    lbra      TfPuffs             then the smoke trail

* TfScaleZ: TfScale = the SETMAT scale for the depth in TfT3+8: the mesh 2^s times its size past 2^20 (256 m)
* of view depth, s to 7, so a far mesh holds a few dots.
TfScaleZ            clr       TfScale
                    lda       TfT3+8
                    beq       sc2@
                    ldb       #TfScaleTop         2^24 and up (4 km): 4 + the top byte's bit count - 1
sc1@                lsra
                    beq       sc1a@
                    incb
                    bra       sc1@
sc1a@               cmpb      #TfScaleMax
                    bls       sc1b@
                    ldb       #TfScaleMax
sc1b@               stb       TfScale
                    bra       sc3@
sc2@                lda       TfT3+9              2^20 (256 m) and up: the bit count of the byte's high nibble
                    lsra                          (the actor then never drops below about seven dots)
                    lsra
                    lsra
                    lsra
                    beq       sc3@
                    clrb
sc2a@               lsra
                    beq       sc2b@
                    incb
                    bra       sc2a@
sc2b@               stb       TfScale
sc3@                rts

* TfTrans: X -> a position (12 bytes, 1/256 m): TfD = it from the eye (1/64 m), TfT3 = its view translation
* (T = (d . C) >> 7). Carry set when it is not drawable, A = the code (3 out of range, 4 behind the eye).
TfTrans             ldu       #TfD                d = the position (X) - the eye, 1/256 m
                    ldb       #Pos32Size
                    lbsr      CpB
                    ldx       #TfD
                    ldu       TfEye
                    lbsr      Sub32
                    leax      4,x
                    leau      4,u
                    lbsr      Sub32
                    leax      4,x
                    leau      4,u
                    lbsr      Sub32
                    ldx       #TfD                to 1/64 m, within 64 km each way (the arithmetic's range)
                    ldb       #AxisCount
tr3@                asr       ,x
                    ror       1,x
                    ror       2,x
                    ror       3,x
                    asr       ,x
                    ror       1,x
                    ror       2,x
                    ror       3,x
                    lda       ,x
                    beq       tr3a@
                    coma
                    bne       tr9f@
                    lda       1,x
                    cmpa      #TfRangeBot
                    blo       tr9f@
                    bra       tr3b@
tr3a@               lda       1,x
                    cmpa      #TfRangeTop
                    bhs       tr9f@
tr3b@               leax      4,x
                    decb
                    bne       tr3@
                    clr       TfJ                 T_j = (sum over i of d_i C[i][j]) >> 7
tr4@                ldx       #TfAcc
                    ldd       #SumInit
                    std       ,x
                    std       2,x
                    std       4,x
                    ldx       #TfD
                    ldu       TfC
                    ldb       TfJ
                    lslb
                    leau      b,u
                    lda       #AxisCount
                    sta       TfI
tr5@                pshs      x,u
                    lbsr      TfMac
                    puls      x,u
                    leax      4,x
                    leau      6,u
                    dec       TfI
                    bne       tr5@
                    lbsr      TfShr7
                    ldx       #TfT3
                    ldb       TfJ
                    lslb
                    lslb
                    abx
                    ldd       TfAcc+2
                    std       ,x
                    ldd       TfAcc+4
                    std       2,x
                    inc       TfJ
                    lda       TfJ
                    cmpa      #AxisCount
                    blo       tr4@
                    ldd       TfT3+8              behind the eye (or at it): not drawn
                    bmi       tr9b@
                    bne       tr8@
                    ldd       TfT3+10
                    bne       tr8@
tr9f@               lda       #TfFar
                    bra       tr9@
tr9b@               lda       #TfBehind
tr9@                orcc      #Carry
                    rts
tr8@                andcc     #^Carry
                    rts

* TfPuffs: the smoke trail: the actor's last TfTrN positions (one every 2 s, TfTrail), each a puff mesh at the
* view (M = C^T, no turn), four times the actor's magnification so it holds a few dots.
TfPuffs             lda       TfTrN
                    lbeq      pf9@
                    clr       TfK
pf1@                ldb       TfK
                    lda       #Pos32Size
                    mul
                    ldx       #TfTrail
                    leax      d,x
                    lbsr      TfTrans
                    bcs       pf8@
                    clr       TfI                 M = C^T: M[r][c] = C[c][r]
pf2@                clr       TfJ
pf2a@               ldx       TfC                 C[c][r] at C + 6c + 2r
                    ldb       TfJ
                    lda       #AxisCount
                    mul
                    addb      TfI
                    lslb
                    abx
                    ldd       ,x
                    ldx       #TfM                M[r][c] at M + 6r + 2c
                    pshs      d
                    ldb       TfI
                    lda       #AxisCount
                    mul
                    addb      TfJ
                    lslb
                    abx
                    puls      d
                    std       ,x
                    inc       TfJ
                    lda       TfJ
                    cmpa      #AxisCount
                    blo       pf2a@
                    inc       TfI
                    lda       TfI
                    cmpa      #AxisCount
                    blo       pf2@
                    lbsr      TfScaleZ
                    lda       TfScale
                    adda      #PuffScaleAdd
                    cmpa      #PuffScaleMax
                    bls       pf3@
                    lda       #PuffScaleMax
pf3@                sta       TfScale
                    ldx       #TfM
                    lda       #GpuOpSetMat
                    ldb       #SetMatUnits
                    lbsr      GpUnits
                    ldx       #GpMeshS
                    lda       #GpuOpMesh
                    ldb       #MeshUnits
                    lbsr      GpUnits
pf8@                inc       TfK
                    lda       TfK
                    cmpa      TfTrN
                    lblo      pf1@
pf9@                rts

* TfNegD: -D.
TfNegD              coma
                    comb
                    addd      #NegCarry
                    rts

* TfMac: TfAcc (48-bit) += the 32-bit value at X times the 16-bit value at U (unsigned products on the math
* block, the signs kept aside). Registers clobbered.
TfMac                 clr       TfSg
                    ldd       ,u
                    bpl       mc1@
                    lbsr      TfNegD
                    com       TfSg
mc1@                std       TfCabs
                    ldd       ,x
                    std       TfDabs
                    ldd       2,x
                    std       TfDabs+2
                    tst       TfDabs
                    bpl       mc2@
                    ldx       #TfDabs
                    lbsr      TfNeg32
                    com       TfSg
mc2@                ldd       TfDabs+2            the low word's product
                    std       >MATH_MUL_A
                    ldd       TfCabs
                    std       >MATH_MUL_B
                    ldd       >MATH_MUL_P
                    std       TfPr+2
                    ldd       >MATH_MUL_P+2
                    std       TfPr+4
                    ldd       #SumInit
                    std       TfPr
                    ldd       TfDabs              the high word's, 16 bits up
                    std       >MATH_MUL_A
                    ldd       >MATH_MUL_P+2
                    addd      TfPr+2
                    std       TfPr+2
                    ldd       >MATH_MUL_P
                    adcb      TfPr+1
                    adca      TfPr
                    std       TfPr
                    tst       TfSg
                    beq       mc3@
                    ldx       #TfPr
                    lbsr      TfNeg48
mc3@                ldd       TfPr+4
                    addd      TfAcc+4
                    std       TfAcc+4
                    ldd       TfPr+2
                    adcb      TfAcc+3
                    adca      TfAcc+2
                    std       TfAcc+2
                    ldd       TfPr
                    adcb      TfAcc+1
                    adca      TfAcc
                    std       TfAcc
                    rts

* TfNeg48: the 48-bit value at X negated. TfShr7: TfAcc >> 7 (arithmetic).
TfNeg48               ldd       4,x
                    eora      #ComplementBits
                    eorb      #ComplementBits
                    addd      #NegCarry
                    std       4,x
                    ldd       2,x
                    eora      #ComplementBits
                    eorb      #ComplementBits
                    adcb      #CarryOnly
                    adca      #CarryOnly
                    std       2,x
                    ldd       ,x
                    eora      #ComplementBits
                    eorb      #ComplementBits
                    adcb      #CarryOnly
                    adca      #CarryOnly
                    std       ,x
                    rts
TfShr7                ldb       #TfTShift
sh1@                asr       TfAcc
                    ror       TfAcc+1
                    ror       TfAcc+2
                    ror       TfAcc+3
                    ror       TfAcc+4
                    ror       TfAcc+5
                    decb
                    bne       sh1@
                    rts

* BdDraw: O'Hare's buildings and parked jets and the Sears Tower as lit GPU meshes (aircraft/bld2gpu.py) in the
* forward and spot views by daylight. FsBdFlag (1) makes the scenery skip its own boxes (sf_wildbits.py); this
* frame's list ran with last frame's value, so the meshes go when that was 1, and the next frame's is 1 in
* daylight ($013F = 1) outside the map view. FS's matrix carries the view's aspect in its columns (x and z / 4,
* y x 0.4858), which would skew the meshes' normals, so they get C' = C with those undone (a rotation), M = C'^T,
* T from TfTrans with C' (an origin behind the eye still draws: the airport is around it), scale 3 (1/8 m units),
* and their own projection (FY 1312 x 1.9433, NEAR 4 m: the same dots and depth keys as FS's matrix gives) and
* light (a sun fixed to the world, from the southeast and high: L = M sun). Registers clobbered.
BdDraw              clrb
                    lda       TfMode
                    beq       bd0@                the map view: the list's boxes
                    lda       >vLight             dusk and night: the list's boxes with their lit windows
                    cmpa      #LightDay
                    bne       bd0@
                    incb
bd0@                lda       >FsBdFlag+1         the value this frame's list ran with
                    stb       >FsBdFlag+1         the next frame's
                    clr       >FsBdFlag
                    tsta
                    lbeq      bd9@
                    lda       TfMode
                    lbeq      bd9@
                    ldx       #vPosX              the eye and C, as TfDraw's
                    ldu       #vViewM
                    cmpa      #TfModeSpot
                    bne       bd1@
                    ldx       #SpEye
                    ldu       #SpM
bd1@                stx       TfEye
                    lbsr      BdMat
                    lda       #BdScale            scale 3: 1/8 m units
                    sta       TfScale
                    lbra      BdLight
bd9@                rts

* BdMat (BdDraw, GdDraw): U = FS's view matrix C (its columns carrying the view's aspect: x and z / 4, y x 0.4858):
* BdC = C' (a rotation: those undone), TfC = BdC, TfM = M = C'^T. Registers clobbered.
BdMat               ldx       #BdC
                    stx       TfC
                    lda       #AxisCount
                    sta       TfK
bd2@                ldd       ,u                  x times 4
                    aslb
                    rola
                    aslb
                    rola
                    std       ,x
                    ldd       4,u                 z times 4
                    aslb
                    rola
                    aslb
                    rola
                    std       4,x
                    ldd       2,u                 2y + y x $077A (y / 0.4858, as fsx's spot matrix)
                    std       <vMulA
                    aslb                          2y (|y| <= 0.4858)
                    rola
                    pshs      d
                    ldd       #YAspectInvFrac
                    std       <vMulB
                    jsr       >FswMq
                    addd      ,s++
                    bvc       bd2a@
                    ldd       #Q15One             a full Q15 one
                    tst       2,u
                    bpl       bd2a@
                    ldd       #Q15NegOne
bd2a@               std       2,x
                    leau      6,u
                    leax      6,x
                    dec       TfK
                    bne       bd2@
                    ldx       #BdC                M = C'^T
                    ldu       #TfM
                    ldd       ,x
                    std       ,u
                    ldd       6,x
                    std       2,u
                    ldd       12,x
                    std       4,u
                    ldd       2,x
                    std       6,u
                    ldd       8,x
                    std       8,u
                    ldd       14,x
                    std       10,u
                    ldd       4,x
                    std       12,u
                    ldd       10,x
                    std       14,u
                    ldd       16,x
                    std       16,u
                    rts

* BdLight (BdDraw, after BdMat): the light and the projection, then the meshes.
BdLight             ldx       #TfM                the light: L = M sun
                    ldy       #BdLt
bd3@                ldd       #SumInit
                    std       TfSum
                    ldu       #BdSun
                    lda       #AxisCount
                    sta       TfK
bd3a@               ldd       ,x++
                    std       <vMulA
                    ldd       ,u++
                    std       <vMulB
                    jsr       >FswMq
                    addd      TfSum
                    std       TfSum
                    dec       TfK
                    bne       bd3a@
                    ldd       TfSum
                    std       ,y++
                    cmpy      #BdLtDirEnd
                    blo       bd3@
                    lbsr      TfPre               the scenery's records first, then the meshes' light and projection
                    ldx       #BdLt
                    lda       #GpuOpSetLight
                    ldb       #SetLightUnits
                    lbsr      GpUnits
                    ldx       #BdProj             (480 lines: FY and CY doubled, ProjU)
                    lbsr      ProjU
                    ldy       #BdTab
bd4@                ldx       TfEye               within the mesh's range: dx^2 + dz^2 < R^2 (map units;
                    ldd       ,x                  VISIBILITY_KM is a distance, not a box)
                    subd      ,y
                    bpl       bd4a@
                    lbsr      TfNegD
bd4a@               tsta
                    bne       bd8@
                    cmpb      4,y
                    bhs       bd8@
                    tfr       b,a
                    mul
                    pshs      d                   dx^2
                    ldd       8,x
                    subd      2,y
                    bpl       bd4b@
                    lbsr      TfNegD
bd4b@               tsta
                    bne       bd4c@
                    cmpb      4,y
                    bhs       bd4c@
                    tfr       b,a
                    mul
                    addd      ,s                  dx^2 + dz^2 (each under R^2: no carry)
                    std       ,s
                    lda       4,y
                    tfr       a,b
                    mul                           R^2
                    cmpd      ,s++
                    bls       bd8@                R^2 <= dx^2 + dz^2: out of sight
                    bra       bd4d@
bd4c@               leas      2,s
                    bra       bd8@
bd4d@               equ       *
                    ldd       ,y                  the origin: the map corner
                    std       BdPos
                    ldd       2,y
                    std       BdPos+8
                    pshs      y
                    ldx       #BdPos
                    lbsr      TfTrans             T (TfT3) with C'
                    bcc       bd5@
                    cmpa      #TfBehind           behind the eye: drawn all the same
                    bne       bd7@
bd5@                ldx       #TfM                SETMAT, MESH
                    lda       #GpuOpSetMat
                    ldb       #SetMatUnits
                    lbsr      GpUnits
                    ldx       ,s
                    leax      5,x
                    lda       #GpuOpMesh
                    ldb       #MeshUnits
                    lbsr      GpUnits
bd7@                puls      y
bd8@                leay      12,y
                    cmpy      #BdTabE
                    blo       bd4@
                    lbsr      CbRun               the clouds (fs2/fscl), in the meshes' light and projection
bd9@                rts

* The clouds' block (fscl.asm, fs2/fscl): WbAScrn's first block, before the panel's (ExitAll frees both), mapped at
* $4000 in place of the scenery window only while its code runs: the SceneEngine has its own copy of the list, and
* nothing else reads the window then. CbLoad (GpInit): the window's block from this process's DAT image, the file
* read into the clouds' block, its ClInit run; CbOn 1 when it went in. CbRun (BdDraw): its ClRun. CbIn: the
* clouds' block at $4000 (carry: not there). CbOut: the window's block back. Registers clobbered.
CbLoad              clr       CbOn
                    tst       GpOn                no meshes: no clouds
                    beq       cl9@
                    swi2
                    fcb       F$ID                A = this process
                    ldx       #AcFile             its descriptor: AcFile's room is free once GpLoad is done
                    swi2
                    fcb       F$GPrDsc
                    bcs       cl9@
                    lda       AcFile+P$DATImg+5   slot 2's block: the scenery window's
                    sta       CbWin
                    bsr       CbIn
                    bcs       CbOut
                    lda       #READ.
                    ldx       #CbName
                    swi2
                    fcb       I$Open
                    bcs       CbOut
                    pshs      a
                    ldx       #FsclBase
                    ldy       #FsclMax
                    swi2
                    fcb       I$Read
                    puls      a
                    pshs      cc
                    swi2
                    fcb       I$Close
                    puls      cc
                    bcs       CbOut
                    jsr       >FsclInit           ClInit
                    inc       CbOn
                    bra       CbOut
cl9@                rts
CbRun               tst       CbOn
                    beq       cl9@
                    bsr       CbIn
                    bcs       CbOut
                    jsr       >FsclRun            ClRun
CbOut               ldu       #FsclBase
                    ldb       #CbBlocks
                    swi2
                    fcb       F$ClrBlk
                    clra
                    ldb       CbWin
                    tfr       d,x
                    ldb       #CbBlocks
                    swi2
                    fcb       F$MapBlk
                    rts
CbIn                ldu       #FsclBase
                    ldb       #CbBlocks
                    swi2
                    fcb       F$ClrBlk
                    clra
                    ldb       >WbScrBlks+1        WbAScrn's first block: the clouds'
                    tfr       d,x
                    ldb       #CbBlocks
                    swi2
                    fcb       F$MapBlk
                    bcs       ci9@
                    cmpu      #FsclBase
                    beq       ci9@
                    ldb       #CbBlocks           elsewhere: off again
                    swi2
                    fcb       F$ClrBlk
                    orcc      #Carry
ci9@                rts
CbName              fcc       "fscl"
                    fcb       C$CR
CbWin               fcb       0                   the scenery window's block
CbOn                fcb       0                   1: the clouds' block is in
BdSun               fdb       13526,23832,-16747  toward the sun (east, up, north; Q15, 0.98 long): southeast, 47 deg up
BdProj              fcb       $14,$00,$09,$F6,$14,$00,(ViewCY*16)/256,(ViewCY*16)&255,$00,$01,$00,$00,$04,$00  SETPROJ: FX 5120, FY 2550, CX 5120, CY ViewCY x 16 (fs_wb.d), NEAR 65536, the clip at NEAR >> 4 (rc27)
BdTab               fdb       194,859             O'Hare: the origin's map corner, within VISIBILITY_KM (fs_wb.d) each way
                    fcb       VisUnits
                    fdb       GpOF,GpNfO,GpOV
                    fcb       0
                    fdb       269,811             the Sears Tower: the ST's map corner, within VISIBILITY_KM each way
                    fcb       VisUnits
                    fdb       GpXF,GpNfX,GpXV
                    fcb       0
BdTabE              equ       *

* GdDraw (FsxGround: fsw's GdCall, from HzGpu once the sky and ground split went to the GPU): the textured ground,
* fscl's GdRun (fscl.asm), the clouds' block at $4000 meanwhile (CbIn, CbOut, as CbRun). Registers clobbered.
GdDraw              tst       CbOn
                    beq       gd9@
                    lbsr      CbIn
                    bcs       gd8@
                    jsr       >FsclGdRun          GdRun
gd8@                lbra      CbOut
gd9@                rts

* TfPre: as fsx's GpDraw before the model: the scenery's records to the GPU first (it draws in arrival order), then
* the light and the projection again (vette leaves its own in the GPU), into GpQ (GpFlush waits for the
* SceneEngine's list to end before them).
TfPre                 jsr       >FswFeed
                    ldx       #GpSetup
                    lda       #GpuOpSetLight
                    ldb       #SetLightUnits
                    lbsr      GpUnits
                    ldx       #GpSetupProj        (480 lines: FY and CY doubled, ProjU)
                    lbra      ProjU

                    use       fst_plan.asm

