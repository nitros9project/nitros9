********************************************************************
* fs_wb.asm - FS (Flight Simulator II), WildBits port: the platform layer
*
* fs.asm assembles this file twice, in the two places of the original module that hold nothing:
*   WbPart 1 - the 16 zero bytes between the module name and the entry point ($0010-$001F)
*   WbPart 2 - the zero tail ($5BF0 on)
*   WbPart 3 - the original's embedded copyright string after the entry jump ($0023-$004F, 45 bytes; the title
*              screen, from the fd data file, still shows the copyright)
* Each WildBits call site in FS and the overlays is a same-length jsr into here (padded with nop),
* so no original address moves.
*
*   WbDScrn    entry table, fixed at WbEntry (F2 and F3 call it): SS.DScrn, text or the flight screen
*   WbStart    startup: the data directory /dd/fs2 (fa, fd, fp, the sf. scenery files) and fsw, the drawing
*              layer (port/fsw.asm) (part 3)
*   WbAScrn    the flight screen: three RAM blocks (the K2's clouds', the panel's at $8000, the scenery
*              window's second at $6000), bitmap 0 (640x240 HIRES4, CLUT 0)
*   WbPalette  CLUT 0 from FS's GIME palette (WbGime, part 1), then WbSet: I$SetStt on FS's display path
*   (fsw, port/fsw.asm, loaded at startup: the view drawn into the bitmaps by the line engine, the panel copy)
*   WbJoy      SS.Joy for the right stick in FS's 0-63 scale, from the mouse
*
* The module must end by $5CFF: a program using its last block past $1CFF is not linked into slot 7,
* and $FD00-$FFFF is I/O in every WildBits process map.

                    ifeq      WbPart-1
********************************************************************
* Part 1 ($0010-$001F)

* WbGime: B = the GIME color (%RGBrgb), shifted right once per component: bit 0 = the low bit,
* bit 2 = the high bit. Stores the component (0, $55, $AA, $FF) at ,u+ and shifts B for the next one.
WbGime              clra
                    lsrb
                    bcc       wg1@
                    lda       #GimeLevelLo
wg1@                bitb      #GimeCompHiBit
                    beq       wg2@
                    adda      #GimeLevelHi
wg2@                sta       ,u+
                    rts
                    zmb       $20-*

                    endc

                    ifeq      WbPart-3
********************************************************************
* Part 3 ($0023-$004F)

* WbStart: replaces StartupStub (an rts) at the start of FsMain. The data directory /dd/fs2 (FS opens its
* files by relative names) and the drawing layer fsw read into FswLoad on.
WbStart             lda       #READ.
                    ldx       #WbDataDir+ModBase
                    os9       I$ChgDir            on an error the current data directory stays
                    ldx       #WbFswName+ModBase
                    os9       I$Open
                    bcs       ws8@
                    ldx       #FswLoad
                    ldy       #FswMax
                    os9       I$Read
                    bcs       ws8@
                    os9       I$Close
                    rts
ws8@                os9       F$Exit              no fsw: FS cannot run (its error, before any screen is set up)
WbDataDir           fcc       "/dd/fs2"
                    fcb       C$CR

                    ifgt      *-$0050
                    error     "fs_wb.asm: part 3 is over 45 bytes"
                    endc
                    zmb       $0050-*
                    endc

                    ifeq      WbPart-2
********************************************************************
* Part 2 ($5BF0 on)

* Entry table
                    ifne      *-WbEntry
                    error     "fs_wb.asm: the entry table moved"
                    endc

* WbDScrn: A = path, Y = 0 for the text screen, else the flight screen (bitmaps on, text off).
* X and Y are kept.
WbDScrn             jsr       >FswQuiet           the engine sound off over the menus (the next frame brings it back)
                    pshs      x,y
                    ldx       #FX_TXT
                    leay      ,y
                    beq       wds1@
                    ldx       #FX_GRF+FX_BM
wds1@               ldy       #FT_OMIT
                    ldb       #SS.DScrn
                    os9       I$SetStt
                    puls      x,y,pc

* WbAScrn: replaces FS's SS.AScrn. Exit: X = the screen address, Y = WbScrBlks, carry set on an
* error (FS then reports a fatal error). The RAM blocks go back to the system when FS exits (fsw's ExitAll). Three
* consecutive blocks (no CoCo screen: the view is drawn in the bitmaps): the K2's clouds' (fs2/fscl, mapped by the
* K2's fsx only while the clouds run; the Jr2 leaves it empty), then the panel's, in the free slot at $8000 (FS's
* screen base $6110 puts its rows 99 on there), then the scenery window's second block at $6000 (WbWin2, to
* WbExit: the window is $4000-$7FFF). F$MapBlk takes the highest free slot (F$FreeHB), so the panel's block goes
* in first.
WbAScrn             clr       >DMA.Base+DMA_CTRL_REG stop a copy an earlier run left armed
                    ldb       #WbScrBlkCount
                    os9       F$AllRAM            D = the first of three consecutive blocks: the clouds'
                    bcs       wa9@
                    stb       >WbScrBlks+1
                    incb                          the panel's
                    clra
                    tfr       d,x
                    ldb       #OneBlock
                    os9       F$MapBlk
                    bcs       wa9@
                    cmpu      #WbPanelBlk
                    bne       wa7@
                    leax      1,x                 the window's second block
                    ldb       #OneBlock
                    os9       F$MapBlk
                    bcs       wa9@
                    cmpu      #WbWin2
                    bne       wa7@
                    ldx       #WbScrBase
                    pshs      x                   ,s = the screen address
                    ldx       #ScrType240
                    ldy       #ViewBitmap0        bitmap 0; Y stays 0 to the end
                    ldb       #SS.AScrn
                    bsr       WbSet               X = its first block
                    bcs       wa8@
                    tfr       x,d
                    stb       >WbScrBlks
                    ldx       #BmClearPoll        fill 0, wait for the end (mode 7)
                    ldu       #BmClearAllRows     every row
                    ldb       #SS.BmClear         its blocks hold whatever was in them
                    bsr       WbSet
                    ldx       #BmCfgKeep          enable and CLUT as they are
                    ldu       #BmCfgHires4        HIRES4 on, palette group 0
                    ldb       #SS.BmCfg
                    bsr       WbSet
                    ldx       #Layer0             layer 0 = bitmap 0 (Y): a terminal starts with its layers blanked
                    ldb       #SS.PScrn
                    bsr       WbSet
                    lda       #RealityOn          reality mode on from the start (Roger 2026-10-17); the
                    sta       >vReality              joystick setting stays fd's 0, the keyboard
                    bsr       WbPalette           carry from SS.ClutWrite
                    jsr       >FswInit            bitmap 1 and double buffering (fsw)
                    ldy       >WbScrBlks
                    puls      x,pc
wa8@                puls      x,pc                carry set by the failed SS.AScrn
wa7@                ldb       #E$NoRAM            a slot other than expected
                    orcc      #Carry
wa9@                rts

WbFswName           fcc       "fsw"               (part 3's WbStart opens it)
                    fcb       C$CR

* WbExit: FS's exit (F$Exit, B = the status): the window's second block and the screen block out of the map first.
WbExit              jsr       >FswExit            fsx's RAM block freed
                    pshs      b
                    ldd       #SidBothVolOff             both SIDs' volume 0: the engine sound off
                    sta       >SID_SELECT_PORT
                    stb       >SID_DATA_PORT
                    ldu       #WbWin2
                    ldb       #OneBlock
                    os9       F$ClrBlk            (not mapped yet on an early exit: nothing to clear)
                    ldu       #WbPanelBlk
                    ldb       #OneBlock
                    os9       F$ClrBlk
                    puls      b
                    os9       F$Exit

* WbPalette: Y = 0. CLUT 0 entries 0-15 from FS's GIME colors: each ESC $31 pp cc record at
* WbGimePal-3 becomes the entry blue, green, red in place (the unused fourth byte keeps the GIME code) (WriteTermResetStr no longer sends them).
WbPalette           ldx       #WbPalRecs
wp1@                ldb       3,x
                    leau      ,x
                    jsr       >WbGime+ModBase     blue: b, B
                    jsr       >WbGime+ModBase     green: g, G
                    jsr       >WbGime+ModBase     red: r, R
                    leax      4,x
                    cmpx      #WbPalRecsEnd
                    blo       wp1@
                    leax      -64,x               back to the first entry
                    ldu       #FsColorCount       CLUT 0 (Y) from entry 0
                    ldb       #SS.ClutWrite
* WbSet: B = the SetStat code, X/Y/U its parameters, on the display path ($0CD6). WbPalette falls into it.
WbSet               lda       >FsPath
                    os9       I$SetStt
                    rts

* WbJoy: replaces SS.Joy for the right stick. A = input path. Exit as SS.Joy: X, Y = 0-63,
* A = the button. The mouse's 640x480 position scaled to 0-63.
WbJoy               ldb       #SS.Mouse
                    os9       I$GetStt            X = 0-639, Y = 0-479, A = buttons (any one is the stick's)
                    pshs      a
                    tfr       x,d
                    lsra
                    rorb
                    lsra
                    rorb                          0-159
                    lda       #MouseXToJoy
                    mul                           A = 0-63
                    tfr       a,b
                    clra
                    tfr       d,x
                    tfr       y,d
                    lsra
                    rorb
                    lsra
                    rorb                          0-119
                    lda       #MouseYToJoy
                    mul                           A = 0-63
                    tfr       a,b
                    clra
                    tfr       d,y
                    puls      a,pc

* The FS addresses fsw goes back to (fs_wb.d) must be FS's
                    ifne      DrawHLine+8+ModBase-FsDrawHLine8
                    error     "fs_wb.d: FsDrawHLine8"
                    endc
                    ifne      FillRowFull+ModBase-FsFillRowFull
                    error     "fs_wb.d: FsFillRowFull"
                    endc
                    ifne      FillRow80+4+ModBase-FsFillRow80x4
                    error     "fs_wb.d: FsFillRow80x4"
                    endc
                    ifne      PlotPixel+5+ModBase-FsPlotPixel5
                    error     "fs_wb.d: FsPlotPixel5"
                    endc
                    ifne      DrawLine+4+ModBase-FsDrawLine4
                    error     "fs_wb.d: FsDrawLine4"
                    endc
                    ifne      UpdateInstrumentMasks+ModBase-FsUpdInstMasks
                    error     "fs_wb.d: FsUpdInstMasks"
                    endc
                    ifne      FillPolyRetireEdge+ModBase-FsPolyRetire
                    error     "fs_wb.d: FsPolyRetire"
                    endc
                    ifne      Xform3Software+ModBase-FsXform3Soft
                    error     "fs_wb.d: FsXform3Soft"
                    endc
                    ifne      Xform2Software+ModBase-FsXform2Soft
                    error     "fs_wb.d: FsXform2Soft"
                    endc
                    ifne      Xform2Sums+ModBase-FsXform2Sums
                    error     "fs_wb.d: FsXform2Sums"
                    endc
                    ifne      DrawGlyph+3+ModBase-FsDrawGlyph3
                    error     "fs_wb.d: FsDrawGlyph3"
                    endc
                    ifne      FillRect+4+ModBase-FsFillRect4
                    error     "fs_wb.d: FsFillRect4"
                    endc
                    ifne      GroundPtOvZ+ModBase-FsGPtOvZ
                    error     "fs_wb.d: FsGPtOvZ"
                    endc
                    ifne      BuildViewMatrix+ModBase-FsBuildViewMatrix
                    error     "fs_wb.d: FsBuildViewMatrix"
                    endc
                    ifne      GroundPtOvX+ModBase-FsGPtOvX
                    error     "fs_wb.d: FsGPtOvX"
                    endc
                    ifne      DrawTextString+ModBase-FsDrawTextString
                    error     "fs_wb.d: FsDrawTextString"
                    endc
                    ifne      SwitchOverlay+ModBase-FsSwitchOverlay
                    error     "fs_wb.d: FsSwitchOverlay"
                    endc
                    ifne      DrawViewAircraftParts+ModBase-FsDrawViewParts
                    error     "fs_wb.d: FsDrawViewParts"
                    endc
                    ifne      DispListDispatch+ModBase-FsDispList
                    error     "fs_wb.d: FsDispList"
                    endc
                    ifne      RunDisplayList+ModBase-FsRunList
                    error     "fs_wb.d: FsRunList"
                    endc
                    ifne      RunDisplayListAt+8+ModBase-FsDispNext
                    error     "fs_wb.d: FsDispNext"
                    endc
                    ifne      ProcessTimerTicks+ModBase-FsTimerTicks
                    error     "fs_wb.d: FsTimerTicks"
                    endc
                    ifne      SignalIntercept+ModBase-FsSigIcpt
                    error     "fs_wb.d: FsSigIcpt"
                    endc
                    ifne      Atan2Angle+ModBase-FsAtan2
                    error     "fs_wb.d: FsAtan2"
                    endc
                    ifne      Sin16+ModBase-FsSin16
                    error     "fs_wb.d: FsSin16"
                    endc
                    ifne      Cos16+ModBase-FsCos16
                    error     "fs_wb.d: FsCos16"
                    endc
                    ifne      LoadPanelPicture+ModBase-FsLoadPanelPicture
                    error     "fs_wb.d: FsLoadPanelPicture"
                    endc
                    ifne      LoadPictureFa+ModBase-FsLoadPictureFa
                    error     "fs_wb.d: FsLoadPictureFa"
                    endc
                    ifne      InitFlightDisplay+ModBase-FsInitFlightDisplay
                    error     "fs_wb.d: FsInitFlightDisplay"
                    endc
                    ifne      SetHeightFromTerrain+ModBase-FsSetHeightFromTerrain
                    error     "fs_wb.d: FsSetHeightFromTerrain"
                    endc
                    ifne      PollKey+ModBase-FsPollKey
                    error     "fs_wb.d: FsPollKey"
                    endc
                    ifne      ShowThrottlePos+ModBase-FsShowThrottlePos
                    error     "fs_wb.d: FsShowThrottlePos"
                    endc
                    ifne      ShowElevatorPos+ModBase-FsShowElevatorPos
                    error     "fs_wb.d: FsShowElevatorPos"
                    endc
                    ifne      ShowAileronPosGauge+ModBase-FsShowAileronPosGauge
                    error     "fs_wb.d: FsShowAileronPosGauge"
                    endc
                    ifne      ShowRudderPos+ModBase-FsShowRudderPos
                    error     "fs_wb.d: FsShowRudderPos"
                    endc
                    ifne      SetLineColor+ModBase-FsSetLineColor
                    error     "fs_wb.d: FsSetLineColor"
                    endc
                    ifne      SetFillColor+ModBase-FsSetFillColor
                    error     "fs_wb.d: FsSetFillColor"
                    endc
                    ifne      Dec3ToAscii+ModBase-FsDec3ToAscii
                    error     "fs_wb.d: FsDec3ToAscii"
                    endc
                    ifne      DrawClockHourMin+ModBase-FsDrawClockHourMin
                    error     "fs_wb.d: FsDrawClockHourMin"
                    endc
                    ifne      DrawEngineSwitches+ModBase-FsDrawEngineSwitches
                    error     "fs_wb.d: FsDrawEngineSwitches"
                    endc
                    ifne      SetAdfFreq+ModBase-FsSetAdfFreq
                    error     "fs_wb.d: FsSetAdfFreq"
                    endc
                    ifne      PrintPanelText5+ModBase-FsPrintPanelText5
                    error     "fs_wb.d: FsPrintPanelText5"
                    endc
                    ifne      PrintPanelTextF+ModBase-FsPrintPanelTextF
                    error     "fs_wb.d: FsPrintPanelTextF"
                    endc
                    ifne      ShowTextMsgWaitKey+ModBase-FsShowTextMsgWaitKey
                    error     "fs_wb.d: FsShowTextMsgWaitKey"
                    endc
                    ifne      InitAdfNeedle+ModBase-FsInitAdfNeedle
                    error     "fs_wb.d: FsInitAdfNeedle"
                    endc
                    ifne      MulQ15Vars+ModBase-FsMulQ15Vars
                    error     "fs_wb.d: FsMulQ15Vars"
                    endc
                    ifne      DivQ15Signed+ModBase-FsDivQ15Signed
                    error     "fs_wb.d: FsDivQ15Signed"
                    endc
                    ifne      Cos8+ModBase-FsCos8
                    error     "fs_wb.d: FsCos8"
                    endc
                    ifne      Sin8+ModBase-FsSin8
                    error     "fs_wb.d: FsSin8"
                    endc
                    ifne      ResetFlightState+ModBase-FsResetFlightState
                    error     "fs_wb.d: FsResetFlightState"
                    endc

* The end: FS must stay within $5CFF bytes
                    ifgt      *-$5CFC
                    error     "fs_wb.asm: FS is over $5CFF bytes"
                    endc

                    endc
