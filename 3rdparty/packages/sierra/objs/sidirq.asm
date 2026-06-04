********************************************************************
* SIDIRQ - VSYNC-IRQ-driven X-SID audio driver for CoCo3 + NitrOS-9
*
* Phase D revision (chunked-write):
*   - Drivr+Objct module, loaded via /sid descriptor at boot.
*   - VInit installs F$VIRQ + F$IRQ for 60Hz periodic execution.
*   - IRQSvc owns all SID timing.  When LoadState=2 (playing), it
*     decodes one event per voice per tick from a preloaded buffer
*     and writes the SID registers under a single MPI gate.  When
*     LoadState != 2 and ChirpEn is set, it runs the Phase B 1Hz
*     voice-3 chirp test pattern (mutually exclusive with playback).
*
*   - VGStt:
*       SS.SidCnt  ($90) - return 60Hz tick counter in R$X
*       SS.SidActv ($96) - return LoadState in R$X (0/1/2)
*
*   - VSStt:
*       SS.SidClr  ($91) - clear tick counter
*       SS.SidChrp ($92) - chirp en/dis via R$X low bit
*       SS.SidPrep ($93) - prepare for a new stream: R$Y = total
*                          stream length in bytes.  Lazy-allocs the
*                          driver-side F$SRqMem'd 16 KB buffer on
*                          first call.  Resets WritePos=0, LoadState=1.
*                          Rejected with E$DevBsy if currently playing.
*       SS.SidStart($94) - validate WritePos==StreamLen, parse the
*                          stream header, init per-voice state, set
*                          master SID regs, enter play (LoadState=2).
*       SS.SidStop ($95) - silence all voices, LoadState=1 (replay-able
*                          if WritePos==StreamLen).
*       SS.SidWrite($97) - F$Move R$Y bytes from caller's R$X into the
*                          driver buffer at WritePos; advance WritePos.
*                          Rejected if not in prep state.
*   - VTerm silences voices, frees F$SRqMem buffer, removes IRQ hooks.
*
* Stream load flow (caller side):
*     SS.SidPrep   total_len                     ; allocate, reset
*     SS.SidWrite  chunk_ptr, chunk_len           ; (repeat until full)
*     SS.SidStart                                 ; begin playback
*     poll SS.SidActv until LoadState != 2        ; wait for finish
*
* Why chunked rather than one big F$Move: the previous one-shot path
* required mnln to grow its own data area by 16 KB via F$Mem.  In the
* Sierra runtime, F$Mem's expansion can collide with sierra's manually-
* poked task-1 MMU slots for the loaded modules, producing a buffer
* address that maps onto mnln's own physical code pages.  The subsequent
* I$Read then corrupted mnln in-place -- music still played (the driver
* moved the bytes out before mnln re-executed the corrupted region) but
* the game crashed once it re-entered the damaged code.  The chunked
* path uses only a small (512 B) static buffer in mnln and lets the
* driver own the system-side 16 KB region, sidestepping F$Mem entirely.
*
* Concurrency model:
*   - LoadState is the IRQ-visibility latch.  Process code sets it
*     to 2 LAST (after all voice state is valid), and clears it
*     FIRST on stop.  IRQs are masked across non-atomic mutations.
*   - Single MPI gate around all 3 voice services per tick.
*   - U is the driver static base throughout.  Voice state fields
*     are accessed via offsets from X; buffer cursor lives in Y.
********************************************************************

                    nam       SIDIRQ
                    ttl       VSYNC-IRQ polyphonic SID driver

                    ifp1
                    use       defsfile
                    endc

* --- Custom SS.* codes (driver-private, not in os9.d) ---
SS.SidCnt           equ       $90
SS.SidClr           equ       $91
SS.SidChrp          equ       $92
SS.SidPrep          equ       $93                 was SS.SidLoad in Phase C
SS.SidStart         equ       $94
SS.SidStop          equ       $95
SS.SidActv          equ       $96
SS.SidWrite         equ       $97

