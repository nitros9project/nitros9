* fs_flight.asm - FS (Flight Simulator II), part of the port: fixed-point and trig math, view matrix, course plotter, packed text printer, wind, daylight,
* slew mode, aerodynamics and flight physics ($3263-$52A4)
* Assembled by fs.asm (use); absolute self-references are label+ModBase.

* MulSigned8: signed 8x8 multiply: A * B -> D (signed 16-bit)
MulSigned8               tsta
                    bpl       SMul8APositive
                    nega
                    tstb
                    bpl       SMul8DoMulNeg
                    negb
* SMul8DoMulPos: signed 8x8 multiply (MulSigned8): operands made positive, multiply for a positive product
SMul8DoMulPos               mul
                    bra       SMul8Done
* SMul8APositive: signed 8x8 multiply: A was positive, check sign of B
SMul8APositive               tstb
                    bpl       SMul8DoMulPos
                    negb
* SMul8DoMulNeg: signed 8x8 multiply: signs differ, multiply and negate the product
SMul8DoMulNeg               mul
                    coma
                    comb
                    addd      #NegCarry
* SMul8Done: signed 8x8 multiply: return D = A*B
SMul8Done               rts
* MulQ15Store: D * <$AF (Q15 signed fraction multiply), result stored back to <$AF and returned in D
MulQ15Store               std       <vMulB
                    jsr       >MulQ15Vars+ModBase
                    std       <vMulA
                    rts
* MulQ15: signed Q15 multiply: D * <$AF -> D (rounded (a*b)>>15); D also left in <$B1
MulQ15               std       <vMulB
* MulQ15Vars: signed Q15 multiply of <$AF * <$B1 -> D (rounded (a*b)>>15); operands are made absolute in place
* WildBits: the magnitudes multiplied on the math block (MATH_MUL_P, exact). FS rounded twice, the product's
* bits 31-8 on bit 7, then shifted left once and rounded on bit 6: that is (P + $4080) >> 15, bit for bit.
MulQ15Vars               ldd       <vMulA
                    bpl       MulQ15APos
                    nega
                    negb
                    sbca      #NegBorrow
                    std       <vMulA
                    std       >MATH_MUL_A
                    ldd       <vMulB
                    bpl       MulQ15NegResult
                    nega
                    negb
                    sbca      #NegBorrow
                    std       <vMulB
                    bra       MulQ15PosResult
* MulQ15APos: Q15 multiply: first operand positive, test second
MulQ15APos               std       >MATH_MUL_A
                    ldd       <vMulB
                    bpl       MulQ15PosResult
                    nega
                    negb
                    sbca      #NegBorrow
                    std       <vMulB
* MulQ15NegResult: Q15 multiply: operands of different sign, compute product then negate
MulQ15NegResult               std       >MATH_MUL_B
                    ldd       >MATH_MUL_P+2
                    addd      #Q15Round
                    sta       <vMulQ15Lo          bit 7: the result's bit 0
                    ldd       >MATH_MUL_P         (loads keep C)
                    adcb      #AdcCarryOnly
                    adca      #AdcCarryOnly
                    lsl       <vMulQ15Lo
                    rolb
                    rola
                    nega
                    negb
                    sbca      #NegBorrow
                    rts
* MulQ15PosResult: Q15 multiply: both operands positive (or both negated), compute positive product
MulQ15PosResult               std       >MATH_MUL_B
                    ldd       >MATH_MUL_P+2
                    addd      #Q15Round
                    sta       <vMulQ15Lo          bit 7: the result's bit 0
                    ldd       >MATH_MUL_P         (loads keep C)
                    adcb      #AdcCarryOnly
                    adca      #AdcCarryOnly
                    lsl       <vMulQ15Lo
                    rolb
                    rola
