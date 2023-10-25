********************************************************************
* mc6850 Driver
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          ????/??/??
* NitrOS-9 2.00 distribution.
*
*   9r4    2003/01/01  Boisy G. Pitre
* Back-ported to OS-9 Level Two.
*
*  10r1    2003/??/??  Robert Gault
* Added 6809 code where it was lacking.
*
*  10r2    2004/05/03  Boisy G. Pitre
* Fixed numerous issues with 6809 and Level 1 versions.
* Tested 6809 Level 1 and Level 2.
* [NAC HACK 2015Sep08] I should have cloned this to make 6851 version
* and that's what I'll end up doing, reverting this to its former glory.
* I might even need to do 2 versions - one with handshake and one without.

                    nam       mc6850
                    ttl       mc6850 Driver

                    ifp1
                    use       defsfile
;           use   scfdefs
                    endc

* conditional assembly switches
TC9                 set       false               "true" for TC-9 version, "false" for Coco 3

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

                    ifne      mc09
* 6850 registers
                    org       0
StatReg             rmb       1
CtlReg              equ       StatReg
DataReg             rmb       1
                    else
* 6551 register definitions
                    org       0
DataReg             rmb       1                   receive/transmit Data (read Rx / write Tx)
StatReg             rmb       1                   status (read only)
PRstReg             equ       StatReg             programmed reset (write only)
CmdReg              rmb       1                   command (read/write)
CtlReg              rmb       1                   control (read/write)
                    endc

                    ifne      mc09
* Status bit definitions
Stat.IRQ            equ       %10000000           IRQ occurred
Stat.TxE            equ       %00000010           Tx data register Empty
Stat.RxF            equ       %00000001           Rx data register Full
Stat.Ovr            equ       %00100000           Rx data Overrun error
Stat.Frm            equ       %00010000           Rx data Framing error
Stat.Par            equ       %01000000           Rx data Parity error

Stat.Err            equ       Stat.Ovr!Stat.Frm!Stat.Par Status error bits
Stat.Flp            equ       $00                 all Status bits active when set
Stat.Msk            equ       Stat.IRQ!Stat.RxF   active IRQs
                    else
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
                    endc

* Control bit definitions
Ctl.Stop            equ       %10000000           stop bits (set=two, clear=one)
Ctl.DBit            equ       %01100000           see data bit table below
Ctl.RxCS            equ       %00010000           Rx clock source (set=baud rate, clear=external)
Ctl.Baud            equ       %00001111           see baud rate table below

* data bit table
DB.8                equ       %00000000           eight data bits per character
DB.7                equ       %00100000           seven data bits per character
DB.6                equ       %01000000           six data bits per character
DB.5                equ       %01100000           five data bits per character

* baud rate table
                    org       $00
BR.ExClk            rmb       1                   16x external clock (not supported)
                    org       $11
BR.00050            rmb       1                   50 baud (not supported)
BR.00075            rmb       1                   75 baud (not supported)
BR.00110            rmb       1                   109.92 baud
BR.00135            rmb       1                   134.58 baud (not supported)
BR.00150            rmb       1                   150 baud (not supported)
BR.00300            rmb       1                   300 baud
BR.00600            rmb       1                   600 baud
BR.01200            rmb       1                   1200 baud
BR.01800            rmb       1                   1800 baud (not supported)
BR.02400            rmb       1                   2400 baud
BR.03600            rmb       1                   3600 baud (not supported)
BR.04800            rmb       1                   4800 baud
BR.07200            rmb       1                   7200 baud (not supported)
BR.09600            rmb       1                   9600 baud
BR.19200            rmb       1                   19200 baud

* Command bit definitions
Cmd.Par             equ       %11100000           see parity table below
Cmd.Echo            equ       %00010000           local echo (set=activated)
Cmd.TIRB            equ       %00001100           see Tx IRQ/RTS/Break table below
Cmd.RxI             equ       %00000010           Rx IRQ (set=disabled)
Cmd.DTR             equ       %00000001           DTR output (set=enabled)

* parity table
Par.None            equ       %00000000
Par.Odd             equ       %00100000
Par.Even            equ       %01100000
Par.Mark            equ       %10100000
Par.Spac            equ       %11100000

* Tx IRQ/RTS/Break table
TIRB.Off            equ       %00000000           RTS & Tx IRQs disabled
TIRB.On             equ       %00000100           RTS & Tx IRQs enabled
TIRB.RTS            equ       %00001000           RTS enabled, Tx IRQs disabled
TIRB.Brk            equ       %00001100           RTS enabled, Tx IRQs disabled, Tx line Break

