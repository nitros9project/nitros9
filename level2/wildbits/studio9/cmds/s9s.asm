********************************************************************
* s9s - Studio-9 score DISPLAY / PRINT overlay, disassembled from the UltiMusE III v10.11.4e
* (OS-9 Level 2) display overlay and ported. Routine names are evidence-based readings of the
* original; "[reading uncertain]" marks one the evidence did not settle. Local labels read
* a<n>@, b<n>@ ...: the letter is the label, n the routine it belongs to.
* Event pages hold 928 events ($03A0), not the original 1020 ($03FC), so a page fits the
* $1D00 visible bytes of DAT slot 7 (see GPBLKS in s9.asm); SeekEvent carries the constant.
* The screen and print loops place events and draw rests first, then draw the notes at the
* saved columns through the same NoteEvent/CallDrawNote code: all rests precede all notes,
* including parts that share a staff. The screen layout is measured without output first
* (LayoutOnly), so the left-edge key signature is known before painting. Draw order: clear,
* staves/clefs, left key, rests/marks, notes, beams, focused-part notes, flush.
*
* OverlayMain takes one int argument whose low byte selects the job (screen draw, focused
* notes, draw without cls, print). The overlay has no C runtime of its own: it shares s9's
* data area and calls s9's library through the vector table (UmeData_p* in equates.asm).
* All drawing is a byte protocol written to stdout for s9gui: a command byte >= $80 with a
* fixed number of argument bytes: $9E staves, $A3 key signature, $A4 time signature, $A7
* score marks (tempo/dynamic/clock/end/ending/accent by subtype), $A8 bar line + bar number,
* $AA hairpin or rit/accel, $B2 two-char label, $A2/$A5/$A6/$AB partwise marks (MIDI
* channel/volume/instrument/raw event) at a part's staff, $BC erase rows, $BD system brace,
* $BE squeeze vertically, $BF printer job ('b' begin, 'd' dump page, 'e' end), $C6/$C7
* open/close text box, $CC text cursor.
* Event records are 8 bytes in 928-record pages: [0] part (0 = non-note), [1-2] time, [3] note
* value, [4] dots, [5] type (notes: staff step, $20 = rest; others: 1-6 bar-line kinds with the
* bar number in [3-4], 7 label, $0A time sig, $0B key sig, $16-$22 marks, > $22 hidden), [6-7]
* parameters. SeekEvent/NextEvent/PrevEvent keep curind, curevp, the page bounds
* database/curptop and curpage.
* DrawScreen clamps the cursor event gind to column xgoal (6..77), finds the previous bar line,
* takes the shortest note in the bar (MinDurInBar) as the spacing unit, clears rows and draws
* staves, then places events in two passes (forward from the cursor, then backward) storing x
* in grafxes ($0425) and y in grafyes ($05C2) and issuing s9gui commands or s9's DrawNote; the
* key signature at the left edge comes from FindKeySig, the beam pass from overlay s9b 'b'
* when beam is set.
* PrintScore asks three prompts, warns that 'Q' aborts, opens a status box, prints the title and
* nine header lines, then per system: PrintLine renders a trial line, FitBarsOnLine decides how
* many bars fit (time-signature dependent), GapThreshold spreads the leftover columns over the
* largest time gaps, PrintLine renders the final line, a closing/final bar is drawn, and the
* page is dumped to the printer or previewed ("Line %d. Keep on previewing?"). Library helpers
* at the end: MulInt, DivInt (divide-by-zero signals itself via F$ID/F$Send), ShiftRightN/
* ShiftLeftN. Unlabeled fcb/fcc runs are bytes kept from the original with no known use.
*
* header: type/lang $11 attr/rev $81, data size $104C (4172)

                    nam       s9s
                    ttl       s9s (disassembly)

                  IFP1
                    use       defsfile
                  ENDC

tylg                set       $11
atrv                set       $81
UME_SCOPE_S9S                  equ       1
                    use       equates.asm
size                equ       $104C

                    mod       eom,name,tylg,atrv,start,size
name                fcs       /s9s/
                    fcb       $07
start               equ       *
                    lbra      OverlayMain
                    fcb       $39,$0D,$00
* OverlayMain: low byte of the first int argument selects the job: SJobRedraw ('s') DrawScreen,
* 'f' DrawFocusedNotes, SJobRedrawKeep ('n') DrawScreenKeep (the same draw without the cls),
* 'p' PrintScore.
OverlayMain         pshs      u
                    ldb       5,s
                    cmpb      #SJobRedraw
                    bne       a1@
                    bsr       DrawScreen
                    bra       b1@
a1@                 ldb       5,s
                    cmpb      #'f
                    bne       NotFocusedJob
                    lbsr      DrawFocusedNotes
                    bra       b1@
NotFocusedJob       ldb       5,s
                    cmpb      #SJobRedrawKeep
                    bne       NotKeepJob
* The 'n' job lays out with the last full draw's anchor (KeepGind/KeepXgoal), not the click's
* gind/xgoal, so the layout is the one on the screen; the click's values are restored afterwards.
                    ldd       <UmeData_gind
                    pshs      d
                    ldd       <UmeData_xgoal
                    pshs      d
                    ldd       >KeepGind
                    std       <UmeData_gind
                    ldd       >KeepXgoal
                    std       <UmeData_xgoal
                    lbsr      DrawScreenKeep
                    puls      d
                    std       <UmeData_xgoal
                    puls      d
                    std       <UmeData_gind
                    bra       b1@
NotKeepJob          ldb       5,s
                    cmpb      #$70
                    bne       b1@
                    lbsr      PrintScore
