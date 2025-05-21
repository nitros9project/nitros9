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

DWWrite             pshs      u,b,a,cc            preserve registers
                    ldb       >MMU_SLOT_2
                    pshs      b
                    lda       #$C5		  Bank where the WizFi registers are
                    orcc      #IntMasks           mask interupts
                    sta       >MMU_SLOT_2
a@                  clrb
* Maybe the DW server is sending us unwanted status codes?
* Purging the RxD FIFO while transmitting the packet has proven to make the most stable session under
* the current conditions of the Jr2 FIFO count registers being broken.
* By some miracle, it works out 99% of the time.
b@                  lda       >WIZFI_UART_RxD_WR_Count
                    beq       t@
                    lda       >WIZFI_UART_DataReg
                    decb
                    bne       b@
t@                  lda       ,x+                 get byte from buffer
                    sta       >WIZFI_UART_DataReg send the data byte
                    leay      -1,y                decrement byte counter
                    bne       a@                  loop if more to send

                    puls      b                   Get saved MMU block # from stack
                    stb       >MMU_SLOT_2         Restore MMU block #
                    puls      cc,a,b,u,pc         restore registers and return
