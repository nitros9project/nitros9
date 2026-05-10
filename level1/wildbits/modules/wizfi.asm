                    nam       WizFi
                    ttl       WizNet WizFi360 Driver

********************************************************************
* WizFi - WizNet WizFi360 Driver
*
* WizFi360 Programming references can be found here:
*   https://docs.wiznet.io/img/products/wizfi360/wizfi360ds/wizfi360_atset_v1118_e.pdf
*   http://www.wiznet.io/
*
********************************************************************
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2025/06/17  Roger Taylor
* Single IRQ, multi device process coupling attempt
*
*          2025/08/28  Roger Taylor
* Added new INT_WIZFI interrupt for K2, other non Jr2 machines

                    ifp1
                    use       defsfile
                    endc


* INT_TIMER_0 (25.175Mhz-based timer)
* 25,175,000 / 11520 Bytes Per Second  = 2185 ticks @ 25.175Mhz (8, 137)
* 25,175,000 / 92160 Bytes Per Second  =  273 ticks @ 25.175Mhz (1,  17)

TRATE               equ       350                 Tweak for goldilox (300 = quick response) (800 = choppy response)
D.WZStatTbl         equ       D.SWPage            Borrowed from incompatible SmartWatch variable
WORK_SLOT	    equ       MMU_SLOT_2
MMU_WINDOW          equ       $4000
Mask_SocketDev      equ       %00001000
IRQ_State_ListenPkt equ       %00000001
INT_WIZFI           equ       %00000001
SYS0_MACHINE_ID     equ       SYS0+7

*============================================================================

* sc6551 residue being removed over time
DCDStBit            equ       %00100000           DCD status bit for SS.CDSta call
DSRStBit            equ       %01000000           DSR status bit for SS.CDSta call
SlpBreak            set       TkPerSec/2+1        line Break duration
SlpHngUp            set       TkPerSec/2+1        hang up (drop DTR) duration


* Command bit definitions
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

*============================================================================

                    org       $00
vpr_proc            rmb       1
vpr_wake            rmb       1
vpr_chan            rmb       1
vpr_stat            rmb       1
vpr_data            rmb       1

*============================================================================
                    org       V.SCF               allow for SCF manager data area
CpyDCDSR            rmb       1                   DSR+DCD status copy
Mask.DCD            rmb       1                   DCD status bit mask (MUST immediately precede Mask.DSR)
Mask.DSR            rmb       1                   DSR status bit mask (MUST immediately follow Mask.DCD)
CDSigPID            rmb       1                   process ID for CD signal
CDSigSig            rmb       1                   CD signal code
SigSent             rmb       1                   keyboard abort/interrupt signal already sent
SSigPID             rmb       1                   SS.SSig process ID
SSigSig             rmb       1                   SS.SSig signal code
Wrk.Type            rmb       1                   type work byte (MUST immediately precede Wrk.Baud)
Wrk.Baud            rmb       1                   baud work byte (MUST immediately follow Wrk.Type)
Wrk.XTyp            rmb       1                   extended type work byte

*============================================================================
ind_CtrlReg         rmb       2
ind_DataReg         rmb       2
ind_RxD_RD_CountReg rmb       2
ind_RxD_WR_CountReg rmb       2
ind_TxD_RD_CountReg rmb       2
ind_TxD_WR_CountReg rmb       2

*============================================================================
IRQ_State           rmb       1
IpdLen              rmb       2
PktReadPos          rmb       1
IpdLenChar          rmb       1
DeviceMode          rmb       1		          Mode of the device descriptor (0 = no packets)
DevChan             rmb       1                  Connection # of the device descriptor (0-3)
PacketChannel       rmb       1
OutPktLaydown       rmb       1
OutPktPickup        rmb       1
strDecimal5         rmb       5
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

* WizFi requires a high-speed hardware IRQ service.
* Clock-based VIRQ has never worked out.
***********************************************************************************
* F$IRQ packet.
*
T0IRQ_Pckt          equ       *
T0IRQ_Pckt.Flip     fcb       %00000000           the flip byte
T0IRQ_Pckt.Mask     fcb       INT_TIMER_0         the mask byte for machines without actual WizFi Interrupt
                    fcb       $F1                 the priority byte

WIIRQ_Pckt          equ       *
WIIRQ_Pckt.Flip     fcb       %00000000           the flip byte
WIIRQ_Pckt.Mask     fcb       INT_WIZFI           the mask byte for WizFi Interrupt
                    fcb       $F1                 the priority byte


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

                    pshs      y			  save Y so it's last on stack so we can recall it using 0,s

                    lbsr      GetDevChan

* Check if we've already allocated memory.
                    ifgt      Level-1
                    ldx       <D.WZStatTbl
                    else
                    ldx       >D.WZStatTbl
                    endc
                    lbne      Init2
                    
