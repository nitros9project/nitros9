********************************************************************
* F3 - disassembled OS-9 module (byte-exact lwasm round trip)
* Flight Simulator II (subLOGIC, 1987), CoCo 3 OS-9 Level 2: disassembled from the byte listing ../f3.asm.
* An overlay FS maps at $4000 (F2, F3 and F4 share that window): absolute self-references are Lxxxx+ModBase.
* header: type/lang $21 attr/rev $80, exec offset $0020, data size $0000 (0), module size 8192 bytes
* Labels name the routines, branch points and data; ModBase+label is the run address. Data addressing is left numeric (offsets into the
* program's data area, <$xx = direct page). fcb lines inside code carry the decoded mnemonic as a comment
* where the assembler could not be made to reproduce the original encoding.

                    nam       F3
                    ttl       F3 (disassembly)

                    ifp1
                    use       defsfile
                    use       fs_wb.d
                    endc

* Constants: the values this module's instructions use, by name (fs_wb.d holds the addresses)
ArrowLen            equ       $0003               StrListArrow's and StrArrowBlank's bytes
AsciiBits           equ       $7F                 a character's 7 ASCII bits: RBF's end-of-name bit 7 cleared
ChrCR               equ       $0D                 a carriage return: the end of an OS-9 path name or text line
ChrSpace            equ       $20                 a space, the first printable character: lower key codes are not typed in
CurDirDot           equ       $2E                 '.', the current directory: the directory part of a path that has none
CurDirDotCR         equ       $2E0D               '.' and a CR: the directory part is the current directory, so the path gets none
DataFileMagic       equ       $DD01               the data file's header magic
DataHdrLen          equ       $000A               the data file's header: 10 bytes, the block index after it
DefaultSfLen        equ       $0C                 StrDefaultScenery's bytes: sf.wildbits and its CR
DirEntLen           equ       $0020               an RBF directory entry's bytes (rbf.d DIR.SZ)
DirErrorLen         equ       $0015               MsgDirError's bytes
DirPromptLen        equ       $000A               MsgDirEditPrompt's bytes
DirReadMode         equ       $81                 I$Open's access mode for a directory: DIR. + READ.
DScrnText           equ       $0000               WbDScrnEnt's Y: 0 the text screen (else the flight screen's blocks)
EntryDirEnd         equ       $00                 NextSceneryEntry's A: 0 at the directory's end (also the open flag cleared)
EntryFound          equ       $FF                 NextSceneryEntry's A: an sf. entry was found (B its name's length)
ErrEndOfFile        equ       $D3                 OS-9 error E$EOF: end of file, the directory's last entry read
GotoXYBias          equ       $20                 VT_GOTOXY's column and row are sent plus $20
GotoXYLen           equ       $0003               a cursor move's bytes: VT_GOTOXY, the column, the row
KeyDefault          equ       $5F                 Shift+up ($5F, '_'): back to the default scenery file sf.wildbits
KeyDown             equ       $0A                 the down arrow ($0A): the selection one row down
KeyEnter            equ       $0D                 Enter ($0D): load the chosen file, or accept the edited directory
KeyF2               equ       $B2                 F2 ($B2 after fswc's KeyMap): leave the scenery menu
KeyLeft             equ       $08                 the left arrow and Backspace both send $08: edit the directory, delete a character
KeyUp               equ       $0C                 the up arrow ($0C): the selection one row up
ListBottomRow       equ       $0D                 the file list's last screen row
ListEndEntry        equ       $0000               the file list's end: an entry of two zero words (name pointer, length)
ListGotoCol         equ       $20                 the list arrow's column 0 as VT_GOTOXY takes it (+$20)
ListLineLen         equ       $0006               MsgListLine's bytes: CR LF, 3 spaces, erase to the line's end
ListRows            equ       $0B                 the file list's rows on screen (ListTopRow to ListBottomRow)
ListTopRow          equ       $03                 the file list's first screen row
NotCarry            equ       $FE                 the CC mask that clears the carry bit
OpenRead            equ       $01                 I$Open's access mode: read (READ.)
OrderNameLen        equ       8                   the names OrderSceneryList looks for, past sf.: 8 characters (wildbits, standard)
PathSep             equ       $2F                 '/': a path name's separator
PathSlashLen        equ       $0001               StrPathSlash's bytes
SceneryErrorLen     equ       $0017               MsgSceneryError's bytes
SceneryScreenLen    equ       $008E               MsgSceneryScreen's bytes (the title's CR LF added on the WildBits)
SfListMaxEnd        equ       $2070+((FswRecBuf-$2200)/29)*4 the file list's limit: vSfList + 4 bytes for each name (29 bytes at most) that fits from vSfNames below FswRecBuf
SfMenuTextMax       equ       FswRecBuf-$2200     the scenery's menu text's most bytes: vSfMenuText ($2200) up to fsw's RecBuf
SfNameLenInit       equ       $00                 the entry name's length before its first character is counted
SfPathMax           equ       $20                 vSceneryPath's most characters before its CR
SfPrefix            equ       $7366               sf: the first two characters of a scenery file's name
SfPrefixDot         equ       $2E                 the '.' after sf in a scenery file's name