* V.ERR bit definitions
DCDLstEr            equ       %00100000           DCD lost error
OvrFloEr            equ       %00000100           Rx data overrun or Rx buffer overflow error
FrmingEr            equ       %00000010           Rx data framing error
ParityEr            equ       %00000001           Rx data parity error

* FloCtlRx bit definitions
FCRxSend            equ       %10000000           send flow control character
FCRxSent            equ       %00010000           Rx disabled due to XOFF sent
FCRxDTR             equ       %00000010           Rx disabled due to DTR
FCRxRTS             equ       %00000001           Rx disabled due to RTS

* FloCtlTx bit definitions
FCTxXOff            equ       %10000000           due to XOFF received
FCTxBrk             equ       %00000010           due to currently transmitting Break

* Wrk.Type bit definitions
Parity              equ       %11100000           parity bits
MdmKill             equ       %00010000           modem kill option
RxSwFlow            equ       %00001000           Rx data software (XON/XOFF) flow control
TxSwFlow            equ       %00000100           Tx data software (XON/XOFF) flow control
RTSFlow             equ       %00000010           CTS/RTS hardware flow control
DSRFlow             equ       %00000001           DSR/DTR hardware flow control

* Wrk.Baud bit definitions
StopBits            equ       %10000000           number of stop bits code
WordLen             equ       %01100000           word length code
BaudRate            equ       %00001111           baud rate code

* Wrk.XTyp bit definitions
SwpDCDSR            equ       %10000000           swap DCD+DSR bits (valid for 6551 only)
ForceDTR            equ       %01000000           don't drop DTR in term routine
RxBufPag            equ       %00001111           input buffer page count

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

regWbuf             rmb       2                   substitute for regW
RxBufDSz            equ       256-.               default Rx buffer gets remainder of page...
RxBuff              rmb       RxBufDSz            default Rx buffer
MemSize             equ       .

rev                 set       2
edition             set       10

                    mod       ModSize,ModName,Drivr+Objct,ReEnt+rev,ModEntry,MemSize

                    fcb       UPDAT.              access mode(s)

ModName             fcs       "mc6850"
                    fcb       edition


* These 3 bytes control how the IRQ ISR processes interrupts from this
* device
IRQPckt             equ       *
Pkt.Flip            fcb       Stat.Flp            flip byte
Pkt.Mask            fcb       Stat.Msk            mask byte
                    fcb       $0A                 priority

BaudTabl            equ       *
                    fcb       BR.00110,BR.00300,BR.00600
                    fcb       BR.01200,BR.02400,BR.04800
                    fcb       BR.09600,BR.19200


* NOTE:  SCFMan has already cleared all device memory except for V.PAGE and
*        V.PORT.  Zero-default variables are:  CDSigPID, CDSigSig, Wrk.XTyp.
* Entry:
* Y = address of the device descriptor
* U = address of the device memory area
*
* Exit:
* CC = carry set on error
* B  = error code
Init                clrb                          default to no error...
                    pshs      cc,dp               save IRQ/Carry status, system DP
                    ifne      H6309
                    tfr       u,w
                    tfr       e,dp
                    tfr       y,w                 save descriptor pointer
                    else
                    tfr       u,d                 get device memory area
                    tfr       a,dp                and make it the direct page
                    pshs      y                   save descriptor pointer
                    endc

* Register the ISR
* D address of the device status register
* X address of the "packet" containing the flip/mask/priority
* Y address of the device IRQ service routine
* U address of the device IRQ service routine memory
                    ldd       <V.PORT             base hardware address (=status register)

                    leax      IRQPckt,pc
                    leay      IRQSvc,pc
                    os9       F$IRQ

                    ifne      H6309
                    tfr       w,y                 recover descriptor pointer
                    else
                    puls      y
                    endc

                    lbcs      ErrExit             failed to register interrupt

DfltInfo            ldd       #RxBufDSz           default Rx buffer size
                    leax      RxBuff,u            default Rx buffer address
                    std       <RxBufSiz           save Rx buffer size
                    stx       <RxBufPtr           save Rx buffer address
                    stx       <RxBufGet           set initial Rx buffer input address
                    stx       <RxBufPut           set initial Rx buffer output address
                    ifne      H6309
                    addr      d,x                 point to end of Rx buffer
                    else
                    leax      d,x
                    endc
                    stx       <RxBufEnd           save Rx buffer end address
                    subd      #80                 characters available in Rx buffer
                    std       <RxBufMax           set auto-XOFF threshold
                    ldd       #10                 characters remaining in Rx buffer
                    std       <RxBufMin           set auto-XON threshold after auto-XOFF
                    ldb       #TIRB.RTS           default command register

