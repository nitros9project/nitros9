* Disassembly by Os9disasm of pffinit.r

                    section   bss

* Uninitialized data (class D)
D0000               rmb       1
* Initialized Data (class H)

                    endsect


                    section   bss

* Uninitialized data (class B)
B0000               rmb       1
B0001               rmb       29
B001e               rmb       0
* Initialized Data (class G)
G0000               fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $81
                    fcb       $4c
                    fcb       $cc
                    fcb       $cc
                    fcb       $cc
                    fcb       $cc
                    fcb       $cc
                    fcb       $cd
                    fcb       $7d
                    fcb       $23
                    fcb       $d7
                    fcb       $0a
                    fcb       $3d
                    fcb       $70
                    fcb       $a3
                    fcb       $d7
                    fcb       $7a
                    fcb       $03
                    fcb       $12
                    fcb       $6e
                    fcb       $97
                    fcb       $8d
                    fcb       $4f
                    fcb       $df
                    fcb       $77
                    fcb       $51
                    fcb       $b7
                    fcb       $17
                    fcb       $58
                    fcb       $e2
                    fcb       $19
                    fcb       $65
                    fcb       $73
                    fcb       $27
                    fcb       $c5
                    fcb       $ac
                    fcb       $47
                    fcb       $1b
                    fcb       $47
                    fcb       $84
                    fcb       $70
                    fcb       $06
                    fcb       $37
                    fcb       $bd
                    fcb       $05
                    fcb       $af
                    fcb       $6c
                    fcb       $6a
                    fcb       $6d
                    fcb       $56
                    fcb       $bf
                    fcb       $94
                    fcb       $d5
                    fcb       $e5
                    fcb       $7a
                    fcb       $43
                    fcb       $69
                    fcb       $2b
                    fcb       $cc
                    fcb       $77
                    fcb       $11
                    fcb       $84
                    fcb       $61
                    fcb       $cf
                    fcb       $66
                    fcb       $09
                    fcb       $70
                    fcb       $5f
                    fcb       $41
                    fcb       $36
                    fcb       $b4
                    fcb       $a6
                    fcb       $63
                    fcb       $5b
                    fcb       $e6
                    fcb       $fe
                    fcb       $ce
                    fcb       $bd
                    fcb       $ed
                    fcb       $d6
                    fcb       $5f
                    fcb       $2f
                    fcb       $eb
                    fcb       $ff
                    fcb       $0b
                    fcb       $cb
                    fcb       $24
                    fcb       $ab
                    fcb       $5c
                    fcb       $0c
                    fcb       $bc
                    fcb       $cc
                    fcb       $09
                    fcb       $6f
                    fcb       $50
                    fcb       $89
                    fcb       $59
                    fcb       $61
                    fcb       $2e
                    fcb       $13
                    fcb       $42
                    fcb       $4b
                    fcb       $b4
                    fcb       $0e
                    fcb       $55
                    fcb       $34
                    fcb       $24
                    fcb       $dc
                    fcb       $35
                    fcb       $09
                    fcb       $5c
                    fcb       $d8
                    fcb       $52
                    fcb       $10
                    fcb       $1d
                    fcb       $7c
                    fcb       $f7
                    fcb       $3a
                    fcb       $b0
                    fcb       $ad
                    fcb       $4f
                    fcb       $66
                    fcb       $95
                    fcb       $94
                    fcb       $be
                    fcb       $c4
                    fcb       $4d
                    fcb       $e1
                    fcb       $4b
                    fcb       $38
                    fcb       $77
                    fcb       $aa
                    fcb       $32
                    fcb       $36
                    fcb       $a4
                    fcb       $b4
                    fcb       $48
                    fdb       G0090

                    endsect

                    section   code

pffinit             pshs      u
                    puls      u,pc
pffloat             pshs      d,u
                    ldx       6,s
                    bra       L001a
L000a               ldd       #1
                    bra       L0016
L000f               ldd       #-1
                    bra       L0016
L0014               clra
                    clrb
L0016               std       ,s
                    bra       L0037