tylg                set       $21
atrv                set       $80
size                equ       $0000
ModBase             equ       $4000               the address the module runs at

                    mod       eom,name,tylg,atrv,start,size
                    fcb       $00
name                fcs       /F3/
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
start               equ       *
                    jmp       >SceneryMenu+ModBase
                    fcc       /Copyright 1987 subLOGIC. All Rights Reserved./
* MsgSceneryScreen: Scenery-select screen ($8C bytes; $8E on WildBits): clear screen, cursor off, palettes, "Current Scenery File:" and "Scenery File Select  Exit:F2" titles, ends with cursor at row 1
MsgSceneryScreen    equ       *
* WildBits: no ESC $31 (CoCo palette) on the WildBits terminal: four $00 no-ops each, the same length
                    fcb       $0C,$05,$20,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00
                    fcc       /Current Scenery File:/
                    fcb       $02
                    fcc       / "--------------------------------/
                    fcb       $02
* WildBits: the 80-column screen does not wrap the 32 dashes, so the title gets its own line
                    fcc       / .--------------------------------/
                    fcb       $0D,$0A
                    fcc       /Scenery File Select     Ex/
                    fcc       /it:F2/
                    fcb       $02,$20,$21
* StrPathSlash: "/" written between the directory and the file name when the current path is shown
StrPathSlash               fcb       $2F
* StrDefaultScenery: Default scenery file name "sf.wildbits" + CR (12 bytes), restored by ResetSceneryName
StrDefaultScenery               fcc       /sf.wildbits/
                    fcb       $0D
* StrListArrow: "-->" selection arrow drawn at the start of the selected list row
StrListArrow               fcc       /-->/
* StrArrowBlank: Three spaces that erase the selection arrow
StrArrowBlank               fcc       /   /
* MsgDirEditPrompt: Directory-edit prompt (10 bytes): cursor to row 1, erase line, cursor on, palette change
MsgDirEditPrompt    equ       *
* WildBits: no ESC $31 (CoCo palette) on the WildBits terminal: four $00 no-ops each, the same length
                    fcb       $02,$20,$21,$04,$05,$21,$00,$00
                    fcb       $00,$00
* MsgListHome: Cursor-XY code to column 0 row 2, the line above the first file-list row
MsgListHome               fcb       $02,$20,$22
* MsgListLine: CR LF, 3 spaces, erase to end of line: starts each file-list row (6 bytes)
MsgListLine               fcb       $0D,$0A
                    fcc       /   /
                    fcb       $04
* MsgSceneryError: "Scenery File Error!" message at row 7 (23 bytes)
MsgSceneryError               fcb       $0C,$02
                    fcc       / 'Scenery File Error!/
* MsgDirError: "Directory Error !" message at row 7 (21 bytes)
MsgDirError               fcb       $0C,$02
                    fcc       / 'Directory Error !/
* SceneryMenu: Overlay entry (via jmp at offset $20): scenery file selector; shows text screen (SS.DScrn 0), lists sf.* files, loads the chosen one, returns to FS on F2
SceneryMenu               lda       >FsPath
                    ldy       #DScrnText
                    jsr       >WbDScrnEnt            WildBits SS.DScrn (fs_wb.asm)
                    nop
                    nop
                    clr       >vSfLoadErr
