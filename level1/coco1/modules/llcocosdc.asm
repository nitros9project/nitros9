********************************************************************
* llcocosdc - CoCo SDC Low-level driver
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2013/05/??  Boisy G. Pitre
* Created.
*          2014/11/27  tim lindner
* Changed read and write routines to enter and leave command mode.
*
*          2014/12/22  Darren Atkinson
* Total re-write. Provides MPI slot selection to permit co-existence
* with a real floppy controller.  Sends command to controller during
* Init which locks out the floppy emulation capability. Adds GetStat
* functions for extended commands.  Uses TFM to retrieve data blocks
* when a 6309 CPU is present. Supports the SS.DSize GetStat function
* to query controller for the disk size.
*
*          2015/01/08  Darren Atkinson
* Fixed bug in getSize which caused boot to fail when controller was
* installed in slot 2, 3 or 4 of a Multi-Pak Interface.
*
                    nam       llcocosdc
                    ttl       CoCo SDC Low-level driver

                    use       defsfile
                    use       rbsuper.d
                    use       cocosdc.d

MPIREG              equ       $FF7F


tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       0


                    mod       eom,name,tylg,atrv,start,0

* Low-level driver static memory area inside that of rbsuper
                    org       V.LLMem
V.SDCMPI            rmb       1                   MPI slot containing CoCo SDC
V.MaskIRQs          rmb       1                   contains $50 if IRQ/FIRQ should be masked

name                fcs       /llcocosdc/

start               lbra      ll_init
                    bra       ll_read
                    nop
                    bra       ll_write
                    nop
                    bra       ll_getstat
                    nop
                    bra       ll_setstat
                    nop
                    ***       lbra                ll_term ***
                    clrb
                    rts


*--------------------------------------------------------------------------
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
ll_getstat          ldx       PD.RGS,y            point X at stacked registers
                    lda       R$B,x               get function code
                    cmpa      #SS.DSize
                    beq       getSize             branch if "get disk size"
                    tfr       a,b
                    andb      #$F0                keep hi nibble
                    cmpb      #CMDEXD
                    beq       exCmd               branch if extended command with data
                    anda      #$FF-4              make sure "TFM" bit is cleared
                    cmpb      #CMDEX
                    beq       exCmd               branch if ext command without data
                    comb                          set carry
                    ldb       #E$UnkSvc           return error
                    rts


*--------------------------------------------------------------------------
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
ll_setstat          clrb                          no error
                    rts


*--------------------------------------------------------------------------
* SS.DSize - Return size information about a device
*
* Exit:
*    Carry cleared for no error.
*    A = Sector Size  (1=256, 2=512, 4=1024, 8=2048)
*
*      IF B = 0
*          X = Number of Sectors (bits 31-16)
*          Y = Number of Sectors (Bits 15-0)
*
*      IF B != 0
*          B = Number of Logical Sides
*          X = Number of Logical Cylinders
*          Y = Number of Logical Sectors/Track
*
getSize             lda       #CMDEX              primary command code
                    ora       PD.DRV,y            combine drive num with command
                    ldb       #'Q                 "Query Size" sub-command
                    leay      ,u                  point Y at device mem
                    ldu       #$FFFF              I/O buffer = none
                    pshs      x                   save frame ptr
                    bsr       CommSDC             send query to controller
                    puls      x                   restore frame ptr
                    ldb       #E$NotRdy           error code
                    bcs       sizeRet             return if error
                    ldd       ,y                  bits 15-0 of size
                    std       R$Y,x               return in Y
                    clra                          bits 31-24 of size always zero
                    ldb       -1,y                bits 23-16 of size
                    std       R$X,x               return bits 31-16 in X
                    inca                          A = 1:  256 byte sectors
                    clrb                          B = 0:  LBA device
                    std       R$D,x               return in D
sizeRet             rts


*--------------------------------------------------------------------------
* SDC Extended Device Commands
*
*   Entered with SDC command code in A.
*
*   Parameters are passed indirectly via the register frame:
*       X = address of 256 byte I/O buffer or $FFFF if none
*     U.L = optional param byte 1
*       Y = optional param bytes 2 (hi) and 3 (low)
*
*   Response values are returned indirectly via the register frame:
*       A = controller status
*     U.H = 0
*     U.L = response byte 1
*       Y = response bytes 2 (hi) and 3 (low)
*
exCmd               pshs      u,y,x               preserve registers
                    leay      ,u                  Y = device memory area
                    ldu       R$X,x               U = I/O buffer address
                    ldb       R$U+1,x             B = param byte 1
                    ldx       R$Y,x               X = param bytes 2 and 3
                    bsr       CommSDC             do command protocol
                    puls      x                   restore register frame pointer
                    stb       R$A,x               [A] = controller status
                    lda       #0                  will clear top half of U
                    ldb       -1,y                get response byte 1 (FF49)
                    std       R$U,x               [U] = 1st response byte
                    ldd       ,y                  get response bytes 2,3 (FF4A,B)
                    std       R$Y,x               [Y] = 2nd and 3rd response bytes
                    ldb       #E$NotRdy           error code
                    bcs       exOut               skip next if error
                    clrb                          no error
