                    export    _open
                    export    _close

                    section   code
                    
_open               ldx       2,s
                    lda       5,s
                    os9       I$Open
                    lblo      _os9err
                    tfr       a,b
                    clra
                    rts
                    
_close              lda       3,s
                    os9       I$Close
                    lbra      _sysret

                    endsect

