                    ifeq      H6309-1

*******************************************************
*
* DWWrite  -  6309 native Turbo Edition  115k / 230k
*    Send a packet to the DriveWire server.
*    Serial data format:  8-N-2
*
* Entry:
*    X  = address of the data to be sent
*    Y  = number of bytes to send
*
* Exit:
*    X  = address of last byte sent + 1
*    Y  = 0
*    All others preserved
*
BBOUT               equ       $FF20               ; bit banger output port

DWWrite             pshs      u,d,cc              ; preserve registers
                    orcc      #$50                ; mask interrupts
                    ldu       #BBOUT              ; point U to output port
                    aim       #$F7,3,u            ; disable sound output

* Wait for serial input line to become idle
wait1               lda       2,u                 ; sample input
                    ldb       #$80                ; setup ACCB as a shift counter
wait2               eora      2,u                 ; look for changing input
                    lsra                          ; shift 'changed' bit into Carry
                    lda       2,u                 ; sample input
                    rorb                          ; rotate 'changed' bit into ACCB
                    bcc       wait2               ; loop for 8 samples
                    bne       wait1               ; try again if changes seen in the input

* Byte transmitter loop
                    incb                          ; ACCB = 1 (start bit / byte incrementor)
txByte              lda       ,x                  ; get data byte
                    stb       ,u                  ; send start bit
                    asla                          ; move bit 0 into position
                    abx                           ; increment data ptr
                    sta       ,u++                ; bit 0
                    rora
                    nop
                    sta       ,--u                ; bit 1
                    lsra
                    sta       ,u++                ; bit 2
                    lsra
                    nop
                    sta       ,--u                ; bit 3
                    lsra
                    nop
                    sta       ,u++                ; bit 4
                    lsra
                    nop
                    sta       ,--u                ; bit 5
                    lsra
                    sta       ,u++                ; bit 6
                    lsra
                    aslb                          ; ACCB = 2 (stop bit)
                    sta       ,--u                ; bit 7
                    leau      ,u
                    stb       ,u                  ; send stop bit
                    lsrb                          ; ACCB = 1 (start bit / byte incrementor)
                    leay      -1,y                ; decrement counter
                    bne       txByte              ; loop if more bytes to send

                    puls      cc,d,u,pc           ; restore registers and return

                    else

*******************************************************
*
* DWWrite  -  6809 Turbo Edition  115k / 230k
*    Send a packet to the DriveWire server.
*    Serial data format:  8-N-2
*
* Entry:
*    X  = address of the data to be sent
*    Y  = number of bytes to send
*
* Exit:
*    X  = address of last byte sent + 1
*    Y  = 0
*    All others preserved
*
*BBOUT	equ	$FF20		; bit banger output port

DWWrite             pshs      u,d,cc              ; preserve registers
                    orcc      #$50                ; mask interrupts
                    ldu       #BBOUT              ; point U to output port
                    lda       3,u                 ; read PIA 1-B control register
                    anda      #$F7                ; clear sound enable bit
                    sta       3,u                 ; disable sound output

* Wait for serial input line to become idle
wait1               lda       2,u                 ; sample input
                    ldb       #$80                ; setup ACCB as a shift counter
wait2               eora      2,u                 ; look for changing input
                    lsra                          ; shift 'changed' bit into Carry
                    lda       2,u                 ; sample input
                    rorb                          ; rotate 'changed' bit into ACCB
                    bcc       wait2               ; loop for 8 samples
                    bne       wait1               ; try again if changes seen in the input

* Byte transmitter loop
                    ldb       #2
                    lda       ,x                  ; retrieve first byte from buffer
txByte              decb                          ; ACCB = 1 (start bit / byte incrementor)
                    abx                           ; increment data ptr
                    stb       ,u                  ; send start bit
                    asla                          ; move bit 0 into position
                    nop
                    sta       ,u                  ; bit 0
                    rora
                    sta       ,u+                 ; bit 1
                    lsra
                    sta       -1,u                ; bit 2
                    lsra
                    sta       ,-u                 ; bit 3
                    lsra
                    incb                          ; ACCB = 2 (stop bit)
                    sta       ,u                  ; bit 4
                    lsra
                    sta       ,u+                 ; bit 5
                    lsra
                    sta       -1,u                ; bit 6
                    lsra
                    sta       ,-u                 ; bit 7
                    lda       ,x                  ; fetch next byte
                    stb       ,u                  ; send stop bit
                    leay      -1,y                ; decrement counter
                    bne       txByte              ; loop if more bytes to send

                    puls      cc,d,u,pc           ; restore registers and return

                    endc
