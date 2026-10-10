********************************************************************
* s9t - Studio-9 find / sort / block overlay, disassembled from the UltiMusE III v10.11.4e
* (OS-9 Level 2) overlay and ported. Routine names are evidence-based readings of the
* original. Local labels read a<n>@, b<n>@ ...: the letter is the label, n the routine it
* belongs to.
* Event pages hold 928 records ($03A0), not the original 1020 ($03FC), so a page fits the
* $1D00 visible bytes of DAT slot 7 (see GPBLKS in s9.asm); RecordPtr carries the constant.
*
* s9 enters at OverlayEntry with a command character: 'g' -> FindCmd(cmdline) implements the G
* "go to" command (parses [G|g][ ][+|-][count]<type letter>[number][p<part>], maps the type
* letters to a mark-subtype code plus a match predicate, runs FindNthMatch over the score and
* stores the hit in gind/xgoal/godotind, "None found." otherwise); 's' -> SortNotes(staff,
* from, to) reorders the notes of each chord on one staff and returns the swap count; 'b' ->
* BlockMenu with the keys "dcmpfts ou": d delete block, c copy / m move the [block] to the
* ^ (I) marker, p play block, f fix up a part, t transpose by semitones, s sort notes on a
* staff, o turn the I marker into a Coda mark, u remove all block marks.
* Score records are 8 bytes (byte 0 = part, 0 = mark; 1-2 = time; 5 = staff position ($20 =
* rest) or mark subtype; 6 = accidental code or mark value; 7 = per-note attribute), 928 per
* page: RecordPtr/NextRecord/PrevRecord walk them through s9's page swapper (ppswap) with
* curind, nevents, curevp/database/curptop; length ($0091) is the 32-bit total duration.
* Mark subtypes: 0..6 bar-line family (bytes 3-4 = measure number), 7 two-character text,
* $0B key signature, $0D '[', $0E ']', $0F the I marker, $11-$14 D.C./D.S. ($11 + 2*DS +
* skip repeats), $1E-$21 event marks.
* Transposition is diatonic: SemisToKeySig ((n*7) mod 12, circle of fifths), KeySigLetterOfs and
* BuildKeyAccidTbl (F C G D A E B order) derive the new key and its accidentals, TransposeRange
* rewrites staff positions and accidental codes via tblAccidSemis/tblSemisAccid, TransposeBlock
* finds or inserts key-signature records around the block.
* s9's services are reached through the UmeData_p* vectors (equates.asm). Local C-library
* copies: AtoI, StrCopy, StrChr, MulInt16, ModInt (with UDivCore), ShiftLeft16, IntToLong/
* LongAdd/LongStore, CopyRecord, SelectWindow.
* The eleven G-command predicates (PredMarkCode ... PredMeasureNum) are code kept as fcb bytes:
* each starts with pshs u and ends in PredRet0/PredRet1, and FindNthMatch calls them through
* jsr [<$11,s]. UDivCore is likewise code. Other unlabeled fcb/fcc runs are bytes kept from
* the original with no known use.
*
* header: type/lang $11 attr/rev $81, data size $104F (4175)

                    nam       s9t
                    ttl       s9t (disassembly)

                  IFP1
                    use       defsfile
                  ENDC
UME_SCOPE_S9T                  equ       1
                    use       equates.asm

tylg                set       $11
atrv                set       $81
size                equ       $104F

                    mod       eom,name,tylg,atrv,start,size
name                fcs       /s9t/
                    fcb       $07
start               equ       *
                    lbra      OverlayEntry
                    fcb       $39,$0D,$00
* OverlayEntry: the low byte of the first argument is the command char: 'g' FindCmd(cmdline), 's' SortNotes(staff, from, to), 'b' BlockMenu(); returns 0 otherwise
OverlayEntry        pshs      u
                    ldb       5,s
                    sex
                    tfr       d,x
                    bra       EntryDispatch
* EntryFind: 'g' arm: FindCmd(command-line pointer 6,s), then returns 0 via PredRet0
EntryFind           ldd       6,s
                    pshs      a,b
                    lbsr      FindCmd
                    leas      2,s
                    lbra      PredRet0
* EntrySort: 's' arm: SortNotes(staff, from, to) with the three word arguments; returns its swap count
EntrySort           ldd       10,s
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    lbsr      SortNotes
                    leas      6,s
                    puls      u,pc
* EntryBlock: 'b' arm: BlockMenu, returning its changed flag
EntryBlock          lbsr      BlockMenu
                    puls      u,pc
* EntryDispatch: command-character switch of OverlayEntry; anything else returns 0
EntryDispatch       cmpx      #$0067
                    beq       EntryFind
                    cmpx      #$0073
                    beq       EntrySort
                    cmpx      #$0062
                    beq       EntryBlock
                    lbra      PredRet0
* BeepIfSound: when the sound-on flag $03C3 is set, calls s9's beep vector pbeep; bad keys in FindCmd and BlockMenu
BeepIfSound         pshs      u
                    ldb       >UmeData_reserved_03C3
                    beq       a1@
                    jsr       [>UmeData_pbeep]
a1@                 puls      u,pc
* PredMarkCode: default G-command predicate (code kept as fcb): returns 1 for a mark (byte 0 == 0) whose subtype byte 5 equals the code argument; selected at n4@
PredMarkCode        fcb       $34,$40,$E6,$F8,$04,$10,$26,$02
                    fcb       $D5,$AE,$64,$E6,$05,$1D,$10,$A3
                    fcb       $66,$10,$26,$02,$C9,$CC,$00,$01
                    fcb       $16,$02,$C5
