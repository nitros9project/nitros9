********************************************************************
* MMCDRV Color Computer MultiMedia Card Driver
* Version 2.0.1
* Copyright (C) 2003 Jim Hathaway III KG4KNB@hat3.net
********************************************************************

************************************************************************
* Updates:
* 06/16/03 - Copied code from version 321 driver and changed for asm
*            Did this to see if there is some other issue with ASM
*            cross assembly of this module.  Still having problems when
*            trying to write any file to a MMC formatted with the
*            newer driver driver.  This driver seems to work with ASM
*            there must be a bug with the other modified version
* 06/17/03 - Moved from 001b version to 100 after testing showed no
*            issues.
*            Worked on making code similar to other code.  Need to test
*            this code as is to see if it will still work.
*            Made EXTREME changes to the code.  Will need mucho debugo
* 06/18/03 - More time working through.
* 06/19/03 - Fixed a bug in the read code that did not set PD.BUF correctly
*            Y was being loaded with V.PORT before PD.BUF,y was calculated
*            Write sector routine was missing Y=V.Port setup as well as
*            MDN,u setup before calling GREAD.
*            LSN0PROC - missing RTS, also moved clearing of the LSN0 flag
*            to the LSN0PROC subroutine and removed it from the READ
*            subroutine. Found and fixed several bugs today.  Including
*            the problem last night with an iniz causing the driver to
*            loop and access the card.
* 06/24/03 - Found a bug in the error return routines, comb should have
*            been done BEFORE the error number is loaded.  Was causing
*            a read error 244 to be returned as error 011
* 06/29/03 - Found final bug causing problems in nlevel2.  IF an error
*            was returned from the chkrs routine the delay was not called
*            before exit, then the calling routine went back and sent the
*            command again and stepped on the spi transfer.  After all
*            bytes are written or read at slow speed the delay routine
*            MUST be called!
*************************************************************************

NUMDRIVE            equ       2                   Max. # of device descriptors for this driver
CMDREAD             equ       $51                 Command to read a single block
CMDWRITE            equ       $58                 Command to write a sector
MMCCSB              equ       $80                 MMC control register slow clock bit
MMCCRO              equ       1                   MMC control register offset from data port
DLYAMT              equ       $28                 Standard delay amount used in DLYSTART
CRDPULS             equ       $A                  Number of times to loop for card init

                    nam       MMCDRV
                    ttl       MMC device driver for CoCo

                    ifp1
                    use       defsfile
                    endc

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $02
edition             equ       2

                    mod       eom,name,tylg,atrv,start,size

                    org       0
                    rmb       DRVBEG+(DRVMEM*NUMDRIVE)

* Start of driver-specific statics
LSN0                rmb       1                   Byte flag to indicate LSN0
MDN                 rmb       1                   MMC Drive Number
SECT2WR             rmb       1                   Determines the sector to write
OS9SECT             rmb       2                   Temp storage for OS9 sector address
SECTPNT             rmb       2                   Temp storage for Sector Buffer pointer
BUFFER1             rmb       256                 Sector buffer location for write cmds
RCMDBLK             rmb       6
WCMDBLK             rmb       6

size                equ       .

                    fcb       $FF                 mode byte

name                fcs       /MMCDRV/            module name
                    fcb       edition             module edition


* Start point
start               lbra      INIT
                    lbra      READ
                    lbra      WRITE
                    lbra      GETSTA
                    lbra      SETSTA
                    lbra      TERM
* End start

********************************
* Command bytes storage area
********************************
CMD0                fcb       $40,0,0,0,0,$95
CMD1                fcb       $41,0,0,0,0,$95
CMD13               fcb       $4D,0,0,0,0,$95
CMD171              fcb       $50,0,0,1,0,$95
CMD172              fcb       $50,0,0,2,0,$95

***************************************************************
* LSN0PROC - Process drive table when LSN0 is loaded.
* Called from READ
* Added pshs, puls y to preserve y holding the address of the
* MMC 6/19/03 JMH
***************************************************************
LSN0PROC            pshs      y                   Save y for return
                    ldb       MDN,u               Get drive number
                    decb                          Make drive 1 = 0, drive 2 = 1
                    lda       #DRVMEM             # bytes to copy from LSN0 to drive table
                    mul                           Compute drive table location
                    leay      DRVBEG,u            Point to start of drive tables
                    leay      d,y
                    ldx       SECTPNT,u           We need to get the sector buffer to use
                    lda       #DD.SIZ             Get drive table size
