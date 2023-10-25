*******************************************************************
* llide - Low-level IDE driver
*
* $Id$
*
* This low level driver works with both ATA and ATAPI devices.
*
* The type of device (ATA or ATAPI) is automatically detected
* by the 'IOSetup' routine.  Additionally, an ATA device is
* further detected as either an LBA or CHS device.
*
* Since only two physical drives are allowed (master/slave),
* there is a two entry "per drive static storage" that indicates
* if a drive has been initialized, its type (ATAPI or ATA, LBA or
* CHS), and if ATA, its geometry.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*     1    2004/04/08  Boisy G. Pitre
* Created.
*
*     2    2005/07/23  Christopher R. Hawks
* Fixes for persnickity ATAPI CDROMs.
*
*     3    2005/08/21  Christopher R. Hawks
* More fixes.
*
*     4    2005/12/13  Boisy G. Pitre
* Moved SS.VarSect code into RBSuper for performance

                    nam       llide
                    ttl       Low-level IDE driver

                    ifp1
                    use       defsfile
                    use       rbsuper.d
                    use       ide.d
                    endc

tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       4


RW12                set       0                   Use READ12/WRITE12 ATAPI commands (1 = yes)
WAITTIME            set       10                  BUSY wait time (in approximate seconds)

*
* Status Register Flip/Mask Values
*
NBUSYDRDY           equ       (BusyBit|DrdyBit)*256+(DrdyBit)
NBUSY               equ       (BusyBit)*256+$00
NBUSYDRQ            equ       (BusyBit|DrqBit)*256+(DrqBit)
NBUSYNDRQ           equ       (BusyBit|DrqBit)*256+$00

                    mod       eom,name,tylg,atrv,start,0

                    ifne      RW12
READCODE            equ       A$READ2
WRITCODE            equ       A$WRITE2
                    else
READCODE            equ       A$READ
WRITCODE            equ       A$WRITE
                    endc

NumRetries          equ       8

* Low-level driver static memory area
                    org       V.LLMem
* Master static storage
V.Master            rmb       1                   status byte (ATAPI or ATA (CHS or LBA))
                    rmb       2                   Cylinders (CHS) or Bits 31-16 of LBA
                    rmb       1                   Sides (CHS) or Bits 15-8 of LBA
                    rmb       2                   Sectors (CHS) or Bits 7-0 of LBA
* Slave drive static storage
V.Slave             rmb       1
                    rmb       2
                    rmb       1
                    rmb       2
* ATAPI Command Packet
V.ATAPICmd          rmb       18
V.SnsData           equ       V.ATAPICmd          Sense Data is shared with ATAPI command block
* The following values are for device 0 and 1 respectively:
* Bit 0 = device inited (0 = false, 1 = true)
* Bit 1 = device type (0 = ATA, 1 = ATAPI)
* Bit 2 = device mode (0 = CHS, 1 = LBA)
V.CurStat           rmb       1
V.Retries           rmb       1
V.WhichDv           rmb       1                   contains devhead selection (made by IOSetup)
V.PhySct            rmb       3                   local copy of physical sector passed (V.PhySct)
V.SctCnt            rmb       1                   local copy of physical sector passed (V.SectCnt)
V.Sectors           rmb       1                   number of sectors (harvested directly from drive query)
V.CurDTbl           rmb       2
V.ATAVct            rmb       2


name                fcs       /llide/

start               bra       ll_init
                    nop
                    lbra      ll_read
                    lbra      ll_write
                    lbra      ll_getstat
                    lbra      ll_setstat

* ll_init - Low level init routine
*
* Entry:
*    Y  = address of device descriptor
*    U  = address of low level device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
* Note: This routine is called ONCE: for the first device
* IT IS NOT CALLED PER DEVICE!
*
ll_init
*         clrb
*         rts


* ll_term - Low level term routine
*
* Entry:
*    Y  = address of device descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
* Note: This routine is called ONCE: for the last device
* IT IS NOT CALLED PER DEVICE!
*
ll_term
                    clrb
                    rts


* Entry:   Y = address of per-drive static storage
ATADSize
                    pshs      y,x,b               make room for space on stack (and save id byte)
* Determine if we are dealing with LBA or CHS
                    bitb      #$04                LBA?
                    bne       lba@
* Here we pull CHS values
chs@
                    ldd       1,y                 get cylinders
                    std       1,s
                    lda       3,y                 get sides
                    sta       ,s                  save sides on stack (B)
                    ldd       4,y                 get sectors
                    std       3,s                 save sectors/track on stack (Y)
                    bra       m@
