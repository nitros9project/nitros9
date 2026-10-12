                    nam AstroSnd
                    use defsfile
                    use sound_defs.asm
                    mod SoundEnd,SoundName,Drivr+Objct,ReEnt+1,SoundEntries,SoundMemory
AS_ActLutMask       equ %00000011  MMU_MEM_CTRL bits 1:0, the active LUT
AS_StackReach       equ 32         stack bytes used below S while a slot is borrowed
                    org V.SCF
SD_Window           rmb 2
SD_Slot1            rmb 1
SD_Slot2            rmb 1
SD_Open             rmb 1
SD_Blocks           rmb 2
SD_HasBlocks        rmb 1
SD_UploadBlock      rmb 1
SD_Registered       rmb 1
SD_Running          rmb 1
SD_Enabled          rmb 1
SD_Paused           rmb 1
SD_AlienMask        rmb 1
SD_LoopCue          rmb 1
SD_SIDFrame         rmb 1
SD_SIDPointer       rmb 2
SD_SIDIndex         rmb 1
SD_SIDRegister      rmb 1
SD_Mix              rmb 2
SD_Missed           rmb 2
SD_Voices           rmb AS_Voices*AV_Bytes
SD_Synth            rmb SY_Slots*2  current frame of each running script, 0 = idle
SD_SynthStart       rmb SY_Slots*2  its first frame, for loops
SD_SynthLoop        rmb SY_Slots*2  loop to resume when a one-shot ends, 0 = none
SD_RumbleHold       rmb 1           ticks the player explosion keeps the asteroid rumble off
SD_PlayerBoom       rmb 1           ticks the player explosion still owns the explosion voices
SoundMemory         equ .
                    fcb WRITE.
SoundName           fcs /AstroSnd/
                    fcb 1
SoundEntries        lbra SoundInit
                    lbra SoundBad
                    lbra SoundBad
                    lbra SoundGet
                    lbra SoundSet
                    lbra SoundTerm

* This driver owns Timer 0. Refuse an already-unmasked Timer 0 source.
* No permanent system window: free system pages can share a slot with linked
* modules, this driver's own code included. Init picks two candidate slots
* free of this driver's code and statics; BorrowWindow adds only the stack.
SoundInit           leax SD_Window,u
                    ldb #SoundMemory-SD_Window
SoundClear          clr ,x+
                    decb
                    bne SoundClear
                    lda >INT_MASK_0
                    bita #INT_TIMER_0
                    lbeq SoundBusy
                    lda >AS_PCMStatus
                    bita #AS_PCMReady
                    lbeq SoundBusy
                    lda #$FF
                    sta SD_AlienMask,u
                    leay SlotBits,pcr
                    lda #$81           slot 0 (direct page) and 7 (I/O, vectors)
                    pshs a             stack offset 0: busy slot mask
                    leax SoundEntries,pcr
                    tfr x,d
                    lbsr BusySlot
                    leax SoundEnd-1,pcr
                    tfr x,d
                    lbsr BusySlot
                    tfr u,d
                    lbsr BusySlot
                    leax SoundMemory-1,u
                    tfr x,d
                    lbsr BusySlot
                    puls a
                    clrb
SoundSlotFind       incb
                    cmpb #7
                    bhs SoundSlotsDone
                    lsra
                    bita #1
                    bne SoundSlotFind
                    tst SD_Slot1,u
                    bne SoundSlotSecond
                    stb SD_Slot1,u
                    bra SoundSlotFind
SoundSlotSecond     stb SD_Slot2,u
SoundSlotsDone      ldb #E$NoRAM
                    tst SD_Slot2,u
                    lbeq SoundInitFailed
                    ldb #AS_SoundRAMBlocks
                    os9 F$AllRAM
                    lbcs SoundInitFailed
                    std SD_Blocks,u
                    inc SD_HasBlocks,u
                    ldd #INT_PENDING_0
                    leax SoundPacket,pcr
                    leay SoundIRQ,pcr
                    os9 F$IRQ
                    lbcs SoundInitFailed
                    inc SD_Registered,u
                    lbsr SilenceSID
                    clrb
SoundReturn         rts
SoundInitFailed     pshs b
                    lbsr SoundTerm
                    puls b
                    orcc #Carry
                    rts
SoundBusy           ldb #E$DevBsy
                    orcc #Carry
                    rts
