********************************************************************
* llscsi - Low-level SCSI driver
*
* $Id$
*
* Drives tested with this driver:
* -------------------------------
* Conner DCP30200 Hard Drive - Sends out a SDTR message immediately,
*   which confused the driver.  The driver now handles the receipt
*   of SCSI messages from the target.
*
* IBM DPES-31080 Hard Drive - Works, but seizes the bus if a
*   device ID is referenced on the bus that doesn't exist.
*
* Sony CDU415 2X CD-ROM - Works fine.
*
* Toshiba XM-4101BME 12X CD-ROM - Works fine.
*
* NOTE: A full dsave from the Sony to the IBM was done on 300+ MB
* of data (RTSI RBF CD-ROM) on June 7, 2004 with no problems.
*
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2004/04/??  Boisy G. Pitre
* Created.
*
*          2004/??/??  Boisy G. Pitre
* RELEASED WITH SUPERDRIVERS 1.0
*
*          2005/12/02  Boisy G. Pitre
* Now detects MESSAGE IN phase and reads in message codes (ignoring
* the data).  The Conner DCP30200 Hard Drive sends out a SDTR message
* immediately, which confused the driver.  The driver now handles the
* receipt of messages from the target.
*
*          2005/12/11  Boisy G. Pitre
* Added SS.SQD and SS.DCmd support.
*
*          2005/12/13  Boisy G. Pitre
* Moved SS.VarSect code into RBSuper for performance.
*
*          2006/03/22  Boisy G. Pitre
* Moved SS.VarSect code into RBSuper for performance.
*
*          2008/01/21  Boisy G. Pitre
* Fixed issue in DCmd where Y was not being saved when os9 F$ID was being called.

                    nam       llscsi
                    ttl       Low-level SCSI driver

                    ifp1
                    use       defsfile
                    use       rbsuper.d
                    use       scsi.d
                    endc

tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       0


*
* SCSI Delay Constants
*
                    ifgt      Level-1
BUSYDELAY           equ       $FFFF
                    else
BUSYDELAY           equ       $FFFF/2
                    endc
NUMTRIES            equ       8

                    mod       eom,name,tylg,atrv,start,0

                    org       V.LLMem
* Low-level driver static memory area
* SCSI Command Packet
* SCSI packet length is 14 bytes
V.SCSICMD           rmb       1
V.SCSILUN           rmb       1
V.SCSIPrm0          rmb       1
V.SCSIPrm1          rmb       1
V.SCSIPrm2          rmb       1
V.SCSIPrm3          rmb       1
V.SCSIPrm4          rmb       1
V.SCSIPrm5          rmb       1
V.SCSIPrm6          rmb       1
V.SCSIPrm7          rmb       1
                    rmb       4
SCSIPkLn            equ       .-V.SCSICMD
V.Retries           rmb       1                   SCSI command retry counter
V.OS9Err            rmb       1                   (0 = return OS-9 error code, 1 = return SCSI error code)
V.Turbo             rmb       1                   turbo flag (0 = regular read, 1 = turbo read)
V.TfrBuf            rmb       2                   transfer buffer pointer
V.RetryVct          rmb       2                   retry vector
V.ReadVct           rmb       2                   normal/turbo read vectoor
V.WriteVct          rmb       2                   normal/turbo write vector
V.DnsByte           rmb       1                   copy of PD.DNS from last accessed drive
                    ifne      D4N1+HDII
V.MPISlot           rmb       1                   MPI slot
V.MPISave           rmb       1                   contents of original MPI slot
                    endc
* The Request Sense Packet and Read Capacity return data share the same space
ReqSnPkt            equ       .
V.TxBuf             equ       .                   used by DSize
V.R$Err             rmb       2                   SCSI error code return value
V.UTxBuf            equ       .
V.R$Err2            rmb       10
V.R$AdSns           rmb       1
ReqPkL              equ       .-ReqSnPkt          length of packet
                    rmb       3                   makes V.TxBuf 16 bytes

name                fcc       /ll/
                    ifne      TC3
                    fcs       /tc3/
                    else
                    ifne      KTLR
                    fcs       /ktlr/
                    else
                    ifne      D4N1+HDII
                    fcs       /disto/
                    endc
                    endc
                    endc

start               bra       ll_init
                    nop
                    lbra      ll_read
                    lbra      ll_write
                    bra       ll_getstat
                    nop
                    lbra      ll_setstat
