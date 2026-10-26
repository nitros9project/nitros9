********************************************************************
* fsx_ac.asm - the model renderer shared by fsx (the spot view: the Archer) and fst (traffic: the Learjet): the
* matrix and eye for a model (MdlDraw), the 32-bit and Q15 helpers, the aircraft-file reader and renderer (AcLoad,
* AcDraw). The including file defines MdlM (the view matrix MdlDraw puts back), AcName (the model file) and
* AcFile (the block after its code).

GpOn                fcb       0                   1: the model is rc26's GPU's (the including file's GpDraw draws it)
XR                  zmb       18                  R, row by row (the world's x, y, z)
XS                  fdb       0
XK                  fcb       0
XJ                  fcb       0
XI                  fcb       0

* MdlDraw: the model drawn with R (XR, row by row: the world's axes, the model's columns) and the eye from the
* model in MdlW (model units, world axes): C = R' x MdlM to <$68, the eye R' x MdlW to <$0C, AcDraw,
* then MdlM back to <$68 and the point pipeline. Registers clobbered.
MdlDraw             clr       XK                  C: <$68 + 6k + 2j = sum over i of R(i,k) x MdlM(i,j)
dr3@                clr       XJ
dr4@                ldd       #SumInit
                    std       XS
                    ldx       #XR
                    ldb       XK
                    abx
                    ldu       #MdlM
                    ldb       XJ
                    leau      b,u
                    lda       #AxisCount
                    sta       XI
dr5@                ldd       ,x
                    std       <vMulA
                    ldd       ,u
                    std       <vMulB
                    jsr       >FswMq
                    addd      XS
                    std       XS
                    leax      6,x
                    leau      6,u
                    dec       XI
                    bne       dr5@
                    ldb       XK
                    lda       #MatRowWords
                    mul
                    addb      XJ
                    ldx       #vViewM
                    abx
                    ldd       XS
                    std       ,x
                    ldb       XJ
                    addb      #MatIdxStep
                    stb       XJ
                    cmpb      #MatIdxEnd
                    blo       dr4@
                    ldb       XK
                    addb      #MatIdxStep
                    stb       XK
                    cmpb      #MatIdxEnd
                    blo       dr3@
                    clr       XK                  the eye: <$0C + 2k = sum over i of MdlW(i) x R(i,k)
dr6@                ldd       #SumInit
                    std       XS
                    ldx       #XR
                    ldb       XK
                    abx
                    ldu       #MdlW
                    lda       #AxisCount
                    sta       XI
dr7@                ldd       ,u
                    std       <vMulA
                    ldd       ,x
                    std       <vMulB
                    jsr       >FswMq
                    addd      XS
                    std       XS
                    leax      6,x
                    leau      2,u
                    dec       XI
                    bne       dr7@
                    ldx       #vEyeX
                    ldb       XK
                    abx
                    ldd       XS
                    std       ,x
                    ldb       XK
                    addb      #MatIdxStep
                    stb       XK
                    cmpb      #MatIdxEnd
                    blo       dr6@
                    jsr       >FswMatLoad         C to the point pipeline
                    tst       GpOn                rc26's GPU holds the model: C and the eye to it (GpDraw)
                    beq       dr7a@
                    lbsr      GpDraw
                    ifdef     WBTRAF
* the K2: no software renderer (no ac.gpu: no model)
dr7a@               equ       *
                    else
                    bra       dr7b@
dr7a@               lbsr      AcDraw
                    endc
dr7b@               ldx       #MdlM                the spot view's matrix back
                    ldu       #vViewM
dr8@                ldd       ,x++
                    std       ,u++
                    cmpu      #vViewMEnd
                    blo       dr8@
                    jmp       >FswMatLoad

* MqXY: D * X (Q15). MqY: D * X * $3E2F.
MqY                 bsr       MqXY
                    ldx       #YAspect
MqXY                std       <vMulA
                    stx       <vMulB
                    jmp       >FswMq
* Neg4: -D / 4. Q4: D / 4 (as BuildViewMatrix: arithmetic shifts).
Neg4                coma
                    comb
                    addd      #NegCarry
Q4                  asra
                    rorb
                    asra
                    rorb
                    rts

* Fits2: carry clear when the 32-bit value at X lies in -$2000..$1FFF. X past it.
Fits2               ldd       ,x
                    beq       ft1@
                    cmpd      #Fits2NegHi
                    bne       ft8@
                    ldd       2,x
                    cmpd      #Atan2Min
                    bhs       ft9@
                    bra       ft8@
ft1@                ldd       2,x
                    cmpd      #Atan2Max
                    blo       ft9@
ft8@                leax      4,x
                    orcc      #Carry
                    rts
ft9@                leax      4,x
                    andcc     #^Carry
                    rts

* 32-bit helpers: Add32 ,x += ,u; Sub32 ,x -= ,u; Mv4 4 bytes X to U; AddW ,u = ,x + D (sign-extended);
* Cp12 / CpB: 12 / B bytes from X to U. Registers kept but D (CpB: X and U past).
Add32               ldd       2,x
                    addd      2,u
                    std       2,x
                    ldd       ,x
                    adcb      1,u
                    adca      ,u
                    std       ,x
                    rts
Sub32               ldd       2,x
                    subd      2,u
                    std       2,x
                    ldd       ,x
                    sbcb      1,u
                    sbca      ,u
                    std       ,x
                    rts
Mv4                 ldd       ,x
                    std       ,u
                    ldd       2,x
                    std       2,u
                    rts
AddW                pshs      d
                    addd      2,x
                    std       2,u
                    ldd       ,x
                    adcb      #CarryOnly
                    adca      #CarryOnly
                    tst       ,s
                    bpl       aw1@
                    subd      #SignExtNeg
aw1@                std       ,u
                    puls      d,pc
Cp12                ldb       #Pos32Size
CpB                 lda       ,x+
                    sta       ,u+
                    decb
                    bne       CpB
                    rts

* The K2's fsx (WBTRAF) draws the aircraft by the GPU only: the software renderer below is the Jr2's (its room
* holds the K2's clouds, 2026-10-23). GpDraw keeps the prop's angle.
                    ifdef     WBTRAF
AcRnd               fdb       0                   the prop's angle: on by the RPM gauge value x 256 a frame
                    else

********************************************************************
* The aircraft (wildbits-buildkit/notes/fs2-aircraft-files.md): fs2/ac.archer read to AcFile (the block after this
* code) on the first spot frame, its model drawn by AcDraw through FS's own point transform and polygon fill: the
* faces the eye sees (n . eye > 4 d in model coordinates), their points through FS's $31 into the cache, the faces
* into NB depth buckets by their first three points' camera z, then far to near, each as $25 (its color) $2F $32
* $33 .. $29. After the file: the cache (nv + nvm of FS's 8-byte slot records), the bucket heads, a link word per
* drawn face, a mark bit per cache entry.
NB                  equ       32                  depth buckets
AcOk                fcb       0                   0: not read yet, 1: there, $FF: none
AcSc                fdb       0                   the model's scale: points and face planes >> AcSc (the caller's eye too)
AcNv                fcb       0                   stored vertices
AcNvm               fcb       0                   the mirrored set's
AcNf                fcb       0                   stored faces
AcNfm               fcb       0                   the mirrored ones
AcPf                fcb       0                   the first prop vertex
AcHy                fdb       0                   the prop hub's y
AcV                 fdb       0                   the vertices
AcF                 fdb       0                   the faces
AcCache             fdb       0
AcHead              fdb       0
AcNext              fdb       0
AcMark              fdb       0
AcNc                fdb       0                   cache entries
AcNd                fdb       0                   drawn faces
AcMb                fdb       0                   mark bytes
AcRnd               fdb       0                   the prop's angle: on by the RPM gauge value x 256 a frame
AcSin               fdb       0
AcCos               fdb       $7FFF
AcJ                 fdb       0                   a drawn face (or a cache entry)
AcMir               fcb       0                   it is a mirrored face
AcMp                fcb       0                   a mirrored point
AcN                 fcb       0                   its vertex count
AcCol               fcb       0                   its color
AcB                 fcb       0                   a bucket
AcMin               fdb       0
AcMax               fdb       0
AcSh                fcb       0
AcS                 rmb       3                   a 24-bit sum
AcP                 rmb       3                   a product
AcE                 fdb       0
AcM                 fcb       0
AcNeg               fcb       0
AcPt                rmb       6                   a point
AcList              rmb       16                  the list FS runs

* AcLoad: fs2/ac.archer to AcFile, its header checked, the work areas laid out after it: AcOk 1, else $FF.
AcLoad              lda       #AcNone
                    sta       AcOk
                    lda       #READ.
                    ldx       #AcName
                    swi2
                    fcb       I$Open
                    lbcs      al9@
                    ldx       #AcFile
                    ldy       #FsxBase+FsxMax-AcFile
                    pshs      a
                    swi2
                    fcb       I$Read
                    puls      a
                    pshs      cc,y                the read's result
                    swi2
                    fcb       I$Close
                    puls      cc,y
                    lbcs      al9@
                    ldd       AcFile              'AC', version 1
                    cmpd      #AcMagic
                    lbne      al9@
                    lda       AcFile+2
                    cmpa      #AcVersion
                    lbne      al9@
                    tfr       y,d                 the cache after the file, at an even address
                    addd      #AcFileRound
                    andb      #EvenMask
                    std       AcCache
                    ldx       #AcFile
                    ldd       19,x                the model
                    leax      d,x
                    ldd       ,x
                    std       AcNv                nv, nvm
                    ldd       2,x
                    std       AcNf                nf, nfm
                    lda       4,x
                    sta       AcPf
                    ldd       5,x
                    std       AcHy
                    leax      9,x
                    stx       AcV
                    lda       AcNv
                    ldb       #AcVtxBytes
                    mul
                    leax      d,x
                    stx       AcF
                    lda       AcNf                the faces within the file
                    ldb       #AcFaceBytes
                    mul
                    addd      AcF
                    cmpd      AcCache
                    bhi       al9@
                    ldb       AcNv                cache entries: nv + nvm
                    clra
                    addb      AcNvm
                    adca      #CarryOnly
                    std       AcNc
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    addd      AcCache
                    std       AcHead
                    addd      #AcHeadBytes
                    std       AcNext
                    ldb       AcNf                drawn faces: nf + nfm
                    clra
                    addb      AcNfm
                    adca      #CarryOnly
                    std       AcNd
                    lslb
                    rola
                    addd      AcNext
                    std       AcMark
                    ldd       AcNc
                    addd      #MarkByteRound
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    std       AcMb
                    addd      AcMark
                    cmpd      #FsxBase+FsxMax
                    bhi       al9@
                    lda       #AcOkRead
                    sta       AcOk
al9@                rts

* AcDraw: the aircraft, with C loaded and the eye in model coordinates in <$0C/<$0E/<$10. Registers clobbered.
AcDraw              lda       AcOk
                    bne       ad0@
                    lbsr      AcLoad
                    lda       AcOk
ad0@                deca
                    lbne      ad9@
                    lda       >vRpm               FS's RPM gauge value (49 at full power, 13 at idle)
                    beq       ad1@                not turning: the prop stays
                    cmpa      #PropRpmMax         a windmilling dive goes higher: held under the two blades'
                    bls       ad0b@               90-degree limit, so the prop never looks to turn backwards
                    lda       #PropRpmMax
ad0b@               clrb                          the angle on by it x 256 a frame (69 degrees at full power)
                    addd      AcRnd
                    std       AcRnd
                    anda      #PropStepMask       drawn in 22.5-degree steps
                    clrb
                    jsr       >FsSin16
                    std       AcSin
                    ldd       AcRnd
                    anda      #PropStepMask
                    clrb
                    jsr       >FsCos16
                    std       AcCos
ad1@                ldx       AcMark              no point marked
                    ldy       AcMb
ad1a@               clr       ,x+
                    leay      -1,y
                    bne       ad1a@
* pass 1: the faces seen, their points marked; the others' links $8000
                    ldd       #AcFirst
                    std       AcJ
p1@                 lbsr      AcFace
                    lbsr      AcVis
                    bcc       p1n@
                    clrb
p1v@                pshs      b
                    lbsr      AcVtx
                    lbsr      AcBit
                    ora       ,x
                    sta       ,x
                    puls      b
                    incb
                    cmpb      AcN
                    blo       p1v@
                    ldd       #AcSeen
                    bra       p1s@
p1n@                ldd       #AcUnseen
p1s@                pshs      d
                    ldd       AcJ
                    lslb
                    rola
                    addd      AcNext
                    tfr       d,x
                    puls      d
                    std       ,x
                    ldd       AcJ
                    addd      #AcStep
                    std       AcJ
                    cmpd      AcNd
                    blo       p1@
* pass 2: the marked points through FS's $31 (slot 0) into the cache
                    ldd       #AcFirst
                    std       AcJ
p2@                 ldd       AcJ
                    lbsr      AcBit
                    anda      ,x
                    beq       p2n@
                    lbsr      AcPoint
                    ldx       #AcList
                    ldd       #DlPointSlot0
                    std       ,x
                    ldd       AcPt
                    std       2,x
                    ldd       AcPt+2
                    std       4,x
                    ldd       AcPt+4
                    std       6,x
                    lda       #DlOpReturn
                    sta       8,x
                    lbsr      AcRun
                    ldd       AcJ
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    addd      AcCache
                    tfr       d,u
                    ldx       #vPtSlots           slot 0
                    ldb       #PtSlotBytes
                    lbsr      CpB
p2n@                ldd       AcJ
                    addd      #AcStep
                    std       AcJ
                    cmpd      AcNc
                    blo       p2@
* pass 3: each seen face's depth key (its first three points' camera z / 4, summed) in its link
                    ldd       #Int16Max
                    std       AcMin
                    ldd       #Int16Min
                    std       AcMax
                    ldd       #AcFirst
                    std       AcJ
p3@                 ldd       AcJ
                    lslb
                    rola
                    addd      AcNext
                    tfr       d,x
                    ldd       ,x
                    cmpd      #AcUnseen
                    beq       p3n@
                    pshs      x
                    lbsr      AcFace
                    ldd       #SumInit
                    std       AcP
                    clrb
p3v@                pshs      b
                    lbsr      AcVtx
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    addd      AcCache
                    tfr       d,x
                    ldd       4,x                 camera z
                    asra
                    rorb
                    asra
                    rorb
                    addd      AcP
                    std       AcP
                    puls      b
                    incb
                    cmpb      #AcKeyPoints
                    blo       p3v@
                    puls      x
                    ldd       AcP
                    std       ,x
                    cmpd      AcMin
                    bge       p3a@
                    std       AcMin
p3a@                cmpd      AcMax
                    ble       p3n@
                    std       AcMax
p3n@                ldd       AcJ
                    addd      #AcStep
                    std       AcJ
                    cmpd      AcNd
                    blo       p3@
* pass 4: the seen faces into NB buckets over min .. max
                    ldd       AcMax
                    cmpd      AcMin
                    lblt      ad9@                no face seen
                    subd      AcMin
                    clr       AcSh
p4s@                cmpd      #NB
                    blo       p4h@
                    lsra
                    rorb
                    inc       AcSh
                    bra       p4s@
p4h@                ldx       AcHead              every bucket empty ($FFFF)
                    ldb       #AcHeadBytes
                    lda       #AcNilByte
p4c@                sta       ,x+
                    decb
                    bne       p4c@
                    ldd       #AcFirst
                    std       AcJ
p4@                 ldd       AcJ
                    lslb
                    rola
                    addd      AcNext
                    tfr       d,u
                    ldd       ,u
                    cmpd      #AcUnseen
                    beq       p4n@
                    subd      AcMin
                    pshs      b
                    ldb       AcSh
                    stb       AcM
                    puls      b
p4r@                tst       AcM
                    beq       p4b@
                    lsra
                    rorb
                    dec       AcM
                    bra       p4r@
p4b@                lslb                          the bucket's head
                    ldx       AcHead
                    abx
                    ldd       ,x
                    std       ,u
                    ldd       AcJ
                    std       ,x
p4n@                ldd       AcJ
                    addd      #AcStep
                    std       AcJ
                    cmpd      AcNd
                    blo       p4@
* pass 5: far to near
                    lda       #AcLastBucket
                    sta       AcB
p5@                 ldb       AcB
                    lslb
                    ldx       AcHead
                    abx
                    ldd       ,x
p5j@                cmpd      #AcNil
                    beq       p5n@
                    std       AcJ
                    lbsr      AcPoly
                    ldd       AcJ
                    lslb
                    rola
                    addd      AcNext
                    tfr       d,x
                    ldd       ,x
                    bra       p5j@
p5n@                dec       AcB
                    bpl       p5@
ad9@                rts

* AcFace: drawn face AcJ: U = its record, AcMir, AcN (3 or 4), AcCol. The first 2 nfm drawn faces are the
* mirrored pairs (even: as stored, odd: mirrored), then the others. X kept.
AcFace              clr       AcMir
                    ldb       AcNfm
                    clra
                    lslb
                    rola
                    cmpd      AcJ
                    bhi       af1@
                    ldd       AcJ                 past the pairs: K = J - nfm
                    subb      AcNfm
                    sbca      #CarryOnly
                    bra       af2@
af1@                ldd       AcJ                 a pair: K = J / 2
                    lsra
                    rorb
                    bcc       af2@
                    inc       AcMir
af2@                lda       #AcFaceBytes
                    mul
                    addd      AcF
                    tfr       d,u
                    lda       ,u
                    tfr       a,b
                    andb      #AcColorBits
                    stb       AcCol
                    lsra
                    lsra
                    lsra
                    lsra
                    adda      #AcMinCorners
                    sta       AcN
                    rts

* AcVtx: B = a vertex of face U (0 .. n - 1): D = its cache entry. A mirrored face's vertices go in the other
* order, each the mirror of its stored one (nv + i for i in the mirrored set). U, X kept.
AcVtx               tst       AcMir
                    beq       av1@
                    negb
                    addb      AcN
                    decb
av1@                addb      #AcFaceVtxOff
                    ldb       b,u
                    clra
                    tst       AcMir
                    beq       av9@
                    cmpb      AcNvm
                    bhs       av9@
                    addb      AcNv
                    adca      #CarryOnly
av9@                rts

* AcVis: carry set when the eye sees face U (mirrored when AcMir): (n . eye) - 4 d > 0, 24 bits. U kept.
AcVis               clr       AcS
                    clr       AcS+1
                    clr       AcS+2
                    ldb       1,u
                    tst       AcMir
                    beq       vs1@
                    negb
vs1@                ldx       #vEyeX
                    bsr       AcMac
                    ldb       2,u
                    ldx       #vEyeY
                    bsr       AcMac
                    ldb       3,u
                    ldx       #vEyeZ
                    bsr       AcMac
                    clr       AcP                 4 d as 24 bits (d >> AcSc)
                    ldd       4,u
                    ldx       AcSc
                    beq       vs1b@
vs1a@               asra
                    rorb
                    leax      -1,x
                    bne       vs1a@
vs1b@               tsta
                    bpl       vs2@
                    com       AcP
vs2@                lslb
                    rola
                    rol       AcP
                    lslb
                    rola
                    rol       AcP
                    std       AcP+1
                    ldd       AcS+1
                    subd      AcP+1
                    std       AcS+1
                    lda       AcS
                    sbca      AcP
                    sta       AcS
                    bmi       vs8@
                    ora       AcS+1
                    ora       AcS+2
                    beq       vs8@
                    orcc      #Carry
                    rts
vs8@                andcc     #^Carry
                    rts

* AcMac: AcS += B (signed byte) x the signed word at X, 24 bits. U, X kept.
AcMac               clr       AcNeg
                    tstb
                    bpl       am1@
                    negb
                    com       AcNeg
am1@                stb       AcM
                    ldd       ,x
                    bpl       am2@
                    coma
                    comb
                    addd      #NegCarry
                    com       AcNeg
am2@                std       AcE
                    lda       AcE+1
                    ldb       AcM
                    mul
                    std       AcP+1
                    lda       AcE
                    ldb       AcM
                    mul
                    addb      AcP+1
                    adca      #CarryOnly
                    std       AcP
                    tst       AcNeg
                    beq       am3@
                    com       AcP
                    com       AcP+1
                    com       AcP+2
                    inc       AcP+2
                    bne       am3@
                    inc       AcP+1
                    bne       am3@
                    inc       AcP
am3@                ldd       AcS+1
                    addd      AcP+1
                    std       AcS+1
                    lda       AcS
                    adca      AcP
                    sta       AcS
                    rts

* AcBit: D = a cache entry: X = its mark byte, A = its bit. U kept.
AcBit               pshs      b
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    addd      AcMark
                    tfr       d,x
                    puls      b
                    andb      #MarkBitMask
                    lda       #MarkBit0
ab1@                decb
                    bmi       ab9@
                    lsla
                    bra       ab1@
ab9@                rts

* AcPoint: AcPt = the model point of cache entry AcJ: a stored vertex, a mirrored one (x -> -x), or a prop
* vertex turned by the prop's angle about the z axis through (0, hub y).
AcPoint             ldb       AcNv
                    clra
                    cmpd      AcJ
                    bhi       pt1@
                    ldd       AcJ                 a mirrored point: stored vertex J - nv
                    subb      AcNv
                    lda       #AcMpMirror
                    bra       pt2@
pt1@                ldb       AcJ+1
                    clra
pt2@                sta       AcMp
                    pshs      b
                    lda       #AcVtxBytes
                    mul
                    addd      AcV
                    tfr       d,x
                    ldd       ,x
                    std       AcPt
                    ldd       2,x
                    std       AcPt+2
                    ldd       4,x
                    std       AcPt+4
                    puls      b
                    tst       AcMp
                    beq       pt3@
                    ldd       AcPt
                    coma
                    comb
                    addd      #NegCarry
                    std       AcPt
                    bra       pt9@
pt3@                cmpb      AcPf
                    blo       pt9@
                    ldd       AcPt+2              x' = x cos - (y - hy) sin, y' = hy + x sin + (y - hy) cos
                    subd      AcHy
                    std       AcE
                    ldd       AcPt
                    ldx       AcCos
                    lbsr      MqXY
                    std       AcP
                    ldd       AcE
                    ldx       AcSin
                    lbsr      MqXY
                    pshs      d
                    ldd       AcP
                    subd      ,s++
                    pshs      d
                    ldd       AcPt
                    ldx       AcSin
                    lbsr      MqXY
                    std       AcP
                    ldd       AcE
                    ldx       AcCos
                    lbsr      MqXY
                    addd      AcP
                    addd      AcHy
                    std       AcPt+2
                    puls      d
                    std       AcPt
pt9@                ldx       AcSc                the model's scale
                    beq       pt9b@
pt9a@               asr       AcPt
                    ror       AcPt+1
                    asr       AcPt+2
                    ror       AcPt+3
                    asr       AcPt+4
                    ror       AcPt+5
                    leax      -1,x
                    bne       pt9a@
pt9b@               rts

* AcPoly: drawn face AcJ: its points' cache records into slots 0 .. n - 1, then $25 color $0178, $2F, $32 0,
* $33 1 .. $33 n - 1, $29.
AcPoly              lbsr      AcFace
                    clrb
ap1@                pshs      b
                    lbsr      AcVtx
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    addd      AcCache
                    tfr       d,x
                    ldb       ,s                  slot i at $08B3 + 8 i
                    lda       #PtSlotBytes
                    mul
                    addd      #vPtSlots
                    pshs      u
                    tfr       d,u
                    ldb       #PtSlotBytes
                    lbsr      CpB
                    puls      u
                    puls      b
                    incb
                    cmpb      AcN
                    blo       ap1@
                    ldx       #AcList
                    lda       #DlOpStoreW
                    sta       ,x+
                    lda       AcCol
                    ldb       #BothNibbles
                    mul
                    stb       ,x+                 the color in all four nibbles
                    stb       ,x+
                    ldd       #vFillPat
                    std       ,x++
                    ldd       #DlPolyBegin
                    std       ,x++
                    clr       ,x+
                    ldb       #AcSlotSecond
ap2@                lda       #DlOpPolyTo
                    sta       ,x+
                    stb       ,x+
                    incb
                    cmpb      AcN
                    blo       ap2@
                    ldd       #DlFillReturn
                    std       ,x
* AcRun: FS runs AcList (as RunDisplayListAt, without its timer ticks). Registers clobbered.
AcRun               clr       >vEnd1Cut
                    clr       <vEnd2Cut
                    ldu       #AcList
                    stu       <vDispListPtr
                    jmp       >FsDispList
                    endc