* SceneryMenuRestart: Restart the selector: clear dir-open flag, split the path at $0250 into directory ($2010) and file name ($2030), redraw
SceneryMenuRestart               clr       >vSfDirOpen
                    ldx       #vSceneryPath
                    stx       >vSceneryDirEnd
                    stx       >vSceneryNameEnd
* SplitPathLoop: F$PrsNam loop: $0057 = start of last path element, $0055 = end of path
SplitPathLoop               os9       F$PrsNam
                    blo       SplitPathCopyDir
                    ldu       >vSceneryNameEnd
                    stu       >vSceneryDirEnd
                    sty       >vSceneryNameEnd
                    tfr       y,x
                    bra       SplitPathLoop
* SplitPathCopyDir: Copy the directory part of $0250 to $2010, or "." when the path has no directory
SplitPathCopyDir               ldx       #vSceneryPath
                    ldy       #vSceneryDir
                    cmpx      >vSceneryDirEnd
                    bne       SplitPathDirLoop
                    lda       #CurDirDot
                    sta       ,y+
                    bra       SplitPathDirEnd
* SplitPathDirLoop: Copy directory characters up to the last element; drop a trailing "/"
SplitPathDirLoop               lda       ,x+
                    sta       ,y+
                    cmpx      >vSceneryDirEnd
                    bls       SplitPathDirLoop
                    cmpa      #PathSep
                    bne       SplitPathDirEnd
                    leay      -1,y
* SplitPathDirEnd: CR-terminate the directory buffer, save its end in $0057, then copy the file name
SplitPathDirEnd               lda       #ChrCR
                    sta       ,y
                    sty       >vSceneryDirEnd
                    ldy       #vSceneryName
* SplitPathNameLoop: Copy the file name element to $2030; its end goes to $0055
SplitPathNameLoop               lda       ,x+
                    sta       ,y+
                    cmpx      >vSceneryNameEnd
                    bls       SplitPathNameLoop
                    leay      -1,y
                    sty       >vSceneryNameEnd
                    pshs      a,x,y
                    lda       >FsPath
                    ldx       #MsgSceneryScreen+ModBase
                    ldy       #SceneryScreenLen   WildBits: the title's CR LF
                    os9       I$Write
                    puls      a,x,y
                    jsr       >PrintSceneryPath+ModBase
                    jsr       >ReadSceneryDir+ModBase
                    bhs       MenuShowList
                    pshs      a,x,y
                    lda       >FsPath
                    ldx       #MsgDirError+ModBase
                    ldy       #DirErrorLen
                    os9       I$Write
                    puls      a,x,y
* MenuDirErrWaitKey: After "Directory Error", wait for a key, then go to directory editing
MenuDirErrWaitKey               jsr       >FsPollKey
                    beq       MenuDirErrWaitKey
                    bra       MenuEditDirectory
* MenuShowList: Directory read OK: draw the file list from the top
MenuShowList               jsr       >ListDrawFromTop+ModBase
* MenuKeyLoop: Main selector key loop: down/up arrows move the cursor, Enter loads, left arrow edits directory, $5F default file, F2 exits
MenuKeyLoop               jsr       >FsPollKey
                    beq       MenuKeyLoop
                    cmpb      #KeyDown
                    bne       MenuKeyUp
                    jsr       >ListCursorDown+ModBase
                    bra       MenuKeyLoop
* MenuKeyUp: Key not down arrow: test up arrow ($0C)
MenuKeyUp               cmpb      #KeyUp
                    bne       MenuKeyEnter
                    jsr       >ListCursorUp+ModBase
                    bra       MenuKeyLoop
* MenuKeyEnter: Test Enter: index = row-3+top; if a file is there load it (LoadSceneryFile), set the error flag on failure
MenuKeyEnter               cmpb      #KeyEnter
                    bne       MenuKeyLeft
                    lda       >vMenuRow
                    suba      #ListTopRow
                    adda      >vSfListTop
                    cmpa      >vSfCount
                    bhs       MenuKeyLeft
                    tfr       a,b
                    clr       >vSfLoadErr
                    jsr       >FswSceneLoad          WildBits: the load, then the aircraft onto the scenery's runway
                    bhs       MenuAfterLoadWaitKey
                    pshs      a,x,y
                    lda       >FsPath
                    ldx       #MsgSceneryError+ModBase
                    ldy       #SceneryErrorLen
                    os9       I$Write
                    puls      a,x,y
                    inc       >vSfLoadErr
