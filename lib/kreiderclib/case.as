                    export    _toupper
                    export    _tolower
                    
                    section   code

_toupper            clra
                    ldb       3,s
                    leax      _chcodes,y
                    lda       d,x
                    anda      #4
                    beq       L0022
                    andb      #$df
                    clra
                    rts

_tolower            clra
                    ldb       3,s
                    leax      _chcodes,y
                    lda       d,x
                    anda      #2
                    beq       L0022
                    orb       #$20
                    clra
                    rts
L0022               ldd       2,s
                    rts

                    endsect