*         lbra  ll_term

* ll_term
*
* Entry:
*    Y  = address of device descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
ll_term
                    clrb
                    rts

* ll_init
*
* Entry:
*    Y  = address of device descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
ll_init
                    ifne      D4N1+HDII
* Disto 4-N-1 and HD-II: Get MPI slot select value from descriptor
* and save it in our static storage.
                    lda       IT.MPI,y
                    anda      #$0F                preserve *SCS bits only
                    sta       V.MPISlot,u
                    endc
                    clrb
                    rts


* ll_getstat
*
* Entry:
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
ll_getstat
                    ldx       PD.RGS,y
                    lda       R$B,x
                    cmpa      #SS.DSize
                    beq       SSDSize
                    ldb       #E$UnkSvc
                    coma
                    rts


* SS.DSize - Return size information about a device
*
* Entry: B = SS.DSize
* Exit:  Carry = 1; error with code in B
*        Carry = 0:
*          IF B = 0
*            A = Sector Size (1 = 256, 2 = 512, 4 = 1024, 8 = 2048)
*            X = Number of Sectors (bits 31-16)
*            Y = Number of Sectors (Bits 15-0)
*          IF B != 0
*            A = Sector Size (1 = 256, 2 = 512, 4 = 1024, 8 = 2048)
*            X = Number of Logical Cylinders
*            B = Number of Logical Sides
*            Y = Number of Logical Sectors/Track
*
SSDSize
                    pshs      u,y
                    bsr       DSize
                    bcs       ex@
                    ldu       ,s                  get path desc in U
                    ldu       PD.RGS,u
                    std       R$D,u
                    stx       R$X,u
                    sty       R$Y,u
                    clrb
ex@                 puls      y,u,pc

* DSize - Get SCSI disk size
*
* Exit:  Carry = 1; error with code in B
*        Carry = 0:
*          IF B = 0
*            A = Sector Size (1 = 256, 2 = 512, 4 = 1024, 8 = 2048)
*            X = Number of Sectors (bits 31-16)
*            Y = Number of Sectors (Bits 15-0)
*          IF B != 0
*            A = Sector Size (1 = 256, 2 = 512, 4 = 1024, 8 = 2048)
*            X = Number of Logical Cylinders
*            B = Number of Logical Sides
*            Y = Number of Logical Sectors/Track
DSize               lbsr      SCSIPrep            do SCSI prep stuff
                    lda       #S$RCAP
                    sta       V.SCSICMD,u
                    leax      V.TxBuf,u
                    stx       V.TfrBuf,u
                    ifne      D4N1+HDII
                    lbsr      MPIIn
                    endc
                    lbsr      SCSIXfer
                    bcs       ex@
                    ldd       V.TxBuf+2,u         get bits 15-0 of block count
                    addd      #$0001              add 1 to count
                    std       V.TxBuf+2,u         resave
                    bcc       b@
                    ldd       V.TxBuf,u           get bits 31-16
                    addd      #$0001              add 1
                    std       V.TxBuf,u           resave
b@                  lda       V.TxBuf+6,u
                    clrb
                    ldx       V.TxBuf,u
                    ldy       V.TxBuf+2,u
ex@
                    ifne      D4N1+HDII
                    lbra      MPIOut
                    else
                    rts
                    endc


* ll_setstat
*
* Entry:
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
ll_setstat
                    ldx       PD.RGS,y
                    lda       R$B,x
                    cmpa      #SS.SQD
                    beq       StopUnit
                    cmpa      #SS.DCmd
                    bne       n@
                    pshs      x                   save pointer to caller registers
                    bsr       DCmd                call DCmd
                    puls      x                   get pointer to caller registers
                    sta       R$A,x               save status byte in A
n@                  clrb
ex                  rts

* Entry:
*    R$B = SS.SQD
StopUnit
                    lbsr      SCSIPrep            do SCSI prep stuff
                    lda       #S$UNIT
                    sta       V.SCSICMD,u
                    clr       V.SCSIPrm2,u        we want to STOP unit
s@
                    ifne      D4N1+HDII
                    lbsr      MPIIn
                    endc
                    lbra      SCSIXfer

noperms             comb
                    ldb       #E$FNA
                    rts

