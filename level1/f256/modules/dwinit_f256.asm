DWInit
* Initialize the baud rate.
                    ldx       #UART.Base
                    lda       UART_LCR,x
                    ora       #LCR_DLB
                    sta       UART_LCR,x
                    lda       UART_LCR,x

                    lda       #0
                    sta       UART_DLH,x
*               lda       #13                 (25.125Mhz / (16 * 115200)) = 13.65 (internal speed of Devices inside FPGA is 25.175Mhz (not 6Mhz))
                    lda       #6                  (25.125Mhz / (16 * 230400)) = 6.82 (internal speed of Devices inside FPGA is 25.175Mhz (not 6Mhz))
                    sta       UART_DLL,x

                    lda       UART_LCR,x
                    eora      #LCR_DLB
                    sta       UART_LCR,x
* Initialize serial parameters.
                    lda       #LCR_PARITY_NONE|LCR_STOPBIT_1|LCR_DATABITS_8
                    anda      #0x7F
                    sta       UART_LCR,x

                    lda       #%11000000          FIFO mode is always on and it has only 14 Bytes
                    sta       UART_FCR,x
* Read until no more data left.
loop2@              lda       UART_TRHB,x         read byte from TX/RX holding register
                    lda       UART_LSR,x          get the LSR register value
                    bita      #LSR_DATA_AVAIL     test for data available
                    bne       loop2@              if available, get byte
                    rts
