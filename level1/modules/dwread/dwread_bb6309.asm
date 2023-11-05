*******************************************************
* 57600 (115200) bps using 6309 native mode
*******************************************************

DWRead              clrb                          ; clear Carry (no framing error)
                    decb                          ; clear Z flag, B = $FF
                    pshs      u,x,dp,cc           ; preserve registers
                    orcc      #$50                ; mask interrupts
*         ldmd      #1                  ; requires 6309 native mode
                    tfr       b,dp                ; set direct page to $FFxx
                    setdp     $ff
                    leay      -1,y                ; adjust request count
                    leau      ,x                  ; U = storage ptr
                    tfr       0,x                 ; initialize checksum
                    lda       #$01                ; A = serial in mask
                    bra       rx0030              ; go wait for start bit

* Read a byte
rxByte              sexw                          ; 4 cycle delay
                    ldw       #$006a              ; shift counter and timing flags
                    clra                          ; clear carry so next will branch
rx0010              bcc       rx0020              ; branch if even bit number (15 cycles)
                    nop       ;                   extra (16th) cycle
rx0020              lda       <BBIN               ; read bit
                    lsra                          ; move bit into carry
                    rorb                          ; rotate bit into byte accumulator
                    lda       #0                  ; prep A for 8th data bit
                    lsrw      ;                   bump shift count, timing bit to carry
                    bne       rx0010              ; loop until 7th data bit has been read
                    incw                          ; W = 1 for subtraction from Y
                    inca                          ; A = 1 for reading bit 7
                    anda      <BBIN               ; read bit 7
                    lsra                          ; move bit 7 into carry, A = 0
                    rorb                          ; byte is now complete
                    stb       ,u+                 ; store received byte to memory
                    abx                           ; update checksum
                    subr      w,y                 ; decrement request count
                    inca                          ; A = 1 for reading stop bit
                    anda      <BBIN               ; read stop bit
                    bls       rxExit              ; exit if completed or framing error

* Wait for a start bit or timeout
rx0030              clrw                          ; initialize timeout counter
rx0040              bita      <BBIN               ; check for start bit
                    beq       rxByte              ; branch if start bit detected
                    addw      #1                  ; bump timeout counter
                    bita      <BBIN
                    beq       rxByte
                    bcc       rx0040              ; loop until timeout rolls over
                    lda       #$03                ; setup to return TIMEOUT status

* Clean up, set status and return
rxExit              beq       rx0050              ; branch if framing error
                    eora      #$02                ; toggle SUCCESS flag
rx0050              inca                          ; A = status to be returned in C and Z
                    ora       ,s                  ; place status information into the..
                    sta       ,s                  ; ..C and Z bits of the preserved CC
                    leay      ,x                  ; return checksum in Y
                    puls      cc,dp,x,u,pc        ; restore registers and return
                    setdp     $00
