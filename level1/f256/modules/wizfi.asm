********************************************************************
* WizFi - WizNet WizFi360 Driver
*
* WizFi360 Programming references can be found here:
*   https://docs.wiznet.io/img/products/wizfi360/wizfi360ds/wizfi360_atset_v1118_e.pdf
*   http://www.wiznet.io/
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
*          2025/06/04  R Taylor
* Packet listener added to ISR.  Stages the packet data for the main code to
* grab for the current /n# device.  No buffering is taking place at this time.
*
*          2025/06/05  R Taylor
* Automatic packet transmitter added to ISR.  Works in tandem with the Write
* routine's 256-byte circular buffer.


                    nam       WizFi
                    ttl       WizNet WizFi360 Driver

                    ifp1
                    use       defsfile
                    endc

WIZFI_INTERRUPT     equ       INT_TIMER_0         Convenience placement
VIRQCNT             equ       1
WORK_SLOT	    equ       MMU_SLOT_2
MMU_WINDOW          equ       $4000

* miscellaneous definitions
DCDStBit            equ       %00100000           DCD status bit for SS.CDSta call
DSRStBit            equ       %01000000           DSR status bit for SS.CDSta call
SlpBreak            set       TkPerSec/2+1        line Break duration
SlpHngUp            set       TkPerSec/2+1        hang up (drop DTR) duration


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


*============================================================================
Mask_SocketDev            equ       %00001000
IRQ_State_ListenByte      equ       $01
IRQ_State_ListenPkt       equ       $02
IRQ_State_ListenConnect   equ       $03
IRQ_State_WritePacket     equ       $04
IRQ_State_ListenPktPrompt equ       $05
IRQ_State_ListenPktVerify equ       $06

*============================================================================

* Globals Page Definitions (must be 256 bytes max)
* WizFi.StatCnt          equ       15+16
*                        org       $00
* D.WizFi                rmb       4
* WizFi.StatTbl          rmb       WizFi.StatCnt          page pointers for terminal device static storage



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
WxDatLen            rmb       2
SigSent             rmb       1                   keyboard abort/interrupt signal already sent
SSigPID             rmb       1                   SS.SSig process ID
SSigSig             rmb       1                   SS.SSig signal code
WritFlag            rmb       1                   initial write attempt flag
Wrk.Type            rmb       1                   type work byte (MUST immediately precede Wrk.Baud)
Wrk.Baud            rmb       1                   baud work byte (MUST immediately follow Wrk.Type)
Wrk.XTyp            rmb       1                   extended type work byte
VIRQBF              rmb       5                   buffer for VIRQ
LastRxCount         rmb       1

*============================================================================
MasterRxDget        rmb       2
MasterRxDput        rmb       2
MasterRxDBlock      rmb       1

*============================================================================
ind_ControlReg      rmb       2
ind_DataReg         rmb       2
ind_RxD_RD_CountReg rmb       2
ind_RxD_WR_CountReg rmb       2
ind_TxD_RD_CountReg rmb       2
ind_TxD_WR_CountReg rmb       2

*== INTERUPT SERVICE ROUTINE ================================================
IRQ_State           rmb       1
PendingByte         rmb       1
LastRxD             rmb       1
IpdLen              rmb       2
PktReadPos             rmb       1
IpdLenChar          rmb       1
DeviceMode          rmb       1		          Mode of the device descriptor (0 = no packets)
DeviceChannel       rmb       1                  Connection # of the device descriptor (0-3)
PacketChannel       rmb       1

*== WRITING PACKETS =========================================================
WritePos            rmb       1
WritePacketTimer    rmb       1
OutPktLaydown       rmb       1
OutPktPickup        rmb       1
strDecimal5         rmb       5

*============================================================================
* sc6551 residuals
DataReg             rmb       1                   receive/transmit Data (read Rx / write Tx)
StatReg             rmb       1                   status (read only)
PRstReg             equ       StatReg             programmed reset (write only)
CmdReg              rmb       1                   command (read/write)
CtlReg              rmb       1                   control (read/write)

