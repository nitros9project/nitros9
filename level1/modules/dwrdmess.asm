*******************************************************
*
* DWRdMess
*    Receive a response from the DriveWire server via MESS FIFO
*    4/27/10 AAW - Based on John Linville's example driver
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

DWRead              clra                          ; clear Carry (no framing error)
                    pshs      u,x,cc              ; preserve registers, push timeout msb
                    orcc      #$50                ; mask interrupts

                    leau      ,x                  ; U = storage ptr
                    ldx       #0                  ; initialize checksum

* Read a byte
rxByte              ldb       $ffe1               ; check for data in FIFO
                    beq       rxByte              ; loop while empty
                    ldb       $ffe0               ; read data value

                    stb       ,u+                 ; store received byte to memory
                    abx                           ; update checksum
                    leay      ,-y                 ; decrement request count
                    bne       rxByte              ; loop if another byte wanted


* Clean up, set status and return
rxExit              leay      ,x                  ; return checksum in Y
                    puls      cc,x,u,pc           ; restore registers and return
                    setdp     $00


