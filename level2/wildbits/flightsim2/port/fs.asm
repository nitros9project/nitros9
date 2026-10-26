********************************************************************
* FS - disassembled OS-9 module (byte-exact lwasm round trip)
* Flight Simulator II (subLOGIC, 1987), CoCo 3 OS-9 Level 2: disassembled from the byte listing ../fs.asm.
* FS runs at $A000: its absolute addresses into itself are written Lxxxx+ModBase.
* header: type/lang $11 attr/rev $80, exec offset $0020, data size $4000 (16384), module size 24064 bytes
* Labels name the routines, branch points and data; ModBase+label is the run address. Data addressing is left numeric (offsets into the
* program's data area, <$xx = direct page). fcb lines inside code carry the decoded mnemonic as a comment
* where the assembler could not be made to reproduce the original encoding.

                    nam       FS
                    ttl       FS (disassembly)

                    ifp1
                    use       defsfile
                    use       fs_wb.d
                    endc

* Constants: the values this module's instructions use, by name (fs_wb.d holds the addresses)
AdcCarryOnly        equ       $00                 adc's operand 0: only the carry added (the low byte's carry into the high byte)
AdfAreaBotRight     equ       $854C               the panel's ADF frequency area: bottom right (x $85, y $4C)
AdfAreaTopLeft      equ       $7040               the panel's ADF frequency area: top left (x $70, y $40)
AdfCenter           equ       $495D               the ADF dial's center: row 73 (high), x 93 (low)
AdfNoStation        equ       $C000               the ADF's angle while no station is received: the needle points up
AdfRetuned          equ       $FF                 $020E $FF: the ADF retuned, its station searched again (RunDisplayList keeps it in $020F)
AileronBias         equ       $8000               the stick's x x 4 (0-252) in the high byte, less it: the signed aileron position
AileronMarkerAt     equ       $1636               the aileron marker's slide: byte column 22 (high), row 54 (low)
AirDensitySea       equ       $7FFE               the air density ($0749, Q15) at sea level: less 2.5 a meter of altitude
AirspeedCenter      equ       $270D               the airspeed dial's center: row 39 (high), x 13 (low)
AirspeedDialTop     equ       $5A                 the airspeed the dial's table covers up to (23 entries, 4 apart)
AirspeedStepFrac    equ       $07                 the airspeed within a table step, in eighths: its low 2 bits and first fraction bit
AirspeedZero        equ       $0000               0: vAirspeed at a standstill (a brake press does not take it below 0)
AltClampLo          equ       $03                 the height's low byte after the integration went below 0: 3/256 m (on the ground)
AltErrStep          equ       $0001               the altimeter error's ($073D) step toward $073F a pass: 1 (FS's 2)
AltErrStepFlip      equ       $FFFE               -2: turns the AltErrStep (+1) that follows into -1 (16 bits)
AltimErrOddsMask    equ       $03                 the Z position's meter byte (<$0A), its low 2 bits: vAltimErrGoal picked only when they are 0 (one time in 4)
AltimeterBandSteps  equ       $0370               880 altimeter steps: a 10,000 ft band, one turn of the small hand
AltimeterCenter     equ       $1E41               the altimeter's center: row 30 (high), x 65 (low)
AltimeterHalfBand   equ       $01B8               440 altimeter steps, 5,000 ft: the band marker's second position in a band
AltimeterLastBand   equ       $09                 the last 10,000 ft band the band marker counts
AltimeterLastMark   equ       $13                 the altimeter band marker's last position (2 a band, 0-19)
AltimeterStepsPerM  equ       $24F4               Q15 0.2887: meters to altimeter steps (88 a 1000 ft)
AmmoFull            equ       $64                 the guns' rounds after rearming ($0814)
Ang180FixLo         equ       $01                 the low byte that makes Ang180W $8001 before AngleToDegrees360
Ang180W             equ       $8000               180 degrees as a 16-bit angle (made $8001 before MulQ15Vars here)
Angle16Quarter      equ       $4000               90 degrees in a 16-bit angle (65536 a turn)
Angle8Half          equ       $80                 180 degrees in an 8-bit angle (256 a turn)
Angle8NegQuarter    equ       $C0                 -90 degrees in an 8-bit angle (256 a turn)
Angle8PastQuarter   equ       $41                 the first 8-bit angle past 90 degrees (256 a turn)
Angle8Quarter       equ       $40                 90 degrees in an 8-bit angle (256 a turn)
AsciiFive           equ       $35                 ASCII 5: the tachometer's odd half step (50 RPM)
AsciiNine           equ       $39                 ASCII 9: the last decimal digit character
AsciiSpace          equ       $20                 ASCII space: the word gap in the packed text
AsciiZero           equ       $30                 ASCII 0: a digit's value to its character
AsciiZeroLess1      equ       $2F                 ASCII 0 less 1: the digit loop counts up before each subtraction
AsciiZeroPlus10     equ       $3A                 ASCII 0 plus 10: the overshot remainder (-10 to -1) back to its digit
AsciiZeros          equ       $3030               ASCII 0 in both bytes: two digit values to their characters
AtanFracHiBits      equ       $07                 the ratio's bits 8-10: the high byte of its fraction within a table step (r & $7FF)
AtanTieNudge        equ       $0001               1 added to <$A5 when it equals <$A7: the swapped ratio stays below 1 for DivQ15Signed
AttBallCX           equ       $27                 the attitude ball's center x
AttBallCY           equ       $1D                 the attitude ball's center row
AttBallLastRow      equ       $2C                 the attitude ball's bottom row (AttBallRow0 + AttBallRows - 1)
AttBallRow0         equ       $0D                 the attitude ball's top row
AttBallRows         equ       $20                 the attitude ball's rows
AttGroundColor      equ       $88                 the attitude ball's ground: color 8 (brown) in both nibbles
AttHzHalfLen        equ       $3C                 the attitude horizon's half length: cos x 60 / 256
AttMoveBack         equ       $FE                 the masked change of -1 or -2: too small to redraw the attitude ball
AttMoveMask         equ       $FE                 the pitch or bank change without bit 0: 0 when it moved 0 or +1
AttPitchOfs         equ       $20                 pitch + 32: the attitude ball shows pitch -32 to 31
AttPitchSpan        equ       $40                 the pitches the attitude ball shows (64 from -32)
AttRedrawOfs        equ       $0B                 moves vAttPitchShown more than 1 off the pitch: the attitude indicator redraws
AttSkyColor         equ       $77                 the attitude ball's sky: color 7 (light blue) in both nibbles
BankCenterDec       equ       $FFD8               the roll self-centering's step toward 0 for a positive bank (-40)
BankCenterInc       equ       $0028               the roll self-centering's step toward 0 for a negative bank (+40)
BlkCacheLast        equ       $03                 LoadDataBlock: the block cache's last slot
BlkNone             equ       $FF                 LoadDataBlock: no block in a cache slot; also its slot -1
BmCfgHires4         equ       $0100               SS.BmCfg's R$U: HIRES4 on (high byte 1), palette group 0 (low byte)
BmCfgKeep           equ       $FFFF               SS.BmCfg's R$X: the enable and CLUT bytes $FF, both kept as they are
BmClearAllRows      equ       0                   SS.BmClear's U: first row 0 (high), rows 0 = to the end (low): every row
BmClearPoll         equ       $7000               SS.BmClear's R$X: fill value 0, wait mode 7 (DmaWt.Poll): back when the fill is done
BombsFull           equ       $35                 the bombs after rearming: '5' ($129B holds the count as an ASCII digit)
CarbHeatDrop        equ       $F8                 -8: the throttle the carburetor heat costs (vCarbHeat on)
CarbIceDrop         equ       $E0                 -32: the throttle lost while the carburetor heat melts carburetor ice (vCarbIce)
CarbIceSteps        equ       $14                 20: vCarbIce's start: the engine updates the ice takes to melt with the carburetor heat on
CarbIceThrottle     equ       $4000               the throttle (vThrottle, 16 bits) at or below which carburetor ice forms
CarryOnly           equ       $00                 0: an adc or sbc of the carry alone (a rounding bit, a carry or borrow into the next byte)
CcFirqMask          equ       $40                 the CC register's F bit: FIRQ masked while S holds the fill pattern
CdiDevMax           equ       $001E               30: the CDI's full deflection, 10 degrees in the deviation's 1/3-degree units
CdiDevMin           equ       $FFE2               -30: the CDI's full deflection the other way (1/3-degree units)
CdiDevMinLo         equ       $E2                 the low byte of -30, the CDI's full deflection the other way
CharDelayLo         equ       $0A                 the per-character delay's low byte: (255 - vCommRate) x 256 + 10 loops
CharStep            equ       $04                 a character's advance: 4 pixels (3 wide, 1 apart)
ClockHours          equ       $18                 24: the hours in a day, the hour after 23 is 0
ClockLastMin        equ       $3B                 59: the clock's last minute
ClockLastSec        equ       $3B                 59: the clock's last second
ClockZeroLess1      equ       $FF                 0 less 1: the inca / incb that follows makes the clock's minutes or seconds 0
ColorClear          equ       $00                 FS's color 0: the view cleared (black on the CoCo; the sky through the bitmaps' see-through nibble)
ColorNibble         equ       $0F                 a both-nibble color byte's low nibble: the color 0-15
ComRetuned          equ       $01                 $02A3 and $02AD 1: COM1 retuned (RunDisplayList keeps $02A3 in $02A4)
Cos90Deg            equ       $0000               the cosine of 90 degrees, Q15: 0
CosPast90Half       equ       $FE6E               cos(90 degrees + half a cosine table step), Q15 (-402)
CoverRecCount       equ       $08                 DrawInstrumentCovers' bits of A tested: 8, one 5-byte record each
CrankLoopsInner     equ       $00FF               the starter's cranking delay: the inner loop's passes
CrankLoopsOuter     equ       $0005               the starter's cranking delay: the outer loop's passes
CrashLanding        equ       $04                 the crash code ($0137): a landing too hard or too banked
CrashMsgDelay       equ       $05                 DelayA's count for the CRASH or SPLASH message
CrashSplash         equ       $08                 the crash code ($0137): a splash, the aircraft on water
CreditsMsgLen       equ       $010A               vCreditsMsg's length in bytes
CtlBias             equ       $7F                 a control's signed high byte + 127: 0-254, its marker's step after 4 shifts
DataFileMagic       equ       $DD01               the data file's header magic
DataHdrLen          equ       $000A               the data file's header: 10 bytes, the block index after it
DataIdxLen          equ       $06                 one block's index entry in the data file: file position (4), length (2)
DecPlace10          equ       $000A               10: the tens place (DecDigitBySub's divisor; a digit loop's subtraction)
DecPlace100         equ       $0064               100: the hundreds place (DecDigitBySub's divisor)
DecPlace1000        equ       $03E8               1000: the thousands place (DecDigitBySub's divisor)
DecPlace10000       equ       $2710               10000: the ten thousands place (DecDigitBySub's divisor)
DegPerHalfTurn      equ       $00B4               degrees in a half turn: the reciprocal heading, and a 16-bit angle's Q15 scale to degrees
DegPerTurn          equ       $0168               degrees in a turn: a negative heading made 0-359
DelayInnerLoops     equ       $0000               DelayA's inner loop count: 0, 65536 passes (leax -1 wraps)
DemoAnswerFlip      equ       $01                 flips the answer index (A 0, B 1) to vDemo (A 1 the demo, B 0)
DevHalfTurn         equ       $021C               540: a half turn in the NAV deviation's 1/3-degree units (as Q15: a 16-bit angle to them)
DevHalfTurnNeg      equ       $FDE4               -540: minus a half turn in the NAV deviation's 1/3-degree units
DevOffEndLo         equ       $2C                 the low byte of 300 ($012C), the OFF band's end: from it on the flag is TO
DevOffHi            equ       $01                 the high byte of 256-299, the deviation's OFF band (85-100 degrees): below it the flag is FROM
DevOffNegEndLo      equ       $D4                 the low byte of -300 ($FED4), the negative OFF band's end: below it the flag is TO
DevOffNegHi         equ       $FE                 the high byte of the negative OFF band, -300 to -257 ($FED4-$FEFF)
DialHalf            equ       $2C                 44: half a turn of a dial needle (9 o'clock)
DialLast            equ       $57                 87: a dial needle's last position
DialQuarter         equ       $16                 22: a quarter turn of a dial needle (88 positions counterclockwise from 3 o'clock; 22 points up)
DialQuarterLessTurn equ       $BE                 -66: DialQuarter less one turn (88), for a remainder left one turn below 0
DialSteps           equ       $58                 88: a dial needle's positions in one turn
DialThreeQuarters   equ       $42                 66: three quarters of a turn of a dial needle (6 o'clock)
DigitValMask        equ       $0F                 an ASCII digit's value bits (0-9)
DivSignNeg          equ       $FF                 DivQ15Signed's sign flag <$9A: the quotient is negative
DlOpBits            equ       $7F                 a display-list op byte without bit 7 (DispListDispatch's aslb drops it)
DlOpEnd             equ       $79                 display-list op: the list's end
DlOpLineTo          equ       $02                 display-list op: a 3D line from the last point to this one (X, Y, Z words follow)
DmeNmScale          equ       $011B               283 (32768 / 115.75): the station distance (16 m units) to nautical miles, 8.8 after MulU16Mid and x 2
DmeNoSignal         equ       $01                 $0719 1: no DME station, the readout blank
DmeRedraw           equ       $01                 $071A 1: DrawDmeReadout redraws the DME readout (its bit 0, shifted out)
DmeTenthsScale      equ       $14                 20: the mile's fraction / 2 (0-127) to tenths in the high byte (MulSigned8)
DmgEngine           equ       $03                 vDamageBits' engine bits: b0 the oil overheats, b1 no oil pressure
DmgLeakL            equ       $04                 vDamageBits b2: the left tank leaks
DmgLeakR            equ       $08                 vDamageBits b3: the right tank leaks
DmgOilHot           equ       $01                 vDamageBits b0: the oil overheats
DmgOilPress         equ       $02                 vDamageBits b1: no oil pressure
DmgPowerMax         equ       $10                 the throttle (power) held to it while an engine damage bit is set
DScrnText           equ       $0000               WbDScrn's Y: 0 the text screen (else the flight screen's blocks)
EdgeRetired         equ       $7F                 polygon fill: an edge's top row past every scan row, so the edge is done
EdPosBiasHi         equ       $40                 EdPosBias's high byte: NORTH and EAST POSITION are the map square + $4000
ElevatorJoyScale    equ       $A2                 the stick's turned y x 4 (0-252) x it: the elevator's whole travel (about $A000)
ElevatorLimit       equ       $5000               the elevator's travel each side of center (its high byte $B0-$50)
ElevatorLimitHi     equ       $50                 the elevator's high byte at its top end (+80; $B0 the bottom): ShowElevatorPos's steps count down from it
ElevatorMarkerAt    equ       $1A4E               the elevator marker's slide: byte column 26 (high), its bottom row 78 (low)
ElevatorMarkerCenter equ       $0A                 the elevator marker's center position
ElevatorMarkerSpan  equ       $14                 the elevator marker's travel (positions 0-20, drawn upside down)
ElevDriftStep       equ       $01                 vElevator's step toward the trim ($081C) a pass: 1 (stored to $081B)
ElevSnapSpeedLo     equ       $0A                 UpdateGroundElev: the airspeed's low byte (vAirspeed+1) below it, vElev takes vElevArea at once
EngineRunning       equ       $01                 vEngineOn 1: the engine runs
EnvBankMax          equ       $16                 the bank ($074F's high byte) the stall timer's envelope allows each way (31 degrees)
EnvBankSpan         equ       $2C                 twice EnvBankMax: the envelope's bank window
EnvPitchMax         equ       $0F                 the pitch ($074D's high byte) the stall timer's envelope allows each way (21 degrees)
EnvPitchSpan        equ       $1E                 twice EnvPitchMax: the envelope's pitch window
EnvSpeedMax         equ       $49                 the airspeed (m/s, vAirspeed's high byte) the stall timer's envelope allows each way
EnvSpeedSpan        equ       $92                 twice EnvSpeedMax: the envelope's airspeed window
ErrBadMediaType     equ       $F9                 OS-9 error E$BTyp: bad media type
ErrBadSector        equ       $F1                 OS-9 error E$Sect: bad sector number
ErrBlockTooBig      equ       $0B                 LoadDataBlock's error: the block does not fit below its limit
ErrNoScreen         equ       $50                 FatalSystemError's code: no flight screen (WbAScrn failed)
ErrNotAccessible    equ       $D6                 OS-9 error E$FNA: file not accessible
ErrPathNotFound     equ       $D8                 OS-9 error E$PNNF: path name not found
EvenMask            equ       $FE                 bit 0 cleared: an even value (vAtanTbl's byte index of a word)
FailHandlerIx       equ       $0E                 a random even index 0-14: one of TblFailureHandlers' 8 words
FailMsgDelay        equ       $01                 how long AIRCRAFT PROBLEM stays: DelayA's count
FailRollEnd         equ       $64                 100: a random byte at or above it is no roll; 0-99 at or above vReliability fails a part
FailRollPasses      equ       $0A                 the failure roll's countdown start ($0224): a roll every 11th UpdateReliability pass
FatalCodeMsgLen     equ       $0007               MsgFatalCode's length in bytes
FatalMsgLen         equ       $002C               MsgFatalSysError's length in bytes
FdWordLen           equ       $0002               an fd record header's words (the length, the address): 2 bytes each
FirstUserMode       equ       $0A                 the first user mode: modes 0-9 are built in; InitRunTable65 fills each library record with its number
FlapsMarkBase       equ       $3610               the flaps marker's column ($36, bytes) and base row ($10)
FlapsMarkRows       equ       $01                 the flaps marker's height in rows
FlapsMarkUp         equ       $06                 the flaps marker's position with the flaps up (6 less the setting)
FontFirstChar       equ       $20                 the font's first character (space): the glyph index is the character less this
FrameEvery8         equ       $04                 vFrameCount's bit 2: phase 0's work on every other phase-0 frame, every 8th (the radios retuned, the demo's start)
FrameSigOff         equ       $0000               SS.FClr's Y: 0, the frame signal cleared
FrameSigOn          equ       $0001               SS.FClr's Y: not 0, the frame signal set
FrameSigTicks       equ       $000C               SS.FClr's X: the ticks between /FTDD's frame signals (12: five a second)
FsColorCount        equ       16                  FS's colors 0-15: SS.ClutWrite's U, the CLUT 0 entries written
FsDiskMsgLen        equ       $0062               vFsDiskMsg's length in bytes
FsdTypeLang         equ       $40                 fsd's module type and language: Data
Fuel1MarkBase       equ       $420B               fuel tank 1's gauge marker: column ($42, bytes) and row ($0B)
Fuel2MarkBase       equ       $4A0B               fuel tank 2's gauge marker: column ($4A, bytes) and row ($0B)
FuelBurnRate        equ       $FB                 -5: the fuel a throttle unit burns (MulSigned8 with vThrottle's high byte; x 8 in Europe 1917)
FuelBurnSecBit      equ       $02                 the clock seconds' bit 1: an engine update burns fuel only when it is set (every 4 s)
FuelBurnSignExt     equ       $FF                 $FF: the negative burn's (<$90) sign byte, added with the carry into a tank's high byte
FuelFull            equ       $20                 a full fuel tank ($0731, $0734)
FuelSelGlyph        equ       $3B                 the fuel tank selector's glyph (font entry $3B)
FuelSelTank1        equ       $8403               the fuel selector glyph's spot over tank 1's gauge: x $84, row 3
FuelSelTank2        equ       $9903               the fuel selector glyph's spot over tank 2's gauge: x $99, row 3
FwdViewPitch        equ       $00                 the forward view's pitch offset added to the shown pitch (0: none)
GaugeMarkMin        equ       $00                 a slide gauge marker's position 0: the gauge's left end
GaugeMarkRows       equ       $06                 a slide gauge marker's height in rows
GimeCompHiBit       equ       %00000100           the GIME color's high bit of this component, after WbGime's shift (bit 2)
GimeLevelHi         equ       $AA                 a GIME color component's high bit as an 8-bit level
GimeLevelLo         equ       $55                 a GIME color component's low bit as an 8-bit level
GlyphKeepEven       equ       $000F               an even-x glyph row keeps the screen word's last pixel
GlyphKeepOdd        equ       $F000               an odd-x glyph row keeps the screen word's first pixel
GlyphRowMask        equ       $07                 one glyph row: its 3 pixel bits
GlyphStopBit        equ       $80                 the glyph word's stop bit (bit 15) above its five 3-bit rows
GlyphStopEnd        equ       $0001               the glyph word with its five rows shifted out: only the stop bit left
GndEffectHeight     equ       $14                 the height (m) under which the wing gets ground effect
GndEffectHeightHi   equ       $00                 GndEffectHeight's high byte: the 16-bit height (<$05-<$06, m) less 20 m
GndEffectLift       equ       $0B                 ground effect's lift, added to the lift coefficient's high byte ($0796)
GndHeightFt         equ       $0009               the aircraft's height on the ground (3 m) in ft, left out of ALTITUDE
GndHeightHi         equ       $00                 the on-ground test's height $000301, its high byte
GndHeightLo         equ       $01                 the on-ground test's height 3 m + 1/256 ($000301), its low byte
GndHeightMid        equ       $03                 the on-ground test's height $000301, its middle byte: 3 m, the aircraft's height on the ground
GndTrackOfs         equ       $0000               the track's offset from the heading on the ground: 0 (vTrackOfs in the air)
GoodbyeMsgLen       equ       $0031               vGoodbyeMsg's length in bytes
GroundElevStep      equ       $01                 vElev's step toward vElevArea: 1 m (two decb make it -1)
GroundPtExpMin      equ       $30                 a ground point's exponent is at least 48 (64 + its shift); a 3D point's is 0
GsDevCenter         equ       $0C00               12 x 256: the glideslope deviation moved to the needle's center position (its high byte the position)
GsDevSpan           equ       $1800               24 x 256: a moved glideslope deviation below it is on the needle's scale (0-23)
GsNeedleLast        equ       $18                 24: the glideslope needle's last position (12 centered)
GunBurstRounds      equ       $03                 Europe 1917: the rounds one joystick button press fires (vGunBurst)
GyroDriftStep       equ       $0002               the heading indicator's drift ($0210, a 16-bit angle) added each UpdateReliability pass
HexByteLen          equ       $0002               a byte in hex: 2 digits
HexLetterGap        equ       $07                 from ASCII 9 plus 1 to A: a hex digit past 9 to its letter
HexLoDigit          equ       $0F                 a byte's low nibble: its low hex digit (0-15)
HexWordLen          equ       $0004               a 16-bit value in hex: 4 digits
HLineOddByte        equ       $01                 the remaining byte count's bit 0: odd, one byte stored before the words
HtAboveGndStep      equ       $0001               the height above ground's (<$05) step up: 1 m, when vElev stepped down
HzDeadLoad          equ       $FF                 $FF loaded into A and overwritten by the next instruction: no effect (FS's own bytes)
HzEndAngle          equ       $35                 the horizon line's ends: the view heading +- 53/256 turn (74.5 degrees)
HzListZero          equ       $0000               0: <$0C, <$10 (saved, put back after) and <$42-<$4A while the horizon display list runs
HzNoLine            equ       $FF                 <$D4, the last line's first row: no horizon line drawn yet
IceCheckMaskHi      equ       $3F                 the bits of vFrameCount that must be 0 for the carburetor ice check
IceCheckMaskLo      equ       $FC                 the bits of the byte after vFrameCount ($41) that must be 0 for the carburetor ice check
IlsCourseToObs      equ       $1555               Q15 1/6: the ILS course ($0154, 1/3 degrees) to the OBS's 2-degree units
InstAirspeed        equ       $01                 <$EB bit 0: the airspeed indicator present, working and shown
InstAllBits         equ       $FFFF               every instrument's bit: all working ($02AE), all shown ($0233)
InstAltimeter       equ       $08                 <$EB bit 3: the altimeter present, working and shown
InstAttitude        equ       $10                 <$EB bit 4: the attitude indicator present, working and shown
InstCompass         equ       $10                 <$EC bit 4: the magnetic compass is shown
InstForced3         equ       $F1                 <$ED's bits forced on: all but bits 1-3 (bit 3 NAV2 or the ADF)
InstFuelGauges      equ       $20                 <$EC bit 5: the fuel gauges and the tank selector are shown
InstHdgInd          equ       $04                 <$EB bit 2: the heading indicator is shown
InstNav1            equ       $20                 <$EB bit 5: the NAV1 indicator present, working and shown
InstNav2            equ       $08                 <$ED bit 3: the NAV2 dial present, working and shown (the ADF's while $0348 is set)
InstOilGauges       equ       $40                 <$EC bit 6: the oil temperature and pressure gauges are shown
InstReadouts        equ       $80                 <$EC bit 7, forced on: the radio, clock, DME and engine switch readouts
InstTach            equ       $40                 <$EB bit 6: the tachometer is shown
InstTurnCoord       equ       $02                 <$EB bit 1: the turn coordinator (airplane and slip ball) present, working and shown
JoyBothSticks       equ       $02                 vJoyMode 2: both sticks (the left one the throttle)
JoyMax              equ       $3F                 the stick's largest reading (0-63): its y turned over
JoyXAboveMid        equ       $21                 ReadJoyRightX: the stick's x at or above it moves 1 down toward the center (32)
JoyXBelowMid        equ       $1F                 ReadJoyRightX: the stick's x at or below it moves 1 up toward the center (32)
JoyXJitter          equ       $02                 ReadJoyRightX: x within 1 of the last (x - last + 1 at most 2) leaves the ailerons
KeyA                equ       $41                 the key A (ASCII): the first answer; an answer less it is the answer's index
KeyB                equ       $42                 the key B (ASCII): the operating mode question's last answer
KeyC                equ       $43                 the key C (ASCII): the display question's last answer
KeyF1               equ       $B1                 F1 ($B1; the K2's $A1 made it by fswc's KeyMap): overlay 1, CMDS/f2
KeyF2               equ       $B2                 F2 ($B2; the K2's $A2 made it by fswc's KeyMap): overlay 2, CMDS/f3
KeyOvlBase          equ       $B1                 an overlay key ($B5-$B8) less it: the overlay requested (4-7)
KeyOvlEnd           equ       $B9                 past the last overlay key ($B8)
KeyOvlFirst         equ       $B5                 the first of the overlay keys $B5-$B8 (overlays 4-7; fswc's KeyMap makes F3 $B5)
KeyP                equ       $50                 the key P (ASCII): the pause ends
KeyQuit             equ       $90                 Alt+P: FS's quit key
KeyReadLen          equ       $0001               PollKeyRead's I$Read count: one key byte
KeyShiftBreak       equ       $03                 Shift+BREAK ($03, the CoCo 3 code fswc's KeyMap makes): the credits, at the display question
LandBankMax         equ       $0A                 the bank (an 8-bit angle) a landing survives each way: 14 degrees
LandBankSpan        equ       $14                 twice LandBankMax: the landing's bank window
LandSinkMax         equ       $08                 the sink rate a landing survives ($07BF's high byte, downward)
Layer0              equ       0                   SS.PScrn's X: layer 0, the top display layer
LightDay            equ       $01                 vLight: day
LightDusk           equ       $02                 vLight: dawn or dusk
LightNight          equ       $04                 vLight: night
LlAxisCount         equ       3                   the long line's components: x, y, z (FswLl's three 16.8 positions and steps)
LlStepShifts        equ       4                   the long-line step's left shifts: the ends' difference / 16 as 16.8 (<< 8, >> 4)
LoadKindCrash       equ       $01                 vLoadKind 1: the crash reset (the same B makes vOvlReq 1, CMDS/f2)
LoadKindDemo        equ       $03                 vLoadKind 3: the demo start (F2's mode-3 load)
MagDrop             equ       $04                 the power lost on one magneto alone (the mag drop)
MagSwBoth           equ       $03                 vMagSw 3: the magneto switch at BOTH (after the start)
MagSwStart          equ       $04                 vMagSw 4: the magneto switch at START (the starter cranks)
ModCrcLen           equ       $0003               a module's CRC at its end: 3 bytes
ModeRecLen          equ       $41                 a mode record's bytes
MonitorMsgLen       equ       $010C               vMonitorMsg's length in bytes
MouseXToJoy         equ       102                 the mouse's x / 4 (0-159) x it / 256: the stick's x, 0-63
MouseYToJoy         equ       136                 the mouse's y / 4 (0-119) x it / 256: the stick's y, 0-63
MPerFtQ16Fs         equ       $4E0C               meters per foot in 1/65536 as FS's SetHeightFromTerrain takes it (0.30487)
MsgTextStays        equ       $01                 ShowTextMsgWaitKey's A: not 0, the text screen stays after the key (0: back to the flight screen)
Nav1Rx              equ       $01                 $028E's bit 0: NAV1 hears its station
Nav1RxOff           equ       $FE                 clears $028E bit 0: NAV1 no longer hears its station
Nav2FlagRec         equ       $03                 NAV2's first record in vNavFlagTxt (NAV1's are 0-2)
Nav2Rx              equ       $02                 $028E's bit 1: NAV2 hears its station
Nav2RxOff           equ       $FD                 clears $028E bit 1: NAV2 no longer hears its station
NavFlagFrom         equ       $02                 vNav1Flag / vNav2Flag 2: FROM (vNavFlagTxt's third record)
NavFlagTo           equ       $01                 vNav1Flag / vNav2Flag 1: TO (vNavFlagTxt's second record)
NavRetuned          equ       $01                 $028C 1: a NAV radio retuned, its station searched again (RunDisplayList keeps it in $028D)
NeedleMirrored      equ       $FF                 <$3B: the needle drawn mirrored left-right (0 not)
NeedleStep          equ       $01                 a NAV needle's (CDI, glideslope) step a pass: one position
NegBorrow           equ       $00                 sbca's operand 0 after nega, negb: the low byte's borrow taken from the high byte (a 16-bit negate)
NegCarry            equ       $0001               the 1 that completes a 16-bit two's-complement negate (after coma, comb)
NegHighByteMin      equ       $80                 a 16-bit value's high byte at or above it: negative (degrees made 0-359)
NightVisible12      equ       $0080               the visible masks $02B1-$02B2 with the panel dark: only <$EC's bit 7 (forced on)
NightVisible3       equ       $01                 the visible mask $02B3 with the panel dark: only <$ED's bit 0 (forced on)
NoHorizonList       equ       $0000               $0192 0: no horizon line list for the scenery's op 9 to call
NotCarry            equ       $FE                 the CC mask that clears the carry bit
NotDrawn            equ       $FFFF               the instruments' last-value caches' mark ($FF a byte, $FFFF a word): nothing drawn yet, so each redraws
Obs100Deg           equ       $32                 100 degrees in the OBS's 2-degree units
Obs180Deg           equ       $5A                 180 degrees in the OBS's 2-degree units: the reciprocal
Obs360Deg           equ       $B4                 360 degrees in the OBS's 2-degree units: a full turn
ObsShowBits         equ       $14                 the instrument mask bits 2 and 4 that let an OBS readout be drawn
ObsToAngle          equ       $016C               364 (65536 / 180): the OBS's 2-degree units to a 16-bit angle (MulU16Mid's low word <$B5)
OilPressMarkBase    equ       $4915               the oil pressure marker's column ($49, bytes) and row ($15)
OilPressRun         equ       $0A                 the oil pressure of the running engine (vOilPress's high byte)
OilPressStep        equ       $00FA               vOilPress's step toward its target an engine update (1/256 units)
OilTempHot          equ       $12                 the oil temperature with the oil overheating (DmgOilHot)
OilTempMarkBase     equ       $4115               the oil temperature marker's column ($41, bytes) and row ($15)
OilTempRun          equ       $09                 the oil temperature the running engine settles at (vOilTemp's high byte)
OilTempStep         equ       $0019               vOilTemp's step toward its target an engine update (1/256 units)
OneBlock            equ       1                   F$MapBlk's and F$ClrBlk's B: one block
OpenRead            equ       $01                 I$Open's access mode: read (READ.)
OpenUpdate          equ       $03                 I$Open's access mode: read and write (UPDAT.)
OpModeMsgLen        equ       $0059               vOpModeMsg's length in bytes
OvlF2               equ       $01                 vOvlReq 1: CMDS/f2, the editor
OvlF3               equ       $02                 vOvlReq 2: CMDS/f3, the scenery menu
OvlTypeLang         equ       $21                 an overlay's module type and language: Sbrtn+Objct
PanelBlank          equ       $00                 SetFillColor's color 0: the ADF area cleared to the panel's background
PartsMapView        equ       $12                 TblViewAircraftParts' entry 9 (byte offset): the map view's airplane symbol
PartsUpView         equ       $10                 TblViewAircraftParts' entry 8 (byte offset): the pitched-up view's parts (an empty shape in the port)
PartsUpView1917     equ       $14                 TblViewAircraftParts' entry 10 (byte offset): the pitched-up view's parts in EUROPE 1917
PausedBotRight      equ       $3037               FillRect's X for the PAUSED box: right x 48, bottom row 55
PausedTopLeft       equ       $1331               FillRect's D for the PAUSED box: left x 19, top row 49
PendMsgDelay        equ       $04                 how long a pending message stays: DelayA's count (about 0.9 s each)
PitchToSpeed        equ       $FF38               the airspeed change per pitch change (Q15 -200: pitching up slows the aircraft)
PixCenter88         equ       $80                 one half in 8.8: an edge's start x taken at its pixel's center
PixEvenNib          equ       $F0                 a screen byte's even-x pixel (high nibble)
PixOddNib           equ       $0F                 a screen byte's odd-x pixel (low nibble)
PkTextMargin        equ       $03                 the packed text's first column and first row (pixels)
PkTextRowEnd        equ       $5A                 the packed text rows' end: a row at or past it clears the view and starts at the top
PkTextRowStep       equ       $07                 the packed text's row spacing (pixels)
PkTextTokenMask     equ       $7F                 a packed text token ($80 + n) without bit 7: its dictionary index n
PkTextWrapCol       equ       $64                 the packed text's column at which the next word goes to the next row
PlotModeRecord      equ       $01                 vPlotMode ($08A4) 1: the course plotter records the course
PlotModeShow        equ       $02                 vPlotMode ($08A4) 2: the course plotter draws the recorded course
PlotScalePrecise    equ       $04                 vPlotScale ($08A7) 4, PRECISION: 1 m units, the points not divided by 16
Q15FracBits         equ       $0F                 the quotient bits a Q15 divide makes (DivQ15's loop count)
Q15Round            equ       $4080               the Q15 multiply's rounding: (P + $4080) >> 15 is FS's two roundings bit for bit
Q15Tenth            equ       $0CCC               Q15 0.1
RealityOn           equ       1                   vReality 1: reality mode on
RpmBelowZero        equ       $F0                 a tachometer stepped down to it or above went below 0 (vRpmTarget taken)
RpmIdle             equ       $0D                 13 (650 rpm, 50-rpm units): the least vRpmTarget while reality mode is off
RpmStep             equ       $02                 the tachometer's step toward vRpmTarget a timer tick (50-rpm units)
RudderMarkerAt      equ       $165A               the rudder marker's slide: byte column 22 (high), row 90 (low)
SceneryDiskMsgLen   equ       $0069               vSceneryDiskMsg's length in bytes
ScreenBytesPerRow   equ       $50                 bytes in one row of FS's CoCo screen (160 pixels, 4 bits each)
ScreenRowUp         equ       $B0                 -80: a row step up the screen (-ScreenBytesPerRow)
ScrType240          equ       0                   SS.AScrn's X: screen type 0, 320 x 240 (10 blocks)
SeasonBitWinter     equ       $01                 vSeasonBit for winter (season 1): bit 0, shifted left once a season after it
SeasonRowMask       equ       $03                 vSeason's low 2 bits: TblDaylightTimes' row (fall, 4, as row 0; 8 bytes a row)
SeasonSpring        equ       $02                 vSeason 2: spring, when carburetor ice forms
SecTicksStart       equ       $FB                 -5: vSecTicks' start, counted up to 0: 5 timer ticks to a second of FS's clock
SeekFileStart       equ       $0000               I$Seek's position 0 (X and U): the data file's start, its header
SeekIndexHi         equ       $0000               I$Seek's X, the position's high word: 0 (the block index lies in the file's first 64 KB)
ServiceRearm        equ       $02                 the scenery's service request ($013B) 2: the stopped aircraft also rearmed (1: refueled, repaired)
ShapeEnd            equ       $FFFF               a TblViewAircraftParts shape list's end word
SidBothVolOff       equ       (SID_SELECT_BOTH+$18)*256 A: both SIDs' register $18 (filter mode, volume); B: 0, volume 0 (the engine sound off)
SlewAltZero         equ       $0000               the height (<$04-<$06) and its slew rate ($0833) at the bottom: 0
SlewBandColor       equ       $00                 the slew readout band's color: FS's color 0, black
SlewBandRows        equ       $06                 the slew readout band's height in rows
SlewCtlZero         equ       $0000               slew mode's first frame (vSlewEntry): the controls and the slew rates zeroed, vSlewEntry cleared
SlewEntrySet        equ       $01                 vSlewEntry 1: slew mode's next frame is its first (it zeroes the controls)
SlewStepNegOne      equ       $FFFF               -1 in the slew step's 24 bits (D, A also into <$9A): shifted left to -2^n
SlewStepZero        equ       $0000               0 in the slew step's 24 bits (D, A also into <$9A): ones shifted in make 2^n-1
SlideMarkerCenter   equ       $07                 the aileron and rudder markers' center position (0-15)
SlideMarkerRows     equ       $02                 a horizontal slide marker's height in rows
SlideMarkerWide     equ       $FF                 a slide marker 2 pixels wide (0: 1 pixel)
SlipBallCenter      equ       $09                 the slip ball's center position (positions 1-17)
SlipBallCol0        equ       $03                 the slip ball's x for position 0 (x = position + 3)
SlipBallInitPos     equ       $00                 the slip ball's position at panel init: 0 (x 3)
SlipBallLimit       equ       $08                 the slip ball held to +8 from its center
SlipBallLimitNeg    equ       $F8                 the slip ball held to -8 from its center
SlipBallRowOfs      equ       $1950               the slip ball's screen offset: row 81 x 80 bytes
SlipBias            equ       $7F                 127: the signed slip value made unsigned for the two shifts
SlipBiasDiv4        equ       $1F                 31: SlipBias / 4, taken back off after the two shifts
SpdCurveFracMask    equ       $0F                 vAirspeed's high byte, its low nibble: the place within a speed curve step (16 m/s)
SplashFrames        equ       $03                 the frames on water before the splash crash (vSplashCount)
SsFClr              equ       $81                 VRN's SetStat SS.FClr ($81): FS2's frame signal set (Y not 0) or cleared (Y 0)
SsFScrn             equ       $8D                 SetStat SS.FScrn ($8D): a bitmap freed (Y)
SsMontr             equ       $92                 SetStat SS.Montr ($92): the monitor type (X)
SsOpt               equ       $00                 GetStat / SetStat SS.Opt ($00): the path's 32 option bytes
SsReady             equ       $01                 GetStat SS.Ready ($01): carry clear when a key is waiting
SsVCtr              equ       $80                 VRN's GetStat SS.VCtr ($80): the ticks counted since the last read, the count cleared
StallAoAMax         equ       $24                 the angle of attack ($074B's high byte) at which the wing stalls
StallAoAMin         equ       $E7                 the negative angle of attack ($074B's high byte, -25) below which the wing stalls
StallNoLiftInit     equ       $0F                 vStallNoLift's count ($089D) at a stall: the steps with no lift
StallNone           equ       $00                 B 0: no stall (the stall path's B is StallTimeInit; ComputeAeroLift's load overwrites both)
StallTimeInit       equ       $06                 vStallTime's count ($0898) at a stall or a flight outside the envelope
StdInPath           equ       $00                 path 0, stdin: the keyboard (FsKeyPath)
StdOutPath          equ       $01                 path 1, stdout: the display (FsPath)
StepFlip            equ       $02                 2: turns the one-position step that follows the other way (-1 into +1, +1 into -1)
StnNormBias         equ       $10                 16: a station delta's high byte plus it, so -16 to 16 tests as 0 to 32
StnNormSpan         equ       $21                 33: a biased station delta high byte below it (-16 to 16) is shifted left again
TextClearLen        equ       $0003               vTextClearStr's clear-screen and cursor-off codes FS writes: 3 bytes (not the palette records)
ThrottleJoyScale    equ       $82                 the left stick's y x 4 (0-252) x it: the throttle, 0-$7FF8
ThrottleMarkBase    equ       $3651               the throttle marker's column ($36, bytes) and base row ($51) on the CoCo panel
ThrottleMarkIdle    equ       $00                 the throttle marker's position 0: a closed throttle (vThrottle / 4)
ThrottleMarkRows    equ       $03                 the throttle marker's height in rows
ThrustRpmMin        equ       $0E                 14 (700 rpm, 50-rpm units): an RPM below it makes no thrust
ThrustRpmScale      equ       $07D0               Q15 0.061: the RPM (50-rpm units, <$AF's high byte) to thrust, before the air density
TickQ15             equ       $0222               one clock tick (1/60 s) in Q15 seconds: the time step per /FTDD tick
TimeStepMaxHi       equ       $7F                 the time step's high byte when it reached 1 s ($077C kept under 1 s, Q15)
TrimMarkBase        equ       $3624               the elevator trim marker's column ($36, bytes) and base row ($24)
TrimMarkMid         equ       $05                 the elevator trim marker's middle position
TrimMarkRows        equ       $02                 the elevator trim marker's height in rows
TurnCoordColor      equ       $FF                 color 15 (white; SetLineColor keeps the low nibble): the turn coordinator airplane
TurnCoordErase      equ       $00                 color 0 (black, the dial's face): erases the turn coordinator airplane
TurnCoordLast       equ       $0F                 the turn coordinator airplane's last index
TurnCoordMid        equ       $08                 the turn coordinator airplane's wings-level index (8 of 0-15)
TurnCoordX          equ       $0D                 the turn coordinator's center x
TurnCoordXY         equ       $0D47               the turn coordinator's center as DrawLine's X: x 13 (high), y 71 (low)
TurnCoordY          equ       $47                 the turn coordinator's center y
TwoSecondBit        equ       $01                 the seconds count's ($028A) bit 0: the elevator drift and the engine run when it is 0, every 2 s
TwoSpaces           equ       $2020               two ASCII spaces: the DME's digits blanked
TwoSpanXings        equ       $04                 polygon fill: 4 X crossings on a row, two spans
TxtBlack            equ       $0000               text color word: FS's color 0, black (erase), in every pixel
TxtBlue             equ       $6666               text color word: FS's color 6, blue, in every pixel
TxtGray             equ       $5555               text color word: FS's color 5, gray, in every pixel
TxtGreen            equ       $BBBB               text color word: FS's color 11, green, in every pixel
TxtRed              equ       $4444               text color word: FS's color 4, red, in every pixel
TxtWhite            equ       $FFFF               text color word: FS's color 15, white, in every pixel
TxtYellow           equ       $9999               text color word: FS's color 9, yellow, in every pixel
UpperCaseMask       equ       $DF                 a letter's bit 5 cleared: its upper case
VertMarkerRows      equ       $03                 the vertical slide marker's height in rows
ViewBitmap0         equ       $0000               SS.FScrn's Y: bitmap 0, the view's first (fsw's ExitAll frees bitmaps 1 and 2)
ViewBotRight        equ       $9F62               FillRect's X for the view: right x 159 ($9F), bottom row 98 ($62)
ViewHdgZero         equ       $0000               the view's heading (<$1C) in the straight-down and pitched-up views: 0 (the heading goes in as the bank)
ViewScrNone         equ       $0000               vViewScr's value: 0, the view has no memory (its addresses row*80 + x/2 only name rows)
ViewTopLeft         equ       $0000               FillRect's D for the view: left x 0, top row 0
VsiCenter           equ       $4B42               the VSI's center: row 75 (high), x 66 (low)
VsiLimit            equ       $09                 the vertical speed's high byte held to +9 (the VSI's end)
VsiLimitNeg         equ       $F7                 the vertical speed's high byte held to -9 (the VSI's end)
VsiZeroPos          equ       $83                 131: the VSI needle's position at 0 (43, by 9 o'clock) plus one turn (88)
WaterColorWord      equ       $2222               the water's color word (FS's color 2, blue, in all four pixels): the probe under the nose
WbScrBlkCount       equ       3                   the flight screen's RAM blocks (F$AllRAM): the K2's clouds', the panel's, the window's second
WindmillRestartSpd  equ       $25                 the airspeed (m/s, vAirspeed's high byte) at which the windmilling propeller restarts the engine
WindmillTblLast     equ       $1F                 TblWindmillRpmByAirspeed's last entry (31; the index is the airspeed / 4)

tylg                set       $11
atrv                set       $80
size                equ       $4000
ModBase             equ       $A000               the address the module runs at

                    mod       eom,name,tylg,atrv,start,size
                    fcb       $00
name                fcs       /FS/
WbPart              set       1
                    use       fs_wb.asm           the WildBits platform layer, part 1
start               equ       *

                    use       fs_core.asm
                    use       fs_draw.asm
                    use       fs_panel.asm
                    use       fs_flight.asm
                    use       fs_systems.asm
WbPart              set       2
                    use       fs_wb.asm           the WildBits platform layer, part 2

                    emod
eom                 equ       *
                    end