*============================================================================
                    ifeq      Level-1
orgDFIRQ            rmb       2
                    endc
*============================================================================
RxBufDSz            equ       256-.               default Rx buffer gets remainder of page...
RxBuff              rmb       RxBufDSz            default Rx buffer

OutPktBuf           rmb       256

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

strConnect          fcc       "0,CONNECT"
strCipSend          fcc       "AT+CIPSEND="
                    fcb       0
BaudTabl            equ       *
                    fcb       BR.00110,BR.00300,BR.00600
                    fcb       BR.01200,BR.02400,BR.04800
                    fcb       BR.09600,BR.19200


***********************************************************************************
* F$IRQ packet.
*
IRQ_Pckt            equ       *
IRQ_Pckt.Flip       fcb       %00000000           the flip byte
IRQ_Pckt.Mask       fcb       WIZFI_INTERRUPT     the mask byte
                    fcb       $F1                 the priority byte


* Set up INT_TIMER_0 (25.175Mhz-based timer)
* Fast
* 25,175,000 / 11520 Bytes Per Second  = 2185 ticks @ 25.175Mhz (8, 137)
* 25,175,000 / 23040 Bytes Per Second  = 1092 ticks @ 25.175Mhz (4,  68)
* 25,175,000 / 92160 Bytes Per Second  =  273 ticks @ 25.175Mhz (1,  17)
*
* rates and results
* 273 = startup purger idled out
* 380 = startup purger finished

* Being tweaked for goldilox
TRATE equ 300
*TRATE equ 800 * choppy response but output is fast

SetIRQRate           ldd       #TRATE
c@                  sta       T0_VAL+0            registers are still Little Endian?
                    stb       T0_VAL+1
                    clr       T0_VAL+2
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
* NOTE:  SCFMan has already cleared all device memory except for V.PAGE and
*        V.PORT.  Zero-default variables are:  CDSigPID, CDSigSig, Wrk.XTyp.
Init                clrb                          default to no error...
                    pshs      cc,dp               save IRQ/Carry status, system DP
*                    tfr       u,d
*                    tfr       a,dp

                    orcc      #IntMasks

                    pshs      y			  save Y so it's last on stack so we can recall it using 0,s

                    lbsr      GetDeviceChannel

                *     pshs      x
                *     tfr       dp,a
                *     ldb       DeviceChannel,u
                *     tfr       d,x
                *     tfr       u,d
                *     tst       $1C,x
                *     bne       Init2               Already requested a page of memory
*                     pshs      u
*                     ldd       #$0100
*                     os9       F$SRqMem
*                     tfr       u,x
*                     puls      u
*                     lbcs      InitExit
*                     stx       <D.WizFi
*                     clrb
* c@                  clr       ,x+
*                     decb
*                     bne       c@
* Install IRQ servicer based on INT_PENDING_0 register
                    ldd       #TRATE
                    sta       T0_VAL+0            registers are still Little Endian?
                    stb       T0_VAL+1
                    clr       T0_VAL+2
                    lda       #%00000001
                    sta       >T0_CTR
                    lda       #%00000010          Timer reloads Value, for continuous run
                    sta       >T0_CMP_CTR
                    ldd       #INT_PENDING_0      get the pending interrupt pending address
                    leax      IRQ_Pckt,pcr        point to the IRQ packet
                    leay      iService,pcr       and the service routine
                    os9       F$IRQ               install the interrupt handler
*                    bcc       g@                  branch if success
*                    os9       F$PErr
                    lda       >INT_MASK_0          else get the interrupt mask byte
                    anda      #^WIZFI_INTERRUPT   set the interrupt
                    sta       >INT_MASK_0          and save it back
Init2
*                    puls      x
                    clr       OutPktLaydown,u
                    clr       OutPktPickup,u
                    clr       WritePacketTimer,u
                    clr       PktReadPos,u
                    clr       PendingByte,u
                    clra
                    clrb
                    std       IpdLen,u
                    std       MasterRxDget,u
                    std       MasterRxDput,u

                    ldb       #IRQ_State_ListenPkt
                    stb       IRQ_State,u

                    ldd       V.PORT,u	allow $404x, $FF2x  
                    andb      #%11100000                
                    tfr       d,y

