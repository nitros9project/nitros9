********************************************************************
* s9d - Studio-9 file-I/O overlay: load, save, append, kill and change directory
* Ported from UltiMusE III v10.11.4e (OS-9 Level 2) CMDS/Um3D, disassembled to byte-exact lwasm source.
* Port changes: event pages hold 928 events ($03A0), not 1020, so a page fits the $1D00 visible bytes
* of DAT slot 7 (GPBLKS in s9.asm) - EventPtr and the event-page loop carry the constant; the file
* picker runs in s9r (FilePickMenu); drive shortcuts $10-$15; MIDI/Lyra/Musica/Orchestra-90 score
* imports through s9i/s9y/s9f/s9o; MIDI defaults before a score read.
*
* s9's soowee links it by name and calls start (lbra OverlayMain) with (command, name buffer, write
* flag, type char, quick flag, alt flag); it runs on the main program's data area (Y) and reaches
* printf/sprintf/flush/message box/yes-no/pause, the event-page mappers and soowee through the
* function-pointer table at $035D..$03A7.
* OverlayMain maps the type char to an extension (u=.ume score, i=.ins instruments, p=.per
* percussion, l=.lev levels, m=.mid MIDI setup; 'a' = append .ume), runs FilePickMenu, then opens or
* creates the file (OVERWRITE prompt, "Can't create/open" messages) and walks the file format
* section by section with U pointing at ReadPath or WritePath: version+parts word (scorelvl/nparts,
* current version 11), staves nstaves (0..7 else "Odd file, punt!"), header words $03/$05, event
* count nevents, part table $0C5F (4 bytes/part), staff table $0C19 (10 bytes/staff), the events in
* 928-event pages mapped through ppswap with "Outa RAM, Score Cut!" fallback, word $5E, instrument
* patches ($075F) and 16 ten-byte names ($07EB), MIDI config $03F3 (17), levels $0103 (8), the
* ImEvts block at $03E5 (count word, $D0-byte header at +$1000, version 9 list of $03E9-$03E5 bytes,
* version 11 extra 52-byte records at +$10D0), percussion tables $0CA3/$0CB4, byte $0083, word
* $0060, and finally s9e command 'i'; a failed length check ends in "**Disk Full?" or "**Disk Read
* Short; Data bad?".
* AppendScore opens a second .ume, checks part count, clefs and the 'Hollow' percussion flag against
* the current score, appends a type-2 marker event (and a second one, type $0A with the incoming
* $03/$05 words when both are set), reads the incoming events behind the existing ones, shifts their
* times by $93, skips to the version-9 ImEvts list (ESB byte must be 234), appends it and relocates
* the type $1E/$1F references.
* Helpers: EventPtr/NextEvent, SanitizeEvents, ExtForType/HasExtension/AddExtension,
* InitInstrTable, ClearImHeader, the s9gui window codes (WinDefine $C6, WinEnd $C7, WinCtl89/8B)
* printed through printf, and the Microware C runtime tail (string, memcpy, long, mul/div, and
* creat/open/close/read/write/lseek/unlink/chdir wrappers with errno at $034F). Unlabeled fcb
* blocks and the routines marked unreferenced are bytes of the original module that nothing calls
* any more. Local labels aN@/bN@ belong to routine N.

                    nam       s9d
                    ttl       s9d (score and MIDI files)
UME_SCOPE_S9D                  equ       1
                    use       equates.asm

                  IFP1
                    use       defsfile
                  ENDC

tylg                set       $11
atrv                set       $81
size                equ       $104F

                    mod       eom,name,tylg,atrv,start,size
name                fcs       /s9d/
                    fcb       $07
start               equ       *
                    lbra      OverlayMain
                    fcb       $39,$0D,$00
* FilePickMenu(name, ext, a3, a4, a5) -> soowee('R', 'b', name, ext copy, a3, a4, a5): s9r's picker.
* The extension is copied to the stack: s9d code/data is unmapped during the nested overlay.
FilePickMenu        pshs      u
                    leas      -6,s
                    ldx       12,s
                    ldd       ,x
                    std       ,s
                    ldd       2,x
                    std       2,s
                    ldb       4,x
                    stb       4,s
                    ldd       18,s
                    pshs      d
                    ldd       18,s
                    pshs      d
                    ldd       18,s
                    pshs      d
                    leax      6,s
                    pshs      x
                    ldd       18,s
                    pshs      d
                    ldd       #'b
                    pshs      d
                    ldd       #'R
                    pshs      d
                    jsr       [>UmeData_psoowee]
                    leas      20,s
                    puls      u,pc
OverlayMain         pshs      u
                    leas      >-$00BC,s
* Commands $10-$15 (drive shortcuts): s9g 'r' takes the drive root from pDriveMenu, then the
* ordinary Read Score browser runs.
                    ldb       >$00C1,s
                    cmpb      #$10
                    blo       MainNormalCommand
                    cmpb      #$15
                    bhi       MainNormalCommand
                    subb      #$10
                    lda       #3
                    mul
                    ldx       >pDriveMenu
                    lbeq      MainReturnZero
                    leax      64,x
                    ldd       b,x                 configured name for this menu slot
                    lbeq      MainReturnZero
                    leax      <$1E,s
                    std       1,x
                    lda       #'/
                    sta       ,x
                    clr       3,x
                    pshs      x                   root string is on stack, safe across overlays
                    ldd       #'r
                    pshs      d
                    ldd       #'G
                    pshs      d
                    jsr       [>UmeData_psoowee]
                    leas      6,s
                    cmpd      #0
                    lbne      MainReturnZero
                    leax      <$1E,s
                    clr       ,x                  directory consumed: empty name opens Read Score
                    stx       >$00C2,s
                    clr       >$00C5,s
                    lda       #'u
                    sta       >$00C7,s
                    clr       >$00C9,s
                    clr       >$00CB,s
MainNormalCommand   equ       *
                    ldd       #$0001
                    stb       <$11,s
                    clra
                    clrb
                    stb       <$10,s
                    ldb       >$00C7,s
                    cmpb      #$61
                    bne       MainKillFlag
                    ldd       #$0075
                    stb       >$00C7,s
                    ldd       #$0001
                    stb       <$10,s
* kill (15,s) = write && alt
MainKillFlag        ldb       >$00C5,s
                    beq       a8@
                    ldb       >$00CB,s
                    beq       a8@
                    ldd       #$0001
                    bra       MainGetExt
a8@                 clra
                    clrb
* ext = ExtForType(type) -> $18,s; empty extension returns 0; quick && !write -> ChdirLoop
MainGetExt          stb       15,s
                    ldb       >$00C7,s
                    sex
                    pshs      a,b
                    lbsr      ExtForType
                    leas      2,s
                    std       <$18,s
                    tfr       d,x
                    ldb       ,x
                    lbeq      MainReturnZero
                    ldb       >$00C9,s
                    beq      MainSkipChdir
                    ldb       >$00C5,s
                    bne      MainSkipChdir
* CHANGE DIR loop: FilePickMenu(name, ext, alt, 1, 0); empty -> return 0; ChangeDir ok -> return 0; else "Can't CHD" box, clear the name, repeat
ChdirLoop           clra
                    clrb
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldb       >$00CF,s
                    sex
                    pshs      a,b
                    ldd       <$1E,s
                    pshs      a,b
                    ldd       >$00CA,s
                    pshs      a,b
                    lbsr      FilePickMenu
                    leas      10,s
                    ldb       [>$00C2,s]
                    lbeq      MainReturnZero
                    ldd       >$00C2,s
                    pshs      a,b
                    lbsr      ChangeDir
                    std       ,s++
                    lbeq      MainReturnZero
                    ldd       >$00C2,s
                    pshs      a,b
                    leax      >fmtCantChd,pcr
                    pshs      x
                    leax      <$1E,s
                    pshs      x
                    jsr       [>UmeData_psprintf]
                    leas      6,s
                    clra
                    clrb
                    pshs      a,b
                    leax      <$1C,s
                    pshs      x
                    jsr       [>UmeData_palert]
                    leas      4,s
                    clra
                    clrb
                    stb       [>$00C2,s]
                    bra      ChdirLoop
* branch island for MainGetExt's two short branches past ChdirLoop
MainSkipChdir       bra       MainNeedMenu
* write && !quick -> MainShowMenu; else a given name -> MainBuildName, empty -> MainShowMenu
MainNeedMenu        ldb       >$00C5,s
                    beq       a9@
                    ldb       >$00C9,s
                    beq       MainShowMenu
a9@                 ldb       [>$00C2,s]
                    bne       MainBuildName
* FilePickMenu(name, ext, write, 0, kill), a score read offering strScoreExt; empty name -> return 0
MainShowMenu        ldb       15,s
                    sex
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldb       >$00C9,s
                    sex
                    pshs      a,b
                    ldd       <$1E,s
                    tst       >$00CB,s
                    bne       md_ext@
                    ldb       >$00CD,s
                    cmpb      #'u
                    bne       md_oldext@
                    tst       <$16,s
                    bne       md_oldext@
                    leax      strScoreExt,pcr
                    tfr       x,d
                    bra       md_ext@
md_oldext@          ldd       <$1E,s
md_ext@             pshs      d
                    ldd       >$00CA,s
                    pshs      a,b
                    lbsr      FilePickMenu
                    leas      10,s
                    ldb       [>$00C2,s]
                    lbeq      MainReturnZero
* score read (not append): the name needs a score extension (HasExtension, strScoreExt), else beep; others AddExtension(name, ext); append -> return AppendScore(name)
MainBuildName       tst       >$00C5,s
                    bne       md_addext@
                    ldb       >$00C7,s
                    cmpb      #'u
                    bne       md_addext@
                    tst       <$10,s
                    bne       md_addext@
                    leax      strScoreExt,pcr
                    pshs      x
                    ldd       >$00C4,s
                    pshs      d
                    lbsr      HasExtension
                    leas      4,s
                    bne       md_named@
                    jsr       [>UmeData_pbeep]          unsupported/missing score suffix: bonk, no open
                    lbra      MainClearName
md_addext@          ldd       <$18,s
                    pshs      a,b
                    ldd       >$00C4,s
                    pshs      a,b
                    lbsr      AddExtension
                    leas      4,s
md_named@           ldb       <$10,s
                    beq       MainKillFile
                    ldd       >$00C2,s
                    pshs      a,b
                    lbsr      AppendScore
                    leas      2,s
                    lbra      MainExit
