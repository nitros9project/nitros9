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

DWRead              clra                          clear Carry (no framing error)
                    pshs      u,x,cc              preserve registers
                    leau      ,x
                    ldx       #$0000
loop@               lda       UART_LSR            get the LSR register value
                    bita      #$01                test for data available
                    beq       loop@               loop if not set
                    lda       UART_TRHB           get the data byte
                    stb       ,u+                 save off acquired byte
                    abx                           update checksum
                    leay      ,-y                 decrement Y
                    bne       loop@               branch if more to obtain
                    leay      ,x                  return checksum in Y
                    puls      cc,x,u,pc           restore registers and return
