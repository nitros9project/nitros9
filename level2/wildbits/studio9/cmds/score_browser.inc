* The file picker (from the original s9d): 64 entries a page, read through a 32-bit directory seek cursor.
* The $078A-byte frame holds a 72-slot list; the page state lives beyond it.
BrowserEntry        ldx       6,s
                    ldd       1,x
                    cmpd      #$7363            .scr is the multi-score filter
                    bne       beargs@
                    leax      strScoreExt,pcr
                    stx       6,s
beargs@             ldd       12,s
                    pshs      d
                    ldd       12,s
                    pshs      d
                    ldd       12,s
                    pshs      d
                    ldd       12,s
                    pshs      d
                    ldd       12,s
                    pshs      d
                    lbsr      FilePickMenu
                    leas      10,s
                    rts
ReadDirList         pshs      u
                    leas      <-DirFrameSize,s
                    ldd       #$0081
                    pshs      a,b
                    leax      >pathCurDir,pcr
                    pshs      x
                    lbsr      OpenPath
                    leas      4,s
                    std       DirChanOff,s
                    cmpd      #$0003
                    bge       DirSkipDots
                    ldd       >UmeData_c_errno
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    leax      >msgCantOpenDir,pcr
                    pshs      x
                    jsr       [>UmeData_palert]
                    leas      6,s
                    clra
                    clrb
                    lbra      DirListExit
* DirSkipDots: count = 0, clear the page's more flag and seek to its saved directory position
DirSkipDots         clra
                    clrb
                    std       DirCountOff,s
                    ldx       <DirPageArgOff,s
                    clr       4,x
                    ldu       2,x
                    ldx       ,x
                    lda       DirChanOff+1,s
                    pshs      y
                    os9       I$Seek
                    puls      y
                    lbcs      DirReadDone
* DirReadLoop: read the next 32-byte entry (a short read ends the scan) and advance the cursor; skip deleted
* entries; CopyOs9Name, then HasExtension XOR invert decides; a match loses its extension (except for the
* .scr filter and the inverted list)
DirReadLoop         ldd       #$0020
                    pshs      a,b
                    leax      <DirBuffOff+2,s   STACK OFFSET adjusted for 2 bytes below frame S
                    pshs      x
                    ldd       DirChanOff+4,s   STACK OFFSET adjusted for 4 bytes below frame S
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    cmpd      #$0020
                    lblt      DirReadDone
                    ldx       <DirPageArgOff,s
                    ldd       2,x
                    addd      #32
                    std       2,x
                    bcc       droff@
                    ldd       ,x
                    addd      #1
                    std       ,x
droff@              ldb       <DirBuffOff,s
                    beq       DirReadLoop
                    leax      <DirBuffOff,s
                    pshs      x
                    leax      DirNameOff+2,s   STACK OFFSET adjusted for 2 bytes below frame S
                    pshs      x
                    lbsr      CopyOs9Name
                    leas      4,s
                    ldd       <DirExtArgOff,s
                    pshs      a,b
                    leax      DirNameOff+2,s   STACK OFFSET adjusted for 2 bytes below frame S
                    pshs      x
                    lbsr      HasExtension
                    leas      4,s
                    sex
                    pshs      a,b
                    ldb       <DirInvertArgOff+1+2,s   STACK OFFSET adjusted for 2 bytes below frame S
                    sex
                    eora      ,s+
                    eorb      ,s+
                    std       -2,s   STACK TEMP; compiler scratch/pushed value
                    lbeq      DirNotMatch         no match: a subdirectory?
                    leax      strScoreExt,pcr
                    cmpx      <DirExtArgOff,s
                    beq       DirStoreName
                    ldb       <DirInvertArgOff+1,s
                    bne       DirStoreName
                    leax      DirNameOff,s
                    pshs      x
                    lbsr      StrLen
                    leas      2,s
                    leax      DirNameOff,s
                    leax      d,x
                    clra
                    clrb
                    stb       -4,x
* DirStoreName: name[24]=0, StrCpy(list + count*26, name), count++, back to DirReadLoop; a 65th entry ends
* the page (DirPageFull)
DirStoreName        ldd       DirCountOff,s
                    cmpd      #64
                    lbhs      DirPageFull
                    clra
                    clrb
                    stb       <DirNameOff+24,s
                    leax      DirNameOff,s
                    pshs      x
                    ldd       DirCountOff+2,s   STACK OFFSET adjusted for 2 bytes below frame S
                    pshs      a,b
                    ldd       #$001A
                    lbsr      MulInt16
                    addd      <DirFnamesArgOff+2,s   STACK OFFSET adjusted for 2 bytes below frame S
                    pshs      a,b
                    lbsr      StrCpy
                    leas      4,s
                    ldd       DirCountOff,s
                    addd      #$0001
                    std       DirCountOff,s
                    lbra      DirReadLoop