* MulQ15Done: Q15 multiply: return result in D
MulQ15Done               rts
* (the software multiply's spare bytes: the routines after keep their addresses)
                    zmb       69
* MulU16x16: unsigned 16x16 multiply <$AF * <$B1 -> 32-bit product in <$B3..<$B6
* WildBits: on the math block; D returns the high word as before
MulU16x16               ldd       <vMulA
                    std       >MATH_MUL_A
                    ldd       <vMulB
                    std       >MATH_MUL_B
                    ldd       >MATH_MUL_P+2
                    std       <vMulProd+2
                    ldd       >MATH_MUL_P
                    std       <vMulProd
                    rts
* MulU16MidMul: MulU16Mid's multiply, D = <$B1 (before MulU16Mid so that it keeps its address)
MulU16MidMul               std       >MATH_MUL_B
                    ldd       <vMulA
                    std       >MATH_MUL_A
                    ldd       >MATH_MUL_P+2
                    std       <vMulProd+2
                    ldd       >MATH_MUL_P
                    std       <vMulProd
                    ldd       >MATH_MUL_P+1
                    rts
* MulU16Mid: unsigned multiply D * <$AF, returns the middle 16 bits (product>>8, <$B4) in D
MulU16Mid               std       <vMulB
                    bra       MulU16MidMul
* (the software multiply's spare bytes)
                    zmb       4
* DivQ15Signed: signed fractional divide: D (stored in <$AF) / <$B1 -> Q15 quotient in D and <$AF, saturates at $7FFF
DivQ15Signed               std       <vDivQuot
                    bpl       DivQ15DividendPos
                    coma
                    comb
                    addd      #NegCarry
                    std       <vDivQuot
                    ldd       <vDivisor
                    bpl       DivQ15SignNeg
                    coma
                    comb
                    addd      #NegCarry
                    std       <vDivisor
* DivQ15SignPos: signed divide: result will be positive ($9A=0)
DivQ15SignPos               clra
                    sta       <vDivSign
                    bra       DivQ15Start
* DivQ15DividendPos: signed divide: dividend positive, test divisor sign
DivQ15DividendPos               ldd       <vDivisor
                    bpl       DivQ15SignPos
                    coma
                    comb
                    addd      #NegCarry
                    std       <vDivisor
* DivQ15SignNeg: signed divide: result will be negative ($9A=$FF)
DivQ15SignNeg               lda       #DivSignNeg
                    sta       <vDivSign
* DivQ15Start: signed divide: set up 15-bit restoring division loop
DivQ15Start               lda       #Q15FracBits
                    sta       <vDivQ15Bits
                    ldd       <vDivQuot
* DivQ15Loop: signed divide: trial subtract of divisor
DivQ15Loop               cmpd      <vDivisor
                    bmi       DivQ15ShiftBit
                    subd      <vDivisor
* DivQ15ShiftBit: signed divide: shift quotient bit into <$AF and remainder left
DivQ15ShiftBit               rol       <vDivQuot+1
                    rol       <vDivQuot
                    aslb
                    rola
                    dec       <vDivQ15Bits
                    bne       DivQ15Loop
                    ldd       <vDivQuot
                    coma
                    comb
                    aslb
                    rola
                    bpl       DivQ15ApplySign
                    ldd       #Q15One
* DivQ15ApplySign: signed divide: negate quotient if result sign is negative
DivQ15ApplySign               tst       <vDivSign
                    bpl       DivQ15Store
                    coma
                    comb
                    addd      #NegCarry
* DivQ15Store: signed divide: store quotient in <$AF and return
DivQ15Store               std       <vDivQuot
                    rts
* Cos8: cosine of angle in A (256 units per turn, B cleared) -> D signed Q15
Cos8               clrb
                    bra       Cos16
* Sin8: sine of angle in A (256 units per turn, B cleared) -> D signed Q15
Sin8               clrb
                    bra       Sin16
* (CosHalfStep, SinHalfStep, gone: nothing called them)
                    zmb       8
* Sin16: sine of 16-bit angle D (A = angle, B = fraction for interpolation) -> D Q15 (cos of angle-90)
Sin16               suba      #Angle8Quarter
* Cos16: cosine of 16-bit angle D with linear interpolation from TblCosQuarter -> D Q15
Cos16               ldx       #TblCosQuarter+ModBase
                    tsta
                    bmi       Cos16NegAngle
* Cos16PosAngle: cosine: angle folded to 0..$7F; beyond 90 degrees use -cos(180-angle)
Cos16PosAngle               cmpa      #Angle8Quarter
                    bmi       CosQuadrantLookup
                    subd      #Ang180W
                    coma
                    comb
                    addd      #NegCarry
                    bsr       CosQuadrantLookup
                    coma
                    comb
                    addd      #NegCarry
                    rts
* Cos16NegAngle: cosine: negative angle, negate it (cos is even)
Cos16NegAngle               coma
                    comb
                    addd      #NegCarry
                    bpl       Cos16PosAngle
                    ldd       #Q15One
                    bra       Cos16PosAngle
* CosQuadrantLookup: cosine for first quadrant: exact table entry or interpolated
CosQuadrantLookup               tstb
                    beq       CosQuadExact
* WildBits: every fraction interpolated (FS kept bit 7 for its half step only: b & $7F made a whole table step
* in half the angle, a +-0.7 degree sawtooth once Sin16/Cos16 took full 16-bit angles)
                    lbne      CosQuadInterp
                    asla
                    bmi       CosQuadEndHalf
                    leax      a,x
                    ldd       ,x++
                    addd      ,x
                    lsra
                    rorb
                    rts
* CosQuadEndHalf: cosine lookup: half step past 90 degrees, return $FE6E
CosQuadEndHalf               ldd       #CosPast90Half
                    rts
* CosQuadExact: cosine lookup: no fraction, return table entry
CosQuadExact               asla
                    bmi       CosQuadZero
                    ldd       a,x
                    rts
* CosQuadZero: cosine lookup: exactly 90 degrees, return 0
CosQuadZero               ldd       #Cos90Deg
                    rts
* CosQuadInterp: cosine lookup: interpolate between entries (fraction * (next-cur) + cur)
* WildBits: the Q15 multiply on the math block, as MulQ15Vars (the fraction is never negative, so the delta's
* sign is the product's)
CosQuadInterp               pshs      a,b
                    puls      b
                    aslb
                    abx
                    puls      a
                    clrb
                    lsra                          WildBits: the fraction b / 256 as Q15 (b << 7)
                    rorb
                    std       <vMulB
                    std       >MATH_MUL_B
                    ldd       2,x
                    subd      ,x
                    bpl       CosInterpDeltaPos
                    nega
                    negb
                    sbca      #NegBorrow
                    std       <vMulA
                    std       >MATH_MUL_A
                    ldd       >MATH_MUL_P+2
                    addd      #Q15Round
                    sta       <vMulQ15Lo          bit 7: the result's bit 0
                    ldd       >MATH_MUL_P         (loads keep C)
                    adcb      #AdcCarryOnly
                    adca      #AdcCarryOnly
                    lsl       <vMulQ15Lo
                    rolb
                    rola
                    nega
                    negb
                    sbca      #NegBorrow
                    addd      ,x
                    rts
* CosInterpDeltaPos: cosine interpolation multiply: table delta positive
CosInterpDeltaPos               std       <vMulA
                    std       >MATH_MUL_A
                    ldd       >MATH_MUL_P+2
                    addd      #Q15Round
                    sta       <vMulQ15Lo          bit 7: the result's bit 0
                    ldd       >MATH_MUL_P         (loads keep C)
                    adcb      #AdcCarryOnly
                    adca      #AdcCarryOnly
                    lsl       <vMulQ15Lo
                    rolb
                    rola
* CosInterpAddBase: cosine interpolation: add the base table entry and return
CosInterpAddBase               addd      ,x
                    rts
* (the software multiply's spare bytes: the table keeps its address)
                    zmb       94
* TblCosQuarter: cosine table, 65+1 words Q15: cos(0..90 degrees) in 64 steps ($7FFF down to 0, then $FCDC)
TblCosQuarter               fcb       $7F,$FF,$7F,$F5,$7F,$D8,$7F,$A6
                    fcb       $7F,$61,$7F,$09,$7E,$9C,$7E,$1D
                    fcb       $7D,$89,$7C,$E3
                    fcc       /|){\z|y/
                    fcb       $89,$78,$84
                    fcc       /wkvAu/
                    fcb       $04,$73,$B5
                    fcs       /rTpb/
                    fcs       /o^mI/
                    fcs       /l#jmh&/
                    fcb       $66,$CF,$64,$E8,$62,$F1,$60,$EB
                    fcb       $5E,$D7,$5C,$B3,$5A,$82
                    fcs       /XBUu/
                    fcb       $53,$9B
                    fcs       /Q3N?/
                    fcs       /L?I4/
                    fcb       $47,$1C
                    fcs       /DzAN/
                    fcb       $3F,$17
                    fcc       /<V9/
                    fcb       $8C,$36,$BA,$33,$DF,$30,$FB,$2E
                    fcb       $11,$2B,$1F
                    fcc       /(&%("#/
                    fcb       $1F,$1A,$1C,$0B,$18,$F9,$15,$E2
                    fcb       $12,$C8,$0F,$AB,$0C,$8C,$09,$6B
                    fcb       $06,$48,$03,$24,$00,$00,$FC,$DC
* InterpBySpeed: interpolate a 16-entry byte table at X indexed by airspeed $07BB (high nibble index, low nibble fraction) -> <$AF/D
InterpBySpeed               lda       >vAirspeed
                    tfr       a,b
                    anda      #SpdCurveFracMask
                    asla
                    asla
                    asla
                    pshs      a
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    abx
                    lda       ,x+
                    sta       <vInterpBase
                    lda       ,x
                    suba      <vInterpBase
                    puls      b
                    jsr       >MulSigned8+ModBase
                    aslb
                    rola
                    adda      <vInterpBase
                    std       <vMulA
                    rts
                    fcb       $DC,$B8,$DD,$AF,$DC,$BC,$DD,$B1
                    fcb       $DC,$BA,$BD,$D5,$8B,$DD,$BE,$39
                    fcb       $DC,$C1,$DD,$AF,$DC,$C5,$DD,$B1
                    fcb       $DC,$C3,$8D,$12,$DD,$C7,$39,$EC
                    fcb       $01,$DD,$AF,$EC,$05,$DD,$B1,$EC
                    fcb       $03,$8D,$03,$ED,$07,$39,$8E,$D6
* WildBits: screen y = 63 - table (view rows 1-125)
                    fcb       $BC,$8D,$15,$4D,$2A,$01,$4C,$80
                    fcb       $3F,$40,$97,$9A,$8E,$D6,$3B,$DC
* WildBits: screen x = 128 + table (x 1-255)
                    fcb       $AF,$8D,$05,$8B,$80,$D6,$9A,$39
                    fcb       $0F,$90,$DE,$B1,$27,$14,$10,$93
                    fcb       $B1,$26,$07,$86,$7F,$0F,$92,$7E
                    fcb       $D6,$2E,$34,$06,$D3,$B1,$26,$0A
                    fcb       $35,$06,$CC,$7F,$FF,$D7,$92,$7E
                    fcb       $D6,$2E,$35,$06,$97,$92,$2A,$05
                    fcb       $43,$53,$C3,$00,$01,$58,$49,$10
                    fcb       $93,$B1,$2B,$02,$93,$B1,$09,$90
                    fcb       $58,$49,$10,$93,$B1,$2B,$02,$93
                    fcb       $B1,$09,$90,$58,$49,$10,$93,$B1
                    fcb       $2B,$02,$93,$B1,$09,$90,$58,$49
                    fcb       $10,$93,$B1,$2B,$02,$93,$B1,$09
                    fcb       $90,$58,$49,$10,$93,$B1,$2B,$02
                    fcb       $93,$B1,$09,$90,$58,$49,$10,$93
                    fcb       $B1,$2B,$02,$93,$B1,$09,$90,$58
                    fcb       $49,$10,$93,$B1,$2B,$02,$93,$B1
                    fcb       $09,$90,$58,$49,$10,$93,$B1,$2B
                    fcb       $02,$93,$B1,$09,$90,$96,$90
                    fcc       /CDM*/
                    fcb       $02,$86,$7F,$A6,$86,$D6,$92,$2A
* WildBits: projection tables: x = 128*X/Z (0-127), y = 63*Y/Z (0-62)
                    fcb       $01,$43,$39,$00,$01,$02,$03,$04
                    fcb       $05,$06,$07,$08,$09,$0A,$0B,$0C
                    fcb       $0D,$0E,$0F,$10,$11,$12,$13,$14
                    fcb       $15,$16,$17,$18,$19,$1A,$1B,$1C
                    fcb       $1D,$1E,$1F,$20,$21,$22,$23,$24
                    fcb       $25,$26,$27,$28,$29,$2A,$2B,$2C
                    fcb       $2D,$2E,$2F,$30,$31,$32,$33,$34
                    fcb       $35,$36,$37,$38,$39,$3A,$3B,$3C
                    fcb       $3D,$3E,$3F,$40,$41,$42,$43,$44
                    fcb       $45,$46,$47,$48,$49,$4A,$4B,$4C
                    fcb       $4D,$4E,$4F,$50,$51,$52,$53,$54
                    fcb       $55,$56,$57,$58,$59,$5A,$5B,$5C
                    fcb       $5D,$5E,$5F,$60,$61,$62,$63,$64
                    fcb       $65,$66,$67,$68,$69,$6A,$6B,$6C
                    fcb       $6D,$6E,$6F,$70,$71,$72,$73,$74
                    fcb       $75,$76,$77,$78,$79,$7A,$7B,$7C
                    fcb       $7D,$7E,$7F,$7F,$00,$00,$00,$01
                    fcb       $01,$02,$02,$03,$03,$04,$04,$05
                    fcb       $05,$06,$06,$07,$07,$08,$08,$09
                    fcb       $09,$0A,$0A,$0B,$0B,$0C,$0C,$0D
                    fcb       $0D,$0E,$0E,$0F,$0F,$10,$10,$11
                    fcb       $11,$12,$12,$13,$13,$14,$14,$15
                    fcb       $15,$16,$16,$17,$17,$18,$18,$19
                    fcb       $19,$1A,$1A,$1B,$1B,$1C,$1C,$1D
                    fcb       $1D,$1E,$1E,$1F,$1F,$1F,$20,$20
                    fcb       $21,$21,$22,$22,$23,$23,$24,$24
                    fcb       $25,$25,$26,$26,$27,$27,$28,$28
                    fcb       $29,$29,$2A,$2A,$2B,$2B,$2C,$2C
                    fcb       $2D,$2D,$2E,$2E,$2F,$2F,$30,$30
                    fcb       $31,$31,$32,$32,$33,$33,$34,$34
                    fcb       $35,$35,$36,$36,$37,$37,$38,$38
                    fcb       $39,$39,$3A,$3A,$3B,$3B,$3C,$3C
                    fcb       $3D,$3D,$3E,$3E
* BuildViewMatrix: build the 3x3 view rotation matrix (<$68-<$78) from aircraft pitch/bank/heading (<$12/<$14/<$16) and view direction $0839; $0139 set gives a straight-down view (probably radar)
BuildViewMatrix               lda       >vMapView
                    beq       BuildViewMatrixNormal
                    ldd       #Angle16Quarter
                    std       <vViewPitch
                    ldd       #ViewHdgZero
                    std       <vViewHdg
                    ldd       <vHdg
                    coma
                    comb
                    addd      #NegCarry
                    std       <vViewBank
                    jmp       >BuildViewMatrixFold+ModBase
* BuildViewMatrixNormal: view matrix: not the straight-down view; $0839 bit 7 selects a pitched-up-90 view (probably)
BuildViewMatrixNormal               lda       >vViewDir
                    bpl       BuildViewMatrixViewDir
                    ldd       <vHdg
                    coma
                    comb
                    addd      #NegCarry
                    std       <vViewBank
                    ldd       #ViewHdgZero
                    std       <vViewHdg
                    ldd       <vPitch
                    adda      #Angle8Quarter
                    std       <vViewPitch
                    jmp       >BuildViewMatrixFold+ModBase
* BuildViewMatrixViewDir: view matrix: rotate the attitude by the view direction (low nibble of $0839 * 16)
BuildViewMatrixViewDir               asla
                    asla
                    asla
                    asla
                    sta       <vVmViewDir
                    ldd       <vBank
                    std       <vBankFolded
                    ldd       <vPitch
                    std       <vPitchFolded
                    lda       <vHdg
                    sta       <vVmHdg
                    lda       <vBankFolded
                    adda      #Angle8Quarter
                    bpl       BuildViewMatrixRotate
                    ldd       #Ang180W
                    subd      <vPitchFolded
                    std       <vPitchFolded
                    lda       <vBankFolded
                    eora      #Angle8Half
                    sta       <vBankFolded
                    lda       <vVmHdg
                    eora      #Angle8Half
                    sta       <vVmHdg
* BuildViewMatrixRotate: view matrix: combine view direction with pitch/bank to get view angles <$18/<$1A/<$1C
BuildViewMatrixRotate               lda       <vVmHdg
                    adda      <vVmViewDir
                    sta       <vViewHdg
* WildBits: <$1D, the heading's low byte, comes from fsw (Matrix sets it before calling here)
                    lda       <vVmViewDir
                    jsr       >Cos8+ModBase
                    std       <vViewDirCos
                    lda       <vVmViewDir
                    jsr       >Sin8+ModBase
                    std       <vViewDirSin
                    ldd       <vBankFolded
                    std       <vMulA
                    ldd       <vViewDirSin
                    std       <vMulB
                    jsr       >MulQ15Vars+ModBase
                    std       <vViewPitch
                    ldd       <vPitchFolded
                    std       <vMulA
                    ldd       <vViewDirCos
                    std       <vMulB
                    jsr       >MulQ15Vars+ModBase
                    subd      <vViewPitch
                    std       <vViewPitch
                    ldd       <vBankFolded
                    std       <vMulA
                    ldd       <vViewDirCos
                    std       <vMulB
                    jsr       >MulQ15Vars+ModBase
                    std       <vViewBank
                    ldd       <vPitchFolded
                    std       <vMulA
                    ldd       <vViewDirSin
                    std       <vMulB
                    jsr       >MulQ15Vars+ModBase
                    addd      <vViewBank
                    std       <vViewBank
* BuildViewMatrixFold: view matrix: fold view pitch past vertical (flip bank and heading)
BuildViewMatrixFold               lda       <vViewPitch
                    cmpa      #Angle8NegQuarter
                    bpl       BuildViewMatrixTrig
                    ldd       #Ang180W
                    subd      <vViewPitch
                    std       <vViewPitch
                    lda       <vViewBank
                    eora      #Angle8Half
                    sta       <vViewBank
                    lda       <vViewHdg
                    eora      #Angle8Half
                    sta       <vViewHdg
* BuildViewMatrixTrig: view matrix: sines/cosines of the view angles and the matrix element products
* WildBits: interpolated over the whole angle (Sin16/Cos16; FS rounded each angle to half a table step, 0.7 degrees)
BuildViewMatrixTrig               ldd       <vViewPitch
                    jsr       >Sin16+ModBase
                    std       <vSinViewPitch
                    ldd       <vViewBank
                    jsr       >Sin16+ModBase
                    std       <vSinViewBank
                    ldd       <vViewHdg
                    jsr       >Sin16+ModBase
                    std       <vSinViewHdg
                    ldd       <vViewPitch
                    jsr       >Cos16+ModBase
                    std       <vVmCosP
                    ldd       <vViewBank
                    jsr       >Cos16+ModBase
                    std       <vCosViewBank
                    ldd       <vViewHdg
                    jsr       >Cos16+ModBase
                    std       <vCosViewHdg
                    ldd       <vCosViewHdg
                    std       <vMulA
                    ldd       <vCosViewBank
                    std       <vMulB
                    jsr       >MulQ15Vars+ModBase
                    std       <vCosHdgCosBank
                    ldd       <vSinViewHdg
                    std       <vMulA
                    ldd       <vSinViewBank
                    std       <vMulB
                    jsr       >MulQ15Vars+ModBase
                    std       <vVmSinHSinB
                    ldd       <vCosViewHdg
                    std       <vMulA
                    ldd       <vSinViewBank
                    std       <vMulB
                    jsr       >MulQ15Vars+ModBase
                    std       <vCosHdgSinBank
                    ldd       <vSinViewHdg
                    std       <vMulA
                    ldd       <vCosViewBank
                    std       <vMulB
                    jsr       >MulQ15Vars+ModBase
                    std       <vSinHdgCosBank
                    ldd       <vSinViewPitch
                    std       <vMulA
                    ldd       <vVmSinHSinB
                    std       <vMulB
                    jsr       >MulQ15Vars+ModBase
                    std       <vSinPitchSinHdgSinBank
                    ldd       <vSinViewPitch
                    std       <vMulA
                    ldd       <vSinHdgCosBank
                    std       <vMulB
                    jsr       >MulQ15Vars+ModBase
                    std       <vVmSinPSinHCosB
                    ldd       <vCosHdgSinBank
                    std       <vMulA
                    ldd       <vSinViewPitch
                    std       <vMulB
                    jsr       >MulQ15Vars+ModBase
                    std       <vVmSinPCosHSinB
                    ldd       <vSinViewPitch
                    std       <vMulA
                    ldd       <vCosHdgCosBank
                    std       <vMulB
                    jsr       >MulQ15Vars+ModBase
                    std       <vVmSinPCosHCosB
                    ldd       <vCosHdgCosBank
                    addd      <vSinPitchSinHdgSinBank
                    std       <vViewM
                    ldd       <vVmSinPSinHCosB
                    subd      <vCosHdgSinBank
                    std       <vViewMXY
                    ldd       <vSinViewHdg
                    std       <vMulA
                    ldd       <vVmCosP
                    std       <vMulB
                    jsr       >MulQ15Vars+ModBase
                    std       <vViewMXZ
                    ldd       <vSinViewBank
                    std       <vMulA
                    ldd       <vVmCosP
                    std       <vMulB
                    jsr       >MulQ15Vars+ModBase
                    std       <vViewMYX
                    ldd       <vVmCosP
                    std       <vMulA
                    ldd       <vCosViewBank
                    std       <vMulB
                    jsr       >MulQ15Vars+ModBase
                    std       <vViewMYY
                    ldd       <vSinViewPitch
                    coma
                    comb
                    addd      #NegCarry
                    std       <vViewMYZ
                    ldd       <vVmSinPCosHSinB
                    subd      <vSinHdgCosBank
                    std       <vViewMZX
                    ldd       <vVmSinHSinB
                    addd      <vVmSinPCosHCosB
                    std       <vViewMZY
                    ldd       <vCosViewHdg
                    std       <vMulA
                    ldd       <vVmCosP
                    std       <vMulB
                    jsr       >MulQ15Vars+ModBase
                    std       <vViewMZZ
                    ldx       #vViewM
                    fcb       $EC,$00                        (ldd) 5-bit zero offset (assembler would emit ,r)
                    fcs       /GVGVm/
                    fcb       $00,$EC,$06
                    fcs       /GVGVm/
                    fcb       $06,$EC,$0C
                    fcs       /GVGVm/
* WildBits: Y column x 0.4858 (aspect of the 255 x 125 view on 640 x 164)
                    fcb       $0C,$EC,$02,$DD,$B1,$CC,$3E,$2F
                    fcb       $DD,$AF,$BD,$D2,$83,$ED,$02,$EC
* WildBits: Y column x 0.4858 (aspect of the 255 x 125 view on 640 x 164)
                    fcb       $08,$DD,$B1,$CC,$3E,$2F,$DD,$AF
                    fcb       $BD,$D2,$83,$ED,$08,$EC,$0E,$DD
* WildBits: Y column x 0.4858 (aspect of the 255 x 125 view on 640 x 164)
                    fcb       $B1,$CC,$3E,$2F,$DD,$AF,$BD,$D2
                    fcb       $83,$ED,$0E,$EC,$04
                    fcs       /GVGVm/
                    fcb       $04,$EC,$0A
                    fcs       /GVGVm/
                    fcb       $0A,$EC,$88,$10
                    fcs       /GVGVm/
                    fcb       $88,$10,$39,$DC,$6E,$DD,$AF,$BD
                    fcb       $D9,$7E,$DC,$B3,$FD,$00,$42,$96
                    fcb       $B5,$B7,$00,$44,$DC,$70,$DD,$AF
                    fcb       $BD,$D9,$7E,$DC,$B3,$FD,$00,$45
                    fcb       $96,$B5,$B7,$00,$47,$DC,$72,$DD
                    fcb       $AF,$BD,$D9,$7E,$DC,$B3,$FD,$00
                    fcb       $48,$96,$B5,$B7,$00
                    fcs       /J9*.CSC/
                    fcb       $00,$01,$DD,$AF,$DC,$0E
                    fcs       /*,CSC/
                    fcb       $00,$01,$DD,$B1,$BD,$D3,$20,$08
                    fcb       $B6,$09,$B5,$09,$B4,$09,$B3,$03
                    fcb       $B5,$03,$B4,$03,$B3,$0C,$B5,$26
                    fcb       $06,$0C,$B4,$26,$02,$0C,$B3,$39
                    fcb       $DC,$0E,$2A,$DE,$43,$53,$C3,$00
                    fcb       $01,$DD,$B1,$BD,$D3,$20,$08,$B6
                    fcb       $09,$B5,$09,$B4,$09,$B3
                    fcb       $39
* GroundPoint: the ground-point transform ($D9C5, from the display-list ops): fsw's GPt
GroundPoint         jmp       >FswGPt
* WildBits: FS's long-line op ($2B, a runway's center line as 8 dashes) took its step as the ends' difference
* halved four times, dropping 4 bits a component, then added it 16 times: the dashes near the camera (a few dozen
* units deep) drifted sideways by up to ~15 units, tens of dots, and jumped as the next dash came in (the center
* line's back-and-forth). Now each component is carried as 16.8 (FswLl: x, y, z positions, then x, y, z steps =
* difference << 4, 24 bits each), so dash k is start + k x difference / 16 to 1/256. (In the room of FS's own
* ground-point transform, which fsw's GPt replaced.)
* LlInit: the start (<$B8) and the step (the difference <$89-<$8E) to FswLl. Registers clobbered.
LlInit              ldx       #FswLl
                    ldy       #vEnd1X
li1@                ldd       ,y                  the start, 16.8
                    std       ,x
                    clr       2,x
                    ldd       -LlDiffOfs,y        the difference, << 4 as 24 bits
                    std       10,x
                    clr       9,x
                    tsta
                    bpl       li2@
                    com       9,x
li2@                lda       #LlStepShifts
li3@                lsl       11,x
                    rol       10,x
                    rol       9,x
                    deca
                    bne       li3@
                    leax      3,x
                    leay      2,y
                    cmpy      #vEnd1Past
                    blo       li1@
                    rts
* LlStep: X = <$C1 or <$B8: the next point (the position plus the step, its whole part) there. D, X, Y clobbered.
LlStep              ldy       #FswLl
                    ldb       #LlAxisCount
ls1@                pshs      b
                    ldd       1,y
                    addd      10,y
                    std       1,y
                    lda       ,y
                    adca      9,y
                    sta       ,y
                    ldd       ,y
                    std       ,x++
                    leay      3,y
                    puls      b
                    decb
                    bne       ls1@
                    rts
                    zmb       $3A46-*
* GroundPtOvZ: the ground point's dZ overflowed 16 bits: halved with the base sums, exponent 63
GroundPtOvZ         fcb       $46
                    fcb       $56,$88,$80,$DD,$8D,$07,$89,$06
                    fcb       $8A,$7E,$DA,$6B
* GroundPtOvX: the ground point's dX overflowed 16 bits: halved (then dZ) with the base sums, exponent 63
GroundPtOvX         fcb       $46,$56
                    fcb       $88,$80,$DD,$89,$37,$06,$93,$10
                    fcb       $29,$06,$47,$56,$DD,$8D,$20,$06
                    fcb       $46,$56,$88,$80,$DD,$8D,$07,$5D
                    fcb       $06,$5E,$07,$60,$06,$61,$07,$63
                    fcb       $06,$64,$0A,$4D
* WildBits: the ground point transform's products, 16 x 16 on the math block (FswXform2)
Xform2Products      jmp       >FswXform2
                    nop
Xform2Software      fcb       $4D,$2A
                    fcb       $0A
                    fcc       /@]*/
                    fcb       $0A
                    fcc       /P=XI /
                    fcb       $0C,$5D,$2A,$F8
                    fcs       /P=CSC/
                    fcb       $00,$01,$58,$49,$D3,$5D,$34,$01
                    fcb       $DD,$5D,$1F,$89,$1D,$35,$01,$28
                    fcb       $01,$43,$97,$5F,$96,$8D,$D6
                    fcc       /tM*/
                    fcb       $0A
                    fcc       /@]*/
                    fcb       $0A
                    fcc       /P=XI /
                    fcb       $0C,$5D,$2A,$F8
                    fcs       /P=CSC/
                    fcb       $00,$01
                    fcc       /XI4/
                    fcb       $02,$D3,$5D,$DD,$5D,$35,$04,$1D
                    fcb       $99,$5F,$97,$5F,$96,$89,$D6
                    fcc       /jM*/
                    fcb       $0A
                    fcc       /@]*/
                    fcb       $0A
                    fcc       /P=XI /
                    fcb       $0C,$5D,$2A,$F8
                    fcs       /P=CSC/
                    fcb       $00,$01,$58,$49,$D3,$60,$34,$01
                    fcb       $DD,$60,$1F,$89,$1D,$35,$01,$28
                    fcb       $01,$43,$97,$62,$96,$8D,$D6
                    fcc       /vM*/
                    fcb       $0A
                    fcc       /@]*/
                    fcb       $0A
                    fcc       /P=XI /
                    fcb       $0C,$5D,$2A,$F8
                    fcs       /P=CSC/
                    fcb       $00,$01
                    fcc       /XI4/
                    fcb       $02,$D3,$60,$DD,$60,$35,$04,$1D
                    fcb       $99,$62,$97,$62,$96,$89,$D6
                    fcc       /lM*/
                    fcb       $0A
                    fcc       /@]*/
                    fcb       $0A
                    fcc       /P=XI /
                    fcb       $0C,$5D,$2A,$F8
                    fcs       /P=CSC/
                    fcb       $00,$01,$58,$49,$D3,$63,$34,$01
                    fcb       $DD,$63,$1F,$89,$1D,$35,$01,$28
                    fcb       $01,$43,$97,$65,$96,$8D,$D6
                    fcc       /xM*/
                    fcb       $0A
                    fcc       /@]*/
                    fcb       $0A
                    fcc       /P=XI /
                    fcb       $0C,$5D,$2A,$F8
                    fcs       /P=CSC/
                    fcb       $00,$01
                    fcc       /XI4/
                    fcb       $02,$D3,$63,$DD,$63,$35,$04,$1D
                    fcb       $99,$65,$97,$65
Xform2Sums          fcb       $96,$5F,$98,$62     WildBits: FswXform2 comes back here
                    fcb       $98,$65,$27,$04,$81,$FF,$26,$14
                    fcb       $96,$5F,$98,$5D,$2B,$10,$96,$62
                    fcb       $98,$60,$2B,$0A,$96,$65,$98,$63
                    fcb       $2B,$04,$20,$08,$8D,$27,$8D,$25
                    fcb       $8D,$23,$20,$14,$96,$5D,$8B,$40
                    fcb       $2B,$0C,$96,$60,$8B,$40,$2B,$06
                    fcb       $96,$63,$8B,$40,$2A,$02,$8D,$0D
                    fcb       $DC,$5D,$ED,$81,$DC,$60,$ED,$81
                    fcb       $DC,$63,$ED,$84,$39,$04,$5F,$06
                    fcb       $5D,$06,$5E,$04,$62,$06,$60,$06
                    fcb       $61,$04,$65,$06,$63,$06,$64,$0A
                    fcc       /M91F/
                    fcb       $10,$9F,$7B,$37,$06,$93,$0C,$10
                    fcb       $29,$06,$2C,$DD,$89,$37,$06,$93
                    fcb       $0E,$10,$29,$06,$4D,$DD,$8B,$37
                    fcb       $06,$93,$10,$10,$29,$06,$4D,$DD
                    fcb       $8D,$96,$89,$8B,$40,$2B,$0C,$96
                    fcb       $8B,$8B,$40,$2B,$06,$96,$8D,$8B
                    fcb       $40,$2A,$0C,$07,$89,$06,$8A,$07
                    fcb       $8B,$06,$8C,$07,$8D,$06,$8E
* WildBits: the 3D point transform's nine products on the math block (FswXform3)
Xform3Products      jmp       >FswXform3
                    nop
                    nop
Xform3Software      fcb       $DC,$89,$DD,$AF
                    fcb       $DC,$68,$DD,$B1,$DC,$AF
                    fcs       /*NCSC/
                    fcb       $00,$01,$DD,$AF,$DC,$B1
                    fcs       /*NCSC/
                    fcb       $00,$01,$DD,$B1,$96,$AF,$D6,$B1
                    fcb       $3D,$DD,$9A,$96,$AF,$D6,$B2,$3D
                    fcb       $9B,$9B,$DD,$9B,$24,$02,$0C,$9A
                    fcb       $96,$B0,$D6,$B1,$3D,$D3,$9B,$DD
                    fcb       $9B,$24,$02,$0C,$9A,$96,$B0,$D6
                    fcb       $B2,$3D,$99,$9C,$97,$9C,$DC,$9A
                    fcb       $C9,$00,$89,$00,$09,$9C,$59,$49
                    fcb       $09,$9C,$C9,$00,$89,$00,$20,$4A
                    fcb       $DC,$B1,$2A,$C0,$43,$53,$C3,$00
                    fcb       $01,$DD,$B1,$96,$AF,$D6,$B1,$3D
                    fcb       $DD,$9A,$96,$AF,$D6,$B2,$3D,$9B
                    fcb       $9B,$DD,$9B,$24,$02,$0C,$9A,$96
                    fcb       $B0,$D6,$B1,$3D,$D3,$9B,$DD,$9B
                    fcb       $24,$02,$0C,$9A,$96,$B0,$D6,$B2
                    fcb       $3D,$99,$9C,$97,$9C,$DC,$9A,$C9
                    fcb       $00,$89,$00,$09,$9C,$59,$49,$09
                    fcb       $9C,$C9,$00,$89,$00,$43,$53,$C3
                    fcb       $00,$01,$ED,$84,$DC,$8B,$DD,$AF
                    fcb       $DC,$6E,$DD,$B1,$DC,$AF
                    fcs       /*NCSC/
                    fcb       $00,$01,$DD,$AF,$DC,$B1
                    fcs       /*NCSC/
                    fcb       $00,$01,$DD,$B1,$96,$AF,$D6,$B1
                    fcb       $3D,$DD,$9A,$96,$AF,$D6,$B2,$3D
                    fcb       $9B,$9B,$DD,$9B,$24,$02,$0C,$9A
                    fcb       $96,$B0,$D6,$B1,$3D,$D3,$9B
                    fcb       $DD,$9B,$24,$02,$0C,$9A,$96,$B0
                    fcb       $D6,$B2,$3D,$99,$9C,$97,$9C,$DC
                    fcb       $9A,$C9,$00,$89,$00,$09,$9C,$59
                    fcb       $49,$09,$9C,$C9,$00,$89,$00,$20
                    fcb       $4A,$DC,$B1,$2A,$C0,$43,$53,$C3
                    fcb       $00,$01,$DD,$B1,$96,$AF,$D6,$B1
                    fcb       $3D,$DD,$9A,$96,$AF,$D6,$B2,$3D
                    fcb       $9B,$9B,$DD,$9B,$24,$02,$0C,$9A
                    fcb       $96,$B0,$D6,$B1,$3D,$D3,$9B,$DD
                    fcb       $9B,$24,$02,$0C,$9A,$96,$B0,$D6
                    fcb       $B2,$3D,$99,$9C,$97,$9C,$DC,$9A
                    fcb       $C9,$00,$89,$00,$09,$9C,$59,$49
                    fcb       $09,$9C,$C9,$00,$89,$00,$43,$53
                    fcb       $C3,$00,$01,$E3,$84,$ED,$84,$DC
                    fcb       $8D,$DD,$AF,$DC,$74,$DD,$B1,$DC
                    fcb       $AF
                    fcs       /*NCSC/
                    fcb       $00,$01,$DD,$AF,$DC,$B1
                    fcs       /*NCSC/
                    fcb       $00,$01,$DD,$B1,$96,$AF,$D6,$B1
                    fcb       $3D,$DD,$9A,$96,$AF,$D6,$B2,$3D
                    fcb       $9B,$9B,$DD,$9B,$24,$02,$0C,$9A
                    fcb       $96,$B0,$D6,$B1,$3D,$D3,$9B,$DD
                    fcb       $9B,$24,$02,$0C,$9A,$96,$B0,$D6
                    fcb       $B2,$3D,$99,$9C,$97,$9C,$DC,$9A
                    fcb       $C9,$00,$89,$00,$09,$9C,$59,$49
                    fcb       $09,$9C,$C9,$00,$89,$00,$20,$4A
                    fcb       $DC,$B1,$2A,$C0,$43,$53,$C3,$00
                    fcb       $01,$DD,$B1,$96,$AF,$D6,$B1,$3D
                    fcb       $DD,$9A,$96,$AF,$D6,$B2,$3D,$9B
                    fcb       $9B,$DD,$9B,$24,$02,$0C,$9A,$96
                    fcb       $B0,$D6,$B1,$3D,$D3,$9B,$DD,$9B
                    fcb       $24,$02,$0C,$9A,$96,$B0,$D6,$B2
                    fcb       $3D,$99,$9C,$97,$9C,$DC,$9A,$C9
                    fcb       $00,$89,$00,$09,$9C,$59,$49,$09
                    fcb       $9C,$C9,$00,$89,$00,$43,$53,$C3
                    fcb       $00,$01,$E3,$84,$ED,$81,$DC,$89
                    fcb       $DD,$AF,$DC,$6A,$DD,$B1,$DC,$AF
                    fcs       /*NCSC/
                    fcb       $00,$01,$DD,$AF,$DC,$B1
                    fcs       /*NCSC/
                    fcb       $00,$01,$DD,$B1,$96,$AF,$D6,$B1
                    fcb       $3D,$DD,$9A,$96,$AF,$D6,$B2,$3D
                    fcb       $9B,$9B,$DD,$9B,$24,$02,$0C,$9A
                    fcb       $96,$B0,$D6,$B1,$3D,$D3,$9B,$DD
                    fcb       $9B,$24,$02,$0C,$9A,$96,$B0,$D6
                    fcb       $B2,$3D,$99,$9C,$97,$9C,$DC,$9A
                    fcb       $C9,$00,$89,$00,$09,$9C,$59,$49
                    fcb       $09,$9C,$C9,$00,$89,$00,$20,$4A
                    fcb       $DC,$B1,$2A,$C0,$43,$53,$C3,$00
                    fcb       $01,$DD,$B1,$96,$AF,$D6,$B1,$3D
                    fcb       $DD,$9A,$96,$AF,$D6,$B2,$3D,$9B
                    fcb       $9B,$DD,$9B,$24,$02,$0C,$9A,$96
                    fcb       $B0,$D6,$B1,$3D,$D3,$9B,$DD,$9B
                    fcb       $24,$02,$0C,$9A,$96,$B0,$D6,$B2
                    fcb       $3D,$99,$9C,$97,$9C,$DC,$9A,$C9
                    fcb       $00,$89,$00,$09,$9C,$59,$49,$09
                    fcb       $9C,$C9,$00,$89,$00,$43,$53,$C3
                    fcb       $00,$01,$ED,$84,$DC,$8B,$DD,$AF
                    fcb       $DC,$70,$DD,$B1,$DC,$AF
                    fcs       /*NCSC/
                    fcb       $00,$01,$DD,$AF,$DC,$B1
                    fcs       /*NCSC/
                    fcb       $00,$01,$DD,$B1,$96,$AF,$D6,$B1
                    fcb       $3D,$DD,$9A,$96,$AF,$D6,$B2,$3D
                    fcb       $9B,$9B,$DD,$9B,$24,$02,$0C,$9A
                    fcb       $96,$B0,$D6,$B1,$3D,$D3,$9B,$DD
                    fcb       $9B,$24,$02,$0C,$9A,$96,$B0,$D6
                    fcb       $B2,$3D,$99,$9C,$97,$9C,$DC,$9A
                    fcb       $C9,$00,$89,$00,$09,$9C,$59,$49
                    fcb       $09,$9C,$C9,$00,$89,$00,$20,$4A
                    fcb       $DC,$B1,$2A,$C0,$43,$53,$C3,$00
                    fcb       $01,$DD,$B1,$96,$AF,$D6,$B1,$3D
                    fcb       $DD,$9A,$96,$AF,$D6,$B2,$3D,$9B
                    fcb       $9B,$DD,$9B,$24,$02,$0C,$9A,$96
                    fcb       $B0,$D6,$B1,$3D,$D3,$9B,$DD,$9B
                    fcb       $24,$02,$0C,$9A,$96,$B0,$D6,$B2
                    fcb       $3D,$99,$9C,$97,$9C,$DC,$9A,$C9
                    fcb       $00,$89,$00,$09,$9C,$59,$49,$09
                    fcb       $9C,$C9,$00,$89,$00,$43,$53,$C3
                    fcb       $00,$01,$E3,$84,$ED,$84,$DC,$8D
                    fcb       $DD,$AF,$DC,$76,$DD,$B1,$DC,$AF
                    fcs       /*NCSC/
                    fcb       $00,$01,$DD,$AF,$DC,$B1
                    fcs       /*NCSC/
                    fcb       $00,$01,$DD,$B1,$96,$AF,$D6,$B1
                    fcb       $3D,$DD,$9A,$96,$AF,$D6,$B2,$3D
                    fcb       $9B,$9B,$DD,$9B,$24,$02,$0C,$9A
                    fcb       $96,$B0,$D6,$B1,$3D,$D3,$9B,$DD
                    fcb       $9B,$24,$02,$0C,$9A,$96,$B0,$D6
                    fcb       $B2,$3D,$99,$9C,$97,$9C,$DC,$9A
                    fcb       $C9,$00,$89,$00,$09,$9C,$59,$49
                    fcb       $09,$9C,$C9,$00,$89,$00,$20,$4A
                    fcb       $DC,$B1,$2A,$C0,$43,$53,$C3,$00
                    fcb       $01,$DD,$B1,$96,$AF,$D6,$B1,$3D
                    fcb       $DD,$9A,$96,$AF,$D6,$B2,$3D,$9B
                    fcb       $9B,$DD,$9B,$24,$02,$0C,$9A,$96
                    fcb       $B0,$D6,$B1,$3D,$D3,$9B,$DD,$9B
                    fcb       $24,$02,$0C,$9A,$96,$B0,$D6,$B2
                    fcb       $3D,$99,$9C,$97,$9C,$DC,$9A,$C9
                    fcb       $00,$89,$00,$09,$9C,$59,$49,$09
                    fcb       $9C,$C9,$00,$89,$00,$43,$53,$C3
                    fcb       $00,$01,$E3,$84,$ED,$81,$DC,$89
                    fcb       $DD,$AF,$DC,$6C,$DD,$B1,$DC,$AF
                    fcs       /*NCSC/
                    fcb       $00,$01,$DD,$AF,$DC,$B1
                    fcs       /*NCSC/
                    fcb       $00,$01,$DD,$B1,$96,$AF,$D6,$B1
                    fcb       $3D,$DD,$9A,$96,$AF,$D6,$B2,$3D
                    fcb       $9B,$9B,$DD,$9B,$24,$02,$0C,$9A
                    fcb       $96,$B0,$D6,$B1,$3D,$D3,$9B,$DD
                    fcb       $9B,$24,$02,$0C,$9A,$96,$B0,$D6
                    fcb       $B2,$3D,$99,$9C,$97,$9C,$DC,$9A
                    fcb       $C9,$00,$89,$00,$09,$9C,$59,$49
                    fcb       $09,$9C,$C9,$00,$89,$00,$20,$4A
                    fcb       $DC,$B1,$2A,$C0,$43,$53,$C3,$00
                    fcb       $01,$DD,$B1,$96,$AF,$D6,$B1,$3D
                    fcb       $DD,$9A,$96,$AF,$D6,$B2,$3D,$9B
                    fcb       $9B,$DD,$9B,$24,$02,$0C,$9A,$96
                    fcb       $B0,$D6,$B1,$3D,$D3,$9B,$DD,$9B
                    fcb       $24,$02,$0C,$9A,$96,$B0,$D6,$B2
                    fcb       $3D,$99,$9C,$97,$9C,$DC,$9A,$C9
                    fcb       $00,$89,$00,$09,$9C,$59,$49,$09
                    fcb       $9C,$C9,$00,$89,$00,$43,$53,$C3
                    fcb       $00,$01,$ED,$84,$DC,$8B,$DD,$AF
                    fcb       $DC,$72,$DD,$B1,$DC,$AF
                    fcs       /*NCSC/
                    fcb       $00,$01,$DD,$AF,$DC,$B1
                    fcs       /*NCSC/
                    fcb       $00,$01,$DD,$B1,$96,$AF,$D6,$B1
                    fcb       $3D,$DD,$9A,$96,$AF,$D6,$B2,$3D
                    fcb       $9B,$9B,$DD,$9B,$24,$02,$0C,$9A
                    fcb       $96,$B0,$D6,$B1,$3D,$D3,$9B,$DD
                    fcb       $9B,$24,$02,$0C,$9A,$96,$B0,$D6
                    fcb       $B2,$3D,$99,$9C,$97,$9C,$DC,$9A
                    fcb       $C9,$00,$89,$00,$09,$9C,$59,$49
                    fcb       $09,$9C,$C9,$00,$89,$00,$20,$4A
                    fcb       $DC,$B1,$2A,$C0,$43,$53,$C3,$00
                    fcb       $01,$DD,$B1,$96,$AF,$D6,$B1,$3D
                    fcb       $DD,$9A,$96,$AF,$D6,$B2,$3D,$9B
                    fcb       $9B,$DD,$9B,$24,$02,$0C,$9A,$96
                    fcb       $B0,$D6,$B1,$3D,$D3,$9B,$DD,$9B
                    fcb       $24,$02,$0C,$9A,$96,$B0,$D6,$B2
                    fcb       $3D,$99,$9C,$97,$9C,$DC,$9A,$C9
                    fcb       $00,$89,$00,$09,$9C,$59,$49,$09
                    fcb       $9C,$C9,$00,$89,$00,$43,$53,$C3
                    fcb       $00,$01,$E3,$84,$ED,$84,$DC,$8D
                    fcb       $DD,$AF,$DC,$78,$DD,$B1,$DC,$AF
                    fcs       /*NCSC/
                    fcb       $00,$01,$DD,$AF,$DC,$B1
                    fcs       /*NCSC/
                    fcb       $00,$01,$DD,$B1,$96,$AF,$D6,$B1
                    fcb       $3D,$DD,$9A,$96,$AF,$D6,$B2,$3D
                    fcb       $9B,$9B,$DD,$9B,$24,$02,$0C,$9A
                    fcb       $96,$B0,$D6,$B1,$3D,$D3,$9B,$DD
                    fcb       $9B,$24,$02,$0C,$9A,$96,$B0,$D6
                    fcb       $B2,$3D,$99,$9C,$97,$9C,$DC,$9A
                    fcb       $C9,$00,$89,$00,$09,$9C,$59,$49
                    fcb       $09,$9C,$C9,$00,$89,$00,$20,$4A
                    fcb       $DC,$B1,$2A,$C0,$43,$53,$C3,$00
                    fcb       $01,$DD,$B1,$96,$AF,$D6,$B1,$3D
                    fcb       $DD,$9A,$96,$AF,$D6,$B2,$3D,$9B
                    fcb       $9B,$DD,$9B,$24,$02,$0C,$9A,$96
                    fcb       $B0,$D6,$B1,$3D,$D3,$9B,$DD,$9B
                    fcb       $24,$02,$0C,$9A,$96,$B0,$D6,$B2
                    fcb       $3D,$99,$9C,$97,$9C,$DC,$9A,$C9
                    fcb       $00,$89,$00,$09,$9C,$59,$49,$09
                    fcb       $9C,$C9,$00,$89,$00,$43,$53,$C3
                    fcb       $00,$01,$E3,$84,$ED,$81,$96,$4E
                    fcb       $27,$0C,$67,$1E,$66,$1F,$67,$1C
                    fcb       $66,$1D,$67,$1A,$66,$1B
                    fcs       /9FV]/
                    fcb       $89,$37,$06,$93,$0E,$10,$29,$00
                    fcb       $06,$DD,$8B
                    fcc       /GV /
                    fcb       $02,$59,$49,$DD,$8B,$37,$06,$93
                    fcb       $10,$10,$29,$00,$06,$DD,$8D
                    fcc       /GV /
                    fcb       $02,$46,$56,$DD,$8D,$7E,$DB,$FF
                    fcb       $46,$56,$DD,$8B,$07,$89,$06,$8A
                    fcb       $20,$E1,$46,$56,$DD,$8D,$07,$8B
                    fcb       $06,$8C,$07,$89,$06,$8A,$7E,$DB
                    fcb       $FF,$DC,$B8,$DD,$C1,$DC,$BA,$DD
                    fcb       $C3,$DC,$BC,$DD,$C5,$86,$FF,$B7
                    fcb       $0A,$BA,$B7,$0A,$BD,$B7,$0A,$BC
                    fcb       $86,$FF,$97,$F4,$DC,$C1,$FD,$0A
                    fcb       $8A,$DC,$C3,$FD,$0A,$8C,$DC,$C5
                    fcb       $FD,$0A,$8E,$7F,$0A,$BF,$DC,$C1
                    fcb       $93,$C5,$2F,$06,$86,$FF,$B7,$0A
                    fcb       $BF,$39,$7F,$0A,$BA,$DC,$C1,$FD
                    fcb       $0A,$A8,$DC,$C3,$FD,$0A,$AA,$DC
                    fcb       $C5,$FD,$0A,$AC,$DC,$C1,$FD,$0A
                    fcb       $90,$DC,$C3,$FD,$0A,$92,$DC,$C5
                    fcb       $FD,$0A,$94,$7F,$0A,$BE,$DC,$C1
                    fcb       $D3,$C5,$2C,$06,$86,$FF,$B7,$0A
                    fcb       $BE,$39,$7F,$0A,$BC,$DC,$C1,$FD
                    fcb       $0A,$B4,$DC,$C3,$FD,$0A,$B6,$DC
                    fcb       $C5,$FD,$0A,$B8,$DC,$C1,$FD,$0A
                    fcb       $9C,$DC,$C3,$FD,$0A,$9E,$DC,$C5
                    fcb       $FD,$0A,$A0,$7F,$0A,$C0,$DC,$C3
                    fcb       $93,$C5,$2F,$06,$86,$FF,$B7,$0A
                    fcb       $C0,$39,$7F,$0A,$BD,$DC,$C1,$FD
                    fcb       $0A,$AE,$DC,$C3,$FD,$0A,$B0,$DC
                    fcb       $C5,$FD,$0A,$B2,$DC,$C1,$FD,$0A
                    fcb       $96,$DC,$C3,$FD,$0A,$98,$DC,$C5
                    fcb       $FD,$0A,$9A,$7F,$0A,$C1,$DC,$C3
                    fcb       $D3,$C5,$2C,$06,$86,$FF,$B7,$0A
* WildBits: the vertex projected exactly by fsw (in place of jsr $D56D / jmp $E494)
                    fcb       $C1,$39
                    jmp       >FswPVtx
                    nop
                    nop
                    nop
                    fcb       $B6,$0A,$BF,$26,$18,$DC,$C1,$93
                    fcb       $C5,$2E,$42,$DC,$C1,$FD,$0A,$8A
                    fcb       $DC,$C3,$FD,$0A,$8C,$DC,$C5,$FD
                    fcb       $0A,$8E,$7E,$E3,$7D,$DC,$C1,$93
                    fcb       $C5,$2F,$10,$DC,$C1,$FD,$0A,$8A
                    fcb       $DC,$C3,$FD,$0A,$8C,$DC,$C5,$FD
                    fcb       $0A,$8E,$39,$7F,$0A,$BF,$BD,$E5
                    fcb       $5C,$BD,$E3,$7D,$FC,$0A,$8A,$DD
                    fcb       $C1,$FC,$0A,$8C,$DD,$C3,$FC,$0A
                    fcb       $8E,$DD,$C5,$20,$08,$86,$FF,$B7
                    fcb       $0A,$BF,$BD,$E5,$5C,$7D,$0A,$BA
                    fcb       $10,$26,$FF,$0E,$B6,$0A,$BE,$26
                    fcb       $18,$DC,$C1,$D3,$C5,$2D,$42,$DC
                    fcb       $C1,$FD,$0A,$90,$DC,$C3,$FD,$0A
                    fcb       $92,$DC,$C5,$FD,$0A,$94,$7E,$E3
                    fcb       $D9,$DC,$C1,$D3,$C5,$2C,$10,$DC
                    fcb       $C1,$FD,$0A,$90,$DC,$C3,$FD,$0A
                    fcb       $92,$DC,$C5,$FD,$0A,$94,$39,$7F
                    fcb       $0A,$BE,$BD,$E5,$7D,$BD,$E3,$D9
                    fcb       $FC,$0A,$90,$DD,$C1,$FC,$0A,$92
                    fcb       $DD,$C3,$FC,$0A,$94,$DD,$C5,$20
                    fcb       $08,$86,$FF,$B7,$0A,$BE,$BD,$E5
                    fcb       $7D,$7D,$0A,$BC,$10,$26,$FE,$E2
                    fcb       $B6,$0A,$C0,$26,$18,$DC,$C3,$93
                    fcb       $C5,$2E,$42,$DC,$C1,$FD,$0A,$9C
                    fcb       $DC,$C3,$FD,$0A,$9E,$DC,$C5,$FD
                    fcb       $0A,$A0,$7E,$E4,$35,$DC,$C3,$93
                    fcb       $C5,$2F,$10,$DC,$C1,$FD,$0A,$9C
                    fcb       $DC,$C3,$FD,$0A,$9E,$DC,$C5,$FD
                    fcb       $0A,$A0,$39,$7F,$0A,$C0,$BD,$E5
                    fcb       $9E,$BD,$E4,$35,$FC,$0A,$9C,$DD
                    fcb       $C1,$FC,$0A,$9E,$DD,$C3,$FC,$0A
                    fcb       $A0,$DD,$C5,$20,$08,$86,$FF,$B7
                    fcb       $0A,$C0,$BD,$E5,$9E,$7D,$0A,$BD
                    fcb       $10,$26,$FE,$B6,$B6,$0A,$C1,$26
                    fcb       $18,$DC,$C3,$D3,$C5,$2D,$42,$DC
                    fcb       $C1,$FD,$0A,$96,$DC,$C3,$FD,$0A
                    fcb       $98,$DC,$C5,$FD,$0A,$9A,$7E,$E4
                    fcb       $91,$DC,$C3,$D3,$C5,$2C,$10,$DC
                    fcb       $C1,$FD,$0A,$96,$DC,$C3,$FD,$0A
                    fcb       $98,$DC,$C5,$FD,$0A,$9A,$39,$7F
                    fcb       $0A,$C1,$BD,$E5,$BF,$BD,$E4,$91
                    fcb       $FC,$0A,$96,$DD,$C1,$FC,$0A,$98
                    fcb       $DD,$C3,$FC,$0A,$9A,$DD,$C5,$20
                    fcb       $08,$86,$FF,$B7,$0A,$C1,$BD,$E5
* WildBits: the vertex projected exactly by fsw (in place of jsr $D56D and the PolyBegin/PolyAddVertex jumps)
                    fcb       $BF
                    jmp       >FswPVtx
                    fcb       $0C,$F4,$27,$03
                    fcb       $7E,$B1,$86,$7E,$B1,$70,$0F,$41
                    fcb       $DC,$2A,$DD,$C1,$DC,$2C,$DD,$C3
                    fcb       $DC,$2E,$DD,$C5,$7D,$0A,$BF,$26
                    fcb       $08,$DC,$C1,$93,$C5,$2E,$0A,$20
                    fcb       $0E,$DC,$C1,$93,$C5,$2F,$02,$20
                    fcb       $06,$BD,$E5,$5C,$BD,$E3,$7D,$7D
                    fcb       $0A,$BA,$26,$2A,$FC,$0A,$A8,$DD
                    fcb       $C1,$FC,$0A,$AA,$DD,$C3,$FC,$0A
                    fcb       $AC,$DD,$C5,$7D,$0A,$BE,$26,$08
                    fcb       $DC,$C1,$D3,$C5,$2D,$0A,$20,$0E
                    fcb       $DC,$C1,$D3,$C5,$2C,$02,$20,$06
                    fcb       $BD,$E5,$7D,$BD,$E3,$D9,$7D,$0A
                    fcb       $BC,$26,$2A,$FC,$0A,$B4,$DD,$C1
                    fcb       $FC,$0A,$B6,$DD,$C3,$FC,$0A,$B8
                    fcb       $DD,$C5,$7D,$0A,$C0,$26,$08,$DC
                    fcb       $C3,$93,$C5,$2E,$0A,$20,$0E,$DC
                    fcb       $C3,$93,$C5,$2F,$02,$20,$06,$BD
                    fcb       $E5,$9E,$BD,$E4,$35,$7D,$0A,$BD
                    fcb       $26,$2A,$FC,$0A,$AE,$DD,$C1,$FC
                    fcb       $0A,$B0,$DD,$C3,$FC,$0A,$B2,$DD
                    fcb       $C5,$7D,$0A,$C1,$26,$08,$DC,$C3
                    fcb       $D3,$C5,$2D,$0A,$20,$0E,$DC,$C3
                    fcb       $D3,$C5,$2C,$02,$20,$06,$BD,$E5
                    fcb       $BF,$BD,$E4,$91,$0A,$F4,$2B,$03
* WildBits: the polygon filled exactly by fsw
                    jmp       >FswPFill
                    fcb       $39,$FC,$0A,$8A,$DD
                    fcb       $B8,$FC,$0A,$8C,$DD,$BA,$FC,$0A
                    fcb       $8E,$DD,$BC,$DC,$C1,$FD,$0A,$8A
                    fcb       $DC,$C3,$FD,$0A,$8C,$DC,$C5,$FD
                    fcb       $0A,$8E,$7E,$E7,$65,$FC,$0A,$90
                    fcb       $DD,$B8,$FC,$0A,$92,$DD,$BA,$FC
                    fcb       $0A,$94,$DD,$BC,$DC,$C1,$FD,$0A
                    fcb       $90,$DC,$C3,$FD,$0A,$92,$DC,$C5
                    fcb       $FD,$0A,$94,$7E,$E7,$A4,$FC,$0A
                    fcb       $9C,$DD,$B8,$FC,$0A,$9E,$DD,$BA
                    fcb       $FC,$0A,$A0,$DD,$BC,$DC,$C1,$FD
                    fcb       $0A,$9C,$DC,$C3,$FD,$0A,$9E,$DC
                    fcb       $C5,$FD,$0A,$A0,$7E,$E6,$E2,$FC
                    fcb       $0A,$96,$DD,$B8,$FC,$0A,$98,$DD
                    fcb       $BA,$FC,$0A,$9A,$DD,$BC,$DC,$C1
                    fcb       $FD,$0A,$96,$DC,$C3,$FD,$0A,$98
                    fcb       $DC,$C5,$FD,$0A,$9A,$7E,$E7,$21
                    fcb       $0F,$B7,$96,$BC,$2A,$04,$C6,$80
                    fcb       $D7,$B7,$DC,$BC,$D3,$B8,$2C,$06
                    fcb       $C6,$40,$DA,$B7,$D7,$B7,$DC,$BC
                    fcb       $93,$B8,$2C,$06,$C6,$20,$DA,$B7
                    fcb       $D7,$B7,$DC,$BC,$D3,$BA,$2C,$06
                    fcb       $C6,$10,$DA,$B7,$D7,$B7,$DC,$BC
                    fcb       $93,$BA,$2C,$06,$C6,$08,$DA,$B7
                    fcb       $D7,$B7,$39,$0F,$C0,$96,$C5,$2A
                    fcb       $04,$C6,$80,$D7,$C0,$DC,$C5,$D3
                    fcb       $C1,$2C,$06,$C6,$40,$DA,$C0,$D7
                    fcb       $C0,$DC,$C5,$93,$C1,$2C,$06,$C6
                    fcb       $20,$DA,$C0,$D7,$C0,$DC,$C5,$D3
                    fcb       $C3,$2C,$06,$C6,$10,$DA,$C0,$D7
                    fcb       $C0,$DC,$C5,$93,$C3,$2C,$06,$C6
                    fcb       $08,$DA,$C0,$D7,$C0,$39,$8D,$02
                    fcb       $8D,$40,$8E,$00,$B7,$10,$8E,$00
                    fcb       $C0,$A6,$84,$E6,$A4,$E7,$80,$A7
                    fcb       $A0,$A6,$84,$E6,$A4,$E7,$80,$A7
                    fcb       $A0,$A6,$84,$E6,$A4,$E7,$80,$A7
                    fcb       $A0,$A6,$84,$E6,$A4,$E7,$80,$A7
                    fcb       $A0,$A6,$84,$E6,$A4,$E7,$80,$A7
                    fcb       $A0,$A6,$84,$E6,$A4,$E7,$80,$A7
                    fcb       $A0,$A6,$84,$E6,$A4,$E7,$80,$A7
                    fcb       $A0,$39,$96,$C0,$27,$40,$84,$40
                    fcb       $27,$0C,$BD,$E7,$A4,$BD,$E6,$1B
                    fcb       $96,$C0,$94,$B7,$26,$30,$96,$C0
                    fcb       $84,$20,$27,$0C,$BD,$E7,$65,$BD
                    fcb       $E6,$1B,$96,$C0,$94,$B7,$26,$1E
                    fcb       $96,$C0,$84,$10,$27,$0C,$BD,$E7
                    fcb       $21,$BD,$E6,$1B,$96,$C0,$94,$B7
                    fcb       $26,$0C,$96,$C0,$84,$08,$27,$06
                    fcb       $BD,$E6,$E2,$7E,$E6,$1B,$39,$BD
                    fcb       $E7,$E5
* WildBits: each clip-plane cut ($E6E2, $E721, $E765, $E7A4) begins in fsw's ClipIn: both ends within +-16383, so
* the cut's 16-bit differences cannot wrap (in place of ldd <$BC / subd <$C5)
                    jsr       >FswClipIn
                    nop
                    fcb       $DD,$B1
                    fcb       $DC,$BA,$93,$C3,$93,$B1,$29,$EF
                    fcb       $DD,$B1,$DC,$C5,$93,$C3,$BD,$D3
                    fcb       $53,$DC,$B8,$93,$C1,$DD,$B1,$DC
                    fcb       $AF,$DD,$90,$BD,$D2,$83,$D3,$C1
                    fcb       $DD,$C1,$DC,$BC,$93,$C5,$DD,$B1
                    fcb       $DC,$90,$DD,$AF,$BD,$D2,$83,$D3
                    fcb       $C5,$DD,$C5,$DD,$C3,$39,$BD,$E7
                    fcb       $E5
                    jsr       >FswClipIn
                    nop
                    fcb       $DD,$B1,$DC
                    fcb       $C3,$93,$BA,$93,$B1,$29,$EF,$DD
                    fcb       $B1,$DC,$C5,$D3,$C3,$BD,$D3,$53
                    fcb       $DC,$B8,$93,$C1,$DD,$B1,$DC,$AF
                    fcb       $DD,$90,$BD,$D2,$83,$D3,$C1,$DD
                    fcb       $C1,$DC,$BC,$93,$C5,$DD,$B1,$DC
                    fcb       $90,$DD,$AF,$BD,$D2,$83,$D3,$C5
                    fcb       $DD,$C5,$43,$53,$C3,$00,$01,$DD
                    fcb       $C3,$39,$BD,$E7,$E5
                    jsr       >FswClipIn
                    nop
                    fcb       $DD,$B1,$DC,$B8,$93,$C1,$93
                    fcb       $B1,$29,$EF,$DD,$B1,$DC,$C5,$93
                    fcb       $C1,$BD,$D3,$53,$DC,$BC,$93,$C5
                    fcb       $DD,$B1,$DC,$AF,$DD,$90,$BD,$D2
                    fcb       $83,$D3,$C5,$DD,$C5,$DD,$C1,$DC
                    fcb       $BA,$93,$C3,$DD,$B1,$DC,$90,$DD
                    fcb       $AF,$BD,$D2,$83,$D3,$C3,$DD,$C3
                    fcb       $39,$BD,$E7,$E5
                    jsr       >FswClipIn
                    nop
                    fcb       $DD,$B1,$DC,$C1,$93,$B8,$93,$B1
                    fcb       $29,$EF,$DD,$B1,$DC,$C5,$D3,$C1
                    fcb       $BD,$D3,$53,$DC,$BA,$93,$C3,$DD
                    fcb       $B1,$DC,$AF,$DD,$90,$BD,$D2,$83
                    fcb       $D3,$C3,$DD,$C3,$DC,$BC,$93,$C5
                    fcb       $DD,$B1,$DC,$90,$DD,$AF,$BD,$D2
                    fcb       $83,$D3,$C5,$DD,$C5,$43,$53,$C3
                    fcb       $00,$01,$DD,$C1,$39,$8E,$00,$B8
                    fcb       $BD,$CB,$F7,$8E,$00,$C1,$BD,$CB
* WildBits: no ESC $31 (CoCo palette) on the WildBits terminal: four $00 no-ops each, the same length
                    fcb       $F7,$39,$0C,$05,$20,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$02
                    fcc       /  **** Course Plotter System ****/
                    fcb       $02
                    fcc       / #A. Begin NORMAL course recording/
                    fcb       $02
                    fcc       / %B. Display course plot/
                    fcb       $02
                    fcc       / 'C. Begin PRECISION recording/
                    fcb       $02
                    fcc       / )D. Turn off course plotter/
                    fcb       $02
                    fcc       / -Select option, then press Q to/
                    fcb       $02
                    fcc       / .return to Flight, Slew, or Radar/
                    fcb       $02,$20,$2F
                    fcc       /mode to view or record course./
                    fcb       $8E,$E7,$F2,$10,$8E,$01,$0A,$86
                    fcb       $01,$BD,$B9,$B5,$C4,$DF,$C1,$41
                    fcb       $27,$1D,$C1,$42,$27,$1F,$C1
                    fcs       /C'.A/
                    fcs       /D'$A/
                    fcb       $51,$26,$DE
