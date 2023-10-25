* Disassembly by Os9disasm of ccdiv.r

                    section   code

ccudiv              subd      #0
                    beq       L000f
                    pshs      d
                    leas      -2,s
                    clr       ,s
                    clr       1,s
                    bra       L003d
L000f               puls      d
                    std       ,s
                    ldd       #$002d
                    lbra      _rpterr
ccdiv               subd      #0
                    beq       L000f
                    pshs      d
                    leas      -2,s
                    clr       ,s
                    clr       1,s
                    tsta
                    bpl       L0031
                    nega
                    negb
                    sbca      #0
                    com       1,s
                    std       2,s
L0031               ldd       6,s
                    bpl       L003d
                    nega
                    negb
                    sbca      #0
                    com       1,s
                    std       6,s
L003d               lda       #1
L003f               inca
                    asl       3,s
                    rol       2,s
                    bpl       L003f
                    sta       ,s
                    ldd       6,s
                    clr       6,s
                    clr       7,s
L004e               subd      2,s
                    bcc       L0058
                    addd      2,s
                    andcc     #254
                    bra       L005a
L0058               orcc      #1
L005a               rol       7,s
                    rol       6,s
                    lsr       2,s
                    ror       3,s
                    dec       ,s
                    bne       L004e
                    std       2,s
                    tst       1,s
                    beq       L0074
                    ldd       6,s
                    nega
                    negb
                    sbca      #0
                    std       6,s
L0074               ldx       4,s
                    ldd       6,s
                    std       4,s
                    stx       6,s
                    ldx       2,s
                    ldd       4,s
                    leas      6,s
                    rts

                    endsect

