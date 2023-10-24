* Disassembly by Os9disasm of cfloats.r

                    section   code

* class D external label equates

D0000               equ       $0000
D0010               equ       $0010
D0011               equ       $0011
D0012               equ       $0012
D0013               equ       $0013
D0014               equ       $0014
D0015               equ       $0015
D0016               equ       $0016
D0017               equ       $0017
D0018               equ       $0018
D0019               equ       $0019
D001c               equ       $001c
D001d               equ       $001d
D001e               equ       $001e
D0022               equ       $0022
D0023               equ       $0023
D0024               equ       $0024
D0025               equ       $0025
D0026               equ       $0026
D0027               equ       $0027
D0028               equ       $0028
D0029               equ       $0029
D002a               equ       $002a
D0081               equ       $0081

_dnorm              ldx       2,s
                    lbsr      _dstack
                    bsr       L0008
                    rts
L0008               pshs      u
                    leas      -30,s
                    tfr       s,u
                    clr       D001d,u
                    clr       D0019,u
                    lbsr      L028f
                    lbra      L00b4
_dneg               ldb       #7
                    clra
L001e               ora       b,x
                    decb
                    bpl       L001e
                    tsta
                    lbeq      _xtofla
                    ldd       ,x
                    eora      #$80
                    lbra      L064d
_dadd               lbsr      L04a7
                    lbsr      L0189
                    lbra      L00b4
_dsub               lbsr      L04a7
                    lbsr      L015f
                    lbra      L00b4
_dmul               lbsr      L04a7
                    lbsr      L0302
                    bra       L00b4
_ddiv               lbsr      L04a7
                    lbsr      L032e
                    bra       L00b4
_dtol               lbsr      _xtofla
                    lbra      L054b
_dtoi               bsr       _dtol
                    ldd       2,x
                    rts
_ltod               ldd       ,x
                    std       _flacc,y
                    ldd       2,x
                    leax      _flacc,y
                    std       2,x
                    lbra      L04eb
_itod               leax      _flacc,y
                    std       2,x
                    tfr       a,b
                    sex
                    tfr       a,b
                    std       ,x
                    lbra      L04eb
_utod               leax      _flacc,y
                    std       2,x
                    clr       ,x
                    clr       1,x
                    lbra      L04eb
_dtof               ldd       ,x
                    std       _flacc,y
                    lda       2,x
                    ldb       7,x
                    leax      _flacc,y
                    std       2,x
                    rts
_ftod               ldd       ,x
                    std       _flacc,y
                    ldd       2,x
                    leax      _flacc,y
                    sta       2,x
                    stb       7,x
                    clr       3,x
                    clr       4,x
                    clr       5,x
                    clr       6,x
                    rts
L00b4               leax      _flacc,y
                    ldd       D0022,u
                    std       ,x
                    ldd       D0024,u
                    std       2,x
                    ldd       D0026,u
                    std       4,x
                    ldd       D0028,u
                    std       6,x
                    leas      D001e,u
                    puls      u
                    puls      d
                    std       6,s
                    leas      6,s
                    rts
_dcmpr              lda       2,s
                    eora      ,x
                    bmi       L0147
                    lda       2,s
                    bmi       L011a
                    lda       9,s
                    beq       L0113
                    ldb       7,x
                    beq       L014b
                    cmpa      7,x
                    bne       L011e
                    ldd       2,s
                    cmpd      ,x
                    bne       L011e
                    ldd       4,s
                    cmpd      2,x
                    bne       L011e
                    ldd       6,s
                    cmpd      4,x
                    bne       L011e
                    lda       8,s
                    anda      #254
                    pshs      a
                    ldb       6,x
                    andb      #254
                    cmpa      ,s+
                    bne       L011e
                    bra       L014f
L0113               lda       7,x
                    bne       L015a
                    clra
                    bra       L014f
L011a               lda       7,x
                    cmpa      9,s
