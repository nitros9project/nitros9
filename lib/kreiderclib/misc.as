                    export    _lock
                    export    _pause
                    export    _sync
                    export    _crc
                    export    _prerr
                    export    _tsleep
                    
                    section   code

_lock               rts

_pause              ldx       #0
                    clrb
                    os9       F$Sleep
                    lbra      _os9err
                    
_sync               rts

_crc                pshs      y,u
                    ldx       6,s
                    ldy       8,s
                    ldu       10,s
                    os9       F$CRC
                    puls      y,u,pc
                    
_prerr              lda       3,s
                    ldb       5,s
                    os9       F$PErr
                    lblo      _os9err
                    rts
                    
_tsleep             ldx       2,s
                    os9       F$Sleep
                    lblo      _os9err
                    tfr       x,d
                    rts

                    endsect