* kill: UnlinkFile(name), "Can't delete" box on error; either way clear the name and back to MainNeedMenu
MainKillFile        ldb       15,s
                    beq       MainWriteProbe
                    ldd       >$00C2,s
                    pshs      a,b
                    lbsr      UnlinkFile
                    std       ,s++
                    lbeq      MainClearName
                    ldd       >UmeData_c_errno
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    leax      >msgCantKill,pcr
                    pshs      x
                    jsr       [>UmeData_palert]
                    leas      6,s
                    lbra      MainClearName
* write: U = WritePath; the file exists (OpenPath(name, 1) succeeds): close it and, unless quick, ask "OVERWRITE %s?" (no -> MainClearName)
MainWriteProbe      ldb       >$00C5,s
                    beq      MainOpenFile
                    leau      >WritePath,pcr
                    ldd       #$0001
                    pshs      a,b
                    ldd       >$00C4,s
                    pshs      a,b
                    lbsr      OpenPath
                    leas      4,s
                    std       ,s
                    ble       MainCreateFile
                    ldd       ,s
                    pshs      a,b
                    lbsr      ClosePath
                    leas      2,s
                    ldb       >$00C9,s
                    bne       MainCreateFile
                    ldd       >$00C2,s
                    pshs      a,b
                    leax      >fmtOverwrite,pcr
                    pshs      x
                    leax      <$1E,s
                    pshs      x
                    jsr       [>UmeData_psprintf]
                    leas      6,s
                    leax      <$1A,s
                    pshs      x
                    jsr       [>UmeData_pyesno]
                    leas      2,s
                    lbeq      MainClearName
* fd = CreatePath(name, 3); failure -> "Can't create" box, MainClearName
MainCreateFile      ldd       #$0003
                    pshs      a,b
                    ldd       >$00C4,s
                    pshs      a,b
                    lbsr      CreatePath
                    leas      4,s
                    std       ,s
                    lbgt      ScoreHeader
                    ldd       >$00C2,s
                    pshs      a,b
                    leax      >fmtCantCreate,pcr
                    bra       MainFileErrBox
* read: U = ReadPath; fd = OpenPath(name, 1), failure -> "Can't open"; a score: MIDI defaults, imports by extension, native saves nparts/nstaves in 10,s/8,s and sends WinCtl8B(1), WinCtl89(0)
MainOpenFile        leau      >ReadPath,pcr
                    ldd       #$0001
                    pshs      a,b
                    ldd       >$00C4,s
                    pshs      a,b
                    lbsr      OpenPath
                    leas      4,s
                    std       ,s
                    ble       a10@
                    ldb       >$00C7,s
                    cmpb      #$75
                    bne       ScoreHeader
* A score read (load or import, not append) starts from the MIDI defaults - after the open, so a
* cancelled pick changes nothing.
                    tst       <$10,s              the append flag
                    bne       mof1@
                    lbsr      MidiDefaults9d
mof1@               leax      strScoreExt,pcr
                    pshs      x
                    ldd       >$00C4,s
                    pshs      d
                    lbsr      HasExtension
                    leas      4,s
                    cmpb      #'I
                    lbeq      MidiReadScore
                    cmpb      #'Y
                    lbeq      LyraReadScore
                    cmpb      #'O
                    lbeq      OrcReadScore
                    cmpb      #'F
                    lbeq      MusicaReadScore
                    ldd       <UmeData_nparts
                    std       10,s
                    ldd       <UmeData_nstaves
                    std       8,s
                    ldd       #$0001
                    pshs      a,b
                    lbsr      WinCtl8B
                    leas      2,s
                    clra
                    clrb
                    pshs      a,b
                    lbsr      WinCtl89
                    leas      2,s
                    bra       ScoreHeader
a10@                ldd       >$00C2,s
                    pshs      a,b
                    leax      >fmtCantOpen,pcr
* shared tail: sprintf the format in X, message box, MainClearName
MainFileErrBox      pshs      x
                    leax      <$1E,s
                    pshs      x
                    jsr       [>UmeData_psprintf]
                    leas      6,s
                    clra
                    clrb
                    pshs      a,b
                    leax      <$1C,s
                    pshs      x
                    jsr       [>UmeData_palert]
                    leas      4,s
* name[0] = 0 and back to MainNeedMenu
MainClearName       clra
                    clrb
                    stb       [>$00C2,s]
                    lbra      MainNeedMenu
* type 'u' only (else NonScoreVersion): write puts nparts + $0B00 (version 11) as the first word, then scorelvl = 11 and SanitizeEvents; read -> ScoreReadVersion
ScoreHeader         ldb       >$00C7,s
                    cmpb      #$75
                    lbne      NonScoreVersion
                    ldb       >$00C5,s
                    beq       ScoreReadVersion
                    ldd       <UmeData_nparts
                    addd      #$0B00
                    std       <UmeData_scorelvl
                    ldd       #$0002
                    pshs      a,b
                    ldx       #$0066
                    pshs      x
                    ldd       4,s
                    pshs      a,b
                    lbsr      WritePath
                    leas      6,s
                    ldd       #$000B
                    std       <UmeData_scorelvl
                    lbsr      SanitizeEvents
                    bra      ScoreRwStaves
* read the version word: nparts = low 5 bits, scorelvl = high byte (version)
ScoreReadVersion    ldd       #$0002
                    pshs      a,b
                    ldx       #$0066
                    pshs      x
                    ldd       4,s
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    ldd       <UmeData_scorelvl
                    clra
                    andb      #$1F
                    std       <UmeData_nparts
                    ldb       <UmeData_scorelvl
                    sex
                    std       <UmeData_scorelvl
* The 'Score v%d; reader v%d.' box is skipped (the version shows elsewhere): the code up to
* ScoreVersionOk is unreachable.
                    bra       ScoreVersionOk
                    ldd       <UmeData_scorelvl
                    beq       ScoreVersionOk
                    ldd       <UmeData_scorelvl
                    cmpd      #$000B
                    beq       ScoreVersionOk
                    ldd       #$000B
                    pshs      a,b
                    ldd       <UmeData_scorelvl
                    pshs      a,b
                    leax      >fmtScoreVersion,pcr
                    pshs      x
                    leax      <$20,s
                    pshs      x
                    jsr       [>UmeData_psprintf]
                    leas      8,s
                    clra
                    clrb
                    pshs      a,b
                    leax      <$1C,s
                    pshs      x
                    jsr       [>UmeData_palert]
                    leas      4,s
* keysig = 0; version < 7 -> transp ($60) = 0 (that word is in the file from version 7)
ScoreVersionOk      clra
                    clrb
                    std       <UmeData_keysig
                    ldd       <UmeData_scorelvl
                    cmpd      #$0007
                    bge       ScoreRwStaves
                    clra
                    clrb
                    std       <UmeData_transp
* (*U)(fd, &nstaves, 2); outside 0..7 -> ScoreOddFile
ScoreRwStaves       ldd       #$0002
                    pshs      a,b
                    ldx       #$005A
                    pshs      x
                    ldd       4,s
                    pshs      a,b
                    jsr       ,u
                    leas      6,s
                    ldd       <UmeData_nstaves
                    blt       ScoreOddFile
                    ldd       <UmeData_nstaves
                    cmpd      #$0007
                    ble       ScoreRwTables
* "Odd file, punt!": ClosePath, message box, nparts and nstaves both from the saved part count at 10,s, return 0
ScoreOddFile        ldd       ,s
                    pshs      a,b
                    lbsr      ClosePath
                    leas      2,s
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgOddFile,pcr
                    pshs      x
                    jsr       [>UmeData_palert]
                    leas      4,s
                    ldd       10,s
                    std       <UmeData_nparts
                    ldd       10,s
                    std       <UmeData_nstaves
* D = 0 (cancel / nothing done)
MainReturnZero      clra
                    clrb
* frame exit of OverlayMain
MainExit            leas      >$00BC,s
                    puls      u,pc
* MidiDefaults9d: s9's MidiDefaults for this overlay - parts 1-16 on, channels 1-16 on, every part to
* channel 1 (0). Keeps every register.
MidiDefaults9d      pshs      d,x
                    ldx       #MidiPartOn+1
                    ldd       #$1001              A = 16 entries, B = on
md91@               stb       ,x+
                    deca
                    bne       md91@
                    ldx       #MidiChanOn
                    lda       #16
md92@               stb       ,x+
                    deca
                    bne       md92@
                    ldx       #MidiChanTbl+1
                    lda       #16
md93@               clr       ,x+
                    deca
                    bne       md93@
                    puls      d,x,pc
* rw words $03, $05, nevents, (nparts+1)*4 bytes of the part table $0C5F, nstaves*10 bytes of the staff table $0C19; end of events = LSeek(fd, 0, 1) + nevents*8 -> $14,s
ScoreRwTables       ldd       #$0002
                    pshs      a,b
                    ldx       #$0003
                    pshs      x
                    ldd       4,s
                    pshs      a,b
                    jsr       ,u
                    leas      6,s
                    ldd       #$0002
                    pshs      a,b
                    ldx       #$0005
                    pshs      x
                    ldd       4,s
                    pshs      a,b
                    jsr       ,u
                    leas      6,s
                    ldd       #$0002
                    pshs      a,b
                    ldx       #$0029
                    pshs      x
                    ldd       4,s
                    pshs      a,b
                    jsr       ,u
                    leas      6,s
                    ldd       <UmeData_nparts
                    addd      #$0001
                    aslb
                    rola
                    aslb
                    rola
                    pshs      a,b
                    ldx       #$0C5F
                    pshs      x
                    ldd       4,s
                    pshs      a,b
                    jsr       ,u
                    leas      6,s
                    ldd       <UmeData_nstaves
                    pshs      a,b
                    ldd       #$000A
                    lbsr      MulInt16
                    pshs      a,b
                    ldx       #$0C19
                    pshs      x
                    ldd       4,s
                    pshs      a,b
                    jsr       ,u
                    leas      6,s
                    leax      <$14,s
                    pshs      x
                    ldd       #$0001
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    lbsr      LSeek
                    leas      8,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       <UmeData_nevents
                    lbsr      LongFromInt
                    pshs      x
                    ldd       #$0003
                    lbsr      LongShl
                    lbsr      LongAdd
                    lbsr      LongStore
                    ldd       <UmeData_nevents
                    cmpd      #$7FFF
                    ble       EvBlockInit
                    ldd       #$7FFF
                    pshs      a,b
                    ldd       <UmeData_nevents
                    pshs      a,b
                    leax      >fmtScoreCut,pcr
                    pshs      x
                    leax      <$20,s
                    pshs      x
                    jsr       [>UmeData_psprintf]
                    leas      8,s
                    ldd       #$7FFF
                    std       <UmeData_nevents
                    clra
                    clrb
                    pshs      a,b
                    leax      <$1C,s
                    pshs      x
                    jsr       [>UmeData_palert]
                    leas      4,s
