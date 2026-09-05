********************************************************************
* rbdw - DriveWire RBF driver
*
* This driver works in conjuction with the DriveWire Server on Linux,
* Mac or Windows, providing the CoCo with pseudo-disk access through
* the serial port.
*
* It adheres to the DriveWire Version 3 Protocol.
*
* The baud rate is set at 115200 and the communications requirements
* are set to 8-N-1.  For OS-9 Level One on a CoCo 2, the baud rate
* is 57600.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2008/02/08  Boisy G. Pitre
* Started from drivewire.asm in DriveWire 2 Product folder.
*
*   2      2008/04/22  Boisy G. Pitre
* Verified working operation on a CoCo 3 running NitrOS-9/6809 Level 1 @ 57.6Kbps
*
*   3      2009/03/09  Boisy G. Pitre
* Added checks for size after reading as noted by Darren A's email.
*
*   4      2009/12/31  Boisy G. Pitre
* Fixed a crash in Term by adding a check for DWSubAddr of $0000
* (possible if Init fails due to subroutine module not being in
*  memory and I$Detach calls Term)

                    nam       rbdw
                    ttl       DriveWire RBF driver

NUMRETRIES          equ       8
* Cycle-counted windows (2026-09-05): 65536 polls is ~220ms under turbo on the
* rc11 cores and shrinks with every faster CPU; a DriveWire4 server stall (Java
* GC) measures ~620ms. Multipliers keep the windows above that with margin at a
* 2x faster CPU. Proper fix: TIMER0 ($FE30) counts the fixed 25.175MHz IO clock.
DW_PURGE_MULT       equ       4                   PurgeRX idle window: ~0.9s turbo (~0.45s at 2x)
DW_ABWAIT_MULT      equ       24                  AbWait listen for a stalled server: ~4s turbo (~2s at 2x)

                    ifne      wildbits