* Give ability for us to LD/ST [someWizFiReg,u] for the WizFi registers
                    leax      WizFi_CtrlReg,y
                    stx       ind_ControlReg,u
                    leax      WizFi_DataReg,y
                    stx       ind_DataReg,u
                    leax      WizFi_RxD_RD_Cnt,y
                    stx       ind_RxD_RD_CountReg,u
                    leax      WizFi_RxD_WR_Cnt,y
                    stx       ind_RxD_WR_CountReg,u
                    leax      WizFi_TxD_RD_Cnt,y
                    stx       ind_TxD_RD_CountReg,u
                    leax      WizFi_TxD_WR_Cnt,y
                    stx       ind_TxD_WR_CountReg,u

*                    clr       [ind_ControlReg,u]  115200 bps

*                    pshs      x
*                    ldb       #1                  Master RxD stream needs an 8K block of RAM
*                    os9       F$AllRAM
*                    puls      x
*                    lbcs      InitExit
*                    stb       MasterRxDBlock,u

* Allocate WizFi statics page

                    ldy       ,s

InitExit            puls      y
                    puls      cc,dp,pc            recover IRQ/Carry status, system DP, return

Term                clrb                          default to no error...
                    pshs      cc,dp               save IRQ/Carry status, dummy B, system DP

                    tfr       u,d
                    tfr       a,dp

*                    clra
*                    ldb       MasterRxDBlock,u
*                    tfr       d,x
*                    ldb       #1
*                    os9       F$DelRAM

                *     ifeq      Level-1
                *     ldx       >D.Proc
                *     lda       P$ID,x
                *     sta       <V.BUSY
                *     sta       <V.LPRC
                *     endc

                *     ldx       V.PORT,u
                *     lda       CmdReg,u		*CmdReg,x            get current Command register contents
                *     anda      #^(Cmd.TIRB!Cmd.DTR) disable Tx IRQs, RTS, and DTR
                *     ora       #Cmd.RxI            disable Rx IRQs
                *     ldb       Wrk.XTyp,u           get extended type byte
                *     andb      #ForceDTR           forced DTR?
                *     beq       KeepDTR             no, go leave DTR disabled...
                *     ora       #Cmd.DTR            set (enable) DTR bit
KeepDTR
*             sta       CmdReg,u		*CmdReg,x            set DTR and RTS enable/disable
TermExit

                    ldx       #$0000              remove IRQ table entry
                    os9       F$IRQ

                    puls      cc                  recover IRQ/Carry status
                    puls      dp,pc               restore dummy A, system DP, return

RxCRead             pshs      y,b,cc
                    orcc      #IntMasks
                    ldd       MasterRxDget,u
                    addd      #$0001              To be optimized later into  incb, bcc, inca  incrementer
                    anda      #$07                2K circular buffer
                    std       MasterRxDget,u
                    adda      #$40                Buffer pointer between $4000-$5FFF
                    tfr       d,y
                    ldb       >WORK_SLOT
                    lda       MasterRxDBlock,u
                    sta       >WORK_SLOT
                    lda       ,y
                    stb       >WORK_SLOT
x@                  puls      cc,b,y,pc


RxCWrite            pshs      y,b,a,cc
                    orcc      #IntMasks
                    ldd       MasterRxDput,u
                    addd      #$0001
                    anda      #$07                2K circular buffer
                    std       MasterRxDput,u
                    adda      #$40                Buffer pointer between $4000-$5FFF
                    tfr       d,y
                    ldb       >WORK_SLOT
                    lda       MasterRxDBlock,u
                    sta       >WORK_SLOT
                    lda       1,s
                    sta       ,y
                    stb       >WORK_SLOT
x@                  puls      cc,a,b,y,pc


