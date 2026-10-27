********************************************************************
* sky_stars.asm - FS2's stars at dawn, dusk and night, in the K2's fscl (fscl.asm at $4000: fst's GdDraw, FsclSky)
* and the Jr2's fsx (fsx.asm at FsxBase: FsxGround), both from fsw's GdCall at the end of Horizon and from Sky
* (DrawSkyGround without the horizon in view), after the sky and before the scenery, which draws over them.
* sky_stars.d (tools/flightsim2/stars_gen.py, the Yale Bright Star Catalog): the stars brighter than V 4.0 that
* rise at 42 deg north, brightest first, as equatorial unit vectors. A fixed dome turned by FS's clock: the sky's
* angle (the local sidereal time) is SkLst, the season's midnight, plus FS's hours and minutes; when it moves, W
* (equatorial to FS's east, up, north) and SkMask (the stars 1 deg up and more) are made again. Each frame K = C W
* (C: FS's view matrix vViewM, the view's aspect in its columns), and each star above the horizon goes to the
* camera: Z first (ahead only), then X and Y within the view (|X| < Z, |Y| < Z), drawn by fsw's Dot (FswDot: the
* point <$B8 projected exactly, in the line color <$EE). Dawn and dusk: the bright ones (V < 1.5), white; night:
* those white, V < 3.0 light gray, the rest dark gray. FS's DP 0. Registers clobbered.

SkAxes              equ       3                   x, y, z: K's rows, W's rows, a row's words
SkBitFirst          equ       $80                 SkMask's first bit in a byte: the first of its eight stars
SkCarry             equ       0                   adca: the carry alone
SkCosLat            equ       24351               cos 42 deg (Q15): FS's Chicago
SkDay               equ       1                   vLight 1: day, no stars
SkDkGray            equ       10                  FS's dark gray: V 3.0-4.0
SkHour              equ       2731                the sky's turn in an hour: 65536 / 24
SkHourHi            equ       SkHour/256          its high byte (x hours 0-23: under 256)
SkHourLo            equ       SkHour&255          its low byte
SkLtGray            equ       5                   FS's light gray: V 1.5-3.0
SkMade              equ       1                   SkThOk: W and SkMask made for SkTh
SkMinute            equ       46                  the sky's turn in a minute: 65536 / 1440 (45.5)
SkNegCarry          equ       1                   a negation: the complement + 1
SkNight             equ       4                   vLight 4: night, every star (2, dawn and dusk: the bright ones)
SkRowBytes          equ       6                   a row of three Q15 words (vViewM's, SkW's)
SkSeasonMask        equ       3                   vSeason - 1 (1-4) as SkLst's index 0-3
SkSinLat            equ       21926               sin 42 deg (Q15)
SkStarBytes         equ       3                   a star in SkTab: x, y, z signed bytes (x 127)
SkUpMin             equ       284                 1 deg up as SkDot gives it (sin 1 deg x 16256): lower ones lie in the haze
SkWhite             equ       15                  FS's white: V < 1.5
SkWUp               equ       SkW+SkRowBytes      W's up row

* SkDraw (fscl's ClBase+9, the Jr2 fsx's GdDraw): the frame's stars.
SkDraw              lda       >vLight
                    cmpa      #SkDay
                    lbeq      sd9@
                    tst       >vMapView           the map view: none
                    lbne      sd9@
                    lbsr      SkTime              the sky's angle: W and SkMask again when it moved
                    lbsr      SkKMat              K = C W
                    ldx       #SkNBright          dawn and dusk: the bright ones
                    lda       >vLight
                    cmpa      #SkNight
                    bne       sd1@
                    ldx       #SkN                night: all
sd1@                stx       SkCnt
                    ldd       >vLineColPat        FS's line color, kept
                    std       SkCol
                    lbsr      SkFirst
sd2@                lda       [SkMp]
                    anda      SkMb
                    beq       sd8@                below the horizon
                    ldu       #SkKZ
                    lbsr      SkDot
                    std       SkZ
                    ble       sd8@                behind the eye or beside it
                    ldu       #SkKX
                    lbsr      SkDot
                    std       SkX
                    lbsr      SkAbs
                    cmpd      SkZ
                    bhs       sd8@                left or right of the view
                    ldu       #SkKY
                    lbsr      SkDot
                    std       SkY
                    lbsr      SkAbs
                    cmpd      SkZ
                    bhs       sd8@                above or below it
                    lda       #SkWhite            the color by the star's class
                    ldx       SkNo
                    cmpx      #SkNBright
                    blo       sd3@
                    lda       #SkLtGray
                    cmpx      #SkNMid
                    blo       sd3@
                    lda       #SkDkGray
sd3@                sta       >vLineColPat
                    ldd       SkX
                    std       >vEnd1X
                    ldd       SkY
                    std       >vEnd1X+2
                    ldd       SkZ
                    std       >vEnd1X+4
                    jsr       >FswDot             its pixel (registers kept)
sd8@                lbsr      SkStep
                    blo       sd2@
                    ldd       SkCol
                    std       >vLineColPat
sd9@                rts

* SkFirst: Y = the first star, SkMp and SkMb its bit in SkMask, SkNo 0. SkStep: the next star; carry set while
* SkNo is under SkCnt. X clobbered.
SkFirst             ldy       #SkTab
                    ldx       #SkMask
                    stx       SkMp
                    lda       #SkBitFirst
                    sta       SkMb
                    clra
                    clrb
                    std       SkNo
                    rts
SkStep              leay      SkStarBytes,y
                    lsr       SkMb
                    bcc       ss1@
                    ror       SkMb                past bit 0: bit 7 of the next byte
                    ldx       SkMp
                    leax      1,x
                    stx       SkMp
ss1@                ldx       SkNo
                    leax      1,x
                    stx       SkNo
                    cmpx      SkCnt
                    rts

* SkTime (SkDraw): the sky's angle for FS's season and clock: SkLst's (the season's midnight) + 2731 an hour + 46
* a minute; W and SkMask made again when it moved, or were never made.
SkTime              ldb       >vSeason
                    decb
                    andb      #SkSeasonMask
                    lslb
                    ldx       #SkLst
                    abx
                    lda       >vHour
                    ldb       #SkHourLo
                    mul
                    std       SkSum
                    lda       >vHour
                    ldb       #SkHourHi
                    mul
                    addb      SkSum
                    stb       SkSum
                    lda       >vMinute
                    ldb       #SkMinute
                    mul
                    addd      SkSum
                    addd      ,x
                    tst       SkThOk
                    beq       st1@
                    cmpd      SkTh
                    beq       st9@
