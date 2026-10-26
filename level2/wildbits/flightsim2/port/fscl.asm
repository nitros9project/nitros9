********************************************************************
* fscl - FS (Flight Simulator II), WildBits port: the K2's clouds (Roger 2026-10-22/23), all in one block.
*
* A raw binary, not a module, at $4000: the K2's fsx (fst.asm's CbLoad, from GpInit) reads /dd/fs2/fscl into the
* clouds' block (WbAScrn's first, before the panel's; ExitAll frees both), and maps it at $4000 in place of the
* scenery window only while it runs (CbIn, CbOut): ClInit once, ClRun each frame. Its code, its
* variables and its slots are all here; it calls the K2 fsx's routines and reads its variables (fsx at FsxBase the
* while), linked by the K2 fsx's symbol table (fsx_k2.sym: lwasm --symbol-dump, tools/flightsim2/drop.sh).
*
* ClInit (GpInit, after ac.gpu went in): eight cumulus shapes made at random, each 56 triangles and 30 corners in
* 86 mesh entries from GpCF (ac2gpu.py leaves the room: the Learjet is not loaded): a rim, two rings and a top
* corner over it, a sagging ring and a bottom corner under it, seven corners a ring, each turned, pulled in and
* raised at random, so no two clouds and no bottom are flat alike. A corner is in 1/16384 of the shape's length (x
* across -8192..8192, z squashed by ClD, y up from the layer: every corner lifted 0.25 of the shape's height, so the
* lowest sits on the layer and the top reaches 1.25 of it); a ring's cos and sin go through c (2 - |c|) (ClBl), so
* its ends are blunt, not points. Each face carries its own normal (ClFn), and each corner's normal is the sum of its
* faces' (ClNrm), so the Gouraud light follows the shape's real planes, a rock's, not a cotton ball's even puff. The
* faces are screen-doored, white (material 1); a cloud's MESH overrides light gray (material 4) at random.
* ClRun (BdDraw, after the buildings, in their light and projection: the forward and spot views by daylight, while
* vClouds bit 0 is on): the bubble, in map units (256 m) each way from the eye: a cloud past ClGone (24 km) goes;
* while fewer than ClLive (TOTAL_CLOUDS) lie within ClOuter (18 km) one more is made each frame in a free slot, out of sight
* between the drawn circle (ClDraw, 16 km) and ClOuter, any direction whatever the path; with none within ClOuter
* (the start, a jump, new layers) the circle is filled at once, 2-18 km; its shape, color and turn at random, its base on the
* bottom of one of the menu's two cloud layers (vCld1TopFt..vCld1BotFt, vCld2TopFt..vCld2BotFt, feet; one under 56 m
* thick has none, both: no clouds), its height 0.6-1.0 of the layer's thickness, every axis alike (SETMAT scale and
* size). When the menu's layers change, every cloud goes and new ones come on them. Each frame the menu's winds
* move every cloud, the wind at its altitude as FS picks the aircraft's (the shear zone altitudes, each wind's knots
* and direction: ClWind, ClDrift). Each one within ClDraw is drawn: SETMAT with M = C'^T A (A its turn and size, C'
* BdDraw's), T from TfTrans (one behind the eye drawn all the same, as BdDraw's), its scale; MESH its shape with its
* color.

                    nam       fscl
                    ttl       FS2 the K2's clouds

                    use       fsx_k2.sym

* Constants: the values this module's instructions use, by name (fs_wb.d holds the addresses)
ClAxisOfs           equ       1456+$4000          a cloud's turn below its wind's direction: 90 deg plus 8 (half ClAxisSpan), 16-bit angle
ClAxisSpan          equ       2912                a cloud's random turn about its wind, 16-bit angle: +-8 deg (1,456 a side)
ClCapUnder          equ       1                   ClCpD 1: ClCapD's cap, under its ring (wound the other way)
ClCornRadMin        equ       30473               a corner's least radius: 0.93 in Q15 of the ring's
ClCornRadSpan       equ       2294                a corner's radius's random part: 0.07 in Q15 of the ring's
ClCornStep          equ       9362                a ring's corner step, 16-bit angle: 65536 / 7 (ClN corners)
ClCornTurnHalf      equ       550                 half ClCornTurnSpan: a corner's random turn -550..549
ClCornTurnSpan      equ       1100                a corner's random turn's range, 16-bit angle: +-550 (about 3 deg)
ClDirSfc            equ       ClDir+6             the surface wind's direction in ClDir
ClDirW1             equ       ClDir+4             wind 1's direction in ClDir
ClDirW2             equ       ClDir+2             wind 2's direction in ClDir (wind 3's at ClDir)
ClDrfSfc            equ       ClDrf+12            the surface wind's drift in ClDrf (dx, dz)
ClDrfW1             equ       ClDrf+8             wind 1's drift in ClDrf (dx, dz)
ClDrfW2             equ       ClDrf+4             wind 2's drift in ClDrf (dx, dz; wind 3's at ClDrf)
ClDriftFrac         equ       6383                0.1948 in Q15: a knot-tick's drift past 2 (2.1948 in 1/256 m)
ClFillMin           equ       8                   map units (2 km): the filled circle's nearest cloud
ClFillSpan          equ       ClOuter-8+1         the filled circle's distances: ClFillMin..ClOuter (map units)
ClFormMin           equ       ClDraw+1            a new cloud's least distance, map units: just past ClDraw
ClFree              equ       $FF                 ClShp's value for a free cloud slot
ClHMin              equ       2949                ClH's least: the top 0.18 of the shape's length high (1/16384 units)
ClHSpan             equ       983                 ClH's random part: 0.06 of the shape's length (1/16384 units)
ClIEnd              equ       ClI+3               the end of ClI's three corner numbers
ClLiftFrac          equ       8192                0.25 in Q15: every corner's lift, of ClH (the lowest sits on the layer)
ClMinThick          equ       56                  a cloud layer's least thickness, m: a thinner one has no clouds
ClNoSlot            equ       0                   ClSlot 0: no free slot
CloudsOn            equ       1                   vClouds' low byte, bit 0: the scenery's clouds on (F7 / Alt+C)
ClPartLimit         equ       128                 ClNrm: the largest part halved until under it (64-127)
ClPartMin           equ       64                  ClNrm: the largest part doubled until at least it
ClPosZ              equ       ClPos+8             ClPos's Z (32 bits)
ClRadFrac           equ       4915                0.15 in Q15: ClRad (4 m) per size x 2^scale (0.6 of the cloud's length)
ClRandAdd           equ       13849               ClRand's increment
ClRandMul           equ       25173               ClRand's multiplier (x 25173 + 13849, 16 bits)
ClRimToRing1        equ       $0007               ClBand's rings: the rim (corner 0) and the first ring (corner 7), first corners
ClRing1To2          equ       $070E               ClBand's rings: the first ring (corner 7) and the second (corner 14)
ClRing2ToTop        equ       $0E15               ClCap's ring and point: the second ring (corner 14) and the top corner (21)
ClScaleBase         equ       2                   a new cloud's first SETMAT scale (its size then halved or doubled into 128-255)
ClShapes            equ       8                   the cumulus shapes ClInit makes (shape numbers 0-7)
ClShdOn             equ       1                   ClShd 1: ClGo draws the cloud's shadow, not the cloud
ClSizeMax           equ       255                 a cloud's largest size (x 1/256): past it halved, a scale up
ClSizeMin           equ       128                 a cloud's least size (x 1/256): under it doubled, a scale down, while above scale 0
ClSizePerM          equ       27316               0.8336 in Q15 (256 / 307.1): a cloud's size per m of height at scale 2
ClSqrtGuess         equ       128                 ClNrm's square root: Newton's first guess
ClSqrtRounds        equ       5                   ClNrm's square root: Newton's rounds
ClThkFracMin        equ       19661               a cloud's least height: 0.6 in Q15 of the layer's thickness
ClThkFracSpan       equ       13106               a cloud's height's random part: 0.4 in Q15 of the layer's thickness
ClUnderToBot        equ       $161D               ClCapD's ring and point: the under ring (corner 22) and the bottom corner (29)
ClUnderToRim        equ       $1600               ClBand's rings: the under ring (corner 22) and the rim (corner 0)
ClUnitScale         equ       255                 ClUnit: a part x 255 / the length, then x 128 (just under Q15 one)
ClUvBytes           equ       4                   a mesh corner entry's last bytes: texture u, v (two words, 0)
ClVtSize            equ       12                  a corner's bytes in ClVt: x, y, z, its normal (words)
GdAirEnd            equ       $FFFF               GdAir's end marker (gd_air.asm)
GdAirReach          equ       1                   an airport's meadow reach in tiles: dx + this within 0..GdAirSpan
GdAirSpan           equ       2                   2 x GdAirReach: |dx| <= 1 as dx + 1 within 0..this
GdMeadow            equ       2                   GdTex: the meadow's faces past GpGF (0 farmland)
GdScale             equ       4                   the ground's SETMAT scale: 4, 1/4 m units (ac2gpu.py's ground quad)
GdSxY               equ       GdSx+4              GdSx's y part (32 bits): T's step a tile east
GdSxZ               equ       GdSx+8              GdSx's z part (32 bits)
GdSzY               equ       GdSz+4              GdSz's y part (32 bits): T's step a tile north
GdSzZ               equ       GdSz+8              GdSz's z part (32 bits)
GdTileBack          equ       2                   the textured block's tiles before the eye's, each way (5 = 2 + 1 + 2)
GdTiles             equ       5                   the textured block's tiles each way (5 x 5)
HalfRound           equ       1                   added before a halving: rounded
LastHour            equ       23                  the day's last hour (the one before 0)
MPerFtQ8            equ       78                  meters per foot in 1/256 (0.3047): feet to m, as F2 converts altitudes
PosLowZero          equ       0                   a position's low word (1/256 m into its map unit): 0
Q15OneHi            equ       $7F                 Q15 one's high byte: the shadow's normal y (0, 1, 0) a byte at a time
Q15OneLo            equ       $FF                 Q15 one's low byte
SeasonMask          equ       3                   FS's season, its low 2 bits (vSeason - 1: ShTab's season 0-3)
ShFanEnd            equ       ClN-1               the shadow fan's k ends below it: its last face 0, ClN-2, ClN-1
ShFanFirst          equ       1                   the shadow fan's first k (corners 0, k, k + 1)
ShMinThird          equ       182                 546 / 3: the minutes x 182, three times x 546 (Q15 of min / 60)
ShSeasonSize        equ       50                  ShTab's bytes a season: 25 hours, two bytes each
ShSpan              equ       2*ShNear            a shadow's window, map units: -ShNear..ShNear about the eye, offset by ShNear
Sqrt2Less1          equ       13573               0.414 in Q15 (sqrt 2 - 1): 1.414 R = R + R x this (the view's side cull)
TfMEnd              equ       TfM+18              the end of TfM's matrix M (nine Q15 words; T follows)
TriCorners          equ       3                   a triangle's corners
Vec3Bytes           equ       6                   a vector's bytes: three words x, y, z (a corner's place, a normal)
WindHundreds        equ       100                 a wind's knots: its second byte counts hundreds (F2's two bytes)

