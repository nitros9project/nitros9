* Disassembly by Os9disasm of ftelldummy.r

                    section   code

ftell               leax      _flacc,y
                    clra
                    clrb
                    std       ,x
                    std       2,x
                    rts

                    endsect