NoDTR               ldx       <V.PORT             get port address

                    orcc      #IntMasks           disable IRQs while setting up hardware

* [NAC HACK 2015Sep13] might be a problem that mc09 has no way to flush
* (virtual or real) UART fifos.

*           lda   StatReg,x      ensure old IRQ flags are clear
*           lda   DataReg,x      ensure old error and Rx data IRQ flags are clear
*           lda   StatReg,x      ... again
*           lda   DataReg,x      ... and again

* [NAC HACK 2015Sep13] NOPs are to keep addresses unchanged during debug
                    nop
                    nop
                    nop
                    nop
                    nop
                    nop
                    nop
                    nop
                    lda       StatReg,x           get new Status register contents

* [NAC HACK 2015Sep16]  Enable Rx interrupt
                    ora       #$80
                    sta       StatReg,x

                    sta       <Cpy.Stat           save Status copy
                    tfr       a,b                 copy it...
                    eora      Pkt.Flip,pc         flip bits per D.Poll
                    anda      Pkt.Mask,pc         any IRQ(s) still pending?

* [NAC HACK 2015Sep13] the UART model in exec09 cannot flag rx char available
* so this test will always fail. Even if I could get the i/o there to be non-
* blocking I still can't work out how I could get the UART status register to
* behave correctly.. it would need to support type-ahead.
*           lbne  NRdyErr        yes, go report error... (device not plugged in?)
                    nop
                    nop

                    puls      cc,dp,pc            recover IRQ/Carry status, system DP, return

*
*
Term                clrb                          default to no error...
                    pshs      cc,dp               save IRQ/Carry status, dummy B, system DP
                    ifne      H6309
                    tfr       u,w                 setup our DP
                    tfr       e,dp
                    else
                    tfr       u,d
                    tfr       a,dp
                    endc
                    ifeq      Level-1
                    ldx       >D.Proc
                    lda       P$ID,x
                    sta       <V.BUSY
                    sta       <V.LPRC
                    endc
                    ldx       <V.PORT
                    lda       0,x                 get current status
* [NAC HACK 2015Sep09] ??
                    anda      #^(Cmd.TIRB!Cmd.DTR) disable Tx IRQs, RTS, and DTR
                    ora       #Cmd.RxI            disable Rx IRQs


                    ldd       <RxBufSiz           get Rx buffer size
                    tsta                          less than 256 bytes?
                    beq       TermExit            yes, no system memory to return...
                    pshs      u                   save data pointer
                    ldu       <RxBufPtr           get address of system memory
                    os9       F$SRtMem
                    puls      u                   recover data pointer
TermExit
                    ldd       <V.PORT             base hardware address is status register

                    ldx       #$0000              remove IRQ table entry
                    leay      IRQSvc,pc
                    puls      cc                  recover IRQ/Carry status
                    os9       F$IRQ
                    puls      dp,pc               restore dummy A, system DP, return

ReadSlp
                    ifeq      Level-1
                    lda       <V.BUSY
                    sta       <V.WAKE
                    lbsr      Sleep0              go suspend process...
                    else
                    ldd       >D.Proc             process descriptor address
                    sta       <V.WAKE             save MSB for IRQ service routine
                    tfr       d,x                 copy process descriptor address
                    ifne      H6309
                    oim       #Suspend,P$State,x
                    else
                    ldb       P$State,x
                    orb       #Suspend
                    stb       P$State,x
                    endc
                    lbsr      Sleep1              go suspend process...
                    endc
                    ldx       >D.Proc             process descriptor address
                    ldb       P$Signal,x          pending signal for this process?
                    beq       ChkState            no, go check process state...
                    cmpb      #S$Intrpt           do we honor signal?
                    lbls      ErrExit             yes, go do it...
ChkState            equ       *
                    ifne      H6309
                    tim       #Condem,P$State,x
                    else
                    ldb       P$State,x
                    bitb      #Condem
                    endc
                    bne       PrAbtErr            yes, go do it...
                    ldb       <V.WAKE             true interrupt?
                    beq       ReadChk             yes, go read the char.
                    bra       ReadSlp             no, go suspend the process

