********************************************************************
* s9k - Studio-9 KeyPad Input Editor overlay: note entry from the keyboard
* Ported from the UltiMusE III 10.11.4e module (disassembled byte-exact). Routine, global
* and vector names come from Mike Knudsen's C source (kp.c, kpsubs.c, virt3.c; bdp.c,
* bglob.c and fcnptrs.h for the data, defined in equates.asm with the pct*/pctn* printf
* formats). Local labels read a<n>@, b<n>@: the letter is the label, n the routine.
* Event pages hold 928 records ($03A0), not the original 1020, so a page fits the $1D00
* visible bytes of DAT slot 7; i2p's page divide carries the constant.
*
* `start` lbra's to kpmain, which s9 calls and which returns to it. s9 services come through
* the vector table from $0351: [pprintf] printf, [psoowee] run an overlay (called 'S','s' to
* redraw the score), [paddbars] add a bar, [pbeep] beep (the 10.11 extra entry), [pflush]
* flush the pipe to s9gui before each key read, [ppswap] load an event page, [pcod2raw]
* ticks of a duration, [penter]/[pchip]/[pfulltime] insert / replace a note record,
* [ppluspart]/[paddclone] free chord slot / clone a part, [prepart] repart(), [pyesno]
* yes/no box, [palert] error box, [pexprmenu] expression menu.
* Data model: the score is a run of 8-byte note records (byte0 part, 0 = empty slot; word1
* time; byte3 duration code; byte4 dots; byte5 pitch step or $20 = rest; byte6 accidental;
* byte7 articulation) in 928-record pages; i2p/plusplus/decdec maintain <curind, <curevp,
* the page bounds <database/<curptop, <curpage and the record count <nevents. kpind is the
* keypad cursor index; grafxes/grafyes hold the x/y of every displayed record (indexed by
* index-xyoff), lftind/ritind bound the displayed range; partstaff reads parts/staves/clefs.
* Main loop (KpMainLoop): kpickup loads the record under the cursor into the entry globals,
* the score is redrawn when rfr_scr is set, kpcurse (bytblt mode 3) marks the cursor and
* ReadPath reads one key. Characters of strNoteChars are collected by kpbuffit; space/Enter
* parse the line with kparse (duration v w/1 h/2 q/4 8 16/6 32/3 64 128, dots . .. /3 _,
* letter a-g or r, accidental # x N F FF (also z S p - = H), octave 0-7 or + u - d = o with
* an optional o prefix, articulation t l n m s, leading y = keep current) into
* kpdur/kpdmod/kpnotch/kpitmod/kpoctch/kpartic. kprocess builds the 5-byte template at
* brush, computes the staff step (auto-octave with option o), replaces the note or stacks a
* chord note (options c/a), and kpmove 'a' advances by the note's ticks, adding a bar at
* the end unless option p is set.
* Command keys on an empty line (KpKeyDispatch): Q/k quit, arrows (kpmove), space advance,
* = next record, ^U/^X back, G goto (Entry / last Mouse / Keypad exit / Action), ? show the
* note, P pick up, D/Y re-enter, +/C and -/B chord mode on/off, < > scroll, H redraw, L/R
* page, M or any other key = kpmen (options o p y c a, move mode h v b, info pages i n,
* e = expression insert).
* Runtime tail: bytblt (graphics command in DP arg0..arg5 = $95-$9A), CopyNoteP, index,
* MulInt16, DivInt16, ReadPath, SleepTicks, ErrnoReturn (errno at $034F). The bytes after
* ErrnoReturn are the original initial-data image (format strings, tables, padding).

                    nam       s9k
                    ttl       s9k (disassembly)

                  IFP1
                    use       defsfile
                  ENDC
UME_SCOPE_S9K                  equ       1
                    use       equates.asm

tylg                set       $11
atrv                set       $81
size                equ       $104C



                    mod       eom,name,tylg,atrv,start,size
name                fcs       /s9k/
                    fcb       $07
start               equ       *
                    lbra      kpmain
                    fcb       $39,$0D,$00
* kpmove(cmd, part, ticks): moves the keypad cursor: 'u'/'d' previous/next non-empty record, 'l'/'r' previous/next record of the part, 'a' advance by ticks; part < 0 = the cursor record's part
kpmove          pshs      u
                    leas      -3,s
                    clra
                    clrb
                    stb       ,s
                    ldd       >kpind
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    tfr       d,u
                    ldd       9,s
                    bge       a1@
                    ldb       ,u
                    sex
                    std       9,s
a1@                 ldd       11,s
                    addd      1,u
                    std       11,s
                    ldb       8,s
                    sex
                    tfr       d,x
                    lbra      MoveDispatch
* MoveUpLoop: 'u': decdec until a record with a part (byte0 != 0); stops at index 0
MoveUpLoop          lbsr      decdec
                    tfr       d,u
                    ldb       ,u
                    lbne      MoveDone
                    ldd       <curind
                    bge       MoveUpLoop
                    clra
                    clrb
                    bra       MoveClampIndex
* MoveDownLoop: 'd': plusplus until a record with a part; clamps to count-1
MoveDownLoop        lbsr      plusplus
                    tfr       d,u
                    ldb       ,u
                    lbne      MoveDone
                    ldd       <curind
                    cmpd      <nevents
                    blt       MoveDownLoop
                    ldd       <nevents
                    addd      #$FFFF
* MoveClampIndex: MoveUpLoop bra's here with 0, MoveDownLoop falls in with count-1
MoveClampIndex      std       <curind
                    lbra      MoveDone
* MoveLeftStep: 'l' body: decdec and compare byte0 with the wanted part
MoveLeftStep        lbsr      decdec
                    tfr       d,u
                    ldb       ,u
                    sex
                    cmpd      9,s
                    lbeq      MoveDone
* MoveLeftLoop: 'l' loop head: continue while <curind >= 0
MoveLeftLoop        ldd       <curind
                    bge       MoveLeftStep
                    lbra      MoveDone
* MoveRightStep: 'r' body: plusplus and compare byte0 with the wanted part
MoveRightStep       lbsr      plusplus
                    tfr       d,u
                    ldb       ,u
                    sex
                    cmpd      9,s
                    lbeq      MoveDone
* MoveRightLoop: 'r' loop head: continue while <curind < <nevents (record count)
MoveRightLoop       ldd       <curind
                    cmpd      <nevents
                    blt       MoveRightStep
                    lbra      MoveDone
* AdvanceCursor: 'a' entry: mode kpmode 'v' -> AdvanceVertLoop, else AdvanceHorzLoop
AdvanceCursor       ldb       >kpmode
                    cmpb      #$76
                    bne      AdvanceHorzLoop
* AdvanceVertLoop: vertical advance: plusplus; at the end clamps and adds a bar via [paddbars] once (unless autopick); stops at the next note unless chord/add mode skips parts with flag bit 2
AdvanceVertLoop     lbsr      plusplus
                    tfr       d,u
                    ldd       <curind
                    cmpd      <nevents
                    blt       AdvVertCheck
                    ldd       <nevents
                    addd      #$FFFF
                    std       <curind
                    std       >kpind
                    ldb       >autopick
                    lbne      MoveDone
                    ldb       ,s
                    lbne      MoveDone
                    jsr       [>paddbars]
                    ldd       #$0001
                    stb       ,s
                    ldd       >kpind
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    tfr       d,u
                    bra       AdvanceVertLoop
* AdvVertCheck: skip empty records; without chord (kpclone) or add (autoclone) mode stop at the first note
AdvVertCheck        ldb       ,u
                    ble      AdvanceVertLoop
                    ldb       >kpclone
                    bne       AdvVertPartFlag
                    ldb       >autoclone
                    lbeq      MoveDone
* AdvVertPartFlag: reads the part table parts[byte0] flags; bit 2 set -> keep advancing
AdvVertPartFlag     ldb       ,u
                    sex
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #parts
                    leax      d,x
                    ldd       2,x
                    clra
                    andb      #$04
                    bne      AdvanceVertLoop
                    lbra      MoveDone
* AdvanceHorzLoop: horizontal ('h'/'b') advance: plusplus; at the end adds a bar once ([paddbars], not when autopick or the part flag bit 2), in 'b' mode steps once more
AdvanceHorzLoop     lbsr      plusplus
                    tfr       d,u
                    ldd       <curind
                    cmpd      <nevents
                    blt       AdvSamePart
                    ldd       <nevents
                    addd      #$FFFF
                    std       <curind
                    std       >kpind
                    ldb       >autopick
                    lbne      MoveDone
                    ldb       ,s
                    lbne      MoveDone
                    ldd       9,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #parts
                    leax      d,x
                    ldd       2,x
                    clra
                    andb      #$04
                    lbne      MoveDone
                    jsr       [>paddbars]
                    ldd       #$0001
                    stb       ,s
                    ldd       >kpind
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    tfr       d,u
                    ldb       >kpmode
                    cmpb      #$62
                    bne       AdvSamePart
                    lbsr      plusplus
                    tfr       d,u
* AdvSamePart: record of the wanted part: in 'h' mode keep going until its time (word1) reaches the target time (11,s)
AdvSamePart         ldb       ,u
                    sex
                    cmpd      9,s
                    bne       AdvOtherPart
                    ldb       >kpmode
                    cmpb      #$68
                    bne      MoveDone
                    ldd       1,u
                    subd      11,s
                    std       1,s
                    blt      AdvanceHorzLoop
                    bra      MoveDone
* AdvOtherPart: record of another part: only in 'b' mode take it if anybar, cycling the part number 1..<nparts
AdvOtherPart        ldb       >kpmode
                    cmpb      #$62
                    bne      AdvanceHorzLoop
                    pshs      u
                    lbsr      anybar
                    std       ,s++
                    lbeq      AdvanceHorzLoop
                    ldd       9,s
                    addd      #$0001
                    std       9,s
                    cmpd      >nparts
                    ble       AdvBackLoop
                    ldd       #$0001
                    std       9,s
                    lbra      AdvanceHorzLoop
* AdvBackStep: 'b' mode: decdec back to the previous anybar record, then AdvanceHorzLoop
AdvBackStep         lbsr      decdec
                    tfr       d,u
                    pshs      u
                    lbsr      anybar
                    std       ,s++
                    beq       AdvBackLoop
                    lbra      AdvanceHorzLoop
* AdvBackLoop: loop head of AdvBackStep: continue while <curind > 0
AdvBackLoop         ldd       <curind
                    bgt       AdvBackStep
                    lbra      AdvanceHorzLoop
* MoveBadCmd: unknown command character: bell and finish
MoveBadCmd          lbsr      bell
                    bra       MoveDone
* MoveDispatch: dispatch on the command char: u, d, l, r, a
MoveDispatch        cmpx      #$0075
                    lbeq      MoveUpLoop
                    cmpx      #$0064
                    lbeq      MoveDownLoop
                    cmpx      #$006C
                    lbeq      MoveLeftLoop
                    cmpx      #$0072
                    lbeq      MoveRightLoop
                    cmpx      #$0061
                    lbeq      AdvanceCursor
                    bra       MoveBadCmd
* MoveDone: common exit: kpind = <curind clamped to count-1
MoveDone            ldd       <curind
                    std       >kpind
                    cmpd      <nevents
                    blt       a2@
                    ldd       <nevents
                    addd      #$FFFF
                    std       <curind
                    std       >kpind
a2@                 leas      3,s
                    puls      u,pc
* kpcurse(index): if index is within lftind..ritind draws a bytblt mode-3 box around the record's screen position (x from grafxes, y from grafyes, index-xyoff; rests and marks nudged); returns 1, or 0 when off screen
kpcurse       pshs      a,b,x,y,u
                    ldd       10,s
                    cmpd      >lftind
                    blt       BoxOffScreen
                    ldd       10,s
                    cmpd      >ritind
                    ble       BoxOnScreen
* BoxOffScreen: index not displayed: return 0
BoxOffScreen        clra
                    clrb
                    lbra      DrawCursorBoxRet
* BoxOnScreen: fetch x (grafxes) and y (grafyes) of the record; y 0 -> default $B5
BoxOnScreen         ldd       10,s
                    subd      >xyoff
                    ldx       #grafxes
                    leax      d,x
                    ldb       ,x
                    sex
                    std       4,s
                    ldd       10,s
                    subd      >xyoff
                    ldx       #grafyes
                    leax      d,x
                    ldb       ,x
                    clra
                    std       2,s
                    ldd       4,s
                    addd      #$FFFF
                    std       ,s
                    ldd       2,s
                    bne       BoxRestOffset
                    ldd       #$00B5
