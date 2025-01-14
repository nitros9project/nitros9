                    export    _ftell
                    
                    section   code

_ftell              leax      _flacc,y
                    clra
                    clrb
                    std       ,x
                    std       2,x
                    rts

                    endsect