b1@                 puls      u,pc
* DrawScreen: 's' job: redraws the score window around cursor event gind at column xgoal
* (clamped 6..77). The cls (show.c's wkill() + yclear()) comes first, so the 'n' job can join
* at DrawScreenKept with the sheet as it is. A silent layout round (LayoutOnly drops every
* drawing command) settles the anchor, then the draw repeats visibly: previous bar line,
* spacing unit from MinDurInBar, staves, left key signature, two placement passes, notes.
DrawScreen          pshs      u
                    leas      <-$2F,s
                    clr       >FocusOnly
                    clr       >RenderNotes
                    clr       >LayoutOnly         the two commands below must go out
                    lbsr      CloseTextBox        s9gui $C7: whatever a text box covered is put back
                    clra
                    clrb
                    pshs      a,b
                    ldd       #SheetRowTop
                    pshs      a,b
                    ldd       #SheetRowBottom
                    pshs      a,b
                    lbsr      ClearRows           the sheet's cls: s9gui $BC clears rows 8..184, full width
                    leas      6,s
* DrawScreenKept: the 'n' job joins here (DrawScreenKeep set the frame up) - the same draw, no cls.
DrawScreenKept      lda       #1
                    sta       >LayoutOnly
                    ldd       <UmeData_gind
                    bge       a2@
                    clra
                    clrb
                    bra       b2@
a2@                 ldd       <UmeData_gind
                    cmpd      <UmeData_nevents
                    blt       ClampCursorCol
                    ldd       <UmeData_nevents
                    addd      #$FFFF
b2@                 std       <UmeData_gind
                    bra       ClampCursorCol
* RestartDraw: re-entry with 'leas <-$2F,x' (compiler goto): restarts from the column clamp after the leftmost event reached index 0 with room to spare (xgoal = gind = 0 set at NextPass)
RestartDraw         leas      <-$2F,x
* ClampCursorCol: clamps xgoal to 6..77 ($4D); at either limit snaps gind to its same-time group edge with SameTimeEdge(gind, xgoal > 40); seeks gind, 4,s = its time
ClampCursorCol      ldd       #$0006
                    std       <$2B,s
                    ldd       <UmeData_xgoal
                    cmpd      <$2B,s
                    bge       a3@
                    ldd       <$2B,s
                    bra       b3@
a3@                 ldd       <UmeData_xgoal
                    cmpd      #$004D
                    ble       c3@
                    ldd       #$004D
b3@                 std       <UmeData_xgoal
c3@                 ldd       <UmeData_xgoal
                    cmpd      <$2B,s
                    ble       d3@
                    ldd       <UmeData_xgoal
                    cmpd      #$004D
                    blt       g3@
d3@                 ldd       <UmeData_xgoal
                    cmpd      #$0028
                    ble       e3@
                    ldd       #$0001
                    bra       f3@
e3@                 clra
                    clrb
f3@                 pshs      a,b
                    ldd       <UmeData_gind
                    pshs      a,b
                    lbsr      SameTimeEdge
                    leas      4,s
                    std       <UmeData_gind
g3@                 ldd       <UmeData_gind
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    tfr       d,u
                    ldd       1,u
                    std       4,s
                    bra       PrevBarCheck
* PrevBarLoop: walks back from the cursor event with PrevEvent until IsBarLine or index < 0
PrevBarLoop         pshs      u
                    lbsr      IsBarLine
                    std       ,s++
                    bne       FoundPrevBar
                    lbsr      PrevEvent
                    tfr       d,u
* PrevBarCheck: loop test of PrevBarLoop; loops while curind >= 0
PrevBarCheck        ldd       <UmeData_curind
                    bge       PrevBarLoop
* FoundPrevBar: gbarind = its index, gbar = its bar number (bytes 3-4), spacing unit <$13,s = MinDurInBar(gbarind+1), base index xyoff = gind - (xgoal-5)*16/3; staves unless in the layout round
FoundPrevBar        ldd       <UmeData_curind
                    std       <UmeData_gbarind
                    ldd       3,u
                    std       <UmeData_gbar
                    clra
                    clrb
                    pshs      a,b
                    ldd       <UmeData_gbarind
                    addd      #$0001
                    pshs      a,b
                    lbsr      MinDurInBar
                    leas      4,s
                    std       <$13,s
                    ldd       <$2B,s
                    addd      #$FFFF
                    pshs      a,b
                    ldd       <UmeData_xgoal
                    subd      ,s++
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    pshs      a,b
                    ldd       #$0003
                    lbsr      DivInt
                    pshs      a,b
                    ldd       <UmeData_gind
                    subd      ,s++
                    std       <UmeData_xyoff
                    tst       >LayoutOnly
                    bne       BeginScreenPasses
                    ldd       <UmeData_gind
                    bne       a4@
                    ldd       #$0001
                    bra       b4@
a4@                 clra
                    clrb
b4@                 pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    lbsr      DrawStaves
                    leas      4,s
* LeftKeySig: FindKeySig(lftind) and DrawKeySig at the left edge, before the score events
LeftKeySig          ldd       <UmeData_lftind
                    pshs      a,b
                    lbsr      FindKeySig
                    leas      2,s
                    std       <$23,s
                    beq       BeginScreenPasses
                    ldd       <$23,s
                    pshs      a,b
                    ldd       <UmeData_gind
                    bne       a18@
                    ldd       #$0001
                    bra       b18@
a18@                clra
                    clrb
b18@                addd      #$0003
                    pshs      a,b
                    lbsr      DrawKeySig
                    leas      4,s
BeginScreenPasses   clra
                    clrb
                    std       <$11,s
                    lbra      NextPass
* PassBegin: head of the two placement passes (<$11,s = 0 forward from the cursor, 1 backward from cursor-1); x = xgoal, seeks the pass start event
PassBegin           ldd       <UmeData_xgoal
                    std       8,s
                    ldd       4,s
                    std       ,s
                    ldd       <UmeData_gind
                    subd      <$11,s
                    std       <$23,s
                    cmpd      <UmeData_gbarind
                    blt       a5@
                    ldd       <UmeData_gbar
                    std       <$29,s
                    ldd       <$13,s
                    bra       b5@
a5@                 ldd       <UmeData_gbar
                    addd      #$FFFF
                    std       <$29,s
                    clra
                    clrb
b5@                 std       <$15,s
                    clra
                    clrb
                    std       <$1D,s
                    std       <$1B,s
                    ldd       <$23,s
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    tfr       d,u
                    lbra      DrawLoopCheck
* DrawEventLoop: per-event loop head (U = current event): the note walk draws saved notes; placement recomputes the spacing unit at a bar line, converts the time delta to columns and dispatches on the event kind
DrawEventLoop       ldb       ,u
                    sex
                    std       <$1F,s
                    tst       >RenderNotes
                    beq       ScreenPlaceEvent
                    tstb
                    lbeq      DrawStepEvent        non-note marks were drawn during placement
                    tst       >FocusOnly
                    beq       FocusPartAllowed
                    ldd       <$1F,s
                    cmpd      >FocusedPart
                    beq       FocusPartAllowed
                    cmpd      >PaintedFocus
                    lbne      DrawStepEvent
FocusPartAllowed    equ       *
                    ldd       <$1F,s
                    cmpd      >FocusedPart
                    beq       IsFocusedScreenNote
                    lda       >RenderNotes
                    cmpa      #2
                    lbeq      DrawStepEvent
                    bra       ScreenFocusAllowed
IsFocusedScreenNote lda       >RenderNotes
                    cmpa      #2
                    lbne      DrawStepEvent
ScreenFocusAllowed  equ       *
                    ldb       5,u
                    cmpb      #$20
                    lbeq      DrawStepEvent        every rest is already down
                    sex
                    std       <$21,s
                    ldd       <UmeData_curind
                    subd      <UmeData_xyoff
                    ldx       #$0425
                    ldb       d,x
                    clra
                    std       8,s
                    lbra      NoteEvent           reuse the existing note renderer, with the saved x
ScreenPlaceEvent    equ       *
                    ldd       <$15,s
                    bne       a6@
                    ldd       <UmeData_curind
                    std       <$23,s
                    ldd       <$11,s
                    pshs      a,b
                    ldd       <UmeData_curind
                    pshs      a,b
                    lbsr      MinDurInBar
                    leas      4,s
                    std       <$15,s
                    ldd       <$23,s
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    tfr       d,u
* a6@: 12,s = time - previous time, 10,s = the same negated on the backward pass; zero delta = chord, no x advance
a6@                 ldd       1,u
                    std       2,s
                    subd      ,s
                    std       12,s
                    lbeq      GotEventType
                    ldd       2,s
                    std       ,s
                    ldd       <$11,s
                    beq       b6@
                    ldd       12,s
                    nega
                    negb
                    sbca      #$00
                    bra       c6@
b6@                 ldd       12,s
c6@                 std       10,s
                    cmpd      <$15,s
                    blt       AdvanceByTime
                    ldb       <UmeData_compact
                    bne       FixedColAdvance
* AdvanceByTime: advance <$27,s = MulInt(delta, 24) / unit, rounded to a multiple of 8, at least +-8; x += advance/8
AdvanceByTime       ldd       12,s
                    pshs      a,b
                    ldd       #$0018
                    lbsr      MulInt
                    pshs      a,b
                    ldd       <$17,s
                    lbsr      DivInt
                    std       <$27,s
                    bge       a7@
                    ldd       <$27,s
                    addd      #$FFFC
                    andb      #$F8
                    std       <$27,s
                    cmpd      #$FFF8
                    ble       c7@
                    ldd       #$FFF8
                    bra       b7@
a7@                 ldd       <$27,s
                    addd      #$0004
                    andb      #$F8
                    std       <$27,s
                    cmpd      #$0008
                    bge       c7@
                    ldd       #$0008
b7@                 std       <$27,s
c7@                 ldd       8,s
                    pshs      a,b
                    ldd       <$29,s
                    pshs      a,b
                    ldd       #$0008
                    lbsr      DivInt
                    bra       e7@
* FixedColAdvance: taken when compact is set and delta >= unit: x moves a fixed +3 (-3 backward); x outside 6..77 ends the pass
FixedColAdvance     ldd       8,s
                    pshs      a,b
                    ldd       <$13,s
                    beq       d7@
                    ldd       #$FFFD
                    bra       e7@
d7@                 ldd       #$0003
e7@                 addd      ,s++
                    std       8,s
                    ldd       8,s
                    cmpd      <$2B,s
                    blt       f7@
                    ldd       8,s
                    cmpd      #$004D
                    ble       GotEventType
f7@                 lbra      PassEnd
* GotEventType: <$21,s = event type (byte 5); when the previous event was a partwise mark (<$1D,s, part byte <$1B,s 0) and this one is a note or another type, x steps by that mark's width 15,s (back on the backward pass)
GotEventType        ldb       5,u
                    sex
                    std       <$21,s
                    ldd       <$1B,s
                    bne       DispatchByKind
                    ldd       <$1D,s
                    pshs      a,b
                    lbsr      IsPartMarkType
                    leas      2,s
                    beq       DispatchByKind
                    ldd       <$1F,s
                    bne       a8@
                    ldd       <$21,s
                    cmpd      <$1D,s
                    beq       DispatchByKind
a8@                 ldd       8,s
                    pshs      a,b
                    ldd       <$13,s
                    beq       b8@
                    ldd       <$11,s
                    nega
                    negb
                    sbca      #$00
                    bra       c8@
b8@                 ldd       <$11,s
c8@                 addd      ,s++
                    std       8,s
* DispatchByKind: part byte != 0 -> NoteEvent; type > $22 -> hidden event (grafxes 0, grafyes $FF), step on; else NonNoteEvent
DispatchByKind      ldd       <$1F,s
                    lbne      NoteEvent
                    ldd       <$21,s
                    cmpd      #$0022
                    ble       NonNoteEvent
                    ldd       <UmeData_curind
                    subd      <UmeData_xyoff
                    ldx       #$0425
                    leax      d,x
                    clra
                    clrb
                    stb       ,x
                    ldd       <UmeData_curind
                    subd      <UmeData_xyoff
                    ldx       #$05C2
                    leax      d,x
                    ldd       #$00FF
                    stb       ,x
                    lbra      DrawStepEvent
* NonNoteEvent: width 15,s from the per-type table at data $011A; the backward pass subtracts it from x first and ends when x leaves the window
NonNoteEvent        ldd       <$21,s
                    ldx       #$011A
                    leax      d,x
                    ldb       ,x
                    sex
                    std       15,s
* The markers of one time ($16/$17, width 0) share a column; the first non-marker after them
* at the same time (delta 0) steps x on by 3 columns first. Backward pass: the first marker met
* after a same-time non-marker steps x back by 3. A marker has part byte 0 and type $16/$17.
                    ldd       12,s                the time delta to the previous event
                    bne       nne9@
                    ldd       <$11,s
                    bne       nneb@               the backward pass
                    ldd       <$21,s              forward: this event must not be a marker
                    cmpd      #$0016
                    blt       nne2@
                    cmpd      #$0017
                    ble       nne9@
nne2@               lbsr      PrevWasMark
                    bne       nne9@
                    ldd       8,s
                    addd      #$0003
                    std       8,s
                    bra       nne9@
nneb@               ldd       <$21,s              backward: this event must be a marker, the previous not
                    cmpd      #$0016
                    blt       nne9@
                    cmpd      #$0017
                    bgt       nne9@
                    lbsr      PrevWasMark
                    beq       nne9@
                    ldd       8,s
                    subd      #$0003
                    std       8,s
nne9@
                    clra
                    clrb
                    std       6,s
                    ldd       <$11,s
                    beq       BarLineEvent
                    ldd       8,s
                    subd      15,s
                    std       8,s
                    cmpd      <$2B,s
                    bge       BarLineEvent
                    lbra      PassEnd
* BarLineEvent: stores x; types 1-6 are bar-line kinds: DrawBarLine(x, kind, bar number bytes 3-4); kind 5 (ending, number in byte 6) is sent as kind 0 for ending 1, else 1, plus DrawBarLine(x, 5, ending number)
BarLineEvent        ldd       <UmeData_curind
                    subd      <UmeData_xyoff
                    ldx       #$0425
                    leax      d,x
                    ldd       8,s
                    stb       ,x
                    ldd       <$21,s
                    cmpd      #$0006
                    lbgt      TypeKeySig
                    ldd       3,u
                    std       <$29,s
                    clra
                    clrb
                    std       <$17,s
                    ldd       <$21,s
                    cmpd      #$0005
                    bne       c9@
                    ldb       6,u
                    sex
                    std       <$17,s
                    cmpd      #$0001
                    bne       a9@
                    clra
                    clrb
                    bra       b9@
a9@                 ldd       #$0001
b9@                 std       <$21,s
c9@                 ldd       <$29,s
                    pshs      a,b
                    ldd       <$23,s
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    lbsr      DrawBarLine
                    leas      6,s
                    ldd       <$17,s
                    beq       e9@
                    ldd       <$17,s
                    pshs      a,b
                    ldd       #$0005
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    lbsr      DrawBarLine
                    leas      6,s
                    bra       e9@
* d9@: unreferenced: x and width 0 at index 0
d9@                 ldd       <UmeData_curind
                    subd      <UmeData_xyoff
                    ldx       #$0425
                    leax      d,x
                    clra
                    clrb
                    stb       ,x
                    clra
                    clrb
                    std       15,s
e9@                 clra
                    clrb
                    std       <$15,s
                    ldd       <$29,s
                    subd      <$11,s
                    std       <$29,s
                    lbra      StoreEventY
* TypeKeySig: type $0B = key signature: DrawKeySig(x, byte 6 = sharps(+)/flats(-))
TypeKeySig          ldd       <$21,s
                    cmpd      #$000B
                    bne       TypeTempo
                    ldb       6,u
                    sex
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    lbsr      DrawKeySig
* StoreEventYPop4: drops the 4 pushed args, joins StoreEventY; TypeKeySig falls in, TypeLabel branches here
StoreEventYPop4     leas      4,s
                    lbra      StoreEventY
* TypeTempo: type $19 = tempo: DrawScoreMark($19, x, byte 3 = bpm)
TypeTempo           ldd       <$21,s
                    cmpd      #$0019
                    bne       TypeDynamic
                    ldb       3,u
                    sex
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    ldd       #$0019
* CallScoreMark: shared tail of the $19/$1A/$1B/$1F/$21/$22 cases: push subtype, DrawScoreMark, drop 6 bytes
CallScoreMark       pshs      a,b
                    lbsr      DrawScoreMark
                    lbra      StoreEventYPop6
* TypeDynamic: type $1A = dynamic mark (level in byte 7): DrawScoreMark($1A, x-1, byte 7)
TypeDynamic         ldd       <$21,s
                    cmpd      #$001A
                    bne       TypeClock
                    ldb       7,u
                    sex
                    pshs      a,b
                    ldd       10,s
                    addd      #$FFFF
                    pshs      a,b
                    ldd       #$001A
                    bra       CallScoreMark
* TypeClock: type $1B = MIDI clock on/off: DrawScoreMark($1B, x, byte 7); s9gui draws 'C+'/'C-'
TypeClock           ldd       <$21,s
                    cmpd      #$001B
                    bne       TypeRamp
                    ldb       7,u
                    sex
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    ldd       #$001B
                    lbra      CallScoreMark
* TypeRamp: types $1C (cresc/decresc) and $1D (rit/accel): DrawRampMark(x, byte 7, byte 6, byte 3)
TypeRamp            ldd       <$21,s
                    cmpd      #$001C
                    beq       a10@
                    ldd       <$21,s
                    cmpd      #$001D
                    bne       TypeLabel
a10@                ldb       3,u
                    sex
                    pshs      a,b
                    ldb       6,u
                    sex
                    pshs      a,b
                    ldb       7,u
                    sex
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    lbsr      DrawRampMark
                    leas      8,s
                    lbra      StoreEventY
* TypeLabel: type 7 = two-character label: DrawLabel(x, event) sends bytes 3 and 6 as text
TypeLabel           ldd       <$21,s
                    cmpd      #$0007
                    bne       TypeAccent
                    pshs      u
                    ldd       10,s
                    pshs      a,b
                    lbsr      DrawLabel
                    lbra      StoreEventYPop4
* TypeAccent: type $22 = accent/tenuto: DrawScoreMark($22, x, byte 7); s9gui draws '^' or '-'
TypeAccent          ldd       <$21,s
                    cmpd      #$0022
                    bne       TypeTimeSig
                    ldb       7,u
                    sex
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    ldd       #$0022
                    lbra      CallScoreMark
* TypeTimeSig: type $0A = time signature: DrawTimeSig(x, byte 6 = beats, byte 7 = unit)
TypeTimeSig         ldd       <$21,s
                    cmpd      #$000A
                    bne       a11@
                    ldb       7,u
                    sex
                    pshs      a,b
                    ldb       6,u
                    sex
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    lbsr      DrawTimeSig
                    lbra      StoreEventYPop6
* a11@: type $1F: DrawScoreMark($1F, x, -1) -> s9gui prints 'E' without a number (end/fine style mark)  [reading uncertain]
a11@                ldd       <$21,s
                    cmpd      #$001F
                    bne       TypeEnding
                    ldd       #$FFFF
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    ldd       #$001F
                    lbra      CallScoreMark
* TypeEnding: type $21 = numbered ending: DrawScoreMark($21, x, byte 7 = ending number) -> s9gui prints 'E n'
TypeEnding          ldd       <$21,s
                    cmpd      #$0021
                    bne       TypePartMark
                    ldb       7,u
                    sex
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    ldd       #$0021
                    lbra      CallScoreMark
* TypePartMark: IsPartMarkType: $16 MIDI channel -> $A2, $17 instrument -> $A6, $18 volume -> $A5, $1E/$20 raw event -> $AB; DrawPartMark(cmd, x, byte 6 = part, byte 7 or -1 for $1E)
TypePartMark        ldd       <$21,s
                    pshs      a,b
                    lbsr      IsPartMarkType
                    std       ,s++
                    lbeq      TypeOther
                    ldd       <$21,s
                    cmpd      #$001E
                    bne       a12@
                    ldd       #$FFFF
                    bra       b12@
a12@                ldb       7,u
                    sex
b12@                pshs      a,b
                    ldb       6,u
                    sex
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    ldd       <$27,s
                    cmpd      #$0017
                    bne       c12@
                    ldd       #$00A6
                    bra       CallPartMark
c12@                ldd       <$27,s
                    cmpd      #$0018
                    bne       d12@
                    ldd       #$00A5
                    bra       CallPartMark
d12@                ldd       <$27,s
                    cmpd      #$0016
                    bne       e12@
                    ldd       #$00A2
                    bra       CallPartMark
e12@                ldd       #$00AB
* CallPartMark: shared tail: DrawPartMark, y to 6,s; x -= width on the forward pass, += width on the backward pass, cancelling the generic width step
CallPartMark        pshs      a,b
                    lbsr      DrawPartMark
                    leas      8,s
                    std       6,s
                    ldd       8,s
                    pshs      a,b
                    ldd       <$13,s
                    beq       a13@
                    ldd       <$11,s
                    bra       b13@
a13@                ldd       <$11,s
                    nega
                    negb
                    sbca      #$00
b13@                addd      ,s++
                    std       8,s
                    bra       StoreEventY
* TypeOther: remaining types: DrawBarLine(x, type, 0) lets s9gui's $A8 handler draw them
TypeOther           clra
                    clrb
                    pshs      a,b
                    ldd       <$23,s
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    lbsr      DrawBarLine
* StoreEventYPop6: drops 6 args and falls into StoreEventY
StoreEventYPop6     leas      6,s
* StoreEventY: grafyes[curind-xyoff] = 6,s; on the forward pass (not at index 0) x += width 15,s
StoreEventY         ldd       <UmeData_curind
                    subd      <UmeData_xyoff
                    ldx       #$05C2
                    leax      d,x
                    ldd       6,s
                    stb       ,x
                    ldd       <$11,s
                    lbne      SavePrevType
                    ldd       <UmeData_curind
                    lbeq      SavePrevType
                    ldd       8,s
                    addd      15,s
                    std       8,s
                    lbra      SavePrevType
* NoteEvent: note (part byte != 0): PartStaff(part, &staffY, &flags); a rest ($20) goes to RestEvent; else y = staffY + 2*byte 5 (staff step); 14,s = stem flag (flags bit 0: 0, bit 1: 1, else step > 4) when x > 20
NoteEvent           ldd       12,s                a note right after a same-time marker group sits 3 columns on
                    bne       nev1@
                    ldd       <$11,s
                    bne       nev1@
                    lbsr      PrevWasMark
                    bne       nev1@
                    ldd       8,s
                    addd      #$0003
                    std       8,s
nev1@               leax      <$19,s
                    pshs      x
                    leax      <$2F,s
                    pshs      x
                    ldd       <$23,s
                    pshs      a,b
                    lbsr      PartStaff
                    leas      6,s
                    ldd       <$2D,s
                    std       6,s
                    ldd       <$21,s
                    cmpd      #$0020
                    beq       RestEvent
                    ldd       6,s
                    pshs      a,b
                    ldd       <$23,s
                    addd      <$23,s
                    addd      ,s++
                    std       6,s
                    ldd       <$19,s
                    clra
                    andb      #$01
                    bne       c14@
                    ldd       <$19,s
                    clra
                    andb      #$02
                    beq       b14@
a14@                ldd       #$0001
                    bra       d14@
b14@                ldd       <$21,s
                    cmpd      #$0004
                    bgt       a14@
c14@                clra
                    clrb
d14@                stb       14,s
                    sex
                    pshs      a,b
                    ldd       8,s
                    cmpd      #$0014
                    ble       e14@
                    ldd       #$0001
                    bra       f14@
e14@                clra
                    clrb
f14@                anda      ,s+
                    andb      ,s+
                    stb       14,s
                    bra       StoreNotePos
* RestEvent: rest (byte 5 = $20): y = staffY + 8, +8 / -8 by part flag bits 0/1
RestEvent           ldd       6,s
                    pshs      a,b
                    ldd       <$1B,s
                    clra
                    andb      #$01
                    beq       a15@
                    ldd       #$0008
                    bra       c15@
a15@                ldd       <$1B,s
                    clra
                    andb      #$02
                    beq       b15@
                    ldd       #$FFF8
                    bra       c15@
b15@                clra
                    clrb
c15@                addd      #$0008
                    addd      ,s++
                    std       6,s
* StoreNotePos: stores x/y; placement draws only rests (notes wait for the note walk); with beam set (not FocusOnly) only rests and parts with flag bit 2 are drawn here
StoreNotePos        ldd       <UmeData_curind
                    subd      <UmeData_xyoff
                    ldx       #$0425
                    leax      d,x
                    ldd       8,s
                    stb       ,x
                    ldd       <UmeData_curind
                    subd      <UmeData_xyoff
                    ldx       #$05C2
                    leax      d,x
                    ldd       6,s
                    stb       ,x
                    tst       >RenderNotes
                    bne       ScreenNoteFilter
                    ldb       5,u
                    cmpb      #$20
                    bne       SavePrevType        defer notes until BOTH placement directions finish
ScreenNoteFilter    equ       *
                    tst       >FocusOnly
                    bne       CallDrawNote
                    ldb       <UmeData_beam
                    beq       CallDrawNote
                    ldd       <$21,s
                    cmpd      #$0020
                    beq       CallDrawNote
                    ldd       <$19,s
                    clra
                    andb      #$04
                    beq       SavePrevType
* CallDrawNote: s9's DrawNote vector pdrawnr(event+3, x, y, staffY, stem flag, flags&4, 1) draws head/stem/flags; nothing in the layout round
CallDrawNote        tst       >LayoutOnly
                    lbne      SavePrevType
                    ldd       #$0001
                    pshs      a,b
                    ldd       <$1B,s
                    clra
                    andb      #$04
                    tst       >FocusOnly
                    beq       FocusBeamFlagsReady
                    tst       <UmeData_beam
                    beq       FocusBeamFlagsReady
                    ldd       #4                  retain existing beams; repaint only the note glyph
FocusBeamFlagsReady equ       *
                    pshs      a,b
                    ldb       <$12,s
                    sex
                    pshs      a,b
                    ldd       <$33,s
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    ldd       <$12,s
                    pshs      a,b
                    pshs      u
                    ldd       #$0003
                    addd      ,s++
                    pshs      a,b
                    jsr       [>UmeData_pdrawnr]
                    leas      14,s
* SavePrevType: remembers part byte/type of this event (<$1B,s/<$1D,s) for the next iteration
SavePrevType        ldd       <$1F,s
                    std       <$1B,s
                    ldd       <$21,s
                    std       <$1D,s
* DrawStepEvent: NextEvent, or PrevEvent on the backward placement pass, then DrawLoopCheck; DispatchByKind branches here for hidden types
DrawStepEvent       tst       >RenderNotes
                    bne       a16@                note drawing always walks forward
                    ldd       <$11,s
                    beq       a16@
                    lbsr      PrevEvent
                    bra       b16@
a16@                lbsr      NextEvent
b16@                tfr       d,u
* DrawLoopCheck: placement loops while the index is in 0..nevents-1 and x <= 77; the note walk runs to ritind, then the focused-part walk or the finish
DrawLoopCheck       ldd       <UmeData_curind
                    tst       >RenderNotes
                    beq       ScreenPlaceCheck
                    cmpd      <UmeData_ritind
                    lble      DrawEventLoop
                    lda       >RenderNotes
                    cmpa      #1
                    bne       ScreenNotesFinished
                    tst       >FocusOnly
                    bne       FocusSecondPass
                    tst       <UmeData_beam
                    bne       ScreenNotesFinished  beaming runs before the focused notes
FocusSecondPass     equ       *
                    ldd       >FocusedPart
                    bmi       ScreenNotesFinished
                    inc       >RenderNotes
                    lbra      ScreenNotesSeek
ScreenNotesFinished equ       *
                    ldd       <UmeData_lftind
                    pshs      a,b
                    lbsr      SeekEvent           leave the iterator as the placement passes did
                    leas      2,s
                    tfr       d,u
                    lda       >RenderNotes
                    clr       >RenderNotes
                    cmpa      #2
                    lbeq      ScreenFlush
                    lbra      AfterPasses
ScreenPlaceCheck    equ       *
                    tsta
                    blt       PassEnd
                    ldd       <UmeData_curind
                    cmpd      <UmeData_nevents
                    bge       PassEnd
                    ldd       8,s
                    cmpd      #$004D
                    lble      DrawEventLoop
* PassEnd: end of a pass: the forward pass records ritind = rightmost placed index, the backward pass lftind = leftmost
PassEnd             ldd       <$11,s
                    bne       a17@
                    lbsr      PrevEvent
                    tfr       d,u
                    ldd       <UmeData_curind
                    std       <UmeData_ritind
                    bra       b17@
a17@                lbsr      NextEvent
                    tfr       d,u
                    ldd       <UmeData_curind
                    std       <UmeData_lftind
b17@                ldd       <$11,s
                    addd      #$0001
                    std       <$11,s
* NextPass: after both passes, when lftind is 0 and x > 6 the view restarts with xgoal = gind = 0 (RestartDraw)
NextPass            ldd       <$11,s
                    cmpd      #$0001
                    lble      PassBegin
                    ldd       <UmeData_lftind
                    bne       ScreenNotesBegin
                    ldd       8,s
                    cmpd      <$2B,s
                    ble       ScreenNotesBegin
                    clra
                    clrb
                    std       <UmeData_xgoal
                    std       <UmeData_gind
                    leax      <$2F,s
                    lbra      RestartDraw
* The silent layout round settled lftind, including any viewport restart; placement repeats
* visibly after the staves and the left-edge key signature.
ScreenNotesBegin    tst       >LayoutOnly
                    beq       ScreenNotesReady
                    ldd       <UmeData_gind                the anchor this draw settled on (restart and clamps done):
                    std       >KeepGind           kept for the 'n' job, which must lay out exactly this
                    ldd       <UmeData_xgoal
                    std       >KeepXgoal
                    clr       >LayoutOnly
                    lbra      ClampCursorCol
ScreenNotesReady    inc       >RenderNotes
* No batch opener: FrRenderFocusedPart ($CA) is read by s9gui as pollmark with one argument and
* would eat the first note packet. Focused notes need no wrapper: drawnr sets FocusNoteBit and
* s9gui's dispatcher inks every such $A0 itself.
ScreenNotesSeek     ldd       <UmeData_lftind
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    tfr       d,u
                    lbra      DrawLoopCheck
* AfterPasses: when beam (not FocusOnly): psoowee('B', 'b') = overlay s9b beam pass; then the focused-part notes or the flush
AfterPasses         tst       >FocusOnly
                    bne       ScreenFlush
                    ldb       <UmeData_beam
                    beq       ScreenFlush
                    ldd       #$0062
                    pshs      a,b
                    ldd       #$0042
                    pshs      a,b
                    jsr       [>UmeData_psoowee]
                    leas      4,s
                    ldd       >FocusedPart
                    bmi       ScreenFlush
                    lda       #2
                    sta       >RenderNotes
                    lbra      ScreenNotesSeek
* ScreenFlush: flush after notes and the optional beam pass.
ScreenFlush         jsr       [>UmeData_pflush]
                    ldd       >FocusedPart
                    std       >PaintedFocus
                    clr       >FocusOnly

                    leas      <$2F,s
                    puls      u,pc
* No placement, clearing, staff lines, rests or score marks on a focus-only repaint.
DrawFocusedNotes    pshs      u
                    leas      <-$2F,s
                    clr       >LayoutOnly
                    clr       >RenderNotes
                    lda       #1
                    sta       >FocusOnly
                    lbra      ScreenNotesReady
* DrawScreenKeep: the 'n' job: the sheet draw after a dropped note, without the cls. Same frame
* as DrawScreen, joining its code after the clear: staves, left key signature, bar lines, marks,
* rests and notes are drawn over what is on the screen.
DrawScreenKeep      pshs      u
                    leas      <-$2F,s
                    clr       >FocusOnly
                    clr       >RenderNotes
                    lbra      DrawScreenKept
* PrintScore: 'p' job: gets the marked range (pfixmarx), asks 'Squeeze Vertically', 'Real Print', 'Printer Ready?', then prints/previews the score system by system
PrintScore          clr       >LayoutOnly
                    clr       >FocusOnly

                    pshs      u
                    leas      <-$6B,s
                    leax      <$26,s
                    pshs      x
                    leax      <$2A,s
                    pshs      x
                    leax      <$2E,s
                    pshs      x
                    jsr       [>UmeData_pfixmarx]
                    leas      6,s
                    beq       PrintExit
                    ldd       <UmeData_nevents
                    addd      #$FFFF
                    cmpd      <$28,s
                    ble       AskPrintOptions
                    ldd       <$28,s
                    addd      #$FFFF
                    std       <$28,s
* AskPrintOptions: yes/no prompts: squeeze -> dosqueez, real print -> <$2C,s (needs printype), printer ready
AskPrintOptions     leax      >msgSqueezeVert,pcr
                    pshs      x
                    jsr       [>UmeData_pyesno]
                    leas      2,s
                    stb       <UmeData_dosqueez
                    leax      >msgRealPrint,pcr
                    pshs      x
                    jsr       [>UmeData_pyesno]
                    leas      2,s
                    stb       <$2C,s
                    beq       PrintSetup
                    ldb       <UmeData_printype
                    beq       PrintExit
                    leax      >msgPrinterReady,pcr
                    pshs      x
                    jsr       [>UmeData_pyesno]
                    leas      2,s
                    bne       WarnAbortKey
* PrintExit: early exit of PrintScore (no range / no printer / not ready)
PrintExit           leas      <$6B,s
                    puls      u,pc
* WarnAbortKey: palert(msgAbortHint): Q aborts a started print
WarnAbortKey        clra
                    clrb
                    pshs      a,b
                    leax      >msgAbortHint,pcr
                    pshs      x
                    jsr       [>UmeData_palert]
                    leas      4,s
* PrintSetup: PrinterCmd('b'), ClearRows(0, $BF), TextCursorOnOff(0), OpenTextBox(5,180,70,11,0,3), prints the title ($0BEB), maps the header block and prints its 9 lines
PrintSetup          ldd       #$0062
                    pshs      a,b
                    lbsr      PrinterCmd
                    leas      2,s
                    ldd       #$0001
                    std       <$10,s
                    ldd       <$2A,s
                    std       <$26,s
                    ldd       #$00BF
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    lbsr      ClearRows
                    leas      4,s
                    clra
                    clrb
                    pshs      a,b
                    lbsr      TextCursorOnOff
                    leas      2,s
                    ldd       #$0003
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$000B
                    pshs      a,b
                    ldd       #$0046
                    pshs      a,b
                    ldd       #$00B4
                    pshs      a,b
                    ldd       #$0005
                    pshs      a,b
                    lbsr      OpenTextBox
                    leas      12,s
                    ldx       #$0BEB
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    ldd       #$000D
                    pshs      a,b
                    jsr       [>UmeData_pputchar]
                    leas      2,s
                    ldd       #$0001
                    pshs      a,b
                    jsr       [>UmeData_pswapevts]
                    leas      2,s
                    clra
                    clrb
                    std       14,s
                    ldd       >UmeData_reserved_03E5
                    addd      #$1000
                    bra       HeaderLineCheck
* HeaderLineLoop: prints the 9 header lines of 52 bytes from $03E5+$1000 with fmtHeaderLine
HeaderLineLoop      ldd       <$2D,s
                    pshs      a,b
                    leax      >fmtHeaderLine,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    ldd       14,s
                    addd      #$0001
                    std       14,s
                    subd      #$0001
                    ldd       <$2D,s
                    addd      #$0034
* HeaderLineCheck: test-first entry of HeaderLineLoop; loops while the counter 14,s < 9
HeaderLineCheck     std       <$2D,s
                    ldd       14,s
                    cmpd      #$0009
                    blt       HeaderLineLoop
                    clra
                    clrb
                    pshs      a,b
                    jsr       [>UmeData_pswapevts]
                    leas      2,s
                    ldb       <$2C,s
                    beq       a19@
                    ldb       <UmeData_dosqueez
                    sex
                    std       12,s
                    ldd       #$0001
                    stb       <UmeData_dosqueez
                    ldd       #$0064
                    pshs      a,b
                    lbsr      PrinterCmd
                    leas      2,s
                    ldd       12,s
                    stb       <UmeData_dosqueez
                    bra       LineStart
* a19@: preview: SqueezeVert, then palert of an empty string to clear the box
a19@                lbsr      SqueezeVert
                    clra
                    clrb
                    pshs      a,b
                    leax      >strEmpty,pcr
                    pshs      x
                    jsr       [>UmeData_palert]
                    leas      4,s
* LineStart: start of a printed system: CloseTextBox, seek the line's first event, skip a leading type-$0D event
LineStart           lbsr      CloseTextBox
                    ldd       <$26,s
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    tfr       d,u
                    ldb       ,u
                    bne       a20@
                    ldb       5,u
                    cmpb      #$0D
                    bne       a20@
                    lbsr      NextEvent
                    tfr       d,u
* a20@: a first event that is a bar line gives kind (byte 5), bar number (bytes 3-4) and byte 6; else kind 0 near the start (index <= 3) or -1
a20@                pshs      u
                    lbsr      IsBarLine
                    std       ,s++
                    beq       b20@
                    ldb       5,u
                    sex
                    std       <$20,s
                    ldd       3,u
                    std       <$1A,s
                    ldb       6,u
                    sex
                    std       <$16,s
                    bra       PrintLineLoop
b20@                ldd       <UmeData_curind
                    cmpd      #$0003
                    bgt       c20@
                    clra
                    clrb
                    bra       d20@
c20@                ldd       #$FFFF
d20@                std       <$20,s
                    clra
                    clrb
                    std       <$16,s
                    std       <$1A,s
* PrintLineLoop: per-system loop head: trial PrintLine to find the bar positions, then FitBarsOnLine, GapThreshold and the final PrintLine
PrintLineLoop       ldd       #$FFFF
                    std       <$22,s
                    clra
                    clrb
                    std       <$12,s
                    clra
                    clrb
                    pshs      a,b
                    ldd       <$18,s
                    std       <$16,s
                    pshs      a,b
                    ldd       <$1E,s
                    std       <$1C,s
                    pshs      a,b
                    ldd       <$26,s
                    std       <$24,s
                    pshs      a,b
                    leax      <$2A,s
                    pshs      x
                    clra
                    clrb
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       <$38,s
                    pshs      a,b
                    ldd       <$38,s
                    pshs      a,b
                    lbsr      PrintLine
                    leas      <$14,s
                    ldd       <$22,s
                    cmpd      #$FFFF
                    bne       LineBarInfo
                    ldd       <$26,s
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    bra       StartBarCheck
* StartBarLoop: walks back from the line start to the nearest bar line when the trial pass found none
StartBarLoop        pshs      u
                    lbsr      IsBarLine
                    std       ,s++
                    bne       a21@
                    lbsr      PrevEvent
* StartBarCheck: entry of StartBarLoop after the line-start seek; loops while index >= 0
StartBarCheck       tfr       d,u
                    ldd       <UmeData_curind
                    bge       StartBarLoop
a21@                ldd       <UmeData_curind
                    std       <$22,s
                    ldd       #$0002
                    std       <$12,s
* LineBarInfo: the system's bar index <$22,s is known: seeks it, reads kind, bar number, byte 6, and its trial x column into <$12,s when not set
LineBarInfo         ldd       <$22,s
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    tfr       d,u
                    ldb       5,u
                    sex
                    std       <$20,s
                    ldd       3,u
                    std       <$1A,s
                    ldb       6,u
                    sex
                    std       <$16,s
                    ldd       <$12,s
                    bne       b21@
                    ldd       <$22,s
                    subd      <UmeData_xyoff
                    ldx       #$0425
                    leax      d,x
                    ldb       ,x
                    sex
                    std       <$12,s
* b21@: 2,s = time(ritind, the last event of the trial line) - time(bar); when ritind reached the range end the line is complete
b21@                ldd       1,u
                    std       6,s
                    ldd       <UmeData_ritind
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    tfr       d,x
                    ldd       1,x
                    subd      6,s
                    std       2,s
                    ldd       <UmeData_ritind
                    cmpd      <$28,s
                    blt       FitBarsOnLine
                    ldd       <$28,s
                    std       <$24,s
                    leax      <$6B,s
                    lbra      LineAtRangeEnd
* FitBarsOnLine: bars 10,s = span / zonedur, then time-signature ($03/$05) dependent limits from the first bar's column <$12,s and nzones
FitBarsOnLine       ldd       #$0001
                    pshs      a,b
                    ldd       <$24,s
                    pshs      a,b
                    lbsr      SameTimeEdge
                    leas      4,s
                    pshs      a,b
                    jsr       [>UmeData_pfindts]
                    leas      2,s
                    ldd       2,s
                    pshs      a,b
                    ldd       <UmeData_zonedur
                    lbsr      DivInt
                    std       10,s
                    ldd       <$12,s
                    cmpd      #$0048
                    lbge      h22@
                    ldd       <UmeData_reserved_0003
                    cmpd      #$0004
                    bne       b22@
                    ldd       <UmeData_reserved_0005
                    cmpd      #$0004
                    bne       b22@
                    ldd       <$12,s
                    cmpd      #$0038
                    blt       a22@
                    ldd       10,s
                    clra
                    andb      #$02
                    std       10,s
a22@                ldd       <$12,s
                    cmpd      #$0040
                    lblt      LineEndTime
                    lbra      h22@
b22@                ldd       <UmeData_reserved_0003
                    cmpd      #$0003
                    bne       d22@
                    ldd       10,s
                    cmpd      #$0001
                    bne       c22@
                    ldd       <$12,s
                    cmpd      #$0035
                    lbge      h22@
c22@                ldd       <$12,s
                    cmpd      #$0039
                    lblt      LineEndTime
                    lbra      h22@
d22@                ldd       <UmeData_reserved_0003
                    cmpd      #$0004
                    bne       e22@
                    ldd       <UmeData_reserved_0005
                    cmpd      #$0002
                    bne       e22@
                    ldd       <$12,s
                    cmpd      #$0046
                    lblt      LineEndTime
                    bra       h22@
e22@                ldd       <UmeData_nzones
                    clra
                    andb      #$01
                    bne       f22@
                    ldd       10,s
                    addd      10,s
                    cmpd      <UmeData_nzones
                    ble       h22@
                    ldd       <UmeData_nzones
                    asra
                    rorb
                    bra       i22@
f22@                ldd       <UmeData_nzones
                    clra
                    andb      #$01
                    beq       LineEndTime
                    ldd       <UmeData_nzones
                    asra
                    rorb
                    addd      #$0001
                    cmpd      10,s
                    bgt       g22@
                    ldd       <UmeData_nzones
                    asra
                    rorb
                    addd      #$0001
                    bra       i22@
g22@                ldd       <UmeData_nzones
                    asra
                    rorb
                    cmpd      10,s
                    ble       LineEndTime
* h22@: no whole bar fits on this line
h22@                clra
                    clrb
i22@                std       10,s
* LineEndTime: end time = bars * zonedur + start time; seeks the bar event
LineEndTime         ldd       10,s
                    pshs      a,b
                    ldd       <UmeData_zonedur
                    lbsr      MulInt
                    addd      6,s
                    std       ,s
                    ldd       <$22,s
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    bra       FindLineEndCheck
* FindLineEndLoop: NextEvent until time >= end time or index > ritind
FindLineEndLoop     ldd       1,u
                    pshs      a,b
                    ldd       2,s
                    subd      ,s++
                    ble       a23@
                    lbsr      NextEvent
* FindLineEndCheck: entry of FindLineEndLoop from LineEndTime; loops while index <= ritind
FindLineEndCheck    tfr       d,u
                    ldd       <UmeData_curind
                    cmpd      <UmeData_ritind
                    ble       FindLineEndLoop
* a23@: <$24,s = last event index of the line (index-1)
a23@                ldd       <UmeData_curind
                    addd      #$FFFF
                    std       <$24,s
                    bra       LeftoverCols
* LineAtRangeEnd: compiler goto (leas <-$6B,x) taken when the trial line reached the range end; joins LeftoverCols
LineAtRangeEnd      leas      <-$6B,x
* LeftoverCols: 12,s = 77 - x of the last event: spare columns to distribute (0 if none)
LeftoverCols        ldd       <$24,s
                    subd      <UmeData_xyoff
                    ldx       #$0425
                    leax      d,x
                    ldb       ,x
                    sex
                    pshs      a,b
                    ldd       #$004D
                    subd      ,s++
                    std       12,s
                    bgt       FinalLinePass
                    clra
                    clrb
                    std       8,s
                    std       12,s
* FinalLinePass: GapThreshold(leftover, &8,s, start, last), then the final PrintLine with that threshold and beam
FinalLinePass       ldd       <$24,s
                    pshs      a,b
                    ldd       <$28,s
                    pshs      a,b
                    leax      12,s
                    pshs      x
                    ldd       <$12,s
                    pshs      a,b
                    lbsr      GapThreshold
                    leas      8,s
                    std       2,s
                    ldb       <UmeData_beam
                    sex
                    pshs      a,b
                    ldd       <$16,s
                    pshs      a,b
                    ldd       <$1C,s
                    pshs      a,b
                    ldd       <$24,s
                    pshs      a,b
                    leax      <$2A,s
                    pshs      x
                    ldd       12,s
                    pshs      a,b
                    ldd       <$14,s
                    pshs      a,b
                    ldd       <$1A,s
                    pshs      a,b
                    ldd       <$34,s
                    pshs      a,b
                    ldd       <$38,s
                    pshs      a,b
                    lbsr      PrintLine
                    leas      <$14,s
                    ldd       10,s
                    lbne      EndOfScoreBar
                    ldd       <$20,s
                    std       <$1C,s
                    ldx       <$20,s
                    bra       f24@
a24@                clra
                    clrb
                    bra       e24@
b24@                clra
                    clrb
                    std       <$20,s
                    bra       CloseBarLine
c24@                ldd       <$16,s
                    cmpd      #$0001
                    bne       d24@
                    clra
                    clrb
                    bra       e24@
d24@                ldd       #$0001
e24@                std       <$1C,s
                    bra       CloseBarLine
* f24@: closing bar kind from the line's kind <$20,s: 3 -> 0, 5 -> 0 for ending 1 else 1, 1/6 kept with <$20,s cleared, others kept
f24@                cmpx      #$0003
                    beq       a24@
                    cmpx      #$0001
                    beq       b24@
                    cmpx      #$0006
                    lbeq      b24@
                    cmpx      #$0005
                    beq       c24@
* CloseBarLine: DrawBarLine($4F, kind <$1C,s, 0): bar line at the right edge of the printed system
CloseBarLine        clra
                    clrb
                    pshs      a,b
                    ldd       <$1E,s
* DrawBarAtEdge: shared tail with the kind in D: DrawBarLine($4F, kind, 0); EndOfScoreBar branches in with kind 6
DrawBarAtEdge       pshs      a,b
                    ldd       #$004F
                    pshs      a,b
                    lbsr      DrawBarLine
                    leas      6,s
                    bra       PageOutput
* EndOfScoreBar: line reaches the last event: DrawBarLine($4F, 6, 0) = final double bar; else <$20,s = -1
EndOfScoreBar       ldd       <UmeData_nevents
                    addd      #$FFFE
                    cmpd      <$24,s
                    bgt       a25@
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0006
                    bra       DrawBarAtEdge
a25@                ldd       #$FFFF
                    std       <$20,s
* PageOutput: real print: pinkey 'q' aborts, else PrinterCmd('d') dumps the page; preview: SqueezeVert and prompt
PageOutput          ldb       <$2C,s
                    beq       PreviewPrompt
                    jsr       [>UmeData_pinkey]
                    cmpb      #$71
                    beq       PrintFinish
                    ldd       #$0064
                    pshs      a,b
                    lbsr      PrinterCmd
                    leas      2,s
                    bra       NextLine
* PreviewPrompt: sprintf(fmtKeepPreview, line no) and yes/no; 'no' ends the preview
PreviewPrompt       lbsr      SqueezeVert
                    ldd       <$10,s
                    addd      #$0001
                    std       <$10,s
                    subd      #$0001
                    pshs      a,b
                    leax      >fmtKeepPreview,pcr
                    pshs      x
                    leax      <$33,s
                    pshs      x
                    jsr       [>UmeData_psprintf]
                    leas      6,s
                    leax      <$2F,s
                    pshs      x
                    jsr       [>UmeData_pyesno]
                    leas      2,s
                    beq       PrintFinish
* NextLine: next system starts at last+1; loops to PrintLineLoop while inside the range
NextLine            ldd       <$24,s
                    addd      #$0001
                    std       <$26,s
                    cmpd      <$28,s
                    bge       PrintFinish
                    lbra      PrintLineLoop
* PrintFinish: PrinterCmd('e') on a real print, redraw flags rfr_bar/rfr_scr, TextCursorOnOff(1), palert(msgPrintDone)
PrintFinish         ldb       <$2C,s
                    beq       a26@
                    ldd       #$0065
                    pshs      a,b
                    lbsr      PrinterCmd
                    leas      2,s
* a26@: redraw flags, text cursor on, done message, return
a26@                ldd       #$0001
                    stb       <UmeData_rfr_bar
                    stb       <UmeData_rfr_scr
                    ldd       #$0001
                    pshs      a,b
                    lbsr      TextCursorOnOff
                    leas      2,s
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgPrintDone,pcr
                    pshs      x
                    jsr       [>UmeData_palert]
                    leas      4,s
                    leas      <$6B,s
                    puls      u,pc
* GapThreshold(leftover, &count, start, last): repeatedly takes the largest time gap below the current minimum between events start..last and charges one leftover column per gap of that size until the columns run out; returns that gap size, *count = the columns left for it
GapThreshold        pshs      u
                    leas      -8,s
                    ldd       #$7FFF
                    lbra      GapOuterLoop
* GapPassStart: outer pass: *count = leftover, candidate = 0, seek the start event
GapPassStart        ldd       12,s
                    std       [<$0E,s]
                    clra
                    clrb
                    std       4,s
                    ldd       <$10,s
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    tfr       d,u
                    ldd       1,u
                    std       ,s
                    bra       LargestGapCheck
* LargestGapLoop: candidate = largest delta below the current minimum
LargestGapLoop      ldd       1,u
                    subd      ,s
                    std       2,s
                    cmpd      4,s
                    ble       a27@
                    ldd       2,s
                    cmpd      6,s
                    bge       a27@
                    ldd       2,s
                    std       4,s
a27@                ldd       1,u
                    std       ,s
                    lbsr      NextEvent
                    tfr       d,u
* LargestGapCheck: test-first entry of LargestGapLoop; loops while index <= last; no candidate returns the current minimum
LargestGapCheck     ldd       <UmeData_curind
                    cmpd      <$12,s
                    ble       LargestGapLoop
                    ldd       4,s
                    bne       b27@
                    ldd       6,s
                    bra       GapThresholdRet
* b27@: second scan from the start event
b27@                ldd       <$10,s
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    tfr       d,u
                    ldd       1,u
                    std       ,s
                    bra       CountGapsCheck
* CountGapsLoop: each gap equal to the candidate consumes one leftover column
CountGapsLoop       ldd       1,u
                    subd      ,s
                    cmpd      4,s
                    bne       a28@
                    ldd       12,s
                    addd      #$FFFF
                    std       12,s
a28@                ldd       1,u
                    std       ,s
                    lbsr      NextEvent
                    tfr       d,u
* CountGapsCheck: test-first entry of CountGapsLoop; loops while index <= last
CountGapsCheck      ldd       <UmeData_curind
                    cmpd      <$12,s
                    ble       CountGapsLoop
                    ldd       4,s
* GapOuterLoop: minimum = candidate; repeats while leftover > 0
GapOuterLoop        std       6,s
                    ldd       12,s
                    lbgt      GapPassStart
                    ldd       4,s
* GapThresholdRet: GapThreshold exit with D = the threshold (or the minimum when no candidate)
GapThresholdRet     leas      8,s
                    puls      u,pc
* PrintLine(start, last, extraCols, extraCols2, gapThreshold, &lastDrawn, leadBarKind, barNo, byte6, beam): renders one printed system through s9gui: clears the page, staves, lead bar, brace, key signature, then the events as DrawScreen does, with the extra-column budget
PrintLine           pshs      u
                    leas      <-$21,s
                    clr       >RenderNotes
                    ldd       <$27,s
                    cmpd      <UmeData_nevents
                    blt       a29@
                    ldd       <UmeData_nevents
                    addd      #$FFFF
                    std       <$27,s
* a29@: <$1B,s = 1..3 columns reserved for the leading bar line, x <$1D,s starts at <$1B,s + 4
a29@                ldd       #$0001
                    std       <$1B,s
                    ldd       <$31,s
                    blt       b29@
                    ldd       <$1B,s
                    addd      #$0001
                    std       <$1B,s
b29@                ldd       <$31,s
                    ble       c29@
                    ldd       <$1B,s
                    addd      #$0001
                    std       <$1B,s
* c29@: seeks the start event, remembers its time, then looks back for the bar line
c29@                ldd       <$1B,s
                    addd      #$0004
                    std       <$1D,s
                    ldd       <$25,s
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    tfr       d,u
                    ldd       1,u
                    std       ,s
                    bra       LinePrevBarCheck
* LinePrevBarLoop: PrevEvent until IsBarLine
LinePrevBarLoop     pshs      u
                    lbsr      IsBarLine
                    std       ,s++
                    bne       LineSetup
                    lbsr      PrevEvent
                    tfr       d,u
* LinePrevBarCheck: entry of LinePrevBarLoop; loops while index >= 0
LinePrevBarCheck    ldd       <UmeData_curind
                    bge       LinePrevBarLoop
* LineSetup: gbarind/gbar from the bar line, spacing unit 7,s = MinDurInBar, CloseTextBox, ClearRows(0, $BF, 0), DrawStaves(<$1B,s, 0), lead bar kind from the args (ending: 0 for ending 1, else 2)
LineSetup           ldd       <UmeData_curind
                    std       <UmeData_gbarind
                    ldd       3,u
                    std       <UmeData_gbar
                    clra
                    clrb
                    pshs      a,b
                    ldd       <UmeData_gbarind
                    addd      #$0001
                    pshs      a,b
                    lbsr      MinDurInBar
                    leas      4,s
                    std       7,s
                    lbsr      CloseTextBox
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$00BF
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    lbsr      ClearRows
                    leas      6,s
                    clra
                    clrb
                    pshs      a,b
                    ldd       <$1D,s
                    pshs      a,b
                    lbsr      DrawStaves
                    leas      4,s
                    ldd       <$31,s
                    blt       LineBraceKeySig
                    ldd       <$31,s
                    cmpd      #$0005
                    bne       c30@
                    ldd       <$35,s
                    cmpd      #$0001
                    bne       a30@
                    clra
                    clrb
                    bra       b30@
a30@                ldd       #$0002
b30@                std       <$31,s
                    bra       DrawLeadBar
c30@                clra
                    clrb
                    std       <$35,s
* DrawLeadBar: DrawBarLine(1, kind, barNo) at the left edge, plus DrawBarLine(1, 5, byte6) for an ending
DrawLeadBar         ldd       <$33,s
                    pshs      a,b
                    ldd       <$33,s
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    lbsr      DrawBarLine
                    leas      6,s
                    ldd       <$35,s
                    beq       LineBraceKeySig
                    ldd       <$35,s
                    pshs      a,b
                    ldd       #$0005
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    lbsr      DrawBarLine
                    leas      6,s
* LineBraceKeySig: printf(fmt at $16, $BD) = s9gui system brace, then FindKeySig(start) and DrawKeySig(x-2, sharps)
LineBraceKeySig     ldd       #$00BD
                    pshs      a,b
                    ldd       <UmeData_reserved_0016
                    pshs      a,b
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    ldd       <$25,s
                    pshs      a,b
                    lbsr      FindKeySig
                    leas      2,s
                    std       <$15,s
                    beq       LineBaseIndex
                    ldd       <$15,s
                    pshs      a,b
                    ldd       <$1F,s
                    addd      #$FFFE
                    pshs      a,b
                    lbsr      DrawKeySig
                    leas      4,s
                    ldd       <$1D,s
                    addd      #$0001
                    std       <$1D,s
* LineBaseIndex: xyoff = start - (x-4)*16/3 = base index of grafxes/grafyes; seeks the start event and enters the loop check
LineBaseIndex       ldd       <$1D,s
                    addd      #$FFFC
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    pshs      a,b
                    ldd       #$0003
                    lbsr      DivInt
                    pshs      a,b
                    ldd       <$27,s
                    subd      ,s++
                    std       <UmeData_xyoff
                    ldd       <$25,s
                    std       <$15,s
                    ldd       <UmeData_gbar
                    std       <$33,s
                    clra
                    clrb
                    std       15,s
                    std       13,s
                    ldd       <$15,s
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    tfr       d,u
                    lbra      PrintLoopCheck
* PrintEventLoop: per-event loop head of PrintLine (U = current event), same structure as DrawEventLoop with the extra-column budget
PrintEventLoop      ldb       ,u
                    sex
                    std       <$11,s
                    tst       >RenderNotes
                    beq       PrintPlaceEvent
                    tstb
                    lbeq      PrintNextEvent
                    ldd       <$11,s
                    cmpd      >FocusedPart
                    beq       PrintIsFocused
                    lda       >RenderNotes
                    cmpa      #2
                    lbeq      PrintNextEvent
                    bra       PrintFocusAllowed
PrintIsFocused      lda       >RenderNotes
                    cmpa      #2
                    lbne      PrintNextEvent
PrintFocusAllowed   equ       *
                    ldb       5,u
                    cmpb      #$20
                    lbeq      PrintNextEvent
                    sex
                    std       <$13,s
                    ldd       <UmeData_curind
                    subd      <UmeData_xyoff
                    ldx       #$0425
                    ldb       d,x
                    clra
                    std       <$1D,s
                    lbra      NoteEventP           same print renderer; do not consume spacing budgets again
PrintPlaceEvent     equ       *
                    ldd       7,s
                    bne       a31@
                    ldd       <UmeData_curind
                    std       <$15,s
                    clra
                    clrb
                    pshs      a,b
                    ldd       <UmeData_curind
                    pshs      a,b
                    lbsr      MinDurInBar
                    leas      4,s
                    std       7,s
                    ldd       <$15,s
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    tfr       d,u
* a31@: delta 4,s from the previous time; while extraCols lasts, a gap > threshold earns an extra column, and a gap == threshold earns one while extraCols2 also lasts
a31@                ldd       1,u
                    std       2,s
                    subd      ,s
                    std       4,s
                    lbeq      GotEventTypeP
                    ldd       2,s
                    std       ,s
                    ldd       <$29,s
                    ble       c31@
                    ldd       4,s
                    cmpd      <$2D,s
                    ble       b31@
                    ldd       <$1D,s
                    addd      #$0001
                    std       <$1D,s
                    ldd       <$29,s
                    addd      #$FFFF
                    std       <$29,s
                    bra       c31@
b31@                ldd       <$2B,s
                    ble       c31@
                    ldd       4,s
                    cmpd      <$2D,s
                    bne       c31@
                    ldd       <$1D,s
                    addd      #$0001
                    std       <$1D,s
                    ldd       <$29,s
                    addd      #$FFFF
                    std       <$29,s
                    ldd       <$2B,s
                    addd      #$FFFF
                    std       <$2B,s
c31@                ldd       4,s
                    cmpd      7,s
                    blt       AdvanceByTimeP
                    ldb       <UmeData_compact
                    bne       FixedColAdvanceP
* AdvanceByTimeP: x += (MulInt(delta, 24)/unit rounded to 8s, at least 8) / 8; x > 77 ends the line
AdvanceByTimeP      ldd       4,s
                    pshs      a,b
                    ldd       #$0018
                    lbsr      MulInt
                    pshs      a,b
                    ldd       9,s
                    lbsr      DivInt
                    std       <$19,s
                    addd      #$0004
                    andb      #$F8
                    std       <$19,s
                    cmpd      #$0008
                    bge       a32@
                    ldd       #$0008
                    std       <$19,s
a32@                ldd       <$1D,s
                    pshs      a,b
                    ldd       <$1B,s
                    pshs      a,b
                    ldd       #$0008
                    lbsr      DivInt
                    addd      ,s++
                    bra       b32@
* FixedColAdvanceP: print twin of FixedColAdvance: compact set and delta >= unit -> x += 3, then the 77 test
FixedColAdvanceP    ldd       <$1D,s
                    addd      #$0003
b32@                std       <$1D,s
                    ldd       <$1D,s
                    cmpd      #$004D
                    ble       GotEventTypeP
                    lbra      LineDone
* GotEventTypeP: type to <$13,s; when the previous event (part byte 13,s 0, type 15,s) was a partwise mark and this one is a note or another type, x += width 9,s
GotEventTypeP       ldb       5,u
                    sex
                    std       <$13,s
                    ldd       13,s
                    bne       DispatchByKindP
                    ldd       15,s
                    pshs      a,b
                    lbsr      IsPartMarkType
                    leas      2,s
                    beq       DispatchByKindP
                    ldd       <$11,s
                    bne       a33@
                    ldd       <$13,s
                    cmpd      15,s
                    beq       DispatchByKindP
a33@                ldd       <$1D,s
                    addd      9,s
                    std       <$1D,s
* DispatchByKindP: stores x; notes -> NoteEventP; types > $22 and $0D-$0F skipped in print; else NonNoteEventP
DispatchByKindP     ldd       <$11,s
                    lbne      NoteEventP
                    ldd       <UmeData_curind
                    subd      <UmeData_xyoff
                    ldx       #$0425
                    leax      d,x
                    ldd       <$1D,s
                    stb       ,x
                    ldd       <$13,s
                    cmpd      #$0022
                    bgt       a34@
                    ldd       <$13,s
                    cmpd      #$000D
                    blt       NonNoteEventP
                    ldd       <$13,s
                    cmpd      #$000F
                    bgt       NonNoteEventP
a34@                lbra      PrintNextEvent
* NonNoteEventP: width 9,s from table $011A; bar lines (types 1-6) are drawn with DrawBarLine once the lead bar is done (<$31,s = -1); the first one of the line is the lead bar
NonNoteEventP       ldd       <$13,s
                    ldx       #$011A
                    leax      d,x
                    ldb       ,x
                    sex
                    std       9,s
* As on the screen, the first non-marker after a same-time marker group sits 3 columns on.
                    ldd       4,s
                    bne       nnp9@
                    ldd       <$13,s
                    cmpd      #$0016
                    blt       nnp2@
                    cmpd      #$0017
                    ble       nnp9@
nnp2@               lbsr      PrevWasMarkP
                    bne       nnp9@
                    ldd       <$1D,s
                    addd      #$0003
                    std       <$1D,s
nnp9@
                    clra
                    clrb
                    std       <$17,s
                    ldd       <$13,s
                    cmpd      #$0006
                    lbgt      TypeKeySigP
                    ldd       3,u
                    std       <$33,s
                    ldd       <UmeData_curind
                    lbeq      d35@
                    ldd       <$31,s
                    cmpd      #$FFFF
                    bne       d35@
                    clra
                    clrb
                    std       <$35,s
                    ldd       <$13,s
                    cmpd      #$0005
                    bne       c35@
                    ldb       6,u
                    sex
                    std       <$35,s
                    cmpd      #$0001
                    bne       a35@
                    clra
                    clrb
                    bra       b35@
a35@                ldd       #$0001
b35@                std       <$13,s
* c35@: DrawBarLine(x, kind, barNo), plus DrawBarLine(x, 5, ending) for an ending, inside the line
c35@                ldd       <$33,s
                    pshs      a,b
                    ldd       <$15,s
                    pshs      a,b
                    ldd       <$21,s
                    pshs      a,b
                    lbsr      DrawBarLine
                    leas      6,s
                    ldd       <$35,s
                    beq       e35@
                    ldd       <$35,s
                    pshs      a,b
                    ldd       #$0005
                    pshs      a,b
                    ldd       <$21,s
                    pshs      a,b
                    lbsr      DrawBarLine
                    leas      6,s
                    bra       e35@
* d35@: index 0 or the bar already drawn as the lead bar: x = 1, width 0, lead kind = -1
d35@                ldd       <UmeData_curind
                    subd      <UmeData_xyoff
                    ldx       #$0425
                    leax      d,x
                    ldd       #$0001
                    stb       ,x
                    clra
                    clrb
                    std       9,s
                    ldd       #$FFFF
                    std       <$31,s
* e35@: spacing unit 7,s = 0 (recomputed at the next event), *lastDrawn = index
e35@                clra
                    clrb
                    std       7,s
                    ldd       <UmeData_curind
                    std       [<$2F,s]
                    lbra      StoreEventYP
* TypeKeySigP: type $0B: DrawKeySig(x, byte 6)
TypeKeySigP         ldd       <$13,s
                    cmpd      #$000B
                    bne       TypeTempoP
                    ldb       6,u
                    sex
                    pshs      a,b
                    ldd       <$1F,s
                    pshs      a,b
                    lbsr      DrawKeySig
* StoreEventYPop4P: drops the 4 args, joins StoreEventYP; TypeKeySigP falls in, TypeLabelP branches here
StoreEventYPop4P    leas      4,s
                    lbra      StoreEventYP
* TypeTempoP: type $19: DrawScoreMark($19, x, byte 3)
TypeTempoP          ldd       <$13,s
                    cmpd      #$0019
                    bne       TypeDynamicP
                    ldb       3,u
                    sex
                    pshs      a,b
                    ldd       <$1F,s
                    pshs      a,b
                    ldd       #$0019
* CallScoreMarkP: shared tail: DrawScoreMark then drop 6 bytes
CallScoreMarkP      pshs      a,b
                    lbsr      DrawScoreMark
                    lbra      StoreEventYPop6P
* TypeDynamicP: type $1A: DrawScoreMark($1A, x-1, byte 7)
TypeDynamicP        ldd       <$13,s
                    cmpd      #$001A
                    bne       TypeClockP
                    ldb       7,u
                    sex
                    pshs      a,b
                    ldd       <$1F,s
                    addd      #$FFFF
                    pshs      a,b
                    ldd       #$001A
                    bra       CallScoreMarkP
* TypeClockP: type $1B: DrawScoreMark($1B, x, byte 7)
TypeClockP          ldd       <$13,s
                    cmpd      #$001B
                    bne       TypeRampP
                    ldb       7,u
                    sex
                    pshs      a,b
                    ldd       <$1F,s
                    pshs      a,b
                    ldd       #$001B
                    lbra      CallScoreMarkP
* TypeRampP: types $1C/$1D: DrawRampMark(x, byte 7, byte 6, byte 3)
TypeRampP           ldd       <$13,s
                    cmpd      #$001C
                    beq       a36@
                    ldd       <$13,s
                    cmpd      #$001D
                    bne       TypeLabelP
a36@                ldb       3,u
                    sex
                    pshs      a,b
                    ldb       6,u
                    sex
                    pshs      a,b
                    ldb       7,u
                    sex
                    pshs      a,b
                    ldd       <$23,s
                    pshs      a,b
                    lbsr      DrawRampMark
                    leas      8,s
                    lbra      StoreEventYP
* TypeLabelP: type 7: DrawLabel(x, event)
TypeLabelP          ldd       <$13,s
                    cmpd      #$0007
                    bne       TypeAccentP
                    pshs      u
                    ldd       <$1F,s
                    pshs      a,b
                    lbsr      DrawLabel
                    lbra      StoreEventYPop4P
* TypeAccentP: type $22: DrawScoreMark($22, x, byte 7)
TypeAccentP         ldd       <$13,s
                    cmpd      #$0022
                    bne       TypeTimeSigP
                    ldb       7,u
                    sex
                    pshs      a,b
                    ldd       <$1F,s
                    pshs      a,b
                    ldd       #$0022
                    lbra      CallScoreMarkP
* TypeTimeSigP: type $0A: DrawTimeSig(x, byte 6, byte 7)
TypeTimeSigP        ldd       <$13,s
                    cmpd      #$000A
                    bne       a37@
                    ldb       7,u
                    sex
                    pshs      a,b
                    ldb       6,u
                    sex
                    pshs      a,b
                    ldd       <$21,s
                    pshs      a,b
                    lbsr      DrawTimeSig
                    lbra      StoreEventYPop6P
* a37@: type $1F: DrawScoreMark($1F, x, -1)
a37@                ldd       <$13,s
                    cmpd      #$001F
                    bne       TypeEndingP
                    ldd       #$FFFF
                    pshs      a,b
                    ldd       <$1F,s
                    pshs      a,b
                    ldd       #$001F
                    lbra      CallScoreMarkP
* TypeEndingP: type $21: DrawScoreMark($21, x, byte 7)
TypeEndingP         ldd       <$13,s
                    cmpd      #$0021
                    bne       TypePartMarkP
                    ldb       7,u
                    sex
                    pshs      a,b
                    ldd       <$1F,s
                    pshs      a,b
                    ldd       #$0021
                    lbra      CallScoreMarkP
* TypePartMarkP: IsPartMarkType -> DrawPartMark with $A6/$A5/$A2/$AB by type
TypePartMarkP       ldd       <$13,s
                    pshs      a,b
                    lbsr      IsPartMarkType
                    std       ,s++
                    beq       TypeOtherP
                    ldd       <$13,s
                    cmpd      #$0017
                    bne       a38@
                    ldd       #$00A6
                    bra       CallPartMarkP
a38@                ldd       <$13,s
                    cmpd      #$0018
                    bne       b38@
                    ldd       #$00A5
                    bra       CallPartMarkP
b38@                ldd       <$13,s
                    cmpd      #$0016
                    bne       c38@
                    ldd       #$00A2
                    bra       CallPartMarkP
c38@                ldd       #$00AB
* CallPartMarkP: shared tail: DrawPartMark, y to <$17,s, then x -= width
CallPartMarkP       pshs      a,b
                    lbsr      DrawPartMark
                    leas      2,s
                    std       <$17,s
                    ldd       <$13,s
                    cmpd      #$001E
                    bne       a39@
                    ldd       #$FFFF
                    bra       b39@
a39@                ldb       7,u
                    sex
b39@                ldd       <$1D,s
                    subd      9,s
                    std       <$1D,s
                    bra       StoreEventYP
* TypeOtherP: other types: DrawBarLine(x, type, 0)
TypeOtherP          clra
                    clrb
                    pshs      a,b
                    ldd       <$15,s
                    pshs      a,b
                    ldd       <$21,s
                    pshs      a,b
                    lbsr      DrawBarLine
* StoreEventYPop6P: drops 6 args and falls into StoreEventYP
StoreEventYPop6P    leas      6,s
* StoreEventYP: grafyes[curind-xyoff] = y; x += width unless index 0
StoreEventYP        ldd       <UmeData_curind
                    subd      <UmeData_xyoff
                    ldx       #$05C2
                    leax      d,x
                    ldd       <$17,s
                    stb       ,x
                    ldd       <UmeData_curind
                    lbeq      SavePrevTypeP
                    ldd       <$1D,s
                    addd      9,s
                    std       <$1D,s
                    lbra      SavePrevTypeP
* NoteEventP: note: PartStaff, y = staffY + 2*step; stem flag 6,s from part flags / step > 4, only when y > 15, forced when y > 176; not set with beam
NoteEventP          ldd       4,s                 a note right after a same-time marker group sits 3 columns on
                    bne       nep1@
                    lbsr      PrevWasMarkP
                    bne       nep1@
                    ldd       <$1D,s
                    addd      #$0003
                    std       <$1D,s
nep1@               leax      11,s
                    pshs      x
                    leax      <$21,s
                    pshs      x
                    ldd       <$15,s
                    pshs      a,b
                    lbsr      PartStaff
                    leas      6,s
                    ldd       <$1F,s
                    std       <$17,s
                    ldd       <$13,s
                    cmpd      #$0020
                    lbeq      RestEventP
                    ldd       <$17,s
                    pshs      a,b
                    ldd       <$15,s
                    addd      <$15,s
                    addd      ,s++
                    std       <$17,s
                    ldb       <$38,s
                    lbne      StoreNotePosP
                    ldd       11,s
                    clra
                    andb      #$01
                    bne       c40@
                    ldd       11,s
                    clra
                    andb      #$02
                    beq       b40@
a40@                ldd       #$0001
                    bra       d40@
b40@                ldd       <$13,s
                    cmpd      #$0004
                    bgt       a40@
c40@                clra
                    clrb
d40@                stb       6,s
                    sex
                    pshs      a,b
                    ldd       <$19,s
                    cmpd      #$000F
                    ble       e40@
                    ldd       #$0001
                    bra       f40@
e40@                clra
                    clrb
f40@                anda      ,s+
                    andb      ,s+
                    stb       6,s
                    sex
                    pshs      a,b
                    ldd       <$19,s
                    cmpd      #$00B0
                    ble       g40@
                    ldd       #$0001
                    bra       h40@
g40@                clra
                    clrb
h40@                ora       ,s+
                    orb       ,s+
                    stb       6,s
                    bra       StoreNotePosP
* RestEventP: rest (byte 5 = $20): y = staffY + 8, +-8 by part flags
RestEventP          ldd       <$17,s
                    pshs      a,b
                    ldd       13,s
                    clra
                    andb      #$01
                    beq       a41@
                    ldd       #$0008
                    bra       c41@
a41@                ldd       13,s
                    clra
                    andb      #$02
                    beq       b41@
                    ldd       #$FFF8
                    bra       c41@
b41@                clra
                    clrb
c41@                addd      #$0008
                    addd      ,s++
                    std       <$17,s
* StoreNotePosP: stores x/y; placement draws only rests; the beam arg with part flag bit 2 decides whether a note is drawn
StoreNotePosP       ldd       <UmeData_curind
                    subd      <UmeData_xyoff
                    ldx       #$0425
                    leax      d,x
                    ldd       <$1D,s
                    stb       ,x
                    ldd       <UmeData_curind
                    subd      <UmeData_xyoff
                    ldx       #$05C2
                    leax      d,x
                    ldd       <$17,s
                    stb       ,x
                    tst       >RenderNotes
                    bne       PrintNoteFilter
                    ldb       5,u
                    cmpb      #$20
                    bne       SavePrevTypeP
PrintNoteFilter     equ       *
                    ldb       <$38,s
                    beq       CallDrawNoteP
                    ldd       <$13,s
                    cmpd      #$0020
                    beq       CallDrawNoteP
                    ldd       11,s
                    clra
                    andb      #$04
                    beq       SavePrevTypeP
* CallDrawNoteP: pdrawnr(event+3, x, y, staffY, stem flag, flags&4, 1)
CallDrawNoteP       ldd       #$0001
                    pshs      a,b
                    ldd       13,s
                    clra
                    andb      #$04
                    pshs      a,b
                    ldb       10,s
                    sex
                    pshs      a,b
                    ldd       <$25,s
                    pshs      a,b
                    ldd       <$1F,s
                    pshs      a,b
                    ldd       <$27,s
                    pshs      a,b
                    pshs      u
                    ldd       #$0003
                    addd      ,s++
                    pshs      a,b
                    jsr       [>UmeData_pdrawnr]
                    leas      14,s
* SavePrevTypeP: remembers part byte/type for the next event
SavePrevTypeP       ldd       <$11,s
                    std       13,s
                    ldd       <$13,s
                    std       15,s
* PrintNextEvent: NextEvent then PrintLoopCheck; DispatchByKindP branches here to skip hidden and $0D-$0F types
PrintNextEvent      lbsr      NextEvent
                    tfr       d,u
* PrintLoopCheck: placement loops while index <= last and x <= 77; the note walk runs to ritind
PrintLoopCheck      ldd       <UmeData_curind
                    tst       >RenderNotes
                    beq       PrintPlaceCheck
                    cmpd      <UmeData_ritind
                    lble      PrintEventLoop
                    lda       >RenderNotes
                    cmpa      #1
                    bne       PrintNotesFinished
                    tst       <$38,s
                    bne       PrintNotesFinished
                    ldd       >FocusedPart
                    bmi       PrintNotesFinished
                    inc       >RenderNotes
                    lbra      PrintFocusSeek
PrintNotesFinished  equ       *
                    ldd       <UmeData_ritind
                    pshs      a,b
                    lbsr      SeekEvent           preserve PrintLine's original final iterator
                    leas      2,s
                    tfr       d,u
                    lda       >RenderNotes
                    clr       >RenderNotes
                    cmpa      #2
                    lbeq      a42@
                    bra       LineNotesDone
PrintPlaceCheck     equ       *
                    cmpd      <$27,s
                    bgt       LineDone
                    ldd       <$1D,s
                    cmpd      #$004D
                    lble      PrintEventLoop
* LineDone: end of placement: ritind = last placed index, lftind = start; then the note walk, the s9b beam pass when beam, and printf(strCR)
LineDone            lbsr      PrevEvent
                    tfr       d,u
                    ldd       <UmeData_curind
                    std       <UmeData_ritind
                    ldd       <$25,s
                    std       <UmeData_lftind
                    inc       >RenderNotes
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    tfr       d,u
                    lbra      PrintLoopCheck
LineNotesDone       equ       *
                    ldb       <$38,s
                    beq       a42@
                    ldd       #$0062
                    pshs      a,b
                    ldd       #$0042
                    pshs      a,b
                    jsr       [>UmeData_psoowee]
                    leas      4,s
                    ldd       >FocusedPart
                    bmi       a42@
                    lda       #2
                    sta       >RenderNotes
PrintFocusSeek      ldd       <UmeData_lftind
                    pshs      d
                    lbsr      SeekEvent
                    leas      2,s
                    tfr       d,u
                    lbra      PrintLoopCheck
* a42@: printf(strCR) flushes the s9gui pipe and returns
a42@                leax      >strCR,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    leas      <$21,s
                    puls      u,pc
* msgSqueezeVert: yes/no prompt, answer kept in dosqueez
msgSqueezeVert      fcc       /Squeeze Vertically (recommended)?/
                    fcb       $00
* msgRealPrint: yes/no prompt
msgRealPrint        fcc       /Real Print, not just preview?/
                    fcb       $00
* msgPrinterReady: yes/no prompt
msgPrinterReady     fcc       /Printer Ready?  Paper at Page Top?/
                    fcb       $00
* msgAbortHint: message box text
msgAbortHint        fcc       /To abort print once started,/
                    fcb       $0D
                    fcc       / hit 'Q' -- not BREAK!/
                    fcb       $0D,$00
* fmtHeaderLine: printf format for the 9 header lines
fmtHeaderLine       fcc       /       %s/
                    fcb       $0D,$00
* strEmpty: empty string passed to palert to clear the message box
strEmpty            fcb       $00
* fmtKeepPreview: sprintf format for the preview prompt
fmtKeepPreview      fcc       /Line %d.  Keep on previewing? /
                    fcb       $00
* msgPrintDone: message at the end of a print
msgPrintDone        fcc       / Print Finished./
                    fcb       $0D,$00
* strCR: printed to flush the line-buffered s9gui pipe at the end of PrintLine (followed by unused bytes)
strCR               fcb       $0D,$00,$34,$40,$8E,$01,$A6,$1F
                    fcb       $10,$35,$C0
* IsPartMarkType(type): 1 if type is $16, $17, $18, $1E or $20 (marks drawn at a part's staff via DrawPartMark)
IsPartMarkType      pshs      u
                    ldd       4,s
                    cmpd      #$0017
                    beq       a43@
                    ldd       4,s
                    cmpd      #$0018
                    beq       a43@
                    ldd       4,s
                    cmpd      #$0016
                    beq       a43@
                    ldd       4,s
                    cmpd      #$001E
                    beq       a43@
                    ldd       4,s
                    cmpd      #$0020
                    bne       PredicateFalse
* a43@: returns 1
a43@                ldd       #$0001
                    bra       PredicateRet
* IsBarLine(eventPtr): 1 if byte 0 == 0 (not a note) and type (byte 5) <= 6 = a bar-line event
IsBarLine           pshs      u
                    ldb       [<$04,s]
                    bne       PredicateFalse
                    ldx       4,s
                    ldb       5,x
                    cmpb      #$06
                    bgt       PredicateFalse
                    ldd       #$0001
                    bra       PredicateRet
* PredicateFalse: shared 'return 0' of IsPartMarkType and IsBarLine
PredicateFalse      clra
                    clrb
* PredicateRet: shared puls u,pc of those two predicates; branched to with D = 1, fallen into with D = 0
PredicateRet        puls      u,pc
* DrawTimeSig(x, beats, unit): s9gui $A4 + 3 bytes (s9gui draws the digits on every staff)
DrawTimeSig         pshs      u
                    ldd       #$00A4
                    stb       <UmeData_arg0
                    ldd       4,s
                    stb       <UmeData_arg1
                    ldd       6,s
                    lbra      Cmd4StoreByte3
* DrawPartMark(cmd, x, part, value): a part outside 1..16 returns $BF, nothing sent. Channel ($A2) and instrument ($A6) marks sit on a staff line from PartMarkLane (x one column on for an odd lane); $A5/$AB at staffY + 8 +-8 by part flags. Sends cmd, x, y, value; returns y
DrawPartMark        pshs      a,b,x,u
                    ldd       12,s
                    cmpd      #$0001
                    blt       a44@
                    ldd       12,s
                    cmpd      #$0010
                    ble       b44@
* a44@: invalid part: returns $BF (off screen), nothing sent
a44@                ldd       #$00BF
                    lbra      SharedRetPop4
* b44@: PartStaff lookup: ,s = staffY, 2,s = flags
b44@                leax      2,s
                    pshs      x
                    leax      2,s
                    pshs      x
                    ldd       <$10,s
                    pshs      a,b
                    lbsr      PartStaff
                    leas      6,s
                    ldd       8,s
                    cmpd      #$00A2              MIDI channel
                    beq       marklane@
                    cmpd      #$00A6              instrument
                    bne       markflags@
marklane@           ldb       9,s                 the command's low byte
                    clra
                    cmpb      #$A6
                    bne       mlk@
                    inca                          A = 1 an instrument mark, 0 a channel mark
mlk@                ldb       13,s                B = the part (1..16)
                    lbsr      PartMarkLane        A = the x bump (1 on an odd lane), B = the line above the staff bottom
                    pshs      a
                    clra
                    addd      1,s                 staff bottom plus the part's staff line
                    std       1,s
                    puls      b                   the bump
                    clra
                    addd      10,s                the x: one column on for lines 2 and 4 (x is in columns)
                    std       10,s
                    bra       markemit@
markflags@
                    ldd       ,s
                    pshs      a,b
                    ldd       4,s
                    clra
                    andb      #$01
                    beq       c44@
                    ldd       #$0008
                    bra       e44@
c44@                ldd       4,s
                    clra
                    andb      #$02
                    beq       d44@
                    ldd       #$FFF8
                    bra       e44@
d44@                clra
                    clrb
* e44@: y = staffY + 8 +-8; markemit@ fills arg0..arg3 and writes 4 bytes (none in the layout round)
e44@                addd      #$0008
                    addd      ,s++
                    std       ,s
markemit@           ldd       8,s
                    stb       <UmeData_arg0
                    ldd       10,s
                    stb       <UmeData_arg1
                    ldd       ,s
                    stb       <UmeData_arg2
                    ldd       14,s
                    stb       <UmeData_arg3
                    ldd       #$0004
                    pshs      a,b
                    tst       >LayoutOnly
                    bne       SkipLayoutPartMark
                    jsr       [>UmeData_pnfwrite]
SkipLayoutPartMark  leas      2,s
                    ldd       ,s
                    lbra      SharedRetPop4
* PrevWasMark: Z set when the previous event of the screen placement pass was a channel/
* instrument marker: its part byte (<$1B,s of the caller, 0 for a mark) is 0 and its type
* (<$1D,s) is $16 or $17. Called with lbsr: the caller's slots sit two bytes deeper here.
PrevWasMark         ldd       <$1D,s              the previous part byte
                    bne       pwm0@
                    ldd       <$1F,s              the previous type
                    cmpd      #$0016
                    blt       pwm0@
                    cmpd      #$0017
                    bgt       pwm0@
                    clra                          Z: a marker
                    rts
pwm0@               lda       #1                  NZ: not a marker
                    rts
* PrevWasMarkP: the print pass's twin: part byte at 13,s, type at 15,s of the caller's frame.
PrevWasMarkP        ldd       15,s
                    bne       pwp0@
                    ldd       <$11,s
                    cmpd      #$0016
                    blt       pwp0@
                    cmpd      #$0017
                    bgt       pwp0@
                    clra
                    rts
pwp0@               lda       #1
                    rts
* PartMarkLane: A = the kind (0 channel, 1 instrument), B = the part (1..16). Lane = 2 x the
* number of earlier parts on the same staff + the kind, mod 5 (the five staff lines repeat
* for more parts). Returns A = the x bump (1 on an odd lane), B = 16 - 4 x lane, the line
* above the staff bottom. No C arguments; keeps X/U/Y.
PartMarkLane        pshs      x,u
                    pshs      a                   the kind: 0 a channel mark, 1 an instrument mark
                    clra                          D = the part
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$0C5F
                    leau      d,x
                    ldd       ,u
                    pshs      d
                    leax      4,x
                    clrb
mlnext@             pshs      u
                    cmpx      ,s++
                    bhs       mlrank@
                    pshs      b
                    ldd       ,x
                    cmpd      1,s
                    puls      b
                    bne       mlskip@
                    incb
mlskip@             leax      4,x
                    bra       mlnext@
mlrank@             lslb                          lane = 2 x rank + the kind: H and I of a part on their own lines
                    addb      2,s
mlmod@              cmpb      #5
                    blo       mloff@
                    subb      #5
                    bra       mlmod@
mloff@              pshs      b
                    andb      #1
                    beq       mlev@
                    lda       #1                  an odd lane (line 2, 4): one column (8 dots) right - the mark's x is in COLUMNS
                    bra       mlx@
mlev@               clra
mlx@                puls      b
                    lslb
                    lslb
                    negb
                    addb      #16                 B = 16 - 4 x lane: the line above the staff bottom
                    leas      3,s                 the staff word and the kind
                    puls      x,u,pc
* DrawScoreMark(subtype, x, param): s9gui $A7 with x, subtype, param; subtypes $19 tempo number, $1A dynamic glyph, $1B 'C+/-' clock, $1F/$21 'E'[n] ending, $22 '^'/'-' accent
DrawScoreMark       pshs      u
                    ldd       #$00A7
                    stb       <UmeData_arg0
                    ldd       6,s
                    stb       <UmeData_arg1
                    ldd       4,s
* Cmd4StoreByte3: shared tail: D -> arg2, 8,s -> arg3, SendCmd4Bytes; DrawTimeSig branches in after its $A4
Cmd4StoreByte3      stb       <UmeData_arg2
                    ldd       8,s
                    lbra      SendCmd4Bytes
* DrawLabel(x, eventPtr): s9gui $B2 with x, byte 3, byte 6 = the two label characters (type 7 event)
DrawLabel           pshs      u
                    ldd       #$00B2
                    stb       <UmeData_arg0
                    ldd       4,s
                    stb       <UmeData_arg1
                    ldx       6,s
                    ldb       3,x
                    stb       <UmeData_arg2
                    ldx       6,s
                    ldb       6,x
                    lbra      SendCmd4Bytes
* DrawRampMark(x, b7, b6, b3): s9gui $AA; b6 < 2 -> '<'/'>' hairpin with the target dynamic, else rit ('R') / accel ('A') with the target tempo
DrawRampMark        pshs      u
                    ldd       #$00AA
                    stb       <UmeData_arg0
                    ldd       4,s
                    stb       <UmeData_arg1
                    ldd       6,s
                    stb       <UmeData_arg2
                    ldd       8,s
                    stb       <UmeData_arg3
                    ldd       10,s
                    bra       Cmd5StoreByte5
* NoteDuration(value, dots): word table at data $015A[dots] shifted right by value (ShiftRightN): note duration in ticks
NoteDuration        pshs      u
                    ldd       6,s
                    aslb
                    rola
                    ldx       #$015A
                    leax      d,x
                    ldd       ,x
                    pshs      a,b
                    ldd       6,s
                    lbsr      ShiftRightN
                    puls      u,pc
* DrawBarLine(x, kind, barNo16): s9gui $A8 with x, kind byte, 16-bit bar number; kinds 1-6 (5 ending, 6 final), also used for misc types
DrawBarLine         pshs      u
                    ldd       #$00A8
                    stb       <UmeData_arg0
                    ldd       4,s
                    stb       <UmeData_arg1
                    ldd       6,s
                    stb       <UmeData_arg2
                    ldd       8,s
                    sta       <UmeData_arg3
* Cmd5StoreByte5: shared tail: D -> arg4 then send 5 bytes; DrawRampMark branches in after its $AA header
Cmd5StoreByte5      stb       <UmeData_arg4
                    ldd       #$0005
                    lbra      SendCmdBytes
* DrawKeySig(x, sharps): s9gui $A3; positive = sharps, negative = flats, 0 = naturals
DrawKeySig          pshs      u
                    ldd       #$00A3
                    stb       <UmeData_arg0
                    ldd       4,s
                    stb       <UmeData_arg1
                    ldd       6,s
                    stb       <UmeData_arg2
                    ldd       #$0003
                    lbra      SendCmdBytes
                    fcb       $34,$40,$EC,$68,$34,$06,$E6,$6D
                    fcb       $1D,$34,$06,$EC,$6A,$34,$06,$EC
                    fcb       $6A,$34,$06,$CC,$00,$C0,$34,$06
                    fcb       $30,$8D,$02,$5D,$34,$10,$AD,$9F
                    fcb       $03
                    fcs       /]2l5@/
* OpenTextBox(x, y, w, h, a5, a6): printf(fmt at $14 = '%c' x7, $C6, ...) opens s9gui's text box (5,180,70,11 for the print status)
OpenTextBox         pshs      u
                    ldd       14,s
                    pshs      a,b
                    ldb       15,s
                    sex
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    ldd       #$00C6
                    pshs      a,b
                    ldd       <UmeData_reserved_0014
                    pshs      a,b
                    jsr       [>UmeData_pprintf]
                    leas      <$10,s
                    puls      u,pc
* CloseTextBox: printf(fmt at $16, $C7) then flush: s9gui restores the screen under an open text box
CloseTextBox        pshs      u
                    ldd       #$00C7
                    lbra      SendCmdByte
* TextCursorOnOff(flag): printf(fmt at $18, $CC, flag): s9gui shows/hides the text-box cursor block; off during printing, on at the end
TextCursorOnOff     pshs      u
                    ldb       5,s
                    sex
                    pshs      a,b
                    ldd       #$00CC
                    pshs      a,b
                    ldd       <UmeData_reserved_0018
                    pshs      a,b
                    jsr       [>UmeData_pprintf]
                    leas      6,s
                    lbra      FlushExit
* ClearRows(y0, y1, a3): s9gui $BC (0, y0, $4F, y1, a3) erases the full-width band of rows y0..y1 (negatives clamped to 0)
ClearRows           pshs      u
                    ldd       4,s
                    bge       a45@
                    clra
                    clrb
                    std       4,s
a45@                ldd       6,s
                    bge       b45@
                    clra
                    clrb
                    std       6,s
* b45@: fills the 6-byte $BC command and sends it
b45@                ldd       #$00BC
                    stb       <UmeData_arg0
                    clra
                    clrb
                    stb       <UmeData_arg1
                    ldd       4,s
                    stb       <UmeData_arg2
                    ldd       #$004F
                    stb       <UmeData_arg3
                    ldd       6,s
                    stb       <UmeData_arg4
                    ldd       8,s
                    stb       <UmeData_arg5
                    ldd       #$0006
                    bra       SendCmdBytes
* DrawStaves(xOffset, leftBar): s9gui $9E (leftBar, xOffset, halfstaf) draws every staff's lines and clef, with the system's left bar when leftBar != 0
DrawStaves          pshs      u
                    ldd       #$009E
                    stb       <UmeData_arg0
                    ldb       7,s
                    stb       <UmeData_arg1
                    ldd       4,s
                    stb       <UmeData_arg2
                    ldb       <UmeData_halfstaf
* SendCmd4Bytes: shared tail: arg3 = B, write 4 command bytes
SendCmd4Bytes       stb       <UmeData_arg3
                    ldd       #$0004
* SendCmdBytes: shared tail: pnfwrite D bytes of the arg0.. command buffer to stdout (none in the layout round), then return
SendCmdBytes        pshs      a,b
                    tst       >LayoutOnly
                    bne       SkipLayoutCommand
                    jsr       [>UmeData_pnfwrite]
SkipLayoutCommand   equ       *
                    lbra      SharedRetPop2
* SqueezeVert: when dosqueez: printf(fmt at $16, $BE) = s9gui squeeze vertically, then flush
SqueezeVert         pshs      u
                    ldb       <UmeData_dosqueez
                    beq       FlushExit
                    ldd       #$00BE
* SendCmdByte: shared tail: printf(fmt at $16, cmd) then FlushExit
SendCmdByte         pshs      a,b
                    ldd       <UmeData_reserved_0016
                    pshs      a,b
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    bra       FlushExit
* PrinterCmd(c): when printype is set or c == 'b': printf(fmt at $20, $BF, c, printype, dosqueez, doesff, automarg) = s9gui printer job 'b' begin / 'd' dump page / 'e' end
PrinterCmd          pshs      u
                    ldb       >UmeData_printype
                    bne       a46@
                    ldb       5,s
                    cmpb      #$62
                    beq       a46@
                    puls      u,pc
* a46@: builds and prints the $BF sequence
a46@                ldb       <UmeData_automarg
                    sex
                    pshs      a,b
                    ldb       <UmeData_doesff
                    sex
                    pshs      a,b
                    ldb       <UmeData_dosqueez
                    sex
                    pshs      a,b
                    ldb       >UmeData_printype
                    sex
                    pshs      a,b
                    ldb       13,s
                    sex
                    pshs      a,b
                    ldd       #$00BF
                    pshs      a,b
                    ldd       <UmeData_reserved_0020
                    pshs      a,b
                    jsr       [>UmeData_pprintf]
                    leas      14,s
* FlushExit: shared exit: pflush of the s9gui pipe, return
FlushExit           jsr       [>UmeData_pflush]
                    puls      u,pc
* PartStaff(part, &staffY, &flags): part table at data $0C5F (4 bytes/part: staff, flags) and staff table at $0C19 (10 bytes/staff, y first); a bad part alerts 'Partstaff: Bad Part=' and uses the last part
PartStaff           pshs      u
                    ldd       4,s
                    cmpd      #$0001
                    blt       BadPart
                    ldd       4,s
                    cmpd      <UmeData_nparts
                    ble       PartStaffLookup
* BadPart: palert(msgBadPart, 1, part) and substitutes the last part nparts
BadPart             ldd       4,s
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    leax      >msgBadPart,pcr
                    pshs      x
                    jsr       [>UmeData_palert]
                    leas      6,s
                    ldd       <UmeData_nparts
                    std       4,s
* PartStaffLookup: *flags = parts[part].flags, *staffY = staves[parts[part].staff].y
PartStaffLookup     ldd       4,s
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
                    lbsr      MulInt
                    ldx       #$0C19
                    leax      d,x
                    ldd       ,x
                    std       [<$06,s]
                    puls      u,pc
* MinDurInBar(index, backwards): smallest NoteDuration among the notes from index to the next bar line or end = the spacing unit (start $60; a duration below 2 counts as 6; rests with value > 3 count double; at least 12 with compact)
MinDurInBar         pshs      a,b,x,u
                    ldd       8,s
                    cmpd      <UmeData_nevents
                    blt       a47@
                    ldd       <UmeData_nevents
                    addd      #$FFFF
                    std       8,s
a47@                ldd       #$0060
                    std       2,s
                    ldd       8,s
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    lbra      MinDurLoopCheck
* MinDurLoop: a bar line stops the scan, notes update the minimum
MinDurLoop          ldb       ,u
                    bne       a48@
                    ldb       5,u
                    cmpb      #$06
                    bgt       d48@
                    lbra      f48@
* a48@: NoteDuration(byte 3, byte 4) against the running minimum
a48@                ldb       4,u
                    sex
                    pshs      a,b
                    ldb       3,u
                    sex
                    pshs      a,b
                    lbsr      NoteDuration
                    leas      4,s
                    std       ,s
                    cmpd      2,s
                    bge       d48@
                    ldd       ,s
                    cmpd      #$0002
                    bge       b48@
                    ldd       #$0006
                    std       ,s
* b48@: rests (byte 5 = $20) with value > 3 count double
b48@                ldb       5,u
                    cmpb      #$20
                    bne       c48@
                    ldb       3,u
                    cmpb      #$03
                    ble       c48@
                    ldd       ,s
                    pshs      a,b
                    ldd       #$0001
                    lbsr      ShiftLeftN
                    std       ,s
                    cmpd      2,s
                    bge       d48@
c48@                ldd       ,s
                    std       2,s
* d48@: PrevEvent or NextEvent by the direction flag
d48@                ldb       11,s
                    beq       e48@
                    lbsr      PrevEvent
                    bra       MinDurLoopCheck
e48@                lbsr      NextEvent
* MinDurLoopCheck: loop test of MinDurInBar: index in 0..nevents-1
MinDurLoopCheck     tfr       d,u
                    ldd       <UmeData_curind
                    cmpd      <UmeData_nevents
                    bge       f48@
                    ldd       <UmeData_curind
                    lbge      MinDurLoop
* f48@: returns the minimum 2,s. With compact display on, the unit is never under a 16th
* (12 ticks), so a bar holding a 32nd or a 64th lays out like a native one; the
* FixedColAdvance cap still applies above it.
f48@                ldd       2,s
                    tst       <UmeData_compact                Compact display?
                    beq       SharedRetPop4
                    cmpd      #12                 a 16th
                    bge       SharedRetPop4
                    ldd       #12
* SharedRetPop4: shared leas 4,s / puls u,pc: MinDurInBar and both DrawPartMark returns
SharedRetPop4       leas      4,s
                    puls      u,pc
* FindKeySig(index): walks back to the nearest non-note event of type $0B and returns its byte 6 (sharps/flats), 0 if none
FindKeySig          pshs      u
                    ldd       4,s
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    bra       KeySigLoopCheck
* KeySigLoop: loop head of the backward key-signature search
KeySigLoop          ldb       ,u
                    bne       a49@
                    ldb       5,u
                    cmpb      #$0B
                    bne       a49@
                    ldb       6,u
                    sex
                    puls      u,pc
a49@                lbsr      PrevEvent
* KeySigLoopCheck: entry of KeySigLoop from FindKeySig's seek; loops while index >= 0, else returns 0
KeySigLoopCheck     tfr       d,u
                    ldd       <UmeData_curind
                    bge       KeySigLoop
                    clra
                    clrb
                    puls      u,pc
* SameTimeEdge(index, dir): steps while the time equals that of index; dir != 0 -> last index of the same-time group, dir == 0 -> first; clamps to 0 / nevents-1
SameTimeEdge        pshs      a,b,u
                    ldd       6,s
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    tfr       d,u
                    ldd       1,u
                    std       ,s
* EdgeLoop: loop head of SameTimeEdge
EdgeLoop            ldd       <UmeData_curind
                    bge       a50@
                    clra
                    clrb
                    bra       SharedRetPop2
a50@                ldd       <UmeData_curind
                    cmpd      <UmeData_nevents
                    blt       b50@
                    ldd       <UmeData_nevents
                    addd      #$FFFF
                    bra       SharedRetPop2
b50@                ldd       1,u
                    cmpd      ,s
                    beq       e50@
                    ldb       9,s
                    beq       c50@
                    ldd       #$FFFF
                    bra       d50@
c50@                ldd       #$0001
d50@                addd      <UmeData_curind
                    bra       SharedRetPop2
e50@                ldb       9,s
                    beq       f50@
                    lbsr      NextEvent
                    bra       g50@
f50@                lbsr      PrevEvent
g50@                tfr       d,u
                    bra       EdgeLoop
* SharedRetPop2: shared leas 2,s / puls u,pc of SameTimeEdge's exits and SendCmdBytes
SharedRetPop2       leas      2,s
                    puls      u,pc
                    fcc       /%c%c%c%c%s/
                    fcb       $0D,$00
* msgBadPart: error text (the message box appends ' %d')
msgBadPart          fcc       /Partstaff: Bad Part=/
                    fcb       $00
* SeekEvent(index): curind = index; page = index/$3A0 + 1 is swapped in through ppswap when it is not curpage; returns curevp = database + (index mod $3A0)*8, or 0 when the swap fails
SeekEvent           pshs      u
                    ldu       4,s
                    leas      -2,s
                    stu       <UmeData_curind
                    ldd       #$0001
                    bra       BlockDivStep
* BlockDivLoop: repeated subtraction of $3A0 for the page number and remainder
BlockDivLoop        ldd       ,s
                    addd      #$0001
* BlockDivStep: body of SeekEvent's divide loop, entered with count 1: stores the count and subtracts $3A0
BlockDivStep        std       ,s
                    leau      >-$03A0,u
                    stu       -2,s
                    bge       BlockDivLoop
                    leau      >$03A0,u
                    ldd       ,s
                    cmpd      <UmeData_curpage
                    beq       a51@
                    ldd       ,s
                    pshs      a,b
                    jsr       [>UmeData_ppswap]
                    leas      2,s
                    bne       a51@
                    clra
                    clrb
                    bra       b51@
* a51@: pointer = remainder*8 + database
a51@                tfr       u,d
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    addd      <UmeData_database
                    std       <UmeData_curevp
b51@                leas      2,s
                    puls      u,pc
* NextEvent: curind++; curevp += 8, swapping in the next page (curpage+1) past curptop; returns curevp
NextEvent           pshs      u
                    ldd       <UmeData_curind
                    addd      #$0001
                    std       <UmeData_curind
                    cmpd      <UmeData_nevents
                    bge       RetEventPtr
                    ldd       <UmeData_curevp
                    addd      #$0008
                    std       <UmeData_curevp
                    cmpd      <UmeData_curptop
                    bls       RetEventPtr
                    ldd       <UmeData_curpage
                    addd      #$0001
                    pshs      a,b
                    jsr       [>UmeData_ppswap]
                    leas      2,s
                    ldd       <UmeData_database
                    bra       StoreEventPtr
* PrevEvent: curind--; curevp -= 8, swapping in the previous page and continuing at its last record (curptop); returns curevp
PrevEvent           pshs      u
                    ldd       <UmeData_curind
                    addd      #$FFFF
                    std       <UmeData_curind
                    blt       RetEventPtr
                    ldd       <UmeData_curevp
                    addd      #$FFF8
                    std       <UmeData_curevp
                    cmpd      <UmeData_database
                    bhs       RetEventPtr
                    ldd       <UmeData_curpage
                    addd      #$FFFF
                    pshs      a,b
                    jsr       [>UmeData_ppswap]
                    leas      2,s
                    ldd       <UmeData_curptop
* StoreEventPtr: stores the remapped record pointer to curevp; NextEvent branches in with database, PrevEvent falls in
StoreEventPtr       std       <UmeData_curevp
* RetEventPtr: shared return of NextEvent/PrevEvent: D = curevp
RetEventPtr         ldd       <UmeData_curevp
                    puls      u,pc
* MulInt: C library 16x16 multiply: D * word on the stack (popped), 8x8 fast path when both high bytes are zero
MulInt              tsta
                    bne       MulFull16
                    tst       2,s
                    bne       MulFull16
                    lda       3,s
                    mul
                    ldx       ,s
                    stx       2,s
                    ldx       #$0000
                    std       ,s
                    puls      a,b,pc
* MulFull16: four-partial-product 16x16 multiply
MulFull16           pshs      a,b
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
                    bhs       a52@
                    inc       ,s
a52@                lda       4,s
                    ldb       9,s
                    mul
                    addd      1,s
                    std       1,s
                    bhs       b52@
                    inc       ,s
b52@                lda       4,s
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
                    fcb       $83,$00,$00,$27,$0A,$34,$06
                    fcs       /2~od/
                    fcc       /oa ./
* DivByZero: divisor 0: errno and signal $2D to self via SendSelfSignal
DivByZero           puls      a,b
                    std       ,s
                    ldd       #$002D
                    lbra      SendSelfSignal
* DivInt: C library signed 16-bit divide: word on the stack / D, quotient in D, remainder in X
DivInt              subd      #$0000
                    beq       DivByZero
                    pshs      a,b
                    leas      -2,s
                    clr       ,s
                    clr       1,s
                    tsta
                    bpl       a53@
                    nega
                    negb
                    sbca      #$00
                    com       1,s
                    std       2,s
a53@                ldd       6,s
                    bpl       b53@
                    nega
                    negb
                    sbca      #$00
                    com       1,s
                    std       6,s
b53@                lda       #$01
c53@                inca
                    asl       3,s
                    rol       2,s
                    bpl       c53@
                    sta       ,s
                    ldd       6,s
                    clr       6,s
                    clr       7,s
* d53@: shift-subtract division loop
d53@                subd      2,s
                    bhs       e53@
                    addd      2,s
                    andcc     #$FE
                    bra       f53@
e53@                orcc      #$01
f53@                rol       7,s
                    rol       6,s
                    lsr       2,s
                    ror       3,s
                    dec       ,s
                    bne       d53@
                    std       2,s
                    tst       1,s
                    beq       g53@
                    ldd       6,s
                    nega
                    negb
                    sbca      #$00
                    std       6,s
* g53@: returns quotient in D, remainder in X
g53@                ldx       4,s
                    ldd       6,s
                    std       4,s
                    stx       6,s
                    ldx       2,s
                    ldd       4,s
                    leas      6,s
                    rts
* ShiftRightN: arithmetic shift right of the stacked word by B
ShiftRightN         tstb
                    beq       ShiftResultRet
a54@                asr       2,s
                    ror       3,s
                    decb
                    bne       a54@
                    bra       ShiftResultRet
                    fcb       $5D,$27,$07
                    fcs       /dbfcZ&y/
* ShiftResultRet: common tail of ShiftRightN/ShiftLeftN: returns the shifted word in D, drops the arg
ShiftResultRet      ldd       2,s
                    pshs      a,b
                    ldd       2,s
                    std       4,s
                    ldd       ,s
                    leas      4,s
                    rts
* ShiftLeftN: shift left of the stacked word by B
ShiftLeftN          tstb
                    beq       ShiftResultRet
a55@                asl       3,s
                    rol       2,s
                    decb
                    bne       a55@
                    bra       ShiftResultRet
* SendSelfSignal: errno = D, F$ID then F$Send signal B to the own process (divide-by-zero trap, B = $2D)
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
                    fcc       /s9s/
                    fcb       $00

                    emod
eom                 equ       *
                    end
