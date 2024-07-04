                    export    _isatty
                    export    _devtyp
                    
                    section   code

_isatty             ldd       2,s
                    pshs      d
                    bsr       _devtyp
                    std       ,s++
                    beq       L000c
                    clrb
                    rts
L000c               incb
                    rts
                    
_devtyp             lda       3,s
                    clrb
                    leas      -32,s
                    leax      ,s
                    os9       I$GetStt
                    lda       ,s
                    leas      32,s
                    lblo      _os9err
                    tfr       a,b
                    clra
                    rts

                    endsect