* Here we pull LBA values at words 60-61
lba@
                    clr       ,s                  clear flag indicating LBA mdoe (B)
                    ldd       3,y                 get bits 15-0
                    std       3,s                 save bits 15-0 on stack (Y)
                    ldd       1,y                 get bits 31-16
                    std       1,s                 save bits 31-16 (X)
m@                  lda       #$02                512 bytes/sector
ex@                 puls      b,x,y,pc


* SSDSize - Get a disk medium's size
*
* GetStat Call SS.DSize:
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
SSDSize             pshs      u,y
                    bsr       DSize
                    bcs       ex@
                    ldu       ,s                  get path desc in U
                    ldu       PD.RGS,u
                    std       R$D,u
                    stx       R$X,u
                    sty       R$Y,u
                    clrb
ex@                 puls      y,u,pc

DSize               lbsr      IOSetup
                    bcs       ex@
* Determine if this device is ATAPI or ATA
                    bitb      #$02                ATAPI?
                    lbeq      ATADSize            no, it's ATA
* Note - for ATAPI version of SS.DSize, we use the obsolete
* READ CAPACITY call because it works on CD-ROMs, as opposed to
* READ FORMAT CAPACITIES.
ATAPIDSize
                    lbsr      ATAPIPreSend        prepare packet
* Populate packet buffer with STOP code and Eject
*         ldd   #$230C		ATAPI READ FORMAT CAPACITIES Code
                    lda       #$25                ATAPI READ CAPACITY Code
                    sta       V.ATAPICmd,u        write it
*         stb   V.ATAPICmd+8,u	and allocation length
* Send to data port
                    bsr       ATAPISend           send command
                    bcs       ex@
* Read 8 bytes of format capacity data
*         ldb   #6
                    ldb       #4
                    pshs      b
                    leay      V.SnsData,u
read@               lda       DataReg,x
                    ldb       Latch,x
                    std       ,y++
                    dec       ,s
                    bne       read@
                    puls      b
                    ldx       V.SnsData+0,u
                    ldy       V.SnsData+2,u
                    leay      1,y
                    bcc       b@
                    leax      1,x
b@                  lda       V.SnsData+6,u
                    clrb
ex@                 rts

*         ldy   PD.RGS,y
*         ldd   V.SnsData+0,u	get bits 31-16
*         std   R$X,y
*         ldd   V.SnsData+2,u	get bits 15-0
*         addd  #$0001		add 1
*         std   R$Y,y
*         bcc   b@
*         ldd   R$X,y
*         addd  #$0001
*         std   R$X,y
*b@       lda   V.SnsData+6,u	get bits 15-8 of block size
*         sta   R$A,y
*         clr   R$B,y		signal that this is LBA mode
*         clrb
*ex@      rts


* ll_getstat - Low level GetStat routine
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
ex1                 rts


* StopUnit - Park a drive
*
* ATA   Devices: This is a No-Op.
* ATAPI Devices: A STOP UNIT command is issued to the device.
*                (ejects media on ATAPI removable devices)
StopUnit            lbsr      IOSetup
                    bcs       ex1
* Determine if this device is ATAPI or ATA
                    bitb      #$02                ATAPI?
                    beq       ex1                 no, ignore...
                    lbsr      ATAPIPreSend        prepare packet
* Populate packet buffer with STOP code and Eject
ok@                 ldd       #A$STOP*256+$02     ATAPI STOP Code and Eject byte
                    sta       V.ATAPICmd,u        write it and RSV to zero
                    stb       V.ATAPICmd+4,u
* Send to data port
                    bra       ATAPISend           send command


* ll_setstat - Low level SetStat routine
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
                    ifne      0
                    cmpa      #SS.DCmd
                    bne       n@
                    pshs      x                   save pointer to caller registers
                    bsr       DCmd                call DCmd
                    puls      x                   get pointer to caller registers
                    sta       R$A,x               save status byte in A
                    endc
n@                  clrb
ssex                rts


                    ifne      0
BadType             comb
                    ldb       #E$BTyp
                    rts

* Entry:
*    X   = caller regs
*    Y   = path descriptor
*
*    R$B = SS.DCmd
*    R$X = Transfer buffer
*    R$Y = ATAPI command packet
DCmd
                    pshs      y
                    os9       F$ID                get the user ID of the calling process
                    cmpy      #$0000              is it 0 (superuser)?
                    puls      y
                    bne       noperms             no, don't allow the call
                    lbsr      IOSetup
