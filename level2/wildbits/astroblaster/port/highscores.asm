* Per-process 99-score history, matching the original $3FCB/$40D4 table.
* Scores remain packed BCD in tens; comparisons are unsigned words.
* X game/Y video/U process unless noted. Preserve all unless specified.
* Initials accept typed A-Z, Backspace and Enter, or left/right and Space.
* All input is nonblocking SS.LiveKeys; Escape remains the global exit.

UpdatePlayerRanks pshs     d,x,y,u
                    leay      GS_ScorePlayer1,x
                    leau      GS_RankPlayer1,x
                    bsr       RankOnePlayer
                    leay      GS_ScorePlayer2,x
                    leau      GS_RankPlayer2,x
                    bsr       RankOnePlayer
                    puls      d,x,y,u,pc
* X game/Y score/U two separate decimal rank digits. Preserve X,Y,U.
RankOnePlayer    pshs      x,y,u
                    ldd       ,y
                    bne       RankNonzeroScore
                    ldd       #GS_BCD0909
                    std       ,u
                    puls      x,y,u,pc
RankNonzeroScore
                    leay      GS_HighScores,x
                    pshs      d         stack offset 0: score to rank
                    clr       ,u
                    lda       #1
                    sta       1,u
RankNextScore    ldd       ,s        stack offset: saved score
                    cmpd      ,y++
                    bhs       RankPlayerDone
                    lda       1,u
                    cmpa      #9
                    bne       RankIncrementUnits
                    lda       ,u
                    cmpa      #9
                    beq       RankPlayerDone
                    inc       ,u
                    clr       1,u
                    bra       RankNextScore
RankIncrementUnits inc    1,u
                    bra       RankNextScore
RankPlayerDone   leas      2,s
                    puls      x,y,u,pc

* X game/Y video. Record one player at a time so inserted names remain
* associated with their scores even when both players enter the top ten.
BeginScoreRecords
                    clr       GS_RecordPlayer,x
RecordNextPlayer lda       GS_RecordPlayer,x
                    cmpa      GS_PlayerMode,x
                    lbhs      FinishScoreRecords
                    lbsr      InsertPlayerRecord
                    lda       GS_RecordRank,x
                    cmpa      #SCORE_INITIAL_RANKS
                    blo       BeginRecordInitials
                    inc       GS_RecordPlayer,x
                    bra       RecordNextPlayer
BeginRecordInitials
                    pshs      d,x,y,u
                    ldb       #SCORE_INITIALS_BYTES
                    mul
                    leay      GS_Initials,x
                    leay      d,y
                    sty       GS_RecordPointer,x
                    lda       #SCORE_INITIAL_FIRST
                    sta       ,y
                    sta       1,y
                    sta       2,y
                    clr       GS_RecordLetter,x
                    ldd       #SCORE_ENTRY_TICKS
                    std       GS_RecordClock,x
                    ldb       AD_Buttons,u
                    stb       GS_RecordButtons,x
                    lbsr      SaveRecordKeys ; ignore keys held on arrival
                    lda       #PHASE_INITIALS
                    sta       GS_Phase,x
                    lbsr      DrawRecordScreen
                    puls      d,x,y,u,pc

* X game; preserves D,X,Y,U. GS_RecordRank=99 if score does not qualify.
InsertPlayerRecord
                    pshs      d,x,y,u
                    leas      -HS_FrameBytes,s
                    lda       GS_RecordPlayer,x
                    lsla
                    leay      GS_ScorePlayer1,x
                    ldd       a,y
                    std       HS_Value,s ; stack offset: candidate score
                    lda       #SCORE_TABLE_COUNT
                    sta       GS_RecordRank,x
                    ldd       HS_Value,s ; stack offset
                    lbeq      InsertRecordReturn
                    leay      GS_HighScores,x
                    clrb
FindRecordRank   pshs      b         stack offset: candidate index
                    ldd       HS_Value+1,s ; stack offset: score under index
                    cmpd      ,y
                    puls      b
                    bhs       InsertRecordFound
                    leay      2,y
                    incb
                    cmpb      #SCORE_TABLE_COUNT
                    blo       FindRecordRank
                    lbra      InsertRecordReturn
InsertRecordFound
                    stb       GS_RecordRank,x
                    sty       HS_Insert,s ; stack offset: insertion location
                    leau      GS_HighScores+SCORE_TABLE_BYTES-2,x
ShiftScoreTable  cmpu      HS_Insert,s ; stack offset
                    beq       InsertScoreValue
                    ldd       -2,u
                    std       ,u
                    leau      -2,u
                    bra       ShiftScoreTable