* Allocate a single 256 byte page of memory
                    ldd       #$0100
                    pshs      u
                    os9       F$SRqMem
                    tfr       u,x
                    puls      u
                    ifgt      Level-1
                    stx       <D.WZStatTbl
                    else
                    stx       >D.WZStatTbl
                    endc

                    clrb
c@                  clr       ,x+
                    decb
                    bne       c@

Init2               lda       SYS0_MACHINE_ID
                    cmpa      #$1A                 at this time the Jr2 doesn't have the WizFi Interrupt
                    beq       InstallTimer0
InstallWizIRQ       lda       >INT_MASK_3          else get the interrupt mask byte
                    anda      #^INT_WIZFI          enable the WizFi interrupt
                    sta       >INT_MASK_3          and save it back
                    ldd       #INT_PENDING_3       assume all other machines with WizFi will have the WizFi Interrupt
                    leax      WIIRQ_Pckt,pcr       point to the IRQ packet
                    bra       Install
InstallTimer0       ldd       #TRATE
                    sta       T0_VAL+0            registers are still Little Endian?
                    stb       T0_VAL+1
                    clr       T0_VAL+2
                    lda       #%00000001
                    sta       >T0_CTR
                    lda       #%00000010          Timer reloads Value, for continuous run
                    sta       >T0_CMP_CTR
                    lda       >INT_MASK_0         else get the interrupt mask byte
                    anda      #^INT_TIMER_0       enable the TIMER_0 interrupt
                    sta       >INT_MASK_0         and save it back
                    ldd       #INT_PENDING_0      get the pending interrupt pending address
                    leax      T0IRQ_Pckt,pcr      point to the IRQ packet

Install             leay      iService,pcr        and the service routine
                    os9       F$IRQ               install the interrupt handler
*                    bcc       g@                 branch if success
*                    os9       F$PErr
                    clr       OutPktLaydown,u
                    clr       OutPktPickup,u
                    clr       PktReadPos,u
                    clra
                    clrb
                    std       IpdLen,u

                    ldb       #IRQ_State_ListenPkt
                    stb       IRQ_State,u

*Init2
                    ldd       V.PORT,u	allow $404x, $FF2x  
                    andb      #%11100000                
                    tfr       d,y

* Give ability for us to LD#/ST# [someWizFiReg,u] the WizFi registers
                    leax      WizFi_CtrlReg,y
                    stx       ind_CtrlReg,u
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

*                    pshs      x
*                    ldb       #1                  Master RxD stream needs an 8K block of RAM
*                    os9       F$AllRAM
*                    puls      x
*                    lbcs      InitExit
*                    stb       MasterRxDBlock,u

InitExit            puls      y
                    puls      cc,dp,pc            recover IRQ/Carry status, system DP, return

Term                clrb                          default to no error...
                    pshs      cc,dp               save IRQ/Carry status, dummy B, system DP

                *     lda       #WIZFI_INTERRUPT
                *     pshs      a
                *     sta       >INT_PENDING_0      get the pending interrupt pending address
                *     lda       >INT_MASK_0          else get the interrupt mask byte
                *     ora       ,s+
                *     sta       >INT_MASK_0          and save it back

                     ldx       #$0000              remove IRQ table entry
                     os9       F$IRQ

                *     pshs      u                   save data pointer
                *     ifgt      Level-1
                *     ldu       <D.WZStatTbl
                *     else
                *     ldu       >D.WZStatTbl
                *     endc
                *     os9       F$SRtMem
                *     puls      u                   recover data pointer

                    puls      cc                  recover IRQ/Carry status
                    puls      dp,pc               restore dummy A, system DP, return

GetVpPtr            ifgt      Level-1
                    ldx       <D.WZStatTbl
                    else
                    ldx       >D.WZStatTbl
                    endc
                    andb      #3
                    lslb
                    lslb
                    abx
                    rts

GetDevChan          pshs      d
                    ldd       Wrk.Type,u           save type/baud in data area
                    andb      #%00000011
                    stb       [ind_CtrlReg,u]      Update WizFi Control Register
                    ldb       V.PORT+1,u
                    tfr       b,a
                    anda      #%00001000
                    sta       DeviceMode,u
                    tfr       b,a
                    anda      #%00000011
                    sta       DevChan,u
                    puls      d,pc

RxFCheck            ldd       [ind_RxD_WR_CountReg,u]
                    anda      #$07
                    cmpd      #$0000
                    rts

iService            pshs      cc,dp,x

                    lda       SYS0_MACHINE_ID
                    cmpa      #$1A                at this time the Jr2 doesn't have the WizFi Interrupt
                    beq       ClearTimer0
                    lda       #INT_WIZFI          clear pending interrupt
                    sta       >INT_PENDING_3
                    bra       iSendPkt
