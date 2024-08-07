                    export    _umin
                    export    _umax

                    section   code

_umin               ldd       2,s
                    cmpd      4,s
                    bls       L0009
                    ldd       4,s
L0009               rts

_umax               ldd       2,s
                    cmpd      4,s
                    bcc       L0013
                    ldd       4,s
L0013               rts

                    endsect