ClBase              equ       $4000
ClMaxB              equ       $2000

ClN                 equ       7                   corners a ring
ClNf                equ       56                  triangles a shape
ClEnt               equ       86                  mesh entries a shape: 56 triangles, 30 corners
ClLive              equ       TOTAL_CLOUDS        clouds kept within ClOuter (fs_wb.d)
ClMax               equ       TOTAL_CLOUDS*2      cloud slots: those within ClOuter and the ones still in the band behind
ClGone              equ       94                  map units (24 km): past it a cloud goes (16 km and a band 2 x the largest
*                                                 typical cloud, 4 km: Roger 2026-10-22)
* a slot (ClRec bytes)
ClShp               equ       0                   the shape 0-7 ($FF: the slot is free)
ClCol               equ       1                   the color (MESH material override: 0 white, ClMatG light gray)
ClX                 equ       2                   X and Z, 32 bits each (1/256 m, as FS's positions): the wind moves them
ClZ                 equ       6
ClAlt               equ       10                  the altitude of its base (m)
ClScl               equ       12                  the SETMAT scale
ClAc                equ       13                  its A, made once (ClMake): cos k, sin k, k (Q15: k its size /256,
ClAs                equ       15                  every axis alike; the turn at random)
ClAk                equ       17
ClRad               equ       19                  its bounding radius in 4 m (0.6 of its length): the view culls by it
ClRec               equ       21
ClFlags             equ       %00010111           ZTEST, ZWRITE, GOURAUD, SCREENDOOR (gpu3_tri.v's flag bits)
ClMatW              equ       1                   the white ramp (ac2gpu.py MATS)
ClMatG              equ       4                   the light gray ramp
* the clouds' shadows (GROUND TEXTURE 1: FswGdOn; GdRun, ShOne)
ShFace              equ       GpCF+8*ClEnt        their faces, after the eight shapes
ShNf                equ       5                   a fan over the rim's seven corners (each shape's corners 0-6)
ShMat               equ       21                  ground.py's dark green: one color at every level
ShFlags             equ       %00010000           SCREENDOOR alone: no depth test or write, as the ground's tiles
ShNear              equ       20                  map units (5 km): a shadow is drawn when it lands within this of the
*                                                 eye each way (the textured block, 5 tiles of 8)

                    ifgt      8*ClEnt+ShNf-GpCN
                    error     "fscl: eight shapes and the shadow's faces do not fit the mesh room (GpCN)"
                    endc

                    org       ClBase
                    jmp       ClInit              ClBase+0: the shapes, the slots free
                    jmp       ClRun               ClBase+3: a frame's clouds
                    jmp       GdRun               ClBase+6: the textured ground (fst's GdDraw)

ClOk                fcb       0                   1: the shapes are in the GPU
ClSeed              fdb       0
ClK                 fcb       0                   the shape being made
ClJ                 fcb       0                   a corner, a step round a ring
ClCnt               fcb       0                   clouds within 16 km
ClSlot              fdb       0                   a free slot (0: none)
ClD                 fdb       0                   the shape's z squash (Q15)
ClH                 fdb       0                   its top's height
ClLift              fdb       0                   every corner's lift: 0.25 ClH
ClBot               fdb       0                   a new cloud's layer: its bottom, its thickness (m)
ClThk               fdb       0
ClLyrs              zmb       8                   the menu's layers as the last frame had them
ClSc                fcb       0                   a new cloud's scale and size
ClSz                fcb       0
ClTk                fcb       0                   this frame's ticks
ClDrf               zmb       16                  this frame's drift for each wind (vWind3 first): dx, dz (1/256 m)
ClDir               zmb       8                   each wind's direction (vWind3 first; FS's angle, offsets added: ClWind)
ClR                 fdb       0                   a corner's radius; a new cloud's distance
ClC                 fdb       0                   a cosine and a sine
ClS                 fdb       0
ClAng               fdb       0                   an angle
ClU                 fdb       0                   the ring being made
ClT                 fdb       0                   a partial sum
ClAB                zmb       2                   a band's or a cap's rings: their first corners
ClQ                 zmb       4                   a band's quad: a, b, c, d
ClI                 zmb       3                   a face's corners
ClCpD               fcb       0                   1: ClCapD's cap, under its ring
ClV                 zmb       12                  a corner: x, y, z, its normal
ClCb                fdb       0                   ClC, ClS blunted (ClBl): the corner's place round the ring
ClSb                fdb       0
ClVp                fdb       0                   the next corner's place in ClVt
ClE1                zmb       6                   a face's edges p1 - p0, p2 - p0 (x 2)
ClE2                zmb       6
ClN3                zmb       6                   its unit normal (Q15)
ClMx                fdb       0                   the normal's largest part; then its length
ClSq                fdb       0                   the sum of its parts' squares
ClPos               zmb       12                  a cloud's position (1/256 m)
ClA                 zmb       10                  its A: cos k, sin k, k, -sin k, cos k (k its size)
ClMsh               zmb       7                   its MESH: first face, count, corner base, material override
ClTm                zmb       6                   F$Time
ClShd               fcb       0                   1: ClGo draws the cloud's shadow (ShOne), not the cloud
ShFx                fdb       0                   a shadow's offset east, north per m of height (Q11): ShSun
ShFz                fdb       0
ShDx                fdb       0                   this one's offset east, north / 16 (m)
ShDz                fdb       0
ShT                 fdb       0
ShMin               fdb       0                   the minutes x 546 (Q15 of min / 60)
ClDraw              equ       63                  map units (16 km): the clouds within are drawn
ClOuter             equ       71                  (18 km): new ones form between ClDraw and it, out of sight (Roger 2026-10-23:
*                                                 none seen to "poof" in near), and ClLive count within it
ClFill              fcb       0                   1: the circle is being filled at once (ClMake: 2-18 km, anywhere)
ClTri               fcb       0,1,2,0,2,3         a quad's two triangles, split a-c
                    fcb       0,1,3,1,2,3         or split b-d
* the rings, rim first (ClRing bytes each): the radius (of 8192), the corners, the height's base and range (Q15 of
* ClH)
ClRing              equ       7
* (2026-10-23: the rings over and under the rim 0.90 of it, not 0.72 and 0.62: the rim no longer juts out past
* them, so the ends are rounded walls, not blades)
ClRings             fdb       8192
                    fcb       ClN
                    fdb       -1966,4588          the rim: -0.06..0.08
                    fdb       7373
                    fcb       ClN
                    fdb       15729,4588          0.90 of the rim: 0.48..0.62
                    fdb       4915
                    fcb       ClN
                    fdb       25559,3932          0.60: 0.78..0.90
                    fdb       0
                    fcb       1
                    fdb       29491,3277          the top: 0.90..1.0
                    fdb       7373
                    fcb       ClN
                    fdb       -5243,2621          under, 0.90: -0.16..-0.08
                    fdb       0
                    fcb       1
                    fdb       -6554,1966          the bottom: -0.20..-0.14
