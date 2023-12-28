*******************************************************************
* llsd - Low-level SDHC/SD/MMC driver
*
* This driver talks to the SD card interface on the DE1 utilizing the CoCo3FPGA
*
* $FF64 (Control Register Write)
* Bit 7 : SD Enable
* Bit 6 : Enable Interrupt
* Bits 5-1 : not used
* Bit 0 : SPI Device Select #1 (DE1 SD Card)
*
* $FF64 (Status Register Read)
* Bit 7 : IRQ Active
* Bits 6-2 : not used
* Bit 1 : SD Card Locked (Write Protect)
* Bit 0 : SD Installed
*
* $FF65 (Data Register R/W)
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*     1    2012/06/16  Gary Becker
* Rewritten to work with 8 bit SPI on CoCo3FPGA
*     2    2015/06/06  Gary Becker
* Removed any code to enable multiple slots (single slot only)

                    nam       llcoco3fpga
                    ttl       Low-level SDHC/SD/MMC driver

                    use       defsfile
                    use       rbsuper.d

tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       0
edition             set       4

                    mod       eom,name,tylg,atrv,start,0

                    org       V.LLMem
* Low-level driver static memory area
SEC_CNT             rmb       1                   Number of sectors to transfer
SEC_LOC             rmb       2                   Where they are or where they go
SEC_ADD             rmb       3                   LSN of sector
SDVersion           rmb       1                   0 = Byte Addressable SD
* !0 = Sector Addressable SD
CMDStorage          rmb       1                   Command storage area for read/write CMDs
SD_SEC_ADD          rmb       4                   Four bytes because some devices are byte addressable
CMDCRC              rmb       1

**************************************
* Command bytes storage area
**************************************
CMD0                fcb       $40,$00,$00,$00,$00,$95
*CMD1		fcb		$41,$00,$00,$00,$00,$95
CMD8                fcb       $48,$00,$00,$01,$AA,$87
*CMD13		fcb		$4D,$00,$00,$00,$00,$95
CMD16               fcb       $50,$00,$00,$02,$00,$FF was 95
ACMD41V1            fcb       $69,$00,$00,$00,$00,$FF was 95
ACMD41V2            fcb       $69,$40,$00,$00,$00,$FF was 95
CMD55               fcb       $77,$00,$00,$00,$00,$FF was 95
CMD58               fcb       $7A,$00,$00,$00,$00,$FF was 95

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
* Test 8 bit LED display
SPITRACE            equ       $FF66

name                fcs       /llcoco3fpga/

start               lbra      ll_init
                    bra       ll_read
                    nop
                    lbra      ll_write
                    lbra      ll_getstat
                    lbra      ll_setstat
                    lbra      ll_term

EREAD
                    ldd       #$0000+E$Read       A=Disable SPI Interface, but not CS
* B=Read Error
                    lbra      RETERR

* ll_read - Low level read routine
*
* Entry:
*    Registers:
*      Y  = address of path descriptor
*      U  = address of device memory area
*    Static Variables of interest:
*      V.PhysSect = starting physical sector to read from
*      V.SectCnt  = number of physical sectors to read
*      V.SectSize = physical sector size (0=256,1=512,2=1024,3=2048)
*      V.CchPSpot = address where physical sector(s) will go
*
* Exit:
*    All registers may be modified
*    Static variables may NOT be modified
*    Initialization errors are not flagged as an error
*    SDCards are hot pluggable and card might be plugged in later
ll_read
* Setup read command
                    orcc      #IntMasks           disable interrupts
                    ldx       V.Port-UOFFSET,u    Get address of hardware
                    lda       V.SectCnt,u         Get number of sectors to read
                    sta       SEC_CNT,u           Save it to our usable storage
                    ldd       V.CchPSpot,u        get the location to copy the sector into
                    std       SEC_LOC,u           Save it into our usable storage
                    ldd       V.PhysSect,u        Copy Sector Adrress into our storage
                    std       SEC_ADD,u
                    lda       V.PhysSect+2,u
                    sta       SEC_ADD+2,u
                    lda       SPISTAT,x
                    lsra
                    bcc       EREAD               No card installed, so no reads
