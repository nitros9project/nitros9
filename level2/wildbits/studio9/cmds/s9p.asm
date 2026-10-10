********************************************************************
* s9p - Studio-9 PLAY overlay, disassembled from the UltiMusE III v10.11.4e (OS-9 Level 2)
* PLAY overlay and ported. Routine names are evidence-based readings of the original. Local
* labels read a<n>@, b<n>@ ...: the letter is the label, n the routine it belongs to.
* Event pages hold 928 events ($03A0), not the original 1020 ($03FC), so a page fits the
* $1D00 visible bytes of DAT slot 7 (see GPBLKS in s9.asm); GetEventPtr carries the constant.
*
* One big C function (PlayMain, frame $1C0, args = mode, first event index, last event
* index) walks the score's 8-byte event records (voice, time, len/pitch/accidental/attr)
* through GetEventPtr/NextEvent (pages swapped by [ppswap]) and turns them into MIDI in real
* time, or writes a Standard MIDI File (format 0, 48 ticks/quarter) when smf is set.
* Live output: PutMidiByte -> MidiHwSend, s9's MIDI-byte dispatcher; file output uses s9's
* buffered writer.
* Timing: TIMER1 frame count (ReadSysTick, ReadFineTick), F$Sleep in ticks (SleepTicks), a
* 64ths-of-tick accumulator (residue) and a tick scale machtemp = contemp*denominator/tempo.
* Priority is raised to 254 with F$SPrior for the run (live play only) and restored to 140.
* Score semantics: per-voice 16-byte records (chan, cur note, note-off countdown, staff step
* offset, velocity, transpose, octave shift, articulation, last staff pos); diatonic step ->
* pitch via BuildScaleTable/BuildPitchTable (major scale + key signature, explicit
* accidentals via tblAccidental, percussion map at $0CA3); SS.KySns Shift/Ctrl held during
* play halves/doubles the waits.
* Control events dispatched by EvSwitch: bar lines 0-6 (repeat start/end with an 8-entry
* repeat stack, endings, Fine), tempo $19, time sig $0A, key sig $0B, dynamics $1A/$18,
* accent $22, crescendo $1C, tempo ramp $1D, program change $17 (patch table $075F,
* 16-char instrument names $07EB with '+'/'-' octave prefix), voice channel $16, raw
* MIDI/sysex blocks $1E/$1F, segno/coda/D.C./D.S. $08/$09/$11-$14, MIDI clock $1B
* ($FA/$FC/$F8 realtime bytes, escaped as F7 01 xx in the file).
* SMF writer: WriteMidiHeader (MThd/MTrk, title track-name meta, 9 text lines from the
* mapped extra block, part/instrument metas, time-sig/tempo/key-sig metas), running delta
* (smfdelta), running status (runstat), FinishMidiTrack (end-of-track, then patch the track
* length = file position - 22 at offset 18).
* C library tail: Microware long-math package (accumulator at $0343,y), IntMul/IntDiv/
* UIntDiv/IntMod with the divide-by-zero trap (errno 45 + F$Send to self), shift helpers,
* string helpers, write/lseek/setpr wrappers and the _os9() trampoline (SWI2/code/RTS built
* on the stack). Unlabeled fcb/fcc runs are bytes kept from the original with no known use.
*
* header: type/lang $11 attr/rev $81, data size $1050 (4176)

                    nam       s9p
                    ttl       s9p (disassembly)

                  IFP1
                    use       defsfile
                  ENDC

UME_SCOPE_S9P                  equ       1
                    use       equates.asm         addresses shared by every s9 module
tylg                set       $11
atrv                set       $81
size                equ       $1050

                    mod       eom,name,tylg,atrv,start,size
name                fcs       /s9p/
                    fcb       $07
start               equ       *
                    lbra      PlayMain
                    fcb       $39,$0D,$00
* PlayMain: overlay entry. C frame $1C0; arg low byte $1C5,s = 'a' selects an audition (no SMF, no debug prints). Live play raises the priority to $FE, builds the voice records and runs the event loop.
PlayMain            pshs      u
                    leas      >-$01C0,s
                    clr       >AuditionMode
                    ldb       >$01C5,s
                    cmpb      #'a
                    bne       pmNormal@
                    inc       >AuditionMode
                    lda       <UmeData_smf
                    ldb       <UmeData_pldebug
                    std       >AuditionSavedFlags
                    clr       <UmeData_smf
                    clr       <UmeData_pldebug
                    bra       pmReady@
pmNormal@           lbsr      ResetSAMBeforePlay
pmReady@            leax      PianoMark,pcr       from here s9's PianoDraw hands each key change
                    stx       >PianoVec           to PianoMark while MidiPlaying is set
                    clr       >PianoQN
                    inc       >MidiPlaying