RDCL1               ldb       ,x+                 From copy
                    stb       ,y+                 To Copy
                    deca                          Loop for entire path descriptor
                    bne       RDCL1               Loop till done
                    clr       LSN0,u              Set LSN0 false 0=f 1=t
                    puls      y,pc                Restore/return

* End LSN0PROC

***************************************************************
* Send a command string to the MMC (6 bytes) with delay
* Can be called as SNDCS for sending command and checking status
* or just chkrs can be called to see if the card returns the
* correct response
* Entry: X=Pointer to command string to send
*        Y=MMC Command data port
*        A=Used for loop and not preserved
*
***************************************************************
SNDCS               pshs      d,x                 Save regs
                    ldb       #6                  Number of command bytes
SNDCLS              lda       ,x+                 Get command byte
                    sta       ,y                  Send command byte
                    lbsr      DLYSTRT             Call our delay routine
                    decb                          Are we done?
                    bne       SNDCLS              Keep looping until complete
                    puls      d,x                 Restore regs

CHKRS               pshs      d
                    clrb
CHKRSL1             lbsr      DLYSTRT             Call our delay routine
                    cmpa      ,y                  Check for response
                    beq       CHKRSG              Response is good, exit without error
                    decb                          Keep looping?
                    bne       CHKRSL1             Done yet?

CHKRSB              lbsr      DLYSTRT             Call our delay routine
                    comb                          Set error state
                    puls      d,pc                Cleanup/Return
CHKRSG              lbsr      DLYSTRT             Call our delay routine
                    clrb                          Set no error
                    puls      d,pc                Restore / Return

*********************************************************************
* Delay Routine - For use during initialization to slow down the
* read and write commands to the MMC because we must use a speed of
* less than 400k for the clock until CMD1 is issued (per MMC specs.)
*********************************************************************
DLYSTRT             pshs      b                   Save b register for return
                    ldb       #DLYAMT             Standard delay amount
DLYLP1              decb                          Start of delay loop
                    bne       DLYLP1              End of delay loop
                    puls      b,pc                Get value of b register back
* End delay routine

*******************************************************************
* INIT - Standard OS9 init function.  Enable all MMCs if present and
*        request sector buffer block.  Also set drive tables values.
********************************************************************
INIT                ldy       V.PORT,u            Get MMC base port address
                    lda       #NUMDRIVE           Number of cards to init

INITL1              sta       MDN,u               Get card number
                    lbsr      INITCRD             Try and init card
                    deca
                    bne       INITL1              Keep looping

                    lda       #CMDREAD            Setup bytes for each command area
                    sta       RCMDBLK,u           Save them to each area
                    lda       #CMDWRITE
                    sta       WCMDBLK,u
                    ldd       #$0095              Final two cmd bytes
                    std       RCMDBLK+4,u         Save last two cmd bytes for read
                    std       WCMDBLK+4,u         Save last two cmd bytes for write

                    clr       LSN0,u              Set LSN0 false 0=f 1=t

                    leax      DRVBEG,u            Point to start of drive tables
                    ldb       #NUMDRIVE           Number of drives supported
                    stb       V.NDRV,u            Store the number of drives
                    lda       #$ff
INITL2              sta       DD.TOT,x            DD.TOT MSB to bogus value
                    sta       V.TRAK,x            Init current track # to bogus value
                    leax      DRVMEM,x            Get next drive table location
                    decb                          Loop counter
                    bne       INITL2              Keep looping?

                    clr       MMCCRO,y            Deselect any cards in use

GETSTA
SETSTA
TERM
                    clrb
                    rts

