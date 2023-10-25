* Disassembly by Os9disasm of htol.r

                    section   code

htol                pshs      y,u
                    leax      _flacc,y
                    leay      _chcodes,y
                    ldu       6,s
                    clra
                    clrb
                    std       ,x
                    std       2,x
L0012               ldb       ,u
                    cmpb      #$20
                    beq       L001c
                    cmpb      #9
                    bne       L004e
L001c               leau      1,u
                    bra       L0012
L0020               lda       #4
L0022               asl       3,x
                    rol       2,x
                    rol       1,x
                    rol       ,x
                    deca
                    bne       L0022
                    ldb       ,u+
                    subb      #$30
                    cmpb      #9
                    ble       L003d
                    subb      #7
                    cmpb      #$0f
                    ble       L003d
                    subb      #$20
L003d               andcc     #254
                    lda       #3
                    bra       L0045
L0043               ldb       #0
L0045               adcb      a,x
                    stb       a,x
                    deca
                    bpl       L0043
                    ldb       ,u
L004e               ldb       b,y
                    andb      #$40
                    bne       L0020
                    puls      y,u,pc

                    endsect