lphr                lda       SEC_CNT,u
                    ldd       #CMDRead
                    std       CMDStorage,u        Read command and clear MSB of address
                    ldd       #CMDEnd
                    std       SD_SEC_ADD+3,u      Clear LSB of address and CRC
rd_loop             lda       #(SPI_EN+SLOT_SEL_0) but not IRQ enable
                    bsr       LSNMap0             Setup the appropriate LSN value for the card, build command,
* setup SPI to access the card, and sends command
                    bcs       EREAD               If we timed out, branch with error
                    bne       EREAD               If the R1 was not 0

                    ldy       SEC_LOC,u           Get the sector buffer address
                    ldb       #$00                256 loops of 2 reads of 1 bytes is 512 bytes
lprd                lda       SPIDAT,x            Send FF (receive a byte) until we get FE
                    cmpa      #$FE                Do we need more cycles??????
                    nop
                    bne       lprd
* Read the 512 Byte sector
* we need a minumum of 4 CPU cycles to read in the 8 bits
RDSectorLoop        lda       SPIDAT,x
                    sta       ,y+                 ? cycles ?????????????
                    nop       might               be too much ???????
                    lda       SPIDAT,x
                    sta       ,y+
                    decb
                    bne       RDSectorLoop
* Get the last two bytes of the sector (CRC bytes)
                    lda       SPIDAT,x            Send 2x FF to get the CRC
                    sty       SEC_LOC,u           Save out buffer pointer
*		nop				Might be too many cycles ?????????
                    lda       SPIDAT,x            We ignore the CRC
                    dec       SEC_CNT,u           decrement # of hw sectors to read
                    beq       finird              if zero, we are finished
*Increment sector number by 1 for sector addressable or $200 for byte addressable
incsec              inc       SEC_ADD+2,u         add one to 3 byte LSN
                    bne       lphr                if we are at 0 then we need to add
                    inc       SEC_ADD+1,u         the carry to the next byte
                    bne       lphr
                    inc       SEC_ADD,u
                    bra       lphr

* No errors, exit
finird
                    ldd       #$0000              Disable SPI and exit
                    sta       SPICTRL,x
                    andcc     #^(IntMasks+Carry)  Renable Interrupts and clear carry
                    rts                           return

**************
* LSNMap
* Take physical LSN and convert into SDHC/SD/MMC LSN
* SD/MMC uses a 32 bit byte mapping for the LSN, so we must shift the logical LSN up one bit
* and then clear the 4th byte to build the correct LSN string
* SDHC uses a 32 bit 512 byte sector mapping for the LSN.So there is no need to shift the LSN
* we can just write it as is and clear out the upper LSN byte, because we only get 3 bytes from coco for LSN
* does not preserve Reg A
**************
LSNMap0
                    sta       SPICTRL,x
                    nop
                    lda       SPIDAT,x            Send 1 FF
                    lda       SDVersion,u
                    bne       secadd              GoTo Sector Address type
*Save the sector number into the command
                    ldd       SEC_ADD+1,u         bytes 1 and 2 (middle and LSB)
                    aslb                          Byte address needs to be shifter one more bit
                    rola
                    std       SD_SEC_ADD+1,u      and stored in the first 3 bytes of a 4 byte address
                    lda       SEC_ADD,u           MSB
                    rola
                    sta       SD_SEC_ADD,u
                    bra       merge
secadd
                    ldd       SEC_ADD+1,u         Save the sector number into our storage
                    std       SD_SEC_ADD+2,u      Store in the last three bytes of the 4 byte address
                    lda       SEC_ADD,u
                    sta       SD_SEC_ADD+1,u
merge               lda       SPIDAT,x            Send 1 FF
LSNMap1
                    leay      CMDStorage,u
