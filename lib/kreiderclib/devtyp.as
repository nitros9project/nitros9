                    export    isatty
                    export    devtyp
                    
                    section   code

isatty              ldd       2,s
                    pshs      d
                    bsr       devtyp
                    std       ,s++
                    beq       L000c
                    clrb
                    rts
L000c               incb
                    rts
                    
devtyp              lda       3,s
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