ClRingsE            equ       *

* ClInit (GpInit): every slot free; with the meshes in (GpOn), the eight shapes to the GPU. Registers clobbered.
ClInit              clr       ClOk
                    ldx       #ClTab
                    lda       #ClFree
ci1@                sta       ,x
                    leax      ClRec,x
                    cmpx      #ClTab+ClMax*ClRec
                    blo       ci1@
                    tst       GpOn
                    beq       ci9@
                    ldx       #ClTm               the seed: the time of day
                    swi2
                    fcb       F$Time
                    ldd       ClTm+4              minutes, seconds
                    eora      ClTm+3              the hour
                    std       ClSeed
                    clr       ClK
ci2@                lbsr      ClShape
                    inc       ClK
                    lda       ClK
                    cmpa      #ClShapes
                    blo       ci2@
                    lbsr      ShMake
                    inc       ClOk
ci9@                rts

* ClShape: shape ClK to the GPU from mesh entry GpCF + 86 ClK: its 56 faces, then its 30 corners, ring by ring.
ClShape             lda       ClK
                    ldb       #ClEnt
                    mul
                    addd      #GpCF
                    lbsr      ClUpA
                    ldd       #ClHSpan            the top 0.18-0.24 of the length high (was 0.30-0.43; ClMake's U
                    lbsr      ClRnd               follows the tallest)
                    addd      #ClHMin
                    std       ClH
* z squashed to 3.25-4.0 ClH (Q15): 1.625-2.0 x the top's height (1.25 ClH), so a cloud seen end-on is wider than
* tall (at 0.20-0.28 of the length it stood on end)
                    lsra
                    rorb
                    lsra
                    rorb
                    std       ClT                 ClH / 4
                    ldd       ClH
                    subd      ClT
                    lbsr      ClRnd               0..0.75 ClH
                    addd      ClT
                    addd      ClH
                    addd      ClH
                    addd      ClH
                    std       ClD
                    ldd       ClH
                    ldx       #ClLiftFrac         every corner lifted 0.25 of it: the lowest sits on the layer
                    lbsr      MqXY
                    std       ClLift
                    ldd       #ClVt               the corners first, into ClVt: the faces' normals need them
                    std       ClVp
                    ldu       #ClRings
cs1@                clr       ClJ
cs2@                stu       ClU
                    lbsr      ClVtx
                    ldu       ClU
                    inc       ClJ
                    lda       ClJ
                    cmpa      2,u
                    blo       cs2@
                    leau      ClRing,u
                    cmpu      #ClRingsE
                    blo       cs1@
                    ldd       #ClRimToRing1       the faces: the rim to the first ring
                    lbsr      ClBand
                    ldd       #ClRing1To2         the first ring to the second
                    lbsr      ClBand
                    ldd       #ClRing2ToTop       the second ring to the top
                    lbsr      ClCap
                    ldd       #ClUnderToRim       the under ring to the rim
                    lbsr      ClBand
                    ldd       #ClUnderToBot       the under ring to the bottom
                    lbsr      ClCapD
                    ldx       #ClVt               then the corners: each entry, its normal the sum of its faces' made
cs3@                leax      6,x                 a unit vector, u 0, v 0
                    lbsr      ClNrm
                    leax      -6,x
                    ldb       #ClVtSize
cs4@                lda       ,x+
                    lbsr      ClPut
                    decb
                    bne       cs4@
                    clra
                    ldb       #ClUvBytes
cs5@                lbsr      ClPut
                    decb
                    bne       cs5@
                    cmpx      ClVp
                    blo       cs3@
                    lbra      ClUpF               the shape's last entries up
* ClUpA: D = a mesh entry: UP_ADDR set to it, after FIFO room (ClUpB empty: ClUpF went first). Registers clobbered.
ClUpA               aslb                          x 16: the entry's byte in the mesh space
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    std       ClAd+1              UP_ADDR: the mesh space ($40), then the byte, as GpLoad
                    lbsr      GpRoom              (registers kept)
                    ldy       #ClAdR
                    ldu       #UpAdrBytes
                    ldx       #GpFnLPkN
                    clra                          GpCall: its SetStat functions
                    lbsr      GpCall
                    rts

* ClPut: A = UP_DATA's next byte, into ClUpB; a full ClUpB goes up first (ClUpF). Registers kept but CC.
ClPut               pshs      x
                    ldx       ClUpP
                    cmpx      #ClUpB+ClUpN
                    blo       cp1@
                    bsr       ClUpF
                    ldx       ClUpP
cp1@                sta       ,x+
                    stx       ClUpP
                    puls      x,pc
* ClUpF: ClUpB's bytes to UP_DATA, after FIFO room for them (GpRoom: 260 units), in one GpuF.LPkN (ClUpR: mask 0,
* every byte to the one port); ClUpB emptied. Registers kept but CC.
ClUpF               pshs      d,x,y,u
                    ldd       ClUpP
                    subd      #ClUpB
                    beq       cu9@
                    tfr       d,u                 the bytes
                    lbsr      GpRoom
                    ldy       #ClUpR
                    ldx       #GpFnLPkN
                    clra                          GpCall: its SetStat functions
                    lbsr      GpCall
                    ldd       #ClUpB
                    std       ClUpP
cu9@                puls      d,x,y,u,pc
ClUpN               equ       256                 a GpRoom's worth (16 entries)
ClUpP               fdb       ClUpB               the next byte's place in ClUpB
ClAdR               fdb       Gpu.UpAdr           GpuF.LPkN's request: UP_ADDR's 3 bytes (mask 3), then them
                    fcb       3,0
ClAd                fcb       $40,0,0

* ClBand: A, B = the first corners of two rings: the band between them, two triangles a step, split either way
* at random. Registers clobbered.
ClBand              std       ClAB
                    clr       ClJ
cb1@                ldb       ClJ                 k1 = k + 1, round the ring
                    incb
                    cmpb      #ClN
                    blo       cb2@
                    clrb
cb2@                lda       ClAB                a = A + k
                    adda      ClJ
                    sta       ClQ
                    tfr       b,a                 b = A + k1
                    adda      ClAB
                    sta       ClQ+1
                    tfr       b,a                 c = B + k1
                    adda      ClAB+1
                    sta       ClQ+2
                    lda       ClAB+1              d = B + k
                    adda      ClJ
                    sta       ClQ+3
                    lbsr      ClRand
                    ldx       #ClTri
                    tsta
                    bpl       cb3@
                    leax      6,x
cb3@                bsr       ClTri3
                    bsr       ClTri3
                    inc       ClJ
                    lda       ClJ
                    cmpa      #ClN
                    blo       cb1@
                    rts
* ClTri3: the face of the quad's corners named by the three bytes at X (X past them).
ClTri3              ldu       #ClI
                    ldy       #ClQ
                    ldb       #TriCorners
ct1@                lda       ,x+
                    lda       a,y
                    sta       ,u+
                    decb
                    bne       ct1@
                    pshs      x
                    bsr       ClFace
                    puls      x,pc