* MenuAfterLoadWaitKey: After a load attempt wait for a key: F2 exits, any other key restarts the selector
MenuAfterLoadWaitKey               jsr       >FsPollKey
                    beq       MenuAfterLoadWaitKey
                    cmpb      #KeyF2
                    beq       MenuExit
                    jmp       >SceneryMenuRestart+ModBase
* MenuKeyLeft: Test left arrow ($08): go to directory editing
MenuKeyLeft               cmpb      #KeyLeft
                    bne       MenuKeyDefault
* MenuEditDirectory: Redraw the screen, edit the directory line (EditDirectory), then restart the selector
MenuEditDirectory               pshs      a,x,y
                    lda       >FsPath
                    ldx       #MsgSceneryScreen+ModBase
                    ldy       #SceneryScreenLen   WildBits: the title's CR LF
                    os9       I$Write
                    puls      a,x,y
                    jsr       >EditDirectory+ModBase
                    jmp       >SceneryMenuRestart+ModBase
* MenuKeyDefault: Test $5F (probably shift+up arrow): reset to the default scenery file and restart
MenuKeyDefault               cmpb      #KeyDefault
                    bne       MenuKeyF2
                    jsr       >ResetSceneryName+ModBase
                    jmp       >SceneryMenuRestart+ModBase
* MenuKeyF2: Test F2 ($B2): exit, otherwise keep reading keys
MenuKeyF2               cmpb      #KeyF2
                    lbne      MenuKeyLoop
* MenuExit: Exit: if the last load failed show "Scenery File Error!" and stay in the selector
MenuExit               tst       >vSfLoadErr
                    beq       MenuReturnToFlight
                    pshs      a,x,y
                    lda       >FsPath
                    ldx       #MsgSceneryError+ModBase
                    ldy       #SceneryErrorLen
                    os9       I$Write
                    puls      a,x,y
* MenuExitErrWaitKey: Wait for a key after the exit-time scenery error, then restart
MenuExitErrWaitKey               jsr       >FsPollKey
                    beq       MenuExitErrWaitKey
                    jmp       >SceneryMenuRestart+ModBase
* MenuReturnToFlight: Restore the flight screen (SS.DScrn $0CCD), call FS redraw routines, clear $0221 (no overlay) and return
MenuReturnToFlight               lda       >FsPath
                    ldy       >WbScrBlks
                    jsr       >WbDScrnEnt            WildBits SS.DScrn (fs_wb.asm)
                    nop
                    nop
                    jsr       >FsTermReset
                    clr       >vOvlReq
                    jsr       >FsClearView
                    rts
* ListCursorDown: Move the selection down one row, scrolling the list when past row 13
ListCursorDown               jsr       >EraseListArrow+ModBase
                    lda       >vMenuRow
                    inca
                    cmpa      #ListBottomRow
                    bls       ListSetCursorRow
                    lda       >vSfListTop
                    inca
                    cmpa      >vSfCount
                    bne       ListScrollDownStore
                    deca
* ListScrollDownStore: Store the new top index ($00A3) and redraw with the cursor on row 13
ListScrollDownStore               sta       >vSfListTop
                    lda       #ListBottomRow
                    bra       ListRedrawAtRow
* ListSetCursorRow: Store cursor row $02B9 and draw the arrow there
ListSetCursorRow               sta       >vMenuRow
                    jsr       >DrawListArrow+ModBase
                    rts
* ListDrawFromTop: Top index 0, cursor row 3, redraw the list and arrow
ListDrawFromTop               clr       >vSfListTop
                    lda       #ListTopRow
* ListRedrawAtRow: Set cursor row from A, redraw the file list and the arrow
ListRedrawAtRow               sta       >vMenuRow
                    jsr       >DrawFileList+ModBase
                    jsr       >DrawListArrow+ModBase
                    rts
