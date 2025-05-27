********************************************************************
* rbmem - F256 RAM and Flash Driver
*
* Don't be afraid to use the F256 Flash Cartridge!  RT
* In developing this driver an extreme and unrealistic amount of
* Flash write cycles have been carried out for months with no apparent
* effects as of this writing. Having said this, wear-reduction and
* write-efficiency will be added to this driver over time.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*
*   0/0    ????/?/??   ?
* Original rbmem was written by Boisy P. but had no revision notes
*
*   1/1    2025/5/11   R Taylor
* Solid Flash writes, wear-reduction and write efficiency
*
                    use       defsfile

* If 1, during Init the Flash ID is shown on the F256 text screen in the upper right corner.
fDEBUG              equ       1
MAXDRIVES           equ       4
MMU_SLOT            equ       2
MMU_WINDOW          equ       $2000*MMU_SLOT
MMU_WORKSLOT        equ       MMU_SLOT_0+MMU_SLOT

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       2

                    mod       eom,name,tylg,atrv,ModEntry,size

                    org       DrvBeg
DrvTab              rmb       MaxDrives*DrvMem       ; Drive tables, 1 per drive

CDrvTab             rmb       2
SaveMMU             rmb       1
FlashBlock          rmb       1
CacheBlock          rmb       1
IsFlash             rmb       1
EmptySector         rmb       1

size                equ       .

                    fcb       DIR.+SHARE.+PREAD.+PWRIT.+PEXEC.+READ.+WRITE.+EXEC.

name                fcs       /rbmem/
                    fcb       edition

FLASH_ID_128K       fdb       $BFD5               SST brand
FLASH_ID_256K       fdb       $BFD6	          SST brand
FLASH_ID_512K       fdb       $BFD7	          SST brand
FLASH_ID_F256       fdb       $F256               Jr2 has the onboard Flash ID of ($BFD7) but is intercepted by the FPGA and returns $F256
ERASE_WAIT          equ       $2800               This value considers a dummy "cmpx #$0000" is in the delay loop

ModEntry            lbra      Init
                    lbra      Read
                    lbra      Write
                    lbra      GetStat
                    lbra      SetStat
                    lbra      Term



* Init routine - only gets called once per driver initialized.
* Called if you INIZ the device as well.
* Entry: Y = Address of device descriptor.
*        U = Device memory area.
* NOTE: All of device memory (Except V.PORT) are cleared to 0's.
Init
                    ldb       #MAXDRIVES          get default # drives
                    pshs      b
                    stb       V.NDRV,u            save it
                    leax      DRVBEG,u            point to drive table start
t@
                    clr       <V.TRAK,x
                    dec       <V.TRAK,x
                    clr       DD.TOT,x
*     Cartridge (128KB) = 1024 total LSNs
* Onboard Flash (512KB) = 2048 total LSNs
                    ldd       #$800
                    std       DD.TOT+1,x
                    leax      DRVMEM,x
                    dec       ,s
                    bne       t@
                    puls      b
  
                    ldd       M$Port+1,y          Get port address in device descriptor
                    std       V.PORT,u            and save to device memory (used by CalcMMUBlock)

                    clr       isFlash,u

                ifgt Level-1
                    lbsr      ReadFlashID         If compatible Flash ID is seen, isFlash is set to 1
                    lbsr      ShowFlashID         Print the 4-character Flash ID in the upper/right of the screen
                    lbsr      AskForCache         OS-9 Level II - only call to request a free 8K block of RAM
                    stb       CacheBlock,u        Save the block #
                else
                    clrb                          No error
                endc
                    rts                           Return with any error from the AskForCache routine

Term                clrb
                    rts


