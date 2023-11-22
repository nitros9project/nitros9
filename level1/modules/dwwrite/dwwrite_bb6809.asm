*******************************************************
* 57600 (115200) bps using 6809 code and timimg
*******************************************************

DWWrite             pshs      dp,d,cc             ; preserve registers
                    orcc      #$50                ; mask interrupts
                    ldd       #$04ff              ; A = loop counter, B = $ff
                    tfr       b,dp                ; set direct page to $FFxx
                    setdp     $ff
                    ldb       <$ff23              ; read PIA 1-B control register
                    andb      #$f7                ; clear sound enable bit
                    stb       <$ff23              ; disable sound output
                    fcb       $8c                 ; skip next instruction

txByte              stb       <BBOUT              ; send stop bit
                    ldb       ,x+                 ; get a byte to transmit
                    nop
                    lslb                          ; left rotate the byte two positions..
                    rolb                          ; ..placing a zero (start bit) in bit 1
tx0020              stb       <BBOUT              ; send bit (start bit, d1, d3, d5)
                    rorb                          ; move next bit into position
                    exg       a,a
                    nop
                    stb       <BBOUT              ; send bit (d0, d2, d4, d6)
                    rorb                          ; move next bit into position
                    leau      ,u
                    deca                          ; decrement loop counter
                    bne       tx0020              ; loop until 7th data bit has been sent

                    stb       <BBOUT              ; send bit 7
                    ldd       #$0402              ; A = loop counter, B = MARK value
                    leay      ,-y                 ; decrement byte counter
                    bne       txByte              ; loop if more to send

                    stb       <BBOUT              ; leave bit banger output at MARK
                    puls      cc,d,dp,pc          ; restore registers and return
                    setdp     $00