* ClCap: A = a ring's first corner, B = a single corner over it: the ring's seven triangles to it, wound as the bands
* (ClFn's e2 x e1 out). ClCapD: the same with the corner under the ring, wound the other way. Registers clobbered.
ClCapD              pshs      a
                    lda       #ClCapUnder
                    sta       ClCpD
                    puls      a
                    bra       ClCap1
ClCap               clr       ClCpD
ClCap1              std       ClAB
                    clr       ClJ
cc1@                ldb       ClJ
                    incb
                    cmpb      #ClN
                    blo       cc2@
                    clrb
cc2@                addb      ClAB
                    stb       ClI+1
                    lda       ClAB
                    adda      ClJ
                    sta       ClI
                    tst       ClCpD
                    beq       cc3@
                    ldd       ClI                 under: A + k1 first
                    exg       a,b
                    std       ClI
cc3@                lda       ClAB+1
                    sta       ClI+2
                    bsr       ClFace
                    inc       ClJ
                    lda       ClJ
                    cmpa      #ClN
                    blo       cc1@
                    rts

* ClFace: a face entry for the corners in ClI: their numbers (words), the white material, no texture, the flags, 0,
* its normal (ClFn), through ClPut; the normal / 16 added to each of its corners' sums (ClVt). Registers clobbered.
ClFace              lbsr      ClFn
                    ldx       #ClI
cf0@                lda       ,x+
                    lbsr      ClVa
                    ldd       ClN3
                    bsr       ClQ16
                    addd      6,y
                    std       6,y
                    ldd       ClN3+2
                    bsr       ClQ16
                    addd      8,y
                    std       8,y
                    ldd       ClN3+4
                    bsr       ClQ16
                    addd      10,y
                    std       10,y
                    cmpx      #ClIEnd
                    blo       cf0@
                    ldx       #ClI
                    ldb       #TriCorners
cf1@                clra
                    lbsr      ClPut
                    lda       ,x+
                    lbsr      ClPut
                    decb
                    bne       cf1@
                    lda       #ClMatW
                    lbsr      ClPut
                    clra
                    lbsr      ClPut
                    lda       #ClFlags
                    lbsr      ClPut
                    clra
                    lbsr      ClPut
                    ldx       #ClN3
                    ldb       #Vec3Bytes
cf2@                lda       ,x+
                    lbsr      ClPut
                    decb
                    bne       cf2@
                    rts
* ClQ16: D = D / 16 (arithmetic).
ClQ16               asra
                    rorb
                    asra
                    rorb
                    asra
                    rorb
                    asra
                    rorb
                    rts
* ClVa: Y = corner A's entry in ClVt. D clobbered.
ClVa                ldb       #ClVtSize
                    mul
                    addd      #ClVt
                    tfr       d,y
                    rts

* ClFn: ClN3 = the face at ClI's unit normal (Q15), outward: e2 x e1 (e1 = p1 - p0, e2 = p2 - p0, from ClVt, doubled
* into Q15 for MqXY; every face winds so that e1 x e2 points in), then ClNrm. Registers clobbered.
ClFn                lda       ClI
                    lbsr      ClVa
                    pshs      y                   p0
                    lda       ClI+1
                    lbsr      ClVa
                    tfr       y,x
                    ldy       ,s
                    ldu       #ClE1
                    lbsr      ClEdge
                    lda       ClI+2
                    lbsr      ClVa
                    tfr       y,x
                    puls      y
                    ldu       #ClE2
                    lbsr      ClEdge
                    ldd       ClE2+2              x: e2y e1z - e2z e1y
                    ldx       ClE1+4
                    lbsr      MqXY
                    std       ClN3
                    ldd       ClE2+4
                    ldx       ClE1+2
                    lbsr      MqXY
                    pshs      d
                    ldd       ClN3
                    subd      ,s++
                    std       ClN3
                    ldd       ClE2+4              y: e2z e1x - e2x e1z
                    ldx       ClE1
                    lbsr      MqXY
                    std       ClN3+2
                    ldd       ClE2
                    ldx       ClE1+4
                    lbsr      MqXY
                    pshs      d
                    ldd       ClN3+2
                    subd      ,s++
                    std       ClN3+2
                    ldd       ClE2                z: e2x e1y - e2y e1x
                    ldx       ClE1+2
                    lbsr      MqXY
                    std       ClN3+4
                    ldd       ClE2+2
                    ldx       ClE1
                    lbsr      MqXY
                    pshs      d
                    ldd       ClN3+4
                    subd      ,s++
                    std       ClN3+4
                    ldx       #ClN3
                    lbra      ClNrm
* ClEdge: U = (the corner at X - the corner at Y) x 2, x, y, z.
ClEdge              ldd       ,x
                    subd      ,y
                    aslb
                    rola
                    std       ,u
                    ldd       2,x
                    subd      2,y
                    aslb
                    rola
                    std       2,u
                    ldd       4,x
                    subd      4,y
                    aslb
                    rola
                    std       4,u
                    rts

* ClNrm: the three words at X made a unit vector (Q15), in place: all halved or doubled until the largest part is
* 64-127 (its square and the sum of three fit 16 bits), its length the square root of that sum (Newton from 128,
* five rounds, MATH_DIV), then each part x 255 / the length, x 128. All zero: straight up. X kept.
ClNrm               clra
                    clrb
                    std       ClMx
                    ldd       ,x
                    lbsr      ClBig
                    ldd       2,x
                    lbsr      ClBig
                    ldd       4,x
                    lbsr      ClBig
                    ldd       ClMx
                    bne       nm2@
                    std       ,x                  no length: up
                    std       4,x
                    ldd       #Q15One
                    std       2,x
                    rts
nm1@                lsra                          halved
                    rorb
                    std       ClMx
                    asr       ,x
                    ror       1,x
                    asr       2,x
                    ror       3,x
                    asr       4,x
                    ror       5,x
nm2@                ldd       ClMx
                    cmpd      #ClPartLimit
                    bhs       nm1@
nm3@                cmpd      #ClPartMin
                    bhs       nm4@
                    aslb                          doubled
                    rola
                    std       ClMx
                    asl       1,x
                    rol       ,x
                    asl       3,x
                    rol       2,x
                    asl       5,x
                    rol       4,x
                    bra       nm3@
nm4@                clra
                    clrb
                    std       ClSq
                    ldd       ,x
                    lbsr      ClSqA
                    ldd       2,x
                    lbsr      ClSqA
                    ldd       4,x
                    lbsr      ClSqA
                    ldd       #ClSqrtGuess        the length: L = (L + S / L) / 2
                    std       ClMx
                    lda       #ClSqrtRounds
                    pshs      a
nm5@                ldd       ClMx
                    std       >MATH_DIV_SOR
                    ldd       ClSq
                    std       >MATH_DIV_END
                    nop
                    nop
                    nop
                    nop
                    nop
                    nop
                    ldd       >MATH_DIV_QUOT
                    addd      ClMx
                    lsra
                    rorb
                    std       ClMx
                    dec       ,s
                    bne       nm5@
                    puls      a
                    leay      ,x
                    lbsr      ClUnit
                    leay      2,x
                    lbsr      ClUnit
                    leay      4,x
* ClUnit: the part at Y (-128..127) x 255 / ClMx, x 128 (Q15), its sign kept.
ClUnit              ldd       ,y
                    pshs      a
                    bpl       un1@
                    coma
                    comb
                    addd      #NegCarry
un1@                lda       #ClUnitScale
                    mul
                    pshs      d
                    ldd       ClMx
                    std       >MATH_DIV_SOR
                    puls      d
                    std       >MATH_DIV_END
                    nop
                    nop
                    nop
                    nop
                    nop
                    nop
                    ldd       >MATH_DIV_QUOT
                    tfr       b,a
                    clrb
                    lsra
                    rorb
                    tst       ,s+
                    bpl       un2@
                    coma
                    comb
                    addd      #NegCarry
un2@                std       ,y
                    rts
* ClBig: ClMx = the larger of it and |D|. ClSqA: ClSq += D squared (|D| 0-128).
ClBig               tsta
                    bpl       mx1@
                    coma
                    comb
                    addd      #NegCarry
mx1@                cmpd      ClMx
                    bls       mx9@
                    std       ClMx
mx9@                rts
ClSqA               tsta
                    bpl       sq1@
                    coma
                    comb
                    addd      #NegCarry
sq1@                tfr       b,a
                    mul
                    addd      ClSq
                    std       ClSq
                    rts
* ClBl: D = c (Q15) -> c (2 - |c|): a ring's place, its ends blunt (an ellipse's ends are points once it is squashed
* thin). Saturates at 1.
ClBl                pshs      d
                    tsta
                    bpl       bl1@
                    coma
                    comb
                    addd      #NegCarry
bl1@                tfr       d,x
                    ldd       ,s
                    lbsr      MqXY                c |c|
                    pshs      d
                    ldd       2,s
                    subd      ,s++                c - c |c|
                    addd      ,s++                + c
                    bvc       bl9@
                    ldd       #Q15One
bl9@                rts

