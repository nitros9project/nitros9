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
*
*          2026/08/26  Roger Taylor
* Timer0 machinery removed: the K2 architecture is now the ONLY code
* path (Jr2 included). Init installs the WizFi F$IRQ packet on all
* machines; the ISR just clears the edges and drains the output ring;
* Read direct-pops the FIFO with tick-sleep blocking; WritSlp drains
* the ring itself and tick-polls instead of suspending on a wake that
* needed the Tx edge. No interrupt is load-bearing: the driver runs
* unchanged on bitstreams without the WizFi edges. Interrupt equates
* moved to wildbits.d (INT_WIZFI = Rx+Tx bits). Known gap: a byte
* ParkOther hands to another socket's slot is not yet picked up by
* that socket's direct-pop reader (concurrent multi-socket only).
*
*   4/1    2026/09/02  Roger Taylor
* WizCon4: four concurrent external connections (/wz0-/wz3) on the one
* WizFi360 link, plus the raw /wz port. Before this the driver served a
* single socket: the +IPD parser and its parked payload byte lived in
* each device's statics, so with several readers popping the one FIFO
* the parser fragmented and keystrokes were lost, and every device
* installed its own interrupt entries. Now: (1) the +IPD parser state
* is in the SHARED stat page and whoever pops a byte advances it;
* payload is queued per channel (32-byte RX queues) no matter who
* popped; (2) one edge entry and one tick service serve all devices
* through a device registry (DrainAll), installed by the first Init and
* handed to a survivor on Term; (3) LineWatch tracks "n,CONNECT" /
* "n,CLOSED" so delivery is link-gated (a channel hears bytes only
* while its link is up) and a client disconnect is turned into a
* hangup so login/tsmon re-arm; (4) packet-mode TX is tick-batched
* into one CIPSEND per activity burst, with a bounded prompt wait and
* abort-on-no-prompt; (5) the CIPSEND handshake pops route packet
* traffic to its queue instead of destroying it (HsPop).
* Prerequisites that made it possible: the kernel's slot-2 reservation
* and interrupt-controller scrub (fixes bundle, main), which stopped
* the fork-under-load freeze that masked every WiFi test; the WiFi Rx/
* Tx edges on INT_PENDING_3 (v8 cores; never load-bearing - the driver
* runs unchanged on cores without them); a 2-byte shared-page pointer
* that is NOT in the K2 keyboard's direct-page area (D.WZStatTbl =
* D.DbgMem); and the wiz4up/wiz4down scripts that start and stop the
* four tsmon listeners. Field-verified on the K2 and Jr2.

                    ifp1
                    use       defsfile
                    endc


* Shared stat-page pointer. MUST be a 2-byte DP slot that no wildbits
* code shares: D.DbgMem ($0A-$0B, os9.d "Debug memory pointer") is used
* by nothing on wildbits. NEVER use $00-$09 - that is the K2 keyboard's
* D.RowState/D.WBKKyDn (see 2026/09/02 history entry: the original
* choice, D.SWPage at $03, was rewritten by every keystroke).
D.WZStatTbl         equ       D.DbgMem            2-byte DP slot, unused on wildbits (was D.SWPage $03 - K2 keyboard territory)
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
vpr_stat            rmb       1                   bit7 = queue non-empty (chan in bits 1:0)
vpr_data            rmb       1                   legacy single-byte park (unused)
vpr_rd              rmb       1                   receive queue read index
vpr_wr              rmb       1                   receive queue write index
vpr_recsz           equ       8                   slot record stride in the stat page

* Per-channel receive queues in the D.WZStatTbl page: 4 slot records
* (8 bytes each at chan*8), then four 32-byte rings at $20 + chan*32.
* Replaces the single parked byte, which lost all but the last byte of
* any multi-byte +IPD run arriving during a CIPSEND handshake.
vpq_rings           equ       $20
vpq_size            equ       32
vpq_mask            equ       vpq_size-1

