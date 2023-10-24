*******************************************************
*
* DWWriteMESS
*
*  4/27/10 AAW - Based on John Linville's example
*
* Entry:
*    X  = starting address of data to send
*    Y  = number of bytes to send
*
* Exit:
*    X  = address of last byte sent + 1
*    Y  = 0
*    All others preserved
*


DWWrite             pshs      u,d,cc              ; preserve registers
                    orcc      #$50                ; mask interrupts

txByte              ldb       ,x+                 ; get a byte to transmit
                    stb       $ffe0               ; write it to the FIFO
                    leay      ,-y                 ; decrement byte counter
                    bne       txByte              ; loop if more to send

                    puls      cc,d,u,pc           ; restore registers and return