* Subroutine to calculate MMU block number and offset based on the requested sector.
*
* Entry:   Y = Path descriptor pointer.
*          U = Device memory pointer.
*        B:X = LSN to calculate for.
*
* Exit:    A = MMU block number we need to map in.
*          X = Offset within the MMU block to get sector from (always < 8KB).
*          Y = Sector buffer pointer for RBF.
CalcMMUBlock        lda       PD.DRV,y
                    cmpa      V.NDRV,u
                    bhs       drvex@
                    pshs      x,d
                    leax      DrvBeg,u
                    ldb       #DrvMem
                    lda       PD.DRV,y
                    mul
                    leax      d,x
                    stx       CDrvTab,u
                    puls      x,d
                    cmpb      DD.TOT,x            Test the MSB of the sector number
                    bhi       sectex@             Branch if not 0 (error)
                    pshs      a,x                 Preserve the LSW of the sector number
                    ldx       CDrvTab,u            Point to the drive table
                    ldd       1,s                 Get LSW of sector from stack
                    cmpd      DD.TOT+1,x          Compare against the LSW of the sector to table's number of sectors
                    bhs       cleanex@            Sector number too large, exit with error
                    aslb                          D = D * 2
                    rola
                    aslb                          D = D * 4
                    rola
                    aslb                          D = D * 8
                    rola
                    ora       V.PORT+1,u          Set the block starting bit
                    sta       ,s                  Save the MMU block on the stack
                    clrb                          Calculate the offset within the 8KB block we want
                    lda       2,s                 Get the sector number off of the stack
                    anda      #$1F                Mask out all but what's within the 8KB address offset
                    addd      #MMU_WINDOW         Add the base address of the MMU slot
                    std       1,s                 Save the updated offset back on the stack
                    ldy       PD.BUF,y            Get the sector buffer address
                    puls      pc,x,a              Get the offset and MMU block, then return
cleanex@            leas      3,s                 Clean up the stack
sectex@             comb                          Set the carry
                    ldb       #E$Sect             Load the "bad sector" error
                    rts                           Return
drvex@              comb                          Set the carry
                    ldb       #$F0                Unit error (illegal drive number)
                    rts                           Return

* Entry: B:X = LSN to read (only X will be used).
*          Y = Path descriptor pointer.
*          U = Device memory pointer.
Read                lda       >MMU_WORKSLOT       Save the MMU block number
                    sta       SaveMMU,u
                    pshs      y,x                 Preserve the path descriptor & device memory pointers
                    bsr       CalcMMUBlock        Calculate the MMU block & offset for the sector
                    bcs       ex@                 Branch if error
                ifgt Level-1
                    sta       FlashBlock,u
                endc
                    orcc      #IntMasks
                    bsr       TfrSect             Transfer the sector from the RAM drive to PD.BUF
                    puls      y,x                 Restore the path descriptor & device memory pointers
                    leax      ,x                  Is this LSN0?
                    bne       CleanRWExit         Branch if not
                    ldx       PD.BUF,y            else get the path descriptor buffer into X
                    ldy       cDrvTab,u           Recall this drive's memory pointer from CalcMMUBlock routine
                    ldb       #DD.SIZ             Set the counter to the size
l@                  lda       ,x+                 Get a byte from the source
                    sta       ,y+                 Save it in the destination
                    decb                          Decrement the counter
                    bne       l@                  Branch of more to do
                    bra       CleanRWExit
ex@                 puls      y,x,pc              Restore registers and return

CleanRWExit         lda       SaveMMU,u
                    sta       >MMU_WORKSLOT       remap in system block 0
                    andcc     #^IntMasks          turn on interrupts and clear carry to indicate no error
                    clrb                          no errors
                    rts

* Entry: B:X = LSN to write.
*          Y = Path descriptor pointer.
*          U = Device memory pointer.
Write               lda       >MMU_WORKSLOT       Get the contents of working slot
                    sta       SaveMMU,u           Save in driver vars
                    lbsr      CalcMMUBlock        Calculate the MMU Block & the offset for the sector
                    bcs       x@                  Branch if error
                    orcc      #IntMasks           Mask interrupts
                    exg       x,y                 Make  X = sector buffer pointer, Y= offset within the MMU block
                ifgt      Level-1
                    sta       FlashBlock,u
                    tst       IsFlash,u
                    lbne      TfrFSect
                endc
                    bsr       TfrSect
                    bra       CleanRWExit