*
* Input	U = Address of device static data storage
*	Y = Address of path descriptor module
*
* Output
*	A = Character read
*	CC = carry set on error, clear on none
*	B = error code if CC.C set.
*
Read                clrb                          default to no errors...
                    pshs      cc,dp               save IRQ/Carry status, system DP
                    ifne      H6309
                    tfr       u,w                 setup our DP
                    tfr       e,dp
                    else
                    tfr       u,d
                    tfr       a,dp
                    endc
ReadLoop            orcc      #IntMasks           disable IRQs while checking Rx flow control
ReadChk             lda       <FloCtlRx           get Rx flow control flags
                    beq       ReadChar            none, go get Rx character...
                    ldx       <RxDatLen           get Rx data count again
                    cmpx      <RxBufMin           at or below XON level?
                    bhi       ReadChar            no, go get Rx character...
                    ldx       <V.PORT
                    bita      #FCRxSent           Rx disabled due to XOFF sent?
                    beq       ChkHWHS             no, go check hardware handshake(s)...
                    ldb       <FloCtlTx           get Tx flow control flags
                    bitb      #FCTxBrk            currently transmitting line Break?
                    beq       NotTxBrk            yes, go skip XON this time...
ReadLp2             andcc     #^IntMasks          turn interupts back on
                    bra       ReadLoop
NotTxBrk            equ       *
                    ifne      H6309
                    tim       #Stat.TxE,StatReg,x
                    else
                    pshs      a
                    lda       StatReg,x
                    bita      #Stat.TxE
                    puls      a
                    endc
                    beq       ReadLp2             no, go skip XON this time...
                    ldb       <V.XON
                    stb       DataReg,x           write XON character
ChkHWHS             bita      #FCRxDTR!FCRxRTS    Rx disabled due to DTR or RTS?
                    beq       RxFloClr            no, go clear Rx flow control flag(s)...
*           ldb   CmdReg,x       get current Command register contents
                    ldb       #0
                    andb      #^Cmd.TIRB          clear Tx IRQ/RTS/Break control bits
                    orb       #TIRB.RTS!Cmd.DTR   enable RTS and DTR, disable Tx IRQs
*           stb   CmdReg,x       set Command register
RxFloClr            clr       <FloCtlRx           clear Rx flow control flags
ReadChar            ldb       <V.ERR              get accumulated errors, if any
                    stb       PD.ERR,y            set/clear error(s) in path descriptor
                    bne       ReprtErr            error(s), go report it/them...
                    ldd       <RxDatLen           get Rx buffer count
                    beq       ReadSlp             none, go sleep while waiting for new Rx data...
                    ifne      H6309
                    decd      less                character we're about to grab
                    else
                    subd      #$0001
                    endc
                    std       <RxDatLen           save new Rx data count
                    orcc      #IntMasks           see if this fixes the problem
                    ldx       <RxBufGet           current Rx buffer pickup position
                    lda       ,x+                 get Rx character, set up next pickup position
                    cmpx      <RxBufEnd           end of Rx buffer?
                    blo       SetPckUp            no, go keep pickup pointer
                    ldx       <RxBufPtr           get Rx buffer start address
SetPckUp            stx       <RxBufGet           set new Rx data pickup pointer
                    puls      cc,dp,pc            recover IRQ/Carry status, dummy B, system DP, return

*
* Module jump table
*
ModEntry            lbra      Init
                    bra       Read
                    nop
                    bra       Write
                    nop
                    ifne      H6309
                    bra       GStt
                    nop
                    else
                    lbra      GStt
                    endc
                    lbra      SStt
                    lbra      Term

PrAbtErr            ldb       #E$PrcAbt
                    bra       ErrExit

ReprtErr            clr       <V.ERR              clear error status
                    bitb      #DCDLstEr           DCD lost error?
                    bne       HngUpErr            yes, go report it...
                    ldb       #E$Read

* come here with cc, dp, pc stacked.
* set carry in the stacked copy of cc and return.
ErrExit             equ       *
                    ifne      H6309
                    oim       #Carry,,s           set carry
                    else
                    lda       ,s
                    ora       #Carry
                    sta       ,s
                    endc
                    puls      cc,dp,pc            restore CC, system DP, return

HngUpErr            ldb       #E$HangUp
                    lda       #PST.DCD            DCD lost flag
                    sta       PD.PST,y            set path status flag
                    bra       ErrExit

