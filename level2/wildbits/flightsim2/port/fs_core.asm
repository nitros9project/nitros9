* fs_core.asm - FS (Flight Simulator II), part of the port: startup and quit, data and picture loading, main loop and back buffer, ground and crash checks,
* keyboard and joystick input, line / horizontal-run drawing, polygon edge setup ($0020-$11E0)
* Assembled by fs.asm (use); absolute self-references are label+ModBase.

                    jmp       >FsMain+ModBase
WbPart              set       3
                    use       fs_wb.asm           the WildBits platform layer, part 3 (the title screen keeps the copyright)
* WildBits: the CoCo's "fa" file name (the ADF dial piece) is gone; its bytes stay so no address moves
                    zmb       3
* StrFileFd: filename "fd" (CR-terminated): initialized-data file loaded into the data area at startup
StrFileFd               fcb       $66,$64,$0D
* WildBits: the CoCo's "fp" file name (the panel picture) is gone; its bytes stay so no address moves
                    zmb       3
* StrDevFTDD: device name "/FTDD" (CR-terminated), opened at startup (path in $0286)
StrDevFTDD               fcb       $2F
                    fcc       /FTDD/
                    fcb       $0D
* WriteTermResetStr: writes the 67-byte control string at $0E0E to the window path $0CD6; probably resets the text screen after a prompt
WriteTermResetStr               lda       >FsPath
                    ldx       #vTextClearStr
                    ldy       #TextClearLen       WildBits: the palette records are CLUT entries now (WbPalette)
                    os9       I$Write
                    rts
* ClearViewWindow: fills screen rectangle (0,0)-($9F,$62) with color 0: clears the out-the-window 3D view area
ClearViewWindow               lda       #ColorClear
                    jsr       >SetFillColor+ModBase
                    ldd       #ViewTopLeft
                    ldx       #ViewBotRight
                    ldy       >FsScreen
                    jmp       >FillRect+ModBase
* FsMain: program entry: F$Mem, load fd data, open /FTDD, save/set terminal options, allocate graphics screen, ask monitor type and option, then start flight
FsMain               ldd       #WbWin2
                    os9       F$Mem
                    lblo      FsExit
                    jsr       >WbStart+ModBase     WildBits: data directory
                    tfr       dp,a
                    jsr       >LoadDataFileFd+ModBase
                    lblo      FsExit
                    jsr       >InitRunTable65+ModBase
                    lda       #StdInPath
                    sta       >FsKeyPath
                    lda       #StdOutPath
                    sta       >FsPath
                    ldx       #SignalIntercept+ModBase
                    ldu       #vIcptData
                    os9       F$Icpt
                    lda       #OpenUpdate
                    ldx       #StrDevFTDD+ModBase
                    os9       I$Open
                    lblo      FsExit
                    sta       >vFtddPath
                    lda       >vFtddPath
                    ldb       #SsFClr
                    ldx       #FrameSigTicks
                    ldy       #FrameSigOn
                    os9       I$SetStt
                    lblo      FsExit
                    lda       >FsKeyPath
                    ldx       #vOptSaved
                    ldb       #SsOpt
                    os9       I$GetStt
                    lda       >FsKeyPath
                    ldx       #vOptPacket
                    ldb       #SsOpt
                    os9       I$GetStt
                    clra
                    sta       >vOptEcho
                    sta       >vOptAutoLf
                    sta       >vOptPause
                    ldy       #vOptBsp
* FsMainClrOptsLoop: clears the path option bytes $0D04-$0D0E before I$SetStt SS.Opt
FsMainClrOptsLoop               sta       ,y+
                    cmpy      #vOptParity
                    blo       FsMainClrOptsLoop
                    lda       >FsKeyPath
                    ldx       #vOptPacket
                    ldb       #SsOpt
                    os9       I$SetStt
                    lda       >FsPath
                    jsr       >WbAScrn+ModBase     WildBits flight screen
                    nop
                    nop
                    nop
                    nop
                    nop
                    bhs       FsMainGotScreen
                    ldb       #ErrNoScreen
                    jsr       >FatalSystemError+ModBase
* FsMainGotScreen: after SS.AScrn: stores screen address $0CCF, end $0CD1/$0CD3, screen number $0CCD; loads the panel
FsMainGotScreen               stx       >FsScreen
                    leax      >FsPanelOfs,x
                    stx       >vPanelScrInit
                    stx       >vPanelScr
                    sty       >WbScrBlks
                    ldx       #vBackBuf
                    ldd       #ViewScrNone        WildBits: the view has no memory; its addresses (row*80 + x/2) only name rows
                    std       >vViewScr
                    jsr       >LoadPanelPicture+ModBase
* FsMainAskMonitor: prompt (text $0E85) for monitor type A-C, sets SS.Montr from table $0E82; BREAK shows info text
FsMainAskMonitor               ldx       #vMonitorMsg
                    ldy       #MonitorMsgLen
                    lda       #MsgTextStays
                    jsr       >ShowTextMsgWaitKey+ModBase
                    cmpb      #KeyShiftBreak
                    beq       FsMainShowInfo
                    andb      #UpperCaseMask
                    cmpb      #KeyA
                    blo       FsMainAskMonitor
                    cmpb      #KeyC
                    bhi       FsMainAskMonitor
                    subd      #KeyA
                    clra
                    ldx       #vMonitorTypes
                    ldb       b,x
                    tfr       d,x
                    lda       >FsPath
                    ldb       #SsMontr
                    os9       I$SetStt
* FsMainAskOptionAB: prompt (text $0F91) for A or B; stores choice xor 1 in $02C7 (meaning not determined), then jumps to StartFlight
FsMainAskOptionAB               ldx       #vOpModeMsg
                    ldy       #OpModeMsgLen
                    clra
                    jsr       >ShowTextMsgWaitKey+ModBase
                    andb      #UpperCaseMask
                    cmpb      #KeyA
                    blo       FsMainAskOptionAB
                    cmpb      #KeyB
                    bhi       FsMainAskOptionAB
                    subb      #KeyA
                    eorb      #DemoAnswerFlip
                    stb       >vDemo
                    ldd       #WbWinStart
                    std       >vListStart
                    ldd       #WbWinEnd           WildBits: the window to $7FFF (WbAScrn's block at $6000)
                    std       >vListEnd
                    jmp       >StartFlight+ModBase
* FsMainShowInfo: BREAK at the monitor prompt: shows the text at $0FEA (266 bytes), then asks again
FsMainShowInfo               ldx       #vCreditsMsg
                    ldy       #CreditsMsgLen
                    lda       #MsgTextStays
                    jsr       >ShowTextMsgWaitKey+ModBase
                    bra       FsMainAskMonitor
* QuitProgram: quit (key $90): unloads pending overlay, shows screen 0, frees graphics screen, restores terminal options, resets and closes /FTDD, exits
QuitProgram               lda       >vOvlReq
                    beq       QuitProgramRestore
                    clr       >vOvlReq
                    jsr       >SwitchOverlay+ModBase
* QuitProgramRestore: quit: restore display/terminal and close /FTDD
QuitProgramRestore               lda       >FsPath
                    ldy       #DScrnText
                    jsr       >WbDScrn+ModBase            WildBits SS.DScrn (fs_wb.asm)
                    nop
                    nop
                    lda       >FsPath
                    ldy       #ViewBitmap0        WildBits: bitmap 0
                    ldb       #SsFScrn
                    os9       I$SetStt
                    lda       >FsPath
                    ldx       #vGoodbyeMsg
                    ldy       #GoodbyeMsgLen
                    os9       I$Write
                    lda       >FsKeyPath
                    ldx       #vOptSaved
                    ldb       #SsOpt
                    os9       I$SetStt
                    lda       >vFtddPath
                    ldb       #SsFClr
                    ldy       #FrameSigOff
                    os9       I$SetStt
                    lda       >vFtddPath
                    os9       I$Close
                    clrb
* FsExit: os9 F$Exit with B = status (also the startup error exit)
FsExit               equ       *
* WildBits: the screen's blocks out of the map, then F$Exit
                    jmp       >WbExit+ModBase
