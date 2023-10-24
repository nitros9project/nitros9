********************************************************************
* RAMD SDRAM Disk Driver for CoCo3FPGA
*
* $Id: ramd.asm,v 1.0 2016/12/09 14:52:42 gbecker Exp $
*
* Ed.    Comments                                       Who YY/MM/DD
* ------------------------------------------------------------------
*  1     Initial driver                         Gary Becker 16/12/09
*
*  2     Updated to conform to NitrOS9 Repo     Bill Pierce 17/02/04
*

*   $FF84: SDRAM Control Register (Write)
RAMDCON             equ       $00
* Bit  Signal
* 0    R/W
*
*   $FF84: Disk Flag (Read)
RAMDSTA             equ       $00
* Bit  Signal
*  7   Operation Finished
*  0   R/W
*   $FF85-$FF86: DATA (Read / Write)
RAMDDAT             equ       $01
*
*   $FF87-88: Block Address
RAMDADD             equ       $03
*
N.Drives            equ       1                   number of drives to support
*
* Command equates
*
*
                    nam       RAMD
                    ttl       os9 device driver

                    use       os9.d
                    use       rbf.d
                    use       coco.d

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    org       0
                    mod       eom,name,tylg,atrv,start,size
                    fcb       $ff

u0000               rmb       DRVBEG+(DRVMEM*N.Drives)

size                equ       .

                    fcb       $FF                 This byte is the driver permissions
name                fcs       /RAMD/
                    fcb       1                   edition #1

start               bra       INIT                3 bytes per entry to keep RBF happy
                    nop
                    bra       READ
                    nop
                    bra       WRITE
                    nop
                    bra       GETSTA
                    nop
                    bra       SETSTA
                    nop
                    bra       TERM
                    nop

* Read
*
* Entry:
*	B = MSB of LSN
*	X = LSB of LSN
*	Y = address of path descriptor
*	U = address of device memory area
*
* Exit:
*	CC = carry set on error
*	B = error code
*
READ                lda       #$01                1=READ the sector
                    tstb                          Make sure 3rd byte of LSN is 0
                    bne       ERROR
                    pshs      x,y                 Save these registers for later
                    tst       ,s                  Check high bit of X (Low 16 bits of LSN)
                    bmi       ERROR2              Should equal 0
                    bsr       GetSect             Go read the sector
                    puls      x,y
                    tfr       x,d
                    tstb                          Test one byte of saved X
                    bne       TERM
                    tsta                          Test other byte of saved X
                    bne       TERM
* LSN0, standard OS-9 format
                    ldy       PD.BUF,y            address of buffer
                    leau      DRVBEG,u            point to the beginning of the drive tables
                    ldb       #DD.SIZ             copy bytes over
copy.0              lda       ,y+                 grab from LSN0
                    sta       ,u+                 save into device static storage
                    decb                          Finished when B=0
                    bne       copy.0
                    bra       TERM                Return

*
* Entry:
*	B = MSB of LSN
*	X = LSB of LSN
*	Y = address of path descriptor
*	U = address of device memory area
*
* Exit:
*	CC = carry set on error
*	B = error code
*
GetSect
*	orcc	#IntMasks	Kill interrupts
                    pshs      x                   save 2 byte LSN
                    ldx       V.PORT,u            get address of hardware
                    sta       RAMDCON,x           Setup for a READ
                    puls      d                   Get 2 byte LSN
                    std       RAMDADD,x           Put it in the address
                    ldy       PD.BUF,y            address of buffer
                    lda       #$80                128 2 byte transfers
                    pshs      a                   On stack
                    lda       RAMDDAT+1,x         Start transfer
LP0                 tst       RAMDSTA,x           Is transfer completed?
                    bpl       LP0
                    ldd       RAMDDAT,x           Yes, read 2 bytes from RAM
                    std       ,y++                Store them in buffer
                    dec       ,s                  Are we finished?
                    bne       LP0                 No
                    puls      b                   clear b
*	andcc	#^(IntMasks)	Renable Interrupts
                    rts

ERROR2              puls      x,y
ERROR               ldb       E$SeekRg            Only error is Seek out of Range
                    comb                          Set carry bit
                    rts

* Init
*
* Entry:
*	Y = address of device descriptor
*	U = address of device memory area
*
* Exit:
*	CC = carry set on error
*	B = error code
*
INIT
                    leax      DRVBEG,u            point to the beginning of the drive tables
                    ldd       #$8000              Number of total sectors
                    stb       DD.TOT,x            $00
                    std       DD.TOT+1,x          $8000
                    ldd       #$0100              A=$01 B=$00
                    stb       V.NDRV,u            $01
*	lda	#$FF		Probably not needed
*	sta	V.TRAK,u

TERM
* no SetSta calls - return, no error, ignore
SETSTA
* no GetSta calls - return, no error, ignore
GETSTA
                    andcc     #^Carry             clear carry
                    rts

*
* Entry:
*	B = MSB of LSN
*	X = LSB of LSN
*	Y = address of path descriptor
*	U = address of device memory area
*
* Exit:
*	CC = carry set on error
*	B = error code
*
WRITE               clra                          0 =WRITE to disk
                    tstb                          Make sure 3rd byte of LSN is 0
                    bne       ERROR
                    pshs      x,y                 Save these registers for later
                    tst       ,s                  Check high bit of X (Low 16 bits of LSN)
                    bmi       ERROR2              Should equal 0
* Get Sector comes here with:
* Entry: A = read/write command code (0/1)
*	B = MSB of the disk's LSN
*	X = LSW of the disk's LSN
*	Y = path dsc. ptr
*	U = Device static storage ptr
* Exit:	CC = carry set on error
*	A = error status from command register
PutSect
*	orcc	#IntMasks	Kill interrupts
                    ldx       V.PORT,u            get address of hardware
                    sta       RAMDCON,x           Setup for a READ
                    ldy       PD.BUF,y            address of buffer
                    puls      d                   Get 2 byte LSN
                    std       RAMDADD,x           Put it in the address
                    lda       #$80                128 2 byte transfers
                    pshs      a                   On stack
LP2                 ldd       ,y++                get 2 bytes
                    std       RAMDDAT,x           write them to th RAM
LP1                 tst       RAMDSTA,x           is the transfer completed?
                    bpl       LP1
                    dec       ,s
                    bne       LP2
                    puls      b                   clear b
                    puls      y
*	andcc	#^(IntMasks)	Renable Interrupts
                    bra       TERM

                    emod

eom                 equ       *
