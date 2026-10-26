********************************************************************
* fsp - FS (Flight Simulator II), WildBits port: the dashboard
*
* A raw binary, not a module, like fsx: fsw's PInit reads /dd/fs2/fsp into a RAM block of its own, and fsw maps
* that block at FspBase (in place of the panel's block, as fsx's) only while fsp runs: FspInit once from fsw's
* Init, FspFrame every frame from fsw's Frame. The dash is bitmap 2, a 640x240 HIRES4 plane on layer 0 (VICKY's
* top layer) on both machines: rows 147-239 hold the art, rows 0-146 are nibble 0, HIRES4's transparent pixel,
* so the view on layer 1 (the K2's GPU, the Jr2's flipped bitmaps 0 and 1) shows through them and through the
* corners above the glareshield's curve. The art (wildbits-buildkit/tools/flightsim2/dash/mkdash.py from
* notes/dash/dash_static16.png, option B of 2026-10-17) is the file /dd/fs2/dash.bm, 93 rows of 320 bytes then
* the 15-color palette (CLUT entries 1-15, blue, green, red, 0 each).
*
* FspInit (A = bitmap 2's first block, X = fsp's own block, U = the first of the four RAM blocks that keep the
* pristine copy the instruments are restored from, Y = bitmap 1's first block on the K2, the second dash buffer,
* else 0): the art into the bitmap (bitmap 1 too, with its CLUT, on the K2) and the pristine copy, read in
* chunks into this block's buffer and moved by the DMA engine (1D, waited for: it runs in the vertical blank; a
* copy that does not finish is a failure); the palette into CLUT 1, and bitmap 2 pointed at CLUT 1 (the view
* keeps CLUT 0). Carry set: no dash, B = the step that refused (1 the open, 2 a short file or a read error, 3 a
* DMA copy, 4 the CLUT write, 5 the bitmap configure); fsw shows it (PBar). There is no other panel.
* FspFrame: the instruments.

                    nam       fsp
                    ttl       FS2 WildBits dashboard

                    ifp1
                    use       defsfile
                    use       fs_wb.d
                    endc

* Constants: the values this module's instructions use, by name (fs_wb.d holds the addresses)
ActNdRXCut          equ       6                   the actor's needle: x radius 6 dots shorter than the rim
ActNdRYCut          equ       3                   the actor's needle: y radius 3 rows shorter
AdfFaceOfs          equ       FaceOff&$FFFF       the ADF's face in the pristine copy: its offset's low 16 bits
AdfNdRXCut          equ       3                   the ADF needle: x radius 3 dots shorter
AdfNdRYCut          equ       2                   the ADF needle: y radius 2 rows shorter
AdfOn               equ       1                   AdfCa: the ADF switch on
AltSmRXCut          equ       10                  the altimeter's small hand: x radius 10 dots shorter
AltSmRYCut          equ       6                   the altimeter's small hand: y radius 6 rows shorter
Angle8Half          equ       $80                 180 degrees in an 8-bit angle (256 a turn)
AsciiZero           equ       '0                  the ASCII digit 0
AtBankMax           equ       42                  the largest bank size the ball shows (CotT, SinT, CosT: 0-42)
AtPoMax             equ       16                  the horizon's largest offset below the ball's center (pitch / 2, rows)
AtPoMin             equ       -16                 the horizon's largest offset above the ball's center
BallBottom          equ       16                  the ball's bottom row off its center (AtDy's last)
BallHalfH           equ       16                  rows under 16 off the ball's center lie inside it
BallTop             equ       -16                 the ball's top row off its center (AtDy's first)
BcdLoDigit          equ       $0F                 a BCD byte's low digit
BlkPages            equ       32                  a block's 256-byte pages ($2000 / 256)
BmCfgClut1          equ       $FF01               SS.BmCfg's X: the enable kept ($FF, high byte), CLUT 1 (low byte)
BmCfgKeep           equ       $FFFF               SS.BmCfg's X or U: both bytes $FF, both fields kept as they are
BmNum0              equ       0                   bitmap 0's number: Y counts up from it to bitmap 1's (leay 1,y)
BmNumDash           equ       2                   the dash's bitmap number: bitmap 2
BmNumSecond         equ       1                   the K2's second dash buffer's bitmap number: bitmap 1
BmRowBytes          equ       320                 a bitmap row: 320 bytes (640 dots, HIRES4)
BmRowHalf           equ       320/2               half a bitmap row: row x 160, then x 2 with bit 16 in the carry
BufOffHi            equ       (Buf-FspBase)/256   Buf's offset in this block, in 256-byte pages
CacheStale          equ       $FF                 a cache value no state matches: the item is drawn again next frame
CardMajorEvery      equ       3                   a major tick every 3 ticks (30 degrees)
CardTickDeg         equ       10                  a card tick every 10 degrees
CardTicks           equ       36                  a card's ticks a turn
CdiCenter           equ       15                  the CDI's centered value (0-30)
CdiHalfRows         equ       9                   the CDI needle's rows each side of the center (19 rows)
CdiScale            equ       21                  the CDI's dots per unit x 16 (21 / 16)
CharPitch           equ       8                   a digit's room in a readout: 8 dots
ChBlank             equ       10                  a readout character code: blank (a dark 8)
ChColon             equ       12                  a readout character code: ':' lit
ChPoint             equ       11                  a readout character code: '.' lit (the codes from 11 are no digits)
ChPointDim          equ       13                  a readout character code: '.' dark
ColonPitch          equ       3                   a colon's room in a readout: 3 dots
ColonStep           equ       2                   a colon's dots: 2 rows apart, from 2 below the top
Com2Lead            equ       1                   COM2's first digit, always 1 (121.15)
CotTFirst           equ       3                   CotT's first bank: below it the horizon is level
CpCornerX           equ       0                   the windshield's top-left corner: its first column
CpPostEnd           equ       DashTop-1           the windshield post's last row: above the dash's top edge
CtrDotLeft          equ       1                   the center dot's first column left of cx
CtrDotUp            equ       2                   the center dot's top row above cy
CtrDotW             equ       2                   the center dot's last column after its first
DashLayer           equ       0                   the dash's layer: 0, VICKY's top (SS.PScrn's X)
DashOffHi           equ       DashOff/256         DashOff's high bytes: the art's offset in a bitmap, in 256-byte pages
DashOffLo           equ       DashOff&255         DashOff's low byte
DashPalClut         equ       $0101               SS.ClutWrite's Y for the dash's palette: CLUT 1 (high byte), from entry 1 (low byte)
DecHundred          equ       100                 Dec3's hundreds digit's step
DecTen              equ       10                  Dec3's tens digit's step
DegPosMul           equ       125                 degrees x 125 >> 9: dial positions (88 / 360)
DegTurn             equ       360                 degrees a turn
DialCSSize          equ       2                   a DialCS entry: 2 bytes (cos, sin)
DialPosCount        equ       88                  FS's dial positions a turn (DialCS)
DialPosHalf         equ       44                  half a turn in dial positions: the opposite side
DialPosTop          equ       22                  the dial position at 12 o'clock (0 = 3 o'clock, anticlockwise)
DigitMax            equ       9                   the largest decimal digit
DivBits             equ       24                  Div's dividend bits (DvN)
DmaFallPolls        equ       0                   DmaWait's polls for its fall: 0 = 65,536 (leay -1,y wraps)
DmaRisePolls        equ       64                  DmaWait's polls for the busy flag's rise
DmRingMask          equ       7                   DmI's wrap: the ring's 8 slots
DmRingN             equ       8                   the DME ring's samples (16 s, one every 2 s): full
ElevScale           equ       93                  x 93 / 256: the elevator 0-160 to rows 0-58 (x 58 / 160)
EtMinWrap           equ       100                 the elapsed timer's minutes wrap to 0 there (0-99)
EvenMask            equ       $FE                 bit 0 cleared: an even value (a whole word for the double-speed DMA, an even address)
FaceOfsTop          equ       1                   the faces' offsets' bits 23-16 (FaceOff is $12C00)
FfScale             equ       176                 x 176 / 256: the throttle's high byte to tenths of a gallon an hour (x 0.687)
FlapsFull           equ       $60                 vFlaps' high byte at full flaps (0 up, $20 a notch)
FlapsRows           equ       58                  the flaps lever's travel, rows (up: at the slot's top)
FlapsScale          equ       155                 x 155 / 256: flaps $00-$60 to rows 0-58 (x 58 / 96)
FlipPendOn          equ       1                   FlipPend: the hidden buffer is drawn, to be shown
FlipRasMax          equ       300                 Flip's raster limit: lines under 300 lie above the art
FreqChars           equ       6                   a frequency readout's characters (3 digits, a point, 2)
FsElevFullNeg       equ       -$50                the elevator's full travel the other way: vElevator's high byte -$50
FuelFull            equ       32                  a tank's units when full ($20): the needle at x0 + 2 x units
GaugeMaxDot         equ       64                  a gauge needle's last dot from x0 (x1 - x0)
GgNdStep            equ       2                   the gauge needle's next width two rows down (1, 3, 5 dots)
GgNdTop             equ       2                   the gauge needle's first row below the gauge's top
GgSelRows           equ       8                   the selected gauge's outline: its bottom row below its top
Gl35ColBit          equ       4                   a glyph row's tested bit: bit 2, the left column (the row shifts left)
Gl35Cols            equ       3                   a 3 x 5 glyph's columns
Gl35CtrX            equ       1                   a 3 x 5 glyph's center column right of its left
Gl35CtrY            equ       2                   a 3 x 5 glyph's center row below its top
Gl35Pitch           equ       4                   the next letter's left dot: 4 dots on
Gl35Rows            equ       5                   a 3 x 5 glyph's rows
GpuCtl256           equ       $02                 Gpu.Ctrl b1: the 320 x 256-color view (clear: 640 x 16)
GpuCtlDither        equ       $08                 Gpu.Ctrl b3: DITHER
GpuXFixN            equ       GpuF.FixN*256       SS.Gpu's X: GpuF.FixN in the high byte, block 0 (VICKY's fixed registers)
GpuXList            equ       GpuF.List*256       SS.Gpu's X: GpuF.List in the high byte, block 0
GsClosureMax        equ       255                 the largest closure GS takes (one byte, 16 m units)
GsScale             equ       249                 x 249 / 128: 16 m / 16 s to knots (1.944)
HorizonHW           equ       34                  the horizon line's half width, pixels: the ball's widest
HubTopUp            equ       2                   the hub's top row above the dial's center (5 rows)
KnNoFill            equ       $7F                 a Knob shape row's fill first dot: no fill on that row
LampBulbDown        equ       2                   a lamp's bulb: its top row below the socket's y0
LampOn              equ       1                   Lamp's A: lit
LdCountHiBits       equ       $3F                 the line engine's FIFO count (SS.BmLine's GetStat X): bits 13:8 in its high byte
LdFifoEmpty         equ       0                   the line engine's FIFO count when it is empty
LnBothOn            equ       1                   LnBoth: Ln draws on both dash buffers
LnRecSize           equ       8                   a line engine record: 8 bytes
LubberRows          equ       4                   the lubber line's last row below its first
LvKnobUp            equ       3                   a lever knob's top row above the handle row (7 rows)
MarkEnd             equ       4                   one past the last pitch mark (3)
MarkEvenHW          equ       12                  a 10-degree pitch mark's half width, pixels
MarkFirst           equ       -3                  the first pitch mark (k)
MarkMinHW           equ       2                   the shortest pitch mark half width drawn, pixels
MarkOddHW           equ       6                   a 5- or 15-degree pitch mark's half width, pixels
Max3Digits          equ       999                 the largest three-digit value a readout shows
MinorTickCut        equ       2                   a minor tick: 2 shorter than a major
MixFull             equ       64                  the mixture at full rich: the handle's rows up (the slot's top)
MovedStart          equ       0                   Done's start: no bitmap or face bytes moved yet
Nav2FaceOfs         equ       (FaceOff+FaceW*FaceH)&$FFFF NAV2's face in the pristine copy: its offset's low 16 bits
NavLetInX           equ       8                   the VOR cards' letters: x inset from the rim, dots
NavLetInY           equ       6                   the VOR cards' letters: y inset from the rim, rows
NavTickLen          equ       4                   the VOR cards' major tick length (a minor 2 shorter)
NdBaseStep          equ       1                   the needle's three-dot base: 1 dot apart (cx - 1 .. cx + 1)
NdTailRadii         equ       $0402               the needle's tail: x radius 4 (high byte), y radius 2 (low byte), into NdRX, NdRY
NegBorrow           equ       0                   sbca #0 after nega, negb: the borrow that completes D's negation
NegCarry            equ       1                   the 1 that completes D's two's-complement negation (coma, comb)
Num3Chars           equ       3                   a three-digit readout's characters (GS, TTS)
Num3LzN             equ       2                   Num3's leading digits that blank when zero
NvFlFr              equ       2                   NavDial's flag: FR
NvFlTo              equ       1                   NavDial's flag: TO
NvFlUp              equ       9                   the flag's top row above the dial's center
NvFlX               equ       9                   the flag's first dot right of the dial's center
ObsDegUnit          equ       2                   the OBS's unit: 2 degrees
OddBit              equ       1                   bit 0: an odd value
OilPMax             equ       10                  the oil pressure's top taken ($0A running)
OilPScale           equ       13                  x 13 / 2: oil pressure to needle dots (about x 6.4)
OilTMax             equ       21                  the oil temperature's top taken (x 3: 63 dots)
OilTScale           equ       3                   x 3: oil temperature to needle dots
PalEntries          equ       15                  the dash palette's CLUT entries (1-15)
PointRow            equ       6                   a point's row below the character's top
PrisBaseHi          equ       PrisBase/256        PrisBase in 256-byte pages: the pristine copy's first bitmap offset
PtrBaseHW           equ       2                   the bank pointer's base: pixels each side along the horizon
PtrBaseUp           equ       26                  the bank pointer's base: pixels up from the ball's center
PtrTipUp            equ       32                  the bank pointer's tip: pixels up from the ball's center
RasBlankEnd         equ       40                  the update window's end: raster lines under 40 (the picture is lines 45-524)
RasFrameEnd         equ       470                 the raster line from which the frame's end opens the update window (two buffers)
RasLineHiBits       equ       $0F                 VKY_LINE_Y_POS_HI: the raster line's bits 11:8 in its low nibble
RasNever            equ       $FFFF               GpuW.Ras's U: a raster line never reached (one buffer: the window is the blank only)
RivetRow0           equ       6                   the post's first rivet row
RivetRowEnd         equ       DashTop-4           the rivets stop above this row (the dash's top less 4)
RivetStep           equ       10                  the rivets' spacing, rows
RivetX0             equ       CpPX+3              the post's left rivet column
RivetX1             equ       CpPX+8              the post's right rivet column
RolaStart           equ       0                   a byte that takes the carry in by rola (clra would clear the carry)
RoseBarDown         equ       6                   the rose airplane's bar: its bottom row below the center
RoseBarUp           equ       9                   the rose airplane's bar: its top row above the center
RoseLetInX          equ       9                   the rose's letters: x inset from the rim, dots
RoseLetInY          equ       6                   the rose's letters: y inset from the rim, rows
RoseTickLen         equ       5                   the heading rose's major tick length (a minor 2 shorter)
RoseWingHalf        equ       7                   the rose airplane's wings: dots each side of the center
RoseWingSpan        equ       14                  the rose airplane's wings: last dot after the first
RpmPosLast          equ       63                  RpmPos's last entry ($072C taken up to it)
RudderMax           equ       124                 the largest rudder high-byte size taken
RudderScale         equ       29                  x 29 / 256: the rudder high byte's size to dots off the bar's middle
RudKnobTop          equ       RudY0-1             the rudder knob's top row
RudMidX             equ       (RudX0+RudX1)/2     the rudder bar's middle dot (the knob at 0)
RwItN               equ       1                   RasW's GpuF.List: one item (RwIt)
RyBytes             equ       2                   RasY's request: two bytes (VKY_LINE_Y_POS_HI, _LO)
SecPerMin           equ       60                  seconds a minute (the elapsed timer)
SegAll              equ       $7F                 all seven segments of a readout digit (a-g in bits 0-6)
SegCount            equ       7                   a digit's segments (a-g)
ShownBit            equ       1                   Shown's toggle: 0 bitmap 2 on layer 0, 1 bitmap 1
SlipBallRow         equ       11                  the slip ball's top row below the dial's center
SlipBias            equ       $7F                 127: the signed slip value made unsigned for the two shifts
SlipBiasDiv4        equ       $1F                 31: SlipBias / 4, taken back off after the two shifts
SlipMax             equ       8                   the slip ball's last position right of center (2 dots each)
SlipMin             equ       -8                  the slip ball's last position left of center
SpotOfs             equ       FaceY*320+FaceX     the NAV2 spot's offset in a bitmap (row FaceY, byte FaceX)
SpotOfsTop          equ       0                   the spot offset's bits 23-16: the carry only
St640               equ       8                   StCa's bit: the 640 x 16 view
StallWarnAoA        equ       $21                 vAngleOfAttack's high byte from which the stall light shows (FS stalls at $24)
StDither            equ       4                   StCa's bit: the dither on (the right third blue)
StepClut            equ       4                   Init's failing step: 4 the CLUT write
StepOpen            equ       1                   Init's failing step for fsw's PBar: 1 the open
StRibbon            equ       2                   StCa's bit: the line ribbons on (the middle green)
StripClrRows        equ       8                   the rows Strip covers, 0-7 (below its height cleared)
StripRows           equ       2                   the strip's height, rows
TailProbeLen        equ       1                   the read past the palette: 1 byte (one there: not a dash file)
TcFinDown           equ       2                   the fin's bottom row below the dial's center
TcFinUp             equ       4                   the fin's top row above the dial's center
TcLevel             equ       8                   FS's turn index ($0800, 0-15) for wings level: dial position 0
TcWingRX            equ       16                  the turn airplane's wing: x radius, dots
TcWingRY            equ       4                   the turn airplane's wing: y radius, rows
TenthChars          equ       4                   a tenths readout's characters (2 digits, a point, 1: FF, USED)
TenthLzN            equ       1                   Tenth's leading digits that blank when zero: the first
TenthsPerUnit       equ       10                  tenths a fuel unit (gallon)
TfNone              equ       999                 FswTfDst's value with no actor
ThrScale            equ       137                 x 137 / 256: the throttle's high byte to the handle's rows (x 0.535)
TrimBias            equ       80                  the trim's high byte -$50..$50 made 0-160
TrimScale           equ       103                 x 103 / 256: the trim 0-160 to the handle's rows (x 0.402)
TtsClosureMax       equ       2184                TTS's largest closure: x 15 stays under 32,768 (Div's divisor)
WingBarLen          equ       11                  a wing bar's last dot after its first
WingDropR           equ       4                   the right turned-down end's first dot right of cx
WingDropRows        equ       2                   the turned-down ends' last row below their first (cy + 1 .. + 3)
WingInner           equ       5                   the wing bars' inner ends, dots off cx
WingOuter           equ       16                  the miniature aircraft's wing bars: outer ends, dots off cx
ZeroExtHi           equ       0                   a byte's high byte added to or taken from D: the carry or borrow only

                    org       FspBase

