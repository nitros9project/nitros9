                    *******************************************************
*
* DWWrite
*    Send a packet to the DriveWire server.
*    Serial data format:  1-8-N-1
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

DWWrite             pshs      u,a,cc              preserve registers
                    orcc      #IntMasks           mask interupts
loop@               lda       UART.Base+UART_LSR  get status register
                    anda      #LSR_XMIT_DONE      is transmit FIFO empty?
                    beq       loop@               branch if not
                    lda       ,x+                 get byte from buffer
                    sta       UART.Base+UART_TRHB put it to PIA
                    leay      -1,y                decrement byte counter
                    bne       loop@               loop if more to send
                    puls      cc,a,u,pc           restore registers and return