x@                  rts


* Transfer data between the RBF sector buffer & the RAM drive image sector buffer.
* Both READ and WRITE (with X,Y swapping between the two) call this routine.
TfrSect             sta       >MMU_WORKSLOT       switch in the working block 
* 6809 - Use StkBlCpy (either system wide or local to driver) ?
                    ldb       #64                 64 sets of 4 bytes to copy
                    pshs      b,u                 save the counter & U
                    leau      ,x                  point U to the source of the copy
l@                  pulu      d,x                 get 4 bytes
                    std       ,y++                save the first two bytes in the sector buffer
                    stx       ,y++                and the next one
                    dec       ,s                  decrement the 4 byte block counter
                    bne       l@                  branch until all 256 bytes are done
                    puls      b,u                 B = 0, restore U
*                    andcc     #^(IntMasks+Carry)  turn on interrupts and clear carry to indicate no error
                    rts                           return

GetStat             clrb
                    rts

SetStat             clrb
                    rts


*  =================================================================================
* |  Everything below this point is for the Flash Writable version of this driver   |
*  =================================================================================

                    ifgt      Level-1

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
ReadFlashID         pshs      cc
                    orcc      #IntMasks
                    ldb       >MMU_WORKSLOT
                    pshs      b
                    lbsr      FlashSend5555AA     Send command "Software ID Entry"
                    lbsr      FlashSend2AAA55
                    ldb       #$90
                    lbsr      FlashSend5555XX
                    ldd       >MMU_WINDOW         Get ID of Flash Chip (if using MMU_SLOT_2)
                    tfr       d,x
                    lbsr      FlashSend5555AA     Send command "Software ID Exit"
                    lbsr      FlashSend2AAA55
                    ldb       #$F0
                    lbsr      FlashSend5555XX
                    puls      b
                    stb       >MMU_WORKSLOT
                    cmpx      FLASH_ID_F256,pcr
                    beq       f@
                    cmpx      FLASH_ID_128K,pcr
                    beq       f@
                    cmpx      FLASH_ID_256K,pcr
                    beq       f@
                    cmpx      FLASH_ID_512K,pcr
                    bne       s@                  Debug, show the Flash Cart's ID on the text screen
f@                  inc       IsFlash,u
s@                  puls      cc,pc


ShowFlashID         lda       fDEBUG,u
                    beq       x@
                    pshs      cc
                    orcc      #IntMasks
                    ldb       >MMU_WORKSLOT
                    pshs      b
                    ldb       #$C2                Text screen block #
                    stb       >MMU_WORKSLOT 
                    tfr       x,d
                    lsra                          Do cheap binary to 4-digit HEX ASCII string
                    lsra
                    lsra
                    lsra
                    bsr       Bin2AscHex
                    sta       >MMU_WINDOW+80+76
                    tfr       x,d
                    anda      #$0f
                    bsr       Bin2AscHex
                    sta       >MMU_WINDOW+80+77
                    tfr       x,d
                    tfr       b,a
                    lsra                          Do cheap binary to 4-digit HEX ASCII string
                    lsra
                    lsra
                    lsra
                    bsr       Bin2AscHex
                    sta       >MMU_WINDOW+80+78
                    tfr       x,d
                    tfr       b,a
                    anda      #$0f
                    bsr       Bin2AscHex
                    sta       >MMU_WINDOW+80+79
                    puls      b
                    stb       >MMU_WORKSLOT
                    puls      cc                  Does this restore CPU interrupt masks?
x@                  rts

Bin2AscHex          anda      #$0f
                    cmpa      #9
                    bls       d@
                    suba      #10
                    adda      #'A'
                    bra       x@
d@                  adda      #'0'
x@                  rts


* Address $5555 in Flash cartridge is in block $82 and when block $82 is mapped to $4000 (MMU SLOT 2),
* the address $5555 translates to $5555, because $5555 becomes $1555 then added to $4000.
FlashSend5555AA     pshs      a
                    lda       V.PORT+1,u
                    anda      #$C0               Align to top of Flash chip
                    adda      #$02
                    sta       >MMU_WORKSLOT
                    lda       #$AA
                    sta       >$5555
                    puls      a,pc

