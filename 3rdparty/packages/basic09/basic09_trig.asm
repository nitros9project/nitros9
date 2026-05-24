* Arcsin
ASNFNC               pshs      x
                    bsr       CSIGN
                    ldd       $01,y
                    lbeq      L4A91
                    cmpd      #$0180
                    bgt       ASNERR
                    bne       L4946
                    ldd       $03,y
                    bne       ASNERR
                    lda       $05,y
                    lbeq      RETPI2
                   ifeq      INCLUDED&EDITOR
ASNERR               lbra      L4FC7
                   else
ASNERR               lbra      L4FC7
                   endc

L4946               lbsr      ARCSUB
                    leay      <-$14,y
                    leax      <$15,y
                    leau      ,y
                    lbsr      CMOVE
                    lbsr      CDENOR
                    leax      <$1B,y
                    lbra      L4A3E

* Get/clear sign bit
CSIGN               ldb       $05,y
                    andb      #$01
                    stb       <u006D
                    eorb      $05,y
                    stb       $05,y
                    rts

* Arccosine
ACSFNC               leau      <ACSRET,pc
                    pshs      u,x
                    bsr       CSIGN
                    ldd       $01,y
                    lbeq      RETPI2
                    cmpd      #$0180
                    bgt       ASNERR
                    bne       ACSF10
                    ldd       $03,y
                    bne       ASNERR
                    lda       $05,y
                    bne       ASNERR
                    lda       <u006D
                    bne       ACSF05
                    clrb
                    std       $01,y
                    puls      pc,u,x

ACSF05               leay      6,y
                    puls      u,x
                    lbra      L4B03

ACSF10               bsr       ARCSUB
                    leay      <-$14,y
                    leax      <$1B,y
                    leau      ,y
                    lbsr      CMOVE
                    lbsr      CDENOR
                    leax      <$15,y
                    lbra      L4A3E

ACSRET               lda       $05,y
                    bita      #$01
                    beq       ACSF25
                    ldu       <u0031
                    tst       1,u
                    beq       L49BF
                    leau      <L49C6,pc
                   ifeq      INCLUDED&EDITOR
                    lbsr      RCPVAR
                   else
                    lbsr      L3F93
                   endc
                    bra       ACSF20
L49BF               lbsr      L4B03
                   ifeq      INCLUDED&EDITOR
ACSF20               lbra      RLADD
                   else
ACSF20               lbra      L3FB1
                   endc
ACSF25               rts

L49C6               fcb       $08,$b4,$00,$00,$00

* Arc computation setup — sqrt(1-x^2)
ARCSUB               lda       <u006D
                    pshs      a
                    leay      <-$12,y
                    ldd       #$0201
                    std       $0C,y
                    lda       #$80
                    clrb
                    std       $0E,y
                    clra
                    std       <$10,y
                    ldd       <$12,y
                    std       ,y
                    std       $06,y
                    ldd       <$14,y
                    std       $02,y
                    std       $08,y
                    ldd       <$16,y
                    std       $04,y
                    std       $0A,y
                   ifeq      INCLUDED&EDITOR
                    lbsr      RLMUL
                    lbsr      L147E
                   else
                    lbsr      L40CC
                    lbsr      L3FAB
                   endc
                    lbsr      SQRR05
                    puls      a
                    sta       <u006D
                    rts

* Arctangent
ATNFNC               pshs      x
                    lbsr      CSIGN
                    ldb       $01,y
                    cmpb      #$18
                    blt       L4A17
RETPI2               leay      6,y
                    lbsr      L4B03
                    dec       $01,y
                    bra       ATNF35

L4A17               leay      <-$1A,y
                    ldd       #$1000
                    std       ,y
                    clra
                    std       $02,y
                    sta       $04,y
                    ldb       <$1B,y
                    bra       ATNF30

ATNF20               asr       ,y
                    ror       $01,y
                    ror       $02,y
                    ror       $03,y
                    ror       $04,y
                    decb
ATNF30               cmpb      #$02
                    bgt       ATNF20
                    stb       <$1B,y
                    leax      <$1B,y
L4A3E               leau      $0A,y
                    lbsr      CMOVE
                    lbsr      CDENOR
                    clra
                    clrb
                    std       <$14,y
                    std       <$16,y
                    sta       <$18,y
                    leax      >CCIRY0,pc
                    stx       <$19,y
                    lbsr      CIRCOR
                    leax      <$14,y
                    leau      <$1B,y
                    lbsr      CMOVE
                    lbsr      CNORM
                    leay      <$1A,y
