********************************************************************
* s9b - Studio-9 note-beaming overlay
* Ported from UltiMusE III v10.11.4e (OS-9 Level 2) CMDS/Um3B, disassembled to byte-exact lwasm source.
* Port change: event pages hold 928 events ($03A0), not 1020, so a page fits the $1D00 visible bytes
* of DAT slot 7 (GPBLKS in s9.asm); SeekEvent carries its own copy of the page divide.
* Focus: the first staff pass skips FocusedPart; a second pass (BeamFocusPass) beams it alone, so
* the focused part is drawn after the others.
*
* No C startup of its own: the main program calls it with the shared data area (DP = data page 0;
* absolute data addresses such as the per-event x table $0425, y table $05C2, staff tables
* $0C5F/$0C19 and the vectors pnfwrite $0365, pdrawnr $038B, ppswap $0399).
* start -> EntryStub -> BeamNotes ($EA-byte frame). BeamNotes walks back from event lftind
* (PrevEvent) to the last bar line (IsBarEvent: staff 0, subtype <= 6) and the time signature
* (staff 0, subtype $0A, bytes 6/7 = numerator/denominator). Then for each staff 1..nparts it calls
* SetupMeter (dencodur = beat-unit index 2..5, dendur = 192/denominator ticks per beat, tripper =
* compound flag, zonedur = ticks per beat group, nzones = beats per bar) and StaffOptions
* (flag word: bits 0-1 force the stem flag, bit 2 = no beaming), and scans events lftind..ritind
* (SeekEvent/NextEvent: 8-byte records - byte 0 staff, word 1 time in ticks, byte 3 value index
* (>= 4 = eighth or shorter, beamable), byte 5 staff position or subtype, $20 = rest).
* Notes of the staff on the same beat ((time - bar time) / zonedur, unsigned) are collected into up
* to 16 ten-byte frame records {event index, x, y, stem extension, value}; a beat change, rest, bar
* line, time signature, the range end or a full group flushes it. A lone note is drawn with its
* flag via pdrawnr; a group gets a beam line from the first to the last stem, each interior note's
* deviation from it (dx*(y-y1) - dy*(x-x1)) / dx, a shift by the min/max deviation plus room for
* extra beams, then every note is redrawn beamed (stem x = column*8 + 1 or 9), stem extension
* lines ($B5), the main beam ($D0, style byte thick), full extra beams for 16ths etc. ($D1, spaced
* +-4) and partial beams per level ($D2; a lone stub is 7 px, see MidStubDir).
* The tail holds Microware C runtime helpers: MulInt16, DivInt16/DivUInt16 (quotient in D,
* remainder in X), ModInt16 (calls the divide through the data vector $0CCD), LongFromUInt/StoreLong
* (long accumulator at $0343) and the divide-by-zero trap (code $2D to $034F, then F$ID + F$Send
* to itself). The bytes after SendSelfSignal are the original initialized-data image (including
* the "Hi, Lester!" padding array), not referenced by code. Unlabeled fcb blocks between routines
* are unreferenced bytes of the original module. Local labels aN@/bN@ belong to routine N (lwasm
* has no per-routine scope).

                    nam       s9b
                    ttl       s9b (disassembly)

                  IFP1
                    use       defsfile
                  ENDC

tylg                set       $11
atrv                set       $81
size                equ       $104F
UME_SCOPE_S9B                  equ       1
                    use       equates.asm

                    mod       eom,name,tylg,atrv,start,size
name                fcs       /s9b/
                    fcb       $07
start               equ       *
                    lbra      EntryStub
                    fcb       $39,$0D,$00
* overlay entry: the standard pshs u / bsr / puls u,pc wrapper around the C routine
EntryStub           pshs      u
                    bsr       BeamNotes
                    puls      u,pc
* the overlay's only application routine ($EA-byte frame)
BeamNotes           pshs      u
                    leas      >-$00EA,s
                    clr       >BeamFocusPass
                    clra
                    clrb
                    std       <$48,s
                    ldd       <UmeData_lftind
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    bra       BackScanTest
* backward scan: while the bar time (frame $48) is still 0, IsBarEvent records its time 1,u
BackScanBody        ldd       <$48,s
                    bne       BackChkTimeSig
                    pshs      u
                    lbsr      IsBarEvent
                    std       ,s++
                    beq       BackChkTimeSig
                    ldd       1,u
                    std       <$48,s
* staff-0 time signature (subtype $0A): numerator 6,u -> frame $14, denominator 7,u -> frame $12; leave once the bar time is known
BackChkTimeSig      ldb       ,u
                    bne       BackScanPrev
                    ldb       5,u
                    cmpb      #$0A
                    bne       BackScanPrev
                    ldb       6,u
                    sex
                    std       <$14,s
                    ldb       7,u
                    sex
                    std       <$12,s
                    ldd       <$48,s
                    bne       StaffLoopInit
BackScanPrev        lbsr      PrevEvent
* u = event pointer; continue while curind >= 0
BackScanTest        tfr       d,u
                    ldd       <UmeData_curind
                    bge       BackScanBody
* staff counter (frame $42) = 1; loops staff 1..nparts
StaffLoopInit       ldd       #$0001
                    std       <$42,s
                    lbra      StaffLoopTest
* per staff: SetupMeter, then frame 6 = simple meter (tripper 0) with denominator >= 8
BeamStaffBody       ldd       <UmeData_reserved_0003
                    subd      <$14,s
                    ldd       <UmeData_reserved_0005
                    std       <$12,s
                    lbsr      SetupMeter
                    ldb       <UmeData_tripper
                    bne       a1@
                    ldd       #$0001
                    bra       b1@
a1@                 clra
                    clrb
b1@                 pshs      a,b
                    ldd       <UmeData_reserved_0005
                    cmpd      #$0008
                    blt       c1@
                    ldd       #$0001
                    bra       GetStaffFlags