L011e               bhi       L014b
                    bcs       L015a
                    ldd       ,x
                    cmpd      2,s
                    bne       L011e
                    ldd       2,x
                    cmpd      4,s
                    bne       L011e
                    ldd       4,x
                    cmpd      6,s
                    bne       L011e
                    lda       6,x
                    anda      #254
                    pshs      a
                    lda       8,s
                    anda      #254
                    cmpa      ,s+
                    bne       L011e
                    bra       L014f
L0147               lda       ,x
                    bpl       L015a
L014b               lda       #1
                    andcc     #254
L014f               pshs      cc
                    ldd       1,s
                    std       9,s
                    puls      cc
                    leas      8,s
                    rts
L015a               clra
                    cmpa      #1
                    bra       L014f
L015f               lda       D0017,u
                    beq       L0180
                    ldb       D001c,u
                    eorb      #$80
                    stb       D001c,u
                    eorb      D0018,u
                    stb       D0019,u
                    ldb       D0029,u
                    bne       L0192
                    lbsr      L061b
                    lda       D0022,u
                    lbra      L02d2
L0180               lda       D0022,u
                    ldb       D0018,u
                    lbra      L02d5
L0189               lbeq      L061b
                    lda       D0017,u
                    beq       L0180
L0192               suba      D0029,u
                    beq       L01c3
                    sta       ,u
                    bcs       L01c9
                    ldb       D0017,u
                    stb       D0029,u
                    ldd       D0022,u
L01a4               lsra
                    rorb
                    ror       D0024,u
                    ror       D0025,u
                    ror       D0026,u
                    ror       D0027,u
                    ror       D0028,u
                    dec       ,u
                    bne       L01a4
                    std       D0022,u
L01bc               lda       D0019,u
                    bmi       L0238
                    bra       L01e9
L01c3               inc       ,u
                    orcc      #1
                    bra       L01bc
L01c9               ldd       D0010,u
L01cc               lsra
                    rorb
                    ror       D0012,u
                    ror       D0013,u
                    ror       D0014,u
                    ror       D0015,u
                    ror       D0016,u
                    inc       ,u
                    bne       L01cc
                    std       D0010,u
                    lda       D0019,u
                    bmi       L023b
L01e9               ldd       D0027,u
                    adcb      D0016,u
                    adca      D0015,u
                    std       D0027,u
                    ldd       D0025,u
                    adcb      D0014,u
                    adca      D0013,u
                    std       D0025,u
                    ldb       D0024,u
                    adcb      D0012,u
                    stb       D0024,u
                    ldd       D0022,u
                    adcb      D0011,u
                    adca      D0010,u
                    std       D0022,u
                    bcc       L0230
                    inc       D0029,u
                    ror       D0022,u
                    ror       D0023,u
                    ror       D0024,u
                    ror       D0025,u
                    ror       D0026,u
                    ror       D0027,u
                    ror       D0028,u
L0230               lda       D001c,u
                    sta       D0019,u
                    bra       L028f
L0238               rola
                    coma
                    asra
L023b               ldd       D0027,u
                    sbcb      D0016,u
                    sbca      D0015,u
                    std       D0027,u
                    ldd       D0025,u
                    sbcb      D0014,u
                    sbca      D0013,u
                    std       D0025,u
                    ldd       D0023,u
                    sbcb      D0012,u
                    sbca      D0011,u
                    std       D0023,u
                    lda       D0022,u
                    sbca      D0010,u
                    sta       D0022,u
                    lda       D0018,u
                    bcc       L028c
                    com       D0022,u
                    com       D0023,u
                    com       D0024,u
                    com       D0025,u
                    com       D0026,u
                    com       D0027,u
                    com       D0028,u
                    lda       ,u
                    beq       L0289
                    lbsr      L05d8
L0289               lda       D001c,u
L028c               sta       D0019,u
L028f               clr       ,u
L0291               lda       D0022,u
                    bmi       L02d2
                    ora       D0023,u
                    ora       D0024,u
                    ora       D0025,u
                    ora       D0026,u
                    ora       D0027,u
                    ora       D0028,u
                    beq       L02e6
                    ldd       D0022,u
L02ad               dec       D0029,u
                    bne       L02b5
                    dec       D001d,u