* Fall through to cmdsend

* cmdsend - Sends a 6 byte command
* Entry:  X = HW addr
*         Y = Address of first byte of command sequence
* Exit:
* Registers preserved: all but A/B/X
cmdsend
                    lda       ,y
                    sta       SPITRACE
                    ldb       #6
cslp                lda       ,y+
                    sta       SPIDAT,x
                    decb
                    bne       cslp
* If finished, fall through to GETR1

* Entry:  X = HW addr
* Exit:   A = R1
*         CC.C = 0 OK
*         CC.C = 1 ERROR
* Registers preserved: all but A/B
GetR1
                    andcc     #^Carry             Clear Carry
                    ldb       #$00                Probably too much
lpgtr1              lda       SPIDAT,x
                    bpl       finigtr1
                    decb
                    bne       lpgtr1
                    comb                          set carry for error
finigtr1            rts

* ll_write - Low level write routine
*
* Entry:
*    Registers:
*      Y  = address of path descrip
*      U  = address of device memory area
*    Static Variables of interest:
*      V.PhysSect = starting physical sector to write to
*      V.SectCnt  = number of physical sectors to write
*      V.SectSize = physical sector size (0=256,1=512,2=1024,3=2048)
*      V.CchPSpot = address of data to write to device
*
* Exit:
*    All registers may be modified
*    Static variables may NOT be modified
ll_write
                    orcc      #IntMasks           disable interrupts
                    ldx       V.Port-UOFFSET,u    Get address of hardware
                    lda       V.SectCnt,u         Get number of sectors to write
                    sta       SEC_CNT,u           Save it to our usable storage
                    ldd       V.CchPSpot,u        get the location to of the sector send
                    std       SEC_LOC,u           Save it into our usable storage
                    ldd       V.PhysSect,u        Copy Sector Adrress into our storage
                    std       SEC_ADD,u
                    lda       V.PhysSect+2,u
                    sta       SEC_ADD+2,u
                    lda       SPISTAT,x
                    lsra
                    lbcc      EWRITE              No card installed, so no writes
                    lsra
                    lbcs      EWP                 Write Protected, then exit with WP error
* The big read sector loop comes to here
lphw                ldd       #CMDWrite
                    std       CMDStorage,u
                    ldd       #CMDEnd
                    std       SD_SEC_ADD+3,u      LSB of address and CRC
wr_loop             lda       #(SPI_EN+SLOT_SEL_0)
                    bsr       LSNMap0             Setup the appropriate LSN value for the card, build command,
* setup SPI to access the card, and sends command
                    bcs       EWRITE
                    bne       EWRITE

                    lda       SPIDAT,x            2 bytes >= 1 byte after R1
                    nop       Might               not be enough ?????
                    nop
                    lda       SPIDAT,x
                    ldd       #$FE00              Start of sector byte and clear counter
                    ldy       SEC_LOC,u           get the location of the sectors(s) to write
                    sta       SPIDAT,x            Mark the start of the sector
                    nop       Too                 much ???????
* Write the 512 Byte sector
WRSectorLoop        lda       ,y+
                    sta       SPIDAT,x
                    nop
                    lda       ,y+
                    sta       SPIDAT,x
                    decb
                    bne       WRSectorLoop
                    lda       SPIDAT,x            send two FFs as CRC
                    sty       SEC_LOC,u           Save out buffer pointer
                    nop       Might               not be enough ???????
                    stb       SPIDAT,x            Second FF (send 0 to check)
                    cmpa      #$E5                Response - Data accepted token
                    beq       fnd0                First byte? if not, check four more bytes.
* Make sure the response was accepted
                    lda       SPIDAT,x            This should be the data we got back during the write of the last CRC
