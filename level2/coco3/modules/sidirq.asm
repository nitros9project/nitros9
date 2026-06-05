********************************************************************
* SIDIRQ - VSYNC-IRQ-driven X-SID audio driver for CoCo3 + NitrOS-9
*
* High-level design
* -----------------
* The X-SID cart is a MOS 6581/8580 SID synthesizer chip plugged
* into MPI slot 1 ($FF40 base when MPI is routed to slot 1).  The
* SID exposes 3 independent voices (each with frequency, pulse-width,
* ADSR, and waveform select) plus a master volume + filter.
*
* This driver presents a /sid SCF-style device.  Audio playback is
* IRQ-driven: a single 60 Hz F$VIRQ tick wakes IRQSvc, which decodes
* up to one event from each of the 3 voice streams and writes the
* SID registers.  Process-context code never touches the SID chip
* during playback (the stream load protocol below builds buffers,
* but only IRQSvc plays them).
*
*   - Drivr+Objct module, loaded via /sid descriptor at boot.
*   - VInit installs F$VIRQ + F$IRQ for 60 Hz periodic execution.
*   - IRQSvc owns all SID timing.  When LoadState=2 (playing), it
*     decodes one event per voice per tick from a preloaded buffer
*     and writes the SID registers under a single MPI gate.  When
*     LoadState != 2 and ChirpEn is set, it runs the Phase B 1 Hz
*     voice-3 chirp test pattern (mutually exclusive with playback).
*
* Path-status protocol (defined in defs/sid.d)
* --------------------------------------------
*   GetStt (I$GetStt):
*       SS.SidCnt  ($90) - return 60 Hz tick counter in R$X
*       SS.SidActv ($96) - return LoadState in R$X (0/1/2)
*
*   SetStt (I$SetStt):
*       SS.SidClr  ($91) - clear tick counter
*       SS.SidChrp ($92) - chirp en/dis via R$X low bit
*       SS.SidPrep ($93) - prepare for a new stream: R$Y = total
*                          stream length in bytes.  Lazy-allocs the
*                          driver-side F$SRqMem'd 16 KB buffer on
*                          first call.  Resets WritePos=0,
*                          LoadState=1.  Rejected with E$DevBsy if
*                          currently playing.
*       SS.SidStart($94) - validate WritePos==StreamLen, parse the
*                          stream header, init per-voice state, set
*                          master SID regs, enter play (LoadState=2).
*       SS.SidStop ($95) - silence all voices, LoadState=1 (replay-
*                          able if WritePos==StreamLen).
*       SS.SidWrite($97) - F$Move R$Y bytes from caller's R$X into
*                          the driver buffer at WritePos; advance
*                          WritePos.  Rejected if not in prep state.
*
*   VTerm silences voices, frees the F$SRqMem buffer, removes IRQ
*   hooks.
*
* Stream load flow (caller side)
* ------------------------------
*     SS.SidPrep   total_len                     ; allocate, reset
*     SS.SidWrite  chunk_ptr, chunk_len           ; (repeat until full)
*     SS.SidStart                                 ; begin playback
*     poll SS.SidActv until LoadState != 2        ; wait for finish
*
* Why chunked rather than one big F$Move
* --------------------------------------
* The previous one-shot path required mnln to grow its own data area
* by 16 KB via F$Mem.  In the Sierra runtime, F$Mem's expansion can
* collide with sierra's manually-poked task-1 MMU slots for the
* loaded modules, producing a buffer address that maps onto mnln's
* own physical code pages.  The subsequent I$Read then corrupted
* mnln in-place -- music still played (the driver moved the bytes
* out before mnln re-executed the corrupted region) but the game
* crashed once it re-entered the damaged code.  The chunked path
* uses only a small (512 B) static buffer in mnln and lets the
* driver own the system-side 16 KB region, sidestepping F$Mem
* entirely.
*
* Concurrency model
* -----------------
*   - LoadState is the IRQ-visibility latch.  Process code sets it
*     to 2 LAST (after all voice state is valid), and clears it
*     FIRST on stop.  IRQs are masked across non-atomic mutations.
*   - Single MPI gate around all 3 voice services per tick: we
*     save the caller's MPI selection, route to SID, service all
*     three voices, then restore.  This minimizes MPI churn (one
*     gate per tick rather than three) and keeps non-SID cards in
*     the MPI quiet between SID accesses.
*   - U is the driver static base throughout.  Voice state fields
*     are accessed via offsets from X; buffer cursor lives in Y.
*
* Stream format
* -------------
* The stream buffer starts with an 8-byte header:
*   [0..1] v1off          - byte offset of voice-1 event stream
*   [2..3] v2off          - byte offset of voice-2 event stream
*   [4..5] v3off          - byte offset of voice-3 event stream
*   [6..7] total_ticks    - informational, not validated
* followed by three event sub-streams.  Each event is 5 bytes:
*   [0..1] duration       - ticks until next event for this voice
*                           ($FFFF = end-of-stream sentinel)
*   [2..3] frequency      - 16-bit raw SID frequency word
*   [4]    amp_wave       - bits 7..4 = sustain (nibble), bits 3..0
*                           = waveform enum (0 = rest/silence, else
*                           SID waveform select nibble; see ServiceVoice)
* The duration field is consumed in IRQSvc by VSTick countdown;
* freq + amp_wave are written to the SID when VSTick reaches 0.
********************************************************************

                    nam       SIDIRQ
                    ttl       VSYNC-IRQ polyphonic SID driver

                    ifp1
                    use       defsfile            ; OS-9 system equates
                    use       sid.d               ; SS.SidXxx codes + stream limits
                    endc