* --- X-SID hardware ---
SidBase             equ       $FF40
SidV3Ctrl           equ       $FF52
SidV3AD             equ       $FF53
SidV3SR             equ       $FF54
SidFilLo            equ       $FF55
SidFilHi            equ       $FF56
SidFilRes           equ       $FF57
SidVol              equ       $FF58
MPISel              equ       $FF7F
MPISid              equ       $30

* --- Chirp tuning (Phase B test pattern) ---
ChirpMask           equ       $1F
ChirpOnTick         equ       $00
ChirpOffTick        equ       $10
ChirpFreqHi         equ       $1D
ChirpFreqLo         equ       $40

* --- Stream config ---
SidBufSize          equ       16384               16 KB stream buffer (SQ0 max=12783)
SidMinStream        equ       9                   8 hdr + >= 1 byte data
SidEvtSize          equ       5
SidEvtEnd           equ       $FFFF

* --- Per-voice state struct (12 bytes) ---
VSPtr               equ       0                   2: cursor in stream buffer
VSAvail             equ       2                   2: bytes left in voice
VSStartPtr          equ       4                   2: saved cursor for replay
VSStartAvail        equ       6                   2: saved Avail for replay
VSTick              equ       8                   2: ticks left in current note
VSMaskBit           equ       10                  1: bit in VoiceMask
VSSidOff            equ       11                  1: SidBase offset (0/7/14)
VSSize              equ       12

* --- Static device memory ---
                    org       V.SCF
VIRQPckt            rmb       5                   Cnt(2) Rst(2) Stat(1)
TickCnt             rmb       2
ChirpEn             rmb       1
SavedMPI            rmb       1
LoadState           rmb       1                   0=idle 1=loaded 2=playing
VoiceMask           rmb       1                   bit0=v1 b1=v2 b2=v3
DataPtr             rmb       2                   F$SRqMem'd buffer (0=none)
DataSize            rmb       2                   rounded size from F$SRqMem
StreamLen           rmb       2                   total stream bytes (set by SS.SidPrep)
WritePos            rmb       2                   bytes written so far (SS.SidWrite)
V1State             rmb       VSSize
V2State             rmb       VSSize
V3State             rmb       VSSize
VMem                equ       *

rev                 set       0
edition             set       1

                    mod       VEnd,VName,Drivr+Objct,ReEnt+rev,VEntry,VMem

                    fcb       UPDAT.

VName               fcs       "SIDIRQ"
                    fcb       edition

VEntry              lbra      VInit
                    lbra      VRead
                    lbra      VWrit
                    lbra      VGStt
                    lbra      VSStt
                    lbra      VTerm

IRQPckt             fcb       $00,Vi.IFlag,$0A

********************************************************************
* VInit - install IRQ + VIRQ.  Buffer alloc deferred to first Load.
********************************************************************
VInit               leax      VIRQPckt+Vi.Stat,u
                    lda       #$80
                    sta       ,x
                    tfr       x,d
                    leax      IRQPckt,pc
                    leay      IRQSvc,pc
                    os9       F$IRQ
                    bcs       VInitExit
                    ldd       #$0001
                    std       VIRQPckt+Vi.Rst,u
                    ldx       #$0001
                    leay      VIRQPckt,u
                    os9       F$VIRQ
                    bcc       VInitExit
                    pshs      cc,b
                    lbsr      VRmIRQ
                    puls      cc,b,pc
VInitExit           rts

********************************************************************
* VRead - device is write-only
********************************************************************
VRead               comb
                    ldb       #E$Read
                    rts

********************************************************************
* VWrit - silently accept (reserved for future I$Write path)
********************************************************************
VWrit               clrb
                    rts

********************************************************************
* VGStt - GetStatus dispatch
********************************************************************
VGStt               cmpa      #SS.SidCnt
                    beq       VGSttCnt
                    cmpa      #SS.SidActv
                    beq       VGSttActv
                    cmpa      #SS.Ready
                    beq       VGSttRdy
                    comb
                    ldb       #E$UnkSvc
                    rts
VGSttCnt            ldx       PD.RGS,y
                    ldd       TickCnt,u
                    std       R$X,x
                    clrb
                    rts
VGSttActv           ldx       PD.RGS,y
                    clra
                    ldb       LoadState,u
                    std       R$X,x
                    clrb
                    rts
