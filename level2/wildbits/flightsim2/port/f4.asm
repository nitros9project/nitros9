********************************************************************
* F4 - disassembled OS-9 module (byte-exact lwasm round trip)
* Flight Simulator II (subLOGIC, 1987), CoCo 3 OS-9 Level 2: disassembled from the byte listing ../f4.asm (its first module; FSD follows it in the same file, see fsd.asm).
* An overlay FS maps at $4000 (F2, F3 and F4 share that window): absolute self-references are Lxxxx+ModBase.
* header: type/lang $21 attr/rev $00, exec offset $0020, data size $0000 (0), module size 4096 bytes
* Labels name the routines, branch points and data; ModBase+label is the run address. Data addressing is left numeric (offsets into the
* program's data area, <$xx = direct page). fcb lines inside code carry the decoded mnemonic as a comment
* where the assembler could not be made to reproduce the original encoding.

                    nam       F4
                    ttl       F4 (disassembly)

                    ifp1
                    use       defsfile
                    use       fs_wb.d
                    endc

* Constants: the values this module's instructions use, by name (fs_wb.d holds the addresses)
AmmoFull            equ       $0064               vAmmo at the war's start: the guns' rounds
AsciiZero           equ       $30                 ASCII 0: an enemy's status 0-2 to its digit in the war report
BombAltNone         equ       $0000               vBombAlt ($0816) 0: no bomb falling (the bomb landed)
BombFallStep        equ       $0032               vBombAlt's drop a frame: a falling bomb's height step
BombsFullChar       equ       $35                 vBombsLeft at the war's start: ASCII 5, five bombs
BombsNoneChar       equ       $30                 vBombsLeft with no bomb left: ASCII 0
CarryOnly           equ       $00                 0: an adc or sbc of the carry alone (a rounding bit, a carry or borrow into the next byte)
ComplementBits      equ       $FF                 eor with it: X and Z delta high bytes that are each other's complement ($00, $FF) also give 0
DmgLeakLeft         equ       $04                 vDamageBits bit 2: the left fuel tank leaks
DmgLeakRight        equ       $08                 vDamageBits bit 3: the right fuel tank leaks
DmgOilPress         equ       $02                 vDamageBits bit 1: no oil pressure, the engine's power limited
DmgOilTemp          equ       $01                 vDamageBits bit 0: the oil overheats, the engine's power limited
EnemyAltMin         equ       $01                 an enemy's lowest height, m (its height's low byte)
EnemyAttacking      equ       $02                 an enemy's status (+$17) 2: attacking, chasing the aircraft
EnemyColor          equ       $88                 color 8: an enemy plane's dot and lines (SetLineColor keeps the low nibble)
EnemyDescentStep    equ       $01                 an evading enemy's descent a frame it moves: 1 m (its height's low byte)
EnemyFarFlag        equ       $7F                 vEnemyFar's value: the enemy too far (a delta's high byte is not a sign)
EnemyFireRequest    equ       $01                 vEnemyFired: an enemy fired (bit 0, the ENEMYFIRE message; UpdateWarMessages shifts it out)
EnemyOnRadar        equ       $FF                 an enemy's radar flag (+9): on the scope (it may fire)
EnemyReturning      equ       $01                 an enemy's status (+$17) 1: returning or at home
GunLeftX            equ       $27                 the left gun's tracer start column
GunRightX           equ       $77                 the right gun's tracer start column
GunsightColor       equ       $00                 color 0: the gunsight's lines, no enemy in range
GunsightInRangeColor equ       $44                 color 4: the gunsight's lines while an enemy is in range
GunY                equ       $63                 the guns' tracer start row, just below the view's rows 0-98
HitFailSplit        equ       $3F                 vFrameCount below it, the right tank leaks at a hit; at or above it, the left
HitsDisable         equ       $3C                 vWarDamage (enemy hits) that disables the aircraft
HitsEngine          equ       $28                 vWarDamage from which the oil temperature and pressure fail
HitsLeak            equ       $14                 vWarDamage from which a fuel tank leaks (right or left by the frame counter)
HitsLeftLeak        equ       $07                 vWarDamage from which the left fuel tank may leak
HitsOilPress        equ       $23                 vWarDamage from which the oil pressure fails
HtDeltaHiSmallNeg   equ       $FFFF               the height delta's upper word when it is -256 to -1 m: only its low byte compared
HtDeltaHiSmallPos   equ       $0000               the height delta's upper word when it is 0 to 255 m: only its low byte compared
InRangeRequest      equ       $03                 vEnemyInSight and the target flag: bit 0 the IN RANGE message, bit 1 the gunsight highlighted a frame more
KillScore           equ       $01                 points added to vWarScore for an enemy shot down
MapViewOn           equ       $01                 vMapView in the map view (straight down): no gunsight
NegCarry            equ       $0001               1: completes a two's-complement negation after coma / comb
NotCarry            equ       $FE                 the CC mask that clears the carry bit
OddFrameBit         equ       $01                 vFrameCount's ($0040) bit 0: an evading enemy descends every other frame
PanelReadoutsOff    equ       $7F                 vInstActive2 and vInstPresent+1 without bit 7: the radio, clock and DME readouts not printed
PointClipBits       equ       $0F                 vEnd1Clip's low four bits: set, the enemy's point is not drawn and is no target
RadarAboveColor     equ       $66                 color 6: the radar dot of an enemy above the aircraft
RadarBelowColor     equ       $44                 color 4: the radar dot of an enemy below the aircraft
RadarBgColor        equ       $00                 color 0: the radar scope's background
RadarBotRight       equ       $9E55               the radar scope's bottom right on the panel: column 158, row 85 (FillRect's X)
RadarBottom         equ       $0055               the radar scope's bottom row on the panel
RadarCenterX        equ       $0087               the radar scope's center column on the panel
RadarCenterY        equ       $0040               the radar scope's center row on the panel
RadarLeft           equ       $0070               the radar scope's left column on the panel
RadarLevelColor     equ       $FF                 color 15: the radar dot of an enemy at about the aircraft's height
RadarLevelMax       equ       $1E                 30 m: an enemy lower than the aircraft by less shows level on the radar
RadarLevelMin       equ       $E2                 -30 m: an enemy higher than the aircraft by less shows level on the radar
RadarMarkBoth       equ       $99                 the aircraft's mark on the radar: color 9 in both pixels of a byte
RadarMarkLeft       equ       $90                 the aircraft's mark on the radar: color 9 in a byte's left pixel
RadarMarkRight      equ       $09                 the aircraft's mark on the radar: color 9 in a byte's right pixel
RadarRight          equ       $009E               the radar scope's right column on the panel
RadarScaleX         equ       $0176               Q15 1/87.6: an enemy's meters across to radar scope pixels
RadarScaleY         equ       $01A3               Q15 1/78.2: an enemy's meters along the heading to radar scope rows
RadarTop            equ       $002A               the radar scope's top row on the panel
RadarTopLeft        equ       $702A               the radar scope's top left on the panel: column 112, row 42 (FillRect's A, B)
RangeHidden         equ       $04                 range high byte from which (1024 m) an enemy is not drawn and is no target
RangeShape0         equ       $02                 range high byte from which (512 m) an enemy is drawn as shape 0, never in the gunsight
RangeShape1         equ       $01                 range high byte from which (256 m) an enemy is drawn as shape 1
RangeShape2         equ       $80                 range low byte from which (128 m) an enemy is drawn as shape 2
RangeShape3         equ       $40                 range low byte from which (64 m) an enemy is drawn as shape 3; nearer, shape 4
ReturnTargetAlt     equ       $01                 a returning enemy is no target while the aircraft's height (m) is above this and below 256
RoundsPerShot       equ       $0001               the rounds a shot takes from vAmmo ($0814): 1
RptNumsLen          equ       $002A               vRptNums' length (ShowTextMsgWaitKey)
ScoreWrap           equ       $03E8               vWarScore wraps here (three panel digits)
ShapeMaxX           equ       $9B                 an enemy shape's center column limit (drawn left of it)
ShapeMaxY           equ       $5F                 an enemy shape's center row limit (drawn above it; the view is rows 0-98)
ShapeMinX           equ       $04                 an enemy shape's lowest center column: its lines (up to 4 pixels out) stay in the view
ShapeMinY           equ       $04                 an enemy shape's lowest center row: its lines stay in the view
SightBottom         equ       $41                 the gunsight's window: an enemy in sight is at or above this row
SightLeft           equ       $45                 the gunsight's window: an enemy in sight is right of this column (x 70-90)
SightRight          equ       $5B                 the gunsight's window: an enemy in sight is left of this column
SightTop            equ       $23                 the gunsight's window: an enemy in sight is below this row (rows 36-65)
StatusLineMask      equ       $03                 vStatusLine's low two bits: the four panel status line strings
StatusLineTime      equ       $04                 vStatusWait's start: UpdateWarMessages calls between the panel status line's strings
TracerAxes          equ       $02                 a tracer's coordinates moved toward its aim: x, then y
TracerColor         equ       $FF                 color 15: the tracers
TracerEntrySize     equ       $06                 bytes in one vTracerTbl entry
TracerFrames        equ       $19                 vTracerTime after a round: the frames the tracers stay drawn
TracerHitTime       equ       $0B                 a tracer whose time is below this (its last 10 steps) hits an enemy in the gunsight
TracerTblEnd        equ       $FF                 the time byte that ends vTracerTbl
TracerTblSize       equ       $54                 the 14 tracer entries' bytes: the slot index wraps here
VeteranKills        equ       $04                 vWarKills from which the damage limits are lower
VetHitsDisable      equ       $14                 with VeteranKills: vWarDamage that disables the aircraft
VetHitsEngine       equ       $07                 with VeteranKills: vWarDamage from which the oil temperature and pressure fail
VetHitsLeak         equ       $01                 with VeteranKills: vWarDamage from which a fuel tank leaks
WarAnnounced        equ       $03                 vWarState: the war on, WAR !!!! shown
WarDelayEnd         equ       $0000               the WAR !!!! delay counter's end: 0 again after 65536 passes
WarDelayStart       equ       $0000               the WAR !!!! delay counter's start: 0
WarMsgEnemyFire     equ       $02                 vWarMsgShown: ENEMYFIRE shown
WarMsgInRange       equ       $01                 vWarMsgShown: IN RANGE shown
WarMsgNone          equ       $00                 vWarMsgShown: no war message shown
WarPanelBgColor     equ       $00                 color 0: the war's panel area background
WarPanelBotRight    equ       $9E5B               the war's panel area bottom right: column 158, row 91 (FillRect's X)
WarPanelTopLeft     equ       $7024               the war's panel area top left: column 112, row 36 (FillRect's A, B)
WarReportLen        equ       $011B               MsgWarReport's length (I$Write)
WarStarted          equ       $01                 vWarState bit 0: a bomb hit started the war (WAR !!!! not shown yet)

