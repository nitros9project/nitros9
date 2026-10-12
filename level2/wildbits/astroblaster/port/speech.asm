* Original 8035-decoded SP0250 data, preloaded once into owned high RAM.
* No SD I/O in playback. ServiceSpeech may map ONE block, then releases it.
* FeedSpeech never maps, sleeps or busy-waits. Call it within drawing loops.
* U process base. All public service/event entries preserve D,X,Y,U.
InitializeSpeech
                    lda SP_Port
                    anda #$FE
                    cmpa #SP_Present
                    lbne SpeechInitAbsent
                    inc AD_Speech+SP_Enabled,u
                    lda #$FF
                    sta AD_Speech+SP_LastPhase,u
                    sta AD_Speech+SP_LastDemo,u
                    ldx #SP_AssetBlocks
                    lda #ASTRO_OUTPUT_PATH
                    ldb #SS.GfxAlloc
                    os9 I$SetStt
                    bcs SpeechInitReturn
                    stx AD_Speech+SP_FirstBlock,u
                    stx AD_Speech+SP_Block,u
                    inc AD_Speech+SP_OwnsBlocks,u
                    pshs u
                    ldx #SP_AssetOffset/65536
                    lda AD_AssetPath,u
                    ldu #SP_AssetOffset&$FFFF
                    os9 I$Seek
                    puls u
                    bcs SpeechInitReturn
                    ldd #SP_AssetBytes/SCREEN_BLOCK_BYTES
                    stb AD_Speech+SP_BufferCount,u
SpeechLoadBlock
                    lbsr MapSpeechBlock
                    bcs SpeechInitReturn
                    ldy #SCREEN_BLOCK_BYTES
                    tst AD_Speech+SP_BufferCount,u
                    bne SpeechLoadRead
                    ldy #SP_AssetBytes%SCREEN_BLOCK_BYTES
SpeechLoadRead       sty AD_Speech+SP_Remaining,u
                    lda AD_AssetPath,u
                    os9 I$Read
                    pshs cc,b,y
                    lbsr ReleaseDisplayMapping
                    puls cc,b,y
                    bcs SpeechInitReturn
                    cmpy AD_Speech+SP_Remaining,u
                    bne SpeechShortRead
                    tst AD_Speech+SP_BufferCount,u
                    beq SpeechLoaded
                    dec AD_Speech+SP_BufferCount,u
                    ldd AD_Speech+SP_Block,u
                    addd #1
                    std AD_Speech+SP_Block,u
                    bra SpeechLoadBlock
SpeechShortRead     ldb #E$EOF
                    orcc #1
SpeechInitReturn    rts
SpeechLoaded        clr AD_Speech+SP_Remaining,u
                    clr AD_Speech+SP_Remaining+1,u
SpeechInitAbsent    clrb
                    rts

* Uses the same single borrowed map slot as the bitmap; never simultaneous.
MapSpeechBlock      ldx AD_Speech+SP_Block,u
                    ldb #1
                    pshs u
                    os9 F$MapBlk
                    tfr u,x
                    puls u
                    bcs SpeechInitReturn
                    stx AP_MapAddress,u
                    inc AP_HasMapping,u
                    cmpx #LAST_SAFE_BLOCK_MAP
                    bls SpeechMapOK
                    ldb #E$MemFul
                    orcc #1
                    rts
SpeechMapOK         clrb
                    rts

* A = original phrase index. One pending announcement; current word finishes.
* Later event replaces pending event, never bytes already queued to the chip.
QueueSpeech         tst AD_Speech+SP_Enabled,u
                    beq SpeechQueueReturn
                    sta AD_Speech+SP_Pending,u
SpeechQueueReturn   rts

ServiceSpeech       pshs d,x,y
                    tst AD_Speech+SP_Enabled,u
                    lbeq SpeechServiceReturn
                    tst AP_Paused,u
                    lbne SpeechServiceReturn
                    clr AD_Speech+SP_Hushed,u
                    tst AP_HasMapping,u
                    lbne SpeechFeedOnly
                    tst AD_Speech+SP_BufferCount,u
                    lbne SpeechFeedOnly
                    ldd AD_Speech+SP_Remaining,u
                    lbne SpeechRefill
