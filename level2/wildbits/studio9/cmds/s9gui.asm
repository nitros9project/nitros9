********************************************************************
* s9gui - Studio-9 graphics renderer for the WildBits K2/Jr2 (NitrOS-9 Level 2)
*
* Ported from Fran, the graphics back end of UltiMusE III v10.11.4e (a Microware-C program), by way of a
* disassembly of the distribution's CMDS/Fran. Routine and variable names come from Mike Knudsen's FRANS
* C source (fran.c fnote.c fstaves.c fgraf.c fcurse.c fmenus.c flay.c fterm.c fprint.c, newclib); labels
* that still read Lxxxx are code that source does not have. Menu/help strings follow fmenus.c where
* possible, keeping the distribution's control bytes and spacing.
*
* s9 runs s9gui with stdin connected to a pipe carrying a byte-coded command stream; replies go back on
* path 1. Every dot is drawn straight into VICKY's HIRES4 bitmap (640x192 of the 640x240 frame, four bits
* a dot, 320 bytes a row, y=0 the bottom row) through a sliding two-block window - see mapwin. The font is
* Chars16 (data module s9_d0, copied to data $099F). The music symbols are UmeSymbols16 data in RAM blocks
* of s9gui's own (FrSym): pointers into the original one-bit symbol image are turned into bank offsets at
* the picture primitives (SrcFix). The small one-bit pictures still built in (corners, strips, glyph
* columns) are widened to four bits as drawn (NibTab). The printer dump (/p) is assembled only with
* -DFRANPRINT and still reads pictures the one-bit way.
*
* Start-up: CStart (RelocPointers, CopyInitBlock, argument scan) -> main: signal intercept, priority $A0,
* curinit, makevdg/mapwin (bitmaps, DMA probe, double buffering) -> MainBody: palettes, pcls, font,
* imgload, then dispatch. dispatch reads one byte at a time: a non-negative byte is text for the open text
* window (vanna); $80-$D2 is looked up in the {cmd,nargs,handler} table at data $B0 (fes), its argument
* bytes are fread into <arg0.., and the handler is called.
* Primitives: hline, vpatdyn, put1/dyna1 (8-dot glyph columns), put2/dyna2 (16-dot images), bytblt,
* boxc/winbox, phrase (font text), pcls, pal, setcurse (six-byte symbol records at data $0311: extents +
* image pointer), and the text-window system (wcreate/newin/vanna/linefeed/scrollup/gohome/alcurset) with
* window backgrounds saved through the spalloc bump allocator.
* C library: the printf family, stdio, Mul16/Div16/Asr16, an sbrk heap from FrDataEnd, OS-9 call wrappers
* and the CStart runtime.
* Data size $3FFF. The module must stay at or below 31,999 bytes.

                    nam       s9gui
                    ttl       s9gui (UltiMusE III graphics server, four bits a dot)

                  IFP1
                    use       defsfile
                  ENDC

tylg                set       $11
atrv                set       $80
size                equ       $3FFF
UME_SCOPE_S9GUI                equ       1
                    use       equates.asm

* Direct-page names come from the C source; the linker lays the direct page out in link order (fran dump
* fpix fglob fnote fstaves fgraf fcurse fsys fmenus flay fterm fprint, library last): 11 initialized bytes,
* then each file's uninitialized variables (fgraf from <$54, fcurse <$78, fterm <$86, fprint <$A7); <$2E-<$3B
* are dump.a's (no source). Unused C variables hold s9gui statics: <$3C-<$3F (FrEatCR, FrWin, FrWinP), bucket
* <$6E (Fr4Src, FrBM0), base <$74 (FrUnder), bptr <$76 (FrChrome). thick (<$40) is live: bline writes >thick.



* DMA engine: TinyVKY's DMA ($FEC0) works on absolute SRAM addresses, past the MMU, and runs in the
* vertical blank with the CPU halted. s9gui knows the physical blocks of what it moves - the picture
* (FrBM0, ten contiguous blocks), the save arena (FrSave, eight) and the symbol bank (FrSym, two) - so an
* engine address is block x $2000 + offset. A transfer waits for the next blank (up to 16.7 ms), so only
* transfers of DmaMinBytes and up go this way; small ones and the modes the engine lacks (invert, OR) stay
* on the CPU. DmaProbe sets FrDma at start-up when the engine answers; MAME's model fails the probe.
* FrKeyBank (the 88-key table's RAM block) is spalloc's ceiling; $3A7D above it is the C runtime's live
* F$Icpt callback pointer and must not be reused.
* The 24 note and rest pictures of the original module ($0E55-$1155) live in the symbol bank (UmeSymbols16
* part 2, at BankPic). Their labels give the picture table VIRTUAL addresses PicVirt+offset: module-relative,
* so RelocPointers still adds the module base, and SrcFix turns them into bank offsets. PicVirt lies past
* the module's end, where no real picture pointer can be; nothing reads through it.
* FrEatCR (<$3C): the command pipe is read in line mode, so s9 follows its refresh ($CD) and poll
* (pollmark) commands with a CR; their handlers arm FrEatCR and CmdTextChar swallows that CR.

                    mod       eom,name,tylg,atrv,start,size
name                fcs       /s9gui/
                    fcb       $06
* RelocPointers: walks a fixup list (count, then 16-bit data offsets) adding the base in X (module or data area) to each pointer stored in the data area
RelocPointers       ldd       ,y++
                    beq       RelocPtrsRet
                    pshs      x
                    leax      d,y
                    leax      d,x
                    pshs      x
* RelocLoop: per-pointer loop of RelocPointers
RelocLoop           ldd       ,y++
                    leax      d,u
                    ldd       ,x
                    addd      2,s
                    std       ,x
                    cmpy      ,s
                    bne       RelocLoop
                    leas      4,s
* RelocPtrsRet: rts of RelocPointers (empty list, or the loop done)
RelocPtrsRet        rts
* CopyInitBlock: copies a length-prefixed initialised-data block from Y to U (length 0 = nothing)
CopyInitBlock       ldx       ,y++
                    beq       CopyInitRet
* CopyInitLoop: byte loop of CopyInitBlock
CopyInitLoop        lda       ,y+
                    sta       ,u+
                    leax      -1,x
                    bne       CopyInitLoop
* CopyInitRet: rts of CopyInitBlock (zero length, or the copy done)
CopyInitRet         rts
start               equ       *
                    pshs      y,u
                    clra
                    clrb
* ClearDPLoop: zeroes the 256 direct-page bytes at startup
ClearDPLoop         sta       ,u+
                    decb
                    bne       ClearDPLoop
                    ldx       2,s
                    leau      ,x
                    leax      >FrDataEnd,x
                    pshs      x
                    leay      >tblInitData,pcr
                    bsr       CopyInitBlock
                    ldu       4,s
                    leau      >FrImageOrg,u
                    bsr       CopyInitBlock
                    clra
* ClearBssLoop: zeroes the data area from the end of the init blocks up to FrDataEnd ($3AEF)
ClearBssLoop        cmpu      ,s
                    beq       RelocAndArgs
                    sta       ,u+
                    bra       ClearBssLoop
* RelocAndArgs: applies the module-relative then data-relative fixup lists, stores F$Fork's Y (top of the parameters) in <$0C and counts arguments in $0878
RelocAndArgs        ldu       4,s
                    leax      >ModuleBase,pcr
                    bsr       RelocPointers
                    leax      ,u
                    bsr       RelocPointers
                    puls      a,b,x,u
                    stx       <FrData_reserved_000C
                    sty       >$0876,u
                    leay      ,u
                    leax      ,s
                    pshs      x
                    ldd       #$0000
                    std       >$0878,u
* ArgScanLoop: loop head of the parameter-string scanner (handles quotes, spaces, CR terminator)
ArgScanLoop         lda       ,x+
                    cmpa      #$0D
                    beq       ArgScanDone
                    cmpa      #$20
                    beq       f1@
                    cmpa      #$22
                    beq       a1@
                    cmpa      #$27
                    bne       d1@
a1@                 pshs      a
* b1@: finds the closing quote and NUL-terminates the argument there (a CR ends it too)
b1@                 lda       ,x+
                    cmpa      #$0D
                    beq       c1@
                    cmpa      ,s
                    bne       b1@
                    clr       -1,x
c1@                 puls      b
d1@                 ldy       >$0878,u
                    leay      1,y
                    sty       >$0878,u
e1@                 cmpa      #$0D
                    beq       ArgScanDone
                    cmpa      #$20
                    beq       f1@
                    lda       ,x+
                    bra       e1@
f1@                 clr       -1,x
                    bra       ArgScanLoop
* ArgScanDone: terminates the last argument and builds the argv pointer array backwards on the stack
ArgScanDone         leax      -1,x
                    clr       ,x
                    puls      y
                    clr       ,-s
                    clr       ,-s
                    pshs      y
                    cmpx      ,s++
                    bls       CallMain
                    leay      ,s
                    bra       ArgvBackScan
* ArgvBuildLoop: walks the parameter string backwards pushing one pointer per argument
ArgvBuildLoop       pshs      y
                    cmpx      ,s++
                    beq       CallMain
                    lda       ,-x
                    bne       ArgvBuildLoop
                    leax      1,x
                    lda       ,x
                    cmpa      #$27
                    beq       a2@
                    cmpa      #$22
                    bne       b2@
a2@                 clr       ,x+
b2@                 pshs      x
                    leax      -1,x
* ArgvBackScan: back-scan head over an argument's bytes; entered by ArgScanDone's bra and looped from its own tail
ArgvBackScan        ldb       -1,x
                    bne       ArgvBuildLoop
                    leax      -1,x
                    bra       ArgvBackScan
* CallMain: pushes argv[0] ($0876), argv and argc ($0878+1), runs StkInitCheck, calls main, then exit(0)
CallMain            ldx       >$0876,u
                    pshs      x
                    leax      ,s
                    pshs      x
                    ldd       >$0878,u
                    addd      #$0001
                    pshs      a,b
                    leay      ,u
                    bsr       StkInitCheck
                    lbsr     main                main is beyond bsr range
                    clr       ,-s
                    clr       ,-s
                    lbsr      exit
* StkInitCheck: heap pointer <$16 = FrDataEnd ($3AEF), stack top <$1C, low-water <$18 = S-126; StackOverflow if S-126 wraps or meets the heap
StkInitCheck        leax      >FrDataEnd,y
                    stx       <FrData_reserved_0016
                    sts       <FrData_reserved_001C
                    sts       <FrData_reserved_0018
                    ldd       #$FF82
                    tfr       s,x
                    pshs      x
                    leax      d,s
                    cmpx      ,s++
                    bhi       StackOverflow
                    cmpx      <FrData_reserved_0018
                    bhs       a3@
                    cmpx      <FrData_reserved_0016
                    blo       StackOverflow
                    stx       <FrData_reserved_0018
a3@                 rts
* msgStackOverflow: '>>> Stack Overflow <<<' written to stderr by StackOverflow
msgStackOverflow    fcc       />>> Stack Overflow <<</
                    fcb       $0D
* StackOverflow: writes msgStackOverflow to path 2 with I$WritLn and exits with status $CF (SysExit)
StackOverflow       leax      <msgStackOverflow,pcr
                    ldb       #$CF
                    pshs      b
                    lda       #$02
                    ldy       #$0064
                    os9       I$WritLn
                    clr       ,-s
                    lbsr      SysExit
                    ldd       <FrData_reserved_001C
                    subd      <FrData_reserved_0018
                    rts
                    fcb       $DC,$18,$93,$16,$39
* SigHandler: the signal intercept main installs: beepa, then counts the signal in <broke
SigHandler          pshs      u
                    lbsr      beepa
                    ldb       <broke
                    addd      #$0001
                    stb       <broke
                    puls      u,pc
* makevdg: D = the screen address <vdgram, calling mapwin the first time
makevdg        pshs      u
                    ldd       <vdgram
                    bne       a4@
                    lbsr      mapwin
* mapwin has set up both screens (bitmap 0 DMA-cleared, bitmap 1 made and DMA-copied: BottomInit, DblBufInit).
* One byte on path 1, the reply pipe, says so: s9 waits for it before it paints the 88 piano keys, which the
* clear and copy would otherwise wipe.
                    pshs      a,x,y               Y is the C static base
                    lda       #1
                    leax      ,s                  any byte: the saved A
                    ldy       #1
                    os9       I$Write
                    puls      a,x,y
                    ldd       <vdgram
                    puls      u,pc
a4@                 puls      u,pc
* main: spinit, intercept(SigHandler), setpr(getpid(),$A0), stdin flag $40, curinit, makevdg; prints 'Nscr' and exit($25) when no screen, else MainBody
main            pshs      u
                    leas      <-$53,s
                    lbsr      spinit
                    leax      >SigHandler,pcr
                    pshs      x
                    lbsr      intercept
                    leas      2,s
                    clra
                    clrb
                    stb       <broke
                    ldd       #$00A0
                    pshs      a,b
                    lbsr      getpid
                    pshs      a,b
                    lbsr      setpr
                    leas      4,s
                    ldd       >FrData_reserved_072C
                    orb       #$40
                    std       >FrData_reserved_072C
                    lbsr      curinit
                    bsr       makevdg
                    std       -2,s
                    bne       ScreenMapped
                    leax      >msgNoGfxScreen,pcr
                    pshs      x
                    lbsr      printf
                    leas      2,s
                    ldd       #$0025
                    pshs      a,b
                    lbsr      exit
                    bra       MainBody
* ScreenMapped: the original printed 'Screen at $%04x' and slept a second here.
ScreenMapped
* Nothing to clear or wait for: MainBody's pcls paints the whole picture, and the F$MapBlk map is live at once
* (the kernel reloads the LUT on every return).
* MainBody: tool x 16, grafix, pal(1,0) and pal(0,$3F), pcls to paper, load the font, clear the drag/menu state,
* setcurse(1), imgload, then the dispatch loop; at EOF release and exit(0). No stipple or splash: s9 sends its greeting.
MainBody            ldd       #16
                    std       >FrToolX
                    lbsr      grafix
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    lbsr      pal
                    leas      4,s
                    ldd       #$003F
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    lbsr      pal
                    leas      4,s
                    lda       #COLORS_PAPER        paper / transparent palette index
                    clrb
                    pshs      a,b
                    lbsr      pcls
                    leas      2,s
                    lbsr      LoadFontData
                    clr       >FrDragKind         the drag glyph is off (the record bytes are not zero in the image)
                    clr       >FrDynaInk
                    clr       >FrDragUp
                    clr       >FrMenu
                    ldd       #$0001
                    pshs      a,b
                    lbsr      setcurse
                    leas      2,s
                    lbsr      imgload
                    lbsr      dispatch
                    lbsr      release
                    clra
                    clrb
                    pshs      a,b
                    lbsr      exit
                    leas      2,s
                    leas      <$53,s
                    puls      u,pc
pala               pshs      u
                    ldb       <arg1
                    sex
                    pshs      a,b
                    ldb       <arg0
                    sex
                    pshs      a,b
                    lbsr      pal
                    lbra      slaya_1
defsa               pshs      u
                    ldb       <arg2
                    clra
                    pshs      a,b
                    ldb       <arg1
                    sex
                    pshs      a,b
                    ldb       <arg0
                    tfr       b,a
                    anda      #$80                bit 7 of the staff number: the sheet's gray staff lines option (s9l)
                    sta       >FrStaffDots
                    andb      #$7F
                    clra
                    pshs      a,b
                    lbsr      dfstaff
                    lbra      dbcda_1
udfsa               pshs      u
                    ldb       <arg0
                    sex
                    pshs      a,b
                    lbsr      fgstaff
                    lbra      scura_1
defpa               pshs      u
                    ldb       <arg5
                    clra
                    andb      #$03
                    pshs      a,b
                    ldb       <arg4
                    sex
                    pshs      a,b
                    ldb       <arg3
                    sex
                    pshs      a,b
                    ldb       <arg2
                    clra
                    pshs      a,b
                    ldb       <arg1
                    sex
                    pshs      a,b
                    ldb       <arg0
                    sex
                    pshs      a,b
                    lbsr      dfpart
                    leas      12,s
                    puls      u,pc
udfpa               pshs      u
                    ldb       <arg0
                    sex
                    pshs      a,b
                    lbsr      fgpart
                    lbra      scura_1
sksa               pshs      u
                    ldb       <arg0
                    sex
                    std       <keysig
                    puls      u,pc
stsa               pshs      u
                    ldb       <arg0
                    sex
                    std       <numer
                    ldb       <arg1
                    clra
                    andb      #$1F
                    std       <denom
                    puls      u,pc
claa               pshs      u
                    ldb       <arg0
                    sex
                    pshs      a,b
                    lbsr      pcls
                    lbra      scura_1
cssa               pshs      u
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$00B8
                    pshs      a,b
                    ldd       #$0008
                    pshs      a,b
                    lbsr      yclear
                    lbra      dbcda_1
drepa               pshs      u
                    ldb       <arg0
                    sex
                    std       <brushx
                    ldb       <arg1
                    clra
                    std       <brushy
                    ldb       <arg2
                    clra
                    pshs      a,b
                    ldx       #brush
                    pshs      x
                    lbsr      drbrush
                    lbra      slaya_1
dfrna               pshs      u
                    ldb       <arg0
                    stb       >FrData_reserved_0212
                    ldb       <arg1
                    stb       >brush
                    ldb       <arg2
                    stb       >FrData_reserved_0211
                    ldb       <arg3
                    stb       >FrData_reserved_0214
                    puls      u,pc
scrla               pshs      u
                    ldd       <arg4
                    pshs      a,b
                    ldd       <arg2
                    pshs      a,b
                    ldd       <arg0
                    pshs      a,b
                    lbsr      scroll
                    lbra      dbcda_1
scrma               pshs      a,b,u
                    ldb       <arg1
                    clra
                    std       ,s
                    addd      #$0002
                    pshs      a,b
                    ldd       2,s
                    pshs      a,b
                    ldd       #$0101
                    pshs      a,b
                    lbsr      scroll
                    leas      6,s
                    bra       scura_1
rftba               pshs      u
                    tst       <arg1
                    lbmi      ToolDrag
                    ldb       <arg0
                    clra
                    cmpd      <tooly
                    beq       tbpos@
                    lbsr      ToolHide
tbpos@              equ       *
                    ldb       <arg0
                    clra
                    std       <tooly
                    lbsr      ToolSave
                    ldb       <arg2
                    sex
                    pshs      a,b
                    ldb       <arg1
                    sex
                    pshs      a,b
                    lbsr      drtools
                    lbra      slaya_1
scura               pshs      u
                    ldb       <arg0
                    sex
                    pshs      a,b
                    lbsr      setcurse
scura_1               leas      2,s
                    puls      u,pc
* dcura - $9B x(word) y: the drag glyph at the pointer, only while $C2 has armed one (FrDragKind 1 = clef, 2 = part-type
* icon; FrDragIdx the index). getnbak saves the whole canvas; dcuhide puts it back before each move and on $C2 0.
* The glyph's 16 dots center on x (byte columns, clamped to 0..77) and its bottom row sits on y (rows from the bottom),
* clamped so the whole glyph stays below row 191: a note drops on the staff line under the pointer.
dcura               ldb       >FrDragKind
                    lbeq      dcu9@
                    pshs      u
                    lda       <arg0
                    ldb       <arg1
                    subd      #$0008              the glyph's middle on the pointer
                    bpl       dcu0@
                    clra
                    clrb
dcu0@               lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb                          x / 8
                    cmpb      #77
                    bls       dcu1@
                    ldb       #77
dcu1@               pshs      b                   the column (the statics still describe the OLD spot until it is hidden)
                    lbsr      dcurows             B = rows - 1
                    pshs      b                   ,s the height  1,s the column
                    ldb       <arg2               the pointer's y = the bottom row
                    clra
                    addb      ,s                  STACK OFFSET 0: glyph rows minus one
                    adca      #0                  retain overflow from pointer + height
                    cmpd      #191
                    bls      dcufit@
                    ldb       #191
dcufit@            subb      ,s                  full glyph fits below the top canvas edge
dcu2@               pshs      b                   ,s the bottom row  1,s the height  2,s the column
                    addb      1,s                 + the height = the top row
                    bcc       dcu2a@
                    ldb       #191
dcu2a@              cmpb      #191
                    bls       dcu2b@
                    ldb       #191                too high: the glyph stays inside the canvas
dcu2b@              pshs      b                   ,s the top  1,s the bottom  2,s the height  3,s the column
                    ldb       >FrDragUp
                    beq       dcu2c@              not on the screen yet
                    ldb       ,s
                    cmpb      >FrDragY
                    bne       dcu2c@
                    ldb       3,s
                    cmpb      >FrDragCol
                    bne       dcu2c@
                    leas      4,s                 the same place: nothing to do (no flicker)
                    puls      u
                    rts
dcu2c@              lbsr      dcuhide             the old spot back (the background restored from the old statics)
                    puls      b
                    stb       >FrDragY            the top row
                    puls      b
                    stb       >FrDragY1           the bottom row
                    puls      b                   the height, done with
                    puls      b
                    stb       >FrDragCol          the column
                    lbsr      getnbak             save all 640 x 192 pixels, including the menu
                    ldb       >FrDragKind
                    cmpb      #1
                    bne       dcu5@
                    ldb       >FrDragIdx
                    lda       #$36
                    mul
                    addd      #$0EC9
                    tfr       d,x
                    pshs      x                   the clef image
                    bra       dcu6@
dcu5@               ldb       >FrDragIdx
                    lda       #32
                    mul
                    leax      >PicPartIcon,pcr
                    leax      d,x
                    pshs      x                   the part-type icon (symbol bank)
dcu6@               lbsr      dcurows
                    incb
                    clra
                    pshs      a,b                 the rows
                    ldb       >FrDragY
                    clra
                    pshs      a,b
                    ldb       >FrDragCol
                    clra
                    pshs      a,b
                    ldb       #1                inked
                    stb       >FrDynaInk          ink the glyph's dots like the notes (dyna2 with Or8)
                    lbsr      dyna2               dyna2(col, y, rows, image)
                    clr       >FrDynaInk
                    leas      8,s
dcu8@               ldb       #1
                    stb       >FrDragUp
                    puls      u
dcu9@               rts
* dcurows: B = the glyph's rows - 1 (26 a clef, 15 a part-type icon); A = FrDragKind
dcurows             ldb       #26
                    lda       >FrDragKind
                    cmpa      #1
                    beq       dcur1@
                    ldb       #15
dcur1@              rts
* dcuhide: the background back under the glyph if it is on the screen
dcuhide             ldb       >FrDragUp
                    beq       dcuh9@
                    clr       >FrDragUp
                    lbsr      putnbak             restore the complete canvas before moving
dcuh9@              rts
* dragset - $C2 kind index 0: arm the drag glyph (kind 1 clef / 2 part-type icon, at the index), or kind 0 = hide and disarm
dragset             pshs      u
                    ldb       <arg0
                    bne       drs1@
                    lbsr      dcuhide
                    clr       >FrDragKind
                    puls      u,pc
drs1@               stb       >FrDragKind
                    ldb       <arg1
                    cmpa      #$02                meant to clamp kind 2 to 0..3, but A is $FF here (dispatch's sex of $C2),
                    bne       drs2@               so every index is clamped to 0..6
                    cmpb      #$03
                    bls       drs3@
                    ldb       #$03
                    bra       drs3@
drs2@               cmpb      #$06
                    bls       drs3@
                    ldb       #$06
drs3@               stb       >FrDragIdx
                    clr       >FrDragUp
                    puls      u,pc
drsha               pshs      u
                    ldb       <arg1
                    sex
                    pshs      a,b
                    ldb       <arg0
                    sex
                    pshs      a,b
                    lbsr      storf
                    lbra      slaya_1
drsa               pshs      u
                    ldb       <arg0
                    clra
                    std       <lastaffy
                    ldb       <arg2
                    sex
                    std       <lastclef
                    ldb       <arg3
                    sex
                    pshs      a,b
                    ldb       <arg1
                    sex
                    pshs      a,b
                    ldd       <lastaffy
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    lbsr      staff
                    leas      8,s
                    ldd       #$0001
                    bra       ersa_1
ersa               pshs      u
                    clra
                    clrb
                    pshs      a,b
                    ldd       <lastaffy
                    addd      #$0010
                    pshs      a,b
                    ldd       <lastaffy
                    pshs      a,b
                    lbsr      yclear
                    leas      6,s
                    clra
                    clrb
ersa_1               pshs      a,b
                    ldd       <lastclef
                    pshs      a,b
                    ldd       #$0036
                    lbsr      Mul16
                    ldx       #$0EC9
                    leax      d,x
                    pshs      x
                    ldd       #$001B
                    pshs      a,b
                    ldd       <lastaffy
                    addd      #$0014
                    pshs      a,b
                    ldd       #$0002
                    pshs      a,b
                    lbsr      put2
                    lbra      clra_2
dralstcl               pshs      a,b,x,y,u
                    lbsr      ToolHide            restore before repainting the score
                    ldd       <nstaves
                    std       4,s
                    bra      dralstcl_4
dralstcl_1               leax      ,s
                    pshs      x
                    leax      4,s
                    pshs      x
                    ldd       8,s
                    pshs      a,b
                    lbsr      getstaff
                    leas      6,s
                    ldb       <arg2
                    sex
                    pshs      a,b
                    ldb       <arg0
                    sex
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    ldb       <arg1
                    beq       dralstcl_2
                    ldd       #$0001
                    bra       dralstcl_3
dralstcl_2               clra
                    clrb
dralstcl_3               pshs      a,b
                    lbsr      staff
                    leas      8,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       2,s
                    pshs      a,b
                    ldd       #$001B
                    pshs      a,b
                    ldd       8,s
                    addd      #$0014
                    pshs      a,b
                    ldb       <arg1
                    sex
                    pshs      a,b
                    ldb       <arg0
                    sex
                    addd      ,s++
                    pshs      a,b
                    lbsr      put2
                    leas      10,s
dralstcl_4               ldd       4,s
                    addd      #$FFFF
                    std       4,s
                    bge      dralstcl_1
                    lbra      dbcda_1
dcrsa               pshs      u
                    ldb       <arg3
                    sex
                    pshs      a,b
                    ldb       <arg2
                    sex
                    pshs      a,b
                    ldb       <arg1
                    sex
                    pshs      a,b
                    ldb       <arg0
                    sex
                    pshs      a,b
                    lbsr      drawcres
                    leas      8,s
                    puls      u,pc
drsys               pshs      u
                    leas      -10,s
                    ldd       #$00BF
                    std       2,s
                    clra
                    clrb
                    std       4,s
                    ldd       <nstaves
                    std       8,s
                    bra       drsys_3
drsys_1               leax      ,s
                    pshs      x
                    leax      8,s
                    pshs      x
                    ldd       12,s
                    pshs      a,b
                    lbsr      getstaff
                    leas      6,s
                    ldd       6,s
                    cmpd      4,s
                    ble       drsys_2
                    ldd       6,s
                    std       4,s
drsys_2               ldd       6,s
                    cmpd      2,s
                    bge       drsys_3
                    ldd       6,s
                    std       2,s
drsys_3               ldd       8,s
                    addd      #$FFFF
                    std       8,s
                    bge       drsys_1
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$00BF
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    lbsr      vpatdyn
                    leas      8,s
                    leax      >L0AB8,pcr
                    pshs      x
                    ldd       #$0004
                    pshs      a,b
                    ldd       8,s
                    addd      #$0012
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    lbsr      dyna1
                    leas      8,s
                    leax      >L0ABD,pcr
                    pshs      x
                    ldd       #$0004
                    pshs      a,b
                    ldd       6,s
                    addd      #$0001
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    lbsr      dyna1
                    leas      8,s
                    ldd       #$00E0
                    pshs      a,b
                    ldd       6,s
                    addd      #$000E
                    pshs      a,b
                    ldd       6,s
                    addd      #$0002
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    lbsr      vpatdyn
                    leas      8,s
                    lbra      clra_2
daksa               pshs      u
                    ldb       <arg1
                    sex
                    pshs      a,b
                    ldb       <arg0
                    sex
                    pshs      a,b
                    lbsr      drawks
                    lbra      slaya_1
datsa               pshs      u
                    ldb       <arg2
                    sex
                    pshs      a,b
                    ldb       <arg1
                    sex
                    pshs      a,b
                    ldb       <arg0
                    sex
                    pshs      a,b
                    lbsr      drawts
                    lbra      dbcda_1
dxlva               pshs      u
                    ldb       <arg2
                    sex
                    pshs      a,b
                    ldb       <arg1
                    clra
                    pshs      a,b
                    ldb       <arg0
                    sex
                    pshs      a,b
                    lbsr      drlevel
                    lbra      dbcda_1
dinsa               pshs      u
                    ldb       <arg2
                    sex
                    pshs      a,b
                    ldb       <arg1
                    clra
                    pshs      a,b
                    ldb       <arg0
                    sex
                    pshs      a,b
                    lbsr      drinstr
                    lbra      dbcda_1
dmcha               pshs      u
                    ldb       <arg2
                    sex
                    pshs      a,b
                    ldb       <arg1
                    clra
                    pshs      a,b
                    ldb       <arg0
                    sex
                    pshs      a,b
                    lbsr      drmchop
                    lbra      dbcda_1
dpeva               pshs      u
                    ldb       <arg2
                    sex
                    pshs      a,b
                    ldb       <arg1
                    clra
                    pshs      a,b
                    ldb       <arg0
                    sex
                    pshs      a,b
                    lbsr      drprtevt
                    lbra      dbcda_1
dglia               pshs      a,b,u
                    ldb       <arg0
                    sex
                    std       ,s
                    ldb       <arg2
                    clra
                    stb       <arg2
                    ldb       <arg1
                    cmpb      #$19
                    bne       dglia_1
                    ldb       <arg2
                    sex
                    pshs      a,b
                    ldd       2,s
                    pshs      a,b
                    lbsr      drawtmp
                    bra      dglia_6
dglia_1               ldb       <arg1
                    cmpb      #$1A
                    bne       dglia_2
                    ldb       <arg2
                    sex
                    pshs      a,b
                    ldd       2,s
                    pshs      a,b
                    lbsr      drawgenv
                    bra       dglia_6
dglia_2               ldb       <arg1
                    cmpb      #$1B
                    bne       dglia_3
                    ldb       <arg2
                    sex
                    pshs      a,b
                    ldd       2,s
                    pshs      a,b
                    lbsr      drawclk
                    bra       dglia_6
dglia_3               ldb       <arg1
                    cmpb      #$1F
                    beq       dglia_4
                    ldb       <arg1
                    cmpb      #$21
                    bne       dglia_5
dglia_4               ldb       <arg2
                    sex
                    pshs      a,b
                    ldd       2,s
                    pshs      a,b
                    lbsr      drsysevt
                    bra       dglia_6
dglia_5               ldb       <arg1
                    cmpb      #$22
                    lbne      dumpa_1
                    ldb       <arg2
                    sex
                    pshs      a,b
                    ldd       2,s
                    pshs      a,b
                    lbsr      drawaccent
dglia_6               leas      4,s
                    lbra      dumpa_1
dlaba               pshs      u
                    ldb       <arg2
                    sex
                    pshs      a,b
                    ldb       <arg1
                    sex
                    pshs      a,b
                    ldb       <arg0
                    sex
                    pshs      a,b
                    lbsr      drawlab
                    lbra      dbcda_1
diasa               pshs      u
                    ldd       <arg2
                    pshs      a,b
                    ldb       <arg1
                    clra
                    andb      #$1F
                    pshs      a,b
                    ldb       <arg0
                    sex
                    pshs      a,b
                    lbsr      putalst
                    lbra      dbcda_1
arta               pshs      u
                    ldb       <arg4
                    sex
                    pshs      a,b
                    ldb       <arg3
                    sex
                    pshs      a,b
                    ldb       <arg2
                    clra
                    pshs      a,b
                    ldb       <arg1
                    sex
                    pshs      a,b
                    ldb       <arg0
                    sex
                    pshs      a,b
                    lbsr      drawart
                    lbra      clra_2
slaya               pshs      u
                    ldb       <arg1
                    sex
                    pshs      a,b
                    ldb       <arg0
                    sex
                    pshs      a,b
                    lbsr      showglay
slaya_1               leas      4,s
                    puls      u,pc
* Drag background is the entire 640 x 192 score canvas (61,440 bytes).
* Dedicated blocks keep this snapshot independent of menu/toolbox/window saves.
getnbak             clra
                    clrb
                    bra       DragCanvasCopy
putnbak             ldd       #1
DragCanvasCopy      pshs      d,x,y,u              STACK OFFSET 0: mode; 2: X; 4: Y; 6: U
                    ldx       >FrDragSave
                    beq      dragcopydone@
                    ldd       >FrSave
                    pshs      d                   STACK OFFSET 0: original rectangle-arena block
                    stx       >FrSave             bytblt uses the dedicated drag arena temporarily
                    ldx       #$087A              virtual token for arena offset zero
                    pshs      x
                    ldd       #191                y2: top of the complete canvas
                    pshs      d
                    ldd       #79                 x2: last eight-pixel column
                    pshs      d
                    clra
                    clrb
                    pshs      d                   y1: bottom
                    pshs      d                   x1: left
                    ldd       12,s                STACK OFFSET 12: original mode, before six arguments
                    pshs      d
                    lbsr      bytblt              DMA copy, CPU fallback
                    leas      12,s                six word arguments removed
                    lbsr      SymUnmap            invalidate temporary arena mapping before restoring owner
                    puls      d
                    std       >FrSave
dragcopydone@      puls      d,x,y,u,pc

gaboa               pshs      u
                    ldb       <arg0
                    beq       gaboa_1
                    lbsr      gtext
                    leax      >L0AC2,pcr
                    pshs      x
                    lbsr      pat
                    leas      2,s
                    bra       gaboa_2
gaboa_1               lbsr      wkill
                    clra
                    clrb
                    stb       <tgwmode
gaboa_2               puls      u,pc
hlina               pshs      u
                    ldb       <arg5
                    clra
                    pshs      a,b
                    ldb       <arg4
                    clra
                    pshs      a,b
                    ldd       <arg2
                    pshs      a,b
                    ldd       <arg0
                    pshs      a,b
                    lbsr      hline
                    bra      boxa_1
vlina               pshs      u
                    ldb       <arg4
                    clra
                    pshs      a,b
                    ldb       <arg3
                    clra
                    pshs      a,b
                    ldb       <arg2
                    clra
                    pshs      a,b
                    ldd       <arg0
                    pshs      a,b
                    lbsr      vline
                    bra      boxa_1
blinea               pshs      u
                    ldb       <arg6
                    sex
                    pshs      a,b
                    ldb       <arg5
                    clra
                    pshs      a,b
                    ldd       <arg3
                    pshs      a,b
                    ldb       <arg2
                    clra
                    pshs      a,b
                    ldd       <arg0
                    pshs      a,b
                    lbsr      bline
                    lbra     clra_2
bagnla               pshs      u
                    ldb       <arg0
                    sex
                    pshs      a,b
                    lbsr      bagnline
                    lbra      dumpa_1
L07C5               equ       *
                    pshs      u
                    ldd       <arg3
                    pshs      a,b
                    ldd       <arg1
                    pshs      a,b
                    ldb       <arg0
                    sex
                    pshs      a,b
                    lbsr      bsegline
                    lbra      dbcda_1
boxa               pshs      u
                    ldb       <arg3
                    clra
                    pshs      a,b
                    ldb       <arg2
                    sex
                    pshs      a,b
                    ldb       <arg1
                    clra
                    pshs      a,b
                    ldb       <arg0
                    sex
                    pshs      a,b
                    lbsr      boxc
boxa_1               leas      8,s
                    puls      u,pc
nboxa               pshs      u
                    ldb       <arg3
                    clra
                    pshs      a,b
                    ldb       <arg2
                    sex
                    pshs      a,b
                    ldb       <arg1
                    clra
                    pshs      a,b
                    ldb       <arg0
                    sex
                    pshs      a,b
                    ldd       #$0003              mode 3: invert
                    pshs      a,b
                    inc       >FrNoDirty          the inversion adds nothing to the batch's dirty set
                    lbsr      SwapBase
                    lbsr      bytblt              the shown page first (live)
                    lbsr      SwapBase
                    lbsr      bytblt              and the hidden one, so both pages stay identical and the
                    clr       >FrNoDirty          un-invert cancels whichever page a flip in between shows
                    bra       clra_2
* nboxh: menu-bar hover rectangle, shifted right by half an eight-dot text column. Unlike bytblt,
* this works in packed-pixel bytes so the four-dot displacement is exact. It follows nboxa's live
* two-page rule and does not add the transient hover to the next batch's dirty set.
nboxh               pshs      u
                    inc       >FrNoDirty
                    lbsr      SwapBase            visible page first
                    bsr       HalfInvert
                    lbsr      SwapBase
                    bsr       HalfInvert          hidden page kept identical
                    clr       >FrNoDirty
                    puls      u,pc
HalfInvert          pshs      d,x,u
                    clra
                    ldb       <arg0               left eight-dot column
                    tfr       d,x
                    clra
                    ldb       <arg3               top row
                    lbsr      ScrPos
                    leau      2,u                 four packed dots = half a column
                    lda       <arg3
                    suba      <arg1
                    inca                          row count
                    ldb       <arg2
                    subb      <arg0
                    incb
                    lslb
                    lslb                          bytes per row
                    pshs      d                   ,s rows  1,s bytes
hivrow@             clra
                    ldb       1,s
                    tfr       d,x
hivbyte@            com       ,u+
                    leax      -1,x
                    bne       hivbyte@
                    clra
                    ldb       1,s
                    nega
                    negb
                    sbca      #0
                    leau      d,u                 back to the shifted row start
                    lbsr      ScrRowDn
                    dec       ,s
                    bne       hivrow@
                    leas      2,s
                    puls      d,x,u,pc
clra               pshs      u
                    ldb       <arg3
                    clra
                    pshs      a,b
                    ldb       <arg2
                    sex
                    pshs      a,b
                    ldb       <arg1
                    clra
                    pshs      a,b
                    ldb       <arg0
                    sex
                    pshs      a,b
                    ldd       #$0002
clra_1               pshs      a,b
                    lbsr      bytblt
clra_2               leas      10,s
                    puls      u,pc
acura               pshs      u
                    ldb       <arg0
                    sex
                    pshs      a,b
                    lbsr      alcurset
                    lbra      dumpa_1
phrsa               pshs      u
                    leas      <-$51,s
                    leax      ,s
                    pshs      x
                    lbsr      gets
                    leas      2,s
                    ldb       <arg2
                    sex
                    pshs      a,b
                    leax      2,s
                    pshs      x
                    ldb       <arg1
                    clra
                    pshs      a,b
                    ldb       <arg0
                    sex
                    pshs      a,b
                    lbsr      phrase
                    leas      8,s
                    leas      <$51,s
                    puls      u,pc
dbcda               pshs      u
                    ldb       <arg1
                    clra
                    pshs      a,b
                    ldb       <arg0
                    sex
                    pshs      a,b
                    ldb       <arg2
                    clra
                    pshs      a,b
                    lbsr      drawbcd
dbcda_1               leas      6,s
                    puls      u,pc
menua               pshs      u
                    ldb       <arg0
                    sex
                    pshs      a,b
                    lbsr      upmenu
                    bra       dumpa_1
owsta               pshs      u
                    ldb       <arg5
                    sex
                    pshs      a,b
                    ldb       <arg4
                    sex
                    pshs      a,b
                    ldb       <arg3
                    sex
                    pshs      a,b
                    ldb       <arg2
                    sex
                    pshs      a,b
                    ldb       <arg1
                    clra
                    pshs      a,b
                    ldb       <arg0
                    sex
                    pshs      a,b
                    lbsr      wcreate
owsta_1               leas      12,s
                    bra       dumpa_2
dumpa               pshs      u
                    ldb       <arg0
                    clra
                    andb      #$0F
                    stb       <printype
                    ldd       #$00C0
                    pshs      a,b
                    lbsr      ndump
dumpa_1               leas      2,s
dumpa_2               puls      u,pc
* ctxma - command $B9 col y rows width: a context menu box, its rows streamed by s9 and its overlays.
* The command table lies in the initialized-data image, whose addresses are numeric: an entry can be repurposed,
* never inserted.
* The rows follow the packet, one CR-terminated line each: the key letter, then the label (a label
* starting with a box glyph $60/$7F is a toggle row). At most 32 rows; they are written straight into
* a saved text window that wkill ($C7) puts back.
ctxma               pshs      u
                    leas      -(CTXMAX+4),s       the key letter of each row, then col, y, rows, width
                    lda       <arg0
                    sta       CTXMAX,s            the <argN slots are scratch for wcreate/vanna/bytblt: keep copies
                    lda       <arg1               y as sent: a bar menu's descriptor gives MenuDropY, a sub-menu its own
                    sta       CTXMAX+1,s
                    lda       <arg2
                    sta       CTXMAX+2,s
                    lda       <arg3
                    sta       CTXMAX+3,s
                    ldb       <arg2               rows
                    lbeq      ctx9@
                    cmpb      #CTXMAX
                    bls       ctx0@
                    ldb       #CTXMAX
ctx0@               pshs      b                   the count, kept
                    pshs      b                   the count, counted down while the rows are read
* The rows come from the pipe as key letter + label + CR and are written straight into the text window (7-dot
* lines); then the loop below reads mouse packets (x word, canvas row, code) from the same pipe, keeps the row
* under the pointer inverted (bytblt mode 3) and answers ONE byte per packet on path 1, the reply pipe: 0 for a
* move (code 0), the key letter of the row clicked (code 1) or the key typed; CR for a click off the box, a title
* row, code 2 or EOF. The caller's $C7 takes the window down.
                    ldb       >FrMenu
                    bitb      #$01
                    beq       ctxnew@
                    ldb       #$04
                    stb       >FrMenu             quiet: only the box glyphs are repainted, no clear
                    lbsr      gohome              the menu is still up (a toggle): reprint over it
                    bra       ctxrows@
ctxnew@             ldb       ,s
                    clra                          the window is exactly as tall as its rows
                    pshs      a,b                 ,s the window height  2,s the count
                    ldd       #WinMenu
                    pshs      a,b                 style: a menu (black interior, inverted text, style 1 frame)
                    ldd       #$0001
                    pshs      a,b                 save the background
                    ldd       4,s
                    pshs      a,b                 height
                    ldb       <arg3
                    clra
                    addd      #$0002
                    pshs      a,b                 width + 2
                    ldb       <arg1
                    clra
                    pshs      a,b                 y
                    ldb       <arg0
                    clra
                    subd      #$0001
                    pshs      a,b                 col - 1
                    lbsr      wcreate
                    leas      14,s                the six arguments and the height
                    ldd       #$000C
                    pshs      a,b
                    lbsr      MenuClear           FF: clear the menu with its own background
                    leas      2,s
ctxrows@            leax      2,s                 the keys
                    pshs      x                   ,s cursor  2,s countdown  3,s count  4,s keys
ctx5@               ldb       <arg3
                    incb
                    stb       >FrCtxLeft          width+1 characters fit the row (box included); the rest of a label is dropped
                    lbsr      ctxg@               the row's key letter
                    ldx       ,s
                    stb       ,x+
                    stx       ,s
                    lbsr      ctxg@               the label's first character: a box glyph = a toggle row
                    cmpb      #MenuDim
                    bne       ctxlv@
                    lda       #MenuDimInk         a disabled row: its text in MenuDimInk, its box no toggle
                    sta       >FrTxtInk
                    lbsr      ctxg@
                    bra       ctx6a@
ctxlv@              cmpb      #GlyphBoxOff
                    beq       ctxbx@
                    cmpb      #GlyphBoxOn                the checked box (Chars16 $7F)
                    bne       ctx6a@
ctxbx@              ldx       ,s                  the keys cursor (ctxg@ clobbered X)
                    lda       -1,x
                    ora       #$80                bit 7 on the key: a toggle row
                    sta       -1,x
                    dec       >FrCtxLeft          the box takes a column
                    clra
                    pshs      a,b
                    lbsr      vanna               the box glyph: always painted (it may have flipped)
                    leas      2,s
                    bra       ctx6@
ctx6@               lbsr      ctxg@
ctx6a@              cmpb      #C$CR
                    beq       ctx7@
                    lda       >FrMenu
                    bita      #$04
                    bne       ctx6@               quiet reprint: the text is on the screen already
                    tst       >FrCtxLeft
                    beq       ctx6@               past the row's width: dropped (it would wrap and scroll the menu)
                    dec       >FrCtxLeft
                    clra
                    pshs      a,b
                    lbsr      vanna               a character of the label
                    leas      2,s
                    bra       ctx6@
ctx7@               clr       >FrTxtInk           the row's end: the text color back
                    dec       2,s
                    beq       ctx8@               the last row: no CR (it would scroll the window, which is exactly as tall as its rows)
                    ldd       #$000D
                    pshs      a,b
                    lbsr      vanna               CR: the next text line
                    leas      2,s
                    bra       ctx5@
ctx8@               clr       >FrTxtInk
                    leas      3,s                 ,s the count  1,s the keys
                    ldb       #$01
                    stb       >FrMenu             up, not sticky
                    ldb       #$FF
                    pshs      b                   ,s the row inverted (FF = none)
                    leas      -4,s                ,s the packet: x hi, x lo, row, code   4,s inverted  5,s count  6,s keys
* The packets are read RAW on path 0: the stdin FILE is in line mode (pipeman ReadLn hands bytes over
* only at a CR), and a packet has no CR. The stdio buffer is empty here: the rows ended with a CR.
* Y is the C data base (the library reads the stdin FILE at FrStdin,y); I$Read returns the count in Y, so Y is saved.
                    lbsr      Present             the menu is drawn: flip before the pointer loop
ctxl@               pshs      y
* The packet is gathered one byte at a time (a pipe read can come back short). s9's input polls put the flip
* signal into this pipe between packets: $CA, then two CRs. A packet's first byte is x hi, 0..2, so a $CA or a CR
* in that slot is not a packet: the slot is read again until a real first byte arrives.
ctxlr@              leax      2,s                 the packet, under the saved Y
                    ldb       #4                  bytes still wanted
ctxlb@              pshs      b,x
                    clra                          path 0
                    ldy       #$0001
                    os9       I$Read              one byte
                    puls      b,x                 CC untouched
                    bcs       ctxl8@              EOF: as a click off
                    cmpb      #4                  the packet's first byte?
                    bne       ctxln@
                    lda       ,x
                    cmpa      #$CA                the flip signal ...
                    beq       ctxlb@              ... skipped: read the slot again
                    cmpa      #C$CR               ... or one of its CRs
                    beq       ctxlb@
ctxln@              leax      1,x
                    decb
                    bne       ctxlb@
                    clra                          Z set, carry clear: a whole packet
ctxl8@              puls      y                   CC untouched: carry = EOF, Z clear = short
                    bcs       ctxcr@
                    bne       ctxcr@
                    ldb       3,s                 the code
                    beq       ctxm@
                    cmpb      #$01
                    beq       ctxc@
                    cmpb      #$02
                    beq       ctxcr@
                    leax      6,s                 a key typed: a toggle row's key makes the menu sticky
                    lda       5,s
ctxk1@              ldb       ,x+
                    andb      #$7F
                    cmpb      3,s
                    bne       ctxk2@
                    ldb       -1,x
                    bpl       ctxk3@
                    bsr       ctxst@
                    bra       ctxk3@
ctxk2@              deca
                    bne       ctxk1@
ctxk3@              ldb       3,s
                    bra       ctxr@               it goes back as it is
ctxc@               bsr       ctxrow@
                    bmi       ctxcr@              nothing under the press
                    leax      6,s
                    abx
                    ldb       ,x                  its key letter
                    cmpb      #C$SPAC
                    bls       ctxcr@              a title row (or a disabled one): the menu closes
                    bpl       ctxpk@              a plain pick
                    andb      #$7F                a toggle row: the answer, and the window stays
                    bsr       ctxst@
                    bra       ctxr@
ctxst@              lda       #$03
                    sta       >FrMenu
                    rts
ctxcr@              ldb       #C$CR
* A pick or a close ends the menu: FrMenu clear, so a sub-menu packet sent while this window is still up opens
* its own window instead of reprinting into this one
ctxpk@              clr       >FrMenu
ctxr@               stb       ,s
                    ldb       4,s
                    bsr       ctxinv@             the inverted row back
                    bsr       ctxw@               the answer
                    leas      6,s                 the packet, the inverted row and the count
                    lbra      ctx9@
* ctxw@: the packet's first byte goes to path 1 = stdout = the reply pipe (lock-step: one byte per packet)
ctxw@               ldd       #$0001
                    pshs      a,b
                    leax      4,s
                    pshs      x
                    ldd       #$0001
                    pshs      a,b
                    lbsr      write
                    leas      6,s
                    rts
ctxm@               bsr       ctxrow@
                    cmpb      4,s
                    beq       ctxz@               the same row (or none) as before
                    stb       3,s                 the new row, parked in the code byte (the stack must not move: ctxinv@ offsets)
                    ldb       4,s
                    bsr       ctxinv@             the old one back
                    ldb       3,s
                    stb       4,s
                    bsr       ctxinv@             the new one lit
ctxz@               clr       ,s
                    bsr       ctxw@               nothing yet: a zero answers the move
                    lbra      ctxl@
* ctxg@: B = the next pipe byte; EOF reads as CR
ctxg@               ldx       #FrStdin
                    pshs      x
                    lbsr      getc
                    leas      2,s
                    tsta
                    beq       ctxg9@
                    ldb       #C$CR
ctxg9@              rts
* ctxrow@: B = the row under the packet's pointer, $FF (N set) when none. Byte columns col..col+width-1,
* rows (y-5-my)/7 below the count. Stack here: 2,s the packet  7,s the count  8,s the keys
* CTXMAX+8,s col  CTXMAX+9,s y  CTXMAX+10,s rows  CTXMAX+11,s width
ctxrow@             ldd       2,s
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb                          the byte column
                    subb      CTXMAX+8,s
                    sbca      #$00
                    bne       ctxrn@
                    cmpb      CTXMAX+11,s
                    bhs       ctxrn@
                    lda       CTXMAX+9,s
                    suba      #$05
                    suba      4,s                 topy - 5 - my
                    bcs       ctxrn@              above the box
                    ldb       #$FF
ctxrd@              incb
                    suba      #$07
                    bcc       ctxrd@
                    cmpb      7,s
                    blo       ctxr9@
ctxrn@              ldb       #$FF
ctxr9@              tstb
                    rts
* ctxinv@: invert row B (nothing for $FF or a title row): bytblt(3, col-1, y2-5, col+width, y2), y2 = y-5-7B
ctxinv@             cmpb      #$FF
                    beq       ctxi9@
                    pshs      b                   ,s the row   9,s the keys   CTXMAX+9,s col  CTXMAX+10,s y  CTXMAX+12,s width
                    leax      9,s
                    abx
                    lda       ,x
                    cmpa      #C$SPAC
                    bls       ctxi8@              a title row
                    clra
                    clrb
                    pshs      a,b                 buf: none        (2,s row  CTXMAX+11,s col  CTXMAX+12,s y  CTXMAX+14,s width)
                    lda       #$07
                    ldb       2,s
                    mul
                    pshs      a,b                 7 * row          (4,s row  CTXMAX+13,s col  CTXMAX+14,s y  CTXMAX+16,s width)
                    ldb       CTXMAX+14,s
                    clra
                    subd      ,s++                y - 7 * row      (2,s row  CTXMAX+11,s col  CTXMAX+12,s y  CTXMAX+14,s width)
                    subd      #$0005
                    pshs      a,b                 y2               (2,s buf  4,s row  CTXMAX+13,s col  CTXMAX+16,s width)
                    ldb       CTXMAX+13,s
                    clra
                    addb      CTXMAX+16,s
                    adca      #$00
                    pshs      a,b                 x2 = col + width (2,s y2  CTXMAX+15,s col)
                    ldd       2,s
                    subd      #$0005
                    pshs      a,b                 y1 = y2 - 5      (CTXMAX+17,s col)
                    ldb       CTXMAX+17,s
                    clra
                    subd      #$0001
                    pshs      a,b                 x1 = col - 1
                    ldd       #$0003
                    pshs      a,b                 invert
                    inc       >FrNoDirty          the inversion adds nothing to the batch's dirty set
                    lbsr      SwapBase
                    lbsr      bytblt              the shown page first (live)
                    lbsr      SwapBase
                    lbsr      bytblt              and the hidden one, so both pages stay identical and the
                    clr       >FrNoDirty          un-invert cancels whichever page a flip in between shows
                    leas      12,s
ctxi8@              puls      b
ctxi9@              rts
ctx9@               leas      CTXMAX+4,s
                    puls      u,pc
* pollmark - command $CA: s9 sends it (inkey, testkey, mouce) just before it looks for a key or the mouse, so the
* screen it drew is complete: Present shows the hidden page (nothing if nothing was drawn since the last flip).
* The CR that follows is swallowed like $CD's.
pollmark            pshs      u
                    lbsr      Present
                    ldb       #$01
                    stb       <FrEatCR
                    puls      u,pc
unimp               pshs      u                   commands $AE and $CD (s9's refresh): arm the CR swallow
* No flip here: a $CD follows every item of a screen; pollmark ($CA) flips.
                    ldb       #$01
                    stb       <FrEatCR
                    puls      u,pc
beepa               pshs      u
                    ldb       >FrBell
                    beq       beepa_1
                    lbsr      Beep
beepa_1               puls      u,pc
* dispatch: the command loop - fread one stdin byte; < $80 is text for vanna when a window is open, $80-$D2 is
* looked up in the {cmd,nargs,handler} table fes (data $B0), its arguments fread into <arg0.. and the handler called.
* s9 flushes its stdout (this pipe) before every key poll: if s9gui ever stops reading, that flush blocks forever
* and both processes sit idle, which looks exactly like a dead keyboard.

dispatch         pshs      u
                    leas      <-$4D,s
                    clra
                    clrb
                    stb       4,s
                    bra       CmdReadNext
* CmdReadNext: loop head: fread one command byte from stdin; 0 bytes read = EOF, text and exit
CmdReadNext         ldx       #FrStdin
                    pshs      x
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    leax      11,s
                    pshs      x
                    lbsr      fread
                    leas      8,s
                    std       8,s
                    bne       CmdTextChar
                    lbsr      text
                    lbra      CommandLoopExit
* CmdTextChar: non-negative byte: passed to vanna if a text window is open (<tgwmode)
CmdTextChar         ldb       5,s
                    blt       CmdLookup
                    tst       <FrEatCR            the byte right after a $CD or $CA?
                    beq       ctc1@
                    clr       <FrEatCR            the flag covers one byte only
                    cmpb      #$0D
                    lbeq      CmdLoopBack         the CR s9 appends: not text
ctc1@               ldb       <tgwmode
                    beq      CmdLoopBack
                    ldb       5,s
                    sex
                    pshs      a,b
                    lbsr      vanna
                    bra       CmdCharDone
* CmdLookup: bytes above $D2 go to illegal; otherwise scan the 4-byte command table fes ($B0)
CmdLookup           ldb       5,s
                    cmpb      #$D2
                    bgt       CmdIllegalArm
                    clra
                    clrb
                    std       2,s
                    ldu       #fes
* CmdLookupLoop: compares the command byte with each table entry until a match or the $D3 terminator
CmdLookupLoop       ldb       ,u
                    sex
                    std       ,s
                    pshs      a,b
                    ldb       7,s
                    sex
                    cmpd      ,s++
                    beq       a5@
                    ldd       ,s
                    cmpd      #$00D3
                    beq       a5@
                    ldd       2,s
                    addd      #$0001
                    std       2,s
                    subd      #$0001
                    tfr       u,d
                    leau      4,u
                    bra       CmdLookupLoop
a5@                 ldd       ,s
                    cmpd      #$00D3
                    bne       CmdReadArgs
* CmdIllegalArm: dispatch arm for byte > $D2 or table terminator $D3: pushes the byte and calls illegal
CmdIllegalArm       ldb       5,s
                    sex
                    pshs      a,b
                    lbsr      illegal
* CmdCharDone: pops the byte pushed for vanna/illegal
CmdCharDone         leas      2,s
* CmdLoopBack: back to CmdReadNext; CmdTextChar comes here for a swallowed CR or when no text window is open
CmdLoopBack         lbra      CmdReadNext
* CmdReadArgs: takes the handler offset and arg count from the entry and freads that many bytes to <arg0 ($1E)
CmdReadArgs         ldd       2,u                 the handler's module offset (not relocated)
                    leax      >ModuleBase,pcr
                    leax      d,x
                    stx       6,s
                    ldb       1,u
                    sex
                    std       10,s
                    beq       CmdArgCheck
                    ldx       #FrStdin
                    pshs      x
                    ldd       12,s
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldx       #$001E
                    pshs      x
                    lbsr      fread
                    leas      8,s
                    std       8,s
* CmdArgCheck: if fewer bytes arrived than needed: fprintf(stderr, fmtEofInCmd) and bell, then leave the loop
CmdArgCheck         ldd       8,s
                    cmpd      10,s
                    bge       CmdDispatch
                    ldd       8,s
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    ldb       9,s
                    sex
                    orb       #$80
                    clra
                    pshs      a,b
                    leax      >fmtEofInCmd,pcr
                    pshs      x
                    ldx       #FrStderr
                    pshs      x
                    lbsr      fprintf
                    leas      10,s
                    lbsr      bell
                    bra       CommandLoopExit
* CmdDispatch: a $A0 with FocusNoteBit in <arg0 drops the bit and sets FrFocusInk; then calls the handler, command byte pushed
CmdDispatch         clr       >FrFocusInk
                    ldb       5,s
                    cmpb      #$A0
                    bne       DispatchFocusReady
                    lda       <arg0
                    bita      #FocusNoteBit
                    beq       DispatchFocusReady
                    anda      #^FocusNoteBit
                    sta       <arg0
                    inc       >FrFocusInk
DispatchFocusReady  ldb       5,s
                    sex
                    pshs      a,b
                    jsr       [<$08,s]
                    leas      2,s
                    std       8,s
                    lbra      CmdReadNext
* CommandLoopExit: dispatch's epilogue; reached on EOF and on a short argument read
CommandLoopExit     leas      <$4D,s
                    puls      u,pc
* RenderFocusedPart - $CA (FrRenderFocusedPart): a batch of $A0 note packets (five arguments each), ended by any
* other byte (zero by protocol). Unreachable: pollmark's $CA entry comes first in the command table.
RenderFocusedPart   pshs      u
FocusedBatchNext    ldx       #FrStdin
                    pshs      x
                    lbsr      getc
                    leas      2,s
                    cmpb      #$A0
                    bne       FocusedBatchDone
                    ldx       #FrStdin
                    pshs      x
                    ldd       #5
                    pshs      d
                    ldd       #1
                    pshs      d
                    ldx       #arg0
                    pshs      x
                    lbsr      fread
                    leas      8,s
                    cmpd      #5
                    bne       FocusedBatchDone
                    lda       <arg0
                    anda      #^FocusNoteBit
                    sta       <arg0
                    lda       #1
                    sta       >FrFocusInk
                    lbsr      dnota
                    bra       FocusedBatchNext
FocusedBatchDone    clr       >FrFocusInk
                    puls      u,pc
* illegal: sprintf/pat 'Ill %02x' into the text window, then dumps the following stdin bytes (ResyncLoop)
illegal          pshs      u
                    leas      <-$41,s
                    ldd       <$45,s
                    clra
                    pshs      a,b
                    leax      >fmtIllegalCmd,pcr
                    pshs      x
                    leax      4,s
                    pshs      x
                    lbsr      sprintf
                    leas      6,s
                    leax      ,s
                    pshs      x
                    lbsr      pat
                    leas      2,s
* ResyncLoop: pats each stdin byte as ' %2x' until an even one arrives, then WaitFewSecs; the $FFFF EOF test never passes (EOF is odd and keeps the loop going)
ResyncLoop          ldx       #FrStdin
                    pshs      x
                    lbsr      getc
                    leas      2,s
                    std       <$45,s
                    pshs      a,b
                    leax      >fmtHexByte,pcr
                    pshs      x
                    leax      4,s
                    pshs      x
                    lbsr      sprintf
                    leas      6,s
                    leax      ,s
                    pshs      x
                    lbsr      pat
                    leas      2,s
                    ldd       <$45,s
                    clra
                    andb      #$01
                    bne       ResyncLoop
                    ldd       <$45,s
                    cmpd      #$FFFF
                    bne       WaitFewSecs
                    leax      >msgFoundEof,pcr
                    pshs      x
                    lbsr      printf
                    leas      2,s
                    lbsr      release
                    ldd       #$0001
                    pshs      a,b
                    lbsr      exit
                    leas      2,s
* WaitFewSecs: pat msgWaitFewSec and tsleep(100 ticks)
WaitFewSecs         leax      >msgWaitFewSec,pcr
                    pshs      x
                    lbsr      pat
                    leas      2,s
                    ldd       #$0064
                    pshs      a,b
                    lbsr      tsleep
                    leas      2,s
                    leas      <$41,s
                    puls      u,pc
* msgNoGfxScreen: 'Nscr' printed by main when the screen cannot be mapped
msgNoGfxScreen      fcc       /Nscr/              short: s9gui is at its size ceiling
                    fcb       $0D,$00
L0AB8               equ       *
                    fcb       $0C,$18,$30,$60,$00
L0ABD               equ       *
                    fcb       $60,$30,$18,$0C,$00
L0AC2               equ       *
                    fcb       $0C,$0D,$0D               FF, CR, CR: the abort prompt gaboa pats
                    fcc       /  RELEASE TO ABORT/
                    fcb       $0D,$00
* fmtEofInCmd: 'EOF cmd need/got' fprintf to stderr by dispatch on a short argument read
fmtEofInCmd         fcb       $0D
                    fcc       |EOF %2x %d/%d|
                    fcb       $0D,$00
* fmtIllegalCmd: 'Ill %02x' sprintf format used by illegal
fmtIllegalCmd       fcb       $0D
                    fcc       /Ill %02x/
                    fcb       $0D,$00
* fmtHexByte: ' %2x' format used by ResyncLoop to dump stray stdin bytes
fmtHexByte          fcc       / %2x/
                    fcb       $00
* msgFoundEof: printed before exit(1) by ResyncLoop's EOF test (unreachable)
msgFoundEof         fcb       $0D
                    fcc       /Fran found EOF, 'bye./
                    fcb       $0D,$00
* msgWaitFewSec: 'Wait a few sec...' printed by WaitFewSecs
msgWaitFewSec       fcb       $0D
                    fcc       /Wait a few sec.../
                    fcb       $00
* dump: dump.a / fprint.c dumper(): legacy printer bitmap dump.
                    ifdef     FRANPRINT
dump               pshs      u
                    ldx       <vdgram
                    stx       <FrData_reserved_002E
                    ldb       <printype
                    decb
                    beq       dump_2
                    decb
                    beq       dump_1
                    decb
                    beq       dump_1
                    decb
                    beq       dump_4
                    decb
                    beq       dump_5
                    decb
                    beq       dump_7
                    decb
                    beq       dump_8
                    puls      u,pc
dump_1               leax      >L0D0D,pcr
                    bra       dump_3
dump_2               leax      >L0D09,pcr
dump_3               stx       <FrData_reserved_0034
                    lbra      L0C42_1
dump_4               leax      >L0CBD,pcr
                    stx       <FrData_reserved_0034
                    leax      >L0CCB,pcr
                    stx       <FrData_reserved_0038
                    bra       dump_6
dump_5               leax      >L0CC1,pcr
                    stx       <FrData_reserved_0034
                    leax      >L0CD1,pcr
                    stx       <FrData_reserved_0038
dump_6               leax      >L0CC5,pcr
                    stx       <FrData_reserved_0036
                    leax      >L0CD7,pcr
                    stx       <FrData_reserved_003A
                    bra       dump_9
dump_7               leax      >L0CE6,pcr
                    stx       <FrData_reserved_0034
                    leax      >L0CDF,pcr
                    stx       <FrData_reserved_0036
                    leax      >L0CEB,pcr
                    stx       <FrData_reserved_0038
                    leax      >L0CF0,pcr
                    stx       <FrData_reserved_003A
                    bra       dump_9
dump_8               leax      >L0CF8,pcr
                    stx       <FrData_reserved_0034
                    leax      >L0CF4,pcr
                    stx       <FrData_reserved_0036
                    leax      >L0CEB,pcr
                    stx       <FrData_reserved_0038
                    leax      >L0CFC,pcr
                    stx       <FrData_reserved_003A
dump_9               ldu       <FrData_reserved_0034
                    bsr      DumpSendString
                    ldu       <FrData_reserved_0036
                    bsr      DumpSendString
                    clr       <FrData_reserved_0032
dump_10               ldu       <FrData_reserved_0038
                    bsr      DumpSendString
                    clr       <FrData_reserved_0031
dump_11               ldb       #$80
                    stb       <FrData_reserved_0030
dump_12               lda       #$01
                    ldx       <FrData_reserved_002E
                    leax      <-$50,x
dump_13               leax      <$50,x
                    ldb       ,x
                    andb      <FrData_reserved_0030
                    addb      #$FF
                    rola
                    bhs       dump_13
                    bsr       L0C42
                    lsr       <FrData_reserved_0030
                    bne       dump_12
                    ldx       <FrData_reserved_002E
                    leax      1,x
                    stx       <FrData_reserved_002E
                    ldb       <FrData_reserved_0031
                    incb
                    stb       <FrData_reserved_0031
                    cmpb      #$50
                    blo       dump_11
                    leau      >L0CBA,pcr
                    bsr       DumpSendString
                    ldx       <FrData_reserved_002E
                    leax      >$0230,x
                    stx       <FrData_reserved_002E
                    ldb       <FrData_reserved_0032
                    incb
                    stb       <FrData_reserved_0032
                    cmpb      <pnrows
                    blt       dump_10
                    ldu       <FrData_reserved_003A
                    bsr       DumpSendString
                    puls      u,pc
* DumpSendString: Send the NUL-terminated printer control string through putprtr.
DumpSendString               lda       ,u+
                    beq       DumpSendString_1
                    bsr       L0C42
                    bra       DumpSendString
DumpSendString_1               rts
L0C42               tfr       a,b
                    pshs      a,b
                    lbsr      putprtr
                    puls      a,b,pc
L0C42_1               clr       <FrData_reserved_0033
                    leau      >L0CFF,pcr
                    bsr       DumpSendString
                    clr       <FrData_reserved_0032
L0C42_2               ldu       <FrData_reserved_0034
                    bsr       DumpSendString
                    clr       <FrData_reserved_0031
L0C42_3               ldb       #$80
                    stb       <FrData_reserved_0030
L0C42_4               lda       #$01
                    ldx       <FrData_reserved_002E
                    leax      >$0230,x
L0C42_5               leax      <-$50,x
                    ldb       ,x
                    andb      <FrData_reserved_0030
                    addb      #$FF
                    rola
                    bpl       L0C42_5
                    tst       <FrData_reserved_0033
                    beq       L0C42_6
                    anda      #$87
L0C42_6               bsr       L0C42
                    lsr       <FrData_reserved_0030
                    bne       L0C42_4
                    ldx       <FrData_reserved_002E
                    leax      1,x
                    stx       <FrData_reserved_002E
                    ldb       <FrData_reserved_0031
                    incb
                    stb       <FrData_reserved_0031
                    cmpb      #$50
                    blo       L0C42_3
                    lda       #$0D
                    bsr       L0C42
                    ldx       <FrData_reserved_002E
                    leax      >$01E0,x
                    stx       <FrData_reserved_002E
                    ldb       <FrData_reserved_0032
                    incb
                    stb       <FrData_reserved_0032
                    cmpb      <pnrows
                    blt       L0C42_2
                    lda       <pnrows
                    cmpa      #$1B
                    blt       L0C42_7
                    cmpb      <pnrows
                    bgt       L0C42_7
                    inc       <FrData_reserved_0033
                    bra       L0C42_2
L0C42_7               leau      >L0D05,pcr
                    bsr      DumpSendString
                    puls      u,pc
L0CBA               equ       *
                    fcb       $0D,$0A,$00
L0CBD               equ       *
                    fcb       $1B,$6C,$05,$00
L0CC1               equ       *
                    fcb       $1B
                    fcb       $6C,$0C,$00
L0CC5               equ       *
                    fcb       $1B,$23,$1B,$41,$08
                    fcb       $00
L0CCB               equ       *
                    fcb       $1B,$2A,$06,$80,$02,$00
L0CD1               equ       *
                    fcb       $1B
                    fcb       $2A,$01,$80,$02,$00
L0CD7               equ       *
                    fcb       $1B,$3D,$1B
                    fcb       $32,$1B,$6C,$01,$00
L0CDF               equ       *
                    fcb       $1B,$33,$18
                    fcb       $1B,$35,$80,$00
L0CE6               equ       *
                    fcb       $1B,$58,$0A,$50
                    fcb       $00
L0CEB               equ       *
                    fcb       $1B,$4C,$80,$02,$00
L0CF0               equ       *
                    fcb       $1B,$33
                    fcb       $24,$00
L0CF4               equ       *
                    fcb       $1B,$33,$10,$00
L0CF8               equ       *
                    fcb       $1B,$4D
                    fcb       $08,$00
L0CFC               equ       *
                    fcb       $1B,$40,$00
L0CFF               equ       *
                    fcb       $1B,$14,$1B
                    fcb       $16,$12,$00
L0D05               equ       *
                    fcb       $1E,$1B,$13,$00
L0D09               equ       *
                    fcb       $1C
                    fcb       $40,$80,$00
L0D0D               equ       *
                    fcb       $00
                    else
* Without FRANPRINT (no printer on the WildBits) dump, its Epson strings and dumper are not assembled; dump is a stub.
dump                rts
                    endc
* or2_15: (screenAddr, image) as or2_16 but only the image's first 15 rows (put2 with rows = 15)
or2_15        pshs      u
                    ldu       4,s
                    ldx       6,s
                    ldb       #$0F
                    bra       OrImageRows
* or2_16: (screenAddr, image) inks a 16-row, sixteen-dot image into 16 screen rows; put2 uses it for 16-row pictures
or2_16        pshs      u
                    ldu       4,s
                    ldx       6,s
                    ldb       #$10
* OrImageRows: B = rows, U = screen address, X = image: each row Fetch16, Or8, then ScrRowDn. Returns for or2_15/or2_16.
OrImageRows         pshs      b
oir1@               lbsr      Fetch16             the row, from the bank or widened
                    lbsr      Or8
                    lbsr      ScrRowDn
                    dec       ,s
                    bne       oir1@
                    puls      b
                    puls      u,pc
* CopyBytes: (dst, src, n) forward byte copy; scrollup uses it to move a text line up
CopyBytes           ldd       4,s
                    addd      6,s
                    pshs      a,b,u
                    ldx       8,s
                    ldu       6,s
                    bra       b6@
a6@                 ldb       ,x+
                    stb       ,u+
b6@                 cmpx      ,s
                    blo       a6@
                    puls      a,b,u,pc
* mapwin: claim the screen. There is no one-bit canvas: every primitive draws straight into VICKY's bitmap 0,
* 640x192 of the 640x240 HIRES4 frame (four bits a dot, two dots a byte, the HIGH nibble the LEFT dot, 320 bytes
* a row; y=0 is the BOTTOM row, so row y starts at byte (191-y)*320). s9 allocates the ten-block bitmap and sets
* layer 0, CLUT 0 and HIRES4 before s9gui is forked, so SS.AScrn answers E$WADef with the first block in X;
* a fresh allocation is accepted as well.
* The picture is 61,440 bytes and this process has two free map slots, so it is reached through a SLIDING
* TWO-BLOCK WINDOW: ScrWin maps picture blocks W and W+1; every row STARTS in block W and is 320 bytes long,
* so no row can run out of the window. ScrAddr anchors the window on any byte offset; ScrRowDn / ScrRowUp
* step one row and re-anchor when the step leaves the first block. The wildbits kernel reloads the MMU LUT
* on every system-call return, so a remap is live as soon as F$MapBlk returns.
* Ink is nibble FrInk, paper nibble 0 (VICKY shows the background color for a 0 dot).
mapwin       pshs      y,u
* Eight blocks for the four-bit rectangle saves (RectSave); if refused, FrSave stays 0 and saves are skipped.
                    ldb       #$08
                    os9       F$AllRAM            D = the first block
                    bcs       mds0@
                    std       >FrSave
mds0@               clra
                    clrb
                    std       >FrDragSave         0 until the drag snapshot (eight blocks) is allocated
                    ldb       #8
                    os9       F$AllRAM
                    lbcs      NoScrM              fail startup instead of drawing without a saved canvas
                    std       >FrDragSave
                    lda       #$02                path 2 = /term
                    ldb       #SS.AScrn           bitmap 0, ten blocks (type 0 = 320x240)
                    ldx       #$0000
                    ldy       #$0000
                    os9       I$SetStt            X = the bitmap's first physical block
                    bcc       scrok@
                    cmpb      #E$WADef            already allocated (s9 allocates it first): X is its block
                    lbne      NoScrA              anything else: no screen (NoCanvas)
scrok@              tfr       x,d
                    stb       <FrBM0
                    lbsr      DmaProbe            the DMA engine there? (FrDma)
                    ldb       #$FF
                    stb       <FrWin              nothing mapped yet
                    clra
                    clrb
                    std       <FrWinP
                    lbsr      ScrAddr             offset 0: picture blocks 0-1 into the window
                    ldd       <FrWinP
                    lbeq      NoScrM              F$MapBlk refused: no screen (NoCanvas)
                    std       <vdgram                the 'screen present' word main() tests and prints
* The frame has 240 rows, the picture 192: BottomInit clears the whole bitmap before the display is switched on.
                    bsr      BottomInit
                    lbsr     DblBufInit          bitmap 1, the copy: double buffering from here
                    lda       #$02                show it: graphics + bitmap, text layer off
                    ldb       #SS.DScrn
                    ldx       #FX_GRF+FX_BM
                    ldy       #FT_OMIT
                    os9       I$SetStt
                    puls      y,u,pc
* BottomInit: the whole bitmap - ten contiguous blocks - goes to $00 by DMA; DblBufInit then copies all ten
* blocks into bitmap 1, so both screens start clean. Without the DMA engine nothing is cleared. s9gui draws
* nothing below row 191; s9 lays out the 88-key keyboard there itself. Keeps every register.
BottomInit          pshs      d,x,y,u
                    clra                          color $0 in both dots
                    ldb       <FrBM0
                    ldx       #0
                    ldy       #5*8192             two runs: a DmaClr count is sixteen bits
                    lbsr      DmaClr              blocks 0-4
                    bcs       bi1@
                    clra
                    ldb       <FrBM0
                    addb      #5
                    ldx       #0
                    ldy       #5*8192
                    lbsr      DmaClr              blocks 5-9
bi1@                lbsr      SymUnmap
                    puls      d,x,y,u,pc

                    use       module_dir.inc
FontBank            fcc       /s9_d0/
                    fcb       0

* LinkDataBank: X = data module name -> U = its base, linked or loaded from the s9 directory, UD bank header checked. Carry + B = error. Keeps X and Y.
LinkDataBank        pshs      x,y
                    lda       #Data
                    os9       F$Link
                    bcc       ldbCheck@
                    leas      -S9ModulePathBytes,s
                    leau      ,s                  STACK OFFSET 0: temporary absolute module path
                    lbsr      S9InitDir
                    bcs       ldbPathDone@
                    tfr       x,u
                    ldx       S9ModulePathBytes,s  STACK OFFSET: saved module-name argument
ldbName@            lda       ,x+
                    sta       ,u+
                    bne       ldbName@
                    leax      ,s
                    lda       #Data
                    ldb       #EXEC.
                    os9       F$Load
ldbPathDone@        leas      S9ModulePathBytes,s
                    bcs       ldbDone@
ldbCheck@           ldd       M$IDSize+2,u
                    cmpd      #$5544              UD bank format
                    bne       ldbBad@
                    ldb       M$IDSize+4,u
                    cmpb      #1
                    bne       ldbBad@
                    ldd       M$IDSize,u
                    beq       ldbBad@
                    cmpd      #$1B00
                    bhi       ldbBad@
                    addd      #$0103              header and CRC
                    cmpd      M$Size,u
                    bhi       ldbBad@
                    clrb
                    bra       ldbDone@
ldbBad@             os9       F$UnLink
                    ldb       #E$BMID
                    orcc      #Carry
ldbDone@            puls      x,y,pc

LoadFontData        pshs      d,x,y,u
                    lbsr      SymUnmap
                    ldb       #$FF
                    stb       <FrWin
* s9's fork parameters name its two symbol-tail blocks (FrTailBlk, for imgload). The Chars16 font comes from the
* page-aligned s9_d0 data module, which keeps s9gui under its 31,999-byte ceiling.
                    lbsr      BankParams
                    std       >FrTailBlk          for imgload
                    leax      >FontBank,pcr
                    lbsr      LinkDataBank
                    bcs       lfdDone@
                    pshs      u                   module base, for F$UnLink
                    leax      $100,u              page-aligned payload
                    ldu       #$099F
                    ldy       #$0900              the whole font, 2304 bytes ($099F-$129E)
lfdTail@            lda       ,x+
                    sta       ,u+
                    leay      -1,y
                    bne       lfdTail@
                    ldu       #FrArrowGlyphs       the arrow glyphs, kept apart from the font
                    ldy       #GlyphArrowCount*GlyphBytes  the appended glyphs: right, up, down arrows
lfdArrows@          lda       ,x+
                    sta       ,u+
                    leay      -1,y
                    bne       lfdArrows@
* Every dot of the font and of the arrows inverted (InvByte) into FrFontInv / FrArrowInv, same layout: menu
* windows draw their text from there.
                    ldx       #$099F
                    ldu       #FrFontInv
                    ldy       #FontBytes
lfdInv@             lda       ,x+
                    bsr       InvByte
                    sta       ,u+
                    leay      -1,y
                    bne       lfdInv@
                    ldx       #FrArrowGlyphs
                    ldu       #FrArrowInv
                    ldy       #GlyphArrowCount*GlyphBytes
lfdInvA@            lda       ,x+
                    bsr       InvByte
                    sta       ,u+
                    leay      -1,y
                    bne       lfdInvA@
                    puls      u
                    os9       F$UnLink
lfdDone@            puls      d,x,y,u,pc
* InvByte: A = two font dots -> A with ink ($F) and paper ($0) swapped; every other color stays, so the
* checkbox's gray $C stays gray on black. Keeps B.
InvByte             pshs      b
                    tfr       a,b
                    andb      #$0F                the right dot
                    beq       ivb1@
                    cmpb      #$0F
                    bne       ivb2@
                    clrb                          ink -> paper
                    bra       ivb2@
ivb1@               ldb       #$0F                paper -> ink
ivb2@               stb       ,-s
                    anda      #$F0                the left dot
                    beq       ivb3@
                    cmpa      #$F0
                    bne       ivb4@
                    clra
                    bra       ivb4@
ivb3@               lda       #$F0
ivb4@               ora       ,s+
                    puls      b,pc

* BankParams: s9's fork parameters (its TailInit) name the two module blocks that carry UmeSymbols16:
* two characters, block + $40 each, then CR. -> A = the bank 1 block, B = the bank 2 block; D = 0 and Z set
* when the parameters do not carry them.
* <$0C is the END of the parameter area (Y at entry; RelocAndArgs pulls it into X), not its start: the
* runtime's argument scanner walks backwards from it. s9 sends exactly three bytes, so they are the
* three before it: block 6 + $40, block 7 + $40, then the CR (or the NUL the scanner writes over it).
BankParams          ldx       <FrData_reserved_000C
                    lda       -1,x
                    beq       bpEnd@
                    cmpa      #C$CR
                    bne       bpNone@
bpEnd@              lda       -3,x
                    cmpa      #$40
                    blo       bpNone@
                    ldb       -2,x
                    cmpb      #$40
                    blo       bpNone@
                    suba      #$40
                    subb      #$40                Z clear: block 7 is never block 0
                    rts
bpNone@             clra
                    clrb
                    rts

* CopyBlockBank: D bytes from the start of RAM block X into the symbol bank at offset U (FrSym is
* the first of its two blocks, an offset past $2000 is in the second). One source and one
* destination block are mapped at a time - this process has two free slots. D = 1 done, 0 failed.
CopyBlockBank       tst       >FrDma
                    beq       CopyBlockBankCpu
* By DMA when the engine is there: the bank's two blocks are contiguous, so one run covers both.
                    pshs      d,x,y,u
                    tfr       d,y                 the count
                    tfr       x,d
                    tfr       b,a                 A = the source block
                    ldb       >FrSym+1            B = the bank's first block
                    ldx       #0                  the source offset; U = the bank offset as given
                    lbsr      DmaCopy
                    puls      d,x,y,u
                    bcs       CopyBlockBankCpu    not done: the mapped copy below
                    ldd       #1
                    rts
CopyBlockBankCpu    pshs      d,x,y,u
                    leas      -6,s                ,s source base  2,s destination base  4,s this pass
*                                                 6,s bytes left  8,s block  10,s Y  12,s destination offset
                    clra
                    clrb
                    std       ,s
                    std       2,s
                    ldx       8,s
                    ldb       #1
                    os9       F$MapBlk            the source block
                    bcs       cbbFail@
                    stu       ,s
cbbNext@            ldd       6,s
                    beq       cbbDone@
                    ldx       >FrSym
                    ldd       12,s
                    cmpd      #DAT.BlSz
                    blo       cbb1@
                    subd      #DAT.BlSz
                    std       12,s
                    leax      1,x                 the second bank block
cbb1@               ldb       #1
                    os9       F$MapBlk            the destination block
                    bcs       cbbFail@
                    stu       2,s
                    ldd       #DAT.BlSz
                    subd      12,s                room left in it
                    cmpd      6,s
                    bls       cbb2@
                    ldd       6,s
cbb2@               std       4,s
                    tfr       d,y
                    ldu       2,s
                    ldd       12,s
                    leau      d,u
                    ldx       ,s
cbb3@               lda       ,x+
                    sta       ,u+
                    leay      -1,y
                    bne       cbb3@
                    stx       ,s                  the source cursor moves on
                    ldu       2,s
                    ldb       #1
                    os9       F$ClrBlk            the destination block
                    clra
                    clrb
                    std       2,s
                    ldd       12,s
                    addd      4,s
                    std       12,s
                    ldd       6,s
                    subd      4,s
                    std       6,s
                    bra       cbbNext@
cbbDone@            ldd       ,s                  the source cursor has moved on: F$ClrBlk wants the block base
                    anda      #$E0
                    clrb
                    tfr       d,u
                    ldb       #1
                    os9       F$ClrBlk            the source
                    ldd       #1
                    bra       cbbRet@
cbbFail@            ldu       2,s
                    beq       cbbF1@
                    ldb       #1
                    os9       F$ClrBlk
cbbF1@              ldd       ,s
                    beq       cbbF2@
                    anda      #$E0
                    clrb
                    tfr       d,u
                    ldb       #1
                    os9       F$ClrBlk
cbbF2@              clra
                    clrb
cbbRet@             leas      8,s                 the frame and the pushed D
                    puls      x,y,u,pc

* A refused screen exits through NoCanvas (vdgram = 0); main() reports it.
NoScrA              equ       NoCanvas
NoScrM              equ       NoCanvas
* ScrWin: A = the picture block (0-8) that must be at the front of the window; when it is not there
* already, the pair mapped now is cleared and blocks A, A+1 are mapped in its place. Keeps every
* register (A comes back clamped). If F$MapBlk refuses, FrWinP stays 0 and the error code is left in FrWin
* (startup then takes NoCanvas; later it cannot happen - the same two slots have just been freed).
* A block outside 0-8 (a row above the picture, y > 191, or below it) is held to 0-8, so such a row lands
* inside the mapped window instead of mapping RAM that is not the bitmap's.
ScrWin              cmpa      #$08
                    bls       sw0@
                    tsta
                    bmi       swlo@
                    lda       #$08                below the picture: the last pair
                    bra       sw0@
swlo@               clra                          above it: the first pair
sw0@                cmpa      <FrWin
                    beq       sw9@
                    pshs      d,x,y,u
                    sta       <FrWin
                    lbsr      DirtyMark           the pair is about to be drawn into
                    ldu       <FrWinP
                    beq       sw1@                nothing mapped yet
                    ldb       #$02
                    os9       F$ClrBlk
                    clra
                    clrb
                    std       <FrWinP
sw1@                ldb       <FrWin
                    addb      <FrBM0
                    clra
                    tfr       d,x
                    ldb       #$02
                    os9       F$MapBlk            U = where the pair landed ($4000: slots 2-3)
                    bcc       sw2@
                    stb       <FrWin
                    bra       sw8@
sw2@                stu       <FrWinP
sw8@                puls      d,x,y,u
sw9@                rts
* ScrAddr: D = byte offset in the picture (0-61439) -> U = its address in the window, anchored so the
* row it starts is wholly inside. Keeps D, X and Y.
ScrAddr             pshs      a,b
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra                          block = offset / 8192
                    bsr       ScrWin
                    ldd       ,s
                    anda      #$1F                offset within the window's first block
                    addd      <FrWinP
                    tfr       d,u
                    puls      a,b,pc
* ScrRowDn: U = a row start in the window -> U = the row below it on the screen (y-1): 320 bytes
* further on, re-anchoring the window when that leaves its first block. ScrRowUp: the row above
* (y+1), 320 bytes back. Both keep every other register.
ScrRowDn            pshs      a,b
                    leau      >$0140,u
                    tfr       u,d
                    subd      <FrWinP
                    cmpd      #$2000
                    blo       rd9@                still starts in the first block
                    pshs      a,b
                    lda       <FrWin
                    inca
                    bsr       ScrWin
                    puls      a,b
                    subd      #$2000
                    addd      <FrWinP
                    tfr       d,u
rd9@                puls      a,b,pc
ScrRowUp            pshs      a,b
                    tfr       u,d
                    subd      <FrWinP
                    subd      #$0140
                    bcc       ru1@                still in the first block
                    pshs      a,b
                    lda       <FrWin
                    deca
                    lbsr      ScrWin
                    puls      a,b
                    addd      #$2000
ru1@                addd      <FrWinP
                    tfr       d,u
                    puls      a,b,pc
* ScrPos: D = y (0-191, 0 the bottom row), X = byte column (0-79 - eight dots each, as every caller
* counts them) -> U = the address of that column's first byte on that row, window anchored. This is
* the one-bit '(191-y)*80 + col' with four bytes a column and 320 a row. Clobbers X (Mul16).
ScrPos              pshs      x                   the column
                    pshs      a,b
                    ldd       #$00BF
                    subd      ,s++                191-y
                    pshs      a,b
                    ldd       #$0140
                    lbsr      Mul16               (191-y)*320; Mul16 pops its operand and clobbers X
                    pshs      a,b
                    ldd       2,s                 the column
                    aslb
                    rola
                    aslb
                    rola                          four bytes a column
                    addd      ,s++
                    leas      2,s
                    bra      ScrAddr
* FillRows: U = a column's address on the top row (ScrPos), A = rows, B = bytes a row, X = the
* fill byte (two dots) in its low half. From the column's byte 2 on - dots 4 and 5, where boxc puts a side
* line, then everything right of them - each row gets that byte: a dot-exact CLS. bytblt's eight-dot
* columns cannot stop at a frame line, which sits in the middle of its column.
FillRows            pshs      d,x,u               ,s rows  1,s bytes a row  3,s the byte
fr1@                leax      2,u
                    ldb       1,s
                    lda       3,s
fr2@                sta       ,x+
                    decb
                    bne       fr2@
                    lbsr      ScrRowDn
                    dec       ,s
                    bne       fr1@
                    puls      d,x,u,pc
* NibTab: the four dots of a nibble (bit 3 the left one) as two four-bit bytes: a set dot is FrInk,
* a clear dot 0. Widens the module's one-bit pictures, the strip patterns and the fill words.
NibTab              fcb       0,0,0,FrInk,0,FrInk*16,0,FrInk*17                        nibbles 0-3
                    fcb       FrInk,0,FrInk,FrInk,FrInk,FrInk*16,FrInk,FrInk*17                    nibbles 4-7
                    fcb       FrInk*16,0,FrInk*16,FrInk,FrInk*16,FrInk*16,FrInk*16,FrInk*17        nibbles 8-B
                    fcb       FrInk*17,0,FrInk*17,FrInk,FrInk*17,FrInk*16,FrInk*17,FrInk*17        nibbles C-F
* SprTab: the same table in SprInk, for the one-bit sprites (ExpBSpr).
SprTab              fcb       0,0,0,SprInk,0,SprInk*16,0,SprInk*17
                    fcb       SprInk,0,SprInk,SprInk,SprInk,SprInk*16,SprInk,SprInk*17
                    fcb       SprInk*16,0,SprInk*16,SprInk,SprInk*16,SprInk*16,SprInk*16,SprInk*17
                    fcb       SprInk*17,0,SprInk*17,SprInk,SprInk*17,SprInk*16,SprInk*17,SprInk*17
* ExpB: B = eight one-bit dots (bit 7 the left one) -> D = the left four as two bytes, X = the right
* four. OrExp inks those four bytes over ,U (InkAt), ClrExp clears the set dots there (erase),
* PutExp stores them (the eight dots replace what was there). All keep U and every other register.
ExpB                pshs      b
                    leax      >NibTab,pcr         the ink: lines, plots, patterns
                    bra       ExpB1
* ExpBSpr: ExpB for a one-bit SPRITE row (Fetch16/Fetch8): SprInk, unless FrChrome says the picture is
* a frame corner or an item-box cap, which must match the lines it joins.
ExpBSpr             pshs      b
                    leax      >SprTab,pcr
                    tst       <FrUnder            ledger ink ignores chrome and note highlighting
                    beq       expschrome@
                    tst       >FrStaffDots
                    beq       ExpB1
                    andb      #$AA                same alternating pixels as the staff
                    stb       ,s                  ExpB1 reloads this for the right half
                    bra       ExpB1
expschrome@         tst       <FrChrome
                    beq       ExpB1
                    leax      >NibTab,pcr
ExpB1               lsrb
                    lsrb
                    lsrb
                    lsrb
                    lslb
                    ldd       b,x                 the left four dots
                    pshs      a,b
                    ldb       2,s                 the eight dots again
                    andb      #$0F
                    lslb
                    ldx       b,x                 the right four
                    puls      a,b
                    leas      1,s
                    rts
* OrExp: B = eight one-bit dots, inked over the four bytes at ,U (the INK method): a dot with ink replaces
* the dot under it, a clear dot leaves it alone - as Or8 does for four-bit rows. Keeps every register.
OrExp               pshs      d,x,u
                    bsr       ExpB                D = the left four dots, X = the right four
                    bsr       InkAt
                    tfr       b,a
                    leau      1,u
                    bsr       InkAt
                    tfr       x,d
                    leau      1,u
                    bsr       InkAt
                    tfr       b,a
                    leau      1,u
                    bsr       InkAt
                    puls      d,x,u,pc
* InkAt: A = a byte of two dots -> its inked dots replace the ones at ,U, its clear dots leave them. Keeps all.
InkAt               pshs      a,b
                    lbsr      NibMask             A = $F0 / $0F / $FF for the inked dot(s)
                    coma
                    anda      ,u                  the dots under them cleared
                    ora       ,s                  the picture's dots in
                    sta       ,u
                    puls      a,b,pc
ClrExp              pshs      d,x
                    bsr       ExpB
                    coma
                    comb
                    anda      ,u
                    andb      1,u
                    std       ,u
                    tfr       x,d
                    coma
                    comb
                    anda      2,u
                    andb      3,u
                    std       2,u
                    puls      d,x,pc
PutExp              pshs      d,x
                    bsr       ExpB
                    std       ,u
                    stx       2,u
                    puls      d,x,pc
* Row path of the picture primitives: Fetch16 (sixteen dots) / Fetch8 (eight) put the next source row
* into FrRow as four-bit bytes and advance X: a one-bit row widened through ExpBSpr when Fr4Src is clear,
* or copied as it is (colors included) from the four-bit rows SrcFix pointed X at when it is set.
* when it is set. Or8/Or4 draw FrRow's inked dots over ,U (each replaces the dot under it), Put8/Put4 store it, Clr8/Clr4 erase every dot the
* row has ink on (AND NOT of a per-nibble mask, so any color erases). All keep U; only Fetch16/Fetch8 change X.
Fetch16             pshs      a,b
                    tst       <Fr4Src
                    bne       f16b@
                    ldb       ,x+
                    pshs      x
                    lbsr     ExpBSpr
                    std       >FrRow
                    stx       >FrRow+2
                    puls      x
                    ldb       ,x+
                    pshs      x
                    lbsr     ExpBSpr
                    std       >FrRow+4
                    stx       >FrRow+6
                    puls      x
                    puls      a,b,pc
f16b@               ldd       ,x++
                    std       >FrRow
                    ldd       ,x++
                    std       >FrRow+2
                    ldd       ,x++
                    std       >FrRow+4
                    ldd       ,x++
                    std       >FrRow+6
                    puls      a,b,pc
Fetch8              pshs      a,b
                    tst       <Fr4Src
                    bne       f8b@
                    ldb       ,x+
                    pshs      x
                    lbsr      ExpBSpr
                    std       >FrRow
                    stx       >FrRow+2
                    puls      x
                    puls      a,b,pc
f8b@                ldd       ,x++
                    std       >FrRow
                    ldd       ,x++
                    std       >FrRow+2
                    puls      a,b,pc
* Or8/Or4: FrRow's eight/four bytes over ,U, each through FocusPixel: every inked dot replaces the dot under it
* (NibMask picks the inked nibbles), so a picture is drawn in front. With FrUnder set (ledger lines) the row
* only fills paper dots, so it goes behind what is there. Keep every register.
Or8                 pshs      a,b,x,u
                    ldb       #$08
                    bra       orn@
Or4                 pshs      a,b,x,u
                    ldb       #$04
orn@                ldx       #FrRow
or1@                lda       ,x+
                    lbsr      FocusPixel
                    tst       <FrUnder
                    bne       or2@                a ledger line: behind what is there
                    pshs      a                   the row's two dots
                    lbsr      NibMask             A = $F0/$0F/$FF for the inked one(s)
                    coma
                    anda      ,u                  clear them under the picture
                    ora       ,s+                 and put the picture's colors there
                    sta       ,u+
                    decb
                    bne       or1@
                    puls      a,b,x,u,pc
or2@                pshs      a                   the row's two dots
                    lda       ,u                  the dots there now
                    pshs      a
                    lbsr      NibMask             A = the mask of the inked ones
                    coma
                    anda      1,s                 the row's dots only where paper
                    ora       ,s+                 under the dots that are there
                    sta       ,u+
                    leas      1,s
                    decb
                    bne       or1@
                    puls      a,b,x,u,pc
Put8                pshs      a,b,x,u
                    ldb       #$08
                    bra       ptn@
Put4                pshs      a,b,x,u
                    ldb       #$04
ptn@                ldx       #FrRow
pt1@                lda       ,x+
                    lbsr      FocusPixel
                    sta       ,u+
                    decb
                    bne       pt1@
                    puls      a,b,x,u,pc
* FocusPixel: A = a byte of two dots. With FrFocusInk set, every non-zero dot is XORed with COLORS_PARTXOR
* ($F ^ $7 = 8: $F <-> 7, $E <-> 6, $C <-> 4, $A <-> 2, 8 <-> 0); paper stays. Then, with FrOpaque set, paper
* dots become OpaqueInk. Nothing changes while FrUnder is set. Keeps B; no C arguments.
FocusPixel          tst       <FrUnder
                    bne       opq3@               ledger pixels keep staff gray and transparency
                    tst       >FrFocusInk
                    beq       FocusPixelDone
                    pshs      b
                    tfr       a,b
                    andb      #$F0
                    beq       fpx1@               left dot is paper: leave it
                    eora      #COLORS_PARTXOR*16   map left dot to selected-part palette
fpx1@               tfr       a,b
                    andb      #$0F
                    beq       fpx2@               right dot is paper: leave it
                    eora      #COLORS_PARTXOR      map right dot to selected-part palette
fpx2@               puls      b
* FrOpaque: paper dots become OpaqueInk (palette $A, black), so the row covers what is there
FocusPixelDone      tst       >FrOpaque
                    beq       opq3@
                    pshs      b
                    tfr       a,b
                    andb      #$F0
                    bne       opq1@
                    ora       #OpaqueInk*16       the left dot was paper
opq1@               tfr       a,b
                    andb      #$0F
                    bne       opq2@
                    ora       #OpaqueInk          the right dot was paper
opq2@               puls      b
opq3@               rts
Clr8                pshs      a,b,x,u
                    ldb       #$08
                    bra       cln@
Clr4                pshs      a,b,x,u
                    ldb       #$04
cln@                ldx       #FrRow
cl1@                lda       ,x+
                    bsr       NibMask
                    coma
                    anda      ,u
                    sta       ,u+
                    decb
                    bne       cl1@
                    puls      a,b,x,u,pc
* NibMask: A = a byte of two dots -> A = $F0 for a left dot of any color, $0F for a right one, or both
NibMask             pshs      b
                    tfr       a,b
                    andb      #$F0
                    beq       nm1@
                    ldb       #$F0
nm1@                anda      #$0F
                    beq       nm2@
                    orb       #$0F
nm2@                tfr       b,a
                    puls      b,pc
* SrcFix: X = a picture pointer, A = bytes a one-bit row (1 or 2), B = rows. A four-bit image in this module
* (Note128Up..Note128End) is used in place. A pointer into the old AllUm3 buffer ($0BDF-$128E) means the
* symbol bank's first part, one into the virtual picture range (PicVirt, PicLen bytes, module-relative) its
* second: the four-bit rows (A*4 bytes each) are staged into FrStage and X = FrStage. Fr4Src is set in all
* these cases; any other pointer is a one-bit picture in this module: Fr4Src clear, X unchanged. Keeps every
* other register. Staging maps the bank over the window's slots, so a primitive calls SrcFix BEFORE ScrPos.
SrcFix              clr       <Fr4Src
                    pshs      d,y,u
                    leau      Note128Up,pcr
                    pshs      u
                    tfr       x,d
                    subd      ,s++
                    cmpd      #Note128End-Note128Up
                    bhs       sfbank@
                    inc       <Fr4Src             local four-bit image; no bank mapping required
                    puls      d,y,u,pc
sfbank@             cmpx      #$0BDF
                    blo       sf1@
                    cmpx      #$128F
                    bhs       sf1@
                    tfr       x,d
                    subd      #$0BDF              part 1: the AllUm3 rows
                    bra       sf2@
sf1@                leau      >PicVirt,pcr        part 2: the pictures that were built in
                    tfr       x,d
                    pshs      u
                    subd      ,s++                X - PicVirt modulo 64K: base + PicVirt + offset can pass $FFFF, the
*                                                 16-bit difference is still the offset. A pointer below the range
*                                                 gives $8000 or more and fails the length test (no carry test).
                    cmpd      #PicLen
                    bhs       sf8@                outside it: a one-bit picture, drawn as it is
                    aslb
                    rola
                    aslb
                    rola
                    addd      #BankPic
                    bra       sf3@
sf2@                aslb
                    rola
                    aslb
                    rola
sf3@                tfr       d,x                 the offset in the bank
                    lda       ,s
                    ldb       1,s
                    mul                           one-bit bytes
                    aslb
                    rola
                    aslb
                    rola                          four-bit bytes to stage (216 at most)
                    ldu       #FrStage
                    bsr      BankCopy
                    ldx       #FrStage
                    inc       <Fr4Src
                    lda       >FrDynaInk
                    cmpa      #2                  turn it?
                    bne       sf8@
* The 180-degree turn: a 16 x 16 four-bit picture is 128 bytes; byte i and byte 127 - i change
* places with their nibbles swapped, so the last row's right dot becomes the first row's left one. Only the
* part-type icons ask for it (drawpticon), and only 16-row pictures are staged that way.
                    ldx       #FrStage
                    ldu       #FrStage+128
                    ldy       #64
sft@                lda       ,x
                    bsr       NibSwap
                    ldb       ,-u
                    sta       ,u
                    tfr       b,a
                    bsr       NibSwap
                    sta       ,x+
                    leay      -1,y
                    bne       sft@
                    ldx       #FrStage            the turned picture, from its first row
sf8@                puls      d,y,u,pc
* NibSwap: A = A with its nibbles exchanged (the two dots of a four-bit byte swap sides)
NibSwap             pshs      b
                    tfr       a,b
                    lsra
                    lsra
                    lsra
                    lsra
                    lslb
                    lslb
                    lslb
                    lslb
                    pshs      b
                    ora       ,s+
                    puls      b,pc
* BankCopy: X = offset in the symbol bank (0-$28C3), D = bytes, U = where they go. Maps the bank's two
* blocks into the window's slots for the copy (the next ScrAddr maps the picture again). Nothing copied
* when there is no bank.
BankCopy            pshs      d,x,y,u
                    lbsr      SymMap              U = the bank, or 0
                    beq       bc9@
                    ldd       2,s
                    leax      d,u
                    ldu       6,s
                    ldy       ,s
bc1@                lda       ,x+
                    sta       ,u+
                    leay      -1,y
                    bne       bc1@
bc9@                lbsr      SymUnmap
                    puls      d,x,y,u,pc
NoCanvas            ldu       #$0000  mapwin's no-screen exit: vdgram = 0
SetScreenPtr        stu       <vdgram
                    puls      y,u,pc
* The 24 sixteen-by-sixteen pictures are four-bit data in UmeSymbols16 (part 2). Their labels (equates.asm,
* PicVirt + offset) are virtual module addresses that SrcFix maps into the bank.
* The four part-type icons follow Note64thDown, four-bit in the bank at $26C4 + 128 * index:
* PartNormal, PartClone, PartNormalNoFlags, PartCloneNoFlags in UmeSymbols16.asm (the scheme is written there).
* Stem up only; drawpticon asks SrcFix (FrDynaInk = 2) to turn them for the stem-down drawings. 32 virtual bytes apart, like the pictures.
* imgload: allocate the two-block symbol bank (FrSym) and copy s9's two tail blocks (FrTailBlk) into it.
imgload             pshs      y,u
                    clra
                    clrb
                    std       >FrSym
                    ldb       #2
                    os9       F$AllRAM
                    lbcs      ildError@
                    std       >FrSym
                    lbsr      SymUnmap            both free slots are needed: a source and a destination block
                    ldb       #$FF
                    stb       <FrWin              nothing in the window (set before D is loaded: B is clobbered)
                    ldd       >FrTailBlk          the two tail block numbers
                    beq       ildCheck@           0 = no tail blocks: no symbols
                    pshs      d                   ,s block 6   1,s block 7
                    ldb       ,s
                    clra
                    tfr       d,x
                    ldd       #$1B00              bank 1: 6912 bytes to offset 0
                    ldu       #0
                    lbsr      CopyBlockBank
                    beq       ildTailBad@
                    ldb       1,s
                    clra
                    tfr       d,x
                    ldd       #$11C0              bank 2: 4544 bytes right after bank 1, including the piano keys
                    ldu       #$1B00
                    lbsr      CopyBlockBank
ildTailBad@         leas      2,s
                    bra       ildCheck@
ildCheck@           bne       ildDone@
                    clra
                    clrb
                    std       >FrSym              the two blocks stay allocated (a fatal path)
ildError@           leax      >msgImageReadErr,pcr
                    pshs      x
                    lbsr      printf
                    leas      2,s
ildDone@            puls      y,u,pc
* 128th notes use the current 64th artwork with a red dot in the notehead.
* Four 128-byte glyphs (16 rows of 8 bytes) cut from the symbol image, each with byte 2 of two adjacent notehead rows
* Note128Glyph Img,Row: the 64th artwork at offset Img of UmeSymbols16.img, the dot on rows Row and Row+1.
Note128Glyph        macro
                    includebin ../.mods/SYS/UmeSymbols16.img,\1,\2*8+2
                    fcb       $99
                    includebin ../.mods/SYS/UmeSymbols16.img,\1+\2*8+3,7
                    fcb       $99
                    includebin ../.mods/SYS/UmeSymbols16.img,\1+\2*8+11,128-(\2*8+11)
                    endm
Note128Up           Note128Glyph $2244,12
Note128Down         Note128Glyph $2644,1        Note128Up+128
                    Note128Glyph $2044,12
                    Note128Glyph $2444,1
Note128End          equ       *                   Note128Up+512
Rest128             fdb       $0300,$0780,$0380,$0700,$0F00,$0700,$0E00,$1E00
                    fdb       $0E00,$1C00,$3C00,$1C00,$1800,$1000,$3000,$2000
dnota               pshs      u
                    leas      -8,s
                    ldb       <arg2
                    clra
                    std       4,s
                    ldb       <arg0
                    clra
                    andb      #$01
                    std       2,s
                    bne       dnota_1
                    ldb       <arg1
                    sex
                    std       <lastnrx
                    ldb       <arg4
                    clra
                    std       <lastaffy
* The pitch modifier is drawn last, at the end of dnota.
dnota_1               equ       *
dnota_3               ldb       <arg0
                    andb      #$38                articulation only; exclude 128th-note flag
                    clra
                    asra
                    rorb
                    asra
                    rorb
                    asra
                    rorb
                    std       ,s
                    aslb
                    rola
                    ldx       #$0200
                    leax      d,x
                    ldu       ,x
                    stu       -2,s
                    beq       dnota_5
                    ldd       ,s
                    cmpd      #$0003
                    bne       dnota_4
                    leax      >L1DB6,pcr
                    pshs      x
                    ldd       #$0001
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    ldb       <arg1
                    sex
                    addd      #$FFFF
                    pshs      a,b
                    lbsr      dyna1
                    leas      8,s
dnota_4               ldd       2,s
                    pshs      a,b
                    pshs      u
                    ldd       #$000D
                    pshs      a,b
                    ldd       10,s
                    addd      #$0007
                    pshs      a,b
                    ldb       <arg1
                    sex
                    addd      #$FFFF
                    pshs      a,b
                    lbsr      put1
                    leas      10,s
dnota_5               ldb       <arg3
                    sex
                    pshs      a,b
                    ldd       #$0005
                    lbsr      Asr16
                    clra
                    andb      #$07
                    std       ,s
                    cmpd      #$0002
                    beq       dnota_8
                    ldb       <arg0
                    clra
                    andb      #$02
                    beq       dnota_6
                    ldd       ,s
                    addd      #$0005
                    std       ,s
                    ldd       #$0006
                    bra       dnota_7
dnota_6               ldd       #$FFFD
dnota_7               addd      4,s
                    std       6,s
                    ldd       2,s
                    pshs      a,b
                    ldd       2,s
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$116D
                    leax      d,x
                    pshs      x
                    ldd       #$0004
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    ldb       <arg1
                    sex
                    pshs      a,b
                    lbsr      put2
                    leas      10,s
dnota_8               ldb       <arg3
                    sex
                    asra
                    rorb
                    asra
                    rorb
                    clra
                    andb      #$07
                    std       ,s
                    ldb       <arg0
                    clra
                    andb      #$04
                    beq       dnota_9
                    ldd       ,s
                    cmpd      #$0003
                    ble       dnota_9
                    ldd       #$0003
                    std       ,s
dnota_9               ldb       <arg0
                    clra
                    andb      #$02
                    beq       dnota_10
                    ldd       ,s
                    addd      #$0008
                    std       ,s
                    ldd       #$0002
                    bra       dnota_11
dnota_10               ldd       #$000D
dnota_11               addd      4,s
                    std       6,s
                    ldd       2,s
                    pshs      a,b
                    ldd       2,s
                    aslb
                    rola
                    ldx       #$01E0
                    leax      d,x
                    ldd       ,x
                    pshs      d
                    lda       <arg0
                    bita      #Note128Bit
                    beq       nrglyph@
                    leax      Note128Up,pcr
                    bita      #$02
                    beq       nrptr@
                    leax      Note128Down,pcr
nrptr@              bita      #$04                no-flags variant keeps its red notehead
                    beq       nrstore@
                    leax      256,x
nrstore@            stx       ,s
nrglyph@            equ       *
                    ldd       #$0010
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    ldb       <arg1
                    sex
                    pshs      a,b
                    lbsr      put2
                    leas      10,s
                    ldd       2,s
                    pshs      a,b
                    ldb       <arg4
                    clra
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    ldb       <arg1
                    sex
                    pshs      a,b
                    lbsr      ledger
                    leas      8,s
* The pitch modifier last: the accidental strip (a natural, dyna1) and glyph (put1 at column x+1) go down
* over the head, stem, flags and ledger lines, always transparent - FrOpaque is parked in 6,s (free here)
* and put back afterwards; the toolbox draws its note icons with it set.
                    ldb       >FrOpaque
                    stb       6,s
                    clr       >FrOpaque
                    ldb       <arg3
                    clra
                    andb      #$03
                    std       ,s
                    beq       dnota_pm@
                    ldd       ,s
                    cmpd      #$0003
                    bne       dnota_2
                    leax      >L1DB2,pcr
                    pshs      x
                    ldd       #$0003
                    pshs      a,b
                    ldd       8,s
                    addd      #$FFFE
                    pshs      a,b
                    ldb       <arg1
                    sex
                    addd      #$0001
                    pshs      a,b
                    lbsr      dyna1
                    leas      8,s
dnota_2               ldd       2,s
                    pshs      a,b
                    ldd       2,s
                    pshs      a,b
                    ldd       #$0006
                    lbsr      Mul16
                    ldx       #$1155
                    leax      d,x
                    pshs      x
                    ldd       #$0006
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    ldb       <arg1
                    sex
                    addd      #$0001
                    pshs      a,b
                    lbsr      put1
                    leas      10,s
dnota_pm@           ldb       6,s
                    stb       >FrOpaque
                    leas      8,s
                    puls      u,pc
drsta               pshs      a,b,x,y,u
                    ldb       <arg2
                    clra
                    std       4,s
                    ldb       <arg0
                    clra
                    andb      #$01
                    std       ,s
                    bne       drsta_1
                    ldb       <arg1
                    sex
                    std       <lastnrx
                    ldb       <arg2
                    clra
                    std       <lastaffy
drsta_1               ldb       <arg3
                    clra
                    andb      #$03
                    std       2,s
                    beq       drsta_3
                    ldd       2,s
                    cmpd      #$0003
                    bne       drsta_2
                    leax      >L1DB8,pcr
                    pshs      x
                    ldd       #$0003
                    pshs      a,b
                    ldd       8,s
                    addd      #$FFFE
                    pshs      a,b
                    ldb       <arg1
                    sex
                    addd      #$0001
                    pshs      a,b
                    lbsr      dyna1
                    leas      8,s
drsta_2               ldd       ,s
                    pshs      a,b
                    ldd       4,s
                    pshs      a,b
                    ldd       #$0006
                    lbsr      Mul16
                    ldx       #$1155
                    leax      d,x
                    pshs      x
                    ldd       #$0006
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    ldb       <arg1
                    sex
                    addd      #$0001
                    pshs      a,b
                    lbsr      put1
                    leas      10,s
drsta_3               ldd       ,s
                    pshs      a,b
                    ldb       <arg3
                    sex
                    asra
                    rorb
                    asra
                    rorb
                    clra
                    andb      #$07
                    aslb
                    rola
                    ldx       #$01D0
                    leax      d,x
                    ldd       ,x
                    pshs      d
                    lda       <arg0
                    bita      #Note128Bit
                    beq       rrglyph@
                    leax      Rest128,pcr
                    stx       ,s
rrglyph@            equ       *
                    ldd       #$0010
                    pshs      a,b
                    ldd       10,s
                    addd      #$0008
                    pshs      a,b
                    ldb       <arg1
                    sex
                    pshs      a,b
                    lbsr      put2
                    leas      10,s
                    leas      6,s
                    puls      u,pc
drawnr               pshs      u
                    ldb       <$11,s
                    stb       <arg0
                    ldd       6,s
                    stb       <arg1
                    ldd       8,s
                    stb       <arg2
                    ldb       [<$04,s]
                    sex
                    aslb
                    rola
                    aslb
                    rola
                    pshs      a,b
                    ldx       6,s
                    ldb       1,x
                    sex
                    ora       ,s+
                    orb       ,s+
                    stb       <arg3
                    ldx       4,s
                    ldb       2,x
                    cmpb      #$20
                    bne       drawnr_1
                    lbsr      drsta
                    bra      drawnr_4
drawnr_1               ldb       <arg3
                    sex
                    pshs      a,b
                    ldx       6,s
                    ldb       4,x
                    sex
                    pshs      a,b
                    ldd       #$0005
                    lbsr      Lsl16
                    ora       ,s+
                    orb       ,s+
                    stb       <arg3
                    ldd       10,s
                    stb       <arg4
                    ldb       <arg0
                    sex
                    pshs      a,b
                    ldx       6,s
                    ldb       3,x
                    sex
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    ora       ,s+
                    orb       ,s+
                    stb       <arg0
                    ldb       13,s
                    beq       drawnr_2
                    ldb       <arg0
                    sex
                    orb       #$02
                    stb       <arg0
drawnr_2               ldb       15,s
                    beq       drawnr_3
                    ldb       <arg0
                    sex
                    orb       #$04
                    stb       <arg0
drawnr_3               lbsr      dnota
drawnr_4               puls      u,pc
drawart               pshs      u
                    ldd       10,s
                    cmpd      #$0002
                    bne       drawart_1
                    puls      u,pc
drawart_1               ldb       5,s
                    sex
                    pshs      a,b
                    ldb       15,s
                    beq       drawart_2
                    ldd       #$0005
                    bra       drawart_3
drawart_2               clra
                    clrb
drawart_3               addd      12,s
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$116D
                    leax      d,x
                    pshs      x
                    ldd       #$0004
                    pshs      a,b
                    ldb       <$13,s
                    beq       drawart_4
                    ldd       #$0006
                    bra       drawart_5
drawart_4               ldd       #$FFFD
drawart_5               addd      14,s
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    lbsr      put2
                    lbra      ledger_6
* ledger: draws (or, with set = 0, erases) a note's ledger lines - hline above the staff, the one-bit rows
* L1DBC/L1DBF below it - after the note; while drawing, FrUnder puts them behind the note in SprInk.
ledger               pshs      u
                    leas      -10,s
                    ldb       <$15,s              drawing (not erasing)?
                    beq       l1509a@
                    inc       <FrUnder
l1509a@             ldd       <$10,s
                    subd      <$12,s
                    std       8,s
                    ldd       14,s
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    addd      #$FFFE
                    std       2,s
                    ldd       14,s
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    addd      #$000B
                    std       ,s
                    ldd       8,s
                    cmpd      #$FFFE
                    bge      ledger_3
                    ldd       8,s
                    nega
                    negb
                    sbca      #$00
                    asra
                    rorb
                    asra
                    rorb
                    std       6,s
                    ldd       <$12,s
                    addd      #$FFFC
                    bra       ledger_2
ledger_1               ldb       <$15,s
                    sex
                    pshs      a,b
                    leax      >L1DBC,pcr
                    pshs      x
                    ldd       #$0001
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    ldd       <$16,s
                    addd      #$FFFF
                    pshs      a,b
                    lbsr      put2
                    leas      10,s
                    ldb       <$15,s
                    sex
                    pshs      a,b
                    leax      >L1DBF,pcr
                    pshs      x
                    ldd       #$0001
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    ldd       <$16,s
                    addd      #$0001
                    pshs      a,b
                    lbsr      put1
                    leas      10,s
                    ldd       4,s
                    subd      #$0004
ledger_2               std       4,s
                    ldd       6,s
                    addd      #$FFFF
                    std       6,s
                    bge       ledger_1
                    bra       ledger_6
ledger_3               ldd       8,s
                    cmpd      #$0012
                    ble       ledger_6
                    ldd       8,s
                    addd      #$FFF0
                    asra
                    rorb
                    asra
                    rorb
                    std       6,s
                    ldd       <$12,s
                    addd      #$0014
                    bra       ledger_5
ledger_4               ldb       <$15,s
                    sex
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    ldd       4,s
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    lbsr      hline
                    leas      8,s
                    ldd       4,s
                    addd      #$0004
ledger_5               std       4,s
                    ldd       6,s
                    addd      #$FFFF
                    std       6,s
                    bge       ledger_4
ledger_6               clr       <FrUnder
                    leas      10,s
                    puls      u,pc
drawbcd               pshs      a,b,x,u
                    ldd       12,s
                    addd      #$0005
                    std       12,s
                    ldd       8,s
                    bge       drawbcd_1
                    clra
                    clrb
                    bra       drawbcd_2
drawbcd_1               ldd       8,s
                    cmpd      #$03E7
                    ble       drawbcd_3
                    ldd       #$03E7
drawbcd_2               std       8,s
drawbcd_3               clra
                    clrb
                    std       ,s
                    std       2,s
                    bra       drawbcd_5
drawbcd_4               ldd       ,s
                    addd      #$0001
                    std       ,s
drawbcd_5               ldd       8,s
                    subd      #$0064
                    std       8,s
                    bge       drawbcd_4
                    ldd       8,s
                    addd      #$0064
                    std       8,s
                    bra       drawbcd_7
drawbcd_6               ldd       2,s
                    addd      #$0001
                    std       2,s
drawbcd_7               ldd       8,s
                    subd      #$000A
                    std       8,s
                    bge       drawbcd_6
                    ldd       8,s
                    addd      #$000A
                    std       8,s
                    ldd       ,s
                    beq       drawbcd_8
                    ldd       ,s
                    pshs      a,b
                    ldd       #$0007
                    lbsr      Mul16
                    ldx       #$1043
                    leax      d,x
                    pshs      x
                    ldd       #$0007
                    pshs      a,b
                    ldd       <$10,s
                    pshs      a,b
                    ldd       <$10,s
                    pshs      a,b
                    lbsr      dyna1
                    leas      8,s
                    ldd       12,s
                    subd      #$0006
                    std       12,s
drawbcd_8               ldd       2,s
                    bne       drawbcd_9
                    ldd       ,s
                    beq       drawbcd_10
drawbcd_9               ldd       2,s
                    pshs      a,b
                    ldd       #$0007
                    lbsr      Mul16
                    ldx       #$1043
                    leax      d,x
                    pshs      x
                    ldd       #$0007
                    pshs      a,b
                    ldd       <$10,s
                    pshs      a,b
                    ldd       <$10,s
                    pshs      a,b
                    lbsr      dyna1
                    leas      8,s
                    ldd       12,s
                    subd      #$0006
                    std       12,s
drawbcd_10               ldd       8,s
                    pshs      a,b
                    ldd       #$0007
                    lbsr      Mul16
                    ldx       #$1043
                    leax      d,x
                    pshs      x
                    ldd       #$0007
                    pshs      a,b
                    ldd       <$10,s
                    pshs      a,b
                    ldd       <$10,s
                    pshs      a,b
                    lbsr      dyna1
                    leas      8,s
                    leas      4,s
                    puls      u,pc
L16CC               equ       *
                    pshs      u
                    leas      <-$20,s
                    ldd       #$001E
                    pshs      a,b
                    ldd       <$2C,s
                    pshs      a,b
                    leax      6,s
                    pshs      x
                    lbsr      CopyBytes
                    leas      6,s
                    clra
                    clrb
                    std       <$18,s
                    std       <$10,s
                    std       8,s
                    clra
                    clrb
                    std       ,s
                    leau      <$1E,s
                    bra       drawbcd_12
drawbcd_11               ldd       ,s
                    pshs      a,b
                    leau      -2,u
                    ldd       2,u
                    ora       ,s+
                    orb       ,s+
                    std       ,s
drawbcd_12               leax      2,s
                    pshs      x
                    cmpu      ,s++
                    bhs       drawbcd_11
                    ldd       ,s
                    lbeq      drawbcd_22
                    ldd       <$24,s
                    cmpd      #$0002
                    bge      drawbcd_20
                    bra       drawbcd_16
drawbcd_13               ldd       ,s
                    pshs      a,b
                    ldd       #$0001
                    lbsr      Lsl16
                    std       ,s
                    leau      <$1E,s
                    bra       drawbcd_15
drawbcd_14               leau      -2,u
                    ldd       2,u
                    pshs      a,b
                    ldd       #$0001
                    lbsr      Lsl16
                    std       2,u
drawbcd_15               leax      2,s
                    pshs      x
                    cmpu      ,s++
                    bhs       drawbcd_14
drawbcd_16               ldd       ,s
                    bgt       drawbcd_13
                    ldd       #$FF00
                    bra       drawbcd_21
drawbcd_17               ldd       ,s
                    pshs      a,b
                    ldd       #$0001
                    lbsr      Lsr16
                    std       ,s
                    leau      <$1E,s
                    bra       drawbcd_19
drawbcd_18               leau      -2,u
                    ldd       2,u
                    pshs      a,b
                    ldd       #$0001
                    lbsr      Lsr16
                    std       2,u
drawbcd_19               leax      2,s
                    pshs      x
                    cmpu      ,s++
                    bhs       drawbcd_18
drawbcd_20               ldd       ,s
                    clra
                    andb      #$01
                    beq       drawbcd_17
                    ldd       #$00FF
drawbcd_21               std       <$18,s
                    std       <$10,s
                    std       8,s
                    ldd       #$0001
                    pshs      a,b
                    leax      4,s
                    pshs      x
                    ldd       #$000F
                    pshs      a,b
                    ldd       <$2C,s
                    pshs      a,b
                    ldd       <$2C,s
                    pshs      a,b
                    lbsr      put2
                    leas      10,s
drawbcd_22               leas      <$20,s
                    puls      u,pc
putalst               pshs      u
                    leas      -16,s
                    ldd       <$16,s
                    cmpd      #$0006
                    bgt       putalst_6
                    ldd       <$16,s
                    pshs      a,b
                    ldd       #$001E
                    lbsr      Mul16
                    ldx       #$11BD
                    leax      d,x
                    stx       2,s
                    ldd       <$16,s
                    cmpd      #$0005
                    bne       putalst_1
                    leax      >L26BA,pcr
                    stx       4,s
                    ldd       #$0019
                    std       10,s
                    ldd       #$000A
                    bra       putalst_5
putalst_1               ldd       <$14,s
                    cmpd      #$0001
                    ble       putalst_2
                    ldd       <$14,s
                    cmpd      #$004F
                    bne       putalst_3
putalst_2               leax      >L16CC,pcr
                    bra       putalst_4
putalst_3               leax      >put2,pcr
putalst_4               stx       4,s
                    ldd       #$000F
                    std       10,s
                    ldd       #$000F
putalst_5               std       8,s
                    bra      putalst_11
putalst_6               ldd       <$16,s
                    cmpd      #$0015
                    bne       putalst_7
                    ldd       #$00B8
                    pshs      a,b
                    ldd       <$16,s
                    addd      #$0001
                    pshs      a,b
                    ldd       #$0008
                    pshs      a,b
                    ldd       <$1A,s
                    pshs      a,b
                    ldd       #$0002
                    pshs      a,b
                    lbsr      bytblt
                    leas      10,s
                    lbra      putalst_17
putalst_7               ldd       <$16,s
                    pshs      a,b
                    ldd       #$0006
                    lbsr      Mul16
                    ldx       #$021F
                    leax      d,x
                    stx       ,s
                    ldb       3,x
                    sex
                    std       6,s
                    ldx       ,s
                    ldb       4,x
                    sex
                    std       8,s
                    ldx       ,s
                    ldb       5,x
                    sex
                    std       10,s
                    ldd       6,s
                    cmpd      #$0001
                    bne       putalst_8
                    leax      >put1,pcr
                    bra       putalst_10
putalst_8               ldd       6,s
                    cmpd      #$0002
                    bne       putalst_9
                    leax      >put2,pcr
                    bra       putalst_10
putalst_9               leax      >L26BA,pcr
putalst_10               tfr       x,d
                    std       4,s
                    ldx       ,s
                    ldd       1,x
                    std       2,s
putalst_11               clra
                    clrb
                    bra      putalst_16
putalst_12               ldd       14,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      Mul16
                    ldx       #staves
                    leax      d,x
                    ldd       ,x
                    std       12,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       4,s
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    ldd       <$12,s
                    addd      <$10,s
                    pshs      a,b
                    ldd       <$1C,s
                    pshs      a,b
                    jsr       [<$0E,s]
                    leas      10,s
                    ldd       <$18,s
                    beq       putalst_15
                    ldd       <$16,s
                    cmpd      #$0005
                    bne       putalst_13
                    ldd       12,s
                    addd      #$0012
                    pshs      a,b
                    ldd       <$16,s
                    addd      #$0001
                    bra       putalst_14
putalst_13               ldd       12,s
                    addd      #$FFFA
                    pshs      a,b
                    ldd       <$16,s
putalst_14               pshs      a,b
                    ldd       <$1C,s
                    pshs      a,b
                    lbsr      drawbcd
                    leas      6,s
putalst_15               ldd       14,s
                    addd      #$0001
putalst_16               std       14,s
                    ldd       14,s
                    cmpd      <nstaves
                    blt      putalst_12
putalst_17               leas      <$10,s
                    puls      u,pc
drawlab               pshs      u
                    leas      -3,s
                    ldb       10,s
                    stb       ,s
                    ldb       12,s
                    stb       1,s
                    clra
                    clrb
                    stb       2,s
                    ldd       #$00B7
                    pshs      a,b
                    ldd       9,s
                    addd      #$0002
                    pshs      a,b
                    ldb       <$10,s
                    beq       drawlab_1
                    ldd       #$0001
                    bra       drawlab_2
drawlab_1               clra
                    clrb
drawlab_2               addd      ,s++
                    pshs      a,b
                    ldd       #$00AE
                    pshs      a,b
                    ldd       13,s
                    pshs      a,b
                    lbsr      boxc
                    leas      8,s
                    clra
                    clrb
                    pshs      a,b
                    leax      2,s
                    pshs      x
                    ldd       #$00B1
                    pshs      a,b
                    ldd       13,s
                    addd      #$0001
                    pshs      a,b
                    lbsr      phrase
                    leas      8,s
                    leas      3,s
                    puls      u,pc
drawaccent               pshs      a,b,u
                    ldd       8,s
                    bge       drawaccent_1
                    ldd       #$002D
                    bra       drawaccent_2
drawaccent_1               ldd       #$005E
drawaccent_2               stb       ,s
                    clra
                    clrb
                    stb       1,s
                    ldd       #$0001
                    pshs      a,b
                    leax      2,s
                    pshs      x
                    ldd       #$00B3
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    lbsr      phrase
                    leas      8,s
                    leas      2,s
                    puls      u,pc
drawtmp               pshs      u
                    ldd       #$00B3
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    ldd       10,s
                    clra
                    lbra      drprtevt_3
drawclk               pshs      u
                    ldd       #$0001
                    pshs      a,b
                    leax      >L1DC1,pcr
                    pshs      x
                    ldd       #$00B3
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    lbsr      phrase
                    leas      8,s
                    clra
                    clrb
                    pshs      a,b
                    ldd       8,s
                    beq       drawclk_1
                    leax      >L1DC3,pcr
                    bra       drawclk_2
drawclk_1               leax      >L1DC5,pcr
drawclk_2               tfr       x,d
                    pshs      a,b
                    ldd       #$00AE
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    lbsr      phrase
                    lbra      drlevel_2
drsysevt               pshs      u
                    ldd       #$0001
                    pshs      a,b
                    leax      >L1DC7,pcr
                    pshs      x
                    ldd       10,s
                    cmpd      #$0009
                    ble       drsysevt_1
                    ldd       #$0008
                    bra       drsysevt_2
drsysevt_1               ldd       #$0005
drsysevt_2               pshs      a,b
                    ldd       #$00B8
                    subd      ,s++
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    lbsr      phrase
                    leas      8,s
                    ldd       6,s
                    lblt      drprtevt_5
                    ldd       6,s
                    cmpd      #$0009
                    ble       drsysevt_3
                    ldd       #$0005
                    bra       drsysevt_4
drsysevt_3               ldd       #$0008
drsysevt_4               pshs      a,b
                    ldd       #$00B8
                    subd      ,s++
                    pshs      a,b
                    ldd       6,s
                    addd      #$0001
                    pshs      a,b
                    ldd       10,s
                    lbra      drprtevt_3
drawcres               pshs      u
                    leas      -5,s
                    ldd       #$0063
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       <$11,s
                    pshs      a,b
                    lbsr      clamp
                    leas      6,s
                    std       13,s
                    ldd       15,s
                    cmpd      #$0002
                    bge       drawcres_1
                    ldd       #$0001
                    bra       drawcres_2
drawcres_1               clra
                    clrb
drawcres_2               stb       ,s
                    beq       drawcres_5
                    ldd       #$0001
                    pshs      a,b
                    ldd       <$11,s
                    beq       drawcres_3
                    leax      >L1DC9,pcr
                    bra       drawcres_4
drawcres_3               leax      >L1DCB,pcr
drawcres_4               tfr       x,d
                    pshs      a,b
                    ldd       #$00B3
                    pshs      a,b
                    ldd       15,s
                    pshs      a,b
                    lbsr      phrase
                    leas      8,s
                    ldd       11,s
                    pshs      a,b
                    ldd       11,s
                    addd      #$0001
                    pshs      a,b
                    bsr      drawgenv
                    leas      4,s
                    ldd       #$0020
                    bra       drawcres_7
drawcres_5               ldd       11,s
                    clra
                    pshs      a,b
                    leax      >L1DCD,pcr
                    pshs      x
                    ldx       #FrNumBuf           the number text in its own 8 bytes
                    pshs      x
                    lbsr      sprintf
                    leas      6,s
                    ldd       #$0001
                    pshs      a,b
                    ldx       #FrNumBuf
                    pshs      x
                    ldd       #$00B3
                    pshs      a,b
                    ldd       15,s
                    pshs      a,b
                    lbsr      phrase
                    leas      8,s
                    ldd       15,s
                    cmpd      #$0003
                    bne       drawcres_6
                    ldd       #$0052
                    bra       drawcres_7
drawcres_6               ldd       #$0041
drawcres_7               stb       >FrNumBuf           the letter, then the number after it
                    ldd       13,s
                    pshs      a,b
                    leax      >L1DD1,pcr
                    pshs      x
                    ldx       #FrNumBuf+1
                    pshs      x
                    lbsr      sprintf
                    leas      6,s
                    clra
                    clrb
                    pshs      a,b
                    ldx       #FrNumBuf
                    pshs      x
                    ldd       #$00AD
                    pshs      a,b
                    ldd       15,s
                    pshs      a,b
                    lbsr      phrase
                    leas      8,s
                    leas      5,s
                    puls      u,pc
drawgenv               pshs      u
                    ldd       6,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      Mul16
                    ldx       #$0E79
                    leax      d,x
                    pshs      x
                    ldd       #$0005
                    pshs      a,b
                    ldd       #$00B7
                    lbra      drlevel_1
drawks               pshs      a,b,x,y,u
                    ldd       12,s
                    bne       drawks_1
                    ldd       #$0004
                    bra       drawks_3
drawks_1               ldd       12,s
                    ble       drawks_2
                    ldd       #$0002
                    bra       drawks_3
drawks_2               ldd       12,s
                    nega
                    negb
                    sbca      #$00
                    std       12,s
                    ldd       #$0007
drawks_3               aslb
                    rola
                    ldx       #$0200
                    leax      d,x
                    ldd       ,x
                    std       ,s
                    ldd       10,s
                    subd      #$0000
                    std       10,s
                    clra
                    clrb
                    bra       drawks_5
drawks_4               ldd       2,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      Mul16
                    ldx       #staves
                    leax      d,x
                    ldd       ,x
                    addd      #$0008
                    std       4,s
                    ldd       ,s
                    pshs      a,b
                    ldd       #$000D
                    pshs      a,b
                    ldd       8,s
                    addd      #$0007
                    pshs      a,b
                    ldd       <$10,s
                    pshs      a,b
                    lbsr      dyna1
                    leas      8,s
                    ldd       4,s
                    addd      #$FFFE
                    pshs      a,b
                    ldd       12,s
                    addd      #$0001
                    pshs      a,b
                    ldd       <$10,s
                    pshs      a,b
                    lbsr      drawbcd
                    leas      6,s
                    ldd       2,s
                    addd      #$0001
drawks_5               std       2,s
                    ldd       2,s
                    cmpd      <nstaves
                    blt       drawks_4
                    lbra      drprtevt_4
drawts               pshs      a,b,x,y,u
                    ldd       10,s
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    std       ,s
                    clra
                    clrb
                    lbra      drawts_6
drawts_1               ldd       4,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      Mul16
                    ldx       #staves
                    leax      d,x
                    ldd       ,x
                    std       2,s
                    clra
                    clrb
                    pshs      a,b
                    ldd       4,s
                    addd      #$0008
                    pshs      a,b
                    ldd       4,s
                    addd      #$FFFE
                    pshs      a,b
                    ldd       6,s
                    addd      #$FFFB
                    pshs      a,b
                    lbsr      hline
                    leas      8,s
                    clra
                    clrb
                    pshs      a,b
                    ldd       4,s
                    addd      #$0008
                    pshs      a,b
                    ldd       4,s
                    addd      #$000D
                    pshs      a,b
                    ldd       6,s
                    addd      #$000A
                    pshs      a,b
                    lbsr      hline
                    leas      8,s
                    ldd       12,s
                    cmpd      #$0009
                    ble       drawts_2
                    ldd       #$0010
                    bra       drawts_3
drawts_2               ldd       #$000A
drawts_3               addd      2,s
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    ldd       <$10,s
                    pshs      a,b
                    lbsr      drawbcd
                    leas      6,s
                    ldd       14,s
                    bge       drawts_4
                    clra
                    clrb
                    std       14,s
drawts_4               ldd       14,s
                    cmpd      #$0009
                    ble       drawts_5
                    ldd       #$000A
                    std       14,s
drawts_5               ldd       14,s
                    pshs      a,b
                    ldd       #$0007
                    lbsr      Mul16
                    ldx       #$1043
                    leax      d,x
                    pshs      x
                    ldd       #$0007
                    pshs      a,b
                    ldd       6,s
                    addd      #$0007
                    pshs      a,b
                    ldd       <$10,s
                    pshs      a,b
                    lbsr      dyna1
                    leas      8,s
                    ldd       4,s
                    addd      #$0001
drawts_6               std       4,s
                    ldd       4,s
                    cmpd      <nstaves
                    lblt      drawts_1
                    lbra      drprtevt_4
drinstr               pshs      u
                    leax      >L1DD4,pcr
                    pshs      x
                    ldd       #$0005
                    pshs      a,b
                    ldd       10,s
                    addd      #$0002
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    lbsr      dyna1
                    leas      8,s
                    ldd       8,s
                    cmpd      #$0009
                    ble      drprtevt_1
                    ldd       #$0001
                    bra      drprtevt_2
drmchop               pshs      u
                    ldd       8,s
                    addd      #$0001
                    std       8,s
                    leax      >L1DDA,pcr
                    pshs      x
                    ldd       #$0005
                    pshs      a,b
                    ldd       10,s
                    addd      #$0002
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    lbsr      dyna1
                    leas      8,s
                    ldd       8,s
                    cmpd      #$0009
                    ble       drprtevt_1
                    ldd       #$0001
                    bra       drprtevt_2
drprtevt               pshs      u
                    leax      >L1DE0,pcr
                    pshs      x
                    ldd       #$0005
                    pshs      a,b
                    ldd       10,s
                    addd      #$0002
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    lbsr      dyna1
                    leas      8,s
                    ldd       8,s
                    blt       drprtevt_5
                    ldd       8,s
                    cmpd      #$0009
                    ble       drprtevt_1
                    ldd       #$0001
                    bra       drprtevt_2
drprtevt_1               ldd       #$FFFE
drprtevt_2               addd      6,s
                    pshs      a,b
                    ldd       6,s
                    addd      #$0001
                    pshs      a,b
                    ldd       12,s
drprtevt_3               pshs      a,b
                    lbsr      drawbcd
drprtevt_4               leas      6,s
drprtevt_5               puls      u,pc
drlevel               pshs      u
                    ldd       8,s
                    clra
                    andb      #$07
                    std       8,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      Mul16
                    ldx       #$0E79
                    leax      d,x
                    pshs      x
                    ldd       #$0005
                    pshs      a,b
                    ldd       10,s
                    addd      #$0002
drlevel_1               pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    lbsr      dyna2
drlevel_2               leas      8,s
                    puls      u,pc
* msgImageReadErr: 'Nimg', imgload's no-symbols message; the bytes after it are strips, short strings and formats
msgImageReadErr     fcc       /Nimg/              short, for the size ceiling
                    fcb       $0D,$00
L1DB2               equ       *
                    fcb       $00,$00,$00,$00
L1DB6               equ       *
                    fcb       $00,$00
L1DB8               equ       *
                    fcb       $00,$00,$00,$00
L1DBC               equ       *
                    fcb       $03,$FF,$00
L1DBF               equ       *
                    fcb       $F0
                    fcb       $00
L1DC1               equ       *
                    fcb       $43,$00
L1DC3               equ       *
                    fcb       $2B,$00
L1DC5               equ       *
                    fcb       $2D,$00
L1DC7               equ       *
                    fcb       $45
                    fcb       $00
L1DC9               equ       *
                    fcb       $3C,$00
L1DCB               equ       *
                    fcb       $3E,$00
L1DCD               equ       *
                    fcb       $25,$32,$64
                    fcb       $00
L1DD1               equ       *
                    fcb       $25,$64,$00
L1DD4               equ       *
                    fcb       $7E,$18,$18,$18
                    fcb       $7E,$00
L1DDA               equ       *
                    fcb       $66,$7E,$66,$66,$66
                    fcb       $00
L1DE0               equ       *
                    fcb       $7E,$60,$7C,$60,$7E
                    fcb       $00
dfstaff               pshs      a,b,u
                    ldd       6,s
                    cmpd      #$0007
                    lbge      grafstaff_3
                    ldd       <nstaves
                    addd      #$FFFF
                    cmpd      6,s
                    bge       dfstaff_1
                    ldd       6,s
                    addd      #$0001
                    std       <nstaves
dfstaff_1               ldd       6,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      Mul16
                    ldx       #staves
                    leax      d,x
                    stx       ,s
                    ldd       8,s
                    ldx       ,s
                    std       2,x
                    ldd       10,s
                    std       [,s]
                    lbra      grafstaff_3
fgstaff               pshs      u
                    ldd       4,s
                    cmpd      <nstaves
                    blt       fgstaff_1
                    puls      u,pc
fgstaff_1               ldd       4,s
                    std       <nstaves
                    puls      u,pc
dfpart               pshs      a,b,u
                    ldd       6,s
                    lble      grafstaff_3         a part number below 1 would write under the parts table
                    ldd       6,s
                    cmpd      #$0010
                    lbgt      grafstaff_3
                    ldd       6,s
                    cmpd      <nparts
                    ble       dfpart_1
                    ldd       6,s
                    std       <nparts
dfpart_1               ldd       6,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #parts
                    leax      d,x
                    stx       ,s
                    ldd       8,s
                    std       [,s]
                    ldd       10,s
                    ldx       ,s
                    std       2,x
                    lbra      grafstaff_3
fgpart               pshs      u
                    ldd       4,s
                    beq       fgpart_1
                    ldd       4,s
                    cmpd      <nparts
                    ble       fgpart_2
fgpart_1               puls      u,pc
fgpart_2               ldd       4,s
                    addd      #$FFFF
                    std       <nparts
                    puls      u,pc
getstaff               pshs      u
                    ldd       4,s
                    cmpd      <nstaves
                    blt       getstaff_1
                    ldd       <nstaves
                    addd      #$FFFF
                    std       4,s
getstaff_1               ldd       4,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      Mul16
                    ldx       #staves
                    leax      d,x
                    ldd       2,x
                    aslb
                    rola
                    ldx       #$02C7
                    leax      d,x
                    ldd       ,x
                    std       [<$08,s]
                    ldd       4,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      Mul16
                    ldx       #staves
                    leax      d,x
                    ldd       ,x
                    std       [<$06,s]
                    puls      u,pc
grafstaff               pshs      a,b,u
                    ldd       6,s
                    cmpd      #$0001
                    blt       grafstaff_1
                    ldd       6,s
                    cmpd      <nparts
                    ble       grafstaff_2
grafstaff_1               ldd       <nparts
                    std       6,s
grafstaff_2               ldd       6,s
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
                    std       [<$0A,s]
                    ldd       ,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      Mul16
                    ldx       #staves
                    leax      d,x
                    ldd       ,x
                    std       [<$08,s]
                    ldd       ,s
grafstaff_3               leas      2,s
                    puls      u,pc
bline               pshs      u
                    leas      -7,s
                    ldd       11,s
                    cmpd      #$0008
                    bge       bline_1
                    ldd       #$0008
                    bra       bline_2
bline_1               ldd       11,s
                    cmpd      #$0278
                    blt       bline_3
                    ldd       #$0278
bline_2               std       11,s
bline_3               ldd       15,s
                    cmpd      #$0008
                    bge       bline_4
                    ldd       #$0008
                    bra       bline_5
bline_4               ldd       15,s
                    cmpd      #$0278
                    blt       bline_6
                    ldd       #$0278
bline_5               std       15,s
bline_6               ldd       13,s
                    cmpd      #$0002
                    bge       bline_7
                    ldd       #$0002
                    bra       bline_8
bline_7               ldd       13,s
                    cmpd      #$00BE
                    blt       bline_9
                    ldd       #$00BE
bline_8               std       13,s
bline_9               ldd       <$11,s
                    cmpd      #$0002
                    bge       bline_10
                    ldd       #$0002
                    bra       bline_11
bline_10               ldd       <$11,s
                    cmpd      #$00BE
                    blt       bline_12
                    ldd       #$00BE
bline_11               std       <$11,s
bline_12               ldd       <$11,s
                    subd      13,s
                    std       >FrData_bdelty
                    ldd       15,s
                    subd      11,s
                    std       >FrData_bdeltx
                    bge       bline_13
                    ldd       11,s
                    std       5,s
                    ldd       15,s
                    std       11,s
                    ldd       5,s
                    std       15,s
                    ldd       >FrData_bdeltx
                    nega
                    negb
                    sbca      #$00
                    std       >FrData_bdeltx
                    ldd       >FrData_bdelty
                    nega
                    negb
                    sbca      #$00
                    std       >FrData_bdelty
bline_13               ldd       >FrData_bdelty
                    blt       bline_14
                    ldd       #$FFB0
                    bra       bline_15
bline_14               ldd       >FrData_bdelty
                    nega
                    negb
                    sbca      #$00
                    std       >FrData_bdelty
                    ldd       #$0050
bline_15               std       <dy
                    ldd       >FrData_bdelty
                    cmpd      >FrData_bdeltx
                    ble       bline_16
                    ldd       >FrData_bdeltx
                    std       >FrData_bdelty
bline_16               ldd       11,s
                    std       >FrData_bx1
                    ldd       13,s
                    std       >FrData_by1
                    ldd       <dy
                    std       >FrData_bdy
                    ldd       >FrData_bdelty
                    addd      #$0001
                    std       >FrData_bdelty
                    ldd       >FrData_bdeltx
                    addd      #$0001
                    std       >FrData_bdeltx
                    ldd       <$13,s
                    stb       >thick
                    ldd       >FrData_bdeltx
                    nega
                    negb
                    sbca      #$00
                    std       3,s
* FrData_bbp keeps the start as a picture OFFSET (the window moves); U is the eight-dot group whose dot the
* mask byte at ,s selects: a plot is OrExp of that mask, and the next group is four bytes on.
                    ldd       #$00BF
                    subd      13,s
                    pshs      a,b
                    ldd       #$0140
                    lbsr      Mul16
                    pshs      a,b
                    ldd       13,s
                    lsra
                    rorb
                    andb      #$FC
                    addd      ,s++
                    std       >FrData_bbp
                    lbsr      ScrAddr
                    ldd       #$0040
                    stb       ,s
                    ldd       >FrData_bdeltx
                    std       1,s
                    bra      bline_23
bline_17               ldb       ,s
                    lbsr      OrExp
                    ldb       >thick
                    beq       bline_18
                    lbsr      ScrRowUp
                    ldb       ,s
                    lbsr      OrExp
                    lbsr      ScrRowDn
bline_18               ldb       ,s
                    bge       bline_19
                    ldd       #$0040
                    bra       bline_20
bline_19               ldb       ,s
                    sex
                    pshs      a,b
                    ldd       #$0001
                    lbsr      Asr16
                    stb       ,s
                    bne       bline_21
                    leau      4,u
                    ldd       #$0080
bline_20               stb       ,s
bline_21               ldd       3,s
                    addd      >FrData_bdelty
                    std       3,s
                    blt       bline_23
                    ldd       3,s
                    subd      >FrData_bdeltx
                    std       3,s
                    ldd       1,s
                    beq       bline_22
                    ldb       ,s
                    lbsr      OrExp
                    ldb       >thick
                    beq       bline_22
                    lbsr      ScrRowUp
                    ldb       ,s
                    lbsr      OrExp
                    lbsr      ScrRowDn
bline_22               tst       <dy                the sign of dy (the one-bit +80/-80 step) picks the direction: + down, - up
                    bmi       *+7
                    lbsr      ScrRowDn
                    bra       *+5
                    lbsr      ScrRowUp
bline_23               ldd       1,s
                    addd      #$FFFF
                    std       1,s
                    bge      bline_17
                    lbra      bsegline_9
bagnline               pshs      u
                    leas      -5,s
                    ldd       9,s
                    pshs      a,b
                    ldd       #$0140
                    lbsr      Mul16
                    pshs      a,b
                    ldd       >FrData_bbp
                    subd      ,s++
                    lbsr      ScrAddr
                    ldd       >FrData_bdy
                    std       <dy
                    ldd       >FrData_bdeltx
                    nega
                    negb
                    sbca      #$00
                    std       3,s
                    ldd       #$0040
                    stb       ,s
                    ldd       >FrData_bdeltx
                    std       1,s
                    bra      bagnline_7
bagnline_1               ldb       ,s
                    lbsr      OrExp
                    ldb       >thick
                    beq       bagnline_2
                    lbsr      ScrRowUp
                    ldb       ,s
                    lbsr      OrExp
                    lbsr      ScrRowDn
bagnline_2               ldb       ,s
                    bge       bagnline_3
                    ldd       #$0040
                    bra       bagnline_4
bagnline_3               ldb       ,s
                    sex
                    pshs      a,b
                    ldd       #$0001
                    lbsr      Asr16
                    stb       ,s
                    bne       bagnline_5
                    leau      4,u
                    ldd       #$0080
bagnline_4               stb       ,s
bagnline_5               ldd       3,s
                    addd      >FrData_bdelty
                    std       3,s
                    blt       bagnline_7
                    ldd       3,s
                    subd      >FrData_bdeltx
                    std       3,s
                    ldd       1,s
                    beq       bagnline_6
                    ldb       ,s
                    lbsr      OrExp
                    ldb       >thick
                    beq       bagnline_6
                    lbsr      ScrRowUp
                    ldb       ,s
                    lbsr      OrExp
                    lbsr      ScrRowDn
bagnline_6               tst       <dy                the sign of dy (the one-bit +80/-80 step) picks the direction: + down, - up
                    bmi       *+7
                    lbsr      ScrRowDn
                    bra       *+5
                    lbsr      ScrRowUp
bagnline_7               ldd       1,s
                    addd      #$FFFF
                    std       1,s
                    bge      bagnline_1
                    leas      5,s
                    puls      u,pc
bsegline               pshs      u
                    leas      -7,s
                    ldd       11,s
                    pshs      a,b
                    ldd       #$0140
                    lbsr      Mul16
                    pshs      a,b
                    ldd       >FrData_bbp
                    subd      ,s++
                    lbsr      ScrAddr
                    ldd       >FrData_bdy
                    std       <dy
                    ldd       >FrData_bdeltx
                    nega
                    negb
                    sbca      #$00
                    std       5,s
                    ldd       #$0040
                    stb       ,s
                    ldd       13,s
                    subd      >FrData_bx1
                    std       1,s
                    ldd       15,s
                    subd      >FrData_bx1
                    addd      #$0001
                    std       3,s
                    bra      bsegline_8
bsegline_1               ldd       1,s
                    bgt       bsegline_2
                    ldb       ,s
                    lbsr      OrExp
                    ldb       >thick
                    beq       bsegline_2
                    lbsr      ScrRowUp
                    ldb       ,s
                    lbsr      OrExp
                    lbsr      ScrRowDn
bsegline_2               ldb       ,s
                    bge       bsegline_3
                    ldd       #$0040
                    bra       bsegline_4
bsegline_3               ldb       ,s
                    sex
                    pshs      a,b
                    ldd       #$0001
                    lbsr      Asr16
                    stb       ,s
                    bne       bsegline_5
                    leau      4,u
                    ldd       #$0080
bsegline_4               stb       ,s
bsegline_5               ldd       5,s
                    addd      >FrData_bdelty
                    std       5,s
                    blt       bsegline_7
                    ldd       5,s
                    subd      >FrData_bdeltx
                    std       5,s
                    ldd       3,s
                    beq       bsegline_6
                    ldd       1,s
                    bgt       bsegline_6
                    ldb       ,s
                    lbsr      OrExp
                    ldb       >thick
                    beq       bsegline_6
                    lbsr      ScrRowUp
                    ldb       ,s
                    lbsr      OrExp
                    lbsr      ScrRowDn
bsegline_6               tst       <dy                the sign of dy (the one-bit +80/-80 step) picks the direction: + down, - up
                    bmi       *+7
                    lbsr      ScrRowDn
                    bra       *+5
                    lbsr      ScrRowUp
bsegline_7               ldd       1,s
                    addd      #$FFFF
                    std       1,s
bsegline_8               ldd       3,s
                    addd      #$FFFF
                    std       3,s
                    lbge      bsegline_1
bsegline_9               leas      7,s
                    puls      u,pc
* zclamp: (v, max) returns v clamped to 0..max (negative -> 0)
zclamp           pshs      u
                    ldd       4,s
                    bge       a9@
                    clra
                    clrb
                    puls      u,pc
a9@                 ldd       4,s
                    cmpd      6,s
                    bgt       ClampRetBound
                    bra       ClampRetValue
* clamp: (v, lo, hi) returns v clamped to lo..hi
clamp         pshs      u
                    ldd       4,s
                    cmpd      6,s
                    bge       a10@
* ClampRetBound: returns the bound at 6,s; zclamp branches here for v>max, clamp falls in for v<lo
ClampRetBound       ldd       6,s
                    puls      u,pc
a10@                ldd       4,s
                    cmpd      8,s
                    ble       ClampRetValue
                    ldd       8,s
                    puls      u,pc
* ClampRetValue: returns the unclamped value at 4,s; shared tail of both zclamp and clamp
ClampRetValue       ldd       4,s
                    puls      u,pc
* grafix: sets the run flag <grafmode = 1 (MainBody; nothing reads the flag)
grafix          pshs      u
                    ldd       #$0001
                    bra       StoreRunFlag
* text: clears the run flag <grafmode (EOF/exit paths)
text          pshs      u
                    clra
                    clrb
* StoreRunFlag: common tail of grafix (D=1) and text (D=0)
StoreRunFlag        stb       <grafmode
                    puls      u,pc
* release: calls text before exit
release         pshs      u
                    bsr       text
                    puls      u,pc
* pcls: (v) fills picture rows 0-191 (61,440 bytes, through ScrAddr) with the one-bit pattern -v (0 clear, 1 = $FFFF, $AAAB = $5555 stipple)
* The pattern's low four dots (bit 3 the left one) are widened through NibTab into the fill word; $5555 gives
* alternate dots. Rows 192-239 belong to the banner and are left alone (block 7 is filled only to row 191).
pcls          pshs      u
                    clr       >FrToolUp           full-screen fill discards the old overlay
                    ldd       4,s
                    nega
                    negb
                    sbca      #$00                the one-bit pattern
                    andb      #$0F
                    lslb
                    leax      >NibTab,pcr
                    ldd       b,x
                    std       <paint                the fill word
                    clr       ,-s                 ,s = picture block 0-7
* FillScreenLoop: one picture block per pass, at the front of the window
FillScreenLoop      lda       ,s
                    lsla
                    lsla
                    lsla
                    lsla
                    lsla
                    clrb                          block * 8192
                    lbsr      ScrAddr
                    ldx       #$0400              1,024 x 8 bytes
                    lda       ,s
                    cmpa      #$07
                    bne       fsw0@
                    ldx       #$0200              block 7: 512 x 8 = rows 179-191, the picture's last
fsw0@               ldd       <paint
fsw@                std       ,u++
                    std       ,u++
                    std       ,u++
                    std       ,u++
                    leax      -1,x
                    bne       fsw@
                    inc       ,s
                    lda       ,s
                    cmpa      #$08
                    blo       FillScreenLoop
                    leas      1,s
                    puls      u,pc
* pal: (reg, color) no-op, reached from MainBody and command $87 (pala). The original printed the CoCo3 palette
* escape ESC '1' reg color, but WildBits vtio takes ESC '1' as Delete Line.
pal          rts                           nothing pushed yet, so a plain rts

* hline: (x1, x2, y, color) horizontal line in pixel coordinates: x clamped/ordered to 0..639, y outside 0..191 (y=0 bottom) draws nothing; edge bytes masked with the tables at data $02D7/$02E0, middle bytes filled with the -color pattern
* The color is a one-bit fill pattern (-1 ink, 0 paper, $AAAB gives the $5555 dotted line the menu bar uses);
* its low four dots are widened through NibTab into the byte written across the run.
hline               pshs      u
                    ldd       10,s
                    nega
                    negb
                    sbca      #$00
                    andb      #$0F
                    lslb
                    leax      >NibTab,pcr
                    tst       <FrUnder            a ledger line: the staff's gray (SprTab), behind what is there
                    beq       hl0@
                    leax      >SprTab,pcr
                    tst       >FrStaffDots
                    beq       hl0@
                    andb      #$14                index = (pattern AND $A) * 2
hl0@                ldd       b,x
                    std       <color
                    ldd       #$027F
                    pshs      a,b
                    leax      8,s
                    pshs      x
                    leax      8,s
                    pshs      x
                    lbsr      argfix
                    leas      6,s
                    ldd       8,s
                    blt       a11@
                    ldd       8,s
                    cmpd      #$00BF
                    ble       HLineBody
a11@                puls      u,pc
* HLineBody: computes byte columns <hgt/<width and the row address, then the single-byte or multi-byte cases
* A byte holds two dots: byte column x/2, in-byte index x&1 (x2's stored as (x2&1)+1). Edge masks: data
* $02D7 (dots from index i rightwards: $FF,$0F,$00) and $02E0 (dots left of index i: $00,$F0,$FF).
HLineBody           ldd       4,s
                    lsra
                    rorb
                    std       <hgt
                    ldd       4,s
                    clra
                    andb      #$01
                    std       4,s
                    ldd       6,s
                    lsra
                    rorb
                    std       <width
                    ldd       6,s
                    clra
                    andb      #$01
                    addd      #$0001
                    std       6,s
                    ldd       #$00BF
                    subd      8,s
                    pshs      a,b
                    ldd       #$0140
                    lbsr      Mul16
                    addd      <hgt
                    lbsr      ScrAddr
                    ldd       <hgt
                    cmpd      <width
                    bne      b12@
                    ldd       10,s
                    beq       a12@
                    ldb       ,u
                    sex
                    pshs      a,b
                    ldd       6,s
                    ldx       #$02D7
                    leax      d,x
                    ldb       ,x
                    sex
                    pshs      a,b
                    ldd       10,s
                    ldx       #$02E0
                    leax      d,x
                    ldb       ,x
                    sex
                    anda      ,s+
                    andb      ,s+
                    anda      <color
                    andb      <color+1
                    ora       ,s+
                    orb       ,s+
                    lbra      i12@
a12@                ldb       ,u
                    sex
                    pshs      a,b
                    ldd       6,s
                    ldx       #$02E0
                    leax      d,x
                    ldb       ,x
                    sex
                    pshs      a,b
                    ldd       10,s
                    ldx       #$02D7
                    leax      d,x
                    ldb       ,x
                    sex
                    ora       ,s+
                    orb       ,s+
                    bra      h12@
b12@                ldd       10,s
                    beq       c12@
                    ldb       ,u
                    sex
                    pshs      a,b
                    ldd       6,s
                    ldx       #$02D7
                    leax      d,x
                    ldb       ,x
                    sex
                    anda      <color
                    andb      <color+1
                    ora       ,s+
                    orb       ,s+
                    bra       d12@
c12@                ldb       ,u
                    sex
                    pshs      a,b
                    ldd       6,s
                    ldx       #$02E0
                    leax      d,x
                    ldb       ,x
                    sex
                    anda      ,s+
                    andb      ,s+
d12@                bsr       HUnder
                    stb       ,u
                    leau      1,u
                    ldd       <width
                    subd      <hgt
                    std       <col
                    bra       f12@
* e12@: fills the bytes between the two edge bytes with the color byte (through HUnder)
e12@                ldd       <color
                    bsr       HUnder
                    stb       ,u+
f12@                ldd       <col
                    addd      #$FFFF
                    std       <col
                    bne       e12@
                    ldd       10,s
                    beq       g12@
                    ldb       ,u
                    sex
                    pshs      a,b
                    ldd       8,s
                    ldx       #$02E0
                    leax      d,x
                    ldb       ,x
                    sex
                    anda      <color
                    andb      <color+1
                    ora       ,s+
                    orb       ,s+
                    bra       i12@
g12@                ldb       ,u
                    sex
                    pshs      a,b
                    ldd       8,s
                    ldx       #$02D7
                    leax      d,x
                    ldb       ,x
                    sex
h12@                anda      ,s+
                    andb      ,s+
i12@                bsr       HUnder
                    stb       ,u
                    puls      u,pc
* HUnder: B = the byte hline is about to store at ,U. While FrUnder is set (ledger lines) the dots already
* inked at ,U win: B = ,U OR (B AND NOT NibMask(,U)). Keeps A, X and U.
HUnder              tst       <FrUnder
                    beq       hu9@
                    pshs      a
                    lda       ,u                  the dots there now
                    pshs      a
                    lbsr      NibMask             A = $F0/$0F/$FF where they are inked (keeps B)
                    coma
                    pshs      a
                    andb      ,s+                 the line keeps only the paper nibbles
                    orb       ,s+                 and the inked dots stay
                    puls      a
hu9@                rts
vline               pshs      u
                    ldd       #$00BF
                    pshs      a,b
                    leax      10,s
                    pshs      x
                    leax      10,s
                    pshs      x
                    lbsr      argfix
                    leas      6,s
                    ldd       4,s
                    blt       vline_1
                    ldd       4,s
                    cmpd      #$027F
                    ble       vline_2
vline_1               puls      u,pc
* s9gui: the dot is a nibble: $F0 (draw) or the mask $FF0F (erase), shifted right by four for an odd x.
vline_2               ldd       10,s
                    beq       vline_3
                    ldd       #$00F0
                    bra       vline_4
vline_3               ldd       #$FF0F
vline_4               pshs      a,b
                    ldd       6,s
                    clra
                    andb      #$01
                    lslb
                    lslb
                    lbsr      Asr16
                    std       <color
                    ldd       #$00BF
                    subd      8,s
                    pshs      a,b
                    ldd       #$0140
                    lbsr      Mul16
                    pshs      a,b
                    ldd       6,s
                    lsra
                    rorb
                    addd      ,s++
                    lbsr      ScrAddr
                    ldd       8,s
                    subd      6,s
                    addd      #$0001
                    std       <dy
                    bra       vline_8
vline_5               ldd       10,s
                    beq       vline_6
                    ldb       ,u
                    sex
                    ora       <color
                    orb       <color+1
                    bra       vline_7
vline_6               ldb       ,u
                    sex
                    anda      <color
                    andb      <color+1
vline_7               stb       ,u
                    lbsr      ScrRowDn
vline_8               ldd       <dy
                    addd      #$FFFF
                    std       <dy
                    bge       vline_5
                    puls      u,pc
* vpatdyn: (col, y1, y2, pattern) writes one byte pattern into byte column col for rows y1..y2 (clamped/ordered to 0..191); used for box sides with patterns like $18, $60, $30, $66
vpatdyn           pshs      u
                    ldd       #$00BF
                    pshs      a,b
                    leax      10,s
                    pshs      x
                    leax      10,s
                    pshs      x
                    lbsr      argfix
                    leas      6,s
                    ldd       4,s
                    blt       a13@
                    ldd       4,s
                    cmpd      #$004F
                    ble       b13@
a13@                puls      u,pc
b13@                ldb       11,s
                    sex
                    std       <color
                    ldd       8,s
                    ldx       4,s
                    lbsr      ScrPos
                    ldd       8,s
                    subd      6,s
                    addd      #$0001
                    std       <dy
                    bra       VLineTest
* VLineLoop: row loop of vpatdyn: the pattern widened and stored (PutExp), or ORed (OrExp) while FrDynaInk is set
VLineLoop           ldb       <color+1                the eight-dot pattern, widened
                    tst       >FrDynaInk
                    beq       vll1@
                    lbsr      OrExp               inked: only the pattern's set dots,
                    bra       vll2@               its paper dots leave the screen as it is
vll1@               lbsr      PutExp
vll2@               lbsr      ScrRowDn
* VLineTest: row-counter test (<dy) of VLineLoop; vpatdyn branches here after computing the start address
VLineTest           ldd       <dy
                    addd      #$FFFF
                    std       <dy
                    bge       VLineLoop
                    puls      u,pc
* put1: (col, y, rows, strip, set) 8-pixel-wide glyph column: set!=0 ORs each strip byte into the row, set=0 clears the strip bits (AND NOT)
put1          pshs      u
                    ldd       #$004F
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    lbsr      zclamp
                    leas      4,s
                    std       4,s
                    ldd       #$00BF
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    lbsr      zclamp
                    leas      4,s
                    std       6,s
                    ldx       10,s
                    lda       #$01
                    ldb       9,s
                    lbsr      SrcFix              the bank's rows, or the one-bit strip
                    stx       10,s
                    ldd       6,s
                    ldx       4,s
                    lbsr      ScrPos
                    ldb       13,s
                    beq       Strip8ClrTest
                    bra       Strip8OrTest
* Strip8OrLoop: OR row loop of put1
Strip8OrLoop        ldx       10,s
                    lbsr      Fetch8
                    stx       10,s
                    lbsr      Or4
                    lbsr      ScrRowDn
* Strip8OrTest: row-counter test of Strip8OrLoop; put1 branches here when set != 0
Strip8OrTest        ldd       8,s
                    addd      #$FFFF
                    std       8,s
                    bge       Strip8OrLoop
                    bra       DrawStrip8Ret
* Strip8ClrLoop: AND-NOT (erase) row loop of put1
Strip8ClrLoop       ldx       10,s
                    lbsr      Fetch8
                    stx       10,s
                    lbsr      Clr4
                    lbsr      ScrRowDn
* Strip8ClrTest: row-counter test of Strip8ClrLoop; put1 branches here when set = 0 (erase)
Strip8ClrTest       ldd       8,s
                    addd      #$FFFF
                    std       8,s
                    bge       Strip8ClrLoop
* DrawStrip8Ret: puls u,pc of put1; the OR loop branches here, the AND-NOT loop falls through
DrawStrip8Ret       puls      u,pc
* put2: (col, y, rows, image, set) 16-pixel-wide image: 16 rows via or2_16, 15 via or2_15, otherwise an OR loop; set=0 erases with AND NOT. Used for note heads, clefs and menu icons
put2         pshs      u
                    ldd       #$004E
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    lbsr      zclamp
                    leas      4,s
                    std       4,s
                    ldd       #$00BF
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    lbsr      zclamp
                    leas      4,s
                    std       6,s
                    ldx       10,s
                    lda       #$02
                    ldb       9,s
                    lbsr      SrcFix              the bank's rows, or the one-bit picture
                    stx       10,s
                    ldd       6,s
                    ldx       4,s
                    lbsr      ScrPos
                    ldb       13,s
                    beq      Image16ClrTest
                    ldd       8,s
                    cmpd      #$0010
                    bne       b14@
                    ldd       10,s
                    pshs      a,b
                    pshs      u
                    lbsr      or2_16
a14@                leas      4,s
                    bra      DrawImage16Ret
b14@                ldd       8,s
                    cmpd      #$000F
                    bne       Image16OrTest
                    ldd       10,s
                    pshs      a,b
                    pshs      u
                    lbsr      or2_15
                    bra       a14@
* Image16OrLoop: generic OR row loop of put2
Image16OrLoop       ldx       10,s
                    lbsr      Fetch16
                    stx       10,s
                    lbsr      Or8
                    lbsr      ScrRowDn
* Image16OrTest: row-counter test of Image16OrLoop; put2 branches here for row counts other than 16/15
Image16OrTest       ldd       8,s
                    addd      #$FFFF
                    std       8,s
                    bge       Image16OrLoop
                    bra       DrawImage16Ret
* Image16ClrLoop: AND-NOT row loop of put2
Image16ClrLoop      ldx       10,s
                    lbsr      Fetch16
                    stx       10,s
                    lbsr      Clr8
                    lbsr      ScrRowDn
* Image16ClrTest: row-counter test of Image16ClrLoop; put2 branches here when set = 0 (erase)
Image16ClrTest      ldd       8,s
                    addd      #$FFFF
                    std       8,s
                    bge       Image16ClrLoop
* DrawImage16Ret: puls u,pc of put2; the 16x16/16x15 fast paths and the OR loop all branch here
DrawImage16Ret      puls      u,pc
* dyna1: (col, y, rows, strip) stores the strip's rows into a byte column (Put4), or ORs them (Or4) while FrDynaInk is set; draws menu end caps
dyna1           pshs      u
                    ldd       #$004F
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    lbsr      zclamp
                    leas      4,s
                    std       4,s
                    ldd       #$00BF
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    lbsr      zclamp
                    leas      4,s
                    std       6,s
                    ldx       10,s
                    lda       #$01
                    ldb       9,s
                    lbsr      SrcFix
                    stx       10,s
                    ldd       6,s
                    ldx       4,s
                    lbsr      ScrPos
                    bra       PutStrip8Test
* PutStrip8Loop: row loop of dyna1
PutStrip8Loop       ldx       10,s
                    lbsr      Fetch8
                    stx       10,s
                    tst       >FrDynaInk
                    beq       ps81@
                    lbsr      Or4                 inked: the toolbox's 3 and quote strips over the CLS white
                    bra       ps82@
ps81@               lbsr      Put4
ps82@               lbsr      ScrRowDn
* PutStrip8Test: row-counter test of PutStrip8Loop; dyna1 branches here after computing the start address
PutStrip8Test       ldd       8,s
                    addd      #$FFFF
                    std       8,s
                    bge       PutStrip8Loop
                    puls      u,pc
* dyna2: (col, y, rows, image) stores 2-byte-wide image rows straight into the screen; draws the clef icons ($0EC9 + n*$36, 27 rows)
* The rows word's HIGH byte is a byte offset 0-3 from the column's first byte (two dots each), so an icon can sit
* between columns. Rows are stored (Put8), or ORed (Or8) while FrDynaInk is set.
dyna2          pshs      u
                    ldd       #$004E              78 like put2: a sixteen-dot row at column 79 would spill onto the next row
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    lbsr      zclamp
                    leas      4,s
                    std       4,s
                    ldd       #$00BF
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    lbsr      zclamp
                    leas      4,s
                    std       6,s
                    ldx       10,s
                    lda       #$02
                    ldb       9,s
                    lbsr      SrcFix
                    stx       10,s
                    ldd       6,s
                    ldx       4,s
                    lbsr      ScrPos
                    ldb       8,s                 the byte offset (the rows word's high byte)
                    leau      b,u
                    clr       8,s                 the row count alone from here
                    bra       PutStrip16Test
* PutStrip16Loop: row loop of dyna2
PutStrip16Loop      ldx       10,s
                    lbsr      Fetch16
                    stx       10,s
                    tst       >FrDynaInk
                    beq       psl1@
                    lbsr      Or8                 inked: only the picture's dots replace what is there (the drag glyph)
                    bra       psl2@
psl1@               lbsr      Put8
psl2@
                    lbsr      ScrRowDn
* PutStrip16Test: row-counter test of PutStrip16Loop; dyna2 branches here after computing the start address
PutStrip16Test      ldd       8,s
                    addd      #$FFFF
                    std       8,s
                    bge       PutStrip16Loop
                    puls      u,pc
* L26BA: disabled (rts). The original one-bit 24-dot row writer (vdgram + (191-y)*80 + col), reached only
* through putalst for 24-dot items; the code after the rts is dead until a four-bit writer replaces it.
L26BA               equ       *
                    rts
                    pshs      u
                    ldd       #$004D
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    lbsr      zclamp
                    leas      4,s
                    std       4,s
                    ldd       #$00BF
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    lbsr      zclamp
                    leas      4,s
                    std       6,s
                    ldd       #$00BF
                    subd      6,s
                    pshs      a,b
                    ldd       #$0050
                    lbsr      Mul16
                    addd      <vdgram
                    addd      4,s
                    tfr       d,u
                    bra       dyna2_2
dyna2_1               ldx       10,s
                    leax      1,x
                    stx       10,s
                    ldb       -1,x
                    stb       ,u
                    ldx       10,s
                    leax      2,x
                    stx       10,s
                    ldd       -2,x
                    std       1,u
                    leau      <$50,u
dyna2_2               ldd       8,s
                    addd      #$FFFF
                    std       8,s
                    bge       dyna2_1
                    puls      u,pc
box               pshs      u
                    ldd       #$0001
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    lbsr      hline
                    leas      8,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    lbsr      vline
                    leas      8,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    ldd       14,s
                    addd      #$FFFF
                    pshs      a,b
                    lbsr      vline
                    leas      8,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    lbsr      hline
                    leas      8,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    lbsr      vline
                    leas      8,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    ldd       10,s
                    addd      #$0001
                    pshs      a,b
                    lbsr      vline
                    lbra      DrawFrameDone
* boxc: (x1, y1, x2, y2) plain rectangle outline in byte columns: HLines at y1/y2 from x1*8+4 to x2*8+3 and vpatdyn $18 sides
boxc            pshs      u
                    ldd       4,s
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    addd      #$0004
                    std       <xl
                    ldd       8,s
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    addd      #$0003
                    std       <xr
                    ldd       #$0001
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    ldd       <xr
                    pshs      a,b
                    ldd       <xl
                    pshs      a,b
                    lbsr      hline
                    leas      8,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    ldd       <xr
                    pshs      a,b
                    ldd       <xl
                    pshs      a,b
                    lbsr      hline
                    leas      8,s
                    ldd       6,s
                    addd      #$0001
                    std       6,s
                    ldd       10,s
                    addd      #$FFFF
                    std       10,s
                    ldd       #$0018
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    lbsr      vpatdyn
                    leas      8,s
                    ldd       #$0018
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    lbsr      vpatdyn
                    lbra      DrawFrameDone
* winbox: (x1, y1, x2, y2, style) decorated box: style 1 the 3D box (Box3D), style 0 plain boxc, other styles nothing
winbox           pshs      u
                    inc       <FrChrome           s9gui: the corners are drawn in FrInk (ExpBSpr)
                    ldd       4,s
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    std       <xl
                    ldd       8,s
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    std       <xr
                    ldd       12,s
                    cmpd      #$0001
                    lbne      FrameStyle0         style 0 (or any other): FrameStyle0
* Style 1: Box3D, paper inside and an ink border (the routine the menus use).
                    ldd       #Box3DMode          the mode: closed outline, shadow if BoxShadows
                    pshs      a,b
                    ldd       #Box3DInk           fg: the text's ink
                    pshs      a,b
                    ldd       #Box3DPaper         bg: paper
                    pshs      a,b
                    ldd       16,s                YT
                    pshs      a,b
                    ldd       16,s                XR
                    pshs      a,b
                    ldd       16,s                YB
                    pshs      a,b
                    ldd       16,s                XL
                    pshs      a,b
                    lbsr      Box3D
                    leas      14,s
                    clr       <FrChrome
                    puls      u,pc
* Box3D: the 3D box in whole bytes (every menu and every style 1 box). Args (XL, YB, XR, YT, bg byte, fg byte,
* mode) in winbox's columns and rows. The fg outline: byte 0 of column XL through byte 1 of column XR, rows
* YT+1 (YT at the screen's top row) down to YB+3. The bg inside: byte 1 of XL through byte 0 of XR, rows YT
* down to YB+4 - a one-byte (two-dot) border on the sides, one row on the top and bottom. Mode bits: B3Open -
* the right and bottom edges are bg too (flush into the shadow); B3Shadow - the shadow (WinShadow), drawn last
* just outside the outline on the right and bottom; B3Light - that shadow light gray (MenuShadowByte), else dark
* gray (ShadowByte). Style 1 boxes: Box3DMode; menus: black inside, paper outline, MenuBoxMode.
* Keeps every register.
Box3D               pshs      d,x,u               XL 8,s YB 10,s XR 12,s YT 14,s bg 16,s fg 18,s mode 20,s
                    ldd       18,s                the outline, fg
                    pshs      d
                    ldx       16,s                YT
                    cmpx      #191
                    bhs       b3a@                (no row above the screen's top row)
                    leax      1,x
b3a@                tfr       x,d
                    subd      12,s                YB
                    subd      #2
                    pshs      d                   the rows: the top down to YB+3
                    ldd       16,s                XR
                    subd      12,s                XL
                    lslb
                    rola
                    lslb
                    rola
                    addd      #2
                    pshs      d                   (XR-XL)*4+2 bytes: byte 0 of XL through byte 1 of XR
                    pshs      x                   the top row
                    ldd       16,s                XL
                    lslb
                    rola
                    lslb
                    rola
                    pshs      d                   byte 0 of XL
                    lbsr      BoxFill
                    leas      10,s
                    ldd       16,s                the inside, bg
                    pshs      d
                    ldd       16,s                YT
                    subd      12,s                YB
                    subd      #3
                    pshs      d                   the rows: YT down to YB+4
                    ldb       25,s                the mode
                    andb      #B3Open
                    beq       b3c@
                    ldd       ,s                  open: down to YB+3, over the bottom edge
                    addd      #1
                    std       ,s
b3c@                ldd       16,s                XR
                    subd      12,s                XL
                    lslb
                    rola
                    lslb
                    rola
                    pshs      d                   (XR-XL)*4 bytes: byte 1 of XL through byte 0 of XR
                    ldb       27,s                the mode
                    andb      #B3Open
                    beq       b3d@
                    ldd       ,s                  open: through byte 1 of XR, over the right edge
                    addd      #1
                    std       ,s
b3d@                ldd       20,s                YT
                    pshs      d
                    ldd       16,s                XL
                    lslb
                    rola
                    lslb
                    rola
                    addd      #1
                    pshs      d                   byte 1 of XL
                    lbsr      BoxFill
                    leas      10,s
* the shadow last, just outside the outline (B3Shadow)
                    ldb       21,s                the mode
                    andb      #B3Shadow
                    beq       b3e@
                    ldx       #ShadowByte         a paper box: dark gray
                    ldb       21,s
                    andb      #B3Light
                    beq       b3s@
                    ldx       #MenuShadowByte     a black box: light gray
b3s@                leas      -4,s                WinShadow reads XL at 14,s
                    lbsr      WinShadow
                    leas      4,s
b3e@                puls      d,x,u,pc
* FillSpan: FillRows for a row span of any length (B counts at most 255): U, A = rows and X = the fill byte as
* FillRows takes them, the byte count a word pushed by the caller (who drops it). Keeps every register.
FillSpan            pshs      a,x,u               ,s rows  1,s the fill  3,s U  7,s the count
fs1@                ldd       7,s
                    beq       fs9@
                    cmpd      #252
                    bls       fs2@
                    ldd       #252
fs2@                pshs      d                   this pass
                    lda       2,s
                    ldb       1,s
                    ldx       3,s
                    lbsr      FillRows
                    ldd       9,s
                    subd      ,s
                    std       9,s                 the bytes left
                    ldd       ,s++
                    leau      d,u                 on along the rows
                    bra       fs1@
fs9@                puls      a,x,u,pc
* WinShadow: the 3D box's shadow in whole bytes of X (Box3D passes ShadowByte or MenuShadowByte), just outside
* the outline: bytes 2-3 of column XR from row YT-3 down to the outline's bottom row (YB+3), then the two rows
* under it (YB+2, YB+1) from byte 2 of column XL+1 through byte 3 of column XR. Reads Box3D's args (XL, YB,
* XR, YT) four bytes deeper than Box3D does, then this return address: XL 14,s YB 16,s XR 18,s YT 20,s;
* +6 after the pshs here. Keeps every register.
WinShadow           pshs      d,x,u
                    ldd       24,s                XR
                    cmpd      #$004F
                    bhi       ws9@                off the screen (vpatdyn's test)
                    ldd       26,s                YT
                    subd      22,s                YB
                    subd      #5                  the rows YB+3..YT-3
                    ble       ws1@
                    pshs      b                   the rows
                    ldx       25,s                XR
                    ldd       27,s                YT
                    subd      #3
                    lbsr      ScrPos              U = the right column on row YT-3
                    puls      a                   A = the rows
                    ldb       #2                  bytes 2 and 3 (FillRows starts at byte 2)
                    ldx       2,s                 the caller's X: the shadow byte
                    lbsr      FillRows
ws1@                ldx       20,s                XL
                    leax      1,x                 column XL+1
                    ldd       22,s                YB
                    addd      #2
                    lbsr      ScrPos              U = column XL+1 on row YB+2; FillRows starts at byte 2 of it
                    ldd       24,s                XR
                    subd      20,s                XL
                    lslb
                    rola
                    lslb
                    rola
                    subd      #2
                    pshs      d                   (XR-XL)*4-2 bytes: byte 2 of column XL+1 through byte 3 of the right column
                    lda       #2                  rows YB+2, YB+1
                    ldx       4,s                 the caller's X (under the count): the shadow byte
                    lbsr      FillSpan
                    leas      2,s
ws9@                puls      d,x,u,pc
* FrameStyle0: winbox for any style but 1: style 0 draws boxc, others nothing (FrChrome left set)
FrameStyle0         ldd       12,s
                    bne       a15@
                    ldd       10,s
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    lbsr      boxc
* DrawFrameDone: shared tail of box, boxc and FrameStyle0: clears FrChrome, drops 8 bytes, puls u,pc
DrawFrameDone       clr       <FrChrome
                    leas      8,s
a15@                puls      u,pc
* butbox: (colA, colB, y, kind) frame around a menu item; none in a black (menu) window or for kind 0. Kinds 1-7: hlines at y-3 and y+6 from colA*8+6 to colB*8+1, 8-row end caps (dyna1, $02E9/$02F1) at colA (+1 for kind 4) and colB; kinds 8-12: 11-row caps ($02F9/$0305) at colA and colA+1; kind 13: two put1 strips ($0303/$030F)
butbox         tst       >FrWinInv           a black (menu) window: no button frame - ink on black
                    beq       bbx0@
                    rts
bbx0@               pshs      a,b,x,y,u
                    inc       <FrChrome           s9gui: the end caps are drawn in FrInk (ExpBSpr)
                    ldd       <$10,s
                    lbeq      DrawItemBoxDone
                    ldd       14,s
                    addd      #$FFFD
                    std       ,s
                    ldd       14,s
                    addd      #$0006
                    std       2,s
                    ldd       <$10,s
                    cmpd      #$0008
                    lbge      ItemBoxTall
                    ldd       10,s
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    addd      #$0006
                    std       <xl
                    ldd       12,s
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    addd      #$0001
                    std       <xr
                    ldd       #$0001
                    pshs      a,b
                    ldd       2,s
                    pshs      a,b
                    ldd       <xr
                    pshs      a,b
                    ldd       <xl
                    pshs      a,b
                    lbsr      hline
                    leas      8,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       4,s
                    pshs      a,b
                    ldd       <xr
                    pshs      a,b
                    ldd       <xl
                    pshs      a,b
                    lbsr      hline
                    leas      8,s
                    ldd       2,s
                    addd      #$FFFF
                    std       2,s
                    ldd       <$10,s
                    addd      #$FFFF
                    std       <$10,s
                    cmpd      #$0003
                    bne       a16@
                    ldd       #$0001
                    bra       b16@
a16@                clra
                    clrb
b16@                std       4,s
                    ldd       <$10,s
                    aslb
                    rola
                    ldx       #$02E9
                    leax      d,x
                    ldd       ,x
                    pshs      a,b
                    ldd       #$0008
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    ldd       <$10,s
                    addd      10,s
                    pshs      a,b
                    lbsr      dyna1
                    leas      8,s
                    ldd       <$10,s
                    aslb
                    rola
                    ldx       #$02F1
                    leax      d,x
                    ldd       ,x
                    pshs      a,b
                    ldd       #$0008
                    lbra      ItemBoxRightCap
* ItemBoxTall: kind >= 8 branch of butbox (11-row caps or the 16-wide kind 13)
ItemBoxTall         ldd       2,s
                    addd      #$0001
                    std       2,s
                    ldd       10,s
                    addd      #$0001
                    std       12,s
                    ldd       <$10,s
                    cmpd      #$000D
                    bne       a17@
                    ldd       #$0001
                    pshs      a,b
                    ldd       >FrData_reserved_0303
                    pshs      a,b
                    ldd       #$000B
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    ldd       <$12,s
                    pshs      a,b
                    lbsr      put1
                    leas      10,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       >FrData_reserved_030F
                    pshs      a,b
                    ldd       #$000B
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    ldd       <$14,s
                    pshs      a,b
                    lbsr      put1
                    leas      10,s
                    bra       DrawItemBoxDone
a17@                ldd       <$10,s
                    subd      #$0008
                    std       <$10,s
                    aslb
                    rola
                    ldx       #$02F9
                    leax      d,x
                    ldd       ,x
                    pshs      a,b
                    ldd       #$000B
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    ldd       <$10,s
                    pshs      a,b
                    lbsr      dyna1
                    leas      8,s
                    ldd       <$10,s
                    aslb
                    rola
                    ldx       #$0305
                    leax      d,x
                    ldd       ,x
                    pshs      a,b
                    ldd       #$000B
* ItemBoxRightCap: the dyna1 call for the right end cap; the short-kind path lbras here, the tall path falls in
ItemBoxRightCap     pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    ldd       <$12,s
                    pshs      a,b
                    lbsr      dyna1
                    leas      8,s
* DrawItemBoxDone: butbox's exit (clears FrChrome, leas 6,s, puls u,pc): kind 0, the kind-13 arm and the cap paths
DrawItemBoxDone     clr       <FrChrome
                    leas      6,s
                    puls      u,pc
* ---- THE DMA PRIMITIVES ---------------------------------------------------------------------------
* DmaProbe: FrDma = 1 when the engine's read decode answers as the RTL does (a read of $FEC4 returns the
* byte written at $FEC7). MAME's model returns its own register: no DMA there.
DmaProbe            pshs      a
                    lda       #$C4
                    sta       >DMAPROBE4
                    lda       #$C7
                    sta       >DMAPROBE7
                    lda       >DMAPROBE4
                    cmpa      #$C7
                    bne       dpr0@
                    lda       #1
                    sta       >FrDma
* A program run before s9 can leave a logic op (OR/AND/XOR/MASK) in DMAOPR ($FED4); every fill and copy would
* then combine with the screen instead of writing it, so the op is set to COPY.
                    clr       >DMAOPR
                    puls      a,pc
dpr0@               clr       >FrDma
                    puls      a,pc
* DmaAddr: A = a RAM block, X = an offset in it (0-$FFFF, may run into the following blocks) ->
* A:B = the top two bytes of block x $2000 + offset, X = the offset (its low byte is the third)
DmaAddr             pshs      x
                    tfr       a,b
                    lsrb
                    lsrb
                    lsrb                          B = block >> 3: bits 23:16
                    asla
                    asla
                    asla
                    asla
                    asla                          A = block << 5: bits 15:8
                    adda      ,s                  + the offset's high byte
                    bcc       daa1@
                    incb                          carries into bits 23:16
daa1@               exg       a,b
                    puls      x,pc
* DmaSetSrc / DmaSetDst: A = block, X = offset -> the three address registers. Clobbers D.
DmaSetSrc           bsr       DmaAddr
                    sta       >DMASRCH
                    stb       >DMASRCH+1
                    tfr       x,d
                    stb       >DMASRCH+2
                    rts
DmaSetDst           bsr       DmaAddr
                    sta       >DMADSTH
                    stb       >DMADSTH+1
                    tfr       x,d
                    stb       >DMADSTH+2
                    rts
* DmaCount: Y = a 1D byte count (1-65535). The count's three bytes are scattered as the RTL builds it:
* $FECF = [23:16] (0 here), $FECC = [15:8], $FECD = [7:0]; $FECE is a live 2D register, left 0.
DmaCount            pshs      y
                    lda       ,s
                    sta       >DMAXH
                    lda       1,s
                    sta       >DMAXH+1
                    clr       >DMAYH
                    clr       >DMAYH+1
                    puls      y,pc
* DmaShape: X = bytes a row, Y = rows (2D). DmaStrides: X = source stride, Y = destination stride, bytes.
DmaShape            pshs      x,y
                    lda       ,s
                    sta       >DMAXH
                    lda       1,s
                    sta       >DMAXH+1
                    lda       2,s
                    sta       >DMAYH
                    lda       3,s
                    sta       >DMAYH+1
                    puls      x,y,pc
DmaStrides          pshs      x,y
                    lda       ,s
                    sta       >DMASSTH
                    lda       1,s
                    sta       >DMASSTH+1
                    lda       2,s
                    sta       >DMADSTSH
                    lda       3,s
                    sta       >DMADSTSH+1
                    puls      x,y,pc
* DmaFire: A = the control bits (enable + mode). Written with start clear, then with start set - the
* engine fires on that edge - then the status is BUSY-POLLED until bit 7 drops; control is cleared at
* the end so the next start is a fresh edge. Carry set = the engine never finished: the caller falls
* back to the CPU and FrDma is cleared for the rest of the run.
* No sleep in this loop: the engine halts the CPU in the vertical blank and waits for the HALT acknowledge
* (BA and BS); a yield lets the kernel idle in cwai, which never acknowledges the halt, so nothing would move.
DmaFire             pshs      x,y
                    sta       >DMACTL
                    ora       #DMA_START
                    sta       >DMACTL
* The busy flag rises a few clocks after the start bit (two clock-domain syncs); a poll before then reads "done"
* with the transfer still to come. So wait for BUSY to RISE first (bounded: a transfer already over, the CPU
* halted through it, reads low and the bound expires), then for it to fall.
                    ldx       #$0400
dfi0@               lda       >DMASTAT
                    bita      #DMA_BUSY
                    bne       dfi0b@              it is running (or queued): now wait for the end
                    leax      -1,x
                    bne       dfi0@
dfi0b@              ldy       #DmaPolls
                    ldx       #0
dfi1@               lda       >DMASTAT
                    bita      #DMA_BUSY
                    beq       dfi9@
                    leax      -1,x
                    bne       dfi1@
                    leay      -1,y
                    bne       dfi1@
                    clr       >DMACTL
                    clr       >FrDma              stuck once: never again this run
                    puls      x,y
                    orcc      #Carry
                    rts
dfi9@               clr       >DMACTL
                    puls      x,y
                    andcc     #^Carry
                    rts
* DmaClr: A = the byte, B = the destination block, X = the offset in it, Y = the count. 1D fill.
* Carry set = not done (no engine, or it stuck): the caller clears on the CPU.
DmaClr              tst       >FrDma
                    beq       DmaOff
                    pshs      a
                    tfr       b,a
                    lbsr      DmaSetDst
                    puls      a
                    sta       >DMASTAT            the fill byte
                    lbsr      DmaCount
                    lda       #DMA_EN+DMA_FILL
                    bra       DmaFire
* DmaClr2D: A = the byte, B = the destination block, X = the offset; the shape and strides set before.
DmaClr2D            tst       >FrDma
                    beq       DmaOff
                    pshs      a
                    tfr       b,a
                    lbsr      DmaSetDst
                    puls      a
                    sta       >DMASTAT
                    lda       #DMA_EN+DMA_FILL+DMA_2D
                    bra       DmaFire
* DmaCopy: A = the source block, X = its offset, B = the destination block, U = its offset, Y = the count.
DmaCopy             tst       >FrDma
                    beq       DmaOff
                    pshs      b,u
                    lbsr      DmaSetSrc
                    puls      a,x                 the destination block and offset
                    lbsr      DmaSetDst
                    lbsr      DmaCount
                    lda       #DMA_EN
                    lbra      DmaFire
* DmaCopy2D: as DmaCopy without the count; the shape and strides set before.
DmaCopy2D           tst       >FrDma
                    beq       DmaOff
                    pshs      b,u
                    lbsr      DmaSetSrc
                    puls      a,x
                    lbsr      DmaSetDst
                    lda       #DMA_EN+DMA_2D
                    lbra      DmaFire
DmaOff              orcc      #Carry
                    rts
* RectDma: bytblt's large rectangles by DMA. Entered from RectOpDispatch with X = the mode and the
* stack exactly as bytblt left it (pshs u only), so RectRowOff / RectArenaOff read their frame slots
* as they do for RectSave. Modes 2/4/6 fill, 0 saves to the arena, 1 restores from it; 3, 5, 7, 8 and
* anything under DmaMinBytes go on to the CPU dispatch (RectCpuDispatch).
RectDma             stu       <dy                 the window row the CPU handlers need, put back by RectCpuDispatch
                    sty       <afxa1              Y = the C static base: the DMA calls load it, every exit restores it
* Saves and restores rely on the DMA controller's first-byte fix (rc20 cores); older cores leave stale edge dots.
                    cmpx      #$0003
                    lbeq      RectCpuDispatch
                    cmpx      #$0005
                    lbeq      RectCpuDispatch
                    cmpx      #$0006
                    lbhi      RectCpuDispatch
                    stx       <xr                 the mode
                    lbsr      RectRowOff          <igoal = the picture offset of the top row
                    ldd       <hgt
                    pshs      a,b
                    ldd       <bgoal
                    lbsr      Mul16               rows x bytes a row (the operand popped)
                    cmpd      #DmaMinBytes
                    lblo      RectCpuDispatch
                    std       <xl                 the count
                    ldd       <xr
                    cmpd      #$0002
                    beq       rdm2@
                    cmpd      #$0004
                    beq       rdm4@
                    cmpd      #$0006
                    beq       rdm6@
* a save or a restore: the arena must exist
                    ldd       >FrSave
                    lbeq      RectBlockOpRet      no arena: nothing (as RectSave / RectRestore)
                    lbsr      RectArenaOff        <ibase = the arena offset of the buffer
                    ldx       <bgoal
                    ldy       <hgt
                    lbsr      DmaShape
                    ldd       <xr
                    bne       rdm1@
* mode 0, save: picture (stride 320) -> arena (stride bgoal)
                    ldx       #$0140
                    ldy       <bgoal
                    lbsr      DmaStrides
                    lda       <FrBM0
                    ldx       <igoal
                    ldb       >FrSave+1
                    ldu       <ibase
                    ldy       <xl
                    lbsr      RectDma2D
                    bra       rdm9@
* mode 1, restore: arena -> picture
rdm1@               ldx       <bgoal
                    ldy       #$0140
                    lbsr      DmaStrides
                    lda       >FrSave+1
                    ldx       <ibase
                    ldb       <FrBM0
                    ldu       <igoal
                    ldy       <xl
                    lbsr      RectDma2D
                    bra       rdm9@
rdm2@               lda       #COLORS_PAPER*$11   paper
                    bra       rdmf@
rdm4@               lda       #COLORS_INK*$11     ink
                    bra       rdmf@
rdm6@               lda       #COLORS_INK                alternate dots (RectFillGrey's $0F0F)
rdmf@               ldb       <FrBM0
                    ldx       <igoal
                    ldy       <xl
                    pshs      a,b
                    ldd       <bgoal
                    cmpd      #$0140
                    puls      a,b
                    bne       rdmf2@
                    lbsr      DmaClr              full-width rows are one run: 1D
                    bra       rdm9@
rdmf2@              pshs      a,b,x
                    ldx       <bgoal
                    ldy       <hgt
                    lbsr      DmaShape
                    ldx       #$0140
                    ldy       #$0140
                    lbsr      DmaStrides          both strides a picture row
                    puls      a,b,x
                    lbsr      DmaClr2D
rdm9@               lbcs      RectCpuDispatch     the engine did not do it: the CPU does
                    ldy       <afxa1              the static base back
                    lbra      RectBlockOpRet
* RectDma2D: A/X = source block/offset, B/U = destination block/offset, Y = the count, the shape and
* strides set: one 1D run when the rows are contiguous both sides (a full-width rectangle), else 2D
RectDma2D           pshs      a,b
                    ldd       <bgoal
                    cmpd      #$0140
                    puls      a,b
                    lbne      DmaCopy2D
                    lbra      DmaCopy
* RectCpuDispatch: the mode handlers on the CPU; X = the mode again
RectCpuDispatch     ldu       <dy
                    ldy       <afxa1              the static base back
                    ldx       <xr
                    lbra      RectOpDispatch1

* bytblt: (mode, x1, y1, x2, y2, buf) byte-column rectangle operation: 0 save, 1 restore,
* 2 paper, 3 invert, 4 ink, 5 OR buffer, 6 gray (alternate dots), 7 palette $1, 8 menu interior; clamps to 0..79 x 0..191
bytblt         pshs      u
                    clra
                    clrb
                    std       <color
                    ldd       #$004F
                    pshs      a,b
                    leax      12,s
                    pshs      x
                    leax      10,s
                    pshs      x
                    lbsr      argfix
                    leas      6,s
                    ldd       #$00BF
                    pshs      a,b
                    leax      14,s
                    pshs      x
                    leax      12,s
                    pshs      x
                    lbsr      argfix
                    leas      6,s
* s9gui: <width = columns (eight dots each), <bgoal = bytes a row (four a column), <hgt = rows, <iptr = the
* buffer (modes 0, 1, 5); U walks the rows from the top one down through the window (RectNextRow).
                    ldd       10,s
                    subd      6,s
                    addd      #$0001
                    std       <width                columns
                    aslb
                    rola
                    aslb
                    rola
                    std       <bgoal                bytes a row
                    ldd       12,s
                    ldx       6,s
                    lbsr      ScrPos              U = the top row of the rectangle
                    ldd       12,s
                    subd      8,s
                    addd      #$0001
                    std       <hgt                rows
                    ldx       14,s
                    stx       <iptr                the buffer
                    ldx       4,s
                    lbra      RectOpDispatch
* Window backgrounds (newin's spalloc buffers) and the fixed saves at $087A and $1290 (the note column, the
* drag area) are kept four bits deep in s9gui's own RAM arena, FrSave - eight blocks (64K) F$AllRAM'd in
* mapwin - so what comes back is what was there, colors included. A buffer 'pointer' P (spalloc's
* $13D8-$3977, or $087A / $1290) names the arena offset (P-$087A)*4: sixteen bits, below 50,200 for every
* buffer the module passes. The arena shares the window's two slots with the picture, so rows travel
* through the Shuttle (data $13D8) at most ShuttleMax (5,816) bytes a pass, so a pass never leaves the
* two arena blocks mapped for it. <ibase arena offset, <igoal picture offset of the next row, <dy bytes
* in the pass, <xl rows in the pass, <xr a counter, <color 0 = restore as saved / 1 = put the inked
* dots over the picture (mode 5).
* AreaWin: A = arena block (0-7): blocks A and A+1 of the save arena take the window's slots (the
* picture is forgotten; the next ScrAddr maps it afresh). U = their address.
AreaWin             pshs      d,x
                    ldu       <FrWinP
                    beq       aw1@
                    ldb       #$02
                    os9       F$ClrBlk
aw1@                clra
                    clrb
                    std       <FrWinP
                    ldb       #$FF
                    stb       <FrWin
                    ldb       ,s                  the arena block
                    clra
                    addd      >FrSave
                    tfr       d,x
                    ldb       #$02
                    os9       F$MapBlk            the slots were just freed: it cannot refuse
                    stu       <FrWinP
                    puls      d,x,pc
* RectArenaOff: <ibase = the arena offset of the buffer <iptr. RectRowOff: <igoal = the picture offset of
* the rectangle's top row, (191 - y2) * 320 + x1 * 4; both run inside bytblt's frame (pshs u),
* where x1 is at 6,s and y2 at 12,s - two deeper here for the return address.
RectArenaOff        ldd       <iptr
                    subd      #$087A
                    aslb
                    rola
                    aslb
                    rola
                    std       <ibase
                    rts
RectRowOff          ldd       #$00BF
                    subd      14,s                y2, the top row
                    pshs      a,b
                    ldd       #$0140
                    lbsr      Mul16               (191 - y2) * 320; the operand popped
                    pshs      a,b
                    ldd       10,s                x1
                    aslb
                    rola
                    aslb
                    rola                          four bytes a column
                    addd      ,s++
                    std       <igoal
* the blocks the rectangle covers go dirty here (the DMA modes never call ScrWin)
                    pshs      x
                    ldx       <hgt
                    lbsr      DirtyRange
                    puls      x
                    rts
* RectSave: mode 0 - the rows of the rectangle into the arena, as they are
RectSave            ldd       >FrSave
                    lbeq      RectBlockOpRet      no arena: nothing
                    bsr       RectArenaOff
                    bsr       RectRowOff
rsa1@               ldd       <igoal                a pass: rows into the shuttle until it is full
                    lbsr      ScrAddr             U = the next row (the picture mapped again)
                    ldx       #Shuttle
                    clra
                    clrb
                    std       <dy                bytes in the shuttle
rsa2@               ldd       <dy
                    addd      <bgoal
                    cmpd      #ShuttleMax
                    bhi       rsa4@               the next row would not fit: flush
                    std       <dy
                    lda       <width+1                columns: four bytes each (counted on the stack: ldd clobbers A)
                    pshs      a
rsa3@               ldd       ,u++
                    std       ,x++
                    ldd       ,u++
                    std       ,x++
                    dec       ,s
                    bne       rsa3@
                    leas      1,s
                    ldd       <igoal
                    addd      #$0140
                    std       <igoal                the row below
                    lbsr      ScrAddr
                    ldd       <hgt
                    subd      #$0001
                    std       <hgt
                    bne       rsa2@
rsa4@               ldd       <dy                flush: the shuttle into the arena at <ibase
                    beq       rsa9@
                    lda       <ibase
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra                          arena block = offset / 8192
                    lbsr      AreaWin             U = the pair
                    ldd       <ibase
                    anda      #$1F
                    leau      d,u                 the offset inside it
                    ldx       #Shuttle
                    ldd       <dy
                    lsra
                    rorb
                    lsra
                    rorb                          four-byte chunks
                    std       <xr
rsa5@               ldd       ,x++
                    std       ,u++
                    ldd       ,x++
                    std       ,u++
                    ldd       <xr
                    subd      #$0001
                    std       <xr
                    bne       rsa5@
                    ldd       <ibase
                    addd      <dy
                    std       <ibase
                    ldd       <hgt
                    bne       rsa1@               rows remain: another pass
rsa9@               lbra      RectBlockOpRet
* RectRestore: mode 1 - the saved rows back as they were. RectOrBuf: mode 5 - their inked dots put
* over the picture (each replaces the dot under it, as Or8 does).
RectRestore         ldd       >FrSave
                    lbeq      RectBlockOpRet      no arena: nothing
                    clr       <color
                    bra       rre0@
RectOrBuf           ldd       >FrSave
                    lbeq      RectBlockOpRet      no arena: nothing
                    ldb       #$01
                    stb       <color
rre0@               lbsr      RectArenaOff
                    lbsr      RectRowOff
rre1@               clra                          a pass: how many rows fit the shuttle
                    clrb
                    std       <dy                bytes
                    std       <xl                rows
                    ldd       <hgt
                    std       <xr                rows left to look at
rre2@               ldd       <xr
                    beq       rre3@
                    ldd       <dy
                    addd      <bgoal
                    cmpd      #ShuttleMax
                    bhi       rre3@
                    std       <dy
                    ldd       <xl
                    addd      #$0001
                    std       <xl
                    ldd       <xr
                    subd      #$0001
                    std       <xr
                    bra       rre2@
rre3@               ldd       <xl
                    pshs      a,b                 the pass's rows, for the count at the end
                    lda       <ibase
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra
                    lbsr      AreaWin             the arena into the window
                    ldd       <ibase
                    anda      #$1F
                    leax      d,u                 X = the saved rows
                    ldu       #Shuttle
                    ldd       <dy
                    lsra
                    rorb
                    lsra
                    rorb
                    std       <xr
rre4@               ldd       ,x++
                    std       ,u++
                    ldd       ,x++
                    std       ,u++
                    ldd       <xr
                    subd      #$0001
                    std       <xr
                    bne       rre4@
                    ldd       <ibase
                    addd      <dy
                    std       <ibase
                    ldx       #Shuttle
rre5@               ldd       <igoal                each row of the pass onto the picture
                    lbsr      ScrAddr
                    lda       <width+1                columns (counted on the stack: ldd clobbers A)
                    tst       <color
                    bne       rre7@
                    pshs      a
rre6@               ldd       ,x++                restore: as saved
                    std       ,u++
                    ldd       ,x++
                    std       ,u++
                    dec       ,s
                    bne       rre6@
                    leas      1,s
                    bra       rre8@
rre7@               ldb       #$04                or: the inked dots over the picture
                    pshs      a
rre7a@              lda       ,x+
                    pshs      a
                    lbsr      NibMask
                    coma
                    anda      ,u
                    ora       ,s+
                    sta       ,u+
                    decb
                    bne       rre7a@
                    puls      a
                    deca
                    bne       rre7@
rre8@               ldd       <igoal
                    addd      #$0140
                    std       <igoal
                    ldd       <xl
                    subd      #$0001
                    std       <xl
                    bne       rre5@
                    ldd       <hgt
                    subd      ,s++                less the pass's rows
                    std       <hgt
                    lbne      rre1@
                    lbra      RectBlockOpRet
* RectFillMenu: mode 8, the menu interior (COLORS_MENUBG). RectFillWhite: mode 7, palette $1 (COLORS_TOOLBOXBG).
RectFillMenu        ldd       #COLORS_MENUBG*$1111
                    bra       rf0@
RectFillWhite       ldd       #COLORS_TOOLBOXBG*$1111
                    bra       rf0@
* RectFillGrey: mode 6, alternate dots. RectFillSolid: mode 4, ink. RectFill: mode 2, paper (bytblt zeroed <color).
RectFillGrey        ldd       #COLORS_INK*$0101              alternate dots
                    bra       rf0@
RectFillSolid       ldd       #COLORS_INK*$1111
                    bra       rf0@
RectFill            ldd       <color                0: paper
rf0@                std       <color
rf1@                ldx       <bgoal
                    ldd       <color
rf2@                std       ,u++
                    std       ,u++
                    leax      -4,x
                    bne       rf2@
                    bsr       RectNextRow
                    bne       rf1@
                    lbra      RectBlockOpRet
* RectInvert: mode 3 - every byte complemented: ink <-> paper
RectInvert          ldx       <bgoal
ri1@                com       ,u+
                    leax      -1,x
                    bne       ri1@
                    bsr       RectNextRow
                    bne       RectInvert
                    lbra      RectBlockOpRet
* RectNextRow: U (a row's end) back to its start and down one row; Z set when no rows remain
RectNextRow         ldd       <bgoal
                    nega
                    negb
                    sbca      #$00
                    leau      d,u
                    lbsr      ScrRowDn
                    ldd       <hgt
                    subd      #$0001
                    std       <hgt
                    rts
* PackExp: the four picture bytes at ,U (eight dots) -> B, bit 7 the left dot, a set bit = any ink. Keeps U.
PackExp             pshs      a,x
                    leax      4,u
                    clrb
                    lda       #$04
                    pshs      a
pk1@                lsrb
                    lsrb
                    lda       ,-x
                    bita      #$F0
                    beq       pk2@
                    orb       #$80
pk2@                bita      #$0F
                    beq       pk3@
                    orb       #$40
pk3@                dec       ,s
                    bne       pk1@
                    leas      1,s
                    puls      a,x,pc
* RectOpDispatch: jumps to the bytblt mode handler selected by X; with the DMA engine every rectangle goes
* to RectDma first (it comes back to RectOpDispatch1 when the CPU must do it).
RectOpDispatch      stx       <xr
                    tst       >FrDma
                    beq       RectOpDispatch1
                    lbra      RectDma
RectOpDispatch1     cmpx      #$0008
                    lbeq      RectFillMenu
                    cmpx      #$0000
                    lbeq      RectSave
                    cmpx      #$0001
                    lbeq      RectRestore
                    cmpx      #$0007
                    lbeq      RectFillWhite
                    cmpx      #$0006
                    lbeq      RectFillGrey
                    cmpx      #$0004
                    lbeq      RectFillSolid
                    cmpx      #$0002
                    lbeq      RectFill
                    cmpx      #$0003
                    lbeq     RectInvert
                    cmpx      #$0005
                    lbeq      RectOrBuf
* RectBlockOpRet: puls u,pc of bytblt; every mode handler and the unknown-mode default land here
RectBlockOpRet      puls      u,pc
* yclear: (y1, y2) clears every dot of rows y1..y2. s9gui: 320 bytes a row from the top row down.
yclear               pshs      u
                    ldd       #$00BF
                    pshs      a,b
                    leax      8,s
                    pshs      x
                    leax      8,s
                    pshs      x
                    bsr      argfix
                    leas      6,s
                    ldd       6,s                 the higher y: the top row
                    ldx       #$0000
                    lbsr      ScrPos
                    ldd       6,s
                    subd      4,s
                    addd      #$0001
                    std       <ibase                rows to clear (1-192)
* the rows are one contiguous run in the picture: by DMA when it is large enough
                    tst       >FrDma
                    beq       ce1@
                    pshs      a,b
                    ldd       #$0140
                    lbsr      Mul16               rows x 320 (the operand popped)
                    cmpd      #DmaMinBytes
                    blo       ce1@
                    sty       <afxa1              Y = the C static base, parked
                    tfr       d,y                 the count
                    ldd       #$00BF
                    subd      6,s                 191 - the top row
                    pshs      a,b
                    ldd       #$0140
                    lbsr      Mul16               its picture offset
                    ldx       <ibase              the rows: the blocks they cover go dirty
                    lbsr      DirtyRange
                    tfr       d,x
                    ldb       <FrBM0
                    clra                          paper
                    lbsr      DmaClr
                    ldy       <afxa1              the static base back
                    bcs       ce1@                not done: the CPU loop below
                    puls      u,pc
ce1@                ldx       #$0028              40 x 8 bytes
                    clra
                    clrb
ce2@                std       ,u++
                    std       ,u++
                    std       ,u++
                    std       ,u++
                    leax      -1,x
                    bne       ce2@
                    leau      >-$0140,u
                    lbsr      ScrRowDn
                    dec       <ibase+1
                    bne       ce1@
                    puls      u,pc
* argfix: (&a, &b, max) clamps both values to 0..max and swaps them so a <= b
argfix      pshs      u
                    ldd       [<$04,s]
                    std       <afxa1
                    cmpd      8,s
                    ble       a26@
                    ldd       8,s
                    bra       b26@
a26@                ldd       <afxa1
                    bge       c26@
                    clra
                    clrb
b26@                std       <afxa1
c26@                ldd       [<$06,s]
                    std       <afxa2
                    cmpd      8,s
                    ble       d26@
                    ldd       8,s
                    bra       e26@
d26@                ldd       <afxa2
                    bge       f26@
                    clra
                    clrb
e26@                std       <afxa2
f26@                ldd       <afxa1
                    cmpd      <afxa2
                    ble       g26@
                    ldd       <afxa1
                    std       <afxi
                    ldd       <afxa2
                    std       <afxa1
                    ldd       <afxi
                    std       <afxa2
g26@                ldd       <afxa1
                    std       [<$04,s]
                    ldd       <afxa2
                    std       [<$06,s]
                    puls      u,pc
staff               pshs      u
                    ldd       6,s
                    cmpd      #$00AD
                    bgt       staff_1
                    ldd       6,s
                    bge       staff_2
staff_1               puls      u,pc
* staff: (col, y, bar, dots) five full-width lines four rows apart at rows y..y+16 (y 0..173, else nothing);
* bar != 0 first draws the 17-row bar at byte column col (four bytes a column). dots != 0: alternate dots.
staff_2               ldd       #$00BF
                    subd      6,s
                    pshs      a,b
                    ldd       #$0140
                    lbsr      Mul16
                    std       <ibase
                    ldb       9,s
                    beq       staff_5
                    ldd       4,s
                    aslb
                    rola
                    aslb
                    rola
                    addd      <ibase
                    lbsr      ScrAddr
                    ldd       #$0012
                    std       <dy
                    bra       staff_4
* The bar and the lines are StaffInk, not FrInk. A bar row: two dots of ink, then fourteen of paper (eight bytes).
staff_3               ldd       #StaffInk*$1100     two dots of staff ink, two of paper
                    std       ,u
                    clra
                    clrb
                    std       2,u
                    std       4,u                 dots 4-15 (2,u through 7,u): paper
                    std       6,u
                    lbsr      ScrRowUp
staff_4               ldd       <dy
                    addd      #$FFFF
                    std       <dy
                    bne       staff_3
staff_5               ldb       11,s
                    stb       >FrStaffDots        remember the actual score staff pattern, not just layout edits
                    beq       staff_6
                    ldd       #StaffInk*$1010     alternate dots
                    bra       staff_7
staff_6               ldd       #StaffInk*$1111     every dot
staff_7               std       <color
* With the DMA engine the five lines are ONE 2D fill: five rows of 320 bytes from the top line (ibase - 4 x 1280)
* down at a stride of 1280 (the lines are four rows apart), in the pattern's byte. The CPU loop below is the fallback.
                    tst       >FrDma
                    beq       staff_7c
                    sty       <afxa1              Y = the C static base, parked
                    ldx       #$0140              320 bytes a row
                    ldy       #5                  five lines
                    lbsr      DmaShape
                    ldx       #$0500
                    ldy       #$0500              1280: four rows on
                    lbsr      DmaStrides
                    ldd       <ibase
                    subd      #$1400              the top line: 4 x 1280 above the bottom one
                    ldx       #17                 the five lines span seventeen rows: their blocks go dirty
                    lbsr      DirtyRange
                    tfr       d,x
                    lda       <color              the pattern's byte
                    ldb       <FrBM0
                    lbsr      DmaClr2D
                    ldy       <afxa1              the static base back
                    bcs       staff_7c            not done: the CPU draws them
                    puls      u,pc
staff_7c            ldd       <ibase
                    lbsr      ScrAddr
                    ldd       #$0006
                    std       <dy
                    bra       staff_11
* The loop below counts down BEFORE it writes: 161 writes 160 words = one 320-byte row.
staff_8               ldd       #$00A1              161 words: 160 written = one 320-byte row
                    std       <width
                    bra       staff_10
staff_9               ldd       <color
                    std       ,u++
staff_10               ldd       <width
                    addd      #$FFFF
                    std       <width
                    bne       staff_9
                    lbsr      ScrRowUp            five rows up: the next line, four rows above
                    lbsr      ScrRowUp
                    lbsr      ScrRowUp
                    lbsr      ScrRowUp
                    lbsr      ScrRowUp
staff_11               ldd       <dy
                    addd      #$FFFF
                    std       <dy
                    bne       staff_8
                    puls      u,pc
* phrase: (col, y, str, noRow6) draws a string with the 6-row font at data $099F starting at byte column col, top row y+4 (clamped 5..191); noRow6 skips the sixth glyph row
phrase            pshs      u
                    leas      -1,s
                    ldd       #$00BF              top row up to 191 (the menu bar's text starts on raster row 0)
                    pshs      a,b
                    ldd       #$0005
                    pshs      a,b
                    ldd       11,s
                    addd      #$0004
                    pshs      a,b
                    lbsr      clamp
                    leas      6,s
                    std       7,s
                    ldd       7,s
                    ldx       5,s
                    lbsr      ScrPos
                    bra       DrawTextNext
* DrawTextGlyph: stores the 5 or 6 rows of one glyph ((c-$20)*24 into the font) and advances one column
* The glyph is 24 bytes of the Chars16 font (six rows of four, four bits a dot) stored as it is; a
* glyph row is 320 bytes from the last, all six inside the window (ScrPos anchored the first).
DrawTextGlyph       ldb       ,s
                    sex
                    addd      #$FFE0
                    pshs      a,b
                    ldd       #$0018
                    lbsr      Mul16
                    ldx       #$099F              the four-bit font
                    tst       >FrWinInv
                    beq       dtg1@
                    ldx       #FrFontInv          a menu (black) window: the inverted font
dtg1@               leax      d,x
                    ldd       ,x
                    std       ,u
                    ldd       2,x
                    std       2,u
                    ldd       4,x
                    std       >$0140,u
                    ldd       6,x
                    std       >$0142,u
                    ldd       8,x
                    std       >$0280,u
                    ldd       10,x
                    std       >$0282,u
                    ldd       12,x
                    std       >$03C0,u
                    ldd       14,x
                    std       >$03C2,u
                    ldd       <$10,x
                    std       >$0500,u
                    ldd       <$12,x
                    std       >$0502,u
                    ldb       12,s
                    bne       a27@
                    ldd       <$14,x
                    std       >$0640,u
                    ldd       <$16,x
                    std       >$0642,u
a27@                leau      4,u
* DrawTextNext: fetches the next character, ends at NUL
DrawTextNext        ldx       9,s
                    leax      1,x
                    stx       9,s
                    ldb       -1,x
                    stb       ,s
                    bne       DrawTextGlyph
                    leas      1,s
                    puls      u,pc
* Small one-bit pictures (a byte a row), pointed to by the data image's FrRm299-FrRm326 table entries
L3050               equ       *
                    fcb       $0E,$18
                    fcc       /0000/
                    fcb       $18,$0E,$00
L3059               equ       *
                    fcb       $06,$06,$06,$06,$06
                    fcb       $06,$06,$06,$00
L3062               equ       *
                    fcb       $06,$0C,$18,$30
                    fcb       $30,$18,$0C,$06,$00
L306B               equ       *
                    fcb       $C0,$60,$30
                    fcb       $18,$18,$30,$60,$C0,$00
L3074               equ       *
                    fcb       $70,$18
                    fcb       $0C,$0C,$0C,$0C,$18,$70,$00
L307D               equ       *
                    fcb       $60,$60,$60,$60,$60,$60,$60,$60
                    fcb       $00
L3086               equ       *
                    fcb       $60,$30,$18,$0C,$0C,$18,$30
                    fcb       $60,$00
L308F               equ       *
                    fcb       $60,$30,$18,$0C,$0C,$18
                    fcb       $30,$60,$00
L3098               equ       *
                    fcb       $00,$0F,$0C,$0C,$0C
                    fcb       $0C,$0C,$0C,$0C,$0F,$00,$00
L30A4               equ       *
                    fcb       $00
                    fcb       $0F,$0C,$0D,$0C,$0C,$0C,$0D,$0C
                    fcb       $0F,$00,$00
L30B0               equ       *
                    fcb       $00,$00,$00,$1F,$1F
                    fcb       $19,$19,$19,$19,$19,$19,$00
L30BC               equ       *
                    fcb       $19
                    fcb       $19,$19,$19,$19,$19,$19,$1F,$00
                    fcb       $00,$00,$00
L30C8               equ       *
                    fcb       $19,$19,$19,$19,$19
                    fcb       $19,$19,$19,$19,$19,$19,$00
L30D4               equ       *
                    fcb       $00
                    fcb       $00,$00,$7F,$7F,$78,$7F,$7F,$00
                    fcb       $00,$00,$00
L30E0               equ       *
                    fcb       $00,$FF,$03,$03,$03
                    fcb       $03,$03,$03,$03,$FF,$00,$00
L30EC               equ       *
                    fcb       $00
                    fcb       $FF,$03,$9B,$F3,$63,$F3,$9B,$03
                    fcb       $FF,$00,$00
L30F8               equ       *
                    fcb       $00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00
L3104               equ       *
                    fcb       $00
                    fcb       $00,$00,$00
L3110               equ       *
                    fcb       $00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00
L311C               equ       *
                    fcb       $00,$00,$00
                    fcb       $E0,$F8,$3C,$F8,$E0
                    fcb       $00,$00,$00,$00
* curinit: copies the note-head image pointers at data $01E8/$01E6/$01E4/$01E2 into the image-pointer fields of symbol records 28-31 ($03BD/$03C3/$03C9/$03CF)
curinit     pshs      u
                    ldd       >FrData_reserved_01E8
                    std       >FrData_reserved_03BD
                    ldd       >FrData_reserved_01E6
                    std       >FrData_reserved_03C3
                    ldd       >FrData_reserved_01E4
                    std       >FrData_reserved_03C9
                    ldd       >FrData_reserved_01E2
                    std       >FrData_reserved_03CF
                    puls      u,pc
* setcurse: (n) selects music symbol n (0-37, anything else -> 1): <curcurse = n; the 6-byte record at cursors ($0311)+n*6 gives <ctop, <cbot, <cleft, <cright (bytes 0-3, sign-extended) and <curse (word 4); <cheight = ctop+cbot+1, <cwid = cleft+cright+1
setcurse        pshs      u
                    ldd       4,s
                    blt       a28@
                    ldd       4,s
                    cmpd      #$0026              38 records, 0..37
                    blt       LoadSymbolRec
a28@                ldd       #$0001
                    std       4,s
* LoadSymbolRec: unpacks the symbol record into the direct page
LoadSymbolRec       ldd       4,s
                    std       <curcurse
                    ldd       4,s
                    pshs      a,b
                    ldd       #$0006
                    lbsr      Mul16
                    ldx       #cursors
                    leax      d,x
                    leau      ,x
                    ldb       2,u
                    sex
                    std       <cleft
                    ldb       3,u
                    sex
                    std       <cright
                    ldb       ,u
                    sex
                    std       <ctop
                    ldb       1,u
                    sex
                    std       <cbot
                    ldd       <ctop
                    addd      <cbot
                    addd      #$0001
                    std       <cheight
                    ldd       <cleft
                    addd      <cright
                    addd      #$0001
                    std       <cwid
                    ldd       4,u
                    std       <curse
                    puls      u,pc
* SymMap: maps the symbol bank's two blocks (FrSym) into the window's slots, dropping the window (FrWin = $FF:
* the next ScrAddr maps it afresh): U = the bank's address, or U = 0 and Z set when there is no bank or the map
* failed. FrWinP holds the bank's address meanwhile so SymUnmap can clear it; SymUnmap is always safe. Keeps D, X, Y.
SymMap              pshs      d,x
                    ldu       <FrWinP
                    beq       sm1@
                    ldb       #$02
                    os9       F$ClrBlk
sm1@                clra
                    clrb
                    std       <FrWinP
                    ldb       #$FF
                    stb       <FrWin
                    ldx       >FrSym
                    beq       sm8@                no bank
                    ldb       #$02                both blocks
                    os9       F$MapBlk
                    bcc       sm2@
                    ldu       #$0000
                    bra       sm9@
sm2@                stu       <FrWinP
                    bra       sm9@
sm8@                ldu       #$0000
sm9@                cmpu      #$0000
                    puls      d,x,pc
* SymUnmap: unmaps whatever the window slots hold (FrWinP) and always sets FrWin = $FF, so the next ScrWin maps
* the picture pair afresh instead of drawing through FrWinP = 0. Keeps every register.
SymUnmap            pshs      d,u
                    ldu       <FrWinP
                    beq       su9@
                    ldb       #$02
                    os9       F$ClrBlk
                    clra
                    clrb
                    std       <FrWinP
su9@                ldb       #$FF
                    stb       <FrWin              nothing mapped: the next ScrAddr maps the picture afresh
                    puls      d,u,pc
* DOUBLE BUFFERING: two ten-block bitmaps, bitmap 0 (s9 allocates it, shown first) and bitmap 1 (DblBufInit
* allocates it and copies bitmap 0 into it). FrBM0, the base every primitive draws through, is always the HIDDEN
* one, FrBMShown the shown one (0 = single-buffered: everything draws straight onto bitmap 0). A batch ends at
* pollmark ($CA, before s9 waits for a key or the mouse), at gets, and before a condensed menu's pointer loop:
* Present waits for a start of frame (WaitBlank), shows the hidden bitmap (ShowPage: SS.PScrn, layer 0), swaps
* the bases and DMA-copies the blocks the batch touched - FrDirty, a bit a block for picture blocks 0-7, set by
* ScrWin (DirtyMark) for the CPU primitives and by DirtyRange for the DMA fills - from the shown bitmap to the
* hidden one, so the hidden one is current again. A batch that drew nothing flips nothing. Hover inversions
* (nboxa, nboxh, the condensed menu rows) go onto both pages, the shown one first, with FrNoDirty set. s9gui
* draws nothing in rows 192-239 (s9's keyboard area); blocks 8-9 are copied only here. Needs the DMA engine.
DblBufInit          pshs      d,x,y,u
                    clr       >FrBMShown          single-buffered until everything below succeeds
                    tst       >FrDma
                    lbeq      dbi9@
                    lda       #$02                path 2 = /term
                    ldb       #SS.AScrn           bitmap 1, ten blocks (type 0 = 320x240)
                    ldx       #$0000
                    ldy       #$0001
                    os9       I$SetStt            X = its first block
                    bcc       dbi1@
                    cmpb      #E$WADef            still there from an earlier run: X is its block
                    lbne      dbi9@
dbi1@               pshs      x,u                 bitmap 1's HIRES4 bit through grfdrv
                    lda       #$02                (SS.BmCfg) - SS.AScrn turned it on with CLUT 0; HIRES4 is
                    ldb       #SS.BmCfg           a per-plane bit, not $FFCB; palette group 0
                    ldx       #$FFFF
                    ldy       #$0001
                    ldu       #$0100
                    os9       I$SetStt
                    puls      x,u
                    tfr       x,d
                    pshs      b                   ,s bitmap 1's first block
* bitmap 0 -> bitmap 1, all ten blocks, two runs (a count is sixteen bits)
                    lda       <FrBM0
                    ldb       ,s                  bitmap 1
                    ldx       #0
                    ldu       #0
                    ldy       #5*8192
                    lbsr      DmaCopy
                    lbcs      dbi8@
                    lda       <FrBM0
                    adda      #5
                    ldb       ,s
                    addb      #5
                    ldx       #0
                    ldu       #0
                    ldy       #5*8192
                    lbsr      DmaCopy
                    lbcs      dbi8@
                    clr       >FrEcho
* bitmap 0 stays shown; from here everything draws into bitmap 1
                    lda       <FrBM0
                    sta       >FrBMShown          double buffering is on
                    sta       >FrBM0Blk
                    ldb       ,s
                    stb       <FrBM0
                    lda       #$FF
                    sta       <FrWin
                    clr       >FrShown
                    clr       <FrDirty
                    clr       >FrNoDirty
                    lda       >FrBM0Blk
                    lbsr      ShowPage            layer 0 shows bitmap 0
dbi8@               leas      1,s
dbi9@               puls      d,x,y,u,pc
* SwapBase: the hidden and shown bases exchange, the window re-anchored. Nothing when single-buffered. Keeps all.
SwapBase            tst       >FrBMShown
                    beq       sb9@
                    pshs      d
                    lda       <FrBM0
                    ldb       >FrBMShown
                    sta       >FrBMShown
                    stb       <FrBM0
                    lda       #$FF
                    sta       <FrWin
                    puls      d
sb9@                rts
* ShowPage: A = the picture block to display (FrBM0Blk = bitmap 0, else bitmap 1). Unmaps the window pair (the
* map's two free slots hold it; the next draw re-anchors it), then selects that bitmap as layer 0's source through
* grfdrv (SS.PScrn on path 2), which keeps it per terminal. Keeps all.
ShowPage            pshs      d,x,y,u
                    pshs      a                   the block
                    ldu       <FrWinP
                    beq       sg1@
                    ldb       #2
                    os9       F$ClrBlk
                    clra
                    clrb
                    std       <FrWinP
                    ldb       #$FF
                    stb       <FrWin
* Both bitmaps stay enabled; layers 1 and 2 show no plane (s9 sets them at start), so only layer 0's bitmap is seen.
sg1@                ldy       #$0000              bitmap 0 ...
                    lda       ,s
                    cmpa      >FrBM0Blk
                    beq       sg2@
                    ldy       #$0001              ... or bitmap 1
sg2@                lda       #$02
                    ldb       #SS.PScrn
                    ldx       #$0000              layer 0
                    os9       I$SetStt
sg9@                puls      a
                    puls      d,x,y,u,pc
* WaitBlank: waits for the next start of frame through the OS. The system tick is VICKY's start-of-frame
* interrupt (the clock driver owns INT_PENDING_0), so sleeping one tick wakes just after a frame starts.
* Keeps every register.
WaitBlank           pshs      x
                    ldx       #1
                    os9       F$Sleep             until the next tick: the start of the next frame
                    puls      x,pc
* DirtyMark: A = a picture block index the drawing is about to touch: it and the next one (the window maps a
* pair) go into FrDirty; block 7 is the last one tracked (the banner blocks are never redrawn). Nothing while
* FrNoDirty (a both-bitmap inversion). Keeps every register.
DirtyMark           tst       >FrNoDirty
                    bne       dm9@
                    pshs      d,x
                    cmpa      #7
                    bls       dm1@
                    lda       #7
dm1@                leax      >DirtyTab,pcr
                    ldb       a,x
                    orb       <FrDirty
                    stb       <FrDirty
                    puls      d,x
dm9@                rts
DirtyTab            fcb       3,6,12,24,48,96,192,128
* DirtyRange: D = a picture offset, X = rows from it downward -> every picture block those rows cover goes into
* FrDirty, the first block through the last (block 7 is the last tracked). Every DMA that draws into the picture
* calls this (RectRowOff, yclear, the staff-line fill, BoxFill); the CPU primitives mark through ScrWin.
* Nothing while FrNoDirty. Keeps every register.
DirtyRange          tst       >FrNoDirty
                    bne       drg9@
                    pshs      d,x,y
                    pshs      d                   ,s the offset
                    tfr       x,d
                    pshs      b                   ,s rows  1,s the offset
                    clra
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    adda      ,s+                 D = rows x 320
                    addd      ,s                  + the offset = the byte past the last row
                    subd      #1                  the last byte
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra                          A = the last block
                    ldb       ,s                  the offset's high byte
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    lsrb                          B = the first block
                    leas      2,s
                    cmpa      #7
                    bls       drg1@
                    lda       #7
drg1@               cmpb      #7
                    bls       drg2@
                    ldb       #7
drg2@               leax      >BitTab,pcr
drg3@               pshs      a
                    lda       b,x                 block B's bit
                    ora       <FrDirty
                    sta       <FrDirty
                    puls      a
                    incb
                    pshs      a
                    cmpb      ,s+                 through the last block
                    bls       drg3@
                    puls      d,x,y
drg9@               rts
BitTab              fcb       1,2,4,8,16,32,64,128
* Present: the batch's end: flip to the hidden page and copy the touched blocks back. Keeps every register.
Present             tst       >FrBMShown
                    lbeq      pr9@
                    tst       <FrDirty
                    lbeq      pr9@                the batch drew nothing: no flip
                    pshs      d,x,y,u
* FrEcho, when set, counts down one a flip (alcurset stores 0 in it)
                    lda       >FrEcho
                    beq       pr0@
                    deca
                    sta       >FrEcho
pr0@                lbsr      WaitBlank           the flip lands just after a frame starts
                    lda       >FrShown
                    eora      #1
                    sta       >FrShown            bookkeeping only
                    lda       <FrBM0              the page just drawn
                    lbsr      ShowPage            layer 0 shows it
                    lbsr      SwapBase            draw into the one just hidden
* the touched blocks, shown -> hidden, one run from the lowest dirty block over n blocks to the highest one
                    clra
                    ldb       <FrDirty
                    clr       <FrDirty
                    ldx       #0                  X = the lowest dirty block
pr2@                lsrb                          bit 0 -> carry
                    bcs       pr3@
                    leax      1,x
                    bra       pr2@
pr3@                ldy       #1                  n: the block found, plus every one up to the highest set bit
pr4@                tstb
                    beq       pr5@
                    lsrb
                    leay      1,y
                    bra       pr4@
pr5@                tfr       x,d
                    addb      <FrBM0
                    pshs      b                   the destination block (hidden), first: the next tfr x,d would clear A
                    tfr       x,d
                    addb      >FrBMShown
                    tfr       b,a                 A = the source block (shown)
                    puls      b                   B = the destination
                    pshs      d
                    tfr       y,d                 n blocks
                    cmpb      #8
                    blo       pr6@
                    ldy       #$FFFF              all eight: one byte short of 65,536 (the banner's last, never redrawn)
                    bra       pr7@
pr6@                tfr       b,a
                    lsla
                    lsla
                    lsla
                    lsla
                    lsla
                    clrb
                    tfr       d,y                 Y = blocks * 8192
pr7@                puls      d
                    ifdef     PAGECHECK
                    pshs      d,y                 ,s the source and destination blocks  2,s the count: PageCheck reads them
                    endc
                    ldx       #0
                    ldu       #0
                    lbsr      DmaCopy
                    ifdef     PAGECHECK
                    lbsr      PageCheck           compares the copy byte for byte, logs mismatches
                    leas      4,s
                    endc
                    puls      d,x,y,u
pr9@                rts
                    ifdef     PAGECHECK
* PageCheck (assembled only with -DPAGECHECK, a diagnostic build): after Present's page copy, every copied block
* is read back on the CPU - the shown block and its hidden copy mapped one at a time into the two free slots the
* window pair just left - and compared byte for byte. Any difference prints one line on path 2:
*   P cccc kkoooowwggtttt
* cccc the mismatch count, kk the blocks compared, oooo the first mismatch's offset in its block, ww the source
* byte there, gg the byte the DMA left, tttt how many mismatches carry the source byte just BEFORE theirs (a
* stale read). 2,s = the blocks (A source, B destination), 4,s = the count ($FFFF for all eight: seven compared).
* Keeps every register. Never shipped: s9gui must stay under $7D00 bytes.
PageCheck           pshs      d,x,y,u             10,s the blocks  12,s the count
                    leas      -42,s               ,s cnt  2,s stale  4,s k  5,s n  6,s off  8,s want  9,s got
*                                                 10,s src map  12,s dst map  14,s line (28)   +42: 52,s blocks 54,s count
                    clra
                    clrb
                    std       ,s
                    std       2,s
                    sta       4,s
                    lda       54,s                the count's high byte: blocks x 32 ($FF for all eight -> 7)
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra
                    sta       5,s                 n
                    beq       pc9@
pcblk@              ldb       4,s
                    addb      52,s                the source block k
                    clra
                    tfr       d,x
                    ldb       #1
                    os9       F$MapBlk
                    bcs       pc9@
                    stu       10,s
                    ldb       4,s
                    addb      53,s                the destination block k
                    clra
                    tfr       d,x
                    ldb       #1
                    os9       F$MapBlk
                    bcs       pcu1@
                    stu       12,s
                    ldx       10,s
                    ldu       12,s
                    ldy       #DAT.BlSz
pccmp@              lda       ,x+
                    cmpa      ,u+
                    bne       pcmis@
pcnext@             leay      -1,y
                    bne       pccmp@
                    ldu       12,s
                    ldb       #1
                    os9       F$ClrBlk
pcu1@               ldu       10,s
                    ldb       #1
                    os9       F$ClrBlk
                    inc       4,s
                    ldb       4,s
                    cmpb      5,s
                    blo       pcblk@
                    ldd       ,s
                    bne       pclog@
pc9@                leas      42,s
                    puls      d,x,y,u,pc
* a mismatch: A = the source byte, -1,u the copy's; count it, note the first, and whether it is the byte before
pcmis@              pshs      a
                    ldd       1,s
                    addd      #1
                    std       1,s
                    cmpd      #1
                    bne       pcm1@
                    lda       ,s
                    sta       9,s                 want
                    lda       -1,u
                    sta       10,s                got
                    tfr       x,d
                    subd      11,s                the source map base -> the offset, + 1 past the byte
                    subd      #1
                    std       7,s
pcm1@               lda       -1,u                the copy's byte ...
                    cmpa      -2,x                ... against the source byte before this one
                    bne       pcm2@
                    ldd       3,s
                    addd      #1
                    std       3,s
pcm2@               puls      a
                    bra       pcnext@
* pchex@: A -> two hex digits at X, X advanced. Keeps everything else.
pchex@              pshs      a
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       pchn@
                    puls      a
                    anda      #$0F
pchn@               adda      #'0
                    cmpa      #'9
                    bls       pchs@
                    adda      #7
pchs@               sta       ,x+
                    rts
* the line: P cccc kkoooowwggtttt CR (22 bytes), on path 2
pclog@              leax      14,s
                    lda       #'P
                    sta       ,x+
                    lda       #C$SPAC
                    sta       ,x+
                    lda       ,s
                    bsr       pchex@
                    lda       1,s
                    bsr       pchex@
                    lda       #C$SPAC
                    sta       ,x+
                    lda       4,s
                    bsr       pchex@
                    lda       6,s
                    bsr       pchex@
                    lda       7,s
                    bsr       pchex@
                    lda       8,s
                    bsr       pchex@
                    lda       9,s
                    bsr       pchex@
                    lda       2,s
                    bsr       pchex@
                    lda       3,s
                    bsr       pchex@
                    lda       #C$CR
                    sta       ,x+
                    leax      14,s
                    lda       #2
                    ldy       #22
                    os9       I$WritLn
                    lbra      pc9@
                    endc
* keynop: command $C5 (14 argument bytes) does nothing: s9 draws the piano keys (rows 192-239) itself. The
* entry stays in the command table, which is a data image (never insert or remove entries).
keynop              rts
* ToolHide / ToolSave: restore / save the toolbox rectangle (48 columns from FrToolX, rows tooly..tooly+22, the
* brush box included) at FrToolSave in the FrSave arena: ($4000-$087A)*4 = 56856, 4416 bytes. The other
* window saves end below (FrKeyBank-$087A)*4 = 50148. ToolRect: D = bottom row, X = bytblt mode, U = token.
ToolHide            tst       >FrToolUp
                    beq       tbret@
                    clr       >FrToolUp
                    ldd       >FrToolY
                    ldx       #1                  restore original colors
                    ldu       #FrToolSave
                    bra       ToolRect
ToolSave            tst       >FrToolUp
                    bne       tbret@
                    ldd       <tooly
                    std       >FrToolY
                    inc       >FrToolUp
                    ldx       #0                  save untouched background
                    ldu       #FrToolSave
ToolRect            pshs      d,x,u
                    pshs      u                   STACK OFFSET: ToolRect frame, save-arena token
                    addd      #22
                    pshs      d                   STACK OFFSET: ToolRect frame, top Y
                    ldd       >FrToolX
                    addd      #47
                    pshs      d                   STACK OFFSET: ToolRect frame, right column
                    ldd       6,s                 STACK OFFSET: ToolRect frame, saved bottom Y
                    pshs      d
                    ldd       >FrToolX
                    pshs      d                   STACK OFFSET: ToolRect frame, left column
                    pshs      x                   STACK OFFSET: ToolRect frame, operation
                    lbsr      bytblt
                    leas      12,s
                    puls      d,x,u,pc
tbret@              rts
* ToolDrag: rftba with arg1 bit 7 set, rftba's saved U still on the stack. $80 captures the drawn toolbox
* into FrToolImage (arena bytes 50712-55127); $81 moves it to column arg2, row arg0: the old background back,
* the new one saved, the image pasted. Moves do not call drtools/drbrush.
ToolDrag            ldb       <arg1
                    cmpb      #$80
                    beq       tbcapture@
                    cmpb      #$81
                    bne       tbdragret@
                    ldb       <arg0
                    clra
                    cmpd      <tooly
                    bne       tbmove@
                    ldb       <arg2
                    cmpd      >FrToolX
                    beq       tbdragret@
tbmove@             equ       *
                    lbsr      ToolHide
                    ldb       <arg0
                    clra
                    std       <tooly
                    std       <brushy
                    ldb       <arg2
                    clra
                    std       >FrToolX
                    addd      #44
                    std       <brushx
                    lbsr      ToolSave
                    ldd       <tooly
                    ldx       #1                  paste the rendered toolbox
                    bra       tbimage@
tbcapture@          ldd       <tooly
                    ldx       #0                  capture before restoring its background
tbimage@            ldu       #FrToolImage
                    lbsr      ToolRect
tbdragret@          puls      u,pc
* ToolPixelX: D = legacy pixel X -> D - 128 + FrToolX*8, relative to the movable toolbox. Keeps X.
ToolPixelX          pshs      x
                    subd      #128
                    tfr       d,x
                    ldd       >FrToolX
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    leax      d,x
                    tfr       x,d
                    puls      x,pc
drtools             pshs      u
                    leas      -15,s
* drtools: draws the toolbox; the icons are transparent (FrOpaque is not set here)
                    clra
                    clrb
                    std       ,s
                    ldd       #$00B8
                    pshs      a,b
                    ldx       #$004B
                    pshs      x
                    leax      4,s
                    pshs      x
                    lbsr      argfix
                    leas      6,s
                    ldb       <$16,s
                    beq       drtools_1
                    ldd       #$0003
                    bra       drtools_2
drtools_1               clra
                    clrb
drtools_2               stb       11,s
                    clra
                    clrb
                    stb       13,s
                    ldd       <$13,s
                    cmpd      #$0001
                    bne       drtools_3
                    ldd       #$0020
                    bra       drtools_4
drtools_3               ldd       #$0001
drtools_4               std       8,s
                    stb       12,s
                    ldd       #$0002
                    stb       14,s
                    ldd       8,s
                    cmpd      #$0020
                    bne       drtools_5
                    ldd       #$000B
                    bra       drtools_6
drtools_5               ldd       #$0007
drtools_6               std       6,s
* The toolbox interior, dots 132-483 of rows tooly..tooly+22 (bytes 66-241 of a row), is filled with
* COLORS_TOOLBOXBG and nothing outside it. Then FrDynaInk = 1: the frame sides (vpatdyn), the strips (dyna1)
* and the icons (dyna2) OR their ink dots over that fill instead of storing their paper dots.
                    pshs      u
                    ldd       <tooly
                    addd      #$0016
                    ldx       >FrToolX
                    lbsr      ScrPos              U = column 16 (dot 128) of the top row
                    ldx       #COLORS_TOOLBOXBG*$11 two toolbox background dots
                    ldd       #23*256+176         23 rows of bytes 66-241
                    lbsr      FillRows
                    puls      u
                    ldb       #$01
                    stb       >FrDynaInk
                    ldd       <$13,s
                    cmpd      #$0002
                    bne       drtools_7
                    ldd       #$0003
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0002
                    pshs      a,b
                    ldd       #$001A
                    pshs      a,b
                    ldd       <tooly
                    addd      #$0015
                    pshs      a,b
                    ldd       >FrToolX
                    addd      #1
                    pshs      a,b
                    lbsr      wcreate
                    leas      12,s
drtools_7               ldd       <tooly
                    addd      #$0016
                    pshs      a,b
                    ldd       >FrToolX
                    addd      #44
                    pshs      a,b
                    ldd       <tooly
                    pshs      a,b
                    ldd       >FrToolX
                    pshs      a,b
                    lbsr      boxc
                    leas      8,s
                    clra
                    clrb
                    std       4,s
                    ldd       >FrToolX
                    lbra      drtools_22
drtools_8               ldd       <$13,s
                    cmpd      #$0002
                    bne       drtools_9
                    ldd       4,s
                    cmpd      #$000D
                    lble      drtools_21
drtools_9               ldd       4,s
                    cmpd      #$0007
                    bgt       drtools_10
                    ldd       4,s
                    stb       10,s
                    ldd       #$0001
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       12,s
                    addd      <tooly
                    pshs      a,b
                    ldd       14,s
                    addd      <tooly
                    pshs      a,b
                    ldd       12,s
                    addd      #$0001
                    pshs      a,b
                    leax      <$16,s
                    pshs      x
                    lbsr      drawnr
                    leas      14,s
                    lbra      drtools_21
drtools_10               ldd       4,s
                    cmpd      #$0008
                    bne       drtools_11
                    ldd       #$0001
                    pshs      a,b
                    ldd       <tooly
                    addd      #$0016
                    pshs      a,b
                    ldd       <tooly
                    pshs      a,b
                    ldd       #$0110
                    lbsr      ToolPixelX
                    pshs      a,b
                    lbsr      vline
                    leas      8,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       <tooly
                    addd      #$0016
                    pshs      a,b
                    ldd       <tooly
                    pshs      a,b
                    ldd       #$0155
                    lbsr      ToolPixelX
                    pshs      a,b
                    lbsr      vline
                    leas      8,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       <tooly
                    addd      #$000B
                    pshs      a,b
                    ldd       #$0155
                    lbsr      ToolPixelX
                    pshs      a,b
                    ldd       #$0110
                    lbsr      ToolPixelX
                    pshs      a,b
                    lbsr      hline
                    lbra      drtools_20
drtools_11               ldd       4,s
                    cmpd      #$0009
                    bne       drtools_12
                    ldd       #$0001
                    pshs      a,b
                    ldd       <tooly
                    addd      #$0010
                    pshs      a,b
                    ldd       #$011E
                    lbsr      ToolPixelX
                    pshs      a,b
                    ldd       #$0118
                    lbsr      ToolPixelX
                    pshs      a,b
                    lbsr      hline
                    leas      8,s
                    ldx       #$1175
                    pshs      x
                    ldd       #$0004
                    pshs      a,b
                    ldd       <tooly
                    addd      #$0006
                    lbra      drtools_19
drtools_12               ldd       4,s
                    cmpd      #$000C
                    bgt      drtools_13
                    ldd       4,s
                    addd      #$FFF7
                    pshs      a,b
                    ldd       #$0006
                    lbsr      Mul16
                    ldx       #$1155
                    leax      d,x
                    pshs      x
                    ldd       #$0006
                    pshs      a,b
                    ldd       <tooly
                    addd      #$0012
                    pshs      a,b
                    ldd       8,s
                    addd      #$0001
                    pshs      a,b
                    lbsr      dyna1
                    leas      8,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       6,s
                    addd      #$FFF8
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$116D
                    leax      d,x
                    pshs      x
                    ldd       #$0004
                    pshs      a,b
                    ldd       <tooly
                    addd      #$0007
                    pshs      a,b
                    ldd       10,s
                    addd      #$0001
                    pshs      a,b
                    lbsr      put2
                    leas      10,s
                    lbra      drtools_21
drtools_13               ldd       4,s
                    cmpd      #$000D
                    bne      drtools_16
                    ldd       #$0012
                    subd      6,s
                    addd      <tooly
                    std       ,s
                    ldd       #$0003
                    stb       >qrest
                    ldd       #$0001
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    ldd       12,s
                    addd      #$0001
                    pshs      a,b
                    ldd       <$14,s
                    cmpd      #$0020
                    bne       drtools_14
                    ldx       #qnote
                    bra       drtools_15
drtools_14               ldx       #qrest
drtools_15               tfr       x,d
                    pshs      a,b
                    lbsr      drawnr
                    leas      14,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       <tooly
                    addd      #$0016
                    pshs      a,b
                    ldd       <tooly
                    pshs      a,b
                    ldd       #$0166
                    lbsr      ToolPixelX
                    pshs      a,b
                    lbsr      vline
                    bra      drtools_20
drtools_16               ldd       4,s
                    addd      #$FFF5
                    std       ,s
                    cmpd      #$0008
                    bne       drtools_17
                    ldd       <curcurse
                    cmpd      #$0008
                    bne       drtools_17
                    ldd       #$0012
                    bra       drtools_18
drtools_17               ldd       ,s
drtools_18               pshs      a,b
                    ldd       #$0012
                    lbsr      Mul16
                    ldx       #$0BDF
                    leax      d,x
                    pshs      x
                    ldd       #$0009
                    pshs      a,b
                    ldd       <tooly
                    addd      #$0014
                    pshs      a,b
                    ldd       8,s
                    addd      #$0001
                    pshs      a,b
                    lbsr      dyna2
                    leas      8,s
                    ldd       4,s
                    addd      #$FFFC
                    pshs      a,b
                    ldd       #$0012
                    lbsr      Mul16
                    ldx       #$0BDF
                    leax      d,x
                    pshs      x
                    ldd       #$0009
                    pshs      a,b
                    ldd       <tooly
                    addd      #$000A
drtools_19               pshs      a,b
                    ldd       8,s
                    addd      #$0001
                    pshs      a,b
                    lbsr      dyna2
drtools_20               leas      8,s
drtools_21               ldd       4,s
                    addd      #$0001
                    std       4,s
                    subd      #$0001
                    ldd       2,s
                    addd      #$0002
drtools_22               std       2,s
                    ldd       4,s
                    cmpd      #$0015
                    lblt      drtools_8
                    clr       >FrDynaInk
                    leas      15,s
                    puls      u,pc
scroll               pshs      a,b,x,y,u
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0006
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    lbsr      yclear
                    leas      6,s
                    ldd       #$0007
                    pshs      a,b
                    ldd       #$027E
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    lbsr      box
                    leas      8,s
                    clra
                    clrb
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$027D
                    pshs      a,b
                    ldd       #$0003
                    pshs      a,b
                    lbsr      hline
                    leas      8,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0007
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0025
                    pshs      a,b
                    lbsr      vline
                    leas      8,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0007
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0259
                    pshs      a,b
                    lbsr      vline
                    leas      8,s
                    leax      >L38F7,pcr
                    pshs      x
                    ldd       #$0005
                    pshs      a,b
                    ldd       #$0005
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    lbsr      dyna2
                    leas      8,s
                    leax      >L3902,pcr
                    pshs      x
                    ldd       #$0005
                    pshs      a,b
                    ldd       #$0005
                    pshs      a,b
                    ldd       #$004D
                    pshs      a,b
                    lbsr      dyna2
                    leas      8,s
                    ldd       10,s
                    lbeq      L3633_3
                    ldd       12,s
                    lbsr      L6B9A
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    bsr       L3603
                    neg       <FrData_reserved_0000
                    fcb       $02,$32               with the neg: the long constant $00000232; bsr pushes its address
L3603               puls      x
                    lbsr      L6A23
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       14,s
                    lbsr      L6B9A
                    lbsr      L6A98
                    ldd       >FrData_reserved_0010
                    addd      #$0027
                    std       4,s
                    ldd       14,s
                    lbsr      L6B9A
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    bsr       L3633
                    neg       <FrData_reserved_0000
                    fcb       $02,$32               with the neg: the long constant $00000232; bsr pushes its address
L3633               puls      x
                    lbsr      L6A23
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       14,s
                    lbsr      L6B9A
                    lbsr      L6A98
                    ldd       >FrData_reserved_0010
                    addd      #$0027
                    std       2,s
                    ldd       #$0001              the location thumb box start: row 1 (the bottom)
                    bra       L3633_2
L3633_1             ldd       #$0001              draw location thumb, loop
                    pshs      a,b
                    ldd       2,s
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    lbsr      hline
                    leas      8,s
                    ldd       ,s
                    addd      #$0001
L3633_2               std       ,s
                    ldd       ,s
                    cmpd      #$0006              ending row 6 (the top of the moving thumb) of the location box
                    bls       L3633_1
* The lower edge, canvas row 0, is drawn last so neither the arrows nor the moving thumb can leave the
* scroll bar open along the picture's bottom edge: hline(x1=0, x2=638, y=0, color=1).
L3633_3               ldd       #$0001
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$027E
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    lbsr      hline
                    leas      8,s
                    leas      6,s
                    puls      u,pc
* dmenbar: the top menu bar. The ten ordinary titles are butted together from column MenuBarCol0 (widths:
* MenuBarWidths, the same list as equates.asm's MenuBarCi columns that s9 builds its hover / click targets
* from); the six drive labels go at the columns s9 sent with $B7. Title pointers: barlabs[] at data $03FB.
* Frame: ,s scratch  2,s (byte)  3,s the title index  5,s its column.
dmenbar             pshs      u
                    leas      -7,s
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$00BF
                    pshs      a,b
                    ldd       #$00B9
                    pshs      a,b
                    lbsr      yclear              rows 185-191 to paper
                    leas      6,s
* The bar is paper text on black from raster row 0 (canvas 191) down: the glyphs go in as ink on paper, top
* row 190 = raster row 1 (phrase puts the top at y+4, y = 186), sixth row 185; then rows 185-191 are
* complemented (bytblt 3) across the width. The hover highlighter complements a title's rows back: black on paper.
                    ldd       #MenuBarCol0
                    std       5,s
                    clra
                    clrb
                    std       3,s
dmenbar_3           ldd       3,s
                    cmpd      #MenuBarTitleItems
                    bge       dmenbar_6
                    aslb
                    rola
                    ldx       #FrBarLabsIm+FrDA   barlabs[]
                    ldd       d,x                 the label's module offset
                    leau      >ModuleBase,pcr
                    leau      d,u                 the label, its own space each side
                    clra
                    clrb
                    pshs      a,b                 all six rows
                    pshs      u
                    ldd       #MenuBarY1+1        top row 190 (raster row 1)
                    pshs      a,b
                    ldd       11,s                the column
                    pshs      a,b
                    lbsr      phrase
                    leas      8,s
                    ldd       3,s
                    leax      >MenuBarWidths,pcr
                    ldb       b,x                 the title's width in columns
                    clra
                    addd      5,s
                    std       5,s                 the next title's column
                    ldd       3,s
                    addd      #$0001
                    std       3,s
                    bra       dmenbar_3
* The six drive labels: each at the column s9 sent with $B7 (FrDriveText), so they stay flush right.
dmenbar_6           clra
                    clrb
                    std       3,s                 shortcut index
                    ldd       #MenuBarC10
                    std       5,s                 shortcut column
dmenbar_short       ldd       3,s
                    cmpd      #6
                    bge       dmenbar_finish
                    lda       #5
                    mul
                    ldu       #FrDriveText
                    leau      d,u
                    clra
                    ldb       ,u+                 the column sent with $B7
                    std       5,s
                    tst       1,u                 absent slot: no text and no highlight
                    beq       dmenbar_next
                    clra
                    clrb
                    pshs      a,b
                    pshs      u
                    ldd       #MenuBarY1+1
                    pshs      a,b
                    ldd       11,s
                    pshs      a,b
                    lbsr      phrase
                    leas      8,s
dmenbar_next        ldd       3,s
                    addd      #1
                    std       3,s
                    bra       dmenbar_short
* the bar complemented: bytblt(3, 0, MenuBarY1, 79, MenuBarY2, 0) - the six text rows plus the line above, full width
dmenbar_finish      clra
                    clrb
                    pshs      a,b                 no buffer
                    ldd       #MenuBarY2          y2 = 191: the black line on raster row 0 is complemented too
                    pshs      a,b                 y2 = 191
                    ldd       #$004F
                    pshs      a,b                 x2 = column 79
                    ldd       #MenuBarY1
                    pshs      a,b                 y1 = 185
                    clra
                    clrb
                    pshs      a,b                 x1 = column 0
                    ldd       #$0003
                    pshs      a,b                 invert
                    lbsr      bytblt
                    leas      12,s
                    leas      7,s
                    puls      u,pc
* MenuBarWidths: the ten ordinary titles' widths in columns.
MenuBarWidths       fcb       MenuBarW0,MenuBarW1,MenuBarW2,MenuBarW3,MenuBarW4
                    fcb       MenuBarW5,MenuBarW6,MenuBarW7,MenuBarW8,MenuBarW9
* SetDriveLabel: command $B7 (slot, column, char1, char2; char2 0 for a one-character name) -> slot's FrDriveText record: column, space, char1, char2, NUL. Slot >= 6 is ignored.
SetDriveLabel       pshs      d,x
                    ldb       <arg0
                    cmpb      #6
                    bhs       sdlret@
                    lda       #5
                    mul
                    ldx       #FrDriveText
                    leax      d,x
                    lda       <arg1
                    sta       ,x
                    lda       #32
                    sta       1,x
                    lda       <arg2
                    sta       2,x
                    lda       <arg3
                    sta       3,x
                    clr       4,x
sdlret@             puls      d,x,pc
* mainbord: command $98, the score-entry margin: byte column 0, rows 8-184, cleared to paper (vpatdyn pattern 0).
* The original's decorative patterns ($A8, $15) at columns 0 and 79 are gone; column 79 is left alone, so a
* note head or beam that reaches the last column is not cut off.
mainbord            pshs      u
                    clra                          paper pattern
                    clrb
                    pshs      a,b
                    ldd       #$00B8
                    pshs      a,b
                    ldd       #$0008
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    lbsr      vpatdyn
                    leas      8,s
                    puls      u,pc
drbrush             pshs      a,b,u
                    ldx       #brushsave
                    pshs      x
                    ldd       <brushy
                    addd      #$0016
                    pshs      a,b
                    ldd       <brushx
                    addd      #$0003
                    pshs      a,b
                    ldd       <brushy
                    pshs      a,b
                    ldd       <brushx
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    lbsr      bytblt
                    leas      12,s
* The clear: paper over the twelve bytes between the box's sides only (dots 4-27 of its four columns, rows
* brushy..brushy+22), so dots 0-3 of column brushx (the toolbox's fill and frame-line ends) survive. The frame
* and the glyph are then inked (FrDynaInk).
                    pshs      u
                    ldd       <brushy
                    addd      #$0016
                    ldx       <brushx
                    lbsr      ScrPos              U = the box's first column on its top row
                    ldx       #COLORS_PAPER*$11    paper
                    ldd       #23*256+12          23 rows of its bytes 2-13
                    lbsr      FillRows
                    puls      u
                    ldb       #$01
                    stb       >FrDynaInk
                    ldd       8,s
                    cmpd      #$0016
                    beq       drbrush_1
                    ldd       8,s
                    cmpd      #$000F
                    beq       drbrush_1
                    ldd       8,s
                    cmpd      #$0008
                    bne       drbrush_4
drbrush_1               ldx       6,s
                    ldb       2,x
                    cmpb      #$20
                    bne       drbrush_2
                    ldd       #$000B
                    bra       drbrush_3
drbrush_2               ldd       #$0007
drbrush_3               std       ,s
                    ldd       #$0001
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       <brushy
                    addd      6,s
                    pshs      a,b
                    ldd       <brushy
                    addd      8,s
                    pshs      a,b
                    ldd       <brushx
                    addd      #$0001
                    pshs      a,b
                    ldx       #brush
                    pshs      x
                    lbsr      drawnr
                    leas      14,s
                    lbra      drbrush_9
drbrush_4               ldd       8,s
                    cmpd      #$0003
                    blt       drbrush_5
                    ldd       8,s
                    cmpd      #$0007
                    bgt       drbrush_5
                    ldd       8,s
                    addd      #$FFFD
                    pshs      a,b
                    ldd       #$0026
                    lbsr      Mul16
                    ldx       #$0DBB
                    leax      d,x
                    pshs      x
                    ldd       #$0013
                    pshs      a,b
                    ldd       <brushy
                    addd      #$0014
                    bra       drbrush_8
drbrush_5               ldd       8,s
                    cmpd      #$0009
                    blt       drbrush_9
                    ldd       8,s
                    cmpd      #$0015
                    bgt       drbrush_9
                    ldd       8,s
                    pshs      a,b
                    ldd       #$0006
                    lbsr      Mul16
                    ldx       #cursors
                    leax      d,x
                    ldd       4,x
                    pshs      a,b
                    ldd       10,s
                    cmpd      #$000A
                    blt       drbrush_6
                    ldd       10,s
                    cmpd      #$000D
                    bgt       drbrush_6
                    ldd       #$0004
                    bra       drbrush_7
drbrush_6               ldd       #$0008
drbrush_7               pshs      a,b
                    ldd       <brushy
                    addd      #$000E
drbrush_8               pshs      a,b
                    ldd       <brushx
                    addd      #$0001
                    pshs      a,b
                    lbsr      dyna2
                    leas      8,s
drbrush_9               ldd       <brushy
                    addd      #$0016
                    pshs      a,b
                    ldd       <brushx
                    addd      #$0003
                    pshs      a,b
                    ldd       <brushy
                    pshs      a,b
                    ldd       <brushx
                    pshs      a,b
                    lbsr      boxc
                    leas      8,s
                    clr       >FrDynaInk
                    leas      2,s
                    puls      u,pc
erbrush               pshs      u
                    ldx       #brushsave
                    pshs      x
                    ldd       <brushy
                    addd      #$0016
                    pshs      a,b
                    ldd       <brushx
                    addd      #$0003
                    pshs      a,b
                    ldd       <brushy
                    pshs      a,b
                    ldd       <brushx
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    lbsr      bytblt
                    leas      12,s
                    puls      u,pc
* bell: beeps (Beep) when the bell-enable byte FrBell is non-zero
bell                pshs      u
                    ldb       >FrBell
                    beq       a29@
                    lbsr      Beep
a29@                puls      u,pc
L38F7               equ       *  left arrow, 16 x 5 (scroll)
                    fcb       $0E,$00,$3C,$00,$FF,$FF,$3C,$00
                    fcb       $0E,$00,$00
L3902               equ       *  right arrow, 16 x 5 (scroll)
                    fcb       $00,$70,$00,$3C,$FF
                    fcb       $FF,$00,$3C,$00,$70,$00
* barlabs[] (fcurse.c): the ten menu-bar titles, original text and spacing.
str_barlabs_0               equ       *
                    fcc       / File/
                    fcb       $00
str_barlabs_1               equ       *
                    fcc       / Score/
                    fcb       $00
str_barlabs_2               equ       *
                    fcc       / Opts/
                    fcb       $00
str_barlabs_3               equ       *
                    fcc       / Inst/
                    fcb       $00
str_barlabs_4               equ       *
                    fcc       / MIDI/
                    fcb       $00
str_barlabs_5               equ       *
                    fcc       / Tools/
                    fcb       $00
str_barlabs_6               equ       *
                    fcc       / Goto/
                    fcb       $00
str_barlabs_7               equ       *
                    fcc       / Block/
                    fcb       $00
str_barlabs_8               equ       *
                    fcc       / Misc/
                    fcb       $00
str_barlabs_9               equ       *
                    fcc       /  Play/
                    fcb       $00
* menu-text fragments from the original: an empty line and the two scroll arrows
strMenuBlank               equ       *
                    fcb       $00
strMenuBlank_394F               equ       *
                    fcc       / <--/
                    fcb       $00
strMenuBlank_3954               equ       *
                    fcc       /--> /
                    fcb       $00
* hexc2i: (c) menu code digit: '0'-'9' -> 0-9, 'a'-'g' -> 10-16, anything else 0
hexc2i        pshs      u
                    ldb       5,s
                    sex
                    subd      #$0030
                    stb       5,s
                    blt       a30@
                    ldb       5,s
                    cmpb      #$09
                    bgt       a30@
                    ldb       5,s
                    sex
                    puls      u,pc
a30@                ldb       5,s
                    sex
                    subd      #$0031
                    stb       5,s
                    blt       b30@
                    ldb       5,s
                    cmpb      #$06
                    bgt       b30@
                    ldb       5,s
                    sex
                    addd      #$000A
                    puls      u,pc
b30@                clra
                    clrb
                    puls      u,pc
* upmenu: (n) hides the text cursor and shows menu n (0-22, else bell): 7 -> laymenu(1), 12 -> laymenu(0), else the 7-byte record at FrMenuRecs ($0503)+n*7 (flag, col, y, w, h, ptr): flag clear -> a text window with the string list, flag set -> nothing (s9 streams those menus)
upmenu            pshs      a,b,x,y,u
                    ldd       10,s
                    blt       a31@
                    ldd       10,s
                    cmpd      #$0016
                    ble       b31@
a31@                lbsr      bell
                    lbra      ShowMenuDone
b31@                clra
                    clrb
                    pshs      a,b
                    lbsr      alcurset
                    leas      2,s
                    ldd       10,s
                    cmpd      #$0007
                    beq       c31@
                    ldd       10,s
                    cmpd      #$000C
                    bne       ShowTableMenu
c31@                ldd       10,s
                    cmpd      #$0007
                    bne       d31@
                    ldd       #$0001
                    bra       e31@
d31@                clra
                    clrb
e31@                pshs      a,b
                    lbsr      laymenu
                    leas      2,s
                    lbra      ShowMenuDone
* ShowTableMenu: the 7-byte record of menu n; a flag-set (push-button) record draws nothing: s9 streams
* those menus through ctxma ($B9) with the labels
ShowTableMenu       ldd       10,s
                    pshs      a,b
                    ldd       #$0007
                    lbsr      Mul16
                    ldx       #FrMenuRecs
                    leax      d,x
                    leau      ,x
                    ldb       ,u
                    beq       ShowTextMenu
                    lbra      ShowMenuDone
* ShowTextMenu: table entry with flag clear: wcreate(col, y, w, h, 1, WinMenu) (skipped for menu 5) then print the string list
ShowTextMenu        ldd       10,s
                    cmpd      #$0005
                    beq       a32@
                    ldd       #WinMenu            a drop-down menu (Goto and the other table menus)
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldb       4,u
                    sex
                    pshs      a,b
                    ldb       3,u
                    sex
                    pshs      a,b
                    ldb       2,u
                    clra
                    pshs      a,b
                    ldb       1,u
                    sex
                    pshs      a,b
                    lbsr      wcreate
                    leas      12,s
a32@                ldd       5,u
                    std       4,s
                    clra
                    clrb
* MenuLinesLoop: pat each pointer of the NUL-terminated string list
MenuLinesLoop       std       2,s
                    ldd       2,s
                    aslb
                    rola
                    ldx       4,s
                    leax      d,x
                    ldd       ,x                  the string's module offset
                    leax      >ModuleBase,pcr
                    leax      d,x
                    stx       ,s
                    ldb       ,x
                    beq       ShowMenuDone
                    ldd       ,s
                    pshs      a,b
                    lbsr      pat
                    leas      2,s
                    ldd       2,s
                    addd      #$0001
                    bra       MenuLinesLoop
* ShowMenuDone: upmenu's exit (leas 6,s / puls u,pc); the range-error bell, laymenu, a flag-set record and the list end branch here
ShowMenuDone        leas      6,s
                    puls      u,pc
* yesno: command $C9 (col, row): the YES/NO box. A column with bit 7 set opens it as a menu window (WinMenu:
* black Box3D, the inverted font), YesNoBlackW wide, YES and NO further left; butbox draws no frames there.
yesno               pshs      a,b,x,y,u
                    ldb       <arg0
                    andb      #$7F                the column (bit 7: the black box)
                    clra
                    std       2,s
                    ldb       <arg1
                    clra
                    std       ,s
                    ldd       #$0002
                    tst       <arg0
                    bpl       yng1@
                    ldd       #WinMenu
yng1@               pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0004
                    pshs      a,b
                    ldd       #$0024              36 columns
                    tst       <arg0
                    bpl       yng2@
                    ldd       #YesNoBlackW        the black box: half as wide
yng2@               pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    lbsr      wcreate
                    leas      12,s
                    tst       >FrWinInv           the black box: YES YesNoBlackYesDX columns further left, inside it
                    beq       yng3@
                    ldd       2,s
                    subd      #YesNoBlackYesDX
                    std       2,s
yng3@               equ       *
                    clra
                    clrb
                    pshs      a,b
                    lbsr      alcurset
                    leas      2,s
                    ldd       #$0020
                    pshs      a,b
                    lbsr      vanna
                    leas      2,s
                    ldd       ,s
                    addd      #$FFE6
                    std       4,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    ldd       6,s
                    addd      #$0010
                    pshs      a,b
                    ldd       8,s
                    addd      #$0007
                    pshs      a,b
                    lbsr      butbox
                    leas      8,s
                    ldd       #$0001
                    pshs      a,b
                    leax      >strMenuYES,pcr
                    pshs      x
                    ldd       8,s
                    pshs      a,b
                    ldd       8,s
                    addd      #$0008
                    pshs      a,b
                    lbsr      phrase
                    leas      8,s
                    tst       >FrWinInv           the black box: NO YesNoBlackNoDX-YesNoBlackYesDX columns further left still
                    beq       yng4@
                    ldd       2,s
                    subd      #YesNoBlackNoDX-YesNoBlackYesDX
                    std       2,s
yng4@               equ       *
                    ldd       #$0001
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    ldd       6,s
                    addd      #$001D
                    pshs      a,b
                    ldd       8,s
                    addd      #$0014
                    pshs      a,b
                    lbsr      butbox
                    leas      8,s
                    ldd       #$0001
                    pshs      a,b
                    leax      >strMenuNO,pcr
                    pshs      x
                    ldd       8,s
                    pshs      a,b
                    ldd       8,s
                    addd      #$0015
                    pshs      a,b
                    lbsr      phrase
                    leas      8,s
                    leas      6,s
                    puls      u,pc
patience               pshs      u  command $C3: the paper 3D box with the wait message
                    ldd       #WinStylePaper3D    the paper 3D box
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0003
                    pshs      a,b
                    ldd       #$0021
                    pshs      a,b
                    ldd       #$0078
                    pshs      a,b
                    ldd       #$0018
                    pshs      a,b
                    lbsr      wcreate
                    leas      12,s
                    clra
                    clrb
                    pshs      a,b
                    lbsr      alcurset
                    leas      2,s
                    leax      >strMenuPatienceThisTakesTime,pcr
                    pshs      x
                    lbsr      pat
                    leas      2,s
                    puls      u,pc
* empty menu string
strMenuBlank_3EAB               equ       *
                    fcb       $00
* kpchelps[] (fmenus.c): the keypad help text, original spacing and control bytes; strMenuBlank_* are its empty lines
str_kpchelps_0               equ       *
                    fcc       / KeyPad Input INSTANT Cmnds/
                    fcb       $0D,$00
str_kpchelps_1               equ       *
                    fcc       / use CAP letters except k:/
                    fcb       $0D,$00
strMenuBlank_4027               equ       *
                    fcb       $0D,$00
str_kpchelps_3               equ       *
                    fcc       /M get Modes Menu/
                    fcb       $0D,$00
str_kpchelps_4               equ       *
                    fcc       /k exit bacK to mousing/
                    fcb       $0D,$00
str_kpchelps_5               equ       *
                    fcc       /ENTER Modes Menu/
                    fcb       $0D,$00
strMenuBlank_4065               equ       *
                    fcb       $0D,$00
str_kpchelps_7               equ       *
                    fcc       |C enter Clone/Chord mode|
                    fcb       $0D,$00
str_kpchelps_8               equ       *
                    fcc       /B Brush mode, leave Clone/
                    fcb       $0D,$00
str_kpchelps_9               equ       *
                    fcc       /P Pick up note to defaults/
                    fcb       $0D,$00
str_kpchelps_10               equ       *
                    fcc       /D Duplicate default note/
                    fcb       $0D,$00
strMenuBlank_40D2               equ       *
                    fcb       $0D,$00
str_kpchelps_12               equ       *
                    fcc       /H refresH screen/
                    fcb       $0D,$00
str_kpchelps_13               equ       *
                    fcc       /<,> move view one screen/
                    fcb       $0D,$00
str_kpchelps_14               equ       *
                    fcc       /arrow keys -- as marked/
                    fcb       $0D,$00
str_kpchelps_15               equ       *
                    fcc       /SPACE advances cursor/
                    fcb       $0D,$00
str_kpchelps_16               equ       *
                    fcc       /CTRL-U undoes last move/
                    fcb       $0D,$00
strMenuBlank_4149               equ       *
                    fcb       $0D,$00
str_kpchelps_18               equ       *
                    fcc       /GM goto last Mouse click/
                    fcb       $0D,$00
str_kpchelps_19               equ       *
                    fcc       /GK goto last Keypad exit/
                    fcb       $0D,$00
str_kpchelps_20               equ       *
                    fcc       /GA goto last keypad Action/
                    fcb       $0D,$00
str_kpchelps_21               equ       *
                    fcc       /GE goto keypad Entry screen/
                    fcb       $0D,$00
str_kpchelps_22               equ       *
                    fcc       |L,R Lines connect notes/Rests|
                    fcb       $0D,$00
str_kpchelps_23               equ       *
                    fcc       /?  show current defaults/
                    fcb       $00
strMenuBlank_41F0               equ       *
                    fcb       $00
* kpnhelps[] (fmenus.c): the note-string help text, original spacing; strMenuBlank_* are its empty lines
str_kpnhelps_0               equ       *
                    fcc       /All Notestring Items are Optional,/
                    fcb       $0D,$00
str_kpnhelps_1               equ       *
                    fcc       /  but must have at least One:/
                    fcb       $0D,$00
strMenuBlank_4234               equ       *
                    fcb       $0D,$00
str_kpnhelps_3               equ       *
                    fcc       /Duration:  1,2,4,8,16,32,64 or v,w,h,q/
                    fcb       $0D,$00
str_kpnhelps_4               equ       *
                    fcc       |Dura Mod:  ., .., /3, _|
                    fcb       $0D,$00
str_kpnhelps_5               equ       *
                    fcc       /Pitch:     a,b,c,d,e,f,g, r/
                    fcb       $0D,$00
str_kpnhelps_6               equ       *
                    fcc       /Pitch Mod: Fp, #Sz, x, N=/
                    fcb       $0D,$00
str_kpnhelps_7               equ       *
                    fcc       /Octave:    o, then 0-7 or u, n/
                    fcb       $0D,$00
str_kpnhelps_8               equ       *
                    fcc       /Articulate: t, l, n, m, s/
                    fcb       $0D,$00
strMenuBlank_42EA               equ       *
                    fcb       $00
* barprs[] (fmenus.c): the barline menu text, original spacing and control bytes
str_barprs_0               equ       *
                    fcb       $0C
                    fcc       / CHANGE BARLINE TO/
                    fcb       $0D,$00
str_barprs_1               equ       *
                    fcc       /1  Single Bar/
                    fcb       $0D,$00
str_barprs_2               equ       *
                    fcc       /2  Double Bar/
                    fcb       $0D,$00
str_barprs_3               equ       *
                    fcc       /(  begin repeat/
                    fcb       $0D,$00
str_barprs_4               equ       *
                    fcc       /)  end repeat/
                    fcb       $0D,$00
str_barprs_5               equ       *
                    fcc       /:  back-back )(/
                    fcb       $0D,$00
str_barprs_6               equ       *
                    fcc       /Nn Nth Ending/
                    fcb       $0D,$00
str_barprs_7               equ       *
                    fcc       /F  Fine./
                    fcb       $0D,$00
str_barprs_8               equ       *
                    fcb       $0D
                    fcc       /  INSERT A NEW/
                    fcb       $0D,$00
str_barprs_9               equ       *
                    fcc       |/  Time Sig|
                    fcb       $0D,$00
str_barprs_10               equ       *
                    fcc       /Kn Key Sig/
                    fcb       $0D,$00
str_barprs_11               equ       *
                    fcc       /D  DS, DC al Fine/
                    fcb       $0D,$00
str_barprs_12               equ       *
                    fcc       /$  Sign/
                    fcb       $0D,$00
str_barprs_13               equ       *
                    fcc       /C  Coda label/
                    fcb       $0D,$00
str_barprs_14               equ       *
                    fcc       /S  Space/
                    fcb       $0D,$00
str_barprs_15               equ       *
                    fcc       /L  Label/
                    fcb       $0D,$0D,$00
* strMenuBlank_448A: distribution menu text
strMenuBlank_448A               equ       *
                    fcb       $00
* str_exprprs_0: fmenus.c exprprs[] text
str_exprprs_0               equ       *
                    fcb       $0C
                    fcc       / PART'S EXPR:/
                    fcb       $0D,$00
* str_exprprs_1: fmenus.c exprprs[] text
str_exprprs_1               equ       *
                    fcc       /Instrument/
                    fcb       $0D,$00
* str_exprprs_2: fmenus.c exprprs[] text
str_exprprs_2               equ       *
                    fcc       /Volume ppp-fff/
                    fcb       $0D,$00
* str_exprprs_3: fmenus.c exprprs[] text
str_exprprs_3               equ       *
                    fcc       /Midi chan hop/
                    fcb       $0D,$00
* str_exprprs_4: fmenus.c exprprs[] text
str_exprprs_4               equ       *
                    fcc       /Event (MIDI)/
                    fcb       $0D,$00
* str_exprprs_5: fmenus.c exprprs[] text
str_exprprs_5               equ       *
                    fcb       $0D
                    fcc       / GENERAL EXPR:/
                    fcb       $0D,$00
* str_exprprs_6: fmenus.c exprprs[] text
str_exprprs_6               equ       *
                    fcc       /Tempo change/
                    fcb       $0D,$00
* str_exprprs_7: fmenus.c exprprs[] text
str_exprprs_7               equ       *
                    fcc       /General volume/
                    fcb       $0D,$00
* str_exprprs_8: fmenus.c exprprs[] text
str_exprprs_8               equ       *
                    fcc       /midi drum Clock/
                    fcb       $0D,$00
* str_exprprs_9: fmenus.c exprprs[] text
str_exprprs_9               equ       *
                    fcc       /< cresc  > dim/
                    fcb       $0D,$00
* str_exprprs_10: fmenus.c exprprs[] text
str_exprprs_10               equ       *
                    fcc       |Accel / Ritard|
                    fcb       $0D,$00
* str_exprprs_11: fmenus.c exprprs[] text
str_exprprs_11               equ       *
                    fcc       /^ accent/
                    fcb       $0D,$00
* str_exprprs_12: fmenus.c exprprs[] text
str_exprprs_12               equ       *
                    fcc       /- Layoff/
                    fcb       $0D,$00
* str_exprprs_4_4548: fmenus.c exprprs[] text
str_exprprs_4_4548               equ       *
                    fcc       /Event (MIDI)/
                    fcb       $0D,$0D,$00
* strMenuBlank_4557: distribution menu text
strMenuBlank_4557               equ       *
                    fcb       $00
* str_midiprs_0: midiprs[] row: 'Ith -> 01' (key h: every part to channel 01), 'Ith -> Ith' (key i)
str_midiprs_0               equ       *
                    fcb       $0D
                    fcc       / Ith /
                    fcb       GlyphArrowRight
                    fcc       / 01     Ith /
                    fcb       GlyphArrowRight
                    fcc       / Ith/
                    fcb       $0D,$00
* str_midiprs_2: fmenus.c midiprs[] text
str_midiprs_2               equ       *
                    fcc       / Update       Restore/
                    fcb       $0D,$00
* str_midiprs_3: midiprs[] row (s9 text: Omni range)
str_midiprs_3               equ       *
                    fcc       / Klone chans  Omni range/
                    fcb       $0D,$00
* str_midiprs_4: fmenus.c midiprs[] text
str_midiprs_4               equ       *
                    fcc       / Tutti        Quiet all/
                    fcb       $0D,$00
* str_midiprs_6: fmenus.c midiprs[] text
str_midiprs_6               equ       *
                    fcc       / Modes...     Levels.../
                    fcb       $0D,$00
* strMidiNeverMind: the MIDI menu's last row: Devices... (key v, s9r's MIDI Devices menu) and Never mind
strMidiNeverMind    equ       *
                    fcc       / Devices...   Never mind/
                    fcb       $0D,$00
* str_midiprs_7: the blank line above the Choice: prompt
str_midiprs_7               equ       *
                    fcb       $0D,$00
* strMenuBlank_46EE: distribution menu text
strMenuBlank_46EE               equ       *
                    fcb       $00
* strMenuBlank_47EB: distribution menu text
strMenuBlank_47EB               equ       *
                    fcb       $00
* str_glayprs_0: fmenus.c glayprs[] text
str_glayprs_0               equ       *
                    fcc       /[Staves.../
                    fcb       $00
* str_glayprs_1: fmenus.c glayprs[] text
str_glayprs_1               equ       *
                    fcc       /reOrder Parts/
                    fcb       $00
* str_glayprs_2: fmenus.c glayprs[] text
str_glayprs_2               equ       *
                    fcc       /voice Ranges/
                    fcb       $00
* str_glayprs_3: fmenus.c glayprs[] text
str_glayprs_3               equ       *
                    fcc       /<+8va part/
                    fcb       $00
* str_glayprs_4: fmenus.c glayprs[] text
str_glayprs_4               equ       *
                    fcc       /<-8va part/
                    fcb       $00
* str_glayprs_5: fmenus.c glayprs[] text
str_glayprs_5               equ       *
                    fcc       /<reFill part/
                    fcb       $00
* str_glayprs_6: fmenus.c glayprs[] text
str_glayprs_6               equ       *
                    fcc       /<Tacetize part/
                    fcb       $00
* str_glayprs_7: fmenus.c glayprs[] text
str_glayprs_7               equ       *
                    fcc       /<Clear part/
                    fcb       $00
* str_glayprs_8: fmenus.c glayprs[] text
str_glayprs_8               equ       *
                    fcc       /BACK TO SCORE/
                    fcb       $00
* strMenuBlank_485E: distribution menu text
strMenuBlank_485E               equ       *
                    fcb       $00
* str_gotoprs_0: fmenus.c gotoprs[] text
str_gotoprs_0               equ       *
                    fcc       /g Number  go to Numbered Bar/
                    fcb       $0D,$00
* str_gotoprs_1: fmenus.c gotoprs[] text
str_gotoprs_1               equ       *
                    fcc       /G Number  to Special barline/
                    fcb       $0D,$00
* str_gotoprs_2: fmenus.c gotoprs[] text
str_gotoprs_2               equ       *
                    fcc       /g SPACE   Repeat last goto/
                    fcb       $0D,$00
* str_gotoprs_3: fmenus.c gotoprs[] text
str_gotoprs_3               equ       *
                    fcc       /g. or gu  Undo last goto/
                    fcb       $0D,$00
* str_gotoprs_4: fmenus.c gotoprs[] text
str_gotoprs_4               equ       *
                    fcc       /    Universal Command form is:/
                    fcb       $00
* str_gotoprs_5: fmenus.c gotoprs[] text
str_gotoprs_5               equ       *
                    fcc       /g Sign Number What/
                    fcb       $0D
                    fcc       /    Sign and Number optional;/
                    fcb       $0D,$00
* str_gotoprs_6: fmenus.c gotoprs[] text
str_gotoprs_6               equ       *
                    fcc       /    'What' choices include:/
                    fcb       $0D,$00
* str_gotoprs_7: fmenus.c gotoprs[] text
str_gotoprs_7               equ       *
                    fcc       /[ Left marker     ] Right/
                    fcb       $0D,$00
* str_gotoprs_8: fmenus.c gotoprs[] text
str_gotoprs_8               equ       *
                    fcc       /! To-marker       * End score/
                    fcb       $0D,$00
* str_gotoprs_9: fmenus.c gotoprs[] text
str_gotoprs_9               equ       *
                    fcc       /x any eXpression  k Key sig/
                    fcb       $0D,$00
* str_gotoprs_10: fmenus.c gotoprs[] text
str_gotoprs_10               equ       *
                    fcc       /i Instr           v Vol level/
                    fcb       $0D,$00
* str_gotoprs_11: fmenus.c gotoprs[] text
str_gotoprs_11               equ       *
                    fcc       |t Tempo           / Time Sig|
                    fcb       $0D,$00
* str_gotoprs_12: fmenus.c gotoprs[] text
str_gotoprs_12               equ       *
                    fcc       /n Nth eNding      f Fine./
                    fcb       $0D,$00
* str_gotoprs_13: fmenus.c gotoprs[] text
str_gotoprs_13               equ       *
                    fcc       /o Coda            s Sign/
                    fcb       $0D,$00
* str_gotoprs_14: fmenus.c gotoprs[] text
str_gotoprs_14               equ       *
                    fcc       /g Gen'l level     m Midi chan/
                    fcb       $0D,$00
* str_gotoprs_15: fmenus.c gotoprs[] text
str_gotoprs_15               equ       *
                    fcc       /a Articulation    _ Tie/
                    fcb       $0D,$00
* str_gotoprs_16: fmenus.c gotoprs[] text
str_gotoprs_16               equ       *
                    fcc       /: Repeats         d DC or DS/
                    fcb       $0D,$00
* str_gotoprs_17: fmenus.c gotoprs[] text
str_gotoprs_17               equ       *
                    fcc       /p# Part # ... ... P# no rests/
                    fcb       $0D,$00
* str_gotoprs_18: fmenus.c gotoprs[] text
str_gotoprs_18               equ       *
                    fcc       |<> Cresc/Dim      r Rit/Accel|
                    fcb       $0D,$00
* str_gotoprs_19: fmenus.c gotoprs[] text
str_gotoprs_19               equ       *
                    fcc       |c Clock on/off    e Event|
                    fcb       $0D,$00
* str_gotoprs_20: fmenus.c gotoprs[] text
str_gotoprs_20               equ       *
                    fcc       |^ Accent/layoff   l Label|
                    fcb       $0D,$00
* str_gotoprs_21: fmenus.c gotoprs[] text
str_gotoprs_21               equ       *
                    fcc       / value# may follow ivgm<>tr/
                    fcb       $0D,$00
* str_gotoprs_22: fmenus.c gotoprs[] text
str_gotoprs_22               equ       *
                    fcc       / p# may follow pPivm./
                    fcb       $0D,$00
* strMenuBlank_4B34: distribution menu text
strMenuBlank_4B34               equ       *
                    fcb       $00
* strMenuYES: distribution menu text
strMenuYES               equ       *
                    fcc       /  YES/
                    fcb       $00
* strMenuNO: distribution menu text
strMenuNO               equ       *
                    fcc       /  NO!/
                    fcb       $00
* strMenuPatienceThisTakesTime: distribution menu text
strMenuPatienceThisTakesTime               equ       *
                    fcb       $0D
                    fcc       / Patience...this takes time.../
                    fcb       $00
layback               pshs      u
                    leas      -12,s
                    leax      >LayBackList1,pcr   the left area and the band's rows over the panel cleared
                    lbsr      DrawList
                    ldd       #$00B9
                    bra       layback_2
layback_1               ldd       #$AAAB
                    pshs      a,b
                    ldd       4,s
                    pshs      a,b
                    ldd       #$027F              x2 = 639: across to column 79 (laymenu's clear stops under the band)
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    lbsr      hline
                    leas      8,s
                    ldd       2,s
                    addd      #$0002
layback_2               std       2,s
                    ldd       2,s
                    cmpd      #$00BF
                    ble       layback_1
* LayBackList2: column 0 paper, the bottom line, the Clef / TS / KS labels and the separators
                    leax      >LayBackList2,pcr
                    lbsr      DrawList
                    clra
                    clrb
                    stb       9,s
                    ldd       #$0001
                    std       6,s
                    ldd       #$000B
                    std       4,s
                    ldd       #$0053
                    bra      layback_5
layback_3               ldd       >nparts
                    addd      #$0001
                    cmpd      6,s
                    blt       layback_4
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$00BF
                    pshs      a,b
                    ldd       #$0008
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    lbsr      vline
                    leas      8,s
layback_4               ldd       6,s
                    pshs      a,b
                    lbsr      i2hexc
                    leas      2,s
                    stb       8,s
                    ldd       #$0001
                    pshs      a,b
                    leax      10,s
                    pshs      x
                    ldd       #$0001
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    lbsr      phrase
                    leas      8,s
                    ldd       #$0001
                    pshs      a,b
                    leax      10,s
                    pshs      x
                    ldd       #$00BA
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    lbsr      phrase
                    leas      8,s
                    ldd       6,s
                    addd      #$0001
                    std       6,s
                    subd      #$0001
                    ldd       4,s
                    addd      #$0003
                    std       4,s
                    ldd       ,s
                    addd      #$0018
layback_5               std       ,s
                    ldd       6,s
                    cmpd      #$0010
                    ble      layback_3
                    ldd       >nparts
                    cmpd      #$0010
                    bge       layback_6
                    ldd       >nparts
                    addd      #$0001
                    bra       layback_7
layback_6               ldd       #$0010
layback_7               std       6,s
                    ldd       #$0055              pattern $55: the separator after the last part column
                    pshs      a,b
                    ldd       #$00BF
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    ldd       #$0003
                    lbsr      Mul16
                    addd      #$000A
                    pshs      a,b
                    lbsr      vpatdyn
                    leas      8,s
                    leas      12,s
                    puls      u,pc
* laymenu: draws the right-hand SCORE EDITOR panel: LayMenuList (clear of columns 57-79, frame, field, title strip,
* icon areas, eraser), the seven clef icons and the four part-type icons. Every panel column is + LayDX (equates);
* s9l's text and hit tests and MenuRowCol/MenuBarLeft/MenuBarRight use LayDX too.
laymenu      pshs      a,b,x,u
                    leax      >LayMenuList,pcr
                    lbsr      DrawList
                    clra
                    clrb
                    std       2,s                 i
                    ldu       #LayClefByte0       the first clef's byte in the row (laymenu restores U)
                    bra       ClefIconLoopTest
* ClefIconLoop: draws clef icon i (dyna2 $0EC9+i*$36) at byte LayClefByte0 + LayClefPitch*i of the row (20 dots
* apart), y $21+LayUp+LayDY, 27 rows
ClefIconLoop        ldd       2,s
                    pshs      a,b
                    ldd       #$0036
                    lbsr      Mul16
                    ldx       #$0EC9
                    leax      d,x
                    pshs      x                   the picture
                    tfr       u,d
                    andb      #3
                    tfr       b,a                 the byte offset into the column
                    ldb       #$1B                27 rows
                    pshs      a,b
                    ldd       #$0021+LayUp+LayDY  the clefs' top row
                    pshs      a,b
                    tfr       u,d
                    lsra
                    rorb
                    lsra
                    rorb                          the column
                    pshs      a,b
                    lbsr      dyna2
                    leas      8,s
                    ldd       2,s
                    addd      #$0001
                    std       2,s
                    leau      LayClefPitch,u
* ClefIconLoopTest: loop test of ClefIconLoop: repeats while i<7; entered by bra from the setup
ClefIconLoopTest    ldd       2,s
                    cmpd      #$0007
                    blt       ClefIconLoop
* The four part-type buttons, three columns apart from about column 62+LayDX (s9l hit-tests them): a quarter note
* = a normal part, a two-note chord on one stem = a clone, the same two with the flag crossed out = the no-flags
* kinds. Pictures: PicPartIcon (four-bit, in the UmeSymbols16 bank), shared with the drag glyph and the part column.
                    clra
                    clrb
                    pshs      a,b                 ,s the icon index
vil1@               ldb       1,s
                    lda       #32
                    mul
                    leax      >PicPartIcon,pcr
                    leax      d,x                 the picture (four-bit, in the symbol bank)
                    pshs      x
                    ldb       3,s                 the index
                    lda       #LayPartPitch
                    mul
                    addd      #LayPartByte0       its byte in the row
                    tfr       d,u
                    andb      #3
                    tfr       b,a                 the byte offset into the column
                    ldb       #16                 16 rows
                    pshs      a,b
                    ldd       #$003D              y 61: the top row
                    pshs      a,b
                    tfr       u,d
                    lsra
                    rorb
                    lsra
                    rorb                          the column
                    pshs      a,b
                    ldb       #1
                    stb       >FrDynaInk          inked
                    lbsr      dyna2               inked
                    clr       >FrDynaInk
                    leas      8,s
                    inc       1,s
                    ldb       1,s
                    cmpb      #4
                    blo       vil1@
                    leas      2,s
                    leas      4,s
                    puls      u,pc
* DrawList: makes a list of calls to the C-style drawing routines (bytblt, winbox, hline, vline,
* vpatdyn, phrase, dyna2) from records instead of ldd/pshs code - five bytes an argument become two. X = the list.
* A record: fdb routine-* (from the record), fcb count, fcb mask, then count fdb arguments in PUSH order (the first
* is the deepest - the routine's LAST parameter). Mask bit k set = argument k is an address, stored as label-*
* (from its own word). fdb 0 ends the list. Keeps D, X, U; Y (the C base) is never touched.
DrawList            pshs      d,x,u
dl1@                ldd       ,x
                    beq       dl9@
                    leau      d,x                 the routine
                    ldd       2,x                 A = the count, B = the mask
                    leax      4,x
                    pshs      d,x,u               ,s count  1,s mask  2,s the next argument  4,s the routine
                    tfr       s,u
dl2@                tst       ,u
                    beq       dl4@
                    ldx       2,u
                    ldd       ,x++
                    stx       2,u
                    lsr       1,u
                    bcc       dl3@
                    leax      -2,x
                    leax      d,x                 an address: its offset from its own word
                    tfr       x,d
dl3@                pshs      d
                    dec       ,u
                    bra       dl2@
dl4@                jsr       [4,u]
                    leas      ,u                  the arguments dropped
                    puls      d,x,u               X = the next record
                    bra       dl1@
dl9@                puls      d,x,u,pc
* LayMenuList: the Score Editor panel (laymenu) - bytblt(mode, x1, y1, x2, y2), winbox(x1, y1, x2, y2, style),
* dyna2(col, y, offset*256+rows, image); arguments in push order (y2 / style / image first)
LayMenuList         fdb       bytblt-*
                    fcb       5,0
                    fdb       $00B8,$004F,$0000,$0039,$0002              the panel's columns, under the dotted header band
                    fdb       winbox-*
                    fcb       5,0
                    fdb       LayPanelStyle,$00BE+LayDY,$004F+LayDX,$0001+LayUp+LayDY,$003B+LayDX  the 3D frame
                    fdb       bytblt-*
                    fcb       5,0
                    fdb       $00BB+LayDY,$004E+LayDX,LayFieldBot,$003C+LayDX,$0002   the field
                    fdb       bytblt-*
                    fcb       5,0
                    fdb       $00BB+LayDY,$004B+LayDX,$00B5+LayDY,$003F+LayDX,$0002   the title strip
                    fdb       bytblt-*
                    fcb       5,0
                    fdb       $002B,$004D+LayDX,$0005+LayUp+LayDY,$003C+LayDX,$0002  the clef area
                    fdb       bytblt-*
                    fcb       5,0
                    fdb       $0046,$0049+LayDX,$002C,$003D+LayDX,$0002               the part-type area
                    fdb       bytblt-*
                    fcb       5,0
                    fdb       $003D,$004E+LayDX,$002C,$004B+LayDX,$0002               the eraser's area
                    fdb       dyna2-*
                    fcb       4,0
                    fdb       $0E2D,((LayXByte&3)*256)+$000F,$003D,LayXByte/4        the eraser (MarkDelete), 15 rows
                    fdb       0
* LayBackList1: clears the Score Editor's left area and the header band's rows over the panel's columns
LayBackList1        fdb       bytblt-*
                    fcb       5,0
                    fdb       $00BF,$003A+LayDX,$0000,$0000,$0002
                    fdb       bytblt-*
                    fcb       5,0
                    fdb       $00BF,$004F,$00B9,$003B+LayDX,$0002
                    fdb       0
* LayBackList2: column 0 paper under the band, the bottom line, the Clef / TS / KS labels top and bottom and the
* separators - vpatdyn(x, y1, y2, pattern), hline(x1, x2, y, pattern), phrase(x, y, text, flag), vline(x, y1, y2, pattern)
LayBackList2        fdb       vpatdyn-*
                    fcb       4,0
                    fdb       $0000,$00B8,$0008,$0000
                    fdb       hline-*
                    fcb       4,0
                    fdb       $0001,$0007,$01D0+LayDX*8+8,$0000
                    fdb       phrase-*
                    fcb       4,%0010
                    fdb       $0000
                    fdb       L56F8-*
                    fdb       $0001,$0000
                    fdb       phrase-*
                    fcb       4,%0010
                    fdb       $0001
                    fdb       L56FD-*
                    fdb       $00BA,$0000
                    fdb       vline-*
                    fcb       4,0
                    fdb       $0001,$00B8,$0008,$0022
                    fdb       phrase-*
                    fcb       4,%0010
                    fdb       $0001
                    fdb       L5702-*
                    fdb       $0001,$0005
                    fdb       phrase-*
                    fcb       4,%0010
                    fdb       $0001
                    fdb       L5705-*
                    fdb       $00BA,$0005
                    fdb       phrase-*
                    fcb       4,%0010
                    fdb       $0001
                    fdb       L5708-*
                    fdb       $0001,$0008
                    fdb       phrase-*
                    fcb       4,%0010
                    fdb       $0001
                    fdb       L570B-*
                    fdb       $00BA,$0008
                    fdb       vline-*
                    fcb       4,0
                    fdb       $0001,$00B8,$0008,$003B
                    fdb       vline-*
                    fcb       4,0
                    fdb       $0001,$00BF,$0008,$0055
                    fdb       0
showglay               pshs      u
                    leas      <-$38,s
                    ldb       <$3D,s
                    sex
                    pshs      a,b
                    lbsr      layback
                    leas      2,s
                    clra
                    clrb
                    bra       showglay_2
showglay_1               ldd       #$0001
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    lbsr      storf
                    leas      4,s
                    std       10,s
                    ldd       6,s
                    addd      #$0001
showglay_2               std       6,s
                    ldd       6,s
                    cmpd      >nstaves
                    blt       showglay_1
                    ldb       <$3F,s
                    beq       showglay_3
                    ldx       #FrStdin
                    pshs      x
                    ldd       >nparts
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    leax      <$1C,s
                    pshs      x
                    lbsr      fread
                    leas      8,s
                    ldx       #FrStdin
                    pshs      x
                    ldd       >nparts
                    addd      #$0001
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    leax      <$2D,s
                    pshs      x
                    lbsr      fread
                    leas      8,s
                    ldd       #WinStylePaper3D    the paper 3D box
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$000E
                    pshs      a,b
                    ldd       #$000F
                    pshs      a,b
                    ldd       #$00BB
                    pshs      a,b
                    ldd       #$003E
                    pshs      a,b
                    lbsr      wcreate
                    leas      12,s
showglay_3               ldd       #$0002
                    stb       <$14,s
                    ldd       #$0007
                    stb       <$12,s
                    clra
                    clrb
                    stb       <$11,s
                    clra
                    clrb
                    stb       <$13,s
                    ldd       #$0001
                    lbra      showglay_25
showglay_4               ldd       8,s
                    pshs      a,b
                    ldd       #$0003
                    lbsr      Mul16
                    addd      #$0008
                    std       ,s
                    leax      4,s
                    pshs      x
                    leax      12,s
                    pshs      x
                    ldd       12,s
                    pshs      a,b
                    lbsr      grafstaff
                    leas      6,s
                    ldd       4,s
                    clra
                    andb      #$10
                    beq       showglay_5
                    ldd       #$0001
                    bra       showglay_6
showglay_5               clra
                    clrb
showglay_6               aslb
                    rola
                    pshs      a,b
                    ldd       6,s
                    clra
                    andb      #$04
                    beq       showglay_7
                    ldd       #$0001
                    bra       showglay_8
showglay_7               clra
                    clrb
showglay_8               pshs      a,b
                    ldd       #$0004
                    subd      ,s++
                    subd      ,s++
                    stb       <$10,s
                    ldb       <$3F,s
                    lbeq      showglay_14
                    ldb       <$10,s
                    cmpb      #$03
                    ble       showglay_9
                    ldd       #$0003
                    stb       <$10,s
showglay_9               ldd       8,s
                    leax      <$15,s
                    leax      d,x
                    ldb       ,x
                    sex
                    std       14,s
                    ldd       8,s
                    leax      <$26,s
                    leax      d,x
                    ldb       ,x
                    sex
                    std       12,s
                    ldd       14,s
                    cmpd      #$0020
                    lbeq      showglay_24
                    ldd       #$0001
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       <$12,s
                    cmpd      #$0004
                    ble       showglay_10
                    ldd       #$0001
                    bra       showglay_11
showglay_10               clra
                    clrb
showglay_11               pshs      a,b
                    ldd       <$10,s
                    pshs      a,b
                    ldd       <$12,s
                    addd      <$16,s
                    addd      <$16,s
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    leax      <$1C,s
                    pshs      x
                    lbsr      drawnr
                    leas      14,s
                    ldd       #$0001
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       <$10,s
                    cmpd      #$0004
                    blt       showglay_12
                    ldd       #$0001
                    bra       showglay_13
showglay_12               clra
                    clrb
showglay_13               pshs      a,b
                    ldd       <$10,s
                    pshs      a,b
                    ldd       <$12,s
                    addd      <$14,s
                    addd      <$14,s
                    lbra      showglay_23
showglay_14               ldd       #$0001
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       8,s
                    clra
                    andb      #$02
                    beq       showglay_15
                    ldd       #$0001
                    bra       showglay_16
showglay_15               clra
                    clrb
showglay_16               pshs      a,b
                    ldd       <$10,s
                    pshs      a,b
                    ldd       12,s
                    clra
                    andb      #$01
                    beq       showglay_17
                    ldd       #$0006
                    bra       showglay_19
showglay_17               ldd       12,s
                    clra
                    andb      #$02
                    beq       showglay_18
                    ldd       #$FFFA
                    bra       showglay_19
showglay_18               clra
                    clrb
showglay_19               addd      <$12,s
                    addd      #$0008
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    leax      <$1C,s
                    pshs      x
                    lbsr      drawpticon          the part's icon: stem down if below the center line (bit 1); y +6 above (bit 0), -6 below
                    leas      14,s
                    ldd       4,s
                    clra
                    andb      #$03
                    bne       showglay_24
                    ldd       #$0001
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       <$10,s
                    pshs      a,b
                    ldd       12,s
                    clra
                    andb      #$01
                    beq       showglay_20
                    ldd       #$0006
                    bra       showglay_22
showglay_20               ldd       12,s
                    clra
                    andb      #$02
                    beq       showglay_21
                    ldd       #$FFFA
                    bra       showglay_22
showglay_21               clra
                    clrb
showglay_22               addd      <$12,s
                    addd      #$0008
* A part on the center line (neither bit) gets a second, stem-down icon at the same y; same arguments as drawnr.
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    leax      <$1C,s
                    pshs      x
                    lbsr      drawpticon          the second icon, stem down
                    leas      14,s
                    bra       showglay_24
showglay_23               pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    leax      <$1C,s
                    pshs      x
                    lbsr      drawpticon          the range rows: drawnr at the first pitch, the type icon at the second
                    leas      14,s
showglay_24               ldd       8,s
                    addd      #$0001
showglay_25               std       8,s
                    ldd       8,s
                    cmpd      >nparts
                    lble      showglay_4
                    ldd       >keysig
                    pshs      a,b
                    ldd       #$0008
                    pshs      a,b
                    lbsr      drawks
                    leas      4,s
                    ldd       >denom
                    pshs      a,b
                    ldd       >numer
                    pshs      a,b
                    ldd       #$0005
                    pshs      a,b
                    lbsr      drawts
                    leas      6,s
                    leas      <$38,s
                    puls      u,pc
* drawpticon: drawnr's argument frame (ptr, col, y, staff y, down, 0, 1): draws the part-type icon of the class
* byte at ptr (PicPartIcon + 32 * (4 - class)), inked, at y + 12 (y counts upward) so its head sits where dnota's
* stem-up head was. 'down' set turns the same picture 180 degrees through SrcFix (FrDynaInk = 2) - head on top,
* stem down its left - and draws it at y + 3, where dnota's stem-down head was.
drawpticon          pshs      u
                    ldx       4,s                 the note record drawnr reads
                    ldb       ,x                  its class: 4 normal, 3 clone, 2 no flags, 1 clone without flags
                    clra
                    cmpd      #$0004
                    ble       dpi1@
                    ldd       #$0004
dpi1@               cmpd      #$0001
                    bge       dpi2@
                    ldd       #$0001
dpi2@               pshs      a,b
                    ldd       #$0004
                    subd      ,s++
                    lda       #32
                    mul
                    leax      >PicPartIcon,pcr
                    leax      d,x
                    pshs      x                   the picture
                    ldd       #16
                    pshs      a,b                 rows
                    ldb       #1                  FrDynaInk 1: inked
                    stb       >FrDynaInk
                    ldd       16,s                down? (the picture and the row count are pushed: 12,s + 4)
                    beq       dpi4@
                    ldb       #2                  FrDynaInk 2: inked and turned 180 degrees
                    stb       >FrDynaInk
                    ldd       12,s
                    addd      #3
                    bra       dpi5@
dpi4@               ldd       12,s
                    addd      #12
dpi5@               pshs      a,b                 y
                    ldd       12,s
                    pshs      a,b                 col
                    lbsr      dyna2
                    clr       >FrDynaInk
                    leas      8,s
                    puls      u,pc
storf               pshs      a,b,x,y,u  storf(staff, ink): bracket, five staff lines, number, symbol from table $02C7; D = the staff's y
                    ldd       10,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      Mul16
                    ldx       #staves
                    leax      d,x
                    ldd       ,x
                    std       2,s
                    ldd       10,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      Mul16
                    ldx       #staves
                    leax      d,x
                    ldd       2,x
                    std       4,s
                    aslb
                    rola
                    ldx       #$02C7
                    leax      d,x
                    ldu       ,x
                    ldd       12,s
                    pshs      a,b
                    ldd       4,s
                    addd      #$0010
                    std       2,s
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    ldd       #$0007
                    pshs      a,b
                    lbsr      vline
                    leas      8,s
                    bra       storf_2
* The staff lines: the staff's gray (hline under FrUnder takes SprTab), alternate dots when FrStaffDots is set,
* every dot otherwise. hline negates the color word: 1 -> every dot, -10 -> the 1010 pattern.
storf_1               ldd       #$0001
                    tst       >FrStaffDots
                    beq       storf_1a
                    ldd       #$FFF6
storf_1a            pshs      a,b
                    ldd       2,s
                    pshs      a,b
                    ldd       #$01CE
                    pshs      a,b
                    ldd       #$0008
                    pshs      a,b
                    inc       <FrUnder
                    lbsr      hline
                    clr       <FrUnder
                    leas      8,s
                    ldd       ,s
                    subd      #$0004
                    std       ,s
storf_2               ldd       ,s
                    cmpd      2,s
                    bge       storf_1
                    ldd       2,s
                    addd      #$0006
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       14,s
                    addd      #$0001
                    pshs      a,b
                    lbsr      drawbcd
                    leas      6,s
                    ldd       12,s
                    pshs      a,b
                    pshs      u
                    ldd       #$001B
                    pshs      a,b
                    ldd       8,s
                    addd      #$0014
                    pshs      a,b
                    ldd       #$0002
                    pshs      a,b
                    lbsr      put2
                    leas      10,s
                    ldd       2,s
                    leas      6,s
                    puls      u,pc
i2hexc               pshs      u  i2hexc(n): '0'-'9', 'A'-'V' for n AND $1F
                    ldd       4,s
                    clra
                    andb      #$1F
                    std       4,s
                    cmpd      #$0009
                    bgt       i2hexc_1
                    ldd       4,s
                    addd      #$0030
                    puls      u,pc
i2hexc_1               ldd       4,s
                    addd      #$0037
                    puls      u,pc
L56F8               equ       *
                    fcb       $43,$6C,$65,$66
                    fcb       $00
L56FD               equ       *
                    fcb       $43,$6C,$65,$66
                    fcb       $00
L5702               equ       *
                    fcb       $54,$53,$00
L5705               equ       *
                    fcb       $54,$53,$00
L5708               equ       *
                    fcb       $4B
                    fcb       $53,$00
L570B               equ       *
                    fcb       $4B,$53,$00
* spinit: resets the bump allocator: slot table $13CE[0] = $13D8, count $13D6 = 0
spinit            pshs      u
                    ldx       #space
                    stx       >FrData_spacestk
                    clra
                    clrb
                    std       >FrData_spaceind
                    puls      u,pc
* spalloc: (n) bump allocator with 3 slots: returns the current top and records top + n; 0 when that would reach FrKeyBank or all 3 slots are used
spalloc            pshs      a,b,x,u
                    ldd       >FrData_spaceind
                    aslb
                    rola
                    ldx       #spacestk
                    leax      d,x
                    ldd       ,x
                    std       2,s
                    addd      8,s
                    std       ,s
                    ldx       #FrKeyBank          the ceiling: the key pointer and display state sit above
                    cmpx      ,s
                    bls       AllocFail
                    ldd       >FrData_spaceind
                    cmpd      #$0003
                    blt       AllocPush
* AllocFail: returns 0
AllocFail           clra
                    clrb
                    lbra      OpenTextWinRet
* AllocPush: records the new top and returns the block start
AllocPush           ldd       >FrData_spaceind
                    addd      #$0001
                    std       >FrData_spaceind
                    aslb
                    rola
                    ldx       #spacestk
                    leax      d,x
                    ldd       ,s
                    std       ,x
                    ldd       2,s
                    bra      OpenTextWinRet
spfree               pshs      u
                    ldd       >FrData_spaceind
                    bgt       spfree_1
                    clra
                    clrb
                    puls      u,pc
spfree_1               ldd       >FrData_spaceind
                    addd      #$FFFF
                    std       >FrData_spaceind
                    ldd       #$0001
                    puls      u,pc
gtext               pshs      u
                    ldb       <tgwmode
                    beq       gtext_2
                    ldb       <stocker
                    beq       gtext_1
                    puls      u,pc
gtext_1               lbsr      wsave
gtext_2               ldd       #$0001
                    stb       <tgwmode
                    ldd       #$0001
                    stb       <stocker
                    ldd       #$0020
                    std       <wncols
                    ldd       #$0012
                    std       <wnrows
                    lbsr      center
                    ldd       #WinStylePaper3D    the paper 3D box
                    pshs      a,b
                    ldd       #$0001
                    bra       L5804
* wcreate: (col, y, width, height, save, style) opens a text window: wsave if one is open, sets wcleft/wtopy/wncols/wnrows, winrest, newin(save, style)
wcreate         pshs      u
                    ldb       <tgwmode
                    beq       InitTextWin
                    lbsr      wsave
* InitTextWin: stores the new window parameters and marks the window open
InitTextWin         ldd       #$0001
                    stb       <tgwmode
                    clra
                    clrb
                    stb       <stocker
                    ldd       8,s
                    std       <wncols
                    ldd       10,s
                    std       <wnrows
                    ldd       6,s
                    std       <wtopy
                    ldd       4,s
                    std       <wcleft
                    lbsr      winrest
                    ldd       14,s
                    pshs      a,b
                    ldb       15,s
                    sex
* L5804: the second push of newin's arguments; gtext (command $83) branches here with the style pushed and D = 1 (save).
L5804               equ       *
                    pshs      a,b
                    lbsr      newin
* OpenTextWinRet: shared 'leas 4,s / puls u,pc' epilogue of wcreate, AllocFail and AllocPush
OpenTextWinRet      leas      4,s
                    puls      u,pc
* wkillcmd: command $C7: with FrMenu bit 1 set (after a toggle row) the kill is swallowed once (bit cleared) so the
* menu window stays for the $B9 reprint; otherwise FrMenu is cleared and wkill runs
wkillcmd            ldb       >FrMenu
                    bitb      #$02
                    beq       wkc1@
                    andb      #$FD
                    stb       >FrMenu
                    rts
wkc1@               clr       >FrMenu
                    lbra      wkill
wkill               pshs      u
                    clr       >FrWinInv           the menu state goes with the window (wrestore brings back the one below)
                    ldb       <tgwmode
                    bne       wkill_1
                    puls      u,pc
wkill_1               ldd       <texsave
                    beq       wkill_3
                    ldd       <texsave
                    pshs      a,b
                    ldd       <wtopy
                    pshs      a,b
                    ldd       <wcrght
                    addd      #$0001
                    pshs      a,b
                    ldd       <wboty
                    pshs      a,b
                    ldd       <wcleft
                    addd      #$FFFF
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    lbsr      bytblt
                    leas      12,s
                    lbsr      spfree
                    bne       wkill_2
                    ldd       <texsave
                    pshs      a,b
                    leax      >L5D45,pcr
                    pshs      x
                    lbsr      printf
                    leas      4,s
                    lbsr      bell
wkill_2               clra
                    clrb
                    std       <texsave
wkill_3               lbsr      wrestore
                    puls      u,pc
                    pshs      u
                    ldd       4,s
                    cmpd      <nowinv
                    bne       wkill_4
                    puls      u,pc
wkill_4               ldd       <nowinv
                    beq       wkill_5
                    ldd       <nowinv
                    pshs      a,b
                    bsr       L5887
                    leas      2,s
wkill_5               ldd       4,s
                    beq       L5887_2
                    ldd       4,s
                    cmpd      <wnrows
                    bgt       L5887_2
                    ldd       4,s
                    pshs      a,b
                    bsr       L5887
                    bra       L5887_1
L5887               pshs      a,b,u
                    ldd       6,s
                    addd      #$FFFF
                    pshs      a,b
                    ldd       #$0007
                    lbsr      Mul16
                    pshs      a,b
                    ldd       <wtopy
                    addd      #$FFFC
                    subd      ,s++
                    std       ,s
                    pshs      a,b
                    ldd       <wcrght
                    pshs      a,b
                    ldd       4,s
                    addd      #$FFF9
                    pshs      a,b
                    ldd       <wcleft
                    pshs      a,b
                    ldd       #$0003
                    pshs      a,b
                    lbsr      bytblt
                    leas      10,s
L5887_1               leas      2,s
L5887_2               puls      u,pc
* wsave: if <wp < spacestk (stack $139E..$13CD, 4 levels), saves the 12-byte window state at <wp (0 stocker, 1 width, 2 height, 3 col, 4 top, 5 curcol, 6 currow, 7 nowinv, 8 curaddr, 10 texsave) and bumps <wp
wsave        pshs      u
                    ldx       #spacestk
                    cmpx      <wp
                    bhi       a39@
                    puls      u,pc
a39@                ldd       <wncols
                    ldx       <wp
                    stb       1,x
                    ldd       <wnrows
                    ldx       <wp
                    stb       2,x
                    ldd       <wcleft
                    ldx       <wp
                    stb       3,x
                    ldd       <wtopy
                    ldx       <wp
                    stb       4,x
                    ldd       <nowinv
                    ldx       <wp
                    stb       7,x
                    ldd       <curaddr
                    ldx       <wp
                    std       8,x
                    ldd       <curcol
                    ldx       <wp
                    stb       5,x
                    ldd       <currow
                    ldx       <wp
                    stb       6,x
                    ldd       <texsave
                    ldx       <wp
                    std       10,x
* Byte 0 ([<wp] = [$0008,y]) is <stocker (0/1) with bit 7 set when the window is a menu (FrWinInv), so a menu
* brought back by wrestore keeps its menu colors.
                    ldb       <stocker
                    tst       >FrWinInv
                    beq       wsv1@
                    orb       #$80
wsv1@               stb       [>$0008,y]
                    ldd       <wp
                    addd      #$000C
                    std       <wp
                    puls      u,pc
wrestore               pshs      u
                    ldx       #wstack
                    cmpx      <wp
                    bne       wrestore_1
                    clra
                    clrb
                    lbra      L59CA
wrestore_1               ldd       <wp
                    addd      #$FFF4
                    std       <wp
                    ldx       <wp
                    ldb       1,x
                    sex
                    std       <wncols
                    ldx       <wp
                    ldb       2,x
                    sex
                    std       <wnrows
                    ldx       <wp
                    ldb       3,x
                    sex
                    std       <wcleft
                    ldx       <wp
                    ldb       4,x
                    clra
                    std       <wtopy
                    ldx       <wp
                    ldb       7,x
                    sex
                    std       <nowinv
                    ldx       <wp
                    ldd       8,x
                    std       <curaddr
                    ldx       <wp
                    ldb       5,x
                    sex
                    std       <curcol
                    ldx       <wp
                    ldb       6,x
                    sex
                    std       <currow
                    ldx       <wp
                    ldd       10,x
                    std       <texsave
                    ldb       [>$0008,y]          <stocker, bit 7 = the restored window is a menu (wsave)
                    clr       >FrWinInv
                    lslb
                    rol       >FrWinInv
                    lsrb
                    stb       <stocker
                    lbra      center_1
* newin: (save, style) if save: spalloc(<wsavsiz) and bytblt(0) the covered area into it (msgCantAlloc + bell on failure); wboxclr(style), gohome, <tgwmode = 1
newin         pshs      u
                    clra
                    clrb
                    std       <texsave
                    ldb       5,s
                    beq       DrawWinAndHome
                    ldd       <wsavsiz
                    pshs      a,b
                    lbsr      spalloc
                    leas      2,s
                    std       <texsave
                    ldd       <texsave
                    bne       SaveWinBackgnd
                    ldd       <wsavsiz
                    pshs      a,b
                    leax      >msgCantAlloc,pcr
                    pshs      x
                    lbsr      printf
                    leas      4,s
                    lbsr      bell
                    bra       DrawWinAndHome
* SaveWinBackgnd: bytblt(0, col-1, bottom, right+1, top, buf)
SaveWinBackgnd      ldd       <texsave
                    pshs      a,b
                    ldd       <wtopy
                    pshs      a,b
                    ldd       <wcrght
                    addd      #$0001
                    pshs      a,b
                    ldd       <wboty
                    pshs      a,b
                    ldd       <wcleft
                    addd      #$FFFF
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    lbsr      bytblt
                    leas      12,s
* DrawWinAndHome: wboxclr then gohome and set the open flag
DrawWinAndHome      ldd       6,s
                    pshs      a,b
                    lbsr      wboxclr
                    leas      2,s
                    lbsr      gohome
                    ldd       #$0001
L59CA               equ       *
                    stb       <tgwmode
                    puls      u,pc
* wlimit: limits width to 80, height to 26, top y to 0..191, left column to 1..79
wlimit      pshs      u
                    ldd       <wncols
                    cmpd      #$0050
                    ble       a40@
                    ldd       #$0050
                    std       <wncols
a40@                ldd       <wnrows
                    cmpd      #$001A
                    ble       b40@
                    ldd       #$001A
                    std       <wnrows
b40@                ldd       <wtopy
                    bge       c40@
                    clra
                    clrb
                    std       <wtopy
c40@                ldd       <wtopy
                    cmpd      #$00BF
                    ble       d40@
                    ldd       #$00BF
                    std       <wtopy
d40@                ldd       <wcleft
                    cmpd      #$004F
                    ble       e40@
                    ldd       #$004F
                    std       <wcleft
e40@                ldd       <wcleft
                    cmpd      #$0001
                    bge       f40@
                    ldd       #$0001
                    std       <wcleft
f40@                puls      u,pc
center               pshs      u
                    bsr       wlimit
                    ldd       #$0050
                    subd      <wncols
                    pshs      a,b
                    ldd       #$0002
                    lbsr      Div16
                    std       <wcleft
                    ldd       <wnrows
                    pshs      a,b
                    ldd       #$0007
                    lbsr      Mul16
                    addd      #$00C0
                    pshs      a,b
                    ldd       #$0002
                    lbsr      Div16
                    addd      #$0008
                    std       <wtopy
center_1               bsr       winrest
                    puls      u,pc
* winrest: wlimit, right col <wcrght = col+width-1 (window shifted left if past 78), bottom y <wboty = top-10-7*height (top raised if below 0), home offset <homeaddr = (191-(top-5))*320+col*4, save size <wsavsiz = (width+2)*(top-bottom+1)+2
winrest     pshs      u
                    lbsr      wlimit
                    ldd       <wcleft
                    addd      <wncols
                    addd      #$FFFF
                    std       <wcrght
                    ldd       <wcrght
                    cmpd      #$004E
                    ble       a41@
                    ldd       <wcleft
                    pshs      a,b
                    ldd       <wcrght
                    addd      #$FFB2
                    nega
                    negb
                    sbca      #$00
                    addd      ,s++
                    std       <wcleft
                    ldd       #$004E
                    std       <wcrght
a41@                ldd       <wnrows
                    pshs      a,b
                    ldd       #$0007
                    lbsr      Mul16
                    pshs      a,b
                    ldd       <wtopy
                    addd      #$FFF6
                    subd      ,s++
                    std       <wboty
                    ldd       <wboty
                    bge       CalcWinHome
                    ldd       <wtopy
                    subd      <wboty
                    std       <wtopy
                    clra
                    clrb
                    std       <wboty
* CalcWinHome: computes the home screen address and the save-buffer size
CalcWinHome         ldd       <wtopy
                    addd      #$FFFB
                    pshs      a,b
                    ldd       #$00BF
                    subd      ,s++
                    pshs      a,b
                    ldd       #$0140
                    lbsr      Mul16
                    pshs      a,b
                    ldd       <wcleft
                    aslb
                    rola
                    aslb
                    rola
                    addd      ,s++
                    std       <homeaddr                the home cell's picture offset
                    ldd       <wncols
                    addd      #$0002
                    pshs      a,b
                    ldd       <wtopy
                    subd      <wboty
                    addd      #$0001
                    lbsr      Mul16
                    addd      #$0002
                    std       <wsavsiz
                    puls      u,pc
* wboxclr: (style) clears the window area with bytblt(2) and draws a winbox of the given style one column/row outside it
* Style WinMenu marks the window a menu (FrWinInv: glyphs from the inverted font) and draws it with Box3D (black
* inside, paper border); style 1 windows reach Box3D through winbox (paper inside, ink border).
wboxclr        pshs      u
                    clr       >FrWinInv
                    ldd       4,s
                    cmpd      #WinMenu
                    bne       wbc0@
                    inc       >FrWinInv           a menu
wbc0@               ldd       <wtopy
                    tst       >FrWinInv           a 3D box (a menu, or style 1) draws its own top row - Box3D's border -
                    bne       wbc1@               so the clear stops under it
                    ldx       4,s
                    cmpx      #$0001
                    bne       wbc2@
wbc1@               subd      #1
wbc2@               pshs      a,b
                    ldd       <wcrght
                    addd      #$0001
                    pshs      a,b
                    ldd       <wboty              the clear's bottom row
                    tst       >FrWinInv           a 3D box (a menu, or style 1): its outline's bottom row is wboty+4 and
                    bne       wbc3@               its shadow (YB+2, YB+1) sits under it, so the clear stops at the outline
                    ldx       8,s
                    cmpx      #$0001
                    bne       wbc4@
wbc3@               addd      #4
wbc4@               pshs      a,b
                    ldd       <wcleft
                    addd      #$FFFF
                    pshs      a,b
                    ldd       #$0002
                    pshs      a,b
                    lbsr      bytblt
                    leas      10,s
                    tst       >FrWinInv
                    bne       wbm@
                    ldd       4,s                 the style (1 is the 3D box: winbox hands it to Box3D in paper and ink)
                    pshs      a,b
                    bsr       wbargs@
                    lbsr      winbox
                    leas      10,s
                    puls      u,pc
* A menu: Box3D with a black inside and the menu text's paper color as its border.
wbm@                ldd       #MenuBoxMode        the mode: closed (a paper outline all round), the light gray shadow
                    pshs      a,b
                    ldd       #MenuEdgeByte       fg: the menu text's color
                    pshs      a,b
                    ldd       #MenuFillByte       bg: black
                    pshs      a,b
                    bsr       wbargs@
                    lbsr      Box3D
                    leas      14,s
                    puls      u,pc
* wbargs@: pushes the box's XL, YB, XR, YT onto the caller's stack (winbox's order: XL on top) and returns
wbargs@             puls      x                   the return
                    ldd       <wtopy
                    addd      #$FFFF
                    pshs      a,b                 YT
                    ldd       <wcrght
                    addd      #$0001
                    pshs      a,b                 XR
                    ldd       <wboty
                    addd      #$0001
                    pshs      a,b                 YB
                    ldd       <wcleft
                    addd      #$FFFF
                    pshs      a,b                 XL
                    jmp       ,x
* gohome: cursor column/row = 0, cursor address = home <$9B, redraw the underline cursor
gohome          pshs      u
                    clra
                    clrb
                    std       <currow
                    std       <curcol
                    ldd       <homeaddr
                    std       <curaddr
                    ldb       <tgwmode
                    lbeq      ShowCursorExit
                    lbra      ShowCursorRet
* alcurset: (flag) with a window open shows (CurUnder $7F) or hides (CurUnder 0) the text cursor; stores the flag in <alfacurse, clears FrEcho
alcurset         pshs      u
                    ldb       <tgwmode
                    beq       c42@
                    ldb       5,s
                    beq       a42@
                    ldb       <alfacurse
                    bne       a42@
                    ldd       #$007F
                    bra       b42@
a42@                ldb       5,s
                    bne       c42@
                    ldb       <alfacurse
                    beq       c42@
                    clra
                    clrb
b42@                lbsr      CurUnder
c42@                ldb       5,s
                    stb       <alfacurse
                    beq       d42@
                    clrb                          FrEcho stays 0 either way: vanna's two-page echo is off, the idle flip shows the echo
d42@                stb       >FrEcho
                    puls      u,pc
                    pshs      u
                    puls      u,pc
* pat: (str) vanna every byte of a NUL-terminated string into the text window
pat              pshs      u
                    leas      -1,s
                    bra       PutStrLoop
* PutStrChar: body of the pat loop: sign-extends the byte at ,s and calls vanna; PutStrLoop bne here
PutStrChar          ldb       ,s
                    sex
                    pshs      a,b
                    bsr       vanna
                    leas      2,s
* PutStrLoop: character loop of pat
PutStrLoop          ldx       5,s
                    leax      1,x
                    stx       5,s
                    ldb       -1,x
                    stb       ,s
                    bne       PutStrChar
                    leas      1,s
                    puls      u,pc
* vanna: (c) text-window character output: CR -> linefeed, FF -> clear window and home, BS -> backsp, CAN ($18) -> erase to line start, BEL -> bell, arrow glyphs, else the glyph at the cursor and advance
* While FrEcho is set and double buffering is on, a character other than BEL goes onto BOTH pages - the shown one
* first, then the hidden one with the cursor state put back - and marks nothing. alcurset keeps FrEcho 0.
vanna               pshs      u
                    ldb       >FrEcho             the two-page echo flag
                    beq       vnn@
                    tst       >FrBMShown
                    beq       vnn@
                    ldb       5,s
                    andb      #$7F
                    cmpb      #$07
                    beq       vnn@
                    inc       >FrNoDirty
                    ldd       <currow
                    pshs      a,b
                    ldd       <curcol
                    pshs      a,b
                    ldd       <curaddr
                    pshs      a,b                 ,s curaddr  2,s curcol  4,s currow  6,s U  8,s ret  10,s c
                    lbsr      SwapBase            the shown page
                    ldd       10,s
                    pshs      a,b
                    lbsr      VannaBody
                    leas      2,s
                    lbsr      SwapBase            the hidden page
                    puls      a,b
                    std       <curaddr
                    puls      a,b
                    std       <curcol
                    puls      a,b
                    std       <currow
                    ldd       4,s
                    pshs      a,b
                    lbsr      VannaBody
                    leas      2,s
                    clr       >FrNoDirty
                    puls      u,pc
vnn@                ldd       4,s
                    pshs      a,b
                    lbsr      VannaBody
                    leas      2,s
                    puls      u,pc
VannaBody           pshs      u
                    ldb       5,s
                    clra
                    andb      #$7F
                    stb       5,s
                    cmpb      #GlyphArrowFirst
                    blo       vctrl@
                    cmpb      #GlyphArrowDown
                    lbhi      PutGlyph
                    subb      #GlyphArrowFirst
                    lda       #GlyphBytes
                    mul
                    ldx       #FrArrowGlyphs
                    tst       >FrWinInv
                    beq       pga1@
                    ldx       #FrArrowInv         a menu window: the inverted arrows
pga1@               leax      d,x
                    lbra      PutGlyphSource
vctrl@              cmpb      #$20
                    lbge      PutGlyph
                    ldb       5,s
                    cmpb      #$0D
                    bne       PutCharFF
* PutCharCR: carriage return: linefeed
PutCharCR           lbsr      linefeed
                    lbra      ShowCursorRet
* PutCharFF: form feed: clears the text area (bytblt(2), or MenuFill in a menu window) and gohome
PutCharFF           ldb       5,s
                    cmpb      #$0C
                    lbne      PutCharBS
                    ldd       <wboty
                    addd      #$0005
                    pshs      a,b
                    ldd       <wcrght
                    pshs      a,b
                    ldd       <wtopy
                    addd      #$FFFB
                    pshs      a,b
                    ldd       <wcleft
                    pshs      a,b
                    tst       >FrWinInv
                    beq       pff1@
                    leas      8,s                 a menu window: its interior instead
                    lbsr      MenuFill
                    bra       pff2@
pff1@               ldd       #$0002
                    pshs      a,b
                    lbsr      bytblt
                    leas      10,s
pff2@               lbsr      gohome
                    lbra      ShowCursorRet
* MenuClear: a condensed menu's FF - its interior (MenuFill), the cursor home.
MenuClear           pshs      u
                    bsr       MenuFill
                    lbsr      gohome
                    puls      u,pc
* MenuFill: the inside of a menu's
* box in black - Box3D's bg rectangle (byte 1 of column wcleft-1 through byte 0 of column wcrght+1, rows
* wtopy-MenuFillTop down to wboty+MenuFillBot) - for the FF of a menu. BoxFill does the work. Keeps every register.
MenuFill            pshs      d,x
                    ldd       #MenuFillByte
                    pshs      d                   the fill
                    ldd       <wtopy
                    subd      <wboty
                    subd      #MenuFillTop+MenuFillBot-1
                    pshs      d                   the rows
                    ldd       <wcrght
                    subd      <wcleft
                    addd      #2
                    lslb
                    rola
                    lslb
                    rola
                    pshs      d                   bytes a row: (wcrght-wcleft+2)*4
                    ldd       <wtopy
                    subd      #MenuFillTop
                    pshs      d                   the top row
                    ldd       <wcleft
                    subd      #1
                    lslb
                    rola
                    lslb
                    rola
                    addd      #1
                    pshs      d                   the first byte: byte 1 of column wcleft-1
                    lbsr      BoxFill
                    leas      10,s
                    puls      d,x,pc
* BoxFill: a rectangle of whole bytes, args (first byte - column*4 + byte, top row, bytes a row, rows, fill byte).
* By DMA (one 2D fill, picture-row strides) when the engine is there and the rectangle is DmaMinBytes or more;
* else, or when the engine did not finish, on the CPU (FillSpan). An empty rectangle draws nothing.
* Keeps every register.
BoxFill             pshs      d,x,y,u             first byte 10,s  top 12,s  bytes 14,s  rows 16,s  fill 18,s
                    ldd       14,s
                    lble      bf0@
                    ldd       16,s
                    lble      bf0@
                    ldd       #$00BF
                    subd      12,s                191 - the top row
                    pshs      a,b
                    ldd       #$0140
                    lbsr      Mul16               the row's picture offset (the operand popped)
                    addd      10,s                + the first byte
                    pshs      a,b                 ,s the picture offset (args +2)
                    ldx       18,s                the rows
                    lbsr      DirtyRange          the blocks it covers go dirty (the DMA path has no ScrWin)
                    tst       >FrDma
                    beq       rfcpu@
                    ldd       18,s                the rows
                    pshs      a,b
                    ldd       18,s                bytes a row (14,s + 4)
                    lbsr      Mul16               D = rows x bytes (the operand popped)
                    cmpd      #DmaMinBytes
                    blo       rfcpu@
                    pshs      a,b                 ,s the count  2,s the offset (args +4)
                    ldx       18,s                bytes a row
                    ldy       20,s                rows
                    lbsr      DmaShape
                    ldx       #$0140
                    ldy       #$0140
                    lbsr      DmaStrides          both strides a picture row
                    puls      y                   Y = the count
                    lda       21,s                the fill (18,s + 2, low byte)
                    ldb       <FrBM0              the hidden page
                    ldx       ,s                  the offset
                    lbsr      DmaClr2D
                    bcc       rf9@
rfcpu@              ldd       12,s                the first byte (args +2)
                    lsra
                    rorb
                    lsra
                    rorb
                    tfr       d,x                 its column
                    ldd       14,s                the top row
                    lbsr      ScrPos              U = the column on the top row
                    ldb       13,s
                    andb      #$03
                    subb      #2                  FillRows starts at byte 2 of U: back to the first byte
                    leau      b,u
                    ldd       16,s                bytes a row
                    pshs      d
                    lda       21,s                the rows (16,s + 4, low byte)
                    ldx       22,s                the fill (18,s + 4)
                    lbsr      FillSpan
                    leas      2,s
rf9@                leas      2,s
bf0@                puls      d,x,y,u,pc
* PutCharBS: backspace: backsp unless at column 0
PutCharBS           ldb       5,s
                    cmpb      #$08
                    bne       PutCharCAN
                    ldd       <curcol
                    lbeq      ShowCursorRet
                    lbsr      backsp
                    lbra      ShowCursorRet
* PutCharCAN: $18: erase back to the start of the line
PutCharCAN          ldb       5,s
                    cmpb      #$18
                    bne       PutCharBEL
                    bra       EraseLineLoop
* EraseLineStep: body of EraseLineLoop for PutCharCAN: one lbsr backsp per remaining column
EraseLineStep       lbsr      backsp
* EraseLineLoop: backsp until column 0
EraseLineLoop       ldd       <curcol
                    bne       EraseLineStep
                    lbra      ShowCursorRet
* PutCharBEL: $07: bell
PutCharBEL          ldb       5,s
                    cmpb      #$07
                    lbne      ShowCursorRet
                    lbsr      bell
                    lbra      ShowCursorRet
* PutGlyph: draws glyph c-$20 (24 bytes at $099F + (c-$20)*24, or FrFontInv in a menu window; six rows of four
* bytes) into the cursor cell, clears the underline row (+$780) when the cursor is on, then AdvanceCursor.
* FrTxtInk set: PutGlyphInk recolors it.
PutGlyph            ldb       5,s
                    sex
                    addd      #$FFE0
                    pshs      a,b
                    ldd       #$0018
                    lbsr      Mul16
                    ldx       #$099F              the four-bit font
                    tst       >FrWinInv
                    beq       pgf1@
                    ldx       #FrFontInv          a menu window: the inverted font
pgf1@               leax      d,x
PutGlyphSource      ldd       <curaddr
                    lbsr      ScrAddr             U = the cell
                    tst       >FrTxtInk
                    lbne      PutGlyphInk         a recolored glyph (a disabled menu row)
                    ldd       ,x
                    std       ,u
                    ldd       2,x
                    std       2,u
                    ldd       4,x
                    std       >$0140,u
                    ldd       6,x
                    std       >$0142,u
                    ldd       8,x
                    std       >$0280,u
                    ldd       10,x
                    std       >$0282,u
                    ldd       12,x
                    std       >$03C0,u
                    ldd       14,x
                    std       >$03C2,u
                    ldd       <$10,x
                    std       >$0500,u
                    ldd       <$12,x
                    std       >$0502,u
                    ldd       <$14,x
                    std       >$0640,u
                    ldd       <$16,x
                    std       >$0642,u
                    ldb       <alfacurse
                    lbeq      AdvanceCursor
                    bsr       UnderClear
                    lbra      AdvanceCursor       skip recoloring after normal glyph
* UnderClear: clears the underline row of the cell at U - to paper, or in a menu window to the inverted interior.
* Keeps every register.
UnderClear          pshs      d
                    clra
                    clrb
                    tst       >FrWinInv
                    beq       ucl1@
                    coma
                    comb
ucl1@               std       >$0780,u
                    std       >$0782,u
                    puls      d,pc
* PutGlyphInk: the glyph's 24 bytes with every white nibble (COLORS_FONTINK) turned into FrTxtInk; X = the
* glyph, U = the cell. Six rows of four bytes, 320 bytes apart; then the underline as PutGlyph.
PutGlyphInk         pshs      y
                    ldb       >FrTxtInk
                    andb      #$0F
                    tfr       b,a
                    lsla
                    lsla
                    lsla
                    lsla
                    pshs      a,b                 ,s the ink in the left nibble  1,s in the right
                    ldy       #6
pgi1@               lda       #4
                    pshs      a                   ,s the bytes left in the row  1,s/2,s the inks
pgi2@               lda       ,x+
                    tst       >FrWinInv           a menu window: the inverted font back to the plain one, so the text
                    beq       pgi2n@              dots are found as usual (its paper dots become the interior at pgi4@)
                    coma
pgi2n@              tfr       a,b
                    andb      #$F0
                    cmpb      #COLORS_FONTINK*16   the left dot white?
                    bne       pgi3@
                    anda      #$0F
                    ora       1,s
pgi3@               tfr       a,b
                    andb      #$0F
                    cmpb      #COLORS_FONTINK      the right dot white?
                    bne       pgi4@
                    anda      #$F0
                    ora       2,s
pgi4@               tst       >FrWinInv           a menu window: the paper dots are the black interior
                    beq       pgi5@
                    tfr       a,b
                    andb      #$F0
                    bne       pgi4r@
                    ora       #MenuFillByte&$F0
pgi4r@              tfr       a,b
                    andb      #$0F
                    bne       pgi5@
                    ora       #MenuFillByte&$0F
pgi5@               sta       ,u+
                    dec       ,s
                    bne       pgi2@
                    leas      1,s
                    leau      >$0140-4,u          the next row
                    leay      -1,y
                    bne       pgi1@
                    leas      2,s                 the inks
                    leau      >-6*$0140,u         back to the cell
                    puls      y
                    ldb       <alfacurse
                    beq       AdvanceCursor
                    bsr       UnderClear
* AdvanceCursor: column++ (linefeed at the window width) and cursor address++
AdvanceCursor       ldd       <curcol
                    addd      #$0001
                    std       <curcol
                    cmpd      <wncols
                    lbge      PutCharCR
                    ldd       <curaddr
                    addd      #$0004              a text column is four bytes
                    std       <curaddr
* ShowCursorRet: common exit: redraws the underline cursor when <alfacurse is set
ShowCursorRet       ldb       <alfacurse
                    beq       ShowCursorExit
                    ldb       #$7F
                    bsr      CurUnder
* ShowCursorExit: plain 'puls u,pc' return: ShowCursorRet beq here with cursor off, gohome lbeq when no window
ShowCursorExit      puls      u,pc
* backsp: turns the underline off, moves the cursor back one column and blanks that cell's six glyph rows
backsp       pshs      u
                    clrb
                    lbsr      CurUnder            the underline off
                    ldd       <curcol
                    addd      #$FFFF
                    std       <curcol
                    ldd       <curaddr
                    addd      #$FFFC
                    std       <curaddr                one cell back
                    lbsr      ScrAddr
                    clra
                    clrb
                    std       ,u
                    std       2,u
                    std       >$0140,u
                    std       >$0142,u
                    std       >$0280,u
                    std       >$0282,u
                    std       >$03C0,u
                    std       >$03C2,u
                    std       >$0500,u
                    std       >$0502,u
                    std       >$0640,u
                    std       >$0642,u
                    puls      u,pc
* CurUnder: B = an eight-dot pattern for the cursor cell's underline row (+$780, under the six glyph rows): $7F on, 0 off
CurUnder            pshs      d,u
                    ldd       <curaddr
                    lbsr      ScrAddr
                    leau      >$0780,u
                    ldb       1,s
                    lbsr      PutExp
                    tst       >FrWinInv
                    beq       cun9@
                    com       ,u                  a menu window: the cursor row inverted, as its text
                    com       1,u
                    com       2,u
                    com       3,u
cun9@               puls      d,u,pc
* linefeed: erases the cursor, column = 0, row++ (scrollup on the last row), cursor address = home + row*$8C0 (7 pixel rows of 320 bytes)
linefeed             pshs      u
                    ldb       <alfacurse
                    beq       a43@
                    clrb
                    bsr      CurUnder
a43@                clra
                    clrb
                    std       <curcol
                    ldd       <wnrows
                    addd      #$FFFF
                    cmpd      <currow
                    bgt       b43@
                    bsr       scrollup
                    ldd       <wnrows
                    addd      #$FFFF
                    bra       SetCursorRow
b43@                ldd       <currow
                    addd      #$0001
                    std       <currow
                    ldd       <currow
* SetCursorRow: D = row: cursor address = home + row*$8C0; ends with the caller's puls u,pc (linefeed pushed U)
SetCursorRow        pshs      a,b
                    ldd       #$08C0              seven rows of 320
                    lbsr      Mul16
                    addd      <homeaddr
                    std       <curaddr
                    puls      u,pc
* scrollup: copies every pixel row of the window up by one text line (CopyBytes from row+$8C0) and clears the last line with bytblt(2)
scrollup        pshs      a,b,x,u
                    ldd       <wtopy
                    addd      #$FFFB
                    std       2,s
                    ldd       <homeaddr
                    bra       ScrollRowTest
* ScrollRowLoop: per-pixel-row copy loop of scrollup
* ,s = destination row offset (ScrAddr maps it to U), 2,s = row counter; the source is seven rows ($8C0) further on.
ScrollRowLoop       ldd       ,s
                    lbsr      ScrAddr
                    ldd       <wncols
                    aslb
                    rola
                    aslb
                    rola
                    pshs      a,b                 width * 4 bytes
                    leax      >$08C0,u
                    pshs      x
                    pshs      u
                    lbsr      CopyBytes
                    leas      6,s
                    ldd       2,s
                    addd      #$FFFF
                    std       2,s
                    ldd       ,s
                    addd      #$0140
* ScrollRowTest: stores the destination row offset and loops while 2,s > wboty+12; scrollup bra here to start
ScrollRowTest       std       ,s
                    ldd       <wboty
                    addd      #$000C
                    cmpd      2,s
                    blt       ScrollRowLoop
                    ldd       <wboty
                    addd      #$000C
                    pshs      a,b
                    ldd       <wcrght
                    pshs      a,b
                    ldd       <wboty
                    addd      #$0005
                    pshs      a,b
                    ldd       <wcleft
                    pshs      a,b
                    ldd       #$0002
                    pshs      a,b
                    lbsr      bytblt
                    leas      10,s
                    leas      4,s
                    puls      u,pc
L5D45               equ       *
                    fcb       $2A,$2A,$43,$61,$6E,$27,$74,$20,$66,$72,$65,$65,$20,$25,$30,$34,$78
                    fcb       $0D,$00
* msgCantAlloc: 'al%d' printed with the size when the window save buffer cannot be allocated; L5D45 above is wkill's '**Can't free %04x'
msgCantAlloc        fcc       /al%d/
                    fcb       $0D,$00
putprtr               pshs      u
                    ldd       <fprtr
                    pshs      a,b
                    ldb       7,s
                    sex
                    pshs      a,b
                    lbsr      putc
                    lbra      eject_12
                    ifdef     FRANPRINT
dumper               pshs      u
                    leax      >L615C,pcr
                    pshs      x
                    leax      >L6159,pcr
                    pshs      x
                    lbsr      fopen
                    leas      4,s
                    std       <fprtr
                    lbeq      eject_13
                    ldx       <fprtr
                    ldd       6,x
                    orb       #$80
                    std       6,x
                    ldd       #$0080
                    pshs      a,b
                    lbsr      getpid
                    pshs      a,b
                    lbsr      setpr
                    leas      4,s
                    lbsr      dump
                    ldd       <fprtr
                    pshs      a,b
                    lbsr      fclose
                    leas      2,s
                    ldd       #$00A0
                    pshs      a,b
                    lbsr      getpid
                    pshs      a,b
                    lbsr      setpr
                    lbra      eject_12
                    else
dumper              rts
                    endc
roundup               pshs      a,b,u
                    ldb       <printype
                    cmpb      #$03
                    ble       roundup_1
                    ldd       #$0008
                    bra       roundup_2
roundup_1               ldd       #$0007
roundup_2               std       ,s
                    ldd       #$00C0
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    lbsr      zclamp
                    leas      4,s
                    std       6,s
                    addd      ,s
                    addd      #$FFFF
                    pshs      a,b
                    ldd       2,s
                    lbsr      Div16
                    stb       <pnrows
                    ldd       ,s
                    pshs      a,b
                    ldb       <pnrows
                    sex
                    lbsr      Mul16
                    std       6,s
                    bra       blank_3
ndump               pshs      u
                    ldd       4,s
                    pshs      a,b
                    bsr       roundup
                    leas      2,s
                    std       4,s
                    lbsr      dumper
                    ldd       4,s
                    puls      u,pc
blank               pshs      a,b,u
                    ldd       6,s
                    pshs      a,b
                    ldd       #$0050
                    lbsr      Mul16
                    addd      <vdgram
                    std       ,s
                    addd      #$004F
                    tfr       d,u
                    bra       blank_2
blank_1               leau      -1,u
                    ldb       1,u
                    beq       blank_2
                    clra
                    clrb
                    bra       blank_3
blank_2               cmpu      ,s
                    bhi       blank_1
                    ldd       #$0001
blank_3               leas      2,s
                    puls      u,pc
squeeze               pshs      a,b,x,y,u
                    ldd       #$00BF
                    std       ,s
                    ldd       #$0001
                    std       2,s
                    clra
                    clrb
                    bra      squeeze_5
squeeze_1               ldd       4,s
                    pshs      a,b
                    bsr       blank
                    std       ,s++
                    beq       squeeze_2
                    ldd       2,s
                    addd      #$0001
                    bra      squeeze_4
squeeze_2               ldb       <dosqueeze
                    beq       squeeze_3
                    ldd       2,s
                    cmpd      #$0002
                    blt       squeeze_3
                    ldd       2,s
                    addd      #$FFFF
                    std       2,s
                    ldd       ,s
                    subd      4,s
                    addd      #$0001
                    pshs      a,b
                    ldd       #$0050
                    lbsr      Mul16
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    ldd       #$0050
                    lbsr      Mul16
                    addd      <vdgram
                    pshs      a,b
                    ldd       8,s
                    subd      6,s
                    pshs      a,b
                    ldd       #$0050
                    lbsr      Mul16
                    addd      <vdgram
                    pshs      a,b
                    lbsr      CopyBytes
                    leas      6,s
                    ldd       4,s
                    subd      2,s
                    std       4,s
                    ldd       ,s
                    subd      2,s
                    std       ,s
squeeze_3               clra
                    clrb
squeeze_4               std       2,s
                    ldd       4,s
                    addd      #$0001
squeeze_5               std       4,s
                    ldd       4,s
                    cmpd      ,s
                    ble      squeeze_1
                    ldd       ,s
                    cmpd      #$00BF
                    bge       squeeze_6
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$00BE
                    subd      2,s
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    lbsr      yclear
                    leas      6,s
squeeze_6               ldd       ,s
                    subd      2,s
                    addd      #$0001
                    lbra      prtboss_20
eject               pshs      a,b,x,u
                    ldb       <printype
                    cmpb      #$03
                    bne       eject_1
                    ldd       #$02DA
                    bra       eject_2
eject_1               ldd       #$0318
eject_2               std       ,s
                    addd      #$0006
                    subd      <printy
                    pshs      a,b
                    ldd       #$000C
                    lbsr      Div16
                    std       2,s
                    cmpd      #$003F
                    ble       eject_3
                    clra
                    clrb
                    std       2,s
eject_3               ldd       <printy
                    pshs      a,b
                    ldd       4,s
                    pshs      a,b
                    ldd       #$000C
                    lbsr      Mul16
                    addd      ,s++
                    std       <printy
                    cmpd      ,s
                    ble       eject_4
                    ldd       <printy
                    subd      ,s
                    std       <printy
eject_4               leax      >L6161,pcr
                    pshs      x
                    leax      >L615E,pcr
                    pshs      x
                    lbsr      fopen
                    leas      4,s
                    std       <fprtr
                    beq      eject_11
                    ldx       <fprtr
                    ldd       6,x
                    orb       #$80
                    std       6,x
                    bra       eject_9
eject_5               ldd       2,s
                    cmpd      #$0004
                    bne       eject_7
                    ldb       <prpage
                    sex
                    pshs      a,b
                    ldd       >FrData_reserved_06F8
                    pshs      a,b
                    leax      >L6163,pcr
                    pshs      x
                    ldd       <fprtr
                    pshs      a,b
                    lbsr      fprintf
                    leas      8,s
                    ldb       <doesff
                    beq       eject_6
                    ldd       #$000C
                    pshs      a,b
                    lbsr      putprtr
                    leas      2,s
                    ldd       #$0001
                    std       <printy
                    bra       eject_10
eject_6               ldb       <printype
                    cmpb      #$03
                    ble       eject_8
eject_7               ldd       #$000A
                    pshs      a,b
                    lbsr      putprtr
                    leas      2,s
eject_8               ldd       2,s
                    addd      #$FFFF
                    std       2,s
eject_9               ldd       2,s
                    bgt       eject_5
eject_10               ldd       <fprtr
                    pshs      a,b
                    lbsr      fclose
                    leas      2,s
eject_11               ldb       <prpage
                    addd      #$0001
                    stb       <prpage
eject_12               leas      4,s
eject_13               puls      u,pc
prtboss               pshs      a,b,x,y,u
                    ldb       <arg1
                    clra
                    andb      #$0F
                    stb       <printype
                    ldb       <arg2
                    stb       <dosqueeze
                    ldb       <arg3
                    stb       <doesff
                    ldb       <arg4
                    stb       <automarg
                    ldb       <printype
                    cmpb      #$03
                    bne       prtboss_1
                    ldd       #$02DA
                    bra       prtboss_2
prtboss_1               ldd       #$0318
prtboss_2               std       ,s
                    ldb       <arg0
                    sex
                    tfr       d,x
                    lbra      prtboss_19
prtboss_3               ldd       #$0001
                    std       <printy
                    stb       <prpage
                    lbra      prtboss_20
prtboss_4               lbsr      squeeze
                    pshs      a,b
                    lbsr      roundup
                    leas      2,s
                    std       4,s
prtboss_5               ldd       <printy
                    cmpd      #$0030
                    blt       prtboss_6
                    ldd       ,s
                    addd      #$FFFA
                    cmpd      <printy
                    lbgt      prtboss_12
prtboss_6               leax      >L616E,pcr
                    pshs      x
                    leax      >L616B,pcr
                    pshs      x
                    lbsr      fopen
                    leas      4,s
                    std       <fprtr
                    beq       prtboss_9
                    ldx       <fprtr
                    ldd       6,x
                    orb       #$80
                    std       6,x
                    ldb       <automarg
                    bne       prtboss_7
                    leax      >L6170,pcr
                    pshs      x
                    ldd       <fprtr
                    pshs      a,b
                    lbsr      fprintf
                    leas      4,s
prtboss_7               ldb       <prpage
                    sex
                    pshs      a,b
                    ldd       >FrData_reserved_06F8
                    pshs      a,b
                    leax      >L6174,pcr
                    pshs      x
                    ldd       <fprtr
                    pshs      a,b
                    lbsr      fprintf
                    leas      8,s
                    ldb       <printype
                    cmpb      #$03
                    ble       prtboss_8
                    ldd       #$000A
                    pshs      a,b
                    lbsr      putprtr
                    leas      2,s
prtboss_8               ldd       <fprtr
                    pshs      a,b
                    lbsr      fclose
                    leas      2,s
prtboss_9               ldd       <printy
                    addd      #$0030
                    std       <printy
                    cmpd      ,s
                    ble       prtboss_13
                    ldb       <automarg
                    beq       prtboss_10
                    ldd       #$0031
                    bra       prtboss_11
prtboss_10               ldd       <printy
                    subd      ,s
prtboss_11               std       <printy
                    bra       prtboss_13
prtboss_12               ldd       <printy
                    addd      4,s
                    pshs      a,b
                    ldd       2,s
                    addd      #$FFC4
                    cmpd      ,s++
                    bge       prtboss_13
                    lbsr      eject
                    lbra      prtboss_5
prtboss_13               lbsr      dumper
                    ldd       <printy
                    addd      4,s
                    std       <printy
                    leax      >L617F,pcr
                    pshs      x
                    leax      >L617C,pcr
                    pshs      x
                    lbsr      fopen
                    leas      4,s
                    std       <fprtr
                    beq       prtboss_14
                    ldx       <fprtr
                    ldd       6,x
                    orb       #$80
                    std       6,x
                    ldd       #$000A
                    pshs      a,b
                    lbsr      putprtr
                    leas      2,s
                    ldd       <fprtr
                    pshs      a,b
                    lbsr      fclose
                    leas      2,s
prtboss_14               ldd       <printy
                    addd      #$000C
                    std       <printy
                    bra       prtboss_20
prtboss_15               lbsr      eject
                    bra       prtboss_20
prtboss_16               ldb       <arg0
                    cmpb      #$71
                    bne       prtboss_17
                    lbsr      squeeze
                    bra       prtboss_18
prtboss_17               ldd       #$00C0
prtboss_18               pshs      a,b
                    lbsr      ndump
                    leas      2,s
                    bra       prtboss_20
prtboss_19               cmpx      #$0062
                    lbeq      prtboss_3
                    cmpx      #$0064
                    lbeq      prtboss_4
                    cmpx      #$0065
                    beq       prtboss_15
                    cmpx      #$0071
                    beq       prtboss_16
                    cmpx      #$0031
                    beq      prtboss_16
                    bra       prtboss_20
prtboss_20               leas      6,s
                    puls      u,pc
L6135               equ       *
                    fcb       $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
                    fcb       $00
L6159               equ       *
                    fcb       $2F,$70,$00
L615C               equ       *
                    fcb       $77,$00
L615E               equ       *
                    fcb       $2F,$70
                    fcb       $00
L6161               equ       *
                    fcb       $77,$00
L6163               equ       *
                    fcb       $25,$73,$2D,$25,$64,$2D
                    fcb       $0D,$00
L616B               equ       *
                    fcb       $2F,$70,$00
L616E               equ       *
                    fcb       $77,$00
L6170               equ       *
                    fcb       $0A
                    fcb       $0A,$0A,$00
L6174               equ       *
                    fcb       $25,$73,$2D,$25,$64,$2D
                    fcb       $0D,$00
L617C               equ       *
                    fcb       $2F,$70,$00
L617F               equ       *
                    fcb       $77,$00
* Beep: silent on wildbits ($FF20 is WizFi.Base, $FF00-$FF03 is SDC1, not the CoCo DAC/PIAs); returns B = 0
* The original CoCo tone code follows, commented out: it must never run on wildbits.
Beep                clrb                          no error, no sound
                    rts
*                     bsr       SoundEnable
*                     pshs      cc
*                     orcc      #$50
*                     lda       #$E6
* BeepToneLoop: one DAC high/low cycle of Beep
* BeepToneLoop        bsr       BeepDelay
*                     tfr       a,b
*                     andb      #$F7
*                     orb       #$02
*                     stb       >$FF20
*                     bsr       BeepDelay
*                     ldb       #$02
*                     stb       >$FF20
*                     deca
*                     deca
*                     cmpa      #$12
*                     bhs       BeepToneLoop
*                     puls      cc
*                     lda       >$FF23
*                     anda      #$F7
*                     sta       >$FF23
*                     clrb
*                     rts
* SoundEnable: sets PIA1 CB2 ($FF23 bit 3) sound enable and clears the HS/FS interrupt enables in $FF01/$FF03
* SoundEnable         lda       >$FF23
*                     ora       #$08
*                     sta       >$FF23
*                     lda       >$FF01
*                     anda      #$F7
*                     sta       >$FF01
*                     lda       >$FF03
*                     anda      #$F7
*                     sta       >$FF03
*                     rts
* BeepDelay: $B4-count busy delay
* BeepDelay           ldb       #$B4
* BeepDelayLoop: decb/bne delay loop
* BeepDelayLoop       decb
*                     bne       BeepDelayLoop
*                     rts
                    fcb       $8D,$DF,$86,$0A,$1F,$89,$5A,$26
                    fcb       $FD,$F6,$FF,$20,$C8,$F0,$F7,$FF
                    fcb       $20,$4C,$81,$4C,$25,$EE,$20,$BF
L61E4               pshs      a,b
                    stu       -2,s
                    bne       L61E4_2
                    leau      >FrStdin,y
                    lda       #$10
L61E4_1               ldb       7,u
                    andb      #$03
                    beq       L61E4_2
                    leau      13,u
                    deca
                    bne       L61E4_1
                    ldd       #$00C8
                    std       <FrData_reserved_001A
                    clra
                    clrb
                    puls      x,pc
L61E4_2               puls      a,b
                    std       8,u
                    ldd       1,x
                    tsta
                    beq       L61E4_4
                    cmpa      #$2B
                    beq       L61E4_3
                    cmpb      #$2B
                    bne       L61E4_4
L61E4_3               ldb       #$03
                    bra       L61E4_7
L61E4_4               ldb       ,x
                    cmpb      #$72
                    beq       L61E4_5
                    cmpb      #$64
                    bne       L61E4_6
L61E4_5               ldb       #$01
                    bra       L61E4_7
L61E4_6               ldb       #$02
L61E4_7               orb       7,u
                    stb       7,u
                    ldd       2,u
                    addd      11,u
                    std       ,u
                    std       4,u
                    tfr       u,d
                    rts
L6238               clra
                    clrb
                    pshs      a,b,u
                    ldd       1,x
                    tsta
                    beq       L6238_4
                    cmpa      #$78
                    bne       L6238_2
                    cmpb      #$2B
                    bne       L6238_1
                    ldd       #$0007
                    bra       L6238_3
L6238_1               ldd       #$0004
                    bra       L6238_3
L6238_2               cmpa      #$2B
                    bne       L6238_9
                    ldd       #$0003
L6238_3               std       ,s
L6238_4               ldb       ,x
                    cmpb      #$72
                    bne       L6238_5
                    ldd       ,s
                    orb       #$01
                    bra       L6238_11
L6238_5               cmpb      #$61
                    bne       L6238_6
                    ldd       ,s
                    orb       #$02
                    pshs      a,b
                    pshs      u
                    lbsr      open
                    leas      4,s
                    std       2,s
                    cmpd      #$FFFF
                    beq       L6238_7
                    ldu       #$0002
                    ldx       #$0000
                    pshs      x,u
                    pshs      a,b,x
                    lbsr      lseek
                    puls      a,b
                    leas      6,s
                    bra       L6238_13
L6238_6               cmpb      #$77
                    bne       L6238_8
L6238_7               ldd       ,s
                    orb       #$02
                    pshs      a,b
                    pshs      u
                    lbsr      CreateOrTruncate
                    bra       L6238_12
L6238_8               cmpb      #$64
                    beq       L6238_10
L6238_9               ldd       #$00CB
                    std       <FrData_reserved_001A
                    ldd       #$FFFF
                    bra       L6238_13
L6238_10               ldd       ,s
                    orb       #$81
L6238_11               pshs      a,b
                    pshs      u
                    lbsr      open
L6238_12               leas      4,s
L6238_13               leas      4,s
                    rts
                    pshs      u
                    ldu       #$0000
                    ldx       6,s
                    ldd       4,s
                    bra       L62FC
fopen               pshs      u
                    ldx       6,s
                    ldu       4,s
                    lbsr      L6238
                    ldu       #$0000
                    std       -2,s
                    bpl       fopen_1
L62DE               equ       *
                    clra
                    clrb
                    puls      u,pc
                    pshs      u
                    ldd       8,s
                    pshs      a,b
                    lbsr      fclose
                    leas      2,s
                    ldx       6,s
                    ldu       4,s
                    lbsr      L6238
                    std       -2,s
                    bmi       L62DE
                    ldu       8,s
fopen_1               ldx       6,s
L62FC               equ       *
                    lbsr      L61E4
                    puls      u,pc
* gets: (buf) getc from stdin into buf until CR (NUL-terminated, returns buf) or EOF (returns 0); flips the page first
* Stores at most 80 characters (phrsa's buffer is 81 bytes); the rest of the line is read and dropped up to the CR.
gets            pshs      u
                    lbsr      Present             the prompt is complete: flip before the wait
                    ldu       4,s
                    ldb       #80
                    stb       >FrGetsLeft
                    bra       ReadLineLoop
* ReadLineStore: stores the char at ,u+ while FrGetsLeft allows, then falls into ReadLineLoop
ReadLineStore       tst       >FrGetsLeft
                    beq       ReadLineLoop        the buffer is full: the character is consumed, not stored
                    dec       >FrGetsLeft
                    stb       ,u+
* ReadLineLoop: character loop of gets
ReadLineLoop        leax      >FrStdin,y
                    pshs      x
                    lbsr      getc
                    leas      2,s
                    cmpb      #$0D
                    beq       a44@
                    cmpd      #$FFFF
                    bne       ReadLineStore
* EOF without a CR: NUL-terminate the buffer too and return 0.
                    clr       ,u
                    clra
                    clrb
                    bra       b44@
a44@                clr       ,u
                    ldd       4,s
b44@                puls      u,pc
* fread: (buf, size, count, fp) getc size*count bytes; returns the number of whole items read
fread               pshs      a,b,x,u
                    ldu       8,s
                    clra
                    clrb
                    bra       FReadItemTest
* FReadItemLoop: outer item loop of fread: reloads the per-item byte count from 10,s; the item test blt here
FReadItemLoop       ldd       10,s
                    bra       FReadByteTest
* FReadByteLoop: inner byte loop of fread
FReadByteLoop       ldd       14,s
                    pshs      a,b
                    lbsr      getc
                    leas      2,s
                    cmpd      #$FFFF
                    beq       a45@
                    stb       ,u+
                    ldd       ,s
                    subd      #$0001
* FReadByteTest: inner byte-count test of fread: stores the decremented count and loops to FReadByteLoop
FReadByteTest       std       ,s
                    bne       FReadByteLoop
                    ldd       2,s
                    addd      #$0001
* FReadItemTest: item-count test of fread: stores the count, loops while below count 12,s; the prologue bra here
FReadItemTest       std       2,s
                    cmpd      12,s
                    blt       FReadItemLoop
a45@                leas      2,s
                    puls      a,b,u,pc
* printf: (fmt, ...) to stdout (FrStdout) through FormatEngine with PfPutcStream
printf              pshs      u
                    leau      6,s
                    leax      >FrStdout,y
                    ldd       4,s
                    bra       SetStreamPutc
* fprintf: (fp, fmt, ...) through FormatEngine with PfPutcStream
fprintf             pshs      u
                    leau      8,s
                    ldx       4,s
                    ldd       6,s
* SetStreamPutc: printf/fprintf join: stores the FILE pointer in $3A5C and picks the PfPutcStream callback
SetStreamPutc       stx       >$3A5C,y
                    leax      >PfPutcStream,pcr
                    bra       CallFormat
* sprintf: (buf, fmt, ...) output pointer in $3A5C, characters stored by PfPutcBuf
sprintf             pshs      u
                    ldd       4,s
                    std       >$3A5C,y
                    leau      8,s
                    ldd       6,s
                    leax      >PfPutcBuf,pcr
* CallFormat: pushes args/fmt/putc pointer and calls FormatEngine
CallFormat          pshs      a,b,u
                    pshs      x
                    bsr       FormatEngine
                    leas      6,s
                    puls      u,pc
* FmtEngineDone: FormatEngine exit: FmtLoop beq here at the end of the format string; leas 8,s then rts
FmtEngineDone       leas      8,s
                    rts
* FormatEngine: printf core: walks the format string, parses '-', '0', width and .precision, converts d u x X o s c l e f g E G through the Fmt* routines and pads with FmtOutField
FormatEngine        ldu       4,s
                    leas      -8,s
                    bra       FmtLoop
* FmtChar: %c: fetch the int argument and output its low byte
FmtChar             ldx       14,s
                    ldd       ,x++
                    stx       14,s
* FmtPutChar: emit one character through the putc callback
FmtPutChar          jsr       [<$0A,s]
* FmtLoop: format-string loop head: plain characters go out, '%' starts a conversion
FmtLoop             ldb       ,u+
                    beq       FmtEngineDone
                    cmpb      #$25
                    bne       FmtPutChar
                    clrb
                    lda       #$7D
                    std       ,s
                    stb       7,s
                    stb       2,s
                    ldb       ,u+
                    cmpb      #$2D
                    bne       a46@
                    stb       7,s
                    ldb       ,u+
a46@                cmpb      #$30
                    beq       FmtWidth
                    ldb       #$20
* FmtWidth: parses the field width (FmtAtoi) and optional .precision
FmtWidth            stb       6,s
                    ldb       -1,u
                    lbsr      FmtAtoi
                    std       3,s
                    ldb       ,u+
                    cmpb      #$2E
                    bne       FmtConvType
                    stb       2,s
                    ldb       ,u+
                    lbsr      FmtAtoi
                    std       ,s
                    ldb       ,u+
* FmtConvType: dispatch on the conversion letter
FmtConvType         cmpb      #$63
                    beq       FmtChar
                    pshs      u
                    cmpb      #$66
                    beq       FmtFloat
                    cmpb      #$65
                    beq       FmtFloat
                    cmpb      #$67
                    beq       FmtFloat
                    cmpb      #$45
                    beq       FmtFloat
                    cmpb      #$47
                    beq       FmtFloat
                    cmpb      #$6C
                    beq       FmtLong
                    cmpb      #$73
                    beq       FmtString
                    cmpb      #$64
                    lbeq      FmtDecimal
                    cmpb      #$6F
                    lbeq      FmtOctal
                    cmpb      #$78
                    lbeq      FmtHex
                    cmpb      #$58
                    lbeq      FmtHex
                    cmpb      #$75
                    lbeq      FmtUnsigned
                    puls      u
                    lbra      FmtPutChar
* FmtFloat: %f %e %g %E %G: calls the FtoaStub (floating point not linked, yields an empty string)
FmtFloat            ldd       5,s
                    pshs      a,b
                    leax      <$12,s
                    ldd       4,s
                    tst       6,s
                    bne       a47@
                    ldd       #$0006
a47@                pshs      a,b,x
                    ldd       #$7D00
                    std       8,s
                    ldb       -1,u
                    clra
                    pshs      a,b
                    lbsr      FtoaStub
                    bra       FmtStrResult
* FmtLong: %l: fetches a 32-bit argument and converts with LongToStr
FmtLong             pshs      u
                    ldx       <$12,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      4,x
                    stx       <$16,s
                    ldb       ,u+
                    stu       6,s
                    pshs      a,b
                    lbsr      LongToStr
* FmtStrResult: shared tail of FmtFloat/FmtLong: drops 8 arg bytes, U = converted string, jumps to FmtPadAndNext
FmtStrResult        leas      8,s
                    tfr       d,u
                    lbra      FmtPadAndNext
* FmtString: %s: uses '(null)' for a zero pointer, honors the precision
FmtString           bsr       FmtNextArg
                    tfr       d,u
                    cmpd      #$0000
                    bne       a48@
                    leau      >strNull,pcr
                    tfr       u,d
a48@                pshs      u
                    lbsr      strlen
                    leas      2,s
                    tst       4,s
                    beq       b48@
                    cmpd      2,s
                    bhi       b48@
                    std       2,s
b48@                lbsr      FmtOutField
                    lbra      FmtConvNext
* FmtDecimal: %d: sign handling then FmtDecConv
FmtDecimal          bsr       FmtNumBufArg
                    pshs      a,b,x,y,u
                    tsta
                    bpl       FmtDecConv
                    nega
                    negb
                    sbca      #$00
                    std       ,s
                    ldb       #$2D
                    stb       ,u+
                    bra       FmtDecConv
* FmtUnsigned: %u: FmtDecConv without sign
FmtUnsigned         bsr       FmtNumBufArg
                    pshs      a,b,x,y,u
* FmtDecConv: converts D to decimal with the power table FrPow10 (10000..10, the units digit is the remainder), suppressing leading zeros
FmtDecConv          ldd       #$0005
                    std       2,s
                    sta       4,s
                    leax      >FrPow10,y
                    puls      a,b
                    bra       FmtDecDigitNext
* FmtDecDigitInc: counts one subtraction in FmtDecDigitLoop; the loop bhs here while D still >= the power of ten
FmtDecDigitInc      inc       ,s
* FmtDecDigitLoop: repeated-subtraction digit loop of FmtDecConv
FmtDecDigitLoop     subd      ,x
                    bhs       FmtDecDigitInc
                    addd      ,x++
                    pshs      b
                    ldb       1,s
                    tst       3,s
                    bne       a49@
                    tstb
                    beq       b49@
                    inc       3,s
a49@                addb      #$30
                    stb       ,u+
b49@                clr       1,s
                    puls      b
* FmtDecDigitNext: power-of-ten counter of FmtDecConv: dec 1,s and loops to FmtDecDigitLoop; the setup bra here
FmtDecDigitNext     dec       1,s
                    bne       FmtDecDigitLoop
                    addb      #$30
                    stb       ,u+
                    clr       ,u
                    leas      4,s
                    bra       FmtNumDone
* FmtNumBufArg: points U at the number buffer $3A5E and falls into FmtNextArg
FmtNumBufArg        leau      >$3A5E,y
* FmtNextArg: fetches the next 16-bit vararg and advances the argument pointer
FmtNextArg          ldx       <$12,s
                    ldd       ,x++
                    stx       <$12,s
                    rts
* FmtHex: %x/%X: hex digits (letter case from the conversion char), then StrReverse
FmtHex              andb      #$20
                    stb       7,s
                    bsr       FmtNumBufArg
                    pshs      a,b,u
* FmtHexLoop: nibble loop of FmtHex
FmtHexLoop          andb      #$0F
                    pshs      b
                    lda       #$30
                    cmpb      #$09
                    ble       a50@
                    lda       #$37
                    adda      12,s
a50@                adda      ,s+
                    sta       ,u+
                    ldd       ,s
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    std       ,s
                    bne       FmtHexLoop
* FmtRadixDone: NUL-terminates the digits and StrReverses them; FmtHexLoop falls in, FmtOctalLoop bra here
FmtRadixDone        clr       ,u
                    ldx       2,s
                    bsr       StrReverse
                    leas      2,s
* FmtNumDone: FmtDecConv bra here after the digits: pops the saved buffer pointer, falls into FmtPadAndNext
FmtNumDone          puls      u
* FmtPadAndNext: calls FmtPadStr on the converted string then falls into FmtConvNext; FmtStrResult lbra here
FmtPadAndNext       bsr       FmtPadStr
* FmtConvNext: restores the saved format pointer and lbra FmtLoop; FmtString lbra here after FmtOutField
FmtConvNext         puls      u
                    lbra      FmtLoop
* StrReverseLoop: swap loop of StrReverse
StrReverseLoop      ldb       ,x
                    lda       ,-u
                    sta       ,x+
                    stb       ,u
* StrReverse: reverses the characters between X and U in place
StrReverse          pshs      u
                    cmpx      ,s++
                    blo       StrReverseLoop
                    rts
* FmtOctal: %o: octal digits then StrReverse
FmtOctal            bsr       FmtNumBufArg
                    pshs      a,b,u
* FmtOctalLoop: 3-bit digit loop of FmtOctal
FmtOctalLoop        andb      #$07
                    addb      #$30
                    stb       ,u+
                    ldd       ,s
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    std       ,s
                    bne       FmtOctalLoop
                    bra       FmtRadixDone
* FmtPadStr: strlen of the converted string then FmtOutField
FmtPadStr           pshs      u
                    lbsr      strlen
                    leas      2,s
* FmtOutField: outputs the converted field with left/right padding to the parsed width
FmtOutField         nega
                    negb
                    sbca      #$00
                    addd      7,s
                    std       7,s
                    tst       11,s
                    bne       FmtOutNext
                    bsr       FmtEmitPad
                    bra       FmtOutNext
* FmtOutLoop: emits the field characters
FmtOutLoop          ldb       ,u+
                    beq       a51@
                    jsr       [<$0E,s]
* FmtOutNext: precision counter of FmtOutField: dec 4,s (characters left) and loops to FmtOutLoop; both FmtOutField paths reach it
FmtOutNext          ldd       4,s
                    subd      #$0001
                    std       4,s
                    bpl       FmtOutLoop
a51@                tst       11,s
                    beq       b51@
                    bsr       FmtEmitPad
b51@                rts
* FmtPadChar: body of the FmtEmitPad loop: emits the pad byte 12,s through the putc vector [<$10,s]
FmtPadChar          ldb       12,s
                    jsr       [<$10,s]
* FmtEmitPad: emits the pad character (space or 0) for the remaining width
FmtEmitPad          ldd       9,s
                    subd      #$0001
                    std       9,s
                    bpl       FmtPadChar
                    rts
* FmtAtoi: parses a decimal number from the format string using the ctype table FrCtype (bit $08 = digit)
FmtAtoi             clr       ,-s
                    clr       ,-s
                    leau      -1,u
                    leax      >FrCtype,y
                    bra       FmtAtoiTest
* FmtAtoiLoop: value*10 + digit loop
FmtAtoiLoop         ldd       ,s
                    aslb
                    rola
                    std       ,s
                    aslb
                    rola
                    aslb
                    rola
                    addd      ,s
                    addb      ,u+
                    adca      #$00
                    subd      #$0030
                    std       ,s
                    ldb       ,u
* FmtAtoiTest: digit test of FmtAtoi: ctype bit $08 loops back to FmtAtoiLoop; the prologue bra here
FmtAtoiTest         lda       b,x
                    anda      #$08
                    bne       FmtAtoiLoop
                    puls      a,b,pc
* PfPutcStream: printf's per-character callback: putc(char, stream from $3A5C)
PfPutcStream        ldx       >$3A5C,y
                    pshs      a,b,x
                    bsr      putc
                    leas      4,s
                    rts
* PfPutcBuf: sprintf's callback: stores the character at [$3A5C]++ and NUL-terminates
PfPutcBuf           ldx       >$3A5C,y
                    stb       ,x+
                    stx       >$3A5C,y
                    clr       ,x
                    rts
* strNull: '(null)' substituted for a zero %s argument
strNull             fcb       $28,$6E,$75,$6C,$6C,$29,$00
                    pshs      u
                    ldu       6,s
                    ldb       4,s
                    pshs      a,b,u
                    bsr       putc
                    ldb       9,s
                    stb       1,s
                    bsr       putc
                    leas      4,s
                    puls      u,pc
putc               pshs      u
                    ldu       6,s
                    ldd       6,u
                    anda      #$80
                    andb      #$22
                    cmpb      #$02
                    bne       putc_4
                    cmpa      #$80
                    beq       putc_1
                    pshs      u
                    lbsr      AllocFileBuf
                    leas      2,s
putc_1               ldd       6,u
                    andb      #$04
                    beq       putc_5
                    ldd       #$0001
                    pshs      a,b
                    leax      7,s
                    ldd       8,u
                    pshs      a,b,x
                    ldb       7,u
                    andb      #$40
                    beq       putc_2
                    lbsr      writeln
                    bra       putc_3
putc_2               lbsr      write
putc_3               leas      6,s
                    cmpd      #$FFFF
                    bne       putc_8
                    ldb       7,u
                    orb       #$20
                    stb       7,u
putc_4               ldd       #$FFFF
                    puls      u,pc
putc_5               anda      #$01
                    bne       putc_6
                    pshs      u
                    lbsr      FlushBuffer
                    std       ,s++
                    bne       putc_4
putc_6               ldx       ,u
                    ldb       5,s
                    stb       ,x+
                    stx       ,u
                    cmpx      4,u
                    bhs       putc_7
                    ldb       7,u
                    andb      #$40
                    beq       putc_8
                    ldb       5,s
                    cmpb      #$0D
                    bne       putc_8
putc_7               pshs      u
                    bsr      FlushBuffer
                    std       ,s++
                    bne       putc_4
putc_8               ldd       4,s
                    puls      u,pc
* CloseAllFiles: _cleanup: fclose each of the 16 FILE structs (13 bytes) from FrStdin
CloseAllFiles       pshs      u
                    leax      >FrStdin,y
                    ldb       #$10
                    pshs      b
* CloseAllLoop: per-FILE loop of CloseAllFiles
CloseAllLoop        pshs      x
                    bsr       fclose
                    puls      x
                    leax      13,x
                    dec       ,s
                    bne       CloseAllLoop
                    puls      b,u,pc
* fclose: (fp) fflush when open for writing, close, clear the flags
fclose              pshs      u
                    ldu       4,s
                    beq      RetMinusOne
                    ldd       6,u
                    beq      RetMinusOne
                    andb      #$02
                    beq       FCloseNoFlush
                    pshs      u
                    bsr       fflush
                    leas      2,s
                    bra       FCloseFinish
* RetMinusOne: returns -1 for a bad FILE pointer
RetMinusOne         ldd       #$FFFF
                    puls      u,pc
* FCloseNoFlush: fclose path for a non-write stream: D=0 and falls into FCloseFinish; the flag test beq here
FCloseNoFlush       clra
                    clrb
* FCloseFinish: close tail shared by both fclose paths: close on 8,u then clears the flag word at 6,u
FCloseFinish        pshs      a,b
                    ldd       8,u
                    pshs      a,b
                    lbsr      close
                    leas      2,s
                    clra
                    clrb
                    std       6,u
                    puls      a,b,u,pc
* fflush: (fp) allocates the buffer if needed (AllocFileBuf) and writes it out with FlushBuffer
fflush              pshs      u
                    ldu       4,s
                    beq      RetMinusOne
                    ldd       6,u
                    andb      #$22
                    cmpb      #$02
                    bne      RetMinusOne
                    anda      #$80
                    bne       a52@
                    pshs      u
                    lbsr      AllocFileBuf
                    leas      2,s
a52@                pshs      u
                    bsr       FlushBuffer
                    leas      2,s
                    puls      u,pc
* FlushBuffer: writes the pending buffer contents with writeln (flag $40 line mode, one line at a time) or write, seeking first when the file position was moved
FlushBuffer         pshs      u
                    ldu       4,s
                    leas      -4,s
                    lda       6,u
                    anda      #$01
                    bne       a53@
                    ldd       ,u
                    cmpd      4,u
                    beq       a53@
                    clra
                    clrb
                    pshs      a,b
                    pshs      u
                    lbsr      ClearLongRes
                    leas      2,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       8,u
                    pshs      a,b
                    lbsr      lseek
                    leas      8,s
a53@                ldd       ,u
                    subd      2,u
                    std       2,s
                    beq      FlushResetBuf
                    ldd       6,u
                    anda      #$01
                    beq      FlushResetBuf
                    andb      #$40
                    beq       FlushWriteAll
                    ldd       2,u
                    bra       FlushLineNext
* FlushLineLoop: I$WritLn loop for line-mode streams
FlushLineLoop       pshs      a,b
                    ldd       ,u
                    pshs      a,b
                    ldd       8,u
                    pshs      a,b
                    lbsr      writeln
                    leas      6,s
                    std       ,s
                    cmpd      #$FFFF
                    beq       FlushError
                    ldd       2,s
                    subd      ,s
                    std       2,s
                    ldd       ,u
                    addd      ,s
* FlushLineNext: line-loop test of FlushBuffer: stores the buffer ptr, repeats while bytes remain; setup bra here
FlushLineNext       std       ,u
                    ldd       2,s
                    bne       FlushLineLoop
                    bra       FlushResetBuf
* FlushWriteAll: single I$Write of the whole buffer
FlushWriteAll       ldd       2,s
                    pshs      a,b
                    ldd       2,u
                    pshs      a,b
                    ldd       8,u
                    pshs      a,b
                    lbsr      write
                    leas      6,s
                    cmpd      2,s
                    beq       FlushResetBuf
* FlushError: sets the error flag $20 and returns -1
FlushError          ldb       7,u
                    orb       #$20
                    stb       7,u
                    ldd       4,u
                    std       ,u
                    ldd       #$FFFF
                    bra       FlushBufRet
* FlushResetBuf: marks the stream as written, resets the buffer pointers
FlushResetBuf       lda       6,u
                    ora       #$01
                    sta       6,u
                    ldd       2,u
                    std       ,u
                    addd      11,u
                    std       4,u
                    clra
                    clrb
* FlushBufRet: shared FlushBuffer exit: FlushError bra here with -1, FlushResetBuf falls in with 0
FlushBufRet         leas      4,s
                    puls      u,pc
* getc: (fp) returns the next buffered byte or refills with FillBuf; -1 on EOF/error/unreadable stream
getc                pshs      u
                    ldu       4,s
                    beq       GetCFail
                    lda       6,u
                    anda      #$01
                    bne       GetCFail
                    ldx       ,u
                    cmpx      4,u
                    bhs       FillBuf
* GetCReturn: returns the byte at the read pointer and advances it
GetCReturn          ldb       ,x+
                    stx       ,u
                    clra
                    puls      u,pc
                    fcb       $34,$40,$EE
                    fcs       /f'@f/
                    fcb       $47,$C4,$01,$27,$3A,$EC,$64,$10
                    fcb       $83,$FF,$FF,$27,$32,$AE,$C4,$AC
                    fcs       /B',g/
                    fcb       $82,$20,$DD,$34,$40,$EE,$64,$34
                    fcb       $C0,$8D,$C1,$ED,$62,$10,$83,$FF
                    fcb       $FF,$27,$0A,$8D,$B7,$10,$83,$FF
                    fcb       $FF,$27,$02,$A6
                    fcs       /c2d5@/
* GetCSetEof: sets flag $10 (EOF)
GetCSetEof          ldb       #$10
                    bra       GetCSetFlag
* GetCSetErr: sets flag $20 (error)
GetCSetErr          ldb       #$20
* GetCSetFlag: ORs B into the FILE flags 7,u for GetCSetEof/GetCSetErr, then falls into GetCFail
GetCSetFlag         orb       7,u
                    stb       7,u
* GetCFail: returns -1
GetCFail            ldd       #$FFFF
                    puls      u,pc
* FillBuf: _filbuf: checks the stream is readable, allocates its buffer, flushes stdout before reading stdin in line mode, reads a block (readln in line mode, read otherwise) or one byte unbuffered
FillBuf             ldd       6,u
                    anda      #$80
                    andb      #$31
                    cmpb      #$01
                    bne       GetCFail
                    cmpa      #$80
                    beq       FillFlushOut
                    pshs      u
                    lbsr      AllocFileBuf
                    leas      2,s
* FillFlushOut: stdin with flag $40: fflush(stdout) first
FillFlushOut        leax      >FrStdin,y
                    pshs      x
                    cmpu      ,s++
                    bne       FillReadBlk
                    ldb       7,u
                    andb      #$40
                    beq       FillReadBlk
                    leax      >FrStdout,y
                    pshs      x
                    lbsr      fflush
                    leas      2,s
* FillReadBlk: read a full buffer with I$ReadLn or I$Read
FillReadBlk         ldb       7,u
                    andb      #$08
                    beq       FillUnbuffered
                    ldd       M$IDSize+2,u
                    pshs      a,b
                    ldx       2,u
                    ldd       8,u
                    pshs      a,b,x
                    ldb       7,u
                    andb      #$40
                    beq       FillReadPath
                    lbsr      readln
                    bra       FillCheckCount
* FillUnbuffered: read one byte into the FILE's own byte slot
FillUnbuffered      ldd       #$0001
                    pshs      a,b
                    leax      10,u
                    stx       2,u
                    ldd       8,u
                    pshs      a,b,x
* FillReadPath: plain I$Read call of FillBuf: FillReadBlk beq here for non-line mode, FillUnbuffered falls in
FillReadPath        lbsr      read
* FillCheckCount: 0 bytes -> EOF flag, negative -> error flag, else set the end pointer and return the first byte
FillCheckCount      leas      6,s
                    std       -2,s
                    lbeq      GetCSetEof
                    lbmi      GetCSetErr
                    ldx       2,u
                    leax      d,x
                    stx       4,u
                    ldx       2,u
                    lbra      GetCReturn
                    fcb       $39
* LongToStr: (conv, long) converts a 32-bit value to decimal (d), octal (o) or hex (x/X) text in the buffer at $3A68 for %l
LongToStr           pshs      u
                    leau      >$3A68,y
                    pshs      u
                    ldb       7,s
                    cmpb      #$64
                    beq       LongDecimal
                    cmpb      #$6F
                    beq       LongOctal
                    cmpb      #$78
                    beq       LongHex
                    cmpb      #$58
                    beq       LongHex
                    lda       #$6C
                    std       ,u++
* LongToStrDone: LongToStr exit: NUL-terminates the buffer and returns; LongDecDone lbra here
LongToStrDone       clr       ,u
                    puls      a,b,u,pc
* LongOctal: octal conversion of the 32-bit value
LongOctal           leax      8,s
a54@                ldb       3,x
                    andb      #$07
                    addb      #$30
                    stb       ,u+
                    ldb       #$03
                    bsr       Shift32Right
                    bne       a54@
                    bra       LongRadixDone
* Shift32Right: shifts the 32-bit value at X right by B bits and returns Z set when it became zero
Shift32Right        lsr       ,x
                    ror       1,x
                    ror       2,x
                    ror       3,x
                    decb
                    bne       Shift32Right
                    lda       ,x
                    ora       1,x
                    ora       2,x
                    ora       3,x
                    rts
* LongHex: hex conversion of the 32-bit value
LongHex             andb      #$20
                    pshs      b
                    leax      9,s
a55@                ldb       3,x
                    andb      #$0F
                    pshs      b
                    lda       #$30
                    cmpb      #$09
                    ble       b55@
                    lda       #$37
                    adda      1,s
b55@                adda      ,s+
                    sta       ,u+
                    ldb       #$04
                    bsr       Shift32Right
                    bne       a55@
                    leas      1,s
* LongRadixDone: tail of LongHex/LongOctal: NUL-terminates and StrReverses; LongOctal bra here, LongHex falls in
LongRadixDone       ldx       ,s
                    clr       ,u
                    lbsr      StrReverse
                    puls      a,b,u,pc
* LongDecimal: signed decimal conversion using the power table FrPow10L (1000000000..10); -2147483648 is special-cased
LongDecimal         ldb       8,s
                    bpl       LongDecDigits
                    ldd       #$0000
                    subd      10,s
                    std       10,s
                    ldd       #$0000
                    sbcb      9,s
                    sbca      8,s
                    std       8,s
                    cmpd      #$8000
                    bne       b56@
                    ldd       2,x
                    bne       b56@
                    leax      >strMinLong,pcr
a56@                lda       ,x+
                    sta       ,u+
                    bne       a56@
* LongDecDone: bridge to LongToStrDone: the strMinLong copy falls in and the digit loop end bra here
LongDecDone         bra      LongToStrDone
b56@                ldb       #$2D
                    stb       ,u+
* LongDecDigits: digit generation loop start of LongDecimal
LongDecDigits       leax      >FrPow10L,y
                    clra
                    ldb       #$0A
                    pshs      a
                    pshs      a,b
                    bra       LongDecNextPow
* LongDecDigitInc: counts one 32-bit subtraction in LongDecLoop; the loop bhs here while no borrow occurred
LongDecDigitInc     inc       ,s
* LongDecLoop: 32-bit repeated-subtraction digit loop
LongDecLoop         ldd       13,s
                    subd      2,x
                    std       13,s
                    ldd       11,s
                    sbcb      1,x
                    sbca      ,x
                    std       11,s
                    bhs       LongDecDigitInc
                    ldd       13,s
                    addd      2,x
                    std       13,s
                    ldd       11,s
                    adcb      1,x
                    adca      ,x
                    std       11,s
                    ldb       ,s
                    tst       2,s
                    bne       a57@
                    tstb
                    beq       b57@
                    inc       2,s
a57@                addb      #$30
                    stb       ,u+
b57@                leax      4,x
                    clr       ,s
* LongDecNextPow: power-table counter of LongDecimal: dec 1,s and loops to LongDecLoop; LongDecDigits bra here
LongDecNextPow      dec       1,s
                    bne       LongDecLoop
                    ldb       14,s
                    addb      #$30
                    stb       ,u+
                    leas      3,s
                    bra       LongDecDone
* strMinLong: '-2147483648' emitted for the most negative long
strMinLong          fcc       /-2147483648/
                    fcb       $00
* AllocFileBuf: (fp) first use of a stream: GetStatus SS.Opt to pick line mode ($40, SCF device) or block mode ($80), sbrk a buffer of the FILE's size (default 256) or fall back to the 1-byte slot
AllocFileBuf        pshs      u
                    ldu       4,s
                    ldb       7,u
                    bitb      #$C0
                    bne       b58@
                    leas      <-$20,s
                    leax      ,s
                    ldd       8,u
                    pshs      a,b,x
                    clra
                    clrb
                    pshs      a,b
                    lbsr      GetStatus
                    ldb       #$40
                    lda       6,s
                    beq       a58@
                    ldb       #$80
a58@                leas      <$26,s
                    orb       7,u
                    stb       7,u
b58@                lda       6,u
                    ora       #$80
                    sta       6,u
                    andb      #$0C
                    bne       AllocFileBufDone
                    ldd       M$IDSize+2,u
                    bne       c58@
                    ldd       #$0100
                    std       11,u
c58@                ldd       2,u
                    bne       d58@
                    ldd       M$IDSize+2,u
                    pshs      a,b
                    lbsr      sbrk
                    leas      2,s
                    std       2,u
                    cmpd      #$FFFF
                    beq       UseTinyBuf
d58@                ldb       #$08
                    bra       AllocFileBufSetPtrs
* UseTinyBuf: no heap: use the FILE's own 1-byte buffer (flag $04)
UseTinyBuf          leax      10,u
                    stx       2,u
                    ldd       #$0001
                    std       11,u
                    ldb       #$04
* AllocFileBufSetPtrs: ORs buffer flag B ($08 heap / $04 tiny) into 7,u and sets ,u/4,u to the buffer end
AllocFileBufSetPtrs orb       7,u
                    stb       7,u
                    ldd       2,u
                    addd      11,u
                    std       4,u
                    std       ,u
* AllocFileBufDone: AllocFileBuf exit; taken directly when 7,u already shows a buffer ($08/$04)
AllocFileBufDone    puls      u,pc
* strlen: (str) length of a NUL-terminated string
strlen              ldx       2,s
* StrLenLoop: scan loop of strlen
StrLenLoop          ldb       ,x+
                    bne       StrLenLoop
                    leax      -1,x
                    tfr       x,d
                    subd      2,s
                    rts
* strAbba: 'abba' module name probed with F$NMLink by sleep to guess the tick rate on systems without F$TPS
strAbba             fcs       /abba/
* sleep: (n) sleeps n seconds: ticks/s from F$TPS, else 10 (F$SUser fails), 100 (F$NMLink 'abba' E$UnkSvc) or 60; times n, tsleep; n=0 sleeps one tick
sleep           ldd       2,s
                    bne       GetTickRate
                    ldd       #$0001
                    bra       DoSleep
* GetTickRate: F$TPS or the fallback probes
GetTickRate         pshs      a,b
                    os9       F$TPS
                    bhs       ScaleTicksBySecs
                    clra
                    os9       F$ID
                    os9       F$SUser
                    bhs       ProbeAbba
                    ldd       #$000A
                    bra       ScaleTicksBySecs
* ProbeAbba: F$NMLink 'abba': E$UnkSvc ($D0) -> 100 ticks/s, anything else -> 60
ProbeAbba           leax      <strAbba,pcr
                    clra
                    os9       F$NMLink
                    bhs       a59@
                    cmpb      #$D0
                    bne       a59@
                    ldd       #$0064
                    bra       ScaleTicksBySecs
a59@                ldd       #$003C
* ScaleTicksBySecs: GetTickRate join: F$TPS/10/100/60 all arrive here to Mul16 ticks-per-sec by the seconds arg
ScaleTicksBySecs    lbsr      Mul16
* DoSleep: tsleep with the computed tick count
DoSleep             pshs      a,b
                    lbsr      tsleep
                    puls      x,pc
* FtoaStub: floating-point conversion stub: returns a pointer to the empty string strEmpty
FtoaStub            leax      >strEmpty,pcr
                    tfr       x,d
                    rts
* strEmpty: single NUL returned by FtoaStub
strEmpty            fcb       $00
* ClearLongRes: zeroes the 32-bit result cell at data $000E used by lseek/ftell
ClearLongRes        leax      >$000E,y
                    clra
                    clrb
                    std       ,x
                    std       2,x
                    rts
L6A23               ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      >$000E,y
                    clr       ,x
                    clr       1,x
                    lda       9,s
                    ldb       3,s
                    mul
                    std       2,x
                    lda       9,s
                    ldb       2,s
                    mul
                    addd      1,x
                    std       1,x
                    bhs       L6A23_1
                    inc       ,x
L6A23_1               lda       8,s
                    ldb       3,s
                    mul
                    addd      1,x
                    std       1,x
                    bhs       L6A23_2
                    inc       ,x
L6A23_2               lda       9,s
                    ldb       1,s
                    mul
                    addd      ,x
                    std       ,x
                    lda       8,s
                    ldb       2,s
                    mul
                    addd      ,x
                    std       ,x
                    lda       7,s
                    ldb       3,s
                    mul
                    addd      ,x
                    std       ,x
                    lda       9,s
                    ldb       ,s
                    mul
                    addb      ,x
                    stb       ,x
                    lda       8,s
                    ldb       1,s
                    mul
                    addb      ,x
                    stb       ,x
                    lda       7,s
                    ldb       2,s
                    mul
                    addb      ,x
                    stb       ,x
                    lda       6,s
                    ldb       3,s
                    mul
                    addb      ,x
                    stb       ,x
                    leas      4,s
                    lbra      L6B9A_1
L6A98               bsr       L6ADE
                    lda       1,s
                    beq       L6A98_1
                    lbsr      L6B6A
L6A98_1               leas      8,s
                    lbra      L6B9A_1
                    fcb       $A6,$84,$AA,$01,$AA
                    fcb       $02,$AA,$03,$26,$0F,$EC,$84,$DD
                    fcb       $0E,$EC,$02,$30,$A9,$00,$0E,$ED
                    fcb       $02,$16,$00,$E6,$A6,$62,$A7,$A9
                    fcb       $3A,$7C,$8D,$2D,$EC,$6A,$30,$A9
                    fcb       $00,$0E,$ED,$84,$EC,$6C,$ED,$02
                    fcb       $6D,$A9
                    fcs       /:|+E/
                    fcb       $32,$68,$16,$00,$C7
L6ADE               lda       ,x
                    ora       1,x
                    ora       2,x
                    ora       3,x
                    bne       L6ADE_1
                    ldd       2,s
                    std       6,s
                    leas      6,s
                    ldd       #$002D
                    lbra      SendSelfSignal
L6ADE_1               ldd       ,x
                    ldx       2,x
                    pshs      a,b,x
                    ldd       #$0000
                    pshs      a,b
                    std       <FrData_reserved_000E
                    std       <FrData_reserved_0010
                    tst       2,s
                    bpl       L6ADE_2
                    leax      2,s
                    bsr      L6B6A
                    com       1,s
L6ADE_2               tst       10,s
                    bpl       L6ADE_3
                    leax      10,s
                    bsr      L6B6A
                    com       1,s
L6ADE_3               leax      >$000E,y
                    lda       #$01
L6ADE_4               inca
                    asl       5,s
                    rol       4,s
                    rol       3,s
                    rol       2,s
                    bpl       L6ADE_4
                    sta       ,s
L6ADE_5               ldd       12,s
                    subd      4,s
                    std       12,s
                    ldd       10,s
                    sbcb      3,s
                    sbca      2,s
                    std       10,s
                    bhs       L6ADE_6
                    ldd       12,s
                    addd      4,s
                    std       12,s
                    ldd       10,s
                    adcb      3,s
                    adca      2,s
                    std       10,s
                    andcc     #$FE
                    bra       L6ADE_7
L6ADE_6               orcc      #$01
L6ADE_7               rol       3,x
                    rol       2,x
                    rol       1,x
                    rol       ,x
                    lsr       2,s
                    ror       3,s
                    ror       4,s
                    ror       5,s
                    dec       ,s
                    bne       L6ADE_5
                    jmp       [<$06,s]
                    fcb       $17,$00,$4A
L6B6A               ldd       #$0000
                    subd      2,x
                    std       2,x
                    ldd       #$0000
                    sbcb      1,x
                    sbca      ,x
                    std       ,x
                    rts
                    fcb       $EC,$84,$43,$53,$DD,$0E,$EC
                    fcb       $02
                    fcs       /CS0)/
                    fcb       $00,$0E,$ED,$02,$39,$30,$A9,$00
                    fcb       $0E,$ED,$02,$1F,$89,$1D,$1F,$89
                    fcb       $ED,$84,$39
L6B9A               leax      >$000E,y
                    std       2,x
                    clr       ,x
                    clr       1,x
                    rts
L6B9A_1               tfr       cc,a
                    puls      x
                    stx       2,s
                    leas      2,s
                    leax      >$000E,y
                    tfr       a,cc
                    rts
                    fcb       $EC,$84,$DD
                    fcb       $0E,$EC,$02,$30,$A9,$00,$0E,$ED
                    fcb       $02,$39
* Mul16: D * (word on stack): 8x8 fast path, else the full 16x16 product; returns low word in D, high word in X, pops the operand
Mul16               tsta
                    bne       Mul16Long
                    tst       2,s
                    bne       Mul16Long
                    lda       3,s
                    mul
                    ldx       ,s
                    stx       2,s
                    ldx       #$0000
                    std       ,s
                    puls      a,b,pc
* Mul16Long: four-partial-product 16x16 multiply
Mul16Long           pshs      a,b
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
                    bhs       a60@
                    inc       ,s
a60@                lda       4,s
                    ldb       9,s
                    mul
                    addd      1,s
                    std       1,s
                    bhs       b60@
                    inc       ,s
b60@                lda       4,s
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
                    fcb       $83,$00,$00,$27,$08,$34,$06,$6F
                    fcb       $E2,$6F,$E2,$20,$2C
* DivByZero: divide by zero: SendSelfSignal with code $2D
DivByZero           puls      a,b
                    std       ,s
                    ldd       #$002D
                    lbra      SendSelfSignal
* Div16: signed 16-bit divide (word on stack / D): quotient in D, remainder in X, pops the operand; D = 0 raises DivByZero
Div16               subd      #$0000
                    beq       DivByZero
                    pshs      a,b
                    clr       ,-s
                    clr       ,-s
                    tsta
                    bpl       a61@
                    nega
                    negb
                    sbca      #$00
                    com       1,s
                    std       2,s
a61@                ldd       6,s
                    bpl       b61@
                    nega
                    negb
                    sbca      #$00
                    com       1,s
                    std       6,s
b61@                lda       #$01
* DivNormLoop: normalizes the divisor, counting shifts
DivNormLoop         inca
                    asl       3,s
                    rol       2,s
                    bpl       DivNormLoop
                    sta       ,s
                    ldd       6,s
                    clr       6,s
                    clr       7,s
* DivLoop: shift-subtract division loop
DivLoop             subd      2,s
                    bhs       a62@
                    addd      2,s
                    andcc     #$FE
                    bra       b62@
a62@                orcc      #$01
b62@                rol       7,s
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
* DivResult: applies the sign and returns quotient/remainder
DivResult           ldx       4,s
                    ldd       6,s
                    std       4,s
                    stx       6,s
                    ldx       2,s
                    ldd       4,s
                    leas      6,s
                    rts
* Asr16: arithmetic right shift of the word on the stack by B (byte moves for counts >= 8); result in D, operand popped
Asr16               tstb
                    beq       ShiftReturn
                    cmpb      #$08
                    blo       AsrLoop
                    lda       2,s
                    sta       3,s
                    clra
                    tst       3,s
                    bpl       a63@
                    deca
a63@                sta       2,s
                    subb      #$08
                    beq       ShiftReturn
* AsrLoop: bit-by-bit asr/ror loop
AsrLoop             asr       2,s
                    ror       3,s
                    decb
                    bne       AsrLoop
                    bra       ShiftReturn
* Lsr16: unsigned right shift of the word on the stack by B; result in D, operand popped
Lsr16               tstb
                    beq       ShiftReturn
                    cmpb      #$08
                    blo       Lsr16_1
                    lda       2,s
                    sta       3,s
                    clr       2,s
                    subb      #$08
                    beq       ShiftReturn
Lsr16_1               lsr       2,s
                    ror       3,s
                    decb
                    bne       Lsr16_1
                    bra       ShiftReturn
* Lsl16: left shift of the word on the stack by B; result in D, operand popped
Lsl16               tstb
                    beq       ShiftReturn
                    cmpb      #$08
                    blo       Lsl16_1
                    lda       3,s
                    sta       2,s
                    clr       3,s
                    subb      #$08
                    beq       ShiftReturn
Lsl16_1               asl       3,s
                    rol       2,s
                    decb
                    bne       Lsl16_1
* ShiftReturn: pops the shifted value into D and returns to the caller; Lsl16 falls in, Asr16/Lsr16 branch here
ShiftReturn         puls      a,b,x
                    exg       d,x
                    tfr       x,pc
* SendSelfSignal: errno <$1A = D, then F$ID / F$Send the signal in B to this process
SendSelfSignal      std       <FrData_reserved_001A
                    pshs      b,y
                    os9       F$ID
                    puls      b,y
                    os9       F$Send
                    rts
* GetStatus: (code, path, ptr, y) I$GetStt wrapper dispatching on the code: SS.Opt buffer, SS.Ready/SS.EOF plain, SS.Size/SS.Pos store X:U through ptr, $0E/$0F pass X (and Y), others E$UnkSvc
GetStatus           pshs      y,u
                    lda       9,s
                    ldb       7,s
                    beq       GetStatPassX
                    cmpb      #$01
                    beq       GetStatPlain
                    cmpb      #$02
                    beq       GetStatSizePos
                    cmpb      #$05
                    beq       GetStatSizePos
                    cmpb      #$06
                    beq       GetStatPlain
                    cmpb      #$0E
                    beq       GetStatPassX
                    cmpb      #$0F
                    beq       GetStatPassY
                    ldb       #$D0
                    bra       GetStatErr
* GetStatSizePos: SS.Size/SS.Pos: stores the 32-bit result through the pointer
GetStatSizePos      os9       I$GetStt
                    bhs       GetStatStoreLong
* GetStatErr: error exit via ErrReturn
GetStatErr          puls      y,u
                    lbra      ErrReturn
* GetStatStoreLong: GetStatus SS.Size/SS.Pos success: stores X:U 32-bit result through the caller's ptr, returns 0
GetStatStoreLong    stx       [<$0A,s]
                    ldx       10,s
                    stu       2,x
                    clrb
                    clra
                    puls      y,u,pc
* GetStatPassY: GetStatus arm for code $0F: also loads caller's Y (12,s) before falling into GetStatPassX
GetStatPassY        ldy       12,s
* GetStatPassX: GetStatus arm for codes $00/$0E (and $0F): puts caller's ptr in X, then plain I$GetStt
GetStatPassX        ldx       10,s
* GetStatPlain: plain I$GetStt returning 0 or errno
GetStatPlain        os9       I$GetStt
                    puls      y,u
                    lbra      RetOkOrErr
                    pshs      y,u
                    lda       9,s
                    ldb       7,s
                    beq       GetStatus_3
                    cmpb      #$02
                    beq       GetStatus_2
                    cmpb      #$03
                    beq       GetStatus_3
                    cmpb      #$04
                    beq       GetStatus_1
                    cmpb      #$0A
                    beq       GetStatus_5
                    cmpb      #$0B
                    beq       GetStatus_3
                    cmpb      #$0C
                    beq       GetStatus_5
                    cmpb      #$0D
                    beq       GetStatus_4
                    cmpb      #$0F
                    beq       GetStatus_3
                    cmpb      #$10
                    beq       GetStatus_3
                    cmpb      #$11
                    beq       GetStatus_2
                    cmpb      #$14
                    beq       GetStatus_1
                    cmpb      #$15
                    beq       GetStatus_1
                    cmpb      #$19
                    beq       GetStatus_1
                    cmpb      #$1A
                    beq       GetStatus_3
                    cmpb      #$1B
                    beq       GetStatus_5
                    ldb       #$D0
                    puls      y,u
                    lbra      ErrReturn
GetStatus_1               ldy       14,s
GetStatus_2               ldu       12,s
GetStatus_3               ldx       10,s
                    bra       GetStatus_5
GetStatus_4               tfr       a,b
                    lda       11,s
                    ldx       12,s
                    ldy       14,s
                    ldu       <$10,s
GetStatus_5               os9       I$SetStt
                    puls      y,u
                    lbra      RetOkOrErr
* CreateOrTruncate: (path, mode) I$Create; if the file exists (E$CEF) and is not a directory, I$Open it and truncate (SS.Size 0)
CreateOrTruncate               ldx       2,s
                    lda       5,s
                    tfr       a,b
                    andb      #$24
                    orb       #$0B
                    os9       I$Create
                    bhs       CreateOrTruncate_2
                    cmpb      #$DA
                    bne       CreateOrTruncate_1
                    lda       5,s
                    bita      #$80
                    bne       CreateOrTruncate_1
                    anda      #$07
                    ldx       2,s
                    os9       I$Open
                    blo       CreateOrTruncate_1
                    pshs      a,u
                    ldx       #$0000
                    leau      ,x
                    ldb       #$02
                    os9       I$SetStt
                    puls      a,u
                    bhs       CreateOrTruncate_2
                    pshs      b
                    os9       I$Close
                    puls      b
CreateOrTruncate_1               lbra      ErrReturn
                    fcb       $AE,$62,$A6,$65,$E6,$67,$10
                    fcb       $3F,$83,$25,$F2,$20,$14,$C1,$DA
                    fcb       $26,$EC,$10,$3F,$87,$25,$E7,$AE
                    fcb       $62,$A6,$65,$E6,$67,$10,$3F,$83
                    fcb       $25,$EC
CreateOrTruncate_2               tfr       a,b
                    clra
                    rts
* open: (path, mode) I$Open; returns the path number or -1 with errno
open            ldx       2,s
                    lda       5,s
                    os9       I$Open
                    lblo      ErrReturn
                    tfr       a,b
                    clra
                    rts
* close: (path) I$Close
close           lda       3,s
                    os9       I$Close
                    lbra      RetOkOrErr
* read: (path, buf, n) I$Read; returns the count, 0 at E$EOF, -1 on error
read            pshs      y
                    ldx       6,s
                    lda       5,s
                    ldy       8,s
                    pshs      y
                    os9       I$Read
* ReadDone: shared read/readln result handling (E$EOF -> 0)
ReadDone            bhs       b64@
                    cmpb      #$D3
                    bne       a64@
                    clra
                    clrb
                    puls      x,y,pc
a64@                puls      x,y
                    lbra      ErrReturn
b64@                tfr       y,d
                    puls      x,y,pc
* readln: (path, buf, n) I$ReadLn with the read result handling
readln          pshs      y
                    lda       5,s
                    ldx       6,s
                    ldy       8,s
                    pshs      y
                    os9       I$ReadLn
                    bra       ReadDone
* write: (path, buf, n) I$Write; returns the count or -1
write           pshs      y
                    ldy       8,s
                    beq       WriteRetCount
                    lda       5,s
                    ldx       6,s
                    os9       I$Write
* WriteDone: Shared write result handler: write falls in, writeln branches here; error -> ErrReturn
WriteDone           bhs       WriteRetCount
                    puls      y
                    lbra      ErrReturn
* WriteRetCount: Write success/zero-length return: count from Y into D; both write calls beq here when n=0
WriteRetCount       tfr       y,d
                    puls      y,pc
* writeln: (path, buf, n) I$WritLn; returns the count or -1
writeln          pshs      y
                    ldy       8,s
                    beq       WriteRetCount
                    lda       5,s
                    ldx       6,s
                    os9       I$WritLn
                    bra       WriteDone
* lseek: (path, offset.hi, offset.lo, whence) whence 1 adds SS.Pos, 2 adds SS.Size, other than 0 is E$Seek; I$Seek, returns X -> the 32-bit position at $000E
lseek           pshs      u
                    ldd       10,s
                    bne       a65@
                    ldu       #$0000
                    ldx       #$0000
                    bra       LSeekDo
a65@                cmpd      #$0001
                    beq       LSeekFromCur
                    cmpd      #$0002
                    beq       LSeekFromEnd
                    ldb       #$F7
* LSeekError: errno = B, result cell = -1
LSeekError          clra
                    std       <FrData_reserved_001A
                    ldd       #$FFFF
                    leax      >$000E,y
                    std       ,x
                    std       2,x
                    puls      u,pc
* LSeekFromEnd: lseek whence=2 arm: I$GetStt $02 (SS.Size) for the base, then LSeekDo adds the offset
LSeekFromEnd        lda       5,s
                    ldb       #$02
                    os9       I$GetStt
                    blo       LSeekError
                    bra       LSeekDo
* LSeekFromCur: lseek whence=1 arm: I$GetStt $05 (SS.Pos) for the base, then falls into LSeekDo
LSeekFromCur        lda       5,s
                    ldb       #$05
                    os9       I$GetStt
                    blo       LSeekError
* LSeekDo: adds the offset to the base position and I$Seeks
LSeekDo             tfr       u,d
                    addd      8,s
                    std       <FrData_reserved_0010
                    tfr       d,u
                    tfr       x,d
                    adcb      7,s
                    adca      6,s
                    bmi       LSeekError
                    tfr       d,x
                    std       <FrData_reserved_000E
                    lda       5,s
                    os9       I$Seek
                    blo       LSeekError
                    leax      >$000E,y
                    puls      u,pc
                    fcb       $39,$8E,$00,$00,$5F,$10,$3F,$0A
                    fcb       $16,$01,$0E
                    fcs       /94`./
                    fcb       $66,$10,$AE,$68,$EE,$6A,$10,$3F
                    fcb       $17,$35,$E0,$A6,$63,$E6,$65,$10
                    fcb       $3F,$0F,$10,$25,$00,$F4,$39
* tsleep: (ticks) F$Sleep; returns the remaining ticks or -1
tsleep              ldx       2,s
                    os9       F$Sleep
                    lblo      ErrReturn
                    tfr       x,d
                    rts
* sbrk: (n) bump-allocates n zeroed bytes from the heap pointer <$16 below the stack limit <$18; returns the old pointer or -1
sbrk                ldd       2,s
                    addd      <FrData_reserved_0016
                    blo       SBrkFail
                    cmpd      <FrData_reserved_0018
                    bhs       SBrkFail
                    pshs      a,b
                    ldx       <FrData_reserved_0016
                    clra
* SBrkZeroLoop: zero-fill loop of sbrk
SBrkZeroLoop        cmpx      ,s
                    bhs       a66@
                    sta       ,x+
                    bra       SBrkZeroLoop
a66@                ldd       <FrData_reserved_0016
                    puls      x
                    stx       <FrData_reserved_0016
                    rts
* SBrkFail: returns -1
SBrkFail            ldd       #$FFFF
                    rts
                    fcb       $A6,$63,$E6,$65,$10,$3F,$08,$16
                    fcb       $00,$C1,$4F,$5F,$10,$3F,$04,$10
                    fcb       $25,$00,$B1,$AE,$62,$27,$04,$E7
                    fcb       $01,$6F,$84,$1F,$89,$4F,$39
* setpr: (pid, prio) F$SPrior; main gives itself priority $A0
setpr         lda       3,s
                    ldb       5,s
                    os9       F$SPrior
                    lbra      RetOkOrErr
                    fcb       $33,$E4,$32,$A9,$00,$FF,$AE,$42
                    fcb       $10,$AE,$44,$A6
                    fcs       /IHHHH*/
                    fcb       $4B,$E6,$4D,$EE,$46,$10,$3F,$05
                    fcb       $10,$3F,$06,$34,$60,$AE,$66,$10
                    fcb       $AE,$68,$EE,$6A,$A6,$6D,$AA,$6F
                    fcb       $E6,$E8,$11,$10,$3F,$03,$35,$60
                    fcb       $10,$25,$00,$65,$1F,$89,$4F,$39
* getpid: F$ID, returns the process id in D
getpid              pshs      y
                    os9       F$ID
                    puls      y
                    tfr       a,b
                    clra
                    rts
                    fcb       $34,$20,$10,$3F,$0C,$1F,$20,$35
                    fcb       $A0
                    fcc       /4  /
                    fcb       $0F,$34,$20,$8D,$EF,$ED,$7E,$27
                    fcb       $07,$C6,$D6,$35,$20,$16,$00,$3A
                    fcb       $10,$AE,$64,$10,$3F,$1C,$24,$0C
                    fcb       $C1,$D0,$26,$EF,$1F,$20,$10,$BE
                    fcb       $00,$4B,$ED
                    fcs       /)O_5 /
* intercept: (fn) stores fn at $3A7D and F$Icpt's the IcptTrampoline with U = data area
intercept        pshs      u
                    tfr       y,u
                    ldx       4,s
                    stx       >$3A7D,y
                    leax      >IcptTrampoline,pcr
                    os9       F$Icpt
                    puls      u
                    bra      RetOkOrErr
* IcptTrampoline: the F$Icpt entry: Y = data area, calls the C signal handler [$3A7D] with the signal code, then rti
IcptTrampoline      tfr       u,y
                    clra
                    pshs      a,b
                    jsr       [>$3A7D,y]
                    leas      2,s
                    rti
* ErrReturn: errno <$1A = B, return -1 (shared by every OS-9 wrapper)
ErrReturn           clra
                    std       <FrData_reserved_001A
                    ldd       #$FFFF
                    rts
* RetOkOrErr: carry set -> ErrReturn, else return 0
RetOkOrErr          blo       ErrReturn
                    clra
                    clrb
                    rts
* exit: (code) AtExitStub, CloseAllFiles, then SysExit
exit               bsr      AtExitStub
                    lbsr      CloseAllFiles
* SysExit: (code) F$Exit
SysExit             ldd       2,s
                    os9       F$Exit
* AtExitStub: exit hook: returns everything s9gui took and puts the text screen back. Clears the mapped window,
* F$DelRAMs the key table (1 block), symbol bank (2), rectangle-save arena (8) and drag snapshot (8), restores
* bitmap 0 if double buffering, frees both bitmaps with SS.FScrn. s9 closes the pipe; s9gui sees EOF and exits here.
AtExitStub          pshs      y                   Y = the C static base, keep it
                    ldu       <FrWinP             the two-block window, if something is mapped in it
                    beq       ax1@
                    ldb       #$02
                    os9       F$ClrBlk
                    clra
                    clrb
                    std       <FrWinP
ax1@                ldx       >FrKeyBank          the piano-key table
                    beq       ax2@
                    ldb       #$01
                    os9       F$DelRAM
                    clra
                    clrb
                    std       >FrKeyBank
ax2@                ldx       >FrSym              the symbol bank
                    beq       ax3@
                    ldb       #$02
                    os9       F$DelRAM
                    clra
                    clrb
                    std       >FrSym
ax3@                ldx       >FrSave             the rectangle-save arena
                    beq       ax4@
                    ldb       #$08
                    os9       F$DelRAM
                    clra
                    clrb
                    std       >FrSave
ax4@                ldx       >FrDragSave         dedicated full-canvas drag snapshot
                    beq      dragfree@
                    ldb       #8
                    os9       F$DelRAM
                    clra
                    clrb
                    std       >FrDragSave
dragfree@          tst       >FrBMShown          double buffering: bitmap 0 back on layer 0, its plane on, bitmap 1's off
                    beq       ax5@
                    pshs      y
                    clr       >FrShown
                    lda       >FrBM0Blk
                    lbsr      ShowPage            plane 0 back on bitmap 0
                    lda       #$02
                    ldb       #SS.PScrn
                    ldx       #$0000
                    ldy       #$0000
                    os9       I$SetStt
                    clr       >FrBMShown
                    puls      y
ax5@                lda       #$02
                    ldb       #SS.FScrn
                    ldy       #$0001              free the double-buffer bitmap, including failed setup
                    os9       I$SetStt
                    lda       #$02                path 2 = /term: text screen back
                    ldb       #SS.DScrn
                    ldx       #FX_TXT
                    ldy       #FT_OMIT
                    os9       I$SetStt
                    lda       #$02                and bitmap 0 back to the system
                    ldb       #SS.FScrn
                    ldy       #$0000              bitmap 0
                    os9       I$SetStt
                    puls      y,pc
* tblInitData: initialized data copied by CStart: an 11-byte DP block (<wp = $139E, <alfacurse = 1), then FrImage..FrImageEnd
* at data $B0 (FrImageOrg): the 71-entry {cmd,nargs,handler} command table ending in $D3, pointer tables, records, menu lists,
* number and ctype tables. Pointers are fdb label entries; the relocation lists after FrImageEnd turn them into addresses.
tblInitData         equ       *
                    fcb       $00,$0B,$00,$01,$00,$00,$00,$00
                    fcb       $00,$00,$13,$9E,$01
                    fdb       FrImageEnd-FrImage
FrImage             equ       *
                    fcb       $A0
                    fcb       $05
                    fdb       dnota
                    fcb       $A1,$04
                    fdb       drsta
                    fcb       $83,$01
                    fdb       gtext
                    fcb       $87,$02
                    fdb       pala
                    fcb       $90,$01
                    fdb       claa
                    fcb       $91,$00
                    fdb       cssa
                    fcb       $92,$03
                    fdb       drepa
                    fcb       $93,$01
                    fdb       erbrush
                    fcb       $94,$04
                    fdb       dfrna
                    fcb       $95,$06
                    fdb       scrla
                    fcb       $96,$01
                    fdb       scrma
                    fcb       $97,$00
                    fdb       dmenbar
                    fcb       $98,$00
                    fdb       mainbord
                    fcb       $99,$03
                    fdb       rftba
                    fcb       $9A,$02
                    fdb       scura
                    fcb       $9B,$04
                    fdb       dcura
                    fcb       $9C,$04
                    fdb       drsa
                    fcb       $9D,$00
                    fdb       ersa
                    fcb       $9E,$03
                    fdb       dralstcl
                    fcb       $9F,$03
                    fdb       drsha
                    fcb       $A3,$02
                    fdb       daksa
                    fcb       $A4,$03
                    fdb       datsa
                    fcb       $A5,$03
                    fdb       dxlva
                    fcb       $A6,$03
                    fdb       dinsa
                    fcb       $A2,$03
                    fdb       dmcha
                    fcb       $A7,$03
                    fdb       dglia
                    fcb       $A8,$04
                    fdb       diasa
                    fcb       $A9,$05
                    fdb       arta
                    fcb       $AA,$04
                    fdb       dcrsa
                    fcb       $B1,$03
                    fdb       slaya
                    fcb       $AB,$03
                    fdb       dpeva
                    fcb       $B2,$03
                    fdb       dlaba
                    fcb       $AC,$01
                    fdb       getnbak
                    fcb       $AD,$01
                    fdb       putnbak
                    fcb       $AE,$00
                    fdb       unimp
                    fcb       $B0,$01
                    fdb       gaboa
                    fcb       $B4,$06
                    fdb       hlina
                    fcb       $B5,$05
                    fdb       vlina
                    fcb       $D0,$07
                    fdb       blinea
                    fcb       $D1,$01
                    fdb       bagnla
                    fcb       $D2,$05
                    fdb       L07C5
                    fcb       $B6,$04
                    fdb       boxa
                    fcb       FrDriveLabelCmd,$04
                    fdb       SetDriveLabel
                    fcb       $B8,$04
                    fdb       nboxa
                    fcb       $B9,$04
                    fdb       ctxma               context menu: col y rows width, labels from the pipe
                    fcb       $BC,$05
                    fdb       clra
                    fcb       $88,$03
                    fdb       defsa
                    fcb       $89,$01
                    fdb       udfsa
                    fcb       $8A,$06
                    fdb       defpa
                    fcb       $8B,$01
                    fdb       udfpa
                    fcb       $8C,$01
                    fdb       sksa
                    fcb       $8E,$02
                    fdb       stsa
                    fcb       $C0,$03
                    fdb       phrsa
                    fcb       $C1,$03
                    fdb       dbcda
                    fcb       $C2,$03
                    fdb       dragset             arm/disarm the drag glyph (kind, index, 0)
                    fcb       $C3,$01
                    fdb       patience
                    fcb       $CC,$02
                    fdb       acura
                    fcb       $C4,$02
                    fdb       menua
                    fcb       $C5,$0E             a no-op (s9h draws the piano keys)
                    fdb       keynop
                    fcb       $C6,$06
                    fdb       owsta
                    fcb       $C7,$01
                    fdb       wkillcmd            swallowed once after a toggle row (FrMenu)
                    fcb       $CA,$01             s9 is about to wait for the user: the screen is complete ($CE is the printer)
                    fdb       pollmark
                    fcb       $C9,$02
                    fdb       yesno
                    fcb       FrRenderFocusedPart,$00
                    fdb       RenderFocusedPart
                    fcb       $CB,$04
                    fdb       nboxh               menu hover, shifted right four pixels
                    fcb       $CD,$01
                    fdb       unimp
                    fcb       $CE,$02
                    fdb       dumpa
                    fcb       $BF,$06
                    fdb       prtboss
                    fcb       $BE,$01
                    fdb       squeeze
                    fcb       $BD,$01
                    fdb       drsys
                    fcb       $CF,$01
                    fdb       beepa
                    fcb       $D3,$00,$00,$00
FrRm323             equ       *
                    fdb       L0E55
FrRm322             equ       *
                    fdb       L0E75
FrRm321             equ       *
                    fdb       L0E95
FrRm320             equ       *
                    fdb       L0EB5
FrRm333             equ       *
                    fdb       L0ED5
FrRm332             equ       *
                    fdb       L0EF5
FrRm331             equ       *
                    fdb       L0F15
FrRm330             equ       *
                    fdb       L0F35
FrRm329             equ       *
                    fdb       L0F55
FrRm328             equ       *
                    fdb       L0F76
FrRm327             equ       *
                    fdb       L0F96
FrRm340             equ       *
                    fdb       L0FB6
FrRm339             equ       *
                    fdb       L0FD6
FrRm338             equ       *
                    fdb       L0FF6
FrRm337             equ       *
                    fdb       L1016
FrRm336             equ       *
                    fdb       L1036
FrRm335             equ       *
                    fdb       L1056
FrRm334             equ       *
                    fdb       L1076
FrRm347             equ       *
                    fdb       L1096
FrRm346             equ       *
                    fdb       L10B6
FrRm345             equ       *
                    fdb       L10D6
FrRm344             equ       *
                    fdb       L10F6
FrRm343             equ       *
                    fdb       L1116
FrRm342             equ       *
                    fdb       L1136
                    fcb       $00,$00,$00,$00
FrRd064             equ       *
                    fcb       $11,$14
FrRd063             equ       *
                    fcb       $11,$21
FrRd062             equ       *
                    fcb       $11,$2E
FrRd075             equ       *
                    fcb       $11,$2E
FrRd074             equ       *
                    fcb       $11,$48
FrRd073             equ       *
                    fcb       $11,$3B
                    fcb       $03,$00,$00,$00,$02,$03,$00,$00
                    fcb       $00,$02,$03,$00,$20,$00,$02,$02
FrRd072             equ       *
                    fcb       $11,$BD,$02,$0F,$10,$03
FrRd071             equ       *
                    fcb       $11,$DB
                    fcb       $02,$0F,$10,$02
FrRd070             equ       *
                    fcb       $11,$F9,$02,$0F
                    fcb       $10,$03
FrRd069             equ       *
                    fcb       $12,$17,$02,$0F,$10,$04
FrRd082             equ       *
                    fcb       $12,$35,$02,$0F,$10,$03
FrRd081             equ       *
                    fcb       $12,$53
                    fcb       $02,$0F,$10,$03
FrRd080             equ       *
                    fcb       $12,$71,$02,$0F
                    fcb       $10,$00,$00,$00,$01,$01,$01,$03
FrRd079             equ       *
                    fcb       $0D,$8F,$02,$0B,$1C,$03
FrRd078             equ       *
                    fcb       $0D,$A5
                    fcb       $02,$0B,$1C,$03,$00,$00,$01,$01
                    fcb       $01,$03,$00,$00,$01,$01,$01,$00
                    fcb       $00,$00,$01,$01,$01,$03
FrRd077             equ       *
                    fcb       $0D,$BB
                    fcb       $02,$13,$11,$03
FrRd076             equ       *
                    fcb       $0D,$E1,$02,$13
                    fcb       $11,$03
FrRd089             equ       *
                    fcb       $0E,$07,$02,$13,$11,$03
FrRd088             equ       *
                    fcb       $0E,$2D,$02,$13,$11,$03
FrRd087             equ       *
                    fcb       $10,$90
                    fcb       $03,$05,$16,$03
FrRd086             equ       *
                    fcb       $10,$B1,$03,$0B
                    fcb       $1C,$03
FrRd085             equ       *
                    fcb       $10,$D2,$03,$05,$16,$03
FrRd084             equ       *
                    fcb       $10,$F3,$03,$0B,$1C,$03,$00,$00
                    fcb       $00,$00,$00,$03,$00,$00,$01,$05
                    fcb       $02,$03,$00,$00,$01,$05,$02,$03
                    fcb       $00,$00,$02,$05,$02,$02,$00,$00
                    fcb       $02,$0C,$00,$03,$00,$00,$02,$05
                    fcb       $02,$03
FrRd083             equ       *
                    fcb       $0E,$53,$02,$0F,$0E
FrRd065             equ       *
                    fcb       $0E
                    fcb       $C9
FrRd066             equ       *
                    fcb       $0E,$FF
FrRd067             equ       *
                    fcb       $0F,$35
FrRd068             equ       *
                    fcb       $0F,$6B
FrRd055             equ       *
                    fcb       $0F
                    fcb       $A1
FrRd056             equ       *
                    fcb       $0F,$D7
FrRd057             equ       *
                    fcb       $10,$0D,$00,$00,$FF
                    fcb       $0F,$00,$1F,$0F,$07,$03,$01,$00               data $02D7 (from the $FF above) = $FF,$0F,$00 (hline right masks)
                    fcb       $00,$F0,$FF,$E0,$F0,$F8,$FC,$FE               data $02E0 = $00,$F0,$FF (left masks); the rest unused
                    fcb       $FF
FrRm301             equ       *
                    fdb       L3050
FrRm300             equ       *
                    fdb       L3059
FrRm299             equ       *
                    fdb       L3062
FrRm312             equ       *
                    fdb       L306B
FrRm311             equ       *
                    fdb       L3074
FrRm310             equ       *
                    fdb       L307D
FrRm309             equ       *
                    fdb       L3086
FrRm308             equ       *
                    fdb       L308F
FrRm307             equ       *
                    fdb       L3098
FrRm306             equ       *
                    fdb       L30A4
FrRm319             equ       *
                    fdb       L30B0
FrRm318             equ       *
                    fdb       L30BC
FrRm317             equ       *
                    fdb       L30C8
FrRm316             equ       *
                    fdb       L30D4
FrRm315             equ       *
                    fdb       L30E0
FrRm314             equ       *
                    fdb       L30EC
FrRm313             equ       *
                    fdb       L30F8
FrRm326             equ       *
                    fdb       L3104
FrRm325             equ       *
                    fdb       L3110
FrRm324             equ       *
                    fdb       L311C
                    fcb       $01,$01,$01,$01
FrRd041             equ       *
                    fcb       $0B,$DF,$00,$04
                    fcb       $00,$08
FrRd042             equ       *
                    fcb       $0B,$F1,$03,$03,$04,$04
FrRd043             equ       *
                    fcb       $0C,$03,$03,$04,$03,$03
FrRd044             equ       *
                    fcb       $0C,$15
                    fcb       $03,$04,$05,$01
FrRd045             equ       *
                    fcb       $0C,$27,$03,$04
                    fcb       $04,$03
FrRd046             equ       *
                    fcb       $0C,$39,$03,$03,$04,$04
FrRd047             equ       *
                    fcb       $0C,$4B,$00,$07,$03,$04
FrRd034             equ       *
                    fcb       $0C,$5D
                    fcb       $04,$02,$04,$04
FrRd035             equ       *
                    fcb       $0C,$6F,$03,$01
                    fcb       $06,$08
FrRd036             equ       *
                    fcb       $0C,$81,$01,$01,$04,$04
FrRd058             equ       *
                    fcb       $11,$75,$01,$01,$04,$04
FrRd059             equ       *
                    fcb       $11,$7D
                    fcb       $00,$02,$04,$04
FrRd060             equ       *
                    fcb       $11,$85,$01,$01
                    fcb       $04,$04
FrRd061             equ       *
                    fcb       $11,$8D,$04,$04,$05,$03
FrRd037             equ       *
                    fcb       $0C,$93,$08,$00,$04,$02
FrRd038             equ       *
                    fcb       $0C,$A5
                    fcb       $04,$02,$05,$03
FrRd039             equ       *
                    fcb       $0C,$B7,$03,$04
                    fcb       $06,$07
FrRd040             equ       *
                    fcb       $0C,$C9,$02,$05,$05,$03
FrRd027             equ       *
                    fcb       $0C,$DB,$00,$07,$04,$02
FrRd028             equ       *
                    fcb       $0C,$ED
                    fcb       $04,$04,$07,$07
FrRd029             equ       *
                    fcb       $0C,$FF,$04,$02
                    fcb       $05,$03
FrRd030             equ       *
                    fcb       $0D,$11,$00,$08,$00,$08
FrRd031             equ       *
                    fcb       $0D,$23,$04,$04,$07,$08
FrRd032             equ       *
                    fcb       $0D,$35
                    fcb       $04,$04,$07,$08
FrRd033             equ       *
                    fcb       $0D,$47,$05,$03
                    fcb       $06,$06
FrRd020             equ       *
                    fcb       $0D,$59,$04,$04,$07,$08
FrRd021             equ       *
                    fcb       $0D,$6B,$05,$03,$03,$03
FrRd022             equ       *
                    fcb       $0D,$7D
                    fcb       $0D,$02,$04,$0B,$00,$00,$0D,$02
                    fcb       $04,$0B,$00,$00,$0D,$02,$04,$0B
                    fcb       $00,$00,$0D,$02,$04,$0B,$00,$00
                    fcb       $0D,$0D,$07,$08
FrRd048             equ       *
                    fcb       $0E,$C9,$0D,$0D
                    fcb       $07,$08
FrRd049             equ       *
                    fcb       $0E,$FF,$0D,$0D,$07,$08
FrRd050             equ       *
                    fcb       $0F,$35,$0D,$0D,$07,$08
FrRd051             equ       *
                    fcb       $0F,$6B
                    fcb       $0D,$0D,$07,$08
FrRd052             equ       *
                    fcb       $0F,$A1,$0D,$0D
                    fcb       $07,$08
FrRd053             equ       *
                    fcb       $0F,$D7,$0D,$0D,$07,$08
FrRd054             equ       *
                    fcb       $10,$0D
FrBarLabsIm         equ       *                   barlabs[]: the menu-bar titles
                    fdb       str_barlabs_0
                    fdb       str_barlabs_1
                    fdb       str_barlabs_2
                    fdb       str_barlabs_3
                    fdb       str_barlabs_4
                    fdb       str_barlabs_5
                    fdb       str_barlabs_6
                    fdb       str_barlabs_7
                    fdb       str_barlabs_8
                    fdb       str_barlabs_9
                    fdb       strMenuBlank
FrMenuList0            equ       *
                    fdb       strMenuBlank_3EAB
                    fdb       strMenuBlank_3EAB
                    fdb       strMenuBlank_3EAB
                    fdb       strMenuBlank_3EAB
                    fdb       strMenuBlank_3EAB
                    fdb       strMenuBlank_3EAB
                    fdb       strMenuBlank_3EAB
                    fdb       strMenuBlank_3EAB
                    fdb       strMenuBlank_3EAB
                    fdb       strMenuBlank_3EAB
                    fdb       strMenuBlank_3EAB
FrMenuList21            equ       *
                    fdb       str_kpchelps_0
                    fdb       str_kpchelps_1
                    fdb       strMenuBlank_4027
                    fdb       str_kpchelps_3
                    fdb       str_kpchelps_4
                    fdb       str_kpchelps_5
                    fdb       strMenuBlank_4065
                    fdb       str_kpchelps_7
                    fdb       str_kpchelps_8
                    fdb       str_kpchelps_9
                    fdb       str_kpchelps_10
                    fdb       strMenuBlank_40D2
                    fdb       str_kpchelps_12
                    fdb       str_kpchelps_13
                    fdb       str_kpchelps_14
                    fdb       str_kpchelps_15
                    fdb       str_kpchelps_16
                    fdb       strMenuBlank_4149
                    fdb       str_kpchelps_18
                    fdb       str_kpchelps_19
                    fdb       str_kpchelps_20
                    fdb       str_kpchelps_21
                    fdb       str_kpchelps_22
                    fdb       str_kpchelps_23
                    fdb       strMenuBlank_41F0
FrMenuList22            equ       *
                    fdb       str_kpnhelps_0
                    fdb       str_kpnhelps_1
                    fdb       strMenuBlank_4234
                    fdb       str_kpnhelps_3
                    fdb       str_kpnhelps_4
                    fdb       str_kpnhelps_5
                    fdb       str_kpnhelps_6
                    fdb       str_kpnhelps_7
                    fdb       str_kpnhelps_8
                    fdb       strMenuBlank_42EA
FrMenuList2            equ       *
                    fdb       str_barprs_0
                    fdb       str_barprs_1
                    fdb       str_barprs_2
                    fdb       str_barprs_3
                    fdb       str_barprs_4
                    fdb       str_barprs_5
                    fdb       str_barprs_6
                    fdb       str_barprs_7
                    fdb       str_barprs_8
                    fdb       str_barprs_9
                    fdb       str_barprs_10
                    fdb       str_barprs_11
                    fdb       str_barprs_12
                    fdb       str_barprs_13
                    fdb       str_barprs_14
                    fdb       str_barprs_15
                    fdb       strMenuBlank_448A
FrMenuList3            equ       *
                    fdb       str_exprprs_0
                    fdb       str_exprprs_1
                    fdb       str_exprprs_2
                    fdb       str_exprprs_3
                    fdb       str_exprprs_4
                    fdb       str_exprprs_5
                    fdb       str_exprprs_6
                    fdb       str_exprprs_7
                    fdb       str_exprprs_8
                    fdb       str_exprprs_9
                    fdb       str_exprprs_10
                    fdb       str_exprprs_11
                    fdb       str_exprprs_12
                    fdb       str_exprprs_4_4548
                    fdb       strMenuBlank_4557
FrMenuList5            equ       *
                    fdb       str_midiprs_0
                    fdb       str_midiprs_2
                    fdb       str_midiprs_3
                    fdb       str_midiprs_4
                    fdb       str_midiprs_6
                    fdb       strMidiNeverMind
                    fdb       str_midiprs_7
                    fdb       strMenuBlank_46EE   the list ends here
FrMenuList6            equ       *
                    fdb       strMenuBlank_47EB
                    fdb       str_glayprs_0
                    fdb       str_glayprs_1
                    fdb       str_glayprs_2
                    fdb       str_glayprs_3
                    fdb       str_glayprs_4
                    fdb       str_glayprs_5
                    fdb       str_glayprs_6
                    fdb       str_glayprs_7
                    fdb       str_glayprs_8
                    fdb       strMenuBlank_485E
FrMenuList9            equ       *
                    fdb       str_gotoprs_0
                    fdb       str_gotoprs_1
                    fdb       str_gotoprs_2
                    fdb       str_gotoprs_3
                    fdb       str_gotoprs_4
                    fdb       str_gotoprs_5
                    fdb       str_gotoprs_6
                    fdb       str_gotoprs_7
                    fdb       str_gotoprs_8
                    fdb       str_gotoprs_9
                    fdb       str_gotoprs_10
                    fdb       str_gotoprs_11
                    fdb       str_gotoprs_12
                    fdb       str_gotoprs_13
                    fdb       str_gotoprs_14
                    fdb       str_gotoprs_15
                    fdb       str_gotoprs_16
                    fdb       str_gotoprs_17
                    fdb       str_gotoprs_18
                    fdb       str_gotoprs_19
                    fdb       str_gotoprs_20
                    fdb       str_gotoprs_21
                    fdb       str_gotoprs_22
                    fdb       strMenuBlank_4B34
MenuWindowRecords
FrMenuRecsIm        equ       *
                    fcb       $00,$17,$AA,$20,$14     menu 0
FrRd004             equ       *
                    fdb       FrMenuList0+FrDA
                    fcb       $01,$3D,$B7,$0E,$0C     menu 1
                    fdb       0  a push-button menu: no list
                    fcb       $00,$1E,$A0,$13,$13     menu 2
FrRd002             equ       *
                    fdb       FrMenuList2+FrDA
                    fcb       $00,$1F,$A0,$12,$12     menu 3
FrRd001             equ       *
                    fdb       FrMenuList3+FrDA
                    fcb       $01,$32,$B7,$0C,$0A     menu 4
                    fdb       0  a push-button menu: no list
                    fcb       $00,MenuBarC4+MenuDropX,$B7,$1A,$18     menu 5
FrRd012             equ       *
                    fdb       FrMenuList5+FrDA
                    fcb       $00,MenuBarC3+MenuDropX,MenuDropY,$32,$17     menu 6 (Inst: under the bar)
FrRd011             equ       *
                    fdb       FrMenuList6+FrDA
                    fcb       $01,$00,$00,$00,$00     menu 7
FrRd010             equ       *
                    fdb       FrMenuList6+FrDA
                    fcb       $00,MidiSubCol,MidiSubTop,$1A,$11     menu 8 (MIDI Levels: 4 text rows into the MIDI menu)
FrRd009             equ       *
                    fdb       FrMenuList6+FrDA
                    fcb       $00,MenuBarC6+MenuDropX,MenuDropY,$1E,$19     menu 9 (Goto: under the bar)
FrRd008             equ       *
                    fdb       FrMenuList9+FrDA
                    fcb       $01,$03,$B7,$10,$0E     menu 10
                    fdb       0  a push-button menu: no list
                    fcb       $01,$0F,$B7,$13,$10     menu 11
                    fdb       0  a push-button menu: no list
                    fcb       $01,$00,$00,$00,$00     menu 12
                    fdb       0  a push-button menu: no list
                    fcb       $01,$03,$A0,$12,$0A     menu 13
                    fdb       0  a push-button menu: no list
                    fcb       $01,$0F,$9B,$11,$0B     menu 14
                    fdb       0  a push-button menu: no list
                    fcb       $01,$1F,$BB,$0F,$10     menu 15
                    fdb       0  a push-button menu: no list
                    fcb       $01,$0F,$A9,$0B,$0A     menu 16
                    fdb       0  a push-button menu: no list
                    fcb       $01,$07,$87,$0B,$09     menu 17
                    fdb       0  a push-button menu: no list
                    fcb       $01,$23,$AA,$0E,$0C     menu 18
                    fdb       0  a push-button menu: no list
                    fcb       $01,$23,$BE,$08,$10     menu 19
                    fdb       0  a push-button menu: no list
                    fcb       $01,$1C,$AB,$18,$0E     menu 20
                    fdb       0  a push-button menu: no list
                    fcb       $00,$1B,$B5,$1E,$18     menu 21
FrRd024             equ       *
                    fdb       FrMenuList21+FrDA
                    fcb       $00,$16,$8D,$27,$0B     menu 22
FrRd023             equ       *
                    fdb       FrMenuList22+FrDA
FrData_reserved_06F8Im equ       *
FrRm004             equ       *
                    fdb       L6135
FrPow10Im           equ       *
                    fcb       $27,$10,$03,$E8,$00,$64,$00,$0A
FrPow10LIm          equ       *
                    fcb       $3B,$9A,$CA,$00,$05,$F5,$E1,$00
                    fcb       $00,$98,$96,$80,$00,$0F,$42,$40
                    fcb       $00,$01,$86,$A0,$00,$00,$27,$10
                    fcb       $00,$00,$03,$E8,$00,$00,$00,$64
                    fcb       $00,$00,$00,$0A
FrStdinIm           equ       *
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$01,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $02,$00,$01,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$46,$00,$02
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00
FrCtypeIm           equ       *
                    fcb       $01,$01,$01,$01
                    fcb       $01,$01,$01,$01,$01,$11,$11,$11
                    fcb       $11,$11,$01,$01,$01,$01,$01,$01
                    fcb       $01,$01,$01,$01,$01,$01,$01,$01
                    fcb       $01,$01,$01,$01,$30,$20,$20,$20
                    fcb       $20,$20,$20,$20,$20,$20,$A0,$20
                    fcb       $20,$20,$20,$20,$48,$48,$48,$48
                    fcb       $48,$48,$48,$48,$48,$48,$20,$20
                    fcb       $20,$20,$20,$A0,$20,$42,$42,$42
                    fcb       $42,$42,$42,$02,$02,$02,$02,$02
                    fcb       $02,$02,$02,$02,$02,$02,$02,$02
                    fcb       $02,$02,$02,$02,$02,$02,$02,$A0
                    fcb       $20,$A0,$20,$20,$20,$44,$44,$44
                    fcb       $44,$44,$44,$04,$04,$04,$04,$04
                    fcb       $04,$04,$04,$04,$04,$04,$04,$04
                    fcb       $04,$04,$04,$04,$04,$04,$04,$20
                    fcb       $20,$20,$A0,$01
FrImageEnd          equ       *
* The relocation lists (CStart's RelocPointers): a count, then the data address of each pointer word.
* Module-relative pointers first, then data-relative ones.
FrRelocMod          fdb       (FrRelocModEnd-FrRelocMod-2)/2
                    fdb       FrRm004+FrDA
                    fdb       FrRm299+FrDA
                    fdb       FrRm300+FrDA
                    fdb       FrRm301+FrDA
                    fdb       FrRm306+FrDA
                    fdb       FrRm307+FrDA
                    fdb       FrRm308+FrDA
                    fdb       FrRm309+FrDA
                    fdb       FrRm310+FrDA
                    fdb       FrRm311+FrDA
                    fdb       FrRm312+FrDA
                    fdb       FrRm313+FrDA
                    fdb       FrRm314+FrDA
                    fdb       FrRm315+FrDA
                    fdb       FrRm316+FrDA
                    fdb       FrRm317+FrDA
                    fdb       FrRm318+FrDA
                    fdb       FrRm319+FrDA
                    fdb       FrRm320+FrDA
                    fdb       FrRm321+FrDA
                    fdb       FrRm322+FrDA
                    fdb       FrRm323+FrDA
                    fdb       FrRm324+FrDA
                    fdb       FrRm325+FrDA
                    fdb       FrRm326+FrDA
                    fdb       FrRm327+FrDA
                    fdb       FrRm328+FrDA
                    fdb       FrRm329+FrDA
                    fdb       FrRm330+FrDA
                    fdb       FrRm331+FrDA
                    fdb       FrRm332+FrDA
                    fdb       FrRm333+FrDA
                    fdb       FrRm334+FrDA
                    fdb       FrRm335+FrDA
                    fdb       FrRm336+FrDA
                    fdb       FrRm337+FrDA
                    fdb       FrRm338+FrDA
                    fdb       FrRm339+FrDA
                    fdb       FrRm340+FrDA
                    fdb       FrRm342+FrDA
                    fdb       FrRm343+FrDA
                    fdb       FrRm344+FrDA
                    fdb       FrRm345+FrDA
                    fdb       FrRm346+FrDA
                    fdb       FrRm347+FrDA
FrRelocModEnd       equ       *
FrRelocData         fdb       (FrRelocDataEnd-FrRelocData-2)/2
                    fdb       FrRd001+FrDA
                    fdb       FrRd002+FrDA
                    fdb       FrRd004+FrDA
                    fdb       $0008
                    fdb       FrRd008+FrDA
                    fdb       FrRd009+FrDA
                    fdb       FrRd010+FrDA
                    fdb       FrRd011+FrDA
                    fdb       FrRd012+FrDA
                    fdb       FrRd020+FrDA
                    fdb       FrRd021+FrDA
                    fdb       FrRd022+FrDA
                    fdb       FrRd023+FrDA
                    fdb       FrRd024+FrDA
                    fdb       FrRd027+FrDA
                    fdb       FrRd028+FrDA
                    fdb       FrRd029+FrDA
                    fdb       FrRd030+FrDA
                    fdb       FrRd031+FrDA
                    fdb       FrRd032+FrDA
                    fdb       FrRd033+FrDA
                    fdb       FrRd034+FrDA
                    fdb       FrRd035+FrDA
                    fdb       FrRd036+FrDA
                    fdb       FrRd037+FrDA
                    fdb       FrRd038+FrDA
                    fdb       FrRd039+FrDA
                    fdb       FrRd040+FrDA
                    fdb       FrRd041+FrDA
                    fdb       FrRd042+FrDA
                    fdb       FrRd043+FrDA
                    fdb       FrRd044+FrDA
                    fdb       FrRd045+FrDA
                    fdb       FrRd046+FrDA
                    fdb       FrRd047+FrDA
                    fdb       FrRd048+FrDA
                    fdb       FrRd049+FrDA
                    fdb       FrRd050+FrDA
                    fdb       FrRd051+FrDA
                    fdb       FrRd052+FrDA
                    fdb       FrRd053+FrDA
                    fdb       FrRd054+FrDA
                    fdb       FrRd055+FrDA
                    fdb       FrRd056+FrDA
                    fdb       FrRd057+FrDA
                    fdb       FrRd058+FrDA
                    fdb       FrRd059+FrDA
                    fdb       FrRd060+FrDA
                    fdb       FrRd061+FrDA
                    fdb       FrRd062+FrDA
                    fdb       FrRd063+FrDA
                    fdb       FrRd064+FrDA
                    fdb       FrRd065+FrDA
                    fdb       FrRd066+FrDA
                    fdb       FrRd067+FrDA
                    fdb       FrRd068+FrDA
                    fdb       FrRd069+FrDA
                    fdb       FrRd070+FrDA
                    fdb       FrRd071+FrDA
                    fdb       FrRd072+FrDA
                    fdb       FrRd073+FrDA
                    fdb       FrRd074+FrDA
                    fdb       FrRd075+FrDA
                    fdb       FrRd076+FrDA
                    fdb       FrRd077+FrDA
                    fdb       FrRd078+FrDA
                    fdb       FrRd079+FrDA
                    fdb       FrRd080+FrDA
                    fdb       FrRd081+FrDA
                    fdb       FrRd082+FrDA
                    fdb       FrRd083+FrDA
                    fdb       FrRd084+FrDA
                    fdb       FrRd085+FrDA
                    fdb       FrRd086+FrDA
                    fdb       FrRd087+FrDA
                    fdb       FrRd088+FrDA
                    fdb       FrRd089+FrDA
FrRelocDataEnd      equ       *
* Data addresses derived from the image labels: an entry removed or added in the image moves them all.
FrDA                equ       FrImageOrg-FrImage  data address of an image label = label + FrDA
FrMenuRecs          equ       FrMenuRecsIm+FrDA
FrData_reserved_06F8 equ       FrData_reserved_06F8Im+FrDA
FrPow10             equ       FrPow10Im+FrDA
FrPow10L            equ       FrPow10LIm+FrDA
FrStdin             equ       FrStdinIm+FrDA
FrCtype             equ       FrCtypeIm+FrDA
FrDragKind          equ       FrMenuRecs+7
FrDragIdx           equ       FrMenuRecs+8
FrDragCol           equ       FrMenuRecs+9
FrDragY             equ       FrMenuRecs+10
FrMenu              equ       FrMenuRecs+11
FrDragUp            equ       FrMenuRecs+12
FrDragY1            equ       FrMenuRecs+13
FrDynaInk           equ       FrMenuRecs+28
FrBell              equ       FrMenuRecs+29
FrStaffDots         equ       FrMenuRecs+30
FrGetsLeft          equ       FrMenuRecs+31
FrCtxLeft           equ       FrMenuRecs+32
FrStdout            equ       FrStdin+13
FrStderr            equ       FrStdin+26
FrData_reserved_072C equ       FrStdin+6
                    fcb       $46,$72,$61,$6E
                    fcb       $00

                    emod
eom                 equ       *
                    end
