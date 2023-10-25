* Disassembly by Os9disasm of claddsub.r

                    section   code

_ladd               ldd       4,s
                    addd      2,x
                    std       _flacc+2,y
                    ldd       2,s
                    adcb      1,x
                    adca      ,x
                    std       _flacc,y
                    lbra      _lbexit
_lsub               ldd       4,s
                    subd      2,x
                    std       _flacc+2,y
                    ldd       2,s
                    sbcb      1,x
                    sbca      ,x
                    std       _flacc,y
                    lbra      _lbexit

                    endsect

