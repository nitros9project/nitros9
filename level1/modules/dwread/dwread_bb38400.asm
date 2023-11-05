*******************************************************
* 38400 bps using 6809 code and timimg
*******************************************************

DWRead              clra                          ; clear Carry (no framing error)
                    deca                          ; clear Z flag, A = timeout msb ($ff)
                    tfr       cc,b
                    pshs      u,x,dp,b,a          ; preserve registers, push timeout msb
                    orcc      #$50                ; mask interrupts
                    tfr       a,dp                ; set direct page to $FFxx
                    setdp     $ff
                    leau      ,x                  ; U = storage ptr
                    ldx       #0                  ; initialize checksum
                    adda      #2                  ; A = $01 (serial in mask), set Carry

* Wait for a start bit or timeout
rx0010              bcc       rxExit              ; exit if timeout expired
                    ldb       #$ff                ; init timeout lsb
rx0020              bita      <BBIN               ; check for start bit
                    beq       rxByte              ; branch if start bit detected
                    subb      #1                  ; decrement timeout lsb
                    bita      <BBIN
                    beq       rxByte
                    bcc       rx0020              ; loop until timeout lsb rolls under
                    bita      <BBIN
                    beq       rxByte
                    addb      ,s                  ; B = timeout msb - 1
                    bita      <BBIN
                    beq       rxByte
                    stb       ,s                  ; store decremented timeout msb
                    bita      <BBIN
                    bne       rx0010              ; loop if still no start bit

* Read a byte
rxByte              leay      ,-y                 ; decrement request count
                    ldd       #$ff80              ; A = timeout msb, B = shift counter
                    sta       ,s                  ; reset timeout msb for next byte
rx0030              exg       a,a
                    nop
                    lda       <BBIN               ; read data bit
                    lsra                          ; shift into carry
                    rorb                          ; rotate into byte accumulator
                    lda       #$01                ; prep stop bit mask
                    bcc       rx0030              ; loop until all 8 bits read

                    stb       ,u+                 ; store received byte to memory
                    abx                           ; update checksum
                    ldb       #$ff                ; set timeout lsb for next byte
                    anda      <BBIN               ; read stop bit
                    beq       rxExit              ; exit if framing error
                    leay      ,y                  ; test request count
                    bne       rx0020              ; loop if another byte wanted
                    lda       #$03                ; setup to return SUCCESS

* Clean up, set status and return
rxExit              leas      1,s                 ; remove timeout msb from stack
                    inca                          ; A = status to be returned in C and Z
                    ora       ,s                  ; place status information into the..
                    sta       ,s                  ; ..C and Z bits of the preserved CC
                    leay      ,x                  ; return checksum in Y
                    puls      cc,dp,x,u,pc        ; restore registers and return
                    setdp     $00