********************************************************************
* WRITE SECTOR
* Must read in correct sector then write out
* a 512 byte sector.  MMCs only support 512 byte sectors
* for write.
********************************************************************
WRITE               stb       RCMDBLK+1,u         Save LSN for read command
                    stx       RCMDBLK+2,u         Save LSN for read command

                    stb       WCMDBLK+1,u         Save LSN for write command
                    stx       WCMDBLK+2,u         Save LSN for write command

                    ldx       PD.BUF,y            Get real sector address for later
                    stx       OS9SECT,u           Save os9 sector address for later

                    lda       WCMDBLK+3,u         Adjust WLSN
                    anda      #$FE                Mask bit 0
                    sta       WCMDBLK+3,u         Adjust WLSN

                    lda       RCMDBLK+3,u         Get lowest LSN byte
                    anda      #1                  Mask bits 7-1
                    sta       SECT2WR,u           Save it for later
                    beq       WRROWE              Go RO WE 1=(RE,WO) 0=(RO,WE)

WRREWO              ldd       RCMDBLK+2,u         Get upper LSN
                    subd      #1
                    std       RCMDBLK+2,u
                    ldb       RCMDBLK+1,u
                    sbcb      #0
                    stb       RCMDBLK+1,u

                    bra       WRGO

WRROWE              ldd       RCMDBLK+2,u         Get upper LSN
                    addd      #1
                    std       RCMDBLK+2,u
                    ldb       RCMDBLK+1,u
                    adcb      #0
                    stb       RCMDBLK+1,u

WRGO                leax      BUFFER1,u
                    stx       SECTPNT,u           Save sector buffer for read

                    lda       PD.DRV,y            Get drive # requested
                    inca
                    sta       MDN,u               Save requested drive number

                    ldy       V.PORT,u            Get MMC base port address

                    lbsr      GREAD               Go get buffered sector
                    lbcs      EWRITE              Write error

WRGO1               leax      CMD172,pcr          Get command to change sector to 512 bytes
                    lda       #$00                Expected response
                    lbsr      SNDCF               Go send the command (cmd17-2)
                    lbcs      ENOTRDY             Not ready

                    leax      WCMDBLK,u           Get address of write command block
                    lda       #$00                Expected response
                    lbsr      SNDCF               Send this command without delay
                    lbcs      ENOTRDY             Not ready

                    lda       #254                Start of data sector byte
                    sta       ,y                  Save start of sector byte

WRGO2               tst       SECT2WR,u           1=(RE,WO) 0=(RO,WE)
                    bne       WRREWO1

WRROWE1             ldx       OS9SECT,u           Get real sector buffer
                    bsr       WRSEC               Go write 256 bytes
                    leax      BUFFER1,u           Get buffered sector
                    bra       WRDC1               Data send complete

WRREWO1             leax      BUFFER1,u           Get buffered sector buffer
                    bsr       WRSEC               Go write 256 bytes
                    ldx       OS9SECT,u           Get real sector buffer
WRDC1               bsr       WRSEC               Go write 256 bytes

* dropped the code to send two crc bytes - the routine
* that reads the card to see if the $E5 response is given
* also sends data, so no separate crc code is needed

                    lda       #$E5                Response - Data accepted tolken
                    lbsr      CHKRF               Check for correct response
                    lbcs      EWRITE              Write error

                    lda       #$FF                Response - Card complete with write
                    lbsr      CHKRF               Check for correct response
                    lbcs      EWRITE              Write error

                    leax      CMD13,pcr           Get check status command
                    lda       #$00                Expected response
                    lbsr      SNDCF               Go send the command (cmd13)
                    lbcs      EWRITE              Write error
                    lbsr      CHKRF               Check for correct response
                    lbcs      EWRITE              Write error

                    leax      CMD171,pcr          Get command to change sector to 256
                    lda       #$00                Expected response
                    lbsr      SNDCF               Go send the command (cmd17-1)
                    lbcs      ENOTRDY             Not ready

                    lbsr      WREXIT              Clean exit

* End of write sector routine

********************************************************
* WRSEC - Write a single 256 byte sector to the MMC
* Entry: Y=MMC data port address
*        X=Sector location to copy from
********************************************************
                    ifne      SMALLC
WRSEC               clrb                          Loop counter
WRLP1               lda       ,x+                 Get data byte
                    sta       ,y                  Store data byte
                    decb
                    bne       WRLP1               Keep looping?
                    rts                           Return

                    else

