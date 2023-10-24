********************************************************************
* Boot - MMC Boot Module
*
* $Id$
*
* This module allows booting from MMC devices using Jim Hathaway's
* MMC Interface for the Color Computer.
*
* This booter was created on May 17th, 2003 by Jim Hathaway and Boisy Pitre
* at the 12th Annual "Last" Chicago CoCoFEST! in Elgin, Illinois at the
* Cloud-9 booth.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2003/05/17  Jim M. Hathaway
* Created.
*
*   2      2003/08/01  Jim M. Hathaway
* Fixed bug that was also in MMCDRV when reading a byte from the
* status register.

                    nam       Boot
                    ttl       MMC Boot Module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       2
edition             set       2

                    mod       eom,name,tylg,atrv,start,size

blockloc            rmb       2                   pointer to memory requested
blockimg            rmb       2                   duplicate of the above
bootloc             rmb       3                   sector pointer; not byte pointer
bootsize            rmb       2                   size in bytes
size                equ       .

name                fcs       /Boot/
                    fcb       edition

start               clra
                    ldb       #size
clean               pshs      a
                    decb
                    bne       clean
                    tfr       s,u                 get pointer to data area
                    pshs      u                   save pointer to data area

                    lda       #$d0                forced interrupt; kill floppy activity
                    sta       $FF48               command register

                    clrb
pause               decb
                    bne       pause
                    lda       $FF48               clear controller
                    clr       $FF40               make sure motors are turned off

* Init hardware
                    lbsr      INITCRD
                    bcs       error

* Request memory for LSN0
                    ldd       #1
                    os9       F$SRqMem            request one page of RAM
                    bcs       error
                    bsr       getpntr

* Get LSN0 into memory
                    clrb                          MSB sector
                    ldx       #0                  LSW sector
                    bsr       mread
                    bcs       error
                    ldd       bootsize,u
                    bcs       error
                    pshs      d

* Return memory
                    ldd       #$100
                    ldu       blockloc,u
                    os9       F$SRtMem
                    puls      d
                    ifgt      Level-1
                    os9       F$BtMem
                    else
                    os9       F$SRqMem
                    endc
                    bcs       error
                    bsr       getpntr
                    std       blockimg,u

* Get os9boot into memory
                    ldd       bootsize,u
                    leas      -2,s                same as a PSHS D
getboot             std       ,s
                    ldb       bootloc,u           MSB sector location
                    ldx       bootloc+1,u         LSW sector location
                    bsr       mread
                    ldd       bootloc+1,u         update sector location by one to 24bit word
                    addd      #1
                    std       bootloc+1,u
                    ldb       bootloc,u
                    adcb      #0
                    stb       bootloc,u
                    inc       blockloc,u          update memory pointer for upload
                    ldd       ,s                  update size of file left to read
                    subd      #$100               file read one sector at a time
                    bhi       getboot

                    leas      4+size,s            reset the stack    same as PULS U,D
                    ldd       bootsize,u
                    ldx       blockimg,u          pointer to start of os9boot in memory
                    andcc     #^Carry             clear carry
                    rts                           back to os9p1

error               leas      2+size,s
                    rts

getpntr             tfr       u,d                 save pointer to requested memory
                    ldu       2,s                 recover pointer to data stack
                    std       blockloc,u
                    rts

mread               tstb
                    bne       hwread
                    cmpx      #0
                    bne       hwread
                    bsr       hwread
                    bcc       readlsn0
                    rts

readlsn0            pshs      a,x,y
                    ldy       blockloc,u
                    lda       DD.Bt,y             os9boot pointer
                    ldx       DD.Bt+1,y           LSW of 24 bit address
                    sta       bootloc,u
                    stx       bootloc+1,u
                    ldx       DD.BSZ,y            os9boot size in bytes
                    stx       bootsize,u
                    clrb
                    puls      a,x,y,pc

* Generic read
hwread              pshs      x
                    lbsr      READ
                    puls      x,pc


CMDREAD             equ       $51                 Command to read a single block
MMCCSB              equ       $80                 MMC control register slow clock bit
MMCCRO              equ       1                   MMC control register offset from data port
MMCDPR              equ       $FF7A               MMC Data port register



********************************
* Command bytes storage area
********************************
CMD0                fcb       $40,0,0,0
CMD1                fcb       $41,0,0,0
CMD171              fcb       $50,0,0,1

***************************************************************
* Send a command string to the MMC (6 bytes) 4 user 2 hard code
* Entry: y= Pointer to command string to send
*        x= MMC data register
*        b= Not used
*        a= Used to copy data
***************************************************************
SNDC                lda       ,y                  Get cmd byte 1
                    sta       ,x                  Send command byte
                    lbsr      DLYSTRT             Call our delay routine
                    lda       1,y                 Get cmd byte 2
                    sta       ,x                  Send command byte
                    lbsr      DLYSTRT             Call our delay routine
                    lda       2,y                 Get cmd byte 3
                    sta       ,x                  Send command byte
                    lbsr      DLYSTRT             Call our delay routine
                    lda       3,y                 Get cmd byte 4
                    sta       ,x                  Send command byte
                    lbsr      DLYSTRT             Call our delay routine
                    lda       #0                  Get cmd byte 5
                    sta       ,x                  Send command byte
                    lbsr      DLYSTRT             Call our delay routine
                    lda       #$95                Get cmd byte 6
                    sta       ,x                  Send command byte
                    lbsr      DLYSTRT             Call our delay routine
                    rts                           Complete sending command return

