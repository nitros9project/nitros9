                    export    _modlink
                    export    _modload
                    export    _munlink
                    
                    section   code

_modlink            pshs      y,u
                    ldx       6,s
                    lda       9,s
                    asla
                    asla
                    asla
                    asla
                    ora       11,s
                    os9       F$Link
L000f               tfr       u,d
                    puls      y,u
                    lblo      _os9err
                    rts
                    
_modload            pshs      y,u
                    ldx       6,s
                    lda       9,s
                    asla
                    asla
                    asla
                    asla
                    ora       11,s
                    os9       F$Load
                    bra       L000f
                    
_munlink            pshs      u
                    ldu       4,s
                    os9       F$UnLink
                    puls      u
                    lbra      _sysret

                    endsect

