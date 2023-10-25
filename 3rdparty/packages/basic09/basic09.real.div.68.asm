L4234               comb                          Default to divide by 0 error
                    ldb       #$2D
                    tst       2,y                 Is number to divide by 0?
                    beq       L4233               Yes, return with error
                    pshs      x                   Preserve X
                    tst       8,y                 Is dividend=0?
                    lbeq      L40DD               Yes, answer=0, return from there
                    lda       7,y                 Get exponent of # to dividend
                    suba      1,y                 Subtract exponent of divisor
                    lbvs      L40EF
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
                    bra       L426F

L426D               exg       d,x
L426F               subd      4,y
                    exg       d,x
                    bcc       L4278
                    subd      #$0001
L4278               subd      2,y
                    beq       L42AB
                    bmi       L42A7
L427E               orcc      #$01
L4280               dec       ,y
                    beq       L42F8
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
                    bcc       L426D
                    exg       d,x
                    addd      4,y
                    exg       d,x
                    bcc       L42A1
                    addd      #$0001
L42A1               addd      2,y
                    beq       L42AB
                    bpl       L427E
L42A7               andcc     #$FE
                    bra       L4280

L42AB               leax      ,x
                    bne       L427E
                    ldb       ,y
                    decb
                    subb      #$10
                    blt       L42CD
                    subb      #$08
                    blt       L42C2
                    stb       ,y
                    lda       $0B,y
                    ldb       #$80
                    bra       L42EB

L42C2               addb      #$08
                    stb       ,y
                    ldd       #$8000
                    ldx       $0A,y
                    bra       L42ED

L42CD               addb      #$08
                    blt       L42DB
                    stb       ,y
                    ldx       $09,y
                    lda       $0B,y
                    ldb       #$80
                    bra       L42ED

L42DB               addb      #$07
                    stb       ,y
                    ldx       $08,y
                    ldd       $0A,y
                    orcc      #$01
L42E5               rolb
                    rola
                    exg       d,x
                    rolb
                    rola
L42EB               exg       d,x
L42ED               andcc     #$FE
                    dec       ,y
                    bpl       L42E5
                    exg       d,x
                    tsta
                    bra       L42FC

L42F8               ldx       $0A,y
                    ldd       8,y
L42FC               bmi       L430C
                    exg       d,x
                    rolb
                    rola
                    exg       d,x
                    rolb
                    rola
                    dec       $07,y
                    lbvs      L40DD
L430C               exg       d,x
                    addd      #$0001
                    exg       d,x
                    bcc       L4321
                    addd      #$0001
                    bcc       L4321
                    rora
                    inc       7,y
                    lbvs      L40EF
L4321               std       8,y
                    tfr       x,d
                    andb      #$FE                Mask out sign bit
                    orb       1,y
                    std       $A,y
                    inc       7,y
                    lbvs      L40EF
L4331               leay      6,y                 Eat temp var
                    clrb                          No error
                    puls      pc,x                Restore X & return