NRdyErr             ldb       #E$NotRdy
                    bra       ErrExit

UnSvcErr            ldb       #E$UnkSvc
                    bra       ErrExit

*
*
Write               clrb                          default to no error...
                    pshs      cc,dp               save IRQ/Carry status, Tx character, system DP
                    ifne      H6309
                    tfr       u,w                 setup our DP
                    tfr       e,dp
                    tfr       a,e
                    else
                    pshs      a
                    tfr       u,d
                    tfr       a,dp
                    puls      a
                    sta       <regWbuf
                    endc
                    orcc      #IntMasks           disable IRQs during error and Tx disable checks
                    bra       WritChr
WritLoop            lda       <WritFlag
                    beq       WritFast
                    lbsr      Sleep1
WritFast            inc       <WritFlag
WritChr             ldx       <V.PORT
                    ldb       <V.ERR              get accumulated errors, if any
                    andb      #DCDLstEr           DCD lost error? (ignore other errors, if any)
                    stb       PD.ERR,y            set/clear error(s) in path descriptor
                    bne       ReprtErr            DCD lost error, go report it...
ChkTxFlo            ldb       <FloCtlTx           get Tx flow control flags
                    bitb      #FCTxBrk            currently transmitting line Break?
                    bne       WritLoop            yes, go sleep a while...
                    lda       <Wrk.Type           get software/hardware handshake enables
                    bita      #DSRFlow            DSR/DTR handshake enabled?
* Changed below - BGP
*           beq   ChkTxFlo       no, go check Tx flow control
                    beq       ChkRxFlo            no, go check Rx flow control
                    ldb       <Cpy.Stat           get copy of status register
                    bitb      <Mask.DSR           Tx disabled due to DSR?
                    bne       WritLoop            yes, go sleep a while...
                    bita      #TxSwFlow           Tx software flow control enabled?
                    beq       ChkRxFlo            no, go check pending Rx flow control
                    bitb      #FCTxXOff           Tx disabled due to received XOFF?
                    bne       WritLoop            yes, go sleep a while...
ChkRxFlo            bita      #RxSwFlow           Rx software flow control enabled?
                    beq       ChkTxE              no, go check Tx register empty
                    ldb       <FloCtlRx           get Rx flow control flags
                    bitb      #FCRxSend           XON/XOFF Rx flow control pending?
                    bne       WritLoop            yes, go sleep a while...
ChkTxE              equ       *
                    ifne      H6309
                    tim       #Stat.TxE,StatReg,x
                    else
                    pshs      a
                    lda       StatReg,x
                    bita      #Stat.TxE
                    puls      a
                    endc
                    beq       WritLoop            no, go sleep a while...
                    ifne      H6309
                    ste       DataReg,x           write Tx character
                    else
                    ldb       <regWbuf
                    stb       DataReg,x
                    endc
                    clr       <WritFlag           clear "initial write attempt" flag
                    puls      cc,dp,pc            recover IRQ/Carry status, Tx character, system DP, return

GStt                clrb                          default to no error...
                    pshs      cc,dp               save IRQ/Carry status, dummy B, system DP
                    ifne      H6309
                    tfr       u,w                 setup our DP
                    tfr       e,dp
                    else
                    pshs      a
                    tfr       u,d
                    tfr       a,dp
                    puls      a
                    endc
                    ldx       PD.RGS,y            caller's register stack pointer
                    cmpa      #SS.EOF
                    beq       GSExitOK            yes, SCF devices never return EOF
                    cmpa      #SS.Ready
                    bne       GetScSiz
                    ldd       <RxDatLen           get Rx data length
                    beq       NRdyErr             none, go report error
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
                    ifne      H6309
                    tfr       u,w                 setup our DP
                    tfr       e,dp
                    else
                    pshs      a
                    tfr       u,d
                    tfr       a,dp
                    puls      a
                    endc
                    ldx       PD.RGS,y
                    cmpa      #SS.HngUp
                    bne       SetBreak
                    lda       #^Cmd.DTR           cleared (disabled) DTR bit
                    ldx       <V.PORT
                    orcc      #IntMasks           disable IRQs while setting Command register
*           anda  CmdReg,x       mask in current Command register contents
*           sta   CmdReg,x       set new Command register
                    bsr       HngUpSlp            go sleep for a while...