L02b5               asl       ,u
                    rol       D0028,u
                    rol       D0027,u
                    rol       D0026,u
                    rol       D0025,u
                    rol       D0024,u
                    rolb
                    rola
                    bpl       L02ad
                    stb       D0023,u
                    ldb       D0029,u
                    beq       L02ea
L02d2               ldb       D0019,u
L02d5               anda      #$7f
                    andb      #$80
                    pshs      b
                    adda      ,s+
                    sta       D0022,u
                    tst       D001d,u
                    bne       L02ea
L02e5               rts
L02e6               sta       D0029,u
                    rts
L02ea               lda       D001d,u
                    ldb       D0029,u
                    subd      #0
                    beq       L02fd
                    bmi       L02fd
L02f7               ldd       #$0028
                    lbra      _rpterr
L02fd               lbsr      L0328
                    bra       L02f7
L0302               beq       L0328
                    lda       D0017,u
                    beq       L0328
                    lbsr      L03a4
                    clra
                    ldb       D0029,u
                    addb      D0017,u
                    adca      #0
                    subd      #$0080
                    stb       D0029,u
                    sta       D001d,u
                    lbsr      L0291
                    lda       ,u
                    bpl       L02e5
                    lbra      L05d8
L0328               clra
                    sta       D0029,u
                    bra       L038e
L032e               ldb       D0017,u
                    bne       L0339
                    ldd       #$0029
                    lbra      _rpterr
L0339               tsta
                    beq       L0328
                    lbsr      L0402
                    clra
                    ldb       D0029,u
                    subb      D0017,u
                    sbca      #0
                    addd      #$0081
                    sta       D001d,u
                    stb       D0029,u
                    lda       6,u
                    coma
                    asra
                    ror       D0022,u
                    ror       D0023,u
                    ror       D0024,u
                    ror       D0025,u
                    ror       D0026,u
                    ror       D0027,u
                    ror       D0028,u
                    ror       ,u
                    lbsr      L0291
                    lda       ,u
                    bpl       L03a3
                    lbra      L05d8
L0376               pshs      a
                    ldd       D0022,u
                    std       ,u
                    ldd       D0024,u
                    std       2,u
                    ldd       D0026,u
                    std       4,u
                    ldb       D0028,u
                    stb       6,u
                    puls      a
L038e               sta       D0022,u
                    sta       D0023,u
                    sta       D0024,u
                    sta       D0025,u
                    sta       D0026,u
                    sta       D0027,u
                    sta       D0028,u
L03a3               rts
L03a4               clra
                    bsr       L0376
                    ldb       #$38
                    stb       8,u
L03ab               lda       6,u
                    lsra
                    bcc       L03da
                    ldd       D0027,u
                    addd      D0015,u
                    std       D0027,u
                    ldd       D0025,u
                    adcb      D0014,u
                    adca      D0013,u
                    std       D0025,u
                    ldd       D0023,u
                    adcb      D0012,u
                    adca      D0011,u
                    std       D0023,u
                    lda       D0022,u
                    adca      D0010,u
                    sta       D0022,u
L03da               ror       D0022,u
                    ror       D0023,u
                    ror       D0024,u
                    ror       D0025,u
                    ror       D0026,u
                    ror       D0027,u
                    ror       D0028,u
                    ror       ,u
                    ror       1,u
                    ror       2,u
                    ror       3,u
                    ror       4,u
                    ror       5,u
                    ror       6,u
                    dec       8,u
                    bne       L03ab
                    rts
L0402               clra
                    lbsr      L0376
                    ldb       #$39
                    stb       8,u
L040a               ldb       ,u
                    cmpb      D0010,u
                    bcs       L0441
                    ldd       5,u
                    subd      D0015,u
                    std       13,u
                    ldd       3,u
                    sbcb      D0014,u
                    sbca      D0013,u
                    std       11,u
                    ldb       2,u
                    sbcb      D0012,u
                    stb       10,u
                    ldd       ,u
                    sbcb      D0011,u
                    sbca      D0010,u
                    bcs       L0441
                    std       ,u
                    lda       10,u
                    sta       2,u
                    ldd       11,u
                    std       3,u
                    ldd       13,u
                    std       5,u
