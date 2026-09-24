*******************************************************
*
* DWRead
*    Receive a response from the DriveWire server.
*    Times out if the serial port goes idle for DW_TIMEOUT_MULT x 65536 polls:
*    ~2.7s under turbo on the rc11 cores, ~4s at stock speed (the CoCo
*    original was 1.4/0.7s at 0.89/1.79MHz).
*    Serial data format:  1-8-N-1
*
* Entry:
*    X  = starting address where data is to be stored
*    Y  = number of bytes expected
*
* Exit:
*    CC = carry set on UART receive error, Z set if all bytes received
*    X  = starting address of data received
*    Y  = checksum
*    U is preserved.  All accumulators are clobbered
*

* Cycle-counted timeouts (2026-09-05): the 16-bit poll counter wraps after 65536
* polls, ~335ms at stock speed and ~220ms under turbo - shorter than a DriveWire4
* server stall (Java GC, measured ~620ms), and it shrinks again with every faster
* CPU. DW_TIMEOUT_MULT multiplies the window (12 x 65536 polls = ~2.7s under
* today's turbo, still ~1.4s at a 2x faster CPU). DW_PURGE_IDLE is the
* post-timeout idle window in polls (3072 = ~5.5ms turbo, ~2.8ms at 2x; 10 char
* times at 230400 is 434us). Proper fix: time both off TIMER0 ($FE30), which
* counts the fixed 25.175MHz IO clock and is untouched by turbo.
DW_TIMEOUT_MULT     equ       12                  +50% 2026-09-05 (was 8)
DW_MASKED           equ       512                 polls the wait for a first byte stays masked (~3 ms turbo) before interrupts return
DW_PURGE_IDLE       equ       3072                +50% 2026-09-05 (was 2048)
DWRead              clra                          clear carry (no framing error)
                    clrb
                    pshs      u,x,d,cc            preserve registers
* Only the prompt wait and active receive burst mask interrupts. After
* DW_MASKED empty polls, restore the caller's masks until another byte arrives.
* Retain UART overrun/parity/framing/break errors in saved CC: LSR reads clear
* them in hardware. Finish the leg (or time out) so the caller can complete
* the checksum handshake before resynchronizing; never accept a damaged leg.
                    orcc      #IntMasks
                    leau      ,x
                    ldx       #$0000
loop@               ldd       #$0000              store counter
                    std       1,s
                    lda       #DW_TIMEOUT_MULT    outer timeout count
                    pshs      a                   ,s = outer count; saved CC now 1,s, counter 2,s
loop2@              lda       UART.Base+UART_LSR  get the LSR register value
                    bita      #$1E                overrun, parity, framing or break
                    beq       rxok@
                    pshs      a                   retain data-ready bit from this LSR read
                    lda       2,s                 saved CC (outer count and LSR above it)
                    ora       #$01                sticky carry = damaged receive leg
                    sta       2,s
                    puls      a
rxok@               bita      #LSR_DATA_AVAIL     test for data available
                    bne       getbyte@            if available, get byte
                    ldd       2,s
                    addb      #$01
                    adca      #$00
                    std       2,s
                    cmpd      #DW_MASKED          the prompt-answer window is over: interrupts back on
                    bne       l2c@
                    lda       1,s                 the caller's CC (interrupts on)
                    tfr       a,cc
                    ldd       2,s                 the counter again (A was the CC)
l2c@                cmpd      #$0000
                    bne       loop2@
                    dec       ,s                  16-bit counter wrapped: one outer count down
                    bne       loop2@
                    leas      1,s                 drop the outer count
                    lda       ,s                  get CC off stack
                    anda      #^$04               clear the Z flag to indicate not all bytes received.
                    sta       ,s
                    tfr       a,cc                the purge waits with the caller's interrupts (on)
* RX resync purge (2026-08-28): after a timeout, the server's remaining
* bytes may still arrive and sit in the 16-byte FIFO, poisoning the NEXT
* transaction (the cascading-#244 pattern). Drain the FIFO and any late
* stragglers until the line has been idle for 10+ character times.
* Bounded (max ~1200 discards); interrupts are the caller's here; X is
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
prg0@               ldx       #DW_PURGE_IDLE      idle window (3072 polls: ~5.5ms turbo, >120 char times at 230400)
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
getbyte@            leas      1,s                 drop the outer count
                    orcc      #IntMasks           2026-09-12: the burst is read masked (see above); bye@ restores the caller's CC
                    ldb       UART.Base+UART_TRHB get the data byte
                    stb       ,u+                 save off acquired byte
                    abx                           update checksum
                    leay      ,-y                 decrement Y
                    bne       loop@               branch if more to obtain
                    leay      ,x                  return checksum in Y
bye@                puls      cc,d,x,u,pc         restore registers and return