RxFRead             pshs      cc,b
                    orcc      #IntMasks
                    ldb       >WORK_SLOT
                    lda       #$C5		Bank where the WizFi registers are
                    sta       >WORK_SLOT
                    lda       [ind_DataReg,u]
                    stb       >WORK_SLOT
                    puls      b,cc
                    rts

GetDeviceChannel
                    ldb       V.PORT+1,u
                    tfr       b,a
                    anda      #MASK_SOCKETDEV
                    sta       DeviceMode,u
                    andb      #3
                    stb       DeviceChannel,u
                    rts

iRxFCheck           ldd       [ind_RxD_WR_CountReg,u]
                    anda      #$07
                    cmpd      #$0000
                    rts

RxCCheck
                    ldb       PendingByte,u
                    rts


iService            pshs      cc,dp,x
*                    tfr       u,d                 setup our DP
*                    tfr       a,dp
*                    bsr       GetDeviceChannel
                    ldb       >WORK_SLOT
                    pshs      b
                    lda       #$C5		  Map in the WizFi registers
                    sta       >WORK_SLOT

                    lda       #WIZFI_INTERRUPT    clear pending interrupt
                    sta       INT_PENDING_0

                    ldb       PendingByte,u
                    lbne      iExit
                    lbsr      iRxFCheck
                    lbeq      iSendPkt         Send pending TxD packets only if no RxD

                    lda       [ind_DataReg,u]
                    sta       LastRxD,u

                    ldb       DeviceMode,u        Device descriptor has the Packets bit set
                    lbeq      iReadAndWake0

                    ldb       IRQ_State,u
                    cmpb      #IRQ_State_ListenPkt
                    beq       iListenPkt

                    ldx       IpdLen,u
                    bne       x@
                    ldb       #IRQ_State_ListenPkt
                    stb       IRQ_State,u
                    clr       PktReadPos,u
                    lbra      iExit
x@                  leax      -1,x
                    stx       IpdLen,u

                    ldb       PacketChannel,u
                    cmpb      DeviceChannel,u
                    lbeq      iReadAndWake
                    lbra      iExit

iListenPkt          leax      strIPD,pcr          point to start of IPD string constant
                    ldb       PktReadPos,u           what character position are we at?  +  P  D  ,   ?  0-3
                    cmpb      #4
                    bls       mc@                 go match exact chars "+IPD,"
                    cmpb      #5
                    beq       ms@                 go match a digit "0" - "3" for the socket #
                    cmpb      #6
                    bls       mc@                 go match exact char ","
                    cmpa      #58                 match ":" terminator for +IPD string
                    beq       t@                  terminating character
                    sta       IpdLenChar,u        match length digits
                    ldd       IpdLen,u
                    lbsr      DecBin
                    std       IpdLen,u
m@                  inc       PktReadPos,u
x@                  lbra      iExit             Exit with no data
strIPD              fcc       "+IPD,$,#####:"
t@                  clr       PktReadPos,u
                    clr       IRQ_State,u        Switch to data mode for the next cycle
                    bra       x@
mc@                 cmpa      b,x                 Match exact char from RxD FIFO
                    beq       m@
                    clr       PktReadPos,u           Match failed, quit parsing the IPD and start again
                    bra       x@
ms@                 clr       PacketChannel,u
                    cmpa      #'0
                    blo       m@
                    cmpa      #'3
                    bhi       m@
                    suba      #'0                 get connection # in ASCII "0" - "3"
                    sta       PacketChannel,u
                    clr       IpdLen,u
                    clr       IpdLen+1,u
                    bra       m@
iSendPkt
*                    inc       WritePacketTimer,u
*                    ldb       WritePacketTimer,u
*                    anda      #127
*                    andb      #7
*                    lbne      iExit
                    ldb       OutPktLaydown,u
                    subb      OutPktPickup,u
                    lbeq      iExit
                    bpl       n@
                    negb
n@                  clra
                    tfr       d,y
                    leax      strCipSend,pcr
s@                  lda       ,x+
                    beq       c@
                    lbsr      SendByte
                    bra       s@