* COM1 16750 direct-access equates for the receive-purge path (the
* 16550.d defs are not in this module's include chain).
DWU.TRHB            equ       $FE60               RX holding register
DWU.FCR             equ       $FE62               FIFO control register (write-only)
DWU.LSR             equ       $FE65               line status register
DWU.RXRDY           equ       $01                 LSR data-available bit
                    endc

                    ifp1
                    use       defsfile
                    use       drivewire.d
                    endc

NumDrvs             set       4

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       4

                    mod       eom,name,tylg,atrv,start,size

                    rmb       DRVBEG+(DRVMEM*NumDrvs)
driveno             rmb       1
retries             rmb       1
size                equ       .

                    fcb       DIR.+SHARE.+PEXEC.+PREAD.+PWRIT.+EXEC.+UPDAT.

name                fcs       /rbdw/
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
                    pshs      cc
* Send OP_TERM to the server
                    ifgt      LEVEL-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
* Fix crash in certain cases
                    beq       no@
                    ldy       #$0001
                    lda       #OP_TERM
                    pshs      a
                    leax      ,s
                    orcc      #IntMasks
                    jsr       DW$Write,u
                    clrb
                    puls      a
no@                 puls      cc,pc

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
                    leax      dwiosub,pcr
                    os9       F$Link
                    bcs       InitEx
                    tfr       y,u
                    ifgt      LEVEL-1
                    stu       <D.DWSubAddr
                    else
                    stu       >D.DWSubAddr
                    endc
* Initialize the low level device
                    jsr       DW$Init,u
                    lda       #OP_INIT
                    sta       ,s
                    leax      ,s
                    ldy       #$0001
                    jsr       DW$Write,u
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
                    lda       #NUMRETRIES
                    sta       retries,u
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


ReadSect            pshs      cc
                    pshs      u,y,x,b,a,cc        then push CC and others on stack
* Send out op code and 3 byte LSN
                    lda       PD.DRV,y            get drive number
                    cmpa      #NumDrvs
                    blo       Read1
                    ldb       #E$Unit
                    ifne      wildbits
                    lbra      ReadEr2             long branch - the PurgeRX/ReadAbort block sits in between
                    else
                    bra       ReadEr2
                    endc
Read1               sta       driveno,u
                    lda       #OP_READEX          load A with READ opcode

Read2
                    ldb       driveno,u
                    leax      ,s
                    std       ,x
                    ldy       #5
                    ifgt      LEVEL-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
                    orcc      #IntMasks
                    jsr       DW$Write,u

* Get 256 bytes of sector data
                    ldx       5,s
                    ldx       PD.BUF,x            get buffer pointer into X
                    ldy       #$0100
                    jsr       DW$Read,u
                    ifne      wildbits
* Protocol-completion error path (2026-08-29): on a failed sector read
* the server has already sent the data and is BLOCKED waiting for our
* 2-byte checksum. Aborting without it makes the server consume the
* next command's first bytes as the checksum - server-side frame slip
* (UNKNOWN OPCODE / garbage-LSN / CRC-fail storms in the DW4 log).
* Send a deliberately-wrong checksum, collect and discard the status
* byte, and only then return the error - both parsers stay framed.
                    bcs       ReadAbort
                    bne       ReadAbort
                    else
                    bcs       ReadEr1
                    bne       ReadEr1
                    endc
                    pshs      y
                    leax      ,s
                    ldy       #$0002
                    jsr       DW$Write,u          write checksum to server

* Get error code byte
                    leax      ,s
                    ldy       #$0001
                    jsr       DW$Read,u
                    puls      d
                    ifne      wildbits
* A failed status read here means the server stalled AFTER the data
* leg (checksum already sent) - the status byte is still owed and
* would land inside the next transaction. Wait for it, then purge.
                    lbcs      AbWait
                    lbne      AbWait
                    else
                    bcs       ReadEr0             branch if we timed out
                    bne       ReadEr0
                    endc
                    tfr       a,b                 transfer byte to B (in case of error)
                    tstb                          is it zero?
                    ifne      wildbits
                    lbeq      ReadOkChk           OK status - verify the line is actually silent
                    else
                    beq       ReadEx              if not, exit with error
                    endc
                    cmpb      #E$CRC
                    ifne      wildbits
                    lbne      ReadBadSt
                    else
                    bne       ReadEr2
                    endc
ReadRetry           ldu       7,s                 get U from stack
                    dec       retries,u           decrement retries
                    ifne      wildbits
* Resync before EVERY retry (2026-08-29): when the reply stream is
* lagged (a stale response queued ahead of us), each REREADEX otherwise
* re-reads the PREVIOUS response, fails the server-side CRC again, and
* the retry loop sustains the desync forever - the field signature of
* endless completed-but-CRC-failed reads with no timeouts. Purging
* here drains the backlog so the retry reads fresh, aligned data.
                    lbeq      ReadBadSt           out of retries: purge, then honest E$Read
                    bsr       PurgeRX
                    lda       #OP_REREADEX        reread opcode
                    lbra      Read2
                    else
                    beq       ReadEr1

                    lda       #OP_REREADEX        reread opcode
                    bra       Read2
                    endc               and try getting sector again
                    ifne      wildbits
* Drain the receive path until the line has been idle 10+ character
* times, so an off-by-N stream from a failed transaction cannot poison
* the next one. A shifted-but-still-flowing stream never times out
* inside DWRead (reads complete promptly with wrong bytes), so this
* must run on EVERY failed transaction, not only on timeouts. Bounded:
* max 1200 discards, ~0.6ms idle window. IRQs are masked here.
PurgeRX             pshs      d,x,y
* Hardware RX FIFO reset first: an overrun (server dumping a sector
* remainder into a client that stopped listening) can wedge the FIFO
* pointer state in ways byte-draining never clears.
                    lda       #%11000010          FCR: RX FIFO reset strobe (self-clearing)
                    sta       >DWU.FCR
                    ldy       #1200               max stale bytes to discard
* Idle window DW_PURGE_MULT x 65536 polls (~0.9s turbo): must outlast a
* server-side stall (Java GC in DW4, measured ~620ms total) that
* resumes sending a sector remainder long after our timeouts fired.
* The window restarts on every discarded byte, so an in-progress
* remainder is consumed in real time and the wait only runs in full
* once, after the final straggler.
pur0@               ldb       #DW_PURGE_MULT      idle window = DW_PURGE_MULT x 65536 polls
pur0a@              ldx       #0
pur1@               lda       >DWU.LSR
                    bita      #DWU.RXRDY
                    bne       pur2@               byte present - discard, restart window
                    leax      -1,x
                    bne       pur1@
                    decb                          16-bit window wrapped: one outer count down
                    bne       pur0a@
                    puls      d,x,y,pc            line idle - resynced
pur2@               lda       >DWU.TRHB           discard stale byte
                    leay      -1,y
                    bne       pur0@
                    puls      d,x,y,pc            discard cap hit - stop

ReadAbort           ldd       #$FFFF              deliberately-wrong checksum
                    pshs      d
                    leax      ,s
                    ldy       #$0002
                    jsr       DW$Write,u          complete the checksum leg for the server
                    leax      ,s
                    ldy       #$0001
                    jsr       DW$Read,u           collect (and discard) its status byte
                    puls      d
                    bcs       AbWait              nothing came back - server still stalled
                    bne       AbWait
AbPurge             bsr       PurgeRX             drain any residue before erroring out
                    bra       ReadEr1
* The server never sent a byte: it is deep in a stall (DW4 Java GC,
* measured 620ms+) and the WHOLE response is still owed. If we purge
* now the line looks idle, we declare it clean, and the late burst
* lands inside the NEXT transaction - establishing the one-response
* lag. Listen up to ~2s for the burst to start; PurgeRX then consumes
* it in real time. A truly dead server just costs one slow error.
AbWait              ldb       #DW_ABWAIT_MULT                 DW_ABWAIT_MULT x 65536 polls: ~4s turbo, ~2s at a 2x faster CPU
abw0@               ldx       #0
abw1@               lda       >DWU.LSR
                    bita      #DWU.RXRDY
                    bne       AbPurge             burst arriving - purge drains it live
                    leax      -1,x
                    bne       abw1@
                    decb
                    bne       abw0@
                    bra       AbPurge             still silent - purge anyway, then error
* Status byte was $00 (OK) - but on a synced line the server sends
* NOTHING after the status byte, so the line must now be silent. A
* byte trailing it means we just consumed a STALE response: the "OK"
* belongs to the PREVIOUS transaction and the sector data is wrong
* (accepting it is where the #216/garbage-LSN corruption came from).
* In a lagged, flowing stream the next byte arrives within ~43us at
* 230400; watch ~200us to be sure, then purge and retry the sector.
ReadOkChk           pshs      x
                    ldx       #360                ~600us of LSR polls (was 120; see dwread purge note -
*                                                 these windows are cycle-counted and shrank when rc10's
*                                                 fast writes sped the CPU up)
okc0@               lda       >DWU.LSR
                    bita      #DWU.RXRDY
                    bne       okc1@               trailing byte - stale response consumed
                    leax      -1,x
                    bne       okc0@
                    puls      x
                    lbra      ReadEx              line silent - clean accept
okc1@               puls      x
                    lbra      ReadRetry           purge happens inside the retry path
* A nonzero status byte that is not E$CRC means the reply stream is
* shifted - we just read a data byte as "status". Purge to resync and
* report a plain read error instead of passing the garbage byte through
* as a random error code (the mystery #214/#216 reports).
ReadBadSt           lbsr      PurgeRX
                    endc
ReadEr0
ReadEr1             ldb       #E$Read             read error
ReadEr2             lda       9,s
                    ora       #Carry
                    sta       9,s
ReadEx              leas      5,s
                    puls      y,u
                    puls      cc,pc

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
Write               lda       #NUMRETRIES
                    sta       retries,u
                    pshs      cc
                    pshs      u,y,x,b,a,cc
                    endc
* Send out op code and 3 byte LSN
                    lda       PD.DRV,y
                    cmpa      #NumDrvs
                    blo       Write1
                    comb                          set Carry
                    ldb       #E$Unit
                    bra       WritEx
Write1              sta       driveno,u
                    lda       #OP_WRITE
Write15
                    ldb       driveno,u
                    leax      ,s
                    std       ,x
                    ldy       #$0005
                    ifgt      LEVEL-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
                    orcc      #IntMasks
                    jsr       DW$Write,u

* Compute checksum on sector we just sent and send checksum to server
                    ldy       5,s                 get Y from stack
                    ldx       PD.BUF,y            point to buffer
                    ldy       #256
                    jsr       6,u
                    leax      -256,x
                    bsr       DoCSum
                    pshs      d
                    leax      ,s
                    ldy       #$0002
                    jsr       DW$Write,u

* Await acknowledgement from server on receipt of sector
                    leax      ,s
                    ldy       #$0001
                    jsr       DW$Read,u           read ack byte from server
                    bcs       WritEx0
                    bne       WritEx0
                    puls      d
                    tsta
                    beq       WritEx              yep
                    tfr       a,b
                    cmpb      #E$CRC              checksum error?
                    bne       WritEx2
                    ldu       7,s                 get U from stack
                    dec       retries,u           decrement retries
                    beq       WritEx1             exit with error if no more
                    lda       #OP_REWRIT          else resend
                    bra       Write15
WritEx0             puls      d
WritEx1             ldb       #E$Write
WritEx2             lda       9,s
                    ora       #Carry
                    sta       9,s
WritEx              leas      5,s
                    puls      y,u
                    puls      cc,pc

                    use       dwcheck.asm

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
SetStat             lda       #OP_SETSTA
* Size optimization
                    fcb       $8C                 skip next two bytes


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
                    lda       #OP_GETSTA
                    clrb                          clear Carry
                    pshs      cc                  and push CC on stack
                    leas      -3,s
                    sta       ,s
                    lda       PD.DRV,y            get drive number
                    ldx       PD.RGS,y
                    ldb       R$B,x
                    std       1,s
                    leax      ,s
                    ldy       #$0003
                    ifgt      LEVEL-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
                    jsr       6,u
                    leas      3,s
                    puls      cc,pc

dwiosub             fcs       /dwio/

                    emod
eom                 equ       *
                    end