* s9 acts on the PRESS, so this overlay starts while the button that chose PLAY is still
* held. PressHeld (equates.asm, a DP byte shared with s9's ReadMouse) tells CheckAbort the
* starting press may still be down: only a press that follows a release aborts.
                    ldb       #$01
                    stb       <PressHeld
                    lbsr      FindDataBlock
                    ldx       #$01A6
                    stx       <UmeData_midics
                    ldb       <UmeData_smf
                    bne       InitMidiPak
                    ldd       #$00FE
                    pshs      a,b
                    ldd       <UmeData_group
                    pshs      a,b
                    lbsr      SetPriority
                    leas      4,s
InitMidiPak         equ       *                   live MIDI devices are set up by s9
* a1@: clears broke, 11,s = average of bytes $0106/$0107, 2,s = velo, contemp = secmin*20, then inits the voice records from part 1.
a1@                 clra
                    clrb
                    std       <UmeData_broke
                    ldb       >UmeData_reserved_0106
                    sex
                    pshs      a,b
                    ldb       >UmeData_reserved_0107
                    sex
                    addd      ,s++
                    asra
                    rorb
                    std       11,s
                    ldd       <UmeData_velo
                    std       2,s
                    ldd       <UmeData_secmin
                    pshs      a,b
                    ldd       #$0014
                    lbsr      IntMul
                    std       <UmeData_contemp
                    ldd       #$0001
                    std       <UmeData_plpart
                    leax      >$009C,s
                    stx       ,s
                    lbra      InitVoiceLoopTest
* InitVoiceLoop: voice record per part 1..nparts: [0] channel (MidiChanTbl), [2] note 0, [4] off countdown 0, [6] staff step offset (GetPartStaff), [8] velocity byte $0107, [10] transpose (transp, 0 with part flag $10), [12] octave shift 0, [14] articulation 1, [15] last staff pos $20.
InitVoiceLoop       ldd       #$0001
                    ldx       ,s
                    stb       14,x
                    clra
                    clrb
                    ldx       ,s
                    std       2,x
                    ldx       ,s
                    std       4,x
                    ldb       >UmeData_reserved_0107
                    sex
                    ldx       ,s
                    std       8,x
                    ldd       #$0020
                    ldx       ,s
                    stb       15,x
                    ldd       <UmeData_plpart
                    ldx       #MidiChanTbl
                    leax      d,x
                    ldb       ,x
                    sex
                    std       [,s]
                    leax      13,s
                    pshs      x
                    ldd       2,s
                    addd      #$0006
                    pshs      a,b
                    ldd       <UmeData_plpart
                    pshs      a,b
                    lbsr      GetPartStaff
                    leas      6,s
                    ldd       13,s
                    clra
                    andb      #$10
                    beq       a2@
                    clra
                    clrb
                    bra       b2@
a2@                 ldd       <UmeData_transp
b2@                 ldx       ,s
                    std       10,x
                    clra
                    clrb
                    ldx       ,s
                    std       12,x
                    ldd       ,s
                    addd      #$0010
                    std       ,s
                    subd      #$0010
                    ldd       <UmeData_plpart
                    addd      #$0001
                    std       <UmeData_plpart
                    subd      #$0001
* InitVoiceLoopTest: loops while plpart <= nparts, then resets the play state.
InitVoiceLoopTest   ldd       <UmeData_plpart
                    cmpd      <UmeData_nparts
                    lble      InitVoiceLoop
                    ldd       #$FFFF
                    std       <UmeData_coda
                    std       <UmeData_dcds
                    std       <UmeData_dp_sign
                    std       <UmeData_nthendx
                    clra
                    clrb
                    stb       <UmeData_senzarep
                    stb       <$16,s
                    stb       <$11,s
                    clra
                    clrb
                    stb       <UmeData_sound
                    stb       <UmeData_inending
                    ldd       #$7FFF
                    std       <UmeData_takeoff
                    std       <UmeData_tilloff
                    clra
                    clrb
                    std       <UmeData_runstat
                    std       <UmeData_keysig
                    ldd       #$0078
                    std       <UmeData_tempo
                    clra
                    clrb
                    std       <UmeData_lastime
                    ldd       <UmeData_reserved_0003
                    std       <$1F,s
                    ldd       <UmeData_reserved_0005
                    std       <$1D,s
                    leax      <$19,s
                    pshs      x
                    bsr       PlaySetup
                    neg       <UmeData_reserved_0000
                    neg       <UmeData_reserved_0000
* PlaySetup: continuation after the bsr over the inline long 0 (stored to <$19,s): resets the repeat stack at frame+$19C, builds the natural and key-signature pitch tables, the tick scale and the SMF head, starts the MIDI clock.
PlaySetup           puls      x
                    lbsr      LongStore
                    leax      >$019C,s
                    stx       <UmeData_rsptr
                    clra
                    clrb
                    std       [>$00B7,y]
                    clra
                    clrb
                    ldx       <UmeData_rsptr
                    leax      4,x
                    stx       <UmeData_rsptr
                    std       -2,x
                    clra
                    clrb
                    pshs      a,b
                    leax      <$23,s
                    pshs      x
                    lbsr      BuildScaleTable
                    leas      4,s
                    leax      <$5A,s
                    pshs      x
                    leax      <$23,s
                    pshs      x
                    lbsr      BuildPitchTable
                    leas      4,s
                    ldd       <UmeData_keysig
                    pshs      a,b
                    leax      <$23,s
                    pshs      x
                    lbsr      BuildScaleTable
                    leas      4,s
                    leax      <$28,s
                    pshs      x
                    leax      <$23,s
                    pshs      x
                    lbsr      BuildPitchTable
                    leas      4,s
                    lbsr      CalcTickScale
                    clra
                    clrb
                    std       <UmeData_accent
                    std       <UmeData_residue
                    ldd       #$0002
                    std       4,s
                    clra
                    clrb
                    std       <UmeData_smfdelta
                    ldb       <UmeData_smf
                    beq       a3@
                    ldd       <UmeData_tempo
                    pshs      a,b
                    lbsr      WriteMidiHeader
                    leas      2,s
a3@                 ldb       <UmeData_scrclock
                    beq       b3@
                    ldb       <UmeData_clocken
                    beq       b3@
                    ldd       #$0001
                    bra       c3@
b3@                 clra
                    clrb
c3@                 stb       6,s
                    beq       d3@
                    ldd       #$00FA
                    pshs      a,b
                    lbsr      SendRealtime
                    leas      2,s
d3@                 ldb       <UmeData_pldebug
                    beq       e3@
                    ldd       <UmeData_keysig
                    pshs      a,b
                    leax      >msgKeyInit,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    jsr       [>UmeData_pflush]
e3@                 equ       *
                    clra
                    clrb
                    std       9,s
                    pshs      a,b
                    lbsr      GetEventPtr
                    leas      2,s
                    tfr       d,u
                    lbra      PlayLoopTest
* PlayLoopTop: broke nonzero ends the play (3 = key abort: gind = curind-1, xgoal = $28, rfr_scr = 1) through PlayFinish.
PlayLoopTop         ldd       <UmeData_broke
                    beq       StartWindowCheck
                    ldd       <UmeData_broke
                    cmpd      #$0003
                    bne       a4@
                    ldd       <UmeData_curind
                    addd      #$FFFF
                    std       <UmeData_gind
                    ldd       #$0028
                    std       <UmeData_xgoal
                    ldd       #$0001
                    stb       <UmeData_rfr_scr
a4@                 lbra      PlayFinish
* StartWindowCheck: event index 9,s vs args $1C6,s/$1C8,s (first/last event to sound) sets/clears sound and latches the start phase in 7,s.
StartWindowCheck    ldd       9,s
                    cmpd      >$01C6,s
                    blt       b5@
                    ldb       <UmeData_sound
                    bne       a5@
                    lbsr      ReadFineTick
                    std       7,s
a5@                 ldd       #$0001
                    stb       <UmeData_sound
b5@                 ldd       9,s
                    cmpd      >$01C8,s
                    ble       AdvanceTime
                    clra
                    clrb
                    stb       <UmeData_sound
* AdvanceTime: now = event time, delt = delta since the last event; flushes the device buffer (pmflush) when mididev; adds delt to crdelt/acdelt; fix = SS.KySns bits.
AdvanceTime         ldd       1,u
                    std       <UmeData_now
                    ldd       <UmeData_now
                    subd      <UmeData_lastime
                    std       <UmeData_delt
                    lble      DispatchEvent
                    ldb       <UmeData_mididev
                    beq       a6@
                    jsr       [>UmeData_pmflush]
a6@                 clra
                    clrb
                    std       <UmeData_accent
                    ldd       <UmeData_now
                    std       <UmeData_lastime
                    ldd       <UmeData_crdelt
                    addd      <UmeData_delt
                    std       <UmeData_crdelt
                    ldd       <UmeData_acdelt
                    addd      <UmeData_delt
                    std       <UmeData_acdelt
                    ldb       <UmeData_sound
                    lbeq      CrescUpdate
                    lbsr      GetKeySense
                    tst       >AuditionMode
                    beq       aks1@
                    clra                          an audition ignores the speed keys (Shift = 2x,
                    clrb                          Ctrl = half); wildbits SS.KySns is the state at the last key read
aks1@               std       <UmeData_fix
* SliceLoop: towait = min(delt, tilloff), clipped to the next MIDI clock ($F8, 4,s ticks away) while the clock runs (6,s); fix bit 0 (Shift) halves and bit 1 (Ctrl) doubles the wait.
SliceLoop           ldd       <UmeData_delt
                    cmpd      <UmeData_tilloff
                    ble       a7@
                    ldd       <UmeData_tilloff
                    bra       b7@
a7@                 ldd       <UmeData_delt
b7@                 std       <UmeData_towait
                    ldb       6,s
                    beq       f7@
                    ldd       <UmeData_towait
                    cmpd      4,s
                    bge       c7@
                    ldd       4,s
                    subd      <UmeData_towait
                    bra       e7@
c7@                 ldd       4,s
                    std       <UmeData_towait
                    ldd       #$00F8
                    pshs      a,b
                    lbsr      SendRealtime
                    leas      2,s
                    ldb       <UmeData_mididev
                    beq       d7@
                    jsr       [>UmeData_pmflush]
d7@                 ldd       #$0002
e7@                 std       4,s
f7@                 ldd       <UmeData_smfdelta
                    pshs      a,b
                    ldd       <UmeData_towait
                    std       <UmeData_ttemp
                    addd      ,s++
                    std       <UmeData_smfdelta
                    ldb       <UmeData_smf
                    lbne      NoteOffCheck
                    ldd       <UmeData_fix
                    clra
                    andb      #$01
                    beq       h7@
                    ldd       <UmeData_ttemp
                    clra
                    andb      #$01
                    beq       g7@
                    ldd       <UmeData_residue
                    addd      #$0020
                    std       <UmeData_residue
g7@                 ldd       <UmeData_ttemp
                    pshs      a,b
                    ldd       #$0001
                    lbsr      AsrShift
                    bra       i7@
h7@                 ldd       <UmeData_fix
                    clra
                    andb      #$02
                    beq       j7@
                    ldd       <UmeData_ttemp
                    addd      <UmeData_ttemp
i7@                 std       <UmeData_ttemp
j7@                 ldd       <UmeData_ttemp                a slice with length: every note due now is out,
                    beq       j7a@                so paint the keys they changed; the time is charged to this wait
                    lbsr      PianoFlush
j7a@                ldd       <UmeData_residue
                    pshs      a,b
                    ldd       <UmeData_ttemp
                    pshs      a,b
                    ldd       <UmeData_machtemp
                    lbsr      IntMul
                    addd      ,s++
                    std       <UmeData_residue
                    ldd       7,s                 previous 1/64-tick phase
                    pshs      a,b
                    lbsr      ReadFineTick        current phase, increasing modulo 60*64
                    std       9,s                 next interval starts here
                    subd      ,s++                elapsed painting/dispatch time in 1/64 ticks
                    bpl       k7@
                    addd      #60*64              wrapped through the one-second counter
k7@                 pshs      a,b
                    ldd       <UmeData_residue
                    subd      ,s++                charge sub-tick work, not just whole video frames
                    std       <UmeData_residue
                    ldd       <UmeData_residue
                    pshs      a,b
                    ldd       #$0006
                    lbsr      AsrShift
                    std       <UmeData_ttemp
                    ble       l7@
                    ldd       <UmeData_residue
                    clra
                    andb      #$3F
                    std       <UmeData_residue
                    ldd       <UmeData_ttemp
                    pshs      a,b
                    lbsr      SleepTicks
                    leas      2,s
l7@                 lbsr      ReadFineTick
                    std       7,s
* NoteOffCheck: tilloff -= towait; when it reaches zero, scans every voice for expired notes.
NoteOffCheck        ldd       <UmeData_tilloff
                    subd      <UmeData_towait
                    std       <UmeData_tilloff
                    lbgt      SliceDeltaNext
                    ldd       #$7FFF
                    std       <UmeData_tilloff
                    ldd       #$0001
                    std       <UmeData_plpart
                    leax      >$009C,s
                    stx       ,s
                    lbra      NoteOffScanTest
* NoteOffScan: per voice, rec[4] (note-off countdown) -= takeoff; on expiry sends $90+chan / note / 0 unless the part or channel is off; tracks the new minimum in tilloff.
NoteOffScan         ldx       ,s
                    ldd       4,x
                    std       <UmeData_ttemp
                    lble      d8@
                    ldd       <UmeData_ttemp
                    subd      <UmeData_takeoff
                    std       <UmeData_ttemp
                    ldx       ,s
                    std       4,x
                    ble       a8@
                    ldd       <UmeData_ttemp
                    cmpd      <UmeData_tilloff
                    lbge      d8@
                    ldd       <UmeData_ttemp
                    std       <UmeData_tilloff
                    bra       d8@
a8@                 ldd       <UmeData_plpart
                    ldx       #MidiPartOn
                    leax      d,x
                    ldb       ,x
                    beq       d8@
                    ldd       [,s]
                    ldx       #MidiChanOn
                    leax      d,x
                    ldb       ,x
                    beq       d8@
                    ldb       <UmeData_smf
                    beq       b8@
                    lbsr      WriteDeltaTime
b8@                 ldd       [,s]
                    addd      #$0090
                    std       <UmeData_oldmid
                    cmpd      <UmeData_runstat
                    beq       c8@
                    ldd       <UmeData_oldmid
                    std       <UmeData_runstat
                    pshs      a,b
                    lbsr      PutMidiByte
                    leas      2,s
c8@                 ldx       ,s
                    ldd       2,x
                    pshs      a,b
                    lbsr      PutMidiByte
                    leas      2,s
                    clra
                    clrb
                    pshs      a,b
                    lbsr      PutMidiByte
                    leas      2,s
d8@                 ldd       ,s
                    addd      #$0010
                    std       ,s
                    subd      #$0010
                    ldd       <UmeData_plpart
                    addd      #$0001
                    std       <UmeData_plpart
                    subd      #$0001
* NoteOffScanTest: loops while plpart <= nparts, then flushes and takeoff = tilloff.
NoteOffScanTest     ldd       <UmeData_plpart
                    cmpd      <UmeData_nparts
                    lble      NoteOffScan
                    ldb       <UmeData_mididev
                    beq       e8@
                    jsr       [>UmeData_pmflush]
e8@                 ldd       <UmeData_tilloff
                    std       <UmeData_takeoff
* SliceDeltaNext: delt -= towait; loops to SliceLoop while delta remains.
SliceDeltaNext      ldd       <UmeData_delt
                    subd      <UmeData_towait
                    std       <UmeData_delt
                    lbgt      SliceLoop
* CrescUpdate: hairpin in progress (<$16,s): velocity offset 2,s = target <$14,s once crdelt reaches the length <$17,s, else crbeglvl + (crdelt*crmult)>>8.
CrescUpdate         ldb       <$16,s
                    beq       RampUpdate
                    ldd       <UmeData_crdelt
                    cmpd      <$17,s
                    blt       a9@
                    clra
                    clrb
                    stb       <$16,s
                    ldd       <$14,s
                    bra       b9@
a9@                 ldd       <UmeData_crmult
                    pshs      a,b
                    ldd       <UmeData_crdelt
                    lbsr      IntMul
                    pshs      a,b
                    ldd       #$0008
                    lbsr      AsrShift
                    addd      <UmeData_crbeglvl
b9@                 std       2,s
* RampUpdate: accel/rit in progress (<$11,s): machtemp = target 15,s once acdelt reaches the length <$12,s, else acbegmt + (acdelt*acmult)>>acscale; tempo meta when filing.
RampUpdate          ldb       <$11,s
                    beq       DispatchEvent
                    ldd       <UmeData_acdelt
                    cmpd      <$12,s
                    blt       a10@
                    clra
                    clrb
                    stb       <$11,s
                    ldd       15,s
                    bra       b10@
a10@                ldd       <UmeData_acmult
                    pshs      a,b
                    ldd       <UmeData_acdelt
                    lbsr      IntMul
                    pshs      a,b
                    ldd       <UmeData_acscale
                    lbsr      AsrShift
                    addd      <UmeData_acbegmt
b10@                std       <UmeData_machtemp
                    ldb       <UmeData_smf
                    beq       DispatchEvent
                    ldd       <UmeData_machtemp
                    pshs      a,b
                    lbsr      TempoToScale
                    std       ,s
                    lbsr      WriteTempoMeta
                    leas      2,s
* DispatchEvent: plslot = event code 5,u; voice events (0,u != 0) go to NoteEvent; codes <= 6 are bar lines (accidentals reset by rebuilding the pitch table, bar number printed when pldebug), then EvSwitch.
DispatchEvent       ldb       5,u
                    sex
                    std       <UmeData_plslot
                    ldb       ,u
                    lbne      NoteEvent
                    ldd       <UmeData_plslot
                    cmpd      #$0006
                    bgt       a11@
                    leax      <$28,s
                    pshs      x
                    leax      <$23,s
                    pshs      x
                    lbsr      BuildPitchTable
                    leas      4,s
                    ldb       <UmeData_pldebug
                    beq       a11@
                    ldd       3,u
                    pshs      a,b
                    leax      >fmtBarNum,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    jsr       [>UmeData_pflush]
a11@                ldx       <UmeData_plslot
                    lbra      EvSwitch
* EvClockStart: event $1B: 7,u != 0 starts the MIDI clock ($FA) when clocken, else a running clock stops ($FC); 6,s = clock running.
EvClockStart        ldb       7,u
                    beq       a12@
                    ldb       <UmeData_clocken
                    stb       6,s
                    lbeq      EvMetaDone
                    ldd       #$00FA
                    bra       b12@
a12@                ldb       6,s
                    lbeq      EvMetaDone
                    clra
                    clrb
                    stb       6,s
                    ldd       #$00FC
b12@                pshs      a,b
                    lbsr      SendRealtime
                    lbra      EvDonePop2
* EvFine: bar code 6 (Fine): when a D.C./D.S. return point (dcds) is set, jumps to nevents (end of piece).
EvFine              ldd       <UmeData_dcds
                    cmpd      #$FFFF
                    lbeq      BarLineDone
                    ldd       <UmeData_nevents
                    lbra      BarSetEventIndex
* EvRepeatStart: bar code 3 (|:): pushes the event index on the 4-byte-entry repeat stack (rsptr, limit frame+$1BC) or alerts "**Stack Full!".
EvRepeatStart       leax      >$01BC,s
                    cmpx      <UmeData_rsptr
                    bhs       a13@
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgStackFull,pcr
                    pshs      x
                    jsr       [>UmeData_palert]
                    leas      4,s
                    bra       b13@
a13@                ldd       9,s
                    std       [>$00B7,y]
                    clra
                    clrb
                    ldx       <UmeData_rsptr
                    leax      4,x
                    stx       <UmeData_rsptr
                    std       -2,x
                    ldd       #$FFFF
                    std       <UmeData_nthendx
b13@                lbra      EvDone
* EvRepeatEnd: bar code 1 (:|): "**Stack MT!" when empty; pops the entry; with a zero count, counts the pass, re-pushes and jumps back to the saved index.
EvRepeatEnd         leax      >$019C,s
                    cmpx      <UmeData_rsptr
                    bne       a14@
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgStackEmpty,pcr
                    pshs      x
                    jsr       [>UmeData_palert]
                    leas      4,s
                    lbra      BarLineDone
a14@                ldx       <UmeData_rsptr
                    leax      -4,x
                    stx       <UmeData_rsptr
                    ldd       2,x
                    bne       BarLineDone
                    ldx       <UmeData_rsptr
                    ldd       2,x
                    addd      #$0001
                    std       2,x
                    ldx       <UmeData_rsptr
                    leax      4,x
                    stx       <UmeData_rsptr
                    bra       BarJumpStackTop
* EvEnding: bar code 5 (ending bracket, number 6,u): sets inending; ending 1 jumps to nthendx when set; another number saves the index in nthendx and jumps back to the repeat start.
EvEnding            ldd       #$0001
                    stb       <UmeData_inending
                    ldb       6,u
                    cmpb      #$01
                    bne       a15@
                    ldd       <UmeData_nthendx
                    cmpd      #$FFFF
                    beq       BarLineDone
                    ldd       <UmeData_nthendx
                    bra       BarSetEventIndex
a15@                ldd       9,s
                    std       <UmeData_nthendx
                    leax      >$019C,s
                    cmpx      <UmeData_rsptr
                    bne       b15@
                    leax      >msgStackEmpty0,pcr
                    pshs      x
                    jsr       [>UmeData_palert]
                    lbra      EvDonePop2
b15@                clra
                    clrb
                    stb       <UmeData_inending
                    ldx       <UmeData_rsptr
* BarJumpStackTop: loads the saved event index from the repeat-stack top; EvRepeatEnd branches here
BarJumpStackTop     ldd       -4,x
* BarSetEventIndex: D = the new play position 9,s; EvFine and EvEnding jump here with their targets
BarSetEventIndex    std       9,s
* BarLineDone: shared lbra EvDone for the bar-line handlers
BarLineDone         lbra      EvDone
* EvEndingClose: bar code 2: when inending and nthendx is set, clears nthendx and pops the repeat stack.
EvEndingClose       ldb       <UmeData_inending
                    beq       a16@
                    ldd       <UmeData_nthendx
                    cmpd      #$FFFF
                    beq       a16@
                    ldd       #$FFFF
                    std       <UmeData_nthendx
                    ldd       <UmeData_rsptr
                    addd      #$FFFC
                    std       <UmeData_rsptr
a16@                lbra      EvDone
* EvTempo: event $19: tempo = 3,u, printed when pldebug; a pending time signature due now is applied, else the tick scale is recomputed and the tempo meta written when filing.
EvTempo             clra
                    clrb
                    stb       <$11,s
                    ldb       3,u
                    clra
                    ldx       6,u
                    cmpx      #$4C59              Lyra wide-tempo record: high byte in 4,u; otherwise byte tempo
                    bne       tmpbyte@
                    lda       4,u
tmpbyte@
                    std       <UmeData_tempo
                    ldb       <UmeData_pldebug
                    beq       a17@
                    ldd       <UmeData_tempo
                    pshs      a,b
                    leax      >fmtTempo,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    jsr       [>UmeData_pflush]
a17@                ldd       1,u
                    lbsr      UIntToLong
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      <$1D,s
                    lbsr      LongCmp
                    bne       b17@
                    leax      >$01C0,s
                    bra       ApplyTimeSigEntry
b17@                lbsr      CalcTickScale
                    ldb       <UmeData_smf
                    lbeq      EvMetaDone
                    lbra      EmitTempoMeta
* EvTimeSig: event $0A: numerator 6,u -> <$1F,s, denominator 7,u -> <$1D,s, event time -> long <$19,s; applied immediately only at time 0.
EvTimeSig           ldb       6,u
                    sex
                    std       <$1F,s
                    ldb       7,u
                    sex
                    std       <$1D,s
                    leax      <$19,s
                    pshs      x
                    ldd       1,u
                    lbsr      UIntToLong
                    lbsr      LongStore
                    ldd       1,u
                    beq       ApplyTimeSig
                    lbra      EvDone
* ApplyTimeSigEntry: restores S from X then ApplyTimeSig; EvTempo branches here when a time sig is due now
ApplyTimeSigEntry   leas      >-$01C0,x
* ApplyTimeSig: $03/$05 = num/den, printed when pldebug; tripper (compound) = num%3 == 0, num >= 6, den >= 8; dendur = zonedur = 192/den, zonedur x3 when compound; tick scale; time-sig and tempo metas when filing.
ApplyTimeSig        ldd       <$1F,s
                    std       <UmeData_reserved_0003
                    ldd       <$1D,s
                    std       <UmeData_reserved_0005
                    ldb       <UmeData_pldebug
                    beq       a18@
                    ldd       <UmeData_reserved_0005
                    pshs      a,b
                    ldd       <UmeData_reserved_0003
                    pshs      a,b
                    leax      >fmtTimeSig,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      6,s
                    jsr       [>UmeData_pflush]
a18@                ldd       <UmeData_reserved_0005
                    cmpd      #$0008
                    blt       b18@
                    ldd       <UmeData_reserved_0003
                    cmpd      #$0006
                    blt       b18@
                    ldd       <UmeData_reserved_0003
                    pshs      a,b
                    ldd       #$0003
                    lbsr      IntMod
                    bne       b18@
                    ldd       #$0001
                    bra       c18@
b18@                clra
                    clrb
c18@                stb       <UmeData_tripper
                    ldd       #$00C0
                    pshs      a,b
                    ldd       <UmeData_reserved_0005
                    lbsr      IntDiv
                    std       <UmeData_dendur
                    std       <UmeData_zonedur
                    ldb       <UmeData_tripper
                    beq       d18@
                    ldd       <UmeData_zonedur
                    pshs      a,b
                    ldd       <UmeData_dendur
                    addd      <UmeData_dendur
                    addd      ,s++
                    std       <UmeData_zonedur
d18@                lbsr      CalcTickScale
                    ldb       <UmeData_smf
                    beq       EvMetaDone
                    lbsr      WriteTimeSigMeta
* EmitTempoMeta: WriteTempoMeta(tempo); EvTempo jumps in, ApplyTimeSig falls through when filing
EmitTempoMeta       ldd       <UmeData_tempo
                    pshs      a,b
                    lbsr      WriteTempoMeta
* EvDonePop2: pops one pushed arg then finishes the event; EvClockStart and EvEnding branch here
EvDonePop2          leas      2,s
* EvMetaDone: shared lbra EvDone for the clock/tempo/time-sig handlers when no meta is written
EvMetaDone          lbra      EvDone
* EvKeySig: event $0B: keysig = 6,u, rebuilds the scale/pitch tables, key-sig meta when filing, prints "Key %d" when pldebug.
EvKeySig            ldb       6,u
                    sex
                    std       <UmeData_keysig
                    pshs      a,b
                    leax      <$23,s
                    pshs      x
                    lbsr      BuildScaleTable
                    leas      4,s
                    leax      <$28,s
                    pshs      x
                    leax      <$23,s
                    pshs      x
                    lbsr      BuildPitchTable
                    leas      4,s
                    ldb       <UmeData_smf
                    beq       a19@
                    lbsr      WriteKeySigMeta
a19@                ldb       <UmeData_pldebug
                    beq       b19@
                    ldd       <UmeData_keysig
                    pshs      a,b
                    leax      >msgKeyChange,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    jsr       [>UmeData_pflush]
b19@                lbra      EvDone
* EvDynamic: event $1A: cancels a hairpin and sets the velocity offset 2,s = dynamics table $0103[7,u] + velo - 11,s.
EvDynamic           clra
                    clrb
                    stb       <$16,s
                    ldb       7,u
                    sex
                    ldx       #$0103
                    leax      d,x
                    ldb       ,x
                    sex
                    addd      <UmeData_velo
                    subd      11,s
                    std       2,s
                    lbra      EvDone
* EvAccent: event $22: one-event accent = +accentwt when 7,u > 0, else -accentwt.
EvAccent            ldb       7,u
                    ble       a20@
                    ldb       <UmeData_accentwt
                    sex
                    bra       b20@
a20@                ldb       <UmeData_accentwt
                    sex
                    nega
                    negb
                    sbca      #$00
b20@                std       <UmeData_accent
                    lbra      EvDone
* EvCrescendo: event $1C: starts a hairpin: target <$14,s from the dynamics table, length <$17,s = zonedur * 6,u, crmult = ((target-start)<<8)/length.
EvCrescendo         ldd       #$0001
                    stb       <$16,s
                    clra
                    clrb
                    std       <UmeData_crdelt
                    ldd       2,s
                    std       <UmeData_crbeglvl
                    ldb       7,u
                    sex
                    ldx       #$0103
                    leax      d,x
                    ldb       ,x
                    sex
                    addd      <UmeData_velo
                    subd      11,s
                    std       <$14,s
                    ldd       <UmeData_zonedur
                    pshs      a,b
                    ldb       6,u
                    sex
                    lbsr      IntMul
                    std       <$17,s
                    ldd       <$14,s
                    subd      <UmeData_crbeglvl
                    pshs      a,b
                    ldd       #$0008
                    lbsr      AslShift
                    pshs      a,b
                    ldd       <$19,s
                    lbsr      IntDiv
                    std       <UmeData_crmult
                    lbra      EvDone
* EvTempoRamp: event $1D: starts accel/rit from machtemp toward TempoToScaleC(7,u) (15,s) over zonedur*6,u (<$12,s); normalizes the difference into acmult/acscale.
EvTempoRamp         ldd       #$0001
                    stb       <$11,s
                    clra
                    clrb
                    std       <UmeData_acdelt
                    ldd       <UmeData_machtemp
                    std       <UmeData_acbegmt
                    ldb       7,u
                    clra
                    pshs      a,b
                    lbsr      TempoToScaleC
                    leas      2,s
                    std       15,s
                    ldd       <UmeData_zonedur
                    pshs      a,b
                    ldb       6,u
                    sex
                    lbsr      IntMul
                    std       <$12,s
                    clra
                    clrb
                    std       <UmeData_acscale
                    ldd       15,s
                    subd      <UmeData_acbegmt
                    std       <UmeData_acmult
                    bne       a21@
                    clra
                    clrb
                    stb       <$11,s
                    bra       g21@
a21@                ldd       <UmeData_acmult
                    bge       e21@
                    bra       c21@
b21@                ldd       <UmeData_acscale
                    addd      #$0001
                    std       <UmeData_acscale
c21@                ldd       <UmeData_acmult
                    addd      <UmeData_acmult
                    std       <UmeData_acmult
                    blt       b21@
                    ldd       <UmeData_acmult
                    asra
                    rorb
                    ora       #$80
                    bra       f21@
d21@                ldd       <UmeData_acscale
                    addd      #$0001
                    std       <UmeData_acscale
e21@                ldd       <UmeData_acmult
                    addd      <UmeData_acmult
                    std       <UmeData_acmult
                    bgt       d21@
                    ldd       <UmeData_acmult
                    lsra
                    rorb
f21@                std       <UmeData_acmult
g21@                ldd       <UmeData_acmult
                    pshs      a,b
                    ldd       <$14,s
                    lbsr      IntDiv
                    std       <UmeData_acmult
                    lbra      EvDone
* EvProgChange: event $17: when instren and the channel is on, sends $C0+chan and the patch (low byte of word $075F[7,u], & $7F) for voice 6,u, then OctaveFromName.
EvProgChange        ldb       <UmeData_instren
                    lbeq      EvDone
                    ldb       6,u
                    sex
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    leax      >$008C,s
                    leax      d,x
                    stx       ,s
                    ldd       [,s]
                    ldx       #MidiChanOn
                    leax      d,x
                    ldb       ,x
                    beq       OctaveFromName
                    ldb       <UmeData_smf
                    beq       a22@
                    lbsr      WriteDeltaTime
a22@                ldd       [,s]
                    addd      #$00C0
                    std       <UmeData_runstat
                    pshs      a,b
                    lbsr      PutMidiByte
                    leas      2,s
                    ldb       7,u
                    sex
                    std       <UmeData_fix
                    aslb
                    rola
                    ldx       #$075F
                    leax      d,x
                    ldd       ,x
                    clra
                    andb      #$7F
                    pshs      a,b
                    lbsr      PutMidiByte
                    leas      2,s
* OctaveFromName: first char of instrument name $07EB[i*16]: '+' -> rec[12] = +12, '-' -> -12, else 0; rec[10] transpose adjusted by the difference.
OctaveFromName      ldd       <UmeData_fix
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$07EB
                    leax      d,x
                    ldb       ,x
                    sex
                    std       <UmeData_fix
                    ldx       ,s
                    ldd       10,x
                    leax      10,x
                    pshs      a,b,x
                    ldx       4,s
                    ldd       12,x
                    nega
                    negb
                    sbca      #$00
                    addd      ,s++
                    std       [,s++]
                    ldx       ,s
                    ldd       10,x
                    leax      10,x
                    pshs      a,b,x
                    ldd       <UmeData_fix
                    cmpd      #$002B
                    bne       a23@
                    ldd       #$000C
                    bra       c23@
a23@                ldd       <UmeData_fix
                    cmpd      #$002D
                    bne       b23@
                    ldd       #$FFF4
                    bra       c23@
b23@                clra
                    clrb
c23@                ldx       4,s
                    std       12,x
                    addd      ,s++
                    bra       EvVoiceStoreDone
* EvVoiceDynamic: event $18: voice 6,u base velocity rec[8] = dynamics table $0103[7,u].
EvVoiceDynamic      ldb       6,u
                    sex
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    leax      >$008C,s
                    leax      d,x
                    leax      8,x
                    pshs      x
                    ldb       7,u
                    sex
                    ldx       #$0103
                    leax      d,x
                    ldb       ,x
                    sex
* EvVoiceStoreDone: std [,s++] then EvDone; EvProgChange branches in, EvVoiceDynamic falls through
EvVoiceStoreDone    std       [,s++]
                    lbra      EvDone
* EvVoiceChannel: event $16: cuts the sounding note of voice 6,u (note-off when part and channel are on), then rec[0] channel = 7,u.
EvVoiceChannel      ldb       6,u
                    sex
                    std       <UmeData_plpart
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    leax      >$008C,s
                    leax      d,x
                    stx       ,s
                    ldd       4,x
                    ble       b24@
                    clra
                    clrb
                    ldx       ,s
                    std       4,x
                    ldd       <UmeData_plpart
                    ldx       #MidiPartOn
                    leax      d,x
                    ldb       ,x
                    beq       b24@
                    ldd       [,s]
                    ldx       #MidiChanOn
                    leax      d,x
                    ldb       ,x
                    beq       b24@
                    ldb       <UmeData_smf
                    beq       a24@
                    lbsr      WriteDeltaTime
a24@                ldd       [,s]
                    addd      #$0090
                    std       <UmeData_runstat
                    pshs      a,b
                    lbsr      PutMidiByte
                    leas      2,s
                    ldx       ,s
                    ldd       2,x
                    pshs      a,b
                    lbsr      PutMidiByte
                    leas      2,s
                    clra
                    clrb
                    ldx       ,s
                    std       2,x
                    pshs      a,b
                    lbsr      PutMidiByte
                    leas      2,s
b24@                ldb       7,u
                    sex
                    std       [,s]
                    lbra      EvDone
* EvRawMidi: events $1E/$1F: 6,u = $40 forces midievts on; when midievts, SendRawMidiEvent and runstat cleared.
EvRawMidi           ldb       6,u
                    cmpb      #$40
                    bne       erm_normal@
                    lda       #1
                    sta       <UmeData_midievts
erm_normal@         ldb       <UmeData_midievts
                    lbeq      EvDone
                    pshs      u
                    lbsr      SendRawMidiEvent
                    leas      2,s
                    clra
                    clrb
                    std       <UmeData_runstat
                    lbra      EvDone
* EvSegno: event $08: dp_sign = current event index.
EvSegno             ldd       9,s
                    std       <UmeData_dp_sign
                    lbra      EvDone
* EvToCoda: event $09: on the return pass (dcds set) jumps to dcds and clears it; when nthendx is set, clears it and pops the repeat stack.
EvToCoda            ldd       <UmeData_dcds
                    cmpd      #$FFFF
                    lbeq      EvDone
                    ldd       <UmeData_dcds
                    std       9,s
                    ldd       #$FFFF
                    std       <UmeData_dcds
                    ldd       <UmeData_nthendx
                    cmpd      #$FFFF
                    lbeq      EvDone
                    ldd       #$FFFF
                    std       <UmeData_nthendx
                    ldd       <UmeData_rsptr
                    addd      #$FFFC
                    std       <UmeData_rsptr
                    lbra      EvDone
* EvDCalCoda: event $12: sets senzarep then falls into EvDaCapo.
EvDCalCoda          ldd       #$0001
                    stb       <UmeData_senzarep
* EvDaCapo: event $11: dcds = current index, jump to event 0.
EvDaCapo            ldd       9,s
                    std       <UmeData_dcds
                    clra
                    clrb
                    bra       DaCapoJumpDone
* EvDSalCoda: event $14: sets senzarep then falls into EvDalSegno.
EvDSalCoda          ldd       #$0001
                    stb       <UmeData_senzarep
* EvDalSegno: event $13: alerts "**No Sign!" when dp_sign is -1, else dcds = current index and jump to dp_sign.
EvDalSegno          ldd       <UmeData_dp_sign
                    cmpd      #$FFFF
                    bne       a25@
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgNoSign,pcr
                    pshs      x
                    jsr       [>UmeData_palert]
                    leas      4,s
                    lbra      EvDone
a25@                ldd       9,s
                    std       <UmeData_dcds
                    ldd       <UmeData_dp_sign
* DaCapoJumpDone: D = jump target -> 9,s then EvDone; EvDaCapo branches in with 0, EvDalSegno with dp_sign
DaCapoJumpDone      std       9,s
                    lbra      EvDone
* EvSwitch: X = event code; cmpx chain to the handlers; other codes fall into EvDone.
EvSwitch            cmpx      #$001B
                    lbeq      EvClockStart
                    cmpx      #$0006
                    lbeq      EvFine
                    cmpx      #$0003
                    lbeq      EvRepeatStart
                    cmpx      #$0001
                    lbeq      EvRepeatEnd
                    cmpx      #$0005
                    lbeq      EvEnding
                    cmpx      #$0002
                    lbeq      EvEndingClose
                    cmpx      #$0019
                    lbeq      EvTempo
                    cmpx      #$000A
                    lbeq      EvTimeSig
                    cmpx      #$000B
                    lbeq      EvKeySig
                    cmpx      #$001A
                    lbeq      EvDynamic
                    cmpx      #$0022
                    lbeq      EvAccent
                    cmpx      #$001C
                    lbeq      EvCrescendo
                    cmpx      #$001D
                    lbeq      EvTempoRamp
                    cmpx      #$0017
                    lbeq      EvProgChange
                    cmpx      #$0018
                    lbeq      EvVoiceDynamic
                    cmpx      #$0016
                    lbeq      EvVoiceChannel
                    cmpx      #$001E
                    lbeq      EvRawMidi
                    cmpx      #$001F
                    lbeq      EvRawMidi
                    cmpx      #$0008
                    lbeq      EvSegno
                    cmpx      #$0009
                    lbeq      EvToCoda
                    cmpx      #$0012
                    lbeq      EvDCalCoda
                    cmpx      #$0011
                    lbeq      EvDaCapo
                    cmpx      #$0014
                    lbeq      EvDSalCoda
                    cmpx      #$0013
                    lbeq      EvDalSegno
* EvDone: common tail: 9,s != curind means a jump: GetEventPtr(9,s), lastime = its time; then FetchNextEvent.
EvDone              ldd       9,s
                    cmpd      <UmeData_curind
                    lbeq      FetchNextEvent
                    ldd       9,s
                    pshs      a,b
                    lbsr      GetEventPtr
                    leas      2,s
                    tfr       d,u
                    ldd       1,u
                    std       <UmeData_lastime
                    lbra      FetchNextEvent
* NoteEvent: voice event, skipped when 7,u = $82 (imported notation shadowed by exact raw
* MIDI note events) or the part/channel is off. A rest (code $20) gives note 0; staff offset
* rec[6] = 0 maps code 5,u+4 through the percussion table $0CA3; else step = 5,u + rec[6]
* folded into 0..49, pitch from the current table (accidental 6,u: natural table +
* tblAccidental, kept for the bar), + transpose rec[10], folded by octaves into
* midinnmin..midinnmax. Articulation 7,u: 2 = the voice's rec[14], other nonzero = new rec[14].
NoteEvent           ldb       7,u
                    cmpb      #$82
                    lbeq      FetchNextEvent
                    ldb       ,u
                    sex
                    std       <UmeData_plpart
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    leax      >$008C,s
                    leax      d,x
                    stx       ,s
                    ldd       <UmeData_plpart
                    ldx       #MidiPartOn
                    leax      d,x
                    ldb       ,x
                    lbeq      FetchNextEvent
                    ldd       [,s]
                    std       <UmeData_midchan
                    ldx       #MidiChanOn
                    leax      d,x
                    ldb       ,x
                    lbeq      FetchNextEvent
                    ldx       ,s
                    ldd       2,x
                    std       <UmeData_oldmid
                    ldb       7,u
                    sex
                    std       <UmeData_plart
                    ldd       <UmeData_plslot
                    cmpd      #$0020
                    bne       a26@
                    clra
                    clrb
                    std       <UmeData_midnote
                    lbra      m26@
a26@                ldx       ,s
                    ldd       6,x
                    std       <UmeData_midnote
                    bne       b26@
                    ldd       <UmeData_plslot
                    addd      #$0004
                    ldx       #$0CA3
                    leax      d,x
                    ldb       ,x
                    sex
                    lbra      j26@
b26@                ldd       <UmeData_midnote
                    addd      <UmeData_plslot
                    bra       d26@
c26@                ldd       <UmeData_chrind
                    addd      #$0007
d26@                std       <UmeData_chrind
                    ldd       <UmeData_chrind
                    blt       c26@
                    bra       f26@
e26@                ldd       <UmeData_chrind
                    subd      #$0007
                    std       <UmeData_chrind
f26@                ldd       <UmeData_chrind
                    cmpd      #$0031
                    bgt       e26@
                    ldb       6,u
                    sex
                    std       <UmeData_fix
                    bne       g26@
                    ldd       <UmeData_chrind
                    leax      <$28,s
                    leax      d,x
                    ldb       ,x
                    sex
                    std       <UmeData_midnote
                    bra       h26@
g26@                ldd       <UmeData_chrind
                    leax      <$28,s
                    leax      d,x
                    pshs      x
                    ldd       <UmeData_chrind
                    leax      <$5C,s
                    leax      d,x
                    ldb       ,x
                    sex
                    pshs      a,b
                    leax      >tblAccidental,pcr
                    ldd       <UmeData_fix
                    leax      d,x
                    ldb       ,x
                    sex
                    addd      ,s++
                    std       <UmeData_midnote
                    stb       [,s++]
h26@                ldd       <UmeData_midnote
                    pshs      a,b
                    ldx       2,s
                    ldd       10,x
                    addd      ,s++
                    bra       j26@
i26@                ldd       <UmeData_midnote
                    subd      #$000C
j26@                std       <UmeData_midnote
                    ldb       <UmeData_midinnmax
                    sex
                    cmpd      <UmeData_midnote
                    blt       i26@
                    bra       l26@
k26@                ldd       <UmeData_midnote
                    addd      #$000C
                    std       <UmeData_midnote
l26@                ldb       <UmeData_midinnmin
                    sex
                    cmpd      <UmeData_midnote
                    bgt       k26@
m26@                ldd       <UmeData_plart
                    cmpd      #$0002
                    bne       n26@
                    ldx       ,s
                    ldb       14,x
                    sex
                    std       <UmeData_plart
                    bra       NoteTiming
n26@                ldd       <UmeData_plart
                    beq       NoteTiming
                    ldd       <UmeData_plart
                    ldx       ,s
                    stb       14,x
* NoteTiming: when sounding, duration = NoteDuration(3,u, 4,u) adjusted by articulation (0: +2, 3: -zonedur/8, 4: half), at least 1 when below 2; a rest gives 0.
NoteTiming          ldb       <UmeData_sound
                    lbeq      FetchNextEvent
                    ldd       <UmeData_plslot
                    cmpd      #$0020
                    bne       a27@
                    clra
                    clrb
                    lbra      h27@
a27@                ldb       4,u
                    sex
                    pshs      a,b
                    ldb       3,u
                    sex
                    pshs      a,b
                    lbsr      NoteDuration
                    leas      4,s
                    std       <UmeData_ttemp
                    ldx       <UmeData_plart
                    bra       f27@
b27@                ldd       <UmeData_ttemp
                    addd      #$0002
                    bra       e27@
c27@                ldd       <UmeData_ttemp
                    pshs      a,b
                    ldd       <UmeData_zonedur
                    asra
                    rorb
                    asra
                    rorb
                    asra
                    rorb
                    nega
                    negb
                    sbca      #$00
                    addd      ,s++
                    bra       e27@
d27@                ldd       <UmeData_ttemp
                    pshs      a,b
                    ldd       #$0001
                    lbsr      AsrShift
e27@                std       <UmeData_ttemp
                    bra       g27@
* f27@: selects the adjustment by articulation 0/3/4.
f27@                stx       -2,s
                    beq       b27@
                    cmpx      #$0003
                    beq       c27@
                    cmpx      #$0004
                    beq       d27@
g27@                ldd       <UmeData_ttemp
                    cmpd      #$0002
                    bge       NoteTieCheck
                    ldd       #$0001
h27@                std       <UmeData_ttemp
* NoteTieCheck: while the voice sounds, the same pitch, or no accidental at the same staff position, is a tie (no retrigger); otherwise the old note is sent off.
NoteTieCheck        ldx       ,s
                    ldd       4,x
                    ble       SendNoteOn
                    ldd       <UmeData_midnote
                    cmpd      <UmeData_oldmid
                    beq       a28@
                    ldd       <UmeData_fix
                    bne       SendPrevNoteOff
                    ldx       ,s
                    ldb       15,x
                    sex
                    cmpd      <UmeData_plslot
                    bne       SendPrevNoteOff
a28@                leax      >$01C0,s
                    lbra      NoteTieSkipOn
* SendPrevNoteOff: delta time when filing, running status $90+chan, old note oldmid, velocity 0.
SendPrevNoteOff     ldb       <UmeData_smf
                    beq       a29@
                    lbsr      WriteDeltaTime
a29@                ldd       <UmeData_midchan
                    addd      #$0090
                    std       <UmeData_fix
                    cmpd      <UmeData_runstat
                    beq       b29@
                    ldd       <UmeData_fix
                    std       <UmeData_runstat
                    pshs      a,b
                    lbsr      PutMidiByte
                    leas      2,s
b29@                ldd       <UmeData_oldmid
                    pshs      a,b
                    lbsr      PutMidiByte
                    leas      2,s
                    clra
                    clrb
                    pshs      a,b
                    lbsr      PutMidiByte
                    leas      2,s
* SendNoteOn: rec[2] = pitch (0: no note-on); sends $90+chan, pitch, velocity = rec[8] + offset 2,s + accent clamped to 1..127.
SendNoteOn          ldd       <UmeData_midnote
                    ldx       ,s
                    std       2,x
                    lbeq      UpdateNoteTimer
                    ldb       <UmeData_smf
                    beq       a30@
                    lbsr      WriteDeltaTime
a30@                ldd       <UmeData_midchan
                    addd      #$0090
                    std       <UmeData_fix
                    cmpd      <UmeData_runstat
                    beq       b30@
                    ldd       <UmeData_fix
                    std       <UmeData_runstat
                    pshs      a,b
                    lbsr      PutMidiByte
                    leas      2,s
b30@                ldd       <UmeData_midnote
                    pshs      a,b
                    lbsr      PutMidiByte
                    leas      2,s
                    ldx       ,s
                    ldd       8,x
                    addd      2,s
                    addd      <UmeData_accent
                    std       <UmeData_fix
                    ldd       <UmeData_fix
                    cmpd      #$007F
                    ble       c30@
                    ldd       #$007F
                    bra       d30@
c30@                ldd       <UmeData_fix
                    cmpd      #$0001
                    bge       e30@
                    ldd       #$0001
d30@                std       <UmeData_fix
e30@                ldd       <UmeData_fix
                    pshs      a,b
                    lbsr      PutMidiByte
                    leas      2,s
                    bra       UpdateNoteTimer
* NoteTieSkipOn: tie path: restores S from X and enters UpdateNoteTimer without retriggering
NoteTieSkipOn       leas      >-$01C0,x
* UpdateNoteTimer: rec[4] = note-off countdown rebased to the takeoff/tilloff bookkeeping; rec[15] = staff position.
UpdateNoteTimer     ldd       <UmeData_ttemp
                    beq       b31@
                    ldd       <UmeData_ttemp
                    cmpd      <UmeData_tilloff
                    bge       a31@
                    ldd       <UmeData_takeoff
                    subd      <UmeData_tilloff
                    addd      <UmeData_ttemp
                    std       <UmeData_takeoff
                    ldd       <UmeData_ttemp
                    std       <UmeData_tilloff
a31@                ldd       <UmeData_ttemp
                    pshs      a,b
                    ldd       <UmeData_takeoff
                    subd      <UmeData_tilloff
                    addd      ,s++
                    std       <UmeData_ttemp
b31@                ldd       <UmeData_ttemp
                    ldx       ,s
                    std       4,x
                    ldd       <UmeData_plslot
                    ldx       ,s
                    stb       15,x
* FetchNextEvent: U = NextEvent(), 9,s = curind.
FetchNextEvent      lbsr      NextEvent
                    tfr       d,u
                    ldd       <UmeData_curind
                    std       9,s
* PlayLoopTest: loops to PlayLoopTop while 9,s < nevents.
PlayLoopTest        ldd       9,s
                    cmpd      <UmeData_nevents
                    lblt      PlayLoopTop
* PlayFinish: $FC when the clock ran, note-off for every voice still sounding (from voice nparts down), FinishMidiTrack when filing.
PlayFinish          ldb       6,s
                    beq       a32@
                    ldd       #$00FC
                    pshs      a,b
                    lbsr      SendRealtime
                    leas      2,s
a32@                ldd       <UmeData_nparts
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    leax      >$008C,s
                    leax      d,x
                    stx       ,s
                    bra       AllNotesOffTest
* AllNotesOffLoop: per voice, sends $90+chan / rec[2] / 0 when rec[4] != 0.
AllNotesOffLoop     ldx       ,s
                    ldd       4,x
                    beq       b33@
                    ldb       <UmeData_smf
                    beq       a33@
                    lbsr      WriteDeltaTime
a33@                ldd       [,s]
                    addd      #$0090
                    pshs      a,b
                    lbsr      PutMidiByte
                    leas      2,s
                    ldx       ,s
                    ldd       2,x
                    pshs      a,b
                    lbsr      PutMidiByte
                    leas      2,s
                    clra
                    clrb
                    pshs      a,b
                    lbsr      PutMidiByte
                    leas      2,s
b33@                ldd       ,s
                    addd      #$FFF0
                    std       ,s
* AllNotesOffTest: loops while the record pointer is above frame+$8C
AllNotesOffTest     leax      >$008C,s
                    cmpx      ,s
                    blo       AllNotesOffLoop
                    ldb       <UmeData_smf
                    beq       PlayExit
                    lbsr      FinishMidiTrack
* PlayExit: StopRawNotes, audition flags restored, queued piano keys painted, broke = 1 (done), priority back to $8C, frame dropped.
PlayExit            lbsr      StopRawNotes
                    tst       >AuditionMode
                    beq       pexNormal@
                    ldd       >AuditionSavedFlags
                    sta       <UmeData_smf
                    stb       <UmeData_pldebug
                    clr       >AuditionMode
pexNormal@          lbsr      PianoFlush          the keys still queued, while PianoVec is live
                    clr       >MidiPlaying
                    ldd       #$0001
                    std       <UmeData_broke
                    ldd       #$008C
                    pshs      a,b
                    ldd       <UmeData_group
                    pshs      a,b
                    lbsr      SetPriority
                    leas      4,s
                    leas      >$01C0,s
                    puls      u,pc
* ResetSAMBeforePlay: GM System On to the SAM2695 for live play on the wildbits MIDI path; no wait afterwards.
ResetSAMBeforePlay  pshs      d,x,y,u
                    tst       <UmeData_smf
                    bne       rsbpDone@
                    tst       <UmeData_midiser
                    beq       rsbpDone@
                    lda       >MidiRoutePaths
                    cmpa      #MidiWildbitsPath
                    bne       rsbpDone@
                    leax      SAMResetBytes,pcr
                    ldu       #6
rsbpByte@           ldb       ,x+
                    jsr       [>pSAMSend]
                    leau      -1,u
                    bne       rsbpByte@
rsbpDone@           puls      d,x,y,u,pc
SAMResetBytes       fcb       $F0,$7E,$7F,$09,$01,$F7

* msgKeyInit: printed at play start when pldebug.
msgKeyInit          fcc       /Key %d/
                    fcb       $0D,$00
* fmtBarNum: bar number printed at each bar line when pldebug.
fmtBarNum           fcc       /%d /
                    fcb       $00
* msgStackFull: repeat stack overflow (8 entries).
msgStackFull        fcc       /**Stack Full!/
                    fcb       $0D,$00
* msgStackEmpty: repeat end without a repeat start.
msgStackEmpty       fcc       /**Stack MT!/
                    fcb       $0D,$00
* msgStackEmpty0: variant alerted by the ending-bracket handler.
msgStackEmpty0      fcc       /**Stack MT!/
                    fcb       $0D
                    fcc       /, 0/
                    fcb       $00
* fmtTempo: printed on a tempo event.
fmtTempo            fcc       /Tempo %d./
                    fcb       $0D,$00
* fmtTimeSig: "%d/%d\r" printed when a time signature is applied.
fmtTimeSig          fcb       $25,$64,$2F,$25,$64,$0D,$00
* msgKeyChange: printed on a key signature event.
msgKeyChange        fcc       /Key %d/
                    fcb       $0D,$00
* msgNoSign: D.S. without a segno.
msgNoSign           fcc       /**No Sign!/
                    fcb       $0D,$00
* tblAccidental: semitone offset by accidental code 6,u: 0,0,+1,+2,0,0,-2,-1.
tblAccidental       fcb       $00,$00,$01,$02,$00,$00,$FE,$FF
                    fcb       $00
* NoteDuration(value, dots): word table $015A[dots 4,u] arithmetically shifted right by value 3,u.
NoteDuration        pshs      u
                    ldd       6,s
                    aslb
                    rola
                    ldx       #$015A
                    leax      d,x
                    ldd       ,x
                    pshs      a,b
                    ldd       6,s
                    lbsr      AsrShift
                    puls      u,pc
* SleepTicks: one OS tick per sleep; CheckAbort drains MIDI-IN and paints its keys between
* waits. Elapsed timer ticks are charged, not the requested count, so early wakeups do not
* shorten notes. 0,s is Os9Call's register frame; U at 10,s, remaining ticks at 14,s.
SleepTicks          pshs      u
                    leas      -10,s
st1@                ldd       14,s
                    ble       st9@                nothing left to sleep
                    cmpd      #$0001
                    ble       st2@
                    ldd       #$0001
st2@                std       4,s                 rg_x = this chunk
                    lbsr      ReadSysTick
                    std       6,s                 rg_y is unused by F$Sleep
                    leax      ,s
                    pshs      x
                    ldd       #$000A              F$Sleep
                    pshs      a,b
                    lbsr      Os9Call
                    leas      4,s
                    bsr       CheckAbort          a key or a click sets broke
                    lbsr      ReadSysTick
                    pshs      d
                    ldd       8,s                 previous down-counter tick
                    subd      ,s++
                    bpl       stelapsed@
                    addd      #60
stelapsed@          pshs      d
                    ldd       16,s
                    subd      ,s++
                    std       14,s
                    ldd       <UmeData_broke
                    beq       st1@
st9@                bra       Os9RegFrameRet
* CheckAbort: a key waiting on path 0 (SS.Ready) is read away so the editor never sees it,
* broke = 3. A left click (SS.Mouse on path 2, the console) waits for the release so it is
* not taken as a command afterwards, broke = 1. The press that chose PLAY (PressHeld) is
* ignored until the button has been seen up. On the CoCo3 the abort came from the BREAK
* signal, which the wildbits console never sends. Y is the C static base; SS.Mouse returns
* the row in Y, so it is saved.
CheckAbort          pshs      d,x,y,u
                    jsr       [>pMidiEcho]
                    lbsr      PianoFlush          show live DIN key changes during the wait
                    leas      -2,s                the byte a waiting key is read into
                    clra                          path 0
                    ldb       #SS.Ready
                    os9       I$GetStt            B = characters waiting, carry set when none
                    bcs       ca2@
                    tstb
                    beq       ca2@
                    clra                          read the key away
                    leax      ,s
                    ldy       #$0001
                    os9       I$Read
                    bra       ca8@
ca2@                lda       #$02                the console: buttons in A
                    ldb       #SS.Mouse
                    os9       I$GetStt
                    bcs       ca9@
                    bita      #$01                left button
                    beq       ca4@                up: any press from now on is a new one
                    tst       <PressHeld          the press that chose PLAY, still held?
                    bne       ca9@                yes: not an abort
ca3@                ldx       #$0001              wait for the release, a tick at a time
                    os9       F$Sleep
                    lda       #$02
                    ldb       #SS.Mouse
                    os9       I$GetStt
                    bcs       ca8@
                    bita      #$01
                    bne       ca3@
* A click aborts with 1, the plain BREAK value, so the player leaves gind/xgoal alone;
* 3 (the ^C value) recenters the view on the last event played and is for a key only.
                    ldd       #$0001
                    std       <UmeData_broke
                    bra       ca9@
ca8@                ldd       #$0003              a key: the ^C behavior, view to the last event
                    std       <UmeData_broke
                    bra       ca9@
ca4@                clr       <PressHeld          the button has been seen up
ca9@                leas      2,s
                    puls      d,x,y,u,pc
* GetKeySense: I$GetStt ($8D) path 0, SS.KySns ($27) via Os9Call; returns B = rg_a Shift/Ctrl bits.
GetKeySense         pshs      u
                    leas      -10,s
                    clra
                    clrb
                    stb       1,s
                    ldd       #$0027
                    stb       2,s
                    leax      ,s
                    pshs      x
                    ldd       #$008D
                    pshs      a,b
                    lbsr      Os9Call
                    leas      4,s
                    ldb       1,s
* Os9RegFrameRet: drops the 10-byte register frame and returns; SleepTicks branches in, GetKeySense falls in
Os9RegFrameRet      leas      10,s
                    puls      u,pc
* GetPartStaff(part, *step, *flags): an out-of-range part becomes nparts; *step = word 2 of the clefs ($0162) entry of the part's staff ($0C19, 10-byte entries) = staff step offset; *flags = word 2 of the parts ($0C5F) entry.
GetPartStaff        pshs      u
                    ldd       4,s
                    cmpd      #$0001
                    blt       a35@
                    ldd       4,s
                    cmpd      <UmeData_nparts
                    ble       b35@
a35@                ldd       <UmeData_nparts
                    std       4,s
b35@                ldd       4,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$0C5F
                    leax      d,x
                    leau      ,x
                    ldd       2,u
                    std       [<$08,s]
                    ldd       ,u
                    pshs      a,b
                    ldd       #$000A
                    lbsr      IntMul
                    ldx       #$0C19
                    leax      d,x
                    ldd       2,x
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$0162
                    leax      d,x
                    ldd       2,x
                    std       [<$06,s]
                    puls      u,pc
* PutMidiByte: file bytes go to the SMF writer; live bytes fan out through s9.
PutMidiByte         pshs      u
                    ldd       <UmeData_midicnt
                    addd      #1
                    std       <UmeData_midicnt
                    ldd       4,s
                    pshs      d
                    tst       <UmeData_smf
                    bne       pmbFile@
                    lbsr      MidiHwSend
                    lbra      PopArgAndRet
pmbFile@            jsr       [>UmeData_pputmidi]
                    lbra      PopArgAndRet
* BuildScaleTable(table, key): copies tblMajorScale into the 7-entry table, then raises F,C,G,D,A,E,B once per sharp or lowers B,E,A,D,G,C,F once per flat.
BuildScaleTable     pshs      u
                    leas      -1,s
                    ldu       5,s
                    ldd       #$0007
                    pshs      a,b
                    leax      >tblMajorScale,pcr
                    pshs      x
                    ldd       9,s
                    pshs      a,b
                    lbsr      MemCopy
                    leas      6,s
                    ldd       7,s
                    lbeq      BuildScaleDone
                    ldd       7,s
                    ble       FlatStepInit
                    ldd       #$0003
                    bra       SharpStepSet
* SharpLoop: raises step (start F=3, +4 mod 7) once per sharp.
SharpLoop           ldb       ,s
                    sex
                    leax      d,u
                    ldb       ,x
                    addd      #$0001
                    stb       ,x
                    ldb       ,s
                    sex
                    addd      #$0004
                    stb       ,s
                    cmpd      #$0006
                    ble       a37@
                    ldb       ,s
                    sex
                    subd      #$0007
* SharpStepSet: stores the sharp step index; BuildScaleTable jumps here with 3 (=F)
SharpStepSet        stb       ,s
a37@                ldd       7,s
                    addd      #$FFFF
                    std       7,s
                    bge       SharpLoop
                    bra       BuildScaleDone
* FlatStepInit: flats arm of BuildScaleTable: seeds the step with 6 (=B)
FlatStepInit        ldd       #$0006
                    bra       FlatStepSet
* FlatLoop: lowers step (start B=6, +3 mod 7) once per flat.
FlatLoop            ldb       ,s
                    sex
                    leax      d,u
                    ldb       ,x
                    addd      #$FFFF
                    stb       ,x
                    ldb       ,s
                    sex
                    addd      #$0003
                    stb       ,s
                    cmpd      #$0006
                    ble       a38@
                    ldb       ,s
                    sex
                    subd      #$0007
* FlatStepSet: stores the flat step index; FlatStepInit jumps in with the seed
FlatStepSet         stb       ,s
a38@                ldd       7,s
                    addd      #$0001
                    std       7,s
                    ble       FlatLoop
* BuildScaleDone: exit of BuildScaleTable; taken for key 0 and after both loops
BuildScaleDone      leas      1,s
                    puls      u,pc
* BuildPitchTable(scale, table): fills table bytes 1..49: pitch[1+oct*7+step] = 24 + 12*oct + scale[step], built with $1818/$0C0C word pairs.
BuildPitchTable     pshs      u
                    ldu       4,s
                    leas      -4,s
                    ldd       10,s
                    addd      #$0031
                    std       ,s
                    ldd       10,s
                    addd      #$0001
                    std       10,s
                    ldd       #$1818
                    bra       b39@
* a39@: one octave (7 entries) per iteration.
a39@                ldd       ,u
                    addd      2,s
                    std       [<$0A,s]
                    ldx       10,s
                    leax      2,x
                    pshs      x
                    ldd       2,u
                    addd      4,s
                    std       [,s++]
                    ldx       10,s
                    leax      4,x
                    pshs      x
                    ldd       4,u
                    addd      4,s
                    std       [,s++]
                    ldb       6,u
                    sex
                    addd      2,s
                    ldx       10,s
                    stb       6,x
                    ldd       10,s
                    addd      #$0007
                    std       10,s
                    ldd       2,s
                    addd      #$0C0C
b39@                std       2,s
                    ldd       10,s
                    cmpd      ,s
                    blo       a39@
                    leas      4,s
                    puls      u,pc
* CalcTickScale: machtemp = contemp * denominator ($05) / tempo (tempo x3 when tripper and scorelvl >= 7) = 64ths of a tick per duration unit.
CalcTickScale       pshs      a,b,u
                    ldb       <UmeData_tripper
                    beq       a40@
                    ldd       <UmeData_scorelvl
                    cmpd      #$0007
                    blt       a40@
                    ldd       <UmeData_tempo
                    addd      <UmeData_tempo
                    addd      <UmeData_tempo
                    bra       b40@
a40@                ldd       <UmeData_tempo
b40@                std       ,s
                    ldd       <UmeData_contemp
                    pshs      a,b
                    ldd       <UmeData_reserved_0005
                    lbsr      IntMul
                    pshs      a,b
                    ldd       2,s
                    lbsr      UIntDiv
                    std       <UmeData_machtemp
                    lbra      PopArgAndRet
* TempoToScaleC: TempoToScale, but triples the tempo whenever tripper is set (no scorelvl test); used for the ramp target.
TempoToScaleC       pshs      u
                    ldb       <UmeData_tripper
                    beq       TempoScaleDivide
                    bra       TempoTripleArg
* TempoToScale: returns contemp * $05 / arg with the compound x3 rule; also turns a tick scale back into a tempo for the ramp meta.
TempoToScale        pshs      u
                    ldb       <UmeData_tripper
                    beq       TempoScaleDivide
                    ldd       <UmeData_scorelvl
                    cmpd      #$0007
                    blt       TempoScaleDivide
* TempoTripleArg: triples the tempo arg for compound meter; TempoToScaleC branches in, TempoToScale falls through
TempoTripleArg      ldd       4,s
                    pshs      a,b
                    ldd       6,s
                    addd      6,s
                    addd      ,s++
                    std       4,s
* TempoScaleDivide: common contemp*$05/tempo body of TempoToScale/TempoToScaleC
TempoScaleDivide    ldd       <UmeData_contemp
                    pshs      a,b
                    ldd       <UmeData_reserved_0005
                    lbsr      IntMul
                    pshs      a,b
                    ldd       6,s
                    lbsr      UIntDiv
                    puls      u,pc
* SendRealtime: sends a MIDI realtime byte ($F8/$FA/$FC), none in an audition; in the file it is escaped as delta, F7, 01, byte.
SendRealtime        tst       >AuditionMode
                    beq       srtNormal@
                    rts
srtNormal@          pshs      u
                    ldb       <UmeData_smf
                    beq       a41@
                    lbsr      WriteDeltaTime
                    ldd       #$00F7
                    pshs      a,b
                    lbsr      PutMidiByte
                    leas      2,s
                    ldd       #$0001
                    pshs      a,b
                    lbsr      PutMidiByte
                    leas      2,s
a41@                ldb       5,s
                    sex
                    bra       PutMidiByteTail
* WriteVarLen: SMF variable-length quantity: < $80 one byte, else (v>>14)|$80 when v >= $4000, (v>>7)|$80, v&$7F through PutMidiByte.
WriteVarLen         pshs      u
                    ldd       4,s
                    cmpd      #$0080
                    bhs       a42@
                    ldd       4,s
                    bra       PutMidiByteTail
a42@                ldd       4,s
                    anda      #$C0
                    clrb
                    std       -2,s
                    beq       b42@
                    ldd       4,s
                    pshs      a,b
                    ldd       #$000E
                    lbsr      LsrShift
                    orb       #$80
                    pshs      a,b
                    lbsr      PutMidiByte
                    leas      2,s
b42@                ldd       4,s
                    pshs      a,b
                    ldd       #$0007
                    lbsr      LsrShift
                    orb       #$80
                    clra
                    pshs      a,b
                    lbsr      PutMidiByte
                    leas      2,s
                    ldd       4,s
                    clra
                    andb      #$7F
* PutMidiByteTail: pushes D and calls PutMidiByte; SendRealtime and WriteVarLen branch here for their last byte
PutMidiByteTail     pshs      a,b
                    lbsr      PutMidiByte
* PopArgAndRet: pops the pushed arg and returns
PopArgAndRet        leas      2,s
* PutMidiRet: bare puls u,pc; unreferenced.
PutMidiRet          puls      u,pc
* MidiBlockAddr(offset, len): pswapevts(1) maps the extra block (base kept in $03E5); returns base+offset, or 0 when base+offset+len passes the limit in $03E9.
MidiBlockAddr       pshs      u
                    ldd       6,s
                    clra
                    std       6,s
                    ldd       #$0001
                    pshs      a,b
                    jsr       [>UmeData_pswapevts]
                    leas      2,s
                    std       >UmeData_reserved_03E5
                    addd      4,s
                    tfr       d,u
                    pshs      u
                    ldd       8,s
                    addd      ,s++
                    cmpd      >UmeData_reserved_03E9
                    bls       a43@
                    clra
                    clrb
                    puls      u,pc
a43@                tfr       u,d
                    puls      u,pc
* SendMidiBlock(event, chan): sends the 7,x-byte user MIDI string at offset 3,x: status bytes with a zero low nibble get the channel ORed in; system bytes get an F7 escape and length when filing.
SendMidiBlock       pshs      u
                    leas      -8,s
                    ldx       12,s
                    ldb       7,x
                    clra
                    std       5,s
                    pshs      a,b
                    ldx       14,s
                    ldd       3,x
                    pshs      a,b
                    bsr       MidiBlockAddr
                    leas      4,s
                    tfr       d,u
                    stu       -2,s
                    lbne      BlockByteNext
                    lbra      SendMidiBlockRet
                    fcb       $16,$00,$C1
* BlockByteLoop: loop over the block bytes; data bytes go straight out.
BlockByteLoop       ldb       ,u+
                    stb       2,s
                    lbge      BlockSendByte
                    ldb       <UmeData_smf
                    beq       a44@
                    lbsr      WriteDeltaTime
a44@                ldb       2,s
                    clra
                    andb      #$F0
                    cmpd      #$00F0
                    beq       BlockSysex
                    ldb       2,s
                    clra
                    andb      #$0F
                    lbne      BlockSendByte
                    ldb       2,s
                    clra
                    andb      #$F0
                    pshs      a,b
                    ldb       <$11,s
                    sex
                    ora       ,s+
                    orb       ,s+
                    stb       2,s
                    lbra      BlockSendByte
* BlockSysex: system byte in the block while filing: F0 kept, other system bytes re-sent after an F7 escape, then the length counted.
BlockSysex          ldb       <UmeData_smf
                    lbeq      BlockSendByte
                    stu       ,s
                    ldb       2,s
                    cmpb      #$F0
                    bne       a45@
                    ldd       #$0001
                    bra       b45@
a45@                clra
                    clrb
b45@                stb       7,s
                    bne       c45@
                    ldd       #$00F7
                    stb       2,s
                    leau      -1,u
c45@                ldb       2,s
                    sex
                    pshs      a,b
                    lbsr      PutMidiByte
                    leas      2,s
                    ldd       5,s
                    bra       SysexLenSet
* SysexLenScan: counts data bytes up to the next status byte or F7 to get the escape length.
SysexLenScan        ldx       ,s
                    leax      1,x
                    stx       ,s
                    ldb       -1,x
                    stb       2,s
                    bge       a46@
                    ldb       2,s
                    cmpb      #$F7
                    bne       b46@
a46@                ldd       3,s
                    addd      #$FFFF
* SysexLenSet: stores the sysex scan counter; BlockSysex jumps in to seed it with the remaining block length
SysexLenSet         std       3,s
                    ldd       3,s
                    bne       SysexLenScan
b46@                ldd       5,s
                    subd      3,s
                    std       3,s
                    ldd       5,s
                    subd      3,s
                    std       5,s
                    ldb       7,s
                    bne       c46@
                    ldd       3,s
                    addd      #$0001
                    std       3,s
c46@                ldd       3,s
                    pshs      a,b
                    lbsr      WriteVarLen
                    bra       SysexDataNext
* SysexDataLoop: sends the counted sysex data bytes.
SysexDataLoop       ldb       ,u+
                    sex
                    pshs      a,b
                    lbsr      PutMidiByte
* SysexDataNext: counter step of SysexDataLoop; also pops WriteVarLen's arg
SysexDataNext       leas      2,s
                    ldd       3,s
                    addd      #$FFFF
                    std       3,s
                    bge       SysexDataLoop
                    bra       BlockByteNext
* BlockSendByte: PutMidiByte of the current block byte 2,s
BlockSendByte       ldb       2,s
                    sex
                    pshs      a,b
                    lbsr      PutMidiByte
                    leas      2,s
* BlockByteNext: counter step of BlockByteLoop; SendMidiBlock branches in to start it
BlockByteNext       ldd       5,s
                    addd      #$FFFF
                    std       5,s
                    lbge      BlockByteLoop
* SendMidiBlockRet: exit of SendMidiBlock; taken when MidiBlockAddr returned 0
SendMidiBlockRet    leas      8,s
                    puls      u,pc
* SendRawMidiEvent(event): $1E: channel message 3,u/4,u/7,u with the channel from MidiChanTbl[6,u & $3F]; $1F: system message 3,u|$F0 with 0-3 data bytes selected by bits $60 of 3,u. 3,u >= 0 sends a MIDI block instead.
SendRawMidiEvent    pshs      u
                    ldu       4,s
                    leas      -6,s
                    ldb       3,u
                    stb       3,s
                    ldb       5,u
                    cmpb      #$1E
                    lbne      RawSysMsg
                    ldb       6,u
                    andb      #$3F               strip preserved-MIDI flag from part selector
                    sex
                    ldx       #MidiChanTbl
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$0F
                    stb       2,s
                    ldb       3,s
                    bge       c47@
                    ldb       3,s
                    clra
                    andb      #$0F
                    bne       a47@
                    ldb       3,s
                    clra
                    andb      #$F0
                    pshs      a,b
                    ldb       4,s
                    sex
                    ora       ,s+
                    orb       ,s+
                    stb       3,s
a47@                ldb       <UmeData_smf
                    beq       b47@
                    lbsr      WriteDeltaTime
* b47@: sends status, 4,u & $7F and, when 4,u >= 0, 7,u & $7F.
b47@                ldb       3,s
                    sex
                    pshs      a,b
                    lbsr      PutMidiByte
                    leas      2,s
                    ldb       4,u
                    clra
                    andb      #$7F
                    pshs      a,b
                    lbsr      PutMidiByte
                    leas      2,s
                    ldb       4,u
                    lblt      Pop6FrameRet
                    ldb       7,u
                    clra
                    andb      #$7F
                    pshs      a,b
                    lbsr      PutMidiByte
                    lbra      RawMsgPopDone
c47@                ldb       2,s
                    sex
                    lbra      RawBlockSend
* RawSysMsg: event $1F system/realtime message; F7 escape with length ((3,u>>5)&3)+1 when filing.
RawSysMsg           ldb       5,u
                    cmpb      #$1F
                    lbne      Pop6FrameRet
                    ldb       3,s
                    lbge      b48@
                    ldb       <UmeData_smf
                    beq       a48@
                    lbsr      WriteDeltaTime
                    ldd       #$00F7
                    pshs      a,b
                    lbsr      PutMidiByte
                    leas      2,s
                    ldb       3,s
                    sex
                    pshs      a,b
                    ldd       #$0005
                    lbsr      AsrShift
                    clra
                    andb      #$03
                    addd      #$0001
                    pshs      a,b
                    lbsr      PutMidiByte
                    leas      2,s
a48@                ldb       3,s
                    sex
                    orb       #$F0
                    pshs      a,b
                    lbsr      PutMidiByte
                    leas      2,s
                    ldb       3,s
                    clra
                    andb      #$60
                    stb       3,s
                    lbeq      Pop6FrameRet
                    ldb       4,u
                    sex
                    pshs      a,b
                    lbsr      PutMidiByte
                    leas      2,s
                    ldb       3,s
                    clra
                    andb      #$40
                    lbeq      Pop6FrameRet
                    ldb       7,u
                    sex
                    pshs      a,b
                    lbsr      PutMidiByte
                    leas      2,s
                    ldb       3,s
                    clra
                    andb      #$20
                    lbeq      Pop6FrameRet
                    ldb       6,u
                    sex
                    pshs      a,b
                    lbsr      PutMidiByte
                    bra       RawMsgPopDone
b48@                clra
                    clrb
* RawBlockSend: SendMidiBlock(event, chan in D) then unmaps the extra block with pswapevts(0)
RawBlockSend        pshs      a,b
                    pshs      u
                    lbsr      SendMidiBlock
                    leas      4,s
                    clra
                    clrb
                    pshs      a,b
                    jsr       [>UmeData_pswapevts]
* RawMsgPopDone: pops the last pushed byte then exits SendRawMidiEvent
RawMsgPopDone       leas      2,s
                    lbra      Pop6FrameRet
* WriteTimeSigMeta: delta, FF 58 04, numerator $03, log2(den) (2/4/8/16 -> 1..4), zonedur/2 clocks per click, 8; clears runstat.
WriteTimeSigMeta    pshs      u
                    leas      -5,s
                    lbsr      WriteDeltaTime
                    ldd       #$0003
                    pshs      a,b
                    leax      >hdrTimeSigMeta,pcr
                    pshs      x
                    jsr       [>UmeData_psmfwrit]
                    leas      4,s
                    ldd       <UmeData_reserved_0003
                    stb       1,s
                    ldd       #$0002
                    stb       ,s
                    ldd       <UmeData_reserved_0005
                    cmpd      #$0002
                    bne       a49@
                    ldd       #$0001
                    stb       ,s
a49@                ldd       <UmeData_reserved_0005
                    cmpd      #$0008
                    bne       b49@
                    ldd       #$0003
                    stb       ,s
b49@                ldd       <UmeData_reserved_0005
                    cmpd      #$0010
                    bne       c49@
                    ldd       #$0004
                    stb       ,s
c49@                ldb       ,s
                    stb       2,s
                    ldd       <UmeData_zonedur
                    lsra
                    rorb
                    stb       3,s
                    ldd       #$0008
                    stb       4,s
                    ldd       #$0004
                    pshs      a,b
                    leax      3,s
                    pshs      x
                    jsr       [>UmeData_psmfwrit]
                    leas      4,s
                    clra
                    clrb
                    std       <UmeData_runstat
                    leas      5,s
                    puls      u,pc
* WriteTempoMeta(tempo): delta, FF 51 03, then 3 bytes of (48000000 / zonedur) * secmin / tempo = microseconds per quarter.
WriteTempoMeta      pshs      a,b,x,u
                    lbsr      WriteDeltaTime
                    ldd       #$0003
                    pshs      a,b
                    leax      >hdrTempoMeta,pcr
                    pshs      x
                    jsr       [>UmeData_psmfwrit]
                    leas      4,s
                    leax      ,s
                    pshs      x
                    ldd       #$6C00
                    pshs      a,b
                    ldd       #$02DC
                    pshs      a,b
                    ldd       <UmeData_zonedur
                    lbsr      UIntToLong
                    lbsr      LongDiv
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       <UmeData_secmin
                    lbsr      IntToLong
                    lbsr      LongMul
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       14,s
                    lbsr      UIntToLong
                    lbsr      LongDiv
                    lbsr      LongStore
                    ldd       #$0003
                    pshs      a,b
                    leax      3,s
                    pshs      x
                    jsr       [>UmeData_psmfwrit]
                    leas      4,s
                    clra
                    clrb
                    std       <UmeData_runstat
                    lbra      SmfWriteFrameRet
* WriteKeySigMeta: delta, FF 59 02, keysig, 0 (major).
WriteKeySigMeta     pshs      u
                    lbsr      WriteDeltaTime
                    ldd       #$0003
                    pshs      a,b
                    leax      >hdrKeySigMeta,pcr
                    pshs      x
                    jsr       [>UmeData_psmfwrit]
                    leas      4,s
                    ldd       <UmeData_keysig
                    pshs      a,b
                    lbsr      PutMidiByte
                    leas      2,s
                    clra
                    clrb
                    pshs      a,b
                    lbsr      PutMidiByte
                    leas      2,s
                    clra
                    clrb
                    std       <UmeData_runstat
                    puls      u,pc
* WriteTextMeta(str, type): builds the long $00FF0000 + type<<8 + strlen as the 4 bytes 00 FF tt ll, writes them and the string with psmfwrit.
WriteTextMeta       pshs      a,b,x,y,u
                    ldd       10,s
                    pshs      a,b
                    lbsr      StrLen
                    leas      2,s
                    std       ,s
                    leax      2,s
                    pshs      x
                    ldd       14,s
                    pshs      a,b
                    ldd       #$0008
                    lbsr      AslShift
                    lbsr      IntToLong
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    bsr       TextMetaTail
                    neg       <UmeData_kpoctave
                    neg       <UmeData_reserved_0000
* TextMetaTail: continuation after the inline long $00FF0000 (bsr-over-constant idiom).
TextMetaTail        puls      x
                    lbsr      LongAdd
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       6,s
                    lbsr      IntToLong
                    lbsr      LongAdd
                    lbsr      LongStore
                    ldd       #$0004
                    pshs      a,b
                    leax      4,s
                    pshs      x
                    jsr       [>UmeData_psmfwrit]
                    leas      4,s
                    ldd       ,s
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    jsr       [>UmeData_psmfwrit]
                    leas      4,s
* Pop6FrameRet: shared leas 6,s / puls u,pc epilogue: WriteTextMeta falls in, SendRawMidiEvent branches here
Pop6FrameRet        leas      6,s
                    puls      u,pc
* WriteTitleText: track-name meta (3) = title at $0BEB + strViaUltimuse, then up to 9 text metas (1) from the 52-byte lines at mapped block +$1000.
WriteTitleText      pshs      u
                    leas      <-$58,s
                    ldx       #$0BEB
                    pshs      x
                    lbsr      StrLen
                    leas      2,s
                    std       ,s
                    lbeq      WriteTitleRet
                    ldx       #$0BEB
                    pshs      x
                    leax      10,s
                    pshs      x
                    lbsr      StrCpy
                    leas      4,s
                    leax      >strViaUltimuse,pcr
                    pshs      x
                    leax      10,s
                    pshs      x
                    lbsr      StrCat
                    leas      4,s
                    ldd       #$0003
                    pshs      a,b
                    leax      10,s
                    pshs      x
                    lbsr      WriteTextMeta
                    leas      4,s
                    ldd       #$0001
                    pshs      a,b
                    jsr       [>UmeData_pswapevts]
                    leas      2,s
                    clra
                    clrb
                    std       2,s
                    ldd       >UmeData_reserved_03E5
                    addd      #$1000
                    tfr       d,u
                    bra       TextLineTest
* TextLineLoop: loop over the 9 comment lines; lines of 1..51 chars are written.
TextLineLoop        pshs      u
                    lbsr      StrLen
                    leas      2,s
                    std       ,s
                    beq       a50@
                    ldd       ,s
                    cmpd      #$0033
                    bgt       a50@
                    ldd       #$0001
                    pshs      a,b
                    pshs      u
                    lbsr      WriteTextMeta
                    leas      4,s
a50@                ldd       2,s
                    addd      #$0001
                    std       2,s
                    subd      #$0001
                    leau      <$34,u
* TextLineTest: loop test of TextLineLoop; WriteTitleText branches in to start it
TextLineTest        ldd       2,s
                    cmpd      #$0009
                    blt       TextLineLoop
                    clra
                    clrb
                    pshs      a,b
                    jsr       [>UmeData_pswapevts]
                    leas      2,s
* WriteTitleRet: exit of WriteTitleText; taken when the title at $0BEB is empty
WriteTitleRet       leas      <$58,s
                    puls      u,pc
* WritePartInfo: "Part %d on Chan %d." per part (text meta 1), then "Instr %d: %s" (meta 4) for each of the 64 instruments with a patch or a name.
WritePartInfo       pshs      u
                    leas      <-$2A,s
                    ldd       #$0001
                    bra       PartLoopNext
* PartLoop: parts 1..nparts, channel = MidiChanTbl[p]+1.
PartLoop            ldd       ,s
                    ldx       #MidiChanTbl
                    leax      d,x
                    ldb       ,x
                    sex
                    addd      #$0001
                    pshs      a,b
                    ldd       2,s
                    pshs      a,b
                    leax      >fmtPartOnChan,pcr
                    pshs      x
                    leax      <$10,s
                    pshs      x
                    jsr       [>UmeData_psprintf]
                    leas      8,s
                    ldd       #$0001
                    pshs      a,b
                    leax      12,s
                    pshs      x
                    lbsr      WriteTextMeta
                    leas      4,s
                    ldd       ,s
                    addd      #$0001
* PartLoopNext: stores and tests the part index; WritePartInfo branches in with 1
PartLoopNext        std       ,s
                    ldd       ,s
                    cmpd      <UmeData_nparts
                    ble       PartLoop
                    clra
                    clrb
                    lbra      InstrLoopEntry
* InstrLoop: instruments 0..63: patch = low byte of word $075F[i] & $7F, name $07EB+i*16.
InstrLoop           ldd       ,s
                    aslb
                    rola
                    ldx       #$075F
                    leax      d,x
                    ldd       ,x
                    clra
                    andb      #$7F
                    std       2,s
                    ldd       ,s
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$07EB
                    leax      d,x
                    leau      ,x
                    ldd       2,s
                    bne       WriteInstrMeta
                    pshs      u
                    lbsr      StrLen
                    std       ,s++
                    beq       InstrLoopNext
* WriteInstrMeta: sprintf fmtInstrName and WriteTextMeta(buf, 4).
WriteInstrMeta      pshs      u
                    ldd       4,s
                    pshs      a,b
                    leax      >fmtInstrName,pcr
                    pshs      x
                    leax      <$10,s
                    pshs      x
                    jsr       [>UmeData_psprintf]
                    leas      8,s
                    ldd       #$0004
                    pshs      a,b
                    leax      12,s
                    pshs      x
                    lbsr      WriteTextMeta
                    leas      4,s
* InstrLoopNext: InstrLoop increment; an empty slot (patch 0, empty name) branches here
InstrLoopNext       ldd       ,s
                    addd      #$0001
* InstrLoopEntry: loop test (i < 64); WritePartInfo branches here with D = 0
InstrLoopEntry      std       ,s
                    ldd       ,s
                    cmpd      #$0040
                    lblt      InstrLoop
                    leas      <$2A,s
                    puls      u,pc
* WriteMidiHeader(tempo): MThd (14 bytes) and MTrk (8), title/text, part info, time-sig meta, tempo meta.
WriteMidiHeader     pshs      u
                    ldd       #$000E
                    pshs      a,b
                    leax      >hdrMThd,pcr
                    pshs      x
                    jsr       [>UmeData_psmfwrit]
                    leas      4,s
                    ldd       #$0008
                    pshs      a,b
                    leax      >hdrMTrk,pcr
                    pshs      x
                    jsr       [>UmeData_psmfwrit]
                    leas      4,s
                    lbsr      WriteTitleText
                    lbsr      WritePartInfo
                    lbsr      WriteTimeSigMeta
                    ldd       4,s
                    pshs      a,b
                    lbsr      WriteTempoMeta
                    leas      2,s
                    puls      u,pc
* FinishMidiTrack: writes 00 FF 2F 00 (end of track), flushes, position via LSeek(cur), length = pos - 22, LSeek to 18 and WritePath the 4-byte MTrk length.
FinishMidiTrack     pshs      a,b,x,u
                    leax      ,s
                    pshs      x
                    bsr       EotAndTell
                    neg       <UmeData_kpoctave
                    ble       EotAndTell
* EotAndTell: continuation after the inline 00 FF 2F 00: write it, flush, lseek(path, 0, 1).
EotAndTell          puls      x
                    lbsr      LongStore
                    ldd       #$0004
                    pshs      a,b
                    leax      2,s
                    pshs      x
                    jsr       [>UmeData_psmfwrit]
                    leas      4,s
                    jsr       [>UmeData_pmflush]
                    leax      ,s
                    pshs      x
                    ldd       #$0001
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    pshs      a,b
                    ldx       >UmeData_fmidi
                    ldd       8,x
                    pshs      a,b
                    lbsr      LSeek
                    leas      8,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    bsr       TrackLenPatch
                    neg       <UmeData_reserved_0000
                    neg       <UmeData_reserved_0016
* TrackLenPatch: continuation after the inline long 22: subtract, seek to 18, write 4 bytes.
TrackLenPatch       puls      x
                    lbsr      LongSub
                    lbsr      LongStore
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0012
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldx       >UmeData_fmidi
                    ldd       8,x
                    pshs      a,b
                    lbsr      LSeek
                    leas      8,s
                    ldd       #$0004
                    pshs      a,b
                    leax      2,s
                    pshs      x
                    ldx       >UmeData_fmidi
                    ldd       8,x
                    pshs      a,b
                    lbsr      WritePath
                    leas      6,s
* SmfWriteFrameRet: shared exit of FinishMidiTrack and WriteTempoMeta: drops the long scratch
SmfWriteFrameRet    leas      4,s
                    puls      u,pc
* WriteDeltaTime: WriteVarLen(smfdelta) then smfdelta = 0 (running delta in duration units).
WriteDeltaTime      pshs      u
                    ldd       <UmeData_smfdelta
                    pshs      a,b
                    lbsr      WriteVarLen
                    leas      2,s
                    clra
                    clrb
                    std       <UmeData_smfdelta
                    puls      u,pc
* tblMajorScale: semitones of C D E F G A B: 0,2,4,5,7,9,11.
tblMajorScale       fcb       $00,$02,$04,$05,$07,$09,$0B,$00
* hdrTimeSigMeta: FF 58 04 - SMF time signature meta header.
hdrTimeSigMeta      fcb       $FF,$58,$04,$00
* hdrTempoMeta: FF 51 03 - SMF set-tempo meta header.
hdrTempoMeta        fcb       $FF,$51,$03,$00
* hdrKeySigMeta: FF 59 02 - SMF key signature meta header.
hdrKeySigMeta       fcb       $FF,$59,$02,$00
* strViaUltimuse: appended to the title in the track-name meta.
strViaUltimuse      fcc       / via Studio-9 under CoCo3 OS-9 L2. /
                    fcb       $00
* fmtPartOnChan: sprintf format for the part text metas.
fmtPartOnChan       fcc       /Part %d on Chan %d./
                    fcb       $00
* fmtInstrName: sprintf format for the instrument-name metas.
fmtInstrName        fcc       /Instr %d: %s/
                    fcb       $00
* hdrMThd: "MThd" 00000006 0000 0001 0030 - format 0, one track, 48 ticks per quarter.
hdrMThd             fcc       /MThd/
                    fcb       $00,$00,$00,$06,$00,$00,$00,$01
                    fcb       $00,$30,$00
* hdrMTrk: "MTrk" 00000000 - track chunk header, length patched by FinishMidiTrack.
hdrMTrk             fcc       /MTrk/
                    fcb       $00,$00,$00,$00,$00
* GetEventPtr(index): curind = index; page = index/$3A0 + 1 is swapped in through ppswap when it is not curpage; returns curevp = database + 8*(index mod $3A0), or 0 when the swap fails.
GetEventPtr         pshs      u
                    ldu       4,s
                    leas      -2,s
                    stu       <UmeData_curind
                    ldd       #$0001
                    bra       b51@
a51@                ldd       ,s
                    addd      #$0001
b51@                std       ,s
                    leau      >-$03A0,u
                    stu       -2,s
                    bge       a51@
                    leau      >$03A0,u
                    ldd       ,s
                    cmpd      <UmeData_curpage
                    beq       c51@
                    ldd       ,s
                    pshs      a,b
                    jsr       [>UmeData_ppswap]
                    leas      2,s
                    bne       c51@
                    clra
                    clrb
                    bra       d51@
c51@                tfr       u,d
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    addd      <UmeData_database
                    std       <UmeData_curevp
d51@                leas      2,s
                    puls      u,pc
* NextEvent: curind++; curevp += 8, swapping in the next page (curevp = database) past curptop; returns curevp.
NextEvent           pshs      u
                    ldd       <UmeData_curind
                    addd      #$0001
                    std       <UmeData_curind
                    cmpd      <UmeData_nevents
                    bge       b52@
                    ldd       <UmeData_curevp
                    addd      #$0008
                    std       <UmeData_curevp
                    cmpd      <UmeData_curptop
                    bls       b52@
                    ldd       <UmeData_curpage
                    addd      #$0001
                    pshs      a,b
                    jsr       [>UmeData_ppswap]
                    leas      2,s
                    ldd       <UmeData_database
                    bra       a52@
                    fcb       $34,$40,$DC,$2B,$C3,$FF,$FF,$DD
                    fcb       $2B,$2D,$1D,$DC,$23,$C3,$FF,$F8
                    fcb       $DD,$23,$10,$93,$25,$24,$11,$DC
                    fcb       $2F,$C3,$FF,$FF,$34,$06,$AD,$9F
                    fcb       $03,$99,$32,$62,$DC,$27
a52@                std       <UmeData_curevp
b52@                ldd       <UmeData_curevp
                    puls      u,pc
* MidiHwSend: tail call to s9's C-compatible MIDI-byte dispatcher.
MidiHwSend          jmp       [>pMidiSend]
* MemCopy(dest, src, n): copies n bytes.
MemCopy             pshs      u
                    leas      -2,s
                    ldx       6,s
                    ldu       8,s
                    ldd       8,s
                    addd      10,s
                    std       ,s
                    bra       b54@
a54@                ldb       ,u+
                    stb       ,x+
b54@                cmpu      ,s
                    blo       a54@
                    leas      2,s
                    puls      u,pc
* FindDataBlock keeps the original's name but only starts TIMER1. The original probed the
* CoCo3 MMU at $FFA8 for its data block and read D.Tick through block 0; on wildbits $FFA8
* is the EDIT map's slot 0, so neither works. TIMER1 counts start-of-frame pulses (60 Hz,
* the kernel tick rate; the OS does not use the timers) upward and clears itself at 60.
FindDataBlock       ldb       #%00000010          clear the counter
                    stb       >T1_CTR
                    clr       >T1_CMP
                    clr       >T1_CMP+1
                    ldb       #60
                    stb       >T1_CMP+2
                    ldb       #%00000001          clear automatically at frame 60
                    stb       >T1_CMP_CTR
                    ldb       #%00001001          count up, one per start of frame
                    stb       >T1_CTR
                    rts
* ReadFineTick: an increasing time phase in 1/64 of a video frame, modulo one second
* (0..3839). TIMER1 supplies the frame and VICKY's live raster Y the fraction. VGA has 525
* lines; Y/8 gives 0..65 and is clamped to 63 for the final blanking lines. The frame is
* read on both sides of Y so a start-of-frame between the reads cannot pair an old frame
* with a new raster position. Playback accounting only: the score keeps its 60 Hz time base.
ReadFineTick        pshs      x
rft0@               lda       >T1_VAL+2           frame number 0..59
                    pshs      a
                    lda       >VKY_LINE_Y_POS_HI
                    ldb       >VKY_LINE_Y_POS_LO
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb                          raster Y / 8
                    cmpd      #63
                    bls       rft1@
                    ldd       #63                 vertical blank stays at the last sub-tick
rft1@               tfr       d,x
                    lda       >T1_VAL+2
                    cmpa      ,s+
                    bne       rft2@               frame moved while Y was sampled: retry
                    tfr       a,b
                    clra                          frame number modulo 60, increasing
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola                          x 64
                    pshs      x
                    addd      ,s++                plus 0..63 within this frame
                    puls      x,pc
rft2@               bra       rft0@
* ReadSysTick: 60 - (frame count mod 60) = 60..1, counting down like NitrOS-9's D.Tick
* (clock.asm decrements it); callers compute last - now (+60 on wrap) = ticks elapsed.
ReadSysTick         clra
                    ldb       >T1_VAL+2           hardware wraps this frame count at 60
                    pshs      a,b
                    ldd       #60
                    subd      ,s++                60 - that: 60..1, counting DOWN like D.Tick
                    rts
* StrCat(dest, src): finds the end of dest with StrEnd then copies src including the null.
StrCat              pshs      u
                    ldu       6,s
                    ldx       4,s
                    bsr       StrEnd
                    tfr       d,x
                    bra       StrCopyLoop
* StrCpy(dest, src): copies src to dest through the null, returns dest.
StrCpy              pshs      u
                    ldu       6,s
                    ldx       4,s
* StrCopyLoop: byte copy until the null; StrCpy falls in, StrCat branches here
StrCopyLoop         ldb       ,u+
                    stb       ,x+
                    bne       StrCopyLoop
                    ldd       4,s
                    puls      u,pc
                    fcb       $AE,$62
* StrEnd: returns the address of the terminating null of the string at X.
StrEnd              ldb       ,x+
                    bne       StrEnd
                    leax      -1,x
                    tfr       x,d
                    rts
* StrLen(str): scans to the null and returns end - start.
StrLen              pshs      u
                    ldu       4,s
a56@                ldb       ,u+
                    bne       a56@
                    leau      -1,u
                    tfr       u,d
                    subd      4,s
                    puls      u,pc
* LongMul: 32x32 multiply of the pushed long by [X] into the accumulator at $0343,y (ten 8x8 mul steps).
LongMul             ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      >$0343,y
                    clr       ,x
                    clr       1,x
                    lda       9,s
                    ldb       3,s
                    mul
                    std       2,x
                    lda       9,s
                    ldb       2,s
                    mul
                    addd      1,x
                    std       1,x
                    bhs       a57@
                    inc       ,x
a57@                lda       8,s
                    ldb       3,s
                    mul
                    addd      1,x
                    std       1,x
                    bhs       b57@
                    inc       ,x
b57@                lda       9,s
                    ldb       1,s
                    mul
                    addd      ,x
                    std       ,x
                    lda       8,s
                    ldb       2,s
                    mul
                    addd      ,x
                    std       ,x
                    lda       7,s
                    ldb       3,s
                    mul
                    addd      ,x
                    std       ,x
                    lda       9,s
                    ldb       ,s
                    mul
                    addb      ,x
                    stb       ,x
                    lda       8,s
                    ldb       1,s
                    mul
                    addb      ,x
                    stb       ,x
                    lda       7,s
                    ldb       2,s
                    mul
                    addb      ,x
                    stb       ,x
                    lda       6,s
                    ldb       3,s
                    mul
                    addb      ,x
                    stb       ,x
                    leas      4,s
                    lbra      LongEpilog
* LongDiv: signed 32-bit divide (pushed / [X]): LongDivCore, then negate when the sign flag is set.
LongDiv             bsr       LongDivCore
                    lda       1,s
                    beq       a58@
                    lbsr      LongNeg
* a58@: drops the 8-byte work area and returns through LongEpilog.
a58@                leas      8,s
                    lbra      LongEpilog
                    fcb       $A6,$84,$AA,$01,$AA,$02,$AA,$03
                    fcb       $26,$11,$EC,$84,$ED,$A9,$03,$43
                    fcb       $EC,$02,$30,$A9,$03,$43,$ED,$02
                    fcb       $16,$01,$50,$A6,$62,$A7,$A9,$0C
                    fcb       $CC,$8D,$2D,$EC,$6A,$30,$A9,$03
                    fcb       $43,$ED,$84,$EC,$6C,$ED,$02,$6D
                    fcb       $A9,$0C,$CC,$2B,$C3,$32,$68,$16
                    fcb       $01,$31
* LongDivCore: zero divisor -> errno 45 via SignalSelf; otherwise takes absolute values, normalizes and runs the shift-subtract loop.
LongDivCore         lda       ,x
                    ora       1,x
                    ora       2,x
                    ora       3,x
                    bne       a59@
                    ldd       2,s
                    std       6,s
                    leas      6,s
                    ldd       #$002D
                    lbra      SignalSelf
a59@                ldd       ,x
                    ldx       2,x
                    pshs      a,b,x
                    ldd       #$0000
                    pshs      a,b
                    std       >$0343,y
                    std       >$0345,y
                    tst       2,s
                    bpl       b59@
                    leax      2,s
                    lbsr      LongNeg
                    inc       1,s
b59@                tst       10,s
                    bpl       c59@
                    leax      10,s
                    lbsr      LongNeg
                    com       1,s
c59@                leax      >$0343,y
                    lda       #$01
d59@                inca
                    asl       5,s
                    rol       4,s
                    rol       3,s
                    rol       2,s
                    bpl       d59@
                    sta       ,s
* LongDivLoop: restoring shift-subtract loop over the normalized bit count.
LongDivLoop         ldd       12,s
                    subd      4,s
                    std       12,s
                    ldd       10,s
                    sbcb      3,s
                    sbca      2,s
                    std       10,s
                    bhs       a60@
                    ldd       12,s
                    addd      4,s
                    std       12,s
                    ldd       10,s
                    adcb      3,s
                    adca      2,s
                    std       10,s
                    andcc     #$FE
                    bra       b60@
a60@                orcc      #$01
b60@                rol       3,x
                    rol       2,x
                    rol       1,x
                    rol       ,x
                    lsr       2,s
                    ror       3,s
                    ror       4,s
                    ror       5,s
                    dec       ,s
                    bne       LongDivLoop
                    jmp       [<$06,s]
* LongAdd: accumulator = pushed long + [X].
LongAdd             ldd       4,s
                    addd      2,x
                    std       >$0345,y
                    ldd       2,s
                    adcb      1,x
                    adca      ,x
                    std       >$0343,y
                    lbra      LongEpilog
* LongSub: accumulator = pushed long - [X].
LongSub             ldd       4,s
                    subd      2,x
                    std       >$0345,y
                    ldd       2,s
                    sbcb      1,x
                    sbca      ,x
                    std       >$0343,y
                    lbra      LongEpilog
* LongCmp: compares the pushed long with [X]; returns the flags and pops the long.
LongCmp             ldd       2,s
                    cmpd      ,x
                    bne       b61@
                    ldd       4,s
                    cmpd      2,x
                    beq       b61@
                    blo       a61@
                    lda       #$01
                    andcc     #$FE
                    bra       b61@
a61@                clra
                    cmpa      #$01
b61@                pshs      cc
                    ldd       1,s
                    std       5,s
                    puls      cc
                    leas      4,s
                    rts
                    fcb       $17,$00,$62
* LongNeg: negates the 32-bit value at X in place.
LongNeg             ldd       #$0000
                    subd      2,x
                    std       2,x
                    ldd       #$0000
                    sbcb      1,x
                    sbca      ,x
                    std       ,x
                    rts
                    fcb       $EC,$84,$43,$53,$ED,$A9,$03,$43
                    fcb       $EC,$02
                    fcs       /CS0)/
                    fcb       $03,$43,$ED,$02,$39
* IntToLong: sign-extends D into the long accumulator at $0343,y.
IntToLong           leax      >$0343,y
                    std       2,x
                    tfr       a,b
                    sex
                    tfr       a,b
                    std       ,x
                    rts
* UIntToLong: zero-extends D into the long accumulator.
UIntToLong          leax      >$0343,y
                    std       2,x
                    clr       ,x
                    clr       1,x
                    rts
* LongStore: copies 4 bytes from X to the pushed destination and pops that argument.
LongStore           pshs      y
                    ldy       4,s
                    ldd       ,x
                    std       ,y
                    ldd       2,x
                    std       2,y
                    puls      x
                    exg       y,x
                    puls      a,b
                    std       ,s
                    rts
* LongEpilog: common exit of the long routines: drops the pushed long, X = accumulator.
LongEpilog          tfr       cc,a
                    puls      x
                    stx       2,s
                    leas      2,s
                    leax      >$0343,y
                    tfr       a,cc
                    rts
                    fcb       $EC,$84,$ED,$A9,$03,$43,$EC,$02
                    fcb       $30,$A9,$03,$43,$ED,$02,$39
* IntMul: 16x16 multiply of D by the pushed word, which it pops (single mul when both high bytes are 0).
IntMul              tsta
                    bne       IntMulWide
                    tst       2,s
                    bne       IntMulWide
                    lda       3,s
                    mul
                    ldx       ,s
                    stx       2,s
                    ldx       #$0000
                    std       ,s
                    puls      a,b,pc
* IntMulWide: four-partial-product path of IntMul.
IntMulWide          pshs      a,b
                    ldd       #$0000
                    pshs      a,b
                    pshs      a,b
                    lda       5,s
                    ldb       9,s
                    mul
                    std       2,s
                    lda       5,s
                    ldb       8,s
                    mul
                    addd      1,s
                    std       1,s
                    bhs       a62@
                    inc       ,s
a62@                lda       4,s
                    ldb       9,s
                    mul
                    addd      1,s
                    std       1,s
                    bhs       b62@
                    inc       ,s
b62@                lda       4,s
                    ldb       8,s
                    mul
                    addd      ,s
                    std       ,s
                    ldx       6,s
                    stx       8,s
                    ldx       ,s
                    ldd       2,s
                    leas      8,s
                    rts
                    fcb       $6F,$A9,$0C,$CD,$30,$8D,$00,$40
                    fcb       $AF,$A9,$0C,$CE,$20,$14
* IntMod: pushed % D through IntDiv ($0CCE,y), the dividend sign kept in $0CCD,y; returns the remainder with that sign.
IntMod              leax      >IntDiv,pcr
                    stx       >$0CCE,y
                    clr       >$0CCD,y
                    tst       2,s
                    bpl       a63@
                    inc       >$0CCD,y
a63@                subd      #$0000
                    bne       b63@
                    puls      x
                    ldd       ,s++
                    jmp       ,x
b63@                ldx       2,s
                    pshs      x
                    jsr       [>$0CCE,y]
                    ldd       ,s
                    std       2,s
                    tfr       x,d
                    tst       >$0CCD,y
                    beq       c63@
                    nega
                    negb
                    sbca      #$00
c63@                std       ,s++
                    rts
* UIntDiv: unsigned 16-bit divide (pushed / D) sharing the IntDiv loop; a zero divisor traps.
UIntDiv             subd      #$0000
                    beq       DivByZero
                    pshs      a,b
                    leas      -2,s
                    clr       ,s
                    clr       1,s
                    bra       DivNormalize
* DivByZero: errno 45 and F$Send to self via SignalSelf.
DivByZero           puls      a,b
                    std       ,s
                    ldd       #$002D
                    lbra      SignalSelf
* IntDiv: signed 16-bit divide pushed / D: quotient in D, remainder in X.
IntDiv              subd      #$0000
                    beq       DivByZero
                    pshs      a,b
                    leas      -2,s
                    clr       ,s
                    clr       1,s
                    tsta
                    bpl       a64@
                    nega
                    negb
                    sbca      #$00
                    com       1,s
                    std       2,s
a64@                ldd       6,s
                    bpl       DivNormalize
                    nega
                    negb
                    sbca      #$00
                    com       1,s
                    std       6,s
* DivNormalize: shifts the divisor left until bit 15 is set, counting iterations.
DivNormalize        lda       #$01
a65@                inca
                    asl       3,s
                    rol       2,s
                    bpl       a65@
                    sta       ,s
                    ldd       6,s
                    clr       6,s
                    clr       7,s
* DivLoop: restoring shift-subtract division loop.
DivLoop             subd      2,s
                    bhs       a66@
                    addd      2,s
                    andcc     #$FE
                    bra       b66@
a66@                orcc      #$01
b66@                rol       7,s
                    rol       6,s
                    lsr       2,s
                    ror       3,s
                    dec       ,s
                    bne       DivLoop
                    std       2,s
                    tst       1,s
                    beq       c66@
                    ldd       6,s
                    nega
                    negb
                    sbca      #$00
                    std       6,s
c66@                ldx       4,s
                    ldd       6,s
                    std       4,s
                    stx       6,s
                    ldx       2,s
                    ldd       4,s
                    leas      6,s
                    rts
* AsrShift: arithmetic shift right of the pushed word by B.
AsrShift            tstb
                    beq       ShiftDone
a67@                asr       2,s
                    ror       3,s
                    decb
                    bne       a67@
                    bra       ShiftDone
* LsrShift: logical shift right of the pushed word by B.
LsrShift            tstb
                    beq       ShiftDone
a68@                lsr       2,s
                    ror       3,s
                    decb
                    bne       a68@
* ShiftDone: common exit: returns the shifted word and pops the argument.
ShiftDone           ldd       2,s
                    pshs      a,b
                    ldd       2,s
                    std       4,s
                    ldd       ,s
                    leas      4,s
                    rts
* AslShift: shift left of the pushed word by B.
AslShift            tstb
                    beq       ShiftDone
a69@                asl       3,s
                    rol       2,s
                    decb
                    bne       a69@
                    bra       ShiftDone
* SignalSelf: errno = D, F$ID then F$Send signal B to the own process (divide-by-zero trap).
SignalSelf          std       >$034F,y
                    pshs      b,y
                    os9       F$ID
                    puls      b,y
                    os9       F$Send
                    rts
* WritePath(path, buf, n): I$Write, returns n or -1 with errno.
WritePath           pshs      y
                    ldy       8,s
                    beq       a70@
                    lda       5,s
                    ldx       6,s
                    os9       I$Write
                    bhs       a70@
                    puls      y
                    lbra      SetErrnoRet
a70@                tfr       y,d
                    puls      y,pc
                    fcb       $34,$20,$10,$AE,$68,$27,$F5,$A6
                    fcb       $65,$AE,$66,$10,$3F,$8C,$20,$E5
* LSeek(path, long offset, whence): base 0 (whence 0), SS.Pos (1) or SS.Size (2), then I$Seek; returns the new long position.
LSeek               pshs      u
                    ldd       10,s
                    bne       a71@
                    ldu       #$0000
                    ldx       #$0000
                    bra       DoSeek
a71@                cmpd      #$0001
                    beq       SeekFromCur
                    cmpd      #$0002
                    beq       SeekFromEnd
                    ldb       #$F7
* SeekError: errno = B, returns -1L.
SeekError           clra
                    std       >$034F,y
                    ldd       #$FFFF
                    leax      >$0343,y
                    std       ,x
                    std       2,x
                    puls      u,pc
* SeekFromEnd: I$GetStt SS.Size for whence 2.
SeekFromEnd         lda       5,s
                    ldb       #$02
                    os9       I$GetStt
                    blo       SeekError
                    bra       DoSeek
* SeekFromCur: I$GetStt SS.Pos for whence 1.
SeekFromCur         lda       5,s
                    ldb       #$05
                    os9       I$GetStt
                    blo       SeekError
* DoSeek: adds the offset to the base, rejects a negative result, I$Seek.
DoSeek              tfr       u,d
                    addd      8,s
                    std       >$0345,y
                    tfr       d,u
                    tfr       x,d
                    adcb      7,s
                    adca      6,s
                    bmi       SeekError
                    tfr       d,x
                    std       >$0343,y
                    lda       5,s
                    os9       I$Seek
                    blo       SeekError
                    leax      >$0343,y
                    puls      u,pc
                    fcb       $A6,$63,$E6,$65,$10,$3F,$08,$16
                    fcb       $00,$99,$4F,$5F,$10,$3F,$04,$10
                    fcb       $25,$00,$87,$AE,$62,$27,$04,$E7
                    fcb       $01,$6F,$84,$1F,$89,$4F,$39
* SetPriority(pid, prio): setpr = F$SPrior wrapper with carry-to-result.
SetPriority         lda       3,s
                    ldb       5,s
                    os9       F$SPrior
                    lbra      CarryToResult
                    fcb       $33,$E4,$32,$A9,$00,$FF,$AE,$42
                    fcb       $10,$AE,$44,$A6
                    fcs       /IHHHH*/
                    fcb       $4B,$E6,$4D,$EE,$46,$10,$3F,$05
                    fcb       $10,$3F,$06,$34,$60,$AE,$66,$10
                    fcb       $AE,$68,$EE,$6A,$A6,$6D,$AA,$6F
                    fcb       $E6,$E8,$11,$10,$3F,$03,$35,$60
                    fcb       $10,$25,$00,$3B,$1F,$89,$4F,$39
* Os9Call(code, regs): _os9: builds SWI2/code/RTS on the stack, loads D,X,Y,U from the register block, stores CC,D,DP,X,Y,U back, returns -1 on carry.
Os9Call             pshs      y,u
                    lda       7,s
                    ldb       #$39
                    pshs      a,b
                    ldd       #$103F
                    pshs      a,b
                    ldu       12,s
                    ldd       1,u
                    ldx       4,u
                    ldy       6,u
                    ldu       8,u
                    jsr       ,s
                    pshs      cc,u
                    ldu       15,s
                    leau      8,u
                    pshu      a,b,dp,x,y
                    puls      a,x
                    sta       ,-u
                    stx       8,u
                    leas      4,s
                    puls      y,u
                    bita      #$01
                    beq       a72@
                    ldd       #$FFFF
                    rts
* a72@: returns 0 (no carry).
a72@                clra
                    clrb
                    rts
* SetErrnoRet: errno ($034F,y) = B, returns -1.
SetErrnoRet         clra
                    std       >$034F,y
                    ldd       #$FFFF
                    rts
* CarryToResult: carry -> SetErrnoRet, else returns 0 (tail of SetPriority).
CarryToResult       blo       SetErrnoRet
                    clra
                    clrb
                    rts
                    fcb       $00,$22,$00,$00,$00,$00,$04,$00
                    fcb       $04,$00,$00,$00,$01,$47,$01,$45
                    fcb       $01,$43,$01,$41,$01,$3F,$01,$3D
                    fcb       $01,$56,$01,$54,$01,$52,$01,$50
                    fcb       $01,$4E,$01,$4C,$02,$0A,$01
                    fcc       /h4c/
                    fcb       $00,$03,$00,$02,$00,$04,$00,$00
                    fcb       $01,$11
                    fcc       /!1AYi/
                    fcb       $7F,$03,$00,$00,$00,$02,$03,$00
                    fcb       $00,$00,$02,$03,$00,$20,$00,$02
                    fcb       $02,$03,$02,$03,$04,$03,$03,$03
                    fcb       $03,$03,$03,$03,$00,$03,$03,$03
                    fcb       $03,$03,$03,$03,$03,$03,$03,$03
                    fcb       $03,$02,$02,$02,$04,$04,$02,$02
                    fcb       $03,$03,$01
                    fcc       /%c%c%c%c%c%c%c/
                    fcb       $00
                    fcc       /%c%c%c%c%c%c/
                    fcb       $0D,$00,$01,$80,$02,$40,$02,$A0
                    fcb       $01,$00,$00,$17,$00,$18,$00,$17
                    fcb       $00,$0C,$00,$17,$00,$11,$00,$17
                    fcb       $00,$05,$00,$17,$00,$00,$00,$17
                    fcb       $00,$12,$00,$17,$00,$10,$00,$17
                    fcb       $00,$00,$00,$17,$00,$17,$00,$17
                    fcb       $00,$17,$00,$17,$00,$17,$00,$17
                    fcb       $00,$17,$00,$17,$00,$17,$00,$17
                    fcb       $00,$17,$00,$17,$00,$17,$00,$17
                    fcb       $00,$17,$00,$17,$00,$17
                    fcc       /1234567890123456789012345678901234567890123456789/
                    fcb       $00
                    fcc       / Hi, Lester!  Keep your Hands off my code! -Mike /
                    fcb       $00
                    fcc       /1234567890123456789012345678901234567890123456789/
                    fcb       $00
                    fcc       / This array is here for a reason. You are one hel/
                    fcb       $00
                    fcc       /l of a C hacker if you figure out what that is!  /
                    fcb       $00
                    fcc       /1234567890123456789012345678901234567890123456789/
                    fcb       $00
                    fcc       /1234567890123456789012345678901234567890123456/
                    fcb       $00,$00,$1A,$01,$72,$01,$6E,$01
                    fcb       $6A,$01,$66,$01,$62,$01,$88,$01
                    fcb       $86,$01,$84,$01,$82,$01,$7E,$01
                    fcb       $7A,$01,$76,$01,$96,$01,$94,$01
                    fcb       $92,$01,$90,$01,$8E,$01,$8C,$01
                    fcb       $8A,$01,$A4,$01,$A2,$01,$A0,$01
                    fcb       $9E,$01,$9C,$01,$9A,$01,$98,$00
                    fcb       $0C,$00,$12,$00,$10,$00,$0E,$00
                    fcb       $0C,$00,$0A,$00,$20,$00,$1E,$00
                    fcb       $1C,$00,$1A,$00,$18,$00,$16,$00
                    fcb       $14
                    fcc       /s9p/
                    fcb       $00

* StopRawNotes: raw MIDI notes do not use the monophonic timers, so every live play end
* sends Sustain Off (CC 64 = 0) and then All Sound Off (CC 120) on all sixteen channels.
* CC 120 alone leaves a sustain pedal down, so later notes on that channel would hold.
StopRawNotes        tst       <UmeData_smf
                    bne       srn_done@
                    ldd       #$00B0
                    pshs      d
srn_loop@           ldd       ,s                  STACK OFFSET 0: the control-change status $B0+channel
                    bsr       srn_byte
                    ldb       #64                 Sustain (damper) pedal
                    bsr       srn_pair
                    ldb       #120                All Sound Off
                    bsr       srn_pair
                    inc       1,s
                    ldb       1,s
                    cmpb      #$C0
                    blo       srn_loop@
                    leas      2,s
                    jsr       [>UmeData_pmflush]
srn_done@           rts
* srn_pair: B = the controller number, sent followed by the value 0 (running status: the status byte went first)
srn_pair            clra
                    bsr       srn_byte
                    clra
                    clrb
srn_byte            pshs      d
                    lbsr      PutMidiByte
                    leas      2,s
                    rts
* PianoMark: while s9p plays, s9's PianoDraw jsr's here (PianoVec) instead of painting:
* A = the key index 0..87, B = lit. The change is queued for PianoFlush so no note waits for
* a paint; a full queue is painted first. The return address is the rts in front of s9's
* PianoPaint. Keeps every register.
PianoMark           pshs      d,x
                    ldx       4,s                 the rts after PianoDraw's jsr
                    stx       >PianoRts
                    ldb       >PianoQN
                    cmpb      #PianoQMax
                    blo       pmk1@
                    bsr       PianoFlush          full: paint what is waiting
                    clrb
pmk1@               inc       >PianoQN
                    ldx       #PianoQ
                    abx
                    abx                           two bytes an entry
                    ldd       ,s                  the key and its state as PianoDraw had them
                    std       ,x
                    puls      d,x,pc
* PianoFlush: paints the queued key changes in order through s9's PianoPaint and empties
* the queue. Called when a time slice with length starts (every note due then is out), from
* CheckAbort and as play ends. Keeps every register.
PianoFlush          pshs      d,x,u
                    ldu       >PianoRts           PianoPaint is at 1,u
                    ldx       #PianoQ
pfl1@               dec       >PianoQN
                    bmi       pfl2@               the queue is empty
                    ldd       ,x++                A the key, B lit
                    jsr       1,u                 PianoPaint keeps every register
                    bra       pfl1@
pfl2@               clr       >PianoQN
                    puls      d,x,u,pc
                    emod
eom                 equ       *
                    end