*		nop				But we do send another ff so we can get the E5
                    cmpa      #$E5                Response - Data accepted token
                    beq       fnd0                First byte? if not, check three more bytes.
                    lda       SPIDAT,x
                    cmpa      #$E5                Response - Data accepted token if this is not it, then we have an issue
                    beq       fnd0                First byte? if not, check two more bytes.
                    lda       SPIDAT,x
                    cmpa      #$E5                Response - Data accepted token if this is not it, then we have an issue
                    beq       fnd0                First byte? if not, check one more byte.
                    lda       SPIDAT,x
                    cmpa      #$E5                Response - Data accepted token if this is not it, then we have an issue
                    bne       EWRITE              Write error
* Check to see if the write is complete
fnd0                lda       SPIDAT,x
                    beq       lpwr2
                    bra       fnd0                Ths beq and bra could be a bne, but I want the extra cycles
lpwr2               lda       SPIDAT,x
                    cmpa      #$FF
                    beq       wfin
                    bra       lpwr2
wfin                ldb       #10                 Lets send 10 more FF just in case
finlp               lda       SPIDAT,x
                    decb
                    bne       finlp
                    dec       SEC_CNT,u           decrement # of hw sectors to read
                    beq       finiwr              if zero, we are finished
                    inc       SEC_ADD+2,u         add one to 3 byte LSN
                    bne       lphw                if we are at 0 then we need to add
                    inc       SEC_ADD+1,u         the carry to the next byte
                    lbne      lphw
                    inc       SEC_ADD,u
                    lbra      lphw
* No errors, exit
finiwr
                    ldd       #$0000              Diable SPI and exit
                    sta       SPICTRL,x
                    andcc     #^(IntMasks+Carry)  Renable Interrupts and clear carry
                    rts

* Error handlers
EWRITE
                    ldd       #$0000+E$Write      A=Enable SPI Interface, but not CS
* B=Write Error
                    bra       RETERR
EWP
                    ldd       #$0000+E$WP         A=Enable SPI Interface, but not CS
* B=Write Protect Error

RETERR
                    sta       SPICTRL,x           Set the hardware
                    andcc     #^IntMasks          Enable interrupts
                    coma                          Set Carry
                    rts
NOTRDY
                    ldd       #$0000+E$NotRdy     Turn off controller and turn on IRQ and flag not ready error
                    bra       RETERR
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
                    orcc      #IntMasks           disable interrupts
                    lda       $FFD9               Speed up
                    ldx       V.PORT-UOFFSET,u    load x with the hw address for the IRQ routine
                    lda       SPISTAT,x
                    lsra
                    bcc       NOTRDY              If there is no card, nothing to do
* Enable SPI
                    ldd       #SPI_EN*256+$10     Enable SPI Interface, but not CS
* 16*8 cycles is >= 74
                    sta       SPICTRL,x

*send at least 74 clock cycles with no SS, 16*8 = 128
lpff                lda       SPIDAT,x            Send FF
                    decb                          2 cycles, need 4
*		nop				2 cycles
                    bne       lpff                3 Cycles
*Initialize card 0
CRD0                lda       #SPI_EN+SLOT_SEL_0  Enable SPI and lower CS
                    sta       SPICTRL,x

* sdinit - initializes SD Cards, if installed
sdinit
* Send CMD0
                    lda       SPIDAT,x            Send 1 FF
                    nop       ?????????           enough
                    leay      CMD0,pcr            Might need more cycles ???????
                    lda       SPIDAT,x            Send 1 more FF
                    lbsr      cmdsend             Also does a GETR1
                    bcs       NOTRDY
                    anda      #$7E                Idle is ok
                    bne       NOTRDY              but nothing else