* WildBits: the course plotter's return to the flight screen went through the original's SS.DScrn with the CoCo
* screen address in X, which the WildBits driver takes as the master control byte ($9A: graphics off, a black
* screen; 2026-10-17). WbDScrn as every other switch; the same 13 bytes (lda, ldy, ldb, os9, rts).
                    lda       >FsPath
                    ldy       >WbScrBlks              nonzero: the flight screen
                    jsr       >WbDScrn+ModBase    WildBits SS.DScrn (fs_wb.asm)
                    rts
                    nop
                    nop
                    fcb       $C6,$06,$86,$0A,$20,$17,$B6,$08
                    fcb       $A8,$27,$C6,$86,$02,$B7,$08,$A4
                    fcb       $7E,$E8,$FC,$7F,$08,$A4,$7E,$E8
                    fcb       $FC,$C6,$04,$86,$02,$F7,$08,$A7
                    fcb       $B7,$08,$A2,$B7,$08,$A3,$86,$01
                    fcb       $B7,$08,$A4,$BE,$0C,$CF,$30,$89
                    fcb       $3C,$00,$86,$07,$A7,$80,$B6,$08
                    fcb       $A7,$A7,$80,$DC,$02,$ED,$81,$DC
                    fcb       $00,$ED,$81,$DC,$06,$ED,$81,$DC
                    fcb       $04,$ED,$81,$DC,$0A,$ED,$81,$DC
                    fcb       $08,$ED,$81,$86,$1B,$A7,$80,$86
                    fcb       $01,$A7,$80,$4F,$5F,$ED,$81,$ED
                    fcb       $81,$ED,$81,$86,$79,$A7,$84,$BF
                    fcb       $08,$A5,$86,$01,$B7,$08,$A8,$7E
                    fcb       $E8,$FC