* ClVtx: corner ClJ of the ring at ClU into ClVt (ClVp): turned j/7 of a circle +-3 deg, at 0.93-1.0 of the ring's
* radius, its cos and sin blunted (ClBl), z squashed by ClD; its height ClH x (the ring's base + a random part of its
* range); its normal 0, the sum of its faces' to come (ClFace). Registers clobbered.
ClVtx               clra                          the turn: j x 9362 (65536 / 7)
                    ldb       ClJ
                    std       >MATH_MUL_A
                    ldd       #ClCornStep
                    std       >MATH_MUL_B
                    ldd       >MATH_MUL_P+2
                    std       ClAng
                    ldd       #ClCornTurnSpan     +-550
                    lbsr      ClRnd
                    subd      #ClCornTurnHalf
                    addd      ClAng
                    std       ClAng
                    jsr       >FsCos16
                    lbsr      ClBl
                    std       ClCb
                    ldd       ClAng
                    jsr       >FsSin16
                    lbsr      ClBl
                    std       ClSb
                    ldd       #ClCornRadSpan      the radius: 0.93-1.0 of the ring's
                    lbsr      ClRnd
                    addd      #ClCornRadMin
                    ldu       ClU
                    ldx       ,u
                    lbsr      MqXY
                    std       ClR
                    ldx       ClCb                x = r cos
                    lbsr      MqXY
                    std       ClV
                    ldd       ClR                 z = r sin D
                    ldx       ClSb
                    lbsr      MqXY
                    ldx       ClD
                    lbsr      MqXY
                    std       ClV+4
                    ldu       ClU                 y = H fb + 0..H fr
                    ldd       5,u
                    ldx       ClH
                    lbsr      MqXY
                    lbsr      ClRnd
                    std       ClT
                    ldu       ClU
                    ldd       3,u
                    ldx       ClH
                    lbsr      MqXY
                    addd      ClT
                    addd      ClLift
                    std       ClV+2
                    ldx       #ClV                x, y, z, the normal's sum 0, into ClVt
                    ldu       ClVp
                    ldb       #Vec3Bytes
cv1@                lda       ,x+
                    sta       ,u+
                    decb
                    bne       cv1@
                    clra
                    ldb       #Vec3Bytes
cv2@                sta       ,u+
                    decb
                    bne       cv2@
                    stu       ClVp
                    rts

* ClRand: D = the next number (x 25173 + 13849, 16 bits; its high bits the better). ClRnd: D = 0..D-1 (the
* number x D, its high word). Both keep X, Y and U.
ClRand              ldd       ClSeed
                    std       >MATH_MUL_A
                    ldd       #ClRandMul
                    std       >MATH_MUL_B
                    ldd       >MATH_MUL_P+2
                    addd      #ClRandAdd
                    std       ClSeed
                    rts
ClRnd               pshs      d
                    bsr       ClRand
                    std       >MATH_MUL_A
                    puls      d
                    std       >MATH_MUL_B
                    ldd       >MATH_MUL_P
                    rts

* ClRun (BdDraw): the bubble, a new cloud, then the clouds within 16 km. Registers clobbered.
ClRun               tst       ClOk
                    lbeq      cr9@
                    lda       >vClouds+1          F7 / Alt+C: off
                    bita      #CloudsOn
                    lbeq      cr9@
                    ldx       #vCld2TopFt         the menu's layers changed since the last frame: every cloud goes,
                    ldu       #ClLyrs             and new ones come on the new layers
                    clrb
cl1@                ldy       ,x++
                    cmpy      ,u
                    beq       cl2@
                    sty       ,u
                    incb
cl2@                leau      2,u
                    cmpx      #vCldFtEnd
                    blo       cl1@
                    tstb
                    beq       cl4@
                    ldx       #ClTab
                    lda       #ClFree
cl3@                sta       ,x
                    leax      ClRec,x
                    cmpx      #ClTab+ClMax*ClRec
                    blo       cl3@
cl4@                lbsr      ClWind              this frame's drift for each wind
                    clr       ClCnt
                    ldd       #ClNoSlot
                    std       ClSlot
                    ldx       #ClTab
cr1@                lda       ClShp,x
                    bmi       cr3@                free
                    lbsr      ClDrift             the wind at its altitude moves it
                    lbsr      ClDist
                    cmpd      #ClGone
                    bls       cr2@
                    lda       #ClFree             past 24 km: gone
                    sta       ClShp,x
                    bra       cr3@
cr2@                cmpd      #ClOuter
                    bhi       cr4@
                    inc       ClCnt
                    bra       cr4@
cr3@                stx       ClSlot
cr4@                leax      ClRec,x
                    cmpx      #ClTab+ClMax*ClRec
                    blo       cr1@