* Entry:
*    X   = caller regs
*    Y   = path descriptor
*
*    R$B = SS.DCmd
*    R$X = Transfer buffer
*    R$Y = SCSI command packet
DCmd
* Fixed bug where Y was not being saved when doing os9 F$ID
                    pshs      y
                    os9       F$ID                get the user ID of the calling process
                    cmpy      #$0000              is it 0 (superuser)?
                    puls      y
                    bne       noperms             no, don't allow the call
                    lbsr      SCSIPrep
                    ldy       R$X,x               get caller's transfer buffer
                    sty       V.UTxBuf,u          save off in mem for later
                    ldx       R$Y,x               get ptr to caller's SCSI command buffer
                    ifgt      Level-1
                    ldy       D.Proc              get current process ptr
                    lda       P$Task,y            get task # for current process
                    ldb       D.SysTsk            get system task #
                    ldy       #SCSIPkLn           max size of SCSI command
                    pshs      u                   save on stack
                    leau      V.SCSICMD,u         point to SCSI command buffer in our statics
                    os9       F$Move              copy from caller to temporary task
                    puls      u
                    bcs       ex                  error copying, exit
                    else
                    ldb       #SCSIPkLn
                    leay      V.SCSICMD,u
cl@                 lda       ,x+
                    sta       ,y+
                    decb
                    bne       cl@
                    endc
                    ldy       V.PORT-UOFFSET,u    get hw address (because we overwrite Y earlier)
                    ifne      D4N1+HDII
                    lbsr      MPIIn
                    endc
                    inc       V.OS9Err,u          we want real SCSI errors returned
                    inc       V.CchDirty,u        and make cache dirty
                    leax      retry@,pcr
                    stx       V.RetryVct,u
retry@              lbsr      SCSISend
                    ifne      D4N1+HDII
                    lbcs      MPIOut
                    else
                    bcs       ex
                    endc
                    ifgt      Level-1
                    ldx       D.Proc              get current process ptr
                    ldb       P$Task,x            get task # for current process
                    endc
                    ldx       V.UTxBuf,u

msgloop@            lbsr      Wait4REQ            wait for REQ to be asserted
                    bita      #CMD                command phase?
                    lbne      PostXfr             yes, return
io@                 bita      #INOUT              data coming in or going out?
                    bne       in@                 branch if coming in...
                    ifgt      Level-1
                    os9       F$LDABX
                    leax      1,x
                    else
                    lda       ,x+
                    endc
                    sta       SCSIDATA,y
                    bra       msgloop@
in@                 lda       SCSIDATA,y
                    ifgt      Level-1
                    os9       F$STABX
                    leax      1,x
                    else
                    sta       ,x+
                    endc
                    bra       msgloop@


* ll_read
*
* Entry:
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Static memory referenced:
*    V.CchPSpot     = address of spot in cache where physical sector data will go
*    sectsize       = sector size (0=256,1=512,2=1024,3=2048)
*    V.SectCnt      = sectors to read
*    V.PhysSect = physical sector to start read from
ll_read
                    ifne      D4N1+HDII
                    lbsr      MPIIn
                    endc
                    ifne      SIZEMATTERS
                    bsr       SCSIPrep            do SCSI prep stuff
                    bsr       MakeRead            make read command packet
                    ldx       V.CchPSpot,u
                    stx       V.TfrBuf,u
                    lbra      SCSIXfer
                    else
                    leax      SCSIReadRetry,pcr
                    stx       V.RetryVct,u
                    lbsr      SCSIPrep            do SCSI prep stuff
                    lbsr      MakeRead            make read command packet
SCSIReadRetry
                    lbsr      SCSISend
                    bcs       mpiex
                    bita      #CMD
                    lbne      PostXfr
                    ldb       V.SectCnt,u
                    pshs      b
* Set up appropriate read call (regular or turbo)
                    tst       V.Turbo,u
                    beq       reg@
                    leax      TurboRead,pcr
                    bra       do@
reg@                leax      RegRead256,pcr
do@                 stx       V.ReadVct,u
                    ldx       V.CchPSpot,u        get pointer to physical sector in cache for data in
again@
                    ldb       V.Log2Phys,u
                    pshs      b
loop@
                    jsr       [V.ReadVct,u]
                    dec       ,s
                    bne       loop@
                    puls      b
                    dec       ,s
                    bne       again@
                    puls      a
                    lbra      PostXfr
