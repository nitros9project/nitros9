                    export    _ss_rel
                    export    _ss_rest
                    export    _ss_opt
                    export    _ss_pfd
                    export    _ss_ssig
                    export    _ss_tiks
                    
                    section   code

_ss_rel             ldb       #$1b
                    bra       L0018
_ss_rest            ldb       #3
                    bra       L0018
                    
_ss_opt             ldb       #0
                    bra       L0016
                    
_ss_pfd             ldb       #$0f
                    bra       L0016
                    
_ss_ssig            ldb       #$1a
                    bra       L0016
                    
_ss_tiks            ldb       #$10
L0016               ldx       4,s
L0018               lda       3,s
                    os9       I$SetStt
                    lbra      _sysret

                    endsect

