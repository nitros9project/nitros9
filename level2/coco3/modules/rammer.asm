********************************************************************
* Rammer - NitrOS-9 Level 2 RAM Disk
*
* $Id$
*
* Alan DeKok's version of RAMMER - Based on original Keving Darling version
*
* NOTE: For some reason, when DEINIZing /r0, the INIT routine gets called...
*       but it still deallocates memory!
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   4      ????/??/??  ???
* Original Kevin Darling Version.
*
*   5      2000/03/14  L. Curtis Boyle
* Several changes
*
*   5r2    2000/05/09  L. Curtis Boyle
* Allowed driver to go past 400K, attempted some fixes for handling /MD,
* so that setting vfy=0 on /R0 would not completely crash the system.
* Fixed some error reporting bugs that would crash the system, and
* moved entry table to between READ/WRITE to allow short branches to both.
*
*   5r3    2019/03/23  L. Curtis Boyle
* Fixed MD so that it works properly with 2 MB RAM systems. Also optimized 6809
* Sector read/write. Also fixed a signed math bug when >127 MMU blocks are assigned
*   to a RAM drive.
*   5r4    2020/09/02  L. Curtis Boyle
* Optimized 6809 sector read/write speed further

* Following CAN be set higher, but will take another page of system RAM then.
* 200 will allow maximum of 1,638,400 byte RAM drive.
MAXBLOCK            set       201                 Maximum # of MMU blocks allowed in RAM drive

                    nam       Rammer
                    ttl       NitrOS-9 Level 2 RAM Disk

                    ifp1
                    use       defsfile
                    endc

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $04
edition             set       5

                    mod       eom,name,tylg,atrv,start,size

* Device mem stuff - can make MMUTable bigger, but will take 2 pages of system
*  RAM then for device memory
u0000               rmb       DRVBEG+DRVMEM       Reserve room for 1 entry drive table
MDFlag              rmb       1                   0=R0 descriptor, <>0=MD descriptor
numofBlk            rmb       1                   # of MMU blocks allocated for RAM drive
MMUTable            rmb       MAXBLOCK            Table of MMU Block #'s being used.
size                equ       .

                    fcb       DIR.+SHARE.+PREAD.+PWRIT.+PEXEC.+READ.+WRITE.+EXEC.

name                fcs       /Rammer/
                    fcb       edition

* Terminate routine - deallocates RAM
L0024               lda       <numofBlk,u         Get # blocks we had allocated
                    beq       L003D               If none, exit
                    leay      <MMUTable,u         Point to MMU block table
                    IFNE      H6309
                    clre                          Hi byte of block # to allocate (always 0)
L002E               ldf       ,y                  Get block #
                    ELSE
L002E               ldb       ,y
                    ENDC
                    clr       ,y+                 Zero it out in table
                    IFNE      H6309
                    tfr       w,x                 Block # to deallocate
                    ELSE
                    pshs      a
                    clra
                    tfr       d,x
                    puls      a
                    ENDC
                    ldb       #$01                1 block to deallocate
                    os9       F$DelRAM            Deallocate the block
                    deca                          Dec # of blocks to clean out
                    bne       L002E               Do until entire RAM drive is deallocated
L003D               clrb                          Exit w/o error
                    rts

* Deallocate RAM allocated so far, exit with no RAM error
L003F               bsr       L0024               Deallocate all RAM Drive ram blocks
L0041               comb                          Exit no RAM left error
                    ldb       #E$MemFul
                    rts

* Init routine - only gets called once per driver inited.
* Called if you INIZ the device as well
* Entry: Y=Address of device descriptor
*        U=Device mem area
* NOTE: All of device mem (Except V.PORT) is cleared to 0's
Init                lda       #1
                    sta       V.NDRV,u            only can handle 1 drive descriptor
                    leax      DRVBEG,u            Point to start of drive table
                    sta       DD.TOT+2,x          Set DD.TOT to non 0 value
                    lda       <M$Opt,y            Get # of bytes in device descriptor table
                    deca