* WizCon4: the +IPD parser state is SHARED, in the stat page - the
* hardware FIFO is one stream, so whichever context pops a byte (any
* device's reader, any handshake HsPop) must advance THE parser, not a
* per-device copy. Four concurrent connections with per-device parser
* state fragmented headers across readers. Page offsets $A0+:
wzp_state           equ       $A0                 IRQ_State_ListenPkt or 0=data phase
wzp_ipdlen          equ       $A1                 2 bytes: +IPD payload countdown
wzp_readpos         equ       $A3                 header match position
wzp_lenchar         equ       $A4                 current length digit for DecBin
wzp_chan            equ       $A5                 channel of the +IPD in progress
wzp_link            equ       $A6                 link bits: bit n = "n,CONNECT" seen
wzp_line            equ       $A7                 CONNECT/CLOSED line-watcher state
wzp_ldig            equ       $A8                 line-watcher latched channel bit
* Handshake evidence (prompt seen / response line done), latched by
* LineWatch whoever pops the byte; SendRing waits on these flags.
wzp_hs              equ       $A9                 WZHS_* handshake evidence flags
wzp_lfc             equ       $AA                 first printable char of current line
wzp_cool            equ       $AB                 cooldown ticks: skip IRQ drains
wzp_hup             equ       $AC                 WizCon4n: bit n = "n,CLOSED" seen, hangup pending for channel n
WZHS_PROMPT         equ       $01                 "> " send prompt seen
WZHS_LINE           equ       $02                 "S"/"E" response line completed
WZCOOLTKS           equ       30                  ~1/2 second of tick backoff

* One edge entry and one tick service serve every /wz device via this
* registry (DrainAll); the first Init installs them, Term hands them on.
wzp_devs            equ       $B0                 registry: 5 static ptrs (0 = free)
wzp_devcnt          equ       $BA                 registered device count
wzp_owner           equ       $BB                 2 bytes: installer's static
wzp_virq            equ       $C0                 shared VIRQ packet (Vi.PkSz bytes)

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
TxVIRQPkt           rmb       Vi.PkSz            60Hz tick-flush VIRQ packet (Vi.Cnt/Vi.Rst/Vi.Stat)
OutPktBuf           rmb       256

MemSize             equ       .

* Packet-mode early-flush threshold: a ring this full sends immediately
* instead of waiting for the tick, so bulk streams aren't throttled to
* tick pace (256-byte ring).
TXTHRESH            equ       192

rev                 set       4
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

***********************************************************************************
* F$IRQ packet.
* One F$IRQ entry serves BOTH WizFi sources: INT_WIZFI (defs) carries
* the Rx data edge and the Tx drain-complete edge; iService clears and
* services whichever fired.
WIIRQ_Pckt          equ       *
WIIRQ_Pckt.Flip     fcb       %00000000           the flip byte
* Mask 0: this entry never claims a poll. The WiFi edge is only a
* latency optimizer (TX drains in Write and on ticks, RX is reader-polled).
WIIRQ_Pckt.Mask     fcb       0                   NEVER match (was INT_WIZFI)
                    fcb       $F1                 the priority byte

* F$IRQ packet for the 60Hz tick-flush VIRQ (polls TxVIRQPkt+Vi.Stat):
* the clock sets Vi.IFlag there each time the repeating 1-tick count
* expires; TickSvc clears it and drains the output ring.
TickPckt            fcb       %00000000           flip byte
                    fcb       Vi.IFlag            mask: the VIRQ fired flag
                    fcb       $F1                 priority


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
* WizCon4: initialize the SHARED +IPD parser (once, with the page)
                    ldx       >D.WZStatTbl
                    ldb       #IRQ_State_ListenPkt
                    stb       wzp_state,x
* WizCon4: install the SHARED interrupt plumbing once - one edge
* entry + one tick VIRQ for ALL /wz devices. Owned by this (first)
* device's static; DrainAll walks the registry.
                    stu       wzp_owner,x
* No interrupt plumbing is installed (an every-tick F$VIRQ storms the
* K2 poll walk); blocked readers are the TX flush motor instead (rdk2w@).
WzNoVq              equ       *

* Both machines use the WiFi hardware edges (INT_WIZFI), never load-bearing.
* The source is not unmasked until the end of Init: the ind_* pointers
* must exist before iService can run. Per-device work = rings + registry.
Init2               equ       *
* Register this device's static so DrainAll serves its TX ring.
                    pshs      cc
                    orcc      #IntMasks
                    ldx       >D.WZStatTbl
                    leax      wzp_devs,x
                    ldb       #5
ra1@                ldd       ,x++
                    beq       ra2@                free registry slot
                    decb
                    bne       ra1@
                    bra       ra3@                registry full: run unserved
ra2@                stu       -2,x
                    ldx       >D.WZStatTbl
                    inc       wzp_devcnt,x
ra3@                puls      cc
                    clr       OutPktLaydown,u
                    clr       OutPktPickup,u
* WizCon4: the parser is SHARED (stat page, wzp_*) and is initialized
* once in the page-allocation branch above; per-device parser fields
* are retired.

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

* WizCon4: the tick VIRQ is shared and was installed once with the
* page (see the allocation branch); nothing per-device to do here.

* INT_WIZFI stays masked: unmasked with no reader active, unsolicited
* module bytes storm the edge on both machines.
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

* Silence our interrupt sources BEFORE removing the handler: an edge
* landing after removal has no handler.
                     orcc      #IntMasks
* WizCon4 teardown: deregister this device from DrainAll first.
                     ldx       >D.WZStatTbl
                     leax      wzp_devs,x
                     ldb       #5
td1@                 cmpu      ,x++
                     beq       td2@
                     decb
                     bne       td1@
                     bra       td3@                not registered: nothing to clear
td2@                 clra
                     clrb
                     std       -2,x                free the registry slot
                     ldx       >D.WZStatTbl
                     dec       wzp_devcnt,x
td3@                 ldx       >D.WZStatTbl
                     cmpu      wzp_owner,x         did WE install the entries?
                     lbne      TermCmn             no: they stay with their owner
                     lda       wzp_devcnt,x
                     bne       TermMove            owner leaving, others remain
* Last device out: full interrupt teardown.
                     lda       >INT_MASK_3
                     ora       #INT_WIZFI          mask both WizFi edges
                     sta       >INT_MASK_3
                     ldx       >D.WZStatTbl
                     leay      wzp_virq,x
                     ldx       #$0000              delete the shared VIRQ
                     os9       F$VIRQ
                     ldx       #$0000              remove tick IRQ table entry
                     leay      TickSvc,pcr
                     os9       F$IRQ
                     ldx       #$0000              remove WizFi-edge IRQ table entry
                     os9       F$IRQ
                     lbra      TermCmn
* Owner leaving while devices remain: hand the two IRQ entries to a
* survivor (the VIRQ packet lives in the page and needs no move).
TermMove             lda       >INT_MASK_3
                     ora       #INT_WIZFI          quiesce during the handover
                     sta       >INT_MASK_3
                     ldx       #$0000              remove tick entry (our static)
                     leay      TickSvc,pcr
                     os9       F$IRQ
                     ldx       #$0000              remove edge entry (our static)
                     os9       F$IRQ
                     pshs      u                   keep SELF for exit
                     ldx       >D.WZStatTbl
                     leax      wzp_devs,x
                     ldb       #5
tm1@                 ldu       ,x++                find a survivor
                     bne       tm2@
                     decb
                     bne       tm1@
                     puls      u                   none found (shouldn't happen)
                     lbra      TermCmn
tm2@                 ldx       >D.WZStatTbl
                     stu       wzp_owner,x         survivor becomes the owner
                     ldd       #INT_PENDING_3      reinstall edge under survivor
                     leax      WIIRQ_Pckt,pcr
                     leay      iService,pcr
                     os9       F$IRQ
                     ldx       >D.WZStatTbl
                     leax      wzp_virq+Vi.Stat,x
                     tfr       x,d                 reinstall tick under survivor
                     leax      TickPckt,pcr
                     leay      TickSvc,pcr
                     os9       F$IRQ
                     puls      u                   SELF back for the SCFMan exit
                     lda       >INT_MASK_3
                     anda      #^(INT_WIZFI)       re-enable the edges
                     sta       >INT_MASK_3
TermCmn              equ       *

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
                    lslb                          8-byte records (was 4: 5-byte
                    abx                           slots overlapped their neighbor)
                    rts

* RingPtr - X -> base of channel B's 32-byte receive ring. Preserves A.
RingPtr             pshs      a
                    ldx       >D.WZStatTbl
                    andb      #3
                    lda       #vpq_size
                    mul                           D = chan * ring size
                    addd      #vpq_rings
                    leax      d,x
                    puls      a,pc

GetDevChan          pshs      d,x
                    ldd       Wrk.Type,u           save type/baud in data area
                    andb      #%00000011
* WizCon4n (2026-09-02): ind_CtrlReg is not set until later in Init, so
* this used to store through a NULL pointer into DP byte $0000 (the
* kernel DP; on the K2 that is keyboard row-state 0) on every /wzN
* Init. Only write the control register once the pointer exists.
                    ldx       ind_CtrlReg,u
                    beq       gdcnc@
                    stb       ,x                   Update WizFi Control Register
gdcnc@              ldb       V.PORT+1,u
                    tfr       b,a
                    anda      #%00001000
                    sta       DeviceMode,u
                    tfr       b,a
                    anda      #%00000011
                    sta       DevChan,u
                    puls      d,x,pc

RxFCheck            ldd       [ind_RxD_WR_CountReg,u]
                    anda      #$07
                    cmpd      #$0000
                    rts

* HsFlags - B = the shared handshake-evidence flags (wzp_hs). X,A kept.
HsFlags             pshs      x
                    ldx       >D.WZStatTbl
                    ldb       wzp_hs,x
                    puls      x,pc

* HsClear - wipe the handshake evidence for a fresh burst. Clobbers X,B.
HsClear             ldx       >D.WZStatTbl
                    ldb       wzp_hs,x
                    andb      #^(WZHS_PROMPT+WZHS_LINE)
                    stb       wzp_hs,x
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
                    lbeq      r@
                    lbsr      HsClear             stale evidence out: this burst
                    leax      strCipSend,pcr      latches its own
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
* WizCon4: the prompt is detected via the page flag (WZHS_PROMPT), which
* LineWatch latches no matter which context popped the byte - a blocked
* reader popping the prompt no longer destroys it (field: four tsmon
* readers starved the writer of every prompt and the retry timeouts,
* IRQs masked, froze the machine). An ERROR line means no prompt is
* coming: abort immediately instead of burning the full timeout.
                    ldx       #16384              bounded: module silent => abort
wsp@                lbsr      HsFlags             B = evidence (any popper's)
                    bitb      #WZHS_PROMPT
                    bne       wspr@               prompt seen: send the payload
                    bitb      #WZHS_LINE
                    bne       wspa@               a response line completed with
*                                                 no prompt (ERROR): abort now
                    lbsr      RxFCheck
                    beq       wspn@
                    lbsr      HsPop               pop: routes packets, latches flags
                    bra       wsp@
wspn@               leax      -1,x
                    bne       wsp@
* Timeout: the module is silent. ABORT this burst - pickup has not
* advanced, the ring is intact, the same bytes retry cleanly later
* (blind sends desynced the stream: "AT+CIPSEND=0,1" on the remote
* screen mid-dir). Also arm the cooldown so the IRQ-context drains
* back off: re-burning this timeout with IRQs masked on every tick is
* what froze the machine at first connect. (X is dead here: it just
* counted down to zero.)
                    ldx       >D.WZStatTbl
                    ldb       #WZCOOLTKS
                    stb       wzp_cool,x
wspa@               orcc      #Zero               nothing sent
                    bra       sr9@
* Prompt received: clear the evidence so the purge below waits on THIS
* burst's SEND OK/ERROR line, then fall into the payload push.
wspr@               lbsr      HsClear
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
* Purge the CIPSEND responses by CONTENT, not count: wait until a line
* starting with 'S' ("SEND OK") or 'E' ("ERROR") completes. WizCon4:
* completion is the page flag WZHS_LINE, latched by LineWatch in
* whichever context popped the line - a blocked reader eating the
* response no longer wedges the purge. Bounded: a dead link gives up.
srp0@               ldx       #16384              bounded wait for the S/E line
srpw@               lbsr      HsFlags             B = evidence (any popper's)
                    bitb      #WZHS_LINE          "SEND OK"/"ERROR" completed?
                    bne       xx@                 (latched by ANY popper)
                    lbsr      RxFCheck
                    beq       srpn@
                    lbsr      HsPop               pop: routes packets, latches flags
                    bra       srpw@
srpn@               leax      -1,x
                    bne       srpw@
                    bra       xx@                 timeout: give up the purge
xx@                 andcc     #^Zero              sent a burst: return Z clear
sr9@                puls      y,pc

* ISR: clear the edge and opportunistically drain the output ring.
* Receive is entirely reader-driven (Read polls and pops the hardware
* FIFO); writers never suspend (Write drains synchronously, WritSlp
* drains and tick-polls) - so the ISR wakes nobody and touches no RAM
* state. It is a latency optimization, not a dependency: the driver is
* fully functional even if this never runs.
iService            pshs      cc,dp,x
                    lda       #INT_WIZFI          clear whichever edge fired
                    sta       >INT_PENDING_3
                    lbsr      DrainAll            drain every device's queued output
* Return with carry explicitly CLEAR ('interrupt serviced'): the entry
* CC pushed at iService would otherwise be returned as-is - a random
* carry handed to the kernel's IRQ tail, which masks IRQs on carry set.
iExit               lda       ,s                  stacked entry CC
                    anda      #^Carry             force carry clear: serviced
                    sta       ,s
                    puls      cc,dp,x,pc          Recover system DP, return...

* Tick flush service: the clock's repeating 1-tick VIRQ lands here via
* the polling table (TickPckt watches TxVIRQPkt+Vi.Stat). Clear the
* fired flag (keeping the $80 repeat marker) and drain any queued
* output - the batching flush Timer0 used to provide. IRQs are masked
* in this context; SendRing is safe here (same contract as iService).
TickSvc             pshs      cc,dp,x
                    ldx       >D.WZStatTbl        shared VIRQ packet (WizCon4)
                    lda       wzp_virq+Vi.Stat,x
                    anda      #^Vi.IFlag          clear fired flag, keep repeat bit
                    sta       wzp_virq+Vi.Stat,x
* Collision avoidance: if inbound bytes are waiting, defer this tick's
* flush - a CIPSEND handshake launched into arriving +IPD traffic
* forces byte-routing work at the worst moment. HsPop makes collisions
* SAFE; this makes them RARE. Write's threshold kick still bounds
* output latency when the ring fills. (U = owner static: valid ind_*.)
                    lbsr      RxFCheck
                    bne       tksk@               input in flight: flush next tick
                    lbsr      DrainAll            flush every device's queue
tksk@               bra       iExit               exit with carry clear: serviced

* DrainAll - run SendRing for every registered device: WizCon4's one
* tick/edge serves all /wz rings. IRQ context, IRQs masked; preserves
* Y and U (SendRing preserves Y; U swapped per device and restored).
DrainAll            pshs      u,x,b
                    ldx       >D.WZStatTbl
                    ldb       wzp_cool,x          cooling off after a handshake
                    beq       da0@                timeout? skip this pass: don't
                    decb                          re-burn a masked timeout every
                    stb       wzp_cool,x          tick (that froze the machine)
                    puls      u,x,b,pc
da0@                leax      wzp_devs,x
                    ldb       #5
da1@                ldu       ,x++
                    beq       da2@                empty registry slot
                    pshs      x,b
                    lbsr      SendRing
                    puls      x,b
da2@                decb
                    bne       da1@
                    puls      u,x,b,pc

* PktByte - run one received byte (A) through the +IPD packet state
* machine. Shared by the timer ISR (Jr2) and the K2 reader-context
* direct-pop loop, so packet mode works identically on both.
* Exit: Z set   = byte was header/bookkeeping (consumed, keep reading)
*       Z clear = A is a payload byte for channel PacketChannel
PktByte             pshs      y
                    ldy       >D.WZStatTbl        WizCon4: THE shared parser
                    ldb       wzp_state,y         listening for a header?
                    cmpb      #IRQ_State_ListenPkt
                    beq       pkhdr@
                    ldx       wzp_ipdlen,y        data phase: count the byte
                    beq       pklsn@              count spent: back to listen
                    leax      -1,x
                    stx       wzp_ipdlen,y
                    andcc     #^Zero              payload byte: Z clear
                    puls      y,pc
pklsn@              ldb       #IRQ_State_ListenPkt
                    stb       wzp_state,y
                    clr       wzp_readpos,y
pkeat@              orcc      #Zero               consumed: Z set
                    puls      y,pc
pkhdr@              lbsr      LineWatch           lines, links, handshake evidence
                    leax      strIPD,pcr          point to start of IPD string constant
                    ldb       wzp_readpos,y       what character position are we at?  +  P  D  ,   ?  0-3
                    cmpb      #4
                    bls       pkmc@               go match exact chars "+IPD,"
                    cmpb      #5
                    beq       pkms@               go match a digit "0" - "3" for the socket #
                    cmpb      #6
                    bls       pkmc@               go match exact char ","
                    cmpa      #58                 match ":" terminator for +IPD string
                    beq       pkt@                terminating character
                    sta       wzp_lenchar,y       match length digits
                    ldd       wzp_ipdlen,y
                    lbsr      DecBin
                    std       wzp_ipdlen,y
pkm@                inc       wzp_readpos,y
                    bra       pkeat@
pkt@                clr       wzp_readpos,y
                    clr       wzp_state,y         switch to data mode for the next cycle
                    bra       pkeat@
pkmc@               cmpa      b,x                 match exact char from RxD FIFO
                    beq       pkm@
                    clr       wzp_readpos,y       match failed: restart the parse
                    bra       pkeat@
pkms@               clr       wzp_chan,y
                    cmpa      #'0
                    blo       pkm@
                    cmpa      #'3
                    bhi       pkm@
                    suba      #'0                 get connection # in ASCII "0" - "3"
                    sta       wzp_chan,y
                    clr       wzp_ipdlen,y
                    clr       wzp_ipdlen+1,y
                    bra       pkm@
strIPD              fcc       "+IPD,$,"            only positions 0-6 are matched

* LineWatch - runs on every listen-state byte (in parallel with the
* +IPD matcher): tracks unsolicited "n,CONNECT" / "n,CLOSED" lines and
* maintains wzp_link (bit n = channel n has an inbound link). WizCon4:
* lets accept logic see which of the 4 server connections are alive.
* Entry: A = byte, Y = stat page. Preserves A,X; clobbers B.
* wzp_line: 0 = at line start, 1 = digit latched, 2 = comma seen,
* 3 = 'C' seen, $FF = ignore until end of line.
LineWatch           cmpa      #13
                    lbeq      lwr@                CR: line boundary
                    cmpa      #10
                    lbeq      lwr@                LF: line boundary
                    ldb       wzp_line,y
                    beq       lw0@
                    cmpb      #1
                    beq       lw1@
                    cmpb      #2
                    beq       lw2@
                    cmpb      #3
                    beq       lw3@
                    rts                           $FF: skip to end of line
* n,CONNECT / n,CLOSED are matched anywhere in the line (a leading prompt
* must not hide them); the true first char is still latched once (wzp_lfc).
lw0@                tst       wzp_lfc,y           first char of this line already latched?
                    bne       lw0q@
                    sta       wzp_lfc,y           latch the line's first char
lw0q@               cmpa      #'>                 module's CIPSEND prompt?
                    bne       lw0p@
                    ldb       wzp_hs,y            latch it: the writer waits on
                    orb       #WZHS_PROMPT        this flag, so a reader popping
                    stb       wzp_hs,y            the prompt no longer destroys it
lw0p@               cmpa      #'0                 line starts with a channel digit?
                    blo       lwx@
                    cmpa      #'3
                    bhi       lwx@
                    pshs      a
                    suba      #'0
                    ldb       #1
lw0s@               tsta                          B = 1 << channel
                    beq       lw0d@
                    lslb
                    deca
                    bra       lw0s@
lw0d@               stb       wzp_ldig,y
                    puls      a
                    ldb       #1
                    stb       wzp_line,y
                    rts
lw1@                cmpa      #',                 "n," ?
                    bne       lwx@
                    ldb       #2
                    stb       wzp_line,y
                    rts
lw2@                cmpa      #'C                 "n,C" ?
                    bne       lwx@
                    ldb       #3
                    stb       wzp_line,y
                    rts
lw3@                cmpa      #'O                 "n,CO..." = CONNECT
                    bne       lw3c@
                    ldb       wzp_ldig,y
                    orb       wzp_link,y
                    stb       wzp_link,y          mark channel linked
                    ldb       wzp_ldig,y
                    comb
                    andb      wzp_hup,y
                    stb       wzp_hup,y           WizCon4n: fresh link clears any pending hangup
                    bra       lwx@
lw3c@               cmpa      #'L                 "n,CL..." = CLOSED
                    bne       lwx@
                    ldb       wzp_ldig,y
                    comb
                    andb      wzp_link,y
                    stb       wzp_link,y          mark channel unlinked
                    ldb       wzp_ldig,y
                    orb       wzp_hup,y
                    stb       wzp_hup,y           WizCon4n: hangup pending for that channel's readers
lwx@                clr       wzp_line,y          anything else: back to scanning (WizCon4p)
                    rts
lwr@                ldb       wzp_lfc,y           the completed line's first char
                    clr       wzp_lfc,y
                    clr       wzp_line,y          new line starts fresh
                    cmpb      #'S                 "SEND OK" completed?
                    beq       lwrs@
                    cmpb      #'E                 "ERROR" completed?
                    bne       lwr9@
lwrs@               ldb       wzp_hs,y
                    orb       #WZHS_LINE
                    stb       wzp_hs,y            latched: any popper reports it
lwr9@               rts

* ParkOther - K2 reader-context hand-off of a payload byte (A) that
* belongs to ANOTHER channel: park it in that channel's slot and wake
* any sleeper there. This is the only K2 receive path that still
* touches the vpr page (multi-socket flows only). IRQs must be masked.
ParkOther           pshs      a                   byte to enqueue
                    ldx       >D.WZStatTbl
                    ldb       wzp_chan,x          WizCon4: shared parser's channel
                    lbsr      GetVpPtr            X -> slot record
                    ldb       vpr_wr,x
                    incb
                    andb      #vpq_mask
                    cmpb      vpr_rd,x            ring full?
                    bne       po1@
                    lda       vpr_rd,x            overwrite oldest: bump read idx
                    inca
                    anda      #vpq_mask
                    sta       vpr_rd,x
po1@                pshs      b,x                 advanced write idx + slot ptr
                    lda       vpr_wr,x            store position
                    ldx       >D.WZStatTbl
                    ldb       wzp_chan,x          channel again (X reloaded next)
                    lbsr      RingPtr             X -> ring base (A preserved)
                    leax      a,x
                    lda       3,s                 the byte
                    sta       ,x
                    puls      b,x                 slot ptr back
                    stb       vpr_wr,x            commit the enqueue
                    pshs      x
                    ldx       >D.WZStatTbl
                    ldb       wzp_chan,x
                    puls      x
                    orb       #$80
                    stb       vpr_stat,x          mark queue non-empty
                    puls      a
                    clrb
                    lda       vpr_wake,x          sleeper on that channel?
                    beq       po9@
                    stb       vpr_wake,x          mark I/O done
                    tfr       d,x                 process descriptor page
                    lda       P$State,x
                    anda      #^Suspend
                    sta       P$State,x
po9@                rts

* HsPop - pop one RX byte during a CIPSEND handshake: packet payload is
* queued for its channel, header bytes are consumed, only line noise
* (prompt / response text) reaches the caller's matcher.
* Exit: Z clear = A holds a byte for the matcher; Z set = packet traffic.
* Preserves X,Y. IRQs must be masked. Raw mode passes everything.
HsPop               pshs      x,y
                    lda       [ind_DataReg,u]
                    ldb       DeviceMode,u
                    beq       hsm@                raw: matcher sees everything
                    lbsr      PktByte
                    bne       hsp@                payload byte: park for its socket
                    ldx       >D.WZStatTbl        consumed - header progress?
                    ldb       wzp_state,x
                    cmpb      #IRQ_State_ListenPkt
                    bne       hse@                in a packet data phase
                    ldb       wzp_readpos,x
                    bne       hse@                mid-header match
hsm@                andcc     #^Zero              matcher material
                    puls      x,y,pc
hsp@                lbsr      ParkOther
hse@                orcc      #Zero               consumed
                    puls      x,y,pc

* x bits 1..0 is socket #, bit 4 = isPacketChannel	ldd <V.PORT
Read                clrb                          default to no errors...
                    pshs      cc,dp               save IRQ/Carry status, system DP

ReadD               orcc      #IntMasks
* Parked-byte pickup FIRST: a CIPSEND handshake (HsPop) or another
* channel's reader (ParkOther) may have parked a payload byte for our
* channel. This also closes the documented multi-socket gap (parked
* hand-offs were never retrieved by direct-pop readers). Packet mode
* only: raw /wz shares slot 0 with /wz0 and must not steal its bytes.
rdpk@               ldb       DeviceMode,u
                    beq       rdk2@               raw: FIFO only
                    ldb       DevChan,u
                    lbsr      GetVpPtr            X -> our slot record
                    ldb       vpr_rd,x
                    cmpb      vpr_wr,x
                    beq       rdk2@               queue empty
                    pshs      x                   slot ptr
                    tfr       b,a                 read position
                    ldb       DevChan,u
                    lbsr      RingPtr             X -> ring base (A preserved)
                    lda       a,x                 dequeue the byte
                    puls      x                   slot ptr back
                    ldb       vpr_rd,x
                    incb
                    andb      #vpq_mask
                    stb       vpr_rd,x
                    cmpb      vpr_wr,x            drained?
                    bne       rdpkd@
                    clr       vpr_stat,x          queue empty again
rdpkd@              lbra      rdk2d@              deliver the dequeued byte
* Both machines: fully vpr-free receive - poll and pop the hardware FIFO
* directly; when empty, tick-sleep and re-poll (signals honored). No
* parking, no wake handshake, no marginal-SRAM round-trips in the path.
rdk2@               lbsr      RxFCheck            bytes waiting in the hardware FIFO?
                    beq       rdk2w@              no: tick-sleep and re-poll
                    lda       [ind_DataReg,u]     pop directly
                    ldb       DeviceMode,u        packet-mode descriptor?
                    bne       rdk2p@
* Raw pops feed LineWatch too, so link/hangup state is right no matter
* who pops the byte (a client still attached across a reboot announces
* 0,CONNECT while /wz is being drained raw).
                    pshs      y
                    ldy       >D.WZStatTbl
                    lbsr      LineWatch           track n,CONNECT / n,CLOSED from raw traffic
                    puls      y
                    bra       rdk2d@              raw: deliver as-is
rdk2p@              lbsr      PktByte             parse: +IPD headers consumed here
                    beq       rdk2@               header byte: keep reading
                    ldx       >D.WZStatTbl        payload byte: whose channel?
                    ldb       wzp_chan,x
                    cmpb      DevChan,u
                    beq       rdk2d@              ours: deliver directly
                    lbsr      ParkOther           another socket's: hand it off
                    bra       rdk2@               and keep reading for our own
* Link-gated delivery: a packet reader passes bytes only while its
* channel is linked (wzp_link bit n); the rest is dropped, so tsmon
* never forks a login on stray bytes.
rdk2d@              ldb       DeviceMode,u        packet device?
                    beq       rdk2x@              raw: always deliver
                    pshs      a,x
                    ldb       DevChan,u
                    leax      LinkTbl,pcr
                    ldb       b,x                 bit mask for our channel
                    ldx       >D.WZStatTbl
                    andb      wzp_link,x          linked?
                    puls      a,x
                    lbeq      rdk2@               no: drop the byte, keep reading
rdk2x@              puls      cc,dp,pc            deliver it (entry carry clear)
LinkTbl             fcb       1,2,4,8             channel -> wzp_link/wzp_hup bit
* Blocked-reader poll: yield the tick, honor signals, re-poll; every
* wake drains all rings (the TX flush motor).
rdk2w@              lbsr      Sleep1
                    lbsr      DrainAll            flush queued TX while we're up
                    ldx       >D.Proc
                    ldb       P$Signal,x          pending signal?
                    beq       rdk2c@
                    cmpb      #S$Intrpt
                    lbls      ErrExit
rdk2c@              ldb       P$State,x
                    bitb      #Condem
                    lbne      PrAbtErr
* WizCon4n: HANGUP EMULATION. "n,CLOSED" (LineWatch) leaves a pending
* hangup for channel n; a blocked packet-mode reader on that channel
* returns E$HangUp through the DCD-lost path, so login/shell on the
* channel exit, tsmon re-opens and waits for the next CONNECT - the
* connection lifecycle is owned by the driver, not by scripts.
                    ldb       DeviceMode,u
                    lbeq      rdpk@               raw: no lifecycle
                    ldb       DevChan,u
                    leax      LinkTbl,pcr
                    ldb       b,x
                    ldx       >D.WZStatTbl
                    bitb      wzp_hup,x           hangup pending for our channel?
                    lbeq      rdpk@               no: re-poll via parked-byte check
                    comb
                    andb      wzp_hup,x
                    stb       wzp_hup,x           consume it (one hangup per close)
                    lbra      HngUpErr            E$HangUp + PST.DCD

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

* Ring full: drain it ourselves (IRQs are masked - no ISR race), give
* up a tick honoring signals, and retry. No suspend, no wake handshake:
* the writer never depends on an interrupt to make progress. In packet
* mode a full ring flushes as one CIPSEND mid-line - acceptable, and
* only reachable when a single line exceeds the 256-byte ring.
WritSlp             lbsr      SendRing            push the ring into the TX FIFO
                    lbsr      Sleep1              breathe, honor signals
                    ldx       >D.Proc
                    ldb       P$Signal,x          pending signal for this process?
                    beq       c@                  no, go check process state...
                    cmpb      #S$Intrpt           do we honor signal?
                    lbls      ErrExit             yes, go do it...
c@                  ldb       P$State,x
                    bitb      #Condem
                    lbne      PrAbtErr            yes, go do it...
                    bra       WriteD              ring drained: lay the byte down

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
* Send kick: raw mode drains the ring on every byte, unconditionally
* (the 2048-byte hardware TX FIFO paces; gating on FIFO-empty stranded
* command tails). IRQs are masked above, so there is no race with the ISR.
                    ldb       DeviceMode,u
                    beq       WrKick              raw mode: drain on every byte
* Packet mode: no per-byte kick - bytes coalesce and leave as one
* CIPSEND per burst; only a nearly-full ring (TXTHRESH) flushes early.
                    ldb       OutPktLaydown,u
                    subb      OutPktPickup,u      pending byte count (mod 256)
                    cmpb      #TXTHRESH
                    bhs       WrKick              nearly full: flush now
                    bra       WrExit              otherwise wait for the tick
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
* Payload empty: report ready when the hardware FIFO holds bytes so the
* poller calls Read, whose pump actually delivers them - otherwise
* SS.Ready pollers (modem's listen loop) spin forever on data that is
* sitting in the FIFO. (Packet mode: FIFO content may be just header
* chars, so a Read after this can still block until real payload.)
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
                    ldy       >D.WZStatTbl                 get digit
                    ldb       wzp_lenchar,y
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


                    emod
ModSize             equ       *
                    end

