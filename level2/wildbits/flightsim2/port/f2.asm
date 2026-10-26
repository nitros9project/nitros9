********************************************************************
* F2 - disassembled OS-9 module (byte-exact lwasm round trip)
* Flight Simulator II (subLOGIC, 1987), CoCo 3 OS-9 Level 2: disassembled from the byte listing ../f2.asm.
* An overlay FS maps at $4000 (F2, F3 and F4 share that window): absolute self-references are Lxxxx+ModBase.
* header: type/lang $21 attr/rev $80, exec offset $0020, data size $0000 (0), module size 8192 bytes
* Labels name the routines, branch points and data; ModBase+label is the run address. Data addressing is left numeric (offsets into the
* program's data area, <$xx = direct page). fcb lines inside code carry the decoded mnemonic as a comment
* where the assembler could not be made to reproduce the original encoding.

                    nam       F2
                    ttl       F2 (disassembly)

                    ifp1
                    use       defsfile
                    use       fs_wb.d
                    endc

* Constants: the values this module's instructions use, by name (fs_wb.d holds the addresses)
AdcCarryOnly        equ       $00                 adc's operand 0: only the carry added (the low byte's carry into the high byte)
AdfAreaBotRight     equ       $854C               the panel's ADF frequency area: bottom right (x $85, y $4C)
AdfAreaTopLeft      equ       $7040               the panel's ADF frequency area: top left (x $70, y $40)
AdfShownOn          equ       $01                 vAdfShown 1: F2 put the ADF on the panel (in NAV2's place)
AirspeedToKt        equ       $0200               vAirspeed (1/256 m/s) to AIRSPEED: x 512 / 65536, 2 per m/s (about knots)
Angle8ToDeg32       equ       45                  an 8-bit angle (1/256 turn) x it / 32: degrees (360/256 = 45/32)
AnglePerDegQ8       equ       $B60C               a degree as a 16-bit angle, x 256 (182.04): degrees to an angle
ArrowGotoCol        equ       $37                 the field arrow's column 23 as VT_GOTOXY takes it (+$20)
ArrowLen            equ       $0003               StrFieldArrow's and StrArrowErase's bytes
AsciiPastNine       equ       $3A                 ASCII '9' + 1: the digit keys end below it
AsciiSpace          equ       $20                 ASCII space
AsciiZero           equ       $30                 ASCII '0'
AtisTempBias        equ       $10                 half of 32: vAtisTempOfs made -16 to 15
AtisTempMask        equ       $1F                 the frame counter's (<$40) low 5 bits: a varying 0-31 for vAtisTempOfs
AttrOwnerRW         equ       $03                 I$Create's file attributes: owner read and write
CopyToSlot          equ       $01                 CopyModeRecord's A: 1 the settings record to the mode's slot (0 the slot to it)
CtlCenter           equ       $7FFF               a control's center in the editor: the signed position + 32767
DegPerTurn          equ       $0168               degrees in a turn: a 16-bit angle to degrees
DigitValMask        equ       $0F                 an ASCII digit's value bits (0-9)
DiskErrorLen        equ       $001F               MsgDiskError's bytes
DScrnText           equ       $0000               WbDScrnEnt's Y: 0 the text screen (else the flight screen's blocks)
EdDigitLastIx       equ       $05                 vEdDigits' last index (the 100,000s)
EdDigitShiftIx      equ       $04                 the digit shift's first source: the 10,000s (the 100,000s drop)
EdLastPage          equ       $03                 FIX MODE's last page
EdPages             equ       $04                 FIX MODE's pages (numbered from 0)
EdPosBias           equ       $4000               NORTH and EAST POSITION: the map square + $4000
EdPosBiasHi         equ       $40                 EdPosBias's high byte
EdScreenInitLen     equ       $000F               StrEditorScreenInit's bytes
EdShiftBack         equ       $02                 the digit shift's step back: the incb undone and the next lower digit (vEdDigits[b] to [b+1])
EdValueWidth        equ       $0006               a value's characters on screen and the most digits typed
ErrNumGotoCol       equ       $2C                 the error number's column 12 (after "Disk Error #") as VT_GOTOXY takes it
ErrNumGotoRow       equ       $2C                 the error number's row 12 as VT_GOTOXY takes it
FileLineLen         equ       $0024               vEdFileLine's bytes: the cursor move, the name, its CR
FileNameLastIx      equ       $1F                 vEdFileName's last index (32 characters)
FirstRow            equ       $01                 a page's first field row
FirstUserMode       equ       $0A                 the first user mode: modes 0-9 are built in (TblBuiltinModes)
FtPerMQ14           equ       $D1EB               feet per meter in 1/16384 (3.2800): ALTITUDE's m to ft
FtPerMQ8            equ       $0348               feet per meter in 1/256 (3.28125): m to ft
GndGreen            equ       $BB                 the ground's green: FS's color 11 in both nibbles
GndHeightFt         equ       $0009               the aircraft's height on the ground (3 m) in ft, left out of ALTITUDE
GndSnow             equ       $FF                 winter's ground: white, FS's color 15 in both nibbles
GotoXYBias          equ       $20                 VT_GOTOXY's column and row are sent plus $20
GotoXYLen           equ       $0003               vGotoXY's bytes: VT_GOTOXY, the column, the row
HeightSetFrames     equ       $14                 frames SetHeightFromTerrain sets the height after the editor ($07F2 counts them)
InstNav2            equ       $08                 <$ED's bit 3: the NAV2 indicator shown (the ADF's place when ADF ENABLE)
InstReadouts        equ       $80                 the instrument masks' bit 7 (<$EC, $0345): the radio, clock, DME and engine switch readouts
JoyModes            equ       $03                 JOYSTICK ENABLE's settings 0-2; 3 and up stored as 0
KeyDown             equ       $0A                 the down arrow ($0A): the next field
KeyEnter            equ       $0D                 Enter ($0D): the value done
KeyF1               equ       $B1                 F1 ($B1 after fswc's KeyMap): the editor left
KeyLeft             equ       $08                 the left arrow and Backspace both send $08 (SS.KySns's KsLeft tells them apart)
KeyLoadLib          equ       $18                 Shift+left ($18): a mode library loaded from disk
KeyMinus            equ       $2D                 '-': the previous field, as the up arrow
KeyRevert           equ       $5F                 '_': the current mode reloaded, the edits dropped
KeySaveLib          equ       $1A                 Shift+down ($1A): the mode library saved to disk
KeySaveMode         equ       $13                 Ctrl+up ($13): the settings saved as a user mode
KeyUp               equ       $0C                 the up arrow ($0C): the previous field
KtHundredsStart     equ       $FFFF               the wind's knots word before the divide by 100: its hundreds byte at -1 (the loop's first inc makes 0)
KtToAirspeed        equ       $7FFF               AIRSPEED to vAirspeed (1/256 m/s): x 32767 / 256, 128 a unit
LibBytes            equ       $03CF               the mode library's bytes: 15 user modes of 65
LibPromptLen        equ       $0021               StrLoadLibPrompt's and StrSaveLibPrompt's bytes
LibSave             equ       $01                 LoadSaveLibrary's A: 1 save the library (0 load)
ModeDemo            equ       $02                 mode 2: the demo
ModeEurope1917      equ       $07                 mode 7: Europe 1917 (the WWI game, CMDS/f4)
ModeRecLastIx       equ       $40                 a mode record's last index: the copy runs from it to 0
ModeRecLen          equ       $41                 a mode record's bytes
MPerFtQ16           equ       $4E07               meters per foot in 1/65536 (0.3048): ft to m
MPerFtQ16Fs         equ       $4E0C               meters per foot in 1/65536 as FS's SetHeightFromTerrain takes it (0.30487)
OpenUpdate          equ       $03                 I$Open's access mode: read and write (UPDAT.)
OpenWrite           equ       $02                 I$Create's access mode: write (WRITE.)
OvlF4               equ       $03                 vOvlReq 3: CMDS/f4, the Europe 1917 game
PageTextLenOfs      equ       $02                 a TblPageText entry's length word, after its text pointer
PanelBlank          equ       $00                 SetFillColor's color 0: the ADF area cleared to the panel's background
ScaledAltCount      equ       $07                 vScaledAlts' words
SeasonWinter        equ       1                   vSeason 1: winter (SeasonGnd's white ground)
SeekFileStart       equ       $0000               I$Seek's position (X high word, U low word from it): 0, the file's start
UnitsToEditor       equ       $0000               ConvertWindTables' Y: 0 the sim's units to the editor's
UnitsToSim          equ       $0001               ConvertWindTables' Y: 1 the editor's units back to the sim's
UserModeRow         equ       $01                 page 1's USER MODE row
UserModeSave        equ       $6E                 USER MODE 110 and up: the settings saved into mode n-100
UserModeSaveEnd     equ       $D2                 USER MODE 210 and up: refused (the saves run 110-209)
UserModeSaveOfs     equ       $64                 a save number less this is the mode it saves into
ValueCol            equ       $1A                 the field value's column
ValueGotoCol        equ       $3A                 the value's column 26 as VT_GOTOXY takes it (+$20)
WindKtBase          equ       $64                 a wind's knots in two bytes: the rest of 100, the hundreds
WindSfcDirHalf      equ       28                  half of WindSfcDirRange: the surface wind within +-28/256 turn (40 degrees) of vStartHdg
WindSfcDirRange     equ       57                  the surface wind's random directions (1/256 turn): WrRnd's 0-56, less WindSfcDirHalf
WrRndAdd            equ       13849               WrRnd's increment: added to the seed x WrRndMul
WrRndMul            equ       25173               WrRnd's multiplier: the seed x it + WrRndAdd (a linear congruential generator)

tylg                set       $21
atrv                set       $80
size                equ       $0000
ModBase             equ       $4000               the address the module runs at

                    mod       eom,name,tylg,atrv,start,size
                    fcb       $00
name                fcs       /F2/
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
start               equ       *
                    jmp       >EditorEntry+ModBase
                    fcc       /Copyright 1987 subLOGIC. All Rights Reserved./
* TblPageText: Editor page table: 4 entries (text pointer, length) for FIX MODE pages 1-4; the page strings follow it
TblPageText         fdb       Page1Text+ModBase,Page2Text-Page1Text,Page2Text+ModBase,Page3Text-Page2Text
                    fdb       Page3Text+ModBase,Page4Text-Page3Text,Page4Text+ModBase,StrEditorScreenInit-Page4Text
Page1Text           fcb       $0C,$05
                    fcc       / SIMULATION CONTROL:/
                    fcb       $0D,$0A
                    fcc       / USER MODE  - - - - -/
                    fcb       $0D,$0A
                    fcc       / AUTO-COORDINATION  -/
                    fcb       $0D,$0A
                    fcc       / SLEW   - - - - - - -/
                    fcb       $0D,$0A
                    fcc       / REALITY MODE   - - -/
                    fcb       $0D,$0A
                    fcc       / EUROPE 1917  - - - -/
                    fcb       $0D,$0A
                    fcc       / COMMUNICATION RATE -/
                    fcb       $0D,$0A
                    fcc       / RELIABILITY FACTOR/
                    fcb       $0D,$0A
                    fcc       / OVER-CONTROL LIMITER/
                    fcb       $0D,$0A
                    fcc       / ADF ENABLE - - - - -/
                    fcb       $0D,$0A
                    fcc       / JOYSTICK ENABLE  - -/
* WildBits: smart taxi (fsw's TxSmart: 1 taxi mode, 0 FS's own ground handling)
                    fcb       $0D,$0A
                    fcc       / SMART TAXI - - - - -/
* WildBits: the clouds (vClouds bit 0, F7 / Alt+C) and the K2's ground (fsw's GdOn, F8: the clouds' shadows and the
* meadow near the airports, fscl GdRun): 1 on, 0 off
                    fcb       $0D,$0A
                    fcc       / CLOUDS RENDER MODE -/
                    fcb       $0D,$0A
                    fcc       / GROUND TEXTURE - - -/
                    fcb       $02
                    fcc       / .--------------------------------/
                    fcb       $0D,$0A
                    fcc       /CC-FS2 FIX MODE  PAGE 1 EX/
                    fcc       /IT:F1/
Page2Text           fcb       $0C,$05
                    fcc       / AIRCRAFT POSITION:/
                    fcb       $0D,$0A
                    fcc       / NORTH POSITION - - -/
                    fcb       $0D,$0A
                    fcc       / EAST POSITION  - - -/
                    fcb       $0D,$0A
                    fcc       / ALTITUDE - - - - - -/
                    fcb       $0D,$0A
                    fcc       / PITCH  - - - - - - -/
                    fcb       $0D,$0A
                    fcc       / BANK - - - - - - - -/
                    fcb       $0D,$0A
                    fcc       / HEADING  - - - - - -/
                    fcb       $0D,$0A
                    fcc       / AIRSPEED - - - - - -/
                    fcb       $0D,$0A
                    fcc       / THROTTLE - - - - - -/
                    fcb       $0D,$0A
                    fcc       / RUDDER - - - - - - -/
                    fcb       $0D,$0A
                    fcc       / AILERONS - - - - - -/
                    fcb       $0D,$0A
                    fcc       / FLAPS  - - - - - - -/
                    fcb       $0D,$0A
                    fcc       / ELEVATORS  - - - - -/
                    fcb       $02
                    fcc       / .--------------------------------/
                    fcb       $0D,$0A
                    fcc       /CC-FS2 FIX MODE  PAGE 2 EX/
                    fcc       /IT:F1/
Page3Text           fcb       $0C,$05
                    fcc       / ENVIRONMENTAL CONTROL A:/
                    fcb       $0D,$0A
                    fcc       /  TIME: HOURS  - - - -/
                    fcb       $0D,$0A
                    fcc       /        MINUTES  - - -/
                    fcb       $0D,$0A
                    fcc       /  SEASON/
                    fcb       $0D,$0A
                    fcc       /  CLOUD LAYER 2 TOPS/
                    fcb       $0D,$0A
                    fcc       /  CLOUD LAYER 2 BOTTOMS/
                    fcb       $0D,$0A
                    fcc       /  CLOUD LAYER 1 TOPS/
                    fcb       $0D,$0A
                    fcc       /  CLOUD LAYER 1 BOTTOMS/
                    fcb       $02
                    fcc       / .--------------------------------/
                    fcb       $0D,$0A
                    fcc       /CC-FS2 FIX MODE  PAGE 3 EX/
                    fcc       /IT:F1/
Page4Text           fcb       $0C,$05
                    fcc       / ENVIRONMENTAL CONTROL B:/
                    fcb       $0D,$0A
                    fcc       / WIND LEVEL 3: KNOTS/
                    fcb       $0D,$0A
                    fcc       /               DEGREES/
                    fcb       $0D,$0A
                    fcc       / SHEAR ZONE ALTITUDE 3/
                    fcb       $0D,$0A
                    fcc       / WIND LEVEL 2: KNOTS/
                    fcb       $0D,$0A
                    fcc       /               DEGREES/
                    fcb       $0D,$0A
                    fcc       / SHEAR ZONE ALTITUDE 2/
                    fcb       $0D,$0A
                    fcc       / WIND LEVEL 1: KNOTS/
                    fcb       $0D,$0A
                    fcc       /               DEGREES/
                    fcb       $0D,$0A
                    fcc       / SHEAR ZONE ALTITUDE 1/
                    fcb       $0D,$0A
                    fcc       / SURFACE WIND: KNOTS/
                    fcb       $0D,$0A
                    fcc       /               DEGREES/
                    fcb       $02
                    fcc       / .--------------------------------/
                    fcb       $0D,$0A
                    fcc       /CC-FS2 FIX MODE  PAGE 4 EX/
                    fcc       /IT:F1/
* StrEditorScreenInit: 15-byte screen setup sent on entry: cursor off, clear screen, three palette (ESC $31) settings
StrEditorScreenInit equ       *
* WildBits: no ESC $31 (CoCo palette) on the WildBits terminal: four $00 no-ops each, the same length
                    fcb       $05,$20,$0C,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00
* StrFieldArrow: "-->" field cursor arrow
StrFieldArrow               fcc       /-->/
* StrArrowErase: 3 spaces that erase the field cursor arrow
StrArrowErase               fcc       /   /
* MsgDiskError: "Disk Error #" and "Press any key" with cursor-position codes (31 bytes)
MsgDiskError               fcb       $02
                    fcc       / ,Disk Error #/
                    fcb       $02,$28,$2F
                    fcc       /Press any key/
* StrSaveLibPrompt: Clear screen + "Save Mode Library Filename:" prompt (33 bytes)
StrSaveLibPrompt               fcb       $0C,$02
                    fcc       / (Save Mode Library Filename:/
                    fcb       $0D,$0A
* StrLoadLibPrompt: Clear screen + "Load Mode Library Filename:" prompt (33 bytes)
StrLoadLibPrompt               fcb       $0C,$02
                    fcc       / (Load Mode Library Filename:/
                    fcb       $0D,$0A
* TblPow10: 24-bit powers of ten 1,10,100,1000,10000 (3 bytes each) for decimal entry and display
TblPow10               fcb       $00,$00,$01,$00,$00,$0A,$00,$00
                    fcb       $64,$00,$03,$E8,$00,$27,$10
* TblPow10Top: 24-bit 100000, top entry of TblPow10 where decimal printing starts
TblPow10Top               fcb       $01,$86,$A0
* TblPageFields: 4 pointers to per-page field lists, then the lists: 4-byte entries (size 1-3, row, variable address), 0-terminated
TblPageFields       fdb       Page1Fields+ModBase,Page2Fields+ModBase,Page3Fields+ModBase,Page4Fields+ModBase
Page1Fields         fcb       $01,$01,$03,$43,$01,$02,$03,$03
                    fcb       $01,$03,$03,$04,$01,$04,$03,$05
                    fcb       $01,$05,$03,$07,$01,$06,$03,$08
                    fcb       $01,$07,$03,$42,$01,$08,$03,$47
                    fcb       $01,$09,$03,$48,$01,$0A,$08,$8D
                    fcb       $01,$0B
                    fdb       FswTxSmart          WildBits: SMART TAXI
                    fcb       $01,$0C
                    fdb       vClouds+1           WildBits: CLOUDS RENDER MODE
                    fcb       $01,$0D
                    fdb       FswGdOn             WildBits: GROUND TEXTURE
                    fcb       $00
Page2Fields         fcb       $02,$01,$03,$09,$02,$02,$03
                    fcb       $0B,$02,$03,$03,$0D,$02,$04,$03
                    fcb       $0F,$02,$05,$03,$11,$02,$06,$03
                    fcb       $13,$02,$07,$03,$15,$02,$08,$03
                    fcb       $17,$02,$09,$03,$19,$02,$0A,$03
                    fcb       $1B,$02,$0B,$03,$1D,$02,$0C,$03
                    fcb       $1F,$00
Page3Fields         fcb       $01,$01,$03,$21,$01,$02
                    fcb       $03,$22,$01,$03,$03,$23,$02,$04
                    fcb       $03,$24,$02,$05,$03,$26,$02,$06
                    fcb       $03,$28,$02,$07,$03,$2A,$00
Page4Fields         fcb       $02
                    fcb       $01,$03,$32,$02,$02,$03,$34,$02
                    fcb       $03,$03,$30,$02,$04,$03,$36,$02
                    fcb       $05,$03,$38,$02,$06,$03,$2E,$02
                    fcb       $07,$03,$3A,$02,$08,$03,$3C,$02
                    fcb       $09,$03,$2C,$02,$0A,$03,$3E,$02
                    fcb       $0B,$03,$40,$00
* EditorEntry: F2 exec entry: set up screen, import sim state, then by $020C run the FIX MODE editor or a mode load/save and exit
EditorEntry               lda       >FsPath
                    ldy       #DScrnText
                    jsr       >WbDScrnEnt            WildBits SS.DScrn (fs_wb.asm)
                    nop
                    nop
                    pshs      a,x,y
                    lda       >FsPath
                    ldx       #StrEditorScreenInit+ModBase
                    ldy       #EdScreenInitLen
                    os9       I$Write
                    puls      a,x,y
                    jsr       >ImportSimState+ModBase
                    jsr       >ShowFirstPage+ModBase
                    lda       >vLoadKind
                    beq       EditorLoop
                    deca
                    bne       EditorEntryMode2
                    jsr       >LoadModeSlot+ModBase
                    bra       EditorExit
* EditorEntryMode2: $020C=2: save current settings as a user mode, then exit
EditorEntryMode2               deca
                    bne       EditorEntryMode3
                    jsr       >SaveUserMode+ModBase
                    bra       EditorExit
* EditorEntryMode3: $020C=3: load mode 2 and exit
EditorEntryMode3               lda       #ModeDemo
                    sta       >vModeNum
                    jsr       >LoadModeSlot+ModBase
                    bra       EditorExit
* EditorLoop: Editor main loop: edit the current field, store it, act on navigation flags
EditorLoop               jsr       >EditField+ModBase
                    tst       >vEdTyped
                    beq       EditorLoopCheckExit
                    jsr       >StoreFieldAndMode+ModBase
                    lda       >vMenuPage
                    bne       EditorLoopCheckExit
                    lda       >vMenuRow
                    cmpa      #UserModeRow
                    bne       EditorLoopCheckExit
                    lda       >vEdExit
                    bne       EditorExit
                    bra       EditorLoop
* EditorLoopCheckExit: Exit if F1 was pressed, else handle page/field navigation
EditorLoopCheckExit               lda       >vEdExit
                    beq       EditorLoopPageNav
* EditorExit: Leave the editor: apply settings to the simulation (ApplyEditsAndExit)
EditorExit               jmp       >ApplyEditsAndExit+ModBase
* EditorLoopPageNav: Left/right arrow page change requested (vEdPage not 0)
EditorLoopPageNav               tst       >vEdPage
                    beq       EditorLoopFieldNav
                    bmi       EditorLoopPrevPage
                    jsr       >ShowNextPage+ModBase
                    bra       EditorLoop
* EditorLoopPrevPage: Go to the previous page
EditorLoopPrevPage               jsr       >ShowPrevPage+ModBase
                    bra       EditorLoop
* EditorLoopFieldNav: Up (flag $02B5) or down field movement
EditorLoopFieldNav               lda       >vEdUp
                    beq       EditorLoopNextField
                    clr       >vEdUp
                    jsr       >CursorPrevField+ModBase
                    bra       EditorLoop
* EditorLoopNextField: Move to the next field
EditorLoopNextField               jsr       >CursorNextField+ModBase
                    bra       EditorLoop
* CursorNextField: Move the arrow to the next field; past the last field go to the next page
CursorNextField               jsr       >EraseArrow+ModBase
                    lda       >vMenuRow
                    inca
                    cmpa      >vMenuRows
                    bls       SelectRowA
* ShowNextPage: Advance to the next editor page (wraps 3 to 0), draw it and select row 1
ShowNextPage               lda       >vMenuPage
                    inca
                    cmpa      #EdPages
                    bne       ShowPageA
* ShowFirstPage: Draw editor page 0 (text and values) and select row 1
ShowFirstPage               clra
* ShowPageA: Set page number from A, draw page text and values, select row 1
ShowPageA               sta       >vMenuPage
                    jsr       >ShowPageText+ModBase
                    jsr       >ShowPageValues+ModBase
                    lda       #FirstRow
* SelectRowA: Set current row ($02B9) from A and draw the arrow there
SelectRowA               sta       >vMenuRow
                    jsr       >DrawArrow+ModBase
                    rts
* CursorPrevField: Move the arrow to the previous field; above row 1 go to the last field of the previous page
CursorPrevField               jsr       >EraseArrow+ModBase
                    lda       >vMenuRow
                    deca
                    bne       SelectRowA
* ShowPrevPage: Go back one editor page (wraps 0 to 3), draw it and select its last row
ShowPrevPage               lda       >vMenuPage
                    deca
                    bpl       ShowPrevPageSet
                    lda       #EdLastPage
* ShowPrevPageSet: Store the previous page number and draw that page
ShowPrevPageSet               sta       >vMenuPage
                    jsr       >ShowPageText+ModBase
                    jsr       >ShowPageValues+ModBase
                    lda       >vMenuRows
                    jmp       >SelectRowA+ModBase
* EraseArrow: Erase the field arrow on the current row
EraseArrow               jsr       >GotoArrowColumn+ModBase
                    pshs      a,x,y
                    lda       >FsPath
                    ldx       #StrArrowErase+ModBase
                    ldy       #ArrowLen
                    os9       I$Write
                    puls      a,x,y
                    rts
* DrawArrow: Draw "-->" on the current row
DrawArrow               jsr       >GotoArrowColumn+ModBase
                    pshs      a,x,y
                    lda       >FsPath
                    ldx       #StrFieldArrow+ModBase
                    ldy       #ArrowLen
                    os9       I$Write
                    puls      a,x,y
                    rts
* GotoArrowColumn: Send cursor-goto (column 23, current row) to the screen
GotoArrowColumn               lda       #ArrowGotoCol
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
* GotoValueColumn: Send cursor-goto (column 26, current row) to the screen
GotoValueColumn               lda       #ValueGotoCol
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
* EditField: Read keys and edit the current field decimal value; handles navigation, F1, revert, save mode, library load/save
EditField               clr       >vEdTyped
                    jsr       >GotoValueColumn+ModBase
                    clra
                    sta       >vEdDigits
                    sta       >vEdExit
                    sta       >vEdTextLen
                    sta       >vEdPage
                    ldb       #EdDigitLastIx
                    lda       #AsciiZero
                    ldx       #vEdDigitBuf
* EditFieldClearDigits: Fill the 6-digit buffer $02BE with '0'
EditFieldClearDigits               sta       b,x
                    decb
                    bpl       EditFieldClearDigits
* EditFieldKeyLoop: Wait for a key (FS $A6D2) and dispatch it
EditFieldKeyLoop               jsr       >FsPollKey
                    beq       EditFieldKeyLoop
                    tfr       b,a
                    cmpa      #KeyEnter
                    beq       EditFieldDone
                    cmpa      #KeyDown
                    beq       EditFieldDone
                    cmpa      #KeyMinus
                    beq       EditFieldUpKey
                    cmpa      #KeyUp
                    bne       EditFieldChkF1
* EditFieldUpKey: '-' or up arrow: flag move to the previous field
EditFieldUpKey               sta       >vEdUp
                    bra       EditFieldDone
* EditFieldChkF1: Check for F1 (exit editor)
EditFieldChkF1               cmpa      #KeyF1
                    bne       EditFieldChkBack
                    inc       >vEdExit
* EditFieldDone: Convert the typed digits to binary ($02B6-$02B8) and return
EditFieldDone               jsr       >DigitsToBinary+ModBase
                    rts
* EditFieldChkBack: $08: the left arrow goes to the previous page, a value typed stored first (EditFieldDone, then
* EditorLoop's StoreFieldAndMode); Backspace (the same $08, without SS.KySns's left-arrow bit) deletes the last digit
EditFieldChkBack               cmpa      #KeyLeft
                    bne       EditFieldChkRight
                    tst       >vEdTyped
                    beq       EditFieldPrevPage
                    lda       >FsKeyPath
                    ldb       #SS.KySns
                    os9       I$GetStt
                    bcs       EditFieldBackspace
                    bita      #KsLeft
                    beq       EditFieldBackspace
* EditFieldPrevPage: ask for the previous page
EditFieldPrevPage               dec       >vEdPage
                    bra       EditFieldDone
* EditFieldBackspace: Delete the last typed digit and redraw the value
EditFieldBackspace               lda       >vEdDigits
                    lbeq      EditFieldKeyLoop
                    dec       >vEdDigits
                    lda       #AsciiSpace
                    dec       >vEdTextLen
                    ldb       >vEdTextLen
                    ldy       #vEdValueText
                    sta       b,y
                    ldy       #vEdDigitBuf
* EditFieldShiftDigits: Shift the digit buffer down one place
EditFieldShiftDigits               lda       1,y
                    sta       ,y+
                    cmpy      #vEdDigitTop
                    bne       EditFieldShiftDigits
                    lda       #AsciiZero
                    sta       ,y
                    jsr       >GotoValueColumn+ModBase
                    pshs      a,x,y
                    lda       >FsPath
                    ldx       #vEdValueText
                    ldy       #EdValueWidth
                    os9       I$Write
                    puls      a,x,y
                    jsr       >GotoValueColumn+ModBase
                    lbra      EditFieldNextKey
* EditFieldChkRight: Right arrow (or Tab): the next page, a value typed stored first (it was ignored once a digit
* was typed)
EditFieldChkRight               cmpa      #KEY_TAB
                    bne       EditFieldChkRevert
                    inc       >vEdPage
                    bra       EditFieldDone
* EditFieldChkRevert: '_': reload the current mode (discard edits)
EditFieldChkRevert               cmpa      #KeyRevert
                    bne       EditFieldChkSave
                    jsr       >ReloadModeRedraw+ModBase
                    jmp       >EditField+ModBase
* EditFieldChkSave: Key $13: save current settings as a user mode
EditFieldChkSave               cmpa      #KeySaveMode
                    bne       EditFieldChkLoadLib
                    jsr       >SaveUserMode+ModBase
                    jmp       >EditField+ModBase
* EditFieldChkLoadLib: Key $18: load a mode library from disk
EditFieldChkLoadLib               cmpa      #KeyLoadLib
                    bne       EditFieldChkSaveLib
                    pshs      a,x,y
                    lda       >FsPath
                    ldx       #StrLoadLibPrompt+ModBase
                    ldy       #LibPromptLen
                    os9       I$Write
                    puls      a,x,y
                    jsr       >InputFilename+ModBase
                    beq       EditFieldRedraw
                    clra
                    jsr       >LoadSaveLibrary+ModBase
                    blo       ShowDiskError
                    lda       >vMenuRow
                    pshs      a
                    jsr       >LoadModeSlot+ModBase
                    jsr       >ShowPageValues+ModBase
                    puls      a
                    sta       >vMenuRow
                    bra       EditFieldRedraw
* ShowDiskError: Print "Disk Error #" with error B, wait for a key
ShowDiskError               stb       >vEdValue+2
                    pshs      a,x,y
                    lda       >FsPath
                    ldx       #MsgDiskError+ModBase
                    ldy       #DiskErrorLen
                    os9       I$Write
                    puls      a,x,y
                    clr       >vEdValue
                    clr       >vEdValue+1
                    lda       #ErrNumGotoCol
                    sta       >vGotoCol
                    lda       #ErrNumGotoRow
                    sta       >vGotoRow
                    jsr       >PrintDecimal24+ModBase
* ShowDiskErrorWait: Wait for any key after a disk error
ShowDiskErrorWait               jsr       >FsPollKey
                    beq       ShowDiskErrorWait
                    bra       EditFieldRedraw
* EditFieldChkSaveLib: Key $1A: save the mode library to disk
EditFieldChkSaveLib               cmpa      #KeySaveLib
                    bne       EditFieldChkDigit
                    pshs      a,x,y
                    lda       >FsPath
                    ldx       #StrSaveLibPrompt+ModBase
                    ldy       #LibPromptLen
                    os9       I$Write
                    puls      a,x,y
                    jsr       >InputFilename+ModBase
                    beq       EditFieldRedraw
                    lda       #LibSave
                    jsr       >LoadSaveLibrary+ModBase
                    blo       ShowDiskError
* EditFieldRedraw: Redraw page 0 and restart field editing
EditFieldRedraw               jsr       >ShowFirstPage+ModBase
                    jmp       >EditField+ModBase
* EditFieldChkDigit: Accept only digits '0'-'9'
EditFieldChkDigit               cmpa      #AsciiZero
                    bhs       EditFieldDigit
* EditFieldNextKey: Go back for the next key
EditFieldNextKey               jmp       >EditFieldKeyLoop+ModBase
* EditFieldDigit: Append a digit to the field (max 6), blanking the old value on the first digit
EditFieldDigit               cmpa      #AsciiPastNine
                    bhs       EditFieldNextKey
                    ldb       >vEdTextLen
                    cmpb      #EdValueWidth
                    beq       EditFieldNextKey
                    inc       >vEdTyped
                    sta       <vEdKeyDigit
                    lda       >vEdDigits
                    bne       EditFieldInsertDigit
                    ldy       #vEdValueText
                    clrb
                    lda       #AsciiSpace
* EditFieldBlankLoop: Fill the 6-character display buffer $02FB with spaces
EditFieldBlankLoop               sta       b,y
                    incb
                    cmpb      #EdValueWidth
                    bne       EditFieldBlankLoop
                    pshs      a,x,y
                    lda       >FsPath
                    ldx       #vEdValueText
                    ldy       #EdValueWidth
                    os9       I$Write
                    puls      a,x,y
* EditFieldInsertDigit: Shift the digit buffer up and insert the new digit
EditFieldInsertDigit               ldb       #EdDigitShiftIx
                    ldx       #vEdDigitBuf
* EditFieldInsertLoop: Digit-buffer shift loop
EditFieldInsertLoop               lda       b,x
                    incb
                    sta       b,x
                    subb      #EdShiftBack
                    bpl       EditFieldInsertLoop
                    lda       <vEdKeyDigit
                    sta       >vEdDigitBuf
                    inc       >vEdDigits
                    ldb       >vEdTextLen
                    ldy       #vEdValueText
                    sta       b,y
                    incb
                    stb       >vEdTextLen
                    jsr       >GotoValueColumn+ModBase
                    pshs      a,x,y
                    lda       >FsPath
                    ldx       #vEdValueText
                    ldy       #EdValueWidth
                    os9       I$Write
                    puls      a,x,y
                    jmp       >EditFieldNextKey+ModBase
* InputFilename: Read a filename into $02D7 with echo; returns D = length (Z if empty)
InputFilename               ldx       #vEdFileName
                    ldb       #FileNameLastIx
* InputFilenameClear: Blank the 32-byte filename buffer
InputFilenameClear               lda       #AsciiSpace
                    sta       b,x
                    decb
                    bpl       InputFilenameClear
* InputFilenameLoop: Get the next key
InputFilenameLoop               pshs      x
* InputFilenameWait: Wait for a key (FS $A6D2)
InputFilenameWait               jsr       >FsPollKey
                    beq       InputFilenameWait
                    puls      x
                    cmpb      #KeyEnter
                    beq       InputFilenameDone
                    cmpb      #KeyLeft
                    beq       InputFilenameBack
                    cmpx      #vEdFileNameEnd
                    bhs       InputFilenameLoop
                    stb       ,x+
                    bra       InputFilenameEcho
* InputFilenameBack: Backspace: remove the last character
InputFilenameBack               cmpx      #vEdFileName
                    ble       InputFilenameLoop
                    lda       #AsciiSpace
                    sta       ,-x
* InputFilenameEcho: Redraw the filename line ($02D4, 36 bytes)
InputFilenameEcho               pshs      a,x,y
                    lda       >FsPath
                    ldx       #vEdFileLine
                    ldy       #FileLineLen
                    os9       I$Write
                    puls      a,x,y
                    bra       InputFilenameLoop
* InputFilenameDone: CR: terminate the name and return its length
InputFilenameDone               stb       ,x
                    tfr       x,d
                    subd      #vEdFileName
                    rts
* LoadSaveLibrary: A=0 load / A=1 save the mode library file named at $02D7 ($03CF bytes at $034A); carry set + B=error on failure
LoadSaveLibrary               sta       >vLibSave
                    lda       #OpenUpdate
                    ldx       #vEdFileName
                    os9       I$Open
                    bhs       LoadSaveLibOpened
                    tst       >vLibSave
                    beq       LoadSaveLibExit
                    lda       #OpenWrite
                    ldb       #AttrOwnerRW
                    ldx       #vEdFileName
                    os9       I$Create
                    blo       LoadSaveLibExit
* LoadSaveLibOpened: File open: seek to 0 and read or write
LoadSaveLibOpened               sta       >vLibPath
                    ldx       #SeekFileStart
                    tfr       x,u
                    os9       I$Seek
                    blo       LoadSaveLibError
                    ldy       #LibBytes
                    ldx       #vModeLib
                    lda       >vLibPath
                    tst       >vLibSave
                    bne       LoadSaveLibWrite
                    os9       I$Read
                    blo       LoadSaveLibError
                    bra       LoadSaveLibClose
* LoadSaveLibWrite: Write the library
LoadSaveLibWrite               os9       I$Write
                    blo       LoadSaveLibError
* LoadSaveLibClose: Close the file and return success
LoadSaveLibClose               lda       >vLibPath
                    os9       I$Close
                    rts
* LoadSaveLibError: Close the file keeping error code B
LoadSaveLibError               pshs      b
                    lda       >vLibPath
                    os9       I$Close
                    puls      b
* LoadSaveLibExit: Return (carry from the failed call)
LoadSaveLibExit               rts
* DigitsToBinary: Convert the 6 ASCII digits at $02BE (least significant first) to a 24-bit value in $02B6-$02B8
DigitsToBinary               clra
                    sta       >vEdValue
                    sta       >vEdValue+1
                    sta       >vEdValue+2
                    ldx       #vEdDigitBuf
                    ldy       #TblPow10+ModBase
* DigitsToBinaryLoop: Per-digit loop
DigitsToBinaryLoop               ldb       ,x+
                    andb      #DigitValMask
                    beq       DigitsToBinaryNext
* DigitsToBinaryAdd: Add the digit's power of ten (repeated digit times)
DigitsToBinaryAdd               lda       2,y
                    adda      >vEdValue+2
                    sta       >vEdValue+2
                    lda       1,y
                    adca      >vEdValue+1
                    sta       >vEdValue+1
                    lda       ,y
                    adca      >vEdValue
                    sta       >vEdValue
                    decb
                    bne       DigitsToBinaryAdd
* DigitsToBinaryNext: Next digit and next power of ten
DigitsToBinaryNext               leay      3,y
                    cmpx      #vEdDigitsEnd
                    bne       DigitsToBinaryLoop
                    rts
* PrintDecimal24: Print the 24-bit value in $02B6-$02B8 in decimal (leading zeros suppressed) at the $02F8 cursor position
PrintDecimal24               pshs      y
                    clr       >vDecStarted
                    ldy       #vEdValueText
                    clrb
                    lda       #AsciiSpace
* PrintDecimalBlank: Fill the 6-character output buffer with spaces
PrintDecimalBlank               sta       b,y
                    incb
                    cmpb      #EdValueWidth
                    blo       PrintDecimalBlank
                    ldx       #TblPow10Top+ModBase
* PrintDecimalDigit: Start the next decimal digit
PrintDecimalDigit               lda       #AsciiZero
                    sta       >vDecDigit
* PrintDecimalSub: Subtract the power of ten while it fits, counting the digit
PrintDecimalSub               lda       >vEdValue+2
                    suba      2,x
                    sta       >vDecTrialLo
                    lda       >vEdValue+1
                    sbca      1,x
                    sta       >vDecTrialMid
                    lda       >vEdValue
                    sbca      ,x
                    bmi       PrintDecimalStore
                    sta       >vEdValue
                    lda       >vDecTrialMid
                    sta       >vEdValue+1
                    lda       >vDecTrialLo
                    sta       >vEdValue+2
                    inc       >vDecDigit
                    bra       PrintDecimalSub
* PrintDecimalStore: Store the digit unless it is a leading zero
PrintDecimalStore               lda       >vDecDigit
                    cmpx      #TblPow10+ModBase
                    beq       PrintDecimalPut
                    cmpa      #AsciiZero
                    bne       PrintDecimalPut
                    lda       >vDecStarted
                    beq       PrintDecimalNext
* PrintDecimalPut: Put the digit into the output buffer
PrintDecimalPut               inc       >vDecStarted
                    lda       >vDecDigit
                    sta       ,y+
* PrintDecimalNext: Next lower power of ten; finally write the cursor-goto and the digits
PrintDecimalNext               leax      -3,x
                    cmpx      #TblPow10+ModBase
                    bhs       PrintDecimalDigit
                    pshs      a,x,y
                    lda       >FsPath
                    ldx       #vGotoXY
                    ldy       #GotoXYLen
                    os9       I$Write
                    puls      a,x,y
                    pshs      a,x,y
                    lda       >FsPath
                    ldx       #vEdValueText
                    ldy       #EdValueWidth
                    os9       I$Write
                    puls      a,x,y
                    puls      y
                    rts
* WriteScreen: Write Y bytes at X to the screen path ($0CD6)
WriteScreen               lda       >FsPath
                    os9       I$Write
                    rts
* StoreFieldAndMode: Store the edited value into the field variable; on a USER MODE change load mode n, or save to mode n-100 when n >= 110
StoreFieldAndMode               lda       >vMenuRow
                    pshs      a
                    jsr       >StoreFieldValue+ModBase
* WildBits (#15, 2026-10-25): only a store into USER MODE itself (page 1, row 1) loads or saves a mode; any other
* field puts USER MODE back in step with the current mode (the demo's load sets $0301 to 2 and left $0343 at 0, so
* the next field stored, GROUND TEXTURE or any other, reloaded mode 0: throttle 0, the magnetos off, on the ground)
                    lda       >vMenuPage
                    bne       StoreFieldRejectMode
                    lda       ,s
                    deca
                    bne       StoreFieldRejectMode
                    lda       >vUserModeFld
                    cmpa      #UserModeSaveEnd
                    bhs       StoreFieldRejectMode
                    cmpa      >vModeNum
                    beq       StoreFieldRejectMode
                    cmpa      #UserModeSave
                    bhs       StoreFieldSaveMode
                    cmpa      >vModeCount
                    bhs       StoreFieldRejectMode
                    sta       >vModeNum
                    jsr       >LoadModeSlot+ModBase
                    lda       >vModeNum
                    sta       >vUserModeFld
                    bra       StoreFieldRedraw
* StoreFieldSaveMode: USER MODE 110+: save current settings into user mode n-100
StoreFieldSaveMode               suba      #UserModeSaveOfs
                    cmpa      >vModeCount
                    bhs       StoreFieldRejectMode
                    sta       >vModeNum
                    sta       >vUserModeFld
                    jsr       >SaveModeSlot+ModBase
* StoreFieldRedraw: Redraw the page values and restore the row
StoreFieldRedraw               jsr       >ShowPageValues+ModBase
                    puls      a
                    sta       >vMenuRow
                    rts
* StoreFieldRejectMode: Invalid mode number: restore the current mode in the field
StoreFieldRejectMode               lda       >vModeNum
                    sta       >vUserModeFld
                    bra       StoreFieldRedraw
* ShowPageValues: Print the values of every field on the current page and set $02D0 = last row
ShowPageValues               clr       >vMenuRows
                    ldb       >vMenuPage
                    aslb
                    ldy       #TblPageFields+ModBase
                    ldy       b,y
* ShowPageValuesLoop: Per-field loop
ShowPageValuesLoop               lda       ,y
                    beq       ShowPageValuesDone
                    jsr       >NextFieldDesc+ModBase
                    lda       >vMenuRow
                    cmpa      >vMenuRows
                    blo       ShowPageValuesFetch
                    sta       >vMenuRows
* ShowPageValuesFetch: Load the field's 1-3 byte variable into $02B6-$02B8
ShowPageValuesFetch               clrb
                    stb       >vEdValue
                    stb       >vEdValue+1
                    stb       >vEdValue+2
                    ldb       -4,y
                    decb
                    beq       ShowPageValuesByte
                    decb
                    beq       ShowPageValuesWord
                    bra       ShowPageValues24
* ShowPageValuesByte: 1-byte field
ShowPageValuesByte               lda       ,u
                    sta       >vEdValue+2
                    bra       ShowPageValuesPrint
* ShowPageValuesWord: 2-byte field
ShowPageValuesWord               lda       ,u
                    sta       >vEdValue+1
                    lda       1,u
                    sta       >vEdValue+2
                    bra       ShowPageValuesPrint
* ShowPageValues24: 3-byte field
ShowPageValues24               lda       ,u
                    sta       >vEdValue
                    lda       1,u
                    sta       >vEdValue+1
                    lda       2,u
                    sta       >vEdValue+2
* ShowPageValuesPrint: Print the value and continue
ShowPageValuesPrint               jsr       >PrintDecimal24+ModBase
                    bra       ShowPageValuesLoop
* ShowPageValuesDone: Return
ShowPageValuesDone               rts
* ImportSimState: Convert the simulator state (position, altitude, attitude, heading, speed, controls, wind) to editor units in $0309-$0331
ImportSimState               ldd       <vPosZ
                    adda      #EdPosBiasHi
                    std       >vModeNorth
                    ldd       <vPosX
                    adda      #EdPosBiasHi
                    std       >vModeEast
                    ldd       <vAlt+1
                    addd      >vElev
                    std       <vMulA
                    ldd       #FtPerMQ14
                    jsr       >Mul16Scale+ModBase
                    ldd       <vMulProd
                    rol       <vMulProd+2
                    rolb
                    rola
                    rol       <vMulProd+2
                    rolb
                    rola
                    subd      #GndHeightFt
                    std       >vModeAltFt
                    ldd       >vHdgCopy
                    subd      >vHdgOfs2
                    subd      >vHdgOfs1
                    std       >vHdgCopy
                    ldd       >vHdgCopy
                    std       <vMulA
                    ldd       #DegPerTurn
                    jsr       >Mul16Scale+ModBase
                    ldd       <vMulProd
                    std       >vModeHdg
                    ldd       >vBankAngle
                    std       <vMulA
                    ldd       #DegPerTurn
                    jsr       >Mul16Scale+ModBase
                    ldd       <vMulProd
                    std       >vModeBank
                    ldd       >vPathPitch
                    std       <vMulA
                    ldd       #DegPerTurn
                    jsr       >Mul16Scale+ModBase
                    ldd       <vMulProd
                    std       >vModePitch
                    ldd       >vAirspeed
                    std       <vMulA
                    ldd       #AirspeedToKt
                    jsr       >Mul16Scale+ModBase
                    ldd       <vMulProd
                    std       >vModeAirspeed
                    ldd       >vThrottle
                    std       >vModeThrottle
                    ldd       >vFlaps
                    std       >vModeFlaps
                    ldd       >vRudder
                    addd      #CtlCenter
                    std       >vModeRudder
                    ldd       >vAileron
                    addd      #CtlCenter
                    std       >vModeAileron
                    ldd       >vElevator
                    addd      #CtlCenter
                    std       >vModeElevator
                    lda       >vDemoOn
                    bne       ImportSimStateWind
                    ldd       >vCopyTo0207
                    std       >vDemoOffCopy
* ImportSimStateWind: Convert wind tables and scale the shear altitudes for display
ImportSimStateWind               ldy       #UnitsToEditor
                    jsr       >ConvertWindTables+ModBase
                    ldd       >vShear1
                    std       <vMulA
                    ldd       #FtPerMQ8
                    jsr       >Mul16Scale+ModBase
                    std       >vShear1
                    ldd       >vShear2
                    std       <vMulA
                    ldd       #FtPerMQ8
                    jsr       >Mul16Scale+ModBase
                    std       >vShear2
                    ldd       >vShear3
                    std       <vMulA
                    ldd       #FtPerMQ8
                    jsr       >Mul16Scale+ModBase
                    std       >vShear3
                    rts
* ApplyEditsAndExit: Convert edited values back to simulator state, handle Europe 1917 and ADF panel changes, then return to FS
ApplyEditsAndExit               clr       >vOvlReq
                    lda       >vWarOn
                    beq       ApplyChkWarMode
                    lda       >vEurope1917
                    bne       ApplyWarMode
                    jsr       >FsLoadPanelPicture
                    lda       >vInstActive2
                    ora       #InstReadouts
                    sta       >vInstActive2
                    lda       >vInstPresent+1
                    ora       #InstReadouts
                    sta       >vInstPresent+1
                    jsr       >FsInitFlightDisplay
                    clr       >vWarOn
                    clr       >vAdfShown
                    ldd       #WbWinStart
                    std       >vListStart
                    std       >vListEnd
* ApplyChkWarMode: Europe 1917 off: skip the WWI setup
ApplyChkWarMode               lda       >vEurope1917
                    beq       ApplyAdfPanel
* ApplyWarMode: Europe 1917 on: force mode 7, load it and request overlay 3 (F4) via $0221
ApplyWarMode               lda       #ModeEurope1917
                    sta       >vUserModeFld
                    sta       >vModeNum
                    sta       >vWarOn
                    clr       >vWarReport
                    jsr       >LoadModeSlot+ModBase
                    lda       #OvlF4
                    sta       >vOvlReq
* ApplyAdfPanel: Show or remove the ADF instrument according to the ADF ENABLE setting
ApplyAdfPanel               lda       >vAdfShown
                    bne       ApplyAdfOff
                    lda       >vAdfEnable
                    beq       ApplyJoystick
                    lda       >vInstActive3
                    anda      #InstNav2
                    beq       ApplyAdfShown
                    jsr       >FsLoadPictureFa
                    jsr       >FsInitAdfNeedle
                    lda       #PanelBlank
                    jsr       >FsSetFillColor
                    ldd       #AdfAreaTopLeft
                    ldx       #AdfAreaBotRight
                    ldy       >vPanelScr
                    jsr       >FsFillRect
                    ldx       #vAdfLabel
                    ldy       >vPanelScr
                    jsr       >FsPrintPanelText5
                    jsr       >FsSetAdfFreq
                    jsr       >FsDrawEngineSwitches
* ApplyAdfShown: Mark the ADF as displayed
ApplyAdfShown               lda       #AdfShownOn
                    sta       >vAdfShown
                    bra       ApplyJoystick
* ApplyAdfOff: ADF disabled: restore the panel if it was shown
ApplyAdfOff               lda       >vAdfEnable
                    bne       ApplyJoystick
                    lda       >vInstActive3
                    anda      #InstNav2
                    beq       ApplyAdfCleared
                    jsr       >FsLoadPanelPicture
                    jsr       >FsInitFlightDisplay
* ApplyAdfCleared: Mark the ADF as not displayed
ApplyAdfCleared               clr       >vAdfShown
* ApplyJoystick: Clamp joystick enable ($088D) to 0-2 and restore the screen
ApplyJoystick               lda       >vJoyMode
                    cmpa      #JoyModes
                    blo       ApplyJoystickStore
                    clra
* ApplyJoystickStore: Store the joystick setting and convert the remaining values back
ApplyJoystickStore               sta       >vJoyMode
                    lda       >FsPath
                    ldy       >WbScrBlks
                    jsr       >WbDScrnEnt            WildBits SS.DScrn (fs_wb.asm)
                    nop
                    nop
                    jsr       >FsTermReset
                    jsr       >FsDrawClockHourMin
                    ldd       >vModeNorth
                    subd      #EdPosBias
                    std       <vPosZ
                    ldd       >vModeEast
                    subd      #EdPosBias
                    std       <vPosX
                    ldd       >vModeZLo
                    std       <vPosZ+2
                    ldd       >vModeXLo
                    std       <vPosX+2
                    jsr       >FsSetHeightFromTerrain
                    ldd       >vModeHdg
                    std       <vMulA
                    ldd       #AnglePerDegQ8
                    jsr       >Mul16Scale+ModBase
                    std       >vHdgCopy
                    ldd       >vHdgCopy
                    addd      >vHdgOfs2
                    std       >vHdgCopy
                    ldd       >vHdgCopy
                    addd      >vHdgOfs1
                    std       >vHdgCopy
                    ldd       >vModeBank
                    std       <vMulA
                    ldd       #AnglePerDegQ8
                    jsr       >Mul16Scale+ModBase
                    std       >vBankAngle
                    ldd       >vModePitch
                    std       <vMulA
                    ldd       #AnglePerDegQ8
                    jsr       >Mul16Scale+ModBase
                    std       >vPathPitch
                    ldd       >vModeAirspeed
                    std       <vMulA
                    ldd       #KtToAirspeed
                    jsr       >Mul16Scale+ModBase
                    std       >vAirspeed
                    ldd       >vModeThrottle
                    std       >vThrottle
                    ldd       >vModeFlaps
                    std       >vFlaps
                    ldd       >vModeRudder
                    subd      #CtlCenter
                    std       >vRudder
                    ldd       >vModeAileron
                    subd      #CtlCenter
                    std       >vAileron
                    ldd       >vModeElevator
                    subd      #CtlCenter
                    std       >vElevator
                    lda       >vReality
                    beq       ApplyEnvironment
                    lda       >vThrottle
                    bne       ApplyEnvironment
                    clra
                    jsr       >FsSetMagnetos
* ApplyEnvironment: Copy the pending flag, convert wind and shear values back to simulator units
ApplyEnvironment               lda       >vDemo
                    sta       >vDemoOn
                    clr       >vDemo
                    ldd       >vShear1
                    std       <vMulA
                    ldd       #MPerFtQ16
                    jsr       >Mul16Scale+ModBase
                    ldd       <vMulProd
                    std       >vShear1
                    ldd       >vShear2
                    std       <vMulA
                    ldd       #MPerFtQ16
                    jsr       >Mul16Scale+ModBase
                    ldd       <vMulProd
                    std       >vShear2
                    ldd       >vShear3
                    std       <vMulA
                    ldd       #MPerFtQ16
                    jsr       >Mul16Scale+ModBase
                    ldd       <vMulProd
                    std       >vShear3
                    ldy       #UnitsToSim
                    jsr       >ConvertWindTables+ModBase
* ApplyResetState: Clear transient simulator flags, then convert clouds, time and season; its address also appears as the constant $4E07 in three ldd #
ApplyResetState               clra
                    sta       >vWarState
                    sta       >vWarStarted
                    sta       >vWarKills
                    sta       >vWarDowned
                    sta       >vBombAlt
                    sta       >vWarScore
                    sta       >vWarScore+1
                    lda       >vReality
                    bne       ApplyClouds
                    jsr       >FsResetFlightState
* ApplyClouds: Recompute time/season dependent state. The cloud layers stay in the menu's feet (vCld2TopFt..
* vCld1BotFt): FS's own decks at $0158-$015E are no longer set (fs_wb.d), the K2's 3D clouds read the feet.
ApplyClouds               jsr       >SeasonGnd+ModBase   WildBits: the season's ground
                    lda       #HeightSetFrames
                    sta       >vGroundSettle
                    lda       >vFlaps
                    jsr       >FsSetFlaps
                    jsr       >FsShowElevatorPos
                    jsr       >FsShowThrottlePos
                    jsr       >FsShowRudderPos
                    jsr       >FsShowAileronPosGauge
                    clr       >vLoadKind
                    lda       >vUserModeFld
                    sta       >vSceneMode
                    lda       <vFrameCount
                    anda      #AtisTempMask
                    suba      #AtisTempBias
                    sta       >vAtisTempOfs
                    lda       >vModeRec
                    ldb       >vSlew
                    beq       ApplyStoreSlewFlag
                    clra
* ApplyStoreSlewFlag: Store $022A (0 when slew is on)
ApplyStoreSlewFlag               sta       >vNoSlew
                    rts
* SaveUserMode: Save the current settings as a user mode (mode+10 for built-in modes), then reload and redraw
SaveUserMode               lda       >vModeNum
                    cmpa      #FirstUserMode
                    bhs       SaveUserModeChk
                    adda      #FirstUserMode
                    sta       >vUserModeFld
                    sta       >vModeNum
                    bra       SaveUserModeDo
* SaveUserModeChk: Already a user mode: check it is within the library count
SaveUserModeChk               cmpa      >vModeCount
                    bhs       SaveUserModeDone
* SaveUserModeDo: Copy the settings into the slot and reload them
SaveUserModeDo               jsr       >SaveModeSlot+ModBase
                    jsr       >ReloadModeRedraw+ModBase
* SaveUserModeDone: Return
SaveUserModeDone               rts
* ReloadModeRedraw: Reload the current mode into the settings record and redraw the page values
ReloadModeRedraw               lda       >vMenuRow
                    pshs      a
                    jsr       >LoadModeSlot+ModBase
                    jsr       >ShowPageValues+ModBase
                    puls      a
                    sta       >vMenuRow
                    rts
* Mul16Scale: Unsigned 16x16 multiply of <$AF word by D; 32-bit product in <$B3-<$B6, returns D = product bits 8-23
Mul16Scale               pshs      x
                    std       <vMulB
                    ldb       <vMulA+1
                    lda       <vMulB+1
                    mul
                    std       <vMulProd+2
                    lda       <vMulB
                    ldb       <vMulA+1
                    mul
                    addb      <vMulProd+2
                    adca      #AdcCarryOnly
                    std       <vMulProd+1
                    lda       <vMulB+1
                    ldb       <vMulA
                    mul
                    clr       <vMulProd
                    addd      <vMulProd+1
                    std       <vMulProd+1
                    bhs       Mul16ScaleHigh
                    inc       <vMulProd
* Mul16ScaleHigh: Add the high partial product
Mul16ScaleHigh               lda       <vMulB
                    ldb       <vMulA
                    mul
                    addd      <vMulProd
                    std       <vMulProd
                    ldd       <vMulProd+1
                    puls      x
                    rts
* NextFieldDesc: Read the field descriptor at Y: set row $02B9 and the value-column cursor, U = variable address, Y += 4
NextFieldDesc               lda       1,y
                    sta       >vMenuRow
                    adda      #GotoXYBias
                    sta       >vGotoRow
                    ldb       #ValueCol
                    addb      #GotoXYBias
                    stb       >vGotoCol
                    tfr       d,x
                    ldu       2,y
                    leay      4,y
                    rts
* ShowPageText: Write the text of editor page $02BA (via TblPageText)
ShowPageText               lda       >vMenuPage
                    asla
                    asla
                    ldx       #TblPageText+ModBase
                    tfr       x,y
                    ldx       a,x
                    adda      #PageTextLenOfs
                    ldy       a,y
                    jsr       >WriteScreen+ModBase
                    rts
* StoreFieldValue: Store $02B6-$02B8 into the variable of the field on the current row (1-3 bytes)
StoreFieldValue               ldb       >vMenuRow
                    pshs      b
                    ldb       >vMenuPage
                    aslb
                    ldy       #TblPageFields+ModBase
                    ldy       b,y
* StoreFieldValueFind: Search the page's field list for the current row
StoreFieldValueFind               lda       ,y
                    beq       StoreFieldValueDone
                    jsr       >NextFieldDesc+ModBase
                    puls      b
                    pshs      b
                    cmpb      >vMenuRow
                    bne       StoreFieldValueFind
                    ldb       -4,y
                    decb
                    beq       StoreFieldValueByte
                    decb
                    beq       StoreFieldValueWord
                    bra       StoreFieldValue24
* StoreFieldValueByte: Store 1 byte
StoreFieldValueByte               lda       >vEdValue+2
                    sta       ,u
                    bra       StoreFieldValueDone
* StoreFieldValueWord: Store 2 bytes
StoreFieldValueWord               ldd       >vEdValue+1
                    std       ,u
                    bra       StoreFieldValueDone
* StoreFieldValue24: Store 3 bytes
StoreFieldValue24               lda       >vEdValue
                    sta       ,u
                    ldd       >vEdValue+1
                    std       1,u
* StoreFieldValueDone: Return
StoreFieldValueDone               puls      b
                    rts
* ConvertWindTables: Convert the 4 wind entries ($0332-$0341) and 7 words at $015E; Y=0 to editor units, Y=1 back to simulator units
ConvertWindTables               ldx       #vWind3
                    jsr       >ConvertWindEntry+ModBase
                    ldx       #vWind2
                    jsr       >ConvertWindEntry+ModBase
                    ldx       #vWind1
                    jsr       >ConvertWindEntry+ModBase
                    ldx       #vWindSfc
                    jsr       >ConvertWindEntry+ModBase
                    lda       #ScaledAltCount
                    sta       <vScaleWordsLeft
                    ldx       #vScaledAlts
                    cmpy      #UnitsToSim
                    beq       ConvertWindToSim
* ConvertWindToEditor: Scale the 7 words to editor units (probably shear and cloud altitudes)
ConvertWindToEditor               ldd       #FtPerMQ8
                    std       <vMulA
                    ldd       ,x
                    jsr       >Mul16Scale+ModBase
                    std       ,x++
                    dec       <vScaleWordsLeft
                    bne       ConvertWindToEditor
                    rts
* ConvertWindToSim: Scale the 7 words back to simulator units
ConvertWindToSim               ldd       #MPerFtQ16Fs
                    std       <vMulA
                    ldd       ,x
                    jsr       >Mul16Scale+ModBase
                    ldd       <vMulProd
                    std       ,x++
                    dec       <vScaleWordsLeft
                    bne       ConvertWindToSim
                    rts
* ConvertWindEntry: Convert one wind entry at X: direction to/from degrees, speed to/from two base-100 bytes (Y selects direction)
ConvertWindEntry               cmpy      #UnitsToEditor
                    bne       ConvertWindEntryToSim
                    ldd       #DegPerTurn
                    std       <vMulA
                    ldd       2,x
                    jsr       >Mul16Scale+ModBase
                    ldd       <vMulProd
                    std       2,x
                    lda       1,x
                    ldb       #WindKtBase
                    mul
                    addb      ,x
                    adca      #AdcCarryOnly
                    std       ,x
                    rts
* ConvertWindEntryToSim: Convert degrees back to a binary angle and split the speed into base-100 bytes
ConvertWindEntryToSim               ldd       #AnglePerDegQ8
                    std       <vMulA
                    ldd       2,x
                    pshs      x
                    jsr       >Mul16Scale+ModBase
                    puls      x
                    std       2,x
                    ldd       ,x
                    ldu       #KtHundredsStart
                    stu       ,x
* ConvertWindEntryDiv: Divide by 100 by repeated subtraction
ConvertWindEntryDiv               inc       1,x
                    subd      #WindKtBase
                    bhs       ConvertWindEntryDiv
                    addd      #WindKtBase
                    stb       ,x
* SaveModeSlotDone: Return (built-in mode, nothing saved)
SaveModeSlotDone               rts
* SaveModeSlot: Copy the settings record $0302 into the current user-mode slot (modes 10+ only)
SaveModeSlot               lda       >vModeNum
                    cmpa      #FirstUserMode
                    blo       SaveModeSlotDone
                    lda       #CopyToSlot
                    bra       CopyModeRecord
* LoadModeSlot: Copy the current mode ($0301) from the built-in table or the library into the settings record $0302;
* WildBits: then WindRnd, random winds for a mode without any
LoadModeSlot               clra
                    bsr       CopyModeRecord
                    jmp       >WindRnd+ModBase
* CopyModeRecord: A=0 slot to settings, A=1 settings to slot; 65-byte record of mode $0301
CopyModeRecord               sta       >vModeCopyDir
                    ldd       #TblBuiltinModes+ModBase
                    std       <vModeRecPtr
                    lda       >vModeNum
                    cmpa      #FirstUserMode
                    blo       CopyModeRecordAddr
                    sbca      #FirstUserMode
                    ldx       #vModeLib
                    stx       <vModeRecPtr
* CopyModeRecordAddr: Compute the slot address (mode x 65 + base)
CopyModeRecordAddr               ldb       #ModeRecLen
                    mul
                    addd      <vModeRecPtr
                    std       <vModeRecPtr
                    ldb       #ModeRecLastIx
                    ldx       <vModeRecPtr
                    ldy       #vModeRec
                    lda       >vModeCopyDir
                    beq       CopyModeRecordLoop
                    exg       x,y
* CopyModeRecordLoop: Copy loop
CopyModeRecordLoop               lda       b,x
                    sta       b,y
                    decb
                    bpl       CopyModeRecordLoop
                    rts
* TblBuiltinModes: Built-in modes 0-9, 65 bytes each (settings record image: +7 Z high word + $4000, +9 X high
* word + $4000, +17 heading in degrees), followed by zero fill. WildBits: modes 0 (the start and crash reset),
* 2 (demo) and 4 start at O'Hare in the game start's map square (187,863: 9C's west end), heading 090; the crash
* reset then puts the aircraft on the start itself (fsw ModeLd). The CoCo's were at Meigs (287,804, heading 0).
* Winds (+48 wind 3, +52 wind 2, +56 wind 1, +60 the surface: knots, degrees): modes 0, 2, 3, 7, 8 and 9 had none in
* FS II's data; prefilled (Roger 2026-10-25) at random near the average of modes 1, 4 and 5's (36 kt 287, 23 kt
* 308, 14 kt 315, 6 kt 310: knots x 0.75-1.25, degrees +-30). WindRnd still covers a library mode without winds.
* Mode 5's wind 1 (322 kt in FS II's data) 14 kt; mode 6's winds had knots and degrees swapped (wind 2's 642 deg
* read as 282).
TblBuiltinModes     fcb       $01,$01,$00,$01,$00,$00,$80,$43,$5F,$40,$BB,$00,$00   mode 0 (+3 reality mode on, Roger 2026-10-17)
                    fcb       $00,$00,$00,$00,$00,$5A,$00,$00,$00,$00,$7F,$FF,$7F
                    fcb       $FF,$00,$00,$7F,$FF,$08,$00,$04,$4E,$20,$3A,$99,$3A   (+31 08:00, +34 the clouds 15,001-20,000
                    fcb       $98,$19,$64,$0B,$B8,$17,$70,$23,$28,$00,$22,$01,$31   and 6,500-15,000 ft: fs2/fd's start, 2026-10-25)
                    fcb       $00,$13,$01,$40,$00,$11,$01,$22,$00,$07,$01,$2C,$64
                    fcb       $01,$00,$00,$01,$00,$00,$80,$53,$5F,$19,$B8,$00,$00   mode 1
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7F,$FF,$7F
                    fcb       $FF,$00,$00,$7F,$FF,$0F,$17,$02,$27,$10,$1F,$40,$13
                    fcb       $88,$0B,$B8,$09,$60,$1C,$D4,$35,$E8,$00,$2B,$01,$0E
                    fcb       $00,$19,$01,$22,$00,$11,$01,$22,$00,$0A,$01,$36,$5F
                    fcb       $01,$01,$00,$00,$01,$00,$80,$43,$5F,$40,$BB,$00,$00   mode 2
                    fcb       $00,$00,$00,$00,$00,$5A,$00,$14,$7D,$00,$7F,$FF,$7F
                    fcb       $BC,$00,$00,$97,$FF,$0A,$11,$03,$27,$10,$1F,$40,$13
                    fcb       $88,$0B,$B8,$0B,$B8,$17,$70,$23,$28,$00,$1D,$01,$2C
                    fcb       $00,$13,$01,$2C,$00,$0E,$01,$4A,$00,$07,$01,$3B,$64
                    fcb       $01,$01,$00,$00,$00,$00,$80,$3C,$0E,$16,$AD,$00,$00   mode 3
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7F,$FF,$7F
                    fcb       $FF,$00,$00,$7F,$FF,$15,$05,$03,$27,$10,$1F,$40,$13
                    fcb       $88,$0B,$B8,$0B,$B8,$17,$70,$23,$28,$00,$1C,$01,$3B
                    fcb       $00,$1C,$01,$4F,$00,$0B,$01,$45,$00,$04,$01,$18,$64
                    fcb       $01,$01,$00,$01,$00,$00,$80,$43,$5F,$40,$BB,$00,$00   mode 4 (reality mode on)
                    fcb       $00,$00,$00,$00,$00,$5A,$00,$00,$00,$00,$7F,$FF,$7F
                    fcb       $FF,$00,$00,$7F,$FF,$16,$1F,$03,$27,$10,$1F,$40,$13
                    fcb       $88,$0B,$B8,$0B,$B8,$17,$70,$23,$28,$00,$1F,$01,$22
                    fcb       $00,$12,$01,$5E,$00,$0C,$01,$54,$00,$03,$01,$5E,$64
                    fcb       $01,$01,$00,$00,$00,$00,$40,$42,$8A,$52,$49,$00,$00   mode 5
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7F,$FF,$7F
                    fcb       $FF,$00,$00,$7F,$FF,$0D,$00,$03,$00,$00,$00,$00,$10
                    fcb       $68,$0D,$98,$0D,$98,$10,$68,$23,$28,$00,$21,$01,$2C
                    fcb       $00,$19,$01,$1D,$00,$0E,$01,$18,$00,$04,$01,$0E,$64   (+52 wind 1 14 kt, FS II's 322)
                    fcb       $01,$01,$00,$00,$00,$00,$80,$45,$EB,$55,$5D,$00,$00   mode 6
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7F,$FF,$7F
                    fcb       $FF,$00,$00,$7F,$FF,$09,$2D,$03,$24,$5E,$1F,$40,$19
                    fcb       $64,$0B,$B8,$04,$B0,$05,$91,$0B,$B8,$00,$1D,$01,$08   (the winds: FS II's had knots and degrees
                    fcb       $00,$19,$01,$1A,$00,$10,$00,$86,$00,$0A,$01,$48,$64   swapped, wind 2's 642 deg = 282)
                    fcb       $01,$01,$00,$00,$00,$01,$FF,$43,$FC,$1D,$0A,$00,$00   mode 7
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7F,$FF,$7F
                    fcb       $FF,$00,$00,$7F,$FF,$0C,$23,$03,$27,$10,$1F,$40,$13
                    fcb       $88,$0B,$B8,$0B,$B8,$17,$70,$23,$28,$00,$22,$01,$3B
                    fcb       $00,$17,$01,$18,$00,$0D,$01,$36,$00,$06,$01,$3B,$64
                    fcb       $01,$01,$00,$00,$00,$00,$C8,$40,$10,$40,$51,$02,$F2   mode 8
                    fcb       $00,$00,$00,$00,$00,$5A,$00,$00,$00,$00,$7F,$FF,$7F
                    fcb       $FF,$00,$00,$7F,$FF,$08,$05,$03,$27,$10,$1F,$40,$13
                    fcb       $88,$0B,$B8,$0B,$B8,$17,$70,$23,$28,$00,$1F,$01,$1D
                    fcb       $00,$18,$01,$18,$00,$0D,$01,$40,$00,$05,$01,$2C,$64
                    fcb       $01,$01,$00,$00,$00,$00,$C8,$40,$10,$40,$51,$02,$F2   mode 9
                    fcb       $00,$00,$00,$00,$00,$5A,$00,$00,$00,$00,$7F,$FF,$7F
                    fcb       $FF,$00,$00,$7F,$FF,$08,$05,$03,$00,$00,$00,$00,$13
                    fcb       $88,$04,$7E,$0B,$B8,$17,$70,$23,$28,$00,$2C,$01,$13
                    fcb       $00,$17,$01,$2C,$00,$0F,$01,$2C,$00,$06,$01,$1D,$64
* (The CoCo's fill to the module's end, 3311 bytes; WindRnd sits in its first bytes.)
WrFill              equ       *
* WindRnd (LoadModeSlot; Roger 2026-10-25): a mode whose four winds are all 0 knots (every built-in mode but 1, 4,
* 5 and 6) gets random fair winds, new at every load (the start and every crash reset load mode 0): the surface
* 4-10 knots from within 40 degrees of the start runway's heading (vStartHdg: a headwind), each level above veering
* 6-25 degrees from the one below and stronger: level 1 8-15, level 2 14-24, level 3 22-35 knots (WrTab). In the
* record's editor units, knots and degrees (ApplyEditsAndExit converts them). The seed: F$Time's minutes and
* seconds, the hour in. D, X, Y clobbered.
WindRnd             ldd       >vWind3
                    addd      >vWind2
                    addd      >vWind1
                    addd      >vWindSfc
                    bne       wr9@
                    pshs      u
                    leas      -6,s                F$Time's six bytes: year, month, day, hour, minutes, seconds
                    tfr       s,x
                    os9       F$Time
                    ldd       4,s
                    eora      3,s
                    std       4,s                 the seed, in the minutes and seconds
                    leau      4,s
                    lda       #WindSfcDirRange    the surface wind's direction (from): the start heading +-28 (40 degrees)
                    bsr       WrRnd
                    adda      >vStartHdg
                    suba      #WindSfcDirHalf
                    ldy       #vWindSfc
                    ldx       #WrTab+ModBase
wr1@                pshs      a                   this wind's direction, 1/256 turn
                    ldb       #Angle8ToDeg32      in degrees: x 45 / 32
                    mul
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    std       2,y
                    lda       1,x                 the knots: the base plus 0 .. range-1
                    bsr       WrRnd
                    adda      ,x
                    tfr       a,b
                    clra
                    std       ,y
                    puls      a
                    cmpy      #vWind3
                    beq       wr8@
                    pshs      a                   the level above veers (clockwise): the base plus 0 .. range-1
                    lda       3,x
                    bsr       WrRnd
                    adda      2,x
                    adda      ,s+
                    leax      4,x
                    leay      -4,y
                    bra       wr1@
wr8@                leas      6,s
                    puls      u
wr9@                rts
* WrRnd: A = 0 .. A-1 (the seed at U x 25173 + 13849, its high byte x A). X, Y, U kept.
WrRnd               pshs      a
                    ldd       ,u
                    std       >MATH_MUL_A
                    ldd       #WrRndMul
                    std       >MATH_MUL_B
                    ldd       >MATH_MUL_P+2
                    addd      #WrRndAdd
                    std       ,u
                    puls      b
                    mul
                    rts
WrTab               fcb       4,7,4,15            from the surface up: knots base and range, the next level's veer base and range (1/256 turn)
                    fcb       8,8,4,15            level 1
                    fcb       14,11,4,15          level 2
                    fcb       22,14               level 3
* SeasonGnd (ApplyClouds, every exit: the editor, a mode load, the start; Roger 2026-10-25): the season's ground. FS
* never wrote the sky / ground table at $0100-$0113 (fs2/fd's values only), and no scenery list tests the season, so
* the season changed nothing on screen. Every area's list takes the day's ground from $0100 (the fill pattern word:
* the color in each nibble): winter (vSeason 1) white, snow; spring, summer and fall green, fs2/fd's. A clobbered.
SeasonGnd           lda       #GndGreen           green (FS's color 11)
                    ldb       >vSeason
                    cmpb      #SeasonWinter
                    bne       sg1@
                    lda       #GndSnow            winter: white (15)
sg1@                sta       >vDayGround
                    sta       >vDayGround+1
                    rts
                    zmb       WrFill+3293-*       the rest of the fill, to the module's old end (code before WrFill moves it: LoadModeSlot's call 5 bytes, StoreFieldAndMode's USER MODE test 10, ApplyClouds' call 3)

                    emod
eom                 equ       *
                    end