SoundBad            ldb #E$UnkSvc
                    orcc #Carry
                    rts
SoundPacket         fcb 0,INT_TIMER_0,$F8

* Callers mask IRQs. Borrow SD_Slot1, or SD_Slot2 when the stack (S down to
* S-AS_StackReach) is in it; this driver's code and statics never are.
* Exit C clear: Y = DAT register, SD_Window = slot base, saved MMU control
* and old block on the stack for RestoreWindow. C set: neither slot free,
* nothing changed or left on the stack. X/D scratch.
BorrowWindow        puls x
                    lda >MMU_MEM_CTRL
                    pshs a
                    tfr a,b
                    andb #AS_ActLutMask
                    lslb
                    lslb
                    lslb
                    lslb
                    anda #^EDIT_LUT
                    pshs b
                    ora ,s+
                    sta >MMU_MEM_CTRL  edit the LUT the CPU runs on
                    leay -AS_StackReach,s
                    tfr y,d
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra
                    pshs a             slot of the stack's lowest reach
                    tfr s,d
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra               A = slot of S
                    puls b
                    pshs d             stack offsets: S slot 0, reach slot 1
                    ldb SD_Slot1,u
                    cmpb ,s
                    beq BorrowSecond
                    cmpb 1,s
                    bne BorrowFound
BorrowSecond        ldb SD_Slot2,u
                    cmpb ,s
                    beq BorrowNone
                    cmpb 1,s
                    beq BorrowNone
BorrowFound         leas 2,s
                    ldy #DAT.Regs
                    leay b,y
                    lda #$20
                    mul
                    tfr b,a
                    clrb
                    std SD_Window,u
                    lda ,y
                    pshs a
                    andcc #^Carry
                    jmp ,x
BorrowNone          leas 2,s
                    puls a
                    sta >MMU_MEM_CTRL
                    orcc #Carry
                    jmp ,x
* A = address high byte: mark its slot in the busy mask at 2,s.
BusySlot            lsra
                    lsra
                    lsra
                    lsra
                    lsra
                    lda a,y
                    ora 2,s
                    sta 2,s
                    rts
SlotBits            fcb 1,2,4,8,16,32,64,128
RestoreWindow       puls x
                    puls a
                    sta ,y
                    puls a
                    sta >MMU_MEM_CTRL
                    jmp ,x

* The exclusive opener fills a mapped physical bank directly with I$Read.
* Do not expose a bank once playback starts or beyond the owned allocation.
SoundGet            cmpa #AS_UploadBlock
                    beq SoundUploadBank
                    cmpa #SS.Ready
                    lbne SoundBad
                    ldx PD.RGS,y
                    ldd SD_Missed,u
                    std R$X,x
                    clrb
                    rts
SoundUploadBank     tst SD_Enabled,u
                    lbne SoundBusy
                    ldb SD_UploadBlock,u
                    cmpb #AS_SoundRAMBlocks
                    bhs SoundUploadComplete
                    addb SD_Blocks+1,u
                    clra
                    ldx PD.RGS,y
                    std R$X,x
                    clrb
                    rts
SoundUploadComplete ldb #E$EOF
                    orcc #Carry
                    rts
SoundSet            ldx PD.RGS,y
                    cmpa #SS.Open
                    beq SoundOpenPath
                    cmpa #SS.Close
                    beq SoundClosePath
                    cmpa #SS.ComSt
                    lbeq SoundOK
                    cmpa #AS_Play
                    beq SoundPlay
                    cmpa #AS_Background
                    lbeq SoundBackground
                    cmpa #AS_Pause
                    lbeq SoundPause
                    cmpa #AS_Stop
                    lbeq SoundStop
                    cmpa #AS_Start
                    lbeq SoundStart
                    cmpa #AS_Loop
                    lbeq SoundLoop
                    cmpa #AS_UploadDone
                    beq SoundCommitBank
                    lbra SoundBad
SoundCommitBank     tst SD_Enabled,u
                    lbne SoundBusy
                    lda SD_UploadBlock,u
                    cmpa #AS_SoundRAMBlocks
                    lbhs SoundBad
                    inc SD_UploadBlock,u
                    clrb
                    rts
SoundOpenPath       tst SD_Open,u
                    lbne SoundBusy
                    inc SD_Open,u
                    clrb
                    rts
SoundClosePath      clr SD_Open,u
                    lbra SoundStop
