********************************************************************
* RamPak - Disto RAM Pak device driver
*
* $Id$
*
* Ed.    Comments                                       Who YY/MM/DD
* ------------------------------------------------------------------
* 2      Original Disto version by Brian Lantz          BL
* 3      Removed copyright info, removed useless        BGP 98/10/20
*        register saves, optimized, changed port
*        address in descriptor to hold port address
*        of RAM pak instead of MPI.

                    nam       RamPak
                    ttl       Disto RAM Pak device driver

* Disassembled 98/04/20 09:57:05 by Disasm v1.5 (C) 1988 by RML

                    ifp1
                    use       defsfile
;         use   rbfdefs
                    endc

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       3

                    mod       eom,name,tylg,atrv,start,size

* RBF Data Area
                    rmb       129

* Free for driver use
ORGSlot             rmb       1

size                equ       .

                    fcb       DIR.+SHARE.+PEXEC.+PREAD.+PWRIT.+EXEC.+UPDAT.

name                fcs       /RamPak/
                    fcb       edition
*         fcc   /(C) 1985 BRIAN A. LANTZ/
*         fcb   $0D
*         fcc   /LICENSED TO DISTO/

start               lbra      Init
                    lbra      Read
                    lbra      Write
                    lbra      GetStat
                    lbra      SetStat
                    lbra      Term

* Init
*
* Entry:
*    Y  = address of device descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Init                ldd       #($FF*256)+3
                    stb       V.NDRV,u
                    leax      DRVBEG,u
* For each B, compute total sectors...
Init010             sta       V.TRAK,x
                    pshs      b,a
                    lda       IT.CYL+1,y
                    ldb       IT.SCT+1,y
                    mul
                    std       DD.TOT+1,x
                    puls      b,a
                    leax      DRVMEM,x
                    decb
                    bne       Init010
                    rts

* Write
*
* Entry:
*    B  = MSB of the disk's LSN
*    X  = LSB of the disk's LSN
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Write               pshs      cc
                    bsr       SlctSlot
WritLoop            lda       ,x+
                    stb       ,y
                    sta       3,y
                    incb
                    bne       WritLoop
                    bra       RestSlot

* Read
*
* Entry:
*    B  = MSB of the disk's LSN
*    X  = LSB of the disk's LSN
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Read                cmpx      #$0000
                    beq       ReadLSN0

ReadSect            pshs      cc
                    bsr       SlctSlot
ReadLoop            stb       ,y
                    lda       3,y
                    sta       ,x+
                    incb
                    bne       ReadLoop

* Restore the original MPI slot value we saved off
RestSlot            lda       >ORGSlot,u
                    sta       >MPI.Slct
                    puls      cc
                    clrb
                    rts

* Read LSN0 into our path descriptor
ReadLSN0            pshs      y
                    bsr       ReadSect
                    puls      y
                    ldx       PD.BUF,y
                    lda       <PD.DRV,y
                    leay      DRVBEG,u
                    ldb       #DRVMEM
                    mul
                    leay      d,y
                    ldb       #DD.SIZ-1
LSN0Loop            lda       b,x
                    sta       b,y
                    decb
                    bne       LSN0Loop
                    rts


* This routine selects the MPI slot
* Exit:  X = address of path descriptor buffer
SlctSlot            orcc      #IntMasks           mask interrupts
                    lda       >MPI.Slct           get current selected slot
                    sta       >ORGSlot,u          save off
                    lda       PD.DRV,y            get drive no.
                    ldb       #$11
                    mul                           multiply drive no. times $11
                    stb       >MPI.Slct           set new MPI slot no.
                    tfr       x,d
                    ldx       PD.BUF,y            load X with address of path buffer
                    ldy       V.PORT,u            get HW addr
                    sta       2,y                 write LSN hi byte to PAK
                    stb       1,y                 write LSN lo byte to PAK
                    clrb
                    rts

* GetStat
*
* Entry:
*    A  = function code
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
GetStat             comb
                    ldb       #E$UnkSvc
                    rts

SetStat
* Term
*
* Entry:
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Term                clrb
                    rts

                    emod
eom                 equ       *
                    end