* CoursePlotterUpdate: per-frame course plotter: mode $08A4 1 = record points, 2 = display the plot
CoursePlotterUpdate               lda       >vPlotMode
                    bne       CoursePlotterModeCheck
                    rts
* CoursePlotterModeCheck: course plotter: dispatch on mode
CoursePlotterModeCheck               cmpa      #PlotModeRecord
                    beq       CoursePlotterRecordTick
                    cmpa      #PlotModeShow
                    beq       CoursePlotterDisplay
                    rts
* CoursePlotterDisplay: course plotter: draw the recorded course (buffer at $0CCF+$3C00) via RunDisplayList
CoursePlotterDisplay               ldx       >FsScreen
                    leax      >FsCourseOfs,x
                    stx       <vDispListPtr
                    jsr       >RunDisplayList+ModBase
                    rts
* CoursePlotterRecordTick: course plotter recording: count down the sample interval $08A3
CoursePlotterRecordTick               dec       >vPlotCount
                    beq       CoursePlotterRecordPoint
                    rts
* CoursePlotterRecordPoint: course plotter: reload interval, stop if the buffer is full
CoursePlotterRecordPoint               lda       >vPlotEvery
                    sta       >vPlotCount
                    ldx       >FsScreen
* WildBits: the points end with the screen block ($9D10-$9FF2, after the panel)
                    leax      >WbCourseEnd-WbScrBase,x
                    cmpx      >vPlotPtr
                    bhi       CoursePlotterStorePoint
                    rts