* Word boundaries are frame boundaries. Never interrupt a partially sent frame.
                    lda AD_Speech+SP_Pending,u
                    beq SpeechContinuePhrase
                    clr AD_Speech+SP_Pending,u
                    lsla
                    leax SpeechPhraseDirectory,pcr
                    ldd a,x
                    leax d,x
                    stx AD_Speech+SP_Sequence,u
SpeechContinuePhrase ldx AD_Speech+SP_Sequence,u
                    lbeq SpeechServiceReturn
                    ldb ,x+
                    stx AD_Speech+SP_Sequence,u
                    tstb
                    lbeq SpeechEndPhrase
                    decb
                    lda #SP_WordEntryBytes
                    mul
                    leax SpeechWordDirectory,pcr
                    leax d,x
                    clra
                    ldb ,x+
                    addd AD_Speech+SP_FirstBlock,u
                    std AD_Speech+SP_Block,u
                    ldd ,x++
                    std AD_Speech+SP_Offset,u
                    ldd ,x
                    std AD_Speech+SP_Remaining,u
SpeechRefill        ldd #SCREEN_BLOCK_BYTES
                    subd AD_Speech+SP_Offset,u
                    cmpd AD_Speech+SP_Remaining,u
                    bls SpeechRefillBound
                    ldd AD_Speech+SP_Remaining,u
SpeechRefillBound   cmpd #SP_BufferBytes
                    bls SpeechRefillSize
                    ldd #SP_BufferBytes
SpeechRefillSize    pshs d
                    lbsr MapSpeechBlock
                    bcs SpeechRefillError
                    ldd AD_Speech+SP_Offset,u
                    leax d,x
                    leay AD_Speech+SP_Buffer,u
                    sty AD_Speech+SP_BufferRead,u
                    ldb 1,s         stack offset: refill length low byte
SpeechCopyByte      lda ,x+
                    sta ,y+
                    decb
                    bne SpeechCopyByte
                    lbsr ReleaseDisplayMapping
                    bcs SpeechRefillError
                    puls d
                    stb AD_Speech+SP_BufferCount,u
                    pshs d
                    addd AD_Speech+SP_Offset,u
                    cmpd #SCREEN_BLOCK_BYTES
                    blo SpeechKeepBlock
                    subd #SCREEN_BLOCK_BYTES
                    inc AD_Speech+SP_Block+1,u
SpeechKeepBlock     std AD_Speech+SP_Offset,u
                    ldd AD_Speech+SP_Remaining,u
                    subd ,s++       stack offset: refill length
                    std AD_Speech+SP_Remaining,u
                    bra SpeechFeedOnly
SpeechRefillError   leas 2,s         discard saved refill length
                    stb AD_AssetError,u
                    bra SpeechServiceReturn
SpeechEndPhrase     lbsr QueueSpeechSilence
                    bra SpeechFeedOnly
QueueSpeechSilence  clra
                    clrb
                    std AD_Speech+SP_Sequence,u
* All-zero LPC frame silences the last excitation; hardware otherwise repeats it.
                    leax AD_Speech+SP_Buffer,u
                    stx AD_Speech+SP_BufferRead,u
                    ldb #SP_FrameBytes
                    stb AD_Speech+SP_BufferCount,u
SpeechZeroFrame     clr ,x+
                    decb
                    bne SpeechZeroFrame
                    rts
SpeechFeedOnly      lbsr FeedSpeech
SpeechServiceReturn puls d,x,y,pc

FeedSpeech          pshs d,x
                    tst AD_Speech+SP_Enabled,u
                    beq SpeechFeedReturn
                    tst AP_Paused,u
                    bne SpeechFeedReturn
                    bra SpeechFeedStart
* FeedSpeech without the pause test, for PauseSpeech. Preserve D,X,Y,U.
FeedSpeechNow       pshs d,x
SpeechFeedStart     ldx AD_Speech+SP_BufferRead,u
SpeechFeedByte      tst AD_Speech+SP_BufferCount,u
                    beq SpeechFeedReturn