VGSttRdy            comb
                    ldb       #E$NotRdy
                    rts

********************************************************************
* VSStt - SetStatus dispatch
********************************************************************
VSStt               cmpa      #SS.SidClr
                    lbeq      VSSttClr
                    cmpa      #SS.SidChrp
                    lbeq      VSSttChrp
                    cmpa      #SS.SidPrep
                    lbeq      VSSttPrep
                    cmpa      #SS.SidWrite
                    lbeq      VSSttWrite
                    cmpa      #SS.SidStart
                    lbeq      VSSttStart
                    cmpa      #SS.SidStop
                    lbeq      VSSttStop
                    comb
                    ldb       #E$UnkSvc
                    rts

VSSttClr            ldd       #$0000
                    std       TickCnt,u
                    clrb
                    rts

* SS.SidChrp - chirp en/dis via R$X low bit; ignored while playing.
VSSttChrp           lda       LoadState,u
                    cmpa      #2
                    beq       VSChrpOK
                    ldx       PD.RGS,y
                    ldb       R$X+1,x
                    bitb      #$01
                    beq       VSChrpDis
                    lda       #$01
                    sta       ChirpEn,u
                    clrb
                    rts
VSChrpDis           clr       ChirpEn,u
                    pshs      cc
                    orcc      #IntMasks
                    lda       >MPISel
                    sta       SavedMPI,u
                    lda       #MPISid
                    sta       >MPISel
                    lda       #$10
                    sta       >SidV3Ctrl
                    lda       SavedMPI,u
                    sta       >MPISel
                    puls      cc
VSChrpOK            clrb
                    rts

* SS.SidPrep - prepare for a new stream load.
*   R$Y = total stream length in bytes.
*   Rejects with E$DevBsy if currently playing (LoadState=2).
*   Lazy-allocates the 16 KB system buffer on first call.
*   Resets WritePos=0, LoadState=1 (loaded but caller must write data).
VSSttPrep           lda       LoadState,u
                    cmpa      #2
                    bne       VSPrep1
                    comb
                    ldb       #E$DevBsy
                    rts

VSPrep1             clr       LoadState,u         invalidate any prior load
                    clr       VoiceMask,u
                    ldd       #$0000              reset WritePos
                    std       WritePos,u
                    ldx       PD.RGS,y
                    ldd       R$Y,x
                    cmpd      #SidMinStream
                    blo       VSPrepBadArg
                    cmpd      #SidBufSize
                    bhi       VSPrepBadArg
                    std       StreamLen,u

                    ldd       DataPtr,u
                    bne       VSPrepHaveBuf
* First-time allocation.
                    pshs      y,u                 save path desc + driver static
                    ldd       #SidBufSize
                    os9       F$SRqMem
                    bcs       VSPrepAFail
                    tfr       u,x                 X = buffer addr
                    puls      y,u
                    stx       DataPtr,u
                    std       DataSize,u
                    bra       VSPrepHaveBuf
VSPrepAFail         puls      y,u
                    rts

VSPrepHaveBuf       lda       #$01
                    sta       LoadState,u         loaded, awaiting writes
                    clrb
                    rts

VSPrepBadArg        ldb       #E$IllArg
                    comb
                    rts

* SS.SidWrite - F$Move caller(R$X, R$Y) into buffer at WritePos.
*   Requires LoadState=1 (not idle, not playing).
*   Bounds check via subtraction: R$Y must be <= (StreamLen-WritePos).
*   0-byte writes succeed as no-op.
*   On success, advances WritePos by R$Y.
*
* Stack layout while F$Move args are being built (low to high):
*   [,s] = dest_addr (DataPtr+WritePos)
*   [2,s] = src_addr  (R$X from caller)
*   [4,s] = driver static (saved U for restore after F$Move)
*   [6,s] = count    (R$Y, kept for post-F$Move WritePos advance)
VSSttWrite          lda       LoadState,u
                    cmpa      #1
                    lbne      VSWriteBad
                    ldx       PD.RGS,y
                    ldd       R$Y,x               D = bytes requested
                    beq       VSWriteOK           0-byte write = no-op
                    pshs      d                   [,s] = count
                    ldd       StreamLen,u
                    subd      WritePos,u          D = remaining capacity
                    cmpd      ,s                  remaining >= count?
                    bhs       VSWriteCapOK
                    leas      2,s                 pop count
                    bra       VSWriteBad

