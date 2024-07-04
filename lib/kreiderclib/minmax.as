                    export    _min
                    export    _max
                    
                    section   code

_min                ldd       2,s
                    cmpd      4,s
                    ble       L0009
                    ldd       4,s
L0009               rts

_max                ldd       2,s
                    cmpd      4,s
                    bge       L0013
                    ldd       4,s
L0013               rts

                    endsect