* Entry table (FspInit, FspFrame in fs_wb.d)
                    jmp       Init
                    jmp       Frame

DashRow0            equ       147
DashOff             equ       DashRow0*320        $B7C0: the art's first byte in a bitmap
DashBytes           equ       93*320              29,760
PalBytes            equ       15*4
* the NAV2 spot's two faces (mkdash.py, after the bitmap in dash.bm): the ADF's, then NAV2's, each the spot's
* region (FaceX byte, FaceW bytes, FaceY row, FaceH rows); kept in the pristine copy past its rows (bitmap row 240
* on), copied over the spot's region there when the ADF goes on or off
FaceX               equ       (DNv2CX-36)/2
FaceW               equ       38                  even: the double-speed DMA moves two bytes at a time
FaceY               equ       DNv2CY-18
FaceH               equ       37
FaceBytes           equ       2*FaceW*FaceH       2,812
FaceOff             equ       240*320             the ADF's face, at the pristine copy's offset $12C00; NAV2's after
* the pristine copy: fsw's five blocks hold the bitmap's offsets from PrisBase on (2026-10-19: they were taken at
* the bitmap's own offsets, $B7C0 on, 5-9 blocks past the four fsw took)
PrisBase            equ       5*$2000
ChunkMax            equ       $0200               the buffer at the block's end, 512 bytes (768 until the fuel tank outline, 1 KB until the audio panel, 2 KB until the
*                                                 state strip; a page multiple: Init takes its 24-bit address by pages)

* Init: see the header. A = bitmap 2's first block, X = this block, U = the pristine copy's first block.
Init                pshs      d,x,y,u
                    sta       DashBlk
                    stx       Self
                    tfr       u,d
                    stb       Pris
                    tfr       y,d                 the K2's second dash buffer, bitmap 1 (0: none)
                    stb       Bm1
                    lda       #StepOpen           the step that refuses, for fsw's PBar: 1 the open
                    sta       InStep
                    lda       #READ.
                    ldx       #DName
                    swi2
                    fcb       I$Open
                    lbcs      in8@
                    sta       Path
                    inc       InStep              2 a short or long file, or a read error
* the two 24-bit destinations: block * $2000 + DashOff, in the bitmap and the pristine copy; the source is this
* block's buffer: Self * $2000 + (Buf - FspBase)
                    lda       DashBlk
                    lbsr      BlkAdr              D:B = block * $2000 >> 8 in D, low byte 0
                    addd      #DashOffHi
                    std       Dst0
                    ldb       #DashOffLo
                    stb       Dst0+2
                    lda       Pris
                    lbsr      BlkAdr
                    subd      #PrisBaseHi         the copy's blocks hold the bitmap's offsets from PrisBase on
                    addd      #DashOffHi
                    std       Dst1
                    ldb       #DashOffLo
                    stb       Dst1+2
                    lda       Bm1                 and in bitmap 1
                    beq       inb@
                    lbsr      BlkAdr
                    addd      #DashOffHi
                    std       Dst2
                    ldb       #DashOffLo
                    stb       Dst2+2
inb@
                    lda       Self+1
                    lbsr      BlkAdr
                    addd      #BufOffHi
                    std       Src
                    clr       Src+2
* the pristine copy's 24-bit base, the regions' restore source (the destination is bitmap 2, BmAdr from Frame)
                    lda       Pris
                    lbsr      BlkAdr
                    subd      #PrisBaseHi
                    std       PrAdr
                    clr       PrAdr+2
                    ldd       #MovedStart
                    std       Done                bitmap and face bytes moved so far
* the file in three parts, read so that no chunk spans two: the bitmap's DashBytes (to the bitmaps and the
* pristine copy), the NAV2 spot's two faces (FaceBytes, to the pristine copy only, past its rows), the palette
in1@                ldd       Done
                    cmpd      #DashBytes+FaceBytes
                    bhs       in4@                both done: the palette
                    ldd       #DashBytes
                    cmpd      Done
                    bhi       in1a@
                    ldd       #DashBytes+FaceBytes  the faces' share
in1a@               subd      Done                D = what is left of this part
                    cmpd      #ChunkMax
                    bls       in1b@
                    ldd       #ChunkMax
in1b@               std       Part
                    tfr       d,y
                    lbsr      RdChunk
                    lbcs      in7@
                    ldx       #Dst1               the pristine copy (both parts)
                    lbsr      Move
                    bcs       in7a@
                    ldd       Done
                    cmpd      #DashBytes
                    bhs       in3@                a face: the pristine copy only
                    ldx       #Dst0               the bitmap
                    lbsr      Move
                    bcs       in7a@
                    tst       Bm1
                    beq       in3@
                    ldx       #Dst2               the second dash buffer
                    lbsr      Move
                    bcs       in7a@
in3@                ldd       Done
                    addd      Part
                    std       Done
                    bra       in1@
in4@                ldy       #PalBytes           the palette, then nothing more
                    bsr       RdChunk
                    bcs       in7@
                    ldx       #Buf
                    ldu       #Pal
                    ldb       #PalBytes
in5@                lda       ,x+
                    sta       ,u+
                    decb
                    bne       in5@
                    ldy       #TailProbeLen       a byte past the palette: not a dash file
                    bsr       RdChunk
                    bcc       in7@
                    lda       Path
                    swi2
                    fcb       I$Close
                    bra       in6@
in7a@               inc       InStep              3 a DMA copy that did not finish
in7@                lda       Path
                    swi2
                    fcb       I$Close
                    bra       in8@
in6@                equ       *
* the palette: CLUT 1 entries 1-15; bitmap 2 onto CLUT 1, its other fields as they are
                    lda       #StepClut           4 the CLUT write
                    sta       InStep
                    ldx       #Pal
                    ldy       #DashPalClut
                    ldu       #PalEntries
                    ldb       #SS.ClutWrite
                    bsr       SetStt
                    bcs       in8@
                    inc       InStep              5 the bitmap configure
                    ldx       #BmCfgClut1         enable as it is, CLUT 1
                    ldu       #BmCfgKeep          HIRES4 and group as they are
                    ldy       #BmNumDash
                    ldb       #SS.BmCfg
                    bsr       SetStt
                    bcs       in8@
                    ldy       #BmNum0             bitmap 1, the K2's second buffer, the same
                    ldb       Bm1
                    beq       in9@
                    ldx       #BmCfgClut1
                    ldu       #BmCfgKeep
                    leay      1,y
                    ldb       #SS.BmCfg
                    bsr       SetStt
                    bcs       in8@
in9@                andcc     #^Carry
                    puls      d,x,y,u,pc
in8@                puls      d,x,y,u             carry set, B = the step that refused
                    ldb       InStep
                    orcc      #Carry
                    rts

* BlkAdr: A = a block: D = (block * $2000) >> 8, the top two bytes of its 24-bit address
BlkAdr              ldb       #BlkPages
                    mul
                    rts

* RdChunk: Y bytes of dash.bm into Buf, all of them: carry set on an error or a short read (Y kept for a probe)
RdChunk             pshs      y
                    lda       Path
                    ldx       #Buf
                    swi2
                    fcb       I$Read
                    sty       IoY                 the read's Y, B and CC, for a probe of a failure
                    stb       IoB
                    pshs      cc
                    puls      a
                    sta       IoCC
                    bcs       rc9@
                    cmpy      ,s
                    beq       rc8@
                    orcc      #Carry              short
                    bra       rc9@
rc8@                andcc     #^Carry
rc9@                puls      y,pc

* SetStt: B = the code, X/Y/U its parameters, on FS's display path. Carry from the call.
SetStt              lda       >FsPath
                    swi2
                    fcb       I$SetStt
                    rts

* Move: Part bytes from Src to the 24-bit destination at X (then advanced by Part) by a 1D DMA copy, waited for.
* The engine is shared with FS's own copies: programmed with interrupts off, in one piece. Carry set when the
* engine is still busy after 65,536 polls, before or after the copy (the buffer is reused as soon as Move
* returns, so a copy that is not known to have finished is a failure, never a copy to assume).
Move                pshs      d,x,y,u
                    lbsr      DmaWait             the last copy's end
                    bcs       mv5@
                    orcc      #IntMasks
                    clr       >DMA.Base+DMA_CTRL_REG
                    ldd       Src
                    std       >DMA.Base+DMA_SOURCE_ADDR_H
                    lda       Src+2
                    sta       >DMA.Base+DMA_SOURCE_ADDR_L
                    ldd       ,x
                    std       >DMA.Base+DMA_DEST_ADDR_H
                    lda       2,x
                    sta       >DMA.Base+DMA_DEST_ADDR_L
                    clr       >DMA.Base+DMA_SIZE_1D_H
                    clr       >DMA.Base+DMA_SIZE_Y_H  a live 2D register: cleared
                    ldd       Part
                    sta       >DMA.Base+DMA_SIZE_1D_M
                    stb       >DMA.Base+DMA_SIZE_1D_L
                    clr       >DMA.Base+DMA_OP_REG
                    lda       #DMA_CTRL_Enable    1D
                    lsrb                          an even count (the addresses are even): double speed, two
                    bcs       mv1@                bytes a transfer
                    ora       #DMA_CTRL_Dbl_Speed
mv1@                sta       >DMA.Base+DMA_CTRL_REG
                    ora       #DMA_CTRL_Start_Trf
                    sta       >DMA.Base+DMA_CTRL_REG
                    andcc     #^IntMasks
* the destination on by Part (24-bit)
                    ldd       1,x
                    addd      Part
                    std       1,x
                    bcc       mv2@
                    inc       ,x
mv2@                lbsr      DmaWait             the copy runs in the next vertical blank: wait for it
                    bcc       mv4@
mv5@                orcc      #Carry              still busy: not finished
                    puls      d,x,y,u,pc
mv4@                andcc     #^Carry
                    puls      d,x,y,u,pc

