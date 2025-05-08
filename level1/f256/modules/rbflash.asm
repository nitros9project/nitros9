********************************************************************
* rbflash - F256 cartridge expansion and flash driver
* Experimental driver for seeing how we can use the Flash cartridge.

* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------

                    use       defsfile


MMU_SLOT            equ       2
MMU_WINDOW          equ       $2000*MMU_SLOT

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,ModEntry,size

                    org       DRVBEG+1*DRVMEM

FlashBank           rmb       1
RAMAddr             rmb       2
IsFlash             rmb       1

size                equ       .

                    fcb       DIR.+SHARE.+PREAD.+PWRIT.+PEXEC.+READ.+WRITE.+EXEC.

name                fcs       /rbflash/
                    fcb       edition

FLASH_ID_128K       fdb       $BFD5           SST brand
FLASH_ID_256K       fdb       $BFD6	      SST brand
FLASH_ID_512K       fdb       $BFD7	      SST brand
ERASE_WAIT          fdb       $2800           Tightest safe delay only when using    leax -1,x  cmpx #0000  bne loop  method
*ERASE_WAIT          fdb       $3000           trial delay


ModEntry            lbra       Init
                    lbra       Read
                    lbra       Write
                    lbra       GetStat
                    lbra       SetStat
                    lbra       Term

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

                    lbsr      ReadFlashID
                    lbsr      ShowFlashID

                    ldb       #1                  we need 1 8k RAM block
                    os9       F$AllRAM            to read the Flash block into for updating and writing back to Flash
                    bcs       x@
                    stb       SwapBlock,u

                    clrb
x@                    rts

Term                clrb
                    rts

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
cx@                 clrb
                    rts
ex@                 puls      y,x,pc              restore registers and return

* Entry: B:X = LSN to write.
*          Y = Path descriptor pointer.
*          U = Device memory pointer.
Write               bsr       CalcMMUBlock        calculate the MMU Block & the offset for the sector
                    bcs       x@                  branch if error
                    exg       x,y                 make  X = sector buffer pointer, Y= offset within the MMU block
* Transfer data between the RBF sector buffer & the RAM drive image sector buffer.
* Both READ and WRITE (with X,Y swapping between the two) call this routine.
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
x@                  rts                           return


GetStat             pshs      a,x,y,u
                    lbsr      ReadFlashID
                    lbsr      ShowFlashID
                    clrb                          clear error code and carry flag
                    puls      a,x,y,u,pc          return

SetStat             clrb                          clear error code and carry flag
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
                    addd      #MMU_WINDOW         add the base address of the MMU slot
                    std       1,s                 save the updated offset back on the stack
                    ldy       PD.BUF,y            get the sector buffer address
                    puls      pc,x,a              get the offset and MMU block, then return
cleanex@            leas      3,s                 clean up the stack
sectex@             comb                          set the carry
                    ldb       #E$Sect             load the "bad sector" error
                    rts                           return

* The SST39LF010/020/040 and SST39VF010/020/040
* FLASH chips are 128K x8, 256K x8 and 5,124K x8
*
* With A MS -A1 = 0; SST Manufacturer’s ID = BFH, is read with A0 = 0,
* SST39LF/VF010 Device ID = D5H, is read with A0 = 1.
* SST39LF/VF020 Device ID = D6H, is read with A0 = 1.
* SST39LF/VF040 Device ID = D7H, is read with A0 = 1.
*
* Translation: The value we read from $6000 contains:
*  MSB = Manufacturer's ID = $BF (Microchip Technology - SST)
*  LSB = Device ID = $DF = 128KB of Flash
*                    $D6 = 256KB of Flash <----- Foenix Flash cartridge
*                    $D7 = 512KB of Flash
*
* In summary: We better see $BFD6 or $BFD7 as the chip ID.
*
ReadFlashID
	pshs	cc
	orcc	#IntMasks
	ldb	>MMU_SLOT_0+MMU_SLOT
	pshs	b
	bsr	FlashSend5555AA                 * Send command "Software ID Entry"
	bsr	FlashSend2AAA55
	ldb	#$90
	bsr	FlashSend5555XX
	ldd	MMU_WINDOW			Get ID of Flash Chip (if using MMU_SLOT_2)
        tfr     d,x
	bsr	FlashSend5555AA                 * Send command "Software ID Exit"
	bsr	FlashSend2AAA55
	ldb	#$F0
	bsr	FlashSend5555XX
	puls	b
	stb	>MMU_SLOT_0+MMU_SLOT
	clr	isFlash,u
	cmpx	FLASH_ID_256K,pcr
	beq	f@
	cmpx	FLASH_ID_512K,pcr
	beq	f@
	bra	s@			Debug, show the Flash Cart's ID on the text screen
f@	inc	IsFlash,u
s@	puls	cc,pc