WRSEC               leax      15,x
                    lda       #8                  Number of loops to run
                    pshs      a                   Used for loop counter
WRBLK1              ldd       -15,x               Get 2 bytes
                    sta       ,y                  Save byte 1
                    nop       Delay               to complete SPI transfer
                    stb       ,y                  Save byte 2
                    ldd       -13,x               Get 2 more bytes
                    sta       ,y                  Save byte 3
                    nop       Delay               to complete SPI transfer
                    stb       ,y                  Save byte 4
                    ldd       -11,x               Get 2 more bytes
                    sta       ,y                  Save byte 5
                    nop       Delay               to complete SPI transfer
                    stb       ,y                  Save byte 6
                    ldd       -9,x                Get 2 more bytes
                    sta       ,y                  Save byte 7
                    nop       Delay               to complete SPI transfer
                    stb       ,y                  Save byte 8
                    ldd       -7,x                Get 2 more bytes
                    sta       ,y                  Save byte 9
                    nop       Delay               to complete SPI transfer
                    stb       ,y                  Save byte 10
                    ldd       -5,x                Get 2 more bytes
                    sta       ,y                  Save byte 11
                    nop       Delay               to complete SPI transfer
                    stb       ,y                  Save byte 12
                    ldd       -3,x                Get 2 more bytes
                    sta       ,y                  Save byte 13
                    nop       Delay               to complete SPI transfer
                    stb       ,y                  Save byte 14
                    ldd       -1,x                Get 2 more bytes
                    sta       ,y                  Save byte 15
                    nop       Delay               to complete SPI transfer
                    stb       ,y                  Save byte 16
                    ldd       1,x                 Get 2 more bytes
                    sta       ,y                  Save byte 17
                    nop       Delay               to complete SPI transfer
                    stb       ,y                  Save byte 18
                    ldd       3,x                 Get 2 more bytes
                    sta       ,y                  Save byte 19
                    nop       Delay               to complete SPI transfer
                    stb       ,y                  Save byte 20
                    ldd       5,x                 Get 2 more bytes
                    sta       ,y                  Save byte 21
                    nop       Delay               to complete SPI transfer
                    stb       ,y                  Save byte 22
                    ldd       7,x                 Get 2 more bytes
                    sta       ,y                  Save byte 23
                    nop       Delay               to complete SPI transfer
                    stb       ,y                  Save byte 24
                    ldd       9,x                 Get 2 more bytes
                    sta       ,y                  Save byte 25
                    nop       Delay               to complete SPI transfer
                    stb       ,y                  Save byte 26
                    ldd       11,x                Get 2 more bytes
                    sta       ,y                  Save byte 27
                    nop       Delay               to complete SPI transfer
                    stb       ,y                  Save byte 28
                    ldd       13,x                Get 2 more bytes
                    sta       ,y                  Save byte 29
                    nop       Delay               to complete SPI transfer
                    stb       ,y                  Save byte 30
                    ldd       15,x                Get 2 more bytes
                    sta       ,y                  Save byte 31
                    nop       Delay               to complete SPI transfer
                    stb       ,y                  Save byte 32
                    leax      32,x                Add 32 bytes
                    dec       ,s                  Loop counter
                    bne       WRBLK1              Loop back and do it again
                    puls      a,pc                Clean stack, return

                    endc

* End of WRSEC subroutine

*************************************************
* INITCRD : Init a single card
* Entry: Y=MMC data port address
*        MDN,u = card number (1..X)
* Registers preserved
*************************************************
INITCRD             pshs      d,x

                    lda       #MMCCSB             Change MMC clock to slow speed
                    sta       MMCCRO,y            Write slow speed bit
                    lda       #CRDPULS            Clock pulses needed to init cards

* Per MMC spec - before any commands are sent to the card 80 clock
* pulses must be sent at a speed of less than 400k.  After init
* is complete we will use the full speed of 3.56 Mhz.  This is the
* clock speed of the serial shift.  8 cycles at 3.56 Mhz are required
* to complete the SPI transfer.

