********************************************************************
* fs_wb.d - Flight Simulator II, WildBits port: definitions shared by FS and its overlays (F2, F3, F4)
*
* The port is WildBits source only: FS, F2, F3 and F4 as they run on the WildBits, with the platform layer in
* fs_wb.asm and the drawing layer in fsw.asm.

FsBase              equ       $A000               the address FS runs at
WbEntry             equ       $5BF0               FS offset of fs_wb.asm's entry table (the original's zero tail)

* fs_wb.asm entry table - fixed addresses, so the overlays can call FS
WbDScrnEnt          equ       FsBase+WbEntry      SS.DScrn: A = path, Y = 0 text screen, else the flight screen

* FS data the platform layer uses
WbScrBlks           equ       $0CCD               FS's "screen number": the bitmap block (high), WbAScrn's first block (low): the K2's clouds', the panel's after it
FsScreen            equ       $0CCF               FS's screen address (WbAScrn: WbScrBase)
FsPath              equ       $0CD6               FS's display path
FsKeyPath           equ       $0CD5               the keyboard path (stdin)
KsLeft              equ       %00100000           SS.KySns: the left arrow (its $08; Backspace's $08 has no bit)
WbGimePal           equ       $0E14               first GIME color of FS's 16 ESC $31 pp cc palette records (4 bytes apart)
* Color 0 is the sky ("the universe"): the bitmaps' see-through nibble shows VICKY's background, which fsw's HzSky
* keeps at FS's sky color (Jr2). FS's black is drawn as FsBlack, whose palette entry fd makes black (sf_wildbits.py
* make_fd: the light red FS never draws).
vSkyCol             equ       $0182               FS's sky color (both nibbles; the scenery and FS's daylight set it)
FsBlack             equ       12                  FS's black in the view (palette entry 12 black, fd)

* The flight screen's map: $4000-$7FFF the scenery window, 16 KB as the K2 SceneEngine's scene RAM: $4000-$5FFF
* FS's own data memory (F$Mem; an overlay's while one runs), $6000-$7FFF a RAM block of its own (WbAScrn's third,
* mapped once, cleared at the exit; it stays through the overlays, so F$Link still puts them at $4000); $8000-$9FFF
* the panel's block (WbAScrn): the panel (CoCo rows 99-191) from $8000, the course plotter's points from $9D10.
* FS's screen base ($0CCF) is $6110, so its rows 99 on land at $8000; its rows 0-98 (the CoCo view, not shown:
* the view is drawn in the bitmaps) lie in the window's second block, and nothing writes them. No device page is
* mapped: the VICKY block's registers are reached through grfdrv256's SS.Gpu (below).
WbScrBase           equ       $6110               FS's CoCo screen base: row 99 at $8000
WbWin2              equ       $6000               the scenery window's second block
WbWinEnd            equ       $8000               the scenery window's end in flight (LoadDataBlock's limit, $0244)