InsertScoreValue ldd       HS_Value,s ; stack offset
                    std       ,u
                    ldb       GS_RecordRank,x
                    cmpb      #SCORE_INITIAL_RANKS
                    bhs       InsertRecordReturn
                    lslb
                    lslb
                    leay      GS_Initials,x
                    leay      b,y
                    sty       HS_Insert,s ; stack offset: initials slot
                    leau      GS_Initials+(SCORE_INITIAL_RANKS-1)*SCORE_INITIALS_BYTES,x
ShiftInitials   cmpu      HS_Insert,s ; stack offset
                    beq       InsertRecordReturn
                    ldd       -4,u
                    std       ,u
                    ldd       -2,u
                    std       2,u
                    leau      -SCORE_INITIALS_BYTES,u
                    bra       ShiftInitials
InsertRecordReturn
                    leas      HS_FrameBytes,s
                    puls      d,x,y,u,pc

UpdateRecordInitials
                    ldd       GS_RecordClock,x
                    subd      #1
                    std       GS_RecordClock,x
                    lbeq      RecordInitialsDone
                    ldb       AD_Buttons,u
                    lda       GS_RecordButtons,x
                    stb       GS_RecordButtons,x
                    coma
                    pshs      b
                    anda      ,s+       stack offset: current button mask
                    pshs      a         stack offset: new arrow/Space edges
                    lbsr      ReadRecordKey
                    tsta
                    beq       RecordArrowKeys
                    leas      1,s       discard saved button edges
                    cmpa      #KEY_ENTER
                    beq       RecordInitialsDone
                    cmpa      #KEY_BACKSPACE
                    beq       RecordBackspace
                    anda      #$DF      lowercase ASCII to uppercase
                    adda      #SCORE_INITIAL_FIRST-'A
                    pshs      y         stack offset: video base
                    ldy       GS_RecordPointer,x
                    ldb       GS_RecordLetter,x
                    sta       b,y
                    puls      y
                    bra       RecordAcceptLetter
RecordBackspace  tst       GS_RecordLetter,x
                    beq       RecordRedrawInitials
                    dec       GS_RecordLetter,x
                    pshs      y         stack offset: video base
                    ldy       GS_RecordPointer,x
                    ldb       GS_RecordLetter,x
                    lda       #SCORE_INITIAL_FIRST
                    sta       b,y
                    puls      y
RecordRedrawInitials
                    lbra      DrawEntryInitials
RecordArrowKeys  puls      a
                    bita      #CONTROL_FIRE
                    bne       RecordAcceptLetter
                    pshs      a,y
                    ldy       GS_RecordPointer,x
                    ldb       GS_RecordLetter,x
                    leay      b,y
                    bita      #CONTROL_LEFT
                    beq       RecordCheckRight
                    dec       ,y
                    lda       ,y
                    cmpa      #SCORE_INITIAL_FIRST
                    bhs       RecordLetterChanged
                    lda       #SCORE_INITIAL_LAST
                    sta       ,y
                    bra       RecordLetterChanged
RecordCheckRight bita      #CONTROL_RIGHT
                    beq       RecordLetterChanged
                    inc       ,y
                    lda       ,y
                    cmpa      #SCORE_INITIAL_LAST
                    bls       RecordLetterChanged
                    lda       #SCORE_INITIAL_FIRST
                    sta       ,y
RecordLetterChanged
                    puls      a,y
                    lbra      DrawEntryInitials
RecordAcceptLetter
                    inc       GS_RecordLetter,x
                    lda       GS_RecordLetter,x
                    cmpa      #SCORE_INITIAL_COUNT
                    lblo      DrawEntryInitials
RecordInitialsDone
                    inc       GS_RecordPlayer,x
                    lbra      RecordNextPlayer
FinishScoreRecords
                    lda       #PHASE_GAME_OVER
                    sta       GS_Phase,x
                    lda       #SCORE_TITLE_TICKS
                    sta       GS_PhaseClock,x
                    lbra      DrawHighScoreScreen

* X game/U process. Return A = one newly pressed A-Z, Backspace or Enter,
* zero if none. Preserve B,X,Y,U. Compare the whole previous held-key list:
* releasing another key may reorder the live slots, but is not a new press.
ReadRecordKey   pshs      b,x,y
                    leas      -IE_FrameBytes,s
                    clr       IE_Key,s
                    leay      GS_RecordKeys,x
                    leax      AD_Keys+ASTRO_KEY_CODES,u
                    ldb       #ASTRO_LIVEKEY_BYTES
RecordScanKey   lda       ,x+
                    cmpa      #KEY_BACKSPACE
                    beq       RecordFindHeldKey
                    cmpa      #KEY_ENTER
                    beq       RecordFindHeldKey
                    cmpa      #'A
                    blo       RecordNextKey
                    cmpa      #'Z
                    bls       RecordFindHeldKey
                    cmpa      #'a
                    blo       RecordNextKey
                    cmpa      #'z
                    bhi       RecordNextKey