ICLKPL1             tst       ,y                  Send 8 clock pulses to card
                    lbsr      DLYSTRT             Call our delay routine
                    deca                          Loop counter
                    bne       ICLKPL1             Loop until all clocks done

                    lda       MDN,u               Get card number
                    ora       #MMCCSB             Select slow clock bit
                    sta       MMCCRO,y            Write to MMC control register slow speed

                    leax      CMD0,pcr            x = cmd0 address
                    lda       #$01                Response
                    lbsr      SNDCS               Go send the command w/ delay
                    lbcs      INITCE1             This card is not ready exit

                    ldb       #20                 Number of times to send CMD1 before error
INCMD1L             leax      CMD1,pcr            Load address into x for cmd1
                    lda       #$00                Expected response
                    lbsr      SNDCS               Go send the command (cmd1)
                    bcc       INC1C               We got our response, continue
                    decb                          Loop counter
                    bne       INCMD1L             Keep trying to get a response of 0
                    lbcs      INITCE1             This card is not ready exit

INC1C               lda       MDN,u               Get card number
                    sta       MMCCRO,y            Write to MMC control register full speed

                    leax      CMD171,pcr          Get command to change sector to 256 bytes
                    lda       #$00                Expected response
                    lbsr      SNDCF               Go send the command (cmd17-1) w/o delay
                    bcs       INITCE1             Error changing to 256 byte sector

                    clrb                          No error
                    puls      d,x,pc              Clean exit

INITCE1             comb                          Error, we could not init card
                    puls      d,x,pc

* End of INITCRD


*****************************************************************
* READ - Read a single 256 byte sector.  Uses GREAD to get the
*        sector into memory
*****************************************************************
READ                stb       RCMDBLK+1,u         Save LSN
                    stx       RCMDBLK+2,u         Save LSN

                    leax      0,x                 Check for LSN0
                    bne       RDS1
                    tstb                          Check for LSN0
                    bne       RDS1
                    inc       LSN0,u              Set LSN0 Flag

RDS1                lda       PD.DRV,y            Get drive # requested
                    inca                          Set drive number correctly
                    sta       MDN,u               Save drive number

                    ldx       PD.BUF,y            Get physical sector buffer pointer
                    stx       SECTPNT,u           Store the sector buffer location

                    ldy       V.PORT,u            Get MMC base port address

                    bsr       GREAD               Get our sector
                    lbcs      EREAD               Exit with read error

                    tst       LSN0,u              Is this LSN0?
                    beq       RDEX1               Complete - return

                    lbsr      LSN0PROC            Process LSN0 information

WREXIT
RDEX1               clrb                          Set no errors
                    clr       MMCCRO,y            Deselect any cards in use
                    rts                           Read complete with no errors

* End of READ

***************************************************************
* Send a command string to the MMC (6 bytes) w/o delay
* Can be called as SNDCF for sending command and checking status
* or just CHKRF can be called to see if the card returns the
* correct response
* Entry: X = Pointer to command string to send
*        Y = MMC Command data port
*        A = Used for loop and not preserved
***************************************************************
SNDCF
                    ifne      SMALLC

                    pshs      d,x                 Save regs
                    ldb       #$06                Loop amount
SNDCFL1             lda       ,x+                 Get command byte
                    sta       ,y                  Save byte to card
                    decb                          Loop counter
                    bne       SNDCFL1             Keep looping?
                    puls      d,x                 Restore regs

                    else

                    pshs      d                   Save regs
                    ldd       ,x                  Get command bytes
                    sta       ,y                  Save byte 1
                    nop       Delay               to complete SPI transfer
                    stb       ,y                  Save byte 2
                    ldd       2,x                 Get command bytes
                    sta       ,y                  Save byte 3
                    nop       Delay               to complete SPI transfer
                    stb       ,y                  Save byte 4
                    ldd       4,x                 Get command bytes
                    sta       ,y                  Save byte 5
                    nop       Delay               to complete SPI transfer
                    stb       ,y                  Save byte 6
                    puls      d                   Restore regs

                    endc