* Address $5555 in chip is in block $82 and when block $82 is mapped to $4000 (MMU SLOT 2),
* the address $5555 translates to $5555, because $5555 becomes $1555 then added to $4000.
FlashSend5555XX     pshs      a
                    lda       V.PORT+1,u
                    anda      #$C0               Align to top of Flash chip
                    adda      #$02
                    sta       >MMU_WORKSLOT
                    stb       >$5555
                    puls      a,pc

* Address $2AAA in chip is in block $81 and when block $81 is mapped to $4000 (MMU SLOT 2),
* the address $2AAA translates to $4AAA, because $2AAA becomes $0AAA then added to $4000.
FlashSend2AAA55     pshs      a
                    lda       V.PORT+1,u
                    anda      #$C0               Align to top of Flash chip
                    inca
                    sta       >MMU_WORKSLOT
                    lda       #$55
                    sta       >$4AAA
                    puls      a,pc


* 8K block copier, using single MMU slot
* Entry: A = source block
*        B = destination block
* Exit: destination block stays in MMU slot
*       all registers restored

AskForCache         ldb       #1                  Flash Write mode needs an 8K swap block of RAM
                    os9       F$AllRAM
                    rts                           Return with any error, otherwise reg.b = cache block

Flash2Cache         pshs      u,x,y,d
                    ldx       #MMU_WINDOW
                    ldy       #4096               2 bytes per iteration = 8192
c@                  ldb       ,s                  get source block from reg.a position on stack
                    stb       >MMU_WORKSLOT 
                    ldu       ,x
                    ldb       1,s                 get destination block from reg.b position on stack
                    stb       >MMU_WORKSLOT 
                    stu       ,x++
                    leay      -1,y
                    bne       c@
                    puls      d,u,x,y,pc

CheckEmpty          pshs      b,y
                    lda       ,y
                    clrb
a@                  anda      ,y+
                    decb
                    bne       a@
                    coma                          $FF becomes $00 which sets CC.Z ?
                    tsta
                    puls      b,y,pc

* Copy 8K Flash block into 8K Cache.
* Copy OS-9 sector into correct spot in 8K Cache.
* Is old OS-9 sector empty?  No, erase the associated 4K Flash sector and write back the 4K Cache sector.
* Is old OS-9 sector empty?  Yes, write only the 256-byte sector back to Flash.

TfrFSect            lda       FlashBlock,u        copy from Flash block to Cache block
                    ldb       CacheBlock,u
                    bsr       Flash2Cache
                    bsr       CheckEmpty          is the OS-9 sector that's already on Flash empty?
                    sta       EmptySector,u       save empty status
                    pshs      x,y
                    lda       CacheBlock,u
                    lbsr      TfrSect             Write the 256-byte sector into the 8K Cache
                    puls      x,y
                    tst       EmptySector,u
                    beq       c@                  old OS-9 sector is empty, so we just need to write over Only It
                    tfr       y,d                 Y = address of OS-9 256-byte sector within the 8K Cache
                    anda      #$10                compute which half of the 8K Flash block it's in (A12 of address)
                    tfr       d,x               
                    leax      MMU_WINDOW,x        base start of the RAM copy of the new Flash sector to write back
                    lsra                          OS-9 sector on Flash is dirty (used), so we need to rewrite entire 4K Flash sector
                    lsra
                    lsra
                    lsra                          compute 0=1st half of 4K Flash sector, 1=2nd half
                    ldb       FlashBlock,u        what 8K Flash block is the sector in?
                    lbsr      Erase4KSector
                    ldy       #4096               at this point X needs to point to the 4K Sector within the 8K Cache
                    bra       w@                  start writing 4K Sector from 8K Cache to Flash
c@                  tfr       y,x                 Y = address of OS-9 256-byte sector within the 8K Cache
                    ldy       #256                write only the OS-9 sector to Flash
w@                  ldb       CacheBlock,u
                    stb       >MMU_WORKSLOT
                    lda       ,x
