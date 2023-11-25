DWInit
* Initialize the baud rate.
               lda       UART_LCR
               ora       #LCR_DLB
               sta       UART_LCR
               lda       UART_LCR

               lda       #0
               sta       UART_DLH
*               lda       #13                 (25.125Mhz / (16 * 115200)) = 13.65 (internal speed of Devices inside FPGA is 25.175Mhz (not 6Mhz))
               lda       #6                  (25.125Mhz / (16 * 230400)) = 6.82 (internal speed of Devices inside FPGA is 25.175Mhz (not 6Mhz))
               sta       UART_DLL

               lda       UART_LCR
               eora      #LCR_DLB
               sta       UART_LCR
* Initialize serial parameters.
               lda       #LCR_PARITY_NONE|LCR_STOPBIT_1|LCR_DATABITS_8
               anda      #0x7F
               sta       UART_LCR

               lda       #%11000000          ; FIFO Mode is always On and it has only 14Bytes
               sta       UART_FCR
* Read until no more data left.
loop2@         lda       UART_TRHB           read byte from TX/RX holding register
               lda       UART_LSR            get the LSR register value
               bita      #LSR_DATA_AVAIL     test for data available
               bne       loop2@              if available, get byte
               rts
