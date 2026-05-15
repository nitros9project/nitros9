RealDiv               comb                          Default to divide by 0 error
                    ldb       #$2D
                    tst       2,y                 Is number to divide by 0?
                    beq       RealDivRts               Yes, return with error
                    pshs      x                   Preserve X
                    tst       8,y                 Is dividend=0?
                    lbeq      RmulZeroResult               Yes, answer=0, return from there
                    lda       7,y                 Get exponent of # to dividend
                    suba      1,y                 Subtract exponent of divisor
                    lbvs      RmulExpError
                    sta       7,y
                    lda       #$21                ??? (count for exponent shifts?)
                    ldb       5,y                 Get sign byte of dividend
                    eorb      $B,y                Calculate which sign result will be
                    andb      #$01                Just keep sign bit
                    std       ,y                  Save ??? & resulting sign
                    lsr       2,y                 Divide whole divisor mantissa by 2
                    ror       3,y
                    ror       4,y
                    ror       5,y
                    ldd       8,y                 Get dividend into D:X
                    ldx       $A,y                Divide whole dividend by 2
                    lsra
                    rorb
                    exg       d,x
                    rora
                    rorb
                    clr       $B,y                Clear last byte of dividend mantissa
                    bra       RdivDoDiv

RdivChkDiv               exg       d,x
RdivDoDiv               subd      4,y
                    exg       d,x
                    bcc       RdivExpNeg
                    subd      #$0001
RdivExpNeg               subd      2,y
                    beq       RdivNextBit
                    bmi       RdivBitSet
RdivSetSign               orcc      #$01
RdivSetSign2               dec       ,y
                    beq       RdivFinish
                    rol       $B,y
                    rol       $A,y
                    rol       9,y
                    rol       8,y
                    exg       d,x
                    lslb
                    rola
                    exg       d,x
                    rolb
                    rola
                    bcc       RdivChkDiv
                    exg       d,x
                    addd      4,y
                    exg       d,x
                    bcc       RdivMainLoop
                    addd      #$0001
RdivMainLoop               addd      2,y
                    beq       RdivNextBit
                    bpl       RdivSetSign
RdivBitSet               andcc     #$FE
                    bra       RdivSetSign2

RdivNextBit               leax      ,x
                    bne       RdivSetSign
                    ldb       ,y
                    decb
                    subb      #$10
                    blt       RdivNormLoop
                    subb      #$08
                    blt       RdivNorm
                    stb       ,y
                    lda       $0B,y
                    ldb       #$80
                    bra       RdivCheckSign

RdivNorm               addb      #$08
                    stb       ,y
                    ldd       #$8000
                    ldx       $0A,y
                    bra       RdivSetNeg

RdivNormLoop               addb      #$08
                    blt       RdivRound
                    stb       ,y
                    ldx       $09,y
                    lda       $0B,y
                    ldb       #$80
                    bra       RdivSetNeg

RdivRound               addb      #$07
                    stb       ,y
                    ldx       $08,y
                    ldd       $0A,y
                    orcc      #$01
RdivSaveResult               rolb
                    rola
                    exg       d,x
                    rolb
                    rola
RdivCheckSign               exg       d,x
RdivSetNeg               andcc     #$FE
                    dec       ,y
                    bpl       RdivSaveResult
                    exg       d,x
                    tsta
                    bra       RdivFpErr

RdivFinish               ldx       $0A,y
                    ldd       8,y
RdivFpErr               bmi       RdivReturn
                    exg       d,x
                    rolb
                    rola
                    exg       d,x
                    rolb
                    rola
                    dec       $07,y
                    lbvs      RmulZeroResult
RdivReturn               exg       d,x
                    addd      #$0001
                    exg       d,x
                    bcc       RdivShiftMant
                    addd      #$0001
                    bcc       RdivShiftMant
                    rora
                    inc       7,y
                    lbvs      RmulExpError
RdivShiftMant               std       8,y
                    tfr       x,d
                    andb      #$FE                Mask out sign bit
                    orb       1,y
                    std       $A,y
                    inc       7,y
                    lbvs      RmulExpError
RdivShiftDone               leay      6,y                 Eat temp var
                    clrb                          No error
                    puls      pc,x                Restore X & return
