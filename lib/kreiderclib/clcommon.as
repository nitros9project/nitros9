* Disassembly by Os9disasm of clcommon.r

                    section   code

_lbexit             tfr       cc,a
                    puls      x
                    stx       2,s
                    leas      2,s
                    leax      _flacc,y
                    tfr       a,cc
                    rts
_ltoacc             ldd       ,x
                    std       _flacc,y
                    ldd       2,x
                    leax      _flacc,y
                    std       2,x
                    rts

                    endsect