* ListCursorUp: Move the selection up one row, scrolling the list when above row 3
ListCursorUp               jsr       >EraseListArrow+ModBase
                    lda       >vMenuRow
                    deca
                    cmpa      #ListTopRow
                    bhs       ListSetCursorRow
                    lda       >vSfListTop
                    deca
                    bpl       ListScrollUpStore
                    lda       #ListTopRow
                    bra       ListSetCursorRow
* ListScrollUpStore: Store the decremented top index and redraw with the cursor on row 3
ListScrollUpStore               sta       >vSfListTop
                    lda       #ListTopRow
                    jmp       >ListRedrawAtRow+ModBase
* EraseListArrow: Erase the "-->" arrow on the current row
EraseListArrow               jsr       >GotoListRow+ModBase
                    pshs      a,x,y
                    lda       >FsPath
                    ldx       #StrArrowBlank+ModBase
                    ldy       #ArrowLen
                    os9       I$Write
                    puls      a,x,y
                    rts
* DrawListArrow: Draw the "-->" arrow on the current row
DrawListArrow               jsr       >GotoListRow+ModBase
                    pshs      a,x,y
                    lda       >FsPath
                    ldx       #StrListArrow+ModBase
                    ldy       #ArrowLen
                    os9       I$Write
                    puls      a,x,y
                    rts
* GotoListRow: Write a cursor-XY code ($02F8) for column 0, row $02B9
GotoListRow               lda       #ListGotoCol
                    sta       >vGotoCol
                    lda       >vMenuRow
                    adda      #GotoXYBias
                    sta       >vGotoRow
                    pshs      a,x,y
                    lda       >FsPath
                    ldx       #vGotoXY
                    ldy       #GotoXYLen
                    os9       I$Write
                    puls      a,x,y
                    rts
* BuildSceneryPath: Rebuild the full path at $0250 from directory $2010 and file name $2030 (32 chars max, CR-terminated)
BuildSceneryPath               ldy       #vSceneryPath
                    ldx       #vSceneryDir
                    ldb       #SfPathMax
                    ldu       ,x
                    cmpu      #CurDirDotCR
                    beq       BuildPathName
* BuildPathDirLoop: Copy directory characters, then append "/"
BuildPathDirLoop               lda       ,x+
                    sta       ,y+
                    decb
                    beq       BuildPathEnd
                    cmpx      >vSceneryDirEnd
                    blo       BuildPathDirLoop
                    lda       #PathSep
                    sta       ,y+
                    decb
                    beq       BuildPathEnd
* BuildPathName: Append the file name from $2030
BuildPathName               ldx       #vSceneryName
* BuildPathNameLoop: Copy file name characters up to $0055
BuildPathNameLoop               lda       ,x+
                    sta       ,y+
                    decb
                    beq       BuildPathEnd
                    cmpx      >vSceneryNameEnd
                    blo       BuildPathNameLoop
* BuildPathEnd: CR-terminate the path at $0250
BuildPathEnd               lda       #ChrCR
                    sta       ,y
                    rts
* ResetSceneryName: Set the path at $0250 to the default "sf.wildbits" and clear the error flag
ResetSceneryName               ldx       #StrDefaultScenery+ModBase
                    ldy       #vSceneryPath
                    ldb       #DefaultSfLen
* ResetSceneryLoop: Copy loop for the 12-byte default name
ResetSceneryLoop               lda       ,x+
                    sta       ,y+
                    decb
                    bne       ResetSceneryLoop
                    clr       >vSfLoadErr
                    rts
* DrawFileList: Draw 11 file-list rows starting at list index $00A3 (table $2070: name pointer, length)
DrawFileList               lda       #ListRows
                    sta       >vFileRowsLeft
                    pshs      a,x,y
                    lda       >FsPath
                    ldx       #MsgListHome+ModBase
                    ldy       #GotoXYLen
                    os9       I$Write
                    puls      a,x,y
                    clra
                    ldb       >vSfListTop
                    aslb
                    rola
                    aslb
                    rola
                    addd      #vSfList
                    tfr       d,u