exOut               puls      y,u,pc              return


*--------------------------------------------------------------------------
* ll_write
*
*    Write one sector.
*
* Entry:
*    Y  = address of path descriptor
*    U  = address of device memory area
*
*
ll_write            lda       #CMDWRITE           command code for Write
                    bsr       sectorIO            common sector I/O
                    bcc       wrRet               return if success
                    ldb       #E$Write            error code for write
wrRet               rts


*--------------------------------------------------------------------------
* ll_read
*
*    Read one sector.
*
* Entry:
*    Y  = address of path descriptor
*    U  = address of device memory area
*
ll_read             lda       #CMDREAD+4          command code for 6309 Read (TFM)
                    fcb       $11                 next instr is "LDE" on 6309
                    lda       #CMDREAD            command code for 6809 Read
                    bsr       sectorIO            common sector I/O
                    bcc       rdRet               return if success
                    ldb       #E$Read             error code for read
rdRet               rts


*--------------------------------------------------------------------------
* Funnel code for sector read and write
*
* Entry:
*    A  = read/write command code
*    Y  = address of path descriptor
*    U  = address of device memory area
*
sectorIO            ldb       #1                  highest drive number allowed
                    subb      PD.DRV,y            range check drive number
                    bcc       drvOK               branch if valid
                    ldb       #E$Unit             error code for bad drive number
                    puls      x,pc                pop top address then return

drvOK               ora       PD.DRV,y            combine drive num with command
                    leay      ,u                  point Y at device mem
                    ldb       V.PhysSect,u        B = hi byte of LSN
                    ldx       V.PhysSect+1,u      X = lo word of LSN
                    ldu       V.CchPSpot,u        U = buffer address

                    ***       Fall                Thru ***

*--------------------------------------------------------------------------
* CommSDC
*
*    This is the core routine used for all
*    transactions with the SDC controller.
*
* Entry:
*    A = Command code
*    B = LSN hi byte  / First parameter byte
*    X = LSN lo word  / 2nd and third param bytes
*    Y = Address of driver device memory area
*    U = Address of I/O buffer ($FFFF = none)
*
* Exit:
*    Carry set on error
*    B = controller status code
*    Y = address of SDC Data Register A (FF4A)
*
CommSDC

* Save current MPI setting and activate the SDC slot
                    pshs      cc                  preserve CC (interrupt masks)
                    lsr       ,s                  shift carry out of saved CC
                    pshs      a,b                 save cmd code, alloc byte for saving MPI
                    tfr       cc,a                get copy of current CC
                    ora       V.MaskIRQs,y        set I and F masks if FDC present
                    tfr       a,cc                update I and F in CC
                    lda       MPIREG              get current MPI slot
                    sta       1,s                 save on stack where B was pushed
                    anda      #$30                mask out current SCS nibble
                    ora       V.SDCMPI,y          insert SCS nibble for SDC slot
                    ldy       #DATREGA            setup Y for hardware addressing
                    tsta                          was an SDC controller found?
                    bmi       sdcNone             exit if no
                    sta       MPIREG              activate MPI slot

* Put controller in Command mode
                    lda       #CMDMODE            the magic number
                    sta       -10,y               send to control latch (FF40)
                    puls      a                   pull saved command code back into A

* Put input parameters into the registers.
* It does no harm to put random data in the
* registers for commands which dont use them.
                    stb       -1,y                high byte to param reg 1
                    stx       ,y                  low word to param regs 2 and 3

* Wait for Not Busy.
                    lbsr      waitForIt           run polling loop
                    bcs       cmdExit             exit if error or timed out

* Send command to controller
                    sta       -2,y                to command register (FF48)

* Determine if a data block should be sent.
* The code for any command which requires
* a data block will have bit 5 set.
                    bita      #$20                test the "send block" command bit
                    beq       rxBlock             branch if no block to send

* Wait for Ready to send
                    bsr       waitForIt           run polling loop
                    bcs       cmdExit             exit if error or timed out
                    leax      ,u                  move data address to X
                    ifgt      Level-1
                    bita      #$40                extended command or sector write?
                    lbne      txCmd               branch if extended command
                    endif

