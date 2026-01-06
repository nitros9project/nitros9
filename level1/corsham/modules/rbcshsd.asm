********************************************************************
* rbcshsd - Corsham SD driver
*
* This driver works with the Corsham SS=50 SD/RTC Shield
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2017/05/08  Boisy G. Pitre
* Started.

                    nam       rbcshsd
                    ttl       DriveWire RBF driver

NUMRETRIES          equ       8

                    ifp1
                    use       defsfile
                    endc

NumDrvs             set       4

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

                    rmb       DRVBEG+(DRVMEM*NumDrvs)
dcmd                rmb       1
dno                 rmb       1
dssz                rmb       1
dscthi              rmb       2
dsctlo              rmb       2
resp                rmb       1
size                equ       .

                    fcb       DIR.+SHARE.+PEXEC.+PREAD.+PWRIT.+EXEC.+UPDAT.

name                fcs       /rbcshsd/
                    fcb       edition

start               bra       Init
                    nop
                    lbra      Read
                    lbra      Write
                    lbra      GetStat
                    lbra      SetStat

* Term
*
* Entry:
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Term
                    clrb
                    rts

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
Init
                    ifgt      Level-1
* Perform this so we can successfully do F$Link below
                    ldx       <D.Proc
                    pshs      a,x
                    ldx       <D.SysPrc
                    stx       <D.Proc
                    else
                    pshs      a
                    endc

                    ldb       #NumDrvs
                    stb       V.NDRV,u
                    leax      DRVBEG,u
                    lda       #$FF
Init2               sta       DD.TOT,x            invalidate drive tables
                    sta       DD.TOT+1,x
                    sta       DD.TOT+2,x
                    leax      DRVMEM,x
                    decb
                    bne       Init2

* Check if subroutine module has already been linked
                    ifgt      LEVEL-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
                    bne       InitEx
* Link to subroutine module
                    clra
                    leax      iosub,pcr
                    os9       F$Link
                    bcs       InitEx
                    tfr       y,u
                    ifgt      LEVEL-1
                    stu       <D.DWSubAddr
                    else
                    stu       >D.DWSubAddr
                    endc
* Initialize the low level device
                    jsr       ,u
                    clrb

InitEx
                    ifgt      Level-1
                    puls      a,x
                    stx       <D.Proc
InitEx2
                    rts
                    else
InitEx2
                    puls      a,pc
                    endc

* Read
*
* Entry:
*    B  = MSB of LSN
*    X  = LSB of LSN
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Read
                    cmpx      #$0000              LSN 0?
                    bne       ReadSect            branch if not
                    tstb                          LSN 0?
                    bne       ReadSect            branch if not
* At this point we are reading LSN0
                    bsr       ReadSect            read the sector
                    bcs       CpyLSNEx            if error, exit
                    leax      DRVBEG,u            point to start of drive table
                    ldb       <PD.DRV,y           get drive number
NextDrv             beq       CopyLSN0            branch if terminal count
                    leax      <DRVMEM,x           else move to next drive table entry
                    decb                          decrement counter
                    bra       NextDrv             and continue
CopyLSN0            ldb       #DD.SIZ             get size to copy
                    ldy       PD.BUF,y            point to buffer
CpyLSNLp            lda       ,y+                 get byte from buffer
                    sta       ,x+                 and save in drive table
                    decb
                    bne       CpyLSNLp
CpyLSNEx            rts


ReadSect
                    lda       PD.DRV,y            get drive number
                    cmpa      #NumDrvs
                    blo       ReadOk
                    coma
                    ldb       #E$Unit
                    rts

ReadOk              andcc     #^Carry
                    pshs      cc,y,u
                    sta       dno,u
                    lda       #2
                    sta       dssz,u
                    clra
                    std       dscthi,u
                    stx       dsctlo,u
                    lda       #PC_READ_LONG       load A with READ opcode
                    sta       dcmd,u
                    ldy       #7
                    leax      dcmd,u

                    ifgt      LEVEL-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
                    orcc      #IntMasks
                    jsr       6,u
                    ldy       #1
                    jsr       3,u
                    lda       ,x
                    cmpa      #PR_SECTOR_DATA
                    bne       ReadEr1

* Get 256 bytes of sector data
                    ldx       1,s                 get path descriptor ptr
                    ldx       PD.BUF,x            get buffer pointer into X
                    ldy       #$0100
                    ifgt      LEVEL-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
                    jsr       3,u
                    bcc       ReadEx

ReadEr1             puls      cc,y,u
                    orcc      #Carry
                    ldb       #E$Read
                    rts
ReadEx              puls      cc,y,u,pc



* Write
*
* Entry:
*    B  = MSB of LSN
*    X  = LSB of LSN
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Write               lda       PD.DRV,y
                    cmpa      #NumDrvs
                    blo       WriteSect
                    comb                          set Carry
                    ldb       #E$Unit
                    rts

WriteSect           andcc     #^Carry
                    pshs      cc,y,u
                    sta       dno,u
                    lda       #2
                    sta       dssz,u
                    clra
                    std       dscthi,u
                    stx       dsctlo,u
                    lda       #PC_WRITE_LONG      load A with WRITE opcode
                    sta       dcmd,u
                    ldy       #7
                    leax      dcmd,u

                    ifgt      LEVEL-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
                    orcc      #IntMasks
                    jsr       6,u
* Write 256 bytes of sector data
                    ldx       1,s                 get path descriptor ptr
                    ldx       PD.BUF,x            get buffer pointer into X
                    ldy       #$0100
                    jsr       6,u

                    ldx       1,s                 get path descriptor ptr
                    leax      resp,x
                    ldy       #1
                    jsr       3,u
                    lda       ,x
                    cmpa      #RACK
                    beq       WriteEx

* read error byte but ignore
                    ldy       #1
                    jsr       3,u

WriteEr1            puls      cc,y,u
                    orcc      #Carry
                    ldb       #E$Write
                    rts
WriteEx
                    puls      cc,y,u,pc

* SetStat
*
* Entry:
*    R$B = function code
*    Y   = address of path descriptor
*    U   = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
SetStat
* Size optimization


* GetStat
*
* Entry:
*    R$B = function code
*    Y   = address of path descriptor
*    U   = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
GetStat
                    rts

iosub               fcs       /pio/

                    emod
eom                 equ       *
                    end