ClearTimer0         lda       #INT_TIMER_0
                    sta       >INT_PENDING_0
iSendPkt            ldb       OutPktLaydown,u
                    subb      OutPktPickup,u
                    lbeq      iRead
                    bpl       n@
                    negb
n@                  clra
                    tfr       d,y
* ps@                 lbsr      RxFCheck            Is there any FIFO data waiting?
*                     beq       s1@
*                     lda       [ind_DataReg,u]     Read next FIFO byte
*                     bra       ps@
s1@                 ldb       DeviceMode,u
                    beq       r@
                    leax      strCipSend,pcr
s@                  lda       ,x+
                    beq       c@
                    sta       [ind_DataReg,u]
                    bra       s@
c@                  lda       DevChan,u
                    adda      #'0
                    sta       [ind_DataReg,u]
                    lda       #',
                    sta       [ind_DataReg,u]
                    leax      strDecimal5,u
                    tfr       y,d
                    lbsr      Word2Dec3           We also have Word2Dec5 routine for 5-digit packet size for outgoing
                    ldb       #3
d@                  lda       ,x+
                    sta       [ind_DataReg,u]
                    decb
                    bne       d@
                    lda       #$0d
                    sta       [ind_DataReg,u]
                    lda       #$0a
                    sta       [ind_DataReg,u]
wsp@                lbsr      RxFCheck
                    beq       wsp@
                    lda       [ind_DataReg,u]
                    cmpa      #32
                    bne       wsp@
r@                  inc       OutPktPickup,u
                    ldb       OutPktPickup,u
                    leax      OutPktBuf,u
                    abx
                    lda       ,x
                    sta       [ind_DataReg,u]
                    leay      -1,y
                    bne       r@
                    ldb       DeviceMode,u
                    beq       xx@
                    ldy       #4                  Wait for 4 CRLF terminated AT responses
pl@                 lbsr      RxFCheck            Is there any FIFO data waiting?
                    beq       pl@                 No, loop forever until there is *** There is no dead loop prevention at this time
                    lda       [ind_DataReg,u]     Read next FIFO byte
                    cmpa      #10                 Is it the code for Line Feed?
                    bne       pl@                 No, loop until
                    leay      -1,y                Update the string response counter
                    bne       pl@                 Purge the next string
xx@                 lbra      iWake
*                    lbra      iExit               Return from ISR, no payload update

iRead
                    ldb       DevChan,u           Get the connection/channel # for the current device
                    lbsr      GetVpPtr            Point to associated payload
                    lda       vpr_stat,x          Has the mainline code signaled that it has consumed the last data byte?
                    lbmi      iExit               No, so just exit.  The hardware FIFO will do it's job in the meantime.
                    lbsr      RxFCheck            Are there any pending RxD FIFO bytes?
                    lbeq      iExit               Return from ISR, no payload update

                    lda       [ind_DataReg,u]     Pop next FIFO byte
                    ldb       DeviceMode,u        Device descriptor has the Packets bit set
                    lbeq      iBroadcast          Device is using the WizFi360 passthrough/raw mode

                    ldb       IRQ_State,u         Are we currently listening for a packet header?
                    cmpb      #IRQ_State_ListenPkt
                    beq       iListenPkt          Yes, keep listening

                    ldx       IpdLen,u            Are we still returning the data portion of a packet?
                    beq       x@                  No, go back into Listen mode and return
                    leax      -1,x                Yes, decrement the byte count
                    stx       IpdLen,u            Update the byte counter
                    lbra      iBroadcast          Update the payload and return
x@                  ldb       #IRQ_State_ListenPkt  Go into listen mode
                    stb       IRQ_State,u
                    clr       PktReadPos,u        Clear the text matching index
                    lbeq      iExit               Return from ISR, no payload update

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
x@                  lbra      iExit               Exit with no data
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
iBroadcast          ldb       PacketChannel,u
                    lbsr      GetVpPtr
                    ldb       PacketChannel,u
                    orb       #$80
                    stb       vpr_stat,x
                    sta       vpr_data,x

iWake               ldb       PacketChannel,u
                    lbsr      GetVpPtr
                    clrb                          clear Carry (for exit) and LSB of process descriptor address
                    lda       vpr_wake,x          anybody waiting? ([D]=process descriptor address)
                    beq       iExit               no, go return...
                    stb       vpr_wake,x          mark I/O done
                    tfr       d,x                 copy process descriptor pointer
                    lda       P$State,x           get state flags
                    anda      #^Suspend           clear suspend state
                    sta       P$State,x           save state flags