mpiex
                    ifne      D4N1+HDII
                    lbra      MPIOut
                    else
                    rts
                    endc

TurboRead
                    ifne      H6309

* 6309 Turbo READ
                    ldw       #256
                    orcc      #IntMasks           we have to mask interrupts for Level 1
                    tfm       y,x+                do the transfer
                    andcc     #^IntMasks          we have to unmask interrupts for Level 1
                    lbsr      DeauxDeaux
                    rts

                    else

* 6809 Turbo READ
                    lda       #16
                    pshs      a
l2@                 lda       SCSIDATA,y
                    ldb       SCSIDATA,y
                    std       ,x
                    lda       SCSIDATA,y
                    ldb       SCSIDATA,y
                    std       $02,x
                    lda       SCSIDATA,y
                    ldb       SCSIDATA,y
                    std       $04,x
                    lda       SCSIDATA,y
                    ldb       SCSIDATA,y
                    std       $06,x
                    lda       SCSIDATA,y
                    ldb       SCSIDATA,y
                    std       $08,x
                    lda       SCSIDATA,y
                    ldb       SCSIDATA,y
                    std       $0A,x
                    lda       SCSIDATA,y
                    ldb       SCSIDATA,y
                    std       $0C,x
                    lda       SCSIDATA,y
                    ldb       SCSIDATA,y
                    std       $0E,x
                    leax      16,x
                    dec       ,s                  decrement counter
                    bne       l2@
                    puls      a,pc
                    endc

RegRead256
                    clrb
*
* "Non-Turbo" Read Data from controller
*
* Passed:  B = bytes to read
*          X = Address of buffer
*          Y = Controller Address
*
RegRead
* We wait for REQ in an infinite, faster loop here
                    lda       SCSISTAT,y          get SCSI status byte
                    bita      #REQ                REQ?
                    beq       RegRead
                    lda       SCSIDATA,y
                    sta       ,x+
                    decb
                    bne       RegRead
                    rts


                    endc


* Make Read/Write Packet
* Entry:
*    A = SCSI command
*    V.PhysSect = 3 byte physical sector to read/write
MakeWrite           lda       #S$WRITEX
                    fcb       $8C                 skip next two bytes
MakeRead            lda       #S$READEX
MakeRW              sta       V.SCSICMD,u         put passed SCSI command
                    lda       V.SectCnt,u         'V.SectCnt' logical blocks
* Make SCSI Read/Write 6 byte CDB here
*               sta       V.SCSIPrm2,u
*               lda       V.PhysSect,u
*               sta       V.SCSILUN,u
*               ldd       V.PhysSect+1,u
*               std       V.SCSIPrm0,u
*               rts
* Make SCSI Read/Write Extended 10 byte CDB here
                    sta       V.SCSIPrm6,u
                    lda       V.PhysSect,u
                    sta       V.SCSIPrm1,u
                    ldd       V.PhysSect+1,u
                    std       V.SCSIPrm2,u
                    rts

* Prep for SCSI transfer
* Preserves all regs
* Entry: Y = path descriptor
* Exit:  Y = hardware address
SCSIPrep            pshs      x,d
                    leax      V.SCSICMD,u
                    ldb       #SCSIPkLn
l@                  clr       ,x+
                    decb
                    bne       l@
                    ldb       PD.DNS,y            and DNS byte
                    stb       V.DnsByte,u         save in our statics
                    andb      #DNS.TURBO          mask out all but turbo bit
                    stb       V.Turbo,u           and save state
                    lda       #NUMTRIES           get retry count
                    sta       V.Retries,u         and reset retry counter
                    clr       V.OS9Err,u          we want real SCSI errors returned
                    ldy       V.PORT-UOFFSET,u    get hw address
                    puls      x,d,pc

* Check Transfer Status
* This routine is passed the address of another routine to call in case
* the device is busy or there is an error returned.
*
* Passed:  V.RetryVct,u = address of routine to call if SCSI device is busy
PostXfr             lbsr      GetStatB            get transfer status byte
                    bita      #X$BUSY             device BUSY?
                    bne       retry@              attempt a retry if so...
chkerr@             bita      #X$ERROR            error?
                    beq       ok@                 branch if not...
* Error occurred.. retry
retry@              dec       V.Retries,u         decrement retry count
                    bne       jmp@                try again if not at end
                    ifne      D4N1+HDII
                    lbsr      SCSIErr
                    lbra      MPIOut
                    else
                    lbra      SCSIErr
                    endc
