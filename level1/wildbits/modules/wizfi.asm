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
*
*          2026/08/25-26  Roger Taylor
* K2 rework, hardware-verified against marginal external SRAM (the RAM
* clock domain closes timing by ~0.12ns; RAM-resident driver state was
* observed losing writes/reading stale, eating leading Rx bytes):
* - Tx: INT_WIZFI_TX drain-complete edge (INT_PENDING_3 bit 5); ring
*   drain extracted into SendRing; Write drains unconditionally (the
*   2048-byte hardware TX FIFO paces), so no tail can strand in RAM.
* - Rx: fully vpr-free on K2. The ISR does nothing for receive; Read
*   polls RxFCheck and pops the data register directly to the caller
*   (no RAM intermediary); blocked readers tick-sleep and re-poll with
*   signal checks. SS.Ready reports the hardware FIFO. Timer machines
*   (Jr2) keep the original parked-payload path unchanged.
* - +IPD packet mode preserved on both paths: the state machine lives
*   in PktByte, run by the timer ISR (Jr2) or the K2 reader loop; a K2
*   reader receiving another socket's payload hands it off via that
*   channel's slot (ParkOther) - the only K2 Rx path still touching
*   the vpr page, exercised by multi-socket flows only.
* - GetVpPtr uses extended (not direct-page) addressing like every
*   other system access in this driver.
* - Term masks its interrupt sources before removing the F$IRQ entry.
* - Packet-mode CIPSEND handshake made response-driven and bounded: the
*   "> " prompt wait and the reply purge (pop lines until "SEND OK" or
*   "ERROR") can no longer wedge the writer - the old fixed 4-LF purge
*   hung forever under ATE0 with IRQs masked.

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
WZ_Stat_TxEmpty     equ       %00001000           CtrlReg readback bit 3: hardware TX FIFO empty
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

* One F$IRQ entry serves BOTH WizFi sources: the mask byte carries the Rx
* data edge and the Tx drain-complete edge; iService clears and services
* whichever fired (the send path runs first either way).
WIIRQ_Pckt          equ       *
WIIRQ_Pckt.Flip     fcb       %00000000           the flip byte
WIIRQ_Pckt.Mask     fcb       INT_WIZFI           the mask byte for the WizFi interrupts
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

* K2 (machine ID $16) has the WizFi hardware interrupt wired; other
* machines (Jr2 = $1A) poll via Timer0. NOTE: the interrupt is NOT
* unmasked here on either path - unmasking before F$IRQ install (or
* before the ind_* pointers exist) let the first interrupt run iService
* through null pointers / with no handler: storm, dead before shell
* (proven by LED probe 2026-08-20). Pending cleared, handler installed,
* everything initialized, THEN unmask at the end of Init.
Init2               lda       SYS0_MACHINE_ID
                    cmpa      #$16                K2 with hardware WizFi interrupt?
                    bne       InstallTimer0       no: poll via Timer0
InstallWizIRQ       lda       #INT_WIZFI
                    sta       >INT_PENDING_3       clear any stale latched pendings
                    ldd       #INT_PENDING_3       polling address for the packet
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
                    lda       #INT_TIMER_0
                    sta       >INT_PENDING_0      clear any pending from the just-started timer
                    ldd       #INT_PENDING_0      get the pending interrupt pending address
                    leax      T0IRQ_Pckt,pcr      point to the IRQ packet

Install             leay      iService,pcr        and the service routine
                    os9       F$IRQ               install the interrupt handler
* NOTE: interrupt is NOT unmasked here. The ind_* hardware pointers are
* initialized further down; unmasking before they exist let the first
* interrupt run iService with NULL pointers (reads via [$0000]). The
* unmask now happens at the very end of Init, after everything is ready.
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

* Everything initialized (incl. ind_* pointers): NOW enable the source.
                    lda       SYS0_MACHINE_ID
                    cmpa      #$16                K2 with hardware WizFi interrupt?
                    bne       unmt0@
                    lda       >INT_MASK_3
                    anda      #^(INT_WIZFI)       enable Rx data + Tx drain edges
                    sta       >INT_MASK_3
                    bra       unmx@