* LoadPanelPicture: clears the view window. WildBits: no "fp" (the CoCo's panel picture): FS's panel is the
* dashboard (fsp), so nothing is loaded; the bytes keep their length so no address moves.
LoadPanelPicture               jmp       >ClearViewWindow+ModBase
                    zmb       6
* LoadPictureFa: WildBits: no "fa" (the CoCo's ADF dial piece): the dashboard draws its own ADF. Carry clear.
LoadPictureFa               andcc     #NotCarry
                    rts
                    zmb       93                  the CoCo's picture file loader, gone
* LoadDataFileFd: opens "fd" and reads records (length word, address word, data) into the data area until a zero length
LoadDataFileFd               ldx       #StrFileFd+ModBase
                    lda       #OpenRead
                    os9       I$Open
                    blo       LoadDataFdDone
                    sta       >FsFdPath
* LoadDataFdLoop: reads the next record length; zero ends the file
LoadDataFdLoop               lda       >FsFdPath
                    ldx       #FsFdRecLen
                    ldy       #FdWordLen
                    os9       I$Read
                    blo       LoadDataFdClose
                    ldx       >FsFdRecLen
                    beq       LoadDataFdEnd
                    lda       >FsFdPath
                    ldx       #FsFdRecAdr
                    ldy       #FdWordLen
                    os9       I$Read
                    blo       LoadDataFdClose
                    lda       >FsFdPath
                    ldx       >FsFdRecAdr
                    ldy       >FsFdRecLen
                    os9       I$Read
                    blo       LoadDataFdClose
                    bra       LoadDataFdLoop
* LoadDataFdEnd: end record reached: clear carry
LoadDataFdEnd               andcc     #NotCarry
* LoadDataFdClose: closes the fd path keeping the cc/b status
LoadDataFdClose               pshs      cc,b
                    lda       >FsFdPath
                    os9       I$Close
                    puls      cc,b
* LoadDataFdDone: return; carry set on error
LoadDataFdDone               rts
* InitRunTable65: fills $034A-$0718 with runs of 65 equal bytes 10,11,12,... (lookup table; use not determined)
InitRunTable65               lda       #FirstUserMode
                    ldx       #vModeLib
* InitRunTable65Run: starts a new 65-byte run
InitRunTable65Run               ldb       #ModeRecLen
* InitRunTable65Loop: stores one byte of the current run
InitRunTable65Loop               sta       ,x+
                    cmpx      #vModeLibEnd
                    bhs       InitRunTable65Done
                    decb
                    bne       InitRunTable65Loop
                    inca
                    bra       InitRunTable65Run
* InitRunTable65Done: return
InitRunTable65Done               rts
* StartFlight: initializes the flight display (InitFlightDisplay, LoadDataBlock) and enters the main loop
StartFlight               jsr       >InitFlightDisplay+ModBase
                    jsr       >LoadDataBlock+ModBase
* MainLoop: main frame loop: pause handling, flight model, scenery, instruments, keys, joystick, phased updates
MainLoop               lda       >vPaused
                    beq       MainLoopRun
                    jsr       >ShowPausedMsg+ModBase
* MainLoopWaitUnpause: paused: waits for the P key, then clears $0223 and re-reads the /FTDD status
MainLoopWaitUnpause               jsr       >PollKey+ModBase
                    beq       MainLoopWaitUnpause
                    andb      #UpperCaseMask
                    cmpb      #KeyP
                    bne       MainLoopWaitUnpause
                    clr       >vPaused
                    lda       >vFtddPath
                    ldb       #SsVCtr
                    os9       I$GetStt
* MainLoopRun: runs one frame: physics, view, instrument updates
MainLoopRun               jsr       >DrawAltimeter+ModBase
                    jsr       >CalcAirspeedNeedle+ModBase
                    lda       >vSlew
                    beq       MainLoopFlightModel
                    jsr       >SlewModeUpdate+ModBase
                    bra       MainLoopAfterModel
* MainLoopFlightModel: $0304 clear: runs UpdateFlightPhysics (normal flight model path; $0304 probably slew/edit mode)
MainLoopFlightModel               jsr       >UpdateFlightPhysics+ModBase
* MainLoopAfterModel: common frame work after the flight model call
MainLoopAfterModel               jsr       >ApplyWindDrift+ModBase
                    jsr       >PrintPendingMessage+ModBase
* WildBits: fsw builds it (BuildViewMatrix) and hands it to the K2's point pipeline
                    jsr       >FswMatrix
                    jsr       >DrawSkyGround+ModBase
                    jsr       >DrawTachRpm+ModBase
                    jsr       >UpdAttitudeInd+ModBase
                    ldd       >vListStart
                    cmpd      >vListEnd
                    beq       MainLoopNoChange
                    std       <vDispListPtr
* WildBits: on the K2's SceneEngine when it is there (fsw), else RunDisplayList
                    jsr       >FswScene
* MainLoopNoChange: after the $0240/$0244 compare (RunDisplayList only when they differ); overlay check, view shape, crash check
* WildBits: in the spot view fsw puts the aircraft's position back and draws the aircraft first, and draws no
* cockpit parts
MainLoopNoChange               jsr       >FswOvl
                    jsr       >FswParts
                    jsr       >CoursePlotterUpdate+ModBase
                    jsr       >DrawSlewPosition+ModBase
                    jsr       >DrawNav1Indicator+ModBase
                    jsr       >DrawNav2Indicator+ModBase
                    jsr       >CheckCrashMessage+ModBase
                    jsr       >SetPanelLightMask+ModBase
                    lsr       >vSkipPresent
                    blo       MainLoopNoBlit
                    jsr       >FswPresent         WildBits: the view drawn into the bitmaps, flipped
* MainLoopNoBlit: after the optional back buffer copy to the screen
MainLoopNoBlit               jsr       >UpdateGroundElev+ModBase
                    jsr       >DrawHeadingInd+ModBase
                    jsr       >DrawMagCompass+ModBase
                    jsr       >FswFrame           WildBits: instruments, then the panel copy
* MainLoopKeyLoop: polls keys and dispatches each through DispatchKey until none is waiting
MainLoopKeyLoop               jsr       >PollKey+ModBase
                    beq       MainLoopKeysDone
                    jsr       >DispatchKey+ModBase
                    bra       MainLoopKeyLoop
* MainLoopKeysDone: reads joysticks, then does the per-frame-phase work selected by the low bits of <$40
MainLoopKeysDone               jsr       >ReadJoysticks+ModBase
                    lda       <vFrameCount
                    lsra
                    blo       MainLoopOddPhase
                    lsra
                    blo       MainLoopPhase2
                    jsr       >UpdateDaylight+ModBase
                    jsr       >UpdTurnCoord+ModBase
                    jsr       >UpdFuelGauge1+ModBase
                    jsr       >ComputeWindDrift+ModBase
                    jsr       >DrawDmeReadout+ModBase
                    lda       <vFrameCount
                    anda      #FrameEvery8
                    beq       MainLoopEvenTail
                    jsr       >FlagNav1Retune+ModBase
                    jsr       >FlagNav2Retune+ModBase
                    jsr       >FlagAdfRetune+ModBase
                    lda       >vDemo
                    beq       MainLoopPhase0End
                    ldb       #LoadKindDemo
                    stb       >vLoadKind
                    ldb       #OvlF2
                    stb       >vOvlReq
* MainLoopPhase0End: end of the phase 0 instrument updates
MainLoopPhase0End               bra       MainLoopEvenTail
* MainLoopPhase2: frame phase 2 updates (UpdOilTempGauge, FlightAuxUpdate)
MainLoopPhase2               jsr       >UpdOilTempGauge+ModBase
                    jsr       >FlightAuxUpdate+ModBase
                    bra       MainLoopEvenTail
* MainLoopOddPhase: odd frame phases (1 and 3)
MainLoopOddPhase               lsra
                    blo       MainLoopPhase1
                    jsr       >UpdFuelGauge2+ModBase
                    bra       MainLoopOddCommon
* MainLoopPhase1: frame phase 1 updates (UpdOilPressGauge, UpdateReliability)
MainLoopPhase1               jsr       >UpdOilPressGauge+ModBase
                    jsr       >UpdateReliability+ModBase
* MainLoopOddCommon: common odd-phase updates; rotates the 16-bit $0134
MainLoopOddCommon               jsr       >UpdateNav1+ModBase
                    jsr       >UpdateNav2+ModBase
                    jsr       >CalcVsiNeedle+ModBase
                    jsr       >UpdAdfNeedle+ModBase
                    ldd       >vBlink
                    aslb
                    rola
                    adcb      #CarryOnly
                    std       >vBlink
                    jmp       >MainLoopNextFrame+ModBase
* MainLoopEvenTail: even-phase tail updates (splash check, UpdateStallTimer, UpdSlipBall)
MainLoopEvenTail               jsr       >CheckSplashdown+ModBase
                    jsr       >UpdateStallTimer+ModBase
                    jsr       >UpdSlipBall+ModBase
* MainLoopNextFrame: increments the frame counter <$40 and loops
MainLoopNextFrame               inc       <vFrameCount
                    jmp       >MainLoop+ModBase
* (CopyBackBufToScreen, gone: fsw's Present replaced it)
                    zmb       90
* InitFlightDisplay: calls UpdateInstrumentMasks then redraws every panel instrument
InitFlightDisplay               jsr       >UpdateInstrumentMasks+ModBase
* RedrawAllInstruments: redraws all panel instruments and gauges and forces later redraws ($FFFF in the last-value caches)
RedrawAllInstruments               jsr       >SetNav1Freq+ModBase
                    jsr       >SetNav2Freq+ModBase
                    jsr       >SetComFreq+ModBase
                    clr       >vComSearch
                    jsr       >SetXpdrCode+ModBase
                    jsr       >DrawNav1Obs+ModBase
                    jsr       >DrawNav2Obs+ModBase
                    jsr       >DrawClockSeconds+ModBase
                    jsr       >DrawTachRpm+ModBase
                    jsr       >InitAltimeterHands+ModBase
                    jsr       >InitAirspeedNeedle+ModBase
                    jsr       >InitVsiNeedle+ModBase
                    lda       >vAdfEnable
                    beq       RedrawAllInstrNoX
                    jsr       >InitAdfNeedle+ModBase
* RedrawAllInstrNoX: continuation after the optional InitAdfNeedle call ($0348 set)
RedrawAllInstrNoX               jsr       >InitElevatorMarker+ModBase
                    jsr       >InitAileronMarker+ModBase
                    jsr       >InitRudderMarker+ModBase
                    jsr       >InitOilPressGauge+ModBase
                    jsr       >InitOilTempGauge+ModBase
                    jsr       >InitFuelGauge1+ModBase
                    jsr       >InitFuelGauge2+ModBase
                    jsr       >InitThrottleMarker+ModBase
                    jsr       >InitElevTrimMarker+ModBase
                    jsr       >InitFlapsMarker+ModBase
                    jsr       >InitTurnCoord+ModBase
                    jsr       >InitSlipBall+ModBase
                    jsr       >DrawEngineSwitches+ModBase
                    jsr       >DrawFuelTankSel+ModBase
                    jsr       >DrawClockHourMin+ModBase
                    lda       >vAttPitchShown
                    adda      #AttRedrawOfs
                    sta       >vAttPitchShown
                    ldd       #NotDrawn
                    sta       >vNav1Cdi
                    sta       >vNav2Cdi
                    sta       >vGsNeedle
                    std       >vHdgDeg
                    sta       >vRpmShown
                    sta       >vNav1FlagShown
                    sta       >vNav2FlagShown
                    sta       >vShownSpare
                    lda       #DmeRedraw
                    sta       >vDmeRedraw
                    jsr       >DrawDmeReadout+ModBase
                    rts
* UpdateGroundElev: snaps the ground elevation vElev to the area's vElevArea when $07BC < 10, then steps it toward
* vElevArea twice
UpdateGroundElev               ldx       >vElevArea
                    ldb       >vAirspeed+1
                    cmpb      #ElevSnapSpeedLo
                    bhs       UpdateGroundElevTwice
                    stx       >vElev
* UpdateGroundElevTwice: calls StepGroundElev then falls into it (two steps)
UpdateGroundElevTwice               jsr       >StepGroundElev+ModBase
* StepGroundElev: moves vElev one meter toward vElevArea and the height above ground (vAlt) the other way, floor 3
StepGroundElev               ldb       #GroundElevStep
                    ldx       >vElevArea
                    cmpx      >vElev
                    bhs       StepGroundElevApply
                    decb
                    decb
* StepGroundElevApply: applies the +1/-1 step to vElev
StepGroundElevApply               sex
                    tfr       d,y
                    addd      >vElev
                    std       >vElev
                    tfr       y,d
                    coma
                    comb
                    addd      #NegCarry
                    tsta
                    bmi       StepGroundElevAddHt
                    ldd       #HtAboveGndStep
* StepGroundElevAddHt: adds the opposite step to the height above ground <$05
StepGroundElevAddHt               addd      <vAlt+1
                    std       <vAlt+1
                    bmi       StepGroundElevFloor
                    bne       StepGroundElevDone
                    lda       <vAlt+2
                    cmpa      #GndHeightMid
                    bhs       StepGroundElevDone
* StepGroundElevFloor: height went below 3: set it to 3 (fraction cleared)
StepGroundElevFloor               lda       #GndHeightMid
                    sta       <vAlt+2
                    clra
                    clrb
                    std       <vAlt
* StepGroundElevDone: return
StepGroundElevDone               rts
* MsgCrash: screen text "CRASH !!!" (position bytes $14,$32, zero-terminated)
MsgCrash               fcb       $14
                    fcc       /2CRASH !!!/
                    fcb       $00
* MsgSplash: screen text "SPLASH !!!" (position bytes $14,$32, zero-terminated)
MsgSplash               fcb       $14
                    fcc       /2SPLASH !!!/
                    fcb       $00
* CheckCrashMessage: if a crash is flagged ($0137, $0304 clear): clears the view, prints CRASH or SPLASH ($0137 = 8), waits, requests overlay 1
CheckCrashMessage               lda       >vSlew
                    bne       CheckCrashMsgClear
                    lda       >vCrash
                    beq       CheckCrashMsgDone
                    ldx       #MsgCrash+ModBase
                    cmpa      #CrashSplash
                    bne       CheckCrashMsgShow
                    ldx       #MsgSplash+ModBase
* CheckCrashMsgShow: shows the selected message and requests the reset overlay
CheckCrashMsgShow               pshs      x
                    jsr       >ClearViewWindow+ModBase
                    ldd       #TxtRed
                    std       >vTextColor
                    puls      x
                    ldu       >FsScreen
                    jsr       >DrawTextString+ModBase
                    lda       #CrashMsgDelay
                    jsr       >DelayA+ModBase
                    ldb       #LoadKindCrash
                    stb       >vLoadKind
                    stb       >vOvlReq
* CheckCrashMsgClear: clears the crash code $0137
CheckCrashMsgClear               clr       >vCrash
* CheckCrashMsgDone: return
CheckCrashMsgDone               rts
* CheckSplashdown: on the ground ($0781), forward view, pixel under the nose is water color $2222: after 3 frames sets crash code 8 (splash)
CheckSplashdown               lda       >vOnGnd
                    beq       CheckSplashdownReset
* WildBits: the color under the nose from fsw's probe (the CoCo view rows are not mapped)
                    ldx       #FswProbe
                    nop
                    nop
                    nop
                    nop
                    ldd       ,x
                    cmpd      #WaterColorWord
                    bne       CheckSplashdownReset
                    lda       >vViewDir
                    bne       CheckSplashdownReset
                    ldd       >vMapView-1
                    bne       CheckSplashdownReset
                    lda       >vGroundSettle
                    bne       CheckSplashdownReset
                    dec       >vSplashCount
                    bne       CheckSplashdownDone
                    lda       #CrashSplash
                    sta       >vCrash
* CheckSplashdownReset: resets the splash frame counter $08A1 to 3
CheckSplashdownReset               lda       #SplashFrames
                    sta       >vSplashCount
* CheckSplashdownDone: return
CheckSplashdownDone               rts
* DelayA: busy-wait delay: A x 3 x 65536 loop iterations
DelayA               equ       *
* WildBits: the message just drawn shown, then the CoCo's delay in ticks (fsw)
                    jmp       >FswDelay
                    nop
* DelayAOuter: middle delay loop (Y)
DelayAOuter               ldx       #DelayInnerLoops
* DelayAInner: inner delay loop (X)
DelayAInner               leax      -1,x
                    bne       DelayAInner
                    leay      -1,y
                    bne       DelayAOuter
                    deca
                    bne       DelayA
                    rts
* SetHeightFromTerrain: probably recomputes the height above ground <$05 from <$B3 - vElev (via MulU16Mid), floor 3, clears <$04/<$07
SetHeightFromTerrain               ldd       >vModeAltFt
                    addd      #GndHeightFt
                    std       <vMulA
                    ldd       #MPerFtQ16Fs
                    jsr       >MulU16Mid+ModBase
                    ldd       <vMulProd
                    subd      >vElev
                    bmi       SetHeightFromTerrMin
                    cmpd      #GndHeightMid
                    bhs       SetHeightFromTerrStore
* SetHeightFromTerrMin: height below 3: use 3
SetHeightFromTerrMin               ldd       #GndHeightMid
* SetHeightFromTerrStore: stores the height above ground in <$05
SetHeightFromTerrStore               std       <vAlt+1
                    clra
                    sta       <vAlt+3
                    sta       <vAlt
                    rts
* TblViewAircraftParts: 11 pointers to shape lists (type 0 filled polygon or 1 line set, color, x/y points, $FFFF end)
* drawn in the view per view direction $0839. WildBits: the CoCo's wing and strut polygons of the side views (entries
* 1-7) are gone: their pointers on the empty shape ($A5B8), their bytes zeroed. Entry 9 is the straight-down view's
* airplane symbol ($0139), entry 10 the one $0839 bit 7 with $0307 selects; both kept at their places.
TblViewAircraftParts               fcb       $A5,$B8,$A5,$B8,$A5,$B8,$A5,$B8
                    fcb       $A5,$B8,$A5,$B8,$A5,$B8,$A5,$B8
* WildBits: the shapes in 256x127 view units
                    fcb       $A6,$0D,$A6,$0E,$A6,$1E,$FF
                    zmb       84
* WildBits (2026-10-21): entry 9, the map view's airplane symbol, is Roger's top-down icon cropped and scaled onto
* the original's 7 x 8 units (x 123-129, y 60-67, color $DD): the fuselage, the wing 3 units down, the 3-unit tail
* bar on the fuselage's end (the original: a cross with the tail bar a row below the fuselage)
                    fcb       $FF,$01,$DD,$7E,$3C
                    fcb       $7E,$43,$7B,$3F,$81,$3F,$7D,$43
                    fcb       $7F,$43,$FF,$FF,$01,$44,$7E,$35
                    fcb       $7E,$49,$75,$3F,$88,$3F,$7B,$35
                    fcb       $82,$35,$7B,$3A,$82,$3A,$7B,$44
                    fcb       $82,$44,$7B,$49,$82,$49,$FF,$FF
* DrawViewAircraftParts: draws the shape from TblViewAircraftParts selected by view direction $0839 ($0307 and $0139 select other entries) into the back buffer
DrawViewAircraftParts               ldx       #TblViewAircraftParts+ModBase
                    ldb       >vViewDir
                    bpl       DrawViewPartsChkFlag
                    ldb       #PartsUpView
                    lda       >vEurope1917
                    beq       DrawViewPartsChkFlag
                    ldb       #PartsUpView1917
* DrawViewPartsChkFlag: $0139 set selects entry 9
DrawViewPartsChkFlag               lda       >vMapView
                    beq       DrawViewPartsSelect
                    ldb       #PartsMapView
* DrawViewPartsSelect: fetches the shape list; type 0 = filled polygon
DrawViewPartsSelect               abx
                    ldx       ,x
                    lda       ,x+
                    bne       DrawViewPartsLines
                    lda       ,x+
                    pshs      x
                    jsr       >SetFillColor+ModBase
                    puls      x
                    ldd       ,x++
                    pshs      x
                    jsr       >PolyBegin+ModBase
                    puls      x
* DrawViewPartsPolyLoop: adds polygon vertices until $FFFF
DrawViewPartsPolyLoop               ldd       ,x++
                    cmpd      #ShapeEnd
                    beq       DrawViewPartsPolyFill
                    pshs      x
                    jsr       >PolyAddVertex+ModBase
                    puls      x
                    bra       DrawViewPartsPolyLoop
* DrawViewPartsPolyFill: closes and fills the polygon
DrawViewPartsPolyFill               jsr       >FillPolygon+ModBase
                    rts
* DrawViewPartsLines: type 1 = set of lines: sets the line color
DrawViewPartsLines               deca
                    bne       DrawViewPartsDone
                    lda       ,x+
                    pshs      x
                    jsr       >SetLineColor+ModBase
                    puls      x
* DrawViewPartsLineLoop: draws one line per point pair until $FFFF
DrawViewPartsLineLoop               ldy       ,x++
                    cmpy      #ShapeEnd
                    beq       DrawViewPartsDone
                    ldd       ,x++
                    pshs      x
                    tfr       y,x
                    ldy       >vViewScr
                    jsr       >DrawLine+ModBase
                    puls      x
                    bra       DrawViewPartsLineLoop
* DrawViewPartsDone: return (type $FF or end)
DrawViewPartsDone               rts
* MsgPaused: screen text "PAUSED." (position bytes $14,$32, zero-terminated)
MsgPaused               fcb       $14
                    fcc       /2PAUSED./
                    fcb       $00
* ShowPausedMsg: clears a box in the view and prints "PAUSED."
ShowPausedMsg               lda       #ColorClear
                    jsr       >SetFillColor+ModBase
                    ldd       #PausedTopLeft
                    ldx       #PausedBotRight
                    ldy       >FsScreen
                    jsr       >FillRect+ModBase
                    ldd       #TxtWhite
                    std       >vTextColor
                    ldu       >FsScreen
                    ldx       #MsgPaused+ModBase
* WildBits: the message drawn and shown at once (fsw)
                    jmp       >FswPause
* PollKey: if a key is waiting on stdin ($0CD5) reads it to $009A and returns it in B; returns A=0/Z when none
PollKey               lda       >FsKeyPath
                    ldb       #SsReady
                    os9       I$GetStt
                    bhs       PollKeyRead
                    clra
                    rts
* PollKeyRead: reads one key byte
PollKeyRead               lda       >FsKeyPath
                    ldy       #KeyReadLen
                    ldx       #vKeyByte
                    os9       I$Read
                    jmp       >FswKeyMap          WildBits: the K2's F1/F2 codes
                    nop
* ReadJoysticks: joystick control (if $088D set, $0304 clear): right stick x = ailerons $0812, y = elevator $081A, button; left stick ($088D=2) y = $0837 (probably throttle), button
ReadJoysticks               lda       >vSlew
                    bne       ReadJoysticksDone
                    lda       >vJoyMode
                    bne       ReadJoyRight
* ReadJoysticksDone: return
ReadJoysticksDone               rts
* ReadJoyRight: reads the right joystick with SS.Joy
ReadJoyRight               lda       >FsKeyPath
                    jsr       >WbJoy+ModBase       WildBits: the mouse
                    nop
                    nop
                    nop
                    nop
                    nop
                    tsta
                    beq       ReadJoyRightX
                    jsr       >JoyButtonAction+ModBase
* ReadJoyRightX: center dead band on x; update ailerons when x moved by more than 1
ReadJoyRightX               tfr       x,d
                    cmpb      #JoyXBelowMid
                    bhi       ReadJoyRightXHi
                    incb
* ReadJoyRightXHi: upper half of the dead band adjustment
ReadJoyRightXHi               cmpb      #JoyXAboveMid
                    blo       ReadJoyRightXCmp
                    decb
* ReadJoyRightXCmp: compares x with the last value $088F
ReadJoyRightXCmp               tfr       b,a
                    suba      >vStickX
                    inca
                    cmpa      #JoyXJitter
                    bls       ReadJoyRightY
                    stb       >vStickX
                    aslb
                    aslb
                    tfr       b,a
                    clrb
                    subd      #AileronBias
                    std       >vAileron
                    pshs      y
                    jsr       >ShowAileronPos+ModBase
                    puls      y
* ReadJoyRightY: y changed: sets elevator $081A and updates its indicator
ReadJoyRightY               cmpy      >vStickY
                    beq       ReadJoyChkLeft
                    sty       >vStickY
                    tfr       y,d
                    eorb      #JoyMax
                    aslb
                    aslb
                    lda       #ElevatorJoyScale
                    mul
                    subd      #ElevatorLimit
                    std       >vElevator
                    jsr       >ShowElevatorPos+ModBase
* ReadJoyChkLeft: checks whether the left joystick is used ($088D = 2)
ReadJoyChkLeft               lda       >vJoyMode
                    cmpa      #JoyBothSticks
                    beq       ReadJoyLeft
                    bne       ReadJoyDone
* ReadJoyLeft: reads the left joystick with SS.Joy
ReadJoyLeft               lda       >FsKeyPath
                    clra                          WildBits: the left stick stays still
                    ldy       >vStickYL
                    nop
                    nop
                    nop
                    tsta
                    beq       ReadJoyLeftY
                    jsr       >JoyButtonAction+ModBase
* ReadJoyLeftY: y changed: sets $0837 (probably throttle) and updates its indicator
ReadJoyLeftY               cmpy      >vStickYL
                    beq       ReadJoyDone
                    sty       >vStickYL
                    tfr       y,d
                    aslb
                    aslb
                    lda       #ThrottleJoyScale
                    mul
                    std       >vThrottle
                    jsr       >ShowThrottlePos+ModBase
* ReadJoyDone: return
ReadJoyDone               rts
* TblKeyDispatch: 128 handler addresses (+ModBase) indexed by key code 0-$7F, used by DispatchKey
TblKeyDispatch               fcb       $A8,$AC,$AE,$30,$AB,$C5,$AD,$FF
                    fcb       $AB,$CF,$A8,$AC
* WildBits (Roger 2026-10-24): Ctrl+F alternates the fuel tanks itself (fsw); FS's selected the tank for , and .
                    fdb       FswFuelKey
                    fcb       $A8,$AC
                    fcb       $AC,$32,$AC,$0E,$A8,$AC,$A8,$AC
                    fcb       $AB,$DE,$AD,$F5,$AE,$18,$A8,$AC
                    fcb       $A8,$AC,$A8,$AC,$A8,$AC,$A8,$D0
                    fcb       $AE,$4B,$A8,$AC,$AE,$46,$A8,$AC
                    fcb       $AE,$4B,$A8,$AC,$A8,$AC,$A8,$AC
                    fcb       $A8,$AC,$A8,$AC,$A8,$AC,$A8,$AC
                    fcb       $AB,$E4,$A8,$AC,$A8,$AC,$A8,$AC
                    fcb       $A8,$AC,$A8,$AC,$A8,$AC,$A8,$AC
                    fcb       $A9,$5C,$A9,$60,$A8,$AC,$A8,$AC
                    fcb       $A9,$64,$A8,$AC,$AA,$8A,$AC,$08
                    fcb       $A8,$AC,$A8,$D8,$A8,$F9,$A9,$1A
                    fcb       $A9,$31,$A9,$46,$A8,$AC,$A8,$AC
                    fcb       $A9,$5C,$A9,$60,$A8,$AC,$A8,$AC
                    fcb       $A8,$AC,$A8,$AC,$A8,$AC,$A8,$AC
                    fcb       $A8,$AC
                    fcb       $A8,$AC
                    fcb       $AD,$A8,$AD,$64
* WildBits: D, E, the GPU's dither, the line ribbons on/off (fsw)
                    fdb       FswGfxKey,FswGfxKey
                    fcb       $AC,$DC,$AC,$F1
                    fcb       $AD,$2D
* WildBits: I, the GPU view 320 x 256 colors <-> 640 x 16 (fsw)
                    fdb       FswViewKey
* WildBits (taxi mode, 2026-10-19): J, K, L: the left, both, the right brakes (fsw)
                    fdb       FswBrakeL,FswBrakeB,FswBrakeR
                    fcb       $AD,$6E,$AD,$D0,$A8,$AC
                    fcb       $AD,$EC,$E8,$FC,$AC,$5C
* WildBits: S, the spot view (fsw)
                    fdb       FswSpotKey
                    fcb       $AC,$82,$A8,$AC,$AD,$96,$AE,$81
                    fcb       $AE,$8A,$AC,$BE,$AE,$90,$A8,$AC
                    fcb       $A8,$AC,$A8,$AC,$A8,$AC,$A8,$C5
                    fcb       $A8,$AC
                    fcb       $A8,$AC
                    fcb       $AD,$A8,$AD,$64
* WildBits: d, e, the GPU's dither, the line ribbons on/off (fsw)
                    fdb       FswGfxKey,FswGfxKey
                    fcb       $AC,$DC,$AC,$F1
                    fcb       $AD,$2D
* WildBits: I, the GPU view 320 x 256 colors <-> 640 x 16 (fsw)
                    fdb       FswViewKey
* WildBits (taxi mode, 2026-10-19): J, K, L: the left, both, the right brakes (fsw)
                    fdb       FswBrakeL,FswBrakeB,FswBrakeR
                    fcb       $AD,$6E,$AD,$D0,$A8,$AC
                    fcb       $AD,$EC,$E8,$FC,$AC,$5C
* WildBits: s, the spot view (fsw)
                    fdb       FswSpotKey
                    fcb       $AC,$82,$A8,$AC,$AD,$96,$AE,$81
                    fcb       $AE,$8A,$AC,$BE,$AC,$4D,$A8,$AC
                    fcb       $A8,$AC,$A8,$AC,$A8,$AC,$A8,$AC
* DispatchKey: B = key: codes below $80 jump through TblKeyDispatch; $B1-$B8 request overlays, $90 quits
DispatchKey               aslb
                    blo       DispatchKeyHigh
                    ldx       #TblKeyDispatch+ModBase
                    abx
                    jmp       [,x]
* DispatchKeyHigh: key with bit 7 set: function/overlay keys and quit
DispatchKeyHigh               rorb
                    cmpb      #KeyF1
                    lbeq      DispatchKeyOverlay1
                    cmpb      #KeyF2
                    lbeq      DispatchKeyOverlay2
                    cmpb      #KeyOvlFirst
                    blo       DispatchKeyChkQuit
                    cmpb      #KeyOvlEnd
                    lblo      DispatchKeyOverlay
* DispatchKeyChkQuit: key $90 jumps to QuitProgram
DispatchKeyChkQuit               cmpb      #KeyQuit
                    bne       DispatchKeyIgnore
                    jmp       >QuitProgram+ModBase
* DispatchKeyIgnore: unhandled key: return
DispatchKeyIgnore               aslb
                    asrb
                    rts
* DispatchKeyOverlay: keys $B5-$B8: request overlay 4-7 ($0221)
DispatchKeyOverlay               subb      #KeyOvlBase
                    stb       >vOvlReq
                    rts
* DispatchKeyOverlay1: key $B1: request overlay 1
DispatchKeyOverlay1               lda       #OvlF2
                    sta       >vOvlReq
                    rts
* DispatchKeyOverlay2: key $B2: request overlay 2 unless $0307 (probably WWI mode) is set
DispatchKeyOverlay2               lda       >vEurope1917
                    bne       DispatchKeyOvl2Done
                    lda       #OvlF3
                    sta       >vOvlReq
* DispatchKeyOvl2Done: return
DispatchKeyOvl2Done               rts
                    fcb       $86,$01,$B7,$02,$0C,$86,$01,$B7
                    fcb       $02,$21,$39,$86,$02,$F6,$03,$07
                    fcb       $27,$F0,$39,$C6,$01,$96,$EA,$81
                    fcb       $03,$26,$05,$CC,$00,$00,$20,$3A
                    fcb       $81,$06,$27,$04,$81,$07,$26,$04
                    fcb       $F7,$08,$26,$39,$81,$0C,$26,$03
                    fcb       $F7,$08,$3A,$39,$C6,$02,$96,$EA
* WildBits (2026-10-21 #21): the magnetos come on and off together - Enter then 2 (R) and 3 (L) both set magnetos
* 1 and 2 ($0DCB/$0DCC, D = $0203 / $0103), as 4 (BOTH) does; only 1 (OFF) clears them (the original set one each)
                    fcb       $81,$03,$26,$05,$CC,$02,$03,$20
                    fcb       $19,$81,$06,$27,$04,$81,$07,$26
                    fcb       $04,$F7,$08,$26,$39,$81,$0C,$26
                    fcb       $03,$F7,$08,$3A,$39,$CC,$01,$03
                    fcb       $20,$00,$0F,$EA,$54,$F7,$0D,$CC
                    fcb       $59,$C4,$01,$F7,$0D,$CB
* SetMagnetoSwitch: A = magneto switch position (0 off .. 3 both, 4 start) into $0825, then redraws the switch status line (DrawEngineSwitches)
SetMagnetoSwitch               sta       >vMagSw
                    jmp       >DrawEngineSwitches+ModBase
                    fcb       $96,$EA,$81,$03,$26,$06,$CC,$03
                    fcb       $03,$7E,$A9,$1F,$C6,$02,$D7,$EA
                    fcb       $5A,$F7,$01,$39,$39,$96,$EA,$81
                    fcb       $03,$26,$06,$CC,$04,$03,$7E,$A9
                    fcb       $1F,$C6,$01,$B6,$01,$39,$26,$E8
                    fcb       $D7,$EA,$39,$7A,$08
                    fcc       /19|/
                    fcb       $08,$31,$39,$B6,$03,$48,$27,$1F
                    fcb       $96,$EA,$81,$0D,$25,$19,$81,$0F
                    fcb       $22,$15,$80,$0D,$1F,$89,$8E,$09
                    fcb       $C4,$A6,$85,$81,$30,$26,$02,$86
                    fcb       $3A,$4A,$A7,$85,$7E,$B6,$83,$96
                    fcb       $EA,$7F,$02,$89,$F6,$03,$07,$26
                    fcb       $04,$80,$02,$26,$1B,$81,$10,$26
                    fcb       $05,$C6,$04,$7E,$AA,$7A,$1A,$01
                    fcb       $79,$01,$8C,$79,$01,$8B,$F6,$01
                    fcb       $8A,$59,$C4,$7F,$F7,$01,$8A,$39
                    fcb       $80,$02,$26,$19,$FC,$09,$CB,$10
                    fcb       $83
                    fcc       /18&/
                    fcb       $05,$CC
                    fcc       /35 /
                    fcb       $08,$5A,$C1,$2F,$26,$03,$C6
                    fcs       /9J~*/
                    fcb       $F1,$4A,$26,$08,$FC,$09,$CD,$8D
                    fcb       $37,$7E,$AB,$00,$4A,$26,$17,$F6
                    fcb       $08,$26,$C1,$02,$27,$08,$FC,$09
                    fcb       $D3,$8D,$37,$7E,$AB,$16,$FC,$09
                    fcb       $DB,$8D,$2F,$7E,$AB
                    fcs       /"J&<v/
                    fcb       $08,$26,$C1,$02,$27,$08,$FC,$09
                    fcb       $D5,$8D,$0B,$7E,$AB,$37,$FC,$09
* WildBits (2026-10-21, Roger): the radios' kHz digits step by 0.01 (were 0.05): down at $AA0D (decb, a borrow
* into the tenths, 9 under 0), the same 18 bytes, nops after
                    fcb       $DD,$8D,$03,$7E,$AB,$42,$5A,$C1
                    fcb       $2F,$26,$09,$C6,$39,$4A,$81,$2F
                    fcb       $26,$02,$86,$39
                    fcb       $39,$12,$12,$12
                    fcb       $10,$83
                    fcc       /08&/
                    fcb       $04,$CC
                    fcs       /179ZA/
                    fcb       $2F,$26,$03,$CC
                    fcc       /099J/
                    fcb       $81,$03,$22,$13,$1F,$89,$8E,$09
                    fcb       $FA,$A6,$85,$81,$30,$26,$02,$86
                    fcb       $38,$4A,$A7,$85,$7E,$B6,$E7,$80
                    fcb       $03
                    fcs       /J&+6/
                    fcb       $08,$3A,$81,$02,$27,$12,$7A,$09
                    fcb       $A8,$B6,$09,$A8,$81,$FF,$26,$05
                    fcb       $86,$B3,$B7,$09,$A8,$7E,$B5,$5D
                    fcb       $7A,$09,$A9,$B6,$09,$A9,$81,$FF
                    fcb       $26,$05,$86,$B3,$B7,$09,$A9,$7E
* WildBits (Roger 2026-10-24): , no longer selects the left tank (Ctrl+F alternates them): bne -> bra over it
                    fcb       $B5,$85,$81,$04,$20,$0B,$B6,$07
                    fcb       $35,$27,$06,$7A,$07,$35,$7E,$BB
                    fcb       $49,$39,$F6,$03,$48,$27,$1D,$D6
                    fcb       $EA,$C1,$0D,$25,$17,$C1,$0F,$22
                    fcb       $13,$C0,$0D,$8E,$09,$C4,$A6,$85
                    fcb       $81,$39,$26,$02,$86,$2F,$4C,$A7
                    fcb       $85,$7E,$B6,$83,$96,$EA,$7F,$02
                    fcb       $89,$F6,$03,$07,$26,$04,$80,$02
                    fcb       $26,$1D,$81,$10,$26,$05,$C6,$04
                    fcb       $7E,$AB,$8E,$1C,$FE,$76,$01,$8A
                    fcb       $76,$01,$8B,$76,$01,$8C,$86,$1F
                    fcb       $BA,$01,$8C,$B7,$01,$8C,$39,$80
                    fcb       $02,$26,$1C,$FC,$09,$CB,$10,$83
                    fcc       /35&/
                    fcb       $05,$CC
                    fcc       /18 /
                    fcb       $08,$5C,$C1,$3A,$26,$03,$C6,$30
                    fcb       $4C,$FD,$09,$CB,$7E,$B5
                    fcc       />J&/
                    fcb       $0C,$FC,$09,$CD,$BD,$AB,$9E,$FD
                    fcb       $09,$CD,$7E,$B5
                    fcc       />J&/
                    fcb       $1F,$B6,$08,$26,$81,$02,$27,$0C
                    fcb       $FC,$09,$D3,$BD,$AB,$B2,$FD,$09
                    fcb       $D3,$7E,$B4,$FB,$FC,$09,$DB,$BD
                    fcb       $AB,$B2,$FD,$09,$DB,$7E,$B5,$15
                    fcb       $4A,$26,$1D,$B6,$08,$26,$81,$02
                    fcb       $27,$0B,$FC,$09,$D5,$8D,$67,$FD
                    fcb       $09,$D5,$7E,$B4,$FB,$FC,$09,$DD
                    fcb       $8D,$5C,$FD,$09,$DD,$7E,$B5,$15
                    fcb       $4A,$81,$03,$22,$13,$1F,$89,$8E
                    fcb       $09,$FA,$A6,$85,$81,$37,$26,$02
                    fcb       $86,$2F,$4C,$A7,$85,$7E,$B6,$E7
                    fcb       $80,$03
                    fcs       /J&)6/
                    fcb       $08,$3A,$81,$02,$27,$11,$7C,$09
                    fcb       $A8,$B6,$09,$A8,$81,$B4,$26,$04
                    fcb       $4F,$B7,$09,$A8,$7E,$B5,$5D,$7C
                    fcb       $09,$A9,$B6,$09,$A9,$81,$B4,$26
                    fcb       $04,$4F,$B7,$09,$A9,$7E,$B5,$85
* WildBits (Roger 2026-10-24): . no longer selects the right tank (Ctrl+F alternates them): bne -> bra over it
                    fcb       $81,$04,$20,$0B,$B6,$07,$35,$26
                    fcb       $06,$7C,$07,$35,$7E,$BB,$49,$39
* WildBits (2026-10-21): kHz up by 0.01 at $AB9E (incb, a carry into the tenths, 0 past 9), the same 20 bytes
                    fcb       $5C,$C1,$3A,$26,$09,$C6,$30,$4C
                    fcb       $81,$3A,$26,$02,$86,$30,$39,$12
                    fcb       $12
                    fcb       $12,$12,$12
                    fcb       $10,$83
                    fcc       /17&/
                    fcb       $04,$CC
                    fcs       /089\A/
                    fcb       $3A,$26,$03,$CC
                    fcs       /109L/
                    fcb       $00,$00,$FD,$07,$3D,$FD,$07,$3F
                    fcb       $39,$FC,$02,$16,$93,$16,$F3,$01
                    fcb       $4A,$F3,$01,$48,$FD,$02,$10,$39
                    fcb       $73,$08,$24,$7E,$B6,$52
* JoyButtonAction: joystick button: on the ground ($0781) decrements $07BB (probably brakes); in WWI mode ($0307) with $0814 set fires guns ($0821/$08A9)
JoyButtonAction               lda       >vOnGnd
                    beq       JoyButtonAirborne
                    dec       >vAirspeed
                    bpl       JoyButtonDone
                    ldd       #AirspeedZero
                    std       >vAirspeed
* JoyButtonDone: return
JoyButtonDone               rts
* JoyButtonAirborne: not on the ground: fire if $0307 and $0814 are set
JoyButtonAirborne               lda       >vEurope1917
                    beq       JoyButtonDone
                    ldd       >vAmmo
                    beq       JoyButtonDone
                    lda       #GunBurstRounds
                    sta       >vGunBurst
                    sta       >vGunFired
                    rts
                    fcb       $86,$01,$B7,$02,$2C,$39,$B6,$0C
                    fcb       $D5,$C6,$27,$10,$3F,$8D,$84,$02
                    fcb       $27,$06,$73,$08,$18,$7E,$B6,$52
                    fcb       $7C,$08,$33,$86,$78,$74,$02,$2C
                    fcb       $25,$18,$B6,$08,$37,$8B,$08,$2A
                    fcb       $11,$39,$7A,$08
                    fcc       /3Ot/
                    fcb       $02,$2C,$25,$07,$B6,$08,$37,$80
                    fcb       $08,$2B,$EF,$B7,$08,$37
* ShowThrottlePos: updates the indicator for $0837 (probably throttle) via MoveThrottleMarker
ShowThrottlePos               lda       >vThrottle
                    lsra
                    lsra
                    jmp       >MoveThrottleMarker+ModBase
                    fcb       $B6,$03,$04,$27,$09,$CC,$00,$00
                    fcb       $DD,$12,$DD,$14,$DD,$16,$39,$86
                    fcb       $0E,$17,$02,$37,$86,$01,$B7,$02
                    fcb       $2F,$7C,$08,$2D,$B6,$08,$1C,$80
                    fcb       $04,$81,$AC,$27,$03,$B7,$08,$1C
                    fcb       $86,$50,$B0,$08,$1C
                    fcs       /DDDD=/
                    fcb       $BA,$8C,$39,$4F,$17,$02,$12,$B6
* WildBits (2026-10-20): key T, the elevator down: 8 a tap ($80,$08 suba #8; was 4), and no 16 for a tap within 0.6 s
* of the last ($20 bra over the suba #12, was $27 beq): every tap the same step
                    fcb       $08,$1A,$80,$08,$F6,$03,$04,$26
                    fcb       $07,$F6,$02,$89,$20,$02,$80,$0C
                    fcb       $B7,$08,$1A,$2A,$06,$81,$B0,$2C
                    fcb       $02,$86,$B0,$B7,$08,$1A,$86,$03
                    fcb       $B7,$02,$89
* ShowElevatorPos: updates the elevator position indicator from $081A when its 8-step value changes ($0D1B)
ShowElevatorPos               lda       #ElevatorLimitHi
                    suba      >vElevator
                    lsra
                    lsra
                    lsra
                    cmpa      >vElevatorStep
                    beq       ShowElevatorPosDone
                    sta       >vElevatorStep
                    jsr       >UpdElevatorMarker+ModBase
* ShowElevatorPosDone: return
ShowElevatorPosDone               rts
                    fcb       $86,$02,$17,$01,$D5,$7A,$08,$2D
                    fcb       $B6,$08,$1E,$80,$20,$2A,$01,$4F
                    fcb       $B7,$08,$1E
                    fcs       /DDDD=/
                    fcb       $BA,$B4,$BD,$F2,$86,$39,$86,$0C
                    fcb       $17,$01,$B7,$B6,$08,$12,$80,$04
                    fcb       $81,$80,$10,$27,$FF,$D1,$B7,$08
                    fcb       $12,$20,$4D
* WildBits (Roger 2026-10-21): the 5G view (the view pitched 90 degrees, $0839 bit 7) removed: after a 5, G
* only drops the pending direction (in place of lda #$FF / lbsr SetViewDir); G's own work follows as before
                    clr       <vKeySelItem
                    nop
                    nop
                    nop
                    fcb       $4F,$F6,$03,$04,$27,$13,$B7,$08
                    fcb       $1A,$BD,$AC,$AA,$4F,$B7,$08,$31
                    fcb       $B7,$08,$2D,$B7,$08,$2F,$B7,$08
                    fcb       $33,$B7,$08,$12,$B7,$08,$2B,$B6
                    fcb       $03,$47,$44,$BB,$07,$6B,$B1,$03
                    fcb       $47,$25,$06,$FC,$07,$6B,$FD,$08
                    fcb       $99,$8D,$15,$16,$00,$4C,$39,$86
                    fcb       $04,$BD,$AE,$98,$B6,$08,$12,$8B
                    fcb       $04,$10,$29,$00,$28,$B7,$08,$12
* ShowAileronPos: ailerons changed: with $0303 (probably auto-coordination) copies them to the rudder $082B; updates the aileron indicator ($0D1C) and ComputeYawTerm
ShowAileronPos               lda       >vAutoCoord
                    beq       ShowAileronPosGauge
                    ldd       >vAileron
                    std       >vRudder
                    jsr       >ShowRudderPos+ModBase
* ShowAileronPosGauge: updates the aileron indicator when its 16-step value changes
ShowAileronPosGauge               lda       >vAileron
                    adda      #CtlBias
                    lsra
                    lsra
                    lsra
                    lsra
                    cmpa      >vAileronStep
                    beq       ShowAileronPosDone
                    sta       >vAileronStep
                    jsr       >UpdAileronMarker+ModBase
* ShowAileronPosDone: calls ComputeYawTerm and returns
ShowAileronPosDone               jsr       >ComputeYawTerm+ModBase
                    rts
                    fcb       $B6,$08,$2B,$80,$04,$81,$80,$26
                    fcb       $08,$39,$B6,$08,$2B,$8B,$04,$29
                    fcb       $20,$B7,$08,$2B,$B6,$03,$03,$27
                    fcb       $09,$FC,$08,$2B,$FD,$08,$12,$BD
                    fcb       $AD,$4C
* ShowRudderPos: updates the rudder position indicator from $082B (UpdRudderMarker) and UpdatePitchCtlTerms
ShowRudderPos               lda       >vRudder
                    adda      #CtlBias
                    lsra
                    lsra
                    lsra
                    lsra
                    jsr       >UpdRudderMarker+ModBase
                    jsr       >UpdatePitchCtlTerms+ModBase
                    rts
                    fcb       $86,$0A,$17,$00,$FD,$7C,$08,$2F
                    fcb       $B6,$08,$1C,$8B,$04,$81,$54,$16
                    fcb       $FE,$C8,$86,$08,$17,$00,$EB,$B6
* WildBits (2026-10-20): key B, the elevator up: 8 a tap ($8B,$08 adda #8; was 4), and no 16 for a tap within 0.6 s of
* the last ($20 bra over the adda #12, was $27 beq): every tap the same step
                    fcb       $08,$1A,$8B,$08,$F6,$03,$04,$26
                    fcb       $07,$F6,$02,$89,$20,$02,$8B,$0C
                    fcb       $B7,$08,$1A,$10,$2B,$FE,$DD,$81
                    fcb       $50,$10,$25,$FE,$D7,$86,$50,$16
                    fcb       $FE,$D2,$86,$06,$17,$00,$C3,$7A
                    fcb       $08,$2F,$B6,$03,$04,$26,$0E,$B6
                    fcb       $08,$1E,$8B,$20,$10,$2A,$FE,$E8
                    fcb       $86,$60,$16,$FE,$E3,$39,$B6,$02
                    fcb       $23,$88,$FF,$B7,$02,$23,$39,$86
                    fcb       $03,$97,$EA,$39,$86,$10,$97,$EA
                    fcb       $39,$B6,$02,$89,$27,$09,$96,$EA
                    fcb       $81,$04,$26,$03,$0C,$EA,$39,$81
                    fcb       $05,$26,$03,$7C,$02,$A3,$86,$04
                    fcb       $20,$10,$B6,$02,$89,$27,$09,$96
                    fcb       $EA,$81,$06,$26,$03,$0C,$EA,$39
                    fcb       $86,$06,$97,$EA,$86,$14,$B7,$02
                    fcb       $89,$39,$B6,$02,$89,$27,$0D,$96
                    fcb       $EA,$81,$0D,$25,$07,$81,$0F,$22
                    fcb       $03,$4C,$20,$E6,$86,$0D,$20,$E2
                    fcb       $86,$0C,$97,$EA,$39,$B6,$03,$04
                    fcb       $27,$1A,$DC,$12,$43,$53,$C3,$00
                    fcb       $01,$FD,$07,$4D,$DC,$14,$43,$53
                    fcb       $C3,$00,$01,$FD,$07,$4F,$DC,$16
                    fcb       $FD,$07,$82,$39,$B6,$02,$89,$27
                    fcb       $0E,$96,$EA,$81,$08,$25,$08,$81
                    fcb       $0B,$22,$04,$4C,$16,$FF,$AB,$86
                    fcb       $08,$20,$A7,$86,$01,$BA,$08,$3B
                    fcb       $B7,$08,$3B,$39,$86,$01,$B7,$12
                    fcs       /-9s./
                    fcb       $A6,$39,$7F,$02,$89,$39,$D6,$EA
                    fcb       $C1,$01,$26,$07,$0F,$EA,$B7,$08
                    fcc       /92b9/
                    fcb       $FF
* (StartupStub, gone: fs_wb's WbStart replaced it)
                    zmb       1
* TblColorPattern: 16 color fill words $0000,$1111..$FFFF (4 bits per pixel, color replicated in each nibble)
TblColorPattern               fcb       $00,$00,$11,$11
                    fcc       /""33DDUUffww/
                    fcb       $88,$88,$99,$99,$AA,$AA,$BB,$BB
                    fcb       $CC,$CC,$DD,$DD,$EE,$EE,$FF,$FF
* SetLineColor: A = color 0-15: sets the line color pattern <$EE
SetLineColor               ldy       #TblColorPattern+ModBase
                    anda      #ColorNibble
                    asla
                    ldd       a,y
                    std       <vLineColPat
                    rts
                    fcb       $B6,$01,$79
* SetFillColor: A = color 0-15: sets the fill pattern word $0178 and the left/right pixel nibbles <$F0/<$F1
SetFillColor               ldy       #TblColorPattern+ModBase
                    anda      #ColorNibble
                    asla
                    ldd       a,y
                    std       >vFillPat
                    anda      #PixEvenNib
                    sta       <vFillLeftNib
                    andb      #PixOddNib
                    stb       <vFillRightNib
                    rts
* DivFrac8: unsigned divide (A*256)/B, quotient and remainder in <$E4-<$E9; returns D = 8.8 quotient (line slope)
* WildBits: on the math block's divider in place of FS's 16-step loop (exact: quotient and remainder as the loop
* left them); the divisor is still <$E6:<$E7, and 0 gives the loop's answer, $FFFF with the dividend as the
* remainder. X is no longer counted down to 0 (neither caller reads it).
DivFrac8               stb       <vDivFracSor+1
                    clrb
                    std       <vDivFracQuot
                    std       >MATH_DIV_END
                    ldd       <vDivFracSor
                    beq       DivFrac8Zero
                    std       >MATH_DIV_SOR
                    nop                           the divider's 12 clocks
                    nop
                    nop
                    nop
                    nop
                    nop
                    ldd       >MATH_DIV_REM
                    std       <vDivFracRem
                    ldd       >MATH_DIV_QUOT
                    std       <vDivFracQuot
                    rts
* DivFrac8Zero: divide by zero (D = 0): all quotient bits set, the dividend left as the remainder
DivFrac8Zero               ldx       <vDivFracQuot
                    stx       <vDivFracRem
                    coma
                    comb
                    std       <vDivFracQuot
                    rts
* PlotPixel: A = x, B = row, Y = the base: one pixel in the line color <$EE
PlotPixel           equ       *
                    jmp       >FswPlot            WildBits: view pixels to the line engine too
                    fcb       $15
                    fcs       /8X:l/
                    fcb       $84,$30,$AB,$35,$02,$44,$25,$0F
                    fcb       $E6,$86,$C4,$0F,$E7,$86,$D6,$EE
                    fcb       $C4,$F0,$EA,$86,$E7,$86,$39,$E6
                    fcb       $86,$C4,$F0,$E7,$86,$D6,$EE,$C4
                    fcb       $0F,$EA,$86,$E7,$86,$39
* DrawLine: draws a line in color <$EE between X=(x1,y1) and D=(x2,y2) into the 160-pixel-wide 4bpp buffer at Y (row addresses from table $1538)
DrawLine               equ       *
                    jmp       >FswLine            WildBits: view lines to the line engine too
                    nop
                    bhs       DrawLineSorted
                    exg       d,x
                    stx       <vLineLeftX
* DrawLineSorted: endpoints ordered left to right; same row goes to DrawLineHoriz
DrawLineSorted               cmpb      <vLineLeftRow
                    lbeq      DrawLineHoriz
                    pshs      a,b
                    tfr       x,d
                    ldx       #vRowAddrTbl
                    aslb
                    abx
                    ldd       ,x
                    leax      d,y
                    ldb       <vLineLeftX
                    lda       #PixOddNib
                    lsrb
                    abx
                    bhs       DrawLineSetMask
                    lda       #PixEvenNib
* DrawLineSetMask: sets the pixel nibble mask <$7D and color byte <$7E
DrawLineSetMask               sta       <vLineKeep
                    coma
                    anda      <vLineColPat
                    sta       <vLineColor
                    puls      a,b
                    suba      <vLineLeftX
                    lbeq      DrawLineVert
                    sta       <vLineDX
                    subb      <vLineLeftRow
                    stb       <vLineDY
                    lbmi      DrawLineUp
                    cmpa      <vLineDY
                    lblo      DrawLineSteepDn
                    sta       <vLinePixCount
                    inc       <vLinePixCount
                    tfr       a,b
                    lsrb
                    negb
* DrawLineShallowDn: plots a mostly horizontal line going down (Bresenham)
DrawLineShallowDn               lda       ,x
                    anda      <vLineKeep
                    ora       <vLineColor
                    sta       ,x
                    dec       <vLinePixCount
                    lbeq      DrawLineDone
                    lda       <vLineKeep
                    anda      <vLineColPat
                    sta       <vLineColor
                    lda       <vLineKeep
                    coma
                    bmi       DrawLineShallowDnStep
                    leax      1,x
* DrawLineShallowDnStep: next pixel position for the shallow downward line
DrawLineShallowDnStep               sta       <vLineKeep
                    addb      <vLineDY
                    lbhs      DrawLineShallowDn
                    leax      <FsRowBytes,x
                    subb      <vLineDX
                    jmp       >DrawLineShallowDn+ModBase
* DrawLineSteepDn: sets up a mostly vertical line going down
DrawLineSteepDn               stb       <vLinePixCount
                    negb
                    asrb
* DrawLineSteepDnLoop: plots the mostly vertical downward line
DrawLineSteepDnLoop               lda       ,x
                    anda      <vLineKeep
                    ora       <vLineColor
                    sta       ,x
                    dec       <vLinePixCount
                    lbmi      DrawLineDone
                    leax      <FsRowBytes,x
                    addb      <vLineDX
                    lbmi      DrawLineSteepDnLoop
                    lda       <vLineKeep
                    anda      <vLineColPat
                    sta       <vLineColor
                    lda       <vLineKeep
                    coma
                    bmi       DrawLineSteepDnStep
                    leax      1,x
* DrawLineSteepDnStep: steps one pixel right on the steep downward line
DrawLineSteepDnStep               sta       <vLineKeep
                    subb      <vLineDY
                    jmp       >DrawLineSteepDnLoop+ModBase
* DrawLineUp: line going up: choose steep or shallow
DrawLineUp               negb
                    cmpb      <vLineDX
                    lbls      DrawLineShallowUp
                    stb       <vLinePixCount
                    negb
                    asrb
* DrawLineSteepUpLoop: plots the mostly vertical upward line
DrawLineSteepUpLoop               lda       ,x
                    anda      <vLineKeep
                    ora       <vLineColor
                    sta       ,x
                    dec       <vLinePixCount
                    lbmi      DrawLineDone
                    leax      <-FsRowBytes,x
                    addb      <vLineDX
                    lbmi      DrawLineSteepUpLoop
                    lda       <vLineKeep
                    anda      <vLineColPat
                    sta       <vLineColor
                    lda       <vLineKeep
                    coma
                    bmi       DrawLineSteepUpStep
                    leax      1,x
* DrawLineSteepUpStep: steps one pixel right on the steep upward line
DrawLineSteepUpStep               sta       <vLineKeep
                    addb      <vLineDY
                    jmp       >DrawLineSteepUpLoop+ModBase
* DrawLineShallowUp: sets up a mostly horizontal line going up
DrawLineShallowUp               sta       <vLinePixCount
                    inc       <vLinePixCount
                    tfr       a,b
                    lsrb
                    negb
* DrawLineShallowUpLoop: plots the mostly horizontal upward line
DrawLineShallowUpLoop               lda       ,x
                    anda      <vLineKeep
                    ora       <vLineColor
                    sta       ,x
                    dec       <vLinePixCount
                    lbeq      DrawLineDone
                    lda       <vLineKeep
                    anda      <vLineColPat
                    sta       <vLineColor
                    lda       <vLineKeep
                    coma
                    bmi       DrawLineShallowUpStep
                    leax      1,x
* DrawLineShallowUpStep: next pixel position for the shallow upward line
DrawLineShallowUpStep               sta       <vLineKeep
                    subb      <vLineDY
                    lblo      DrawLineShallowUpLoop
                    leax      <-FsRowBytes,x
                    subb      <vLineDX
                    jmp       >DrawLineShallowUpLoop+ModBase
* DrawLineDone: return
DrawLineDone               rts
* DrawLineHoriz: horizontal line: uses DrawHLine with the line color, then restores the fill color
DrawLineHoriz               pshs      a
                    ldx       #vRowAddrTbl
                    aslb
                    abx
                    ldd       ,x
                    leax      d,y
                    lda       >vFillPat
                    sta       <vFillColorSave
                    lda       <vLineColPat
                    jsr       >SetFillColor+ModBase
                    puls      a
                    ldb       <vLineLeftX
                    jsr       >DrawHLine+ModBase
                    lda       <vFillColorSave
                    jmp       >SetFillColor+ModBase
* DrawLineVert: vertical line (same x)
DrawLineVert               subb      <vLineLeftRow
                    blo       DrawLineVertUp
* DrawLineVertDnLoop: plots a vertical line downward
DrawLineVertDnLoop               lda       ,x
                    anda      <vLineKeep
                    ora       <vLineColor
                    sta       ,x
                    decb
                    lbmi      DrawLineDone
                    leax      <FsRowBytes,x
                    bra       DrawLineVertDnLoop
* DrawLineVertUp: vertical line upward
DrawLineVertUp               decb
* DrawLineVertUpLoop: plots a vertical line upward
DrawLineVertUpLoop               lda       ,x
                    anda      <vLineKeep
                    ora       <vLineColor
                    sta       ,x
                    incb
                    lbeq      DrawLineDone
                    leax      <-FsRowBytes,x
                    bra       DrawLineVertUpLoop
* FillRowFull: fills the whole 80-byte row at X with the fill pattern
FillRowFull               leau      <FsRowBytes,x
* FillRow80: fills the 80 bytes below U with the fill pattern $0178 using stack pushes (interrupts masked)
FillRow80               equ       *
                    jmp       >FswRow80           WildBits: view rows to the line engine too
                    nop
                    orcc      #CcFirqMask
                    sts       >vRow80SaveS
                    ldd       >vFillPat
                    ldx       >vFillPat
                    ldy       >vFillPat
                    lds       >vFillPat
                    tfr       a,dp
                    pshu      a,b,dp,x,y,s
                    pshu      a,b,dp,x,y,s
                    pshu      a,b,dp,x,y,s
                    pshu      a,b,dp,x,y,s
                    pshu      a,b,dp,x,y,s
                    pshu      a,b,dp,x,y,s
                    pshu      a,b,dp,x,y,s
                    pshu      a,b,dp,x,y,s
                    pshu      a,b,x,y,s
                    lds       >vRow80SaveS
                    puls      cc,dp,pc
* DrawHLine: X = row address, A = right x, B = left x: fills the span with the fill pattern ($9F00 = whole row)
DrawHLine               equ       *
                    jmp       >FswHLine           WildBits: view spans to the line engine too
                    nop
                    lbeq      FillRowFull
                    sta       <vHLineRightX
                    lsrb
                    abx
                    bhs       DrawHLineMid
                    incb
                    lda       #PixEvenNib
                    anda      ,x
                    ora       <vFillRightNib
                    sta       ,x+
* DrawHLineMid: after the odd left pixel: compute the byte count
DrawHLineMid               lda       <vHLineRightX
                    lsra
                    pshs      cc
                    blo       DrawHLineCount
                    deca
* DrawHLineCount: computes the remaining byte count
DrawHLineCount               sta       <vHLineLastByte
                    subb      <vHLineLastByte
                    decb
                    bitb      #HLineOddByte
                    beq       DrawHLineWords
                    incb
                    lda       >vFillPat
                    sta       ,x+
* DrawHLineWords: jumps into the unrolled stu ,x++ sequence for the word count
DrawHLineWords               ldu       >vFillPat
                    ldy       #DrawHLineTail+ModBase
                    jmp       b,y
                    fcb       $EF,$81,$EF,$81,$EF,$81,$EF,$81
                    fcb       $EF,$81,$EF,$81,$EF,$81,$EF,$81
                    fcb       $EF,$81,$EF,$81,$EF,$81,$EF,$81
                    fcb       $EF,$81,$EF,$81,$EF,$81,$EF,$81
                    fcb       $EF,$81,$EF,$81,$EF,$81,$EF,$81
                    fcb       $EF,$81,$EF,$81,$EF,$81,$EF,$81
                    fcb       $EF,$81,$EF,$81,$EF,$81,$EF,$81
                    fcb       $EF,$81,$EF,$81,$EF,$81,$EF,$81
                    fcb       $EF,$81,$EF,$81,$EF,$81,$EF,$81
                    fcb       $EF,$81,$EF,$81,$EF,$81,$EF,$81
                    fcb       $EF,$81,$EF,$81,$EF,$81,$EF,$81
* DrawHLineTail: end of the unrolled store sequence: writes the last left pixel nibble if needed
DrawHLineTail               fcb       $35,$01,$25,$08,$A6,$84,$84,$0F
                    fcb       $9A,$F0,$A7,$84,$39
* PolyBegin: D = first vertex (x,y): starts a polygon edge list at $0AC6, sets min/max y <$DB/<$DC
PolyBegin               std       >vPolyFirst
                    std       >vPolyLast
                    stb       <vPolyRow
                    stb       <vPolyLastRow
                    ldy       #vPolyEdgeList
                    sty       >vPolyEdgePtr
                    clr       >vPolyEdges
                    rts
* PolyAddVertex: D = next vertex (x,y): updates the y range and appends the edge from the previous vertex (start x, 8.8 slope)
PolyAddVertex               cmpb      <vPolyRow
                    bpl       PolyAddVertexChkMax
                    stb       <vPolyRow
                    bra       PolyAddVertexEdge
* PolyAddVertexChkMax: checks the maximum y
PolyAddVertexChkMax               cmpb      <vPolyLastRow
                    bmi       PolyAddVertexEdge
                    stb       <vPolyLastRow
* PolyAddVertexEdge: orders the edge endpoints top to bottom
PolyAddVertexEdge               tfr       d,x
                    ldd       >vPolyLast
                    stx       >vPolyLast
                    cmpb      >vPolyLast+1
                    blo       PolyAddVertexStore
                    exg       d,x
* PolyAddVertexStore: stores the edge record and computes dx/dy
PolyAddVertexStore               inc       >vPolyEdges
                    ldy       >vPolyEdgePtr
                    stb       ,y++
                    sta       2,y
                    ldb       #PixCenter88
                    lsra
                    rorb
                    std       ,y++
                    tfr       x,d
                    stb       -3,y
                    subb      -4,y
                    lbeq      PolyAddVertexFlat
                    suba      ,y
                    pshs      cc
                    bhs       PolyAddVertexSlope
                    nega
* PolyAddVertexSlope: divides to get the 8.8 edge slope
PolyAddVertexSlope               jsr       >DivFrac8+ModBase
                    puls      cc
                    bhs       PolyAddVertexSlopeSt
                    coma
                    comb
                    addd      #NegCarry
* PolyAddVertexSlopeSt: stores the signed slope
PolyAddVertexSlopeSt               asra
                    rorb
                    std       ,y++
                    sty       >vPolyEdgePtr
                    rts
* PolyAddVertexFlat: horizontal edge: no slope stored
PolyAddVertexFlat               sta       ,y++
                    sty       >vPolyEdgePtr
                    rts
