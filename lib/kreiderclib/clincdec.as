* Disassembly by Os9disasm of clincdec.r

                    section   code

_linc               ldd       #1
                    addd      2,x
                    std       2,x
                    ldd       ,x
                    adcb      #0
                    adca      #0
                    std       ,x
                    rts
_ldec               ldd       2,x
                    subd      #1
                    std       2,x
                    ldd       ,x
                    sbcb      #0
                    sbca      #0
                    std       ,x
                    rts

                    endsect