VSWriteCapOK        pshs      u                   [,s] = static  [2,s] = count
                    ldd       R$X,x               D = caller src ptr
                    pshs      d                   [,s] = src ...
                    ldd       DataPtr,u
                    addd      WritePos,u          D = dest
                    pshs      d                   [,s] = dest [2,s] = src [4,s] = static [6,s] = count
                    ldx       <D.Proc
                    lda       P$Task,x            A = caller task
                    ldb       <D.SysTsk           B = system task
                    puls      u                   U = dest
                    puls      x                   X = src
                    ldy       2,s                 Y = count (peek; static at [,s])
                    os9       F$Move
                    puls      u                   restore driver static
                    bcs       VSWriteFFail
                    puls      d                   D = count
                    addd      WritePos,u
                    std       WritePos,u
                    clrb
                    rts

VSWriteFFail        leas      2,s                 pop count
                    rts                           carry set, B holds F$Move err

VSWriteBad          comb
                    ldb       #E$IllArg
                    rts

VSWriteOK           clrb
                    rts

* SS.SidStart - validate complete prep, parse header, init voice state,
*               set master SID regs, enter play (LoadState=2).
*   Requires LoadState=1 AND WritePos==StreamLen (full data received).
*   Header layout (8 bytes at DataPtr):
*     [0..1] v1off (offset of voice 1 events; must be >= 8)
*     [2..3] v2off
*     [4..5] v3off
*     [6..7] total_ticks (informational, not validated)
*   Constraint: v1off <= v2off <= v3off <= StreamLen.
VSSttStart          lda       LoadState,u
                    cmpa      #1
                    lbne      VSStartNoData
                    ldd       WritePos,u
                    cmpd      StreamLen,u
                    lbne      VSStartNoData       incomplete prep

* Validate header: v1off >= 8, v1off <= v2off <= v3off <= StreamLen.
                    ldx       DataPtr,u
                    ldd       ,x                  v1off
                    cmpd      #8
                    lblo      VSStartBadHdr
                    cmpd      2,x                 vs v2off
                    lbhi      VSStartBadHdr
                    ldd       2,x                 v2off
                    cmpd      4,x                 vs v3off
                    lbhi      VSStartBadHdr
                    ldd       4,x                 v3off
                    cmpd      StreamLen,u
                    lbhi      VSStartBadHdr

* Init V1 voice state from header.
                    leay      V1State,u
                    ldd       ,x                  v1off
                    pshs      d                   [,s] = v1off
                    addd      DataPtr,u
                    std       VSPtr,y
                    std       VSStartPtr,y
                    ldd       2,x
                    subd      ,s                  v2off - v1off = avail
                    std       VSAvail,y
                    std       VSStartAvail,y
                    leas      2,s
                    ldd       #0
                    std       VSTick,y
                    lda       #$01
                    sta       VSMaskBit,y
                    clr       VSSidOff,y

* Init V2 voice state.
                    leay      V2State,u
                    ldd       2,x                 v2off
                    pshs      d
                    addd      DataPtr,u
                    std       VSPtr,y
                    std       VSStartPtr,y
                    ldd       4,x
                    subd      ,s                  v3off - v2off
                    std       VSAvail,y
                    std       VSStartAvail,y
                    leas      2,s
                    ldd       #0
                    std       VSTick,y
                    lda       #$02
                    sta       VSMaskBit,y
                    lda       #$07
                    sta       VSSidOff,y

* Init V3 voice state.
                    leay      V3State,u
                    ldd       4,x                 v3off
                    pshs      d
                    addd      DataPtr,u
                    std       VSPtr,y
                    std       VSStartPtr,y
                    ldd       StreamLen,u
                    subd      ,s                  StreamLen - v3off
                    std       VSAvail,y
                    std       VSStartAvail,y
                    leas      2,s
                    ldd       #0
                    std       VSTick,y
                    lda       #$04
                    sta       VSMaskBit,y
                    lda       #$0E
                    sta       VSSidOff,y