* new clouds: none within ClOuter (the start, a jump, the menu's layers changed): the circle filled at once, this
* frame (no cloud is seen forming one by one); else one a frame while fewer than ClLive, out of sight in the ring
* between ClDraw and ClOuter (ClMake, ClFill 0)
                    lda       ClCnt
                    bne       cr4a@
                    inc       ClFill
                    ldx       #ClTab
cf1@                lda       ClShp,x
                    bpl       cf2@                in use
                    lda       ClCnt
                    cmpa      #ClLive
                    bhs       cf9@
                    lbsr      ClMake
                    lda       ClShp,x
                    bmi       cf9@                no layer: none made
                    inc       ClCnt
cf2@                leax      ClRec,x
                    cmpx      #ClTab+ClMax*ClRec
                    blo       cf1@
cf9@                clr       ClFill
                    bra       cr5@
cr4a@               cmpa      #ClLive             fewer than ClLive within ClOuter: one more, in the ring
                    bhs       cr5@
                    ldx       ClSlot
                    beq       cr5@
                    lbsr      ClMake
cr5@                ldx       #ClTab
cr6@                lda       ClShp,x
                    bmi       cr8@
                    lbsr      ClDist
                    cmpd      #ClDraw
                    bhi       cr8@
                    pshs      x
                    lbsr      ClOne
                    puls      x
cr8@                leax      ClRec,x
                    cmpx      #ClTab+ClMax*ClRec
                    blo       cr6@
cr9@                rts

* ClDist: D = the slot at X's distance from the eye in map units: the larger of |dx| and |dz|. X kept.
ClDist              ldu       TfEye
                    ldd       ClX,x
                    subd      ,u
                    bpl       cd1@
                    lbsr      TfNegD
cd1@                pshs      d
                    ldd       ClZ,x
                    subd      8,u
                    bpl       cd2@
                    lbsr      TfNegD
cd2@                cmpd      ,s
                    bhs       cd3@
                    ldd       ,s
cd3@                leas      2,s
                    rts

* ClLayer: one of the menu's two cloud layers (its feet: vCld1TopFt/vCld1BotFt, vCld2TopFt/vCld2BotFt) at random,
* the other when that one is under 56 m thick: ClBot its bottom, ClThk its thickness (m). Carry: neither (no
* cloud). X kept.
ClLayer             lbsr      ClRand
                    ldu       #vCld1TopFt
                    tsta
                    bpl       cy1@
                    ldu       #vCld2TopFt
cy1@                bsr       ClLyr1
                    bcc       cy9@
                    cmpu      #vCld1TopFt         that one too thin: the other
                    beq       cy2@
                    ldu       #vCld1TopFt
                    bra       ClLyr1
cy2@                ldu       #vCld2TopFt
* ClLyr1: the layer at U (two words in feet, either order): ClBot the lower in m, ClThk the difference; carry when
* that is under 56 m. X, U kept.
ClLyr1              ldd       ,u
                    bsr       ClFtM
                    std       ClT
                    ldd       2,u
                    bsr       ClFtM
                    cmpd      ClT
                    bls       cy3@
                    pshs      d                   the second is the higher: the first the bottom
                    ldd       ClT
                    std       ClBot
                    puls      d
                    subd      ClT
                    bra       cy4@
cy3@                std       ClBot               the second is the bottom
                    ldd       ClT
                    subd      ClBot
cy4@                std       ClThk
                    cmpd      #ClMinThick
cy9@                rts
* ClFtM: D feet -> D m (x 78 / 256, as F2 converts its altitudes). X, U kept.
ClFtM               std       >MATH_MUL_A
                    ldd       #MPerFtQ8
                    std       >MATH_MUL_B
                    ldd       >MATH_MUL_P+1
                    rts

* ClWind: this frame's drift for each of the menu's winds, turned as FS's ComputeWindDrift turns them (the
* direction plus the area's vHdgOfs1, the surface wind's plus vHdgOfs2 too, high bytes) and pushed as its
* ApplyWindDrift pushes the aircraft (dx = -d sin, dz = -d cos): d = knots x ticks x 2.1948 (1/256 m: 0.5144 m/s a
* knot, 60 ticks a second; TfTick: FS's time step, so a paused frame moves nothing). ClDrf + 4k for the wind at
* vWind3 + 4k. Registers clobbered.
ClWind              lbsr      TfTick
                    stb       ClTk
                    ldy       #vWind3
                    ldu       #ClDrf
cw1@                lda       1,y                 knots: the hundreds, then the rest (F2's two bytes)
                    ldb       #WindHundreds
                    mul
                    addb      ,y
                    adca      #CarryOnly
                    std       >MATH_MUL_A
                    clra
                    ldb       ClTk
                    std       >MATH_MUL_B
                    ldd       >MATH_MUL_P+2       n = knots x ticks
                    pshs      d
                    ldx       #ClDriftFrac        d = 2 n + n x 0.1948
                    lbsr      MqXY
                    addd      ,s
                    addd      ,s++
                    std       ClT
                    ldd       2,y                 the direction
                    adda      >vHdgOfs1
                    cmpy      #vWindSfc
                    bne       cw2@
                    adda      >vHdgOfs2
cw2@                std       ClAng
                    pshs      d                   ClDir's word for this wind: (Y - vWind3) / 2
                    tfr       y,d
                    subd      #vWind3
                    lsra
                    rorb
                    ldx       #ClDir
                    leax      d,x
                    puls      d
                    std       ,x
                    pshs      y,u
                    jsr       >FsSin16
                    puls      y,u
                    ldx       ClT
                    lbsr      MqXY
                    lbsr      TfNegD
                    std       ,u
                    ldd       ClAng
                    pshs      y,u
                    jsr       >FsCos16
                    puls      y,u
                    ldx       ClT
                    lbsr      MqXY
                    lbsr      TfNegD
                    std       2,u
                    leau      4,u
                    leay      4,y
                    cmpy      #vWindEnd
                    blo       cw1@
                    rts

* ClDrift: the cloud in the slot at X moved by the wind at its base's altitude, as FS picks the aircraft's: under
* vShear1 the surface wind, under vShear2 wind 1, under vShear3 wind 2, above it wind 3. X kept.
ClDrift             ldd       ClAlt,x
                    ldu       #ClDrfSfc
                    cmpd      >vShear1
                    blo       dd1@
                    ldu       #ClDrfW1
                    cmpd      >vShear2
                    blo       dd1@
                    ldu       #ClDrfW2
                    cmpd      >vShear3
                    blo       dd1@
                    ldu       #ClDrf
dd1@                leay      ClX,x
                    ldd       ,u
                    bsr       ClAdd
                    leay      ClZ,x
                    ldd       2,u
* ClAdd: the 32-bit value at Y += D, sign-extended. X, Y, U kept.
ClAdd               pshs      d
                    addd      2,y
                    std       2,y
                    ldd       ,y
                    adcb      #CarryOnly
                    adca      #CarryOnly
                    tst       ,s
                    bpl       ca1@
                    subd      #SignExtNeg
ca1@                std       ,y
                    puls      d,pc

* ClMake: a new cloud in the slot at X (X kept), on a layer of the menu's (none: the slot stays free). Registers
* clobbered.
ClMake              lbsr      ClLayer
                    bcc       cm0@
                    rts
cm0@                pshs      x
                    ldd       #ClOuter-ClDraw     the distance: out of sight between ClDraw and ClOuter (16-18 km),
                    lbsr      ClRnd               any direction, whatever the path; while the circle is filled at
                    addd      #ClFormMin          once (ClFill), anywhere 2-18 km
                    tst       ClFill
                    beq       cm1@
                    ldd       #ClFillSpan
                    lbsr      ClRnd
                    addd      #ClFillMin
cm1@                std       ClR
                    lbsr      ClRand
                    std       ClAng
                    ldd       ClAng               X = the eye's + d sin (whole map units), as FS moves the aircraft
                    jsr       >FsSin16
                    ldx       ClR
                    lbsr      MqXY
                    ldu       TfEye
                    addd      ,u
                    ldx       ,s
                    std       ClX,x
                    ldd       #PosLowZero
                    std       ClX+2,x
                    ldd       ClAng               Z = the eye's + d cos
                    jsr       >FsCos16
                    ldx       ClR
                    lbsr      MqXY
                    ldu       TfEye
                    addd      8,u
                    ldx       ,s
                    std       ClZ,x
                    ldd       #PosLowZero
                    std       ClZ+2,x
                    ldd       ClBot               its base: the layer's bottom
                    std       ClAlt,x
                    lbsr      ClRand              the color: light gray or the shape's white
                    ldb       #ClMatG
                    tsta
                    bmi       cm3@
                    clrb
cm3@                stb       ClCol,x
* the turn (A, below): its long axis along the wind at its base (the one ClDrift moves it by), +-8 deg, as cloud
* streets lie. The wind blows from W (its drift -sin W, -cos W: ClWind); A turns the shape's x axis to (cos a,
* -sin a) east and north, so a = W - 90 deg
                    ldd       ClAlt,x
                    ldu       #ClDirSfc           the surface wind's
                    cmpd      >vShear1
                    blo       cm4@
                    ldu       #ClDirW1            wind 1's
                    cmpd      >vShear2
                    blo       cm4@
                    ldu       #ClDirW2            wind 2's
                    cmpd      >vShear3
                    blo       cm4@
                    ldu       #ClDir              wind 3's
cm4@                ldd       #ClAxisSpan         +-8 deg: 1,456 a side
                    lbsr      ClRnd
                    subd      #ClAxisOfs
                    addd      ,u
                    std       ClAng
* its size: its height 0.6-1.0 of the layer's thickness, every axis alike (it never stands taller than its shape
* has it, and grows all round with the layer): U = h x 256 / 307.1 (the tallest shape at scale 2 and size 256
* stands 307.1 m: 1.25 x 3,931 units of 2^2 / 64 m; ClShape's ClH tops out at 3,931), then halved a scale up or
* doubled a scale down to 128-255
                    ldd       #ClThkFracSpan
                    lbsr      ClRnd
                    addd      #ClThkFracMin
                    ldx       ClThk               h = T x 0.6-1.0
                    lbsr      MqXY
                    ldx       #ClSizePerM         U = h x 0.8336
                    lbsr      MqXY
                    std       ClT
                    lda       #ClScaleBase
                    sta       ClSc
cm5@                ldd       ClT
                    cmpd      #ClSizeMax
                    bls       cm6@
                    addd      #HalfRound          halved, rounded: a scale up
                    lsra
                    rorb
                    std       ClT
                    inc       ClSc
                    bra       cm5@
cm6@                cmpd      #ClSizeMin
                    bhs       cm7@
                    tst       ClSc
                    beq       cm7@
                    lslb                          doubled: a scale down
                    rola
                    std       ClT
                    dec       ClSc
                    bra       cm6@
cm7@                stb       ClSz
                    ldx       ,s
                    lda       ClSc
                    sta       ClScl,x
                    lda       ClSz                A, made once: k = the size /256 in Q15 (x 128), cos k, sin k
                    clrb
                    lsra
                    rorb
                    std       ClAk,x
                    ldd       ClAng
                    jsr       >FsCos16
                    ldx       ,s
                    ldx       ClAk,x
                    lbsr      MqXY
                    ldx       ,s
                    std       ClAc,x
                    ldd       ClAng
                    jsr       >FsSin16
                    ldx       ,s
                    ldx       ClAk,x
                    lbsr      MqXY
                    ldx       ,s
                    std       ClAs,x
                    lda       ClSc                its radius in 4 m: 0.15 x size x 2^scale (0.6 of its length)
                    sta       ClJ
                    clra
                    ldb       ClSz
cm8@                tst       ClJ
                    beq       cm9@
                    lslb
                    rola
                    dec       ClJ
                    bra       cm8@
cm9@                ldx       #ClRadFrac
                    lbsr      MqXY
                    ldx       ,s
                    std       ClRad,x
                    ldd       #ClShapes           the shape: last, the slot in use from here
                    lbsr      ClRnd
                    stb       ClShp,x
                    puls      x,pc

* ClOne: the cloud in the slot at X: its position, T (TfTrans with BdDraw's C'), M = C'^T A, SETMAT, MESH.
* ClGo (ShOne too, with ClShd 1 and the slot at ,s): from ClPos on. Registers clobbered.
ClOne               pshs      x
                    clr       ClShd
                    ldd       ClX,x               X, Z as the wind left them, Y the altitude x 256
                    std       ClPos
                    ldd       ClX+2,x
                    std       ClPos+2
                    ldd       ClZ,x
                    std       ClPos+8
                    ldd       ClZ+2,x
                    std       ClPos+10
                    ldd       ClAlt,x
                    std       ClPos+5
                    clra
                    sta       ClPos+4
                    sta       ClPos+7
ClGo                ldx       #ClPos
                    lbsr      TfTrans
                    bcc       co0@
                    cmpa      #TfBehind           behind the eye: kept for the cull (it may reach in front)
                    lbne      co9@
co0@                ldx       ,s                  culled before any more work: wholly behind the eye (z + R < 0), or
                    ldd       TfT3+8              wholly outside the view's sides (|x| - z > 1.414 R: the view is +-45
                    addd      ClRad,x             deg, FX = CX); T's high words are in 4 m
                    lbmi      co9@
                    ldd       ClRad,x
                    ldx       #Sqrt2Less1         0.414 R
                    lbsr      MqXY
                    ldx       ,s
                    addd      ClRad,x
                    std       ClT
                    ldd       TfT3
                    bpl       co0a@
                    lbsr      TfNegD
