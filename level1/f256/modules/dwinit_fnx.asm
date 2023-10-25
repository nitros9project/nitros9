DWInit
                    lda       #FCR_TXR|FCR_RXR
                    sta       UART_FCR
                    lda       #LCR_DLB
                    sta       UART_LCR
                    ldd       #13*256+0
                    std       UART_DLL
                    lda       #LCR_PARITY_NONE|LCR_STOPBIT_1|LCR_DATABITS_8
                    sta       UART_LCR
