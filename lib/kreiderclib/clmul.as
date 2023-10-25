* Disassembly by Os9disasm of clmul.r

                    section   code

_lmul               ldd       2,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    leax      _flacc,y
                    clr       ,x
                    clr       1,x
                    lda       9,s
                    ldb       3,s
                    mul
                    std       2,x
                    lda       9,s
                    ldb       2,s
                    mul
                    addd      1,x
                    std       1,x
                    bcc       L0024
                    inc       ,x
L0024               lda       8,s
                    ldb       3,s
                    mul
                    addd      1,x
                    std       1,x
                    bcc       L0031
                    inc       ,x
L0031               lda       9,s
                    ldb       1,s
                    mul
                    addd      ,x
                    std       ,x
                    lda       8,s
                    ldb       2,s
                    mul
                    addd      ,x
                    std       ,x
                    lda       7,s
                    ldb       3,s
                    mul
                    addd      ,x
                    std       ,x
                    lda       9,s
                    ldb       ,s
                    mul
                    addb      ,x
                    stb       ,x
                    lda       8,s
                    ldb       1,s
                    mul
                    addb      ,x
                    stb       ,x
                    lda       7,s
                    ldb       2,s
                    mul
                    addb      ,x
                    stb       ,x
                    lda       6,s
                    ldb       3,s
                    mul
                    addb      ,x
                    stb       ,x
                    leas      4,s
                    lbra      _lbexit

                    endsect