tylg                set       $21
atrv                set       $00
size                equ       $0000
ModBase             equ       $4000               the address the module runs at

                    mod       eom,name,tylg,atrv,start,size
                    fcb       $00
name                fcs       /F4/
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
start               equ       *
                    jmp       >WarMain+ModBase
                    fcc       /Copyright 1987 subLOGIC. All Rights Reserved./
* MsgWarReport: War report screen text (window codes + labels) written with I$Write, 283 bytes
MsgWarReport        equ       *
* WildBits: no ESC $31 (CoCo palette) on the WildBits terminal: four $00 no-ops each, the same length
                    fcb       $0C,$05,$20,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$02
                    fcc       /% ***** WAR REPORT *****/
                    fcb       $02
                    fcc       /#"Enemy Planes Shot Down = /
                    fcb       $02
                    fcc       /0#Bomb Hits = /
                    fcb       $02
                    fcc       /!$Aircraft Damage by Enemy = /
                    fcb       $02
                    fcc       /!&Enemy Status: 0=Shot Down,/
                    fcb       $02
                    fcc       /!'1=Returning or Home,2=Attacking/
                    fcb       $02
                    fcc       /")Enemy 1 = /
                    fcb       $02
                    fcc       /0)Enemy 2 = /
                    fcb       $02
                    fcc       /"+Enemy 3 = /
                    fcb       $02
                    fcc       /0+Enemy 4 = /
                    fcb       $02
                    fcc       /"-Enemy 5 = /
                    fcb       $02
                    fcc       /0-Enemy 6 = /
                    fcb       $02,$21,$2F
                    fcc       /Press any key to resume battle/
* MsgWarStarted: "WAR !!!!" status message shown when bombing starts the war
MsgWarStarted               fcc       /q%WAR !!!! /
                    fcb       $00
* MsgInRange: "IN RANGE" status message (enemy inside the gunsight)
MsgInRange               fcc       /q%IN RANGE /
                    fcb       $00
* MsgEnemyFire: "ENEMYFIRE" status message (enemy is shooting at the player)
MsgEnemyFire               fcc       /q%ENEMYFIRE/
                    fcb       $00
