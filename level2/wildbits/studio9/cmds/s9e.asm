********************************************************************
* s9e - Studio-9 events/structure overlay (edition 7)
* Ported from UltiMusE III v10.11.4e (OS-9 Level 2) CMDS/Um3E, disassembled to byte-exact lwasm source.
* Port change: event pages hold 928 events ($03A0), not 1020, so a page fits the $1D00 visible bytes
* of DAT slot 7 (GPBLKS in s9.asm); NoteAddr carries its own copy of the page divide.
*
* s9 calls the entry with a function letter as the first argument; OvlMain sign-extends it and
* FnSwitch dispatches:
*   'e' EditInstEvent(noteIdx) - the Instant (MIDI) Event editor: shows the event hit, asks
*       Insert/Add/Replace, reads hex bytes, validates them (first byte $80-$FF, data bytes <= $7F,
*       message length by status, partwise events need a part) and stores them inline in the 8-byte
*       record or, when too long, in the shared ImEvts byte pool (InternEvent, mapped via pswapevts)
*   'o' ReorderParts(staff, segregateClones) - sorts the parts, rebuilds $0C5F, MidiChanTbl and
*       MidiPartOn in the new order and renumbers every part reference and the same-time note order
*   'n' SortStaves - sorts the 10-byte staff records at $0C19 and renumbers part->staff references
*   'b' EditBarMark(noteIdx) - bar-mark menu (endings, repeats, fine, ending number, meter, key,
*       D.C./D.S., segno, coda, space, label) applied to the bar record or a newly inserted one
*   'i' InstrFileIO(path, write) - reads/writes the 64-slot instrument table (called by s9d)
*   'B' AddBars(noteIdx, firstBar, count, startTimeLong) - appends count bars of rests for every
*       non-clone part ("No more bars; out of memory!")
* Event records are 8 bytes: 0 part (0 = system record), 1-2 time, 3-4 data, 5 type (system records:
* $00-$06 bar lines, other marks up to $15, meter $0A, key $0B; $16-$18, $1E and $20 carry their part
* in byte 6; $1E partwise instant, $1F system instant, $20/$21 tables), 6-7 params.
* The tail is the Microware C runtime (MemCopy, Copy5/CopyRec8, StrNCpy, AtoI, long accumulator at
* $0343, MulU16, DivS16/ModS16, LShift16, ReadPath/WritePath/SleepTicks, ErrReturn with errno at
* $034F). Output goes through the main program's printf/sprintf, the s9gui panel codes $C6/$C7 (DP
* formats <$14/<$16), message box, pause, yes/no, line/key input and menu picker. Unlabeled fcb
* blocks are unreferenced bytes of the original module. Local labels aN@/bN@ belong to routine N.

                    nam       s9e
                    ttl       s9e (disassembly)

                  IFP1
                    use       defsfile
                  ENDC
UME_SCOPE_S9E                  equ       1
                    use       equates.asm

tylg                set       $11
atrv                set       $81
size                equ       $104F

                    mod       eom,name,tylg,atrv,start,size
name                fcs       /s9e/
                    fcb       $07
start               equ       *
                    lbra      OvlMain
                    fcb       $39,$0D,$00
* overlay entry: X = the sign-extended function letter (first argument), dispatched by FnSwitch
OvlMain             pshs      u
                    ldb       5,s
                    sex
                    tfr       d,x
                    lbra      FnSwitch
* 'e': EditInstEvent(note index)
CaseEditEvent       ldd       6,s
                    pshs      a,b
                    lbsr      EditInstEvent
                    bra       OvlRetPop2
* 'o': calls ReorderParts(arg2 staff, arg3 segregate-clones flag) and returns 1
CaseReorderParts    ldd       8,s
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    lbsr      ReorderParts
                    leas      4,s
                    lbra      RetOne
* 'n': calls SortStaves (no args) and returns 1
CaseSortStaves      lbsr      SortStaves
                    lbra      RetOne
* 'b': calls EditBarMark(arg2 note index)
CaseBarMark         ldd       6,s
                    pshs      a,b
                    lbsr      EditBarMark
* shared exit: drop the 2-byte argument then OvlRetByte
OvlRetPop2          leas      2,s
                    bra       OvlRetByte
* 'i': calls InstrFileIO(arg2 path, arg3 write flag)
CaseInstrFile       ldd       8,s
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    lbsr      InstrFileIO
                    leas      4,s
* shared overlay exit: sex (byte result in B sign-extended to D), puls u,pc
OvlRetByte          sex
                    puls      u,pc
* 'B': pushes the long at 12,s plus args 4,3,2 and calls AddBars(noteIdx, firstBar, count, startTime)
CaseAddBars         leax      12,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    lbsr      AddBars
                    leas      10,s
                    puls      u,pc
* cmpx chain on the function letter 'e' 'o' 'n' 'b' 'i' 'B', else RetZero
FnSwitch            cmpx      #$0065
                    lbeq      CaseEditEvent
                    cmpx      #$006F
                    lbeq      CaseReorderParts
                    cmpx      #$006E
                    beq       CaseSortStaves
                    cmpx      #$0062
                    beq       CaseBarMark
                    cmpx      #$0069
                    beq       CaseInstrFile
                    cmpx      #$0042
                    beq       CaseAddBars
                    bra       RetZero
* MemEqual(a, b, n): compares n bytes; returns 1 if equal, 0 at the first difference; used by InternEvent to find an existing event string
MemEqual            pshs      u
                    ldu       8,s
                    bra       MemEqNext
* MemEqual loop body: fetch *a++ and *b++, cmpd, exit 0 on mismatch
MemEqLoop           ldx       4,s
                    leax      1,x
                    stx       4,s
                    ldb       -1,x
                    sex
                    pshs      a,b
                    ldx       8,s
                    leax      1,x
                    stx       8,s
                    ldb       -1,x
                    sex
                    cmpd      ,s++
                    beq       MemEqNext
* return 0 (unknown function letter, and MemEqual mismatch)
RetZero             clra
                    clrb
                    puls      u,pc
* MemEqual loop test: decrement count, loop while >= 0
MemEqNext           leau      -1,u
                    stu       -2,s
                    bge       MemEqLoop
* return 1 (MemEqual all bytes equal; 'o' and 'n' cases)
RetOne              ldd       #$0001
                    puls      u,pc
* InternEvent(bytes, n): n must be 1..255; maps the ImEvts pool (pswapevts(1): base $03E5, end $03E9, 4096 bytes max) and returns the offset of an identical n-byte string, else appends it; no room -> '***Events out of room!' and 0 (pool left mapped)
InternEvent         pshs      u
                    leas      -8,s
                    ldd       14,s
                    lble      InternFail
                    ldd       14,s
                    cmpd      #$00FF
                    lbgt      InternFail
                    ldd       #$0001
                    pshs      a,b
                    jsr       [>UmeData_pswapevts]
                    leas      2,s
                    std       >UmeData_reserved_03E5
                    ldd       >UmeData_reserved_03E9
                    subd      >UmeData_reserved_03E5
                    std       4,s
                    ldd       #$1000
                    subd      4,s
                    std       6,s
                    ldd       4,s
                    subd      14,s
                    std       ,s
                    clra
                    clrb
                    std       2,s
                    ldu       >UmeData_reserved_03E5
                    bra       InternScanTest
* InternEvent pool scan body: MemEqual(u, bytes, n), advance offset and pointer
InternScan          ldd       14,s
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    pshs      u
                    lbsr      MemEqual
                    leas      6,s
                    std       -2,s
                    bne       InternFound
                    ldd       2,s
                    addd      #$0001
                    std       2,s
                    subd      #$0001
                    tfr       u,d
                    leau      1,u
* InternEvent scan loop test (offset < used - n)
InternScanTest      ldd       2,s
                    cmpd      ,s
                    blt       InternScan
* InternEvent: match found before the end - unmap pool ([$03A7](0)) and return the offset
InternFound         ldd       2,s
                    cmpd      ,s
                    bge       InternAppend
                    clra
                    clrb
                    pshs      a,b
                    jsr       [>UmeData_pswapevts]
                    leas      2,s
                    ldd       2,s
                    bra       InternExit
* InternEvent: not found; if n > room show '***Events out of room!' else append the bytes at $03E9
InternAppend        ldd       14,s
                    cmpd      6,s
                    ble       InternCopyTest
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgEventsFull,pcr
                    pshs      x
                    jsr       [>UmeData_palert]
                    leas      4,s
* InternEvent failure exit: return 0
InternFail          clra
                    clrb
                    bra       InternExit
                    fcb       $20,$19
* InternEvent append loop: copy one byte to the pool end pointer $03E9 and bump it
InternCopyLoop      ldx       12,s
                    leax      1,x
                    stx       12,s
                    ldb       -1,x
                    ldx       >UmeData_reserved_03E9
                    leax      1,x
                    stx       >UmeData_reserved_03E9
                    stb       -1,x
                    ldd       14,s
                    addd      #$FFFF
                    std       14,s
* InternEvent append loop test; afterwards unmaps the pool and returns the old used size as the new offset
InternCopyTest      ldd       14,s
                    bgt       InternCopyLoop
                    clra
                    clrb
                    pshs      a,b
                    jsr       [>UmeData_pswapevts]
                    leas      2,s
                    ldd       4,s
* InternEvent frame teardown and return
InternExit          leas      8,s
                    puls      u,pc
* MapEventBytes(offset, count): maps the ImEvts pool; returns a pointer to offset when offset+count (count & $FF) lies inside it, else 0; the caller unmaps with pswapevts(0)
MapEventBytes       pshs      a,b,u
                    ldd       8,s
                    clra
                    std       8,s
                    ldd       #$0001
                    pshs      a,b
                    jsr       [>UmeData_pswapevts]
                    leas      2,s
                    std       >UmeData_reserved_03E5
                    addd      6,s
                    std       ,s
                    addd      8,s
                    cmpd      >UmeData_reserved_03E9
                    bls       a1@
                    clra
                    clrb
                    bra       b1@
a1@                 ldd       ,s
b1@                 leas      2,s
                    puls      u,pc
* ShowInstEvent(note): type $1E 'Instant on Part %d:' then its bytes inline (bytes 3, 4, 7; bit 7 of byte 3 set = inline, bit 7 of a data byte ends the list) or from the pool; type $1F 'Instant System:' (ShowSysEvent); $20/$21 'Table, not yet.'; else 'Type %d, Not an Event.'
ShowInstEvent       pshs      u
                    ldu       4,s
                    leas      -7,s
                    leax      >fmtHexByteSp,pcr
                    stx       ,s
                    ldb       3,u
                    stb       6,s
                    ldb       5,u
                    cmpb      #$1E
                    lbne      ShowSysEvent
                    leax      >strInstant,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    ldb       6,u
                    sex
                    pshs      a,b
                    leax      >fmtOnPart,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    ldb       6,s
                    bge       ShowPartPooled
                    ldb       4,u
                    clra
                    andb      #$7F
                    pshs      a,b
                    ldb       3,u
                    clra
                    pshs      a,b
                    leax      >fmtTwoHex,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      6,s
                    ldb       4,u
                    lblt      PrintCR
                    ldb       7,u
                    clra
                    andb      #$7F
                    pshs      a,b
                    leax      >fmtSpHex,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    bra       PrintCR