c@                  lda       DeviceChannel,u
                    adda      #'0
                    lbsr      SendByte
                    lda       #',
                    lbsr      SendByte

                    leax      strDecimal5,u
                    tfr       y,d
                    lbsr      Word2Dec3           We also have Word2Dec5 routine for 5-digit packet size for outgoing
                    ldb       #3
d@                  lda       ,x+
                    lbsr      SendByte
                    decb
                    bne       d@
                    lda       #$0d
                    lbsr      SendByte
                    lda       #$0a
                    lbsr      SendByte
wsp@                lbsr      iRxFCheck
                    beq       wsp@
                    lda       [ind_DataReg,u]
                    cmpa      #32
                    bne       wsp@
r@                  inc       OutPktPickup,u
                    ldb       OutPktPickup,u
                    leax      OutPktBuf,u
                    abx
                    lda       ,x
	            lbsr      SendByte
                    leay      -1,y
                    bne       r@
                    ldy       #4                  Wait for 4 CRLF terminated AT responses
pl@                 lbsr      iRxFCheck           There is no dead loop prevention at this time
                    beq       pl@
                    lda       [ind_DataReg,u]
                    cmpa      #10
                    bne       pl@
                    leay      -1,y
                    bne       pl@
                    bra       iExit
*                    bra       iWake
iReadAndWake0       clr       PacketChannel,u
iReadAndWake
                    ldb       #1
                    stb       PendingByte,u

iWake
                *     pshs      u
                *     tfr       dp,a 
                *     ldb       PacketChannel,u
                *     tfr       d,x
                *     lda       $1C,x
                *     clrb
                *     tfr       d,u

                    clrb                          clear Carry (for exit) and LSB of process descriptor address
                    lda       V.WAKE,u            anybody waiting? ([D]=process descriptor address)
                    beq       r@                  no, go return...
                    stb       V.WAKE,u            mark I/O done
                    tfr       d,x                 copy process descriptor pointer
                    lda       P$State,x           get state flags
                    anda      #^Suspend           clear suspend state
                    sta       P$State,x           save state flags
r@
*                  puls      u
iExit               puls      b
                    stb       >WORK_SLOT

                    puls      cc,dp,x,pc               recover system DP, return...


ReadSlp             ldd       >D.Proc             Level II process descriptor address
                    sta       V.WAKE,u             save MSB for IRQ service routine
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
                    lbne      PrAbtErr            yes, go do it...
                    ldb       V.WAKE,u             true interrupt?
                    beq       ReadChar             yes, go read the char.
                    bra       ReadSlp             no, go suspend the process

* x bits 1..0 is socket #, bit 4 = isPacketChannel	ldd <V.PORT
Read                clrb                          default to no errors...
                    pshs      cc,dp               save IRQ/Carry status, system DP
*                    tfr       u,d
*                    tfr       a,dp

*ReadChar
*                    ldb       V.ERR,u              get accumulated errors, if any
*                    stb       PD.ERR,y            set/clear error(s) in path descriptor
*                    lbne      ReprtErr            error(s), go report it/them...

ReadChar            orcc      #IntMasks
                    tst       PendingByte,u
                    beq       ReadSlp
                    lda       LastRxD,u
                    clr       PendingByte,u
                    puls      cc,dp,pc            recover IRQ/Carry status, dummy B, system DP, return

PrAbtErr            ldb       #E$PrcAbt
                    bra       ErrExit

ReprtErr            clr       V.ERR,u              clear error status
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


WriteSlp            ldd       >D.Proc             Level II process descriptor address
                    sta       V.WAKE,u             save MSB for IRQ service routine
                    tfr       d,x                 copy process descriptor address
                    ldb       P$State,x
                    orb       #Suspend
                    stb       P$State,x
                    lbsr      Sleep1              go suspend process...
                    ldx       >D.Proc             process descriptor address
                    ldb       P$Signal,x          pending signal for this process?
                    beq       ChkWState           no, go check process state...
                    cmpb      #S$Intrpt           do we honor signal?
                    lbls      ErrExit             yes, go do it...
