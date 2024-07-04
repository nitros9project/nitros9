                    export    modlink
                    export    modload
                    export    munlink
                    
                    section   code

modlink             pshs      y,u
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
                    
modload             pshs      y,u
                    ldx       6,s
                    lda       9,s
                    asla
                    asla
                    asla
                    asla
                    ora       11,s
                    os9       F$Load
                    bra       L000f
                    
munlink             pshs      u
                    ldu       4,s
                    os9       F$UnLink
                    puls      u
                    lbra      _sysret

                    endsect