* MsgStatusBlank: Blank status message clearing the message field
MsgStatusBlank               fcc       /q%         /
                    fcb       $00
* TblStatusLinePtrs: Four data-area string pointers ($127A,$129E,$1292,$1286) cycled on the panel status line
TblStatusLinePtrs               fcb       $12,$7A,$12,$9E,$12,$92,$12,$86
* TblEnemyShapes: Five pointers to enemy-plane line shapes by size (far to near), each a count plus dx1,dy1,dx2,dy2 lines
TblEnemyShapes               fcb       $41,$AD,$41,$B6,$41,$BF,$41,$CC
                    fcb       $41,$DD,$02,$FF,$FF,$01,$FF,$FF
                    fcb       $01,$01,$01,$02,$FE,$FF,$02,$FF
                    fcb       $FE,$01,$02,$01,$03,$FE,$FE,$02
                    fcb       $FE,$FE,$02,$02,$02,$00,$FE,$00
                    fcb       $02,$04,$FD,$FE,$03,$FE,$FD,$02
                    fcb       $03,$02,$FF,$FE,$01,$02,$01,$FE
                    fcb       $FF,$02,$04,$FC,$FD,$04,$FD,$FC
                    fcb       $03,$04,$03,$FE,$FD,$02,$03,$02
                    fcb       $FD,$FE,$03
* TblGunsightLines: Gunsight line list: x1,y1,x2,y2 byte quads (cross plus diamond) drawn on the view
TblGunsightLines               fcc       /F2Z2P$PbF2P@P@Z2Z2P$P$F2/
* WarMain: F4 entry (exec $20): one-time war setup, then per-frame guns, bombs, enemies, gunsight, messages, report
WarMain               lda       >vWarStarted
                    bne       WarMainFrame
                    inc       >vWarStarted
                    jsr       >InitWarPanel+ModBase
                    clrb
                    jsr       >AddScore+ModBase
                    inc       >vWarEnemyInit
                    lda       #BombsFullChar
                    sta       >vBombsLeft
                    ldd       #AmmoFull
                    std       >vAmmo
* WarMainFrame: WarMain per-frame part: enemy init, radar clear, gunfire, bombs, enemy updates when war is on
WarMainFrame               jsr       >InitEnemiesOnce+ModBase
                    jsr       >ClearRadarScope+ModBase
                    jsr       >UpdateGunfire+ModBase
                    jsr       >UpdateBombs+ModBase
                    lda       >vWarState
                    beq       WarMainHud
                    ldx       #vEnemyRec1
                    jsr       >UpdateEnemyPlane+ModBase
                    ldx       #vEnemyRec2
                    jsr       >UpdateEnemyPlane+ModBase
                    ldx       #vEnemyRec3
                    jsr       >UpdateEnemyPlane+ModBase
                    ldx       #vEnemyRec4
                    jsr       >UpdateEnemyPlane+ModBase
                    ldx       #vEnemyRec5
                    jsr       >UpdateEnemyPlane+ModBase
                    ldx       #vEnemyRec6
                    jsr       >UpdateEnemyPlane+ModBase
* WarMainHud: WarMain: draw gunsight, update status messages, show war report if requested
WarMainHud               jsr       >DrawGunsight+ModBase
                    jsr       >UpdateWarMessages+ModBase
                    jsr       >ShowWarReport+ModBase
                    rts
* DrawGunsight: Draw the gunsight lines on the view (highlighted color when an enemy is in range)
DrawGunsight               lda       >vViewDir
                    bne       DrawGunsightDone
                    lda       >vMapView
                    cmpa      #MapViewOn
                    beq       DrawGunsightDone
                    lda       #GunsightColor
                    tst       >vEnemyInSight
                    beq       DrawGunsightColor
                    lda       #GunsightInRangeColor
* DrawGunsightColor: DrawGunsight: set line color and point at the line table
DrawGunsightColor               jsr       >FsSetLineColor
                    ldy       #TblGunsightLines+ModBase
* DrawGunsightLoop: DrawGunsight: draw each line of the table
DrawGunsightLoop               ldx       ,y++
                    ldd       ,y++
                    pshs      y
                    ldy       >vViewScr
                    jsr       >FsDrawLine
                    puls      y
                    cmpy      #WarMain+ModBase
                    blo       DrawGunsightLoop
* DrawGunsightDone: DrawGunsight: return
DrawGunsightDone               rts
* UpdateEnemyPlane: Update one enemy plane record (X): status logic, chase/return, fire on player, move, project, draw
UpdateEnemyPlane               ldb       <EnStatus,x
                    bne       UpdateEnemyActive
                    rts
* UpdateEnemyActive: UpdateEnemyPlane: status nonzero; branch on returning (1) or attacking (2)
UpdateEnemyActive               decb
                    bne       UpdateEnemyAttacking
                    ldd       >vPosX
                    cmpd      11,x
                    bgt       UpdateEnemyGoHome
                    ldd       >vPosZ
                    cmpd      13,x
                    blt       UpdateEnemyGoHome
                    lda       #EnemyAttacking
                    sta       <EnStatus,x
* UpdateEnemyGoHome: UpdateEnemyPlane: aim at the home position (record +$1A)
UpdateEnemyGoHome               ldy       <EnHomePtr,x
                    jsr       >ComputeTargetDelta+ModBase
                    jmp       >UpdateEnemyEvadeCheck+ModBase
* UpdateEnemyAttacking: UpdateEnemyPlane: attacking; check the player is still inside the enemy zone
UpdateEnemyAttacking               ldd       >vPosX
                    cmpd      15,x
                    bgt       UpdateEnemySetReturn
                    ldd       >vPosZ
                    cmpd      <EnZoneMinZ,x
                    bgt       UpdateEnemyChase
* UpdateEnemySetReturn: UpdateEnemyPlane: player left the zone, set status 1 (returning)
UpdateEnemySetReturn               lda       #EnemyReturning
                    sta       <EnStatus,x
                    rts
* UpdateEnemyChase: UpdateEnemyPlane: aim at the player; if close enough fire (damage, ENEMYFIRE message)
UpdateEnemyChase               ldy       #vPosX
                    jsr       >ComputeTargetDelta+ModBase
                    lda       9,x
                    beq       UpdateEnemyEvadeCheck
                    jsr       >ComputeEnemyRange+ModBase
                    lda       >vEnemyFar
                    ora       >vEnemyRange
                    bne       UpdateEnemyEvadeCheck
                    lda       >vEnemyRange+1
                    cmpa      <EnFireRange,x
                    bhi       UpdateEnemyEvadeCheck
                    lda       #EnemyFireRequest
                    sta       >vEnemyFired
                    lda       <EnEvadeLen,x
                    sta       <EnEvadeCnt,x
                    inc       >vWarDamage
                    jsr       >ShowDamageCount+ModBase
                    jsr       >ApplyEnemyHitDamage+ModBase