co0a@               subd      TfT3+8
                    cmpd      ClT
                    lbgt      co9@
                    ldx       ,s                  A, made at its creation: cos k, sin k, k, -sin k, cos k
                    ldd       ClAc,x
                    std       ClA
                    std       ClA+8
                    ldd       ClAk,x
                    std       ClA+4
                    ldd       ClAs,x
                    std       ClA+2
                    lbsr      TfNegD
                    std       ClA+6
                    tst       ClShd               the shadow: A's y column 0, every corner flat on the ground
                    beq       co1@
                    clr       ClA+4
                    clr       ClA+5
co1@                ldu       #BdC                M[r][c] = sum over k of C'[k][r] A[k][c]: C'[k][r] at BdC + 6k + 2r
                    ldy       #TfM
co2@                ldd       ,u                  M[r][0] = C'[0][r] cos k + C'[2][r] (-sin k)
                    ldx       ClA
                    lbsr      MqXY
                    std       ClT
                    ldd       12,u
                    ldx       ClA+6
                    lbsr      MqXY
                    addd      ClT
                    std       ,y
                    ldd       6,u                 M[r][1] = C'[1][r] k
                    ldx       ClA+4
                    lbsr      MqXY
                    std       2,y
                    ldd       ,u                  M[r][2] = C'[0][r] sin k + C'[2][r] cos k
                    ldx       ClA+2
                    lbsr      MqXY
                    std       ClT
                    ldd       12,u
                    ldx       ClA+8
                    lbsr      MqXY
                    addd      ClT
                    std       4,y
                    leau      2,u
                    leay      6,y
                    cmpy      #TfMEnd
                    blo       co2@
                    ldx       ,s
                    lda       ClScl,x             its scale
                    sta       TfScale
                    lda       ClShp,x             MESH: the shape's faces, their count, its corners, the color
                    ldb       #ClEnt
                    mul
                    addd      #GpCF
                    std       ClMsh
                    addd      #ClNf
                    std       ClMsh+4
                    ldd       #ClNf
                    std       ClMsh+2
                    lda       ClCol,x
                    sta       ClMsh+6
                    tst       ClShd               the shadow: ShMake's fan over the shape's rim, its own material
                    beq       co8@
                    ldd       #ShFace
                    std       ClMsh
                    ldd       #ShNf
                    std       ClMsh+2
                    clr       ClMsh+6
co8@                ldx       #TfM                SETMAT, MESH (GpUnits: into fsx's GpQ)
                    lda       #GpuOpSetMat
                    ldb       #SetMatUnits
                    lbsr      GpUnits
                    ldx       #ClMsh
                    lda       #GpuOpMesh
                    ldb       #MeshUnits
                    lbsr      GpUnits
co9@                puls      x,pc

