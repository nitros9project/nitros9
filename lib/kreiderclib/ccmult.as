* Disassembly by Os9disasm of ccmult.r

                    section   code

ccmult              tsta
                    bne       L0015
                    tst       2,s
                    bne       L0015
                    lda       3,s
                    mul
                    ldx       ,s
                    stx       2,s
                    ldx       #0
                    std       ,s
                    puls      d,pc
L0015               pshs      d
                    ldd       #0
                    pshs      d
                    pshs      d
                    lda       5,s
                    ldb       9,s
                    mul
                    std       2,s
                    lda       5,s
                    ldb       8,s
                    mul
                    addd      1,s
                    std       1,s
                    bcc       L0032
                    inc       ,s
L0032               lda       4,s
                    ldb       9,s
                    mul
                    addd      1,s
                    std       1,s
                    bcc       L003f
                    inc       ,s
L003f               lda       4,s
                    ldb       8,s
                    mul
                    addd      ,s
                    std       ,s
                    ldx       6,s
                    stx       8,s
                    ldx       ,s
                    ldd       2,s
                    leas      8,s
                    rts

                    endsect