* UpdateEnemyEvadeCheck: UpdateEnemyPlane: after firing, run the climb/descend timer (record +$18) instead of chasing
UpdateEnemyEvadeCheck               lda       <EnEvadeCnt,x
                    beq       UpdateEnemyMoveX
                    dec       <EnEvadeCnt,x
                    bpl       UpdateEnemyClimb
                    lda       >vFrameCount
                    anda      #OddFrameBit
                    beq       UpdateEnemyToProject
                    andcc     #NotCarry
                    lda       5,x
                    sbca      #EnemyDescentStep
                    sta       5,x
                    bhs       UpdateEnemyAltFloor
                    lda       4,x
                    sbca      #CarryOnly
                    sta       4,x
                    bhs       UpdateEnemyToProject
                    dec       3,x
                    bne       UpdateEnemyToProject
* UpdateEnemyAltFloor: UpdateEnemyPlane: keep the enemy altitude at least 1
UpdateEnemyAltFloor               ora       3,x
                    ora       4,x
                    bne       UpdateEnemyToProject
                    lda       #EnemyAltMin
                    sta       5,x
                    bra       UpdateEnemyToProject
* UpdateEnemyClimb: UpdateEnemyPlane: climb one unit (24-bit altitude increment)
UpdateEnemyClimb               inc       5,x
                    bne       UpdateEnemyToProject
                    inc       4,x
                    bne       UpdateEnemyToProject
                    inc       3,x
                    bne       UpdateEnemyToProject
* UpdateEnemyToProject: UpdateEnemyPlane: jump to projection and drawing
UpdateEnemyToProject               jmp       >UpdateEnemyProject+ModBase
* UpdateEnemyMoveX: UpdateEnemyPlane: move X toward the target by the X speed (record +$13)
UpdateEnemyMoveX               lda       >vEnemyDX
                    bmi       UpdateEnemyMoveXNeg
                    lda       2,x
                    adda      <EnSpeedX,x
                    sta       2,x
                    bhs       UpdateEnemyMoveY
                    inc       1,x
                    bne       UpdateEnemyMoveY
                    fcb       $6C,$00                        (inc) 5-bit zero offset (assembler would emit ,r)
                    fcb       $20,$13
* UpdateEnemyMoveXNeg: UpdateEnemyPlane: move X in the negative direction
UpdateEnemyMoveXNeg               lda       2,x
                    suba      <EnSpeedX,x
                    sta       2,x
                    bhs       UpdateEnemyMoveY
                    lda       1,x
                    sbca      #CarryOnly
                    sta       1,x
                    bhs       UpdateEnemyMoveY
                    fcb       $6A,$00                        (dec) 5-bit zero offset (assembler would emit ,r)
* UpdateEnemyMoveY: UpdateEnemyPlane: move altitude toward the target by the Y speed (record +$14)
UpdateEnemyMoveY               lda       >vEnemyDY
                    bmi       UpdateEnemyMoveYNeg
                    lda       5,x
                    adda      <EnSpeedY,x
                    sta       5,x
                    bhs       UpdateEnemyMoveZ
                    inc       4,x
                    bne       UpdateEnemyMoveZ
                    inc       3,x
                    bra       UpdateEnemyMoveZ
* UpdateEnemyMoveYNeg: UpdateEnemyPlane: move altitude down
UpdateEnemyMoveYNeg               lda       5,x
                    suba      <EnSpeedY,x
                    sta       5,x
                    bhs       UpdateEnemyMoveZ
                    lda       4,x
                    sbca      #CarryOnly
                    sta       4,x
                    bhs       UpdateEnemyMoveZ
                    dec       3,x
* UpdateEnemyMoveZ: UpdateEnemyPlane: move Z toward the target by the Z speed (record +$15)
UpdateEnemyMoveZ               lda       >vEnemyDZ
                    bmi       UpdateEnemyMoveZNeg
                    lda       8,x
                    adda      <EnSpeedZ,x
                    sta       8,x
                    bhs       UpdateEnemyProject
                    inc       7,x
                    bne       UpdateEnemyProject
                    inc       6,x
                    bra       UpdateEnemyProject
* UpdateEnemyMoveZNeg: UpdateEnemyPlane: move Z in the negative direction
UpdateEnemyMoveZNeg               lda       8,x
                    suba      <EnSpeedZ,x
                    sta       8,x
                    bhs       UpdateEnemyProject
                    lda       7,x
                    sbca      #CarryOnly
                    sta       7,x
                    bhs       UpdateEnemyProject
                    dec       6,x
* UpdateEnemyProject: UpdateEnemyPlane: project position through FS 3D transform, radar plot, size and gunsight test
UpdateEnemyProject               ldd       1,x
                    std       >vEnemyPtX
                    ldd       4,x
                    std       >vEnemyPtY
                    ldd       7,x
                    std       >vEnemyPtZ
                    pshs      x
                    ldd       #vEnemyDispList
                    std       >vDispListPtr
                    lda       #EnemyColor
                    jsr       >FsSetLineColor
                    jsr       >FsRunList
                    puls      x
                    lda       >vEnd1ViewX
                    sta       >vEnemyViewX
                    lda       >vEnd1ViewRow
                    sta       >vEnemyViewY
                    ldy       #vPosX
                    jsr       >ComputeTargetDelta+ModBase
                    jsr       >PlotEnemyOnRadar+ModBase
                    lda       >vEnd1Clip
                    anda      #PointClipBits
                    bne       UpdateEnemyNoTarget
                    jsr       >ComputeEnemyRange+ModBase
                    clrb
                    clr       >vEnemySize
                    tst       >vEnemyFar
                    bne       UpdateEnemyNoTarget
                    lda       >vEnemyRange
                    cmpa      #RangeHidden
                    bhs       UpdateEnemyNoTarget
                    cmpa      #RangeShape0
                    bhs       UpdateEnemyDrawShape
                    cmpa      #RangeShape1
                    inc       >vEnemySize
                    bhs       UpdateEnemyCheckSight
                    lda       >vEnemyRange+1
                    cmpa      #RangeShape2
                    inc       >vEnemySize
                    bhs       UpdateEnemyCheckSight
                    cmpa      #RangeShape3
                    inc       >vEnemySize
                    bhs       UpdateEnemyCheckSight
                    inc       >vEnemySize