c1@                 clra
                    clrb
* StaffOptions(staff, &attr frame $3A, &flags frame 10); flag bit 2 = no beaming, skip the staff
GetStaffFlags       anda      ,s+
                    andb      ,s+
                    stb       6,s
                    leax      10,s
                    pshs      x
                    leax      <$3C,s
                    pshs      x
                    ldd       <$46,s
                    pshs      a,b
                    lbsr      StaffOptions
                    leas      6,s
                    ldd       10,s
                    clra
                    andb      #$04
                    beq       ChkStemOption
                    lbra      NextStaff
* flag bits 0-1 clear -> automatic stem direction (frame 9 = 1)
ChkStemOption       ldd       10,s
                    clra
                    andb      #$03
                    bne       a2@
                    ldd       #$0001
                    bra       FwdScanInit
a2@                 clra
                    clrb
* clear flush flag and group count/beats, bar time -> frame $46, SeekEvent(lftind)
FwdScanInit         stb       9,s
                    clra
                    clrb
                    stb       8,s
                    clra
                    clrb
                    std       <$34,s
                    std       <$36,s
                    std       <$32,s
                    ldd       <$48,s
                    std       <$46,s
                    ldd       <UmeData_lftind
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    tfr       d,u
                    lbra      FwdScanTest
* last event of the range (curind == ritind) forces a flush (frame 8)
FwdScanBody         ldd       <UmeData_curind
                    cmpd      <UmeData_ritind
                    bne       ChkStaffNote
                    ldd       #$0001
                    stb       8,s
* event on this staff: rest ($20 at 5,u) flushes; x (signed) from $0425, y from $05C2, indexed by curind - xyoff
ChkStaffNote        ldb       ,u
                    sex
                    cmpd      <$42,s
                    lbne      ChkBarEvent
                    ldb       5,u
                    cmpb      #$20
                    lbeq      SetFlush
                    ldd       <UmeData_curind
                    subd      <UmeData_xyoff
                    ldx       #$0425
                    leax      d,x
                    ldb       ,x
                    sex
                    std       4,s
                    ldd       <UmeData_curind
                    subd      <UmeData_xyoff
                    ldx       #$05C2
                    leax      d,x
                    ldb       ,x
                    clra
                    std       2,s
                    ldd       10,s
                    clra
                    andb      #$01
                    bne       StemFlagZero
                    ldd       10,s
                    clra
                    andb      #$02
                    beq       StemFromPos
* stem flag := 1: option bit 1, or position 5,u > 4
StemFlagOne         ldd       #$0001
                    bra       CalcBeatIndex
* automatic: stem flag (frame 7) = position 5,u > 4
StemFromPos         ldb       5,u
                    cmpb      #$04
                    bgt       StemFlagOne
* stem flag := 0: option bit 0, or position <= 4
StemFlagZero        clra
                    clrb
* beat (frame $38) = (time - bar time) / zonedur; in x/8 simple meters the tick offset within the beat goes to the long at frame $3C
CalcBeatIndex       stb       7,s
                    ldd       1,u
                    subd      <$46,s
                    pshs      a,b
                    ldd       >UmeData_zonedur
                    lbsr      DivUInt16
                    std       <$38,s
                    ldb       6,s
                    beq       ChkBeamable
                    leax      <$3C,s
                    pshs      x
                    ldd       <$3A,s
                    pshs      a,b
                    ldd       >UmeData_zonedur
                    lbsr      MulInt16
                    pshs      a,b
                    ldd       1,u
                    subd      <$4A,s
                    subd      ,s++
                    lbsr      LongFromUInt
                    lbsr      StoreLong
* value 3,u < 4 (quarter or longer): draw alone via pdrawnr(&ev+3, x, y, attr, stemflag, 0, 1) and flush
ChkBeamable         ldb       3,u
                    cmpb      #$04
                    bge       StartGroup
                    ldd       #$0001
                    stb       8,s
                    ldd       #$0001
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldb       11,s
                    sex
                    pshs      a,b
                    ldd       <$40,s
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    pshs      u
                    ldd       #$0003
                    addd      ,s++
                    pshs      a,b
                    jsr       [>UmeData_pdrawnr]
                    leas      14,s
                    lbra      ChkFlush
* count == 0: first record {index, x, y, -, value}; position sum ($22), min/max value (14/12), group beat ($34/$36)
StartGroup          ldd       <$32,s
                    bne       ChkSameBeat
                    leax      <$4A,s
                    stx       ,s
                    ldb       5,u
                    sex
                    std       <$22,s
                    ldd       4,s
                    ldx       ,s
                    std       2,x
                    ldd       2,s
                    ldx       ,s
                    std       4,x
                    ldd       <UmeData_curind
                    std       [,s]
                    ldb       3,u
                    sex
                    std       12,s
                    std       14,s
                    ldx       ,s
                    std       8,x
                    ldd       #$0001
                    std       <$32,s
                    ldd       <$38,s
                    std       <$34,s
                    std       <$36,s
                    lbra      ChkFlush
* same beat as the group -> append; else break, except in x/8 simple meters (frame 6) when beat - group beat >= count or the note is off the beat
ChkSameBeat         ldd       <$38,s
                    cmpd      <$36,s
                    beq       AppendGroup
                    ldb       6,s
                    lbeq      BreakGroup
                    ldd       <$38,s
                    subd      <$34,s
                    cmpd      <$32,s
                    bge       AppendGroup
                    leax      <$3C,s
                    lda       ,x
                    ora       1,x
                    ora       2,x
                    ora       3,x
                    lbeq      BreakGroup