* PredTextMarks: G 'x' predicate (code kept as fcb): mark whose subtype is $17,$18,$19,$22,$1A,$1C or $1D (the i/v/t/^/g/<>/r mark codes); the bytes after it hold the wildcard char-compare helpers used by PredTwoCharMark
PredTextMarks       fcb       $34,$40,$E6,$F8,$04,$10,$26,$02
                    fcb       $BA,$AE,$64,$E6,$05,$1D,$1F,$03
                    fcb       $11,$83,$00,$17,$27,$26,$11,$83
                    fcb       $00,$18,$27,$20,$11,$83,$00,$19
                    fcb       $27,$1A,$11,$83,$00,$22,$27,$14
                    fcb       $11,$83,$00,$1A,$27,$0E,$11,$83
                    fcb       $00,$1C,$27,$08,$11,$83,$00,$1D
                    fcb       $10,$26,$02,$87,$CC,$00,$01,$16
                    fcb       $02,$83,$34,$40,$E6,$67,$C1,$2A
                    fcb       $10,$27,$02,$7B,$E6,$67,$C1,$3F
                    fcb       $26,$0C,$E6,$65,$10,$27,$02,$6B
                    fcb       $CC,$00,$01,$16,$02,$67,$E6,$65
                    fcb       $1D,$34,$06,$E6,$69,$1D,$10,$A3
                    fcb       $E1,$10,$26,$02,$56,$CC,$00,$01
                    fcb       $16,$02
                    fcs       /R4@f/
                    fcb       $69,$10,$27,$02,$4C,$E6,$69,$1D
                    fcb       $34,$06,$E6,$67,$1D,$34,$06,$8D
                    fcb       $BB,$32,$64,$10,$27,$02,$36,$E6
                    fcb       $69,$C1
                    fcs       /*&0f/
                    fcb       $6B,$10,$27,$02,$2E,$E6,$6B,$1D
                    fcb       $34,$06,$E6,$67,$1D,$34,$06,$17
                    fcb       $FF,$9C
                    fcc       /2d&/
                    fcb       $13,$E6,$6B,$1D,$34,$06,$E6,$69
                    fcb       $1D,$34,$06,$17,$FF,$8B,$32,$64
                    fcb       $10,$27,$02,$06,$CC,$00,$01,$16
                    fcb       $02,$02,$E6,$6B,$1D,$34,$06,$E6
                    fcb       $69,$1D,$34,$06,$17,$FF
                    fcs       /r2d5@/
* PredTwoCharMark: G 'l' and ';' predicate (code kept as fcb): mark with subtype 7 whose bytes 3 and 6 match the two packed characters of the code (built with ShiftLeft16 <<8) through the '*'/'?' wildcard compare
PredTwoCharMark     fcb       $34,$40,$E6,$F8,$04,$10,$26,$01
                    fcb       $E6,$AE,$64,$E6,$05,$C1,$07,$10
                    fcb       $26,$01,$DC,$EC,$66,$4F,$C4,$7F
                    fcb       $34,$06,$EC,$68,$34,$06,$CC,$00
                    fcb       $08,$17,$19,$B9,$4F,$C4,$7F,$34
                    fcb       $06,$AE,$68,$E6,$06,$1D,$34,$06
                    fcb       $AE,$6A,$E6,$03,$1D,$34,$06,$17
                    fcb       $FF
                    fcs       /e2h5@/
* PredAnyNote: G 'p'/'P' predicate (code kept as fcb): returns 1 when byte 0 (part) > 0, i.e. any note record; installed at a9@
PredAnyNote         fcb       $34,$40,$E6,$F8,$04,$10,$2F,$01
                    fcb       $A8,$CC,$00,$01,$16,$01,$A4
* PredArticNote: G 'a' predicate (code kept as fcb): note, not a rest, articulation byte 7 neither 0 (tied) nor 2 (normal)
PredArticNote       fcb       $34,$40,$EE,$64,$E6,$C4,$10,$2F
                    fcb       $01,$98,$E6,$45,$C1,$20,$10,$27
                    fcb       $01,$90,$E6,$47,$C1,$02,$10,$27
                    fcb       $01,$88,$E6,$47,$10,$27,$01,$82
                    fcb       $CC,$00,$01,$16,$01,$7E
* PredTiedNote: G '_' predicate (code kept as fcb): note, not a rest, articulation byte 7 == 0 (tied); the unlabeled helper after it (mark with subtype <= 6) is the bar-line test of PredBarLine and PredMeasureNum
PredTiedNote        fcb       $34,$40,$EE,$64,$E6,$C4,$10,$27
                    fcb       $01,$72,$E6,$45,$C1,$20,$10,$27
                    fcb       $01,$6A,$E6,$47,$10,$26,$01,$64
                    fcb       $CC,$00,$01,$16,$01
                    fcs       /`4@f/
                    fcb       $F8,$04,$10,$26,$01,$55,$AE,$64
                    fcb       $E6,$05,$C1,$06,$10,$2E,$01,$4B
                    fcb       $CC,$00,$01,$16,$01,$47
* PredRepeatBars: G ':' predicate (code kept as fcb): bar-line mark with subtype 1, 3 or 5 = end repeat / start repeat / Nth ending
PredRepeatBars      fcb       $34,$40,$EE,$64,$E6,$C4,$10,$26
                    fcb       $01,$3B,$E6,$45,$C1,$03,$27,$0E
                    fcb       $E6,$45,$C1,$01,$27,$08,$E6,$45
                    fcb       $C1,$05,$10,$26,$01,$27,$CC,$00
                    fcb       $01,$16,$01,$23
* PredDynamicMark: G 'd' predicate (code kept as fcb): mark with subtype $11..$14, the D.C./D.S. family
PredDynamicMark     fcb       $34,$40,$EE,$64,$E6,$C4,$10,$26
                    fcb       $01,$17,$E6,$45,$C1,$11,$10,$2D
                    fcb       $01,$0F,$E6,$45,$C1,$14,$10,$2E
                    fcb       $01,$07,$CC,$00,$01,$16,$01,$03
* PredEndingMarks: G 'e'/'E' predicate (code kept as fcb): mark whose subtype is $1E/$1F/$20/$21, selected by code bits 3..0 ('e' = $0C -> $1E,$1F; 'E' = 3 -> $20,$21)
PredEndingMarks     fcb       $34,$40,$EE,$64,$E6,$C4,$10,$26
                    fcb       $00,$F7,$EC,$66,$4F,$C4,$08,$27
                    fcb       $06,$E6,$45,$C1,$1E,$27,$2B,$EC
                    fcb       $66,$4F,$C4,$04,$27,$06,$E6,$45
                    fcb       $C1,$1F,$27,$1E,$EC,$66,$4F,$C4
                    fcb       $02,$27,$06,$E6,$45,$C1,$20,$27
                    fcb       $11,$EC,$66,$4F,$C4,$01,$10,$27
                    fcb       $00,$C7,$E6,$45,$C1,$21,$10,$26
                    fcb       $00,$BF,$CC,$00,$01,$16,$00,$BB
* PredBarLine: predicate for a bare G/g with no type letter (code kept as fcb): bar-line mark (subtype <= 6, the helper after PredTiedNote) and, when the code (uppercase-G flag) is set, subtype != 0
PredBarLine         fcb       $34,$40,$EC,$64,$34,$06,$17,$FF
                    fcc       /R2b/
                    fcb       $10,$27,$00,$AA,$E6,$67,$27,$08
                    fcb       $AE,$64,$E6,$05,$10,$27,$00,$9E
                    fcb       $CC,$00,$01,$16,$00,$9A
* PredMeasureNum: predicate for 'g <number>' (code kept as fcb): bar-line mark (subtype <= 6) whose word at bytes 3-4 equals the measure number
PredMeasureNum      fcb       $34,$40,$EC,$64,$34,$06,$17,$FF
                    fcc       /12b/
                    fcb       $10,$27,$00,$89,$AE,$64,$EC,$03
                    fcb       $10,$A3,$66,$10,$26,$00,$7E,$CC
                    fcb       $00,$01,$16,$00,$7A
* MatchPartAndNum(rec, num, part, typechar): filter after the predicate in FindNthMatch. part > 0: 'p'/'P' and 'a'/'_' need byte 0 == part and match at once ('P' also rejects rests); others need byte 6 == part. num >= 0: 't'/'r' need byte 3 == num, others byte 7 == num
MatchPartAndNum     pshs      u
                    ldu       4,s
                    ldd       8,s
                    ble       f2@
                    ldb       11,s
                    cmpb      #$70
                    beq       a2@
                    ldb       11,s
                    cmpb      #$50
                    bne       c2@
a2@                 ldb       ,u
                    sex
                    cmpd      8,s
                    lbne      PredRet0
                    ldb       11,s
                    cmpb      #$70
                    beq       b2@
                    ldb       5,u
                    cmpb      #$20
                    lbeq      PredRet0
b2@                 ldd       #$0001
                    lbra      PredRet
c2@                 ldb       11,s
                    cmpb      #$61
                    beq       d2@
                    ldb       11,s
                    cmpb      #$5F
                    bne       e2@
d2@                 ldb       ,u
                    sex
                    cmpd      8,s
                    bne       PredRet0
                    ldd       #$0001
                    bra       PredRet
e2@                 ldb       6,u
                    sex
                    cmpd      8,s
                    bne       PredRet0
f2@                 ldd       6,s
                    blt       PredRet1
                    ldb       11,s
                    cmpb      #$74
                    beq       g2@
                    ldb       11,s
                    cmpb      #$72
                    bne       h2@
g2@                 ldb       3,u
                    sex
                    cmpd      6,s
                    bne       PredRet0
                    ldd       #$0001
                    bra       PredRet
h2@                 ldb       7,u
                    sex
                    cmpd      6,s
                    beq       PredRet1
* PredRet0: shared 'return 0' exit of the predicates, MatchPartAndNum and OverlayEntry
PredRet0            clra
                    clrb
* PredRet: shared return (puls u,pc) with D already set
PredRet             puls      u,pc
* PredRet1: shared 'return 1' exit of the predicates
PredRet1            ldd       #$0001
                    puls      u,pc
* ParseNumArg(char **cursor, int dflt): when **cursor is a digit, AtoI it and advance the cursor by 1-3 digits (n > 9, n > 99); else returns dflt
ParseNumArg         pshs      u
                    leas      -1,s
                    ldx       5,s
                    ldb       [,x]
                    stb       ,s
                    cmpb      #$30
                    blt       b3@
                    ldb       ,s
                    cmpb      #$39
                    bgt       b3@
                    ldd       [<$05,s]
                    addd      #$0001
                    std       [<$05,s]
                    subd      #$0001
                    pshs      a,b
                    lbsr      AtoI
                    leas      2,s
                    std       7,s
                    cmpd      #$0009
                    ble       a3@
                    ldd       [<$05,s]
                    addd      #$0001
                    std       [<$05,s]
a3@                 ldd       7,s
                    cmpd      #$0063
                    ble       b3@
                    ldd       [<$05,s]
                    addd      #$0001
                    std       [<$05,s]
b3@                 ldd       7,s
                    leas      1,s
                    puls      u,pc
* FindCmd(cmdline): the G 'go to' command: parses the command line ('G' vs 'g', ' ' repeats the spec saved at $07DF, '.'/'u' returns to godotind, +/- direction, count, type letter, number, p<part>), picks predicate + subtype code, runs FindNthMatch and reports
FindCmd             pshs      u
                    leas      <-$14,s
                    ldx       #$01A6
                    stx       ,s
                    clra
                    clrb
                    std       10,s
                    ldd       #$FFFF
                    std       8,s
                    ldd       #$0001
                    std       12,s
* FindParseLoop: takes the command char, exits on NUL/CR, notes an uppercase 'G'; a space copies the saved spec back and re-parses
FindParseLoop       ldd       <$18,s
                    std       ,s
                    tfr       d,x
                    ldb       ,x
                    stb       7,s
                    beq       a4@
                    ldb       7,s
                    cmpb      #$0D
                    bne       b4@
a4@                 leas      <$14,s
                    puls      u,pc
b4@                 ldb       7,s
                    cmpb      #$47
                    bne       c4@
                    ldd       #$0001
                    bra       d4@
c4@                 clra
                    clrb
d4@                 stb       4,s
                    ldx       ,s
                    leax      1,x
                    stx       ,s
                    ldb       ,x
                    stb       6,s
                    cmpb      #$20
                    bne       e4@
                    ldx       #$07DF
                    pshs      x
                    ldd       <$1A,s
                    pshs      a,b
                    lbsr      StrCopy
                    leas      4,s
                    bra       FindParseLoop
e4@                 ldb       6,s
                    cmpb      #$2E
                    beq       f4@
                    ldb       6,s
                    cmpb      #$75
                    bne       g4@
f4@                 ldd       <UmeData_godotind
                    std       <$12,s
                    clra
                    clrb
                    lbra      FindGotoDirect
g4@                 ldd       <$18,s
                    pshs      a,b
                    ldx       #$07DF
                    pshs      x
                    lbsr      StrCopy
                    leas      4,s
                    ldb       6,s
                    cmpb      #$2B
                    bne       h4@
                    ldd       #$0001
                    bra       j4@
h4@                 ldb       6,s
                    cmpb      #$2D
                    bne       i4@
                    ldd       #$FFFF
                    bra       j4@
i4@                 clra
                    clrb
j4@                 std       2,s
                    beq       k4@
                    ldx       ,s
                    leax      1,x
                    stx       ,s
                    ldb       ,x
                    stb       6,s
k4@                 ldb       6,s
                    cmpb      #$30
                    blt       n4@
                    ldb       6,s
                    cmpb      #$39
                    bgt       n4@
                    ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    pshs      a,b
                    lbsr      AtoI
                    leas      2,s
                    std       12,s
                    cmpd      #$0009
                    ble       l4@
                    ldd       ,s
                    addd      #$0001
                    std       ,s
l4@                 ldd       12,s
                    cmpd      #$0063
                    ble       m4@
                    ldd       ,s
                    addd      #$0001
                    std       ,s
m4@                 ldd       12,s
                    cmpd      #$03E7
                    ble       n4@
                    ldd       ,s
                    addd      #$0001
                    std       ,s
n4@                 leau      >PredMarkCode,pcr
                    ldx       ,s
                    leax      1,x
                    stx       ,s
                    ldb       -1,x
                    stb       5,s
                    sex
                    tfr       d,x
                    lbra      FindTypeSwitch
* FindNoTypeChar: no type letter: count 0 without a direction goes to event 0; 'g' with a number selects PredMeasureNum (measure n); otherwise PredBarLine with the uppercase flag as code
FindNoTypeChar      ldd       2,s
                    bne       b5@
                    ldd       12,s
                    bne       a5@
                    clra
                    clrb
                    std       <$12,s
                    bra       FindGotoDirect
a5@                 ldb       4,s
                    bne       b5@
                    leau      >PredMeasureNum,pcr
                    ldd       12,s
                    lbra      FindSetCode
b5@                 leau      >PredBarLine,pcr
                    ldb       4,s
                    sex
                    lbra      FindSetCode
* FindArmLeftMarker: '[' arm: subtype $0D left block marker, screen hint 0, then FindRunSearch
FindArmLeftMarker   ldd       #$000D
                    std       <$10,s
                    clra
                    clrb
                    bra       c5@
* FindArmRightMarker: ']' arm: subtype $0E right block marker, screen hint $4F, then FindRunSearch
FindArmRightMarker  ldd       #$000E
                    std       <$10,s
                    ldd       #$004F
                    bra       c5@
* FindArmToMarker: '|' and '!' arms: subtype $0F, the ^ (I) marker, screen hint $29
FindArmToMarker     ldd       #$000F
                    std       <$10,s
                    ldd       #$0029
c5@                 std       14,s
                    lbra      FindRunSearch
* FindArmEndScore: '*' arm: index = nevents-1 (last record), hint $46; no search
FindArmEndScore     ldd       <UmeData_nevents
                    addd      #$FFFF
                    std       <$12,s
                    ldd       #$0046
* FindGotoDirect: shared tail of '*', the '.'/'u' undo and the bare goto: stores the hint and reports, no search
FindGotoDirect      std       14,s
                    leax      <$14,s
                    lbra      FindReportEntry
* FindArmArticulation: 'a' arm: installs PredArticNote, then the p/P part scan via FindPartScanEntry
FindArmArticulation leau      >PredArticNote,pcr
                    bra       d5@
* FindArmTie: '_' arm: installs PredTiedNote, then the p/P part scan via FindPartScanEntry
FindArmTie          leau      >PredTiedNote,pcr
                    bra       d5@
* FindArmAnyExpr: 'x' arm: installs PredTextMarks (any eXpression), then the p/P part scan
FindArmAnyExpr      leau      >PredTextMarks,pcr
d5@                 leax      <$14,s
                    lbra      FindPartScanEntry
* FindArmInstr: 'i' arm: subtype $17 instrument mark, value# and p# via FindCodeWithNum
FindArmInstr        ldd       #$0017
                    bra       e5@
* FindArmVolLevel: 'v' arm: subtype $18 volume level mark, value# and p# via FindCodeWithNum
FindArmVolLevel     ldd       #$0018
                    bra       e5@
* FindArmMidiChan: 'h' and 'm' arms: subtype $16 MIDI channel mark, value# and p# follow
FindArmMidiChan     ldd       #$0016
e5@                 std       <$10,s
                    leax      <$14,s
                    lbra      FindCodeWithNum
* FindArmTempo: 't' arm: subtype $19 tempo mark, optional value# through FindCodeNumEntry
FindArmTempo        ldd       #$0019
                    lbra      FindCodeNumEntry
* FindArmRitAccel: 'r' arm: subtype $1D rit/accel mark, optional value# through FindCodeNumEntry
FindArmRitAccel     ldd       #$001D
                    lbra      FindCodeNumEntry
* FindArmTimeSig: '/' arm: subtype $0A time signature (s9e CaseMeter writes 10), FindSetCode
FindArmTimeSig      ldd       #$000A
                    lbra      FindSetCode
* FindArmKeySig: 'k' arm: subtype $0B key signature (s9e CaseKeySig writes 11), FindSetCode
FindArmKeySig       ldd       #$000B
                    lbra      FindSetCode
* FindArmEventMark: 'e' arm: PredEndingMarks code $0C = subtypes $1E/$1F
FindArmEventMark    leau      >PredEndingMarks,pcr
                    ldd       #$000C
                    lbra      FindSetCode
* FindArmEventAlt: 'E' arm: same predicate, code $03 = subtypes $20/$21
FindArmEventAlt     leau      >PredEndingMarks,pcr
                    ldd       #$0003
                    lbra      FindSetCode
* FindArmNthEnding: 'n' arm: bar-line subtype $05, Nth ending (s9e CaseEndingNo writes 5)
FindArmNthEnding    ldd       #$0005
                    lbra      FindSetCode
* FindArmFine: 'f' arm: bar-line subtype $06, Fine (s9e CaseFine writes 6)
FindArmFine         ldd       #$0006
                    lbra      FindSetCode
* FindArmCoda: 'o' arm: subtype $09, Coda label (s9e CaseCoda writes 9)
FindArmCoda         ldd       #$0009
                    lbra      FindSetCode
* FindArmSign: '$' and 's' arms: subtype $08, the Sign/Segno (s9e CaseSegno writes 8)
FindArmSign         ldd       #$0008
                    lbra      FindSetCode
* FindArmDcOrDs: 'd' arm: PredDynamicMark, subtypes $11-$14 = D.C./D.S. (s9e CaseDaCapo)
FindArmDcOrDs       leau      >PredDynamicMark,pcr
                    lbra      FindRunSearch
* FindArmClockMark: 'c' arm: subtype $1B, the MIDI clock on/off mark, then FindSetCode
FindArmClockMark    ldd       #$001B
                    lbra      FindSetCode
* FindArmAccent: '^' arm: subtype $22, the accent/tenuto mark, then FindSetCode
FindArmAccent       ldd       #$0022
                    lbra      FindSetCode
* FindArmLabel: 'l' arm: PredTwoCharMark; packs the next two chars as (c1<<8)|c2 into the code
FindArmLabel        leau      >PredTwoCharMark,pcr
                    ldx       ,s
                    leax      1,x
                    stx       ,s
                    ldb       -1,x
                    sex
                    std       <$10,s
                    pshs      a,b
                    ldd       #$0008
                    lbsr      ShiftLeft16
                    pshs      a,b
                    ldx       2,s
                    leax      1,x
                    stx       2,s
                    ldb       -1,x
                    clra
                    bra       f5@
* FindArmLabelAlt: ';' arm: the same two-char label pack, with bit 7 masked off the second character
FindArmLabelAlt     leau      >PredTwoCharMark,pcr
                    ldx       ,s
                    leax      1,x
                    stx       ,s
                    ldb       -1,x
                    sex
                    std       <$10,s
                    pshs      a,b
                    ldd       #$0008
                    lbsr      ShiftLeft16
                    pshs      a,b
                    ldx       2,s
                    leax      1,x
                    stx       2,s
                    ldb       -1,x
                    clra
                    andb      #$7F
f5@                 ora       ,s+
                    orb       ,s+
* FindSetCode: common tail of the simple type letters: stores the subtype code and jumps to FindRunSearch
FindSetCode         std       <$10,s
                    lbra      FindRunSearch
* FindArmRepeats: ':' arm: installs PredRepeatBars and runs the search with no subtype code
FindArmRepeats      leau      >PredRepeatBars,pcr
                    lbra      FindRunSearch
* FindArmGenLevel: 'g' arm: subtype $1A general volume level, falls into FindCodeNumEntry
FindArmGenLevel     ldd       #$001A
* FindCodeNumEntry: shared tail of the t/r/g arms: stores the subtype, then FindCodeNum reads the value#
FindCodeNumEntry    std       <$10,s
                    leax      <$14,s
                    bra       a6@
* FindArmCrescDim: '<' and '>' arms: subtype $1C cresc/dim, then FindCodeNum for the value#
FindArmCrescDim     ldd       #$001C
                    std       <$10,s
                    bra       FindCodeNum
a6@                 leas      <-$14,x
* FindCodeNum: arm for t/r/g/<> marks: ParseNumArg into the number slot, then the search
FindCodeNum         ldd       #$FFFF
                    pshs      a,b
                    leax      2,s
                    pshs      x
                    lbsr      ParseNumArg
                    leas      4,s
                    std       8,s
                    lbra      FindRunSearch
* FindCodeWithNum: arm for i/v/h/m marks: ParseNumArg into the number slot, then a trailing p/P part spec
FindCodeWithNum     leas      <-$14,x
                    ldd       #$FFFF
                    pshs      a,b
                    leax      2,s
                    pshs      x
                    lbsr      ParseNumArg
                    leas      4,s
                    std       8,s
                    bra       a7@
* FindPartScanEntry: stack-normalizing entry into the p/P part scan of FindCodeWithNum, used by the a/_/x arms
FindPartScanEntry   leas      <-$14,x
a7@                 ldx       ,s
                    leax      1,x
                    stx       ,s
                    ldb       -1,x
                    cmpb      #$70
                    beq       FindParsePart
                    ldb       [,s]
                    cmpb      #$50
                    lbne      FindRunSearch
* FindParsePart: the part after p/P ('1'-'9' with an optional second digit, 'a'-'g' = 10..16, else 1) into the part slot
FindParsePart       ldx       ,s
                    leax      1,x
                    stx       ,s
                    ldb       -1,x
                    stb       7,s
                    cmpb      #$31
                    blt       a8@
                    ldb       7,s
                    cmpb      #$39
                    bgt       a8@
                    ldb       7,s
                    sex
                    addd      #$FFD0
                    std       10,s
                    ldb       [,s]
                    stb       7,s
                    cmpb      #$30
                    lblt      FindRunSearch
                    ldb       7,s
                    cmpb      #$39
                    lbgt      FindRunSearch
                    ldd       10,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      MulInt16
                    pshs      a,b
                    ldb       9,s
                    sex
                    addd      #$FFD0
                    addd      ,s++
                    bra       c8@
a8@                 ldb       7,s
                    cmpb      #$61
                    blt       b8@
                    ldb       7,s
                    cmpb      #$67
                    bgt       b8@
                    ldb       7,s
                    sex
                    addd      #$FFA9
                    bra       c8@
b8@                 ldd       #$0001
c8@                 std       10,s
                    lbra      FindRunSearch
* FindBadType: unknown type letter: BeepIfSound and leave
FindBadType         lbsr      BeepIfSound
                    lbra      FindCmdExit
* FindTypeSwitch: type-letter switch of FindCmd: NUL, [ ] | ! * a _ x i v h m t r / k e E n f o $ s d c ^ l ; : g < > p P each set a subtype code and/or predicate
FindTypeSwitch      stx       -2,s
                    lbeq      FindNoTypeChar
                    cmpx      #$005B
                    lbeq      FindArmLeftMarker
                    cmpx      #$005D
                    lbeq      FindArmRightMarker
                    cmpx      #$007C
                    lbeq      FindArmToMarker
                    cmpx      #$0021
                    lbeq      FindArmToMarker
                    cmpx      #$002A
                    lbeq      FindArmEndScore
                    cmpx      #$0061
                    lbeq      FindArmArticulation
                    cmpx      #$005F
                    lbeq      FindArmTie
                    cmpx      #$0078
                    lbeq      FindArmAnyExpr
                    cmpx      #$0069
                    lbeq      FindArmInstr
                    cmpx      #$0076
                    lbeq      FindArmVolLevel
                    cmpx      #$0068
                    lbeq      FindArmMidiChan
                    cmpx      #$006D
                    lbeq      FindArmMidiChan
                    cmpx      #$0074
                    lbeq      FindArmTempo
                    cmpx      #$0072
                    lbeq      FindArmRitAccel
                    cmpx      #$002F
                    lbeq      FindArmTimeSig
                    cmpx      #$006B
                    lbeq      FindArmKeySig
                    cmpx      #$0065
                    lbeq      FindArmEventMark
                    cmpx      #$0045
                    lbeq      FindArmEventAlt
                    cmpx      #$006E
                    lbeq      FindArmNthEnding
                    cmpx      #$0066
                    lbeq      FindArmFine
                    cmpx      #$006F
                    lbeq      FindArmCoda
                    cmpx      #$0024
                    lbeq      FindArmSign
                    cmpx      #$0073
                    lbeq      FindArmSign
                    cmpx      #$0064
                    lbeq      FindArmDcOrDs
                    cmpx      #$0063
                    lbeq      FindArmClockMark
                    cmpx      #$005E
                    lbeq      FindArmAccent
                    cmpx      #$006C
                    lbeq      FindArmLabel
                    cmpx      #$003B
                    lbeq      FindArmLabelAlt
                    cmpx      #$003A
                    lbeq      FindArmRepeats
                    cmpx      #$0067
                    lbeq      FindArmGenLevel
                    cmpx      #$003C
                    lbeq      FindArmCrescDim
                    cmpx      #$003E
                    lbeq      FindArmCrescDim
                    cmpx      #$0070
                    lbeq      FindParsePart
                    cmpx      #$0050
                    lbeq      FindParsePart
                    lbra      FindBadType
* FindRunSearch: p/P switch to PredAnyNote; with a direction, FindNthMatch from lftind toward ritind (count 400 forward, 1 backward); then FindNthMatch toward the score end or start with the typed count; screen hint 0 forward, $4F backward, $3C at the last record
FindRunSearch       ldb       5,s
                    cmpb      #$70
                    beq       a9@
                    ldb       5,s
                    cmpb      #$50
                    bne       b9@
a9@                 leau      >PredAnyNote,pcr
b9@                 ldd       2,s
                    beq       e9@
                    ldb       5,s
                    sex
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    ldd       <$16,s
                    pshs      a,b
                    pshs      u
                    ldd       12,s
                    ble       c9@
                    ldd       #$0190
                    bra       d9@
c9@                 ldd       #$0001
d9@                 pshs      a,b
                    ldd       <UmeData_ritind
                    pshs      a,b
                    ldd       <UmeData_lftind
                    pshs      a,b
                    lbsr      FindNthMatch
                    leas      <$10,s
                    std       <$12,s
                    bge       g9@
                    ldd       <UmeData_lftind
                    bra       f9@
e9@                 clra
                    clrb
f9@                 std       <$12,s
g9@                 ldb       5,s
                    sex
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    ldd       <$16,s
                    pshs      a,b
                    pshs      u
                    ldd       <$16,s
                    pshs      a,b
                    ldd       14,s
                    bge       h9@
                    clra
                    clrb
                    bra       i9@
h9@                 ldd       <UmeData_nevents
                    addd      #$FFFF
i9@                 pshs      a,b
                    ldd       <$20,s
                    pshs      a,b
                    lbsr      FindNthMatch
                    leas      <$10,s
                    std       <$12,s
                    ldd       2,s
                    bge       k9@
                    ldb       5,s
                    cmpb      #$20
                    bne       j9@
                    ldd       12,s
                    bne       k9@
j9@                 ldd       #$004F
                    bra       l9@
k9@                 clra
                    clrb
l9@                 std       14,s
                    ldd       <UmeData_nevents
                    addd      #$FFFF
                    cmpd      <$12,s
                    bne       FindReport
                    ldd       #$003C
                    std       14,s
                    bra       FindReport
* FindReportEntry: stack-normalizing entry into FindReport, from FindGotoDirect
FindReportEntry     leas      <-$14,x
* FindReport: index < 0 alerts msgNoneFound, else gind = index, xgoal = hint, godotind = old lftind, rfr_scr = 1
FindReport          ldd       <$12,s
                    bge       a10@
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgNoneFound,pcr
                    pshs      x
                    jsr       [>UmeData_palert]
                    leas      4,s
                    bra       FindCmdExit
a10@                ldd       <$12,s
                    std       <UmeData_gind
                    ldd       14,s
                    std       <UmeData_xgoal
                    ldd       <UmeData_lftind
                    std       <UmeData_godotind
                    ldd       #$0001
                    stb       <UmeData_rfr_scr
* FindCmdExit: FindCmd frame release; FindBadType and the 'None found.' path branch here
FindCmdExit         leas      <$14,s
                    puls      u,pc
* FindNthMatch(from, to, count, pred, code, num, part, typechar): walks records from 'from' toward 'to' with NextRecord/PrevRecord calling pred(rec, code) via jsr [<$11,s] and MatchPartAndNum; a match at 'from' (from != 0) does not count; returns the index of the count-th match, else the last match, else -1
FindNthMatch        pshs      u
                    leas      -3,s
                    ldd       7,s
                    pshs      a,b
                    lbsr      RecordPtr
                    leas      2,s
                    tfr       d,u
                    ldd       #$FFFF
                    std       1,s
                    ldd       7,s
                    beq       a11@
                    ldd       15,s
                    pshs      a,b
                    pshs      u
                    jsr       [<$11,s]
                    leas      4,s
                    beq       a11@
                    ldb       <$16,s
                    sex
                    pshs      a,b
                    ldd       <$15,s
                    pshs      a,b
                    ldd       <$15,s
                    pshs      a,b
                    pshs      u
                    lbsr      MatchPartAndNum
                    leas      8,s
                    beq       a11@
                    ldd       11,s
                    addd      #$0001
                    std       11,s
a11@                ldd       9,s
                    cmpd      7,s
                    bgt       b11@
                    ldd       #$0001
                    bra       c11@
b11@                clra
                    clrb
c11@                stb       ,s
                    bra       FindMatchTest
* FindMatchLoop: tests the current record, on a match decrements the count and remembers curind, steps to the next/previous record
FindMatchLoop       ldd       15,s
                    pshs      a,b
                    pshs      u
                    jsr       [<$11,s]
                    leas      4,s
                    beq       a12@
                    ldb       <$16,s
                    sex
                    pshs      a,b
                    ldd       <$15,s
                    pshs      a,b
                    ldd       <$15,s
                    pshs      a,b
                    pshs      u
                    lbsr      MatchPartAndNum
                    leas      8,s
                    beq       a12@
                    ldd       11,s
                    addd      #$FFFF
                    std       11,s
                    ldd       <UmeData_curind
                    std       1,s
a12@                ldb       ,s
                    beq       b12@
                    lbsr      PrevRecord
                    bra       c12@
b12@                lbsr      NextRecord
c12@                tfr       d,u
* FindMatchTest: loops while the count is nonzero and curind is within the limit
FindMatchTest       ldd       11,s
                    beq       h12@
                    ldb       ,s
                    beq       e12@
                    ldd       <UmeData_curind
                    cmpd      9,s
                    blt       f12@
d12@                ldd       #$0001
                    bra       g12@
e12@                ldd       <UmeData_curind
                    cmpd      9,s
                    ble       d12@
f12@                clra
                    clrb
g12@                lbne      FindMatchLoop
h12@                ldd       1,s
                    leas      3,s
                    puls      u,pc
* msgNoneFound: alerted by FindReport when no record matches
msgNoneFound        fcc       /None found./
                    fcb       $00
* SemisToKeySig(semis): key-signature change for a semitone offset: normalize to 0..11, (n*7) mod 12 (circle of fifths), values above 6 become negative (flats)
SemisToKeySig       pshs      a,b,u
                    bra       b13@
a13@                ldd       6,s
                    addd      #$000C
                    std       6,s
b13@                ldd       6,s
                    blt       a13@
                    ldd       6,s
                    pshs      a,b
                    ldd       #$0007
                    lbsr      MulInt16
                    pshs      a,b
                    ldd       #$000C
                    lbsr      ModInt
                    std       ,s
                    cmpd      #$0006
                    ble       c13@
                    ldd       ,s
                    subd      #$000C
                    std       ,s
c13@                ldd       ,s
                    leas      2,s
                    puls      u,pc
* BuildKeyAccidTbl(key, int tbl[7]): clears the table, then marks |key| letters +1 starting at F stepping by fifths (F C G D A E B) for sharps, or -1 starting at B stepping by fourths for flats
BuildKeyAccidTbl    pshs      a,b,x,y,u
                    ldu       12,s
                    ldd       #$0008
                    std       ,s
                    bra       b14@
a14@                clra
                    clrb
                    std       ,u++
b14@                ldd       ,s
                    addd      #$FFFF
                    std       ,s
                    bne       a14@
                    ldd       10,s
                    lbeq      KeyTblDone
                    ldu       12,s
                    ldd       10,s
                    ble       c14@
                    ldd       #$0003
                    std       ,s
                    ldd       #$0004
                    std       4,s
                    ldd       #$0001
                    std       2,s
                    bra       KeyTblNext
c14@                ldd       #$0006
                    std       ,s
                    ldd       #$0003
                    std       4,s
                    ldd       #$FFFF
                    std       2,s
                    ldd       10,s
                    nega
                    negb
                    sbca      #$00
                    std       10,s
                    bra       KeyTblNext
* KeyTblFillLoop: stores +1/-1 at the current letter, advances by 4 or 3 mod 7
KeyTblFillLoop      ldd       ,s
                    aslb
                    rola
                    leax      d,u
                    ldd       2,s
                    std       ,x
                    ldd       ,s
                    addd      4,s
                    std       ,s
                    cmpd      #$0006
                    ble       KeyTblNext
                    ldd       ,s
                    subd      #$0007
                    std       ,s
* KeyTblNext: countdown and test of the accidental count; both setups jump here
KeyTblNext          ldd       10,s
                    addd      #$FFFF
                    std       10,s
                    bge       KeyTblFillLoop
* KeyTblDone: BuildKeyAccidTbl exit; key 0 leaves the table cleared
KeyTblDone          leas      6,s
                    puls      u,pc
* KeySigLetterOfs(key): letter offset of a key signature's tonic: 0 for C, (key*4) mod 7 for sharps, (key*-3) mod 7 for flats; differences give the diatonic step of a transposition
KeySigLetterOfs     pshs      u
                    ldd       4,s
                    bne       a15@
                    clra
                    clrb
                    puls      u,pc
a15@                ldd       4,s
                    ble       b15@
                    ldd       4,s
                    aslb
                    rola
                    aslb
                    rola
                    bra       c15@
b15@                ldd       4,s
                    pshs      a,b
                    ldd       #$FFFD
                    lbsr      MulInt16
c15@                pshs      a,b
                    ldd       #$0007
                    lbsr      ModInt
                    puls      u,pc
                    fcb       $35,$C0
* TransposeRange(start, end, key, semis, writekey): new key = key + SemisToKeySig(semis) folded into -6..6 (msgPrefer6Flats asked at +-6), stored in record[start] byte 6 when writekey; builds the old/new accidental tables and rewrites every note's staff position and accidental
TransposeRange      pshs      u
                    leas      <-$3C,s
                    leax      >msgPrefer6Flats,pcr
                    stx       <$1E,s
                    ldd       <$46,s
                    pshs      a,b
                    lbsr      SemisToKeySig
                    leas      2,s
                    std       14,s
                    ldd       <$44,s
                    addd      14,s
                    std       <$10,s
                    cmpd      #$0006
                    ble       a16@
                    ldd       <$10,s
                    subd      #$000C
                    std       <$10,s
a16@                ldd       <$10,s
                    cmpd      #$0006
                    bne       b16@
                    ldd       <$1E,s
                    pshs      a,b
                    jsr       [>UmeData_pyesno]
                    leas      2,s
                    beq       b16@
                    ldd       #$FFFA
                    bra       d16@
b16@                ldd       <$10,s
                    cmpd      #$FFFA
                    bge       c16@
                    ldd       <$10,s
                    addd      #$000C
                    bra       d16@
c16@                ldd       <$10,s
                    cmpd      #$FFFA
                    bne       e16@
                    ldd       <$1E,s
                    pshs      a,b
                    jsr       [>UmeData_pyesno]
                    leas      2,s
                    bne       e16@
                    ldd       #$0006
d16@                std       <$10,s
e16@                ldb       <$49,s
                    beq       f16@
                    ldd       <$40,s
                    pshs      a,b
                    lbsr      RecordPtr
                    leas      2,s
                    tfr       d,x
                    ldd       <$10,s
                    stb       6,x
f16@                ldd       <$44,s
                    pshs      a,b
                    lbsr      KeySigLetterOfs
                    leas      2,s
                    std       <$18,s
                    ldd       <$10,s
                    pshs      a,b
                    lbsr      KeySigLetterOfs
                    leas      2,s
                    std       <$16,s
                    subd      <$18,s
                    std       <$1C,s
                    ldd       <$46,s
                    ble       g16@
                    ldd       <$1C,s
                    bge       g16@
                    ldd       <$1C,s
                    addd      #$0007
                    bra       h16@
g16@                ldd       <$46,s
                    bge       i16@
                    ldd       <$1C,s
                    ble       i16@
                    ldd       <$1C,s
                    subd      #$0007
h16@                std       <$1C,s
i16@                leax      <$2E,s
                    pshs      x
                    ldd       <$46,s
                    pshs      a,b
                    lbsr      BuildKeyAccidTbl
                    leas      4,s
                    leax      <$20,s
                    pshs      x
                    ldd       <$12,s
                    pshs      a,b
                    lbsr      BuildKeyAccidTbl
                    leas      4,s
                    ldd       <$40,s
                    pshs      a,b
                    lbsr      RecordPtr
                    leas      2,s
                    lbra      TransNoteTest
* TransNoteLoop: skips marks, rests, parts without a clef base and parts flagged $10 (GetPartInfo); shifts the staff position by the letter delta (kept in -11..20); an explicit accidental is recomputed from tblAccidSemis and the old key's table and re-expressed against the new key's table through tblSemisAccid
TransNoteLoop       ldb       ,u
                    lbeq      d17@
                    ldb       5,u
                    cmpb      #$20
                    lbeq      d17@
                    leax      ,s
                    pshs      x
                    leax      4,s
                    pshs      x
                    ldb       ,u
                    sex
                    pshs      a,b
                    lbsr      GetPartInfo
                    leas      6,s
                    std       4,s
                    ldd       2,s
                    lbeq      d17@
                    ldd       ,s
                    clra
                    andb      #$10
                    lbne      d17@
                    ldb       5,u
                    sex
                    std       12,s
                    addd      <$1C,s
                    std       10,s
                    cmpd      #$0014
                    ble       a17@
                    ldd       10,s
                    subd      #$0007
                    bra       b17@
a17@                ldd       10,s
                    cmpd      #$FFF5
                    bge       c17@
                    ldd       10,s
                    addd      #$0007
b17@                std       10,s
c17@                ldd       10,s
                    stb       5,u
                    ldb       6,u
                    sex
                    std       8,s
                    lbeq      d17@
                    ldd       12,s
                    addd      2,s
                    addd      #$FFFF
                    pshs      a,b
                    ldd       #$0007
                    lbsr      ModInt
                    std       <$14,s
                    ldd       10,s
                    addd      2,s
                    addd      #$FFFF
                    pshs      a,b
                    ldd       #$0007
                    lbsr      ModInt
                    std       <$12,s
                    leax      >tblAccidSemis,pcr
                    ldd       8,s
                    leax      d,x
                    ldb       ,x
                    sex
                    std       8,s
                    ldd       <$14,s
                    aslb
                    rola
                    leax      <$2E,s
                    leax      d,x
                    ldd       ,x
                    pshs      a,b
                    ldd       10,s
                    subd      ,s++
                    std       <$1A,s
                    ldd       <$12,s
                    aslb
                    rola
                    leax      <$20,s
                    leax      d,x
                    ldd       ,x
                    addd      <$1A,s
                    std       6,s
                    leax      >tblSemisAccid,pcr
                    tfr       x,d
                    pshs      a,b
                    ldd       8,s
                    addd      #$0002
                    addd      ,s++
                    tfr       d,x
                    ldb       ,x
                    stb       6,u
d17@                lbsr      NextRecord
* TransNoteTest: loops to TransNoteLoop while curind <= end
TransNoteTest       tfr       d,u
                    ldd       <UmeData_curind
                    cmpd      <$42,s
                    lble      TransNoteLoop
                    leas      <$3C,s
                    puls      u,pc
* TransposeBlock(semis): gets the [ ] marks (pfixmarx), finds the key signature in force at '[' (the marks at '[', else scanning backward, else keysig), inserts one at the block start when missing (pfulltime/penter), transposes each key-signature section with TransposeRange and restores the original key after the block
TransposeBlock      pshs      u
                    leas      -14,s
                    ldx       #$01A6
                    stx       10,s
                    leax      6,s
                    pshs      x
                    leax      10,s
                    pshs      x
                    leax      14,s
                    pshs      x
                    jsr       [>UmeData_pfixmarx]
                    leas      6,s
                    lbsr      BeginLongOp
                    ldd       #$FFFF
                    std       6,s
                    ldd       10,s
                    pshs      a,b
                    lbsr      RecordPtr
                    leas      2,s
                    bra       TransKeyFwdTest
* TransFindKeyFwd: scans the marks at '[' for a key-signature mark (subtype $0B), remembering index and key
TransFindKeyFwd     ldb       ,u
                    bne       b18@
                    ldb       5,u
                    cmpb      #$0B
                    bne       a18@
                    ldd       <UmeData_curind
                    std       6,s
                    ldb       6,u
                    sex
                    std       ,s
                    bra       b18@
a18@                lbsr      NextRecord
* TransKeyFwdTest: forward scan test (curind < nevents)
TransKeyFwdTest     tfr       d,u
                    ldd       <UmeData_curind
                    cmpd      <UmeData_nevents
                    blt       TransFindKeyFwd
b18@                ldd       6,s
                    cmpd      #$FFFF
                    lbne      TransKeyReady
                    ldd       10,s
                    pshs      a,b
                    lbsr      RecordPtr
                    leas      2,s
                    bra       TransKeyBackTest
* TransFindKeyBack: scans backward from '[' with PrevRecord for the key signature in force
TransFindKeyBack    ldb       ,u
                    bne       a19@
                    ldb       5,u
                    cmpb      #$0B
                    bne       a19@
                    ldb       6,u
                    sex
                    std       ,s
                    ldd       <UmeData_curind
                    std       6,s
                    bra       b19@
a19@                lbsr      PrevRecord
* TransKeyBackTest: backward scan test (curind >= 0)
TransKeyBackTest    tfr       d,u
                    ldd       <UmeData_curind
                    bge       TransFindKeyBack
b19@                ldd       6,s
                    cmpd      #$FFFF
                    bne       c19@
                    ldd       <UmeData_keysig
                    std       ,s
c19@                ldd       6,s
                    cmpd      #$FFFF
                    beq       TransInsertKeySig
                    ldd       6,s
                    pshs      a,b
                    lbsr      RecordPtr
                    leas      2,s
                    tfr       d,x
                    ldd       1,x
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    lbsr      RecordPtr
                    leas      2,s
                    tfr       d,x
                    ldd       1,x
                    cmpd      ,s++
                    beq       TransKeyReady
* TransInsertKeySig: inserts a key-signature record at the time of '[' (pfulltime, penter); -1 alerts msgNoMemTranspose
TransInsertKeySig   ldd       #$000B
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    jsr       [>UmeData_pfulltime]
                    leas      2,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    jsr       [>UmeData_penter]
                    leas      8,s
                    std       6,s
                    cmpd      #$FFFF
                    bne       a20@
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgNoMemTranspose,pcr
                    pshs      x
                    jsr       [>UmeData_palert]
                    leas      4,s
                    lbra      TransBlockExit
a20@                ldd       8,s
                    addd      #$0001
                    std       8,s
* TransKeyReady: key known: sets the section key and enters TransRangeLoop
TransKeyReady       ldd       ,s
                    std       2,s
                    lbra      TransRangeLoop
* TransNextSection: body of TransRangeLoop: RecordPtr(start+1), then the scan for the next key sig bounding this section
TransNextSection    ldd       6,s
                    addd      #$0001
                    pshs      a,b
                    lbsr      RecordPtr
                    leas      2,s
                    bra       TransNextKeyTest
* TransNextKeyLoop: finds the next key-signature mark inside the block
TransNextKeyLoop    ldb       ,u
                    bne       a21@
                    ldb       5,u
                    cmpb      #$0B
                    bne       a21@
                    ldb       6,u
                    sex
                    std       2,s
                    bra       TransApplyRange
a21@                lbsr      NextRecord
* TransNextKeyTest: loops while curind <= block end
TransNextKeyTest    tfr       d,u
                    ldd       <UmeData_curind
                    cmpd      8,s
                    ble       TransNextKeyLoop
* TransApplyRange: TransposeRange(section start, curind-1, key, semis, 1), then the next section
TransApplyRange     ldd       <UmeData_curind
                    addd      #$FFFF
                    std       4,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       <$14,s
                    pshs      a,b
                    ldd       4,s
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    lbsr      TransposeRange
                    leas      10,s
                    ldd       2,s
                    std       ,s
                    ldd       4,s
                    addd      #$0001
                    std       6,s
* TransRangeLoop: loop over the key-signature sections inside the block; afterwards checks whether a key signature already follows the block
TransRangeLoop      ldd       6,s
                    cmpd      8,s
                    lblt      TransNextSection
                    ldd       6,s
                    pshs      a,b
                    lbsr      RecordPtr
                    leas      2,s
                    tfr       d,x
                    ldd       1,x
                    std       12,s
                    ldd       <UmeData_nevents
                    addd      #$FFFF
                    cmpd      8,s
                    lble      TransBlockExit
                    ldd       <UmeData_nevents
                    addd      #$FFFF
                    pshs      a,b
                    lbsr      RecordPtr
                    leas      2,s
                    tfr       d,x
                    ldd       1,x
                    cmpd      12,s
                    lbeq      TransBlockExit
                    ldd       6,s
                    pshs      a,b
                    lbsr      RecordPtr
                    leas      2,s
                    bra       TransKeyAfterTest
* TransFindKeyAfter: looks for a key-signature mark after the block at the same time
TransFindKeyAfter   ldb       ,u
                    bne       a22@
                    ldb       5,u
                    cmpb      #$0B
                    bne       a22@
                    ldd       <UmeData_curind
                    std       4,s
                    bra       b22@
a22@                lbsr      NextRecord
* TransKeyAfterTest: loops while curind < nevents
TransKeyAfterTest   tfr       d,u
                    ldd       <UmeData_curind
                    cmpd      <UmeData_nevents
                    blt       TransFindKeyAfter
b22@                ldd       <UmeData_curind
                    cmpd      <UmeData_nevents
                    bge       TransRestoreKey
                    ldd       4,s
                    pshs      a,b
                    lbsr      RecordPtr
                    leas      2,s
                    tfr       d,x
                    ldd       1,x
                    cmpd      12,s
                    beq       TransBlockExit
* TransRestoreKey: inserts a key-signature record after the block carrying the original key, so the rest of the score is unchanged
TransRestoreKey     ldd       #$000B
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    jsr       [>UmeData_pfulltime]
                    leas      2,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    jsr       [>UmeData_penter]
                    leas      8,s
                    std       4,s
                    pshs      a,b
                    lbsr      RecordPtr
                    leas      2,s
                    tfr       d,x
                    ldd       ,s
                    stb       6,x
* TransBlockExit: EndPrompt, drop the frame, return
TransBlockExit      lbsr      EndPrompt
                    leas      14,s
                    puls      u,pc
* msgPrefer6Flats: yes/no in TransposeRange when the new key lands on +-6
msgPrefer6Flats     fcc       / Do you prefer 6 Flats to 6 Sharps?/
                    fcb       $00
* tblAccidSemis: 9 bytes indexed by accidental code (record byte 6): 0,0,+1,+2,0,0,-2,-1,0 semitones (2 sharp, 3 double sharp, 6 double flat, 7 flat)
tblAccidSemis       fcb       $00,$00,$01,$02,$00,$00,$FE,$FF
                    fcb       $00
* tblSemisAccid: 6 bytes indexed by semitone offset +2 (-2..+3): 6,7,4,2,3,0 = double flat, flat, natural, sharp, double sharp, none
tblSemisAccid       fcb       $06,$07,$04,$02,$03,$00
* msgNoMemTranspose: TransposeBlock when inserting a key-signature record fails
msgNoMemTranspose   fcc       / Out of memory, no transpose!/
                    fcb       $00
* GetPartInfo(part, int *clefbase, int *flags): an out-of-range part becomes nparts; *flags = word 2 of the parts ($0C5F) entry; *clefbase = word 2 of the clefs ($0162) entry of the part's staff ($0C19, 10-byte entries); returns the staff (word 0)
GetPartInfo         pshs      a,b,u
                    ldd       6,s
                    cmpd      #$0001
                    blt       a23@
                    ldd       6,s
                    cmpd      <UmeData_nparts
                    ble       b23@
a23@                ldd       <UmeData_nparts
                    std       6,s
b23@                ldd       6,s
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
                    lbsr      MulInt16
                    ldx       #$0C19
                    leax      d,x
                    ldd       2,x
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$0162
                    leax      d,x
                    ldd       2,x
                    std       [<$08,s]
                    ldd       ,s
                    leas      2,s
                    puls      u,pc
* PartCharToNum(c): '0'-'9' give 0-9, 'a'-'g' give 10-16, anything else 0 (the 'Part (1 to G)' prompt)
PartCharToNum       pshs      u
                    ldb       5,s
                    sex
                    subd      #$0030
                    stb       5,s
                    blt       a24@
                    ldb       5,s
                    cmpb      #$09
                    bgt       a24@
                    ldb       5,s
                    sex
                    puls      u,pc
a24@                ldb       5,s
                    sex
                    subd      #$0031
                    stb       5,s
                    blt       b24@
                    ldb       5,s
                    cmpb      #$06
                    bgt       b24@
                    ldb       5,s
                    sex
                    addd      #$000A
                    puls      u,pc
b24@                clra
                    clrb
                    puls      u,pc
* BeginLongOp: pprintf(fmt at $0A, $C3, 13) then flush; at the start of TransposeBlock, CmdDeleteBlock and CopyBlockDo, before the long record loops
BeginLongOp         pshs      u
                    ldd       #$000D
                    pshs      a,b
                    ldd       #$00C3
                    pshs      a,b
                    ldd       <UmeData_reserved_000A
                    lbra      Print3Flush
* EndPrompt: pprintf(fmt at $0A, $C7, 13): closes the prompt display after every prompt and at the end of each block operation
EndPrompt           pshs      u
                    ldd       #$000D
                    pshs      a,b
                    ldd       #$00C7
                    pshs      a,b
                    ldd       <UmeData_reserved_000A
                    lbra      Print3Ret
* PrePlayEsc: pprintf(fmt at $16, $83), sent by CmdPlayBlock before the play vector when pldebug is set
PrePlayEsc          pshs      u
                    ldd       #$0083
                    pshs      a,b
                    ldd       <UmeData_reserved_0016
                    pshs      a,b
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    puls      u,pc
* OpenPromptBox(tall): DefWindowEsc($0E, $6E, $32, tall ? 5 : 2, 1, WinStylePaper3D): the prompt area of the semitone, part and staff prompts
OpenPromptBox       pshs      u
                    ldd       #WinStylePaper3D    the paper 3D box
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldb       9,s
                    beq       a25@
                    ldd       #$0005
                    bra       b25@
a25@                ldd       #$0002
b25@                pshs      a,b
                    ldd       #$0032
                    pshs      a,b
                    ldd       #$006E
                    pshs      a,b
                    ldd       #$000E
                    pshs      a,b
                    bsr       DefWindowEsc
                    leas      12,s
                    puls      u,pc
* SelectWindow(n): curcurse = n and pprintf(fmt at $18, $9A, n); BlockMenu selects window 2 and restores the old one
SelectWindow        pshs      u
                    ldd       4,s
                    std       <UmeData_curcurse
                    ldd       4,s
                    pshs      a,b
                    ldd       #$009A
                    pshs      a,b
                    ldd       <UmeData_reserved_0018
* Print3Ret: shared tail: pprintf with three pushed words, return (SelectWindow, EndPrompt)
Print3Ret           pshs      a,b
                    jsr       [>UmeData_pprintf]
                    leas      6,s
                    puls      u,pc
* Print3Flush: shared tail: pprintf with three pushed words, then FlushTail (BeginLongOp)
Print3Flush         pshs      a,b
                    jsr       [>UmeData_pprintf]
                    leas      6,s
                    bra       FlushTail
* DefWindowEsc(a, b, c, d, e, f): pprintf(fmt at $14, $C6, a..f) then flush; used only by OpenPromptBox
DefWindowEsc        pshs      u
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
* FlushTail: pflush, return
FlushTail           jsr       [>UmeData_pflush]
                    puls      u,pc
* GetPartStaff(part, int *flags): entry part*4 of the $0C5F part table; *flags = word 2, returns word 0 (the part's staff); used by SortNotes
GetPartStaff        pshs      u
                    ldd       4,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$0C5F
                    leax      d,x
                    leau      ,x
                    ldd       2,u
                    std       [<$06,s]
                    ldd       ,u
                    puls      u,pc
* SortNotes(staff, from, to): for each note on the staff (1-based) compares it with the later notes at the same time with the same voice bits (flags & 3) and bytes 3-4, and swaps pitch/accidental where the order is wrong for the voice (bit 0 / bit 1); returns the swap count
SortNotes           pshs      u
                    leas      <-$11,s
                    clra
                    clrb
                    std       7,s
                    ldd       <$15,s
                    addd      #$FFFF
                    std       <$15,s
                    ldd       <$17,s
                    pshs      a,b
                    lbsr      RecordPtr
                    leas      2,s
                    lbra      SortOuterTest
* SortOuterLoop: picks the next note on the target staff and copies it to the frame temp
SortOuterLoop       ldb       ,u
                    lbeq      SortOuterNext
                    leax      2,s
                    pshs      x
                    ldb       ,u
                    sex
                    pshs      a,b
                    bsr       GetPartStaff
                    leas      4,s
                    cmpd      <$15,s
                    lbne      SortOuterNext
                    ldd       <UmeData_curind
                    std       5,s
                    pshs      u
                    leax      11,s
                    pshs      x
                    lbsr      CopyRecord
                    leas      4,s
                    lbra      SortInnerNext
* SortInnerLoop: while the record time equals the anchor's, tests staff, voice bits, bytes 3-4 and pitch order
SortInnerLoop       ldd       1,u
                    cmpd      10,s
                    lbne      SortWriteBack
                    ldb       ,u
                    lbeq      SortInnerNext
                    leax      ,s
                    pshs      x
                    ldb       ,u
                    sex
                    pshs      a,b
                    lbsr      GetPartStaff
                    leas      4,s
                    cmpd      <$15,s
                    lbne      SortInnerNext
                    ldd       2,s
                    eora      ,s
                    eorb      1,s
                    clra
                    andb      #$03
                    lbne      SortInnerNext
                    ldb       3,u
                    sex
                    pshs      a,b
                    ldb       14,s
                    sex
                    cmpd      ,s++
                    lbne      SortInnerNext
                    ldb       4,u
                    sex
                    pshs      a,b
                    ldb       15,s
                    sex
                    cmpd      ,s++
                    lbne      SortInnerNext
                    ldd       2,s
                    clra
                    andb      #$01
                    beq       a26@
                    ldb       5,u
                    cmpb      #$20
                    beq       a26@
                    ldb       14,s
                    cmpb      #$20
                    beq       SortSwapNotes
                    ldb       5,u
                    sex
                    pshs      a,b
                    ldb       <$10,s
                    sex
                    cmpd      ,s++
                    blt       SortSwapNotes
a26@                ldd       2,s
                    clra
                    andb      #$02
                    beq       SortInnerNext
                    ldb       5,u
                    sex
                    pshs      a,b
                    ldb       <$10,s
                    sex
                    cmpd      ,s++
                    ble       SortInnerNext
* SortSwapNotes: exchanges bytes 5, 6 (and 7, kept on rests) between the temp copy and the record; counts the swap
SortSwapNotes       ldb       14,s
                    stb       4,s
                    ldb       5,u
                    stb       14,s
                    ldb       4,s
                    stb       5,u
                    ldb       15,s
                    stb       4,s
                    ldb       6,u
                    stb       15,s
                    ldb       4,s
                    stb       6,u
                    ldb       <$10,s
                    stb       4,s
                    ldb       14,s
                    cmpb      #$20
                    beq       a27@
                    ldb       7,u
                    stb       <$10,s
a27@                ldb       5,u
                    cmpb      #$20
                    beq       b27@
                    ldb       4,s
                    stb       7,u
b27@                ldd       7,s
                    addd      #$0001
                    std       7,s
* SortInnerNext: NextRecord, loops while curind <= 'to'; every inner-loop reject branches here
SortInnerNext       lbsr      NextRecord
                    tfr       d,u
                    ldd       <UmeData_curind
                    cmpd      <$19,s
                    lble      SortInnerLoop
* SortWriteBack: CopyRecord of the temp copy back over the anchor record
SortWriteBack       ldd       5,s
                    pshs      a,b
                    lbsr      RecordPtr
                    leas      2,s
                    tfr       d,u
                    leax      9,s
                    pshs      x
                    pshs      u
                    lbsr      CopyRecord
                    leas      4,s
* SortOuterNext: NextRecord, then the outer test
SortOuterNext       lbsr      NextRecord
* SortOuterTest: loops to SortOuterLoop while curind <= 'to'; the routine entry jumps here
SortOuterTest       tfr       d,u
                    ldd       <UmeData_curind
                    cmpd      <$19,s
                    lble      SortOuterLoop
                    ldd       7,s
                    leas      <$11,s
                    puls      u,pc
* BlockMenu: the 'b' block command: SelectWindow(2), the condensed Blocks menu (descBlocks) -> key; u = RemoveBlockMarks, o = CmdOMark; after the [ ] ^ marks (pfmarks) and checks: p play, t transpose, f fixup, s sort, d delete, c copy, m move
BlockMenu           pshs      u
                    leas      <-$73,s
                    ldd       <UmeData_curcurse
                    std       2,s
                    ldd       #$0002
                    pshs      a,b
                    lbsr      SelectWindow
                    leas      2,s
* The Blocks menu is a condensed text menu (descBlocks below, streamed by s9's menu3 and
* drawn by s9gui).
                    ldx       #MenuStates
                    pshs      x
                    leax      >descBlocks,pcr
                    pshs      x
                    jsr       [>pMenu3]           B = the key letter picked, CR = closed
                    leas      4,s
                    stb       <$19,s
                    lbsr      EndPrompt
                    ldd       2,s
                    pshs      a,b
                    lbsr      SelectWindow
                    leas      2,s
                    ldb       <$19,s
                    cmpb      #$0D
                    lbeq      BlockCancel
                    ldb       <$19,s
                    cmpb      #$75
                    bne       BlockGetMarks
                    lbsr      RemoveBlockMarks
                    lbra      BlockSetFlagExit
* BlockGetMarks: the '[' (<$16,s), ']' (<$14,s) and I-marker (<$12,s) indices via pfmarks, then the 'o' key test
BlockGetMarks       leax      <$12,s
                    pshs      x
                    leax      <$16,s
                    pshs      x
                    leax      <$1A,s
                    pshs      x
                    jsr       [>UmeData_pfmarks]
                    leas      6,s
                    ldb       <$19,s
                    cmpb      #$6F
                    bne       BlockCheckMarks
                    ldd       <$12,s
                    bge       CmdOMark
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgNeedIMarker,pcr
                    lbra      BlockErrExit
* CmdOMark: 'o': needs the I marker (msgNeedIMarker), then writes subtype 9 (Coda) into that marker record and reports changed
CmdOMark            ldd       <$12,s
                    pshs      a,b
                    lbsr      RecordPtr
                    leas      2,s
                    tfr       d,u
                    ldd       #$0009
                    stb       5,u
                    ldd       #$0001
                    lbra      BlockSetFlagExit
* BlockCheckMarks: StrChr(strKeysNeedBlock, key); for those keys a '[' after ']' alerts msgBracketsBackward
BlockCheckMarks     ldb       <$19,s
                    sex
                    pshs      a,b
                    leax      >strKeysNeedBlock,pcr
                    pshs      x
                    lbsr      StrChr
                    leas      4,s
                    std       -2,s
                    lbeq      BlockMarksOk
                    ldd       <$14,s
                    blt       CmdPlayBlock
                    ldd       <$16,s
                    cmpd      <$14,s
                    ble       CmdPlayBlock
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgBracketsBackward,pcr
                    lbra      BlockErrExit
* CmdPlayBlock: 'p': asks for the marks (pfixmarx) when '[' is missing, defaults ']' to the last record, PrePlayEsc when pldebug, then pplay('[', ']') and EndPrompt
CmdPlayBlock        ldb       <$19,s
                    cmpb      #$70
                    bne       CmdTranspose
                    ldd       <$16,s
                    bge       a28@
                    leax      <$12,s
                    pshs      x
                    leax      <$16,s
                    pshs      x
                    leax      <$1A,s
                    pshs      x
                    jsr       [>UmeData_pfixmarx]
                    leas      6,s
                    lbeq      BlockRetFlag
a28@                ldd       <$14,s
                    bge       b28@
                    ldd       <UmeData_nevents
                    addd      #$FFFF
                    std       <$14,s
b28@                ldb       <UmeData_pldebug
                    beq       c28@
                    lbsr      PrePlayEsc
c28@                ldd       <$14,s
                    pshs      a,b
                    ldd       <$18,s
                    pshs      a,b
                    jsr       [>UmeData_pplay]
                    leas      4,s
                    ldb       <UmeData_pldebug
                    beq       BlockRetFlag
                    lbsr      EndPrompt
                    bra       BlockRetFlag
* CmdTranspose: 't': OpenPromptBox, msgHowManySemis, a line from pgets, AtoI, and TransposeBlock(n) when non-zero; sets rfr_scr
CmdTranspose        ldb       <$19,s
                    cmpb      #$74
                    bne       CmdFixOrSort
                    clra
                    clrb
                    pshs      a,b
                    lbsr      OpenPromptBox
                    leas      2,s
                    leax      >msgHowManySemis,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    leax      <$1A,s
                    pshs      x
                    jsr       [>UmeData_pgets]
                    leas      2,s
                    lbsr      EndPrompt
                    leax      <$1A,s
                    pshs      x
                    lbsr      AtoI
                    leas      2,s
                    std       6,s
                    beq       BlockRetFlag
                    ldd       6,s
                    pshs      a,b
                    lbsr      TransposeBlock
                    leas      2,s
                    ldd       #$0001
                    stb       <UmeData_rfr_scr
* BlockRetFlag: BlockMenu exit returning the changed flag rfr_scr
BlockRetFlag        ldb       <UmeData_rfr_scr
                    lbra      BlockExit
* CmdFixOrSort: 'f' or 's' fall into FixSortRange, other keys go to BlockNeedMarks
CmdFixOrSort        ldb       <$19,s
                    cmpb      #$66
                    beq       FixSortRange
                    ldb       <$19,s
                    cmpb      #$73
                    lbne      BlockNeedMarks
* FixSortRange: f/s prologue: the block marks (pfixmarx), or pyesno msgCurrentScreen and the screen range lftind..ritind
FixSortRange        clra
                    clrb
                    stb       <UmeData_rfr_scr
                    leax      <$12,s
                    pshs      x
                    leax      <$16,s
                    pshs      x
                    leax      <$1A,s
                    pshs      x
                    jsr       [>UmeData_pfixmarx]
                    leas      6,s
                    bne       CmdFixUpPart
                    leax      >msgCurrentScreen,pcr
                    pshs      x
                    jsr       [>UmeData_pyesno]
                    leas      2,s
                    lbeq      BlockCancel
                    ldd       <UmeData_lftind
                    std       <$16,s
                    ldd       <UmeData_ritind
                    std       <$14,s
* CmdFixUpPart: 'f': msgPartToFixUp, a key from pcharmaus, PartCharToNum (1..nparts), then pfixup('[', ']', part, 1)
CmdFixUpPart        clra
                    clrb
                    pshs      a,b
                    lbsr      OpenPromptBox
                    leas      2,s
                    ldb       <$19,s
                    cmpb      #$66
                    bne       CmdSortNotes
                    leax      >msgPartToFixUp,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    leax      <$18,s
                    pshs      x
                    jsr       [>UmeData_pcharmaus]
                    leas      2,s
                    lbsr      EndPrompt
                    ldb       <$18,s
                    sex
                    pshs      a,b
                    lbsr      PartCharToNum
                    leas      2,s
                    std       6,s
                    lbeq      BlockCancel
                    ldd       6,s
                    cmpd      <UmeData_nparts
                    lbgt      BlockCancel
                    ldd       #$0001
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    ldd       <$18,s
                    pshs      a,b
                    ldd       <$1C,s
                    pshs      a,b
                    jsr       [>UmeData_pfixup]
                    leas      8,s
                    lbra      BlockResultToFlag
* CmdSortNotes: 's': msgClickStaffSort, key or click (pkeymaus); a click maps y to a staff with pfindstaff + 1, a key goes through PartCharToNum
CmdSortNotes        leax      >msgClickStaffSort,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    leax      10,s
                    pshs      x
                    leax      14,s
                    pshs      x
                    jsr       [>UmeData_pkeymaus]
                    leas      4,s
                    stb       <$18,s
                    lbsr      EndPrompt
                    ldb       <$18,s
                    bne       a29@
                    ldd       10,s
                    pshs      a,b
                    jsr       [>UmeData_pfindstaff]
                    leas      2,s
                    addd      #$0001
                    bra       SortRunReport
a29@                ldb       <$18,s
                    cmpb      #$0D
                    lbeq      BlockCancel
                    ldb       <$18,s
                    sex
                    pshs      a,b
                    lbsr      PartCharToNum
                    leas      2,s
* SortRunReport: rejects staff > nstaves, SortNotes(staff, '[', ']') and palert(msgNotesSwapped, 1, count)
SortRunReport       std       6,s
                    ldd       6,s
                    cmpd      <UmeData_nstaves
                    lbgt      BlockCancel
                    ldd       <$14,s
                    pshs      a,b
                    ldd       <$18,s
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    lbsr      SortNotes
                    leas      6,s
                    std       6,s
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    leax      >msgNotesSwapped,pcr
                    pshs      x
                    jsr       [>UmeData_palert]
                    leas      6,s
* BlockResultToFlag: tail of the 'f' and 's' arms: nonzero result -> changed flag 1, else 0
BlockResultToFlag   ldd       6,s
                    lbne      BlockRetChanged
                    clra
                    clrb
                    lbra      BlockSetFlagExit
* BlockNeedMarks: d/m/c need both marks; msgMissingBracket when either index is negative
BlockNeedMarks      ldd       <$16,s
                    ora       <$14,s
                    orb       <$15,s
                    std       -2,s
                    bge       BlockMarksOk
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgMissingBracket,pcr
* BlockErrExit: shared exit: palert with the pushed message and 0, then BlockCancel
BlockErrExit        pshs      x
                    jsr       [>UmeData_palert]
                    leas      4,s
                    lbra      BlockCancel
* BlockMarksOk: marks OK (key not in strKeysNeedBlock, or both >= 0): key into X for BlockDispatchDMC
BlockMarksOk        ldb       <$19,s
                    sex
                    tfr       d,x
                    lbra      BlockDispatchDMC
* CmdDeleteBlock: 'd': BeginLongOp then DeleteBlockBody
CmdDeleteBlock      lbsr      BeginLongOp
                    bra       DeleteBlockBody
* DeleteAfterMove: re-entry for 'm': resets S to the BlockMenu frame (leas <-$73,x) and deletes the original block after the copy
DeleteAfterMove     leas      <-$73,x
* DeleteBlockBody: deletes the records between '[' and ']': count = records after ']', delta = time(']') - time('['), shifts the tail down with adjusted times; nevents = new count, length = time of the last record
DeleteBlockBody     ldd       <UmeData_nevents
                    addd      #$FFFF
                    subd      <$14,s
                    std       6,s
                    ldd       <$16,s
                    pshs      a,b
                    lbsr      RecordPtr
                    leas      2,s
                    tfr       d,x
                    ldd       1,x
                    pshs      a,b
                    ldd       <$16,s
                    pshs      a,b
                    lbsr      RecordPtr
                    leas      2,s
                    tfr       d,x
                    ldd       1,x
                    subd      ,s++
                    std       ,s
                    ldd       <$14,s
                    addd      #$0001
                    std       <$14,s
                    bra       DelBlockFinish
* DelShiftLoop: CopyRecord src -> temp, subtract delta from the time word, CopyRecord temp -> dst
DelShiftLoop        ldd       <$14,s
                    addd      #$0001
                    std       <$14,s
                    subd      #$0001
                    pshs      a,b
                    lbsr      RecordPtr
                    std       ,s
                    leax      <$6D,s
                    pshs      x
                    lbsr      CopyRecord
                    leas      4,s
                    ldd       <$6C,s
                    subd      ,s
                    std       <$6C,s
                    leax      <$6B,s
                    pshs      x
                    ldd       <$18,s
                    addd      #$0001
                    std       <$18,s
                    subd      #$0001
                    pshs      a,b
                    lbsr      RecordPtr
                    std       ,s
                    lbsr      CopyRecord
                    leas      4,s
                    ldd       6,s
                    addd      #$FFFF
                    std       6,s
* DelBlockFinish: loop test and finish: nevents, LongStore of the last record's time to length, rfr_scr = 1, pgivebac, EndPrompt
DelBlockFinish      ldd       6,s
                    bne       DelShiftLoop
                    ldd       <$16,s
                    std       <UmeData_nevents
                    ldx       #$0091
                    pshs      x
                    ldd       <UmeData_nevents
                    addd      #$FFFF
                    pshs      a,b
                    jsr       [>UmeData_pfulltime]
                    leas      2,s
                    lbsr      LongStore
                    ldd       #$0001
                    stb       <UmeData_rfr_scr
                    jsr       [>UmeData_pgivebac]
                    lbsr      EndPrompt
                    lbra      BlockRetFlag2
* CmdCopyMoveBlock: 'c'/'m': needs the ^ (I) marker (msgNeedCaret) outside the block (msgCaretOutside); count = ']' - '[' - 1, delta = block time span; needs 32767 - nevents >= count and the last new record addressable
CmdCopyMoveBlock    ldd       <$12,s
                    bge       a30@
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgNeedCaret,pcr
                    lbra      BlockMsgRetFlag
a30@                ldd       <$16,s
                    cmpd      <$12,s
                    bge       CopyCheckRoom
                    ldd       <$12,s
                    cmpd      <$14,s
                    bge       CopyCheckRoom
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgCaretOutside,pcr
                    bra       BlockMsgRetFlag
* CopyCheckRoom: count and time span, then the room checks (RecordPtr of the last new index non-zero)
CopyCheckRoom       ldd       <$14,s
                    subd      <$16,s
                    addd      #$FFFF
                    std       6,s
                    ldd       <$16,s
                    pshs      a,b
                    lbsr      RecordPtr
                    leas      2,s
                    tfr       d,x
                    ldd       1,x
                    pshs      a,b
                    ldd       <$16,s
                    pshs      a,b
                    lbsr      RecordPtr
                    leas      2,s
                    tfr       d,x
                    ldd       1,x
                    subd      ,s++
                    std       ,s
                    ldd       #$7FFF
                    subd      <UmeData_nevents
                    cmpd      6,s
                    blt       ScoreUnchanged
                    ldd       6,s
                    addd      <UmeData_nevents
                    addd      #$FFFF
                    pshs      a,b
                    lbsr      RecordPtr
                    std       ,s++
                    bne       CopyBlockDo
* ScoreUnchanged: copy/move failure exit: pgivebac and palert(msgScoreUnchanged)
ScoreUnchanged      jsr       [>UmeData_pgivebac]
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgScoreUnchanged,pcr
* BlockMsgRetFlag: shared exit: palert with the pushed message, then return the changed flag
BlockMsgRetFlag     pshs      x
                    jsr       [>UmeData_palert]
                    leas      4,s
                    lbra      BlockRetFlag2
* CopyBlockDo: copies the block to the ^ marker: BeginLongOp, nevents += count, length += span (IntToLong/LongAdd/LongStore), opens a gap after the marker, adjusts '[' ']' when the marker precedes the block, then copies the block records with shifted times
CopyBlockDo         lbsr      BeginLongOp
                    ldd       <UmeData_nevents
                    addd      #$FFFF
                    std       14,s
                    addd      6,s
                    std       <$10,s
                    ldd       14,s
                    subd      <$12,s
                    std       4,s
                    ldd       <UmeData_nevents
                    addd      6,s
                    std       <UmeData_nevents
                    ldx       #$0091
                    pshs      x
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       6,s
                    lbsr      IntToLong
                    lbsr      LongAdd
                    lbsr      LongStore
                    bra       CopyMakeRoomTest
* CopyMakeRoomLoop: moves records from the old end down to the marker up by count, adding the time span
CopyMakeRoomLoop    ldd       14,s
                    addd      #$FFFF
                    std       14,s
                    subd      #$FFFF
                    pshs      a,b
                    lbsr      RecordPtr
                    std       ,s
                    leax      <$6D,s
                    pshs      x
                    lbsr      CopyRecord
                    leas      4,s
                    ldd       <$6C,s
                    addd      ,s
                    std       <$6C,s
                    leax      <$6B,s
                    pshs      x
                    ldd       <$12,s
                    addd      #$FFFF
                    std       <$12,s
                    subd      #$FFFF
                    pshs      a,b
                    lbsr      RecordPtr
                    std       ,s
                    lbsr      CopyRecord
                    leas      4,s
                    ldd       4,s
                    addd      #$FFFF
                    std       4,s
* CopyMakeRoomTest: repeats while the shift counter 4,s is nonzero
CopyMakeRoomTest    ldd       4,s
                    bne       CopyMakeRoomLoop
                    ldd       <$12,s
                    cmpd      <$16,s
                    bge       CopyBlockRecs
                    ldd       <$16,s
                    addd      6,s
                    std       <$16,s
                    ldd       <$14,s
                    addd      6,s
                    std       <$14,s
* CopyBlockRecs: delta = time(marker) - time('['), then copies '['+1 .. ']'-1 after the marker
CopyBlockRecs       ldd       <$16,s
                    addd      #$0001
                    std       14,s
                    ldd       <$12,s
                    addd      #$0001
                    std       <$10,s
                    ldd       14,s
                    pshs      a,b
                    lbsr      RecordPtr
                    leas      2,s
                    tfr       d,x
                    ldd       1,x
                    pshs      a,b
                    ldd       <$12,s
                    pshs      a,b
                    lbsr      RecordPtr
                    leas      2,s
                    tfr       d,x
                    ldd       1,x
                    subd      ,s++
                    std       ,s
                    bra       CopyDoneOrMove
* CopyRecsLoop: CopyRecord block record -> temp, add delta to its time, CopyRecord into the gap
CopyRecsLoop        ldd       14,s
                    addd      #$0001
                    std       14,s
                    subd      #$0001
                    pshs      a,b
                    lbsr      RecordPtr
                    std       ,s
                    leax      <$6D,s
                    pshs      x
                    lbsr      CopyRecord
                    leas      4,s
                    ldd       <$6C,s
                    addd      ,s
                    std       <$6C,s
                    leax      <$6B,s
                    pshs      x
                    ldd       <$12,s
                    addd      #$0001
                    std       <$12,s
                    subd      #$0001
                    pshs      a,b
                    lbsr      RecordPtr
                    std       ,s
                    lbsr      CopyRecord
                    leas      4,s
                    ldd       6,s
                    addd      #$FFFF
                    std       6,s
* CopyDoneOrMove: after the copy, 'm' goes to DeleteAfterMove to remove the original block; else EndPrompt and report changed
CopyDoneOrMove      ldd       6,s
                    bne       CopyRecsLoop
                    ldb       <$19,s
                    cmpb      #$6D
                    bne       a31@
                    leax      <$73,s
                    lbra      DeleteAfterMove
a31@                lbsr      EndPrompt
* BlockRetChanged: D = 1 into BlockSetFlagExit
BlockRetChanged     ldd       #$0001
* BlockSetFlagExit: B -> changed flag rfr_scr, leave BlockMenu
BlockSetFlagExit    stb       <UmeData_rfr_scr
                    bra       BlockExit
* BlockBadKey: unknown block-menu key: BeepIfSound, return 0
BlockBadKey         lbsr      BeepIfSound
* BlockCancel: BlockMenu 'return 0' exit (CR, bad part, message exits)
BlockCancel         clra
                    clrb
                    bra       BlockExit
* BlockDispatchDMC: final key switch: 'd' CmdDeleteBlock, 'm'/'c' CmdCopyMoveBlock, else BlockBadKey
BlockDispatchDMC    cmpx      #$0064
                    lbeq      CmdDeleteBlock
                    cmpx      #$006D
                    lbeq      CmdCopyMoveBlock
                    cmpx      #$0063
                    lbeq      CmdCopyMoveBlock
                    bra       BlockBadKey
* BlockRetFlag2: second copy of the rfr_scr tail before BlockExit (DelBlockFinish, BlockMsgRetFlag)
BlockRetFlag2       ldb       <UmeData_rfr_scr
* BlockExit: frame release and return of BlockMenu
BlockExit           leas      <$73,s
                    puls      u,pc
* RemoveBlockMarks: 'u': walks every record and deletes marks with subtype $0D ('['), $0E (']') or $0F (I marker) through premove; returns 1 when any were removed
RemoveBlockMarks    pshs      u
                    leas      -3,s
                    clra
                    clrb
                    stb       2,s
                    clra
                    clrb
                    pshs      a,b
                    lbsr      RecordPtr
                    leas      2,s
                    bra       UnmarkTest
* UnmarkLoop: byte 0 == 0 and byte 5 in $0D..$0F
UnmarkLoop          ldb       ,u
                    bne       UnmarkNext
                    ldb       5,u
                    cmpb      #$0D
                    beq       UnmarkDelete
                    ldb       5,u
                    cmpb      #$0E
                    beq       UnmarkDelete
                    ldb       5,u
                    cmpb      #$0F
                    bne       UnmarkNext
* UnmarkDelete: deletes the record at curind, re-derives the pointer, sets the changed flag
UnmarkDelete        ldd       <UmeData_curind
                    std       ,s
                    ldd       <UmeData_curind
                    pshs      a,b
                    jsr       [>UmeData_premove]
                    leas      2,s
                    ldd       ,s
                    pshs      a,b
                    lbsr      RecordPtr
                    leas      2,s
                    tfr       d,u
                    ldd       #$0001
                    stb       2,s
                    bra       a32@
* UnmarkNext: NextRecord for records that are not block marks, falls into the test
UnmarkNext          lbsr      NextRecord
* UnmarkTest: loops to UnmarkLoop while curind < nevents; the routine entry jumps here
UnmarkTest          tfr       d,u
a32@                ldd       <UmeData_curind
                    cmpd      <UmeData_nevents
                    blt       UnmarkLoop
                    ldb       2,s
                    leas      3,s
                    puls      u,pc
* descBlocks: the Blocks menu for s9's menu3: fcb col, y, width, rows; the key letters; rows
* of kind + label + NUL (kind ' ' plain; a space key = a row the picker leaves alone); a zero
* kind ends it.
descBlocks          fcb       MenuBarC7+MenuDropX+1,MenuDropY,12,10  frame at Block label's first column
                    fcc       /dcmpfts ou/
                    fcc       / Delete/
                    fcb       0
                    fcc       / Copy/
                    fcb       0
                    fcc       / Move/
                    fcb       0
                    fcc       / Play/
                    fcb       0
                    fcc       / Fixup/
                    fcb       0
                    fcc       / Transpose/
                    fcb       0
                    fcc       / Sort notes/
                    fcb       0
                    fcb       C$SPAC,0            a blank row
                    fcc       / insert cOda/
                    fcb       0
                    fcc       / Unmark score/
                    fcb       0,0
* msgNeedIMarker: CmdOMark without the I (^) marker
msgNeedIMarker      fcc       /Need an I marker!/
                    fcb       $00
* strKeysNeedBlock: block-menu keys that need the [ ] marks; tested with StrChr
strKeysNeedBlock    fcc       /tfdmcps/
                    fcb       $00
* msgBracketsBackward: ']' precedes '[' in the score
msgBracketsBackward fcc       / ] [ backwards!/
                    fcb       $00
* msgHowManySemis: CmdTranspose prompt
msgHowManySemis     fcc       /(Use '-' for Down)/
                    fcb       $0D
                    fcc       / How many Semitones up? /
                    fcb       $00
* msgCurrentScreen: yes/no when f/s find no block marks
msgCurrentScreen    fcc       /Do the Current Screen showing?/
                    fcb       $00
* msgPartToFixUp: CmdFixUpPart prompt
msgPartToFixUp      fcc       /Part (1 to G) to fix up: /
                    fcb       $00
* msgClickStaffSort: CmdSortNotes prompt
msgClickStaffSort   fcc       /CLICK Staff to Sort Notes on/
                    fcb       $0D
                    fcc       / or Type its No.: /
                    fcb       $00
* msgNotesSwapped: alerted after SortNotes with the swap count
msgNotesSwapped     fcc       /Notes Swapped:/
                    fcb       $00
* msgMissingBracket: d/m/c without both block marks
msgMissingBracket   fcc       /Missing [ or ] !/
                    fcb       $00
* msgNeedCaret: copy/move without the ^ (I) marker
msgNeedCaret        fcc       /Need a ^ mark./
                    fcb       $00
* msgCaretOutside: copy/move with the marker inside the block
msgCaretOutside     fcb       $0D
                    fcc       /Must have ^ outside [block]./
                    fcb       $0D,$00
* msgScoreUnchanged: copy/move aborted for lack of room
msgScoreUnchanged   fcc       / Score left unchanged./
                    fcb       $00
* RecordPtr(index): curind = index; page = index/$3A0 + 1 is swapped in through ppswap when it is not curpage; returns curevp = database + (index mod $3A0)*8, or 0 when the swap fails
RecordPtr           pshs      u
                    ldu       4,s
                    leas      -2,s
                    stu       <UmeData_curind
                    ldd       #$0001
                    bra       b33@
a33@                ldd       ,s
                    addd      #$0001
b33@                std       ,s
                    leau      >-$03A0,u
                    stu       -2,s
                    bge       a33@
                    leau      >$03A0,u
                    ldd       ,s
                    cmpd      <UmeData_curpage
                    beq       RecPtrInBlock
                    ldd       ,s
                    pshs      a,b
                    jsr       [>UmeData_ppswap]
                    leas      2,s
                    bne       RecPtrInBlock
                    clra
                    clrb
                    bra       RecPtrRet
* RecPtrInBlock: pointer = remainder*8 + database, stored in curevp
RecPtrInBlock       tfr       u,d
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    addd      <UmeData_database
                    std       <UmeData_curevp
* RecPtrRet: RecordPtr exit; the failed-swap path branches here with D = 0
RecPtrRet           leas      2,s
                    puls      u,pc
* NextRecord: curind++, curevp += 8; past curptop swaps in page curpage+1 and restarts at database; returns curevp
NextRecord          pshs      u
                    ldd       <UmeData_curind
                    addd      #$0001
                    std       <UmeData_curind
                    cmpd      <UmeData_nevents
                    bge       RetRecPtr
                    ldd       <UmeData_curevp
                    addd      #$0008
                    std       <UmeData_curevp
                    cmpd      <UmeData_curptop
                    bls       RetRecPtr
                    ldd       <UmeData_curpage
                    addd      #$0001
                    pshs      a,b
                    jsr       [>UmeData_ppswap]
                    leas      2,s
                    ldd       <UmeData_database
                    bra       SetRecPtr
* PrevRecord: curind--, curevp -= 8; below database swaps in page curpage-1 and continues at curptop; returns curevp
PrevRecord          pshs      u
                    ldd       <UmeData_curind
                    addd      #$FFFF
                    std       <UmeData_curind
                    blt       RetRecPtr
                    ldd       <UmeData_curevp
                    addd      #$FFF8
                    std       <UmeData_curevp
                    cmpd      <UmeData_database
                    bhs       RetRecPtr
                    ldd       <UmeData_curpage
                    addd      #$FFFF
                    pshs      a,b
                    jsr       [>UmeData_ppswap]
                    leas      2,s
                    ldd       <UmeData_curptop
* SetRecPtr: stores the new record pointer in curevp; NextRecord jumps here with database, PrevRecord falls in with curptop
SetRecPtr           std       <UmeData_curevp
* RetRecPtr: shared exit of NextRecord/PrevRecord: returns curevp
RetRecPtr           ldd       <UmeData_curevp
                    puls      u,pc
                    fcb       $EC,$64,$E3
                    fcs       /f4F./
                    fcb       $68,$EE,$66,$20,$04,$E6,$80,$E7
                    fcb       $C0,$AC,$E4,$25,$F8,$35,$C6,$EC
                    fcb       $64,$AE,$62,$34,$10,$30,$8B,$20
                    fcb       $12,$EC,$18,$ED,$84,$EC,$1A,$ED
                    fcb       $02,$EC,$1C,$ED,$04,$EC,$1E,$ED
                    fcb       $06,$30,$18,$AC,$E4,$22,$EA,$35
                    fcb       $90,$AE,$62,$EC,$64,$E3,$62,$34
                    fcb       $06,$20,$12,$EC,$08,$ED,$84,$EC
                    fcb       $0A,$ED,$02,$EC,$0C,$ED,$04,$EC
                    fcb       $0E,$ED,$06,$30,$08,$AC,$E4,$25
                    fcb       $EA,$35,$86,$34,$40,$EE,$66,$AE
                    fcb       $64,$EC,$C4,$ED,$84,$EC,$42,$ED
                    fcb       $02,$E6,$44,$E7,$04,$35,$C0
* CopyRecord(dst, src): copies one 8-byte score record as four words
CopyRecord          pshs      u
                    ldu       6,s
                    ldx       4,s
                    ldd       ,u
                    std       ,x
                    ldd       2,u
                    std       2,x
                    ldd       4,u
                    std       4,x
                    ldd       6,u
                    std       6,x
                    puls      u,pc
                    fcb       $34,$40,$EE,$66,$AE,$64,$8D,$16
                    fcb       $1F,$01,$20,$06
* StrCopy(dst, src): byte loop until NUL, returns dst; saves/restores the last find spec at $07DF
StrCopy             pshs      u
                    ldu       6,s
                    ldx       4,s
a34@                ldb       ,u+
                    stb       ,x+
                    bne       a34@
                    ldd       4,s
                    puls      u,pc
                    fcb       $AE,$62,$E6,$80,$26,$FC,$30,$1F
                    fcb       $1F,$10,$39
* StrChr(s, c): returns a pointer to the first c in s or 0; tests the block key against strKeysNeedBlock
StrChr              ldx       2,s
a35@                ldb       ,x+
                    beq       b35@
                    cmpb      5,s
                    bne       a35@
                    tfr       x,d
                    bra       c35@
b35@                clra
                    rts
                    fcb       $AE,$62,$CC,$00,$01,$34,$06,$20
                    fcb       $06,$E1,$67,$26,$02,$AF,$E4,$E6
                    fcb       $80,$26,$F6,$35,$06
c35@                subd      #$0001
                    rts
* AtoI(str): skips blanks and tabs, accepts +/-, accumulates decimal digits (x*10 via shifts), negates on '-'
AtoI                pshs      u
                    ldu       4,s
                    clra
                    clrb
                    pshs      a,b
                    pshs      b
a36@                ldb       ,u+
                    cmpb      #$20
                    beq       a36@
                    cmpb      #$09
                    beq       a36@
                    cmpb      #$2D
                    bne       b36@
                    stb       ,s
                    bra       d36@
b36@                cmpb      #$2B
                    bne       e36@
                    bra       d36@
c36@                ldd       1,s
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
d36@                ldb       ,u+
e36@                cmpb      #$30
                    blo       f36@
                    cmpb      #$39
                    bls       c36@
f36@                tst       ,s+
                    puls      a,b
                    beq       g36@
                    nega
                    negb
                    sbca      #$00
g36@                puls      u,pc
* LongAdd: accumulator ($0343,y) = the 32-bit value on the stack + the long at X; grows length in CopyBlockDo
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
* IntToLong: sign-extends D into the 32-bit accumulator at $0343,y
IntToLong           leax      >$0343,y
                    std       2,x
                    tfr       a,b
                    sex
                    tfr       a,b
                    std       ,x
                    rts
                    fcb       $30,$A9,$03,$43,$ED,$02,$6F,$84
                    fcb       $6F,$01,$39
* LongStore: copies the 4-byte long at X to the destination pointer on the stack (length or a record time)
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
* LongAddRet: tail of LongAdd: pops the 32-bit argument, keeps CC and returns X = the accumulator at $0343,y
LongAddRet          tfr       cc,a
                    puls      x
                    stx       2,s
                    leas      2,s
                    leax      >$0343,y
                    tfr       a,cc
                    rts
                    fcb       $EC,$84,$ED,$A9,$03,$43,$EC,$02
                    fcb       $30,$A9,$03,$43,$ED,$02,$39
* MulInt16: 16x16 multiply (D * pushed word): 8x8 fast path with mul, else four partial products; returns the low word in D
MulInt16            tsta
                    bne       MulWide
                    tst       2,s
                    bne       MulWide
                    lda       3,s
                    mul
                    ldx       ,s
                    stx       2,s
                    ldx       #$0000
                    std       ,s
                    puls      a,b,pc
* MulWide: four-partial-product path of MulInt16 when either operand exceeds 8 bits
MulWide             pshs      a,b
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
                    bhs       a37@
                    inc       ,s
a37@                lda       4,s
                    ldb       9,s
                    mul
                    addd      1,s
                    std       1,s
                    bhs       b37@
                    inc       ,s
b37@                lda       4,s
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
* ModInt: modulo: divisor in D, dividend on the stack; installs UDivCore at $0CCD,y, records the sign at $0CCC,y, returns the remainder with the dividend's sign (mod 12 / mod 7 in the key code)
ModInt              leax      >UDivCore,pcr
                    stx       >$0CCD,y
                    clr       >$0CCC,y
                    tst       2,s
                    bpl       a38@
                    inc       >$0CCC,y
a38@                subd      #$0000
                    bne       b38@
                    puls      x
                    ldd       ,s++
                    jmp       ,x
b38@                ldx       2,s
                    pshs      x
                    jsr       [>$0CCD,y]
                    ldd       ,s
                    std       2,s
                    tfr       x,d
                    tst       >$0CCC,y
                    beq       c38@
                    nega
                    negb
                    sbca      #$00
c38@                std       ,s++
                    rts
                    fcb       $83,$00,$00,$27,$0A,$34,$06
                    fcs       /2~od/
                    fcc       /oa .5/
                    fcb       $06,$ED,$E4,$CC,$00,$2D,$16,$00
                    fcb       $99
* UDivCore: unsigned shift-subtract division loop called through [>$0CCD,y] by ModInt (code kept as fcb)
UDivCore            fcb       $83,$00,$00,$27,$F1,$34,$06
                    fcs       /2~od/
                    fcc       /oaM*/
                    fcb       $08,$40,$50,$82,$00,$63,$61,$ED
                    fcb       $62,$EC,$66,$2A,$08,$40,$50,$82
                    fcb       $00,$63,$61,$ED,$66,$86,$01
                    fcs       /Lhcib*y/
                    fcb       $A7,$E4,$EC
                    fcs       /fofog#/
                    fcb       $62,$24,$06,$E3,$62,$1C,$FE,$20
                    fcb       $02,$1A,$01
                    fcs       /igifdbfcjd/
                    fcb       $26,$E8,$ED
                    fcc       /bma'/
                    fcb       $08,$EC
                    fcc       /f@P/
                    fcb       $82,$00,$ED,$66,$AE,$64,$EC,$66
                    fcb       $ED,$64,$AF,$66,$AE,$62,$EC
                    fcc       /d2f9]'/
                    fcb       $13
                    fcs       /gbfcZ&y/
                    fcb       $20,$0A,$5D,$27,$07
                    fcs       /dbfcZ&y/
* ShiftLeft16Ret: shared return of ShiftLeft16: the shifted word in D, frame dropped; B = 0 jumps here
ShiftLeft16Ret      ldd       2,s
                    pshs      a,b
                    ldd       2,s
                    std       4,s
                    ldd       ,s
                    leas      4,s
                    rts
* ShiftLeft16: shifts the pushed word left by B bits; packs two characters for PredTwoCharMark
ShiftLeft16         tstb
                    beq       ShiftLeft16Ret
a39@                asl       3,s
                    rol       2,s
                    decb
                    bne       a39@
                    bra       ShiftLeft16Ret
                    fcb       $ED,$A9,$03
                    fcc       /O4$/
                    fcb       $10,$3F,$0C,$35,$24,$10,$3F,$08
                    fcb       $39,$00,$22,$00,$00,$00,$00,$04
                    fcb       $00,$04,$00,$00,$00,$01,$47,$01
                    fcb       $45,$01,$43,$01,$41,$01,$3F,$01
                    fcb       $3D,$01,$56,$01,$54,$01,$52,$01
                    fcb       $50,$01,$4E,$01,$4C,$02,$0A,$01
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
                    fcc       /s9t/
                    fcb       $00

                    emod
eom                 equ       *
                    end