* ShowInstEvent: partwise event stored in the pool (byte 3 bit 7 clear) - MapEventBytes(offset 3-4,u, count 7,u) and print each byte
ShowPartPooled      ldb       7,u
                    clra
                    std       2,s
                    pshs      a,b
                    ldd       3,u
                    pshs      a,b
                    lbsr      MapEventBytes
                    leas      4,s
                    std       4,s
                    bne       PartByteTest
                    lbra      ShowEvtExit
                    fcb       $20,$15
* print one pooled byte with fmtHexByteSp
PartByteLoop        ldx       4,s
                    leax      1,x
                    stx       4,s
                    ldb       -1,x
                    clra
                    pshs      a,b
                    ldd       2,s
                    pshs      a,b
                    jsr       [>UmeData_pprintf]
                    leas      4,s
* pooled byte loop test; then unmap the pool
PartByteTest        ldd       2,s
                    addd      #$FFFF
                    std       2,s
                    bge       PartByteLoop
                    clra
                    clrb
                    pshs      a,b
                    jsr       [>UmeData_pswapevts]
                    leas      2,s
* print strCR and leave ShowInstEvent
PrintCR             leax      >strCR,pcr
* shared tail: printf(X) via [$035D] then ShowEvtExit
PrintStrExit        pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    lbra      ShowEvtExit
* ShowInstEvent type $1F: 'Instant System:' - inline form prints status ($F0|low nibble of byte 3) then 4,u / 7,u / 6,u according to bits $20/$40 of byte 3
ShowSysEvent        ldb       5,u
                    cmpb      #$1F
                    lbne      ShowTableType
                    leax      >strInstantSys,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    ldb       6,s
                    lbge      ShowSysPooled
                    ldb       6,s
                    sex
                    orb       #$F0
                    clra
                    pshs      a,b
                    ldd       2,s
                    pshs      a,b
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    ldb       6,s
                    clra
                    andb      #$60
                    stb       6,s
                    lbeq      SysPrintCR
                    ldb       4,u
                    clra
                    pshs      a,b
                    ldd       2,s
                    pshs      a,b
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    ldb       6,s
                    clra
                    andb      #$40
                    lbeq      SysPrintCR
                    ldb       7,u
                    clra
                    pshs      a,b
                    ldd       2,s
                    pshs      a,b
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    ldb       6,s
                    clra
                    andb      #$20
                    lbeq      SysPrintCR
                    ldb       6,u
                    clra
                    pshs      a,b
                    ldd       2,s
                    pshs      a,b
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    bra       SysPrintCR
* system event bytes kept in the pool: MapEventBytes and print them
ShowSysPooled       ldb       7,u
                    clra
                    std       2,s
                    pshs      a,b
                    ldd       3,u
                    pshs      a,b
                    lbsr      MapEventBytes
                    leas      4,s
                    std       4,s
                    bne       SysByteTest
                    lbra      ShowEvtExit
                    fcb       $20,$15
* print one pooled system-event byte
SysByteLoop         ldx       4,s
                    leax      1,x
                    stx       4,s
                    ldb       -1,x
                    clra
                    pshs      a,b
                    ldd       2,s
                    pshs      a,b
                    jsr       [>UmeData_pprintf]
                    leas      4,s
* pooled system byte loop test; unmap afterwards
SysByteTest         ldd       2,s
                    addd      #$FFFF
                    std       2,s
                    bge       SysByteLoop
                    clra
                    clrb
                    pshs      a,b
                    jsr       [>UmeData_pswapevts]
                    leas      2,s
* print strCR2 and exit (system event done)
SysPrintCR          leax      >strCR2,pcr
                    lbra      PrintStrExit
* type $20 or $21 -> SayTableNotYet, else SayNotAnEvent
ShowTableType       ldb       5,u
                    cmpb      #$20
                    beq       SayTableNotYet
                    ldb       5,u
                    cmpb      #$21
                    bne       SayNotAnEvent
* prints 'Table, not yet.'
SayTableNotYet      leax      >msgTableNotYet,pcr
                    lbra      PrintStrExit
* prints 'Type %d, Not an Event.' with the record type byte
SayNotAnEvent       ldb       5,u
                    sex
                    pshs      a,b
                    leax      >fmtNotAnEvent,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      4,s
* ShowInstEvent frame teardown and return
ShowEvtExit         leas      7,s
                    puls      u,pc
* EditInstEvent(noteIdx) ('e'): on an event record (part 0, type $1E-$21) shows it and asks Insert before / Add after / Replace / ENTER; then reads hex bytes, validates them, encodes them inline or through InternEvent, and inserts or replaces the record
EditInstEvent       pshs      u
                    leas      >-$0417,s
                    ldx       #$01A6
                    stx       ,s
                    ldx       #$0C11
                    pshs      x
                    leax      <$11,s
                    pshs      x
                    lbsr      CopyRec8
                    leas      4,s
                    ldd       >$041B,s
                    pshs      a,b
                    lbsr      NoteAddr
                    leas      2,s
                    tfr       d,u
                    ldb       5,u
                    stb       2,s
                    ldd       #$FFFF
                    std       13,s
                    ldb       ,u
                    lbne      AnchorPart
                    ldb       2,s
                    cmpb      #$1E
                    lblt      AnchorPart
                    ldb       2,s
                    cmpb      #$21
                    lbgt      AnchorPart
                    ldd       #$0001
                    pshs      a,b
                    lbsr      OpenPanel
                    leas      2,s
                    leax      >msgYouHitEvent,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    pshs      u
                    lbsr      ShowInstEvent
                    leas      2,s
                    leax      >msgInsAddRepl,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    leax      >msgOrEnter,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    leax      >$0117,s
                    pshs      x
                    jsr       [>UmeData_pcharmaus]
                    leas      2,s
                    lbsr      ClosePanel
                    ldb       >$0117,s
                    cmpb      #$72
                    bne       InsBeforeCase
                    ldd       >$041B,s
                    std       13,s
                    bra       AnchorPart
* answer 'i' (insert before) handling; 'a' falls to AddAfterCase, anything else exits with 0
InsBeforeCase       ldb       >$0117,s
                    cmpb      #$69
                    bne       AddAfterCase
                    ldd       >$041B,s
                    addd      #$FFFF
                    cmpd      13,s
                    bne       a2@
                    ldd       #$0001
                    bra       AnchorPart
a2@                 clra
                    clrb
                    bra       AnchorPart
* answer 'a' (add after); any other key -> EditRetZero
AddAfterCase        ldb       >$0117,s
                    cmpb      #$61
                    lbne      EditRetZero
                    ldd       >$041B,s
                    addd      #$0001
                    cmpd      13,s
                    bne       a3@
                    ldd       #$0001
                    bra       AnchorPart
a3@                 clra
                    clrb
* part for the new event: the note's part byte (0,u) if nonzero, else 6,u for types $16,$17,$18,$1E,$20, else 0
AnchorPart          ldb       ,u
                    beq       AnchorTypeChk
                    ldb       ,u
* sign-extends the chosen part byte into PromptHexBytes; AnchorPart falls in, AnchorTypeChk a4@ branches
AnchorPartExtend    sex
                    bra       PromptHexBytes
* tests the anchor record type against $17,$18,$16,$1E,$20 (records that carry a part in byte 6)
AnchorTypeChk       ldb       2,s
                    cmpb      #$17
                    beq       a4@
                    ldb       2,s
                    cmpb      #$18
                    beq       a4@
                    ldb       2,s
                    cmpb      #$16
                    beq       a4@
                    ldb       2,s
                    cmpb      #$1E
                    beq       a4@
                    ldb       2,s
                    cmpb      #$20
                    bne       b4@
a4@                 ldb       6,u
                    bra       AnchorPartExtend
b4@                 clra
                    clrb
* opens the panel, prints 'Type Hex bytes...', reads a line with [$0359], ParseHexBytes into the record buffer; forces bit 7 on the first byte with 'First byte must be between Hex 80 and FF'
PromptHexBytes      std       9,s
                    ldd       #$0001
                    pshs      a,b
                    lbsr      OpenPanel
                    leas      2,s
                    leax      >msgTypeHexBytes,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    leax      >$0117,s
                    pshs      x
                    jsr       [>UmeData_pgets]
                    leas      2,s
                    ldb       >$0117,s
                    lbeq      CancelEdit
                    ldd       #$00FF
                    pshs      a,b
                    leax      <$19,s
                    pshs      x
                    leax      >$011B,s
                    pshs      x
                    lbsr      ParseHexBytes
                    leas      6,s
                    std       5,s
                    lbeq      CancelEdit
                    ldb       <$17,s
                    stb       2,s
                    clra
                    andb      #$80
                    bne       ClassifyStatus
                    leax      >msgFirstByteRange,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    ldb       2,s
                    sex
                    orb       #$80
                    clra
                    pshs      a,b
                    ldb       4,s
                    sex
                    pshs      a,b
                    leax      >fmtChangingTo,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      6,s
                    ldb       <$17,s
                    sex
                    orb       #$80
                    stb       <$17,s
                    jsr       [>UmeData_phit]
* 12,s = 1 for a channel message (status & $70 != $70), 0 for a system message ($Fx); type $1F system / $1E partwise
ClassifyStatus      ldb       2,s
                    clra
                    andb      #$70
                    cmpd      #$0070
                    beq       a5@
                    ldd       #$0001
                    bra       PartwiseCheck
a5@                 clra
                    clrb
* partwise event with no part -> 'No; Partwise Event must go on Note, Rest, ...' and cancel; else store the part number in the record
PartwiseCheck       stb       12,s
                    ldd       #$001F
                    std       7,s
                    ldb       12,s
                    beq       FitsInlineChk
                    ldd       #$001E
                    std       7,s
                    ldd       9,s
                    bne       StoreEventPart
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgPartwiseAnchor,pcr
                    pshs      x
                    jsr       [>UmeData_palert]
                    leas      4,s
* close the panel and return 0
CancelEdit          lbsr      ClosePanel
* return 0 from EditInstEvent
EditRetZero         clra
                    clrb
                    lbra      EditEvtExit
* partwise arm of PartwiseCheck: stores the part number low byte at <$15,s, then FitsInlineChk
StoreEventPart      ldd       9,s
                    stb       <$15,s
* 11,s = event fits inline: channel message with <= 3 bytes or system message with <= 4 bytes; otherwise StorePooledEvt
FitsInlineChk       ldb       12,s
                    beq       a6@
                    ldd       5,s
                    cmpd      #$0003
                    ble       b6@
a6@                 ldb       12,s
                    bne       c6@
                    ldd       5,s
                    cmpd      #$0004
                    bgt       c6@
b6@                 ldd       #$0001
                    bra       BuildInline
c6@                 clra
                    clrb
* inline encoding: expected length 2 for $Cx/$Dx status, 3 for other channel messages, SysLenSwitch for system messages
BuildInline         stb       11,s
                    lbeq      StorePooledEvt
                    ldb       2,s
                    clra
                    andb      #$7F
                    stb       2,s
                    ldd       5,s
                    std       3,s
                    ldb       12,s
                    beq       c7@
                    ldb       2,s
                    cmpb      #$40
                    blt       a7@
                    ldb       2,s
                    cmpb      #$5F
                    bgt       a7@
                    ldd       #$0002
                    bra       b7@
a7@                 ldd       #$0003
b7@                 std       3,s
                    bra       LenMismatchChk
c7@                 ldb       2,s
                    clra
                    andb      #$0F
                    tfr       d,x
                    bra       SysLenSwitch
SysLenThree         ldd       #$0003
                    bra       d7@
SysLenTwo           ldd       #$0002
                    bra       d7@
SysLenAsTyped       ldd       5,s
                    bra       d7@
