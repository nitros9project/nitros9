********************************************************************
* rbfnxcart - F256 cartridge expansion driver
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------

                    use       defsfile

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

u0000               rmb       DRVBEG+DRVMEM       Reserve room for 1 entry drive table
size                equ       .

                    fcb       DIR.+SHARE.+PREAD.+PWRIT.+PEXEC.+READ.+WRITE.+EXEC.

name                fcs       /rbfnxcart/
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
*          Y = Path desciptor pointer.
*          U = Device memory pointer.
Write               bsr       CalcMMUBlock        calculate the MMU Block & the offset for the sector
                    bcs       exit                branch if error
                    exg       x,y                 X = sector buffer pointer, Y= offset within the MMU block
* Transfer data between the RBF sector buffer & the RAM drive image sector buffer.
* Both READ and WRITE (with X,Y swapping between the two) call this routine.
MMU_SLOT            equ       3
TfrSect             orcc      #IntMasks           mask interrupts
                    ldb       >MMU_MEM_CTRL+MMU_SLOT save the MMU block number
                    pshs      b
                    sta       >MMU_MEM_CTRL+MMU_SLOT save the MMU block number
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
                    sta       >MMU_MEM_CTRL+MMU_SLOT remap in system block 0
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
                    ldd       1,s                 get the LSN off the stack
                    leax      DRVBEG,u            point to the drive table
                    cmpd      DD.TOT+1,x          compare against the LSW of the sector to table's number of sectors
                    bhs       cleanex@            sector number too large, exit with error
                    rolb                          D = D * 2
                    rola
                    rolb                          D = D * 4
                    rola
                    rolb                          D = D * 8
                    rola
                    ora       #$80                set the high bit (F256 expansion RAM/Flash is at $80-$9F)
                    sta       ,s                  save the MMU block on the stack
                    clrb                          calculate the offset within the 8KB block we want
                    lda       2,s                 get the sector number off of the stack
                    anda      #$1F                mask out all but what's within the 8KB address offset
                    addd      #$2000*MMU_SLOT     add the base address of the MMU slot
                    std       1,s                 save the updated offset back on the stack
                    ldy       PD.BUF,y            get the sector buffer address
                    puls      x,a,pc              get the offset and MMU block, then return
cleanex@            leas      3,s                 clean up the stack
sectex@             comb                          set the carry
                    ldb       #E$Sect             load the "bad sector" error
                    rts                           return

                    emod
eom                 equ       *
                    end