** SS.DCmd only works with ATAPI devices.
                    bitb      #$02                ATAPI?
                    beq       BadType             branch if not
                    ldy       R$X,x               get caller's transfer buffer
                    sty       V.UTxBuf,u          save off in mem for later
                    ldx       R$Y,x               get ptr to caller's command buffer
                    ifgt      Level-1
                    ldy       D.Proc              get current process ptr
                    lda       P$Task,y            get task # for current process
                    ldb       D.SysTsk            get system task #
                    ldy       #ATAPIPkLn          max size of ATAPI command
                    pshs      u                   save on stack
                    leau      V.ATAPICmd,u        point to ATAPI command buffer in our statics
                    os9       F$Move              copy from caller to temporary task
                    puls      u
                    bcs       ex                  error copying, exit
                    else
                    ldb       #ATAPIPkLn
                    leay      V.ATAPICmd,u
cl@                 lda       ,x+
                    sta       ,y+
                    decb
                    bne       cl@
                    endc
                    ldy       V.PORT-UOFFSET,u    get hw address (because we overwrite Y earlier)
*               inc       V.OS9Err,u          we want real errors returned
                    inc       V.CchDirty,u        and make cache dirty
*               leax      retry@,pcr
*               stx       V.RetryVct,u
retry@              lbsr      ATAPISend
                    bcs       ex
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
                    endc

* ATAPISend - Sends the command packet to the device
*
* Entry:   X = HW address
*          V.WhichDv = DevHead device selection value
* Exit:    Carry = 1; error code in B
*          Carry = 0; command successfully sent
ATAPISend
* First, select the device and wait for /BUSY
                    lda       V.WhichDv,u
                    sta       DevHead,x           select device
* ATAPI says we wait for !BUSY
                    ldd       #NBUSYDRDY          wait for NBUSY and DEVREADY too - CRH
                    lbsr      StatusWait          wait for proper condition
                    bcs       timeout             branch if error
                    lda       #NumRetries         get retry count
                    sta       V.Retries,u         and save
retry@
                    clr       Features,x          clear feature byte
                    clr       SectCnt,x           clear TAG field
                    ldd       #$FFFF              maximum read in PIO mode
                    std       CylLow,x
                    lda       #$A0                ATAPI PACKET CODE
                    sta       Command,x           write it to device
* Check for error
                    ldd       #NBUSYDRQ           /BUSY and DRQ
                    lbsr      StatusWait          wait for proper condition
                    bcs       ex@                 branch if error
* Send to data port
                    lda       #6                  packet size / 2
                    pshs      a,y
                    leay      V.ATAPICmd,u
l@                  ldd       ,y++
                    stb       Latch,x
                    sta       DataReg,x
                    dec       ,s
                    bne       l@
                    puls      a,y
* Added by CRH - Some drives require that we wait for much more than
* 400ns.  Hence this code forces a slow-down and checks the status
* to see if things are ok.
                    clrb
slow@               decb                          CRH wait for much more than 400ns
                    bne       slow@
                    lda       Status,x            CRH Sometimes error on first try
                    lsra
                    bcc       ok@
                    dec       V.Retries,u
                    bne       retry@
* As per ATA/ATAPI-6 spec (T13/1410D Revision 3A), page 161, we wait for /BUSY
* and DRQ after sending a command
* That IS NOT the case when sending START/STOP unit commands, so we don't check
* for DRQ.
ok@                 ldd       #NBUSY              /BUSY
                    lbsr      StatusWait          wait for proper condition
                    bcs       ex@                 branch if error
                    lda       #A$STOP             CRH see above
                    cmpa      V.ATAPICmd,u
                    beq       nodata@
                    ldd       #NBUSYDRQ           /BUSY and DRQ
                    lbsr      StatusWait          wait for proper condition
                    bcs       ex@                 branch if error
nodata@             lsra                          shift in CHECK CONDITION bit
                    bcc       ex@                 branch if ok
* Note: if the device returns error, DRQ won't be set...
err@                lbsr      HandleSenseKey      go check sense key
                    bcs       ex@
ret@                dec       V.Retries,u         else retry until terminal
                    bne       retry@              continue retrying
timeout             comb                          set carry
                    ldb       #E$DevBsy+4         SHOULD BE AN E$TimeOut ERROR!
ex@                 rts

* Prepare the ATAPI Packet
ATAPIPreSend
                    pshs      x
* Clear 12 byte packet.
                    leax      V.ATAPICmd,u
                    ldb       #12
c@                  clr       ,x+
                    decb
                    bne       c@
ex@                 puls      x,pc