***********************************************************
* CHKR - Check card response
* Used to check response from a card
* Entry: a= Expected Response byte code
*        b= used for loop / set on exit to flag error/no error
***********************************************************
CHKR                pshs      b                   Save reg b
                    clrb                          Use for loop counter
CHKRL1              bsr       DLYSTRT             Call our delay routine
                    cmpa      ,x                  Check for response
                    beq       CHKRG               Response is good, exit without error
                    decb                          Keep looping?
                    bne       CHKRL1              Done yet?
CHKRB               bsr       DLYSTRT             Need delay
                    comb                          Set error state
                    puls      b,pc                Return
CHKRG               bsr       DLYSTRT             Need delay
                    clrb                          Set no error
                    puls      b,pc                Return
* End CHKR routine

*********************************************************************
* DLYSTRT: Delay routine for use as a delay for sending commands
*          or clock pulses as the slower spi rate.
*          Delay is hard coded at $14
*          All registers perserved
*********************************************************************
DLYSTRT             pshs      b                   Save b register for return
                    ldb       #$14                Default delay needed
DLYLP1              decb                          Start of delay loop
                    bne       DLYLP1              End of delay loop
                    puls      b,pc                Get value of b register back
* End delay routine

************************************************************
* INITCRD: Init a single card, no register values needed,
*          all preserved
*   Entry: y = Used, and not preserved
*          x = Address to MMC data port
************************************************************
INITCRD             ldx       #MMCDPR             Address to MMC
                    lda       #MMCCSB             Select no cards and slow speed
                    sta       MMCCRO,x            Store to control register
                    lda       #$0A                A= 10 clocks
CLKPL1              tst       ,x                  Pulse the clock 80 times to init all cards
                    bsr       DLYSTRT             Call our delay routine
                    deca                          Loop counter
                    bne       CLKPL1              Keep looping till we send 80 clocks

                    lda       #$81                Select crd 1 @ slow speed
                    sta       MMCCRO,x            Write to MMC control register slow speed
                    leay      CMD0,pcr            Load address into y for cmd0
                    lbsr      SNDC                Go send the command (cmd0)

                    lda       #$01                Expected response
                    lbsr      CHKR                Go check for response bit
                    lbcs      INITCE1

                    ldb       #20                 Number of times to send CMD1 before error

                    leay      CMD1,pcr            Load address into y for cmd1
INCMD1L             lbsr      SNDC                Go send the command (cmd1)

                    lda       #$00                Expected response
                    lbsr      CHKR                Go check for response bit
                    bcc       INC1C               We got our response, continue

                    decb                          Loop counter
                    bne       INCMD1L             Keep trying to get a response of 0
                    lbcc      INC1C
                    lda       #81
                    lbra      INITCE1             This card is not ready exit

INC1C               lda       #$01                Get card number, always use card 0
                    sta       MMCCRO,x            Write to MMC control register full speed
                    leay      CMD171,pcr          Get command to change sector to 256 bytes
                    lbsr      SNDC                Go send the command (cmd17-1)

                    lda       #0                  Expected response
                    lbsr      CHKR                Go check for response byte
                    bcs       INITCE1

                    clrb                          No error
                    puls      pc                  Clean exit

INITCE1             comb                          Error, we could not init card
                    tfr       a,b
                    puls      pc
* End of INITCRD

*****************************************************************
* READ - Read a single 256 byte sector.
*        y= Location to store data to
*        b,x= LSN number
*        x not preserved
*****************************************************************
READ                pshs      d,x                 Save LSN
                    ldy       blockloc,u
                    lda       #$1                 Get drive #1
                    sta       MMCCRO+MMCDPR       Select card 1
                    lda       MMCDPR              Burn a byte - bug fix

                    lda       #CMDREAD            Read cmd byte 1
                    sta       MMCDPR              Save read command
                    nop       Delay
                    stb       MMCDPR              Save cmd byte 2
                    tfr       x,d                 Move the rest of the LSN
                    sta       MMCDPR              Save cmd byte 3
                    ldx       #MMCDPR             Get MMC address and delay
                    stb       ,x                  Save cmd byte 4
                    lda       #$0                 Cmd byte 5
                    sta       ,x                  Save cmd byte 5
                    lda       #$95                Cmd byte 6 CRC
                    sta       ,x                  Save cmd byte 6

RDN2                lda       #$FE                Expected response
                    lbsr      CHKR                Check for response
                    bcs       RDEEX1              Card should have read sector, read error!

                    clra                          Number of loops 256
RDLP1               ldb       ,x                  Get byte from MMC
                    stb       ,y+                 Save byte
                    deca                          Loop counter
                    bne       RDLP1

                    ldd       ,x                  Get CRC Byte 1
                    lda       ,x                  Get CRC Byte 2

RDEX1               clr       MMCCRO,x            Deselect any cards in use
                    clrb                          Set no errors
                    puls      d,x,pc              Read complete with no errors
RDEEX1              clr       MMCCRO,x            Deselect any cards in use
                    comb                          Error reading sector
                    puls      d,x,pc              Return with error
* End of READ


                    ifgt      Level-1
* Fillers to get to $1D0
Pad                 fill      $39,$1D0-3-*
                    endc

                    emod
eom                 equ       *
                    end

