* Disassembly by Os9disasm of ss2.r

                    section   code

* OS-9 system function equates

I$SetStt            equ       $8e

_ss_lock            pshs      u
                    ldb       #$11
                    bra       L0010
_ss_attr            pshs      u
                    ldb       #$1c
                    bra       L0012
_ss_size            pshs      u
                    ldb       #2
L0010               ldu       8,s
L0012               ldx       6,s
                    lda       5,s
                    os9       I$SetStt
                    puls      u
                    lbra      _sysret

                    endsect

