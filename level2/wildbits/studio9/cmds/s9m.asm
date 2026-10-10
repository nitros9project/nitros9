********************************************************************
* s9m - Studio-9 MIDI setup overlay: the MIDI MENU, MIDI Modes, MIDI Volume Levels and
* INSTRUMENTS editors
* Ported from the UltiMusE III 10.11.4e module (disassembled byte-exact); routine names are
* evidence-based readings. Local labels read a<n>@, b<n>@: the letter is the label, n the routine.
* Event pages hold 928 records ($03A0), not the original 1020, so a page fits the $1D00
* visible bytes of DAT slot 7; SeekRecord's page divide carries the constant.
*
* s9 runs it through [psoowee] with a command character: 'm' opens the MIDI MENU (part->channel
* table editor with part/channel checkboxes and an in-place channel field, play), 'i' opens the
* INSTRUMENTS editor (64 patch numbers + 16-char names, kopy/move/swap/x-out, read/write via
* overlay s9d, percussion sub-editor) and 's' lists the 24 instruments of the current page,
* marking with '>' those referenced by instrument-change records in the score. Inside the MIDI
* menu, 'm' opens MIDI Modes (instrument changes, clocks, events, master volume, min/max note,
* use clocks, transpose, seconds per minute, accent weight; a condensed menu through [pMenu3]),
* 'l' the MIDI Volume Levels editor (8 velocities ppp..fff, with an even-spacing interpolator)
* and 'v' overlay s9r's MIDI Devices menu.
* Screens are driven through s9's vectors: [pprintf]/[psprintf], [pgets]/[pcharmaus] read a
* line/key, [pputchar], [pyesno], [ptextmen] the mouse/keyboard picker (a cell index, or minus
* the key), [pkeymaus], [pplay], [psoowee], [pmouce], [ppswap]. s9gui commands go out through
* the DP formats (<$14 = seven %c, <$18 = "%c%c\r", <$16 = "%c\r"): $9A n select window (also
* stored in curcurse), $C4 n show form, $C6 x y w h a style create a window (then [pflush]),
* $C7 close it, $CC n cursor, $B8 invert a rectangle (through [pnfwrite]). Shared data:
* MidiChanTbl part->channel (17), MidiPartOn, MidiChanOn, $0103 level velocities, $0182 pointer
* to the ppp..fff names, $075F patch codes[64], $07EB names[64][16], $03C6 list-top index,
* $0CA3 percussion note numbers[17], $0184 drum-name pointers, $0CB4 synth name; score records
* are 8 bytes in 928-record pages walked with SeekRecord/PrevRecord. The tail is the Microware C
* library (strncpy, memcpy, atoi, 16x16 multiply, signed divide with a divide-by-zero signal
* trap, F$Sleep wrapper, the errno/-1 return), followed by the original initialized-data image
* (including the "Hi, Lester" padding array).

                    nam       s9m
                    ttl       s9m (disassembly)

                  IFP1
                    use       defsfile
                  ENDC
UME_SCOPE_S9M                  equ       1
                    use       equates.asm

tylg                set       $11
atrv                set       $81
size                equ       $104C

                    mod       eom,name,tylg,atrv,start,size
name                fcs       /s9m/
                    fcb       $08
start               equ       *
                    lbra      CmdDispatch
                    fcb       $39,$0D,$00
* CmdDispatch: overlay entry: the command char from [psoowee] (5,s) into X, compared against 'm', 'i', 's'
CmdDispatch         pshs      u
                    ldb       5,s
                    sex
                    tfr       d,x
                    bra       CmdCompare
* DoMidiMenu: 'm': MidiMenu, then CmdReturn
DoMidiMenu          lbsr      MidiMenu
                    bra       CmdReturn
* DoInstrMenu: 'i': InstrMenu, then CmdReturn
DoInstrMenu         lbsr      InstrMenu
                    bra       CmdReturn
* DoShowInstrList: 's': ShowInstrList, then CmdReturn
DoShowInstrList     lbsr      ShowInstrList
                    bra       CmdReturn
* CmdCompare: dispatch on 'm', 'i', 's'; unknown commands fall through to the return
CmdCompare          cmpx      #$006D
                    beq       DoMidiMenu
                    cmpx      #$0069
                    beq       DoInstrMenu
                    cmpx      #$0073
                    beq       DoShowInstrList
* CmdReturn: common exit: stores the byte at data $01A6 into the result slot (a constant from the printf power-of-ten table, effectively meaningless) and puls u,pc
CmdReturn           ldb       >UmeData_reserved_01A6
                    stb       5,s
                    puls      u,pc
* BoxGlyph: B = a switch byte -> D = its checkbox glyph (GlyphBoxOn or GlyphBoxOff); replaces the C routine
* OnOffChar.
BoxGlyph            clra
                    tstb
                    beq       mma1@
                    ldb       #GlyphBoxOn-GlyphBoxOff
mma1@               addb      #GlyphBoxOff
                    rts
* ChanChars: B = MIDI channel 0-15 -> A, B = channel+1 as two digits, "01".."16"
ChanChars           incb
                    lda       #'0
                    cmpb      #10
                    blo       mma2@
                    inca
                    subb      #10
mma2@               addb      #'0
                    rts
* MidiRowCell: B = part, X = five printf words, U = the menu frame: part box, part character, channel box and
* the two channel characters - the field editor's buffer instead when the part is the one being edited
MidiRowCell         clra
                    pshs      d,x                 ,s the part  2,s the words
                    ldx       #MidiPartOn
                    ldb       b,x
                    bsr       BoxGlyph
                    std       [2,s]
                    lbsr      PartNumToChar       (,s = the part)
                    ldx       2,s
                    std       2,x
                    ldb       1,s
                    leax      MmTbl,u
                    ldb       b,x                 the part's channel 0-15
                    pshs      b
                    ldx       #MidiChanOn
                    ldb       b,x
                    bsr       BoxGlyph
                    ldx       3,s
                    std       4,x
                    puls      b
                    bsr       ChanChars
                    pshs      d
                    ldb       3,s                 the part
                    cmpb      MmEdit,u
                    puls      d
                    bne       mma3@
                    ldd       MmBuf,u
mma3@               ldx       2,s
                    stb       9,x
                    tfr       a,b
                    clra
                    std       6,x
                    clr       8,x
                    puls      d,x,pc
* MidiDrawMenu: U = the menu frame. Prints the title, the column header and the eight rows of parts u and u+8
MidiDrawMenu        leax      >msgMidiMenuTitle,pcr
                    bsr       MidiPuts
                    leax      >msgPartChanHdr,pcr
                    bsr       MidiPuts
                    ldb       #1
mma4@               pshs      b
                    leas      -20,s               ten printf words: the left part, then the right
                    leax      ,s
                    bsr       MidiRowCell
                    ldb       20,s
                    addb      #8
                    leax      10,s
                    bsr       MidiRowCell
                    leax      >fmtMidiMenuRow,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      22,s
                    puls      b
                    incb
                    cmpb      #8
                    bls       mma4@
                    rts
MidiPuts            pshs      x
                    jsr       [>UmeData_pprintf]
                    puls      x,pc
* MidiEditMark: U = the menu frame. Inverts the field character under the cursor (FrInvert works on both
* pages, so a second call puts it back)
MidiEditMark        ldb       MmEdit,u
                    decb
                    lda       #MidiMenuCol+MidiChanCol
                    bitb      #8
                    beq       mma5@
                    adda      #MidiHalfCols
mma5@               adda      MmCurs,u
                    sta       <UmeData_arg1
                    sta       <UmeData_arg3
                    andb      #7
                    lda       #TextLineH
                    mul
                    negb
                    addb      #MidiMenuTop-TextTopPad-(MidiMenuHead+1)*TextLineH+1
                    stb       <UmeData_arg2
                    addb      #TextLineH-1
                    stb       <UmeData_arg4
                    ldb       #FrInvert
                    stb       <UmeData_arg0
                    ldd       #5
                    pshs      d
                    jsr       [>UmeData_pnfwrite]
                    leas      2,s
                    jmp       [>UmeData_pflush]
* MidiMenu: MIDI MENU editor (command 'm'): copies the 17-byte part->channel table to the working copy
* at MmTbl, sets the redraw flag and enters the menu loop
MidiMenu            pshs      u
                    leas      <-MmFrame,s
                    ldd       #17
                    pshs      a,b
                    ldx       #MidiChanTbl
                    pshs      x
                    leax      MmTbl+4,s
                    pshs      x
                    lbsr      MemCopy
                    leas      6,s
                    ldd       #$0001
                    stb       MmRedraw,s
                    lbra      MidiMenuAgain
* MidiMenuLoop: loop head: when the redraw flag is set draws the window frame and clears the flag
MidiMenuLoop        ldb       MmRedraw,s
                    beq       MidiMenuHeader
                    ldu       #WinMenu            style: a drop-down menu - black interior, inverted text
                    ldx       #1                  save the background
                    ldd       #MidiMenuH
                    pshs      u,x,d
                    ldu       #MidiMenuW
                    ldx       #MidiMenuTop
                    ldd       #MidiMenuCol
                    pshs      u,x,d
                    lbsr      DrawBox
                    leas      12,s
                    clr       MmRedraw,s
* MidiMenuHeader: no field editor; the title, the column header and the part rows
MidiMenuHeader      clr       MmEdit,s
                    leau      ,s
                    lbsr      MidiDrawMenu
* MidiMenuPick: ChoicePrompt(form 5) then the picker [ptextmen]: negative = -key, 0 = a click off the menu
* (ENTER), else the cell. Two cells a row, MidiPickW wide, so the command rows highlight whole; in a part row
* the pointer's x picks the item.
MidiMenuPick        ldx       #0
                    ldd       #5
                    pshs      x,d
                    lbsr      ChoicePrompt
                    leas      4,s
                    ldu       #1
                    ldx       #MidiMenuRows
                    ldd       #MidiMenuHead
                    pshs      u,x,d
                    ldu       #MidiPickCols
                    ldx       #MidiPickW
                    ldd       #MidiMenuTop
                    pshs      u,x,d
                    ldd       #MidiMenuCol
                    pshs      d
                    jsr       [>UmeData_ptextmen]
                    leas      14,s
                    std       ,s
                    blt       MidiPickKey
                    decb
                    cmpb      #15
                    bls       MidiPickPart
                    incb
                    leax      >tblMidiPickKeys,pcr
                    ldb       b,x
                    bra       MidiMenuKey
MidiPickKey         negb
                    bra       MidiMenuKey
* MidiPickPart: B = part-row cell 0-15 (row*2 + half). The pointer's x (pmouce, pixels) gives the text column:
* left of MidiChanBoxCol the part box/number, then the channel box, from MidiChanCol the channel number.
MidiPickPart        pshs      b
                    leas      -4,s                the pointer's x, then its row
                    leax      2,s
                    pshs      x
                    leax      2,s
                    pshs      x
                    jsr       [>UmeData_pmouce]
                    leas      4,s
                    ldd       ,s                  x in pixels, 8 a column
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    subb      #MidiMenuCol        the text column in the menu
                    leas      4,s
                    puls      a                   the cell
                    lsra                          A = the row, carry = the right half
                    bcc       mmp1@
                    subb      #MidiHalfCols
                    adda      #8
mmp1@               inca                          A = the part
                    cmpb      #MidiChanCol
                    bhs       mmp2@
                    cmpb      #MidiChanBoxCol
                    tfr       a,b
                    blo       MidiCellPart
                    bra       MidiCellChan
mmp2@               tfr       a,b
                    bra       MidiChanEdit
* MidiMenuKey: echoes the key and converts it to a part number (1-9, a-g); a part opens its channel's
* field editor, 0 is a command key
MidiMenuKey         stb       MmKey,s
                    sex
                    pshs      a,b
                    jsr       [>UmeData_pputchar]
                    ldb       MmKey+2,s
                    sex
                    std       ,s
                    lbsr      PartCharToNum
                    leas      2,s
                    tstb
                    bne       MidiChanEdit
* MidiCmdKey: part number 0: reload the key and jump to the command dispatch
MidiCmdKey          ldb       MmKey,s
                    sex
                    tfr       d,x
                    lbra      MidiCmdDispatch
* MidiCellChan / MidiCellPart: a click on a checkbox toggles it: B = part; flips MidiChanOn of
* the part's channel (every part on that channel) or MidiPartOn of the part
MidiCellChan        leax      MmTbl,s
                    ldb       b,x
                    ldx       #MidiChanOn
                    bra       MidiToggle