* count++, next record, position sum += position, store {index, x, y, value}, track the minimum value (frame 14)
AppendGroup         ldd       <$32,s
                    addd      #$0001
                    std       <$32,s
                    ldd       ,s
                    addd      #$000A
                    std       ,s
                    ldd       <$22,s
                    pshs      a,b
                    ldb       5,u
                    sex
                    addd      ,s++
                    std       <$22,s
                    ldd       4,s
                    ldx       ,s
                    std       2,x
                    ldd       2,s
                    ldx       ,s
                    std       4,x
                    ldd       <UmeData_curind
                    std       [,s]
                    ldb       3,u
                    sex
                    ldx       ,s
                    std       8,x
                    ldx       ,s
                    ldd       8,x
                    cmpd      14,s
                    bge       TrackMaxValue
                    ldx       ,s
                    ldd       8,x
                    std       14,s
* track the maximum value (frame 12, most beams)
TrackMaxValue       ldx       ,s
                    ldd       8,x
                    cmpd      12,s
                    ble       ChkGroupFull
                    ldx       ,s
                    ldd       8,x
                    std       12,s
* 16 notes in the group force a flush
ChkGroupFull        ldd       <$32,s
                    cmpd      #$0010
                    blt       ChkFlush
                    bra       SetFlush
* beat changed: flush, remember the beat, PrevEvent so this note starts the next group
BreakGroup          ldd       #$0001
                    stb       8,s
                    ldd       <$38,s
                    std       <$34,s
                    lbsr      PrevEvent
                    tfr       d,u
                    bra       ChkFlush
* event of another staff: a bar line sets the bar time (frame $46), resets the beats and flushes
ChkBarEvent         pshs      u
                    lbsr      IsBarEvent
                    std       ,s++
                    beq       ChkTimeSigEvt
                    ldd       1,u
                    std       <$46,s
                    clra
                    clrb
                    std       <$34,s
                    std       <$38,s
                    bra       SetFlush
* staff-0 time signature: numerator/denominator to <$03/<$05, SetupMeter, flush
ChkTimeSigEvt       ldb       ,u
                    bne       ChkFlush
                    ldb       5,u
                    cmpb      #$0A
                    bne       ChkFlush
                    ldb       6,u
                    sex
                    std       <UmeData_reserved_0003
                    ldb       7,u
                    sex
                    std       <UmeData_reserved_0005
                    lbsr      SetupMeter
* frame 8 = 1: the group must be drawn now
SetFlush            ldd       #$0001
                    stb       8,s
ChkFlush            ldb       8,s
                    bne       ChkGroupEmpty
                    lbra      FwdScanNext
* clear the flush flag; nothing collected -> FwdScanNext
ChkGroupEmpty       clra
                    clrb
                    stb       8,s
                    ldd       <$32,s
                    bne       FlushGroup
                    lbra      FwdScanNext
* save the scan index (frame $10); one note -> drawn with its flag, more -> AutoStemDir
FlushGroup          ldd       <UmeData_curind
                    std       <$10,s
                    ldd       <$32,s
                    cmpd      #$0001
                    lbne      AutoStemDir
                    leax      <$4A,s
                    stx       ,s
                    ldd       [,s]
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    tfr       d,u
                    ldd       10,s
                    clra
                    andb      #$01
                    bne       SingleStemZero
                    ldd       10,s
                    clra
                    andb      #$02
                    beq       SingleStemDir
* lone note: stem flag := 1 (option bit 1, or position > 4)
SingleStemOne       ldd       #$0001
                    bra       DrawSingleNote
SingleStemDir       ldb       5,u
                    cmpb      #$04
                    bgt       SingleStemOne
* lone note: stem flag := 0 (option bit 0, or position <= 4)
SingleStemZero      clra
                    clrb
* pdrawnr(&ev+3, x, y, attr, stemflag, 0, 1), count = 0, SeekEvent back to the saved index
DrawSingleNote      stb       7,s
                    ldd       #$0001
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldb       11,s
                    sex
                    pshs      a,b
                    ldd       <$40,s
                    pshs      a,b
                    ldx       8,s
                    ldd       4,x
                    pshs      a,b
                    ldx       10,s
                    ldd       2,x
                    pshs      a,b
                    pshs      u
                    ldd       #$0003
                    addd      ,s++
                    pshs      a,b
                    jsr       [>UmeData_pdrawnr]
                    leas      14,s
                    clra
                    clrb
                    std       <$32,s
                    ldd       <$10,s
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    lbra      FwdScanNext
* automatic direction: stem flag = count*4 < position sum (average position > 4)
AutoStemDir         ldb       9,s
                    beq       InitBeamLine
                    ldd       <$32,s
                    aslb
                    rola
                    aslb
                    rola
                    cmpd      <$22,s
                    bge       a3@
                    ldd       #$0001
                    bra       b3@
a3@                 clra
                    clrb
b3@                 stb       7,s
* beam ends (x1,y1) = rec[0], (x2,y2) = rec[count-1] with extension 0; dx/dy and the interior loop when count > 2
InitBeamLine        leax      <$4A,s
                    stx       ,s
                    ldd       2,x
                    std       <$2A,s
                    ldx       ,s
                    ldd       4,x
                    std       <$28,s
                    clra
                    clrb
                    ldx       ,s
                    std       6,x
                    ldd       <$32,s
                    addd      #$FFFF
                    pshs      a,b
                    ldd       #$000A
                    lbsr      MulInt16
                    leax      <$4A,s
                    leax      d,x
                    stx       ,s
                    ldd       2,x
                    std       <$26,s
                    ldx       ,s
                    ldd       4,x
                    std       <$24,s
                    clra
                    clrb
                    ldx       ,s
                    std       6,x
                    clra
                    clrb
                    std       <$16,s
                    std       <$18,s
                    ldd       <$32,s
                    cmpd      #$0002
                    lble      CalcBeamExtra
                    ldd       <$26,s
                    subd      <$2A,s
                    std       <$20,s
                    ldd       <$24,s
                    subd      <$28,s
                    std       <$1E,s
                    ldd       #$0001
                    std       <$1C,s
                    leax      <$54,s
                    stx       ,s
                    lbra      DevLoopTest
