                    export    _kill
                    export    _wait
                    export    _setpr
                    export    _chain
                    export    _os9fork
                    
                    section   code

_kill               lda       3,s
                    ldb       5,s
                    os9       F$Send
                    lbra      _sysret
                    
_wait               clra
                    clrb
                    os9       F$Wait
                    lblo      _os9err
                    ldx       2,s
                    beq       L001b
                    stb       1,x
                    clr       ,x
L001b               tfr       a,b
                    clra
                    rts
                    
_setpr              lda       3,s
                    ldb       5,s
                    os9       F$SPrior
                    lbra      _sysret
                    
_chain              leau      ,s
                    leas      255,y
                    ldx       2,u
                    ldy       4,u
                    lda       9,u
                    asla
                    asla
                    asla
                    asla
                    ora       11,u
                    ldb       13,u
                    ldu       6,u
                    os9       F$Chain
                    os9       F$Exit
                    
_os9fork            pshs      y,u
                    ldx       6,s
                    ldy       8,s
                    ldu       10,s
                    lda       13,s
                    ora       15,s
                    ldb       17,s
                    os9       F$Fork
                    puls      y,u
                    lblo      _os9err
                    tfr       a,b
                    clra
                    rts

                    endsect