* CoursePlotterStorePoint: course plotter: store a point (X, altitude, Z relative to the start) at $08A5, end marker $79
CoursePlotterStorePoint               ldy       >FsScreen
                    leay      >FsCourseOfs,y
                    ldx       >vPlotPtr
                    lda       #DlOpLineTo
                    sta       ,x+
                    ldb       <vPosX+2
                    subb      2,y
                    lda       <vPosX+1
                    sbca      5,y
                    tfr       d,u
                    lda       <vPosX
                    sbca      4,y
                    sta       >vPlotDeltaHi
                    tfr       u,d
                    jsr       >CoursePlotScaleDelta+ModBase
                    std       ,x++
                    ldb       <vAlt+2
                    subb      6,y
                    lda       <vAlt+1
                    sbca      9,y
                    tfr       d,u
                    lda       <vAlt
                    sbca      8,y
                    sta       >vPlotDeltaHi
                    tfr       u,d
                    jsr       >CoursePlotScaleDelta+ModBase
                    std       ,x++
                    ldb       <vPosZ+2
                    subb      10,y
                    lda       <vPosZ+1
                    sbca      13,y
                    tfr       d,u
                    lda       <vPosZ
                    sbca      12,y
                    sta       >vPlotDeltaHi
                    tfr       u,d
                    jsr       >CoursePlotScaleDelta+ModBase
                    std       ,x++
                    lda       #DlOpEnd
                    sta       ,x
                    stx       >vPlotPtr
                    rts