** ATAPI REQUEST SENSE Command
** Should only be called for ATAPI devices
*ReqSense
*         bsr    ATAPIPreSend	prepare packet
** Populate packet buffer with REQUEST SENSE
*         ldd   #$0312		ATAPI REQUEST SENSE Code and allocation length byte
*         sta   V.ATAPICmd,u
*         stb   V.ATAPICmd+4,u
** Send to data port
*         lbsr  ATAPISend	send command
*         lda   Status,x		get status code
*         lsra			shift in CHECK CONDITION bit
*         bcs   ex@		branch if ok
** Read 18 bytes of sense data
*         ldb   #$12
*         pshs  y,b
*         leay  V.SnsData,u
*read@    lda   DataReg,x
*         ldb   Latch,x
*         std   ,y++
*         dec   ,s
*         bne   read@
*         puls  b,y,pc
*ex@      rts


* IOSetup - Sets up the device for I/O
*
* The device is selected (master or slave), then the device is
* checked for previous initialization.
*
* If the device has not been initialized, it is queried for its
* mode (ATAPI/ATA, LBA or CHS) and size.  That information is
* saved in the driver's static storage for later use by other
* routines.
*
* Entry:  Y = path descriptor pointer
*         U = static memory pointer
* Exit:   B = status byte for device
*         X = HW address
*         Y = pointer to current device table
IOSetup             ldx       V.PORT-UOFFSET,u    get hw address
                    lda       PD.DNS,y            get device ID bit
                    lsra                          shift device ID into carry
                    bcs       slave@
                    lda       #%10100000          master byte
                    leay      V.Master,u
                    bra       t@
slave@              lda       #%10110000          slave byte
                    leay      V.Slave,u           else point to slave status byte
t@                  sty       V.CurDTbl,u
                    sta       V.WhichDv,u         save for later
* Select the device -- on power-up, the status register is usually 0
                    sta       DevHead,x           select device
* According to page 320 of the ATA/ATAPI-6 document, we must wait for BOTH
* BUSY and DRQ to be clear before proceeding. (HI2: Device_Select State)
                    ldd       #NBUSYNDRQ          /BUSY and /DRQ
                    lbsr      StatusWait          wait for proper condition
                    lbcs      ex@                 branch if error
* Determine if this device has already been initialized
                    tst       ,y                  test device's stat byte
                    lbne      initdone            if not zero, init already done
* Here we must initialize the device by IDENTIFYING it.
* First, try sending the ATA IDENTIFY DRIVE code
                    lda       #$EC                ATA identify command
                    sta       Command,x           write it
                    ldd       #NBUSY              /BUSY
                    lbsr      StatusWait          wait for proper condition
                    lbcs      ex@                 branch if error
* Check if there's an error
                    lsra                          shift error bit into carry
                    bcc       ATAIdent            if no error, then probably ATA
* If here, we got an error sending $EC, so try ATAPI's $A1
                    lda       #$A1
                    sta       Command,x
                    clrb
slow@               decb                          CRH wait for much more than 400ns
                    bne       slow@
                    ldd       #NBUSY
                    lbsr      StatusWait          wait for proper condition
                    bcs       ex@                 branch if error
                    lsra                          shift error bit into carry
                    bcs       timeout             if not error, we're ok
                    ldd       #NBUSYDRQ
                    lbsr      StatusWait          wait for proper condition
                    lbcs      ex@                 branch if error
* Here, we have identified an ATAPI device.
ATAPIIdent
                    ldb       #$03                ATAPI
                    stb       ,y
* We flush the ATAPI data but don't reference it
dread@              ldb       DataReg,x           CRH flush ALL bytes
*         ldb   Latch,x 	but save time by not reading latch
                    lda       Status,x
                    anda      #8
                    bne       dread@
                    bra       initdone
* ATAIdent - process an ATA device
* This routine is called by IOSetup when it deduces that the device
* being queried is an ATA device.  This device is called ONCE -- the
* first time the device is accessed.
* This routine will set up our per-drive static storage to indicate that
* it is an ATA device.  It will also determine if it is an LBA or CHS mode
* device, and save the appropriate CHS or LBA sector values.
ATAIdent
                    ldd       #NBUSYDRDY          /BUSY and DRDY
                    lbsr      StatusWait          wait for proper condition
                    bcs       ex@                 branch if error
* Harvest C/H/S and LBA sector values.
                    ldb       DataReg,x           ignore bytes 0-1
                    ldb       DataReg,x           bytes 2-3 = no. of cylinders
                    lda       Latch,x
                    std       1,y                 save cylinders in our private static area
                    ldb       DataReg,x           ignore bytes 4-5
                    ldb       DataReg,x           bytes 6-7 = no. of heads
                    lda       Latch,x
                    stb       3,y                 save sides on stack (B)
                    ldb       DataReg,x           ignore bytes 8-9
                    ldb       DataReg,x           ignore bytes 10-11
                    ldb       DataReg,x           bytes 12-13 = no. of sectors/track
                    lda       Latch,x
                    std       4,y                 save sectors/track on stack (Y)
