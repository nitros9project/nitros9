*******************************************************
* 57600 (115200) bps using 6309 native mode
*******************************************************

DWWrite             pshs      u,d,cc              ; preserve registers
                    orcc      #$50                ; mask interrupts
*         ldmd      #1                  ; requires 6309 native mode
                    ldu       #BBOUT+1            ; point U to bit banger out register +1
                    aim       #$f7,2,u            ; disable sound output
                    lda       #8                  ; counter for start bit and 7 data bits
                    fcb       $8c                 ; skip next instruction

txByte              stb       -1,u                ; send stop bit
tx0010              ldb       ,x+                 ; get a byte to transmit
                    lslb                          ; left rotate the byte two positions..
                    rolb                          ; ..placing a zero (start bit) in bit 1
                    bra       tx0030

tx0020              bita      #1                  ; even or odd bit number ?
                    beq       tx0040              ; branch if even (15 cycles)
tx0030              nop       ;                   extra (16th) cycle
tx0040              stb       -1,u                ; send bit
                    rorb                          ; move next bit into position
                    deca                          ; decrement loop counter
                    bne       tx0020              ; loop until 7th data bit has been sent
                    leau      ,u+
                    stb       -1,u                ; send bit 7
                    ldd       #$0802              ; A = loop counter, B = MARK value
                    leay      -1,y                ; decrement byte counter
                    bne       txByte              ; loop if more to send

                    stb       -1,u                ; final stop bit
                    puls      cc,d,u,pc           ; restore registers and return
