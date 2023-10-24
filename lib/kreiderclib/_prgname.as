* Disassembly by Os9disasm of _prgname.r

                    section   code

_prgname            leax      btext,pcr
                    ldd       2,x
                    leax      d,x
                    leax      -4,x
L000a               lda       ,-x
                    bne       L000a
                    leax      1,x
                    tfr       x,d
                    rts

                    endsect

