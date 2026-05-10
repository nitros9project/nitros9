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
                    clra
                    clrb
loop@               ldu       WizFi.Base+WizFi_TxD_WR_Cnt
                    cmpu      #$0000
                    beq       a@
                    subd      #$0001
                    bne       loop@
a@                  lda       ,x+                 get byte from buffer
                    sta       WizFi.Base+WizFi_DataReg
                    leay      -1,y                decrement byte counter
                    bne       a@                  loop if more to send
                    puls      cc,a,u,pc           restore registers and return