* interior deviation (dx*(y-y1) - dy*(x-x1)) / dx -> rec+6; track the minimum (frame $16)
DevLoopBody         ldx       ,s
                    ldd       2,x
                    std       4,s
                    ldx       ,s
                    ldd       4,x
                    std       2,s
                    ldd       <$1E,s
                    pshs      a,b
                    ldd       6,s
                    subd      <$2C,s
                    lbsr      MulInt16
                    pshs      a,b
                    ldd       <$22,s
                    pshs      a,b
                    ldd       6,s
                    subd      <$2C,s
                    lbsr      MulInt16
                    subd      ,s++
                    std       <$1A,s
                    pshs      a,b
                    ldd       <$22,s
                    lbsr      DivInt16
                    std       <$1A,s
                    ldx       ,s
                    std       6,x
                    ldd       <$1A,s
                    cmpd      <$16,s
                    bge       TrackMaxDev
                    ldd       <$1A,s
                    std       <$16,s
* track the maximum deviation (frame $18)
TrackMaxDev         ldd       <$1A,s
                    cmpd      <$18,s
                    ble       DevLoopNext
                    ldd       <$1A,s
                    std       <$18,s
DevLoopNext         ldd       <$1C,s
                    addd      #$0001
                    std       <$1C,s
                    subd      #$0001
                    ldd       ,s
                    addd      #$000A
                    std       ,s
                    subd      #$000A
* loop while i < count-1
DevLoopTest         ldd       <$32,s
                    addd      #$FFFF
                    cmpd      <$1C,s
                    lbgt      DevLoopBody
* extra room (frame $2C) = (max value-5)*4-2 for 32nd notes or shorter, else 0
CalcBeamExtra       ldd       12,s
                    cmpd      #$0005
                    ble       a4@
                    ldd       12,s
                    addd      #$FFFB
                    aslb
                    rola
                    aslb
                    rola
                    addd      #$FFFE
                    bra       ShiftBeamLine
a4@                 clra
                    clrb
* shift = stem flag ? min deviation - extra : max deviation + extra, so every stem reaches the beam
ShiftBeamLine       std       <$2C,s
                    ldb       7,s
                    beq       a5@
                    ldd       <$16,s
                    subd      <$2C,s
                    bra       ApplyBeamShift
a5@                 ldd       <$18,s
                    addd      <$2C,s
* y1 += shift, y2 += shift, then the beamed-note loop
ApplyBeamShift      std       <$18,s
                    ldd       <$28,s
                    addd      <$18,s
                    std       <$28,s
                    ldd       <$24,s
                    addd      <$18,s
                    std       <$24,s
                    clra
                    clrb
                    std       <$1C,s
                    leax      <$4A,s
                    stx       ,s
                    lbra      DrawNoteTest
* pdrawnr(&ev+3, x, y, attr, stemflag, 1, 1); rec+6 -= shift; stem x = column*8 + (stem flag ? 1 : 9); first stem x -> x1
DrawBeamedNote      ldd       [,s]
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    tfr       d,u
                    ldx       ,s
                    ldd       2,x
                    std       4,s
                    ldx       ,s
                    ldd       4,x
                    std       2,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldb       11,s
                    sex
                    pshs      a,b
                    ldd       <$40,s
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    pshs      u
                    ldd       #$0003
                    addd      ,s++
                    pshs      a,b
                    jsr       [>UmeData_pdrawnr]
                    leas      14,s
                    ldx       ,s
                    ldd       6,x
                    subd      <$18,s
                    std       6,x
                    ldd       4,s
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    pshs      a,b
                    ldb       9,s
                    beq       a6@
                    ldd       #$0001
                    bra       b6@
a6@                 ldd       #$0009
b6@                 addd      ,s++
                    std       4,s
                    ldx       ,s
                    std       2,x
                    ldd       <$1C,s
                    bne       ChkLastStemX
                    ldd       4,s
                    std       <$2A,s
* last record: its stem x -> x2 (frame $26)
ChkLastStemX        ldd       <$32,s
                    addd      #$FFFF
                    cmpd      <$1C,s
                    bne       DrawNoteNext
                    ldd       4,s
                    std       <$26,s
DrawNoteNext        ldd       <$1C,s
                    addd      #$0001
                    std       <$1C,s
                    subd      #$0001
                    ldd       ,s
                    addd      #$000A
                    std       ,s
                    subd      #$000A
* loop while i < count; then beam offset (frame $30) = -13/+13 and beam spacing (frame $2E) = +4/-4 by stem flag
DrawNoteTest        ldd       <$1C,s
                    cmpd      <$32,s
                    lblt      DrawBeamedNote
                    ldb       7,s
                    beq       StemsDownConst
                    ldd       #$FFF3
                    std       <$30,s
                    ldd       #$0004
                    bra       StemLoopInit
StemsDownConst      ldd       #$000D
                    std       <$30,s
                    ldd       #$FFFC
* store the spacing, i = 0, pointer = rec[0]
StemLoopInit        std       <$2E,s
                    clra
                    clrb
                    std       <$1C,s
                    leax      <$4A,s
                    stx       ,s
                    lbra      StemLoopTest
* note with a non-zero extension: stem flag set -> DrawStemLine(x, y-ext, y, 1), clear -> (x, y, y-ext, 1); y = note y + beam offset
StemLoopBody        ldx       ,s
                    ldd       2,x
                    std       4,s
                    ldx       ,s
                    ldd       4,x
                    addd      <$30,s
                    std       2,s
                    ldx       ,s
                    ldd       6,x
                    beq       StemLoopNext
                    ldb       7,s
                    beq       StemDownArgs
                    ldd       #$0001
                    pshs      a,b
                    ldd       4,s
                    pshs      a,b
                    ldd       6,s
                    ldx       4,s
                    subd      6,x
                    bra       CallStemLine
