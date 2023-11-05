*******************************************************
* 57600 (115200) bps using 6809 code and timimg
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
                    lda       #$01                ; A = serial in mask
                    bra       rx0030              ; go wait for start bit

* Read a byte
rxByte              leau      1,u                 ; bump storage ptr
                    leay      ,-y                 ; decrement request count
                    lda       <BBIN               ; read bit 0
                    lsra                          ; move bit 0 into Carry
                    ldd       #$ff20              ; A = timeout msb, B = shift counter
                    sta       ,s                  ; reset timeout msb for next byte
                    rorb                          ; rotate bit 0 into byte accumulator
rx0010              lda       <BBIN               ; read bit (d1, d3, d5)
                    lsra
                    rorb
                    bita      1,s                 ; 5 cycle delay
                    bcs       rx0020              ; exit loop after reading bit 5
                    lda       <BBIN               ; read bit (d2, d4)
                    lsra
                    rorb
                    leau      ,u
                    bra       rx0010

rx0020              lda       <BBIN               ; read bit 6
                    lsra
                    rorb
                    leay      ,y                  ; test request count
                    beq       rx0050              ; branch if final byte of request
                    lda       <BBIN               ; read bit 7
                    lsra
                    rorb                          ; byte is now complete
                    stb       -1,u                ; store received byte to memory
                    abx                           ; update checksum
                    lda       <BBIN               ; read stop bit
                    anda      #$01                ; mask out other bits
                    beq       rxExit              ; exit if framing error

* Wait for a start bit or timeout
rx0030              bita      <BBIN               ; check for start bit
                    beq       rxByte              ; branch if start bit detected
                    bita      <BBIN               ; again
                    beq       rxByte
                    ldb       #$ff                ; init timeout lsb
rx0040              bita      <BBIN
                    beq       rxByte
                    subb      #1                  ; decrement timeout lsb
                    bita      <BBIN
                    beq       rxByte
                    bcc       rx0040              ; loop until timeout lsb rolls under
                    bita      <BBIN
                    beq       rxByte
                    addb      ,s                  ; B = timeout msb - 1
                    bita      <BBIN
                    beq       rxByte
                    stb       ,s                  ; store decremented timeout msb
                    bita      <BBIN
                    beq       rxByte
                    bcs       rx0030              ; loop if timeout hasn't expired
                    bra       rxExit              ; exit due to timeout

rx0050              lda       <BBIN               ; read bit 7 of final byte
                    lsra
                    rorb                          ; byte is now complete
                    stb       -1,u                ; store received byte to memory
                    abx                           ; calculate final checksum
                    lda       <BBIN               ; read stop bit
                    anda      #$01                ; mask out other bits
                    ora       #$02                ; return SUCCESS if no framing error

* Clean up, set status and return
rxExit              leas      1,s                 ; remove timeout msb from stack
                    inca                          ; A = status to be returned in C and Z
                    ora       ,s                  ; place status information into the..
                    sta       ,s                  ; ..C and Z bits of the preserved CC
                    leay      ,x                  ; return checksum in Y
                    puls      cc,dp,x,u,pc        ; restore registers and return
                    setdp     $00
