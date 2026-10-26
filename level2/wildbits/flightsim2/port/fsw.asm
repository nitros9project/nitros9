********************************************************************
* fsw - FS (Flight Simulator II), WildBits port: the drawing layer
*
* A raw binary, not a module: WbStart (fs_wb.asm part 3) reads /dd/fs2/fsw into FS's data area from FswLoad:
* part 1 in data FS leaves unused, part 2 from FswBase in the back buffer FS no longer needs. FS's view is 256 x 127 units (its projection, fs_flight.asm) and has no
* memory: the view base is 0, so a view address is row*80 + x/2 and only names the row. Every view primitive
* lands here and becomes line-engine records, scaled to the full 640-dot width and rows 0-ViewLast (163), in the
* hidden HIRES4 bitmap; FS's own pixel writes for the view are skipped. FswPresent draws the records and flips the
* two bitmaps on layer 1, under the dash (fsp, bitmap 2 on layer 0).
*
* View units: the projection reaches x 1-255 and rows 1-125 only (centers 128 and 63), so those fill the bitmap:
* x -> dots T(x-1) .. T(x)-1 with T(u) = 2u + (u*131)>>8 (T(255) = 640); row -> bitmap rows MapRow(row) .. MapRow(row+1)-1
* (rows 1-125 -> 0-163). Column 0 and rows 0 and 126 get no dots, so the ground fill never shows there.

                    nam       fsw
                    ttl       FS2 WildBits drawing layer

                    ifp1
                    use       defsfile
                    use       fs_wb.d
                    endc

* Constants: the values this module's instructions use, by name (fs_wb.d holds the addresses)
AScrnBlocks         equ       3                   WbAScrn's RAM blocks: the clouds', the panel's, the scenery window's second (3)
BorderBytes         equ       6                   VICKY's border registers in BrdRq: control, blue, green, red, x size, y size (bytes)
BothNibbles         equ       $11                 a 4-bit color times it: the color in both nibbles of a byte
ByteBits            equ       8                   bits in a byte: a shift of 8 or more moves whole bytes
CarryOnly           equ       0                   0: an adc or sbc of the carry alone (a rounding bit, a carry or borrow into the next byte)
CenterX16           equ       5120                the view's center dot (320) in sixteenths
ClipBigBias         equ       $40                 ClipBig: + $40 on a word's high byte leaves bit 7 clear only within -16384..+16383
CodeBlocks          equ       1                   fsx's, fswc's or fsp's RAM: one 8 KB block each (F$AllRAM, F$DelRAM's count)
ColorNibble         equ       $0F                 a color 0-15 in a byte's low nibble (FS's color patterns repeat it in each nibble)
CrossingBytes       equ       2                   a crossing in XBuf, a word: one past XBufSecond is one pair
CrossPairMask       equ       %11111100           XBuf's byte count rounded down to whole pairs of crossings (4 bytes)
DashBitmap          equ       2                   SS.FScrn's Y: bitmap 2, the dash's (fswc's DashBm)
DelayAExit          equ       0                   DelayA's X and Y at its exit: 0 (its busy loop's counters run out)
DelayTicks          equ       53                  ticks of F$Sleep per count of FS's DelayA (about 0.9 s at 60 Hz)
DeltaShiftedOut     equ       0                   GPt: the deltas after a second whole-byte shift (shifted out: 0)
DispNextStu         equ       $DF7B               FsDispNext's own first instruction, stu <$7B (opcode $DF, operand $7B), put back
DotRecMaxX16        equ       10239-16            DotRec: the light's left end at most one dot (16 sixteenths) left of the last dot
EbRqBase            equ       EbRq+14             EbRq's LOADBASE words (<$42-<$4A and a pad byte), after LOADEYE's item and LOADBASE's header
FifoAskMax          equ       255                 Present: the line engine's FIFO count asked this many times at most before the flip
FifoEmpty           equ       0                   the line engine's FIFO count with every pixel drawn
FirstDot            equ       0                   a row's first dot
Frac16Mask          equ       $0F                 a sixteenths value's fraction bits (x16, y16: a dot's 1/16)
FracCarry           equ       1                   the fraction's carry into the whole part (16.16 dots)
FracDigits          equ       4                   EdgeSet: the slope's fraction, four hex digits (16 bits)
FScrnXUnused        equ       0                   SS.FScrn's X: not used (0)
FsRowEnd            equ       126                 the view row past FS's last projected row (125): MapRow gives it VRows
FsViewHeight        equ       127                 FS's view height in rows (0-126; the view is 256 x 127 units)
FsViewRows          equ       125                 FS's projected view rows (1-125): MapRow's divisor
FsWhite             equ       15                  FS's color 15: white (the horizon line at dusk and night)
FuelTankBit         equ       1                   the fuel tank selection $0735: 0 the left, 1 the right (eora: the other one)
GpEPositive         equ       0                   GpSum: the quotient's bits 23-16 before the borrow (0; sbca CarryOnly makes $FF when negative)
GpExpBase           equ       64                  GPt's exponent <$4D counts from 64 (64 + the shift, as FS's)
GpKLowBase          equ       16                  GpLow: the shift count's base, 16 (the leading zeros of the low byte from it)
GpKMax              equ       23                  GPt: the largest shift count (every value 0: 23)
GpKStart            equ       -2                  GPt: the shift count's start, -2 (the leading zeros of A, less one)
GpKStartLo          equ       6                   GPt with A 0: the shift count's start, 8 - 2 (8 + the leading zeros of B, less one)
GpSumsEnd           equ       GpS+12              the end of GpS: three 32-bit sums of products
GpuCtl256           equ       $02                 Gpu.Ctrl b1: the 320 x 256-color view, 480 lines (clear: 640 x 16)
GpuCtlOff           equ       0                   Gpu.Ctrl with every bit clear: the GPU off
GpuOpClear          equ       $03                 the GPU record CLEAR's opcode: every view row to the color
GpuOpHSplit         equ       $04                 the GPU record HSPLIT's opcode: every view row in two colors split by the line (2 units)
GpuOpPoly           equ       $10                 the GPU record POLY's opcode: a polygon, its vertices in the units after it
GpuTagCont          equ       $FE                 the GPU unit tag CONT: every unit of a record after its first
GpuXFixNVicky       equ       GpuF.FixN*256       SS.Gpu's X: GpuF.FixN, block 0: VICKY's fixed registers (TXT.Base)
GpuXList            equ       GpuF.List*256       SS.Gpu's X: GpuF.List, a series of SS.Gpu functions in one call
GpuXLPk8Vicky       equ       GpuF.LPk8*256+VICKY_BLK SS.Gpu's X: GpuF.LPk8 (a byte at an offset), VICKY's block
GpuXPp              equ       GpuF.Pp*256         SS.Gpu's X: GpuF.Pp, items for the K2's point pipeline
GpuXSceneL          equ       GpuF.SceneL*256     SS.Gpu's X: GpuF.SceneL (the SceneEngine's RAM from a list of ranges)
H3MinMag            equ       $2000               H3Pre: the deltas doubled until their largest magnitude reaches it ($2000-$3FFF)
Half16              equ       8                   half a dot or row in sixteenths: a row's center below its top
HLineWholeRow       equ       $9F00               DrawHLine's A = 159, B = 0: the whole CoCo row (x 0-159)
HwGpuMeshes         equ       2                   HwGpu 2: rc26's GPU draws the view and holds fst's meshes (fsx's GpInit)
HzColors            equ       4                   Horizon's band colors: HzAbove, HzBelow, HzLeft, HzRight
L3End               equ       L3B+4               the end of Line3's ends L3A, L3B (x16, y16: 4 bytes each)
LastDot16           equ       10239               the view's last dot (639) in sixteenths, its last sixteenth (640 x 16 - 1)
LdCountHiBits       equ       $3F                 the line engine's FIFO count (SS.BmLine's GetStat X): bits 13:8 in its high byte
LightDay            equ       1                   vLight: day
LineVerts           equ       2                   a line's vertices: fewer, PFill draws nothing; two, one line
MlRqWords           equ       MlRq+4              MlRq's matrix words, after its item's command, port, in and out bytes
ModeLoadLow         equ       0                   a mode load's position low words ($02CC/$02CE): 0, FS's own placement on the mode's map squares
NegCarry            equ       1                   the 1 that completes a two's-complement negation (coma, comb)
NegMinuend          equ       0                   0 less a value: its negation (EdgeSet's 32-bit slope)
NoBlock             equ       0                   a RAM block variable: 0, no block (PBlk, as XBlk and CodeBlk)
NoCamPointZ         equ       $8000               L3Last's Z with no last camera point (no clipped end has Z $8000)
NoDashBuf2          equ       0                   FspInit's Y: no second dash buffer (the Jr2)
OneDot              equ       1                   one dot: a unit's last dot is the next unit's first less one
OneRow              equ       1                   one row: the last row is the row count less one
OneSixteenth        equ       1                   one sixteenth of a row: LrCut's ends that close are done
OpJmpExt            equ       $7E                 the 6809's JMP extended opcode
OpLdaExt            equ       $B6                 the 6809's LDA extended opcode (FsDispNext+2's lda >$0896, put back)
OvHeightMax         equ       8                   OvEd: the height within 8 m of the kept one is no move (the editor's feet round trip)
OvHeightSpan        equ       16                  twice OvHeightMax: OvEd's height window
OvlF2               equ       1                   vOvlReq 1: CMDS/f2, the editor
PFailNoRam          equ       1                   PFail 1: no RAM blocks (fsp's, the pristine copy's)
PfRminNone          equ       $FF                 PFill's least first row before any edge: $FF, past every row
PgFirstS            equ       1                   PolyG: the first record's second vertex, 1 (vertex 0 begins every record: a fan)
PolyDirect          equ       $20                 a GPU POLY record's mode byte (+0): DIRECT, the color in +1, no material, no depth
PolyMinVerts        equ       3                   the fewest vertices of a polygon (the GPU's POLY)
PolyRecMore         equ       7                   a POLY record's vertices after vertex 0: 7 at most (8 a record)
PosBytes            equ       12                  the aircraft's position <$00-<$0B: X, the height, Z, 32 bits each (bytes)
PrHiMax             equ       4096                PrHi's result for the largest product, 2^24: 2^24 >> 12
PrisBlocks          equ       5                   the dash's pristine copy: 5 consecutive RAM blocks
PrItems             equ       3                   Present's GpuF.List items: PrRec, PrPrb, PrSwp
PrPrbItems          equ       2                   Present's GpuF.List after a failed item: PrPrb, PrSwp
PrRNum              equ       4096                Proj: 4096 / Z's dividend, 2^12 (Z 2048-4095: 1 remainder 4096 - Z)
PrROneHi            equ       $10                 PrR's whole 1: the $1000 of R = 2^24/Z = $1000 + q2 $100 + ..., its high byte
PsgTone0Off         equ       $9F                 the PSG's command byte: tone 0's attenuation 15, off
Q15Half             equ       $4000               one half before a >> 15: a sum of Q15 products rounded
RecBytes            equ       8                   a line-engine record's bytes (SS.BmLine's records, the GPU's units)
Recip5Q10           equ       205                 1/5 in 1/1024 (205): (n x 205) >> 10 = n / 5 for Div80's rows
RowCenterRound      equ       7                   EdgeSet: (y16 + 7) >> 4 = the first row whose center (row x 16 + 8) is at or below y16
ScreenBytesPerRow   equ       80                  bytes in one row of FS's CoCo screen (160 pixels, 4 bits each): a view address is row x 80
SeNoWord            equ       $22FF               SeW's D when the engine stopped without a word: type $22, no record's (SeNext counts a fault)
SeRecEndLess5       equ       $30-5               the END record's type ($30) less the five types SeNext's decas passed
SeRecOpLess5        equ       $20-5               the CPU op's record type ($20) less the five types SeNext's decas passed
SeRecWriteLess5     equ       $10-5               the write-back run's record type ($10) less the five types SeNext's decas passed
SoItems             equ       4                   SeRes's GpuF.List items: SoUp, SoRec, SoLp, SoOut
SpanWholeRow        equ       $FF00               Span's SpR = 255, SpL = 0: the view's whole row
TxBrkBoth           equ       3                   TxBrk b0 and b1: both brakes held (key K)
TxBrkLeft           equ       1                   TxBrk b0: the left brake held (key J)
TxBrkRight          equ       2                   TxBrk b1: the right brake held (key L)
TxBrkSteps          equ       4                   TxBrkT: aerodynamics steps the brakes stay on after a key (0.8 s; the auto-repeat keeps them on)
Unit16              equ       16                  one dot or one bitmap row in sixteenths
ViewBitmap1         equ       1                   SS.FScrn's Y: bitmap 1, the view's second (the first back buffer, fswc's InitBm)
ViewLastX           equ       255                 FS's view's last x unit (x 0-255): a span to the row's right end
ViewLayer           equ       1                   the view's display layer (SS.PScrn's X): layer 1, under the dash's layer 0
ViewMid16           equ       ViewRows*8          the view's middle row in sixteenths (ViewRows x 16 / 2)
VrnFs2Sig           equ       $80                 VRN's FS2 timer signal code (os9.d S$FS2Sig): one tick
VtxBytes            equ       4                   a vertex in VBuf: x16, y16 words (bytes)
WindowBlocks        equ       1                   the FsxBase window ($8000-$9FFF): one 8 KB block (F$MapBlk, F$ClrBlk's count)
WinEndPage          equ       WbWinEnd/256        the scenery window's end ($8000), its page: a list at or past it is not in the window
WinPanelBlocks      equ       2                   the scenery window's second block and the panel's after it ($6000-$9FFF): 2 blocks
WinStartPage        equ       $40                 the scenery window's start ($4000), its page: a list below it is not in the window
X16PerUnit          equ       40                  sixteenths per FS view x unit (640 x 16 / 256)
X2TabEnd            equ       X2Tab+18            the end of X2Tab: three 6-byte entries (base sum, dX entry, dZ entry)
XBufSecond          equ       XBuf+2              XBuf's second crossing (a word after the first)
XUnitFrac           equ       131                 XUnit: T(u) = 2u + (u x 131) >> 8, the 131/256 dot of 640 / 255 dots a view unit over 2
Y16PerRow3          equ       63                  PVtx: three times the sixteenths per FS view row (3 x 164 x 16 / 125)
ZScaleEnd           equ       4096                Proj: Z scaled down below 4096 (2048-4095)
ZScaleMin           equ       2048                Proj: Z scaled up to at least 2048 (2048-4095)

* A raw binary has no os9 directive: a system call is written as SWI2 and its function byte.
                    org       FswLoad

* The view's rows: FS's 125 view rows (1-125) map onto bitmap rows 0 to ViewLast, the same span the K2's GPU draws
* (VIEW_ROWS 164, fsx GpInit), so the view reaches the dash's top edge on both machines (Roger 2026-10-17)
ViewRows            equ       164
ViewLast            equ       ViewRows-1

********************************************************************
* Part 1, FswLoad-$200F: data area FS leaves unused (its fd file ends at $1BFE, its old back buffer starts at
* $2010). Then zeros up to FswBase: PolyMem and RecBuf, which hold nothing yet when WbStart reads the file.

* What fsx uses, at the addresses fs_wb.d gives it
                    jmp       >Mq                 FswMq
                    jmp       >MatLoad            FswMatLoad
SpPosV              zmb       12                  SpPos: the aircraft's position while the eye is in <$00-<$0B
SpNewV              fcb       0                   SpNew: the first frame since S
                    ifne      SpPosV-SpPos
                    error     "fs_wb.d: SpPos"
                    endc
                    ifne      SpNewV-SpNew
                    error     "fs_wb.d: SpNew"
                    endc
                    ifne      SpNewV+1-FswSpOn    (SpOn right after it)
                    error     "fs_wb.d: FswSpOn"
                    endc

********************************************************************
* The spot view (S): the view from a spotter plane, as the Atari ST FS2's SPOT; the camera and the aircraft are
* fsx's (fsx.asm). Matrix (SpotCam) has fsx build the view and put the eye in FS's position <$00-<$0B for the
* sky, the ground and the scenery; the main loop's SwitchOverlay call (Ovl) puts the aircraft's position back
* and has fsx draw the aircraft; its DrawViewAircraftParts call (Parts) draws nothing. fsx's block is
* mapped in the panel's place only meanwhile (XIn / XOut).
SpOn                fcb       0                   the spot view chosen
SpSwap              fcb       0                   the eye is in <$00-<$0B this frame
SpLive              fcb       0                   this frame is the spot view's (Parts)
XBlk                fdb       0                   fsx's RAM block (0: none, no spot view)
SpTick              fcb       0                   timer signals that came while fsx was mapped (a count)

* SpotKey: S or s (TblKeyDispatch): the spot view on or off.
SpotKey             com       SpOn
                    lda       #true
                    sta       SpNew
                    rts

* SpotCam: Matrix in the spot view: fsx's FsxCam (not in the map view, $0139, nor without fsx). All
* registers kept.
SpotCam             pshs      d,x,y,u
                    ldd       XBlk
                    beq       sc8@
                    tst       >vMapView
                    bne       sc8@
                    ldx       #SpIcpt             a tick while the eye is in <$00-<$0B waits for Ovl
                    swi2                          (FS's flight model would move the eye, and Ovl's
                    fcb       F$Icpt              restore would drop the move); installed first, so
                    tst       >vTickPend          no tick lands between the drain and the intercept;
                    beq       sc1@                then the pending ticks, on the aircraft's own position
                    jsr       >FsTimerTicks
sc1@                lbsr      XIn
                    bcs       sc7@
                    jsr       >FsxCam
                    lbsr      XOut
                    lda       #true
                    sta       SpSwap
                    sta       SpLive
                    bra       sc9@
sc7@                lbsr      IcptBack            no spot frame after all: FS's own intercept back
sc8@                jsr       >FsBuildViewMatrix
sc9@                puls      d,x,y,u
                    lbra      VgLoad              the view's geometry, then the matrix to the pipeline

* Ovl: the main loop's SwitchOverlay. After a spot frame's scenery: the aircraft's position back in <$00-<$0B,
* the aircraft drawn by fsx (FsxDraw), then SwitchOverlay. While fsx is mapped in the panel's place, FS's
* timer signal goes to SpIcpt (a tick then would draw instruments into fsx): pending ticks run first, a tick
* that comes meanwhile runs afterwards.
Ovl                 tst       SpSwap
                    lbeq      OvTrf
                    clr       SpSwap
                    ldx       #SpPos
                    ldu       #vPosX
                    ldb       #PosBytes
ov1@                lda       ,x+
                    sta       ,u+
                    decb
                    bne       ov1@
                    ldx       #SpIcpt
                    swi2
                    fcb       F$Icpt
                    tst       >vTickPend
                    beq       ov2@
                    jsr       >FsTimerTicks
ov2@                bsr       XIn
                    bcs       ov3@
                    jsr       >FsxDraw
                    bsr       XOut
ov3@                bsr       IcptBack
ov9@                jmp       >OvEd               the editor's entry (part 2), then FsSwitchOverlay
* IcptBack: FS's own signal intercept back; every tick SpIcpt counted becomes one of FS's pending ticks
* ($0896, which ProcessTimerTicks counts down), each with $0289's countdown as FS's SignalIntercept does it.
* X, U, A clobbered.
IcptBack            ldx       #FsSigIcpt
                    ldu       #vIcptData          FS's own data pointer
                    swi2
                    fcb       F$Icpt
ib1@                tst       SpTick
                    beq       ib9@
                    dec       SpTick
                    inc       >vTickPend
                    lda       >vRepeatTicks
                    beq       ib1@
                    dec       >vRepeatTicks
                    bra       ib1@
ib9@                rts
SpIcpt              cmpb      #VrnFs2Sig          the ticks counted (a long spot frame loses none)
                    bne       si9@
                    inc       SpTick
si9@                rti

* Parts: the main loop's DrawViewAircraftParts call: FS's own (the wing and strut shapes gone from its table, the
* straight-down view's airplane symbol kept); in the spot view none, and no water under the nose (the splashdown
* probe sees the spot view's ground, not the nose's).
Parts               tst       SpLive
                    beq       pa1@
                    clr       SpLive
                    clr       >Probe
                    clr       >Probe+1
                    rts
pa1@                jmp       >FsDrawViewParts

* XIn: fsx's block mapped at FsxBase in place of the panel's; carry set (the panel back) when it cannot be.
* PIn (part 2) maps fsp's block the same way (FspBase is the same window). XOut: the panel's block back. XPan:
* the panel's block mapped (WbAScrn's second block).
* MapIn: X = a RAM block (fsx's, a code block's), mapped there the same way.
XIn                 ldx       XBlk
MapIn               pshs      x
                    ldu       #FsxBase
                    ldb       #WindowBlocks
                    swi2
                    fcb       F$ClrBlk
                    puls      x
                    ldb       #WindowBlocks
                    swi2
                    fcb       F$MapBlk
                    bcs       xi8@
                    cmpu      #FsxBase
                    beq       xi9@
                    ldb       #WindowBlocks       elsewhere: off again
                    swi2
                    fcb       F$ClrBlk
xi8@                bsr       XPan
                    orcc      #Carry
xi9@                rts
XOut                ldu       #FsxBase
                    ldb       #WindowBlocks
                    swi2
                    fcb       F$ClrBlk
XPan                ldb       >WbScrBlks+1        the panel's block: WbAScrn's second
                    incb
                    clra
                    tfr       d,x
                    ldb       #WindowBlocks
                    swi2
                    fcb       F$MapBlk
                    rts

* XInit (Init): fsw's code block (/dd/fs2/fswc) and fsx (/dd/fs2/fsx), each read into a RAM block of its own
* (BlkInit). Without fsx there is no spot view; without fswc no scenery load from f3's menu.
XInit               ldy       #CodeBlk
                    ldx       #CName
                    bsr       BlkInit
                    ldy       #XBlk
                    ldx       #XName
* BlkInit: X = a file name, Y = its block's variable: a RAM block, the file read into it (mapped at FsxBase
* meanwhile); the variable 0 when either fails (carry set).
BlkInit             pshs      x,y
                    ldb       #CodeBlocks
                    swi2
                    fcb       F$AllRAM
                    bcs       xn9@
                    std       [2,s]
                    lda       #READ.
                    ldx       ,s
                    swi2
                    fcb       I$Open
                    bcs       xn8@
                    pshs      a
                    ldx       [3,s]
                    bsr       MapIn
                    bcs       xn7@
                    lda       ,s
                    ldx       #FsxBase
                    ldy       #FsxMax
                    swi2
                    fcb       I$Read
                    pshs      cc
                    bsr       XOut
                    puls      cc
                    bcs       xn7@
                    puls      a
                    swi2
                    fcb       I$Close
                    puls      x,y,pc
xn7@                puls      a
                    swi2
                    fcb       I$Close
xn8@                ldx       [2,s]
                    ldb       #CodeBlocks
                    swi2
                    fcb       F$DelRAM
                    ldy       2,s
                    clr       ,y
                    clr       1,y
                    orcc      #Carry
xn9@                puls      x,y,pc
XName               fcc       "fsx"
                    fcb       C$CR
CName               fcc       "fswc"
                    fcb       C$CR
CodeBlk             fdb       0                   fsw's code block (fswc): its RAM block (0: none)
CodeEnt             fdb       0                   CCall's entry in it

* CCall: X = an entry in fsw's code block (on the stack: the caller's X): the block mapped at FsxBase in place of
* the panel's, the entry called with the caller's registers, the panel back; returns the entry's registers. No
* block: carry set, the entry not run.
CCall               stx       CodeEnt
                    pshs      d,y,u
                    ldx       CodeBlk