* Try to quickly get a response from the MMC.  128 loops
* is only a guess as to how long an average command response
* might be.  After the 128 loops it is obvious that the card
* may need more time to process the command (such as a write)
* command.  At that point we sleep for 1 tick to give the
* card time to complete the request.  Then try another 255 times
* to get the response before we return an error.
* 6-24-03 JMH - Found something interesting in NLevel2 V030102
* testing last night.  The MMC would not initialize aparently
* based on the LED pattern being displayed.  Level2 OS9 is able
* to use this driver without problems.  As I think about it more
* it might be the fact that in 6309 mode the CPU is able to
* execute instructions faster and so it is stepping on the
* spi shift.
* 6-24-03 JMH - Moved pshs x lower into subroutine to save
* some time if a sleep is not needed then there is no reason
* to pshs x and puls x.

CHKRF               pshs      d                   Save regs
                    clrb                          Number of loops

CHKRFL1             cmpa      ,y
                    beq       CHKRFG              Got our response
                    cmpa      ,y
                    beq       CHKRFG              Got our response
                    decb                          Loop counter
                    bne       CHKRFL1             Keep looping?

* This sleep should only occur when writing to the card
                    pshs      x                   Save x for later
                    ldx       #1                  Sleep for remainder of this tick
                    os9       F$Sleep             Wait for card
                    puls      x                   Restore

                    clrb                          Number of loops = 256
CHKRFL2             cmpa      ,y
                    beq       CHKRFG              Got our response
                    decb                          Loop counter
                    bne       CHKRFL2             Keep looping?

CHKRFB              comb                          Set error state
                    puls      d,pc                Cleanup/Return
CHKRFG              clrb                          Set no error
                    puls      d,pc                Cleanup/Return

***************************************************************
* GREAD - New generic read subroutine.  Requires:
*         MDN,u = drive number
*         RCMDBLK,u LSN (RCMDBLK+1,RCMDBLK+2,RCMDBLK+3)
*         SECTPNT,u = location to copy sector to
*         Y = V.port,u (MMC base port address)
***************************************************************
GREAD
                    lda       MDN,u
                    sta       MMCCRO,y            Select MMC

                    lda       ,y                  Burn a byte - bug fix

                    lda       #$FF                Expected card response
                    bsr       CHKRF               Go check for response byte
                    bcc       RDN1                Is card ready?  If yes continue

                    lbsr      INITCRD             Try and initialize the card requested
                    lbcs      ENOTRDY             Not ready - no card found in slot

                    lda       MDN,u               Get drive number
                    sta       MMCCRO,y            Write to MMC control register

RDN1                leax      RCMDBLK,u           Read command block
                    lda       #$00                Expected response
                    bsr       SNDCF               Send this command without delay
                    bcc       RDN2                If command did not generate err continue

                    lbsr      INITCRD             Try and initialize the card requested
                    lbcs      ENOTRDY             Not ready

                    lda       MDN,u               Get drive number again
                    sta       MMCCRO,y            Set card selected at full speed

                    leax      RCMDBLK,u           Read command block
                    lda       #$00                Expected response - cmd accepted
                    bsr       SNDCF               Send this command without delay
                    lbcs      ENOTRDY             Not ready

RDN2                lda       #$FE                Expected response start of sector
                    bsr       CHKRF               Check for response
                    lbcs      EREAD               Read Error

                    ldx       SECTPNT,u           We need to get the sector buffer to use
                    bsr       RDSEC               Go read the sector

                    clrb                          Set no errors
                    rts

***************************************************************
* RDSEC - Read a single 256 byte sector from the MMC + 2 CRC bytes
* Entry: Y=MMC data port address
*        X=Sector location to copy to
***************************************************************
                    ifne      SMALLC
RDSEC               pshs      x                   Save x
                    clrb                          Loop counter
RDLP1               lda       ,y                  Get data byte
                    sta       ,x+                 Store data byte
                    decb
                    bne       RDLP1               Keep looping?
*         ldd   ,y             Get CRC bytes
*         lda   ,y             Get CRC bytes
                    puls      x,pc                Restore/return

                    else

