********************************************************************
* boot_picothing - PATA IDE Boot Module for Pico-Thing
*
* Provides HWInit, HWTerm, HWRead for boot_common.asm.
*
* Reads from the Pico-Thing's PATA interface at PTIDEBase.
* The data register is 16-bit: use LDD/STD for sector data.
* No latch register exists.
*
* Byte order: the Pico presents the 16-bit IDE data register in
* big-endian order at PTIDEBase+0 (DataReg):
*   ldd DataReg,y  ->  A = D8-D15 (high byte), B = D0-D7 (low byte)
*
* The PATA drive uses 512-byte physical sectors.  boot_common
* passes 256-byte OS-9 logical sector numbers.  HWRead divides
* the LSN by 2 to get the physical sector, reads all 512 bytes,
* returns the requested half, and caches the other half so the
* next sequential request is served without a disk read.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*     1    2025       Initial version for Pico-Thing

                    nam       Boot
                    ttl       PATA IDE Boot Module for Pico-Thing

                  IFP1
                    use       defsfile
                    use       ide_picothing.d
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
HWInit              lda       #%00000010 nIEN: disable IDE interrupts
                    sta       AltStatus,y write device control register
                    ldb       WhchDriv,pcr get drive select (0=master, 1=slave)
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
b@                  lda       Status,y  wait for BSY to clear
                    bmi       b@
                    anda      #DrqBit   wait for DRQ to set
                    beq       b@
* Harvest C/H/S and LBA values from IDENTIFY response
* No D.BtBug calls during data transfer
* Byte order: ldd DataReg,y -> A=high (D8-D15), B=low (D0-D7)
                    ldd       DataReg,y word 0: ignore
                    ldd       DataReg,y word 1: cylinders
                    std       cyls,u    save cylinders (big-endian)
                    ldd       DataReg,y word 2: ignore
                    ldd       DataReg,y word 3: heads
                    stb       sides,u   save heads (B = low byte = D0-D7)
                    ldd       DataReg,y word 4: ignore
                    ldd       DataReg,y word 5: ignore
                    ldd       DataReg,y word 6: sectors per track
                    std       sects,u   save sectors/track (big-endian)
* throw away words 7-48 (42 words)
                    pshs      x         save X for use as counter
                    ldx       #42
l@                  ldd       DataReg,y read and discard word
                    leax      -1,x
                    bne       l@
* word 49: LBA support flag in bit 9 (A = D8-D15 already)
                    ldd       DataReg,y word 49
                    anda      #%00000010 LBA supported? (bit 9 = bit 1 of A)
                    beq       nope@
                    lda       mode,u
                    ora       #%01000000 set LBA flag
                    sta       mode,u
nope@               ldx       #10       skip words 50-59
more@               ldd       DataReg,y read and discard word
                    leax      -1,x
                    bne       more@
                    ldd       DataReg,y word 60: LBA sectors (bits 15-0)
                    std       sects,u   save bits 15-0 (big-endian)
                    ldd       DataReg,y word 61: LBA sectors (bits 31-16)
                    std       cyls,u    save bits 31-16 (big-endian)
* skip remaining IDENTIFY words (256 - 62 = 194)
                    ldx       #194
left@               ldd       DataReg,y discard remaining words
                    leax      -1,x
                    bne       left@
                    puls      x         restore X
HWTerm              clrb
                    rts

*------------------------------------------------------------
*
* HWRead - Read one 256-byte OS-9 sector from PATA device
*
* Physical sectors are 512 bytes.  Each call re-reads the full
* physical sector and keeps only the wanted 256-byte half.
* No on-stack cache buffer needed (saves 260 bytes of stack).
*
* Entry: Y = hardware address (PTIDEBase)
*        B = bits 23-16 of LSN
*        X = bits 15-0  of LSN
*        blockloc,u = pointer to 256-byte sector buffer
* Exit:  X = pointer to data (= blockloc,u)
*        Carry clear = OK, Carry set = Error
*
HWRead              pshs      x,b
* Stack: [LSN23-16:0] [LSN15-8:1] [LSN7-0:2]
* Compute half selector (bit 0 of LSN)
                    lda       2,s       LSN bits 7-0
                    anda      #$01      half = 0 or 1
                    pshs      a         save half
* Stack: [half:0] [LSN23-16:1] [LSN15-8:2] [LSN7-0:3]
* Shift 24-bit LSN right by 1 to get physical sector number
                    lsr       1,s       shift bits 23-16
                    ror       2,s       rotate into bits 15-8
                    ror       3,s       rotate into bits 7-0

* Wait for BSY clear and DRDY
bsy@                tst       Status,y
                    bmi       bsy@
                    lda       mode,u
                    sta       DevHead,y
rdy@                ldb       Status,y
                    andb      #BusyBit+DrdyBit
                    cmpb      #DrdyBit
                    bne       rdy@
                    ldb       #$01
                    stb       SectCnt,y one physical sector
* LBA addressing
                    lda       1,s       psn 23-17
                    sta       CylHigh,y
                    ldd       2,s       psn 15-0
                    stb       SectNum,y
                    sta       CylLow,y
                    lda       #S$READ
                    sta       Command,y
                    ldx       #0        timeout counter (65536 polls)
drq@                lda       Status,y
                    bita      #ErrBit   check for error
                    bne       drqerr@
                    bita      #DrqBit
                    bne       drqok@
                    leax      -1,x
                    bne       drq@
                    lbra      RdDone2   timeout, abort this read
drqerr@             lbra      RdDone2   error, abort this read
drqok@
* Read 512-byte physical sector, keep only the wanted half
                    tst       ,s        which half?
                    bne       h1@
* half=0: first 256 bytes -> blockloc, discard second 256
                    ldx       blockloc,u
                    bsr       Rd256     read first half into buffer
                    bsr       Skip256   discard second half
                    bra       RdDone
* half=1: discard first 256 bytes, second -> blockloc
h1@                 bsr       Skip256   discard first half
                    ldx       blockloc,u
                    bsr       Rd256     read second half into buffer
RdDone              lda       Status,y  read final status
                    ldx       blockloc,u X = data pointer for caller
                    leas      4,s       clean [half][psn]
                    clrb                clear carry
                    rts
RdDone2             lda       Status,y  read final status
                    ldx       blockloc,u X = data pointer for caller
                    leas      4,s       clean [half][psn]
                    comb                set carry (error)
                    rts

* Rd256 - read 256 bytes (128 words) from DataReg into X
Rd256               ldb       #128
                    pshs      b
rd@                 ldd       DataReg,y
                    std       ,x++
                    dec       ,s
                    bne       rd@
                    leas      1,s
                    rts

* Skip256 - read and discard 256 bytes (128 words) from DataReg
Skip256             ldb       #128
                    pshs      b
sk@                 ldd       DataReg,y
                    dec       ,s
                    bne       sk@
                    leas      1,s
                    rts

*------------------------------------------------------------

Address             fdb       PTIDEBase hardware address
WhchDriv            fcb       0         drive select (0=master, 1=slave)

                    emod
eom                 equ       *
                    end
