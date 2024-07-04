                    export    __ss_lock
                    export    __ss_attr
                    export    __ss_size
                    
                    section   code

__ss_lock           pshs      u
                    ldb       #$11
                    bra       L0010
                    
__ss_attr           pshs      u
                    ldb       #$1c
                    bra       L0012
                    
__ss_size           pshs      u
                    ldb       #2
L0010               ldu       8,s
L0012               ldx       6,s
                    lda       5,s
                    os9       I$SetStt
                    puls      u
                    lbra      _sysret

                    endsect