L0441               rol       D0028,u
                    rol       D0027,u
                    rol       D0026,u
                    rol       D0025,u
                    rol       D0024,u
                    rol       D0023,u
                    rol       D0022,u
                    rol       6,u
                    rol       5,u
                    rol       4,u
                    rol       3,u
                    rol       2,u
                    rol       1,u
                    rol       ,u
                    dec       8,u
                    bhi       L040a
                    beq       L048f
                    ldd       5,u
                    subd      D0015,u
                    std       5,u
                    ldd       3,u
                    sbcb      D0014,u
                    sbca      D0013,u
                    std       3,u
                    ldd       1,u
                    sbcb      D0012,u
                    sbca      D0011,u
                    std       1,u
                    lda       ,u
                    sbca      D0010,u
                    sta       ,u
                    clra
                    bra       L0441
L048f               ror       ,u
                    com       D0022,u
                    com       D0023,u
                    com       D0024,u
                    com       D0025,u
                    com       D0026,u
                    com       D0027,u
                    com       D0028,u
                    rts
L04a7               puls      d
                    pshs      u
                    leas      -30,s
                    tfr       s,u
                    pshs      d
                    clr       D001d,u
                    ldd       6,x
                    std       D0016,u
                    ldd       4,x
                    std       D0014,u
                    ldd       2,x
                    std       D0012,u
                    ldd       ,x
                    stb       D0011,u
                    tfr       a,b
                    sta       D001c,u
                    ora       #$80
                    sta       D0010,u
                    eorb      D0022,u
                    stb       D0019,u
                    lda       D0022,u
                    sta       D0018,u
                    ora       #$80
                    sta       D0022,u
                    lda       D0029,u
                    rts
                    leax      D0022,u
L04eb               lda       #$a0
                    sta       7,x
                    clr       4,x
                    clr       5,x
                    clr       6,x
                    lda       ,x
                    tfr       a,b
                    orb       1,x
                    orb       2,x
                    orb       3,x
                    beq       L0537
                    ldb       1,x
                    tsta
                    bpl       L0519
                    pshs      d
                    clra
                    clrb
                    subd      2,x
                    std       2,x
                    ldd       #0
                    sbcb      1,s
                    sbca      ,s
                    leas      2,s
                    bvs       L0523
L0519               dec       7,x
                    asl       3,x
                    rol       2,x
                    rolb
                    rola
                    bpl       L0519
L0523               anda      #$7f
                    tst       ,x
                    bpl       L052b
                    ora       #$80
L052b               std       ,x
                    rts
                    leax      D0022,u
                    clr       4,x
                    clr       5,x
                    clr       6,x
L0537               clr       7,x
L0539               clr       ,x
                    clr       1,x
                    clr       2,x
                    clr       3,x
                    rts
L0542               ldd       #$002a
                    lbra      _rpterr
                    leax      D0022,u
L054b               ldb       7,x
                    beq       L0539
                    subb      #$81
                    bcs       L05ca
                    negb
                    addb      #$1f
                    bmi       L0542
                    bne       L056f
                    ldd       ,x
                    cmpd      #$8000
                    bne       L0542
                    lda       2,x
                    ora       3,x
                    ora       4,x
                    ora       5,x
                    ora       6,x
                    bne       L0542
                    rts
L056f               pshs      b
                    ldd       ,x
                    bmi       L0585
                    ora       #$80
L0577               lsra
                    rorb
                    ror       2,x
                    ror       3,x
                    dec       ,s
                    bne       L0577
                    std       ,x
                    puls      b,pc
L0585               clr       ,-s
L0587               lsra
                    rorb
                    ror       2,x
                    ror       3,x
                    ror       4,x
                    ror       5,x
                    ror       6,x
                    bcc       L0597
                    inc       ,s
L0597               dec       1,s
                    bne       L0587
                    std       ,x
                    ldd       ,s++
                    bne       L05a9
                    lda       4,x
                    ora       5,x
                    ora       6,x
                    beq       L05ba
L05a9               ldd       2,x
                    addd      #1
                    std       2,x
                    ldd       ,x
                    adcb      #0
                    adca      #0
                    bcs       L0542
                    std       ,x
