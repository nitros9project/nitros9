********************************************************************
* F5 - Flight Simulator II's airport menu (WildBits, 2026-10-21): F3 (fswc's KeyMap makes the K2's $A3 and the
* PS/2 keyboard's $B3 key $B5, FS's overlay 4; it was F4 until 2026-10-25) shows the airports, a line for each runway
* end and one for the terminal apron, in pages of MnRows as the F1 menu: up and down move the arrow (past the page's
* end to the next page), left and right turn the page, Enter puts the aircraft there and returns to flight, F3 or
* BREAK (Esc) returns as it was.
* A runway end: on the threshold (mkf5.py's RWY_IN in), heading along the runway; the apron: beside a taxiway,
* facing it. Enter makes the place the start spot (fs_wb.d vStart*), its airport's mode the current mode (Roger
* 2026-10-25; $FF in the table keeps the current one) and asks FS for its crash reset (CMDS/f2's mode load, kind 1,
* which puts every flight variable at that mode's settings; fswc's StartPos then puts the aircraft on the spot,
* level, on the ground), so the aircraft is there as if the game had started there (Roger 2026-10-22: a warp that
* kept the flight state crashed). A crash afterwards resets there too. FS loads the place's scenery itself (area 1
* chooses the region by the position).
* The table (f5_data.asm) is generated from sf.wildbits and O'Hare's source by wildbits-buildkit/tools/flightsim2/mkf5.py.

                    nam       F5
                    ttl       F5 (the airport menu)

                    ifp1
                    use       defsfile
                    use       fs_wb.d
                    endc

