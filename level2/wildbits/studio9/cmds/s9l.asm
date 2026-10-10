********************************************************************
* s9l - Studio-9 Layout overlay: the mouse-driven score editor (staff and part layout)
* Ported from the UltiMusE III 10.11.4e module (disassembled byte-exact); routine names are
* evidence-based readings. Local labels read a<n>@, b<n>@: the letter is the label, n the routine.
* Event pages hold 928 records ($03A0), not the original 1020, so a page fits the $1D00
* visible bytes of DAT slot 7; SeekEvent's page divide carries the constant.
*
* s9 runs it through [psoowee]; start lbra's to LayoutMain (a C function; the low byte of its
* third argument is echoed in the $B1 range command). All display goes through [pprintf]: the
* direct-page streams <$0A..<$20 point at "%c%c..." formats, so every wrapper prints a one-byte
* s9gui command >= $80 plus parameters ($88 draw staff, $89 erase staff, $8A draw part icon, $8B
* erase part, $8C key sig, $8E time sig, $9A mode, $9B drag icon, $9F highlight staff, $B1 range
* display, $C0 text, $C2 drag glyph, $C3/$C7 begin/end busy, $C4 menu select, $C6 prompt box);
* [pflush] flushes the pipe.
* Entry path: LayoutMain selects the panel and sends its text (SendPanelText), sets mode 1, draws
* all parts (DrawParts) and staves (DrawStaves), shows the key/time signatures (ShowSignatures),
* then MainLoop: AwaitInput ([pkeymaus] waits for a click or key); a click is classified against
* the right-hand panel (HitDeleteBtn -> mode 6, HitPartTypeBtns -> modes $1C-$1F and HitClefBtns
* -> modes $20-$26, both through GlyphPress for a click or a drag; HitCmdMenu -> a menu row's
* letter) or the picture (PictureHit: zone 1 staff handle, 4 part icon, 5 empty part slot, 6 left
* margin); letters go through KeyDispatch (strMenuKeys documents the menu rows).
* Zone x mode handlers: AddStaff (max 7), ChangeClef (+TransposeForClef for every part on the
* staff), ChangePartType (with Remove/Restore Rests questions), AddPart (max 16, refills rests),
* DeleteStaff (refuses while parts sit on it), ForgetPart ("Forgetting Part X. Sure?": erase its
* events, shift the tables, RenumberParts), DragStaff / DragPart / DropPart (mouse tracking with
* [pmouce]).
* Shared data in s9's data area: nparts, nstaves, curcurse (the mode), time signature <$03/<$05,
* keysig, staff table $0C19 (10 bytes: y, clef), part table $0C5F (4 bytes: staff, flags; bit0/1
* above/below, bit2 and bit4 the two part-type buttons), clef offset table $0162, the per-part
* bytes MidiPartOn/MidiChanTbl; events: 8 bytes, 928 per page, nevents, curind, curevp, the page
* bounds database/curptop, curpage ([ppswap] loads a page). Event: byte0 part (0 = global), byte5
* pitch/type ($20 rest, <= 6 bar line, $0A time sig, $0B key sig), byte6 part reference for the
* global types $16/$17/$18/$1E/$20.
* Score helpers: RefillRests inserts rests ([pregen], [penter]) into every bar where the part is
* silent; ErasePartEvents deletes rests, rest-only bars or everything of a part in a range
* ([premove]); IsBarLine delimits bars. C library tail: MemCopy, StrCopy, long helpers
* (LongAdd/LongFromInt/StoreLong on the $0343,y accumulator), Mul16, DivMod16 with the DivByZero
* -> RaiseSignal (F$ID + F$Send) trap. The fcb data after RaiseSignal is the original idata image
* (with Mike Knudsen's "Hi, Lester!" note).

                    nam       s9l
                    ttl       s9l (disassembly)

                  IFP1
                    use       defsfile
                  ENDC
UME_SCOPE_S9L                  equ       1
                    use       equates.asm

tylg                set       $11
atrv                set       $81
size                equ       $104C

                    mod       eom,name,tylg,atrv,start,size
name                fcs       /s9l/
                    fcb       $06
start               equ       *
                    lbra      LayoutMain
                    fcb       $39,$0D,$00
* LayoutMain: overlay entry (start lbra's here): frame $82, args at $86,s; saves curcurse, selects menu 12 and sends the panel text, mode 1, draws parts/staves, shows the signatures, then the input loop; ExitLayout returns to s9 restoring curcurse
LayoutMain          pshs      u
                    leas      >-$0082,s
                    ldd       <UmeData_curcurse
                    std       <$2A,s
                    ldd       #$000C              one menu for every case
                    pshs      a,b
                    lbsr      SelectMenu
                    leas      2,s
                    jsr       [>UmeData_pflush]            flush: s9gui draws the panel before the text arrives
                    lbsr      SendPanelText       the title and the menu rows
                    ldd       #$0001
                    stb       <UmeData_rfr_bar
                    stb       <UmeData_rfr_scr
                    stb       <$2F,s
                    ldd       #$0001
                    std       <UmeData_curcurse
                    pshs      a,b
                    lbsr      SetMode
                    leas      2,s
                    ldd       <UmeData_nstaves
                    beq       c1@
                    ldd       <UmeData_nparts
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    lbsr      DrawParts
                    leas      4,s
                    ldd       <UmeData_nstaves
                    addd      #$FFFF
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    lbsr      DrawStaves
                    leas      4,s
c1@                 lbsr      ShowSignatures
* MainLoop: top of the layout event loop; RangeDisplay(arg3, 0) when the changed flag <$2F,s is set
MainLoop            ldb       <$2F,s
                    beq       AwaitInput
                    clra
                    clrb
                    pshs      a,b
                    ldb       >$008B,s
                    sex
                    pshs      a,b
                    lbsr      RangeDisplay
                    leas      4,s
* AwaitInput: after a drop the mode goes back to select (LayDropReset); clears the changed flag, column limit <$14,s = 3*(parts + (parts < 16)) + 10; [pkeymaus] (s9's keymouse: waits for a click or key, the menu hover on meanwhile) -> key in <$30,s, x in ,s, y in <$1A,s, column x/8 in <$1C,s
AwaitInput          tst       <LayDropReset
                    beq       awi1@
                    clr       <LayDropReset       a drag was dropped: back to the select mode
                    ldd       #$0001
                    pshs      a,b
                    lbsr      SetMode
                    leas      2,s
awi1@               clra
                    clrb
                    stb       <$2F,s
                    ldd       <UmeData_nparts
                    cmpd      #$0010
                    bge       a2@
                    ldd       #$0001
                    bra       b2@
a2@                 clra
                    clrb
b2@                 addd      <UmeData_nparts
                    pshs      a,b
                    ldd       #$0003
                    lbsr      Mul16
                    addd      #$000A
                    std       <$14,s
                    leax      <$1A,s
                    pshs      x
                    leax      2,s
                    pshs      x
                    ldb       #$FF
                    stb       <LayHov             the menu hover is on while keymouse waits
                    jsr       [>UmeData_pkeymaus]
                    clr       <LayHov             (keymouse un-inverted the row before returning)
                    leas      4,s
                    stb       <$30,s
                    ldd       ,s
                    asra
                    rorb
                    asra
                    rorb
                    asra
                    rorb
                    std       <$1C,s
                    ldb       <$30,s
                    bne       HitDeleteBtn
                    ldd       <$1C,s
                    cmpd      #$003B+LayDX       left of the panel (LayDX: the panel's column shift)
                    lble      PictureHit
* HitDeleteBtn: InRect(col, y, 75..78 (+LayDX), 44..58): the X/delete button -> SetMode(6)
HitDeleteBtn        ldd       #$003A
                    pshs      a,b
                    ldd       #$004E+LayDX
                    pshs      a,b
                    ldd       #$002C
                    pshs      a,b
                    ldd       #$004B+LayDX
                    pshs      a,b
                    ldd       <$22,s
                    pshs      a,b
                    ldd       <$26,s
                    pshs      a,b
                    lbsr      InRect
                    leas      12,s
                    std       -2,s
                    beq       HitPartTypeBtns
                    ldd       #$0006
                    std       <UmeData_curcurse
                    pshs      a,b
                    lbsr      SetMode
                    leas      2,s
                    lbra      ToMainLoopEarly
* HitPartTypeBtns: the four part-type icons drawn by s9gui's laymenu: hot box columns 61..74 (+LayDX),
* rows 44..66; mode $1C + (col-61)/3, the index clamped to 3, then GlyphPress
HitPartTypeBtns     ldd       #$0042              rows up to 66
                    pshs      a,b
                    ldd       #$004A+LayDX        columns up to 74 (75 starts the X button)
                    pshs      a,b
                    ldd       #$002C              rows from 44
                    pshs      a,b
                    ldd       #$003D+LayDX        columns from 61
                    pshs      a,b
                    ldd       <$22,s
                    pshs      a,b
                    ldd       <$26,s
                    pshs      a,b
                    lbsr      InRect
                    leas      12,s
                    std       -2,s
                    beq       HitClefBtns
                    ldd       <$1C,s
                    addd      #-($003D+LayDX)     col - 61
                    pshs      a,b
                    ldd       #$0003
                    lbsr      DivMod16
                    cmpd      #$0003
                    ble       hptb1@
                    ldd       #$0003              the fourth icon at most
hptb1@              std       <$28,s
                    addd      #$001C
                    std       <UmeData_curcurse
                    ldd       #$0002
                    lbra      GlyphPress          a voice icon: click or drag
* HitClefBtns: InRect(col, y, 60..77 (+LayDX), 12..43): seven clef icons LayClefPitch bytes apart; index = (x - LayClefByte0*2) / (LayClefPitch*2), clamped to 0..6; mode $20 + index, then GlyphPress
HitClefBtns         ldd       #$002B              rows up to 43
                    pshs      a,b
                    ldd       #$004D+LayDX
                    pshs      a,b
                    ldd       #$0005+LayUp+LayDY  rows from 12
                    pshs      a,b
                    ldd       #$003C+LayDX
                    pshs      a,b
                    ldd       <$22,s
                    pshs      a,b
                    ldd       <$26,s
                    pshs      a,b
                    lbsr      InRect
                    leas      12,s
                    std       -2,s
                    lbeq      HitCmdMenu
                    ldd       ,s                  the pointer's x in dots
                    subd      #LayClefByte0*2     - the first clef's left dot
                    bpl       hcb1@
                    clra
                    clrb
hcb1@               pshs      a,b
                    ldd       #LayClefPitch*2
                    lbsr      DivMod16
                    cmpd      #$0006
                    ble       hcb2@
                    ldd       #$0006              the seventh clef at most
hcb2@               std       <$28,s
                    addd      #$0020
                    std       <UmeData_curcurse
                    ldd       #$0001
                    lbra      GlyphPress          a clef icon: click or drag
* GlyphPress: D = 1 a clef, 2 a voice icon; the mode is in curcurse and the icon index in <$28,s. Released
* within the countdown (9 polls 4 ticks apart) = a plain click: the mode stays armed for the next click.
* Still held = s9gui gets the glyph ($C2 kind index) and it follows the pointer ($9B x y, DragIconAt) until
* the release. The drop: a clef on a staff = ChangeClef, a clef on the sheet = AddStaff there, a voice icon
* on a staff = AddPart to that staff; anything else = nothing. The glyph is hidden ($C2 0 0 0) and the next
* wait puts the mode back to select (LayDropReset).
GlyphPress          pshs      a,b                 ,s the kind; the frame slots are 2 further down
                    ldd       <UmeData_curcurse
                    pshs      a,b
                    lbsr      SetMode             the mode to s9gui, as SetModeLoop does
                    leas      2,s
                    ldx       #9                  polls four ticks apart before the drag starts (about half a second; F$Sleep 1 only yields)
                    pshs      x                   ,s the countdown  2,s the kind; the frame is 4 further down
gp1@                leax      <$1E,s              y -> the frame's <$1A,s
                    pshs      x
                    leax      6,s                 x -> the frame's ,s
                    pshs      x
                    jsr       [>UmeData_pmouce]            mouce: D = the button level, x and y filled in
                    leas      4,s
                    cmpd      #$0000
                    lbeq      gp9a@               released: a plain click
                    ldx       #$0004
                    os9       F$Sleep             four ticks (X only; Y, the static base, is kept)
                    ldx       ,s
                    leax      -1,x
                    stx       ,s
                    bne       gp1@
                    leas      2,s                 the countdown; ,s the kind again
                    clra
                    clrb
                    pshs      a,b
                    ldd       <$2C,s              the icon index (frame <$28,s)
                    pshs      a,b
                    ldd       4,s                 the kind
                    pshs      a,b
                    ldd       #$00C2
                    pshs      a,b
                    ldd       <UmeData_reserved_000E                '%c%c%c%c\r'
                    pshs      a,b
                    jsr       [>UmeData_pprintf]            $C2 kind index 0: s9gui arms the glyph
                    leas      10,s
                    ldd       #$FFFF
                    pshs      a,b                 ,s the y last sent  (kind at 2,s; the frame 4 further down)
                    pshs      a,b                 ,s the x last sent  2,s the y
gp2@                ldd       <$20,s              y (the frame's <$1A,s)
                    cmpd      2,s
                    bne       gp2a@
                    ldd       6,s                 x (the frame's ,s)
                    cmpd      ,s
                    beq       gp2b@               the pointer has not moved: nothing to draw
gp2a@               ldd       <$20,s
                    std       2,s
                    ldd       6,s
                    std       ,s
                    ldd       <$20,s
                    pshs      a,b
                    ldd       8,s                 x
                    pshs      a,b
                    lbsr      DragIconAt          $9B x y: the glyph at the pointer
                    leas      4,s
                    jsr       [>UmeData_pflush]            flush: s9gui draws it now
gp2b@               ldx       #$0001
                    os9       F$Sleep             a yield between polls
                    leax      <$20,s
                    pshs      x
                    leax      8,s
                    pshs      x
                    jsr       [>UmeData_pmouce]
                    leas      4,s
                    cmpd      #$0000
                    lbne      gp2@                still held
                    leas      4,s                 the last x and y
                    clra
                    clrb
                    pshs      a,b
                    pshs      a,b
                    pshs      a,b
                    ldd       #$00C2
                    pshs      a,b
                    ldd       <UmeData_reserved_000E
                    pshs      a,b
                    jsr       [>UmeData_pprintf]            $C2 0 0 0: the glyph goes
                    leas      10,s
                    jsr       [>UmeData_pflush]
                    ldb       #1
                    stb       <LayDropReset
                    puls      a,b                 the kind; the frame is back at ,s
                    pshs      a,b
                    ldd       2,s                 x
                    asra
                    rorb
                    asra
                    rorb
                    asra
                    rorb
                    std       <$1E,s              the column (frame <$1C,s + 2)
                    ldd       <$1C,s              y (frame <$1A,s + 2)
                    pshs      a,b
                    jsr       [>UmeData_pfindstaff]            the staff at that y, or >= the count
                    leas      2,s
                    std       <$28,s              the staff (frame <$26,s + 2)
                    puls      x                   X = the kind, the frame at ,s
                    cmpx      #$0002
                    lbeq      gpVoice@
* a clef
                    ldd       <$26,s
                    cmpd      <UmeData_nstaves
                    lbge      gpc1@
                    ldd       #$0001
                    std       <$12,s              zone 1: a staff handle
                    lbra      ChangeClef
gpc1@               ldd       <$1C,s
                    cmpd      #$0001
                    lblt      gpNone@
                    cmpd      #$003B+LayDX
                    lbge      gpNone@             the panel: nothing
                    ldd       <UmeData_nstaves
                    cmpd      #$0007
                    lbge      gpNone@             no more staves
                    lbra      AddStaff            a new staff at the drop (its y - 8)
gpVoice@            ldd       <$26,s
                    cmpd      <UmeData_nstaves
                    lbge      gpNone@             no staff there
                    ldd       <UmeData_nparts
                    addd      #$0001
                    std       <$24,s              the new part number
                    ldd       #$0005
                    std       <$12,s              zone 5: a new part slot
                    ldd       <$26,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      Mul16
                    ldx       #$0C19
                    leax      d,x
                    ldd       ,x
                    std       10,s                the staff's y, as HitNewPartSlot leaves it
                    lbra      AddPart
gpNone@             lbra      ToMainLoop
gp9a@               leas      2,s                 the countdown
gp9@                leas      2,s                 the kind
                    lbra      ToMainLoop
* HitCmdMenu: a key goes straight to MenuKeyPick; a click must fall in InRect(col, y, MenuBarLeft..MenuBarRight,
* the MenuRows rows from MenuRowY0 down); a miss -> SetSelectMode
HitCmdMenu          ldb       <$30,s
                    bne       MenuKeyPick
                    ldd       #MenuRowY0+4        row 0 reaches up to MenuRowY0 + 4
                    pshs      a,b
                    ldd       #MenuBarRight
                    pshs      a,b
                    ldd       #MenuRowY0-(MenuRows-1)*MenuRowPitch-2   row 13 reaches down to MenuRowY0 - 91 - 2
                    pshs      a,b
                    ldd       #MenuBarLeft
                    pshs      a,b
                    ldd       <$22,s
                    pshs      a,b
                    ldd       <$26,s
                    pshs      a,b
                    lbsr      InRect
                    leas      12,s
                    std       -2,s
                    lbeq      SetSelectMode
* MenuKeyPick: for a click, row = (MenuRowY0 + 4 - y) / 7 indexes strMenuKeys for the command letter; then KeyDispatch
MenuKeyPick         ldb       <$30,s
                    bne       c4@
                    ldd       #MenuRowY0+4
                    subd      <$1A,s
                    pshs      a,b
                    ldd       #$0007
                    lbsr      DivMod16
                    std       <$28,s
                    leax      >strMenuKeys,pcr
                    tfr       x,d
                    ldx       <$28,s
                    leax      d,x
                    ldb       ,x
                    stb       <$30,s
c4@                 ldb       <$30,s
                    sex
                    tfr       d,x
                    lbra      KeyDispatch
* KeyStaves: 's': asks msgRenumberStaves -> [psoowee]('E','n') runs overlay s9e; asks msgSpaceStaves -> SpaceStaves; redraws all staves
KeyStaves           leax      >msgRenumberStaves,pcr
                    pshs      x
                    jsr       [>UmeData_pyesno]
                    std       ,s++
                    beq       AskSpaceStaves
                    ldd       #$006E
                    pshs      a,b
                    ldd       #$0045
                    pshs      a,b
                    jsr       [>UmeData_psoowee]
                    leas      4,s
* AskSpaceStaves: second question of KeyStaves: 'Space Staves equally?' -> SpaceStaves
AskSpaceStaves      leax      >msgSpaceStaves,pcr
                    pshs      x
                    jsr       [>UmeData_pyesno]
                    std       ,s++
                    beq       a5@
                    lbsr      SpaceStaves
a5@                 ldd       <UmeData_nstaves
                    addd      #$FFFF
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    lbsr      DrawStaves
                    leas      4,s
                    lbra      RedrawPartsAndMark
* KeyOrderParts: 'o'/'p': asks msgReorderParts (all staves, then msgSegregateClones) else AskWhichStaff; runs overlay s9e 'o'
KeyOrderParts       leax      >msgReorderParts,pcr
                    pshs      x
                    jsr       [>UmeData_pyesno]
                    std       ,s++
                    beq       AskWhichStaff
                    ldd       #$FFFF
                    std       <$26,s
                    leax      >msgSegregateClones,pcr
                    pshs      x
                    jsr       [>UmeData_pyesno]
                    leas      2,s
                    stb       <$2E,s
                    bra       RunUm3EReorder
* AskWhichStaff: opens the prompt box, prints msgWhichStaff, reads a line ([pgets]); (digit - '1') & 7 -> staff number
AskWhichStaff       clra
                    clrb
                    stb       <$2E,s
                    sex
                    pshs      a,b
                    lbsr      StaffPromptBox
                    leas      2,s
                    leax      >msgWhichStaff,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    leax      <$31,s
                    pshs      x
                    jsr       [>UmeData_pgets]
                    leas      2,s
                    lbsr      EndBusy
                    ldb       <$31,s
                    lbeq      ToMainLoopEarly
                    ldb       <$31,s
                    sex
                    addd      #$FFCF
                    clra
                    andb      #$07
                    std       <$26,s
* RunUm3EReorder: [psoowee]('E', 'o', staff, segregate flag) runs overlay s9e to re-order parts, then redraws parts
RunUm3EReorder      ldb       <$2E,s
                    sex
                    pshs      a,b
                    ldd       <$28,s
                    pshs      a,b
                    ldd       #$006F
                    pshs      a,b
                    ldd       #$0045
                    pshs      a,b
                    jsr       [>UmeData_psoowee]
                    leas      8,s
* RedrawPartsAndMark: shared tail of KeyStaves (lbra) and RunUm3EReorder (falls in): DrawParts(1, count) then MarkChangedLoop
RedrawPartsAndMark  ldd       <UmeData_nparts
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    lbsr      DrawParts
                    leas      4,s
                    lbra      MarkChangedLoop
* KeyRange: 'r': [pfixmarx] selects the bracketed range, mode 2, ShowPartRanges(start, end), [phit] 'Hit ENTER or CLICK', restores the mode
KeyRange            leax      2,s
                    pshs      x
                    leax      6,s
                    pshs      x
                    leax      10,s
                    pshs      x
                    jsr       [>UmeData_pfixmarx]
                    leas      6,s
                    lbeq      ToMainLoopEarly
                    ldd       <UmeData_curcurse
                    std       <$2C,s
                    ldd       #$0002
                    pshs      a,b
                    lbsr      SetMode
                    leas      2,s
                    ldd       4,s
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    lbsr      ShowPartRanges
                    leas      4,s
                    jsr       [>UmeData_phit]
                    ldd       <$2C,s
                    pshs      a,b
                    lbsr      SetMode
                    leas      2,s
                    lbsr      EndBusy
                    bra       MarkChangedLoop
* KeyOctaveUp: '+'/'=': mode $17; on a part icon OctaveShift calls [ptranprt](part, +7, start, end) = 7 staff steps up
KeyOctaveUp         ldd       #$0017
                    lbra      SetModeLoop
* KeyOctaveDown: '-': mode $18, later [ptranprt](part, -7, start, end)
KeyOctaveDown       ldd       #$0018
                    lbra      SetModeLoop
* KeyRefill: 'f': mode $19 = refill rests in the selected range (RefillRange -> RefillRests)
KeyRefill           ldd       #$0019
                    lbra      SetModeLoop
* KeyStripOrTime: 't': mode $1A, strip rests / rest-only bars (ErasePartEvents without the all flag); 'T' is DoTimeSig
KeyStripOrTime      ldd       #$001A
                    lbra      SetModeLoop
* DoTimeSig: 'T': [pgtsig] time-signature dialog, then printf($8E, <$03, <$05) shows it
DoTimeSig           jsr       [>UmeData_pgtsig]
                    ldd       <UmeData_reserved_0005
                    pshs      a,b
                    ldd       <UmeData_reserved_0003
                    pshs      a,b
                    ldd       #$008E
                    pshs      a,b
                    ldd       <UmeData_reserved_000C
                    pshs      a,b
                    jsr       [>UmeData_pprintf]
                    leas      8,s
                    bra       MarkChangedLoop
* KeyClear: 'c': mode $1B = ClearRange with the all flag (ErasePartEvents deletes every event of the part in the range)
KeyClear            ldd       #$001B
                    lbra      SetModeLoop
* KeyKeySig: 'k': [pgksig] key-signature dialog, then printf($8C, key)
KeyKeySig           jsr       [>UmeData_pgksig]
                    pshs      a,b
                    ldd       #$008C
                    pshs      a,b
                    ldd       <UmeData_reserved_000A
                    pshs      a,b
                    jsr       [>UmeData_pprintf]
                    leas      6,s
* MarkChangedLoop: sets the changed flag <$2F,s = 1, then ToMainLoopEarly; KeyRange, DoTimeSig and KeyKeySig come here
MarkChangedLoop     ldd       #$0001
                    stb       <$2F,s
                    lbra      ToMainLoopEarly
* KeyExitQuit: the Apply changes row and CR: WizForce = 2 tells s9's Score handler to keep the score (it
* builds bars only when there are none); KeyExit refills the parts' rests on the way out.
KeyExitQuit         ldb       #$02
                    stb       <WizForce
                    lbra      KeyExit             the refill on the way out
* KeyWizard: the Score wizard row: out with WizForce = 3; s9's Score handler then runs newscore with the
* layout prompts.
KeyWizard           ldb       #$03
                    stb       <WizForce
                    lbra      ExitLayout
* KeyExitNoChange: the 'Exit, no change' row: out with WizForce = 2 like Apply changes, no refill, no busy.
KeyExitNoChange     ldb       #$02
                    stb       <WizForce
                    lbra      ExitLayout
* KeyExit: the New score row, also the end of KeyExitQuit: a time signature still at 4/4 is re-sent ($8E 4 4)
* so it shows as common time, one entered with 'Time sig' stands; every non-clone part gets its rests
* refilled over the whole score (RefillRests), then ExitLayout.
KeyExit             ldd       <UmeData_reserved_0003                time signature 4/4?
                    cmpd      #$0004
                    bne       KeyExitRests        a time signature entered with 'Time sig' stands
                    ldd       <UmeData_reserved_0005
                    cmpd      #$0004
                    bne       KeyExitRests
a6@                 ldd       <UmeData_reserved_0005
                    pshs      a,b
                    ldd       <UmeData_reserved_0003
                    pshs      a,b
                    ldd       #$008E
                    pshs      a,b
                    ldd       <UmeData_reserved_000C
                    pshs      a,b
                    jsr       [>UmeData_pprintf]
                    leas      8,s
KeyExitRests        lbsr      BeginBusy
                    ldd       #$0001
                    pshs      a,b                 ,s the part, 1..nparts
KeyExitR1           ldd       ,s
                    cmpd      <UmeData_nparts
                    bgt       KeyExitR2
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$0C5F
                    leax      d,x
                    ldb       3,x                 the part's flags, low byte
                    andb      #$04
                    bne       KeyExitR3           a clone: no rests of its own
                    ldd       ,s
                    pshs      a,b                 the part
                    ldd       <UmeData_nevents
                    addd      #$FFFF
                    pshs      a,b                 end = the last event
                    clra
                    clrb
                    pshs      a,b                 start = the first
                    lbsr      RefillRests
                    leas      6,s
KeyExitR3           ldd       ,s
                    addd      #$0001
                    std       ,s
                    bra       KeyExitR1
KeyExitR2           leas      2,s
                    lbsr      EndBusy
* ExitLayout: function exit: EndBusy, restore the caller's mode <$2A,s via SetMode, leas $82 / puls u,pc
ExitLayout          lbsr      EndBusy
                    ldd       <$2A,s
                    pshs      a,b
                    lbsr      SetMode
                    leas      2,s
                    leas      >$0082,s
                    puls      u,pc
* KeyDelete: 'x': mode 6 (delete part / staff on the next click)
KeyDelete           ldd       #$0006
                    lbra      SetModeLoop
* KeyDispatch: cmpx chain on the command letter: s p o r = + - f t c k T w n CR q e x space; unknown -> ClearMsgAndLoop
KeyDispatch         cmpx      #$0073
                    lbeq      KeyStaves
                    cmpx      #$0070
                    lbeq      KeyOrderParts
                    cmpx      #$006F
                    lbeq      KeyOrderParts
                    cmpx      #$0072
                    lbeq      KeyRange
                    cmpx      #$003D
                    lbeq      KeyOctaveUp
                    cmpx      #$002B
                    lbeq      KeyOctaveUp
                    cmpx      #$002D
                    lbeq      KeyOctaveDown
                    cmpx      #$0066
                    lbeq      KeyRefill
                    cmpx      #$0074
                    lbeq      KeyStripOrTime
                    cmpx      #$0063
                    lbeq      KeyClear
                    cmpx      #$006B
                    lbeq      KeyKeySig
                    cmpx      #$0054
                    lbeq      DoTimeSig           'T': the Time signature row
                    cmpx      #$0077
                    lbeq      KeyWizard           'w': the Score wizard row
                    cmpx      #$006E
                    lbeq      KeyExit             'n': the New score row
                    cmpx      #$000D
                    lbeq      KeyExitQuit         CR: as Apply changes
                    cmpx      #$0071
                    lbeq      KeyExitQuit         'q': the Apply changes row
                    cmpx      #$0065
                    lbeq      KeyExitNoChange     'e': the Exit, no change row
                    cmpx      #$0078
                    lbeq      KeyDelete
                    cmpx      #$0020
                    beq       SetSelectMode
                    lbra      ClearMsgAndLoop
* SetSelectMode: D = 1 into SetModeLoop: the space key and a click that misses the command menu
SetSelectMode       ldd       #$0001
* SetModeLoop: common tail: SetMode(D) then back to MainLoop
SetModeLoop         pshs      a,b
                    lbsr      SetMode
                    leas      2,s
* ToMainLoopEarly: lbra ToMainLoop, a second hop back to MainLoop
ToMainLoopEarly     lbra      ToMainLoop
* PictureHit: click in the layout picture (col <= $3B+LayDX): classifies the zone into <$12,s (0 none, 1 staff handle, 4 part icon, 5 new-part slot, 6 margin)
PictureHit          ldd       <$1C,s
                    cmpd      #$0001
                    lblt      ToMainLoop
                    clra
                    clrb
                    std       <$12,s
                    ldd       <$1C,s
                    cmpd      <$14,s
                    blt       HitStaffMargin
                    ldd       #$0001
                    pshs      a,b
                    lbsr      SetMode
                    leas      2,s
                    lbra      ZoneDispatch
* HitStaffMargin: columns 1..3: zone 6, or zone 1 when [pfindstaff](y) finds a staff (its y kept in 12,s)
HitStaffMargin      ldd       <$1C,s
                    cmpd      #$0001
                    blt       HitPartIcon
                    ldd       <$1C,s
                    cmpd      #$0004
                    bge       HitPartIcon
                    ldd       #$0006
                    std       <$12,s
                    ldd       <$1A,s
                    pshs      a,b
                    jsr       [>UmeData_pfindstaff]
                    leas      2,s
                    std       <$26,s
                    cmpd      <UmeData_nstaves
                    lbge      ZoneDispatch
                    ldd       #$0001
                    std       <$12,s
                    ldd       <$26,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      Mul16
                    ldx       #$0C19
                    leax      d,x
                    ldd       ,x
                    std       12,s
                    lbra      ZoneDispatch
* HitPartIcon: Columns >10: part=(col-11)/3+1; GetPartStaff, icon y = staffY+8 +/-6 by flag bits, zone 4 when y within -3..+2
HitPartIcon         ldd       <$1C,s
                    cmpd      #$000A
                    lble      HitNewPartSlot
                    ldd       <$1C,s
                    addd      #$FFF5
                    pshs      a,b
                    ldd       #$0003
                    lbsr      DivMod16
                    addd      #$0001
                    std       <$24,s
                    cmpd      <UmeData_nparts
                    lbgt      HitNewPartSlot
                    leax      <$1E,s
                    pshs      x
                    leax      12,s
                    pshs      x
                    ldd       <$28,s
                    pshs      a,b
                    lbsr      GetPartStaff
                    leas      6,s
                    std       <$26,s
                    ldd       10,s
                    addd      #$0008
                    pshs      a,b
                    ldd       <$20,s
                    clra
                    andb      #$01
                    beq       a7@
                    ldd       #$0006
                    bra       c7@
a7@                 ldd       <$20,s
                    clra
                    andb      #$02
                    beq       b7@
                    ldd       #$FFFA
                    bra       c7@
b7@                 clra
                    clrb
c7@                 addd      ,s++
                    std       12,s
                    addd      #$FFFD
                    cmpd      <$1A,s
                    bgt       ZoneDispatch
                    ldd       12,s
                    addd      #$0002
                    cmpd      <$1A,s
                    blt       ZoneDispatch
                    ldd       #$0004
                    std       <$12,s
                    bra       ZoneDispatch
* HitNewPartSlot: Column of part count+1 on an existing staff: zone 5 (add part here)
HitNewPartSlot      ldd       <UmeData_nparts
                    addd      #$0001
                    cmpd      <$24,s
                    bne       ZoneDispatch
                    ldd       <$1A,s
                    pshs      a,b
                    jsr       [>UmeData_pfindstaff]
                    leas      2,s
                    std       <$26,s
                    cmpd      <UmeData_nstaves
                    bge       ZoneDispatch
                    ldd       #$0005
                    std       <$12,s
                    ldd       <$26,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      Mul16
                    ldx       #$0C19
                    leax      d,x
                    ldd       ,x
                    std       10,s
* ZoneDispatch: zone 0 -> ClearMsgAndLoop, else ModeSwitch
ZoneDispatch        ldd       <$12,s
                    bne       ModeSwitch
* ClearMsgAndLoop: ClearMsgLine then MainLoop: zone 0 in ZoneDispatch and the unknown-letter arm of KeyDispatch
ClearMsgAndLoop     lbsr      ClearMsgLine
                    lbra      MainLoop
* ModeSwitch: mode 1/2 -> DragDispatch; modes $20..$26 (clefs) -> AddStaff on zone 6 (No more Staves! at 7) or ChangeClef; else PartIconZone
ModeSwitch          ldd       <UmeData_curcurse
                    cmpd      #$0001
                    lbeq      ToDragDispatch
                    ldd       <UmeData_curcurse
                    cmpd      #$0002
                    lbeq      ToDragDispatch
                    ldd       <UmeData_curcurse
                    cmpd      #$0020
                    lblt      PartIconZone
                    ldd       <UmeData_curcurse
                    cmpd      #$0026
                    lbgt      PartIconZone
                    ldd       <$12,s
                    cmpd      #$0006
                    lbne      ChangeClef
                    ldd       <UmeData_nstaves
                    cmpd      #$0007
                    blt       AddStaff
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgNoMoreStaves,pcr
                    pshs      x
                    jsr       [>UmeData_palert]
                    leas      4,s
                    lbra      MainLoop
* AddStaff: a clef mode on the margin (or a dropped clef): new staff at y-8, clef = mode-$20 in the staff table $0C19, then RedrawStavesMark
AddStaff            ldd       <UmeData_nstaves
                    addd      #$0001
                    std       <UmeData_nstaves
                    subd      #$0001
                    std       <$26,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      Mul16
                    ldx       #$0C19
                    leax      d,x
                    pshs      x
                    ldd       <$1C,s
                    addd      #$FFF8
                    std       [,s++]
                    ldd       <$26,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      Mul16
                    ldx       #$0C19
                    leax      d,x
                    leax      2,x
                    pshs      x
                    ldd       <UmeData_curcurse
                    addd      #$FFE0
                    std       [,s++]
* RedrawStavesMark: Shared tail of AddStaff and ChangeClef: DrawStaves(staff,staff), set the changed flag, StaffZoneDone
RedrawStavesMark    ldd       <$26,s
                    pshs      a,b
                    ldd       <$28,s
                    pshs      a,b
                    lbsr      DrawStaves
                    leas      4,s
                    ldd       #$0001
                    stb       <$2F,s
                    lbra      StaffZoneDone
* ChangeClef: Clef mode on a staff handle: staff.clef=mode-$20, TransposeForClef for every part on that staff, redraw
ChangeClef          ldd       <$12,s
                    cmpd      #$0001
                    lbne      d8@
                    ldd       <$26,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      Mul16
                    ldx       #$0C19
                    leax      d,x
                    ldd       2,x
                    std       <$20,s
                    ldd       <$26,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      Mul16
                    ldx       #$0C19
                    leax      d,x
                    leax      2,x
                    pshs      x
                    ldd       <UmeData_curcurse
                    addd      #$FFE0
                    std       <$24,s
                    std       [,s++]
                    ldd       #$0001
                    bra       c8@
* a8@: parts 1..count on the changed staff get TransposeForClef(part, old clef, new clef)
a8@                 ldd       <$24,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$0C5F
                    leax      d,x
                    ldd       ,x
                    cmpd      <$26,s
                    bne       b8@
                    ldd       <$22,s
                    pshs      a,b
                    ldd       <$22,s
                    pshs      a,b
                    ldd       <$28,s
                    pshs      a,b
                    lbsr      TransposeForClef
                    leas      6,s
b8@                 ldd       <$24,s
                    addd      #$0001
c8@                 std       <$24,s
                    ldd       <$24,s
                    cmpd      <UmeData_nparts
                    ble       a8@
                    lbra      RedrawStavesMark
d8@                 lbsr      ClearMsgLine
* StaffZoneDone: lbra ToMainLoop closing the clef/staff zone: RedrawStavesMark jumps in, ChangeClef's miss falls in
StaffZoneDone       lbra      ToMainLoop
* PartIconZone: zone 4 (else AddPart): <$10,s = part flags & 4, then PartModeSwitch on the mode
PartIconZone        ldd       <$12,s
                    cmpd      #$0004
                    lbne      AddPart
                    ldd       <$24,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$0C5F
                    leax      d,x
                    ldd       2,x
                    clra
                    andb      #$04
                    std       <$10,s
                    ldx       <UmeData_curcurse
                    lbra      PartModeSwitch
* ChangePartType: Modes $1C-$1F on a part icon: MakePartFlags, asks msgRemoveRests (ErasePartEvents rests) or AskRestoreRests, DrawParts(part,part)
ChangePartType      ldd       <$24,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$0C5F
                    leax      d,x
                    leax      2,x
                    pshs      x
                    ldd       <$28,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      Mul16
                    ldx       #$0C19
                    leax      d,x
                    ldd       ,x
                    pshs      a,b
                    ldd       <$1E,s
                    pshs      a,b
                    ldd       <UmeData_curcurse
                    pshs      a,b
                    ldd       <$26,s
                    pshs      a,b
                    lbsr      MakePartFlags
                    leas      8,s
                    std       <$10,s
                    std       [,s++]
                    ldd       14,s
                    clra
                    andb      #$04
                    std       14,s
                    ldd       <$10,s
                    bne       AskRestoreRests
                    ldd       14,s
                    beq       AskRestoreRests
                    leax      >msgRemoveRests,pcr
                    pshs      x
                    jsr       [>UmeData_pyesno]
                    leas      2,s
                    beq       AskRestoreRests
                    lbsr      BeginBusy
                    ldd       #$0001
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       <$28,s
                    pshs      a,b
                    ldd       <UmeData_nevents
                    addd      #$FFFF
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    lbsr      ErasePartEvents
                    leas      10,s
                    lbsr      EndBusy
* AskRestoreRests: 'Restore Rests to part?' -> RefillRests over the whole score plus [pfixup]
AskRestoreRests     ldd       <$10,s
                    beq       a9@
                    ldd       14,s
                    bne       a9@
                    leax      >msgRestoreRests,pcr
                    pshs      x
                    jsr       [>UmeData_pyesno]
                    leas      2,s
                    beq       a9@
                    lbsr      BeginBusy
                    ldd       <$24,s
                    pshs      a,b
                    ldd       <UmeData_nevents
                    addd      #$FFFF
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    lbsr      RefillRests
                    leas      6,s
                    clra
                    clrb
                    pshs      a,b
                    ldd       <$26,s
                    pshs      a,b
                    ldd       <UmeData_nevents
                    addd      #$FFFF
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    jsr       [>UmeData_pfixup]
                    leas      8,s
                    lbsr      EndBusy
a9@                 ldd       <$24,s
                    pshs      a,b
                    ldd       <$26,s
                    pshs      a,b
                    lbsr      DrawParts
                    leas      4,s
                    ldd       #$0001
                    bra       PartEditDone
* DoForgetPart: Mode 6 on a part icon: ForgetPart(part), result -> changed flag
DoForgetPart        ldd       <$24,s
                    pshs      a,b
                    lbsr      ForgetPart
                    leas      2,s
* PartEditDone: Shared tail of ChangePartType (bra, D=1) and DoForgetPart: stb B into the changed flag, then loop
PartEditDone        stb       <$2F,s
                    lbra      ToMainLoop
* PartRangeOps: modes $19/$17/$18 on a part: [pfixmarx] range select, then RefillRange (asks msgNoFlagsRefill first) or OctaveShift
PartRangeOps        leax      2,s
                    pshs      x
                    leax      6,s
                    pshs      x
                    leax      10,s
                    pshs      x
                    jsr       [>UmeData_pfixmarx]
                    leas      6,s
                    lbeq      ToMainLoop
                    ldd       <UmeData_curcurse
                    cmpd      #$0019
                    bne       OctaveShift
                    ldd       <$10,s
                    bne       a10@
                    ldd       #$0001
                    bra       b10@
a10@                clra
                    clrb
b10@                clra
                    andb      #$04
                    bne       RefillRange
                    leax      >msgNoFlagsRefill,pcr
                    pshs      x
                    jsr       [>UmeData_pyesno]
                    leas      2,s
                    lbeq      ReadyAndLoop
* RefillRange: BeginBusy, RefillRests(start,end,part), EndBusy
RefillRange         lbsr      BeginBusy
                    ldd       <$24,s
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    lbsr      RefillRests
                    leas      6,s
                    lbsr      EndBusy
                    lbra      ReadyAndLoop
* OctaveShift: [ptranprt](part, mode == $17 ? +7 : -7, start, end): shift the part's notes an octave
OctaveShift         lbsr      BeginBusy
                    ldd       4,s
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    ldd       <UmeData_curcurse
                    cmpd      #$0017
                    bne       a11@
                    ldd       #$0007
                    bra       b11@
a11@                ldd       #$FFF9
b11@                pshs      a,b
                    ldd       <$2A,s
                    pshs      a,b
                    jsr       [>UmeData_ptranprt]
                    leas      8,s
                    bra       ReadyAndLoop
* ClearRange: Modes $1A/$1B: range select then ErasePartEvents(start,end,part, all=(mode==$1B), restsOnly=flags&4)
ClearRange          leax      2,s
                    pshs      x
                    leax      6,s
                    pshs      x
                    leax      10,s
                    pshs      x
                    jsr       [>UmeData_pfixmarx]
                    leas      6,s
                    lbeq      ToMainLoop
                    lbsr      BeginBusy
                    ldd       <$10,s
                    pshs      a,b
                    ldd       <UmeData_curcurse
                    cmpd      #$001B
                    bne       a12@
                    ldd       #$0001
                    bra       b12@
a12@                clra
                    clrb
b12@                pshs      a,b
                    ldd       <$28,s
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    lbsr      ErasePartEvents
                    leas      10,s
* ReadyAndLoop: EndBusy then MainLoop
ReadyAndLoop        lbsr      EndBusy
                    lbra      ToMainLoop
* PartModeNoMatch: Default arm of the PartModeSwitch cmpx chain: ClearMsgLine then ToMainLoop
PartModeNoMatch     lbsr      ClearMsgLine
                    lbra      ToMainLoop
* PartModeSwitch: cmpx chain on the mode for a part-icon click: $1C-$1F type, 6 delete, $19/$17/$18 range ops, $1A/$1B clear
PartModeSwitch      cmpx      #$001C
                    lbeq      ChangePartType
                    cmpx      #$001D
                    lbeq      ChangePartType
                    cmpx      #$001E
                    lbeq      ChangePartType
                    cmpx      #$001F
                    lbeq      ChangePartType
                    cmpx      #$0006
                    lbeq      DoForgetPart
                    cmpx      #$0019
                    lbeq      PartRangeOps
                    cmpx      #$0017
                    lbeq      PartRangeOps
                    cmpx      #$0018
                    lbeq      PartRangeOps
                    cmpx      #$001A
                    lbeq      ClearRange
                    cmpx      #$001B
                    lbeq      ClearRange
                    bra       PartModeNoMatch
* AddPart: zone 5 with a type mode ($1C-$1F): part count < 16, new entry in $0C5F (staff, MakePartFlags), MidiPartOn[part] = 1, RefillRests over the whole score, DrawParts
AddPart             ldd       <$12,s
                    cmpd      #$0005
                    lbne      DeleteStaffCheck
                    ldd       <UmeData_curcurse
                    cmpd      #$001C
                    lblt      b13@
                    ldd       <UmeData_curcurse
                    cmpd      #$001F
                    lbgt      b13@
                    ldd       <UmeData_nparts
                    cmpd      #$0010
                    lbge      ZoneNoActionExit
                    ldd       <UmeData_nparts
                    addd      #$0001
                    std       <UmeData_nparts
                    std       <$24,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$0C5F
                    leax      d,x
                    ldd       <$26,s
                    std       ,x
                    ldd       <$24,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$0C5F
                    leax      d,x
                    leax      2,x
                    pshs      x
                    ldd       12,s
                    pshs      a,b
                    ldd       <$1E,s
                    pshs      a,b
                    ldd       <UmeData_curcurse
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    lbsr      MakePartFlags
                    leas      8,s
                    std       <$10,s
                    std       [,s++]
                    ldd       <$24,s
                    ldx       #MidiPartOn
                    leax      d,x
                    ldd       #$0001
                    stb       ,x
* A clone part (flags bit 2) gets no rests; the new icon is drawn right away.
                    lbsr      BeginBusy
                    ldd       14,s
                    clra
                    andb      #$04
                    bne       ap13@               a clone: no refill
                    ldd       <$24,s
                    pshs      a,b
                    ldd       <UmeData_nevents
                    addd      #$FFFF
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    lbsr      RefillRests
                    leas      6,s
ap13@               ldd       <$24,s
                    pshs      a,b
                    ldd       <$26,s
                    pshs      a,b
                    lbsr      DrawParts
                    leas      4,s
                    lbsr      EndBusy
a13@                ldd       #$0001
                    stb       <$2F,s
                    lbra      ToMainLoop
b13@                lbsr      ClearMsgLine
                    lbra      ToMainLoop
* DeleteStaffCheck: Mode 6 on a staff handle: scans parts for one still on the staff -> msgStaffHasParts, else DeleteStaff
DeleteStaffCheck    ldd       <UmeData_curcurse
                    cmpd      #$0006
                    lbne      ZoneNoActionExit
                    ldd       <$12,s
                    cmpd      #$0001
                    lbne      ToMainLoop
                    ldd       <UmeData_nparts
                    bra       b14@
* a14@: from the last part down, look for a part on the staff
a14@                ldd       <$24,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$0C5F
                    leax      d,x
                    ldd       ,x
                    cmpd      <$26,s
                    beq       c14@
                    ldd       <$24,s
                    addd      #$FFFF
b14@                std       <$24,s
                    ldd       <$24,s
                    bne       a14@
c14@                ldd       <$24,s
                    beq       DeleteStaff
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgStaffHasParts,pcr
                    pshs      x
                    jsr       [>UmeData_palert]
                    leas      4,s
                    lbra      MainLoop
* DeleteStaff: EraseStaff($89), staff count--, decrement staff refs of parts above, MemCopy the staff table down, redraw parts and staves
DeleteStaff         ldd       <$26,s
                    pshs      a,b
                    lbsr      EraseStaff
                    leas      2,s
                    ldd       <UmeData_nstaves
                    addd      #$FFFF
                    std       <UmeData_nstaves
                    ldd       <UmeData_nparts
                    bra       c15@
* a15@: parts on a higher staff move down one staff
a15@                ldd       <$24,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$0C5F
                    leax      d,x
                    ldd       ,x
                    cmpd      <$26,s
                    blt       b15@
                    ldd       <$24,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$0C5F
                    leax      d,x
                    ldd       ,x
                    addd      #$FFFF
                    std       ,x
b15@                ldd       <$24,s
                    addd      #$FFFF
c15@                std       <$24,s
                    ldd       <$24,s
                    bne       a15@
                    ldd       <UmeData_nparts
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    lbsr      DrawParts
                    leas      4,s
                    ldd       <UmeData_nstaves
                    subd      <$26,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      Mul16
                    pshs      a,b
                    ldd       <$28,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      Mul16
                    ldx       #$0C19
                    leax      d,x
                    tfr       x,d
                    addd      #$000A
                    pshs      a,b
                    ldd       <$2A,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      Mul16
                    ldx       #$0C19
                    leax      d,x
                    pshs      x
                    lbsr      MemCopy
                    leas      6,s
                    ldd       <UmeData_nstaves
                    addd      #$FFFF
                    pshs      a,b
                    ldd       <$28,s
                    pshs      a,b
                    lbsr      DrawStaves
                    leas      4,s
                    ldd       #$0001
                    stb       <$2F,s
                    lbra      ToMainLoop
* ZoneNoActionExit: ClearMsgLine + MainLoop when AddPart hits the 16-part limit or DeleteStaffCheck sees a mode != 6
ZoneNoActionExit    lbsr      ClearMsgLine
                    lbra      MainLoop
* ToDragDispatch: Modes 1 and 2 in ModeSwitch: loads the zone <$12,s into X and lbra's to DragDispatch
ToDragDispatch      ldx       <$12,s
                    lbra      DragDispatch
* DragStaff: Mode 1 on a staff handle: HiliteStaff, remember the y offset, track the mouse moving the staff (y clamped 8..167)
DragStaff           clra
                    clrb
                    pshs      a,b
                    ldd       <$28,s
                    pshs      a,b
                    lbsr      HiliteStaff
                    leas      4,s
                    ldd       <$26,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      Mul16
                    ldx       #$0C19
                    leax      d,x
                    ldd       2,x
                    std       <$22,s
                    ldd       <$1A,s
                    subd      12,s
                    std       8,s
                    lbra      d16@
* a16@: per poll: unhighlight, staff y = mouse y - offset clamped, DrawStaff, HiliteStaff, flush
a16@                ldd       12,s
                    addd      8,s
                    cmpd      <$1A,s
                    lbeq      d16@
                    clra
                    clrb
                    pshs      a,b
                    ldd       <$28,s
                    pshs      a,b
                    lbsr      HiliteStaff
                    leas      4,s
                    ldd       <$1A,s
                    subd      8,s
                    std       12,s
                    cmpd      #$0008
                    bge       b16@
                    ldd       #$0008
                    std       12,s
b16@                ldd       12,s
                    cmpd      #$00A7
                    ble       c16@
                    ldd       #$00A7
                    std       12,s
c16@                ldd       <$26,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      Mul16
                    ldx       #$0C19
                    leax      d,x
                    ldd       12,s
                    std       ,x
                    ldd       12,s
                    pshs      a,b
                    ldd       <$24,s
                    pshs      a,b
                    ldd       <$2A,s
                    pshs      a,b
                    lbsr      DrawStaff
                    leas      6,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       <$28,s
                    pshs      a,b
                    lbsr      HiliteStaff
                    leas      4,s
                    jsr       [>UmeData_pflush]
* d16@: [pmouce](&x, &y) poll; loops while the button is held, then the changed flag and mode 1
d16@                leax      <$1A,s
                    pshs      x
                    leax      2,s
                    pshs      x
                    jsr       [>UmeData_pmouce]
                    leas      4,s
                    std       -2,s
                    lbne      a16@
                    ldd       #$0001
                    stb       <$2F,s
                    lbra      ResetModeLoop
* DragPart: Mode 1 on a part icon: mode = FlagsToMode(flags), DragIconAt follows the mouse (y clamped 8..183)
DragPart            ldd       #$0001
                    stb       <$2F,s
                    ldd       <$1E,s
                    pshs      a,b
                    lbsr      FlagsToMode
                    leas      2,s
                    std       <UmeData_curcurse
                    ldd       <UmeData_curcurse
                    pshs      a,b
                    lbsr      SetMode
                    leas      2,s
                    ldd       <$1A,s
                    subd      12,s
                    std       8,s
                    ldd       <$24,s
                    pshs      a,b
                    ldd       #$0003
                    lbsr      Mul16
                    addd      #$0009
                    std       <$1C,s
                    lbra      DropPart
* DragPartLoop: per poll: the icon at the old spot goes, y is recomputed (clamped), the icon drawn at (col*8, y), flush; DropPart's [pmouce] poll lbne's back here while the button is held
DragPartLoop        ldd       12,s
                    addd      8,s
                    cmpd      <$1A,s
                    lbeq      DropPart
                    ldd       12,s
                    pshs      a,b
                    ldd       <$1E,s
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    pshs      a,b
                    lbsr      DragIconAt
                    leas      4,s
                    ldd       <$1A,s
                    subd      8,s
                    std       12,s
                    cmpd      #$0008
                    bge       a17@
                    ldd       #$0008
                    std       12,s
a17@                ldd       12,s
                    cmpd      #$00B7
                    ble       b17@
                    ldd       #$00B7
                    std       12,s
b17@                ldd       12,s
                    pshs      a,b
                    ldd       <$1E,s
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    pshs      a,b
                    lbsr      DragIconAt
                    leas      4,s
                    jsr       [>UmeData_pflush]
* DropPart: poll until release, then [pfindstaff](y) target staff, MakePartFlags, update part staff/flags, TransposeForClef(old, new clef), DrawParts(part, part)
DropPart            leax      <$1A,s
                    pshs      x
                    leax      2,s
                    pshs      x
                    jsr       [>UmeData_pmouce]
                    leas      4,s
                    std       -2,s
                    lbne      DragPartLoop
                    ldd       12,s
                    pshs      a,b
                    ldd       <$1E,s
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    pshs      a,b
                    lbsr      DragIconAt
                    leas      4,s
                    ldd       12,s
                    pshs      a,b
                    jsr       [>UmeData_pfindstaff]
                    leas      2,s
                    std       <$26,s
                    cmpd      <UmeData_nstaves
                    lbge      ResetModeLoop
                    ldd       <$26,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      Mul16
                    ldx       #$0C19
                    leax      d,x
                    ldd       ,x
                    std       10,s
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    ldd       <UmeData_curcurse
                    pshs      a,b
                    ldd       <$24,s
                    pshs      a,b
                    lbsr      MakePartFlags
                    leas      8,s
                    std       <$1E,s
                    ldd       <$24,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$0C5F
                    leax      d,x
                    ldd       <$1E,s
                    std       2,x
                    ldd       <$24,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$0C5F
                    leax      d,x
                    ldd       ,x
                    pshs      a,b
                    ldd       #$000A
                    lbsr      Mul16
                    ldx       #$0C19
                    leax      d,x
                    ldd       2,x
                    std       <$20,s
                    ldd       <$24,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$0C5F
                    leax      d,x
                    ldd       <$26,s
                    std       ,x
                    ldd       <$26,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      Mul16
                    ldx       #$0C19
                    leax      d,x
                    ldd       2,x
                    std       <$22,s
                    pshs      a,b
                    ldd       <$22,s
                    pshs      a,b
                    ldd       <$28,s
                    pshs      a,b
                    lbsr      TransposeForClef
                    leas      6,s
                    ldd       <$24,s
                    pshs      a,b
                    ldd       <$26,s
                    pshs      a,b
                    lbsr      DrawParts
                    leas      4,s
                    bra       ResetModeLoop
* DragZoneNoMatch: Default arm of DragDispatch (zone not 1 or 4): ClearMsgLine then ResetModeLoop
DragZoneNoMatch     lbsr      ClearMsgLine
                    bra       ResetModeLoop
* DragDispatch: modes 1/2: zone 1 -> DragStaff, zone 4 -> DragPart, else DragZoneNoMatch
DragDispatch        cmpx      #$0001
                    lbeq      DragStaff
                    cmpx      #$0004
                    lbeq      DragPart
                    bra       DragZoneNoMatch
* ResetModeLoop: SetMode(1) then MainLoop
ResetModeLoop       ldd       #$0001
                    pshs      a,b
                    lbsr      SetMode
                    leas      2,s
* ToMainLoop: lbra MainLoop hub
ToMainLoop          lbra      MainLoop
                    fcb       $32,$E9,$00,$82,$35,$C0
* strMenuKeys: the command letter of each row of the score editor's menu, in the order of the rows in
* tblPanelText (column MenuRowCol, MenuRowPitch dots apart from MenuRowY0 down); s9's LayHover inverts the
* row under the pointer. A row that says 'then click a part' sets a mode and waits for the click in the part
* column (the staff strip at the left); space (mode 1) cancels it.
*   0 s  Renumber staves   asks 'Re-Number all Staves?' (s9e 'n' renumbers 1..n top to bottom), then
*                          'Space Staves equally?' (SpaceStaves), then redraws every staff.
*   1 T  Time signature    the time-signature dialog ([pgtsig]); the new meter is used by the refill.
*   2 k  Key signature     the key-signature dialog ([pgksig]); sent to s9gui as $8C key.
*   3 o  Reorder parts     asks 'Re-order Parts on All Staves?' (else 'Which Staff?'), then 'Segregate
*                          Clones to the rear?'; s9e 'o' sorts the parts of each staff by pitch.
*   4 r  Part ranges       scans every part's highest and lowest note and shows the two rows of pitches
*                          (ShowPartRanges), then waits for ENTER or a click. Shows only, changes nothing.
*   5 +  Octave up         then click a part: every note of that part moves 7 staff steps up ([ptranprt]).
*   6 -  Octave down       then click a part: 7 staff steps down.
*   7 f  Fill rests        then click a part: rests are inserted where its bars come up short of the
*                          meter (RefillRests); notes are not touched. Asks 'Refill anyway?' first.
*   8 t  Remove rests      then click a part: its rests and rest-only bars are erased (ErasePartEvents
*                          without the all flag); notes stay.
*   9 c  Erase part        then click a part: every event of that part goes (ErasePartEvents, all flag);
*                          the part itself stays on its staff.
*  10 w  Score wizard      leaves with WizForce 3: s9 runs newscore with the layout questions.
*  11 n  New score         leaves with the staves and parts as laid out here: a 4/4 meter still at its
*                          default is shown as common time, and every part is filled with rests over
*                          the whole score (KeyExit). With music on the sheet s9 asks before clearing.
*  12 q  Apply changes     (CR too) leaves after filling every non-clone part's rests (the refill, the
*                          long edit); WizForce 2 tells s9 to keep the score.
*  13 e  Exit, no change   leaves at once: no refill, nothing touched.
* Off the menu: x (Delete part/staff, then click one), space (plain select mode), a drag of a clef or a
* part-type icon from the panel onto a staff (AddPart / a clef change).
strMenuKeys         fcc       /sTkor+-ftcwnqe/    one letter per row, in the order above
* tblPanelText: every string the SCORE EDITOR panel shows, sent by SendPanelText as s9gui $C0 text commands
* (code, column, y, flag, text, CR) right after SelectMenu asked for the panel; s9gui draws only the frame,
* the field and the icons. Placed entries: fcb column, y, flag, then the text and a NUL; a zero column ends
* them. The MenuRows menu rows follow as bare strings in strMenuKeys' order (MenuRowCol, MenuRowY0 and
* MenuRowPitch in equates.asm, shared with the hit test and s9's LayHover), 15 characters at most.
tblPanelText        fcb       63+LayDX,182+LayDY,1      the title, centered on the field
*                                                   (flag 1: the sixth glyph row is not drawn)
                    fcc       /SCORE EDITOR/
                    fcb       0
                    fcb       0                   the placed items end; the fourteen rows follow, text only
                    fcc       /Renumber staves/
                    fcb       0
                    fcc       /Time signature/
                    fcb       0
                    fcc       /Key signature/
                    fcb       0
                    fcc       /Reorder parts/
                    fcb       0
                    fcc       /Part ranges/
                    fcb       0
                    fcc       /Octave up/
                    fcb       0
                    fcc       /Octave down/
                    fcb       0
                    fcc       /Fill rests/
                    fcb       0
                    fcc       /Remove rests/
                    fcb       0
                    fcc       /Erase part/
                    fcb       0
                    fcc       /Score wizard/
                    fcb       0
                    fcc       /New score/
                    fcb       0
                    fcc       /Apply changes/
                    fcb       0
                    fcc       /Exit, no change/
                    fcb       0
* SendPanelText: the placed items (column, y, flag, text), then the MenuRows rows (column MenuRowCol,
* y MenuRowY0 - MenuRowPitch * row, flag 0), each as printf(fmtPanelText, $C0, column, y, flag, text).
* Keeps every register.
SendPanelText       pshs      d,x,y,u
                    leax      >tblPanelText,pcr
spt1@               ldb       ,x                  the column; zero ends the placed items
                    beq       spt3@
                    leax      3,x
                    pshs      x                   the text (the %s: deepest)
                    ldb       -1,x
                    clra
                    pshs      d                   the flag
                    ldb       -2,x
                    pshs      d                   y
                    ldb       -3,x                the column
                    bsr       spt5@               sent; X = past the text's NUL
                    bra       spt1@
spt3@               leax      1,x                 the rows
                    ldd       #MenuRowY0
                    pshs      d                   ,s y
                    ldb       #MenuRows
                    pshs      b                   ,s the count  1,s y
spt4@               pshs      x                   the text
                    clra
                    clrb
                    pshs      d                   the flag 0
                    ldd       5,s                 y (under the text and the flag)
                    pshs      d
                    ldb       #MenuRowCol
                    bsr       spt5@
                    ldd       1,s
                    subd      #MenuRowPitch
                    std       1,s
                    dec       ,s
                    bne       spt4@
                    leas      3,s
                    puls      d,x,y,u,pc
* spt5@: text, flag and y are on the stack under the return; B = the column. The return goes to U (Y is
* the static base printf addresses stdout through; X walks the text), then the column, the code and the
* format are pushed and printf(fmt, $C0, column, y, flag, text) sends the line. The six argument bytes are
* dropped, X is left past the text's NUL, and the return is taken through U.
spt5@               puls      u                   the return address
                    clra
                    pshs      d                   the column
                    ldd       #$00C0
                    pshs      d                   the code
                    leax      >fmtPanelText,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      10,s                the format, the code, the column, y, the flag
                    puls      x                   the text
spt6@               lda       ,x+
                    bne       spt6@               past its NUL
                    jmp       ,u
* fmtPanelText: s9gui's $C0 text command - code, column, y, flag, the text, CR
fmtPanelText        fcc       /%c%c%c%c%s/
                    fcb       $0D,0
                    fcb       $00
* msgRenumberStaves: 'Re-Number all Staves?' yes/no prompt of KeyStaves
msgRenumberStaves   fcc       /Re-Number all Staves?/
                    fcb       $00
* msgSpaceStaves: 'Space Staves equally?' prompt -> SpaceStaves
msgSpaceStaves      fcc       /Space Staves equally?/
                    fcb       $00
* msgReorderParts: 'Re-order Parts on All Staves?' prompt of KeyOrderParts
msgReorderParts     fcc       /Re-order Parts on All Staves?/
                    fcb       $00
* msgSegregateClones: 'Segregate Clones to the rear?' prompt, flag passed to s9e
msgSegregateClones  fcc       /Segregate Clones to the rear?/
                    fcb       $00
* msgWhichStaff: 'Which Staff (Number)? ' line-input prompt
msgWhichStaff       fcc       /Which Staff (Number)? /
                    fcb       $00
* msgNoMoreStaves: 'No more Staves!' + CR shown via [palert] when 7 staves exist
msgNoMoreStaves     fcc       /No more Staves!/
                    fcb       $0D,$00
* msgRemoveRests: 'Remove Rests from part?' prompt in ChangePartType
msgRemoveRests      fcc       /Remove Rests from part?/
                    fcb       $00
* msgRestoreRests: 'Restore Rests to part?' prompt in ChangePartType
msgRestoreRests     fcc       /Restore Rests to part?/
                    fcb       $00
* msgNoFlagsRefill: 'No-Flags Clone-Part; Refill anyway?' prompt before RefillRange
msgNoFlagsRefill    fcc       /No-Flags Clone-Part; Refill anyway?/
                    fcb       $00
* msgStaffHasParts: 'Can't delete Staff until all its Parts / are Moved Off or Deleted.' message of DeleteStaffCheck
msgStaffHasParts    fcc       /Can't delete Staff until all its Parts/
                    fcb       $0D
                    fcc       /  are Moved Off or Deleted./
                    fcb       $00,$34,$40,$CE,$01,$A6,$35,$C0
* IsPartRefType: (type) -> 1 for event types $16,$17,$18,$1E,$20 whose byte 6 holds a part number (used by ErasePartEvents and RenumberParts on part-0 events)
IsPartRefType       pshs      u
                    ldd       4,s
                    cmpd      #$0017
                    beq       a18@
                    ldd       4,s
                    cmpd      #$0018
                    beq       a18@
                    ldd       4,s
                    cmpd      #$0016
                    beq       a18@
                    ldd       4,s
                    cmpd      #$001E
                    beq       a18@
                    ldd       4,s
                    cmpd      #$0020
                    bne       b18@
a18@                ldd       #$0001
                    bra       c18@
                    fcb       $34,$40,$E6,$65,$1D,$83,$00,$30
                    fcb       $E7,$65,$2D,$0B,$E6,$65,$C1,$09
                    fcb       $2E,$05,$E6,$65,$1D,$35,$C0,$E6
                    fcb       $65,$1D,$83,$00,$31,$E7,$65,$2D
                    fcb       $0E,$E6,$65,$C1,$06,$2E,$08,$E6
                    fcb       $65,$1D,$C3,$00,$0A,$35,$C0
b18@                clra
                    clrb
c18@                puls      u,pc
* PartToChar: (part) -> '0'+part for <=9, '7'+part ('A'..) above; patches the X of msgForgetPart
PartToChar          pshs      u
                    ldd       4,s
                    cmpd      #$0009
                    bgt       a19@
                    ldd       #$0030
                    bra       b19@
a19@                ldd       #$0037
b19@                addd      4,s
                    puls      u,pc
* ForgetPart(part): asks msgForgetPart, ErasePartEvents(all), ErasePart($8B), MemCopy the $0C5F, MidiPartOn and MidiChanTbl tables down, count--, DrawParts, RenumberParts, EndBusy; returns 1 if done
ForgetPart          pshs      u
                    leas      <-$29,s
                    leax      >msgForgetPart,pcr
                    pshs      x
                    leax      2,s
                    pshs      x
                    lbsr      StrCopy
                    leas      4,s
                    ldd       <$2D,s
                    pshs      a,b
                    bsr       PartToChar
                    leas      2,s
                    stb       <$10,s
                    leax      ,s
                    pshs      x
                    jsr       [>UmeData_pyesno]
                    std       ,s++
                    lbeq      a20@
                    lbsr      BeginBusy
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       <$31,s
                    pshs      a,b
                    ldd       <UmeData_nevents
                    addd      #$FFFF
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    lbsr      ErasePartEvents
                    leas      10,s
                    ldd       <$2D,s
                    pshs      a,b
                    lbsr      ErasePart
                    leas      2,s
                    ldd       <UmeData_nparts
                    subd      <$2D,s
                    aslb
                    rola
                    aslb
                    rola
                    pshs      a,b
                    ldd       <$2F,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$0C5F
                    leax      d,x
                    tfr       x,d
                    addd      #$0004
                    pshs      a,b
                    ldd       <$31,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$0C5F
                    leax      d,x
                    pshs      x
                    lbsr      MemCopy
                    leas      6,s
                    ldd       <UmeData_nparts
                    subd      <$2D,s
                    pshs      a,b
                    ldd       <$2F,s
                    ldx       #MidiPartOn
                    leax      d,x
                    tfr       x,d
                    addd      #$0001
                    pshs      a,b
                    ldd       <$31,s
                    ldx       #MidiPartOn
                    leax      d,x
                    pshs      x
                    lbsr      MemCopy
                    leas      6,s
                    ldd       <UmeData_nparts
                    subd      <$2D,s
                    pshs      a,b
                    ldd       <$2F,s
                    ldx       #MidiChanTbl
                    leax      d,x
                    tfr       x,d
                    addd      #$0001
                    pshs      a,b
                    ldd       <$31,s
                    ldx       #MidiChanTbl
                    leax      d,x
                    pshs      x
                    lbsr      MemCopy
                    leas      6,s
                    ldd       <UmeData_nparts
                    addd      #$FFFF
                    std       <UmeData_nparts
                    ldd       <UmeData_nparts
                    pshs      a,b
                    ldd       <$2F,s
                    pshs      a,b
                    lbsr      DrawParts
                    leas      4,s
                    ldd       <$2D,s
                    pshs      a,b
                    lbsr      RenumberParts
                    leas      2,s
                    lbsr      EndBusy
                    ldd       #$0001
                    bra       b20@
a20@                clra
                    clrb
b20@                leas      <$29,s
                    puls      u,pc
* MakePartFlags: (flags, mode, y, staffY) -> flags&$E8 | 1 if y-staffY-8>3 | 2 if <-3 | 4 for modes $1D/$1F | $10 for $1E/$1F
MakePartFlags       pshs      a,b,x,u
                    ldd       8,s
                    andb      #$E8
                    std       2,s
                    ldd       12,s
                    subd      14,s
                    addd      #$FFF8
                    std       ,s
                    ldd       2,s
                    pshs      a,b
                    ldd       2,s
                    cmpd      #$0003
                    ble       a21@
                    ldd       #$0001
                    bra       c21@
a21@                ldd       2,s
                    cmpd      #$FFFD
                    bge       b21@
                    ldd       #$0002
                    bra       c21@
b21@                clra
                    clrb
c21@                ora       ,s+
                    orb       ,s+
                    std       2,s
                    ldd       10,s
                    cmpd      #$001D
                    beq       d21@
                    ldd       10,s
                    cmpd      #$001F
                    bne       e21@
d21@                ldd       2,s
                    orb       #$04
                    std       2,s
e21@                ldd       10,s
                    cmpd      #$001E
                    beq       f21@
                    ldd       10,s
                    cmpd      #$001F
                    bne       g21@
f21@                ldd       2,s
                    orb       #$10
                    std       2,s
g21@                ldd       2,s
                    lbra      PopFrame4Ret
* FlagsToMode: (flags) -> $1C + (bit2?1:0) + (bit4?2:0): inverse of MakePartFlags, used when dragging a part
FlagsToMode         pshs      u
                    ldd       4,s
                    clra
                    andb      #$10
                    beq       c22@
                    ldd       4,s
                    clra
                    andb      #$04
                    beq       a22@
                    ldd       #$001F
                    bra       b22@
a22@                ldd       #$001E
b22@                puls      u,pc
c22@                ldd       4,s
                    clra
                    andb      #$04
                    beq       d22@
                    ldd       #$001D
                    bra       e22@
d22@                ldd       #$001C
e22@                puls      u,pc
                    fcb       $35,$C0
* ShowPartRanges(start, end): scans events for the highest/lowest pitch (byte 5, $20 = rest skipped) per part 1..16, RangeDisplay(1,1), writes the two rows via [powrite]
ShowPartRanges      pshs      u
                    leas      <-$2B,s
                    ldd       #$0011
                    std       6,s
                    bra       b23@
* a23@: init: min[] = $7F, max[] = -127 for parts 16..1
a23@                ldd       6,s
                    leax      <$19,s
                    leax      d,x
                    ldd       #$007F
                    stb       ,x
                    ldd       6,s
                    leax      8,s
                    leax      d,x
                    ldd       #$FF81
                    stb       ,x
b23@                ldd       6,s
                    addd      #$FFFF
                    std       6,s
                    bne       a23@
                    ldd       <$2F,s
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    lbra      f23@
* c23@: event scan updating min/max per part
c23@                ldb       ,u
                    sex
                    std       6,s
                    beq       e23@
                    ldd       6,s
                    cmpd      <UmeData_nparts
                    bgt       e23@
                    ldb       5,u
                    sex
                    std       4,s
                    cmpd      #$0020
                    beq       e23@
                    ldd       6,s
                    leax      8,s
                    leax      d,x
                    ldb       ,x
                    sex
                    cmpd      4,s
                    bge       d23@
                    ldd       6,s
                    leax      8,s
                    leax      d,x
                    ldd       4,s
                    stb       ,x
d23@                ldd       6,s
                    leax      <$19,s
                    leax      d,x
                    ldb       ,x
                    sex
                    cmpd      4,s
                    ble       e23@
                    ldd       6,s
                    leax      <$19,s
                    leax      d,x
                    ldd       4,s
                    stb       ,x
e23@                lbsr      NextEvent
f23@                tfr       d,u
                    ldd       <UmeData_curind
                    cmpd      <$31,s
                    lblt      c23@
                    ldd       #$0011
                    std       6,s
                    bra       h23@
* g23@: an untouched max (-127) becomes $20 (rest) so a silent part prints a rest
g23@                ldd       6,s
                    leax      8,s
                    leax      d,x
                    ldb       ,x
                    sex
                    cmpd      #$FF81
                    bne       h23@
                    ldd       6,s
                    leax      8,s
                    leax      d,x
                    ldd       #$0020
                    stb       ,x
* h23@: loop bottom, then RangeDisplay(1,1), the max row (nparts bytes) and the CR-terminated min row
h23@                ldd       6,s
                    addd      #$FFFF
                    std       6,s
                    bne       g23@
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    lbsr      RangeDisplay
                    leas      4,s
                    ldd       <UmeData_nparts
                    pshs      a,b
                    leax      11,s
                    pshs      x
                    jsr       [>UmeData_powrite]
                    leas      4,s
                    ldd       <UmeData_nparts
                    addd      #$0001
                    leax      <$19,s
                    leax      d,x
                    ldd       #$000D
                    stb       ,x
                    ldd       <UmeData_nparts
                    addd      #$0001
                    pshs      a,b
                    leax      <$1C,s
                    pshs      x
                    jsr       [>UmeData_powrite]
                    leas      4,s
                    leas      <$2B,s
                    puls      u,pc
                    fcc       /4V /
                    fcb       $0A,$CC,$00,$04,$34,$06,$17,$09
                    fcb       $14
                    fcs       /2b0d/
                    fcb       $34,$10
                    fcc       /0d4/
                    fcb       $10,$AD,$9F,$03,$9F,$32,$64,$ED
                    fcb       $7E,$26,$E4,$16,$01,$4F
* SpaceStaves: Spaces the staves evenly: y[i] = $B0 - (i+1)*(($B0-(count<4?20:0))/(count+1)) written into table $0C19
SpaceStaves         pshs      a,b,x,u
                    ldd       <UmeData_nstaves
                    cmpd      #$0004
                    bge       a24@
                    ldd       #$0014
                    bra       b24@
a24@                clra
                    clrb
b24@                pshs      a,b
                    ldd       #$00B0
                    subd      ,s++
                    pshs      a,b
                    ldd       <UmeData_nstaves
                    addd      #$0001
                    lbsr      DivMod16
                    std       ,s
                    clra
                    clrb
                    std       2,s
                    ldu       #$0C19
                    bra       d24@
* c24@: loop over staves computing the evenly spaced y
c24@                ldd       2,s
                    addd      #$0001
                    pshs      a,b
                    ldd       2,s
                    lbsr      Mul16
                    pshs      a,b
                    ldd       #$00B0
                    subd      ,s++
                    leau      10,u
                    std       -10,u
                    ldd       2,s
                    addd      #$0001
                    std       2,s
d24@                ldd       2,s
                    cmpd      <UmeData_nstaves
                    blt       c24@
                    lbra      PopFrame4Ret
* GetPartStaff(part, &staffY, &flags): an out-of-range part becomes nparts; returns partTbl[part].staff, stores the staff's y from $0C19 and the part flags
GetPartStaff        pshs      a,b,u
                    ldd       6,s
                    cmpd      #$0001
                    blt       a25@
                    ldd       6,s
                    cmpd      <UmeData_nparts
                    ble       b25@
a25@                ldd       <UmeData_nparts
                    std       6,s
b25@                ldd       6,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$0C5F
                    leax      d,x
                    leau      ,x
                    ldd       2,u
                    std       [<$0A,s]
                    ldd       ,u
                    std       ,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      Mul16
                    ldx       #$0C19
                    leax      d,x
                    ldd       ,x
                    std       [<$08,s]
                    ldd       ,s
                    lbra      PopFrame2Ret
* InRect: (a, b, aMin, bMin, aMax, bMax) -> 1 when aMin<=a<=aMax and bMin<=b<=bMax; the hot-region test
InRect              pshs      u
                    ldd       4,s
                    cmpd      8,s
                    blt       a26@
                    ldd       4,s
                    cmpd      12,s
                    bgt       a26@
                    ldd       6,s
                    cmpd      10,s
                    blt       a26@
                    ldd       6,s
                    cmpd      14,s
                    bgt       a26@
                    ldd       #$0001
                    lbra      PopUAndRet
a26@                clra
                    lbra      RetZeroPopU
* FranCmdC6(a1..a6): printf('%c'x7, $C6, a1..a6) then [pflush]: the window-create command; opens the prompt box
FranCmdC6           pshs      u
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
                    bra       FlushAndRet
* StaffPromptBox(flag): FranCmdC6(14, $6E, $32, flag?5:2, 1, WinStylePaper3D) opens the box for msgWhichStaff
StaffPromptBox      pshs      u
                    ldd       #WinStylePaper3D    paper 3D box
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldb       9,s
                    beq       a27@
                    ldd       #$0005
                    bra       b27@
a27@                ldd       #$0002
b27@                pshs      a,b
                    ldd       #$0032
                    pshs      a,b
                    ldd       #$006E
                    pshs      a,b
                    ldd       #$000E
                    pshs      a,b
                    lbsr      FranCmdC6
                    leas      12,s
                    puls      u,pc
* ClearMsgLine: the C bell(): [pbeep] when the sound flag ($03C3) is set (the name is an early misreading)
ClearMsgLine        pshs      u
                    ldb       >UmeData_reserved_03C3
                    beq       a28@
                    jsr       [>UmeData_pbeep]
a28@                puls      u,pc
* BeginBusy: printf('%c\r', $C3) + flush: sent before every long operation (erase, refill, forget, reorder); paired with EndBusy
BeginBusy           pshs      u
                    ldd       #$00C3
                    pshs      a,b
                    ldd       <UmeData_reserved_0016
                    pshs      a,b
                    jsr       [>UmeData_pprintf]
                    leas      4,s
* FlushAndRet: tail of BeginBusy: [pflush] then puls u,pc; FranCmdC6 branches here after its printf
FlushAndRet         jsr       [>UmeData_pflush]
                    puls      u,pc
* EndBusy: printf('%c\r', $C7) (the window-kill command, s9k's wkill): sent after long operations, after line input and at exit
EndBusy             pshs      u
                    ldd       #$00C7
                    pshs      a,b
                    ldd       <UmeData_reserved_0016
                    pshs      a,b
                    jsr       [>UmeData_pprintf]
* PopFrame4Ret: leas 4,s / puls u,pc epilogue: EndBusy falls in, MakePartFlags and SpaceStaves lbra here
PopFrame4Ret        leas      4,s
                    puls      u,pc
* SetMode(mode): stores curcurse and printf('%c%c\r', $9A, mode) so s9gui shows the mode
SetMode             pshs      u
                    ldd       4,s
                    std       <UmeData_curcurse
                    ldd       4,s
                    pshs      a,b
                    ldd       #$009A
                    bra       ModePrintfTail
* DragIconAt: (x, y): y clamped >=0, printf('%c%c%c%c\r', $9B, x>>8, x, y): the part icon following the mouse
DragIconAt          pshs      u
                    ldd       6,s
                    bge       a29@
                    clra
                    clrb
                    std       6,s
a29@                ldd       6,s
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    ldb       8,s
                    sex
                    pshs      a,b
                    ldd       #$009B
                    pshs      a,b
                    ldd       <UmeData_reserved_001C
                    bra       PrintfTail10
* SelectMenu(n): printf(pctn2, $C4, n); LayoutMain asks for menu 12, the score editor panel
SelectMenu          pshs      u
                    ldd       4,s
                    pshs      a,b
                    ldd       #$00C4
* ModePrintfTail: pushes the command and the format pctn2; SetMode branches in, SelectMenu falls in, joins PrintfTail6
ModePrintfTail      pshs      a,b
                    ldd       <pctn2
                    lbra      PrintfTail6
* RangeDisplay: (a, b): printf('%c%c%c\r', $B1, a, b); (1,1) precedes the two pitch rows of ShowPartRanges, (arg3,0) on every changed pass
RangeDisplay        pshs      u
                    ldb       7,s
                    sex
                    pshs      a,b
                    ldb       7,s
                    sex
                    pshs      a,b
                    ldd       #$00B1
                    bra       HilitePrintfTail
* HiliteStaff: (staff, on): printf('%c%c%c\r', $9F, staff, on) brackets DragStaff
HiliteStaff         pshs      u
                    ldd       6,s
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    ldd       #$009F
* HilitePrintfTail: Pushes the command and format <$1A; HiliteStaff falls in, RangeDisplay branches in -> PrintfTail8
HilitePrintfTail    pshs      a,b
                    ldd       <UmeData_reserved_001A
                    lbra      PrintfTail8
* DrawStaff(n, clef, y): printf('%c%c%c%c\r', $88, n, clef, y); bit 7 of n carries <halfstaf (the gray staff
* lines option) for s9gui's defsa / storf.
DrawStaff           pshs      u
                    ldd       8,s
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    ldd       8,s
                    tst       <UmeData_halfstaf                gray staff lines on?
                    beq       ds1@
                    orb       #$80
ds1@                pshs      a,b
                    ldd       #$0088
                    pshs      a,b
                    ldd       <UmeData_reserved_000E
* PrintfTail10: pshs the format, [pprintf], then PopFrame10Ret: DrawStaff falls in, DragIconAt branches in
PrintfTail10        pshs      a,b
                    jsr       [>UmeData_pprintf]
                    lbra      PopFrame10Ret
* EraseStaff: (n): printf('%c%c', $89, n) in DeleteStaff
EraseStaff          pshs      u
                    ldd       4,s
                    pshs      a,b
                    ldd       #$0089
                    bra       ErasePrintfTail
* DrawPartIcon: (part, staff, flags, 0, 0, 0): printf('%c'x7, $8A, ...) draws one part icon
DrawPartIcon        pshs      u
                    ldd       14,s
                    pshs      a,b
                    ldb       15,s
                    sex
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
                    ldd       #$008A
                    pshs      a,b
                    ldd       <UmeData_reserved_0014
                    pshs      a,b
                    jsr       [>UmeData_pprintf]
                    leas      <$10,s
                    puls      u,pc
* ErasePart: (n): printf('%c%c', $8B, n) in ForgetPart
ErasePart           pshs      u
                    ldd       4,s
                    pshs      a,b
                    ldd       #$008B
* ErasePrintfTail: Pushes the command and format <$0A; ErasePart falls in, EraseStaff branches in, joins PrintfTail6
ErasePrintfTail     pshs      a,b
                    ldd       <UmeData_reserved_000A
* PrintfTail6: pshs the format, [pprintf], leas 6,s, puls u,pc: shared by ModePrintfTail and ErasePrintfTail
PrintfTail6         pshs      a,b
                    jsr       [>UmeData_pprintf]
                    leas      6,s
                    puls      u,pc
* DrawParts: (from, to): for each part GetPartStaff then DrawPartIcon
DrawParts           pshs      u
                    leas      -10,s
                    ldd       14,s
                    bra       b30@
* a30@: loop body of DrawParts
a30@                leax      2,s
                    pshs      x
                    leax      6,s
                    pshs      x
                    ldd       12,s
                    pshs      a,b
                    lbsr      GetPartStaff
                    leas      6,s
                    std       6,s
                    clra
                    clrb
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    ldd       <$12,s
                    pshs      a,b
                    lbsr      DrawPartIcon
                    leas      12,s
                    ldd       8,s
                    addd      #$0001
b30@                std       8,s
                    ldd       8,s
                    cmpd      <$10,s
                    ble       a30@
* PopFrame10Ret: leas 10,s / puls u,pc: the DrawParts loop falls in and PrintfTail10 lbra's here
PopFrame10Ret       leas      10,s
                    puls      u,pc
* DrawStaves: (from, to): DrawStaff(i, $0C19[i].clef, $0C19[i].y) for each staff
DrawStaves          pshs      a,b,u
                    ldd       6,s
                    bra       b31@
* a31@: loop body of DrawStaves
a31@                ldd       ,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      Mul16
                    ldx       #$0C19
                    leax      d,x
                    ldd       ,x
                    pshs      a,b
                    ldd       2,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      Mul16
                    ldx       #$0C19
                    leax      d,x
                    ldd       2,x
                    pshs      a,b
                    ldd       4,s
                    pshs      a,b
                    lbsr      DrawStaff
                    leas      6,s
                    ldd       ,s
                    addd      #$0001
b31@                std       ,s
                    ldd       ,s
                    cmpd      8,s
                    ble       a31@
                    lbra      PopFrame2Ret
* ShowSignatures: scans part-0 events: type $0B -> keysig, type $0A -> time <$03/<$05; then printf $8C key and $8E num,den
ShowSignatures      pshs      u
                    clra
                    clrb
                    std       <UmeData_keysig
                    clra
                    clrb
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    bra       d32@
* a32@: event loop of ShowSignatures (stops at the first non-global event)
a32@                ldb       ,u
                    bne       e32@
                    ldb       5,u
                    cmpb      #$0B
                    bne       b32@
                    ldb       6,u
                    sex
                    std       <UmeData_keysig
b32@                ldb       5,u
                    cmpb      #$0A
                    bne       c32@
                    ldb       6,u
                    sex
                    std       <UmeData_reserved_0003
                    ldb       7,u
                    sex
                    std       <UmeData_reserved_0005
c32@                lbsr      NextEvent
d32@                tfr       d,u
                    ldd       <UmeData_curind
                    cmpd      <UmeData_nevents
                    blt       a32@
e32@                ldd       <UmeData_keysig
                    pshs      a,b
                    ldd       #$008C
                    pshs      a,b
                    ldd       <UmeData_reserved_000A
                    pshs      a,b
                    jsr       [>UmeData_pprintf]
                    leas      6,s
                    ldd       <UmeData_reserved_0005
                    pshs      a,b
                    ldd       <UmeData_reserved_0003
                    pshs      a,b
                    ldd       #$008E
                    pshs      a,b
                    ldd       <UmeData_reserved_000C
* PrintfTail8: pshs the format, [pprintf], leas 8,s, puls u,pc: ShowSignatures falls in, HilitePrintfTail lbra's in
PrintfTail8         pshs      a,b
                    jsr       [>UmeData_pprintf]
                    leas      8,s
                    puls      u,pc
* IsBarLine: (event*) -> 1 when byte0 (part) == 0 and byte5 (type) <= 6; delimits bars in the refill/erase scans
IsBarLine           pshs      u
                    ldb       [<$04,s]
                    bne       a33@
                    ldx       4,s
                    ldb       5,x
                    cmpb      #$06
                    bgt       a33@
                    ldd       #$0001
                    bra       PopUAndRet
a33@                clra
* RetZeroPopU: clrb completing the D=0 result: IsBarLine's false arm falls in, InRect lbra's here after clra
RetZeroPopU         clrb
* PopUAndRet: Bare puls u,pc shared by the two predicates: IsBarLine bra's and InRect lbra's here with D=1
PopUAndRet          puls      u,pc
* TransposeForClef(part, oldClef, newClef): unless either is 4, delta = $0162[old].w2 - $0162[new].w2, [ptranprt](part, delta, 0, last) shifts the notes
TransposeForClef    pshs      a,b,u
                    ldd       8,s
                    cmpd      #$0004
                    beq       PopFrame2Ret
                    ldd       10,s
                    cmpd      #$0004
                    beq       PopFrame2Ret
                    ldd       10,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$0162
                    leax      d,x
                    ldd       2,x
                    pshs      a,b
                    ldd       10,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$0162
                    leax      d,x
                    ldd       2,x
                    subd      ,s++
                    std       ,s
                    beq       PopFrame2Ret
                    ldd       <UmeData_nevents
                    addd      #$FFFF
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       4,s
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    jsr       [>UmeData_ptranprt]
                    leas      8,s
* PopFrame2Ret: leas 2,s / puls u,pc: TransposeForClef's three early exits plus GetPartStaff and DrawStaves jump here
PopFrame2Ret        leas      2,s
                    puls      u,pc
* RefillRests(start, end, part): for each bar where the part has no event, [pfulltime] bar time, [pparse]/[pregen] rest durations, [penter] inserts $20 rests; msgNotAllRefilled on failure
RefillRests         pshs      u
                    leas      <-$13,s
                    ldd       <$17,s
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    bra       b34@
* a34@: scan to the first bar line
a34@                pshs      u
                    lbsr      IsBarLine
                    std       ,s++
                    bne       c34@
                    lbsr      NextEvent
b34@                tfr       d,u
                    ldd       <UmeData_curind
                    cmpd      <$19,s
                    ble       a34@
c34@                ldd       <UmeData_curind
                    std       15,s
                    bra       d34@
* d34@: per-bar head: fetch the bar's time value, reset the has-events flag
d34@                leax      6,s
                    pshs      x
                    ldd       <$11,s
                    pshs      a,b
                    jsr       [>UmeData_pfulltime]
                    leas      2,s
                    lbsr      StoreLong
                    ldd       15,s
                    addd      #$0001
                    std       15,s
                    subd      #$0001
                    std       13,s
                    clra
                    clrb
                    stb       10,s
                    ldd       15,s
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    bra       g34@
* e34@: scan the bar for events of the part
e34@                pshs      u
                    lbsr      IsBarLine
                    std       ,s++
                    bne       h34@
                    ldb       ,u
                    sex
                    cmpd      <$1B,s
                    bne       f34@
                    ldd       #$0001
                    stb       10,s
f34@                lbsr      NextEvent
g34@                tfr       d,u
                    ldd       <UmeData_curind
                    cmpd      <$19,s
                    ble       e34@
h34@                ldd       <UmeData_curind
                    cmpd      <$19,s
                    lbgt      l34@
                    ldd       <UmeData_curind
                    std       15,s
                    ldb       10,s
                    lbne      d34@
                    ldd       8,s
                    pshs      a,b
                    ldd       1,u
                    subd      ,s++
                    std       ,s
                    bne       i34@
                    lbra      d34@
i34@                ldd       #$0020
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    jsr       [>UmeData_pparse]
                    leas      8,s
* j34@: insert rests until the bar is full; the end index grows with each insert
j34@                ldd       #$0001
                    pshs      a,b
                    leax      <$13,s
                    pshs      x
                    leax      <$16,s
                    pshs      x
                    jsr       [>UmeData_pregen]
                    leas      6,s
                    std       ,s
                    leax      2,s
                    pshs      x
                    leax      8,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       6,s
                    lbsr      LongFromInt
                    lbsr      LongAdd
                    lbsr      StoreLong
                    ldd       #$0020
                    pshs      a,b
                    ldd       <$1D,s
                    pshs      a,b
                    leax      6,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    jsr       [>UmeData_penter]
                    leas      8,s
                    std       11,s
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    tfr       d,u
                    ldd       11,s
                    bge       k34@
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgNotAllRefilled,pcr
                    pshs      x
                    jsr       [>UmeData_palert]
                    leas      4,s
                    clra
                    clrb
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       <$1F,s
                    pshs      a,b
                    ldd       <$15,s
                    pshs      a,b
                    ldd       <$15,s
                    pshs      a,b
                    bsr       ErasePartEvents
                    leas      10,s
                    bra       l34@
k34@                ldb       <$12,s
                    stb       3,u
                    ldb       <$11,s
                    stb       4,u
                    ldd       #$0002
                    stb       7,u
                    ldd       <$19,s
                    addd      #$0001
                    std       <$19,s
                    ldd       15,s
                    addd      #$0001
                    std       15,s
                    ldd       ,s
                    lbgt      j34@
                    lbra      d34@
l34@                leas      <$13,s
                    puls      u,pc
* ErasePartEvents(start, end, part, all, restsOnly): restsOnly && !all deletes the part's $20 rests; otherwise, bar by bar, when all is set or the bar holds no notes of the part, deletes the part's events and (with all) the part-0 IsPartRefType events referring to it
ErasePartEvents     pshs      u
                    leas      -3,s
                    ldb       <$10,s
                    beq       e35@
                    ldb       14,s
                    bne       e35@
                    ldd       7,s
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    bra       c35@
* a35@: simple scan deleting rests of the part ([premove], reseek, end--)
a35@                ldb       ,u
                    sex
                    cmpd      11,s
                    bne       b35@
                    ldb       5,u
                    cmpb      #$20
                    bne       b35@
                    ldd       <UmeData_curind
                    std       1,s
                    pshs      a,b
                    jsr       [>UmeData_premove]
                    leas      2,s
                    ldd       1,s
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    tfr       d,u
                    ldd       9,s
                    addd      #$FFFF
                    std       9,s
                    bra       d35@
b35@                lbsr      NextEvent
c35@                tfr       d,u
d35@                ldd       <UmeData_curind
                    cmpd      9,s
                    ble       a35@
                    lbra      t35@
* e35@: bar-wise variant: seek start and find the first bar line
e35@                ldd       7,s
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    bra       g35@
* f35@: scan to the first bar line
f35@                pshs      u
                    lbsr      IsBarLine
                    std       ,s++
                    bne       h35@
                    lbsr      NextEvent
g35@                tfr       d,u
                    ldd       <UmeData_curind
                    cmpd      9,s
                    ble       f35@
h35@                bra       i35@
* i35@: per-bar head: remember the first event index, clear the has-notes flag
i35@                lbsr      NextEvent
                    tfr       d,u
                    ldd       <UmeData_curind
                    std       1,s
                    clra
                    clrb
                    stb       ,s
                    bra       l35@
* j35@: scan the bar for non-rest events of the part
j35@                pshs      u
                    lbsr      IsBarLine
                    std       ,s++
                    bne       m35@
                    ldb       ,u
                    sex
                    cmpd      11,s
                    bne       k35@
                    ldb       5,u
                    cmpb      #$20
                    beq       k35@
                    ldd       #$0001
                    stb       ,s
k35@                lbsr      NextEvent
                    tfr       d,u
l35@                ldd       <UmeData_curind
                    cmpd      9,s
                    ble       j35@
m35@                ldd       <UmeData_curind
                    cmpd      9,s
                    lbgt      t35@
                    ldb       14,s
                    bne       n35@
                    ldb       ,s
                    bne       i35@
n35@                ldd       1,s
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    bra       r35@
o35@                ldb       ,u
                    sex
                    cmpd      11,s
                    beq       p35@
                    ldb       14,s
                    beq       q35@
                    ldb       ,u
                    bne       q35@
                    ldb       6,u
                    sex
                    cmpd      11,s
                    bne       q35@
                    ldb       5,u
                    sex
                    pshs      a,b
                    lbsr      IsPartRefType
                    leas      2,s
                    beq       q35@
* p35@: [premove](index), SeekEvent back, end index--
p35@                ldd       <UmeData_curind
                    std       1,s
                    pshs      a,b
                    jsr       [>UmeData_premove]
                    leas      2,s
                    ldd       1,s
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    tfr       d,u
                    ldd       9,s
                    addd      #$FFFF
                    std       9,s
                    bra       s35@
q35@                lbsr      NextEvent
r35@                tfr       d,u
* s35@: delete pass over the bar (stops at the next bar line)
s35@                pshs      u
                    lbsr      IsBarLine
                    leas      2,s
                    lbeq      o35@
                    lbra      i35@
t35@                leas      3,s
                    puls      u,pc
* RenumberParts: (deleted): decrements byte0 of events with part >= deleted, and byte6 of part-0 IsPartRefType events referencing a higher part
RenumberParts       pshs      a,b,u
                    clra
                    clrb
                    pshs      a,b
                    lbsr      SeekEvent
                    leas      2,s
                    bra       d36@
* a36@: event loop of RenumberParts
a36@                ldb       ,u
                    sex
                    std       ,s
                    cmpd      6,s
                    blt       b36@
                    ldb       ,u
                    addd      #$FFFF
                    stb       ,u
                    bra       c36@
b36@                ldd       ,s
                    bne       c36@
                    ldb       5,u
                    sex
                    pshs      a,b
                    lbsr      IsPartRefType
                    leas      2,s
                    beq       c36@
                    ldb       6,u
                    sex
                    cmpd      6,s
                    blt       c36@
                    ldb       6,u
                    addd      #$FFFF
                    stb       6,u
c36@                lbsr      NextEvent
d36@                tfr       d,u
                    ldd       <UmeData_curind
                    cmpd      <UmeData_nevents
                    blt       a36@
                    leas      2,s
                    puls      u,pc
* msgForgetPart: 'Forgetting Part X.  Sure?' template; ForgetPart copies it and patches the X with PartToChar
msgForgetPart       fcc       /Forgetting Part X.  Sure?/
                    fcb       $00
* msgNotAllRefilled: ' Not all bars ReFilled.' shown when the rest insert [penter] fails
msgNotAllRefilled   fcc       / Not all bars ReFilled./
                    fcb       $00
* SeekEvent(n): curind = n, page = n/928 + 1 (loaded via [ppswap] if not curpage); returns curevp = database + (n%928)*8, 0 on failure
SeekEvent           pshs      u
                    ldu       4,s
                    leas      -2,s
                    stu       <UmeData_curind
                    ldd       #$0001
                    bra       b37@
a37@                ldd       ,s
                    addd      #$0001
b37@                std       ,s
                    leau      >-$03A0,u
                    stu       -2,s
                    bge       a37@
                    leau      >$03A0,u
                    ldd       ,s
                    cmpd      <UmeData_curpage
                    beq       c37@
                    ldd       ,s
                    pshs      a,b
                    jsr       [>UmeData_ppswap]
                    leas      2,s
                    bne       c37@
                    clra
                    clrb
                    bra       d37@
c37@                tfr       u,d
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    addd      <UmeData_database
                    std       <UmeData_curevp
d37@                leas      2,s
                    puls      u,pc
* NextEvent: advances curind/curevp by one 8-byte event, loading the next page via [ppswap] past curptop; returns curevp
NextEvent           pshs      u
                    ldd       <UmeData_curind
                    addd      #$0001
                    std       <UmeData_curind
                    cmpd      <UmeData_nevents
                    bge       b38@
                    ldd       <UmeData_curevp
                    addd      #$0008
                    std       <UmeData_curevp
                    cmpd      <UmeData_curptop
                    bls       b38@
                    ldd       <UmeData_curpage
                    addd      #$0001
                    pshs      a,b
                    jsr       [>UmeData_ppswap]
                    leas      2,s
                    ldd       <UmeData_database
                    bra       a38@
                    fcb       $34,$40,$DC,$2B,$C3,$FF,$FF,$DD
                    fcb       $2B,$2D,$1D,$DC,$23,$C3,$FF,$F8
                    fcb       $DD,$23,$10,$93,$25,$24,$11,$DC
                    fcb       $2F,$C3,$FF,$FF,$34,$06,$AD,$9F
                    fcb       $03,$99,$32,$62,$DC,$27
a38@                std       <UmeData_curevp
b38@                ldd       <UmeData_curevp
                    puls      u,pc
* MemCopy: (dst, src, len): byte copy while src < src+len
MemCopy             pshs      u
                    leas      -2,s
                    ldx       6,s
                    ldu       8,s
                    ldd       8,s
                    addd      10,s
                    std       ,s
                    bra       b39@
a39@                ldb       ,u+
                    stb       ,x+
b39@                cmpu      ,s
                    blo       a39@
                    leas      2,s
                    puls      u,pc
                    fcb       $34,$40,$EE,$66,$AE,$64,$8D,$16
                    fcb       $1F,$01,$20,$06
* StrCopy: (dst, src): copies through the NUL, returns dst
StrCopy             pshs      u
                    ldu       6,s
                    ldx       4,s
a40@                ldb       ,u+
                    stb       ,x+
                    bne       a40@
                    ldd       4,s
                    puls      u,pc
                    fcb       $AE,$62,$E6,$80,$26,$FC,$30,$1F
                    fcb       $1F,$10,$39
* LongAdd: C long helper: adds the long at X to the stacked long into the accumulator $0343,y
LongAdd             ldd       4,s
                    addd      2,x
                    std       >$0345,y
                    ldd       2,s
                    adcb      1,x
                    adca      ,x
                    std       >$0343,y
                    lbra      LongAddRet
                    fcb       $EC,$64,$A3,$02,$ED,$A9,$03,$45
                    fcb       $EC,$62,$E2,$01,$A2,$84,$ED,$A9
                    fcb       $03,$43,$16,$00,$2F
* LongFromInt: C long helper: sign-extends D into the accumulator $0343,y, X -> it
LongFromInt         leax      >$0343,y
                    std       2,x
                    tfr       a,b
                    sex
                    tfr       a,b
                    std       ,x
                    rts
                    fcb       $30,$A9,$03,$43,$ED,$02,$6F,$84
                    fcb       $6F,$01,$39
* StoreLong: C long helper: copies the 4 bytes at X to the address pushed by the caller and drops it from the stack
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
* LongAddRet: tail of LongAdd: saves CC, pops the stacked long, returns X -> the $0343,y long accumulator
LongAddRet          tfr       cc,a
                    puls      x
                    stx       2,s
                    leas      2,s
                    leax      >$0343,y
                    tfr       a,cc
                    rts
                    fcb       $EC,$84,$ED,$A9,$03,$43,$EC,$02
                    fcb       $30,$A9,$03,$43,$ED,$02,$39
* Mul16: Microware C multiply: D * word at 2,s (fast 8x8 path, else four mul partials)
Mul16               tsta
                    bne       a41@
                    tst       2,s
                    bne       a41@
                    lda       3,s
                    mul
                    ldx       ,s
                    stx       2,s
                    ldx       #$0000
                    std       ,s
                    puls      a,b,pc
a41@                pshs      a,b
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
                    bhs       b41@
                    inc       ,s
b41@                lda       4,s
                    ldb       9,s
                    mul
                    addd      1,s
                    std       1,s
                    bhs       c41@
                    inc       ,s
c41@                lda       4,s
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
* DivByZero: Divisor 0: errno 45 and RaiseSignal
DivByZero           puls      a,b
                    std       ,s
                    ldd       #$002D
                    lbra      RaiseSignal
* DivMod16: Microware C signed divide: word at 2,s / D, shift-subtract loop; quotient in D, remainder in X
DivMod16            subd      #$0000
                    beq       DivByZero
                    pshs      a,b
                    leas      -2,s
                    clr       ,s
                    clr       1,s
                    tsta
                    bpl       a42@
                    nega
                    negb
                    sbca      #$00
                    com       1,s
                    std       2,s
a42@                ldd       6,s
                    bpl       b42@
                    nega
                    negb
                    sbca      #$00
                    com       1,s
                    std       6,s
b42@                lda       #$01
c42@                inca
                    asl       3,s
                    rol       2,s
                    bpl       c42@
                    sta       ,s
                    ldd       6,s
                    clr       6,s
                    clr       7,s
d42@                subd      2,s
                    bhs       e42@
                    addd      2,s
                    andcc     #$FE
                    bra       f42@
e42@                orcc      #$01
f42@                rol       7,s
                    rol       6,s
                    lsr       2,s
                    ror       3,s
                    dec       ,s
                    bne       d42@
                    std       2,s
                    tst       1,s
                    beq       g42@
                    ldd       6,s
                    nega
                    negb
                    sbca      #$00
                    std       6,s
g42@                ldx       4,s
                    ldd       6,s
                    std       4,s
                    stx       6,s
                    ldx       2,s
                    ldd       4,s
                    leas      6,s
                    rts
* RaiseSignal: Stores the code at $034F,y, F$ID, F$Send to own process (C runtime error trap)
RaiseSignal         std       >$034F,y
                    pshs      b,y
                    os9       F$ID
                    puls      b,y
                    os9       F$Send
                    rts
                    fcb       $39,$8E,$00,$00,$5F,$10,$3F,$0A
                    fcb       $16,$00
                    fcs       /'94`./
                    fcb       $66,$10,$AE,$68,$EE,$6A,$10,$3F
                    fcb       $17,$35,$E0,$A6,$63,$E6,$65,$10
                    fcb       $3F,$0F,$10,$25,$00,$0D,$39,$AE
                    fcb       $62,$10,$3F,$0A,$10,$25,$00,$03
                    fcb       $1F,$10,$39,$4F,$ED,$A9,$03,$4F
                    fcb       $CC,$FF,$FF,$39,$25,$F5
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
                    fcc       /s9l/
                    fcb       $00

                    emod
eom                 equ       *
                    end
