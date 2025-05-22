********************************************************************
* WizFi - WizNet WizFi360 Driver
*
* WizFi360 Programming references can be found here:
*   https://docs.wiznet.io/img/products/wizfi360/wizfi360ds/wizfi360_atset_v1118_e.pdf
*   http://www.wiznet.io/
*
* 6309 instructions have been removed since at this time the F256
* doesn't support 6309 instructions, and it makes the code easier
* to follow.
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          ????/??/??
*
*   r1     2025/04/27  Roger Taylor
* Based on sc6551 framework. Removed a ton of ACIA stuff.
*
*          2025/05/05  Roger Taylor
* Works from XTerm software
*
                    nam       WizFi
                    ttl       WizNet WizFi360 Driver

                    ifp1
                    use       defsfile
;           use   scfdefs
                    endc

VIRQCNT  equ  1
WORK_SLOT	equ	MMU_SLOT_2


* conditional assembly switches
TC9                 set       false               "true" for TC-9 version, "false" for Coco 3
MPIFlag             set       true                "true" MPI slot selection, "false" no slot

* miscellaneous definitions
DCDStBit            equ       %00100000           DCD status bit for SS.CDSta call
DSRStBit            equ       %01000000           DSR status bit for SS.CDSta call
SlpBreak            set       TkPerSec/2+1        line Break duration
SlpHngUp            set       TkPerSec/2+1        hang up (drop DTR) duration

                    ifeq      TC9-true
IRQBit              equ       %00000100           GIME IRQ bit to use for IRQ ($FF92)
                    else
IRQBit              equ       %00000001           GIME IRQ bit to use for IRQ ($FF92)
                    endc


* Status bit definitions
Stat.IRQ            equ       %10000000           IRQ occurred
Stat.DSR            equ       %01000000           DSR level (clear = active)
Stat.DCD            equ       %00100000           DCD level (clear = active)
Stat.TxE            equ       %00010000           Tx data register Empty
Stat.RxF            equ       %00001000           Rx data register Full
Stat.Ovr            equ       %00000100           Rx data Overrun error
Stat.Frm            equ       %00000010           Rx data Framing error
Stat.Par            equ       %00000001           Rx data Parity error

Stat.Err            equ       Stat.Ovr!Stat.Frm!Stat.Par Status error bits
Stat.Flp            equ       $00                 all Status bits active when set
Stat.Msk            equ       Stat.IRQ!Stat.RxF   active IRQs


* static data area definitions
                    org       V.SCF               allow for SCF manager data area
Cpy.Stat            rmb       1                   Status register copy
CpyDCDSR            rmb       1                   DSR+DCD status copy
Mask.DCD            rmb       1                   DCD status bit mask (MUST immediately precede Mask.DSR)
Mask.DSR            rmb       1                   DSR status bit mask (MUST immediately follow Mask.DCD)
CDSigPID            rmb       1                   process ID for CD signal
CDSigSig            rmb       1                   CD signal code
FloCtlRx            rmb       1                   Rx flow control flags
FloCtlTx            rmb       1                   Tx flow control flags
RxBufEnd            rmb       2                   end of Rx buffer
RxBufGet            rmb       2                   Rx buffer output pointer
RxBufMax            rmb       2                   Send XOFF (if enabled) at this point
RxBufMin            rmb       2                   Send XON (if XOFF sent) at this point
RxBufPtr            rmb       2                   pointer to Rx buffer
RxBufPut            rmb       2                   Rx buffer input pointer
RxBufSiz            rmb       2                   Rx buffer size
RxDatLen            rmb       2                   current length of data in Rx buffer
SigSent             rmb       1                   keyboard abort/interrupt signal already sent
SSigPID             rmb       1                   SS.SSig process ID
SSigSig             rmb       1                   SS.SSig signal code
WritFlag            rmb       1                   initial write attempt flag
Wrk.Type            rmb       1                   type work byte (MUST immediately precede Wrk.Baud)
Wrk.Baud            rmb       1                   baud work byte (MUST immediately follow Wrk.Type)
Wrk.XTyp            rmb       1                   extended type work byte
VIRQBF              rmb       5                   buffer for VIRQ
LastRxCount         rmb       1


                    ifeq      Level-1
