********************************************************************
* sdrive - Assign disk image to SDC slot
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2014/11/30  tim lindner
* Started writing code.

                    nam       sdrive
                    ttl       Assign disk image to SDC slot

                    ifp1
                    use       defsfile
                    endc

* Here are some tweakable options
DOHELP              set       0                   1 = include help info
STACKSZ             set       32                  estimated stack size in bytes
PARMSZ              set       256                 estimated parameter size in bytes

* Module header definitions
tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

*********************************************************************
*** Hardware Addressing
*********************************************************************
CTRLATCH            equ       $FF40               ; controller latch (write)
CMDREG              equ       $FF48               ; command register (write)
STATREG             equ       $FF48               ; status register (read)
PREG1               equ       $FF49               ; param register 1
PREG2               equ       $FF4A               ; param register 2
PREG3               equ       $FF4B               ; param register 3
DATREGA             equ       PREG2               ; first data register
DATREGB             equ       PREG3               ; second data register
*********************************************************************
*** STATUS BIT MASKS
*********************************************************************
BUSY                equ       %00000001
READY               equ       %00000010
FAILED              equ       %10000000

                    mod       eom,name,tylg,atrv,start,size

                    org       0
slot                rmb       1

cleartop            equ       .                   everything up to here gets cleared at start
* Finally the stack for any PSHS/PULS/BSR/LBSRs that we might do
                    rmb       STACKSZ+PARMSZ
size                equ       .

* The utility name and edition goes here
name                fcs       /sdrive/
                    fcb       edition
* Place constant strings here
timeout             fcc       /Timeout./
                    fcb       C$LF
                    fcb       C$CR
timeoutL            equ       *-timout

targetInUse         fcc       /Target in use./
                    fcb       C$LF
                    fcb       C$CR
targetInUseL        equ       *-targetInUse

dirNotFound         fcc       /Directory not found./
                    fcb       C$LF
                    fcb       C$CR
dirNotFoundL        equ       *-dirNotFound

pathNameInvalid     fcc       /Pathname is invalid./
                    fcb       C$LF
                    fcb       C$CR
pathNameInvalidL    equ       *-pathNameInvalid

miscHardware        fcc       /Miscellaneous hardware error./
                    fcb       C$LF
                    fcb       C$CR
miscHardwareL       equ       *-miscHardware

unknown             fcc       /Unknown error./
                    fcb       C$LF
                    fcb       C$CR
unknownL            equ       *-unknown

targetNotFound      fcc       /Target not found./
                    fcb       C$LF
                    fcb       C$CR
targetNotFoundL     equ       *-targetNotFound

                    ifne      DOHELP
HlpMsg              fcb       C$LF
                    fcc       /Use: sdrive <slot> <image name>/
                    fcb       C$LF
                    fcb       C$CR
                    fcc       /  <slot> is a number, either 0 or 1./
                    fcb       C$LF
                    fcb       C$CR
                    fcc       /  <image name> is valid path and image name./
                    fcb       C$LF
                    fcb       C$CR
                    fcc       /  <image name> can be blank to eject an image./
                    fcb       C$LF
                    fcb       C$CR
HlpMsgL             equ       *-HlpMsg
                    endc
*
* Here's how registers are set when this process is forked:
*
*   +-----------------+  <--  Y          (highest address)
*   !   Parameter     !
*   !     Area        !
*   +-----------------+  <-- X, SP
*   !   Data Area     !
*   +-----------------+
*   !   Direct Page   !
*   +-----------------+  <-- U, DP       (lowest address)
*
*   D = parameter area size
*  PC = module entry point abs. address
*  CC = F=0, I=0, others undefined

* The start of the program is here.
* main program
start
                    cmpd      #1
                    lbeq      ShowHelp
                    subb      #1
                    sbca      #0
                    clr       d,x                 put null at end of parameter area (not CR)
                    leas      -3,s                make some more room in parameter area
                    lbsr      SkipSpcs
                    clr       slot,u
                    lda       ,x+
                    cmpa      #'0
                    beq       slot0
                    cmpa      #'1
                    beq       slot1
                    lbra      ShowHelp