* DrawFileListLoop: One row: start a new line, print the entry name if there is one
DrawFileListLoop               pshs      a,x,y
                    lda       >FsPath
                    ldx       #MsgListLine+ModBase
                    ldy       #ListLineLen
                    os9       I$Write
                    puls      a,x,y
                    ldx       ,u
                    beq       DrawFileListNext
                    ldx       ,u++
                    ldy       ,u++
                    pshs      u
                    lda       >FsPath
                    os9       I$Write
                    puls      u
* DrawFileListNext: Count down the 11 rows
DrawFileListNext               dec       >vFileRowsLeft
                    bne       DrawFileListLoop
                    rts
* EditDirectory: Line editor for the directory name at $2010; Enter accepts, left arrow deletes, $5F resets to default; returns carry clear
EditDirectory               pshs      a,x,y
                    lda       >FsPath
                    ldx       #MsgDirEditPrompt+ModBase
                    ldy       #DirPromptLen
                    os9       I$Write
                    puls      a,x,y
                    jsr       >PrintDirectory+ModBase
* EditDirKeyLoop: Wait for a key (FS key poll) keeping the cursor pointer in X
EditDirKeyLoop               pshs      x
* EditDirWaitKey: Key poll loop for the directory editor
EditDirWaitKey               jsr       >FsPollKey
                    beq       EditDirWaitKey
                    puls      x
                    cmpb      #KeyEnter
                    beq       EditDirAccept
                    cmpb      #KeyLeft
                    beq       EditDirBackspace
                    cmpb      #KeyDefault
                    beq       EditDirDefault
                    cmpb      #ChrSpace
                    blo       EditDirKeyLoop
                    cmpx      #vSceneryName
                    bhs       EditDirKeyLoop
                    stb       ,x+
                    ldb       #ChrCR
                    stb       ,x
                    bra       EditDirStoreEnd
* EditDirBackspace: Delete the last directory character (not past the buffer start)
EditDirBackspace               cmpx      #vSceneryDir
                    ble       EditDirKeyLoop
                    lda       #ChrCR
                    sta       ,-x
* EditDirStoreEnd: Save the new directory end in $0057 and redraw the edit line
EditDirStoreEnd               stx       >vSceneryDirEnd
                    bra       EditDirectory
* EditDirAccept: Enter: rebuild the full path from the edited directory, carry clear
EditDirAccept               jsr       >BuildSceneryPath+ModBase
                    andcc     #NotCarry
                    rts
* EditDirDefault: $5F: reset the path to the default scenery file, carry clear
EditDirDefault               jsr       >ResetSceneryName+ModBase
                    andcc     #NotCarry
                    rts
* PrintDirectory: Print the directory buffer $2010..($0057); returns X = end of directory
PrintDirectory               ldx       #vSceneryDir
                    ldd       >vSceneryDirEnd
                    subd      #vSceneryDir
                    tfr       d,y
                    lda       >FsPath
                    os9       I$Write
                    ldx       >vSceneryDirEnd
                    rts
* PrintSceneryPath: Print the current path as directory, "/", file name
PrintSceneryPath               jsr       >PrintDirectory+ModBase
                    pshs      a,x,y
                    lda       >FsPath
                    ldx       #StrPathSlash+ModBase
                    ldy       #PathSlashLen
                    os9       I$Write
                    puls      a,x,y
                    ldx       #vSceneryName
                    ldd       >vSceneryNameEnd
                    subd      #vSceneryName
                    tfr       d,y
                    os9       I$Write
                    rts
* ReadSceneryDir: Read the directory and build the list of sf.* files: table $2070 (pointer, length per entry, 100 max), names at $2200, count in $00A4; carry set on error
ReadSceneryDir               clr       >vSfCount
                    ldx       #vSfNames
                    ldu       #vSfList
                    pshs      u
                    clra
                    clrb
* ClearListTableLoop: Clear the file-list table $2070-$21FF
ClearListTableLoop               sta       ,u++
                    sta       ,u++
                    cmpu      #vSfNames
                    blo       ClearListTableLoop
                    puls      u