* BoxSetY: store the adjusted y and draw
BoxSetY             std       2,s
                    bra       BoxDraw
* BoxRestOffset: a rest (byte5 = $20) in a part: y += 3 for duration code 1 (whole rest) else 1
BoxRestOffset       ldd       10,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    tfr       d,u
                    ldb       ,u
                    beq       BoxSymOffset
                    ldb       5,u
                    cmpb      #$20
                    bne       BoxSymOffset
                    ldd       2,s
                    pshs      a,b
                    ldb       3,u
                    cmpb      #$01
                    bne       a3@
                    ldd       #$0003
                    bra       b3@
a3@                 ldd       #$0001
b3@                 addd      ,s++
                    bra       BoxSetY
* BoxSymOffset: empty-part record with ispwexpr symbol: box starts one unit further right
BoxSymOffset        ldb       ,u
                    bne       BoxDraw
                    ldb       5,u
                    sex
                    pshs      a,b
                    lbsr      ispwexpr
                    leas      2,s
                    beq       BoxDraw
                    ldd       ,s
                    addd      #$0001
                    std       ,s
* BoxDraw: bytblt(3, x-1, y-3, x+1, y+3) and return 1
BoxDraw             ldd       2,s
                    addd      #$0003
                    pshs      a,b
                    ldd       6,s
                    addd      #$0001
                    pshs      a,b
                    ldd       6,s
                    addd      #$FFFD
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    ldd       #$0003
                    pshs      a,b
                    lbsr      bytblt
                    leas      10,s
                    ldd       #$0001
* DrawCursorBoxRet: kpcurse exit: BoxOffScreen lbra's here with 0, BoxDraw falls in with 1
DrawCursorBoxRet    leas      6,s
                    puls      u,pc
* kpbuffit(start, ptr, key): edits the note line: $08 steps back, ^U/^X ($15/$18) kill the line, other keys append (limit 80, else bell) with a NUL terminator; echoes via [pputchar]; returns the new pointer
kpbuffit         pshs      u
                    ldb       9,s
                    cmpb      #$08
                    bne       EditNotBackspace
                    ldd       6,s
                    addd      #$FFFF
* EditSetPtr: store the new line pointer, then echo
EditSetPtr          std       6,s
* EditEchoKey: echo the key through [pputchar] and return the pointer
EditEchoKey         ldb       9,s
                    sex
                    pshs      a,b
                    jsr       [>pputchar]
                    leas      2,s
                    bra       LineEditKeyRet
* EditNotBackspace: ^U/^X -> EditKillLine, else EditAddChar
EditNotBackspace    ldb       9,s
                    cmpb      #$15
                    beq       EditKillLine
                    ldb       9,s
                    cmpb      #$18
                    bne       EditAddChar
* EditKillLine: ^U/^X: pointer back to the line start
EditKillLine        ldd       4,s
                    bra       EditSetPtr
* EditAddChar: append the key if the line is shorter than 80, NUL-terminate
EditAddChar         ldd       6,s
                    subd      4,s
                    cmpd      #$0050
                    bge       EditLineFull
                    ldb       9,s
                    ldx       6,s
                    leax      1,x
                    stx       6,s
                    stb       -1,x
                    clra
                    clrb
                    stb       [<$06,s]
                    bra       EditEchoKey
* EditLineFull: line full: bell
EditLineFull        lbsr      bell
* LineEditKeyRet: kpbuffit exit, D = line pointer
LineEditKeyRet      ldd       6,s
                    puls      u,pc
* kpickup(pickup): loads the record under kpind into the entry globals: byte5 -> kvslot; with pickup, autopick or stacking copies bytes 3,4,7 -> kpdur,kpdmod,kpartic; the pitch comes from the record (pickup/autopick) or [prepart] (pitcarry/stacking) and is split into kpoctave/kpoctch/kpnotch/kplnotenum
kpickup     pshs      u
                    leas      -11,s
                    ldd       >kpind
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    tfr       d,u
                    ldb       ,u
                    sex
                    std       9,s
                    ldb       5,u
                    sex
                    std       >kvslot
                    ldb       >kpclone
                    bne       a4@
                    ldb       >autoclone
                    beq       b4@
a4@                 ldd       >kvslot
                    cmpd      #$0020
                    beq       b4@
                    ldd       #$0001
                    bra       c4@
b4@                 clra
                    clrb
c4@                 stb       ,s
                    ldb       <$10,s
                    bne       d4@
                    ldb       >autopick
                    bne       d4@
                    ldb       ,s
                    beq       FetchPitchStage
d4@                 ldd       9,s
                    bne       FetchDurArtic
                    ldb       <$10,s
                    lbeq      FetchDone
                    lbsr      bell
                    lbra      FetchDone
* FetchDurArtic: copy record bytes 3/4/7 into duration kpdur, dots kpdmod, articulation kpartic
FetchDurArtic       ldb       3,u
                    sex
                    std       >kpdur
                    ldb       4,u
                    sex
                    std       >kpdmod
                    ldb       7,u
                    sex
                    std       >kpartic
* FetchPitchStage: pitch only with pickup, autopick, kpclone, autoclone or pitcarry, else FetchDone
FetchPitchStage     ldb       <$10,s
                    bne       a5@
                    ldb       >autopick
                    bne       a5@
                    ldb       >kpclone
                    bne       a5@
                    ldb       >autoclone
                    bne       a5@
                    ldb       >pitcarry
                    lbeq      FetchDone
a5@                 ldb       <$10,s
                    bne       FetchRawPitch
                    ldb       >autopick
                    beq       FetchOptYPitch
* FetchRawPitch: pickup or option p: accidental kpitmod from byte6, step from byte5 (kvslot)
FetchRawPitch       ldb       6,u
                    sex
                    std       >kpitmod
                    ldd       >kvslot
                    std       1,s
                    bra       FetchRestCheck
* FetchOptYPitch: neither pickup nor option p: needs option y (pitcarry) and chord/add mode or kpmode 'v'
FetchOptYPitch      ldb       >pitcarry
                    lbeq      FetchDone
                    ldb       >kpclone
                    bne       FetchStackSlot
                    ldb       >autoclone
                    bne       FetchStackSlot
                    ldb       >kpmode
                    cmpb      #$76
                    lbne      FetchDone
* FetchStackSlot: when stacking: part = [ppluspart](kpind) free chord slot, exit if none
FetchStackSlot      ldb       ,s
                    beq       FetchStepPitch
                    ldd       >kpind
                    pshs      a,b
                    jsr       [>ppluspart]
                    leas      2,s
                    std       9,s
                    lbeq      FetchDone
* FetchStepPitch: step = [prepart](kpind, part, &kpitmod) (repart; also fills kpitmod)
FetchStepPitch      ldx       #kpitmod
                    pshs      x
                    ldd       11,s
                    pshs      a,b
                    ldd       >kpind
                    pshs      a,b
                    jsr       [>prepart]
                    leas      6,s
                    std       1,s
* FetchRestCheck: step $20 = rest -> letter 'r' and exit
FetchRestCheck      ldd       1,s
                    cmpd      #$0020
                    bne       StepToOctLetter
                    ldd       #$0072
                    stb       >kpnotch
                    bra      FetchDone
* StepToOctLetter: partstaff clef offset (default 12): octave = (step+ofs+6)/7 clamped to 7, letter index = remainder
StepToOctLetter     leax      3,s
                    pshs      x
                    leax      7,s
                    pshs      x
                    leax      11,s
                    pshs      x
                    ldd       15,s
                    pshs      a,b
                    lbsr      partstaff
                    leas      8,s
                    ldd       5,s
                    bne       a6@
                    ldd       #$000C
                    std       5,s
a6@                 ldd       1,s
                    pshs      a,b
                    ldd       7,s
                    addd      #$0006
                    addd      ,s++
                    std       1,s
                    pshs      a,b
                    ldd       #$0007
                    lbsr      DivInt16
                    std       >kpoctave
                    ldd       1,s
                    pshs      a,b
                    ldd       >kpoctave
                    pshs      a,b
                    ldd       #$0007
                    lbsr      MulInt16
                    nega
                    negb
                    sbca      #$00
                    addd      ,s++
                    std       1,s
                    ldd       >kpoctave
                    cmpd      #$0007
                    ble       StoreOctLetter
                    ldd       #$0007
                    std       >kpoctave
* StoreOctLetter: kpoctch = '0'+octave, kpnotch = strLetters[letter], kplnotenum = letter index
StoreOctLetter      ldd       >kpoctave
                    addd      #$0030
                    stb       >kpoctch
                    leax      >strLetters,pcr
                    ldd       1,s
                    leax      d,x
                    ldb       ,x
                    stb       >kpnotch
                    ldd       1,s
                    std       >kplnotenum
* FetchDone: exit of kpickup
FetchDone           leas      11,s
                    puls      u,pc
* kprint(buf): formats the entry settings into buf as a note string (duration, dots, letter, accidental, octave digit, articulation letter); returns buf
kprint    pshs      u
                    ldu       4,s
                    ldd       >kpdur
                    cmpd      #8
                    bne       kpold@
                    ldd       #$3132              128 needs three digits
                    std       ,u++
                    ldb       #'8
                    stb       ,u+
                    bra       FmtDurMods
kpold@              ldd       >kpdur
                    cmpd      #$0005
                    blt       FmtDurChar
                    leax      >strDurTens,pcr
                    tfr       x,d
                    pshs      a,b
                    ldd       >kpdur
                    addd      #$FFFB
                    addd      ,s++
                    tfr       d,x
                    ldb       ,x
                    stb       ,u+
* FmtDurChar: emit strDurChars[kpdur]
FmtDurChar          leax      >strDurChars,pcr
                    ldd       >kpdur
                    leax      d,x
                    ldb       ,x
                    stb       ,u+
FmtDurMods          equ       *
                    ldd       >kpdmod
                    cmpd      #$0002
                    bne       a7@
                    ldd       #$002E
                    bra       b7@
a7@                 ldd       >kpdmod
                    cmpd      #$0003
                    bne       FmtDots
                    ldd       #$002F
b7@                 stb       ,u+
* FmtDots: emit the dot/triplet characters for kpdmod
FmtDots             ldd       >kpdmod
                    beq       FmtLetter
                    leax      >strDotChars,pcr
                    ldd       >kpdmod
                    leax      d,x
                    ldb       ,x
                    stb       ,u+
* FmtLetter: emit the letter kpnotch, then 'F' first for a double flat
FmtLetter           ldb       >kpnotch
                    stb       ,u+
                    ldd       >kpitmod
                    cmpd      #$0006
                    bne       FmtAccidental
                    ldd       #$0046
                    stb       ,u+
* FmtAccidental: emit strAccChars[kpitmod] for codes >= 2
FmtAccidental       ldd       >kpitmod
                    cmpd      #$0002
                    blt       FmtOctArtic
                    leax      >strAccChars,pcr
                    ldd       >kpitmod
                    leax      d,x
                    ldb       ,x
                    stb       ,u+
* FmtOctArtic: emit the octave char kpoctch and strArticChars[kpartic], NUL-terminate
FmtOctArtic         ldb       >kpoctch
                    stb       ,u+
                    leax      >strArticChars,pcr
                    ldd       >kpartic
                    leax      d,x
                    ldb       ,x
                    stb       ,u+
                    clra
                    clrb
                    stb       ,u
                    ldd       4,s
                    puls      u,pc
* kprocess(stack): enters the parsed note at the cursor: ticks = [pcod2raw](dur, dots), fills the 5-byte template at brush, resolves the octave (digit, +/-/=, or AutoOctave) and the staff step, then stacks a chord note (stack != 0) or replaces the note; returns ticks, 0 on failure
kprocess           pshs      u
                    leas      <-$24,s
                    leax      >strLetters2,pcr
                    stx       <$1D,s
                    ldd       >kpind
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    std       ,s
                    ldb       [,s]
                    sex
                    std       10,s
                    bne       EnterNoteInfo
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgMustOverlay,pcr
                    pshs      x
                    jsr       [>palert]
                    leas      4,s
                    lbra      EnterNoteFail