slot1               inc       slot,u
slot0
                    lbsr      SkipSpcs            skip forward to parameter
                    leax      -2,x                back off two bytes
* Add M: to start of parameter
                    ldd       #"M:
                    std       ,x
* setup SDC for command mode
                    orcc      #IntMasks           mask interrupts
                    lbsr      CmdSetup
                    bcc       sendCommand
                    andcc     #^IntMasks          unmask interrupts
                    ldb       #$f6                Not ready error code
                    lbra      Exit
sendCommand
                    ldb       #$e0
                    orb       slot,u
                    stb       CMDREG              send to SDC command register
                    exg       a,a                 wait
                    lbsr      txData              transmit buffer to SDC
                    lda       #$0
                    sta       CTRLATCH
                    andcc     #^IntMasks          unmask interrupts
                    bcc       ExitOK
                    tstb
                    beq       timeOutError
                    bitb      #$20
                    bne       targetInUseError
                    bitb      #$10
                    bne       targetNotFoundError
                    bitb      #$08
                    bne       miscHardwareError
                    bitb      #$04
                    bne       pathNameInvalidError
                    bra       unknownError
targetInUseError
                    ldy       #targetInUseL
                    leax      targetInUse,pc
                    bra       wrtErr
targetNotFoundError
                    ldy       #targetNotFoundL
                    leax      targetNotFound,pc
                    bra       wrtErr
miscHardwareError
                    ldy       #miscHardwareL
                    leax      miscHardware,pc
                    bra       wrtErr
pathNameInvalidError
                    ldy       #pathNameInvalidL
                    leax      pathNameInvalid,pc
                    bra       wrtErr
unknownError
                    ldy       #unknownL
                    leax      unknown,pc
                    bra       wrtErr
timeOutError
                    ldy       #timeoutL
                    leax      timeout,pc
wrtErr              lda       #$2
                    os9       I$Write

ExitOK              clrb
Exit
                    os9       F$Exit

ShowHelp            equ       *
                    ifne      DOHELP
                    leax      >HlpMsg,pcr         point to help message
                    ldy       #HlpMsgL            get length
                    lda       #$02                std error
                    os9       I$Write             write it
                    endc
                    bra       ExitOk

* Stolen from BASIC09
* Convert # in D to ASCII version (decimal)
L09BA               pshs      y,x,d               Preserve End of data mem ptr,?,Data mem size
                    pshs      d                   Preserve data mem size again
                    leay      <L09ED,pc           Point to decimal table (for integers)