* remaining (2,s) = nevents, page (12,s) = 1
EvBlockInit         ldd       <UmeData_nevents
                    std       2,s
                    ldd       #$0001
                    std       12,s
                    lbra      EvBlockTest
* ppswap(page), page++; failure -> page--, nevents -= remaining, "**Outa RAM, Score Cut!", remap the last good page, ok = 0
EvBlockLoop         ldd       12,s
                    addd      #$0001
                    std       12,s
                    subd      #$0001
                    pshs      a,b
                    jsr       [>UmeData_ppswap]
                    leas      2,s
                    bne       EvBlockChunk
                    ldd       12,s
                    addd      #$FFFF
                    std       12,s
                    ldd       <UmeData_nevents
                    subd      2,s
                    std       <UmeData_nevents
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgOutaRam,pcr
                    pshs      x
                    jsr       [>UmeData_palert]
                    leas      4,s
                    ldd       12,s
                    addd      #$FFFF
                    pshs      a,b
                    jsr       [>UmeData_ppswap]
                    leas      2,s
                    bra       EvBlockFail
* n = min(remaining, 928) events for this page
EvBlockChunk        ldd       2,s
                    cmpd      #$03A0
                    ble       a11@
                    ldd       #$03A0
                    bra       EvBlockRw
a11@                ldd       2,s
* (*U)(fd, database, n*8) / 8 -> 4,s; short count -> EvBlockFail
EvBlockRw           std       6,s
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    pshs      a,b
                    ldd       <UmeData_database
                    pshs      a,b
                    ldd       4,s
                    pshs      a,b
                    jsr       ,u
                    leas      6,s
                    pshs      a,b
                    ldd       #$0008
                    lbsr      DivInt16
                    std       4,s
                    cmpd      6,s
                    beq       EvBlockNext
* ok ($11,s) = 0
EvBlockFail         clra
                    clrb
                    stb       <$11,s
                    bra       EvBlocksDone
* remaining -= n
EvBlockNext         ldd       2,s
                    subd      4,s
                    std       2,s
* loop while remaining > 0
EvBlockTest         ldd       2,s
                    lbgt      EvBlockLoop
