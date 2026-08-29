*******************************************************
*
* DWRead
*    Receive a response from the DriveWire server.
*    Times out if serial port goes idle for more than 1.4 (0.7) seconds.
*    Serial data format:  1-8-N-1
*
* Entry:
*    X  = starting address where data is to be stored
*    Y  = number of bytes expected
*
* Exit:
*    CC = carry set on framing error, Z set if all bytes received
*    X  = starting address of data received
*    Y  = checksum
*    U is preserved.  All accumulators are clobbered
*

DWRead              clra                          clear carry (no framing error)
                    clrb
                    pshs      u,x,d,cc            preserve registers
                    orcc      #IntMasks           mask interrupts
                    leau      ,x
                    ldx       #$0000
loop@               ldd       #$0000              store counter
                    std       1,s
loop2@              lda       UART.Base+UART_LSR  get the LSR register value
                    bita      #LSR_DATA_AVAIL     test for data available
                    bne       getbyte@            if available, get byte
                    ldd       1,s
                    addb      #$01
                    adca      #$00
                    std       1,s
                    cmpd      #$0000
                    bne       loop2@
                    lda       ,s                  get CC off stack
                    anda      #^$04               clear the Z flag to indicate not all bytes received.
                    sta       ,s
* RX resync purge (2026-08-28): after a timeout, the server's remaining
* bytes may still arrive and sit in the 16-byte FIFO, poisoning the NEXT
* transaction (the cascading-#244 pattern). Drain the FIFO and any late
* stragglers until the line has been idle for 10+ character times.
* Bounded (max ~1200 discards); IRQs are still masked here; X is
* restored from the stack at exit so it is free to use.
                    ldy       #1200               max stale bytes to discard
* 2026-09-04: was 256, which measured ~0.5ms only at the ~9MHz the machine ran
* at when this was tuned (2026-08-28, pre-fast-writes).  10 char times at 230400
* is 434us, so 256 left barely 15% margin - and rc10's fast RAM writes shortened
* write frames 32->24 ticks, speeding the CPU up and eating it.  The purge then
* declared the line idle with bytes still in flight, left stragglers in the
* 16-byte FIFO and poisoned the next transaction: the cascading-#244 pattern
* this purge exists to prevent.  768 restores ~3x margin at any plausible clock.
* Proper fix is to time this off a hardware timer ($FE30) instead of counting
* cycles - see the notes in the drivewire kit.
prg0@               ldx       #768                idle window, >=1.4ms (>30 char times at 230400)
prg1@               lda       UART.Base+UART_LSR
                    bita      #LSR_DATA_AVAIL
                    bne       prg2@               late byte - discard it, restart idle window
                    leax      -1,x
                    bne       prg1@
                    bra       bye@                line went idle - resync complete
prg2@               lda       UART.Base+UART_TRHB discard stale byte
                    leay      -1,y
                    bne       prg0@
                    bra       bye@                discard cap hit - stop draining
getbyte@            ldb       UART.Base+UART_TRHB get the data byte
                    stb       ,u+                 save off acquired byte
                    abx                           update checksum
                    leay      ,-y                 decrement Y
                    bne       loop@               branch if more to obtain
                    leay      ,x                  return checksum in Y
bye@                puls      cc,d,x,u,pc         restore registers and return