********************************************************************
* Frame: the instruments, every frame. The dial block (the six dials, the tachometer, the engine gauges and the
* levers: dots 52-405, rows 157-236) is restored from the pristine copy's art by one 2D DMA copy started at the
* end of each frame (the engine copies in the next vertical blank; a frame that finds it still running draws
* nothing), then everything in it is drawn afresh through the line engine; the readouts, switches and stall
* light outside it are drawn only when their value changes (caches). Colors are CLUT 1 entries 1-15
* (mkdash.py's palette order).
C_BLACK             equ       1
C_GRAY2             equ       2
C_GRAY3             equ       3
C_GRAY4             equ       4
C_GRAY5             equ       5
C_WHITE             equ       6
C_LED               equ       7
C_LEDDIM            equ       8
C_RED               equ       9
C_GREEN             equ       10
C_LABEL             equ       11
C_SKY               equ       12
C_GROUND            equ       13
C_ORANGE            equ       14
C_DARK              equ       15                  the lip shadow's 45 gray (an unlit lamp)

* Frame: A = bitmap 2's first block, B = its plane bits for the line engine. With two buffers (the K2, Bm1) the
* regions are restored and drawn on the hidden one, which is shown (Flip) once it is all drawn; each buffer has its
* own keys (RgKeys the hidden one's, RgAlt the shown one's), and a region drawn on one is marked to be drawn on
* the other too. The readouts and switches go on both at once (one set of caches).
Frame               pshs      d,x,y,u
                    stb       LnPlane
                    lbsr      AdfFace             the NAV2 spot's face for the ADF switch
                    lbsr      BlkAdr
                    std       BmAdr               the dash bitmap's 24-bit base (block x $2000)
                    clr       BmAdr+2
                    tst       Bm1
                    beq       fk0@
                    tst       FlipPend            the last drawing shown first
                    beq       fd3@                (none: RgSkip keeps counting the frames that missed the window)
                    lbsr      Flip
                    bcs       fd2@
                    lda       RgSkip              not yet: the regions wait, up to RgSkips frames
                    inca
                    sta       RgSkip
                    cmpa      #RgSkips
                    lblo      fr8@
fd1@                lbsr      Flip
                    bcc       fd1@
fd2@                clr       RgSkip
fd3@                tst       Shown               the hidden buffer: bitmap 1 while bitmap 2 shows
                    bne       fk0@
                    lda       Bm1
                    lbsr      BlkAdr
                    std       BmAdr
                    lda       #TyVKY_LD_BM1
                    sta       LnPlane
* Which instruments changed: each region's FS bytes (RgTab) against the copy taken when it was last drawn
fk0@                clr       RgDirty
                    clr       RgDirty+1
                    clr       RgI
fk1@                lbsr      RgEntry             X = the region's entry, U = its key copy
                    ldb       RgN,x
                    leay      RgAdr,x
fk2@                pshs      x
                    ldx       ,y++
                    lda       ,x
                    puls      x
                    cmpa      ,u+
                    beq       fk3@
                    pshs      b,x,y
                    ldb       RgI
                    lbsr      RgMark
                    puls      b,x,y
fk3@                decb
                    bne       fk2@
                    inc       RgI
                    lda       RgI
                    cmpa      #RgCount
                    blo       fk1@
                    ldd       RgDirty
                    beq       fr8@                nothing moved: the dash stays as it is
* The raster: a restore runs in the vertical blank and the drawing must be on the screen before the dial rows
* are scanned, so the update waits for the frame's end (raster line 470 on, or the first lines of the next);
* a frame that finds the raster elsewhere leaves the dash for the next one, up to RgSkips frames in a row
                    lbsr      Raster
                    bcs       fk4@
                    lda       RgSkip
                    inca
                    sta       RgSkip
                    cmpa      #RgSkips
                    blo       fr8@
fk3a@               lbsr      RasW                the window, waited for in the driver
                    bcs       fk3a@               (the wait ran out: again)
fk4@                clr       RgSkip
* the dirty regions' pristine art back, one 2D copy each (the engine takes them one after another in the blank)
                    lbsr      DmaWait             a copy of FS's own still running: let it end
                    bcs       fr9@
                    clr       RgI
fk5@                lbsr      RgDirtyQ
                    beq       fk6@
                    lbsr      RgEntry
                    lbsr      Restore
                    lbsr      DmaWait
                    bcs       fr9@                never finished: nothing over a half-restored region
fk6@                inc       RgI
                    lda       RgI
                    cmpa      #RgCount
                    blo       fk5@
* then the dirty instruments drawn, each over its restored art, and their keys taken
                    clr       RgI
fk7@                lbsr      RgDirtyQ
                    beq       fk7a@
                    lbsr      RgEntry
                    ldb       RgN,x
                    leay      RgAdr,x
fk7b@               pshs      x
                    ldx       ,y++
                    lda       ,x
                    puls      x
                    sta       ,u+
                    decb
                    bne       fk7b@
                    ldx       RgDraw,x
                    jsr       ,x
fk7a@               inc       RgI
                    lda       RgI
                    cmpa      #RgCount
                    blo       fk7
                    tst       Bm1                 two buffers: the other one draws these regions too; shown next
                    beq       fr8@
                    lbsr      RgInv
                    lda       #FlipPendOn
                    sta       FlipPend
* the readouts, the switches and the stall light lie outside the regions: each keeps its own caches (on both
* buffers at once when there are two)
fr8@                lda       Bm1
                    beq       fr8a@
                    lda       #LnBothOn
fr8a@               sta       LnBoth
                    tst       CpDone              the cockpit's windshield post and corner: the first frame only
                    bne       fr8b@
                    inc       CpDone
                    lbsr      Cockpit
fr8b@               lbsr      Readouts
                    lbsr      Switches
                    lbsr      Strip
                    clr       LnBoth
fr9@                lbsr      LnGo                the frame's lines drawn
                    puls      d,x,y,u,pc
fk7                 bra       fk7@

* Flip: the hidden buffer onto layer 0 once it is all drawn (the line engine's FIFO empty; the restores were
* waited for) and the raster is above the art (line 300; the rows above the art are transparent in both), then
* the keys swapped (RgKeys the new hidden buffer's). Carry set: shown.
Flip                pshs      d,x,y,u
                    ldb       #SS.BmLine          the line engine's FIFO count (GetStat SS.BmLine: X)
                    lda       >FsPath
                    swi2
                    fcb       I$GetStt
                    bcs       fl8@
                    tfr       x,d
                    anda      #LdCountHiBits
                    cmpd      #LdFifoEmpty
                    bne       fl8@
                    lbsr      RasY
                    cmpd      #FlipRasMax
                    bhs       fl8@
                    ldy       #BmNumSecond        bitmap 1 while bitmap 2 shows
                    tst       Shown
                    beq       fl1@
                    ldy       #BmNumDash
fl1@                ldx       #DashLayer          layer 0
                    ldb       #SS.PScrn
                    lbsr      SetStt
                    bcs       fl8@
                    lda       Shown
                    eora      #ShownBit
                    sta       Shown
                    clr       FlipPend
                    ldx       #RgKeys
                    ldu       #RgAlt
                    ldb       #RgCount*RgKeyN
fl2@                lda       ,x
                    pshs      a
                    lda       ,u
                    sta       ,x+
                    puls      a
                    sta       ,u+
                    decb
                    bne       fl2@
                    orcc      #Carry
                    puls      d,x,y,u,pc
fl8@                andcc     #^Carry
                    puls      d,x,y,u,pc

* AdfFace: when FS's ADF switch ($0348, FIX MODE page 1) changed: the ADF's face or NAV2's copied over the NAV2
* spot's region in the pristine copy (a 2D DMA copy, waited for), as the CoCo's fa covered its NAV2 dial; the
* region's keys hold $0348, so it is restored and redrawn on both buffers. Registers kept.
AdfFace             pshs      d,x
                    lda       >vAdfEnable
                    beq       af1@
                    lda       #AdfOn
af1@                cmpa      AdfCa
                    lbeq      af9@
                    sta       AdfCa
                    ldx       #AdfFaceOfs         the ADF's face (its offset's bit 16 added below)
                    tsta
                    bne       af2@
                    ldx       #Nav2FaceOfs                  NAV2's
af2@                stx       RsOfs
                    ldd       PrAdr+1             the source: PrAdr + the face's offset (FaceOff's bit 16 set)
                    addd      RsOfs
                    std       RsSrc+1
                    lda       PrAdr
                    adca      #FaceOfsTop
                    sta       RsSrc
                    ldd       PrAdr+1             the destination: PrAdr + the spot's offset
                    addd      #SpotOfs
                    std       RsDst+1
                    lda       PrAdr
                    adca      #SpotOfsTop
                    sta       RsDst
                    lbsr      DmaWait
                    bcs       af8@
                    orcc      #IntMasks
                    clr       >DMA.Base+DMA_CTRL_REG
                    ldd       RsSrc
                    std       >DMA.Base+DMA_SOURCE_ADDR_H
                    lda       RsSrc+2
                    sta       >DMA.Base+DMA_SOURCE_ADDR_L
                    ldd       RsDst
                    std       >DMA.Base+DMA_DEST_ADDR_H
                    lda       RsDst+2
                    sta       >DMA.Base+DMA_DEST_ADDR_L
                    ldd       #FaceW
                    std       >DMA.Base+DMA_SIZE_X_H
                    std       >DMA.Base+DMA_SRC_STRIDE_X_H  the face's rows are FaceW bytes apart
                    ldd       #BmRowBytes
                    std       >DMA.Base+DMA_DST_STRIDE_Y_H
                    ldd       #FaceH
                    std       >DMA.Base+DMA_SIZE_Y_H
                    clr       >DMA.Base+DMA_OP_REG
                    lda       #DMA_CTRL_Enable+DMA_CTRL_1D_2D+DMA_CTRL_Dbl_Speed   all even: two bytes a transfer
                    sta       >DMA.Base+DMA_CTRL_REG
                    ora       #DMA_CTRL_Start_Trf
                    sta       >DMA.Base+DMA_CTRL_REG
                    andcc     #^IntMasks
                    lbsr      DmaWait
                    bcc       af9@
af8@                lda       #CacheStale         not done: tried again next frame
                    sta       AdfCa
af9@                puls      d,x,pc

* RgInv: the other buffer's keys (RgAlt) of the regions drawn this frame made $FF: it draws them too
RgInv               pshs      d,u
                    clr       RgI
ri1@                lbsr      RgDirtyQ
                    beq       ri3@
                    ldb       RgI
                    lda       #RgKeyN
                    mul
                    ldu       #RgAlt
                    leau      d,u
                    lda       #CacheStale
                    ldb       #RgKeyN
ri2@                sta       ,u+
                    decb
                    bne       ri2@
ri3@                inc       RgI
                    lda       RgI
                    cmpa      #RgCount
                    blo       ri1@
                    puls      d,u,pc

* RgEntry: RgI's region: X = its RgTab entry, U = its key copy (RgKeys). Registers kept otherwise.
RgEntry             pshs      d
                    ldb       RgI
                    lda       #RgSize
                    mul
                    ldx       #RgTab
                    leax      d,x
                    ldb       RgI
                    lda       #RgKeyN
                    mul
                    ldu       #RgKeys
                    leau      d,u
                    puls      d,pc
* RgMark: region B dirty. RgDirtyQ: Z clear when region RgI is dirty. Registers kept.
RgMark              pshs      d,x
                    ldx       #RgBits
                    lslb
                    ldd       b,x
                    ora       RgDirty
                    orb       RgDirty+1
                    std       RgDirty
                    puls      d,x,pc
RgDirtyQ            pshs      d,x
                    ldx       #RgBits
                    ldb       RgI
                    lslb
                    ldd       b,x
                    anda      RgDirty
                    andb      RgDirty+1
                    pshs      a
                    orb       ,s+                 Z from both bytes
                    puls      d,x,pc
RgBits              fdb       1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768
* Raster: carry set when the raster line is in the update window. One buffer (the Jr2): the blank, under 40 (the
* picture is lines 45-524; at 470 the dash's bottom rows were still being scanned). Two buffers: 470 on as well
* (the drawing goes on the hidden one; the window only keeps the DMA's wait for the blank short). Registers kept.
Raster              pshs      d
                    bsr       RasY
                    tst       Bm1
                    beq       ra2@
                    cmpd      #RasFrameEnd
                    bhs       ra1@
ra2@                cmpd      #RasBlankEnd
                    bhs       ra0@
ra1@                orcc      #Carry
                    puls      d,pc
ra0@                andcc     #^Carry
                    puls      d,pc
* RasW: Raster's window waited for in the driver: one GpuF.List, its GpuW.Ras wait (the line under 40, with two
* buffers 470 on as well). Carry set: the wait ran out (65,536 polls). Registers kept.
RasW                pshs      d,x,y,u
                    ldd       #RasNever           one buffer: the blank only
                    tst       Bm1
                    beq       rw1@
                    ldd       #RasFrameEnd        two: 470 on as well
rw1@                std       RwIt+GpuL.U
                    ldx       #GpuXList
                    ldy       #RwIt
                    ldu       #RwItN
                    lda       >FsPath             grfdrv256's GPU call: SS.Gpu on FS's display path
                    ldb       #SS.Gpu
                    swi2
                    fcb       I$SetStt
                    puls      d,x,y,u,pc
RwIt                fcb       GpuK.Wait,GpuW.Ras,0
                    fdb       40,0
* RasY (Flip, Raster): D = the raster line, VICKY's VKY_LINE_Y_POS through grfdrv256's GPU call (GpuF.FixN).
* Registers kept but D and CC.
RasY                pshs      x,y,u
                    ldx       #GpuXFixN
                    ldy       #RyRq
                    ldu       #RyBytes
                    lda       >FsPath             grfdrv256's GPU call: SS.Gpu's GetStat on FS's display path
                    ldb       #SS.Gpu
                    swi2
                    fcb       I$GetStt
                    ldd       RyRq+4
                    anda      #RasLineHiBits
                    puls      x,y,u,pc
RyRq                fdb       VKY_LINE_Y_POS_HI   GpuF.FixN's request: the offset, the mask, 0, then the two bytes
                    fcb       1,0
                    rmb       2

* The regions: the rectangle the pristine copy restores (its first byte in a row, its bytes, its first row, its
* rows), the FS bytes whose change redraws it, and the routine that draws it
RgTab               equ       *
                    fdb       Asi
                    fcb       (DAsiCX-36)/2,37,DAsiCY-18,37,1
                    fdb       $0D20,0,0,0,0,0
                    fdb       Alt
                    fcb       (DAltCX-36)/2,37,DAltCY-18,37,2
                    fdb       $003D,$003E,0,0,0,0
                    fdb       Vsi
                    fcb       (DVsiCX-36)/2,37,DVsiCY-18,37,1
                    fdb       $0D21,0,0,0,0,0
                    fdb       Rpm
                    fcb       (DRpmCX-36)/2,37,DRpmCY-18,37,1
                    fdb       $072C,0,0,0,0,0
                    fdb       TurnCoord
                    fcb       (DTrnCX-36)/2,37,DTrnCY-18,37,2
                    fdb       $0800,$0761,0,0,0,0
                    fdb       Rose
                    fcb       (DHdgCX-36)/2,37,DHdgCY-18,37,6
                    fdb       $09AA,$09AB,FswTfBrg,FswTfBrg+1,FswTfDst,FswTfDst+1
                    fdb       Attitude
                    fcb       (DAttCX-36)/2,37,DAttCY-18,37,2
                    fdb       $0012,$0014,0,0,0,0
                    fdb       FuelL
                    fcb       (GFuLX-2)/2,GFuLW/2+2,GFuLY-1,GFuLH+2,2
                    fdb       $0731,$0735,0,0,0,0 the left tank, the tank selector
                    fdb       FuelR
                    fcb       (GFuRX-2)/2,GFuRW/2+2,GFuRY-1,GFuRH+2,2
                    fdb       $0734,$0735,0,0,0,0
                    fdb       OilP
                    fcb       (GOiPX-2)/2,GOiPW/2+2,GOiPY-1,GOiPH+2,1
                    fdb       $073B,0,0,0,0,0
                    fdb       OilT
                    fcb       (GOiTX-2)/2,GOiTW/2+2,GOiTY-1,GOiTH+2,1
                    fdb       $0739,0,0,0,0,0
                    fdb       Levers
                    fcb       (LThrX-2)/2,(LTrmX+10-LThrX+2)/2+1,LThrY0-4,LThrY1-LThrY0+8,2   to y1+3: a knob at the slot's end reaches 3 rows below it
                    fdb       $0837,$081C,0,0,0,0
                    fdb       Nav1
                    fcb       (DNv1CX-36)/2,37,DNv1CY-18,37,3
                    fdb       $09A8,$071E,$0723,0,0,0
                    fdb       Nav2
                    fcb       FaceX,FaceW,FaceY,FaceH,5
                    fdb       $09A9,$0720,$0724,$0348,$09A7,0
                    fdb       Controls
                    fcb       (RudX0-2)/2,(LElvX+10-(RudX0-2))/2+1,LFlpY0-4,RudY1+3-(LFlpY0-4)+1,3
                    fdb       $081E,$081A,$082B,0,0,0
RgDraw              equ       0                   the entry: the draw routine
RgX                 equ       2                   the first byte in a row
RgBytes             equ       3
RgY                 equ       4
RgRows              equ       5
RgN                 equ       6                   how many FS bytes
RgAdr               equ       7                   their addresses
RgSize              equ       19
RgKeyN              equ       6
RgCount             equ       15
RgSkips             equ       4

* DmaWait: the engine's busy flag rises a few clocks after a start and falls when the copy is done (it runs in
* the vertical blank, the CPU halted meanwhile). Waits for the rise (briefly: an idle engine never rises), then
* the fall. Carry set when still busy after 65,536 polls. Registers kept.
DmaWait             pshs      d,y
                    ldb       #DmaRisePolls
dw1@                lda       >DMA.Base+DMA_STATUS_REG
                    bmi       dw2@
                    decb
                    bne       dw1@
dw2@                ldy       #DmaFallPolls
dw3@                lda       >DMA.Base+DMA_STATUS_REG
                    bpl       dw4@
                    leay      -1,y
                    bne       dw3@
                    orcc      #Carry
                    puls      d,y,pc
dw4@                andcc     #^Carry
                    puls      d,y,pc


* Restore: the region at X (RgTab) from the pristine copy to bitmap 2 by a 2D DMA copy at double speed (two bytes
* a transfer: the region taken to whole words), started (Frame waits for it). The offset of its first byte is
* RgY x 320 + (RgX rounded down to even); the source is PrAdr + that, the destination BmAdr + that.
Restore             pshs      d,x,y
                    ldb       RgY,x
                    lda       #BmRowHalf
                    mul                           row x 160
                    lslb
                    rola                          x 2: row x 320, its bit 16 in the carry (rows past 204)
                    std       RsOfs
                    lda       #RolaStart          (clra would clear the carry)
                    rola
                    sta       RsOfsH
                    ldb       RgX,x               its first word (double speed: an even byte)
                    andb      #EvenMask
                    clra
                    addd      RsOfs
                    std       RsOfs
                    bcc       rs1@
                    inc       RsOfsH
rs1@                ldd       PrAdr+1
                    addd      RsOfs
                    std       RsSrc+1
                    lda       PrAdr
                    adca      RsOfsH
                    sta       RsSrc
                    ldd       BmAdr+1
                    addd      RsOfs
                    std       RsDst+1
                    lda       BmAdr
                    adca      RsOfsH
                    sta       RsDst
                    orcc      #IntMasks
                    clr       >DMA.Base+DMA_CTRL_REG
                    ldd       RsSrc
                    std       >DMA.Base+DMA_SOURCE_ADDR_H
                    lda       RsSrc+2
                    sta       >DMA.Base+DMA_SOURCE_ADDR_L
                    ldd       RsDst
                    std       >DMA.Base+DMA_DEST_ADDR_H
                    lda       RsDst+2
                    sta       >DMA.Base+DMA_DEST_ADDR_L
                    lda       RgX,x               its bytes to whole words: an odd first byte or end takes the
                    anda      #OddBit             byte beside it too (clean art, inside no other region)
                    adda      RgBytes,x
                    inca
                    anda      #EvenMask
                    tfr       a,b
                    clra
                    std       >DMA.Base+DMA_SIZE_X_H
                    ldd       #BmRowBytes
                    std       >DMA.Base+DMA_SRC_STRIDE_X_H
                    std       >DMA.Base+DMA_DST_STRIDE_Y_H
                    ldb       RgRows,x
                    clra
                    std       >DMA.Base+DMA_SIZE_Y_H
                    clr       >DMA.Base+DMA_OP_REG
                    lda       #DMA_CTRL_Enable+DMA_CTRL_1D_2D+DMA_CTRL_Dbl_Speed
                    sta       >DMA.Base+DMA_CTRL_REG
                    ora       #DMA_CTRL_Start_Trf
                    sta       >DMA.Base+DMA_CTRL_REG
                    andcc     #^IntMasks
                    puls      d,x,y,pc

********************************************************************
* The line engine
* Ln: the line LnX0,LnY0 - LnX1,LnY1 in color LnC on the frame's bitmap (LnPlane); with LnBoth (the K2's two
* dash buffers) on the other one too (plane bits 8 / 4: bitmap 2 / 1). A record into that bitmap's queue (LnQ2,
* LnQ1: Buf, free once Init has read the art), drawn by LnGo1 when the queue is full and by LnGo at the frame's
* end. Registers kept.
Ln                  pshs      d,x,y
                    lda       LnPlane