* Only the flag/status/store are atomic, not the wait, phrase or frame.
                    pshs cc
                    orcc #IntMasks
                    lda SP_Port
                    bita #SP_Ready
                    beq SpeechFeedBusy
                    lda ,x+
                    sta SP_Port
                    puls cc
                    stx AD_Speech+SP_BufferRead,u
                    dec AD_Speech+SP_BufferCount,u
                    inc AD_Speech+SP_FramePosition,u
                    lda AD_Speech+SP_FramePosition,u
                    cmpa #SP_FrameBytes
                    blo SpeechFeedByte
                    clr AD_Speech+SP_FramePosition,u
                    bra SpeechFeedByte
SpeechFeedBusy      puls cc
SpeechFeedReturn    puls d,x,pc

* Main context, while the terminal is in the background. Drop the phrase and
* its queued bytes, complete a partly sent frame with zeros and send one
* all-zero frame: the chip goes silent instead of repeating its last frame.
* Called each pause-wait pass until the bytes are out. Preserve D,X,Y,U.
PauseSpeech         pshs d,x
                    tst AD_Speech+SP_Enabled,u
                    beq PauseSpeechReturn
                    tst AP_Paused,u
                    beq PauseSpeechReturn
                    tst AD_Speech+SP_Hushed,u
                    bne PauseSpeechFeed
                    inc AD_Speech+SP_Hushed,u
                    clr AD_Speech+SP_Pending,u
                    clra
                    clrb
                    std AD_Speech+SP_Sequence,u
                    std AD_Speech+SP_Remaining,u
                    ldb #SP_FrameBytes
                    subb AD_Speech+SP_FramePosition,u rest of a partly sent frame
                    cmpb #SP_FrameBytes
                    beq PauseSpeechZero none: just the silent frame
                    addb #SP_FrameBytes then the silent frame
PauseSpeechZero     stb AD_Speech+SP_BufferCount,u
                    leax AD_Speech+SP_Buffer,u
                    stx AD_Speech+SP_BufferRead,u
PauseSpeechClear    clr ,x+
                    decb
                    bne PauseSpeechClear
PauseSpeechFeed     lbsr FeedSpeechNow
PauseSpeechReturn   puls d,x,pc

* Speech follows the original event classes and original phrase indexes.
UpdateSpeechEvents  pshs d,x,y
                    leax AD_Game,u
                    lda GS_Phase,x
                    cmpa AD_Speech+SP_LastPhase,u
                    beq SpeechCheckSector
                    ldb AD_Speech+SP_LastPhase,u
                    sta AD_Speech+SP_LastPhase,u
                    cmpa #PHASE_GAME_OVER
                    bne SpeechNotOver
* The high-score table after initials returns to the game-over phase: the
* phrase was already spoken when the game ended.
                    cmpb #PHASE_INITIALS
                    lbeq SpeechRecordEvents
                    bra SpeechGameOverEvent
SpeechNotOver       cmpa #PHASE_PLAY
                    bne SpeechCheckSector
                    tst GS_DemoActive,x
                    lbne SpeechRecordEvents
                    clr AD_Speech+SP_LastLevel,u
                    bra SpeechCheckSector
SpeechGameOverEvent lda #SP_PhraseGameOver
                    lbsr QueueSpeech
                    lbra SpeechRecordEvents
SpeechCheckSector  tst GS_DemoActive,x
                    lbne SpeechRecordEvents
                    lda GS_Phase,x  play events only: the title is not sector 1
                    cmpa #PHASE_PLAY
                    lbne SpeechRecordEvents
                    lda GS_Level,x
                    cmpa AD_Speech+SP_LastLevel,u
                    bne SpeechSectorEvent
                    lda GS_CurrentPlayer,x
                    cmpa AD_Speech+SP_LastPlayer,u
                    beq SpeechCheckFuel
SpeechSectorEvent  lda GS_Level,x
                    deca
                    anda #7
                    adda #SP_PhraseSector
                    tst GS_CurrentPlayer,x
                    beq SpeechQueueSector
                    adda #8
SpeechQueueSector  lbsr QueueSpeech
                    lbra SpeechRecordEvents
