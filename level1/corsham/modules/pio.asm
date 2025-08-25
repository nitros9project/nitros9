********************************************************************
* pio - Corsham Arduino Parallel I/O Low Level Subroutine Module
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2017/05/09  Boisy G. Pitre
* Started.
*
                    nam       pio
                    ttl       Corsham Arduino Parallel I/O Low Level Subroutine Module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,start,0

name                fcs       /pio/

* PIA subroutine entry table
start               bra       Init
                    nop
                    bra       PIARead
                    nop
                    bra       PIAWrite
                    nop

* Term
*
* Entry:
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Term
                    clrb                          clear Carry
                    rts


* Init
*
* Entry:
*    Y  = address of device descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
* Initialize the serial device
Init
;
; Set up the data direction register for port B so that
; the DIRECTION and PSTROBE bits are output.
;
                    pshs      d,x
                    ldx       #PIA0Base
                    clr       PIACTLB,x           ;select DDR ...for port B
                    ldd       #$04*256+DIRECTION|PSTROBE
                    stb       PIADDRB,x
                    sta       PIACTLB,x
                    bsr       xParSetWrite
                    puls      d,x,pc

; Fall through to set up for writes...
;
                    page
;*****************************************************
; This sets up for writing to the Arduino.  Sets up
; direction registers, drives the direction bit, etc.
;
; Entry: X = PIA Base
;
; All registers preserved
;
xParSetWrite        pshs      d
                    ldd       #$0004
                    sta       PIACTLA,x           ; select DDRfor port A
                    deca                          ; A $00 => $FF
                    sta       PIADDRA,x
                    stb       PIACTLA,x           ;select data reg
;
; Set direction flag to output, clear ACK bit
;
                    lda       #DIRECTION
                    sta       PIAREGB,x
                    puls      d,pc

                    page
;*****************************************************
; This sets up for reading from the Arduino.  Sets up
; direction registers, clears the direction bit, etc.
;
; Entry: X = PIA
;
; All registers preserved
;
xParSetRead         pshs      b
                    ldb       #$04
                    clr       PIACTLA,x           ;select DDR for port A
                    clr       PIADDRA,x
                    stb       PIACTLA,x           ;select data reg
;
; Set direction flag to input, clear ACK bit
;
                    clr       PIAREGB,x
                    puls      b,pc

                    page
;*****************************************************
; Entry: X = address of bytes to write
;        Y = byte count
;
; All registers preserved.
;
; Write cycle:
;
;    1. Wait for other side to lower ACK.
;    2. Put data onto the bus.
;    3. Set DIRECTION and PSTROBE to indicate data
;       is valid and ready to read.
;    4. Wait for ACK line to go high, indicating the
;       other side has read the data.
;    5. Lower PSTROBE.
;    6. Wait for ACK to go low, indicating end of
;       transfer.
;
PIAWrite            pshs      b,x,y,u             ;save data
                    tfr       x,u
                    ldx       #PIA0Base
                    bsr       xParSetWrite
Parwl22             ldb       PIAREGB,x           ;check status
                    andb      #ACK
                    bne       Parwl22             ;wait for ACK to go low

;
; Now put the data onto the bus
;
nextbyte@           ldb       ,u+
                    stb       PIAREGA,x
;
; Raise the strobe so the Arduino knows there is
; new data.
;
                    ldb       PIAREGB,x
                    orb       #PSTROBE
                    stb       PIAREGB,x
;
; Wait for ACK to go high, indicating the Arduino has
; pulled the data and is ready for more.
;
Parwl33             ldb       PIAREGB,x
                    andb      #ACK
                    beq       Parwl33
;
; Now lower the strobe, then wait for the Arduino to
; lower ACK.
;
                    ldb       PIAREGB,x
                    andb      #~PSTROBE
                    stb       PIAREGB,x
Parwl44             ldb       PIAREGB,x
                    andb      #ACK
                    bne       Parwl44
                    leay      -1,y
                    bne       nextbyte@

                    puls      b,x,y,u,pc

                    page
;*****************************************************
; Entry: X = address of buffer to hold bytes
;        Y = byte count
;
; This does not have a time-out.
;
; Preserves all registers.
;
; Read cycle:
;
;    1. Wait for other side to raise ACK, indicating
;       data is ready.
;    2. Read data.
;    3. Raise PSTROBE indicating data was read.
;    4. Wait for ACK to go low.
;    5. Lower PSTROBE.
;
PIARead
                    pshs      b,x,y,u
                    tfr       x,u
                    ldx       #PIA0Base
                    bsr       xParSetRead
rloop@              ldb       PIAREGB,x
                    andb      #ACK                ;is their strobe high?
                    beq       rloop@              ;nope, no data
;
; Data is available, so grab and save it.
;
                    ldb       PIAREGA,x
                    stb       ,u+
;
; Now raise our strobe (their ACK), then wait for
; them to lower their strobe.
;
                    ldb       PIAREGB,x
                    orb       #PSTROBE
                    stb       PIAREGB,x
Parrlp1             ldb       PIAREGB,x
                    andb      #ACK
                    bne       Parrlp1             ;still active
;
; Lower our ack, then we're done.
;
                    ldb       PIAREGB,x
                    andb      #~PSTROBE
                    stb       PIAREGB,x
                    leay      -1,y
                    bne       rloop@
                    puls      b,x,y,u,pc

                    emod
eom                 equ       *
                    end