* Throw away the next 42 (7-48) words
                    ldb       #43
l@                  tst       DataReg,x
                    lda       Latch,x
                    decb
                    bne       l@
* A holds byte with LBA bit
                    incb                          B was 0, now 1
                    anda      #%00000010          LBA allowed on this drive?
                    beq       nope@
                    orb       #$04                set LBA mode
                    stb       ,y                  save updated status byte
* Since we're LBA mode, get the number of LBA sectors in words 60-61
                    ldb       #10                 skip to the LBA sectors (words 60-61)
more@               tst       DataReg,x           simply read the data register like this...
                    decb
                    bne       more@
                    ldb       DataReg,x           get word 60
                    lda       Latch,x
                    std       3,y
                    ldb       DataReg,x           and 61
                    lda       Latch,x
                    std       1,y
                    lda       #256-61             how many words we have left
                    bra       left@               go on.
nope@               stb       ,y                  save updated status byte
* Read remaining 256-50 words
                    lda       #256-50
left@               ldb       DataReg,x
                    deca
                    bne       left@
initdone            ldb       ,y                  get status byte of drive
                    clra                          clear carry
ex@                 rts


* ATAPI Write Routine -- Independent of ATA Read
ATAPIWrite
                    lbsr      ATAPIPreSend        prepare packet
* Populate packet buffer with WRITE code and sector information
again@              ldb       V.PhySct,u          get bits 23-16 of sector
                    stb       V.ATAPICmd+3,u
                    ldd       V.PhySct+1,u        get bits 15-0 of sector
                    std       V.ATAPICmd+4,u
                    ldd       #WRITCODE*256+$01   ATAPI WRITE Code and transfer length
                    sta       V.ATAPICmd,u        write it
                    ifne      RW12
                    stb       V.ATAPICmd+9,u      write to byte 9
                    else
                    stb       V.ATAPICmd+8,u      write to byte 8
                    endc
* Send to data port
                    lbsr      ATAPISend           send command
                    bcs       ex@
* Shift data from device
o@                  pshs      d
                    lda       V.Log2Phys,u
                    sta       1,s                 set up our logical sector counter
inc@                clr       ,s                  set up our byte counter
wr@                 ldd       ,y++
                    stb       Latch,x
                    sta       DataReg,x
                    inc       ,s
                    bpl       wr@
                    dec       1,s
                    bne       inc@
                    puls      d
* Increment physical sector
                    inc       V.PhySct+2,u
                    bcc       go@
                    inc       V.PhySct+1,u
                    bcc       go@
                    inc       V.PhySct,u
go@                 dec       V.SctCnt,u          decrement # of hw sectors to read
                    bne       again@              if not zero, do it again
                    ldd       #NBUSY              /BUSY
                    lbsr      StatusWait          wait for proper condition
                    bcs       ex@                 branch if error
                    lsra                          error bit set?
                    bcc       ex@                 yep...
                    bsr       HandleSenseKey
ex@                 puls      x,pc



* ATAPI Read Routine -- Independent of ATA Read
ATAPIRead
                    ldy       V.CchPSpot,u        get pointer to spot in cache to put sector
                    lbsr      ATAPIPreSend        do command packet setup stuff
* Populate packet buffer with READ code and sector information
again@              ldb       V.PhySct,u          get,u bits 23-16 of sector
                    stb       V.ATAPICmd+3,u
                    ldd       V.PhySct+1,u        get bits 15-0 of sector
                    std       V.ATAPICmd+4,u
                    ldd       #READCODE*256+$01   ATAPI Read Code and transfer length
                    sta       V.ATAPICmd,u        write it and RSV to zero
                    ifne      RW12
                    stb       V.ATAPICmd+9,u      write to byte 9
                    else
                    stb       V.ATAPICmd+8,u      write to byte 8
                    endc
* Send to data port
                    lbsr      ATAPISend           send command
                    bcs       ex@
* Shift data from device
o@                  pshs      d
                    lda       V.Log2Phys,u
                    sta       1,s                 set up our logical sector counter
inc@                clr       ,s                  set up our byte counter
read@               lda       DataReg,x
                    ldb       Latch,x
                    std       ,y++
                    inc       ,s
                    bpl       read@
                    dec       1,s
                    bne       inc@
                    puls      d