StemDownArgs        ldd       #$0001
                    pshs      a,b
                    ldd       4,s
                    ldx       2,s
                    subd      6,x
                    pshs      a,b
                    ldd       6,s
CallStemLine        pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    lbsr      DrawStemLine
                    leas      8,s
StemLoopNext        ldd       <$1C,s
                    addd      #$0001
                    std       <$1C,s
                    subd      #$0001
                    ldd       ,s
                    addd      #$000A
                    std       ,s
                    subd      #$000A
* loop while i < count; then y1/y2 += beam offset; thick with stem flag set raises the beam one pixel
StemLoopTest        ldd       <$1C,s
                    cmpd      <$32,s
                    lblt      StemLoopBody
                    ldd       <$28,s
                    addd      <$30,s
                    std       <$28,s
                    ldd       <$24,s
                    addd      <$30,s
                    std       <$24,s
                    ldb       <UmeData_thick
                    beq       BeamArgs
                    ldb       7,s
                    beq       BeamArgs
                    ldd       <$24,s
                    addd      #$FFFF
                    pshs      a,b
                    ldd       <$28,s
                    pshs      a,b
                    ldd       <$2C,s
                    addd      #$FFFF
                    bra       CallDrawBeam
BeamArgs            ldd       <$24,s
                    pshs      a,b
                    ldd       <$28,s
                    pshs      a,b
                    ldd       <$2C,s
* DrawBeam(x1, y1, x2, y2); extra-beam offset (frame $1E) = spacing; i = 5
CallDrawBeam        pshs      a,b
                    ldd       <$30,s
                    pshs      a,b
                    lbsr      DrawBeam
                    leas      8,s
                    ldd       <$2E,s
                    std       <$1E,s
                    ldd       #$0005
                    bra       SubBeamTest
* DrawSubBeam(offset), offset += spacing, for i = 5..minimum value (beams every note carries)
SubBeamLoop         ldd       <$1E,s
                    pshs      a,b
                    lbsr      DrawSubBeam
                    leas      2,s
                    ldd       <$1E,s
                    addd      <$2E,s
                    std       <$1E,s
                    ldd       <$1C,s
                    addd      #$0001
* loop while i <= minimum value; then 8 more bytes of locals (frame offsets +8 below) and level = minimum+1
SubBeamTest         std       <$1C,s
                    ldd       <$1C,s
                    cmpd      14,s
                    ble       SubBeamLoop
                    leas      -8,s
                    ldd       <$16,s
                    addd      #$0001
                    std       6,s
                    lbra      LevelLoopTest
* partial-beam level loop: run length = 0, flush = 0, i = 0, pointer = rec[0]
LevelLoopInit       clra
                    clrb
                    std       4,s
                    clra
                    clrb
                    stb       <$10,s
                    clra
                    clrb
                    std       <$24,s
                    leax      <$52,s
                    stx       8,s
                    lbra      RunScanTest
* runs of notes whose value >= level; the last note flushes the run
RunScanBody         ldd       <$3A,s
                    addd      #$FFFF
                    cmpd      <$24,s
                    bne       ChkRunBreak
                    ldd       #$0001
                    stb       <$10,s
* value below the level: flush the run without extending it
ChkRunBreak         ldx       8,s
                    ldd       8,x
                    cmpd      6,s
                    bge       ExtendRun
                    ldd       #$0001
                    stb       <$10,s
                    bra       FlushRun
* run end = i; run start = i when the run was empty; length++
ExtendRun           ldd       <$24,s
                    std       ,s
                    ldd       4,s
                    bne       a7@
                    ldd       <$24,s
                    std       2,s
a7@                 ldd       4,s
                    addd      #$0001
                    std       4,s
* draw the run: length > 1 -> DrawPartBeam(offset, start x, end x); length 1 -> 7-pixel stub
FlushRun            ldb       <$10,s
                    lbeq      RunScanNext
                    clra
                    clrb
                    stb       <$10,s
                    ldd       4,s
                    lbeq      RunScanNext
                    ldd       2,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      MulInt16
                    leax      <$52,s
                    leax      d,x
                    ldd       2,x
                    std       <$28,s
                    ldd       4,s
                    cmpd      #$0001
                    ble       SingleStub
                    ldd       ,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      MulInt16
                    leax      <$52,s
                    leax      d,x
                    ldd       2,x
* DrawPartBeam tail entered with the to-x in D (SingleStub: x+7)
RunStubCallTo       pshs      a,b
                    ldd       <$2A,s
* the same tail with the to-x pushed and the from-x in D (ChkLastStub: x-7)
RunStubCallFrom     pshs      a,b
                    ldd       <$2A,s
                    pshs      a,b
                    lbsr      DrawPartBeam
                    lbra      RunDone
* lone note first in the group: stub to the right (x..x+7)
SingleStub          ldd       2,s
                    bne       ChkLastStub
                    ldd       <$28,s
                    addd      #$0007
                    bra       RunStubCallTo
* lone note last in the group: stub to the left (x-7..x)
ChkLastStub         ldd       <$3A,s
                    addd      #$FFFF
                    cmpd      2,s
                    bne       MidStubDir
                    ldd       <$28,s
                    pshs      a,b
                    ldd       <$2A,s
                    addd      #$FFF9
                    bra       RunStubCallFrom
