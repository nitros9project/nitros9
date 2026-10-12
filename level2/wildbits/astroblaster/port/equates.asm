* Astro Blaster - NitrOS-9 Level 2 / 6809 port.
* All port state, hardware meanings and geometry are named here.
* Original Z80 locations live outside the repository, in astroblasteroriginal/equates.asm.
* An address-derived symbol means the purpose has NOT yet been established.

SCREEN_WIDTH        equ       640
SCREEN_HEIGHT       equ       240
SCREEN_BPP          equ       4
SCREEN_STRIDE       equ       SCREEN_WIDTH/2
SCREEN_BYTES        equ       SCREEN_STRIDE*SCREEN_HEIGHT
SCREEN_BLOCK_BYTES  equ       $2000
SCREEN_BLOCKS       equ       (SCREEN_BYTES+SCREEN_BLOCK_BYTES-1)/SCREEN_BLOCK_BYTES
LAST_SAFE_BLOCK_MAP equ       $C000     slot 6; slot 7 overlaps fixed CPU I/O

G80_NATIVE_WIDTH    equ       256
G80_NATIVE_HEIGHT   equ       224
G80_UPRIGHT_WIDTH   equ       G80_NATIVE_HEIGHT
G80_UPRIGHT_HEIGHT  equ       G80_NATIVE_WIDTH
G80_TILE_WIDTH      equ       8
G80_TILE_HEIGHT     equ       8
G80_TILE_COUNT      equ       256
G80_PALETTE_ENTRIES equ       64

G80_ROM_BASE        equ       $0000
G80_ROM_BYTES       equ       $A000
G80_RAM_BASE        equ       $C800
G80_RAM_BYTES       equ       $0800
G80_VIDEO_BASE      equ       $E000
G80_VIDEO_BYTES     equ       $1800
G80_CHARS_PLANE0    equ       $E800
G80_CHARS_PLANE1    equ       $F000
G80_SPEECH_DATA     equ       $38
G80_SPEECH_CONTROL  equ       $3B
G80_SOUND_CONTROL0  equ       $3E
G80_SOUND_CONTROL1  equ       $3F
G80_VIDEO_CONTROL  equ       $BF
G80_INPUT_FIRST    equ       $F8
G80_INPUT_LAST     equ       $FC
G80_PALETTE_WRITE  equ       $02
G80_IRQ_ENABLE     equ       $04

* Terminal-facing code must include the repository's defsfile/wildbits.d.
* Do not duplicate SS.* or hardware register definitions here.
ASTRO_INPUT_PATH    equ       0
ASTRO_OUTPUT_PATH   equ       1
ASTRO_LIVEKEY_BYTES equ       6
ASTRO_KEY_SENSE     equ       0
ASTRO_KEY_CODES     equ       1
ASTRO_KEY_BYTES     equ       ASTRO_KEY_CODES+ASTRO_LIVEKEY_BYTES
AS_BufferBytes      equ       3072      generated largest pack is 2778 bytes
AS_WaveCount        equ       33
AS_AsteroidPack     equ       32
AS_DockingPack      equ       33
AS_PrefixBytes      equ       8
AS_EntryBytes       equ       6         big-endian file offset (4), length (2)
AS_HeaderBytes      equ       AS_PrefixBytes+AS_WaveCount*AS_EntryBytes
AS_DefaultMode      equ       0         stack offset after PSHS A: open mode

* DecodeTile stack offsets after its six-byte local frame is reserved.
* Output is 64 palette indexes in ORIGINAL raster order, not screen pixels.
DT_PaletteBase     equ       0         stack offset: tile color group * 4
DT_RowsLeft        equ       1         stack offset: remaining source rows
DT_ColumnsLeft     equ       2         stack offset: remaining source pixels
DT_LowPlane        equ       3         stack offset: shifting low-bit plane
DT_HighPlane       equ       4         stack offset: shifting high-bit plane
DT_FrameBytes      equ       5         local stack frame size

* ReadTerminalKeys stack offsets after PSHS D,X,Y,U.
RK_ResultPointer   equ       2         stack offset: saved X output pointer
RK_StaticBase      equ       6         stack offset: saved U process base
RK_ReturnBytes     equ       7         returned A,X,Y,U stack image length
RK_ReturnSense     equ       0         stack offset: returned A
RK_ReturnKeys12    equ       1         stack offset: returned X
RK_ReturnKeys34    equ       3         stack offset: returned Y
RK_ReturnKeys56    equ       5         stack offset: returned U
RK_SavedDBytes     equ       2

* Per-process platform storage; offsets from U, never absolute addresses.
AP_SavedMCRLow     equ       0         word returned by SS.MCR
AP_SavedMCRHigh    equ       AP_SavedMCRLow+2
AP_Bitmap          equ       AP_SavedMCRHigh+2
AP_FirstBlock      equ       AP_Bitmap+2
AP_ClearBlock      equ       AP_FirstBlock+2
AP_MapAddress      equ       AP_ClearBlock+2
AP_BlocksLeft      equ       AP_MapAddress+2
AP_OwnsBitmap      equ       AP_BlocksLeft+1
AP_HasMapping      equ       AP_OwnsBitmap+1
AP_SavedDisplay    equ       AP_HasMapping+1
AP_Error           equ       AP_SavedDisplay+1
AP_Paused          equ       AP_Error+1
AP_ExitSignal      equ       AP_Paused+1
AP_WatchesTerminal equ       AP_ExitSignal+1
AP_PreviousButtons equ       AP_WatchesTerminal+1
AP_LastSecond      equ       AP_PreviousButtons+1
AP_LastTick        equ       AP_LastSecond+1
AP_CurrentSecond   equ       AP_LastTick+1
AP_CurrentTick     equ       AP_CurrentSecond+1
AP_ClockNeedsSync  equ       AP_CurrentTick+1
AP_StateBytes      equ       AP_ClockNeedsSync+1
ASTRO_BITMAP_COUNT equ       3
ASTRO_BITMAP_ON    equ       $0100     SS.BmCfg: enabled, CLUT 0
ASTRO_BITMAP_640   equ       $0100     SS.BmCfg: HIRES4, group 0
ASTRO_GRAPHICS     equ       FX_GRF+FX_TIL
TV_Blocks          equ       6         tile set 0 in blocks 0-1, map and tile set 1 in block 2,
*                                        tile set 2 (attract font) in 3, attract map in 4-5
TV_FontBlock       equ       3
TV_PageMapBlock    equ       4
TV_PageAttr        equ       $02       attribute: tile set 2, CLUT 0
TV_PageBlank       equ       $78       the original's space: outside the font, all pen 0
TV_PageTop         equ       30        map rows above the first text line
TV_PageTail        equ       32        map rows after the last text line
PAGE_SCROLL        equ       3         GS_AttractPage: instruction text rising
PAGE_REDDEN        equ       4         7 ticks: blue to red, yellow to black
PAGE_HOLD          equ       5         256 frames
PAGE_DARKEN        equ       6         background to black, 1 step per 6 frames
PAGE_BLACK         equ       7         120 frames
PAGE_CREDIT_HOLD   equ       128       credits variant: frames before it rises
GS_ScrollPixels  equ       GS_AttractStep+1 ; word: scroll position
GS_ScrollEnd     equ       GS_ScrollPixels+2 ; word: where the text ends
GS_ScrollCredits equ       GS_ScrollEnd+2 ; credits when the page began
GS_ScrollHold    equ       GS_ScrollCredits+1
TV_MapBlock        equ       2
TV_MapCols         equ       44        the engine reads 44 cells per line
TV_MapRows         equ       30
TV_FirstMapCol     equ       7         map column 1 is screen column 0; (40-28)/2 = 6 margin columns
TV_MapControl      equ       $11       enable, 8x8 tiles
TV_BlankOffset     equ       $1000     tile set 1: one black tile
TV_BlankAttr       equ       $01       attribute: tile set 1, CLUT 0
TV_BlackPixel      equ       65
TV_CLUTEntries     equ       65        CLUT 0 entries 1-65
* TileSync stack frame.
TS_Glyph           equ       0
TS_AnyLow          equ       1
TS_AnyHigh         equ       2
TS_Column          equ       3
TS_Rows            equ       4
TS_Left            equ       5
TS_Cell            equ       6
TS_FrameBytes      equ       8
ASTRO_GRAPHICS_MASK equ      FX_GRF+FX_BM+FX_SPR+FX_TIL
ASTRO_60HZ_MASK    equ       $FF-FT_CLK70
ASTRO_VT_SIGNALS   equ       S$WinBg*256+S$WinFg
ASTRO_PAUSE_SLEEP  equ       2         F$Sleep counts request minus one tick
ASTRO_CLOCK_BYTES  equ       D.Tick-D.Sec+1 ; atomic seconds/countdown snapshot
ASTRO_CLOCK_MINUTE equ       60
ASTRO_SYSTEM_BLOCK equ       0         L2 system direct page resides in block 0

