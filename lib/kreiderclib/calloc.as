                    export    _calloc
                    
                    section   code

_calloc             pshs      u
                    ldd       4,s
                    ldx       6,s
                    pshs      x
                    lbsr      _ccmult
                    pshs      d
                    lbsr      _malloc
                    std       -2,s
                    beq       L001e
                    ldx       ,s
                    tfr       d,u
L0018               clr       ,u+
                    leax      -1,x
                    bne       L0018
L001e               leas      2,s
                    puls      u,pc

                    endsect