* Constants: the values this module's instructions use, by name (fs_wb.d holds the addresses)
ArrowCol            equ       1                   the arrow's column (StArrow, StBlank)
ArrowLen            equ       3                   StArrow's and StBlank's bytes
DScrnText           equ       0                   WbDScrnEnt's Y: 0 the text screen (else the flight screen's blocks)
FirstRow            equ       1                   a page's first entry row: the arrow's first (row 0 the title)
FootRow             equ       14                  the bottom lines' first row (StFoot, then the page number)
GotoXYBias          equ       $20                 VT_GOTOXY's column and row are sent plus $20
GotoXYLen           equ       3                   a cursor move's bytes: VT_GOTOXY, the column, the row
KeyCtrlBreak        equ       $1B                 Ctrl+BREAK ($1B, the CoCo 3 code fswc's KeyMap makes): the menu closed
KeyDown             equ       $0A                 the down arrow ($0A): the arrow a row down
KeyEnter            equ       $0D                 Enter ($0D): the entry under the arrow becomes the start spot
KeyF3               equ       $B5                 F3 ($B5 after fswc's KeyMap): the airport menu closed
KeyLeft             equ       $08                 the left arrow ($08): the page before
KeyShiftBreak       equ       $03                 Shift+BREAK ($03, the CoCo 3 code fswc's KeyMap makes): the menu closed
KeyUp               equ       $0C                 the up arrow ($0C): the arrow a row up
LoadKindCrash       equ       1                   vLoadKind 1: the crash reset (the same B makes vOvlReq 1, CMDS/f2)
MnModeKeep          equ       $FF                 an entry's mode $FF: the current mode kept (f5_data.asm)
MnPages             equ       (MnCount+MnRows-1)/MnRows the menu's pages: MnCount entries, MnRows a page, the last one short
MnTextLen           equ       16                  an entry's text: AIRPORT - RUNWAY, 16 characters (f5_data.asm)
PageDigit1          equ       '1                  the page number's character for page 0: the pages shown from 1
PageDigitLen        equ       1                   the page number's bytes: one digit
TitleCol            equ       1                   the title's column (row 0)

tylg                set       $21
atrv                set       $80
size                equ       $0000

                    mod       eom,name,tylg,atrv,start,size
name                fcs       /F5/
                    fcb       1                   edition

MnRows              equ       12                  entries a page
MnCol               equ       5                   the entries' column (the arrow at 1)
Row                 equ       $02B9               the arrow's row, 1-MnRows (the F1 menu's own row and page bytes)
Page                equ       $02BA               the page, from 0
Rows                equ       $02D0               the entries on this page (the F1 menu's last-row byte)

start               lda       >FsPath             the text screen
                    ldy       #DScrnText
                    jsr       >WbDScrnEnt
                    clr       Page
                    lda       #FirstRow
                    sta       Row
                    lbsr      Show
mn1@                jsr       >FsPollKey
                    beq       mn1@
                    cmpb      #KeyDown            down
                    bne       mn2@
                    lbsr      Down
                    bra       mn1@
mn2@                cmpb      #KeyUp              up
                    bne       mn3@
                    lbsr      Up
                    bra       mn1@
mn3@                cmpb      #KEY_TAB            right: the next page
                    bne       mn4@
                    lbsr      NextPg
                    bra       mn1@
mn4@                cmpb      #KeyLeft            left: the page before
                    bne       mn5@
                    lbsr      PrevPg
                    bra       mn1@
mn5@                cmpb      #KeyEnter           Enter: there
                    bne       mn6@
                    lbsr      Go
                    lbsr      Back
                    ldb       #LoadKindCrash      then FS's crash reset: F2 with load kind 1 (as CheckCrashMessage)
                    stb       >vLoadKind
                    stb       >vOvlReq
                    rts
mn6@                cmpb      #KeyF3              F3
                    beq       Back
                    cmpb      #KEY_RUNSTOP        BREAK (Esc on the PS/2 keyboard)
                    beq       Back
                    cmpb      #KeyShiftBreak      Shift+BREAK
                    beq       Back
                    cmpb      #KeyCtrlBreak       Ctrl+BREAK
                    bne       mn1@
* Back: the flight screen again, as f3's MenuReturnToFlight: SS.DScrn back to FS's screen, the terminal reset, no
* overlay requested, the view window cleared
Back                lda       >FsPath
                    ldy       >WbScrBlks
                    jsr       >WbDScrnEnt
                    jsr       >FsTermReset
                    clr       >vOvlReq
                    jsr       >FsClearView
                    rts

* Go: the entry under the arrow (X, Z, heading) becomes the start spot, its airport's mode the current mode
Go                  lbsr      Entry
                    ldd       16,x                X: map units, then 1/256 m
                    std       >vStartX
                    ldd       18,x
                    std       >vStartX+2
                    ldd       20,x                Z
                    std       >vStartZ
                    ldd       22,x
                    std       >vStartZ+2
                    lda       24,x                heading
                    sta       >vStartHdg
                    ldd       25,x                the rotation point (auto mode)
                    std       >vStartRot
                    lda       27,x                the airport's mode (Roger 2026-10-25): the crash reset loads it
                    cmpa      #MnModeKeep         ($FF: the current mode kept)
                    beq       go9@
                    sta       >vModeNum           the current mode
                    sta       >vUserModeFld       and USER MODE in step
go9@                rts

* Entry: X = the entry under the arrow (Page x MnRows + Row - 1). D clobbered.
Entry               lda       Page
                    ldb       #MnRows
                    mul
                    addb      Row
                    decb
                    lda       #MnLen
                    mul
                    leax      MnTab,pcr
                    leax      d,x
                    rts

* Down, Up: the arrow a row on; off the page's end to the next page's first row, off its top to the last row of
* the page before (both wrap round the pages)
Down                lbsr      Erase
                    lda       Row
                    cmpa      Rows
                    bhs       NextPg
                    inc       Row
                    lbra      Arrow
Up                  lbsr      Erase
                    dec       Row
                    lbne      Arrow
                    bsr       PgBack
                    bsr       SetRows
                    lda       Rows
                    sta       Row
                    lbra      Show
* NextPg, PrevPg: the page after (before), its first row
NextPg              lda       Page
                    inca
                    cmpa      #MnPages
                    blo       np1@
                    clra
np1@                sta       Page
                    lda       #FirstRow
                    sta       Row
                    lbra      Show
PrevPg              bsr       PgBack
                    lda       #FirstRow
                    sta       Row
                    lbra      Show
PgBack              lda       Page
                    bne       pb1@
                    lda       #MnPages
pb1@                deca
                    sta       Page
                    rts

* SetRows: the entries on this page (MnRows, fewer on the last) to Rows. D clobbered.
SetRows             lda       Page
                    ldb       #MnRows
                    mul
                    pshs      b
                    lda       #MnCount
                    suba      ,s+
                    cmpa      #MnRows
                    bls       sr1@
                    lda       #MnRows
sr1@                sta       Rows
                    rts

* Show: the page: cleared, the title, its entries, the F1 menu's bottom lines with the page number, the arrow
Show                bsr       SetRows
                    leax      StInit,pcr
                    ldy       #StInitL
                    lbsr      Wr
                    clrb                          row 0: the title
                    lda       #TitleCol
                    lbsr      Goto
                    leax      StTitle,pcr
                    ldy       #StTitleL
                    lbsr      Wr
                    lbsr      Entry0              X = the page's first entry
                    ldb       #FirstRow
sh1@                cmpb      Rows
                    bhi       sh2@
                    lda       #MnCol
                    lbsr      Goto
                    ldy       #MnTextLen
                    lbsr      Wr
                    leax      MnLen,x
                    incb
                    bra       sh1@
sh2@                ldb       #FootRow            the bottom lines
                    clra
                    lbsr      Goto
                    leax      StFoot,pcr
                    ldy       #StFootL
                    lbsr      Wr
                    lda       Page
                    adda      #PageDigit1
                    sta       ,-s
                    tfr       s,x
                    ldy       #PageDigitLen
                    lbsr      Wr
                    leas      1,s
                    leax      StExit,pcr
                    ldy       #StExitL
                    lbsr      Wr
                    lbra      Arrow
* Entry0: X = the first entry of the page. D clobbered.
Entry0              lda       Page
                    ldb       #MnRows
                    mul
                    lda       #MnLen
                    mul
                    leax      MnTab,pcr
                    leax      d,x
                    rts

* Arrow, Erase: "-->" at column 1 of the arrow's row, or spaces over it
Arrow               leax      StArrow,pcr
                    bra       ar1@
Erase               leax      StBlank,pcr
ar1@                pshs      x
                    lda       #ArrowCol
                    ldb       Row
                    bsr       Goto
                    puls      x
                    ldy       #ArrowLen
* Wr: Y bytes from X to FS's display path. Registers kept.
Wr                  pshs      d,x,y
                    lda       >FsPath
                    os9       I$Write
                    puls      d,x,y,pc
* Goto: the cursor to column A, row B (the terminal's $02 col+$20 row+$20). Registers kept.
Goto                pshs      d,x,y
                    adda      #GotoXYBias
                    addb      #GotoXYBias
                    pshs      d
                    lda       #VT_GOTOXY
                    pshs      a
                    tfr       s,x
                    ldy       #GotoXYLen
                    bsr       Wr
                    leas      3,s
                    puls      d,x,y,pc

StInit              fcb       $05,$20,$0C         cursor off, clear
StInitL             equ       *-StInit
StTitle             fcc       /AIRPORT - RUNWAY:/
StTitleL            equ       *-StTitle
StFoot              fcc       /--------------------------------/
                    fcb       $0D,$0A
                    fcc       /CC-FS2 AIRPORTS  PAGE /
StFootL             equ       *-StFoot
StExit              fcc       / EXIT:F3/
StExitL             equ       *-StExit
StArrow             fcc       /-->/
StBlank             fcc       /   /

                    use       f5_data.asm

                    emod
eom                 equ       *
                    end