* EnterNoteInfo: record found: byte5, table index kpind-xyoff, its x/y, partstaff of the part (clef offset default 12)
EnterNoteInfo       ldx       ,s
                    ldb       5,x
                    sex
                    std       <$16,s
                    ldd       >kpind
                    subd      >xyoff
                    std       <$10,s
                    ldx       #grafxes
                    leax      d,x
                    ldb       ,x
                    sex
                    std       <$14,s
                    ldd       <$10,s
                    ldx       #grafyes
                    leax      d,x
                    ldb       ,x
                    clra
                    std       <$12,s
                    leax      4,s
                    pshs      x
                    leax      8,s
                    pshs      x
                    leax      12,s
                    pshs      x
                    ldd       <$10,s
                    pshs      a,b
                    lbsr      partstaff
                    leas      8,s
                    std       12,s
                    ldd       6,s
                    bne       BuildNoteTemplate
                    ldd       #$000C
                    std       6,s
* BuildNoteTemplate: ticks = [pcod2raw](dur, dots); brush bytes 0,1,3,4 = dur, dots, accidental, articulation; reset kpitmod = 0 and kpartic = 2 for the next entry; letter index via index
BuildNoteTemplate   ldd       >kpdmod
                    pshs      a,b
                    ldd       >kpdur
                    pshs      a,b
                    jsr       [>pcod2raw]
                    leas      4,s
                    std       <$1B,s
                    ldu       #brush
                    ldd       >kpdur
                    stb       ,u
                    ldd       >kpdmod
                    stb       1,u
                    ldd       >kpartic
                    stb       4,u
                    ldd       >kpitmod
                    stb       3,u
                    clra
                    clrb
                    std       >kpitmod
                    ldd       #$0002
                    std       >kpartic
                    ldb       >kpnotch
                    cmpb      #$72
                    beq       EnterOctave
                    ldb       >kpnotch
                    sex
                    pshs      a,b
                    ldd       <$1F,s
                    pshs      a,b
                    lbsr      index
                    leas      4,s
                    subd      <$1D,s
                    std       2,s
* EnterOctave: octave char '0'..'7' -> absolute octave kpoctave, else EnterOctDispatch
EnterOctave         ldb       >kpoctch
                    cmpb      #$30
                    blt       EnterOctNonDigit
                    ldb       >kpoctch
                    cmpb      #$37
                    bgt       EnterOctNonDigit
                    ldb       >kpoctch
                    sex
                    addd      #$FFD0
* StoreOctave: store the computed octave and go clamp it
StoreOctave         std       >kpoctave
                    bra      ClampOctave
* EnterOctNonDigit: kpoctch not '0'..'7': char into X, EnterOctDispatch
EnterOctNonDigit    ldb       >kpoctch
                    sex
                    tfr       d,x
                    bra       EnterOctDispatch
* OctaveUp: '+': octave + 1
OctaveUp            ldd       >kpoctave
                    addd      #$0001
                    bra       StoreOctave
* OctaveSame: '=': keep the octave
OctaveSame          ldd       >kpoctave
                    bra       ClampOctave
* AutoOctave: no octave given and option o (autooct): letter difference to the last note (kplnotenum) <= -4 -> octave+1, >= 4 -> octave-1 (nearest octave)
AutoOctave          ldb       >kpnotch
                    cmpb      #$72
                    beq       ClampOctave
                    ldb       >autooct
                    beq       ClampOctave
                    ldb       >kpnotch
                    sex
                    pshs      a,b
                    ldd       <$1F,s
                    pshs      a,b
                    lbsr      index
                    leas      4,s
                    subd      <$1D,s
                    std       2,s
                    subd      >kplnotenum
                    std       14,s
                    cmpd      #$FFFC
                    bgt       a8@
                    ldd       >kpoctave
                    addd      #$0001
                    bra      StoreOctave
a8@                 ldd       14,s
                    cmpd      #$0004
                    blt       ClampOctave
* OctaveDown: '-': octave - 1
OctaveDown          ldd       >kpoctave
                    addd      #$FFFF
                    bra      StoreOctave
* EnterOctDispatch: dispatch on the octave char: '+', '-', '=', none
EnterOctDispatch    cmpx      #$002B
                    beq       OctaveUp
                    cmpx      #$002D
                    beq       OctaveDown
                    cmpx      #$003D
                    beq       OctaveSame
                    stx       -2,s
                    beq       AutoOctave
* ClampOctave: clamp kpoctave to 0..7; remember the letter index in kplnotenum for a note
ClampOctave         ldd       >kpoctave
                    bge       a9@
                    clra
                    clrb
                    std       >kpoctave
a9@                 ldd       >kpoctave
                    cmpd      #$0007
                    ble       b9@
                    ldd       #$0007
                    std       >kpoctave
b9@                 ldb       >kpnotch
                    cmpb      #$72
                    beq       RestOrStep
                    ldd       2,s
                    std       >kplnotenum
* RestOrStep: rest -> step $20, else CalcNoteStep
RestOrStep          ldb       >kpnotch
                    cmpb      #$72
                    bne       CalcNoteStep
                    ldd       #$0020
                    bra       StoreStep
* CalcNoteStep: step = letter + (octave-1)*7 + 1 - clef offset (MulInt16)
CalcNoteStep        ldd       2,s
                    pshs      a,b
                    ldd       >kpoctave
                    addd      #$FFFF
                    pshs      a,b
                    ldd       #$0007
                    lbsr      MulInt16
                    addd      #$0001
                    addd      ,s++
                    std       2,s
                    subd      6,s
* StoreStep: template byte2 = step; stacking arg -> find a free slot [ppluspart], else replace
StoreStep           stb       2,u
                    ldb       <$29,s
                    lbeq      ReplaceNote
                    ldd       >kpind
                    pshs      a,b
                    jsr       [>ppluspart]
                    leas      2,s
                    std       10,s
                    beq       TryClonePart
                    ldd       4,s
                    orb       #$04
                    std       4,s
                    bra       StackInsert
* TryClonePart: no free slot and chord option c: [paddclone] clones a part for the note
TryClonePart        ldb       >kpclone
                    beq       StackNoRoom
                    ldd       4,s
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    jsr       [>paddclone]
                    leas      4,s
                    std       10,s
                    bne       StackInsert
* StackNoRoom: no room: kpmove('a', -1, ticks) and return 0
StackNoRoom         ldd       <$1B,s
                    pshs      a,b
                    ldd       #$FFFF
                    pshs      a,b
                    ldd       #$0061
                    pshs      a,b
                    lbsr      kpmove
                    leas      6,s
                    bra       EnterNoteFail
* StackInsert: [pfulltime] then [penter] insert a new record for the chord note; negative result = failure
StackInsert         ldb       2,u
                    sex
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    ldd       >kpind
                    pshs      a,b
                    jsr       [>pfulltime]
                    leas      2,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    jsr       [>penter]
                    leas      8,s
                    std       <$19,s
                    bge       StackCopyShift
* EnterNoteFail: return 0
EnterNoteFail       clra
                    clrb
                    lbra      EnterNoteRet
* StackCopyShift: CopyNoteP into the new record, shift the x/y tables grafxes/grafyes up by one from ritind down to the new index, ritind++
StackCopyShift      pshs      u
                    ldd       <$1B,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    addd      #$0003
                    pshs      a,b
                    lbsr      CopyNoteP
                    leas      4,s
                    ldd       <$19,s
                    subd      >xyoff
                    std       <$10,s
                    ldd       >ritind
                    subd      >xyoff
                    bra       ShiftXYTest
* ShiftXYLoop: loop moving one x/y table entry
ShiftXYLoop         ldd       14,s
                    addd      #$0001
                    ldx       #grafxes
                    leax      d,x
                    pshs      x
                    ldd       <$10,s
                    ldx       #grafxes
                    leax      d,x
                    ldb       ,x
                    stb       [,s++]
                    ldd       14,s
                    addd      #$0001
                    ldx       #grafyes
                    leax      d,x
                    pshs      x
                    ldd       <$10,s
                    ldx       #grafyes
                    leax      d,x
                    ldb       ,x
                    stb       [,s++]
                    ldd       14,s
                    addd      #$FFFF
* ShiftXYTest: loop test of ShiftXYLoop (entered with ritind-xyoff)
ShiftXYTest         std       14,s
                    ldd       14,s
                    cmpd      <$10,s
                    bge       ShiftXYLoop
                    ldd       >ritind
                    addd      #$0001
                    std       >ritind
                    ldd       <$10,s
                    ldx       #grafxes
                    leax      d,x
                    ldd       <$14,s
                    stb       ,x
                    clra
                    clrb
                    stb       >rfr_scr
                    lbra      DrawNewSymbol
* ReplaceNote: non-stacking path: erase the old symbol and replace the record's note
ReplaceNote         ldd       4,s
                    clra
                    andb      #$01
                    bne       c10@
                    ldd       4,s
                    clra
                    andb      #$02
                    beq       b10@
a10@                ldd       #$0001
                    bra       EraseOldSymbol
b10@                ldd       <$16,s
                    cmpd      #$0004
                    bgt       a10@
c10@                clra
                    clrb
* EraseOldSymbol: [pdrawnr](..., 0) erases the old symbol, then rfr_scr = (old ticks != new ticks)
EraseOldSymbol      stb       <$18,s
                    clra
                    clrb
                    pshs      a,b
                    ldd       6,s
                    clra
                    andb      #$04
                    pshs      a,b
                    ldb       <$1C,s
                    sex
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    ldd       <$1A,s
                    pshs      a,b
                    ldd       <$1E,s
                    pshs      a,b
                    ldd       12,s
                    addd      #$0003
                    pshs      a,b
                    jsr       [>pdrawnr]
                    leas      14,s
                    ldx       ,s
                    ldb       4,x
                    sex
                    pshs      a,b
                    ldx       2,s
                    ldb       3,x
                    sex
                    pshs      a,b
                    jsr       [>pcod2raw]
                    leas      4,s
                    cmpd      <$1B,s
                    beq       a11@
                    ldd       #$0001
                    bra       StoreNewNote
a11@                clra
                    clrb
* StoreNewNote: CopyNoteP brush to a local buffer, [pchip](kpind, &buf, ticks, part) replaces the note, undind = -1, kpartic 0 -> 2
StoreNewNote        stb       >rfr_scr
                    pshs      u
                    leax      <$21,s
                    pshs      x
                    lbsr      CopyNoteP
                    leas      4,s
                    ldd       10,s
                    pshs      a,b
                    ldd       <$1D,s
                    pshs      a,b
                    leax      <$23,s
                    pshs      x
                    ldd       >kpind
                    pshs      a,b
                    jsr       [>pchip]
                    leas      8,s
                    ldd       #$FFFF
                    std       >undind
                    ldd       >kpartic
                    bne       DrawNewSymbol
                    ldd       #$0002
                    std       >kpartic
* DrawNewSymbol: no full redraw needed: compute the new y from the step and [pdrawnr](1, ...) draws the note, store y in grafyes
DrawNewSymbol       ldb       >rfr_scr
                    lbne      EnterNoteTail
                    ldb       2,u
                    sex
                    std       <$16,s
                    cmpd      #$0020
                    bne       d12@
                    ldd       4,s
                    clra
                    andb      #$01
                    beq       a12@
                    ldd       #$0008
                    bra       c12@
a12@                ldd       4,s
                    clra
                    andb      #$02
                    beq       b12@
                    ldd       #$FFF8
                    bra       c12@
b12@                clra
                    clrb
c12@                addd      8,s
                    bra       e12@
d12@                ldd       8,s
                    addd      <$16,s
                    addd      <$16,s
e12@                std       <$12,s
                    ldd       4,s
                    clra
                    andb      #$01
                    bne       h12@
                    ldd       4,s
                    clra
                    andb      #$02
                    beq       g12@
f12@                ldd       #$0001
                    bra       i12@
g12@                ldd       <$16,s
                    cmpd      #$0004
                    bgt       f12@
h12@                clra
                    clrb