CCallX              beq       cc8@                (XCall: X = fsx's block)
                    lbsr      MapIn
                    puls      d,y,u
                    puls      x
                    bcs       cc9@
                    jsr       [CodeEnt]
                    pshs      d,x,y,u,cc
                    lbsr      XOut
                    puls      cc,d,x,y,u,pc
cc8@                puls      d,y,u
                    puls      x
                    orcc      #Carry
cc9@                rts

* XExit (WbExit): fsx's block back to the system. Registers kept.
XExit               pshs      d,x,y,u,cc
                    tst       >HwGpu              rc26's GPU off (its layer blank)
                    beq       xx1@
                    lbsr      GpOff               GPU off, the OS's border back
xx1@                ldx       CodeBlk             fsw's code block too
                    beq       xx2@
                    ldb       #CodeBlocks
                    swi2
                    fcb       F$DelRAM
xx2@                ldx       XBlk
                    beq       xx9@
                    ldb       #CodeBlocks
                    swi2
                    fcb       F$DelRAM
xx9@                puls      d,x,y,u,cc,pc

* SceneLoad, Scrub (FswSceneLoad, FswScrub): in fsw's code block (fswc.asm), through CCall.
SceneLoad           pshs      x
                    ldx       #FcSceneLoad
                    bra       CCall
Scrub               pshs      x
                    ldx       #FcScrub
                    bra       CCall

********************************************************************
* The K2's SceneEngine (wildbits-buildkit/notes/fs2-gpu-stage2.md): FS's scenery display list in hardware. Scene
* (FswScene) replaces the main loop's RunDisplayList: the scenery window (after an area load) and FS's variables
* the list uses go up, GO, and each OUT record is acted on as FS and fsw would act: VTX onto the vertex list
* (PVtx's), FILL (PFill), LINE3 (Line3's record), DOT (Plot's), SLINE (Line's), a write-back run into FS's memory;
* a CPU op is run by FS's own handler (then the variables, and the window when it loaded, go up again: RESUME);
* END: done. FS's pending timer ticks run before the list, as RunDisplayList runs them, and after it (FS's
* dispatcher runs them between ops). FS's own RunDisplayList when there is no engine, with F3's software math or
* with the list outside the window. A fault turns the engine off and FS's list runs the frame again.
* The engine's registers (fs_wb.d Se.*) are reached through grfdrv256's GPU call (SS.Gpu): the uploads in one GpuF.SceneL,
* the OUT words a run at a time into SeBuf (GpuF.SeOut, which writes GO or RESUME first).
SeGo                equ       $01                 commands
SeResume            equ       $03
SeAbort             equ       $03                 control: abort, the OUT FIFO flushed, errors cleared
SeBusy              equ       %01000000           STATUS: running
SeOn                fcb       0                   1: the engine is there (Init's probe)
SeFlt               fcb       0                   DIAGNOSTIC: the engine's faults (each ends that frame's scenery)
SeScOk              fcb       0                   0: the scenery window changed since it went up (SeLoad)
SeCnt               fcb       0                   OUT words in SeBuf not yet taken
SeSp                fdb       0                   the stack while FS's handler runs a CPU op

* Scene: the main loop's RunDisplayList (<$7B = the list). Registers clobbered, as by FS's.
Scene               tst       SeOn
                    beq       sn9@
                    lda       <vDispListPtr       the list in the window
                    cmpa      #WinStartPage
                    blo       sn9@
                    cmpa      #WinEndPage
                    bhs       sn9@
                    lbsr      SeTick
                    lbsr      SeUp
                    clr       SeCnt
                    lbsr      Feed                the records so far go first (the GPU draws in arrival order)
                    lda       #SeGo               GO, with the first OUT words (SeW)
                    sta       >SeCmd
                    bra       SeNext
sn9@                jmp       >FsRunList
* the records (SeNext): VTX, FILL, LINE3 here, the others after SeNext
SeVtx               tstb                          the polygon's first vertex: a new list
                    beq       sv1@
                    clr       >VCnt
sv1@                lbsr      SeW
                    std       >PX16
                    lbsr      SeW
                    std       >PY16
                    lbsr      PvAdd
                    bra       SeNext
SeFill              tfr       b,a
                    lbsr      PFillG
                    bra       SeNext
SeLine3             stb       >PfCol
                    ldx       #L3A                the ends, L3A then L3B
sl1@                lbsr      SeW
                    std       ,x++
                    cmpx      #L3End
                    blo       sl1@
                    ldd       #NoCamPointZ        Line3's last end is no camera point now
                    std       >L3Last+4
                    ldx       #L3A
                    ldy       #L3B
                    lbsr      LRec
* SeNext: the next record: A = its type, B = its parameter
SeNext              bsr       SeW
                    deca
                    beq       SeVtx               $01 VTX
                    deca
                    beq       SeFill              $02 FILL
                    deca
                    beq       SeLine3             $03 LINE3
                    deca
                    beq       sd@                 $04 DOT
                    deca
                    beq       ss@                 $05 SLINE
                    cmpa      #SeRecWriteLess5
                    beq       sw@                 write-back run
                    cmpa      #SeRecOpLess5
                    lbeq      SeOp                CPU op
                    cmpa      #SeRecEndLess5
                    beq       se@                 END
                    ldu       #SeAbort            a fault (or no record): the engine stopped, the fault counted;
                    ldy       #Se.Cnt             no fallback to FS's list (the port replaces it): this frame's
                    ldx       #GpuXLPk8Vicky           scenery ends here and the engine walks the next frame again
                    lbsr      GpuSet
                    inc       SeFlt
                    ldd       >vListStart
                    std       <vDispListPtr
                    lbra      SeTick
sd@                 stb       >PfCol              rc27: the light's point (x16, y16)
                    bsr       SeW
                    std       >PX16
                    bsr       SeW
                    std       >PY16
                    lbsr      DotRec
                    bra       SeNext
ss@                 lbra      SeLine3             rc27: SLINE's ends in sixteenths, as LINE3's
sw@                 incb                          the run's length
                    pshs      b
                    bsr       SeW                 its address
                    tfr       d,x
sw1@                bsr       SeW
                    sta       ,x+
                    dec       ,s
                    beq       sw2@
                    stb       ,x+
                    dec       ,s
                    bne       sw1@
sw2@                puls      b
                    bra       SeNext
se@                 bsr       SeW                 the ops run
* SeTick: FS's pending timer ticks
SeTick              tst       >vTickPend
                    beq       st9@
                    jmp       >FsTimerTicks
st9@                rts

* SeW: the next OUT word to D, when there is one; D = $22FF (a fault) when the engine stopped without one. X, Y,
* U kept. SeBuf taken: the next words from the engine first (SeRef, part 2).
SeW                 tst       SeCnt
                    bne       sw2@
                    lbsr      SeRef
                    bcs       sw9@                none: D = $22FF
sw2@                dec       SeCnt
                    pshs      u
                    ldu       >SePtr
                    ldd       ,u++
                    stu       >SePtr
                    puls      u,pc
sw9@                rts

* SeOp: a CPU op at P: FS's handler runs it, from its dispatcher with the dispatcher's next step (RunDisplayListAt
* + 8, stu <$7B / lda >$0896) turned into a jump to SeBack for the op; then the variables up again and RESUME at
* the list pointer the handler left.
SeOp                bsr       SeW
                    std       <vDispListPtr
                    sts       SeSp
                    lda       #OpJmpExt
                    ldx       #SeBack
                    sta       >FsDispNext
                    stx       >FsDispNext+1
                    jmp       >FsDispList
SeBack              ldd       #DispNextStu        FS's dispatcher back
                    std       >FsDispNext
                    lda       #OpLdaExt
                    sta       >FsDispNext+2
                    stu       <vDispListPtr       as the dispatcher
                    lds       SeSp
                    lbra      SeRes               RESUME (part 2)

* SeUp: the scenery window when it changed (its two blocks), then FS's variables the list uses
* (fpga/sim/scene/ranges.json): one GpuF.SceneL over SeRgY's ranges. Registers clobbered.
SeUp                bsr       SeRgY
                    ldx       #GpuXSceneL
                    lbra      GpuSet
* SeRgY (SeUp, SeRes): Y = the ranges that go up: SeRngW's (the window's blocks, then SeRng) when the window
* changed since it went up, else SeRng
SeRgY               ldy       #SeRng
                    tst       SeScOk
                    bne       su1@
                    inc       SeScOk
                    ldy       #SeRngW
su1@                rts
SeRngW              fdb       $4000,WbWin2,WbWin2,WbWinEnd the window, a range a block; then SeRng
SeRng               fdb       $0000,$00D0,$0100,$01A0,$0200,$0210,$0240,$02B0   $0190-$0193: the horizon list pointer
                    fdb       $0890,$08A0,$0A70,$0AD0,$0CD0,$0CE0,$0DE0,$0E10,0,0 $0A7F-$0A8F: the horizon list (op $09)

* SeLoad (FswSeLoad): LoadDataBlock's open (its ldx #$0250): the scenery window goes up again before the list
SeLoad              clr       SeScOk
                    ldx       #vSceneryPath
                    rts

* OvTrf (Ovl, a frame that is not a spot frame): fsx's traffic (fst's actors, FsxTraffic) when the GPU holds
* the meshes (HwGpu 2), fsx mapped and the timer intercepted as for the spot view. Here, after part 1's pinned
* variables (SeOn).
OvTrf               ldx       XBlk
                    beq       ot9@
                    lda       >HwGpu
                    cmpa      #HwGpuMeshes
                    bne       ot9@
                    ldx       #SpIcpt
                    swi2
                    fcb       F$Icpt
                    tst       >vTickPend
                    beq       ot2@
                    jsr       >FsTimerTicks
ot2@                lbsr      XIn
                    bcs       ot3@
                    jsr       >FsxTraffic
                    lbsr      XOut
ot3@                lbsr      IcptBack
ot9@                jmp       >OvEd               the editor's entry (part 2), then FsSwitchOverlay
* XCall: CCall for an entry in fsx's block (X; on the stack: the caller's X): fsx's GPU keys and view (FsxViewKey,
* FsxGfxKey, FsxGpView). No fsx: carry set, the entry not run.
XCall               stx       >CodeEnt
                    pshs      d,y,u
                    ldx       >XBlk
                    lbra      CCallX
* Present's GpuF.List (part 2): the frame's last records (RecIt), the splashdown probe's color, then SWAP (the
* record port's byte 7, bytes 0-6 as they stand)
PrRec               fcb       GpuK.None,GpuF.Rec,0
                    fdb       RecBuf,0
PrPrb               fcb       GpuK.Get,GpuF.LPk8,VICKY_BLK
                    fdb       Gpu.PCol,0
PrSwp               fcb       GpuK.Set,GpuF.LPk8,VICKY_BLK
                    fdb       Gpu.Rec+7,$08
* FuelKey (FswFuelKey, FS's Ctrl+F; Roger 2026-10-24): the fuel tanks alternated ($0735: 0 the left, 1 the right);
* the dash outlines the selected one
FuelKey             lda       >vFuelTank
                    eora      #FuelTankBit
                    sta       >vFuelTank
                    rts
                    zmb       FswTaxiSpd-2-*      (free: the taxi entries stay at FswTaxiSpd, PBlk before them)
PBlk                fdb       0                   fsp's RAM block (0: none; the dash, part 2's PInit): part 1's last bytes, after every pinned address

* Taxi mode (2026-10-19): FS's ComputeAeroAddSpeed and ComputeAeroPitchRate call FswTaxiSpd / FswTaxiYaw (the work
* is in fswc, through CCall); FS's J, K, L keys call FswBrakeL / FswBrakeB / FswBrakeR, which hold the brakes for
* TxBrkT aerodynamics steps (0.8 s: the key's auto-repeat keeps them on).
TaxiSpdS            pshs      x
                    ldx       #FcTaxiSpd
                    lbra      CCall
TaxiYawS            pshs      x
                    ldx       #FcTaxiYaw
                    lbra      CCall
BrakeL              lda       #TxBrkLeft
                    bra       BrakeSet
BrakeR              lda       #TxBrkRight
                    bra       BrakeSet
BrakeB              lda       #TxBrkBoth
BrakeSet            sta       TxBrk
                    lda       #TxBrkSteps
                    sta       TxBrkT
                    rts
TxBrk               fcb       0
TxBrkT              fcb       0
TxSmart             fcb       1                   smart taxi (FIX MODE page 1): 1 taxi mode, 0 FS's own ground handling

* ModeLd (OvEd, a mode load or save, $020C 1-3): FS's own placement (the mode's map squares, low words 0) through
* FS's SwitchOverlay; then fswc's StartPos with the load's kind: a crash reset ($020C 1) goes back to the game's
* start (fd: 9C, 120 m in, heading 090; fs_wb.d FsStart*), any load into the start's map square (FS's start, modes
* 0, 2, 4) gets the start's low words. Returns SwitchOverlay's registers.
ModeLd              ldd       #ModeLoadLow
                    std       >vModeZLo
                    std       >vModeXLo
                    lda       >vLoadKind          the load's kind, for fswc's StartPos
                    pshs      a
                    jsr       >FsSwitchOverlay
                    pshs      cc,d
                    lda       3,s
                    lbsr      StartPosS           fswc's StartPos: the start's spot (A = the kind)
                    puls      cc,d
                    leas      1,s
                    rts
                    zmb       5                   ViewKey stays at FswViewKey

* ViewKey (FswViewKey, key I): fsx's ViewKey, the GPU view's mode 320 x 240 x 256 colors <-> 640 x 240 x 16.
ViewKey             pshs      x
                    ldx       #FsxViewKey
                    lbra      XCall
* StartPosS (ModeLd): CCall wants the caller's X on top of the stack, so it is entered with a branch, never lbsr.
StartPosS           pshs      x
                    ldx       #FcStartPos
                    lbra      CCall