* Increment physical sector
                    inc       V.PhySct+2,u
                    bcc       go@
                    inc       V.PhySct+1,u
                    bcc       go@
                    inc       V.PhySct,u
go@                 dec       V.SctCnt,u          decrement # of hw sectors to read
                    bne       again@              if not zero, do it again
                    ldd       #NBUSY              /BUSY
                    lbsr      StatusWait          wait for proper condition
                    bcs       ex@                 branch if error
                    lsra                          error bit set?
                    bcc       ex@                 nope...
                    bsr       HandleSenseKey
ex@                 puls      x,pc


* Handle ATAPI Sense Key
* If the resulting error in the look-up table is zero,
* we return with carry clear
* Returns: B =  0 (carry clear, no error)
*          B != 1 (carry set, error)
HandleSenseKey
                    pshs      x,a
                    ldb       ErrorReg,x          get error register value
                    lsrb                          shift sense key into place
                    lsrb
                    lsrb
                    lsrb
                    leax      SenseMap,pcr        point to Sense Key Map
                    clra                          clear carry
                    ldb       b,x                 get appropriate error
                    beq       ok@                 if error is zero, return ok
                    coma                          set carry
ok@                 puls      a,x,pc

* ll_read - Low level read routine
*
* Entry:
*    Registers:
*      Y  = address of path descriptor
*      U  = address of device memory area
*    Static Variables of interest:
*      V.PhySct = starting physical sector to read from
*      V.SectCnt  = number of physical sectors to read
*      V.SectSize = physical sector size (0=256,1=512,2=1024,3=2048)
*      V.CchPSpot = address where physical sector(s) will go
*
* Exit:
*    All registers may be modified
*    Static variables may NOT be modified
ll_read
                    pshs      x                   make some space on the stack
                    lbsr      IOSetup             initialize the device
                    lbcs      ex@
* Copy V.PhySct and V.SectCnt to our local copy
* since we cannot modify them.
                    lda       V.PhysSect,u
                    ldy       V.PhysSect+1,u
                    sta       V.PhySct,u
                    sty       V.PhySct+1,u
                    lda       V.SectCnt,u
                    sta       V.SctCnt,u
                    bitb      #$02                ATAPI device?
                    lbne      ATAPIRead           yes, go do it
* ATA Read Routine
ATARead
* stb   V.CurStat,u	save status of current drive
                    bitb      #$04                LBA drive?
                    bne       lba@                branch if so
                    leay      DoCHS,pcr           else point Y to CHS routine
                    bra       skip@
lba@                leay      DoLBA,pcr
skip@               sty       V.ATAVct,u          save pointer
                    ldy       V.CchPSpot,u        get pointer to spot in cache to put sector
loop@
                    ldd       #NBUSY              /BUSY
                    bsr       StatusWait          wait for proper condition
                    bcs       ex@                 branch if error
                    jsr       [V.ATAVct,u]        do proper ATA preparation
                    bcs       ex@                 branch if error
cont@               lda       #$01
                    sta       SectCnt,x           store it
                    lda       #S$READ
                    sta       Command,x
                    ldd       #NBUSY              /BUSY
                    bsr       StatusWait          wait for proper condition
                    bcs       ex@                 branch if error
                    lsra                          error bit set?
                    bcc       w@                  branch if not
                    lbsr      ATAError
                    bra       ex@
w@                  ldd       #NBUSYDRQ           /BUSY and DRQ
                    bsr       StatusWait          wait for proper condition
                    bcs       ex@                 branch if error
                    lda       V.Log2Phys,u
                    sta       1,s                 set up our logical sector counter
inc@                clr       ,s                  set up our byte counter
read@               lda       DataReg,x
                    ldb       Latch,x
                    std       ,y++
                    inc       ,s
                    bpl       read@
                    dec       1,s
                    bne       inc@
* Increment physical sector
                    inc       V.PhySct+2,u
                    bcc       go@
                    inc       V.PhySct+1,u
                    bcc       go@
                    inc       V.PhySct,u
go@                 dec       V.SctCnt,u          decrement # of hw sectors to read
                    bne       loop@               if not zero, do it again
                    clrb
ex@                 puls      x,pc


*
* Convert LSN to LBA values
*
* Entry:  V.PhySct = bits 23-0 of LSN
*         X      = ptr to hardware
*
* Exit:   CHS values placed directly in HW
*
DoLBA               lda       V.WhichDv,u         get devhead value populated by IOSetup (CHS mode)
                    ora       #%01000000          OR in LBA bit
                    sta       DevHead,x
                    ldd       #NBUSYNDRQ          /BUSY and /DRQ
                    bsr       StatusWait
                    bcs       ex@
                    ldb       V.PhySct,u          get bits 23-16 of sector
                    stb       CylHigh,x           store it
                    ldd       V.PhySct+1,u        get bits 15-0 of sector
                    stb       SectNum,x           store it
                    sta       CylLow,x
