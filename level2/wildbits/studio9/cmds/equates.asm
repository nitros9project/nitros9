* Palette roles: separate controls even where their current values coincide.
* Values are 4-bit palette indices; packed bytes/words multiply by $11/$1111.
COLORS_TOOLBOXBG    equ       $1                  toolbox interior
COLORS_PAPER        equ       $0                  main bitmap paper / transparent
COLORS_MENUBG       equ       COLORS_INK          drop-down menu interior: the menu bar's black
WinStylePaper3D     equ       1                   wcreate style: the paper 3D box (Box3D: paper inside, ink outline, dark gray shadow)
WinMenu             equ       3                   wcreate style: a drop-down menu - black interior, inverted font, style 1 frame
COLORS_SELPART      equ       $7                  selected part's foreground; gray shading follows XOR mapping
COLORS_INK          equ       $F                  procedural lines and frame ink
COLORS_SYMBOLINK    equ       $C                  legacy monochrome symbols
COLORS_STAFF        equ       $C                  staff and ledger line ink
COLORS_OPAQUEBG     equ       $A                  opaque replacement for transparent glyph pixels
COLORS_MENUDIM      equ       $D                  disabled menu text
COLORS_SHADOW       equ       $C                  a shadow box's shadow, solid
COLORS_BOXSHADOW    equ       $E                  a paper box's shadow: dark gray 64,64,64
COLORS_MENUSHADOW   equ       $D                  a black box's shadow: light gray 187,187,187
COLORS_FONTINK      equ       $F                  font source foreground (recolor comparison)
COLORS_PARTXOR     equ       COLORS_INK^COLORS_SELPART  selected part mapping, preserving shading

* MASTER DEFINITIONS: shared editor storage, separate s9gui storage, and scoped offsets.
* Edit addresses HERE. Module labels at EQU * remain beside their emitted code/data.
* UME_SCOPE_<module> selects local names: a stack offset is NOT an absolute address.
* C clues: CocoRepo/OS-9/APPS/C_RMA/ULTIMUSE3/UMUSE (v09); current assembly is the
* address authority. Do not derive new addresses from C declaration order alone.
* No apparent hole below UmeStaticEnd is available for allocation. Append new persistent
* editor storage at UmeStaticEnd, extend the heap floor, and run make verify-symbols.
* tools/check/check_symbols.py --write generates the machine-readable inventory (symbols.csv,
* symbol-references.csv, storage.csv ...) from this file and every port source.
*
********************************************************************
* equates.asm - Studio-9: the addresses every module must agree on
*
* s9 and the overlays s9b..s9y run as ONE process - one data area, one direct page - so anything
* one module writes and another reads is defined HERE and nowhere else.
*
*                     use       equates.asm         lwasm finds it beside the including file (cmds/)
*
* THE DIRECT PAGE is the first 256 bytes of the process's data area (CStart zeroes it, then copies
* InitDataImage: 34 bytes to $00-$21, 360 to $F7-$25E). Every overlay addresses it: s9p keeps its
* tempo-ramp slopes at <$F3-<$F6, s9k its cursor state at $F7-$FF, the C runtime and s9 the rest.
* A byte is free only when NO module touches it - direct (<$xx), extended (>$00xx) or through Y. The
* bytes found free that way, $50, $52-$55, $BD and $BE, are all taken below.
PressHeld           equ       $0054               the press that chose a menu-bar title, an overlay or PLAY may still be down;
*                                                 mouce reads the button as up until it has seen it up (set by s9's
*                                                 menu-bar and overlay dispatch, and by s9p's PlayMain)
CtxX                equ       $0052               word: pointer X (dots) at a right-button press - the note the
CtxY                equ       $00BD               word: pointer row at that press   context menu acts on
LayHov              equ       $0050               DP byte: the score editor's menu hover: 0 = off, $FF = on with no row
*                                                 highlighted, else the highlighted row + 1. s9l sets $FF around its input wait;
*                                                 s9's keymouse inverts the row under the pointer (LayHover) and un-inverts it
*                                                 before it returns a click or key (LayHoverOff).
* still free on the page: none - re-run the scan before taking one ($55 is FakeDown, $50 LayHov)
*
* ABOVE THE PAGE MAPPER'S TABLE ($1000-$1047), below the debug ring ($1100): the port's mouse statics.
* s9 alone uses them; they are here so an overlay that ever needs them takes the same address.
MsSysDAT            equ       $1048               word: the system's DAT entry 0 (the kernel's direct page), read once at start
MsPrevBtn           equ       $104A               the left button level the program was last given (0/1)
MsStamp             equ       $104B               word: sec*60+tick (0..3599) when that level began
MsLast              equ       $104D               ticks the previous level lasted, 0..254
MsRightPrev         equ       $104E               the right button's last level (bit 1)
MsRightNew          equ       $104F               1 = the right button went down and MainLoop has not acted on it
MsModeSave          equ       $1050               word: the edit mode to put back after a right-click's X-out (0 = none)
LayerSave           equ       $1052               word: VKY_LAYER_CTRL_0/1 as found at start, put back at exit
Bmp12CtrlSave       equ       $1054               bytes: VICKY C0 bitmap-1 / bitmap-2 control registers, restored at exit
Bmp12CtrlSaved      equ       $1056               1 only after Bmp12CtrlSave is valid
RenderNotes         equ       $1057               s9s: 0 = place events/draw rests, 1 = draw notes at saved positions
LayoutOnly          equ       $1058               s9s: measure screen placement without sending drawing commands
FocusedPart         equ       $1059               word: selected part, -1 = no focus
FocusDirty          equ       $105B               byte: fold note selection into the normal score redraw
FocusOnly           equ       $105C               byte: repaint old/new focused notes at their saved positions
Vs1053Out           equ       $105D               byte: the MIDI Modes menu's VS1053 output checkbox (s9's MidiVSSend feeds the SDI FIFO)
MenuKeyOff          equ       '-                  a descriptor key letter: the row is DISABLED - drawn in MenuDimInk, no click, no key
MenuDim             equ       $10                 the byte menu3 streams before a disabled row's label: s9gui dims that row
MenuDimInk          equ       COLORS_MENUDIM                  the disabled row's text color
PaintedFocus        equ       $105F               word: the part currently shown in the focus color, -1 = none
FrRenderFocusedPart equ       $CA                 s9gui: A0 note packets followed by a zero byte
BeamFocusPass       equ       $105E               byte: draw the focused part after other beamed parts
FocusNoteBit        equ       $80                 s9gui $A0 flags: focused note (removed before decoding accidentals)
MenuBarHover        equ       $1061               word: inverted menu-bar title, -1 = none

MidiSelected        equ       $1063               enabled external device paths
pMidiSend           equ       $1064               word: main live-byte dispatcher
MidiRouteNames      equ       $1066               four 16-byte device names
MidiRoutePaths      equ       $10A6               four path IDs: FF empty, FE Wildbits
MidiRouteCount      equ       4
MidiNameSize        equ       16
MidiPath            equ       $01
MidiWildbitsPath    equ       $FE
MidiUnusedPath      equ       $FF

pSAMSend            equ       $10AC               word: B-byte SAM2695 transmitter
AuditionMode        equ       $10AE               0 playback, 1 audition: no SAM reset, speed keys ignored, smf/verbose off
AuditionSavedFlags  equ       $1131               saved SMF and verbose flags

pMidiEcho           equ       $10B1               word: resident DIN input -> MIDI output/piano hook
MidiRxStatus        equ       $10B3
MidiRxNeed          equ       $10B4
MidiRxCount         equ       $10B5
MidiRxDrop          equ       $10B6
MidiRxBuffer        equ       $10B7               complete input packet, up to 64 bytes
MidiPlaying         equ       $10F7               s9p is active

pMidiNewScore      equ       $10F8
pMidiStaffInit       equ       $10FA
pMidiEventPtr      equ       $10FC
FrDriveLabelCmd     equ       $B7                 unused four-argument slot; $CD remains refresh
pConfigCache        equ       $112F               word: C-heap XML cache, header plus 1025 bytes; s9g owns it
pDriveMenu          equ       $112D               word: allocated 64-byte hit table + six 3-byte drive names + count
FranReply           equ       $1100               byte: the path s9 reads s9gui's menu answers from (a second /pipe, s9gui's path 2; sysup)
pPipeMenu           equ       $1101               word: s9's pipemenu - waits for s9gui's answer to a streamed menu, feeding it mouse packets
pMenu3              equ       $1103               word: s9's menu3(desc, states) - streams a condensed text menu to s9gui and waits (pipemenu)
FakeDown            equ       $55                 DP byte: mouce reports the button DOWN that many more polls (a plain click on a rest runs one lap of place's slide loop)
NoAbort             equ       $54                 DP byte: place() keeps a note placed without motion (a plain click on a rest)
WizForce            equ       $53                 DP byte: newscore runs the layout prompts without asking (the Score menu's 'New Score Wizard')
LayDropReset        equ       $52                 DP byte: s9l - a drag was dropped, the next wait puts the mode back to select
MenuStates          equ       $1105               40 bytes: the state text a caller sprintf's for menu3 ('0'/'1' a checkbox, a digit a radio
*                                                 group, CR-ended text a field)
* THE PIANO KEYS WHILE s9p PLAYS (painting inline disturbed the tempo): no menu runs while s9p plays, so its
* key queue borrows MenuStates. s9's PianoDraw jsr's [PianoVec] instead of painting while MidiPlaying; s9p's
* PianoMark queues the key and PianoFlush paints the queue through s9's PianoPaint, the byte after the rts
* that follows that jsr.
PianoVec            equ       MenuStates          word: s9p's PianoMark, set before MidiPlaying goes up
PianoRts            equ       MenuStates+2        word: the rts after PianoDraw's jsr; s9's PianoPaint is the next byte
PianoQN             equ       MenuStates+4        byte: key changes waiting in PianoQ
PianoQ              equ       MenuStates+5        PianoQMax entries of two bytes: A the key index, B lit (as PianoDraw had them)
PianoQMax           equ       17                  (40 - 5) / 2

* The SCORE EDITOR panel's menu geometry: s9l sends the rows (SendPanelText) and hit-tests them
* (HitCmdMenu); s9's LayHover inverts the row under the pointer. Canvas y counts from the bottom.
LayDX               equ       -1                  the whole panel's column shift, used by s9gui laymenu, s9l's text and
*                                                 hit tests and the three below
MenuRowCol          equ       61+LayDX            the rows' text column
MenuBarLeft         equ       60+LayDX            the hover / click bar: byte columns MenuBarLeft..MenuBarRight
MenuBarRight        equ       77+LayDX            (the panel frame's inner edge is 78+LayDX; 15-character labels end at 75+LayDX)
LayDY               equ       -7                  the whole panel's row shift
LayUp               equ       14                  the panel's lower part raised two text rows (no "Part types" or
*                                                 "Staff Clefs" captions): clefs, frame and field bottom
MenuRowY0           equ       169+LayDY           row 0's y; row i is at MenuRowY0 - i * MenuRowPitch
MenuRowPitch        equ       7                   dots between rows (a glyph is 6 rows high)
MenuRows            equ       14                  rows: Renumber staves ... Exit, no change
LayPanelStyle       equ       1                   the panel's winbox style: 1 = the drop-shadow (3D) box
LayClefByte0        equ       ($3C+LayDX)*4+3     the first clef icon's byte in a 320-byte row (centered on the field)
LayClefPitch        equ       10                  the clefs 20 dots (10 bytes) apart
LayPartByte0        equ       ($3E+LayDX)*4-3     the first part-type icon's byte (6 dots left of column 62+LayDX)
LayPartPitch        equ       12                  the part-type icons 24 dots (three columns) apart
LayXByte            equ       ($4C+LayDX)*4-3     the X button's byte (6 dots left of column 76+LayDX, with the part icons)
LayFieldBot         equ       5+LayUp+LayDY                   the panel field's bottom row (the style 1 frame's bottom line is row 4)

* The TOP MENU BAR: ten compact menus followed by six instant-drive score shortcuts. Ordinary labels
* occupy columns 0-53; the shortcuts are right-aligned as "S0 S1 X0 X1 X2 X3" in columns 62-78, leaving
* column 79 blank.
* Columns are eight-dot glyph columns. s9gui's dmenbar places title i at column MenuBarCi and s9g's
* MenuTemplate (x1,y1,x2,y2: columns and canvas rows) is built from the same numbers, so a change to a
* label's width goes here AND in its string in s9gui (str_barlabs_i) together.
MenuBarItems        equ       16
MenuBarTitleItems   equ       10                  labels supplied by s9gui's barlabs[] pointer table
MenuBarCol0         equ       0
MenuBarY1           equ       185                 the bar's hover / click rows = its six text rows (canvas 185-190, raster rows 6-1;
MenuBarY2           equ       191                 through raster row 0 = canvas 191, the black line: the hover block is 7 rows)
MenuBarW0           equ       5                   " File"
MenuBarW1           equ       6                   " Score"
MenuBarW2           equ       5                   " Opts"
MenuBarW3           equ       5                   " Inst"
MenuBarW4           equ       5                   " MIDI"
MenuBarW5           equ       6                   " Tools"
MenuBarW6           equ       5                   " Goto"
MenuBarW7           equ       6                   " Block"
MenuBarW8           equ       5                   " Misc"
MenuBarW9           equ       6                   "  Play"
MenuBarW10          equ       3                   " S0"
MenuBarW11          equ       3                   " S1"
MenuBarW12          equ       3                   " X0"
MenuBarW13          equ       3                   " X1"
MenuBarW14          equ       3                   " X2"
MenuBarW15          equ       3                   " X3"
MenuBarC0           equ       MenuBarCol0
MenuBarC1           equ       MenuBarC0+MenuBarW0
MenuBarC2           equ       MenuBarC1+MenuBarW1
MenuBarC3           equ       MenuBarC2+MenuBarW2
MenuBarC4           equ       MenuBarC3+MenuBarW3
MenuBarC5           equ       MenuBarC4+MenuBarW4
MenuBarC6           equ       MenuBarC5+MenuBarW5
MenuBarC7           equ       MenuBarC6+MenuBarW6
MenuBarC8           equ       MenuBarC7+MenuBarW7
MenuBarC9           equ       MenuBarC8+MenuBarW8
MenuBarC10          equ       61
MenuBarC11          equ       64
MenuBarC12          equ       67
MenuBarC13          equ       70
MenuBarC14          equ       73
MenuBarC15          equ       76
MenuBarEnd          equ       79                  first column past X3; column 79 itself is the right margin

* THE PRINTF FORMATS FOR S9GUI'S COMMANDS (from bglob.c): two strings, apct7 = '%c%c%c%c%c%c%c'
* and apctn6 = '%c%c%c%c%c%c' + CR, and twelve direct-page pointers into them - pctN points N conversions
* before the end of apct7 (N bytes, no CR), pctnN N before the end of apctn6 (N bytes then the CR that ends a
* s9gui command line). printf(<pctn2, $C4, n) sends a command byte and one argument, and so on. Declared in
* bglob.c in this order, so they sit at <$0A..<$20; every module that talks to s9gui uses them.
pct2                equ       $0A                 '%c%c'
pct3                equ       $0C
pct4                equ       $0E
pct5                equ       $10
pct6                equ       $12
pct7                equ       $14                 '%c%c%c%c%c%c%c' (no CR)
pctn1               equ       $16                 '%c' + CR
pctn2               equ       $18                 '%c%c' + CR
pctn3               equ       $1A
pctn4               equ       $1C
pctn5               equ       $1E
pctn6               equ       $20                 '%c%c%c%c%c%c' + CR

