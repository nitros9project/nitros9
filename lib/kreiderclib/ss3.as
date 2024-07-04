                    export    __ss_wtrk
                    
                    section   code

__ss_wtrk           pshs      y,u
                    ldb       #4
                    ldy       10,s
                    ldu       8,s
                    ldx       14,s
                    lda       7,s
                    os9       I$SetStt
                    puls      y,u
                    lbra      _sysret

                    endsect