* CoursePlotScaleDelta: course plotter: divide 24-bit delta ($00A3:D) by 16 unless PRECISION mode ($08A7=4)
CoursePlotScaleDelta               pshs      a
                    lda       >vPlotScale
                    cmpa      #PlotScalePrecise
                    puls      a
                    beq       CoursePlotScaleDone
                    lsr       >vPlotDeltaHi
                    rora
                    rorb
                    lsr       >vPlotDeltaHi
                    rora
                    rorb
                    lsr       >vPlotDeltaHi
                    rora
                    rorb
                    lsr       >vPlotDeltaHi
                    rora
                    rorb
* CoursePlotScaleDone: course plotter scale: return D
CoursePlotScaleDone               rts
                    fcb       $F6,$03,$23,$8E,$02,$A8,$E6,$85
                    fcb       $FB,$02,$CB,$BD,$EA,$E1,$10,$BF
                    fcb       $14,$0C,$CC,$01,$68,$DD,$AF,$FC
                    fcb       $03,$40,$BD,$D3,$4B,$DC,$B3,$BD
                    fcb       $EA,$E2,$10,$BF,$14,$7C,$81,$30
                    fcb       $26,$02,$86,$20,$B7,$14,$7B,$F6
                    fcb       $03,$3E,$BD,$EA,$E1,$1F,$20,$81
                    fcb       $30,$26,$02,$86,$20,$FD,$14,$82
                    fcb       $F6,$03,$21,$FB,$01,$57,$C1,$18
                    fcb       $25,$02,$C0,$18,$BD,$EA,$E1,$10
                    fcb       $BF,$13,$F4,$CC,$08,$66,$DD,$AF
                    fcb       $FC,$01,$58,$BD,$D3,$4B,$7F,$14
                    fcb       $89,$DC,$B3,$27,$15,$BD,$EA,$E2
                    fcb       $81,$30,$26,$02,$86,$20,$B7,$14
                    fcb       $9B,$10,$BF,$14,$9C,$C6,$20,$F7
                    fcb       $14,$89,$F6,$03
                    fcc       /@TTTTTT/
                    fcb       $8E,$02,$A5,$E6,$85,$BD,$EA,$E1
                    fcb       $10,$BF,$14
                    fcc       /;9O/
                    fcb       $8E,$02,$36,$BD,$B4,$9E,$B6,$02
                    fcb       $36,$10,$BE,$02,$37,$39
* PrintPendingMessage: print the packed message at $02C4 once (when flag $02AD is clear), then call DelayA with A=4
PrintPendingMessage               lda       >vComMsgDone
                    beq       PrintPendingMessageDo
                    rts
* PrintPendingMessageDo: pending message: set flag, clear screen, print the text
PrintPendingMessageDo               inc       >vComMsgDone
                    clr       >vMsgEnd
                    lda       #PkTextMargin
                    sta       >vMsgY
                    sta       >vMsgX
                    jsr       >ClearViewWindow+ModBase
                    ldu       >vComMsg
                    jsr       >PrintPackedText+ModBase
                    lda       #PendMsgDelay
                    jmp       >DelayA+ModBase
* PrintPackedText: print packed text at U: high-bit bytes are word tokens (tables $13D0/$13DD), 0 ends
PrintPackedText               pulu      b
* PrintPackedTextB: print packed text starting with the byte in B (used to print a space then a token word)
PrintPackedTextB               tstb
                    bne       PrintPackedTextToken
                    rts
* PrintPackedTextToken: packed text: byte with high bit set, expand the dictionary word
PrintPackedTextToken               bpl       PrintPackedTextChar
                    pshs      u
                    ldx       #vDictOfs
                    andb      #PkTextTokenMask
                    ldb       b,x
                    ldx       #vDictText
                    abx
                    tfr       x,u
                    ldb       #AsciiSpace
                    jsr       >PrintPackedTextB+ModBase
                    jsr       >TextCursorAdvance+ModBase
                    puls      u
* PrintPackedTextNext: packed text: continue with the next byte
PrintPackedTextNext               bra       PrintPackedText
* PrintPackedTextChar: packed text: draw one character at $0236/$0237 via DrawTextString with a delay ($0308)
PrintPackedTextChar               cmpb      #AsciiSpace
                    beq       PrintPackedTextSpace
                    stb       >vMsgChar
                    ldx       #vMsgCharTxt
                    ldd       #TxtWhite
                    std       >vTextColor
                    pshs      u
                    ldu       >FsScreen
                    jsr       >DrawTextString+ModBase
                    puls      u
                    lda       >vCommRate
                    coma
                    ldb       #CharDelayLo
                    tfr       d,x
* PrintPackedTextDelay: packed text: per-character delay loop
PrintPackedTextDelay               leax      -1,x
                    bne       PrintPackedTextDelay
                    jsr       >TextCursorStepX+ModBase
                    bra       PrintPackedTextNext
* PrintPackedTextSpace: packed text: space, just advance the cursor
PrintPackedTextSpace               jsr       >TextCursorAdvance+ModBase
                    bra       PrintPackedTextNext
* TextCursorAdvance: advance text cursor $0236 by 4; at column $64 go to next row (+7), clear screen when past row $5A
TextCursorAdvance               lda       >vMsgX
                    cmpa      #PkTextWrapCol
                    blo       TextCursorStepX
                    lda       >vMsgY
                    adda      #PkTextRowStep
                    cmpa      #PkTextRowEnd
                    blo       TextCursorSetRow
                    jsr       >ClearViewWindow+ModBase
                    lda       #PkTextMargin
* TextCursorSetRow: text cursor: store new row and return to column 3
TextCursorSetRow               sta       >vMsgY
                    lda       #PkTextMargin
                    bra       TextCursorStoreX
* TextCursorStepX: text cursor: move right one character (4 pixels)
TextCursorStepX               lda       >vMsgX
                    adda      #CharStep
* TextCursorStoreX: text cursor: store column $0236
TextCursorStoreX               sta       >vMsgX
                    rts
* ApplyWindDrift: when airborne ($0781 clear) subtract wind drift $0742/$0744 from X (<$00-02) and Z (<$08-0A) positions
ApplyWindDrift               lda       >vOnGnd
                    bne       ApplyWindDriftDone
                    ldb       >vWindStepX
                    sex
                    sta       <vDriftSignExt
                    ldd       <vPosX+2
                    subd      >vWindStepX
                    std       <vPosX+2
                    lda       <vPosX+1
                    sbca      <vDriftSignExt
                    sta       <vPosX+1
                    lda       <vPosX
                    sbca      <vDriftSignExt
                    sta       <vPosX
                    ldb       >vWindStepZ
                    sex
                    sta       <vDriftSignExt
                    ldd       <vPosZ+2
                    subd      >vWindStepZ
                    std       <vPosZ+2            WildBits: the whole word (FS kept the high byte: whole meters)
                    lda       <vPosZ+1
                    sbca      <vDriftSignExt
                    sta       <vPosZ+1
                    lda       <vPosZ
                    sbca      <vDriftSignExt
                    sta       <vPosZ
* ApplyWindDriftDone: wind drift: return
ApplyWindDriftDone               rts
* ComputeWindDrift: pick the wind layer for the current altitude (<$05 vs $032C/$032E/$0330) and compute drift $0742/$0744 from its speed and direction
ComputeWindDrift               ldd       <vAlt+1
                    cmpd      >vShear1
                    blo       ComputeWindSurface
                    cmpd      >vShear2
                    blo       ComputeWindLayer3
                    cmpd      >vShear3
                    blo       ComputeWindLayer2
                    ldx       #vWind3
                    bra       ComputeWindDirection
* ComputeWindLayer2: wind: the menu's wind level 2 (vWind2)
ComputeWindLayer2               ldx       #vWind2
                    bra       ComputeWindDirection
* ComputeWindLayer3: wind: the menu's wind level 1 (vWind1)
ComputeWindLayer3               ldx       #vWind1
                    bra       ComputeWindDirection
* ComputeWindSurface: wind: the surface wind (vWindSfc), flags the extra direction offset vHdgOfs2
ComputeWindSurface               ldx       #vWindSfc
                    inc       >vWindSfcFlag
* ComputeWindDirection: wind: layer direction plus $0148 (and $014A for the surface layer)
ComputeWindDirection               lda       2,x
                    adda      >vHdgOfs1
                    lsr       >vWindSfcFlag
                    bhs       ComputeWindComponents
                    adda      >vHdgOfs2
* ComputeWindComponents: wind: sin/cos of direction times layer speed times time step $077C
ComputeWindComponents               pshs      a,x
                    jsr       >Sin8+ModBase
                    sta       <vWindDirSin
                    puls      a
                    jsr       >Cos8+ModBase
                    sta       <vWindDirCos
                    puls      x
                    lda       ,x
                    pshs      a
                    ldb       <vWindDirSin
                    jsr       >MulSigned8+ModBase
                    aslb
                    rola
                    ldb       >vTimeStep
                    jsr       >MulSigned8+ModBase
                    std       >vWindStepX         WildBits: the whole 1/256 m drift (FS stored the high byte only:
*                                                 a small drift west became 1 m a frame, one east 0, shoving the
*                                                 aircraft 1 m a frame along X from liftoff on, the faster the frames
*                                                 the faster)
                    puls      a
                    ldb       <vWindDirCos
                    jsr       >MulSigned8+ModBase
                    aslb
                    rola
                    ldb       >vTimeStep
                    jsr       >MulSigned8+ModBase
                    std       >vWindStepZ         WildBits: the whole word, as vWindStepX
                    rts
* TblDaylightTimes: per season: 4 hour:minute pairs (dawn start, dawn end, dusk start, dusk end), e.g. 6:00 6:30 19:00 19:30
TblDaylightTimes               fcb       $06,$00,$06,$1E,$13,$00,$13,$1E
                    fcb       $07,$00,$07,$1E,$11,$00,$11,$1E
                    fcb       $06,$00,$06,$1E,$13,$00,$13,$1E
                    fcb       $05,$00,$05,$1E,$15,$00,$15,$1E
* UpdateDaylight: set lighting level $013F (1 day, 2 dawn/dusk, 4 night) from clock $0321:$0322 and vSeason
UpdateDaylight               ldb       >vSeason
                    andb      #SeasonRowMask
                    aslb
                    aslb
                    aslb
                    ldx       #TblDaylightTimes+ModBase
                    abx
                    lda       >vHour
                    ldb       >vMinute
                    cmpd      ,x
                    blo       UpdateDaylightNight
                    cmpd      2,x
                    blo       UpdateDaylightDusk
                    cmpd      4,x
                    blo       UpdateDaylightDay
                    cmpd      6,x
                    blo       UpdateDaylightDusk
* UpdateDaylightNight: daylight: night (4)
UpdateDaylightNight               lda       #LightNight
                    bra       UpdateDaylightStore
