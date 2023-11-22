*******************************************************
* 38400 bps using 6809 code and timimg
*******************************************************

DWWrite             pshs      u,d,cc              ; preserve registers
                    orcc      #$50                ; mask interrupts
                    ldu       #BBOUT              ; point U to bit banger out register
                    lda       3,u                 ; read PIA 1-B control register
                    anda      #$f7                ; clear sound enable bit
                    sta       3,u                 ; disable sound output
                    fcb       $8c                 ; skip next instruction

txByte              stb       ,--u                ; send stop bit
                    leau      ,u+
                    lda       #8                  ; counter for start bit and 7 data bits
                    ldb       ,x+                 ; get a byte to transmit
                    lslb                          ; left rotate the byte two positions..
                    rolb                          ; ..placing a zero (start bit) in bit 1
tx0010              stb       ,u++                ; send bit
                    tst       ,--u
                    rorb                          ; move next bit into position
                    deca                          ; decrement loop counter
                    bne       tx0010              ; loop until 7th data bit has been sent
                    leau      ,u
                    stb       ,u                  ; send bit 7
                    lda       ,u++
                    ldb       #$02                ; value for stop bit (MARK)
                    leay      -1,y                ; decrement byte counter
                    bne       txByte              ; loop if more to send

                    stb       ,--u                ; leave bit banger output at MARK
                    puls      cc,d,u,pc           ; restore registers and return