* UpdateEnemyCheckSight: UpdateEnemyPlane: test whether the screen position is inside the gunsight window
UpdateEnemyCheckSight               lda       >vEnemyViewX
                    cmpa      #SightRight
                    bhs       UpdateEnemyDrawShape
                    cmpa      #SightLeft
                    bls       UpdateEnemyDrawShape
                    lda       >vEnemyViewY
                    cmpa      #SightBottom
                    bhi       UpdateEnemyDrawShape
                    cmpa      #SightTop
                    bls       UpdateEnemyDrawShape
                    incb
* UpdateEnemyDrawShape: UpdateEnemyPlane: draw the enemy shape, then decide its target flag
UpdateEnemyDrawShape               pshs      b,x
                    jsr       >DrawEnemyShape+ModBase
                    puls      b,x
                    lda       <EnStatus,x
                    cmpa      #EnemyReturning
                    bne       UpdateEnemyCheckView
                    tst       >vAlt
                    bne       UpdateEnemyCheckView
                    tst       >vAlt+1
                    bne       UpdateEnemyCheckView
                    lda       >vAlt+2
                    cmpa      #ReturnTargetAlt
                    bhi       UpdateEnemyNoTarget
* UpdateEnemyCheckView: UpdateEnemyPlane: only targetable when $0839 is clear and in the gunsight
UpdateEnemyCheckView               lda       >vViewDir
                    bne       UpdateEnemySetTarget
                    tstb
                    bne       UpdateEnemyInSight
* UpdateEnemyNoTarget: UpdateEnemyPlane: not a target (flag 0)
UpdateEnemyNoTarget               clra
                    bra       UpdateEnemySetTarget
* UpdateEnemyInSight: UpdateEnemyPlane: in the gunsight, request the IN RANGE message (flag 3)
UpdateEnemyInSight               lda       #InRangeRequest
                    sta       >vEnemyInSight
* UpdateEnemySetTarget: UpdateEnemyPlane: store the target flag (record +$0A)
UpdateEnemySetTarget               sta       10,x
                    rts
* DrawEnemyShape: Draw the enemy plane shape of size $124D at screen position $124E/$124F
DrawEnemyShape               lda       #EnemyColor
                    jsr       >FsSetLineColor
                    lda       >vEnemyViewX
                    cmpa      #ShapeMinX
                    blo       DrawEnemyShapeDone
                    cmpa      #ShapeMaxX
                    bhs       DrawEnemyShapeDone
                    lda       >vEnemyViewY
                    cmpa      #ShapeMinY
                    blo       DrawEnemyShapeDone
                    cmpa      #ShapeMaxY
                    bhs       DrawEnemyShapeDone
                    ldy       #TblEnemyShapes+ModBase
                    ldb       >vEnemySize
                    aslb
                    ldy       b,y
                    ldb       ,y+
* DrawEnemyShapeLoop: DrawEnemyShape: offset and draw each line of the shape
DrawEnemyShapeLoop               lda       ,y+
                    adda      >vEnemyViewX
                    sta       >vEnemyLineX0
                    lda       ,y+
                    adda      >vEnemyViewY
                    sta       >vEnemyLineY0
                    lda       ,y+
                    adda      >vEnemyViewX
                    sta       >vEnemyLineX1
                    lda       ,y+
                    adda      >vEnemyViewY
                    sta       >vEnemyLineY1
                    pshs      b,y
                    ldx       >vEnemyLineX0
                    ldd       >vEnemyLineX1
                    ldy       >vViewScr
                    jsr       >FsDrawLine
                    puls      b,y
                    decb
                    bne       DrawEnemyShapeLoop
* DrawEnemyShapeDone: DrawEnemyShape: return (also when off screen)
DrawEnemyShapeDone               rts
* PlotEnemyOnRadar: Rotate the enemy offset by the player heading and plot it on the panel radar; sets record +9
PlotEnemyOnRadar               lda       >vEnemyDX
                    eora      >vEnemyDZ
                    beq       PlotRadarRotate
                    eora      #ComplementBits
                    beq       PlotRadarRotate
                    jmp       >PlotRadarOffScope+ModBase
* PlotRadarRotate: PlotEnemyOnRadar: rotate dx/dz with sine/cosine of heading $0016 and scale to the scope
PlotRadarRotate               pshs      x
                    lda       >vHdg
                    jsr       >FsSin8
                    std       >vMulA
                    std       >vRadarSin
                    ldd       >vEnemyDX+1
                    std       >vMulB
                    jsr       >FsMulQ15Vars
                    std       >vRadarRotZ
                    ldd       >vRadarSin
                    std       >vMulA
                    ldd       >vEnemyDZ+1
                    std       >vMulB
                    jsr       >FsMulQ15Vars
                    std       >vRadarRotX
                    lda       >vHdg
                    jsr       >FsCos8
                    std       >vRadarCos
                    std       >vMulA
                    ldd       >vEnemyDX+1
                    std       >vMulB
                    jsr       >FsMulQ15Vars
                    subd      >vRadarRotX
                    std       >vRadarRotX
                    ldd       >vRadarCos
                    std       >vMulA
                    ldd       >vEnemyDZ+1
                    std       >vMulB
                    jsr       >FsMulQ15Vars
                    addd      >vRadarRotZ
                    std       >vRadarRotZ
                    ldd       #RadarScaleX
                    std       >vMulA
                    ldd       >vRadarRotX
                    std       >vMulB
                    jsr       >FsMulQ15Vars
                    coma
                    comb
                    addd      #NegCarry
                    addd      #RadarCenterX
                    cmpd      #RadarRight
                    lbhi      PlotRadarOffScope
                    cmpd      #RadarLeft
                    lblo      PlotRadarOffScope
                    stb       >vRadarDotX
                    ldd       #RadarScaleY
                    std       >vMulA
                    ldd       >vRadarRotZ
                    std       >vMulB
                    jsr       >FsMulQ15Vars
                    addd      #RadarCenterY
                    cmpd      #RadarBottom
                    bhi       PlotRadarOffScope
                    cmpd      #RadarTop
                    blo       PlotRadarOffScope
                    stb       >vRadarDotY
                    lda       >vEnemyDY+2
                    ldy       >vEnemyDY
                    bpl       PlotRadarCheckBelow
                    cmpy      #HtDeltaHiSmallNeg
                    bne       PlotRadarAbove
                    cmpa      #RadarLevelMin
                    bgt       PlotRadarLevel
