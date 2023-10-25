* Did mods as per Chris Dekker's RUNB
L4234               comb                          Default to divide by 0 error
                    ldb       #$2D
                    tst       2,y                 Is number to divide by 0?
                    beq       L4233               Yes, return with error
                    tst       8,y                 Is dividend=0?
                    lbeq      L40DD               Yes, answer=0, return from there
                    lda       7,y                 Get exponent of # to dividend
                    suba      1,y                 Subtract exponent of divisor
                    lbvs      L40EF
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
L426F               subw      4,y                 Subtract divisor from dividend
                    sbcd      2,y
                    beq       L42AB
                    bmi       L42A7
L427E               orcc      #1
L4280               dec       ,y
                    beq       L42F8
                    rol       $B,y
                    rol       $A,y
                    rol       9,y
                    rol       8,y
                    andcc     #$fe
                    rolw
                    rold
                    bcc       L426F
                    addw      4,y
                    adcd      2,y
                    beq       L42AB
                    bpl       L427E
L42A7               andcc     #$FE
                    bra       L4280

L42AB               tstw
                    bne       L427E
                    ldb       ,y
                    decb
                    subb      #$10
                    blt       L42CD
                    subb      #$08
                    blt       L42C2
                    stb       ,y
                    lda       $B,y
                    ldb       #$80
                    andcc     #$fe
                    bra       L42EB

L42C2               addb      #$08
                    stb       ,y
                    ldw       #$8000
                    ldd       $A,y
                    andcc     #$fe
                    bra       L42EB

L42CD               addb      #$08
                    blt       L42DB
                    stb       ,y
                    ldq       9,y
                    ldf       #$80
                    andcc     #$fe
                    bra       L42EB

L42DB               addb      #$07
                    stb       ,y
                    ldq       8,y
                    orcc      #$01
L42E5               rolw
                    rold
L42EB               dec       ,y
                    bpl       L42E5
                    tsta
                    bra       L42FC

L42F8               ldq       8,y
L42FC               bmi       L430C
                    rolw
                    rold
                    dec       7,y
                    lbvs      L40DD
L430C               addw      #1
                    adcd      #0
                    bcc       L4321
                    rora
                    inc       7,y
                    lbvs      L40DD
L4321               std       8,y
                    tfr       w,d
                    lsrb                          Shift out sign bit
                    lslb
                    orb       1,y                 Merge in result's sign
                    std       $A,y
                    inc       7,y
                    lbvs      L40EF
L4331               leay      6,y                 Eat temp var
                    rts                           & return