ChkWState           equ       *
                    ldb       P$State,x
                    bitb      #Condem
                    lbne      PrAbtErr            yes, go do it...
                    ldb       V.WAKE,u             true interrupt?
                    beq       Wrt2PktBuf             yes, go write the char.
                    bra       WriteSlp             no, go suspend the process

Write               clrb                          default to no error...
                    pshs      cc,a             save IRQ/Carry status, Tx character, system DP
                    ldb       DeviceMode,u
                    bne       Wrt2PktBuf
                    bsr       SendByte
                    lbra      WriteExit

Wrt2PktBuf
                    orcc      #IntMasks
                    ldb       OutPktLaydown,u
                    incb
                    cmpb      OutPktPickup,u
                    beq       WriteSlp                 1 more write would overflow the buffer, so we need to wait on the ISR to purge
                    stb       OutPktLaydown,u
                    leax      OutPktBuf,u
                    abx
                    lda       1,s
                    sta       ,x
 
WriteExit           puls      cc,a,pc            recover IRQ/Carry status, Tx character, system DP, return

SendByte            pshs      cc,a,b
                    orcc      #IntMasks           disable IRQs during error and Tx disable checks
                    ldb       >WORK_SLOT
                    lda       #$c5
                    sta       >WORK_SLOT
                    lda       1,s
                    sta       [ind_DataReg,u]
                    stb       >WORK_SLOT
                    puls      cc,a,b,pc


GStt                clrb                          default to no error...
                    pshs      cc,dp               save IRQ/Carry status, dummy B, system DP
                *     pshs      a
                *     tfr       u,d
                *     tfr       a,dp
                *     puls      a
                    ldx       PD.RGS,y            caller's register stack pointer
                    cmpa      #SS.EOF
                    beq       GSExitOK            yes, SCF devices never return EOF
                    cmpa      #SS.Ready
                    bne       GetScSiz
                    lbsr      RxCCheck
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
                    ldd       Wrk.Type,u
                    std       R$Y,x
                    clra                          default to DCD and DSR enabled
                    ldb       CpyDCDSR,u
                    bitb      #Mask.DCD
                    beq       CheckDSR            no, go check DSR status
                    ora       #DCDStBit
CheckDSR            bitb      Mask.DSR,u           DSR bit set (disabled)?
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
                *     pshs      a
                *     tfr       u,d
                *     tfr       a,dp
                *     puls      a
                    ldx       PD.RGS,y

SetSSig             cmpa      #SS.SSig
                    bne       SetRelea
                    lda       PD.CPR,y            current process ID
                    ldb       R$X+1,x             LSB of [X] is signal code
                    orcc      #IntMasks
 bra RSendSig
                    pshs      d
                    lbsr      RxCCheck
                    tfr       d,x
                    puls      d
                    cmpx      #$0000
                    bne       RSendSig
                    std       SSigPID,u
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
                    std       CDSigPID,u
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
                    puls      cc,dp,pc            restore Carry status, dummy B, system DP, return

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


* Convert byte in B to Decimal string at X (3 places)
Word2Dec3
                    pshs      u,y,x,b
                    clra
                    leau      <DeciTbl+4,pcr      point to deci-table
                    ldy       #$0003              number of decimal places
                    bra       w1
* Convert word in D to Decimal string at X (5 places)
Word2Dec5
                    pshs      u,y,x,b
                    leau      <DeciTbl,pcr        point to deci-table
                    ldy       #$0005              number of decimal places
w1                  clr       ,s                  clear byte on stack
w2                  subd      ,u                  subtract current place from D
                    bcs       w3                  branch if negative
                    inc       ,s                  else increment place
                    bra       w2                  and continue
w3                  addd      ,u++                re-normalize D
                    pshs      b                   save B
                    ldb       $01,s               get saved B
                    addb      #'0                 add ASCII 0
                    stb       ,x+                 and save
                    puls      b                   retrieve saved B
                    leay      -$01,y              subtract Y
                    bne       w1                  branch if not done
                    puls      pc,u,y,x,b