ATNF35               lda       $05,y
                    ora       <u006D
                    sta       $05,y
                    ldu       <u0031
                    tst       1,u
                    beq       L4A91
                    leau      >L4AFE,pc
                   ifeq      INCLUDED&EDITOR
                    lbsr      RCPVAR
                    lbsr      RLMUL
                   else
                    lbsr      L3F93
                    lbsr      L40CC
                   endc
                    bra       L4A91

* Sine
SINFNC               pshs      x
                    lbsr      L4B0A
                    leax      $0A,y
                    bsr       L4A97
                    lda       $05,y
SINFN2               eora      <u009C
SINFN3               sta       $05,y
L4A91               lda       #$02
                    sta       ,y
                    puls      pc,x

* CORDIC sin/cos kernel
L4A97               leau      <$1B,y
                    lbsr      CMOVE
                    lbsr      CNORM
                    leay      <$14,y
                    leax      >L4D6A,pc
                    leau      $01,y
                    lbsr      CMOVE
                   ifeq      INCLUDED&EDITOR
                    lbra      RLMUL
                   else
                    lbra      L40CC
                   endc

* Cosine
COSFNC               pshs      x
                    bsr       L4B0A
                    leax      ,y
                    bsr       L4A97
                    lda       $05,y
                    eora      <u009B
                    bra       SINFN3

* Tangent
TANFNC               pshs      x
                    bsr       L4B0A
                    leax      $0A,y
                    leau      <$1B,y
                    lbsr      CMOVE
                    lbsr      CNORM
                    leax      ,y
                    leay      <$14,y
                    leau      $01,y
                    lbsr      CMOVE
                    lbsr      CNORM
                    ldd       $01,y
                    bne       TANF10
                    leay      $06,y
                    ldd       #$7FFF
L4AE2               std       $01,y
                    lda       #$FF
                    std       $03,y
                    deca
                    bra       TANF20

                   ifeq      INCLUDED&EDITOR
TANF10               lbsr      RLDIV
                   else
TANF10               lbsr      L422D
                   endc
                    lda       $05,y
TANF20               eora      <u009B
                    bra       SINFN2

* Floating-point constants
L4AF4               fcb       $02,$c9,$0f,$da,$a2

L4AF9               fcb       $fb,$8e,$fa,$35,$12

L4AFE               fcb       $06,$e5,$2e,$e0,$d4

* Load PI into temp var
                   ifeq      INCLUDED&EDITOR
L4B03               leau      >L4AF4,pcr
                    lbra      RCPVAR
                   else
L4B03               leau      <L4AF4,pc
                    lbra      L3F93
                   endc

* PIX — reduce angle to [-PI/2, PI/2]
L4B0A               ldu       <u0031
                    tst       1,u
                    beq       TRIG05
                   ifeq      INCLUDED&EDITOR
                    leau      >L4AF9,pcr
                    lbsr      RCPVAR
                    lbsr      RLMUL
                   else
                    leau      <L4AF9,pc
                    lbsr      L3F93
                    lbsr      L40CC
                   endc
TRIG05               clr       <u009B
                    ldb       $05,y
                    andb      #$01
                    stb       <u009C
                    eorb      $05,y
                    stb       $05,y
                    bsr       L4B03
                    inc       $01,y
                    lbsr      RLCMP
                    blt       TRIG10
                   ifeq      INCLUDED&EDITOR
                    lbsr      L1B7D
                   else
                    lbsr      MODFNR
                   endc
                    bsr       L4B03
                    bra       L4B38

TRIG10               dec       $01,y
L4B38               lbsr      RLCMP
                    blt       TRIG30
                    inc       <u009B
                    lda       <u009C
                    eora      #$01
                    sta       <u009C
                   ifeq      INCLUDED&EDITOR
                    lbsr      L147E
                   else
                    lbsr      L3FAB
                   endc
                    bsr       L4B03
TRIG30               dec       $01,y
                    lbsr      RLCMP
                    ble       L4B64
                    lda       <u009B
                    eora      #$01
                    sta       <u009B
                    inc       $01,y
                    lda       $0B,y
                    ora       #$01
                    sta       $0B,y
                   ifeq      INCLUDED&EDITOR
                    lbsr      RLADD
                   else
                    lbsr      L3FB1
                   endc
                    leay      -$06,y