* Send CMD8
                    lda       SPIDAT,x            Send 1 FF
                    nop       ??????              enough
                    leay      CMD8,pcr            Might need more cycles ??????
                    lda       SPIDAT,x            Send 1 more FF
                    lbsr      cmdsend             Also does an GETR1
                    bcs       SDV1
                    anda      #$7E
                    bne       SDV1
                    lda       SPIDAT,x            Byte 1 of R3/R7, throw it away
                    nop
                    nop       might               need more ????????
                    nop
                    lda       SPIDAT,x            Byte 2 of R3/R7, throw it away
                    nop
                    nop
                    nop
                    lda       SPIDAT,x            Byte 3 of R3/R7, should be 1
                    cmpa      #$01                2 cycles
                    bne       NOTRDY              2 cycles
                    nop
                    lda       SPIDAT,x            Byte 4 of R3/R7, should be $AA
                    cmpa      #$AA                2 cycles
                    bne       NOTRDY              2 cycles
                    nop

* Send ACMD41 by first CMD55
loop41V2            lda       SPIDAT,x            Send 1 FF
                    nop
                    leay      CMD55,pcr           might need more ??????
                    lda       SPIDAT,x            Send 1 FF
                    lbsr      cmdsend             Also does an GETR1
                    bcs       NOTRDY
                    anda      #$7E                Idle is ok
                    bne       NOTRDY              but nothing else

* Then send ACMD41
                    lda       SPIDAT,x
                    nop
                    leay      ACMD41V2,pcr
                    lda       SPIDAT,x
                    lbsr      cmdsend
                    bcs       NOTRDY              No response
                    beq       Send58              If 0 then CMD58
                    cmpa      #$01                if 1 then try again
                    beq       loop41V2
                    lbra      NOTRDY

* Send CMD58 to V2 card
Send58              lda       SPIDAT,x
                    nop       ??????              ENOUGH
                    leay      CMD58,pcr           Read OCR
                    lda       SPIDAT,x
                    lbsr      cmdsend
                    lbcs      NOTRDY
                    lda       SPIDAT,x            Byte 1 of OCR
                    anda      #$40                CCS bit 1= sector 0= byte
                    sta       SDVersion,u
                    lda       SPIDAT,x            Byte 2 of R3/R7, throw it away
                    nop
                    nop
                    lda       SPIDAT,x            Byte 3 of R3/R7, throw it away
                    nop
                    nop
                    lda       SPIDAT,x            Byte 4 of R3/R7, throw it away
                    lda       SDVersion,u         0 = byte addressable, !0 = block addressable
                    bne       FININIT
                    bra       Send16

* Send ACMD41 by first CMD55
SDV1

loop41V1            lda       SPIDAT,x            Get extra bytes in case we got a bad R7 previously
                    nop
                    lda       SPIDAT,x
*		nop
                    clr       SDVersion,u         Byte addressable
                    lda       SPIDAT,x
*		nop
                    leay      CMD55,pcr
                    lda       SPIDAT,x
                    lbsr      cmdsend
                    lbcs      NOTRDY
                    anda      #$7E                Idle is ok
                    lbne      NOTRDY              but nothing else

* Then send ACMD41
                    lda       SPIDAT,x
*		nop
                    leay      ACMD41V1,pcr
                    lda       SPIDAT,x
                    lbsr      cmdsend
                    lbcs      NOTRDY
                    beq       Send16              If 0 then CMD16
                    cmpa      #$01                if 1 then try again
                    beq       loop41V1
                    lbra      NOTRDY
* Send CMD16
Send16              lda       SPIDAT,x
*		nop
                    leay      CMD16,pcr
                    lda       SPIDAT,x
                    lbsr      cmdsend
                    lbne      NOTRDY              but nothing else
* Finish INIT
FININIT
                    lda       SPIDAT,x            Send last FF
*		nop
*		lda		SDVersion,u
*		sta		SPITRACE
*		lda		#SPI_EN+SPI_IRQ_EN	Turn on SPI and Interrupt and turn off CS
                    lda       #SPI_EN             Turn on SPI and turn off CS
                    sta       SPICTRL,x

*Finished with initialization
*Use the stat routine to return

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
                    andcc     #^Carry
                    clrb
                    rts

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
                    andcc     #^Carry
                    rts

                    emod
eom                 equ       *
                    end