st1@                std       SkTh
                    bsr       SkWMat
                    lbsr      SkUp
                    lda       #SkMade
                    sta       SkThOk
st9@                rts

* SkWMat (SkTime): W for the sky's angle t, its rows FS's x, y, z: east (-sin t, cos t, 0), up (cos L cos t,
* cos L sin t, sin L), north (-sin L cos t, -sin L sin t, cos L), L the latitude: the equatorial frame turned by
* t about the pole, then tipped by L.
SkWMat              ldd       SkTh
                    jsr       >FsSin16
                    std       SkSin
                    ldd       SkTh
                    jsr       >FsCos16
                    std       SkCos
                    ldx       #SkW
                    ldd       SkSin               east
                    bsr       SkNegD
                    std       ,x
                    ldd       SkCos
                    std       2,x
                    clra
                    clrb
                    std       4,x
                    ldd       #SkCosLat           up
                    ldu       SkCos
                    bsr       SkMq
                    std       6,x
                    ldd       #SkCosLat
                    ldu       SkSin
                    bsr       SkMq
                    std       8,x
                    ldd       #SkSinLat
                    std       10,x
                    ldd       #SkSinLat           north
                    ldu       SkCos
                    bsr       SkMq
                    bsr       SkNegD
                    std       12,x
                    ldd       #SkSinLat
                    ldu       SkSin
                    bsr       SkMq
                    bsr       SkNegD
                    std       14,x
                    ldd       #SkCosLat
                    std       16,x
                    rts
* SkMq: D x U (Q15) -> D, fsw's Mq (X, Y, U kept). SkNegD: D negated. SkAbs: D's magnitude.
SkMq                std       <vMulA
                    stu       <vMulB
                    jmp       >FswMq
SkAbs               tsta
                    bpl       sa9@
SkNegD              coma
                    comb
                    addd      #SkNegCarry
sa9@                rts

* SkUp (SkTime): SkMask: a star's bit set when its up component (W's up row) is SkUpMin or more.
SkUp                ldx       #SkMask
su1@                clr       ,x+
                    cmpx      #SkMaskEnd
                    blo       su1@
                    ldx       #SkN
                    stx       SkCnt
                    lbsr      SkFirst
su2@                ldu       #SkWUp
                    bsr       SkDot
                    cmpd      #SkUpMin
                    blt       su3@
                    lda       [SkMp]
                    ora       SkMb
                    sta       [SkMp]