BreakClr            lda       #^(Cmd.TIRB!Cmd.DTR) clear (disable) DTR and RTS control bits
FRegClr             ldx       <V.PORT
*           anda  CmdReg,x       mask in current Command register
                    ldb       <FloCtlRx           get Rx flow control flags
                    bitb      #FCRxDTR            Rx disabled due to DTR?
                    bne       LeaveDTR            yes, go leave DTR disabled
                    ora       #Cmd.DTR            set (enable) DTR bit
LeaveDTR            bitb      #FCRxRTS            Rx disabled due to RTS?
                    bne       LeaveRTS            yes, go leave RTS disabled
                    ora       #TIRB.RTS           enable RTS output
LeaveRTS            ldb       <FloCtlTx           get Tx flow control flags
                    bitb      #FCTxBrk            currently transmitting line Break?
                    beq       NoTxBrk             no, go leave RTS alone...
                    ora       #TIRB.Brk           set Tx Break bits
NoTxBrk
*           sta   CmdReg,x       set new Command register
                    puls      cc,dp,pc            restore IRQ/Carry status, dummy B, system DP, return

SetBreak            cmpa      #SS.Break           Tx line break?
                    bne       SetSSig
                    ldy       <V.PORT
                    ldd       #FCTxBrk*256+TIRB.Brk [A]=flow control flag, [B]=Tx break enable
                    orcc      #Intmasks           disable IRQs while messing with flow control flags
                    ora       <FloCtlTx           set Tx break flag bit
                    sta       <FloCtlTx           save Tx flow control flags
*           orb   CmdReg,y       set Tx line break bits
*           stb   CmdReg,y       start Tx line break
                    bsr       BreakSlp            go sleep for a while...
                    anda      #^FCTxBrk           clear Tx break flag bit
                    sta       <FloCtlTx           save Tx flow control flags
*           clr   CmdReg,y       clear Tx line break
                    bra       BreakClr            go restore RTS output to previous...

SetSSig             cmpa      #SS.SSig
                    bne       SetRelea
                    lda       PD.CPR,y            current process ID
                    ldb       R$X+1,x             LSB of [X] is signal code
                    orcc      #IntMasks           disable IRQs while checking Rx data length
                    ldx       <RxDatLen
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
*           bsr   SetPort        go save it and set up control/format registers
ReturnOK            puls      cc,dp,pc            restore Carry status, dummy B, system DP, return

SetOpen             cmpa      #SS.Open
                    bne       SetClose
                    lda       R$Y+1,x             get LSB of caller's [Y]
                    deca                          real SS.Open from SCF? (SCF sets LSB of [Y] = 1)
                    bne       ReturnOK            no, go do nothing but return OK...
                    lda       #TIRB.RTS           enabled DTR and RTS outputs
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


* Interrupt service routine
IRQSvc
                    pshs      dp                  save system DP
                    ifne      H6309
                    tfr       u,w                 setup our DP
                    tfr       e,dp
                    else
                    tfr       u,d                 setup our DP
                    tfr       a,dp
                    endc

                    ldx       <V.PORT
                    ldb       StatReg,x           get current Status register contents
                    stb       <Cpy.Stat           save Status register copy
                    bitb      #Stat.Err           error(s)?
                    beq       ChkRDRF             no, go check Rx data
* Error-handling
                    tst       DataReg,x           read Rx data register to clear ACIA error flags
                    bitb      #Stat.Frm           framing error (assume Rx line Break)?
                    beq       ChkParty            no, go check if parity error...
                    lda       <V.QUIT             default to keyboard quit ("Break") code
                    bra       RxBreak             go pretend we've received V.QUIT character...

ChkParty            bitb      #Stat.Par           parity error?
                    beq       ChkOvRun            no, go check overrun error...
                    lda       #ParityEr           mark parity error
ChkOvRun            bita      #Stat.Ovr           overrun error?
                    beq       SaveErrs            no, go save errors...
                    ora       #OvrFloEr           mark overrun error
SaveErrs            ora       <V.ERR
                    sta       <V.ERR
                    lbra      ChkTrDCD            go check if DCD transition...

* Read data?
ChkRDRF             bitb      #Stat.RxF           Rx data?
                    lbeq      ChkTrDCD            no, go check DCD transition
                    lda       DataReg,x           get Rx data
RxBreak             beq       SavRxDat            its a null, go save it...
                    clr       <SigSent
                    cmpa      <V.INTR             interrupt?
                    bne       Chk.Quit            no, go on...
                    ldb       #S$Intrpt
                    bra       SendSig