* interior lone note: times of it and its neighbors; the stub points left when the next note is closer, else right
MidStubDir          leas      -6,s
                    ldd       8,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      MulInt16
                    leax      <$58,s
                    leax      d,x
                    ldd       ,x
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    tfr       d,x
                    ldd       1,x
                    std       2,s
                    ldd       8,s
                    addd      #$FFFF
                    pshs      a,b
                    ldd       #$000A
                    lbsr      MulInt16
                    leax      <$58,s
                    leax      d,x
                    ldd       ,x
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    tfr       d,x
                    ldd       1,x
                    std       4,s
                    ldd       8,s
                    addd      #$0001
                    pshs      a,b
                    ldd       #$000A
                    lbsr      MulInt16
                    leax      <$58,s
                    leax      d,x
                    ldd       ,x
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    tfr       d,x
                    ldd       1,x
                    std       ,s
                    ldd       2,s
                    subd      4,s
                    pshs      a,b
                    ldd       2,s
                    subd      4,s
                    cmpd      ,s++
                    bhs       StubRight
                    ldd       <$2E,s
                    pshs      a,b
                    ldd       <$30,s
                    addd      #$FFF9
                    bra       CallStubBeam
* stub x..x+7: the next note is at least as far as the previous
StubRight           ldd       <$2E,s
                    addd      #$0007
                    pshs      a,b
                    ldd       <$30,s
CallStubBeam        pshs      a,b
                    ldd       <$30,s
                    pshs      a,b
                    lbsr      DrawPartBeam
                    leas      6,s
* drop 6 bytes (the arguments, or MidStubDir's times), run length = 0
RunDone             leas      6,s
                    clra
                    clrb
                    std       4,s
RunScanNext         ldd       <$24,s
                    addd      #$0001
                    std       <$24,s
                    subd      #$0001
                    ldd       8,s
                    addd      #$000A
                    std       8,s
                    subd      #$000A
* loop while i < count; then level++ and offset += spacing
RunScanTest         ldd       <$24,s
                    cmpd      <$3A,s
                    lblt      RunScanBody
                    ldd       6,s
                    addd      #$0001
                    std       6,s
                    subd      #$0001
                    ldd       <$26,s
                    addd      <$36,s
                    std       <$26,s
* loop while level <= maximum value; then drop the locals, SeekEvent back to the saved index, count = 0, flush = 0
LevelLoopTest       ldd       6,s
                    cmpd      <$14,s
                    lble      LevelLoopInit
                    leas      8,s
                    ldd       <$10,s
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    clra
                    clrb
                    std       <$32,s
                    clra
                    clrb
                    stb       8,s
FwdScanNext         lbsr      NextEvent
                    tfr       d,u
* forward scan continues while curind <= ritind
FwdScanTest         ldd       <UmeData_curind
                    cmpd      <UmeData_ritind
                    lble      FwdScanBody
NextStaff           ldd       <$42,s
                    addd      #$0001
                    std       <$42,s
* loop while staff <= nparts; FocusedPart is skipped on pass 0 and is the only staff of pass 1
StaffLoopTest       ldd       <$42,s
                    cmpd      <UmeData_nparts
                    bgt       BeamPassDone
                    ldd       <$42,s
                    cmpd      >FocusedPart
                    beq       BeamIsFocused
                    tst       >BeamFocusPass
                    beq       BeamPartAllowed
                    bra       NextStaff
BeamIsFocused       tst       >BeamFocusPass
                    beq       NextStaff
BeamPartAllowed     lbra      BeamStaffBody
BeamPassDone        tst       >BeamFocusPass
                    bne       BeamFocusDone
                    ldd       >FocusedPart
                    bmi       BeamFocusDone
                    inc       >BeamFocusPass
                    lbra      StaffLoopInit
BeamFocusDone       equ       *
                    leas      >$00EA,s
                    puls      u,pc

                    fcb       $34,$40,$8E,$01,$A6,$1F,$10,$35
                    fcb       $C0
* IsBarEvent(ev): 1 when staff byte 0 == 0 and subtype 5,ev <= 6, else 0
IsBarEvent          pshs      u
                    ldb       [<$04,s]
                    lbne      RetFalse
                    ldx       4,s
                    ldb       5,x
                    cmpb      #$06
                    lbgt      RetFalse
                    ldd       #$0001
                    lbra      RetResult
* command $B5 {x word, y1, y2, 1} (6 bytes at arg0): vertical stem extension line
DrawStemLine        pshs      u
                    ldd       #$00B5
                    stb       <UmeData_arg0
                    ldb       4,s
                    stb       <UmeData_arg1
                    ldd       4,s
                    stb       <UmeData_arg2
                    ldd       6,s
                    stb       <UmeData_arg3
                    ldd       8,s
                    stb       <UmeData_arg4
                    ldd       10,s
                    lbra      EmitCmd6
* command $D0 {x1 word, y1, x2 word, y2, thick} (8 bytes): the main beam
DrawBeam            pshs      u
                    ldd       #$00D0
                    stb       <UmeData_arg0
                    ldb       4,s
                    stb       <UmeData_arg1
                    ldd       4,s
                    stb       <UmeData_arg2
                    ldd       6,s
                    stb       <UmeData_arg3
                    ldb       8,s
                    stb       <UmeData_arg4
                    ldd       8,s
                    stb       <UmeData_arg5
                    ldd       10,s
                    stb       <UmeData_arg6
                    ldb       <UmeData_thick
                    stb       <UmeData_arg7
                    ldd       #$0008
                    bra       EmitGfxCmd
* command $D1 {offset} (2 bytes): another full-length beam offset from the previous one
DrawSubBeam         pshs      u
                    ldd       #$00D1
                    stb       <UmeData_arg0
                    ldd       4,s
                    stb       <UmeData_arg1
                    ldd       #$0002
                    bra       EmitGfxCmd
* command $D2 {offset, from-x word, to-x word} (6 bytes): partial beam / stub at a beam level
DrawPartBeam        pshs      u
                    ldd       #$00D2
                    stb       <UmeData_arg0
                    ldd       4,s
                    stb       <UmeData_arg1
                    ldb       6,s
                    stb       <UmeData_arg2
                    ldd       6,s
                    stb       <UmeData_arg3
                    ldb       8,s
                    stb       <UmeData_arg4
                    ldd       8,s
EmitCmd6            stb       <UmeData_arg5
                    ldd       #$0006
* push the length and call pnfwrite, which sends the command buffer at arg0
EmitGfxCmd          pshs      a,b
                    jsr       [>UmeData_pnfwrite]
                    leas      2,s
                    puls      u,pc
* SetupMeter: denominator <$05 = 2/4/8/16 -> dencodur 2..5 (else return 0), then beat ticks and compound setup
SetupMeter          pshs      u
                    ldx       <UmeData_reserved_0005
                    bra       MatchDenom
Denom2              ldd       #$0002
                    bra       SetBeatUnit
Denom4              ldd       #$0003
                    bra       SetBeatUnit
Denom8              ldd       #$0004
                    bra       SetBeatUnit
Denom16             ldd       #$0005
SetBeatUnit         std       <UmeData_dencodur
                    bra       CalcBeatTicks
* shared return 0 (IsBarEvent false, unknown denominator)
RetFalse            clra
                    clrb
* shared return with D already set
RetResult           puls      u,pc
MatchDenom          cmpx      #$0002
                    beq       Denom2
                    cmpx      #$0004
                    beq       Denom4
                    cmpx      #$0008
                    beq       Denom8
                    cmpx      #$0010
                    beq       Denom16
                    bra       RetFalse
* dendur = 192 / denominator (192 ticks per whole note); compound when dencodur >= 4, numerator >= 6 and numerator % 3 == 0
CalcBeatTicks       ldd       #$00C0
                    pshs      a,b
                    ldd       <UmeData_reserved_0005
                    lbsr      DivInt16
                    std       <UmeData_dendur
                    ldd       <UmeData_dencodur
                    cmpd      #$0004
                    blt       a8@
                    ldd       <UmeData_reserved_0003
                    cmpd      #$0006
                    blt       a8@
                    ldd       <UmeData_reserved_0003
                    pshs      a,b
                    ldd       #$0003
                    lbsr      ModInt16
                    bne       a8@
                    ldd       #$0001
                    bra       SetCompound
a8@                 clra
                    clrb
* tripper = compound flag; compound: zonedur = dendur * 3, nzones = numerator / 3
SetCompound         stb       <UmeData_tripper
                    ldb       <UmeData_tripper
                    beq       SimpleMeter
                    ldd       <UmeData_dendur
                    pshs      a,b
                    ldd       #$0003
                    lbsr      MulInt16
                    std       <UmeData_zonedur
                    ldd       <UmeData_reserved_0003
                    pshs      a,b
                    ldd       #$0003
                    lbsr      DivInt16
                    std       <UmeData_nzones
                    bra       MeterDone
* simple: nzones = numerator, zonedur = dendur
SimpleMeter         ldd       <UmeData_reserved_0003
                    std       <UmeData_nzones
                    ldd       <UmeData_dendur
                    std       <UmeData_zonedur
MeterDone           ldd       #$0001
                    puls      u,pc
                    fcb       $34,$40,$EC,$6E,$34,$06,$E6,$6F
                    fcb       $1D,$34,$06,$EC,$6E,$34,$06,$EC
                    fcb       $6E,$34,$06,$EC,$6E,$34,$06,$EC
                    fcb       $6E,$34,$06,$CC,$00,$C6,$34,$06
                    fcb       $DC,$14,$34,$06,$AD,$9F,$03,$5D
                    fcb       $32,$E8,$10,$35,$C0,$34,$40,$CC
                    fcb       $00,$C7,$34,$06,$DC,$16,$34,$06
                    fcb       $AD,$9F,$03
                    fcs       /]2d5@/