* TEXT GLYPHS AND S9GUI TEXT GEOMETRY. Chars16 draws $20-$7F; $1D-$1F are appended glyphs
* that s9gui's VannaBody maps to FrArrowGlyphs. $60/$7F are the checkbox glyphs of the toggle rows.
GlyphArrowRight     equ       $1D                 text control: right arrow (appended glyph 0)
GlyphArrowUp        equ       $1E                 text control: up arrow (appended glyph 1)
GlyphArrowDown      equ       $1F                 text control: down arrow (appended glyph 2)
GlyphArrowFirst     equ       GlyphArrowRight     the first appended glyph code
GlyphArrowCount     equ       GlyphArrowDown-GlyphArrowFirst+1
GlyphBytes          equ       24                  one 8x6 HIRES4 glyph: six rows of four bytes
GlyphBoxOff         equ       $60                 empty checkbox
GlyphBoxOn          equ       $7F                 filled checkbox
TextLineH           equ       7                   dots per text line (s9gui's y grows upward)
TextTopPad          equ       4                   dots between a text window's top and its first line
FrInvert            equ       $B8                 nboxa: col1, row1, col2, row2 - inverts a rectangle on both pages

* THE MIDI MENU (s9m 'm'). The part->channel table and the two switch arrays are shared data;
* a note plays only when MidiPartOn[part] AND MidiChanOn[channel] are set (s9p NoteEvent).
MidiChanTbl         equ       UmeData_reserved_03F3  17 bytes: [part 1-16] = MIDI channel 0-15
MidiPartOn          equ       MidiChanTbl+17      17 bytes: [part 1-16] nonzero = the part plays
MidiChanOn          equ       MidiPartOn+17       17 bytes: [channel 0-15] nonzero = the channel plays
MenuDropY           equ       MenuBarY1           a drop-down menu's top y: its frame cuts one scanline into the bar
MenuDropX           equ       1                   a bar menu's window left text column = its title's column + MenuDropX;
*                                                 ctxma's packet column is one
*                                                 more (its window is col-1), so its descriptors use MenuBarCn+MenuDropX+1.
MidiMenuCol         equ       MenuBarC4+MenuDropX the menu window's left text column
MidiMenuTop         equ       MenuDropY           the menu window's top y
ExitBoxCol          equ       MenuBarC0+MenuDropX+10  the Exit this app? box: 10 columns right of the File menu's window
ExitBoxY            equ       MenuDropY-9*TextLineH  and 9 text rows down from its top
YesNoBlackW         equ       18                  the black yes/no box's width: half the paper box's 36
YesNoBlackYesDX     equ       7                   its YES sits this many columns further left than in the paper box,
YesNoBlackNoDX      equ       11                  its NO this many;
*                                                 s9's yesnoAt moves the NO click area by the same
YesNoBlackYesHitDX  equ       8                   and the YES click area this many, so it ends where NO's begins (YES is tested first)
MidiSubCol          equ       $21                the MIDI menu's sub-menus (Modes, Levels): window left text column - Levels'
MidiSubTop          equ       MidiMenuTop-4*TextLineH  their top y: 4 text rows down from the MIDI menu's top
MidiMenuW           equ       $1A                 window width (columns)
MidiMenuH           equ       $14                 window height (lines)
MidiMenuHead        equ       2                   lines above the part rows: title, column header
MidiMenuRows        equ       16                  picker rows: 8 part rows, a blank, 6 command rows, the blank above Choice:
MidiPickW           equ       $0D                 picker cell width: half a row, so every item highlights whole
MidiPickCols        equ       2
MidiHalfCols        equ       13                  text columns from the left half to the right half
MidiChanBoxCol      equ       6                   a click at or right of this text column of a half: the channel box
MidiChanCol         equ       9                   ...of this one: the channel number (the left half's channel column)

* THE SHEET REDRAW WITHOUT ITS CLS: a note dropped on the staff - slid up or down, or
* put straight onto a rest - is followed by the sheet redraw that already takes place; that redraw
* skips the screen clearing. rfr_scr (bmuse.c's bool, DP $7C) carries a third value, and s9s has a second
* entry into the same draw code, after the cls (the cls is at the top of DrawScreen).
RfrScrKeep          equ       2                   rfr_scr: 0 = no redraw, 1 = clear the sheet and draw it, 2 = draw it over what is there
SJobRedraw          equ       's                  s9s job letters (soowee('S', job)): the sheet draw, cls first
SJobRedrawKeep      equ       'n                  the same draw entered after the cls
SheetRowTop         equ       184                 the sheet's rows (s9gui's y grows upward): the cls clears SheetRowBottom..SheetRowTop
SheetRowBottom      equ       8                   (row 8 is just above the scroll bar, 184 just under the menu bar)
* The anchor of the last full draw: a
* click stores the dropped note into gind/xgoal (bmuse.c: keep the target in the same spot), and a draw from
* that anchor is a different layout (no clef indentation when gind != 0, the backward pass rounds the other
* way). Every 's' draw saves its settled gind/xgoal here after the silent layout round; the 'n' job draws
* with these and puts the click's values back, so the no-cls redraw lands on the same pixels as the last draw.
KeepGind            equ       $10FE               word: gind (DP $89) as the last full draw settled it
KeepXgoal           equ       $10AA               word: xgoal (DP $85) likewise ($10AA-$10AB: between MidiRoutePaths' four bytes and pSAMSend)

Note128Bit          equ       $40                 note/rest packet: 128th (64th + red dot); articulation bits 3..5

* ===== s9: module-scoped definitions =====
                    ifdef     UME_SCOPE_UMUSE3
* From UMusE3.asm; C clue: bdp.c:21
mydat0              equ       UmeData_mydat0
* From UMusE3.asm; C clue: bdp.c:25
curevp              equ       UmeData_curevp
* From UMusE3.asm; C clue: bdp.c:26
database            equ       UmeData_database
* From UMusE3.asm; C clue: bdp.c:27
curptop             equ       UmeData_curptop
* From UMusE3.asm; C clue: bdp.c:29
nevents             equ       UmeData_nevents
* From UMusE3.asm; C clue: bdp.c:30
curind              equ       UmeData_curind
* From UMusE3.asm; C clue: bdp.c:32
group               equ       UmeData_group
* From UMusE3.asm; C clue: bdp.c:33
curpage             equ       UmeData_curpage
* From UMusE3.asm; C clue: bdp.c:34
nmpages             equ       UmeData_nmpages
* From UMusE3.asm; C clue: bdp.c:38
godotind            equ       UmeData_godotind
* From UMusE3.asm; C clue: bdp.c:39
undind              equ       UmeData_undind
* From UMusE3.asm; C clue: bdp.c:43
forergb             equ       UmeData_forergb
* From UMusE3.asm; C clue: bdp.c:43
backrgb             equ       UmeData_backrgb
* From UMusE3.asm; C clue: bdp.c:45
hires               equ       UmeData_hires
* From UMusE3.asm; C clue: bdp.c:46
midiser             equ       UmeData_midiser
* From UMusE3.asm; C clue: bdp.c:47
midipak             equ       UmeData_midipak
* From UMusE3.asm; C clue: bdp.c:48
readonly            equ       UmeData_readonly
* From UMusE3.asm; C clue: bdp.c:50
printype            equ       UmeData_printype
* From UMusE3.asm; C clue: bdp.c:52
instren             equ       UmeData_instren
* From UMusE3.asm; C clue: bdp.c:53
mididev             equ       UmeData_mididev
* From UMusE3.asm; C clue: bdp.c:54
clocken             equ       UmeData_clocken
* From UMusE3.asm; C clue: bdp.c:55
left                equ       UmeData_left
* From UMusE3.asm; C clue: bdp.c:56
midievts            equ       UmeData_midievts
* From UMusE3.asm; C clue: bdp.c:58
midinnmin           equ       UmeData_midinnmin
* From UMusE3.asm; C clue: bdp.c:58
midinnmax           equ       UmeData_midinnmax
* From UMusE3.asm; C clue: bdp.c:60
accentwt            equ       UmeData_accentwt
* From UMusE3.asm; C clue: bdp.c:62
pitcarry            equ       UmeData_pitcarry
* From UMusE3.asm; C clue: bdp.c:63
snap                equ       UmeData_snap
* From UMusE3.asm; C clue: bdp.c:64
sticky              equ       UmeData_sticky
* From UMusE3.asm; C clue: bdp.c:65
doesff              equ       UmeData_doesff
* From UMusE3.asm; C clue: bdp.c:65
automarg            equ       UmeData_automarg
* From UMusE3.asm; C clue: bdp.c:66
beam                equ       UmeData_beam
* From UMusE3.asm; C clue: bdp.c:66
thick               equ       UmeData_thick
* From UMusE3.asm; C clue: bdp.c:67
halfstaf            equ       UmeData_halfstaf
* From UMusE3.asm; C clue: bdp.c:74
xyoff               equ       UmeData_xyoff
* From UMusE3.asm; C clue: bdp.c:77
nparts              equ       UmeData_nparts
* From UMusE3.asm; C clue: bdp.c:78
nstaves             equ       UmeData_nstaves
* From UMusE3.asm; C clue: bdp.c:79
keysig              equ       UmeData_keysig
* From UMusE3.asm; C clue: bdp.c:80
secmin              equ       UmeData_secmin
* From UMusE3.asm; C clue: bdp.c:81
transp              equ       UmeData_transp
* From UMusE3.asm; C clue: bdp.c:82
velo                equ       UmeData_velo
* From UMusE3.asm; C clue: bdp.c:86
nbars               equ       UmeData_nbars
* From UMusE3.asm; C clue: bdp.c:86
scorelvl            equ       UmeData_scorelvl
* From UMusE3.asm; C clue: bdp.c:89
dencodur            equ       UmeData_dencodur
* From UMusE3.asm; C clue: bdp.c:90
nzones              equ       UmeData_nzones
* From UMusE3.asm; C clue: bdp.c:93
dendur              equ       UmeData_dendur
* From UMusE3.asm; C clue: bdp.c:94
zonedur             equ       UmeData_zonedur
* From UMusE3.asm; C clue: bdp.c:97
uptime              equ       UmeData_uptime
* From UMusE3.asm; C clue: bdp.c:97
dntime              equ       UmeData_dntime
* From UMusE3.asm; C clue: bdp.c:98
curcurse            equ       UmeData_curcurse
* From UMusE3.asm; C clue: bdp.c:99
broke               equ       UmeData_broke
* From UMusE3.asm; C clue: bdp.c:102
pldebug             equ       UmeData_pldebug
* From UMusE3.asm; C clue: bdp.c:103
aborted             equ       UmeData_aborted
* From UMusE3.asm; C clue: bdp.c:104
compact             equ       UmeData_compact
* From UMusE3.asm; C clue: bdp.c:90
tripper             equ       UmeData_tripper
* From UMusE3.asm; C clue: bdp.c:106
rfr_scr             equ       UmeData_rfr_scr
* From UMusE3.asm; C clue: bdp.c:107
rfr_men             equ       UmeData_rfr_men
* From UMusE3.asm; C clue: bdp.c:108
rfr_rep             equ       UmeData_rfr_rep
* From UMusE3.asm; C clue: bdp.c:109
rfr_bar             equ       UmeData_rfr_bar
* From UMusE3.asm; C clue: bdp.c:110
rfr_tit             equ       UmeData_rfr_tit
* From UMusE3.asm; C clue: bdp.c:111
automon             equ       UmeData_automon
* From UMusE3.asm; C clue: bdp.c:112
dosqueez            equ       UmeData_dosqueez
* From UMusE3.asm; C clue: bdp.c:113
scrclock            equ       UmeData_scrclock
* From UMusE3.asm; C clue: bdp.c:114
smf                 equ       UmeData_smf
* From UMusE3.asm; C clue: bdp.c:118
xgoal               equ       UmeData_xgoal
* From UMusE3.asm; C clue: bdp.c:119
gbar                equ       UmeData_gbar
* From UMusE3.asm; C clue: bdp.c:118
gind                equ       UmeData_gind
* From UMusE3.asm; C clue: bdp.c:125
gbarind             equ       UmeData_gbarind
* From UMusE3.asm; C clue: bdp.c:126
ritind              equ       UmeData_ritind
* From UMusE3.asm; C clue: bdp.c:126
lftind              equ       UmeData_lftind
* From UMusE3.asm; C clue: bdp.c:93
length              equ       UmeData_length
* From UMusE3.asm; C clue: bdp.c:135, fcnptrs.h:23
arg0                equ       UmeData_arg0
* From UMusE3.asm; C clue: bdp.c:135
arg1                equ       UmeData_arg1
* From UMusE3.asm; C clue: bdp.c:135
arg2                equ       UmeData_arg2
* From UMusE3.asm; C clue: bdp.c:135
arg3                equ       UmeData_arg3
* From UMusE3.asm; C clue: bdp.c:135
arg4                equ       UmeData_arg4
* From UMusE3.asm; C clue: bdp.c:135
arg5                equ       UmeData_arg5
* From UMusE3.asm; C clue: bdp.c:135
arg6                equ       UmeData_arg6
* From UMusE3.asm; C clue: bdp.c:135
arg7                equ       UmeData_arg7
* From UMusE3.asm; C clue: bdp.c:141
rshift              equ       UmeData_rshift
* From UMusE3.asm; C clue: bdp.c:142
vslot               equ       UmeData_vslot
* From UMusE3.asm; C clue: bdp.c:144
strleft             equ       UmeData_strleft
* From UMusE3.asm; C clue: bdp.c:145
trileft             equ       UmeData_trileft
* From UMusE3.asm; C clue: bdp.c:147
durleft             equ       UmeData_durleft
* From UMusE3.asm; C clue: bdp.c:149
tripnow             equ       UmeData_tripnow
* From UMusE3.asm; C clue: bdp.c:162
midics              equ       UmeData_midics
* From UMusE3.asm; C clue: bdp.c:80
tempo               equ       UmeData_tempo
* From UMusE3.asm; C clue: bdp.c:165
machtemp            equ       UmeData_machtemp
* From UMusE3.asm; C clue: bdp.c:166
contemp             equ       UmeData_contemp
* From UMusE3.asm; C clue: bdp.c:167
smfdelta            equ       UmeData_smfdelta
* From UMusE3.asm; C clue: bdp.c:168
midicnt             equ       UmeData_midicnt
* From UMusE3.asm; C clue: bdp.c:170
sound               equ       UmeData_sound
* From UMusE3.asm; C clue: bdp.c:170
inending            equ       UmeData_inending
* From UMusE3.asm; C clue: bdp.c:171
senzarep            equ       UmeData_senzarep
* From UMusE3.asm; C clue: bdp.c:172
rsptr               equ       UmeData_rsptr
* From UMusE3.asm; C clue: bdp.c:174
plpart              equ       UmeData_plpart
* From UMusE3.asm; C clue: bdp.c:174
plslot              equ       UmeData_plslot
* From UMusE3.asm; C clue: bdp.c:174
white               equ       UmeData_white
* From UMusE3.asm; C clue: bdp.c:174
midnote             equ       UmeData_midnote
* From UMusE3.asm; C clue: bdp.c:174
oldmid              equ       UmeData_oldmid
* From UMusE3.asm; C clue: bdp.c:174
chrind              equ       UmeData_chrind
* From UMusE3.asm; C clue: bdp.c:174
fix                 equ       UmeData_fix
* From UMusE3.asm; C clue: bdp.c:175
plart               equ       UmeData_plart
* From UMusE3.asm; C clue: bdp.c:175
midchan             equ       UmeData_midchan
* From UMusE3.asm; C clue: bdp.c:175
accent              equ       UmeData_accent
* From UMusE3.asm; C clue: bdp.c:175
runstat             equ       UmeData_runstat
* From UMusE3.asm
dp_sign             equ       UmeData_dp_sign
* From UMusE3.asm; C clue: bdp.c:177
dcds                equ       UmeData_dcds
* From UMusE3.asm; C clue: bdp.c:178
nthendx             equ       UmeData_nthendx
* From UMusE3.asm; C clue: bdp.c:179
coda                equ       UmeData_coda
* From UMusE3.asm; C clue: bdp.c:181
residue             equ       UmeData_residue
* From UMusE3.asm; C clue: bdp.c:149
now                 equ       UmeData_now
* From UMusE3.asm; C clue: bdp.c:183
lastime             equ       UmeData_lastime
* From UMusE3.asm; C clue: bdp.c:185
delt                equ       UmeData_delt
* From UMusE3.asm; C clue: bdp.c:187, fcnptrs.h:36
fmidi               equ       UmeData_fmidi
* From UMusE3.asm; C clue: bdp.c:190
takeoff             equ       UmeData_takeoff
* From UMusE3.asm; C clue: bdp.c:191
tilloff             equ       UmeData_tilloff
* From UMusE3.asm; C clue: bdp.c:192
ttemp               equ       UmeData_ttemp
* From UMusE3.asm; C clue: bdp.c:194
towait              equ       UmeData_towait
* From UMusE3.asm; C clue: bdp.c:197
crdelt              equ       UmeData_crdelt
* From UMusE3.asm; C clue: bdp.c:197
acdelt              equ       UmeData_acdelt
* From UMusE3.asm; C clue: bdp.c:199
crbeglvl            equ       UmeData_crbeglvl
* From UMusE3.asm; C clue: bdp.c:199
acbegmt             equ       UmeData_acbegmt
* From UMusE3.asm; C clue: bdp.c:200
crmult              equ       UmeData_crmult
* From UMusE3.asm; C clue: bdp.c:200
acmult              equ       UmeData_acmult
* From UMusE3.asm; C clue: bdp.c:200
acscale             equ       UmeData_acscale
* From UMusE3.asm; C clue: bglob.c:36
autooct             equ       UmeData_autooct
* From UMusE3.asm; C clue: bglob.c:43
kpmode              equ       UmeData_kpmode
* From UMusE3.asm; C clue: bglob.c:48
kpoctch             equ       UmeData_kpoctch
* From UMusE3.asm; C clue: bglob.c:49
kpnotch             equ       UmeData_kpnotch
* From UMusE3.asm; C clue: bglob.c:52
kpdur               equ       UmeData_kpdur
* From UMusE3.asm; C clue: bglob.c:54
kpartic             equ       UmeData_kpartic
* From UMusE3.asm; C clue: bglob.c:56
kpoctave            equ       UmeData_kpoctave
* From UMusE3.asm; C clue: bglob.c:57
kplnotenum          equ       UmeData_kplnotenum
* From UMusE3.asm; C clue: bglob.c:93
brush               equ       UmeData_brush
* From UMusE3.asm; C clue: bglob.c:181
clefs               equ       UmeData_clefs
* From UMusE3.asm; C clue: bglob.c:20
toolson             equ       UmeData_toolson
* From UMusE3.asm; C clue: bglob.c:29
lastclik            equ       UmeData_lastclik
* From UMusE3.asm; C clue: bglob.c:30
kpind               equ       UmeData_kpind
* From UMusE3.asm; C clue: bglob.c:31
kplast              equ       UmeData_kplast
* From UMusE3.asm; C clue: bglob.c:32
kplastact           equ       UmeData_kplastact
* From UMusE3.asm; C clue: bglob.c:37
autopick            equ       UmeData_autopick
* From UMusE3.asm; C clue: bglob.c:39
autoclone           equ       UmeData_autoclone
* From UMusE3.asm; C clue: bglob.c:40
kpclone             equ       UmeData_kpclone
* From UMusE3.asm; C clue: bglob.c:53
kpdmod              equ       UmeData_kpdmod
* From UMusE3.asm; C clue: bglob.c:53
kpitmod             equ       UmeData_kpitmod
* From UMusE3.asm; C clue: bglob.c:55
kvslot              equ       UmeData_kvslot
* From UMusE3.asm; C clue: bglob.c:81
grafxes             equ       UmeData_grafxes
* From UMusE3.asm; C clue: bglob.c:82
grafyes             equ       UmeData_grafyes
* From UMusE3.asm; C clue: bglob.c:173
staves              equ       UmeData_staves
* From UMusE3.asm; C clue: bglob.c:176
parts               equ       UmeData_parts
* From UMusE3.asm; C clue: fcnptrs.h:14
pcharmaus           equ       UmeData_pcharmaus
* From UMusE3.asm; C clue: fcnptrs.h:14
pkeymaus            equ       UmeData_pkeymaus
* From UMusE3.asm; C clue: fcnptrs.h:14
pinkey              equ       UmeData_pinkey
* From UMusE3.asm; C clue: fcnptrs.h:14
pgets               equ       UmeData_pgets
* From UMusE3.asm; C clue: fcnptrs.h:17
pfindstaff          equ       UmeData_pfindstaff
* From UMusE3.asm; C clue: fcnptrs.h:20
pprintf             equ       UmeData_pprintf
* From UMusE3.asm; C clue: fcnptrs.h:20
psprintf            equ       UmeData_psprintf
* From UMusE3.asm; C clue: fcnptrs.h:21
powrite             equ       UmeData_powrite
* From UMusE3.asm; C clue: fcnptrs.h:22
psoowee             equ       UmeData_psoowee
* From UMusE3.asm; C clue: fcnptrs.h:23
pnfwrite            equ       UmeData_pnfwrite
* From UMusE3.asm; C clue: fcnptrs.h:24
pgksig              equ       UmeData_pgksig
* From UMusE3.asm; C clue: fcnptrs.h:25
pgtsig              equ       UmeData_pgtsig
* From UMusE3.asm; C clue: fcnptrs.h:26
paddclone           equ       UmeData_paddclone
* From UMusE3.asm; C clue: fcnptrs.h:27
ppluspart           equ       UmeData_ppluspart
* From UMusE3.asm; C clue: fcnptrs.h:28
paddbars            equ       UmeData_paddbars
* From UMusE3.asm; C clue: fcnptrs.h:29
prepart             equ       UmeData_prepart
* From UMusE3.asm; C clue: fcnptrs.h:30
pievtinit           equ       UmeData_pievtinit
* From UMusE3.asm; C clue: fcnptrs.h:30
ptextmen            equ       UmeData_ptextmen
* From UMusE3.asm
pbeep               equ       UmeData_pbeep
* From UMusE3.asm; C clue: fcnptrs.h:33
pflush              equ       UmeData_pflush
* From UMusE3.asm; C clue: fcnptrs.h:34
palert              equ       UmeData_palert
* From UMusE3.asm; C clue: fcnptrs.h:35
phit                equ       UmeData_phit
* From UMusE3.asm; C clue: fcnptrs.h:36
pputmidi            equ       UmeData_pputmidi
* From UMusE3.asm; C clue: fcnptrs.h:37
pmflush             equ       UmeData_pmflush
* From UMusE3.asm; C clue: fcnptrs.h:38
pputchar            equ       UmeData_pputchar
* From UMusE3.asm; C clue: fcnptrs.h:39
pfmarks             equ       UmeData_pfmarks
* From UMusE3.asm; C clue: fcnptrs.h:39
pfixup              equ       UmeData_pfixup
* From UMusE3.asm; C clue: fcnptrs.h:40
psmfwrit            equ       UmeData_psmfwrit
* From UMusE3.asm; C clue: fcnptrs.h:41
pdrawnr             equ       UmeData_pdrawnr
* From UMusE3.asm; C clue: fcnptrs.h:42
ppartline           equ       UmeData_ppartline
* From UMusE3.asm; C clue: fcnptrs.h:43
pgivebac            equ       UmeData_pgivebac
* From UMusE3.asm; C clue: fcnptrs.h:43
pfindts             equ       UmeData_pfindts
* From UMusE3.asm; C clue: fcnptrs.h:43
pplay               equ       UmeData_pplay
* From UMusE3.asm; C clue: fcnptrs.h:43
ptranprt            equ       UmeData_ptranprt
* From UMusE3.asm; C clue: fcnptrs.h:43
pclonmid            equ       UmeData_pclonmid
* From UMusE3.asm; C clue: fcnptrs.h:46
ppswap              equ       UmeData_ppswap
* From UMusE3.asm; C clue: fcnptrs.h:47
pfixmarx            equ       UmeData_pfixmarx
* From UMusE3.asm; C clue: fcnptrs.h:48
pparse              equ       UmeData_pparse
* From UMusE3.asm; C clue: fcnptrs.h:48
pmouce              equ       UmeData_pmouce
* From UMusE3.asm; C clue: fcnptrs.h:48
pyesno              equ       UmeData_pyesno
* From UMusE3.asm; C clue: fcnptrs.h:49
pexprmenu           equ       UmeData_pexprmenu
* From UMusE3.asm; C clue: fcnptrs.h:50
pgetempty           equ       UmeData_pgetempty
* From UMusE3.asm; C clue: fcnptrs.h:53
pswapevts           equ       UmeData_pswapevts
* From UMusE3.asm; C clue: fcnptrs.h:56
pregen              equ       UmeData_pregen
* From UMusE3.asm; C clue: fcnptrs.h:57
pcod2raw            equ       UmeData_pcod2raw
* From UMusE3.asm; C clue: fcnptrs.h:60
penter              equ       UmeData_penter
* From UMusE3.asm; C clue: fcnptrs.h:60
premove             equ       UmeData_premove
* From UMusE3.asm; C clue: fcnptrs.h:60
pchip               equ       UmeData_pchip
* From UMusE3.asm; C clue: fcnptrs.h:63
pfulltime           equ       UmeData_pfulltime
* From UMusE3.asm; C clue: fcnptrs.h:66
pmakroom            equ       UmeData_pmakroom
* From UMusE3.asm
GPTab               equ       $1000               one byte per buffer: its RAM block, 0 = none
* From UMusE3.asm
GPTABSZ             equ       64                  buffer numbers 0..63 (pages, plus 34 for events)
* From UMusE3.asm
GPMapped            equ       $1040               which buffer is mapped right now, 0 = none
* From UMusE3.asm
GPAddr              equ       $1042               and the address it was mapped at
* From UMusE3.asm
FranParam           equ       $1044               3 bytes: s9gui's fork parameters - s9's tail blocks 6 and 7 (PianoBM.. reuse them once s9gui runs)
* From UMusE3.asm
GPBLKS              equ       $01                 one 8K block per buffer
* From UMusE3.asm
VKY.GfxMode         equ       $FFCB
* From UMusE3.asm
VKY.BackdropB       equ       $FFCD               bitmap index 0 reveals this fixed-I/O B/G/R backdrop
* From UMusE3.asm
VKY.BackdropG       equ       $FFCE
* From UMusE3.asm
VKY.BackdropR       equ       $FFCF
* From UMusE3.asm
ModuleBase          equ       $0000
* From UMusE3.asm
PianoBM             equ       $1044               bitmap 0's first block (0 = none: nothing drawn)
* From UMusE3.asm
PianoBM1            equ       $1045               bitmap 1's first block (0 = none)
* From UMusE3.asm
PianoStat           equ       $1046               the running status
* From UMusE3.asm
PianoPend           equ       $1047               the note waiting for its velocity, or the flags above
* From UMusE3.asm
MoveNoteAttrs       equ       0                   STACK OFFSET: movenote S frame, five copied note attributes
MoveNoteFrame       equ       5                   STACK FRAME SIZE: movenote temporary attributes
MoveNoteArg         equ       MoveNoteFrame+4     STACK OFFSET: movenote S frame, caller event-index word
PianoSym            equ       $10B0               the tail block holding the symbol bank's second part (the key images)
* From UMusE3.asm
PianoImages         equ       $28C4-$1B00         the up CF image, into that block: DGA +150, EB +300, Black +450
* From UMusE3.asm
PianoPressed        equ       510                 the pressed images follow the four up ones
                    endc

* ===== s9gui: module-scoped definitions (s9gui runs as a separate process) =====
                    ifdef     UME_SCOPE_S9GUI
* From s9gui.asm
FrImageOrg          equ       $00B0               tblInitData block 2 lands here (CStart); the image labels give the rest
FrDriveText         equ       $3A7F               six five-byte position/label records received from s9g
* From s9gui.asm
FrArrowGlyphs       equ       FrDriveText+30       the appended 8x6 font glyphs (GlyphArrowFirst..); separate from the old font arena
FrMidiPath          equ       FrArrowGlyphs+GlyphArrowCount*GlyphBytes  path+1; zero unopened, FF open failed
FrMidiShown         equ       FrMidiPath+1          last drawn receive activity
FrToolY             equ       FrMidiShown+1      word: saved toolbox background bottom Y
FrToolUp            equ       FrToolY+2          byte: background valid for current toolbox
FrToolImage         equ       $3A00              virtual token: captured toolbox in FrSave arena
FrToolSave          equ       $4000              virtual token into FrSave arena, NOT process memory
FrToolX             equ       FrToolUp+1          word: current toolbox left byte column
FrDragSave          equ       FrToolX+2          word: dedicated eight-block full-canvas drag snapshot
FrWinInv            equ       FrDragSave+2       byte: non-zero = the text window is a menu (WinMenu) - its glyphs
*                                                 come from the inverted font, its clears are the menu interior; kept per window
FrDataEnd           equ       FrWinInv+1
* From s9gui.asm
FrFocusInk          equ       $0077               unused low byte of the retired bptr word (FrChrome owns $76)
* From s9gui.asm; C clue: bdp.c:135, fcnptrs.h:23
arg0                equ       FrData_arg0
* From s9gui.asm; C clue: bdp.c:135
arg1                equ       FrData_arg1
* From s9gui.asm; C clue: bdp.c:135
arg2                equ       FrData_arg2
* From s9gui.asm; C clue: bdp.c:135
arg3                equ       FrData_arg3
* From s9gui.asm; C clue: bdp.c:135
arg4                equ       FrData_arg4
* From s9gui.asm; C clue: bdp.c:135
arg5                equ       FrData_arg5
* From s9gui.asm; C clue: bdp.c:135
arg6                equ       FrData_arg6
* From s9gui.asm; C clue: bdp.c:99
broke               equ       FrData_broke
* From s9gui.asm
lastaffy            equ       FrData_lastaffy
* From s9gui.asm
lastclef            equ       FrData_lastclef
* From s9gui.asm
lastnrx             equ       FrData_lastnrx
* From s9gui.asm
lastnry             equ       FrData_lastnry
* From s9gui.asm; C clue: bdp.c:77
nparts              equ       FrData_nparts
* From s9gui.asm; C clue: bdp.c:78
nstaves             equ       FrData_nstaves
* From s9gui.asm; C clue: bdp.c:79
keysig              equ       FrData_keysig
* From s9gui.asm
brushx              equ       FrData_brushx
* From s9gui.asm
brushy              equ       FrData_brushy
* From s9gui.asm; C clue: bglob.c:19
tooly               equ       FrData_tooly
* From s9gui.asm; C clue: bdp.c:98
curcurse            equ       FrData_curcurse
* From s9gui.asm; C clue: bdp.c:88
numer               equ       FrData_numer
* From s9gui.asm; C clue: bdp.c:88
denom               equ       FrData_denom
* From s9gui.asm
pnrows              equ       FrData_pnrows
* From s9gui.asm; C clue: bdp.c:17
dummy               equ       FrData_dummy
* From s9gui.asm
vdgram              equ       FrData_vdgram
* From s9gui.asm
grafmode            equ       FrData_grafmode
* From s9gui.asm
tgwmode             equ       FrData_tgwmode
* From s9gui.asm
wp                  equ       FrData_wp
* From s9gui.asm
alfacurse           equ       FrData_alfacurse
* From s9gui.asm; C clue: bdp.c:66
thick               equ       FrData_thick
* From s9gui.asm
afxi                equ       FrData_afxi
* From s9gui.asm
afxa1               equ       FrData_afxa1
* From s9gui.asm
afxa2               equ       FrData_afxa2
* From s9gui.asm
hgt                 equ       FrData_hgt
* From s9gui.asm
width               equ       FrData_width
* From s9gui.asm
dy                  equ       FrData_dy
* From s9gui.asm
xl                  equ       FrData_xl
* From s9gui.asm
xr                  equ       FrData_xr
* From s9gui.asm
ibase               equ       FrData_ibase
* From s9gui.asm
iptr                equ       FrData_iptr
* From s9gui.asm
igoal               equ       FrData_igoal
* From s9gui.asm
paint               equ       FrData_paint
* From s9gui.asm
color               equ       FrData_color
* From s9gui.asm
col                 equ       FrData_col
* From s9gui.asm
bgoal               equ       FrData_bgoal
* From s9gui.asm
cleft               equ       FrData_cleft
* From s9gui.asm
cright              equ       FrData_cright
* From s9gui.asm
ctop                equ       FrData_ctop
* From s9gui.asm
cbot                equ       FrData_cbot
* From s9gui.asm
cwid                equ       FrData_cwid
* From s9gui.asm
cheight             equ       FrData_cheight
* From s9gui.asm
curse               equ       FrData_curse
* From s9gui.asm
wncols              equ       FrData_wncols
* From s9gui.asm
wnrows              equ       FrData_wnrows
* From s9gui.asm
wcleft              equ       FrData_wcleft
* From s9gui.asm
wcrght              equ       FrData_wcrght
* From s9gui.asm
wtopy               equ       FrData_wtopy
* From s9gui.asm
wboty               equ       FrData_wboty
* From s9gui.asm
whgt                equ       FrData_whgt
* From s9gui.asm
nowinv              equ       FrData_nowinv
* From s9gui.asm
wsavsiz             equ       FrData_wsavsiz
* From s9gui.asm
stocker             equ       FrData_stocker
* From s9gui.asm
curaddr             equ       FrData_curaddr
* From s9gui.asm
homeaddr            equ       FrData_homeaddr
* From s9gui.asm
curcol              equ       FrData_curcol
* From s9gui.asm
currow              equ       FrData_currow
* From s9gui.asm
curpx               equ       FrData_curpx
* From s9gui.asm
curpy               equ       FrData_curpy
* From s9gui.asm
texsave             equ       FrData_texsave
* From s9gui.asm
fprtr               equ       FrData_fprtr
* From s9gui.asm
printy              equ       FrData_printy
* From s9gui.asm; C clue: bdp.c:50
printype            equ       FrData_printype
* From s9gui.asm
prpage              equ       FrData_prpage
* From s9gui.asm
dosqueeze           equ       FrData_dosqueeze
* From s9gui.asm; C clue: bdp.c:65
doesff              equ       FrData_doesff
* From s9gui.asm; C clue: bdp.c:65
automarg            equ       FrData_automarg
* From s9gui.asm
fes                 equ       FrData_fes
* From s9gui.asm; C clue: bglob.c:93
brush               equ       FrData_brush
* From s9gui.asm; C clue: bglob.c:94
qnote               equ       FrData_qnote
* From s9gui.asm; C clue: bglob.c:95
qrest               equ       FrData_qrest
* From s9gui.asm
cursors             equ       FrData_cursors
* From s9gui.asm
brushsave           equ       FrData_brushsave
* From s9gui.asm; C clue: bglob.c:173
staves              equ       FrData_staves
* From s9gui.asm; C clue: bglob.c:176
parts               equ       FrData_parts
* From s9gui.asm
bdeltx              equ       FrData_bdeltx
* From s9gui.asm
bdelty              equ       FrData_bdelty
* From s9gui.asm
bx1                 equ       FrData_bx1
* From s9gui.asm
by1                 equ       FrData_by1
* From s9gui.asm
bdy                 equ       FrData_bdy
* From s9gui.asm
bbp                 equ       FrData_bbp
* From s9gui.asm
wstack              equ       FrData_wstack
* From s9gui.asm
spacestk            equ       FrData_spacestk
* From s9gui.asm
spaceind            equ       FrData_spaceind
* From s9gui.asm; C clue: bdp.c:153, bglob.c:62, fcnptrs.h:6
space               equ       FrData_space
* From s9gui.asm
FrWin               equ       $003D               picture block (0-8) at the front of the window, $FF = none
* From s9gui.asm
FrWinP              equ       $003E               where the two-block window is mapped (word), 0 = not mapped
* From s9gui.asm
FrBM0               equ       $006F               first physical block of bitmap 0
* From s9gui.asm
Fr4Src              equ       $006E               non-zero while a primitive draws four-bit rows staged in FrStage
* From s9gui.asm
* From s9gui.asm
* From s9gui.asm
* From s9gui.asm
* From s9gui.asm
* From s9gui.asm
* From s9gui.asm
* From s9gui.asm
* From s9gui.asm
FrDma               equ       $3A79               byte: 1 = the DMA engine is there and the large clears/copies use it
* From s9gui.asm
FrTxtInk            equ       $3A7A               byte: non-zero = PutGlyph recolors the font's white ($F) to this
* From s9gui.asm
FrShown             equ       $3A7B               byte: the bitmap layer 0 shows, 0 or 1 (double buffering)
* From s9gui.asm
FrBMShown           equ       $3A7C               byte: the shown bitmap's first block (FrBM0 is the hidden one's); 0 = single-buffered
* From s9gui.asm
FrDirty             equ       whgt                byte: bit k = picture block k (0-7) was drawn into since the last Present (it reuses whgt, <$92)
* From s9gui.asm
FrEcho              equ       curpx               byte: Present's line-editor echo countdown; alcurset always stores 0, so it is unused
* From s9gui.asm
FrBM0Blk            equ       curpy+1             byte: bitmap 0's first block (plane 0 goes back to it at exit)
* From s9gui.asm
FrKeyBank           equ       $3973               word: key-table RAM block, 0 = none
* From s9gui.asm
FrNoDirty           equ       $3975               byte: non-zero while a hover inversion goes onto both bitmaps (in FrFocusMask's byte)
* From s9gui.asm
DmaMinBytes         equ       4096                a rectangle of fewer bytes is faster on the CPU than a wait for the blank
* From s9gui.asm
DmaPolls            equ       16                  x 65536 busy laps before a transfer is called stuck (dmashow's bound)
* From s9gui.asm
DMACTL              equ       $FEC0               b0 enable, b1 2D, b2 fill, b6 word fill, b7 start
* From s9gui.asm
DMASTAT             equ       $FEC1               read: b7 = transfer in progress; write: the fill byte
* From s9gui.asm
DMASRCH             equ       $FEC5               source [23:16], [15:8] at +1, [7:0] at +2
* From s9gui.asm
DMADSTH             equ       $FEC9               destination [23:16], [15:8] at +1, [7:0] at +2
* From s9gui.asm
DMAXH               equ       $FECC               X size [15:8] (1D: count [15:8]); [7:0] at +1
* From s9gui.asm
DMAYH               equ       $FECE               Y size [15:8] (2D only; 0 in 1D); +1 = Y [7:0] = 1D count [23:16]
* From s9gui.asm
DMASSTH             equ       $FED0               source stride [15:8], [7:0] at +1 (2D)
* From s9gui.asm
DMADSTSH            equ       $FED2               destination stride likewise
* From s9gui.asm
DMAOPR              equ       $FED4               logic op: b2:0 op, b3 NOT; 0 = COPY (a dead byte on cores before rc17)
* From s9gui.asm
DMAPROBE4           equ       $FEC4               the probe: reading this returns what was written at $FEC7
* From s9gui.asm
DMAPROBE7           equ       $FEC7
* From s9gui.asm
DMA_EN              equ       $01
* From s9gui.asm
DMA_2D              equ       $02
* From s9gui.asm
DMA_FILL            equ       $04
* From s9gui.asm
DMA_START           equ       $80
* From s9gui.asm
DMAOP               equ       $FED4               rc18: b2:0 op (1 OR 2 AND 3 XOR 4 MASK), b3 NOT; 0 = plain
* From s9gui.asm
DMA_BUSY            equ       $80
* From s9gui.asm
FrOpaque            equ       $3A78               byte: non-zero = the inkers turn every PAPER dot (nibble 0) of a picture into OpaqueInk
* From s9gui.asm
OpaqueInk           equ       COLORS_OPAQUEBG                  the opaque paper nibble: CLUT 0 entry 10
* From s9gui.asm
FrNumBuf            equ       $3A70               drawcres' number text, 8 bytes ($3A70-$3A77)
* From s9gui.asm
* From s9gui.asm
* From s9gui.asm
* From s9gui.asm
* From s9gui.asm
FrFocusMask         equ       $3975               reserved byte; FrNoDirty uses its contents
* From s9gui.asm
FrTailBlk           equ       $3976               word: s9's tail blocks 6 and 7 (UmeSymbols16) from its fork
* From s9gui.asm
FrSave              equ       $3978               first of the eight RAM blocks holding the four-bit rectangle saves (a word: 0 = none, packed saves)
* From s9gui.asm
Shuttle             equ       $13D8               the old one-bit save arena: the shuttle between the picture and the save arena
* From s9gui.asm
* The shuttle's top holds the inverted font, built at run time - the same
* layout as the font at $099F (glyph c at (c-$20)*GlyphBytes), then the inverted arrow glyphs; the passes are shorter.
FontBytes           equ       $0900               the font at $099F: 96 glyphs of GlyphBytes
FontInvBytes        equ       FontBytes+GlyphArrowCount*GlyphBytes  the inverted font and the inverted arrows
ShuttleMax          equ       8192-FontInvBytes   a shuttle pass never leaves the two arena blocks mapped for it
FrFontInv           equ       Shuttle+ShuttleMax  the inverted font (same glyph offsets as $099F)
FrArrowInv          equ       FrFontInv+FontBytes the inverted arrow glyphs (same order as FrArrowGlyphs)
MenuFillByte        equ       COLORS_MENUBG*$11   two dots of a menu interior
ShadowByte          equ       COLORS_BOXSHADOW*$11  two dots of a paper box's shadow: dark gray
MenuShadowByte      equ       COLORS_MENUSHADOW*$11 two dots of a black box's (menu's) shadow: light gray
MenuEdgeByte        equ       COLORS_PAPER*$11    two dots of a menu's border (Box3D fg): its text's paper color
Box3DPaper          equ       COLORS_PAPER*$11    a style 1 box's inside (Box3D bg)
Box3DInk            equ       COLORS_INK*$11      a style 1 box's border (Box3D fg): the text's ink
BoxShadows          equ       1                   1 = boxes get the shadow, 0 = no shadows
B3Open              equ       $01                 Box3D mode: the right and bottom edges are bg - the box runs flush into its shadow
B3Shadow            equ       $02                 Box3D mode: the shadow, drawn last, just outside the outline (right and bottom)
B3Light             equ       $04                 Box3D mode: the shadow in MenuShadowByte (light gray) instead of ShadowByte
Box3DMode           equ       BoxShadows*B3Shadow  a style 1 box: closed black outline all round, dark gray shadow
* A menu box is closed too: a paper outline all round and a light gray shadow (a paper box: black outline, dark gray
* shadow).
MenuBoxMode         equ       B3Light+BoxShadows*B3Shadow  a menu: closed paper outline all round, light gray shadow
MenuFillTop         equ       1                   a menu box's inside starts at row wtopy-1 (Box3D: row wtopy is its top border)
MenuFillBot         equ       5                   and ends at row wboty+5; row wboty+4 is its bottom border, the shadow under that
FrSym               equ       $397A               the first of the two RAM blocks holding UmeSymbols16 data (a word: 0 = none)
* From s9gui.asm
FrRow               equ       $397C               the row being drawn, four bits a dot (eight bytes)
* From s9gui.asm
FrStage             equ       $3984               rows staged from the symbol bank (27 x 8 = 216 bytes)
* From s9gui.asm
PicVirt             equ       $7D00               virtual module offset of the first picture
* From s9gui.asm
PicLen              equ       $0381               769 bytes: 24 x 32 and a pad byte - plus 128: the four part-type icons
* From s9gui.asm
BankPic             equ       $1AC0               the pictures' offset in the bank: after part 1's 6,848 bytes
* From s9gui.asm
BankSize            equ       $3074               12,404 bytes; unused (UmeSymbols16 is 11,456 bytes)
* From s9gui.asm
SprInk              equ       COLORS_SYMBOLINK                  the one-bit sprites still built into s9gui (menu icons, arrows)
* From s9gui.asm
FrChrome            equ       $0076               non-zero while winbox / butbox draw (their one-bit pieces use FrInk).
* From s9gui.asm
FrUnder             equ       $0074               non-zero while ledger draws ledger lines: they go BEHIND the dots already drawn
* From s9gui.asm
StaffInk            equ       COLORS_STAFF                  the five staff lines and their left bar (staff): CLUT 0 entry 12
* From s9gui.asm
FrInk               equ       COLORS_INK                  the ink nibble: CLUT 0 entry 15. Paper is nibble 0 (transparent)
* From s9gui.asm
FrEatCR             equ       $003C               non-zero = the next pipe byte is the CR after a $CD
* From s9gui.asm
ModuleBase          equ       $0000
* From s9gui.asm
CTXMAX              equ       32                 MIDI/Modes has 17 rows; consume its whole packet
* From s9gui.asm
L0E55               equ       PicVirt+$0000       RestBreve        breve rest
* From s9gui.asm
L0E75               equ       PicVirt+$0020       RestWhole        whole rest
* From s9gui.asm
L0E95               equ       PicVirt+$0040       RestHalf         half rest
* From s9gui.asm
L0EB5               equ       PicVirt+$0060       RestQuarter      quarter rest
* From s9gui.asm
L0ED5               equ       PicVirt+$0080       RestEighth       eighth rest
* From s9gui.asm
L0EF5               equ       PicVirt+$00A0       Rest16th         sixteenth rest
* From s9gui.asm
L0F15               equ       PicVirt+$00C0       Rest32nd         thirty-second rest
* From s9gui.asm
L0F35               equ       PicVirt+$00E0       Rest64th         sixty-fourth rest
* From s9gui.asm
L0F55               equ       PicVirt+$0100       NoteBreveUp      breve note, head at the bottom
* From s9gui.asm
L0F76               equ       PicVirt+$0121       NoteWholeUp      whole note, head at the bottom (record 31)
* From s9gui.asm
L0F96               equ       PicVirt+$0141       NoteHalfUp       half note stem up (record 30)
* From s9gui.asm
L0FB6               equ       PicVirt+$0161       NoteQuarterUp    quarter note stem up (record 29)
* From s9gui.asm
L0FD6               equ       PicVirt+$0181       NoteEighthUp     eighth note stem up (record 28)
* From s9gui.asm
L0FF6               equ       PicVirt+$01A1       Note16thUp       sixteenth note stem up
* From s9gui.asm
L1016               equ       PicVirt+$01C1       Note32ndUp       thirty-second note stem up
* From s9gui.asm
L1036               equ       PicVirt+$01E1       Note64thUp       sixty-fourth note stem up
* From s9gui.asm
L1056               equ       PicVirt+$0201       NoteBreveDown    breve note, head at the top
* From s9gui.asm
L1076               equ       PicVirt+$0221       NoteWholeDown    whole note, head at the top
* From s9gui.asm
L1096               equ       PicVirt+$0241       NoteHalfDown     half note stem down
* From s9gui.asm
L10B6               equ       PicVirt+$0261       NoteQuarterDown  quarter note stem down
* From s9gui.asm
L10D6               equ       PicVirt+$0281       NoteEighthDown   eighth note stem down
* From s9gui.asm
L10F6               equ       PicVirt+$02A1       Note16thDown     sixteenth note stem down
* From s9gui.asm
L1116               equ       PicVirt+$02C1       Note32ndDown     thirty-second note stem down
* From s9gui.asm
L1136               equ       PicVirt+$02E1       Note64thDown     sixty-fourth note stem down
* From s9gui.asm
PicPartIcon         equ       PicVirt+$0301       part-type icon 0; + 32 * index
                    endc

* ===== s9b: module-scoped definitions =====
                    ifdef     UME_SCOPE_S9B
                    endc

* ===== s9c: module-scoped definitions =====
                    ifdef     UME_SCOPE_S9C
* From s9c.asm
MENU_WIDE           equ       16                  columns inside the box
* From s9c.asm
MENU_PITCH          equ       7                   dots from one row to the next: TEXT rows, as the MIDI menu
* From s9c.asm
mcol                equ       0                      STACK OFFSET; relative to this routine's S/U frame base | word: the box's column
* From s9c.asm
mtopy               equ       2                      STACK OFFSET; relative to this routine's S/U frame base | word: the top phrase line
* From s9c.asm
mrows               equ       4                      STACK OFFSET; relative to this routine's S/U frame base | word: rows in this menu
* From s9c.asm
mlabels             equ       6                      STACK OFFSET; relative to this routine's S/U frame base | word: the row table
* From s9c.asm
mkeys               equ       8                      STACK OFFSET; relative to this routine's S/U frame base | word: the key string
* From s9c.asm
ACHUNK              equ       32                     STACK BUFFER/RECORD CAPACITY; not an address | events copied per page switch (before mframe: it sizes the frame)
* From s9c.asm
aidx                equ       10                     STACK OFFSET; relative to this routine's S/U frame base | word: the placed note's index
* From s9c.asm
afirst              equ       12                     STACK OFFSET; relative to this routine's S/U frame base | word: the bar line's index
* From s9c.asm
abase               equ       14                     STACK OFFSET; relative to this routine's S/U frame base | word: the bar's time = time zero of the temporary score
* From s9c.asm
atmp                equ       16                     STACK OFFSET; relative to this routine's S/U frame base | word: the latest NUTEMPO before the bar, -1 none
* From s9c.asm
atsg                equ       18                     STACK OFFSET; relative to this routine's S/U frame base | word: the latest TIMESIG before the bar, -1 none
* From s9c.asm
aksg                equ       20                     STACK OFFSET; relative to this routine's S/U frame base | word: the latest KEYSIG before the bar, -1 none
* From s9c.asm
acnt                equ       22                     STACK OFFSET; relative to this routine's S/U frame base | word: events in the temporary score
* From s9c.asm
apage               equ       24                     STACK OFFSET; relative to this routine's S/U frame base | word: the temporary page number
* From s9c.asm
awr                 equ       26                     STACK OFFSET; relative to this routine's S/U frame base | word: events written to it so far
* From s9c.asm
abp                 equ       28                     STACK OFFSET; relative to this routine's S/U frame base | word: the chunk's write pointer
* From s9c.asm
anum                equ       30                     STACK OFFSET; relative to this routine's S/U frame base | word: events in the chunk
* From s9c.asm
asrc                equ       32                     STACK OFFSET; relative to this routine's S/U frame base | word: the next source index
* From s9c.asm
aend                equ       34                     STACK OFFSET; relative to this routine's S/U frame base | word: the placed note's end time
apart               equ       36                  STACK OFFSET: audition frame U; clicked part (word)
achn                equ       38                  STACK OFFSET: audition frame U; latest channel-event index (word)
ains                equ       40                  STACK OFFSET: audition frame U; latest instrument-event index (word)
* From s9c.asm
abuf                equ       42                     STACK OFFSET; relative to this routine's S/U frame base | ACHUNK events copied per page switch
* From s9c.asm
mframe              equ       abuf+ACHUNK*8          STACK FRAME SIZE in bytes; not an address
* From s9c.asm
vEvents             equ       $29                 s9 <nevents
* From s9c.asm
vPages              equ       $31                 s9 <nmpages: the score's last event page
* From s9c.asm
vBase               equ       $25                 s9 <database: where the mapped page sits
* From s9c.asm
vGPTab              equ       $1000               s9 GPTab: one byte per buffer, its RAM block
* From s9c.asm
vPswap              equ       $0399               vector: pswap(page) maps a page, creating pages up to it; D = 0 failed
* From s9c.asm
vGiveback           equ       $038F               vector: giveback() frees the pages above the score's last
* From s9c.asm
vCod2raw            equ       $03AB               vector: cod2raw(dur, durmod) = duration units, a whole note 192
* From s9c.asm
AUD_DIV             equ       1                   the audition's tempo divisor: 1 (the note at its natural length)
* From s9c.asm
MAXTEMP             equ       900                 events a temporary score may hold (a page takes 928)
* From s9c.asm
EvTempo             equ       25                  wmuse.h NUTEMPO: TEMPONO in the dur byte
* From s9c.asm
EvTimeSig           equ       10                  TIMESIG
* From s9c.asm
EvKeySig            equ       11                  KEYSIG
                    endc

* ===== s9d: module-scoped definitions =====
                    ifdef     UME_SCOPE_S9D
                    endc

* ===== s9e: module-scoped definitions =====
                    ifdef     UME_SCOPE_S9E
                    endc

* ===== s9k: module-scoped definitions =====
                    ifdef     UME_SCOPE_S9K
* From s9k.asm; C clue: bdp.c:25
curevp              equ       UmeData_curevp
* From s9k.asm; C clue: bdp.c:26
database            equ       UmeData_database
* From s9k.asm; C clue: bdp.c:27
curptop             equ       UmeData_curptop
* From s9k.asm; C clue: bdp.c:29
nevents             equ       UmeData_nevents
* From s9k.asm; C clue: bdp.c:30
curind              equ       UmeData_curind
* From s9k.asm; C clue: bdp.c:33
curpage             equ       UmeData_curpage
* From s9k.asm; C clue: bdp.c:38
godotind            equ       UmeData_godotind
* From s9k.asm; C clue: bdp.c:39
undind              equ       UmeData_undind
* From s9k.asm; C clue: bdp.c:62
pitcarry            equ       UmeData_pitcarry
* From s9k.asm; C clue: bdp.c:74
xyoff               equ       UmeData_xyoff
* From s9k.asm; C clue: bdp.c:77
nparts              equ       UmeData_nparts
* From s9k.asm; C clue: bdp.c:98
curcurse            equ       UmeData_curcurse
* From s9k.asm; C clue: bdp.c:106
rfr_scr             equ       UmeData_rfr_scr
* From s9k.asm; C clue: bdp.c:107
rfr_men             equ       UmeData_rfr_men
* From s9k.asm; C clue: bdp.c:108
rfr_rep             equ       UmeData_rfr_rep
* From s9k.asm; C clue: bdp.c:109
rfr_bar             equ       UmeData_rfr_bar
* From s9k.asm; C clue: bdp.c:118
xgoal               equ       UmeData_xgoal
* From s9k.asm; C clue: bdp.c:118
gind                equ       UmeData_gind
* From s9k.asm; C clue: bdp.c:126
ritind              equ       UmeData_ritind
* From s9k.asm; C clue: bdp.c:126
lftind              equ       UmeData_lftind
* From s9k.asm; C clue: bdp.c:135, fcnptrs.h:23
arg0                equ       UmeData_arg0
* From s9k.asm; C clue: bdp.c:135
arg1                equ       UmeData_arg1
* From s9k.asm; C clue: bdp.c:135
arg2                equ       UmeData_arg2
* From s9k.asm; C clue: bdp.c:135
arg3                equ       UmeData_arg3
* From s9k.asm; C clue: bdp.c:135
arg4                equ       UmeData_arg4
* From s9k.asm; C clue: bdp.c:135
arg5                equ       UmeData_arg5
* From s9k.asm; C clue: bglob.c:36
autooct             equ       UmeData_autooct
* From s9k.asm; C clue: bglob.c:43
kpmode              equ       UmeData_kpmode
* From s9k.asm; C clue: bglob.c:48
kpoctch             equ       UmeData_kpoctch
* From s9k.asm; C clue: bglob.c:49
kpnotch             equ       UmeData_kpnotch
* From s9k.asm; C clue: bglob.c:52
kpdur               equ       UmeData_kpdur
* From s9k.asm; C clue: bglob.c:54
kpartic             equ       UmeData_kpartic
* From s9k.asm; C clue: bglob.c:56
kpoctave            equ       UmeData_kpoctave
* From s9k.asm; C clue: bglob.c:57
kplnotenum          equ       UmeData_kplnotenum
* From s9k.asm; C clue: bglob.c:93
brush               equ       UmeData_brush
* From s9k.asm; C clue: bglob.c:181
clefs               equ       UmeData_clefs
* From s9k.asm; C clue: bglob.c:20
toolson             equ       UmeData_toolson
* From s9k.asm; C clue: bglob.c:29
lastclik            equ       UmeData_lastclik
* From s9k.asm; C clue: bglob.c:30
kpind               equ       UmeData_kpind
* From s9k.asm; C clue: bglob.c:31
kplast              equ       UmeData_kplast
* From s9k.asm; C clue: bglob.c:32
kplastact           equ       UmeData_kplastact
* From s9k.asm; C clue: bglob.c:37
autopick            equ       UmeData_autopick
* From s9k.asm; C clue: bglob.c:39
autoclone           equ       UmeData_autoclone
* From s9k.asm; C clue: bglob.c:40
kpclone             equ       UmeData_kpclone
* From s9k.asm; C clue: bglob.c:53
kpdmod              equ       UmeData_kpdmod
* From s9k.asm; C clue: bglob.c:53
kpitmod             equ       UmeData_kpitmod
* From s9k.asm; C clue: bglob.c:55
kvslot              equ       UmeData_kvslot
* From s9k.asm; C clue: bglob.c:81
grafxes             equ       UmeData_grafxes
* From s9k.asm; C clue: bglob.c:82
grafyes             equ       UmeData_grafyes
* From s9k.asm; C clue: bglob.c:173
staves              equ       UmeData_staves
* From s9k.asm; C clue: bglob.c:176
parts               equ       UmeData_parts
* From s9k.asm; C clue: fcnptrs.h:14
pcharmaus           equ       UmeData_pcharmaus
* From s9k.asm; C clue: fcnptrs.h:14
pkeymaus            equ       UmeData_pkeymaus
* From s9k.asm; C clue: fcnptrs.h:14
pinkey              equ       UmeData_pinkey
* From s9k.asm; C clue: fcnptrs.h:14
pgets               equ       UmeData_pgets
* From s9k.asm; C clue: fcnptrs.h:17
pfindstaff          equ       UmeData_pfindstaff
* From s9k.asm; C clue: fcnptrs.h:20
pprintf             equ       UmeData_pprintf
* From s9k.asm; C clue: fcnptrs.h:20
psprintf            equ       UmeData_psprintf
* From s9k.asm; C clue: fcnptrs.h:21
powrite             equ       UmeData_powrite
* From s9k.asm; C clue: fcnptrs.h:22
psoowee             equ       UmeData_psoowee
* From s9k.asm; C clue: fcnptrs.h:23
pnfwrite            equ       UmeData_pnfwrite
* From s9k.asm; C clue: fcnptrs.h:24
pgksig              equ       UmeData_pgksig
* From s9k.asm; C clue: fcnptrs.h:25
pgtsig              equ       UmeData_pgtsig
* From s9k.asm; C clue: fcnptrs.h:26
paddclone           equ       UmeData_paddclone
* From s9k.asm; C clue: fcnptrs.h:27
ppluspart           equ       UmeData_ppluspart
* From s9k.asm; C clue: fcnptrs.h:28
paddbars            equ       UmeData_paddbars
* From s9k.asm; C clue: fcnptrs.h:29
prepart             equ       UmeData_prepart
* From s9k.asm; C clue: fcnptrs.h:30
pievtinit           equ       UmeData_pievtinit
* From s9k.asm; C clue: fcnptrs.h:30
ptextmen            equ       UmeData_ptextmen
* From s9k.asm
pbeep               equ       UmeData_pbeep
* From s9k.asm; C clue: fcnptrs.h:33
pflush              equ       UmeData_pflush
* From s9k.asm; C clue: fcnptrs.h:34
palert              equ       UmeData_palert
* From s9k.asm; C clue: fcnptrs.h:35
phit                equ       UmeData_phit
* From s9k.asm; C clue: fcnptrs.h:36
pputmidi            equ       UmeData_pputmidi
* From s9k.asm; C clue: fcnptrs.h:37
pmflush             equ       UmeData_pmflush
* From s9k.asm; C clue: fcnptrs.h:38
pputchar            equ       UmeData_pputchar
* From s9k.asm; C clue: fcnptrs.h:39
pfmarks             equ       UmeData_pfmarks
* From s9k.asm; C clue: fcnptrs.h:39
pfixup              equ       UmeData_pfixup
* From s9k.asm; C clue: fcnptrs.h:40
psmfwrit            equ       UmeData_psmfwrit
* From s9k.asm; C clue: fcnptrs.h:41
pdrawnr             equ       UmeData_pdrawnr
* From s9k.asm; C clue: fcnptrs.h:42
ppartline           equ       UmeData_ppartline
* From s9k.asm; C clue: fcnptrs.h:43
pgivebac            equ       UmeData_pgivebac
* From s9k.asm; C clue: fcnptrs.h:43
pfindts             equ       UmeData_pfindts
* From s9k.asm; C clue: fcnptrs.h:43
pplay               equ       UmeData_pplay
* From s9k.asm; C clue: fcnptrs.h:43
ptranprt            equ       UmeData_ptranprt
* From s9k.asm; C clue: fcnptrs.h:43
pclonmid            equ       UmeData_pclonmid
* From s9k.asm; C clue: fcnptrs.h:46
ppswap              equ       UmeData_ppswap
* From s9k.asm; C clue: fcnptrs.h:47
pfixmarx            equ       UmeData_pfixmarx
* From s9k.asm; C clue: fcnptrs.h:48
pparse              equ       UmeData_pparse
* From s9k.asm; C clue: fcnptrs.h:48
pmouce              equ       UmeData_pmouce
* From s9k.asm; C clue: fcnptrs.h:48
pyesno              equ       UmeData_pyesno
* From s9k.asm; C clue: fcnptrs.h:49
pexprmenu           equ       UmeData_pexprmenu
* From s9k.asm; C clue: fcnptrs.h:50
pgetempty           equ       UmeData_pgetempty
* From s9k.asm; C clue: fcnptrs.h:53
pswapevts           equ       UmeData_pswapevts
* From s9k.asm; C clue: fcnptrs.h:56
pregen              equ       UmeData_pregen
* From s9k.asm; C clue: fcnptrs.h:57
pcod2raw            equ       UmeData_pcod2raw
* From s9k.asm; C clue: fcnptrs.h:60
penter              equ       UmeData_penter
* From s9k.asm; C clue: fcnptrs.h:60
premove             equ       UmeData_premove
* From s9k.asm; C clue: fcnptrs.h:60
pchip               equ       UmeData_pchip
* From s9k.asm; C clue: fcnptrs.h:63
pfulltime           equ       UmeData_pfulltime
* From s9k.asm; C clue: fcnptrs.h:66
pmakroom            equ       UmeData_pmakroom
                    endc

* ===== s9l: module-scoped definitions =====
                    ifdef     UME_SCOPE_S9L
                    endc

* ===== s9m: module-scoped definitions =====
                    ifdef     UME_SCOPE_S9M
* From s9m.asm: MidiMenu's frame (leas -MmFrame,s), offsets from its S at the menu loop
MmBuf               equ       0                   the channel field editor: two characters and a NUL
MmEdit              equ       6                   part whose channel is being edited, 0 = none
MmCurs              equ       7                   field editor cursor, 0 or 1
MmRedraw            equ       8                   nonzero: draw the window frame
MmKey               equ       9                   the key or picked command
MmLine              equ       10                  line buffer for pgets
MmTbl               equ       $5B                 working copy of MidiChanTbl (17 bytes)
MmFrame             equ       $6C
                    endc

* ===== s9p: module-scoped definitions =====
                    ifdef     UME_SCOPE_S9P
                    endc

* ===== s9r: module-scoped definitions =====
                    ifdef     UME_SCOPE_S9R
* From s9r.asm
Input               equ       0                      STACK OFFSET; relative to this routine's S/U frame base
* From s9r.asm
Prompt              equ       82                     STACK OFFSET; relative to this routine's S/U frame base
* From s9r.asm
Options             equ       162                    STACK OFFSET; relative to this routine's S/U frame base
* From s9r.asm
Slot                equ       194                    STACK OFFSET; relative to this routine's S/U frame base
* From s9r.asm
NewPath             equ       195                    STACK OFFSET; relative to this routine's S/U frame base
* From s9r.asm
NamePtr             equ       196                    STACK OFFSET; relative to this routine's S/U frame base
* From s9r.asm
FrameSize           equ       198                    STACK FRAME SIZE in bytes; not an address
* From score_browser.inc
* C frame names verified against diskio.c fnamenu()/diread().
DirChanOff                 equ       0                            STACK OFFSET; ReadDirList frame S; C chan; reused as sort pass counter
DirCountOff                equ       2                            STACK OFFSET; ReadDirList frame S; C count
DirNameOff                 equ       4                            STACK OFFSET; ReadDirList frame S; C name[30]
DirBuffOff                 equ       34                           STACK OFFSET; ReadDirList frame S; C buff[32]; directory record / sort temporary
DirSavedUOff               equ       66                           STACK OFFSET; ReadDirList frame S; saved U
DirReturnOff               equ       68                           STACK OFFSET; ReadDirList frame S; return PC
DirFnamesArgOff            equ       70                           STACK OFFSET; ReadDirList frame S; C fnames pointer
DirExtArgOff               equ       72                           STACK OFFSET; ReadDirList frame S; C ext pointer
DirInvertArgOff            equ       74                           STACK OFFSET; ReadDirList frame S; C invert argument
DirPageArgOff              equ       76                           STACK OFFSET; ReadDirList frame S; port directory cursor pointer
BrowserRecOff              equ       0                            STACK OFFSET; FilePickMenu frame S; C rec; printed index, selected index or typed key
BrowserNlinesOff           equ       2                            STACK OFFSET; FilePickMenu frame S; C nlines
BrowserNrecsOff            equ       4                            STACK OFFSET; FilePickMenu frame S; C nrecs
BrowserSavedUOff           equ       1930                         STACK OFFSET; FilePickMenu frame S; saved U
BrowserReturnOff           equ       1932                         STACK OFFSET; FilePickMenu frame S; return PC
BrowserBuffArgOff          equ       1934                         STACK OFFSET; FilePickMenu frame S; C buff pointer
BrowserExtArgOff           equ       1936                         STACK OFFSET; FilePickMenu frame S; C ext pointer
BrowserWrArgOff            equ       1938                         STACK OFFSET; FilePickMenu frame S; C wr argument
BrowserDirArgOff           equ       1940                         STACK OFFSET; FilePickMenu frame S; C dir argument
BrowserDelArgOff           equ       1942                         STACK OFFSET; FilePickMenu frame S; C del argument
DirFrameSize               equ       $42                          STACK FRAME SIZE; diread locals; saved U and arguments excluded
BrowserFrameSize    equ       $078A                  STACK FRAME SIZE in bytes; not an address | bytes allocated below S by FilePickMenu
BrowserListOff      equ       6                      STACK OFFSET; relative to this routine's S/U frame base | first filename in the stack frame
BrowserListBytes    equ       72*26                  STACK BUFFER/RECORD CAPACITY; not an address | reserved filename area; displayed pages are capped at 64
BrowserPagePosOff   equ       $0760                  STACK OFFSET; relative to this routine's S/U frame base | STACK OFFSET, never absolute instrument-table storage
* From score_browser.inc
BrowserPageMoreOff            equ       BrowserPagePosOff+4   STACK OFFSET; relative to this routine's S/U frame base
* From score_browser.inc
BrowserPageActionOff          equ       BrowserPagePosOff+5   STACK OFFSET; relative to this routine's S/U frame base
* From score_browser.inc
BrowserPageNumOff             equ       BrowserPagePosOff+6   STACK OFFSET; relative to this routine's S/U frame base
BrowserPageSkipOff  equ       BrowserPagePosOff+8   STACK OFFSET; FilePickMenu frame S; pages to scan before display
BrowserMouseXOff    equ       BrowserPagePosOff+10  STACK OFFSET; FilePickMenu frame S; current mouse X
BrowserMouseYOff    equ       BrowserPagePosOff+12  STACK OFFSET; FilePickMenu frame S; current mouse Y
                    endc

* ===== s9i: module-scoped definitions =====
                    ifdef     UME_SCOPE_S9I
* From s9i.asm
ipath               equ       0                      STACK OFFSET; relative to this routine's S/U frame base
* From s9i.asm
ipass               equ       1                      STACK OFFSET; relative to this routine's S/U frame base
* From s9i.asm
icur                equ       2                      STACK OFFSET; relative to this routine's S/U frame base | track being read
* From s9i.asm
istat               equ       3                      STACK OFFSET; relative to this routine's S/U frame base
* From s9i.asm
idata               equ       4                      STACK OFFSET; relative to this routine's S/U frame base
* From s9i.asm
idata2              equ       5                      STACK OFFSET; relative to this routine's S/U frame base
* From s9i.asm
ichan               equ       6                      STACK OFFSET; relative to this routine's S/U frame base
* From s9i.asm
imeta               equ       7                      STACK OFFSET; relative to this routine's S/U frame base
* From s9i.asm
itracks             equ       8                      STACK OFFSET; relative to this routine's S/U frame base
* From s9i.asm
idiv                equ       10                     STACK OFFSET; relative to this routine's S/U frame base
* From s9i.asm
itime               equ       12                     STACK OFFSET; relative to this routine's S/U frame base | time of the event in hand
* From s9i.asm
imax                equ       14                     STACK OFFSET; relative to this routine's S/U frame base
* From s9i.asm
icount              equ       16                     STACK OFFSET; relative to this routine's S/U frame base
* From s9i.asm
iparts              equ       18                     STACK OFFSET; relative to this routine's S/U frame base
* From s9i.asm
ibound              equ       20                     STACK OFFSET; relative to this routine's S/U frame base | next bar line (pass 1)
* From s9i.asm
ibarlen             equ       22                     STACK OFFSET; relative to this routine's S/U frame base
* From s9i.asm
ibarno              equ       24                     STACK OFFSET; relative to this routine's S/U frame base
* From s9i.asm
ibufsz              equ       26                     STACK OFFSET; relative to this routine's S/U frame base | bytes buffered per track
* From s9i.asm
inum                equ       28                     STACK OFFSET; relative to this routine's S/U frame base
* From s9i.asm
iden                equ       32                     STACK OFFSET; relative to this routine's S/U frame base
* From s9i.asm
imod                equ       36                     STACK OFFSET; relative to this routine's S/U frame base
* From s9i.asm
itmp                equ       40                     STACK OFFSET; relative to this routine's S/U frame base
* From s9i.asm
ilen                equ       44                     STACK OFFSET; relative to this routine's S/U frame base
* From s9i.asm
iptr                equ       48                     STACK OFFSET; relative to this routine's S/U frame base
* From s9i.asm
ifpos               equ       50                     STACK OFFSET; relative to this routine's S/U frame base | file offset while the chunks are located
* From s9i.asm
iroot               equ       54                     STACK OFFSET; relative to this routine's S/U frame base
* From s9i.asm
irec                equ       56                     STACK OFFSET; relative to this routine's S/U frame base
* From s9i.asm
imap                equ       64                     STACK OFFSET; relative to this routine's S/U frame base | key of each part: program+1, or $C0+channel when the
* From s9i.asm
istf                equ       80                     STACK OFFSET; relative to this routine's S/U frame base | staff of each part: 0 treble, 1 alto, 2 tenor, 3 bass, 4 percussion
* From s9i.asm
itrk                equ       96                     STACK OFFSET; relative to this routine's S/U frame base | the current track's record
* From s9i.asm
ibar                equ       100                    STACK OFFSET; relative to this routine's S/U frame base | bar line record being built
* From s9i.asm
ilastb              equ       108                    STACK OFFSET; relative to this routine's S/U frame base | time of the last bar line laid down
* From s9i.asm
ilo                 equ       112                    STACK OFFSET; relative to this routine's S/U frame base | lowest pitch each part has played (pass 0)
* From s9i.asm
ihi                 equ       128                    STACK OFFSET; relative to this routine's S/U frame base | highest
* From s9i.asm
ichn                equ       160                    STACK OFFSET; relative to this routine's S/U frame base | MIDI channel of each part's first note
* From s9i.asm
iprg                equ       176                    STACK OFFSET; relative to this routine's S/U frame base | each channel's current program; bit 7 = none yet
* From s9i.asm
iact                equ       192                    STACK OFFSET; relative to this routine's S/U frame base
* From s9i.asm
PENDSZ              equ       8                      STACK BUFFER/RECORD CAPACITY; not an address
* From s9i.asm
MAXTRK              equ       32                     STACK BUFFER/RECORD CAPACITY; not an address
* From s9i.asm
TRKSZ               equ       18                     STACK BUFFER/RECORD CAPACITY; not an address
* From s9i.asm
POOL                equ       512                    STACK BUFFER/RECORD CAPACITY; not an address
* From s9i.asm
itrk0               equ       iact+64*PENDSZ         STACK OFFSET; relative to this routine's S/U frame base
* From s9i.asm
ipool               equ       itrk0+MAXTRK*TRKSZ     STACK OFFSET; relative to this routine's S/U frame base
* From s9i.asm
ifirstnote          equ       ipool+POOL             STACK OFFSET; S9I U frame, earliest sounding note tick
irestend            equ       ifirstnote+2          STACK OFFSET; S9I U frame, end of opening silence already notated
iframe              equ       irestend+2            STACK FRAME SIZE in bytes; not an address
* From s9i.asm
tpos                equ       0                      STACK-BACKED TRACK RECORD OFFSET; relative to record pointer
* From s9i.asm
tleft               equ       4                      STACK-BACKED TRACK RECORD OFFSET; relative to record pointer
* From s9i.asm
trun                equ       8                      STACK-BACKED TRACK RECORD OFFSET; relative to record pointer
* From s9i.asm
ttime               equ       9                      STACK-BACKED TRACK RECORD OFFSET; relative to record pointer
* From s9i.asm
trem                equ       11                     STACK-BACKED TRACK RECORD OFFSET; relative to record pointer
* From s9i.asm
tnext               equ       13                     STACK-BACKED TRACK RECORD OFFSET; relative to record pointer
* From s9i.asm
tflag               equ       15                     STACK-BACKED TRACK RECORD OFFSET; relative to record pointer | 1 = end of track reached
* From s9i.asm
tbpos               equ       16                     STACK-BACKED TRACK RECORD OFFSET; relative to record pointer
* From s9i.asm
tblen               equ       17                     STACK-BACKED TRACK RECORD OFFSET; relative to record pointer
* From midi_score.inc; C clue: bdp.c:29
nevents             equ       UmeData_nevents
* From midi_score.inc; C clue: bdp.c:77
nparts              equ       UmeData_nparts
* From midi_score.inc; C clue: bdp.c:78
nstaves             equ       UmeData_nstaves
* From midi_score.inc; C clue: bdp.c:30
curind              equ       UmeData_curind
* From midi_score.inc; C clue: bdp.c:79
keysig              equ       UmeData_keysig
* From midi_score.inc; C clue: bdp.c:81
transp              equ       UmeData_transp
* From midi_score.inc; C clue: bdp.c:82
velo                equ       UmeData_velo
* From midi_score.inc; C clue: bglob.c:173
staves              equ       $0C19
* From midi_score.inc; C clue: bglob.c:176
parts               equ       $0C5F
* From midi_score.inc; C clue: bdp.c:86
nbars               equ       UmeData_nbars
* From midi_score.inc; C clue: bdp.c:118
gind                equ       UmeData_gind
* From midi_score.inc; C clue: bdp.c:118
xgoal               equ       UmeData_xgoal
* From midi_score.inc; C clue: bdp.c:106
rfr_scr             equ       UmeData_rfr_scr
                    endc

* ===== s9y: module-scoped definitions =====
                    ifdef     UME_SCOPE_S9Y
* From s9y.asm
ipath               equ       0                      STACK OFFSET; relative to this routine's S/U frame base
* From s9y.asm
ipass               equ       1                      STACK OFFSET; relative to this routine's S/U frame base
* From s9y.asm
iroot               equ       2                      STACK OFFSET; relative to this routine's S/U frame base
* From s9y.asm
icur                equ       4                      STACK OFFSET; relative to this routine's S/U frame base
* From s9y.asm
lycode               equ       5                     STACK OFFSET; relative to this routine's S/U frame base
* From s9y.asm
ivalue              equ       6                      STACK OFFSET; relative to this routine's S/U frame base
* From s9y.asm
imax                equ       8                      STACK OFFSET; relative to this routine's S/U frame base
* From s9y.asm
ibound              equ       10                     STACK OFFSET; relative to this routine's S/U frame base
* From s9y.asm
ibarlen             equ       12                     STACK OFFSET; relative to this routine's S/U frame base
* From s9y.asm
ibarno              equ       14                     STACK OFFSET; relative to this routine's S/U frame base
* From s9y.asm
ilastb              equ       16                     STACK OFFSET; relative to this routine's S/U frame base
* From s9y.asm
icount              equ       18                     STACK OFFSET; relative to this routine's S/U frame base
* From s9y.asm
irec                equ       20                     STACK OFFSET; relative to this routine's S/U frame base
* From s9y.asm
ibar                equ       28                     STACK OFFSET; relative to this routine's S/U frame base
* From s9y.asm
itrk                equ       36                     STACK OFFSET; relative to this routine's S/U frame base
* From s9y.asm
idur                equ       38                     STACK OFFSET; relative to this routine's S/U frame base
* From s9y.asm
itime               equ       40                     STACK OFFSET; relative to this routine's S/U frame base
* From s9y.asm
imap                equ       48                     STACK OFFSET; relative to this routine's S/U frame base
* From s9y.asm
istf                equ       imap+16                STACK OFFSET; relative to this routine's S/U frame base
* From s9y.asm
ichn                equ       imap+96                STACK OFFSET; relative to this routine's S/U frame base
* From s9y.asm
inum                equ       80                     STACK OFFSET; relative to this routine's S/U frame base
* From s9y.asm
iden                equ       84                     STACK OFFSET; relative to this routine's S/U frame base
* From s9y.asm
imod                equ       88                     STACK OFFSET; relative to this routine's S/U frame base
* From s9y.asm
ipatchmap           equ       100                    STACK OFFSET; relative to this routine's S/U frame base
* From s9y.asm
ipatchlen           equ       102                    STACK OFFSET; relative to this routine's S/U frame base
* From s9y.asm
ipatchidx           equ       103                    STACK OFFSET; relative to this routine's S/U frame base
* From s9y.asm
ilo                 equ       104                    STACK OFFSET; relative to this routine's S/U frame base | lowest sounding pitch per Lyra voice
* From s9y.asm
ihi                 equ       112                    STACK OFFSET; relative to this routine's S/U frame base | highest sounding pitch per Lyra voice
* From s9y.asm
iseen               equ       120                    STACK OFFSET; relative to this routine's S/U frame base | pitch range initialized (eight voices)
* From s9y.asm
iperc               equ       128                    STACK OFFSET; relative to this routine's S/U frame base
* From s9y.asm
iheader             equ       160                    STACK OFFSET; relative to this routine's S/U frame base
* From s9y.asm
itracks             equ       iheader+$160           STACK OFFSET; relative to this routine's S/U frame base
* From s9y.asm
TSZ                 equ       150                    STACK BUFFER/RECORD CAPACITY; not an address
* From s9y.asm
tpos                equ       0                      STACK-BACKED TRACK RECORD OFFSET; relative to record pointer
* From s9y.asm
tend                equ       2                      STACK-BACKED TRACK RECORD OFFSET; relative to record pointer
* From s9y.asm
ttime               equ       4                      STACK-BACKED TRACK RECORD OFFSET; relative to record pointer
* From s9y.asm
toct                equ       6                      STACK-BACKED TRACK RECORD OFFSET; relative to record pointer
* From s9y.asm
teof                equ       7                      STACK-BACKED TRACK RECORD OFFSET; relative to record pointer
* From s9y.asm
tbpos               equ       8                      STACK-BACKED TRACK RECORD OFFSET; relative to record pointer
* From s9y.asm
tblen               equ       9                      STACK-BACKED TRACK RECORD OFFSET; relative to record pointer
* From s9y.asm
tactive             equ       10                     STACK-BACKED TRACK RECORD OFFSET; relative to record pointer
* From s9y.asm
tpitch              equ       11                     STACK-BACKED TRACK RECORD OFFSET; relative to record pointer
* From s9y.asm
tvel                equ       12                     STACK-BACKED TRACK RECORD OFFSET; relative to record pointer
* From s9y.asm
tchannel            equ       13                     STACK-BACKED TRACK RECORD OFFSET; relative to record pointer
* From s9y.asm
tbuf                equ       14                     STACK-BACKED TRACK RECORD OFFSET; relative to record pointer
* From s9y.asm
tgate              equ       78                      STACK-BACKED TRACK RECORD OFFSET; relative to record pointer | sounding fraction (1..8)
* From s9y.asm
tofftime           equ       79                      STACK-BACKED TRACK RECORD OFFSET; relative to record pointer | pending note-off, $FFFF when none
* From s9y.asm
tpref              equ       81                      STACK-BACKED TRACK RECORD OFFSET; relative to record pointer | next source pair, read ahead for ties
* From s9y.asm
tpvalid            equ       83                      STACK-BACKED TRACK RECORD OFFSET; relative to record pointer
* From s9y.asm
tacc                equ       84                     STACK-BACKED TRACK RECORD OFFSET; relative to record pointer | 64 pitch accidental states
* From s9y.asm
tbar                equ       148                    STACK-BACKED TRACK RECORD OFFSET; relative to record pointer | next measure boundary
* From s9y.asm
imacro              equ       itracks+8*TSZ          STACK OFFSET; relative to this routine's S/U frame base
* From s9y.asm
ipatches            equ       imacro+56              STACK OFFSET; relative to this routine's S/U frame base | native instrument patches, up to 64
* From s9y.asm
inpatch             equ       ipatches+64            STACK OFFSET; relative to this routine's S/U frame base
* From s9y.asm
pvoice              equ       inpatch+1              STACK OFFSET; relative to this routine's S/U frame base
* From s9y.asm
pselect             equ       pvoice+1               STACK OFFSET; relative to this routine's S/U frame base
* From s9y.asm
iaccseed            equ       pselect+1              STACK OFFSET; relative to this routine's S/U frame base | immutable key-signature template
* From s9y.asm
ilastc              equ       iaccseed+64            STACK OFFSET; relative to this routine's S/U frame base | the channel last given a marker, per voice ($FF none)
* From s9y.asm
ilast               equ       ilastc+16              STACK OFFSET; relative to this routine's S/U frame base | the instrument slot last given a marker, per voice ($FF none)
* From s9y.asm
pendc               equ       ilast+16               STACK OFFSET; relative to this routine's S/U frame base | a channel change waiting for the voice's next note ($FF none)
* From s9y.asm
pendi               equ       pendc+16               STACK OFFSET; relative to this routine's S/U frame base | an instrument change waiting for the voice's next note ($FF none)
* From s9y.asm
iframe              equ       pendi+16               STACK FRAME SIZE in bytes; not an address
* From midi_score.inc; C clue: bdp.c:29
nevents             equ       UmeData_nevents
* From midi_score.inc; C clue: bdp.c:77
nparts              equ       UmeData_nparts
* From midi_score.inc; C clue: bdp.c:78
nstaves             equ       UmeData_nstaves
* From midi_score.inc; C clue: bdp.c:30
curind              equ       UmeData_curind
* From midi_score.inc; C clue: bdp.c:79
keysig              equ       UmeData_keysig
* From midi_score.inc; C clue: bdp.c:81
transp              equ       UmeData_transp
* From midi_score.inc; C clue: bdp.c:82
velo                equ       UmeData_velo
* From midi_score.inc; C clue: bglob.c:173
staves              equ       $0C19
* From midi_score.inc; C clue: bglob.c:176
parts               equ       $0C5F
* From midi_score.inc; C clue: bdp.c:86
nbars               equ       UmeData_nbars
* From midi_score.inc; C clue: bdp.c:118
gind                equ       UmeData_gind
* From midi_score.inc; C clue: bdp.c:118
xgoal               equ       UmeData_xgoal
* From midi_score.inc; C clue: bdp.c:106
rfr_scr             equ       UmeData_rfr_scr
                    endc

* ===== s9o: module-scoped definitions =====
                    ifdef     UME_SCOPE_S9O
* From s9o.asm
ipath               equ       0                      STACK OFFSET; relative to this routine's S/U frame base
* From s9o.asm
ipass               equ       1                      STACK OFFSET; relative to this routine's S/U frame base
* From s9o.asm
iroot               equ       2                      STACK OFFSET; relative to this routine's S/U frame base
* From s9o.asm
imax                equ       4                      STACK OFFSET; relative to this routine's S/U frame base
* From s9o.asm
ibound              equ       6                      STACK OFFSET; relative to this routine's S/U frame base
* From s9o.asm
ibarlen             equ       8                      STACK OFFSET; relative to this routine's S/U frame base
* From s9o.asm
ibarno              equ       10                     STACK OFFSET; relative to this routine's S/U frame base
* From s9o.asm
ilastb              equ       12                     STACK OFFSET; relative to this routine's S/U frame base
* From s9o.asm
icount              equ       14                     STACK OFFSET; relative to this routine's S/U frame base
* From s9o.asm
irec                equ       16                     STACK OFFSET; relative to this routine's S/U frame base
* From s9o.asm
ibar                equ       24                     STACK OFFSET; relative to this routine's S/U frame base
* From s9o.asm
itime               equ       32                     STACK OFFSET; relative to this routine's S/U frame base
* From s9o.asm
imap                equ       34                     STACK OFFSET; relative to this routine's S/U frame base | 16 part keys, staves at +16, channels at +96
* From s9o.asm
istf                equ       imap+16                STACK OFFSET; relative to this routine's S/U frame base
* From s9o.asm
ichn                equ       imap+96                STACK OFFSET; relative to this routine's S/U frame base
* From s9o.asm
ilo                 equ       146                    STACK OFFSET; relative to this routine's S/U frame base | five voices: lowest / highest sounding pitch, seen
* From s9o.asm
ihi                 equ       151                    STACK OFFSET; relative to this routine's S/U frame base
* From s9o.asm
iseen               equ       156                    STACK OFFSET; relative to this routine's S/U frame base
* From s9o.asm
obase               equ       161                    STACK OFFSET; relative to this routine's S/U frame base | file offset of obuf[0]
* From s9o.asm
obpos               equ       163                    STACK OFFSET; relative to this routine's S/U frame base
* From s9o.asm
oblen               equ       164                    STACK OFFSET; relative to this routine's S/U frame base
* From s9o.asm
oeof                equ       165                    STACK OFFSET; relative to this routine's S/U frame base
* From s9o.asm
ounget              equ       166                    STACK OFFSET; relative to this routine's S/U frame base | a pushed-back character, 0 = none
* From s9o.asm
otok                equ       167                    STACK OFFSET; relative to this routine's S/U frame base | file offset of the token being read (2)
* From s9o.asm
obuf                equ       169                    STACK OFFSET; relative to this routine's S/U frame base | 64 bytes
* From s9o.asm
ovoice              equ       233                    STACK OFFSET; relative to this routine's S/U frame base | 0..4
* From s9o.asm
oclef               equ       234                    STACK OFFSET; relative to this routine's S/U frame base | 0 treble (+), 1 bass (-), 2 percussion
* From s9o.asm
onext               equ       235                    STACK OFFSET; relative to this routine's S/U frame base | one-note clef override: 0 none, 1 treble, 2 bass
* From s9o.asm
odur                equ       236                    STACK OFFSET; relative to this routine's S/U frame base | duration code 1 (W) .. 7 (X)
* From s9o.asm
odmod               equ       237                    STACK OFFSET; relative to this routine's S/U frame base | 0 plain, 1 dotted, 2 double-dotted, 3 triplet
* From s9o.asm
oksig               equ       238                    STACK OFFSET; relative to this routine's S/U frame base | signed sharps
* From s9o.asm
oopt                equ       239                    STACK OFFSET; relative to this routine's S/U frame base | O options: bit0 per-voice accidentals, bit1 carry
* From s9o.asm
otransp             equ       240                    STACK OFFSET; relative to this routine's S/U frame base | semitones, signed
* From s9o.asm
otempo              equ       241                    STACK OFFSET; relative to this routine's S/U frame base | the hex tempo value
* From s9o.asm
ounit               equ       242                    STACK OFFSET; relative to this routine's S/U frame base | beat unit code (N): 2 half, 3 quarter, 4 eighth ...
* From s9o.asm
omstart             equ       243                    STACK OFFSET; relative to this routine's S/U frame base | measure start time (2)
* From s9o.asm
omlen               equ       245                    STACK OFFSET; relative to this routine's S/U frame base | the longest of the first four measures (2)
* From s9o.asm
ovtime              equ       247                    STACK OFFSET; relative to this routine's S/U frame base | per voice: elapsed time in the measure (5 words)
* From s9o.asm
ovreg               equ       257                    STACK OFFSET; relative to this routine's S/U frame base | per voice: register 0..4 ($FF none yet)
* From s9o.asm
ovtrans             equ       262                    STACK OFFSET; relative to this routine's S/U frame base | per voice: U steps, signed
* From s9o.asm
ovlast              equ       267                    STACK OFFSET; relative to this routine's S/U frame base | per voice: the register last marked in the score ($FF none)
* From s9o.asm
ovperc              equ       272                    STACK OFFSET; relative to this routine's S/U frame base | per voice: 1 = plays the percussion clef
* From s9o.asm
oacc                equ       277                    STACK OFFSET; relative to this routine's S/U frame base | shared accidental table, 32 entries, index = step+15: 0 none, else 4+alter
* From s9o.asm
ovacc               equ       309                    STACK OFFSET; relative to this routine's S/U frame base | per-voice tables (O1), 5 x 32
* From s9o.asm
oreg                equ       469                    STACK OFFSET; relative to this routine's S/U frame base | registers A..E: wave, eight weights, volume = 10 bytes each
* From s9o.asm
oregdef             equ       519                    STACK OFFSET; relative to this routine's S/U frame base | per register: 1 = defined by a J line
* From s9o.asm
oregprog            equ       524                    STACK OFFSET; relative to this routine's S/U frame base | per register: the matched GM program
* From s9o.asm
oregslot            equ       529                    STACK OFFSET; relative to this routine's S/U frame base | per register: the INSTRS slot
* From s9o.asm
onslot              equ       534                    STACK OFFSET; relative to this routine's S/U frame base | slots used
* From s9o.asm
orpstart            equ       535                    STACK OFFSET; relative to this routine's S/U frame base | ( : file offset of the notation to repeat (2)
* From s9o.asm
orpcount            equ       537                    STACK OFFSET; relative to this routine's S/U frame base | plays done
* From s9o.asm
orpend              equ       538                    STACK OFFSET; relative to this routine's S/U frame base | pending part repeat: $FF none, else the part
* From s9o.asm
orpsave             equ       539                    STACK OFFSET; relative to this routine's S/U frame base | file offset to come back to (2)
* From s9o.asm
orpin               equ       541                    STACK OFFSET; relative to this routine's S/U frame base | 1 while replaying a part
* From s9o.asm
opart               equ       542                    STACK OFFSET; relative to this routine's S/U frame base | 256 part offsets (512 bytes), 0 = undefined
* From s9o.asm
oval                equ       1054                   STACK OFFSET; relative to this routine's S/U frame base | scratch: the note's step (signed), pitch, etc.
* From s9o.asm
opitch              equ       1055                   STACK OFFSET; relative to this routine's S/U frame base
* From s9o.asm
oglyph              equ       1056                   STACK OFFSET; relative to this routine's S/U frame base
* From s9o.asm
oartic              equ       1057                   STACK OFFSET; relative to this routine's S/U frame base
* From s9o.asm
otick               equ       1058                   STACK OFFSET; relative to this routine's S/U frame base | the note's duration in score ticks (2)
* From s9o.asm
oflag               equ       1060                   STACK OFFSET; relative to this routine's S/U frame base | bit0: a note was seen in this measure
* From s9o.asm
otmp                equ       1061                   STACK OFFSET; relative to this routine's S/U frame base | 4 bytes scratch
* From s9o.asm
orest               equ       1065                   STACK OFFSET; relative to this routine's S/U frame base | 1 = the record is a rest
* From s9o.asm
otempoflag          equ       1066                   STACK OFFSET; relative to this routine's S/U frame base | 1 = a tempo record went out
* From s9o.asm
ogwbase             equ       1067                   STACK OFFSET; relative to this routine's S/U frame base | the register's weights (2)
* From s9o.asm
ogdist              equ       1069                   STACK OFFSET; relative to this routine's S/U frame base | best distance (2)
* From s9o.asm
ogbest              equ       1071                   STACK OFFSET; relative to this routine's S/U frame base | best entry (2)
* From s9o.asm
ogcur               equ       1073                   STACK OFFSET; relative to this routine's S/U frame base | this entry's distance (2)
* From s9o.asm
ogwp                equ       1075                   STACK OFFSET; relative to this routine's S/U frame base | walking weight pointer (2)
* From s9o.asm
ogep                equ       1077                   STACK OFFSET; relative to this routine's S/U frame base | walking entry pointer (2)
* From s9o.asm
omcount             equ       1079                   STACK OFFSET; relative to this routine's S/U frame base | measures closed, up to 4; $FF once the meter went out
* From s9o.asm
ognorm              equ       1080                   STACK OFFSET; relative to this routine's S/U frame base | the register scaled to 15 (8)
* From s9o.asm
iframe              equ       1088                   STACK FRAME SIZE in bytes; not an address
* From midi_score.inc; C clue: bdp.c:29
nevents             equ       UmeData_nevents
* From midi_score.inc; C clue: bdp.c:77
nparts              equ       UmeData_nparts
* From midi_score.inc; C clue: bdp.c:78
nstaves             equ       UmeData_nstaves
* From midi_score.inc; C clue: bdp.c:30
curind              equ       UmeData_curind
* From midi_score.inc; C clue: bdp.c:79
keysig              equ       UmeData_keysig
* From midi_score.inc; C clue: bdp.c:81
transp              equ       UmeData_transp
* From midi_score.inc; C clue: bdp.c:82
velo                equ       UmeData_velo
* From midi_score.inc; C clue: bglob.c:173
staves              equ       $0C19
* From midi_score.inc; C clue: bglob.c:176
parts               equ       $0C5F
* From midi_score.inc; C clue: bdp.c:86
nbars               equ       UmeData_nbars
* From midi_score.inc; C clue: bdp.c:118
gind                equ       UmeData_gind
* From midi_score.inc; C clue: bdp.c:118
xgoal               equ       UmeData_xgoal
* From midi_score.inc; C clue: bdp.c:106
rfr_scr             equ       UmeData_rfr_scr
                    endc

* ===== s9f: module-scoped definitions =====
                    ifdef     UME_SCOPE_S9F
* Mf2MIDI constants: author A4=$123F. Q16.16 G7/G#7 midpoint
* = $123F * 2^((104-0.5-69)/12); Q0.32 increment = 2^(1/12)-1.
MusBoundaryHi      equ       $85DA                  fixed-point constant, integer half of first boundary
MusBoundaryLo      equ       $9B6A                  fixed-point constant, fractional half of first boundary
MusRatioHi         equ       $0F38                  fixed-point constant, high half of semitone increment
MusRatioLo         equ       $F92E                  fixed-point constant, low half of semitone increment
mp_value           equ       0                      STACK OFFSET; Mf2MIDI X frame base, normalized input word
mp_bound           equ       2                      STACK OFFSET; Mf2MIDI X frame base, four-byte Q16.16 boundary
mp_product         equ       6                      STACK OFFSET; Mf2MIDI X frame base, eight-byte multiply result
mp_note            equ       14                     STACK OFFSET; Mf2MIDI X frame base, current MIDI candidate
mp_left            equ       15                     STACK OFFSET; Mf2MIDI X frame base, comparisons remaining
mp_frame           equ       16                     FRAME SIZE; Mf2MIDI locals, excluding saved X and return PC
* From s9f.asm
ipath               equ       0                      STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
ipass               equ       1                      STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
iroot               equ       2                      STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
irec                equ       4                      STACK OFFSET; relative to this routine's S/U frame base | native eight-byte event
* From s9f.asm
imap                equ       12                     STACK OFFSET; relative to this routine's S/U frame base | keys; staves +16; channels +96
* From s9f.asm
istf                equ       imap+16                STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
ichn                equ       imap+96                STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
ilo                 equ       124                    STACK OFFSET; relative to this routine's S/U frame base | four pitch ranges
* From s9f.asm
ihi                 equ       128                    STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
iseen               equ       132                    STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
itime               equ       136                    STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
imax                equ       138                    STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
icount              equ       140                    STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
imusic              equ       142                    STACK OFFSET; relative to this routine's S/U frame base | first nine-byte music record
* From s9f.asm
ifpos               equ       144                    STACK OFFSET; relative to this routine's S/U frame base | logical file position
* From s9f.asm
ibpos               equ       146                    STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
iblen               equ       148                    STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
ibuf                equ       150                    STACK OFFSET; relative to this routine's S/U frame base | 255-byte file buffer
iaccstate           equ       ibuf                   STACK OFFSET: s9f U frame; 50 accidental bytes AFTER all file I/O, reuses ibuf
iaccindex          equ       ibuf+50                STACK OFFSET: s9f U frame; spelling event index, same post-I/O lifetime
* From s9f.asm
imrec               equ       405                    STACK OFFSET; relative to this routine's S/U frame base | one Musica record
* From s9f.asm
itempo              equ       414                    STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
isections           equ       415                    STACK OFFSET; relative to this routine's S/U frame base | nine section offsets
* From s9f.asm
insections          equ       433                    STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
irepeating          equ       434                    STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
ireturn             equ       435                    STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
ibarno              equ       437                    STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
ilastbar            equ       439                    STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
ilen                equ       441                    STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
ibest               equ       443                    STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
ibase               equ       445                    STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
itmp                equ       447                    STACK OFFSET; relative to this routine's S/U frame base | four bytes
* From s9f.asm
ipitch              equ       451                    STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
ipitchout           equ       453                    STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
inote               equ       454                    STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
ivoice              equ       455                    STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
isrctime            equ       456                    STACK OFFSET; relative to this routine's S/U frame base | cumulative Musica time
* From s9f.asm
inexttime           equ       458                    STACK OFFSET; relative to this routine's S/U frame base | rounded cumulative score time
* From s9f.asm
iprevbar            equ       460                    STACK OFFSET; relative to this routine's S/U frame base | prior bar time for meter inference
* From s9f.asm
imetercnt           equ       462                    STACK OFFSET; relative to this routine's S/U frame base | eleven candidate-meter counters
* From s9f.asm
ibeats              equ       473                    STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
ibeatunit           equ       474                    STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
iprogs              equ       475                    STACK OFFSET; relative to this routine's S/U frame base | four waveform GM programs
* From s9f.asm
itones              equ       479                    STACK OFFSET; relative to this routine's S/U frame base | four voices' selected waveform slots
* From s9f.asm
iwave               equ       483                    STACK OFFSET; relative to this routine's S/U frame base | waveform scan index
* From s9f.asm
iclass              equ       484                    STACK OFFSET; relative to this routine's S/U frame base | current waveform GM/name class
* From s9f.asm
iwavefirst          equ       485                    STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
iwaveprev           equ       486                    STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
iwavemin            equ       487                    STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
iwavemax            equ       488                    STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
iwavesum            equ       489                    STACK OFFSET; relative to this routine's S/U frame base | total absolute change over one period
* From s9f.asm
iwavecount          equ       491                    STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
ipending            equ       492                    STACK OFFSET; relative to this routine's S/U frame base | four held MIDI pitches; 0 rest, $FF unset
* From s9f.asm
ipstart             equ       496                    STACK OFFSET; relative to this routine's S/U frame base | four held onset times
* From s9f.asm
ifinish             equ       504                    STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
icont               equ       506                    STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
iseglen             equ       507                    STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
imeasure            equ       509                    STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
inextbar            equ       511                    STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
ifirstbar           equ       513                    STACK OFFSET; relative to this routine's S/U frame base
* From s9f.asm
iframe              equ       515                    STACK FRAME SIZE in bytes; not an address
* From midi_score.inc; C clue: bdp.c:29
nevents             equ       UmeData_nevents
* From midi_score.inc; C clue: bdp.c:77
nparts              equ       UmeData_nparts
* From midi_score.inc; C clue: bdp.c:78
nstaves             equ       UmeData_nstaves
* From midi_score.inc; C clue: bdp.c:30
curind              equ       UmeData_curind
* From midi_score.inc; C clue: bdp.c:79
keysig              equ       UmeData_keysig
* From midi_score.inc; C clue: bdp.c:81
transp              equ       UmeData_transp
* From midi_score.inc; C clue: bdp.c:82
velo                equ       UmeData_velo
* From midi_score.inc; C clue: bglob.c:173
staves              equ       $0C19
* From midi_score.inc; C clue: bglob.c:176
parts               equ       $0C5F
* From midi_score.inc; C clue: bdp.c:86
nbars               equ       UmeData_nbars
* From midi_score.inc; C clue: bdp.c:118
gind                equ       UmeData_gind
* From midi_score.inc; C clue: bdp.c:118
xgoal               equ       UmeData_xgoal
* From midi_score.inc; C clue: bdp.c:106
rfr_scr             equ       UmeData_rfr_scr
                    endc

* ===== s9g: module-scoped definitions =====
                    ifdef     UME_SCOPE_S9G
* From s9g.asm
CfgCacheState       equ       0                      HEAP RECORD OFFSET: valid/blocked/dirty flags
CfgCacheEnd         equ       1                      HEAP RECORD OFFSET: absolute end pointer (word)
CfgCacheXml         equ       3                      HEAP RECORD OFFSET: NUL-terminated XML
CfgValid            equ       1                      cache flag: document accepted
CfgBlocked          equ       2                      cache flag: existing document unreadable/invalid
CfgDirty            equ       4                      cache flag: save at application exit
CfgCacheBytes       equ       CfgCacheXml+1025       HEAP RECORD SIZE
Cap                 equ       1024                   BUFFER CAPACITY; not an address
* From s9g.asm
Xml                 equ       0                      STACK OFFSET: word pointing to persistent XML, U frame
* From s9g.asm
PathBuf             equ       2                      STACK OFFSET; relative to this routine's S/U frame base
* From s9g.asm
Rel                 equ       PathBuf+257            STACK OFFSET; relative to this routine's S/U frame base
* From s9g.asm
Entry               equ       Rel+128                STACK OFFSET; relative to this routine's S/U frame base
* From s9g.asm
Dev                 equ       Entry+64               STACK OFFSET; relative to this routine's S/U frame base
* From s9g.asm
Own                 equ       Dev+32                 STACK OFFSET; relative to this routine's S/U frame base
* From s9g.asm
Parent              equ       Own+3                  STACK OFFSET; relative to this routine's S/U frame base
* From s9g.asm
Root                equ       Parent+3               STACK OFFSET; relative to this routine's S/U frame base
* From s9g.asm
Tag                 equ       Root+4                 STACK OFFSET; relative to this routine's S/U frame base
* From s9g.asm
Enc                 equ       Tag+16                 STACK OFFSET; relative to this routine's S/U frame base
* From s9g.asm
Fd                  equ       Enc+800                STACK OFFSET; relative to this routine's S/U frame base
* From s9g.asm
PathPtr             equ       Fd+1                   STACK OFFSET; relative to this routine's S/U frame base
* From s9g.asm
Value               equ       PathPtr+2              STACK OFFSET; relative to this routine's S/U frame base
* From s9g.asm
ValueEnd            equ       Value+2                STACK OFFSET; relative to this routine's S/U frame base
* From s9g.asm
DocEnd              equ       ValueEnd+2             STACK OFFSET; relative to this routine's S/U frame base
* From s9g.asm
Tmp                 equ       DocEnd+2               STACK OFFSET; relative to this routine's S/U frame base
* From s9g.asm
Cmd                 equ       Tmp+2                  STACK OFFSET; relative to this routine's S/U frame base
* From s9g.asm
Frame               equ       Cmd+1                  STACK FRAME SIZE in bytes; not an address
* From s9g.asm
DmDir               equ       0                      STACK OFFSET; relative to this routine's S/U frame base
* From s9g.asm
DmHead              equ       DmDir+2048             STACK OFFSET; relative to this routine's S/U frame base
* From s9g.asm
DmText              equ       DmHead+32              STACK OFFSET; relative to this routine's S/U frame base
* From s9g.asm
DmCur               equ       DmText+8               STACK OFFSET; relative to this routine's S/U frame base
* From s9g.asm
DmEnd               equ       DmCur+2                STACK OFFSET; relative to this routine's S/U frame base
* From s9g.asm
DmSys               equ       DmEnd+2                STACK OFFSET; relative to this routine's S/U frame base
* From s9g.asm
DmDat               equ       DmSys+2                STACK OFFSET; relative to this routine's S/U frame base
* From s9g.asm
DmMod               equ       DmDat+2                STACK OFFSET; relative to this routine's S/U frame base
* From s9g.asm
DmName              equ       DmMod+2                STACK OFFSET; relative to this routine's S/U frame base
* From s9g.asm
DmSlot              equ       DmName+4               STACK OFFSET; relative to this routine's S/U frame base
* From s9g.asm
DmCol               equ       DmSlot+1               STACK OFFSET; relative to this routine's S/U frame base
* From s9g.asm
DmPtr               equ       DmCol+1                STACK OFFSET; relative to this routine's S/U frame base
* From s9g.asm
DmFrame             equ       DmPtr+2                STACK FRAME SIZE in bytes; not an address
                    endc

* ===== s9s: module-scoped definitions =====
                    ifdef     UME_SCOPE_S9S
                    endc

* ===== s9t: module-scoped definitions =====
                    ifdef     UME_SCOPE_S9T
                    endc

* ===== s9u: module-scoped definitions =====
                    ifdef     UME_SCOPE_S9U
                    endc

* ===== s9w: module-scoped definitions =====
                    ifdef     UME_SCOPE_S9W
                    endc

* End of persistent editor storage; keep the C heap and temporary frames above this.
MidiInPath          equ       AuditionSavedFlags+2  path+1 for interrupt-captured /mi input
S9ModulePathBytes   equ       48                   BUFFER CAPACITY: slash, device, /s9/, module, NUL
S9ModuleDir         equ       MidiInPath+1         captured execution-device path; mutable module suffix
S9ModuleLeaf        equ       S9ModuleDir+S9ModulePathBytes pointer to module-name insertion point
ToolX               equ       S9ModuleLeaf+2      word: toolbox left byte column, 0..32
UmeStaticEnd        equ       ToolX+2
* @alloc ume shared ToolX 2 Toolbox left byte column
* @alloc ume shared S9ModuleDir S9ModulePathBytes Execution-device S9 module pathname
* @alloc ume shared S9ModuleLeaf 2 Pointer within S9ModuleDir to its filename
SS.MidiRead         equ       $D7                  MIDrv private GetStt: B=captured byte, C=no byte
SS.MidiActivity     equ       $D6                  MIDrv private GetStt: X=queued bytes, B=100-ms RX activity
* @alloc ume shared MidiInPath 1 Owned /mi path for interrupt-captured DIN input

* ABSOLUTE DATA NAMES - exact addresses already used by current instructions.
* reserved_XXXX means its complete purpose/extent is not established; NEVER free.
* The two prefixes represent different OS-9 processes; equal values do not alias.
* The C runtime words are identified by InitStackCheck/SbrkAlloc/math wrappers.
FrData_reserved_0000            equ       $0000    reserved legacy location; see symbol-references.csv for every use
FrData_reserved_000C            equ       $000C    reserved legacy location; see symbol-references.csv for every use
FrData_reserved_000E            equ       $000E    reserved legacy location; see symbol-references.csv for every use
FrData_reserved_0010            equ       $0010    reserved legacy location; see symbol-references.csv for every use
FrData_reserved_0016            equ       $0016    reserved legacy location; see symbol-references.csv for every use
FrData_reserved_0018            equ       $0018    reserved legacy location; see symbol-references.csv for every use
FrData_reserved_001A            equ       $001A    reserved legacy location; see symbol-references.csv for every use
FrData_reserved_001C            equ       $001C    reserved legacy location; see symbol-references.csv for every use
FrData_reserved_002E            equ       $002E    reserved legacy location; see symbol-references.csv for every use
FrData_reserved_0030            equ       $0030    reserved legacy location; see symbol-references.csv for every use
FrData_reserved_0031            equ       $0031    reserved legacy location; see symbol-references.csv for every use
FrData_reserved_0032            equ       $0032    reserved legacy location; see symbol-references.csv for every use
FrData_reserved_0033            equ       $0033    reserved legacy location; see symbol-references.csv for every use
FrData_reserved_0034            equ       $0034    reserved legacy location; see symbol-references.csv for every use
FrData_reserved_0036            equ       $0036    reserved legacy location; see symbol-references.csv for every use
FrData_reserved_0038            equ       $0038    reserved legacy location; see symbol-references.csv for every use
FrData_reserved_003A            equ       $003A    reserved legacy location; see symbol-references.csv for every use
FrData_reserved_01E2            equ       $01E2    reserved legacy location; see symbol-references.csv for every use
FrData_reserved_01E4            equ       $01E4    reserved legacy location; see symbol-references.csv for every use
FrData_reserved_01E6            equ       $01E6    reserved legacy location; see symbol-references.csv for every use
FrData_reserved_01E8            equ       $01E8    reserved legacy location; see symbol-references.csv for every use
FrData_reserved_0211            equ       $0211    reserved legacy location; see symbol-references.csv for every use
FrData_reserved_0212            equ       $0212    reserved legacy location; see symbol-references.csv for every use
FrData_reserved_0214            equ       $0214    reserved legacy location; see symbol-references.csv for every use
FrData_reserved_0303            equ       $0303    reserved legacy location; see symbol-references.csv for every use
FrData_reserved_030F            equ       $030F    reserved legacy location; see symbol-references.csv for every use
FrData_reserved_03BD            equ       $03BD    reserved legacy location; see symbol-references.csv for every use
FrData_reserved_03C3            equ       $03C3    reserved legacy location; see symbol-references.csv for every use
FrData_reserved_03C9            equ       $03C9    reserved legacy location; see symbol-references.csv for every use
FrData_reserved_03CF            equ       $03CF    reserved legacy location; see symbol-references.csv for every use
FrData_bdeltx                   equ       $1392    existing named data; see scoped declaration and C clue
FrData_bdelty                   equ       $1394    existing named data; see scoped declaration and C clue
FrData_bx1                      equ       $1396    existing named data; see scoped declaration and C clue
FrData_by1                      equ       $1398    existing named data; see scoped declaration and C clue
FrData_bdy                      equ       $139A    existing named data; see scoped declaration and C clue
FrData_bbp                      equ       $139C    existing named data; see scoped declaration and C clue
FrData_spacestk                 equ       $13CE    existing named data; see scoped declaration and C clue
FrData_spaceind                 equ       $13D6    existing named data; see scoped declaration and C clue
UmeData_reserved_0000           equ       $0000    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0003           equ       $0003    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0005           equ       $0005    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0007           equ       $0007    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0009           equ       $0009    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_000A           equ       $000A    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_000C           equ       $000C    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_000E           equ       $000E    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_000F           equ       $000F    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0010           equ       $0010    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0014           equ       $0014    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0016           equ       $0016    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0018           equ       $0018    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_001A           equ       $001A    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_001C           equ       $001C    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0020           equ       $0020    reserved legacy location; see symbol-references.csv for every use
UmeData_curevp                  equ       $0023    existing named data; see scoped declaration and C clue
UmeData_database                equ       $0025    existing named data; see scoped declaration and C clue
UmeData_curptop                 equ       $0027    existing named data; see scoped declaration and C clue
UmeData_nevents                 equ       $0029    existing named data; see scoped declaration and C clue
UmeData_curind                  equ       $002B    existing named data; see scoped declaration and C clue
UmeData_group                   equ       $002D    existing named data; see scoped declaration and C clue
UmeData_curpage                 equ       $002F    existing named data; see scoped declaration and C clue
UmeData_nmpages                 equ       $0031    existing named data; see scoped declaration and C clue
UmeData_godotind                equ       $0033    existing named data; see scoped declaration and C clue
UmeData_midiser                 equ       $003C    existing named data; see scoped declaration and C clue
UmeData_printype                equ       $003F    existing named data; see scoped declaration and C clue
UmeData_instren                 equ       $0040    existing named data; see scoped declaration and C clue
UmeData_mididev                 equ       $0041    existing named data; see scoped declaration and C clue
UmeData_clocken                 equ       $0042    existing named data; see scoped declaration and C clue
UmeData_midievts                equ       $0044    existing named data; see scoped declaration and C clue
UmeData_midinnmin               equ       $0045    existing named data; see scoped declaration and C clue
UmeData_midinnmax               equ       $0046    existing named data; see scoped declaration and C clue
UmeData_accentwt                equ       $0047    existing named data; see scoped declaration and C clue
UmeData_sticky                  equ       $004A    existing named data; see scoped declaration and C clue
UmeData_doesff                  equ       $004B    existing named data; see scoped declaration and C clue
UmeData_automarg                equ       $004C    existing named data; see scoped declaration and C clue
UmeData_beam                    equ       $004D    existing named data; see scoped declaration and C clue
UmeData_thick                   equ       $004E    existing named data; see scoped declaration and C clue
UmeData_halfstaf                equ       $004F    existing named data; see scoped declaration and C clue
UmeData_reserved_0050           equ       $0050    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0051           equ       $0051    reserved legacy location; see symbol-references.csv for every use
UmeData_xyoff                   equ       $0056    existing named data; see scoped declaration and C clue
UmeData_nparts                  equ       $0058    existing named data; see scoped declaration and C clue
UmeData_nstaves                 equ       $005A    existing named data; see scoped declaration and C clue
UmeData_keysig                  equ       $005C    existing named data; see scoped declaration and C clue
UmeData_secmin                  equ       $005E    existing named data; see scoped declaration and C clue
UmeData_transp                  equ       $0060    existing named data; see scoped declaration and C clue
UmeData_velo                    equ       $0062    existing named data; see scoped declaration and C clue
UmeData_nbars                   equ       $0064    existing named data; see scoped declaration and C clue
UmeData_scorelvl                equ       $0066    existing named data; see scoped declaration and C clue
UmeData_dencodur                equ       $0068    existing named data; see scoped declaration and C clue
UmeData_nzones                  equ       $006A    existing named data; see scoped declaration and C clue
UmeData_dendur                  equ       $006C    existing named data; see scoped declaration and C clue
UmeData_zonedur                 equ       $006E    existing named data; see scoped declaration and C clue
UmeData_curcurse                equ       $0074    existing named data; see scoped declaration and C clue
UmeData_broke                   equ       $0076    existing named data; see scoped declaration and C clue
UmeData_pldebug                 equ       $0078    existing named data; see scoped declaration and C clue
UmeData_compact                 equ       $007A    existing named data; see scoped declaration and C clue
UmeData_tripper                 equ       $007B    existing named data; see scoped declaration and C clue
UmeData_rfr_scr                 equ       $007C    existing named data; see scoped declaration and C clue
UmeData_rfr_bar                 equ       $007F    existing named data; see scoped declaration and C clue
UmeData_rfr_tit                 equ       $0080    existing named data; see scoped declaration and C clue
UmeData_dosqueez                equ       $0082    existing named data; see scoped declaration and C clue
UmeData_scrclock                equ       $0083    existing named data; see scoped declaration and C clue
UmeData_smf                     equ       $0084    existing named data; see scoped declaration and C clue
UmeData_xgoal                   equ       $0085    existing named data; see scoped declaration and C clue
UmeData_gbar                    equ       $0087    existing named data; see scoped declaration and C clue
UmeData_gind                    equ       $0089    existing named data; see scoped declaration and C clue
UmeData_gbarind                 equ       $008B    existing named data; see scoped declaration and C clue
UmeData_ritind                  equ       $008D    existing named data; see scoped declaration and C clue
UmeData_lftind                  equ       $008F    existing named data; see scoped declaration and C clue
UmeData_reserved_0093           equ       $0093    reserved legacy location; see symbol-references.csv for every use
UmeData_arg0                    equ       $0095    existing named data; see scoped declaration and C clue
UmeData_arg1                    equ       $0096    existing named data; see scoped declaration and C clue
UmeData_arg2                    equ       $0097    existing named data; see scoped declaration and C clue
UmeData_arg3                    equ       $0098    existing named data; see scoped declaration and C clue
UmeData_arg4                    equ       $0099    existing named data; see scoped declaration and C clue
UmeData_arg5                    equ       $009A    existing named data; see scoped declaration and C clue
UmeData_arg6                    equ       $009B    existing named data; see scoped declaration and C clue
UmeData_arg7                    equ       $009C    existing named data; see scoped declaration and C clue
UmeData_durleft                 equ       $00A5    existing named data; see scoped declaration and C clue
UmeData_midics                  equ       $00A8    existing named data; see scoped declaration and C clue
UmeData_tempo                   equ       $00AA    existing named data; see scoped declaration and C clue
UmeData_machtemp                equ       $00AC    existing named data; see scoped declaration and C clue
UmeData_contemp                 equ       $00AE    existing named data; see scoped declaration and C clue
UmeData_smfdelta                equ       $00B0    existing named data; see scoped declaration and C clue
UmeData_midicnt                 equ       $00B2    existing named data; see scoped declaration and C clue
UmeData_sound                   equ       $00B4    existing named data; see scoped declaration and C clue
UmeData_inending                equ       $00B5    existing named data; see scoped declaration and C clue
UmeData_senzarep                equ       $00B6    existing named data; see scoped declaration and C clue
UmeData_rsptr                   equ       $00B7    existing named data; see scoped declaration and C clue
UmeData_plpart                  equ       $00B9    existing named data; see scoped declaration and C clue
UmeData_plslot                  equ       $00BB    existing named data; see scoped declaration and C clue
UmeData_midnote                 equ       $00BF    existing named data; see scoped declaration and C clue
UmeData_oldmid                  equ       $00C1    existing named data; see scoped declaration and C clue
UmeData_chrind                  equ       $00C3    existing named data; see scoped declaration and C clue
UmeData_fix                     equ       $00C5    existing named data; see scoped declaration and C clue
UmeData_plart                   equ       $00C7    existing named data; see scoped declaration and C clue
UmeData_midchan                 equ       $00C9    existing named data; see scoped declaration and C clue
UmeData_accent                  equ       $00CB    existing named data; see scoped declaration and C clue
UmeData_runstat                 equ       $00CD    existing named data; see scoped declaration and C clue
UmeData_reserved_00CE           equ       $00CE    reserved legacy location; see symbol-references.csv for every use
UmeData_dp_sign                 equ       $00CF    existing named data; see scoped declaration and C clue
UmeData_dcds                    equ       $00D1    existing named data; see scoped declaration and C clue
UmeData_nthendx                 equ       $00D3    existing named data; see scoped declaration and C clue
UmeData_coda                    equ       $00D5    existing named data; see scoped declaration and C clue
UmeData_residue                 equ       $00D7    existing named data; see scoped declaration and C clue
UmeData_now                     equ       $00D9    existing named data; see scoped declaration and C clue
UmeData_lastime                 equ       $00DB    existing named data; see scoped declaration and C clue
UmeData_delt                    equ       $00DD    existing named data; see scoped declaration and C clue
UmeData_fmidi                   equ       $00DF    existing named data; see scoped declaration and C clue
UmeData_takeoff                 equ       $00E1    existing named data; see scoped declaration and C clue
UmeData_tilloff                 equ       $00E3    existing named data; see scoped declaration and C clue
UmeData_ttemp                   equ       $00E5    existing named data; see scoped declaration and C clue
UmeData_towait                  equ       $00E7    existing named data; see scoped declaration and C clue
UmeData_reserved_00E8           equ       $00E8    reserved legacy location; see symbol-references.csv for every use
UmeData_crdelt                  equ       $00E9    existing named data; see scoped declaration and C clue
UmeData_acdelt                  equ       $00EB    existing named data; see scoped declaration and C clue
UmeData_crbeglvl                equ       $00ED    existing named data; see scoped declaration and C clue
UmeData_acbegmt                 equ       $00EF    existing named data; see scoped declaration and C clue
UmeData_crmult                  equ       $00F1    existing named data; see scoped declaration and C clue
UmeData_acmult                  equ       $00F3    existing named data; see scoped declaration and C clue
UmeData_acscale                 equ       $00F5    existing named data; see scoped declaration and C clue
UmeData_kpoctave                equ       $00FF    existing named data; see scoped declaration and C clue
UmeData_reserved_0106           equ       $0106    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0107           equ       $0107    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0182           equ       $0182    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_01A6           equ       $01A6    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_01C4           equ       $01C4    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0345           equ       $0345    reserved legacy location; see symbol-references.csv for every use
UmeData_c_heaptop               equ       $034B    existing named data; see scoped declaration and C clue
UmeData_c_errno                 equ       $034F    existing named data; see scoped declaration and C clue
UmeData_pcharmaus               equ       $0353    existing named data; see scoped declaration and C clue
UmeData_pkeymaus                equ       $0355    existing named data; see scoped declaration and C clue
UmeData_pinkey                  equ       $0357    existing named data; see scoped declaration and C clue
UmeData_pgets                   equ       $0359    existing named data; see scoped declaration and C clue
UmeData_pfindstaff              equ       $035B    existing named data; see scoped declaration and C clue
UmeData_pprintf                 equ       $035D    existing named data; see scoped declaration and C clue
UmeData_psprintf                equ       $035F    existing named data; see scoped declaration and C clue
UmeData_powrite                 equ       $0361    existing named data; see scoped declaration and C clue
UmeData_psoowee                 equ       $0363    existing named data; see scoped declaration and C clue
UmeData_pnfwrite                equ       $0365    existing named data; see scoped declaration and C clue
UmeData_pgksig                  equ       $0367    existing named data; see scoped declaration and C clue
UmeData_pgtsig                  equ       $0369    existing named data; see scoped declaration and C clue
UmeData_pievtinit               equ       $0373    existing named data; see scoped declaration and C clue
UmeData_ptextmen                equ       $0375    existing named data; see scoped declaration and C clue
UmeData_pbeep                   equ       $0377    existing named data; see scoped declaration and C clue
UmeData_pflush                  equ       $0379    existing named data; see scoped declaration and C clue
UmeData_palert                  equ       $037B    existing named data; see scoped declaration and C clue
UmeData_phit                    equ       $037D    existing named data; see scoped declaration and C clue
UmeData_pputmidi                equ       $037F    existing named data; see scoped declaration and C clue
UmeData_pmflush                 equ       $0381    existing named data; see scoped declaration and C clue
UmeData_pputchar                equ       $0383    existing named data; see scoped declaration and C clue
UmeData_pfmarks                 equ       $0385    existing named data; see scoped declaration and C clue
UmeData_pfixup                  equ       $0387    existing named data; see scoped declaration and C clue
UmeData_psmfwrit                equ       $0389    existing named data; see scoped declaration and C clue
UmeData_pdrawnr                 equ       $038B    existing named data; see scoped declaration and C clue
UmeData_pgivebac                equ       $038F    existing named data; see scoped declaration and C clue
UmeData_pfindts                 equ       $0391    existing named data; see scoped declaration and C clue
UmeData_pplay                   equ       $0393    existing named data; see scoped declaration and C clue
UmeData_ptranprt                equ       $0395    existing named data; see scoped declaration and C clue
UmeData_pclonmid                equ       $0397    existing named data; see scoped declaration and C clue
UmeData_ppswap                  equ       $0399    existing named data; see scoped declaration and C clue
UmeData_pfixmarx                equ       $039B    existing named data; see scoped declaration and C clue
UmeData_pparse                  equ       $039D    existing named data; see scoped declaration and C clue
UmeData_pmouce                  equ       $039F    existing named data; see scoped declaration and C clue
UmeData_pyesno                  equ       $03A1    existing named data; see scoped declaration and C clue
UmeData_pgetempty               equ       $03A5    existing named data; see scoped declaration and C clue
UmeData_pswapevts               equ       $03A7    existing named data; see scoped declaration and C clue
UmeData_pregen                  equ       $03A9    existing named data; see scoped declaration and C clue
UmeData_penter                  equ       $03AD    existing named data; see scoped declaration and C clue
UmeData_premove                 equ       $03AF    existing named data; see scoped declaration and C clue
UmeData_pfulltime               equ       $03B3    existing named data; see scoped declaration and C clue
UmeData_pmakroom                equ       $03B5    existing named data; see scoped declaration and C clue
UmeData_reserved_03B7           equ       $03B7    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_03B8           equ       $03B8    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_03C3           equ       $03C3    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_03C4           equ       $03C4    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_03C6           equ       $03C6    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_03C8           equ       $03C8    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_03CB           equ       $03CB    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_03CD           equ       $03CD    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_03CE           equ       $03CE    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_03CF           equ       $03CF    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_03D0           equ       $03D0    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_03D1           equ       $03D1    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_03D2           equ       $03D2    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_03D3           equ       $03D3    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_03E5           equ       $03E5    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_03E7           equ       $03E7    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_03E9           equ       $03E9    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_03EB           equ       $03EB    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_03F3           equ       $03F3    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0BEB           equ       $0BEB    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0CCB           equ       $0CCB    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0CCC           equ       $0CCC    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0CCE           equ       $0CCE    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0CD0           equ       $0CD0    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0CD2           equ       $0CD2    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0CD4           equ       $0CD4    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0CD5           equ       $0CD5    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0CD6           equ       $0CD6    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0CD7           equ       $0CD7    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0D4E           equ       $0D4E    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0DD8           equ       $0DD8    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0DDC           equ       $0DDC    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0E4D           equ       $0E4D    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0E4F           equ       $0E4F    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0E51           equ       $0E51    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0E53           equ       $0E53    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0E55           equ       $0E55    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0E57           equ       $0E57    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0E59           equ       $0E59    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0E5B           equ       $0E5B    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0ED8           equ       $0ED8    reserved legacy location; see symbol-references.csv for every use
UmeData_reserved_0EDA           equ       $0EDA    reserved legacy location; see symbol-references.csv for every use

* OWNED STORAGE: @alloc process scope symbol bytes purpose. Checked at build time.
UmeLegacyReserved   equ       $0000
* @alloc ume shared UmeLegacyReserved 4096 Legacy data, runtime and unclassified gaps; no new allocation
* @alloc ume UMUSE3 GPTab 64 Physical block table
* @alloc ume UMUSE3 GPMapped 2 Mapped buffer ID
* @alloc ume UMUSE3 GPAddr 2 Mapped address
* @alloc ume UMUSE3 FranParam 3 Fork parameter bytes
* @alloc ume shared MsSysDAT 2 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared MsPrevBtn 1 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared MsStamp 2 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared MsLast 1 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared MsRightPrev 1 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared MsRightNew 1 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared MsModeSave 2 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared LayerSave 2 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared Bmp12CtrlSave 2 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared Bmp12CtrlSaved 1 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared RenderNotes 1 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared LayoutOnly 1 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared FocusedPart 2 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared FocusDirty 1 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared FocusOnly 1 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared Vs1053Out 1 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared BeamFocusPass 1 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared PaintedFocus 2 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared MenuBarHover 2 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared MidiSelected 1 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared pMidiSend 2 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared MidiRouteNames 64 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared MidiRoutePaths 4 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared KeepXgoal 2 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared pSAMSend 2 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared AuditionMode 1 Shared editor storage; aliases require an explicit lifetime contract
* @word ume shared MsPrevBtn Clear previous-button byte and high byte of adjacent MsStamp
* @word ume shared MsStamp+1 Clear low byte of MsStamp and adjacent MsLast
* @word ume shared MsRightPrev Clear adjacent previous/new right-button bytes
* @word ume shared MidiRxStatus Clear adjacent running-status and expected-length bytes
* @word ume shared MidiRxCount Clear adjacent receive-count and drop-state bytes
* @alloc ume shared AuditionSavedFlags 2 SMF and verbose flag bytes saved/restored by S9P audition
UmePadding10AF      equ       $10AF
* @alloc ume shared UmePadding10AF 1 Retired one-byte audition allocation; never reuse PianoSym at next byte
* @alloc ume shared pMidiEcho 2 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared MidiRxStatus 1 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared MidiRxNeed 1 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared MidiRxCount 1 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared MidiRxDrop 1 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared MidiRxBuffer 64 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared MidiPlaying 1 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared pMidiNewScore 2 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared pMidiStaffInit 2 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared pMidiEventPtr 2 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared KeepGind 2 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared FranReply 1 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared pPipeMenu 2 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared pMenu3 2 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared MenuStates 40 Shared editor storage; aliases require an explicit lifetime contract
* @alloc ume shared pConfigCache 2 Pointer to persistent XML cache owned by S9G
* @alloc ume shared pDriveMenu 2 Shared editor storage; aliases require an explicit lifetime contract
UmePadding1047     equ       $1047
UmePadding10B0     equ       $10B0
* @alloc ume shared UmePadding1047 1 Reserved padding
* @alloc ume shared UmePadding10B0 1 Reserved padding
* The legacy reservation includes these intentional lifetime aliases:
* $50-$51 LayHov; $52-$53 CtxX / LayDropReset / WizForce; $54 PressHeld / NoAbort;
* $55 FakeDown; $BD-$BE CtxY overlays the original PLAY white word while editing.
* MenuStates also hosts PianoVec/PianoRts/PianoQN/PianoQ only during playback.
* pDriveMenu is NOT an alias of KeepGind. Its 83-byte payload is C-heap owned.
* Browser page state is S-relative ($0760..$0767 within its $078A-byte frame).
* It does NOT alias the absolute instrument-value area at $075F.
* s9gui: all bytes below FrDataEnd are reserved in its SEPARATE process. Port statics
* reuse retired fields as individually documented; FrNoDirty aliases FrFocusMask.
FrLegacyReserved    equ       $0000
* @alloc fran S9GUI FrLegacyReserved FrDataEnd Entire Fran data and window arena, including reused retired fields


* Remaining named C globals and callback table bounds.
UmeData_mydat0                  equ       $0022    C-backed legacy data; see scoped evidence
UmeData_undind                  equ       $0035    C-backed legacy data; see scoped evidence
UmeData_forergb                 equ       $0037    C-backed legacy data; see scoped evidence
UmeData_backrgb                 equ       $0039    C-backed legacy data; see scoped evidence
UmeData_hires                   equ       $003B    C-backed legacy data; see scoped evidence
UmeData_midipak                 equ       $003D    C-backed legacy data; see scoped evidence
UmeData_readonly                equ       $003E    C-backed legacy data; see scoped evidence
UmeData_left                    equ       $0043    C-backed legacy data; see scoped evidence
UmeData_pitcarry                equ       $0048    C-backed legacy data; see scoped evidence
UmeData_snap                    equ       $0049    C-backed legacy data; see scoped evidence
UmeData_uptime                  equ       $0070    C-backed legacy data; see scoped evidence
UmeData_dntime                  equ       $0072    C-backed legacy data; see scoped evidence
UmeData_aborted                 equ       $0079    C-backed legacy data; see scoped evidence
UmeData_rfr_men                 equ       $007D    C-backed legacy data; see scoped evidence
UmeData_rfr_rep                 equ       $007E    C-backed legacy data; see scoped evidence
UmeData_automon                 equ       $0081    C-backed legacy data; see scoped evidence
UmeData_length                  equ       $0091    C-backed legacy data; see scoped evidence
UmeData_rshift                  equ       $009D    C-backed legacy data; see scoped evidence
UmeData_vslot                   equ       $009F    C-backed legacy data; see scoped evidence
UmeData_strleft                 equ       $00A1    C-backed legacy data; see scoped evidence
UmeData_trileft                 equ       $00A3    C-backed legacy data; see scoped evidence
UmeData_tripnow                 equ       $00A7    C-backed legacy data; see scoped evidence
UmeData_white                   equ       $00BD    C-backed legacy data; see scoped evidence
UmeData_autooct                 equ       $00F7    C-backed legacy data; see scoped evidence
UmeData_kpmode                  equ       $00F8    C-backed legacy data; see scoped evidence
UmeData_kpoctch                 equ       $00F9    C-backed legacy data; see scoped evidence
UmeData_kpnotch                 equ       $00FA    C-backed legacy data; see scoped evidence
UmeData_kpdur                   equ       $00FB    C-backed legacy data; see scoped evidence
UmeData_kpartic                 equ       $00FD    C-backed legacy data; see scoped evidence
UmeData_kplnotenum              equ       $0101    C-backed legacy data; see scoped evidence
UmeData_brush                   equ       $010B    C-backed legacy data; see scoped evidence
UmeData_clefs                   equ       $0162    C-backed legacy data; see scoped evidence
UmeData_toolson                 equ       $03CA    C-backed legacy data; see scoped evidence
UmeData_lastclik                equ       $03D4    C-backed legacy data; see scoped evidence
UmeData_kpind                   equ       $03D6    C-backed legacy data; see scoped evidence
UmeData_kplast                  equ       $03D8    C-backed legacy data; see scoped evidence
UmeData_kplastact               equ       $03DA    C-backed legacy data; see scoped evidence
UmeData_autopick                equ       $03DC    C-backed legacy data; see scoped evidence
UmeData_autoclone               equ       $03DD    C-backed legacy data; see scoped evidence
UmeData_kpclone                 equ       $03DE    C-backed legacy data; see scoped evidence
UmeData_kpdmod                  equ       $03DF    C-backed legacy data; see scoped evidence
UmeData_kpitmod                 equ       $03E1    C-backed legacy data; see scoped evidence
UmeData_kvslot                  equ       $03E3    C-backed legacy data; see scoped evidence
UmeData_grafxes                 equ       $0425    C-backed legacy data; see scoped evidence
UmeData_grafyes                 equ       $05C2    C-backed legacy data; see scoped evidence
UmeData_staves                  equ       $0C19    C-backed legacy data; see scoped evidence
UmeData_parts                   equ       $0C5F    C-backed legacy data; see scoped evidence
UmeData_paddclone               equ       $036B    C-backed legacy data; see scoped evidence
UmeData_ppluspart               equ       $036D    C-backed legacy data; see scoped evidence
UmeData_paddbars                equ       $036F    C-backed legacy data; see scoped evidence
UmeData_prepart                 equ       $0371    C-backed legacy data; see scoped evidence
UmeData_ppartline               equ       $038D    C-backed legacy data; see scoped evidence
UmeData_pexprmenu               equ       $03A3    C-backed legacy data; see scoped evidence
UmeData_pcod2raw                equ       $03AB    C-backed legacy data; see scoped evidence
UmeData_pchip                   equ       $03B1    C-backed legacy data; see scoped evidence
FrData_arg0                     equ       $001E    C-backed legacy data; see scoped evidence
FrData_arg1                     equ       $001F    C-backed legacy data; see scoped evidence
FrData_arg2                     equ       $0020    C-backed legacy data; see scoped evidence
FrData_arg3                     equ       $0021    C-backed legacy data; see scoped evidence
FrData_arg4                     equ       $0022    C-backed legacy data; see scoped evidence
FrData_arg5                     equ       $0023    C-backed legacy data; see scoped evidence
FrData_arg6                     equ       $0024    C-backed legacy data; see scoped evidence
FrData_broke                    equ       $0025    C-backed legacy data; see scoped evidence
FrData_lastaffy                 equ       $0026    C-backed legacy data; see scoped evidence
FrData_lastclef                 equ       $0028    C-backed legacy data; see scoped evidence
FrData_lastnrx                  equ       $002A    C-backed legacy data; see scoped evidence
FrData_lastnry                  equ       $002C    C-backed legacy data; see scoped evidence
FrData_nparts                   equ       $0041    C-backed legacy data; see scoped evidence
FrData_nstaves                  equ       $0043    C-backed legacy data; see scoped evidence
FrData_keysig                   equ       $0045    C-backed legacy data; see scoped evidence
FrData_brushx                   equ       $0047    C-backed legacy data; see scoped evidence
FrData_brushy                   equ       $0049    C-backed legacy data; see scoped evidence
FrData_tooly                    equ       $004B    C-backed legacy data; see scoped evidence
FrData_curcurse                 equ       $004D    C-backed legacy data; see scoped evidence
FrData_numer                    equ       $004F    C-backed legacy data; see scoped evidence
FrData_denom                    equ       $0051    C-backed legacy data; see scoped evidence
FrData_pnrows                   equ       $0053    C-backed legacy data; see scoped evidence
FrData_dummy                    equ       $0002    C-backed legacy data; see scoped evidence
FrData_vdgram                   equ       $0004    C-backed legacy data; see scoped evidence
FrData_grafmode                 equ       $0006    C-backed legacy data; see scoped evidence
FrData_tgwmode                  equ       $0007    C-backed legacy data; see scoped evidence
FrData_wp                       equ       $0008    C-backed legacy data; see scoped evidence
FrData_alfacurse                equ       $000A    C-backed legacy data; see scoped evidence
FrData_thick                    equ       $0040    C-backed legacy data; see scoped evidence
FrData_afxi                     equ       $0054    C-backed legacy data; see scoped evidence
FrData_afxa1                    equ       $0056    C-backed legacy data; see scoped evidence
FrData_afxa2                    equ       $0058    C-backed legacy data; see scoped evidence
FrData_hgt                      equ       $005A    C-backed legacy data; see scoped evidence
FrData_width                    equ       $005C    C-backed legacy data; see scoped evidence
FrData_dy                       equ       $005E    C-backed legacy data; see scoped evidence
FrData_xl                       equ       $0060    C-backed legacy data; see scoped evidence
FrData_xr                       equ       $0062    C-backed legacy data; see scoped evidence
FrData_ibase                    equ       $0064    C-backed legacy data; see scoped evidence
FrData_iptr                     equ       $0066    C-backed legacy data; see scoped evidence
FrData_igoal                    equ       $0068    C-backed legacy data; see scoped evidence
FrData_paint                    equ       $006A    C-backed legacy data; see scoped evidence
FrData_color                    equ       $006C    C-backed legacy data; see scoped evidence
FrData_col                      equ       $0070    C-backed legacy data; see scoped evidence
FrData_bgoal                    equ       $0072    C-backed legacy data; see scoped evidence
FrData_cleft                    equ       $0078    C-backed legacy data; see scoped evidence
FrData_cright                   equ       $007A    C-backed legacy data; see scoped evidence
FrData_ctop                     equ       $007C    C-backed legacy data; see scoped evidence
FrData_cbot                     equ       $007E    C-backed legacy data; see scoped evidence
FrData_cwid                     equ       $0080    C-backed legacy data; see scoped evidence
FrData_cheight                  equ       $0082    C-backed legacy data; see scoped evidence
FrData_curse                    equ       $0084    C-backed legacy data; see scoped evidence
FrData_wncols                   equ       $0086    C-backed legacy data; see scoped evidence
FrData_wnrows                   equ       $0088    C-backed legacy data; see scoped evidence
FrData_wcleft                   equ       $008A    C-backed legacy data; see scoped evidence
FrData_wcrght                   equ       $008C    C-backed legacy data; see scoped evidence
FrData_wtopy                    equ       $008E    C-backed legacy data; see scoped evidence
FrData_wboty                    equ       $0090    C-backed legacy data; see scoped evidence
FrData_whgt                     equ       $0092    C-backed legacy data; see scoped evidence
FrData_nowinv                   equ       $0094    C-backed legacy data; see scoped evidence
FrData_wsavsiz                  equ       $0096    C-backed legacy data; see scoped evidence
FrData_stocker                  equ       $0098    C-backed legacy data; see scoped evidence
FrData_curaddr                  equ       $0099    C-backed legacy data; see scoped evidence
FrData_homeaddr                 equ       $009B    C-backed legacy data; see scoped evidence
FrData_curcol                   equ       $009D    C-backed legacy data; see scoped evidence
FrData_currow                   equ       $009F    C-backed legacy data; see scoped evidence
FrData_curpx                    equ       $00A1    C-backed legacy data; see scoped evidence
FrData_curpy                    equ       $00A3    C-backed legacy data; see scoped evidence
FrData_texsave                  equ       $00A5    C-backed legacy data; see scoped evidence
FrData_fprtr                    equ       $00A7    C-backed legacy data; see scoped evidence
FrData_printy                   equ       $00A9    C-backed legacy data; see scoped evidence
FrData_printype                 equ       $00AB    C-backed legacy data; see scoped evidence
FrData_prpage                   equ       $00AC    C-backed legacy data; see scoped evidence
FrData_dosqueeze                equ       $00AD    C-backed legacy data; see scoped evidence
FrData_doesff                   equ       $00AE    C-backed legacy data; see scoped evidence
FrData_automarg                 equ       $00AF    C-backed legacy data; see scoped evidence
FrData_fes                      equ       $00B0    C-backed legacy data; see scoped evidence
FrData_brush                    equ       $0210    C-backed legacy data; see scoped evidence
FrData_qnote                    equ       $0215    C-backed legacy data; see scoped evidence
FrData_qrest                    equ       $021A    C-backed legacy data; see scoped evidence
FrData_cursors                  equ       $0311    C-backed legacy data; see scoped evidence
FrData_brushsave                equ       $1290    C-backed legacy data; see scoped evidence
FrData_staves                   equ       $1308    C-backed legacy data; see scoped evidence
FrData_parts                    equ       $134E    C-backed legacy data; see scoped evidence
FrData_wstack                   equ       $139E    C-backed legacy data; see scoped evidence
FrData_space                    equ       $13D8    C-backed legacy data; see scoped evidence
UmeData_pmenukey                equ       $0351    fcnptrs.h first entry; unused unless initialized
UmeCallbackBase                 equ       $0351
UmeCallbackCount                equ       51
UmeCallbackEnd                  equ       UmeCallbackBase+UmeCallbackCount*2

* REGISTERED EXISTING ALIASES. New aliases require owner/lifetime review.
* @alias fran S9GUI afxa1 FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI afxa2 FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI afxi FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI alfacurse FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI arg0 FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI arg1 FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI arg2 FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI arg3 FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI arg4 FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI arg5 FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI arg6 FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI automarg FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI bgoal FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI broke FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI brush FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI brushx FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI brushy FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI cbot FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI cheight FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI cleft FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI col FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI color FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI cright FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI ctop FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI curaddr FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI curcol FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI curcurse FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI currow FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI curse FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI cwid FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI denom FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI doesff FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI dosqueeze FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI dy FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI fprtr FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI Fr4Src FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI FrBM0 FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI FrBM0Blk FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI FrBMShown FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI FrChrome FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI FrDirty FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI FrDma FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI FrEatCR FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI FrEcho FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI FrFocusInk FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI FrKeyBank FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI FrNoDirty FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI FrNumBuf FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI FrOpaque FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI FrRow FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI FrSave FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI FrShown FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI FrSym FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI FrTailBlk FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI FrTxtInk FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI FrUnder FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI FrWin FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI FrWinP FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI grafmode FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI hgt FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI homeaddr FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI ibase FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI igoal FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI iptr FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI keysig FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI lastaffy FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI lastclef FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI lastnrx FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI nowinv FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI nparts FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI nstaves FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI numer FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI paint FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI pnrows FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI printy FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI printype FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI prpage FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI qrest FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI stocker FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI texsave FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI tgwmode FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI thick FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI tooly FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI vdgram FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI wboty FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI wcleft FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI wcrght FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI width FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI wncols FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI wnrows FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI wp FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI wsavsiz FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI wtopy FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI xl FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran S9GUI xr FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_bbp FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_bdeltx FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_bdelty FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_bdy FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_bx1 FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_by1 FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_reserved_0000 FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_reserved_000C FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_reserved_000E FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_reserved_0010 FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_reserved_0016 FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_reserved_0018 FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_reserved_001A FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_reserved_001C FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_reserved_002E FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_reserved_0030 FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_reserved_0031 FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_reserved_0032 FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_reserved_0033 FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_reserved_0034 FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_reserved_0036 FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_reserved_0038 FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_reserved_003A FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_reserved_01E2 FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_reserved_01E4 FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_reserved_01E6 FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_reserved_01E8 FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_reserved_0211 FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_reserved_0212 FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_reserved_0214 FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_reserved_0303 FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_reserved_030F FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_reserved_03BD FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_reserved_03C3 FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_reserved_03C9 FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_reserved_03CF FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_spaceind FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias fran shared FrData_spacestk FrLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9C vBase UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9C vCod2raw UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9C vEvents UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9C vGiveback UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9C vGPTab GPTab Existing operand; extent and users are in symbol-references.csv
* @alias ume S9C vPages UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9C vPswap UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9I nevents UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K arg0 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K arg1 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K arg2 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K arg3 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K arg4 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K arg5 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K autoclone UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K autooct UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K autopick UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K brush UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K curcurse UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K curevp UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K curind UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K curpage UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K curptop UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K database UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K gind UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K godotind UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K kpartic UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K kpclone UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K kpdmod UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K kpdur UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K kpind UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K kpitmod UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K kplast UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K kplastact UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K kplnotenum UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K kpmode UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K kpnotch UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K kpoctave UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K kpoctch UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K kvslot UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K lastclik UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K lftind UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K nevents UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K nparts UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K paddbars UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K paddclone UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K palert UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K pbeep UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K pchip UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K pcod2raw UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K pdrawnr UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K penter UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K pexprmenu UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K pflush UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K pfulltime UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K pgets UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K pitcarry UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K pmouce UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K pnfwrite UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K ppartline UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K ppluspart UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K pprintf UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K ppswap UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K pputchar UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K prepart UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K pyesno UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K rfr_bar UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K rfr_men UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K rfr_rep UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K rfr_scr UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K ritind UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K toolson UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K undind UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K xgoal UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume S9K xyoff UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 aborted UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 accentwt UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 arg0 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 arg1 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 arg2 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 arg3 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 arg4 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 arg5 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 automarg UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 automon UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 backrgb UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 beam UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 broke UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 clocken UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 compact UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 curcurse UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 curevp UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 curind UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 curpage UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 curptop UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 database UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 dencodur UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 dendur UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 dntime UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 doesff UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 fmidi UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 forergb UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 gind UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 group UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 halfstaf UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 hires UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 instren UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 keysig UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 lastclik UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 left UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 lftind UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 mididev UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 midievts UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 midinnmax UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 midinnmin UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 midipak UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 midiser UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 nbars UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 nevents UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 nmpages UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 nparts UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 nstaves UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 nzones UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 paddbars UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 paddclone UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 palert UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pbeep UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pcharmaus UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pchip UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pclonmid UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pcod2raw UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pdrawnr UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 penter UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pexprmenu UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pfindstaff UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pfindts UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pfixmarx UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pfixup UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pflush UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pfmarks UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pfulltime UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pgetempty UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pgets UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pgivebac UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pgksig UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pgtsig UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 phit UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 PianoBM FranParam Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 PianoBM1 FranParam Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 PianoPend UmePadding1047 Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 PianoStat FranParam Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 PianoSym UmePadding10B0 Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pievtinit UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pinkey UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pitcarry UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pkeymaus UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pldebug UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pmakroom UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pmflush UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pmouce UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pnfwrite UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 powrite UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pparse UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 ppartline UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pplay UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 ppluspart UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pprintf UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 ppswap UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pputchar UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pputmidi UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pregen UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 premove UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 prepart UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 printype UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 psmfwrit UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 psoowee UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 psprintf UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pswapevts UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 ptextmen UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 ptranprt UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 pyesno UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 readonly UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 rfr_bar UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 rfr_men UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 rfr_rep UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 rfr_scr UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 rfr_tit UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 ritind UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 rshift UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 scorelvl UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 secmin UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 smf UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 snap UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 sticky UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 strleft UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 thick UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 toolson UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 transp UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 trileft UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 tripnow UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 tripper UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 undind UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 uptime UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 velo UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 vslot UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 xgoal UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 xyoff UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume UMUSE3 zonedur UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared CtxX UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared CtxY UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared FakeDown UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared LayDropReset UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared LayHov UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared NoAbort UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared pct7 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared pctn1 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared pctn2 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared PianoQN MenuStates Existing operand; extent and users are in symbol-references.csv
* @alias ume shared PianoRts MenuStates Existing operand; extent and users are in symbol-references.csv
* @alias ume shared PianoVec MenuStates Existing operand; extent and users are in symbol-references.csv
* @alias ume shared PressHeld UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_acbegmt UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_accent UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_accentwt UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_acdelt UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_acmult UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_acscale UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_arg0 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_arg1 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_arg2 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_arg3 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_arg4 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_arg5 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_arg6 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_arg7 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_automarg UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_beam UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_broke UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_c_errno UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_c_heaptop UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_chrind UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_clocken UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_coda UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_compact UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_contemp UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_crbeglvl UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_crdelt UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_crmult UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_curcurse UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_curevp UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_curind UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_curpage UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_curptop UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_database UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_dcds UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_delt UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_dencodur UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_dendur UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_doesff UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_dosqueez UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_dp_sign UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_durleft UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_fix UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_fmidi UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_gbar UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_gbarind UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_gind UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_godotind UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_group UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_halfstaf UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_inending UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_instren UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_keysig UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_kpoctave UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_lastime UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_lftind UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_machtemp UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_midchan UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_midicnt UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_midics UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_mididev UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_midievts UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_midinnmax UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_midinnmin UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_midipak UmeLegacyReserved Legacy MIDI output flag; startup default moved to S9R
* @alias ume shared UmeData_midiser UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_midnote UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_nbars UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_nevents UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_nmpages UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_now UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_nparts UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_nstaves UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_nthendx UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_nzones UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_oldmid UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_palert UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_pbeep UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_pcharmaus UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_pclonmid UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_pdrawnr UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_penter UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_pfindstaff UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_pfindts UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_pfixmarx UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_pfixup UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_pflush UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_pfmarks UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_pfulltime UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_pgetempty UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_pgets UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_pgivebac UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_pgksig UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_pgtsig UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_phit UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_pievtinit UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_pinkey UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_pkeymaus UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_plart UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_pldebug UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_plpart UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_plslot UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_pmakroom UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_pmflush UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_pmouce UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_pnfwrite UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_powrite UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_pparse UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_pplay UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_pprintf UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_ppswap UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_pputchar UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_pputmidi UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_pregen UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_premove UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_printype UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_psmfwrit UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_psoowee UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_psprintf UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_pswapevts UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_ptextmen UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_ptranprt UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_pyesno UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0000 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0003 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0005 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0007 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0009 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_000A UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_000C UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_000E UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_000F UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0010 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0014 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0016 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0018 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_001A UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_001C UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0020 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0050 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0051 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0093 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_00CE UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_00E8 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0106 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0107 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0182 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_01A6 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_01C4 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0345 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_03B7 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_03B8 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_03C3 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_03C4 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_03C6 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_03C8 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_03CB UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_03CD UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_03CE UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_03CF UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_03D0 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_03D1 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_03D2 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_03D3 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_03E5 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_03E7 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_03E9 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_03EB UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_03F3 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0BEB UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0CCB UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0CCC UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0CCE UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0CD0 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0CD2 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0CD4 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0CD5 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0CD6 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0CD7 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0D4E UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0DD8 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0DDC UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0E4D UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0E4F UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0E51 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0E53 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0E55 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0E57 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0E59 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0E5B UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0ED8 UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_reserved_0EDA UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_residue UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_rfr_bar UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_rfr_scr UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_rfr_tit UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_ritind UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_rsptr UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_runstat UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_scorelvl UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_scrclock UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_secmin UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_senzarep UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_smf UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_smfdelta UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_sound UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_sticky UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_takeoff UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_tempo UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_thick UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_tilloff UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_towait UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_transp UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_tripper UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_ttemp UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_velo UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_xgoal UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_xyoff UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared UmeData_zonedur UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv
* @alias ume shared WizForce UmeLegacyReserved Existing operand; extent and users are in symbol-references.csv

* STACK FRAME OWNERSHIP: offsets are relative to the frame base, not process addresses.
* @frame S9R BrowserFrame BrowserFrameSize
* @field S9R BrowserFrame BrowserRecOff 2
* @field S9R BrowserFrame BrowserNlinesOff 2
* @field S9R BrowserFrame BrowserNrecsOff 2
* @field S9R BrowserFrame BrowserListOff BrowserListBytes
* @field S9R BrowserFrame BrowserPagePosOff 4
* @field S9R BrowserFrame BrowserPageMoreOff 1
* @field S9R BrowserFrame BrowserPageActionOff 1
* @field S9R BrowserFrame BrowserPageNumOff 2
* @field S9R BrowserFrame BrowserPageSkipOff 2
* @field S9R BrowserFrame BrowserMouseXOff 2
* @field S9R BrowserFrame BrowserMouseYOff 2

* @frame S9R DirFrame DirFrameSize
* @field S9R DirFrame DirChanOff 2
* @field S9R DirFrame DirCountOff 2
* @field S9R DirFrame DirNameOff 30
* @field S9R DirFrame DirBuffOff 32

* @alias fran S9GUI FrArrowGlyphs FrLegacyReserved Three 24-byte appended font glyphs

* @alias fran S9GUI FrMidiPath FrLegacyReserved Appended owned byte: /mi status path plus one
* @alias fran S9GUI FrMidiShown FrLegacyReserved Appended owned byte: last drawn IRQ activity

* @alias fran S9GUI FrToolY FrLegacyReserved Appended word: saved toolbox background Y
* @alias fran S9GUI FrToolX FrLegacyReserved Appended word: toolbox left column
* @alias fran S9GUI FrToolUp FrLegacyReserved Appended byte: saved toolbox background valid
* @alias fran S9GUI FrDragSave FrLegacyReserved Appended word: dedicated eight-block full-canvas drag snapshot
* @alias fran S9GUI FrWinInv FrLegacyReserved Appended byte: the text window is a menu (inverted font, black interior)
* @alias fran S9GUI FrFontInv FrLegacyReserved The shuttle's top: the inverted font
* @alias fran S9GUI FrArrowInv FrLegacyReserved The shuttle's top: the inverted arrow glyphs
* @alias ume shared UmeData_brush UmeLegacyReserved Existing native note template, flags at offsets 1 and 2
