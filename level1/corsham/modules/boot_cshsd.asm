********************************************************************
* Boot - Corsham SD Boot module
* Provides HWInit, HWTerm, HWRead which are called by code in
* "use"d boot_common.asm
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2017/05/01  Darren Atkinson
* Created.

                    nam       Boot
                    ttl       Corsham SD Boot module

                    ifp1
                    use       defsfile
                    endc

                    org       0
* Default Boot is from drive 0
BootDr              set       0

* Alternate Boot is from drive 1
                    ifeq      DNum-1
BootDr              set       1
                    endc

* Common booter-required defines
LSN24BIT            equ       1
FLOPPY              equ       0

* NOTE: these are U-stack offsets, not DP
seglist             rmb       2                   pointer to segment list
blockloc            rmb       2                   pointer to memory requested
blockimg            rmb       2                   duplicate of the above
bootsize            rmb       2                   size in bytes
LSN0Ptr             rmb       2                   In memory LSN0 pointer
size                equ       .


tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

name                fcs       /Boot/
                    fcb       edition


*--------------------------------------------------------------------------
* HWInit - Initialize the device
*
*    Entry:
*       Y  = hardware address
*
*    Exit:
*       Carry Clear = OK, Set = Error
*       B  = error (Carry Set)
*
HWInit
;
; Set up the data direction register for port B so that
; the DIRECTION and PSTROBE bits are output.
;
                    ldx       #PIA0Base
                    clr       PIACTLB,x           ;select DDR ...for port B
                    ldd       #$04*256+DIRECTION|PSTROBE
                    stb       PIADDRB,x
                    sta       PIACTLB,x
                    lbsr      xParSetWrite

*--------------------------------------------------------------------------
* HWTerm - Terminate the device
*
*    Entry:
*       Y  = hardware address
*
*    Exit:
*       Carry Clear = OK, Set = Error
*       B = error (Carry Set)
*
HWTerm              clrb                          no error
                    rts

***************************************************************************
                    use       boot_common.asm
***************************************************************************

*
* HWRead - Read a 256 byte sector from the device
*
*    Entry:
*       Y  = hardware address
*       B  = bits 23-16 of LSN
*       X  = bits 15-0  of LSN
*       blockloc,u = where to load the 256 byte sector
*
*    Exit:
*       Carry Clear = OK, Set = Error
*
HWRead
                    ldy       blockloc,u

;=====================================================
; This is a low level disk function for a real OS to
; perform a disk sector read using a single long
; sector number.  On entry, X points to a disk
; parameter block with the following fields:
;
;    B = sector bits 23-16
;    X = sector bits 15-0
;    Y = address to store 256 byte buffer
;
; The drive and sector number are zero based.
;
; Returns with C clear on success.  If error, C is set
; and A contains the error code.
;
DiskReadLong        lda       #PC_READ_LONG
                    bsr       xParWriteByte
                    clra
                    bsr       xParWriteByte       ;drive
                    lda       #2                  ;256 byte sectors
                    bsr       xParWriteByte
;
; Now send the four byte sector number.
;
                    clra
                    bsr       xParWriteByte
                    tfr       b,a
                    bsr       xParWriteByte
                    tfr       x,d
                    bsr       xParWriteByte
                    tfr       b,a
                    bsr       xParWriteByte
;*****************************************************
; This sets up for reading from the Arduino.  Sets up
; direction registers, clears the direction bit, etc.
;
xParSetRead         ;select   DDR
                    ldx       #PIA0Base
                    clr       PIACTLA,x           ;...for port A
                    clr       PIADDRA,x
                    lda       #4                  ;select data reg
                    sta       PIACTLA,x
;
; Set direction flag to input, clear ACK bit
;
                    clr       PIAREGB,x

                    bsr       xParReadByte        ;response
                    cmpa      #PR_SECTOR_DATA     ;data?
                    bne       DiskCerror          ;no
;
                    lda       #'.
                    jsr       [S.CharOut]
                    clrb                          ;256 bytes of data
DiskReadLp          bsr       xParReadByte
                    sta       ,y+
                    decb
                    bne       DiskReadLp
;
; All done
;
;*****************************************************
; This sets up for writing to the Arduino.  Sets up
; direction registers, drives the direction bit, etc.
;
xParSetWrite        clra                          ;select DDR
                    sta       PIACTLA,x           ;...for port A
                    deca                          ; $FF set bits for output
                    sta       PIADDRA,x
                    lda       #4                  ;select data reg
                    sta       PIACTLA,x
;
; Set direction flag to output, clear ACK bit
;
                    lda       #DIRECTION
                    sta       PIAREGB,x

                    ldx       blockloc,u

                    clrb
                    rts

;
; Common error handler.  Next byte is the error code
; which goes into B, set carry, and exit.
;
DiskCerror          bsr       xParReadByte
                    lda       #'?
                    jsr       [S.CharOut]
                    comb
                    ldb       #E$Read
                    rts


;*****************************************************
; This writes a single byte to the Arduino.  On entry,
; the byte to write is in A.  This assumes ParSetWrite
; was already called.
;;
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
xParWriteByte       pshs      b,x                 ;save data
                    ldx       #PIA0Base
Parwl22             ldb       PIAREGB,x           ;check status
                    andb      #ACK
                    bne       Parwl22             ;wait for ACK to go low
;
; Now put the data onto the bus
;
                    sta       PIAREGA,x
;
; Raise the strobe so the Arduino knows there is
; new data.
;
                    lda       PIAREGB,x
                    ora       #PSTROBE
                    sta       PIAREGB,x
;
; Wait for ACK to go high, indicating the Arduino has
; pulled the data and is ready for more.
;
Parwl33             lda       PIAREGB,x
                    anda      #ACK
                    beq       Parwl33
;
; Now lower the strobe, then wait for the Arduino to
; lower ACK.
;
                    lda       PIAREGB,x
                    anda      #~PSTROBE
                    sta       PIAREGB,x
Parwl44             lda       PIAREGB,x
                    anda      #ACK
                    bne       Parwl44
                    puls      b,x,pc

;*****************************************************
; This reads a byte from the Arduino and returns it in
; A.  Assumes ParSetRead was called before.
;
; This does not have a time-out.
;
; Preserves all other registers.
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
xParReadByte        pshs      a,x
                    ldx       #PIA0Base
parloop@            lda       PIAREGB,x
                    anda      #ACK                ;is their strobe high?
                    beq       parloop@            ;nope, no data
;
; Data is available, so grab and save it.
;
                    lda       PIAREGA,x
                    sta       ,s
;
; Now raise our strobe (their ACK), then wait for
; them to lower their strobe.
;
                    lda       PIAREGB,x
                    ora       #PSTROBE
                    sta       PIAREGB,x
Parrlp1             lda       PIAREGB,x
                    anda      #ACK
                    bne       Parrlp1             ;still active
;
; Lower our ack, then we're done.
;
                    lda       PIAREGB,x
                    anda      #~PSTROBE
                    sta       PIAREGB,x
                    puls      a,x,pc


                    page

Address             fdb       $0000

                    emod
eom                 equ       *
EOMSize             equ       *-Address

                    end