i12@                stb       <$18,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       6,s
                    clra
                    andb      #$04
                    pshs      a,b
                    ldb       <$1C,s
                    sex
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    ldd       <$1A,s
                    pshs      a,b
                    ldd       <$1E,s
                    pshs      a,b
                    pshs      u
                    jsr       [>pdrawnr]
                    leas      14,s
                    ldd       <$10,s
                    ldx       #grafyes
                    leax      d,x
                    ldd       <$12,s
                    stb       ,x
* EnterNoteTail: option a (autoclone): if no free slot remains, advance by ticks
EnterNoteTail       ldb       >autoclone
                    beq       EnterNoteDone
                    ldd       >kpind
                    pshs      a,b
                    jsr       [>ppluspart]
                    std       ,s++
                    bne       EnterNoteDone
                    ldd       <$1B,s
                    pshs      a,b
                    ldd       #$FFFF
                    pshs      a,b
                    ldd       #$0061
                    pshs      a,b
                    lbsr      kpmove
                    leas      6,s
* EnterNoteDone: brush+4 = 2, brush+3 = 0, return ticks
EnterNoteDone       ldd       #$0002
                    stb       >brush+4
                    clra
                    clrb
                    stb       >brush+3
                    ldd       <$1B,s
* EnterNoteRet: kprocess exit: EnterNoteFail lbra's here with 0, EnterNoteDone falls in with ticks
EnterNoteRet        leas      <$24,s
                    puls      u,pc
* kparse(str): parses a note string into kpdur (duration), kpdmod (dots/triplet), kpnotch (letter a-g/r), kpitmod (accidental), kpoctch (octave char), kpartic (articulation); a leading 'y' skips parsing; returns 1 if the string ends at NUL/space/CR, 0 if characters remain
kparse     pshs      u
                    leas      -7,s
                    leax      >strArticChars2,pcr
                    stx       1,s
                    ldu       11,s
                    ldb       ,u+
                    stb       ,s
                    cmpb      #$79
                    bne       a13@
                    leax      7,s
                    lbra      ParseSkipY
a13@                ldd       #$0001
                    stb       6,s
                    ldb       ,s
                    sex
                    tfr       d,x
                    bra      ParseDurDispatch
* DurCodeV: 'v' -> duration code 0
DurCodeV            clra
                    clrb
                    bra       SetDurCode
* Dur1or16: '1': '128' -> code 8, '16' -> code 5, else whole (1)
Dur1or16            ldd       ,u
                    cmpd      #$3238              128
                    bne       kp16@
                    leau      2,u
                    ldd       #8
                    bra       SetDurCode
kp16@               ldb       ,u
                    cmpb      #$36
                    bne       DurWhole
                    leau      1,u
                    bra       Dur16th
* DurWhole: code 1 (w / 1)
DurWhole            ldd       #$0001
                    bra       SetDurCode
* DurHalf: code 2 (h / 2)
DurHalf             ldd       #$0002
                    bra       SetDurCode
* DurQuarter: code 3 (q / 4)
DurQuarter          ldd       #$0003
                    bra       SetDurCode
* DurEighth: code 4 (8)
DurEighth           ldd       #$0004
                    bra       SetDurCode
* Dur6or64: '6': '64' -> code 7, else 16th
Dur6or64            ldb       ,u
                    cmpb      #$34
                    bne       Dur16th
                    leau      1,u
                    ldd       #$0007
                    bra       SetDurCode
* Dur16th: code 5 (16 / 6)
Dur16th             ldd       #$0005
                    bra       SetDurCode
* Dur3or32: '3' with optional '2' -> code 6
Dur3or32            ldb       ,u
                    cmpb      #$32
                    bne       Dur32nd
                    leau      1,u
* Dur32nd: code 6 (32 / 3)
Dur32nd             ldd       #$0006
* SetDurCode: store the duration code in kpdur
SetDurCode          std       >kpdur
                    bra       ParseDots
* NoDurCode: no duration typed: back up one char, clear the seen flag
NoDurCode           leau      -1,u
                    clra
                    clrb
                    stb       6,s
                    bra       ParseDots
* ParseDurDispatch: first char: v, 1/16/128, w, 2/h, 4/q, 8, 6/64, 3/32 -> duration code, else NoDurCode
ParseDurDispatch    cmpx      #$0076
                    beq      DurCodeV
                    cmpx      #$0031
                    beq       Dur1or16
                    cmpx      #$0077
                    beq       DurWhole
                    cmpx      #$0032
                    beq       DurHalf
                    cmpx      #$0068
                    beq      DurHalf
                    cmpx      #$0034
                    beq       DurQuarter
                    cmpx      #$0071
                    beq      DurQuarter
                    cmpx      #$0038
                    beq      DurEighth
                    cmpx      #$0036
                    beq      Dur6or64
                    cmpx      #$0033
                    beq       Dur3or32
                    bra       NoDurCode
* ParseDots: next char -> dots dispatch
ParseDots           ldb       ,u+
                    stb       ,s
                    sex
                    tfr       d,x
                    bra       ParseDotsDispatch
* DotsDot: '.' -> 1, '..' -> 2
DotsDot             ldb       ,u
                    cmpb      #$2E
                    bne       a14@
                    ldd       #$0002
                    std       >kpdmod
                    leau      1,u
                    bra       ParseLetter
a14@                ldd       #$0001
                    bra       SetDotsCode
* DotsTriplet: '/' with optional '3' -> code 3 (triplet)
DotsTriplet         ldb       ,u
                    cmpb      #$33
                    bne       a15@
                    leau      1,u
a15@                ldd       #$0003
                    bra       SetDotsCode
* DotsNone: '_' -> explicit no dots (0)
DotsNone            clra
                    clrb
* SetDotsCode: store the dot code in kpdmod
SetDotsCode         std       >kpdmod
                    bra       ParseLetter
* DotsDefault: no dot char: after a duration reset kpdmod unless it was a triplet; back up
DotsDefault         ldb       6,s
                    beq       a16@
                    ldd       >kpdmod
                    cmpd      #$0003
                    beq       a16@
                    clra
                    clrb
                    std       >kpdmod
a16@                leau      -1,u
                    bra       ParseLetter
* ParseDotsDispatch: dispatch '.', '/', '_'
ParseDotsDispatch   cmpx      #$002E
                    beq       DotsDot
                    cmpx      #$002F
                    beq       DotsTriplet
                    cmpx      #$005F
                    beq       DotsNone
                    bra       DotsDefault
* ParseLetter: char a..g or r -> SetLetter, else keep the old letter
ParseLetter         ldb       ,u
                    stb       ,s
                    clra
                    clrb
                    stb       6,s
                    ldb       ,s
                    cmpb      #$61
                    blt       a17@
                    ldb       ,s
                    cmpb      #$67
                    ble       SetLetter
a17@                ldb       ,s
                    cmpb      #$72
                    bne       ParseAccidental
* SetLetter: store the letter in kpnotch and set the seen flag
SetLetter           ldb       ,s
                    stb       >kpnotch
                    leau      1,u
                    ldd       #$0001
                    stb       6,s
* ParseAccidental: next char -> accidental dispatch
ParseAccidental     ldb       ,u+
                    stb       ,s
                    sex
                    tfr       d,x
                    bra      ParseAccDispatch
* AccSharp: #/z/S -> code 2; a second sharp char -> double sharp
AccSharp            ldd       #$0002
                    std       >kpitmod
                    ldb       ,u
                    cmpb      #$23
                    beq       AccDblSharp
                    ldb       ,u
                    cmpb      #$53
                    beq       AccDblSharp
                    ldb       ,u
                    cmpb      #$7A
                    bne      ParseOctave
* AccDblSharp: code 3, skip the extra char
AccDblSharp         ldd       #$0003
                    bra       SetAccSkip
* AccDblSharpX: 'x' -> code 3
AccDblSharpX        ldd       #$0003
                    bra       SetAccCode
* AccFlat: F/p/- -> code 7; a second flat char -> double flat
AccFlat             ldd       #$0007
                    std       >kpitmod
                    ldb       ,u
                    cmpb      #$46
                    beq       AccDblFlat
                    ldb       ,u
                    cmpb      #$2D
                    beq       AccDblFlat
                    ldb       ,u
                    cmpb      #$70
                    bne       ParseOctave
* AccDblFlat: code 6
AccDblFlat          ldd       #$0006
* SetAccSkip: store the accidental and skip the second char
SetAccSkip          std       >kpitmod
                    leau      1,u
                    bra       ParseOctave
* AccNatural: N/H/= -> code 4
AccNatural          ldd       #$0004
                    bra       SetAccCode
* AccNone: no accidental char: back up; clear kpitmod if a letter was typed
AccNone             leau      -1,u
                    ldb       6,s
                    beq       ParseOctave
                    clra
                    clrb
* SetAccCode: store the accidental code in kpitmod
SetAccCode          std       >kpitmod
                    bra       ParseOctave
* ParseAccDispatch: dispatch #, z, S, x, F, p, -, N, H, =
ParseAccDispatch    cmpx      #$0023
                    beq      AccSharp
                    cmpx      #$007A
                    beq      AccSharp
                    cmpx      #$0053
                    beq      AccSharp
                    cmpx      #$0078
                    beq       AccDblSharpX
                    cmpx      #$0046
                    beq       AccFlat
                    cmpx      #$0070
                    beq      AccFlat
                    cmpx      #$002D
                    beq      AccFlat
                    cmpx      #$004E
                    beq       AccNatural
                    cmpx      #$0048
                    beq      AccNatural
                    cmpx      #$003D
                    beq      AccNatural
                    bra       AccNone
* ParseOctave: optional 'o' prefix, then digit or sign
ParseOctave         ldb       ,u+
                    stb       ,s
                    clra
                    clrb
                    stb       5,s
                    ldb       ,s
                    cmpb      #$6F
                    bne       ParseOctDigit
                    ldb       ,u+
                    stb       ,s
                    ldd       #$006F
                    stb       5,s
* ParseOctDigit: '0'..'7' -> kpoctch digit, else sign dispatch
ParseOctDigit       clra
                    clrb
                    stb       >kpoctch
                    ldb       ,s
                    cmpb      #$30
                    blt       a18@
                    ldb       ,s
                    cmpb      #$37
                    bgt       a18@
                    ldb       ,s
                    stb       >kpoctch
                    bra      ParseArtic
a18@                ldb       ,s
                    sex
                    tfr       d,x
                    bra       ParseOctDispatch
* OctMinus: '-'/'d' -> '-' (octave down)
OctMinus            ldd       #$002D
                    bra       SetOctChar
* OctDownAfterO: 'n': after an 'o' prefix (5,s) octave char = '-', else OctBackup
OctDownAfterO       ldb       5,s
                    beq       OctBackup
                    ldd       #$002D
                    stb       >kpoctch
                    bra       ParseArtic
* OctPlus: '+'/'u' -> '+' (octave up)
OctPlus             ldd       #$002B
                    bra       SetOctChar
* OctEqual: '='/'o' -> '=' (same octave)
OctEqual            ldd       #$003D
* SetOctChar: store the octave char in kpoctch
SetOctChar          stb       >kpoctch
                    bra       ParseArtic
* OctDefault: other char: 'o' alone means '=', else no octave (auto)
OctDefault          ldb       5,s
                    beq       OctBackup
                    ldd       #$003D
                    stb       >kpoctch
* OctBackup: back up one char
OctBackup           leau      -1,u
                    bra       ParseArtic
* ParseOctDispatch: dispatch -, d, n, +, u, =, o
ParseOctDispatch    cmpx      #$002D
                    beq       OctMinus
                    cmpx      #$0064
                    beq      OctMinus
                    cmpx      #$006E
                    beq       OctDownAfterO
                    cmpx      #$002B
                    beq       OctPlus
                    cmpx      #$0075
                    beq      OctPlus
                    cmpx      #$003D
                    beq       OctEqual
                    cmpx      #$006F
                    beq      OctEqual
                    bra       OctDefault
* ParseArtic: char in strArticChars2 -> code 0..4 in kpartic, else back up
ParseArtic          ldb       ,u+
                    stb       ,s
                    sex
                    pshs      a,b
                    ldd       3,s
                    pshs      a,b
                    lbsr      index
                    leas      4,s
                    std       3,s
                    beq       ArticBackup
                    ldd       3,s
                    subd      1,s
                    std       >kpartic
                    bra       ParseEndCheck
* ArticBackup: no articulation char: back up
ArticBackup         leau      -1,u
                    bra       ParseEndCheck