L05ba               clra
                    clrb
                    subd      2,x
                    std       2,x
                    ldd       #0
                    sbcb      1,x
                    sbca      ,x
                    std       ,x
                    rts
L05ca               lda       ,x
                    lbpl      L0539
                    ldd       #-1
                    std       2,x
                    std       ,x
                    rts
L05d8               inc       D0028,u
                    bne       L060e
                    inc       D0027,u
                    bne       L060e
                    inc       D0026,u
                    bne       L060e
                    inc       D0025,u
                    bne       L060e
                    inc       D0024,u
                    bne       L060e
                    inc       D0023,u
                    bne       L060e
                    ldb       D0022,u
                    tfr       b,a
                    anda      #$7f
                    inca
                    bpl       L0605
                    inc       D0029,u
                    anda      #$7f
L0605               andb      #$80
                    pshs      b
                    adda      ,s+
                    sta       D0022,u
L060e               rts
L060f               neg       D0000
                    neg       D0000
                    neg       D0000
                    neg       D0081
                    leax      >L060f,pcr
L061b               pshs      a
                    ldd       ,x
                    std       D0022,u
                    ldd       2,x
                    std       D0024,u
                    ldd       4,x
                    std       D0026,u
                    ldd       6,x
                    std       D0028,u
                    puls      a,pc
L0633               pshs      a
                    ldd       D0022,u
                    std       ,x
                    ldd       D0024,u
                    std       2,x
                    ldd       D0026,u
                    std       4,x
                    ldd       D0028,u
                    std       6,x
                    puls      a,pc
_xtofla             ldd       ,x
L064d               std       _flacc,y
                    ldd       2,x
                    std       _flacc+2,y
                    ldd       4,x
                    std       _flacc+4,y
                    ldd       6,x
                    leax      _flacc,y
                    std       6,x
                    rts
_dinc               pshs      x
                    bsr       _dstack
                    leax      <L060f,pcr
                    pshs      x
                    lbsr      L04a7
                    lbsr      L0189
L0675               ldx       D002a,u
                    bsr       L0633
                    ldx       D001e,u
                    leas      D002a,u
                    tfr       x,u
                    puls      x,pc
_ddec               pshs      x
                    bsr       _dstack
                    leax      >L060f,pcr
                    pshs      x
                    lbsr      L04a7
                    lbsr      L015f
                    bra       L0675
_finc               pshs      x
                    bsr       _fstack
                    leax      L060f,pcr
                    pshs      x
                    lbsr      L04a7
                    lbsr      L0189
L06a6               ldx       D002a,u
                    ldd       D0022,u
                    std       ,x
                    lda       D0024,u
                    ldb       D0029,u
                    std       2,x
                    ldx       D001e,u
                    leas      D002a,u
                    tfr       x,u
                    puls      x,pc
_fdec               pshs      x
                    bsr       _fstack
                    leax      L060f,pcr
                    pshs      x
                    lbsr      L04a7
                    lbsr      L015f
                    bra       L06a6
_fstack             leas      -8,s
                    ldd       8,s
                    std       ,s
                    clra
                    clrb
                    std       5,s
                    std       7,s
                    ldd       ,x
                    std       2,s
                    ldd       2,x
                    sta       4,s
                    stb       9,s
                    rts
_dstack             leas      -8,s
                    ldd       8,s
                    std       ,s
                    ldd       ,x
                    std       2,s
                    ldd       2,x
                    std       4,s
                    ldd       4,x
                    std       6,s
                    ldd       6,x
                    std       8,s
                    rts
_fmove              pshs      u
                    ldu       4,s
                    exg       x,u
                    ldd       ,u
                    std       ,x
                    ldd       2,u
                    std       2,x
                    bra       L0726
_dmove              pshs      u
                    ldu       4,s
                    exg       x,u
                    ldd       ,u
                    std       ,x
                    ldd       2,u
                    std       2,x
                    ldd       4,u
                    std       4,x
                    ldd       6,u
                    std       6,x
L0726               puls      u
                    puls      d
                    std       ,s
                    rts

                    endsect

