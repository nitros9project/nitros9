                    export    setime
                    export    getime
                    
                    section   code

setime              ldx       2,s
                    os9       F$STime
                    lbra      _sysret
getime              ldx       2,s
                    os9       F$Time
                    lbra      _sysret

                    endsect