L4B64               leay      <-$14,y
                    leax      >L4C33,pc
                    stx       <$19,y
                    leax      <$1B,y
                    leau      <$14,y
                    bsr       CMOVE
                    lbsr      CDENOR
                    ldd       #$1000
                    std       ,y
                    clra
                    std       $02,y
                    sta       $04,y
                    std       $0A,y
                    std       $0C,y
                    sta       $0E,y

* CORDIC rotation engine
CIRCOR               leax      >L4D29,pc
                    stx       <u0095
                   ifeq      INCLUDED&EDITOR
                    leax      >$0041,x
                   else
                    leax      <L4D6A-L4D29,x
                   endc
                    stx       <u0097
                    clr       <u009A
CORDIC               ldb       #$25
                    stb       <u0099
                    clr       <u009D
CORD10               leau      <$1B,y
                    ldx       <u0095
                    cmpx      <u0097
                    bhs       CORD20
                    bsr       CMOVE
                    leax      $05,x
                    stx       <u0095
                    bra       CORD30
CORD20               ldb       #$01
                    bsr       L4C1E
CORD30               leax      ,y
                    leau      $05,y
                    bsr       CSR
                    tst       <u009A
                    bne       CORD40
                    leax      $0A,y
                    leau      $0F,y
                    bsr       CSR
CORD40               jsr       [<$19,y]
                    inc       <u009D
                    dec       <u0099
                    bne       CORD10
                    rts

* Copy 5-byte CORDIC value
CMOVE                pshs      y,x
                    lda       ,x
                    ldy       $01,x
                    ldx       $03,x
                    sta       ,u
                    sty       1,u
                    stx       3,u
                    puls      pc,y,x

* CORDIC shift right
CSR                  ldb       ,x
                    sex
                    ldb       <u009D
                    lsrb
                    lsrb
                    lsrb
                    bcc       CSR05
                    incb
CSR05                pshs      b
                    beq       CSR2
CSR1                 sta       ,u+
                    decb
                    bne       CSR1
CSR2                 ldb       #$05
                    subb      ,s+
                    beq       CSR35
CSR3                 lda       ,x+
                    sta       ,u+
                    decb
                    bne       CSR3
CSR35                leau      -5,u
                    ldb       <u009D
                    andb      #$07
                    beq       CSR5
                    cmpb      #$04
                    bcs       L4C1E
                    subb      #$08
                    lda       ,x
L4C0F                lsla
                    rol       4,u
                    rol       3,u
                    rol       2,u
                    rol       1,u
                    rol       ,u
                    incb
                    bne       L4C0F
                    rts
L4C1E                asr       ,u
                    ror       1,u
                    ror       2,u
                    ror       3,u
                    ror       4,u
                    decb
                    bne       L4C1E
CSR5                 rts

* CORDIC rotation callbacks
CCIRY0               lda       $0A,y
                    eora      ,y
                    coma
                    bra       CTEST

L4C33                lda       <$14,y
CTEST                tsta
                    bpl       L4C4D
                    leax      ,y
                    leau      $0F,y
                    bsr       CADD
                    leax      $0A,y
                    leau      $05,y
                    bsr       CSUB
                    leax      <$14,y
                    leau      <$1B,y
                    bra       CADD

L4C4D                leax      ,y
                    leau      $0F,y
                    bsr       CSUB
                    leax      $0A,y
                    leau      $05,y
                    bsr       CADD
                    leax      <$14,y
                    leau      <$1B,y
                    bra       CSUB

* Check for premature CORDIC completion
FPDV45               leax      <$14,y
                    leau      <$1B,y
                    bsr       CSUB
                    bmi       CADD
                    bne       CLN
                    ldd       $01,x
                    bne       CLN
                    ldd       $03,x
                    bne       CLN
                    ldb       #$01
                    stb       <u0099
CLN                  leax      ,y
                    leau      $05,y
                    bra       CADD

L4C7F                leax      ,y
                    leau      $05,y
                    bsr       CADD
                    cmpa      #$20
                    bcc       CSUB
                    leax      <$14,y
                    leau      <$1B,y

