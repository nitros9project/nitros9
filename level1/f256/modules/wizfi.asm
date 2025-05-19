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

** $0000: R/W - Control Register ; Only bit[0] is used 
**         0: Low Speed (115K) 1: Hi-Speed (2M) 
** $0001: R/W - FIFO Port (input/output)

** ; This is the number of Byte in the FIFO to be Read
** 00000CCC_CCCCCCCC  16-bit count
** $0002: WIFI_UART_RxD_RD_Count[7:0]
** $0003: {5'b0_0000, WIFI_UART_RxD_RD_Count[10:8]}

** ; The is the number of byte has been written by the Module in the FIFO to be read by CPU
** 00000CCC_CCCCCCCC  16-bit count
** $0004: WIFI_UART_RxD_WR_Count[7:0]      <<<< This is the one you know how many bytes to read from the MODULE
** $0005: {5'b0_0000, WIFI_UART_RxD_WR_Count[10:8]}

** ; This is the number of Byte in the FIFO to be Read by the MODULE
** 00000CCC_CCCCCCCC  16-bit count
** $0006: WIFI_UART_TxD_RD_Count[7:0]
** $0007: {5'b0_0000, WIFI_UART_RxD_RD_Count[10:8]} 

** ; This is the number of Byte the CPU has written in the FIFO to be sent to MODULE
** 00000CCC_CCCCCCCC  16-bit count
** $0008: WIFI_UART_TxD_WR_Count[7:0]      
** $0009: {5'b0_0000, WIFI_UART_RxD_WR_Count[10:8]}

** By the way, I put both counts of both sides of both FIFO (1xRxD, 1xTxD) In reality the RxD side ought to report the same number if you take the RD side as opposed to the WR side.
** Bottom line, there is only one Count you need and it is the RxD FIFO...
** There is no Empty Flag in the Control Register to be read as a status, only the count registers will tell you how many bytes are present in the FIFO. the FIFOs are both 2K deep btw

* The F256 has the WizFi registers in bank $C5/$0040 which we map in at $4000 (MMU_SLOT_2)
WIZFI.Base equ $4040
WIZFI_UART_CtrlReg equ WIZFI.Base+0
WIZFI_UART_DataReg equ WIZFI.Base+1
WIZFI_UART_RxD_RD_Count equ WIZFI.Base+2
WIZFI_UART_RxD_WR_Count equ WIZFI.Base+4
WIZFI_UART_TxD_RD_Count equ WIZFI.Base+6
WIZFI_UART_TxD_WR_Count equ WIZFI.Base+8


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
VIRQBF              rmb       5                   buffer for VIRQ
LastRxCount         rmb       1

* Moved Old 6551 register definitions into var space for simulation
*                    org       0
DataReg             rmb       1                   receive/transmit Data (read Rx / write Tx)
StatReg             rmb       1                   status (read only)
PRstReg             equ       StatReg             programmed reset (write only)
CmdReg              rmb       1                   command (read/write)
CtlReg              rmb       1                   control (read/write)


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

SlotSlct            fcb       $FF                 disable MPI slot selection


BaudTabl            equ       *
                    fcb       BR.00110,BR.00300,BR.00600
                    fcb       BR.01200,BR.02400,BR.04800
                    fcb       BR.09600,BR.19200

DMSK     fcb 0                 no flip bits
         fcb Vi.IFlag          polling mask for VIRG
         fcb 10                priority
* NOTE:  SCFMan has already cleared all device memory except for V.PAGE and
*        V.PORT.  Zero-default variables are:  CDSigPID, CDSigSig, Wrk.XTyp.
Init                clrb                          default to no error...
                    pshs      cc,dp               save IRQ/Carry status, system DP
                    tfr       u,d
                    tfr       a,dp
                    pshs      y			save Y so it's last on stack so we can recall it using 0,s

                pshs	x
                ldx	>WORK_SLOT
                ldd	#$00C5		  reg.B = Bank where the WizFi registers are
                stb	>WORK_SLOT
* Bit #0 of the Control Register is the Speed Mode, where
* 0 = 115200 bps (aka Slow mode)
* 1 = 921600 bps (aka Fast mode) doesn't appear to work at this time
                sta	>WIZFI_UART_CtrlReg
*                ldy	#2048
*p@      	ldb	>WIZFI_UART_DataReg
*                leay	-1,y
*                bne	p@
                stx	>WORK_SLOT
                puls	x

* set up IRQ table entry first
* NOTE: uses the status register of the VIRQ buffer for
* the interrupt status register since no hardware status 
* register is available

                    leay	VIRQBF+Vi.Stat,U get address of status byte
                    tfr         y,d               put it into D reg
                    leay	IRQSvc,PCR         get address of interrupt routine 
                    leax	DMSK,PCR         get VIRQ mask info
                    os9         F$IRQ             install onto table
                    lbcs	INIT9             exit on error

        * now set up the VIRQ table entry
                    leay	VIRQBF,U         point to the S-byte packet
                    lda         #$80              get the reset flag to repeat VIRQ's
                    sta	Vi.Stat,y         save it in the buffer
                    ldd	#VIRQCNT          get the VIRQ counter value
                    std	Vi.Rst,y          save it in the reset area of buffer 
                    ldx	#1                code to install the VIRQ
                    os9	F$VIRQ            install on the table
                    lbcs	INIT9             exit on error

	            ldy       ,s
                    ldb       M$Opt,y             get option size
                    cmpb      #IT.XTYP-IT.DTP     room for extended type byte?
                    bls       DfltInfo            no, go use defaults...
                    ldd       #Stat.DCD*256+Stat.DSR default (unswapped) DCD+DSR masks
                    tst       IT.XTYP,y           check extended type byte for swapped DCD & DSR bits
                    bpl       NoSwap              no, go skip swapping them...
                    exg       a,b                 swap to DSR+DCD masks
NoSwap              std       <Mask.DCD           save DCD+DSR (or DSR+DCD) masks
                    lda       IT.XTYP,y           get extended type byte
                    sta       <Wrk.XTyp           save it
                    anda      #RxBufPag           clear all but Rx buffer page count bits
                    beq       DfltInfo            none, go use defaults...
                    clrb                          make data size an even number of pages
                    pshs      u
                    os9       F$SRqMem            get extended buffer
                    tfr       u,x                 copy address
                    puls      u
                    lbcs      TermExit            error, go remove IRQ entry and exit...
                    bra       SetRxBuf
DfltInfo            ldd       #RxBufDSz           default Rx buffer size
                    leax      RxBuff,u            default Rx buffer address
SetRxBuf            std       <RxBufSiz           save Rx buffer size
                    stx       <RxBufPtr           save Rx buffer address
                    stx       <RxBufGet           set initial Rx buffer input address
                    stx       <RxBufPut           set initial Rx buffer output address
                    leax      d,x
                    stx       <RxBufEnd           save Rx buffer end address
                    subd      #80                 characters available in Rx buffer
                    std       <RxBufMax           set auto-XOFF threshold
                    ldd       #10                 characters remaining in Rx buffer
                    std       <RxBufMin           set auto-XON threshold after auto-XOFF
                    ldb       #TIRB.RTS           default command register
                    lda       #ForceDTR
                    bita      <Wrk.XTyp
                    beq       NoDTR               no, don't enable DTR yet
                    orb       #Cmd.DTR            set (enable) DTR bit
NoDTR               ldx       <V.PORT             get port address
                    stb       <CmdReg		*,x            set new command register
                    ldd       IT.PAR,y            [A] = IT.PAR, [B] = IT.BAU from descriptor
                    lbsr      SetPort             go save it and set up control/format registers
                    orcc      #IntMasks           disable IRQs while setting up hardware
*                    ifgt      Level-1
*                    lda       #IRQBit             get GIME IRQ bit to use
*                    ora       >D.IRQER            mask in current GIME IRQ enables
*                    sta       >D.IRQER            save GIME CART* IRQ enable shadow register
*                    sta       >IrqEnR             enable GIME CART* IRQs
*                    endc
*                    lda       StatReg,x           get new Status register contents
                    lda       #Stat.DCD                 fake status for 6551 DCD *************************************************************
                    sta       <Cpy.Stat           save Status copy
                    tfr       a,b                 copy it...
*                    eora      Pkt.Flip,pc         flip bits per D.Poll
*                    anda      Pkt.Mask,pc         any IRQ(s) still pending?
*                    lbne      NRdyErr             yes, go report error... (device not plugged in?)
                    andb      #Stat.DSR!Stat.DCD  clear all but DSR+DCD status
                    stb       <CpyDCDSR           save new DCD+DSR status copy


INIT9	puls	y
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
                    ldx       <V.PORT
                    lda       <CmdReg		*CmdReg,x            get current Command register contents
                    anda      #^(Cmd.TIRB!Cmd.DTR) disable Tx IRQs, RTS, and DTR
                    ora       #Cmd.RxI            disable Rx IRQs
                    ldb       <Wrk.XTyp           get extended type byte
                    andb      #ForceDTR           forced DTR?
                    beq       KeepDTR             no, go leave DTR disabled...
                    ora       #Cmd.DTR            set (enable) DTR bit
KeepDTR             sta       <CmdReg		*CmdReg,x            set DTR and RTS enable/disable
                    ldd       <RxBufSiz           get Rx buffer size
                    tsta                          less than 256 bytes?
                    beq       TermExit            yes, no system memory to return...
                    pshs      u                   save data pointer
                    ldu       <RxBufPtr           get address of system memory
                    os9       F$SRtMem
                    puls      u                   recover data pointer
TermExit
                    ifeq      Level-1
                    ldd       <orgDFIRQ
                    std       >D.FIRQ
                    endc
                    ldd       <V.PORT             base hardware address is status register
                    addd      #$0001

* remove from VIRQ table first
         ldx #0               get zero to remove from table
         leay VIRQBF,U        get address of packet 
         os9 F$VIRQ
* then remove from IRQ table
         ldx #0               get zero to remove from table
         os9 F$IRQ

                    puls      cc                  recover IRQ/Carry status
                    puls      dp,pc               restore dummy A, system DP, return

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
                    lbls      ErrExit             yes, go do it...
ChkState            equ       *
                    ldb       P$State,x
                    bitb      #Condem
                    lbne       PrAbtErr            yes, go do it...
                    ldb       <V.WAKE             true interrupt?
                    beq       ReadChar             yes, go read the char.
                    bra       ReadSlp             no, go suspend the process

Read                clrb                          default to no errors...
                    pshs      cc,dp               save IRQ/Carry status, system DP
                    tfr       u,d
                    tfr       a,dp
ReadChar
	ldb	>WORK_SLOT
   	lda	#$C5			Bank where the WizFi registers are
	sta	>WORK_SLOT
	lda	>WIZFI_UART_RxD_WR_Count
        sta	<RxDatLen+1
	clr	<RxDatLen
	stb	>WORK_SLOT

        ldx	<RxDatLen	           how many RxD FIFO bytes ready?
        lbeq    ReadSlp             none, go sleep while waiting for new Rx data...

	ldb	>WORK_SLOT
   	lda	#$C5			Bank where the WizFi registers are
	sta	>WORK_SLOT
	lda	>WIZFI_UART_DataReg
	stb	>WORK_SLOT

ReadExit        puls      cc,dp,pc            recover IRQ/Carry status, dummy B, system DP, return

PrAbtErr            ldb       #E$PrcAbt
                    bra       ErrExit

ReprtErr            clr       <V.ERR              clear error status
                    bitb      #DCDLstEr           DCD lost error?
                    bne       HngUpErr            yes, go report it...
                    ldb       #E$Read
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

Write               clrb                          default to no error...
                    pshs      cc,dp               save IRQ/Carry status, Tx character, system DP
                    pshs      a
                    tfr       u,d
                    tfr       a,dp
                    puls      a
                    orcc      #IntMasks           disable IRQs during error and Tx disable checks

	pshs	x,b
	ldx	>WORK_SLOT
   	ldb	#$C5			Bank where the WizFi registers are
	stb	>WORK_SLOT
	sta	>WIZFI_UART_DataReg
	stx	>WORK_SLOT
	puls	b,x

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

        orcc #Intmasks
	pshs	x,b
	ldx	>WORK_SLOT
   	ldb	#$C5			Bank where the WizFi registers are
	stb	>WORK_SLOT
        clra
	ldb	>WIZFI_UART_RxD_WR_Count
        std     <RxDatLen
	stx	>WORK_SLOT
	puls	b,x

                    ldd       <RxDatLen           get Rx data length
                    lbeq       NRdyErr             none, go report error
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
                    lda       #^Cmd.DTR           cleared (disabled) DTR bit
                    ldx       <V.PORT
                    orcc      #IntMasks           disable IRQs while setting Command register
                    anda      <CmdReg		*CmdReg,x            mask in current Command register contents
                    sta       <CmdReg		*CmdReg,x            set new Command register
                    bsr       HngUpSlp            go sleep for a while...
BreakClr            lda       #^(Cmd.TIRB!Cmd.DTR) clear (disable) DTR and RTS control bits
FRegClr             ldx       <V.PORT
                    anda      <CmdReg		*CmdReg,x            mask in current Command register
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
NoTxBrk             sta       <CmdReg		*CmdReg,x            set new Command register
                    puls      cc,dp,pc            restore IRQ/Carry status, dummy B, system DP, return

SetBreak            cmpa      #SS.Break           Tx line break?
                    bne       SetSSig
                    ldy       <V.PORT
                    ldd       #FCTxBrk*256+TIRB.Brk [A]=flow control flag, [B]=Tx break enable
                    orcc      #Intmasks           disable IRQs while messing with flow control flags
                    ora       <FloCtlTx           set Tx break flag bit
                    sta       <FloCtlTx           save Tx flow control flags
                    orb       <CmdReg		*CmdReg,y            set Tx line break bits
                    stb       <CmdReg		*CmdReg,y            start Tx line break
                    bsr       BreakSlp            go sleep for a while...
                    anda      #^FCTxBrk           clear Tx break flag bit
                    sta       <FloCtlTx           save Tx flow control flags
                    clr       <CmdReg		*CmdReg,y            clear Tx line break
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
                    bsr       SetPort             go save it and set up control/format registers
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

SetPort             pshs      cc                  save IRQ enable and Carry status
                    orcc      #IntMasks           disable IRQs while setting up ACIA registers
                    std       <Wrk.Type           save type/baud in data area
                    leax      BaudTabl,pc
                    andb      #BaudRate           clear all but baud rate bits
                    ldb       b,x                 get baud rate setting
                    stb       <regWbuf
                    ldb       <Wrk.Baud           get baud info again
                    andb      #^(Ctl.RxCS!Ctl.Baud) clear clock source + baud rate code bits
                    orb       <regWbuf
                    ldx       <V.PORT             get port address
                    anda      #Cmd.Par            clear all except parity bits
                    sta       <regWbuf
                    lda       <CmdReg		*CmdReg,x            get current command register contents
                    anda      #^Cmd.Par           clear parity control bits
                    ora       <regWbuf
                    std       <CmdReg		*CmdReg,x            set command+control registers
                    puls      cc,pc               recover IRQ enable and Carry status, return...


* The purpose of IRQSvc is not to hog the CPU and perform things that the software should be doing.
* What the 6551 and 6850 drivers are doing is insanity.
IRQSvc
                    pshs      dp                  save system DP
                    tfr       u,d                 setup our DP
                    tfr       a,dp

	            lda       VIRQBF+Vi.Stat,U  get status byte 
                    anda      #$FF-Vi.IFlag    mask off interrupt bit 
                    sta	      VIRQBF+Vi.Stat,U  put it back

ChkRDRF             pshs      x,b
                    ldx       >WORK_SLOT
                    lda       #$C5		Bank where the WizFi registers are
                    sta       >WORK_SLOT
                    clra
                    ldb       >WIZFI_UART_RxD_WR_Count
                    beq       noWiz
                    stx       >WORK_SLOT
	            puls      x,b
                    bra       CkSuspnd

noWiz               stx       >WORK_SLOT
	            puls      x,b
                    bra       IRQExit

CkSuspnd            clrb                          clear Carry (for exit) and LSB of process descriptor address
                    lda       <V.WAKE             anybody waiting? ([D]=process descriptor address)
                    beq       IRQExit             no, go return...
                    stb       <V.WAKE             mark I/O done
                    tfr       d,x                 copy process descriptor pointer
                    lda       P$State,x           get state flags
                    anda      #^Suspend           clear suspend state
                    sta       P$State,x           save state flags
IRQExit             puls      dp,pc               recover system DP, return...

                    emod
ModSize             equ       *
                    end