* PlotRadarAbove: PlotEnemyOnRadar: enemy well above the player, color $66
PlotRadarAbove               lda       #RadarAboveColor
                    bra       PlotRadarDot
* PlotRadarCheckBelow: PlotEnemyOnRadar: player above the enemy; check if the difference is large
PlotRadarCheckBelow               cmpy      #HtDeltaHiSmallPos
                    bne       PlotRadarBelow
                    cmpa      #RadarLevelMax
                    blt       PlotRadarLevel
* PlotRadarBelow: PlotEnemyOnRadar: enemy well below the player, color $44
PlotRadarBelow               lda       #RadarBelowColor
                    bra       PlotRadarDot
* PlotRadarLevel: PlotEnemyOnRadar: enemy at about the player altitude, color $FF
PlotRadarLevel               lda       #RadarLevelColor
* PlotRadarDot: PlotEnemyOnRadar: plot the dot on the panel and mark the enemy as on radar
PlotRadarDot               jsr       >FsSetLineColor
                    ldd       >vRadarDotX
                    ldy       >vPanelScr
                    jsr       >FsPlotPixel
                    puls      x
                    ldb       #EnemyOnRadar
                    stb       9,x
                    rts
* PlotRadarOffScope: PlotEnemyOnRadar: outside the radar range, clear the on-radar flag
PlotRadarOffScope               clra
                    puls      x
                    sta       9,x
                    rts
* InitEnemiesOnce: On the init flag $020A: show ammo and damage and set all six enemies to status 1
InitEnemiesOnce               lda       >vWarEnemyInit
                    beq       InitEnemiesDone
                    jsr       >ShowAmmoCount+ModBase
                    jsr       >ShowDamageCount+ModBase
                    clr       >vWarEnemyInit
                    lda       #EnemyReturning
                    sta       >vEnemy1Status
                    sta       >vEnemy2Status
                    sta       >vEnemy3Status
                    sta       >vEnemy4Status
                    sta       >vEnemy5Status
                    sta       >vEnemy6Status
* InitEnemiesDone: InitEnemiesOnce: return
InitEnemiesDone               rts
* ShowDamageCount: Convert damage count $0209 to digits in the panel string at $128E
ShowDamageCount               pshs      x
                    ldb       >vWarDamage
                    clra
                    ldx       #vHitsDigits
                    jsr       >FsDec3ToAscii
                    puls      x
                    rts
* UpdateWarMessages: Show IN RANGE / ENEMYFIRE / blank, cycle the panel status line, announce war start
UpdateWarMessages               lda       >vWarMsgShown
                    lsr       >vEnemyInSight
                    bhs       UpdateWarMsgFire
                    cmpa      #WarMsgInRange
                    beq       UpdateWarMsgCycle
                    lda       #WarMsgInRange
                    sta       >vWarMsgShown
                    ldx       #MsgInRange+ModBase
                    bra       UpdateWarMsgPrint
* UpdateWarMsgFire: UpdateWarMessages: check the enemy-fire request
UpdateWarMsgFire               lsr       >vEnemyFired
                    bhs       UpdateWarMsgClear
                    cmpa      #WarMsgEnemyFire
                    beq       UpdateWarMsgCycle
                    lda       #WarMsgEnemyFire
                    sta       >vWarMsgShown
                    ldx       #MsgEnemyFire+ModBase
                    bra       UpdateWarMsgPrint
* UpdateWarMsgClear: UpdateWarMessages: no request, blank the message if one is shown
UpdateWarMsgClear               cmpa      #WarMsgNone
                    beq       UpdateWarMsgCycle
                    clr       >vWarMsgShown
                    ldx       #MsgStatusBlank+ModBase
* UpdateWarMsgPrint: UpdateWarMessages: print the chosen message
UpdateWarMsgPrint               jsr       >FsPrintPanelTextF
* UpdateWarMsgCycle: UpdateWarMessages: every 4 calls print the next status line string
UpdateWarMsgCycle               dec       >vStatusWait
                    bne       UpdateWarMsgStart
                    lda       #StatusLineTime
                    sta       >vStatusWait
                    inc       >vStatusLine
                    ldb       >vStatusLine
                    andb      #StatusLineMask
                    aslb
                    ldx       #TblStatusLinePtrs+ModBase
                    abx
                    ldx       ,x
                    jsr       >FsPrintPanelTextF
* UpdateWarMsgStart: UpdateWarMessages: on war state 1 print WAR !!!! and set state 3
UpdateWarMsgStart               lda       >vWarState
                    cmpa      #WarStarted
                    bne       UpdateWarMsgDone
                    lda       #WarAnnounced
                    sta       >vWarState
                    ldx       #MsgWarStarted+ModBase
                    jsr       >FsPrintPanelTextF
                    ldx       #WarDelayStart
* UpdateWarMsgDelay: UpdateWarMessages: 65536-iteration delay loop after WAR !!!!
UpdateWarMsgDelay               leax      1,x
                    cmpx      #WarDelayEnd
                    bne       UpdateWarMsgDelay
* UpdateWarMsgDone: UpdateWarMessages: return
UpdateWarMsgDone               rts
* UpdateGunfire: Fire a pending round (ammo, new tracer slot) and animate/draw the tracers
UpdateGunfire               lda       >vGunBurst
                    beq       GunfireCheckActive
                    dec       >vGunBurst
                    jsr       >UseAmmoRound+ModBase
                    lda       #TracerFrames
                    sta       >vTracerTime
                    ldb       >vTracerSlot
                    addb      #TracerEntrySize
                    cmpb      #TracerTblSize
                    blo       GunfireStoreSlot
                    clrb
* GunfireStoreSlot: UpdateGunfire: store the next tracer slot index and set up the tracer
GunfireStoreSlot               stb       >vTracerSlot
                    ldx       #vTracerTbl
                    abx
                    lda       ,x+
                    sta       ,x++
                    inc       >vGunSide
                    lda       >vGunSide
                    rora
                    lda       #GunLeftX
                    bhs       GunfireStoreX
                    lda       #GunRightX
* GunfireStoreX: UpdateGunfire: store the tracer start X (alternating left/right gun)
GunfireStoreX               sta       ,x++
                    lda       #GunY
                    bhs       GunfireStoreY
                    lda       #GunY
* GunfireStoreY: UpdateGunfire: store the tracer start Y
GunfireStoreY               sta       ,x
* GunfireCheckActive: UpdateGunfire: count down the tracer display time; stop at 1
GunfireCheckActive               dec       >vTracerTime
                    bne       DrawTracers
                    inc       >vTracerTime
                    rts