ln0@                sta       LnP
                    ldx       #LnQ2D              the bitmap's queue: 2 (plane bits 8) or 1 (4)
                    cmpa      #TyVKY_LD_BM2
                    beq       ln1@
                    ldx       #LnQ1D
ln1@                ldy       ,x                  its next record's place
                    cmpy      2,x
                    blo       ln2@
                    bsr       LnGo1               full: drawn first
                    ldy       ,x
ln2@                ldd       LnX0
                    std       ,y
                    ldd       LnX1
                    std       2,y
                    lda       LnY0
                    ldb       LnY1
                    std       4,y
                    lda       LnC                 the color, byte 7 0
                    clrb
                    std       6,y
                    leay      8,y
                    sty       ,x
                    lda       LnP
                    tst       LnBoth
                    beq       ln9@
                    cmpa      LnPlane
                    bne       ln9@                the other one done
                    eora      #TyVKY_LD_BM_MASK
                    bra       ln0@
ln9@                puls      d,x,y,pc
* LnGo: both queues drawn (Frame's end: Flip, at the next frame's start, waits for their last pixels). LnGo1: X =
* a queue (LnQ2D, LnQ1D): its records to the line engine on its bitmap in SS.BmLine batches, as fsw's Feed (a
* batch the FIFO ran short of goes on from the record it stopped at, a record it refused, E$IllArg or E$DevBsy,
* is passed, any other error ends it); the queue emptied. Registers kept but CC.
LnGo                pshs      x
                    ldx       #LnQ2D
                    bsr       LnGo1
                    ldx       #LnQ1D
                    bsr       LnGo1
                    puls      x,pc
LnGo1               pshs      d,x,y,u             2,s = the queue
                    ldu       4,x                 the first record
lg1@                ldx       2,s
                    ldd       ,x                  the records from U to the next one's place
                    pshs      u
                    subd      ,s++
                    beq       lg9@
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    ldy       6,x                 the bitmap
                    pshs      u                   ,s = the records
                    tfr       d,u                 their count
                    ldx       ,s
                    lda       >FsPath
                    ldb       #SS.BmLine
                    swi2
                    fcb       I$SetStt            U = the records drawn
                    puls      x
                    bcc       lg2@
                    cmpb      #E$IllArg
                    beq       lg3@
                    cmpb      #E$DevBsy
                    bne       lg9@
lg3@                leau      1,u                 past the one refused
lg2@                tfr       u,d
                    lda       #LnRecSize
                    mul
                    leau      d,x
                    bra       lg1@
lg9@                ldx       2,s
                    ldd       4,x
                    std       ,x
                    puls      d,x,y,u,pc
LnQN                equ       ChunkMax/16         records a queue holds (two queues in Buf)
LnQ2                equ       Buf
LnQ1                equ       Buf+LnQN*8
LnQ2D               fdb       LnQ2,LnQ2+LnQN*8,LnQ2,2 bitmap 2's queue: the next record's place, the end, the first, the bitmap
LnQ1D               fdb       LnQ1,LnQ1+LnQN*8,LnQ1,1 bitmap 1's

* HLn: the row A from X to Y (dots) in LnC. VLn: the dot X from row A to row B. Registers kept.
HLn                 pshs      d,x,y
                    stx       LnX0
                    sty       LnX1
                    sta       LnY0
                    sta       LnY1
                    lbsr      Ln
                    puls      d,x,y,pc
VLn                 pshs      d,x,y
                    stx       LnX0
                    stx       LnX1
                    sta       LnY0
                    stb       LnY1
                    lbsr      Ln
                    puls      d,x,y,pc
* Box: the rows A to B, dots X to Y, filled in LnC
Box                 pshs      d,x,y
bx1@                bsr       HLn
                    inca
                    cmpa      1,s
                    bls       bx1@
                    puls      d,x,y,pc

********************************************************************
* The dials
* SMul7: A = a signed cos/sin (1/128), B = a radius: D = their product >> 7, signed
SMul7               pshs      a
                    tsta
                    bpl       sm1@
                    nega
sm1@                mul
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
                    lsra
                    rorb
                    lsra
                    rorb
                    tst       ,s+
                    bpl       sm2@
                    nega
                    negb
                    sbca      #NegBorrow
sm2@                rts