MidiCellPart        ldx       #MidiPartOn
MidiToggle          abx
                    clrb
                    tst       ,x
                    bne       mma7@
                    incb
mma7@               stb       ,x
                    lbra      MidiMenuAgain
* MidiChanEdit: B = part. The menu is redrawn with the field (two digits, 01-16) in place of the part's channel
* and the character under the cursor inverted. A digit types over the cursor and moves it right, left arrow/BS
* and right arrow move, ENTER or a click applies 1-16 to the working table (else a beep), BREAK leaves it
* unchanged, other keys are ignored.
MidiChanEdit        stb       MmEdit,s
                    leax      MmTbl,s
                    ldb       b,x
                    lbsr      ChanChars
                    std       MmBuf,s
                    clr       MmBuf+2,s
                    clr       MmCurs,s
                    leau      ,s
MidiEditLoop        lbsr      MidiDrawMenu
                    ldd       #5
                    pshs      a,b
                    lbsr      ShowForm
                    leas      2,s
                    lbsr      MidiEditMark
                    leas      -4,s                the pointer's x and row
                    leax      ,s
                    pshs      x
                    leax      4,s
                    pshs      x
                    jsr       [>UmeData_pkeymaus]
                    leas      8,s
                    pshs      b
                    lbsr      MidiEditMark        the character back before the redraw
                    puls      b
                    tstb
                    beq       MidiEditApply       a click
                    cmpb      #C$CR
                    beq       MidiEditApply
                    cmpb      #C$QUIT
                    beq       MidiEditLeave
                    cmpb      #C$INTR
                    beq       MidiEditLeave
                    cmpb      #C$BSP
                    beq       mma8@
                    cmpb      #C$RARR
                    beq       mmb8@
                    subb      #'0
                    cmpb      #9
                    bhi       MidiEditLoop
                    addb      #'0
                    leax      MmBuf,u
                    lda       MmCurs,u
                    stb       a,x                 over the cursor's digit (both digits always present, 01-16)
mmb8@               lda       #1
                    sta       MmCurs,u
                    bra       MidiEditLoop
mma8@               clr       MmCurs,u
                    bra       MidiEditLoop
MidiEditApply       leax      MmBuf,u
                    pshs      x
                    lbsr      AsciiToInt
                    leas      2,s
                    subd      #1
                    cmpd      #15
                    bls       mmd8@
                    lbsr      ErrBeep
                    bra       MidiEditLoop
mmd8@               lda       MmEdit,u
                    leax      MmTbl,u
                    stb       a,x
MidiEditLeave       lbra      MidiMenuAgain
* MidiHashHelp: '#' key: prints the help line '#' means a Part No. 0 - 9, a - g.
MidiHashHelp        leax      >msgHashHelp,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    lbra      MidiMenuAgain
* MidiPlayCmd: 'p' / 'w': commits the working table to MidiChanTbl, FlushDisplay and redraw if pldebug, putchar CR, [pplay](from = key == 'w' ? lftind : 0, nevents-1); leaves the menu if rfr_scr is set
MidiPlayCmd         ldd       #$0011
                    pshs      a,b
                    leax      <$5D,s
                    pshs      x
                    ldx       #MidiChanTbl
                    pshs      x
                    lbsr      MemCopy
                    leas      6,s
                    ldb       <UmeData_pldebug
                    beq       a3@
                    lbsr      FlushDisplay
                    ldd       #$0001
                    stb       8,s
a3@                 ldd       #$000D
                    pshs      a,b
                    jsr       [>UmeData_pputchar]
                    leas      2,s
                    ldd       <UmeData_nevents
                    addd      #$FFFF
                    pshs      a,b
                    ldb       11,s
                    cmpb      #$77
                    bne       b3@
                    ldd       <UmeData_lftind
                    bra       c3@
b3@                 clra
                    clrb
c3@                 pshs      a,b
                    jsr       [>UmeData_pplay]
                    leas      4,s
                    ldb       <UmeData_rfr_scr
                    lbne      MidiMenuLeave
                    lbra      MidiMenuAgain
* MidiLevelsCmd: 'l': runs the MIDI Volume Levels editor then flushes the display
MidiLevelsCmd       lbsr      VolLevelsEditor
                    lbsr      FlushDisplay
                    lbra      MidiMenuAgain
* MidiChanRange: 'o': prompts --> for a channel, then From part / thru part (ENTER = all) and assigns that channel to every part of the range in the working table
MidiChanRange       leax      >msgArrowChan,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    leax      10,s
                    pshs      x
                    jsr       [>UmeData_pgets]
                    leas      2,s
                    leax      10,s
                    pshs      x
                    lbsr      AsciiToInt
                    leas      2,s
                    std       ,s
                    lbeq      MidiMenuAgain
                    ldd       ,s
                    addd      #$FFFF
                    clra
                    andb      #$0F
                    std       ,s
                    leax      >msgFromPart,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    lbsr      ReadPartKey
                    std       4,s
                    beq       a4@
                    leax      >msgThruPart,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    lbsr      ReadPartKey
                    std       2,s
                    bne       c4@
                    bra       b4@
a4@                 ldd       #$0001
                    std       4,s
b4@                 ldd       #$0010
                    std       2,s
c4@                 ldu       4,s
                    bra       ChanRangeTest
* ChanRangeLoop: loop body: table[u] = channel for u = from..thru
ChanRangeLoop       tfr       u,d
                    leax      <$5B,s
                    leax      d,x
                    ldd       ,s
                    stb       ,x
                    leau      1,u
* ChanRangeTest: loop test of MidiChanRange's fill: entered by bra from the setup, ble loops to ChanRangeLoop
ChanRangeTest       cmpu      2,s
                    ble       ChanRangeLoop
                    lbra      MidiMenuAgain
* MidiInitChans: 'i': initializes the working table so part n uses channel n-1
MidiInitChans       leax      MmTbl+1,s
                    clrb
mmi1@               stb       ,x+
                    incb
                    cmpb      #16
                    blo       mmi1@
                    lbra      MidiMenuAgain
* MidiDevicesCmd: 'v': s9r's MIDI Devices menu ([psoowee]('R','M')); B non-zero there = a DriveWire 4 dialog
* ran, so the working table is reloaded (MidiSettingsReload)
MidiDevicesCmd      ldd       #'M
                    pshs      d
                    ldd       #'R
                    pshs      d
                    jsr       [>UmeData_psoowee]
                    leas      4,s
                    tstb
                    lbne      MidiSettingsReload
                    lbra      MidiMenuAgain
* MidiSettingsCmd: 'm': the MIDI Modes sub-menu (MidiSettings); a nonzero B reloads the table
MidiSettingsCmd     lbsr      MidiSettings
                    tstb                          (B is always 0 here)
                    lbne      MidiSettingsReload
                    lbra      MidiMenuAgain
* MidiTurnOnAll: 't': asks Turn on All Parts? (sets MidiPartOn[1..16]) then Turn on All Channels?
* (sets MidiChanOn[0..15]); all sixteen parts, not just 1..part count
MidiTurnOnAll       ldb       #1
                    leax      >msgTurnOnParts,pcr
                    leau      >msgTurnOnChans,pcr
                    bra       MidiSetAll
* MidiShutOffAll: 'q': asks Shut off All Parts? then Shut off All Channels? and clears the same ranges
MidiShutOffAll      clrb
                    leax      >msgShutOffParts,pcr
                    leau      >msgShutOffChans,pcr
* MidiSetAll: B = the value, X = the parts question, U = the channels question (one routine for both C loop pairs)
MidiSetAll          pshs      b,u
                    pshs      x
                    jsr       [>UmeData_pyesno]
                    std       ,s++
                    beq       mms1@
                    ldx       #MidiPartOn+1
                    bsr       MidiFill16
mms1@               ldx       1,s
                    pshs      x
                    jsr       [>UmeData_pyesno]
                    std       ,s++
                    beq       mms2@
                    ldx       #MidiChanOn
                    bsr       MidiFill16
mms2@               leas      3,s
                    lbra      MidiMenuAgain
* MidiFill16: X = the first of 16 bytes, 2,s = the value
MidiFill16          lda       2,s
                    ldb       #16
mmf1@               sta       ,x+
                    decb
                    bne       mmf1@
                    rts
* MidiRestoreTbl: 'r': reloads the working copy from MidiChanTbl (discard edits)
MidiRestoreTbl      ldd       #$0011
                    pshs      a,b
                    ldx       #MidiChanTbl
                    pshs      x
                    leax      <$5F,s
                    lbra      MidiTblMemCopy
* MidiUpdateTbl: ENTER / 'u': copies the working table back to MidiChanTbl; 'u' stays in the menu, ENTER leaves
MidiUpdateTbl       ldd       #$0011
                    pshs      a,b
                    leax      <$5D,s
                    pshs      x
                    ldx       #MidiChanTbl
                    pshs      x
                    lbsr      MemCopy
                    leas      6,s
                    ldb       9,s
                    cmpb      #$75
                    lbeq      MidiMenuAgain
* MidiMenuLeave: 'n' (and after an aborted play): flush the display and return without committing the working table
MidiMenuLeave       lbsr      FlushDisplay
                    lbra      MidiMenuRet
* MidiKChansCmd: 'k': [pclonmid](1, nparts, working table); its exact effect on the table is unverified
MidiKChansCmd       leax      <$5B,s
                    pshs      x
                    ldd       <UmeData_nparts
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    jsr       [>UmeData_pclonmid]
                    bra       MidiTblCopyDone
* MidiAllChan01: 'h': parts 1-9 to channel 01 (0) in the working table; parts A-G keep theirs
MidiAllChan01       leax      MmTbl+1,s
                    ldb       #9
mmh1@               clr       ,x+
                    decb
                    bne       mmh1@
                    lbra      MidiMenuAgain
* MidiSettingsReload: a DriveWire 4 dialog ran (s9r): set the redraw flag and reload the working table from
* MidiChanTbl
MidiSettingsReload  ldd       #$0001
                    stb       8,s
                    ldd       #$0011
                    pshs      a,b
                    leax      <$5D,s
                    pshs      x
                    ldx       #MidiChanTbl
* MidiTblMemCopy: shared MemCopy call: MidiRestoreTbl lbra's in with MidiChanTbl as source, MidiSettingsReload falls through
MidiTblMemCopy      pshs      x
                    lbsr      MemCopy
* MidiTblCopyDone: shared cleanup: drops the 6 arg bytes and lbra MidiMenuAgain; the 'k' arm also branches here
MidiTblCopyDone     leas      6,s
                    lbra      MidiMenuAgain
* MidiBadKey: unknown key: ErrBeep and loop
MidiBadKey          lbsr      ErrBeep
                    lbra      MidiMenuAgain
* MidiCmdDispatch: compare chain for the MIDI menu commands: # p w l ^C ^E h o i m t q r ENTER u n k v, else beep
MidiCmdDispatch     cmpx      #'#
                    lbeq      MidiHashHelp
                    cmpx      #'p
                    lbeq      MidiPlayCmd
                    cmpx      #'w
                    lbeq      MidiPlayCmd
                    cmpx      #'l
                    lbeq      MidiLevelsCmd
                    cmpx      #C$INTR
                    beq       MidiMenuAgain
                    cmpx      #C$QUIT
                    beq       MidiMenuAgain
                    cmpx      #'h                 All Chan 01
                    lbeq      MidiAllChan01
                    cmpx      #'o
                    lbeq      MidiChanRange
                    cmpx      #'i
                    lbeq      MidiInitChans
                    cmpx      #'m
                    lbeq      MidiSettingsCmd
                    cmpx      #'t
                    lbeq      MidiTurnOnAll
                    cmpx      #'q
                    lbeq      MidiShutOffAll
                    cmpx      #'r
                    lbeq      MidiRestoreTbl
                    cmpx      #C$CR
                    lbeq      MidiUpdateTbl
                    cmpx      #'u
                    lbeq      MidiUpdateTbl
                    cmpx      #'n
                    lbeq      MidiMenuLeave
                    cmpx      #'k
                    lbeq      MidiKChansCmd
                    cmpx      #'v                 Devices...: s9r's MIDI Devices menu
                    lbeq      MidiDevicesCmd
                    lbra      MidiBadKey
* MidiMenuAgain: common continue: lbra MidiMenuLoop
MidiMenuAgain       lbra      MidiMenuLoop
* MidiMenuRet: MidiMenu epilogue: leas $6C,s; puls u,pc
MidiMenuRet         leas      <$6C,s
                    puls      u,pc
