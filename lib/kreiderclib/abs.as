                    export    abs
                    
                    section   code

abs                 ldd       2,s
                    bpl       L0008
                    nega
                    negb
                    sbca      #0
L0008               rts

                    endsect