SysLenOne           ldd       #$0001
d7@                 std       3,s
                    bra       LenMismatchChk
* expected length by system status low nibble: 1,2 -> 3 bytes; 3 -> 2; 4,5,9,D -> as typed; else 1
SysLenSwitch        cmpx      #$0001
                    beq       SysLenThree
                    cmpx      #$0002
                    lbeq      SysLenThree
                    cmpx      #$0003
                    beq       SysLenTwo
                    cmpx      #$0004
                    beq       SysLenAsTyped
                    cmpx      #$0005
                    lbeq      SysLenAsTyped
                    cmpx      #$0009
                    lbeq      SysLenAsTyped
                    cmpx      #$000D
                    lbeq      SysLenAsTyped
                    bra       SysLenOne
* 'Extra bytes ignored.' when more bytes than expected, 'Not enough data bytes; better re-do this Event.' when fewer; each followed by the pause [$037D]
LenMismatchChk      ldd       3,s
                    cmpd      5,s
                    bge       a8@
                    leax      >msgExtraIgnored,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    jsr       [>UmeData_phit]
                    ldd       3,s
                    std       5,s
a8@                 ldd       3,s
                    cmpd      5,s
                    ble       EncodeStatus
                    leax      >msgNotEnoughData,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    jsr       [>UmeData_phit]
* data count = typed count - 1; record byte 3 = status & $F0 | $80 for channel messages (channel comes from the part)
EncodeStatus        ldd       5,s
                    addd      #$FFFF
                    std       5,s
                    ldb       12,s
                    beq       EncodeSysStatus
                    ldb       <$17,s
                    clra
                    andb      #$F0
                    orb       #$80
                    bra       StoreEncStatus
* record byte 3 = $80 | status low nibble | (data count << 5) for system messages
EncodeSysStatus     ldb       <$17,s
                    clra
                    andb      #$0F
                    orb       #$80
                    pshs      a,b
                    ldd       7,s
                    pshs      a,b
                    ldd       #$0005
                    lbsr      LShift16
                    ora       ,s+
                    orb       ,s+
* shared store of the encoded status byte at <$12,s; EncodeStatus branches in, EncodeSysStatus falls in
StoreEncStatus      stb       <$12,s
                    leax      <$18,s
                    stx       ,s
                    ldd       #$0001
                    stb       2,s
                    lbra      InlineByteTest