orgDFIRQ            rmb       2
                    endc
regWbuf             rmb       2                   substitute for regW
RxBufDSz            equ       256-.               default Rx buffer gets remainder of page...
RxBuff              rmb       RxBufDSz            default Rx buffer
MemSize             equ       .

rev                 set       2
edition             set       1

                    mod       ModSize,ModName,Drivr+Objct,ReEnt+rev,ModEntry,MemSize

                    fcb       UPDAT.              access mode(s)

ModEntry            lbra      Init
                    lbra      Read
                    lbra      Write
                    lbra      GStt
                    lbra      SStt
                    lbra      Term

ModName             fcs       "WizFi"
                    fcb       edition

DMSK                fcb       0                 no flip bits
                    fcb       Vi.IFlag          polling mask for VIRG
                    fcb       10                priority

* NOTE:  SCFMan has already cleared all device memory except for V.PAGE and
*        V.PORT.  Zero-default variables are:  CDSigPID, CDSigSig, Wrk.XTyp.
Init                clrb                          default to no error...
                    pshs      cc,dp               save IRQ/Carry status, system DP
                    orcc      #IntMasks
                    tfr       u,d
                    tfr       a,dp
                    pshs      y			save Y so it's last on stack so we can recall it using 0,s

                    ldx       <V.PORT
                    ldb       >WORK_SLOT
                    lda       #$C5		  reg.B = Bank where the WizFi registers are
                    sta       >WORK_SLOT
                    lda       #$00
                    sta       WIZFI_UART_CtrlReg,x
                    stb       >WORK_SLOT

* set up IRQ table entry first
* NOTE: uses the status register of the VIRQ buffer for
* the interrupt status register since no hardware status 
* register is available

                    leay      VIRQBF+Vi.Stat,U get address of status byte
                    tfr       y,d               put it into D reg
                    leay      IRQSvc,PCR         get address of interrupt routine 
                    leax      DMSK,PCR         get VIRQ mask info
                    os9       F$IRQ             install onto table
                    lbcs      INIT9             exit on error

        * now set up the VIRQ table entry
                    leay      VIRQBF,U         point to the S-byte packet
                    lda       #$80              get the reset flag to repeat VIRQ's
                    sta       Vi.Stat,y         save it in the buffer
                    ldd       #VIRQCNT          get the VIRQ counter value
                    std       Vi.Rst,y          save it in the reset area of buffer 
                    ldx       #1                code to install the VIRQ
                    os9       F$VIRQ            install on the table
                    lbcs      INIT9             exit on error

INIT9               puls      y
                    puls      cc,dp,pc            recover IRQ/Carry status, system DP, return

Term                clrb                          default to no error...
                    pshs      cc,dp               save IRQ/Carry status, dummy B, system DP
                    tfr       u,d
                    tfr       a,dp
                    ifeq      Level-1
                    ldx       >D.Proc
                    lda       P$ID,x
                    sta       <V.BUSY
                    sta       <V.LPRC
                    endc
TermExit
                    ifeq      Level-1
                    ldd       <orgDFIRQ
                    std       >D.FIRQ
                    endc

* remove from VIRQ table first
                    ldx       #0                  get zero to remove from table
                    leay      VIRQBF,U            get address of packet 
                    os9       F$VIRQ
* then remove from IRQ table
                    ldx       #0                  get zero to remove from table
                    os9       F$IRQ

                    puls      cc                  recover IRQ/Carry status
                    puls      dp,pc               restore dummy A, system DP, return

Read                clrb                          default to no errors...
                    pshs      cc,dp               save IRQ/Carry status, system DP
                    tfr       u,d
                    tfr       a,dp
                    bra       ReadChar