RecordFindHeldKey
                    pshs      b,y       stack offsets: outer count, prior-key base
                    ldb       #ASTRO_LIVEKEY_BYTES
RecordCompareKey cmpa     ,y+
                    beq       RecordHeldKey
                    decb
                    bne       RecordCompareKey
                    sta       IE_Key+IE_SearchBytes,s ; stack offset: new key
RecordHeldKey   puls      b,y
                    tst       IE_Key,s
                    bne       RecordKeyReady
RecordNextKey   decb
                    bne       RecordScanKey
RecordKeyReady  ldx       IE_Game,s ; stack offset: game base
                    bsr       SaveRecordKeys
                    lda       IE_Key,s
                    leas      IE_FrameBytes,s
                    puls      b,x,y,pc

* X game/U process. Snapshot all six SS.LiveKeys codes; D/CC scratch.
SaveRecordKeys  ldd       AD_Keys+ASTRO_KEY_CODES,u
                    std       GS_RecordKeys,x
                    ldd       AD_Keys+ASTRO_KEY_CODES+2,u
                    std       GS_RecordKeys+2,x
                    ldd       AD_Keys+ASTRO_KEY_CODES+4,u
                    std       GS_RecordKeys+4,x
                    rts

DrawRecordScreen pshs      d,x,y,u
                    leax      AD_Video,u
                    lbsr      InitializePlayfieldTiles
                    leay      AD_Video,u
                    leax      RecordTitle,pcr
                    lda       #8
                    lbsr      DrawCenteredTiles
                    leax      RecordHelp,pcr
                    lda       #22
                    lbsr      DrawCenteredTiles
                    leax      RecordFire,pcr
                    lda       #25
                    lbsr      DrawCenteredTiles
                    leax      AD_Game,u
                    lbsr      DrawEntryInitials
                    puls      d,x,y,u,pc
DrawEntryInitials pshs     d,x,y,u
                    ldu       GS_RecordPointer,x
                    leay      SCORE_INITIAL_CELL,y
                    ldb       #SCORE_INITIAL_COUNT
RecordDrawLetter lda       ,u+
                    sta       ,y
                    leay      G80_TILEMAP_STRIDE,y
                    decb
                    bne       RecordDrawLetter
                    ldy       WI_Video,s ; stack offset: saved video
                    leay      SCORE_INITIAL_CELL-1,y
                    lda       #G80_BLANK_TILE
                    sta       ,y
                    sta       G80_TILEMAP_STRIDE,y
                    sta       2*G80_TILEMAP_STRIDE,y
                    ldb       GS_RecordLetter,x
                    lda       #G80_TILEMAP_STRIDE
                    mul
                    lda       #$64       original asterisk glyph
                    sta       b,y
                    puls      d,x,y,u,pc

DrawHighScoreScreen pshs   d,x,y,u
                    tfr       y,x
                    lbsr      InitializePlayfieldTiles
                    leax      HighScoreTitle,pcr
                    lda       #6
                    lbsr      DrawCenteredTiles
                    ldx       WI_Game,s ; stack offset: saved game
                    lda       #1
                    sta       GS_ScoreAltDigits,x
                    clrb
HighScoreDrawOne pshs      b,x,y
                    leau      GS_HighScores,x
                    lslb
                    ldd       b,u
                    exg       x,y
                    leax      SCORE_TOP_CELL,x
                    lbsr      DrawPackedScore
                    puls      b,x,y
                    pshs      b,x,y
                    lslb
                    lslb
                    leax      GS_Initials,x
                    leax      b,x
                    leay      SCORE_TOP_NAME_CELL,y
                    ldb       #SCORE_INITIAL_COUNT
                    lbsr      DrawStatusTileRun
                    puls      b,x,y
                    leay      -3,y       upright rows advance against native X
                    incb
                    cmpb      #SCORE_TOP_COUNT
                    blo       HighScoreDrawOne
                    clr       GS_ScoreAltDigits,x
                    puls      d,x,y,u,pc

RecordTitle       fcb       $4E,$57,$5D,$4E,$5B,$20,$52,$57,$52,$5D,$52,$4A,$55,$5C,$80
RecordHelp        fcb       $5D,$62,$59,$4E,$20,$58,$5B,$20,$5E,$5C,$4E,$20,$4A,$5B,$5B,$58,$60,$5C,$80
* "ENTER ACCEPTS  ESC EXITS" in the original game's alphabet.
RecordFire        fcb       $4E,$57,$5D,$4E,$5B,$20,$4A,$4C,$4C,$4E,$59,$5D,$5C,$20,$20,$4E,$5C,$4C,$20,$4E,$61,$52,$5D,$5C,$80
HighScoreTitle    fcb       $51,$52,$50,$51,$20,$5C,$4C,$58,$5B,$4E,$5C,$80