* Tip: the point at dial position A (0 = 3 o'clock, anticlockwise; taken modulo 88 as FS's own needle code does:
* FS keeps the airspeed needle's position unwrapped, 26-110, and the values 88-110 read past DialCS) on the
* ellipse NdCX,NdCY radii NdRX,NdRY: TipX (16-bit), TipY. Registers kept.
Tip                 pshs      d,x
tp0@                cmpa      #DialPosCount
                    blo       tp1@
                    suba      #DialPosCount
                    bra       tp0@
tp1@                ldb       #DialCSSize
                    mul
                    ldx       #DialCS
                    abx
                    lda       ,x                  cos
                    ldb       NdRX
                    bsr       SMul7
                    addd      NdCX
                    std       TipX
                    lda       1,x                 sin (up)
                    ldb       NdRY
                    bsr       SMul7
                    nega
                    negb
                    sbca      #NegBorrow
                    addb      NdCY
                    stb       TipY
                    puls      d,x,pc

* Needle: a tapered needle from the center to dial position A, color LnC: three lines from a three-dot base.
* The tail behind the center: 4 dots, 2 rows (the mockup's).
Needle              pshs      d,x
                    bsr       Tip
                    ldd       TipX
                    std       LnX1
                    lda       TipY
                    sta       LnY1
                    lda       NdCY
                    sta       LnY0
                    ldd       NdCX
                    subd      #NdBaseStep
                    std       LnX0
                    lbsr      Ln
                    addd      #NdBaseStep
                    std       LnX0
                    lbsr      Ln
                    addd      #NdBaseStep
                    std       LnX0
                    lbsr      Ln
                    ldd       NdRX                the tail: the opposite position on radii 4, 2
                    pshs      d
                    ldd       #NdTailRadii
                    std       NdRX
                    lda       2,s
                    adda      #DialPosHalf
                    bsr       Tip
                    ldd       TipX
                    std       LnX1
                    lda       TipY
                    sta       LnY1
                    ldd       NdCX
                    std       LnX0
                    lbsr      Ln
                    puls      d
                    std       NdRX
                    puls      d,x,pc

* Hub: the boss at the center, an ellipse 7 dots x 5 rows, gray with a darker rim (the mockup's)
Hub                 pshs      d,x,u
                    lda       #C_GRAY3
                    sta       KnO
                    lda       #C_GRAY4
                    sta       KnF
                    ldx       NdCX
                    lda       NdCY
                    suba      #HubTopUp
                    ldu       #KnHub
                    lbsr      Knob
                    puls      d,x,u,pc

* Knob: an outlined shape row by row: X = its reference dot, A = its top row, U = the shape (its rows, then per
* row the outline's first and last dot and the fill's, signed off X; a fill first of $7F: none), the outline in
* KnO, the fill in KnF. Registers kept.
Knob                pshs      d,x,y,u
                    stx       KnX
                    sta       KnR
                    ldb       ,u+
                    stb       KnN
kn1@                lda       KnO
                    sta       LnC
                    ldb       ,u
                    sex
                    addd      KnX
                    tfr       d,x
                    ldb       1,u
                    sex
                    addd      KnX
                    tfr       d,y
                    lda       KnR
                    lbsr      HLn
                    ldb       2,u
                    cmpb      #KnNoFill
                    beq       kn2@
                    lda       KnF
                    sta       LnC
                    sex
                    addd      KnX
                    tfr       d,x
                    ldb       3,u
                    sex
                    addd      KnX
                    tfr       d,y
                    lda       KnR
                    lbsr      HLn
kn2@                leau      4,u
                    inc       KnR
                    dec       KnN
                    bne       kn1@
                    puls      d,x,y,u,pc
* the shapes (PIL's ellipses in dash_mockup_real.py): the hub, 7 x 5 about the center; a lever's knob, 10 x 7 from
* the slot's x - 1; the rudder's, 9 x 7 about its center
KnHub               fcb       5,-1,1,$7F,0,-3,3,-1,1,-3,3,-2,2,-3,3,-1,1,-1,1,$7F,0
KnLev               fcb       7,2,5,$7F,0,0,7,2,5,-1,8,0,7,-1,8,0,7,-1,8,0,7,0,7,2,5,2,5,$7F,0
KnRud               fcb       7,-2,2,$7F,0,-3,3,-2,2,-4,4,-3,3,-4,4,-3,3,-4,4,-3,3,-3,3,-2,2,-2,2,$7F,0

* SetDial: X = a dial's layout (cx, cy, rx, ry bytes: DlAsi..): NdCX..NdRY
SetDial             pshs      d
                    ldd       ,x
                    std       NdCX
                    lda       2,x
                    sta       NdCY
                    ldd       3,x
                    std       NdRX
                    puls      d,pc

* The dials' centers and radii (fsp_layout.d), cx 16-bit, cy, rx, ry
DlAsi               fdb       DAsiCX
                    fcb       DAsiCY,DAsiRX,DAsiRY
DlAlt               fdb       DAltCX
                    fcb       DAltCY,DAltRX,DAltRY
DlVsi               fdb       DVsiCX
                    fcb       DVsiCY,DVsiRX,DVsiRY
DlRpm               fdb       DRpmCX
                    fcb       DRpmCY,DRpmRX,DRpmRY
DlTrn               fdb       DTrnCX
                    fcb       DTrnCY,DTrnRX,DTrnRY
DlHdg               fdb       DHdgCX
                    fcb       DHdgCY,DHdgRX,DHdgRY
DlAtt               fdb       DAttCX
                    fcb       DAttCY,DAttRX,DAttRY
DlNv1               fdb       DNv1CX
                    fcb       DNv1CY,DNv1RX,DNv1RY
DlNv2               fdb       DNv2CX
                    fcb       DNv2CY,DNv2RX,DNv2RY

* Asi: airspeed, FS's needle $0D20
Asi                 pshs      d,x,y,u
                    ldx       #DlAsi
                    lbsr      SetDial
                    lda       #C_WHITE
                    sta       LnC
                    lda       >vAsiNeedle
                    lbsr      Needle
                    lbsr      Hub
                    puls      d,x,y,u,pc
* Alt: the altimeter, the small hand <$3D (short), the big hand <$3E
Alt                 pshs      d,x,y,u
                    ldx       #DlAlt
                    lbsr      SetDial
                    lda       #C_WHITE
                    sta       LnC
                    lda       NdRX
                    suba      #AltSmRXCut
                    sta       NdRX
                    lda       NdRY
                    suba      #AltSmRYCut
                    sta       NdRY
                    lda       >vAltSmallHand
                    lbsr      Needle
                    ldx       #DlAlt
                    lbsr      SetDial
                    lda       >vAltBigHand
                    lbsr      Needle
                    lbsr      Hub
                    puls      d,x,y,u,pc
* Vsi: vertical speed, FS's needle $0D21
Vsi                 pshs      d,x,y,u
                    ldx       #DlVsi
                    lbsr      SetDial
                    lda       #C_WHITE
                    sta       LnC
                    lda       >vVsiNeedle
                    lbsr      Needle
                    lbsr      Hub
                    puls      d,x,y,u,pc
* Rpm: the tachometer, $072C in 50-rpm units through RpmPos
Rpm                 pshs      d,x,y,u
                    ldx       #DlRpm
                    lbsr      SetDial
                    lda       #C_WHITE
                    sta       LnC
                    lda       >vRpm
                    cmpa      #RpmPosLast
                    bls       dl1@
                    lda       #RpmPosLast
dl1@                ldx       #RpmPos
                    lda       a,x
                    lbsr      Needle
                    lbsr      Hub
                    puls      d,x,y,u,pc

* TurnCoord: the airplane symbol banked by FS's index $0800 (0-15, 8 level): a wing line through the center at
* dial position (8 - index), its tip the wing's end; the fin; then the slip ball from $0761.
TurnCoord           pshs      d,x,y
                    ldx       #DlTrn
                    lbsr      SetDial
                    lda       #TcWingRX
                    sta       NdRX
                    lda       #TcWingRY
                    sta       NdRY
                    lda       #TcLevel
                    suba      >vTurnIndex
                    bpl       tc1@
                    adda      #DialPosCount
tc1@                sta       TcPos
                    lbsr      Tip                 the right wing tip
                    ldd       TipX
                    std       LnX1
                    lda       TipY
                    sta       LnY1
                    lda       TcPos
                    adda      #DialPosHalf        the left wing tip, opposite
                    cmpa      #DialPosCount
                    blo       tc2@
                    suba      #DialPosCount
tc2@                lbsr      Tip
                    ldd       TipX
                    std       LnX0
                    lda       TipY
                    sta       LnY0
                    lda       #C_WHITE
                    sta       LnC
                    lbsr      Ln
                    inc       LnY0                the wing two rows thick
                    inc       LnY1
                    lbsr      Ln
* the fin: a short vertical at the center
                    ldx       NdCX
                    lda       NdCY
                    suba      #TcFinUp
                    ldb       NdCY
                    addb      #TcFinDown
                    lbsr      VLn
                    leax      1,x
                    lbsr      VLn
* the slip ball: $0761 high byte -> position 1..17 (9 centered), two dots each from the center, 3 rows
                    lda       >vSlip
                    adda      #SlipBias
                    lsra
                    lsra
                    suba      #SlipBiasDiv4
                    cmpa      #SlipMax
                    ble       tc3@
                    lda       #SlipMax
tc3@                cmpa      #SlipMin
                    bge       tc4@
                    lda       #SlipMin
tc4@                asla
                    ldb       NdCX+1
                    ldx       NdCX
                    leax      a,x                 X = the ball's center dot
                    lda       NdCY
                    adda      #SlipBallRow
                    sta       TcY
                    leax      -2,x
                    leay      4,x
                    lda       #C_WHITE
                    sta       LnC
                    lda       TcY
                    lbsr      HLn
                    inca
                    lbsr      HLn
                    inca
                    lbsr      HLn
                    puls      d,x,y,pc

* Rose: the heading rose, FS's degrees $09AA (Card: its ticks and letters), then the lubber line over it and the
* actor's needle
Rose                pshs      d,x,y,u
                    ldx       #DlHdg
                    ldd       >vHdgDeg
                    std       CdRef
                    lda       #RoseTickLen        the ticks 5 and 3 long
                    sta       CdTk
                    lda       #RoseLetInX         the letters at rx - 9, ry - 6 (the mockup's)
                    ldb       #RoseLetInY
                    lbsr      Card
                    lbra      RoseTop
* Card: X = a dial's layout (DlHdg ..), CdRef = the card's heading (degrees 0-359), CdTk = a major tick's length,
* A / B = the letters' inset from the rim (dots, rows): a tick every 10 degrees (major every 30, CdTk long, else
* CdTk - 2), N E S W in the 3 x 5 font. A card angle C sits at dial position (22 - (C - ref) x 88 / 360) mod 88
* (DegPos).
Card                pshs      d,x,y,u
                    stx       CdDl
                    std       CdIn
                    lda       #C_WHITE
                    sta       LnC
                    clr       RoI
                    clr       RoM                 0 = a major tick (every 30 degrees)
ro1@                lda       RoI
                    ldb       #CardTickDeg
                    mul                           D = i x 10
                    subd      CdRef
                    bpl       ro2@
                    addd      #DegTurn
ro2@                lbsr      DegPos
                    sta       RoP
                    ldx       CdDl
                    lbsr      SetDial
                    lda       RoP
                    lbsr      Tip                 the outer end
                    ldd       TipX
                    std       LnX0
                    lda       TipY
                    sta       LnY0
                    ldb       CdTk                the tick's length
                    tst       RoM
                    beq       ro3@
                    subb      #MinorTickCut
ro3@                stb       RoL
                    lda       NdRX
                    suba      RoL
                    sta       NdRX
                    lda       NdRY
                    suba      RoL
                    sta       NdRY
                    lda       RoP
                    lbsr      Tip                 the inner end
                    ldd       TipX
                    std       LnX1
                    lda       TipY
                    sta       LnY1
                    lbsr      Ln
                    inc       RoM
                    lda       RoM
                    cmpa      #CardMajorEvery
                    blo       ro3a@
                    clr       RoM
ro3a@               inc       RoI
                    lda       RoI
                    cmpa      #CardTicks
                    blo       ro1@
* the letters: N at 0, E at 90, S at 180, W at 270, centered at the inset radii
                    ldu       #RoLet
ro4@                ldd       ,u
                    subd      CdRef
                    bpl       ro5@
                    addd      #DegTurn
ro5@                lbsr      DegPos
                    ldx       CdDl
                    lbsr      SetDial
                    ldb       NdRX
                    subb      CdIn
                    stb       NdRX
                    ldb       NdRY
                    subb      CdIn+1
                    stb       NdRY
                    lbsr      Tip
                    ldd       TipX                the glyph's top left: 1 dot left, 2 rows up
                    subd      #Gl35CtrX
                    std       GlX
                    lda       TipY
                    suba      #Gl35CtrY
                    sta       GlY
                    ldx       2,u
                    lbsr      Gl35
                    leau      4,u
                    cmpu      #RoLetEnd
                    blo       ro4@
                    puls      d,x,y,u,pc
* RoseTop: over the card, the aircraft (its art, which the card's letters cross: a bar 2 dots wide from cy - 9 to
* cy + 6, the wings 2 rows from cx - 7 to cx + 7 on cy - 1) and the lubber line at the top of the rim (rows
* cy - ry - 1 .. + 4, 2 dots), orange
RoseTop             ldx       #DlHdg
                    lbsr      SetDial
                    lda       #C_ORANGE
                    sta       LnC
                    ldx       NdCX
                    lda       NdCY
                    suba      #RoseBarUp
                    ldb       NdCY
                    addb      #RoseBarDown
                    lbsr      VLn
                    leax      1,x
                    lbsr      VLn
                    ldd       NdCX
                    subd      #RoseWingHalf
                    tfr       d,x
                    addd      #RoseWingSpan
                    tfr       d,y
                    lda       NdCY
                    deca
                    lbsr      HLn
                    inca
                    lbsr      HLn
                    ldx       NdCX
                    lda       NdCY
                    suba      NdRY
                    deca
                    tfr       a,b
                    addb      #LubberRows
                    lbsr      VLn
                    leax      1,x
                    lbsr      VLn
* the actor's needle: its bearing from the nose, clockwise from the top (the rose turns with the heading, so a
* relative bearing is a fixed angle from the top), orange, shorter than the rim; none without an actor
                    ldd       >FswTfDst
                    cmpd      #TfNone
                    beq       ro9@
                    ldd       >FswTfBrg
                    lbsr      DegPos
                    ldx       #DlHdg
                    lbsr      SetDial
                    ldb       NdRX
                    subb      #ActNdRXCut
                    stb       NdRX
                    ldb       NdRY
                    subb      #ActNdRYCut
                    stb       NdRY
                    lbsr      Needle
ro9@                puls      d,x,y,u,pc

* DegPos: D = degrees 0-359 relative to the heading: A = the dial position (22 - D x 125 >> 9) mod 88. The
* product's high byte >> 1 is the shift (the low byte cannot carry into it).
DegPos              pshs      x
                    bsr       Mul125
                    lsra
                    pshs      a
                    lda       #DialPosTop
                    suba      ,s+
                    bpl       dp1@
                    adda      #DialPosCount
dp1@                puls      x,pc

* Mul125: D (0-511) x 125 in D
Mul125              pshs      x
                    pshs      a                   D's high byte
                    lda       #DegPosMul
                    mul                           the low byte's product
                    tfr       d,x
                    puls      a
                    ldb       #DegPosMul
                    mul                           the high byte's, its low byte shifted up
                    pshs      b
                    tfr       x,d
                    adda      ,s+
                    puls      x,pc

* Gl35: X = a 3 x 5 glyph (five rows, bits 2-0 the columns left to right), its top left at GlX, GlY, in LnC
* (the mockup's 3 x 5 font, dash_mockup_real.py FONT35). Registers kept.
Gl35                pshs      d,x,y
                    lda       GlY
                    sta       GlR
                    ldb       #Gl35Rows
                    stb       GlN
gl1@                lda       ,x+                 the row's bits
                    pshs      x
                    ldx       GlX
                    ldb       #Gl35Cols
gl2@                bita      #Gl35ColBit
                    beq       gl3@
                    pshs      a
                    lda       GlR
                    tfr       x,y
                    lbsr      HLn                 the dot
                    puls      a
gl3@                lsla
                    leax      1,x
                    decb
                    bne       gl2@
                    puls      x
                    inc       GlR
                    dec       GlN
                    bne       gl1@
                    puls      d,x,y,pc

RoLet               fdb       0,G35N
                    fdb       90,G35E
                    fdb       180,G35S
                    fdb       270,G35W
RoLetEnd            equ       *
G35N                fcb       6,5,5,5,5
G35E                fcb       7,4,6,4,7
G35S                fcb       3,4,2,1,6
G35W                fcb       5,5,7,7,5
G35T                fcb       7,2,2,2,2
G35O                fcb       2,5,5,5,2
G35F                fcb       7,4,6,4,4
G35R                fcb       6,5,6,5,5

* Nav1, Nav2: the VOR indicators: the card turned to the OBS ($09A8 / $09A9, two-degree units; Card), the
* deviation needle (FS's CDI $071E / $0720, 0-30, 15 centered: 4 dots of 5 pixels a side, the needle 2 dots
* wide, 19 rows), TO or FR in the flag window ($0723 / $0724: 1 TO, 2 FR, 0 off: blank). With the ADF on
* ($0348) the NAV2 spot is the ADF's face (AdfFace) and only its needle is drawn, FS's position $09A7, orange.
Nav1                pshs      d,x,y,u
                    lda       #NavTickLen         the ticks 4 and 2 long
                    sta       CdTk
                    ldx       #DlNv1
                    lda       >vNav1Obs
                    ldb       >vNav1CdiGoal
                    pshs      b
                    ldb       >vNav1Flag
                    bra       NavDial
Nav2                pshs      d,x,y,u
                    lda       #NavTickLen
                    sta       CdTk
                    ldx       #DlNv2
                    tst       >vAdfEnable
                    bne       nv8@
                    lda       >vNav2Obs
                    ldb       >vNav2CdiGoal
                    pshs      b
                    ldb       >vNav2Flag
                    bra       NavDial
nv8@                lbsr      SetDial             the ADF: its needle
                    lda       #C_ORANGE
                    sta       LnC
                    lda       NdRX
                    suba      #AdfNdRXCut
                    sta       NdRX
                    lda       NdRY
                    suba      #AdfNdRYCut
                    sta       NdRY
                    lda       >vAdfNeedle
                    lbsr      Needle
                    lbsr      Hub
                    puls      d,x,y,u,pc
* NavDial: X = the dial, A = the OBS, B = the flag, the CDI on the stack (Nav1 / Nav2's)
NavDial             stb       NvFl
                    ldb       #ObsDegUnit         the OBS in degrees
                    mul
                    std       CdRef
                    lda       #NavLetInX          the letters at rx - 8, ry - 6 (the mockup's)
                    ldb       #NavLetInY
                    lbsr      Card
                    lbsr      SetDial
                    lda       #C_WHITE
                    sta       LnC
                    puls      b                   the CDI: (pos - 15) x 21 / 16 dots off the center
                    subb      #CdiCenter
                    pshs      b
                    bpl       nv2@
                    negb
nv2@                lda       #CdiScale
                    mul
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    tst       ,s+
                    bpl       nv3@
                    negb
nv3@                sex
                    addd      NdCX
                    tfr       d,x
                    lda       NdCY
                    suba      #CdiHalfRows
                    ldb       NdCY
                    addb      #CdiHalfRows
                    lbsr      VLn
                    leax      1,x
                    lbsr      VLn
                    ldx       #G35T               the flag: TO / FR
                    ldu       #G35O
                    lda       NvFl
                    cmpa      #NvFlTo
                    beq       nv4@
                    cmpa      #NvFlFr
                    bne       nv9@
                    ldx       #G35F
                    ldu       #G35R
nv4@                ldd       NdCX
                    addd      #NvFlX
                    std       GlX
                    lda       NdCY
                    suba      #NvFlUp
                    sta       GlY
                    lbsr      Gl35
                    ldd       GlX
                    addd      #Gl35Pitch
                    std       GlX
                    tfr       u,x
                    lbsr      Gl35
nv9@                puls      d,x,y,u,pc

* Attitude: the ball from <$12 (pitch, high byte, 256 a turn) and <$14 (bank): the sky and the ground split on
* the horizon through (cx, cy + pitch / 2) tilted by the bank, a span or two a row across the face's width
* (BallHW), then the orange aircraft symbol. Signs: nose up moves the horizon down; bank right raises the horizon's
* right end (to be checked on the hardware).
Attitude            pshs      d,x,y,u
                    ldx       #DlAtt
                    lbsr      SetDial
                    lda       >vPitch             pitch: FS keeps it positive for the nose down (the hardware's
                    nega                          view, 2026-10-17), so the ball takes the negative as nose up
                    asra
                    cmpa      #AtPoMax
                    ble       at1@
                    lda       #AtPoMax
at1@                cmpa      #AtPoMin
                    bge       at2@
                    lda       #AtPoMin
at2@                sta       AtPo
                    lda       >vBank              bank: FS keeps it positive for a left bank (the hardware's view,
                    nega                          2026-10-17), so the ball takes the negative as its bank right
                    sta       AtBk
                    bpl       at3@
                    nega
at3@                cmpa      #AtBankMax
                    bls       at4@
                    lda       #AtBankMax
at4@                sta       AtAb                |bank|
                    clr       AtCot
                    cmpa      #CotTFirst
                    blo       at5@
                    suba      #CotTFirst
                    ldx       #CotT
                    lda       a,x
                    sta       AtCot
at5@                lda       #BallTop
                    sta       AtDy
at6@                lda       AtDy                the row
                    bpl       at7@
                    nega
at7@                ldx       #BallHW
                    ldb       a,x                 the half width
                    stb       AtHw
                    lda       NdCY
                    adda      AtDy
                    sta       AtY
                    ldd       NdCX
                    subb      AtHw
                    sbca      #ZeroExtHi
                    std       AtXl
                    ldd       NdCX
                    addb      AtHw
                    adca      #ZeroExtHi
                    std       AtXr
                    lda       AtDy
                    suba      AtPo
                    sta       AtD                 d = the row's offset from the horizon's center
                    tst       AtCot
                    bne       at8@
* level: sky above the horizon, ground from it down
                    ldb       #C_SKY
                    tsta
                    bmi       at7a@
                    ldb       #C_GROUND
at7a@               stb       LnC
                    ldx       AtXl
                    ldy       AtXr
                    lda       AtY
                    lbsr      HLn
                    lbra      at20@
* banked: the crossing xc = cx -/+ (d x cot16) >> 4; left of it sky when the bank is right
at8@                lda       AtD
                    bpl       at9@
                    nega
at9@                ldb       AtCot
                    mul
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb                          D = |d x cot| >> 4
                    tst       AtD
                    bpl       at10@
                    nega
                    negb
                    sbca      #NegBorrow          D = d x cot >> 4, signed
at10@               tst       AtBk
                    bpl       at11@
                    nega
                    negb
                    sbca      #NegBorrow          bank left: the other way
at11@               pshs      d
                    ldd       NdCX
                    subd      ,s++
                    std       AtXc                xc = cx - (signed)
                    ldb       #C_SKY
                    lda       #C_GROUND
                    tst       AtBk
                    bpl       at12@
                    exg       a,b
at12@               stb       AtCl                the left part's color
                    sta       AtCr
                    ldd       AtXc
                    cmpd      AtXl
                    bgt       at13@
                    lda       AtCr                all the right color
                    sta       LnC
                    ldx       AtXl
                    ldy       AtXr
                    lda       AtY
                    lbsr      HLn
                    bra       at20@
at13@               cmpd      AtXr
                    blt       at14@
                    lda       AtCl                all the left color
                    sta       LnC
                    ldx       AtXl
                    ldy       AtXr
                    lda       AtY
                    lbsr      HLn
                    bra       at20@
at14@               lda       AtCl
                    sta       LnC
                    ldx       AtXl
                    ldy       AtXc
                    leay      -1,y
                    lda       AtY
                    lbsr      HLn
                    lda       AtCr
                    sta       LnC
                    ldx       AtXc
                    ldy       AtXr
                    lda       AtY
                    lbsr      HLn
at20@               inc       AtDy
                    lda       AtDy
                    cmpa      #BallBottom
                    lble      at6@
* the horizon line and the pitch marks, white: one picture painted on the ball and rolled with it. On the screen
* (a dot one pixel wide, a row two high) the horizon through (cx, cy + pitch) runs along h = (cos b, -s sin b),
* s = +1 when the ball banks right (AtBk >= 0), and the marks sit on the perpendicular u = (s sin b, cos b),
* positive toward the ground, 8 pixels apart: mark k (-3..3, 0 the horizon's own line across the ball) is
* centered k x 8 pixels along u and runs +-w pixels along h, w = 12 at 10 degrees, 6 at 5 and 15, shortened to
* what lies inside the ball. SinT / CosT (fsp_layout.d) are Q7 for the bank's size, the sine with its sign.
                    lda       #C_WHITE
                    sta       LnC
                    ldb       AtAb
                    ldx       #CosT
                    lda       b,x
                    sta       LdCos
                    ldx       #SinT
                    lda       b,x
                    tst       AtBk
                    bpl       ld0@
                    nega
ld0@                sta       LdSin               s sin b
                    lda       #MarkFirst
                    sta       LdK
ld1@                lda       LdK
                    asla
                    asla
                    asla
                    sta       LdK8                k x 8 pixels along u
                    tfr       a,b
                    lda       LdSin
                    lbsr      LdMul               the center: k 8 s sin b dots off cx
                    stb       LdX
                    ldb       LdK8
                    lda       LdCos
                    lbsr      LdMul               k 8 cos b pixels down: half as many rows, off the horizon's center
                    asra
                    rorb
                    addb      AtPo
                    stb       LdY
                    ldb       #HorizonHW          the horizon: the ball's width
                    lda       LdK
                    beq       ld3@
                    ldb       #MarkOddHW
                    anda      #OddBit
                    bne       ld3@
                    ldb       #MarkEvenHW
ld3@                stb       LdW
                    lbsr      LdLine
                    inc       LdK
                    lda       LdK
                    cmpa      #MarkEnd
                    blt       ld1@
                    lbra      at21@
* LdLine: the mark centered (LdX dots, LdY rows) off the ball's center, half width LdW pixels along the horizon,
* shortened a pixel at a time until both ends lie inside the ball (none below 2)
LdLine              pshs      d,x,y
ll1@                lda       LdW
                    cmpa      #MarkMinHW
                    blo       ll9@
                    tfr       a,b
                    lda       LdCos
                    lbsr      LdMul               w cos b dots along the horizon
                    stb       LdEx
                    ldb       LdW
                    lda       LdSin
                    lbsr      LdMul               s w sin b pixels: half as many rows, and the right end rises
                    asra
                    rorb
                    negb
                    stb       LdEy
                    lda       LdY
                    adda      LdEy                the right end
                    ldb       LdX
                    addb      LdEx
                    bsr       LdIn
                    bcc       ll8@
                    sta       LdYa
                    stb       LdXa
                    lda       LdY
                    suba      LdEy                the left end
                    ldb       LdX
                    subb      LdEx
                    bsr       LdIn
                    bcc       ll8@
                    adda      NdCY
                    sta       LnY0
                    sex
                    addd      NdCX
                    std       LnX0
                    lda       LdYa
                    adda      NdCY
                    sta       LnY1
                    ldb       LdXa
                    sex
                    addd      NdCX
                    std       LnX1
                    lbsr      Ln
ll9@                puls      d,x,y,pc
ll8@                dec       LdW                 an end outside: shorter
                    bra       ll1@
* LdIn: A = a row off the ball's center, B = a dot off it, both signed: carry set when that dot lies inside the
* ball (|A| < 16 and |B| under the face's half width on that row). A and B kept.
LdIn                pshs      a,b,x
                    tsta
                    bpl       li1@
                    nega
li1@                cmpa      #BallHalfH
                    bhs       li8@
                    ldx       #BallHW
                    lda       a,x
                    deca
                    tstb
                    bpl       li2@
                    negb
li2@                pshs      b
                    cmpa      ,s+
                    blo       li8@
                    orcc      #Carry
                    puls      a,b,x,pc
li8@                andcc     #^Carry
                    puls      a,b,x,pc
* LdMul: A = a Q7 sine or cosine (signed), B = a signed byte: D = A x B >> 7, signed (the product is under 128
* in size here: SMul7's low byte is right for either sign of A, and sex gives the high byte)
LdMul               tstb
                    bpl       lm1@
                    negb
                    lbsr      SMul7
                    negb
                    sex
                    rts
lm1@                lbsr      SMul7
                    sex
                    rts
at21@
* the bank pointer: a solid orange wedge on the ball's rim at its top, rolled with the bank: its tip 32 pixels up
* the ball's own up, -u = (-s sin b, -cos b), on the ball's edge row, tip to tip with the bezel's white index
* when level, its 5-pixel base 26 pixels up along the horizon's direction
* h = (cos b, -s sin b); three lines from the tip to the base's ends and middle. The fixed white index above it
* on the bezel and the bank scale are the art
                    lda       #C_ORANGE
                    sta       LnC
                    ldb       #PtrBaseHW          +-2 pixels along h: (dots, rows)
                    lda       LdCos
                    lbsr      LdMul
                    stb       LdEx
                    ldb       #PtrBaseHW
                    lda       LdSin
                    lbsr      LdMul
                    asra
                    rorb
                    negb
                    stb       LdEy
                    ldb       #PtrTipUp
                    lbsr      BallUp
                    sta       LdYa                the tip
                    stb       LdXa
                    ldb       #PtrBaseUp
                    lbsr      BallUp
                    pshs      a,b                 the base's middle
                    lbsr      LnAB
                    puls      a,b
                    pshs      a,b
                    suba      LdEy
                    subb      LdEx
                    lbsr      LnAB
                    puls      a,b
                    adda      LdEy
                    addb      LdEx
                    lbsr      LnAB
* the miniature aircraft, orange, fixed to the case: two wing bars two rows thick with their inner ends turned
* down, and the center dot
                    ldd       NdCX
                    subd      #WingOuter
                    tfr       d,x
                    addd      #WingBarLen         the left bar, cx-16..cx-5, rows cy-1 and cy: its lower row on the
                    tfr       d,y                 level horizon (cy), as the real gauge's wings lie on its horizon
                    lda       NdCY
                    deca
                    lbsr      HLn
                    inca
                    lbsr      HLn
                    ldd       NdCX
                    addd      #WingInner
                    tfr       d,x
                    addd      #WingBarLen         the right bar, cx+5..cx+16
                    tfr       d,y
                    lda       NdCY
                    deca
                    lbsr      HLn
                    inca
                    lbsr      HLn
                    ldd       NdCX                the inner ends down: dots cx-5, cx-4 and cx+4, cx+5, rows cy+1..cy+3
                    subd      #WingInner
                    tfr       d,x
                    lda       NdCY
                    inca
                    tfr       a,b
                    addb      #WingDropRows
                    lbsr      VLn
                    leax      1,x
                    lbsr      VLn
                    ldd       NdCX
                    addd      #WingDropR
                    tfr       d,x
                    lda       NdCY                (D was the x: the rows again)
                    inca
                    tfr       a,b
                    addb      #WingDropRows
                    lbsr      VLn
                    leax      1,x
                    lbsr      VLn
                    ldd       NdCX                the center dot, 3 dots by 3 rows, cy-2..cy
                    subd      #CtrDotLeft
                    tfr       d,x
                    addd      #CtrDotW
                    tfr       d,y
                    lda       NdCY
                    suba      #CtrDotUp
                    ldb       NdCY
                    lbsr      Box
                    puls      d,x,y,u,pc
* BallUp: B = a radius in pixels: the point that far up the ball from its center along -u: B = its dots off the
* center, A = its rows, signed
BallUp              pshs      b
                    lda       LdSin
                    lbsr      LdMul
                    negb
                    pshs      b                   the dots
                    ldb       1,s
                    lda       LdCos
                    lbsr      LdMul
                    asra
                    rorb
                    negb
                    tfr       b,a                 the rows
                    puls      b
                    leas      1,s
                    rts
* LnAB: the line from (LdXa, LdYa) to (B, A), dots and rows off the ball's center, in LnC
LnAB                pshs      d
                    adda      NdCY
                    sta       LnY1
                    sex
                    addd      NdCX
                    std       LnX1
                    lda       LdYa
                    adda      NdCY
                    sta       LnY0
                    ldb       LdXa
                    sex
                    addd      NdCX
                    std       LnX0
                    lbsr      Ln
                    puls      d,pc

********************************************************************
* Engine: the fuel and oil gauges (a face, its scale, a tapered needle) and the three levers, every frame. The
* selected tank's gauge (FS's $0735: 0 the left, else the right; Ctrl+F then , or .) outlined in the label gray
* (2026-10-23, Roger: FS's own selector mark is on its CoCo panel, not shown); its region comes back from the art
* (the normal gray outline) whenever the selector changes, as its key.
FuelL               pshs      d,x,y,u
                    ldx       #GgFuL
                    lda       >vFuelL             fuel left, $20 full: the needle at x0 + 2 x value
                    cmpa      #FuelFull
                    bls       en1@
                    lda       #FuelFull
en1@                asla
                    lbsr      Gauge
                    tst       >vFuelTank
                    bne       en1a@
                    ldx       #GgFuL
                    bsr       GgSel
en1a@               puls      d,x,y,u,pc
FuelR               pshs      d,x,y,u
                    ldx       #GgFuR
                    lda       >vFuelR
                    cmpa      #FuelFull
                    bls       en2@
                    lda       #FuelFull
en2@                asla
                    lbsr      Gauge
                    tst       >vFuelTank
                    beq       en2a@
                    ldx       #GgFuR
                    bsr       GgSel
en2a@               puls      d,x,y,u,pc
* GgSel: X = a gauge's layout (x 16-bit, y, w): its outline, dots x to x + w - 1, rows y to y + 8, in the label
* gray. Registers kept.
GgSel               pshs      d,x,y,u
                    tfr       x,u
                    lda       #C_LABEL
                    sta       LnC
                    ldx       ,u                  x
                    ldb       3,u                 w
                    clra
                    leay      d,x
                    leay      -1,y                x + w - 1
                    lda       2,u                 the top row
                    lbsr      HLn
                    adda      #GgSelRows          the bottom row
                    lbsr      HLn
                    tfr       a,b
                    suba      #GgSelRows
                    lbsr      VLn                 the left side, rows A to B
                    tfr       y,x
                    lbsr      VLn                 the right side
                    puls      d,x,y,u,pc
OilP                pshs      d,x,y,u
                    ldx       #GgOiP
                    lda       >vOilPress          oil pressure 0-10 ($0A running): x 6.4
                    cmpa      #OilPMax
                    bls       en3@
                    lda       #OilPMax
en3@                ldb       #OilPScale
                    mul
                    lsrb
                    cmpb      #GaugeMaxDot
                    bls       en4@
                    ldb       #GaugeMaxDot
en4@                tfr       b,a
                    lbsr      Gauge
                    puls      d,x,y,u,pc
OilT                pshs      d,x,y,u
                    ldx       #GgOiT
                    lda       >vOilTemp           oil temperature 0-$12 (9 running, $12 hot): x 3
                    cmpa      #OilTMax
                    bls       en5@
                    lda       #OilTMax
en5@                ldb       #OilTScale
                    mul
                    tfr       b,a
                    lbsr      Gauge
                    puls      d,x,y,u,pc
* Controls (2026-10-19): the flaps' lever (FS's $081E high: 0, $20, $40, $60 down; up at the slot's top), the
* elevator's ($081A high, signed -$50..$50, 0 in the middle, up the top) and the rudder's knob on its bar ($082B
* high, signed, 0 at the bar's middle, +-14 dots)
Controls            pshs      d,x,y,u
                    ldx       #LvFlp
                    lda       >vFlaps
                    cmpa      #FlapsFull
                    bls       co1@
                    lda       #FlapsFull
co1@                ldb       #FlapsScale
                    mul                           x 58 / 96
                    nega
                    adda      #FlapsRows
                    tfr       a,b
                    lbsr      Lever
                    ldx       #LvElv
                    lda       >vElevator
                    cmpa      #FsElevFull
                    ble       co2@
                    lda       #FsElevFull
co2@                cmpa      #FsElevFullNeg
                    bge       co3@
                    lda       #FsElevFullNeg
co3@                adda      #FsElevFull         0-160
                    ldb       #ElevScale
                    mul                           x 58 / 160
                    tfr       a,b
                    lbsr      Lever
                    ldb       >vRudder            the rudder: |hb| (to 124) x 29 / 256 dots
                    pshs      b
                    bpl       co4@
                    negb
co4@                cmpb      #RudderMax
                    bls       co5@
                    ldb       #RudderMax
co5@                lda       #RudderScale
                    mul
                    tst       ,s+
                    bpl       co6@
                    nega
co6@                tfr       a,b
                    sex
                    addd      #RudMidX
                    tfr       d,x
                    lda       #C_GRAY2
                    sta       KnO
                    lda       #C_LED
                    sta       KnF
                    lda       #RudKnobTop
                    ldu       #KnRud
                    lbsr      Knob
                    puls      d,x,y,u,pc
* Levers: throttle $0837 high (0-$78) x 8/15 of 64 rows, mixture full, trim $081C high (-$50..$50)
Levers              pshs      d,x,y,u
                    ldx       #LvThr
                    lda       >vThrottle
                    ldb       #ThrScale
                    mul                           x 0.535
                    tfr       a,b
                    lbsr      Lever
                    ldx       #LvMix
                    ldb       #MixFull
                    lbsr      Lever
                    ldx       #LvTrm
                    lda       >vElevTrim
                    adda      #TrimBias
                    ldb       #TrimScale
                    mul                           x 0.402
                    tfr       a,b
                    lbsr      Lever
                    puls      d,x,y,u,pc

* Gauge: X = its layout (x 16-bit, y, w, x0 16-bit, x1 16-bit, red flag), A = the needle's dot from x0: the needle
* only, the mockup's triangle (rows y + 2, + 3 one dot, + 4, + 5 three, + 6, + 7 five). The face, its scale, the
* label and the red low mark are the art, back from the pristine copy with the region.
Gauge               pshs      d,x,y,u
                    sta       GgN
                    tfr       x,u
                    lda       #C_WHITE
                    sta       LnC
                    ldb       GgN
                    clra
                    addd      4,u
                    tfr       d,x
                    lda       2,u
                    adda      #GgNdTop
                    tfr       a,b
                    incb
                    lbsr      VLn
                    adda      #GgNdStep
                    leax      -1,x
                    leay      2,x
                    lbsr      HLn
                    inca
                    lbsr      HLn
                    inca
                    leax      -1,x
                    leay      1,y
                    lbsr      HLn
                    inca
                    lbsr      HLn
                    puls      d,x,y,u,pc
GgFuL               fdb       GFuLX
                    fcb       GFuLY,GFuLW
                    fdb       GFuLX0,GFuLX1
                    fcb       1
GgFuR               fdb       GFuRX
                    fcb       GFuRY,GFuRW
                    fdb       GFuRX0,GFuRX1
                    fcb       1
GgOiP               fdb       GOiPX
                    fcb       GOiPY,GOiPW
                    fdb       GOiPX0,GOiPX1
                    fcb       0
GgOiT               fdb       GOiTX
                    fcb       GOiTY,GOiTW
                    fdb       GOiTX0,GOiTX1
                    fcb       0

* Lever: X = its layout (x 16-bit, y0, y1, knob color), B = the handle's rows up from the bottom (0-64): the slot
* black, its ticks, the bar from the handle down, the knob
Lever               pshs      d,x,y,u
                    stb       LvB
                    tfr       x,u
                    lda       3,u                 the handle row: y1 - rows (the slot and its ticks are the art)
                    suba      LvB
                    sta       LvY
                    lda       #C_GRAY4
                    sta       LnC
                    ldx       ,u
                    leax      2,x
                    lda       LvY
                    ldb       3,u
                    decb
                    lbsr      VLn
                    leax      1,x
                    lbsr      VLn
                    leax      1,x
                    lbsr      VLn
                    leax      1,x
                    lbsr      VLn
                    lda       4,u                 the knob, an ellipse 10 x 7 on the handle row
                    sta       KnF
                    lda       #C_GRAY2
                    sta       KnO
                    ldx       ,u
                    lda       LvY
                    suba      #LvKnobUp
                    ldu       #KnLev
                    lbsr      Knob
                    puls      d,x,y,u,pc
LvThr               fdb       LThrX
                    fcb       LThrY0,LThrY1,C_GREEN  the throttle's knob green, the trim's blue (Roger 2026-10-17)
LvMix               fdb       LMixX
                    fcb       LMixY0,LMixY1,C_RED
LvTrm               fdb       LTrmX
                    fcb       LTrmY0,LTrmY1,C_SKY
LvFlp               fdb       LFlpX
                    fcb       LFlpY0,LFlpY1,C_ORANGE
LvElv               fdb       LElvX
                    fcb       LElvY0,LElvY1,C_GROUND

********************************************************************
* The readouts: old-style seven-segment characters 6 dots x 7 rows at an 8-dot pitch, the dark 8 behind every
* digit and the lit segments bright (the mockup's lcd()); each readout's text is built in Txt (codes 0-9 digits,
* 10 blank, 11 '.' lit, 12 ':' lit, 13 '.' dark: a point is a dot after its digit and takes no room, a colon two
* dots in a 3-dot cell) and compared with its cache, a changed character redrawn.
Readouts            pshs      d,x,y,u
                    lbsr      Tick
                    ldx       #RdTbl
rd1@                ldu       ,x                  the builder
                    beq       rd9@
                    pshs      x
                    jsr       ,u                  Txt filled, A = its length
                    puls      x
                    sta       TxtN
                    ldy       2,x                 the cache
                    ldd       4,x                 vx
                    std       RdX
                    lda       6,x                 y0 + 1
                    sta       RdY
                    clr       RdI
rd2@                ldb       RdI
                    pshs      x
                    ldx       #Txt
                    lda       b,x
                    bsr       Adv                 RdA = its room
                    cmpa      b,y                 as the cache has it: nothing to draw
                    beq       rd3@
                    sta       b,y
                    lbsr      Char
rd3@                puls      x
                    ldb       RdA
                    clra
                    addd      RdX
                    std       RdX
                    inc       RdI
                    lda       RdI
                    cmpa      TxtN
                    blo       rd2@
                    leax      7,x
                    bra       rd1@
rd9@                puls      d,x,y,u,pc
* Adv: A = a character code: RdA = the dots it takes (8, a point 0, a colon 3). Registers kept.
Adv                 pshs      d
                    ldb       #CharPitch
                    cmpa      #ChColon
                    bne       av1@
                    ldb       #ColonPitch
av1@                cmpa      #ChPoint
                    beq       av0@
                    cmpa      #ChPointDim
                    bne       av2@
av0@                clrb
av2@                stb       RdA
                    puls      d,pc

* Char: the character A (0-13) at RdX, RdY: a digit's unlit segments dark, the lit ones bright, each drawn once
* (a character is never erased to a dark 8 first, so a frame caught half drawn never shows one); a point at
* RdX - 1, RdY + 6 (after the digit before it), a colon's dots at RdX, RdY + 2 and + 4
Char                pshs      d,x,y,u
                    sta       ChC
                    cmpa      #ChPoint
                    bhs       ch1@
                    ldb       #C_LEDDIM
                    stb       LnC
                    lda       #SegAll             the dark segments: all but the lit ones
                    ldb       ChC
                    cmpb      #ChBlank
                    bhs       ch0@
                    ldx       #SegBits
                    eora      b,x
ch0@                bsr       Segs
                    ldb       ChC
                    cmpb      #ChBlank
                    bhs       ch9@
                    lda       #C_LED
                    sta       LnC
                    ldx       #SegBits
                    lda       b,x
                    bsr       Segs
                    bra       ch9@
ch1@                ldb       #C_LED
                    cmpa      #ChPointDim         '.' dark
                    bne       ch1a@
                    ldb       #C_LEDDIM
                    lda       #ChPoint
ch1a@               stb       LnC
                    cmpa      #ChPoint            '.'
                    bne       ch2@
                    ldx       RdX
                    leax      -1,x
                    tfr       x,y
                    lda       RdY
                    adda      #PointRow
                    lbsr      HLn
                    bra       ch9@
ch2@                ldx       RdX                 ':'
                    tfr       x,y
                    lda       RdY
                    adda      #ColonStep
                    lbsr      HLn
                    adda      #ColonStep
                    lbsr      HLn
ch9@                puls      d,x,y,u,pc

* Segs: the segments in A's bits 0-6 (a-g) of the character at RdX, RdY in LnC
Segs                pshs      d,x,y
                    sta       SgM
                    ldy       #SegXY
                    lda       #SegCount
                    sta       SgI
sg1@                lsr       SgM
                    bcc       sg2@
                    ldd       RdX
                    addb      ,y
                    adca      #ZeroExtHi
                    std       LnX0
                    lda       RdY
                    adda      1,y
                    sta       LnY0
                    ldd       RdX
                    addb      2,y
                    adca      #ZeroExtHi
                    std       LnX1
                    lda       RdY
                    adda      3,y
                    sta       LnY1
                    lbsr      Ln
sg2@                leay      4,y
                    dec       SgI
                    bne       sg1@
                    puls      d,x,y,pc
* a (top), b, c (right), d (bottom), e, f (left), g (middle): dx0, dy0, dx1, dy1 (the mockup's seg7)
SegXY               fcb       1,0,4,0,5,1,5,2,5,4,5,5,1,6,4,6,0,4,0,5,0,1,0,2,1,3,4,3
SegBits             fcb       $3F,$06,$5B,$4F,$66,$6D,$7D,$07,$7F,$6F

* the readouts, top to bottom: builder, cache, vx, y0 + 1
RdTbl               fdb       TxCom1,CaCom1,RCom1VX
                    fcb       RCom1Y0+1
                    fdb       TxNav1,CaNav1,RNav1VX
                    fcb       RNav1Y0+1
                    fdb       TxNav2,CaNav2,RNav2VX
                    fcb       RNav2Y0+1
                    fdb       TxAdf,CaAdf,RAdfVX
                    fcb       RAdfY0+1
                    fdb       TxDme,CaDme,RDmeVX
                    fcb       RDmeY0+1
                    fdb       TxAct,CaAct,RActVX
                    fcb       RActY0+1
                    fdb       TxTim,CaTim,RTimVX
                    fcb       RTimY0+1
                    fdb       TxXpd,CaXpd,RXpdVX  the second column
                    fcb       RXpdY0+1
                    fdb       TxGs,CaGs,RGsVX
                    fcb       RGsY0+1
                    fdb       TxTts,CaTts,RTtsVX
                    fcb       RTtsY0+1
                    fdb       TxEt,CaEt,REtVX
                    fcb       REtY0+1
                    fdb       TxFf,CaFf,RFfVX
                    fcb       RFfY0+1
                    fdb       TxUsd,CaUsd,RUsdVX
                    fcb       RUsdY0+1
                    fdb       TxCom2,CaCom2,RCom2VX
                    fcb       RCom2Y0+1
                    fdb       0

* Dec3: D = 0-999 -> three digit codes at X. Registers kept but X (left after the digits).
Dec3                pshs      d
                    clr       ,x
dc1@                subd      #DecHundred
                    bcs       dc2@
                    inc       ,x
                    bra       dc1@
dc2@                addd      #DecHundred
                    clr       1,x
dc3@                subd      #DecTen
                    bcs       dc4@
                    inc       1,x
                    bra       dc3@
dc4@                addd      #DecTen
                    stb       2,x
                    leax      3,x
                    puls      d,pc
* Asc: the ASCII digit at X to a code at Y, both on
Asc                 lda       ,x+
                    suba      #AsciiZero
                    cmpa      #DigitMax
                    bls       as1@
                    lda       #ChBlank
as1@                sta       ,y+
                    rts

TxTim               ldy       #Txt
                    ldx       #TmpB
                    clra
                    ldb       >vHour
                    pshs      y
                    lbsr      Dec3                hours as 3 digits in TmpB
                    puls      y
                    lda       TmpB+1
                    sta       ,y+
                    lda       TmpB+2
                    sta       ,y+
                    lda       #ChColon
                    sta       ,y+
                    ldx       #TmpB
                    clra
                    ldb       >vMinute
                    pshs      y
                    lbsr      Dec3
                    puls      y
                    lda       TmpB+1
                    sta       ,y+
                    lda       TmpB+2
                    sta       ,y+
                    lda       #RTimN
                    rts
TxCom1              ldx       #vCom1AllDigits
                    bra       TxFreq
TxNav1              ldx       #vNav1AllDigits
                    bra       TxFreq
TxNav2              ldx       #vNav2AllDigits
TxFreq              ldy       #Txt
                    lbsr      Asc
                    lbsr      Asc
                    lbsr      Asc
                    lda       #ChPoint
                    sta       ,y+
                    lbsr      Asc
                    lbsr      Asc
                    lda       #FreqChars
                    rts
TxAdf               ldy       #Txt
                    lda       #ChBlank
                    sta       ,y+
                    ldx       #vAdfDigits
                    lbsr      Asc
                    lbsr      Asc
                    lbsr      Asc
                    lda       #RAdfN
                    rts
TxDme               ldy       #Txt
                    lda       #ChBlank
                    tst       >vDmeOff            no signal: blank
                    bne       td1@
                    ldx       #TmpB
                    clra
                    ldb       >vDmeNm
                    pshs      y
                    lbsr      Dec3
                    puls      y
                    lda       TmpB+1
                    sta       ,y+
                    lda       TmpB+2
                    sta       ,y+
                    lda       #ChPoint
                    sta       ,y+
                    lda       >vDmeTenths
                    cmpa      #DigitMax
                    bls       td2@
                    lda       #DigitMax
td2@                sta       ,y+
                    lda       #RDmeN
                    rts
td1@                sta       ,y+                 blank: two dark 8s, the dark point, a dark 8
                    sta       ,y+
                    ldb       #ChPointDim
                    stb       ,y+
                    sta       ,y+
                    lda       #RDmeN
                    rts
* ACT: the traffic actor (fst's readout, FswTfBrg / FswTfDst): its bearing from the nose, degrees clockwise, a
* colon, its distance in km (two digits; the readout is in hundreds of meters, 999 = no actor: all blank)
TxAct               ldx       #Txt
                    ldd       >FswTfDst
                    cmpd      #TfNone
                    beq       ta1@
                    ldd       >FswTfBrg
                    lbsr      Dec3
                    lda       #ChColon            a colon between them (a separator)
                    sta       ,x+
                    ldd       >FswTfDst
                    pshs      x
                    ldx       #TmpB
                    lbsr      Dec3                hundreds of meters as three digits: km = the first two
                    puls      x
                    ldd       TmpB
                    std       ,x
                    lda       #RActN
                    rts
ta1@                lda       #ChBlank
                    sta       ,x+
                    sta       ,x+
                    sta       ,x+
                    ldb       #ChColon
                    stb       ,x+
                    sta       ,x+
                    sta       ,x
                    lda       #RActN
                    rts

* Tick (Readouts, every frame): on each new second of FS's clock ($0287) the elapsed timer and, every 2 s, a DME
* sample: the distance to NAV1's station (Dist) and the closure against the sample 16 s before (DmC); the samples
* start again while the DME has no signal ($0719)
Tick                lda       >vSecond
                    cmpa      TkSec
                    lbeq      tk9@
                    sta       TkSec
                    inc       EtS
                    lda       EtS
                    cmpa      #SecPerMin
                    blo       tk1@
                    clr       EtS
                    inc       EtM
                    lda       EtM
                    cmpa      #EtMinWrap
                    blo       tk1@
                    clr       EtM
tk1@                lda       TkSec
                    lsra
                    bcs       tk9@
                    tst       >vDmeOff
                    bne       tk8@
                    bsr       Dist
                    std       DmD
                    ldx       #DmRing
                    ldb       DmI
                    aslb
                    abx
                    ldy       ,x                  the sample 16 s before
                    std       ,x
                    ldb       DmI
                    incb
                    andb      #DmRingMask
                    stb       DmI
                    lda       DmN
                    cmpa      #DmRingN
                    bhs       tk4@
                    inc       DmN
                    rts
tk4@                tfr       y,d
                    subd      DmD                 closing: positive
                    std       DmC
tk9@                rts
tk8@                clr       DmN
                    rts

* Dist: D = the distance to NAV1's station in 16 m units from its offsets $0728 / $072A (FS's DME source,
* ApproxStationDistance): 31/32 the larger plus 3/8 the smaller (within 4 %)
Dist                pshs      x
                    ldd       >vStationDZ
                    bpl       ds1@
                    coma
                    comb
                    addd      #NegCarry
ds1@                std       DsA
                    ldd       >vStationDX
                    bpl       ds2@
                    coma
                    comb
                    addd      #NegCarry
ds2@                cmpd      DsA
                    bhs       ds3@
                    ldx       DsA                 the larger to DsM, the smaller to DsA
                    std       DsA
                    tfr       x,d
ds3@                std       DsM
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
                    pshs      d                   the larger / 32
                    ldd       DsM
                    subd      ,s++
                    std       DsM
                    ldd       DsA
                    lsra
                    rorb
                    lsra
                    rorb
                    pshs      d                   the smaller / 4
                    lsra
                    rorb
                    addd      ,s++
                    addd      DsM
                    puls      x,pc

* Div: DvN (24 bits) / D (below 32,768): the quotient in DvN, the remainder dropped. Registers kept.
Div                 pshs      d,x
                    std       DvD
                    clra
                    clrb
                    ldx       #DivBits
dv1@                asl       DvN+2
                    rol       DvN+1
                    rol       DvN
                    rolb
                    rola
                    cmpd      DvD
                    blo       dv2@
                    subd      DvD
                    inc       DvN+2
dv2@                leax      -1,x
                    bne       dv1@
                    puls      d,x,pc

* Lz: B digit codes at X: the leading zeros blank (dark 8s)
Lz                  lda       ,x
                    bne       lz9@
                    lda       #ChBlank
                    sta       ,x+
                    decb
                    bne       Lz
lz9@                rts
* Two: B = 0-99 -> two digit codes at X, X on past them
Two                 lbsr      Dec3
                    ldd       -2,x
                    std       -3,x
                    leax      -1,x
                    rts

* XPDR: the transponder code, four digits at $09FA (FS's SetXpdrCode)
TxXpd               ldy       #Txt
                    ldx       #vXpdrDigits
                    lbsr      Asc
                    lbsr      Asc
                    lbsr      Asc
                    lbsr      Asc
                    lda       #RXpdN
                    rts
* GS: the DME's ground speed, the closure over 16 s: 16 m / 16 s = 1.944 knots (x 249 / 128), its size; dark
* until 16 s of samples
TxGs                ldx       #Txt
                    lda       DmN
                    cmpa      #DmRingN
                    blo       Dark3
                    ldd       DmC
                    bpl       gs1@
                    coma
                    comb
                    addd      #NegCarry
gs1@                tsta
                    beq       gs2@
                    ldb       #GsClosureMax
gs2@                lda       #GsScale
                    mul
                    aslb
                    rola
                    tfr       a,b
                    lda       #RolaStart
                    rola
* Num3: D = 0-999 -> three digits at Txt (X), the leading zeros dark
Num3                lbsr      Dec3
                    ldx       #Txt
                    ldb       #Num3LzN
                    bsr       Lz
                    lda       #Num3Chars
                    rts
Dark3               lda       #ChBlank
                    sta       ,x+
                    sta       ,x+
                    sta       ,x
                    lda       #Num3Chars
                    rts
* TTS: the minutes to the station at that speed, the distance x 4 / (15 x the closure) (16 m units, 16 s), up
* to 999; dark while not closing
TxTts               ldx       #Txt
                    lda       DmN
                    cmpa      #DmRingN
                    blo       Dark3
                    ldd       DmC
                    ble       Dark3
                    cmpd      #TtsClosureMax
                    bls       ts1@
                    ldd       #TtsClosureMax
ts1@                pshs      d                   x 15: x 16 less once
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    subd      ,s++
                    pshs      d                   the divisor
                    clr       DvN
                    ldd       DmD
                    aslb
                    rola
                    rol       DvN
                    aslb
                    rola
                    rol       DvN
                    std       DvN+1
                    puls      d
                    lbsr      Div
                    ldd       DvN+1
                    tst       DvN
                    bne       ts2@
                    cmpd      #Max3Digits
                    bls       ts3@
ts2@                ldd       #Max3Digits
ts3@                ldx       #Txt
                    bra       Num3
* ET: the elapsed timer, minutes and seconds of FS's clock since FS started (99:59, then round)
TxEt                ldx       #Txt
                    clra
                    ldb       EtM
                    lbsr      Two
                    lda       #ChColon
                    sta       ,x+
                    clra
                    ldb       EtS
                    lbsr      Two
                    lda       #REtN
                    rts
* FF: the fuel flow, gallons an hour in tenths: FS burns 5 x the throttle ($0837) / 65536 units (gallons) every
* 4 s while the engine runs (UpdateEngineFuelBurn; x 8 in WWI mode, $0307): x 0.687 tenths
TxFf                clra
                    clrb
                    tst       >vEngineOn
                    beq       Tenth
                    lda       >vThrottle
                    bpl       ff1@
                    clra
ff1@                ldb       #FfScale
                    mul
                    tfr       a,b
                    clra
                    tst       >vEurope1917
                    beq       Tenth
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
* Tenth: D = tenths 0-999 -> two digits (the first dark when 0), the point, a digit
Tenth               ldx       #Txt
                    cmpd      #Max3Digits
                    bls       te1@
                    ldd       #Max3Digits
te1@                lbsr      Dec3
                    ldb       -1,x
                    lda       #ChPoint
                    std       -1,x
                    ldx       #Txt
                    ldb       #TenthLzN
                    lbsr      Lz
                    lda       #TenthChars
                    rts
* USED: the fuel burned since FS started (or since the tanks last rose: a refill), gallons in tenths: both tanks,
* units $0731 / $0734 and fractions $072F / $0732
TxUsd               ldd       >vFuelLFrac
                    addd      >vFuelRFrac
                    std       UsF
                    lda       >vFuelL
                    adca      >vFuelR
                    sta       UsW
                    cmpa      U0W
                    bhi       us1@
                    blo       us2@
                    ldd       UsF
                    cmpd      U0F
                    bls       us2@
us1@                lda       UsW                 more than at the start: start again
                    sta       U0W
                    ldd       UsF
                    std       U0F
us2@                ldd       U0F
                    subd      UsF
                    pshs      a                   the fraction's high byte
                    lda       U0W
                    sbca      UsW
                    ldb       #TenthsPerUnit
                    mul                           units x 10
                    pshs      d
                    lda       2,s
                    ldb       #TenthsPerUnit
                    mul
                    tfr       a,b
                    clra
                    addd      ,s++
                    leas      1,s
                    bra       Tenth
* COM2: fsw's FswCom2 (BCD, 121.15 as $2115: twr.asm tunes it, Ctrl+K)
TxCom2              ldy       #Txt
                    lda       #Com2Lead
                    sta       ,y+
                    lda       >FswCom2
                    bsr       Nibs
                    lda       #ChPoint
                    sta       ,y+
                    lda       >FswCom2+1
                    bsr       Nibs
                    lda       #RCom2N
                    rts
* Nibs: A = two BCD digits to two digit codes at Y, Y on. B clobbered.
Nibs                tfr       a,b
                    lsra
                    lsra
                    lsra
                    lsra
                    sta       ,y+
                    andb      #BcdLoDigit
                    stb       ,y+
                    rts

********************************************************************
* Switches: the lamps' row, the five switches' (lit green when on), the stall light's (red) and the audio panel's
* six buttons (amber, FswAud), on a change
Switches            pshs      d,x,y,u
                    lda       >vMagSw             magnetos: lit unless off
                    beq       sw1@
                    lda       #LampOn
sw1@                ldx       #SwMag
                    lbsr      Lamp
                    lda       >vLights            panel lights
                    ldx       #SwLit
                    lbsr      Lamp
                    lda       >vCarbHeat          carb heat
                    ldx       #SwCrb
                    lbsr      Lamp
                    lda       >vFlaps             flaps: lit when down
                    ldx       #SwFlp
                    lbsr      Lamp
                    lda       >vJoyMode           the joystick (mouse) setting
                    ldx       #SwMse
                    lbsr      Lamp
* the stall light (the lamps' row, red): angle of attack $074B high at or past $21
                    lda       >vAngleOfAttack
                    cmpa      #StallWarnAoA
                    blo       sw2@
                    cmpa      #Angle8Half
                    bhs       sw2@
                    lda       #LampOn
                    bra       sw3@
sw2@                clra
sw3@                ldx       #SwStl
                    lbsr      Lamp
* the audio panel's buttons (amber): FswAud's bits 0-5, COM1 to MKR
                    ldb       >FswAud
                    ldx       #SwAud
sw4@                clra
                    lsrb
                    rola
                    lbsr      Lamp
                    leax      5,x
                    cmpx      #SwAudE
                    blo       sw4@
                    puls      d,x,y,u,pc

* Strip (2026-10-19, in place of the VICKY border, which shows top and bottom alike): the GPU view's state across
* the dash bitmap's top rows (layer 0, over the view), when fsx's GpInit found the GPU (FswBrdOn): the left third
* clear (it was red with the haze on; the haze is gone), the middle green with the line ribbons on (FswGfxOn's
* FgRibbon), the right third blue with the dither on (FswGpCtl b3), each else clear (nibble 0, the view shows); 2 rows (until 2026-10-24
* 4 in 320 x 256 colors, 8 in 640 x 16); the 8 rows below cleared. Drawn on a change.
Strip               pshs      d,x,y,u
                    tst       >FswBrdOn
                    beq       st9@
                    clrb
                    lda       >FswGfxOn           the line ribbons (fsx's GfxKey)
                    bita      #FgRibbon
                    beq       st2@
                    orb       #StRibbon
st2@                lda       >FswGpCtl
                    bita      #GpuCtlDither
                    beq       st3@
                    orb       #StDither
st3@                bita      #GpuCtl256
                    bne       st4@
                    orb       #St640              640 x 16
st4@                cmpb      StCa                as drawn last: nothing to do
                    beq       st9@
                    stb       StCa
                    lda       #StripRows          2 rows (Roger 2026-10-24), in either mode
                    sta       StH
                    clr       StR
st6@                ldu       #StTab              each row, each third
st7@                clra
                    ldb       StR
                    cmpb      StH
                    bhs       st8@                past the height: clear
                    ldb       StCa
                    andb      4,u
                    beq       st8@
                    lda       5,u
st8@                sta       LnC
                    ldx       ,u
                    ldy       2,u
                    lda       StR
                    lbsr      HLn
                    leau      6,u
                    cmpu      #StTabE
                    blo       st7@
                    inc       StR
                    lda       StR
                    cmpa      #StripClrRows
                    blo       st6@
st9@                puls      d,x,y,u,pc
StTab               fdb       37,212              clear of the cockpit's top-left corner (CpDrop) and its post
                    fcb       1,C_RED
                    fdb       213,CpPX-1
                    fcb       2,C_GREEN
                    fdb       CpPX+12,426
                    fcb       2,C_GREEN
                    fdb       427,639
                    fcb       4,C_SKY
StTabE              equ       *
StCa                fcb       $FF                 the state drawn last
StH                 fcb       0
StR                 fcb       0

* Cockpit (Frame, once; on both buffers with LnBoth): the cockpit as seen from the left seat, on the art's
* transparent rows above the dash, where nothing else draws: the windshield post right of center (columns CpPX ..
* +11 in CpCol's colors, rows 0 to the dash's top edge, rivets every 10 rows in two columns) and the windshield's
* top-left corner in the cockpit's gray (the dash's left curve mirrored: CpDrop's rows per column)
Cockpit             pshs      d,x,y,u
                    ldu       #CpCol
                    ldx       #CpPX
cp1@                lda       ,u+                 the post's columns
                    sta       LnC
                    clra
                    ldb       #CpPostEnd
                    lbsr      VLn
                    leax      1,x
                    cmpu      #CpColE
                    blo       cp1@
                    lda       #RivetRow0          the rivets
cp2@                sta       CpY
                    ldx       #RivetX0
                    bsr       Rivet
                    ldx       #RivetX1
                    bsr       Rivet
                    lda       CpY
                    adda      #RivetStep
                    cmpa      #RivetRowEnd
                    blo       cp2@
                    lda       #C_GRAY3            the top-left corner
                    sta       LnC
                    ldx       #CpCornerX
                    ldu       #CpDrop
cp3@                ldb       ,u+
                    beq       cp9@
                    decb
                    clra
                    lbsr      VLn
                    leax      1,x
                    bra       cp3@
cp9@                puls      d,x,y,u,pc
* Rivet: X = the column, CpY the row: a light dot over its shadow
Rivet               lda       #C_LABEL
                    sta       LnC
                    lda       CpY
                    tfr       a,b
                    lbsr      VLn
                    lda       #C_GRAY3
                    sta       LnC
                    lda       CpY
                    inca
                    tfr       a,b
                    lbra      VLn
CpCol               fcb       C_BLACK,C_GRAY5,C_GRAY4,C_GRAY4,C_GRAY4,C_GRAY4,C_GRAY4,C_GRAY4,C_GRAY4,C_GRAY4
                    fcb       C_GRAY3,C_BLACK     a dark edge, the lit left edge, the body, the shaded right edge
CpColE              equ       *
CpY                 fcb       0
CpDone              fcb       0

* Lamp: X = the lamp (lx 16-bit, y0, cache, lit color), A = on (nonzero): the bulb, an ellipse 5 x 3 on the
* socket's rows y0 + 2 .. + 4 (the mockup's), its color when on, else the dark gray, on a change
Lamp                pshs      d,x,y,u
                    cmpa      3,x                 as drawn last: nothing to do
                    beq       lp9@
                    sta       3,x
                    ldb       #C_DARK
                    tsta
                    beq       lp2@
                    ldb       4,x
lp2@                stb       KnO
                    stb       KnF
                    lda       2,x
                    adda      #LampBulbDown
                    ldx       ,x
                    ldu       #KnLamp
                    lbsr      Knob
lp9@                puls      d,x,y,u,pc
KnLamp              fcb       3,-1,1,$7F,0,-2,2,$7F,0,-1,1,$7F,0
SwMag               fdb       SMagLX
                    fcb       SMagY0,$FF,C_GREEN
SwLit               fdb       SLitLX
                    fcb       SLitY0,$FF,C_GREEN
SwCrb               fdb       SCrbLX
                    fcb       SCrbY0,$FF,C_GREEN
SwFlp               fdb       SFlpLX
                    fcb       SFlpY0,$FF,C_GREEN
SwMse               fdb       SMseLX
                    fcb       SMseY0,$FF,C_GREEN
SwStl               fdb       SStlLX
                    fcb       SStlY0,$FF,C_RED
SwAud               fdb       SAc1LX              the audio panel: COM1, COM2, NAV1, NAV2, ADF, MKR
                    fcb       SAc1Y0,$FF,C_ORANGE
                    fdb       SAc2LX
                    fcb       SAc2Y0,$FF,C_ORANGE
                    fdb       SAn1LX
                    fcb       SAn1Y0,$FF,C_ORANGE
                    fdb       SAn2LX
                    fcb       SAn2Y0,$FF,C_ORANGE
                    fdb       SAadLX
                    fcb       SAadY0,$FF,C_ORANGE
                    fdb       SAmkLX
                    fcb       SAmkY0,$FF,C_ORANGE
SwAudE              equ       *

* the working variables
LnX0                fdb       0
LnX1                fdb       0
LnY0                fcb       0
LnY1                fcb       0
LnC                 fcb       0
NdCX                fdb       0
NdCY                fcb       0
NdRX                fcb       0
NdRY                fcb       0
TipX                fdb       0
TipY                fcb       0
TcPos               fcb       0
TcY                 fcb       0
RoI                 fcb       0
RoP                 fcb       0
RoM                 fcb       0
RoL                 fcb       0
AtPo                fcb       0
AtBk                fcb       0
AtAb                fcb       0
AtCot               fcb       0
AtDy                fcb       0
AtHw                fcb       0
AtY                 fcb       0
AtD                 fcb       0
AtXl                fdb       0
AtXr                fdb       0
AtXc                fdb       0
LdK                 fcb       0                   the pitch marks: the mark (-3..3), k x 8, its center (dots, rows), half width
LdK8                fcb       0
LdX                 fcb       0
LdY                 fcb       0
LdW                 fcb       0
LdSin               fcb       0                   s sin b and cos b, Q7
LdCos               fcb       0
LdEx                fcb       0                   the half width along the horizon (dots, rows)
LdEy                fcb       0
LdXa                fcb       0                   the right end
LdYa                fcb       0
AtCl                fcb       0
AtCr                fcb       0
GgN                 fcb       0
LvB                 fcb       0
LvY                 fcb       0
RdX                 fdb       0
RdY                 fcb       0
RdI                 fcb       0
TxtN                fcb       0
ChC                 fcb       0
SgM                 fcb       0
SgI                 fcb       0
RdA                 fcb       0                   a character's room (Adv)
KnX                 fdb       0                   Knob: its reference dot, row, rows left, colors
KnR                 fcb       0
KnN                 fcb       0
KnO                 fcb       0
KnF                 fcb       0
CdRef               fdb       0                   Card: the card's heading, its layout, the letters' inset, the tick
CdDl                fdb       0
CdIn                fdb       0
CdTk                fcb       0
GlX                 fdb       0                   Gl35: the glyph's top left, the row, rows left
GlY                 fcb       0
GlR                 fcb       0
GlN                 fcb       0
NvFl                fcb       0                   NavDial: the flag
Txt                 rmb       8
TmpB                rmb       4
CaTim              fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
CaCom1              fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
CaNav1              fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
CaNav2              fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
CaAct               fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
CaAdf               fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
CaDme               fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
CaXpd               fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
CaGs                fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
CaTts               fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
CaEt                fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
CaFf                fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
CaUsd               fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
CaCom2               fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
TkSec               fcb       $FF                 FS's clock seconds as Tick saw them last
EtM                 fcb       0                   the elapsed timer: minutes 0-99, seconds
EtS                 fcb       0
DmN                 fcb       0                   the DME samples taken (8: the ring is full)
DmI                 fcb       0                   the ring's next slot
DmD                 fdb       0                   the newest distance, 16 m units
DmC                 fdb       0                   the closure over 16 s, 16 m units
DmRing              rmb       16                  a distance every 2 s, the last 8
DsA                 fdb       0                   Dist's work
DsM                 fdb       0
DvD                 fdb       0                   Div's divisor
DvN                 rmb       3                   Div's dividend, then the quotient
UsW                 fcb       0                   the fuel in both tanks: units, fraction
UsF                 fdb       0
U0W                 fcb       0                   the fuel at the start (or the last refill)
U0F                 fdb       0
RsSrc               fcb       0,0,0               a region's restore: its 24-bit source and destination, its offset
RsDst               fcb       0,0,0
RsOfs               fdb       0
RsOfsH              fcb       0                   the offset's bit 16
PrAdr               fcb       0,0,0               the pristine copy's and the dash bitmap's 24-bit bases
BmAdr               fcb       0,0,0
RgDirty             fdb       0                   the regions to restore and redraw this frame (RgBits)
RgI                 fcb       0
RgSkip              fcb       0                   frames left alone waiting for the raster window
RgKeys              fill      $FF,RgCount*RgKeyN  the keys: none taken yet
AdfCa               fcb       $FF                 the ADF switch the NAV2 spot's face was made for ($FF: none yet)
Pris                fcb       0                   the pristine copy's first block
InStep              fcb       0                   Init's step, for its failure
IoY                 fdb       0                   the last read's Y, B and CC
IoB                 fcb       0
IoCC                fcb       0
LnPlane             fcb       0                   the frame's bitmap, as the line engine's plane bits
LnP                 fcb       0                   Ln's bitmap now
LnBoth              fcb       0                   1: Ln draws on both dash buffers (the readouts and switches)
* the K2's second dash buffer (2026-10-18): bitmap 1 (the GPU draws the view there, so bitmaps 0 and 1 are free)
Bm1                 fcb       0                   its first block (0: one buffer, the Jr2)
Shown               fcb       0                   the buffer on layer 0: 0 bitmap 2, 1 bitmap 1
FlipPend            fcb       0                   1: the hidden buffer is drawn, to be shown
RgAlt               fill      $FF,RgCount*RgKeyN
                    ifne      *-RgAlt-RgCount*RgKeyN
                    error     "fsp: RgAlt is not RgKeys' size"
                    endc
Dst2               fcb       0,0,0               Init: the next bytes' 24-bit address in bitmap 1

                    use       fsp_layout.d

DName               fcs       "/dd/fs2/dash.bm"
DashBlk             fcb       0                   bitmap 2's first block
Self                fdb       0                   this block
Path                fcb       0
Part                fdb       0                   its bitmap bytes
Done                fdb       0                   bitmap bytes moved
Src                 fcb       0,0,0               the buffer's 24-bit address
Dst0                fcb       0,0,0               the next bytes' 24-bit addresses in the bitmap and the pristine copy
Dst1                fcb       0,0,0
Pal                 rmb       PalBytes

BufStart            equ       FspBase+FspMax-ChunkMax
                    ifgt      *-BufStart
                    error     "fsp: code runs into the chunk buffer"
                    endc
                    zmb       BufStart-*
Buf                 rmb       ChunkMax