ex@                 rts


* Wait for a set of conditions in the status register to be TRUE
* This yields a delay of about 4 seconds.
*
* Entry: X = HW address
*        A = flip (if bit set, that bit is tested)
*        B = mask (result must match this byte)
* Exit:  A = status
StatusWait
                    pshs      y,b,a
                    ifeq      Level-1
                    ldb       #WAITTIME/2
                    ldy       #$0000
                    else
                    ldb       #WAITTIME
                    ldy       #$0000
                    endc
l@                  lda       Status,x
                    anda      ,s                  apply flip
                    cmpa      1,s                 compare to mask
                    bne       dec@                branch if not equal (not what we want)
                    clrb                          clear carry
                    bra       ok@
dec@                leay      -1,y                count down
                    bne       l@
                    decb                          decrement bits 23-16
                    bpl       l@                  if >=0, keep going
err@                comb                          set carry
                    ldb       #E$DevBsy
ok@                 leas      2,s
                    lda       Status,x            get status again
                    puls      y,pc

* Wait for 1 tick (1/60 second)
*Delay1Tk
*         pshs  x
*         IFGT  Level-1
*         ldx   D.Proc		get proc descriptor
*         cmpx  D.SysPrc	system?
*         beq   hw@		yep, system cannot sleep
*         ENDC
*         ldx   D.AProcQ	get active proc queue
*         beq   hw@		if empty, do hard wait
*         ldx   #1
*         os9   F$Sleep		give up worst case: 1 tick (1/60 second)
*         puls  x,pc		return to caller
** In case we can't sleep... do a hard 1/60 second delay
*hw@
*         IFEQ  Level-1
*         ldx   #$E52E/2		(5) (4)
*         ELSE
*         ldx   #$E52E		(5) (4)
*         ENDC
*w@       leax  -1,x		(4+) (4+)
*         bne   w@		(3) (3)
*         puls  x,pc		return to caller
*


* ll_write - Low level write routine
*
* Entry:
*    Registers:
*      Y  = address of path descriptor
*      U  = address of device memory area
*    Static Variables of interest:
*      V.PhySct = starting physical sector to write to
*      V.SectCnt  = number of physical sectors to write
*      V.SectSize = physical sector size (0=256,1=512,2=1024,3=2048)
*      V.CchPSpot = address of data to write to device
*
* Exit:
*    All registers may be modified
*    Static variables may NOT be modified
ll_write
                    pshs      x                   make some space on the stack
                    lbsr      IOSetup             initialize the device
                    lbcs      ex@
* Copy V.PhySct to our local copy
                    lda       V.PhysSect,u
                    ldy       V.PhysSect+1,u
                    sta       V.PhySct,u
                    sty       V.PhySct+1,u
                    lda       V.SectCnt,u
                    sta       V.SctCnt,u
*
                    ldy       V.CchPSpot,u        get pointer to spot in cache where physical sector is
                    bitb      #$02                ATAPI device?
                    lbne      ATAPIWrite          yes, go do it
* ATA Write Routine
ATAWrite            stb       V.CurStat,u         save status of current drive
loop@
                    ldd       #NBUSY              /BUSY
                    bsr       StatusWait          wait for proper condition
                    bcs       ex@                 branch if ok
* Check for LBA mode
                    ldb       V.CurStat,u         get status of current drive
                    bitb      #$04                LBA bit set?
                    bne       lba@                branch if so
* Here, we use CHS
                    bsr       DoCHS
                    bcs       ex@
                    bra       cont@
lba@                lbsr      DoLBA
cont@               lda       #$01
                    sta       SectCnt,x           store it
                    lda       #S$WRITE
                    sta       Command,x
                    ldd       #NBUSY              /BUSY
                    bsr       StatusWait          wait for proper condition
                    bcs       ex@                 branch if ok
                    lsra                          error bit set?
                    bcc       g@                  branch if not
                    lbsr      ATAError
                    bra       ex@
g@                  ldd       #NBUSYDRQ           /BUSY and DRQ
                    lbsr      StatusWait          wait for proper condition
                    bcs       ex@                 branch if ok
again@              lda       V.Log2Phys,u
                    sta       1,s                 set up our sector counter
inc@                clr       ,s                  set up our byte counter
wr@                 ldd       ,y++
                    stb       Latch,x
                    sta       DataReg,x
                    inc       ,s
                    bpl       wr@
                    dec       1,s
                    bne       inc@
