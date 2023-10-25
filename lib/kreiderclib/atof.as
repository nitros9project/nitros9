* Disassembly by Os9disasm of atof.r

                    section   code

atof                pshs      u
                    ldu       4,s
                    ldb       #$10
                    clra
L0007               pshs      a
                    decb
                    bne       L0007
L000c               ldb       ,u+
                    cmpb      #$20
                    beq       L000c
                    cmpb      #9
                    beq       L000c
                    cmpb      #$2d
                    bne       L001e
                    inc       4,s
                    bra       L002a
L001e               cmpb      #$2b
                    beq       L002a
                    bra       L002c
L0024               sex
                    leax      8,s
                    lbsr      L00e4
L002a               ldb       ,u+
L002c               cmpb      #$30
                    blt       L0034
                    cmpb      #$39
                    ble       L0024
L0034               cmpb      #$2e
                    beq       L0042
                    bra       L004c
L003a               sex
                    leax      8,s
                    lbsr      L00e4
                    inc       1,s
L0042               ldb       ,u+
                    cmpb      #$30
                    blt       L004c
                    cmpb      #$39
                    ble       L003a
L004c               leax      8,s
                    ldb       #$b8
                    stb       7,x
                    pshs      x
                    pshs      x
                    lbsr      _dnorm
                    leas      2,s
                    lbsr      _dmove
                    ldb       -1,u
                    cmpb      #$65
                    beq       L0068
                    cmpb      #$45
                    bne       L00a1
L0068               inc       2,s
                    ldb       ,u+
                    cmpb      #$2b
                    beq       L0089
                    cmpb      #$2d
                    bne       L008b
                    clr       2,s
                    bra       L0089
L0078               sex
                    pshs      d
                    ldd       8,s
                    pshs      d
                    ldd       #$000a
                    lbsr      ccmult
                    addd      ,s++
                    std       6,s
L0089               ldb       ,u+
L008b               subb      #$30
                    bcs       L0093
                    cmpb      #9
                    ble       L0078
L0093               ldd       6,s
                    tst       2,s
                    beq       L009d
                    nega
                    negb
                    sbca      #0
L009d               addd      ,s
                    std       ,s
L00a1               clr       2,s
                    ldd       ,s
                    bge       L00b2
                    nega
                    negb
                    sbca      #0
                    std       ,s
                    ldd       #1
                    std       2,s
L00b2               leax      8,s
                    ldd       2,s
                    pshs      d,x
                    ldd       4,s
                    pshs      d
                    leax      14,s
                    lbsr      _dstack
                    lbsr      scale
                    leas      12,s
                    lbsr      _dmove
                    ldd       4,s
                    beq       L00d4
                    leax      8,s
                    lbsr      _dneg
                    bra       L00d6
L00d4               leax      8,s
L00d6               leau      _flacc,y
                    pshs      u
                    lbsr      _dmove
                    leas      16,s
                    puls      u,pc
L00e4               pshs      d
                    leas      -8,s
                    ldd       5,x
                    lslb
                    rola
                    std       5,x
                    std       5,s
                    ldd       3,x
                    rolb
                    rola
                    std       3,x
                    std       3,s
                    ldd       1,x
                    rolb
                    rola
                    std       1,x
                    std       1,s
                    lda       ,x
                    rola
                    sta       ,x
                    sta       ,s
                    asl       6,x
                    rol       5,x
                    rol       4,x
                    rol       3,x
                    rol       2,x
                    rol       1,x
                    rol       ,x
                    asl       6,x
                    rol       5,x
                    rol       4,x
                    rol       3,x
                    rol       2,x
                    rol       1,x
                    rol       ,x
                    ldd       5,x
                    addd      5,s
                    std       5,x
                    ldd       3,x
                    adcb      4,s
                    adca      3,s
                    std       3,x
                    ldd       1,x
                    adcb      2,s
                    adca      1,s
                    std       1,x
                    ldb       ,x
                    adcb      ,s
                    stb       ,x
                    ldd       8,s
                    andb      #$0f
                    addd      5,x
                    std       5,x
                    ldd       #0
                    adcb      4,x
                    adca      3,x
                    std       3,x
                    ldd       #0
                    adcb      2,x
                    adca      1,x
                    std       1,x
                    lda       #0
                    adca      ,x
                    sta       ,x
                    leas      10,s
                    rts

                    endsect

