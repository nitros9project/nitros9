********************************************************************
* twr.asm - FS (Flight Simulator II), WildBits port: the tower (2026-10-20). Included by fswc.asm: fsw's Frame
* calls Tower (FcTower) once a frame through CCall. Speech only (Roger: no tower text): the pieces of tower.lpc
* (mktower.py: SP0250 frames) streamed to FS's /FTDD path, which VRN (edition 2) feeds to the chip at $FF9F.
*
* With COM1 on an airport's tower frequency (twr_data.asm) and the aircraft within about 32 km of it, the talk key
* (fsw's KeyMap: F5 on the K2, O on the Jr2, FswTwKey counts the presses) sends the call the situation implies and
* the tower answers: on the ground, the takeoff clearance (or hold short with traffic on the runway or on final, the
* clearance following when it clears); in the air within 18.5 km, the pattern entry, and on final the landing
* clearance (or continue, the clearance following); the first call assigns a squawk; a call before the ATIS was
* heard gets "check ATIS". The tower watches: a takeoff or a landing without clearance or on another runway end, a
* wrong squawk, an unstable final or a runway the actor holds under the aircraft on final (go around), a roll on a
* runway without clearance while the actor is on final (stop), the actor within 1 km in the air (traffic alert);
* it clears the actor too (fst's point, FswTfPt). On the ATIS frequency the ATIS repeats (its runway the tower's).

TwPath              equ       $0286               FS's /FTDD path (fs_core.asm FsMain)
FsCom               equ       $09CB               COM1's four digits, ASCII (FS's $0203 BCD copy is made only while
*                                                 its CoCo panel shows, which the port's never does)
FsXpdr              equ       $01F8               XPDR, BCD (SetXpdrCode)
FsGnd               equ       $0781               on the ground (nonzero)
FsSpd               equ       $07BB               airspeed, 1/256 m/s
FsAgl               equ       $0005               height above the ground, meters (word)
FsHdg               equ       $0016               heading (high byte: 1/256 turn, clockwise from north)
FsSec               equ       $0287               the clock's seconds
FsTick              equ       $0897               FS's timer: $FB-$FF, a step 5 times a second (ProcessTimerTicks)
FsKey               equ       $009A               PollKeyRead's byte (fsw's KeyMap)
FsNavRx             equ       $028E               the NAV receivers: b0 NAV1, b1 NAV2 hear their station
FsAdfOn             equ       $0348               the ADF shown (its needle takes NAV2's station record)
FsWind              equ       $033E               the surface wind as CMDS/f2 stores it: +0 knots (below 100), +2 its
*                                                 direction (from), a 16-bit angle: its high byte 1/256 turn (f2.asm's
*                                                 ConvertWindEntryToSim, degrees x 65536 / 360; FS reads +2)
FsHour              equ       $0321               FS's clock: hours, minutes (local), season (1 winter .. 4 fall)
FsMin               equ       $0322
FsSeason            equ       $0323
FsCloud             equ       $0324               F2's cloud layers, feet MSL: layer 2 top, bottom, layer 1 top, bottom
TwElev              equ       680                 O'Hare's elevation (ft): the ceilings above it
TwSpBy              equ       $82                 VRN's GetStat: the speech bytes still to speak, X
TwCap               equ       640                 the speech kept ahead in VRN's buffer (about 0.85 s)
P_PAUSE             equ       $FE                 a queued second of silence (not a tower.lpc piece; PauseFr)
TwHoldN             equ       25                  no air talk for 5 s (timer steps) after the start or a crash
FsDemo              equ       $02C6               FS started in its demo (A at the start prompt: mode 2; f2's
*                                                 ApplyEnvironment): it takes off and flies by itself
PauseN              equ       30                  its bytes: two silent frames
P_BRK               equ       $FD                 a queued 0.4 s of silence between sentences (BrkFr)
                    ifge      P_N-P_BRK
                    error     "twr: tower.lpc's pieces reach the pause tokens"
                    endc
S_GND               equ       1                   on the ground, called, not cleared
S_HOLD              equ       2                   holding short, the clearance to come
S_CLRTO             equ       3                   cleared for takeoff
S_DEP               equ       4                   departed
S_INB               equ       5                   inbound, the pattern given
S_CONT              equ       6                   on final, continue: the clearance to come
S_CLRL              equ       7                   cleared to land
S_ROLL              equ       8                   landed, rolling out
S_TAXI              equ       9                   cleared to taxi by ground control (hold short, then the tower)

                    use       twr_data.asm
                    use       twr_morse.asm

* Tower (FcTower): once a frame
Tower               pshs      d,x,y,u
                    lbsr      DashSp              the dash off in the spot view, on outside it
                    lbsr      EngSnd              the engine sound (fsw's FrPre had it)
                    inc       TwSeed
                    lbsr      TwOpen
                    lda       >FsTick             FS's timer steps since the last frame (it runs $FB-$FF): the radios
                    tfr       a,b                 tuned and the Morse keyed on them only, not every frame
                    suba      TwTkL
                    bpl       tw0b@
                    adda      #FsTickRange
tw0b@               cmpa      #FsTickRange
                    blo       tw0c@
                    lda       #TwTkOneStep
tw0c@               stb       TwTkL
                    sta       TwTkN
                    beq       tw0a@
                    lbsr      TwTune
tw0a@               lda       >FswTwKey           a tower key pressed (fsw's KeyMap)?
                    beq       tw1@
                    clr       >FswTwKey
                    cmpa      #KeyXpdr
                    bne       tw0@
                    lbsr      XpSel
                    bra       tw1@
tw0@                tst       TwHold              no air talk yet: the call dropped
                    bne       tw1@
                    lbsr      TwTalk
tw1@                lda       >FsSec              a new second?
                    cmpa      TwSecL
                    beq       tw2@
                    sta       TwSecL
                    lbsr      TwSecond
tw2@                lbsr      TwActor
                    lbsr      TwStream
tw3@                tst       TwTkN               a step per timer step: the air-talk hold, the quiet time, the
                    beq       tw9@                Morse
                    tst       TwHold
                    beq       tw3a@
                    dec       TwHold
tw3a@               lbsr      SpBusy
                    beq       tw4@
                    clr       TwQuiet             speech: the quiet starts again
                    bra       tw5@
tw4@                inc       TwQuiet
                    bne       tw5@
                    dec       TwQuiet             at most 255
tw5@                lbsr      Morse
                    dec       TwTkN
                    bra       tw3@
tw9@                puls      d,x,y,u,pc

* DashSp (Tower, every frame): the dash hidden in the spot view (S, fsw's SpOn) and in the sky view (key 4, $0139),
* shown again outside them; SS.BmCfg only on a change. The dash is bitmap 2 and, with the GPU drawing the view (the K2), also bitmap 1:
* fsp flips layer 0 between the two each frame (SS.PScrn leaves their enable bits alone), so both go off and on
* together. Without the GPU bitmap 1 is the view's second buffer and stays on. A no-dash run (no bitmap 2) gets an
* error back and nothing else. D, X, Y, U clobbered.
DashSp              ldb       >FswSpOn
                    orb       >vMapView
                    cmpb      DsLast
                    beq       ds9@
                    stb       DsLast
                    ldy       #DashBitmap
                    bsr       ds1@
                    tst       >FswHwGpu
                    beq       ds9@
                    ldy       #DashBitmapAlt
ds1@                clra
                    tst       DsLast
                    bne       ds2@                the spot view: off
                    inca                          on
ds2@                ldb       #BmCfgKeepField     the CLUT as it is
                    tfr       d,x
                    ldu       #BmCfgKeep          HIRES4 and group as they are
                    lda       >FsPath             FS's display path
                    ldb       #SS.BmCfg
                    swi2
                    fcb       I$SetStt
ds9@                rts
DsLast              fcb       0                   SpOn last frame (0: the dash shown, as at the start)

* EngSnd (Tower, every frame: moved from fsw 2026-10-21 for its room): the engine on both SIDs. FS's RPM ($072C, 50 rpm a step, already smoothed) sets
* voice 1, a 25% pulse at the firing rate (four cylinders, two firings a revolution: rpm / 30 Hz; the SIDs run at
* 954,545 Hz, so Fn = $072C x 29.3), and voice 2, a sawtooth an octave up and a little sharp (the beat). Voice 3 is
* noise through the low-pass filter, which opens with the airspeed ($07BB: the wind). The volume falls as the
* RPM rises (as heard in the cabin: full to 1000 rpm, a quarter at 2500); 0 RPM is silent. The fixed settings
* (pulse width, envelopes, waveforms with the gates on, the filter's routing) are written once. All registers kept.
EsF1                fdb       0                   voice 1's frequency
EsOn                fcb       0                   the fixed settings are written
EngSnd              pshs      d,x
                    ldb       >vRpm
                    beq       es9@                0 RPM: silent (B = 0)
                    tst       EsOn
                    bne       es2@
                    inc       EsOn
                    ldx       #EsFix
es1@                ldd       ,x++
                    bsr       SidW
                    tst       ,x
                    bpl       es1@
es2@                ldb       >vRpm
                    lda       #EsRpmFactor
                    mul
                    lsra
                    rorb
                    lsra
                    rorb                          D = $072C x 117 / 4
                    std       EsF1
                    clra                          voice 1
                    bsr       SidW                (B = the low byte)
                    ldb       EsF1
                    lda       #SidV1FreqHi
                    bsr       SidW
                    ldb       EsF1                voice 2: 2 F1 + F1's high byte x 4
                    lslb
                    lslb
                    clra
                    addd      EsF1
                    addd      EsF1
                    pshs      a
                    lda       #SidV2FreqLo
                    bsr       SidW
                    puls      b
                    lda       #SidV2FreqHi
                    bsr       SidW
                    ldd       EsF1                voice 3: noise at 8 F1 (the high byte)
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    tfr       a,b
                    lda       #SidV3FreqHi
                    bsr       SidW
                    ldb       >vAirspeed          the filter's cutoff: $10 + the airspeed / 2
                    lsrb
                    addb      #EngCutoffBase
                    lda       #SidCutoffHi
                    bsr       SidW
                    ldb       >vRpm               the volume (the cabin's): 22 - 3 x the RPM / 8, at most 15 (1000
                    lda       #EsVolSlope         rpm and below), 4 at 2500 rpm, at least 3, low-pass mode
                    mul
                    lsrb
                    lsrb
                    lsrb
                    negb
                    addb      #EsVolBase
                    cmpb      #EsVolMin
                    bge       es3@
                    ldb       #EsVolMin
es3@                cmpb      #EsVolMax
                    bls       es4@
                    ldb       #EsVolMax
es4@                orb       #SidLowPass
es9@                lda       #SidModeVol
                    bsr       SidW
                    puls      d,x,pc

* SidW: B to register A of both SIDs (the select port, then the data port; the core queues the writes).
SidW                ora       #SID_SELECT_BOTH
                    sta       >SID_SELECT_PORT
                    stb       >SID_DATA_PORT
                    rts
* EsFix: register, value; a negative register ends it
EsFix               fcb       2,$00,3,$04,5,$00,6,$F0,4,$41 voice 1: 25% pulse, attack 0, sustain 15, gate on
                    fcb       12,$00,13,$90,11,$21 voice 2: sawtooth, sustain 9
                    fcb       14,$00,19,$00,20,$60,18,$81 voice 3: noise, sustain 6
                    fcb       $15,$00,$17,$44     the filter: resonance 4, voice 3 through it
                    fcb       $FF

* TwKey (FcTwKey, fsw's KeyMap; B = the key, not 0): the tower's keys noted for the next frame (F5 $A5, O or o:
* talk; -: the XPDR's digits; FS's own table has no use for them), COM2's tuning (Ctrl+K, $0B: its MHz, again its
* kHz, then . up and , down until another key) and the audio panel's: Ctrl+R ($12; the driver sends the same code
* for Ctrl+down, which FS ignores) arms it, then 1-6 turns a button on or off (COM1, COM2, NAV1, NAV2, ADF, MKR:
* FswAud's bits 0-5); the tuning and panel keys kept from FS (B = 0, FsKey 0). A clobbered (KeyMap keeps it).
TwKey               tst       Co2Md               COM2 being tuned: . up, , down; any other key ends it
                    beq       tk0a@
                    cmpb      #KeyTuneUp
                    beq       tk0b@
                    cmpb      #KeyTuneDown
                    beq       tk0b@
                    clr       Co2Md
                    bra       tk0a@
tk0b@               lbsr      Co2Step
                    bra       tk8@
tk0a@               cmpb      #KeyCtrlK           Ctrl+K: COM2's MHz, again its kHz
                    bne       tk0c@
                    lda       Co2Md
                    cmpa      #Co2MdMhz
                    beq       tk0d@
                    lda       #Co2MdMhz
                    sta       Co2Md
                    bra       tk8@
tk0d@               lda       #Co2MdKhz
                    sta       Co2Md
                    bra       tk8@
tk0c@               tst       AuArm
                    beq       tk2@
                    clr       AuArm
                    cmpb      #KeyAudFirst
                    blo       tk2@
                    cmpb      #KeyAudLast
                    bhi       tk2@
                    pshs      a
                    subb      #KeyAudFirst
                    lda       #AudCom1            the button's bit
tk1@                decb
                    bmi       tk0@
                    lsla
                    bra       tk1@
tk0@                eora      >FswAud
                    sta       >FswAud
                    puls      a
                    bra       tk8@
tk2@                cmpb      #KeyCtrlR
                    bne       tk3@
                    inc       AuArm
                    bra       tk8@
tk3@                cmpb      #KeyK2F5
                    beq       tk4@
                    cmpb      #KeyJr2Talk
                    beq       tk4@
                    cmpb      #KeyJr2TalkLc
                    beq       tk4@
                    cmpb      #KeyXpdr
                    bne       tk9@
tk4@                stb       >FswTwKey
tk9@                rts
tk8@                clrb
                    stb       >FsKey
                    rts
* Co2Step: B = . (up) or , (down): COM2's MHz (118-136, around) or kHz (0.01 a step, .00-.99 around) by Co2Md
Co2Step             lda       Co2Md
                    cmpa      #Co2MdMhz
                    bne       cs3@
                    lda       >FswCom2            MHz
                    cmpb      #KeyTuneUp
                    bne       cs1@
                    adda      #BcdPlusOne
                    daa
                    cmpa      #Com2MhzOver
                    blo       cs2@
                    lda       #Com2MhzLow
                    bra       cs2@
cs1@                adda      #BcdMinusOne        one less (BCD)
                    daa
                    cmpa      #Com2MhzLow
                    bhs       cs2@
                    lda       #Com2MhzHigh
cs2@                sta       >FswCom2
                    rts
cs3@                lda       >FswCom2+1          kHz, by 0.01 (as FS's radios now)
                    cmpb      #KeyTuneUp
                    bne       cs4@
                    adda      #BcdPlusOne
                    daa
                    bra       cs5@
cs4@                adda      #BcdMinusOne        one less (BCD)
                    daa
cs5@                sta       >FswCom2+1
                    rts

* Morse (Tower, once a step of FS's timer, FsTick, 5 a second): the received VOR's ident in Morse on the PSG's
* tone 0 (N 110: 1017 Hz at its 3,579,545 Hz clock): a dot 1 step, a dash 3, 1 between them, 3 between letters, 25
* after the ident. NAV1's station while its button is on and NAV1 hears it, else NAV2's (MoFind). A station not in
* MoIds (an ILS localizer) is silent; a new station starts from its ident's start. Speech first: while the tower or
* the ATIS talks (SpBusy) the tone is off, and the ident starts again after it.
Morse               lbsr      SpBusy
                    beq       mo0@
                    tst       MoOn
                    beq       mo0a@
                    lbsr      MoOff
mo0a@               ldx       #MoIdNone
                    stx       MoId
                    rts
mo0@                lbsr      MoFind              X = the station's ident, 0 none
                    cmpx      MoId
                    beq       mo1@
                    stx       MoId
                    clr       MoCh
                    lda       #MoStopBit          no letter
                    sta       MoBits
                    lda       #MoLetterGap
                    sta       MoCnt
                    lbsr      MoOff
mo1@                ldx       MoId
                    beq       mo9@
                    dec       MoCnt
                    bne       mo9@
                    tst       MoOn
                    beq       mo4@
                    lbsr      MoOff               an element ends: the gap after it
                    ldb       #MoElemGap
                    lda       MoBits
                    cmpa      #MoStopBit
                    bne       mo3@
                    ldb       #MoLetterGap        the letter's end
                    lda       MoCh
                    cmpa      #MoIdLen
                    beq       mo2@
                    lda       a,x
                    cmpa      #ChrSpace
                    bne       mo3@
mo2@                clr       MoCh                the ident's end
                    ldb       #MoIdentGap
mo3@                stb       MoCnt
                    rts
mo4@                lda       MoBits              a gap ends: the next element
                    cmpa      #MoStopBit
                    bne       mo6@
                    ldb       MoCh                the next letter
                    lda       b,x
                    inc       MoCh
                    ldx       #MoLet
                    suba      #MoLetBase
                    bhs       mo5@
                    adda      #MoLetToDig         a digit
                    ldx       #MoDig
mo5@                lda       a,x
mo6@                ldb       #MoDotLen           a dot
                    lsla
                    bcc       mo7@
                    ldb       #MoDashLen          a dash
mo7@                sta       MoBits
                    stb       MoCnt
                    lbsr      MoTone
mo9@                rts

* MoFind: X = the ident (in MoIds) of the station heard on NAV1, else NAV2 (not while the ADF is shown), whose
* button is on; 0 none. U clobbered.
MoFind              ldx       #MoIdNone
                    lda       >FswAud
                    bita      #AudNav1
                    beq       mf1@
                    lda       >FsNavRx
                    bita      #NavRx1
                    beq       mf1@
                    ldu       #vNav1StnRec        NAV1's station record
                    bsr       MoLook
                    bne       mf9@
mf1@                lda       >FswAud
                    bita      #AudNav2
                    beq       mf9@
                    tst       >FsAdfOn
                    bne       mf9@
                    lda       >FsNavRx
                    bita      #NavRx2
                    beq       mf9@
                    ldu       #vNav2StnRec        NAV2's
                    bsr       MoLook
mf9@                rts
* MoLook: U = a station record (X low, high, Z low, high words): X = its ident in MoIds by the high words, 0
* (and Z set) when it has none
MoLook              ldx       #MoIds
ml1@                ldd       ,x
                    cmpd      2,u
                    bne       ml2@
                    ldd       2,x
                    cmpd      6,u
                    bne       ml2@
                    leax      4,x
                    rts
ml2@                leax      7,x
                    cmpx      #MoIdsE
                    blo       ml1@
                    ldx       #MoIdNone
                    rts

* MoTone, MoOff: the PSG's tone 0 on (1017 Hz, attenuation 4) or off. A kept.
MoTone              ldb       #MoToneLatch        tone 0, N's low 4 bits
                    stb       >PSG_BOTH_PORT
                    ldb       #MoToneHigh         its high 6
                    stb       >PSG_BOTH_PORT
                    ldb       #PsgTone0Att4       tone 0's attenuation 4
                    stb       >PSG_BOTH_PORT
                    ldb       #MoToneOn
                    stb       MoOn
                    rts
MoOff               ldb       #PsgTone0Off        tone 0 off
                    stb       >PSG_BOTH_PORT
                    clr       MoOn
                    rts

* TwOpen: the first frame: tower.lpc opened, its index read (TwInit 1); without it no speech (TwInit $FF)
TwOpen              lda       TwInit
                    bne       to9@
                    dec       TwInit              tried
                    lbsr      GndNow
                    sta       TwGnd
                    lda       #READ.
                    ldx       #TwName
                    swi2
                    fcb       I$Open
                    bcs       to9@
                    sta       TwFd
                    ldx       #TwBuf
                    ldy       #LpcHdrSize
                    swi2
                    fcb       I$Read
                    bcs       to8@
                    ldd       TwBuf
                    cmpd      #P_N
                    bne       to8@                another file's
                    lda       #TwInitOpen         its pieces' index entries read as they are wanted (TwStream)
                    sta       TwInit
to9@                rts
to8@                lda       TwFd
                    swi2
                    fcb       I$Close
                    rts
TwName              fcc       "tower.lpc"
                    fcb       C$CR

* TwTune: COM1 and COM2, each while its audio button is on (FswAud), against the airports (TwFind): TwMode the
* controller one of them is on (1 tower, 3 ground; COM1's first; TwMask its runways), else 2 when either is on
* the ATIS, else 0; TwAtOn 1 when one radio is on a controller and the other on the ATIS (the broadcast plays
* while the controller is quiet)
TwTune              clr       TwAtOn
                    clr       TwM1
                    clr       TwM2
                    lda       >FswAud             COM1 heard?
                    lsra
                    bcc       tt1@
                    ldx       #FsCom
                    lbsr      Bcd2
                    pshs      a
                    lbsr      Bcd2
                    tfr       a,b
                    puls      a
                    std       TwCom
                    lbsr      TwFind
                    stb       TwM1
                    lda       TwMask
                    sta       TwK1
tt1@                lda       >FswAud             COM2 heard?
                    bita      #AudCom2
                    beq       tt2@
                    ldd       >FswCom2
                    std       TwCom
                    lbsr      TwFind
                    stb       TwM2
                    lda       TwMask
                    sta       TwN2
tt2@                lda       TwM1                a controller on COM1?
                    bsr       TwCtl
                    bne       tt3@
                    sta       TwMode
                    lda       TwK1
                    sta       TwMask
                    lda       TwM2                the other radio
                    bra       tt5@
tt3@                lda       TwM2                on COM2?
                    bsr       TwCtl
                    bne       tt4@
                    sta       TwMode
                    lda       TwN2
                    sta       TwMask
                    lda       TwM1
                    bra       tt5@
tt4@                lda       TwM1                no controller: the ATIS (2) or nothing (0)
                    ora       TwM2
                    sta       TwMode
                    lda       #TwAllRwys
                    sta       TwMask
                    rts
tt5@                cmpa      #TwModeAtis         the other radio on the ATIS: it plays too
                    bne       tt6@
                    inc       TwAtOn
tt6@                rts
* TwCtl: A = a radio's TwFind: Z set when it is a controller (1 tower, 3 ground). A kept.
TwCtl               cmpa      #TwModeTower
                    beq       tc9@
                    cmpa      #TwModeGround
tc9@                rts
* TwFind: TwCom against the airports: B = 1 (one of its tower frequencies: TwMask the runways that one handles),
* 2 (its ATIS: every runway) or 3 (its ground control, +20) with the aircraft in range (TwOK, TwE/TwN its
* position from the airport's reference), else 0; another airport than before: its state afresh
TwFind              ldu       #TwApts
                    clr       TwI
tu1@                lda       TwI
                    cmpa      #TwAptN
                    bhs       tu8@
                    ldd       TwCom
                    cmpd      8,u
                    beq       tu3@
                    cmpd      20,u                its ground control
                    beq       tu3a@
                    ldx       10,u                its tower frequencies
                    ldb       19,u
                    pshs      b
tu2@                ldd       TwCom
                    cmpd      ,x
                    beq       tu2a@
                    leax      3,x
                    dec       ,s
                    bne       tu2@
                    leas      1,s
                    leau      TaSize,u
                    inc       TwI
                    bra       tu1@
tu2a@               leas      1,s
                    lda       2,x
                    sta       TwMask
                    ldb       #TwModeTower
                    bra       tu4@
tu3a@               ldb       #TwModeGround
                    bra       tu3b@
tu3@                ldb       #TwModeAtis
tu3b@               lda       #TwAllRwys
                    sta       TwMask
tu4@                stu       TwAptP
                    pshs      b
                    lbsr      TwPos
                    puls      b
                    tst       TwOK
                    beq       tu8@                out of range
                    lda       TwI
                    cmpa      TwApt
                    beq       tu5@
                    sta       TwApt
                    lbsr      TwReset
tu5@                rts
tu8@                clrb
                    rts
* Bcd2: X = two ASCII digits: A = them as BCD, X past them
Bcd2                lda       ,x+
                    suba      #ChrDigit0
                    lsla
                    lsla
                    lsla
                    lsla
                    sta       TwK
                    lda       ,x+
                    suba      #ChrDigit0
                    ora       TwK
                    rts

* TwReset: the state with a new airport
TwReset             pshs      d
                    clr       TwSt
                    lda       #TwNoEnd
                    sta       TwRwy
                    sta       TwOnEnd
                    clr       TwSq
                    clr       TwSq+1
                    clr       TwFirst
                    clr       TwGaT
                    clr       TwTaT
                    clr       TwStT
                    clr       TwAtT
                    bsr       GndNow
                    sta       TwGnd
                    puls      d,pc
* GndNow: A = 1 on the ground, 0 in the air
GndNow              lda       >FsGnd
                    beq       gn9@
                    lda       #TwGndOn
gn9@                rts

* XpSel: key -, the XPDR's digits selected for FS's . and , keys (its radio items 8-11, which no key of FS's own
* selects), as its Ctrl+C selects COM1's: the first press the first digit, a quick one ($0289) the next
XpSel               lda       >vRepeatTicks
                    beq       xs1@
                    lda       >vKeySelItem
                    cmpa      #XpItemFirst
                    blo       xs1@
                    cmpa      #XpItemThird
                    bhi       xs1@
                    inca
                    bra       xs2@
xs1@                lda       #XpItemFirst
xs2@                sta       >vKeySelItem
                    lda       #RadioRepeatTicks
                    sta       >vRepeatTicks
                    rts

* TwPos: U = an airport: TwE, TwN the aircraft's meters east and north of its reference, TwOK 1 when both fit
* (about 32 km)
TwPos               pshs      x,y
                    clr       TwOK
                    ldx       #vPosX              FS's X (<$00-<$03)
                    leay      ,u
                    bsr       Rel
                    bcs       tp9@
                    std       TwE
                    ldx       #vPosZ              FS's Z (<$08-<$0B)
                    leay      4,u
                    bsr       Rel
                    bcs       tp9@
                    std       TwN
                    inc       TwOK
tp9@                puls      x,y,pc
* Rel: X = an FS position word pair (1/256 m), Y = the reference's: D = the difference in meters; carry set when
* it does not fit 16 bits
Rel                 ldd       2,x
                    subd      2,y
                    sta       TwD+2
                    ldd       ,x
                    sbcb      1,y
                    sbca      ,y
                    std       TwD
                    ldb       TwD+1
                    sex
                    cmpa      TwD
                    bne       rl8@
                    lda       TwD+1
                    ldb       TwD+2
                    andcc     #^Carry
                    rts
rl8@                orcc      #Carry
                    rts

* Near: D = a distance (m): carry clear when the aircraft is within it of the reference east and north
Near                std       TwLim
                    ldd       TwE
                    bpl       nr1@
                    coma
                    comb
                    addd      #NegCarry
nr1@                cmpd      TwLim
                    bhs       nr8@
                    ldd       TwN
                    bpl       nr2@
                    coma
                    comb
                    addd      #NegCarry
nr2@                cmpd      TwLim
                    bhs       nr8@
                    andcc     #^Carry
                    rts
nr8@                orcc      #Carry
                    rts

* EndP: A = a runway end's number: X = its record. D clobbered.
EndP                ldb       #TeSize
                    mul
                    ldx       #TwEnds
                    leax      d,x
                    rts

* End: X = a runway end: TwAl the aircraft's meters along it from the threshold (positive: past it), TwCr across
* (positive: right of the centerline). X kept.
End                 pshs      x
                    ldd       TwE
                    subd      ,x
                    std       TwDe
                    ldd       TwN
                    subd      2,x
                    std       TwDn
                    lda       5,x                 along = de sin + dn cos
                    sta       TwM
                    ldd       TwDe
                    bsr       MulS
                    bsr       Keep
                    ldx       ,s
                    lda       6,x
                    sta       TwM
                    ldd       TwDn
                    bsr       MulS
                    bsr       A24
                    std       TwAl
                    ldx       ,s
                    lda       6,x                 across = de cos - dn sin
                    sta       TwM
                    ldd       TwDe
                    bsr       MulS
                    bsr       Keep
                    ldx       ,s
                    lda       5,x
                    nega
                    sta       TwM
                    ldd       TwDn
                    bsr       MulS
                    bsr       A24
                    std       TwCr
                    puls      x,pc
* Keep: TwP to TwQ
Keep                ldd       TwP
                    std       TwQ3
                    lda       TwP+2
                    sta       TwQ3+2
                    rts
* A24: D = (TwP + TwQ3) >> 7 (the Q7 products' sum in meters)
A24                 ldd       TwP+1
                    addd      TwQ3+1
                    std       TwP+1
                    lda       TwP
                    adca      TwQ3
                    sta       TwP
                    asl       TwP+2
                    rol       TwP+1
                    rol       TwP
                    ldd       TwP
                    rts
* MulS: TwP (24 bits) = D (signed) x TwM (signed byte)
MulS                clr       TwSg
                    tsta
                    bpl       ms1@
                    com       TwSg
                    coma
                    comb
                    addd      #NegCarry
ms1@                std       TwA
                    lda       TwM
                    bpl       ms2@
                    com       TwSg
                    nega
ms2@                sta       TwMa
                    ldb       TwA+1
                    mul
                    std       TwP+1
                    clr       TwP
                    lda       TwMa
                    ldb       TwA
                    mul
                    addd      TwP
                    std       TwP
                    tst       TwSg
                    beq       ms9@
                    com       TwP
                    com       TwP+1
                    com       TwP+2
                    inc       TwP+2
                    bne       ms9@
                    inc       TwP+1
                    bne       ms9@
                    inc       TwP
ms9@                rts

* HdgOK: X = a runway end: carry clear when the aircraft's heading is within 30 degrees of it
HdgOK               lda       >FsHdg
                    suba      4,x
                    bpl       ho1@
                    nega
ho1@                cmpa      #RwyHdgTol
                    bhi       ho8@
                    andcc     #^Carry
                    rts
ho8@                orcc      #Carry
                    rts

* OnEnd: X = a runway end (End done): carry clear when the aircraft is on that runway
OnEnd               ldd       TwAl
                    bmi       oe8@
                    cmpd      7,x
                    bhi       oe8@
                    ldb       9,x
                    clra
                    addd      #RwyEdgeMargin
                    std       TwLim
                    ldd       TwCr
                    bpl       oe1@
                    coma
                    comb
                    addd      #NegCarry
oe1@                cmpd      TwLim
                    bhi       oe8@
                    andcc     #^Carry
                    rts
oe8@                orcc      #Carry
                    rts

* OnFin: X = a runway end (End done): carry clear when the aircraft is on its final: within 9 km short of the
* threshold, the centerline within 150 m plus an eighth of the distance, the heading along it, below 800 m
OnFin               ldd       TwAl
                    bgt       of8@
                    cmpd      #FinFarAl
                    blt       of8@
                    coma
                    comb
                    addd      #NegCarry
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    addd      #FinCrossBase
                    std       TwLim
                    ldd       TwCr
                    bpl       of1@
                    coma
                    comb
                    addd      #NegCarry
of1@                cmpd      TwLim
                    bhi       of8@
                    ldd       >FsAgl
                    cmpd      #FinMaxAgl
                    bhi       of8@
                    bsr       HdgOK
                    rts
of8@                orcc      #Carry
                    rts

* Ends: the tuned airport's runway ends: TwI counts, X the first (U = the airport)
Ends                clr       TwI
                    lda       15,u
                    lbra      EndP
* InFm: X = a runway end: Z clear when its runway is one of TwFm's. A, B clobbered.
InFm                pshs      x
                    ldb       15,x
                    ldx       #TwBits
                    lda       b,x
                    anda      TwFm
                    puls      x,pc
TwBits              fcb       1,2,4,8,16,32,64,128
* FinEnd: A = the end whose final the aircraft is on ($FF none). U = the airport.
FinEnd              pshs      x
                    bsr       Ends
fn1@                lda       TwI
                    cmpa      16,u
                    bhs       fn8@
                    bsr       InFm
                    beq       fn3@
                    lbsr      End
                    bsr       OnFin
                    bcc       fn2@
fn3@                    leax      TeSize,x
                    inc       TwI
                    bra       fn1@
fn2@                lda       TwI
                    adda      15,u
                    puls      x,pc
fn8@                lda       #TwNoEnd
                    puls      x,pc
* RwyEnd: A = the end the aircraft is on, rolling along it ($FF none); RwyAny: on any end's runway, any heading
RwyEnd              clr       TwHd
                    bra       re0@
RwyAny              lda       #TwHdAny
                    sta       TwHd
re0@                pshs      x
                    bsr       Ends
re1@                lda       TwI
                    cmpa      16,u
                    bhs       re8@
                    lbsr      End
                    lbsr      OnEnd
                    bcs       re2@
                    tst       TwHd
                    bne       re3@
                    lbsr      HdgOK
                    bcc       re3@
re2@                leax      TeSize,x
                    inc       TwI
                    bra       re1@
re3@                lda       TwI
                    adda      15,u
                    puls      x,pc
re8@                lda       #TwNoEnd
                    puls      x,pc

* UseEnd: A = the runway end in use among the tuned frequency's runways (TwMask): the one most into the surface
* wind, below 5 knots the one nearest the airport's calm heading
UseEnd              pshs      x
                    lda       TwMask              among the tuned frequency's runways
                    sta       TwFm
                    lda       >FsWind
                    anda      #WindKnotsMask
                    cmpa      #UseEndCalmKt
                    bhs       ue1@
                    lda       17,u                calm: the end nearest the airport's calm heading
                    bra       ue1a@
ue1@                lda       >FsWind+2
ue1a@               sta       TwWd
                    lda       #UseEndWorst
                    sta       TwBest
                    clr       TwPick
                    lbsr      Ends
ue2@                lda       TwI
                    cmpa      16,u
                    bhs       ue8@
                    lbsr      InFm
                    beq       ue4@
                    lda       4,x
                    suba      TwWd
                    bpl       ue3@
                    nega
ue3@                cmpa      TwBest
                    bhs       ue4@
                    sta       TwBest
                    lda       TwI
                    sta       TwPick
ue4@                leax      TeSize,x
                    inc       TwI
                    bra       ue2@
ue8@                lda       TwPick
                    adda      15,u
                    puls      x,pc

* ActPh: A = the actor's phase (twr_data.asm), $FF when there is none
ActPh               pshs      x
                    lda       >FswTfPt
                    cmpa      #TwActN
                    bhs       ap8@
                    ldx       #TwAct
                    lsla
                    lda       a,x
                    puls      x,pc
ap8@                lda       #TwNoPhase
                    puls      x,pc
* RwyBusy: A = a runway end, B nonzero (a departure): the actor on final counts too, and the actor in the air
* anywhere in the end's departure path (DepConf: where it is now). Carry set when the actor holds that runway (on
* it: lining up, rolling for takeoff or out after landing). Only O'Hare has the actor.
RwyBusy             pshs      a,b,x
                    tst       TwApt
                    bne       rb8@
                    lbsr      EndP
                    lda       15,x
                    ldx       TwAptP
                    cmpa      18,x
                    bne       rb8@
                    bsr       ActPh
                    cmpa      #ActPhTakeoff
                    beq       rb9@
                    cmpa      #ActPhRollout
                    beq       rb9@
                    cmpa      #ActPhLineUp
                    beq       rb9@
                    tst       1,s
                    beq       rb8@
                    cmpa      #ActPhFinal
                    beq       rb9@
rb8@                tst       1,s                 a departure: the actor in its path?
                    beq       rb7@
                    lda       ,s
                    lbsr      DepConf
                    bcs       rb9@
rb7@                andcc     #^Carry
                    puls      a,b,x,pc
rb9@                orcc      #Carry
                    puls      a,b,x,pc
* DepConf: A = a runway end: carry set when the actor is in the air (climbing out, in its pattern, going around)
* inside that end's departure path: from the threshold to 6 km past the runway's far end, within 1.5 km of the
* centerline. Where it is now: fst's bearing from the nose (FswTfBrg, degrees) and distance (FswTfDst, 100 m)
* with the aircraft's heading and position (TwE, TwN), wherever the actor's plan has taken it. U kept.
DepConf             pshs      a,b,x,y
                    tst       TwApt               O'Hare only
                    lbne      dc8@
                    lbsr      ActPh
                    cmpa      #ActPhClimb
                    beq       dc1@
                    cmpa      #ActPhPattern
                    beq       dc1@
                    cmpa      #ActPhGoAround
                    lbne      dc8@
dc1@                ldd       >FswTfDst           beyond 10 km: clear of any path here
                    cmpd      #DepConfRange
                    lbhs      dc8@
                    lda       #TfDstMeters        its meters
                    mul
                    std       TwDm
                    ldb       >FswTfBrg+1         its true bearing, 1/256 turn: the heading + the bearing x 182 / 256
                    lda       #Deg2Turn256        (a bearing under 512: its high byte 0 or 1)
                    mul
                    sta       TwBa
                    tst       >FswTfBrg
                    beq       dc2@
                    lda       #Deg2Turn256
                    adda      TwBa
                    sta       TwBa
dc2@                lda       TwBa
                    adda      >FsHdg
                    sta       TwBa
                    lbsr      SinQ7               east: TwE + d sin
                    sta       TwM
                    ldd       TwDm
                    lbsr      MulS
                    lbsr      Q7m
                    addd      TwE
                    pshs      d
                    lda       TwBa                north: TwN + d cos
                    adda      #Angle8Quarter
                    lbsr      SinQ7
                    sta       TwM
                    ldd       TwDm
                    lbsr      MulS
                    lbsr      Q7m
                    addd      TwN
                    ldx       TwE                 the aircraft's position kept, the actor's taken for End
                    ldy       TwN
                    std       TwN
                    puls      d
                    std       TwE
                    pshs      x,y
                    lda       4,s                 the runway end (the caller's A)
                    lbsr      EndP
                    lbsr      End
                    puls      d
                    std       TwE
                    puls      d
                    std       TwN
                    ldd       TwAl                along: the threshold to 6 km past the far end
                    bmi       dc8@
                    ldy       7,x                 the runway's length
                    leay      6000,y
                    pshs      y
                    cmpd      ,s++
                    bgt       dc8@
                    ldd       TwCr                across: within 1.5 km
                    bpl       dc3@
                    coma
                    comb
                    addd      #NegCarry
dc3@                cmpd      #DepPathHalfW
                    bhs       dc8@
                    orcc      #Carry
                    puls      a,b,x,y,pc
dc8@                andcc     #^Carry
                    puls      a,b,x,y,pc
* Q7m: D = TwP (MulS's 24-bit product) >> 7. TwQ3 cleared.
Q7m                 clr       TwQ3
                    clr       TwQ3+1
                    clr       TwQ3+2
                    lbra      A24
* SinQ7: A = an angle (256 a turn): A = its sine, signed Q7 (SinT: a quarter turn). B clobbered.
SinQ7               pshs      x
                    ldx       #SinT
                    tfr       a,b
                    andb      #Angle8QuarterMask  within the quadrant
                    bita      #Angle8Quarter
                    beq       sq1@
                    negb                          the 2nd and 4th: from the other end
                    addb      #Angle8Quarter
sq1@                pshs      a
                    lda       b,x
                    tst       ,s+
                    bpl       sq2@                the 3rd and 4th: negative
                    nega
sq2@                puls      x,pc
SinT                fcb       0,3,6,9,12,16,19,22,25,28,31,34,37,40,43,46,49,51,54,57,60,63,65,68,71,73,76,78,81,83
                    fcb       85,88,90,92,94,96,98,100,102,104,106,107,109,111,112,113,115,116,117,118,120,121,122
                    fcb       122,123,124,125,125,126,126,126,127,127,127,127

********************************************************************
* The calls
* TwTalk: the talk key, on the tower frequency, the tower not talking: the call the situation implies, answered
TwTalk              lda       TwMode
                    cmpa      #TwModeTower
                    beq       tk0@
                    cmpa      #TwModeGround       ground control
                    lbne      tk9@
tk0@                lbsr      TwBusy
                    lbne      tk9@
                    ldu       TwAptP
                    lbsr      AtisLet             the current ATIS heard?
                    sta       TwLet
                    cmpa      TwAtisL
                    beq       tk1@
                    lbsr      SayCS               no: check ATIS, information (the current letter)
                    lda       12,u                the tower's call ("O'Hare tower,"), or ground's
                    ldb       TwMode
                    cmpb      #TwModeGround
                    bne       tk0a@
                    lda       22,u
tk0a@               lbsr      Say
                    lda       #P_CHECK_ATIS
                    lbsr      Say
                    lda       TwLet
                    lbra      Say
tk1@                lda       TwMode              ground control: the taxi clearance
                    cmpa      #TwModeGround
                    lbeq      TwGround
                    tst       >FsGnd
                    beq       tk5@
                    ldd       #FieldRange         on the ground at the field
                    lbsr      Near
                    bcs       tk9@
                    lbsr      UseEnd
                    sta       TwRwy
                    ldb       #RwyBusyDep
                    lbsr      RwyBusy
                    bcc       tk3@
                    lbsr      Head                hold short
                    lda       #P_HOLD_SHORT
                    lbsr      Say
                    lbsr      SayRwy
                    lbsr      ActPh               the actor on final, on the runway, or crossing the departure path
                    ldb       #P_TRAFFIC_FINAL
                    cmpa      #ActPhFinal
                    beq       tk2@
                    ldb       #P_TRAFFIC_DEP
                    cmpa      #ActPhClimb
                    beq       tk2@
                    cmpa      #ActPhPattern
                    beq       tk2@
                    cmpa      #ActPhGoAround
                    beq       tk2@
                    ldb       #P_TRAFFIC_RWY
tk2@                tfr       b,a
                    lbsr      Say
                    lda       #S_HOLD
                    sta       TwSt
                    rts
tk3@                lbsr      Head                cleared for takeoff
                    lbsr      SayRwy
                    lbsr      SayWind
                    lda       #P_CLR_TO
                    lbsr      Say
                    lda       #S_CLRTO
                    sta       TwSt
tk9@                rts
tk5@                ldd       #AirRange           in the air within 10 nm
                    lbsr      Near
                    bcs       tk9@
                    lda       TwMask              on a final of this frequency's runways?
                    sta       TwFm
                    lbsr      FinEnd
                    cmpa      #TwNoEnd
                    beq       tk7@
                    sta       TwRwy               on a final: landing
                    clrb
                    lbsr      RwyBusy
                    bcc       tk6@
                    lbsr      SayCS
                    lda       #P_CONTINUE
                    lbsr      Say
                    lda       #P_TRAFFIC_RWY
                    lbsr      Say
                    lda       #S_CONT
                    sta       TwSt
                    rts
tk6@                lbsr      SayCS
                    lbsr      SayRwy
                    lda       #P_CLR_LAND
                    lbsr      Say
                    lda       #S_CLRL
                    sta       TwSt
                    rts
tk7@                lbsr      UseEnd              inbound: the pattern
                    sta       TwRwy
                    lbsr      Head
                    lda       TwRwy
                    lbsr      EndP
                    lda       #P_ENTER_LDW
                    tst       14,x
                    beq       tk8@
                    lda       #P_ENTER_RDW
tk8@                lbsr      Say
                    lbsr      SayRwy
                    lda       #S_INB
                    sta       TwSt
                    rts
* Head: the call sign and the tower's name, and on the first call the squawk assigned
Head                lbsr      SayCS
                    lda       12,u
                    lbsr      Say
                    ldd       TwSq
                    bne       hd9@
                    lbsr      NewSq
                    lbsr      SaySq
                    lda       #SqChkDelay
                    sta       TwSqT
hd9@                rts
* ObsZ: A = the hour of the ATIS observation in Zulu: the last :51 of FS's clock (local: UTC-6 in winter, -5
* in spring, summer and fall, daylight time)
ObsZ                lda       >FsHour
                    ldb       >FsMin
                    cmpb      #AtisObsMin
                    bhs       oz1@
                    deca
                    bpl       oz1@
                    lda       #LastHour
oz1@                ldb       >FsSeason
                    andb      #SeasonMask
                    cmpb      #SeasonWinter
                    bne       oz2@
                    adda      #UtcOfsWinter
                    bra       oz3@
oz2@                adda      #UtcOfsDst
oz3@                cmpa      #ClockHours
                    blo       oz9@
                    suba      #ClockHours
oz9@                rts
* AtisLet: A = the information letter's piece: a new observation an hour, a new letter (0 Zulu Bravo)
AtisLet             bsr       ObsZ
                    inca
                    adda      #P_L_ALPHA
                    rts

* TwSecond: once a second: the timers, the ATIS, the ground and air changes, the clearances that were waiting,
* the squawk check and the dangers
TwSecond            ldx       #TwGaT
                    ldb       #TwTimerCount       TwGaT, TwTaT, TwStT, TwAtT, TwSqT, TwTrT
sc1@                tst       ,x
                    beq       sc2@
                    dec       ,x
sc2@                leax      1,x
                    decb
                    bne       sc1@
                    ldu       TwAptP
                    lda       TwMode
                    cmpa      #TwModeAtis
                    lbeq      TwAtisS
                    cmpa      #TwModeTower
                    beq       sc2a@
                    cmpa      #TwModeGround       ground control: the ATIS on the other radio, nothing else
                    bne       sc2b@
                    tst       TwAtOn
                    lbne      TwAtisS
sc2b@               rts
sc2a@               tst       TwAtOn              the ATIS on the other radio: while the tower is quiet
                    beq       sc3@
                    lbsr      TwAtisS
                    ldu       TwAptP
sc3@                lda       >FsGnd              on the ground: the end it rolls on (the takeoff's)
                    beq       sc4@
                    lbsr      RwyEnd
                    cmpa      #TwNoEnd
                    beq       sc4@
                    sta       TwOnEnd
sc4@                lbsr      GndNow              taken off or landed?
                    cmpa      TwGnd
                    beq       sc5@
                    sta       TwGnd
                    ldd       #FieldRange
                    lbsr      Near
                    bcs       sc5@                away from the field: nothing to say
                    tst       TwGnd
                    lbeq      TwTakeoff
                    lbra      TwLanded
sc5@                lbsr      Danger              the dangers first: they cut in
                    lbsr      TrafAdv             then the traffic near (the actor where it is now)
                    lbsr      SqChk
sc6@                lbsr      TwBusy
                    bne       sc9@
                    lda       TwSt
                    cmpa      #S_HOLD
                    bne       sc7@
                    lda       TwRwy               holding: the runway clear?
                    ldb       #RwyBusyDep
                    lbsr      RwyBusy
                    bcs       sc9@
                    lbsr      SayCS
                    lbsr      SayRwy
                    lbsr      SayWind
                    lda       #P_CLR_TO
                    lbsr      Say
                    lda       #S_CLRTO
                    sta       TwSt
                    rts
sc7@                cmpa      #S_CONT
                    bne       sc8@
                    lda       TwRwy               continuing: the runway clear?
                    clrb
                    lbsr      RwyBusy
                    bcs       sc9@
                    lbsr      SayCS
                    lbsr      SayRwy
                    lda       #P_CLR_LAND
                    lbsr      Say
                    lda       #S_CLRL
                    sta       TwSt
                    rts
sc8@                cmpa      #S_ROLL
                    bne       sc10@
                    ldd       >FsSpd              rolled out below 30 knots: off the runway
                    cmpd      #RollOutSpd
                    bhs       sc9@
                    lbsr      SayCS               turn off at the next taxiway, contact ground (its frequency)
                    lda       #P_TURN_OFF
                    lbsr      Say
                    lda       #P_CONTACT_GND
                    lbsr      Say
                    ldu       TwAptP
                    ldd       20,u
                    lbsr      SayFreq
                    lda       #S_GND
                    sta       TwSt
sc9@                rts
sc10@               rts

* TwGround (TwTalk on ground control's frequency, the ATIS heard, U = the airport): on the ground at the field the
* taxi clearance to the runway in use, hold short, then the tower of that runway with its frequency: "Cherokee zero
* niner Whiskey, taxi to runway nine center, hold short, contact tower one two one point one five when ready."
* In the air no answer (ground control works the ground only).
TwGround            tst       >FsGnd
                    beq       gr9@
                    ldd       #FieldRange
                    lbsr      Near
                    bcs       gr9@
                    lbsr      UseEnd
                    sta       TwRwy
                    lbsr      SayCS
                    lda       #P_TAXI_TO
                    lbsr      Say
                    lbsr      SayRwy
                    lda       #P_HOLD_SHORT
                    lbsr      Say
                    lbsr      Brk
                    lda       #P_CONTACT_TWR
                    lbsr      Say
                    lbsr      TwTwrF
                    lbsr      SayFreq
                    lda       #P_WHEN_READY
                    lbsr      Say
                    lda       #S_TAXI
                    sta       TwSt
gr9@                rts
* TwTwrF: D = the tower frequency (BCD) that handles runway end TwRwy (U = the airport: its table at 10,u, 19,u
* entries); the first one when none does. X kept.
TwTwrF              pshs      x
                    lda       TwRwy
                    lbsr      EndP                X = the end's record
                    ldb       15,x                its runway number
                    ldx       #TwBits
                    lda       b,x                 its bit
                    ldx       10,u
                    ldb       19,u
tf1@                bita      2,x
                    bne       tf2@
                    leax      3,x
                    decb
                    bne       tf1@
                    ldx       10,u                none: the first
tf2@                ldd       ,x
                    puls      x,pc
* SayFreq: D = a COM frequency (BCD past 100: $2115) spoken: "one two one point one five" (a last 0 not said).
* Registers kept.
SayFreq             pshs      d
                    lda       #P_D1
                    lbsr      Say
                    lda       ,s
                    lsra
                    lsra
                    lsra
                    lsra
                    adda      #P_D0
                    lbsr      Say
                    lda       ,s
                    anda      #BcdLoDigit
                    adda      #P_D0
                    lbsr      Say
                    lda       #P_POINT
                    lbsr      Say
                    lda       1,s
                    lsra
                    lsra
                    lsra
                    lsra
                    adda      #P_D0
                    lbsr      Say
                    lda       1,s
                    anda      #BcdLoDigit
                    beq       sf9@
                    adda      #P_D0
                    lbsr      Say
sf9@                puls      d,pc

* TwTakeoff: just airborne near the field: without the takeoff clearance, or from another runway end, told
TwTakeoff           tst       >FsDemo             the demo flies itself: no violation
                    bne       to2@
                    lda       TwSt
                    cmpa      #S_CLRTO
                    beq       to1@
                    lbsr      Urgent
                    lda       #P_U_NO_TO
                    lbsr      Say
                    bra       to2@
to1@                lda       TwOnEnd
                    cmpa      TwRwy
                    beq       to2@
                    lbsr      Urgent
                    lda       #P_U_WRONG_RWY
                    lbsr      Say
to2@                lda       #S_DEP
                    sta       TwSt
                    rts
* TwLanded: just down near the field: without the landing clearance, or on another runway end, told
TwLanded            tst       >FsDemo             the demo flies itself: no violation
                    bne       ld2@
                    lda       TwSt
                    cmpa      #S_CLRL
                    beq       ld1@
                    lbsr      Urgent
                    lda       #P_U_NO_LAND
                    lbsr      Say
                    bra       ld2@
ld1@                lbsr      RwyEnd
                    cmpa      TwRwy
                    beq       ld2@
                    lbsr      Urgent
                    lda       #P_U_WRONG_RWY
                    lbsr      Say
ld2@                lda       #S_ROLL
                    sta       TwSt
                    rts

* TrafAdv (TwSecond on the tower's frequency, Roger 2026-10-21: live updates on the actor): the actor within 5 nm
* of the aircraft in the air, not within 1 km (Danger's alert): "Cherokee zero niner Whiskey, traffic, Cherokee,
* (clock) o'clock, (miles) miles." from fst's bearing from the nose and distance (where it is now), again every 30 s
* while it stays that near.
TrafAdv             tst       >FsGnd
                    lbne      ta9@
                    tst       TwApt               O'Hare only
                    lbne      ta9@
                    tst       TwTrT
                    lbne      ta9@
                    ldd       >FswTfDst
                    cmpd      #TrafAdvRange       5 nm: 9.26 km
                    lbhs      ta9@
                    cmpd      #TrafAlertRange     within 1 km: Danger's traffic alert
                    lblo      ta9@
                    lbsr      TwBusy
                    lbne      ta9@
                    lbsr      SayCS
                    lda       #P_TRF_TF
                    lbsr      Say
                    ldd       >FswTfBrg           the clock: (bearing + 15) / 30, 0 as 12
                    addd      #ClockHalfDeg
                    ldx       #QuotStart
ta1@                subd      #ClockHourDeg
                    blo       ta2@
                    leax      1,x
                    bra       ta1@
ta2@                tfr       x,d
                    tstb
                    bne       ta3@
                    ldb       #ClockFaceHours
ta3@                addb      #P_C_BASE
                    tfr       b,a
                    lbsr      Say
                    ldd       >FswTfDst           the miles: (100 m x 54 + 500) / 1000, 1-5
                    lda       #TfNmPer100m        (under 93: B alone)
                    mul
                    addd      #TfNmRound
                    ldx       #QuotStart
ta5@                subd      #TfNmScale
                    blo       ta6@
                    leax      1,x
                    bra       ta5@
ta6@                tfr       x,d
                    tstb
                    bne       ta7@
                    ldb       #TrafMilesMin
ta7@                cmpb      #TrafMilesMax
                    bls       ta8@
                    ldb       #TrafMilesMax
ta8@                addb      #P_MI_BASE
                    tfr       b,a
                    lbsr      Say
                    lda       #TrafAdvRepeat
                    sta       TwTrT
ta9@                rts

* SqChk: the squawk assigned against the XPDR, 30 s after the assignment, then a minute after each reminder
SqChk               ldd       TwSq
                    beq       sq9@
                    tst       TwSqT
                    bne       sq9@
                    ldd       >FsXpdr
                    cmpd      TwSq
                    beq       sq8@
                    lbsr      TwBusy
                    bne       sq9@
                    lbsr      Urgent
                    lda       #P_U_WRONG_SQ
                    lbsr      Say
                    lbsr      SaySq
                    lda       #SqRemindRepeat
                    sta       TwSqT
                    rts
sq8@                lda       #SqRecheck
                    sta       TwSqT
sq9@                rts

* Danger: an unstable final or the actor on the runway under the aircraft's final (go around), a roll on a runway
* without clearance while the actor is on final (stop), the actor within 1 km in the air (traffic alert)
Danger              tst       >FsGnd
                    lbne      dg5@
                    ldd       #AirRange           in the air within 10 nm: on a final, low?
                    lbsr      Near
                    bcs       dg3@
                    lda       #TwAllRwys          any runway's
                    sta       TwFm
                    lbsr      FinEnd
                    cmpa      #TwNoEnd
                    beq       dg3@
                    sta       TwFin
                    ldd       >FsAgl
                    cmpd      #DangerFinAgl
                    bhi       dg3@
                    lda       TwFin
                    clrb
                    lbsr      RwyBusy
                    bcs       dg1@
                    ldd       >FsAgl              unstable: below 150 m faster than 140 knots
                    cmpd      #UnstableAgl
                    bhi       dg3@
                    ldd       >FsSpd
                    cmpd      #UnstableSpd
                    blo       dg3@
dg1@                tst       TwGaT
                    bne       dg3@
                    lbsr      Flush
                    lbsr      Urgent
                    lda       #P_U_GO_AROUND
                    lbsr      Say
                    lda       #GoAroundRepeat
                    sta       TwGaT
                    lda       #S_INB
                    sta       TwSt
                    rts
dg3@                lbsr      ActPh               the actor in the air within 1 km?
                    cmpa      #TwNoPhase
                    beq       dg9@
                    cmpa      #ActPhClimb
                    blo       dg9@
                    cmpa      #ActPhRollout
                    beq       dg9@
                    cmpa      #ActPhLineUp
                    beq       dg9@
                    ldd       >FswTfDst
                    cmpd      #TrafAlertRange
                    bhi       dg9@
                    tst       TwTaT
                    bne       dg9@
                    lbsr      Flush
                    lbsr      Urgent
                    lda       #P_U_TRAFFIC
                    lbsr      Say
                    ldd       >FswTfBrg           its clock position: (bearing + 15) / 30, 0 = 12
                    addd      #ClockHalfDeg
                    clr       TwK
dg4@                subd      #ClockHourDeg
                    bcs       dg4a@
                    inc       TwK
                    bra       dg4@
dg4a@               lda       TwK
                    anda      #ClockCountMask
                    cmpa      #ClockFaceHours
                    blo       dg4b@
                    suba      #ClockFaceHours
dg4b@               tsta
                    bne       dg4c@
                    lda       #ClockFaceHours
dg4c@               adda      #P_U_C_BASE
                    lbsr      Say
                    lda       #P_U_TURN_L         turn away: left of traffic on the right, right of traffic
                    ldb       TwK                 head on, behind or on the left
                    beq       dg4e@
                    cmpb      #ClockBehind
                    blo       dg4d@
dg4e@               lda       #P_U_TURN_R
dg4d@               lbsr      Say
                    lda       #TrafAlertRepeat
                    sta       TwTaT
dg9@                rts
dg5@                ldd       >FsSpd              on the ground: rolling on a runway without clearance, the actor
                    cmpd      #RollingSpd         on its final
                    blo       dg9@
                    lda       TwSt
                    cmpa      #S_CLRTO
                    beq       dg9@
                    lbsr      RwyAny
                    cmpa      #TwNoEnd
                    beq       dg9@
                    pshs      a
                    lbsr      ActPh
                    cmpa      #ActPhFinal
                    puls      a
                    bne       dg9@
                    pshs      x                   the actor's runway?
                    lbsr      EndP
                    ldb       15,x
                    puls      x
                    tst       TwApt
                    bne       dg9@
                    pshs      x
                    ldx       TwAptP
                    cmpb      18,x
                    puls      x
                    bne       dg9@
                    tst       TwStT
                    bne       dg9@
                    lbsr      Flush
                    lbsr      Urgent
                    lda       #P_U_STOP
                    lbsr      Say
                    lda       #StopRepeat
                    sta       TwStT
                    rts

* TwAtisS: on the ATIS frequency, the tower not talking for 3 s: the broadcast again (its letter heard: TwAtisL).
* Chicago O'Hare International Airport, information (letter). (hh)51 Zulu. Wind ... Visibility one zero. Ceiling
* ... overcast (or sky clear). Temperature ..., dew point .... Altimeter two niner niner five. I L S approach runway
* ... in use. Landing and departing runway .... Read back all runway hold short instructions. Advise on initial
* contact you have information (letter).
* U = the airport. TwInAt marks its own TwBusy and Say; TwAtPl the broadcast queued (the tower may cut it).
TwAtisS             lda       #TwInAtOn
                    sta       TwInAt
                    bsr       AtisQ
                    clr       TwInAt
                    rts
AtisQ               lbsr      TwBusy
                    beq       at1@
                    lda       #AtisQuietGap       speech: the broadcast again 3 s after it (the tower's)
                    tst       TwAtPl
                    beq       at0@
                    lda       #AtisRepeat         or a minute after the broadcast itself (Roger 2026-10-21)
at0@                cmpa      TwAtT               a longer wait kept
                    bls       at0a@
                    sta       TwAtT
at0a@               rts
at1@                tst       TwAtT
                    lbne      at9@
                    lda       #TwAtPlOn
                    sta       TwAtPl
                    lda       13,u
                    lbsr      Say
                    lbsr      AtisLet
                    sta       TwLet
                    lbsr      Say
                    lbsr      Brk                 a pause after each sentence (Roger 2026-10-21)
                    lbsr      ObsZ                the observation: hh51 Zulu
                    lbsr      Tens
                    ldb       #ObsMinTens
                    lbsr      SayDig
                    ldb       #ObsMinOnes
                    lbsr      SayDig
                    lda       #P_ZULU
                    lbsr      Say
                    lbsr      Brk
                    lbsr      SayWind
                    lbsr      Brk
                    lda       #P_VIS10
                    lbsr      Say
                    lbsr      Brk
                    lbsr      SaySky
                    lbsr      Brk
                    lbsr      SayTemp
                    lbsr      Brk
                    lda       #P_ALTIM
                    lbsr      Say
                    lbsr      Brk
                    lda       TwRwy               the runway in use (the tower's, for every frequency)
                    sta       TwSave
                    lbsr      UseEnd
                    sta       TwRwy
                    lda       #P_ILS
                    lbsr      Say
                    lbsr      SayRwy
                    lda       #P_INUSE
                    lbsr      Say
                    lbsr      Brk
                    lda       #P_LDG_DEP
                    lbsr      Say
                    lbsr      SayRwy
                    lbsr      Brk
                    lda       TwSave
                    sta       TwRwy
                    lda       #P_READBACK
                    lbsr      Say
                    lbsr      Brk
                    lda       #P_ADVISE
                    lbsr      Say
                    lda       TwLet
                    lbsr      Say
                    sta       TwAtisL
                    lda       #AtisRepeat         the next broadcast a minute after this one
                    sta       TwAtT
at9@                rts

* SaySky: F2's cloud layers (feet MSL, a layer where its top is above its bottom) as ceilings above the field,
* the lower first: "Ceiling (height) overcast. (height) overcast." (FS2's layers are solid), else "Sky clear."
SaySky              ldd       >FsCloud+6          layer 1: bottom, top
                    ldx       >FsCloud+4
                    bsr       Agl
                    std       TwB1
                    ldd       >FsCloud+2          layer 2
                    ldx       >FsCloud
                    bsr       Agl
                    std       TwB2
                    cmpd      TwB1
                    bhs       sk1@
                    ldx       TwB1
                    std       TwB1
                    stx       TwB2
sk1@                ldd       TwB1
                    cmpd      #TwNoLayer
                    bne       sk2@
                    lda       #P_SKY_CLR
                    lbra      Say
sk2@                lda       #P_CEILING
                    lbsr      Say
                    ldd       TwB1
                    bsr       SayFt
                    lda       #P_OVC
                    lbsr      Say
                    ldd       TwB2
                    cmpd      #TwNoLayer
                    beq       sk9@
                    bsr       SayFt
                    lda       #P_OVC
                    lbra      Say
sk9@                rts
* Agl: D = a layer's bottom, X its top (feet MSL): D = the bottom above the field (100 at least), $FFFF no layer
Agl                 pshs      d
                    cmpx      ,s++
                    bls       ag8@
                    subd      #TwElev
                    cmpd      #CeilMinFt
                    bge       ag9@
                    ldd       #CeilMinFt
ag9@                rts
ag8@                ldd       #TwNoLayer
                    rts
* SayFt: D = feet (100 and up): "(thousands) thousand (hundreds) hundred", to the nearest hundred
SayFt               clr       TwK
sf1@                cmpd      #FtThousand
                    blo       sf2@
                    subd      #FtThousand
                    inc       TwK
                    bra       sf1@
sf2@                addd      #FtRound
                    clr       TwK2
sf3@                cmpd      #FtHundred
                    blo       sf4@
                    subd      #FtHundred
                    inc       TwK2
                    bra       sf3@
sf4@                lda       TwK2
                    cmpa      #FtHundredsPerK
                    blo       sf5@
                    clr       TwK2
                    inc       TwK
sf5@                lda       TwK
                    beq       sf7@
                    cmpa      #DecBase
                    blo       sf6@
                    lbsr      Tens
                    bra       sf6a@
sf6@                tfr       a,b
                    lbsr      SayDig
sf6a@               lda       #P_THOUSAND
                    lbsr      Say
sf7@                ldb       TwK2
                    beq       sf9@
                    lbsr      SayDig
                    lda       #P_HUNDRED
                    lbra      Say
sf9@                rts

* SayTemp: "Temperature (t), dew point (d)", degrees Celsius. FS2 has no temperature: Chicago's normals for the
* season (TwClim: low, high, the dew point's low and high) through the day, coldest at 05, warmest at 15; under a
* ceiling below 5,000 ft the dew point within 3 of the temperature
SayTemp             lda       >FsSeason
                    anda      #SeasonMask
                    lsla
                    lsla
                    ldx       #TwClim
                    leax      a,x
                    lda       >FsHour             the day's fraction in tenths: 05 -> 15 rising, then falling
                    suba      #ColdestHour
                    bpl       te1@
                    adda      #ClockHours
te1@                cmpa      #WarmingHours
                    bls       te2@
                    suba      #WarmingHours       hours past 15 (1-13 of 14)
                    ldb       #CoolingNum
                    mul
                    addb      #CoolingRound
                    lda       #QuotStart
te1a@               cmpb      #CoolingDen         /7
                    blo       te1b@
                    subb      #CoolingDen
                    inca
                    bra       te1a@
te1b@               nega
                    adda      #TenthsWhole
te2@                sta       TwF
                    lda       ,x                  the temperature: low + (high - low) x f / 10
                    ldb       1,x
                    bsr       Blend
                    sta       TwTc
                    lda       2,x                 the dew point
                    ldb       3,x
                    bsr       Blend
                    sta       TwTd
                    ldd       TwB1                a ceiling below 5,000: the spread 3 at most
                    cmpd      #LowCeilingFt
                    bhs       te3@
                    lda       TwTc
                    suba      #DewSpreadMax
                    cmpa      TwTd
                    ble       te3@
                    sta       TwTd
te3@                lda       #P_TEMP
                    lbsr      Say
                    lda       TwTc
                    bsr       SayDeg
                    lda       #P_DEW
                    lbsr      Say
                    lda       TwTd
* SayDeg: A = degrees (signed): "minus" below zero, then one or two digits
SayDeg              tsta
                    bpl       sd1@
                    nega
                    pshs      a
                    lda       #P_MINUS
                    lbsr      Say
                    puls      a
sd1@                cmpa      #DecBase
                    blo       sd2@
                    lbra      Tens
sd2@                tfr       a,b
                    lbra      SayDig
* Blend: A = low, B = high (signed, high >= low): A = low + (high - low) x TwF / 10
Blend               pshs      a
                    subb      ,s
                    lda       TwF
                    mul
                    clra
bl1@                cmpb      #TenthsWhole
                    blo       bl2@
                    subb      #TenthsWhole
                    inca
                    bra       bl1@
bl2@                adda      ,s+
                    rts
* Chicago's normals (C): fall (season 4), winter, spring, summer: low, high, the dew point's low and high
TwClim              fcb       6,17,4,6
                    fcb       -9,-1,-12,-8
                    fcb       4,15,0,3
                    fcb       19,29,16,18

* TwActor: the actor reached another point of its plan: the tower's call to it, on O'Hare's tower frequency
TwActor             lda       >FswTfPt
                    cmpa      TwActL
                    beq       ac9@
                    sta       TwActL
                    cmpa      #TwActN
                    bhs       ac9@
                    ldb       TwMode
                    cmpb      #TwModeTower
                    bne       ac9@
                    tst       TwApt
                    bne       ac9@
                    pshs      a                   on the actor's runway's frequency only
                    ldx       TwAptP
                    ldb       18,x
                    ldx       #TwBits
                    lda       b,x
                    anda      TwMask
                    puls      a
                    beq       ac9@
                    ldx       #TwAct
                    lsla
                    leax      a,x
                    lda       1,x
                    beq       ac9@
                    cmpa      #ActEvGoAround
                    bne       ac1@
                    lbsr      Flush               the actor goes around
                    lda       #P_U_TFS
                    lbsr      Say
                    lda       #P_U_GO_AROUND
                    lbra      Say
ac1@                pshs      a
                    lda       #P_TFS
                    lbsr      Say
                    lda       TwRwy
                    pshs      a
                    lda       #TwActEnd
                    sta       TwRwy
                    lbsr      SayRwy
                    puls      a
                    sta       TwRwy
                    puls      a
                    ldb       #P_LUAW
                    cmpa      #ActEvLuaw
                    beq       ac2@
                    ldb       #P_CLR_TO
                    cmpa      #ActEvClrTo
                    beq       ac2@
                    ldb       #P_CLR_LAND
ac2@                tfr       b,a
                    lbra      Say
ac9@                rts

********************************************************************
* The speech: pieces queued (Say), streamed from tower.lpc to /FTDD while VRN's buffer has room (TwStream)
* Say: A = a piece, queued (dropped when the queue is full); the tower's first piece over the ATIS broadcast
* (TwAtPl) flushes it. A new transmission (nothing queued or streaming) within a second of the last speech
* (TwQuiet) starts with a second of silence (P_PAUSE: Roger 2026-10-21, a second after speech ends). The ATIS
* (TwInAt) speaks Zira's copy of each piece (P_NT on; the tower is David). Registers kept.
Say                 pshs      d,x
                    tst       TwHold              no air talk for 5 s after the start or a crash: dropped
                    bne       sq8@
                    tst       TwAtPl
                    beq       sy1@
                    tst       TwInAt
                    bne       sy1@
                    bsr       Flush
                    clr       TwAtPl
sy1@                lda       TwQh                a new transmission?
                    cmpa      TwQt
                    bne       sy2@
                    ldd       TwLen
                    bne       sy2@
                    lda       TwQuiet
                    cmpa      #StepsPerSec        quiet for less than a second (5 timer steps)
                    bhs       sy2@
                    lda       #P_PAUSE
                    bsr       SayQ
sy2@                lda       ,s
                    tst       TwInAt              the ATIS speaks in its own voice: its copy of the piece
                    beq       sy3@                (Zira's, P_NT on; not the pauses)
                    cmpa      #P_NT
                    bhs       sy3@
                    adda      #P_NT
sy3@                bsr       SayQ
sq8@                puls      d,x,pc
* Brk: a 0.4 s pause queued (between sentences). Registers kept.
Brk                 pshs      a
                    lda       #P_BRK
                    lbsr      Say
                    puls      a,pc
* SayQ: A = a piece into the queue (dropped when it is full). B, X clobbered.
SayQ                ldb       TwQh
                    ldx       #TwQ
                    sta       b,x
                    incb
                    andb      #TwQMask
                    cmpb      TwQt
                    beq       sq9@
                    stb       TwQh
sq9@                rts
* Flush: the queue and the piece being streamed dropped (an urgent call next)
Flush               pshs      a
                    lda       TwQh
                    sta       TwQt
                    clr       TwLen
                    clr       TwLen+1
                    puls      a,pc
* TwPurge (fswc's StartPos, a crash reset): no air talk for 5 s again, and the speech stopped (TwHush).
TwPurge             pshs      a
                    lda       #TwHoldN
                    sta       TwHold
                    puls      a
* TwHush (TwPurge; TwStream when a COM button goes off): the speech stopped now: the tower's queue dropped, VRN's
* buffer emptied (SS.SpBy as a SetStat, VRN edition 3: it finishes the chip's current frame with silence) and a
* silent frame written after it, so the chip stops whatever VRN runs (an older VRN, without the SetStat, speaks
* what it holds, at most TwCap bytes, then the silent frame). Registers kept.
TwHush              pshs      d,x,y,u
                    lbsr      Flush
                    clr       TwAtPl
                    lda       >TwPath
                    ldb       #TwSpBy
                    swi2
                    fcb       I$SetStt
                    lda       >TwPath
                    ldx       #PauseFr            its first frame: silent, half a second
                    ldy       #LpcFrame
                    swi2
                    fcb       I$Write
                    ldd       #TwPendNone         nothing pending for the tower (the Morse need not wait)
                    std       TwPend
                    puls      d,x,y,u,pc
* SpBusy: Z clear while speech is queued, streaming or still in VRN's buffer (TwPend, the last GetStat)
SpBusy              pshs      d
                    ldd       TwLen
                    bne       sb9@
                    ldd       TwPend
                    bne       sb9@
                    lda       TwQh
                    cmpa      TwQt
sb9@                puls      d,pc
* TwBusy: Z clear while the tower talks (pieces queued or streaming, or VRN still speaking); Z set when what
* talks is the ATIS broadcast heard beside the tower (TwAtPl) and the tower asks (not TwAtisS): its Say cuts it
TwBusy              pshs      d
                    ldd       TwLen
                    bne       tb1@
                    ldd       TwPend
                    bne       tb1@
                    lda       TwQh
                    cmpa      TwQt
                    bne       tb1@
                    clr       TwAtPl              quiet
                    puls      d,pc
tb1@                tst       TwAtPl
                    beq       tb8@
                    tst       TwInAt
                    bne       tb8@
                    clra                          the ATIS only: not busy for the tower
                    puls      d,pc
tb8@                lda       #TwBusyYes
                    puls      d,pc
* SayCS: the call sign, in full the first time
SayCS               lda       #P_CSS
                    tst       TwFirst
                    bne       cs1@
                    inc       TwFirst
                    lda       #P_CS
cs1@                lbra      Say
* Urgent: the urgent call sign (the next pieces say what)
Urgent              lda       #P_U_CSS
                    lbra      Say
* SayRwy: "runway" and TwRwy's name
SayRwy              pshs      x
                    lda       #P_RUNWAY
                    lbsr      Say
                    lda       TwRwy
                    lbsr      EndP
                    lda       10,x
                    lbsr      Say
                    lda       11,x
                    cmpa      #NoNamePiece
                    beq       sr9@
                    lbsr      Say
                    lda       12,x
                    cmpa      #NoNamePiece
                    beq       sr9@
                    lbsr      Say
sr9@                puls      x,pc
* SayDig: B = 0-9: its digit
SayDig              pshs      a
                    tfr       b,a
                    adda      #P_D0
                    lbsr      Say
                    puls      a,pc
* SayWind: "wind DDD at SS", "wind calm" below 3 knots
SayWind             lda       >FsWind
                    anda      #WindKnotsMask
                    cmpa      #SayCalmKt
                    bhs       sw1@
                    lda       #P_WIND_CALM
                    lbra      Say
sw1@                sta       TwWs
                    lda       #P_WIND
                    lbsr      Say
                    lda       >FsWind+2           tens of degrees: (direction x 45 + 160) / 320, 0 = 36
                    ldb       #WindDirMul
                    mul
                    addd      #WindDirRound
                    clr       TwK
sw2@                subd      #WindDirDiv
                    bcs       sw3@
                    inc       TwK
                    bra       sw2@
sw3@                lda       TwK
                    bne       sw4@
                    lda       #WindNorth
sw4@                bsr       Tens                its two digits, then zero
                    clrb
                    bsr       SayDig
                    lda       #P_AT
                    lbsr      Say
                    lda       TwWs
                    cmpa      #DecBase
                    blo       sw5@
                    bsr       Tens
                    rts
sw5@                tfr       a,b
                    bra       SayDig
* Tens: A = 0-99: its two digits
Tens                clrb
tn1@                cmpa      #DecBase
                    blo       tn2@
                    suba      #DecBase
                    incb
                    bra       tn1@
tn2@                pshs      a
                    bsr       SayDig
                    puls      b
                    bra       SayDig
* SaySq: "squawk" and TwSq's four digits
SaySq               lda       #P_SQUAWK
                    lbsr      Say
                    ldb       TwSq
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    bsr       SayDig
                    ldb       TwSq
                    andb      #BcdLoDigit
                    bsr       SayDig
                    ldb       TwSq+1
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    lbsr      SayDig
                    ldb       TwSq+1
                    andb      #BcdLoDigit
                    lbra      SayDig
* NewSq: TwSq a new code: four octal digits, the first 2-6 (not 1200, no emergency code)
NewSq               lda       >FsSec
                    adda      TwSeed
                    adda      >vMinute
                    sta       TwK
                    clrb
ns1@                cmpa      #SqFirstCount
                    blo       ns2@
                    suba      #SqFirstCount
                    bra       ns1@
ns2@                adda      #SqFirstMin         the first digit
                    lsla
                    lsla
                    lsla
                    lsla
                    sta       TwSq
                    lda       TwK
                    lsra
                    lsra
                    lsra
                    anda      #SqOctalMask
                    ora       TwSq
                    sta       TwSq
                    lda       TwSeed
                    anda      #SqOctalMask
                    lsla
                    lsla
                    lsla
                    lsla
                    sta       TwSq+1
                    lda       TwK
                    eora      TwSeed
                    lsra
                    anda      #SqOctalMask
                    ora       TwSq+1
                    sta       TwSq+1
                    rts

* TwStream: while VRN's buffer holds less than TwCap, the queued pieces streamed into it (at most 256 bytes a
* read); VRN without the speech feeder (an older boot file): the queue dropped. A COM button turned off: the
* speech stopped at once (TwHush); both off: the queue dropped
TwStream            lda       >FswAud
                    anda      #AudComs
                    ldb       TwAudL              a COM button turned off since the last frame?
                    sta       TwAudL
                    coma
                    pshs      a
                    andb      ,s+
                    beq       ts0@
                    lbsr      TwHush              yes: the speech stopped at once
ts0@                tst       TwAudL
                    bne       ts1@
                    lda       TwQh                neither COM heard: what the tower says dropped
                    sta       TwQt
                    clr       TwLen
                    clr       TwLen+1
                    rts
ts1@                lda       TwInit
                    cmpa      #TwInitOpen
                    lbne      st9@
                    lbsr      SpBusy              nothing to stream and VRN quiet: no GetStat this frame
                    lbeq      st9@
                    lda       >TwPath
                    ldb       #TwSpBy
                    swi2
                    fcb       I$GetStt
                    lbcs      st8@
                    stx       TwPend
                    ldd       #TwCap
                    subd      TwPend
                    lbls      st9@
                    std       TwFree
st1@                ldd       TwLen
                    lbne      st2@
                    lda       TwQh                the next piece
                    cmpa      TwQt
                    lbeq      st9@
                    ldb       TwQt
                    ldx       #TwQ
                    lda       b,x
                    ldx       #PauseFr            the second of silence: its two frames when they fit
                    ldy       #PauseN
                    cmpa      #P_PAUSE
                    beq       st1p@
                    ldx       #BrkFr              a sentence's pause: one frame
                    ldy       #LpcFrame
                    cmpa      #P_BRK
                    bne       st1b@
st1p@               sty       TwNn
                    ldd       TwFree
                    cmpd      TwNn
                    lblo      st9@
                    ldb       TwQt
                    incb
                    andb      #TwQMask
                    stb       TwQt
                    lda       >TwPath
                    swi2
                    fcb       I$Write
                    lbcs      st8@
                    ldd       TwPend
                    addd      TwNn
                    std       TwPend
                    ldd       TwFree
                    subd      TwNn
                    std       TwFree
                    lbra      st1@
st1b@               incb
                    andb      #TwQMask
                    stb       TwQt
                    cmpa      #P_N                no such piece: never streamed (a bad one feeds the chip noise)
                    bhs       st1@
                    ldb       #LpcEntSize         its index entry (2 + 6 x the piece): a 32-bit offset, a
                    mul                           16-bit length, read from tower.lpc
                    addd      #LpcHdrSize
                    tfr       d,u
                    ldx       #SeekOfsHi
                    lda       TwFd
                    swi2
                    fcb       I$Seek
                    lbcs      st8@
                    lda       TwFd
                    ldx       #TwEnt
                    ldy       #LpcEntSize
                    swi2
                    fcb       I$Read
                    lbcs      st8@
                    ldx       #TwEnt
                    ldd       4,x
                    std       TwLen
                    ldu       2,x
                    ldx       ,x
                    lda       TwFd
                    swi2
                    fcb       I$Seek
                    bcs       st8@
                    lbra      st1@
st2@                cmpd      TwFree              this read: the piece's rest, the room, 255 at most, in whole
                    bls       st3@                LPC frames (15 bytes; every piece is whole frames): a piece cut
                    ldd       TwFree              short (Flush, a COM button off) leaves VRN whole frames, never
st3@                cmpd      #StreamMax          half of one, which would put every later frame out of step
                    bls       st4@                (static)
                    ldd       #StreamMax
st4@                tfr       b,a
                    clrb
st5@                cmpa      #LpcFrame
                    blo       st6@
                    suba      #LpcFrame
                    addb      #LpcFrame
                    bra       st5@
st6@                tstb
                    lbeq      st9@                no room for a frame: the next frame
                    clra
                    tfr       d,y
                    lda       TwFd
                    ldx       #TwBuf
                    swi2
                    fcb       I$Read
                    bcs       st8@
                    sty       TwNn
                    lda       >TwPath
                    ldx       #TwBuf
                    swi2
                    fcb       I$Write
                    bcs       st8@
                    ldd       TwLen
                    subd      TwNn
                    std       TwLen
                    ldd       TwPend
                    addd      TwNn
                    std       TwPend
                    ldd       TwFree
                    subd      TwNn
                    std       TwFree
                    cmpd      #StreamMinFree
                    lbhs      st1@
st9@                rts
st8@                clr       TwPend
                    clr       TwPend+1
                    lbra      Flush

* the tower's variables
AuArm               fcb       0                   1: Ctrl+R pressed, the audio panel's button next (TwKey)
MoId                fdb       0                   Morse: the ident sent (in MoIds), 0 none
MoCh                fcb       0                   its next letter
MoBits              fcb       $80                 the letter's elements left ($80: none)
MoCnt               fcb       3                   timer steps left in this element or gap
TwDm                fdb       0                   DepConf: the actor's distance (m), its true bearing (1/256 turn)
TwBa                fcb       0
TwQuiet             fcb       $FF                 timer steps (5 a second) since speech last sounded (Say's pause)
TwHold              fcb       TwHoldN             timer steps left with no air talk (the start; a crash: TwPurge)
TwAudL              fcb       3                   TwStream: the COM buttons (FswAud b0-1) last frame
PauseFr             fcb       $80,$80,$00,$80,$80,$63,$80,$80,$32,$80,$80,$80,$80,$80,$80   silent, 50 x 10 ms
                    fcb       $80,$80,$00,$80,$80,$63,$80,$80,$32,$80,$80,$80,$80,$80,$80   (P_PAUSE: a second)
BrkFr               fcb       $80,$80,$00,$80,$80,$63,$80,$80,$28,$80,$80,$80,$80,$80,$80   silent, 40 x 10 ms (P_BRK)
TwTkL               fcb       $FB                 Tower: FsTick as last seen, the steps since (TwTkN)
TwTkN               fcb       0
MoOn                fcb       0                   1: the tone sounds
TwInit              fcb       0                   0: tower.lpc not tried, 1 open, $FF none
TwFd                fcb       0
TwSecL              fcb       $FF                 FS's seconds as last seen
TwSeed              fcb       0
TwApt               fcb       $FF                 the airport tuned last ($FF none)
TwAptP              fdb       TwApts
TwMode              fcb       0                   1 tower, 2 ATIS, 0 neither (or out of range)
TwMask              fcb       0                   the tuned frequency's runways (a bit a runway number)
TwFm                fcb       0                   the runways an end search takes (InFm)
TwCom               fdb       0                   the radio TwFind takes (COM1's, then COM2's), BCD
TwM1                fcb       0                   TwTune: COM1's TwFind (0 none, 1 tower, 2 ATIS) and its runways
TwK1                fcb       0
TwM2                fcb       0                   COM2's TwFind and its runways
TwN2                fcb       0
TwAtOn              fcb       0                   1: the ATIS on the other radio than the tower's
TwAtPl              fcb       0                   1: the ATIS broadcast is what is queued or speaking (the tower cuts it)
TwInAt              fcb       0                   1: inside TwAtisS (its own TwBusy and Say)
Co2Md               fcb       0                   COM2's tuning (Ctrl+K): 0 off, 1 MHz, 2 kHz
TwSt                fcb       0                   S_*
TwRwy               fcb       $FF                 the runway end assigned
TwOnEnd             fcb       $FF                 the runway end rolled on (the takeoff's)
TwFin               fcb       0
TwSq                fdb       0                   the squawk assigned, BCD (0 none)
TwFirst             fcb       0                   1: the short call sign from now on
TwGnd               fcb       0                   on the ground last second
TwAtisL             fcb       0                   the ATIS letter heard (its piece; 0 none)
TwLet               fcb       0                   the current letter's piece
TwB1                fdb       0                   SaySky: the ceilings (ft above the field, $FFFF none), lower first
TwB2                fdb       0
TwK2                fcb       0
TwF                 fcb       0                   SayTemp: the day's fraction (tenths), the temperature, dew point
TwTc                fcb       0
TwTd                fcb       0
TwGaT               fcb       0                   seconds to wait: the next go around, traffic alert, stop, ATIS,
TwTaT               fcb       0                   squawk check, traffic advisory (TwSecond counts the six down in this
*                                                 order)
TwStT               fcb       0
TwAtT               fcb       0
TwSqT               fcb       0
TwTrT               fcb       0                   the next traffic advisory (TrafAdv)
TwActL              fcb       $FF                 the actor's point as last seen
TwOK                fcb       0                   TwE, TwN valid
TwE                 fdb       0                   the aircraft from the airport's reference, meters east, north
TwN                 fdb       0
TwI                 fcb       0
TwK                 fcb       0
TwHd                fcb       0
TwWd                fcb       0
TwWs                fcb       0
TwBest              fcb       0
TwPick              fcb       0
TwSave              fcb       0
TwLim               fdb       0
TwD                 rmb       3
TwDe                fdb       0
TwDn                fdb       0
TwAl                fdb       0                   End: along, across (m)
TwCr                fdb       0
TwM                 fcb       0                   MulS
TwMa                fcb       0
TwSg                fcb       0
TwA                 fdb       0
TwP                 rmb       3
TwQ3                rmb       3
TwPend              fdb       0                   VRN's bytes still to speak (the last GetStat), then this frame's
TwFree              fdb       0
TwNn                fdb       0
TwLen               fdb       0                   the streamed piece's bytes left
TwQh                fcb       0                   the queue: head (next free), tail (next out)
TwQt                fcb       0
TwQ                 rmb       64
TwEnt               rmb       6                   a piece's index entry from tower.lpc: offset (32-bit), length
* TwBuf: a read's bytes on their way to VRN (and the file's first word): fsw's polygon work space past FspAct
* ($2014-$2113), idle while the tower runs (a polygon is filled inside one call; the menus' scratch only while
* they run)
TwBuf               equ       $2014