* -------------------------------------------------------------------
* X-SID hardware register map (all relative to MPI slot 1)
* -------------------------------------------------------------------
* SidBase + 0..6  = voice 1: FL, FH, PWL, PWH, CTRL, AD, SR
* SidBase + 7..13 = voice 2 (same layout, +7 offset)
* SidBase +14..20 = voice 3 (same layout, +14 offset)
* SidBase +21..23 = master: FilLo, FilHi, FilRes, Vol
SidBase             equ       $FF40               ; X-SID I/O base (MPI slot 1)
SidV3Ctrl           equ       $FF52               ; voice-3 control byte
SidV3AD             equ       $FF53               ; voice-3 attack/decay
SidV3SR             equ       $FF54               ; voice-3 sustain/release
SidFilLo            equ       $FF55               ; filter cutoff low
SidFilHi            equ       $FF56               ; filter cutoff high
SidFilRes           equ       $FF57               ; filter resonance / mix
SidVol              equ       $FF58               ; master volume + filter sel
MPISel              equ       $FF7F               ; MPI bank select register
MPISid              equ       $30                 ; MPI value to route slot 1 to SID

* -------------------------------------------------------------------
* Chirp tuning (Phase B test pattern; ChirpEn=1 + idle)
* -------------------------------------------------------------------
* Used by the bring-up self-test.  Roughly 1 beep per second on V3.
ChirpMask           equ       $1F                 ; TickCnt mask: 32-tick period (~0.5 s)
ChirpOnTick         equ       $00                 ; fire gate-on when (TickCnt & mask) = 0
ChirpOffTick        equ       $10                 ; fire gate-off at mid-period
ChirpFreqHi         equ       $1D                 ; SID v3 freq hi byte (~middle register)
ChirpFreqLo         equ       $40                 ; SID v3 freq lo byte

* -------------------------------------------------------------------
* Stream config / per-voice event format
* -------------------------------------------------------------------
* SidMaxStream and SidMinStream are defined in defs/sid.d (use'd above).
SidEvtSize          equ       5                   ; bytes per voice event (dur+freq+amp_wave)
SidEvtEnd           equ       $FFFF               ; duration sentinel meaning "no more events"

* -------------------------------------------------------------------
* Per-voice state struct layout (12 bytes, allocated 3x in V?State)
* -------------------------------------------------------------------
VSPtr               equ       0                   ; cursor in stream buffer (current event ptr)
VSAvail             equ       2                   ; bytes still available from VSPtr to end of voice slice
VSStartPtr          equ       4                   ; saved initial cursor for hypothetical replay
VSStartAvail        equ       6                   ; saved initial avail for hypothetical replay
VSTick              equ       8                   ; ticks remaining in current note
VSMaskBit           equ       10                  ; VoiceMask bit (1, 2, or 4)
VSSidOff            equ       11                  ; SidBase offset (0, 7, or 14) for this voice
VSSize              equ       12                  ; total size of one voice state struct

* -------------------------------------------------------------------
* Static device memory layout (kernel allocates VMem bytes per
* device instance and gives us U pointing at the first byte after
* the SCF storage area).
* -------------------------------------------------------------------
                    org       V.SCF               ; start after standard SCF static area
VIRQPckt            rmb       5                   ; F$VIRQ packet: Cnt(2) Rst(2) Stat(1)
TickCnt             rmb       2                   ; free-running 60 Hz tick counter
ChirpEn             rmb       1                   ; non-zero = run chirp test when idle
SavedMPI            rmb       1                   ; MPISel value saved across SID accesses
LoadState           rmb       1                   ; 0=idle, 1=loaded/prepped, 2=playing
VoiceMask           rmb       1                   ; bit0=v1 b1=v2 b2=v3 (cleared as voices end)
DataPtr             rmb       2                   ; F$SRqMem'd 16 KB stream buffer (0=not yet alloc'd)
DataSize            rmb       2                   ; rounded size returned by F$SRqMem (for F$SRtMem)
StreamLen           rmb       2                   ; total stream bytes (set by SS.SidPrep)
WritePos            rmb       2                   ; bytes written so far (advanced by SS.SidWrite)
V1State             rmb       VSSize              ; voice-1 runtime state
V2State             rmb       VSSize              ; voice-2 runtime state
V3State             rmb       VSSize              ; voice-3 runtime state
VMem                equ       *                   ; end of static; kernel allocates VMem bytes

rev                 set       0                   ; module revision
edition             set       1                   ; module edition

* OS-9 driver module header.
                    mod       VEnd,VName,Drivr+Objct,ReEnt+rev,VEntry,VMem

                    fcb       UPDAT.              ; access modes supported (read+write)

VName               fcs       "SIDIRQ"            ; driver name (matched by descriptor)
                    fcb       edition             ; driver edition byte

* Driver entry-point branch table.  IOMan jumps to VEntry+(N*3)
* where N is 0..5 for Init/Read/Write/GetStt/SetStt/Term.
VEntry              lbra      VInit               ; 0: initialize device
                    lbra      VRead               ; 1: read (we reject; write-only)
                    lbra      VWrit               ; 2: write (currently no-op stub)
                    lbra      VGStt               ; 3: GetStat (SS.Sid* + SS.Ready)
                    lbra      VSStt               ; 4: SetStat (SS.Sid* streaming protocol)
                    lbra      VTerm               ; 5: terminate device