* MidiSettings: the MIDI Modes sub-menu: saves curcurse, selects window 2, loops on the menu until ENTER; 1,s = saved window, ,s = last key (0 = leave), 3,s = the B result
MidiSettings        pshs      u
                    leas      -4,s                3,s: returned in B, always 0 (the DW4 dialogs are s9r's)
                    clr       3,s
                    ldd       <UmeData_curcurse
                    std       1,s
                    ldd       #$0002
                    pshs      a,b
                    lbsr      SelectWindow
                    leas      2,s
* SettingsRedraw: sprintf's the three checkbox flags, then the fields, into MenuStates; then the MIDI Modes
* condensed menu (descMidiModes) through [pMenu3] -> key
SettingsRedraw      ldb       <UmeData_midievts
                    sex
                    pshs      a,b
                    ldb       <UmeData_clocken
                    sex
                    pshs      a,b
                    ldb       <UmeData_instren
                    sex
                    pshs      a,b
                    leax      >fmtThreeFlags,pcr
                    pshs      x
                    ldx       #MenuStates
                    pshs      x
                    jsr       [>UmeData_psprintf]         three flag words + format + destination = 10 bytes
                    leas      10,s
                    ldb       <UmeData_accentwt
                    sex
                    pshs      a,b
                    ldd       <UmeData_secmin
                    pshs      a,b
                    ldd       <UmeData_transp
                    pshs      a,b
                    ldb       <UmeData_scrclock
                    sex
                    pshs      a,b
                    ldb       <UmeData_midinnmax
                    sex
                    pshs      a,b
                    ldb       <UmeData_midinnmin
                    sex
                    pshs      a,b
                    ldd       <UmeData_velo
                    pshs      a,b
                    leax      >fmtSettingsVals,pcr
                    pshs      x
                    ldx       #MenuStates+3
                    pshs      x
                    jsr       [>UmeData_psprintf]         the fields, after the flags
                    leas      <$12,s
                    ldx       #MenuStates
                    pshs      x
                    leax      >descMidiModes,pcr
                    pshs      x
                    jsr       [>pMenu3]           s9 streams it to s9gui; key in B
                    leas      4,s
                    stb       ,s
                    lbsr      FlushDisplay
                    ldb       ,s
                    sex
                    tfr       d,x
                    lbra      SettingsDispatch
* SetAccentBoost: 'a': PromptBox, Accent Volume Boost [%d] -> accentwt
SetAccentBoost      clra
                    clrb
                    pshs      a,b
                    lbsr      PromptBox
                    leas      2,s
                    ldb       <UmeData_accentwt
                    sex
                    pshs      a,b
                    leax      >fmtAccentBoost,pcr
                    pshs      x
                    lbsr      PromptNumber
                    leas      4,s
                    stb       <UmeData_accentwt
                    lbra      SettingsFlush
* ToggleOptI: 'i': toggles instren, Instr changes (default 1; the player s9p skips a per-record action when clear)
ToggleOptI          ldb       <UmeData_instren
                    bne       a10@
                    ldd       #$0001
                    bra       b10@
a10@                clra
                    clrb
b10@                stb       <UmeData_instren
                    lbra      SettingsLoopEnd
* ToggleOptC: 'c': toggles clocken, Clocks enable (default 1; tested with scrclock by the player before an extra MIDI setup message)
ToggleOptC          ldb       <UmeData_clocken
                    bne       a11@
                    ldd       #$0001
                    bra       b11@
a11@                clra
                    clrb
b11@                stb       <UmeData_clocken
                    lbra      SettingsLoopEnd
* ToggleOptE: 'e': toggles midievts, Events enable (default 1; the player s9p gates a per-record routine on it)
ToggleOptE          ldb       <UmeData_midievts
                    bne       a12@
                    ldd       #$0001
                    bra       b12@
a12@                clra
                    clrb
b12@                stb       <UmeData_midievts
                    lbra      SettingsLoopEnd
* ToggleOptU: 'u': toggles scrclock, Use clocks (with clocken enables an extra player message)
ToggleOptU          ldb       <UmeData_scrclock
                    bne       a13@
                    ldd       #$0001
                    bra       b13@
a13@                clra
                    clrb
b13@                stb       <UmeData_scrclock
                    lbra      SettingsLoopEnd
* SetSecPerMin: 's': Seconds per Minute [%d] -> secmin, clamped 20..180 (default 60)
SetSecPerMin        clra
                    clrb
                    pshs      a,b
                    lbsr      PromptBox
                    leas      2,s
                    ldd       #$00B4
                    pshs      a,b
                    ldd       #$0014
                    pshs      a,b
                    ldd       <UmeData_secmin
                    pshs      a,b
                    leax      >fmtSecPerMin,pcr
                    pshs      x
                    lbsr      PromptNumber
                    leas      4,s
                    pshs      a,b
                    lbsr      ClampInt
                    leas      6,s
                    std       <UmeData_secmin
                    lbra      SettingsFlush
* SetSemiTones: 't': SemiTones [%d] -> transp, clamped -24..24
SetSemiTones        clra
                    clrb
                    pshs      a,b
                    lbsr      PromptBox
                    leas      2,s
                    ldd       #$0018
                    pshs      a,b
                    ldd       #$FFE8
                    pshs      a,b
                    ldd       <UmeData_transp
                    pshs      a,b
                    leax      >fmtSemiTones,pcr
                    pshs      x
                    lbsr      PromptNumber
                    leas      4,s
                    pshs      a,b
                    lbsr      ClampInt
                    leas      6,s
                    std       <UmeData_transp
                    lbra      SettingsFlush
* SetMasterVol: 'v': Master MIDI Volume [%d] -> velo, clamped -127..127
SetMasterVol        clra
                    clrb
                    pshs      a,b
                    lbsr      PromptBox
                    leas      2,s
                    ldd       #$007F
                    pshs      a,b
                    ldd       #$FF81
                    pshs      a,b
                    ldd       <UmeData_velo
                    pshs      a,b
                    leax      >fmtMasterVol,pcr
                    pshs      x
                    lbsr      PromptNumber
                    leas      4,s
                    pshs      a,b
                    lbsr      ClampInt
                    leas      6,s
                    std       <UmeData_velo
                    lbra      SettingsFlush
* SetMinNote: 'n': Min. MIDI Note No. [%d] -> midinnmin, clamped 1..127
SetMinNote          clra
                    clrb
                    pshs      a,b
                    lbsr      PromptBox
                    leas      2,s
                    ldd       #$007F
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldb       <UmeData_midinnmin
                    sex
                    pshs      a,b
                    leax      >fmtMinNote,pcr
                    pshs      x
                    lbsr      PromptNumber
                    leas      4,s
                    pshs      a,b
                    lbsr      ClampInt
                    leas      6,s
                    stb       <UmeData_midinnmin
                    bra       SettingsFlush
* SetMaxNote: 'x': Max. MIDI Note No. [%d] -> midinnmax, clamped 1..127
SetMaxNote          clra
                    clrb
                    pshs      a,b
                    lbsr      PromptBox
                    leas      2,s
                    ldd       #$007F
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldb       <UmeData_midinnmax
                    sex
                    pshs      a,b
                    leax      >fmtMaxNote,pcr
                    pshs      x
                    lbsr      PromptNumber
                    leas      4,s
                    pshs      a,b
                    lbsr      ClampInt
                    leas      6,s
                    stb       <UmeData_midinnmax
* SettingsFlush: shared tail of the numeric settings: FlushDisplay then loop end
SettingsFlush       lbsr      FlushDisplay
                    lbra      SettingsLoopEnd
* SettingsDone: ENTER: clears the key slot so SettingsLoopEnd leaves the sub-menu
SettingsDone        clra
                    clrb
                    stb       ,s
                    lbra      SettingsLoopEnd
* SettingsBadKey: unknown key: ErrBeep
SettingsBadKey      lbsr      ErrBeep
                    lbra      SettingsLoopEnd
* SettingsDispatch: the playing and score settings keys; ENTER leaves
SettingsDispatch    cmpx      #$0061
                    lbeq      SetAccentBoost
                    cmpx      #$0069
                    lbeq      ToggleOptI
                    cmpx      #$0063
                    lbeq      ToggleOptC
                    cmpx      #$0065
                    lbeq      ToggleOptE
                    cmpx      #$0075
                    lbeq      ToggleOptU
                    cmpx      #$0073
                    lbeq      SetSecPerMin
                    cmpx      #$0074
                    lbeq      SetSemiTones
                    cmpx      #$0076
                    lbeq      SetMasterVol
                    cmpx      #$006E
                    lbeq      SetMinNote
                    cmpx      #$0078
                    lbeq      SetMaxNote
                    cmpx      #$000D
                    lbeq      SettingsDone
                    lbra      SettingsBadKey
* SettingsLoopEnd: loops back to SettingsRedraw while the key slot is nonzero, else re-selects the saved window and returns
SettingsLoopEnd     ldb       ,s
                    lbne      SettingsRedraw
                    ldd       1,s
                    pshs      a,b
                    lbsr      SelectWindow
                    leas      2,s
                    ldb       3,s                 B = 0 for MidiSettingsCmd
                    leas      4,s
                    puls      u,pc
* VolLevelsEditor: MIDI Volume Levels editor ('l'): ShowForm(8) then edits the 8 velocity bytes at $0103 (ppp..fff)
VolLevelsEditor     pshs      u
                    leas      >-$0083,s
                    ldd       #$0008
                    pshs      a,b
                    lbsr      ShowForm
                    leas      2,s
* VolLevelsRedraw: loop head: prints the title and # EXPR VALUE header then the 8 level rows
VolLevelsRedraw     leax      >msgVolLevelsTitle,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    leax      >msgLevelsHdr,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    clra
                    clrb
                    bra       VolLevelsPick
* VolLevelRow: row body: printf ' %d  %3s  %3d' with the level number, its dynamic name ($0182 pointer + 4*level) and $0103[level]
VolLevelRow         ldd       8,s
                    ldx       #$0103
                    leax      d,x
                    ldb       ,x
                    sex
                    pshs      a,b
                    ldd       10,s
                    aslb
                    rola
                    aslb
                    rola
                    addd      >UmeData_reserved_0182
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    leax      >fmtLevelRow,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      8,s
                    ldd       8,s
                    addd      #$0001
* VolLevelsPick: row loop test; then prints E = Even spacing / # of Level to change and runs the picker (MidiSubCol,MidiSubTop origin, 10 rows)
VolLevelsPick       std       8,s
                    ldd       8,s
                    cmpd      #$0008
                    blt       VolLevelRow
                    leax      >msgEvenSpacing,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$000A
                    pshs      a,b
                    ldd       #$0003
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$001A
                    pshs      a,b
                    ldd       #MidiSubTop         the Levels window's origin (s9gui form 8)
                    pshs      a,b
                    ldd       #MidiSubCol
                    pshs      a,b
                    jsr       [>UmeData_ptextmen]
                    leas      14,s
                    stb       1,s
                    bge       VolPickToKey
                    ldb       1,s
                    sex
                    nega
                    negb
                    sbca      #$00
                    bra       VolLevelsKey
* VolPickToKey: picked cell -> key via tblLevelPickKeys '01234567 e'
VolPickToKey        leax      >tblLevelPickKeys,pcr
                    tfr       x,d
                    pshs      a,b
                    ldb       3,s
                    sex
                    addd      ,s++
                    tfr       d,x
                    ldb       ,x
* VolLevelsKey: echoes the key: ENTER exits, 'e' starts even spacing (From Level # key, ENTER = 0..7), digits edit one level
VolLevelsKey        stb       ,s
                    ldb       ,s
                    sex
                    pshs      a,b
                    jsr       [>UmeData_pputchar]
                    leas      2,s
                    ldb       ,s
                    cmpb      #$0D
                    lbeq      VolLevelsExit
                    ldb       ,s
                    cmpb      #$65
                    lbne      VolDigitKey
                    leax      >msgEnterAll07,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    leax      >msgFromLevel,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    leax      10,s
                    pshs      x
                    jsr       [>UmeData_pcharmaus]
                    leas      2,s
                    ldb       10,s
                    stb       ,s
                    cmpb      #$0D
                    bne       VolEvenToLevel
                    clra
                    clrb
                    std       2,s
                    ldd       #$0007
                    std       4,s
                    bra       VolEvenSetup
* VolEvenToLevel: even spacing: from = key&7, prompts To Level #, requires to-from >= 2 else redraw
VolEvenToLevel      ldb       10,s
                    sex
                    pshs      a,b
                    lbsr      PartCharToNum
                    leas      2,s
                    clra
                    andb      #$07
                    std       2,s
                    leax      >msgToLevel,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    lbsr      ReadPartKey
                    clra
                    andb      #$07
                    std       4,s
                    subd      2,s
                    cmpd      #$0002
                    lblt      VolLevelsRedraw
* VolEvenSetup: computes diff = level[to]-level[from] and starts the interpolation at i = to-1
VolEvenSetup        ldd       2,s
                    ldx       #$0103
                    leax      d,x
                    ldb       ,x
                    sex
                    pshs      a,b
                    ldd       6,s
                    ldx       #$0103
                    leax      d,x
                    ldb       ,x
                    sex
                    subd      ,s++
                    std       6,s
                    ldd       4,s
                    std       8,s
                    bra       VolEvenNext
* VolEvenLoop: loop body: level[i] = level[from] + MulInt(diff, i-from) / (to-from)
VolEvenLoop         ldd       8,s
                    ldx       #$0103
                    leax      d,x
                    pshs      x
                    ldd       4,s
                    ldx       #$0103
                    leax      d,x
                    ldb       ,x
                    sex
                    pshs      a,b
                    ldd       12,s
                    subd      6,s
                    pshs      a,b
                    ldd       12,s
                    lbsr      MulInt
                    pshs      a,b
                    ldd       10,s
                    subd      8,s
                    lbsr      DivIntRem
                    addd      ,s++
                    stb       [,s++]
* VolEvenNext: i -= 1; loop while i > from, then redraw
VolEvenNext         ldd       8,s
                    addd      #$FFFF
                    std       8,s
                    cmpd      2,s
                    bgt       VolEvenLoop
                    lbra      VolLevelsRedraw
* VolDigitKey: key - '0' -> level number, must be 0..7 else beep
VolDigitKey         ldb       ,s
                    sex
                    addd      #$FFD0
                    std       8,s
                    cmpd      #$0007
                    bgt       VolBadKey
                    ldd       8,s
                    bge       VolEditValue
* VolBadKey: ErrBeep and redraw
VolBadKey           lbsr      ErrBeep
                    lbra      VolLevelsRedraw
* VolEditValue: sprintf '#%d's New Value [%%d]: ' then PromptNumber with the current value; stores value & $7F into $0103[level]
VolEditValue        ldd       8,s
                    pshs      a,b
                    leax      >fmtNewValuePrompt,pcr
                    pshs      x
                    leax      <$5F,s
                    pshs      x
                    jsr       [>UmeData_psprintf]
                    leas      6,s
                    ldd       8,s
                    ldx       #$0103
                    leax      d,x
                    pshs      x
                    ldd       10,s
                    ldx       #$0103
                    leax      d,x
                    ldb       ,x
                    sex
                    pshs      a,b
                    leax      <$5F,s
                    pshs      x
                    lbsr      PromptNumber
                    leas      4,s
                    clra
                    andb      #$7F
                    stb       [,s++]
                    lbra      VolLevelsRedraw
* VolLevelsExit: epilogue: leas $83,s; puls u,pc
VolLevelsExit       leas      >$0083,s
                    puls      u,pc
* msgMidiMenuTitle: form feed + '        MIDI MENU' + CR
msgMidiMenuTitle    fcb       $0C
                    fcc       /        MIDI MENU/  centered
                    fcb       $0D,$00
* msgPartChanHdr: column header; "Part" over the part box and number, "Chan" over the channel box and number
msgPartChanHdr      fcc       /  Part  Chan   Part  Chan/   the right half one column right
                    fcb       $0D,$00
* fmtMidiMenuRow: two parts a row, each: part box, part, right arrow, channel box, two channel characters.
* Text columns 1, 3, 5, 7, 9-10, then 14, 16, 18, 20, 22-23 (MidiPickPart maps a click by column).
fmtMidiMenuRow      fcc       / %c %c /
                    fcb       GlyphArrowRight
                    fcc       / %c %c%c   %c %c /
                    fcb       GlyphArrowRight
                    fcc       / %c %c%c/
                    fcb       $0D,$00
* tblMidiPickKeys: picker cell -> key, two columns a row: ENTER (cell 0), the 16 part chars in row order (the
* keyboard's part keys; part-row clicks are handled as cells), then the command keys
tblMidiPickKeys     fcb       $0D
                    fcc       /192a3b4c5d6e7f8g  hiurkotqmlvn/   the command cells: h i u r k o t q m l v n
                    fcb       $00
* msgHashHelp: help text for the '#' key
msgHashHelp         fcc       / '#' means a Part No. 0 - 9, a - g./
                    fcb       $00
* msgArrowChan: '  -->' prompt for the channel in the range command
msgArrowChan        fcc       /  -->/
                    fcb       $00
* msgFromPart: '(ENTER for all parts)' CR 'From part:'
msgFromPart         fcc       /(ENTER for all parts)/
                    fcb       $0D
                    fcc       /From part:/
                    fcb       $00
* msgThruPart: ' thru part:'
msgThruPart         fcc       / thru part:/
                    fcb       $00
* msgTurnOnParts: ' Turn on All Parts?' yes/no text
msgTurnOnParts      fcc       / Turn on All Parts?/
                    fcb       $00
* msgTurnOnChans: ' Turn on All Channels?' yes/no text
msgTurnOnChans      fcc       / Turn on All Channels?/
                    fcb       $00
* msgShutOffParts: ' Shut off All Parts?' yes/no text
msgShutOffParts     fcc       / Shut off All Parts?/
                    fcb       $00
* msgShutOffChans: ' Shut off All Channels?' yes/no text
msgShutOffChans     fcc       / Shut off All Channels?/
                    fcb       $00
* Checkbox states in row order: Instr changes, Clocks enable, Events enable.
fmtThreeFlags       fcc       /%d%d%d/
                    fcb       $00
* fmtSettingsVals: CR-separated fields: master volume, min note, max note, Use clocks flag + transpose, seconds per minute, accent weight
fmtSettingsVals     fcc       /%2d/
                    fcb       $0D
                    fcc       /%3d/
                    fcb       $0D
                    fcc       /%3d/
                    fcb       $0D
                    fcc       /%d%3d/
                    fcb       $0D
                    fcc       /%2d/
                    fcb       $0D
                    fcc       /%3d/
                    fcb       $0D,$0D,$00
* descMidiModes: the MIDI Modes condensed-menu descriptor for [pMenu3]: key line, titles, then the items
descMidiModes       fcb       MidiSubCol+1,MidiSubTop,17,12  4 text rows into the MIDI menu, at Levels' column
                    fcc       /-icevnx-utsa/
                    fcc       /  PLAYING MODES/
                    fcb       0
                    fcc       /bInstr changes/
                    fcb       0
                    fcc       /bClocks enable/
                    fcb       0
                    fcc       /bEvents enable/
                    fcb       0
                    fcc       /fVolumaster =/
                    fcb       0
                    fcc       /fmiN note no=/
                    fcb       0
                    fcc       /fmaX note no=/
                    fcb       0
                    fcc       /  SCORE MODES/
                    fcb       0
                    fcc       /bUse clocks/
                    fcb       0
                    fcc       /fTranspose  =/
                    fcb       0
                    fcc       |fSeconds/Min=|
                    fcb       0
                    fcc       /fAccent wght=/
                    fcb       0,0
* strSettingsKeys: unreferenced copy of the key line
strSettingsKeys     fcc       /-icevnx-utsa/
                    fcb       $0D,$00
* fmtAccentBoost: 'Accent Volume Boost [%d]: '
fmtAccentBoost      fcc       /Accent Volume Boost [%d]: /
                    fcb       $00
* fmtSecPerMin: ' Seconds per Minute [%d]: '
fmtSecPerMin        fcc       / Seconds per Minute [%d]: /
                    fcb       $00
* fmtSemiTones: ' SemiTones [%d]: '
fmtSemiTones        fcc       / SemiTones [%d]: /
                    fcb       $00
* fmtMasterVol: ' Master MIDI Volume [%d]: '
fmtMasterVol        fcc       / Master MIDI Volume [%d]: /
                    fcb       $00
* fmtMinNote: ' Min. MIDI Note No. [%d]: '
fmtMinNote          fcc       / Min. MIDI Note No. [%d]: /
                    fcb       $00
* fmtMaxNote: ' Max. MIDI Note No. [%d]: '
fmtMaxNote          fcc       / Max. MIDI Note No. [%d]: /
                    fcb       $00
* msgVolLevelsTitle: form feed + ' MIDI Volume Levels'
msgVolLevelsTitle   fcb       $0C
                    fcc       / MIDI Volume Levels/
                    fcb       $0D,$0D,$00
* msgLevelsHdr: ' # EXPR  VALUE' column header
msgLevelsHdr        fcc       / # EXPR  VALUE/
                    fcb       $0D,$00
* fmtLevelRow: ' %d  %3s  %3d' level number, dynamic name, velocity
fmtLevelRow         fcc       / %d  %3s  %3d/
                    fcb       $0D,$00
* msgEvenSpacing: ' E = Even spacing' / '  # of Level to change: '
msgEvenSpacing      fcb       $0D
                    fcc       / E = Even spacing/
                    fcb       $0D,$0D
                    fcc       /  # of Level to change: /
                    fcb       $00
* tblLevelPickKeys: picker cell -> key table '01234567 e' for the levels editor
tblLevelPickKeys    fcb       $0D
                    fcc       /01234567 e/
                    fcb       $00
* msgEnterAll07: '(ENTER for all 0 to 7)'
msgEnterAll07       fcb       $0D
                    fcc       /(ENTER for all 0 to 7)/
                    fcb       $0D,$00
* msgFromLevel: ' From Level # '
msgFromLevel        fcc       / From Level # /
                    fcb       $00
* msgToLevel: '   To Level #'
msgToLevel          fcb       $0D
                    fcc       /   To Level #/
                    fcb       $00
* fmtNewValuePrompt: sprintf template '#%d's New Value [%%d]: ' producing the PromptNumber format
fmtNewValuePrompt   fcb       $0D
                    fcc       /#%d's New Value [%%d]: /
                    fcb       $00
* ReadPartKey: reads one key ([pcharmaus] into a 1-byte local) and returns its part number via PartCharToNum (0 for ENTER)
ReadPartKey         pshs      u
                    leas      -1,s
                    leax      ,s
                    pshs      x
                    jsr       [>UmeData_pcharmaus]
                    leas      2,s
                    sex
                    pshs      a,b
                    lbsr      PartCharToNum
                    leas      2,s
                    leas      1,s
                    puls      u,pc
* WaitButtonUp: polls the mouse via [pmouce] (two result words on the stack) and sleeps 4 ticks between polls until it returns zero (button released)
WaitButtonUp        pshs      a,b,x,u
                    bra       PollButton
* WaitButtonSleep: still-down arm of WaitButtonUp: PollButton's bne lands here to sleep 4 ticks then poll again
WaitButtonSleep     ldd       #$0004
                    pshs      a,b
                    lbsr      SleepTicks
                    leas      2,s
* PollButton: poll loop head of WaitButtonUp
PollButton          leax      ,s
                    pshs      x
                    leax      4,s
                    pshs      x
                    jsr       [>UmeData_pmouce]
                    leas      4,s
                    bne       WaitButtonSleep
                    leas      4,s
                    puls      u,pc
* ChoicePrompt: (form, keybuf): ShowForm(form), WaitButtonUp, prints '  Choice: ', ShowCursor(1), and if keybuf != 0 reads a key into it
ChoicePrompt        pshs      u
                    ldd       4,s
                    pshs      a,b
                    lbsr      ShowForm
                    leas      2,s
                    bsr       WaitButtonUp
                    leax      >msgChoice,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    ldd       #$0001
                    pshs      a,b
                    lbsr      ShowCursor
                    leas      2,s
                    ldd       6,s
                    beq       a14@
                    ldd       6,s
                    pshs      a,b
                    jsr       [>UmeData_pcharmaus]
                    leas      2,s
a14@                puls      u,pc
* PromptNumber: (fmt, current): printf(fmt, current), reads a line into an 80-byte local; empty line returns current, else AsciiToInt of the text
PromptNumber        pshs      u
                    leas      <-$51,s
                    ldd       <$57,s
                    pshs      a,b
                    ldd       <$57,s
                    pshs      a,b
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    leax      ,s
                    pshs      x
                    jsr       [>UmeData_pgets]
                    leas      2,s
                    ldb       ,s
                    bne       a15@
                    ldd       <$57,s
                    bra       b15@
a15@                leax      ,s
                    pshs      x
                    lbsr      AsciiToInt
                    leas      2,s
b15@                leas      <$51,s
                    puls      u,pc
* ClampInt: (v, lo, hi): returns lo if v < lo, hi if v > hi, else v
ClampInt            pshs      u
                    ldd       4,s
                    cmpd      6,s
                    lblt      ReturnArg2
                    ldd       4,s
                    cmpd      8,s
                    ble       a16@
                    ldd       8,s
                    puls      u,pc
a16@                ldd       4,s
                    puls      u,pc
* PartCharToNum: '0'..'9' -> 0..9, 'a'..'g' -> 10..16, anything else -> 0
PartCharToNum       pshs      u
                    ldb       5,s
                    sex
                    subd      #$0030
                    stb       5,s
                    blt       PartLetterCase
                    ldb       5,s
                    cmpb      #$09
                    bgt       PartLetterCase
                    ldb       5,s
                    sex
                    puls      u,pc
* PartLetterCase: letter branch of PartCharToNum: (c-'a') in 0..6 gives 10..16
PartLetterCase      ldb       5,s
                    sex
                    subd      #$0031
                    stb       5,s
                    blt       a17@
                    ldb       5,s
                    cmpb      #$06
                    bgt       a17@
                    ldb       5,s
                    sex
                    addd      #$000A
                    puls      u,pc
a17@                clra
                    clrb
                    puls      u,pc
* PartNumToChar: n & $1F -> '0'+n for n <= 9, else 'A'+n-10
PartNumToChar       pshs      u
                    ldd       4,s
                    clra
                    andb      #$1F
                    std       4,s
                    cmpd      #$0009
                    bgt       a18@
                    ldd       4,s
                    addd      #$0030
                    puls      u,pc
a18@                ldd       4,s
                    addd      #$0037
                    puls      u,pc
* FmtPatchNo(code, buf): 4 chars into buf: bit 7 set = '.' and sprintf '%3d' of (code&$7F)+1, else [./o][0/1] from bit 6, then the row (bits 5-3) and column (bits 2-0) as 1-8; returns buf
FmtPatchNo          pshs      u
                    clra
                    clrb
                    ldx       6,s
                    stb       4,x
                    ldd       #$002E
                    stb       [<$06,s]
                    ldd       4,s
                    clra
                    andb      #$80
                    beq       a19@
                    ldd       4,s
                    clra
                    andb      #$7F
                    addd      #$0001
                    pshs      a,b
                    leax      >fmtInt3,pcr
                    pshs      x
                    ldd       10,s
                    addd      #$0001
                    pshs      a,b
                    jsr       [>UmeData_psprintf]
                    leas      6,s
                    bra       ReturnArg2
a19@                ldd       4,s
                    clra
                    andb      #$40
                    beq       b19@
                    ldd       #$006F
                    stb       [<$06,s]
b19@                ldd       4,s
                    clra
                    andb      #$07
                    addd      #$0031
                    ldx       6,s
                    stb       3,x
                    ldd       4,s
                    asra
                    rorb
                    asra
                    rorb
                    asra
                    rorb
                    clra
                    andb      #$07
                    addd      #$0031
                    ldx       6,s
                    stb       2,x
                    ldd       4,s
                    clra
                    andb      #$40
                    beq       c19@
                    ldd       #$0031
                    bra       d19@
c19@                ldd       #$0030
d19@                ldx       6,s
                    stb       1,x
* ReturnArg2: shared return tail (ldd 6,s; puls u,pc) used by FmtPatchNo (returns buf) and ClampInt (returns lo)
ReturnArg2          ldd       6,s
                    puls      u,pc
* ShowInstrList: command 's' and part of the instruments screen: fills a 64-byte mark array with blanks, walks the score records back from nevents-1 marking '>' on instruments named by instrument-change records (byte0 = 0, byte5 = $17, byte7 & $3F), then prints 12 rows of two instruments from the list top $03C6
ShowInstrList       pshs      u
                    leas      <-$50,s
                    ldd       #$0040
                    std       2,s
                    bra       b20@
a20@                ldd       2,s
                    leax      <$10,s
                    leax      d,x
                    ldd       #$0020
                    stb       ,x
b20@                ldd       2,s
                    addd      #$FFFF
                    std       2,s
                    bge       a20@
                    ldd       <UmeData_nevents
                    addd      #$FFFF
                    pshs      a,b
                    lbsr      SeekRecord
                    leas      2,s
                    bra       ScanRecordsNext
* MarkUsedInstr: record loop body: if record byte0 == 0 and byte5 == $17 then mark[byte7 & $3F] = '>'
MarkUsedInstr       ldb       ,u
                    bne       a21@
                    ldb       5,u
                    cmpb      #$17
                    bne       a21@
                    ldb       7,u
                    clra
                    andb      #$3F
                    leax      <$10,s
                    leax      d,x
                    ldd       #$003E
                    stb       ,x
a21@                lbsr      PrevRecord
* ScanRecordsNext: record loop test: continue while curind > 0, then set up the row loop
ScanRecordsNext     tfr       d,u
                    ldd       <UmeData_curind
                    bgt       MarkUsedInstr
                    clra
                    clrb
                    std       4,s
                    ldd       >UmeData_reserved_03C6
                    std       2,s
                    addd      #$0001
                    lbra      InstrListNext
* InstrListRow: row body: printf mark, 0-based number, FmtPatchNo text and name for instruments top and top+1 (two consecutive per row)
InstrListRow        ldd       ,s
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
                    pshs      x
                    leax      8,s
                    pshs      x
                    ldd       4,s
                    aslb
                    rola
                    ldx       #$075F
                    leax      d,x
                    ldd       ,x
                    pshs      a,b
                    lbsr      FmtPatchNo
                    leas      4,s
                    pshs      a,b
                    ldd       4,s
                    pshs      a,b
                    ldd       6,s
                    leax      <$16,s
                    leax      d,x
                    ldb       ,x
                    sex
                    pshs      a,b
                    ldd       10,s
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
                    pshs      x
                    leax      <$15,s
                    pshs      x
                    ldd       14,s
                    aslb
                    rola
                    ldx       #$075F
                    leax      d,x
                    ldd       ,x
                    pshs      a,b
                    lbsr      FmtPatchNo
                    leas      4,s
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    ldd       <$10,s
                    leax      <$1E,s
                    leax      d,x
                    ldb       ,x
                    sex
                    pshs      a,b
                    leax      >fmtInstrListRow,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      <$12,s
                    ldd       4,s
                    addd      #$0001
                    std       4,s
                    subd      #$0001
                    ldd       2,s
                    addd      #$0002
                    std       2,s
                    ldd       ,s
                    addd      #$0002
* InstrListNext: row loop test: 12 rows
InstrListNext       std       ,s
                    ldd       4,s
                    cmpd      #$000C
                    lblt      InstrListRow
                    leas      <$50,s
                    puls      u,pc
* InstrMenu: INSTRUMENTS editor (command 'i'): saves curcurse, selects window 1, loops on the list; ,s = pending 2-step command key, <$10,s = source instrument, <$12,s = form drawn flag, <$29,s = input buffer
InstrMenu           pshs      u
                    leas      <-$7A,s
                    ldd       <UmeData_curcurse
                    std       4,s
                    ldd       #$0001
                    pshs      a,b
                    lbsr      SelectWindow
                    leas      2,s
                    clra
                    clrb
                    stb       <$12,s
* InstrMenuLoop: loop head: clamps the list top $03C6 to 0..40 and even, draws form 6 once, then redraws the screen
InstrMenuLoop       ldd       >UmeData_reserved_03C6
                    bge       a22@
                    clra
                    clrb
                    std       >UmeData_reserved_03C6
a22@                ldd       >UmeData_reserved_03C6
                    cmpd      #$0028
                    ble       b22@
                    ldd       #$0028
                    std       >UmeData_reserved_03C6
b22@                ldd       >UmeData_reserved_03C6
                    clra
                    andb      #$FE
                    std       >UmeData_reserved_03C6
                    ldb       <$12,s
                    bne       InstrMenuDraw
                    ldd       #$0006
                    pshs      a,b
                    lbsr      ShowForm
                    leas      2,s
                    ldd       #$0001
                    stb       <$12,s
* InstrMenuDraw: prints the INSTRUMENTS title, ShowInstrList, the five command lines and 'Cmd or Instr. No:'
InstrMenuDraw       leax      >msgInstrTitle,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    lbsr      ShowInstrList
                    leax      >msgPercClearLine,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    leax      >msgReadWriteLine,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    leax      >msgKopyMoveLine,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    leax      >msgSwapXoutLine,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    leax      >msgBackFwdLine,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    leax      >msgCmdOrInstr,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    leau      <$29,s
* InstrPickLoop: input loop: picker (MenuBarC3+MenuDropX, MenuDropY origin, 2 cols x 17 rows); 0 = ENTER, 1..24 = instrument top+n-1 as text, 25.. = command char from tblInstrPickKeys, negative = typed key; collects up to two digits
InstrPickLoop       clra
                    clrb
                    stb       1,u
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0011
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0002
                    pshs      a,b
                    ldd       #$0019
                    pshs      a,b
                    ldd       #MenuDropY          the Inst menu's top, under the bar
                    pshs      a,b
                    ldd       #MenuBarC3+MenuDropX
                    pshs      a,b
                    jsr       [>UmeData_ptextmen]
                    leas      14,s
                    std       6,s
                    bge       a23@
                    ldd       6,s
                    nega
                    negb
                    sbca      #$00
                    bra       InstrPickStoreKey
a23@                ldd       6,s
                    bne       InstrPickNumber
                    ldd       #$000D
                    bra       InstrPickStoreKey
* InstrPickNumber: cell 1..24: sprintf '%d\r' of top+cell-1 into the input buffer and echo it
InstrPickNumber     ldd       6,s
                    cmpd      #$0001
                    blt       InstrPickCmdChar
                    ldd       6,s
                    cmpd      #$0018
                    bgt       InstrPickCmdChar
                    ldd       6,s
                    addd      >UmeData_reserved_03C6
                    addd      #$FFFF
                    std       8,s
                    pshs      a,b
                    leax      >fmtIntCR,pcr
                    pshs      x
                    leax      <$2D,s
                    pshs      x
                    jsr       [>UmeData_psprintf]
                    leas      6,s
                    leax      <$29,s
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    bra       InstrPickEchoDone
* InstrPickCmdChar: cell >= 25: key = tblInstrPickKeys[cell-25] (p c r w k m s x b f)
InstrPickCmdChar    leax      >tblInstrPickKeys,pcr
                    tfr       x,d
                    pshs      a,b
                    ldd       8,s
                    addd      #$FFE7
                    addd      ,s++
                    tfr       d,x
                    ldb       ,x
* InstrPickStoreKey: shared tail of the instrument picker: typed-key and ENTER arms bra here, cmd-char cell falls in
InstrPickStoreKey   stb       1,s
                    ldb       1,s
                    stb       ,u
                    ldb       1,s
                    sex
                    pshs      a,b
                    jsr       [>UmeData_pputchar]
                    leas      2,s
                    ldb       1,s
                    cmpb      #$30
                    blt       a24@
                    ldb       1,s
                    cmpb      #$36
                    bgt       a24@
                    leax      <$29,s
                    pshs      x
                    tfr       u,d
                    subd      ,s++
                    ble       InstrNextChar
a24@                ldb       1,s
                    cmpb      #$0D
                    beq       InstrKeyDone
                    ldd       #$000D
                    pshs      a,b
                    jsr       [>UmeData_pputchar]
* InstrPickEchoDone: shared 2-byte cleanup after the echo: InstrPickNumber bra's in, the putchar arm falls through
InstrPickEchoDone   leas      2,s
                    bra       InstrKeyDone
* InstrNextChar: advance the buffer pointer and read another digit
InstrNextChar       leau      1,u
                    lbra      InstrPickLoop
* InstrKeyDone: input finished: empty/ENTER goes back one window level, else dispatch on the first char
InstrKeyDone        ldb       <$29,s
                    stb       1,s
                    beq       InstrEmptyInput
                    ldb       1,s
                    cmpb      #$0D
                    bne       InstrKeyToCmd
* InstrEmptyInput: empty input: window $15 -> back to $10, windows $10/6 -> back to 1, window 1 -> leave the editor
InstrEmptyInput     ldd       <UmeData_curcurse
                    cmpd      #$0015
                    bne       a25@
                    ldd       #$0010
                    lbra      InstrSelWinLoop
a25@                ldd       <UmeData_curcurse
                    cmpd      #$0010
                    lbeq      InstrBackToWin1
                    ldd       <UmeData_curcurse
                    cmpd      #$0006
                    lbeq      InstrBackToWin1
                    lbra      InstrMenuExit
* InstrKeyToCmd: InstrKeyDone's bne arm: first char is not ENTER, sign-extends it to X and lbra InstrCmdDispatch
InstrKeyToCmd       ldb       1,s
                    sex
                    tfr       d,x
                    lbra      InstrCmdDispatch
* ListUp12: key $0C: list top -= 12
ListUp12            ldd       >UmeData_reserved_03C6
                    subd      #$000C
                    bra       SetListTop
* ListDown12: key $0A: list top += 12
ListDown12          ldd       >UmeData_reserved_03C6
                    addd      #$000C
                    bra       SetListTop
* ListLeft2: key $08: list top -= 2
ListLeft2           ldd       >UmeData_reserved_03C6
                    subd      #$0002
                    bra       SetListTop
* ListRight2: key $09: list top += 2
ListRight2          ldd       >UmeData_reserved_03C6
                    addd      #$0002
                    bra       SetListTop
* ListBack24: 'b' or '<' (Back in list): list top -= 24
ListBack24          ldd       >UmeData_reserved_03C6
                    subd      #$0018
                    bra       SetListTop
* ListFwd24: 'f' or '>' (Forward list): list top += 24
ListFwd24           ldd       >UmeData_reserved_03C6
                    addd      #$0018
* SetListTop: stores the new list top in $03C6 and loops (clamped by InstrMenuLoop)
SetListTop          std       >UmeData_reserved_03C6
                    lbra      InstrMenuLoop
* InstrKopyMoveSwap: 'k' / 's' / 'm': selects window $10 (source number entry) and remembers the command key in ,s
InstrKopyMoveSwap   ldd       #$0010
                    pshs      a,b
                    lbsr      SelectWindow
                    leas      2,s
                    ldb       1,s
                    bra       InstrSetPendKey
* InstrXoutCmd: 'x': selects window 6 and remembers 'x'; the next number entered is erased
InstrXoutCmd        ldd       #$0006
                    pshs      a,b
                    lbsr      SelectWindow
                    leas      2,s
                    ldd       #$0078
* InstrSetPendKey: shared tail of InstrKopyMoveSwap/InstrXoutCmd: stores the pending command key in ,s and loops
InstrSetPendKey     stb       ,s
                    lbra      InstrMenuLoop
* InstrClearAll: 'c': asks Clear All Instruments? and calls ClearAllInstr
InstrClearAll       lbsr      FlushDisplay
                    clra
                    clrb
                    stb       <$12,s
                    leax      >msgClearAllInstr,pcr
                    pshs      x
                    jsr       [>UmeData_pyesno]
                    std       ,s++
                    lbeq      InstrBackToWin1
                    lbsr      ClearAllInstr
                    lbra      InstrBackToWin1
* InstrReadWrite: 'r' / 'w': CallOverlay('D','d', buf, key=='w', 'i', 0, 0) = s9d disk read/write of the instrument file
InstrReadWrite      lbsr      FlushDisplay
                    clra
                    clrb
                    stb       <$12,s
                    ldd       #$0001
                    pshs      a,b
                    lbsr      SelectWindow
                    leas      2,s
                    clra
                    clrb
                    stb       <$29,s
                    clra
                    clrb
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0069
                    pshs      a,b
                    ldb       7,s
                    cmpb      #$77
                    bne       a26@
                    ldd       #$0001
                    bra       b26@
a26@                clra
                    clrb
b26@                pshs      a,b
                    leax      <$31,s
                    pshs      x
                    ldd       #$0064
                    pshs      a,b
                    ldd       #$0044
                    pshs      a,b
                    jsr       [>UmeData_psoowee]
                    leas      14,s
                    lbra      InstrMenuLoop
* InstrPercussion: 'p': flush, select window 1 and run PercEditor
InstrPercussion     lbsr      FlushDisplay
                    clra
                    clrb
                    stb       <$12,s
                    ldd       #$0001
                    pshs      a,b
                    lbsr      SelectWindow
                    leas      2,s
                    lbsr      PercEditor
                    lbra      InstrMenuLoop
* InstrCmdDispatch: compare chain: $0C $0A $08 $09 b < f > k s m x c r w p, digits -> InstrNumberEntered, else beep
InstrCmdDispatch    cmpx      #$000C
                    lbeq      ListUp12
                    cmpx      #$000A
                    lbeq      ListDown12
                    cmpx      #$0008
                    lbeq      ListLeft2
                    cmpx      #$0009
                    lbeq      ListRight2
                    cmpx      #$0062
                    lbeq      ListBack24
                    cmpx      #$003C
                    lbeq      ListBack24
                    cmpx      #$0066
                    lbeq      ListFwd24
                    cmpx      #$003E
                    lbeq      ListFwd24
                    cmpx      #$006B
                    lbeq      InstrKopyMoveSwap
                    cmpx      #$0073
                    lbeq      InstrKopyMoveSwap
                    cmpx      #$006D
                    lbeq      InstrKopyMoveSwap
                    cmpx      #$0078
                    lbeq      InstrXoutCmd
                    cmpx      #$0063
                    lbeq      InstrClearAll
                    cmpx      #$0072
                    lbeq      InstrReadWrite
                    cmpx      #$0077
                    lbeq      InstrReadWrite
                    cmpx      #$0070
                    lbeq      InstrPercussion
                    ldb       1,s
                    cmpb      #$30
                    blt       InstrBadKey
                    ldb       1,s
                    cmpb      #$39
                    ble       InstrNumberEntered
* InstrBadKey: ErrBeep and loop
InstrBadKey         lbsr      ErrBeep
                    lbra      InstrMenuLoop
* InstrNumberEntered: n = AsciiToInt(buffer) & $3F; in window 6 (x-out) patch[n] = $0080 and name[n] = '' then back to window 1 unless sticky; other windows see InstrSrcNumber / InstrDestNumber / InstrEditPatch
InstrNumberEntered  leax      <$29,s
                    pshs      x
                    lbsr      AsciiToInt
                    leas      2,s
                    clra
                    andb      #$3F
                    std       8,s
                    ldd       <UmeData_curcurse
                    cmpd      #$0006
                    bne       InstrSrcNumber
                    ldd       8,s
                    aslb
                    rola
                    ldx       #$075F
                    leax      d,x
                    ldd       #$0080
                    std       ,x
                    ldd       8,s
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
                    clra
                    clrb
                    stb       ,x
                    ldb       <UmeData_sticky
                    bne       InstrMenuAgain
* InstrBackToWin1: select window 1 and loop
InstrBackToWin1     ldd       #$0001
* InstrSelWinLoop: SelectWindow(D) then loop
InstrSelWinLoop     pshs      a,b
                    lbsr      SelectWindow
                    leas      2,s
* InstrMenuAgain: lbra InstrMenuLoop; the x-out path bne's here when sticky is set, InstrSelWinLoop falls through
InstrMenuAgain      lbra      InstrMenuLoop
* InstrSrcNumber: window $10: remember n as the source instrument and select window $15 for the destination
InstrSrcNumber      ldd       <UmeData_curcurse
                    cmpd      #$0010
                    bne       InstrDestNumber
                    ldd       #$0015
                    pshs      a,b
                    lbsr      SelectWindow
                    leas      2,s
                    ldd       8,s
                    std       <$10,s
                    lbra      InstrMenuLoop
* InstrDestNumber: window $15: destination entered; selects window 1 (or $10 when sticky) and performs the pending kopy/move/swap
InstrDestNumber     ldd       <UmeData_curcurse
                    cmpd      #$0015
                    lbne      InstrEditPatch
                    ldb       <UmeData_sticky
                    beq       a27@
                    ldd       #$0010
                    bra       InstrDoKopy
a27@                ldd       #$0001
* InstrDoKopy: saves dest name/patch, copies name[src] (16 bytes, $07EB) and patch[src] ($075F word) to dest; 's' then writes the saved values back to src (swap), 'm' clears src (move)
InstrDoKopy         pshs      a,b
                    lbsr      SelectWindow
                    leas      2,s
                    ldd       8,s
                    std       14,s
                    ldd       #$0010
                    pshs      a,b
                    ldd       <$10,s
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
                    pshs      x
                    leax      <$17,s
                    pshs      x
                    lbsr      StrNCopy
                    leas      6,s
                    ldd       14,s
                    aslb
                    rola
                    ldx       #$075F
                    leax      d,x
                    ldd       ,x
                    std       12,s
                    ldd       #$0010
                    pshs      a,b
                    ldd       <$12,s
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
                    pshs      x
                    ldd       <$12,s
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
                    pshs      x
                    lbsr      StrNCopy
                    leas      6,s
                    ldd       14,s
                    aslb
                    rola
                    ldx       #$075F
                    leax      d,x
                    pshs      x
                    ldd       <$12,s
                    aslb
                    rola
                    ldx       #$075F
                    leax      d,x
                    ldd       ,x
                    std       [,s++]
                    ldb       ,s
                    cmpb      #$73
                    bne       InstrMoveTail
                    ldd       #$0010
                    pshs      a,b
                    leax      <$15,s
                    pshs      x
                    ldd       <$14,s
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
                    pshs      x
                    lbsr      StrNCopy
                    leas      6,s
                    ldd       <$10,s
                    aslb
                    rola
                    ldx       #$075F
                    leax      d,x
                    ldd       12,s
                    std       ,x
* InstrMoveTail: 'm': patch[src] = $0080 and name[src][0] = 0 after the copy
InstrMoveTail       ldb       ,s
                    cmpb      #$6D
                    bne       a28@
                    ldd       <$10,s
                    aslb
                    rola
                    ldx       #$075F
                    leax      d,x
                    ldd       #$0080
                    std       ,x
                    ldd       <$10,s
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
                    clra
                    clrb
                    stb       ,x
a28@                lbra      InstrMenuLoop
* InstrEditPatch: window 1: prompts New Patch No. [%4s] with FmtPatchNo(patch[n]); a non-empty reply is stored through ParsePatchNo
InstrEditPatch      leax      <$23,s
                    pshs      x
                    ldd       10,s
                    aslb
                    rola
                    ldx       #$075F
                    leax      d,x
                    ldd       ,x
                    pshs      a,b
                    lbsr      FmtPatchNo
                    leas      4,s
                    pshs      a,b
                    leax      >fmtNewPatchNo,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    leax      <$29,s
                    pshs      x
                    jsr       [>UmeData_pgets]
                    leas      2,s
                    ldb       <$29,s
                    beq       InstrEditName
                    ldd       8,s
                    aslb
                    rola
                    ldx       #$075F
                    leax      d,x
                    pshs      x
                    leax      <$2B,s
                    pshs      x
                    lbsr      ParsePatchNo
                    leas      2,s
                    std       [,s++]
* InstrEditName: prompts New Name [%-15s]; a space clears the name, other text is StrNCopy'd (15) into name[n]
InstrEditName       ldd       8,s
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
                    stx       2,s
                    pshs      x
                    leax      >fmtNewName,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    leax      <$29,s
                    pshs      x
                    jsr       [>UmeData_pgets]
                    leas      2,s
                    clra
                    clrb
                    stb       <$38,s
                    ldb       <$29,s
                    beq       b29@
                    ldb       <$29,s
                    cmpb      #$20
                    bne       a29@
                    clra
                    clrb
                    stb       <$29,s
a29@                ldd       #$000F
                    pshs      a,b
                    leax      <$2B,s
                    pshs      x
                    ldd       6,s
                    pshs      a,b
                    lbsr      StrNCopy
                    leas      6,s
b29@                lbra      InstrMenuLoop
* InstrMenuExit: re-selects the saved window, flushes if the form was drawn, and returns
InstrMenuExit       ldd       4,s
                    pshs      a,b
                    lbsr      SelectWindow
                    leas      2,s
                    ldb       <$12,s
                    beq       a30@
                    lbsr      FlushDisplay
a30@                leas      <$7A,s
                    puls      u,pc
* PercEditor: percussion editor: DrawBox($0C, $B7, $18, $18, 1, WinStylePaper3D) then edits the 17 percussion note numbers at $0CA3 (slots 16..0, names from the pointer table $0184) and the synth name at $0CB4
PercEditor          pshs      u
                    leas      <-$53,s
                    ldd       #WinStylePaper3D    paper 3D box
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0018
                    pshs      a,b
                    ldd       #$0018
                    pshs      a,b
                    ldd       #$00B7
                    pshs      a,b
                    ldd       #$000C
                    pshs      a,b
                    lbsr      DrawBox
                    leas      12,s
* PercRedraw: loop head: prints ' Slot  Note#   Sound' and rows 16 down to 0
PercRedraw          leax      >msgPercHdr,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    ldd       #$0010
                    lbra      PercRowNext
* PercRowLoop: row body: chooses the staff prefix (||----- / ||     for slots 4..12, '    -- ' / blanks outside) by slot parity
PercRowLoop         ldd       ,s
                    cmpd      #$000C
                    bgt       b31@
                    ldd       ,s
                    cmpd      #$0004
                    blt       b31@
                    ldd       ,s
                    clra
                    andb      #$01
                    beq       a31@
                    leax      >strStaffSpace,pcr
                    bra       PercPrintRow
a31@                leax      >strStaffLine,pcr
                    bra       PercPrintRow
b31@                ldd       ,s
                    clra
                    andb      #$01
                    beq       c31@
                    leax      >strBlank7,pcr
                    bra       PercPrintRow
c31@                leax      >strLedgerLine,pcr
* PercPrintRow: prints the prefix then '%3d %s' with $0CA3[slot] and the drum name
PercPrintRow        tfr       x,d
                    pshs      a,b
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    ldd       ,s
                    aslb
                    rola
                    ldx       #$0184
                    leax      d,x
                    ldd       ,x
                    pshs      a,b
                    ldd       2,s
                    ldx       #$0CA3
                    leax      d,x
                    ldb       ,x
                    sex
                    pshs      a,b
                    leax      >fmtPercRow,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      6,s
                    ldd       ,s
                    addd      #$FFFF
* PercRowNext: row loop test; afterwards prints the Read/Write/CLEAR ALL lines and the synth name, runs the picker (21 rows) and dispatches: 0/ENTER exit, c/20 clear, r/18 read, w/19 write, 21 synth name, 1..17 edit
PercRowNext         std       ,s
                    ldd       ,s
                    lbge      PercRowLoop
                    leax      >msgPercReadWrite,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    ldx       #$0CB4
                    pshs      x
                    leax      >fmtPercClearAll,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    clra
                    clrb
                    stb       2,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0015
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0017
                    pshs      a,b
                    ldd       #$00B7
                    pshs      a,b
                    ldd       #$000C
                    pshs      a,b
                    jsr       [>UmeData_ptextmen]
                    leas      14,s
                    std       ,s
                    lbeq      PercEditorExit
                    ldd       ,s
                    cmpd      #$FFF3
                    lbeq      PercEditorExit
                    ldd       ,s
                    cmpd      #$0014
                    beq       PercClearNotes
                    ldd       ,s
                    cmpd      #$FF9D
                    bne       PercCheckRead
* PercClearNotes: asks 'Clear all Note Numers.  Sure?' then zeroes $0CA3[16..0]
PercClearNotes      leax      >msgClearNotesSure,pcr
                    pshs      x
                    jsr       [>UmeData_pyesno]
                    std       ,s++
                    beq       PercClearDone
                    ldd       #$0010
                    bra       PercClearNext
* PercClearLoop: loop body: $0CA3[i] = 0
PercClearLoop       ldd       ,s
                    ldx       #$0CA3
                    leax      d,x
                    clra
                    clrb
                    stb       ,x
                    ldd       ,s
                    addd      #$FFFF
* PercClearNext: counter store/test of PercClearNotes: entered by bra with 16, bge loops back to PercClearLoop
PercClearNext       std       ,s
                    ldd       ,s
                    bge       PercClearLoop
* PercClearDone: lbra PercRedraw; beq lands here when the Clear all Note Numers confirm is declined, loop falls in
PercClearDone       lbra      PercRedraw
* PercCheckRead: tests for cell 18 or key 'r'
PercCheckRead       ldd       ,s
                    cmpd      #$0012
                    beq       PercReadFile
                    ldd       ,s
                    cmpd      #$FF8E
                    bne       PercCheckWrite
* PercReadFile: CallOverlay('D','d', buf, 0, 'p', 0, 0): read the percussion file through s9d
PercReadFile        clra
                    clrb
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0070
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    leax      10,s
                    pshs      x
                    ldd       #$0064
                    pshs      a,b
                    ldd       #$0044
                    pshs      a,b
                    jsr       [>UmeData_psoowee]
                    leas      14,s
                    lbra      PercRedraw
* PercCheckWrite: tests for cell 19 or key 'w'
PercCheckWrite      ldd       ,s
                    cmpd      #$0013
                    beq       PercWriteFile
                    ldd       ,s
                    cmpd      #$FF89
                    bne       PercSynthName
* PercWriteFile: CallOverlay('D','d', buf, 1, 'p', 0, 0): write the percussion file through s9d
PercWriteFile       clra
                    clrb
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0070
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    leax      10,s
                    pshs      x
                    ldd       #$0064
                    pshs      a,b
                    ldd       #$0044
                    pshs      a,b
                    jsr       [>UmeData_psoowee]
                    leas      14,s
                    lbra      PercRedraw
* PercSynthName: cell 21: prints 'Type new Synth name:', reads a line and StrNCopy's it (24) to $0CB4 with a forced NUL at $0CCB
PercSynthName       ldd       ,s
                    cmpd      #$0015
                    bne       PercEditSlot
                    leax      >msgNewSynthName,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    leax      2,s
                    pshs      x
                    jsr       [>UmeData_pgets]
                    leas      2,s
                    ldb       2,s
                    beq       a32@
                    ldd       #$0018
                    pshs      a,b
                    leax      4,s
                    pshs      x
                    ldx       #$0CB4
                    pshs      x
                    lbsr      StrNCopy
                    leas      6,s
                    clra
                    clrb
                    stb       >UmeData_reserved_0CCB
a32@                lbra      PercRedraw
* PercEditSlot: cell 1..17: slot = 17-cell, prints 'Sound: %s' and PromptNumber 'MIDI Note # [%d]: ', ClampInt 1..127, stores into $0CA3[slot]
PercEditSlot        ldd       ,s
                    lble      PercRedraw
                    ldd       #$0011
                    subd      ,s
                    std       ,s
                    aslb
                    rola
                    ldx       #$0184
                    leax      d,x
                    ldd       ,x
                    pshs      a,b
                    leax      >fmtSoundName,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    ldd       ,s
                    ldx       #$0CA3
                    leax      d,x
                    pshs      x
                    ldd       #$007F
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       6,s
                    ldx       #$0CA3
                    leax      d,x
                    ldb       ,x
                    sex
                    pshs      a,b
                    leax      >fmtMidiNoteNo,pcr
                    pshs      x
                    lbsr      PromptNumber
                    leas      4,s
                    pshs      a,b
                    lbsr      ClampInt
                    leas      6,s
                    stb       [,s++]
                    lbra      PercRedraw
* PercEditorExit: FlushDisplay; leas $53,s; puls u,pc
PercEditorExit      lbsr      FlushDisplay
                    leas      <$53,s
                    puls      u,pc
* ParsePatchNo: inverse of FmtPatchNo: text starting with '1'..'9' gives (atoi-1)&$7F|$80; otherwise skips the prefix char and accumulates digits base 8 ([bank][row][col]) minus 9, & $7F
ParsePatchNo        pshs      u
                    leas      -3,s
                    clra
                    clrb
                    std       1,s
                    ldb       [<$07,s]
                    stb       ,s
                    cmpb      #$31
                    blt       a33@
                    ldb       ,s
                    cmpb      #$39
                    bgt       a33@
                    ldd       7,s
                    pshs      a,b
                    lbsr      AsciiToInt
                    leas      2,s
                    addd      #$FFFF
                    clra
                    andb      #$7F
                    orb       #$80
                    bra       ParsePatchRet
a33@                ldd       7,s
                    addd      #$0001
                    std       7,s
                    bra       ParsePatchLoop
* ParsePatchDigit: digit step of ParsePatchLoop's bne: acc = acc*8 + char - $30 in the base-8 patch-number parse
ParsePatchDigit     ldd       1,s
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    pshs      a,b
                    ldb       2,s
                    sex
                    addd      ,s++
                    addd      #$FFD0
                    std       1,s
* ParsePatchLoop: digit loop of ParsePatchNo
ParsePatchLoop      ldx       7,s
                    leax      1,x
                    stx       7,s
                    ldb       -1,x
                    stb       ,s
                    bne       ParsePatchDigit
                    ldd       1,s
                    subd      #$0009
                    std       1,s
                    clra
                    andb      #$7F
* ParsePatchRet: epilogue of ParsePatchNo (leas 3,s; puls u,pc); the '1'-'9' atoi arm bra's here, loop falls in
ParsePatchRet       leas      3,s
                    puls      u,pc
* ClearAllInstr: for the 64 instruments: patch word at $075F = $0080 and first name byte at $07EB = 0
ClearAllInstr       pshs      a,b,u
                    ldd       #$0040
                    std       ,s
                    ldu       #$07EB
                    bra       ClearInstrNext
* ClearInstrLoop: loop body of ClearAllInstr
ClearInstrLoop      ldd       ,s
                    aslb
                    rola
                    ldx       #$075F
                    leax      d,x
                    ldd       #$0080
                    std       ,x
                    clra
                    clrb
                    stb       ,u
                    leau      <$10,u
* ClearInstrNext: decrement/test of ClearAllInstr: entered by bra with 64, bge loops back to ClearInstrLoop
ClearInstrNext      ldd       ,s
                    addd      #$FFFF
                    std       ,s
                    bge       ClearInstrLoop
                    leas      2,s
                    puls      u,pc
* ShowForm(n): emits display command $C4 n CR through the <$18 '%c%c\r' format; called with form numbers 5, 6 and 8 before a menu screen
ShowForm            pshs      u
                    ldd       4,s
                    pshs      a,b
                    ldd       #$00C4
                    lbra      EmitCmdArg
* FlushDisplay: emits display command $C7 CR through the <$16 '%c\r' format (the window-kill command, s9k's wkill); issued after every edit and before leaving a menu
FlushDisplay        pshs      u
                    ldd       #$00C7
                    pshs      a,b
                    ldd       <UmeData_reserved_0016
                    pshs      a,b
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    puls      u,pc
* PromptBox(big): DrawBox($0E, $6E, $32, big?5:2, 1, WinStylePaper3D) - the small box drawn before each numeric settings prompt
PromptBox           pshs      u
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
                    bsr       DrawBox
                    leas      12,s
                    puls      u,pc
* SelectWindow(n): stores n in curcurse and emits display command $9A n CR
SelectWindow        pshs      u
                    ldd       4,s
                    std       <UmeData_curcurse
                    ldd       4,s
                    pshs      a,b
                    ldd       #$009A
                    bra       EmitCmdArg
* ErrBeep: [pbeep] when the sound-enabled flag $03C3 is set
ErrBeep             pshs      u
                    ldb       >UmeData_reserved_03C3
                    beq       a35@
                    jsr       [>UmeData_pbeep]
a35@                puls      u,pc
* DrawBox(x, y, w, h, a, style): emits $C6 x y w h a style through the <$14 seven-%c format, then [pflush]: the window-create command (s9k's wcreate); frames the menu area before a picker with the same origin
DrawBox             pshs      u
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
                    jsr       [>UmeData_pflush]
                    puls      u,pc
* ShowCursor(n): emits display command $CC n CR; called with 1 before waiting for a choice
ShowCursor          pshs      u
                    ldb       5,s
                    sex
                    pshs      a,b
                    ldd       #$00CC
* EmitCmdArg: shared tail of ShowForm/SelectWindow (branch in) and ShowCursor (falls in): pushes the <$18 '%c%c\r' format, printf, leas 6, return
EmitCmdArg          pshs      a,b
                    ldd       <UmeData_reserved_0018
                    pshs      a,b
                    jsr       [>UmeData_pprintf]
                    leas      6,s
                    puls      u,pc
* msgChoice: '  Choice: '
msgChoice           fcc       /  Choice: /
                    fcb       $00
* fmtInt3: '%3d' used by FmtPatchNo for plain program numbers
fmtInt3             fcc       /%3d/
                    fcb       $00
* fmtInstrListRow: '%c%2d%4s %-15s  %c%2d%4s %-15s' mark, number, patch text, name for two instruments
fmtInstrListRow     fcc       /%c%2d%4s %-15s  %c%2d%4s %-15s/
                    fcb       $0D,$00
* msgInstrTitle: form feed + '           INSTRUMENTS'
msgInstrTitle       fcb       $0C
                    fcc       /           INSTRUMENTS/
                    fcb       $0D,$00
* msgPercClearLine: ' [Percussion...]         (Clear all)' command line
msgPercClearLine    fcc       / [Percussion...]         (Clear all)/
                    fcb       $0D,$00
* msgReadWriteLine: ' (Read file...)          (Write file...)' command line
msgReadWriteLine    fcc       / (Read file...)          (Write file...)/
                    fcb       $0D,$00
* msgKopyMoveLine: ' <Kopy>                  <Move>' command line
msgKopyMoveLine     fcc       / <Kopy>                  <Move>/
                    fcb       $0D,$00
* msgSwapXoutLine: ' <Swap>                  <X-out>' command line
msgSwapXoutLine     fcc       / <Swap>                  <X-out>/
                    fcb       $0D,$00
* msgBackFwdLine: ' (Back in list)          (Forward list)' command line
msgBackFwdLine      fcc       / (Back in list)          (Forward list)/
                    fcb       $0D,$00
* msgCmdOrInstr: '   Cmd or Instr. No: ' prompt
msgCmdOrInstr       fcb       $0D
                    fcc       /   Cmd or Instr. No: /
                    fcb       $00
* fmtIntCR: '%d' CR format used to echo a picked instrument number into the input buffer (4 bytes $25,$64,$0D,$00)
fmtIntCR            fcb       $25,$64,$0D,$00
* tblInstrPickKeys: picker cell 25..34 -> command key 'pcrwkmsxbf' (Percussion, Clear, Read, Write, Kopy, Move, Swap, X-out, Back, Forward)
tblInstrPickKeys    fcc       /pcrwkmsxbf/
                    fcb       $00
* msgClearAllInstr: ' Clear All Instruments?' yes/no text
msgClearAllInstr    fcc       / Clear All Instruments?/
                    fcb       $00
* fmtNewPatchNo: 'New Patch No. [%4s]: '
fmtNewPatchNo       fcc       /New Patch No. [%4s]: /
                    fcb       $00
* fmtNewName: 'New Name [%-15s]: '
fmtNewName          fcc       /New Name [%-15s]: /
                    fcb       $00
* msgPercHdr: form feed + ' Slot  Note#   Sound' percussion header
msgPercHdr          fcb       $0C
                    fcc       / Slot  Note#   Sound/
                    fcb       $0D,$00
* strStaffSpace: '||     ' staff prefix for odd slots 5..11
strStaffSpace       fcc       /||     /
                    fcb       $00
* strStaffLine: '||-----' staff prefix for even slots 4..12
strStaffLine        fcc       /||-----/
                    fcb       $00
* strBlank7: seven blanks: prefix for odd slots outside the staff
strBlank7           fcc       /       /
                    fcb       $00
* strLedgerLine: '    -- ' ledger-line prefix for even slots outside the staff
strLedgerLine       fcc       /    -- /
                    fcb       $00
* fmtPercRow: '%3d %s' CR: note number and drum name
fmtPercRow          fcc       /%3d %s/
                    fcb       $0D,$00
* msgPercReadWrite: '  (Read from file)' CR '  (Write to file)'
msgPercReadWrite    fcc       /  (Read from file)/
                    fcb       $0D
                    fcc       /  (Write to file)/
                    fcb       $0D,$00
* fmtPercClearAll: '     (CLEAR ALL)' CR '%s' CR: last command line plus the synth name at $0CB4
fmtPercClearAll     fcc       /     (CLEAR ALL)/
                    fcb       $0D,$25,$73,$0D,$00
* msgClearNotesSure: 'Clear all Note Numers.  Sure?' yes/no text
msgClearNotesSure   fcc       /Clear all Note Numers.  Sure?/
                    fcb       $00
* msgNewSynthName: 'Type new Synth name:'
msgNewSynthName     fcc       /Type new Synth name:/
                    fcb       $0D,$00
* fmtSoundName: 'Sound: %s'
fmtSoundName        fcc       /Sound: %s/
                    fcb       $0D,$00
* fmtMidiNoteNo: 'MIDI Note # [%d]: '
fmtMidiNoteNo       fcc       /MIDI Note # [%d]: /
                    fcb       $00
* SeekRecord(index): curind = index, page = index/928 + 1, loaded via [ppswap] if it is not curpage (returns 0 on failure); returns curevp = database + 8*(index mod 928)
SeekRecord          pshs      u
                    ldu       4,s
                    leas      -2,s
                    stu       <UmeData_curind
                    ldd       #$0001
                    bra       b36@
a36@                ldd       ,s
                    addd      #$0001
b36@                std       ,s
                    leau      >-$03A0,u
                    stu       -2,s
                    bge       a36@
                    leau      >$03A0,u
                    ldd       ,s
                    cmpd      <UmeData_curpage
                    beq       RecordPtr
                    ldd       ,s
                    pshs      a,b
                    jsr       [>UmeData_ppswap]
                    leas      2,s
                    bne       RecordPtr
                    clra
                    clrb
                    bra       SeekRecordRet
* RecordPtr: curevp = database + 8 * remainder
RecordPtr           tfr       u,d
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    addd      <UmeData_database
                    std       <UmeData_curevp
* SeekRecordRet: epilogue of SeekRecord; the map-block failure path bra's here with D=0, RecordPtr falls through
SeekRecordRet       leas      2,s
                    puls      u,pc
                    fcb       $34,$40,$DC,$2B,$C3,$00,$01,$DD
                    fcb       $2B,$10,$93
                    fcs       /),E\/
                    fcb       $23,$C3,$00,$08,$DD,$23,$10,$93
                    fcs       /'#9\/
                    fcb       $2F,$C3,$00,$01,$34,$06,$AD,$9F
                    fcb       $03,$99,$32,$62,$DC
                    fcc       /% &/
* PrevRecord: steps curind/curevp back one 8-byte record; below database loads page curpage-1 via [ppswap] and continues from curptop; returns curevp
PrevRecord          pshs      u
                    ldd       <UmeData_curind
                    addd      #$FFFF
                    std       <UmeData_curind
                    blt       a37@
                    ldd       <UmeData_curevp
                    addd      #$FFF8
                    std       <UmeData_curevp
                    cmpd      <UmeData_database
                    bhs       a37@
                    ldd       <UmeData_curpage
                    addd      #$FFFF
                    pshs      a,b
                    jsr       [>UmeData_ppswap]
                    leas      2,s
                    ldd       <UmeData_curptop
                    std       <UmeData_curevp
a37@                ldd       <UmeData_curevp
                    puls      u,pc
* StrNCopy: strncpy(dest, src, n): copies up to n bytes, zero-pads the rest, returns dest
StrNCopy            pshs      y,u
                    ldu       8,s
                    ldx       6,s
                    ldy       10,s
                    beq       StrNCopyRet
* StrNCopyLoop: copy loop of StrNCopy
StrNCopyLoop        ldb       ,u+
                    stb       ,x+
                    leay      -1,y
                    beq       StrNCopyRet
                    tstb
                    bne       StrNCopyLoop
* StrNPadLoop: zero-pad loop of StrNCopy
StrNPadLoop         clr       ,x+
                    leay      -1,y
                    bne       StrNPadLoop
* StrNCopyRet: epilogue of StrNCopy: both beq's (n=0 and n exhausted) land here, returns dest from 6,s
StrNCopyRet         ldd       6,s
                    puls      y,u,pc
* AsciiToInt: atoi: skips blanks and tabs, accepts an optional + or -, accumulates decimal digits, negates on '-'
AsciiToInt          pshs      u
                    ldu       4,s
                    clra
                    clrb
                    pshs      a,b
                    pshs      b
* SkipBlanks: leading blank/tab skip loop of AsciiToInt
SkipBlanks          ldb       ,u+
                    cmpb      #$20
                    beq       SkipBlanks
                    cmpb      #$09
                    beq       SkipBlanks
                    cmpb      #$2D
                    bne       a38@
                    stb       ,s
                    bra       AsciiIntNextChar
a38@                cmpb      #$2B
                    bne       AsciiIntDigitTest
                    bra       AsciiIntNextChar
* AccumDigit: acc = acc*10 + digit
AccumDigit          ldd       1,s
                    aslb
                    rola
                    aslb
                    rola
                    addd      1,s
                    aslb
                    rola
                    pshs      a,b
                    ldb       -1,u
                    clra
                    subb      #$30
                    addd      ,s++
                    std       1,s
* AsciiIntNextChar: fetch-next-char point of AsciiToInt: the '-' and '+' arms bra here to consume the sign byte
AsciiIntNextChar    ldb       ,u+
* AsciiIntDigitTest: digit-range test of AsciiToInt: entered with the char already in B when it was not '-' or '+'
AsciiIntDigitTest   cmpb      #$30
                    blo       a39@
                    cmpb      #$39
                    bls       AccumDigit
a39@                tst       ,s+
                    puls      a,b
                    beq       b39@
                    nega
                    negb
                    sbca      #$00
b39@                puls      u,pc
* MemCopy: memcpy(dest, src, n): one odd byte then word copies; used for the 17-byte part->channel table
MemCopy             pshs      y,u
                    ldu       6,s
                    ldy       8,s
                    ldd       10,s
                    beq       MemCopyRet
                    lsra
                    rorb
                    tfr       d,x
                    bhs       MemCopyLoop
                    lda       ,y+
                    sta       ,u+
* MemCopyLoop: word copy loop of MemCopy
MemCopyLoop         ldd       ,y++
                    std       ,u++
                    leax      -1,x
                    bne       MemCopyLoop
* MemCopyRet: epilogue of MemCopy: beq lands here when n=0, MemCopyLoop falls through; puls y,u,pc
MemCopyRet          puls      y,u,pc
* MulInt: 16x16 multiply: D times the word pushed by the caller, result X:D (fast path when both high bytes are zero); pops its argument
MulInt              tsta
                    bne       MulInt32
                    tst       2,s
                    bne       MulInt32
                    lda       3,s
                    mul
                    ldx       ,s
                    stx       2,s
                    ldx       #$0000
                    std       ,s
                    puls      a,b,pc
* MulInt32: four-partial-product path of MulInt for operands with nonzero high bytes
MulInt32            pshs      a,b
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
                    bhs       a40@
                    inc       ,s
a40@                lda       4,s
                    ldb       9,s
                    mul
                    addd      1,s
                    std       1,s
                    bhs       b40@
                    inc       ,s
b40@                lda       4,s
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
* DivZeroTrap: divisor zero: fixes the stack and sends signal $2D to the own process via SignalSelf
DivZeroTrap         puls      a,b
                    std       ,s
                    ldd       #$002D
                    lbra      SignalSelf
* DivIntRem: signed 16-bit divide of the word pushed by the caller by D: restoring shift-subtract loop, returns quotient in D and remainder in X, pops its argument
DivIntRem           subd      #$0000
                    beq       DivZeroTrap
                    pshs      a,b
                    leas      -2,s
                    clr       ,s
                    clr       1,s
                    tsta
                    bpl       a41@
                    nega
                    negb
                    sbca      #$00
                    com       1,s
                    std       2,s
a41@                ldd       6,s
                    bpl       b41@
                    nega
                    negb
                    sbca      #$00
                    com       1,s
                    std       6,s
b41@                lda       #$01
* DivNormLoop: shifts the divisor left until bit 15 is set, counting iterations
DivNormLoop         inca
                    asl       3,s
                    rol       2,s
                    bpl       DivNormLoop
                    sta       ,s
                    ldd       6,s
                    clr       6,s
                    clr       7,s
* LongDivLoop: restoring division loop of DivIntRem
LongDivLoop         subd      2,s
                    bhs       a42@
                    addd      2,s
                    andcc     #$FE
                    bra       b42@
a42@                orcc      #$01
b42@                rol       7,s
                    rol       6,s
                    lsr       2,s
                    ror       3,s
                    dec       ,s
                    bne       LongDivLoop
                    std       2,s
                    tst       1,s
                    beq       c42@
                    ldd       6,s
                    nega
                    negb
                    sbca      #$00
                    std       6,s
c42@                ldx       4,s
                    ldd       6,s
                    std       4,s
                    stx       6,s
                    ldx       2,s
                    ldd       4,s
                    leas      6,s
                    rts
* SignalSelf: stores D in errno ($034F,y), F$ID for the own process id, F$Send the signal to itself (C library arithmetic trap)
SignalSelf          std       >$034F,y
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
                    fcb       $3F,$0F,$10,$25,$00,$0D,$39
* SleepTicks: F$Sleep wrapper: X = ticks from the stack, returns remaining ticks or -1 with errno set
SleepTicks          ldx       2,s
                    os9       F$Sleep
                    lblo      ErrReturn
                    tfr       x,d
                    rts
* ErrReturn: C library error tail: errno ($034F,y) = OS-9 error code in B, returns -1
ErrReturn           clra
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
                    fcc       /s9m/
                    fcb       $00

                    emod
eom                 equ       *
                    end