* GpOff (XExit): the GPU off; the border back as fsx's GpInit found it, when it set the mode indicator (BrdOn),
* through grfdrv256's GPU call (GpuF.FixN). D, X, Y, U clobbered.
GpOff               lbsr      GpClr               Gpu.Ctrl 0 (part 2)
                    tst       BrdOn
                    beq       go9@
                    clr       BrdOn
                    ldx       #GpuXFixNVicky
                    ldy       #BrdRq
                    ldu       #BorderBytes
                    lbra      GpuSet
go9@                rts
                    zmb       1                   BrdSv stays at FswBrdSv
BrdRq               fdb       BORDER_CTRL_REG     GpuF.FixN's request (fsx's GpInit reads into it too): the offset,
                    fcb       7,0                 the mask, 0, then the six bytes
BrdSv               rmb       6                   the OS's border: control, blue, green, red, x size, y size
BrdOn               fcb       0                   1: BrdSv holds them, the border shows the view's state
* GfxKeyS (FswGfxKey, keys D, E): fsx's GfxKey, the dither, the line ribbons on/off.
GfxKeyS             pshs      x
                    ldx       #FsxGfxKey
                    lbra      XCall
LcB                 rmb       4                   LrCut (part 2): the end above, the middle
LcM                 rmb       2
                    ifne      TaxiSpdS-FswTaxiSpd+TaxiYawS-FswTaxiYaw+BrakeL-FswBrakeL+BrakeR-FswBrakeR+BrakeB-FswBrakeB
                    error     "fsw: a taxi entry moved (fs_wb.d)"
                    endc
                    ifne      FuelKey-FswFuelKey
                    error     "fsw: the fuel key moved (fs_wb.d)"
                    endc
                    ifne      ViewKey-FswViewKey
                    error     "fsw: the view key moved (fs_wb.d)"
                    endc
                    ifne      BrdSv-FswBrdSv+BrdOn-FswBrdOn+GfxKeyS-FswGfxKey
                    error     "fsw: the border save or the A/D/E keys moved (fs_wb.d)"
                    endc
                    ifne      TxBrk-FswTxBrk+TxBrkT-FswTxBrkT+TxSmart-FswTxSmart
                    error     "fsw: the brake bytes moved (fs_wb.d)"
                    endc

                    ifgt      *-$2010
                    error     "fsw: part 1 runs into PolyMem"
                    endc
                    zmb       FswBase-*

********************************************************************
* Part 2, FswBase on

* Entry table (FswInit ... in fs_wb.d)
                    jmp       Init
                    jmp       Frame
                    jmp       Present
                    jmp       Row80
                    jmp       HLine
                    zmb       3                   (FillSplitViewRow's entry: gone with FS's sloped-horizon fill)
                    jmp       Plot
                    jmp       Line
                    jmp       EdgePix
                    jmp       KeyMap
                    jmp       Xform3
                    jmp       Xform2
                    jmp       Horizon
                    jmp       SceneLoad
                    jmp       Scrub
                    jmp       PVtx
                    jmp       PFill
                    jmp       Line3
                    jmp       Glyph
                    jmp       Rect
                    jmp       Delay
                    jmp       Pause
Probe               fdb       0                   the splashdown probe (FswProbe): the color word under the nose
EnGPt               jmp       GPt
EnMatrix            jmp       Matrix
EnQuiet             jmp       Quiet
EnOvl               jmp       Ovl
EnParts             jmp       Parts
EnSpotKey           jmp       SpotKey
EnExit              jmp       >ExitAll
EnScene             jmp       Scene
EnSeLoad            jmp       SeLoad
EnDot               jmp       Dot

* FS data used here (DP 0 in FS; extended addressing so a borrowed DP never matters)
FsFill              equ       $0178               fill pattern word (color in each nibble)
FsLineCol           equ       $00EE               line color pattern
FsPolyRow           equ       $00DB               polygon fill: the current row
FsView              equ       $0CD9               the view base FS draws through (0)
FsKey               equ       $009A               PollKeyRead's byte

PolyMem             equ       $2010               FS's old back buffer, free in flight (the overlays use it only
RecBuf              equ       FswRecBuf           while their menus run, between frames): polygon work space, then
RecEnd              equ       FswRecEnd           a batch of records (Feed sends a full one to the engine at once; 64
* again 2026-10-24, from 40: VMax 80 gave the room)
ViewTop             equ       $4000               view addresses lie below; the panel's are the CoCo screen's