* All voice state ready; configure master SID regs + enter play.
                    pshs      cc
                    orcc      #IntMasks
                    lda       >MPISel
                    sta       SavedMPI,u
                    lda       #MPISid
                    sta       >MPISel
                    clr       >SidFilLo
                    clr       >SidFilHi
                    clr       >SidFilRes
                    lda       #$0F
                    sta       >SidVol
                    lda       #$09                AD: A=0, D=9 (~750ms)
                    sta       >SidBase+5          v1 AD
                    sta       >SidBase+7+5        v2 AD
                    sta       >SidBase+14+5       v3 AD
                    lda       SavedMPI,u
                    sta       >MPISel
                    lda       #$07
                    sta       VoiceMask,u
                    lda       #$02
                    sta       LoadState,u         enter play LAST
                    puls      cc
                    clrb
                    rts
VSStartNoData       comb
                    ldb       #E$IllArg
                    rts
VSStartBadHdr       ldb       #E$IllArg
                    comb
                    rts

* SS.SidStop - silence voices, drop state to 1.
VSSttStop           lda       LoadState,u
                    cmpa      #2
                    bne       VSStopOK
                    pshs      cc
                    orcc      #IntMasks
                    lda       #$01
                    sta       LoadState,u         exit play FIRST
                    clr       VoiceMask,u
                    lda       >MPISel
                    sta       SavedMPI,u
                    lda       #MPISid
                    sta       >MPISel
                    clr       >SidBase+4
                    clr       >SidBase+7+4
                    clr       >SidBase+14+4
                    lda       SavedMPI,u
                    sta       >MPISel
                    puls      cc
VSStopOK            clrb
                    rts

********************************************************************
* VTerm - silence, free buffer, remove IRQ hooks.
********************************************************************
VTerm               clr       ChirpEn,u
                    clr       VoiceMask,u
                    clr       LoadState,u
                    pshs      cc
                    orcc      #IntMasks
                    lda       >MPISel
                    sta       SavedMPI,u
                    lda       #MPISid
                    sta       >MPISel
                    clr       >SidBase+4
                    clr       >SidBase+7+4
                    clr       >SidBase+14+4
                    lda       SavedMPI,u
                    sta       >MPISel
                    puls      cc
                    ldd       DataPtr,u
                    beq       VTermNoBuf
                    pshs      u
                    ldd       DataSize,u
                    ldu       DataPtr,u
                    os9       F$SRtMem
                    puls      u
                    ldd       #0
                    std       DataPtr,u
                    std       DataSize,u
VTermNoBuf          ldx       #$0000
                    leay      VIRQPckt,u
                    os9       F$VIRQ
                    bra       VRmIRQ

VRmIRQ              leax      VIRQPckt+Vi.Stat,u
                    tfr       x,d
                    ldx       #$0000
                    leay      IRQSvc,pc
                    os9       F$IRQ
                    rts

********************************************************************
* IRQSvc - per-tick IRQ service.  U = driver static.  IRQs masked.
********************************************************************
IRQSvc              lda       VIRQPckt+Vi.Stat,u
                    anda      #^Vi.IFlag
                    sta       VIRQPckt+Vi.Stat,u

                    ldd       TickCnt,u
                    addd      #$0001
                    std       TickCnt,u

                    lda       LoadState,u
                    cmpa      #2
                    beq       IRQPlay

                    tst       ChirpEn,u
                    beq       IRQOut
                    ldb       TickCnt+1,u
                    andb      #ChirpMask
                    cmpb      #ChirpOnTick
                    lbeq      ChirpFire
                    cmpb      #ChirpOffTick
                    lbeq      ChirpRelease
                    bra       IRQOut

IRQPlay             lda       >MPISel
                    sta       SavedMPI,u
                    lda       #MPISid
                    sta       >MPISel
                    leax      V1State,u
                    lbsr      ServiceVoice
                    leax      V2State,u
                    lbsr      ServiceVoice
                    leax      V3State,u
                    lbsr      ServiceVoice
                    lda       SavedMPI,u
                    sta       >MPISel
                    tst       VoiceMask,u
                    bne       IRQOut
                    lda       #$01
                    sta       LoadState,u