* -------------------------------------------------------------------
* IRQ-polling packet used with F$IRQ:
*   byte 0 = polling-word high byte mask  (we don't poll hw status)
*   byte 1 = polling-word low byte mask   (matches our Vi.Stat byte)
*   byte 2 = priority within the IRQ polling chain
* The kernel walks installed F$IRQ devices on each IRQ; when our
* Vi.Stat byte ANDed with byte1 is non-zero, IRQSvc is invoked.
* -------------------------------------------------------------------
IRQPckt             fcb       $00,Vi.IFlag,$0A    ; polling masks + priority

********************************************************************
* VInit - install IRQ + VIRQ.  Buffer alloc deferred to first Load.
*
* On entry: U = driver static base, kernel-zeroed.
* On exit:  CC.C=0 success, CC.C=1 failure (B=error).
*
* We do TWO kernel hooks here:
*   1. F$IRQ -- registers us in the IRQ poll list.  When the kernel
*      walks the IRQ chain, it checks our Vi.Stat byte against the
*      mask in IRQPckt; if matched, it calls IRQSvc.
*   2. F$VIRQ -- creates a virtual-IRQ packet that the system clock
*      decrements every tick.  When the count reaches 0 the kernel
*      sets our Vi.IFlag in Vi.Stat (which then trips the IRQ poll
*      from #1).  Reset value of 1 means "fire every tick" = 60 Hz.
*
* If F$VIRQ fails (rare), we unwind by removing the F$IRQ hook so
* we don't leave a dead entry in the poll chain.
********************************************************************
VInit               leax      VIRQPckt+Vi.Stat,u  ; X = address of our Vi.Stat byte
                    lda       #$80                ; pre-seed Vi.Stat to non-zero so first
                    sta       ,x                  ;   poll-walk evaluates us (not strictly needed)
                    tfr       x,d                 ; D = Vi.Stat address (F$IRQ wants it in D)
                    leax      IRQPckt,pc          ; X = polling-mask packet
                    leay      IRQSvc,pc           ; Y = service routine address
                    os9       F$IRQ               ; install IRQ poll entry
                    bcs       VInitExit           ; on failure, return carry+error from kernel
                    ldd       #$0001              ; D = Vi.Rst value: reload count = 1 tick
                    std       VIRQPckt+Vi.Rst,u   ; store reload (we want fire-every-tick)
                    ldx       #$0001              ; X = initial Vi.Cnt count
                    leay      VIRQPckt,u          ; Y = address of our VIRQ packet
                    os9       F$VIRQ              ; install virtual IRQ (kernel decrements Vi.Cnt)
                    bcc       VInitExit           ; success path
                    pshs      cc,b                ; F$VIRQ failed -- save error
                    lbsr      VRmIRQ              ; tear down the F$IRQ we just installed
                    puls      cc,b,pc             ; restore error CC+B and return
VInitExit           rts                           ; CC reflects last os9 call

********************************************************************
* VRead - device is write-only.  Any read attempt fails with E$Read.
********************************************************************
VRead               comb                          ; set CC.C (signals error)
                    ldb       #E$Read             ; "read not supported"
                    rts

********************************************************************
* VWrit - silently accept (reserved for future I$Write streaming).
* Currently returns success with no side effect; SS.SidWrite via
* SetStt is the supported data-push path.
********************************************************************
VWrit               clrb                          ; B=0, CC.C=0 -> success
                    rts

********************************************************************
* VGStt - GetStatus dispatch.  A = SS code on entry, Y = path desc.
*
* Supported codes:
*   SS.SidCnt  -> R$X gets TickCnt (16-bit free-running)
*   SS.SidActv -> R$X gets LoadState (0/1/2) zero-extended
*   SS.Ready   -> always "not ready" (we don't buffer reads)
* Unknown codes fail with E$UnkSvc.
********************************************************************
VGStt               cmpa      #SS.SidCnt          ; 60 Hz tick counter query?
                    beq       VGSttCnt
                    cmpa      #SS.SidActv         ; LoadState query?
                    beq       VGSttActv
                    cmpa      #SS.Ready           ; SCF standard "data ready"?
                    beq       VGSttRdy
                    comb                          ; unknown code
                    ldb       #E$UnkSvc
                    rts

VGSttCnt            ldx       PD.RGS,y            ; X = caller's saved register block
                    ldd       TickCnt,u           ; D = current free-running tick counter
                    std       R$X,x               ; return in caller's X
                    clrb                          ; success
                    rts

VGSttActv           ldx       PD.RGS,y            ; X = caller's saved register block
                    clra                          ; zero-extend the single LoadState byte
                    ldb       LoadState,u         ; B = 0=idle, 1=loaded, 2=playing
                    std       R$X,x               ; return D = $0000/$0001/$0002 in caller's X
                    clrb                          ; success
                    rts

VGSttRdy            comb                          ; SCF "data ready"? we have nothing to read
                    ldb       #E$NotRdy           ; signal not-ready (write-only device)
                    rts

********************************************************************
* VSStt - SetStatus dispatch.  A = SS code, Y = path desc.
*
* All streaming-protocol entry points live here.  See sid.d for the
* code map and the individual handlers below for semantics.
********************************************************************
VSStt               cmpa      #SS.SidClr          ; clear tick counter?
                    lbeq      VSSttClr
                    cmpa      #SS.SidChrp         ; chirp test en/dis?
                    lbeq      VSSttChrp
                    cmpa      #SS.SidPrep         ; begin stream load?
                    lbeq      VSSttPrep
                    cmpa      #SS.SidWrite        ; push chunk to buffer?
                    lbeq      VSSttWrite
                    cmpa      #SS.SidStart        ; begin playback?
                    lbeq      VSSttStart
                    cmpa      #SS.SidStop         ; silence + stop?
                    lbeq      VSSttStop
                    comb                          ; unknown SS code
                    ldb       #E$UnkSvc
                    rts

* -------------------------------------------------------------------
* SS.SidClr - reset the 60 Hz tick counter to zero.
* -------------------------------------------------------------------
VSSttClr            ldd       #$0000              ; D = 0
                    std       TickCnt,u           ; zero the free-running counter
                    clrb                          ; success
                    rts

* -------------------------------------------------------------------
* SS.SidChrp - chirp en/dis via R$X low bit.  Ignored while playing
* so we never tangle chirp with stream playback.
* -------------------------------------------------------------------
VSSttChrp           lda       LoadState,u         ; currently playing?
                    cmpa      #2
                    beq       VSChrpOK            ; if so, silently no-op
                    ldx       PD.RGS,y            ; caller's regs
                    ldb       R$X+1,x             ; B = low byte of R$X
                    bitb      #$01                ; bit 0 = enable
                    beq       VSChrpDis           ; clear -> disable
                    lda       #$01                ; set -> enable
                    sta       ChirpEn,u
                    clrb                          ; success
                    rts
VSChrpDis           clr       ChirpEn,u           ; disable chirp
                    pshs      cc                  ; save IRQ-enable state
                    orcc      #IntMasks           ; mask IRQs around SID write
                    lda       >MPISel             ; save caller's MPI slot select
                    sta       SavedMPI,u
                    lda       #MPISid             ; route MPI to SID slot
                    sta       >MPISel
                    lda       #$10                ; v3 CTRL = triangle, gate=0 (silence)
                    sta       >SidV3Ctrl
                    lda       SavedMPI,u          ; restore caller's MPI selection
                    sta       >MPISel
                    puls      cc                  ; restore IRQ mask
VSChrpOK            clrb                          ; success
                    rts

* -------------------------------------------------------------------
* SS.SidPrep - prepare for a new stream load.
*   R$Y = total stream length in bytes (must satisfy
*         SidMinStream <= len <= SidMaxStream).
*   Rejects with E$DevBsy if currently playing (LoadState=2).
*   Lazy-allocates the 16 KB system buffer on first call (so a system
*   that loads the driver but never plays anything pays no RAM cost).
*   Resets WritePos=0, LoadState=1 (loaded; caller must SS.SidWrite).
* -------------------------------------------------------------------
VSSttPrep           lda       LoadState,u         ; busy check
                    cmpa      #2                  ; playing?
                    bne       VSPrep1             ; no -> proceed with prep
                    comb                          ; yes -> reject as busy
                    ldb       #E$DevBsy
                    rts

VSPrep1             clr       LoadState,u         ; invalidate any prior load
                    clr       VoiceMask,u         ; clear all voice-active bits
                    ldd       #$0000              ; reset write cursor
                    std       WritePos,u
                    ldx       PD.RGS,y            ; X = caller's regs
                    ldd       R$Y,x               ; D = requested stream length
                    cmpd      #SidMinStream       ; below minimum (8B hdr + >=1 data)?
                    blo       VSPrepBadArg
                    cmpd      #SidMaxStream       ; above 16 KB buffer cap?
                    bhi       VSPrepBadArg
                    std       StreamLen,u         ; lock in the stream length

                    ldd       DataPtr,u           ; buffer already allocated?
                    bne       VSPrepHaveBuf       ; yes -> skip alloc
* First-time allocation -- ask kernel for SidMaxStream bytes of
* system RAM.  We always alloc the max size, not StreamLen, so a
* later prep with a larger stream can reuse the same buffer
* without re-allocing.
                    pshs      y,u                 ; save path desc + driver static
                    ldd       #SidMaxStream       ; size in D for F$SRqMem
                    os9       F$SRqMem            ; returns ptr in U, rounded size in D
                    bcs       VSPrepAFail         ; alloc failed -> propagate error
                    tfr       u,x                 ; X = allocated buffer addr
                    puls      y,u                 ; restore path desc + driver static
                    stx       DataPtr,u           ; remember buffer addr
                    std       DataSize,u          ; ... and rounded size for F$SRtMem
                    bra       VSPrepHaveBuf
VSPrepAFail         puls      y,u                 ; restore registers
                    rts                           ; CC.C still set, B = F$SRqMem error

VSPrepHaveBuf       lda       #$01                ; LoadState = "loaded, awaiting writes"
                    sta       LoadState,u
                    clrb                          ; success
                    rts

VSPrepBadArg        ldb       #E$IllArg           ; bad stream-length argument
                    comb                          ; CC.C=1
                    rts

* -------------------------------------------------------------------
* SS.SidWrite - F$Move caller(R$X, R$Y bytes) into our buffer at
*               the current WritePos.  Used to push the stream in
*               chunks of any size; caller will typically use a
*               512 B chunk to avoid forcing memory growth in its
*               own task.
*
*   Requires LoadState=1 (not idle, not playing).
*   Bounds check via subtraction: R$Y must be <= (StreamLen-WritePos).
*   0-byte writes succeed as a no-op.
*   On success, advances WritePos by R$Y.
*
* Stack layout while F$Move args are being built (low to high):
*   [,s] = dest_addr (DataPtr+WritePos)
*   [2,s] = src_addr  (R$X from caller)
*   [4,s] = driver static (saved U for restore after F$Move)
*   [6,s] = count    (R$Y, kept for post-F$Move WritePos advance)
* -------------------------------------------------------------------
VSSttWrite          lda       LoadState,u
                    cmpa      #1                  ; must be in "prepped, awaiting data" state
                    lbne      VSWriteBad
                    ldx       PD.RGS,y            ; X = caller's regs
                    ldd       R$Y,x               ; D = bytes requested by caller
                    beq       VSWriteOK           ; 0-byte write = no-op success
                    pshs      d                   ; [,s] = count (save for bounds + post-update)
                    ldd       StreamLen,u
                    subd      WritePos,u          ; D = remaining capacity in buffer
                    cmpd      ,s                  ; remaining >= count?
                    bhs       VSWriteCapOK        ; yes -> proceed with copy
                    leas      2,s                 ; pop count
                    bra       VSWriteBad

VSWriteCapOK        pshs      u                   ; [,s]=static  [2,s]=count
                    ldd       R$X,x               ; D = caller's src ptr
                    pshs      d                   ; [,s]=src ...
                    ldd       DataPtr,u
                    addd      WritePos,u          ; D = dest = buffer + WritePos
                    pshs      d                   ; [,s]=dest [2,s]=src [4,s]=static [6,s]=count
                    ldx       <D.Proc             ; X = current process descriptor
                    lda       P$Task,x            ; A = caller's task number (for F$Move)
                    ldb       <D.SysTsk           ; B = system task number (dest lives in system map)
                    puls      u                   ; U = dest addr
                    puls      x                   ; X = src addr
                    ldy       2,s                 ; Y = byte count (peek; static still at [,s])
                    os9       F$Move              ; copy Y bytes  src->dest across task maps
                    puls      u                   ; restore driver static
                    bcs       VSWriteFFail        ; F$Move failed?
                    puls      d                   ; D = count
                    addd      WritePos,u          ; advance WritePos by count
                    std       WritePos,u
                    clrb                          ; success
                    rts

VSWriteFFail        leas      2,s                 ; pop count (CC.C and B preserved from F$Move)
                    rts                           ; carry set, B holds F$Move error code

VSWriteBad          comb                          ; signal failure
                    ldb       #E$IllArg
                    rts

VSWriteOK           clrb                          ; success (no-op write)
                    rts

* -------------------------------------------------------------------
* SS.SidStart - validate complete prep, parse header, init voice
*               state, set master SID regs, enter play (LoadState=2).
*
*   Requires LoadState=1 AND WritePos==StreamLen (full data received).
*
*   Header layout (8 bytes at DataPtr):
*     [0..1] v1off (offset of voice-1 events; must be >= 8)
*     [2..3] v2off
*     [4..5] v3off
*     [6..7] total_ticks (informational, not validated here)
*   Constraint:  8 <= v1off <= v2off <= v3off <= StreamLen
*
*   Voice slice sizes are derived from the header:
*     V1 avail = v2off - v1off
*     V2 avail = v3off - v2off
*     V3 avail = StreamLen - v3off
* -------------------------------------------------------------------
VSSttStart          lda       LoadState,u
                    cmpa      #1                  ; must be loaded but not playing
                    lbne      VSStartNoData
                    ldd       WritePos,u
                    cmpd      StreamLen,u         ; full stream received?
                    lbne      VSStartNoData       ; incomplete prep

* Validate header: v1off >= 8, v1off <= v2off <= v3off <= StreamLen.
                    ldx       DataPtr,u           ; X = buffer = header base
                    ldd       ,x                  ; D = v1off
                    cmpd      #8                  ; v1off >= 8?
                    lblo      VSStartBadHdr
                    cmpd      2,x                 ; v1off <= v2off?
                    lbhi      VSStartBadHdr
                    ldd       2,x                 ; D = v2off
                    cmpd      4,x                 ; v2off <= v3off?
                    lbhi      VSStartBadHdr
                    ldd       4,x                 ; D = v3off
                    cmpd      StreamLen,u         ; v3off <= StreamLen?
                    lbhi      VSStartBadHdr

* --- Init voice 1 from header (no SID-mask, SID register offset 0).
                    leay      V1State,u           ; Y = voice-1 state struct
                    ldd       ,x                  ; D = v1off
                    pshs      d                   ; [,s] = v1off (need it twice)
                    addd      DataPtr,u           ; absolute ptr to v1 event stream
                    std       VSPtr,y             ; cursor
                    std       VSStartPtr,y        ; replay snapshot of cursor
                    ldd       2,x                 ; v2off
                    subd      ,s                  ; v2off - v1off = V1 byte budget
                    std       VSAvail,y           ; bytes available for V1
                    std       VSStartAvail,y      ; replay snapshot
                    leas      2,s                 ; pop saved v1off
                    ldd       #0                  ; no time elapsed yet
                    std       VSTick,y            ; first IRQ tick will trigger note 1
                    lda       #$01                ; VoiceMask bit for V1
                    sta       VSMaskBit,y
                    clr       VSSidOff,y          ; SID register base offset for V1 = 0

* --- Init voice 2 (mask bit $02, SID offset 7).
                    leay      V2State,u
                    ldd       2,x                 ; v2off
                    pshs      d
                    addd      DataPtr,u
                    std       VSPtr,y
                    std       VSStartPtr,y
                    ldd       4,x                 ; v3off
                    subd      ,s                  ; v3off - v2off = V2 byte budget
                    std       VSAvail,y
                    std       VSStartAvail,y
                    leas      2,s
                    ldd       #0
                    std       VSTick,y
                    lda       #$02                ; VoiceMask bit for V2
                    sta       VSMaskBit,y
                    lda       #$07                ; SID register base offset for V2
                    sta       VSSidOff,y

* --- Init voice 3 (mask bit $04, SID offset 14).
                    leay      V3State,u
                    ldd       4,x                 ; v3off
                    pshs      d
                    addd      DataPtr,u
                    std       VSPtr,y
                    std       VSStartPtr,y
                    ldd       StreamLen,u
                    subd      ,s                  ; StreamLen - v3off = V3 byte budget
                    std       VSAvail,y
                    std       VSStartAvail,y
                    leas      2,s
                    ldd       #0
                    std       VSTick,y
                    lda       #$04                ; VoiceMask bit for V3
                    sta       VSMaskBit,y
                    lda       #$0E                ; SID register base offset for V3 (14)
                    sta       VSSidOff,y

* --- All voice state ready; configure master SID regs + enter play.
                    pshs      cc                  ; preserve IRQ-enable
                    orcc      #IntMasks           ; mask IRQs while we touch the SID
                    lda       >MPISel             ; save caller's MPI selection
                    sta       SavedMPI,u
                    lda       #MPISid             ; route MPI to SID slot
                    sta       >MPISel
                    clr       >SidFilLo           ; filter cutoff = 0
                    clr       >SidFilHi
                    clr       >SidFilRes          ; no resonance / no voice through filter
                    lda       #$0F                ; master volume = max (no filter mix)
                    sta       >SidVol
                    lda       #$09                ; A=0, D=9 (~750 ms decay) -- per-voice AD
                    sta       >SidBase+5          ; v1 AD
                    sta       >SidBase+7+5        ; v2 AD
                    sta       >SidBase+14+5       ; v3 AD
                    lda       SavedMPI,u          ; restore caller's MPI selection
                    sta       >MPISel
                    lda       #$07                ; all 3 voices active mask
                    sta       VoiceMask,u
                    lda       #$02                ; LoadState = playing
                    sta       LoadState,u         ; (set LAST -- IRQSvc will engage)
                    puls      cc                  ; restore IRQ-enable
                    clrb                          ; success
                    rts
VSStartNoData       comb                          ; not loaded or incomplete
                    ldb       #E$IllArg
                    rts
VSStartBadHdr       ldb       #E$IllArg           ; header offsets violate constraint
                    comb
                    rts

* -------------------------------------------------------------------
* SS.SidStop - silence all voices, drop state to 1.
* Safe no-op when not currently playing.
* -------------------------------------------------------------------
VSSttStop           lda       LoadState,u
                    cmpa      #2                  ; only act if currently playing
                    bne       VSStopOK
                    pshs      cc                  ; preserve IRQ state
                    orcc      #IntMasks           ; mask IRQs for atomic state mutation
                    lda       #$01                ; LoadState = "loaded, not playing"
                    sta       LoadState,u         ; (clear LAST? -- no: clear FIRST so IRQSvc disengages)
                    clr       VoiceMask,u         ; release all voices
                    lda       >MPISel             ; save caller's MPI selection
                    sta       SavedMPI,u
                    lda       #MPISid             ; route to SID
                    sta       >MPISel
                    clr       >SidBase+4          ; v1 CTRL = 0 (gate off, silence)
                    clr       >SidBase+7+4        ; v2 CTRL = 0
                    clr       >SidBase+14+4       ; v3 CTRL = 0
                    lda       SavedMPI,u
                    sta       >MPISel
                    puls      cc
VSStopOK            clrb                          ; success
                    rts

********************************************************************
* VTerm - silence, free buffer, remove IRQ hooks.
*
* Called by the kernel when the device is being detached (last close
* on the descriptor).  We must leave the SID silent and the kernel
* IRQ/VIRQ tables clean, plus give the F$SRqMem buffer back to the
* system pool.
********************************************************************
VTerm               clr       ChirpEn,u           ; halt any chirp test
                    clr       VoiceMask,u         ; release all voices
                    clr       LoadState,u         ; LoadState = idle (IRQSvc will no-op)
                    pshs      cc                  ; preserve IRQ enable
                    orcc      #IntMasks           ; mask IRQs while we touch SID
                    lda       >MPISel             ; save caller's MPI selection
                    sta       SavedMPI,u
                    lda       #MPISid             ; route to SID
                    sta       >MPISel
                    clr       >SidBase+4          ; v1 CTRL = silence
                    clr       >SidBase+7+4        ; v2 CTRL = silence
                    clr       >SidBase+14+4       ; v3 CTRL = silence
                    lda       SavedMPI,u          ; restore caller's MPI selection
                    sta       >MPISel
                    puls      cc                  ; restore IRQ enable
                    ldd       DataPtr,u           ; have a buffer to free?
                    beq       VTermNoBuf
                    pshs      u                   ; save driver static
                    ldd       DataSize,u          ; D = rounded size for F$SRtMem
                    ldu       DataPtr,u           ; U = buffer addr
                    os9       F$SRtMem            ; return memory to system pool
                    puls      u                   ; restore driver static
                    ldd       #0                  ; mark buffer as not allocated
                    std       DataPtr,u
                    std       DataSize,u
VTermNoBuf          ldx       #$0000              ; X=0 tells F$VIRQ to *remove* the entry
                    leay      VIRQPckt,u
                    os9       F$VIRQ              ; remove virtual IRQ tick
                    bra       VRmIRQ              ; tail-call to remove F$IRQ hook

* -------------------------------------------------------------------
* VRmIRQ - remove our F$IRQ hook from the kernel IRQ poll chain.
* Shared by VInit's failure path and VTerm.
* -------------------------------------------------------------------
VRmIRQ              leax      VIRQPckt+Vi.Stat,u  ; X = our Vi.Stat byte address
                    tfr       x,d                 ; D = address (F$IRQ wants D=stat ptr)
                    ldx       #$0000              ; X=0 = "remove"
                    leay      IRQSvc,pc           ; Y = service routine (match-key for removal)
                    os9       F$IRQ               ; uninstall
                    rts

********************************************************************
* IRQSvc - per-tick IRQ service.
*
* Entry conditions:
*   U = driver static base
*   IRQs masked by kernel before we're called
*   Kernel has identified us via the polling-mask match
*
* Per-tick work:
*   1. Clear our Vi.IFlag so the kernel removes us from the active
*      poll set until the next VIRQ tick re-arms us.
*   2. Increment TickCnt (visible via SS.SidCnt).
*   3. If playing -> route MPI to SID, service voices 1..3, restore
*      MPI.  If no voices remain (VoiceMask=0), drop LoadState to 1
*      so SS.SidActv reports "stream finished" and the caller can
*      see end-of-playback.
*   4. If not playing AND ChirpEn -> run the Phase B chirp pattern
*      (1 beep every ~0.5 s) for hardware bring-up.
* -------------------------------------------------------------------
IRQSvc              lda       VIRQPckt+Vi.Stat,u  ; load our IRQ stat byte
                    anda      #^Vi.IFlag          ; clear the IFlag bit
                    sta       VIRQPckt+Vi.Stat,u  ; (kernel will re-set it on next VIRQ fire)

                    ldd       TickCnt,u           ; bump the free-running 60 Hz counter
                    addd      #$0001
                    std       TickCnt,u

                    lda       LoadState,u
                    cmpa      #2                  ; playing?
                    beq       IRQPlay             ; yes -> service voices

                    tst       ChirpEn,u           ; idle: chirp test enabled?
                    beq       IRQOut              ; no -> exit
                    ldb       TickCnt+1,u         ; chirp uses low byte of tick counter
                    andb      #ChirpMask          ; mask to chirp period
                    cmpb      #ChirpOnTick        ; "gate on" tick?
                    lbeq      ChirpFire
                    cmpb      #ChirpOffTick       ; "gate off" tick?
                    lbeq      ChirpRelease
                    bra       IRQOut

IRQPlay             lda       >MPISel             ; save caller's MPI selection (single gate)
                    sta       SavedMPI,u
                    lda       #MPISid             ; route MPI to SID for this tick
                    sta       >MPISel
                    leax      V1State,u           ; service voice 1
                    lbsr      ServiceVoice
                    leax      V2State,u           ; service voice 2
                    lbsr      ServiceVoice
                    leax      V3State,u           ; service voice 3
                    lbsr      ServiceVoice
                    lda       SavedMPI,u          ; restore caller's MPI selection
                    sta       >MPISel
                    tst       VoiceMask,u         ; any voices still active?
                    bne       IRQOut              ; yes -> stay in play state
                    lda       #$01                ; all done -> LoadState = "loaded but idle"
                    sta       LoadState,u         ; SS.SidActv will now report end of stream
IRQOut              andcc     #^Carry             ; signal "IRQ handled" to kernel poll walker
                    rts

********************************************************************
* ServiceVoice - decode/play one voice's next event.
*
* Entry:  U = driver static (preserved)
*         X = voice state struct
*         MPI already routed to SID by caller (IRQPlay)
* Uses:   A, B, Y; preserves U, X
*
* Semantics per voice:
*   - If this voice's mask bit is already cleared, do nothing.
*   - If VSTick > 0, just decrement (note still sustaining).
*   - Otherwise consume the next 5-byte event:
*       * if the duration field is $FFFF (sentinel) or 0 -> end voice
*       * if avail < 2 or avail < 5 -> end voice (defensive)
*       * write the frequency to SID FH/FL (FH first per SID quirk)
*       * write SR with sustain<<4 | release=5
*       * if wave nibble == 0  -> rest: silence CTRL (no gate)
*         else                 -> write CTRL with wave<<4 + gate=0,
*                                 then again with gate=1 to trigger
*       * advance cursor by 5, decrement avail by 5
*       * set VSTick = duration-1 (we consumed 1 tick to start it)
*
* End-of-voice cleanup (SVDone):
*   - Clear this voice's bit in VoiceMask.
*   - Write CTRL=0 to silence the voice on the SID chip.
********************************************************************
ServiceVoice        lda       VSMaskBit,x         ; A = this voice's VoiceMask bit
                    bita      VoiceMask,u         ; still active?
                    beq       SVOut               ; no -> nothing to do
                    ldd       VSTick,x            ; D = ticks remaining in current note
                    beq       SVNewNote           ; if 0, time to fetch next event
                    subd      #$0001              ; otherwise decrement and keep playing
                    std       VSTick,x
                    bra       SVOut

SVNewNote           ldd       VSAvail,x           ; bytes left in voice's slice
                    cmpd      #2                  ; need at least 2 for the duration peek
                    blo       SVDone              ; too few -> end voice
                    ldy       VSPtr,x             ; Y = current event ptr
                    ldd       ,y                  ; D = duration field
                    cmpd      #SidEvtEnd          ; end-of-stream sentinel?
                    beq       SVDone
                    ldd       VSAvail,x           ; need full 5 bytes for a complete event
                    cmpd      #SidEvtSize
                    blo       SVDone              ; partial event at tail -> end voice
                    ldy       VSPtr,x             ; Y = event ptr (reload after compares)
                    ldd       ,y                  ; D = duration
                    beq       SVDone              ; dur==0 -> treat as end (defensive)
                    subd      #$0001              ; we've consumed 1 tick to start playing
                    std       VSTick,x

* Compute SID register base for this voice in X, freeing Y/D.
* Stash original voice-state-struct X on the stack so SVPostWave
* can restore it for cursor + avail updates.
                    pshs      x                   ; save voice state struct ptr
                    ldb       VSSidOff,x          ; B = 0 / 7 / 14
                    ldx       #SidBase            ; X = $FF40
                    abx                           ; X = voice FL register
                    lda       3,y                 ; freq high byte from event
                    sta       1,x                 ; voice FH (write hi first per SID hardware quirk)
                    lda       2,y                 ; freq low byte
                    sta       ,x                  ; voice FL
                    ldb       4,y                 ; amp_wave byte from event
                    pshs      b                   ; save amp_wave for waveform handling below
                    lsrb                          ; sustain nibble -> low nibble of B
                    lsrb                          ; (right-shift by 4 to move to low nibble)
                    andb      #$F0                ; isolate sustain in high nibble of SR
                    orb       #$05                ; release nibble = 5 (~250 ms)
                    stb       6,x                 ; voice SR
                    puls      b                   ; restore amp_wave
                    andb      #$0F                ; wave enum in low nibble
                    beq       SVRest              ; 0 -> silence/rest event
                    aslb                          ; shift wave enum into high nibble
                    aslb
                    aslb
                    aslb                          ; B = wave<<4
                    stb       4,x                 ; CTRL: wave + gate=0
                    incb                          ; +1 sets gate bit
                    stb       4,x                 ; CTRL: wave + gate=1 (triggers note)
                    bra       SVPostWave
SVRest              clr       4,x                 ; rest: silence (no wave, no gate)
SVPostWave          puls      x                   ; restore voice state struct ptr
                    leay      5,y                 ; advance event cursor by 5 bytes
                    sty       VSPtr,x             ; store new cursor
                    ldd       VSAvail,x
                    subd      #5                  ; consumed 5 bytes from this voice
                    std       VSAvail,x
SVOut               rts

SVDone              lda       VSMaskBit,x         ; isolate this voice's bit
                    coma                          ; invert -> mask of all other bits
                    anda      VoiceMask,u         ; clear our bit in VoiceMask
                    sta       VoiceMask,u
                    pshs      x                   ; save voice state struct ptr
                    ldb       VSSidOff,x          ; B = voice's SID register offset
                    ldx       #SidBase
                    abx                           ; X = voice's CTRL-1
                    clr       4,x                 ; CTRL = 0 (gate off, no wave -> silence)
                    puls      x                   ; restore voice state ptr
                    rts

********************************************************************
* ChirpFire / ChirpRelease - Phase B chirp test on voice 3.
*
* Called from IRQSvc when LoadState != 2 and ChirpEn is set.
* Plays a triangle-wave beep on V3 once per chirp period (about
* 0.5 s with the default ChirpMask).  This was the original
* bring-up self-test; SS.SidChrp toggles it.
*
* IRQ context, IRQs already masked, U = driver static.
********************************************************************
ChirpFire           lda       >MPISel             ; save caller's MPI selection
                    sta       SavedMPI,u
                    lda       #MPISid             ; route to SID
                    sta       >MPISel
                    lda       #ChirpFreqHi        ; v3 FH = chirp tone
                    sta       >$FF4F
                    lda       #ChirpFreqLo        ; v3 FL = chirp tone
                    sta       >$FF4E
                    clra                          ; zero filter + pulse-width regs
                    sta       >SidFilLo
                    sta       >SidFilHi
                    sta       >SidFilRes
                    sta       >$FF50              ; v3 pulse-width low
                    sta       >$FF51              ; v3 pulse-width high
                    lda       #$0F                ; master volume max
                    sta       >SidVol
                    lda       #$08                ; v3 AD: A=0, D=8
                    sta       >SidV3AD
                    lda       #$A5                ; v3 SR: S=A, R=5
                    sta       >SidV3SR
                    lda       #$11                ; v3 CTRL: triangle wave + gate=1
                    sta       >SidV3Ctrl
                    lda       SavedMPI,u          ; restore caller's MPI selection
                    sta       >MPISel
                    lbra      IRQOut              ; rejoin IRQSvc exit

ChirpRelease        lda       >MPISel             ; save caller's MPI selection
                    sta       SavedMPI,u
                    lda       #MPISid             ; route to SID
                    sta       >MPISel
                    lda       #$10                ; v3 CTRL: triangle, gate=0 (begin release)
                    sta       >SidV3Ctrl
                    lda       SavedMPI,u          ; restore caller's MPI selection
                    sta       >MPISel
                    lbra      IRQOut              ; rejoin IRQSvc exit

                    emod
VEnd                equ       *
                    end