Chk.Quit            cmpa      <V.QUIT             abort?
                    bne       Chk.PChr            no, go on...
                    ldb       #S$Abort
SendSig             pshs      a                   save Rx data
                    lda       <V.LPRC             get last process' ID
                    os9       F$Send
                    puls      a                   recover Rx data
                    stb       <SigSent            set signal sent flag
                    bra       SavRxDat            go save Rx data...

Chk.PChr            cmpa      <V.PCHR             pause?
                    bne       Chk.Flow            no, go on...
                    ldx       <V.DEV2             attached device defined?
                    beq       SavRxDat            no, go save Rx data...
                    sta       V.PAUS,x            yes, pause attached device
                    bra       SavRxDat            go save Rx data...

Chk.Flow            equ       *
                    ifne      H6309
                    tim       #TxSwFlow,<Wrk.Type Tx data software flow control enabled?
                    else
                    pshs      a
                    lda       #TxSwFlow
                    bita      <Wrk.Type
                    puls      a
                    endc
                    beq       SavRxDat            no, go save Rx data...
                    cmpa      <V.XON              XON?
                    bne       Chk.XOff            no, go on...
                    ifne      H6309
                    aim       #^FCTxXOff,<FloCtlTx clear XOFF received bit
                    else
                    pshs      a
                    lda       #^FCTxXOff
                    anda      <FloCtlTx
                    sta       <FloCtlTx
                    puls      a
                    endc
                    bra       SetTxFlo            go save new Tx flow control flags...

Chk.XOff            cmpa      <V.XOFF             XOFF?
                    bne       SavRxDat            no, go save Rx data...
                    ldb       #FCTxXOff           set XOFF received bit
                    orb       <FloCtlTx           set software Tx flow control flag
SetTxFlo            stb       <FloCtlTx           save new Tx flow control flags
                    lbra      ChkTrDCD            go check DCD transition...
SavRxDat            equ       *
                    ifne      H6309
                    aim       #^FCRxSend,<FloCtlRx clear possible pending XOFF flag
                    else
                    pshs      a
                    lda       #^FCRxSend
                    anda      <FloCtlRx
                    sta       <FloCtlRx
                    puls      a
                    endc
                    ldx       <RxBufPut           get Rx buffer input pointer
                    ifne      H6309
                    ldw       <RxDatLen           Rx get Rx buffer data length
                    cmpw      <RxBufSiz           Rx buffer already full?
                    else
                    pshs      d
                    ldd       <RxDatLen
                    std       <regWbuf
                    cmpd      <RxBufSiz
                    puls      d
                    endc
                    blo       NotOvFlo            no, go skip overflow error...
                    ifne      H6309
                    oim       #OvrFloEr,<V.ERR    mark RX buffer overflow error
                    else
                    ldb       #OvrFloEr
                    orb       <V.ERR
                    stb       <V.ERR
                    endc
                    bra       DisRxFlo            go ensure Rx is disabled (if possible)

NotOvFlo            sta       ,x+                 save Rx data
                    cmpx      <RxBufEnd           end of Rx buffer?
                    blo       SetLayDn            no, go keep laydown pointer
                    ldx       <RxBufPtr           get Rx buffer start address
SetLayDn            stx       <RxBufPut           set new Rx data laydown pointer
                    ifne      H6309
                    incw                          one more byte in Rx buffer
                    stw       <RxDatLen           save new Rx data length
                    cmpw      <RxBufMax           at or past maximum fill point?
                    else
                    pshs      d
                    ldd       <regWbuf
                    addd      #1
                    std       <regWbuf
                    std       <RxDatLen
                    cmpd      <RxBufMax
                    puls      d
                    endc
                    blo       SgnlRxD             no, go check Rx data signal...
DisRxFlo            ldx       <V.PORT
*           ldb   CmdReg,x       get current Command register contents
                    ifne      H6309
                    tim       #ForceDTR,<Wrk.XTyp forced DTR?
                    else
                    lda       #ForceDTR
                    bita      <Wrk.XTyp
                    endc
                    bne       DisRxRTS            yes, go check RTS disable...
                    ifne      H6309
                    tim       #DSRFlow,<Wrk.Type  DSR/DTR Flow control?
                    else
                    lda       #DSRFlow
                    bita      <Wrk.Type
                    endc
                    beq       DisRxRTS            no, go check RTS disable
                    ifne      H6309
                    oim       #FCRxDTR,<Wrk.Type  mark RX disabled due to DTR
                    else
                    lda       #FCRxDTR
                    ora       <Wrk.Type
                    sta       <Wrk.Type
                    endc
                    andb      #^Cmd.DTR           clear (disable) DTR bit