* Increment physical sector
                    inc       V.PhySct+2,u
                    bcc       go@
                    inc       V.PhySct+1,u
                    bcc       go@
                    inc       V.PhySct,u
go@
                    dec       V.SctCnt,u          decrement # of hw sectors to read
                    bne       loop@               if not zero, do it again
                    clrb
ex@                 puls      x,pc

*
* Convert LSN to C/H/S values and write to IDE hardware
*
* Entry:  V.PhySct = bits 23-0 of LSN
*         X      = ptr to hardware
*
* Exit:   CHS values placed directly in HW
*
DoCHS
* Select device
                    lda       V.WhichDv,u         get devhead value made by IOSetup (already CHS)
                    sta       DevHead,x
                    ldd       #NBUSYNDRQ          /BUSY and /DRQ
                    lbsr      StatusWait          wait for proper condition
                    bcc       start@              branch if ok
                    rts
* Start computation
start@              pshs      y                   save original Y
                    ldy       V.CurDTbl,u
                    lda       3,y                 get device's head
                    ldb       5,y                 and sector
                    stb       V.Sectors,u
                    mul                           multiply H*S
                    beq       ZeroProd            if zero, error out
                    pshs      d                   save product of H*S
                    ldd       V.PhySct+1,u        get bits 15-0 of LSN
                    ldy       #-1                 start Y at -1
                    inc       V.PhySct,u          increment physical sector
* Here we are doing physLSN/(H*S) to get cylinder for physLSN
a@                  leay      1,y                 increment count to compensate
                    subd      ,s                  subtract (H*S) from physLSN
                    bhs       a@                  if D>=0 then continue
                    dec       V.PhySct,u          decrement phys sector bits 23-16
                    bne       a@                  if not zero, continue divide
                    addd      ,s++                add in (H*S) to make non-negative
                    pshs      d                   D now holds cylinder, save on stack
                    tfr       y,d                 Y now holds cylinder value
                    exg       a,b                 swap
                    std       CylLow,x            store computed cylinder in HW
                    puls      d                   restore saved cylinder
* Now we will compute the sector/head value
                    ldy       #-1
b@                  leay      1,y
                    subb      V.Sectors,u
                    sbca      #0
                    bcc       b@
                    addb      V.Sectors,u
                    incb                          add 1 to B, which is sector
                    stb       SectNum,x           store computed sector in HW
                    tfr       y,d
                    orb       DevHead,x           OR in with value written earlier
                    stb       DevHead,x
                    clrb
                    puls      y,pc
ZeroProd            ldb       #E$Sect
                    coma
                    puls      y,pc

* ATAError - Checks the ATA error register and maps
*            to a NitrOS-9 error message.
*
* Called if the error bit in the status register is set.
ATAError
                    lda       ErrorReg,x
                    ldb       #7
l@                  lsra
                    bcs       LookUp
                    decb
                    bne       l@
LookUp              leax      Errs,pcr
x@                  ldb       b,x
                    coma
                    rts

* This is the ATAPI Sense Key -> NitrOS-9 Error Table
* The Sense Key Table is on page 50 of the ATAPI Removable
* Rewritable Specification, Revision 1.3 Proposed.
* If an error number is zero, then no error is returned.
SenseMap            fcb       0                   sense key 0 (NO SENSE)
                    fcb       0                   sense key 1 (RECOVERED ERROR)
                    fcb       E$NotRdy            sense key 2 (NOT READY)
                    fcb       E$Sect              sense key 3 (MEDIUM ERROR)
                    fcb       E$Unit              sense key 4 (HARDWARE ERROR)
                    fcb       E$IllArg            sense key 5 (ILLEGAL REQUEST)
                    fcb       0                   sense key 6 (UNIT ATTENTION)
                    fcb       E$WP                sense key 7 (DATA PROTECT)
                    fcb       0                   sense key 8 (BLANK CHECK)
                    fcb       0                   sense key 9 (VENDOR SPECIFIC)
                    fcb       0                   sense key A (RESERVED)
                    fcb       1                   sense key B (ABORTED COMMAND)
                    fcb       0                   sense key C (RESERVED)
                    fcb       0                   sense key D (VOLUME OVERFLOW)
                    fcb       0                   sense key E (MISCOMPARE)
                    fcb       0                   sense key F (RESERVED)

* ERROR REG Bit   0      1     2       3       4        5      6     7
Errs                fcb       E$Unit,E$CRC,E$UnkSvc,E$Sect,E$UnkSvc,E$DIDC,E$Seek,E$Sect

                    emod
eom                 equ       *
                    end