ReadSlp             ldd       >D.Proc             Level II process descriptor address
                    sta       <V.WAKE             save MSB for IRQ service routine
                    tfr       d,x                 copy process descriptor address
                    ldb       P$State,x
                    orb       #Suspend
                    stb       P$State,x
                    lbsr      Sleep1              go suspend process...
                    ldx       >D.Proc             process descriptor address
                    ldb       P$Signal,x          pending signal for this process?
                    beq       ChkState            no, go check process state...
                    cmpb      #S$Intrpt           do we honor signal?
                    bls       ErrExit             yes, go do it...
ChkState            ldb       P$State,x
                    bitb      #Condem
                    bne       PrAbtErr            yes, go do it...
                    ldb       <V.WAKE             true interrupt?
                    bne       ReadSlp             no, go suspend the process
ReadChar
                    lda       <V.PAGE
                    bita      #%10000000
                    bne       ReadExit
                    ldx       <V.PORT

                    orcc      #IntMasks
                    ldb       >WORK_SLOT
                    lda       #$C5                Bank where the WizFi registers are
                    sta       >WORK_SLOT
                    lda       WIZFI_UART_RxD_RD_Count,x
                    stb       >WORK_SLOT
                    andcc     #^IntMasks

                    tsta
                    beq       ReadSlp             none, go sleep while waiting for new Rx data...

                    orcc      #IntMasks
                    ldb       >WORK_SLOT
                    lda       #$C5                Bank where the WizFi registers are
                    sta       >WORK_SLOT
                    lda       WIZFI_UART_DataReg,x
                    stb       >WORK_SLOT
ReadExit            puls      cc,dp,pc            recover IRQ/Carry status, dummy B, system DP, return

PrAbtErr            ldb       #E$PrcAbt
                    bra       ErrExit

ErrExit             equ       *
                    lda       ,s
                    ora       #Carry
                    sta       ,s
                    puls      cc,dp,pc            restore CC, system DP, return

HngUpErr            ldb       #E$HangUp
                    lda       #PST.DCD            DCD lost flag
                    sta       PD.PST,y            set path status flag
                    bra       ErrExit

NRdyErr             ldb       #E$NotRdy
                    bra       ErrExit

UnSvcErr            ldb       #E$UnkSvc
                    bra       ErrExit

Write               pshs      cc,dp               save IRQ/Carry status, Tx character, system DP
                    pshs      a
                    tfr       u,d
                    tfr       a,dp
                    ldx       <V.PORT
                    
                    orcc      #IntMasks           disable IRQs during error and Tx disable checks
                    ldb       >WORK_SLOT
                    lda       #$c5
                    sta       >WORK_SLOT
                    puls      a
                    sta       WIZFI_UART_DataReg,x
                    stb       >WORK_SLOT
                    clrb
                    puls      cc,dp,pc            recover IRQ/Carry status, Tx character, system DP, return

GStt                clrb                          default to no error...
                    pshs      cc,dp               save IRQ/Carry status, dummy B, system DP
                    pshs      a
                    tfr       u,d
                    tfr       a,dp
                    puls      a
                    ldx       PD.RGS,y            caller's register stack pointer
                    cmpa      #SS.EOF
                    beq       GSExitOK            yes, SCF devices never return EOF
                    cmpa      #SS.Ready
                    bne       GetScSiz

                    pshs      x
                    ldx       <V.PORT
                    orcc      #Intmasks
                    ldb       >WORK_SLOT
                    lda       #$C5			Bank where the WizFi registers are
                    sta       >WORK_SLOT
                    lda       WIZFI_UART_RxD_RD_Count,x
                    stb       >WORK_SLOT
                    andcc     #^IntMasks
                    puls      x

                    tsta
                    lbeq      NRdyErr             none, go report error
                    tsta                          more than 255 bytes?
                    beq       SaveLen             no, keep Rx data available
                    ldb       #255                yes, just use 255
SaveLen             stb       R$B,x               set Rx data available in caller's [B]
GSExitOK            puls      cc,dp,pc            restore Carry status, dummy B, system DP, return