* Address $5555 in chip is in block $82 and when block $82 is mapped to $4000 (MMU SLOT 2),
* the address $5555 translates to $5555, because $5555 becomes $1555 then added to $4000.
FlashSend5555AA
        pshs	d
	lda	#$82                            $42 for onboard Flash
	sta	>MMU_SLOT_0+MMU_SLOT
	lda	#$AA
	sta	$5555				If using MMU_SLOT_2
	puls	d,pc

FlashSend5555XX
* Address $5555 in chip is in block $82 and when block $82 is mapped to $4000 (MMU SLOT 2),
* the address $5555 translates to $5555, because $5555 becomes $1555 then added to $4000.
        pshs	d
	lda	#$82                            $42 for onboard Flash?
	sta	>MMU_SLOT_0+MMU_SLOT
	stb	$5555				If using MMU_SLOT_2
	puls	d,pc

* Address $2AAA in chip is in block $81 and when block $81 is mapped to $4000 (MMU SLOT 2),
* the address $2AAA translates to $4AAA, because $2AAA becomes $0AAA then added to $4000.
FlashSend2AAA55
	pshs	d
	lda	#$81                            $41 for onboard Flash?
	sta	>MMU_SLOT_0+MMU_SLOT
	lda	#$55
	sta	$4AAA				If using MMU_SLOT_2
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
	cmpx	#0			Which 4k sector of the 8k block do we erase?
	bne	u@			if x = 1 then go erase 2nd sector
	ldb	,s			get block num from stack
	stb	>MMU_SLOT_0+MMU_SLOT    map the block in
	lda	#$30			Place #$30 (Sector Erase Command) on the data bus
	sta	MMU_WINDOW		Place address of 4k block on the address bus
	bra	d@			go to the delay routine
u@	ldb	,s			get block num from stack
	stb	>MMU_SLOT_0+MMU_SLOT    map the block in
	lda	#$30			Place #$30 (Sector Erase Command) on the data bus
	sta	MMU_WINDOW+$1000	Place address of 4k block on the address bus
d@	ldx	ERASE_WAIT,pcr		delay to fully erase Flash sector
w@	leax	-1,x
	cmpx    #$0000                  <--- Used to tweak the delay based on $2800
	bne	w@                      <---  until another delay value is tested WITHOUT using cmpx #$0000
	puls    b,x,pc


* A = MMU block
* X = sector buffer pointer, Y= offset within the MMU block
Write8KBlock
	orcc	#IntMasks           mask interrupts
	sta	FlashBank,u
	sty     RAMAddr,u

	ldb	>MMU_SLOT_0+MMU_SLOT save the MMU block number
	pshs	x,y,u,b

        ldx	#0			Specify 1st 4k sector in 8k block
        bsr	Erase4KSector
        ldx	#1			Specify 2nd 4k sector in 8k block
        bsr	Erase4KSector

	ldb	FlashBank,u			get block num from stack
	ldx	RAMAddr,u		get cpu addr from stack
	ldu	#MMU_WINDOW           flash block transfer window
        ldy	#8192           # of bytes in a bank/block

* Load data first, then address, command
w@	lbsr	FlashSend5555AA
	bsr	FlashSend2AAA55
	ldb	#$A0
	bsr	FlashSend5555XX $A0
        ldb     FlashBank,u
	stb	>MMU_SLOT_0+MMU_SLOT
	lda	,x+
	sta	,u+
	leay	-1,y
	bne	w@

	puls	a,x,y,u
	sta	>MMU_SLOT_0+MMU_SLOT remap in system block 0
	andcc	#^IntMasks  turn on interrupts and clear carry to indicate no error
	clrb
	rts

ShowFlashID
	pshs	cc
	orcc	#IntMasks
	ldb	>MMU_SLOT_0+MMU_SLOT
	pshs	b
	ldb	#$C2				text bank
	stb	>MMU_SLOT_0+MMU_SLOT 

	tfr       x,d
	lsra                          do cheap binary to 4-digit HEX ASCII string
	lsra
	lsra
	lsra
	bsr	Bin2AscHex
	sta	>MMU_WINDOW+80+76

	tfr	x,d
	anda	#$0f
	bsr	Bin2AscHex
	sta	>MMU_WINDOW+80+77

	tfr	x,d
	tfr	b,a
	lsra                          do cheap binary to 4-digit HEX ASCII string
	lsra
	lsra
	lsra
	bsr	Bin2AscHex
	sta	>MMU_WINDOW+80+78

	tfr	x,d
	tfr	b,a
	anda	#$0f
	bsr	Bin2AscHex
	sta	>MMU_WINDOW+80+79

	puls	b
	stb	>MMU_SLOT_0+MMU_SLOT

	clrb                          clear error code and carry flag
	puls	cc,pc

Bin2AscHex
	anda	#$0f
	cmpa	#9
	bls	d@
	suba	#10
	adda	#'A'
	bra	x@
d@	adda	#'0'
x@	rts





                    emod
eom                 equ       *
                    end
