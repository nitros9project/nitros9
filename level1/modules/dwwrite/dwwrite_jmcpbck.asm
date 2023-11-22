DWWrite             pshs      d,cc                ; preserve registers
                    orcc      #$50                ; mask interrupts
txByte
                    lda       ,x+
                    sta       $FF44
                    leay      -1,y                ; decrement byte counter
                    bne       txByte              ; loop if more to send

                    puls      cc,d,pc             ; restore registers and return