L09C1               ldx       #$2F00
L09C4               puls      d                   Get data mem size
L09C6               leax      >$0100,x            Bump X up to $3000
                    subd      ,y                  Subtract value from table
                    bhs       L09C6               No underflow, keep subtracting current power of 10
                    addd      ,y++                Restore to before underflow state
                    pshs      d                   Preserve remainder of this power
                    ldd       ,y                  Get next lower power of 10
                    tfr       x,d                 Promptly overwrite it with X (doesn't chg flags)
                    beq       L09E6               If finished table, skip ahead
                    cmpd      #$3000              Just went through once?
                    beq       L09C1               Yes, reset X & do again
*        lbsr  L1373      Go save A @ [<u0082]
                    ldb       11,u                Write A to output buffer
                    sta       b,u
                    incb
                    stb       11,u
                    ldx       #$2F01              Reset X differently
                    bra       L09C4               Go do again

L09E6
*        lbsr  L1373      Go save A @ [<u0082]
                    ldb       11,u                Write A to output buffer
                    sta       b,u
                    incb
                    stb       11,u
                    leas      2,s                 Eat stack
                    puls      pc,y,x,d            Restore regs & return

* Table of decimal values
L09ED               fdb       $2710               10000
                    fdb       $03E8               1000
                    fdb       $0064               100
                    fdb       $000A               10
                    fdb       $0001               1
                    fdb       $0000               0

*********************************************************************
* Setup Controller for Command Mode
*********************************************************************
* EXIT:
*   Carry cleared on success, set on timeout
*   All other registers preserved
*
CmdSetup            pshs      x,a                 ; preserve registers
                    lda       #$43                ; put controller into..
                    sta       CTRLATCH            ; Command Mode
                    ldx       #0                  ; long timeout counter = 65536
busyLp              lda       STATREG             ; read status
                    lsra                          ; move BUSY bit to Carry
                    bcc       setupExit           ; branch if not busy
                    leax      -1,x                ; decrement timeout counter
                    bne       busyLp              ; loop if not timeout
                    lda       #0                  ; clear A without clearing Carry
                    sta       CTRLATCH            ; put controller back in emulation
setupExit           puls      a,x,pc              ; restore registers and return

*********************************************************************
* Send 256 bytes of Command Data to SDC Controller
*********************************************************************
* ENTRY:
*   X = Data Address
*
* EXIT:
*   B = Status
*   Carry set on failure or timeout
*   All other registers preserved
*
txData              pshs      u,y,x               ; preserve registers
                    ldy       #DATREGA            ; point Y at the data registers
* Poll for Controller Ready or Failed.
                    comb                          ; set carry in anticipation of failure
                    ldx       #0                  ; max timeout counter = 65536
txPoll              ldb       -2,y                ; read status register
                    bmi       txExit              ; branch if FAILED bit is set
                    bitb      #READY              ; test the READY bit
                    bne       txRdy               ; branch if ready
                    leax      -1,x                ; decrement timeout counter
                    beq       txExit              ; exit if timeout
                    bra       txPoll              ; poll again
* Controller Ready. Send the Data.
txRdy               ldx       ,s                  ; re-load data address into X
                    ldb       #128                ; 128 words to send (256 bytes)
txWord              ldu       ,x++                ; get data word from source
                    stu       ,y                  ; send to controller
                    decb                          ; decrement word loop counter
                    bne       txWord              ; loop until done
* Done sending data, wait for result
                    ldx       #0                  ; wait for result
                    comb                          ; assume error
txWait              ldb       -2,y                ; load status
                    bmi       txExit              ; branch if failed
                    lsrb                          ; clear carry if not busy
                    bcc       txExit              ; test ready bit
                    leax      -1,x                ; decrememnt timeout counter
                    bne       txWait              ; loop back until timeout
txExit              puls      x,y,u,pc            ; restore registers and return

*********************************************************************
* Retrieve 256 bytes of Response Data from SDC Controller
*********************************************************************
* ENTRY:
*    X = Data Storage Address
*
* EXIT:
*    B = Status
*    Carry set on failure or timeout
*    All other registers preserved
*
rxData              pshs      u,y,x               ; preserve registers
                    ldy       #DATREGA            ; point Y at the data registers
* Poll for Controller Ready or Failed.
                    comb                          ; set carry in anticipation of failure
                    ldx       #0                  ; max timeout counter = 65536
rxPoll              ldb       -2,y                ; read status register
                    bmi       rxExit              ; branch if FAILED bit is set
                    bitb      #READY              ; test the READY bit
                    bne       rxRdy               ; branch if ready
                    leax      -1,x                ; decrement timeout counter
                    beq       rxExit              ; exit if timeout
                    bra       rxPoll              ; poll again
* Controller Ready. Grab the Data.
rxRdy               ldx       ,s                  ; re-load data address into X
                    ldb       #128                ; 128 words to read (256 bytes)
rxWord              ldu       ,y                  ; read data word from controller
                    stu       ,x++                ; put into storage
                    decb                          ; decrement word loop counter
                    bne       rxWord              ; loop until done
                    clrb                          ; success! clear the carry flag
rxExit              puls      x,y,u,pc            ; restore registers and return

*********************************************************************
* This routine skip over spaces and commas
*********************************************************************
* Entry:
*   X = ptr to data to parse
* Exit:
*   X = ptr to first non-whitespace char
*   A = non-whitespace char
SkipSpcs            lda       ,x+
                    cmpa      #C$SPAC
                    beq       SkipSpcs
                    leax      -1,x
                    rts

                    emod
eom                 equ       *
                    end