* 5-byte add
CADD                 ldd       $03,x
                    addd      3,u
                    std       $03,x
                    ldd       $01,x
                    bcc       L4CA0
                    addd      #$0001
                    bcc       L4CA0
                    inc       ,x
L4CA0                addd      1,u
                    std       $01,x
                    lda       ,x
                    adca      ,u
                    sta       ,x
                    rts

* 5-byte subtract
CSUB                 ldd       $03,x
                    subd      3,u
                    std       $03,x
                    ldd       $01,x
                    bcc       L4CBC
                    subd      #$0001
                    bcc       L4CBC
                    dec       ,x
L4CBC                subd      1,u
                    std       $01,x
                    lda       ,x
                    sbca      ,u
                    sta       ,x
                    rts

* Denormalize 5-byte value
CDENOR               ldb       ,u
                    clr       ,u
                    addb      #$04
                    bge       CDEN20
                    negb
                    lbra      L4C1E

* Multiply 5-byte number by 2 (B times)
L4CD3                lsl       4,u
                    rol       3,u
                    rol       2,u
                    rol       1,u
                    rol       ,u
                    decb
CDEN20               bne       L4CD3
                    rts

* Normalize 5-byte value
CNORM                lda       ,u
                    bpl       L4CEE
                   ifeq      INCLUDED&EDITOR
                    clra
                    clrb
                   else
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                   endc
                    std       ,u
                    std       2,u
                    sta       4,u
                    rts

L4CEE                ldd       #$2004
L4CF1                decb
                    lsl       4,u
                    rol       3,u
                    rol       2,u
                    rol       1,u
                    rol       ,u
                    bmi       L4D05
                    deca
                    bne       L4CF1
                    clrb
                    std       ,u
                    rts

L4D05                lda       ,u
                    stb       ,u
                    ldb       1,u
                    sta       1,u
                    lda       2,u
                    stb       2,u
                    ldb       3,u
                    addd      #$0001
                    andb      #$FE
                    std       3,u
                    bcc       L4D28
                    inc       2,u
                    bne       L4D28
                    inc       1,u
                    bne       L4D28
                    ror       1,u
                    inc       ,u
L4D28                rts

* CORDIC angle table (first set)
L4D29                fcb       $0c,$90,$fd,$aa,$22
                    fcb       $07,$6b,$19,$c1,$58
                    fcb       $03,$eb,$6e,$bf,$26
                    fcb       $01,$fd,$5b,$a9,$ab
                    fcb       $00,$ff,$aa,$dd,$b9
                    fcb       $00,$7f,$f5,$56,$ef
                    fcb       $00,$3f,$fe,$aa,$b7
                    fcb       $00,$1f,$ff,$d5,$56
                    fcb       $00,$0f,$ff,$fa,$ab
                    fcb       $00,$07,$ff,$ff,$55
                    fcb       $00,$03,$ff,$ff,$eb
                    fcb       $00,$01,$ff,$ff,$fd
                    fcb       $00,$01,$00,$00,$00

* CORDIC gain/angle table (second set)
L4D6A                fcb       $00,$9b,$74,$ed,$a8
L4D6F                fcb       $0b,$17,$21,$7f,$7e
                    fcb       $06,$7c,$c8,$fb,$30
                    fcb       $03,$91,$fe,$f8,$f3
                    fcb       $01,$e2,$70,$76,$e3
                    fcb       $00,$f8,$51,$86,$01
                    fcb       $00,$7e,$0a,$6c,$3a
                    fcb       $00,$3f,$81,$51,$62
                    fcb       $00,$1f,$e0,$2a,$6b
                    fcb       $00,$0f,$f8,$05,$51
                    fcb       $00,$07,$fe,$00,$aa
                    fcb       $00,$03,$ff,$80,$15
                    fcb       $00,$01,$ff,$e0,$03
                    fcb       $00,$00,$ff,$f8,$00
                    fcb       $00,$00,$7f,$fe,$00
                    fcb       $00,$00,$3f,$ff,$80
                    fcb       $00,$00,$1f,$ff,$e0
                    fcb       $00,$00,$0f,$ff,$f8
                    fcb       $00,$00,$07,$ff,$fe
                    fcb       $00,$00,$04,$00,$00

* Constant used by RND
L4DCE                fdb       $0E12,$14A2,$BB40,$E62D,$3619,$62E9
