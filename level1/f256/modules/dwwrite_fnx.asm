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

DWWrite             pshs      a                   preserve registers
tx@                 lda       ,x+                 get byte from buffer
                    sta       UART_TRHB           put it to PIA
loop@               lda       UART_LSR            get the LSR register value
                    bita      #$20                test for ready
                    beq       loop@               loop if not set
                    leay      -1,y                decrement byte counter
                    bne       tx@                 loop if more to send
                    puls      a,pc                restore registers and return
