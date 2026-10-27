********************************************************************
* fsx - FS (Flight Simulator II), WildBits port: the spot view
*
* A raw binary, not a module: fsw's Init reads /dd/fs2/fsx into a RAM block of its own, which fsw maps at
* FsxBase (in place of the panel's block) only while fsx runs: FsxCam from Matrix, FsxDraw after the scenery.
*
* The camera is the Atari ST FS2's SPOT (its $3882E; defaults from its situation records): the eye SpDist from
* the aircraft in the direction heading + SpDir (0 ahead, $4000 right, $8000 behind, $C000 left; $8001 is 1 m
* behind) and SpAlt above it; each frame it moves with the aircraft and then 1/16 of the way to that point (a
* lag that swings it round in turns), except over $138800 (5 km: it jumps) and in slew mode; never below 3 m.
* It looks at the aircraft, wings level. Distances in FS's position units (1/256 m).
*
* The aircraft is the ST's Cessna 182 (fsx_cessna.asm), a display list for FS's own interpreter in model units
* (1/16 m; x right, y up, z forward). FS has no turned objects, so the turn goes into the view: with R the
* aircraft's attitude (model axes to the world's), the list runs with the matrix C = R' x SpM and the eye in
* model coordinates R' x SpW in <$0C/<$0E/<$10 (the list's ordering tests read them too); then SpM goes back.
* R comes from SpMc, BuildViewMatrix's matrix for the aircraft's own attitude (rows the world's axes, columns
* the aircraft's: x and z / 4, y x $3E2F): columns x and z times 4, column y / $3E2F.

                    nam       fsx
                    ttl       FS2 spot view

                    ifp1
                    use       defsfile
                    use       fs_wb.d
                    use       fsx_gpu.d
                    endc

* Constants: the values this module's instructions use, by name (fs_wb.d holds the addresses)
AcColorBits         equ       $0F                 a face record's first byte: the color in its low nibble (the corner count - 3 above)
AcFaceBytes         equ       10                  a face record: 10 bytes (corners and color, normal, d, four vertex indexes)
AcFaceVtxOff        equ       6                   a face record's vertex indexes: from byte 6
AcFileRound         equ       AcFile+1            AcFile + 1: the file's end rounded up to an even address (then EvenMask)
AcFirst             equ       0                   AcJ's start: the first drawn face or cache entry
AcHeadBytes         equ       2*NB                the bucket heads: a word per depth bucket
AcKeyPoints         equ       3                   a face's depth key: its first three points' camera z
AcLastBucket        equ       NB-1                the farthest depth bucket (pass 5 counts down from it)
AcMagic             equ       $4143               fs2/ac.archer's header: 'AC'
AcMinCorners        equ       3                   a face's fewest corners: its record's high nibble counts past 3
AcMpMirror          equ       1                   AcMp 1: a mirrored point (x -> -x)
AcNil               equ       $FFFF               a bucket's face list's end (an empty bucket's head)
AcNilByte           equ       $FF                 AcNil's bytes: the bucket heads filled with them, every bucket empty
AcNone              equ       $FF                 AcOk: no aircraft file (not there or refused)
AcOkRead            equ       1                   AcOk 1: ac.archer read and its header checked
AcSeen              equ       0                   a drawn face's link: seen (pass 1); pass 3 puts its depth key there
AcSlotSecond        equ       1                   the second corner's point slot: $33 1 first
AcStep              equ       1                   AcJ's step: the next drawn face or cache entry
AcUnseen            equ       $8000               a drawn face's link: not seen (pass 1), passed over by passes 3 and 4
AcVersion           equ       1                   ac.archer's header version: 1
AcVtxBytes          equ       6                   a stored vertex: x, y, z words, 6 bytes
Angle8Half          equ       $80                 180 degrees in an 8-bit angle (256 a turn)
Atan2Half           equ       $1000               half Atan2Max: a part within -it..it-1 still fits Atan2Angle when doubled
Atan2Max            equ       $2000               Atan2Angle's input limit: each part below $2000 (both fit its $1FFF)
Atan2Min            equ       $E000               Atan2Angle's input's low limit, -$2000 as a word: Fits2's negative limit
AxisCount           equ       3                   the three axes x, y, z: a vector's components, a 3 x 3 matrix's rows or columns
BeaconSecBit        equ       1                   FS's clock seconds ($0287) bit 0: the beacon lit on odd seconds
BothNibbles         equ       $11                 a 4-bit color times it: the color in both nibbles of a byte
BrdBytes            equ       6                   the OS's border: 6 bytes (control, blue, green, red, x size, y size)
BrdOnSaved          equ       1                   FswBrdOn 1: FswBrdSv holds the OS's border, the state strip on
CarryOnly           equ       0                   0: an adc or sbc of the carry alone (a carry or borrow into the higher byte)
DlFillReturn        equ       $2919               display-list ops $29 (the polygon filled) and $19 (return)
DlOpPolyTo          equ       $33                 display-list op: the polygon's next corner (the slot follows)
DlOpReturn          equ       $19                 display-list op: return (a called list's end; here back from AcRun)
DlOpStoreW          equ       $25                 display-list op: a word stored at an address (the word, then the address)
DlPointSlot0        equ       $3100               display-list op $31 (a 3D point into a slot) with slot 0; x, y, z follow
DlPolyBegin         equ       $2F32               display-list ops $2F (a polygon begins) and $32 (its first corner; the slot follows)
EnvRqClrMask        equ       $FF-FswEnvRq        FswReq without its FswEnvRq bit: the request cleared
EvenMask            equ       $FE                 bit 0 cleared: an even value (a whole word for the double-speed DMA, an even address)
Fits2NegHi          equ       $FFFF               Fits2: the high word of a 32-bit value in -$10000..-1 (the low word then checked)
FixOneByte          equ       1                   GpuF.FixN's U: one byte
FyGrow240           equ       119                 the full-screen views' FY: + FY x 119/256 (x 375/256, 240/164 rows)
GfxHires4Clr        equ       $FE                 VKY_GFX_MODE without GFX_HIRES4: the OS's bit cleared before Hr4 is put back
GmItCount           equ       1                   GmIt's GpuF.List items: one, the FIFO_FREE wait
GpCallGet           equ       1                   GpCall's A: not 0, its GetStat functions (0 its SetStat)
GpClutFirst         equ       16                  ac.gpu's first CLUT 0 entry: 16 (FS's palette below it)
GpFnFixPp           equ       GpuF.FixN*256+1     SS.Gpu's X: GpuF.FixN on the K2 point pipeline's registers (block 1, GpuPp.Port)
GpFnFixVicky        equ       GpuF.FixN*256       SS.Gpu's X: GpuF.FixN on VICKY's fixed registers (block 0, TXT.Base)
GpFnList            equ       GpuF.List*256       SS.Gpu's X: GpuF.List
GpFnLPk16           equ       GpuF.LPk16*256+VICKY_BLK SS.Gpu's X: GpuF.LPk16, a word in the VICKY block
GpFnLPk8            equ       GpuF.LPk8*256+VICKY_BLK SS.Gpu's X: GpuF.LPk8, a byte in the VICKY block
GpFnLPkN            equ       GpuF.LPkN*256+VICKY_BLK SS.Gpu's X: GpuF.LPkN, a run of bytes in the VICKY block
GpFnRec             equ       GpuF.Rec*256        SS.Gpu's X: GpuF.Rec with no GpuRec flags
GpHdrSize           equ       5                   an ac.gpu chunk's header: UP_ADDR (3 bytes), the length (2)
GpKindClut          equ       2                   GpKind 2: a CLUT chunk (0 an upload, 1 records)
GpMeshLMat          equ       GpMeshL+6           the first lamp MESH record's material override byte (7 bytes a record)
GpOnLoaded          equ       1                   GpOn 1: ac.gpu went in, rc26's GPU holds the model
GpRegNone           equ       $FFFF               GpR8 / GpR16's D when the call fails: what a core without the register reads
GpSetupProj         equ       GpSetup+14          GpSetup's SETPROJ record, after SETLIGHT's 14 bytes
GpuCtl256           equ       $02                 Gpu.Ctrl b1: the 320 x 256-color view (clear: 640 x 16)
GpuCtlDither        equ       $08                 Gpu.Ctrl b3: DITHER
GpuCtlEn            equ       $01                 Gpu.Ctrl b0: EN, the GPU on
GpuCtlReset         equ       $10                 Gpu.Ctrl b4: RESET
GpuCtlSePort        equ       $80                 Gpu.Ctrl b7: SEPORT, the SceneEngine's records straight to the GPU
GpuCtlZ             equ       $04                 Gpu.Ctrl b2: z, the depth test: set while the GPU draws FS's view with its meshes
GpuIdRc26           equ       $34                 GPU_ID of rc26's GPU (a core without it reads $FF)
GpuOpMesh           equ       $28                 the GPU record MESH's opcode: draw mesh entries (first face, count, base, material)
GpuOpSetLight       equ       $21                 the GPU record SETLIGHT's opcode: the light direction, ambient, diffuse
GpuOpSetMat         equ       $20                 the GPU record SETMAT's opcode: the mesh's matrix, translation and scale (5 units)
GpuOpSetProj        equ       $22                 the GPU record SETPROJ's opcode: the projection (2 units)
GpuTagCont          equ       $FE                 the GPU unit tag CONT: every unit of a record after its first
HwGpuMesh           equ       2                   FswHwGpu 2: the GPU draws the view and the meshes (ac.gpu loaded)
HwGpuOn             equ       1                   FswHwGpu 1: rc26's GPU draws the view
Int16Max            equ       $7FFF               the largest signed word: AcMin's start, above every depth key
Int16Min            equ       $8000               the smallest signed word: AcMax's start, below every depth key
KeyDitherX2         equ       $88                 key D x 2, as FS's DispatchKey passes it: the dither on or off
KeyRibbonX2         equ       $8A                 key E x 2, as FS's DispatchKey passes it: the line ribbons on or off
KeyX2Upper          equ       $BF                 a key x 2 (FS's DispatchKey) with the lower case bit cleared: the upper case key
LampCount           equ       5                   the Archer's lamps: left, right, tail, beacon, landing light
LayerGpu            equ       1                   SS.PScrn's X: display layer 1, the GPU's (the dash bitmap on layer 0)
LayerSrcGpu         equ       3                   SS.PScrn's Y: source 3, the GPU
LightDay            equ       1                   vLight: day (bit 0; clear at dawn, dusk and night)
LoadKindCrash       equ       1                   vLoadKind 1: the crash reset (the same A makes vOvlReq 1, CMDS/f2)
MarkBit0            equ       1                   a mark byte's bit 0, shifted left to the entry's bit
MarkBitMask         equ       7                   a cache entry's bit within its mark byte: the low three bits
MarkByteRound       equ       7                   a mark bit count rounded up to whole bytes (+7, then / 8)
MatBytes            equ       18                  a 3 x 3 matrix of Q15 words: 18 bytes
MatIdxEnd           equ       6                   a matrix row or column index's end: three Q15 words (6 bytes)
MatIdxStep          equ       2                   a matrix row or column index's step: one Q15 word (2 bytes)
MatRowWords         equ       3                   a matrix row's Q15 words: x a word index (2c) gives the row's byte offset 6c
MeshUnits           equ       1                   a MESH record: 1 unit
Mode480On           equ       1                   Gpu.Mode480 b0: 320 x 480 with Gpu.Ctrl b1 (the 256-color view)
ModelUnitShift      equ       2                   halvings from FS's 1/256 m to the model's 1/64 m
NegCarry            equ       1                   the 1 that completes a two's-complement negation (after coma, comb)
Pos32Size           equ       12                  a 32-bit X, Y, Z triple's size: 12 bytes
Pos32X              equ       0                   a 32-bit X, Y, Z triple: the x's offset (y at 4, z at 8)
PpDeltaPut          equ       $0611               PpPut's A, B: the point pipeline's command register (offset 6), SETMODE DELTA ($11)
PpRegWrite          equ       1                   PpReg's B: 1 a write (0 a read)
PpResetPut          equ       $0701               PpPut's A, B: the point pipeline's control register (offset 7), RESET (1)
PpRwFlip            equ       1                   PpReg's B to GpCall's A: a read (0) to GetStat (1), a write (1) to SetStat (0)
PpStatIdle          equ       $05                 the point pipeline's STATUS after a RESET: idle, no error (%101)
PpStatMask          equ       7                   the point pipeline's STATUS: its low three bits
PpStatusGet         equ       $0600               PpReg's A, B: the point pipeline's STATUS (offset 6), a read (0)
PrbRowOn            equ       $8000+161           PROBE_ROW: the probe on (b15) at bitmap row 161, view row 124 at 164 rows (240 lines)
PrbRowOn480         equ       $8000+322           PROBE_ROW: the probe on (b15) at row 322, 161 x 2 in 480 lines
PrbX                equ       320                 PROBE_DOT in the 640 x 16 view: dot 320 (as fsw's PrbX)
PrbX256Col          equ       160                 PROBE_DOT in the 320 x 256-color view: dot 160 (PrbX / 2)
ProjRecBytes        equ       14                  a SETPROJ record: 14 bytes (2 units of 7)
PropRpmMax          equ       63                  the RPM gauge value the prop's step is held to: under the two blades' 90-degree limit
PropStepMask        equ       $F0                 the prop's angle in 1/16 turns (22.5 degrees): the high byte's low nibble cleared
PtSlotBytes         equ       8                   an FS 3D point slot record: 8 bytes (vPtSlots)
Q15NegOne           equ       $8001               Q15 minus one (-$7FFF): Q15One negated
SeAbort             equ       3                   Se.Cnt's control: abort, the OUT FIFO flushed, errors cleared (as fsw's SeAbort)
SeListEnd           equ       $2000               the SceneEngine's list RAM end: ADDR after a byte at SeListLast (RAM counts up there)
SeListLast          equ       $1FFF               the SceneEngine's last list RAM address (its list RAM $0000-$1FFF)
SeLwPlain           equ       0                   Se.Lw 0: the SceneEngine's lines plain, no ribbons
SeStatIdle          equ       $03                 the SceneEngine's STATUS after an abort: idle, nothing in the FIFO (%011)
SeStatMask          equ       7                   the SceneEngine's STATUS: its low three bits
SetLightUnits       equ       2                   a SETLIGHT record: 2 units
SetMatUnits         equ       5                   a SETMAT record: 5 units
SetProjUnits        equ       2                   a SETPROJ record: 2 units
SeViewBytes         equ       12                  the SceneEngine's view registers: twelve bytes (SeView, VsSe)
SeYMul1x            equ       1024                SE_YMUL 1.0 (x 1/1024): the SceneEngine's rows as projected, 240 lines
SeYMul2x            equ       2048                SE_YMUL 2.0 (x 1/1024): the SceneEngine's rows doubled, 480 lines
SignByteBase        equ       0                   the sign byte before the carry is subtracted: $00, $FF when negative (lda keeps the carry)
SignExtNeg          equ       1                   AddW: a negative D's sign extension ($FFFF) on the high word, as minus 1
SpCloseDist         equ       $0100               the close position's distance from the aircraft: 1 m (1/256 m)
SpDirClose          equ       $8001               SpDir's close position: 1 m behind the aircraft ($8000 behind, +1 marks it)
SpDoubleMax         equ       14                  SpLook's doublings at most (a zero difference ends there)
SpJumpDistHi        equ       $0013               the eye's jump distance, 5 km ($138800 in 1/256 m): its high word
SpJumpDistLo        equ       $8800               the eye's jump distance $138800: its low word
SpJumpNegHi         equ       $FFEC               the jump distance negated ($FFEC7800): its high word
SpJumpNegLo         equ       $7800               the jump distance negated ($FFEC7800): its low word
SpLagShift          equ       4                   the spot eye moves 1/16 of the way a frame: 4 right shifts
SpMinAlt            equ       $0300               the spot eye's lowest height above the ground: 3 m (1/256 m)
SpMinAltHi          equ       0                   the spot eye's lowest height, 3 m: its high word (SpMinAlt the low)
SpTY                equ       SpT+4               SpT's height (32 bits, 1/256 m)
SpTZ                equ       SpT+8               SpT's Z (32 bits, 1/256 m)
SumInit             equ       0                   a sum's start
TfModeSpot          equ       2                   TfRun's A (TfMode): 2 the spot view, from fsx's SpEye and SpM
UnitPayload         equ       7                   a GPU unit's payload bytes (byte 7 its tag)
UpAdrBytes          equ       3                   UP_ADDR's 3 bytes: GpHdrR's GpuF.LPkN run
ViewCY16            equ       ViewCY*16           ViewCY in sixteenths of a row (FswPrCY; fsw's PrCYV)
ViewDirBits         equ       $0F                 vViewDir's direction: its low nibble, 1/16 turns (0 ahead)
ViewRows            equ       164                 the cockpit view's rows: bitmap rows 0-163, VIEW_ROWS 164 (as fsw's ViewRows)
WingsLevel          equ       0                   SpLook's bank 0, wings level (<$1A); also the x column's y term (<$6E)
XREnd               equ       XR+18               the end of XR (R's 18 bytes)
YAspect             equ       $3E2F               the view's y aspect, 0.4858 in Q15: BuildViewMatrix's column y scale
YAspectInvFrac      equ       $077A               1/0.4858 less 2 in Q15 (0.0584): 2y + y x this undoes the view's y aspect

                    org       FsxBase
                    jmp       Draw                FsxDraw
                    jmp       Cam                 FsxCam
                    jmp       GpInit              FsxGpInit
                    jmp       Trf                 FsxTraffic
                    jmp       ViewKey             FsxViewKey
                    jmp       GfxKey              FsxGfxKey
                    jmp       GpView              FsxGpView
                    jmp       GdDraw              FsxGround
                    jmp       EnvDef              FsxReq

* Variables
SpDir               fdb       $8000               behind (the ST's second 3D window; its main one has $4000)
SpDist              fdb       $0780               7.5 m ahead and behind; to the sides from the wing tips (SpWing)
SpWing              equ       $0306               3.02 m added x |sin| of the view: 10.52 m on the sides, halfway between
*                                                 the 12.85 m of the full half span (5.35 m) and the 8.2 m before it
SpAlt               fdb       $0140               1.25 m: a quarter of the ST's 5 m, the same look down
SpMc                zmb       18                  the aircraft's attitude matrix
SpM                 zmb       18                  the spot view's matrix
SpW                 zmb       6                   the eye from the aircraft, model units
SpEye               zmb       12                  the eye
SpPrev              zmb       12                  the aircraft's position at the last spot frame
SpT                 zmb       12                  the point the eye moves toward
SpD                 zmb       12                  a difference, 32-bit per axis
SpA                 zmb       4
SpB                 zmb       4
SpSn                fdb       0                   sine and cosine of the eye's direction; the distance
SpCs                fdb       0
SpDs                fdb       0
SpOx                fdb       0                   the eye's offset east and north
SpOz                fdb       0
SpH                 fdb       0                   the view's heading and pitch, their sines and cosines
SpP                 fdb       0
SpSh                fdb       0
SpCh                fdb       0
SpSp                fdb       0
SpCp                fdb       0
SpLen               fdb       0


* Draw: the aircraft from the spot eye, when it is within 512 m (SpW = (eye - aircraft) / 16 within $2000);
* then the traffic (fst.asm) from the same eye. FS's DP 0. Registers clobbered.
Draw                lbsr      DrawAc
                    ifdef     WBTRAF
                    lda       #TfModeSpot
                    lbsr      TfRun
                    endc
                    lbra      GpFlush             the units queued to the GPU before fsw's next records
* Traffic (FsxTraffic, fsw's Ovl in a frame that is not a spot frame): fst's actors in the forward view.
Trf                 equ       *
                    ifdef     WBTRAF
                    lbsr      TfEntry
                    endc
                    lbra      GpFlush

DrawAc             ldx       #SpEye
                    ldu       #SpD
                    lbsr      Cp12
                    ldx       #SpD
                    ldu       #SpPos
                    lbsr      Sub32
                    leax      4,x
                    leau      4,u
                    lbsr      Sub32
                    leax      4,x
                    leau      4,u
                    lbsr      Sub32
                    lda       #ModelUnitShift     1/256 m to the model's 1/64 m
dr0@                ldx       #SpD
                    ldb       #AxisCount
dr0a@               asr       ,x
                    ror       1,x
                    ror       2,x
                    ror       3,x
                    leax      4,x
                    decb
                    bne       dr0a@
                    deca
                    bne       dr0@
                    ldx       #SpD
                    lbsr      Fits2
                    bcs       dr9@
                    lbsr      Fits2
                    bcs       dr9@
                    lbsr      Fits2
                    bcc       dr0b@
dr9@                rts
dr0b@               ldd       SpD+2
                    std       SpW
                    ldd       SpD+6
                    std       SpW+2
                    ldd       SpD+10
                    std       SpW+4
                    ldx       #SpMc               R: SpMc's columns rescaled, row by row
                    ldu       #XR
dr1@                ldd       ,x                  x times 4
                    aslb
                    rola
                    aslb
                    rola
                    std       ,u
                    ldd       4,x                 z times 4
                    aslb
                    rola
                    aslb
                    rola
                    std       4,u
                    ldd       2,x                 y / $3E2F: 2y + y x $077A (2.0584)
                    std       <vMulA
                    aslb                          2y (|y| <= 0.4858)
                    rola
                    pshs      d
                    ldd       #YAspectInvFrac
                    std       <vMulB
                    jsr       >FswMq
                    addd      ,s++
                    bvc       dr2@
                    ldd       #Q15One             past 1: 1 with its sign
                    tst       2,x
                    bpl       dr2@
                    ldd       #Q15NegOne
dr2@                std       2,u
                    leax      6,x
                    leau      6,u
                    cmpu      #XREnd
                    blo       dr1@
                    lbsr      MdlDraw             C, the eye, the model (fsx_ac.asm)
                    rts

* FsxCam: Matrix in the spot view (fsw's SpotCam). The aircraft's own matrix (BuildViewMatrix, forward view) to
* SpMc, the eye moved (SpEyeCalc), the aircraft's position to SpPos and the eye into <$00-<$0B, the view toward
* the aircraft (SpLook). FS's DP 0. Registers clobbered.
Cam                 lda       >vViewDir           the cockpit's view direction aside
                    pshs      a
                    anda      #ViewDirBits        the camera looks the way the view keys do: ahead =
                    lsla                          behind the aircraft, right = on its left side, back =
                    lsla                          in front of it (FS's direction: the low nibble x 16, a
                    lsla                          heading byte)
                    lsla
                    adda      #Angle8Half
                    clrb
                    std       SpDir
                    clr       >vViewDir
                    jsr       >FsBuildViewMatrix
                    puls      a
                    sta       >vViewDir
                    ldx       #vViewM
                    ldu       #SpMc
                    ldb       #MatBytes
                    lbsr      CpB
                    lbsr      SpEyeCalc
                    ldx       #vPosX
                    ldu       #SpPos
                    lbsr      Cp12
                    ldx       #SpEye
                    ldu       #vPosX
                    lbsr      Cp12
                    lbra      SpLook

* SpEyeCalc: SpEye moved for this frame (the ST's $3882E); SpPrev = the aircraft's position.
SpEyeCalc           ldd       >vHdg               the eye's direction: heading + SpDir
                    addd      SpDir
                    pshs      d
                    jsr       >FsSin16
                    std       SpSn
                    puls      d
                    jsr       >FsCos16
                    std       SpCs
                    ldx       SpDir
                    cmpx      #SpDirClose
                    bne       se0a@
                    ldd       #SpCloseDist        the close position: 1 m
                    bra       se0@
se0a@               ldd       SpDir               SpDist + SpWing x |sin| of the direction off the nose: SpDist
                    jsr       >FsSin16            from the wing tips on the side views, from the center ahead
                    tsta                          and behind, an oval between (the near wing never clips)
                    bpl       se0b@
                    coma
                    comb
                    addd      #NegCarry
se0b@               std       <vMulB
                    ldd       #SpWing
                    std       <vMulA
                    jsr       >FswMq
                    addd      SpDist
se0@                std       SpDs
                    std       <vMulA
                    ldd       SpSn
                    std       <vMulB
                    jsr       >FswMq
                    std       SpOx
                    ldd       SpDs
                    std       <vMulA
                    ldd       SpCs
                    std       <vMulB
                    jsr       >FswMq
                    std       SpOz
                    ldd       SpOx                SpT = the aircraft + (offset east, SpAlt, offset north)
                    ldx       #vPosX
                    ldu       #SpT
                    lbsr      AddW
                    ldd       SpAlt
                    ldx       #vAlt
                    ldu       #SpTY
                    lbsr      AddW
                    ldd       SpOz
                    ldx       #vPosZ
                    ldu       #SpTZ
                    lbsr      AddW
                    tst       SpNew
                    beq       se1@
                    clr       SpNew               just switched on: no motion yet
                    ldx       #vPosX
                    ldu       #SpPrev
                    lbsr      Cp12
                    ldx       #vPosX              and the eye at the aircraft's center (off, the camera is the
                    ldu       #SpEye              aircraft's): it moves out to its place from there, not from
                    lbsr      Cp12                where the last spot view left it
se1@                tst       >vSlew              slew mode: no lag
                    lbne      se5@
                    ldy       #Pos32X
se2@                leax      SpEye,y             SpA = the eye + the aircraft's motion
                    ldu       #SpA
                    lbsr      Mv4
                    ldx       #SpA
                    leau      ,y
                    lbsr      Add32
                    leau      SpPrev,y
                    lbsr      Sub32
                    leax      SpT,y               SpB = the target - SpA
                    ldu       #SpB
                    lbsr      Mv4
                    ldx       #SpB
                    ldu       #SpA
                    lbsr      Sub32
                    ldd       SpB                 within $138800 (5 km): 1/16 of the way, else there at once
                    bmi       se3@
                    cmpd      #SpJumpDistHi
                    blo       se4@
                    bhi       se6@
                    ldd       SpB+2
                    cmpd      #SpJumpDistLo
                    bls       se4@
                    bra       se6@
se3@                cmpd      #SpJumpNegHi
                    bhi       se4@
                    blo       se6@
                    ldd       SpB+2
                    cmpd      #SpJumpNegLo
                    blo       se6@
se4@                ldb       #SpLagShift
se4a@               asr       SpB
                    ror       SpB+1
                    ror       SpB+2
                    ror       SpB+3
                    decb
                    bne       se4a@
                    ldx       #SpA
                    ldu       #SpB
                    lbsr      Add32
                    bra       se7@
se6@                leax      SpT,y
se7@                leau      SpEye,y
                    lbsr      Mv4
                    leay      4,y
                    cmpy      #Pos32Size
                    lblo      se2@
                    bra       se8@
se5@                ldx       #SpT
                    ldu       #SpEye
                    lbsr      Cp12
se8@                ldd       SpEye+4             at least 3 m up
                    bmi       se9@
                    bne       se10@
                    ldd       SpEye+6
                    cmpd      #SpMinAlt
                    bhs       se10@
se9@                ldd       #SpMinAltHi
                    std       SpEye+4
                    ldd       #SpMinAlt
                    std       SpEye+6
se10@               ldx       #vPosX
                    ldu       #SpPrev
                    lbra      Cp12

* SpLook: the view from SpEye toward SpPos, wings level: <$68-<$78 as BuildViewMatrix builds them for pitch p,
* bank 0, heading h (columns x and z / 4, column y x $3E2F), <$18 = p, <$1A = 0, <$1C = h; a copy in SpM. The
* difference is scaled to at most $1FFF (FS's Atan2Angle), h its bearing, p that of (-dy, the horizontal
* length); FS's pitch is positive nose down.
SpLook              ldx       #SpPos
                    ldu       #SpD
                    lbsr      Cp12
                    ldx       #SpD
                    ldu       #SpEye
                    lbsr      Sub32
                    leax      4,x
                    leau      4,u
                    lbsr      Sub32
                    leax      4,x
                    leau      4,u
                    lbsr      Sub32
sl1@                ldx       #SpD                too long: halved
                    lbsr      Fits2
                    bcs       sl2@
                    lbsr      Fits2
                    bcs       sl2@
                    lbsr      Fits2
                    bcc       sl4@
sl2@                ldx       #SpD
                    ldb       #AxisCount
sl3@                asr       ,x
                    ror       1,x
                    ror       2,x
                    ror       3,x
                    leax      4,x
                    decb
                    bne       sl3@
                    bra       sl1@
sl4@                lda       #SpDoubleMax        short: doubled while all are below $1000
sl5@                ldx       #SpD
                    ldb       #AxisCount
sl6@                pshs      d
                    ldd       2,x
                    addd      #Atan2Half
                    cmpd      #Atan2Max
                    puls      d
                    bhs       sl8@
                    leax      4,x
                    decb
                    bne       sl6@
                    ldx       #SpD
                    ldb       #AxisCount
sl7@                lsl       3,x
                    rol       2,x
                    rol       1,x
                    rol       ,x
                    leax      4,x
                    decb
                    bne       sl7@
                    deca
                    bne       sl5@
sl8@                ldd       SpD+2               the heading: the bearing of (dx, dz)
                    std       <vAtanX
                    ldd       SpD+10
                    std       <vAtanY
                    jsr       >FsAtan2
                    std       SpH
                    jsr       >FsSin16
                    std       SpSh
                    ldd       SpH
                    jsr       >FsCos16
                    std       SpCh
                    ldd       SpD+2               the horizontal length: dx sin h + dz cos h
                    ldx       SpSh
                    lbsr      MqXY
                    std       SpLen
                    ldd       SpD+10
                    ldx       SpCh
                    lbsr      MqXY
                    addd      SpLen
                    std       <vAtanY
                    ldd       SpD+6               the pitch: the bearing of (-dy, that length)
                    coma
                    comb
                    addd      #NegCarry
                    std       <vAtanX
                    jsr       >FsAtan2
                    std       SpP
                    jsr       >FsSin16
                    std       SpSp
                    ldd       SpP
                    jsr       >FsCos16
                    std       SpCp
                    ldd       SpP
                    std       <vViewPitch
                    ldd       #WingsLevel
                    std       <vViewBank
                    std       <vViewMYX
                    ldd       SpH
                    std       <vViewHdg
                    ldd       SpCh                x: cos h, 0, -sin h
                    lbsr      Q4
                    std       <vViewM
                    ldd       SpSh
                    lbsr      Neg4
                    std       <vViewMZX
                    ldd       SpSp                y: sin p sin h, cos p, sin p cos h (x $3E2F)
                    ldx       SpSh
                    lbsr      MqY
                    std       <vViewMXY
                    ldd       SpCp
                    ldx       #YAspect
                    lbsr      MqXY
                    std       <vViewMYY
                    ldd       SpSp
                    ldx       SpCh
                    lbsr      MqY
                    std       <vViewMZY
                    ldd       SpSh                z: sin h cos p, -sin p, cos h cos p
                    ldx       SpCp
                    lbsr      MqXY
                    lbsr      Q4
                    std       <vViewMXZ
                    ldd       SpSp
                    lbsr      Neg4
                    std       <vViewMYZ
                    ldd       SpCh
                    ldx       SpCp
                    lbsr      MqXY
                    lbsr      Q4
                    std       <vViewMZZ
                    ldx       #vViewM
                    ldu       #SpM
                    ldb       #MatBytes
                    lbra      CpB

                    use       fsx_ac.asm
MdlM                equ       SpM                 the spot view's matrix, back after the model
MdlW                equ       SpW                 the eye from the aircraft
AcName              fcc       "ac.archer"
                    fcb       $0D

* GpInit (FsxGpInit, from fsw's Init): rc26's GPU (GPU_ID $34; a core without it reads $FF there) draws the 3D
* view: RESET, rows 0-146 only (VIEW_ROW0 0, VIEW_ROWS 147: the GPU clips every drawing there and the rows below
* are clear, the dash bitmap shows), FS's palette (LUT 0, CLUT group 0), the splashdown probe at its dot (row 144,
* dot 320), on, the SceneEngine's records straight to it when the engine is there; the GPU on layer 1, behind the
* dash bitmap on layer 0, which is never flipped (fsw's BackBm = FrontBm: the rate's records go to it). Registers
* clobbered.
GpInit              clr       >FswHwPp            the point pipeline: STATUS's low three bits %101 ($FF without it),
                    clr       >FswPpOk            $05 after a RESET (idle, no error); then DELTA mode (the 3D port takes
                    lbsr      PpStat              FS's own deltas <$89-<$8D)
                    anda      #PpStatMask
                    cmpa      #PpStatIdle
                    bne       gp1@
                    ldd       #PpResetPut         RESET: the control register 1
                    lbsr      PpPut
                    lbsr      PpStat
                    cmpa      #PpStatIdle
                    bne       gp1@
                    ldd       #PpDeltaPut         SETMODE DELTA: the command $11
                    lbsr      PpPut
                    inc       >FswHwPp
gp1@                clr       >FswGfxOn           the line ribbons off (key E turns them on)
                    clr       >FswSeOn            the SceneEngine: STATUS's low three bits %011, $03 (idle, nothing in the
                    ldx       #Se.Stat            FIFO) after an abort, and an upload counts ADDR up (RAM there would not)
                    lbsr      GpR8
                    andb      #SeStatMask
                    cmpb      #SeStatIdle
                    bne       gp2@
                    ldb       #SeAbort            abort
                    ldx       #Se.Cnt
                    lbsr      GpW8
                    ldx       #Se.Stat
                    lbsr      GpR8
                    cmpb      #SeStatIdle
                    bne       gp2@
                    ldd       #SeListLast
                    ldx       #Se.Addr
                    lbsr      GpW16
                    tfr       a,b                 a byte ($1F) at ADDR $1FFF: ADDR on to $2000
                    ldx       #Se.Data
                    lbsr      GpW8
                    ldx       #Se.Addr
                    lbsr      GpR16
                    cmpd      #SeListEnd
                    bne       gp2@
                    inc       >FswSeOn
                    ldd       #SeLwPlain          LW 0: plain lines (+D high, +E low)
                    ldx       #Se.Lw
                    lbsr      GpW16
gp2@               lda       >FswSeOn            rc27: the engine's view (its walker and the point port at $FED8)
                    ora       >FswHwPp            is fsw's Proj: x = 320 + 320 X/Z dots, y = 82 - 82 Y/Z rows
                    beq       gp3@
                    ldx       #SeViewR            the view register index 0, then the twelve bytes
                    lbsr      SeVwUp
gp3@                ldx       #Gpu.Id             rc26's GPU
                    lbsr      GpR8
                    cmpb      #GpuIdRc26
                    lbne      gi9@
                    lda       #HwGpuOn
                    sta       >FswHwGpu
                    ldd       #ViewCY16           fsw's Proj centers the view as the GPU does (fs_wb.d ViewCY)
                    std       >FswPrCY
                    lda       #GpuCtlReset        RESET
                    lbsr      GpCtlW
                    ldd       #ViewRows           rows 0-163: the dash's curved corners (rows 147-163) show the GPU
                    ldx       #Gpu.Row0
                    lbsr      GpW16
                    ldd       #SeYMul1x           the SceneEngine projects to the 164 rows itself (its view, below)
                    ldx       #Gpu.YMul
                    lbsr      GpW16
                    clrb
                    ldx       #Gpu.Lut
                    lbsr      GpW8
                    ldx       #Gpu.Clear          CLEAR_COLOR 0 (AUTOCLEAR, with the meshes: the fills repaint the view)
                    lbsr      GpW8
                    lbsr      GpLoad              ac.gpu: the Archer as GPU meshes, its colors, the light and projection
                    ifdef     WBTRAF
                    lbsr      CbLoad              the clouds' block (fs2/fscl: fst.asm, fscl.asm)
                    endc
                    ldd       #PrbRowOn           the splashdown probe: view row 124 is bitmap row 161 at 164 rows
                    ldx       #Gpu.Prb
                    lbsr      GpW16
                    ldd       #PrbX               fallback without the mesh package: 640 mode
                    tst       GpOn
                    beq       gi0@
                    ldd       #PrbX256Col         restored 320 x 256-color view
gi0@                ldx       #GpuPrbDot
                    lbsr      GpW16
                    ldb       #GpuCtlEn           EN
                    tst       GpOn
                    beq       gi0a@
                    ldb       #GpCtrl             EN, 320x240x8, z, dither, autoclear (key I: 640x240x4)
                    pshs      b                   the OS's border saved (fsw's XExit puts it back, as it is: the
                    ldx       #GpFnFixVicky       border is no longer the view's state, 2026-10-19) through
                    ldy       #FswBrdRq           grfdrv256's GPU call (fsw's request BrdRq), and the state strip
                    ldu       #BrdBytes           on (fsp draws it across the top rows of the dash bitmap)
                    lda       #GpCallGet          GpCall: its GetStat functions
                    lbsr      GpCall
                    lda       #BrdOnSaved
                    sta       >FswBrdOn
                    puls      b
gi0a@               tst       >FswSeOn
                    beq       gi1@
                    orb       #GpuCtlSePort       SEPORT
gi1@                tfr       b,a
                    lbsr      GpCtlW
                    lbsr      GpMode              the view's rows for its mode (the 256-color view: 480 lines)
                    ldd       >FswFrontBm
                    std       >FswFrontBm+2
                    lda       >FsPath              FS's display path: layer 1 = source 3, the GPU
                    ldx       #LayerGpu
                    ldy       #LayerSrcGpu
                    ldb       #SS.PScrn
                    swi2
                    fcb       I$SetStt
gi9@                rts

* GpLoad: fs2/ac.gpu (ac2gpu.py) to the GPU: chunks of UP_ADDR (3 bytes) and a length (2), then the bytes: to
* UP_DATA; UP_ADDR $FFFFFF = record units (whole ones) to the record window; $FFFFFE = CLUT 0 entries from 16
* (SS.ClutWrite on the display path); length 0 ends the file. GpOn = 1 when it all went in. The file is read in
* pieces of GpPiece bytes into GpBuf (AcFile, free: the GPU holds the model, AcLoad never runs; a multiple of a
* unit's 8 bytes and the CLUT's 4-byte entries), after the 4 bytes of a GpuF.LPkN request for UP_DATA (SS.Gpu:
* UP_ADDR one GpuF.LPkN, each piece another, after FIFO room for it; the records one GpuF.Rec). Registers
* clobbered.
GpPiece             equ       256
GpBuf               equ       AcFile+4
                    ifgt      GpBuf+GpPiece-AcFile-512
                    error     "fsx: GpLoad's pieces run past AcFile's 512 bytes"
                    endc
GpLoad              clr       GpOn
                    ldx       #GpName
                    lda       #READ.
                    swi2
                    fcb       I$Open
                    lbcs      gl9@
                    sta       GpPath
                    lda       #GpClutFirst
                    sta       GpClut
gl1@                ldx       #GpHdr              the next chunk
                    ldy       #GpHdrSize
                    lbsr      GpRead
                    lbcs      gl8@
                    ldd       GpHdr+3
                    lbeq      gl7@
                    std       GpN
                    clr       GpK
                    clr       GpKind
                    lda       GpHdr
                    anda      GpHdr+1
                    inca                          $FFxxxx
                    bne       gl2@
                    lda       GpHdr+2
                    inca                          $FFFFFF: records
                    bne       gl1a@
                    inc       GpKind
                    bra       gl3@
gl1a@               inca                          $FFFFFE: the CLUT
                    bne       gl2@
                    lda       #GpKindClut
                    sta       GpKind
                    bra       gl3@
gl2@                ldy       #GpHdrR             an upload: UP_ADDR, GpHdr's three bytes
                    ldu       #UpAdrBytes
                    ldx       #GpFnLPkN
                    clra                          GpCall: its SetStat functions
                    lbsr      GpCall
                    lbcs      gl8@
gl3@                ldd       GpN                 the next piece, GpPiece bytes at most
                    beq       gl1@
                    cmpd      #GpPiece
                    bls       gl4@
                    ldd       #GpPiece
gl4@                std       GpPc
                    pshs      d
                    ldd       GpN
                    subd      ,s++
                    std       GpN
                    ldx       #GpBuf
                    ldy       GpPc
                    lbsr      GpRead
                    bcs       gl8@
                    lda       GpKind
                    cmpa      #GpKindClut
                    beq       gl6@
                    tsta
                    bne       gl5x@
                    lbsr      GpRoom
                    ldd       #Gpu.UpDat          UP_DATA: each byte at UP_ADDR, which counts up (mask 0: every byte
                    std       AcFile              to the one port)
                    clr       AcFile+2
                    clr       AcFile+3
                    ldy       #AcFile
                    ldu       GpPc
                    ldx       #GpFnLPkN
                    bra       gl5@
gl5x@               ldd       GpPc                the record window: the piece's units, each after FIFO room
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    tfr       d,u
                    ldy       #GpBuf
                    ldx       #GpFnRec            (no flags: the SceneEngine is idle at the start)
gl5@                clra                          GpCall: its SetStat functions
                    lbsr      GpCall
                    lbcc      gl3@
                    bra       gl8@                refused: GpOn stays 0
gl6@                ldd       GpPc                the CLUT: this piece's entries, from GpClut
                    lsra
                    rorb
                    lsra
                    rorb
                    tfr       d,u                 count
                    pshs      d
                    ldb       GpClut
                    clra
                    tfr       d,y                 CLUT 0, first entry
                    puls      d
                    addb      GpClut
                    stb       GpClut
                    ldx       #GpBuf
                    lda       >FsPath              FS's display path
                    ldb       #SS.ClutWrite
                    swi2
                    fcb       I$SetStt
                    lbra      gl3@
gl7@                lda       #GpOnLoaded
                    sta       GpOn
                    lda       #HwGpuMesh          fsw's diagnostic line shows HwGpu x 10: 2x = the mesh path is on
                    sta       >FswHwGpu
gl8@                lda       GpPath
                    swi2
                    fcb       I$Close
gl9@                rts

GpName              fcc       "ac.gpu"
                    fcb       $0D

* GpRead: Y bytes of ac.gpu into X. Carry: an error, or the file ended early. Registers clobbered.
GpRead              pshs      y
                    lda       GpPath
                    swi2
                    fcb       I$Read
                    bcs       gr9@
                    cmpy      ,s
                    beq       gr8@
                    orcc      #Carry
                    puls      y,pc
gr8@                andcc     #^Carry
gr9@                puls      y,pc

* GpRoom: FIFO room for 260 units, waited for in the driver: one GpuF.List, its GpuW.Free wait (65,536 polls at
* most; one that runs out goes on, as the 1000 asks before it did). Registers kept but CC.
GpRoom              pshs      d,x,y,u
                    ldx       #GpFnList
                    ldy       #GmIt
                    ldu       #GmItCount
                    clra                          GpCall: its SetStat functions
                    lbsr      GpCall
                    puls      d,x,y,u,pc
GmIt                fcb       GpuK.Wait,GpuW.Free,0
                    fdb       260,0

* GpMode (GpInit, GpView, ViewKey): A = Gpu.Ctrl: the view's rows for its mode (Roger 2026-10-21): the 256-color
* view (b1) in 480 lines (Gpu.Mode480), 328 rows (VIEW_ROWS $48 + its high bit $181D), the SceneEngine's rows x 2
* (SE_YMUL 2048), the probe on row 322; the 640 x 16 view in 240 lines, 164 rows, SE_YMUL 1024, the probe on row
* 161. In that order, a register a GpuF.LPk8 / LPk16. Registers kept but CC.
GpMode              pshs      d,x
                    bita      #GpuCtl256
                    beq       gmo1@
                    clra                          the view's rows (fsw's VRows: 164, or 240 with the dash
                    ldb       >FswVRows           hidden) x 2
                    lslb
                    rola
                    ldx       #Gpu.Rows
                    bsr       GpW8
                    tfr       a,b
                    ldx       #Gpu.RowsH
                    bsr       GpW8
                    ldb       #Mode480On
                    ldx       #Gpu.Mode480
                    bsr       GpW8
                    ldd       #SeYMul2x
                    ldx       #Gpu.YMul
                    bsr       GpW16
                    ldd       #PrbRowOn480
                    bra       gmo2@
gmo1@               ldb       >FswVRows
                    ldx       #Gpu.Rows
                    bsr       GpW8
                    clrb
                    ldx       #Gpu.RowsH
                    bsr       GpW8
                    ldx       #Gpu.Mode480
                    bsr       GpW8
                    ldd       #SeYMul1x
                    ldx       #Gpu.YMul
                    bsr       GpW16
                    ldd       #PrbRowOn
gmo2@               ldx       #Gpu.Prb
                    bsr       GpW16
                    puls      d,x,pc

* GpCall (fsx's and fscl's): grfdrv256's GPU call, SS.Gpu on FS's display path: A = 0 its SetStat functions, else
* its GetStat ones; X, Y, U as SS.Gpu takes them. D clobbered.
GpCall              tsta
                    bne       gc1@
                    lda       >FsPath
                    ldb       #SS.Gpu
                    swi2
                    fcb       I$SetStt
                    rts
gc1@                lda       >FsPath
                    ldb       #SS.Gpu
                    swi2
                    fcb       I$GetStt
                    rts
* GpW8 / GpW16: the VICKY block's register at offset X = B / = D (high byte first), one GpuF.LPk8 / LPk16 on FS's
* display path. GpR8 / GpR16: B / D = the register at offset X (their GetStat; D = $FFFF when the call fails, as
* a core without the register reads; else GpR8's A = 0). GpCtlW: Gpu.Ctrl = A, FswGpCtl too. Registers kept but CC
* (and D for GpR8 / GpR16).
GpW8                pshs      d,x,y,u
                    ldy       #GpFnLPk8
                    clra
                    bra       gw1@
GpW16               pshs      d,x,y,u
                    ldy       #GpFnLPk16
gw1@                exg       x,y                 X = the function and the block, Y = the offset
                    tfr       d,u
                    clra                          GpCall: its SetStat functions
                    lbsr      GpCall
                    puls      d,x,y,u,pc
GpR8                pshs      x,y,u
                    ldy       #GpFnLPk8
                    bra       gr1@
GpR16               pshs      x,y,u
                    ldy       #GpFnLPk16
gr1@                exg       x,y
                    lda       #GpCallGet          GpCall: its GetStat functions
                    lbsr      GpCall
                    tfr       u,d
                    bcc       gr9@
                    ldd       #GpRegNone
gr9@                puls      x,y,u,pc
GpCtlW              sta       >FswGpCtl
                    pshs      b,x
                    tfr       a,b
                    ldx       #Gpu.Ctrl
                    bsr       GpW8
                    puls      b,x,pc
* SeVwUp (GpInit, GpView): the SceneEngine's view registers from X's GpuF.LPkN request (Se.VDat, mask 0, then the
* twelve bytes), after its index 0. Registers clobbered.
SeVwUp              pshs      x
                    clrb
                    ldx       #Se.VIdx
                    bsr       GpW8
                    puls      y                   the request
                    ldu       #SeViewBytes
                    ldx       #GpFnLPkN
                    clra                          GpCall: its SetStat functions
                    lbsr      GpCall
                    rts

* ViewKey (FsxViewKey, fsw's key I through its XCall): the GPU view's mode, 320 x 480 x 256 colors (Gpu.Mode480)
* <-> 640 x 240 x 16, from its next swap (Gpu.Ctrl b1; ac.gpu holds a shade LUT for each mode), and the splashdown
* probe's dot for that mode. Only while the GPU draws FS's view with its meshes (GpInit's z-buffered control); the
* dash keeps its 640 x 16 bitmap. D, X clobbered.
ViewKey             tst       >FswHwGpu
                    beq       vk9@
                    lda       >FswGpCtl
                    bita      #GpuCtlZ
                    beq       vk9@
                    ldb       Hr4                 the OS's HIRES4 bit, the first time
                    bpl       vk0@
                    lbsr      VkMode
                    andb      #GFX_HIRES4
                    stb       Hr4
vk0@                eora      #GpuCtl256
                    bsr       GpCtlW
                    lbsr      GpMode              the view's rows for the new mode (the 256-color view: 480 lines)
                    lbsr      VkMode              320 mode: HIRES4 off, the GPU layer shows 8-bit dots; 640 mode:
                    andb      #GfxHires4Clr       the OS's bit back
                    bita      #GpuCtl256
                    bne       vk0a@
                    orb       Hr4
vk0a@               lbsr      VkModeW
                    ldx       #PrbX256Col         320 mode
                    bita      #GpuCtl256
                    bne       vk1@
                    ldx       #PrbX
vk1@                tfr       x,d
                    ldx       #GpuPrbDot          (fsp's state strip shows the new mode)
                    lbra      GpW16
vk9@                rts

* GfxKey (FsxGfxKey, fsw's keys D, E through its XCall; B = the key x 2, FS's DispatchKey): D the dither, E the
* line ribbons (LW: SeLw or 0, the engine only), each on/off; fsp's state strip shows the new state. Only while the
* GPU draws FS's view with its meshes. D, X clobbered.
GfxKey              tst       >FswHwGpu
                    beq       gk9@
                    lda       >FswGpCtl
                    bita      #GpuCtlZ
                    beq       gk9@
                    andb      #KeyX2Upper         the lower case keys as the upper
                    cmpb      #KeyDitherX2        D
                    bne       gk1@
                    eora      #GpuCtlDither       DITHER, from the next swap
                    lbra      GpCtlW
gk1@                cmpb      #KeyRibbonX2        E
                    bne       gk9@
                    tst       >FswSeOn
                    beq       gk9@
                    lda       >FswGfxOn
                    eora      #FgRibbon
                    sta       >FswGfxOn
                    ldx       #Se.Lw              LW, +D high, +E low
                    bita      #FgRibbon
                    beq       gk3@
                    ldd       #SeLw
                    lbra      GpW16
gk3@                ldd       #SeLwPlain          LW 0: plain lines
                    lbra      GpW16
gk9@                rts
Hr4                 fcb       $FF                 the OS's HIRES4 bit (VKY_GFX_MODE b0; $FF: not read yet)
* VkMode / VkModeW (ViewKey): VICKY's mode register (VKY_GFX_MODE) through grfdrv256's GPU call (GpuF.FixN): read
* into B / B written. Registers kept but B (VkMode) and CC.
VkMode              pshs      a,x,y,u
                    lda       #GpCallGet          GpCall: its GetStat functions
                    bsr       VkCall
                    ldb       MdRq+4
                    puls      a,x,y,u,pc
VkModeW             pshs      d,x,y,u
                    stb       MdRq+4
                    clra                          GpCall: its SetStat functions
                    bsr       VkCall
                    puls      d,x,y,u,pc
VkCall              ldx       #GpFnFixVicky
                    ldy       #MdRq
                    ldu       #FixOneByte
                    lbsr      GpCall
                    rts
MdRq                fdb       VKY_GFX_MODE        GpuF.FixN's request: the offset, the mask, 0, the byte
                    fcb       0,0,0
* PpStat / PpPut (GpInit): the K2 point pipeline's registers through grfdrv256's GPU call (GpuF.FixN, registers
* 1: GpuPp.Port, $FED8-$FEDF): A = STATUS (offset 6) / B written at offset A. Registers kept but A (PpStat), CC.
PpStat              pshs      b,x,y,u
                    ldd       #PpStatusGet        offset 6, a read
                    bsr       PpReg
                    lda       PrRq+4
                    puls      b,x,y,u,pc
PpPut               pshs      d,x,y,u
                    stb       PrRq+4
                    ldb       #PpRegWrite         a write
                    bsr       PpReg
                    puls      d,x,y,u,pc
* PpReg: A = the offset, B = 0 a read, 1 a write: one byte. X, Y, U, D clobbered.
PpReg               sta       PrRq+1
                    tfr       b,a
                    eora      #PpRwFlip           GpCall: 1 its GetStat functions (a read), 0 its SetStat (a write)
                    ldx       #GpFnFixPp
                    ldy       #PrRq
                    ldu       #FixOneByte
                    lbsr      GpCall
                    rts
PrRq                fcb       0,0,0,0,0           GpuF.FixN's request: the offset word, the mask 0, 0, the byte

* GpView (FsxGpView, fsw's ViewSet after fswc's, through its XCall): with the GPU its view rows for the view
* (GpMode: x 2 in 480 lines) and, with the SceneEngine, its view: center (5120, CY), scale (1280, VRows x 2), the
* largest dot and row (10239, VMaxY), from fswc's ViewSet's FswVRows, FswPrCY, FswVMaxY. Registers clobbered.
GpView              tst       >FswHwGpu
                    beq       gv9@
                    lda       >FswGpCtl
                    lbsr      GpMode
                    tst       >FswSeOn
                    beq       gv9@
                    ldd       >FswPrCY
                    std       VsSe+2
                    clra
                    ldb       >FswVRows
                    lslb
                    rola
                    std       VsSe+6
                    ldd       >FswVMaxY
                    std       VsSe+10
                    ldx       #VsSeR
                    lbra      SeVwUp
gv9@                rts
VsSeR               fdb       Se.VDat             GpuF.LPkN's request header (as SeViewR), then the view
                    fcb       0,0
VsSe                fdb       5120,0,1280,0,10239,0
* ProjU: X = a SETPROJ record (14 bytes, 2 units) to the GPU, its CY (bytes 6-7) the view's center now (fsw's
* FswPrCY); in 480 lines (the 256-color view, GPU_CTRL b1) its FY (bytes 2-3) and CY doubled, the rows being half
* as tall (SE_YMUL scales only the SceneEngine's records). Registers clobbered.
ProjU               ldu       #PjBuf
                    ldb       #ProjRecBytes
pu1@                lda       ,x+
                    sta       ,u+
                    decb
                    bne       pu1@
                    ldd       >FswPrCY            CY: the view's center (fsw's ViewGeo: 82 or 120 rows)
                    std       PjBuf+6
* The full-screen views' 240 rows (the spot and the straight-down views, the dash hidden): FY x 240/164, the
* scenery's own vertical scale there (fswc's ViewSet: the SceneEngine's rows x 2), so the meshes keep their height
* against the runways (2026-10-22, #29: they were 68%). x 375/256 = 1.4648 for the exact 1.4634: FY + H x 119
* + (L x 119) >> 8 with FY = H:L. The cockpit's 164 rows: the record's FY as it is.
                    lda       >FswVRows
                    cmpa      #ViewRows
                    beq       pu2@
                    lda       PjBuf+2             H x 119
                    ldb       #FyGrow240
                    mul
                    pshs      d
                    lda       PjBuf+3             (L x 119) >> 8
                    ldb       #FyGrow240
                    mul
                    tfr       a,b
                    clra
                    addd      ,s++
                    addd      PjBuf+2             + FY
                    std       PjBuf+2
pu2@                ldx       #PjBuf
                    lda       >FswGpCtl
                    bita      #GpuCtl256
                    beq       pu9@
                    ldd       PjBuf+2
                    aslb
                    rola
                    std       PjBuf+2
                    ldd       PjBuf+6
                    aslb
                    rola
                    std       PjBuf+6
pu9@                lda       #GpuOpSetProj
                    ldb       #SetProjUnits
                    lbra      GpUnits
PjBuf               rmb       14
* GpUnits: B units of a record to the GPU: A = the first unit's tag (the rest CONT, $FE), 7 payload bytes a unit
* from X (X advances). They wait in GpQ (64 units: AcFile, free in flight) for one GpuF.Rec: GpFlush when it is
* full, and at the end of Draw and Trf, before fsw's next records. Registers clobbered.
GpQ                 equ       AcFile
GpQEnd              equ       GpQ+64*8
GpUnits             pshs      d
gu1@                ldu       GpQPtr
                    cmpu      #GpQEnd
                    blo       gu2@
                    bsr       GpFlush
                    ldu       GpQPtr
gu2@                ldb       #UnitPayload
gu3@                lda       ,x+
                    sta       ,u+
                    decb
                    bne       gu3@
                    lda       ,s                  the tag pushes the unit
                    sta       ,u+
                    stu       GpQPtr
                    lda       #GpuTagCont
                    sta       ,s
                    dec       1,s
                    bne       gu1@
                    puls      d,pc
GpQPtr              fdb       GpQ                 the next unit's place in GpQ
* GpFlush: GpQ's units to the GPU's record port, one GpuF.Rec; the SceneEngine stopped first when it is there (its
* port feeds the same FIFO unit by unit, and the core merges the two streams without regard to records: a SETMAT,
* five units, with the engine's units inside it would be a cut-short matrix). GpQ emptied. Registers kept but CC.
GpFlush             pshs      d,x,y,u
                    ldd       GpQPtr
                    subd      #GpQ
                    beq       gf9@
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    tfr       d,u                 the units
                    ldy       #GpQ
                    lda       #GpuF.Rec
                    clrb
                    tst       >FswSeOn
                    beq       gf1@
                    ldb       #GpuRec.SeIdle
gf1@                tfr       d,x
                    clra                          GpCall: its SetStat functions
                    lbsr      GpCall
                    ldd       #GpQ
                    std       GpQPtr
gf9@                puls      d,x,y,u,pc

* GpDraw: the model by the GPU (MdlDraw's AcDraw with GpOn): with C at <$68 (FS's Xform3 applies it as
* cam_j = sum over i of d_i C[i][j]) and the eye in model units at <$0C: SETMAT with M[r][c] = C[c][r] and
* T = -(M eye) >> 7 (the GPU: view = (M p >> 7) + T, FX x / z), MESH the airframe; then the prop: its mesh is about
* its hub, turned AcRnd about z: M2 = M Rz, T2 = T + (M hub >> 7), MESH the prop. The records go to GpQ (GpUnits),
* after the scenery's (fsw's Ovl has fed them); GpFlush waits for the SceneEngine's list to end before them.
* Registers clobbered.
GpDraw              jsr       >FswFeed            the scenery's records first: the GPU draws in arrival order
                    ldx       #GpSetup            the light and projection again (SETLIGHT, SETPROJ: ac2gpu.py's)
                    lda       #GpuOpSetLight
                    ldb       #SetLightUnits
                    lbsr      GpUnits
                    ldx       #GpSetupProj
                    lbsr      ProjU
                    ldx       #GpM                M: C transposed
                    ldx       #GpM                M: C transposed
                    clr       GpR
gd1@                clr       GpC
gd2@                ldb       GpC                 <$68 + 6c + 2r (MdlDraw's C = R' x MdlM, with the eye in the
                    lda       #MatRowWords        aircraft's coordinates at <$0C)
                    mul
                    addb      GpR
                    ldu       #vViewM
                    leau      b,u
                    ldd       ,u
                    std       ,x++
                    ldb       GpC
                    addb      #MatIdxStep
                    stb       GpC
                    cmpb      #MatIdxEnd
                    blo       gd2@
                    ldb       GpR
                    addb      #MatIdxStep
                    stb       GpR
                    cmpb      #MatIdxEnd
                    blo       gd1@
* T: for each row r, the 32-bit -(sum over c of Mq(M[r][c], eye_c)) << 8 (Mq rounds the Q15 product >> 15)
                    clr       GpR
gd3@                ldx       #GpM
                    ldb       GpR
                    lda       #MatRowWords
                    mul
                    leax      d,x
                    ldu       #vEyeX
                    ldd       #SumInit
                    std       GpS
                    std       GpS+2
                    ldb       #AxisCount
gd4@                pshs      b
                    ldd       ,x++
                    std       <vMulA
                    ldd       ,u++
                    std       <vMulB
                    jsr       >FswMq
                    lbsr      GpAddS              GpS += D (sign-extended)
                    puls      b
                    decb
                    bne       gd4@
                    lbsr      GpNegS              GpS = -GpS << 8
                    ldx       #GpT
                    ldb       GpR
                    lslb
                    abx
                    ldd       GpS
                    std       ,x
                    ldd       GpS+2
                    std       2,x
                    ldb       GpR
                    addb      #MatIdxStep
                    stb       GpR
                    cmpb      #MatIdxEnd
                    blo       gd3@
                    clr       GpScale
                    lbsr      GpSend              SETMAT, MESH the airframe
                    ldx       #GpMeshB
                    lda       #GpuOpMesh
                    ldb       #MeshUnits
                    lbsr      GpUnits
                    lbsr      GpLamps             its lamps, with the airframe's matrix
* the prop: AcRnd on by the RPM gauge value x 256 (as AcDraw), its sine and cosine
                    lda       >vRpm
                    beq       gd5@
                    cmpa      #PropRpmMax
                    bls       gd4a@
                    lda       #PropRpmMax
gd4a@               clrb
                    addd      AcRnd
                    std       AcRnd
gd5@                ldd       AcRnd
                    jsr       >FsSin16
                    std       GpSn
                    ldd       AcRnd
                    jsr       >FsCos16
                    std       GpCs
                    ldx       #GpM                M2 rows: [M0 cos + M1 sin, M1 cos - M0 sin, M2], T2 = T + (M1 hy + M2 hz) << 8
                    ldu       #GpM2
                    ldy       #GpT
                    ldb       #AxisCount
gd6@                pshs      b
                    ldd       ,x
                    std       <vMulA
                    ldd       GpCs
                    std       <vMulB
                    jsr       >FswMq
                    pshs      d
                    ldd       2,x
                    std       <vMulA
                    ldd       GpSn
                    std       <vMulB
                    jsr       >FswMq
                    addd      ,s++
                    std       ,u
                    ldd       2,x
                    std       <vMulA
                    ldd       GpCs
                    std       <vMulB
                    jsr       >FswMq
                    pshs      d
                    ldd       ,x
                    std       <vMulA
                    ldd       GpSn
                    std       <vMulB
                    jsr       >FswMq
                    coma
                    comb
                    addd      #NegCarry
                    addd      ,s++
                    std       2,u
                    ldd       4,x
                    std       4,u
                    ldd       ,y                  T2
                    std       GpS
                    ldd       2,y
                    std       GpS+2
                    ldd       2,x
                    std       <vMulA
                    ldd       #GpHubY
                    std       <vMulB
                    jsr       >FswMq
                    pshs      d
                    ldd       4,x
                    std       <vMulA
                    ldd       #GpHubZ
                    std       <vMulB
                    jsr       >FswMq
                    addd      ,s++
                    lbsr      GpAddS8             GpS += D << 8 (sign-extended)
                    ldd       GpS
                    std       ,y
                    ldd       GpS+2
                    std       2,y
                    leax      6,x
                    leau      6,u
                    leay      4,y
                    puls      b
                    decb
                    lbne      gd6@
                    ldx       #GpM2               M2 over M for the send
                    ldu       #GpM
                    ldb       #MatBytes
                    lbsr      CpB
                    lbsr      GpSend              SETMAT, MESH the prop
                    ldx       #GpMeshP
                    lda       #GpuOpMesh
                    ldb       #MeshUnits
                    lbra      GpUnits

* GpLamps: the Archer's lamps (ac2gpu.py: left red, right green, tail white, beacon red, landing light white), each
* its own MESH: lit (its own emissive material) with the lights switch $0824 on, else the dark lens GpLOff; the
* beacon lit every other second (FS's clock, $0287); with the lights on at dusk or night ($013F bit 0 clear) and on
* the ground ($0781), the landing light's beam on the ground ahead, screen-doored. Registers clobbered.
GpLamps             ldb       #GpLOff
                    tst       >vLights
                    beq       gp1@
                    clrb
gp1@                ldx       #GpMeshLMat         each lamp's material override
                    lda       #LampCount
gp2@                stb       ,x
                    leax      7,x
                    deca
                    bne       gp2@
                    tstb
                    bne       gp3@                off: all dark
                    lda       >vSecond            the beacon: every other second
                    bita      #BeaconSecBit
                    bne       gp3@
                    lda       #GpLOff
                    sta       GpMeshL+3*7+6
gp3@                ldx       #GpMeshL
                    lda       #LampCount
gp4@                pshs      a
                    lda       #GpuOpMesh          MESH (X advances)
                    ldb       #MeshUnits
                    lbsr      GpUnits
                    puls      a
                    deca
                    bne       gp4@
                    tst       >vLights            the beam
                    beq       gp9@
                    lda       >vLight
                    bita      #LightDay
                    bne       gp9@
                    tst       >vOnGnd
                    beq       gp9@
                    ldx       #GpMeshW
                    lda       #GpuOpMesh
                    ldb       #MeshUnits
                    lbsr      GpUnits
gp9@                rts

* GpSend: SETMAT (five units) from GpM, GpT, GpScale (contiguous: 18 + 12 + 1 bytes, then 4 of padding).
GpSend              ldx       #GpM
                    lda       #GpuOpSetMat
                    ldb       #SetMatUnits
                    lbra      GpUnits

* GpAddS: GpS (32-bit) += D sign-extended. GpAddS8: += D << 8. GpNegS: GpS = -GpS << 8. D clobbered.
GpAddS              pshs      d
                    lda       ,s
                    rola
                    lda       #SignByteBase
                    sbca      #CarryOnly          $FF when negative
                    tfr       a,b                 the sign word
                    pshs      d
                    ldd       2,s                 D
                    addd      GpS+2
                    std       GpS+2
                    puls      d                   (PULS keeps the carry)
                    adcb      GpS+1
                    adca      GpS
                    std       GpS
                    puls      d,pc
GpAddS8             pshs      d
                    lda       ,s
                    rola
                    lda       #SignByteBase
                    sbca      #CarryOnly
                    pshs      a                   sign, D high, D low: the addend's bytes 0-2, byte 3 = 0
                    lda       2,s
                    adda      GpS+2
                    sta       GpS+2
                    lda       1,s
                    adca      GpS+1
                    sta       GpS+1
                    lda       ,s
                    adca      GpS
                    sta       GpS
                    leas      3,s
                    rts
GpNegS              com       GpS
                    com       GpS+1
                    com       GpS+2
                    com       GpS+3
                    ldd       GpS+2
                    addd      #NegCarry
                    std       GpS+2
                    ldd       GpS
                    adcb      #CarryOnly
                    adca      #CarryOnly
                    std       GpS
                    ldd       GpS+1               << 8
                    std       GpS
                    lda       GpS+3
                    clrb
                    std       GpS+2
                    rts

* SeView: the SceneEngine's view registers (rc27), sixteenths of a dot: center 5120, 1312; scale 1280, 328 (320 dots
* and 82 rows per unit of X/Z, Y/Z); largest 10239, 2623 (640 dots, the 164 rows); after SeViewR's GpuF.LPkN
* request header (Se.VDat, mask 0: every byte to the one port, whose index counts up)
SeViewR             fdb       Se.VDat
                    fcb       0,0
SeView              fdb       5120,ViewCY*16,1280,328,10239,2623   the center row ViewCY (fs_wb.d), was the middle (1312)
GpSetup             fcb       $D3,$0B,$66,$C3,$C2,$58,$30,$CF,$00,$00,$00,$00,$00,$00  SETLIGHT: L, AMB 48, DIF 207
                    fcb       $14,$00,$05,$20,$14,$00,(ViewCY*16)/256,(ViewCY*16)&255,$00,$00,$40,$00,$04,$00  SETPROJ: FX 5120, FY 1312 (82 rows x 16), CX 5120, CY ViewCY x 16 (fs_wb.d), NEAR, the clip at NEAR >> 4 (rc27)
GpMeshB             fdb       0,GpNfB,GpNfB+GpNfP
                    fcb       0
GpMeshP             fdb       GpNfB,GpNfP,GpNfB+GpNfP
                    fcb       0
GpMeshL             fdb       GpLF,8,GpLV         the lamps: left wingtip, right, tail, beacon, landing light
                    fcb       0                   (the material override: GpLamps)
                    fdb       GpLF+8,8,GpLV
                    fcb       0
                    fdb       GpLF+16,8,GpLV
                    fcb       0
                    fdb       GpLF+24,8,GpLV
                    fcb       0
                    fdb       GpLF+32,8,GpLV
                    fcb       0
GpMeshW             fdb       GpWF,GpNfW,GpWV     the landing light's beam
                    fcb       0
GpM                 zmb       18                  SETMAT's payload: M, T, scale, pad
GpT                 zmb       12
GpScale             zmb       5
GpM2                zmb       18
GpS                 zmb       4
GpR                 fcb       0
GpC                 fcb       0
GpSn                fdb       0
GpCs                fdb       0
GpPath              fcb       0
GpHdrR              fdb       Gpu.UpAdr           GpHdr's UP_ADDR as a GpuF.LPkN request: UP_ADDR's 3 bytes (mask 3)
                    fcb       3,0
GpHdr               zmb       5
GpN                 fdb       0
GpPc                fdb       0
GpK                 fcb       0
GpKind              fcb       0
GpClut              fcb       0

* EnvDef (FsxReq: fsw.asm's ReqGo at a frame while FswReq, its FswEnvRq bit set by ReqOn at the start; Roger
* 2026-10-25): the start is a crash reset: mode 0 loaded through CMDS/f2 (f2.asm's LoadModeSlot, with its random
* winds), the aircraft back on the start (fswc.asm's StartPos). Not when A (the demo) was chosen: its own load
* (mode 2) follows. A clobbered.
EnvDef              lda       >FswReq
                    anda      #EnvRqClrMask
                    sta       >FswReq
                    tst       >vDemo
                    bne       ed9@
                    lda       #LoadKindCrash
                    sta       >vLoadKind
                    sta       >vOvlReq
ed9@                rts

                    ifdef     WBTRAF
                    use       fst.asm
                    else
GdDraw              rts                           (the Jr2: no GPU, no textured ground)
                    endc

AcFile              equ       *                   the aircraft file, then its work areas

                    ifgt      *-FsxBase-FsxMax
                    error     "fsx: over its block"
                    endc
                    ifgt      AcFile+512-FsxBase-FsxMax
                    error     "fsx: AcFile's 512 bytes (GpLoad's pieces, GpQ, CbLoad's process descriptor) run past its block"
                    endc

                    end