jmp@                jmp       [V.RetryVct,u]
ok@                 clrb
                    ifne      D4N1+HDII
                    lbra      MPIOut
                    else
                    rts
                    endc


* ll_write
*
* Entry:
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Static memory referenced:
*    V.CchPSpot     = address of spot in cache where physical sector data is
*    sectsize       = sector size (0=256,1=512,2=1024,3=2048)
*    V.SectCnt      = sectors to read
*    V.PhysSect     = physical sector to start read from
ll_write
                    ifne      D4N1+HDII
                    lbsr      MPIIn
                    endc
                    ifne      SIZEMATTERS
                    bsr       SCSIPrep            do SCSI prep stuff
                    bsr       MakeWrite           make read command packet
                    ldx       V.CchPSpot,u
                    stx       V.TfrBuf,u
                    else
                    leax      SCSIWriteRetry,pcr
                    stx       V.RetryVct,u
                    bsr       SCSIPrep            do SCSI prep stuff
                    lbsr      MakeWrite
SCSIWriteRetry      lbsr      SCSISend
                    lbcs      mpiex
                    bita      #CMD
                    bne       PostXfr
                    ldb       V.SectCnt,u
                    pshs      b
* Set up appropriate write call (regular or turbo)
                    tst       V.Turbo,u
                    beq       reg@
                    leax      TurboWrite,pcr
                    bra       do@
reg@                leax      RegWrite,pcr
do@                 stx       V.WriteVct,u
                    ldx       V.CchPSpot,u
again@              ldb       V.Log2Phys,u
                    pshs      b
loop@               jsr       [V.WriteVct,u]
                    dec       ,s
                    bne       loop@
                    puls      b
                    dec       ,s
                    bne       again@
                    puls      a
                    bra       PostXfr

TurboWrite
                    ifne      H6309

* 6309 Turbo WRITE
loop@               orcc      #IntMasks           we have to mask interrupts for Level 1
                    ldw       #256
                    tfm       x+,y
                    andcc     #^IntMasks          we have to unmask interrupts for Level 1
                    lbsr      DeauxDeaux
                    rts

                    else

* 6809 Turbo WRITE
                    lda       #16
                    pshs      a
l2@                 ldd       ,x
                    sta       SCSIDATA,y
                    stb       SCSIDATA,y
                    ldd       $02,x
                    sta       SCSIDATA,y
                    stb       SCSIDATA,y
                    ldd       $04,x
                    sta       SCSIDATA,y
                    stb       SCSIDATA,y
                    ldd       $06,x
                    sta       SCSIDATA,y
                    stb       SCSIDATA,y
                    ldd       $08,x
                    sta       SCSIDATA,y
                    stb       SCSIDATA,y
                    ldd       $0A,x
                    sta       SCSIDATA,y
                    stb       SCSIDATA,y
                    ldd       $0C,x
                    sta       SCSIDATA,y
                    stb       SCSIDATA,y
                    ldd       $0E,x
                    sta       SCSIDATA,y
                    stb       SCSIDATA,y
                    leax      16,x
                    dec       ,s                  decrement counter
                    bne       l2@
                    puls      a,pc

                    endc

*
* "Non-Turbo" Write Data to controller
*
* Passed:  X = Address of data to write
*          Y = Controller Address
*
RegWrite            clrb
loop@               lda       SCSISTAT,y
                    bita      #REQ
                    beq       loop@
                    lda       ,x+
                    sta       SCSIDATA,y
                    decb
                    bne       loop@
                    rts

                    endc

                    ifne      D4N1+HDII
* Disto 4-N-1/HD-II: Map in MPI HERE
MPIIn               pshs      cc,a
                    lda       MPI.Slct            get MPI value
                    sta       V.MPISave,u         save off in our statics
                    anda      #$F0                preserve CTS slot bits (%1111000)
                    ora       V.MPISlot,u         OR in MPI slot of our HW
MPIWrite            sta       MPI.Slct            write out to MPI
                    puls      a,cc,pc

MPIOut              pshs      cc,a
                    lda       V.MPISave,u
                    bra       MPIWrite
                    endc