* Following is if 1st access to RAMMER is on /MD
                    beq       GetStat             0 (/MD desciptor), then exit w/o error
                    ldb       <IT.CYL+1,y         Get LSB of # of cylinders
                    lda       <IT.SID,y           Get # of heads
                    mul                           Calculate # head/cyls total
                    tsta                          Have we overflowed past 255?
                    bne       L0041               Yes, exit with no RAM error
                    lda       <IT.SCT+1,y         Get # of sectors/track
                    mul                           Calculate # of sectors for RAM drive
                    subd      <IT.SCT,y           Subtract 1 tracks worth
                    addd      <IT.T0S,y           Add in the special track 0's # sectors/track
                    std       DD.TOT+1,x          Save as # sectors on drive
                    addd      #$001F              Round up to nearest 8K block
                    IFNE      H6309
                    rold                          Shift # of 8K blocks needed into A
                    rold
                    rold
                    ELSE
                    rolb
                    rola
                    rolb
                    rola
                    rolb
                    rola
                    ENDC
                    cmpa      #MAXBLOCK           If higher than max, exit with mem full error
                    bhi       L0041
                    leax      <MMUTable,u         Point to RAM block table
                    IFNE      H6309
                    tfr       a,e                 # blocks left to allocate
                    ENDC
L0078               ldb       #$01                Try to allocate 1 8K RAM block
                    IFEQ      H6309
                    pshs      a
                    ENDC
                    os9       F$AllRAM
                    IFEQ      H6309
                    puls      a
                    ENDC
                    bcs       L003F               If error, deallocate RAM, and exit
                    inc       <numofBlk,u         Bump up # of blocks allocated
                    stb       ,x+                 Save MMU block # allocated in table
                    IFNE      H6309
                    dece                          Do until done all blocks requested
                    ELSE
                    deca
                    ENDC
                    bne       L0078
                    clrb                          No error & return
                    rts

* Entry: B:X=LSN to read (only X will be used, even with 2 MB)
*        Y=Path dsc. ptr
*        U=Device mem ptr
Read                pshs      x,y,u               Preserve LSW of LSN, path dsc & device mem ptrs
                    bsr       L00C8               Calculate MMU block & offset for sector (returns y,u ptrs)
                    bcs       L00A5               Error, exit with it
                    bsr       L00AE               Transfer sector from RAM drive to PD.BUF
                    puls      x,y,u               Restore ptrs
                    leax      ,x                  Sector 0?
                    bne       GetStat             No, exit without error
                    ldx       PD.BUF,y            Get buffer ptr
                    leay      DRVBEG,u            Point to start of drive table
                    IFNE      H6309
                    ldw       #DD.SIZ             Copy the info we need into drive table
                    tfm       x+,y+
                    ELSE
* 6809 - could use full (including odd size) StkBlCpy (either system wide or local to driver)
*   but it's only $15 bytes,so may just leave it
                    ldb       #DD.SIZ             Copy the info we need into drive table
ReadLp              lda       ,x+
                    sta       ,y+
                    decb
                    bne       ReadLp
                    ENDC
* GetStat/SetStat - no calls, just exit w/o error
GetStat             clrb
                    rts

L00A5               puls      x,y,u,pc

start               bra       Init
                    nop
                    bra       Read
                    nop
                    bra       Write
                    nop
                    bra       GetStat
                    nop
                    bra       GetStat             Actually SetStat (no calls, so same routine)
                    nop
                    lbra      L0024               Terminate (returns memory)