L001a               cmpx      #'f
                    beq       L000a
                    cmpx      #'e
                    beq       L000f
                    cmpx      #'E
                    lbeq      L000f
                    cmpx      #'g
                    beq       L0014
                    cmpx      #'G
                    lbeq      L0014
L0037               ldd       6,s
                    leax      _chcodes,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #2
                    pshs      d
                    ldd       2,s
                    pshs      d
                    ldd       12,s
                    pshs      d
                    ldd       [16,s]
                    addd      #8
                    std       [16,s]
                    subd      #8
                    pshs      d
                    bsr       L0064
                    leas      8,s
                    leas      2,s
                    puls      u,pc
L0064               pshs      u
                    leas      -32,s
                    ldd       #1
                    std       8,s
                    leax      ,s
                    pshs      x
                    ldx       38,s
                    lbsr      _dmove
                    leau      ,s
                    ldb       7,u
                    bne       L008f
                    clra
                    clrb
                    std       24,s
                    std       26,s
                    std       18,s
                    leax      32,s
                    lbra      L0181
L008f               ldb       7,u
                    clra
                    addd      #-128
                    std       22,s
                    bge       L00a9
                    ldd       22,s
                    nega
                    negb
                    sbca      #0
                    std       22,s
                    ldd       #1
                    bra       L00ab
L00a9               clra
                    clrb
L00ab               std       24,s
                    ldd       22,s
                    pshs      d
                    ldd       #78
                    lbsr      ccmult
                    pshs      d
                    ldd       #8
                    lbsr      ccasr
                    std       20,s
                    ldd       24,s
                    beq       L00d2
                    ldd       20,s
                    nega
                    negb
                    sbca      #0
                    bra       L00d5
L00d2               ldd       20,s
L00d5               addd      #1
                    std       18,s
                    ldb       ,u
                    bge       L00eb
                    ldb       ,u
                    clra
                    andb      #$7f
                    stb       ,u
                    ldd       #1
                    bra       L00ed
L00eb               clra
                    clrb
L00ed               std       26,s
                    leax      ,s
                    pshs      x
                    ldd       26,s
                    pshs      d
                    ldd       24,s
                    pshs      d
                    leax      6,s
                    lbsr      _dstack
                    lbsr      scale
                    leas      12,s
                    lbsr      _dmove
                    bra       L012f
L010d               leax      ,s
                    pshs      x
                    lbsr      _dstack
                    bsr       L011e
                    fdb       8192,0,0,132
L011e               puls      x
                    lbsr      _dmul
                    lbsr      _dmove
                    ldd       18,s
                    addd      #-1
                    std       18,s
L012f               leax      ,s
                    lbsr      _dstack
                    bsr       L013e
                    fdb       0,0,0,129
L013e               puls      x
                    lbsr      _dcmpr
                    blt       L010d
                    bra       L0169
L0147               leax      ,s
                    pshs      x
                    lbsr      _dstack
                    bsr       L0158
                    fdb       8192,0,0,132
L0158               puls      x
                    lbsr      _ddiv
                    lbsr      _dmove
                    ldd       18,s
                    addd      #1
                    std       18,s
L0169               leax      ,s
                    lbsr      _dstack
                    bsr       L0178
                    fdb       8192,0,0,132
L0178               puls      x
                    lbsr      _dcmpr
                    bge       L0147
                    bra       L0184
L0181               leas      -32,x
L0184               leax      B0000,y
                    stx       30,s
                    ldd       #'0
                    ldx       30,s
                    leax      1,x
                    stx       30,s
                    stb       -1,x
                    ldd       26,s
                    beq       L01aa
                    ldd       #'-
                    ldx       30,s
                    leax      1,x
                    stx       30,s
                    stb       -1,x
L01aa               ldd       38,s
                    cmpd      #$0010
                    ble       L01b8
                    ldd       #$0010
                    bra       L01bf
L01b8               ldd       38,s
                    bge       L01c2
                    clra
                    clrb
L01bf               std       38,s
L01c2               clra
                    clrb
                    std       10,s
                    ldd       40,s
                    bne       L01e0
                    ldd       #1
                    std       10,s
                    ldd       18,s
                    cmpd      #5
                    lbgt      L0252
                    leax      32,s
                    bra       L0213
