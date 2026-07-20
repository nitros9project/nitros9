;;; Simple sd/spi driver.  Lifted from Gary Becker's
;;; Nitros9 drivers.
;;;
;;;  This will deblock 256 bytes, but only on reads -
;;;  there is no provision for writing partial sectors.
;;;
;;;  To use Run-Time:
;;;    * load up the public interface variables, call ll_read
;;;    * LSN address is always in 512B sectors nos.
;;;

                    export    DPTR
                    export    LSN
                    export    SMALL
                    export    ll_read
                    export    ll_init

EIO                 equ       1                   ; Error on Read
EWP                 equ       2                   ; Error on Write Protect
ENR                 equ       3                   ; Error on Not Ready
IntMasks            equ       $50                 ; shut off firq,irq interrupts
HwBase              equ       $ff64               ; hardware base address
Carry               equ       $1                  ; CC's carry bit

                    .area     .bss
;;; Public interface variables
DPTR                rmb       2                   ; data address
LSN                 rmb       3                   ; 24 bit lsn :(
SMALL               rmb       1                   ; 0=512B read, 1=256B read, -1=256B 2nd 1/2 read

;;; Internal interface
SDVersion           rmb       1                   ; 0 = Byte Addressable SD
                    ;         !0                  = Sector Addressable SD
CMDStorage          rmb       1                   ; Command storage area for read/write CMDs
SD_SEC_ADD          rmb       4                   ; Four bytes - some devices are byte addressable
CMDCRC              rmb       1                   ; CRC

                    .area     .code
;;; A Table of pre-done 6 byte commands
;;;   This is const
CMD0                fcb       $40,$00,$00,$00,$00,$95
*CMD1     fcb   $41,$00,$00,$00,$00,$95
CMD8                fcb       $48,$00,$00,$01,$AA,$87
*CMD13    fcb   $4D,$00,$00,$00,$00,$95
CMD16               fcb       $50,$00,$00,$02,$00,$FF
ACMD41V1            fcb       $69,$00,$00,$00,$00,$FF
ACMD41V2            fcb       $69,$40,$00,$00,$00,$FF
CMD55               fcb       $77,$00,$00,$00,$00,$FF
CMD58               fcb       $7A,$00,$00,$00,$00,$FF

* Read/Write commands
CMDRead             equ       $5100               Command to read a single block
CMDWrite            equ       $5800               Command to write a sector
CMDEnd              equ       $00FF               Every command ends with $95
* SPI Address Equates
* SPI Control Register
SPICTRL             equ       0
SLOT_SEL_0          equ       1
SPI_IRQ_EN          equ       $40
SPI_EN              equ       $80                 Sets SPI enable and IRQ enable
* SPI Status Register
SPISTAT             equ       0
CARD_DET_0          equ       1
CARD_LOCK_0         equ       2
IRQ_SLOT_0          equ       $80
* SPI Transmit / Receive Register
SPIDAT              equ       1


;;; ll_read - Low level read routine
;;;   takes: parameters in public interface
;;;   returns: C set on error, B = error
;;;   modified: all
ll_read
                    orcc      #IntMasks           ; disable interrupts
                    ldx       #HwBase             ; Get address of hardware
                    lda       SPISTAT,x           ; check for card
                    lsra
                    lbcc      NOTRDY              ; No card installed, so no reads
d@                  ldd       #CMDRead
                    std       CMDStorage          ; Read command and clear MSB of address
                    ldd       #CMDEnd
                    std       SD_SEC_ADD+3        ; Clear LSB of address and CRC
                    lda       #(SPI_EN+SLOT_SEL_0) ; but not IRQ enable
                    bsr       LSNMap0             ; apply the approipraite LSN, send cmd
                    lbcs      IOERR               ; If we timed out, branch with error
                    lbne      IOERR               ; If the R1 was not 0
                    ;;        wait                for a FE
a@                  lda       SPIDAT,x            ; Send FF (receive a byte) until we get FE
                    cmpa      #$FE                ; is FE
                    nop       ;
                    bne       a@                  ; no: loop
                    ;;        read                bytes
                    ldy       DPTR                ; Get the sector buffer address
                    tst       SMALL               ; small blocks?
                    beq       read512@            ; no go read all 512
                    bmi       otherhalf@          ; go read second 1/2
                    bsr       read256             ; read 1st half of sector
                    bsr       drop256             ;
                    bra       b@                  ; continue
otherhalf@
                    bsr       drop256             ; read 2nd half of sector
                    bsr       read256             ;
                    bra       b@                  ; continue
read512@
                    bsr       read256             ; read all 512 bytes of sector
                    bsr       read256             ;
                    ;;        get                 CRC
b@                  lda       SPIDAT,x            ; Send 2x FF to get the CRC
                    nop
                    nop
                    lda       SPIDAT,x            ; We ignore the CRC
                    ;;;       No                  errors, exit
c@                  lbra      RETOK
                    ;;        Errors,             exit


;;; Read 256 bytes
;;;   takes: Y = ptr to data
;;;   takes: X = hwbase
;;;   modifies: Y, B, A
read256
                    ldb       #128                ; counter 128
a@                  lda       SPIDAT,x            ; get one byte
                    sta       ,y+                 ; store in buffer
                    lda       SPIDAT,x            ; get another byte
                    sta       ,y+                 ; store in counter
                    decb                          ; bump counter
                    bne       a@                  ; not done? then loop
                    rts                           ; return

;;; Drop 256 bytes
;;;   takes: Y = ptr to data
;;;   takes: X = hwbase
;;;   modifies: Y, B, A
drop256
                    ldb       #128                ; counter = 128
a@                  lda       SPIDAT,x            ; get one byte
                    nop       ;                   delay
                    nop       ;                   delay
                    lda       SPIDAT,x            ; get another byte
                    decb                          ; bump counter
                    bne       a@                  ; not done? then loop
                    rts                           ; return


;;; Map LSN into command buffer, sends command
;;;   takes: A = CNTL bits, command packet loaded (except lsn)
;;;   returns: C set on error, Z = 0 on R1 error ?
;;;   modifies: A
;;;
;;; SD/MMC uses a 32 bit byte mapping for the LSN, so we must shift the
;;; logical LSN up one bit and then clear the 4th byte to build the
;;; correct LSN string
;;;
;;; SDHC uses a 32 bit 512 byte sector mapping for the LSN.So there is
;;; no need to shift the LSN we can just write it as is and clear out the
;;; upper LSN byte, because we only get 3 bytes from coco for LSN
LSNMap0
                    sta       SPICTRL,x
                    nop
                    lda       SPIDAT,x            ; Send 1 FF
                    lda       SDVersion
                    bne       secadd              ; GoTo Sector Address type
                    ;;        Apply               lsn to byte addressing mmc
                    ldd       LSN+1               ; bytes 1 and 2 (middle and LSB)
                    aslb                          ; Byte address needs to be shifter one more bit
                    rola
                    std       SD_SEC_ADD+1        ; save in byte 1,2
                    lda       LSN                 ; calc MSB
                    rola
                    sta       SD_SEC_ADD          ; store in byte 0
                    bra       merge
                    ;;        apply               lsn to sector addressing SD/HC
secadd              ldd       LSN+1               ; just copy it
                    std       SD_SEC_ADD+2
                    lda       LSN
                    sta       SD_SEC_ADD+1
                    ;;        two                 method merge here
merge               lda       SPIDAT,x            ; Send 1 FF
                    ldy       #CMDStorage
                    ;;        Fall                through to cmdsend

* cmdsend - Sends a 6 byte command
* Entry:  X = HW addr
*         Y = Address of first byte of command sequence
* Exit:
* Registers preserved: all but A/B/X
cmdsend
                    lda       ,y
                    sta       $FF66
                    ldb       #6
a@                  lda       ,y+
                    sta       SPIDAT,x
                    decb
                    bne       a@
                    andcc     #^Carry             ; Clear Carry
                    ldb       #$00                ; Probably too much
b@                  lda       SPIDAT,x            ; send FF, wait till + flipped 7 bit
                    bpl       c@                  ;
                    decb                          ; bump counter
                    bne       b@                  ; not done, loop
                    comb                          ; set carry for error
c@                  rts                           ; return

* ll_write - Low level write routine
*
* Entry:
*    Registers:
*    Static Variables of interest:
*      PhysSect = starting physical sector to write to
*      SectSize = physical sector size (0=256,1=512,2=1024,3=2048)
*
* Exit:
*    All registers may be modified
*    Static variables may NOT be modified
ll_write
                    orcc      #IntMasks           ; disable interrupts
                    ldx       #HwBase             ; Get address of hardware
                    lda       SPISTAT,x
                    lsra
                    lbcc      NOTRDY              ; no card - go not ready
                    lsra                          ; bit one is WP
                    lbcs      WPERR               ; Write Protected, then exit with WP error
                    ldd       #CMDWrite           ; load up write command
                    std       CMDStorage          ;
                    ldd       #CMDEnd             ; put LSB of LSN and CRC :)
                    std       SD_SEC_ADD+3        ;
                    lda       #(SPI_EN+SLOT_SEL_0)
                    bsr       LSNMap0             ; apply the appropriate LSN, sends cmd
                    bcs       IOERR               ; error?
                    bne       IOERR               ; error?
                    lda       SPIDAT,x            ; 2 bytes >= 1 byte after R1
                    nop       ;                   Might not be enough ?????
                    nop
                    lda       SPIDAT,x
                    lda       #$FE                ; Start of sector byte and clear counter
                    sta       SPIDAT,x            ; Mark the start of the sector
                    nop       ;                   Too much ???????
                    ;;        Write               the 512 Byte sector
                    ldy       DPTR                ; Y = data buffer
                    clrb                          ; B = 256 byte counter
a@                  lda       ,y+                 ; get a byte from buffer
                    sta       SPIDAT,x            ; write it to SD
                    nop       ;                   wait a bit
                    lda       ,y+                 ; get another byte from buffer
                    sta       SPIDAT,x            ; write it
                    decb                          ; bump counter
                    bne       a@                  ; repeat if not done
                    ;;        get                 crc
                    lda       SPIDAT,x            ; send two FFs as CRC
                    nop
                    nop       ;                   Might not be enough ???????
                    stb       SPIDAT,x            ; Second FF (send 0 to check)
                    cmpa      #$E5                ; Response - Data accepted token
                    beq       fnd0                ; First byte? no? check four more bytes.
                    ;;        Make                sure the response was accepted
                    lda       SPIDAT,x            ; get response
                    cmpa      #$E5                ; Data accepted token
                    beq       fnd0                ;
                    lda       SPIDAT,x            ; check again
                    cmpa      #$E5                ;
                    beq       fnd0                ;
                    lda       SPIDAT,x            ; check again
                    cmpa      #$E5                ;
                    beq       fnd0                ;
                    lda       SPIDAT,x            ; check again
                    cmpa      #$E5                ;
                    bne       IOERR               ; Write error
                    ;;        Check               to see if the write is complete
fnd0                lda       SPIDAT,x
                    beq       lpwr2               ; could be a bne but
                    bra       fnd0                ; I want the extra cycles
lpwr2               lda       SPIDAT,x
                    cmpa      #$FF
                    beq       wfin
                    bra       lpwr2
wfin                ldb       #10                 ; Lets send 16 more FF just in case
b@                  lda       SPIDAT,x
                    decb
                    bne       b@
                    ;;        No                  error so exit
                    bra       RETOK

* Error handlers

RETOK               ldd       #$0000              ; return the disaster of No Error
                    clr       SPICTRL,x
*	andcc	#^IntMasks
                    clra
                    rts

WPERR               ldd       #$0000+EWP
                    bra       a@
IOERR
                    ldd       #$0000+EIO
                    bra       a@
NOTRDY
                    ldd       #$0000+ENR
a@
                    sta       SPICTRL,x           ; Set the hardware
*	andcc   #^IntMasks      ; Enable interrupts
                    coma                          ; Set Carry
                    rts


* ll_init - Low level init routine
* Entry:
*    Y  = address of device descriptor
*    U  = address of low level device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
* Note: This routine is called ONCE: for the first device
* IT IS NOT CALLED PER DEVICE!
*

ll_init
                    orcc      #IntMasks           ; disable interrupts
                    ldx       #HwBase             ; load x with the hw address for the IRQ routine
                    lda       SPISTAT,x
                    lsra
                    bcc       NOTRDY              ; If there is no card, nothing to do
                    ;;        Enable              SPI
                    lda       #SPI_EN             ; Enable SPI Interface, but not CS
                    sta       SPICTRL,x
                    ;;        send                74 clock cycles, no SS
                    ldb       #$10
a@                  lda       SPIDAT,x            ; Send FF
                    decb                          ; 2 cycles, need 4
                    nop
                    bne       a@                  ; 3 Cycles
                    ;;        Initialize          card 0
CRD0                lda       #SPI_EN+SLOT_SEL_0  ; Enable SPI and lower CS
                    sta       SPICTRL,x
                    ;;        Send                CMD0
                    lda       SPIDAT,x            ; Send 1 FF
                    nop       ;                   ????????? enough
                    ldy       #CMD0               ; Might need more cycles ???????
                    lda       SPIDAT,x            ; Send 1 more FF

                    lbsr      cmdsend             ; Also does a GETR1

                    bcs       NOTRDY
                    anda      #$7E                ; Idle is ok
                    bne       NOTRDY              ; but nothing else
                    ;;        Send                CMD8
                    lda       SPIDAT,x            ; Send 1 FF
                    nop
                    ldy       #CMD8               ; Might need more cycles ??????
                    lda       SPIDAT,x            ; Sens 1 more FF
                    lbsr      cmdsend             ; Also does an GETR1
                    bcs       SDV1
                    anda      #$7E
                    bne       SDV1
                    lda       SPIDAT,x            ; Byte 1 of R3/R7, through it away
                    nop
                    nop
                    nop
                    lda       SPIDAT,x            ; Byte 2 of R3/R7, throught it away
                    nop
                    nop
                    nop
                    lda       SPIDAT,x            ; Byte 3 of R3/R7, should be 1
                    cmpa      #$01                ; 2 cycles
                    bne       NOTRDY              ; 2 cycles
                    nop
                    lda       SPIDAT,x            ; Byte 4 of R3/R7, should be $AA
                    cmpa      #$AA                ; 2 cycles
                    bne       NOTRDY              ; 2 cycles
                    nop
                    ;;        Send                ACMD41 by first CMD55
loop41V2
                    lda       SPIDAT,x            ; Send 1 FF
                    nop
                    ldy       #CMD55              ; might need more ??????
                    lda       SPIDAT,x            ; Send 1 FF
                    lbsr      cmdsend             ; Also does an GETR1
                    bcs       NOTRDY
                    anda      #$7E                ; Idle is ok
                    bne       NOTRDY              ; but nothing else
                    ;;        Send                ACMD41
                    lda       SPIDAT,x
                    nop
                    ldy       #ACMD41V2
                    lda       SPIDAT,x
                    lbsr      cmdsend
                    bcs       NOTRDY              ; No response
                    beq       Send58              ; If 0 then CMD58
                    cmpa      #$01                ; if 1 then try again
                    beq       loop41V2
                    lbra      NOTRDY
                    ;;        Send                CMD58
Send58              lda       SPIDAT,x
                    nop
                    ldy       #CMD58              ; Read OCR
                    lda       SPIDAT,x
                    lbsr      cmdsend
                    lbcs      NOTRDY
                    lda       SPIDAT,x            ; Byte 1 of OCR
                    anda      #$40                ; CCS bit 1= sector 0= byte
                    sta       SDVersion
                    lda       SPIDAT,x            ; Byte 2 of R3/R7, through it away
                    nop
                    nop
                    lda       SPIDAT,x            ; Byte 3 of R3/R7, through it away
                    nop
                    nop
                    lda       SPIDAT,x            ; Byte 4 of R3/R7, through it away
                    lda       SDVersion           ; 0 = byte addressable, !0 = block addressable
                    bne       FININIT
                    bra       Send16
                    ;;        Send                ACMD41 by first CMD55
SDV1
loop41V1
                    lda       SPIDAT,x            ; Get extra bytes in case of bad R7 previously
                    nop
                    lda       SPIDAT,x
                    clr       SDVersion           ; Byte addressable
                    lda       SPIDAT,x
                    ldy       #CMD55
                    lda       SPIDAT,x
                    lbsr      cmdsend
                    lbcs      NOTRDY
                    anda      #$7E                ; Idle is ok
                    lbne      NOTRDY              ; but nothing else
                    ;;        send                ACMD41
                    lda       SPIDAT,x
                    ldy       #ACMD41V1
                    lda       SPIDAT,x
                    lbsr      cmdsend
                    lbcs      NOTRDY
                    beq       Send16              ; If 0 then CMD16
                    cmpa      #$01                ; if 1 then try again
                    beq       loop41V1
                    lbra      NOTRDY
                    ;;        send                CMD16
                    *         Send                CMD16
Send16              lda       SPIDAT,x
                    ldy       #CMD16
                    lda       SPIDAT,x
                    lbsr      cmdsend
                    lbne      NOTRDY              ; but nothing else
                    ;;        finished
FININIT             lda       SPIDAT,x            ; Send last FF
                    nop
                    nop
                    lda       #SPI_EN             ; Turn on SPI and turn off CS
                    sta       SPICTRL,x
                    rts