* DrawTracers: UpdateGunfire: walk the tracer table at $12BA
DrawTracers               lda       #TracerColor
                    jsr       >FsSetLineColor
                    ldx       #vTracerTbl
* DrawTracersNext: DrawTracers: next tracer entry, skipping inactive ones
DrawTracersNext               leax      1,x
                    lda       ,x
                    bne       DrawTracersCheckEnd
                    leax      5,x
                    bra       DrawTracersNext
* DrawTracersCheckEnd: DrawTracers: $FF ends the table
DrawTracersCheckEnd               cmpa      #TracerTblEnd
                    bne       DrawTracersStep
                    rts
* DrawTracersStep: DrawTracers: count the tracer down; near the end test for a hit
DrawTracersStep               dec       ,x+
                    cmpa      #TracerHitTime
                    bhs       DrawTracersMove
                    ldy       #vEnemyRec1
* DrawTracersHitScan: DrawTracers: look for an enemy whose target flag is set
DrawTracersHitScan               lda       10,y
                    bne       DrawTracersHitEnemy
                    leay      <EnRecLen,y
                    cmpy      #vEnemyRecEnd
                    blo       DrawTracersHitScan
                    bra       DrawTracersMove
* DrawTracersHitEnemy: DrawTracers: enemy shot down, clear its status, add score, count it
DrawTracersHitEnemy               clr       <EnStatus,y
                    clr       10,y
                    ldb       #KillScore
                    jsr       >AddScore+ModBase
                    inc       >vWarKills
* DrawTracersMove: DrawTracers: move the tracer a quarter of the way to its target point
DrawTracersMove               ldb       #TracerAxes
* DrawTracersMoveLoop: DrawTracers: update X then Y coordinate
DrawTracersMoveLoop               lda       ,x+
                    suba      ,x
                    asra
                    asra
                    adda      ,x
                    sta       ,x+
                    pshs      a
                    decb
                    bne       DrawTracersMoveLoop
                    puls      a,b
                    exg       a,b
                    tst       >vViewDir
                    bne       DrawTracersLoop
                    tst       >vMapView
                    bne       DrawTracersLoop
                    pshs      x
                    ldy       >vViewScr
                    jsr       >FsPlotPixel
                    puls      x
* DrawTracersLoop: DrawTracers: continue with the next entry
DrawTracersLoop               jmp       >DrawTracersNext+ModBase
* UpdateBombs: Release a bomb on request and drop it; on impact score a hit and start the war
UpdateBombs               tst       >vBombReq
                    beq       UpdateBombsFall
                    clr       >vBombReq
                    ldd       >vBombAlt
                    bne       UpdateBombsFall
                    lda       >vBombsLeft
                    cmpa      #BombsNoneChar
                    lbeq      UpdateBombsDone
                    dec       >vBombsLeft
                    ldd       >vAltCopy
                    std       >vBombAlt
* UpdateBombsFall: UpdateBombs: lower the falling bomb by 50 per call
UpdateBombsFall               ldd       >vBombAlt
                    beq       UpdateBombsDone
                    subd      #BombFallStep
                    bpl       UpdateBombsStore
                    ldd       >vBombTarget
                    beq       UpdateBombsMiss
                    jsr       >AddScore+ModBase
                    inc       >vBombHits
                    lda       #WarStarted
                    ora       >vWarState
                    sta       >vWarState
* UpdateBombsMiss: UpdateBombs: bomb landed, clear its height
UpdateBombsMiss               ldd       #BombAltNone
* UpdateBombsStore: UpdateBombs: store the bomb height and clear the FS hit value $0174
UpdateBombsStore               std       >vBombAlt
                    clr       >vBombTarget
                    clr       >vBombTarget+1
* UpdateBombsDone: UpdateBombs: return
UpdateBombsDone               rts
* AddScore: Add B to the score $0228 (wraps at 1000) and convert it into the panel string $12A6
AddScore               clra
                    addd      >vWarScore
                    cmpd      #ScoreWrap
                    blo       AddScoreStore
                    clra
                    clrb
* AddScoreStore: AddScore: store and display the score
AddScoreStore               std       >vWarScore
                    pshs      x
                    ldx       #vScoreDigits
                    jsr       >FsDec3ToAscii
                    puls      x
                    rts
* UseAmmoRound: Decrement the ammo count $0814 (not below 0) and display it
UseAmmoRound               ldd       >vAmmo
                    subd      #RoundsPerShot
                    std       >vAmmo
                    bpl       ShowAmmoCount
                    clra
                    clrb
                    std       >vAmmo
* ShowAmmoCount: Convert ammo count $0814 into the panel string at $1282
ShowAmmoCount               pshs      x
                    ldd       >vAmmo
                    ldx       #vAmmoDigits
                    jsr       >FsDec3ToAscii
                    puls      x
                    rts
* ComputeEnemyRange: Approximate 3D distance from the delta vector into $123A; $1239 nonzero if too far
ComputeEnemyRange               pshs      x
                    ldd       >vEnemyDX+1
                    ldy       >vEnemyDY+1
                    jsr       >ApproxHypot+ModBase
                    ldy       >vEnemyDZ+1
                    jsr       >ApproxHypot+ModBase
                    std       >vEnemyRange
                    lda       >vEnemyDX
                    eora      >vEnemyDY
                    eora      >vEnemyDZ
                    beq       ComputeRangeStoreFar
                    coma
                    beq       ComputeRangeStoreFar
                    lda       #EnemyFarFlag
* ComputeRangeStoreFar: ComputeEnemyRange: store the far flag
ComputeRangeStoreFar               sta       >vEnemyFar
                    puls      x
                    rts
* ApproxHypot: Approximate sqrt(D^2+Y^2) as max + min^2/(2*max)
ApproxHypot               tsta
                    bpl       ApproxHypotAbsY
                    coma
                    comb
                    addd      #NegCarry
* ApproxHypotAbsY: ApproxHypot: absolute value of the second operand
ApproxHypotAbsY               tfr       d,u
                    stu       >vHypotMin
                    tfr       y,d
                    tsta
                    bpl       ApproxHypotCompare
                    coma
                    comb
                    addd      #NegCarry
* ApproxHypotCompare: ApproxHypot: order the operands into max and min
ApproxHypotCompare               cmpd      >vHypotMin
                    bhi       ApproxHypotCalc
                    exg       d,u
                    stu       >vHypotMin
* ApproxHypotCalc: ApproxHypot: compute max + min*min/(2*max)
ApproxHypotCalc               std       >vHypotMax
                    aslb
                    rola
                    std       >vDivisor
                    tfr       u,d
                    jsr       >FsDivQ15Signed
                    ldd       >vHypotMin
                    std       >vMulB
                    jsr       >FsMulQ15Vars
                    addd      >vHypotMax
                    rts