L01e0               ldd       40,s
                    bge       L0216
                    bra       L01ea
L01e7               leas      -32,x
L01ea               ldd       #1
                    std       16,s
                    ldd       #1
                    std       12,s
                    leax      ,s
                    lbsr      _dstack
                    bsr       L0204
                    fdb       0,0,0,0
L0204               puls      x
                    lbsr      _dcmpr
                    bne       L0258
                    ldd       #1
                    std       18,s
                    bra       L0258
L0213               leas      -32,x
L0216               clra
                    clrb
                    std       16,s
                    ldd       18,s
                    std       12,s
                    bge       L0247
                    ldd       12,s
                    addd      38,s
                    blt       L0233
                    ldd       38,s
                    addd      12,s
                    std       38,s
                    bra       L0258
L0233               ldd       38,s
                    nega
                    negb
                    sbca      #0
                    std       12,s
                    clra
                    clrb
                    std       38,s
                    clra
                    clrb
                    std       8,s
                    bra       L0258
L0247               ldd       12,s
                    addd      38,s
                    cmpd      #$0019
                    ble       L0258
L0252               leax      32,s
                    lbra      L01e7
L0258               leax      G0000,y
                    stx       14,s
                    leax      ,s
                    pshs      x
                    lbsr      L0464
                    leas      2,s
                    ldd       12,s
                    bge       L029e
                    ldd       #'0
                    ldx       30,s
                    leax      1,x
                    stx       30,s
                    stb       -1,x
                    ldd       30,s
                    std       28,s
                    ldd       #'.
                    bra       L0286
L0283               ldd       #'0
L0286               ldx       30,s
                    leax      1,x
                    stx       30,s
                    stb       -1,x
                    ldd       12,s
                    addd      #1
                    std       12,s
                    subd      #1
                    bne       L0283
                    bra       L02f1
L029e               ldd       12,s
                    bne       L02be
                    ldd       #'0
                    bra       L02b4
L02a7               leax      14,s
                    pshs      x
                    leax      2,s
                    pshs      x
                    lbsr      L049c
                    leas      4,s
L02b4               ldx       30,s
                    leax      1,x
                    stx       30,s
                    stb       -1,x
L02be               ldd       12,s
                    addd      #-1
                    std       12,s
                    subd      #-1
                    bne       L02a7
                    ldd       30,s
                    std       28,s
                    ldd       38,s
                    beq       L02f1
                    ldd       #'.
                    bra       L02e7
L02da               leax      14,s
                    pshs      x
                    leax      2,s
                    pshs      x
                    lbsr      L049c
                    leas      4,s
L02e7               ldx       30,s
                    leax      1,x
                    stx       30,s
                    stb       -1,x
L02f1               ldd       38,s
                    addd      #-1
                    std       38,s
                    subd      #-1
                    bgt       L02da
                    ldd       8,s
                    lbeq      L037b
                    leas      -4,s
                    ldd       34,s
                    std       ,s
                    tfr       d,x
                    pshs      x
                    leax      20,s
                    pshs      x
                    leax      8,s
                    pshs      x
                    lbsr      L049c
                    leas      4,s
                    stb       [,s++]
                    ldd       #5
                    std       2,s
L0325               ldb       [,s]
                    sex
                    tfr       d,x
                    bra       L0343
L032c               ldd       ,s
                    addd      #-1
                    std       ,s
                    bra       L034d
L0335               ldd       #'-
                    ldx       ,s
                    stb       -1,x
                    ldd       #'0
                    stb       [,s]
                    bra       L034d
L0343               cmpx      #'.
                    beq       L032c
                    cmpx      #'-
                    beq       L0335
L034d               ldb       [,s]
                    sex
                    addd      2,s
                    stb       [,s]
                    cmpd      #'9
                    ble       L035f
                    ldd       #1
                    bra       L0361
L035f               clra
                    clrb
L0361               std       2,s
                    beq       L0379
                    ldb       [,s]
                    sex
                    subd      #10
                    stb       [,s]
                    bra       L036f