su3@                lbsr      SkStep
                    blo       su2@
                    rts

* SkKMat (SkDraw): K = C W, a row per camera axis j (SkKX, SkKY, SkKZ), its word i the sum over FS's axes w of
* C(w, j) W(w, i): vViewM's row w, word j, times SkW's row w, word i.
SkKMat              ldy       #SkKX
                    clr       SkJ
sk1@                clr       SkI
sk2@                ldx       #vViewM
                    ldb       SkJ
                    lslb
                    abx                           C(0, j)
                    ldu       #SkW
                    ldb       SkI
                    lslb
                    leau      b,u                 W(0, i)
                    clra
                    clrb
                    std       SkSum
                    lda       #SkAxes
                    sta       SkK
sk3@                ldd       ,x
                    std       <vMulA
                    ldd       ,u
                    std       <vMulB
                    jsr       >FswMq              (X, Y, U kept)
                    addd      SkSum
                    std       SkSum
                    leax      SkRowBytes,x
                    leau      SkRowBytes,u
                    dec       SkK
                    bne       sk3@
                    std       ,y++
                    inc       SkI
                    lda       SkI
                    cmpa      #SkAxes
                    blo       sk2@
                    inc       SkJ
                    lda       SkJ
                    cmpa      #SkAxes
                    blo       sk1@
                    rts

* SkDot: Y = a star (three signed bytes, x 127), U = a row of three Q15 words -> D = their dot product x 127 /
* 256: each product's high 16 bits, at most 16256 in all. X clobbered.
SkDot               lda       ,y
                    ldx       ,u
                    bsr       SkMul
                    std       SkSum
                    lda       1,y
                    ldx       2,u
                    bsr       SkMul
                    addd      SkSum
                    std       SkSum
                    lda       2,y
                    ldx       4,u
                    bsr       SkMul
                    addd      SkSum
                    rts
* SkMul: A = s (a signed byte), X = k (a signed Q15 word) -> D = s k / 256: the magnitudes on the CPU's MUL, the
* sign put back.
SkMul               clr       SkNeg
                    tsta
                    bpl       sm1@
                    nega
                    com       SkNeg
sm1@                sta       SkS
                    tfr       x,d
                    tsta
                    bpl       sm2@
                    lbsr      SkNegD
                    com       SkNeg
sm2@                std       SkKw                |k|
                    lda       SkS
                    mul                           |s| x |k|'s low byte
                    sta       SkLo                its high byte
                    lda       SkS
                    ldb       SkKw                |s| x |k|'s high byte
                    mul
                    addb      SkLo
                    adca      #SkCarry
                    tst       SkNeg
                    beq       sm3@
                    lbsr      SkNegD
sm3@                rts

                    use       sky_stars.d

* Variables
SkTh                fdb       0                   the sky's angle W and SkMask were made for
SkThOk              fcb       0                   SkMade: they were made
SkSin               fdb       0                   its sine and cosine (Q15)
SkCos               fdb       0
SkCnt               fdb       0                   the stars to look at: the bright ones (dawn, dusk), all (night, SkUp)
SkNo                fdb       0                   the star's index
SkMp                fdb       0                   its byte in SkMask
SkMb                fcb       0                   its bit
SkX                 fdb       0                   the star in the camera: X, Y, Z (then <$B8)
SkY                 fdb       0
SkZ                 fdb       0
SkCol               fdb       0                   FS's line color word, kept over the stars
SkSum               fdb       0                   SkDot's, SkKMat's, SkTime's sum
SkS                 fcb       0                   SkMul's |s|
SkKw                fdb       0                   SkMul's |k|
SkLo                fcb       0                   SkMul's low product's high byte
SkNeg               fcb       0                   SkMul's sign: $FF negative
SkI                 fcb       0                   SkKMat's word i
SkJ                 fcb       0                   SkKMat's row j
SkK                 fcb       0                   SkKMat's FS axes to go
SkW                 zmb       SkAxes*SkRowBytes   W: rows east, up, north (FS's x, y, z), words equatorial x, y, z (Q15)
SkKX                zmb       SkRowBytes          K: the camera's x row (Q15 words for a star's x, y, z)
SkKY                zmb       SkRowBytes          y
SkKZ                zmb       SkRowBytes          z
SkMask              zmb       (SkN+7)/8           a bit a star, the first in bit 7: 1 above the horizon
SkMaskEnd           equ       *