* ReadSceneryDirLoop: Fetch the next sf.* entry and add its name (without the "sf." prefix) to the table
ReadSceneryDirLoop               pshs      x,u
                    jsr       >NextSceneryEntry+ModBase
                    puls      x,u
                    blo       ReadSceneryDirExit
                    beq       ReadSceneryDirEnd
                    stx       ,u++
                    clra
                    std       ,u++
                    ldy       #vSfEntName
* CopyEntryNameLoop: Copy the entry name into name storage
CopyEntryNameLoop               lda       ,y+
                    sta       ,x+
                    decb
                    bne       CopyEntryNameLoop
                    inc       >vSfCount
                    cmpu      #SfListMaxEnd                   files whose names (29 bytes at most) stay below fsw's RecBuf (29)
                    blo       ReadSceneryDirLoop
* ReadSceneryDirEnd: Terminate the table with a zero entry
ReadSceneryDirEnd               lbra      OrderSceneryList    the zero entry, then the order
                    fcb       $12,$12,$12,$12     (LoadSceneryFile stays at F3LoadScenery)
* ReadSceneryDirExit: Return (carry set on a directory error)
ReadSceneryDirExit               rts
* NextSceneryEntry: Open the directory once (path $0CD7) and read 32-byte entries until one starts "sf."; A=$FF B=name length on a hit, A=0 at end of directory, carry set on error
NextSceneryEntry               tst       >vSfDirOpen
                    bne       NextEntryRead
                    lda       #DirReadMode
                    ldx       #vSceneryDir
                    os9       I$Open
                    blo       NextEntryError
                    sta       >vFilePath
                    inc       >vSfDirOpen
* NextEntryRead: Read the next 32-byte directory entry into $2050; EOF closes the directory
NextEntryRead               lda       >vFilePath
                    ldx       #vSfDirEnt
                    ldy       #DirEntLen
                    os9       I$Read
                    bhs       NextEntryCheck
                    cmpb      #ErrEndOfFile
                    bne       NextEntryError
                    bra       NextEntryEof
* NextEntryCheck: Accept the entry only when its name starts "sf."
NextEntryCheck               ldd       >F3DirEnt
                    cmpd      #SfPrefix
                    bne       NextEntryRead
                    lda       >F3DirEnt+2
                    cmpa      #SfPrefixDot
                    bne       NextEntryRead
                    ldx       #vSfEntName
                    ldb       #SfNameLenInit
* NextEntryNameLen: Count the name length after "sf." and clear the last character's high bit
NextEntryNameLen               lda       ,x+
                    incb
                    tsta
                    bpl       NextEntryNameLen
                    anda      #AsciiBits
                    sta       -1,x
                    lda       #EntryFound
                    andcc     #NotCarry
                    rts
* NextEntryEof: End of directory: close it, clear the open flag, A=0 carry clear
NextEntryEof               lda       >vFilePath
                    os9       I$Close
                    blo       NextEntryError
                    lda       #EntryDirEnd
                    sta       >vSfDirOpen
                    andcc     #NotCarry
                    rts
* NextEntryError: Error: close the directory, clear the open flag, carry set (B = error)
NextEntryError               pshs      b
                    lda       >vFilePath
                    os9       I$Close
                    puls      b
                    clr       >vSfDirOpen
                    orcc      #Carry
                    rts
* LoadSceneryFile: Load list entry B: put "sf."+name into the path, open it, check the $DD01 header, seek, read the block to $2200 and write it to the display path $0CD6; carry set on error
LoadSceneryFile               clra
                    rolb
                    rola
                    rolb
                    rola
                    addd      #vSfList
                    tfr       d,x
                    ldy       ,x++
                    ldd       ,x++
                    ldx       #vSceneryNameTail
