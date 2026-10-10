********************************************************************
* s9c - Studio-9 CONTEXT MENUS overlay (also the menu descriptors, the measure-start helper, the
* note audition and the note fit check).
*
* Linked by name through s9's soowee like every s9x overlay: soowee('C', kind) with the menu
* kind as the command letter; returns B = the key letter of the row chosen, C$CR when the menu was
* clicked away (a click outside the box closes it). The caller performs the action; this module
* only draws, tracks and reports.
*
* A menu is one s9gui packet - $B9 col y rows width, then one CR-terminated row each (key letter +
* label) streamed through the same pipe; s9gui (ctxma) draws it, runs the hover loop on the mouse
* packets s9's pipemenu sends it and answers the key picked; RunMenu's $C7 (wkill) then takes the
* saved window down. Adding a menu = a kind letter, a row table (label strings) and a key string below.
*
* Menu geometry: the top text line is at y, rows are MENU_PITCH (7) dots apart, byte columns
* col-1 .. col+width (y grows upward). The press position comes from CtxX/CtxY (equates.asm), stored
* by s9 before the call.
*
* Menus:  'n'  the NOTE menu (right button on the sheet): a plain hover-highlighted list, no title, Delete.
*         'M'  (id) a condensed text menu from a descriptor (see MenuById).
* Helper: 'm'  (index) -> D = the index of the nearest bar line before the event (part 0,
*              code 0-6), 0 at the score start: the start of its measure.
* Audition: 'a'  (index) -> D = the event count of a TEMPORARY SCORE holding THE NOTE ALONE at its
*              natural length: the meter, tempo, key, channel and instrument in force at the note, an
*              opening bar line at time 0, the note at time 0, and a closing bar line at its end.
*              It is built in a fresh event page (one past the score's last, pswap creates it) and
*              swapped in as PAGE 1 with <nevents = its count, so s9 can call the player with
*              (0, count-1) exactly like PLAY. The real event count is parked in the slot after the
*              last temporary event. 0 = nothing to play (a rest, an inclusion, too many events, no memory).
*          'z'  puts the real score back: page 1 and the temporary page change places again,
*              <nevents returns, giveback() frees the temporary page.
* Fit check: 'k'  (index of the clicked rest) -> D = 0 when the palette note may go there, 1 when it may not
*              (after the bonk). It fits when the rests of the clicked rest's own part, taken one after
*              another from the clicked rest, cover the note's length before a note of that part or a bar
*              line comes. chip/bomb then consume only rests and put a rest back for what is left.
* At entry (after pshs u and the frame): the command word is at mframe+4,u (its letter in the low byte
* at mframe+5,u) and the first argument word at mframe+6,u.
********************************************************************
                    nam       s9c
                  IFP1
                    use       defsfile
                  ENDC
UME_SCOPE_S9C                  equ       1
                    use       equates.asm
                    mod       eom,name,Prgrm+Objct,ReEnt+1,start,$104C
name                fcs       /s9c/
                    fcb       1



start               pshs      u
                    leas      -mframe,s
                    leau      ,s
                    ldb       mframe+5,u          the command letter: which menu
                    cmpb      #'n
                    beq       NoteMenu
                    cmpb      #'m
                    lbeq      MeasureStart
                    cmpb      #'a
                    lbeq      Audition
                    cmpb      #'z
                    lbeq      AudRestore
                    cmpb      #'M
                    lbeq      MenuById
                    cmpb      #'k
                    lbeq      FitCheck
                    ldb       #C$CR               no such menu
                    bra       MenuExit
NoteMenu            ldd       #1                  Delete only: no title row
                    std       mrows,u
                    leax      >noteRows,pcr
                    stx       mlabels,u
                    leax      >noteKeys,pcr
                    stx       mkeys,u
                    lbsr      RunMenu
MenuExit            clra
DExit               leas      mframe,s
                    puls      u,pc

* ---- 'M' (id): a CONDENSED TEXT MENU from a descriptor. s9's menu descriptors live here to save room in s9;
* the caller sprintf's any state text into MenuStates first. A descriptor: fcb col, y, width, rows; the key
* letters, one a row (a space = a title row); then one row each = a kind byte, the label, NUL; a zero kind ends
* it. Kinds: ' ' plain; 'b' a checkbox (one state byte, '0' = off); 'r' the head of a radio group (one state
* digit K: the Kth member is filled); 'q' a member; 'f' a field (the label, then the state text up to its CR).
* The box is Chars16 glyph $60 (empty) or $7F (filled), one character wide. s9gui draws it and runs the hover
* loop (pipemenu). B = the key letter of the row picked, CR = closed.
MenuById            ldd       mframe+6,u          the id
                    lslb
                    rola
                    leax      >descTab,pcr
                    ldd       d,x
                    leax      d,x                 the descriptor
                    ldd       #MenuStates
                    pshs      d
                    pshs      x
                    jsr       [>pMenu3]           s9's menu3 streams it, s9gui draws and answers: B
                    leas      4,s
                    clra
                    lbra      DExit
* the descriptor table: id -> offset from here
descTab             fdb       descFiles-descTab
                    fdb       descFiles-descTab   1: FILES as well (it also serves with no score loaded)
                    fdb       descFsub-descTab
                    fdb       descRand-descTab
                    fdb       descOpts-descTab
                    fdb       descPrtr-descTab
                    fdb       descColors-descTab
                    fdb       descFilt-descTab
                    fdb       descFpart-descTab
* Bar menus: col = the title's column + MenuDropX + 1; ctxma opens at col-1 and frames one column
* farther left.
descFiles           fcb       MenuBarC0+MenuDropX+1,MenuDropY,18,13  File
                    fcc       /raswfoidphtkq/
                    fcc       /   Load score/
                    fcb       0
                    fcc       /   Append score/
                    fcb       0
                    fcc       /   Save score/
                    fcb       0
                    fcc       /   Write new file/
                    fcb       0
                    fcc       /   File name?/
                    fcb       0
                    fcc       /bread-Only mode/
                    fcb       0
                    fcc       /   Instrs, etc.../
                    fcb       0
                    fcc       /   Dir non-scores/
                    fcb       0
                    fcc       /   Present dir/
                    fcb       0
                    fcc       /   CHange dir/
                    fcb       0
                    fcc       /   Title editor/
                    fcb       0
                    fcc       /   Kill disk file/
                    fcb       0
                    fcc       /   Quit!/
                    fcb       0,0
descFsub            fcb       7,135,11,9          2: the file sub-menu (menu 17): what to read or write
                    fcc       /ipml rwdk/
                    fcc       /rInstruments/      the radio head: its kind byte r must be the first character
                    fcb       0
                    fcc       /qPercussions/
                    fcb       0
                    fcc       /qMidi chans/
                    fcb       0
                    fcc       /qVol Levels/
                    fcb       0
                    fcc       / /
                    fcb       0
                    fcc       /    Read/
                    fcb       0
                    fcc       /    Write/
                    fcb       0
                    fcc       /    Dir/
                    fcb       0
                    fcc       /    Kill/
                    fcb       0,0

descRand            fcb       MenuBarC8+MenuDropX+1,MenuDropY,14,12  Misc
                    fcc       /pwksnufh9?rq/
                    fcc       /  Play all/
                    fcb       0
                    fcc       /  play Window/
                    fcb       0
                    fcc       /  Keypad editor/
                    fcb       0
                    fcc       /  Screen redraw/
                    fcb       0
                    fcc       /  reNumber bars/
                    fcb       0
                    fcc       /  Undo X-out/
                    fcb       0
                    fcc       /  Finder-filter/
                    fcb       0
                    fcc       /  Hard copy/
                    fcb       0
                    fcc       /  os9 command/
                    fcb       0
                    fcc       /  ? status/
                    fcb       0
                    fcc       /  Restart over/
                    fcb       0
                    fcc       /    QUIT!/
                    fcb       0,0
descOpts            fcb       MenuBarC2+MenuDropX+1,MenuDropY,19,16  Opts: eleven checkboxes
                    fcc       /naishcbtpdmlefr?/
                    fcc       /bNote carryover/
                    fcb       0
                    fcc       /bsnAp cursors/
                    fcb       0
                    fcc       /bstIcky Instr tools/
                    fcb       0
                    fcc       /   Screen colors.../
                    fcb       0
                    fcc       /bditHered staff/
                    fcb       0
                    fcc       /bCompact display/
                    fcb       0
                    fcc       /bBeam note-groups/
                    fcb       0
                    fcc       /bThick beams/
                    fcb       0
                    fcc       /   Printer setup.../
                    fcb       0
                    fcc       /bDebug playing/
                    fcb       0
                    fcc       /bhi-res Mouse/
                    fcb       0
                    fcc       /bLeft mouse port/
                    fcb       0
                    fcc       |bbEll off/on|
                    fcb       0
                    fcc       /   File the options/
                    fcb       0
                    fcc       /   Restore options/
                    fcb       0
                    fcc       | /? status info...|
                    fcb       0,0
descPrtr            fcb       15+5,155+TextLineH,17,11  5: printer setup (menu 14): a radio of eight, two checkboxes
                    fcb       C$CR
                    fcc       /01234567ft/
                    fcc       /  PRINTERS:/
                    fcb       0
                    fcc       /r0 (none)/
                    fcb       0
                    fcc       /q1 DMP-105/
                    fcb       0
                    fcc       /q2 DMP-130/
                    fcb       0
                    fcc       /q3 CGP-220/
                    fcb       0
                    fcc       /q4 Epson Wide/
                    fcb       0
                    fcc       /q5  '' Normal/
                    fcb       0
                    fcc       /q6 IBM Pro/
                    fcb       0
                    fcc       /q7 Gemini 10X/
                    fcb       0
                    fcc       /bFormFeeds work/
                    fcb       0
                    fcc       |bTop/bot Margins|
                    fcb       0,0
descColors          fcb       15,169,11,10        6: colors (menu 16): a radio of two, six checkboxes
                    fcc       /zofarRgGbB/
                    fcc       /  COLORS/
                    fcb       0
                    fcc       / O.K., Keep/
                    fcb       0
                    fcc       /rForeground/
                    fcb       0
                    fcc       /qbAckground/
                    fcb       0
                    fcc       /bred/
                    fcb       0
                    fcc       /bRED/
                    fcb       0
                    fcc       /bgreen/
                    fcb       0
                    fcc       /bGREEN/
                    fcb       0
                    fcc       /bblue/
                    fcb       0
                    fcc       /bBLUE/
                    fcb       0,0
descFilt            fcb       35,170,14,12        7: the finder filter (menu 18)
                    fcc       / enraofc uml/
                    fcc       /  FIND-FILTER/
                    fcb       0
                    fcc       / Everything/
                    fcb       0
                    fcc       /bNotes/
                    fcb       0
                    fcc       /bRests/
                    fcb       0
                    fcc       /rAll parts/
                    fcb       0
                    fcc       /qOne part/
                    fcb       0
                    fcc       /bFlagged/
                    fcb       0
                    fcc       /b+Clone parts/
                    fcb       0
                    fcc       / /
                    fcb       0
                    fcc       /bUpper stems/
                    fcb       0
                    fcc       /bMiddle stems/
                    fcb       0
                    fcc       /bLower stems/
                    fcb       0,0
descFpart           fcb       35,190,8,16         8: the filter's part picker (menu 19): a radio of sixteen, hex K
                    fcc       /123456789abcdefg/
                    fcc       /r1/
                    fcb       0
                    fcc       /q2/
                    fcb       0
                    fcc       /q3/
                    fcb       0
                    fcc       /q4/
                    fcb       0
                    fcc       /q5/
                    fcb       0
                    fcc       /q6/
                    fcb       0
                    fcc       /q7/
                    fcb       0
                    fcc       /q8/
                    fcb       0
                    fcc       /q9/
                    fcb       0
                    fcc       /qA 10/
                    fcb       0
                    fcc       /qB 11/
                    fcb       0
                    fcc       /qC 12/
                    fcb       0
                    fcc       /qD 13/
                    fcb       0
                    fcc       /qE 14/
                    fcb       0
                    fcc       /qF 15/
                    fcb       0
                    fcc       /qG 16/
                    fcb       0,0
* MeasureStart - 'm': walk back from the event before the given one to the nearest bar line
MeasureStart        ldd       mframe+6,u
                    lbsr      BarBefore
                    lbra      DExit
* BarBefore: D = an index -> D = the nearest bar line before it (part 0, code 0-6), 0 at the score start
BarBefore           equ       *
ms1@                std       mcol,u              the candidate
                    beq       ms9@                event 0 opens the score
                    subd      #1
                    std       mcol,u
                    pshs      d
                    jsr       [>pMidiEventPtr]    i2p: D = the record, 0 if the page will not map
                    leas      2,s
                    tfr       d,x
                    beq       ms9@
                    tst       ,x
                    bne       ms2@                a note: keep looking
                    ldb       5,x
                    cmpb      #6
                    bls       ms9@                a bar line
ms2@                ldd       mcol,u
                    bra       ms1@
ms9@                ldd       mcol,u
                    rts

* ---- 'k' (index): may the palette note go on the rest at index? D = 0 yes, D = 1 no (after the bonk) ----
* aend = the length needed, abase = the rest length found so far, apart = the clicked rest's part;
* all in cod2raw units.
FitCheck            ldx       #UmeData_brush
                    ldb       2,x
                    cmpb      #$20
                    beq       fcYes@              the palette holds a rest: not a note entry
                    ldb       1,x                 durmod
                    sex
                    pshs      d
                    ldb       ,x                  dur
                    sex
                    pshs      d
                    jsr       [>vCod2raw]
                    leas      4,s
                    std       aend,u
                    clra
                    clrb
                    std       abase,u
                    ldd       mframe+6,u
                    std       aidx,u
                    lbsr      EventAt
                    beq       fcNo@
                    ldb       ,x
                    stb       apart+1,u           the clicked rest's part
fcNext@             ldd       aidx,u
                    cmpd      <vEvents
                    bhs       fcNo@               the score ends first
                    lbsr      EventAt
                    beq       fcNo@
                    ldb       ,x
                    bne       fcPart@
                    ldb       5,x
                    cmpb      #6
                    bls       fcNo@               a bar line comes first
                    bra       fcStep@             another score mark is not in the way
fcPart@             cmpb      apart+1,u
                    bne       fcStep@             another part's event
                    ldb       5,x
                    cmpb      #$20
                    bne       fcNo@               a note of this part comes first
                    ldb       4,x                 durmod
                    sex
                    pshs      d
                    ldb       3,x                 dur
                    sex
                    pshs      d
                    jsr       [>vCod2raw]
                    leas      4,s
                    addd      abase,u
                    std       abase,u
                    cmpd      aend,u
                    bhs       fcYes@              enough rest: the note fits
fcStep@             ldd       aidx,u
                    addd      #1
                    std       aidx,u
                    bra       fcNext@
fcYes@              bsr       fcRemap
                    clra
                    clrb
                    lbra      DExit
fcNo@               bsr       Bonk
                    bsr       fcRemap
                    ldd       #1
                    lbra      DExit
* the walk may have mapped another event page: the clicked event's page goes back for the caller's pointer
fcRemap             ldd       mframe+6,u
                    lbra      EventAt
* Bonk: a quick low tone, then a lower one held a little longer, on MIDI channel 16 through
* s9's live-byte dispatcher. $FE = a pause, its length in ticks follows; $FF ends the list. Running status
* carries the pairs after the first message, and the player's own running status is forgotten afterwards.
Bonk                leax      >bonkList,pcr
bk1@                ldb       ,x+
                    cmpb      #$FF
                    beq       bkEnd@
                    cmpb      #$FE
                    bne       bkSend@
                    ldb       ,x+
                    clra
                    pshs      x
                    tfr       d,x
                    os9       F$Sleep
                    puls      x
                    bra       bk1@
bkSend@             clra
                    pshs      d,x                 STACK ARGUMENT: the byte (pMidiSend reads the low byte); X is kept under it
                    jsr       [>pMidiSend]
                    puls      d,x
                    bra       bk1@
bkEnd@              clr       <UmeData_runstat
                    clr       <UmeData_reserved_00CE
                    rts
bonkList            fcb       $9F,40,100,$FE,5,40,0,33,100,$FE,11,33,0,$FF

* ---- the AUDITION ('a'): one note as a temporary native score in page 1 -------------------------------
Audition            ldd       mframe+6,u
                    std       aidx,u
                    lbsr      EventAt             X = the note's record
                    lbeq      AudFail
                    ldb       ,x
                    clra
                    std       apart,u
                    lbeq      AudFail             an inclusion is not auditioned
                    ldb       5,x
                    cmpb      #$20
                    lbeq      AudFail             nor a rest
                    ldd       1,x
                    std       aend,u              its start, for now
                    std       abase,u             time zero = the note's start
                    ldb       4,x                 durmod
                    sex
                    pshs      d
                    ldb       3,x                 dur
                    sex
                    pshs      d
                    jsr       [>vCod2raw]
                    leas      4,s
                    addd      aend,u
                    std       aend,u              its end: the closing bar line goes there
* the bar line before the note (afirst): its page must map
                    ldd       aidx,u
                    lbsr      BarBefore
                    std       afirst,u
                    lbsr      EventAt
                    lbeq      AudFail
* The latest meter, tempo, key and this part's channel/instrument before the note.
                    ldd       #-1
                    std       atmp,u
                    std       atsg,u
                    std       aksg,u
                    std       achn,u
                    std       ains,u
                    ldd       aidx,u              attributes in force at the clicked note, not just the bar
aw1@                subd      #1
                    bmi       aw9@
                    std       asrc,u
                    lbsr      EventAt
                    beq       aw9@
                    tst       ,x
                    bne       aw8@                a part's event
                    ldb       5,x
                    cmpb      #EvTempo
                    bne       aw2@
                    ldx       atmp,u
                    bpl       aw8@                the latest is already known
                    ldd       asrc,u
                    std       atmp,u
                    bra       aw8@
aw2@                cmpb      #EvTimeSig
                    bne       aw3@
                    ldx       atsg,u
                    bpl       aw8@
                    ldd       asrc,u
                    std       atsg,u
                    bra       aw8@
aw3@                cmpb      #$16
                    beq       AudChannel
                    cmpb      #$17
                    beq       AudInstrument
                    cmpb      #EvKeySig
                    bne       aw8@
                    ldx       aksg,u
                    bpl       aw8@
                    ldd       asrc,u
                    std       aksg,u
                    bra       aw8@
AudChannel          lda       6,x
                    cmpa      apart+1,u
                    bne       aw8@
                    ldd       achn,u
                    bpl       aw8@
                    ldd       asrc,u
                    std       achn,u
                    bra       aw8@
AudInstrument       lda       6,x
                    cmpa      apart+1,u
                    bne       aw8@
                    ldd       ains,u
                    bpl       aw8@
                    ldd       asrc,u
                    std       ains,u
aw8@                ldd       asrc,u
                    bra       aw1@
* how many events: the tempo, an opening bar, the note, the closing bar, plus meter, key, channel and
* instrument when found
aw9@                ldd       #4
                    ldx       atsg,u
                    bmi       aw10@
                    addd      #1
aw10@               ldx       aksg,u
                    bmi       aw11@
                    addd      #1
aw11@               ldx       achn,u
                    bmi       AudCountInstrument
                    addd      #1
AudCountInstrument  ldx       ains,u
                    bmi       AudCountDone
                    addd      #1
AudCountDone        std       acnt,u
                    cmpd      #MAXTEMP
                    lbhi      AudFail
* the temporary page is the one past the score's last; pswap creates it on the first PutChunk
                    ldd       <vPages
                    addd      #1
                    std       apage,u
                    clra
                    clrb
                    std       awr,u
                    std       anum,u
                    leax      abuf,u
                    stx       abp,u
* Attributes at time 0: meter, then tempo (one change to the player), key and routes.
                    ldd       atsg,u
                    bmi       aw12@
                    lbsr      CopyAttr
                    lbeq      AudFail
aw12@               lbsr      TempoEvent
                    ldd       aksg,u
                    bmi       aw13@
                    lbsr      CopyAttr
                    lbeq      AudFail
aw13@               ldd       achn,u
                    bmi       AudCopyInstrument
                    lbsr      CopyAttr
                    lbeq      AudFail
AudCopyInstrument   ldd       ains,u
                    bmi       AudCopyDone
                    lbsr      CopyAttr
                    lbeq      AudFail
AudCopyDone         lbsr      PutChunk
                    lbeq      AudFail
* the note alone: an opening bar at time 0, the note at time 0, the closing bar at its end
                    lbsr      OpeningBar
                    ldd       aidx,u
                    lbsr      EventAt
                    lbeq      AudFail
                    lbsr      CopyRebased
* Imported MIDI/Lyra notation normally yields to companion raw events.
* This temporary score contains only the clicked note: make that copy audible.
                    ldx       abp,u
                    ldb       -1,x
                    cmpb      #$82
                    bne       aw16@
                    ldb       #2
                    stb       -1,x
aw16@               lbsr      ClosingBar
                    lbsr      PutChunk            the page is mapped from here on
                    lbeq      AudFail
* the real event count parked in the slot after the last temporary event, then the swap
                    ldd       acnt,u
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    addd      <vBase
                    tfr       d,x
                    ldd       <vEvents
                    std       ,x
                    lbsr      SwapPage1
                    clra
                    clrb
                    pshs      d
                    jsr       [>vPswap]           nothing mapped: the next i2p brings in the new page 1
                    leas      2,s
                    ldd       acnt,u
                    std       <vEvents
                    lbra      DExit               D = the count
AudFail             clra
                    clrb
                    lbra      DExit

* ---- 'z': the real score back in page 1 ---------------------------------------------------------
AudRestore          ldd       <vPages
                    std       apage,u             the temporary page is the last one
                    ldd       #1
                    pshs      d
                    jsr       [>vPswap]           page 1 = the temporary score: read the parked count
                    leas      2,s
                    ldd       <vEvents
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    addd      <vBase
                    tfr       d,x
                    ldd       ,x
                    std       awr,u               the real count
                    clra
                    clrb
                    pshs      d
                    jsr       [>vPswap]           nothing mapped
                    leas      2,s
                    lbsr      SwapPage1
                    ldd       awr,u
                    std       <vEvents
                    jsr       [>vGiveback]        the pages above the score's last go: the temporary one
                    clra
                    clrb
                    lbra      DExit

* EventAt: D = an index -> X = its record (i2p); Z set (X = 0) when its page cannot be mapped
EventAt             pshs      d
                    jsr       [>pMidiEventPtr]
                    leas      2,s
                    tfr       d,x
                    leax      ,x                  Z from X
                    rts
* CopyRebased: X = a record -> appended to the chunk, its time less abase
CopyRebased         pshs      y
                    ldy       abp,u
                    ldd       ,x
                    std       ,y
                    ldd       2,x
                    std       2,y
                    ldd       4,x
                    std       4,y
                    ldd       6,x
                    std       6,y
                    ldd       1,y
                    subd      abase,u
                    std       1,y
cr1@                leay      8,y
                    sty       abp,u
                    puls      y
                    lbra      ChunkPlus
* CopyAttr: D = an index -> its record appended to the chunk at time 0; Z set when it cannot be read
CopyAttr            lbsr      EventAt
                    beq       ca9@
                    lbsr      CopyRebased
                    ldx       abp,u
                    clr       -7,x
                    clr       -6,x                time 0
                    leax      ,x                  not Z
ca9@                rts
* TempoEvent: preserve the complete native tempo in force, else use 120, at time 0.
TempoEvent          ldb       #120
                    ldx       atmp,u
                    bmi       te1@
                    tfr       x,d
                    lbsr      EventAt
                    beq       te0@
                    ldd       atmp,u
                    lbra      CopyAttr            includes native high byte / LY tag for imported tempo
te0@                ldb       #120
te1@                tstb
                    bne       te2@
                    incb                          never 0
te2@                pshs      y
                    ldy       abp,u
                    clr       ,y                  part 0
                    clr       1,y
                    clr       2,y                 time 0
                    stb       3,y                 the tempo
                    clr       4,y
                    lda       #EvTempo
                    sta       5,y
                    clr       6,y
                    clr       7,y
                    leay      8,y
                    sty       abp,u
                    puls      y
                    bra       ChunkPlus
* OpeningBar: a plain bar line at time 0
OpeningBar          pshs      y
                    ldy       abp,u
                    clr       ,y
                    clr       1,y
                    clr       2,y
                    clr       3,y
                    clr       4,y
                    clr       5,y                 code 0: SINGLEBAR
                    clr       6,y
                    clr       7,y
                    leay      8,y
                    sty       abp,u
                    puls      y
                    bra       ChunkPlus
* ClosingBar: a plain bar line at the note's end, so the player holds the last notes until then
ClosingBar          pshs      y
                    ldy       abp,u
                    clr       ,y
                    ldd       aend,u
                    subd      abase,u
                    std       1,y
                    clr       3,y
                    clr       4,y
                    clr       5,y                 code 0: SINGLEBAR
                    clr       6,y
                    clr       7,y
                    leay      8,y
                    sty       abp,u
                    puls      y
ChunkPlus           ldd       anum,u
                    addd      #1
                    std       anum,u
                    rts
* PutChunk: the chunk's events -> the temporary page at awr; D = 0 when the page cannot be mapped
PutChunk            ldd       apage,u
                    pshs      d
                    jsr       [>vPswap]
                    leas      2,s
                    cmpd      #0
                    beq       pc9@
                    ldd       awr,u
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    addd      <vBase
                    pshs      y
                    tfr       d,y                 the destination
                    leax      abuf,u
                    ldd       anum,u
                    beq       pc2@
pc1@                pshs      d
                    ldd       ,x++
                    std       ,y++
                    ldd       ,x++
                    std       ,y++
                    ldd       ,x++
                    std       ,y++
                    ldd       ,x++
                    std       ,y++
                    puls      d
                    subd      #1
                    bne       pc1@
pc2@                puls      y
                    ldd       awr,u
                    addd      anum,u
                    std       awr,u
                    leax      abuf,u
                    stx       abp,u
                    clra
                    clrb
                    std       anum,u
                    ldd       #1
pc9@                rts
* SwapPage1: the buffer table entries of page 1 and the temporary page change places
SwapPage1           ldx       #vGPTab
                    ldb       apage+1,u
                    abx
                    lda       ,x                  the temporary page's block
                    ldb       >vGPTab+1           page 1's
                    stb       ,x
                    sta       >vGPTab+1
                    rts

* RunMenu - place the box at the press, draw it, run the picker, take it down. B = the result.
RunMenu             pshs      x,y
                    ldd       <CtxX               the pointer X (640 dots)
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb                          the press's byte column (80 a row)
                    cmpd      #80-MENU_WIDE-2
                    ble       rm1@
                    ldd       #80-MENU_WIDE-2     keep the box on the sheet
rm1@                cmpd      #1
                    bge       rm2@
                    ldd       #1
rm2@                std       mcol,u
                    lda       #MENU_PITCH
                    ldb       mrows+1,u
                    mul                           rows * pitch
                    addd      #7                  + the border: the box is rows+1 text rows tall
                    std       mtopy,u             for now: the box's height
                    ldd       <CtxY
                    cmpd      mtopy,u
                    bge       rm3@
                    ldd       mtopy,u             raise it so the last row stays above the bottom
rm3@                cmpd      #191
                    ble       rm4@
                    ldd       #191
rm4@                std       mtopy,u
* the packet: $B9 col y rows width, then the labels
                    ldd       #MENU_WIDE
                    pshs      a,b
                    ldd       mrows,u
                    pshs      a,b
                    ldd       mtopy,u
                    pshs      a,b
                    ldd       mcol,u
                    pshs      a,b
                    ldd       #$00B9
                    pshs      a,b
                    leax      >fmtMenu,pcr        '%c%c%c%c%c'
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      12,s
                    ldd       mrows,u
                    pshs      a,b
rm5@                ldx       mlabels,u
                    pshs      x
                    ldx       mkeys,u
                    ldb       ,x+                 the row's key letter (a space: a title row)
                    stx       mkeys,u
                    clra
                    pshs      d
                    leax      >fmtLine,pcr        the row goes out as key, label, CR
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      6,s
                    ldx       mlabels,u
rm6@                lda       ,x+                 past this label's terminator
                    bne       rm6@
                    stx       mlabels,u
                    ldd       ,s
                    subd      #1
                    std       ,s
                    bne       rm5@
                    leas      2,s
* s9gui runs the hover loop and answers; pipemenu feeds it the mouse
                    jsr       [>pPipeMenu]        B = the key letter chosen, CR = closed (it flushes the rows itself:
*                                                 the $0379 flush would add $CD CR in front of the first mouse packet)
                    pshs      b
* down again: $C7 closes the saved window
                    ldd       #$00C7
                    pshs      a,b
                    ldd       <UmeData_reserved_0016 the '%c' format (pctn1)
                    pshs      a,b
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    jsr       [>UmeData_pflush]
                    puls      b
                    puls      x,y,pc

fmtMenu             fcc       /%c%c%c%c%c/
                    fcb       0
fmtLine             fcc       /%c%s/
                    fcb       C$CR,0

* ---- the NOTE menu: one label a row (CR goes out after each), one key letter a row (a space is a
* row without a button: the picker leaves it alone)
noteRows            fcc       /Delete/            the X tool's action: clones go, a flagship note becomes a rest
                    fcb       0                   (more rows: add a label here, a key letter below, and raise the count)
noteKeys            fcc       /d/
                    fcb       0
                    fill      0,$1D00-*           >= $1D00 bytes, so F$Link never puts this overlay in slot 7 (the score page's slot)
                    emod
eom                 equ       *
