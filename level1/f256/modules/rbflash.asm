********************************************************************
* rbflash - F256 cartridge expansion and flash driver
* TEMPORARY driver because the F256 port is in github-shambles and
* I have to build my drivers outside of os9boot and load them manually.
* This will eventually and hopefully become rbmem and do what it's
* supposed to do.   R Taylor

* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------

* The SST39LF010/020/040 and SST39VF010/020/040
* FLASH chips are 128K x8, 256K x8 and 5,124K x8

* CPU address where MMU block is mapped in for Flash Chip block r/w
WINDOW_FLASH	equ	$6000         $0000[MMU_SLOT_0],$2000[MMU_SLOT_1],$4000[MMU_SLOT_2],$6000[MMU_SLOT_3]
* window at $6000 (block 3) is used for flash blocks=> MMU_REG = 8+3

ERASE_WAIT	equ	$2800	Worked for ~10 tests but keep monitoring for glitches
*ERASE_WAIT	equ	$3000	Safe but slower


                    use       defsfile

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1


                    mod       eom,name,tylg,atrv,start,size

u0000               rmb       DRVBEG+DRVMEM       Reserve room for 1 entry drive table
fcpuaddr            rmb       2
fblock              rmb       1

size                equ       .

                    fcb       DIR.+SHARE.+PREAD.+PWRIT.+PEXEC.+READ.+WRITE.+EXEC.

name                fcs       /rbflash/
                    fcb       edition

start               bra       Init
                    nop
                    bra       Read
                    nop
                    bra       Write
                    nop
                    bra       GetStat
                    nop
                    bra       GetStat
                    nop
                    bra       GetStat

* Init routine - only gets called once per driver initialized.
* Called if you INIZ the device as well.
* Entry: Y = Address of device descriptor.
*        U = Device memory area.
* NOTE: All of device memory (Except V.PORT) are cleared to 0's.
Init                lda       #1                  only can handle 1 drive descriptor
                    sta       V.NDRV,u            update the device memory
                    leax      DRVBEG,u            point to the start of the drive table
                    ldd       #$FFFF              set initialization value
                    std       DD.TOT,x            set DD.TOT
                    stb       DD.TOT+2,x          to this value
                    ldd       M$Port+1,y          get port address in device descriptor
                    std       V.PORT,u            and save to device memory (used by CalcMMUBlock)
                    clrb                          clear error code and carry flag
                    rts                           return

* Entry: B:X = LSN to read (only X will be used).
*          Y = Path descriptor pointer.
*          U = Device memory pointer.
Read                pshs      y,x                 preserve the path descriptor & device memory pointers
                    bsr       CalcMMUBlock        calculate the MMU block & offset for the sector
                    bcs       ex@                 branch if error
                    bsr       TfrSect             else transfer the sector from the RAM drive to PD.BUF
                    puls      y,x                 restore the pointers
                    leax      ,x                  is this LSN0?
                    bne       GetStat             branch if not
                    ldx       PD.BUF,y            else get the path descriptor buffer into X
                    leay      DRVBEG,u            point to the start of the drive table
* 6809 - Use StkBlCpy (either system wide or local to driver).
                    ldb       #DD.SIZ             set the counter to the size
l@                  lda       ,x+                 get a byte from the source
                    sta       ,y+                 save it in the destination
                    decb                          decrement the counter
                    bne       l@                  branch of more to do
* GetStat/SetStat - no calls, just exit w/o error.
GetStat             clrb                          clear error code and carry flag
exit                rts                           return
ex@                 puls      y,x,pc              restore registers and return

* Entry: B:X = LSN to write.
*          Y = Path descriptor pointer.
*          U = Device memory pointer.
Write               bsr       CalcMMUBlock        calculate the MMU Block & the offset for the sector
                    bcs       exit                branch if error
                    exg       x,y                 X = sector buffer pointer, Y= offset within the MMU block
* Transfer data between the RBF sector buffer & the RAM drive image sector buffer.
* Both READ and WRITE (with X,Y swapping between the two) call this routine.
MMU_SLOT            equ       2
TfrSect             orcc      #IntMasks           mask interrupts
                    ldb       >MMU_SLOT_0+MMU_SLOT save the MMU block number
                    pshs      b
                    sta       >MMU_SLOT_0+MMU_SLOT save the MMU block number
* 6809 - Use StkBlCpy (either system wide or local to driver)
                    ldb       #64                 64 sets of 4 bytes to copy
                    pshs      b,u                 save the counter & U
                    leau      ,x                  point U to the source of the copy
l@                  pulu      d,x                 get 4 bytes
                    std       ,y++                save the first two bytes in the sector buffer
                    stx       ,y++                and the next one
                    dec       ,s                  decrement the 4 byte block counter
                    bne       l@                  branch until all 256 bytes are done
                    puls      b,u                 B = 0, restore U
                    puls      a
                    sta       >MMU_SLOT_0+MMU_SLOT remap in system block 0
                    andcc     #^(IntMasks+Carry)  turn on interrupts and clear carry to indicate no error
                    rts                           return