* per data byte: clear bit 7 ('All but first byte mustn't exceed $7F'), set bit 7 on the last one as terminator, store byte 1->offset 4, 2->offset 7, 3->offset 6
InlineByteLoop      ldb       12,s
                    beq       b9@
                    ldb       [,s]
                    clra
                    andb      #$80
                    beq       a9@
                    leax      >msgDataOver7F,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    ldb       [,s]
                    clra
                    andb      #$7F
                    pshs      a,b
                    ldb       [<$02,s]
                    clra
                    pshs      a,b
                    leax      >fmtChangedTo,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      6,s
                    ldb       [,s]
                    clra
                    andb      #$7F
                    stb       [,s]
a9@                 ldb       2,s
                    sex
                    cmpd      5,s
                    bne       b9@
                    ldb       [,s]
                    sex
                    orb       #$80
                    stb       [,s]
b9@                 ldb       2,s
                    cmpb      #$01
                    bne       c9@
                    ldb       [,s]
                    stb       <$13,s
c9@                 ldb       2,s
                    cmpb      #$02
                    bne       d9@
                    ldb       [,s]
                    stb       <$16,s
d9@                 ldb       2,s
                    cmpb      #$03
                    bne       InlineByteNext
                    ldb       [,s]
                    stb       <$15,s
* advance byte counter and pointer in the inline byte loop
InlineByteNext      ldb       2,s
                    addd      #$0001
                    stb       2,s
                    subd      #$0001
                    ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
* inline byte loop test (byte number <= data count)
InlineByteTest      ldb       2,s
                    sex
                    cmpd      5,s
                    lble      InlineByteLoop
                    bra       CommitEvent
* long event: InternEvent(bytes, count) -> offset into record bytes 3-4 (bit 7 clear), count into byte 7
StorePooledEvt      ldd       5,s
                    pshs      a,b
                    leax      <$19,s
                    pshs      x
                    lbsr      InternEvent
                    leas      4,s
                    std       3,s
                    ldd       5,s
                    stb       <$16,s
                    ldd       3,s
                    anda      #$7F
                    std       <$12,s
* close panel, finish the record (part 0 byte, time from the anchor, type byte 5) and insert it: [$03B3] note time as long, [$03AD](time, 0, type) -> new index; replace paths use InsertBlankRec
CommitEvent         lbsr      ClosePanel
                    clra
                    clrb
                    stb       15,s
                    ldd       7,s
                    stb       <$14,s
                    ldd       1,u
                    std       <$10,s
                    ldd       13,s
                    bge       a10@
                    ldd       7,s
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       >$041F,s
                    pshs      a,b
                    jsr       [>UmeData_pfulltime]
                    leas      2,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    jsr       [>UmeData_penter]
                    leas      8,s
                    std       >$041B,s
                    bra       ShowNewEvent
a10@                ldd       13,s
                    cmpd      >$041B,s
                    bge       b10@
                    ldd       >$041B,s
                    bra       InsertBlankRec
b10@                ldd       13,s
                    cmpd      >$041B,s
                    ble       ShowNewEvent
                    ldd       >$041B,s
                    addd      #$0001
                    std       >$041B,s
* [$03B5](index): insert a blank record at index (main program routine)
InsertBlankRec      pshs      a,b
                    jsr       [>UmeData_pmakroom]
                    leas      2,s
* CopyRec8 the built record into the note at the new index, open panel, ShowInstEvent, pause, close panel, return 1
ShowNewEvent        leax      15,s
                    pshs      x
                    ldd       >$041D,s
                    pshs      a,b
                    lbsr      NoteAddr
                    std       ,s
                    lbsr      CopyRec8
                    leas      4,s
                    ldd       #$0001
                    pshs      a,b
                    lbsr      OpenPanel
                    leas      2,s
                    ldd       >$041B,s
                    pshs      a,b
                    lbsr      NoteAddr
                    std       ,s
                    lbsr      ShowInstEvent
                    leas      2,s
                    jsr       [>UmeData_phit]
                    lbsr      ClosePanel
                    ldd       #$0001
* EditInstEvent frame teardown ($417 bytes) and return
EditEvtExit         leas      >$0417,s
                    puls      u,pc
* ParseHexBytes(text, out, max): clears out[0..max), parses blank/CR/tab separated hex numbers (lowercase digits via HexDigitVal) into bytes; a bad character -> sprintf 'Non-Hex Char ...' into text and a message box; returns the byte count
ParseHexBytes       pshs      u
                    leas      -8,s
                    ldd       14,s
                    addd      <$10,s
                    tfr       d,u
                    bra       ClearOutTest
* zero the output buffer from the end down to its start
ClearOutLoop        clra
                    clrb
                    stb       ,-u
* clear loop test, then initialize accumulator (-1 = none), count, text pointer
ClearOutTest        cmpu      14,s
                    bhs       ClearOutLoop
                    ldd       #$FFFF
                    std       4,s
                    clra
                    clrb
                    std       6,s
                    ldd       12,s
                    std       ,s
                    ldu       14,s
* ParseHexBytes character loop head: NUL/blank/CR/tab end a number, anything else goes to HexDigitStep
HexScanLoop         ldb       [,s]
                    beq       HexFlushByte
                    ldb       [,s]
                    cmpb      #$20
                    beq       HexFlushByte
                    ldb       [,s]
                    cmpb      #$0D
                    beq       HexFlushByte
                    ldb       [,s]
                    cmpb      #$09
                    bne       HexDigitStep
* separator: if a number is pending store it in the output and bump the count
HexFlushByte        ldd       4,s
                    blt       HexEndCheck
                    ldd       4,s
                    stb       ,u+
                    ldd       #$FFFF
                    std       4,s
                    ldd       6,s
                    addd      #$0001
                    std       6,s
* stop at NUL or when count reaches max, else next character
HexEndCheck         ldb       [,s]
                    beq       HexRetCount
                    ldd       6,s
                    cmpd      <$10,s
                    bge       HexRetCount
                    lbra      HexNextChar
* HexDigitVal of the character; negative -> non-hex error message and stop
HexDigitStep        ldb       [,s]
                    sex
                    pshs      a,b
                    lbsr      HexDigitVal
                    leas      2,s
                    std       2,s
                    bge       HexAccum
                    ldb       [,s]
                    sex
                    pshs      a,b
                    leax      >fmtNonHexChar,pcr
                    pshs      x
                    ldd       <$10,s
                    pshs      a,b
                    jsr       [>UmeData_psprintf]
                    leas      6,s
                    clra
                    clrb
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    jsr       [>UmeData_palert]
                    leas      4,s
* return the number of bytes parsed
HexRetCount         ldd       6,s
                    bra       HexParseExit
* start a new number or HexShiftNib into the pending one
HexAccum            ldd       4,s
                    bge       HexShiftNib
                    ldd       2,s
                    bra       HexStoreAccum
* pending = pending * 16 + digit
HexShiftNib         ldd       4,s
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    addd      2,s
* std 4,s pending-value store shared by HexAccum (new number) and HexShiftNib (nibble shifted in)
HexStoreAccum       std       4,s
* advance the text pointer and loop
HexNextChar         ldd       ,s
                    addd      #$0001
                    std       ,s
                    lbra      HexScanLoop
* ParseHexBytes frame teardown
HexParseExit        leas      8,s
                    puls      u,pc
* HexDigitVal(c): '0'-'9' -> 0-9, 'a'-'f' -> 10-15 (lowercase only: subtracts $30 then $31), returns a negative value for other characters
HexDigitVal         pshs      u
                    ldb       5,s
                    sex
                    subd      #$0030
                    stb       5,s
                    cmpd      #$0009
                    ble       HexDigitRet
                    ldb       5,s
                    sex
                    subd      #$0031
                    stb       5,s
                    bge       HexLetterChk
* return c-'0' (0-9 or negative)
HexDigitRet         ldb       5,s
                    sex
                    puls      u,pc
* 'a'..'f' -> add 10
HexLetterChk        ldb       5,s
                    cmpb      #$05
                    bgt       a11@
                    ldb       5,s
                    sex
                    addd      #$000A
                    puls      u,pc
a11@                puls      u,pc
                    fcs       /4@5@/
* ClosePanel: printf(<$16, $C7), the s9gui window-close code; called after every prompt
ClosePanel          pshs      u
                    ldd       #$00C7
                    pshs      a,b
                    ldd       <UmeData_reserved_0016
                    pshs      a,b
                    jsr       [>UmeData_pprintf]
                    lbra      PopFourRet
* OpenPanel(tall): DefineBox(14, 110, 50, tall ? 5 : 2, 1, WinStylePaper3D) - the prompt panel, 5 lines for the event editor, 2 for the label prompt
OpenPanel           pshs      u
                    ldd       #WinStylePaper3D    the paper 3D box
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldb       9,s
                    beq       a12@
                    ldd       #$0005
                    bra       b12@
a12@                ldd       #$0002
b12@                pshs      a,b
                    ldd       #$0032
                    pshs      a,b
                    ldd       #$006E
                    pshs      a,b
                    ldd       #$000E
                    pshs      a,b
                    bsr       DefineBox
                    leas      12,s
                    puls      u,pc
* DefineBox(a..f): printf(<$14, $C6, a, b, c, d, (char)e, f), flush - the s9gui window-define code
DefineBox           pshs      u
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
* BeepIfSound: pbeep when the sound flag $03C3 is set; used for a bad bar-menu key
BeepIfSound         pshs      u
                    ldb       >UmeData_reserved_03C3
                    beq       a13@
                    jsr       [>UmeData_pbeep]
a13@                puls      u,pc
* SelectMenuWin(n): printf(<$18, $C4, n) selects the menu window; tail in PrintCtlCode
SelectMenuWin       pshs      u
                    ldd       4,s
                    pshs      a,b
                    ldd       #$00C4
                    bra       PrintCtlCode
* AskChoice(n, keybuf): SelectMenuWin(n), WaitButtonUp, prints '  Choice: ', CursorCtl(1) and, when keybuf is nonzero, reads a key into it with [$0353]
AskChoice           pshs      u
                    ldd       4,s
                    pshs      a,b
                    bsr       SelectMenuWin
                    leas      2,s
                    bsr       WaitButtonUp
                    leax      >msgChoice,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    ldd       #$0001
                    pshs      a,b
                    bsr       CursorCtl
                    leas      2,s
                    ldd       6,s
                    beq       a14@
                    ldd       6,s
                    pshs      a,b
                    jsr       [>UmeData_pcharmaus]
                    leas      2,s
a14@                puls      u,pc
* CursorCtl(c): printf(<$18, $CC, c); tail in PrintCtlCode
CursorCtl           pshs      u
                    ldb       5,s
                    sex
                    pshs      a,b
                    ldd       #$00CC
* shared tail of SelectMenuWin and CursorCtl: push the code and the <$18 format, printf
PrintCtlCode        pshs      a,b
                    ldd       <UmeData_reserved_0018
                    pshs      a,b
                    jsr       [>UmeData_pprintf]
                    leas      6,s
                    puls      u,pc
* WaitButtonUp: polls pmouce ($039F) with a 4-tick SleepTicks until it reports no button
WaitButtonUp        pshs      a,b,x,u
                    bra       WaitBtnPoll
* SleepTicks(4) between mouse polls
WaitBtnSleep        ldd       #$0004
                    pshs      a,b
                    lbsr      SleepTicks
                    leas      2,s
* call [$039F](&pkt, &x) and loop while nonzero
WaitBtnPoll         leax      ,s
                    pshs      x
                    leax      4,s
                    pshs      x
                    jsr       [>UmeData_pmouce]
                    leas      4,s
                    bne       WaitBtnSleep
* shared exit for WaitButtonUp and ClosePanel: leas 4,s; puls u,pc
PopFourRet          leas      4,s
                    puls      u,pc
msgEventsFull       fcc       /***Events out of room!/
                    fcb       $00
fmtHexByteSp        fcc       /%02X /
                    fcb       $00
strInstant          fcc       /Instant /
                    fcb       $00
fmtOnPart           fcc       /on Part %d: /
                    fcb       $00
fmtTwoHex           fcc       /%02X %02X/
                    fcb       $00
fmtSpHex            fcc       / %02X/
                    fcb       $00
strCR               fcb       $0D,$00
strInstantSys       fcc       /Instant System: /
                    fcb       $00
strCR2              fcb       $0D,$00
msgTableNotYet      fcc       /Table, not yet./
                    fcb       $0D,$00
fmtNotAnEvent       fcc       /Type %d, Not an Event./
                    fcb       $0D,$00
msgYouHitEvent      fcc       /You hit Event: /
                    fcb       $00
msgInsAddRepl       fcb       $0D
                    fcc       /type Insert before, Add after, Replace,/
                    fcb       $0D,$00
msgOrEnter          fcc       / or ENTER if just looking: /
                    fcb       $00
msgTypeHexBytes     fcc       /Type Hex bytes (1 or 2 digits each), separated by blanks:/
                    fcb       $0D,$00
msgFirstByteRange   fcc       /First byte must be between Hex 80 and FF;/
                    fcb       $0D,$00
fmtChangingTo       fcc       / changing your %02X to %02X./
                    fcb       $0D,$00
msgPartwiseAnchor   fcc       /No; Partwise Event must go on Note, Rest, Partwise/
                    fcb       $0D
                    fcc       / expression, or another Partwise Event./
                    fcb       $00
msgExtraIgnored     fcc       /Extra bytes ignored./
                    fcb       $0D,$00
msgNotEnoughData    fcb       $0D
                    fcc       /Not enough data bytes;/
                    fcb       $0D
                    fcc       / better re-do this Event./
                    fcb       $0D,$00
msgDataOver7F       fcb       $0C
                    fcc       /All but first byte mustn't exceed $7F;/
                    fcb       $0D,$00
fmtChangedTo        fcc       / changed your %02X to %02X./
                    fcb       $0D,$00
fmtNonHexChar       fcb       $07
                    fcc       /Non-Hex Char '%c'; ignored all after./
                    fcb       $00
msgChoice           fcc       /  Choice: /
                    fcb       $00
* SortStaves ('n'): exchange-sorts the nstaves 10-byte staff records at $0C19 into descending order of word 0 (swaps through a stack temp); after each swap staff numbers i and j trade places in word 0 of parts 1..nparts ($0C5F)
SortStaves          pshs      u
                    leas      -16,s
                    clra
                    clrb
                    lbra      SortOuterTest
* outer loop: inner index j = i (then incremented)
SortOuterNext       ldd       4,s
                    lbra      SortInnerNext
* staff[j].word0 >= staff[i].word0: swap the two 10-byte records
SortStaffPair       ldd       4,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      MulU16
                    ldx       #$0C19
                    leax      d,x
                    ldd       ,x
                    pshs      a,b
                    ldd       4,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      MulU16
                    ldx       #$0C19
                    leax      d,x
                    ldd       ,x
                    cmpd      ,s++
                    lblt      SortPairSkip
                    ldd       #$000A
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      MulU16
                    ldx       #$0C19
                    leax      d,x
                    pshs      x
                    leax      10,s
                    pshs      x
                    lbsr      MemCopy
                    leas      6,s
                    ldd       #$000A
                    pshs      a,b
                    ldd       4,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      MulU16
                    ldx       #$0C19
                    leax      d,x
                    pshs      x
                    ldd       8,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      MulU16
                    ldx       #$0C19
                    leax      d,x
                    pshs      x
                    lbsr      MemCopy
                    leas      6,s
                    ldd       #$000A
                    pshs      a,b
                    leax      8,s
                    pshs      x
                    ldd       6,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      MulU16
                    ldx       #$0C19
                    leax      d,x
                    pshs      x
                    lbsr      MemCopy
                    leas      6,s
                    ldd       <UmeData_nparts
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$0C5F
                    leax      d,x
                    leau      ,x
                    bra       RenumStaffTest
* walk the part table from the top: word0 == i becomes j and vice versa
RenumStaffLoop      ldd       ,u
                    cmpd      4,s
                    bne       a15@
                    ldd       2,s
                    bra       b15@
a15@                ldd       ,u
                    cmpd      2,s
                    bne       c15@
                    ldd       4,s
b15@                std       ,u
c15@                leau      -4,u
* part-table walk test (u > $0C5F)
RenumStaffTest      ldx       #$0C5F
                    pshs      x
                    cmpu      ,s++
                    bhi       RenumStaffLoop
* no swap (staff[j].word0 < staff[i].word0): load j for SortInnerNext
SortPairSkip        ldd       2,s
* j++ and loop while j < nstaves
SortInnerNext       addd      #$0001
                    std       2,s
                    ldd       2,s
                    cmpd      <UmeData_nstaves
                    lblt      SortStaffPair
                    ldd       4,s
                    addd      #$0001
* i++ and loop while i < nstaves; then return
SortOuterTest       std       4,s
                    ldd       4,s
                    cmpd      <UmeData_nstaves
                    lblt      SortOuterNext
                    leas      <$10,s
                    puls      u,pc
* ReorderParts(staff, segClones) ('o'): sorts a permutation of parts 1..nparts by key = staff*8 + (flags byte 3: bit 0 -> 0, else bit 1 -> 4, else 2) + (clone bit 2 ? (segClones ? $80 : 1) : 0); staff >= 0 sorts only that staff's parts; then rebuilds $0C5F, MidiChanTbl and MidiPartOn in the new order and renumbers every part reference
ReorderParts        pshs      u
                    leas      >-$00D1,s
                    ldd       <UmeData_nparts
                    bra       PermInitTest
* perm[i] = i for i = nparts down to 1
PermInitLoop        ldd       <$15,s
                    aslb
                    rola
                    leax      <$49,s
                    leax      d,x
                    ldd       <$15,s
                    std       ,x
                    ldd       <$15,s
                    addd      #$FFFF
* identity-permutation loop test
PermInitTest        std       <$15,s
                    ldd       <$15,s
                    bne       PermInitLoop
                    ldd       #$0001
                    lbra      PartSortITest
* outer sort loop: j = i + 1
PartSortOuter       ldd       <$15,s
                    lbra      PartSortJInc
* fetch perm[i], perm[j] and their staff words; staff >= 0 skips pairs not both on it
PartSortPair        ldd       <$15,s
                    aslb
                    rola
                    leax      <$49,s
                    leax      d,x
                    ldd       ,x
                    std       13,s
                    ldd       <$11,s
                    aslb
                    rola
                    leax      <$49,s
                    leax      d,x
                    ldd       ,x
                    std       11,s
                    ldd       13,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$0C5F
                    leax      d,x
                    ldd       ,x
                    std       <$13,s
                    ldd       11,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$0C5F
                    leax      d,x
                    ldd       ,x
                    std       15,s
                    ldd       >$00D5,s
                    blt       PartKeyA
                    ldd       >$00D5,s
                    cmpd      <$13,s
                    lbne      PartSortSkip
                    ldd       >$00D5,s
                    cmpd      15,s
                    lbne      PartSortSkip
* compute the ordering key of part perm[i]
PartKeyA            ldd       13,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$0C5F
                    leax      d,x
                    ldd       2,x
                    stb       6,s
                    ldd       <$13,s
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    pshs      a,b
                    ldb       8,s
                    clra
                    andb      #$01
                    beq       a16@
                    clra
                    clrb
                    bra       c16@
a16@                ldb       8,s
                    clra
                    andb      #$02
                    beq       b16@
                    ldd       #$0004
                    bra       c16@
b16@                ldd       #$0002
c16@                ora       ,s+
                    orb       ,s+
                    std       9,s
                    ldb       6,s
                    clra
                    andb      #$04
                    beq       PartKeyB
                    ldd       9,s
                    pshs      a,b
                    ldb       >$00DA,s
                    beq       d16@
                    ldd       #$0080
                    bra       e16@
d16@                ldd       #$0001
e16@                addd      ,s++
                    std       9,s
* compute the ordering key of part perm[j]
PartKeyB            ldd       11,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$0C5F
                    leax      d,x
                    ldd       2,x
                    stb       6,s
                    ldd       15,s
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    pshs      a,b
                    ldb       8,s
                    clra
                    andb      #$01
                    beq       a17@
                    clra
                    clrb
                    bra       c17@
a17@                ldb       8,s
                    clra
                    andb      #$02
                    beq       b17@
                    ldd       #$0004
                    bra       c17@
b17@                ldd       #$0002
c17@                ora       ,s+
                    orb       ,s+
                    std       7,s
                    ldb       6,s
                    clra
                    andb      #$04
                    beq       PartSwapPerm
                    ldd       7,s
                    pshs      a,b
                    ldb       >$00DA,s
                    beq       d17@
                    ldd       #$0080
                    bra       e17@
d17@                ldd       #$0001
e17@                addd      ,s++
                    std       7,s
* if key(i) > key(j) swap perm[i] and perm[j]
PartSwapPerm        ldd       9,s
                    cmpd      7,s
                    ble       PartSortSkip
                    ldd       <$15,s
                    aslb
                    rola
                    leax      <$49,s
                    leax      d,x
                    ldd       ,x
                    std       9,s
                    ldd       <$15,s
                    aslb
                    rola
                    leax      <$49,s
                    leax      d,x
                    pshs      x
                    ldd       <$13,s
                    aslb
                    rola
                    leax      <$4B,s
                    leax      d,x
                    ldd       ,x
                    std       [,s++]
                    ldd       <$11,s
                    aslb
                    rola
                    leax      <$49,s
                    leax      d,x
                    ldd       9,s
                    std       ,x
* ReorderParts inner-loop skip: wrong staff or key(i) <= key(j); loads j for PartSortJInc
PartSortSkip        ldd       <$11,s
* j++ and loop while j <= nparts
PartSortJInc        addd      #$0001
                    std       <$11,s
                    ldd       <$11,s
                    cmpd      <UmeData_nparts
                    lble      PartSortPair
                    ldd       <$15,s
                    addd      #$0001
* i++ and loop while i < nparts
PartSortITest       std       <$15,s
                    ldd       <$15,s
                    cmpd      <UmeData_nparts
                    lblt      PartSortOuter
                    ldd       <UmeData_nparts
                    bra       SaveTables
* newIndex[perm[i]] = i (inverse permutation in the curptop,s array)
InvPermLoop         ldd       <$15,s
                    aslb
                    rola
                    leax      <$49,s
                    leax      d,x
                    ldd       ,x
                    aslb
                    rola
                    leax      <$27,s
                    leax      d,x
                    ldd       <$15,s
                    std       ,x
                    ldd       <$15,s
                    addd      #$FFFF
* MemCopy the part table $0C5F (68 bytes) and MidiChanTbl/MidiPartOn (17 bytes each) into the frame
SaveTables          std       <$15,s
                    ldd       <$15,s
                    bne       InvPermLoop
                    ldd       #$0044
                    pshs      a,b
                    ldx       #$0C5F
                    pshs      x
                    leax      >$0091,s
                    pshs      x
                    lbsr      MemCopy
                    leas      6,s
                    ldd       #$0011
                    pshs      a,b
                    ldx       #MidiChanTbl
                    pshs      x
                    leax      >$0080,s
                    pshs      x
                    lbsr      MemCopy
                    leas      6,s
                    ldd       #$0011
                    pshs      a,b
                    ldx       #MidiPartOn
                    pshs      x
                    leax      <$6F,s
                    pshs      x
                    lbsr      MemCopy
                    leas      6,s
                    ldd       <UmeData_nparts
                    lbra      RebuildTest
* for each old part i: slot newIndex[i] of MidiChanTbl, MidiPartOn and $0C5F receives the saved entry i
RebuildTables       ldd       <$15,s
                    aslb
                    rola
                    leax      <$27,s
                    leax      d,x
                    ldd       ,x
                    std       13,s
                    ldx       #MidiChanTbl
                    leax      d,x
                    pshs      x
                    ldd       <$17,s
                    leax      <$7E,s
                    leax      d,x
                    ldb       ,x
                    stb       [,s++]
                    ldd       13,s
                    ldx       #MidiPartOn
                    leax      d,x
                    pshs      x
                    ldd       <$17,s
                    leax      <$6D,s
                    leax      d,x
                    ldb       ,x
                    stb       [,s++]
                    ldd       #$0004
                    pshs      a,b
                    ldd       <$17,s
                    aslb
                    rola
                    aslb
                    rola
                    leax      >$008F,s
                    leax      d,x
                    pshs      x
                    ldd       <$11,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$0C5F
                    leax      d,x
                    pshs      x
                    lbsr      MemCopy
                    leas      6,s
                    ldd       <$15,s
                    addd      #$FFFF
* rebuild loop test; then start the note walk at NoteAddr(0)
RebuildTest         std       <$15,s
                    ldd       <$15,s
                    lbne      RebuildTables
                    clra
                    clrb
                    pshs      a,b
                    lbsr      NoteAddr
                    leas      2,s
                    lbra      RenumNoteTest
* note walk: part byte 0,u = newIndex[part] when nonzero
RenumNoteLoop       ldb       ,u
                    sex
                    std       <$15,s
                    beq       RenumEvtTypes
                    ldd       <$15,s
                    aslb
                    rola
                    leax      <$27,s
                    leax      d,x
                    ldd       ,x
                    stb       ,u
                    bra       RenumNoteNext
* system records of type $18,$17,$16,$1E,$20 carry their part in byte 6
RenumEvtTypes       ldb       5,u
                    cmpb      #$18
                    beq       RenumEvtPart
                    ldb       5,u
                    cmpb      #$17
                    beq       RenumEvtPart
                    ldb       5,u
                    cmpb      #$16
                    beq       RenumEvtPart
                    ldb       5,u
                    cmpb      #$1E
                    beq       RenumEvtPart
                    ldb       5,u
                    cmpb      #$20
                    bne       RenumNoteNext
* 6,u = newIndex[6,u]
RenumEvtPart        ldb       6,u
                    sex
                    aslb
                    rola
                    leax      <$27,s
                    leax      d,x
                    ldd       ,x
                    stb       6,u
* note-walk advance (lbsr NextNoteAddr); RenumNoteLoop and RenumEvtTypes branch here when done
RenumNoteNext       lbsr      NextNoteAddr
* NextNoteAddr and loop while curind < nevents
RenumNoteTest       tfr       d,u
                    ldd       <UmeData_curind
                    cmpd      <UmeData_nevents
                    lblt      RenumNoteLoop
                    clra
                    clrb
                    lbra      SameTimeOutTest
* second pass: for note i with a part, remember its time and scan the following notes
SameTimeOuter       ldd       2,s
                    pshs      a,b
                    lbsr      NoteAddr
                    leas      2,s
                    tfr       d,u
                    ldb       ,u
                    sex
                    std       <$15,s
                    lbeq      SameTimeScanEnd
                    ldd       1,u
                    std       4,s
                    ldd       2,s
                    addd      #$0001
                    pshs      a,b
                    lbsr      NoteAddr
                    leas      2,s
                    lbra      SameTimeTest
* while the next note has the same time: if its part is lower, swap the two 8-byte records (CopyRec8 through frame temps)
SameTimeScan        ldd       1,u
                    cmpd      4,s
                    lbne      SameTimeScanEnd
                    ldb       ,u
                    lbeq      a18@
                    ldb       ,u
                    sex
                    cmpd      <$15,s
                    bge       a18@
                    ldb       ,u
                    sex
                    std       <$15,s
                    ldd       <UmeData_curind
                    std       ,s
                    pshs      u
                    leax      <$19,s
                    pshs      x
                    lbsr      CopyRec8
                    leas      4,s
                    ldd       2,s
                    pshs      a,b
                    lbsr      NoteAddr
                    leas      2,s
                    tfr       d,u
                    pshs      u
                    leax      <$21,s
                    pshs      x
                    lbsr      CopyRec8
                    leas      4,s
                    leax      <$17,s
                    pshs      x
                    pshs      u
                    lbsr      CopyRec8
                    leas      4,s
                    leax      <$1F,s
                    pshs      x
                    ldd       2,s
                    pshs      a,b
                    lbsr      NoteAddr
                    leas      2,s
                    tfr       d,u
                    pshs      u
                    lbsr      CopyRec8
                    leas      4,s
a18@                lbsr      NextNoteAddr
* inner scan test (index < count)
SameTimeTest        tfr       d,u
                    ldd       <UmeData_curind
                    cmpd      <UmeData_nevents
                    lblt      SameTimeScan
* ends the same-time scan (note has no part, or next note's time differs); i++ into SameTimeOutTest
SameTimeScanEnd     ldd       2,s
                    addd      #$0001
* outer loop test; then ReorderParts returns
SameTimeOutTest     std       2,s
                    ldd       2,s
                    cmpd      <UmeData_nevents
                    lblt      SameTimeOuter
                    leas      >$00D1,s
                    puls      u,pc
* EditBarMark(noteIdx) ('b'): bar-mark editor - AskChoice, then the menu picker ptextmen ($0375) over strBarMenuKeys; the mark is applied in place to the bar record (types <= 6) or to a newly inserted record
EditBarMark         pshs      u
                    leas      <-$58,s
                    ldd       <$5C,s
                    pshs      a,b
                    lbsr      NoteAddr
                    leas      2,s
                    tfr       d,u
* menu loop head: AskChoice(2,0), [$0375](30,160,19,1,1,16,1) picks an item (negative = typed key), ClosePanel
BarMenuLoop         clra
                    clrb
                    pshs      a,b
                    ldd       #$0002
                    pshs      a,b
                    lbsr      AskChoice
                    leas      4,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0010
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0013
                    pshs      a,b
                    ldd       #$00A0
                    pshs      a,b
                    ldd       #$001E
                    pshs      a,b
                    jsr       [>UmeData_ptextmen]
                    leas      14,s
                    stb       3,s
                    lbsr      ClosePanel
                    ldb       3,s
                    bge       MenuIdxToChar
                    ldb       3,s
                    sex
                    nega
                    negb
                    sbca      #$00
                    bra       EchoChoice
* convert a picked menu index into its key character from strBarMenuKeys
MenuIdxToChar       leax      >strBarMenuKeys,pcr
                    tfr       x,d
                    pshs      a,b
                    ldb       5,s
                    sex
                    addd      ,s++
                    tfr       d,x
                    ldb       ,x
* echo the chosen character with [$0383] (putchar) and dispatch through BarMenuSwitch
EchoChoice          stb       2,s
                    ldb       2,s
                    sex
                    pshs      a,b
                    jsr       [>UmeData_pputchar]
                    leas      2,s
                    clra
                    clrb
                    stb       4,s
                    ldb       2,s
                    sex
                    tfr       d,x
                    lbra      BarMenuSwitch
* '1': mark type 0 (plain bar / first ending)
CasePlainBar        clra
                    clrb
                    lbra      SetMarkType
* '2': mark type 2 (second ending)
CaseEnding2         ldd       #$0002
                    lbra      SetMarkType
* 'f': mark type 6 (Fine)
CaseFine            ldd       #$0006
                    lbra      SetMarkType
* '(': mark type 3 (start repeat)
CaseRepeatOpen      ldd       #$0003
                    lbra      SetMarkType
* ')': mark type 1 (end repeat)
CaseRepeatClose     ldd       #$0001
                    lbra      SetMarkType
* ':': current bar becomes type 3 and a new type-1 record is inserted (end + start repeat)
CaseRepeatBoth      ldd       #$0003
                    stb       5,u
                    ldd       #$0001
                    std       ,s
                    ldd       #$0001
                    stb       4,s
                    lbra      ApplyBarMark
* 'n': prompt 'Ending No. (1, 2, ...): ' via [$03A5], AtoI into byte 6, mark type 5
CaseEndingNo        clra
                    clrb
                    stb       7,s
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgEndingNo,pcr
                    pshs      x
                    leax      11,s
                    pshs      x
                    jsr       [>UmeData_pgetempty]
                    leas      6,s
                    lbeq      BarMenuLoop
                    leax      7,s
                    pshs      x
                    lbsr      AtoI
                    leas      2,s
                    stb       6,u
                    ldd       #$0005
                    lbra      SetMarkType
* '/': putchar CR, bar+1, ask the meter with [$0369] (sets <$03/<$05), mark type 10
CaseMeter           ldd       #$000D
                    pshs      a,b
                    jsr       [>UmeData_pputchar]
                    leas      2,s
                    ldd       <$5C,s
                    addd      #$0001
                    std       <$5C,s
                    jsr       [>UmeData_pgtsig]
                    ldd       #$000A
                    lbra      SetMarkType
* 'k': bar+1, mark type 11; key value from [$0367] (key-signature dialog) or a typed number via [$0359]+AtoI
CaseKeySig          ldd       <$5C,s
                    addd      #$0001
                    std       <$5C,s
                    ldd       #$000B
                    std       ,s
                    ldb       3,s
                    bgt       a19@
                    leax      7,s
                    pshs      x
                    jsr       [>UmeData_pgets]
                    leas      2,s
                    ldb       7,s
                    beq       a19@
                    leax      7,s
                    pshs      x
                    lbsr      AtoI
                    leas      2,s
                    bra       b19@
a19@                jsr       [>UmeData_pgksig]
b19@                std       5,s
                    lbra      ApplyBarMark
* 'd': asks 'DS, not DC?' and 'Skip repeats?' with [$03A1]; type = 17 + 2*DS + skip
CaseDaCapo          leax      >msgDSnotDC,pcr
                    pshs      x
                    jsr       [>UmeData_pyesno]
                    leas      2,s
                    sex
                    aslb
                    rola
                    addd      #$0011
                    pshs      a,b
                    leax      >msgSkipRepeats,pcr
                    pshs      x
                    jsr       [>UmeData_pyesno]
                    leas      2,s
                    sex
                    addd      ,s++
                    bra       SetMarkType
* '$': mark type 8, bar+1
CaseSegno           ldd       #$0008
                    std       ,s
                    ldd       <$5C,s
                    addd      #$0001
                    std       <$5C,s
                    lbra      ApplyBarMark
* 'c': mark type 9
CaseCoda            ldd       #$0009
                    bra       SetMarkType
* 's': mark type $15 (the 'S Space' item)
CaseSpaceMark       ldd       #$0015
* common: store the mark type at 0,s and go to ApplyBarMark
SetMarkType         std       ,s
                    lbra      ApplyBarMark
* 'l': OpenPanel(0), 'Type a 1- or 2-char label: ', [$0359] line read; mark type 7 with the two characters (bytes 3 and 6)
CaseLabel           clra
                    clrb
                    pshs      a,b
                    lbsr      OpenPanel
                    leas      2,s
                    leax      >msgTypeLabel,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    leax      7,s
                    pshs      x
                    jsr       [>UmeData_pgets]
                    leas      2,s
                    lbsr      ClosePanel
                    ldb       7,s
                    lbeq      BarMenuLoop
                    ldd       #$0007
                    std       ,s
                    ldb       7,s
                    stb       2,s
                    ldb       8,s
                    stb       3,s
                    bra       ApplyBarMark
* unknown key: BeepIfSound and back to BarMenuLoop
BadKeyBeep          lbsr      BeepIfSound
                    lbra      BarMenuLoop
* cmpx chain on the key: CR cancel, 1 2 f ( ) : n / k d $ c s l, else BadKeyBeep
BarMenuSwitch       cmpx      #$000D
                    lbeq      BarMarkCancel
                    cmpx      #$0031
                    lbeq      CasePlainBar
                    cmpx      #$0032
                    lbeq      CaseEnding2
                    cmpx      #$0066
                    lbeq      CaseFine
                    cmpx      #$0028
                    lbeq      CaseRepeatOpen
                    cmpx      #$0029
                    lbeq      CaseRepeatClose
                    cmpx      #$003A
                    lbeq      CaseRepeatBoth
                    cmpx      #$006E
                    lbeq      CaseEndingNo
                    cmpx      #$002F
                    lbeq      CaseMeter
                    cmpx      #$006B
                    lbeq      CaseKeySig
                    cmpx      #$0064
                    lbeq      CaseDaCapo
                    cmpx      #$0024
                    lbeq      CaseSegno
                    cmpx      #$0063
                    lbeq      CaseCoda
                    cmpx      #$0073
                    lbeq      CaseSpaceMark
                    cmpx      #$006C
                    lbeq      CaseLabel
                    bra       BadKeyBeep
* types <= 6 without the insert flag modify the record in place; otherwise InsertBarRec
ApplyBarMark        ldb       4,s
                    bne       InsertBarRec
                    ldd       ,s
                    cmpd      #$0006
                    ble       StoreBarType
* [$03B5](bar index) inserts a blank record and returns its address (0 -> cancel)
InsertBarRec        ldd       <$5C,s
                    pshs      a,b
                    jsr       [>UmeData_pmakroom]
                    leas      2,s
                    tfr       d,u
                    stu       -2,s
                    bne       SetKeyField
* return 0 (ENTER or no memory)
BarMarkCancel       clra
                    clrb
                    bra       EditBarExit
* type 11: byte 6 = key value
SetKeyField         ldd       ,s
                    cmpd      #$000B
                    bne       SetMeterField
                    ldd       5,s
                    bra       StoreMarkByte6
* type 10: byte 6 = <$03 numerator, byte 7 = <$05 denominator
SetMeterField       ldd       ,s
                    cmpd      #$000A
                    bne       SetLabelField
                    ldd       <UmeData_reserved_0003
                    stb       6,u
                    ldd       <UmeData_reserved_0005
                    stb       7,u
                    bra       StoreBarType
* type 7: byte 3 and byte 6 = the label characters
SetLabelField       ldd       ,s
                    cmpd      #$0007
                    bne       StoreBarType
                    ldb       2,s
                    stb       3,u
                    ldb       3,s
* stb 6,u shared by SetKeyField (key value) and SetLabelField (2nd label char) before StoreBarType
StoreMarkByte6      stb       6,u
* part byte 0 = 0, byte 5 = mark type, rfr_scr = 1 (redraw the score), return 1
StoreBarType        clra
                    clrb
                    stb       ,u
                    ldd       ,s
                    stb       5,u
                    ldd       #$0001
                    stb       <UmeData_rfr_scr
                    ldd       #$0001
* EditBarMark frame teardown
EditBarExit         leas      <$58,s
                    puls      u,pc
* AddBars(noteIdx, firstBar, count, startTimeLong) ('B'): pfindts ($0391) sets the meter in force; records per bar = beats * nparts + 1 (compound: beats = 2*numerator/3); count shrinks until the score fits; then count bars of rests for every non-clone part
AddBars             pshs      u
                    leas      <-$15,s
                    ldd       <$19,s
                    pshs      a,b
                    jsr       [>UmeData_pfindts]
                    leas      2,s
                    ldd       <UmeData_nevents
                    std       14,s
                    ldd       <UmeData_nparts
                    pshs      a,b
                    ldb       <UmeData_tripper
                    beq       a20@
                    ldd       <UmeData_reserved_0003
                    addd      <UmeData_reserved_0003
                    pshs      a,b
                    ldd       #$0003
                    lbsr      DivS16
                    bra       RecsPerBar
a20@                ldd       <UmeData_reserved_0003
* MulU16(beats, nparts parts) + 1 = records per bar
RecsPerBar          lbsr      MulU16
                    addd      #$0001
                    std       2,s
* count <= 0 -> 'No more bars; out of memory!' and return 0
BarFitLoop          ldd       <$1D,s
                    bgt       BarFitTry
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgNoMoreBars,pcr
                    pshs      x
                    jsr       [>UmeData_palert]
                    leas      4,s
                    clra
                    clrb
                    lbra      AddBarsExit
* new count = count*recsPerBar + nevents + 1; must be < $7FFF and NoteAddr(new-1) must map
BarFitTry           ldd       <$1D,s
                    pshs      a,b
                    ldd       4,s
                    lbsr      MulU16
                    addd      <UmeData_nevents
                    addd      #$0001
                    std       12,s
                    cmpd      #$7FFF
                    bge       BarCountDec
                    ldd       12,s
                    addd      #$FFFF
                    pshs      a,b
                    lbsr      NoteAddr
                    std       ,s++
                    bne       BarsAlloc
* count-- and retry
BarCountDec         ldd       <$1D,s
                    addd      #$FFFF
                    std       <$1D,s
                    bra       BarFitLoop
* commit the new event count, Copy5 the rest template $0115 into the frame (byte 7 = 2), last bar = firstBar+count-1, U = NoteAddr(noteIdx)
BarsAlloc           ldd       12,s
                    std       <UmeData_nevents
                    ldx       #$0115
                    pshs      x
                    leax      <$12,s
                    pshs      x
                    lbsr      Copy5
                    leas      4,s
                    ldd       #$0002
                    stb       <$14,s
                    ldd       <$1B,s
                    addd      <$1D,s
                    addd      #$FFFF
                    std       4,s
                    ldd       <$19,s
                    pshs      a,b
                    lbsr      NoteAddr
                    leas      2,s
                    tfr       d,u
                    ldd       14,s
                    addd      #$FFFF
                    cmpd      <$19,s
                    bne       RestTemplate
                    ldb       ,u
                    bne       SkipLastRec
                    ldb       5,u
                    cmpb      #$06
                    ble       RestTemplate
* if the insertion point is the last record and it is a non-bar system record, step past it
SkipLastRec         lbsr      NextNoteAddr
                    tfr       d,u
                    ldd       <UmeData_curind
                    std       <$19,s
* rest duration code dencodur and length dendur; compound time: one value longer, dotted, length * 3
RestTemplate        ldb       <UmeData_tripper
                    beq       a21@
                    ldd       <UmeData_dencodur
                    addd      #$FFFF
                    stb       <$10,s
                    ldd       #$0001
                    stb       <$11,s
                    ldd       <UmeData_dendur
                    pshs      a,b
                    ldd       #$0003
                    lbsr      MulU16
                    bra       b21@
a21@                ldd       <UmeData_dencodur
                    stb       <$10,s
                    ldd       <UmeData_dendur
b21@                std       ,s
                    ldd       <$1B,s
                    std       10,s
                    lbra      BarLoopTest
* write a bar record: part 0, type 0 (except the first), time, bar number
NewBarRec           clra
                    clrb
                    stb       ,u
                    ldd       14,s
                    addd      #$FFFF
                    cmpd      <$19,s
                    beq       a22@
                    clra
                    clrb
                    stb       5,u
a22@                ldd       <$21,s
                    std       1,u
                    ldd       10,s
                    std       3,u
                    lbsr      NextNoteAddr
                    tfr       d,u
                    ldd       #$0001
                    lbra      BeatTest
* beat loop: in compound time only every third beat gets rests (ModS16(beat,3) == 1)
BeatLoop            ldb       <UmeData_tripper
                    beq       a23@
                    ldd       6,s
                    pshs      a,b
                    ldd       #$0003
                    lbsr      ModS16
                    cmpd      #$0001
                    lbne      BeatLoopNext
a23@                ldd       #$0001
                    bra       PartRestTest
* for each part whose flags bit 2 (clone) is clear: Copy5 template into bytes 3-7, time, part number; NextNoteAddr
PartRestLoop        ldd       8,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$0C5F
                    leax      d,x
                    ldd       2,x
                    clra
                    andb      #$04
                    bne       a24@                a clone (flags bit 2) gets no rests of its own
                    leax      <$10,s
                    pshs      x
                    pshs      u
                    ldd       #$0003
                    addd      ,s++
                    pshs      a,b
                    lbsr      Copy5
                    leas      4,s
                    ldd       <$21,s
                    std       1,u
                    ldd       8,s
                    stb       ,u
                    lbsr      NextNoteAddr
                    tfr       d,u
a24@                ldd       8,s
                    addd      #$0001
* part loop test (part <= nparts and index < $7FFF)
PartRestTest        std       8,s
                    ldd       8,s
                    cmpd      <UmeData_nparts
                    bgt       AdvanceTime
                    ldd       <UmeData_curind
                    cmpd      #$7FFF
                    blt       PartRestLoop
* long time += rest length (LongFromInt, LongAdd, LongCopy)
AdvanceTime         leax      <$1F,s
                    pshs      x
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       6,s
                    lbsr      LongFromInt
                    lbsr      LongAdd
                    lbsr      LongCopy
* beat++ into BeatTest; BeatLoop branches here for compound-time beats that get no rests
BeatLoopNext        ldd       6,s
                    addd      #$0001
* beat loop test (beat <= <$03); then bar number and index advance
BeatTest            std       6,s
                    ldd       6,s
                    cmpd      <UmeData_reserved_0003
                    lble      BeatLoop
                    ldd       10,s
                    addd      #$0001
                    std       10,s
                    subd      #$0001
                    ldd       <$19,s
                    addd      #$0001
                    std       <$19,s
                    subd      #$0001
* bar loop test; then the closing bar record, nevents, the end time at $0091 and nbars; returns count
BarLoopTest         ldd       10,s
                    cmpd      4,s
                    lble      NewBarRec
                    clra
                    clrb
                    stb       ,u
                    clra
                    clrb
                    stb       5,u
                    ldd       <$21,s
                    std       1,u
                    ldd       10,s
                    std       3,u
                    ldd       <UmeData_curind
                    addd      #$0001
                    std       <UmeData_nevents
                    ldx       #$0091
                    pshs      x
                    leax      <$21,s
                    lbsr      LongCopy
                    ldd       4,s
                    std       <UmeData_nbars
                    ldd       <$1D,s
* AddBars frame teardown
AddBarsExit         leas      <$15,s
                    puls      u,pc
* CR + '12():nf  /kd$csl': the key of each bar-mark menu row, indexed by the ptextmen pick
strBarMenuKeys      fcb       $0D
                    fcc       /12():nf  /
                    fcb       $2F
                    fcc       /kd$csl/
                    fcb       $00
msgEndingNo         fcc       /Ending No. (1, 2, ...): /
                    fcb       $00
msgDSnotDC          fcb       $0D
                    fcc       /DS, not DC?/
                    fcb       $00
msgSkipRepeats      fcc       /Skip repeats?/
                    fcb       $00
msgTypeLabel        fcc       /Type a 1- or 2-char label: /
                    fcb       $00
msgNoMoreBars       fcc       /No more bars; out of memory!/
                    fcb       $0D,$00
* InstrFileIO(path, write) ('i'): the 64 instrument slots ($075F patch words, $07EB 16-byte names). Write: pass 0 counts the used slots (patch != $80 or a name) and writes the count word and the record length $10; pass 1 writes slot, patch byte and 16-byte name of each. Read: count word (0 -> return 1), record length, then slot, patch and name per entry. Returns the status byte.
InstrFileIO         pshs      u
                    leas      <-$4F,s
                    ldd       #$0001
                    stb       ,s
                    ldb       <$56,s
                    lbeq      ReadInstrHdr
                    clra
                    clrb
                    lbra      WritePassTest
* start a write pass: entries written = 0, slot = 0, u = $07EB
WritePassInit       clra
                    clrb
                    std       8,s
                    clra
                    clrb
                    std       14,s
                    ldu       #$07EB
                    lbra      WritePassEnd
* skip slots with patch $80 and an empty name
WriteEntryLoop      ldd       14,s
                    aslb
                    rola
                    ldx       #$075F
                    leax      d,x
                    ldd       ,x
                    cmpd      #$0080
                    bne       WriteOneInstr
                    ldb       ,u
                    lbeq      WriteEntryNext
* count++; pass 1: WritePath slot byte, patch byte and the 16-byte name (status &= wrote 16)
WriteOneInstr       ldd       8,s
                    addd      #$0001
                    std       8,s
                    ldd       12,s
                    lbeq      WriteEntryNext
                    ldd       14,s
                    stb       1,s
                    ldd       #$0001
                    pshs      a,b
                    leax      3,s
                    pshs      x
                    ldd       <$57,s
                    pshs      a,b
                    lbsr      WritePath
                    leas      6,s
                    ldd       14,s
                    aslb
                    rola
                    ldx       #$075F
                    leax      d,x
                    ldd       ,x
                    stb       1,s
                    ldd       #$0001
                    pshs      a,b
                    leax      3,s
                    pshs      x
                    ldd       <$57,s
                    pshs      a,b
                    lbsr      WritePath
                    leas      6,s
                    ldb       ,s
                    sex
                    pshs      a,b
                    ldd       #$0010
                    pshs      a,b
                    pshs      u
                    ldd       <$59,s
                    pshs      a,b
                    lbsr      WritePath
                    leas      6,s
                    cmpd      #$0010
                    bne       a25@
                    ldd       #$0001
                    bra       b25@
a25@                clra
                    clrb
b25@                anda      ,s+
                    andb      ,s+
                    stb       ,s
* slot++, u += 16
WriteEntryNext      ldd       14,s
                    addd      #$0001
                    std       14,s
                    subd      #$0001
                    leau      <$10,u
* slot loop test (64); at the end of pass 0 write the 2-byte count and a $10 byte
WritePassEnd        ldd       14,s
                    cmpd      #$0040
                    lblt      WriteEntryLoop
                    ldd       12,s
                    bne       a26@
                    ldd       8,s
                    std       2,s
                    ldd       #$0002
                    pshs      a,b
                    leax      4,s
                    pshs      x
                    ldd       <$57,s
                    pshs      a,b
                    lbsr      WritePath
                    leas      6,s
                    ldd       #$0010
                    stb       1,s
                    ldd       #$0001
                    pshs      a,b
                    leax      3,s
                    pshs      x
                    ldd       <$57,s
                    pshs      a,b
                    lbsr      WritePath
                    leas      6,s
a26@                ldd       12,s
                    addd      #$0001
* pass loop test (0..1)
WritePassTest       std       12,s
                    ldd       12,s
                    cmpd      #$0001
                    lble      WritePassInit
                    lbra      InstrIORetVal
* read the 2-byte count; 0 -> return 1
ReadInstrHdr        ldd       #$0002
                    pshs      a,b
                    leax      4,s
                    pshs      x
                    ldd       <$57,s
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    std       4,s
                    bne       ReadRecLen
                    ldd       #$0001
                    lbra      InstrIOExit
* read the record-length byte (& $3F); a name keeps at most 15 characters
ReadRecLen          ldd       #$0001
                    pshs      a,b
                    leax      3,s
                    pshs      x
                    ldd       <$57,s
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    ldd       2,s
                    clra
                    std       8,s
                    ldb       1,s
                    clra
                    andb      #$3F
                    std       10,s
                    cmpd      #$0010
                    blt       a27@
                    ldd       #$000F
                    bra       b27@
a27@                ldd       10,s
                    addd      #$FFFF
b27@                std       6,s
                    lbra      ReadInstrTest
* read slot, patch and name bytes for one instrument
ReadInstrLoop       ldd       #$0001
                    pshs      a,b
                    leax      3,s
                    pshs      x
                    ldd       <$57,s
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    ldb       1,s
                    clra
                    std       14,s
                    ldd       #$0001
                    pshs      a,b
                    leax      3,s
                    pshs      x
                    ldd       <$57,s
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    ldb       ,s
                    sex
                    pshs      a,b
                    ldd       12,s
                    pshs      a,b
                    leax      <$14,s
                    pshs      x
                    ldd       <$59,s
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    cmpd      12,s
                    bne       a28@
                    ldd       #$0001
                    bra       StoreInstr
a28@                clra
                    clrb
* slot < 64: store the patch word at $075F and StrNCpy the name into $07EB, NUL-terminated
StoreInstr          anda      ,s+
                    andb      ,s+
                    stb       ,s
                    ldd       14,s
                    cmpd      #$0040
                    bge       a29@
                    ldd       14,s
                    aslb
                    rola
                    ldx       #$075F
                    leax      d,x
                    pshs      x
                    ldb       3,s
                    clra
                    std       [,s++]
                    ldd       14,s
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
                    leau      ,x
                    ldd       6,s
                    pshs      a,b
                    leax      <$12,s
                    pshs      x
                    pshs      u
                    lbsr      StrNCpy
                    leas      6,s
                    ldd       6,s
                    leax      d,u
                    clra
                    clrb
                    stb       ,x
a29@                ldd       8,s
                    addd      #$FFFF
                    std       8,s
* loop while entries remain
ReadInstrTest       ldd       8,s
                    lbne      ReadInstrLoop
* ldb ,s status byte before InstrIOExit; the write pass lbra's here, the read loop falls through
InstrIORetVal       ldb       ,s
* InstrFileIO frame teardown
InstrIOExit         leas      <$4F,s
                    puls      u,pc
* NoteAddr(index): curind = index; page = 1 + index/928, offset = index%928; page != curpage -> ppswap (D = 0 on failure); returns curevp = database + offset*8
NoteAddr            pshs      u
                    ldu       4,s
                    leas      -2,s
                    stu       <UmeData_curind
                    ldd       #$0001
                    bra       BlockDivTest
BlockDivNext        ldd       ,s
                    addd      #$0001
* subtract 928 per page until negative (stu -2,s only sets the flags)
BlockDivTest        std       ,s
                    leau      >-$03A0,u
                    stu       -2,s
                    bge       BlockDivNext
                    leau      >$03A0,u
                    ldd       ,s
                    cmpd      <UmeData_curpage
                    beq       NoteAddrCalc
                    ldd       ,s
                    pshs      a,b
                    jsr       [>UmeData_ppswap]
                    leas      2,s
                    bne       NoteAddrCalc
                    clra
                    clrb
                    bra       NoteAddrExit
* curevp = offset*8 + database
NoteAddrCalc        tfr       u,d
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    addd      <UmeData_database
                    std       <UmeData_curevp
* exit; a failed map arrives with D = 0
NoteAddrExit        leas      2,s
                    puls      u,pc
* NextNoteAddr: curind++ (pointer unchanged at nevents), curevp += 8; past curptop maps page curpage+1 and restarts at database; returns curevp
NextNoteAddr        pshs      u
                    ldd       <UmeData_curind
                    addd      #$0001
                    std       <UmeData_curind
                    cmpd      <UmeData_nevents
                    bge       NextNoteRet
                    ldd       <UmeData_curevp
                    addd      #$0008
                    std       <UmeData_curevp
                    cmpd      <UmeData_curptop
                    bls       NextNoteRet
                    ldd       <UmeData_curpage
                    addd      #$0001
                    pshs      a,b
                    jsr       [>UmeData_ppswap]
                    leas      2,s
                    ldd       <UmeData_database
                    bra       a30@
                    fcb       $34,$40,$DC,$2B,$C3,$FF,$FF,$DD
                    fcb       $2B,$2D,$1D,$DC,$23,$C3,$FF,$F8
                    fcb       $DD,$23,$10,$93,$25,$24,$11,$DC
                    fcb       $2F,$C3,$FF,$FF,$34,$06,$AD,$9F
                    fcb       $03,$99,$32,$62,$DC,$27
a30@                std       <UmeData_curevp
NextNoteRet         ldd       <UmeData_curevp
                    puls      u,pc
* MemCopy(dst, src, n): byte copy loop from src to dst until src reaches src+n
MemCopy             ldd       4,s
                    addd      6,s
                    pshs      a,b,u
                    ldx       8,s
                    ldu       6,s
                    bra       MemCopyTest
MemCopyLoop         ldb       ,x+
                    stb       ,u+
* loop while source pointer below the end
MemCopyTest         cmpx      ,s
                    blo       MemCopyLoop
                    puls      a,b,u,pc
                    fcb       $EC,$64,$AE,$62,$34,$10,$30,$8B
                    fcb       $20,$12,$EC,$18,$ED,$84,$EC,$1A
                    fcb       $ED,$02,$EC,$1C,$ED,$04,$EC,$1E
                    fcb       $ED,$06,$30,$18,$AC,$E4,$22,$EA
                    fcb       $35,$90,$AE,$62,$EC,$64,$E3,$62
                    fcb       $34,$06,$20,$12,$EC,$08,$ED,$84
                    fcb       $EC,$0A,$ED,$02,$EC,$0C,$ED,$04
                    fcb       $EC,$0E,$ED,$06,$30,$08,$AC,$E4
                    fcb       $25,$EA,$35,$86
* Copy5(dst, src): copies 5 bytes (the rest template into record bytes 3-7)
Copy5               pshs      u
                    ldu       6,s
                    ldx       4,s
                    ldd       ,u
                    std       ,x
                    ldd       2,u
                    std       2,x
                    ldb       4,u
                    stb       4,x
                    puls      u,pc
* CopyRec8(dst, src): copies one 8-byte note record
CopyRec8            pshs      u
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
* StrNCpy(dst, src, n): copies up to n bytes stopping after NUL, zero-fills the rest, returns dst
StrNCpy             pshs      y,u
                    ldu       8,s
                    ldx       6,s
                    ldy       10,s
                    beq       StrNCpyRet
* copy bytes until the count or a NUL
StrNCpyLoop         ldb       ,u+
                    stb       ,x+
                    leay      -1,y
                    beq       StrNCpyRet
                    tstb
                    bne       StrNCpyLoop
* zero-fill the remaining bytes
StrNCpyFill         clr       ,x+
                    leay      -1,y
                    bne       StrNCpyFill
* StrNCpy returns dst (6,s): the n = 0 entry test and the count-exhausted branch both land here
StrNCpyRet          ldd       6,s
                    puls      y,u,pc
* AtoI(str): skips blanks/tabs, optional +/-, accumulates decimal digits (x10 via shifts), returns the signed value
AtoI                pshs      u
                    ldu       4,s
                    clra
                    clrb
                    pshs      a,b
                    pshs      b
* skip blanks and tabs, note a leading '-'
AtoISkipWS          ldb       ,u+
                    cmpb      #$20
                    beq       AtoISkipWS
                    cmpb      #$09
                    beq       AtoISkipWS
                    cmpb      #$2D
                    bne       a31@
                    stb       ,s
                    bra       AtoINextChar
a31@                cmpb      #$2B
                    bne       AtoIDigitChk
                    bra       AtoINextChar
* value = value*10 + digit
AtoIDigit           ldd       1,s
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
* fetches the next character (ldb ,u+) for AtoIDigitChk; both +/- arms of AtoISkipWS branch here
AtoINextChar        ldb       ,u+
* loop while the character is '0'..'9'
AtoIDigitChk        cmpb      #$30
                    blo       AtoISign
                    cmpb      #$39
                    bls       AtoIDigit
* negate the result when a '-' was seen
AtoISign            tst       ,s+
                    puls      a,b
                    beq       a32@
                    nega
                    negb
                    sbca      #$00
a32@                puls      u,pc
* adds the pushed 32-bit value to the long at X into the long accumulator $0343-$0346; returns X pointing at it (LongAccPtr)
LongAdd             ldd       4,s
                    addd      2,x
                    std       >$0345,y
                    ldd       2,s
                    adcb      1,x
                    adca      ,x
                    std       >$0343,y
                    lbra      LongAccPtr
                    fcb       $EC,$64,$A3,$02,$ED,$A9,$03,$45
                    fcb       $EC,$62,$E2,$01,$A2,$84,$ED,$A9
                    fcb       $03,$43,$16,$00,$2F
* sign-extends D into the long accumulator $0343 and returns X = its address
LongFromInt         leax      >$0343,y
                    std       2,x
                    tfr       a,b
                    sex
                    tfr       a,b
                    std       ,x
                    rts
                    fcb       $30,$A9,$03,$43,$ED,$02,$6F,$84
                    fcb       $6F,$01,$39
* copies the 4-byte long at X to the pushed destination pointer
LongCopy            pshs      y
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
* tail of LongAdd: drops the pushed argument and returns X = $0343 long accumulator
LongAccPtr          tfr       cc,a
                    puls      x
                    stx       2,s
                    leas      2,s
                    leax      >$0343,y
                    tfr       a,cc
                    rts
                    fcb       $EC,$84,$ED,$A9,$03,$43,$EC,$02
                    fcb       $30,$A9,$03,$43,$ED,$02,$39
* C runtime 16x16 -> 32 multiply of D by the pushed word; result low word in D, high word in X (fast path when both high bytes are zero)
MulU16              tsta
                    bne       MulU16Long
                    tst       2,s
                    bne       MulU16Long
                    lda       3,s
                    mul
                    ldx       ,s
                    stx       2,s
                    ldx       #$0000
                    std       ,s
                    puls      a,b,pc
* four-partial-product path of MulU16
MulU16Long          pshs      a,b
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
                    bhs       a33@
                    inc       ,s
a33@                lda       4,s
                    ldb       9,s
                    mul
                    addd      1,s
                    std       1,s
                    bhs       b33@
                    inc       ,s
b33@                lda       4,s
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
* C runtime signed remainder: pushed word mod D via DivS16 (function pointer at $0CCD, sign flag at $0CCC); divisor 0 returns the dividend
ModS16              leax      >DivS16,pcr
                    stx       >$0CCD,y
                    clr       >$0CCC,y
                    tst       2,s
                    bpl       a34@
                    inc       >$0CCC,y
a34@                subd      #$0000
                    bne       ModDivide
                    puls      x
                    ldd       ,s++
                    jmp       ,x
* call DivS16 and sign-adjust the remainder from X
ModDivide           ldx       2,s
                    pshs      x
                    jsr       [>$0CCD,y]
                    ldd       ,s
                    std       2,s
                    tfr       x,d
                    tst       >$0CCC,y
                    beq       a35@
                    nega
                    negb
                    sbca      #$00
a35@                std       ,s++
                    rts
                    fcb       $83,$00,$00,$27,$0A,$34,$06
                    fcs       /2~od/
                    fcc       /oa ./
* division by zero: error 45 ($2D) -> RaiseSignal
DivZeroTrap         puls      a,b
                    std       ,s
                    ldd       #$002D
                    lbra      RaiseSignal
* C runtime signed 16-bit divide: pushed dividend / D divisor by shift-subtract; returns quotient in D, remainder in X
DivS16              subd      #$0000
                    beq       DivZeroTrap
                    pshs      a,b
                    leas      -2,s
                    clr       ,s
                    clr       1,s
                    tsta
                    bpl       a36@
                    nega
                    negb
                    sbca      #$00
                    com       1,s
                    std       2,s
a36@                ldd       6,s
                    bpl       b36@
                    nega
                    negb
                    sbca      #$00
                    com       1,s
                    std       6,s
b36@                lda       #$01
* normalize the divisor, counting the shift
DivNormLoop         inca
                    asl       3,s
                    rol       2,s
                    bpl       DivNormLoop
                    sta       ,s
                    ldd       6,s
                    clr       6,s
                    clr       7,s
* subtract-and-shift loop building the quotient bits
DivStepLoop         subd      2,s
                    bhs       a37@
                    addd      2,s
                    andcc     #$FE
                    bra       b37@
a37@                orcc      #$01
b37@                rol       7,s
                    rol       6,s
                    lsr       2,s
                    ror       3,s
                    dec       ,s
                    bne       DivStepLoop
                    std       2,s
                    tst       1,s
                    beq       DivRet
                    ldd       6,s
                    nega
                    negb
                    sbca      #$00
                    std       6,s
* apply the signs and return quotient D, remainder X
DivRet              ldx       4,s
                    ldd       6,s
                    std       4,s
                    stx       6,s
                    ldx       2,s
                    ldd       4,s
                    leas      6,s
                    rts
                    fcb       $5D,$27,$13
                    fcs       /gbfcZ&y/
                    fcb       $20,$0A,$5D,$27,$07
                    fcs       /dbfcZ&y/
* exit of LShift16: returns the shifted word and pops the argument
ShiftRet            ldd       2,s
                    pshs      a,b
                    ldd       2,s
                    std       4,s
                    ldd       ,s
                    leas      4,s
                    rts
* C runtime: pushed word << B (used to place the data-byte count in bits 5-6 of a system event)
LShift16            tstb
                    beq       ShiftRet
* asl/rol B times
LShiftLoop          asl       3,s
                    rol       2,s
                    decb
                    bne       LShiftLoop
                    bra       ShiftRet
* stores D as errno at $034F, F$ID for the own process id, then F$Send of signal B to itself
RaiseSignal         std       >$034F,y
                    pshs      b,y
                    os9       F$ID
                    puls      b,y
                    os9       F$Send
                    rts
* ReadPath(path, buf, n): I$Read wrapper; returns bytes read, 0 at E$EOF ($D3), else ErrReturn
ReadPath            pshs      y
                    ldx       6,s
                    lda       5,s
                    ldy       8,s
                    pshs      y
                    os9       I$Read
                    bhs       b38@
                    cmpb      #$D3
                    bne       a38@
                    clra
                    clrb
                    puls      x,y,pc
a38@                puls      x,y
                    lbra      ErrReturn
b38@                tfr       y,d
                    puls      x,y,pc
                    fcb       $34,$20,$A6,$65,$AE,$66,$10,$AE
                    fcc       /h4 /
                    fcb       $10,$3F,$8B,$20,$DD
* WritePath(path, buf, n): I$Write wrapper (n = 0 returns 0); returns n or ErrReturn
WritePath           pshs      y
                    ldy       8,s
                    beq       a39@
                    lda       5,s
                    ldx       6,s
                    os9       I$Write
                    bhs       a39@
                    puls      y
                    lbra      ErrReturn
a39@                tfr       y,d
                    puls      y,pc
                    fcb       $34,$20,$10,$AE,$68,$27,$F5,$A6
                    fcb       $65,$AE,$66,$10,$3F,$8C,$20,$E5
                    fcb       $39,$8E,$00,$00,$5F,$10,$3F,$0A
                    fcb       $16,$00
                    fcs       /'94`./
                    fcb       $66,$10,$AE,$68,$EE,$6A,$10,$3F
                    fcb       $17,$35,$E0,$A6,$63,$E6,$65,$10
                    fcb       $3F,$0F,$10,$25,$00,$0D,$39
* SleepTicks(ticks): F$Sleep wrapper returning the remaining ticks
SleepTicks          ldx       2,s
                    os9       F$Sleep
                    lblo      ErrReturn
                    tfr       x,d
                    rts
* common system-call failure: errno $034F = B, return -1
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
                    fcc       /s9e/
                    fcb       $00

                    emod
eom                 equ       *
                    end