* ParseSkipY: leading 'y': skip all parsing (no-op leas) and just check the end
ParseSkipY          leas      -7,x
* ParseEndCheck: return 1 if at NUL/space/CR else 0
ParseEndCheck       ldb       ,u
                    beq       ParseOK
                    ldb       ,u
                    cmpb      #$20
                    beq       ParseOK
                    ldb       ,u
                    cmpb      #$0D
                    bne       ParseExtra
* ParseOK: return 1
ParseOK             ldd       #$0001
                    bra       ParseNoteRet
* ParseExtra: return 0 (extra characters)
ParseExtra          clra
                    clrb
* ParseNoteRet: kparse exit: ParseOK bra's here with 1, ParseExtra falls in with 0
ParseNoteRet        leas      7,s
                    puls      u,pc
* kpmain: overlay main (start lbra's here): saves curcurse, curset(0), barwindow(30, strTitle), clamps kpind into the displayed range, then runs the key loop until Q/k
kpmain        pshs      u
                    leas      <-$67,s
                    ldd       >curcurse
                    std       <$13,s
                    clra
                    clrb
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
                    leax      >strTitle,pcr
                    pshs      x
                    ldd       #$001E
                    pshs      a,b
                    lbsr      barwindow
                    leas      4,s
                    leau      <$17,s
                    ldd       >lftind
                    addd      >ritind
                    asra
                    rorb
                    std       <$11,s
                    ldd       >kpind
                    bge       a19@
                    clra
                    clrb
                    std       >kpind
a19@                ldd       >kpind
                    ble       KpCursorToMid
                    ldd       >kpind
                    cmpd      >lftind
                    blt       KpCursorToMid
                    ldd       >kpind
                    cmpd      >ritind
                    ble       KpCursorReady
* KpCursorToMid: cursor outside the displayed range: kpind = middle of lftind..ritind
KpCursorToMid       ldd       <$11,s
                    std       >kpind
* KpCursorReady: 15,s = back position, pickup flag 11,s = 0, rfr_scr = toolson
KpCursorReady       ldd       >kpind
                    std       15,s
                    clra
                    clrb
                    stb       11,s
                    ldb       >toolson
                    stb       >rfr_scr
* KpMainLoop: kpickup(pickup flag 11,s), save dur/dots/artic/step, redraw the score via [psoowee]('S','s') when rfr_scr is set
KpMainLoop          ldb       11,s
                    sex
                    pshs      a,b
                    lbsr      kpickup
                    leas      2,s
                    clra
                    clrb
                    stb       11,s
                    ldd       >kpdur
                    std       9,s
                    ldd       >kpdmod
                    std       7,s
                    ldd       >kpartic
                    std       5,s
                    ldd       >kvslot
                    std       3,s
                    ldb       >rfr_scr
                    beq       KpDrawCursor
                    ldd       #$0073
                    pshs      a,b
                    ldd       #$0053
                    pshs      a,b
                    jsr       [>UmeData_psoowee]
                    leas      4,s
* KpDrawCursor: kpcurse; if off screen set gind/xgoal (index, column 40), redraw via [psoowee]('S','s') and draw again
KpDrawCursor        clra
                    clrb
                    stb       >rfr_scr
                    ldd       >kpind
                    pshs      a,b
                    lbsr      kpcurse
                    leas      2,s
                    bne       KpReadKey
                    ldd       >kpind
                    std       >gind
                    ldd       #$0028
                    std       >xgoal
                    ldd       #$0073
                    pshs      a,b
                    ldd       #$0053
                    pshs      a,b
                    jsr       [>UmeData_psoowee]
                    leas      4,s
                    ldd       >kpind
                    pshs      a,b
                    lbsr      kpcurse
                    leas      2,s
* KpReadKey: [pflush], ReadPath(0,&key,1), toggle the box off, index(strNoteChars, key); non-empty line -> KpLineEdit or beep, empty line -> KpEmptyLineKey
KpReadKey           jsr       [>pflush]
                    ldd       #$0001
                    pshs      a,b
                    leax      4,s
                    pshs      x
                    clra
                    clrb
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    ldd       >kpind
                    pshs      a,b
                    lbsr      kpcurse
                    leas      2,s
                    ldb       2,s
                    sex
                    pshs      a,b
                    leax      >strNoteChars,pcr
                    pshs      x
                    lbsr      index
                    leas      4,s
                    std       ,s
                    leax      <$17,s
                    pshs      x
                    cmpu      ,s++
                    lbls      KpEmptyLineKey
                    ldd       ,s
                    bne       KpLineEdit
                    ldb       2,s
                    cmpb      #$20
                    beq       KpLineEdit
                    ldb       2,s
                    cmpb      #$0D
                    beq       KpLineEdit
                    ldb       2,s
                    cmpb      #$08
                    beq       KpLineEdit
                    ldb       2,s
                    cmpb      #$15
                    beq       KpLineEdit
                    ldb       2,s
                    cmpb      #$18
                    beq       KpLineEdit
                    lbsr      bell
                    lbra      KpMainLoop
* KpLineEdit: kpbuffit on the note line; if it emptied: wkill, alcurset(0); space/CR -> KpParseLine
KpLineEdit          ldb       2,s
                    sex
                    pshs      a,b
                    pshs      u
                    leax      <$1B,s
                    pshs      x
                    lbsr      kpbuffit
                    leas      6,s
                    tfr       d,u
                    leax      <$17,s
                    pshs      x
                    cmpu      ,s++
                    bne       a20@
                    lbsr      wkill
                    clra
                    clrb
                    pshs      a,b
                    lbsr      alcurset
                    leas      2,s
                    lbra      KpMainLoop
a20@                ldb       2,s
                    cmpb      #$20
                    beq       KpParseLine
                    ldb       2,s
                    cmpb      #$0D
                    lbne      KpLoopAgain
* KpParseLine: kparse; on leftovers ask msgExtraChars via [pyesno], no -> KpResetLine
KpParseLine         lbsr      wkill
                    leax      <$17,s
                    pshs      x
                    lbsr      kparse
                    leas      2,s
                    bne       KpEnterNote
                    leax      >msgExtraChars,pcr
                    pshs      x
                    jsr       [>pyesno]
                    leas      2,s
                    beq      KpResetLine
                    bra       KpEnterNote
* KpEnterNoteEntry: entry into KpEnterNote from KpDuplicate: leas -$67,x undoes its leax $67,s stack save
KpEnterNoteEntry    leas      <-$67,x
* KpEnterNote: stacking = (chord or add option) and the cursor note is not a rest; then restore the saved dur/dots/artic of that note
KpEnterNote         ldb       >kpclone
                    bne       a21@
                    ldb       >autoclone
                    beq       b21@
a21@                ldd       3,s
                    cmpd      #$0020
                    beq       b21@
                    ldd       #$0001
                    bra       c21@
b21@                clra
                    clrb
c21@                stb       12,s
                    beq       KpInsertNote
                    ldd       9,s
                    std       >kpdur
                    ldd       7,s
                    std       >kpdmod
                    ldd       5,s
                    std       >kpartic
* KpInsertNote: kprocess(stacking) -> ticks; kplastact = cursor (last action position)
KpInsertNote        ldb       12,s
                    sex
                    pshs      a,b
                    lbsr      kprocess
                    leas      2,s
                    std       13,s
                    ldd       >kpind
                    std       >kplastact
                    ldb       >kpclone
                    bne       a22@
                    ldb       >autoclone
                    beq       KpAdvanceByNote
a22@                ldb       >kpnotch
                    cmpb      #$72
                    bne       KpResetLine
* KpAdvanceByNote: remember the position in 15,s and kpmove('a', -1, ticks); skipped in chord/add mode unless a rest
KpAdvanceByNote     ldd       >kpind
                    std       15,s
                    ldd       13,s
                    pshs      a,b
                    ldd       #$FFFF
                    pshs      a,b
                    ldd       #$0061
                    pshs      a,b
                    lbsr      kpmove
                    leas      6,s
* KpResetLine: line pointer back to the start, wkill, loop
KpResetLine         leau      <$17,s
                    lbsr      wkill
                    lbra      KpLoopAgain
* KpEmptyLineKey: empty line: a note char opens the prompt box (dialogue, alcurset(1)) and starts the line, anything else is a command key
KpEmptyLineKey      ldd       ,s
                    beq       a23@
                    clra
                    clrb
                    pshs      a,b
                    lbsr      dialogue
                    leas      2,s
                    ldd       #$0001
                    pshs      a,b
                    lbsr      alcurset
                    leas      2,s
                    ldb       2,s
                    sex
                    pshs      a,b
                    pshs      u
                    leax      <$1B,s
                    pshs      x
                    lbsr      kpbuffit
                    leas      6,s
                    tfr       d,u
                    lbra      KpMainLoop
a23@                ldb       2,s
                    sex
                    tfr       d,x
                    lbra      KpKeyDispatch
* KpQuit: 'Q'/'k': kplast = godotind = cursor, restore the window, rfr_men/rfr_rep/rfr_bar = 1, return
KpQuit              ldd       >kpind
                    std       >kplast
                    ldd       >kpind
                    std       >godotind
                    ldd       <$13,s
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
                    ldd       #$0001
                    stb       >rfr_men
                    stb       >rfr_rep
                    stb       >rfr_bar
                    lbra      KpExit
* KpRedraw: 'H': set rfr_scr so the loop redraws the score
KpRedraw            ldd       #$0001
                    stb       >rfr_scr
                    lbra      KpLoopAgain
* KpPageLR: 'L'/'R': [ppartline](key == 'R') scrolls the screen left/right
KpPageLR            ldb       2,s
                    cmpb      #$52
                    bne       a24@
                    ldd       #$0001
                    bra       b24@
a24@                clra
                    clrb
b24@                pshs      a,b
                    jsr       [>ppartline]
                    leas      2,s
                    lbra      KpLoopAgain
* KpShowNote: '?': dialogue, print msgCurrentNote + kprint + msgHitEnter, readline [pgets]
KpShowNote          leax      <$17,s
                    pshs      x
                    lbsr      kprint
                    leas      2,s
                    clra
                    clrb
                    pshs      a,b
                    lbsr      dialogue
                    leas      2,s
                    leax      >msgCurrentNote,pcr
                    pshs      x
                    jsr       [>pprintf]
                    leas      2,s
                    leax      <$17,s
                    pshs      x
                    jsr       [>pprintf]
                    leas      2,s
                    leax      >msgHitEnter,pcr
                    pshs      x
                    jsr       [>pprintf]
                    leas      2,s
                    leax      <$17,s
                    pshs      x
                    jsr       [>pgets]
                    leas      2,s
                    lbsr      wkill
                    lbra      KpLoopAgain
* KpChordOn: '+'/'C': chord mode kpclone = 1
KpChordOn           ldd       #$0001
                    bra       KpSetChord
* KpChordOff: '-'/'B': chord mode kpclone = 0
KpChordOff          clra
                    clrb
* KpSetChord: store the chord flag kpclone
KpSetChord          stb       >kpclone
                    lbra      KpLoopAgain
* KpDuplicate: 'D'/'Y': enter the current note settings again (jumps into KpEnterNote)
KpDuplicate         leax      <$67,s
                    lbra      KpEnterNoteEntry
* KpPickup: 'P': set the pickup flag so the next kpickup copies the whole note under the cursor
KpPickup            ldd       #$0001
                    stb       11,s
                    lbra      KpLoopAgain
* KpGoto: 'G': show msgGotoPrompt, read a key, GotoDispatch
KpGoto              clra
                    clrb
                    pshs      a,b
                    lbsr      dialogue
                    leas      2,s
                    leax      >msgGotoPrompt,pcr
                    pshs      x
                    jsr       [>pprintf]
                    leas      2,s
                    jsr       [>pflush]
                    ldd       #$0001
                    pshs      a,b
                    leax      4,s
                    pshs      x
                    clra
                    clrb
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    lbsr      wkill
                    ldb       2,s
                    sex
                    tfr       d,x
                    bra       GotoDispatch
* GotoEntryPos: e/E: middle of the displayed range at entry
GotoEntryPos        ldd       <$11,s
                    bra       GotoSetPos
* GotoMousePos: m/M: last mouse position lastclik
GotoMousePos        ldd       >lastclik
                    bra       GotoSetPos
* GotoExitPos: k/K: last keypad exit position kplast
GotoExitPos         ldd       >kplast
                    bra       GotoSetPos
* GotoActionPos: a/A: last action position kplastact
GotoActionPos       ldd       >kplastact
* GotoSetPos: store the chosen index in kpind
GotoSetPos          std       >kpind
                    lbra      KpLoopAgain
* GotoDispatch: dispatch e/E m/M k/K a/A
GotoDispatch        cmpx      #$0065
                    beq       GotoEntryPos
                    cmpx      #$0045
                    beq      GotoEntryPos
                    cmpx      #$006D
                    beq       GotoMousePos
                    cmpx      #$004D
                    beq      GotoMousePos
                    cmpx      #$006B
                    beq       GotoExitPos
                    cmpx      #$004B
                    beq      GotoExitPos
                    cmpx      #$0061
                    beq       GotoActionPos
                    cmpx      #$0041
                    beq      GotoActionPos
                    lbra      KpLoopAgain
* KpNextRecord: '=': cursor + 1 if below the record count
KpNextRecord        ldd       >kpind
                    cmpd      <nevents
                    lbge      KpLoopAgain
                    ldd       >kpind
                    addd      #$0001
                    lbra      KpSetCursorPos
* KpAdvance: space: remember the position, kpmove('a', -1, 0)
KpAdvance           ldd       >kpind
                    std       15,s
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$FFFF
                    pshs      a,b
                    ldd       #$0061
                    pshs      a,b
                    lbsr      kpmove
                    leas      6,s
                    lbra      KpLoopAgain
* KpBackPos: ^U/^X: cursor back to the position saved before the last advance (15,s)
KpBackPos           ldd       15,s
                    bra      KpSetCursorPos
* KpArrowUp: $0C up arrow -> kpmove('u', -1)
KpArrowUp           ldd       #$FFFF
                    pshs      a,b
                    ldd       #$0075
                    bra       KpArrowMove
* KpArrowDown: $0A down arrow -> kpmove('d', -1)
KpArrowDown         ldd       #$FFFF
                    pshs      a,b
                    ldd       #$0064
                    bra       KpArrowMove
* KpArrowLeft: $08 left arrow -> kpmove('l', -1)
KpArrowLeft         ldd       #$FFFF
                    pshs      a,b
                    ldd       #$006C
                    bra       KpArrowMove
* KpArrowRight: $09 right arrow -> kpmove('r', -1)
KpArrowRight        ldd       #$FFFF
                    pshs      a,b
                    ldd       #$0072
* KpArrowMove: common kpmove call for the arrow keys
KpArrowMove         pshs      a,b
                    lbsr      kpmove
                    leas      4,s
                    lbra      KpLoopAgain
* KpScrollRight: '>': gind = last displayed index, column 0; adds a bar ([paddbars]) when already at the end
KpScrollRight       ldd       >ritind
                    std       >gind
                    clra
                    clrb
                    std       >xgoal
                    ldd       <nevents
                    addd      #$FFFF
                    cmpd      >ritind
                    bne       KpRedrawCenter
                    jsr       [>paddbars]
                    bra       KpRedrawCenter
* KpScrollLeft: '<': gind = first displayed index at column 78
KpScrollLeft        ldd       >lftind
                    std       >gind
                    ldd       #$004E
                    std       >xgoal
* KpRedrawCenter: redraw via [psoowee]('S','s') and put the cursor in the middle of the new range
KpRedrawCenter      ldd       #$0073
                    pshs      a,b
                    ldd       #$0053
                    pshs      a,b
                    jsr       [>UmeData_psoowee]
                    leas      4,s
                    ldd       >lftind
                    addd      >ritind
                    asra
                    rorb
* KpSetCursorPos: store the new cursor index and loop
KpSetCursorPos      std       >kpind
                    lbra      KpLoopAgain
* KpOptions: 'M' and any unlisted key: kpmen then waitmouse
KpOptions           lbsr      kpmen
                    lbsr      waitmouse
                    lbra      KpLoopAgain
* KpKeyDispatch: command-key dispatch: Q k H L R ? + C B - D Y P G = space ^U ^X arrows > < M
KpKeyDispatch       cmpx      #$0051
                    lbeq      KpQuit
                    cmpx      #$006B
                    lbeq      KpQuit
                    cmpx      #$0048
                    lbeq      KpRedraw
                    cmpx      #$004C
                    lbeq      KpPageLR
                    cmpx      #$0052
                    lbeq      KpPageLR
                    cmpx      #$003F
                    lbeq      KpShowNote
                    cmpx      #$002B
                    lbeq      KpChordOn
                    cmpx      #$0043
                    lbeq      KpChordOn
                    cmpx      #$0042
                    lbeq      KpChordOff
                    cmpx      #$002D
                    lbeq      KpChordOff
                    cmpx      #$0044
                    lbeq      KpDuplicate
                    cmpx      #$0059
                    lbeq      KpDuplicate
                    cmpx      #$0050
                    lbeq      KpPickup
                    cmpx      #$0047
                    lbeq      KpGoto
                    cmpx      #$003D
                    lbeq      KpNextRecord
                    cmpx      #$0020
                    lbeq      KpAdvance
                    cmpx      #$0015
                    lbeq      KpBackPos
                    cmpx      #$0018
                    lbeq      KpBackPos
                    cmpx      #$000C
                    lbeq      KpArrowUp
                    cmpx      #$000A
                    lbeq      KpArrowDown
                    cmpx      #$0008
                    lbeq      KpArrowLeft
                    cmpx      #$0009
                    lbeq      KpArrowRight
                    cmpx      #$003E
                    lbeq      KpScrollRight
                    cmpx      #$003C
                    lbeq      KpScrollLeft
                    cmpx      #$004D
                    lbeq      KpOptions
                    lbra      KpOptions
* KpLoopAgain: back to KpMainLoop
KpLoopAgain         lbra      KpMainLoop
* KpExit: return to the main program
KpExit              leas      <$67,s
                    puls      u,pc
* kpmen: curset(2), then loops showing the option states and the keypad modes menu via [pMenu3]; keys toggle autooct/autopick/pitcarry/kpclone/autoclone, h/v/b set kpmode, i/n show an info page, e runs [pexprmenu]; restores the window on exit
kpmen         pshs      u
                    leas      <-$54,s
                    ldd       >curcurse
                    std       1,s
                    ldd       #$0002
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
* OptMenuLoop: loop head: kpmode h/v/b -> radio state 1/2/3
OptMenuLoop         ldb       >kpmode
                    cmpb      #$68
                    bne       a25@
                    ldd       #$0001
                    bra       OptShowStates
a25@                ldb       >kpmode
                    cmpb      #$76
                    bne       b25@
                    ldd       #$0002
                    bra       OptShowStates
b25@                ldd       #$0003
* OptShowStates: sprintf(MenuStates, fmtOptStates, o,p,y,c,a,mode), [pMenu3](descKeypad, MenuStates) -> key in B; CR ends, else lowercase and OptDispatch
OptShowStates       pshs      a,b
                    ldb       >autoclone
                    sex
                    pshs      a,b
                    ldb       >kpclone
                    sex
                    pshs      a,b
                    ldb       >pitcarry
                    sex
                    pshs      a,b
                    ldb       >autopick
                    sex
                    pshs      a,b
                    ldb       >autooct
                    sex
                    pshs      a,b
                    leax      >fmtOptStates,pcr
                    pshs      x
                    ldx       #MenuStates
                    pshs      x
                    jsr       [>UmeData_psprintf]
                    leas      16,s
                    ldx       #MenuStates
                    pshs      x
                    leax      >descKeypad,pcr
                    pshs      x
                    jsr       [>pMenu3]           s9 streams it to s9gui; key in B
                    leas      4,s
                    stb       ,s
                    lbsr      wkill
                    ldb       ,s
                    cmpb      #$0D
                    lbeq      OptMenuDone
                    ldb       ,s
                    sex
                    orb       #$20
                    stb       ,s
                    sex
                    tfr       d,x
                    lbra      OptDispatch
* OptToggleO: 'o': toggle autooct (nearest-octave / auto octave)
OptToggleO          ldb       >autooct
                    bne       a26@
                    ldd       #$0001
                    bra       b26@
a26@                clra
                    clrb
b26@                stb       >autooct
                    lbra      OptMenuLoop
* OptToggleP: 'p': toggle autopick (copy the cursor note raw, no new bars)
OptToggleP          ldb       >autopick
                    bne       a27@
                    ldd       #$0001
                    bra       b27@
a27@                clra
                    clrb
b27@                stb       >autopick
                    lbra      OptMenuLoop
* OptToggleY: 'y': toggle pitcarry (take the pitch from the cursor note)
OptToggleY          ldb       >pitcarry
                    bne       a28@
                    ldd       #$0001
                    bra       b28@
a28@                clra
                    clrb
b28@                stb       >pitcarry
                    lbra      OptMenuLoop
* OptToggleC: 'c': toggle kpclone (chord mode, clone parts)
OptToggleC          ldb       >kpclone
                    bne       a29@
                    ldd       #$0001
                    bra       b29@
a29@                clra
                    clrb
b29@                stb       >kpclone
                    lbra      OptMenuLoop
* OptToggleA: 'a': toggle autoclone (add to chord, stay on the position)
OptToggleA          ldb       >autoclone
                    bne       a30@
                    ldd       #$0001
                    bra       b30@
a30@                clra
                    clrb
b30@                stb       >autoclone
                    lbra      OptMenuLoop
* OptSetMoveMode: 'h'/'v'/'b': kpmode = key (horizontal / vertical / both advance mode)
OptSetMoveMode      ldb       ,s
                    sex
                    orb       #$40
                    stb       >kpmode
                    lbra      OptMenuLoop
* OptInfoPage: 'i'/'n': alcurset(0), menu(21 or 22), wait for a key, then leave the menu
OptInfoPage         clra
                    clrb
                    pshs      a,b
                    lbsr      alcurset
                    leas      2,s
                    ldb       ,s
                    cmpb      #$69
                    bne       a31@
                    ldd       #$0015
                    bra       OptShowPageKey
a31@                ldd       #$0016
* OptShowPageKey: show the page and ReadPath one key
OptShowPageKey      pshs      a,b
                    lbsr      menu
                    leas      2,s
                    jsr       [>pflush]
                    ldd       #$0001
                    pshs      a,b
                    leax      5,s
                    pshs      x
                    clra
                    clrb
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    lbsr      wkill
                    bra       OptMenuDone
* OptEditKeySig: 'e': [pexprmenu](kpind) expression insert; nonzero result sets rfr_scr and undind = -1
OptEditKeySig       ldd       >kpind
                    pshs      a,b
                    jsr       [>pexprmenu]
                    leas      2,s
                    stb       >rfr_scr
                    beq       OptMenuDone
                    ldd       #$FFFF
                    std       >undind
* OptMenuDone: restore the saved window and return
OptMenuDone         ldd       1,s
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
                    bra       OptionsMenuRet
* OptBadKey: unknown key: bell, loop
OptBadKey           lbsr      bell
                    lbra      OptMenuLoop
* OptDispatch: dispatch o p y c a h v b i n e
OptDispatch         cmpx      #$006F
                    lbeq      OptToggleO
                    cmpx      #$0070
                    lbeq      OptToggleP
                    cmpx      #$0079
                    lbeq      OptToggleY
                    cmpx      #$0063
                    lbeq      OptToggleC
                    cmpx      #$0061
                    lbeq      OptToggleA
                    cmpx      #$0068
                    lbeq      OptSetMoveMode
                    cmpx      #$0076
                    lbeq      OptSetMoveMode
                    cmpx      #$0062
                    lbeq      OptSetMoveMode
                    cmpx      #$0069
                    lbeq      OptInfoPage
                    cmpx      #$006E
                    lbeq      OptInfoPage
                    cmpx      #$0065
                    beq       OptEditKeySig
                    bra       OptBadKey
* OptionsMenuRet: kpmen exit
OptionsMenuRet      leas      <$54,s
                    puls      u,pc
* strLetters: "cdefgab": indexed by letter index in StepToOctLetter (StoreOctLetter) to yield the pitch letter stored in kpnotch
strLetters          fcc       /cdefgab/
                    fcb       $00
* strDurTens: "136": leading digit of 16/32/64 emitted by kprint for duration codes 5..7 (code-5 index)
strDurTens          fcc       /136/
                    fcb       $00
* strDurChars: "vwhq8624": duration code 0..7 -> keypad character (v, whole, half, quarter, 8th, 16th, 32nd, 64th), read in kprint
strDurChars         fcc       /vwhq8624/
                    fcb       $00
* strDotChars: "_..3": dot code 1..3 -> '.', '.', '3' (".", "..", "/3" triplet) in kprint
strDotChars         fcc       /_..3/
                    fcb       $00
* strAccChars: "__#xNNFF": accidental code 2..7 -> '#', 'x', 'N', 'N', 'F', 'F' (6 = double flat gets an extra 'F' first) in kprint
strAccChars         fcc       /__#xNNFF/
                    fcb       $00
* strArticChars: "tlnms": articulation code 0..4 -> tie/legato/normal/marcato/staccato letter, indexed by kpartic in kprint
strArticChars       fcc       /tlnms/
                    fcb       $00
* strLetters2: "cdefgab": second copy, kprocess does index(this, kpnotch) - base to get the letter index 0..6
strLetters2         fcc       /cdefgab/
                    fcb       $00
* msgMustOverlay: "Must overlay a note/rest!\r": error box ([palert]) from kprocess when the record under the cursor is empty (byte0 = 0)
msgMustOverlay      fcc       /Must overlay a note/
                    fcb       $2F
                    fcc       /rest!/
                    fcb       $0D,$00
* strArticChars2: "tlnms": parser copy; ParseArtic does index(this, ch) - base to get the articulation code
strArticChars2      fcc       /tlnms/
                    fcb       $00
* strTitle: "KeyPad Input Editor": drawn by barwindow at the start of kpmain
strTitle            fcc       /KeyPad Input Editor/
                    fcb       $00
* strNoteChars: "y012345678abcdefgrhqvw./_#SzxFpNounslmt": every character legal in a note string; KpReadKey uses index on it to decide whether a key goes into the line or is a command
strNoteChars        fcc       /y012345678abcdefgrhqvw./
                    fcb       $2F
                    fcc       /_#SzxFpNounslmt/
                    fcb       $00
* msgExtraChars: "Extra chars in string!  Use anyway?": yes/no box ([pyesno]) when kparse did not consume the whole line
msgExtraChars       fcc       /Extra chars in string!  Use anyway?/
                    fcb       $00
* msgCurrentNote: "Current Note: ": printed by KpShowNote ('?' key) before the formatted note string
msgCurrentNote      fcc       /Current Note: /
                    fcb       $00
* msgHitEnter: "   Hit ENTER: ": printed by KpShowNote before the readline call [pgets]
msgHitEnter         fcc       /   Hit ENTER: /
                    fcb       $00
* msgGotoPrompt: "Entry, or last Mouse, Keypad exit, Action keypad: ": prompt of KpGoto ('G'); the answer key e/m/k/a picks the position source
msgGotoPrompt       fcc       /Entry, or last Mouse, Keypad exit, Action keypad: /
                    fcb       $00
* fmtOptStates: "%d%d%d%d%d%d": OptShowStates sprintf's the o,p,y,c,a option flags and the h/v/b move mode (1/2/3) into MenuStates
fmtOptStates        fcc       /%d%d%d%d%d%d/
                    fcb       $00
* descKeypad: condensed-menu descriptor for [pMenu3]: key line, title, then the items
descKeypad          fcb       28,171,24,14        five checkboxes, a radio of three
                    fcc       / opyca hvbine/
                    fcb       C$CR
                    fcc       |  KeyPad Input/Edit Modes|
                    fcb       0
                    fcc       /bO auto-Octave mode/
                    fcb       0
                    fcc       /bP auto-Pickup (Edit)/
                    fcb       0
                    fcc       /bY note pitch carrYover/
                    fcb       0
                    fcc       |bClone/Chords mode|
                    fcb       0
                    fcc       /bAuto-clone mode/
                    fcb       0
                    fcc       / On hitting barline, move:/
                    fcb       0
                    fcc       /rHorizontal  (partwise)/
                    fcb       0
                    fcc       /qVertically  (chordwise)/
                    fcb       0
                    fcc       /qBack & down (Bar-wise)/
                    fcb       0
                    fcc       / Instant-Commands Help/
                    fcb       0
                    fcc       / Notestring help/
                    fcb       0
                    fcc       / Expression insert.../
                    fcb       0
                    fcc       / ENTER back to keypad/
                    fcb       0,0
* strOptMenu: unreferenced copy of the original key line, followed by an unreferenced original routine
strOptMenu          fcc       / opyca hvbine/
                    fcb       $0D,$00,$34,$40,$8E,$01,$A6,$1F
                    fcb       $10,$35,$C0
* ispwexpr(code): 1 if a record's byte5 symbol code is $16,$17,$18,$1E or $20 (rest); kpcurse shifts the box right by one for these
ispwexpr       pshs      u
                    ldd       4,s
                    cmpd      #$0017
                    beq       RetOne
                    ldd       4,s
                    cmpd      #$0018
                    beq       RetOne
                    ldd       4,s
                    cmpd      #$0016
                    beq       RetOne
                    ldd       4,s
                    cmpd      #$001E
                    beq       RetOne
                    ldd       4,s
                    cmpd      #$0020
                    bne       RetZero
* RetOne: shared return 1 of ispwexpr/anybar
RetOne              ldd       #$0001
                    bra       RetFlagExit
* anybar(recptr): 1 when the record has no part (byte0 = 0) and byte5 <= 6; used by the 'b' move mode to find a place for the next note
anybar          pshs      u
                    ldb       [<$04,s]
                    bne       RetZero
                    ldx       4,s
                    ldb       5,x
                    cmpb      #$06
                    bgt       RetZero
                    ldd       #$0001
                    bra       RetFlagExit
* RetZero: shared return 0 of ispwexpr/anybar
RetZero             clra
                    clrb
* RetFlagExit: shared puls u,pc of ispwexpr and anybar; RetOne and anybar bra here, RetZero falls in
RetFlagExit         puls      u,pc
* partstaff(part, &staff, &clefofs, &flags): an out-of-range part becomes <nparts; returns parts[part].word0 (staff index) in D and stores parts[part].word1 -> flags, staves[word0].word0 -> staff, clefs[staves[word0].word1].word1 -> clefofs
partstaff            pshs      a,b,u
                    ldd       6,s
                    cmpd      #$0001
                    blt       a32@
                    ldd       6,s
                    cmpd      <nparts
                    ble       PartInfoLookup
a32@                ldd       <nparts
                    std       6,s
* PartInfoLookup: parts[part*4], staves[word0*10], clefs[staff.word1*4]
PartInfoLookup      ldd       6,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #parts
                    leax      d,x
                    ldd       ,x
                    std       ,s
                    ldd       6,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #parts
                    leax      d,x
                    ldd       2,x
                    std       [<$0C,s]
                    ldd       ,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      MulInt16
                    ldx       #staves
                    leax      d,x
                    leau      ,x
                    ldd       ,u
                    std       [<$08,s]
                    ldd       2,u
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #clefs
                    leax      d,x
                    ldd       2,x
                    std       [<$0A,s]
                    ldd       ,s
                    bra      SharedRet2
* wcreate(a, b, c, d, e, f): printf(pct7, $C6, a, b, c, d, e, f) - window-create command; only dialogue uses it
wcreate            pshs      u
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
                    ldd       <pct7
                    pshs      a,b
                    jsr       [>pprintf]
                    leas      <$10,s
                    puls      u,pc
* wkill: printf(pctn1, $C7) - window-kill command, issued after every prompt/key read and when the note line is reset
wkill            pshs      u
                    ldd       #$00C7
                    pshs      a,b
                    ldd       <pctn1
                    pshs      a,b
                    jsr       [>pprintf]
                    lbra      SharedRet4
* waitmouse: polls [pmouce] and sleeps 4 ticks while it returns nonzero (button held); called after kpmen
waitmouse         pshs      a,b,u
                    bra       MousePollLoop
* MouseWaitSleep: SleepTicks(4) then poll again
MouseWaitSleep      ldd       #$0004
                    pshs      a,b
                    lbsr      SleepTicks
                    leas      2,s
* MousePollLoop: [pmouce] nonzero -> keep waiting
MousePollLoop       leax      ,s
                    pshs      x
                    leax      2,s
                    pshs      x
                    jsr       [>pmouce]
                    leas      4,s
                    bne       MouseWaitSleep
* SharedRet2: drops 2 locals: partstaff bra's here, waitmouse falls in
SharedRet2          leas      2,s
                    puls      u,pc
* bell: [pbeep] when the sound flag ($03C3) is set; error feedback for bad keys / full line
bell             pshs      u
                    ldb       >UmeData_reserved_03C3
                    beq       a33@
                    jsr       [>pbeep]
a33@                puls      u,pc
* curset(n): stores n in <curcurse (current window) and emits printf(pctn2, $9A, n); kpmain uses 0, kpmen 2, both restore the saved value on exit
curset        pshs      u
                    ldd       4,s
                    std       <curcurse
                    ldd       4,s
                    pshs      a,b
                    ldd       #$009A
                    bra       WinCmdEmit
* alcurset(flag): printf(pctn2, $CC, flag) - 1 when the note line opens, 0 when it empties or before the info pages (input-line cursor on/off)
alcurset            pshs      u
                    ldb       5,s
                    sex
                    pshs      a,b
                    ldd       #$00CC
                    bra       WinCmdEmit
* dialogue(flag): wcreate(14, 110, 50, flag?5:2, 1, WinStylePaper3D) - the prompt/entry window for the note line, the '?' display and the Goto prompt
dialogue       pshs      u
                    ldd       #WinStylePaper3D    paper 3D box
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldb       9,s
                    beq       a34@
                    ldd       #$0005
                    bra       b34@
a34@                ldd       #$0002
b34@                pshs      a,b
                    ldd       #$0032
                    pshs      a,b
                    ldd       #$006E
                    pshs      a,b
                    ldd       #$000E
                    pshs      a,b
                    lbsr      wcreate
                    bra       SharedRet12
* menu(n): printf(pctn2, $C4, n); kpmen's i/n info pages use 21/22
menu            pshs      u
                    ldd       4,s
                    pshs      a,b
                    ldd       #$00C4
* WinCmdEmit: shared tail of curset/alcurset/menu: printf(pctn2, code, n) via [pprintf]
WinCmdEmit          pshs      a,b
                    ldd       <pctn2
                    pshs      a,b
                    jsr       [>pprintf]
                    leas      6,s
                    puls      u,pc
* phrase(x, y, text, flag): printf(fmtTextAt, $C0, x, y, flag, text) - positioned text output used for the title
phrase         pshs      u
                    ldd       8,s
                    pshs      a,b
                    ldb       13,s
                    sex
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    ldd       #$00C0
                    pshs      a,b
                    leax      >fmtTextAt,pcr
                    pshs      x
                    jsr       [>pprintf]
* SharedRet12: shared epilogue dropping 12 arg bytes: dialogue bra's here, phrase falls in
SharedRet12         leas      12,s
                    puls      u,pc
* yclear(y1, y2): bytblt(2, 0, y1, 79, y2) - clears the full-width strip for the title bar
yclear          pshs      u
                    ldd       6,s
                    pshs      a,b
                    ldd       #$004F
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0002
                    pshs      a,b
                    bsr       bytblt
                    leas      10,s
                    puls      u,pc
* barwindow(row, text): yclear($BA,$BE) then phrase(row, $BA, text, 0); called with strTitle
barwindow        pshs      u
                    ldd       #$00BE
                    pshs      a,b
                    ldd       #$00BA
                    pshs      a,b
                    bsr       yclear
                    leas      4,s
                    clra
                    clrb
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    ldd       #$00BA
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    bsr      phrase
                    leas      8,s
                    puls      u,pc
* bytblt(mode, x1, y1, x2, y2): builds the command in DP arg0..arg5 (y1/y2 clamped to >= 0): mode 2/4 = $BC fill with arg5 0/1 (6 bytes), 3 = $B8 box (5 bytes); sends it via [pnfwrite], then [pflush]; other modes -> Bad BytBlt box
bytblt              pshs      a,b,x,u
                    ldd       #$0001
                    std       ,s
                    ldd       12,s
                    bge       a35@
                    clra
                    clrb
                    std       12,s
a35@                ldd       <$10,s
                    bge       b35@
                    clra
                    clrb
                    std       <$10,s
b35@                ldd       10,s
                    stb       <arg1
                    ldd       12,s
                    stb       <arg2
                    ldd       14,s
                    stb       <arg3
                    ldd       <$10,s
                    stb       <arg4
                    ldx       8,s
                    bra       BltDispatch
* BltModeClear: mode 2: <arg5 = 0 (clear) then the $BC command
BltModeClear        clra
                    clrb
                    std       ,s
* BltFillCmd: command $BC, <arg5 flag, 6 bytes
BltFillCmd          ldd       #$00BC
                    stb       <arg0
                    ldd       ,s
                    stb       <arg5
                    ldd       #$0006
                    bra       BltSetLen
* BltBoxCmd: mode 3: command $B8, 5 bytes (box outline used for the cursor)
BltBoxCmd           ldd       #$00B8
                    stb       <arg0
                    ldd       #$0005
* BltSetLen: command length to 2,s: BltFillCmd bra's here with 6, BltBoxCmd falls in with 5
BltSetLen           std       2,s
                    bra       BltSend
* BadBytBlt: error box "Bad BytBlt " + mode via [palert]
BadBytBlt           ldd       8,s
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    leax      >msgBadBytBlt,pcr
                    pshs      x
                    jsr       [>palert]
                    leas      6,s
                    bra       SharedRet4
* BltDispatch: dispatch on mode 2/4/3
BltDispatch         cmpx      #$0002
                    beq       BltModeClear
                    cmpx      #$0004
                    beq       BltFillCmd
                    cmpx      #$0003
                    beq       BltBoxCmd
                    bra       BadBytBlt
* BltSend: [pnfwrite](length) sends the DP command, then [pflush]
BltSend             ldd       2,s
                    pshs      a,b
                    jsr       [>pnfwrite]
                    leas      2,s
                    jsr       [>pflush]
* SharedRet4: drops 4 bytes: wkill and BadBytBlt branch here, BltSend falls in
SharedRet4          leas      4,s
                    puls      u,pc
* fmtTextAt: "%c%c%c%c%s\r": phrase's printf format: code $C0, x, y, flag byte, then the text
fmtTextAt           fcc       /%c%c%c%c%s/
                    fcb       $0D,$00
* msgBadBytBlt: "Bad BytBlt ": error box text of bytblt for a mode other than 2/3/4
msgBadBytBlt        fcc       /Bad BytBlt /
                    fcb       $00
* i2p(index): sets <curind = index, page = index/928 + 1 (loaded via [ppswap] if not <curpage); returns <curevp = <database + (index%928)*8, or 0 if the page load failed
i2p             pshs      u
                    ldu       4,s
                    leas      -2,s
                    stu       <curind
                    ldd       #$0001
                    bra       SeekBlockLoop
* SeekBlockNext: page counter + 1
SeekBlockNext       ldd       ,s
                    addd      #$0001
* SeekBlockLoop: subtract 928-record pages from the index, counting them
SeekBlockLoop       std       ,s
                    leau      >-$03A0,u
                    stu       -2,s
                    bge       SeekBlockNext
                    leau      >$03A0,u
                    ldd       ,s
                    cmpd      <curpage
                    beq       SeekCalcPtr
                    ldd       ,s
                    pshs      a,b
                    jsr       [>ppswap]
                    leas      2,s
                    bne       SeekCalcPtr
                    clra
                    clrb
                    bra       NotePtrRet
* SeekCalcPtr: <curevp = <database + remainder*8
SeekCalcPtr         tfr       u,d
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    addd      <database
                    std       <curevp
* NotePtrRet: i2p exit: a failed [ppswap] bra's here with 0, SeekCalcPtr falls in
NotePtrRet          leas      2,s
                    puls      u,pc
* plusplus: advances <curind/<curevp to the next 8-byte record, loading page <curpage+1 via [ppswap] when <curevp passes <curptop; returns <curevp
plusplus            pshs      u
                    ldd       <curind
                    addd      #$0001
                    std       <curind
                    cmpd      <nevents
                    bge       NoteStepRet
                    ldd       <curevp
                    addd      #$0008
                    std       <curevp
                    cmpd      <curptop
                    bls       NoteStepRet
                    ldd       <curpage
                    addd      #$0001
                    pshs      a,b
                    jsr       [>ppswap]
                    leas      2,s
                    ldd       <database
                    bra       NoteStorePtr
* decdec: steps <curind/<curevp back one record, loading page <curpage-1 via [ppswap] when <curevp drops below <database; returns <curevp
decdec            pshs      u
                    ldd       <curind
                    addd      #$FFFF
                    std       <curind
                    blt       NoteStepRet
                    ldd       <curevp
                    addd      #$FFF8
                    std       <curevp
                    cmpd      <database
                    bhs       NoteStepRet
                    ldd       <curpage
                    addd      #$FFFF
                    pshs      a,b
                    jsr       [>ppswap]
                    leas      2,s
                    ldd       <curptop
* NoteStorePtr: <curevp after a page load: plusplus bra's here with <database, decdec falls in with <curptop
NoteStorePtr        std       <curevp
* NoteStepRet: shared return of plusplus/decdec: D = <curevp
NoteStepRet         ldd       <curevp
                    puls      u,pc
                    fcb       $EC,$64,$E3
                    fcs       /f4F./
                    fcb       $68,$EE,$66,$20,$04,$E6,$80,$E7
                    fcb       $C0,$AC,$E4,$25,$F8,$35,$C6,$EC
                    fcb       $64,$AE,$62,$34,$10,$30,$8B,$20
                    fcb       $12,$EC,$18,$ED,$84,$EC,$1A,$ED
                    fcb       $02,$EC,$1C,$ED,$04,$EC,$1E,$ED
                    fcb       $06,$30,$18,$AC,$E4,$22,$EA,$35
                    fcb       $90,$AE,$62,$EC,$64,$E3,$62,$34
                    fcb       $06,$20,$12,$EC,$08,$ED,$84,$EC
                    fcb       $0A,$ED,$02,$EC,$0C,$ED,$04,$EC
                    fcb       $0E,$ED,$06,$30,$08,$AC,$E4,$25
                    fcb       $EA,$35,$86
* CopyNoteP(dst, src): copies a 5-byte note template (dur, dots, step, accidental, articulation), e.g. brush into record+3 or a local buffer
CopyNoteP          pshs      u
                    ldu       6,s
                    ldx       4,s
                    ldd       ,u
                    std       ,x
                    ldd       2,u
                    std       2,x
                    ldb       4,u
                    stb       4,x
                    puls      u,pc
                    fcb       $34,$40,$EE,$66,$AE,$64,$EC,$C4
                    fcb       $ED,$84,$EC,$42,$ED,$02,$EC,$44
                    fcb       $ED,$04,$EC,$46,$ED,$06,$35,$C0
* index(str, ch): returns a pointer to the first ch in str, or 0; callers subtract the string base to turn a keypad character into a code
index              ldx       2,s
* StrChrLoop: scan loop
StrChrLoop          ldb       ,x+
                    beq       StrChrNone
                    cmpb      5,s
                    bne       StrChrLoop
                    tfr       x,d
                    bra       StrChrFound
* StrChrNone: NUL reached: return 0
StrChrNone          clra
                    rts
                    fcb       $AE,$62,$CC,$00,$01,$34,$06,$20
                    fcb       $06,$E1,$67,$26,$02,$AF,$E4,$E6
                    fcb       $80,$26,$F6,$35,$06
* StrChrFound: pointer back to the matching char
StrChrFound         subd      #$0001
                    rts
* MulInt16: C runtime 16x16 multiply: D * word on the stack; fast 8x8 mul path, else four partial products (low word in D, high in X)
MulInt16            tsta
                    bne       MulLong
                    tst       2,s
                    bne       MulLong
                    lda       3,s
                    mul
                    ldx       ,s
                    stx       2,s
                    ldx       #$0000
                    std       ,s
                    puls      a,b,pc
* MulLong: 16x16 partial-product path when either high byte is nonzero
MulLong             pshs      a,b
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
                    bhs       a36@
                    inc       ,s
a36@                lda       4,s
                    ldb       9,s
                    mul
                    addd      1,s
                    std       1,s
                    bhs       b36@
                    inc       ,s
b36@                lda       4,s
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
* DivByZero: divisor 0: SendSelfSignal($2D)
DivByZero           puls      a,b
                    std       ,s
                    ldd       #$002D
                    bra      SendSelfSignal
* DivInt16: C runtime signed 16-bit divide: stack word / D, quotient in D, remainder in X (shift-subtract loop, sign fix); divisor 0 -> DivByZero
DivInt16            subd      #$0000
                    beq       DivByZero
                    pshs      a,b
                    leas      -2,s
                    clr       ,s
                    clr       1,s
                    tsta
                    bpl       a37@
                    nega
                    negb
                    sbca      #$00
                    com       1,s
                    std       2,s
a37@                ldd       6,s
                    bpl       b37@
                    nega
                    negb
                    sbca      #$00
                    com       1,s
                    std       6,s
b37@                lda       #$01
* DivShiftLoop: normalize the divisor, count shifts
DivShiftLoop        inca
                    asl       3,s
                    rol       2,s
                    bpl       DivShiftLoop
                    sta       ,s
                    ldd       6,s
                    clr       6,s
                    clr       7,s
* DivLoop: restoring shift-subtract loop
DivLoop             subd      2,s
                    bhs       a38@
                    addd      2,s
                    andcc     #$FE
                    bra       b38@
a38@                orcc      #$01
b38@                rol       7,s
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
* DivResult: swap quotient/remainder into D/X and return
DivResult           ldx       4,s
                    ldd       6,s
                    std       4,s
                    stx       6,s
                    ldx       2,s
                    ldd       4,s
                    leas      6,s
                    rts
* SendSelfSignal: stores D in errno ($034F,y), F$ID for the own process id, F$Send that signal to itself (division-by-zero trap, signal $2D)
SendSelfSignal      std       >$034F,y
                    pshs      b,y
                    os9       F$ID
                    puls      b,y
                    os9       F$Send
                    rts
* ReadPath: C read(path, buf, count) via I$Read: returns the count, 0 on E$EOF ($D3), else ErrnoReturn (-1); the key loop reads 1 byte from path 0
ReadPath            pshs      y
                    ldx       6,s
                    lda       5,s
                    ldy       8,s
                    pshs      y
                    os9       I$Read
                    bhs       ReadPathOK
                    cmpb      #$D3
                    bne       ReadPathErr
                    clra
                    clrb
                    puls      x,y,pc
* ReadPathErr: other error: ErrnoReturn
ReadPathErr         puls      x,y
                    bra      ErrnoReturn
* ReadPathOK: return the byte count in D
ReadPathOK          tfr       y,d
                    puls      x,y,pc
                    fcb       $34,$20,$A6,$65,$AE,$66,$10,$AE
                    fcc       /h4 /
                    fcb       $10,$3F,$8B,$20,$DD,$39,$8E,$00
                    fcb       $00,$5F,$10,$3F,$0A,$16,$00
                    fcs       /'94`./
                    fcb       $66,$10,$AE,$68,$EE,$6A,$10,$3F
                    fcb       $17,$35,$E0,$A6,$63,$E6,$65,$10
                    fcb       $3F,$0F,$10,$25,$00,$0D,$39
* SleepTicks: C tsleep(ticks) via F$Sleep; returns the remaining ticks or ErrnoReturn on error
SleepTicks          ldx       2,s
                    os9       F$Sleep
                    blo      ErrnoReturn
                    tfr       x,d
                    rts
* ErrnoReturn: C runtime error exit: errno ($034F,y) = B, returns -1
ErrnoReturn         clra
                    std       >$034F,y
                    ldd       #$FFFF
                    rts
                    fcb       $25,$F5
                    fcc       /O_9/
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
                    fcc       /s9k/
                    fcb       $00

                    fill      0,$1D00-*           pad to $1D00 bytes so F$Link never maps this overlay into slot 7, which the score page needs
                    emod
eom                 equ       *
                    end
