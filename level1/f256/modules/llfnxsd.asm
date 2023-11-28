*******************************************************************
* llfnxsd - Foenix low-level SDHC/SD/MMC driver
*
* This driver works with the following cards:
*
*  - Samsung 32GB EVO Select (microSDXC card using an SD card adapter)
*  - Samsung 256GB EVO Select (microSDXC card using an SD card adapter)
*  - Kingston 32GB Canvas Select Plus SDHC (verified by Stefany Allaire)
*  - Sandisk 64GB ImageMate Plus (after consulting with https://electronics.stackexchange.com/questions/303745/sd-card-initialization-problem-cmd8-wrong-response)
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*     1    2023/10/29  Boisy Gene Pitre.
* Created.

                    use       defsfile
                    use       rbsuper.d

tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       0
edition             set       4

                    mod       eom,name,tylg,atrv,start,0

* Set to 1 to get verbose debugging (not recommended).
SD_DEBUG            equ       0

                    org       V.LLMem
* Low-level driver static memory area.
SEC_CNT             rmb       1                   number of sectors to transfer
SEC_LOC             rmb       2                   where they are or where they go
SEC_ADD             rmb       3                   LSN of sector
SDVersion           rmb       1                   0 = byte addressable SD, !0 = sector addressable SD
CMDStorage          rmb       1                   command storage area for read/write commands
SD_SEC_ADD          rmb       4                   four bytes because some devices are byte addressable
CMDCRC              rmb       1

**************************************
* Command bytes storage area
**************************************
CMD0                fcb       $40,$00,$00,$00,$00,$95
CMD8                fcb       $48,$00,$00,$01,$AA,$87
CMD16               fcb       $50,$00,$00,$02,$00,$FF was 95
ACMD41V1            fcb       $69,$00,$00,$00,$00,$FF was 95
ACMD41V2            fcb       $69,$40,$00,$00,$00,$FF was 95
CMD55               fcb       $77,$00,$00,$00,$00,$FF was 95
CMD58               fcb       $7A,$00,$00,$00,$00,$FF was 95

* Unused commands
*CMD1		     fcb       $41,$00,$00,$00,$00,$95
*CMD13		     fcb       $4D,$00,$00,$00,$00,$95

* Read/Write commands
CMDRead             equ       $5100               command to read a single block
CMDWrite            equ       $5800               command to write a sector
CMDEnd              equ       $00FF               every command ends with this

name                fcs       /llfnxsd/

start               lbra      ll_init
                    bra       ll_read
                    nop
                    lbra      ll_write
                    lbra      ll_getstat
                    lbra      ll_setstat
                    lbra      ll_term

EREAD               comb                          set the carry
                    ldb       #E$Read             set up a read error
                    rts                           return

* ll_read - Low level read routine
*
* Entry:
*    Registers:
*      Y  = The address of path descriptor.
*      U  = The address of device memory area.
*    Static variables of interest:
*      V.PhysSect = The starting physical sector to read from.
*      V.SectCnt  = The number of physical sectors to read.
*      V.SectSize = The physical sector size (0=256,1=512,2=1024,3=2048).
*      V.CchPSpot = The address where physical sector(s) will go.
*
* Exit:
*    All registers may be modified.
*    Static variables may NOT be modified.
*    Initialization errors are not flagged as an error.
*    SDCards are hot pluggable and card might be plugged in later.
ll_read
* Setup the read command.
                    ldx       V.Port-UOFFSET,u    get the hardware base address
                    lda       V.SectCnt,u         get the number of sectors to read
                    sta       SEC_CNT,u           save it to our static storage location
                    ldd       V.CchPSpot,u        get the location to copy the sector into
                    std       SEC_LOC,u           save it to our static storage location
                    ldd       V.PhysSect,u        get the physical sector address upper bits
                    std       SEC_ADD,u           save it to our static storage location
                    lda       V.PhysSect+2,u      get the physical sector address lower bits
                    sta       SEC_ADD+2,u         save it to our static storage location
* Check if a card is inserted.
                    lda       SYS0                get the byte at SYS0
                    anda      #SYS_SD_CD          is a card inserted
                    bne       EREAD               branch if not
lphr                lda       SEC_CNT,u           get our sector count
                    ldd       #CMDRead            and the read command
                    std       CMDStorage,u        store the ead command and clear the MSB of the address
                    ldd       #CMDEnd             get the ending bytes of the command
                    std       SD_SEC_ADD+3,u      clear the LSB of the address and the CRC
* Setup the SPI to access the card, and send the command.
                    bsr       LSNMap              set up the appropriate LSN value for the card and build command
                    bcs       EREAD               branch if we timed out
                    tsta                          is the response 0?
                    lbne      BMODE               branch if not
                    ldy       SEC_LOC,u           get the sector buffer address
* We make 256 loops of 2 reads, or 512 bytes.
                    bsr       TurnLEDON           turn LED ON
                    clrb                          load the counter
p@                  lbsr      GetSDByte           get a byte
                    cmpa      #$FE                is it the marker?
                    bne       p@                  branch if not
* Read the 512 Byte sector.
l@                  lbsr      GetSDByte           get a byte
                    sta       ,y+                 save it in our buffer
                    bsr       GetSDByte           get another byte
                    sta       ,y+                 store it in our buffer
                    decb                          decrement the counter
                    bne       l@                  branch if there's more to read
* Get the last two bytes of the sector (CRC bytes).
                    bsr       GetSDByte           get the first CRC byte
                    sty       SEC_LOC,u           save the updated buffer pointer
                    bsr       GetSDByte           get the second CRC byte
                    bsr       TurnLEDOFF          turn LED ON
                    dec       SEC_CNT,u           decrement the number of sectors to read
                    beq       ex@                 branch if we're done
* Increment the sector number by 1 for sector addressable, or $200 for byte addressable.
incsec              inc       SEC_ADD+2,u         add one to the 3 byte LSN
                    bne       lphr                if we are at 0 then we need to add
                    inc       SEC_ADD+1,u         the carry to the next byte
                    bne       lphr                if we are at 0 then we need to add
                    inc       SEC_ADD,u           the carry to the next byte
                    bra       lphr                continue on
ex@                 clrb
                    rts                           return

**************
* LSNMap
* Take the physical LSN and convert into an SDHC/SD/MMC LSN.
* An SD/MMC card uses a 32 bit byte mapping for the LSN, so we must shift the logical LSN up one bit
* then clear the 4th byte to build the correct LSN string.
* An SDHC card uses a 32 bit 512 byte sector mapping for the LSN, so there is no need to shift the LSN.
* We can just write it as-is and clear out the upper LSN byte, because we only get 3 bytes for the LSN.
* This routine does not preserve A.
**************
LSNMap              lda       SDVersion,u         get the SD card version
                    bne       secadd              if not 0, use sector addressing
* Byte addressing.
                    ldd       SEC_ADD+1,u         get bytes 1 and 2 (middle and LSB)
                    aslb                          shift 16 bits
                    rola                          for byte addressing
                    std       SD_SEC_ADD+1,u      and store in the first 3 bytes of the 4 byte address
                    lda       SEC_ADD,u           get the MSB
                    rola                          roll in the carry
                    sta       SD_SEC_ADD,u        and store it in the MSB of the 32-bit sector address
                    bra       merge               branch to send the command
* Sector addressing.
secadd              ldd       SEC_ADD+1,u         save the sector number into our storage
                    std       SD_SEC_ADD+2,u      store it in the last three bytes of the 4 byte address
                    lda       SEC_ADD,u           get bits 23-16
                    sta       SD_SEC_ADD+1,u      and place it in the buffer
merge               bsr       GetSDByte           get a byte (necessary?)
LSNMap1             leay      CMDStorage,u        point to the command buffer

* SendCmd - Sends a 6 byte command.
*
* Entry:  X = The hardware address.
*         Y = The address of the first byte of the command sequence.
* Exit:
* Registers preserved: all but A/B/X
SendCmd
                    bsr       GetSDByte           get a byte from the SD (needed for SanDisk)
                    ldb       #6                  get the number of bytes to send
l@                  lda       ,y+                 get the byte from the command
                    ifne      SD_DEBUG
                    lbsr      phexOut
                    endc
                    bsr       xfer                transfer it to the SD card
                    decb                          decrement the counter
                    bne       l@                  branch if more

* GetResponse - Gets a byte from the SD card.
*
* Entry:  X = The hardware address.
*
* Exit:   A = The response byte.
*         CC.C = 0 OK
*         CC.C = 1 ERROR
* Registers preserved: all but A/B
GetR1               ldb       #20                 set up the timeout counter
r0@                 bsr       GetSDByte           get a byte
                    cmpa      #$FF                is it $FF?
                    bne       r1@                 branch if not (we're done)
                    decb                          else decrement the timeout counter
                    bne       r0@                 try again if we need to
                    comb                          else set the carry
                    rts                           return
r1@                 clrb                          clear the carry
                    rts                           return

* Turn SD card LED ON/OFF
TurnLEDOn           ldb       SYS0
                    orb       #SYS_SD_L
                    bra       saveit@
TurnLEDOFF          ldb       SYS0
                    andb      #~SYS_SD_L
saveit@             stb       SYS0
                    rts

* Get a single byte from the SD card
GetSDByte           lda       #$FF                load A with $FF
xfer                sta       SDC_DATA,x          store the byte to the SD card
l@                  tst       SDC_STAT,x          get the SPI status bit
                    bmi       l@                  branch if SPI is busy
                    lda       SDC_DATA,x          get the data from the SD card
                    ifne      SD_DEBUG
                    lbsr      phexIn
                    endc
                    rts                           return

EWP                 comb                          set the carry
                    ldb       #E$WP               write protect error
                    rts                           return

* Blast data to the SD card.
* Entry:  B = number of times to blast
BlastSD             pshs      d,x,y
l0@                 lbsr      GetSDByte           sends $FF
                    decb                          decrement the counter
                    bne       l0@                 branch if there's more
                    puls      d,x,y,pc
                                        
* ll_write - Low level write routine
*
* Entry:
*    Registers:
*      Y  = The address of path descriptor.
*      U  = the Address of device memory area.
*    Static variables of interest:
*      V.PhysSect = The starting physical sector to write to.
*      V.SectCnt  = The number of physical sectors to write.
*      V.SectSize = The physical sector size (0=256,1=512,2=1024,3=2048).
*      V.CchPSpot = The address of data to write to the device.
*
* Exit:
*    All registers may be modified.
*    Static variables may NOT be modified.
ll_write            ldx       V.Port-UOFFSET,u    get the hardware address
                    lda       V.SectCnt,u         get the number of sectors to write
                    sta       SEC_CNT,u           save it to our static storage
                    ldd       V.CchPSpot,u        get the location to of the sector send
                    std       SEC_LOC,u           save it into our static storage
                    ldd       V.PhysSect,u        copy the sector address into our storage
                    std       SEC_ADD,u
                    lda       V.PhysSect+2,u
                    sta       SEC_ADD+2,u
                    lda       SYS0                get the byte at SYS0
                    anda      #SYS_SD_CD          is a card inserted
                    lbne      NOTRDY              branch if not
                    anda      #SYS_SD_WP
                    bne       EWP                 write protected, then exit with WP error
* The big read sector loop comes to here.
lphw                ldd       #CMDWrite           get the write command bytes
                    std       CMDStorage,u        save them to the command buffer
                    ldd       #CMDEnd             get the ending bytes
                    std       SD_SEC_ADD+3,u      store the LSB of the address and CRC
                    lbsr      LSNMap              set the LSN value for the card and build the command
* Setup SPI to access the card, and send the command.
                    bcs       EWRITE              branch if error
                    bne       EWRITE              branch if we have a non-zero response
                    bsr       GetSDByte           get a byte
                    bsr       GetSDByte           and another byte
                    ldd       #$FE00              set the start of the sector byte and clear the counter
                    ldy       SEC_LOC,u           get the location of the sectors(s) to write
                    lbsr      xfer                mark the start of the sector
* Write the 512 Byte sector.
                    bsr       TurnLEDON           turn LED ON
l@                  lda       ,y+                 get a byte from our buffer
                    lbsr      xfer                and save it to the SD card
                    lda       ,y+                 get another byte from our buffer
                    lbsr      xfer                and save it to the SD card
                    decb                          decrement the counter
                    bne       l@                  continue if more
                    bsr       GetSDByte           send two $FFs as the CRC
                    sty       SEC_LOC,u           save the updated buffer pointer
                    bsr       GetSDByte           send a second $FF (send 0 to check)
                    cmpa      #$E5                get the response - data accepted token
                    beq       fnd0                first byte? if not, check four more bytes
                    lbsr      TurnLEDOFF          turn LED OFF
* Make sure the response was accepted.
                    lbsr      GetR1               this should be the data we got back during the write of the last CRC
                    cmpa      #$E5                response - data accepted token
                    beq       fnd0                first byte? if not, check three more bytes.
                    lbsr      GetR1               get the response
                    cmpa      #$E5                response - data accepted token if this is not it, then we have an issue
                    beq       fnd0                first byte? if not, check two more bytes.
                    lbsr      GetR1               get the response
                    cmpa      #$E5                response - data accepted token if this is not it, then we have an issue
                    beq       fnd0                first byte? if not, check one more byte.
                    lbsr      GetR1               get the response
                    cmpa      #$E5                response - data accepted token if this is not it, then we have an issue
                    bne       EWRITE              branch if not - we have a write error
* Check to see if the write is complete.
fnd0                lbsr      GetR1               get a byte from the SD card
                    beq       lpwr2               branch if it's 0
                    bra       fnd0                else continue finding
lpwr2               lbsr      GetR1               get a byte from the SD card
                    cmpa      #$FF                is it $FF?
                    beq       f@                  branch if so
                    bra       lpwr2               else continue
f@                  ldb       #10                 send 10 more FF just in case
fl@                 lbsr      GetSDByte
                    decb
                    bne       fl@
                    dec       SEC_CNT,u           decrement the number of sectors to read
                    beq       ex@                 if zero, we are finished
                    inc       SEC_ADD+2,u         add one to 3 byte LSN
                    bne       lphw                if we are at 0 then we need to add
                    inc       SEC_ADD+1,u         the carry to the next byte
                    lbne      lphw                if we are at 0 then we need to add
                    inc       SEC_ADD,u           the carry to the next byte
                    lbra      lphw                we're done
* No errors, exit.
ex@                 clrb                          clear carry
                    rts

EWRITE              comb                          set the carry
                    ldb       #E$Write            write error
                    rts                           return

NOTRDY              comb                          set the carry
                    ldb       #E$NotRdy           not ready error
                    rts                           return

BMODE               comb                          set the carry
                    ldb       #E$BMode            bad mode error
                    rts                           return

                    ifne      SD_DEBUG
* A = byte to convert to HEX
convtohex           cmpa      #$09
                    bgt       o@
                    adda      #$30
                    rts
o@                  adda      #$37                   
                    rts
                    
pMarker             pshs      d,x,y
                    leax      ,s
                    ldy       #1
                    lda       #1
                    os9       I$Write
                    puls      d,x,y,pc
                    
phexIn              pshs      d,x,y
                    lda       #'<
                    bsr       pMarker
                    lda       ,s
                    bsr       pHex
                    puls      d,x,y,pc
        
phexOut             pshs      d,x,y
                    lda       #'>
                    bsr       pMarker
                    lda       ,s
                    bsr       pHex
                    puls      d,x,y,pc
        
phex                pshs      d,x,y
                    pshs      d
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       convtohex
                    sta       ,s
                    lda       2,s
                    anda      #%00001111
                    bsr       convtohex
                    sta       1,s
                    leax      ,s
                    ldy       #2
                    lda       #1
                    os9       I$Write
                    puls      d
                    puls      d,x,y,pc
                    endc

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
ll_init             ldx       V.PORT-UOFFSET,u    load X with the hardware address
                    lda       SYS0                get the byte at SYS0
                    anda      #SYS_SD_CD          is an SD card inserted?
                    bne       NOTRDY              branch if not

                    ldd       #(CS_EN|SPI_CLK)*256+64     get the enable and slow clock bit in A and blast count in B
                    sta       SDC_STAT,x          set the hardware
                    lbsr      BlastSD             blast bytes

                    ldd       #(SPI_CLK)*256+64   get the slow clock bit in A and blast count in B
                    sta       SDC_STAT,x          set the hardware
                    lbsr      BlastSD             blast bytes

* Select the card (keep speed low).
                    lda       #CS_EN|SPI_CLK      set the card enable and slow SPI clock
                    sta       SDC_STAT,x          update the hardware

* Initialize the SD card, if installed.
* Send CMD0.
                    leay      CMD0,pcr            point to the command stream
                    lbsr      SendCmd             send the command
                    lbcs       NOTRDY              branch if error
                    anda      #$7E                check if all but bits 7 and 1 are clear
                    lbne       NOTRDY              branch if not

* Send CMD8.
                    leay      CMD8,pcr            point to the command stream
                    lbsr      SendCmd             send the command
                    lbcs       NOTRDY              branch if error
                    anda      #$7E                clear bits 7 and 0
                    cmpa      #$04                illegal command?
                    lbeq       SDV1                branch if so
                    tsta                          is it 0 (no error)?
                    lbne       NOTRDY              no, something else... bail
                    lbsr      GetR1               get the response
                    lbcs       NOTRDY              branch if error
                    tsta                          is the response 0?
                    lbne       BMODE               branch if not
                    lbsr      GetR1               get the response
                    lbcs       NOTRDY              branch if error
                    tsta                          is the response 0?
                    lbne       BMODE               branch if not
                    lbsr      GetR1               get the response
                    lbcs       NOTRDY              branch if error
                    cmpa      #1                  is the response 1?
                    lbne       BMODE               branch if not
                    lbsr      GetR1               get the response
                    lbcs       NOTRDY              branch if error
                    cmpa      #$AA                is the response $AA?
                    lbne       BMODE               branch if not

* Send ACMD41 by first CMD55.
loop41V2            leay      CMD55,pcr           point to the command stream
                    lbsr      SendCmd             send the command
                    lbcs      NOTRDY              branch if error
                    anda      #$7E                are bits 6-1 clear?
                    lbne      BMODE               branch if not

* Then send ACMD41.
                    leay      ACMD41V2,pcr        point to the command stream
                    lbsr      SendCmd             send the command
                    lbcs      NOTRDY              branch if error
                    tsta                          is the response 0?
                    beq       Send58              if so, then send CMD58
                    cmpa      #$01                is it 1?
                    beq       loop41V2            if so, then try again
                    lbra      BMODE               else indicate an error

* Send CMD58 to V2 cards to read the OCR.
Send58              leay      CMD58,pcr           point to the command stream
                    lbsr      SendCmd             send the command
                    lbcs      NOTRDY              branch if error
                    tsta                          is the response 0?
                    lbne      BMODE               branch if not
                    lbsr      GetR1               throw away byte 2 of R3/R7
                    lbcs      NOTRDY              branch if error
                    anda      #$40                test the CCS bit (1=sector, 0=byte)
                    sta       SDVersion,u         save it in our version variable
                    lbsr      GetR1               throw away byte 3 of R3/R7
                    lbcs      NOTRDY              branch if error
                    lbsr      GetR1               throw away byte 4 of R3/R7
                    lbcs      NOTRDY              branch if error
                    lda       SDVersion,u         get the SD card version
                    bne       InitEx              branch if sector addressing
                    bra       Send16              else continue

* Send ACMD41 by first CMD55.
SDV1
loop41V1            clr       SDVersion,u         this card has byte addressable sectors
                    leay      CMD55,pcr           point to the command stream
                    lbsr      SendCmd             send the command
                    lbcs      NOTRDY              branch if error
                    anda      #$7E                are bits 6-1 clear?
                    lbne      BMODE               branch if not

* Then send ACMD41.
                    leay      ACMD41V1,pcr        point to the command stream
                    lbsr      SendCmd             send the command
                    lbcs      NOTRDY              branch if error
                    tsta                          is the response 0?
                    beq       Send16              if so, send CMD16
                    cmpa      #$01                is the response 1?
                    beq       loop41V1            try again if so
                    lbra      BMODE               else there's an error
* Send CMD16.
Send16              lbsr      SendCmd             send the command
                    lbne      NOTRDY              branch if error

InitEx

* Finished with initialization
* Use the stat routine to return

* ll_getstat - Low level GetStat routine
* ll_setstat - Low level SetStat routine
*
* Entry:
*    Y   = address of path descriptor
*    U   = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
ll_getstat
ll_setstat
*                    clrb
*                    rts

* ll_term - Low level term routine
*
* Entry:
*    Y  = address of device descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
* Note: This routine is called ONCE: for the last device
* IT IS NOT CALLED PER DEVICE!
*
ll_term
                    clrb
                    rts

                    emod
eom                 equ       *
                    end
