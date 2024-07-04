                    export    _setime
                    export    _getime
                    
                    section   code

_setime             ldx       2,s
                    os9       F$STime
                    lbra      _sysret
                    
_getime             ldx       2,s
                    os9       F$Time
                    lbra      _sysret

                    endsect