* UpdateDaylightDusk: daylight: dawn or dusk (2)
UpdateDaylightDusk               lda       #LightDusk
                    bra       UpdateDaylightStore
* UpdateDaylightDay: daylight: day (1)
UpdateDaylightDay               lda       #LightDay
* UpdateDaylightStore: daylight: store level, then set season bit $0187
UpdateDaylightStore               sta       >vLight
                    ldb       >vSeason
                    lda       #SeasonBitWinter
* UpdateDaylightSeasonLoop: daylight: shift a bit by the season number into $0187
UpdateDaylightSeasonLoop               sta       >vSeasonBit
                    asla
                    decb
                    bne       UpdateDaylightSeasonLoop
                    rts
* SlewRateToDelta: convert slew rate in A (A/4 = power of two) to a signed 24-bit step in $9A:D
SlewRateToDelta               asra
                    asra
                    sta       <vSlewShifts
                    beq       SlewRateToDeltaZero
                    bpl       SlewRateToDeltaPos
                    ldd       #SlewStepNegOne
                    sta       <vSlewStepHi
* SlewRateToDeltaNegLoop: slew rate: negative rate, build -2^n
SlewRateToDeltaNegLoop               aslb
                    rola
                    rol       <vSlewStepHi
                    inc       <vSlewShifts
                    bmi       SlewRateToDeltaNegLoop
                    rts
* SlewRateToDeltaPos: slew rate: positive rate, build 2^n-1
SlewRateToDeltaPos               ldd       #SlewStepZero
                    sta       <vSlewStepHi
* SlewRateToDeltaPosLoop: slew rate: shift ones into the step
SlewRateToDeltaPosLoop               orcc      #Carry
                    rolb
                    rola
                    rol       <vSlewStepHi
                    dec       <vSlewShifts
                    bne       SlewRateToDeltaPosLoop
                    rts
* SlewRateToDeltaZero: slew rate: zero rate, zero step
SlewRateToDeltaZero               ldb       #SlewStepZero
                    stb       <vSlewStepHi
                    rts
* SlewModeUpdate: slew mode: move the aircraft by the slew rates (X $0812, Z $081A, altitude $0833) and turn pitch/bank/heading ($0831/$082D/$082F); rates cleared on entry when $07EF set
SlewModeUpdate               lda       >vSlewEntry
                    beq       SlewModeApply
                    ldd       #SlewCtlZero
                    sta       >vSlewEntry
                    std       >vElevator
                    std       >vRudder
                    std       >vAileron
                    sta       >vSlewPitch
                    sta       >vSlewAlt
* SlewModeApply: slew mode: add the X, Z and altitude steps (altitude clamped at 0)
SlewModeApply               lda       >vAileron
                    lbsr      SlewRateToDelta
                    addd      <vPosX+1
                    std       <vPosX+1
                    lda       <vPosX
                    adca      <vSlewStepHi
                    sta       <vPosX
                    lda       >vElevator
                    nega
                    jsr       >SlewRateToDelta+ModBase
                    addd      <vPosZ+1
                    std       <vPosZ+1
                    lda       <vPosZ
                    adca      <vSlewStepHi
                    sta       <vPosZ
                    ldb       >vSlewAlt
                    sex
                    pshs      a
                    addd      <vAlt+1
                    std       <vAlt+1
                    puls      a
                    adca      <vAlt
                    sta       <vAlt
                    bpl       SlewModePitch
                    ldd       #SlewAltZero
                    sta       <vAlt
                    std       <vAlt+1
                    std       >vSlewAlt
* SlewModePitch: slew mode: apply pitch rate (sign depends on whether inverted)
SlewModePitch               lda       >vSlewPitch
                    ldb       <vBank
                    addb      #Angle8Quarter
                    bpl       SlewModePitchAdd
                    nega
* SlewModePitchAdd: slew mode: add pitch rate to <$12
SlewModePitchAdd               adda      <vPitch
                    sta       <vPitch
                    bmi       SlewModePitchNeg
                    cmpa      #Angle8PastQuarter
                    blo       SlewModeBankHeading
                    bra       SlewModeFlipOver
* SlewModePitchNeg: slew mode: check negative pitch past vertical
SlewModePitchNeg               cmpa      #Angle8NegQuarter
                    bhs       SlewModeBankHeading
* SlewModeFlipOver: slew mode: pitch passed vertical, mirror pitch and flip bank and heading
SlewModeFlipOver               ldb       <vPitch+1
                    coma
                    comb
                    addd      #NegCarry
                    eora      #Angle8Half
                    std       <vPitch
                    lda       <vBank
                    eora      #Angle8Half
                    sta       <vBank
                    lda       <vHdg
                    eora      #Angle8Half
                    sta       <vHdg
* SlewModeBankHeading: slew mode: apply bank and heading rates, update map position $0309/$030B
SlewModeBankHeading               lda       >vSlewBank
                    adda      <vBank
                    sta       <vBank
                    lda       <vHdg
                    suba      >vSlewHdg
                    sta       <vHdg
                    ldd       <vPosZ
                    adda      #EdPosBiasHi
                    std       >vModeNorth
                    ldd       <vPosX
                    adda      #EdPosBiasHi
                    std       >vModeEast
                    rts
* TblSpeedControlEffect: 10-byte curve vs airspeed (125,125,125,100,75,50,25,25,25,25), probably aileron/roll effectiveness
TblSpeedControlEffect               fcc       /}}}dK2/
                    fcb       $19,$19,$19,$19
* ComputeAerodynamics: flight model forces (skipped in slew mode): attitude trig, angle of attack, lift, drag, roll, stall warning, airspeed and pitch update
ComputeAerodynamics               lda       >vSlew
                    beq       ComputeAeroForces
                    rts
* ComputeAeroForces: aerodynamics: compute sines/cosines and control terms
ComputeAeroForces               ldd       >vPathPitch
                    jsr       >Sin16+ModBase
                    std       >vSinPathPitch
                    lda       >vPathPitch
                    jsr       >Cos8+ModBase
                    std       >vCosPathPitch
                    ldd       >vBankAngle
                    jsr       >Sin16+ModBase
                    std       >vSinBank
                    lda       >vBankAngle
                    jsr       >Cos8+ModBase
                    std       >vCosBank
                    std       >vCosBankLift
                    ldx       #vRudderSpdCurve
                    jsr       >InterpBySpeed+ModBase
                    ldb       >vRudder
                    jsr       >MulSigned8+ModBase
                    std       >vRudderBySpeed
                    ldx       #vElevSpdCurve
                    jsr       >InterpBySpeed+ModBase
                    ldd       >vElevator
                    jsr       >MulQ15+ModBase
                    std       >vAngleOfAttack
                    std       <vMulA
                    ldd       >vAoALiftK
                    jsr       >MulQ15+ModBase
                    std       >vAoALift
                    ldx       #TblSpeedControlEffect+ModBase
                    jsr       >InterpBySpeed+ModBase
                    std       <vSpdCtlEffect
                    ldd       <vSpdCtlEffect
                    std       <vMulA
                    ldd       >vWingCoefL
                    jsr       >MulQ15+ModBase
                    addd      >vAoALift
                    std       >vLiftCoefL
                    lda       >vWarDowned
                    beq       ComputeAeroRightLift
                    clra
                    clrb
                    std       >vLiftCoefL
* ComputeAeroRightLift: aerodynamics: second wing lift term $07C7
ComputeAeroRightLift               ldd       <vSpdCtlEffect
                    std       <vMulA
                    ldd       >vWingCoefR
                    jsr       >MulQ15+ModBase
                    addd      >vAoALift
                    std       >vLiftCoefR
                    lda       >vAngleOfAttack
                    bmi       ComputeAeroNegAoA
* WildBits (2026-10-20): FS's CoCo panel stall lamp (nine stores at the panel screen $0CD3) is gone: the dash's stall
* light reads $074B itself; its bytes zero so no FS address moves
                    bra       ComputeAeroStallChk
                    zmb       45
ComputeAeroStallChk               cmpa      #StallAoAMax
                    blo       ComputeAeroNoStall
* ComputeAeroSetStall: aerodynamics: stalled, set stall counters $089D=15 and $0898=6
ComputeAeroSetStall               ldb       #StallNoLiftInit
                    stb       >vStallNoLift
                    ldb       #StallTimeInit
                    stb       >vStallTime
                    bra       ComputeAeroLift
* ComputeAeroNegAoA: aerodynamics: negative angle of attack, stall below $E7
ComputeAeroNegAoA               cmpa      #StallAoAMin
                    blo       ComputeAeroSetStall
* ComputeAeroNoStall: aerodynamics: no stall
ComputeAeroNoStall               ldb       #StallNone
* ComputeAeroLift: aerodynamics: dynamic pressure (airspeed squared) times lift terms
ComputeAeroLift               ldd       >vAirspeed
                    std       <vMulA
                    jsr       >MulQ15+ModBase
                    std       >vDynPress
                    std       <vMulA
                    ldd       >vLiftCoefL
                    jsr       >MulQ15+ModBase
                    aslb
                    rola
                    aslb
                    rola
                    std       >vLiftL
                    ldd       >vDynPress
                    std       <vMulA
                    ldd       >vLiftCoefR
                    jsr       >MulQ15+ModBase
                    aslb
                    rola
                    aslb
                    rola
                    std       >vLiftR
                    clra
                    ldb       <vAlt+2
                    subb      #GndEffectHeight
                    ldb       <vAlt+1
                    sbcb      #GndEffectHeightHi
                    bpl       ComputeAeroGroundEffect
                    lda       #GndEffectLift
* ComputeAeroGroundEffect: aerodynamics: lift total with extra term below altitude $14 (probably ground effect)
ComputeAeroGroundEffect               pshs      a
                    ldd       >vLiftR
                    addd      >vLiftL
                    std       <vMulA
                    ldd       >vAirDensity
                    jsr       >MulQ15Store+ModBase
                    puls      a
                    adda      >vLiftScale
                    ldb       >vLiftScale+1
                    jsr       >MulQ15+ModBase
                    std       >vLift
                    lda       >vStallNoLift
                    beq       ComputeAeroDrag
                    dec       >vStallNoLift
                    clra
                    clrb
                    std       >vLift
* ComputeAeroDrag: aerodynamics: drag and force terms
ComputeAeroDrag               ldd       >vSinPathPitch
                    std       <vMulA
                    ldd       >vWeight
                    jsr       >MulQ15+ModBase
                    std       >vWeightAlong
                    ldd       >vCosPathPitch
                    std       <vMulA
                    ldd       >vWeight
                    jsr       >MulQ15+ModBase
                    std       >vWeightNormal
                    ldd       >vLift
                    std       <vMulA
                    ldd       >vCosBankLift
                    jsr       >MulQ15+ModBase
                    subd      >vWeightNormal
                    std       >vNetLift
                    ldd       >vLiftCoefL
                    std       <vMulA
                    jsr       >MulQ15+ModBase
                    std       >vLiftCoefLSq
                    ldd       >vLiftCoefR
                    std       <vMulA
                    jsr       >MulQ15+ModBase
                    std       >vLiftCoefRSq
                    addb      >vLiftCoefLSq
                    bhs       ComputeAeroDragSum
                    inca
                    andcc     #NotCarry
* ComputeAeroDragSum: aerodynamics: sum drag terms
ComputeAeroDragSum               addd      >vSlipDrag
                    adca      >vLiftCoefLSq
                    adda      >vFlapDrag
                    std       <vMulA
                    ldd       >vDragSumK
                    jsr       >MulQ15+ModBase
                    addd      >vDragBaseK
                    std       <vMulA
                    ldd       >vDynPress
                    jsr       >MulQ15Store+ModBase
                    ldd       >vAirDensity
                    jsr       >MulQ15+ModBase
                    addd      >vWeightAlong
                    std       >vDrag
                    ldd       >vAirspeed
                    beq       ComputeAeroThrust
                    lda       >vDrag+1
                    adda      >vDragFixedK
                    sta       >vDrag+1
                    bhs       ComputeAeroThrust
                    inc       >vDrag
* ComputeAeroThrust: aerodynamics: net longitudinal force $0777 and its scaled term $0771
ComputeAeroThrust               ldd       >vThrust
                    subd      >vDrag
                    std       >vNetThrust
                    std       <vMulA
                    ldd       >vAccelK
                    jsr       >MulQ15+ModBase
                    std       >vAccel
                    ldx       #vTurnSpdCurve
                    jsr       >InterpBySpeed+ModBase
                    ldd       >vSinBank
                    jsr       >MulQ15Store+ModBase
                    ldd       >vLift
                    jsr       >MulQ15Times4+ModBase
                    tst       >vOnGnd
                    bne       ComputeAeroPitchRate
                    addd      >vSlipTurn