* SCSIXfer
*
* Entry:
*    Y  = hardware address
*    U  = address of device memory area
*
* Static memory referenced:
*    V.TfrBuf,u      = address of transfer/receive buffer
SCSIXfer            leax      retry@,pcr
                    stx       V.RetryVct,u
retry@              bsr       SCSISend
                    bcs       sr@
                    ldx       V.TfrBuf,u
tfr@                lbsr      Wait4REQ            wait for REQ to be asserted
                    bita      #CMD
                    lbne      PostXfr             COMMAND phase...
* If here, we're in DATA PHASE
                    bita      #INOUT              data coming in or going out?
                    bne       in@                 branch if coming in...
out@                lda       ,x+
                    sta       SCSIDATA,y
                    bra       tfr@
in@                 lda       SCSIDATA,y
                    sta       ,x+
                    bra       tfr@
sr@                 rts


* Give up timeslice several times unless this is the system
DeauxDeaux          pshs      x
                    ifgt      Level-1
                    ldx       D.Proc              get proc descriptor
                    cmpx      D.SysPrc            system?
                    beq       WaitDone            yep, system cannot sleep
                    endc
*               ldx       D.AProcQ            get active proc queue
*               beq       WaitDone            if empty, return
*               ldx       #$0001
*               os9       F$Sleep             give up timeslice
*               ldx       D.AProcQ            get active proc queue
*               beq       WaitDone            if empty, return
                    ldx       #$0001
                    os9       F$Sleep             give up timeslice
WaitDone            puls      x,pc                return to caller

* Get Status Byte from SCSI controller
* Exit: A = status byte
GetStatB            bsr       Wait4REQ
                    lda       SCSIDATA,y
                    pshs      a
                    bsr       Wait4REQ
                    clr       SCSIDATA,y
                    puls      pc,a

* SCSI ID table with hi-bit set for SCSI-3 compliance
IDTBL               fcb       $80+1,$80+2,$80+4,$80+8,$80+16,$80+32,$80+64,128

*
* SCSI Packet Send Routine
*
* Sets LUN for SCSI Packet, then sends command packet to controller
*
* Passed:  Y = Device Address
*
* Returns: A = SCSI Status byte
*
* Destroys: X
*
SCSISend            ldb       V.SCSILUN,u         get SCSI LUN
                    andb      #%00011111          mask out LUN
                    stb       V.SCSILUN,u
                    ldb       V.DnsByte,u         get DNS byte
                    andb      #%11100000          get SCSI LUN from byte
                    orb       V.SCSILUN,u         OR with SCSI LUN byte
                    stb       V.SCSILUN,u         save off
                    ldd       #BUSY*256           we want /BUSY
                    bsr       StatusWait
                    bcs       ex4
* BUSY is clear, put initiator/target IDs on bus
                    lda       V.DnsByte,u         get DNS byte
                    anda      #$07                mask out all but SCSI IDs
                    leax      IDTBL,pcr           point to device ID table
                    lda       a,x                 get ID value
                    sta       SCSIDATA,y          write out to controller
                    sta       SCSISEL,y           here too...
                    ldd       #BUSY*256+BUSY      we want BUSY
                    bsr       StatusWait
                    bcs       ex4
* BUSY is set
* Here we send the packet to the controller.
chkok@              leax      V.SCSICMD,u         point X to SCSI command packet
tfrloop@            bsr       Wait4REQ            wait for REQ
                    bita      #CMD                SCSI CMD bit set?
                    beq       ex4                 branch if not...
                    bita      #INOUT              INOUT set?
                    bne       ckmsg@              branch if target->initiator
                    lda       ,x+                 get byte from SCSI CMD packet
                    sta       SCSIDATA,y          write to controller
                    bra       tfrloop@
ckmsg@              bita      #MSG                MESSAGE IN (target->initiator)
                    beq       ex4
*
* MESSAGE IN phase code
*
MSGIn               lda       SCSIDATA,y          extended message?
                    deca
                    bne       SCSISend            nope, restart target initiation
                    ldb       SCSIDATA,y          get extended message length
* Note: We ignore extended messages
l@                  tst       SCSIDATA,y          read extended message data
                    decb
                    bne       l@
                    bra       SCSISend            message read, restart target initiation
ex4                 rts

*
* Loop until REQ bit is set
*
* Passed:   Y = Device Address
*
* Returns:  A = SCSI Status byte
*
Wait4REQ
loop@               lda       SCSISTAT,y          get SCSI status byte
                    bita      #REQ                REQ?
                    beq       sleep@              +
                    rts                           +