* GdRun (ClBase+6: fst's GdDraw, FsxGround, from fsw's GdCall once the sky and ground split went to the GPU; this
* block at $4000, the K2 fsx at FsxBase): the ground textured near the eye by daylight, in the forward and spot views
* (not the map view): 5 x 5 tiles of 2,048 m on FS's tile grid (the map square >> 3), so the pattern keeps to the
* ground; each tile ac2gpu.py's ground quad (ground.py: GpGF, its texture once across it, scale 4: 1/4 m units),
* farmland (commented out 2026-10-24: none drawn), or meadow within one tile of an airport (GdAir, gd_air.asm; commented
* out 2026-10-24 too: GdRun skips the tiles); then the clouds' shadows (ShOne), all GROUND TEXTURE 1 draws now. F_TEXTURED alone, no depth test or write: the
* scenery's ground draws over it in list order, the 3D objects test against the cleared depth. M = C'^T (fst's BdMat)
* with the eye and the view matrix the scenery has this frame (vPosX, vViewM: the spot eye's in a spot frame), T for
* the block's first tile from TfTrans, then each tile's by adding C' rows x 2^10 (a tile is 2^17 1/64 m and
* T = (d C') >> 7: exact). The meshes' projection (BdProj) first, GpFlush last. Registers clobbered.
GdRun               tst       GpOn
                    lbeq      gd9@
                    tst       >vMapView
                    lbne      gd9@
                    lda       >vLight
                    cmpa      #LightDay
                    lbne      gd9@
                    ldx       #vPosX
                    stx       TfEye
                    ldu       #vViewM
                    lbsr      BdMat
                    lda       #GdScale            scale 4: 1/4 m units
                    sta       TfScale
                    ldx       #BdProj             the meshes' projection (480 lines: ProjU doubles FY and CY)
                    lbsr      ProjU
* the meadow commented out too (Roger 2026-10-24: GROUND TEXTURE 1 is the clouds' shadows alone): no tiles
                    lbra      gdsh@
                    ldd       >vPosX              the block: the eye's tile - 2, each way
                    lbsr      GdTile
                    std       GdTx
                    ldd       >vPosZ
                    lbsr      GdTile
                    std       GdTz
                    cmpd      GdTzL               moved to another block: each tile's texture again
                    bne       gd1@
                    ldd       GdTx
                    cmpd      GdTxL
                    beq       gd2@
gd1@                lbsr      GdTexs
gd2@                ldd       GdTx                the first tile's corner: X, Z its map square (the tile x 8), Y 0
                    lbsr      GdSq
                    std       BdPos
                    ldd       GdTz
                    lbsr      GdSq
                    std       BdPos+8
                    clra
                    clrb
                    std       BdPos+2
                    std       BdPos+4
                    std       BdPos+6
                    std       BdPos+10
                    ldx       #BdPos
                    lbsr      TfTrans
                    bcc       gd3@
                    cmpa      #TfBehind           behind the eye: drawn all the same (the clip plane cuts it)
                    lbne      gd9@
gd3@                ldx       #TfT3               its T, and a tile's step east (C' row x) and north (row z)
                    ldu       #GdRow
                    lbsr      Cp12
                    ldd       BdC
                    ldu       #GdSx
                    lbsr      GdSh10
                    ldd       BdC+2
                    ldu       #GdSxY
                    lbsr      GdSh10
                    ldd       BdC+4
                    ldu       #GdSxZ
                    lbsr      GdSh10
                    ldd       BdC+12
                    ldu       #GdSz
                    lbsr      GdSh10
                    ldd       BdC+14
                    ldu       #GdSzY
                    lbsr      GdSh10
                    ldd       BdC+16
                    ldu       #GdSzZ
                    lbsr      GdSh10
                    ldy       #GdTex
                    clr       GdJ
gd4@                ldx       #GdRow              a row of tiles, north
                    ldu       #GdCur
                    lbsr      Cp12
                    clr       GdI
gd5@                ldx       #GdCur              a tile, east: SETMAT with its T, MESH its texture's faces
                    ldu       #TfT3
                    lbsr      Cp12
                    ldb       ,y+
* farmland commented out (Roger 2026-10-24: ground.py no longer loads its texture): a farmland tile (0) draws
* nothing, only the meadow's (2) near the airports
                    beq       gd5a@
                    clra
                    addd      #GpGF
                    std       GdMsh
                    pshs      y
                    ldx       #TfM
                    lda       #GpuOpSetMat
                    ldb       #SetMatUnits
                    lbsr      GpUnits
                    ldx       #GdMsh
                    lda       #GpuOpMesh
                    ldb       #MeshUnits
                    lbsr      GpUnits
                    puls      y
gd5a@               ldx       #GdCur
                    ldu       #GdSx
                    lbsr      GdAdd
                    inc       GdI
                    lda       GdI
                    cmpa      #GdTiles
                    blo       gd5@
                    ldx       #GdRow
                    ldu       #GdSz
                    lbsr      GdAdd
                    inc       GdJ
                    lda       GdJ
                    cmpa      #GdTiles
                    blo       gd4@
gdsh@               lda       >vClouds+1          the clouds' shadows, while the clouds are on and made
                    bita      #CloudsOn
                    beq       gd8@
                    tst       ClOk
                    beq       gd8@
                    lbsr      ShSun
                    ldx       #ClTab
gd6@                tst       ClShp,x             a slot in use (shape 0-7; $FF free)
                    bmi       gd7@
                    pshs      x
                    lbsr      ShOne
                    puls      x
gd7@                leax      ClRec,x
                    cmpx      #ClTab+ClMax*ClRec
                    blo       gd6@
gd8@                lbra      GpFlush
gd9@                rts
* GdTile: D = a map square -> its tile - 2 (the map square >> 3). GdSq: D = a tile -> its map square (x 8).
GdTile              asra
                    rorb
                    asra
                    rorb
                    asra
                    rorb
                    subd      #GdTileBack
                    rts
GdSq                aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    rts
* GdSh10: the 32-bit value at U = D (Q15, sign-extended) x 2^10. GdAdd: the three 32-bit values at X += those at U.
GdSh10              std       1,u
                    clr       ,u
                    tsta
                    bpl       gs1@
                    com       ,u
gs1@                clr       3,u
                    bsr       gs2@
gs2@                asl       3,u
                    rol       2,u
                    rol       1,u
                    rol       ,u
                    rts
GdAdd               lbsr      Add32
                    leax      4,x
                    leau      4,u
                    lbsr      Add32
                    leax      4,x
                    leau      4,u
                    lbra      Add32
* GdTexs (GdRun, the block moved): GdTex = each tile's faces past GpGF, row by row from the block's first: 2 (meadow)
* when an airport's tile (GdAir) lies within one tile of it each way, else 0 (farmland).
GdTexs              ldd       GdTx
                    std       GdTxL
                    ldd       GdTz
                    std       GdTzL
                    ldy       #GdTex
                    clr       GdJ
gx1@                clr       GdI
gx2@                clra
                    ldb       GdI
                    addd      GdTx
                    std       GdQx
                    clra
                    ldb       GdJ
                    addd      GdTz
                    std       GdQz
                    ldx       #GdAir
gx3@                ldd       ,x++
                    cmpd      #GdAirEnd
                    beq       gx6@
                    subd      GdQx                |dx| <= 1: dx + 1 is 0-2
                    addd      #GdAirReach
                    cmpd      #GdAirSpan
                    bhi       gx4@
                    ldd       ,x
                    subd      GdQz
                    addd      #GdAirReach
                    cmpd      #GdAirSpan
                    bhi       gx4@
                    lda       #GdMeadow
                    bra       gx7@
gx4@                leax      2,x
                    bra       gx3@
gx6@                clra
gx7@                sta       ,y+
                    inc       GdI
                    lda       GdI
                    cmpa      #GdTiles
                    blo       gx2@
                    inc       GdJ
                    lda       GdJ
                    cmpa      #GdTiles
                    blo       gx1@
                    rts
GdTx                fdb       0                   the block's first tile (east, north)
GdTz                fdb       0
GdTxL               fdb       $8000               GdTex's block ($8000: none yet)
GdTzL               fdb       $8000
GdQx                fdb       0                   a tile
GdQz                fdb       0
GdI                 fcb       0
GdJ                 fcb       0
GdTex               zmb       25                  each tile's faces past GpGF (0 farmland, 2 meadow)
GdSx                zmb       12                  T's step a tile east, north (three 32-bit values)
GdSz                zmb       12
GdRow               zmb       12                  T at a row's first tile; at the tile
GdCur               zmb       12
GdMsh               fdb       GpGF,2,GpGV         MESH: the first face, 2 faces, the corners, no material override
                    fcb       0
                    use       gd_air.asm

* ShOne (GdRun, GROUND TEXTURE 1): the shadow of the cloud in the slot at X: its base carried along the sun's rays
* to the ground (ShFx, ShFz x its altitude), drawn when that lands within ShNear map units of the eye each way: ClGo
* with ClShd 1 (A's y column 0: the shape flat on the ground; MESH ShMake's fan over its rim). Registers clobbered.
ShOne               pshs      x
                    ldd       ClAlt,x
                    ldx       ShFx
                    lbsr      MqXY                the offset east / 16 (m)
                    std       ShDx
                    ldx       ,s
                    ldd       ClAlt,x
                    ldx       ShFz
                    lbsr      MqXY
                    std       ShDz
                    ldx       ,s
                    ldd       ShDx                where it lands, in map units from the eye: within ShNear each way
                    lbsr      ClQ16
                    addd      ClX,x
                    subd      >vPosX
                    addd      #ShNear
                    cmpd      #ShSpan
                    bhi       sh9@
                    ldd       ShDz
                    lbsr      ClQ16
                    addd      ClZ,x
                    subd      >vPosZ
                    addd      #ShNear
                    cmpd      #ShSpan
                    bhi       sh9@
                    ldu       #ClPos              X, Z: the cloud's plus the offset (x 4096: 1/256 m), Y 0
                    ldd       ShDx
                    bsr       ShSh12
                    ldu       #ClPosZ
                    ldd       ShDz
                    bsr       ShSh12
                    clra
                    clrb
                    std       ClPos+4
                    std       ClPos+6
                    ldx       #ClPos
                    ldu       ,s
                    leau      ClX,u
                    lbsr      Add32
                    leax      8,x
                    leau      ClZ-ClX,u
                    lbsr      Add32
                    lda       #ClShdOn
                    sta       ClShd
                    lbra      ClGo
sh9@                puls      x,pc
* ShSh12: the 32-bit value at U = D (sign-extended) x 4096.
ShSh12              std       1,u
                    clr       ,u
                    tsta
                    bpl       ss1@
                    com       ,u
ss1@                clr       3,u
                    bsr       ss2@
                    bsr       ss2@
                    bsr       ss2@
ss2@                asl       3,u
                    rol       2,u
                    rol       1,u
                    rol       ,u
                    rts
* ShSun (GdRun): ShFx, ShFz = a shadow's offset east, north per m of height (Q11) for FS's clock and season (ShTab,
* sun_tab.py: whole hours; the minutes between two of them interpolated). Registers clobbered.
ShSun               ldb       >vMinute            the minutes x 546
                    lda       #ShMinThird
                    mul
                    std       ShMin
                    addd      ShMin
                    addd      ShMin
                    std       ShMin
                    lda       >vSeason            1-4: its 25 hours, two bytes each
                    deca
                    anda      #SeasonMask
                    ldb       #ShSeasonSize
                    mul
                    addd      #ShTab
                    tfr       d,x
                    ldb       >vHour
                    cmpb      #LastHour
                    bls       sn1@
                    ldb       #LastHour
sn1@                lslb
                    abx
                    ldy       #ShFx
                    bsr       ShI
                    leax      1,x
                    leay      2,y
* ShI: ,Y = the byte at X (this hour) and at 2,X (the next) as Q11 (x 128), the minutes between them interpolated.
* X and Y kept.
ShI                 lda       2,x
                    clrb
                    asra
                    rorb
                    std       ShT                 the next hour's
                    lda       ,x
                    clrb
                    asra
                    rorb
                    std       ,y                  this hour's
                    pshs      x
                    ldd       ShT
                    subd      ,y
                    ldx       ShMin
                    lbsr      MqXY
                    addd      ,y
                    std       ,y
                    puls      x,pc
* ShMake (ClInit, after the shapes): the shadow's ShNf faces at ShFace: a fan over the rim's seven corners (0, k,
* k + 1), dark green (ShMat) screen-doored (ShFlags), the normal up. Registers clobbered.
ShMake              ldd       #ShFace
                    lbsr      ClUpA
                    lda       #ShFanFirst
                    sta       ClJ
sm1@                clra                          corners 0, k, k + 1 (words)
                    lbsr      ClPut
                    lbsr      ClPut
                    lbsr      ClPut
                    lda       ClJ
                    lbsr      ClPut
                    clra
                    lbsr      ClPut
                    lda       ClJ
                    inca
                    lbsr      ClPut
                    lda       #ShMat
                    lbsr      ClPut
                    clra                          no texture
                    lbsr      ClPut
                    lda       #ShFlags
                    lbsr      ClPut
                    clra
                    lbsr      ClPut
                    lbsr      ClPut               the normal: 0, 1, 0 (Q15)
                    lbsr      ClPut
                    lda       #Q15OneHi
                    lbsr      ClPut
                    lda       #Q15OneLo
                    lbsr      ClPut
                    clra
                    lbsr      ClPut
                    lbsr      ClPut
                    inc       ClJ
                    lda       ClJ
                    cmpa      #ShFanEnd
                    blo       sm1@
                    lbra      ClUpF
                    use       sh_sun.asm

ClUpR               fdb       Gpu.UpDat           GpuF.LPkN's request: UP_DATA (mask 0), then ClUpB
                    fcb       0,0
ClUpB               rmb       ClUpN               the shapes' entries on their way up (ClPut, ClUpF)
ClVt                rmb       30*12               a shape's corners (ClVtx): x, y, z, the normal (its faces' sum, ClFace)
ClTab               rmb       ClMax*ClRec         the slots
ClEnd               equ       *
                    ifgt      ClEnd-ClBase-ClMaxB
                    error     "fscl: past its block"
                    endc

                    end
