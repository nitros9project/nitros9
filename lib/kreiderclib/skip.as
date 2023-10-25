* Disassembly by Os9disasm of skip.r

                    section   code

skipbl              ldx       2,s
L0002               ldb       ,x+
                    cmpb      #$20
                    beq       L0002
                    cmpb      #9
                    beq       L0002
                    bra       L001c
skipwd              ldx       2,s
L0010               ldb       ,x+
                    beq       L001c
                    cmpb      #$20
                    beq       L001c
                    cmpb      #9
                    bne       L0010
L001c               leax      -1,x
                    tfr       x,d
                    rts

                    endsect