* ComputeAeroPitchRate: aerodynamics: store pitch rate term $076D
ComputeAeroPitchRate               std       >vTurnRate
* WildBits (taxi mode, 2026-10-19): the ground turn rate in fsw (fswc's TaxiYaw); FS's 22 bytes kept as 22
                    jsr       >FswTaxiYaw
                    bra       ComputeAeroPitchMoment
                    zmb       17
* ComputeAeroPitchMoment: aerodynamics: pitch change $0769 (full when stalled, half otherwise)
ComputeAeroPitchMoment               ldx       #vPitchSpdCurve
                    jsr       >InterpBySpeed+ModBase
                    lda       >vStallTime
                    beq       ComputeAeroHalfRate
                    ldd       >vNetLift
                    bra       ComputeAeroStorePitch
* ComputeAeroHalfRate: aerodynamics: not stalled, halve the pitch term
ComputeAeroHalfRate               ldd       >vNetLift
                    asra
                    rorb
* ComputeAeroStorePitch: aerodynamics: scale and store pitch change $0769 (none nose-down on the ground)
ComputeAeroStorePitch               jsr       >MulQ15+ModBase
                    std       >vPitchRate
                    ldb       >vOnGnd
                    beq       ComputeAeroSpeed
                    tsta
                    bpl       ComputeAeroSpeed
                    clrb
                    clra
                    std       >vPitchRate
* ComputeAeroSpeed: aerodynamics: compute airspeed change
ComputeAeroSpeed               ldd       #PitchToSpeed
                    std       <vMulA
                    ldd       >vPitchRate
                    jsr       >MulQ15+ModBase
                    addd      >vAccel
                    tst       >vStallTime
                    beq       ComputeAeroAddSpeed
                    ldd       >vAccel
* ComputeAeroAddSpeed: aerodynamics: add the change to airspeed $07BB
* WildBits (taxi mode, 2026-10-19): D = the step -> D = the new airspeed in fsw (fswc's TaxiSpd: in the air
* FS's own add and clamps; on the ground the taxi mode); FS's 12 bytes kept as 12
ComputeAeroAddSpeed               jsr       >FswTaxiSpd
                    nop
                    nop
                    nop
                    nop
                    nop
                    nop
                    nop
                    nop
                    nop
* ComputeAeroStoreSpeed: aerodynamics: store airspeed, add pitch change to pitch $074D
ComputeAeroStoreSpeed               std       >vAirspeed
                    ldd       >vPathPitch
                    addd      >vPitchRate
                    std       >vPathPitch
                    bpl       FoldFlightPitch
                    jsr       >NegateFlightPitch+ModBase
                    jsr       >FoldFlightPitch+ModBase
* NegateFlightPitch: negate aircraft pitch $074D
NegateFlightPitch               ldd       >vPathPitch
                    coma
                    comb
                    addd      #NegCarry
                    std       >vPathPitch
                    rts
* FoldFlightPitch: aircraft pitch past vertical: mirror it and flip bank $074F and heading $0783
FoldFlightPitch               ldd       >vPathPitch
                    cmpa      #Angle8Quarter
                    blo       FoldFlightPitchDone
                    coma
                    comb
                    addd      #NegCarry
                    eora      #Angle8Half
                    std       >vPathPitch
                    lda       >vBankAngle
                    eora      #Angle8Half
                    sta       >vBankAngle
                    lda       >vHdgCopy+1
                    eora      #Angle8Half
                    sta       >vHdgCopy+1
* FoldFlightPitchDone: fold pitch: return
FoldFlightPitchDone               rts
* MulQ15Times4: Q15 multiply D * <$AF then times 4
MulQ15Times4               jsr       >MulQ15+ModBase
                    aslb
                    rola
                    aslb
                    rola
                    rts
* UpdateFlightPhysics: normal flight: read elapsed time from /FTDD (I$GetStt $80) as time step $077C, integrate heading, bank, position (X, altitude, Z), set view attitude <$12/<$14/<$16, ground contact and crash checks
UpdateFlightPhysics               lda       #SlewEntrySet
                    sta       >vSlewEntry
                    lda       >vFtddPath
                    ldb       #SS.VCtr
                    os9       I$GetStt
                    tfr       y,d
                    tfr       b,a
                    clrb
                    std       <vMulA
                    ldd       #TickQ15
                    jsr       >MulU16Mid+ModBase
                    tsta
                    bpl       UpdateFlightTimeStep
                    lda       #TimeStepMaxHi
* UpdateFlightTimeStep: flight physics: store time step, integrate heading $0782
UpdateFlightTimeStep               std       >vTimeStep
                    std       <vMulA
                    ldd       >vTurnRate
                    jsr       >MulQ15+ModBase
                    addd      >vHdgCopy
                    std       >vHdgCopy
                    ldd       >vTimeStep
                    std       <vMulA
                    ldd       >vAirspeed
                    jsr       >MulQ15+ModBase
                    std       >vStepDist
                    ldd       >vTrackOfs
                    tst       >vOnGnd
                    beq       UpdateFlightVelocity
                    ldd       #GndTrackOfs
* UpdateFlightVelocity: flight physics: velocity components from heading and pitch
UpdateFlightVelocity               addd      >vHdgCopy
                    sta       <vTrackHdg
                    jsr       >Sin8+ModBase
                    std       >vSinTrack
                    lda       <vTrackHdg
                    jsr       >Cos8+ModBase
                    std       >vCosTrack
                    ldd       >vCosPathPitch
                    std       <vMulA
                    ldd       >vStepDist
                    jsr       >MulQ15+ModBase
                    std       >vStepHoriz
                    std       <vMulA
                    ldd       >vSinTrack
                    jsr       >MulQ15+ModBase
                    std       >vStepX
                    ldd       >vSinPathPitch
                    std       <vMulA
                    ldd       >vStepDist
                    jsr       >MulQ15+ModBase
                    std       >vStepAlt
                    ldd       >vCosTrack
                    std       <vMulA
                    ldd       >vStepHoriz
                    jsr       >MulQ15+ModBase
                    std       >vStepZ
                    ldd       >vLiftL
                    subd      >vLiftR
                    aslb
                    rola
                    aslb
                    rola
                    std       >vLiftDiff
                    std       <vMulA
                    ldd       >vRollK
                    jsr       >MulQ15+ModBase
                    subd      >vRollCancel
                    std       >vRollRate
                    ldd       >vRollCancel
                    beq       UpdateFlightPosition
                    clra
                    clrb
                    std       >vRollCancel
                    incb
                    stb       >vSkipPresent
* UpdateFlightPosition: flight physics: integrate bank, then add the velocity to Z, X and altitude
UpdateFlightPosition               ldd       >vStepDist
                    std       <vMulA
                    ldd       >vRollRate
                    jsr       >MulQ15+ModBase
                    aslb
                    rola
                    addd      >vBankAngle
                    std       >vBankAngle
                    ldb       >vStepZ+1
                    addb      <vPosZ+3
                    stb       <vPosZ+3
                    ldb       >vStepZ
                    sex
                    adcb      <vPosZ+2
                    stb       <vPosZ+2
                    tfr       a,b
                    adcb      <vPosZ+1
                    stb       <vPosZ+1
                    adca      <vPosZ
                    sta       <vPosZ
                    ldb       >vStepX+1
                    addb      <vPosX+3
                    stb       <vPosX+3
                    ldb       >vStepX
                    sex
                    adcb      <vPosX+2
                    stb       <vPosX+2
                    tfr       a,b
                    adcb      <vPosX+1
                    stb       <vPosX+1
                    adca      <vPosX
                    sta       <vPosX
                    ldb       >vStepAlt+1
                    addb      <vAlt+3
                    stb       <vAlt+3
                    ldb       >vStepAlt
                    sex
                    adcb      <vAlt+2
                    stb       <vAlt+2
                    adca      <vAlt+1
                    sta       <vAlt+1
                    bpl       UpdateFlightAltClamped
                    clra
                    sta       <vAlt+1
                    sta       <vAlt+2
                    lda       #AltClampLo
                    sta       <vAlt+3
* UpdateFlightAltClamped: flight physics: altitude clamped at ground; count down $07F2 via SetHeightFromTerrain
UpdateFlightAltClamped               lda       >vGroundSettle
                    beq       UpdateFlightAttitude
                    jsr       >SetHeightFromTerrain+ModBase
                    dec       >vGroundSettle
* UpdateFlightAttitude: flight physics: compute the displayed pitch <$12
UpdateFlightAttitude               ldd       >vAngleOfAttack
                    std       <vMulA
                    ldd       >vAoAPitchK
                    jsr       >MulQ15+ModBase
                    subd      >vPathPitch
                    pshs      a,b
                    tst       >vViewDir
                    bne       UpdateFlightPitchOut
                    adda      #FwdViewPitch
* UpdateFlightPitchOut: flight physics: add the on-ground pitch offset unless on the ground
UpdateFlightPitchOut               puls      a,b
                    tst       >vOnGnd
                    bne       UpdateFlightAttStore
                    addd      >vAirPitchOfs
* UpdateFlightAttStore: flight physics: store pitch, bank and heading to <$12/<$14/<$16
UpdateFlightAttStore               adda      >vTouchBump
                    std       <vPitch
                    clr       >vTouchBump
                    ldd       >vBankAngle
                    coma
                    comb
                    addd      #NegCarry
                    std       <vBank
                    ldd       >vHdgCopy
                    std       <vHdg
                    clrb
                    lda       <vAlt+3
                    suba      #GndHeightLo
                    lda       <vAlt+2
                    sbca      #GndHeightMid
                    lda       <vAlt+1
                    sbca      #GndHeightHi
                    bpl       UpdateFlightGround
                    decb
* UpdateFlightGround: flight physics: set on-ground flag $0781 from altitude
UpdateFlightGround               stb       >vOnGnd
                    tstb
                    beq       UpdateFlightAirborne
                    clra
                    clrb
                    std       >vBankAngle
                    std       >vRollRate
                    tst       >vPathPitch
                    bpl       UpdateFlightOnGround
                    std       >vPathPitch
* UpdateFlightOnGround: flight physics: on the ground, zero bank and nose-down pitch
UpdateFlightOnGround               lda       >vGroundSettle
                    beq       UpdateFlightLandCheck
                    jsr       >JoyButtonAction+ModBase
                    bra       UpdateFlightTouchdown
* UpdateFlightLandCheck: flight physics: check sink rate and bank on touchdown, crash ($0137=4) if bad
UpdateFlightLandCheck               ldb       #CrashLanding
                    lda       >vVertSpeed
                    bpl       UpdateFlightTouchdown
                    adda      #LandSinkMax
                    bmi       UpdateFlightCrash
                    lda       <vBank
                    adda      #LandBankMax
                    cmpa      #LandBankSpan
                    blo       UpdateFlightTouchdown
* UpdateFlightCrash: flight physics: crash on landing, set $0137=4, zero airspeed
UpdateFlightCrash               stb       >vCrash
                    clra
                    sta       >vAirspeed
* UpdateFlightTouchdown: flight physics: first contact with the ground, record vertical speed
UpdateFlightTouchdown               clrb
                    lda       >vAltBand
                    bne       UpdateFlightTouchStore
                    dec       >vAltBand
                    ldb       >vVertSpeed
* UpdateFlightTouchStore: flight physics: store touchdown term $079E
UpdateFlightTouchStore               stb       >vTouchBump
                    bra       UpdateFlightVertSpeed
* UpdateFlightAirborne: flight physics: airborne, note the change of ground state
UpdateFlightAirborne               cmpa      >vAltBand
                    beq       UpdateFlightVertSpeed
                    sta       >vAltBand
                    ldb       <vPosZ+2
                    andb      #AltimErrOddsMask
                    bne       UpdateFlightVertSpeed
                    addb      <vFrameCount
                    sex
                    std       >vAltimErrGoal
* UpdateFlightVertSpeed: flight physics: vertical speed $07BF = airspeed times sin of pitch
UpdateFlightVertSpeed               ldd       >vAirspeed
                    std       <vMulA
                    ldd       >vSinPathPitch
                    jsr       >MulQ15+ModBase
                    std       >vVertSpeed
* FlightAuxReturn: shared rts (flight physics end, FlightAuxUpdate in slew mode)
FlightAuxReturn               rts
* FlightAuxUpdate: periodic flight update (not in slew mode): air density factor $0749 from $0132, roll self-centering when $082B is 0, handle request $013B
FlightAuxUpdate               lda       >vSlew
                    bne       FlightAuxReturn
                    ldd       >vAltMsl
                    aslb
                    rola
                    std       <vDensityDrop
                    rora
                    rorb
                    lsra
                    rorb
                    addd      <vDensityDrop
                    std       <vDensityDrop
                    ldd       #AirDensitySea
                    subd      <vDensityDrop
                    std       >vAirDensity
                    lda       >vRudder
                    bne       FlightAuxRequest
                    ldd       >vBankAngle
                    bmi       FlightAuxBankNeg
                    addd      #BankCenterDec
                    bmi       FlightAuxBankZero
                    bra       FlightAuxBankStore
* FlightAuxBankNeg: roll centering: negative bank, add $28
FlightAuxBankNeg               addd      #BankCenterInc
                    bmi       FlightAuxBankStore
* FlightAuxBankZero: roll centering: crossed zero, bank = 0
FlightAuxBankZero               clra
                    clrb
* FlightAuxBankStore: roll centering: store bank $074F
FlightAuxBankStore               std       >vBankAngle
* FlightAuxRequest: periodic flight update: handle request flag $013B (reset state when stopped)
FlightAuxRequest               lda       >vService
                    beq       FlightAuxDone
                    lda       >vAirspeed
                    bne       FlightAuxRequestClr
                    jsr       >ResetFlightState+ModBase
                    lda       >vService
                    cmpa      #ServiceRearm
                    bne       FlightAuxRequestClr
                    lda       #AmmoFull
                    sta       >vAmmo
                    lda       #BombsFull
                    sta       >vBombsLeft
* FlightAuxRequestClr: periodic flight update: clear request flag $013B
FlightAuxRequestClr               clra
                    sta       >vService
* FlightAuxDone: periodic flight update: return
FlightAuxDone               rts
* ResetFlightState: reset several flight/instrument state variables ($0731, $0734, $02AE, $0233, $0209, $072E, $0736, $0737, $020A), probably at engine start or reset
ResetFlightState               lda       #FuelFull
                    sta       >vFuelL
                    sta       >vFuelR
                    ldd       #InstAllBits
                    std       >vInstWork
                    std       >vInstLit
                    incb
                    stb       >vWarDamage
                    stb       >vDamageBits
                    incb
                    stb       >vMag2Ok
                    stb       >vMag1Ok
                    stb       >vWarEnemyInit
                    rts
* UpdateStallTimer: count down stall timer $0898, or set it to 6 when pitch, bank or airspeed is outside the normal envelope
UpdateStallTimer               ldb       >vStallTime
                    decb
                    bmi       UpdateStallTimerCheck
                    stb       >vStallTime
                    rts
* UpdateStallTimerCheck: stall timer: check pitch, bank and airspeed limits
UpdateStallTimerCheck               lda       >vPathPitch
                    adda      #EnvPitchMax
                    cmpa      #EnvPitchSpan
                    bhs       UpdateStallTimerSet
                    lda       >vBankAngle
                    adda      #EnvBankMax
                    cmpa      #EnvBankSpan
                    bhs       UpdateStallTimerSet
                    lda       >vAirspeed
                    adda      #EnvSpeedMax
                    cmpa      #EnvSpeedSpan
                    blo       UpdateStallTimerDone
* UpdateStallTimerSet: stall timer: set $0898=6
UpdateStallTimerSet               lda       #StallTimeInit
                    sta       >vStallTime
* UpdateStallTimerDone: stall timer: return
UpdateStallTimerDone               rts
                    fcb       $FC,$08,$1E,$DD,$AF,$FC,$07,$ED
                    fcb       $BD,$D2,$81,$FD,$07,$94,$8D,$6A
                    fcb       $FC,$08,$1E,$DD,$AF,$FC,$07,$DB
                    fcb       $BD,$D2,$81,$B7,$07,$79,$39