*
                    ldb       V.PORT+1,u
                    andb      #$C0               Align to top of Flash chip
                    addb      #$02
                    stb       >MMU_WORKSLOT
                    ldb       #$AA
                    stb       >$5555
*
                    ldb       V.PORT+1,u
                    andb      #$C0               Align to top of Flash chip
                    incb
                    stb       >MMU_WORKSLOT
                    ldb       #$55
                    stb       >$4AAA
*
                    ldb       V.PORT+1,u
                    andb      #$C0               Align to top of Flash chip
                    addb      #$02
                    stb       >MMU_WORKSLOT
                    ldb       #$A0
                    stb       >$5555
*
                    ldb       FlashBlock,u
                    stb       >MMU_WORKSLOT
                    ldb       ,x
                    sta       ,x+                 REQUIRED: when address changes the data is latched
v@                  cmpa      -1,x
                    cmpa      -1,x
                    beq       g@
                    decb
                    bne       v@
                    lda       SaveMMU,u
                    sta       >MMU_WORKSLOT       remap in system block 0
                    ldb       #$F3                CRC ERROR - CRC error on read or write verify
                    andcc     #^IntMasks          turn on interrupts and clear carry to indicate no error
                    orcc      #1
                    rts
g@                  leay      -1,y
                    bne       w@
                    lda       SaveMMU,u
                    sta       >MMU_WORKSLOT       remap in system block 0
                    andcc     #^IntMasks          turn on interrupts and clear carry to indicate no error
                    clrb                          no errors
                    rts

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
* During an internal Erase operation, any attempt to read
* DQ7 will produce a '0'. Once the internal Erase
* operation is completed, DQ7 will produce a '1'. The
* Data# Polling is valid after the rising edge of fourth
* WE# (or CE#) pulse for Program operation. For Sector
* or Chip Erase, the Data# Polling is valid after the rising
* edge of sixth WE# (or CE#) pulse.

Erase4KSector       pshs      x,b,a               reg.b = block num to erase
                    lbsr      FlashSend5555AA
                    lbsr      FlashSend2AAA55
                    ldb       #$80
                    lbsr      FlashSend5555XX
                    lbsr      FlashSend5555AA
                    lbsr      FlashSend2AAA55
                    tst       ,s	                  which 4k sector of the 8k block do we erase?
                    bne       u@                  if reg.a = 1 then go erase 2nd sector
                    ldb       1,s                 get Flash block num from stack
                    stb       >MMU_WORKSLOT       map the Flash block in
                    lda       #$30                place #$30 (Sector Erase Command) on the data bus
                    sta       >MMU_WINDOW         place address of 4k block on the address bus
                    bra       d@                  go to the delay routine
u@                  ldb       1,s                 get Flash block num from stack
                    stb       >MMU_WORKSLOT       map the Flash block in
                    lda       #$30                place #$30 (Sector Erase Command) on the data bus
                    sta       >MMU_WINDOW+$1000   place address of 4k block on the address bus
                    bra       d@                  go to the delay routine
d@                  ldx       #ERASE_WAIT         delay to fully erase Flash sector
w@                  leax      -1,x
                    cmpx      #0                  REQUIRED because the wait count of $2800 was
                    bne       w@                   discovered while 6 padding cycles was included
                    puls      a,b,x,pc


* Chip Erase 5555H AAH,  2AAAH 55H,  5555H 80H,  5555H AAH,  2AAAH 55H,  5555H 10H
Wipe                clrb
                    pshs      cc
                    orcc      #IntMasks
                    lbsr      FlashSend5555AA
                    lbsr      FlashSend2AAA55
                    ldb       #$80
                    lbsr      FlashSend5555XX
                    lbsr      FlashSend5555AA
                    lbsr      FlashSend2AAA55
                    ldb       #$10			Place #$10 (Chip Erase Command) on the data bus
                    lbsr      FlashSend5555XX
                    puls      cc
x@                  rts                           return

                    endc

                    emod
eom                 equ       *
                    end