IRQOut              andcc     #^Carry
                    rts

********************************************************************
* ServiceVoice - decode/play one voice's next event.
* Entry:  U = driver static (preserved)
*         X = voice state struct
*         MPI already routed to SID by caller.
* Uses A, B, Y; preserves U, X.
********************************************************************
ServiceVoice        lda       VSMaskBit,x
                    bita      VoiceMask,u
                    beq       SVOut
                    ldd       VSTick,x
                    beq       SVNewNote
                    subd      #$0001
                    std       VSTick,x
                    bra       SVOut

SVNewNote           ldd       VSAvail,x
                    cmpd      #2
                    blo       SVDone
                    ldy       VSPtr,x
                    ldd       ,y                  duration
                    cmpd      #SidEvtEnd
                    beq       SVDone
                    ldd       VSAvail,x
                    cmpd      #SidEvtSize
                    blo       SVDone
                    ldy       VSPtr,x             Y = event ptr
                    ldd       ,y                  duration
                    beq       SVDone              dur==0 -> treat as end (defensive)
                    subd      #$0001
                    std       VSTick,x
* Compute SID register base in temp.  Use stack to free X for I/O.
                    pshs      x                   save voice state
                    ldb       VSSidOff,x
                    ldx       #SidBase
                    abx                           X = voice FL register
                    lda       3,y                 freq_hi
                    sta       1,x                 voice FH (write hi first)
                    lda       2,y                 freq_lo
                    sta       ,x                  voice FL
                    ldb       4,y                 amp_wave
                    pshs      b                   save amp_wave
                    lsrb
                    lsrb                          shift sustain into SR-hi posn
                    andb      #$F0
                    orb       #$05                release nibble
                    stb       6,x                 voice SR
                    puls      b                   amp_wave back
                    andb      #$0F                wave enum
                    beq       SVRest
                    aslb
                    aslb
                    aslb
                    aslb                          wave -> high nibble
                    stb       4,x                 CTRL: wave + gate=0
                    incb
                    stb       4,x                 CTRL: wave + gate=1 (trig)
                    bra       SVPostWave
SVRest              clr       4,x                 silence (no wave, no gate)
SVPostWave          puls      x                   restore voice state
                    leay      5,y
                    sty       VSPtr,x
                    ldd       VSAvail,x
                    subd      #5
                    std       VSAvail,x
SVOut               rts

SVDone              lda       VSMaskBit,x
                    coma
                    anda      VoiceMask,u
                    sta       VoiceMask,u
                    pshs      x
                    ldb       VSSidOff,x
                    ldx       #SidBase
                    abx
                    clr       4,x
                    puls      x
                    rts

********************************************************************
* ChirpFire / ChirpRelease - Phase B chirp test on voice 3.
* IRQ context, IRQs masked, U = driver static.
********************************************************************
ChirpFire           lda       >MPISel
                    sta       SavedMPI,u
                    lda       #MPISid
                    sta       >MPISel
                    lda       #ChirpFreqHi
                    sta       >$FF4F              v3 FH
                    lda       #ChirpFreqLo
                    sta       >$FF4E              v3 FL
                    clra
                    sta       >SidFilLo
                    sta       >SidFilHi
                    sta       >SidFilRes
                    sta       >$FF50              v3 PWL
                    sta       >$FF51              v3 PWH
                    lda       #$0F
                    sta       >SidVol
                    lda       #$08                A=0, D=8
                    sta       >SidV3AD
                    lda       #$A5                S=A, R=5
                    sta       >SidV3SR
                    lda       #$11                triangle + gate
                    sta       >SidV3Ctrl
                    lda       SavedMPI,u
                    sta       >MPISel
                    lbra      IRQOut

ChirpRelease        lda       >MPISel
                    sta       SavedMPI,u
                    lda       #MPISid
                    sta       >MPISel
                    lda       #$10
                    sta       >SidV3Ctrl
                    lda       SavedMPI,u
                    sta       >MPISel
                    lbra      IRQOut

                    emod
VEnd                equ       *
                    end
