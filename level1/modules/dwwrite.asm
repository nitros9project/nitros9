*******************************************************
*
* DWWrite
*    Send a packet to the DriveWire server.
*    Serial data format:  1-8-N-1
*    4/12/2009 by Darren Atkinson
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


                    ifne      ARDUINO
DWWrite             pshs      a                   ; preserve registers
txByte
                    lda       ,x+                 ; get byte from buffer
                    sta       $FF52               ; put it to PIA
loop@               tst       $FF53               ; check status register
                    bpl       loop@               ; until CB1 is set by Arduino, continue looping
                    tst       $FF52               ; clear CB1 in status register
                    leay      -1,y                ; decrement byte counter
                    bne       txByte              ; loop if more to send
                    puls      a,pc                ; restore registers and return

                    else

                    ifne      SY6551N
                    ifndef    SY6551B
SY6551B             equ       $FF68               ; Set base address for future use
                    endc
                    ifndef    SYDATA
SYDATA              equ       SY6551B
                    endc
                    ifndef    SYCONT
SYCONT              equ       SY6551B+3
                    endc
                    ifndef    SYCOMM
SYCOMM              equ       SY6551B+2
                    endc
                    ifndef    SYSTAT
SYSTAT              equ       SY6551B+1
                    endc
                    ifndef    SYCONSET
SYCONSET            equ       $10                 ; Default baud rate 115200
                    endc
DWWrite             pshs      d,cc                ; preserve registers
                    ifeq      NOINTMASK
                    orcc      #IntMasks           ; mask interrupts
                    endc
                    lda       #SYCONSET           ; Set baud to value of SYCONSET
                    sta       SYCONT              ; write the info to register
                    lda       #$0B                ; Set no parity, no irq
                    sta       SYCOMM              ; write the info to register
txByte
                    lda       SYSTAT              ; read status register to check
                    anda      #$10                ; if transmit buffer is empty
                    beq       txByte              ; if not loop back and check again
                    lda       ,x+                 ; load byte from buffer
                    sta       SYDATA              ; and write it to data register
                    leay      -1,y                ; decrement byte counter
                    bne       txByte              ; loop if more to send
                    puls      cc,d,pc             ; restore registers and return
                    else
                    ifne      JMCPBCK
DWWrite             pshs      d,cc                ; preserve registers
                    orcc      #$50                ; mask interrupts
txByte
                    lda       ,x+
                    sta       $FF44
                    leay      -1,y                ; decrement byte counter
                    bne       txByte              ; loop if more to send

                    puls      cc,d,pc             ; restore registers and return

                    else
                    ifne      BECKER
                    ifndef    BECKBASE
BECKBASE            equ       $FF41               ; Set base address for future use
                    endc
DWWrite             pshs      d,cc                ; preserve registers
                    orcc      #$50                ; mask interrupts
txByte
                    lda       ,x+
                    sta       BECKBASE+1
                    leay      -1,y                ; decrement byte counter
                    bne       txByte              ; loop if more to send

                    puls      cc,d,pc             ; restore registers and return
                    else
                    ifne      BECKERTO
                    ifndef    BECKBASE
BECKBASE            equ       $FF41               ; Set base address for future use
                    endc
DWWrite             pshs      d,cc                ; preserve registers
                    orcc      #$50                ; mask interrupts
txByte
                    lda       ,x+
                    sta       BECKBASE+1
                    leay      -1,y                ; decrement byte counter
                    bne       txByte              ; loop if more to send

                    puls      cc,d,pc             ; restore registers and return
                    endc
                    endc
                    endc
                    endc

                    ifeq      BECKER+JMCPBCK+ARDUINO+BECKERTO+SY6551N
                    ifeq      BAUD38400+H6309
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
                    else

                    ifne      BAUD38400
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


                    else
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


                    endc
                    endc
                    endc
                    endc
