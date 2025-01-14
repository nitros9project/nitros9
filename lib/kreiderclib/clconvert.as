                    export    _litol
                    export    _lutol
                    
                    section   code

_litol              leax      _flacc,y
                    std       2,x
                    tfr       a,b
                    sex
                    tfr       a,b
                    std       ,x
                    rts
_lutol              leax      _flacc,y
                    std       2,x
                    clr       ,x
                    clr       1,x
                    rts

                    endsect

