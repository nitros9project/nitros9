                    export    _ss_lock
                    export    _ss_attr
                    export    _ss_size
                    
                    section   code

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