GetScSiz            cmpa      #SS.ScSiz
                    bne       GetComSt
                    ldu       PD.DEV,y
                    ldu       V$DESC,u
                    clra
                    ldb       IT.COL,u
                    std       R$X,x
                    ldb       IT.ROW,u
                    std       R$Y,x
                    puls      cc,dp,pc            restore Carry status, dummy B, system DP, return

GetComSt            cmpa      #SS.ComSt
                    lbne      UnSvcErr            no, go report error
                    ldd       <Wrk.Type
                    std       R$Y,x
                    clra                          default to DCD and DSR enabled
                    ldb       <CpyDCDSR
                    bitb      #Mask.DCD
                    beq       CheckDSR            no, go check DSR status
                    ora       #DCDStBit
CheckDSR            bitb      <Mask.DSR           DSR bit set (disabled)?
                    beq       SaveCDSt            no, go set DCD/DSR status
                    ora       #DSRStBit
SaveCDSt            sta       R$B,x               set 6551 ACIA style DCD/DSR status in caller's [B]
                    puls      cc,dp,pc            restore Carry status, dummy B, system DP, return

BreakSlp            ldx       #SlpBreak           SS.Break duration
                    bra       TimedSlp

HngUpSlp            ldx       #SlpHngUp           SS.HngUp duration
                    bra       TimedSlp

                    ifeq      Level-1
Sleep0              ldx       #$0000
                    bra       TimedSlp
                    endc
Sleep1              ldx       #1                  give up balance of tick
TimedSlp            pshs      cc                  save IRQ enable status
                    andcc     #^Intmasks          enable IRQs
                    os9       F$Sleep
                    puls      cc,pc               restore IRQ enable status, return

SStt                clrb                          default to no error...
                    pshs      cc,dp               save IRQ/Carry status, dummy B, system DP
                    pshs      a
                    tfr       u,d
                    tfr       a,dp
                    puls      a
                    ldx       PD.RGS,y
                    cmpa      #SS.HngUp
                    bne       SetBreak
*                    orcc      #IntMasks           disable IRQs while setting Command register
*                    bsr       HngUpSlp            go sleep for a while...
FRegClr
SetStatExit         puls      cc,dp,pc            restore IRQ/Carry status, dummy B, system DP, return

SetBreak            cmpa      #SS.Break           Tx line break?
                    bne       SetSSig
                    ldx       <V.PORT
                    ldy       #2048
                    orcc      #Intmasks
                    ldb       >WORK_SLOT
                    lda       #$C5			Bank where the WizFi registers are
                    sta       >WORK_SLOT
p@                  lda       WIZFI_UART_RxD_RD_Count,x
                    beq       n@
                    lda       WIZFI_UART_DataReg,x
n@                  leay      -1,y
                    bne       p@
                    stb       >WORK_SLOT
                    orcc      #Intmasks           disable IRQs while messing with flow control flags
                    bsr       BreakSlp            go sleep for a while...
                    bra       SetStatExit         go restore RTS output to previous...

SetSSig             cmpa      #SS.SSig
                    bne       SetRelea
                    pshs      x
                    ldx       <V.PORT
                    orcc      #Intmasks
                    ldb       >WORK_SLOT
                    lda       #$C5			Bank where the WizFi registers are
                    sta       >WORK_SLOT
                    lda       WIZFI_UART_RxD_RD_Count,x
                    stb       >WORK_SLOT
                    puls      x
                    pshs      a
                    lda       PD.CPR,y            current process ID
                    ldb       R$X+1,x             LSB of [X] is signal code
                    tst       ,s+                check RxD buffer length
                    bne       RSendSig
                    std       <SSigPID
                    puls      cc,dp,pc            restore IRQ/Carry status, dummy B, system DP, return
RSendSig            puls      cc                  restore IRQ/Carry status
                    os9       F$Send
                    puls      dp,pc               restore system DP, return

SetRelea            cmpa      #SS.Relea
                    bne       SetCDSig
                    leax      SSigPID,u           point to Rx data signal process ID
                    bsr       ReleaSig            go release signal...
                    puls      cc,dp,pc            restore Carry status, dummy B, system DP, return

