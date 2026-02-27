********************************************************************
* boot_picothing - PATA IDE Boot Module for Pico-Thing Level 2
*
* Provides HWInit, HWTerm, HWRead for boot_common.asm.
*
* Reads from the Pico-Thing's PATA interface at PTIDEBase.
* The data register is 16-bit: use LDD/STD for sector data.
* No latch register exists.
*
* Byte order assumption: the Pico presents the 16-bit IDE data
* register in little-endian order at PTIDEBase+0 (DataReg):
*   ldd DataReg,y  →  A = low byte (D0-D7), B = high byte (D8-D15)
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*     1    2025       Initial version for Pico-Thing

                    nam       Boot
                    ttl       PATA IDE Boot Module for Pico-Thing Level 2

                  IFP1
                    use       defsfile
                    use       ide.d
                  ENDC

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

* on-stack static storage
                    org       0
cyls                rmb       2         cylinder count from IDENTIFY
sides               rmb       1         head count from IDENTIFY
sects               rmb       2         sectors per track from IDENTIFY
mode                rmb       1         drive mode byte (CHS or LBA)
seglist             rmb       2         pointer to segment list
blockloc            rmb       2         pointer to requested memory
blockimg            rmb       2         duplicate of above
bootloc             rmb       3         sector pointer
bootsize            rmb       2         size in bytes
LSN0Ptr             rmb       2         LSN0 pointer
size                equ       .

name                fcs       /Boot/
                    fcb       edition

* Common booter-required defines
LSN24BIT            equ       1
FLOPPY              equ       0

                    use       boot_common.asm

*------------------------------------------------------------
*
* HWInit - Initialize the PATA device
*
* Entry: Y = hardware address (PTIDEBase)
* Exit:  Carry clear = OK, Carry set = Error, B = error code
*
HWInit              ldb       WhchDriv,pcr get drive select (0=master, 1=slave)
                    bne       slave@
                    lda       #%10100000 master: DEV=0
                    fcb       $8C       skip next instruction (cmpx immediate)
slave@              lda       #%10110000 slave: DEV=1
                    sta       mode,u    save device select byte
                    stb       DevHead,y select device
a@                  tst       Status,y  wait for BSY to clear
                    bmi       a@
                    lda       #$EC      IDENTIFY DEVICE command
                    sta       Command,y
b@                  tst       Status,y  wait for BSY to clear
                    bmi       b@
* Harvest C/H/S and LBA values from IDENTIFY response
                    ldd       DataReg,y word 0: ignore
                    ldd       DataReg,y word 1: cylinders (big-endian in memory)
                    exg       a,b       swap: A=high, B=low
                    std       cyls,u    save cylinders
                    ldd       DataReg,y word 2: ignore
                    ldd       DataReg,y word 3: heads
                    sta       sides,u   save heads (A = low byte = D0-D7)
                    ldd       DataReg,y word 4: ignore
                    ldd       DataReg,y word 5: ignore
                    ldd       DataReg,y word 6: sectors per track
                    exg       a,b       swap: A=high, B=low
                    std       sects,u   save sectors/track
* throw away words 7-48 (42 words)
                    ldb       #42
l@                  ldd       DataReg,y read and discard word
                    decb
                    bne       l@
* word 49: LBA support flag in bit 9 (D8-D15 = A after exg)
                    ldd       DataReg,y word 49
                    exg       a,b       A = high byte = D8-D15
                    anda      #%00000010 LBA supported?
                    beq       nope@
                    lda       mode,u
                    ora       #%01000000 set LBA flag
                    sta       mode,u
nope@               ldb       #10       skip words 50-59
more@               ldd       DataReg,y read and discard word
                    decb
                    bne       more@
                    ldd       DataReg,y word 60: LBA sectors (bits 15-0)
                    exg       a,b
                    std       cyls,u    reuse cyls for LBA lo (see ATADSize)
                    ldd       DataReg,y word 61: LBA sectors (bits 31-16)
                    exg       a,b
                    std       sides-1,u store high word adjacent (offset -1 from sides)
* skip remaining IDENTIFY words (256 - 62 = 194)
                    lda       #194
left@               ldd       DataReg,y discard remaining words
                    deca
                    bne       left@
HWTerm              clrb
                    rts

*------------------------------------------------------------
*
* HWRead - Read one 256-byte OS-9 sector from PATA device
*
* Entry: Y = hardware address (PTIDEBase)
*        B = bits 23-16 of LSN
*        X = bits 15-0  of LSN
*        blockloc,u = pointer to 256-byte sector buffer
* Exit:  X = pointer to data
*        Carry clear = OK, Carry set = Error
*
HWRead              pshs      x,b
b@                  tst       Status,y  wait for BSY clear
                    bmi       b@
                    lda       mode,u
                    sta       DevHead,y set device/head select
r@                  ldb       Status,y  wait for DRDY=1, BSY=0
                    andb      #BusyBit+DrdyBit
                    cmpb      #DrdyBit
                    bne       r@
                    ldb       #$01
                    stb       SectCnt,y one sector at a time
                    lda       mode,u
                    anda      #%01000000 LBA mode?
                    beq       chs@
* LBA mode: load address from stack
                    lda       ,s        bits 23-16
                    sta       CylHigh,y
                    ldd       1,s       bits 15-0
                    stb       SectNum,y bits 7-0
                    sta       CylLow,y  bits 15-8
                    bra       DoCmd
* CHS mode: compute cylinder/head/sector from LBA
chs@                lda       sides,u
                    ldb       sects+1,u
                    mul                 A*B = heads*sectors
                    pshs      d
                    ldd       1+2,s     get bits 15-0 of LBA
                    ldx       #-1
                    inc       0+2,s
a@                  leax      1,x
                    subd      ,s
                    bhs       a@
                    dec       0+2,s
                    bne       a@
                    addd      ,s++
                    pshs      d
                    tfr       x,d
                    exg       a,b
                    std       CylLow,y
                    puls      d
                    ldx       #-1
c@                  leax      1,x
                    subb      sects+1,u
                    sbca      #0
                    bcc       c@
                    addb      sects+1,u
                    incb
                    stb       SectNum,y
                    tfr       x,d
                    orb       DevHead,y
                    stb       DevHead,y
DoCmd               lda       #S$READ
                    sta       Command,y
Blk2                lda       Status,y  wait for DRQ
                    anda      #DrqBit
                    beq       Blk2
                    ldx       blockloc,u
                    clr       ,s        byte counter (128 words = 256 bytes)
* read 128 16-bit words = 256 bytes
BlkLp               ldd       DataReg,y read 16-bit IDE word (little-endian)
                    std       ,x++      store two bytes
                    inc       ,s
                    bpl       BlkLp     loop 128 times (0 to 127)
                    leax      -256,x
                    stx       1,s
                    lda       Status,y  check status
                    clrb
                    puls      b,x,pc

*------------------------------------------------------------

Address             fdb       PTIDEBase hardware address
WhchDriv            fcb       0         drive select (0=master, 1=slave)

                    emod
eom                 equ       *
                    end
