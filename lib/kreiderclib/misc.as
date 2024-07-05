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

;;; void crc(char *start, int count, char accum[3])
;;;
;;; Compute the cyclic redundancy check of a module.
;;;
;;; This function accumulates a CRC in a three byte array at accum[3] for count bytes starting at start. Initialize all three bytes of accum to 0xFF before
;;; calling the function initially. Maintain the values for subsequent calls on the same module. Complement the accumulator if you place it at the end
;;; of an OS-9 module.

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