* X.low = effect 1-8 (sound_assets.asm order). The original board made these
* in analog circuits; here the SID and PSG play per-frame register scripts.
SoundPlay           tst SD_Enabled,u
                    lbeq SoundBusy
                    ldb R$X+1,x
                    lbeq SoundBad
                    cmpb #ASoundCount
                    lbhi SoundBad
* A new effect never steps on one still running on its slot: it is dropped.
* An explosion over a fading alien explosion replaces it between frames; its
* script's first frame gates the SID voice and the PSG noise off, so it starts
* from a released envelope. A running ship explosion is never cut.
                    pshs b,y
                    decb
                    leay SynthSlotOf,pcr
                    ldb b,y
                    lslb
                    leay SD_Synth,u
                    ldd b,y            the slot's current frame, 0 = idle
                    beq SoundPlayFree
                    ldb ,s             the effect
                    cmpb #3            short explosion: an alien
                    blo SoundPlayBusy
                    cmpb #4            long explosion: the ship
                    bhi SoundPlayBusy
                    leay SynthScripts,pcr
                    ldd 6,y            long explosion offset (effect 4)
                    leay d,y
                    cmpy SD_SynthStart+2,u
                    bne SoundPlayFree  an alien explosion: replace it
SoundPlayBusy       puls b,y
                    bra SoundPlayDone
SoundPlayFree       puls b,y
                    lbsr StartEffect
SoundPlayDone       clrb
                    rts
* B = effect 1-8, its slot idle or a fading alien explosion: start its one-shot. The player's explosion
* also overrides the asteroid rumble while it sounds; asteroid explosions
* layer over the rumble on their own voices. Preserve D,X,Y,U.
StartEffect         pshs d
                    clra               a one-shot
                    lbsr StartSynth
                    cmpb #4            long explosion: the player is hit
                    bne StartEffectDone
                    lda #AS_RumbleHold
                    sta SD_PlayerBoom,u
                    lda SD_LoopCue,u
                    cmpa #8
                    bne StartEffectDone
                    clr SD_Synth+10,u  asteroid loop slot idle
                    clr SD_Synth+11,u
                    lda #AS_RumbleHold
                    sta SD_RumbleHold,u
                    lda #SID_SELECT_BOTH+AS_SIDControl
                    ldb #AS_SIDSilent
                    lbsr WriteSID
StartEffectDone     puls d,pc
* Called once per elapsed 60-Hz game tick, including catch-up ticks. SID
* oscillators run in hardware; sample IRQs are unnecessary for envelopes.
SoundBackground     lda R$X+1,x
                    sta SD_AlienMask,u
                    tst SD_Enabled,u
                    lbeq SoundOK
                    tst SD_Paused,u
                    lbne SoundOK
                    lbsr SilenceIdleHums
                    lbsr RumbleHoldTick
                    ldb #4
SoundBackgroundVoice pshs b       stack offset 0: remaining SID voices
                    lbsr UpdateSID
                    puls b
                    decb
                    bne SoundBackgroundVoice
                    lbsr RunSynth
                    clrb
                    rts
* X.low = 0 stop, 7 refill, 8 asteroids: a looping script on its own slot.
SoundLoop           ldb R$X+1,x
                    cmpb SD_LoopCue,u
                    lbeq SoundOK
                    tstb
                    beq SoundLoopAccept
                    cmpb #7
                    lblo SoundBad
                    cmpb #8
                    lbhi SoundBad
SoundLoopAccept     pshs b
                    lbsr StopLoopSynth
                    puls b
                    stb SD_LoopCue,u
                    tstb
                    lbeq SoundOK
                    lda #1             a loop
                    lbsr StartSynth
                    clrb
                    rts
SoundPause          pshs cc
                    orcc #IntMasks
                    lda R$X+1,x
                    sta SD_Paused,u
                    beq SoundResume
                    lbsr DisableSampleTimer
                    lbsr SilenceSID
                    lbsr SilenceSynth
SoundResume
SoundPauseComplete  puls cc
SoundOK             clrb
                    rts
* Configure once, but leave the timer stopped until an actual PCM cue.
SoundStart          lda SD_UploadBlock,u
                    cmpa #AS_SoundRAMBlocks
                    lbne SoundBusy
                    pshs cc
                    orcc #IntMasks
                    lbsr DisableSampleTimer
                    clr >T0_CMP
                    ldd #AS_TimerCount
                    std >T0_CMP+1
                    lda #1             clear counter on match
                    sta >T0_CMP_CTR
                    sta SD_Enabled,u
                    lbsr ClearSIDs
                    lbsr SilenceSynth
                    puls cc
                    clrb
                    rts
