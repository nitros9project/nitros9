DWInit
* Initialize the baud rate.
                    ldx       #UART.Base
                    lda       UART_LCR,x
                    ora       #LCR_DLB
                    sta       UART_LCR,x
                    lda       UART_LCR,x

                    lda       #0
                    sta       UART_DLH,x
* The UART core divides by 16*(divisor+1) - its baud counter is inclusive.
* On the raw 25.175MHz UART clock no standard rate is reachable closer than
* -2.4% (divisor 6 = 224,777 real at "230400"), the margin behind the
* DriveWire E$Read #244 failures under sustained traffic.
* Cores with the fractional-BAUDCE fix (SuperIO_JR.v, 2026-08-28) run the
* baud generator at exactly 22.1184MHz, where standard rates are EXACT:
* 230400 -> 5, 115200 -> 11, 57600 -> 23, 460800 -> 2.
* PAIRING NOTE: divisor and core must match as a pair - a divisor-5 boot
* on a pre-fix core yields 262,240 baud (DW dead); divisor 6 on a fixed
* core yields 197,486 (DW dead). Disks built from this source require the
* BAUDCE-fixed cores, v8_rc3 (2026-08-28) or later, on BOTH machines.
* Current cores as of 2026-09-03: K2 v8_rc10, Jr2 v8_rc7; the parity kits
* ship core and disk together so the pair stays consistent.
                    lda       #5                  22.1184MHz / (16 * (5+1)) = 230400 exactly (BAUDCE-fixed cores)
                    sta       UART_DLL,x
* FIFOs ON, 64 bytes deep (2026-09-07, wb/DriveWireCompatible).  FCR bit 0 is the FIFO enable in this
* 16750 core and every earlier write left it clear, so the link ran on a ONE-byte holding register: it
* only worked because the transactions were interrupt-masked and read each byte within microseconds.
* Bit 5 (64-byte mode) is writable only while DLAB is set, hence this write sits inside the divisor
* window.  Every later FCR write must keep bit 0 set (PurgeRX in rbdw, PollPurge in dwio).
                    lda       #%11100001          FIFOs on, 64-byte mode, RX trigger irrelevant (polled)
                    sta       UART_FCR,x

                    lda       UART_LCR,x
                    eora      #LCR_DLB
                    sta       UART_LCR,x
* Initialize serial parameters.
                    lda       #LCR_PARITY_NONE|LCR_STOPBIT_1|LCR_DATABITS_8
                    anda      #0x7F
                    sta       UART_LCR,x

* (the old FCR write here, %11000000, cleared bit 0 and switched the FIFOs OFF - see the divisor window above)
* Read until no more data left.
loop2@              lda       UART_TRHB,x         read byte from TX/RX holding register
                    lda       UART_LSR,x          get the LSR register value
                    bita      #LSR_DATA_AVAIL     test for data available
                    bne       loop2@              if available, get byte
                    rts