unmt0@              lda       >INT_MASK_0
                    anda      #^INT_TIMER_0       enable the TIMER_0 interrupt
                    sta       >INT_MASK_0
unmx@               equ       *
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

* Silence our interrupt sources BEFORE removing the handler: a Tx
* drain-complete (or Rx) edge landing after removal has no handler.
                     orcc      #IntMasks
                     lda       SYS0_MACHINE_ID
                     cmpa      #$16                K2 with hardware WizFi interrupts?
                     bne       tmt0@
                     lda       >INT_MASK_3
                     ora       #INT_WIZFI          mask both WizFi edges
                     sta       >INT_MASK_3
                     bra       tmx@
tmt0@                lda       >INT_MASK_0
                     ora       #INT_TIMER_0        mask the poll timer
                     sta       >INT_MASK_0
tmx@                 ldx       #$0000              remove IRQ table entry
                     os9       F$IRQ

                *     pshs      u                   save data pointer
                *     ifgt      Level-1
                *     ldu       <D.WZStatTbl
                *     else
                *     ldu       >D.WZStatTbl
                *     endc
                *     os9       F$SRtMem
                *     puls      u                   recover data pointer

                    puls      cc,dp                  recover IRQ/Carry status
                    rts

* Extended, NOT direct-page: GetVpPtr runs in the ISR dispatch context,
* where DP is not guaranteed to be the system page. Every other system
* access in this driver is already extended (>D.Proc, >INT_PENDING_3).
* With <D.WZStatTbl, iBroadcast parked arriving bytes through a garbage
* pointer whenever no reader was active - hardware-verified 2026-08-26:
* Read-counter deficit matched the missing leading bytes exactly.
GetVpPtr            ldx       >D.WZStatTbl
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