* Send 256 bytes of data
                    ldd       #32*256+8           32 chunks of 8 bytes
txChunk             ldu       ,x                  send one chunk...
                    stu       ,y
                    ldu       2,x
                    stu       ,y
                    ldu       4,x
                    stu       ,y
                    ldu       6,x
                    stu       ,y
                    abx                           point X at next chunk
                    deca                          decrement chunk counter
                    bne       txChunk             loop until all 256 bytes sent

* Wait for command to complete
txCompl             lda       #5                  timeout retries
txWait              bsr       waitForIt           run polling loop
                    bitb      #BUSY               test BUSY bit
                    beq       cmdExit             exit if completed
                    deca                          decrement retry counter
                    bne       txWait              repeat if until 0
                    coma                          set carry for timeout error
                    bra       cmdExit             exit

* Set error condition and exit when no SDC hardware found
sdcNone             leas      1,s                 pop saved command code
                    comb                          set carry
                    ldb       #E$Unit             error number for missing hardware
                    bra       cmdExit             exit

* For commands which return a 256 byte response block the
* controller will set the READY bit in the Status register
* when it has the data ready for transfer.   For commands
* which do not return a response block the BUSY bit will
* be cleared to indicate that the command has completed.
*
rxBlock             bsr       longWait            run long status polling loop
                    bls       cmdExit             exit if error, time out or completed
                    leax      1,u                 test the provided buffer address
                    beq       cmdExit             exit if "no buffer" ($FFFF)
                    bita      #$04                test the "TFM" command bit
                    bne       rx6309              branch if set
                    leax      ,u                  move data address to X
                    ifgt      Level-1
                    bita      #$40                extended command or sector read?
                    bne       rxCmd               branch if extended command
                    endif

* 6809 read transfer loop into current task space
                    ldd       #32*256+8           32 chunks of 8 bytes
rxChunk             ldu       ,y                  read one chunk...
                    stu       ,x
                    ldu       ,y
                    stu       2,x
                    ldu       ,y
                    stu       4,x
                    ldu       ,y
                    stu       6,x
                    abx                           update X for next chunk
                    deca                          decrement chunk counter
                    bne       rxChunk             loop until all 256 bytes transferred
                    bra       cmdOK               exit with SUCCESS