* StaffOptions(n, &attr, &flags): n outside 1..nparts becomes nparts; flags = word 2 of the 4-byte entry at $0C5F+n*4, attr = word 0 of the 10-byte record at $0C19 + (entry word 0)*10
StaffOptions        pshs      u
                    ldd       4,s
                    cmpd      #$0001
                    blt       a9@
                    ldd       4,s
                    cmpd      <UmeData_nparts
                    ble       LookupStaff
a9@                 ldd       <UmeData_nparts
                    std       4,s
LookupStaff         ldd       4,s
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
                    lbsr      MulInt16
                    ldx       #$0C19
                    leax      d,x
                    ldd       ,x
                    std       [<$06,s]
                    puls      u,pc
* SeekEvent(index): curind = index; page = index/928 + 1, mapped via ppswap unless it is curpage; returns curevp = database + (index mod 928)*8, or D = 0 when the map fails
SeekEvent           pshs      u
                    ldu       4,s
                    leas      -2,s
                    stu       <UmeData_curind
                    ldd       #$0001
                    bra       BlockDivLoop
BlockDivNext        ldd       ,s
                    addd      #$0001
* repeated subtraction of 928 events; stu -2,s only sets the flags for bge
BlockDivLoop        std       ,s
                    leau      >-$03A0,u
                    stu       -2,s
                    bge       BlockDivNext
                    leau      >$03A0,u
                    ldd       ,s
                    cmpd      <UmeData_curpage
                    beq       EventAddr
                    ldd       ,s
                    pshs      a,b
                    jsr       [>UmeData_ppswap]
                    leas      2,s
                    bne       EventAddr
                    clra
                    clrb
                    bra       SeekEventRet
* curevp = offset*8 + database
EventAddr           tfr       u,d
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    addd      <UmeData_database
                    std       <UmeData_curevp
SeekEventRet        leas      2,s
                    puls      u,pc
* NextEvent: curind++ (pointer unchanged at nevents), curevp += 8; past curptop maps page curpage+1 and points at database; returns curevp
NextEvent           pshs      u
                    ldd       <UmeData_curind
                    addd      #$0001
                    std       <UmeData_curind
                    cmpd      <UmeData_nevents
                    bge       RetEvtPtr
                    ldd       <UmeData_curevp
                    addd      #$0008
                    std       <UmeData_curevp
                    cmpd      <UmeData_curptop
                    bls       RetEvtPtr
                    ldd       <UmeData_curpage
                    addd      #$0001
                    pshs      a,b
                    jsr       [>UmeData_ppswap]
                    leas      2,s
                    ldd       <UmeData_database
                    bra       SetEvtPtr