* ComputeTargetDelta: 24-bit delta (target at Y) minus (enemy at X) into $1230 (X), $1233 (Y), $1236 (Z)
ComputeTargetDelta               andcc     #NotCarry
                    lda       2,y
                    sbca      2,x
                    sta       >vEnemyDX+2
                    lda       1,y
                    sbca      1,x
                    sta       >vEnemyDX+1
                    fcb       $A6,$20                        (lda) 5-bit zero offset (assembler would emit ,r)
                    fcb       $A2,$00,$B7,$12
                    fcc       /01$/
                    fcb       $1C,$FE,$A6,$22,$A2,$05,$B7,$12
                    fcb       $35,$A6,$21,$A2,$04,$B7,$12,$34
                    fcb       $A6,$20,$A2,$03,$B7,$12
                    fcc       /31$/
                    fcb       $1C,$FE,$A6,$22,$A2,$08,$B7,$12
                    fcb       $38,$A6,$21,$A2,$07,$B7,$12,$37
                    fcb       $A6,$20,$A2,$06,$B7,$12,$36,$39
* ClearRadarScope: Clear the panel radar scope and draw the own-plane center marker
ClearRadarScope               lda       #RadarBgColor
                    jsr       >FsSetFillColor
                    ldd       #RadarTopLeft
                    ldx       #RadarBotRight
                    ldy       >vPanelScr
                    jsr       >FsFillRect
                    lda       #RadarMarkLeft
                    ldx       >vPanelScr
                    sta       >F4RadarCtr-80,x
                    sta       >F4RadarCtr+80,x
                    lda       #RadarMarkBoth
                    sta       >F4RadarCtr,x
                    lda       #RadarMarkRight
                    sta       >F4RadarCtr-1,x
                    rts
* InitWarPanel: One-time setup: clear high bits of $00EC/$0345 and clear the panel area used by the radar
InitWarPanel               lda       >vInstActive2
                    anda      #PanelReadoutsOff
                    sta       >vInstActive2
                    lda       >vInstPresent+1
                    anda      #PanelReadoutsOff
                    sta       >vInstPresent+1
                    lda       #WarPanelBgColor
                    jsr       >FsSetFillColor
                    ldd       #WarPanelTopLeft
                    ldx       #WarPanelBotRight
                    ldy       >vPanelScr
                    jmp       >FsFillRect
* ApplyEnemyHitDamage: After an enemy hit, set system-failure bits in $072E (or disable the plane) by damage count
ApplyEnemyHitDamage               ldb       >vWarDamage
                    lda       >vWarKills
                    cmpa      #VeteranKills
                    clra
                    bhs       DamageVeteranLimits
                    cmpb      #HitsDisable
                    bhs       DamageDisablePlane
                    cmpb      #HitsEngine
                    bhs       DamageSetBit0
                    cmpb      #HitsOilPress
                    bhs       DamageSetBit1
                    cmpb      #HitsLeak
                    bhs       DamageRandomBit3
                    cmpb      #HitsLeftLeak
                    bhs       DamageRandomBit2
                    bra       DamageApply
* DamageVeteranLimits: ApplyEnemyHitDamage: lower damage thresholds after 4 or more kills
DamageVeteranLimits               cmpb      #VetHitsDisable
                    bhs       DamageDisablePlane
                    cmpb      #VetHitsEngine
                    bhs       DamageSetBit0
                    cmpb      #VetHitsLeak
                    bhs       DamageRandomBit3
                    bra       DamageApply
* DamageDisablePlane: ApplyEnemyHitDamage: fatal damage, set $022B and all failure bits
DamageDisablePlane               inc       >vWarDowned
* DamageSetBit0: ApplyEnemyHitDamage: set failure bit 0
DamageSetBit0               ora       #DmgOilTemp
* DamageSetBit1: ApplyEnemyHitDamage: set failure bit 1
DamageSetBit1               ora       #DmgOilPress
* DamageRandomBit3: ApplyEnemyHitDamage: set bit 3 depending on $0040 (probably a pseudo-random/frame value)
DamageRandomBit3               ldb       >vFrameCount
                    cmpb      #HitFailSplit
                    bhs       DamageRandomBit2
                    ora       #DmgLeakRight
* DamageRandomBit2: ApplyEnemyHitDamage: set bit 2 depending on $0040
DamageRandomBit2               ldb       >vFrameCount
                    cmpb      #HitFailSplit
                    blo       DamageApply
                    ora       #DmgLeakLeft
* DamageApply: ApplyEnemyHitDamage: merge the bits into $072E
DamageApply               ora       >vDamageBits
                    sta       >vDamageBits
                    rts
* ShowWarReport: If requested ($022F) fill in kills, bomb hits, damage, enemy statuses and show the war report
ShowWarReport               tst       >vWarReport
                    lbeq      ShowWarReportDone
                    clr       >vWarReport
                    clra
                    ldb       >vWarKills
                    ldx       #vRptKills
                    jsr       >FsDec3ToAscii
                    clra
                    ldb       >vBombHits
                    ldx       #vRptBombHits
                    jsr       >FsDec3ToAscii
                    clra
                    ldb       >vWarDamage
                    ldx       #vRptDamage
                    jsr       >FsDec3ToAscii
                    lda       >vEnemy1Status
                    ora       #AsciiZero
                    sta       >vRptEnemy1
                    lda       >vEnemy2Status
                    ora       #AsciiZero
                    sta       >vRptEnemy2
                    lda       >vEnemy3Status
                    ora       #AsciiZero
                    sta       >vRptEnemy3
                    lda       >vEnemy4Status
                    ora       #AsciiZero
                    sta       >vRptEnemy4
                    lda       >vEnemy5Status
                    ora       #AsciiZero
                    sta       >vRptEnemy5
                    lda       >vEnemy6Status
                    ora       #AsciiZero
                    sta       >vRptEnemy6
                    pshs      a,x,y
                    lda       >FsPath
                    ldx       #MsgWarReport+ModBase
                    ldy       #WarReportLen
                    os9       I$Write
                    puls      a,x,y
                    ldx       #vRptNums
                    ldy       #RptNumsLen
                    clra
                    jsr       >FsShowTextMsgWaitKey
* ShowWarReportDone: ShowWarReport: return
ShowWarReportDone               rts
                    fcb       $7F,$02,$21,$39,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00

                    emod
eom                 equ       *
                    end