* Callers already mask IRQs. Preserve live X/Y cue pointers.
EnableSampleTimer   tst SD_Enabled,u
                    beq SampleTimerReturn
                    tst SD_Paused,u
                    bne SampleTimerReturn
                    tst SD_Running,u
                    bne SampleTimerReturn
                    lbsr SoundHasVoices
                    beq SampleTimerReturn
                    lda #2             reset before starting a new cue
                    sta >T0_CTR
                    lda #INT_TIMER_0
                    sta >INT_PENDING_0
                    lda >INT_MASK_0
                    anda #^INT_TIMER_0
                    sta >INT_MASK_0
                    lda #1
                    sta SD_Running,u
                    lda #9             enable, count upward
                    sta >T0_CTR
SampleTimerReturn   rts
DisableSampleTimer  clr >T0_CTR
                    lda >INT_MASK_0
                    ora #INT_TIMER_0
                    sta >INT_MASK_0
                    lda #INT_TIMER_0
                    sta >INT_PENDING_0
                    clr SD_Running,u
                    rts
SoundStop           pshs cc
                    orcc #IntMasks
                    clr SD_Enabled,u
                    lbsr DisableSampleTimer
                    lbsr SilenceSID
                    lbsr SilenceSynth
                    ldy #AS_PCMLeft
                    lbsr SoundZeroChannel
                    ldy #AS_PCMRight
                    lbsr SoundZeroChannel
                    puls cc
                    clrb
                    rts
SoundZeroChannel    ldx #32
SoundZeroWait       lda >AS_PCMStatus
                    bita #AS_PCMReady
                    bne SoundZeroNow
                    leax -1,x
                    bne SoundZeroWait
                    rts
SoundZeroNow        clra
                    clrb
                    std ,y
                    rts

* Timer 0 runs at 8 kHz only while PCM voices are active. The OS clock
* polls until all pending IRQs are gone: acknowledge AFTER bounded mixing
* so a match during this handler cannot immediately re-enter the poll loop.
SoundIRQ            tst SD_Paused,u
                    bne SoundIdleIRQ
                    lbsr SoundHasVoices
                    beq SoundIdleIRQ
                    lda >AS_PCMStatus
                    bita #AS_PCMReady
                    beq SoundNotReady
                    clra
                    clrb
                    std SD_Mix,u
                    lbsr BorrowWindow
                    bcs SoundNotReady
                    leax SD_Voices,u
                    bsr MixVoice
                    leax AV_Bytes,x
                    bsr MixVoice
                    leax AV_Bytes,x
                    bsr MixVoice
                    leax AV_Bytes,x
                    bsr MixVoice
                    lbsr RestoreWindow
                    ldd SD_Mix,u
                    std >AS_PCMLeft
                    lda >AS_PCMStatus
                    bita #AS_PCMReady
                    beq SoundNotReady
                    ldd SD_Mix,u
                    std >AS_PCMRight
SoundIRQDone        lda #INT_TIMER_0
                    sta >INT_PENDING_0
                    clrb
                    rts
SoundNotReady       ldd SD_Missed,u
                    addd #1
                    std SD_Missed,u
                    bra SoundIRQDone
SoundIdleIRQ        lbsr DisableSampleTimer
                    ldy #AS_PCMLeft
                    lbsr SoundZeroChannel
                    ldy #AS_PCMRight
                    lbsr SoundZeroChannel
                    bra SoundIRQDone
* Return Z=1 only when no one-shot or continuous PCM voice remains.
* Preserve X/Y; D and CC scratch. Test both bytes, not just a length's low.
SoundHasVoices      pshs x
                    leax SD_Voices,u
                    ldd AV_Left,x
                    ora AV_Left+AV_Bytes,x
                    orb AV_Left+AV_Bytes+1,x
                    ora AV_Left+2*AV_Bytes,x
                    orb AV_Left+2*AV_Bytes+1,x
                    ora AV_Left+3*AV_Bytes,x
                    orb AV_Left+3*AV_Bytes+1,x
                    ora AV_LoopLength+3*AV_Bytes,x
                    orb AV_LoopLength+3*AV_Bytes+1,x
                    pshs a         stack offset 0: combined high length bytes
                    orb ,s+
                    puls x,pc