* PrevEvent: curind-- (pointer unchanged below 0), curevp -= 8; below database maps page curpage-1 and points at its last slot curptop; returns curevp
PrevEvent           pshs      u
                    ldd       <UmeData_curind
                    addd      #$FFFF
                    std       <UmeData_curind
                    blt       RetEvtPtr
                    ldd       <UmeData_curevp
                    addd      #$FFF8
                    std       <UmeData_curevp
                    cmpd      <UmeData_database
                    bhs       RetEvtPtr
                    ldd       <UmeData_curpage
                    addd      #$FFFF
                    pshs      a,b
                    jsr       [>UmeData_ppswap]
                    leas      2,s
                    ldd       <UmeData_curptop
SetEvtPtr           std       <UmeData_curevp
RetEvtPtr           ldd       <UmeData_curevp
                    puls      u,pc
                    fcb       $30,$A9,$03,$43,$ED,$02,$1F,$89
                    fcb       $1D,$1F,$89,$ED,$84,$39
* C runtime: long accumulator at $0343,y = zero-extended D, X points at it
LongFromUInt        leax      >$0343,y
                    std       2,x
                    clr       ,x
                    clr       1,x
                    rts
* C runtime: copy the long at X to the stacked pointer argument, pop it; X = destination
StoreLong           pshs      y
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
* C runtime 16x16 multiply: D * stacked argument -> D (one mul when both high bytes are 0), argument popped
MulInt16            tsta
                    bne       Mul16Full
                    tst       2,s
                    bne       Mul16Full
                    lda       3,s
                    mul
                    ldx       ,s
                    stx       2,s
                    ldx       #$0000
                    std       ,s
                    puls      a,b,pc
* four partial products
Mul16Full           pshs      a,b
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
                    bhs       a10@
                    inc       ,s
a10@                lda       4,s
                    ldb       9,s
                    mul
                    addd      1,s
                    std       1,s
                    bhs       b10@
                    inc       ,s
b10@                lda       4,s
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
                    fcb       $6F,$A9,$0C,$CC,$30,$8D,$00,$40
                    fcb       $AF,$A9,$0C,$CD,$20,$14
* C runtime signed modulo via the vector $0CCD,y (= DivInt16) and the dividend sign at $0CCC,y; returns the remainder with the dividend's sign; x % 0 returns x
ModInt16            leax      >DivInt16,pcr
                    stx       >$0CCD,y
                    clr       >$0CCC,y
                    tst       2,s
                    bpl       a11@
                    inc       >$0CCC,y
a11@                subd      #$0000
                    bne       ModCallDiv
                    puls      x
                    ldd       ,s++
                    jmp       ,x
ModCallDiv          ldx       2,s
                    pshs      x
                    jsr       [>$0CCD,y]
                    ldd       ,s
                    std       2,s
                    tfr       x,d
                    tst       >$0CCC,y
                    beq       a12@
                    nega
                    negb
                    sbca      #$00
a12@                std       ,s++
                    rts
* C runtime unsigned divide: stacked dividend / D -> quotient D, remainder X; zero divisor traps
DivUInt16           subd      #$0000
                    beq       DivZeroTrap
                    pshs      a,b
                    leas      -2,s
                    clr       ,s
                    clr       1,s
                    bra       DivCoreEntry
* division by zero: code $2D to SendSelfSignal
DivZeroTrap         puls      a,b
                    std       ,s
                    ldd       #$002D
                    lbra      SendSelfSignal
* C runtime signed divide: stacked dividend / D -> quotient D, remainder X; sign flag at 1,s; zero divisor traps
DivInt16            subd      #$0000
                    beq       DivZeroTrap
                    pshs      a,b
                    leas      -2,s
                    clr       ,s
                    clr       1,s
                    tsta
                    bpl       NegDividend
                    nega
                    negb
                    sbca      #$00
                    com       1,s
                    std       2,s
* negate a negative dividend and toggle the sign flag
NegDividend         ldd       6,s
                    bpl       DivCoreEntry
                    nega
                    negb
                    sbca      #$00
                    com       1,s
                    std       6,s
* divide core, A = shift count
DivCoreEntry        lda       #$01
* normalize the divisor (shift left until bit 15 is set)
NormDivisor         inca
                    asl       3,s
                    rol       2,s
                    bpl       NormDivisor
                    sta       ,s
                    ldd       6,s
                    clr       6,s
                    clr       7,s
* restoring division step
DivLoop             subd      2,s
                    bhs       a13@
                    addd      2,s
                    andcc     #$FE
                    bra       DivShift
a13@                orcc      #$01
DivShift            rol       7,s
                    rol       6,s
                    lsr       2,s
                    ror       3,s
                    dec       ,s
                    bne       DivLoop
                    std       2,s
                    tst       1,s
                    beq       DivResult
                    ldd       6,s
                    nega
                    negb
                    sbca      #$00
                    std       6,s
* quotient to D, remainder to X, arguments removed
DivResult           ldx       4,s
                    ldd       6,s
                    std       4,s
                    stx       6,s
                    ldx       2,s
                    ldd       4,s
                    leas      6,s
                    rts
* store the code at $034F,y and send signal B to the own process (F$ID, F$Send)
SendSelfSignal      std       >$034F,y
                    pshs      b,y
                    os9       F$ID
                    puls      b,y
                    os9       F$Send
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
                    fcc       /s9b/
                    fcb       $00

                    fill      0,$1D00-*           >= $1D00 bytes, so F$Link never puts this overlay in slot 7 (the score page's slot)
                    emod
eom                 equ       *
                    end
