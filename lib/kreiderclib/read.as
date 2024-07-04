                    export    _read
                    export    _readln
                    
                    section   code

_read               pshs      y
                    ldx       6,s
                    lda       5,s
                    ldy       8,s
                    pshs      y
                    os9       I$Read
L000e               bcc       L001d
                    cmpb      #$d3
                    bne       L0018
                    clra
                    clrb
                    puls      x,y,pc
L0018               puls      x,y
                    lbra      _os9err
L001d               tfr       y,d
                    puls      x,y,pc
                    
_readln             pshs      y
                    lda       5,s
                    ldx       6,s
                    ldy       8,s
                    pshs      y
                    os9       I$ReadLn
                    bra       L000e

                    endsect