MixVoice            ldd AV_Left,x
                    bne MixHaveSample
                    ldd AV_LoopLength,x
                    beq MixReturn
                    std AV_Left,x
                    lda AV_LoopBank,x
                    sta AV_Block,x
                    ldd AV_LoopOffset,x
                    std AV_Offset,x
                    ldd AV_Left,x
MixHaveSample
                    subd #2
                    std AV_Left,x
                    lda AV_Block,x
                    sta ,y
                    pshs x
                    ldd AV_Offset,x
                    addd SD_Window,u
                    tfr d,x
                    ldd ,x
                    puls x
                    addd SD_Mix,u
                    bvc MixStore
                    bpl MixNegative
                    ldd #$7FFF
                    bra MixStore
MixNegative         ldd #$8000
MixStore            std SD_Mix,u
                    ldd AV_Offset,x
                    addd #2
                    cmpd #AS_BlockBytes
                    blo MixOffset
                    inc AV_Block,x
                    clra
                    clrb
MixOffset           std AV_Offset,x
MixReturn           rts

* Four autonomous SID pulse oscillators follow frequency/duty controls
* measured from the four original circuit outputs. The control envelope is
* updated once per elapsed 60-Hz logic tick, before rendering a new frame.
UpdateSID           pshs cc
                    orcc #IntMasks
                    lbsr BorrowWindow
                    lbcs SIDWindowDone
                    ldb SD_Blocks+1,u  the SID tables' block
                    stb ,y
                    lda SD_SIDFrame,u
                    ldb #4
                    mul
                    addd SD_Window,u
                    pshs d
                    lda SD_AlienMask,u
                    bita #$80
                    puls d
                    bne SIDTableReady
                    addd #ASoundSIDWarp
SIDTableReady
                    std SD_SIDPointer,u
                    lda SD_SIDIndex,u
                    ldb #ASoundSIDBytes/4
                    mul
                    lslb
                    rola
                    lslb
                    rola
                    addd SD_SIDPointer,u
                    std SD_SIDPointer,u
SIDNextVoice        ldb SD_SIDIndex,u
                    leax SIDEnableBits,pcr
                    lda b,x
                    anda SD_AlienMask,u
                    lbne SIDVolume     not playing: its voice may carry another invader
                    lbsr HumRank       A = active invaders before this one
                    cmpa #2
                    lbhs SIDVolume     only two hum voices
                    ldb #7
                    mul
                    addb #SID_SELECT_BOTH
                    stb SD_SIDRegister,u
                    ldx SD_SIDPointer,u
                    lda SD_SIDRegister,u
                    ldb 1,x
                    lbsr WriteSID
                    inca
                    ldb ,x
                    lbsr WriteSID
                    inca
                    ldb 3,x
                    lbsr WriteSID
                    inca
                    ldb 2,x
                    lbsr WriteSID
                    inca
                    ldb #AS_SIDPulse
                    bra SIDGate
SIDGate             lbsr WriteSID
                    inca
                    clrb
                    lbsr WriteSID
                    inca
                    ldb #AS_HumSustain sustain 6 of 15: the hums at 40% volume
                    lbsr WriteSID
SIDVolume           lda #SID_SELECT_BOTH+AS_SIDVolume
                    ldb #AS_SIDLoud
                    lbsr WriteSID
                    lbsr RestoreWindow
SIDWindowDone       puls cc
                    inc SD_SIDIndex,u
                    lda SD_SIDIndex,u
                    cmpa #4
                    blo SIDUpdated
                    clr SD_SIDIndex,u
                    inc SD_SIDFrame,u
                    lda SD_SIDFrame,u
                    cmpa #ASoundSIDFrames
                    blo SIDUpdated
                    clr SD_SIDFrame,u
SIDUpdated          rts
SIDEnableBits       fcb 1,2,4,8

* B = invader 0-3: A = how many invaders before it are playing (enable bit
* clear in SD_AlienMask). Preserve B,X,Y,U.
HumRank             pshs b,x
                    pshs b             stack offset 0: invaders left to check
                    clra
                    leax SIDEnableBits,pcr
HumRankNext         tst ,s
                    beq HumRankDone
                    dec ,s
                    ldb ,x+
                    andb SD_AlienMask,u
                    bne HumRankNext
                    inca
                    bra HumRankNext
