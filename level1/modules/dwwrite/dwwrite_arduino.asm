DWWrite             pshs      a                   ; preserve registers
txByte
                    lda       ,x+                 ; get byte from buffer
                    sta       $FF52               ; put it to PIA
loop@               tst       $FF53               ; check status register
                    bpl       loop@               ; until CB1 is set by Arduino, continue looping
                    tst       $FF52               ; clear CB1 in status register
                    leay      -1,y                ; decrement byte counter
                    bne       txByte              ; loop if more to send
                    puls      a,pc                ; restore registers and return