* SendRing - drain the output ring to the WizFi (callable from the ISR
* and from Write's prime; IRQs MUST be masked at both call sites).
* Exit: Z set = nothing was queued, Z clear = a burst was sent.
* Preserves Y (Write's path descriptor); clobbers D,X.
SendRing            pshs      y
                    ldb       OutPktLaydown,u
                    subb      OutPktPickup,u
                    lbeq      sr9@                ring empty: return Z set
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
* Wait (bounded) for the "> " send prompt; Y = payload count, untouched.
                    ldx       #0                  ~65536 polls, then give up
wsp@                lbsr      RxFCheck
                    bne       wspb@
                    leax      -1,x
                    bne       wsp@
                    bra       r@                  no prompt: send anyway
wspb@               lda       [ind_DataReg,u]
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
* Purge the CIPSEND responses by CONTENT, not count: pop lines until one
* starting with 'S' ("SEND OK") or 'E' ("ERROR") completes. The old
* fixed 4-LF wait assumed module echo ON; under ATE0 fewer LFs arrive
* and the writer wedged here forever with IRQs masked (wizlog4: tsmon
* output never reached the PC). Bounded so a dead link cannot hang us.
srp0@               clrb                          B = first char of current line
                    ldx       #0                  bounded wait per line
srpw@               lbsr      RxFCheck
                    bne       srpb@               a byte is available
                    leax      -1,x
                    bne       srpw@
                    bra       xx@                 timeout: give up the purge
srpb@               lda       [ind_DataReg,u]     pop next response byte
                    cmpa      #13                 CR: ignore
                    beq       srpw@
                    cmpa      #10                 LF: line complete
                    beq       srpe@
                    tstb                          first printable of this line?
                    bne       srpw@
                    tfr       a,b                 latch it
                    bra       srpw@
srpe@               cmpb      #'S                 "SEND OK" line?
                    beq       xx@
                    cmpb      #'E                 "ERROR" line?
                    beq       xx@
                    bra       srp0@               other line: keep purging
xx@                 andcc     #^Zero              sent a burst: return Z clear
sr9@                puls      y,pc

iService            pshs      cc,dp,x
                    lda       SYS0_MACHINE_ID
                    cmpa      #$16                K2 with hardware WizFi interrupts?
                    bne       ClearTimer0
                    lda       #INT_WIZFI          clear whichever fired: Rx data
                    sta       >INT_PENDING_3      edge and/or Tx drain-complete edge
                    bra       iSendPkt
ClearTimer0         lda       #INT_TIMER_0
                    sta       >INT_PENDING_0
iSendPkt            lbsr      SendRing            drain any queued output first
                    lbeq      iRead               nothing was queued: service receive
                    lbra      iWake               sent a burst: wake any sleeper
*                    lbra      iExit               Return from ISR, no payload update

iRead
* K2: the ISR does NOTHING for receive - not even a status read. Every
* RX defense that consulted the vpr page was poisoned by it (measured:
* the no-sleeper gate read spurious vpr_wake and popped 5 bytes with no
* reader). Read polls and pops the hardware FIFO directly; blocked
* readers tick-sleep on the FIFO count. The marginal-SRAM page is fully
* out of the K2 receive path. Timer machines keep the parked path.
                    lda       SYS0_MACHINE_ID
                    cmpa      #$16                K2 with hardware WizFi interrupts?
                    lbeq      iExit               yes: RX is reader-driven only
                    ldb       DevChan,u           Get the connection/channel # for the current device
                    lbsr      GetVpPtr            Point to associated payload
                    lda       vpr_stat,x          Has the mainline code signaled that it has consumed the last data byte?
                    lbmi      iThrottle           No: just exit - the Timer0 poll retries next tick
                    lbsr      RxFCheck            Are there any pending RxD FIFO bytes?
                    lbeq      iExit               Return from ISR, no payload update

                    lda       [ind_DataReg,u]     Pop next FIFO byte
                    ldb       DeviceMode,u        Device descriptor has the Packets bit set
                    lbeq      iBroadcast          Device is using the WizFi360 passthrough/raw mode
                    lbsr      PktByte             run byte through the +IPD machine
                    lbeq      iExit               header/bookkeeping byte: consumed
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

* Driver-side flow control, so the driver survives WITHOUT the kernel's
* DoneIRQ mask-on-carry pacing (i.e. with the mainline clrb DoToggle):
* the payload buffer holds ONE byte; returning with it full and our
* interrupt enabled lets the module re-interrupt before the reader can
* ever consume (boot chatter at 'iniz wz' kills the machine before
* shell). Mask our source here; Read unmasks after consuming.
* Timer0 machines are paced by the timer and are left alone.
* Buffer full: on the hardware-IRQ K2, mask our interrupt until the
* reader consumes (Read unmasks); Timer0 machines just wait for the
* next tick - the timer paces the polling.
iThrottle           lda       SYS0_MACHINE_ID
                    cmpa      #$16                K2 with hardware WizFi interrupt?
                    bne       iExit               no: timer paces the polling
                    lda       >INT_MASK_3
                    ora       #INT_WIZFI          mask the WizFi interrupt
                    sta       >INT_MASK_3
* Return with carry explicitly CLEAR ('interrupt serviced'): the entry
* CC pushed at iService would otherwise be returned as-is - a random
* carry handed to the kernel's IRQ tail, which masks IRQs on carry set.
iExit               lda       ,s                  stacked entry CC
                    anda      #^Carry             force carry clear: serviced
                    sta       ,s
                    puls      cc,dp,x,pc          Recover system DP, return...

* PktByte - run one received byte (A) through the +IPD packet state
* machine. Shared by the timer ISR (Jr2) and the K2 reader-context
* direct-pop loop, so packet mode works identically on both.
* Exit: Z set   = byte was header/bookkeeping (consumed, keep reading)
*       Z clear = A is a payload byte for channel PacketChannel
PktByte             ldb       IRQ_State,u         listening for a header?
                    cmpb      #IRQ_State_ListenPkt
                    beq       pkhdr@
                    ldx       IpdLen,u            data phase: count the byte
                    beq       pklsn@              count spent: back to listen
                    leax      -1,x
                    stx       IpdLen,u
                    andcc     #^Zero              payload byte: Z clear
                    rts
pklsn@              ldb       #IRQ_State_ListenPkt
                    stb       IRQ_State,u
                    clr       PktReadPos,u
pkeat@              orcc      #Zero               consumed: Z set
                    rts
pkhdr@              leax      strIPD,pcr          point to start of IPD string constant
                    ldb       PktReadPos,u        what character position are we at?  +  P  D  ,   ?  0-3
                    cmpb      #4
                    bls       pkmc@               go match exact chars "+IPD,"
                    cmpb      #5
                    beq       pkms@               go match a digit "0" - "3" for the socket #
                    cmpb      #6
                    bls       pkmc@               go match exact char ","
                    cmpa      #58                 match ":" terminator for +IPD string
                    beq       pkt@                terminating character
                    sta       IpdLenChar,u        match length digits
                    ldd       IpdLen,u
                    lbsr      DecBin
                    std       IpdLen,u
pkm@                inc       PktReadPos,u
                    bra       pkeat@
pkt@                clr       PktReadPos,u
                    clr       IRQ_State,u         switch to data mode for the next cycle
                    bra       pkeat@
pkmc@               cmpa      b,x                 match exact char from RxD FIFO
                    beq       pkm@
                    clr       PktReadPos,u        match failed: restart the parse
                    bra       pkeat@
pkms@               clr       PacketChannel,u
                    cmpa      #'0
                    blo       pkm@
                    cmpa      #'3
                    bhi       pkm@
                    suba      #'0                 get connection # in ASCII "0" - "3"
                    sta       PacketChannel,u
                    clr       IpdLen,u
                    clr       IpdLen+1,u
                    bra       pkm@
strIPD              fcc       "+IPD,$,#####:"

* ParkOther - K2 reader-context hand-off of a payload byte (A) that
* belongs to ANOTHER channel: park it in that channel's slot and wake
* any sleeper there. This is the only K2 receive path that still
* touches the vpr page (multi-socket flows only). IRQs must be masked.
ParkOther           pshs      a
                    ldb       PacketChannel,u
                    lbsr      GetVpPtr
                    puls      a
                    ldb       PacketChannel,u
                    orb       #$80
                    stb       vpr_stat,x
                    sta       vpr_data,x
                    clrb
                    lda       vpr_wake,x          sleeper on that channel?
                    beq       po9@
                    stb       vpr_wake,x          mark I/O done
                    tfr       d,x                 process descriptor page
                    lda       P$State,x
                    anda      #^Suspend
                    sta       P$State,x
po9@                rts

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
* K2: fully vpr-free receive - poll and pop the hardware FIFO directly;
* when empty, tick-sleep and re-poll (signals honored). No parking, no
* wake handshake, no marginal-SRAM round-trips anywhere in the path.
                    lda       SYS0_MACHINE_ID
                    cmpa      #$16                K2 with hardware WizFi interrupts?
                    bne       rdtmr@              timer machines: parked path as always
rdk2@               lbsr      RxFCheck            bytes waiting in the hardware FIFO?
                    beq       rdk2w@              no: tick-sleep and re-poll
                    lda       [ind_DataReg,u]     pop directly
                    ldb       DeviceMode,u        packet-mode descriptor?
                    beq       rdk2d@              raw: deliver as-is
                    lbsr      PktByte             parse: +IPD headers consumed here
                    beq       rdk2@               header byte: keep reading
                    ldb       PacketChannel,u     payload byte: whose channel?
                    cmpb      DevChan,u
                    beq       rdk2d@              ours: deliver directly
                    lbsr      ParkOther           another socket's: hand it off
                    bra       rdk2@               and keep reading for our own
rdk2d@              puls      cc,dp,pc            deliver it (entry carry clear)
* K2 blocked-reader poll: give up the tick, honor signals, re-poll.
rdk2w@              lbsr      Sleep1
                    ldx       >D.Proc
                    ldb       P$Signal,x          pending signal?
                    beq       rdk2c@
                    cmpb      #S$Intrpt
                    lbls      ErrExit
rdk2c@              ldb       P$State,x
                    bitb      #Condem
                    lbne      PrAbtErr
                    bra       rdk2@
rdtmr@              ldb       DevChan,u
                    lbsr      GetVpPtr
                    ldb       vpr_stat,x
                    lbpl      ReadSlp             nothing parked: sleep for the tick
rdgo@               andb      #3
                    stb       vpr_stat,x           Notify the hub that we've taken our data
                    cmpb      DevChan,u
                    lbne      ReadSlp
                    lda       vpr_data,x           Get our data
* Byte consumed: on the hardware-IRQ K2, re-enable the interrupt that
* iThrottle masked. IRQs are masked here (orcc at ReadD): race-free RMW.
rdunm@              pshs      a
                    lda       SYS0_MACHINE_ID
                    cmpa      #$16                K2 with hardware WizFi interrupts?
                    bne       u@
                    lda       >INT_MASK_3
                    anda      #^INT_WIZFI          unmask the WizFi interrupt
                    sta       >INT_MASK_3
u@                  puls      a
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
* Background-send kick (hardware-IRQ machines only). Raw mode drains the
* ring on EVERY byte; packet mode only on CR/LF so an AT line becomes ONE
* CIPSEND instead of one per character. The drain is UNCONDITIONAL - the
* 2048-byte hardware TX FIFO does the pacing. Gating this on "TX FIFO
* empty" (the old prime) stranded bytes in the ring whenever the FIFO
* was momentarily busy: with no autonomous TX drain (old bitstreams have
* no Tx edge) the tail of a command sat in the ring until the NEXT
* session's first Write pushed it, mangling command boundaries (proven:
* AT+SLEEP=0 arrived as "AT+SLEEP=" + next-session prefix "0"). On new
* bitstreams the Tx drain-complete edge is now just a safety net.
* IRQs are masked above, so there is no race with the ISR.
                    lda       SYS0_MACHINE_ID
                    cmpa      #$16                K2 with hardware WizFi interrupts?
                    bne       WrExit              no: the poll timer paces sending
                    ldb       DeviceMode,u
                    beq       WrKick              raw mode: drain on every byte
                    lda       1,s                 packet mode: flush on end of line
                    cmpa      #$0d
                    beq       WrKick
                    cmpa      #$0a
                    bne       WrExit
WrKick              lbsr      SendRing            push the ring into the TX FIFO
WrExit              puls      cc,a,pc            recover IRQ/Carry status, Tx character, return

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
                    bmi       Rdy1                payload byte already delivered
* Payload empty. On the hardware-IRQ K2 the Rx FIFO can hold bytes with
* NO edge pending (boot chatter predates Init; bursts behind a consumed
* edge). Count those as ready so the reader calls Read, whose pump
* actually delivers them - otherwise SS.Ready pollers (modem's listen
* loop) spin forever on data that is sitting in the FIFO.
* (Packet mode: FIFO content may be just header chars, so a Read after
* this can still block briefly until real payload arrives.)
                    lda       SYS0_MACHINE_ID
                    cmpa      #$16                K2 with hardware WizFi interrupts?
                    lbne      NRdyErr             timer machines: next tick delivers
                    lbsr      RxFCheck            anything in the hardware FIFO?
                    lbeq      NRdyErr             no: genuinely not ready
Rdy1                ldb       #1                  at least one byte is available
                    stb       R$B,x               set Rx data available in caller's [B]
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
*                    orcc      #IntMasks
*                    ldb       >WORK_SLOT
*                    pshs      b
*                    ldb       #$C2                Text screen block #
*                    stb       >WORK_SLOT
*                    tfr       x,d
*                    lsra                          Do cheap binary to 4-digit HEX ASCII string
*                    lsra
*                    lsra
*                    lsra
*                    bsr       Bin2AscHex
*                    sta       >MMU_WINDOW+80+76
*                    tfr       x,d
*                    anda      #$0f
*                    bsr       Bin2AscHex
*                    sta       >MMU_WINDOW+80+77
*                    tfr       x,d
*                    tfr       b,a
*                    lsra                          Do cheap binary to 4-digit HEX ASCII string
*                    lsra
*                    lsra
*                    lsra
*                    bsr       Bin2AscHex
*                    sta       >MMU_WINDOW+80+78
*                    tfr       x,d
*                    tfr       b,a
*                    anda      #$0f
*                    bsr       Bin2AscHex
*                    sta       >MMU_WINDOW+80+79
*                    puls      b
*                    stb       >WORK_SLOT
*                    puls      cc,d,pc

* Bin2AscHex          anda      #$0f
*                    cmpa      #9
*                    bls       d@
*                    suba      #10
*                    adda      #'A'
*                    bra       x@
* d@                  adda      #'0'
* x@                  rts

                    emod
ModSize             equ       *
                    end


