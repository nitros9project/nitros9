* Did mods as per Chris Dekker's RUNB
RealDiv               comb                          Default to divide by 0 error
                    ldb       #$2D
                    tst       2,y                 Is number to divide by 0?
                    beq       RealDivRts               Yes, return with error
                    tst       8,y                 Is dividend=0?
                    lbeq      RmulZeroResult               Yes, answer=0, return from there
                    lda       7,y                 Get exponent of # to dividend
                    suba      1,y                 Subtract exponent of divisor
                    lbvs      RmulExpError
                    sta       7,y
                    lda       #$21                ??? (count for exponent shifts?)
                    ldb       5,y                 Get sign byte of dividend
                    eorb      $B,y                Calculate which sign result will be
                    andb      #1                  Just keep sign bit
                    std       ,y                  Save ??? & resulting sign
                    ldq       2,y                 Divide whole divisor mantissa by 2
                    lsrd                          /
                    rorw                          < these both eat sign bit and make mantissa a
                    stq       2,y                 \ 31 bit number
                    ldq       8,y                 Divide whole dividend by 2
                    lsrd
                    rorw
                    clr       $B,y                Clear last byte of dividend mantissa
RdivDoDiv               subw      4,y                 Subtract divisor from dividend
                    sbcd      2,y
                    beq       RdivNextBit
                    bmi       RdivBitSet
RdivSetSign               orcc      #1
RdivSetSign2               dec       ,y
                    beq       RdivFinish
                    rol       $B,y
                    rol       $A,y
                    rol       9,y
                    rol       8,y
                    andcc     #$fe
                    rolw
                    rold
                    bcc       RdivDoDiv
                    addw      4,y
                    adcd      2,y
                    beq       RdivNextBit
                    bpl       RdivSetSign
RdivBitSet               andcc     #$FE
                    bra       RdivSetSign2

RdivNextBit               tstw
                    bne       RdivSetSign
                    ldb       ,y
                    decb
                    subb      #$10
                    blt       RdivNormLoop
                    subb      #$08
                    blt       RdivNorm
                    stb       ,y
                    lda       $B,y
                    ldb       #$80
                    andcc     #$fe
                    bra       RdivCheckSign

RdivNorm               addb      #$08
                    stb       ,y
                    ldw       #$8000
                    ldd       $A,y
                    andcc     #$fe
                    bra       RdivCheckSign

RdivNormLoop               addb      #$08
                    blt       RdivRound
                    stb       ,y
                    ldq       9,y
                    ldf       #$80
                    andcc     #$fe
                    bra       RdivCheckSign

RdivRound               addb      #$07
                    stb       ,y
                    ldq       8,y
                    orcc      #$01
RdivSaveResult               rolw
                    rold
RdivCheckSign               dec       ,y
                    bpl       RdivSaveResult
                    tsta
                    bra       RdivFpErr

RdivFinish               ldq       8,y
RdivFpErr               bmi       RdivReturn
                    rolw
                    rold
                    dec       7,y
                    lbvs      RmulZeroResult
RdivReturn               addw      #1
                    adcd      #0
                    bcc       RdivShiftMant
                    rora
                    inc       7,y
                    lbvs      RmulZeroResult
RdivShiftMant               std       8,y
                    tfr       w,d
                    lsrb                          Shift out sign bit
                    lslb
                    orb       1,y                 Merge in result's sign
                    std       $A,y
                    inc       7,y
                    lbvs      RmulExpError
RdivShiftDone               leay      6,y                 Eat temp var
                    rts                           & return