* giveback frees the unused pages, SanitizeEvents, LSeek(fd, end of events, 0), nmpages = page-1 (the ldd #$1C94 / beq never branches)
EvBlocksDone        jsr       [>UmeData_pgivebac]
                    lbsr      SanitizeEvents
                    clra
                    clrb
                    pshs      a,b
                    leax      <$16,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    lbsr      LSeek
                    leas      8,s
                    ldb       <$11,s
                    bne       a12@
                    ldd       #$1C94
                    beq       ScoreRw5E
a12@                ldd       12,s
                    addd      #$FFFF
                    std       <UmeData_nmpages
* rw the word secmin ($5E)
ScoreRw5E           ldd       #$0002
                    pshs      a,b
                    ldx       #$005E
                    pshs      x
                    ldd       4,s
                    pshs      a,b
                    jsr       ,u
                    leas      6,s
                    bra       InstrSection
* other file types: scorelvl = 11 so every section below applies
NonScoreVersion     ldd       #$000B
                    std       <UmeData_scorelvl
* type 'u' or 'i': 14-byte local frame (offsets +14 until InstrNameTest); read -> InitInstrTable first
InstrSection        ldb       >$00C7,s
                    cmpb      #$75
                    beq       a13@
                    ldb       >$00C7,s
                    cmpb      #$69
                    lbne      MidiSection
a13@                leas      -14,s
                    ldb       >$00D3,s
                    bne       InstrRwPatches
                    lbsr      InitInstrTable
* rw 32 bytes at $075F (16 patch words), ok &= (n == 32); i = 0, p = $07EB
InstrRwPatches      ldb       <$1F,s
                    sex
                    pshs      a,b
                    ldd       #$0020
                    pshs      a,b
                    ldx       #$075F
                    pshs      x
                    ldd       <$14,s
                    pshs      a,b
                    jsr       ,u
                    leas      6,s
                    cmpd      #$0020
                    bne       a14@
                    ldd       #$0001
                    bra       b14@
a14@                clra
                    clrb
b14@                anda      ,s+
                    andb      ,s+
                    stb       <$1F,s
                    ldx       #$07EB
                    stx       2,s
                    clra
                    clrb
                    std       ,s
                    bra      InstrNameTest
* 16 names, entries 16 bytes apart from $07EB: write -> StrNCpy(tmp, p, 10), tmp[9] = 0
InstrNameLoop       ldb       >$00D3,s
                    beq       InstrNameRw
                    ldd       #$000A
                    pshs      a,b
                    ldd       4,s
                    pshs      a,b
                    leax      8,s
                    pshs      x
                    lbsr      StrNCpy
                    leas      6,s
                    clra
                    clrb
                    stb       13,s
* rw the 10 bytes of tmp, ok &= (n == 10)
InstrNameRw         ldb       <$1F,s
                    sex
                    pshs      a,b
                    ldd       #$000A
                    pshs      a,b
                    leax      8,s
                    pshs      x
                    ldd       <$14,s
                    pshs      a,b
                    jsr       ,u
                    leas      6,s
                    cmpd      #$000A
                    bne       a15@
                    ldd       #$0001
                    bra       InstrNameStore
a15@                clra
                    clrb
* read -> tmp[9] = 0, StrNCpy(p, tmp, 10); i++, p += 16
InstrNameStore      anda      ,s+
                    andb      ,s+
                    stb       <$1F,s
                    ldb       >$00D3,s
                    bne       a16@
                    clra
                    clrb
                    stb       13,s
                    ldd       #$000A
                    pshs      a,b
                    leax      6,s
                    pshs      x
                    ldd       6,s
                    pshs      a,b
                    lbsr      StrNCpy
                    leas      6,s
a16@                ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    ldd       2,s
                    addd      #$0010
                    std       2,s
* loop while i < 16; then drop the 14-byte frame
InstrNameTest       ldd       ,s
                    cmpd      #$0010
                    blt      InstrNameLoop
                    leas      14,s
* type 'u' or 'm'
MidiSection         ldb       >$00C7,s
                    cmpb      #$75
                    beq       MidiRwCfg
                    ldb       >$00C7,s
                    cmpb      #$6D
                    bne       LevelSection
* rw 17 bytes at MidiChanTbl ($03F3), ok &= (n == 17)
MidiRwCfg           ldb       <$11,s
                    sex
                    pshs      a,b
                    ldd       #$0011
                    pshs      a,b
                    ldx       #MidiChanTbl
                    pshs      x
                    ldd       6,s
                    pshs      a,b
                    jsr       ,u
                    leas      6,s
                    cmpd      #$0011
                    bne       a17@
                    ldd       #$0001
                    bra       b17@
a17@                clra
                    clrb
b17@                anda      ,s+
                    andb      ,s+
                    stb       <$11,s
* type 'u' or 'l': only for version 2 or version > 3
LevelSection        ldb       >$00C7,s
                    cmpb      #$75
                    beq       a18@
                    ldb       >$00C7,s
                    cmpb      #$6C
                    bne       ImEvtsSection
a18@                ldd       <UmeData_scorelvl
                    cmpd      #$0002
                    beq       LevelRw
                    ldd       <UmeData_scorelvl
                    cmpd      #$0003
                    ble       ImEvtsSection
* rw 8 bytes at $0103 (levels), ok &= (n == 8 || version == 2)
LevelRw             ldb       <$11,s
                    sex
                    pshs      a,b
                    ldd       #$0008
                    pshs      a,b
                    ldx       #$0103
                    pshs      x
                    ldd       6,s
                    pshs      a,b
                    jsr       ,u
                    leas      6,s
                    cmpd      #$0008
                    beq       a19@
                    ldd       <UmeData_scorelvl
                    cmpd      #$0002
                    bne       b19@
a19@                ldd       #$0001
                    bra       c19@
b19@                clra
                    clrb
c19@                anda      ,s+
                    andb      ,s+
                    stb       <$11,s
* type 'u': $12,s = $0434, pswapevts(1); write or version >= 3 -> ImEvtsRwCount, else ImEvtsClearOld
ImEvtsSection       ldb       >$00C7,s
                    cmpb      #$75
                    lbne      Ver6Section
                    ldd       #$0434
                    std       <$12,s
                    ldd       #$0001
                    pshs      a,b
                    jsr       [>UmeData_pswapevts]
                    leas      2,s
                    ldb       >$00C5,s
                    bne       ImEvtsRwCount
                    ldd       <UmeData_scorelvl
                    cmpd      #$0003
                    blt      ImEvtsClearOld
* rw the word $12,s; ImEvts base $03E5 == 0 -> ImEvtsSkipHdr; read -> ClearImHeader first
ImEvtsRwCount       ldd       #$0002
                    pshs      a,b
                    leax      <$14,s
                    pshs      x
                    ldd       4,s
                    pshs      a,b
                    jsr       ,u
                    leas      6,s
                    ldd       >UmeData_reserved_03E5
                    beq      ImEvtsSkipHdr
                    ldb       >$00C5,s
                    bne       ImEvtsRwHdr
                    lbsr      ClearImHeader
* rw $D0 bytes at $03E5+$1000 (ImEvts header), ok &= (n == $D0); rfr_tit = ok && reading
ImEvtsRwHdr         ldb       <$11,s
                    sex
                    pshs      a,b
                    ldd       #$00D0
                    pshs      a,b
                    ldd       >UmeData_reserved_03E5
                    addd      #$1000
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    jsr       ,u
                    leas      6,s
                    cmpd      #$00D0
                    bne       a20@
                    ldd       #$0001
                    bra       b20@
a20@                clra
                    clrb
b20@                anda      ,s+
                    andb      ,s+
                    stb       <$11,s
                    sex
                    pshs      a,b
                    ldb       >$00C7,s
                    bne       c20@
                    ldd       #$0001
                    bra       d20@
c20@                clra
                    clrb
d20@                anda      ,s+
                    andb      ,s+
                    stb       <UmeData_rfr_tit
                    bra       ImEvtsUnmap
* no ImEvts block: SeekForward(fd, $D0)
ImEvtsSkipHdr       ldd       #$00D0
                    pshs      a,b
                    ldd       2,s
                    pshs      a,b
                    lbsr      SeekForward
                    leas      4,s
                    bra       ImEvtsUnmap
* version < 3 read: ClearImHeader if the block exists
ImEvtsClearOld      ldd       >UmeData_reserved_03E5
                    beq       ImEvtsUnmap
                    lbsr      ClearImHeader
* pswapevts(0)
ImEvtsUnmap         clra
                    clrb
                    pshs      a,b
                    jsr       [>UmeData_pswapevts]
                    leas      2,s
* version >= 6 (else ExtRecSection): type 'u' writes 8 bytes at $0103 again, or skips them when reading
Ver6Section         ldd       <UmeData_scorelvl
                    cmpd      #$0006
                    lblt      ExtRecSection
                    ldb       >$00C7,s
                    cmpb      #$75
                    bne       PercSection
                    ldb       >$00C5,s
                    beq       Ver6SkipLevels
                    ldd       #$0008
                    pshs      a,b
                    ldx       #$0103
                    pshs      x
                    ldd       4,s
                    pshs      a,b
                    lbsr      WritePath
                    leas      6,s
                    bra       PercSection
Ver6SkipLevels      ldd       #$0008
                    pshs      a,b
                    ldd       2,s
                    pshs      a,b
                    lbsr      SeekForward
                    leas      4,s
* type 'u' or 'p'
PercSection         ldb       >$00C7,s
                    cmpb      #$75
                    beq       PercRwTables
                    ldb       >$00C7,s
                    cmpb      #$70
                    bne       ScoreRwByte83
* rw 17 bytes at $0CA3 and 24 at $0CB4 (percussion tables), ok &= (n == 24)
PercRwTables        ldd       #$0011
                    pshs      a,b
                    ldx       #$0CA3
                    pshs      x
                    ldd       4,s
                    pshs      a,b
                    jsr       ,u
                    leas      6,s
                    ldb       <$11,s
                    sex
                    pshs      a,b
                    ldd       #$0018
                    pshs      a,b
                    ldx       #$0CB4
                    pshs      x
                    ldd       6,s
                    pshs      a,b
                    jsr       ,u
                    leas      6,s
                    cmpd      #$0018
                    bne       a21@
                    ldd       #$0001
                    bra       b21@
a21@                clra
                    clrb
b21@                anda      ,s+
                    andb      ,s+
                    stb       <$11,s
* type 'u' (else ExtRecSection): rw 1 byte at $0083, ok &= (n == 1)
ScoreRwByte83       ldb       >$00C7,s
                    cmpb      #$75
                    lbne      ExtRecSection
                    ldb       <$11,s
                    sex
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldx       #$0083
                    pshs      x
                    ldd       6,s
                    pshs      a,b
                    jsr       ,u
                    leas      6,s
                    cmpd      #$0001
                    bne       a22@
                    ldd       #$0001
                    bra       ScoreRwWord60
a22@                clra
                    clrb
* version >= 7: rw 2 bytes at $0060, ok &= (n == 2)
ScoreRwWord60       anda      ,s+
                    andb      ,s+
                    stb       <$11,s
                    ldd       <UmeData_scorelvl
                    cmpd      #$0007
                    blt       ImListSection
                    ldb       <$11,s
                    sex
                    pshs      a,b
                    ldd       #$0002
                    pshs      a,b
                    ldx       #$0060
                    pshs      x
                    ldd       6,s
                    pshs      a,b
                    jsr       ,u
                    leas      6,s
                    cmpd      #$0002
                    bne       a23@
                    ldd       #$0001
                    bra       b23@
a23@                clra
                    clrb
b23@                anda      ,s+
                    andb      ,s+
                    stb       <$11,s
* version >= 9: write -> len = pswapevts(1) ? ImListLength() : 0
ImListSection       ldd       <UmeData_scorelvl
                    cmpd      #$0009
                    lblt      ExtRecSection
                    ldb       >$00C5,s
                    beq       ImListRwLen
                    ldd       #$0001
                    pshs      a,b
                    jsr       [>UmeData_pswapevts]
                    std       ,s++
                    beq       a24@
                    lbsr      ImListLength
                    std       <$12,s
                    bra       ImListRwLen
a24@                clra
                    clrb
                    std       <$12,s
                    clra
                    clrb
                    pshs      a,b
                    jsr       [>UmeData_pswapevts]
                    leas      2,s
* rw the list length word ($12,s)
ImListRwLen         ldb       <$11,s
                    sex
                    pshs      a,b
                    ldd       #$0002
                    pshs      a,b
                    leax      <$16,s
                    pshs      x
                    ldd       6,s
                    pshs      a,b
                    jsr       ,u
                    leas      6,s
                    cmpd      #$0002
                    bne       a25@
                    ldd       #$0001
                    bra       ImListCheckLen
a25@                clra
                    clrb
* ok &= (n == 2); !ok or len <= 0 -> ImListUnmap; read -> avail = pievtinit(len), avail < len -> "Outa RAM; Events List cut short!" and len = avail
ImListCheckLen      anda      ,s+
                    andb      ,s+
                    stb       <$11,s
                    beq      ImListUnmap
                    ldd       <$12,s
                    ble      ImListUnmap
                    ldb       >$00C5,s
                    bne       ImListRwData
                    ldd       <$12,s
                    pshs      a,b
                    jsr       [>UmeData_pievtinit]
                    leas      2,s
                    std       4,s
                    cmpd      <$12,s
                    bge       ImListMap
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgImListCut,pcr
                    pshs      x
                    jsr       [>UmeData_palert]
                    leas      4,s
                    ldd       4,s
                    std       <$12,s
* pswapevts(1); $03E9 (list end) = $03E5 + len
ImListMap           ldd       #$0001
                    pshs      a,b
                    jsr       [>UmeData_pswapevts]
                    leas      2,s
                    ldd       >UmeData_reserved_03E5
                    addd      <$12,s
                    std       >UmeData_reserved_03E9
* rw len bytes at $03E5, ok &= (n == len)
ImListRwData        ldb       <$11,s
                    sex
                    pshs      a,b
                    ldd       <$14,s
                    pshs      a,b
                    ldd       >UmeData_reserved_03E5
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    jsr       ,u
                    leas      6,s
                    cmpd      <$14,s
                    bne       a26@
                    ldd       #$0001
                    bra       b26@
a26@                clra
                    clrb
b26@                anda      ,s+
                    andb      ,s+
                    stb       <$11,s
* pswapevts(0)
ImListUnmap         clra
                    clrb
                    pshs      a,b
                    jsr       [>UmeData_pswapevts]
                    leas      2,s
* version >= 11 (else MainCloseFile), type 'u' (else InstantSection): pswapevts(1), find the last non-empty 52-byte record at $03E5+$1000, i = 9 down
ExtRecSection       ldd       <UmeData_scorelvl
                    cmpd      #$000B
                    lblt      MainCloseFile
                    ldb       >$00C7,s
                    cmpb      #$75
                    lbne      InstantSection
                    ldd       #$0001
                    pshs      a,b
                    jsr       [>UmeData_pswapevts]
                    leas      2,s
                    ldd       #$0009
                    stb       14,s
                    bra       ExtRecScanNext
* record i non-empty -> ExtRecCount
ExtRecScan          ldd       >UmeData_reserved_03E5
                    addd      #$1000
                    pshs      a,b
                    ldb       <$10,s
                    sex
                    pshs      a,b
                    ldd       #$0034
                    lbsr      MulInt16
                    addd      ,s++
                    tfr       d,x
                    ldb       ,x
                    bne       ExtRecCount
* i--, loop while i >= 0
ExtRecScanNext      ldb       14,s
                    addd      #$FFFF
                    stb       14,s
                    bge       ExtRecScan
* count = i-3 (records beyond the four inside the $D0 header), clamped to 0; writing with no ImEvts block -> 0
ExtRecCount         ldb       14,s
                    sex
                    addd      #$FFFD
                    stb       14,s
                    blt       a27@
                    ldb       >$00C5,s
                    beq       ExtRecRwCount
                    ldd       >UmeData_reserved_03E5
                    bne       ExtRecRwCount
a27@                clra
                    clrb
                    stb       14,s
* rw the count byte (14,s); count 0 -> ExtRecUnmap; block present -> rw count*52 bytes at $03E5+$10D0, else ExtRecSkip
ExtRecRwCount       ldd       #$0001
                    pshs      a,b
                    leax      <$10,s
                    pshs      x
                    ldd       4,s
                    pshs      a,b
                    jsr       ,u
                    leas      6,s
                    ldb       14,s
                    beq       ExtRecUnmap
                    ldd       >UmeData_reserved_03E5
                    beq       ExtRecSkip
                    ldb       14,s
                    sex
                    pshs      a,b
                    ldd       #$0034
                    lbsr      MulInt16
                    pshs      a,b
                    ldd       >UmeData_reserved_03E5
                    addd      #$10D0
                    pshs      a,b
                    ldd       4,s
                    pshs      a,b
                    jsr       ,u
                    leas      6,s
                    bra       ExtRecUnmap
ExtRecSkip          ldb       14,s
                    sex
                    pshs      a,b
                    ldd       #$0034
                    lbsr      MulInt16
                    pshs      a,b
                    ldd       2,s
                    pshs      a,b
                    lbsr      SeekForward
                    leas      4,s
* pswapevts(0)
ExtRecUnmap         clra
                    clrb
                    pshs      a,b
                    jsr       [>UmeData_pswapevts]
                    leas      2,s
* type 'u' or 'i' -> s9e, else MainCloseFile
InstantSection      ldb       >$00C7,s
                    cmpb      #$75
                    beq       InstantCallUm3E
                    ldb       >$00C7,s
                    cmpb      #$69
                    bne       MainCloseFile
* soowee('E', 'i', fd, write): s9e's InstrFileIO reads/writes the 64-slot instrument table; ok &= (result || type == 'i')
InstantCallUm3E     ldb       <$11,s
                    sex
                    pshs      a,b
                    ldb       >$00C7,s
                    sex
                    pshs      a,b
                    ldd       4,s
                    pshs      a,b
                    ldd       #$0069
                    pshs      a,b
                    ldd       #$0045
                    pshs      a,b
                    jsr       [>UmeData_psoowee]
                    leas      8,s
                    std       -2,s
                    bne       a28@
                    ldb       >$00C9,s
                    cmpb      #$69
                    bne       b28@
a28@                ldd       #$0001
                    bra       c28@
b28@                clra
                    clrb
c28@                anda      ,s+
                    andb      ,s+
                    stb       <$11,s
* ClosePath(fd); !ok -> "**Disk Full?" when writing, "**Disk Read Short; Data bad?" when reading
MainCloseFile       ldd       ,s
                    pshs      a,b
                    lbsr      ClosePath
                    leas      2,s
                    ldb       <$11,s
                    bne       MainReturnOne
                    clra
                    clrb
                    pshs      a,b
                    ldb       >$00C7,s
                    beq       a29@
                    leax      >msgDiskFull,pcr
                    bra       b29@
a29@                leax      >msgReadShort,pcr
b29@                tfr       x,d
                    pshs      a,b
                    jsr       [>UmeData_palert]
                    leas      4,s
* return 1; a native score read resets the view
MainReturnOne       tst       >$00C5,s            writes retain the current view
                    bne       viewret@
                    ldb       >$00C7,s
                    cmpb      #'u
                    bne       viewret@
                    lbsr      ResetScoreView
* A drive shortcut's read: the picked name becomes the score's name ($0BEB) - File > Read copies it
* in s9, but the drive-shortcut path passes no buffer.
                    ldb       >$00C1,s            the command: $10-$15 = a drive shortcut
                    cmpb      #$10
                    blo       viewret@
                    cmpb      #$15
                    bhi       viewret@
                    ldd       >$00C2,s            the picked name
                    pshs      d
                    ldd       #UmeData_reserved_0BEB
                    pshs      d
                    lbsr      StrCpy
                    leas      4,s
viewret@            ldd       #$0001
                    leas      >$00BC,s
                    puls      u,pc
* Shared successful score-read return: native, MIDI, Lyra, Musica and Orchestra.
* Logical positions are zero; the main reinit remaps the event pointer afterward.
ResetScoreView      pshs      d,x
                    clra
                    clrb
                    std       <UmeData_xgoal
                    std       <UmeData_gbar
                    std       <UmeData_gind
                    std       <UmeData_gbarind
                    std       <UmeData_ritind
                    std       <UmeData_lftind
                    lda       #1
                    sta       <UmeData_rfr_scr                redraw score and scrollbar
                    sta       <UmeData_rfr_bar
                    puls      d,x,pc
* Unreferenced: the original's directory-listing and picker strings (the picker now lives in s9r).
pathCurDir          fcb       $2E,$00
msgCantOpenDir      fcc       /Can't open Dir, Error #/
                    fcb       $00
fmtNoFiles          fcc       /No %s%s files./
                    fcb       $0D,$00
strNonPrefix        fcc       /non-/
                    fcb       $00
strEmpty            fcb       $00
fmtThreeCols        fcc       /%-26s%-26s%-25s/
                    fcb       $0D,$00
fmtLabelCancel      fcc       /%-26s   (CANCEL)/
                    fcb       $00
strKillFile         fcc       /   (KILL FILE)/
                    fcb       $00
strChangeDir        fcc       /   (CHANGE DIR)/
                    fcb       $00
strWriteFile        fcc       /   (WRITE FILE)/
                    fcb       $00
strReadFile         fcc       /   (READ FILE)/
                    fcb       $00
msgClickOrType      fcc       /Click one, or type name: /
                    fcb       $00
strClearLine        fcb       $0C,$0D,$00
fmtClearShowName    fcb       $0C,$0D,$25,$73,$00
fmtCantChd          fcc       /Can't CHD to '%s'/
                    fcb       $0D,$00
msgCantKill         fcc       /Can't delete; error #/
                    fcb       $00
fmtOverwrite        fcc       /OVERWRITE %s?/
                    fcb       $00
fmtCantCreate       fcc       / Can't create:/
                    fcb       $0D
                    fcc       / %s/
                    fcb       $0D,$00
fmtCantOpen         fcc       / Can't open:/
                    fcb       $0D
                    fcc       / %s/
                    fcb       $0D,$00
* used only by the skipped version box (ScoreReadVersion)
fmtScoreVersion     fcc       /Score v%d; reader v%d./
                    fcb       $00
msgOddFile          fcc       /Odd file, punt!/
                    fcb       $0D,$00
fmtScoreCut         fcc       /WARNING:/
                    fcb       $0D
                    fcc       / Score cut from %d to %d items!/
                    fcb       $0D,$00
msgOutaRam          fcc       /**Outa RAM, Score Cut!/
                    fcb       $0D,$00
msgImListCut        fcc       /Outa RAM; Events List cut short!/
                    fcb       $0D,$00
msgDiskFull         fcc       /**Disk Full?/
                    fcb       $00
msgReadShort        fcc       /**Disk Read Short; Data bad?/
                    fcb       $00
* AppendScore(name): WinDefine(14,150,50,14,1,WinStylePaper3D), AddExtension .ume, OpenPath (fail -> "No '%s'"), read the incoming header, compare, append
AppendScore         pshs      u
                    leas      >-$00BE,s
                    ldd       #$0001
                    stb       8,s
                    ldd       #WinStylePaper3D    the paper 3D box
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$000E
                    pshs      a,b
                    ldd       #$0032
                    pshs      a,b
                    ldd       #$0096
                    pshs      a,b
                    ldd       #$000E
                    pshs      a,b
                    lbsr      WinDefine
                    leas      12,s
                    leax      >strUmeAppend,pcr
                    pshs      x
                    ldd       >$00C4,s
                    pshs      a,b
                    lbsr      AddExtension
                    leas      4,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       >$00C4,s
                    pshs      a,b
                    lbsr      OpenPath
                    leas      4,s
                    std       4,s
                    cmpd      #$0002
                    bge       AppendReadHdr
                    ldd       >$00C2,s
                    pshs      a,b
                    leax      >fmtNoFile,pcr
                    lbra      AppendErrPrint
* incoming version byte -> $23,s, parts (& $1F) -> $22,s, words staves $20, $03 $1E, $05 $1C, event count $1A, part table -> $7A,s, staff table -> $34,s; a newer version raises scorelvl
AppendReadHdr       ldd       #$0001
                    pshs      a,b
                    leax      <$25,s
                    pshs      x
                    ldd       8,s
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    ldd       #$0001
                    pshs      a,b
                    leax      <$24,s
                    pshs      x
                    ldd       8,s
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    ldb       <$22,s
                    clra
                    andb      #$1F
                    stb       <$22,s
                    ldd       #$0002
                    pshs      a,b
                    leax      <$22,s
                    pshs      x
                    ldd       8,s
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    ldd       #$0002
                    pshs      a,b
                    leax      <$20,s
                    pshs      x
                    ldd       8,s
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    ldd       #$0002
                    pshs      a,b
                    leax      <$1E,s
                    pshs      x
                    ldd       8,s
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    ldd       #$0002
                    pshs      a,b
                    leax      <$1C,s
                    pshs      x
                    ldd       8,s
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    ldb       <$22,s
                    sex
                    addd      #$0001
                    aslb
                    rola
                    aslb
                    rola
                    pshs      a,b
                    leax      <$7C,s
                    pshs      x
                    ldd       8,s
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    ldd       <$20,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      MulInt16
                    pshs      a,b
                    leax      <$36,s
                    pshs      x
                    ldd       8,s
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    ldb       <$23,s
                    sex
                    cmpd      >UmeData_scorelvl
                    ble       AppendPartsCheck
                    ldb       <$23,s
                    sex
                    std       >UmeData_scorelvl
* incoming parts > nparts -> "I QUIT; more Incoming parts!", AppendFail
AppendPartsCheck    ldb       <$22,s
                    sex
                    cmpd      >UmeData_nparts
                    ble       AppendCmpInit
                    leax      >msgMoreParts,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    lbra      AppendFail
* errors (0,s) = 0, part i = 1
AppendCmpInit       clra
                    clrb
                    std       ,s
                    ldd       #$0001
                    lbra      AppendCmpTest
* clef word of part i's staff record, current vs incoming; differ -> errors++, "Clefs mismatch Part %d!"
AppendCmpPart       ldd       2,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$0C5F
                    leax      d,x
                    stx       9,s
                    ldd       2,x
                    stb       13,s
                    ldd       [<$09,s]
                    pshs      a,b
                    ldd       #$000A
                    lbsr      MulInt16
                    ldx       #$0C19
                    leax      d,x
                    ldd       2,x
                    std       <$16,s
                    ldd       2,s
                    aslb
                    rola
                    aslb
                    rola
                    leax      <$7A,s
                    leax      d,x
                    stx       9,s
                    ldd       2,x
                    stb       12,s
                    ldd       [<$09,s]
                    pshs      a,b
                    ldd       #$000A
                    lbsr      MulInt16
                    leax      <$34,s
                    leax      d,x
                    ldd       2,x
                    std       <$14,s
                    ldd       <$16,s
                    cmpd      <$14,s
                    beq       AppendCmpHollow
                    ldd       ,s
                    addd      #$0001
                    std       ,s
                    ldd       2,s
                    pshs      a,b
                    leax      >fmtClefsMismatch,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      4,s
* part byte 3 bit $10 ('Hollow' percussion) differs -> errors++, message; i++
AppendCmpHollow     ldb       13,s
                    sex
                    pshs      a,b
                    ldb       14,s
                    sex
                    eora      ,s+
                    eorb      ,s+
                    clra
                    andb      #$10
                    beq       a30@
                    ldd       ,s
                    addd      #$0001
                    std       ,s
                    ldd       2,s
                    pshs      a,b
                    leax      >fmtHollowMismatch,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      4,s
a30@                ldd       2,s
                    addd      #$0001
* loop while i <= incoming parts; errors -> "I QUIT: %d Errors!" and AppendFail, else AppendAddMarks
AppendCmpTest       std       2,s
                    ldb       <$22,s
                    sex
                    cmpd      2,s
                    lbge      AppendCmpPart
                    ldd       ,s
                    beq       AppendAddMarks
                    ldd       ,s
                    pshs      a,b
                    leax      >fmtQuitErrors,pcr
* shared printf(fmt in X) falling into AppendFail
AppendErrPrint      pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      4,s
* pause (phit), WinEnd, return 0
AppendFail          jsr       [>UmeData_phit]
                    lbsr      WinEnd
                    clra
                    clrb
                    leas      >$00BE,s
                    puls      u,pc
* WinEnd; marker = the 8-byte template at $0C11 with byte 5 = 2, stored at EventPtr(nevents); nevents += 2; NextEvent; both incoming $03/$05 words set -> second marker byte 5 = $0A, bytes 6/7 = those words
AppendAddMarks      lbsr      WinEnd
                    ldd       #$0008
                    pshs      a,b
                    ldx       #$0C11
                    pshs      x
                    leax      <$30,s
                    pshs      x
                    lbsr      MemCopy
                    leas      6,s
                    ldd       #$0002
                    stb       <$31,s
                    ldd       <UmeData_nevents
                    pshs      a,b
                    lbsr      EventPtr
                    leas      2,s
                    tfr       d,u
                    ldd       <UmeData_nevents
                    addd      #$0002
                    std       <UmeData_nevents
                    ldd       #$0008
                    pshs      a,b
                    leax      <$2E,s
                    pshs      x
                    pshs      u
                    lbsr      MemCopy
                    leas      6,s
                    lbsr      NextEvent
                    tfr       d,u
                    ldd       <$1E,s
                    beq       AppendStoreMark
                    ldd       <$1C,s
                    beq       AppendStoreMark
                    ldd       #$000A
                    stb       <$31,s
                    ldd       <$1E,s
                    stb       <$32,s
                    ldd       <$1C,s
                    stb       <$33,s
* store the second marker; 6,s = first appended index; SanitizeEvents; nevents += incoming count; end position $24,s = LSeek(fd, 0, 1) + count*8; nevents > $7FFF -> clamp, "WARNING: Score cut short!"
AppendStoreMark     ldd       #$0008
                    pshs      a,b
                    leax      <$2E,s
                    pshs      x
                    pshs      u
                    lbsr      MemCopy
                    leas      6,s
                    ldd       <UmeData_nevents
                    std       6,s
                    lbsr      SanitizeEvents
                    ldd       <UmeData_nevents
                    addd      <$1A,s
                    std       <UmeData_nevents
                    leax      <$24,s
                    pshs      x
                    ldd       #$0001
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    lbsr      LSeek
                    leas      8,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       <$20,s
                    lbsr      LongFromInt
                    pshs      x
                    ldd       #$0003
                    lbsr      LongShl
                    lbsr      LongAdd
                    lbsr      LongStore
                    ldd       <UmeData_nevents
                    cmpd      #$7FFF
                    ble       AppendEvInit
                    ldd       #$7FFF
                    std       <UmeData_nevents
                    leax      >msgScoreCutShort,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    jsr       [>UmeData_phit]
* u = EventPtr(6,s), i ($2A,s) = 0
AppendEvInit        ldd       6,s
                    pshs      a,b
                    lbsr      EventPtr
                    leas      2,s
                    tfr       d,u
                    clra
                    clrb
                    std       <$2A,s
                    bra       AppendEvTest
* read one event into the page; short -> AppendEvShort; i++, u = NextEvent
AppendEvRead        ldd       #$0008
                    pshs      a,b
                    pshs      u
                    ldd       8,s
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    std       <$28,s
                    cmpd      #$0008
                    bne       AppendEvShort
                    ldd       <$2A,s
                    addd      #$0001
                    std       <$2A,s
                    subd      #$0001
                    lbsr      NextEvent
                    tfr       d,u
* loop while i < incoming count
AppendEvTest        ldd       <$2A,s
                    cmpd      <$1A,s
                    blt       AppendEvRead
* i != count: ok = 0 and nevents -= (count - i)
AppendEvShort       ldd       <$2A,s
                    cmpd      <$1A,s
                    beq       AppendEvDone
                    clra
                    clrb
                    stb       8,s
                    ldd       <UmeData_nevents
                    pshs      a,b
                    ldd       <$1C,s
                    subd      <$2C,s
                    nega
                    negb
                    sbca      #$00
                    addd      ,s++
                    std       <UmeData_nevents
* SanitizeEvents, LSeek(fd, end position, 0), u = EventPtr(first appended - 2)
AppendEvDone        lbsr      SanitizeEvents
                    clra
                    clrb
                    pshs      a,b
                    leax      <$26,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    lbsr      LSeek
                    leas      8,s
                    ldd       6,s
                    addd      #$FFFE
                    pshs      a,b
                    lbsr      EventPtr
                    leas      2,s
                    bra       AppendShiftTest
* time 1,u += $93 (time offset of the appended material)
AppendShiftTime     ldd       1,u
                    pshs      a,b
                    ldd       <UmeData_reserved_0093
                    addd      ,s++
                    std       1,u
                    lbsr      NextEvent
* loop while curind < nevents; then xgoal = 40, gind = first appended index, skip 787 bytes; version < 9 -> AppendClose; else skip 8, 255 and 52 more, old list length -> $12,s, room ($03E7 - $03E9 + 1) -> $10,s, incoming length -> 14,s (minus 1, cut to the room with "Some Events cut!", excess -> $2A,s)
AppendShiftTest     tfr       d,u
                    ldd       <UmeData_curind
                    cmpd      <UmeData_nevents
                    blt       AppendShiftTime
                    ldd       #$0028
                    std       >UmeData_xgoal
                    ldd       6,s
                    std       <UmeData_gind
                    ldd       #$0313
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    lbsr      SeekForward
                    leas      4,s
                    ldb       <$23,s
                    cmpb      #$09
                    lblt      AppendClose
                    ldd       #$0008
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    lbsr      SeekForward
                    leas      4,s
                    ldd       #$00FF
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    lbsr      SeekForward
                    leas      4,s
                    ldd       #$0034
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    lbsr      SeekForward
                    leas      4,s
                    lbsr      ImListLength
                    std       <$12,s
                    ldd       >UmeData_reserved_03E7
                    subd      >UmeData_reserved_03E9
                    addd      #$0001
                    std       <$10,s
                    ldb       8,s
                    sex
                    pshs      a,b
                    ldd       #$0002
                    pshs      a,b
                    leax      <$12,s
                    pshs      x
                    ldd       10,s
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    cmpd      #$0002
                    bne       a31@
                    ldd       #$0001
                    bra       b31@
a31@                clra
                    clrb
b31@                anda      ,s+
                    andb      ,s+
                    stb       8,s
                    lbeq      AppendClose
                    ldd       14,s
                    cmpd      #$0001
                    lble      AppendClose
                    ldd       14,s
                    addd      #$FFFF
                    std       14,s
                    subd      <$10,s
                    std       <$2A,s
                    ble       AppendReadEsb
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgEventsCut,pcr
                    pshs      x
                    jsr       [>UmeData_palert]
                    leas      4,s
                    ldd       <$10,s
                    std       14,s
* ESB marker byte != $EA (234) -> "ESB not 234, =" box
AppendReadEsb       ldd       #$0001
                    pshs      a,b
                    leax      13,s
                    pshs      x
                    ldd       8,s
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    ldb       11,s
                    cmpb      #$EA
                    beq       AppendReadImList
                    ldb       11,s
                    sex
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    leax      >msgEsbNot234,pcr
                    pshs      x
                    jsr       [>UmeData_palert]
                    leas      6,s
* pswapevts(1); read len bytes at the list end $03E9, ok &= (n == len)
AppendReadImList    ldd       #$0001
                    pshs      a,b
                    jsr       [>UmeData_pswapevts]
                    leas      2,s
                    ldb       8,s
                    sex
                    pshs      a,b
                    ldd       <$10,s
                    pshs      a,b
                    ldd       >UmeData_reserved_03E9
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    cmpd      <$10,s
                    bne       a32@
                    ldd       #$0001
                    bra       AppendImListOk
a32@                clra
                    clrb
* pswapevts(0); skip the excess bytes ($2A,s > 0)
AppendImListOk      anda      ,s+
                    andb      ,s+
                    stb       8,s
                    clra
                    clrb
                    pshs      a,b
                    jsr       [>UmeData_pswapevts]
                    leas      2,s
                    ldd       <$2A,s
                    ble       AppendAdjustIm
                    ldd       <$2A,s
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    bsr      SeekForward
                    leas      4,s
* $03E9 += len; $12,s = old list length - 1; u = EventPtr(first appended)
AppendAdjustIm      ldd       >UmeData_reserved_03E9
                    addd      14,s
                    std       >UmeData_reserved_03E9
                    ldd       <$12,s
                    addd      #$FFFF
                    std       <$12,s
                    ldd       6,s
                    pshs      a,b
                    lbsr      EventPtr
                    leas      2,s
                    bra       AppendFixTest
* part-0 events of type $1E/$1F with a non-negative word 3,u: that list offset += $12,s
AppendFixImRef      ldb       ,u
                    bne       AppendFixNext
                    ldb       5,u
                    cmpb      #$1E
                    beq       a33@
                    ldb       5,u
                    cmpb      #$1F
                    bne       AppendFixNext
a33@                ldb       3,u
                    blt       AppendFixNext
                    ldd       3,u
                    addd      <$12,s
                    std       3,u
AppendFixNext       lbsr      NextEvent
* loop while curind < nevents
AppendFixTest       tfr       d,u
                    ldd       <UmeData_curind
                    cmpd      <UmeData_nevents
                    blt       AppendFixImRef
* ClosePath(fd); !ok -> "Append read errors."
AppendClose         ldd       4,s
                    pshs      a,b
                    lbsr      ClosePath
                    leas      2,s
                    ldb       8,s
                    bne       AppendExit
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgAppendErrors,pcr
                    pshs      x
                    jsr       [>UmeData_palert]
                    leas      4,s
* return ok (B = 8,s)
AppendExit          ldb       8,s
                    leas      >$00BE,s
                    puls      u,pc
* SeekForward(fd, n): LSeek(fd, (long)n, 1) - skip n bytes
SeekForward         pshs      u
                    ldd       #$0001
                    pshs      a,b
                    ldd       8,s
                    lbsr      LongFromInt
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    lbsr      LSeek
                    leas      8,s
                    puls      u,pc
* ImListLength: $03E9 - $03E5, the ImEvts list length
ImListLength        pshs      u
                    ldd       >UmeData_reserved_03E9
                    subd      >UmeData_reserved_03E5
                    puls      u,pc
strUmeAppend        fcc       /.ume/
                    fcb       $00
fmtNoFile           fcc       /No '%s'/
                    fcb       $0D,$0A,$00
msgMoreParts        fcc       /I QUIT; more Incoming parts!/
                    fcb       $0D,$00
fmtClefsMismatch    fcc       /Clefs mismatch Part %d!/
                    fcb       $0D,$00
fmtHollowMismatch   fcc       /Mismatched old 'Hollow' Perc, Part %d!/
                    fcb       $0D,$00
fmtQuitErrors       fcc       /I QUIT: %d Errors!/
                    fcb       $0D,$00
msgScoreCutShort    fcc       /WARNING: Score cut short!/
                    fcb       $0D,$00
msgEventsCut        fcc       /Some Events cut!/
                    fcb       $00
msgEsbNot234        fcc       /ESB not 234, =/
                    fcb       $00
msgAppendErrors     fcc       /Append read errors./
                    fcb       $0D,$00
* ExtForType(c): 'u' .ume, 'i' .ins, 'p' .per, 'l' .lev, 'm' .mid, else "" (strNoExt); returns the string
ExtForType          pshs      u
                    ldb       5,s
                    sex
                    tfr       d,x
                    bra       ExtDispatch
ExtUme              leax      >strExtUme,pcr
                    bra       ExtReturn
ExtIns              leax      >strExtIns,pcr
                    bra       ExtReturn
ExtPer              leax      >strExtPer,pcr
                    bra       ExtReturn
ExtLev              leax      >strExtLev,pcr
                    bra       ExtReturn
ExtMid              leax      >strExtMid,pcr
                    bra       ExtReturn
ExtDispatch         cmpx      #$0075
                    beq       ExtUme
                    cmpx      #$0069
                    beq       ExtIns
                    cmpx      #$0070
                    beq       ExtPer
                    cmpx      #$006C
                    beq       ExtLev
                    cmpx      #$006D
                    beq       ExtMid
                    leax      >strNoExt,pcr
ExtReturn           tfr       x,d
                    puls      u,pc
* HasExtension(name, ext): D = 1 when the name's last four characters match ext (case-insensitive,
* ext lowercase). For ext = strScoreExt also .ume -> 1, .mid -> 'I', .lyr -> 'Y', .mus -> 'F', .orc/.asc -> 'O'; else 0.
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
he_mus@             ldx       ,s                  Musica II binary score (s9f)
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
* Reset all 64 instrument patches ($0080) and names.
InitInstrTable      pshs      u
                    ldx       #$075F
                    ldu       #$07EB
                    ldd       #$0080
ii_loop@            std       ,x++
                    clr       ,u
                    leau      16,u
                    cmpx      #$07DF
                    blo       ii_loop@
                    puls      u,pc
* Normalize old-format events, keeping the original signed type tests.
SanitizeEvents      pshs      u
                    clra
                    clrb
                    pshs      d
                    lbsr      EventPtr
                    leas      2,s
                    bra       se_test@
se_loop@            tst       ,u
                    bne       se_note@
                    ldb       5,u
                    cmpb      #6
                    bgt       se_next@
                    ldd       3,u
                    exg       a,b
                    std       3,u
                    bra       se_next@
se_note@            ldb       6,u
                    andb      #7
                    cmpb      #1
                    beq       se_dec@
                    cmpb      #5
                    bne       se_fields@
se_dec@             decb
se_fields@          stb       6,u
                    ldb       3,u
                    andb      #7
                    stb       3,u
                    ldb       4,u
                    andb      #3
                    stb       4,u
                    ldb       7,u
                    andb      #7
                    stb       7,u
                    lda       5,u
                    cmpa      #$20
                    beq       se_two@
                    cmpb      #5
                    blt       se_next@
se_two@             ldb       #2
                    stb       7,u
se_next@            lbsr      NextEvent
se_test@            tfr       d,u
                    ldd       <UmeData_curind
                    cmpd      <UmeData_nevents
                    blt       se_loop@
                    puls      u,pc
* Append only when the filename lacks the requested extension.
AddExtension        ldd       2,s
                    ldx       4,s
                    pshs      d,x
                    lbsr      HasExtension
                    leas      4,s
                    bne       ae_done@
                    lbra      StrCat
ae_done@            rts
* Clear the 468-byte ImEvts header area at $03E5+$1000.
ClearImHeader       pshs      u
                    ldu       >UmeData_reserved_03E5
                    leau      $1000,u
                    ldx       #$01D4
ci_loop@            clr       ,u+
                    leax      -1,x
                    bne       ci_loop@
                    puls      u,pc
* unreferenced shared return with a two-byte local frame
Pop2Return          leas      2,s
                    puls      u,pc
* WinDefine(a1..a6): printf(fmt at <$14, $C6, a1, a2, a3, a4, (char)a5, a6), flush - the s9gui window-define code (x, bottom y, width, rows, ...)
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
* WinEnd: printf(fmt at <$16, $C7) - the s9gui window-close code
WinEnd              pshs      u
                    ldd       #$00C7
                    pshs      a,b
                    ldd       <UmeData_reserved_0016
                    pshs      a,b
                    jsr       [>UmeData_pprintf]
* WinEnd's tail
Pop4Return          leas      4,s
PopUReturn          puls      u,pc
* WinCtlCC(n): printf(fmt at <$18, $CC, (char)n) - unreferenced
WinCtlCC            pshs      u
                    ldb       5,s
                    sex
                    pshs      a,b
                    ldd       #$00CC
                    pshs      a,b
                    ldd       <UmeData_reserved_0018
                    bra       WinCtlPrintf
* WinCtl90: printf(fmt at <$0A, $90, 0) - unreferenced
WinCtl90            pshs      u
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0090
                    bra       WinCtlFmt0A
* WinCtl89(n): printf(fmt at <$0A, $89, n); called with 0 before reading a score
WinCtl89            pshs      u
                    ldd       4,s
                    pshs      a,b
                    ldd       #$0089
                    bra       WinCtlFmt0A
* WinCtl8B(n): printf(fmt at <$0A, $8B, n); called with 1 before reading a score
WinCtl8B            pshs      u
                    ldd       4,s
                    pshs      a,b
                    ldd       #$008B
WinCtlFmt0A         pshs      a,b
                    ldd       <UmeData_reserved_000A
* shared printf tail of the WinCtl codes
WinCtlPrintf        pshs      a,b
                    jsr       [>UmeData_pprintf]
                    leas      6,s
                    puls      u,pc
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
* EventPtr(index): curind = index; page = 1 + index/928, offset = index%928; page != curpage -> ppswap (D = 0 on failure); curevp = database + offset*8; returns curevp
EventPtr            pshs      u
                    ldu       4,s
                    leas      -2,s
                    stu       <UmeData_curind
                    ldd       #$0001
                    bra       EvPtrBlockDiv
EvPtrBlockInc       ldd       ,s
                    addd      #$0001
* page++ while (index -= 928) >= 0 (stu -2,s only sets the flags), then index += 928
EvPtrBlockDiv       std       ,s
                    leau      >-$03A0,u
                    stu       -2,s
                    bge       EvPtrBlockInc
                    leau      >$03A0,u
                    ldd       ,s
                    cmpd      <UmeData_curpage
                    beq       EvPtrCompute
                    ldd       ,s
                    pshs      a,b
                    jsr       [>UmeData_ppswap]
                    leas      2,s
                    bne       EvPtrCompute
                    clra
                    clrb
                    bra       EvPtrExit
* curevp = offset*8 + database
EvPtrCompute        tfr       u,d
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    addd      <UmeData_database
                    std       <UmeData_curevp
EvPtrExit           leas      2,s
                    puls      u,pc
* NextEvent: curind++ (pointer unchanged at nevents), curevp += 8; past curptop maps page curpage+1 and restarts at database; returns curevp
NextEvent           pshs      u
                    ldd       <UmeData_curind
                    addd      #$0001
                    std       <UmeData_curind
                    cmpd      <UmeData_nevents
                    bge       NextEvReturn
                    ldd       <UmeData_curevp
                    addd      #$0008
                    std       <UmeData_curevp
                    cmpd      <UmeData_curptop
                    bls       NextEvReturn
                    ldd       <UmeData_curpage
                    addd      #$0001
                    pshs      a,b
                    jsr       [>UmeData_ppswap]
                    leas      2,s
                    ldd       <UmeData_database
                    bra       a38@
a38@                std       <UmeData_curevp
NextEvReturn        ldd       <UmeData_curevp
                    puls      u,pc
* strcat(dest, src); returns dest
StrCat              pshs      u
                    ldu       6,s
                    ldx       4,s
                    bsr       SkipToNul
                    tfr       d,x
                    bra       StrCopyLoop
* strcpy(dest, src); returns dest
StrCpy              pshs      u
                    ldu       6,s
                    ldx       4,s
StrCopyLoop         ldb       ,u+
                    stb       ,x+
                    bne       StrCopyLoop
                    ldd       4,s
                    puls      u,pc
                    fcb       $AE,$62
* X -> the terminating NUL, also in D
SkipToNul           ldb       ,x+
                    bne       SkipToNul
                    leax      -1,x
                    tfr       x,d
                    rts
* strcmp(a, b): a[i]-b[i] sign-extended at the first difference, 0 when equal - unreferenced
StrCmp              pshs      u
                    ldx       4,s
                    ldu       6,s
                    bra       StrCmpLoop
StrCmpAdvance       ldb       ,u+
                    beq       StrCmpReturn
StrCmpLoop          ldb       ,u
                    subb      ,x+
                    beq       StrCmpAdvance
                    negb
StrCmpReturn        sex
                    puls      u,pc
* strlen(s)
StrLen              pshs      u
                    ldu       4,s
StrLenLoop          ldb       ,u+
                    bne       StrLenLoop
                    leau      -1,u
                    tfr       u,d
                    subd      4,s
                    puls      u,pc
* strncpy(dest, src, n): copies up to n bytes, pads the rest with NUL; returns dest
StrNCpy             pshs      y,u
                    ldu       8,s
                    ldx       6,s
                    ldy       10,s
                    beq       StrNCpyDone
StrNCpyLoop         ldb       ,u+
                    stb       ,x+
                    leay      -1,y
                    beq       StrNCpyDone
                    tstb
                    bne       StrNCpyLoop
a39@                clr       ,x+
                    leay      -1,y
                    bne       a39@
StrNCpyDone         ldd       6,s
                    puls      y,u,pc
* CopyOs9Name(dest, src): copy up to the byte with bit 7 set (OS-9 directory name end), clear that bit, add a NUL; returns dest - unreferenced
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
* memcpy(dest, src, n): odd byte first, then n/2 words; n == 0 does nothing
MemCopy             pshs      y,u
                    ldu       6,s
                    ldy       8,s
                    ldd       10,s
                    beq       MemCopyDone
                    lsra
                    rorb
                    tfr       d,x
                    bhs       MemCopyLoop
                    lda       ,y+
                    sta       ,u+
MemCopyLoop         ldd       ,y++
                    std       ,u++
                    leax      -1,x
                    bne       MemCopyLoop
MemCopyDone         puls      y,u,pc
* Microware C long add: stacked long + long at X -> accumulator $0343,y; pops the operand, X = accumulator
LongAdd             ldd       4,s
                    addd      2,x
                    std       >$0345,y
                    ldd       2,s
                    adcb      1,x
                    adca      ,x
                    std       >$0343,y
                    bra      LongPopArg
                    fcb       $EC,$64,$A3,$02,$ED,$A9,$03,$45
                    fcb       $EC,$62,$E2,$01,$A2,$84,$ED,$A9
                    fcb       $03,$43,$16,$00,$67
* sign-extend D into the long accumulator at $0343,y; X = accumulator
LongFromInt         leax      >$0343,y
                    std       2,x
                    tfr       a,b
                    sex
                    tfr       a,b
                    std       ,x
                    rts
                    fcb       $30,$A9,$03,$43,$ED,$02,$6F,$84
                    fcb       $6F,$01,$39
* copy the long at X to the stacked destination pointer (popped); X = destination
LongStore           pshs      y
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
* load the long at the stacked pointer into the accumulator and shift it left B times; pops the pointer, X = accumulator
LongShl             ldx       2,s
                    pshs      b
                    bsr      LongLoad
                    puls      b
                    tstb
                    beq       LongShlDone
LongShlLoop         asl       3,x
                    rol       2,x
                    rol       1,x
                    rol       ,x
                    decb
                    bne       LongShlLoop
LongShlDone         puls      a,b
                    std       ,s
                    rts
                    fcb       $AE,$62,$34,$04,$17,$00,$24,$35
                    fcb       $04,$5D,$27,$0B,$67,$84,$66,$01
                    fcb       $66,$02,$66,$03,$5A,$26,$F5,$35
                    fcb       $06,$ED,$E4,$39
* shared epilog: pop the stacked long operand, X = accumulator, CC preserved
LongPopArg          tfr       cc,a
                    puls      x
                    stx       2,s
                    leas      2,s
                    leax      >$0343,y
                    tfr       a,cc
                    rts
* copy the long at X into the accumulator; X = accumulator
LongLoad            ldd       ,x
                    std       >$0343,y
                    ldd       2,x
                    leax      >$0343,y
                    std       2,x
                    rts
* Microware C 16x16 multiply: D * stacked operand -> D (operand popped); one mul when both high bytes are 0
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
* four partial products
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
* signed modulo via the vector $0CCD,y (= DivInt16) and the dividend sign at $0CCC,y; remainder with the dividend's sign; x % 0 returns x - unreferenced
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
* divide by zero: errno = 45 and RaiseSignal(45)
DivByZero           puls      a,b
                    std       ,s
                    ldd       #$002D
                    bra      RaiseSignal
* signed 16-bit divide: stacked dividend / D -> quotient D, remainder X; pops the dividend
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
* negative dividend: negate it and toggle the sign flag
DivNegDividend      ldd       6,s
                    bpl       DivNormalize
                    nega
                    negb
                    sbca      #$00
                    com       1,s
                    std       6,s
* normalize the divisor (shift left until bit 15 is set), A = step count
DivNormalize        lda       #$01
DivNormLoop         inca
                    asl       3,s
                    rol       2,s
                    bpl       DivNormLoop
                    sta       ,s
                    ldd       6,s
                    clr       6,s
                    clr       7,s
* restoring division step
DivLoop             subd      2,s
                    bhs       a44@
                    addd      2,s
                    andcc     #$FE
                    bra       DivShiftIn
a44@                orcc      #$01
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
* quotient to D, remainder to X, dividend popped
DivReturn           ldx       4,s
                    ldd       6,s
                    std       4,s
                    stx       6,s
                    ldx       2,s
                    ldd       4,s
                    leas      6,s
                    rts
* errno ($034F,y) = D, then F$Send signal B to the own process (F$ID)
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
* unlink(name): I$DeletX, A = 2 (data directory)
UnlinkFile          lda       #$02
                    ldx       2,s
                    os9       I$DeletX
                    lbra      CarryToRet
                    fcb       $A6,$63,$10,$3F,$82,$10,$25,$01
                    fcb       $4B,$1F,$89,$4F,$39
* creat(name, mode): I$Create attributes (mode & $24) | $0B; if it exists (E$CEF $DA) and mode bit $80 is clear: I$Open (mode & 7) and truncate with I$SetStt SS.Size 0; returns the path number or -1
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
CreatFail           lbra      ErrReturn
                    fcb       $AE,$62,$A6,$65,$E6,$67,$10,$3F
                    fcb       $83,$25,$F2,$20,$14,$C1,$DA,$26
                    fcb       $EC,$10,$3F,$87,$25,$E7,$AE,$62
                    fcb       $A6,$65,$E6,$67,$10,$3F,$83,$25
                    fcb       $EC
* D = path number from A
RetPathNum          tfr       a,b
                    clra
                    rts
* open(name, mode): path number or -1
OpenPath            ldx       2,s
                    lda       5,s
                    os9       I$Open
                    lblo      ErrReturn
                    tfr       a,b
                    clra
                    rts
* close(path)
ClosePath           lda       3,s
                    os9       I$Close
                    lbra      CarryToRet
* read(path, buf, n): bytes read, 0 at E$EOF ($D3), -1 on another error
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
ReadError           puls      x,y
                    lbra      ErrReturn
ReadPathCount       tfr       y,d
                    puls      x,y,pc
                    fcb       $34,$20,$A6,$65,$AE,$66,$10,$AE
                    fcc       /h4 /
                    fcb       $10,$3F,$8B,$20,$DD
* write(path, buf, n): n, or -1 on error (n == 0 returns 0)
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
* lseek(path, long offset, whence): base 0, SS.Pos (whence 1) or SS.Size (whence 2), else errno $F7; I$Seek; returns X = the new position in the accumulator ($FFFFFFFF on error)
LSeek               pshs      u
                    ldd       10,s
                    bne       LSeekWhence
                    ldu       #$0000
                    ldx       #$0000
                    bra       LSeekDoSeek
LSeekWhence         cmpd      #$0001
                    beq       LSeekFromCur
                    cmpd      #$0002
                    beq       LSeekFromEnd
                    ldb       #$F7
* errno = B, result -1
LSeekError          clra
                    std       >$034F,y
                    ldd       #$FFFF
                    leax      >$0343,y
                    std       ,x
                    std       2,x
                    puls      u,pc
* base = file size (SS.Size)
LSeekFromEnd        lda       5,s
                    ldb       #$02
                    os9       I$GetStt
                    blo       LSeekError
                    bra       LSeekDoSeek
* base = current position (SS.Pos)
LSeekFromCur        lda       5,s
                    ldb       #$05
                    os9       I$GetStt
                    blo       LSeekError
* base X:U + stacked offset (negative -> error) into the accumulator, I$Seek
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
* chdir(name): I$ChgDir, A = 1 (data directory)
ChangeDir           lda       #$01
                    ldx       2,s
                    os9       I$ChgDir
                    bra      CarryToRet
                    fcb       $86,$04,$20,$F4
* errno = B, return -1: error exit of the system-call wrappers
ErrReturn           clra
                    std       >$034F,y
                    ldd       #$FFFF
                    rts
* carry set -> ErrReturn, else 0
CarryToRet          blo       ErrReturn
                    clra
                    clrb
                    rts
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
* The original's 343-byte padding array ("This array is here for a reason") stays commented out:
* nothing references it and the 8 KB overlay ceiling needs the room.
*                    fcc       /1234567890123456789012345678901234567890123456789/
*                    fcb       $00
*                    fcc       / Hi, Lester!  Keep your Hands off my code! -Mike /
*                    fcb       $00
*                    fcc       /1234567890123456789012345678901234567890123456789/
*                    fcb       $00
*                    fcc       / This array is here for a reason. You are one hel/
*                    fcb       $00
*                    fcc       /l of a C hacker if you figure out what that is!  /
*                    fcb       $00
*                    fcc       /1234567890123456789012345678901234567890123456789/
*                    fcb       $00
*                    fcc       /1234567890123456789012345678901234567890123456/
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
                    fcc       /s9d/
                    fcb       $00


strScoreExt         fcc       /.scr/
                    fcb       0
strExtLyr           fcc       /.lyr/
                    fcb       0
strExtMus           fcc       /.mus/
                    fcb       0
strExtOrc           fcc       /.orc/
                    fcb       0
strExtAsc           fcc       /.asc/
                    fcb       0
OrcReadScore        ldd       #'O                 Orchestra-90 music language (s9o)
                    bra       ImportReadScore
MusicaReadScore     ldd       #'F
                    bra       ImportReadScore
LyraReadScore       ldd       #'Y
                    bra       ImportReadScore
MidiReadScore       ldd       #'I
ImportReadScore     pshs      d
                    ldd       2,s
                    pshs      d
                    ldd       #'i
                    pshs      d
                    ldd       4,s                 the importer letter: soowee(letter, 'i', path)
                    pshs      d
                    jsr       [>UmeData_psoowee]
                    leas      8,s                 three C arguments plus saved importer ID
                    pshs      d
                    ldd       2,s
                    pshs      d
                    lbsr      ClosePath
                    leas      2,s
                    puls      d
                    cmpd      #0
                    lbeq      MainReturnZero
* Save the imported score as .ume; never offer the MIDI input as a save target.
                    ldd       >$00C2,s
                    pshs      d
                    lbsr      StrLen
                    leas      2,s
                    ldx       >$00C2,s
                    leax      d,x
                    ldd       #$756D
                    std       -3,x
                    lda       #'e
                    sta       -1,x
                    lbra      MainReturnOne

                    fill      0,$1D00-*           >= $1D00 bytes, so F$Link never puts this overlay in slot 7 (the score page's slot)
                    emod
eom                 equ       *
* s9d must stay within the 8,192-byte overlay ceiling.
                    ifgt      eom-$2000
                    error     s9d exceeds its 8 KB overlay slot
                    endc
                    end
