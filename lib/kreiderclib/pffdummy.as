                    export    _pffloat
                    
                    section   code

* class D external label equates

D0000               equ       $0000

_pffloat            leax      >L0007,pcr
                    tfr       x,d
                    rts
L0007               fcb       $00

                    endsect

