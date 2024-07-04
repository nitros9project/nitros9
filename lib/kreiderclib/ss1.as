                    export    __ss_rel
                    export    __ss_rest
                    export    __ss_opt
                    export    __ss_pfd
                    export    __ss_ssig
                    export    __ss_tiks
                    
                    section   code

__ss_rel            ldb       #$1b
                    bra       L0018
                    
__ss_rest           ldb       #3
                    bra       L0018
                    
__ss_opt            ldb       #0
                    bra       L0016
                    
__ss_pfd            ldb       #$0f
                    bra       L0016
                    
__ss_ssig           ldb       #$1a
                    bra       L0016
                    
__ss_tiks           ldb       #$10
L0016               ldx       4,s
L0018               lda       3,s
                    os9       I$SetStt
                    lbra      _sysret

                    endsect