* Variables
FrontBm             fdb       0                   bitmap shown on layer 0
BackBm              fdb       1                   bitmap the records go to
FrontBlk            fcb       0                   its first block (the panel copy's destination)
BackBlk             fcb       0
                    zmb       2                   (RecPtr, now pinned at FswRecPtr: the variables after it keep their places)
RecPtr              equ       FswRecPtr           the next record's place (pinned: fswc's text writes there too)
SpRow               fcb       0                   Span's view row, left x, right x, color
SpL                 fcb       0
SpR                 fcb       0
SpC                 fcb       0
SpY1                fcb       0
SpX0                fdb       0                   Span's dots
SpX1                fdb       0
                    zmb       1                   (DrPlane, gone with Feed's own line engine path: the variables after it keep their places)
GdOn                fcb       0                   1: the ground on, the clouds' shadows and the meadow (F8, F2's GROUND
*                                                 TEXTURE); 0: GdCall skips it all
HwPp                fcb       0                   1: the K2's point pipeline is there (rc26; Init's probe)
HwGpu               fcb       0                   1: rc26's GPU draws the view (fsx's GpInit)
GpCtl               fcb       0                   Gpu.Ctrl as last written (FswGpCtl: fsx's GpInit, fswc's keys, GpClr)
Ll                  zmb       18                  FS's long-line op: x, y, z positions, then x, y, z steps (16.8)
PpOk                fcb       0                   (fsx's GpInit clears it; GPtPp sends the eye and base every point)
PqRq                fcb       0,4,3,3             PjPp's GpuF.Pp item: port Q, the camera point in, x16, y16, VU out
                    rmb       6
PqLen               equ       *-PqRq
                    zmb       3                   (the eye and base cache's last bytes: the variables after it keep their places)
AbsM78             fdb       0                   |<$78|, for <$B1 after a 3D point
MqSgn               fcb       0

* The splashdown test (CheckSplashdown) reads the water color under the nose from Probe (the CoCo screen's row
* 97, byte 40 in the original); the span covering that point (row 124, x 128 here) writes its color there.
ProbeRow            equ       124
ProbeX              equ       128

********************************************************************
* Init: after WbAScrn (bitmap 0 shown on layer 0, its block high in WbScrBlks). fswc and fsx loaded first, then
* bitmap 1 (fswc's InitBm: allocated, cleared, HIRES4, the line engine on); it is the first back buffer. No fswc:
* no bitmap 1, carry set. Registers kept.
Init                pshs      d,x,y,u
                    lda       >WbScrBlks
                    sta       FrontBlk
                    lbsr      XInitC              fswc and fsx into their RAM blocks (fsx optional: its failure is not Init's)
                    lbsr      InitBmS             bitmap 1, cleared, HIRES4, the line engine on (fswc's InitBm)
                    lbcs      in9@
                    stb       BackBlk
                    pshs      cc                  fsx's GpInit: the point pipeline's and the SceneEngine's probes, rc26's GPU (Init's carry is WbAScrn's result)
                    ldd       XBlk
                    beq       in8@
                    lbsr      XIn
                    bcs       in8@
                    jsr       >FsxGpInit
                    lbsr      XOut
in8@                puls      cc
                    pshs      cc
                    lbsr      DashBmS             the dash: bitmap 2 on layer 0 over the view (fswc's DashBm)
                    bcs       in8d@               no bitmap 2: no dash (fsp's DMA would go to block 0)
                    sta       >DashBlk
in8c@               lbsr      PInit               the dash (fsp), the panel
in8d@               puls      cc
in9@                puls      d,x,y,u,pc
* InitBmS, DashBmS, HzBgS: fswc's InitBm, DashBm and HzBg through CCall (entered with lbsr: CCall takes the
* caller's X on the stack)
InitBmS             pshs      x
                    ldx       #FcInitBm
                    lbra      CCall
DashBmS             pshs      x
                    ldx       #FcDashBm
                    lbra      CCall
HzBgS               pshs      x
                    ldx       #FcHzBg
                    lbra      CCall

* SetStt: B = code on the display path
SetStt              lda       >FsPath
                    swi2
                    fcb       I$SetStt
                    rts
* GpuSet / GpuGet: grfdrv256's GPU call, SS.Gpu on FS's display path, its SetStat / GetStat functions (X, Y, U
* as SS.Gpu takes them). D clobbered.
GpuSet              ldb       #SS.Gpu
                    bra       SetStt
GpuGet              ldb       #SS.Gpu
                    lbra      GetStt

* The K2's point pipeline (GpuPp.Port: G ground points, P 3D deltas, Q camera points) is reached only through
* grfdrv256's GPU call: a buffer of items, one GpuF.Pp per routine (PpGo). Its commands:
PpLoadM             equ       $01                 9 words: <$68-<$78
PpLoadEye           equ       $02                 3 words: <$0C, <$0E, <$10
PpLoadBase          equ       $03                 5 words: <$42-<$4A and a pad byte

* Matrix: the main loop's BuildViewMatrix, then (pipeline there) the view matrix to it, once a
* frame; in the spot view SpotCam's. All registers kept. MatLoad: the matrix to the pipeline only.
Matrix              pshs      a                   the view's heading to the 16th bit: FS's BuildViewMatrix sets
                    lda       >vHdg+1             only <$1C, its high byte, and left <$1D as it was
                    sta       >vViewHdg+1
                    puls      a
                    tst       SpOn
                    lbne      SpotCam
                    lbsr      VgBuild             BuildViewMatrix, then the view's geometry (ViewGeo)
MatLoad             lbra      MatPp               (the point pipeline's section, part 2)

********************************************************************
* Frame: replaces the main loop's call to UpdateInstrumentMasks. The dash (fsp, 2026-10-17) is the panel on both
* machines: fsp's block mapped in FS's panel block's place with the timer intercepted, as fsx's is for the spot
* view (OvTrf), and FspFrame draws the instruments into bitmap 2 (layer 0, over the view) and restores its dial
* block from the pristine copy. When fsp could not load (PBlk 0) the panel stays blank but for PBar, the red bars
* that say which step refused.
Frame               jsr       >FsUpdInstMasks
                    lbsr      ReqGo               the start's request (fsx)
                    lbsr      FrPre               the engine sound, the tower
                    pshs      x
                    ldd       PBlk
                    bne       fr0d@
                    lbsr      PBar
                    bra       fr9@
fr0d@               ldx       #SpIcpt
                    swi2
                    fcb       F$Icpt
                    tst       >vTickPend
                    beq       fr0a@
                    jsr       >FsTimerTicks
fr0a@               lbsr      PIn
                    bcs       fr0b@
                    lda       >DashBlk            bitmap 2: its block in A, its plane bits in B
                    ldb       #TyVKY_LD_BM2
                    jsr       >FspFrame
                    lbsr      XOut
                    lbsr      PAct                a click's FS routine, with the panel's block back
fr0b@               lbsr      IcptBack
fr9@                puls      x,pc

********************************************************************
* Present: replaces the main loop's CopyBackBufToScreen. The frame's last records go out (Feed; with rc26's GPU in
* the list below), then, once the line engine has drawn every pixel (its FIFO empty: GetStat SS.BmLine's count,
* asked 255 times at most), the back bitmap is shown on layer 0 and the two swap. With rc26's GPU one GpuF.List
* (PrRec): the records, the splashdown probe's color, then SWAP (shown from the next vertical blank; the FIFO paces
* the frames); no bitmap flip: bitmap 0 holds only the panel.
Present             pshs      d,x,y,u
                    tst       HwGpu
                    bne       pr0@
                    lbsr      Feed
pr0@                lda       #FifoAskMax
                    pshs      a                   ,s = the asks left
pr1@                ldb       #SS.BmLine
                    lbsr      GetStt              X = the line engine's FIFO count
                    bcs       pr2@
                    tfr       x,d
                    anda      #LdCountHiBits
                    cmpd      #FifoEmpty
                    beq       pr2@
                    dec       ,s
                    bne       pr1@
pr2@                leas      1,s
                    tst       HwGpu
                    beq       pr3@
                    ldy       #PrRec
                    lbsr      RecIt               the frame's last records into PrRec
                    ldu       #PrItems
                    ldx       #GpuXList
                    lbsr      GpuSet
                    bcc       pr2a@
                    ldy       #PrPrb              an item failed (the records' FIFO wait ran out): the probe and SWAP
                    ldu       #PrPrbItems         all the same, as before the list
                    ldx       #GpuXList
                    lbsr      GpuSet
pr2a@               ldd       PrPrb+GpuL.U        the probe's color
                    lda       #BothNibbles
                    mul
                    tfr       b,a
                    std       Probe
                    puls      d,x,y,u,pc
pr3@                ldx       #ViewLayer          layer 1, under the dash
                    ldy       BackBm
                    ldb       #SS.PScrn
                    lbsr      SetStt
                    ldd       BackBm
                    ldx       FrontBm
                    stx       BackBm
                    std       FrontBm
                    lda       BackBlk
                    ldb       FrontBlk
                    sta       FrontBlk
                    stb       BackBlk
                    puls      d,x,y,u,pc

* The point pipeline's requests for MatPp and XfPp (the point pipeline's section), in the room MatLoad left here
MlRq                fcb       PpLoadM,0,9,0       GpuF.Pp's item: LOADM, port G, the matrix's 9 words in
                    rmb       18
MlLen               equ       *-MlRq
XpRq                fcb       0,2,3,5             GpuF.Pp's item: port P, the 3 deltas in, X, Y, Z, EF, AZ out
                    rmb       10
XpLen               equ       *-XpRq
* SeRes's GpuF.List: the variables up (SeRgY's ranges), the op's records (RecIt), the list pointer RESUME starts
* at, then RESUME with the engine's first OUT words into SeBuf
SoUp                fcb       GpuK.Set,GpuF.SceneL,0
                    fdb       0,0
SoRec               fcb       GpuK.None,GpuF.Rec,0
                    fdb       RecBuf,0
SoLp                fcb       GpuK.Set,GpuF.LPk16,VICKY_BLK
                    fdb       Se.Lp,0
SoOut               fcb       GpuK.Get,GpuF.SeOut,SeResume
                    fdb       SeBuf,SeRoom
* SeRes (SeBack, after FS's handler ran a CPU op): RESUME in one GpuF.List (SoUp): the variables up (SeRgY's
* ranges), the op's records (RecIt; the line engine's through Feed first), the list pointer RESUME starts at (<$7B),
* then RESUME and the engine's first OUT words into SeBuf (SeCnt, SePtr). An item that failed leaves SeBuf empty:
* SeRef asks again, and an engine that never resumed is a fault there.
SeRes               lbsr      SeRgY
                    sty       SoUp+GpuL.Y
                    ldy       #SoRec
                    tst       HwGpu
                    bne       ss1@
                    lbsr      Feed                the line engine's: as they stand
ss1@                lbsr      RecIt
                    ldd       <vDispListPtr
                    std       SoLp+GpuL.U
                    ldd       #SeRoom
                    std       SoOut+GpuL.U
                    ldx       #GpuXList
                    ldy       #SoUp
                    ldu       #SoItems
                    lbsr      GpuSet
                    bcs       ss9@
                    ldd       SoOut+GpuL.U        the words read
                    stb       SeCnt
                    ldd       #SeBuf
                    std       SePtr
ss9@                lbra      SeNext

                    zmb       FswFeed-*           (free: Feed stays at FswFeed)
* Feed: the records so far out. With rc26's GPU (HwGpu) all of them in one GpuF.Rec to its record port, as they
* stand in the 240-line view; in the 256-color view (GpCtl b1: 480 lines, Roger 2026-10-21, RC27) with GpuRec.480:
* the driver doubles each LINE's rows (FS's view is 164 rows, the GPU's 328), their bit 8 in each X word's bit 15,
* a one-row LINE (a span of a fill) one RECT over both rows, any other a LINE twice, two rows thick, as each row of
* the 240-line view shows twice (one row alone thinned the lines to broken dashes); an op of its own (Horizon's
* HSPLIT or CLEAR) as it is. Else (the Jr2) to the line engine on the back bitmap in SS.BmLine batches: a batch
* the FIFO ran short of goes on from the record it stopped at, a record it refused (E$IllArg: out of range,
* E$DevBsy: never done) is passed, any other error ends it. The engine draws on while FS works; Present waits for
* the last pixels. Registers kept.
Feed                pshs      d,x,y,u
                    ldx       #RecBuf
                    tst       HwGpu
                    beq       fd1@
                    ldy       #PrRec              the GPU: the records' count and flags (RecIt), one GpuF.Rec
                    bsr       RecIt
                    tst       ,y
                    bmi       fd9@                none
                    ldx       GpuL.X,y
                    ldu       GpuL.U,y
                    ldy       #RecBuf
                    lbsr      GpuSet
                    bra       fd9@
fd1@                ldd       RecPtr              the line engine: the records from X on
                    pshs      x
                    subd      ,s++
                    beq       fd9@
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    tfr       d,u                 their count
                    ldy       BackBm
                    ldb       #SS.BmLine
                    pshs      x
                    lbsr      SetStt              U = the records drawn
                    puls      x
                    bcc       fd2@
                    cmpb      #E$IllArg
                    beq       fd3@
                    cmpb      #E$DevBsy
                    bne       fd9@
fd3@                leau      1,u                 past the one refused
fd2@                tfr       u,d
                    lda       #RecBytes
                    mul
                    leax      d,x
                    bra       fd1@
fd9@                ldd       #RecBuf
                    std       RecPtr
                    puls      d,x,y,u,pc
* RecIt (Feed, SeRes, Present; the GPU): Y = a GpuF.Rec item (GpuF.List's): the records so far (RecBuf up to
* RecPtr) as its count, GpCtl b1's 480 lines as its flags (GpuRec.480), GpuK.Set; GpuK.None when there are none.
* RecPtr back to RecBuf. D clobbered, Y kept.
RecIt               ldd       RecPtr
                    subd      #RecBuf
                    beq       ri8@
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    std       GpuL.U,y
                    lda       #GpuK.Set
                    ldb       GpCtl               the 256-color view: 480 lines
                    andb      #GpuCtl256
                    beq       ri1@
                    ldb       #GpuRec.480
ri1@                sta       GpuL.K,y
                    stb       GpuL.X+1,y
                    ldd       #RecBuf
                    std       RecPtr
                    rts
ri8@                lda       #GpuK.None
                    sta       GpuL.K,y
                    rts

* GetStt: SetStt's GetStat, B = a GetStat code.
GetStt              lda       >FsPath
                    swi2
                    fcb       I$GetStt
                    rts
* SeRef (SeW): SeBuf refilled from the SceneEngine's OUT FIFO (GpuF.SeOut, SeCmd's GO or RESUME written first),
* asked again while the engine runs and none came: SeCnt the words, SePtr the first; carry and D = $22FF when it
* stopped without one. X, Y, U kept.
SeCmd               fcb       0                   a command for the next GpuF.SeOut (GO, RESUME), 0 none
SePtr               fdb       0                   the next word in SeBuf
SeRef               pshs      x,y,u
sr1@                lda       #GpuF.SeOut
                    ldb       SeCmd
                    tfr       d,x
                    clr       SeCmd
                    ldy       #SeBuf
                    ldu       #SeRoom
                    lbsr      GpuGet              U = the words read, X = STATUS
                    bcs       sr8@
                    tfr       u,d
                    stb       SeCnt
                    bne       sr3@
                    tfr       x,d                 none: still running?
                    bitb      #SeBusy
                    bne       sr1@
sr8@                ldd       #SeNoWord           stopped without one
                    orcc      #Carry
                    puls      x,y,u,pc
sr3@                ldu       #SeBuf
                    stu       SePtr
                    andcc     #^Carry
                    puls      x,y,u,pc
* GpClr (GpOff): Gpu.Ctrl 0, the GPU off (GpCtl too). D clobbered.
GpClr               pshs      x,y,u
                    clr       GpCtl
                    ldu       #GpuCtlOff
                    ldy       #Gpu.Ctrl
                    ldx       #GpuXLPk8Vicky
                    lbsr      GpuSet
                    puls      x,y,u,pc

* Span: view row SpRow, x SpL..SpR, color SpC: one record per bitmap row of that view row; nothing for an empty
* row or for x 0 alone. Registers kept.
Span                pshs      d,x,u
                    lda       SpRow               the splashdown probe
                    cmpa      #ProbeRow
                    bne       sp0@
                    lda       SpL
                    cmpa      #ProbeX
                    bhi       sp0@
                    lda       SpR
                    cmpa      #ProbeX
                    blo       sp0@
                    lda       SpC
                    ldb       #BothNibbles
                    mul
                    tfr       b,a                 the color in all four nibbles
                    std       Probe
sp0@                ldb       SpR
                    beq       sp9@                x 0 alone: no dots
                    bsr       XUnit
                    subd      #OneDot
                    std       SpX1                X1 = T(SpR)-1
                    clra
                    clrb
                    tst       SpL
                    beq       sp1@
                    ldb       SpL
                    decb
                    bsr       XUnit               X0 = T(SpL-1), 0 for x 0
sp1@                std       SpX0
                    ldb       SpRow
                    incb
                    lbsr      MapRow
                    sta       SpY1
                    ldb       SpRow
                    lbsr      MapRow              the first bitmap row
                    cmpa      SpY1
                    bhs       sp9@                an empty row
sp2@                ldu       RecPtr
                    ldx       SpX0
                    stx       ,u
                    ldx       SpX1
                    stx       2,u
                    sta       4,u
                    sta       5,u
                    ldb       SpC
                    stb       6,u
                    clr       7,u
                    leau      8,u
                    stu       RecPtr
                    cmpu      #RecEnd
                    blo       sp3@
                    lbsr      Feed
sp3@                inca
                    cmpa      SpY1
                    blo       sp2@
sp9@                puls      d,x,u,pc

* XUnit: B = u (0-255). D = T(u) = 2u + (u*131)>>8, the first dot of view x u+1 (T(255) = 640).
XUnit               pshs      b
                    lda       #XUnitFrac
                    mul
                    tfr       a,b
                    clra
                    pshs      d                   (u*131)>>8
                    ldb       2,s
                    clra
                    aslb
                    rola                          2u
                    addd      ,s++
                    leas      1,s
                    rts

* Div80: D = a view row's address (row*80). B = the row (A clobbered). (row*5*205)>>10 = row for every row
* below 1024; the 16 x 8 product is formed as (hi*205 + (lo*205)>>8) >> 2.
Div80               lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb                          D = row*5
                    pshs      a                   hi
                    lda       #Recip5Q10
                    mul                           lo*205
                    tfr       a,b
                    clra
                    pshs      d                   (lo*205)>>8
                    lda       2,s
                    ldb       #Recip5Q10
                    mul                           hi*205
                    addd      ,s++
                    leas      1,s
                    lsra
                    rorb
                    lsra
                    rorb
                    rts

* RowOfEnd: U = a view row's end address (row*80+80). B = the row (A clobbered).
RowOfEnd            tfr       u,d
                    subd      #ScreenBytesPerRow
                    bra       Div80

********************************************************************
* The view's primitives. View addresses are below ViewTop. FS's CoCo panel is not drawn (2026-10-20: the dash, fsp,
* is the panel): a fill, span, pixel, line, glyph or rectangle aimed anywhere but the view returns at once, with the
* registers as FS's own routine leaves them where its callers read them.

* Row80: FillRow80's entry. U = the row's end; a view row: one full-width span in FS's fill color, U back 80.
Row80               cmpu      #ViewTop
                    bhs       r89@                the panel
                    pshs      d
                    bsr       RowOfEnd
                    stb       SpRow
                    clr       SpL
                    lda       #ViewLastX
                    sta       SpR
                    lda       >FsFill+1
                    anda      #ColorNibble
                    sta       SpC
                    lbsr      Span
                    puls      d
                    leau      -80,u
                    rts
r89@                leau      -80,u               the panel: not drawn (U back 80, as FillRow80's pushes leave it)
                    rts

* HLine: DrawHLine's entry. X = the row's address, A = right x, B = left x; $9F00 = the whole row.
HLine               cmpx      #ViewTop
                    bhs       hl8@                the panel
                    pshs      d
                    cmpd      #HLineWholeRow
                    bne       hl1@
                    ldd       #SpanWholeRow       the whole row
hl1@                stb       SpL
                    sta       SpR
                    tfr       x,d
                    bsr       Div80
                    stb       SpRow
                    lda       >FsFill+1
                    anda      #ColorNibble
                    sta       SpC
                    lbsr      Span
                    puls      d,pc
hl8@                rts                           the panel: not drawn


* MapRow: B = a view row (0-127). A = its first bitmap row: (row - 1) x VRows / 125, the view's rows now (164 in
* the cockpit, 240 with the dash hidden: FS's center row on the view's, as Proj's); row 0 -> 0; rows 126 on ->
* VRows, so row 125 ends at the view's last. B clobbered.
MapRow              tstb
                    beq       mr1@
                    cmpb      #FsRowEnd
                    bhs       mr2@
                    decb
                    pshs      b
                    ldd       #FsViewRows
                    std       >MATH_DIV_SOR
                    puls      b
                    lda       VRowsV
                    mul
                    std       >MATH_DIV_END
                    nop
                    nop
                    nop
                    nop
                    nop
                    nop
                    ldd       >MATH_DIV_QUOT
                    tfr       b,a
                    rts
mr1@                clra
                    rts
mr2@                lda       VRowsV
                    rts

* Plot: PlotPixel's entry. Y = the base, A = x, B = row; on the view (base 0), one pixel in the line color.
Plot                cmpy      >FsView
                    bne       pl8@                not the view: not drawn
                    cmpb      #FsViewHeight
                    bhs       pl8@
                    pshs      d
                    sta       SpL
                    sta       SpR
                    stb       SpRow
                    lda       >FsLineCol
                    anda      #ColorNibble
                    sta       SpC
                    lbsr      Span
                    puls      d
pl8@                rts

* Dot (FswDot): the DOT op's pixel ($CB53, in place of PlotPixel with FS's view units): the light's camera point
* <$B8 projected exactly (Proj), one 320-dot (two dots) wide and one row tall in the line color, as the K2's GPU
* draws the SceneEngine's DOT. Registers kept.
Dot                 pshs      d,x,y,u
                    ldx       #vEnd1X
                    lbsr      Proj
                    lda       >FsLineCol
                    anda      #ColorNibble
                    bne       dtk@
                    lda       #FsBlack            FS's black (PFillA)
dtk@                sta       PfCol
                    bsr       DotRec
                    puls      d,x,y,u,pc
* DotRec: the light at PX16, PY16 in color PfCol (Dot, the SceneEngine's DOT). Registers kept.
DotRec              pshs      d,x,y
                    ldd       PX16
                    std       L3A
                    cmpd      #DotRecMaxX16
                    bls       dt1@
                    ldd       #DotRecMaxX16
dt1@                addd      #Unit16
                    std       L3B
                    ldd       PY16
                    std       L3A+2
                    std       L3B+2
                    ldd       #NoCamPointZ        no camera point to join
                    std       L3Last+4
                    ldx       #L3A
                    ldy       #L3B
                    lbsr      LRec
                    puls      d,x,y,pc

* Line: DrawLine's entry. Y = the base, X = (x1,y1), D = (x2,y2); on the view, one record in the line color
* through the middles of the two end units. LineC: the same on the view in color SpC (the SceneEngine's SLINE).
Line                cmpy      >FsView
                    bne       LineFs
                    pshs      a
                    lda       >FsLineCol
                    sta       SpC
                    puls      a
LineC               pshs      d,x,u
                    ldu       RecPtr
                    lda       2,s                 x1
                    bsr       DotX
                    std       ,u
                    lda       ,s                  x2
                    bsr       DotX
                    std       2,u
                    ldb       3,s                 y1
                    bsr       DotY
                    sta       4,u
                    ldb       1,s                 y2
                    bsr       DotY
                    sta       5,u
                    lda       SpC
                    anda      #ColorNibble
                    sta       6,u
                    clr       7,u
                    leau      8,u
                    stu       RecPtr
                    cmpu      #RecEnd
                    blo       ln1@
                    lbsr      Feed
ln1@                puls      d,x,u,pc
LineFs              rts                           not the view: not drawn
* DotX: A = view x. D = a dot inside its unit (T(x-1)+1; 0 for x 0).
DotX                tsta
                    beq       dx1@
                    tfr       a,b
                    decb
                    lbsr      XUnit
                    addd      #OneDot
                    rts
dx1@                clrb
                    rts
* DotY: B = view row. A = its first bitmap row, at most ViewLast.
DotY                cmpb      #FsViewHeight
                    blo       dy1@
                    ldb       #FsRowEnd
dy1@                lbsr      MapRow
                    cmpa      #ViewLast
                    bls       dy2@
                    lda       #ViewLast
dy2@                rts

* EdgePix: FillPolyEdgeEnd's end pixel (polygons are the view only). A = x, row FsPolyRow, the fill color.
* FS's own nibble write is skipped: on at FillPolyRetireEdge (X is on the stack, as it expects).
EdgePix             sta       SpL
                    sta       SpR
                    ldb       >FsPolyRow
                    stb       SpRow
                    lda       >FsFill+1
                    anda      #ColorNibble
                    sta       SpC
                    lbsr      Span
                    jmp       >FsPolyRetire

* KeyMap (FswKeyMap, the end of PollKeyRead): fswc's KeyMap (FcKeyMap), through CCall: the K2's and the PS/2
* keyboard's codes made FS2's, the tower's keys taken. Exit as PollKeyRead: B = the key, flags from B.
KeyMap              pshs      x
                    ldx       #FcKeyMap
                    lbra      CCall

* FrPre (Frame): the engine sound, then fswc's tower (twr.asm) once a frame, through CCall (here, past the pinned
* Feed, so Frame keeps its size)
FrPre               equ       *                   (the engine sound: fswc's Tower calls EngSnd first)
Tower               pshs      x
                    ldx       #FcTower
                    lbra      CCall


********************************************************************
* Xform3: the 3D point transform's nine products (FS $3C1D, entered by jmp with FS's DP 0). X = the output, three
* words; the point's deltas <$89/<$8B/<$8D, the view matrix <$68-<$78 (Q15). Each output is the sum of three
* Q15 products in 32 bits from the math block, rounded once. Exit as FS's: X past the
* three words, A = 0 (<$4E), <$4D = <$4E = 0.
Xform3              lbsr      H3Pre               the deltas scaled up (H3)
                    tst       HwPp
                    lbne      XfPp
                    clr       <vPointExp
                    clr       <vXformHalve
* grouped by delta (each in MATH_MUL_A once): S0 = dX m68 + dY m6E + dZ m74, S1 = .. m6A, m70, m76, S2 = .. m6C,
* m72, m78; each sum rounded once (FS's rounds each product twice)
                    pshs      x
                    ldd       H3D
                    std       >MATH_MUL_A
                    ldu       #GpS
                    ldy       #vViewM
                    lbsr      GpP1
                    ldy       #vViewMXY
                    lbsr      GpP1
                    ldy       #vViewMXZ
                    lbsr      GpP1
                    ldd       H3D+2
                    std       >MATH_MUL_A
                    ldu       #GpS
                    ldy       #vViewMYX
                    lbsr      GpP3
                    ldy       #vViewMYY
                    lbsr      GpP3
                    ldy       #vViewMYZ
                    lbsr      GpP3
                    ldd       H3D+4
                    std       >MATH_MUL_A
                    ldu       #GpS
                    ldy       #vViewMZX
                    lbsr      GpP2
                    ldy       #vViewMZY
                    lbsr      GpP2
                    ldy       #vViewMZZ
                    lbsr      GpP2
                    puls      x
                    ldu       #GpS
xf2@                ldd       2,u                 each sum + 1/2, >> 15: the low 16 bits
                    addd      #Q15Half
                    std       2,u
                    ldd       ,u
                    adcb      #CarryOnly
                    adca      #CarryOnly
                    lsl       2,u
                    rolb
                    rola
                    std       ,x++
                    leau      4,u
                    cmpu      #GpSumsEnd
                    blo       xf2@
* <$AF / <$B1: the last product's magnitudes, as FS's MulQ15 leaves them
                    ldd       <vPointDZ
                    bpl       xf3@
                    coma
                    comb
                    addd      #NegCarry
xf3@                std       <vMulA
                    ldd       <vViewMZZ
                    bpl       xf4@
                    coma
                    comb
                    addd      #NegCarry
xf4@                std       <vMulB
                    clra
                    rts

* XfPp: Xform3 on the point pipeline (DELTA mode): the scaled deltas in, the three rounded sums out, the same exit.
XfPp                clr       <vPointExp
                    clr       <vXformHalve
                    ldd       H3D
                    std       XpRq+4
                    ldd       H3D+2
                    std       XpRq+6
                    ldd       H3D+4
                    std       XpRq+8
                    pshs      x
                    ldy       #XpRq
                    ldu       #XpLen
                    lbsr      PpGo
                    puls      x
                    ldd       XpRq+4
                    std       ,x++
                    ldd       XpRq+6
                    std       ,x++
                    ldd       XpRq+8
                    std       ,x++                (EF, the outcode, and AZ, of the scaled delta, read and not used:
                    ldd       <vPointDZ           FS works its own outcode out, and |<$8D| stands for AZ)
                    bpl       xp1@
                    coma
                    comb
                    addd      #NegCarry
xp1@                std       <vMulA
                    ldd       AbsM78
                    std       <vMulB
                    clra
                    rts

* H3Pre (H3): FS's 3D deltas <$89/<$8B/<$8D to H3D scaled up together, until the largest magnitude is $2000-$3FFF
* (none: all 0). A positive scale per point moves neither its projection nor FS's clipping (every clip plane
* passes through the eye), and the camera point keeps its fraction instead of FS's d R / 4 rounded to a word.
* <$89-<$8D unchanged. A, B clobbered.
H3Pre               ldd       <vPointDX
                    std       H3D
                    bpl       h31@
                    coma
                    comb
                    addd      #NegCarry
h31@                std       H3M
                    ldd       <vPointDY
                    std       H3D+2
                    bpl       h32@
                    coma
                    comb
                    addd      #NegCarry
h32@                ora       H3M
                    orb       H3M+1
                    std       H3M
                    ldd       <vPointDZ
                    std       H3D+4
                    bpl       h33@
                    coma
                    comb
                    addd      #NegCarry
h33@                ora       H3M
                    orb       H3M+1
                    beq       h39@
h34@                cmpd      #H3MinMag
                    bhs       h39@
                    aslb
                    rola
                    lsl       H3D+1
                    rol       H3D
                    lsl       H3D+3
                    rol       H3D+2
                    lsl       H3D+5
                    rol       H3D+4
                    bra       h34@
h39@                rts
H3D                 fdb       0,0,0               the scaled deltas
H3M                 fdb       0                   their magnitudes ORed

* Mq: <$AF * <$B1 (signed Q15) -> D, rounded as FS's MulQ15: the magnitudes multiplied (left in <$AF/<$B1, as
* FS leaves them), the product's bits 31-8 rounded on bit 7, shifted left once and rounded on bit 6, the sign
* put back. X, Y, U kept.
Mq                  clr       MqSgn
                    ldd       <vMulA
                    bpl       mq1@
                    coma
                    comb
                    addd      #NegCarry
                    std       <vMulA
                    com       MqSgn
mq1@                std       >MATH_MUL_A
                    ldd       <vMulB
                    bpl       mq2@
                    coma
                    comb
                    addd      #NegCarry
                    std       <vMulB
                    com       MqSgn
mq2@                std       >MATH_MUL_B
                    ldb       >MATH_MUL_P+3
                    aslb                          C = bit 7: the first rounding
                    lda       >MATH_MUL_P+2       (loads keep C)
                    adca      #CarryOnly
                    sta       <vMulQ15Lo
                    ldd       >MATH_MUL_P
                    adcb      #CarryOnly
                    adca      #CarryOnly
                    rol       <vMulQ15Lo
                    rolb
                    rola                          the Q15 shift
                    rol       <vMulQ15Lo          C = bit 6: the second rounding
                    adcb      #CarryOnly
                    adca      #CarryOnly
                    tst       MqSgn
                    beq       mq3@
                    coma
                    comb
                    addd      #NegCarry
mq3@                rts

********************************************************************
* Xform2: the ground point transform's products (FS $3A79, entered by jmp with FS's DP 0). FS has scaled the
* point's deltas <$89/<$8D and the three base sums <$5D/<$60/<$63 (16 bit) together (exponent <$4D); it then
* adds 2 x (high byte x high byte) of each delta and view matrix entry, 7 bits by 7. Here each product is the
* Q15 product of the whole words (the same scale, (d x m) >> 15), added into a 24-bit sum: <$5F/<$62/<$65 =
* bits 23-16, <$5D/<$60/<$63 = bits 15-0, as FS leaves them. FS goes on at its range checks ($3B7E).
* X, Y and U kept.
Xform2              pshs      x,u                 FS's output pointer and U
                    ldx       #X2Tab
x22@                ldu       ,x                  the base sum's address
                    ldd       ,u
                    std       X2Acc
                    clrb
                    tsta
                    bpl       x23@
                    decb
x23@                stb       X2Ext               the sum, sign extended
                    ldd       <vPointDX
                    std       <vMulA
                    ldu       2,x
                    ldd       ,u
                    std       <vMulB
                    bsr       X2Add               + dX x the first entry
                    ldd       <vPointDZ
                    std       <vMulA
                    ldu       4,x
                    ldd       ,u
                    std       <vMulB
                    bsr       X2Add               + dZ x the second
                    ldu       ,x
                    ldd       X2Acc
                    std       ,u
                    lda       X2Ext
                    sta       2,u                 bits 23-16
                    leax      6,x
                    cmpx      #X2TabEnd
                    blo       x22@
                    puls      x,u
                    jmp       >FsXform2Sums

* X2Add: X2Ext:X2Acc += the Q15 product <$AF x <$B1. X kept.
X2Add               lbsr      Mq
                    sta       X2Hi
                    addd      X2Acc
                    std       X2Acc
                    lda       X2Ext
                    adca      #CarryOnly
                    tst       X2Hi
                    bpl       xa1@
                    deca                          a negative product: + $FF
xa1@                sta       X2Ext
                    rts

X2Acc               fdb       0
X2Ext               fcb       0
X2Hi                fcb       0
* Each output: its base sum, the entry for dX, the entry for dZ (FS's pairing)
X2Tab               fdb       $005D,$0068,$0074
                    fdb       $0060,$006A,$0076
                    fdb       $0063,$006C,$0078

********************************************************************
* The exact view: 3D lines, polygons and the sky/ground split from FS's camera-space points, projected straight
* to dots and bitmap rows in sixteenths (FS's own projection rounds to its 256 x 127 view units first).
VMax                equ       80                  vertices a polygon keeps (96 until 2026-10-23, 92 until 2026-10-24: RecBuf's 64)
VBuf                equ       PolyMem             the polygon's vertices: x16, y16 words
EBuf                equ       VBuf+VMax*4         its edges, ESize bytes each
ESize               equ       10
XBuf                equ       EBuf+VMax*ESize     a row's crossings, words
SeBuf               equ       XBuf+VMax*2         the SceneEngine's OUT words (SeW), SeRoom of them, up to RecBuf
SeRoom              equ       (RecBuf-SeBuf)/2
                    ifgt      SeBuf+SeRoom*2-RecBuf
                    error     "fsw: SeBuf runs into RecBuf"
                    endc
PrbY                equ       161                 the splashdown probe: the bitmap row and dot of view row 124, x 128
* (MapRow: 123 x ViewRows / 125; was 144 for the 147-row view)
PrbX                equ       320

PrX                 fdb       0                   Proj: |X|, |Y|, Z scaled; the signs; a count
PrY                 fdb       0
PrZ                 fdb       0
PrSx                fcb       0
PrSy                fcb       0
PrN                 fcb       0
PrR                 fdb       0                   Proj: R = 2^24/Z
Pow2                fdb       1,2,4,8,16,32,64,128,256,512,1024,2048
PX16                fdb       0                   Proj's result: dot x and bitmap row, in sixteenths
PY16                fdb       0
VCnt                fcb       0                   the polygon's vertices so far
PfCol               fcb       0                   the color of PFill, Line3 and SpRec
PfN                 fcb       0
PfE                 fcb       0                   PFill: edges, rows, the current row, the crossings' end
PfRmin              fcb       0
PfRend              fcb       0
SpY                 fcb       0
PfXEnd              fdb       0
VEnd                fdb       0
EsSgn               fcb       0                   EdgeSet's temporaries
EsD                 fcb       0
EsK                 fcb       0
EsAcc               fdb       0
EsOff               fdb       0
EsFr                fdb       0
EsTmp               fdb       0
L3A                 fdb       0,0                 Line3: the last line's ends (x16, y16) ...
L3B                 fdb       0,0
L3Last              fdb       0,0,$8000           ... and its end's camera point (none yet)
HzEdge              rmb       ESize               Horizon: the horizon as an edge
HzAbove             fcb       0                   its colors: above, below, left and right of it
HzBelow             fcb       0
HzLeft              fcb       0
HzRight             fcb       0

* Proj: X = a camera-space point (X, Y, Z words, as FS's <$C1). PX16/PY16 = its dot x and bitmap row in
* sixteenths: x = 320 + 320 X/Z, y = CY - 82 Y/Z (CY FswPrCY, ViewCY's 82: 0-10239, 0 .. 2623; FS's clippers keep
* |X|, |Y| <= Z, so the top 8 rows of FS's view lie above the bitmap).
* |X|, |Y| and Z are scaled together until Z is 2048-4095; R = 2^24/Z on the math block's divider, a hex digit
* at a time; |X| R and |Y| R on its multiplier give the offsets. X, Y kept.
Proj                tst       HwPp
                    lbne      PjPp
                    pshs      u
                    ldd       4,x
                    bgt       pj1@
                    ldd       #CenterX16          Z <= 0 (X = Y = 0 there): the center
                    std       PX16
                    ldd       >FswPrCY
                    std       PY16
                    puls      u,pc
pj1@                std       PrZ
                    ldd       ,x
                    sta       PrSx
                    bpl       pj2@
                    coma
                    comb
                    addd      #NegCarry
pj2@                cmpd      PrZ
                    bls       pj3@
                    ldd       PrZ                 at most Z
pj3@                std       PrX
                    ldd       2,x
                    sta       PrSy
                    bpl       pj4@
                    coma
                    comb
                    addd      #NegCarry
pj4@                cmpd      PrZ
                    bls       pj5@
                    ldd       PrZ
pj5@                std       PrY
                    ldd       PrZ
                    cmpd      #ZScaleMin
                    bhs       pj7@
                    clr       PrN                 a near point: scaled up exactly, by 2^s
pj6@                inc       PrN
                    aslb
                    rola
                    cmpd      #ZScaleMin
                    blo       pj6@
                    std       PrZ
                    ldb       PrN
                    lslb
                    ldu       #Pow2
                    ldd       b,u
                    std       >MATH_MUL_A
                    ldd       PrX
                    std       >MATH_MUL_B
                    ldd       >MATH_MUL_P+2
                    std       PrX
                    ldd       PrY
                    std       >MATH_MUL_B
                    ldd       >MATH_MUL_P+2
                    std       PrY
                    ldd       PrZ
                    bra       pj9@
pj7@                cmpd      #ZScaleEnd
                    blo       pj9@
pj8@                lsr       PrX
                    ror       PrX+1
                    lsr       PrY
                    ror       PrY+1
                    lsra
                    rorb
                    cmpd      #ZScaleEnd
                    bhs       pj8@
pj9@                std       PrZ
                    std       >MATH_DIV_SOR
* R = 2^24/Z = $1000 + q2 $100 + q3 $10 + q4: 4096/Z is 1 remainder 4096 - Z, then three hex digits, each
* remainder x 16 / Z on the divider (Z < 4096: it fits). q2 is 16 for Z = 2048 ($2000).
                    ldd       #PrRNum
                    subd      PrZ
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    std       >MATH_DIV_END
                    nop
                    nop
                    nop
                    nop
                    nop
                    nop
                    ldd       >MATH_DIV_QUOT
                    addb      #PrROneHi
                    stb       PrR
                    ldd       >MATH_DIV_REM
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    std       >MATH_DIV_END
                    nop
                    nop
                    nop
                    nop
                    nop
                    nop
                    ldd       >MATH_DIV_QUOT
                    lslb
                    lslb
                    lslb
                    lslb
                    stb       PrR+1
                    ldd       >MATH_DIV_REM
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    std       >MATH_DIV_END
                    nop
                    nop
                    nop
                    nop
                    nop
                    nop
                    ldd       >MATH_DIV_QUOT
                    orb       PrR+1
                    stb       PrR+1
                    ldd       PrR
                    std       >MATH_MUL_A         R = 2^24/Z (4097-8192)
                    ldd       PrX
                    std       >MATH_MUL_B
                    bsr       PrHi                D = |X| R >> 12 (0-4096)
                    pshs      d
                    aslb
                    rola
                    aslb
                    rola
                    addd      ,s++                x 5
                    lsra
                    rorb
                    lsra
                    rorb                          / 4: 320 |X|/Z in sixteenths
                    tst       PrSx
                    bmi       px1@
                    addd      #CenterX16
                    bra       px2@
px1@                pshs      d
                    ldd       #CenterX16
                    subd      ,s++
px2@                cmpd      #LastDot16
                    bls       px3@
                    ldd       #LastDot16
px3@                std       PX16
                    ldd       PrY
                    std       >MATH_MUL_B
                    bsr       PrHi                D = |Y| R >> 12
                    std       >MATH_MUL_A
                    clra
                    ldb       VRowsV
                    std       >MATH_MUL_B
                    ldd       >MATH_MUL_P+1       x VRows >> 9: 82 (120) |Y|/Z in sixteenths (the view's row scale)
                    lsra
                    rorb
                    tst       PrSy
                    bmi       py1@
                    pshs      d
                    ldd       >FswPrCY            the view's center row, in sixteenths
                    subd      ,s++
                    bra       py2@
py1@                addd      >FswPrCY
py2@                cmpd      VMaxY               its last (signed: above the view's top stays negative, LRec and
                    ble       py3@                EdgeSet cut it there)
                    ldd       VMaxY
py3@                std       PY16
                    puls      u,pc
* PrHi: D = the multiplier's product >> 12 (it is at most 2^24)
PrHi                tst       >MATH_MUL_P
                    bne       ph1@
                    ldd       >MATH_MUL_P+1
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    rts
ph1@                ldd       #PrHiMax
                    rts

* PVtx: a polygon vertex from FS's clipper (jumped to in place of its projection at $4491 and $4322, and of
* PolyBegin/PolyAddVertex): the camera point <$C1/<$C3/<$C5 projected exactly onto the vertex list, which starts
* anew on the polygon's first vertex (<$F4 counting as FS counts). <$C7/<$C8 get the point in view units, as
* FS's projection leaves it there. Registers clobbered, as by FS's.
PVtx                inc       >vPolyVtxCount
                    bne       pv1@
                    clr       VCnt
pv1@                ldx       #vEnd2X
                    lbsr      Proj
                    bsr       PvAdd
                    ldd       #X16PerUnit         x16 / 40 = the view x
                    std       >MATH_DIV_SOR
                    ldd       PX16
                    std       >MATH_DIV_END
                    ldd       PY16                FS's own frame: centered on the view's middle, not ViewCY
                    subd      >FswPrCY
                    addd      #ViewMid16
                    pshs      d
                    aslb
                    rola
                    addd      ,s++
                    tfr       d,x                 y16 x 3 / 63 = the view row (FS's 125: 63 = 3 x 164 x 16 / 125)
                    ldd       >MATH_DIV_QUOT
                    stb       >vEnd2ViewX
                    ldd       #Y16PerRow3
                    std       >MATH_DIV_SOR
                    stx       >MATH_DIV_END
                    nop
                    nop
                    nop
                    nop
                    nop
                    nop
                    ldd       >MATH_DIV_QUOT
                    stb       >vEnd2ViewRow
                    rts
* PvAdd: PX16, PY16 onto the vertex list (full: dropped); also the SceneEngine's VTX (Scene)
PvAdd               ldb       VCnt
                    cmpb      #VMax
                    bhs       pa9@
                    inc       VCnt
                    lda       #VtxBytes
                    mul
                    addd      #VBuf
                    tfr       d,u
                    ldd       PX16
                    std       ,u
                    ldd       PY16
                    std       2,u
pa9@                rts

* PFill: FS's FillPolygon for the 3D view's polygons (jumped to at $4558): the vertex list in the fill color,
* exactly. Each bitmap row whose center lies inside it: the edges' crossings there, sorted, filled in pairs; no
* outline. Two vertices are one line; a polygon that covers no row center is one line along its long axis, so it
* still shows. The list is emptied. Registers clobbered, as by FS's. PFillA: A = the color (the SceneEngine's FILL).
* PFillG: the SceneEngine's FILL (Scene): with the GPU the engine's port has drawn it already, a GPU polygon at the
* view's own rows (SE_YMUL), so the vertex list is only emptied; without the GPU (the Jr2), PFillA's fill.
PFillG              tst       HwGpu
                    beq       PFillA
                    clr       VCnt
                    rts
PFill               lda       >FsFill+1
PFillA              anda      #ColorNibble
                    bne       pfa@
                    lda       #FsBlack            FS's black: color 0 is the sky (the bitmaps' see-through nibble)
pfa@                sta       PfCol
                    ldb       VCnt
                    clr       VCnt
                    cmpb      #LineVerts
                    lblo      pf9@
                    tst       HwGpu               the GPU: three vertices or more, its POLY
                    beq       pf0@
                    cmpb      #PolyMinVerts
                    lbhs      PolyG
pf0@                stb       PfN
                    lda       #VtxBytes
                    mul
                    addd      #VBuf
                    std       VEnd
                    ldx       #VBuf
                    lda       PfN
                    cmpa      #LineVerts
                    bne       pf1@
                    leay      4,x                 two vertices: one line
                    lbra      LRec
pf1@                clr       PfE                 the edges
                    lda       #PfRminNone
                    sta       PfRmin
                    clr       PfRend
                    ldx       #VBuf
                    ldu       #EBuf
pf3@                leay      4,x
                    cmpy      VEnd
                    blo       pf4@
                    ldy       #VBuf
pf4@                lbsr      EdgeSet
                    bcs       pf5@                no row center on it
                    lda       ,u
                    cmpa      PfRmin
                    bhs       pf6@
                    sta       PfRmin
pf6@                lda       1,u
                    cmpa      PfRend
                    bls       pf7@
                    sta       PfRend
pf7@                inc       PfE
                    leau      ESize,u
pf5@                leax      4,x
                    cmpx      VEnd
                    blo       pf3@
                    tst       PfE
                    lbeq      pl0@
                    lda       PfRmin
                    sta       SpY
ps1@                lda       SpY                 each row: its crossings
                    cmpa      PfRend
                    lbhs      pf9@
                    ldu       #EBuf
                    ldy       #XBuf
                    ldb       PfE
                    stb       PfN
ps2@                lda       SpY
                    cmpa      ,u
                    blo       ps3@                not yet
                    cmpa      1,u
                    bhs       ps3@                done
                    ldd       2,u
                    std       ,y++
                    ldd       4,u                 on a row
                    addd      8,u
                    std       4,u
                    ldd       2,u
                    adcb      7,u
                    adca      6,u
                    std       2,u
ps3@                leau      ESize,u
                    dec       PfN
                    bne       ps2@
                    tfr       y,d
                    subd      #XBuf
                    andb      #CrossPairMask      whole pairs
                    addd      #XBuf
                    std       PfXEnd
                    subd      #XBufSecond
                    bls       ps6@                none: nothing to order
                    cmpd      #CrossingBytes
                    bne       psq@
                    ldd       XBuf                one pair (the usual row): in order
                    cmpd      XBuf+2
                    ble       ps6@
                    ldx       XBuf+2
                    stx       XBuf
                    std       XBuf+2
                    bra       ps6@
psq@                ldx       #XBufSecond         more: sorted (insertion)
ps4@                cmpx      PfXEnd
                    bhs       ps6@
                    ldd       ,x
                    leau      ,x
ps5@                cmpu      #XBuf
                    bls       ps5a@
                    cmpd      -2,u
                    bge       ps5a@
                    ldy       -2,u
                    sty       ,u
                    leau      -2,u
                    bra       ps5@
ps5a@               std       ,u
                    leax      2,x
                    bra       ps4@
ps6@                ldx       #XBuf               the pairs
ps7@                cmpx      PfXEnd
                    bhs       ps8@
                    ldd       ,x++
                    std       SpX0
                    ldd       ,x++
                    std       SpX1
                    cmpd      SpX0
                    bge       ps9@
                    addd      SpX0                a pair narrower than a dot: the dot in its middle, so a
                    asra                          sliver shows on every row it crosses
                    rorb
                    std       SpX0
                    std       SpX1
ps9@                lbsr      SpRec
                    bra       ps7@
ps8@                inc       SpY
                    lbra      ps1@
pf9@                rts
* No row center inside: one line between the vertices farthest apart in x (or in y, when that is longer).
pl0@                ldx       #VBuf
                    pshs      x                   ,s the least x16, 2,s the most, 4,s the least y16, 6,s the most
                    pshs      x
                    pshs      x
                    pshs      x
pl1@                ldd       ,x
                    ldu       ,s
                    cmpd      ,u
                    bge       pl2@
                    stx       ,s
pl2@                ldu       2,s
                    cmpd      ,u
                    ble       pl3@
                    stx       2,s
pl3@                ldd       2,x
                    ldu       4,s
                    cmpd      2,u
                    bge       pl4@
                    stx       4,s
pl4@                ldu       6,s
                    cmpd      2,u
                    ble       pl5@
                    stx       6,s
pl5@                leax      4,x
                    cmpx      VEnd
                    blo       pl1@
                    ldx       2,s                 the x extent
                    ldd       ,x
                    ldx       ,s
                    subd      ,x
                    pshs      d
                    ldx       8,s                 the y extent
                    ldd       2,x
                    ldx       6,s
                    subd      2,x
                    cmpd      ,s
                    bgt       pl6@
* a strip 16 dots or wider under a row (a far ground polygon seen edge-on, at the horizon) draws nothing, as FS's
* own fill: drawn as a line it crossed every building in front of it
                    lda       ,s++                the x extent's high byte
                    bne       pl8@
                    puls      x,y                 along x
                    leas      4,s
                    bra       LRec
pl6@                leas      6,s                 along y
                    puls      x,y
                    bra       LRec
pl8@                leas      8,s
                    rts

* LRec: a line record from vertex X to vertex Y (x16, y16) in PfCol, cut at the view's top (LrCut). Registers
* kept.
LRec                pshs      d,x,y,u
                    lda       2,x
                    ora       2,y
                    bpl       lr0@
                    bsr       LrCut               an end above the view
                    bcs       lr1@
lr0@                ldu       RecPtr
                    ldd       ,x
                    bsr       Sh4
                    std       ,u
                    ldd       ,y
                    bsr       Sh4
                    std       2,u
                    ldd       2,x
                    bsr       Sh4
                    stb       4,u
                    ldd       2,y
                    bsr       Sh4
                    stb       5,u
                    lda       PfCol
                    sta       6,u
                    clr       7,u
                    leau      8,u
                    stu       RecPtr
                    tst       HwGpu               the GPU: the line goes now, in its list order with the engine's
                    bne       lr2@                faces (the SceneEngine port's triangles do not wait in RecBuf)
                    cmpu      #RecEnd
                    blo       lr1@
lr2@                lbsr      Feed
lr1@                puls      d,x,y,u,pc
* Sh4z: D >> 4, 0 when D is negative. Sh4: D >> 4
Sh4z                tsta
                    bpl       Sh4
                    clra
                    clrb
                    rts
Sh4                 lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    rts
* LrCut: LRec's line with an end above the view (y16 < 0): carry set when both are (nothing to draw); else X =
* the end in the view, Y = LcA, the point where the line meets row 0: halved toward the end above (LcB) until
* the two are a sixteenth apart. D clobbered.
LrCut               lda       2,x
                    anda      2,y
                    lsla
                    bcs       lc8@                both above: carry set
                    tst       2,x
                    bpl       lc1@
                    exg       x,y                 X = the end in the view
lc1@                ldd       ,x
                    std       LcA
                    ldd       2,x
                    std       LcA+2
                    ldd       ,y
                    std       LcB
                    ldd       2,y
                    std       LcB+2
lc2@                ldd       LcA+2
                    subd      LcB+2               (1 or more)
                    subd      #OneSixteenth
                    beq       lc4@                a sixteenth apart: LcA on row 0
                    ldd       LcA                 the middle
                    addd      LcB
                    rora
                    rorb
                    std       LcM
                    ldd       LcA+2
                    addd      LcB+2
                    asra
                    rorb
                    tsta
                    bmi       lc3@
                    std       LcA+2               in the view: the new LcA
                    ldd       LcM
                    std       LcA
                    bra       lc2@
lc3@                std       LcB+2               above: the new LcB
                    ldd       LcM
                    std       LcB
                    bra       lc2@
lc4@                ldy       #LcA                (carry clear: SUBD left no borrow)
lc8@                rts
LcA                 rmb       4                   (LcB, LcM: at part 1's end)

* SpRec: a span record, dots SpX0-SpX1 (clamped to 0-639; nothing when empty) on bitmap row SpY in PfCol. The
* span over the nose (row PrbY, dot PrbX) also puts its color where the splashdown test reads it. Registers kept.
SpRec               pshs      d,u
                    ldd       SpX0
                    bpl       sr1@
                    clra
                    clrb
                    std       SpX0
sr1@                ldd       SpX1
                    cmpd      #LD.MaxX4
                    ble       sr2@
                    ldd       #LD.MaxX4
                    std       SpX1
sr2@                cmpd      SpX0
                    blt       sr9@
                    lda       SpY
                    cmpa      #PrbY
                    bne       sr3@
                    ldd       SpX0
                    cmpd      #PrbX
                    bgt       sr3@
                    ldd       SpX1
                    cmpd      #PrbX
                    blt       sr3@
                    lda       PfCol
                    ldb       #BothNibbles
                    mul
                    tfr       b,a
                    std       Probe
sr3@                ldu       RecPtr
                    ldd       SpX0
                    std       ,u
                    ldd       SpX1
                    std       2,u
                    lda       SpY
                    sta       4,u
                    sta       5,u
                    lda       PfCol
                    sta       6,u
                    clr       7,u
                    leau      8,u
                    stu       RecPtr
                    cmpu      #RecEnd
                    blo       sr9@
                    lbsr      Feed
sr9@                puls      d,u,pc

* EdgeSet: the edge from vertex X to vertex Y (x16, y16) for a scan, into U (ESize bytes): +0 the first row whose
* center it crosses, +1 the row after its last, +2/+4 its x there (16.16 dots), +6/+8 its slope (16.16 dots a
* row, signed). Carry set when it crosses no row center (+0 and +1 are still set). X, Y, U kept.
EdgeSet             pshs      x,y
                    ldd       2,x
                    cmpd      2,y
                    bls       es1@
                    exg       x,y                 X = the upper end
es1@                ldd       2,x
                    addd      #RowCenterRound
                    lbsr      Sh4z
                    stb       ,u                  rows whose center (row + 1/2) lies in [upper, lower), from row 0
                    ldd       2,y                 (an end above the view's top: the first center is row 0's, up to
                    addd      #RowCenterRound     136 sixteenths below it)
                    lbsr      Sh4z
                    stb       1,u
                    cmpb      ,u
                    lbls      es9@
                    ldd       2,y
                    subd      2,x
                    std       >MATH_DIV_SOR       dy (sixteenths)
                    clr       EsSgn
                    ldd       ,y
                    subd      ,x
                    bpl       es2@
                    com       EsSgn
                    coma
                    comb
                    addd      #NegCarry
es2@                std       >MATH_DIV_END       |dx| / dy: the slope's whole dots ...
                    lda       ,u
                    ldb       #Unit16
                    mul
                    addd      #Half16
                    subd      2,x
                    stb       EsD                 (the first center's distance below the upper end, 0-15)
                    ldd       >MATH_DIV_QUOT
                    std       6,u
                    clr       EsAcc
                    clr       EsAcc+1
                    lda       #FracDigits
                    sta       EsK
                    ldd       >MATH_DIV_REM
es3@                aslb                          ... and four hex digits of its fraction
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    std       >MATH_DIV_END
                    ldd       EsAcc
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    addd      >MATH_DIV_QUOT
                    std       EsAcc
                    ldd       >MATH_DIV_REM
                    dec       EsK
                    bne       es3@
                    ldd       EsAcc
                    std       8,u
                    ldd       6,u                 the offset to the first center: |slope| x d/16
                    std       >MATH_MUL_A
                    ldb       EsD                 (B written last, as everywhere: then the product is read)
                    clra
                    std       >MATH_MUL_B
                    ldd       >MATH_MUL_P+1       whole part x d, >> 4
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    std       EsOff
                    ldb       >MATH_MUL_P+3
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    orb       EsOff+1
                    stb       EsOff+1
                    lda       >MATH_MUL_P+3
                    anda      #Frac16Mask
                    lsla
                    lsla
                    lsla
                    lsla
                    clrb
                    std       EsFr
                    ldd       8,u                 fraction x d, >> 4
                    std       >MATH_MUL_A
                    ldb       EsD
                    clra
                    std       >MATH_MUL_B
                    ldd       >MATH_MUL_P+1
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    std       EsTmp
                    ldb       >MATH_MUL_P+3
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    orb       EsTmp+1
                    lda       EsTmp
                    addd      EsFr
                    std       EsFr
                    bcc       es4@
                    ldd       EsOff
                    addd      #FracCarry
                    std       EsOff
es4@                ldb       1,x                 the upper end's x in 16.16
                    andb      #Frac16Mask
                    lslb
                    lslb
                    lslb
                    lslb
                    tfr       b,a
                    clrb
                    std       4,u
                    ldd       ,x
                    lbsr      Sh4
                    std       2,u
                    tst       EsSgn
                    bmi       es5@
                    ldd       4,u                 + the offset
                    addd      EsFr
                    std       4,u
                    ldd       2,u
                    adcb      EsOff+1
                    adca      EsOff
                    std       2,u
                    bra       es8@
es5@                ldd       4,u                 - the offset, and the slope negated
                    subd      EsFr
                    std       4,u
                    ldd       2,u
                    sbcb      EsOff+1
                    sbca      EsOff
                    std       2,u
                    ldd       #NegMinuend
                    subd      8,u
                    std       8,u
                    ldd       #NegMinuend
                    sbcb      7,u
                    sbca      6,u
                    std       6,u
es8@                andcc     #^Carry
                    puls      x,y,pc
es9@                orcc      #Carry
                    puls      x,y,pc

* Line3: FS's DrawLine for a 3D line (at $2C5F; FS has clipped both ends): the ends projected exactly from their
* camera points (<$B8.. and <$C1..), one record in the line color. A start equal to the last line's end reuses
* that projection. The ends stay in L3A/L3B: DrawSkyGround's line is the horizon (Horizon). Registers kept.
Line3               pshs      d,x,y,u
                    lda       >FsLineCol
                    anda      #ColorNibble
                    bne       l30@
                    lda       #FsBlack            FS's black (PFillA)
l30@                sta       PfCol
                    ldd       >vEnd1X
                    cmpd      L3Last
                    bne       l31@
                    ldd       >vEnd1Y
                    cmpd      L3Last+2
                    bne       l31@
                    ldd       >vEnd1Z
                    cmpd      L3Last+4
                    bne       l31@
                    ldd       L3B                 the last end
                    std       L3A
                    ldd       L3B+2
                    std       L3A+2
                    bra       l32@
l31@                ldx       #vEnd1X
                    lbsr      Proj
                    ldd       PX16
                    std       L3A
                    ldd       PY16
                    std       L3A+2
l32@                ldx       #vEnd2X
                    lbsr      Proj
                    ldd       PX16
                    std       L3B
                    ldd       PY16
                    std       L3B+2
                    ldd       >vEnd2X
                    std       L3Last
                    ldd       >vEnd2Y
                    std       L3Last+2
                    ldd       >vEnd2Z
                    std       L3Last+4
                    ldx       #L3A
                    ldy       #L3B
                    lbsr      LRec
                    puls      d,x,y,u,pc

********************************************************************
* The point pipeline's section: every use of the K2's point pipeline goes through grfdrv256's GPU call, one
* GpuF.Pp per routine with a buffer of items (each: a command, the port, the words in, the words out, then the
* words; the ones out come back over them).
* PpGo: Y = the items, U = their length in bytes: one GpuF.Pp. X, D clobbered.
PpGo                ldx       #GpuXPp
                    lbra      GpuGet
* GPtPp's items
EbRq                fcb       PpLoadEye,0,3,0     GpuF.Pp's items: LOADEYE, port G, <$0C, <$0E, <$10 in
                    rmb       6
                    fcb       PpLoadBase,0,5,0    LOADBASE, port G, <$42-<$4A and a pad byte in
                    zmb       10
GpRq                fcb       0,0,2,4             port G, x and z in, the three camera words and the exponent out
                    rmb       8
EbLen               equ       *-EbRq

* MatPp (MatLoad): the view matrix (<$68-<$79) to the pipeline, and |<$78| to AbsM78. All registers kept.
MatPp               tst       HwPp
                    beq       mp9@
                    pshs      d,x,y,u
                    ldx       #vViewM
                    ldy       #MlRqWords
mp1@                ldd       ,x++
                    std       ,y++
                    cmpx      #vViewMEnd
                    blo       mp1@
                    ldy       #MlRq
                    ldu       #MlLen
                    bsr       PpGo
                    ldd       >vViewMZZ
                    bpl       mp2@
                    coma
                    comb
                    addd      #NegCarry
mp2@                std       AbsM78
                    puls      d,x,y,u
mp9@                rts

* PjPp: Proj on the point pipeline (the same PX16, PY16; its view units are not used here). X, Y, U kept.
PjPp                pshs      x,y,u
                    ldd       ,x
                    std       PqRq+4
                    ldd       2,x
                    std       PqRq+6
                    ldd       4,x
                    std       PqRq+8
                    ldy       #PqRq
                    ldu       #PqLen
                    bsr       PpGo
                    ldd       PqRq+4
                    std       PX16
                    ldd       PqRq+6
                    std       PY16
                    ldd       PqRq+8              VU
                    puls      x,y,u,pc

* GPtPp: GPt on the point pipeline: the eye (<$0C, <$0E, <$10) and the base sums (<$42-<$4A) loaded, then x, z
* in, all in one call; the three camera words to X (X left on the last, as Xform2Sums leaves it) and the exponent
* to <$4D. A point whose delta overflows 16 bits goes the math block's way (FS's overflow paths).
GPtPp               leay      4,u
                    sty       <vDispListPtr
                    lda       <vPointExp
                    sta       >vPrevPointExp
                    pshs      x,y                 the output, FS's Y
                    ldd       <vEyeX
                    std       EbRq+4
                    ldd       <vEyeY
                    std       EbRq+6
                    ldd       <vEyeZ
                    std       EbRq+8
                    ldx       #vBaseSumX
                    ldy       #EbRqBase
gb@                 ldd       ,x++
                    std       ,y++
                    cmpx      #vBaseSumZLo
                    blo       gb@
                    lda       ,x                  <$4A and the pad byte (0, EbRq's)
                    sta       ,y
                    pulu      d                   x, z
                    std       GpRq+4
                    pulu      d
                    std       GpRq+6
                    pshs      u
                    ldy       #EbRq
                    ldu       #EbLen
                    lbsr      PpGo
                    puls      u
                    puls      x
                    ldd       GpRq+4
                    std       ,x++
                    ldd       GpRq+6
                    std       ,x++
                    ldd       GpRq+8
                    std       ,x
                    ldd       GpRq+10             A = the exponent, B = the flags (b0 overflow)
                    puls      y
                    sta       <vPointExp
                    lsrb
                    bcs       go@
                    rts
go@                 leax      -4,x                the math block's way
                    leau      -4,u
                    lda       >vPrevPointExp
                    sta       <vPointExp
                    jmp       GPtMath

* GPt: FS's ground-point transform (GroundPoint, $D9C5; U = the point's x, z words in the display list, X = where
* the camera point goes; DP 0, as FS calls it). As FS's: the deltas from the eye (dX = x - <$0C, dZ = z - <$10)
* and the area's three base sums (<$42-$4A, 24 bit: the eye's height through the view matrix) are scaled up
* together as far as they go (each kept within -$4000..$3FFF; exponent <$4D counting from 64, FS's last one saved
* in $0271), then each camera coordinate = its base sum + (dX m1 + dZ m2) / 2^15; FS's Xform2Sums scales the
* sums back into 16 bits and stores them at X. FS shifted the five values a bit a step, testing all five each
* time; here the count is found at once from the bit length of the values folded to magnitudes, and the six
* products come from the math block, summed in 32 bits and rounded once. A delta that overflows 16 bits goes
* FS's own way (GroundPtOvX, GroundPtOvZ). X is kept for Xform2Sums.
GpW                 rmb       3                   the folded values ORed (24 bit)
GpDelta             rmb       3                   a delta as 24 bit (low byte 0)
GpK                 fcb       0                   the shift count
GpS                 rmb       12                  the three 32-bit sums of products
GpQ                 fdb       0
GpE                 fcb       0
GpBE                fcb       0
GPt                 tst       HwPp
                    lbne      GPtPp
GPtMath             leay      4,u
                    sty       <vDispListPtr
                    ldd       <vBaseSumX          the base sums
                    std       <vGPtSumX
                    lda       <vBaseSumXLo
                    sta       <vGPtSumX+2
                    ldd       <vBaseSumY
                    std       <vGPtSumY
                    lda       <vBaseSumYLo
                    sta       <vGPtSumY+2
                    ldd       <vBaseSumZ
                    std       <vGPtSumZ
                    lda       <vBaseSumZLo
                    sta       <vGPtSumZ+2
                    lda       <vPointExp
                    sta       >vPrevPointExp
                    lda       #GpExpBase
                    sta       <vPointExp
                    pulu      d
                    subd      <vEyeX
                    bvc       gp1@
                    jmp       >FsGPtOvX
gp1@                std       <vPointDX
                    pulu      d
                    subd      <vEyeZ
                    bvc       gp2@
                    jmp       >FsGPtOvZ
gp2@                std       <vPointDZ
* the shift count: k = 23 - the bit length of the ORed values folded to magnitudes (FS's loop stops at the shift
* that would take a value out of -$4000..$3FFF). The 16-bit words decide it unless all of them fold to 0; then
* the low bytes do too (GpLow).
                    ldd       <vPointDX
                    bpl       f1@
                    coma
                    comb
f1@                 std       GpW
                    ldd       <vPointDZ
                    bpl       f2@
                    coma
                    comb
f2@                 ora       GpW
                    orb       GpW+1
                    std       GpW
                    ldd       <vGPtSumX
                    bpl       f3@
                    coma
                    comb
f3@                 ora       GpW
                    orb       GpW+1
                    std       GpW
                    ldd       <vGPtSumY
                    bpl       f4@
                    coma
                    comb
f4@                 ora       GpW
                    orb       GpW+1
                    std       GpW
                    ldd       <vGPtSumZ
                    bpl       f5@
                    coma
                    comb
f5@                 ora       GpW
                    orb       GpW+1
                    tsta
                    beq       f7@
                    ldb       #GpKStart           k = the leading zeros of A, less one
f6@                 incb
                    lsla
                    bcc       f6@
                    bra       GpSet
f7@                 tstb
                    lbeq      GpLow
                    lda       #GpKStartLo         A = 0: k = 8 + the leading zeros of B, less one
f8@                 inca
                    lslb
                    bcc       f8@
                    tfr       a,b
GpSet               stb       GpK
                    addb      #GpExpBase
                    stb       <vPointExp
                    ldb       GpK                 whole bytes first
                    cmpb      #ByteBits
                    blo       gp6@
                    lda       <vPointDX+1
                    clrb
                    std       <vPointDX
                    lda       <vPointDZ+1
                    std       <vPointDZ
                    ldd       <vGPtSumX+1
                    std       <vGPtSumX
                    clr       <vGPtSumX+2
                    ldd       <vGPtSumY+1
                    std       <vGPtSumY
                    clr       <vGPtSumY+2
                    ldd       <vGPtSumZ+1
                    std       <vGPtSumZ
                    clr       <vGPtSumZ+2
                    ldb       GpK
                    subb      #ByteBits
                    stb       GpK
                    cmpb      #ByteBits
                    blo       gp6@
                    ldd       #DeltaShiftedOut    a second byte (the deltas are 0 by now)
                    std       <vPointDX
                    std       <vPointDZ
                    lda       <vGPtSumX+1
                    sta       <vGPtSumX
                    clr       <vGPtSumX+1
                    lda       <vGPtSumY+1
                    sta       <vGPtSumY
                    clr       <vGPtSumY+1
                    lda       <vGPtSumZ+1
                    sta       <vGPtSumZ
                    clr       <vGPtSumZ+1
                    ldb       GpK
                    subb      #ByteBits
                    stb       GpK
gp6@                lda       GpK                 then single bits
                    beq       GpMul
gp7@                lsl       <vPointDX+1
                    rol       <vPointDX
                    lsl       <vPointDZ+1
                    rol       <vPointDZ
                    lsl       <vGPtSumX+2
                    rol       <vGPtSumX+1
                    rol       <vGPtSumX
                    lsl       <vGPtSumY+2
                    rol       <vGPtSumY+1
                    rol       <vGPtSumY
                    lsl       <vGPtSumZ+2
                    rol       <vGPtSumZ+1
                    rol       <vGPtSumZ
                    deca
                    bne       gp7@
                    bra       GpMul
* GpLow: every word folds to 0 (the values are 0 or -1 in their high 16 bits): the 24-bit values decide
GpLow               clr       GpW
                    clr       GpW+1
                    clr       GpW+2
                    clr       GpDelta+2
                    ldd       <vPointDX
                    std       GpDelta
                    ldy       #GpDelta
                    lbsr      GpFold
                    ldd       <vPointDZ
                    std       GpDelta
                    lbsr      GpFold
                    ldy       #vGPtSumX
                    bsr       GpFold
                    ldy       #vGPtSumY
                    bsr       GpFold
                    ldy       #vGPtSumZ
                    bsr       GpFold
                    ldb       #GpKLowBase         the leading zeros of the low byte, from 16
                    lda       GpW+2
                    beq       gl3@                all zero (FS would shift without end): 23
                    decb
                    decb
gl1@                incb
                    lsla
                    bcc       gl1@
                    lbra      GpSet
gl3@                ldb       #GpKMax
                    lbra      GpSet
* the products: S = dX m1 + dZ m2 for each output (FS's pairs: $68/$74, $6A/$76, $6C/$78), signed from the
* unsigned multiplier (minus b << 16 for a < 0, minus a << 16 for b < 0)
GpMul               ldd       <vPointDX
                    std       >MATH_MUL_A
                    ldu       #GpS
                    ldy       #vViewM
                    bsr       GpP1
                    ldy       #vViewMXY
                    bsr       GpP1
                    ldy       #vViewMXZ
                    bsr       GpP1
                    ldd       <vPointDZ
                    std       >MATH_MUL_A
                    ldu       #GpS
                    ldy       #vViewMZX
                    lbsr      GpP2
                    ldy       #vViewMZY
                    lbsr      GpP2
                    ldy       #vViewMZZ
                    lbsr      GpP2
                    ldu       #GpS
                    ldy       #vGPtSumX
                    lbsr      GpSum
                    ldy       #vGPtSumY
                    lbsr      GpSum
                    ldy       #vGPtSumZ
                    lbsr      GpSum
                    jmp       >FsXform2Sums

* GpFold: the 24-bit value at Y folded to its magnitude (complemented when negative), ORed into GpW. Y kept.
GpFold              ldd       ,y
                    bpl       gf1@
                    coma
                    comb
                    ora       GpW
                    orb       GpW+1
                    std       GpW
                    lda       2,y
                    coma
                    bra       gf2@
gf1@                ora       GpW
                    orb       GpW+1
                    std       GpW
                    lda       2,y
gf2@                ora       GpW+2
                    sta       GpW+2
                    rts

* GpP1: the 32-bit product dX (<$89, in MATH_MUL_A) x the word at Y into ,U; U on 4.
GpP1                ldd       ,y
                    std       >MATH_MUL_B
                    ldd       >MATH_MUL_P+2
                    std       2,u
                    ldd       >MATH_MUL_P
                    tst       <vPointDX
                    bpl       p11@
                    subd      ,y
p11@                tst       ,y
                    bpl       p12@
                    subd      <vPointDX
p12@                std       ,u
                    leau      4,u
                    rts

* GpP3: the 32-bit product dY (<$8B, in MATH_MUL_A) x the word at Y added into ,U; U on 4 (Xform3).
GpP3                ldd       ,y
                    std       >MATH_MUL_B
                    ldd       >MATH_MUL_P+2
                    addd      2,u
                    std       2,u
                    ldd       >MATH_MUL_P
                    adcb      1,u
                    adca      ,u
                    tst       <vPointDY
                    bpl       p31@
                    subd      ,y
p31@                tst       ,y
                    bpl       p32@
                    subd      <vPointDY
p32@                std       ,u
                    leau      4,u
                    rts

* GpP2: the 32-bit product dZ (<$8D, in MATH_MUL_A) x the word at Y added into ,U; U on 4.
GpP2                ldd       ,y
                    std       >MATH_MUL_B
                    ldd       >MATH_MUL_P+2
                    addd      2,u
                    std       2,u
                    ldd       >MATH_MUL_P
                    adcb      1,u
                    adca      ,u
                    tst       <vPointDZ
                    bpl       p21@
                    subd      ,y
p21@                tst       ,y
                    bpl       p22@
                    subd      <vPointDZ
p22@                std       ,u
                    leau      4,u
                    rts

* GpSum: the sum at U rounded and shifted right 15 (bits 23-0 of the quotient), plus the base sum's word at Y
* (sign-extended): the low 16 bits back at Y, bits 23-16 at Y+2, as Xform2Sums takes them. U on 4.
GpSum               ldd       2,u
                    addd      #Q15Half
                    std       2,u
                    ldd       ,u
                    adcb      #CarryOnly
                    adca      #CarryOnly
                    lsl       2,u                 the low word's bit 15 in
                    rolb
                    rola                          D = the quotient's bits 15-0, C = its sign
                    std       GpQ
                    lda       #GpEPositive
                    sbca      #CarryOnly
                    sta       GpE                 its bits 23-16
                    ldb       ,y
                    sex
                    sta       GpBE
                    ldd       GpQ
                    addd      ,y
                    std       ,y
                    lda       GpE
                    adca      GpBE
                    sta       2,y
                    leau      4,u
                    rts

********************************************************************
* Horizon: DrawSkyGround once its horizon line is drawn and visible (jumped to; returns from DrawSkyGround).
* First $0192, which the scenery calls (op 9) after setting white to draw the horizon over its ground: kept at
* dawn, dusk and night ($013F 2, 4), 0 in daylight. Then the sky and the ground, exactly, from the line's ends
* (L3A -> L3B, the last line drawn; FS clips it to the view, so its ends lie on the view's border and the rows
* past them are one color). FS's color <$D7 lies right of A -> B looking up the screen (in level flight A is
* the left end and <$D7 the ground: FS fills from the view's bottom with it), <$D9 left of it, as FS's swaps
* choose them. Rows above both ends, below both, and the band between: each band row split where the line
* crosses its center.
FsLight             equ       $013F               1 day, 2 dawn/dusk, 4 night (UpdateDaylight)
FsHorizonList       equ       $0192
Horizon             lda       >FsLight
                    cmpa      #LightDay
                    bne       hz1@                not daylight
                    clra
                    clrb
                    bra       hz2@
hz1@                ldd       #vHorizonList
hz2@                std       >FsHorizonList
                    lda       >vPatAboveHz+1      the two colors: A = <$D9's, B = <$D7's
                    anda      #ColorNibble
                    ldb       >vPatBelowHz+1
                    andb      #ColorNibble
                    pshs      d
                    ldd       L3B                 above: <$D9's when A -> B runs right
                    subd      L3A
                    bgt       hz3@
                    lda       1,s
                    sta       HzAbove
                    lda       ,s
                    sta       HzBelow
                    bra       hz4@
hz3@                lda       ,s
                    sta       HzAbove
                    lda       1,s
                    sta       HzBelow
hz4@                ldd       L3B+2               right of the crossing: <$D9's when A -> B runs down
                    subd      L3A+2
                    bgt       hz5@
                    lda       1,s
                    sta       HzRight
                    lda       ,s
                    sta       HzLeft
                    bra       hz6@
hz5@                lda       ,s
                    sta       HzRight
                    lda       1,s
                    sta       HzLeft
hz6@                leas      2,s
                    tst       HwGpu               the GPU: one HSPLIT for the whole view
                    lbne      HzGpu
                    lbsr      HzSky
                    ldx       #L3A
                    ldy       #L3B
                    ldu       #HzEdge
                    lbsr      EdgeSet             the band (empty for a flat line)
                    clr       SpY
                    lda       HzAbove
                    sta       PfCol
hz7@                lda       SpY                 above
                    cmpa      ,u
                    bhs       hz8@
                    lbsr      HzRow
                    bra       hz7@
hz8@                cmpa      1,u                 the band
                    bhs       hz10@
                    ldd       2,u                 the crossing, rounded
                    tst       4,u
                    bpl       hz9@
                    addd      #OneDot
hz9@                pshs      d
                    subd      #OneDot
                    std       SpX1
                    clra
                    clrb
                    std       SpX0
                    lda       HzLeft
                    sta       PfCol
                    lbsr      SpRec
                    puls      d
                    std       SpX0
                    ldd       #LD.MaxX4
                    std       SpX1
                    lda       HzRight
                    sta       PfCol
                    lbsr      SpRec
                    inc       SpY
                    ldd       4,u
                    addd      8,u
                    std       4,u
                    ldd       2,u
                    adcb      7,u
                    adca      6,u
                    std       2,u
                    lda       SpY
                    bra       hz8@
hz10@               lda       HzBelow
                    sta       PfCol
hz11@               lda       SpY                 below
                    cmpa      VRowsV
                    bhs       hz12@
                    lbsr      HzRow
                    bra       hz11@
hz12@               lda       >FsLight            dusk and night: the horizon line in white over the split, from
                    cmpa      #LightDay           the line's own ends (the CoCo's scenery drew it through $0192;
                    beq       hz13@               the ST lists in sf.wildbits do not), the scenery drawn over it
                    pshs      x,y
                    lda       #FsWhite
                    sta       PfCol
                    ldx       #L3A
                    ldy       #L3B
                    lbsr      LRec
                    puls      x,y
hz13@               rts
* HzSky (Horizon without the GPU): the sky is color 0, the bitmap's see-through nibble, which shows VICKY's
* background: set to the RGB of FS's sky color (vSkyCol: day, dawn, dusk, night) whenever that changes (fswc's
* HzBg, through grfdrv256's GPU call), then the band colors equal to it become 0. D, X, Y, U clobbered.
HzSky               lda       >vSkyCol
                    anda      #ColorNibble
                    cmpa      HzSkyNow
                    beq       hk1@
                    sta       HzSkyNow
                    lbsr      HzBgS
hk1@                ldx       #HzAbove
                    ldb       #HzColors
hk2@                lda       ,x
                    cmpa      HzSkyNow
                    bne       hk3@
                    clr       ,x
hk3@                leax      1,x
                    decb
                    bne       hk2@
                    rts
HzSkyNow            fcb       $FF                 the sky color the background holds ($FF: none yet)
* HzGpu (Horizon, with the GPU): sky and ground in one record, the GPU's HSPLIT ($04): every view row filled with
* two colors split by the line A-B (the horizon's ends, L3A and L3B), at the row's center; the high nibble's color
* where s = 2dy (x - X0) - dx (2y + 1 - 2 Y0) > 0: right of a line running down the screen, left of one running up,
* above a flat one running right. The rows are the view's (480-line rows in 480 lines, their bit 8 in each X
* word's bit 15, as Feed's LINEs). A line of no length: CLEAR ($03) in the color above. Then the white line at dusk
* and night, as before.
HzGpu               lda       GpCtl               480 lines?
                    anda      #GpuCtl256
                    sta       HzM4
                    clra
                    ldb       VRowsV
                    tst       HzM4
                    beq       hg1@
                    lslb
                    rola
hg1@                subd      #OneRow
                    std       HzMax               the last row
                    lbsr      Feed                the records so far: room for the record's two units
                    ldu       RecPtr
                    ldx       #L3A
                    lbsr      HzPt
                    std       ,u                  X0 (dots, 640 across)
                    ldd       HzR
                    std       2,u                 Y0 (the view's rows)
                    std       HzY0
                    ldx       #L3B
                    lbsr      HzPt
                    std       4,u                 X1
                    ldd       HzR
                    std       8,u                 Y1 (the second unit)
                    clr       6,u
                    clr       12,u
                    clr       13,u
                    clr       14,u
                    lda       #GpuTagCont         the record goes on
                    sta       15,u
                    ldd       8,u
                    subd      HzY0                dy (rows)
                    bgt       hg3@
                    blt       hg4@
                    ldd       4,u                 flat: dx (dots)
                    cmpd      ,u
                    bhi       hg5@                dx > 0: color A above
                    blo       hg6@                dx < 0: below
                    clr       4,u                 no length: CLEAR in the color above (the depth left as it is)
                    lda       HzAbove
                    sta       6,u
                    lda       #GpuOpClear
                    sta       7,u
                    leau      8,u
                    bra       hg9@
hg3@                lda       HzRight             dy > 0: color A right
                    ldb       HzLeft
                    bra       hg7@
hg4@                lda       HzLeft              dy < 0: left
                    ldb       HzRight
                    bra       hg7@
hg5@                lda       HzAbove
                    ldb       HzBelow
                    bra       hg7@
hg6@                lda       HzBelow
                    ldb       HzAbove
hg7@                std       10,u                color A (where s > 0), color B
                    lda       #GpuOpHSplit        HSPLIT
                    sta       7,u
                    leau      16,u
hg9@                stu       RecPtr
                    lbsr      GdCall              the textured ground over the split (the K2's fsx)
                    lbra      hz12@
* GdCall (HzGpu, the sky and ground split in RecBuf): fsx's FsxGround, the textured ground over it, with the GPU's
* meshes (HwGpu 2): the split fed first (the GPU draws in arrival order); FS's timer intercepted meanwhile, as for
* the traffic (OvTrf: a tick while fsx sits in the panel's place would draw instruments into it). GdOn 0 (the
* start, F8, F2's GROUND TEXTURE): none of it. Registers kept.
GdCall              pshs      d,x,y,u
                    tst       GdOn
                    beq       gc9@
                    ldx       XBlk
                    beq       gc9@
                    lda       HwGpu
                    cmpa      #HwGpuMeshes
                    bne       gc9@
                    lbsr      Feed
                    ldx       #SpIcpt
                    swi2
                    fcb       F$Icpt
                    tst       >vTickPend
                    beq       gc2@
                    jsr       >FsTimerTicks
gc2@                lbsr      XIn
                    bcs       gc3@
                    jsr       >FsxGround
                    lbsr      XOut
gc3@                lbsr      IcptBack
gc9@                puls      d,x,y,u,pc
* HzPt: X = an end (x16, y16) -> D = its dot (0-639); HzR = its row (0 to HzMax).
HzPt                ldd       2,x                 the row: y16 / 16 (240 lines) or / 8 (480)
                    bpl       hp1@
                    clra
                    clrb
hp1@                lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    tst       HzM4
                    bne       hp2@
                    lsra
                    rorb
hp2@                cmpd      HzMax
                    bls       hp3@
                    ldd       HzMax
hp3@                std       HzR
                    ldd       ,x                  the dot: x16 / 16
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    rts
HzM4                fcb       0
HzMax               fdb       0
HzR                 fdb       0
HzY0                fdb       0
* HzRow: row SpY full width in PfCol; SpY + 1. U kept.
HzRow               pshs      u                   (the record written here: a full row needs no clamping)
                    ldu       RecPtr
                    ldd       #FirstDot
                    std       ,u
                    ldd       #LD.MaxX4
                    std       2,u
                    lda       SpY
                    sta       4,u
                    sta       5,u
                    cmpa      #PrbY
                    bne       hr1@
                    lda       PfCol               the splashdown probe's row
                    ldb       #BothNibbles
                    mul
                    tfr       b,a
                    std       Probe
hr1@                lda       PfCol
                    sta       6,u
                    clr       7,u
                    leau      8,u
                    stu       RecPtr
                    cmpu      #RecEnd
                    blo       hr2@
                    lbsr      Feed
hr2@                inc       SpY
                    puls      u,pc

********************************************************************
* Glyph, Rect: DrawGlyph's and FillRect's entries: on FS's own screen's view (U, Y = its base) fswc's Glyph and
* Rect (FcGlyph, FcRect, through CCall; moved there 2026-10-21 for fsw's room): FS's text and fills on its own
* view rows. Else DrawGlyph's or FillRect's own first instruction (the CoCo panel's text and covers: not drawn).
Glyph               cmpu      >FsScreen
                    beq       gy1@
                    rts
gy1@                pshs      x
                    ldx       #FcGlyph
                    lbra      CCall
Rect                cmpy      >FsScreen
                    beq       rt1@
                    rts
rt1@                pshs      x
                    ldx       #FcRect
                    lbra      CCall

* Delay: FS's DelayA (A = the count: a busy loop of A x 3 x 65536 that lasted about A x 0.9 s on the CoCo, and
* follows a message FS has just drawn): the message shown (Present), then A x 53 ticks of F$Sleep (again after
* each signal: /FTDD's wake FS five times a second). Exit as DelayA: X = Y = 0, A and B kept.
Delay               lbsr      Quiet
                    pshs      d
                    lbsr      Present
                    lda       ,s
                    ldb       #DelayTicks
                    mul
                    tfr       d,x
dl1@                leax      ,x
                    beq       dl9@
                    swi2                          X = the ticks left when a signal woke it
                    fcb       F$Sleep
                    bcc       dl1@
dl9@                puls      d
                    ldx       #DelayAExit
                    ldy       #DelayAExit
                    rts

* Pause: ShowPausedMsg's end: "PAUSED." drawn (DrawTextString; X and U set by FS) and shown at once.
Pause               lbsr      Quiet
                    jsr       >FsDrawTextString
                    lbra      Present

********************************************************************
* Quiet: both SIDs' volume 0 and the PSG's tone 0 off (pause, messages, menus, the exit); the next frame's EngSnd
* and Morse ident (twr.asm) bring them back. All registers kept.
Quiet               pshs      d
                    lda       #SidModeVol
                    clrb
                    bsr       SidW
                    ldb       #PsgTone0Off
                    stb       >PSG_BOTH_PORT
                    puls      d,pc

* SidW: B to register A of both SIDs (the select port, then the data port; the core queues the writes).
SidW                ora       #SID_SELECT_BOTH
                    sta       >SID_SELECT_PORT
                    stb       >SID_DATA_PORT
                    rts


********************************************************************



                    ifgt      RecEnd-FswBase
                    error     "fsw: the record batch runs into fsw"
                    endc

                    ifne      Ll-FswLl
                    error     "fs_wb.d: FswLl"
                    endc
                    ifne      HwGpu-FswHwGpu
                    error     "fs_wb.d: FswHwGpu"
                    endc
                    ifne      GpCtl-FswGpCtl
                    error     "fs_wb.d: FswGpCtl"
                    endc
                    ifne      FrontBm-FswFrontBm
                    error     "fs_wb.d: FswFrontBm"
                    endc
                    ifne      SeFlt-FswSeFlt
                    error     "fs_wb.d: FswSeFlt"
                    endc
                    ifne      EnGPt-FswGPt+EnMatrix-FswMatrix+EnQuiet-FswQuiet+EnOvl-FswOvl
                    error     "fs_wb.d: FswGPt .. FswOvl"
                    endc
                    ifne      EnParts-FswParts+EnSpotKey-FswSpotKey+EnExit-FswExit+EnScene-FswScene+EnSeLoad-FswSeLoad
                    error     "fs_wb.d: FswParts .. FswSeLoad"
                    endc
                    ifne      EnDot-FswDot
                    error     "fs_wb.d: FswDot"
                    endc
                    ifne      GdOn-FswGdOn
                    error     "fs_wb.d: FswGdOn"
                    endc
                    ifne      SeOn-FswSeOn
                    error     "fs_wb.d: FswSeOn"
                    endc
                    ifne      Feed-FswFeed
                    error     "fs_wb.d: FswFeed"
                    endc
                    ifne      HwPp-FswHwPp
                    error     "fs_wb.d: FswHwPp"
                    endc
                    ifne      PpOk-FswPpOk
                    error     "fs_wb.d: FswPpOk"
                    endc
                    ifne      Probe-FswProbe
                    error     "fs_wb.d: FswProbe"
                    endc
* fsp, the dashboard (K2, 2026-10-17): PInit (Init) takes a RAM block, reads /dd/fs2/fsp into it and runs
* FspInit (the dash art into bitmap 2 and the pristine copy, its palette). Without the file, or when FspInit
* refuses, PBlk is 0 and Frame draws PBar. PIn maps the block at FspBase as XIn does fsx's (carry set: the panel
* is back). After every pinned address, so none of them moves (PBlk is in part 1).
PIn                 ldu       #FspBase
                    ldb       #WindowBlocks
                    swi2
                    fcb       F$ClrBlk
                    ldx       PBlk
                    ldb       #WindowBlocks
                    swi2
                    fcb       F$MapBlk
                    bcs       pi8@
                    cmpu      #FspBase
                    beq       pi9@
                    ldb       #WindowBlocks       elsewhere: off again
                    swi2
                    fcb       F$ClrBlk
pi8@                lbsr      XPan
                    orcc      #Carry
pi9@                rts
* PFail says which step refused: 1 no RAM blocks (fsp's, the pristine copy's four), 2 /dd/fs2/fsp not opened,
* 3 its block not mapped, 4 not read, 5 FspInit refused (its own step in PStep: 1 /dd/fs2/dash.bm not opened,
* 2 a short file or a read error, 3 a DMA copy, 4 the CLUT write, 5 the bitmap configure). PBar draws them on
* the dash plane.
PInit               lda       #PFailNoRam
                    sta       >PFail
                    ldb       #CodeBlocks
                    swi2
                    fcb       F$AllRAM
                    bcs       pn9@
                    std       PBlk
                    ldb       #PrisBlocks         the pristine copy: 5 consecutive blocks (the dash's rows at the bitmap's offsets - $A000, the NAV2 spot's faces at 76,800 - $A000)
                    swi2
                    fcb       F$AllRAM
                    bcs       pn8@
                    stb       >PrisBlk
                    inc       >PFail
                    lda       #READ.
                    ldx       #PName
                    swi2
                    fcb       I$Open
                    bcs       pn8@
                    inc       >PFail
                    pshs      a
                    bsr       PIn
                    bcs       pn7@
                    inc       >PFail
                    lda       ,s
                    ldx       #FspBase
                    ldy       #FspMax
                    swi2
                    fcb       I$Read
                    bcs       pn6@
                    inc       >PFail
                    ldy       #NoDashBuf2         Y = the second dash buffer: bitmap 1 on the K2 (the GPU draws
                    tst       HwGpu               the view), none on the Jr2
                    beq       pn5@
                    clra
                    ldb       BackBlk
                    tfr       d,y
pn5@                clra
                    ldb       >PrisBlk
                    tfr       d,u                 U = the pristine copy's first block
                    lda       >DashBlk            A = bitmap 2's
                    ldx       PBlk
                    jsr       >FspInit
                    bcc       pn6@
                    stb       >PStep
                    orcc      #Carry
pn6@                pshs      cc
                    lbsr      XOut
                    puls      cc
                    bcs       pn7@
                    clr       >PFail
                    puls      a
                    swi2
                    fcb       I$Close
                    rts
pn7@                puls      a
                    swi2
                    fcb       I$Close
pn8@                ldd       #NoBlock
                    std       PBlk
pn9@                rts
PName               fcs       "/dd/fs2/fsp"
PFail               fcb       0
PStep               fcb       0                   fsp's own step when PFail is 5
PrisBlk             fcb       0                   the dash's pristine copy: the first of its five RAM blocks
DashBlk             fcb       0                   bitmap 2's first block

* PBar (Frame, no dash): fswc's PBar through CCall (the two red bars of PFail and PStep at the bottom of the dash
* plane), when there is a bitmap 2 to draw on. D clobbered.
PBar                tst       >DashBlk            no bitmap 2 (it could not be allocated): nothing to draw on
                    beq       pb9@
                    pshs      x
                    lda       >PFail
                    ldb       >PStep
                    ldx       #FcPBar
                    lbra      CCall
pb9@                rts

* PAct (Frame, after fsp): the action a dash click left in FspAct (fs_wb.d), run here because FS's routines
* redraw its CoCo panel in the $8000 block, which is fsp's while fsp runs. A = FspActA, B = FspActB.
* The dash's clicks are off (fsp's Clicks is not called) and FspAct ($2010) is the polygon work space, so its byte
* is whatever the last polygon left there: PAct ran an FS panel routine from it every frame (magnetos, the trim
* marker's XOR into VICKY's window, flaps). Off with the clicks; the dispatch (PaTab: FsDrawEngSw .. FsSetMagnetos)
* is in git (wb/flightsim2 before 2026-10-18) for when they come back, with FspAct moved out of PolyMem.
PAct                clr       >FspAct
                    rts

* OvEd (Ovl, every overlay switch): F1's editor (overlay 1, the module f2) asked for. The editor runs inside FS's
* SwitchOverlay and rebuilds the position from its own coarse fields on the way out (ApplyEditsAndExit: the map
* squares, the low words from $02CC/$02CE, the height through feet). So: the position (<$00-<$0B: X, the height, Z,
* 32 bits each) is kept before, and put back exactly after, unless the editor moved the aircraft (another map
* square, or the height more than 8 m off). The low words also go to $02CC/$02CE for an edited position.
* Otherwise FS's SwitchOverlay as it is (part 1 is full).
* Only the interactive editor ($020C = 0): FS's mode loads go through the same overlay ($020C 1-3: the start, a
* crash reset, a mode recalled) and place the aircraft from the mode's map squares with low words $02CC/$02CE = 0,
* as FS always had them (their positions are designed so); those keep 0 here (ModeLd, part 1, which then puts
* the aircraft back on the game's start after a crash reset).
OvEd                lda       >vOvlReq
                    cmpa      #OvlF2
                    bne       oe9@
                    tst       >vLoadKind
                    beq       oe0@
                    lbra      ModeLd              a mode load or save: FS's own (part 1), a crash then the start
oe0@                lda       >vModeNum           the mode number: a mode recalled in the editor is not undone
                    sta       OvMode
                    ldd       >vPosZ+2
                    std       >vModeZLo
                    ldd       >vPosX+2
                    std       >vModeXLo
                    ldx       #vPosX              the position as it is
                    ldu       #OvPos
                    ldb       #PosBytes
oe1@                lda       ,x+
                    sta       ,u+
                    decb
                    bne       oe1@
                    jsr       >FsSwitchOverlay    the editor, until it is left
                    pshs      cc,d,x,u
                    ldd       #ModeLoadLow        FS's later mode loads: low words 0 again
                    std       >vModeZLo
                    std       >vModeXLo
                    lda       >vModeNum           no mode recalled
                    cmpa      OvMode
                    bne       oe8@
                    ldd       >vPosX              the same map square (X, Z high words)
                    cmpd      OvPos
                    bne       oe8@
                    ldd       >vPosZ
                    cmpd      OvPos+8
                    bne       oe8@
                    ldd       >vAlt+1             the height within 8 m (the editor's feet round trip)
                    subd      OvPos+5
                    addd      #OvHeightMax
                    cmpd      #OvHeightSpan
                    bhi       oe8@
                    ldx       #OvPos              not moved: the position back, exactly
                    ldu       #vPosX
                    ldb       #PosBytes
oe2@                lda       ,x+
                    sta       ,u+
                    decb
                    bne       oe2@
oe8@                puls      cc,d,x,u,pc
oe9@                jmp       >FsSwitchOverlay
* ExitAll (FswExit, WbExit's first call; B = the exit status, kept): everything FS's run took back to the system,
* so the next run finds the memory and the bitmaps free: bitmaps 1 and 2 (SS.FScrn; FS's quit freed bitmap 0),
* fsp's block, the dash's pristine copy (4 blocks), WbAScrn's two blocks, the clouds' and the panel's (the panel's unmapped first:
* F$ClrBlk only frees the slot, and F$Exit releases only what is still mapped), the sound off, then fsx's block (XExit).
ExitAll             pshs      d,x,y,u
                    ldx       #FScrnXUnused
                    ldy       #ViewBitmap1
                    ldb       #SS.FScrn
                    lbsr      SetStt
                    ldx       #FScrnXUnused
                    ldy       #DashBitmap
                    ldb       #SS.FScrn
                    lbsr      SetStt
                    ldx       PBlk
                    beq       ea1@
                    ldb       #CodeBlocks
                    swi2
                    fcb       F$DelRAM
ea1@                clra
                    ldb       >PrisBlk
                    beq       ea2@
                    tfr       d,x
                    ldb       #PrisBlocks
                    swi2
                    fcb       F$DelRAM
ea2@                ldu       #WbWin2             the window's second block and the panel's out of the map
                    ldb       #WinPanelBlocks
                    swi2
                    fcb       F$ClrBlk
                    clra
                    ldb       >WbScrBlks+1        then WbAScrn's three blocks freed
                    beq       ea3@
                    tfr       d,x
                    ldb       #AScrnBlocks
                    swi2
                    fcb       F$DelRAM
ea3@                puls      d,x,y,u
                    lbsr      Quiet               the engine and the Morse tone off
                    lbra      XExit
* XInitC: XInit for Init: fsx (the spot view, the GPU's meshes) is optional, so its failure is not Init's.
XInitC              ldd       #false              the list draws its own buildings until fst's meshes take over
                    std       >FsBdFlag
                    lbsr      XInit
                    andcc     #^Carry
                    rts
OvPos               rmb       12                  the position when the editor was asked for
OvMode              rmb       1                   the mode number then

* VgBuild (Matrix), VgLoad (SpotCam): FS's matrix built, then ViewGeo (and MatLoad).
VgBuild             jsr       >FsBuildViewMatrix
                    bra       ViewGeo
VgLoad              bsr       ViewGeo
                    lbra      MatLoad
* ViewGeo: the view's geometry once a frame, after the matrix (Roger 2026-10-21). The cockpit view: 164 rows, the
* projection centered on row 82, so the clip box (|Y/Z| <= 1, FS's and the SceneEngine's) covers every row; the
* matrix as FS builds it. The dash hidden (the spot view, SpOn, or the sky view, key 4, $0139): the whole screen,
* 240 rows centered on row 120, the matrix's y column times 82/120 so 120 rows a unit show the same angles as 82
* did and the clip box still meets the view's edges. A change of the two: fswc's ViewSet (the rows, the center, the
* GPU's and the SceneEngine's view). The meshes keep their own matrices and take the center (fsx's ProjU). All
* registers kept.
VgPK                equ       22391               82 / 120 (Q15)
ViewGeo             pshs      d,x,y,u
                    clra
                    tst       SpOn
                    bne       vg0@
                    tst       >vMapView
                    beq       vg1@
vg0@                inca                          the dash hidden: the whole screen
vg1@                cmpa      VMode
                    beq       vg6@
                    sta       VMode
                    lbsr      ViewSet
vg6@                tst       VMode
                    beq       vg9@                the cockpit: the matrix as it is
                    ldu       #vViewM             the matrix
vg8@                ldd       2,u                 the whole screen: y x 82 / 120
                    std       <vMulA
                    ldd       #VgPK
                    std       <vMulB
                    lbsr      Mq
                    std       2,u
                    leau      6,u
                    cmpu      #vViewMEnd
                    blo       vg8@
vg9@                puls      d,x,y,u,pc
* ViewSet: A = VMode: fswc's ViewSet (the rows, the center), through CCall; then, with the GPU, fsx's GpView (its
* view and the SceneEngine's), through XCall. Registers clobbered.
ViewSet             bsr       vs1@
                    tst       HwGpu
                    beq       vs9@
                    pshs      x
                    ldx       #FsxGpView
                    lbra      XCall
vs1@                pshs      x
                    ldx       #FcViewSet
                    lbra      CCall
vs9@                rts
VMode               fcb       $FF                 0 the cockpit, 1 the whole screen ($FF: none yet)

* PolyG (PFillA, with the GPU): B = the vertex count (3 or more), PfCol, VBuf: the polygon as the GPU's POLY
* records ($10, DIRECT, the material the color, no depth) into RecBuf, a fan from vertex 0 of 8 vertices at most a
* record; each vertex unit ($FE) x16, y16 (480 lines: the row doubled). Registers clobbered.
PolyG               stb       PfN
                    lda       GpCtl               480 lines?
                    anda      #GpuCtl256
                    sta       PgM4
                    lda       #PgFirstS           s: the record's second vertex
                    sta       PgS
pg1@                lda       PfN                 m: N - s, 7 at most
                    suba      PgS
                    cmpa      #PolyRecMore
                    bls       pg2@
                    lda       #PolyRecMore
pg2@                sta       PgM
                    ldu       RecPtr
                    ldb       #PolyDirect         DIRECT
                    stb       ,u
                    ldb       PfCol
                    stb       1,u
                    clr       2,u
                    inca                          m + 1 vertices
                    sta       3,u
                    clr       4,u
                    clr       5,u
                    clr       6,u
                    ldb       #GpuOpPoly          POLY
                    stb       7,u
                    bsr       PgNext
                    ldx       #VBuf
                    bsr       PgV
                    lda       PgS
                    ldb       #VtxBytes
                    mul
                    addd      #VBuf
                    tfr       d,x
                    lda       PgM
                    sta       PgK
pg3@                bsr       PgV
                    leax      4,x
                    dec       PgK
                    bne       pg3@
                    lda       PgS                 the next record from the last vertex
                    adda      PgM
                    deca
                    sta       PgS
                    inca
                    cmpa      PfN
                    blo       pg1@
                    rts
* PgV: X = a vertex (x16, y16): its unit at U. X kept.
PgV                 ldd       ,x
                    std       ,u
                    ldd       2,x
                    tst       PgM4
                    beq       pv2@
                    aslb
                    rola
pv2@                std       2,u
                    clr       4,u
                    clr       5,u
                    clr       6,u
                    lda       #GpuTagCont         the record goes on
                    sta       7,u
* PgNext: the unit at U done: RecPtr past it (a full batch to the GPU: Feed); U = RecPtr. X kept.
PgNext              leau      8,u
                    stu       RecPtr
                    cmpu      #RecEnd
                    blo       pn9@
                    lbsr      Feed
                    ldu       RecPtr
pn9@                rts
PgM4                fcb       0
PgS                 fcb       0
PgM                 fcb       0
PgK                 fcb       0

* ReqGo (Frame): while ReqOn (FswReq) is set, fsx's EnvDef: its FswEnvRq bit, the start as a crash reset
ReqGo               tst       >FswReq
                    beq       rg9@
                    pshs      x
                    ldx       #FsxReq
                    lbra      XCall
rg9@                rts

* ClipIn (FswClipIn, pinned): the first instructions of FS's four clip-plane cuts ($E6E2, $E721, $E765, $E7A4, each
* in place of its ldd <$BC / subd <$C5). FS's cut takes the ends' differences in 16 bits and its overflow check
* sees only the last one, so ends far apart (a building wall from beside the eye to far ahead: x -27054 and
* +16734) wrapped and cut the face at wrong points. Both ends <$B8 and <$C1 are halved together (FS's own $E7E5,
* the same as its overflow retry; the cut point is unchanged) until every word is within +-16383, so every
* difference fits. Exit: D = <$BC - <$C5 as the two instructions it replaces. X kept.
                    zmb       FswClipIn-*
ClipIn              pshs      x
ci1@                ldx       #vEnd1X
                    bsr       ClipBig
                    bne       ci2@
                    ldx       #vEnd2X
                    bsr       ClipBig
                    beq       ci9@
ci2@                jsr       >FsHalveLineEnds    both ends halved
                    bra       ci1@
ci9@                puls      x
                    ldd       <vEnd1Z
                    subd      <vEnd2Z
                    rts
* ClipBig: X = an end (three words): Z clear when one of them is outside +-16383. A clobbered.
ClipBig             lda       ,x
                    adda      #ClipBigBias
                    bmi       cb9@
                    lda       2,x
                    adda      #ClipBigBias
                    bmi       cb9@
                    lda       4,x
                    adda      #ClipBigBias
                    bmi       cb9@
                    clra
                    rts
cb9@                lda       #true
                    rts

                    zmb       FswReq-*
ReqOn               fcb       FswEnvRq            FswReq: FswEnvRq, the start as a crash reset at the first frame (fsx's EnvDef)
                    zmb       FswRecPtr-*
RecPtrV             fdb       RecBuf              FswRecPtr: the next record's place (fswc's text writes there too)
                    zmb       FswVMaxY-*
VMaxY               fdb       164*16-1            FswVMaxY: Proj's last row in sixteenths (fswc's ViewSet)
VRowsV              fcb       164                 FswVRows: the view's rows (fswc's ViewSet; fsx's and fswc's GpMode)

* The traffic readout fst writes (fs_wb.d pins them at the end of part 2, under the stack)
                    zmb       FswTfBrg-*
TfBrgV              fdb       0                   the actor's bearing from the nose, degrees clockwise
TfDstV              fdb       999                 its distance, hundreds of meters (999: none)
PrCYV               fdb       ViewCY*16           Proj's center row in sixteenths: ViewCY (fs_wb.d), the horizon midway
*                                                 in what shows above the dash, on both machines
TwKeyV              fcb       0                   FswTwKey: a tower key for fswc's tower (0 none)
TfPtV               fcb       $FF                 FswTfPt: the actor's plan point ($FF: no actor)
AudV                fcb       $03                 FswAud: the audio panel's buttons, COM1 and COM2 heard at the start
Com2V               fdb       $3540               FswCom2: COM2 at the start, O'Hare's ATIS (COM1, fd: the start's tower)
                    ifne      RecPtrV-FswRecPtr
                    error     "fs_wb.d: FswRecPtr"
                    endc
                    ifne      ClipIn-FswClipIn
                    error     "fs_wb.d: FswClipIn"
                    endc
                    ifne      AudV-FswAud
                    error     "fs_wb.d: FswAud"
                    endc
                    ifne      Com2V-FswCom2
                    error     "fs_wb.d: FswCom2"
                    endc
                    ifne      TwKeyV-FswTwKey
                    error     "fs_wb.d: FswTwKey"
                    endc
                    ifne      TfPtV-FswTfPt
                    error     "fs_wb.d: FswTfPt"
                    endc
                    ifne      PrCYV-FswPrCY
                    error     "fs_wb.d: FswPrCY"
                    endc
                    ifne      TfBrgV-FswTfBrg
                    error     "fs_wb.d: FswTfBrg"
                    endc
                    ifne      TfDstV-FswTfDst
                    error     "fs_wb.d: FswTfDst"
                    endc
                    ifgt      *-$3F00
                    error     "fsw: the code runs into the stack"
                    endc

                    end