* 6309 read transfer using TFM into current task space
rx6309              fcb       $10,$86,$01,$00     [ldw #256] block size = 256
                    orcc      #$50                ensure interrupts are masked
                    leax      1,y                 point X at Data Register B (FF4B)
                    fcb       $11,$3B,$13         [tfm x,u+] read block
cmdOK               clrb                          status code for SUCCESS, clear carry

* Exit
cmdExit             puls      a                   pull saved MPI settings
                    rol       ,s                  rotate carry into saved CC on stack
                    clr       -10,y               end command mode
                    sta       MPIREG              restore saved MPI settings
                    puls      cc,pc               restore irq masks, update carry and return


*--------------------------------------------------------------------------
* Wait for controller status to indicate either "Not Busy" or "Ready".
* Will time out if neither condition satisfied within a suitable period.
*
* Exit:
*    CC.C set on error or time out.
*    CC.Z set on "Not Busy" status (if carry cleared).
*    B = status
*    A, Y and U are preserved.
*
longWait            bsr       waitForIt           enter here for doubled timeout
                    bcc       waitRet             return if cleared in 1st pass
waitForIt           ldx       #0                  setup timeout counter
waitLp              comb                          set carry for assumed FAIL
                    ldb       -2,y                read status
                    bmi       waitRet             return if FAILED
                    lsrb                          BUSY --> Carry
                    bcc       waitDone            branch if not busy
                    bitb      #READY/2            test READY (shifted)
                    bne       waitRdy             branch if ready for transfer
                    bsr       waitRet             consume some time
                    ldb       #$81                status = timeout
                    leax      ,-x                 decrement timeout counter
                    beq       waitRet             return if timed out
                    bra       waitLp              try again

waitDone            clrb                          Not Busy: status = 0, set Z
waitRdy             rolb                          On Ready: clear C and Z
waitRet             rts                           return


*--------------------------------------------------------------------------
* Transfers of command and response data require special handling
* in Level 2 due to separate address space for System/User tasks.
*
                    ifgt      Level-1
* Send command data from User task space
txCmd               bsr       tskPrep             B = task#, push word counter
txWord              os9       F$LDABX             get byte from user space buffer
                    sta       ,y                  send 1st half of word
                    leax      1,x                 increment buffer address
                    os9       F$LDABX             get byte from user space buffer
                    sta       1,y                 send 2nd half of word
                    leax      1,x                 increment buffer address
                    dec       ,s                  decrement word counter
                    bne       txWord              loop if more to send
                    leas      1,s                 pop word counter
                    lbra      txCompl             go wait for command completion

tskPrep             ldu       D.Proc              get current process ptr
                    ldb       P$Task,u            get task # for current process
                    lda       #128                number of words to transfer (256 bytes)
                    ldu       ,s+                 half-pop return address into U
                    sta       ,s                  leave word counter on the stack
                    tfr       u,pc                return

* Read response data into User task space
rxCmd               bsr       tskPrep             B = task#, push word counter
rxWord              lda       ,y                  read 1st half of word
                    os9       F$STABX             store in user space buffer
                    leax      1,x                 increment buffer address
                    lda       1,y                 read 2nd half of word
                    os9       F$STABX             store in user space buffer
                    leax      1,x                 increment buffer address
                    dec       ,s                  decrement word counter
                    bne       rxWord              loop if more to read
                    leas      1,s                 pop word counter
                    bra       cmdOK               exit with SUCCESS
                    endif


*--------------------------------------------------------------------------
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
ll_init             pshs      cc                  save irq masks
                    orcc      #$50                mask irqs
                    ldd       #$8080              prepare "not found" values
                    pshs      dp,b,a              alloc variables on stack
                    ldx       #CMDREG             point X at FDC command reg
                    ldb       MPIREG              get current MPI slot
                    andb      #$33                mask out the unused bits
                    stb       2,s                 save on stack (in DP position)
                    orb       #$03                start SCS scan at slot 4

chkSlot             stb       MPIREG              activate slot being scanned
                    lda       ,s                  have we already found CoCo SDC ?
                    bpl       chkFDC              branch if yes
                    lda       #$64                test pattern
                    sta       -6,x                store at Flash Data Reg address
                    lda       -5,x                get value from Flash Ctrl Reg
                    clr       -6,x                clear Flash Data Reg
                    eora      -5,x                get changed bits from Ctrl Reg
                    suba      #$60                did expected bits change?
                    bne       chkFDC              branch if not an SDC
                    stb       ,s                  record the SDC slot
                    bra       nxtSlot             go scan next slot

chkFDC              lda       1,s                 have we already found an FDC ?
                    bpl       nxtSlot             branch if yes
                    bsr       fdcTest             test if FDC present
                    bne       nxtSlot             branch if not present
                    stb       1,s                 record the FDC slot

nxtSlot             decb                          decrement SCS slot number
                    bitb      #$08                have we scanned all slots?
                    beq       chkSlot             loop if more to scan
                    lda       ,s                  get slot with CoCo SDC
                    bmi       saveSDC             branch if none
                    cmpa      2,s                 same as original slot selection?
                    bne       saveSDC             branch if no
                    eora      #$01                change original slot to..
                    sta       2,s                 ..be something else
                    eora      #$01                back to the true SDC slot
saveSDC             anda      #$83                keep SDC slot number or "not found"
                    sta       V.SDCMPI,u          store SDC slot info in device mem
                    lda       #$50                irq masks will be needed if FDC present
                    ldb       1,s                 was an FDC found?
                    bpl       useSlot             branch if yes
                    clra                          irq masks not needed
                    ldb       2,s                 get original MPI slot selection
useSlot             stb       MPIREG              activate default MPI slot
                    sta       V.MaskIRQs,u        store irq masks in device mem
                    lda       $FF22               reset any latched CART interrupt
                    leas      3,s                 pop variables off the stack
                    puls      cc                  restore saved irq masks

* Disable Floppy Emulation capability in SDC controller
                    lda       #$C0                primary command code
                    ldb       #'g                 secondary command to "Set Global Flags"
                    ldx       #$FF80              mask/flag bytes
                    leay      ,u                  point Y at static variables
                    ldu       #$FFFF              "no buffer" address
                    lbsr      CommSDC             send command to controller
                    clrb                          no error
                    rts                           return

* Test for presence of FDC in active slot
fdcTest             lda       #$D0                FORCE INTERRUPT command
                    sta       ,x                  send to FDC command register
                    bsr       fdcDelay            wait awhile
                    lda       ,x                  read FDC status
                    lda       3,x                 read FDC data register
                    coma                          invert all bits
                    sta       3,x                 put inverted data back
                    bsr       fdcDelay            wait awhile
                    suba      3,x                 test if read matches write
fdcDelay            pshs      y,x,d,cc            push regs
                    mul                           delay cycles
                    puls      cc,d,x,y,pc         restore regs and return


*--------------------------------------------------------------------------

                    emod
eom                 equ       *
                    end

