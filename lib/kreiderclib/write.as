                    export    _write
                    export    _writeln
                    
                    section   code

_write              pshs      y
                    ldy       8,s
                    beq       L0015
                    lda       5,s
                    ldx       6,s
                    os9       I$Write
L000e               bcc       L0015
                    puls      y
                    lbra      _os9err
L0015               tfr       y,d
                    puls      y,pc
                    
_writeln            pshs      y
                    ldy       8,s
                    beq       L0015
                    lda       5,s
                    ldx       6,s
                    os9       I$WritLn
                    bra       L000e

                    endsect