* Subroutine to calculate MMU block number and offset based on the requested sector.
*
* Entry:   Y = Path descriptor pointer.
*          U = Device memory pointer.
*        B:X = LSN to calculate for.
*
* Exit:    A = MMU block number we need to map in.
*          X = Offset within the MMU block to get sector from (always < 8KB).
*          Y = Sector buffer pointer for RBF.
CalcMMUBlock        tstb                          test the MSB of the sector number
                    bne       sectex@             branch if not 0 (error)
                    pshs      a,x                 preserve the LSW of the sector number
                    tfr       x,d                 transfer LSW of sector from X to D
                    leax      DRVBEG,u            point to the drive table
                    cmpd      DD.TOT+1,x          compare against the LSW of the sector to table's number of sectors
                    bhs       cleanex@            sector number too large, exit with error
                    aslb                          D = D * 2
                    rola
                    aslb                          D = D * 4
                    rola
                    aslb                          D = D * 8
                    rola
                    ora       V.PORT+1,u          set the block starting bit
                    sta       ,s                  save the MMU block on the stack
                    clrb                          calculate the offset within the 8KB block we want
                    lda       2,s                 get the sector number off of the stack
                    anda      #$1F                mask out all but what's within the 8KB address offset
                    addd      #$2000*MMU_SLOT     add the base address of the MMU slot
                    std       1,s                 save the updated offset back on the stack
                    ldy       PD.BUF,y            get the sector buffer address
                    puls      pc,x,a              get the offset and MMU block, then return
cleanex@            leas      3,s                 clean up the stack
sectex@             comb                          set the carry
                    ldb       #E$Sect             load the "bad sector" error
                    rts                           return


ProgCart
	ldx	#$c000
	ldb	#$9e
	stb	fblock,u
	lbsr	Write8KBlock
*	jsr	WaitaBit
x@	rts



ReadFlashID
	bsr	FlashSend5555AA                 * Send command "Software ID Entry"
	bsr	FlashSend2AAA55
	ldb	#$90
	bsr	FlashSend5555XX
	ldd	$6000
        tfr     d,x
	bsr	FlashSend5555AA                 * Send command "Software ID Exit"
	bsr	FlashSend2AAA55
	ldb	#$F0
	bsr	FlashSend5555XX
	rts


* Address $5555 in chip is in block $82 and when block $82 is mapped to $6000,
* the address $5555 translates to $7555
FlashSend5555AA
        pshs            d
	lda	#$82                            $42 for onboard Flash
	sta	>MMU_SLOT_3
	lda	#$AA
	sta	$7555
	puls            d,pc
FlashSend5555XX
        pshs            d
	lda	#$82                            $42 for onboard Flash?
	sta	>MMU_SLOT_3
	stb	$7555                           
	puls            d,pc

* Address $2AAA in chip is in block $81 and when block $81 is mapped to $6000,
* the address $2AAA translates to $6AAA
FlashSend2AAA55
	pshs	d
	lda	#$81                            $41 for onboard Flash?
	sta	>MMU_SLOT_3
	lda	#$55
	sta	$6AAA
	puls    d,pc



* 3.3 Sector Erase Operation
* The Sector Erase operation allows the system to erase
* the device on a sector-by-sector basis. The sector
* architecture is based on uniform sector size of
* 4 Kbytes. The Sector Erase operation is initiated by
* executing a six-byte command load sequence for
* Software Data Protection with Sector Erase command
* (30H) and Sector Address (SA) in the last bus cycle.
* The sector address is latched on the falling edge of the
* sixth WE# pulse, while the command (30H) is latched
* on the rising edge of the sixth WE# pulse. The internal
* Erase operation begins after the sixth WE# pulse. The
* End-of-Erase can be determined using either Data#
* Polling or Toggle Bit methods. See Figure 7-6 for timing
* waveforms. Any commands written during the Sector
* Erase operation will be ignored.

Erase4KSector
	pshs	x,b			block num to erase
	bsr	FlashSend5555AA
	bsr	FlashSend2AAA55
	ldb	#$80
	bsr	FlashSend5555XX
	bsr	FlashSend5555AA
	bsr	FlashSend2AAA55
	cmpx	#0
	bne	u@			erase first 4k sector of 8k block
	ldb	,s			get block num from stack
	stb	>MMU_SLOT_3		erase second 4k sector of 8k block
	lda	#$30
	sta	$6000
	bra	w@
u@	ldb	,s
	stb	>MMU_SLOT_3
	lda	#$30
	sta	$7000
w@	ldx	#ERASE_WAIT	Delay counter to fully erase Flash sector
w1@	leax	-1,x
	cmpx	#$0000
	bne	w1@
	puls      b,x,pc

*; accu has to contain flashblock number.
erase8KBlock
        ldx	#0
        bsr	Erase4KSector
        ldx	#1
        bsr	Erase4KSector
        rts

Write8KBlock
	orcc	#IntMasks
	pshs	y,u
	pshs	x,b			cpu addr, block num

        ldx	#0
        bsr	Erase4KSector
        ldx	#1
        bsr	Erase4KSector

	ldb	,s			get block num from stack
	ldx	1,s			get cpu addr from stack
	ldu	#$6000           flash block transfer window
        ldy	#8192           # of bytes in a bank/block

* Load data first, then address, command
w@	lbsr	FlashSend5555AA
	bsr	FlashSend2AAA55
	ldb	#$A0
	bsr	FlashSend5555XX $A0
        ldb     fblock,u
	stb	>MMU_SLOT_3
	lda	,x+
	sta	,u+
	leay	-1,y
	bne	w@

*	bsr	verify8KBlock
	puls	x,b
	puls	u,y
	andcc     #^(IntMasks+Carry)  turn on interrupts and clear carry to indicate no error
	rts





                    emod
eom                 equ       *
                    end