L036f               ldd       ,s
                    addd      #-1
                    std       ,s
                    lbra      L0325
L0379               leas      4,s
L037b               ldd       16,s
                    lbeq      L03f2
                    ldd       42,s
                    beq       L038c
                    ldd       #'E
                    bra       L038f
L038c               ldd       #'e
L038f               ldx       30,s
                    leax      1,x
                    stx       30,s
                    stb       -1,x
                    ldd       18,s
                    addd      #-1
                    std       18,s
                    bge       L03b3
                    ldd       18,s
                    nega
                    negb
                    sbca      #0
                    std       18,s
                    ldd       #$002d
                    bra       L03b6
L03b3               ldd       #'+
L03b6               ldx       30,s
                    leax      1,x
                    stx       30,s
                    stb       -1,x
                    ldd       18,s
                    pshs      d
                    ldd       #10
                    lbsr      ccdiv
                    addd      #'0
                    ldx       30,s
                    leax      1,x
                    stx       30,s
                    stb       -1,x
                    ldd       18,s
                    pshs      d
                    ldd       #10
                    lbsr      ccmod
                    addd      #'0
                    ldx       30,s
                    leax      1,x
                    stx       30,s
                    stb       -1,x
                    bra       L0422
L03f2               ldd       10,s
                    beq       L0422
                    ldd       30,s
                    cmpd      28,s
                    beq       L0422
                    bra       L0413
L0401               ldb       [30,s]
                    cmpb      #'0
                    beq       L0413
                    ldd       30,s
                    addd      #1
                    std       30,s
                    bra       L0422
L0413               ldd       30,s
                    addd      #-1
                    std       30,s
                    cmpd      28,s
                    bne       L0401
L0422               clra
                    clrb
                    stb       [30,s]
                    leax      B001e,y
                    cmpx      30,s
                    bhi       L044b
                    leax      L04eb,pcr
                    pshs      x
                    leax      _iob+26,y
                    pshs      x
                    lbsr      fprintf
                    leas      4,s
                    ldd       #1
                    pshs      d
                    lbsr      exit
                    leas      2,s
L044b               ldb       B0000,y
                    cmpb      #'0
                    bne       L0459
                    leax      B0001,y
                    bra       L045d
L0459               leax      B0000,y
L045d               tfr       x,d
                    leas      32,s
                    puls      u,pc
L0464               pshs      u
                    ldx       4,s
                    lda       7,x
                    suba      #$80
                    bcs       L0496
                    ldb       ,x
                    orb       #$80
                    stb       ,x
                    clr       7,x
                    suba      #4
                    beq       L048d
L047a               lsr       ,x
                    ror       1,x
                    ror       2,x
                    ror       3,x
                    ror       4,x
                    ror       5,x
                    ror       6,x
                    ror       7,x
                    inca
                    bne       L047a
L048d               lda       #8
L048f               deca
                    bmi       L0496
                    ldb       a,x
                    beq       L048f
L0496               sta       D0000
                    clra
                    clrb
                    puls      u,pc
L049c               ldx       2,s
                    clra
                    ldb       ,x
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    addb      #'0
                    pshs      d,u
                    ldb       ,x
                    andb      #$0f
                    stb       ,x
                    bsr       L04dd
                    lda       D0000
                    bmi       L04db
L04b5               ldb       a,x
                    bne       L04bc
                    deca
                    bpl       L04b5
L04bc               sta       D0000
                    bmi       L04db
                    leas      -8,s
L04c2               ldb       a,x
                    stb       a,s
                    deca
                    bpl       L04c2
                    bsr       L04dd
                    bsr       L04dd
                    lda       D0000
                    clrb
L04d0               ldb       a,x
                    adcb      a,s
                    stb       a,x
                    deca
                    bpl       L04d0
                    leas      8,s
L04db               puls      d,u,pc
L04dd               lda       D0000
                    bmi       L04ea
                    asl       a,x
                    bra       L04e7
L04e5               rol       a,x
L04e7               deca
                    bpl       L04e5
L04ea               rts
L04eb               fcc       "pffinit buffer overflow"
                    fcb       $0d,$00

                    endsect