* DirNotMatch: unless the list is inverted, an entry without the extension may be a subdirectory: it is opened
* with mode $81 (READ+DIR) - a directory opens, a plain file does not - and listed as '/name' ('/' sorts before
* every letter and digit, so the directories head the list; the picker's exit enters a '/name'). '.' is
* skipped; '..' lists as '/..', the way up.
DirNotMatch         ldb       <DirInvertArgOff+1,s
                    lbne      DirReadLoop         the non-scores list: nothing to add
                    ldb       DirNameOff,s
                    cmpb      #'.
                    bne       dnm1@
                    ldb       DirNameOff+1,s
                    lbeq      DirReadLoop         '.' itself
* a name with a '.' in it is a file (OS-9 directories carry no extension) and is never opened, so a large
* folder catalogs quickly
dnm1@               ldb       DirNameOff+1,s
                    cmpb      #'.
                    bne       dnm2b@
                    ldb       DirNameOff+2,s
                    beq       dnm3@               '..' itself: the way up, always a directory
dnm2b@              leax      DirNameOff,s
dnm0@               ldb       ,x+
                    beq       dnm3@
                    cmpb      #'.
                    bne       dnm0@
                    lbra      DirReadLoop
dnm3@               ldd       #$0081
                    pshs      a,b
                    leax      DirNameOff+2,s                 the name (past the pushed mode)   STACK OFFSET adjusted for 2 bytes below frame S
                    pshs      x
                    lbsr      OpenPath
                    leas      4,s
                    cmpd      #$0003
                    lblt      DirReadLoop         not a directory
                    pshs      a,b
                    lbsr      ClosePath
                    leas      2,s
                    leax      DirNameOff,s
                    pshs      x
                    lbsr      StrLen
                    puls      x                   X = the name again, D = its length
                    leax      d,x                 the NUL
                    leau      DirNameOff,s                 U = the name's first byte (U is scratch here, restored at the exit)
dnm2@               ldb       ,x
                    stb       1,x                 the name moves one right, NUL included
                    leax      -1,x
                    pshs      u
                    cmpx      ,s++
                    bhs       dnm2@
                    ldb       #'/
                    stb       ,u
                    lbra      DirStoreName
* DirPageFull: the 65th entry: step the cursor back over it and set the more flag.
* DirReadDone: ClosePath(fd); while pages remain to skip, or count <= 1, return the count; else bubble-sort
* with pass counter = count
DirPageFull         ldx       <DirPageArgOff,s
                    ldd       2,x
                    subd      #32
                    std       2,x
                    bcc       dpf1@
                    ldd       ,x
                    subd      #1
                    std       ,x
dpf1@               lda       #1
                    sta       4,x
DirReadDone         ldd       DirChanOff,s
                    pshs      a,b
                    lbsr      ClosePath
                    leas      2,s
                    ldx       <DirPageArgOff,s
                    ldd       8,x                 remaining pages to skip; no intermediate sort
                    bne       DirReturnCount
                    ldd       DirCountOff,s
                    cmpd      #$0001
                    ble      DirReturnCount
                    ldd       DirCountOff,s
                    std       DirChanOff,s
                    bra      DirSortOuterTest
* DirSortPass: outer sort loop: u = list + (count-1)*26 (MulInt16 by 26), inner scan runs u down to the second slot
DirSortPass         ldd       DirCountOff,s
                    addd      #$FFFF
                    pshs      a,b
                    ldd       #$001A
                    lbsr      MulInt16
                    addd      <DirFnamesArgOff,s
                    tfr       d,u
                    bra       DirSortInnerTest
* DirSortCompare: inner sort body: StrCmp(u-26, u) > 0 -> swap the two 26-byte names through the $22,s temp with three StrCpy; then u -= 26
DirSortCompare      pshs      u
                    pshs      u
                    ldd       #$FFE6
                    addd      ,s++
                    pshs      a,b
                    lbsr      StrCmp
                    leas      4,s
                    std       -2,s   STACK TEMP; compiler scratch/pushed value
                    ble       a2@
                    pshs      u
                    ldd       #$FFE6
                    addd      ,s++
                    pshs      a,b
                    leax      <DirBuffOff+2,s   STACK OFFSET adjusted for 2 bytes below frame S
                    pshs      x
                    lbsr      StrCpy
                    leas      4,s
                    pshs      u
                    pshs      u
                    ldd       #$FFE6
                    addd      ,s++
                    pshs      a,b
                    lbsr      StrCpy
                    leas      4,s
                    leax      <DirBuffOff,s
                    pshs      x
                    pshs      u
                    lbsr      StrCpy
                    leas      4,s
a2@                 leau      <-$1A,u
* DirSortInnerTest: inner loop test, entered from DirSortPass
DirSortInnerTest    cmpu      <DirFnamesArgOff,s
                    bhi       DirSortCompare
* DirSortOuterTest: pass counter-- ; nonzero -> DirSortPass
DirSortOuterTest    ldd       DirChanOff,s
                    addd      #$FFFF
                    std       DirChanOff,s
                    bne      DirSortPass
* DirReturnCount: D = count, then the frame exit
DirReturnCount      ldd       DirCountOff,s
* DirListExit: frame exit, also the error return with D = 0
DirListExit         leas      <DirFrameSize,s
                    puls      u,pc
* FilePickMenu(name, ext, write, chdir, kill): clear the list, ReadDirList one page, show it three names a row
* above the mode label, CANCEL and the page arrows, then take a click or a typed name
FilePickMenu        pshs      u
                    leas      >-BrowserFrameSize,s
                    clra
                    clrb
                    std       >BrowserPagePosOff,s
                    std       >BrowserPagePosOff+2,s
                    std       >BrowserPageNumOff,s
                    std       >BrowserPageSkipOff,s
                    clr       >BrowserPageActionOff,s
                    bra       MenuListClear
MenuReload          clr       >BrowserPageActionOff,s
                    ldx       >BrowserBuffArgOff,s
                    clr       ,x
MenuListClear       leau      >BrowserListOff+1871,s
                    bra       b3@
a3@                 clra
                    clrb
                    leau      -1,u
                    stb       1,u
b3@                 leax      BrowserListOff,s
                    pshs      x
                    cmpu      ,s++
                    bhs       a3@
MenuReadAgain       ldb       >BrowserDirArgOff+1,s
                    beq       c3@
                    ldb       >BrowserWrArgOff+1,s
                    beq       c3@
                    ldd       #$0001
                    bra       MenuReadDir
c3@                 clra
                    clrb
* MenuReadDir: count = ReadDirList(list, ext, flag, page), rescanning while pages remain to skip; zero count
* in chdir mode -> NoFilesMsg, otherwise MenuSizeCheck
MenuReadDir         leax      >BrowserPagePosOff,s
                    pshs      x
                    pshs      a,b
                    ldd       >BrowserExtArgOff+4,s   STACK OFFSET adjusted for 4 bytes below frame S
                    pshs      a,b
                    leax      BrowserListOff+6,s   STACK OFFSET adjusted for 6 bytes below frame S
                    pshs      x
                    lbsr      ReadDirList
                    leas      8,s
                    std       BrowserNrecsOff,s
                    ldd       >BrowserPageSkipOff,s
                    beq       mploaded@
                    tst       >BrowserPageMoreOff,s
                    beq       mploaded@
                    subd      #1
                    std       >BrowserPageSkipOff,s
                    lbra      MenuListClear
mploaded@           clr       >BrowserPageSkipOff,s
                    clr       >BrowserPageSkipOff+1,s
                    ldd       BrowserNrecsOff,s
                    bne       MenuSizeCheck
                    ldb       >BrowserDirArgOff+1,s
                    beq       MenuSizeCheck
                    ldd       >BrowserExtArgOff,s
                    pshs      a,b
                    ldb       >BrowserDirArgOff+1+2,s   STACK OFFSET adjusted for 2 bytes below frame S
                    beq       a4@
                    ldb       >BrowserWrArgOff+1+2,s   STACK OFFSET adjusted for 2 bytes below frame S
                    beq       a4@
                    leax      >strNonPrefix,pcr
                    bra       NoFilesMsg
a4@                 leax      >strEmpty,pcr
* NoFilesMsg: sprintf(name, fmtNoFiles, prefix, ext) ("non-" when chdir && write), alert, name[0]=0, exit
NoFilesMsg          tfr       x,d
                    pshs      a,b
                    leax      >fmtNoFiles,pcr
                    pshs      x
                    ldd       >BrowserBuffArgOff+6,s   STACK OFFSET adjusted for 6 bytes below frame S
                    pshs      a,b
                    jsr       [>UmeData_psprintf]
                    leas      8,s
                    clra
                    clrb
                    pshs      a,b
                    ldd       >BrowserBuffArgOff+2,s   STACK OFFSET adjusted for 2 bytes below frame S
                    pshs      a,b
                    jsr       [>UmeData_palert]
                    leas      4,s
                    clra
                    clrb
                    stb       [>BrowserBuffArgOff,s]
                    lbra      MenuExit
* MenuSizeCheck: rfr_scr |= (count > 42), rfr_bar = the same (the big-list flag: MenuClose then issues
* WinCtl90); WinDefine's 5th argument is !flag
MenuSizeCheck       ldd       #$0002
                    pshs      a,b
                    ldb       <UmeData_rfr_scr
                    sex
                    pshs      a,b
                    ldd       BrowserNrecsOff+4,s   STACK OFFSET adjusted for 4 bytes below frame S
                    cmpd      #$002A
                    ble       a5@
                    ldd       #$0001
                    bra       b5@
a5@                 clra
                    clrb
b5@                 ora       ,s+
                    orb       ,s+
                    stb       <UmeData_rfr_scr
                    stb       <UmeData_rfr_bar
                    bne       c5@
                    ldd       #$0001
                    bra       MenuOpenWindow
c5@                 clra
                    clrb
* MenuOpenWindow: rows = (count+2)/3 + 1 (DivInt16) -> 2,s; WinDefine(1, 190, 78, rows, !bigflag, 2); putchar(12) clears; i = 0, u = list
MenuOpenWindow      pshs      a,b
                    ldd       BrowserNrecsOff+4,s   STACK OFFSET adjusted for 4 bytes below frame S
                    addd      #$0002
                    pshs      a,b
                    ldd       #$0003
                    lbsr      DivInt16
                    addd      #$0001
                    std       BrowserNlinesOff+4,s   STACK OFFSET adjusted for 4 bytes below frame S
                    pshs      a,b
                    ldd       #$004E
                    pshs      a,b
                    ldd       #$00BE
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    lbsr      WinDefine
                    leas      12,s
                    ldd       #$000C
                    pshs      a,b
                    jsr       [>UmeData_pputchar]
                    leas      2,s
                    clra
                    clrb
                    std       BrowserRecOff,s
                    leau      BrowserListOff,s
                    bra       MenuRowTest
* MenuPrintRow: printf(fmtThreeCols, u, u+26, u+52); u += 78; i += 3
MenuPrintRow        pshs      u
                    ldd       #$0034
                    addd      ,s++
                    pshs      a,b
                    pshs      u
                    ldd       #$001A
                    addd      ,s++
                    pshs      a,b
                    pshs      u
                    leax      >fmtThreeCols,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      8,s
                    leau      <$4E,u
                    ldd       BrowserRecOff,s
                    addd      #$0003
                    std       BrowserRecOff,s
* MenuRowTest: loop test i < count -> MenuPrintRow; then picks the mode label: kill -> strKillFile, chdir -> strChangeDir, write -> strWriteFile, else strReadFile
MenuRowTest         ldd       BrowserRecOff,s
                    cmpd      BrowserNrecsOff,s
                    blt       MenuPrintRow
                    ldb       >BrowserDelArgOff+1,s
                    beq       a6@
                    leax      >strKillFile,pcr
                    bra       MenuPrompt
a6@                 ldb       >BrowserDirArgOff+1,s
                    beq       b6@
                    leax      >strChangeDir,pcr
                    bra       MenuPrompt
b6@                 ldb       >BrowserWrArgOff+1,s
                    beq       c6@
                    leax      >strWriteFile,pcr
                    bra       MenuPrompt
c6@                 leax      >strReadFile,pcr
* MenuPrompt: printf(fmtLabelCancel, label, strCancel, strPageArrows); WinDefine($1C, 190-7*rows-4, $23, 1, 1, 0)
* for the input line; WinCtlCC(1); printf(msgClickOrType); u = name (typing cursor)
MenuPrompt          tfr       x,u
                    leax      strPageArrows,pcr
                    pshs      x
                    leax      strCancel,pcr
                    pshs      x
                    pshs      u
                    leax      >fmtLabelCancel,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      8,s
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0023
                    pshs      a,b
                    ldd       BrowserNlinesOff+8,s   STACK OFFSET adjusted for 8 bytes below frame S
                    pshs      a,b
                    ldd       #$0007
                    lbsr      MulInt16
                    pshs      a,b
                    ldd       #$00BE
                    subd      ,s++
                    addd      #$FFFC
                    pshs      a,b
                    ldd       #$001C
                    pshs      a,b
                    lbsr      WinDefine
                    leas      12,s
                    ldd       #$0001
                    pshs      a,b
                    lbsr      WinCtlCC
                    leas      2,s
                    leax      >msgClickOrType,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    ldu       >BrowserBuffArgOff,s
* MenuInputLoop: key = ptextmen(1, 190, 26, 3, 0, rows, 1); >= 0 -> MenuClickIndex (1-based click), negative
* -> key = (-key)&$7F; the first typed char prints strClearLine
MenuInputLoop       ldd       #$0001
                    pshs      a,b
                    ldd       BrowserNlinesOff+2,s   STACK OFFSET adjusted for 2 bytes below frame S
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0003
                    pshs      a,b
                    ldd       #$001A
                    pshs      a,b
                    ldd       #$00BE
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    jsr       [>UmeData_ptextmen]
                    leas      14,s
                    std       BrowserRecOff,s
                    bge      MenuClickIndex
                    ldd       BrowserRecOff,s
                    nega
                    negb
                    sbca      #$00
                    clra
                    andb      #$7F
                    std       BrowserRecOff,s
                    cmpu      >BrowserBuffArgOff,s
                    bne       MenuKeyDispatch
                    leax      >strClearLine,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
* MenuKeyDispatch: typed $0D (Enter) -> MenuNameDone; $08 (backspace) -> u-- if past the start, echo
MenuKeyDispatch     ldd       BrowserRecOff,s
                    cmpd      #$000D
                    lbeq      MenuNameDone
                    ldd       BrowserRecOff,s
                    cmpd      #$0008
                    bne       MenuKeyCtrl
                    cmpu      >BrowserBuffArgOff,s
                    bls       MenuEchoKey
                    leau      -1,u
                    bra       MenuEchoKey
* MenuKeyCtrl: $15 (^U) or $18 (^X) -> erase the typed line: echo $18 and reset u to the name start
MenuKeyCtrl         ldd       BrowserRecOff,s
                    cmpd      #$0015
                    beq       a7@
                    ldd       BrowserRecOff,s
                    cmpd      #$0018
                    bne       MenuKeyStore
a7@                 ldd       #$0018
                    std       BrowserRecOff,s
                    ldu       >BrowserBuffArgOff,s
                    bra       MenuEchoKey
* MenuKeyStore: space ($20) ignored, any other key stored at u++ and echoed
MenuKeyStore        ldd       BrowserRecOff,s
                    cmpd      #$0020
                    lbeq      MenuInputLoop
                    ldd       BrowserRecOff,s
                    stb       ,u+
* MenuEchoKey: putchar(key), flush, back to MenuInputLoop
MenuEchoKey         ldd       BrowserRecOff,s
                    pshs      a,b
                    jsr       [>UmeData_pputchar]
                    leas      2,s
                    jsr       [>UmeData_pflush]
                    lbra      MenuInputLoop
* MenuClickIndex: index = key-1; a list entry -> MenuClickRange; on the bottom row column 0 (the mode label)
* ends the typed name (empty = cancel), column 1 is CANCEL, column 2 the page arrows
MenuClickIndex      ldd       BrowserRecOff,s
                    addd      #$FFFF
                    std       BrowserRecOff,s
                    cmpd      BrowserNrecsOff,s
                    blt       MenuClickRange
                    ldd       BrowserNlinesOff,s
                    subd      #1
                    pshs      d
                    ldd       #3
                    lbsr      MulInt16
                    cmpd      BrowserRecOff,s
                    lbhi      MenuInputLoop
                    ldd       BrowserRecOff,s
                    pshs      a,b
                    ldd       #$0003
                    lbsr      ModInt16
                    cmpd      #2
                    lbeq      MenuPageArrow
                    cmpd      #0
                    bne       MenuCancel
* MenuNameDone: *u = 0 terminates the typed name and goes to MenuClose
MenuNameDone        clra
                    clrb
                    stb       ,u
                    lbra      MenuClose
* MenuClickRange: index < 0 or >= count -> MenuCancel, else MenuPickEntry
MenuClickRange      ldd       BrowserRecOff,s
                    blt       MenuCancel
                    ldd       BrowserRecOff,s
                    cmpd      BrowserNrecsOff,s
                    blt       MenuPickEntry
* MenuCancel: name[0] = 0 (cancel) and MenuClose
MenuCancel          clra
                    clrb
                    stb       [>BrowserBuffArgOff,s]
                    lbra       MenuClose
* MenuPickEntry: StrNCpy(name, list + index*26, 25); u = name+StrLen; printf(fmtClearShowName); flush; read mode without kill accepts at once, otherwise MenuNeedConfirm
MenuPickEntry       ldd       #$0019
                    pshs      a,b
                    ldd       BrowserRecOff+2,s   STACK OFFSET adjusted for 2 bytes below frame S
                    pshs      a,b
                    ldd       #$001A
                    lbsr      MulInt16
                    leax      BrowserListOff+2,s   STACK OFFSET adjusted for 2 bytes below frame S
                    leax      d,x
                    pshs      x
                    ldd       >BrowserBuffArgOff+4,s   STACK OFFSET adjusted for 4 bytes below frame S
                    pshs      a,b
                    lbsr      StrNCpy
                    leas      6,s
                    ldd       >BrowserBuffArgOff,s
                    pshs      a,b
                    lbsr      StrLen
                    leas      2,s
                    addd      >BrowserBuffArgOff,s
                    tfr       d,u
                    ldd       >BrowserBuffArgOff,s
                    pshs      a,b
                    leax      >fmtClearShowName,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    jsr       [>UmeData_pflush]
                    ldb       >BrowserWrArgOff+1,s
                    bne       MenuNeedConfirm
                    ldb       >BrowserDelArgOff+1,s
                    lbeq       MenuClose
* MenuNeedConfirm: write&&chdir accepts the click; write or kill without chdir goes back to MenuInputLoop so the user confirms/edits the name with Enter
MenuNeedConfirm     ldb       >BrowserWrArgOff+1,s
                    lbeq      MenuInputLoop
                    ldb       >BrowserDirArgOff+1,s
                    lbeq      MenuInputLoop
                    lbra      MenuClose
* MenuPageArrow: ptextmen already took the click; the mouse X picks the arrow. The footer column starts at
* cell 53; cells 70..77 are "( up  down )", the last cell blank so the text window does not wrap.
* mouce(xptr,yptr) returns the full-resolution X; it preserves U and Y.
MenuPageArrow       leax      >BrowserMouseYOff,s
                    pshs      x
                    leax      >BrowserMouseXOff+2,s   STACK OFFSET adjusted for pushed Y pointer
                    pshs      x
                    jsr       [>UmeData_pmouce]
                    leas      4,s
                    ldd       >BrowserMouseXOff,s
                    cmpd      #71*8
                    lblo      MenuInputLoop
                    cmpd      #74*8
                    blo       MenuPreviousPage
                    cmpd      #77*8
                    lbhs      MenuInputLoop
MenuNextPage        tst       >BrowserPageMoreOff,s
                    lbeq      MenuInputLoop
                    ldd       >BrowserPageNumOff,s
                    addd      #1
                    std       >BrowserPageNumOff,s
                    bra       mpreload@
* Re-scan to the previous 64-entry boundary. This has no fixed history limit,
* uses the existing frame, and sorts only the displayed page.
MenuPreviousPage    ldd       >BrowserPageNumOff,s
                    lbeq      MenuInputLoop
                    subd      #1
                    std       >BrowserPageNumOff,s
                    std       >BrowserPageSkipOff,s
                    clra
                    clrb
                    std       >BrowserPagePosOff,s
                    std       >BrowserPagePosOff+2,s
mpreload@           inc       >BrowserPageActionOff,s
* MenuClose: WinEnd twice (input line and list box); rfr_bar set -> WinCtl90
MenuClose           lbsr      WinEnd
                    lbsr      WinEnd
                    ldb       <UmeData_rfr_bar
                    beq       MenuExit
                    lbsr      WinCtl90
* MenuExit: a page change reloads; otherwise the frame goes, and a picked or typed '/name' is a subdirectory:
* ChangeDir into it, clear the name and run the picker again (the caller's arguments are still on the stack:
* a tail jump). A failed ChangeDir returns the '/name' as it is.
MenuExit            tst       >BrowserPageActionOff,s
                    lbne      MenuReload
                    leas      >BrowserFrameSize,s
                    puls      u
                    ldx       BrowserBuffArgOff-1932,s                 the name argument   STACK OFFSET adjusted for -1932 bytes below frame S
                    ldb       ,x
                    cmpb      #'/
                    bne       mex@
                    leax      1,x
                    pshs      x
                    lbsr      ChangeDir
                    leas      2,s
                    cmpd      #0
                    blt       mex@
                    ldx       BrowserBuffArgOff-1932,s   STACK OFFSET adjusted for -1932 bytes below frame S
                    clr       ,x
                    lbra      FilePickMenu
mex@                rts
* pathCurDir: "." - the directory ReadDirList opens
pathCurDir          fcb       $2E,$00
* msgCantOpenDir: "Can't open Dir, Error #" message box with errno in ReadDirList
msgCantOpenDir      fcc       /Can't open Dir, Error #/
                    fcb       $00
* fmtNoFiles: "No %s%s files.\r" sprintf format (prefix, ext) shown when the CHANGE DIR listing is empty
fmtNoFiles          fcc       /No %s%s files./
                    fcb       $0D,$00
* strNonPrefix: "non-" prefix for fmtNoFiles when the listing was of non-matching names
strNonPrefix        fcc       /non-/
                    fcb       $00
* strEmpty: "" empty prefix for fmtNoFiles
strEmpty            fcb       $00
* fmtThreeCols: "%-26s%-26s%-25s\r" one row of three file names in FilePickMenu
fmtThreeCols        fcc       /%-26s%-26s%-25s/
                    fcb       $0D,$00
* fmtLabelCancel: "%-26s%-26s%s" the bottom row: mode label, CANCEL, page arrows
fmtLabelCancel      fcc       /%-26s%-26s%s/
                    fcb       $00
* strKillFile: "   (KILL FILE)" menu label in kill mode
strKillFile         fcc       /   (KILL FILE)/
                    fcb       $00
* strChangeDir: "   (CHANGE DIR)" menu label in chdir mode
strChangeDir        fcc       /   (CHANGE DIR)/
                    fcb       $00
* strWriteFile: "   (WRITE FILE)" menu label in write mode
strWriteFile        fcc       /   (WRITE FILE)/
                    fcb       $00
* strReadFile: "   (READ FILE)" menu label in read mode
strReadFile         fcc       /   (READ FILE)/
                    fcb       $00
* msgClickOrType: "Click one, or type name: " prompt of FilePickMenu
msgClickOrType      fcc       /Click one, or type name: /
                    fcb       $00
* strClearLine: "\f\r" printed before the first typed character of a name
strClearLine        fcb       $0C,$0D,$00
* fmtClearShowName: "\f\r%s" shows the clicked file name on the input line
fmtClearShowName    fcb       $0C,$0D,$25,$73,$00
* HasExtension(name, ext): nonzero when name ends in ext (case-insensitive). The .scr filter accepts .ume (1)
* and the importable files, returning the importer's letter: .mid 'I', .lyr 'Y', .mus 'F', .orc/.asc 'O'.
HasExtension        pshs      u
                    ldx       4,s
                    tfr       x,u
he_end@             tst       ,x+
                    bne       he_end@
                    leax      -5,x
                    pshs      u
                    cmpx      ,s++
                    bls       HasExtNo
                    ldu       6,s
                    pshs      x
                    bsr       he_cmp
                    bne       he_yes@
                    leau      strScoreExt,pcr
                    cmpu      8,s
                    bne       he_popno@
                    ldx       ,s
                    leau      strExtUme,pcr
                    bsr       he_cmp
                    bne       he_yes@
                    ldx       ,s
                    leau      strExtMid,pcr
                    bsr       he_cmp
                    beq       he_lyra@
                    ldb       #'I
                    bra       he_done@
he_lyra@
                    ldx       ,s
                    leau      strExtLyr,pcr
                    bsr       he_cmp
                    beq       he_mus@
                    ldb       #'Y
                    bra       he_done@
he_mus@             ldx       ,s
                    leau      strExtMus,pcr
                    bsr       he_cmp
                    beq       he_orc@
                    ldb       #'F
                    bra       he_done@
he_orc@             ldx       ,s                  .orc and .asc are Orchestra-90 text (s9o)
                    leau      strExtOrc,pcr
                    bsr       he_cmp
                    bne       he_isorc@
                    ldx       ,s
                    leau      strExtAsc,pcr
                    bsr       he_cmp
                    beq       he_done@
he_isorc@           ldb       #'O
                    bra       he_done@
he_yes@             ldd       #1
he_done@            leas      2,s
                    puls      u,pc
he_popno@           leas      2,s
HasExtNo            clra
                    clrb
                    puls      u,pc
he_cmp              ldb       #4
he_char@            lda       ,x+
                    cmpa      #'A
                    blo       he_lower@
                    cmpa      #'Z
                    bhi       he_lower@
                    adda      #$20
he_lower@           cmpa      ,u+
                    bne       he_fail@
                    decb
                    bne       he_char@
                    ldd       #1
                    rts
he_fail@            clra
                    clrb
                    rts
* WinDefine (six arguments): printf(fmt at DP $14, $C6, ...) and flush - the private window-define code
WinDefine           pshs      u
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
* WinEnd: printf(fmt at DP $16, $C7) - the private window-close code
WinEnd              pshs      u
                    ldd       #$00C7
                    pshs      a,b
                    ldd       <UmeData_reserved_0016
                    pshs      a,b
                    jsr       [>UmeData_pprintf]
* Pop4Return: WinEnd's tail
Pop4Return          leas      4,s
* PopUReturn: puls u,pc (no caller in this module)
PopUReturn          puls      u,pc
* WinCtlCC(n): printf(fmt at DP $18, $CC, (char)n) - private control code; MenuPrompt issues it with 1
WinCtlCC            pshs      u
                    ldb       5,s
                    sex
                    pshs      a,b
                    ldd       #$00CC
                    pshs      a,b
                    ldd       <UmeData_reserved_0018
                    bra       WinCtlPrintf
* WinCtl90: printf(fmt at DP $0A, $90, 0) - private control code issued after a big menu closes
WinCtl90            pshs      u
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0090
                    bra       WinCtlFmt0A
* WinCtl89(n): printf(fmt at DP $0A, $89, n) - private control code (no caller in this module)
WinCtl89            pshs      u
                    ldd       4,s
                    pshs      a,b
                    ldd       #$0089
                    bra       WinCtlFmt0A
* WinCtl8B(n): printf(fmt at DP $0A, $8B, n) - private control code (no caller in this module)
WinCtl8B            pshs      u
                    ldd       4,s
                    pshs      a,b
                    ldd       #$008B
* WinCtlFmt0A: shared tail pushing the code then the DP $0A printf format; WinCtl8B falls in
WinCtlFmt0A         pshs      a,b
                    ldd       <UmeData_reserved_000A
* WinCtlPrintf: shared printf tail of the WinCtl codes; WinCtlCC branches here
WinCtlPrintf        pshs      a,b
                    jsr       [>UmeData_pprintf]
                    leas      6,s
                    puls      u,pc
* strExtUme..strNoExt: the file extensions; HasExtension uses .ume and .mid
strExtUme           fcc       /.ume/
                    fcb       $00
strExtIns           fcc       /.ins/
                    fcb       $00
strExtPer           fcc       /.per/
                    fcb       $00
strExtLev           fcc       /.lev/
                    fcb       $00
strExtMid           fcc       /.mid/
                    fcb       $00
strNoExt            fcb       $00
* StrCpy(dest, src): returns dest
StrCpy              pshs      u
                    ldu       6,s
                    ldx       4,s
* StrCopyLoop: byte copy loop of StrCpy
StrCopyLoop         ldb       ,u+
                    stb       ,x+
                    bne       StrCopyLoop
                    ldd       4,s
                    puls      u,pc
                    fcb       $AE,$62
* SkipToNul: advance X to the terminating NUL and return it in D
SkipToNul           ldb       ,x+
                    bne       SkipToNul
                    leax      -1,x
                    tfr       x,d
                    rts
* StrCmp: strcmp(a, b): returns a[i]-b[i] sign-extended at the first difference, 0 when equal
StrCmp              pshs      u
                    ldx       4,s
                    ldu       6,s
                    bra       StrCmpLoop
* StrCmpAdvance: equal bytes: the next, or StrCmpReturn on the NUL
StrCmpAdvance       ldb       ,u+
                    beq       StrCmpReturn
* StrCmpLoop: compare loop of StrCmp
StrCmpLoop          ldb       ,u
                    subb      ,x+
                    beq       StrCmpAdvance
                    negb
* StrCmpReturn: StrCmp exit, D = the sign-extended difference
StrCmpReturn        sex
                    puls      u,pc
* StrLen: strlen(s): scans to NUL, D = end - start
StrLen              pshs      u
                    ldu       4,s
* StrLenLoop: scan loop of StrLen
StrLenLoop          ldb       ,u+
                    bne       StrLenLoop
                    leau      -1,u
                    tfr       u,d
                    subd      4,s
                    puls      u,pc
* StrNCpy: strncpy(dest, src, n): copies up to n bytes and pads the rest with NUL; returns dest
StrNCpy             pshs      y,u
                    ldu       8,s
                    ldx       6,s
                    ldy       10,s
                    beq       StrNCpyDone
* StrNCpyLoop: copy loop of StrNCpy; hits NUL -> pad loop
StrNCpyLoop         ldb       ,u+
                    stb       ,x+
                    leay      -1,y
                    beq       StrNCpyDone
                    tstb
                    bne       StrNCpyLoop
a39@                clr       ,x+
                    leay      -1,y
                    bne       a39@
* StrNCpyDone: StrNCpy exit returning dest
StrNCpyDone         ldd       6,s
                    puls      y,u,pc
* CopyOs9Name: CopyOs9Name(dest, src): copies bytes until one with bit 7 set (OS-9 directory-entry name terminator), clears that bit, appends NUL; returns dest
CopyOs9Name         pshs      u
                    ldu       4,s
                    ldx       6,s
a40@                ldb       ,x+
                    stb       ,u+
                    bpl       a40@
                    andb      #$7F
                    stb       -1,u
                    clr       ,u
                    ldd       4,s
                    puls      u,pc
* MulInt16: D * the stacked word -> D, the argument popped; an 8x8 MUL when both high bytes are zero
MulInt16            tsta
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
* MulFull16: general 16x16 partial-product path of MulInt16
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
                    bhs       a41@
                    inc       ,s
a41@                lda       4,s
                    ldb       9,s
                    mul
                    addd      1,s
                    std       1,s
                    bhs       b41@
                    inc       ,s
b41@                lda       4,s
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
* ModInt16: signed modulo of the stacked dividend by D: divisor 0 returns the dividend, else DivInt16 through
* the vector at $0CCD,y and the remainder with the dividend's sign (flag $0CCC,y)
ModInt16            leax      >DivInt16,pcr
                    stx       >$0CCD,y
                    clr       >$0CCC,y
                    tst       2,s
                    bpl       a42@
                    inc       >$0CCC,y
a42@                subd      #$0000
                    bne       ModCallDiv
                    puls      x
                    ldd       ,s++
                    jmp       ,x
* ModCallDiv: push the dividend, jsr [$0CCD,y], take the remainder from X, negate when the sign flag is set
ModCallDiv          ldx       2,s
                    pshs      x
                    jsr       [>$0CCD,y]
                    ldd       ,s
                    std       2,s
                    tfr       x,d
                    tst       >$0CCC,y
                    beq       a43@
                    nega
                    negb
                    sbca      #$00
a43@                std       ,s++
                    rts
                    fcb       $83,$00,$00,$27,$0A,$34,$06
                    fcs       /2~od/
                    fcc       /oa ./
* DivByZero: divide by zero: errno = 45 and RaiseSignal(45)
DivByZero           puls      a,b
                    std       ,s
                    ldd       #$002D
                    bra      RaiseSignal
* DivInt16: signed 16-bit divide (Microware C _div): dividend on the stack, divisor in D; negates operands tracking the sign, shift-subtract loop; D = quotient, X = remainder, pops the dividend
DivInt16            subd      #$0000
                    beq       DivByZero
                    pshs      a,b
                    leas      -2,s
                    clr       ,s
                    clr       1,s
                    tsta
                    bpl       DivNegDividend
                    nega
                    negb
                    sbca      #$00
                    com       1,s
                    std       2,s
* DivNegDividend: negative dividend: negate it and toggle the sign flag
DivNegDividend      ldd       6,s
                    bpl       DivNormalize
                    nega
                    negb
                    sbca      #$00
                    com       1,s
                    std       6,s
* DivNormalize: shift the divisor left until bit 15 is set, counting the steps
DivNormalize        lda       #$01
* DivNormLoop: normalization shift loop of DivInt16
DivNormLoop         inca
                    asl       3,s
                    rol       2,s
                    bpl       DivNormLoop
                    sta       ,s
                    ldd       6,s
                    clr       6,s
                    clr       7,s
* DivLoop: restoring shift-subtract division loop
DivLoop             subd      2,s
                    bhs       a44@
                    addd      2,s
                    andcc     #$FE
                    bra       DivShiftIn
a44@                orcc      #$01
* DivShiftIn: shift the quotient bit in, shift the divisor right, count down
DivShiftIn          rol       7,s
                    rol       6,s
                    lsr       2,s
                    ror       3,s
                    dec       ,s
                    bne       DivLoop
                    std       2,s
                    tst       1,s
                    beq       DivReturn
                    ldd       6,s
                    nega
                    negb
                    sbca      #$00
                    std       6,s
* DivReturn: move the return address over the dividend arg, X = remainder, D = quotient, leas 6 and rts
DivReturn           ldx       4,s
                    ldd       6,s
                    std       4,s
                    stx       6,s
                    ldx       2,s
                    ldd       4,s
                    leas      6,s
                    rts
* RaiseSignal: store D into errno (>$034F,y), F$ID for the own process id, F$Send that signal to self
RaiseSignal         std       >$034F,y
                    pshs      b,y
                    os9       F$ID
                    puls      b,y
                    os9       F$Send
                    rts
                    fcb       $AE,$62,$A6,$65,$10,$3F,$84,$25
                    fcb       $03,$10,$3F,$8F,$16,$01,$75,$AE
                    fcb       $62,$E6,$65,$10,$3F,$85,$16,$01
                    fcb       $6B,$A6,$65,$20,$02
* UnlinkFile: unlink(name): I$DeletX with A = 2 (data directory), CarryToRet
UnlinkFile          lda       #$02
                    ldx       2,s
                    os9       I$DeletX
                    lbra      CarryToRet
                    fcb       $A6,$63,$10,$3F,$82,$10,$25,$01
                    fcb       $4B,$1F,$89,$4F,$39
* CreatePath: creat(name, mode): I$Create with (mode & $24) | $0B; E$CEF ($DA, exists) and mode bit $80 clear -> I$Open (mode & 7) then I$SetStt SS.Size with X:U = 0 to truncate; returns the path number or ErrReturn
CreatePath          ldx       2,s
                    lda       5,s
                    tfr       a,b
                    andb      #$24
                    orb       #$0B
                    os9       I$Create
                    bhs       RetPathNum
                    cmpb      #$DA
                    bne       CreatFail
                    lda       5,s
                    bita      #$80
                    bne       CreatFail
                    anda      #$07
                    ldx       2,s
                    os9       I$Open
                    blo       CreatFail
                    pshs      a,u
                    ldx       #$0000
                    leau      ,x
                    ldb       #$02
                    os9       I$SetStt
                    puls      a,u
                    bhs       RetPathNum
                    pshs      b
                    os9       I$Close
                    puls      b
* CreatFail: error exit of CreatePath: lbra ErrReturn
CreatFail           lbra      ErrReturn
                    fcb       $AE,$62,$A6,$65,$E6,$67,$10,$3F
                    fcb       $83,$25,$F2,$20,$14,$C1,$DA,$26
                    fcb       $EC,$10,$3F,$87,$25,$E7,$AE,$62
                    fcb       $A6,$65,$E6,$67,$10,$3F,$83,$25
                    fcb       $EC
* RetPathNum: D = path number from A (tfr a,b; clra) shared by CreatePath
RetPathNum          tfr       a,b
                    clra
                    rts
* OpenPath: open(name, mode): I$Open, carry -> ErrReturn, else returns the path number
OpenPath            ldx       2,s
                    lda       5,s
                    os9       I$Open
                    lblo      ErrReturn
                    tfr       a,b
                    clra
                    rts
* ClosePath: close(path): I$Close then CarryToRet
ClosePath           lda       3,s
                    os9       I$Close
                    lbra      CarryToRet
* ReadPath: read(path, buf, n): I$Read, E$EOF ($D3) -> 0, other error -> ErrReturn, else bytes read
ReadPath            pshs      y
                    ldx       6,s
                    lda       5,s
                    ldy       8,s
                    pshs      y
                    os9       I$Read
                    bhs       ReadPathCount
                    cmpb      #$D3
                    bne       ReadError
                    clra
                    clrb
                    puls      x,y,pc
* ReadError: non-EOF read error: restore X,Y and ErrReturn
ReadError           puls      x,y
                    lbra      ErrReturn
* ReadPathCount: ReadPath success return: bhs target, D = Y = bytes read, puls x,y,pc
ReadPathCount       tfr       y,d
                    puls      x,y,pc
                    fcb       $34,$20,$A6,$65,$AE,$66,$10,$AE
                    fcc       /h4 /
                    fcb       $10,$3F,$8B,$20,$DD
* WritePath: write(path, buf, n): n == 0 returns 0, I$Write, error -> ErrReturn, else n
WritePath           pshs      y
                    ldy       8,s
                    beq       a45@
                    lda       5,s
                    ldx       6,s
                    os9       I$Write
                    bhs       a45@
                    puls      y
                    lbra      ErrReturn
a45@                tfr       y,d
                    puls      y,pc
                    fcb       $34,$20,$10,$AE,$68,$27,$F5,$A6
                    fcb       $65,$AE,$66,$10,$3F,$8C,$20,$E5
* LSeek: lseek(path, long offset, whence): whence 0 from start, 1 adds SS.Pos (I$GetStt 5), 2 adds SS.Size (I$GetStt 2), other -> errno $F7; I$Seek; returns X -> the 32-bit result at $0343,y
LSeek               pshs      u
                    ldd       10,s
                    bne       LSeekWhence
                    ldu       #$0000
                    ldx       #$0000
                    bra       LSeekDoSeek
* LSeekWhence: whence dispatch: 1 -> LSeekFromCur, 2 -> LSeekFromEnd, else errno $F7 and LSeekError
LSeekWhence         cmpd      #$0001
                    beq       LSeekFromCur
                    cmpd      #$0002
                    beq       LSeekFromEnd
                    ldb       #$F7
* LSeekError: errno = B, long result = -1 (both words $FFFF), return
LSeekError          clra
                    std       >$034F,y
                    ldd       #$FFFF
                    leax      >$0343,y
                    std       ,x
                    std       2,x
                    puls      u,pc
* LSeekFromEnd: I$GetStt SS.Size (2) -> X:U file size as the base
LSeekFromEnd        lda       5,s
                    ldb       #$02
                    os9       I$GetStt
                    blo       LSeekError
                    bra       LSeekDoSeek
* LSeekFromCur: I$GetStt SS.Pos (5) -> X:U current position as the base
LSeekFromCur        lda       5,s
                    ldb       #$05
                    os9       I$GetStt
                    blo       LSeekError
* LSeekDoSeek: base X:U + stacked offset (negative result -> error), store in the accumulator, I$Seek, X = accumulator
LSeekDoSeek         tfr       u,d
                    addd      8,s
                    std       >$0345,y
                    tfr       d,u
                    tfr       x,d
                    adcb      7,s
                    adca      6,s
                    bmi       LSeekError
                    tfr       d,x
                    std       >$0343,y
                    lda       5,s
                    os9       I$Seek
                    blo       LSeekError
                    leax      >$0343,y
                    puls      u,pc
* ChangeDir: chdir(name): I$ChgDir with A = 1 (data directory), CarryToRet
ChangeDir           lda       #$01
                    ldx       2,s
                    os9       I$ChgDir
                    bcs       ErrReturn
* The current directory is captured when leaving this drive or exiting s9.
* Do not load another overlay or allocate its large work frame inside the browser.
                    clra
                    clrb
                    rts
                    fcb       $86,$04,$20,$F4
* ErrReturn: errno (>$034F,y) = B, return -1; common error exit of the system-call wrappers
ErrReturn           clra
                    std       >$034F,y
                    ldd       #$FFFF
                    rts
* CarryToRet: carry set -> ErrReturn else return 0 (tail of UnlinkFile, ClosePath and ChangeDir)
CarryToRet          blo       ErrReturn
                    clra
                    clrb
                    rts
strScoreExt         fcc       /.scr/
                    fcb       0
strExtOrc           fcc       /.orc/
                    fcb       0
strExtAsc           fcc       /.asc/
                    fcb       0
strExtLyr           fcc       /.lyr/
                    fcb       0
strExtMus           fcc       /.mus/
                    fcb       0
* 17 spaces put '(' at cell 70; up at 72, down at 75, ')' at 77.
* $1E/$1F select the two appended Chars16 arrow glyphs in s9gui's text stream.
strPageArrows       fcc       /                 ( /
                    fcb       $1E
                    fcc       /  /
                    fcb       $1F
                    fcc       / )/
                    fcb       0
strCancel           fcc       /   (CANCEL)/
                    fcb       0