DeciTbl             fdb       10000,1000,100,10,1


* For debugging, shows the Rx Packet size in the upper corner of the text screen

DecBin              pshs      y,b,a               save registers
                    ldb       IpdLenChar,u                 get digit
                    subb      #$30                make it binary
                    cmpb      #$0A                bla bla bla!
                    bcc       L095D
                    lda       #$00
                    ldy       #$000A
L094F               addd      ,s
                    bcs       L095B
                    leay      -$01,y
                    bne       L094F
                    std       ,s
                    andcc     #^Zero
L095B               puls      pc,y,b,a
L095D               orcc      #Zero
                    puls      pc,y,b,a



* Phased out, or on pause


* * debug
*         pshs d,x
*         clrb
*         tfr	d,x
*         lbsr	ShowHex
*         puls d,x,pc


* ShowHex             pshs      cc,d
*                     orcc      #IntMasks
*                     ldb       >WORK_SLOT
*                     pshs      b
*                     ldb       #$C2                Text screen block #
*                     stb       >WORK_SLOT 
*                     tfr       x,d
*                     lsra                          Do cheap binary to 4-digit HEX ASCII string
*                     lsra
*                     lsra
*                     lsra
*                     bsr       Bin2AscHex
*                     sta       >MMU_WINDOW+80+76
*                     tfr       x,d
*                     anda      #$0f
*                     bsr       Bin2AscHex
*                     sta       >MMU_WINDOW+80+77
*                     tfr       x,d
*                     tfr       b,a
*                     lsra                          Do cheap binary to 4-digit HEX ASCII string
*                     lsra
*                     lsra
*                     lsra
*                     bsr       Bin2AscHex
*                     sta       >MMU_WINDOW+80+78
*                     tfr       x,d
*                     tfr       b,a
*                     anda      #$0f
*                     bsr       Bin2AscHex
*                     sta       >MMU_WINDOW+80+79
*                     puls      b
*                     stb       >WORK_SLOT
*                     puls      cc,d,pc

* Bin2AscHex          anda      #$0f
*                     cmpa      #9
*                     bls       d@
*                     suba      #10
*                     adda      #'A'
*                     bra       x@
* d@                  adda      #'0'
* x@                  rts


* RxCCheck
*                    pshs      cc
*                    orcc      #IntMasks
* Method 1
*                    ldd       MasterRxDput,u
*                    cmpd      MasterRxDget,u
*                    bhs       p@
*                    ldd       MasterRxDget,u
*                    subd      MasterRxDput,u
*                    bra       r@
* p@                 subd      MasterRxDget,u
* r@
*                    puls      cc
* Method 2
*                    cmpd      #$0000
*                    rts



* * Transfer RxD from FIFO into Connection Buffer

* ISRPurger           lbsr      iRxFCheck
*                     beq       ISRWatcher
*                     tfr       d,y                 <------  Copying all FIFO to 8k Buffer "doesn't work out"  -------->
*                     ldy       #1                  <------  Copying only 1 byte, RxD works but is super slow  ------->

* p@                  lbsr      RxFRead             Hardware FIFO buffer
*                     lbsr      RxCWrite            Circular buffer, keeps track of size
*                     leay      -1,y
*                     bne       p@
*                     bra       iWake

* ISRWatcher          lbsr      RxCCheck
*                     beq       ISRExit

* ListenForConnect  for /n# devices only
* 	leax	strConnect,pcr
* 	ldb	PktReadPos,u
* 	cmpa	b,x
* 	beq	m@
* 	clr	PktReadPos,u
* 	bra	x@
* m@	incb
* 	stb	PktReadPos,u
*         cmpb    #9		total match
*         blo     x@
* 	clr	PktReadPos,u
* 	ldb	#State_ListenPacket
* 	stb	IRQ_State,u
* x@	bra	ReadExit


                    emod
ModSize             equ       *
                    end