* Transfer between RBF sector buffer & RAM drive image sector buffer
* Called by both READ and WRITE (with U,Y swapping between the two)
* Entry: U=source of copy ptr
*        Y=dest of copy ptr
*        A=MMU Block # sector we want is in
* Exit: U,Y incremented by 256. B=0, A&X modified
L00AE               orcc      #IntMasks           Shut IRQ's off
                    sta       >DAT.Regs           Map in RAM drive block into block #0
                    IFNE      H6309
                    ldw       #$0100              256 byte transfer
                    tfm       u+,y+               Copy between the two buffers (
                    clrb                          MMU block 0 to map back into Task 0 DAT
                    ELSE
* 8 byte mini-stackblast routine - 55 cycles/8 bytes copied - 1760 cycles/sector
                    ldb       #32                 32 sets of 8 bytes to copy (always 256 byte sectors)
                    pshs      b                   Save counter
WriteLp             pulu      d,x                 (9) Get 4 bytes
                    std       ,y                  (5) Save them in sector buffer
                    stx       2,y                 (6)
                    pulu      d,x                 (9) Get 4 more bytes
                    std       4,y                 (6) Save them in sector buffer
                    stx       6,y                 (6)
                    leay      8,y                 (5) Bump dest ptr by 8
                    dec       ,s                  (6) Dec 8 byte block counter
                    bne       WriteLp             (3) Do all 256 bytes
                    puls      b                   Eat temp stack and set B to 0 for MMU
                    ENDC
                    stb       >DAT.Regs           Remap in system block 0 (B has to be 0 here)
                    andcc     #^(IntMasks+Carry)  Turn IRQ's back on & no error
                    rts

* Entry: B:X = LSN to write
*        Y=Path dsc. ptr
*        U=Device mem ptr
Write               pshs      u                   Save dev mem ptr
                    bsr       L00C8               Calculate MMU Block & offset for sector (returns y,u ptrs)
                    bcs       L00A7               Error,exit with it
                    exg       u,y                 U=Sector buffer ptr, Y=Offset within MMU block
                    bsr       L00AE               Map in block, copy sector data
L00A7               puls      u,pc                Restore device mem ptr & return


* Subroutine to calculate MMU block # and offset based on sector # requested
* Entry: Y=path dsc. ptr
*        U=device mem ptr
*        B:X=LSN to calculate for
* Exit: A=MMU block # we need to map in
*       U=offset within MMU block to get sector from (always <8K) - ready for stack blast
*       Y=Sector buffer ptr for RBF
*       MDFlag,u=0 if NOT MD, else MD
L00C8               clr       MDFlag,u            Flag that we are on "real" RAM Drive
                    IFNE      H6309
                    ldw       PD.DEV,y            Get our Device table entry ptr
                    ldw       V$DESC,w            Get device descriptor ptr
                    lda       M$Opt,w             Get size of options table
                    ELSE
                    pshs      x
                    ldx       PD.DEV,y            Get our Device table entry ptr
                    ldx       V$DESC,x            Get device descriptor ptr
                    lda       M$Opt,x             Get size of options table
                    puls      x
                    ENDC
                    deca
                    bne       L00DB               Not MD, skip ahead
                    inc       MDFlag,u            Flag we are on MD
                    sta       <PD.SIZ,y
                    sta       <PD.SIZ+3,y
                    sta       <PD.SSZ,y
                    ldd       <D.BlkMap+2         Get end of block memory ptr
                    subd      <D.BlkMap           Calc # of blocks of RAM
* Bug fix for 2MB RAM systems - LCB 03/23/2019
                    tsta                          2 MB RAM (B=0 always if this is true)?
                    beq       Not2MB              No, do multiplication
                    lda       #$20                Force for 2 MB
                    bra       TwoMB

Not2MB              lda       #32                 * 32 for # of 'sectors'
                    mul
TwoMB               std       <PD.SIZ+1,y         Save as middle word of file size
                    std       <PD.SSZ+1,y         Save as segment size
                    bra       L00DE               Skip ahead (sector # will allow all 2 MB)

L00DB               tstb                          Test MSB of sector #
                    bne       L010F               <>0, exit with Sector error
L00DE               pshs      x                   Preserve LSW of sector #
                    ldd       ,s                  Load it again into D
                    tst       MDFlag,u            We on MD?
                    bne       L00EE               Yes, skip ahead
                    leax      DRVBEG,u            Point to drive table
                    cmpd      DD.TOT+1,x          LSW of sector compared to table's # of sectors
                    bhs       L010E               Sector # too large, exit with error
L00EE               equ       *
                    IFNE      H6309
                    rold                          A=MMU block offset in RAM drive image
                    rold
                    rold
                    ELSE
                    rolb
                    rola
                    rolb
                    rola
                    rolb
                    rola
                    ENDC
                    tst       MDFlag,u            We on /MD?
                    bne       L0100               Yup, skip calculating MMU stuff
                    leax      <MMUTable,u         Point to MMU table
* Signed A is going to screw up on $80 and higher!
                    tfr       a,b                 D=A (make 16 bit since A can't be signed)
                    clra
                    lda       d,x                 Get MMU block # we want
                    beq       L010E               If 0, exit with sector error
L0100               pshs      a                   Save block #
                    clrb                          Calculate offset within 8k block we want
                    lda       2,s
                    anda      #$1F                Mask out all but within 8K address offset
                    std       1,s                 Save offset
                    ldy       PD.BUF,y            Get sector buffer address
                    puls      a,u,pc              Get offset, MMU block & return

L010E               leas      2,s                 Eat X on stack
L010F               comb                          Exit with bad sector #
                    ldb       #E$Sect
                    rts

                    emod
eom                 equ       *
                    end