HumRankDone         leas 1,s
                    puls b,x,pc

* After the player's explosion, bring the asteroid rumble back if the field
* is still playing its loop. Preserve U.
RumbleHoldTick      tst SD_PlayerBoom,u
                    beq RumbleHoldRumble
                    dec SD_PlayerBoom,u
RumbleHoldRumble    tst SD_RumbleHold,u
                    beq RumbleHoldDone
                    dec SD_RumbleHold,u
                    bne RumbleHoldDone
                    lda SD_LoopCue,u
                    cmpa #8
                    bne RumbleHoldDone
                    ldx SD_SynthLoop+10,u
                    stx SD_Synth+10,u
                    stx SD_SynthStart+10,u
RumbleHoldDone      rts

* Hums sit on voices 1-2 of BOTH SIDs, so they are centered in stereo. Gate
* off a hum voice no playing invader uses; voice 1 carries the asteroid loop
* while it runs (the field has no hums). Preserve U.
SilenceIdleHums     pshs d
                    ldb #4
                    lbsr HumRank       A = invaders playing
                    cmpa #2
                    bhs SilenceIdleDone
                    pshs a
                    lda #SID_SELECT_BOTH+7+AS_SIDControl
                    ldb #AS_SIDSilent
                    lbsr WriteSID
                    puls a
                    tsta
                    bne SilenceIdleDone
                    ldb SD_LoopCue,u
                    cmpb #8
                    beq SilenceIdleDone
                    lda #SID_SELECT_BOTH+AS_SIDControl
                    ldb #AS_SIDSilent
                    lbsr WriteSID
SilenceIdleDone     puls d,pc

* A=SID register including chip select, B=value. One atomic selector/data pair.
WriteSID            pshs cc
                    orcc #IntMasks
                    sta >SID_SELECT_PORT
                    stb >SID_DATA_PORT
                    puls cc,pc
* B = effect 1-8, A = 0 one-shot or nonzero loop: start its script on its
* slot; a loop is also recorded to resume after one-shots. Preserve U.
StartSynth          pshs d,x,y
                    decb
                    pshs b             stack offset 0: effect index, 1: loop flag
                    leax SynthScripts,pcr
                    lslb
                    ldd b,x
                    leax d,x           x = the script
                    ldb ,s+
                    leay SynthSlotOf,pcr
                    ldb b,y
                    lslb
                    leay SD_Synth,u
                    stx b,y
                    leay SD_SynthStart,u
                    stx b,y
                    tst ,s             loop flag (saved A)
                    beq StartSynthDone
                    leay SD_SynthLoop,u
                    stx b,y
StartSynthDone      puls d,x,y,pc
* Slot of each effect: 0 left PSG tone 2 (player laser), 1 voice 3 of both
* SIDs plus PSG noise clocked by both tone 3s (explosions: loud, low, both
* speakers), 2 right PSG tone 1 (enemy laser), 3 left PSG tone 1 (bonus box
* and docking sonar, never together), 5 both SIDs voice 1 (asteroid loop,
* centered with the hums, which the field does not play), 6 right PSG tone
* 2 (refill loop). Stereo as the OS sets it: the hums, the rumble and the
* explosions are on both speakers.
SynthSlotOf         fcb 0,2,1,1,3,3,6,5

* One game tick of every running script. Preserve U.
RunSynth            pshs d,x,y
                    leay SD_Synth,u
                    ldb #SY_Slots
RunSynthSlot        pshs b             stack offset 0: slots left
                    ldx ,y
                    beq RunSynthNext
RunSynthFrame       lda ,x+
                    cmpa #$FF
                    beq RunSynthDone
                    cmpa #$FE
                    beq RunSynthLoop
                    tsta
                    beq RunSynthStore
                    pshs a             stack offset 0: writes left
RunSynthWrite       lda ,x+
                    ldb ,x+
                    tsta
                    bmi RunSynthPSG
                    lbsr WriteSID
                    bra RunSynthWrote
RunSynthPSG         bita #2
                    bne RunSynthBoth
                    bita #1
                    bne RunSynthRight
                    stb >PSG_LEFT_PORT
                    bra RunSynthWrote
RunSynthRight       stb >PSG_RIGHT_PORT
                    bra RunSynthWrote
RunSynthBoth        stb >PSG_BOTH_PORT
RunSynthWrote       dec ,s
                    bne RunSynthWrite
                    leas 1,s