SpeechCheckFuel    lda GS_FuelLevel,x
                    cmpa AD_Speech+SP_LastFuel,u
                    beq SpeechCheckHeat
                    cmpa #8
                    beq SpeechLowFuel
                    cmpa #2
                    bne SpeechCheckHeat
                    lda #SP_PhraseCriticalFuel
                    bra SpeechQueueFuel
SpeechLowFuel      lda #SP_PhraseLowFuel
SpeechQueueFuel    lbsr QueueSpeech
SpeechCheckHeat    lda GS_LaserLocked,x
                    cmpa AD_Speech+SP_LastLock,u
                    beq SpeechHeatWarning
                    tsta
                    beq SpeechCoolEvent
                    lda #SP_PhraseLocked
                    bra SpeechQueueHeat
SpeechCoolEvent    lda #SP_PhraseCooled
                    bra SpeechQueueHeat
SpeechHeatWarning  lda GS_HeatUnits,x
                    cmpa #10
                    bne SpeechCheckDock
                    cmpa AD_Speech+SP_LastHeat,u
                    beq SpeechCheckDock
                    lda #SP_PhraseHot
SpeechQueueHeat    lbsr QueueSpeech
SpeechCheckDock    lda GS_Stage,x
                    cmpa AD_Speech+SP_LastStage,u
                    beq SpeechRecordEvents
                    cmpa #STAGE_DOCK
                    bne SpeechRecordEvents
                    lda #SP_PhraseDock
                    lbsr QueueSpeech
SpeechRecordEvents lda GS_Level,x
                    sta AD_Speech+SP_LastLevel,u
                    lda GS_CurrentPlayer,x
                    sta AD_Speech+SP_LastPlayer,u
                    lda GS_FuelLevel,x
                    sta AD_Speech+SP_LastFuel,u
                    lda GS_HeatUnits,x
                    sta AD_Speech+SP_LastHeat,u
                    lda GS_Stage,x
                    sta AD_Speech+SP_LastStage,u
                    lda GS_LaserLocked,x
                    sta AD_Speech+SP_LastLock,u
                    puls d,x,y,pc

* Finish a partial frame and one silent frame before releasing the asset RAM.
* Timeout is counted in real ticks, not CPU speed. No infinite Ready loop.
CloseSpeech         pshs d,x,y
                    tst AD_Speech+SP_Enabled,u
                    lbeq SpeechCloseReturn
                    clr AD_Speech+SP_Pending,u
                    clra
                    clrb
                    std AD_Speech+SP_Sequence,u
                    std AD_Speech+SP_Remaining,u
                    lda AD_Speech+SP_FramePosition,u
                    beq SpeechCloseSilent
                    ldb #SP_FrameBytes
                    pshs a
                    subb ,s+        stack offset: partial frame position
                    leax AD_Speech+SP_Buffer,u
                    stx AD_Speech+SP_BufferRead,u
                    stb AD_Speech+SP_BufferCount,u
SpeechClosePad      clr ,x+
                    decb
                    bne SpeechClosePad
                    lbsr SpeechDrainClose
SpeechCloseSilent  lbsr QueueSpeechSilence
                    lbsr SpeechDrainClose
                    lbsr ReleaseDisplayMapping
                    tst AD_Speech+SP_OwnsBlocks,u
                    beq SpeechCloseReturn
                    ldx AD_Speech+SP_FirstBlock,u
                    pshs u
                    ldu #SP_AssetBlocks
                    lda #ASTRO_OUTPUT_PATH
                    ldb #SS.GfxFree
                    os9 I$SetStt
                    puls u
                    bcc SpeechCloseFreed
                    stb AD_ErrorCode,u
                    bra SpeechCloseReturn
SpeechCloseFreed    clr AD_Speech+SP_OwnsBlocks,u
                    clr AD_Speech+SP_Enabled,u
SpeechCloseReturn   puls d,x,y,pc
SpeechDrainClose   lda #SP_CloseTicks
                    sta AD_Speech+SP_Closing,u
SpeechDrainNext    tst AD_Speech+SP_BufferCount,u
                    beq SpeechDrainReturn
                    lbsr FeedSpeech
                    ldx #ASTRO_PAUSE_SLEEP
                    os9 F$Sleep
                    dec AD_Speech+SP_Closing,u
                    bne SpeechDrainNext
SpeechDrainReturn  rts