DisRxRTS            equ       *
                    ifne      H6309
                    tim       #RTSFlow,<Wrk.Type
                    else
                    lda       #RTSFlow
                    bita      <Wrk.Type
                    endc
                    beq       NewRxFlo            no, go set new Rx flow control...
                    ifne      H6309
                    tim       #DSRFlow,<Wrk.Type  line break?
                    else
                    lda       #DSRFlow
                    bita      <Wrk.Type
                    endc
                    bne       NewRxFlo            yes, go set new Rx flow control...
                    ifne      H6309
                    oim       #FCRxRTS,<FloCtlRx
                    else
                    lda       #FCRxRTS
                    ora       <FloCtlRx
                    sta       <FloCtlRx
                    endc
                    andb      #^Cmd.TIRB          clear Tx IRQ/RTS/Break control bits (disable RTS)
NewRxFlo
*           stb   CmdReg,x       set/clear DTR and RTS in Command register
                    ifne      H6309
                    tim       #RxSwFlow,<Wrk.Type Rx software flow control?
                    else
                    ldb       <Wrk.Type
                    bitb      #RxSwFlow
                    endc
                    beq       SgnlRxD             no, go check Rx data signal...
                    lda       <V.XOFF             XOFF character defined?
                    beq       SgnlRxD             no, go check Rx data signal...
                    ldb       <FloCtlRx           get Rx flow control flags
                    bitb      #FCRxSent           XOFF already sent?
                    bne       SgnlRxD             yes, go check Rx data signal...
                    orb       #FCRxSend           set send XOFF flag
                    stb       <FloCtlRx           set new Rx flow control flags
                    ifne      H6309
                    tim       #Stat.TxE,StatReg,x
                    else
                    ldb       StatReg,x
                    bitb      #Stat.TxE
                    endc
                    beq       SgnlRxD             no, go skip XOFF this time...
                    sta       DataReg,x           write XOFF character
                    ldb       #FCRxSent           set XOFF sent flag
                    orb       <FloCtlRx           mask in current Rx flow control flags
                    andb      #^FCRxSend          clear send XOFF flag
                    stb       <FloCtlRx           save new flow control flags
SgnlRxD             ldb       <SigSent            already sent abort/interrupt signal?
                    bne       ChkTrDCD            yes, go check DCD transition...
                    lda       <SSigPID            Rx data signal process ID?
                    beq       ChkTrDCD            none, go check DCD transition...
                    stb       <SSigPID            clear Rx data signal
                    ldb       <SSigSig            Rx data signal code
                    os9       F$Send
ChkTrDCD            ldx       <V.PORT
                    lda       <Cpy.Stat           get Status register copy
                    tfr       a,b                 copy it...
                    eora      <CpyDCDSR           mark changes from old DSR+DCD status copy
*           andb  #Stat.DSR!Stat.DCD clear all but DSR+DCD status
                    stb       <CpyDCDSR           save new DSR+DCD status copy
                    bita      <Mask.DCD           DCD transition?
                    beq       CkSuspnd            no, go check for suspended process...
                    bitb      <Mask.DCD           DCD disabled now?
                    beq       SgnlDCD             no, go check DCD signal...
                    lda       <Wrk.Type
                    bita      #MdmKill            modem kill enabled?
                    beq       SgnlDCD             no, go on...
                    ldx       <V.PDLHd            path descriptor list header
                    beq       StCDLost            no list, go set DCD lost error...
                    lda       #PST.DCD            DCD lost flag
PDListLp            sta       PD.PST,x            set path status flag
                    ldx       PD.PLP,x            get next path descriptor in list
                    bne       PDListLp            not end of list, go do another...
StCDLost            lda       #DCDLstEr           DCD lost error flag
                    ora       <V.ERR
                    sta       <V.ERR
SgnlDCD             lda       <CDSigPID           get process ID, send a DCD signal?
                    beq       CkSuspnd            no, go check for suspended process...
                    ldb       <CDSigSig           get DCD signal code
                    clr       <CDSigPID           clear DCD signal
                    os9       F$Send

CkSuspnd            clrb                          clear Carry (for exit) and LSB of process descriptor address
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
IRQExit             puls      dp,pc               recover system DP, return...

                    emod
ModSize             equ       *
                    end