* Using a 5 bit offset only adds 1 cycle to each of the STD instructs.
* incrementing the X index register each time by ++ adds 3 instructions
* so this saves 2 cycles for every 2 bytes transfered.  2 cycles * 16
* STD instructions = 32 saved cycles per loop or 256 cycles per sector
* read.  This loop uses about 1900 cycles to complete. A simple lda
* sta single byte move loop takes about 3900 cycles to complete.  This
* is a more than 50% increase in speed for this loop (this is where
* the driver uses the most CPU time).  6309 users note! a TFM will not
* work because you need AT LEAST 4 coco (regardless of the CoCo's actual
* speed) cycles between data port access for the SPI cycle to complete.
* If a write or read occurs during the four cycles
* after a byte is read/wrote to the SPI data port then the data
* transfer will be corrupted.

RDSEC               leax      15,x                Move to the middle of the 32 byte block
                    lda       #8                  Number of loops to run
                    pshs      a                   Used for loop
RDLP1               ldd       ,y                  Load byte 1
                    ldb       ,y                  Load byte 2
                    std       -15,x               Store two bytes
                    ldd       ,y                  Load byte 3
                    ldb       ,y                  Load byte 4
                    std       -13,x               Store two bytes
                    ldd       ,y                  Load byte 5
                    ldb       ,y                  Load byte 6
                    std       -11,x               Store two bytes
                    ldd       ,y                  Load byte 7
                    ldb       ,y                  Load byte 8
                    std       -9,x                Store two bytes
                    ldd       ,y                  Load byte 9
                    ldb       ,y                  Load byte 10
                    std       -7,x                Store two bytes
                    ldd       ,y                  Load byte 11
                    ldb       ,y                  Load byte 12
                    std       -5,x                Store two bytes
                    ldd       ,y                  Load byte 13
                    ldb       ,y                  Load byte 14
                    std       -3,x                Store two bytes
                    ldd       ,y                  Load byte 15
                    ldb       ,y                  Load byte 16
                    std       -1,x                Store two bytes
                    ldd       ,y                  Load byte 17
                    ldb       ,y                  Load byte 18
                    std       1,x                 Store two bytes
                    ldd       ,y                  Load byte 19
                    ldb       ,y                  Load byte 20
                    std       3,x                 Store two bytes
                    ldd       ,y                  Load byte 21
                    ldb       ,y                  Load byte 22
                    std       5,x                 Store two bytes
                    ldd       ,y                  Load byte 23
                    ldb       ,y                  Load byte 24
                    std       7,x                 Store two bytes
                    ldd       ,y                  Load byte 25
                    ldb       ,y                  Load byte 26
                    std       9,x                 Store two bytes
                    ldd       ,y                  Load byte 27
                    ldb       ,y                  Load byte 28
                    std       11,x                Store two bytes
                    ldd       ,y                  Load byte 29
                    ldb       ,y                  Load byte 30
                    std       13,x                Store two bytes
                    ldd       ,y                  Load byte 31
                    ldb       ,y                  Load byte 32
                    std       15,x                Store two bytes
                    leax      32,x                Add 32 bytes
                    dec       ,s                  Loop counter
                    bne       RDLP1               Loop back and do it again

* Eliminated the code to pull two CRC bytes from the card.
* The routine that checks for the correct response will
* extract these two bytes from the MMC

*         ldd   ,y             Get 1 byte of CRC data from card
*         ldb   ,y             Get 1 byte of CRC data from card

                    puls      a,pc

                    endc

* End of RDSEC subroutine

ENOTRDY             bsr       ERREXIT
                    comb
                    ldb       #E$NotRdy           Not ready
                    rts

EWRITE              bsr       ERREXIT
                    comb
                    ldb       #E$Write            Write error
                    rts

EREAD               bsr       ERREXIT
                    comb
                    ldb       #E$Read             Read error
                    rts

* Added to handle things that need to occur if an error occurs
* 1. Select the card (may already be selected)
* 2. Send command to change sector size back to 256 bytes
* 3. Clear the LSN0 flag (may already be cleared)
* 4. Deselect all cards.

ERREXIT             lda       MDN,u               Get drive number
                    sta       MMCCRO,y            Select card (in case not selected)
                    leax      CMD171,pcr          Get command to change sector to 256 bytes
                    lda       #$00                Expected response
                    lbsr      SNDCF               Go send the command (cmd17-1) w/o delay

                    clr       lsn0,u              Clear LSN0 flag if set
                    clr       MMCCRO,y            Deselect any cards
                    rts

                    emod
eom                 equ       *
                    end