sleep@              lbsr      DeauxDeaux
                    bra       loop@

* Wait for a set of conditions in the status register to be TRUE
* This yields a delay of about 5 seconds.
*
* Entry: Y = HW address
*        A = flip (if bit set, that bit is tested)
*        B = mask (result must match this byte)
StatusWait
                    pshs      x,d
                    ifeq      Level-1
                    ldb       #$02
                    ldx       #$0000
                    else
                    ldb       #$04
                    ldx       #$0000
                    endc
l@                  lda       SCSISTAT,y
                    anda      ,s                  apply flip
                    cmpa      1,s                 compare to mask
                    bne       dec@                branch if not equal (not what we want)
                    lda       SCSISTAT,y
                    clrb                          clear carry
                    bra       ok@
dec@                leax      -1,x                count down
                    bne       l@
                    decb                          decrement bits 23-16
                    bpl       l@                  if >=0, keep going
                    comb                          set carry
                    ldb       #E$NotRdy
ok@                 leas      2,s
                    puls      x,pc

*
* Send a REQSENSE message to the SCSI controller
*
SndMSG              lbsr      Wait4REQ            wait for REQ to be asserted
                    bita      #CMD                command phase?
                    bne       ex4                 yes, return
                    beq       INorOUT             no, check for in/out
                    rts
INorOUT             bita      #INOUT              data coming in or going out?
                    bne       ComingIn            branch if coming in...
                    lda       ,x+
                    sta       SCSIDATA,y
                    bra       SndMSG
ComingIn            lda       SCSIDATA,y
                    sta       ,x+
                    bra       SndMSG


* SCSIErr - Attemps a REQUEST SENSE to find a SCSI error
*
* Entry:
*    Y  = address of hardware
*    U  = address of device memory area
*
* Exit:
*    CC = carry set
*    B  = error code
*
SCSIErr             lda       #S$REQSEN           REQUEST SENSE command
                    sta       V.SCSICMD,u
                    clra
                    clrb
                    sta       V.SCSILUN,u
                    std       V.SCSIPrm0,u
                    lda       #ReqPkL             set allocation length
                    std       V.SCSIPrm2,u
                    lbsr      SCSISend            send command
                    bcs       ex4                 branch if error
                    leax      V.R$Err,u           point to return data buffer
                    bsr       SndMSG              get response data
                    lbsr      GetStatB
                    clra
                    pshs      a
                    lda       V.R$Err,u           get error code
                    anda      #$7F                wipe out hi bit
                    cmpa      #$70                "current" error?
                    bne       L05A3               branch if not...
                    lda       V.R$Err2,u          get more detailed error
                    anda      #%00001111
                    sta       ,s                  save off stack
                    lda       V.R$AdSns,u         get additional sense code
L05A3               tst       V.OS9Err,u          send OS-9 error?
L05A7               beq       L05AD               branch if so...
                    tfr       a,b                 else put SCSI error in B
                    clr       V.OS9Err,u          and clear SCSI error flag
                    bra       ErrErr              and return with error
* Walk error table to find OS-9 error
L05AD               leax      >ErrTbl,pcr
                    ldb       #E$Unit
L05B3               tst       ,x
                    beq       ErrErr
                    cmpa      ,x++
                    blt       L05B3
                    ldb       -1,x
ErrErr              coma
                    puls      pc,a



* Error Table - Maps SCSI errors to OS-9 errors
* This table is contructed so that gaps are actually continuations of
* the previous entry.  For example, $14 maps to E$Seek, and so does $15 and
* $16.
ErrTbl              fcb       $01,E$NotRdy
                    fcb       $02,E$Seek
                    fcb       $03,E$Write
                    fcb       $04,E$NotRdy
                    fcb       $06,E$Seek
                    fcb       $10,E$CRC
                    fcb       $11,E$Read
                    fcb       $14,E$Seek
                    fcb       $17,E$CRC
                    fcb       $19,E$IllArg
                    fcb       $1C,E$Read
                    fcb       $1E,E$CRC
                    fcb       $20,E$IllCmd
                    fcb       $21,E$Sect
                    fcb       $25,E$IllArg
                    fcb       $29,E$NotRdy
                    fcb       $00


                    emod
eom                 equ       *
                    end

