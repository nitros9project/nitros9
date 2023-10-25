* Disassembly by Os9disasm of memccpy.r

                    section   code

memccpy             pshs      y,u
                    ldu       8,s
                    ldx       6,s
                    ldy       12,s
                    beq       L001b
L000b               lda       ,u+
                    sta       ,x+
                    cmpa      11,s
                    bne       L0017
                    tfr       u,d
                    bra       L001d
L0017               leay      -1,y
                    bne       L000b
L001b               tfr       y,d
L001d               puls      y,u,pc

                    endsect

