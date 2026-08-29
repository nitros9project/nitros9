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
*    Y  = 0 (bytes remaining if the transmitter wedged)
*    All others preserved
*
* 2026-08-28: the wait for LSR_XMIT_DONE is now bounded (~0.3s per byte).
* The old unbounded spin was the driver's only true hard-hang path: a
* wedged transmitter froze the machine with IRQs masked forever.  On
* timeout the remaining bytes are abandoned; the transaction then fails
* at the next DWRead (which purges and resyncs) and surfaces as a clean
* E$Read error with IRQs restored.
*

DWWrite             pshs      u,d,cc              preserve registers (B too - D is the timeout counter)
                    orcc      #IntMasks           mask interupts
                    leas      -2,s                local 16-bit drain-wait timeout counter
loop@               ldd       #$0000              reset the timeout for each byte
                    std       ,s
wait@               lda       UART.Base+UART_LSR  get status register
                    anda      #LSR_XMIT_DONE      is transmit FIFO empty?
                    beq       tick@               not yet - count down the timeout
                    lda       ,x+                 get byte from buffer
                    sta       UART.Base+UART_TRHB put it to PIA
                    leay      -1,y                decrement byte counter
                    bne       loop@               loop if more to send
                    bra       bye@
tick@               ldd       ,s
                    addd      #$0001
                    std       ,s
                    bne       wait@               ~65536 polls before giving up
bye@                leas      2,s                 drop timeout counter
                    puls      cc,d,u,pc           restore registers and return