RunSynthStore       stx ,y
                    bra RunSynthNext
RunSynthLoop        ldx SY_Slots*2,y   its SD_SynthStart entry
                    bra RunSynthFrame
RunSynthDone        ldx SY_Slots*4,y   its SD_SynthLoop entry
                    beq RunSynthIdle
                    stx SY_Slots*2,y
                    bra RunSynthFrame  resume the loop
RunSynthIdle        clr ,y
                    clr 1,y
RunSynthNext        leay 2,y
                    puls b
                    decb
                    bne RunSynthSlot
                    puls d,x,y,pc

* Stop the running loop (refill on slot 6, asteroids on slot 5) and silence it.
StopLoopSynth       lda SD_LoopCue,u
                    cmpa #7
                    bne StopLoopAsteroids
                    clr SD_SynthLoop+12,u refill: slot 6, right PSG tone 2
                    clr SD_SynthLoop+13,u
                    clr SD_Synth+12,u
                    clr SD_Synth+13,u
                    lda #$BF           tone 2 off
                    sta >PSG_RIGHT_PORT
                    rts
StopLoopAsteroids   cmpa #8
                    bne StopLoopNone
                    clr SD_SynthLoop+10,u asteroids: slot 5, both SIDs voice 1
                    clr SD_SynthLoop+11,u
                    clr SD_Synth+10,u
                    clr SD_Synth+11,u
                    lda #SID_SELECT_BOTH+AS_SIDControl
                    ldb #AS_SIDSilent
                    lbra WriteSID
StopLoopNone        rts

* Stop every script and silence the PSG channels they use. Preserve U.
SilenceSynth        pshs d,x
                    leax SD_Synth,u
                    ldb #SY_Slots*6    SD_Synth, SD_SynthStart, SD_SynthLoop
SilenceSynthSlot    clr ,x+
                    decb
                    bne SilenceSynthSlot
                    clr SD_LoopCue,u
                    clr SD_RumbleHold,u
                    clr SD_PlayerBoom,u
                    lda #$9F
                    sta >PSG_BOTH_PORT
                    lda #$BF
                    sta >PSG_BOTH_PORT
                    lda #$DF
                    sta >PSG_BOTH_PORT
                    lda #$FF
                    sta >PSG_BOTH_PORT
                    lda #SID_SELECT_BOTH+14+AS_SIDControl
                    ldb #AS_SIDSilent
                    lbsr WriteSID
                    puls d,x,pc

* Both SIDs from a known state: registers 0-23 zero (voices, filter cutoff,
* resonance and routing), then full volume with no filter mode. A voice another
* program left routed into the filter would otherwise play through a filter
* with no mode selected: silence. Preserve U.
ClearSIDs           pshs d
                    lda #SID_SELECT_BOTH
                    clrb
ClearSIDReg         lbsr WriteSID
                    inca
                    cmpa #SID_SELECT_BOTH+AS_SIDVolume
                    blo ClearSIDReg
                    ldb #AS_SIDLoud
                    lbsr WriteSID
                    puls d,pc

SilenceSID          pshs d
                    lda #SID_SELECT_BOTH+AS_SIDControl
                    ldb #AS_SIDSilent
                    lbsr WriteSID
                    adda #7
                    lbsr WriteSID
                    adda #7
                    lbsr WriteSID
                    lda #SID_SELECT_BOTH+AS_SIDVolume
                    clrb
                    lbsr WriteSID
                    puls d,pc

SoundTerm           tst SD_Registered,u
                    beq SoundFreeAssets
                    lbsr SoundStop
                    ldx #0
                    leay SoundIRQ,pcr
                    os9 F$IRQ
                    lbcs SoundReturn
                    clr SD_Registered,u
SoundFreeAssets     tst SD_HasBlocks,u
                    lbeq SoundOK
                    ldd SD_Blocks,u
                    ldb #AS_SoundRAMBlocks
* F$DelRAM: X=start block, B=count (unmapped physical allocations).
                    ldx SD_Blocks,u
                    os9 F$DelRAM
                    clr SD_HasBlocks,u
                    rts
                    use sound_assets.asm
                    ifne ASoundSIDBlock-AS_SoundFileBlock
                    error "AS_SoundFileBlock in sound_defs.asm must equal ASoundSIDBlock"
                    endc
                    use synth_assets.asm
                    emod
SoundEnd            equ *
                    end