* fsw (port/fsw.asm): the WildBits drawing layer, a raw binary that WbStart loads from /dd/fs2/fsw into FS's
* data area from FswLoad: its part 1 at $1C00-$200F (unused: fd's data ends at $1BFE), zeros over $2010-$280F,
* its part 2 (the entry table first) in FS's freed back buffer at $2750-$3EFF. $2010-$274F: in flight fsw's
* polygon work space and record batch (RecBuf $2550-$274F, 64 records); while a menu runs the overlays' scratch: the
* fd loader's $2010-$2014, f3's scenery selector $2010-$206F (path), $2070-$212F (list table) and the file names
* and menu text from $2200 (below FswRecBuf). $3F00 on is the stack. The view is drawn straight into the HIRES4
* bitmaps by the line engine.
FswLoad             equ       $1C00
FswBase             equ       $2750
FswRecBuf           equ       FswBase-64*8        fsw's RecBuf: 64 records (8 bytes) up to part 2 (40 from 2026-10-18)
FswRecEnd           equ       FswRecBuf+64*8      its end (fswc's text checks it)
FswMax              equ       $3F00-FswLoad
FswInit             equ       FswBase+0           after WbAScrn: bitmap 1, double buffering
FswFrame            equ       FswBase+3           main loop: instruments, then the panel copy
FswPresent          equ       FswBase+6           replaces CopyBackBufToScreen: the view's records drawn, bitmaps flipped
FswRow80            equ       FswBase+9           FillRow80's entry
FswHLine            equ       FswBase+12          DrawHLine's entry
FswPlot             equ       FswBase+18          PlotPixel's entry
FswLine             equ       FswBase+21          DrawLine's entry
FswEdgePix          equ       FswBase+24          FillPolyEdgeEnd's end pixel
FswKeyMap           equ       FswBase+27          the end of PollKeyRead: the K2's F1/F2
FswXform3           equ       FswBase+30          the 3D point transform's nine products (math block)
FswXform2           equ       FswBase+33          the ground point transform's six products (math block)
FswHorizon          equ       FswBase+36          DrawSkyGround past its horizon line: $0192, the sky and ground exactly
FswSceneLoad        equ       FswBase+39          f3's scenery load, then the aircraft onto that scenery's runway
FswScrub            equ       FswBase+42          f3: the loaded scenery's menu text without CoCo palette escapes
FswPVtx             equ       FswBase+45          a 3D polygon vertex, projected exactly (FS's clipper, $4491 / $4322)
FswPFill            equ       FswBase+48          FillPolygon, exactly
FswLine3            equ       FswBase+51          DrawLine for a 3D line, projected exactly ($2C5F)
FswGlyph            equ       FswBase+54          DrawGlyph's entry: no text on the CoCo screen's view rows
FswRect             equ       FswBase+57          FillRect's entry: no fills on the CoCo screen's view rows
FswDelay            equ       FswBase+60          DelayA: the message shown, then the CoCo's delay in ticks
FswPause            equ       FswBase+63          ShowPausedMsg's text, drawn and shown
FswProbe            equ       FswBase+66          the splashdown probe: the color word under the nose (fsw writes it)
FsDrawTextString    equ       $B3D1               DrawTextString
FswGPt              equ       FswBase+68          the ground-point transform (GroundPoint, $D9C5)
FswMatrix           equ       FswBase+71          BuildViewMatrix, then the matrix to the point pipeline
FswQuiet            equ       FswBase+74          the engine sound off until the next frame (all registers kept)
FswOvl              equ       FswBase+77          the main loop's SwitchOverlay: the spot view's model first
FswParts            equ       FswBase+80          DrawViewAircraftParts: not in the spot view
FswSpotKey          equ       FswBase+83          S: the spot view on or off
FswExit             equ       FswBase+86          WbExit: fsx's RAM block back to the system
FswScene            equ       FswBase+89          the main loop's RunDisplayList: on the K2's SceneEngine when it is there
FswSeLoad           equ       FswBase+92          LoadDataBlock's ldx #$0250: the scenery window goes up to the engine again
FswDot              equ       FswBase+95          the DOT op's pixel ($CB53): the light's point <$B8 projected exactly
FsRunList           equ       $C888               RunDisplayList
FsDispNext          equ       $C8A2               RunDisplayListAt+8: the dispatcher's next step (stu <$7B), where op handlers return
FsBuildViewMatrix   equ       $D73C               BuildViewMatrix: the view matrix <$68-<$78
FsSwitchOverlay     equ       $B7D7               SwitchOverlay
FsDrawViewParts     equ       $A63A               DrawViewAircraftParts (the straight-down view's airplane symbol)
FsDispList          equ       $C8AC               DispListDispatch: runs the display list at <$7B to its $19
FsTimerTicks        equ       $F557               ProcessTimerTicks
FsSigIcpt           equ       $F543               SignalIntercept, FS's F$Icpt routine (data pointer $1F10)
FsAtan2             equ       $F887               Atan2Angle: D = the bearing of (<$A5, <$A7)
FsSin16             equ       $D3B9               Sin16: D = an angle -> D = its sine (Q15)
FsCos16             equ       $D3BB               Cos16

* fsx (port/fsx.asm): the spot view's aircraft (the Atari ST's Cessna 182) and its drawing, a raw binary that
* fsw's Init reads from /dd/fs2/fsx into a RAM block of its own. The block is mapped at $8000, in place of the
* panel's, only while fsx runs (fsw's XIn / XOut); FS's signal routine is swapped for fsw's then, so no timer
* tick draws the panel into it. fsw part 1 starts with what fsx uses, at fixed addresses.
FsxBase             equ       $8000
FsxMax              equ       $2000
* fswc (fsw's code block 1, fswc.asm): mapped at FsxBase by fsw's CCall; its entry table
FcSceneLoad         equ       FsxBase+0           f3's scenery load, then the aircraft onto that scenery's runway
FcScrub             equ       FsxBase+3           f3: the loaded scenery's menu text without CoCo palette escapes
FcTaxiSpd           equ       FsxBase+6           taxi mode: the airspeed step on the ground (FS's ComputeAeroAddSpeed)
FcTaxiYaw           equ       FsxBase+9           taxi mode: the turn rate on the ground (FS's ComputeAeroPitchRate)
FcStartPos          equ       FsxBase+12          the crash reset: the aircraft on the game's start (fsw ModeLd)
FcTower             equ       FsxBase+15          the tower, once a frame (fsw's Frame; twr.asm)
FcTwKey             equ       FsxBase+18          a key read (fsw's KeyMap): the tower's and the audio panel's (twr.asm)
FcKeyMap            equ       FsxBase+21          the end of PollKeyRead (fsw's KeyMap): the keyboards' codes, the tower's keys
FcViewSet           equ       FsxBase+24          A = the view mode (fsw ViewGeo): the rows, the center (then fsx's GpView)
FcGlyph             equ       FsxBase+27          DrawGlyph on FS's own view rows (fsw's Glyph)
FcRect              equ       FsxBase+30          FillRect on FS's own view rows (fsw's Rect)
FcPBar              equ       FsxBase+33          A = PFail, B = PStep: the dash's red failure bars (fsw's PBar)
FcInitBm            equ       FsxBase+36          bitmap 1, the first back buffer (fsw's Init): B = its first block
FcDashBm            equ       FsxBase+39          bitmap 2, the dash's, on layer 0 (fsw's Init): A = its first block
FcHzBg              equ       FsxBase+42          A = FS's sky color: VICKY's background its RGB (fsw's HzSky)
* fsw part 1 after PBlk (2026-10-19, taxi mode): FS's patches and its J/K/L keys call these (fsw.asm checks them)
FswFuelKey          equ       $1F7A               Ctrl+F: the fuel tanks alternated (fsw's FuelKey, part 1)
FswReq              equ       $3EE7               fsw's request to fsx at the next frame (fsw.asm's ReqOn; 0 none)
FswEnvRq            equ       $40                 FswReq's bit 6: fsx.asm's EnvDef at the first frame (the start as a crash reset: mode 0 through CMDS/f2)
FsxReq              equ       FsxBase+24          fsx.asm's EnvDef (fsw's Frame while FswReq)
FswTaxiSpd          equ       $1F85              D = the step -> D = the new airspeed (stub: fswc's TaxiSpd)
FswTaxiYaw          equ       $1F8D               the ground turn rate into $076D (stub: fswc's TaxiYaw)
FswBrakeL           equ       $1F95               key J: the left brake
FswBrakeR           equ       $1F99               key L: the right brake
FswBrakeB           equ       $1F9D               key K: both brakes
FswTxBrk            equ       $1FA8               the brakes held: b0 left, b1 right
FswTxBrkT           equ       $1FA9               aerodynamics steps the brakes stay on after a key (its auto-repeat)
FswTxSmart          equ       $1FAA               smart taxi, F2's FIX MODE page 1: 1 taxi mode (fswc), 0 FS's own
FswViewKey          equ       $1FCD              key I: the GPU view 320 x 256 colors <-> 640 x 16 (fsw ViewKey)
FswBrdSv            equ       $1FFB              the OS's border (6 bytes), saved by fsx's GpInit, put back by fsw's XExit
FswBrdOn            equ       $2001              1: FswBrdSv holds the OS's border, the border shows the view's state
FswGfxKey           equ       $2002              keys D, E: the dither, the line ribbons (fsw GfxKey)
FswGfxOn            equ       $1BFF              the GPU view's switches (FgRibbon): off at the start (fsx's GpInit),
*                                                fsx's key E; the free byte between fd's data ($1BFE) and fsw ($1C00)
FgRibbon            equ       %00000001          the SceneEngine's line ribbons on (LW SeLw)
* the view's state on the border (fswc's Ind): 4 rows top and bottom in 320 x 256 colors, 12 in 640 x 16; green the
* line ribbons on, blue the dither on
SeLw                equ       256                the SceneEngine's line half width (rc26_gpu3 LW), 1/256 list units:
*                                                256 = one unit each side of the line, a road 32 m wide at the area
*                                                origins' 16 m units, a runway or taxiway line 2 m wide at their 1 m units
* The game's start (fd, sf_wildbits.py start_position: 9C, 120 m in, heading 090): X and Z (32 bits, 1/256 m),
* the heading byte. fsw's ModeLd puts the aircraft back there after a crash reset, fswc's SceneLoad after a load
* of sf.wildbits.
FsStartXHi          equ       $00BB
FsStartXLo          equ       $5B00
FsStartZHi          equ       $035F
FsStartZLo          equ       $6E00
FsStartHdg          equ       $40
FsxDraw             equ       FsxBase             the aircraft drawn from the spot eye (fsw's Ovl)
FsxCam              equ       FsxBase+3           the spot view's camera (fsw's SpotCam, for Matrix)
FsxGpInit           equ       FsxBase+6           rc26's GPU set up (fsw's Init)
FsxTraffic          equ       FsxBase+9           fst's actors in a frame that is not a spot frame (fsw's Ovl)
FsxViewKey          equ       FsxBase+12          key I: the GPU view 320 x 256 colors <-> 640 x 16 (fsw's ViewKey, XCall)
FsxGfxKey           equ       FsxBase+15          keys D, E: the dither, the line ribbons (fsw's GfxKeyS, XCall)
FsxGpView           equ       FsxBase+18          the GPU's and the SceneEngine's view for fswc's ViewSet's rows (fsw's ViewSet)
FsxGround           equ       FsxBase+21          the textured ground over the sky and ground split (fsw's GdCall, the K2's fst)

* fsp (port/fsp.asm): the dashboard, a raw binary read by fsw's PInit from /dd/fs2/fsp into a RAM block of its
* own, mapped at FspBase (fsx's window, in place of the panel's block) only while it runs (2026-10-17).
FspBase             equ       $8000
FspMax              equ       $2000
FspInit             equ       FspBase             the art into bitmap 2 and the pristine copy, its palette (fsw's Init): A = bitmap 2's first block, X = fsp's block, U = the pristine copy's first block; carry set: B = the step that refused
FspFrame            equ       FspBase+3           the instruments, every frame (fsw's Frame): A = bitmap 2's first block, B = its plane bits
* The dash's clicks: fsp pokes FS's variables itself, but FS's own routines that redraw its CoCo panel write the
* $8000 block, fsp's while it runs, so fsp leaves an action here (code, then A and B for it) and fsw runs it after
* the panel's block is back (fsw PAct). $2010-$2013 is fsw's polygon work space, idle between frames.
FspAct              equ       $2010               0 none, else one of the FspAct* codes
* fsw's variables fsx's GpInit sets (fsw checks these addresses)
FswHwGpu            equ       $27C6              HwGpu: 1 when rc26's GPU draws the view
FswFrontBm          equ       $27B2              FrontBm, then BackBm (2 bytes each)
FswSeOn             equ       $1DC6               SeOn: the SceneEngine is there
FswSeFlt            equ       $1DC7               SeFlt: the SceneEngine's faults (fst's state code while it runs)
FswTfBrg            equ       $3EF0               fst's readout on the rate panel: the actor's bearing from the nose (degrees clockwise)
FswTfDst            equ       $3EF2               and its distance in hundreds of meters (999: none)
FswPrCY             equ       $3EF4               fsw's Proj: the view's center row in sixteenths (ViewCY's with the GPU)
FswTwKey            equ       $3EF6               a tower key (fsw's KeyMap: F5 $A5, O, o: talk; -: the XPDR's digits), 0 none
FswTfPt             equ       $3EF7               the actor's plan point (fst's TfAtPt), $FF none: the tower's view of it
FswAud              equ       $3EF8               the audio panel's buttons (Ctrl+R, 1-6; fswc's TwKey): b0 COM1, b1 COM2,
*                                                 b2 NAV1, b3 NAV2, b4 ADF, b5 MKR; 1 heard (fsp lights them)
FswCom2             equ       $3EF9               COM2's frequency, BCD past 100 ($2115: 121.15; twr.asm tunes it, Ctrl+K)
* ViewCY: the K2 GPU view's center row (bitmap rows 0-163 drawn; Roger 2026-10-19: the horizon midway in what shows
* above the dash, whose top is row 147); fsw's Proj (FswPrCY), the scenery engine's view (fsx SeView), the GPU's
* projection (fsx GpSetup, fst BdProj, ac2gpu.py's CY) all take it, on both machines (fsw's PrCYV; the Jr2's lines
* and fills cut at the view's top by fsw's LRec / EdgeSet, FS's own rows moved by MapRow).
ViewCY              equ       82                  the cockpit view's center row (fsw ViewGeo): the clip box covers its 164 rows
* VISIBILITY_KM (Roger 2026-10-24): how far 3D objects are seen, in every view. The K2's meshes (fst's BdTab) and
* every range test of the scenery that guards a 3D object, a runway or dots (sf_wildbits.py reads this line) are
* held to it; ground shapes and radio stations keep their own ranges. VisUnits: the same in map units (256 m).
VISIBILITY_KM       equ       20
VisUnits            equ       VISIBILITY_KM*1000/256
ACTOR_TRAIL_LENGTH  equ       8                   the actor's smoke trail, in puffs (one every 2 s; fst's TfTrail)
TOTAL_CLOUDS        equ       24                  the K2's clouds kept around the aircraft (fscl's ClLive, fs.md)
FswVRows            equ       $3EEF              fsw's VRows: the view's rows, 164 or 240 (the dash hidden)
FswVMaxY            equ       $3EED              fsw's VMaxY: Proj's last row, sixteenths (VRows x 16 - 1)
FswClipIn           equ       $3EB4              fsw's ClipIn: FS's four clip-plane cuts begin there (both ends within +-16383)
FswRecPtr           equ       $3EEB              fsw's RecPtr: the next record's place in RecBuf (fswc's text)
FswFeed             equ       $29A4        Feed: the records so far to the GPU (fsx: the model's go after the scenery's)
FswHwPp             equ       $27C5              HwPp: the K2's point pipeline is there (fsx's probe)
FswGdOn             equ       $27C4              GdOn: 1 the ground on: the clouds' shadows (fscl ShOne) and the meadow near the
*                                                airports; 0 off (the start; F8, fswc's KeyMap; F2's GROUND TEXTURE)
FswPpOk             equ       $27DA              PpOk: the pipeline's eye and base sums are PpEye / PpBase
FswLl               equ       $27C8              Ll: FS's long-line op's 16.8 positions and steps (18 bytes)
* FS's own variables (the originals' addresses in FS's data; "Assign symbols to unknowns", 2026-10-21)
* The start spot: fd sets it to the game's start (FsStart*, the record at $00F5 in fd; make_fd keeps it); the airport
* menu (f5) moves it; a crash reset (fswc's StartPos, kind 1) puts the aircraft there, so "as if the game started
* there" (Roger 2026-10-22). $00F5-$00FF: FS's direct page past fd's first record, used by nothing else.
vStartX             equ       $00F5               X: map square (high word), then 1/256 m (low word)
vStartZ             equ       $00F9               Z, the same
vStartHdg           equ       $00FD               heading, 1/256 turn
vStartRot           equ       $00FE               the start runway's rotation point, 90% of its length along its larger axis, m (fd, f5,
*                                                 fswc's SceneTab set it; nothing reads it since 2026-10-23: auto mode is FS's own again)
* FS's variables found while debugging (2026-10-22)
vPosX               equ       $0000               the aircraft's X: map square, then 1/256 m (32 bits)
vAlt                equ       $0004               its height (32 bits; $0301 on the ground at the start)
vElevArea           equ       $0145               the area's ground elevation, which the scenery list sets (m)
vElev               equ       $07F6               the ground elevation under the aircraft (m): stepped toward vElevArea 2 a frame
*                                                 (UpdateGroundElev), vAlt's height above ground moved the other way, so
*                                                 the altitude above sea level holds; FS draws the ground at y 0 always
vPosZ               equ       $0008               its Z, as X
vViewM              equ       $0068               FS's view matrix C: three rows (x, y, z) of three Q15 words, the view's aspect
*                                                 in its columns (x and z / 4, y x 0.4858)
vMapView            equ       $0139               not 0: the map view
vLight              equ       $013F               1 day, 2 dawn and dusk, 4 night (UpdateDaylight)
vTickPend           equ       $0896               FS's pending timer ticks (ProcessTimerTicks counts them down)
vEdTyped            equ       $02BB               F2's editor: not 0 once a digit was typed into the field
vEdPage             equ       $02D2               F2's editor: the page move a key asked for (+1 next, -1 previous)
vPitch              equ       $0012               the view's pitch
vBank               equ       $0014               the view's bank
vHdg                equ       $0016               the heading (1/256 turn in the high byte)
vLoadKind           equ       $020C               the mode load's kind: 1 a crash reset, 3 the demo start (F2)
vOvlReq             equ       $0221               the overlay requested (1 F2, 4 f5, 0 none)
vDemo               equ       $02C7               1: A (demo) chosen at the start: one mode-3 load, then cleared
vReality            equ       $0305               reality mode (the engine must be started; F2's start load clears it)
vMag1Ok             equ       $0736               magneto 1 works (reliability failures)
vMag2Ok             equ       $0737               magneto 2 works
vEngineOn           equ       $0738               the engine runs
vOnGnd              equ       $0781               $FF on the ground
vHdgCopy            equ       $0782               the heading's copy, written back each frame
vAirspeed           equ       $07BB               airspeed, 1/256 m/s
vAileron            equ       $0812               the ailerons
vElevator           equ       $081A               the elevator
vMagSw              equ       $0825               the magneto switch: 0 off, 1 R, 2 L, 3 both, 4 start
vThrottle           equ       $0837               the throttle (the high byte, notches of 8)
vStickY             equ       $0890               the right stick's last Y (the mouse: WbJoy)
vStickYL            equ       $0894               the left stick's last Y
vMag1               equ       $0DCB               magneto 1 on
vMag2               equ       $0DCC               magneto 2 on
vHour               equ       $0321               FS's clock: the hour 0-23 (ProcessTimerTicks; F2's TIME: HOURS)
vMinute             equ       $0322               the minute 0-59 (F2's MINUTES)
vSeason             equ       $0323               the season: 1 winter, 2 spring, 3 summer, 4 fall (F2's editor; daylight, carb ice)
* FS's own cloud layers: m at $0158-$015E (layer 1 bottom and top, layer 2 bottom and top), from which the scenery
* list drew a solid deck under the aircraft above layer 1 and a white or gray sky under layer 2. Never set since
* 2026-10-23 (F2's ApplyClouds no longer converts the menu's feet into them: Roger, "we won't use that mechanism"),
* so the list never draws them. The K2's 3D clouds (fscl.asm) read the menu's own feet.
vCld2TopFt          equ       $0324               the menu's cloud layer 2 tops, ft
vCld2BotFt          equ       $0326               cloud layer 2 bottoms
vCld1TopFt          equ       $0328               cloud layer 1 tops
vCld1BotFt          equ       $032A               cloud layer 1 bottoms
vShear1             equ       $032C               shear zone altitude 1, m in flight (F2 shows feet): under it the surface wind
vShear2             equ       $032E               shear zone altitude 2: under it wind 1
vShear3             equ       $0330               shear zone altitude 3: under it wind 2, above it wind 3
vWind3              equ       $0332               wind level 3: knots (the rest of 100, the hundreds), direction (a 16-bit angle)
vWind2              equ       $0336               wind level 2
vWind1              equ       $033A               wind level 1
vWindSfc            equ       $033E               the surface wind
vHdgOfs1            equ       $0148               the area's heading offset (its high byte turns the winds and the runways)
vHdgOfs2            equ       $014A               the second (its high byte turns the surface wind and the runways too)
vClouds             equ       $019C               the scenery's clouds: bit 0 of the word on (sf_clouds.py's test; fd starts it off;
*                                                 K2 F7 / Alt+C toggle it, fswc KeyMap; F2's CLOUDS RENDER MODE); in the range fsw
*                                                 copies to the SceneEngine
FsBdFlag            equ       $019E               word: 1 while fst draws O'Hare's buildings and the Sears Tower as GPU meshes (sf.wildbits skips its boxes); fsw's Init clears it
* The VICKY block's registers FS2 uses (VICKY_BLK, $FC): offsets in that block, reached only through grfdrv256's
* SS.Gpu on FS's display path (defs/wildbits.d: GpuF.LPk8 / LPk16 / LPkN a register or a run, GpuF.Rec the GPU's
* records, GpuF.SceneL / GpuF.SeOut the SceneEngine). X = GpuF.x * 256 + VICKY_BLK for the long pokes and peeks.
* rc26's GPU (offset $1800)
Gpu.Ctrl            equ       $1800               CTRL: b0 EN, b1 the 320 x 256-color view, b2 z, b3 dither, b4 RESET, b5 autoclear, b7 SEPORT
Gpu.Free            equ       $1802               FIFO_FREE (records)
Gpu.Row0            equ       $1806               VIEW_ROW0, then VIEW_ROWS
Gpu.Rows            equ       $1807               VIEW_ROWS, its low byte (164: $A4; 328 in 480 lines: $48)
Gpu.Lut             equ       $1808
Gpu.Clear           equ       $1809               CLEAR_COLOR
Gpu.UpAdr           equ       $180A               UP_ADDR (3 bytes)
Gpu.UpDat           equ       $180D               UP_DATA: a byte at UP_ADDR, which counts up
Gpu.YMul            equ       $180E               SE_YMUL: the SceneEngine records' row scale, x 1/1024
Gpu.Prb             equ       $1810               PROBE_ROW, then PROBE_DOT
Gpu.PCol            equ       $1814               the probe's color
Gpu.Mode480         equ       $181B               b0: with CTRL b1 (320 x 256 colors), 320 x 480 (Roger 2026-10-21)
Gpu.RowsH           equ       $181D               VIEW_ROWS' high bit (1: 328 rows)
Gpu.Id              equ       $181F
Gpu.Rec             equ       $1840               the record port: bytes 0-6 latch, byte 7 pushes the unit
* the K2's SceneEngine (offset $1780)
Se.Out              equ       $1780               R the OUT FIFO's head word (pops)
Se.Stat             equ       $1782               R STATUS / W command
Se.Cnt              equ       $1783               R COUNT, the OUT words there / W control
Se.Addr             equ       $1784               the upload address (16 bit)
Se.Data             equ       $1786               W a byte at ADDR, ADDR + 1
Se.Lp               equ       $1787               W the list pointer RESUME starts at (16 bit)
Se.VIdx             equ       $178B               the view register index
Se.VDat             equ       $178C               the view registers' byte at the index, which counts up
Se.Lw               equ       $178D               LW: the line half width, +D high, +E low
FswGpCtl            equ       $27C7              GpCtl: Gpu.Ctrl as last written (fsx's GpInit, fswc's keys, fsw's GpOff)
FswMq               equ       FswLoad+0           jmp Mq: <$AF * <$B1 (Q15, rounded) -> D
FswMatLoad          equ       FswLoad+3           jmp MatLoad: <$68-<$78 to the point pipeline
SpPos               equ       FswLoad+6           the aircraft's position while the eye is in <$00-<$0B (12 bytes)
SpNew               equ       FswLoad+18          nonzero: the first spot frame since S
FswSpOn             equ       FswLoad+19          SpOn: the spot view chosen (fswc's DashSp: the dash hidden)
FsGPtOvZ            equ       $DA46               GroundPtOvZ: FS's dZ overflow path
FsGPtOvX            equ       $DA53               GroundPtOvX: FS's dX overflow path
FsDrawGlyph3        equ       $B350               DrawGlyph past its ldx #$14C0
FsFillRect4         equ       $B3F2               FillRect past its std <$90 / stx <$92
F3LoadScenery       equ       $44EF               f3's LoadSceneryFile (f3 runs at $4000; f3.asm checks it)

* FS addresses fsw goes back to; fs_wb.asm part 2 checks each against FS's labels
FsDrawHLine8        equ       $B0DC               DrawHLine past its $9F00 test
FsFillRowFull       equ       $B09F
FsFillRow80x4       equ       $B0A6               FillRow80 past pshs cc,dp / orcc #$10
FsPlotPixel5        equ       $AF1A               PlotPixel past pshs a / ldx #$1538
FsDrawLine4         equ       $AF47               DrawLine past stx <$9A / cmpa <$9A
FsUpdInstMasks      equ       $FB07               UpdateInstrumentMasks
FsPolyRetire        equ       $B326               FillPolyRetireEdge
FsXform3Soft        equ       $DC22               the 3D point transform's products in software
FsXform2Soft        equ       $DA7D               the ground point transform's products in software
FsXform2Sums        equ       $DB7E               the ground point transform past its products

* ---- Named by the FS2 symbolization: every address an FS2 instruction used as a raw number
* FS's direct page (page 0): the variables and scratch bytes FS and the WildBits layers address there
vEyeX               equ       $0C                 the eye's x relative to the running display list's origin, in its units (GroundPoint: dX = x - it)
vEyeY               equ       $0E                 the eye's height, the same (the lists' range tests read it)
PsgDivLoMask        equ       $0F                 the SN76489 latch byte's data bits: a tone divider's low 4 bits
vEyeZ               equ       $10                 the eye's z, the same (GroundPoint: dZ = z - it)
EnZoneMinZ          equ       $11                 f4 enemy record: attacking, the player's Z map square must stay above it, else it turns home
EnSpeedX            equ       $13                 f4 enemy record: the X step a frame toward the target (into its X position's low byte)
EnSpeedY            equ       $14                 f4 enemy record: the altitude step a frame toward the target
EnSpeedZ            equ       $15                 f4 enemy record: the Z step a frame toward the target
EnFireRange         equ       $16                 f4 enemy record: it fires when the range ($123B) is at most this
EnStatus            equ       $17                 f4 enemy record: 0 shot down, 1 returning home, 2 attacking
EnEvadeCnt          equ       $18                 f4 enemy record: frames left of the evasive climb (positive) or descent (negative) after a shot
SidModeVol          equ       $18                 SID register $18: the filter mode (high nibble), the volume (low nibble)
vViewPitch          equ       $18                 the view's pitch, 16-bit angle: BuildViewMatrix's from vPitch and the view direction (fsx SpLook's)
EnEvadeLen          equ       $19                 f4 enemy record: the evade count loaded after each shot
EnHomePtr           equ       $1A                 f4 enemy record: its home position (ComputeTargetDelta aims at it when returning)
vViewBank           equ       $1A                 the view's bank, 16-bit angle (BuildViewMatrix, fsx SpLook)
EnRecLen            equ       $1C                 f4 enemy record's length: 28 bytes, six records at $1310-$13B7
vViewHdg            equ       $1C                 the view's heading (camera yaw: vHdg + the view direction), 16-bit; fsw's Matrix sets its low byte
vGlyphBits          equ       $1E                 DrawGlyph: the glyph's rows, 3 bits each from the low end, over a stop bit ($8000)
vMarkerPos          equ       $20                 a panel slide or vertical marker's place: byte column, then row
vNeedleCtr          equ       $20                 DrawDialNeedle: the needle's center: row, then pixel x (the slip ball's x at +1)
vTextPos            equ       $20                 DrawTextString's place: pixel x (+4 a character), then row
vSkyGndUnread       equ       $22                 a byte DrawSkyGround clears after its horizon list; no code or scenery list reads it
vEyeXSave           equ       $23                 DrawSkyGround: vEyeX kept while the horizon list runs at the origin
vEyeZSave           equ       $25                 DrawSkyGround: vEyeZ kept while the horizon list runs at the origin
LlDiffOfs           equ       $2F                 LlInit: from the start (<$B8) back to the ends' difference (<$89): $B8-$89 bytes
vNeedleRtn          equ       $39                 DrawDialNeedle's draw or erase routine, jumped through (DrawNeedleSaveBg / EraseNeedleRestoreBg)
vLineDX             equ       $3B                 DrawLine: x2 - x1, pixels (the Bresenham steps' dx)
vNeedleMirror       equ       $3B                 DrawDialNeedle: $FF the needle shape mirrored left to right, 0 not
vLineDY             equ       $3C                 DrawLine: y2 - y1, rows, signed
vNeedleRowStep      equ       $3C                 DrawDialNeedle: the shape's row step, $50 down or $B0 (-$50) up
vAltSmallHand       equ       $3D                 the altimeter's small (thousands) hand, dial position 0-87 (DrawAltimeter; fsp draws it)
vAltBigHand         equ       $3E                 the altimeter's big (hundreds) hand, dial position 0-87 (DrawAltimeter; fsp draws it)
vVsiTarget          equ       $3F                 the VSI needle's target dial position 0-87 (CalcVsiNeedle; UpdVsiNeedle steps $0D21 to it)
vFrameCount         equ       $40                 FS's frame counter: +1 each main-loop pass (MainLoopNextFrame); its low bits pick the phase work, also read as a random byte
vBaseSumX           equ       $42                 GroundPoint's base sum for camera x, 24 bit (+0 high): the eye's height through the view matrix (0 for the horizon line)
vVmSinPCosHSinB     equ       $42                 BuildViewMatrix: sin pitch x cos heading x sin bank (Q15), for its x-row entries
vBaseSumY           equ       $45                 GroundPoint's base sum for camera y, 24 bit (+0 high)
vVmSinPCosHCosB     equ       $45                 BuildViewMatrix: sin pitch x cos heading x cos bank (Q15)
vBaseSumZ           equ       $48                 GroundPoint's base sum for camera z (depth), 24 bit (+0 high)
vPointExp           equ       $4D                 the last camera point's scale exponent: 64 + the bits GroundPoint shifted it up, 0 after Xform3 ($0271 the one before)
vXformHalve         equ       $4E                 not 0: the 3D transform's tail halves the three camera words; Xform3 clears it, nothing sets it
FsElevFull          equ       $50                 the elevator's full travel: vElevator's high byte -$50..$4F (the stick's -$5000..$4F68)
FsRowBytes          equ       $50                 a CoCo screen row: 80 bytes, 160 dots of 4 bits
vDispListSave       equ       $53                 DrawSkyGround: the display list pointer kept over the horizon list (else the area op's eye-height cache)
vSceneryNameEnd     equ       $55                 f3's scenery selector: the file name's end, in the path ($0250) while it is split, then in the name buffer ($2030)
vVmHdg              equ       $56                 BuildViewMatrix: the heading's high byte, turned 180 degrees when the attitude is folded (bank past 90 degrees)
vModeRecPtr         equ       $57                 f2's CopyModeRecord: the mode's 65-byte record address (the table's base, then the slot)
vSceneryDirEnd      equ       $57                 f3's scenery selector: the directory's end, in the path ($0250) while it is split, then in the directory buffer ($2010)
vVmViewDir          equ       $57                 BuildViewMatrix: the view direction, $0839's low nibble x 16 (1/256 turn)
vVorObs             equ       $58                 ComputeVorDeviation: the OBS course (2-degree units), kept over ComputeStationBearing
vGPtSumX            equ       $5D                 GroundPoint's camera x sum, 24 bit (+0 high) while scaled; after Xform2: +0 bits 15-0, +2 bits 23-16
vVmCosP             equ       $5D                 BuildViewMatrix: cos pitch (Q15)
vGPtSumY            equ       $60                 GroundPoint's camera y sum, 24 bit, as vGPtSumX
vVmSinHSinB         equ       $60                 BuildViewMatrix: sin heading x sin bank (Q15)
vGPtSumZ            equ       $63                 GroundPoint's camera z (depth) sum, 24 bit, as vGPtSumX
vVmSinPSinHCosB     equ       $63                 BuildViewMatrix: sin pitch x sin heading x cos bank (Q15)
MoToneN             equ       $6E                 the Morse tone's PSG divider: 3.58 MHz / 32 / 110 = 1017 Hz (twr.asm's MoTone)
vEnd2Cut            equ       $7A                 FS's 3D line: not 0 when the clipper cut its second end (vEnd2Clip; the uncut end kept at <$C9); 0 at the list's start
vViewMEnd           equ       $7A                 the end of vViewM's 18 bytes (vViewM+18)
vDispListPtr        equ       $7B                 the display list's next byte (RunDisplayListAt, the op handlers, fsw's SceneEngine resume)
vGlyphKeep          equ       $7D                 DrawGlyph: the masks of the dots kept in the glyph's two screen bytes (word)
vLineKeep           equ       $7D                 DrawLine: the screen byte's mask of the other dot ($0F or $F0)
vLineColor          equ       $7E                 DrawLine: the line's color in the dot's nibble
vGsHgtHalf          equ       $83                 UpdateGlideslopeDme: the height ($07F9) halved, divided by the station distance <$AB
vGsSlopeHalf        equ       $89                 UpdateGlideslopeDme: the glideslope beam's slope ($0152) halved, as the height/distance quotient is
vPointDX            equ       $89                 the 3D and ground point transforms: the point's X less the eye's (16 bit, scaled by FS)
vPointDY            equ       $8B                 the 3D point transform: the point's Y less the eye's (16 bit, scaled by FS)
vPointDZ            equ       $8D                 the 3D and ground point transforms: the point's Z less the eye's (16 bit, scaled by FS)
vAltBandRem         equ       $90                 DrawAltimeter: the scaled altitude within its $0370 band, the needles' source
vAttPitchOfs        equ       $90                 UpdAttitudeIndEnds: TblAttPitchRow's horizon offset for the pitch (1/256 turn)
vDecPlace           equ       $90                 DecDigitBySub: the digit's place value (10000, 1000, 100 or 10), subtracted until it no longer fits
vFuelBurnStep       equ       $90                 UpdateEngineFuelRate: the fuel this step burns (the rate x the throttle, negative), added to the tank
vRectX1             equ       $90                 FillRect: the rectangle's left x (A on entry)
vSpdCtlEffect       equ       $90                 ComputeAeroForces: TblSpeedControlEffect at the airspeed, the factor of $0790 and $0792 (Q15)
vTcNewIndex         equ       $90                 UpdTurnCoord: the turn coordinator airplane's new index (0-15), drawn when not $0800
vTcRateX2           equ       $90                 UpdTurnCoord: the turn rate ($076D) times 2, added to its times 4 for times 6
vWindDirSin         equ       $90                 ComputeWindComponents: the sine of the wind's direction (Sin8's high byte)
vXSortSlot          equ       $90                 FillPolySortX: the crossing list's slot a pass fills with the largest x left
vRectX2             equ       $92                 FillRect: the rectangle's right x (X's high byte on entry)
vWindDirCos         equ       $92                 ComputeWindComponents: the cosine of the wind's direction (Cos8's high byte)
vXSortLeft          equ       $92                 FillPolySortX: the entries a pass still compares
vRectRows           equ       $93                 FillRect: the rows left to fill (bottom - top + 1 down to 0)
vRectY2             equ       $93                 FillRect: the rectangle's bottom row (X's low byte on entry)
vAdfErasePos        equ       $9A                 UpdAdfNeedleScale: the ADF needle's old position ($09A7), erased before the new one is drawn
vAsiSpeedHi         equ       $9A                 CalcAirspeedNeedle: the airspeed's high byte clamped to 90, TblAirspeedDial's index and fraction
vAttEndAngle        equ       $9A                 UpdAttitudeIndEnds: a horizon end's angle on the ball (1/256 turn), for Cos8 and Sin8
vBcdHiNib           equ       $9A                 Ascii4ToBcd, SetAdfFreq: a digit moved to the high nibble, ORed with the next digit
vCompassTarget      equ       $9A                 DrawMagCompass: the heading less vHdgOfs2 and vHdgOfs1 (16-bit angle), that $0216 is damped toward
vDecRest            equ       $9A                 Dec3ToAscii, Dec5ToAscii: the number still to convert (16 bit), less each digit's place values
vDialNeedlePos      equ       $9A                 DrawDialNeedle: the needle's dial position, 0-$57
vDivSign            equ       $9A                 DivQ15Signed: the quotient's sign ($FF negative, 0 positive)
vEdKeyDigit         equ       $9A                 F2's editor: the digit key typed (ASCII), kept across the field's blanking
vFileRowsLeft       equ       $9A                 f3's DrawFileList: the file list's rows left to draw (11 down to 0)
vGlyphRowPix        equ       $9A                 DrawGlyph: a glyph row's two pixel bytes in the text color ($0201)
vHLineLastByte      equ       $9A                 DrawHLine: the row byte of the span's last whole byte (right x / 2)
vHLineRightX        equ       $9A                 DrawHLine: the span's right x (A on entry)
vInstMaskNew        equ       $9A                 UpdateInstrumentMasks: an instrument mask byte, present & working & visible, before it is stored
vKeyByte            equ       $9A                 PollKeyRead: the key byte I$Read puts here (fsw's and twr's FsKey)
vLineLeftX          equ       $9A                 DrawLine: the left end's x (X's high byte once the ends are sorted)
vSlewStepHi         equ       $9A                 SlewRateToDelta: the slew step's bits 23-16 (D its bits 15-0), added into X, Z
vTcWingEnd          equ       $9A                 DrawTurnCoordPlane: the wing line's first end (x, row), DrawLine's X
vLineLeftRow        equ       $9B                 DrawLine: the left end's row (X's low byte once the ends are sorted)
vMulQ15Lo           equ       $9C                 the Q15 multiply: the rounded product's bits 15-8, its bit 7 shifted into the result's bit 0
vAtanYLo            equ       $A3                 ComputeStationBearing: dZ's low word, shifted into vAtanY while the deltas are normalized
vBankFolded         equ       $A3                 BuildViewMatrix: the bank (vBank), a half turn off when past 90 degrees, before the view direction's turn
vDriftSignExt       equ       $A3                 ApplyWindDrift: the drift word's sign byte ($0742 or $0744 sign extended: 0 or $FF)
vEnemyLineX0        equ       $A3                 f4's DrawEnemyShape: the shape line's start x, screen dots
vHypotMax           equ       $A3                 f4's ApproxHypot: the larger magnitude
vPlotDeltaHi        equ       $A3                 the course plotter: a point's 24-bit delta from the start, its high byte (D the low word)
vSfListTop          equ       $A3                 f3's scenery menu: the file list's index on the menu's top row (row 3)
vStnBearing         equ       $A3                 ComputeStationBearing's result: the bearing to the station (16-bit angle, less the area's heading offsets)
vVorDev             equ       $A3                 ComputeVorDeviation: the CDI deviation, OBS minus the bearing scaled by $021C (0: no signal)
vEnemyLineY0        equ       $A4                 f4's DrawEnemyShape: the shape line's start y, screen rows
vMag1Fires          equ       $A4                 UpdateEngine: magneto 1 fires (vMag1 and vMag1Ok)
vRudderHalf         equ       $A4                 UpdatePitchCtlTerms: the rudder ($082B) / 2, taken from the ailerons / 2 for $0761
vSfCount            equ       $A4                 f3's scenery menu: the sf.* files in the list (ReadSceneryDir counts them)
vTrackHdg           equ       $A4                 UpdateFlightVelocity: the direction of travel, 1/256 turn: vHdgCopy plus $07B5 in the air
vAtanX              equ       $A5                 Atan2Angle's x (the east delta): D = the bearing of (vAtanX, vAtanY), 0 along +y, clockwise toward +x
vEnemyLineX1        equ       $A5                 f4's DrawEnemyShape: the shape line's end x, screen dots
vHypotMin           equ       $A5                 f4's ApproxHypot: the smaller magnitude (the first operand's until they are ordered)
vOvlNamePtr         equ       $A5                 SwitchOverlay: the overlay's module name (its TblOverlayNames entry) for F$Link and F$Load
vScaleWordsLeft     equ       $A5                 f2's ConvertWindTables: the altitude words at $015E still to scale (7 down to 0)
vSfDirOpen          equ       $A5                 f3's scenery menu: not 0 while the directory is open (path $0CD7)
vEnemyLineY1        equ       $A6                 f4's DrawEnemyShape: the shape line's end y, screen rows
vSfLoadErr          equ       $A6                 f3's scenery menu: not 0 when the last scenery load failed (MenuExit shows the error)
vAtanY              equ       $A7                 Atan2Angle's y (the north delta)
vViewDirCos         equ       $A7                 BuildViewMatrix: the cosine of the view direction (<$57), Q15
vWindmillRpm        equ       $A7                 UpdateEngine: the windmilling RPM at the airspeed (TblWindmillRpmByAirspeed), the RPM's floor
vAtanXLo            equ       $A9                 ComputeStationBearing: dX's low word, shifted into vAtanX while the deltas are normalized
vInterpBase         equ       $A9                 InterpBySpeed: the table's byte at the airspeed's index, the base the fraction's step is added to
vAdfNeedleAng       equ       $AB                 UpdAdfNeedle: the needle's angle (the station's bearing off the nose + 90 degrees) halved; nothing reads it
vAtanTblEntry       equ       $AB                 AtanRatioLookup: the arctangent table's ($10F4) entry at the ratio's step
vStnDist            equ       $AB                 ApproxStationDistance: the station's distance, max + min^2 / (2 max) of |$0728| and |$072A| (before it, the smaller)
vViewDirSin         equ       $AB                 BuildViewMatrix: the sine of the view direction (<$57), Q15
vPitchFolded        equ       $AD                 BuildViewMatrix: the pitch (vPitch), $8000 minus it when the bank was folded
vStnDistMax         equ       $AD                 ApproxStationDistance: the larger of |$0728| and |$072A|
vDensityDrop        equ       $AF                 FlightAuxUpdate: 2.5 x the altitude $0132, taken from $7FFE for the air density factor $0749
vDivQuot            equ       $AF                 DivQ15Signed: the dividend's magnitude, then the Q15 quotient (D too)
vInstNewOn          equ       $AF                 UpdateInstrumentMasks: the mask bytes in which an instrument came on (not 0: the panel is redrawn)
vMarkerWide         equ       $AF                 DrawSlideMarker: $FF a marker 2 dots wide (ailerons, rudder), 0 one dot (gauges); the drawing is gone (fsp)
vMulA               equ       $AF                 the multiply's first operand (MulQ15, MulU16x16, MulU16Mid, f2's Mul16Scale, fsw's Mq): made positive by MulQ15; MulQ15Store's product
vDivisor            equ       $B1                 DivQ15Signed: the divisor, made positive in place
vFillColorSave      equ       $B1                 DrawLineHoriz: the fill color ($0178) kept while DrawHLine fills in the line's color
vMulB               equ       $B1                 the multiply's second operand (Q15 or unsigned 16-bit), made positive in place by MulQ15
vSpan2Right         equ       $B1                 FillPolyTwoSpans: the span drawn second, its right x (DrawHLine's A; the word with vSpan2Left)
vSpan2Left          equ       $B2                 FillPolyTwoSpans: the span drawn second, its left x (DrawHLine's B)
vMulProd            equ       $B3                 the unsigned multiply's 32-bit product, high byte first, <$B3-<$B6 (MulU16x16, MulU16Mid, f2's Mul16Scale)
vEnd1Clip           equ       $B7                 FS's clipper: the first end's clip bits, as vEnd2Clip's (0 inside the view; also the DOT's light)
vEnd1X              equ       $B8                 FS's clipper and 3D line: the first end's camera X (then Y, Z; the second end at <$C1; the DOT's light)
vSinViewPitch       equ       $B8                 BuildViewMatrix: the sine of the view's pitch (<$18), Q15
vEnd1Y              equ       $BA                 the first end's camera Y (up)
vSinViewBank        equ       $BA                 BuildViewMatrix: the sine of the view's bank (<$1A), Q15
vEnd1Z              equ       $BC                 the first end's camera Z (depth)
vSinViewHdg         equ       $BC                 BuildViewMatrix: the sine of the view's heading (<$1C), Q15
vEnd1Past           equ       $BE                 past the first end's camera point (vEnd1X, Y, Z): LlInit's loop end
vEnd1ViewX          equ       $BE                 the first end projected (FS's projection): view x 1-255
vEnd1ViewRow        equ       $BF                 the first end projected: view row 1-125
vEnd2Clip           equ       $C0                 FS's clipper: the second end's clip bits (b7 behind, b6 left, b5 right, b4 below, b3 above; 0 inside)
vCosViewBank        equ       $C1                 BuildViewMatrix: the view bank's cosine (Q15)
vEnd2X              equ       $C1                 FS's clipper and 3D line: the second end's camera X (then Y, Z; the first end at <$B8)
vCosViewHdg         equ       $C3                 BuildViewMatrix: the view heading's cosine (Q15)
vEnd2Y              equ       $C3                 the second end's camera Y (up)
vCosHdgCosBank      equ       $C5                 BuildViewMatrix: cos heading x cos bank (Q15)
vEnd2Z              equ       $C5                 the second end's camera Z (depth)
vEnd2ViewX          equ       $C7                 the second end projected (FS's projection, fsw's PVtx): view x 1-255
vEnd2ViewRow        equ       $C8                 the second end projected: view row 1-125
vCosHdgSinBank      equ       $CA                 BuildViewMatrix: cos heading x sin bank (Q15)
vSinHdgCosBank      equ       $CC                 BuildViewMatrix: sin heading x cos bank (Q15)
vSinPitchSinHdgSinBank equ       $CE                 BuildViewMatrix: sin pitch x sin heading x sin bank (Q15)
vAttHzX1            equ       $D3                 attitude ball: the horizon's upper end, x (UpdAttitudeIndEnds puts the upper end first)
vAttHzRow1          equ       $D4                 attitude ball: the horizon's upper end, screen row
vLineEnd1Row        equ       $D4                 FS's 3D line op: the first end's view row ($FF from DrawSkyGround: no horizon line drawn)
vAttHzX2            equ       $D5                 attitude ball: the horizon's lower end, x
vAttHzRow2          equ       $D6                 attitude ball: the horizon's lower end, screen row
vAttLeftCol         equ       $D7                 attitude ball's sloped rows: the color left of the horizon (SetFillColor's A)
vPatBelowHz         equ       $D7                 DrawSkyGround: the color pattern word below the horizon (the ground's; SwapSkyGroundColors swaps it)
vAttRightCol        equ       $D9                 attitude ball's sloped rows: the color right of the horizon (SetFillColor's A)
vPatAboveHz         equ       $D9                 DrawSkyGround: the color pattern word above the horizon (the sky's)
vHzTopRow           equ       $DB                 DrawSkyGround: the horizon's top row, 127 to start (FS's old sloped fill tracked it)
vPolyRow            equ       $DB                 the polygon's top row (PolyBegin/PolyAddVertex), then FillPolygon's current row
vHzBotRow           equ       $DC                 DrawSkyGround: the horizon's bottom row, 0 to start, $FF with no horizon
vPolyLastRow        equ       $DC                 the polygon's bottom row (its greatest y; PolyBegin/PolyAddVertex)
vAltBands           equ       $DD                 DrawAltimeter: the scaled altitude's $0370 bands, counted (1 + the band)
vCrossCount         equ       $DD                 FillPolyScanline: the row's X crossings still to draw, counted down 2 a span
vDivQ15Bits         equ       $DD                 DivQ15: the quotient bits left (15 to start)
vFillRowCount       equ       $DD                 the rows still to fill, counted down (FillViewRows, FillAttBallRows, FillAttSlopeRows)
vLinePixCount       equ       $DD                 DrawLine: the pixels still to plot, counted down
vSlewShifts         equ       $DD                 SlewRateToDelta: the shifts left (the rate / 4, signed)
vAttSplitX          equ       $DE                 attitude ball's sloped rows: the horizon's x on the current row (8.8, half units)
vAttSplitStep       equ       $E0                 attitude ball's sloped rows: vAttSplitX's step a row (8.8, half units; DivFrac8)
vDivFracQuot        equ       $E4                 DivFrac8: the dividend (A x 256), then the 8.8 quotient
vDivFracSor         equ       $E6                 DivFrac8: the divisor (word; DivFrac8 writes its low byte from B)
vDivFracRem         equ       $E8                 DivFrac8: the remainder
vKeySelItem         equ       $EA                 the control FS's . and , keys change: 1 view direction (5), 3 magnetos (Enter), 8-11 XPDR digits, 13-15 ADF digits; 0 none
vInstActive1        equ       $EB                 the panel's active instruments (present, working, shown; UpdateInstrumentMasks): b0 airspeed, b1 turn coordinator, b2 heading, b3 altimeter, b4 attitude, b5 NAV1, b6 tach, b7 VSI
vInstActive2        equ       $EC                 active instruments, byte 2: b4 compass, b5 fuel, b6 oil, b7 the radios shown (forced on; F4's war panel clears it)
vInstActive3        equ       $ED                 active instruments, byte 3: b3 NAV2 or the ADF in its place (bits $F1 forced on)
vLineColPat         equ       $EE                 the line color pattern (the color in both nibbles, a word; SetLineColor)
vFillLeftNib        equ       $F0                 the fill color in the high nibble, a byte's left pixel (SetFillColor)
vFillRightNib       equ       $F1                 the fill color in the low nibble, a byte's right pixel (SetFillColor)
vRow80SaveS         equ       $F2                 FillRow80: S saved while it pushes the fill pattern (DP holds the pattern then)
vPolyVtxCount       equ       $F4                 FS's polygon op: the vertices so far less one ($FF before the first; PVtx starts the list on 0)
* FS's RAM $0100-$1FFF
vDayGround          equ       $0100               the day's ground color word (both nibbles): the first word of the sky / ground table $0100-$0113, which the scenery copies to vGndCol; f2's SeasonGnd sets it (winter white, else green)
vAltMsl             equ       $0132               the altitude above sea level, m: vAltCopy + vElev (DrawAltimeter); the air density and the scenery's cloud tests read it
vBlink              equ       $0134               the blink rotor: a 16-bit pattern rotated left a bit every odd frame (MainLoopOddCommon); the scenery's flashing lights test its bits
vCrash              equ       $0137               the crash: 0 none, 8 a splash, else a crash (4 a bad landing; the scenery's objects set 2, 4, 6); CheckCrashMessage shows it, then the crash reset
vService            equ       $013B               the scenery's service request at an airport (the word $013A): 1 refuel and repair, 2 also rearm (100 rounds, 5 bombs); done once the aircraft stands still (FlightAuxRequest), then cleared
vMkrInner           equ       $014D               the inner marker light (white): bit 0 lights it this frame, DrawMarkerLights shifts it out; no scenery sets it
vMkrOuter           equ       $014F               the outer marker light (color 6): bit 0 lights it this frame (the scenery sets the word $014E to 1 over the beacon, a 6 x 6 map unit box); DrawMarkerLights shifts it out
vMkrMiddle          equ       $0151               the middle marker light (color 4): bit 0 lights it this frame (the scenery sets the word $0150 to 1 over the beacon, a 2 x 2 map unit box); DrawMarkerLights shifts it out
vGlideSlope         equ       $0152               an ILS glideslope's height-to-distance ratio x 2 (Q15, as UpdateGlideslopeDme measures it): the scenery sets it in the ILS's range each frame; read, then cleared (0 none)
vIlsCourse          equ       $0154               the ILS localizer's course, 1/3 degree (the scenery sets it near an ILS): NAV1's OBS while its station is a localizer (vNav1Loc, UpdateNav1)
vScaledAlts         equ       $015E               7 altitude words from $015E: m in flight, ft while F2 runs (ConvertWindTables)
vBombTarget         equ       $0174               Europe 1917: the points of the target under the aircraft (10, 20; the scenery sets the word): a bomb's landing scores them (UpdateBombs), then cleared
vFillPat            equ       $0178               the fill pattern word, the color in each nibble (SetFillColor; FillRow80, DrawHLine, the polygon fill)
vGndCol             equ       $0184               FS's ground color (both nibbles; the scenery sets it): DrawSkyGround fills the view from its bottom with it
vSeasonBit          equ       $0187               the season's bit: 1 winter, 2 spring, 4 summer, 8 fall (UpdateDaylight); the scenery tests it (the word $0186)
vSceneMode          equ       $0189               the mode number for the scenery's tests (the word $0188: modes 8, 9): vUserModeFld, copied at F2's exit (ApplyClouds)
vHorizonPtr         equ       $0192               the horizon line's display list pointer: op $09 calls it when not 0 (vHorizonList at dawn, dusk and night, fsw's Horizon); DrawSkyGround clears it while the horizon is out of view
vRadioCom           equ       $01F2               COM1's frequency again, BCD (SetComFreq): the radio block $01F2-$01F9 (COM1, NAV1, NAV2, XPDR); nothing reads its three frequencies
vRadioNav1          equ       $01F4               NAV1's frequency again, BCD (SetNav1Freq; the radio block, nothing reads it)
vRadioNav2          equ       $01F6               NAV2's frequency again, BCD (SetNav2Freq; the radio block, nothing reads it)
vXpdrCode           equ       $01F8               the transponder code, BCD (SetXpdrCode; the radio block's last word): the tower reads the squawk
vWarKills           equ       $0200               Europe 1917: the enemy planes shot down (the war report; 4 or more: the veteran damage limits)
vTextColor          equ       $0201               the text color word, the color in each nibble (DrawTextString, DrawGlyph; the PrintPanelText entries set it)
vComBcd             equ       $0203               COM1's frequency, BCD past 100 ($2115: 121.15; SetComFreq): the COM op's ($1E) station search matches it
vMarkerNew          equ       $0205               a panel marker's new position on its scale, its old one in the next byte: MoveSlideMarker's and MoveVertMarker's arguments
vDemoOffCopy        equ       $0207               F2's ImportSimState: vCopyTo0207's word, copied while the demo does not fly; nothing reads it
vWarDamage          equ       $0209               Europe 1917: the enemies' hits on the aircraft (the damage count; the war report, ApplyEnemyHitDamage; the service clears it)
vWarEnemyInit       equ       $020A               Europe 1917: not 0: the six enemies set up again (InitEnemiesOnce clears it; F4's start and the service set it)
vAdfSearch          equ       $020E               $FF: the ADF's NDB search asked for (FlagAdfRetune); RunDisplayList hands it to vAdfSearchNow, the NDB op ($05) clears it
vAdfSearchNow       equ       $020F               the ADF's NDB search in this run of the list (RunDisplayList's copy of vAdfSearch): the NDB op ($05) loads a match into the record at $0293
vDgOffset           equ       $0210               the heading indicator's error (16-bit angle), added to the heading it shows: +2 a step in reality mode (UpdateReliability), set from the compass by the DG key, 0 with reality mode off
vCompassHdg         equ       $0216               the magnetic compass's heading as shown (16-bit angle): DrawMagCompass moves it 1/8 of the way each draw; the DG key sets vDgOffset from it
vOvlEntry           equ       $021D               the overlay's entry (F$Link's Y): SwitchOverlay jumps there
vOvlModule          equ       $021F               the overlay module's header (F$Link's U), for its F$UnLink
vOvlCur             equ       $0222               the overlay linked now (vOvlReq when it was linked; 0 none)
vPaused             equ       $0223               not 0 while paused (key P): MainLoop waits for P, the timer ticks run nothing
vFailTimer          equ       $0224               reality mode: frames to the next failure draw (UpdateReliability counts it down, 10 a cycle)
vWarScore           equ       $0228               Europe 1917: the score (word, wraps at 1000; AddScore shows it)
vNoSlew             equ       $022A               vModeRec's byte 0 (1 in every mode) at F2's exit, 0 while slew is on (vSlew); nothing reads it
vWarDowned          equ       $022B               Europe 1917: not 0 once the aircraft is shot down (fatal damage): no lift (ComputeAeroForces)
vWarStarted         equ       $022E               Europe 1917: F4's one-time setup done (WarMain; F2's exit clears it)
vWarReport          equ       $022F               Europe 1917: the war report asked for (ShowWarReport shows it and clears it)
vInstLit            equ       $0233               the instruments lit by day or with the panel lights on: masks for <$EB, <$EC, <$ED (SetPanelLightMask copies them to vInstVis; the service sets the first two)
vFatalCode          equ       $0236               FatalSystemError: the error code, 2 hex digits
vFatalCodeHex       equ       $0236               FatalSystemError: the error code, 2 ASCII hex digits
vFileHdr            equ       $0236               LoadDataBlock's read buffer: the data file's header, then the block's index entry
vIdxOffset          equ       $0236               an area's index entry as read (6 bytes): the area's file offset (32 bits, LoadDataBlock's seek)
vMsgCharTxt         equ       $0236               the pending message's text record for one character: x, row, the character, 0
vMsgX               equ       $0236               PrintPackedText's one-character text record: the column, pixels (from 3, +4 a character)
vSfMagic            equ       $0236               the scenery file's header as read (10 bytes: magic $DD01, the menu text's offset and length, the area count): its magic (LoadDataBlock, f3)
vMsgY               equ       $0237               PrintPackedText's text record: the row (from 3, +7 a line; the view cleared past $5A)
vFatalAddr          equ       $0238               FatalSystemError: its caller's address, 4 hex digits
vFatalAddrHex       equ       $0238               FatalSystemError: the failing call's address, 4 ASCII hex digits
vMsgChar            equ       $0238               PrintPackedText's text record: the character
vSfMenuOfs          equ       $0238               the scenery file's header: the menu text's file offset (32 bits; f3's seek)
vMsgEnd             equ       $0239               PrintPackedText's text record: its end (0)
vIdxLength          equ       $023A               an area's index entry: the area's length, bytes (LoadDataBlock's read)
vSfMenuLen          equ       $023C               the scenery file's header: the menu text's length (f3 reads it to $2200, at most up to FswRecBuf; fswc's Scrub)
vSfAreaCount        equ       $023F               the scenery file's header: the area count (the word's low byte; LoadDataBlock's limit)
vListStart          equ       $0240               the scenery display list's start, where LoadDataBlock reads the area: $4000, or fsd's list while an overlay runs
vFsdModule          equ       $0242               fsd's module header (F$Link's U) while an overlay runs, 0 none
vListEnd            equ       $0244               the end of the display list's room: LoadDataBlock's limit (WbWinEnd in flight; equal to vListStart: no scenery)
vLoadAddr           equ       $0247               LoadDataBlock: where the area goes (vListStart)
vLoadArea           equ       $0249               LoadDataBlock: the area to load (its index entry; 0 the base area)
vLoadSlot           equ       $024A               LoadDataBlock: the slot the area goes to ($FF the base slot, before the slot table at $024C)
vBaseArea           equ       $024B               the area in the base slot ($FF none): the slot table's entry before $024C
vBlkCache           equ       $024C               LoadDataBlock's cache: the block number in each of its 4 slots ($FF none)
vSceneryPath        equ       $0250               the scenery file's path, 32 characters at most and a CR (LoadDataBlock opens it; f3 edits it)
vPrevPointExp       equ       $0271               the scale exponent of the camera point before the last (GroundPoint saves vPointExp there first): a line's first end; LineEq and the long-line op match the two ends
vEnd1Cut            equ       $0282               FS's 3D line: not 0 when the clipper cut its first end (vEnd2Cut the second's); 0 at the list's start (RunDisplayListAt, fsx's AcRun)
vFtddPath           equ       $0286               the /FTDD path (FsMain opens it): the frame time (I$GetStt $80)
vSecond             equ       $0287               FS's clock: the second 0-59 (ProcessTimerTicks)
vRepeatTicks        equ       $0289               timer ticks left for a key's quick second press (5 a second, ProcessTimerTicks counts down): the radio select keys set 20 (the next digits), the elevator keys 3
vSecCount           equ       $028A               ProcessTimerTicks: the seconds counted; every other one StepElevatorDrift and UpdateEngine
vNavSearch          equ       $028C               the NAV station search asked for after a retune (FlagNavRetuneMask); RunDisplayList hands it to vNavSearchNow, the VOR op ($1D) clears it
vNavSearchNow       equ       $028D               the NAV station search in this run of the list (RunDisplayList's copy of vNavSearch): the VOR op ($1D) loads matches into NAV1's and NAV2's records
vNavRx              equ       $028E               the NAV receivers: b0 NAV1, b1 NAV2 hear their station (the VOR op sets, a retune clears)
vNav2Bcd            equ       $028F               NAV2's frequency, BCD past 100 (SetNav2Freq): the VOR op's search matches it
vNav1Bcd            equ       $0291               NAV1's frequency, BCD past 100 (SetNav1Freq): the VOR op's search matches it
vNav2StnRec         equ       $0293               NAV2's station record, X and Z (low, high words each); the ADF's station while it is shown
vNav1StnRec         equ       $029B               NAV1's station record, X and Z (low, high words each)
vNav1Loc            equ       $029F               NAV1's station record +4, the high byte of its Z low word: not 0 marks an ILS localizer (UpdateNav1 takes vIlsCourse; VORs sit on whole map units)
vComSearch          equ       $02A3               the COM station search asked for (SetComFreq; RedrawAllInstruments clears it); RunDisplayList hands it to vComSearchNow, the COM op ($1E) clears it
vComSearchNow       equ       $02A4               the COM station search in this run of the list (RunDisplayList's copy of vComSearch): the COM op ($1E) loads a match into the record at $02A5
vComMsgDone         equ       $02AD               0: the COM station's message (vComMsg) waits to be printed (the COM op clears it on a find); PrintPendingMessage prints it and sets it, SetComFreq sets it
vInstWork           equ       $02AE               the instruments working: masks for <$EB, <$EC, <$ED (a failure clears a bit; the service sets the first two)
vInstVis            equ       $02B1               the instruments visible: masks for <$EB, <$EC, <$ED (SetPanelLightMask: vInstLit's, or the night set with the panel lights off)
vEdExit             equ       $02B4               F2: not 0 once F1 was pressed: the editor exits (ApplyEditsAndExit)
vEdUp               equ       $02B5               F2: not 0 once '-' or the up arrow was pressed: the previous field
vEdValue            equ       $02B6               F2: the field's value, 24 bits (DigitsToBinary's, what PrintDecimal24 prints and StoreFieldValue stores)
vMenuRow            equ       $02B9               the menu's cursor row: F2's field row (from 1), f3's list row (3-13), f5's arrow row
vMenuPage           equ       $02BA               the menu's page: F2's FIX MODE page 0-3 (ShowPageText; f5's page)
vDecStarted         equ       $02BC               PrintDecimal24: not 0 once a digit went out (the leading zeros before it are dropped)
vEdDigits           equ       $02BD               F2: the digits typed into the field (0-6, in vEdDigitBuf)
vEdDigitBuf         equ       $02BE               F2: the typed digits, ASCII, the last one typed first (6 bytes; DigitsToBinary)
vEdDigitTop         equ       $02C3               vEdDigits' last digit, the 100,000s
vComMsg             equ       $02C4               the COM station's message: its packed text in the scenery, past the station's record (the COM op sets it; PrintPendingMessage)
vEdDigitsEnd        equ       $02C4               the end of vEdDigits (vEdDigits+6)
vEdTextLen          equ       $02C4               F2: the typed digits in the field's text at $02FB (its next column, 0-6)
vDemoOn             equ       $02C6               the demo flies: vDemo's copy at F2's exit (ApplyEnvironment); the aircraft takes off and flies by itself
vDecDigit           equ       $02C8               PrintDecimal24: the digit being counted, ASCII
vModeCopyDir        equ       $02C8               CopyModeRecord: 0 the mode slot to vModeRec, 1 vModeRec to the slot
vDecTrialLo         equ       $02C9               PrintDecimal24: the value less the power of ten, its low byte (kept when it fits)
vDecTrialMid        equ       $02CA               PrintDecimal24: the value less the power of ten, its middle byte (kept when it fits)
vAtisTempOfs        equ       $02CB               the ATIS temperature's random offset (-16..15), drawn at F2's exit (ApplyClouds); the COM station's season temperature + it
vModeZLo            equ       $02CC               the north (Z) position's low word, 1/256 m, that F2's exit puts the aircraft at (0 for FS's mode loads, fsw's ModeLd; fsw's OvEd keeps the aircraft's own)
vModeXLo            equ       $02CE               the east (X) position's low word, 1/256 m, that F2's exit puts the aircraft at (as vModeZLo)
vMenuRows           equ       $02D0               the rows on the menu's page: F2's last field row (ShowPageValues), f5's entries
vLibPath            equ       $02D1               F2: the mode library file's path (LoadSaveLibrary)
vLibSave            equ       $02D3               F2: LoadSaveLibrary: 0 load, 1 save the mode library
vEdFileLine         equ       $02D4               F2's file name line: VT_GOTOXY column 0 row 9 (fd), vEdFileName, its CR (36 bytes)
vEdFileName         equ       $02D7               F2's editor: the mode library's file name, 32 characters, then a CR
vEdFileNameEnd      equ       $02F7               the end of vEdFileName (its CR)
vGotoXY             equ       $02F8               the overlays' cursor move: VT_GOTOXY, column+$20, row+$20 (F2's fields, f3's list)
vGotoCol            equ       $02F9               the cursor-goto code's column + $20 (the code at $02F8: $02, column, row; F2, f3)
vGotoRow            equ       $02FA               the cursor-goto code's row + $20 (F2's field row, f3's list row)
vEdValueText        equ       $02FB               F2's editor: a value's 6 characters, written after vGotoXY (PrintDecimal24, the digit entry)
vModeNum            equ       $0301               the current mode, the settings record's source: 0-9 built in (TblBuiltinModes), 10-24 the library's
vModeRec            equ       $0302               the current mode's settings record, 65 bytes to $0342 (CopyModeRecord); byte 0 (1 in every mode, no F2 field) goes to $022A, unread
vAutoCoord          equ       $0303               AUTO-COORDINATION (F2 page 1): not 0, the ailerons move the rudder with them (ShowAileronPos)
vSlew               equ       $0304               SLEW (F2 page 1): not 0, slew mode: no flight model, no joystick, the north and east position shown
vEurope1917         equ       $0307               EUROPE 1917 (F2 page 1): the WWI game (mode 7, f4): fuel burn x 8, no marker lights, the joystick button fires
vCommRate           equ       $0308               COMMUNICATION RATE (F2 page 1): message text speed, (255 - it) x 256 + 10 loops a character
vModeNorth          equ       $0309               NORTH POSITION (F2 page 2): vPosZ's map square + $4000 (slew mode keeps it current and shows it)
vModeEast           equ       $030B               EAST POSITION (F2 page 2): vPosX's map square + $4000 (slew mode keeps it current and shows it)
vModeAltFt          equ       $030D               ALTITUDE (F2 page 2): ft above sea level (SetHeightFromTerrain turns it back into vAlt)
vModePitch          equ       $030F               PITCH (F2 page 2): degrees ($074D's angle x 360 / 65536)
vModeBank           equ       $0311               BANK (F2 page 2): degrees ($074F's angle x 360 / 65536)
vModeHdg            equ       $0313               HEADING (F2 page 2): degrees (vHdgCopy less vHdgOfs1 and vHdgOfs2)
vModeAirspeed       equ       $0315               AIRSPEED (F2 page 2): vAirspeed / 128 (2 per m/s)
vModeThrottle       equ       $0317               THROTTLE (F2 page 2): vThrottle's copy
vModeRudder         equ       $0319               RUDDER (F2 page 2): $082B + $7FFF
vModeAileron        equ       $031B               AILERONS (F2 page 2): vAileron + $7FFF
vModeFlaps          equ       $031D               FLAPS (F2 page 2): $081E's copy
vModeElevator       equ       $031F               ELEVATORS (F2 page 2): vElevator + $7FFF
vCldFtEnd           equ       $032C               the end of the menu's cloud layer feet (vCld2TopFt..vCld1BotFt)
vReliability        equ       $0342               RELIABILITY FACTOR (F2 page 1), 0-100: in reality mode a random 0-99 at or above it fails a part
vWindEnd            equ       $0342               the end of the menu's four wind records (vWind3..vWindSfc, 4 bytes each)
vUserModeFld        equ       $0343               F2's USER MODE field (page 1 row 1): the mode typed, 110 on saves to mode n-100; kept equal to vModeNum
vInstPresent        equ       $0344               the instruments fitted: masks for <$EB, <$EC, <$ED (UpdateInstrumentMasks; fd $FF $FF $0F)
vAdfEnable          equ       $0348               ADF ENABLE (F2 page 1): not 0, the ADF in place of NAV2
vModeCount          equ       $0349               the modes there are: 25 (fd; 0-9 built in, 10-24 the library's); a mode number at or above it is refused
vModeLib            equ       $034A               the mode library: user modes 10-24, 65 bytes each, to $0718 (fs_core's InitRunTable65 fills it)
vDmeOff             equ       $0719               1: the DME has no signal (NAV1 not received), its readout blank
vModeLibEnd         equ       $0719               the mode library's end: vModeLib + 15 records of 65 bytes
vDmeRedraw          equ       $071A               1: the DME readout changed, DrawDmeReadout redraws it (and clears it)
vDmeTenths          equ       $071B               the DME distance's tenths of a nautical mile, 0-9
vDmeNm              equ       $071C               the DME distance, whole nautical miles (UpdateGlideslopeDme)
vNav1Cdi            equ       $071D               NAV1's CDI needle position, stepped one at a time toward vNav1CdiGoal ($FF: redraw)
vNav1CdiGoal        equ       $071E               NAV1's CDI deviation, needle positions 0-30 (15 centered)
vNav2Cdi            equ       $071F               NAV2's CDI needle position, stepped one at a time toward vNav2CdiGoal ($FF: redraw)
vNav2CdiGoal        equ       $0720               NAV2's CDI deviation, needle positions 0-30 (15 centered)
vGsNeedle           equ       $0721               the glideslope needle's position, stepped one at a time toward vGsGoal ($FF: redraw)
vGsGoal             equ       $0722               the glideslope deviation, needle positions 0-24 (12 centered)
vNav1Flag           equ       $0723               NAV1's flag: 1 TO, 2 FROM, 0 off
vNav2Flag           equ       $0724               NAV2's flag: 1 TO, 2 FROM, 0 off
vNav1FlagShown      equ       $0725               NAV1's flag as last drawn on FS's panel ($FF: redraw)
vNav2FlagShown      equ       $0726               NAV2's flag as last drawn on FS's panel ($FF: redraw)
vShownSpare         equ       $0727               set to $FF with the flags' last-drawn bytes at a full redraw; nothing reads it
vStationDZ          equ       $0728               the aircraft's Z offset from the station ComputeStationBearing measured last, 16 m units
vStationDX          equ       $072A               the aircraft's X offset from that station, 16 m units
vRpm                equ       $072C               the tachometer's RPM, 50-rpm units: stepped 2 a tick toward vRpmTarget
vRpmTarget          equ       $072D               the engine's RPM, 50-rpm units (UpdateEngine, every 2 s)
vDamageBits         equ       $072E               failures: b0 oil overheats, b1 no oil pressure (b0-b1: power at most $10), b2/b3 left/right tank leaks
vFuelLFrac          equ       $072F               the left tank's fraction of a gallon (16 bits, below vFuelL)
vFuelL              equ       $0731               the left tank's fuel, gallons ($20 full)
vFuelRFrac          equ       $0732               the right tank's fraction of a gallon (16 bits, below vFuelR)
vFuelR              equ       $0734               the right tank's fuel, gallons ($20 full)
vFuelTank           equ       $0735               the selected tank: 0 left, else right (Ctrl+F, fsw's FuelKey)
vOilTemp            equ       $0739               the oil temperature (16 bits; high byte 0-$12: 9 running, $12 overheated), steps $19
vOilPress           equ       $073B               the oil pressure (16 bits; high byte 0-$0A: $0A running), steps $FA
vAltimErr           equ       $073D               the altimeter's error, m: added to the altitude it shows, stepped toward vAltimErrGoal
vAltimErrGoal       equ       $073F               the altimeter error's target, m: a random -128..127, picked when the height band changes
vWindStepX          equ       $0742               the wind's drift in X this frame, 1/256 m, subtracted from vPosX (the whole word)
vWindStepZ          equ       $0744               the wind's drift in Z this frame, 1/256 m, subtracted from vPosZ (the whole word)
vWindSfcFlag        equ       $0746               1 for one pass: the surface wind's layer, so its direction adds vHdgOfs2
vStepAlt            equ       $0747               the height's change this frame, 1/256 m: vStepDist x vSinPathPitch
vAirDensity         equ       $0749               the air's density, Q15: $7FFE less 2.5 a meter of altitude above sea level
vAngleOfAttack      equ       $074B               the angle of attack (high byte 256 a turn): the elevator x the speed curve; stall at $24 up, under $E7
vPathPitch          equ       $074D               the flight path's pitch, 16-bit angle (256 a turn in the high byte): the climb angle
vBankAngle          equ       $074F               the aircraft's bank, 16-bit angle, positive right (vBank is its negative)
vLiftBaseK          equ       $0751               the wings' lift coefficient with the controls centered and no flaps (fd)
vDragBaseK          equ       $0753               the drag coefficient's fixed part (fd)
vDragSumK           equ       $0755               the drag coefficient's factor on the lift coefficients' squares, slip and flap drag (fd)
vCosPathPitch       equ       $0757               cos of vPathPitch, Q15
vStepHoriz          equ       $0759               the horizontal distance this frame, 1/256 m: vStepDist x vCosPathPitch
vCosBank            equ       $075B               cos of vBankAngle, Q15 (written, not read)
vCosTrack           equ       $075D               cos of the track (the heading plus vTrackOfs), Q15
vWeightNormal       equ       $075F               the weight's share across the flight path: vWeight x vCosPathPitch
vSlip               equ       $0761               the sideslip: (aileron - rudder) / 2, high bytes, in the high byte; the slip ball shows it
vSlipTurn           equ       $0763               the slip's turn rate: vSlip x vSlipTurnK, added to vTurnRate in the air
vSlipRoll           equ       $0765               the slip's roll: vSlip x vSlipRollK, added to the left wing's lift coefficient
vCosBankLift        equ       $0767               cos of vBankAngle, Q15: the lift's vertical share
vPitchRate          equ       $0769               the flight path's pitch change each ComputeAerodynamics step (0 nose-down on the ground)
vRollRate           equ       $076B               the bank's rate: vLiftDiff x vRollK (0 on the ground)
vTurnRate           equ       $076D               the turn rate, the heading's change a second (182 a degree)
vDrag               equ       $076F               the drag, with the weight's share along the flight path
vAccel              equ       $0771               the airspeed's change from the forces: vNetThrust x vAccelK
vRudderBySpeed      equ       $0773               the rudder's high byte x the speed curve at $0871 (written, not read)
vStepX              equ       $0775               the X change this frame, 1/256 m: vStepHoriz x vSinTrack
vNetThrust          equ       $0777               vThrust minus vDrag
vFlapDrag           equ       $0779               the flaps' drag (high byte of the flaps x $07DB), added to the drag sum
vAirPitchOfs        equ       $077A               added to the view's pitch while airborne (fd: 0)
vTimeStep           equ       $077C               this frame's time, Q15 seconds (ticks x 546, at most $7Fxx)
vStepDist           equ       $077E               the distance flown this frame, 1/256 m: vAirspeed x vTimeStep
vAltBand            equ       $0780               the height's 256 m band last seen in the air; $FF from the first ground contact
vSlipDrag           equ       $0784               the slip's drag: vSlip x vSlipDragK, added to the drag sum
vAilLift            equ       $078C               the ailerons' lift: vAileron x vAilLiftK (vAilStallK stalled); left wing +, right wing -
vAoALift            equ       $078E               the lift coefficient from the angle of attack: vAngleOfAttack x vAoALiftK
vWingCoefL          equ       $0790               the left wing's lift coefficient from its settings: flaps, base, ailerons, slip
vWingCoefR          equ       $0792               the right wing's lift coefficient from its settings: flaps, base, ailerons
vFlapLift           equ       $0794               the flaps' lift coefficient (the flaps x $07ED)
vLiftScale          equ       $0796               the lift's scale, 16 bits (fd); $0B more in its high byte under 20 m (ground effect)
vLift               equ       $0798               the lift: (vLiftL + vLiftR) x vAirDensity x vLiftScale; 0 while the stall count runs
vLiftL              equ       $079A               the left wing's lift: vDynPress x vLiftCoefL x 4
vLiftR              equ       $079C               the right wing's lift: vDynPress x vLiftCoefR x 4
vTouchBump          equ       $079E               the vertical speed at the first ground contact, added to the view's pitch once
vAccelK             equ       $079F               the forces' factor to the airspeed's change (1 / mass, fd)
vRollK              equ       $07A1               the roll moment's factor to the bank's rate (fd)
vLiftDiff           equ       $07A3               the roll moment: (vLiftL - vLiftR) x 4
vStepZ              equ       $07A5               the Z change this frame, 1/256 m: vStepHoriz x vCosTrack
vSinPathPitch       equ       $07AD               sin of vPathPitch, Q15
vSinBank            equ       $07AF               sin of vBankAngle, Q15
vSinTrack           equ       $07B1               sin of the track (the heading plus vTrackOfs), Q15
vWeightAlong        equ       $07B3               the weight's share along the flight path: vWeight x vSinPathPitch
vTrackOfs           equ       $07B5               the track's offset from the heading (16-bit angle): vSlip x vSlipTrackK
vThrust             equ       $07B7               the thrust: vRpmTarget x $07D0 x vAirDensity (UpdateEngine)
vNetLift            equ       $07B9               the lift's vertical share (vLift x vCosBankLift) minus vWeightNormal
vDynPress           equ       $07BD               the dynamic pressure: vAirspeed squared, Q15
vVertSpeed          equ       $07BF               the vertical speed, 1/256 m/s: vAirspeed x vSinPathPitch
vWeight             equ       $07C1               the aircraft's weight (fd)
vLiftCoefL          equ       $07C5               the left wing's lift coefficient: vWingCoefL x the speed curve + vAoALift
vLiftCoefR          equ       $07C7               the right wing's lift coefficient: vWingCoefR x the speed curve + vAoALift
vLiftCoefLSq        equ       $07C9               vLiftCoefL squared, Q15 (induced drag)
vLiftCoefRSq        equ       $07CB               vLiftCoefR squared, Q15 (induced drag)
vAoAPitchK          equ       $07D3               the angle of attack's factor into the view's pitch (fd)
vSlipRollK          equ       $07D5               the slip's factor into vSlipRoll (fd)
vSlipTurnK          equ       $07D7               the slip's factor into vSlipTurn (fd)
vSlipTrackK         equ       $07D9               the slip's factor into vTrackOfs (fd)
vSlipDragK          equ       $07DF               the slip's factor into vSlipDrag (fd)
vDragFixedK         equ       $07E3               a byte added to vDrag's low byte while the airspeed is not 0 (fd: 0)
vAoALiftK           equ       $07E7               the angle of attack's factor into vAoALift (fd)
vAilLiftK           equ       $07E9               the ailerons' factor into vAilLift (fd)
vAilStallK          equ       $07EB               the ailerons' factor into vAilLift while stalled (fd)
vSlewEntry          equ       $07EF               1 after a normal flight frame: slew mode's first frame zeroes the controls, clears it
vGroundSettle       equ       $07F2               frames left in which the height is set from the terrain after a load (f2: 20); no landing or splashdown check
vAsiTarget          equ       $07F3               the airspeed needle's target position (CalcAirspeedNeedleLookup)
vAltCopy            equ       $07F9               vAlt's meters, DrawAltimeter's copy: the glideslope's and f4's bombs' height
vTurnIndex          equ       $0800               the turn coordinator's airplane index drawn (0-15, 8 level)
vThrottleMark       equ       $0806               the throttle lever marker's position drawn (MoveThrottleMarker)
vFlapsMark          equ       $0807               the flaps lever marker's position drawn (6 at the start)
vTrimMark           equ       $0808               the elevator trim marker's position drawn (5 centered)
vFuelLMark          equ       $080A               the left fuel gauge's marker drawn: the left tank $0731 / 4
vFuelRMark          equ       $080B               the right fuel gauge's marker drawn: the right tank $0734 / 4
vOilTempMark        equ       $080C               the oil temperature gauge's marker drawn: $0739
vOilPressMark       equ       $080D               the oil pressure gauge's marker drawn: $073B
vAmmo               equ       $0814               Europe 1917: the machine gun's rounds left (word; 100 at the war's start, f4 shows it)
vBombAlt            equ       $0816               Europe 1917: the falling bomb's height (word, 0 none; f4 lowers it 50 a frame)
vCarbHeat           equ       $0818               the carburetor heat switch: not 0 on (HT on the panel; the engine's power 8 down)
vElevTrim           equ       $081C               the elevator trim (high byte, signed: -$50 to $50 in steps of 4)
vFlaps              equ       $081E               the flaps (high byte: 0 up, $20 a notch, $60 full)
vGunBurst           equ       $0821               Europe 1917: the rounds still to fire (3 a joystick button press; f4 fires one a frame)
vLights             equ       $0824               the lights switch: not 0 on (ON/OF on the panel; the panel at night, fsx's lamps)
vRudder             equ       $082B               the rudder (word, signed; with auto-coordination, $0303, a copy of the ailerons)
vSlewBank           equ       $082D               slew mode: the bank rate (signed, added to <$14 a frame)
vSlewHdg            equ       $082F               slew mode: the heading rate (signed, taken from <$16 a frame)
vSlewPitch          equ       $0831               slew mode: the pitch rate (signed, added to <$12 a frame)
vSlewAlt            equ       $0833               slew mode: the altitude rate (signed byte, added to the height a frame)
vViewDir            equ       $0839               the view direction: the low nibble in 1/16 turns (0 ahead), bit 7 the pitched-up view (gone in the port)
vWarState           equ       $083B               Europe 1917: the war's state: 0 none, bit 0 started (a hit), 3 announced (WAR !!!!)
vCopyTo0207         equ       $083C               a word F2's ImportSimState copies to $0207 when FS did not start in its demo; nothing else reads either
vElevSpdCurve       equ       $083F               the elevator's speed curve, to the angle of attack: 10 bytes, one every 16 m/s (InterpBySpeed)
vPitchSpdCurve      equ       $0849               the pitch rate's speed curve: 10 bytes, one every 16 m/s (InterpBySpeed)
vTurnSpdCurve       equ       $0853               the bank's speed curve, to the turn rate: 10 bytes, one every 16 m/s (InterpBySpeed)
vRudderSpdCurve     equ       $0871               the rudder's speed curve: 10 bytes, one every 16 m/s (InterpBySpeed)
vJoyMode            equ       $088D               the joystick (the mouse) setting: 0 off, 1 the right stick, 2 both sticks (F2's JOYSTICK ENABLE)
vStickX             equ       $088F               the right stick's last X (the mouse: WbJoy)
vSecTicks           equ       $0897               ProcessTimerTicks: the ticks to the clock's next second, $FB up to the wrap (5 ticks a second)
vStallTime          equ       $0898               stall: not 0 stalled, the ticks left (6 at a stall or out of the envelope; ComputeAero's stalled terms)
vRollCancel         equ       $0899               a roll rate cancelled once: G copies $076B here, UpdateFlightVelocity subtracts it, then clears it
vSkipPresent        equ       $089C               bit 0: the next frame not shown (MainLoop shifts it out; set as vRollCancel is used)
vStallNoLift        equ       $089D               stall: the aerodynamics steps left with no lift (15 at a stall)
vWarOn              equ       $089E               Europe 1917 set up: 7 while it runs (F2's ApplyWarMode); F2 clears it when the menu turns the war off
vSplashCount        equ       $08A1               CheckSplashdown: the frames on water left before the splash crash (3)
vPlotEvery          equ       $08A2               the course plotter: frames between recorded points (10; PRECISION 2)
vPlotCount          equ       $08A3               the course plotter: frames to the next recorded point
vPlotMode           equ       $08A4               the course plotter: 0 off, 1 recording, 2 showing the plot
vPlotPtr            equ       $08A5               the course plotter: the next point's place in the plot list (FsScreen + $3C00 on; its $79 end)
vPlotScale          equ       $08A7               the course plotter: the plot's scale, 4 PRECISION (points not divided by 16), 6 normal
vGunFired           equ       $08A9               set to 3 with vGunBurst when the joystick button fires; nothing reads it
vPtSlots            equ       $08B3               FS's 3D point slots: 30 records of 8 bytes; display-list op $31 fills one, $32/$33 read them
vAdfShown           equ       $09A3               1: F2 put the ADF on the panel (in NAV2's place)
vAdfFound           equ       $09A4               1: the tuned NDB is in the scenery list (its record at $0293); cleared at a retune
vAdfFreq            equ       $09A5               the ADF frequency, BCD: the hundreds, then the tens and units (SetAdfFreq, from vAdfDigits)
vAdfNeedle          equ       $09A7               the ADF needle's position drawn (dial steps 0-87)
vNav1Obs            equ       $09A8               NAV1's OBS course, 2-degree steps (0-179)
vNav2Obs            equ       $09A9               NAV2's OBS course, 2-degree steps (0-179)
vHdgDeg             equ       $09AA               the heading indicator's heading, degrees 0-359 (word), as last shown
vRpmShown           equ       $09AC               the tachometer's RPM step last shown ($072C: 50 RPM a step)
vHdgIndTxt          equ       $09AF               the heading indicator's text record: x, row, 3 digits, 0
vHdgIndDigits       equ       $09B1               the heading indicator's 3 ASCII digits (in vHdgIndTxt)
vHdgRecipTxt        equ       $09B5               the heading indicator's reciprocal text record: x, row, 3 digits, 0
vHdgRecipDigits     equ       $09B7               the heading indicator's reciprocal: 3 ASCII digits (in vHdgRecipTxt)
vCompassTxt         equ       $09BB               the magnetic compass's text record: x, row, 3 digits, 0
vCompassDigits      equ       $09BD               the magnetic compass's 3 ASCII digits (in vCompassTxt)
vAdfTxt             equ       $09C1               the ADF frequency text record: x, row, 4 characters, 0
vAdfDigits          equ       $09C4               the ADF frequency's three ASCII digits (in the text record at $09C1)
vCom1Txt            equ       $09C8               COM1's frequency text record: x, row, 5 digits, 0
vCom1AllDigits      equ       $09CA               COM1's frequency as 5 ASCII digits, its leading 1 first (vCom1Txt+2; vCom1Digits the last 4)
vCom1Digits         equ       $09CB               COM1's 4 ASCII frequency digits after its leading 1 (in vCom1Txt)
vNav1Txt            equ       $09D0               NAV1's frequency text record: x, row, 5 digits, 0
vNav1AllDigits      equ       $09D2               NAV1's frequency as 5 ASCII digits, its leading 1 first (vNav1Txt+2; vNav1Digits the last 4)
vNav1Digits         equ       $09D3               NAV1's 4 ASCII frequency digits after its leading 1 (in vNav1Txt)
vNav2Txt            equ       $09D8               NAV2's frequency text record: x, row, 5 digits, 0
vNav2AllDigits      equ       $09DA               NAV2's frequency as 5 ASCII digits, its leading 1 first (vNav2Txt+2; vNav2Digits the last 4)
vNav2Digits         equ       $09DB               NAV2's 4 ASCII frequency digits after its leading 1 (in vNav2Txt)
vObs1Txt            equ       $09E0               NAV1's OBS course text record: x, row, 3 digits, 0
vObs1Digits         equ       $09E2               NAV1's OBS course: 3 ASCII digits (in vObs1Txt)
vObs1RecipTxt       equ       $09E6               NAV1's OBS reciprocal course text record: x, row, 3 digits, 0
vObs1RecipDigits    equ       $09E8               NAV1's OBS reciprocal course: 3 ASCII digits (in vObs1RecipTxt)
vObs2Txt            equ       $09EC               NAV2's OBS course text record: x, row, 3 digits, 0
vObs2Digits         equ       $09EE               NAV2's OBS course: 3 ASCII digits (in vObs2Txt)
vObs2RecipTxt       equ       $09F2               NAV2's OBS reciprocal course text record: x, row, 3 digits, 0
vObs2RecipDigits    equ       $09F4               NAV2's OBS reciprocal course: 3 ASCII digits (in vObs2RecipTxt)
vXpdrTxt            equ       $09F8               the transponder code's text record: x, row, 4 digits, 0
vXpdrDigits         equ       $09FA               the transponder code's 4 ASCII digits (in vXpdrTxt)
vTachTxt            equ       $09FF               the tachometer's RPM text record: x, row, 4 digits, 0
vRpmDigits          equ       $0A01               the tachometer's text: the thousands and hundreds, then the tens (ASCII; text record $09FF)
vClockHrTxt         equ       $0A06               the clock's hours text record: x, row, 2 digits, 0
vHourDigits         equ       $0A08               the clock's hours, two ASCII digits (text record $0A06)
vClockMinTxt        equ       $0A0B               the clock's minutes text record: x, row, 2 digits, 0
vMinuteDigits       equ       $0A0D               the clock's minutes, two ASCII digits (text record $0A0B)
vClockSecTxt        equ       $0A10               the clock's seconds text record: x, row, 2 digits, 0
vSecondDigits       equ       $0A12               the clock's seconds, two ASCII digits (text record $0A10)
vDmeTxt             equ       $0A15               the DME distance text record: x, row, 3 digits, 0
vDmeDigits          equ       $0A17               the DME's distance: the tens and units, then the tenths (ASCII; text record $0A15)
vMiddleMkrTxt       equ       $0A1B               the middle marker light's text record: x $72, row $1B, O, 0
vInnerMkrTxt        equ       $0A1F               the inner marker light's text record: x $77, row $1B, O, 0
vOuterMkrTxt        equ       $0A23               the outer marker light's text record: x $7C, row $1B, O, 0
vLightsOnTxt        equ       $0A27               the lights switch text record shown while they are on (ON)
vLightsOffTxt       equ       $0A2C               the lights switch text record shown while they are off (OF)
vCarbOnTxt          equ       $0A31               the carb heat text record shown while it is on (HT)
vCarbOffTxt         equ       $0A36               the carb heat text record shown while it is off (CH)
vNavFlagTxt         equ       $0A3B               the NAV flags' text records, 8 bytes apart: NAV1's OFF, TO, FR, then NAV2's (x, row, 3 characters, 0)
vHorizonList        equ       $0A7F               the horizon line's display list: op $40, point 1, op $41, point 2, $79 (DrawSkyGround)
vHorizonSin1        equ       $0A80               the horizon line's first point: the sine of <$1C - $35 (Q15)
vHorizonCos1        equ       $0A82               the horizon line's first point: the cosine of <$1C - $35 (Q15)
vHorizonSin2        equ       $0A85               the horizon line's second point: the sine of <$1C + $35 (Q15)
vHorizonCos2        equ       $0A87               the horizon line's second point: the cosine of <$1C + $35 (Q15)
vPolyFirst          equ       $0AC2               the polygon's first vertex (x, y): FillPolygon's closing edge ends there
vPolyLast           equ       $0AC4               the polygon's latest vertex (x, y)
vPolyEdgeList       equ       $0AC6               the polygon's edge list: 6-byte edge records, vPolyEdgePtr the next, vPolyEdges their count
vPolyEdgeRecs       equ       $0AC6               polygon fill: the edge records from PolyBegin (6 bytes each)
vPolyXings          equ       $0C46               polygon fill: the current row's X crossings (one byte each)
vPolyEdgePtr        equ       $0CC6               the next edge record's place in the polygon's edge list ($0AC6 on, 6 bytes an edge)
vPolyEdges          equ       $0CC8               the polygon's edge count (PolyBegin clears it)
vPolyRows           equ       $0CC9               FillPolygon: the rows left to fill, less one (max y - min y, counted down)
vPolyEdgeLeft       equ       $0CCA               FillPolyScanline: the edges left to walk on this row
vPolyRowAdr         equ       $0CCB               FillPolygon: the current row's screen address (row table + vViewScr, 80 bytes a row)
vPanelScrInit       equ       $0CD1               the panel's screen address set at the start (FS's screen + 99 rows); nothing reads it
vPanelScr           equ       $0CD3               the panel's screen base every panel draw uses (FS's screen + 99 rows: $8000)
vFilePath           equ       $0CD7               the path of the scenery file being read (LoadDataBlock, f3's load) or of f3's directory
vViewScr            equ       $0CD9               the view's screen base FS draws through (0: the view has no memory, its addresses only name rows)
vOptSaved           equ       $0CDB               stdin's SS.Opt packet (32 bytes) as found at the start, put back at the quit
vOptPacket          equ       $0CFB               FS's terminal options: stdin's SS.Opt packet (32 bytes): echo, auto line feed, pause and the control characters off
vOptEcho            equ       $0CFF               FS's terminal options (the SS.Opt packet at $0CFB): echo, 0 in flight
vOptAutoLf          equ       $0D00               FS's terminal options: auto line feed, 0 in flight
vOptPause           equ       $0D02               FS's terminal options: end-of-page pause, 0 in flight
vOptBsp             equ       $0D04               FS's terminal options: the backspace character, the first of the 11 editing and control characters FsMain clears
vOptParity          equ       $0D0F               FS's terminal options: the parity code, past the control characters FsMain clears
vElevatorStep       equ       $0D1B               the elevator indicator's step last shown (($50 - the elevator's high byte) / 8)
vAileronStep        equ       $0D1C               the aileron indicator's step last shown ((the high byte + $7F) / 16, 0-15)
vAltSmallDrawn      equ       $0D1D               the altimeter's small (slow) hand, its position drawn (0-87)
vAltBigDrawn        equ       $0D1E               the altimeter's big (fast) hand, its position drawn (0-87)
vAltBandMark        equ       $0D1F               the altimeter's band mark drawn: the bands doubled, +1 in a band's upper half, $13 past ten
vAsiNeedle          equ       $0D20               the airspeed needle's position drawn (dial steps), a quarter of the way to $07F3 a tick
vVsiNeedle          equ       $0D21               the vertical speed needle's position drawn, a step a tick toward <$3F
vAltSmallHandBg     equ       $0D23               the altimeter's small (thousands) hand: the screen bytes it covers, saved (24 bytes)
vAltBigHandBg       equ       $0D3B               the altimeter's big (hundreds) hand: the screen bytes it covers, saved (39 bytes)
vAirspeedNeedleBg   equ       $0D62               the airspeed needle: the screen bytes it covers, saved (39 bytes)
vVsiNeedleBg        equ       $0D89               the VSI needle: the screen bytes it covers, saved (24 bytes)
vAdfNeedleBg        equ       $0DA1               the ADF needle: the screen bytes it covers, saved (24 bytes)
vSlipBallBg         equ       $0DB9               the slip ball: the screen bytes it covers, saved
vCarbIce            equ       $0DCD               carburetor ice: 20 when it forms (spring, low throttle); with the carb heat on it melts a step an engine update, the power $20 down
vSlewNTxt           equ       $0DCE               slew mode's north position text record: x, row, digits, NORTH, 0
vSlewNDigits        equ       $0DD0               slew mode's north position: 5 ASCII digits (in vSlewNTxt)
vSlewETxt           equ       $0DDC               slew mode's east position text record: x, row, digits, EAST, 0
vSlewEDigits        equ       $0DDE               slew mode's east position: 5 ASCII digits (in vSlewETxt)
vSlipBall           equ       $0E0A               the slip ball's position drawn (1-17, 9 centered)
vElevatorMark       equ       $0E0B               the elevator marker's position drawn (20 - vElevatorStep; 10 centered)
vAileronMark        equ       $0E0C               the aileron marker's position drawn (0-15, 7 centered)
vRudderMark         equ       $0E0D               the rudder marker's position drawn (0-15, 7 centered)
vTextClearStr       equ       $0E0E               the text screen's clear and cursor-off codes ($0C, $05 $20), then FS's 16 palette records (WbGimePal)
WbPalRecs           equ       $0E11               FS's 16 palette records ESC $31 pp cc, 4 bytes each (WbGimePal: the first's GIME color)
vGoodbyeMsg         equ       $0E51               the quit's text screen: cleared, cursor on, Thanks for flying subLOGIC, the text colors back
WbPalRecsEnd        equ       $0E51               the end of FS's 16 palette records (WbPalRecs + 64)
vMonitorTypes       equ       $0E82               SS.Montr's monitor type for the answers A, B, C (1 RGB, 0 composite, 2 monochrome)
vMonitorMsg         equ       $0E85               the text screen's title and display question (A RGB, B composite, C black and white)
vOpModeMsg          equ       $0F91               the text screen's operating mode question (A demo, B regular flight)
vCreditsMsg         equ       $0FEA               the text screen's credits (BREAK at the display question)
vAtanTbl            equ       $10F4               FS's arctangent table: atan(n/16) for n 0-16 as 16-bit angles ($2000 at 45 degrees)
vAttPitchShown      equ       $1156               the pitch the attitude indicator last drew (vPitch's high byte; RedrawAllInstrNoX moves it off to force a redraw)
vAttBankShown       equ       $1157               the bank the attitude indicator last drew (vBank's high byte)
vAttLowerCol        equ       $115A               the attitude ball's color below the horizon: $88 upright, $77 inverted (SwapAttColors)
vAttUpperCol        equ       $115B               the attitude ball's color above the horizon: $77 upright (the sky), $88 inverted
vFsDiskMsg          equ       $115C               the text screen's message: insert the Flight Simulator disk
vSceneryDiskMsg     equ       $11BE               the text screen's message: insert the disk with the scenery file
vAdfLabel           equ       $1227               the panel's text record "ADF" (x $71, y $41; fd's data), drawn when the ADF is on
vBombReq            equ       $122D               1: FS's bomb key pressed; f4's UpdateBombs drops a bomb if none falls and bombs are left
vEnemyDX            equ       $1230               f4: the target less the enemy (ComputeTargetDelta): X, 24 bits; the target the aircraft or the enemy's home
vEnemyDY            equ       $1233               f4: the target less the enemy: the altitude, 24 bits
vEnemyDZ            equ       $1236               f4: the target less the enemy: Z, 24 bits
vEnemyFar           equ       $1239               f4: $7F when the delta's high bytes (XORed) are neither 0 nor $FF, the enemy too far; 0 in range (ComputeEnemyRange)
vEnemyRange         equ       $123A               f4: the enemy's distance from the delta's low words (ApproxHypot twice; ComputeEnemyRange)
vRadarRotX          equ       $123C               f4's PlotEnemyOnRadar: the delta turned by the heading: X = dX cos - dZ sin (Q15 products)
vRadarRotZ          equ       $123E               f4's PlotEnemyOnRadar: the delta turned by the heading: Z = dZ cos + dX sin (Q15 products)
vRadarDotX          equ       $1240               f4's PlotEnemyOnRadar: the radar dot's x ($70-$9E), then vRadarDotY: PlotPixel's D
vRadarSin           equ       $1240               f4's PlotEnemyOnRadar: the heading's sine (Sin8, Q15)
vRadarDotY          equ       $1241               f4's PlotEnemyOnRadar: the radar dot's row ($2A-$55)
vRadarCos           equ       $1242               f4's PlotEnemyOnRadar: the heading's cosine (Cos8, Q15)
vEnemyFired         equ       $1244               f4: 1 when an enemy fired at the aircraft (UpdateEnemyPlane); UpdateWarMessages shifts it out and shows ENEMYFIRE
vEnemyInSight       equ       $1245               f4: 3 when an enemy is in the gunsight (UpdateEnemyPlane), halved a frame: not 0 the gunsight highlighted, bit 0 IN RANGE shown
vStatusWait         equ       $1246               f4: UpdateWarMessages' calls left before the panel status line's next string (4 down to 1)
vStatusLine         equ       $1247               f4: the panel status line's string count: its low 2 bits pick AMMO, SCORE, BOMBS or HITS (TblStatusLinePtrs)
vWarMsgShown        equ       $1248               f4: the war message shown: 0 none, 1 IN RANGE, 2 ENEMYFIRE (UpdateWarMessages)
vBombHits           equ       $1249               f4: the bombs that hit (UpdateBombs; the war report's Bomb Hits)
vTracerSlot         equ       $124A               f4: the newest tracer's offset in the tracer table at $12BA (0-$4E, 6 bytes a tracer)
vTracerTime         equ       $124B               f4: the frames the tracers are still drawn: $19 after a round, held at 1 (none drawn)
vGunSide            equ       $124C               f4: the rounds fired: bit 0 the gun a tracer leaves from (0 the left, x $27; 1 the right, x $77)
vEnemySize          equ       $124D               f4: the enemy's shape by its range, 0 farthest to 4 nearest (TblEnemyShapes' index)
vEnemyViewX         equ       $124E               f4: the enemy's view x (<$BE after its display list ran)
vEnemyViewY         equ       $124F               f4: the enemy's view row (<$BF after its display list ran)
vRptNums            equ       $1250               the war report's numbers: cursor codes and digits written after MsgWarReport, 42 bytes
vRptKills           equ       $1253               the war report's enemy planes shot down, three digits
vRptBombHits        equ       $1259               the war report's bomb hits, three digits
vRptDamage          equ       $125F               the war report's aircraft damage by the enemy (its hits), three digits
vRptEnemy1          equ       $1265               f4's war report text: enemy 1's status digit (ShowWarReport)
vRptEnemy2          equ       $1269               f4's war report text: enemy 2's status digit (ShowWarReport)
vRptEnemy3          equ       $126D               f4's war report text: enemy 3's status digit (ShowWarReport)
vRptEnemy4          equ       $1271               f4's war report text: enemy 4's status digit (ShowWarReport)
vRptEnemy5          equ       $1275               f4's war report text: enemy 5's status digit (ShowWarReport)
vRptEnemy6          equ       $1279               f4's war report text: enemy 6's status digit (ShowWarReport)
vAmmoDigits         equ       $1282               the panel status line AMMO :nnn, its three digits (ShowAmmoCount)
vHitsDigits         equ       $128E               the panel status line HITS :nnn, its three digits: vWarDamage (ShowDamageCount)
vBombsLeft          equ       $129B               f4: the bombs left, the ASCII digit ('5' to '0') in the panel status line's BOMBS text ('5' at the start and FS's reset)
vScoreDigits        equ       $12A6               the panel status line SCORE:nnn, its three digits (AddScore)
vEnemyDispList      equ       $12AA               f4's display list that projects an enemy for RunDisplayList (its X, height, Z copied in at +9)
vEnemyPtX           equ       $12B3               f4's enemy display list ($12AA): the point's X, the enemy's X (its record +1, 16 bits)
vEnemyPtY           equ       $12B5               f4's enemy display list: the point's Y, the enemy's altitude (its record +4, 16 bits)
vEnemyPtZ           equ       $12B7               f4's enemy display list: the point's Z, the enemy's Z (its record +7, 16 bits)
vTracerTbl          equ       $12BA               f4's tracers: 14 entries of 6 bytes (start time, time, aim x, x, aim y, y); time $FF ends it
vEnemyRec1          equ       $1310               enemy 1's record, 28 bytes: X, height, Z (24 bits each), radar +9, target +$0A, status +$17, home +$1A
vEnemy1Status       equ       $1327               f4: enemy 1's status, 0 shot down, 1 returning or home, 2 attacking (its record +$17)
vEnemyRec2          equ       $132C               enemy 2's record (28 bytes, as vEnemyRec1)
vEnemy2Status       equ       $1343               f4: enemy 2's status, 0 shot down, 1 returning or home, 2 attacking (its record +$17)
vEnemyRec3          equ       $1348               enemy 3's record (28 bytes, as vEnemyRec1)
vEnemy3Status       equ       $135F               f4: enemy 3's status, 0 shot down, 1 returning or home, 2 attacking (its record +$17)
vEnemyRec4          equ       $1364               enemy 4's record (28 bytes, as vEnemyRec1)
vEnemy4Status       equ       $137B               f4: enemy 4's status, 0 shot down, 1 returning or home, 2 attacking (its record +$17)
vEnemyRec5          equ       $1380               enemy 5's record (28 bytes, as vEnemyRec1)
vEnemy5Status       equ       $1397               f4: enemy 5's status, 0 shot down, 1 returning or home, 2 attacking (its record +$17)
vEnemyRec6          equ       $139C               enemy 6's record (28 bytes, as vEnemyRec1)
vEnemy6Status       equ       $13B3               f4: enemy 6's status, 0 shot down, 1 returning or home, 2 attacking (its record +$17)
vEnemyRecEnd        equ       $13B8               the end of the six enemy records (enemies 1-3's home position record follows)
vDictOfs            equ       $13D0               the packed text's dictionary: each token word's offset in vDictText (token $80 + n)
vDictText           equ       $13DD               the packed text's dictionary words, each ending in 0
F4RadarCtr          equ       $1443               f4: the panel radar's center mark, from the panel's top ($0CD3): row 64, x 134-135
vGlyphFont          equ       $14C0               FS's 3 x 5 font (DrawGlyph's): a word a character from $20, three bits a row, the top row lowest
vRowAddrTbl         equ       $1538               FS's table of screen row offsets (row x 80), added to a screen base
vNeedleLong         equ       $16B8               the long dial needle's shapes: 23 row-span pointers, a quarter turn (airspeed, altimeter hundreds)
vNeedleShort        equ       $16E8               the short dial needle's shapes: 23 row-span pointers (altimeter thousands, VSI, ADF)
GpuPrbDot           equ       $1812               PROBE_DOT (Gpu.Prb+2): the splashdown probe's dot, a word
vSlipBallShape      equ       $1BF2               the slip ball's shape: row spans, a negative word ends them
FsPanelOfs          equ       $1EF0               the panel's first row (CoCo row 99) from FS's screen base: 99 x 80 bytes (WbScrBase+FsPanelOfs = $8000)
vIcptData           equ       $1F10               F$Icpt's data pointer (U) for SignalIntercept, which does not use it
FswBrdRq            equ       $1FF7               fsw's BrdRq: the OS border's GpuF.FixN request (offset, mask 7, 0), FswBrdSv after it
* the WildBits layers' areas ($2000-$9FFF)
FsFdPath            equ       $2010               LoadDataFileFd: the fd file's path (fsw's polygon space, before fsw is loaded)
vBackBuf            equ       $2010               the CoCo's view back buffer, 99 rows of 80 bytes to $3EFF (fsw's areas in the port); X before LoadPanelPicture, unused
vSceneryDir         equ       $2010               f3's scenery menu: the path's directory part, CR-terminated ($2010-$202F)
FsFdRecLen          equ       $2011               LoadDataFileFd: the record's length (word; 0 ends the file)
FsFdRecAdr          equ       $2013               LoadDataFileFd: the record's address (word)
vSceneryName        equ       $2030               f3's scenery menu: the path's file name part, sf.xxx and a CR ($2030-$204F; fswc's FsName)
vSceneryNameTail    equ       $2033               vSceneryName past its sf. prefix (vSceneryName+3): the chosen list name goes there
F3DirEnt            equ       $2050               f3: the directory entry read (32 bytes, the name first, its last character's bit 7 set)
vSfDirEnt           equ       $2050               f3's scenery menu: the directory entry just read, 32 bytes ($2050-$206F)
vSfEntName          equ       $2053               vSfDirEnt's name past its sf. prefix (vSfDirEnt+3)
vSfList             equ       $2070               f3's scenery menu: the file list, 4 bytes an entry (name pointer, length), a zero entry ends it
F3MenuText          equ       $2200               f3: the loaded scenery's menu text, read here up to FswRecBuf
F3NameBuf           equ       $2200               f3: the sf.* files' names (after sf., 29 bytes at most each), up to FswRecBuf
vSfMenuText         equ       $2200               f3's scenery load: the scenery's menu text read from the file, then written to FS's path
vSfNames            equ       $2200               f3's scenery menu: the listed file names (vSfList's entries point here), up to FswRecBuf
FsCourseOfs         equ       $3C00               the course plotter's points (a display list) from FS's screen base: $9D10
Ang90               equ       $4000               90 degrees, a quarter turn, in FS's 16-bit angle
FsclBase            equ       $4000               fscl's run address: the clouds' block mapped at $4000 in place of the scenery window
FsclInit            equ       $4000               fscl's ClInit (its block at $4000: fst's CbIn): the cloud shapes made, the slots free
WbWinStart          equ       $4000               the scenery window's start: where an overlay links (FS's data memory shrunk to it) and the data block loads
FsclRun             equ       $4003               fscl's ClRun: a frame's clouds
FsclGdRun           equ       $4006               fscl's GdRun: the textured ground (fst's GdDraw)
Q15One              equ       $7FFF               a full Q15 one (32767)
WbPanelBlk          equ       $8000               the panel's block in the flight screen's map, $8000-$9FFF: FS's screen base + $1EF0, its row 99
WbCourseEnd         equ       $9FF2               the course plotter's points' end: the screen block's end, after the panel
* FS's code (ModBase $A000 + the label's offset; fs_wb.asm checks each)
FsTermReset         equ       $A05F               WriteTermResetStr: the 67-byte control string at $0E0E to the window path (f5.asm's equate)
FsClearView         equ       $A06D               ClearViewWindow: the view's rectangle (0,0)-($9F,$62) in color 0 (f5.asm's equate)
FsLoadPanelPicture  equ       $A1EA               LoadPanelPicture (WildBits: ClearViewWindow, no panel picture)
FsLoadPictureFa     equ       $A1F3               LoadPictureFa (WildBits: no fa, carry clear)
FsInitFlightDisplay equ       $A414               InitFlightDisplay: UpdateInstrumentMasks, then every panel instrument redrawn
FsSetHeightFromTerrain equ       $A57C               SetHeightFromTerrain
FsPollKey           equ       $A6D2               PollKey: B = a key (fsw's KeyMap applied), Z when none (f5.asm's equate)
FsSetMagnetos       equ       $A91F               A = the magneto switch (vMagSw), B = the magnetos on (b0 vMag1, b1 vMag2): <$EA cleared, the switch line redrawn
FsShowThrottlePos   equ       $AC45               ShowThrottlePos: the throttle marker from vThrottle
FsShowElevatorPos   equ       $ACAA               ShowElevatorPos: the elevator marker from vElevator
FsSetFlaps          equ       $ACD1               A = the flaps ($081E's high byte): the flaps marker moved, the flaps' lift and drag terms set
FsShowAileronPosGauge equ       $AD4C               ShowAileronPosGauge: the aileron marker from vAileron
FsShowRudderPos     equ       $AD86               ShowRudderPos: the rudder marker, then UpdatePitchCtlTerms
FsSetLineColor      equ       $AEC8               SetLineColor: A = color 0-15 -> <$EE
FsSetFillColor      equ       $AED7               SetFillColor: A = color 0-15 -> $0178, <$F0/<$F1
FsPlotPixel         equ       $AF15               PlotPixel: A = x, B = row, Y = the base: one pixel in the line color
FsDrawLine          equ       $AF43               DrawLine: X = (x1,y1), D = (x2,y2), Y = the base
FsFillRect          equ       $B3EE               FillRect: D = (x1,y1), X = (x2,y2), Y = the base, in the fill color
FsDec3ToAscii       equ       $B49E               Dec3ToAscii: D (0-999) -> 3 ASCII digits at X
FsDrawClockHourMin  equ       $B5EC               DrawClockHourMin: the clock's hours and minutes printed on the panel
FsDrawEngineSwitches equ       $B652               DrawEngineSwitches: the carb heat, lights and magneto texts printed
FsSetAdfFreq        equ       $B683               SetAdfFreq: the ADF's frequency printed and retuned
FsPrintPanelText5   equ       $B74E               PrintPanelText5: text record X on the panel in color 5
FsPrintPanelTextF   equ       $B75D               PrintPanelTextF: text record X on the panel in color 15
FsShowTextMsgWaitKey equ       $B9B5               ShowTextMsgWaitKey: X/Y message on the text screen, a key waited for
FsInitAdfNeedle     equ       $C158               InitAdfNeedle: the ADF needle drawn at position 0
FsMulQ15Vars        equ       $D283               MulQ15Vars: <$AF x <$B1 (Q15, rounded) -> D
FsDivQ15Signed      equ       $D353               DivQ15Signed: D / <$B1 -> D (Q15, saturated)
FsCos8              equ       $D3AB               Cos8: A = an angle (1/256 turn) -> D = its cosine (Q15)
FsSin8              equ       $D3AE               Sin8: A = an angle (1/256 turn) -> D = its sine (Q15)
FsHalveLineEnds     equ       $E7E5               both ends of FS's 3D line, <$B8 and <$C1 (three words each), halved: FS's clipper's overflow retry
FsResetFlightState  equ       $F238               ResetFlightState: the transient flight and failure state cleared
* hardware the defs do not name
Low16Mask           equ       $FFFF               keeps a value's low 16 bits
* the view matrix's elements and the base sums' low bytes, by name
vViewMXY            equ       vViewM+2            the view matrix: row x, column y (Q15)
vViewMXZ            equ       vViewM+4            the view matrix: row x, column z (Q15)
vViewMYX            equ       vViewM+6            the view matrix: row y, column x (Q15)
vViewMYY            equ       vViewM+8            the view matrix: row y, column y (Q15)
vViewMYZ            equ       vViewM+10           the view matrix: row y, column z (Q15)
vViewMZX            equ       vViewM+12           the view matrix: row z, column x (Q15)
vViewMZY            equ       vViewM+14           the view matrix: row z, column y (Q15)
vViewMZZ            equ       vViewM+16           the view matrix: row z, column z (Q15)
vBaseSumXLo         equ       vBaseSumX+2         GroundPoint's base sum for camera x: its low byte
vBaseSumYLo         equ       vBaseSumY+2         GroundPoint's base sum for camera y: its low byte
vBaseSumZLo         equ       vBaseSumZ+2         GroundPoint's base sum for camera z: its low byte
