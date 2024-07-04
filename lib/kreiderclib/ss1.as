                    export    __ss_rel
                    export    __ss_rest
                    export    __ss_opt
                    export    __ss_pfd
                    export    __ss_ssig
                    export    __ss_tiks
                    
                    section   code

__ss_rel            ldb       #SS.Relea
                    bra       L0018
                    
__ss_rest           ldb       #SS.Reset
                    bra       L0018
                    
__ss_opt            ldb       #SS.Opt
                    bra       L0016
                    
__ss_pfd            ldb       #SS.FD
                    bra       L0016
                    
__ss_ssig           ldb       #SS.SSig
                    bra       L0016
                    
__ss_tiks           ldb       #SS.Ticks
L0016               ldx       4,s
L0018               lda       3,s
                    os9       I$SetStt
                    lbra      _sysret

                    endsect