SetCDSig            cmpa      #SS.CDSig           set DCD signal?
                    bne       SetCDRel
                    lda       PD.CPR,y            current process ID
                    ldb       R$X+1,x             LSB of [X] is signal code
                    std       <CDSigPID
                    puls      cc,dp,pc            restore Carry status, dummy B, system DP, return

SetCDRel            cmpa      #SS.CDRel           release DCD signal?
                    bne       SetComSt
CDRelSig            leax      CDSigPID,u          point to DCD signal process ID
                    bsr       ReleaSig            go release signal...
                    puls      cc,dp,pc            restore Carry status, dummy B, system DP, return

SetComSt            cmpa      #SS.ComSt
                    bne       SetOpen
                    ldd       R$Y,x               caller's [Y] contains ACIAPAK format type/baud info
                    bsr       SetPort             go save it and set up control/format registers
ReturnOK            puls      cc,dp,pc            restore Carry status, dummy B, system DP, return

SetOpen             cmpa      #SS.Open
                    bne       SetClose
                    lda       R$Y+1,x             get LSB of caller's [Y]
                    deca                          real SS.Open from SCF? (SCF sets LSB of [Y] = 1)
                    bne       ReturnOK            no, go do nothing but return OK...
                    clra
*                    lda       #TIRB.RTS           enabled DTR and RTS outputs
                    orcc      #IntMasks           disable IRQs while setting Format register
                    lbra      FRegClr             go enable DTR and RTS (if not disabled due to Rx flow control)

SetClose            cmpa      #SS.Close
                    lbne      UnSvcErr            no, go report error...
                    lda       R$Y+1,x             real SS.Close from SCF? (SCF sets LSB of [Y] = 0)
                    bne       ReturnOK            no, go do nothing but return OK...
                    leax      SSigPID,u           point to Rx data signal process ID
                    bsr       ReleaSig            go release signal...
                    bra       CDRelSig            go release DCD signal, return from there...

ReleaSig            pshs      cc                  save IRQ enable status
                    orcc      #IntMasks           disable IRQs while releasing signal
                    lda       PD.CPR,y            get current process ID
                    suba      ,x                  same as signal process ID?
                    bne       NoReleas            no, go return...
                    sta       ,x                  clear this signal's process ID
NoReleas            puls      cc,pc               restore IRQ enable status, return

SetPort             pshs      cc                  save IRQ enable and Carry status
                    puls      cc,pc               recover IRQ enable and Carry status, return...


IRQSvc              pshs      dp,x,y,u
                    tfr       u,d                 setup our DP
                    tfr       a,dp
	            lda       VIRQBF+Vi.Stat,U    get status byte 
                    anda      #$FF-Vi.IFlag       mask off interrupt bit 
                    sta	      VIRQBF+Vi.Stat,U    put it back

                    lda       <V.PAGE
                    bita      #%10000000
                    bne       IRQCont             Essentially ignore the interrupt

                    ldx       <V.PORT
                    lda       #$c5
                    ldb       >WORK_SLOT
                    sta       >WORK_SLOT
                    lda       WIZFI_UART_RxD_WR_Count,x
                    stb       >WORK_SLOT
                    tsta
                    beq       IRQExit
IRQCont             clrb                          clear Carry (for exit) and LSB of process descriptor address
                    lda       <V.WAKE             anybody waiting? ([D]=process descriptor address)
                    beq       IRQExit             no, go return...
                ifeq      Level-1
                    clr       <V.WAKE
                    ldb       #S$Wake
                    os9       F$Send
                else
                    stb       <V.WAKE             mark I/O done
                    tfr       d,x                 copy process descriptor pointer
                    lda       P$State,x           get state flags
                    anda      #^Suspend           clear suspend state
                    sta       P$State,x           save state flags
                endc

IRQExit             puls      dp,x,y,u,pc

                    emod
ModSize             equ       *
                    end