* Game workspace offsets from its own X base. The original address is
* retained in neutral names until its role is established. Native pointer
* fields hold 6809 addresses, not Z80 hardware addresses or ROM offsets.
GS_FrameCounter       equ       $C80A-G80_RAM_BASE
GS_CreditsBCD         equ       $C80B-G80_RAM_BASE
GS_C80D               equ       $C80D-G80_RAM_BASE
GS_C80F               equ       $C80F-G80_RAM_BASE
GS_C979               equ       $C979-G80_RAM_BASE
GS_Level              equ       $C97C-G80_RAM_BASE
GS_PreviousCoins      equ       $C810-G80_RAM_BASE
GS_PaletteSource      equ       $CA6F-G80_RAM_BASE
GS_ScorePlayer1       equ       $CB2F-G80_RAM_BASE
GS_ScorePlayer2       equ       $CB31-G80_RAM_BASE
GS_RankPlayer1        equ       $CB33-G80_RAM_BASE
GS_RankPlayer2        equ       $CB35-G80_RAM_BASE
GS_RankPointer1       equ       $CB37-G80_RAM_BASE
GS_RankPointer2       equ       $CB39-G80_RAM_BASE
GS_ScoreSentinel      equ       $CB3D-G80_RAM_BASE
GS_HighScores         equ       $CB3F-G80_RAM_BASE
GS_LastHighScore      equ       $CC01-G80_RAM_BASE
GS_ScoreAltDigits     equ       $CC05-G80_RAM_BASE
GS_Initials           equ       $CC0E-G80_RAM_BASE
GS_InitialsBytes   equ       12
GS_CC4A               equ       $CC4A-G80_RAM_BASE
GS_CC4B               equ       $CC4B-G80_RAM_BASE
GS_EightSlotPool      equ       $CC4C-G80_RAM_BASE
GS_FreeSlots          equ       $CC84-G80_RAM_BASE
GS_StateFlags         equ       $CC8A-G80_RAM_BASE
GS_RandomSeed         equ       $CCA4-G80_RAM_BASE ; native big-endian seed
GS_StarCountdown      equ       $CCA6-G80_RAM_BASE
GS_StarTile           equ       $CCA7-G80_RAM_BASE
GS_StarCells          equ       $CCA8-G80_RAM_BASE ; 32 native cell pointers
GS_INIT_STARS      equ       $01
GS_StarCount       equ       32
GS_StarPeriod      equ       4
GS_StarFirstTile   equ       $23
GS_StarToggle      equ       $07
GS_StarThreshold   equ       $38
GS_RandomFallback equ       $733C
G80_STAR_GLYPHS    equ       $0918
G80_STAR_WRAP_CELL equ       $035F
* UpdateStars/InitializeStars local frame after PSHS D,X,Y,U.
ST_Count           equ       0         stack offset: star records remaining
ST_Move            equ       1         stack offset: move pass (1) or blink (0)
ST_FrameBytes      equ       2
ST_SavedState      equ       ST_FrameBytes+2 ; stack offset: original X game base
ST_SavedVideo      equ       ST_FrameBytes+4 ; stack offset: original Y video base
RO_Column          equ       0         stack offset: saved random tile column
RO_FrameBytes      equ       1

