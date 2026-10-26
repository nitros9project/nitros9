********************************************************************
* fswc - FS (Flight Simulator II), WildBits port: fsw's first code block
*
* A raw binary, not a module: fsw's XInit reads /dd/fs2/fswc into a RAM block of its own (BlkInit), and CCall maps
* it at FsxBase (in place of the panel's block) only while one of its entries runs, the Studio-9 way: code that is
* on no hot path lives in 8 KB blocks of its own and fsw keeps only the code inside the frame. Its entries (the
* table first, fs_wb.d's Fc names) are reached through fsw's stubs.

                    nam       fswc
                    ttl       FS2 fsw code block 1

                    ifp1
                    use       defsfile
                    use       fs_wb.d
                    endc

* Constants: the values this module's instructions use, by name (fs_wb.d holds the addresses)
ActEvClrTo          equ       2                   the actor's plan event: cleared for takeoff (TwAct)
ActEvGoAround       equ       4                   the actor's plan event: go around (TwAct)
ActEvLuaw           equ       1                   the actor's plan event: line up and wait (TwAct)
ActPhClimb          equ       2                   the actor's phase: liftoff, climbing out (the first in the air; TwAct)
ActPhFinal          equ       4                   the actor's phase: on final (TwAct)
ActPhGoAround       equ       6                   the actor's phase: going around (TwAct)
ActPhLineUp         equ       7                   the actor's phase: lining up (TwAct)
ActPhPattern        equ       3                   the actor's phase: in its pattern (TwAct)
ActPhRollout        equ       5                   the actor's phase: touchdown, rolling out (TwAct)
ActPhTakeoff        equ       1                   the actor's phase: lined up, rolling for takeoff, rotating (TwAct)
AdcCarryOnly        equ       0                   adc's operand 0: only the carry added (the low byte's carry into the high byte)
AirRange            equ       18500               Near: the tower's reach in the air, meters east and north (10 nm)
AirspeedOvfHi       equ       $64                 FS's airspeed after an overflow: $64 in its high byte (100 m/s; ComputeAeroAddSpeed's clamp)
AltLetterAdd        equ       $40                 Alt+letter: the upper-case letter + $40, as the K2 driver sends it (Alt+P = $90)
AltLetterFirst      equ       'A                  the first letter Alt makes a key of (upper case)
AltLetterLast       equ       'Z                  the last letter Alt makes a key of (upper case)
AltOnGround         equ       $0301               vAlt's low word on the ground ($0301, as fd's start state)
Angle8Quarter       equ       $40                 90 degrees in an 8-bit angle (256 a turn): its bit 6, the 2nd and 4th quarter turns
Angle8QuarterMask   equ       $3F                 an 8-bit angle's place within its quarter turn (256 a turn)
AtisObsMin          equ       51                  the ATIS observation's minute past the hour
AtisQuietGap        equ       3                   seconds of quiet after the tower's speech before the ATIS again (TwAtT)
AtisRepeat          equ       60                  seconds from an ATIS broadcast to the next (TwAtT)
AudCom1             equ       1                   FswAud's bit 0: COM1 heard (the first button's bit)
AudCom2             equ       2                   FswAud's bit 1: COM2 heard
AudComs             equ       3                   FswAud's COM buttons: b0 COM1, b1 COM2
AudNav1             equ       4                   FswAud's bit 2: NAV1 heard (its Morse ident)
AudNav2             equ       8                   FswAud's bit 3: NAV2 heard (its Morse ident)
BackBitmap          equ       1                   bitmap 1: the first back buffer
BcdLoDigit          equ       $0F                 a BCD byte's low digit
BcdMinusOne         equ       $99                 added to a BCD byte, then daa: the byte one less
BcdPlusOne          equ       1                   added to a BCD byte, then daa: the byte one more
BgRgbLen            equ       3                   GpuF.FixN's U: 3 bytes, the background's blue, green, red
BmCfgHires4         equ       $0100               SS.BmCfg's R$U: HIRES4 on (high byte 1), palette group 0 (low byte)
BmCfgKeep           equ       $FFFF               SS.BmCfg's X or U: both bytes $FF, both fields kept as they are
BmCfgKeepField      equ       $FF                 SS.BmCfg: a byte $FF, that field kept as it is (here the CLUT)
BmClearAllRows      equ       0                   SS.BmClear's U: first row 0 (high), rows 0 = to the end (low): every row
BmClearPoll         equ       $7000               SS.BmClear's R$X: fill value 0, wait mode 7 (DmaWt.Poll): back when the fill is done
CeilMinFt           equ       100                 Agl: the lowest ceiling said, feet above the field
ChrCR               equ       $0D                 a carriage return: the end of an OS-9 path name or text line
ChrDigit0           equ       '0                  the character 0: an ASCII digit minus it is its value
ChrSpace            equ       $20                 a space: the pad after a two-letter ident (MoIds)
ClockBehind         equ       6                   six o'clock, behind: traffic below it is on the right
ClockCountMask      equ       $0F                 Danger: the clock hour count's 4 bits (0-12)
ClockFaceHours      equ       12                  a clock face's hours: 0 said as 12, 12 and up wrap
ClockHalfDeg        equ       15                  half a clock hour in degrees: (bearing + 15) / 30 rounds
ClockHourDeg        equ       30                  a clock hour in degrees
ClockHours          equ       24                  24: the hours in a day, the hour after 23 is 0
CloudsOnBit         equ       1                   vClouds' low byte, bit 0: the scenery's clouds on (K2 F7 / Alt+C toggle it)
Co2MdKhz            equ       2                   Co2Md: COM2's kHz being tuned
Co2MdMhz            equ       1                   Co2Md: COM2's MHz being tuned
CockpitPrCY         equ       82*16               the cockpit view's center row 82 (ViewCY) in sixteenths: FswPrCY
CockpitRows         equ       164                 the cockpit view's rows (FswVRows; fsw's ViewRows)
CocoPixLastDot      equ       3                   a CoCo pixel's last dot of its 4 (x 4 + 3)
CocoViewRows        equ       99                  the CoCo view's rows (0-98): CRow's B x FswVRows / 99
ColdestHour         equ       5                   SayTemp: the day's coldest hour (05)
ColorNibble         equ       $0F                 a color 0-15 in a byte's low nibble (FS's color patterns repeat it in each nibble)
Com2MhzHigh         equ       $36                 COM2's highest MHz past 100, BCD: 136
Com2MhzLow          equ       $18                 COM2's lowest MHz past 100, BCD: 118
Com2MhzOver         equ       $37                 COM2's MHz past 100, BCD: 137, one past the band's top
CoolingDen          equ       7                   SayTemp: the cooling fraction's divisor (14 hours / 2)
CoolingNum          equ       5                   SayTemp: hours past 15 x 5 / 7: x 10 / 14, in tenths of the 14 cooling hours
CoolingRound        equ       3                   SayTemp: the cooling fraction rounded: (h x 5 + 3) / 7
DangerFinAgl        equ       300                 Danger: a final's height above ground (m) under which it is watched
DashBitmap          equ       2                   bitmap 2: the dash's (SS.BmCfg's R$Y)
DashBitmapAlt       equ       1                   bitmap 1: the dash's second buffer while the GPU draws the view (SS.BmCfg's R$Y)
DashLayer           equ       0                   SS.PScrn's X: layer 0, the top: the dash's
DecBase             equ       10                  decimal: a number from 10 on takes two digits (Tens)
Deg2Turn256         equ       182                 degrees to 1/256 turn: x 182 / 256 (256 / 360)
DepConfRange        equ       100                 DepConf: the actor's farthest distance considered, FswTfDst's 100 m (10 km)
DepPathHalfW        equ       1500                DepConf: the departure path's half width, meters from the centerline
DewSpreadMax        equ       3                   SayTemp: the dew point's spread under a low ceiling, degrees C at most
EngCutoffBase       equ       $10                 the engine noise's filter cutoff at rest (SID register $16; + the airspeed / 2)
EscPalette          equ       $31                 the CoCo's palette escape code (ESC $31 pp cc)
EscPalTail          equ       3                   a palette escape's bytes after its ESC: $31, pp, cc (fewer left: no escape)
EsRpmFactor         equ       117                 voice 1's frequency per RPM step ($072C, 50 rpm), x 4: Fn = $072C x 117 / 4
EsVolBase           equ       22                  the engine volume before the RPM's fall (22 - 3 x $072C / 8)
EsVolMax            equ       15                  the engine's highest volume: the SID's full 15
EsVolMin            equ       3                   the engine's lowest volume (SID volume, 0-15)
EsVolSlope          equ       3                   the engine volume's fall: 3 x the RPM step ($072C) / 8
FieldRange          equ       5000                Near: at the field, meters east and north of its reference (5 km)
FinCrossBase        equ       150                 OnFin: the centerline's tolerance (m), plus an eighth of the distance
FinFarAl            equ       -9000               OnFin: the farthest along a final, meters (9 km short of the threshold)
FinMaxAgl           equ       800                 OnFin: the highest height above ground on a final (m)
FsTickRange         equ       5                   FS's timer FsTick: its 5 values $FB-$FF (the wrap of its change since the last frame)
FtHundred           equ       100                 SayFt: feet in a hundred
FtHundredsPerK      equ       10                  SayFt: hundreds in a thousand
FtRound             equ       50                  SayFt: half a hundred feet, the hundreds rounded
FtThousand          equ       1000                SayFt: feet in a thousand
FullViewPrCY        equ       120*16              the whole-screen view's center row 120 in sixteenths: FswPrCY
FullViewRows        equ       240                 the whole-screen view's rows (FswVRows; the dash hidden)
GlyphLeftPix        equ       4                   a glyph row's left pixel bit (bit 2), shifted right for the next two
GlyphRowMask        equ       $07                 one glyph row: its 3 pixel bits (bit 2 the left one)
GlyphStopBit        equ       $80                 the glyph word's stop bit (bit 15) above its five 3-bit rows
GlyphStopEnd        equ       1                   the glyph word with its five rows shifted out: only the stop bit left
GoAroundRepeat      equ       6                   seconds before the next go-around call (TwGaT)
GpuCtl256           equ       $02                 Gpu.Ctrl b1: the 320 x 256-color view, 480 lines (clear: 640 x 16)
GpuFixVicky         equ       GpuF.FixN*256       SS.Gpu's X: GpuF.FixN (high byte) on VICKY's fixed registers (low byte 0)
GpuOpRect           equ       $02                 the GPU record RECT's opcode: rows Y0-Y1, dots X0-X1, filled
IbDotCount          equ       1                   SS.BmLine's U: one record, IbDot
K2FKeyToFs          equ       $10                 the K2's F1/F2 ($A1/$A2) to FS's codes ($B1/$B2, as the PS/2 driver sends them)
KeyAltC             equ       $83                 Alt+C after the Alt mapping (C + $40): the scenery's clouds on or off
KeyAudFirst         equ       '1                  the audio panel's first button key: 1 (COM1)
KeyAudLast          equ       '6                  the audio panel's last button key: 6 (MKR)
KeyCtrlK            equ       $0B                 Ctrl+K ($0B): COM2's MHz, again its kHz
KeyCtrlR            equ       $12                 Ctrl+R ($12; the driver's Ctrl+down too): arms the audio panel's 1-6
KeyF3               equ       $B5                 F3 as FS takes it ($B5): overlay 4, CMDS/f5, the airport menu
KeyJr2Talk          equ       'O                  the Jr2's talk key: O
KeyJr2TalkLc        equ       'o                  the Jr2's talk key unshifted: o
KeyK2F1             equ       $A1                 the K2's F1 ($A1)
KeyK2F2             equ       $A2                 the K2's F2 ($A2)
KeyK2F3             equ       $A3                 the K2's F3 ($A3): the airport menu
KeyK2F5             equ       $A5                 the K2's F5 ($A5): the tower's talk key
KeyK2F7             equ       $A7                 the K2's F7 ($A7): the scenery's clouds on or off
KeyK2F8             equ       $A8                 the K2's F8 ($A8): the textured ground on or off
KeyPs2F3            equ       $B3                 the PS/2 keyboard's F3 ($B3): the airport menu
KeyTuneDown         equ       ',                  the , key: COM2's MHz or kHz one step down (Co2Step)
KeyTuneUp           equ       '.                  the . key: COM2's MHz or kHz one step up (Co2Step)
KeyXpdr             equ       '-                  the tower key -: the XPDR's digits selected (XpSel)
LastHour            equ       23                  the day's last hour (the one before 0)
LoadKindCrash       equ       1                   vLoadKind 1: the crash reset (StartPos's A, from fsw's ModeLd)
LowCeilingFt        equ       5000                SayTemp: a ceiling below it (ft) holds the dew point near the temperature
LpcEntSize          equ       6                   tower.lpc's index entry: a 32-bit offset, a 16-bit length (bytes)
LpcFrame            equ       15                  an LPC frame (SP0250), bytes
LpcHdrSize          equ       2                   tower.lpc's header: its piece count, a word (bytes; the index follows)
MoDashLen           equ       3                   Morse: a dash's timer steps
MoDotLen            equ       1                   Morse: a dot's timer steps
MoElemGap           equ       1                   Morse: timer steps between a letter's elements
MoIdentGap          equ       25                  Morse: timer steps after the ident before it repeats
MoIdLen             equ       3                   Morse: an ident's letters at most (MoIds)
MoIdNone            equ       0                   Morse: no ident (MoId, MoFind, MoLook)
MoLetBase           equ       'A                  MoLet's first letter: A (a letter minus it: its MoLet index)
MoLetterGap         equ       3                   Morse: timer steps between letters (and before an ident's first)
MoLetToDig          equ       'A-'0               a letter's MoLet index back to a digit's MoDig index ('A - '0)
MoStopBit           equ       $80                 MoBits with only its stop bit left: no element of the letter left
MoToneHigh          equ       $6E/16              the PSG's second byte for the Morse tone: N's high 6 bits
MoToneLatch         equ       $80+($6E&$0F)       the PSG's first byte for the Morse tone: tone 0's frequency, N's low 4 bits
MoToneOn            equ       1                   MoOn: the Morse tone sounds
NavRx1              equ       1                   FsNavRx's bit 0: NAV1 hears its station
NavRx2              equ       2                   FsNavRx's bit 1: NAV2 hears its station
NegCarry            equ       1                   the 1 that completes a two's-complement negation (coma, comb)
NoNamePiece         equ       $FF                 a runway end's unused name piece (twr_data.asm TwEnds: $FF none)
ObsMinOnes          equ       1                   the ATIS observation minute's ones digit (:51)
ObsMinTens          equ       5                   the ATIS observation minute's tens digit (:51)
OneSixteenth        equ       1                   one sixteenth of a row: the rows x 16 less it is Proj's last row (FswVMaxY)
P_C_BASE            equ       P_C1-1              the piece before P_C1: + a clock hour (1-12), its o'clock piece
P_MI_BASE           equ       P_MI1-1             the piece before P_MI1: + the miles (1-5), its miles piece
P_U_C_BASE          equ       P_U_C1-1            the piece before P_U_C1: + a clock hour (1-12), its urgent o'clock piece
PalRecLen           equ       4                   a palette record's bytes at WbPalRecs (ESC $31 pp cc; blue, green, red after WbPalette)
PBarFailRow         equ       237                 the PFail bar's row in bitmap 2
PBarLeftX           equ       0                   a PBar record's X0: the bar's left end, dot 0
PBarRedLine         equ       $0200               a PBar record's bytes 6-7: color 2, red in the power-on text palette, and opcode 0, LINE
PBarStepDots        equ       40                  a PBar step's length in dots
PBarStepRow         equ       239                 the PStep bar's row in bitmap 2
PsgTone0Att4        equ       $94                 the PSG's command byte: tone 0's attenuation 4
PsgTone0Off         equ       $9F                 the PSG's command byte: tone 0's attenuation 15, off
QuotStart           equ       0                   a division by repeated subtraction: the quotient's start
RadioRepeatTicks    equ       $14                 vRepeatTicks for a radio select key: the ticks a quick second press steps to the next digit, as FS's own keys
RealityOn           equ       1                   vReality 1: reality mode on
RollingSpd          equ       1317                Danger: 10 knots in 1/256 m/s, rolling on a runway above it
RollOutSpd          equ       3951                30 knots in 1/256 m/s: rolled out below it, off the runway
RwyBusyDep          equ       1                   RwyBusy's B: a departure (0 an arrival)
RwyEdgeMargin       equ       15                  OnEnd: meters past the runway's half width still on it
RwyHdgTol           equ       21                  HdgOK: 30 degrees in 1/256 turn: a heading within it of a runway end's
SayCalmKt           equ       3                   SayWind: a wind below it (knots) is said calm
ScrType240          equ       0                   SS.AScrn's X: screen type 0, 320 x 240 (10 blocks)
SeasonMask          equ       3                   FS's season, its low 2 bits: winter 1, spring 2, summer 3, fall 0
SeasonWinter        equ       1                   FS's season: winter
SeekOfsHi           equ       0                   I$Seek's X: the offset's high word, 0 (the index in the file's first 64 KB)
SidCutoffHi         equ       $16                 SID register $16: the filter cutoff's high 8 bits
SidLowPass          equ       $10                 SID register $18 bit 4: the low-pass filter mode
SidV1FreqHi         equ       1                   SID register 1: voice 1's frequency, high byte
SidV2FreqHi         equ       8                   SID register 8: voice 2's frequency, high byte
SidV2FreqLo         equ       7                   SID register 7: voice 2's frequency, low byte
SidV3FreqHi         equ       15                  SID register 15: voice 3's frequency, high byte
SqChkDelay          equ       30                  seconds from a squawk's assignment to its check (TwSqT)
SqFirstCount        equ       5                   NewSq: the first digit's choices (2-6)
SqFirstMin          equ       2                   NewSq: the first digit's lowest
SqOctalMask         equ       7                   a squawk digit: octal 0-7
SqRecheck           equ       10                  seconds after a matching squawk before the next check (TwSqT)
SqRemindRepeat      equ       60                  seconds after a wrong-squawk reminder before the next check (TwSqT)
StepsPerSec         equ       5                   FS's timer steps a second
StopRepeat          equ       6                   seconds before the next stop call (TwStT)
StreamMax           equ       255                 TwStream: a read's most bytes
StreamMinFree       equ       32                  TwStream: the least room (bytes) in VRN's buffer for another read this frame
TenthsWhole         equ       10                  SayTemp, Blend: tenths in the whole day's fraction (TwF)
TfDstMeters         equ       100                 FswTfDst's unit: meters
TfNmPer100m         equ       54                  nautical miles in 100 m (FswTfDst's unit), x 1000
TfNmRound           equ       500                 TrafAdv: half a mile in thousandths, the miles rounded
TfNmScale           equ       1000                TrafAdv: thousandths in a nautical mile
TrafAdvRange        equ       93                  TrafAdv: the traffic advisory's reach, FswTfDst's 100 m (5 nm)
TrafAdvRepeat       equ       30                  seconds before the next traffic advisory (TwTrT)
TrafAlertRange      equ       10                  Danger's traffic alert: the actor within it, FswTfDst's 100 m (1 km)
TrafAlertRepeat     equ       20                  seconds before the next traffic alert (TwTaT)
TrafMilesMax        equ       5                   TrafAdv: the most miles said
TrafMilesMin        equ       1                   TrafAdv: the fewest miles said
TwAllRwys           equ       $FF                 TwMask, TwFm: every runway (a bit a runway number)
TwAtPlOn            equ       1                   TwAtPl: the ATIS broadcast queued or speaking
TwBusyYes           equ       1                   TwBusy's A: the tower talks (Z clear)
TwGndOn             equ       1                   GndNow's A, TwGnd: on the ground
TwHdAny             equ       1                   TwHd: any heading (RwyAny)
TwInAtOn            equ       1                   TwInAt: inside TwAtisS
TwInitOpen          equ       1                   TwInit: tower.lpc open, its index read
TwModeAtis          equ       2                   TwFind's B, TwMode: the ATIS frequency
TwModeGround        equ       3                   TwFind's B, TwMode: ground control's frequency
TwModeTower         equ       1                   TwFind's B, TwMode: a tower frequency
TwNoEnd             equ       $FF                 no runway end (FinEnd, RwyEnd, RwyAny; TwRwy, TwOnEnd unset)
TwNoLayer           equ       $FFFF               Agl: no cloud layer (its top not above its bottom)
TwNoPhase           equ       $FF                 ActPh: no actor phase (the plan point outside TwAct)
TwPendNone          equ       0                   TwPend: nothing pending in VRN's buffer
TwQMask             equ       63                  TwQ's index wrap: 64 pieces
TwTimerCount        equ       6                   TwSecond's second timers, TwGaT to TwTrT
TwTkOneStep         equ       1                   TwTkN when FsTick's change is out of range (5 or more): one step
TxBrkBoth           equ       3                   FswTxBrk 3: both brakes (b0 left, b1 right)
TxBrkLeft           equ       1                   FswTxBrk 1: the left brake (b0)
TxBrkOne            equ       TxBrkDec/2          one brake's slowing: half of both's (1.25 m/s2)
TxBrkRight          equ       2                   FswTxBrk 2: the right brake (b1)
TxDivBits           equ       32                  TxDiv's steps: the dividend's 32 bits
TxDivRemInit        equ       0                   TxDiv's remainder at the start: 0
TxRudderFull        equ       124                 the rudder's high byte at full deflection ($7C): the turn's share is |rudder| / it
TxSpeedZero         equ       0                   the airspeed stopped: 0 (a step below 0 stops there)
TxThrottle1         equ       8                   the throttle's first taxi step (vThrottle's high byte, steps of 8): below it idle
TxThrottle2         equ       16                  the throttle's second step: from it FS's own speed step (8-15 taxi)
TxTurnDivHi         equ       $0065               TaxiYaw's dividend 6,674,432 ($0065D800: 2.5 m/s2 over the speed, FS's angle a second), its high word
TxTurnDivLo         equ       $D800               TaxiYaw's dividend 6,674,432 ($0065D800), its low word
UnstableAgl         equ       150                 Danger: below it (m above ground) a final faster than UnstableSpd is unstable
UnstableSpd         equ       18436               Danger: 140 knots in 1/256 m/s, an unstable final's speed
UpperCaseMask       equ       $DF                 a letter's bit 5 cleared: its upper case
UseEndCalmKt        equ       5                   UseEnd: a surface wind below it (knots) is calm: the calm heading's end
UseEndWorst         equ       $FF                 UseEnd: TwBest's start, more than any heading difference
UtcOfsDst           equ       5                   Chicago's hours behind UTC in spring, summer and fall (daylight time)
UtcOfsWinter        equ       6                   Chicago's hours behind UTC in winter (standard time)
ViewBitmap0         equ       0                   bitmap 0: the view's first
ViewLayer           equ       1                   SS.PScrn's X: layer 1, the view's (below the dash)
WarmingHours        equ       10                  SayTemp: hours from the coldest (05) to the warmest (15)
WindDirDiv          equ       320                 SayWind: tens of degrees = direction x 45 / 320
WindDirMul          equ       45                  SayWind: tens of degrees = (direction x 45 + 160) / 320 (1/256 turn)
WindDirRound        equ       160                 SayWind: half of WindDirDiv, the tens of degrees rounded
WindKnotsMask       equ       $7F                 the wind's knots byte (the rest of 100) without bit 7
WindNorth           equ       36                  SayWind: north in tens of degrees (0 said as 36)
XpItemFirst         equ       8                   FS's radio item of the XPDR's first digit ($00EA: items 8-11)
XpItemThird         equ       10                  FS's radio item of the XPDR's third digit (the last with a next one)
XRowBit8            equ       $80                 480 lines: a row's bit 8, in the X word's bit 15 (its high byte's bit 7)


                    org       FsxBase
                    jmp       SceneLoad           FcSceneLoad
                    jmp       Scrub               FcScrub
                    jmp       TaxiSpd             FcTaxiSpd
                    jmp       TaxiYaw             FcTaxiYaw
                    jmp       StartPos            FcStartPos
                    jmp       Tower               FcTower
                    jmp       TwKey               FcTwKey
                    jmp       KeyMap              FcKeyMap
                    jmp       ViewSet             FcViewSet
                    jmp       Glyph               FcGlyph
                    jmp       Rect                FcRect
                    jmp       PBar                FcPBar
                    jmp       InitBm              FcInitBm
                    jmp       DashBm              FcDashBm
                    jmp       HzBg                FcHzBg

* KeyMap (FcKeyMap: fsw's KeyMap, the end of PollKeyRead, through CCall; moved from fsw 2026-10-21 for its room),
* for FS and its overlays alike: the WildBits keyboards' codes made the ones FS2
* acts on. The drivers send arrows and BREAK unmodified, with Shift/Ctrl/Alt kept beside each character for
* SS.KySns (grfdrv256 answers it for the last character read); FS2 expects the CoCo 3 keyboard's own codes:
*   arrows, BREAK   Shift / Ctrl versions from KmMod (up $1C/$13, down $1A/$12, left $18/$10, right $19/$11,
*                   BREAK $03/$1B)
*   K2 F1/F2        $A1/$A2 -> $B1/$B2 (the PS/2 driver sends $B1/$B2 already)
*   Alt+letter      uppercase + $40, as the K2 driver makes it (the PS/2 driver leaves the letter): Alt+P = $90,
*                   FS's quit, on both
*   K2 F8 ($A8; FS has no use for it) switches the textured ground (FswGdOn: fsw's GdCall, the K2's GPU) and is
*                   not passed on.
*   F3 (K2 $A3 / PS/2 $B3) -> $B5: FS requests overlay 4, CMDS/f5, the airport menu (Roger 2026-10-25; it was F4,
*                   PS/2 Shift+F2)
*   K2 F7 / Alt+C ($A7 / $83, 2026-10-22) switch the scenery's clouds (vClouds) and are not passed on
* Exit as PollKeyRead: B = the key (also in FsKey), flags from B; A, X, Y kept.
KeyMap              pshs      a,x,y
                    ldb       >FsKey
                    cmpb      #KeyK2F8            K2 F8: the textured ground on / off
                    beq       km8@
                    cmpb      #KeyK2F3            F3 (K2 $A3, PS/2 $B3): the airport menu (CMDS/f5: FS's overlay 4, key $B5)
                    beq       km6@
                    cmpb      #KeyPs2F3
                    bne       km0@
km6@                ldb       #KeyF3
                    bra       km7@
km0@                cmpb      #KeyK2F1
                    blo       km1@
                    cmpb      #KeyK2F2
                    bhi       km1@
                    addb      #K2FKeyToFs         K2 F1/F2
                    bra       km7@
km1@                ldx       #KmMod
km2@                cmpb      ,x
                    beq       km3@
                    leax      4,x
                    tst       ,x
                    bne       km2@
                    pshs      b                   a letter with Alt?
                    andb      #UpperCaseMask
                    cmpb      #AltLetterFirst
                    blo       km5@
                    cmpb      #AltLetterLast
                    bhi       km5@
                    bsr       KeySense
                    bita      #KsAlt
                    beq       km5@
                    addb      #AltLetterAdd
                    leas      1,s
                    bra       km7@
km5@                puls      b
                    bra       km7@
km3@                bsr       KeySense            an arrow or BREAK: its Shift / Ctrl code
                    bita      3,x                 only with the arrow's own SS.KySns bit: Ctrl+L, J, H, I send the
                    beq       km7@                arrows' codes without it ($0C Ctrl+L: FS's lights), passed as sent
                    bita      #KsCtrl
                    beq       km4@
                    ldb       2,x
                    bra       km7@
km4@                bita      #KsShift
                    beq       km7@
                    ldb       1,x
km7@                cmpb      #KeyK2F7            K2 F7, or Alt+C ($83 on both keyboards after the Alt mapping):
                    beq       kmc@                the clouds on / off (FS ignores both codes)
                    cmpb      #KeyAltC
                    beq       kmc@
                    stb       >FsKey
                    tstb                          the tower's keys noted (fswc's TwKey: B = 0 for a key it keeps)
                    beq       km9@
                    lbsr      TwKey
km9@                
                    tstb
                    puls      a,x,y,pc
km8@                lda       >FswGdOn            off, or back on with the value it had (F2's GROUND TEXTURE shows it)
                    beq       km8a@
                    sta       KmGd
                    clra
                    bra       km8b@
km8a@               lda       KmGd
km8b@               sta       >FswGdOn
                    clrb
                    stb       >FsKey
                    puls      a,x,y,pc
kmc@                lda       >vClouds+1          the scenery's clouds (sf_clouds.py: bit 0 of vClouds), not passed on
                    eora      #CloudsOnBit
                    sta       >vClouds+1
                    clrb
                    stb       >FsKey
                    puls      a,x,y,pc

* KeySense: A = the Shift/Ctrl/Alt bits of the character just read (SS.KySns), 0 if the terminal gives none.
* B kept.
KeySense            pshs      b
                    lda       >FsKeyPath
                    ldb       #SS.KySns
                    swi2
                    fcb       I$GetStt
                    bcc       ks1@
                    clra
ks1@                puls      b,pc

KsShift             equ       %00000001           SS.KySns bits
KsCtrl              equ       %00000010
KsAlt               equ       %00000100
* key, its Shift code, its Ctrl code (the CoCo 3 keyboard's)
* KmMod: the key, its Shift and Ctrl codes, its SS.KySns bit (the drivers set it with the arrow; BREAK: any bit)
KmMod               fcb       $0C,$1C,$13,%00001000   up
                    fcb       $0A,$1A,$12,%00010000   down
                    fcb       $08,$18,$10,%00100000   left
                    fcb       $09,$19,$09,%01000000   right; Ctrl stays $09: FS's right-arrow handler toggles carb
*                                                 heat itself when SS.KySns has Ctrl ($11 has no handler in FS's table)
                    fcb       $05,$03,$1B,$FF     BREAK
                    fcb       0
KmGd                fcb       1                   the textured ground's mode F8 turns back on (KeyMap)

* ViewSet (FcViewSet, fsw's ViewGeo on a change; A = 0 the cockpit view, 1 the whole screen): fsw's VRows (164 or
* 240), Proj's center (FswPrCY: row 82 or 120, sixteenths) and last row (FswVMaxY); then fsw's ViewSet has fsx's
* GpView set the GPU's and the SceneEngine's view from them. Registers clobbered.
ViewSet             ldb       #CockpitRows
                    ldx       #CockpitPrCY
                    tsta
                    beq       vs1@
                    ldb       #FullViewRows
                    ldx       #FullViewPrCY
vs1@                stb       >FswVRows
                    stx       >FswPrCY
                    clra
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    subd      #OneSixteenth
                    std       >FswVMaxY
                    rts

TxRecEnd            equ       FswRecEnd           fsw's RecEnd
FsFill              equ       $0178
SpX0                fdb       0                   (fswc's own: fsw's SpRec is not called)
SpX1                fdb       0
SpY                 fcb       0
PfCol               fcb       0
* (fswc, from fsw 2026-10-21) FS's text and fills on its own view rows (the CoCo screen's rows 0-98: crash, PAUSED, aircraft failure, the
* scenery's messages) are drawn in the bitmap, in CoCo pixels scaled to the view: a CoCo pixel is 4 dots wide,
* CoCo row r covers bitmap rows r x 147/99 on. Delay shows them for the time FS meant.
GyBits              fdb       0                   Glyph: the glyph's bits (FS's end marker in bit 15), its x
GyX                 fcb       0
GyRow               fcb       0
CbX0                fcb       0                   CBlk: CoCo x from, to; row; the bitmap rows' end
CbX1                fcb       0
CbR                 fcb       0
CbEnd               fcb       0
RtEnd               fcb       0                   Rect: the last CoCo row

* Glyph: DrawGlyph's entry (B = character - $20, Y = x and row in CoCo pixels, U = the screen base, color word
* $0201). On FS's own screen's view (U = its base): each lit pixel of the 3 x 5 glyph (bit 2 the left one, three
* bits a row, as FS's tables read them) drawn by CBlk. Else DrawGlyph's own first instruction.
Glyph               pshs      d,x,y,u             (fsw's stub: on FS's own screen only)
                    ldx       #vGlyphFont
                    aslb
                    abx
                    ldd       ,x
                    ora       #GlyphStopBit
                    std       GyBits
                    tfr       y,d
                    sta       GyX
                    stb       CbR
                    lda       >vTextColor+1
                    anda      #ColorNibble
                    sta       PfCol
gy2@                lda       GyBits+1
                    anda      #GlyphRowMask
                    sta       GyRow
                    lda       GyX
                    ldb       #GlyphLeftPix
gy3@                bitb      GyRow
                    beq       gy4@
                    sta       CbX0
                    sta       CbX1
                    bsr       CBlk
gy4@                inca
                    lsrb
                    bne       gy3@
                    lsr       GyBits
                    ror       GyBits+1
                    lsr       GyBits
                    ror       GyBits+1
                    lsr       GyBits
                    ror       GyBits+1
                    ldd       GyBits
                    cmpd      #GlyphStopEnd
                    beq       gy9@
                    inc       CbR
                    bra       gy2@
gy9@                puls      d,x,y,u,pc

* Rect: FillRect's entry (A, B = x1, y1; X = x2, y2 in CoCo pixels; Y = the screen base; FS's fill color). On FS's
* own screen's view: rows y1-y2, x1-x2 by CBlk. Else FillRect's own first instructions.
Rect                pshs      d,x,y,u             (fsw's stub: on FS's own screen only)
                    sta       CbX0
                    stb       CbR
                    tfr       x,d
                    sta       CbX1
                    stb       RtEnd
                    lda       >FsFill+1
                    anda      #ColorNibble
                    sta       PfCol
rt2@                lda       CbR
                    cmpa      RtEnd
                    bhi       rt9@
                    bsr       CBlk
                    inc       CbR
                    bra       rt2@
rt9@                puls      d,x,y,u,pc

* CBlk: CoCo pixels CbX0-CbX1 of CoCo row CbR in PfCol: dots 4 x0 to 4 x1 + 3 on each bitmap row that CoCo row
* covers, a span record each into fsw's RecBuf (FswRecPtr; a full batch to the GPU or the line engine: FswFeed).
* Registers kept.
CBlk                pshs      d,x,u
                    ldb       CbX0
                    clra
                    aslb
                    rola
                    aslb
                    rola
                    std       SpX0
                    ldb       CbX1
                    clra
                    aslb
                    rola
                    aslb
                    rola
                    addd      #CocoPixLastDot
                    std       SpX1
                    ldb       CbR
                    lbsr      CRow
                    sta       SpY
                    ldb       CbR
                    incb
                    lbsr      CRow
                    sta       CbEnd
                    tst       >FswHwGpu           the GPU: one RECT ($02) over the rows
                    beq       cb1@
                    cmpa      SpY
                    lbls      cb9@               no row
                    ldu       >FswRecPtr
                    deca
                    sta       5,u                 Y1 (the last row)
                    lda       SpY
                    sta       4,u
                    ldd       SpX0
                    std       ,u
                    ldd       SpX1
                    std       2,u
                    lda       PfCol
                    ldb       #GpuOpRect
                    std       6,u
                    lda       >FswGpCtl           480 lines: rows 2 Y0 to 2 Y1 + 1, their bit 8 in each X word's bit 15
                    bita      #GpuCtl256
                    beq       cb4@
                    ldb       4,u
                    clra
                    aslb
                    rola
                    stb       4,u
                    tsta
                    beq       cb6@
                    lda       ,u
                    ora       #XRowBit8
                    sta       ,u
cb6@                ldb       5,u
                    clra
                    aslb
                    rola
                    incb
                    stb       5,u
                    tsta
                    beq       cb4@
                    lda       2,u
                    ora       #XRowBit8
                    sta       2,u
cb4@                leau      8,u
                    stu       >FswRecPtr
                    cmpu      #TxRecEnd
                    blo       cb9@
                    jsr       >FswFeed
                    bra       cb9@
cb1@                lda       SpY
                    cmpa      CbEnd
                    bhs       cb9@
                    ldu       >FswRecPtr
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
                    stu       >FswRecPtr
                    cmpu      #TxRecEnd
                    blo       cb2@
                    jsr       >FswFeed
cb2@                inc       SpY
                    bra       cb1@
cb9@                puls      d,x,u,pc
* CRow: B = a CoCo view row (0-99). A = its first bitmap row, B x the view's rows (FswVRows) / 99, at most those. B
* clobbered.
CRow                pshs      b
                    ldd       #CocoViewRows
                    std       >MATH_DIV_SOR
                    puls      b
                    lda       >FswVRows
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
                    cmpa      >FswVRows
                    bls       cr1@
                    lda       >FswVRows
cr1@                rts


* StartPos (FcStartPos, fsw's ModeLd after a mode load; A = its kind, $020C): a crash reset (1) puts the aircraft
* on the game's start (fs_wb.d FsStart*: fd's start), level on the ground, heading along the runway, as SceneLoad
* places it (the start spot, vStart*: fd's start until f5 or a scenery load moves it); any other load that left it in the start's map square (FS's own start and modes 0, 2 and 4, which
* hold that square) gets the start's low words too, so it sits on the runway, not on the square's corner. D
* clobbered.
StartPos            ldb       #RealityOn          reality mode on after every mode load (Roger 2026-10-17: on from
                    stb       >vReality           the start; F2's demo start load, kind 3, had set it 0 - Roger 2026-10-22)
                    cmpa      #LoadKindCrash
                    beq       st1@
                    ldd       >vPosX              the start's map square?
                    cmpd      #FsStartXHi
                    bne       st9@
                    ldd       >vPosZ
                    cmpd      #FsStartZHi
                    bne       st9@
                    ldd       #FsStartXLo
                    std       >vPosX+2
                    ldd       #FsStartZLo
                    std       >vPosZ+2
st9@                rts
st1@                ldd       >vStartX            the start spot (fd's start, or where f5 or a scenery load put it)
                    std       >vPosX
                    ldd       >vStartX+2
                    std       >vPosX+2
                    ldd       >vStartZ
                    std       >vPosZ
                    ldd       >vStartZ+2
                    std       >vPosZ+2
                    clra
                    clrb
                    std       >vAlt
                    std       >vPitch             pitch
                    std       >vBank              bank
                    ldd       #AltOnGround
                    std       >vAlt+2             on the ground
                    lda       >vStartHdg
                    clrb
                    std       >vHdg               heading
                    sta       >vHdgCopy           and its copy
                    lbra      TwPurge             the speech of before the crash gone

* The GPU's keys (I, A, D, E) and its view registers are fsx's (ViewKey, GfxKey, GpView; fsw's XCall), with its
* GpInit and GpMode.

* SceneLoad: f3's load of a scenery file (MenuKeyEnter, B = the list entry), then, when it loaded, the aircraft
* onto that scenery's start runway: a scenery's areas are drawn only near them, so a file loaded where the
* aircraft is not (Chicago's Meigs Field after start) leaves it over open water. The aircraft sits on the runway
* (the table's map square plus its low words), heading along it, at FS's on-ground height ($0301, as fd's start
* state), level. Exit as f3's LoadSceneryFile: carry set when the load failed.
FsName              equ       $2030               f3: the file name just loaded ("sf.xxx", CR)
SceneLoad           jsr       >F3LoadScenery
                    bcs       sc9@
                    pshs      d,x,y,u
                    ldu       #SceneTab
sc1@                tst       ,u
                    beq       sc8@                not in the table: the aircraft stays
                    ldx       #FsName
sc2@                lda       ,u+
                    cmpa      ,x+
                    bne       sc4@
                    cmpa      #ChrCR
                    bne       sc2@
                    ldd       ,u                  this scenery: X, Z (high words, then low words), heading
                    std       >vPosX
                    std       >vStartX            and the start spot: a crash reset comes back here
                    ldd       2,u
                    std       >vPosZ
                    std       >vStartZ
                    ldd       4,u
                    std       >vPosX+2
                    std       >vStartX+2
                    ldd       6,u
                    std       >vPosZ+2
                    std       >vStartZ+2
                    clra
                    clrb
                    std       >vAlt
                    std       >vPitch             pitch
                    std       >vBank              bank
                    ldd       #AltOnGround
                    std       >vAlt+2             on the ground
                    lda       8,u
                    std       >vHdg               heading (B = 0)
                    sta       >vHdgCopy           and its copy, which the flight model writes back each frame
                    sta       >vStartHdg
                    ldd       9,u                 and its rotation point (auto mode)
                    std       >vStartRot
                    bra       sc8@
sc4@                lda       -1,u                to the next entry
                    cmpa      #ChrCR
                    beq       sc5@
sc6@                lda       ,u+
                    cmpa      #ChrCR
                    bne       sc6@
sc5@                leau      11,u
                    bra       sc1@
sc8@                puls      d,x,y,u
                    andcc     #^Carry
sc9@                rts

* Each scenery's start: its name as f3 holds it, X and Z (map units: the high words of FS's position), their low
* words, runway heading (1/256 turn, as the scenery's $03 runway op), the rotation point (auto mode: 90% of the runway
* along its larger axis, m). The longest runway of each file but Chicago's:
* O'Hare's is the game's start (fs_wb.d FsStart*), the same spot as fd's start and the crash reset's.
SceneTab            fcc       /sf.standard/
                    fcb       $0D
                    fdb       287,804,0,0         Meigs Field, FS's own start
                    fcb       $00
                    fdb       1068                18/36, 3,899 ft
                    fcc       /sf.wildbits/
                    fcb       $0D
                    fdb       FsStartXHi,FsStartZHi,FsStartXLo,FsStartZLo   O'Hare: the game's start (9C, 120 m in)
                    fcb       FsStartHdg          090
                    fdb       3084                9C, 11,245 ft
                    fcc       /sf.japan/
                    fcb       $0D
                    fdb       15506,1330,0,0      area 3, 2701 x 45
                    fcb       $47
                    fdb       2395
                    fcc       /sf.europe/
                    fcb       $0D
                    fdb       -2124,990,0,0       area 15, 1825 x 23
                    fcb       $32
                    fdb       1546
                    fcc       /sf.sd7/
                    fcb       $0D
                    fdb       2754,-4918,0,0      area 32, 1830 x 46
                    fcb       $00
                    fdb       1647
                    fcc       /sf.sd11/
                    fcb       $0D
                    fdb       1565,1990,0,0       area 27, 1799 x 46: Oscoda, MI (Wurtsmith)
                    fcb       $2E
                    fdb       1619
                    fcb       0

* Scrub: replaces f3's lda >$0CD6 before it writes the loaded scenery's menu text ($2200, [$023C] bytes) to the
* screen: each CoCo palette escape (ESC $31 pp cc; the WildBits terminal has none, and its two bytes would act
* as controls) becomes four $00 no-ops. Exit A = the display path, as f3's lda; X, Y kept.
Scrub               pshs      b,x,y
                    ldx       #vSfMenuText
                    ldy       >vSfMenuLen
sb1@                leay      ,y
                    beq       sb9@
                    lda       ,x+
                    leay      -1,y
                    cmpa      #VT_ESC
                    bne       sb1@
                    cmpy      #EscPalTail
                    blo       sb1@
                    lda       ,x
                    cmpa      #EscPalette
                    bne       sb1@
                    clr       -1,x
                    clr       ,x+
                    clr       ,x+
                    clr       ,x+
                    leay      -3,y
                    bra       sb1@
sb9@                puls      b,x,y
                    lda       >FsPath
                    rts

* Taxi mode (2026-10-19): on the ground with the engine running. FS's airspeed $07BB is 1/256 m/s; FS steps it
* at 5 a second (ComputeAerodynamics). Throttle ($0837's high byte, the keys' steps of 8): idle (below 8) or the
* engine stopped ($0738 0): the jet slows at 0.5 m/s2 and stays stopped; the first step (8-15): it settles at
* 3.5 kt (TxTaxi) at 0.5 m/s2; above: FS's own step (the takeoff run as before). The brakes (FswTxBrk, keys J K L):
* 2.5 m/s2 with both, half with one. In the air, or with smart taxi off (FswTxSmart 0, F2's FIX MODE page 1), FS's
* own code runs unchanged.
TxIdleDec           equ       26                  0.5 m/s2 at 5 steps a second, 1/256 m/s
TxTaxi              equ       461                 3.5 kt (1.8 m/s)
TxBrkDec            equ       128                 2.5 m/s2
TxCross             equ       1145                4.47 m/s: speed / 8 m and 2.5 m/s2 / speed meet
TxV                 fdb       0
TxD                 fdb       0
TxW                 fdb       0
TxN                 zmb       4                   TxDiv: the dividend, then the quotient
TxR                 fdb       0

* TaxiSpd (FcTaxiSpd, FS's ComputeAeroAddSpeed): D = FS's step -> D = the new airspeed.
TaxiSpd             tst       >FswTxSmart         smart taxi off: FS's own
                    beq       ts0@
                    tst       >vOnGnd
                    bne       ts1@
ts0@                addd      >vAirspeed          in the air: FS's own (its overflow and negative clamps)
                    bvc       ta1@
                    lda       #AirspeedOvfHi
                    rts
ta1@                bpl       ta2@
                    clra
ta2@                rts
ts1@                std       TxD
                    tst       >FswTxBrkT          the brakes' hold runs out
                    beq       ts2@
                    dec       >FswTxBrkT
                    bne       ts2@
                    clr       >FswTxBrk
ts2@                ldd       >vAirspeed
                    std       TxV
                    tst       >vEngineOn          the engine stopped: idle
                    beq       tsi@
                    lda       >vThrottle
                    cmpa      #TxThrottle1
                    blo       tsi@
                    cmpa      #TxThrottle2
                    blo       tsf@
                    ldd       TxV                 above the first step: FS's own step
                    addd      TxD
                    bvc       tb1@
                    lda       #AirspeedOvfHi
                    bra       tss@
tb1@                bpl       tss@
                    ldd       #TxSpeedZero
                    bra       tss@
tsi@                ldd       TxV                 idle: slowing to a stop
                    subd      #TxIdleDec
                    bcc       tss@
                    ldd       #TxSpeedZero
                    bra       tss@
tsf@                ldd       TxV                 the first step: toward 3.5 kt
                    cmpd      #TxTaxi
                    bhs       tsd@
                    addd      #TxIdleDec
                    cmpd      #TxTaxi
                    bls       tss@
                    ldd       #TxTaxi
                    bra       tss@
tsd@                subd      #TxIdleDec
                    cmpd      #TxTaxi
                    bhs       tss@
                    ldd       #TxTaxi
tss@                std       TxV
                    lda       >FswTxBrk           the brakes
                    beq       tso@
                    ldb       #TxBrkOne
                    cmpa      #TxBrkBoth
                    bne       tsb@
                    ldb       #TxBrkDec
tsb@                clra
                    pshs      d
                    ldd       TxV
                    subd      ,s++
                    bcc       tsc@
                    ldd       #TxSpeedZero
tsc@                std       TxV
tso@                ldd       TxV
                    rts

* TaxiYaw (FcTaxiYaw, FS's ComputeAeroPitchRate after its store): on the ground, the turn rate $076D (FS's
* angle a second: 182 a degree) = the rudder's share ($082B's high byte / $7C) of the most the nosewheel and the
* tires allow: speed / 8 m below 4.47 m/s, 2.5 m/s2 / speed above. One brake adds half the most toward its side.
* Stopped: no turn. In the air $076D stays as FS made it.
TaxiYaw             tst       >FswTxSmart         smart taxi off: FS's own
                    beq       ty9@
                    tst       >vOnGnd
                    beq       ty9@
                    ldd       >vAirspeed
                    bne       ty1@
                    std       >vTurnRate          stopped
ty9@                rts
ty1@                cmpd      #TxCross
                    bhs       ty2@
                    std       TxV                 speed x 5.06 (1/256 m/s -> FS's angle a second at 8 m)
                    lslb
                    rola
                    lslb
                    rola
                    addd      TxV
                    std       TxW
                    ldd       TxV
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    addd      TxW
                    bra       ty3@
ty2@                std       TxD                 6,674,432 / speed (2.5 m/s2)
                    ldd       #TxTurnDivHi
                    std       TxN
                    ldd       #TxTurnDivLo
                    std       TxN+2
                    ldd       TxD
                    bsr       TxDiv
                    ldd       TxN+2
ty3@                std       TxW                 the most
                    lda       >vRudder            the rudder's high byte, signed
                    pshs      a
                    bpl       ty4@
                    nega
ty4@                tfr       a,b                 |rudder| x the most / 124
                    lda       TxW+1
                    mul
                    std       TxN+2
                    ldb       ,s
                    bpl       ty5@
                    negb
ty5@                lda       TxW
                    mul
                    addb      TxN+2
                    adca      #AdcCarryOnly
                    std       TxN+1
                    clr       TxN
                    ldd       #TxRudderFull
                    bsr       TxDiv
                    ldd       TxN+2
                    tst       ,s+
                    bpl       ty6@
                    coma
                    comb
                    addd      #NegCarry
ty6@                std       TxV                 the rudder's turn
                    ldd       TxW
                    lsra
                    rorb
                    std       TxW                 half the most: one brake
                    lda       >FswTxBrk
                    cmpa      #TxBrkLeft
                    bne       ty7@
                    ldd       TxV                 the left brake: to the left
                    subd      TxW
                    bra       ty8@
ty7@                cmpa      #TxBrkRight
                    bne       ty8a@
                    ldd       TxV                 the right brake: to the right
                    addd      TxW
                    bra       ty8@
ty8a@               ldd       TxV
ty8@                std       >vTurnRate
                    rts

* TxDiv: TxN (32-bit unsigned) / D (16-bit, not 0) -> TxN. X, Y, U kept.
TxDiv               std       TxD
                    pshs      x
                    ldd       #TxDivRemInit
                    std       TxR
                    ldx       #TxDivBits
td1@                lsl       TxN+3
                    rol       TxN+2
                    rol       TxN+1
                    rol       TxN
                    rol       TxR+1
                    rol       TxR
                    ldd       TxR
                    bcs       td2@                a 17th bit: certainly past the divisor
                    cmpd      TxD
                    blo       td3@
td2@                subd      TxD
                    std       TxR
                    inc       TxN+3
td3@                leax      -1,x
                    bne       td1@
                    puls      x,pc

* PBar (FcPBar: fsw's PBar, Frame with no dash, through CCall; moved from fsw 2026-10-24 for its room): two red
* bars at the bottom of the dash plane (bitmap 2, whose CLUT 1 fsp never wrote: its entries are vtio's), 40 dots
* a step: A = fsw's PFail on row 237, B = its PStep on 239; their records on the stack, one SS.BmLine. Registers
* kept.
PBar                pshs      d,x,y,u
                    leas      -16,s               two records
                    leau      ,s
                    pshs      b
                    ldb       #PBarFailRow
                    bsr       PBar1
                    puls      a
                    ldb       #PBarStepRow
                    bsr       PBar1
                    leax      ,s
                    tfr       u,d
                    pshs      x
                    subd      ,s++                the records' bytes
                    beq       pb8@
                    lsrb
                    lsrb
                    lsrb
                    clra
                    tfr       d,u                 their count
                    ldy       #DashBitmap         bitmap 2
                    lda       >FsPath
                    ldb       #SS.BmLine
                    swi2
                    fcb       I$SetStt
pb8@                leas      16,s
                    puls      d,x,y,u,pc
* PBar1: A = the steps (0: no bar), B = the row: its record at U, U past it
PBar1               tsta
                    beq       pb9@
                    stb       4,u                 Y0, Y1
                    stb       5,u
                    ldb       #PBarStepDots
                    mul
                    std       2,u                 X1
                    ldd       #PBarLeftX
                    std       ,u                  X0
                    ldd       #PBarRedLine        red in the power-on text palette order, byte 7 0
                    std       6,u
                    leau      8,u
pb9@                rts

* InitBm (FcInitBm, fsw's Init) and DashBm (FcDashBm, fsw's Init after fsx's GpInit), moved from fsw 2026-10-24
* for its room. InitBm: bitmap 1, the first back buffer, then one dot on it through SS.BmLine: grfdrv256 switches
* the line engine on ($FFCA bit 0, in its mirror too) for Direct's own records. DashBm: bitmap 2 for the dash, on
* layer 0 over the view, which goes to layer 1 (the GPU, set there by fsx's GpInit; otherwise bitmap 0 now and the
* flips from Present). Exit: B (InitBm) or A (DashBm) = the bitmap's first block; carry set: no bitmap. The others
* clobbered.
InitBm              ldy       #BackBitmap         bitmap 1
                    bsr       BmSet
                    bcs       ib9@
                    pshs      b
                    ldu       #IbDotCount         the dot
                    ldx       #IbDot
                    ldb       #SS.BmLine
                    bsr       BmStt
                    puls      b
                    andcc     #^Carry
ib9@                rts
IbDot               fdb       0,0                 x 0 to 0, row 146 to 146, color 0, LINE
                    fcb       146,146,0,0
DashBm              ldy       #DashBitmap         bitmap 2
                    bsr       BmSet
                    bcs       db9@                no bitmap 2: no dash (fsp's DMA would go to block 0)
                    pshs      b
                    tst       >FswHwGpu
                    bne       db1@
                    ldx       #ViewLayer          layer 1 = bitmap 0, the view (no GPU)
                    ldy       #ViewBitmap0
                    ldb       #SS.PScrn
                    bsr       BmStt
db1@                ldx       #DashLayer          layer 0 = bitmap 2, the dash
                    ldy       #DashBitmap
                    ldb       #SS.PScrn
                    bsr       BmStt
                    puls      a
                    andcc     #^Carry
db9@                rts
* BmSet: bitmap Y allocated (SS.AScrn), cleared (fill 0, the end waited for: mode 7) and HIRES4, group 0 (fsp
* points the dash's at CLUT 1). Exit: B = its first block; carry set: not allocated. A, X, U clobbered, Y kept.
BmSet               ldx       #ScrType240
                    ldb       #SS.AScrn
                    bsr       BmStt
                    bcs       bs9@
                    tfr       x,d
                    pshs      b
                    ldx       #BmClearPoll
                    ldu       #BmClearAllRows
                    ldb       #SS.BmClear
                    bsr       BmStt
                    ldx       #BmCfgKeep
                    ldu       #BmCfgHires4
                    ldb       #SS.BmCfg
                    bsr       BmStt
                    puls      b
                    andcc     #^Carry
bs9@                rts
* BmStt: SetStat B on FS's display path
BmStt               lda       >FsPath
                    swi2
                    fcb       I$SetStt
                    rts

* HzBg (FcHzBg, fsw's HzSky when FS's sky color changed; moved from fsw 2026-10-24 for its room): VICKY's
* background the RGB of FS's sky color A (WbPalette's entry: blue, green, red at WbGimePal-3 + 4 x the color),
* through grfdrv256's GPU call (GpuF.FixN). D, X, Y, U clobbered.
HzBg                ldb       #PalRecLen
                    mul
                    addd      #WbPalRecs
                    tfr       d,x
                    ldd       ,x
                    std       HbRq+4
                    lda       2,x
                    sta       HbRq+6
                    ldx       #GpuFixVicky
                    ldy       #HbRq
                    ldu       #BgRgbLen
                    lda       >FsPath             grfdrv256's GPU call: SS.Gpu on FS's display path
                    ldb       #SS.Gpu
                    swi2
                    fcb       I$SetStt
                    rts
HbRq                fdb       BACKGROUND_COLOR_B  GpuF.FixN's request: the offset, the mask, 0, then blue, green, red
                    fcb       3,0
                    rmb       3

                    use       twr.asm

                    ifgt      *-FsxBase-FsxMax
                    error     "fswc: past its 8 KB block"
                    endc
