* Disassembly by Os9disasm of strass.r

                    section   code

_strass             pshs      y,u
                    ldu       6,s
                    ldy       8,s
                    ldd       10,s
                    lsra
                    rorb
                    tfr       d,x
                    bcc       L0013
                    lda       ,y+
                    sta       ,u+
L0013               stx       -2,s
                    beq       L001f
L0017               ldd       ,y++
                    std       ,u++
                    leax      -1,x
                    bne       L0017
L001f               puls      y,u,pc

                    endsect