* Object record ($1725's original IX). Coordinates remain in G80 raster
* orientation; the display renderer alone rotates them into portrait.
OB_MoveFlags       equ       $02
OB_TileX           equ       $06
OB_TileY           equ       $07
OB_PixelX          equ       $08
OB_PixelY          equ       $09
OB_DeltaX          equ       $0A       signed 8-bit displacement per iteration
OB_DeltaY          equ       $0B
OB_Frame           equ       $0C
OB_TargetTile      equ       $0D
OB_ShapePointer    equ       $0E       NATIVE big-endian shape pointer
OB_CROSSED_Y_MINUS equ       $01
OB_CROSSED_Y_PLUS  equ       $02
OB_CROSSED_X_MINUS equ       $04
OB_CROSSED_X_PLUS  equ       $08
OB_PERSIST_FLAGS  equ       $E0
* Converted shape record ($1725's original IY). Every pointer/word must
* be converted at asset generation, never used straight from Z80 ROM.
* Immutable source words are offsets from the shape record, resolved at
* runtime; absolute assembler label values are not OS-9 pointers.
SH_Rows            equ       $00
SH_TileWidth       equ       $02
SH_TileHeight      equ       $03
SH_TileBankA       equ       $04
SH_TileBankB       equ       $05
SH_SourceStride   equ       $0F       NATIVE big-endian signed word
SH_Columns        equ       SH_SourceStride+1 ; original low byte, now second byte
SH_TargetStride   equ       $11       NATIVE big-endian signed word
SH_ClearBytes     equ       $13
SH_LastFrame      equ       $16
SH_FrameSources   equ       $17       pairs of big-endian shape-relative offsets
SH_FrameBytes     equ       4
SH_Plane1Source   equ       2
* RenderObjectPatterns stack offsets after PSHS D,X,Y,U.
OP_CopyParameters equ       0         stack offset: SSC_ record (5 bytes)
OP_TargetBase     equ       OP_CopyParameters+SSC_Parameters ; stack offset: glyph base
OP_Sources        equ       OP_TargetBase+2 ; stack offset: current frame pair
OP_Plane          equ       OP_Sources+2 ; stack offset: plane number 0 or 1
OP_FrameBytes     equ       OP_Plane+1
OP_SavedObject    equ       OP_FrameBytes+2 ; stack offset: saved X
OP_SavedShape     equ       OP_FrameBytes+4 ; stack offset: saved Y
OP_SavedVideo     equ       OP_FrameBytes+6 ; stack offset: saved U
GS_PlayerMode         equ       $CC95-G80_RAM_BASE
GS_CC99               equ       $CC99-G80_RAM_BASE
GS_PoolCount       equ       8
GS_PoolStride      equ       7
GS_PaletteDirty       equ       $CC48-G80_RAM_BASE
GS_VideoControl       equ       $CD0C-G80_RAM_BASE
GS_SoundShadow        equ       $CD11-G80_RAM_BASE
GS_CD5C               equ       $CD5C-G80_RAM_BASE
GS_CD5F               equ       $CD5F-G80_RAM_BASE
GS_CD6C               equ       $CD6C-G80_RAM_BASE
GS_LivesPlayer1       equ       $CD0A-G80_RAM_BASE
GS_LivesPlayer2       equ       $CD0B-G80_RAM_BASE
GS_FuelLevel          equ       $CCF7-G80_RAM_BASE
GS_FuelClock          equ       $CCF8-G80_RAM_BASE
GS_FuelColor          equ       $CA78-G80_RAM_BASE
GS_WarpTicks          equ       $C984-G80_RAM_BASE ; native word
GS_WarpAvailable      equ       $CD0F-G80_RAM_BASE
GS_ShipHitX           equ       $C98E-G80_RAM_BASE
GS_ShipHitY        equ       GS_ShipHitX+1
FUEL_MAX           equ       25
FUEL_PERIOD        equ       24
G80_FUEL_FULL_PATTERN equ    $0910
WARP_SLOW_FACTOR   equ       10
WARP_DURATION      equ       840
GS_ScoreClearBytes equ       $C6
GS_BCD9999         equ       $9999
GS_BCD0909         equ       $0909
GS_SOUND_INITIAL   equ       $DF
GS_ATTRACT_COUNT   equ       $1E

* CopyStridedColumns parameter record, addressed by U.
SC_SourceStride    equ       0         signed word between source rows
SC_TargetStride    equ       2         signed word between destination rows
SC_Parameters      equ       4
* CopyStridedColumns local stack frame.
SC_ColumnsLeft     equ       0         stack offset: outer loop countdown
SC_RowsPerColumn   equ       1         stack offset: inner loop initial count
SC_RowsLeft        equ       2         stack offset: inner loop countdown
SC_FrameBytes      equ       3
SC_BasePointers    equ       4         bytes pushed for each column's X,Y

* Shifted copier extends the same source/destination stride record.
SSC_Shift          equ       SC_Parameters ; shift 0..7 pixels, caller validated
SSC_Parameters     equ       SSC_Shift+1
* CopyShiftedColumns local stack frame, relative to S before column push.
SSC_ColumnsLeft    equ       0         stack offset: outer loop countdown
SSC_RowsPerColumn  equ       1         stack offset: original row count
SSC_RowsLeft       equ       2         stack offset: rows left in this column
SSC_CarryPixels    equ       3         stack offset: spill from previous byte
SSC_ShiftsLeft     equ       4         stack offset: bit-loop countdown
SSC_FrameBytes     equ       5
SSC_BasePointers   equ       4         stack bytes temporarily saving X,Y

* BitmapByteAddress local stack frame after PSHS X,Y.
BA_Bank            equ       0         stack offset: carry above 16-bit byte address
BA_FrameBytes      equ       1
BA_Column          equ       BA_FrameBytes ; stack offset: saved input X byte column
BA_OffsetBytes     equ       2         bytes pushed for result while making block X
BA_SavedXBytes     equ       2
BITMAP_HALF_STRIDE equ       SCREEN_STRIDE/2
BITMAP_OFFSET_HI_MASK equ    (SCREEN_BLOCK_BYTES-1)/256

CLUT_Blue          equ       0
CLUT_Green         equ       1
CLUT_Red           equ       2
CLUT_Reserved      equ       3
CLUT_EntryBytes    equ       4
G80_RGB3Mask       equ       $07
PC_SavedColor      equ       0         stack offset after PSHS A,Y

G80_TILEMAP_BYTES  equ       $0800
G80_INIT_TILE_BYTES equ      $07FF     original seeded LDIR: last source byte rewritten
G80_FONT_ZERO_BYTES equ      $02FF
G80_VIDEO_FILL_BYTES equ     $0D00     $0AFE..$17FD; final two bytes untouched
G80_BLANK_TILE     equ       $20
G80_FONT_DIGITS    equ       $0980     byte offset in owned video buffer
G80_FONT_LETTERS   equ       $0A08
G80_FONT_ASTERISK  equ       $0950
G80_DIGIT_COUNT    equ       10
G80_LETTER_COUNT   equ       26
G80_GLYPH_BYTES    equ       8
G80_GAME_FONT_BYTES equ      $0128
G80_STATUS_SHAPES  equ       $0900
G80_FUEL_CAP_GLYPH equ       $0928
G80_STATUS_HIGH_ON equ       $1108
G80_DIGIT_HIGH0    equ       $1180
G80_DIGIT_HIGH1    equ       $1198
G80_DIGIT_LOW0     equ       $0980
G80_DIGIT_LOW1     equ       $0998
G80_GAME_FONT      equ       $0A00
G80_STATUS_HIGH_FONT equ     $1328
G80_STATUS_LOW_FONT equ      $0800
G80_EMPTY_STATUS_FONT equ    $0B28
G80_PATTERN_A_LOW  equ       $0F00
G80_PATTERN_A_HIGH equ       $1700
G80_PATTERN_B_LOW  equ       $0F80
G80_PATTERN_B_HIGH equ       $1780
G80_STATUS_PATTERN_BYTES equ 64
G80_STATUS_GLYPH_BYTES equ   256
G80_STATUS_HIGH_BYTES equ   40
G80_DIGIT_PLANE_BYTES equ   24
G80_TEXT_END       equ       $80
G80_TILEMAP_STRIDE equ       32
CT_SavedSource     equ       2         stack offset after PSHS D,X,Y
CT_ColumnOrigin    equ       $DF       original $E1DF low byte
CT_ColumnPage      equ       1         original $E100 offset from video base

* Native playfield offsets in the owned G80 video buffer (not CPU I/O).
PF_BorderTile      equ       $01
PF_LastTileRow     equ       $0360
PF_SideOrigin      equ       $001F
PF_SideSpan        equ       6
PF_SideRows        equ       27
PF_Player1Label    equ       $0022
PF_Player2Label    equ       $02C2
PF_LabelTiles      equ       5
PF_LabelFirstTile  equ       $0F
PF_LabelLeft      equ       $0102
PF_LabelRight     equ       $0202
PF_CenterLabel     equ       $0144
PF_Player1Score    equ       $0021
PF_Player2Score    equ       $02C1
PF_Player1Lives    equ       $0024
PF_Player2Lives    equ       $02C4
PF_MaxLives       equ       5
PF_LiveTile       equ       0
PF_FuelOrigin     equ       $0023
PF_FuelSegments   equ       26
PF_FuelFullTile   equ       $22
PF_FuelCapTile    equ       $21
PF_FuelEmptyTile  equ       $25
PF_ScoreZeroTile  equ       $05
PF_AltScoreZero   equ       $40
PF_ScoreDigits    equ       4
* DrawPackedScore local frame after PSHS D,X,Y,U.
DS_BCDValue       equ       0         stack offset: remaining packed digits (word)
DS_ZeroTile       equ       2         stack offset: selected digit bank
DS_DigitsLeft     equ       3         stack offset: remaining digits
DS_ShiftsLeft     equ       4         stack offset: nibble-shift countdown
DS_FrameBytes     equ       5
PF_SavedVideo     equ       2         stack offset: saved X after PSHS D,X,Y,U
PF_SavedState     equ       4         stack offset: saved Y after PSHS D,X,Y,U
* CopyOwnedSpans record; relative source offset is from this record's base.
CS_Target         equ       0
CS_Source         equ       2
CS_Length         equ       4
CS_RecordBytes    equ       6
CS_SavedTarget    equ       4         stack offset: saved Y after PSHS D,X,Y,U

CONTROL_LEFT      equ       $01
CONTROL_RIGHT     equ       $02
CONTROL_FIRE      equ       $04
CONTROL_WARP      equ       $08
CONTROL_START1    equ       $10
CONTROL_START2    equ       $20
CONTROL_CREDIT    equ       $40
CONTROL_EXIT      equ       $80
KEY_START1        equ       '1
KEY_START2        equ       '2
KEY_CREDIT        equ       '5
KEY_QUIT_LOWER    equ       'q
KEY_QUIT_UPPER    equ       'Q
KEY_ESCAPE        equ       $1B
KEY_BACKSPACE     equ       $08
KEY_ENTER         equ       $0D
TC_Buttons        equ       0         stack offset: translated buttons
TC_FrameBytes     equ       1
SC_StartPlayers   equ       0         stack offset: accepted start request
SC_CreditsLeft    equ       1         stack offset: number of credits to subtract
SC_StartFrameBytes equ      2
BCD_DIGIT_MASK    equ       $0F
BCD_BORROW_DIGIT  equ       $0F
BCD_BORROW_FIX    equ       6

* RenderUprightRow stack offsets after PSHS D,X,Y,U and local reservation.
RR_TileMap        equ       0         stack offset: current tile-map pointer
RR_BitMask        equ       2         stack offset: selected glyph column
RR_TilesLeft      equ       3         stack offset: remaining vertical tiles
RR_RowsLeft       equ       4         stack offset: rows within current glyph
RR_PaletteBase    equ       5         stack offset: tile's 4-color group
RR_FrameBytes     equ       6
RR_SavedColumn    equ       RR_FrameBytes ; stack offset: saved input A
RR_VideoBase      equ       RR_FrameBytes+2 ; stack offset: saved input X
RR_Nibble         equ       0         stack offset after temporary PSHS A
G80_PLANE0_OFFSET equ       G80_CHARS_PLANE0-G80_VIDEO_BASE
G80_PLANE_SPACING equ       G80_CHARS_PLANE1-G80_CHARS_PLANE0
G80_VISIBLE_TILE_ROWS equ   G80_NATIVE_HEIGHT/G80_TILE_HEIGHT
G80_PIXEL_MASK    equ       $80
G80_COLUMN_MASK   equ       G80_TILE_WIDTH-1
G80_TILE_GROUP_MASK equ     $F0
BITMAP_COLOR_MASK equ       $0F
ASTRO_PLAYFIELD_WIDTH equ   G80_UPRIGHT_WIDTH*2
ASTRO_PLAYFIELD_X  equ       (SCREEN_WIDTH-ASTRO_PLAYFIELD_WIDTH)/2
ASTRO_PLAYFIELD_BYTE_X equ  ASTRO_PLAYFIELD_X/2
ASTRO_SCALE_DENOM equ       SCREEN_HEIGHT-1
ASTRO_SCALE_EXTRA equ       G80_UPRIGHT_HEIGHT-SCREEN_HEIGHT
ASTRO_SCALE_ROUND equ       ASTRO_SCALE_DENOM/2
RW_Source         equ       0         stack offset: current scanline source
RW_Block          equ       2         stack offset: physical destination block
RW_Offset         equ       4         stack offset: offset in destination block
RW_MapEnd         equ       6         stack offset: end of current mapping
RW_BytesLeft      equ       8         stack offset: bytes left in scanline
RW_FrameBytes     equ       10

* Full-frame source record, addressed by X on RenderPortraitFrame entry.
RF_Video          equ       0         pointer to owned original 8K video buffer
RF_Scanline       equ       2         pointer to 224-byte output scratch row
RF_ColorMap       equ       4         pointer to 64-byte palette-index mapping
RF_PreviousVideo  equ       6         pointer to private 8K previous video image
RF_DirtyGlyphs    equ       8         pointer to 256 one-byte glyph-change flags
RF_DirtyColumns   equ       10        pointer to 32 tile-column redraw flags
RF_ArgumentsBytes equ       12
* RenderPortraitFrame stack offsets after PSHS X,Y,U and local frame.
RF_TargetRow      equ       0         stack offset: destination row 0..239
RF_SourceColumn   equ       1         stack offset: original column 255..0
RF_ScaleError     equ       2         stack offset: scaling remainder 0..238
RF_FrameBytes     equ       3
RF_SavedArguments equ       RF_FrameBytes ; stack offset: saved input X
RF_TemporaryUBytes equ      2         temporary PSHS U around tile conversion

* DetectVideoChanges local stack frame after PSHS D,X,Y,U.
DF_TilesLeft      equ       0         stack offset: visible cells remaining (word)
DF_GlyphsLeft     equ       2         stack offset: 0 wraps through 256 glyphs
DF_Column         equ       3         stack offset: tile column 0..31
DF_GlyphFlags     equ       4         stack offset: glyph-flag base pointer
DF_FrameBytes     equ       6
DF_SavedArguments equ       DF_FrameBytes+2 ; stack offset: saved input X
DF_TemporaryXBytes equ      2         temporary PSHS X during glyph lookup

* Palette work packet: caller-owned and per instance.
PW_Raw            equ       0         64 original RGB332 palette bytes
PW_Used           equ       PW_Raw+G80_PALETTE_ENTRIES
PW_Map            equ       PW_Used+G80_PALETTE_ENTRIES
PW_Colors         equ       PW_Map+G80_PALETTE_ENTRIES ; 16 unique raw colors
PW_CLUT           equ       PW_Colors+16 ; 16 B,G,R,reserved entries
PW_Count          equ       PW_CLUT+16*CLUT_EntryBytes ; highest assigned index
PW_Bytes          equ       PW_Count+1
ASTRO_BLACK_INDEX equ       1         black is opaque; nibble 0 is transparent
ASTRO_OPAQUE_COLORS equ      15
G80_VISIBLE_TILES equ       G80_TILEMAP_STRIDE*G80_VISIBLE_TILE_ROWS
* CollectPaletteUsage stack offsets after PSHS D,X,Y,U and local frame.
CU_TilesLeft      equ       0         stack offset: remaining visible tile cells
CU_RowsLeft       equ       2         stack offset: remaining rows in glyph
CU_LowPlane       equ       3         stack offset: source plane 0 byte
CU_HighPlane      equ       4         stack offset: source plane 1 byte
CU_FrameBytes     equ       5
CU_VideoBase      equ       CU_FrameBytes+2 ; stack offset: saved input X
CU_UsageBase      equ       CU_FrameBytes+4 ; stack offset: saved input Y
CU_GlyphBase      equ       CU_FrameBytes+6 ; stack offset: saved input U
CU_SavedTileBytes equ       2         temporary PSHS X inside tile loop
* CompactPalette stack offsets after PSHS X,Y,U and local frame.
CP_SourceIndex    equ       0         stack offset: original color index 0..63
CP_MappedIndex    equ       1         stack offset: selected opaque nibble
CP_FrameBytes     equ       2
BP_SavedBase      equ       2         stack offset: saved X after PSHS D,X
G80_BOOT_PALETTE_START equ  10
G80_BOOT_PALETTE_PAIRS equ  10
G80_BOOT_RED_INDEX equ      31
G80_BOOT_GREEN_INDEX equ    35
G80_BOOT_BLUE_INDEX equ     39
G80_RAW_RED       equ       $07
G80_RAW_GREEN     equ       $38
G80_RAW_BLUE      equ       $C0
G80_RAW_WHITE     equ       $FF

* DrawObjectTiles local stack frame after PSHS D,X,Y,U.
OT_OriginX        equ       0         stack offset: first tile column
OT_OriginY        equ       1         stack offset: first tile row
OT_Tile           equ       2         stack offset: next pattern tile
OT_ColumnsLeft    equ       3         stack offset: width remaining
OT_RowsLeft       equ       4         stack offset: height remaining
OT_CurrentX       equ       5         stack offset: current tile column
OT_CurrentY       equ       6         stack offset: current tile row
OT_Advance        equ       7         stack offset: 0 erase, 1 increment glyph
OT_Height         equ       8         stack offset: rectangle height
OT_ProtectTen     equ       9         stack offset: body erase protects class $10
OT_FrameBytes     equ       10
OT_SavedObject    equ       OT_FrameBytes+2 ; stack offset: saved X
OT_SavedShape     equ       OT_FrameBytes+4 ; stack offset: saved Y
OT_SavedVideo     equ       OT_FrameBytes+6 ; stack offset: saved U
G80_DRAW_FIRST_COL equ      5
G80_DRAW_ROWS     equ       32        original clips to $E000..$E3FF
G80_ERASE_TILE    equ       G80_BLANK_TILE

* Native player state, still at the original workspace offsets.
GS_PlayerObject       equ       $CC36-G80_RAM_BASE
GS_PlayerDisabled     equ       $CC98-G80_RAM_BASE
GS_LeftPressed        equ       $CC46-G80_RAM_BASE
GS_RightPressed       equ       $CC47-G80_RAM_BASE
GS_MoveNegative       equ       $CA57-G80_RAM_BASE
GS_MovePositive       equ       $CA58-G80_RAM_BASE
GS_PlayerFlash        equ       $CAB7-G80_RAM_BASE
GS_PlayerColor1       equ       $CAA1-G80_RAM_BASE
GS_PlayerColor2       equ       $CAA5-G80_RAM_BASE
PLAYER_LEFT_ROW   equ       1
PLAYER_LEFT_PIXEL equ       1
PLAYER_RIGHT_ROW  equ       24
PLAYER_RIGHT_PIXEL equ      7
PLAYER_FLASH_PERIOD equ     30
PLAYER_OBJECT_BYTES equ     16
* UpdatePlayerMotion local stack offsets after PSHS D,X,Y,U.
PM_SavedGame      equ       2         stack offset: original X
PM_SavedVideo     equ       4         stack offset: original Y

GS_WaveState          equ       $CC88-G80_RAM_BASE
GS_SpecialTarget      equ       $CC8B-G80_RAM_BASE
GS_SpecialHit         equ       $CC8C-G80_RAM_BASE
GS_ShotState          equ       $CC99-G80_RAM_BASE
GS_ShotCell           equ       $CC9A-G80_RAM_BASE ; native video pointer
GS_ShotTile           equ       $CC9D-G80_RAM_BASE
GS_ShotHitX           equ       $CC9E-G80_RAM_BASE
GS_ShotHitY           equ       $CC9F-G80_RAM_BASE
GS_ShotSubpixel       equ       $CCA0-G80_RAM_BASE
GS_ShotHitSubpixel    equ       $CCA1-G80_RAM_BASE
GS_ShotOverlayTile    equ       $CCA2-G80_RAM_BASE
GS_ShotUnderlyingTile equ       $CCA3-G80_RAM_BASE
GS_ShotX              equ       $CCEA-G80_RAM_BASE
GS_ShotY              equ       $CCEB-G80_RAM_BASE
GS_LastHitTile        equ       $CD4F-G80_RAM_BASE
GS_ShotMissed         equ       $CD54-G80_RAM_BASE
GS_LaserLocked        equ       $CD6A-G80_RAM_BASE
GS_LaserFired         equ       $CD6B-G80_RAM_BASE
GS_LaserCooldown      equ       $CCF3-G80_RAM_BASE ; native word
SHOT_REQUESTED    equ       1
SHOT_ACTIVE       equ       2
SHOT_PATTERN_BASE equ       $F0
SHOT_LAST_WAVE    equ       $3F
SHOT_TARGET_CLASS equ       $80
SHOT_PASS_CLASS   equ       $A0
SHOT_SPECIAL_CLASS equ      $70
* Shot helper stack offsets after PSHS D,X,Y,U.
BS_SavedD         equ       0         stack offset: original D / return A
BS_SavedGame      equ       2         stack offset: original X
BS_SavedCell      equ       4         stack offset: original Y
BS_SavedVideo     equ       6         stack offset: original U

* First formation ($5225 wave record). ROM pointers are resolved at init.
GS_EnemyObject        equ       $C932-G80_RAM_BASE
GS_FormationCells     equ       $C942-G80_RAM_BASE
GS_FormationCount equ       GS_FormationCells
GS_FormationAlive equ       GS_FormationCells+1
GS_FormationPositions equ   GS_FormationCells+2
GS_FormationClock     equ       $C96B-G80_RAM_BASE
GS_FormationYCursor   equ       $C96C-G80_RAM_BASE ; native pointer
GS_FormationXCursor   equ       $C96E-G80_RAM_BASE ; native pointer
GS_FormationSpeed     equ       $C970-G80_RAM_BASE
GS_EnemyColor00       equ       $CA8F-G80_RAM_BASE
GS_EnemyColor01       equ       $CA90-G80_RAM_BASE
GS_EnemyColor02       equ       $CA91-G80_RAM_BASE
GS_EnemyColor03       equ       $CA92-G80_RAM_BASE
GS_EnemyColor10       equ       $CA93-G80_RAM_BASE
GS_EnemyColor11       equ       $CA94-G80_RAM_BASE
GS_EnemyColor12       equ       $CA95-G80_RAM_BASE
GS_EnemyColor13       equ       $CA96-G80_RAM_BASE
FORMATION_END     equ       $80
FORMATION_BYTES   equ       34
FORMATION_PERIOD  equ       8
FORMATION_POSITION_BYTES equ 2
* Formation update local frame after PSHS D,X,Y,U.
FM_Cells          equ       0         stack offset: current coordinate pointer
FM_Count          equ       2         stack offset: remaining coordinate pairs
FM_DeltaX         equ       3         stack offset: crossed-cell X delta
FM_DeltaY         equ       4         stack offset: crossed-cell Y delta
FM_Pass           equ       5         stack offset: erase then stamp pass
FM_FrameBytes     equ       6
FM_SavedGame      equ       FM_FrameBytes+2 ; stack offset: original X
FM_SavedVideo     equ       FM_FrameBytes+4 ; stack offset: original Y

GS_ExplosionX         equ       $CCEF-G80_RAM_BASE
GS_ExplosionY         equ       $CCF0-G80_RAM_BASE
GS_ExplosionPixelX    equ       $CCF1-G80_RAM_BASE
GS_ExplosionPixelY    equ       $CCF2-G80_RAM_BASE
GS_ExplosionObject    equ       $C992-G80_RAM_BASE
GS_ExplosionFrames    equ       $C9A2-G80_RAM_BASE
GS_ExplosionClock     equ       $C9A3-G80_RAM_BASE
GS_ExplosionColor0    equ       $CA98-G80_RAM_BASE
GS_ExplosionColor1    equ       $CA99-G80_RAM_BASE
GS_ExplosionColor2    equ       $CA9A-G80_RAM_BASE
GS_CurrentPlayer      equ       $CC94-G80_RAM_BASE
GS_DoubleScore        equ       $CD12-G80_RAM_BASE
FORMATION_HIT_BCD equ       $05       score units of ten: original first-wave 50
EXPLOSION_FRAMES  equ       6
EXPLOSION_PERIOD  equ       2
* ConsumeFormationHit local stack offsets after PSHS D,X,Y,U.
FH_Cells          equ       0         stack offset: hit-list cursor
FH_Count          equ       2         stack offset: candidates remaining
FH_Index          equ       3         stack offset: candidate index
FH_Delta          equ       4         stack offset: saved X/Y cell delta
FH_FrameBytes     equ       6
FH_SavedGame      equ       FH_FrameBytes+2 ; stack offset
FH_SavedVideo     equ       FH_FrameBytes+4 ; stack offset

GS_EnemyShotClock     equ       $CC49-G80_RAM_BASE
GS_EnemyShotRequest equ     GS_CC4A
GS_EnemyShotCount equ       GS_CC4B
GS_EnemyShotX         equ       $CC85-G80_RAM_BASE
GS_EnemyShotY         equ       $CC86-G80_RAM_BASE
GS_EnemyShotPixel     equ       $CC87-G80_RAM_BASE
GS_GameSpeed          equ       $CCE9-G80_RAM_BASE
GS_EnemyFireChance    equ       $C971-G80_RAM_BASE
EB_Flags          equ       0
EB_Pixel          equ       1
EB_X              equ       2
EB_Y              equ       3
EB_Tile           equ       4
EB_Overlay        equ       5
EB_Underlying     equ       6
EB_Used           equ       1
EB_OnScreen       equ       2
EB_Half           equ       4
EB_Pattern        equ       $E0
EB_PlayerClass    equ       $C0
EB_HighHalf       equ       $F0
EB_LowHalf        equ       $0F
EB_MinColumn      equ       11
EB_MaxColumn      equ       30
* UpdateEnemyShots stack frame after PSHS D,X,Y,U.
ES_Record         equ       0         stack offset: current pool entry
ES_Count          equ       2         stack offset: remaining slots
ES_Cell           equ       3         stack offset: current tile cell
ES_FrameBytes     equ       5
ES_SavedGame      equ       ES_FrameBytes+2 ; stack offset
ES_SavedVideo     equ       ES_FrameBytes+4 ; stack offset
PP_SavedResult    equ       0         stack offset after PSHS D,X,Y,U: A
PP_SavedRow       equ       1         stack offset after PSHS D,X,Y,U: B
EO_SavedMask      equ       0         stack offset after PSHS D,X,Y,U: A
EO_SavedRecord    equ       2         stack offset: X
EO_SavedCell      equ       4         stack offset: Y

GS_HeatChanged        equ       $CD64-G80_RAM_BASE
GS_HeatClock          equ       $CD65-G80_RAM_BASE
GS_HeatUnits          equ       $CD66-G80_RAM_BASE
GS_HeatPixels         equ       $CD67-G80_RAM_BASE
GS_HeatColor1         equ       $CA7B-G80_RAM_BASE
GS_HeatColor2         equ       $CA7C-G80_RAM_BASE
HEAT_FIRST_PERIOD equ       15
HEAT_PERIOD       equ       13
HEAT_UNLOCK_UNITS equ       8
HEAT_MAX_UNITS    equ       13
HEAT_FULL_PIXELS  equ       7
HEAT_ORIGIN       equ       $00E1
HEAT_LOW_CELLS    equ       9
HEAT_HIGH_CELLS   equ       5
HEAT_LOW_EMPTY    equ       $30
HEAT_LOW_PARTIAL  equ       $31
HEAT_LOW_FULL     equ       $32
HEAT_HIGH_EMPTY   equ       $33
HEAT_HIGH_PARTIAL equ       $34
HEAT_HIGH_FULL    equ       $35
HEAT_PARTIAL_GLYPH equ      $1188
HEAT_FULL_GLYPH   equ       $1190
HEAT_HIGH_GLYPH   equ       $11A0
HEAT_EMPTY_ROW    equ       $7E
GS_PlayerDeathClock   equ       $CCED-G80_RAM_BASE
GS_PlayerDeathSteps   equ       $CCEE-G80_RAM_BASE
GS_PlayerDeathColors  equ       $CAAF-G80_RAM_BASE ; native pointer
GS_PlayerDeathColorA  equ       $CAA0-G80_RAM_BASE
GS_PlayerDeathColorB  equ       $CAA4-G80_RAM_BASE
GS_LifeEnded          equ       $CD0E-G80_RAM_BASE
PLAYER_DEATH_FIRST_PERIOD equ 12
PLAYER_DEATH_PERIOD equ     4
PLAYER_DEATH_STEPS equ      9

* Native-only game state follows, never overlaps the original 2 KB RAM.
GS_LevelSequence equ       G80_RAM_BYTES
GS_WaveCursor    equ       GS_LevelSequence+2
GS_WaveDescriptor equ      GS_WaveCursor+2
GS_YMotionStart  equ       GS_WaveDescriptor+2
GS_XMotionEntry  equ       GS_YMotionStart+2
GS_XMotionLoop   equ       GS_XMotionEntry+2
GS_ExplosionTemplate equ   GS_XMotionLoop+2
GS_ExplosionShape equ      GS_ExplosionTemplate+2
GS_DiveShape     equ       GS_ExplosionShape+2
GS_WaveComplete  equ       GS_DiveShape+2
GS_LevelComplete equ       GS_WaveComplete+1
GS_WaveDelay     equ       GS_LevelComplete+1
GS_FormationFramePeriod equ GS_WaveDelay+1
GS_FormationFrameClock equ GS_FormationFramePeriod+1
GS_IndependentBank equ     GS_FormationFrameClock+1
GS_WorkBytes     equ       GS_IndependentBank+1
GS_FuelEmpty     equ       GS_WorkBytes
GS_Phase         equ       GS_FuelEmpty+1
GS_PhaseClock    equ       GS_Phase+1
GS_Stage         equ       GS_PhaseClock+1
GS_StageRoot     equ       GS_Stage+1
GS_DockArriving  equ       GS_StageRoot+2
GS_DockDoorsStarted equ    GS_DockArriving+1
GS_BonusPrepared equ       GS_DockDoorsStarted+1
GS_BonusCount    equ       GS_BonusPrepared+1
GS_BonusNext     equ       GS_BonusCount+1
GS_BonusLeft     equ       GS_BonusNext+1
GS_BonusClock    equ       GS_BonusLeft+1
GS_BonusID       equ       GS_BonusClock+1
GS_BonusQueue    equ       GS_BonusID+1 ; four amount/identifier byte pairs
GS_RecordPlayer  equ       GS_BonusQueue+8 ; player whose final score is being inserted
GS_RecordRank    equ       GS_RecordPlayer+1 ; zero-based rank, 0..98
GS_RecordLetter  equ       GS_RecordRank+1 ; current initial, 0..2
GS_RecordButtons equ       GS_RecordLetter+1 ; previous controls for edge detection
GS_RecordClock   equ       GS_RecordButtons+1 ; word: ticks left for initials entry
GS_RecordPointer equ       GS_RecordClock+2 ; pointer to current initials record
GS_SoundPending  equ       GS_RecordPointer+2 ; bitset: one-shot classes this tick
GS_DemoActive    equ       GS_SoundPending+1
GS_DemoDirection equ       GS_DemoActive+1
GS_TitleClock    equ       GS_DemoDirection+1 ; word: native help page duration
GS_RecordKeys    equ       GS_TitleClock+2 ; six previous held codes for typed initials
GS_AttractPage   equ       GS_RecordKeys+ASTRO_LIVEKEY_BYTES ; 0 none, 1 marquee pulse, 2 marquee fade
GS_AttractStep   equ       GS_AttractPage+1 ; marquee fade steps left
GS_Extent        equ       GS_AttractStep+8
MARQUEE_PULSE_FRAMES equ   256       original $8556..$855F: color 3 cycles 256 frames
MARQUEE_FADE_STEPS equ     8         original $8560..$8595
MARQUEE_FADE_FRAMES equ    6
TITLE_DURATION  equ       10*60
TITLE_CREDIT_CELL equ      $01F6     upright row 9
SFX_LASER       equ       1
SFX_WARP        equ       2
SFX_ENEMY       equ       3
SFX_BONUS       equ       4
SFX_PLAYER      equ       5
SFX_DOCK        equ       6
SFX_ENEMY_SHOT  equ       7
SFX_SONAR       equ       8
ASTRO_DMA_CLEAR equ       $7100     DmaWt.Poll, 16-bit, transparent fill
SCORE_TABLE_COUNT equ      99
SCORE_TABLE_BYTES equ      SCORE_TABLE_COUNT*2
SCORE_TOP_COUNT  equ       3
SCORE_INITIAL_RANKS equ    10        original $3BCE accepts ranks 1..10
SCORE_INITIALS_BYTES equ   4
SCORE_INITIAL_COUNT equ    3
SCORE_INITIAL_FIRST equ    $4A       A in the original font
SCORE_INITIAL_LAST equ     $63       Z in the original font
SCORE_ENTRY_TICKS equ      30*60
SCORE_TITLE_TICKS equ      180
SCORE_RANK1_CELL equ       $0079     original $406E: column 3, row 25
SCORE_RANK2_CELL equ       $02F9     original $4085: column 23, row 25
SCORE_TOP_CELL   equ       $0135     row 10 in upright view, column 9
SCORE_TOP_NAME_CELL equ    $0095     same row, column 4
SCORE_INITIAL_CELL equ     $0191     centered row 14, column 12
* High-score insertion local frame after PSHS D,X,Y,U.
HS_Value        equ       0         stack offset: score being inserted
HS_Insert       equ       2         stack offset: table insertion pointer
HS_FrameBytes   equ       4
HS_Game         equ       HS_FrameBytes+2 ; stack offset: saved X game base
HS_Video        equ       HS_FrameBytes+4 ; stack offset: saved Y video base
* ReadRecordKey local frame after PSHS B,X,Y.
IE_Key          equ       0         stack offset: first newly pressed entry key
IE_FrameBytes   equ       1
IE_Game         equ       IE_FrameBytes+1 ; stack offset: saved X game base
IE_SearchBytes  equ       3         nested PSHS B,Y while searching held codes
GS_WaveReentered      equ       $CD56-G80_RAM_BASE
GS_LevelLifeLost      equ       $CD58-G80_RAM_BASE
GS_KillOrderBad       equ       $CD59-G80_RAM_BASE
GS_KillSequence       equ       $CD5A-G80_RAM_BASE
GS_LevelOverheat      equ       $CD6F-G80_RAM_BASE
BONUS_MAX        equ       4
BONUS_INTRO_TICKS equ      120
BONUS_COUNT_TICKS equ      4
BONUS_TILE_BACKUP equ      $0400
BONUS_PATTERN_LOW equ      G80_PLANE0_OFFSET+$73*G80_GLYPH_BYTES
BONUS_PATTERN_HIGH equ     BONUS_PATTERN_LOW+G80_PLANE_SPACING
BONUS_PATTERN_BYTES equ    64
BONUS_COLORS     equ       GS_PaletteSource+28
BONUS_TOP_LEFT   equ       $00DD
BONUS_TOP_RIGHT  equ       $02BD
BONUS_BOTTOM_RIGHT equ     $02B7
BONUS_BOTTOM_LEFT equ      $00D7
BONUS_LEFT_INNER equ       $00D8
BONUS_RIGHT_INNER equ      $02B8
BONUS_TOP_INNER  equ       $00FD
BONUS_BOTTOM_INNER equ     $00F7
BONUS_INSIDE     equ       $00F8
BONUS_TEXT1      equ       $011B
BONUS_TEXT2      equ       $013A
BONUS_NUMBER    equ       $023A
BONUS_AMOUNT    equ       $0199
BO_Game         equ       2         stack offset after PSHS D,X,Y,U
BO_Video        equ       4         stack offset after PSHS D,X,Y,U
SC_Award        equ       0         stack offset after PSHS D,X,Y,U
STAGE_WAVES      equ       0
STAGE_ASTEROIDS  equ       1
STAGE_DOCK       equ       2
GS_AsteroidTicks      equ       $C982-G80_RAM_BASE
GS_AsteroidClock      equ       $C987-G80_RAM_BASE
GS_AsteroidSpawnClock equ       $CABB-G80_RAM_BASE
GS_AsteroidRows       equ       $CD16-G80_RAM_BASE
GS_PodObject          equ       $CCF9-G80_RAM_BASE
GS_PodClock           equ       $CA6B-G80_RAM_BASE
GS_PodsMissed         equ       $CD60-G80_RAM_BASE
GS_PodColors          equ       $CA8B-G80_RAM_BASE
GS_DockObjects        equ       $C9A7-G80_RAM_BASE
GS_Docked             equ       $C9A4-G80_RAM_BASE
GS_DockComplete       equ       $C9A5-G80_RAM_BASE
GS_DockDoorClock      equ       $CA59-G80_RAM_BASE
GS_DockBonusClock     equ       $CA5A-G80_RAM_BASE
GS_DockAction         equ       $CA5D-G80_RAM_BASE
GS_DockTouch          equ       $CA5E-G80_RAM_BASE
GS_TractorColorClock  equ       $CA61-G80_RAM_BASE
GS_DockThrustClock    equ       $CA65-G80_RAM_BASE
GS_DockAdvancing      equ       $CA66-G80_RAM_BASE
GS_DockFailed         equ       $CA67-G80_RAM_BASE
GS_TractorClock       equ       $CD15-G80_RAM_BASE
GS_DockCorrected      equ       $CD53-G80_RAM_BASE
GS_DockAlignmentPixel equ       $CD6D-G80_RAM_BASE
GS_DockAlignmentRow   equ       $CD6E-G80_RAM_BASE
GS_OtherLevel         equ       $CAB8-G80_RAM_BASE
DK_Objects       equ       0
DK_Colors        equ       2
DK_TractorColors equ       4
DK_TractorLow    equ       6
DK_TractorHigh   equ       8
DK_Awards        equ       10
DOCK_OBJECT_COUNT equ      11
DOCK_DOOR_PERIOD equ       6
DOCK_BONUS_PERIOD equ      2
DOCK_THRUST_PERIOD equ     2
DOCK_TRACTOR_PERIOD equ    3
DOCK_COLOR_PERIOD equ      6
DOCK_FINAL_X      equ       15
DOCK_PALETTE_E    equ       GS_PaletteSource+56
DOCK_PALETTE_3    equ       GS_PaletteSource+12
DOCK_TRACTOR_LOW  equ       $0B80
DOCK_TRACTOR_HIGH equ       $1380
* Dock initialization stack offsets after PSHS D,X,Y,U and local frame.
DI_Index          equ       0         stack offset: object index 0..10
DI_FrameBytes     equ       1
DI_Game           equ       DI_FrameBytes+2 ; stack offset: original X
DI_Video          equ       DI_FrameBytes+4 ; stack offset: original Y
DI_Process        equ       DI_FrameBytes+6 ; stack offset: original U
ASTEROID_ROWS    equ       25
ASTEROID_POSITION_BYTES equ 30
ASTEROID_FIRST_SPAWN equ    8
ASTEROID_SPAWN_PERIOD equ   4
ASTEROID_DRAIN_TICKS equ    130
AR_Object        equ       0
AR_Positions     equ       2
AR_Explosion     equ       4
AR_Pod           equ       6
AR_Durations     equ       8
AR_PodColors     equ       10
PHASE_TITLE      equ       0
PHASE_PLAY       equ       1
PHASE_DEATH_WAIT equ       2
PHASE_GAME_OVER  equ       3
PHASE_BONUS     equ       4
PHASE_INITIALS  equ       5
DEATH_WAIT_TICKS equ       60
GAME_OVER_TICKS  equ       180
INITIAL_LIVES   equ       3
PH_X             equ       0         stack offset: current player tile column
PH_Y             equ       1         stack offset: current player tile row
PH_Tile          equ       2         stack offset: new player glyph
PH_UnderTile     equ       3         stack offset: old glyph under player
PH_Columns       equ       4         stack offset: columns remaining
PH_Rows          equ       5         stack offset: rows remaining
PH_Height        equ       6         stack offset: rows per column
PH_FrameBytes    equ       7
PH_Game          equ       PH_FrameBytes+2 ; stack offset: saved X
PH_Video         equ       PH_FrameBytes+4 ; stack offset: saved Y
GS_FormationOriginal  equ       $C907-G80_RAM_BASE
GS_OriginalCount equ       GS_FormationOriginal
GS_OriginalAlive equ       GS_FormationOriginal+1
GS_OriginalPositions equ   GS_FormationOriginal+2
GS_WaveClock          equ       $C900-G80_RAM_BASE
GS_KillPoints         equ       $C97A-G80_RAM_BASE
GS_FormationMode      equ       $C97B-G80_RAM_BASE
GS_FormationType      equ       $C98A-G80_RAM_BASE ; native enum, not Z80 jump pointer
GS_IndependentObjects equ       $CABC-G80_RAM_BASE
GS_DiverActive        equ       $CD32-G80_RAM_BASE
GS_DiverObject        equ       $CD34-G80_RAM_BASE
GS_DiverEscaped       equ       $CD50-G80_RAM_BASE
GS_DiverMissed        equ       $CD57-G80_RAM_BASE
W_YMotion        equ       0
W_XEntry         equ       2
W_XLoop          equ       4
W_Positions      equ       6
W_Shape          equ       8
W_Object         equ       10
W_Speed          equ       12
W_FireChance     equ       13
W_KillPoints     equ       14
W_Mode           equ       15
W_Kind           equ       16
W_Explosion      equ       18
W_Color1         equ       20
W_Color2         equ       21
W_AnimationPeriod equ      22
W_Sound          equ       23
W_ExplosionShape equ       24
W_DiveShape      equ       26
WAVE_ORDINARY    equ       0
WAVE_DIVERS      equ       2
WAVE_INDEPENDENT equ       4
WAVE_INTERVAL   equ       20
IM_PixelX        equ       0
IM_PixelY        equ       1
IM_DeltaX        equ       2
IM_DeltaY        equ       3
IM_Timer         equ       4
IM_Cursor        equ       5         native word
IM_Bytes         equ       7
IM_Count         equ       4
* InitializeWave stack offsets after PSHS D,X,Y,U.
WI_Game          equ       2         stack offset: X
WI_Video         equ       4         stack offset: Y
WI_Sequence      equ       6         stack offset: U
* UpdateIndependentFormation stack offsets after PSHS D,X,Y,U.
IF_Record        equ       0         stack offset: motion record pointer
IF_Position      equ       2         stack offset: position pointer
IF_Count         equ       4         stack offset: ships remaining
IF_Bank          equ       5         stack offset: glyph bank for current ship
IF_FrameBytes    equ       6
IF_Game          equ       IF_FrameBytes+2 ; stack offset
IF_Video         equ       IF_FrameBytes+4 ; stack offset
DIVER_PERIOD_RANDOM equ    100
DIVER_SPEED      equ       -3

* Never use original G80 addresses as physical WildBits stores. Translate
* them to owned process storage or the platform video/input/sound interface.
* The G80 315-0062 changes LD (nn),A destinations according to the ORIGINAL
* opcode address. The disassembly records both encoded and effective targets.

* Cached portrait renderer: offsets from AD_FastRender, owned per process.
* Render strip state: one original eight-row tile column at a time.
FR_Block equ 0
FR_Offset equ 2
FR_MappedBlock equ 4
FR_Cell equ 6
FR_Dirty equ 8
FR_CellsLeft equ 10
FR_Packed equ 11
FR_StateBytes equ 13
* RC_: stack offsets from cell renderer after PSHS D,X,Y and local frame.
RC_Glyph equ 0
RC_Pairs equ 2
RC_Block equ 4
RC_Offset equ 6
RC_Rows equ 8
RC_RowList equ 9
RC_FrameBytes equ 11
* Strip table: first bitmap row, retained rows, followed by cache offsets.
RS_FirstRow equ 0
RS_Count equ 1
RS_CacheRows equ 2
RS_Bytes equ 10

* RC26 fixed speech port; bit 7 identifies hardware, bit 0 accepts a byte.
SP_Port equ $FF9F
SP_Present equ $80
SP_Ready equ 1
SP_FrameBytes equ 15
SP_BufferBytes equ 240
SP_Enabled equ 0
SP_FirstBlock equ 1
SP_OwnsBlocks equ 3
SP_Block equ 4
SP_Offset equ 6
SP_Remaining equ 8
SP_Sequence equ 10
SP_BufferRead equ 12
SP_BufferCount equ 14
SP_FramePosition equ 15
SP_Pending equ 16
SP_LastPhase equ 17
SP_LastDemo equ 18
SP_LastLevel equ 19
SP_LastPlayer equ 20
SP_LastFuel equ 21
SP_LastHeat equ 22
SP_LastStage equ 23
SP_LastLock equ 24
SP_Closing equ 25
SP_Error equ 26
SP_Hushed equ 27
SP_Buffer equ 28
SP_StateBytes equ SP_Buffer+SP_BufferBytes
SP_WordEntryBytes equ 5
SP_PhraseAttract equ 37
SP_PhraseSector equ 19
SP_PhraseLowFuel equ 36
SP_PhraseCriticalFuel equ 35
SP_PhraseHot equ 43
SP_PhraseLocked equ 44
SP_PhraseCooled equ 45
SP_PhraseDock equ 18
SP_PhraseGameOver equ 46
SP_CloseTicks equ 120

DC_Glyph equ 0 ; stack offset: current glyph number
DC_Mask equ 1 ; stack offset: source-column change mask
DC_FrameBytes equ 2
CG_Mask equ 0 ; stack offset: selected original column
CG_Pixels equ 1 ; stack offset: four packed pixels
CG_Rows equ 2 ; stack offset: source rows remaining
CG_Source equ 3 ; stack offset: source glyph pointer
CG_FrameBytes equ 5
KEY_SHOOT_LOWER equ 's
KEY_SHOOT_UPPER equ 'S

GC_Low equ 0 ; stack offset: eight shifting low-plane source bytes
GC_High equ 8 ; stack offset: eight shifting high-plane source bytes
GC_Columns equ 16 ; stack offset: columns remaining
GC_FrameBytes equ 17

* RP_: stack offsets for one strip's packed dirty-cell records.
RP_Count equ 0
RP_Left equ 1
RP_Rows equ 2
RP_RowList equ 3
RP_Subrow equ 5
RP_Write equ 6
RP_Read equ 8
RP_ByteX equ 10
RP_Block equ 11
RP_Offset equ 13
RP_Packets equ 15
RP_RecordBytes equ 6
RP_RowMask equ RP_Packets+28*RP_RecordBytes
RP_FrameBytes equ RP_RowMask+1
