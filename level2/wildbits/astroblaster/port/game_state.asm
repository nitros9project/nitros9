* Native translations of established original routines.
* X = this instance's G80_RAM_BYTES workspace. No fixed-address stores.
* U is untouched. These helpers neither install IRQs nor mask interrupts.

* First launch only. Preserve X,Y,D; initialize all owned game storage.
InitializeWorkRAM  pshs      d,x,y
                    ldy       #G80_RAM_BYTES
InitializeWorkByte clr       ,x+
                    leay      -1,y
                    bne       InitializeWorkByte
                    puls      d,x,y,pc

* Original $3FCB..$3FFE. Clear the session's 99-entry ranking table ONCE.
* Pointer fields use native 6809 byte order and owned workspace addresses.
InitializeScoreState
                    pshs      d,x,y
                    ldd       #GS_BCD9999
                    std       GS_ScoreSentinel,x
                    leay      GS_HighScores,x
                    ldb       #GS_ScoreClearBytes
InitializeScoreByte
                    clr       ,y+
                    decb
                    bne       InitializeScoreByte
                    puls      d,x,y
* A new paid game clears its two scores, not the ranking history.
ResetPlayerScores
                    pshs      d,x,y
                    clra
                    clrb
                    std       GS_ScorePlayer1,x
                    std       GS_ScorePlayer2,x
                    ldd       #GS_BCD0909
                    std       GS_RankPlayer1,x
                    std       GS_RankPlayer2,x
                    leay      GS_LastHighScore,x
                    sty       GS_RankPointer1,x
                    sty       GS_RankPointer2,x
                    clr       GS_ScoreAltDigits,x
                    puls      d,x,y,pc

* State half of original $112A..$1138. Speech-port $28 control output
* belongs to the future audio adapter; never write original port $3B here.
ResetSpeechState   clr       GS_CD5C,x
                    clr       GS_CD5F,x
                    clr       GS_CD6C,x
                    rts

* Palette half of original frame callback $130B..$1341.
* Y = owned 64-byte raw G80 palette buffer. B returns 1 if updated, else 0.
* Preserves X,Y,U. D/CC scratch. No VICKY writes in this game-level routine.
* Original $CA6F table contains complemented palette bytes; COMA matters.
UpdateGamePalette  tst       GS_PaletteDirty,x
                    beq       GamePaletteUnchanged
                    pshs      x,y
                    leax      GS_PaletteSource,x
                    ldb       #G80_PALETTE_ENTRIES
CopyGamePalette    lda       ,x+
                    coma
                    sta       ,y+
                    decb
                    bne       CopyGamePalette
                    puls      x,y
                    clr       GS_PaletteDirty,x
                    ldb       #1
                    rts
GamePaletteUnchanged
                    clrb
                    rts

* Called once by the eventual OS-9 frame scheduler, not from an ISR.
* U = platform state. A background VT or pending exit must not advance.
* B=0 when paused/exiting or palette unchanged; B=1 when palette updated.
* The original $0099 interrupt increments this byte before its callback.
AdvanceGameFrame   ldb       #1
* B = actual elapsed ticks from WaitGameFrame. Game logic runs once;
* counter-dependent animation still sees the elapsed time, as on the Z80.
AdvanceGameFrames  tst       AP_ExitSignal,u
                    bne       GamePaletteUnchanged
                    tst       AP_Paused,u
                    bne       GamePaletteUnchanged
                    addb      GS_FrameCounter,x
                    stb       GS_FrameCounter,x
                    bra       UpdateGamePalette

* Owned-state portion of original GameInitialize ($1139..$1162).
* X = initialized game RAM; preserve D,X,Y,U. Call once after work-RAM
* initialization. Hardware IRQ/callback installation and sound-port writes
* are intentionally left to the platform services, never copied literally.
InitializeGameState
                    pshs      d,x,y,u
                    lda       #G80_IRQ_ENABLE
                    sta       GS_VideoControl,x
                    clr       GS_PaletteDirty,x
                    lda       #GS_SOUND_INITIAL
                    sta       GS_SoundShadow,x
                    lbsr      InitializeScoreState
                    lbsr      ResetSpeechState
                    leay      OriginalInitials,pcr
                    leau      GS_Initials,x
                    ldb       #GS_InitialsBytes
CopyInitials       lda       ,y+
                    sta       ,u+
                    decb
                    bne       CopyInitials
                    puls      d,x,y,u,pc

* State entry at original $0AB9..$0AC5, before its attract-screen setup.
* X = game RAM. Preserve X,Y,U; A/CC scratch.
EnterAttractState  clr       GS_PlayerMode,x
                    lda       #GS_ATTRACT_COUNT
                    sta       GS_C979,x
                    lda       #1
                    sta       GS_Level,x
                    rts

* Original $2195..$21B0; only record-leading bytes are cleared.
* Do not wipe each whole record: the original keeps the other six bytes.
* X = game RAM. Preserve D,X,Y,U; CC scratch.
ResetEightSlotPool pshs      d,x
                    ldb       #GS_PoolCount
                    stb       GS_FreeSlots,x
                    clr       GS_CC4A,x
                    clr       GS_CC4B,x
                    clr       GS_CC99,x
                    leax      GS_EightSlotPool,x
ResetPoolSlot      clr       ,x
                    leax      GS_PoolStride,x
                    decb
                    bne       ResetPoolSlot
                    puls      d,x,pc

* Palette part of original InitializePlayfield ($0F9F..$0FAC).
* Copy the COMPLEMENTED ROM bytes; UpdateGamePalette does the inversion.
* X = game RAM. Preserve D,X,Y,U; CC scratch.
LoadGamePalette    pshs      d,x,y
                    leay      OriginalGamePalette,pcr
                    leax      GS_PaletteSource,x
                    ldb       #G80_PALETTE_ENTRIES
LoadPaletteByte    lda       ,y+
                    sta       ,x+
                    decb
                    bne       LoadPaletteByte
                    puls      d,x,y
                    pshs      a
                    lda       #$FF
                    sta       GS_PaletteDirty,x
                    puls      a,pc