* LoadSceneryNameLoop: Copy the selected name after "sf." in the file-name buffer
LoadSceneryNameLoop               lda       ,y+
                    sta       ,x+
                    decb
                    bne       LoadSceneryNameLoop
                    lda       #ChrCR
                    sta       ,x
                    stx       >vSceneryNameEnd
                    jsr       >BuildSceneryPath+ModBase
                    lda       #OpenRead
                    ldx       #vSceneryPath
                    os9       I$Open
                    blo       LoadSceneryFail
                    sta       >vFilePath
                    lda       >vFilePath
                    ldx       #vFileHdr
                    ldy       #DataHdrLen
                    os9       I$Read
                    ldd       >vSfMagic
                    cmpd      #DataFileMagic
                    bne       LoadSceneryClose
                    lda       >vFilePath
                    ldx       >vSfMenuOfs
                    ldu       >vSfMenuOfs+2
                    os9       I$Seek
                    blo       LoadSceneryClose
                    lda       >vFilePath
                    ldx       #vSfMenuText
                    ldy       >vSfMenuLen
                    cmpy      #SfMenuTextMax      WildBits: the menu text $350 bytes at most ($2200 up to fsw's
                    bls       lsf1@               RecBuf, which holds the frame's records while this runs)
                    ldy       #SfMenuTextMax
                    sty       >vSfMenuLen
lsf1@               os9       I$Read
                    blo       LoadSceneryClose
                    jsr       >FswScrub              WildBits: no CoCo palette escapes in the scenery's menu text
                    ldx       #vSfMenuText
                    ldy       >vSfMenuLen
                    os9       I$Write
                    blo       LoadSceneryClose
                    lda       >vFilePath
                    os9       I$Close
                    blo       LoadSceneryClose
                    andcc     #NotCarry
                    rts
* LoadSceneryClose: Error after the open: close the file and return carry set
LoadSceneryClose               pshs      b
                    lda       >vFilePath
                    os9       I$Close
                    puls      b
* LoadSceneryFail: Return carry set (open failed)
LoadSceneryFail               orcc      #Carry
                    rts
* OrderSceneryList: ReadSceneryDir's end: the table's zero entry, then sf.wildbits to the top of the list and
* sf.standard to the bottom, the others in directory order between them; carry clear
OrderSceneryList               ldx       #ListEndEntry
                    stx       ,u++
                    stx       ,u++
                    ldx       #StrWildbitsName+ModBase
                    bsr       FindSceneryEntry    U = its entry
                    bcs       OrderStandard
                    ldd       ,u
                    ldx       2,u
                    pshs      d,x
* OrderTopLoop: the entries above it down one
OrderTopLoop               cmpu      #vSfList
                    beq       OrderTopPut
                    ldd       -4,u
                    std       ,u
                    ldd       -2,u
                    std       2,u
                    leau      -4,u
                    bra       OrderTopLoop
OrderTopPut               puls      d,x
                    std       ,u
                    stx       2,u
OrderStandard               ldx       #StrStandardName+ModBase
                    bsr       FindSceneryEntry
                    bcs       OrderDone
                    ldd       ,u
                    ldx       2,u
                    pshs      d,x
* OrderEndLoop: the entries below it up one (the table ends at a zero name pointer)
OrderEndLoop               ldd       4,u
                    beq       OrderEndPut
                    std       ,u
                    ldd       6,u
                    std       2,u
                    leau      4,u
                    bra       OrderEndLoop
OrderEndPut               puls      d,x
                    std       ,u
                    stx       2,u
OrderDone               andcc     #NotCarry
                    rts
* FindSceneryEntry: U = the entry whose name is the 8 characters at X; carry set when there is none. X kept.
FindSceneryEntry               ldu       #vSfList
FindEntryLoop               ldy       ,u
                    beq       FindEntryNone
                    ldd       2,u
                    cmpd      #OrderNameLen
                    bne       FindEntryNext
                    pshs      x
                    ldb       #OrderNameLen
FindEntryCmp               lda       ,x+
                    cmpa      ,y+
                    bne       FindEntryMiss
                    decb
                    bne       FindEntryCmp
                    puls      x
                    andcc     #NotCarry
                    rts
FindEntryMiss               puls      x
FindEntryNext               leau      4,u
                    bra       FindEntryLoop
FindEntryNone               orcc      #Carry
                    rts
StrWildbitsName               fcc       /wildbits/
StrStandardName               fcc       /standard/
                    fcb       $00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00   WildBits: two bytes went to the title's CR LF, 14 to the menu text's bound

                    ifne      LoadSceneryFile+ModBase-F3LoadScenery
                    error     "fs_wb.d: F3LoadScenery"
                    endc

                    emod
eom                 equ       *
                    end
