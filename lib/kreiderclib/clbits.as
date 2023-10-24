* Disassembly by Os9disasm of clbits.r

                    section   code

_land               ldd       2,s
                    anda      ,x
                    andb      1,x
                    std       _flacc,y
                    ldd       4,s
                    anda      2,x
                    andb      3,x
                    std       _flacc+2,y
                    lbra      _lbexit
_lor                ldd       2,s
                    ora       ,x
                    orb       1,x
                    std       _flacc,y
                    ldd       4,s
                    ora       2,x
                    orb       3,x
                    std       _flacc+2,y
                    lbra      _lbexit
_lxor               ldd       2,s
                    eora      ,x
                    eorb      1,x
                    std       _flacc,y
                    ldd       4,s
                    eora      2,x
                    eorb      3,x
                    std       _flacc+2,y
                    lbra      _lbexit
_lnot               lda       ,x
                    ora       1,x
                    ora       2,x
                    ora       3,x
                    beq       L0052
                    clrb
                    clra
                    rts
L0052               ldd       #1
                    rts

                    endsect