iExit               puls      cc,dp,x,pc          Recover system DP, return...

ReadSlp             ldb       DevChan,u
                    lbsr      GetVpPtr
                    ldd       >D.Proc             Level II process descriptor address
                    sta       vpr_wake,x           V.WAKE,u             save MSB for IRQ service routine
                    tfr       d,x                 copy process descriptor address
                    ldb       P$State,x
                    orb       #Suspend
                    stb       P$State,x
                    lbsr      Sleep1              go suspend process...
                    ldx       >D.Proc             process descriptor address
                    ldb       P$Signal,x          pending signal for this process?
                    beq       c@                  no, go check process state...
                    cmpb      #S$Intrpt           do we honor signal?
                    lbls      ErrExit             yes, go do it...
c@                  ldb       P$State,x
                    bitb      #Condem
                    lbne      PrAbtErr            yes, go do it...
                    ldb       DevChan,u
                    lbsr      GetVpPtr
                    ldb       vpr_wake,x           V.WAKE,u            true interrupt?
                    beq       ReadD               yes, go read the char.
                    bra       ReadSlp             no, go suspend the process

* x bits 1..0 is socket #, bit 4 = isPacketChannel	ldd <V.PORT
Read                clrb                          default to no errors...
                    pshs      cc,dp               save IRQ/Carry status, system DP

ReadD               orcc      #IntMasks
                    ldb       DevChan,u
                    lbsr      GetVpPtr
                    ldb       vpr_stat,x
                    bpl       ReadSlp
                    andb      #3
                    stb       vpr_stat,x           Notify the hub that we've taken our data
                    cmpb      DevChan,u
                    bne       ReadSlp
                    lda       vpr_data,x           Get our data
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

WritSlp             ldb       DevChan,u
                    lbsr      GetVpPtr
                    ldd       >D.Proc             Level II process descriptor address
                    sta       vpr_wake,x             save MSB for IRQ service routine
                    tfr       d,x                 copy process descriptor address
                    ldb       P$State,x
                    orb       #Suspend
                    stb       P$State,x
                    lbsr      Sleep1              go suspend process...
                    ldx       >D.Proc             process descriptor address
                    ldb       P$Signal,x          pending signal for this process?
                    beq       c@                  no, go check process state...
                    cmpb      #S$Intrpt           do we honor signal?
                    lbls      ErrExit             yes, go do it...
c@                  ldb       P$State,x
                    bitb      #Condem
                    lbne      PrAbtErr            yes, go do it...
                    ldb       DevChan,u
                    lbsr      GetVpPtr
                    ldb       vpr_wake,x            true interrupt?
                    beq       WriteD               yes, go read the char.
                    bra       WritSlp             no, go suspend the process

Write               clrb                          default to no error...
                    pshs      cc,a                save IRQ/Carry status, Tx character, system DP

WriteD              orcc      #IntMasks
                    ldb       OutPktLaydown,u
                    incb
                    cmpb      OutPktPickup,u
                    beq       WritSlp
                    stb       OutPktLaydown,u
                    leax      OutPktBuf,u
                    abx
                    lda       1,s
                    sta       ,x
                    puls      cc,a,pc            recover IRQ/Carry status, Tx character, system DP, return

GStt                clrb                          default to no error...
                    pshs      cc,dp               save IRQ/Carry status, dummy B, system DP
                    ldx       PD.RGS,y            caller's register stack pointer
                    cmpa      #SS.EOF
                    beq       GSExitOK            yes, SCF devices never return EOF
                    cmpa      #SS.Ready
                    bne       GetScSiz
                    pshs      x
                    ldb       DevChan,u
                    lbsr      GetVpPtr
                    lda       vpr_stat,x
                    puls      x
                    clrb                          Convert MSBit of payload status byte into a fake Count value of 0 or 1
                    lsla
                    rolb
                    clra
                    cmpd      #$0000              Test the available number of bytes
*                    lbsr      RxCCheck
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
CheckDSR            bitb      Mask.DSR,u          DSR bit set (disabled)?
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
 bra RSendSig
                    pshs      d
                    ldb       DevChan,u
                    lbsr      GetVpPtr
                    lda       vpr_stat,x
                    clrb
                    lsla
                    rolb
                    clra
                    tfr       d,x
                    puls      d
*                    lbsr      RxCCheck
*                    tfr       d,x
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
                    orcc      #IntMasks           disable IRQs while setting up ACIA registers
                    std       Wrk.Type,u          save type/baud in data area

                    lbsr      GetDevChan

                    puls      cc,pc               recover IRQ enable and Carry status, return...


* Convert byte in B to Decimal string at X (3 places)
Word2Dec3           pshs      u,y,x,b
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

                    emod
ModSize             equ       *
                    end


