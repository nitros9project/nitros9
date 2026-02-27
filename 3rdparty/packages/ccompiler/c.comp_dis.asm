                    nam       c.comp
                    ttl       program module

                    use       defsfile

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       $05

                    mod       eom,name,tylg,atrv,start,size

u0000               rmb       4389
size                equ       .

name                equ       *
                    fcs       /c.comp/
                    fcb       edition

L0014               lda       ,y+
L0016               sta       ,u+
L0018               leax      -$01,x
L001A               bne       L0014
L001C               rts

start               pshs      y
L001F               pshs      u
L0021               clra
L0022               clrb
L0023               sta       ,u+
L0025               decb
L0026               bne       L0023
L0028               ldx       ,s
L002A               leau      ,x
L002C               leax      $08A5,x
L0030               pshs      x
L0032               leay      LB358,pcr
L0036               ldx       ,y++
L0038               beq       L003E
L003A               bsr       L0014
L003C               ldu       $02,s
L003E               leau      >$0078,u
L0042               ldx       ,y++
L0044               beq       L0049
L0046               bsr       L0014
L0048               clra
L0049               cmpu      ,s
L004C               beq       L0052
L004E               sta       ,u+
L0050               bra       L0049

L0052               ldu       $02,s
L0054               ldd       ,y++
L0056               beq       L005F
L0058               leax      >$0000,pcr
L005C               lbsr      L0162
L005F               ldd       ,y++
L0061               beq       L0068
L0063               leax      ,u
L0065               lbsr      L0162
L0068               leas      $04,s
L006A               puls      x
L006C               stx       $0356,u
L0070               sty       $0316,u
L0075               ldd       #$0001
L0078               std       $0352,u
L007C               leay      $0318,u
L0080               leax      ,s
L0082               lda       ,x+
L0084               ldb       $0353,u
L0088               cmpb      #$1d
                    beq       L00E0
L008C               cmpa      #$0d
L008E               beq       L00E0
L0090               cmpa      #$20
L0092               beq       L0098
L0094               cmpa      #$2C
L0096               bne       L009C
L0098               lda       ,x+
                    bra       L008C

L009C               cmpa      #$22
L009E               beq       L00A4
L00A0               cmpa      #$27
L00A2               bne       L00C2
L00A4               stx       ,y++
L00A6               inc       $0353,u
                    pshs      a
L00AC               lda       ,x+
L00AE               cmpa      #$0d
L00B0               beq       L00B6
L00B2               cmpa      ,s
L00B4               bne       L00AC
L00B6               puls      b
L00B8               clr       -$01,x
                    cmpa      #$0d
                    beq       L00E0
                    lda       ,x+
                    bra       L0084

L00C2               leax      -$01,x
                    stx       ,y++
                    leax      $01,x
L00C8               inc       $0353,u
L00CC               cmpa      #$0d
                    beq       L00DC
                    cmpa      #$20
                    beq       L00DC
                    cmpa      #$2C
                    beq       L00DC
                    lda       ,x+
                    bra       L00CC

L00DC               clr       -$01,x
                    bra       L0084

L00E0               leax      $0316,u
                    pshs      x
                    ldd       $0352,u
                    pshs      d
                    leay      ,u
                    bsr       L00FA
                    lbsr      L017C
                    clr       ,-s
                    clr       ,-s
                    lbsr      LB34C
L00FA               leax      $08A5,y
                    stx       $0360,y
                    sts       $0354,y
                    sts       $0362,y
                    ldd       #$FF82
L010F               leax      d,s
                    cmpx      $0362,y
                    bcc       L0121
                    cmpx      $0360,y
                    bcs       L013B
                    stx       $0362,y
L0121               fcb       $39
L0122               fcb       $2a,$2a,$2a,$2a,$20,$53,$54,$41
                    fcb       $43,$4b,$20,$4f,$56,$45,$52,$46
                    fcb       $4C,$4f,$57,$20,$2a,$2a,$2a,$2a
                    fcb       $0d
L013B               leax      L0122,pcr
                    ldb       #$CF
                    pshs      b
                    lda       #$02
                    ldy       #$0064
                    os9       I$WritLn
                    clr       ,-s
                    lbsr      $B352
                    ldd       $0354,y
                    subd      $0362,y
                    rts
                    ldd       $0362,y
                    subd      $0360,y
                    rts

L0162               pshs      x
                    leax      d,y
                    leax      d,x
                    pshs      x
L016A               ldd       ,y++
                    leax      d,u
                    ldd       ,x
                    addd      $02,s
                    std       ,x
                    cmpy      ,s
                    bne       L016A
                    leas      $04,s
                    rts

L017C               pshs      u
                    leax      L5DC9,pcr
                    pshs      x
                    lbsr      $B31C
                    leas      $02,s
                    leax      $0096,y
                    pshs      x
                    lbsr      $9FD7
                    leas      $02,s
                    leax      L0300,pcr
                    pshs      x
                    ldd       $0094,y
                    pshs      d
                    lbsr      $A5D9
                    leas      $04,s
                    lbsr      L6292
                    leax      $0246,y
                    stx       $0003
                    leax      $0253,y
                    stx       $0005
                    lbra      L0295

L01B7               ldx       $06,s
                    leax      $02,x
                    stx       $06,s
                    ldu       ,x
                    ldb       ,u
                    cmpb      #$2d
                    lbne      L0265
                    lbra      L0257

L01CA               ldb       ,u
                    sex
                    tfr       d,x
                    lbra      L023B

L01D2               ldd       #$0001
                    std       $0015
                    lbra      L0257

L01DA               ldd       $0019
                    addd      #$0001
                    std       $0019
                    lbra      L0257

L01E4               leau      $01,u
                    ldb       ,u
                    cmpb      #$3d
                    bne       L0215
                    leax      L0308,pcr
                    pshs      x
                    leau      $01,u
                    pshs      u
                    lbsr      L9F43
                    leas      $04,s
                    std       $0005
                    bne       L0215
                    pshs      u
                    leax      $030A,pcr
                    pshs      x
                    leax      $0260,y
                    pshs      x
                    lbsr      L9A34
                    leas      $06,s
                    lbsr      L02F2
L0215               leax      ,s
                    bra       L0261

L0219               ldd       #$0001
                    std       $0017
                    bra       L0257

L0220               ldb       ,u
                    sex
                    pshs      d
                    leax      L0319,pcr
                    pshs      x
                    leax      $0260,y
                    pshs      x
                    lbsr      L9A34
                    leas      $06,s
                    lbsr      L02F2
                    bra       L0257

L023B               cmpx      #$0073
                    lbeq      L01D2
                    cmpx      #$006E
                    lbeq      L01DA
                    cmpx      #$006F
                    lbeq      L01E4
                    cmpx      #$0070
                    beq       L0219
                    bra       L0220

L0257               leau      $01,u
                    ldb       ,u
                    lbne      L01CA
                    bra       L0295

L0261               leas      ,x
                    bra       L0295

L0265               ldd       L0052
                    bne       L0295
                    ldd       L0052
                    addd      #$0001
                    std       L0052
                    leax      $0246,y
                    pshs      x
                    leax      L032D,pcr
                    pshs      x
                    ldd       [$0a,s]
                    pshs      d
                    lbsr      L9F62
                    leas      $06,s
                    std       $0003
                    bne       L0295
                    leax      $032F,pcr
                    pshs      x
                    lbsr      L042D
                    leas      $02,s
L0295               ldd       $04,s
                    addd      #$FFFF
                    std       $04,s
                    lbgt      L01B7
                    lbsr      L42A6
                    lbsr      $5F26
                    bra       L02AB

L02A8               lbsr      L8192
L02AB               ldd       $003F
                    cmpd      #$FFFF
                    bne       L02A8
                    lbsr      L5BC7
                    ldx       $0005
                    ldd       $06,x
                    clra
                    andb      #$20
                    beq       L02CA
                    leax      $0345,pcr
                    pshs      x
                    lbsr      L042D
                    leas      $02,s
L02CA               leax      $0253,y
                    pshs      x
                    lbsr      $A2F8
                    leas      $02,s
                    ldd       $0009
                    beq       L02F0
                    ldd       $0009
                    pshs      d
                    leax      $0366,pcr
                    pshs      x
                    leax      $0260,y
                    pshs      x
                    lbsr      L9A34
                    leas      $06,s
                    bsr       L02F2
L02F0               puls      pc,u
L02F2               pshs      u
                    ldd       #$0001
                    pshs      d
                    lbsr      LB34C
                    leas      $02,s
                    puls      pc,u
L0300               clrb
                    lsr       -$0b,s
                    tst       $0d,s
                    rol       L5F00
L0308               asr       >L0063
                    fcb       $61
                    jmp       $07,y
                    lsr       $206F
                    neg       $656E
                    bra       L033B
                    com       $0D00
L0319               fcb       $75,$6e,$6b,$6e,$6f,$77,$6e,$20
                    fcb       $66,$6C,$61,$67,$20,$3a,$20,$2d
                    fcb       $25,$63,$0d,$00
L032D               fcb       $72
                    neg       L0063
                    fcb       $61
                    jmp       $07,y
                    lsr       $206F
                    neg       $656E
                    bra       $03A4

L033B               jmp       -$10,s
                    fcb       $75
                    lsr       L2066
                    rol       $0C,s
                    fcb       $65
                    neg       L0065
                    fcb       $72
                    fcb       $72
                    clr       -$0e,s
                    bra       $03C3
                    fcb       $72
                    rol       -$0C,s
                    rol       $0e,s
                    asr       0,y
                    fcb       $61
                    com       $7365
                    tst       $02,s
                    inc       -$07,s
                    bra       $03C0
                    clr       $04,s
                    fcb       $65
                    bra       $03C8
                    rol       $0C,s
                    fcb       $65
                    neg       L0065
                    fcb       $72,$72,$6f,$72,$73,$20,$69,$6e
                    fcb       $20,$63,$6f,$6d,$70,$69,$6C,$61
                    fcb       $74,$69,$6f,$6e,$20,$3a,$20,$25
                    fcb       $64,$0d,$00
L0382               pshs      u
                    ldu       $04,s
                    leas      -$06,s
                    ldd       L0023
                    std       $02,s
                    beq       L0397
                    ldx       $02,s
                    ldd       $10,x
                    std       L0023
                    bra       L03A3

L0397               ldd       #$0012
                    pshs      d
                    lbsr      L6622
                    leas      $02,s
                    std       $02,s
L03A3               ldd       #$0012
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    stu       $08,s
                    pshs      u
                    bsr       L03FB
                    leas      $06,s
                    ldd       #$0009
                    std       ,s
                    bra       L03BF

L03BB               clra
                    clrb
                    std       ,u++
L03BF               ldd       ,s
                    addd      #$FFFF
                    std       ,s
                    subd      #$FFFF
                    bne       L03BB
                    ldd       $02,s
                    ldx       $04,s
                    std       $0e,x
                    lbra      L05DB

L03D4               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    ldd       $0e,u
                    std       ,s
                    ldd       #$0012
                    pshs      d
                    pshs      u
                    ldd       $04,s
                    pshs      d
                    bsr       L03FB
                    leas      $06,s
                    ldd       L0023
                    ldx       ,s
                    std       $10,x
                    ldd       ,s
                    std       L0023
                    lbra      L05B5

L03FB               pshs      u
                    ldu       $04,s
                    bra       L040B

L0401               ldb       ,u+
                    ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    stb       -$01,x
L040B               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bne       L0401
                    puls      pc,u
L0419               pshs      u
                    leax      $0366,y
                    pshs      x
                    leax      L0725,pcr
                    pshs      x
                    lbsr      L054F
                    lbra      L0594

L042D               pshs      u
                    ldd       $04,s
                    pshs      d
                    bsr       L0450
                    leas      $02,s
                    leax      $0260,y
                    pshs      x
                    lbsr      $A2F8
                    lbra      L0548

L0443               pshs      u
                    leax      L072B,pcr
                    pshs      x
                    bsr       L0450
                    lbra      L05B5

L0450               pshs      u
                    ldd       L001F
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    leax      $0584,y
                    pshs      x
                    ldd       $0043
                    bra       L04AD

L0464               pshs      u
                    leas      -$32,s
                    leax      L073F,pcr
                    pshs      x
                    leax      $02,s
                    pshs      x
                    lbsr      $A5D9
                    leas      $04,s
                    ldd       $38,s
                    pshs      d
                    leax      $02,s
                    pshs      x
                    lbsr      $A5F1
                    leas      $04,s
                    leax      ,s
                    pshs      x
                    ldd       $38,s
                    pshs      d
                    bsr       L0498
                    leas      $04,s
                    leas      $32,s
                    puls      pc,u
L0498               pshs      u
                    ldu       $04,s
                    ldd       $0e,u
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    leax      $0584,y
                    pshs      x
                    ldd       $10,u
L04AD               subd      ,s++
                    pshs      d
                    bsr       L04B6
                    lbra      L05DB

L04B6               pshs      u
                    ldu       $04,s
                    lbsr      L0419
                    ldd       $08,s
                    pshs      d
                    leax      L0751,pcr
                    pshs      x
                    lbsr      L054F
                    leas      $04,s
                    ldd       $06,s
                    pshs      d
                    leax      L075B,pcr
                    pshs      x
                    lbsr      L054F
                    leas      $04,s
                    ldd       $08,s
                    cmpd      $0007
                    bne       L04F1
                    leax      $0584,y
                    pshs      x
                    lbsr      L056A
                    leas      $02,s
                    leax      ,s
                    bra       L0508

L04F1               ldd       $0007
                    addd      #$FFFF
                    cmpd      $08,s
                    bne       L0528
                    leax      $0684,y
                    pshs      x
                    lbsr      L056A
                    leas      $02,s
                    bra       L0518

L0508               leas      ,x
                    bra       L0518

L050C               ldd       #$0020
                    pshs      d
                    lbsr      L0584
                    leas      $02,s
                    leau      -$01,u
L0518               cmpu      #$0000
                    bgt       L050C
                    leax      L076B,pcr
                    pshs      x
                    bsr       L056A
                    leas      $02,s
L0528               ldd       $0009
                    addd      #$0001
                    std       $0009
                    cmpd      #$001E
                    ble       L054D
                    leax      $0260,y
                    pshs      x
                    lbsr      $A2F8
                    leas      $02,s
                    leax      $076D,pcr
                    pshs      x
                    bsr       L056A
L0548               leas      $02,s
                    lbsr      L5DC9
L054D               puls      pc,u
L054F               pshs      u
                    ldd       $08,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    leax      $0260,y
                    pshs      x
                    lbsr      L9A34
                    leas      $08,s
                    puls      pc,u
L056A               pshs      u
                    leax      $0260,y
                    pshs      x
                    ldd       $06,s
                    pshs      d
                    lbsr      $9FB7
                    leas      $04,s
                    ldd       #$000D
                    pshs      d
                    bsr       L0584
                    bra       L05B5

L0584               pshs      u
                    leax      $0260,y
                    pshs      x
                    ldb       $07,s
                    sex
                    pshs      d
                    lbsr      $A1CD
L0594               leas      $04,s
                    puls      pc,u
L0598               pshs      u
                    ldu       $04,s
                    stu       -$02,s
                    beq       L05B7
                    ldd       $0a,u
                    pshs      d
                    bsr       L0598
                    leas      $02,s
                    ldd       $0C,u
                    pshs      d
                    lbsr      L0598
                    leas      $02,s
                    pshs      u
                    bsr       L05B9
L05B5               leas      $02,s
L05B7               puls      pc,u
L05B9               pshs      u
                    ldu       $04,s
                    stu       -$02,s
                    beq       L05C7
                    ldd       $000D
                    std       $0a,u
                    stu       $000D
L05C7               puls      pc,u
L05C9               pshs      u
                    ldd       #$0016
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L03FB
L05DB               leas      $06,s
                    puls      pc,u
L05DF               pshs      u
                    ldd       $003F
                    cmpd      #$0033
                    bne       L062D
                    ldx       $0041
                    cmpx      #$0001
                    lbeq      L06FF
                    cmpx      #$0002
                    lbeq      L06FF
                    cmpx      #$0007
                    lbeq      L06FF
                    cmpx      #$000A
                    lbeq      L06FF
                    cmpx      #$0008
                    lbeq      L06FF
                    cmpx      #$0004
                    lbeq      L06FF
                    cmpx      #$0003
                    lbeq      L06FF
                    cmpx      #$0006
                    lbeq      L06FF
                    cmpx      #$0005
                    lbeq      L06FF
                    lbra      L06CD

L062D               ldd       $003F
                    cmpd      #$0034
                    lbne      L06CD
                    ldx       $0041
                    ldd       $08,x
                    cmpd      #$001E
                    bra       L0675

L0641               pshs      u
                    ldd       $003F
                    cmpd      #$0033
                    lbne      L06CD
                    ldx       $0041
                    cmpx      #$000E
                    lbeq      L06FF
                    cmpx      #$000D
                    lbeq      L06FF
                    cmpx      #$001E
                    lbeq      L06FF
                    cmpx      #$0010
                    lbeq      L06FF
                    cmpx      #$000F
                    lbeq      L06FF
                    cmpx      #$0021
L0675               lbeq      L06FF
                    lbra      L06CD

L067C               pshs      u
                    ldd       $04,s
                    asra
                    rorb
                    asra
                    rorb
                    andb      #$F0
                    bra       L0695

L0688               pshs      u
                    ldd       $04,s
                    andb      #$F0
                    aslb
                    rola
                    aslb
                    rola
                    addd      #$0010
L0695               pshs      d
                    ldd       $06,s
                    clra
                    andb      #$0f
                    addd      ,s++
                    puls      pc,u
L06A0               pshs      u
                    ldu       $04,s
                    cmpu      #$004C
                    blt       L06CD
                    cmpu      #$0063
                    bgt       L06CD
                    ldd       #$0001
                    bra       L06CF

L06B5               pshs      u
                    ldu       $04,s
                    stu       -$02,s
                    beq       L06CD
                    ldd       $02,u
                    bra       L06CF

L06C1               pshs      u
                    ldd       $003F
                    cmpd      $04,s
                    bne       L06D1
                    lbsr      $5F26
L06CD               clra
                    clrb
L06CF               puls      pc,u
L06D1               ldu       #$0000
                    bra       L06E8

L06D6               tfr       u,d
                    leax      $00BA,y
                    leax      d,x
                    ldb       ,x
                    sex
                    cmpd      $04,s
                    beq       L06EE
                    leau      $01,u
L06E8               cmpu      #$0080
                    blt       L06D6
L06EE               tfr       u,d
                    stb       $00A1,y
                    leax      $00A1,y
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
L06FF               ldd       #$0001
                    puls      pc,u
L0704               pshs      u
                    bra       L070B

L0708               lbsr      $5F26
L070B               ldd       $003F
                    cmpd      #$0028
                    beq       L0723
                    ldd       $003F
                    cmpd      #$002A
                    beq       L0723
                    ldd       $003F
                    cmpd      #$FFFF
                    bne       L0708
L0723               puls      pc,u
L0725               bcs       L079A
                    bra       L0763
                    bra       L072B

L072B               tst       -$0b,s
                    inc       -$0C,s
                    rol       -$10,s
                    inc       $05,s
                    bra       L0799
                    fcb       $65
                    ror       $09,s
                    jmp       $09,s
                    lsr       $696F
                    jmp       0,x

L073F               com       $0f,s
                    tst       -$10,s
                    rol       $0C,s
                    fcb       $65
                    fcb       $72
                    bra       L07AE
                    fcb       $72
                    fcb       $72
                    clr       -$0e,s
                    bra       $077C
                    bra       L0751

L0751               inc       $09,s
                    jmp       $05,s
                    bra       $077C
                    lsr       0,y
                    bra       L075B

L075B               bpl       L0787
                    bpl       $0789
                    bra       L0781
                    bcs       $07D6
L0763               bra       $0785
                    bpl       $0791
                    bpl       $0793
                    tst       $0000
L076B               fcb       $5e
                    neg       $0074
                    clr       $0f,s
                    bra       $07DF
                    fcb       $61
                    jmp       -$07,s
                    bra       L07DC
                    fcb       $72
                    fcb       $72
                    clr       -$0e,s
                    com       L202D
                    bra       L07C1
                    fcb       $42
L0781               clra
                    fcb       $52
                    lsrb
                    neg       $0034
                    nega
L0787               ldd       #$FFA2
                    lbsr      L010F
                    leas      -$0e,s
                    lbsr      L0899
                    std       $0C,s
                    lbne      L087E
                    clra
L0799               clrb
L079A               lbra      L0895
                    lbra      L087E

L07A0               ldd       $003F
                    std       $0a,s
                    ldd       $0041
                    std       $08,s
                    std       ,s
                    ldd       L001F
                    std       $04,s
L07AE               ldd       $0043
                    std       $02,s
                    lbsr      $5F26
                    ldx       $0a,s
                    bra       L07D2

L07B9               ldd       $0a,s
                    cmpd      #$00A0
                    blt       L07C9
L07C1               ldd       $0a,s
                    cmpd      #$00A9
                    ble       L07DE
L07C9               ldd       $08,s
                    addd      #$0001
                    std       ,s
                    bra       L07DE

L07D2               cmpx      #$0064
                    beq       L07DE
                    cmpx      #$0078
                    beq       L07DE
L07DC               bra       L07B9

L07DE               ldd       ,s
                    pshs      d
                    lbsr      $0785
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    lbeq      L0873
                    ldd       $0a,s
                    cmpd      #$0064
                    lbne      L0852
                    ldd       #$002F
                    pshs      d
                    lbsr      L06C1
                    std       ,s++
                    bne       L0847
                    ldd       $0043
                    std       $02,s
                    ldd       L001F
                    std       $04,s
                    ldd       #$0003
                    pshs      d
                    lbsr      $0785
                    leas      $02,s
                    std       $06,s
                    beq       L083C
                    ldd       $02,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    ldd       #$0003
                    pshs      d
                    ldd       $0C,s
                    pshs      d
                    pshs      u
                    ldd       #$002F
                    pshs      d
                    lbsr      L0FD8
                    leas      $0C,s
                    tfr       d,u
                    bra       L0852

L083C               leax      L109C,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
L0847               pshs      u
                    lbsr      L0598
                    leas      $02,s
                    leax      $0e,s
                    bra       L0891

L0852               ldd       $02,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    ldd       $0C,s
                    pshs      d
                    pshs      u
                    ldd       $14,s
                    pshs      d
                    ldd       $14,s
                    pshs      d
                    lbsr      L0FD8
                    leas      $0C,s
                    std       $0C,s
                    bra       L087E

L0873               leax      L10B5,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
L087E               lbsr      L0CA0
                    std       -$02,s
                    beq       L0893
                    ldd       $12,s
                    cmpd      $0041
                    lble      L07A0
                    bra       L0893

L0891               leas      -$0e,x
L0893               ldd       $0C,s
L0895               leas      $0e,s
                    puls      pc,u
L0899               pshs      u
                    ldd       #$FFA4
                    lbsr      L010F
                    leas      -$0C,s
                    ldu       #$0000
                    ldx       $003F
                    lbra      L0A01

L08AB               ldd       $0043
                    pshs      d
                    ldd       L001F
                    pshs      d
                    ldd       $0041
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    ldd       $003F
                    pshs      d
                    lbsr      L0FD8
                    leas      $0C,s
                    tfr       d,u
                    lbsr      $5F26
                    lbra      L0A63

L08D0               lbsr      $5F26
                    lbsr      L05DF
                    std       -$02,s
                    beq       L08FE
                    lbsr      L0F4C
                    tfr       d,u
                    ldd       #$002E
                    pshs      d
                    lbsr      L06C1
                    leas      $02,s
                    bsr       L0899
                    std       $0a,u
                    lbne      L0A63
                    pshs      u
                    lbsr      L05B9
                    leas      $02,s
                    ldu       #$0000
                    lbra      L0A63

L08FE               clra
                    clrb
                    pshs      d
                    lbsr      $0785
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    bne       L0934
                    bra       L0911

L090F               leas      -$0C,x
L0911               lbsr      L101A
                    ldd       $0043
                    pshs      d
                    ldd       L001F
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    lbsr      L0FD8
                    leas      $0C,s
                    tfr       d,u
L0934               ldd       #$002E
                    pshs      d
                    lbsr      L06C1
                    lbra      L09FD

L093F               ldd       $003F
                    std       $08,s
                    ldd       L001F
                    std       $06,s
                    ldd       $0043
                    std       $04,s
                    lbsr      $5F26
                    lbsr      L0899
                    std       $0a,s
                    beq       L097A
                    ldd       $04,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       #$000E
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    ldd       $12,s
                    pshs      d
                    ldd       $12,s
                    pshs      d
                    lbsr      L0FD8
                    leas      $0C,s
                    tfr       d,u
                    lbra      L0A63

L097A               leax      L10C6,pcr
                    pshs      x
                    lbsr      L0450
                    lbra      L09FD

L0986               ldd       L001F
                    std       $06,s
                    ldd       $0043
                    std       $04,s
                    lbsr      $5F26
                    ldd       $003F
                    cmpd      #$002D
                    bne       L09C8
                    lbsr      $5F26
                    lbsr      L05DF
                    std       -$02,s
                    beq       L09AA
                    lbsr      L0F4C
                    std       $0a,s
                    bra       L09BC

L09AA               clra
                    clrb
                    pshs      d
                    lbsr      $0785
                    leas      $02,s
                    std       $0a,s
                    bne       L09BC
                    leax      $0C,s
                    lbra      L090F

L09BC               ldd       #$002E
                    pshs      d
                    lbsr      L06C1
                    leas      $02,s
                    bra       L09CD

L09C8               lbsr      L0899
                    std       $0a,s
L09CD               ldd       $0a,s
                    std       ,s
                    ldd       $04,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    leax      $04,s
                    pshs      x
                    lbsr      L102E
                    std       ,s
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    lbsr      L0FD8
                    leas      $0C,s
                    tfr       d,u
                    ldd       ,s
                    pshs      d
                    lbsr      L0598
L09FD               leas      $02,s
                    bra       L0A63

L0A01               cmpx      #$0037
                    lbeq      L08AB
                    cmpx      #$0034
                    lbeq      L08AB
                    cmpx      #$004A
                    lbeq      L08AB
                    cmpx      #$004B
                    lbeq      L08AB
                    cmpx      #$0036
                    lbeq      L08AB
                    cmpx      #$002D
                    lbeq      L08D0
                    cmpx      #$0040
                    lbeq      L093F
                    cmpx      #$0043
                    lbeq      L093F
                    cmpx      #$0044
                    lbeq      L093F
                    cmpx      #$0042
                    lbeq      L093F
                    cmpx      #$003D
                    lbeq      L093F
                    cmpx      #$003C
                    lbeq      L093F
                    cmpx      #$0041
                    lbeq      L093F
                    cmpx      #$003B
                    lbeq      L0986
L0A63               cmpu      #$0000
                    bne       L0A6E
                    clra
                    clrb
                    lbra      L0BF5

L0A6E               ldx       $003F
                    lbra      L0B94

L0A73               ldd       $0043
                    std       $04,s
                    ldd       L001F
                    std       $06,s
                    lbsr      $5F26
                    ldd       $04,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       #$000F
                    pshs      d
                    lbsr      L0BF9
                    pshs      d
                    pshs      u
                    ldd       #$0065
                    pshs      d
                    lbsr      L0FD8
                    leas      $0C,s
                    tfr       d,u
                    ldd       #$002E
                    lbra      L0B1A

L0AA4               lbsr      $5F26
                    ldd       #$0002
                    pshs      d
                    lbsr      $0785
                    leas      $02,s
                    std       $0a,s
                    bne       L0AD8
                    lbsr      L101A
                    ldd       $0043
                    pshs      d
                    ldd       L001F
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    lbsr      L0FD8
                    leas      $0C,s
                    std       $0a,s
L0AD8               ldd       $0043
                    pshs      d
                    ldd       L001F
                    pshs      d
                    ldd       #$000C
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    pshs      u
                    ldd       #$0050
                    pshs      d
                    lbsr      L0FD8
                    leas      $0C,s
                    tfr       d,u
                    ldd       $0043
                    pshs      d
                    ldd       L001F
                    pshs      d
                    ldd       #$000F
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    pshs      u
                    ldd       #$0042
                    pshs      d
                    lbsr      L0FD8
                    leas      $0C,s
                    tfr       d,u
                    ldd       #$002C
L0B1A               pshs      d
                    lbsr      L06C1
                    leas      $02,s
                    lbra      L0A6E

L0B24               ldd       $003F
                    std       $08,s
                    ldd       L001F
                    std       $06,s
                    ldd       $0043
                    std       $04,s
                    ldd       L0021
                    addd      #$0001
                    std       L0021
                    lbsr      $5F26
                    ldd       L0021
                    addd      #$FFFF
                    std       L0021
                    ldd       $003F
                    cmpd      #$0034
                    beq       L0B4F
                    lbsr      L924A
                    lbra      L0BB0

L0B4F               ldd       $0043
                    pshs      d
                    ldd       L001F
                    pshs      d
                    ldd       $0041
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    ldd       $003F
                    pshs      d
                    lbsr      L0FD8
                    leas      $0C,s
                    std       $0a,s
                    ldd       $04,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       #$000F
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    pshs      u
                    ldd       $12,s
                    pshs      d
                    lbsr      L0FD8
                    leas      $0C,s
                    tfr       d,u
                    lbsr      $5F26
                    lbra      L0A6E

L0B94               cmpx      #$002D
                    lbeq      L0A73
                    cmpx      #$002B
                    lbeq      L0AA4
                    cmpx      #$0045
                    lbeq      L0B24
                    cmpx      #$0046
                    lbeq      L0B24
L0BB0               ldx       $003F
                    bra       L0BE9

L0BB4               ldd       #$003E
                    std       $003F
                    leax      $0C,s
                    bra       L0BC4

L0BBD               ldd       #$003F
                    std       $003F
                    bra       L0BC6

L0BC4               leas      -$0C,x
L0BC6               ldd       $0043
                    pshs      d
                    ldd       L001F
                    pshs      d
                    ldd       #$000E
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    pshs      u
                    ldd       $003F
                    pshs      d
                    lbsr      L0FD8
                    leas      $0C,s
                    tfr       d,u
                    lbsr      $5F26
                    bra       L0BF3

L0BE9               cmpx      #$003C
                    beq       L0BB4
                    cmpx      #$003D
                    beq       L0BBD
L0BF3               tfr       u,d
L0BF5               leas      $0C,s
                    puls      pc,u
L0BF9               pshs      u
                    ldd       #$FFAE
                    lbsr      L010F
                    leas      -$02,s
                    ldu       #$0000
                    bra       L0C08

L0C08               ldd       $003F
                    cmpd      #$002E
                    beq       L0C50
                    ldd       #$0002
                    pshs      d
                    lbsr      $0785
                    leas      $02,s
                    std       ,s
                    beq       L0C43
                    ldx       ,s
                    ldd       $10,x
                    pshs      d
                    ldx       $02,s
                    ldd       $0e,x
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    pshs      u
                    ldd       $08,s
                    pshs      d
                    ldd       #$000B
                    pshs      d
                    lbsr      L0FD8
                    leas      $0C,s
                    std       ,s
                    ldu       ,s
L0C43               ldd       $003F
                    cmpd      #$0030
                    bne       L0C50
                    lbsr      $5F26
                    bra       L0C08

L0C50               tfr       u,d
                    bra       L0C9C

L0C54               pshs      u
                    ldd       #$FFB8
                    lbsr      L010F
                    leas      -$02,s
                    ldd       $06,s
                    pshs      d
                    lbsr      $0785
                    std       ,s
                    lbsr      L111D
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    beq       L0C80
                    ldd       $06,u
                    cmpd      #$0036
                    bne       L0C80
                    ldd       $08,u
                    std       ,s
                    bra       L0C8F

L0C80               clra
                    clrb
                    std       ,s
                    leax      L10D7,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
L0C8F               stu       -$02,s
                    beq       L0C9A
                    pshs      u
                    lbsr      L0598
                    leas      $02,s
L0C9A               ldd       ,s
L0C9C               leas      $02,s
                    puls      pc,u
L0CA0               pshs      u
                    ldd       #$FFC0
                    lbsr      L010F
                    ldx       $003F
                    bra       L0CF9

L0CAC               ldd       #$0057
                    std       $003F
                    ldd       #$0008
                    bra       L0CC8

L0CB6               ldd       #$0052
                    std       $003F
                    ldd       #$000D
                    bra       L0CC8

L0CC0               ldd       #$0051
                    std       $003F
                    ldd       #$000C
L0CC8               std       $0041
L0CCA               ldd       #$0001
                    puls      pc,u
L0CCF               ldd       $003F
                    cmpd      #$0047
                    blt       L0CDF
                    ldd       $003F
                    cmpd      #$005F
                    ble       L0CF3
L0CDF               ldd       $003F
                    cmpd      #$00A0
                    lblt      L0E94
                    ldd       $003F
                    cmpd      #$00A9
                    lbgt      L0E94
L0CF3               ldd       #$0001
                    lbra      L0E96

L0CF9               cmpx      #$0041
                    beq       L0CAC
                    cmpx      #$0042
                    beq       L0CB6
                    cmpx      #$0043
                    beq       L0CC0
                    cmpx      #$0030
                    beq       L0CCA
                    cmpx      #$0078
                    lbeq      L0CCA
                    cmpx      #$0064
                    lbeq      L0CCA
                    cmpx      #$002F
                    lbeq      L0E94
                    bra       L0CCF
                    puls      pc,u
L0D26               pshs      u
                    ldd       #$FFB8
                    lbsr      L010F
                    ldx       $04,s
                    lbra      L0E98

L0D33               ldd       $06,s
                    addd      $08,s
                    puls      pc,u
L0D39               ldd       $06,s
                    subd      $08,s
                    puls      pc,u
L0D3F               ldd       $06,s
                    pshs      d
                    ldd       $0a,s
                    lbsr      LAF4B
                    puls      pc,u
L0D4A               ldd       $08,s
                    beq       L0D68
                    ldd       $06,s
                    pshs      d
                    ldd       $0a,s
                    lbsr      $AFFF
                    bra       L0D66

L0D59               ldd       $08,s
                    beq       L0D68
                    ldd       $06,s
                    pshs      d
                    ldd       $0a,s
                    lbsr      $AFAC
L0D66               puls      pc,u
L0D68               lbsr      L1572
                    lbra      L0E94

L0D6E               ldd       $06,s
                    anda      $08,s
                    andb      $09,s
                    puls      pc,u
L0D76               ldd       $06,s
                    ora       $08,s
                    orb       $09,s
                    puls      pc,u
L0D7E               ldd       $06,s
                    eora      $08,s
                    eorb      $09,s
                    puls      pc,u
L0D86               ldd       $06,s
                    pshs      d
                    ldd       $0a,s
                    lbsr      LB08C
                    puls      pc,u
L0D91               ldd       $06,s
                    pshs      d
                    ldd       $0a,s
                    lbsr      LB069
                    puls      pc,u
L0D9C               ldd       $06,s
                    cmpd      $08,s
                    lbne      L0E94
                    ldd       #$0001
                    lbra      L0E96

L0DAB               ldd       $06,s
                    cmpd      $08,s
                    lbeq      L0E94
                    ldd       #$0001
                    lbra      L0E96

L0DBA               ldd       $06,s
                    cmpd      $08,s
                    lble      L0E94
                    ldd       #$0001
                    lbra      L0E96

L0DC9               ldd       $06,s
                    cmpd      $08,s
                    lbge      L0E94
                    ldd       #$0001
                    lbra      L0E96

L0DD8               ldd       $06,s
                    cmpd      $08,s
                    lblt      L0E94
                    ldd       #$0001
                    lbra      L0E96

L0DE7               ldd       $06,s
                    cmpd      $08,s
                    lbgt      L0E94
                    ldd       #$0001
                    lbra      L0E96

L0DF6               ldd       $06,s
                    nega
                    negb
                    sbca      #$00
                    puls      pc,u
L0DFE               ldd       $06,s
                    lbne      L0E94
                    ldd       #$0001
                    lbra      L0E96

L0E0A               ldd       $06,s
                    coma
                    comb
                    puls      pc,u
L0E10               ldd       $06,s
                    lbeq      L0E94
                    ldd       $08,s
                    lbeq      L0E94
                    ldd       #$0001
                    lbra      L0E96

L0E22               ldd       $06,s
                    bne       L0E2C
                    ldd       $08,s
                    lbeq      L0E94
L0E2C               ldd       #$0001
                    lbra      L0E96

L0E32               leas      -$04,s
                    ldd       $0C,s
                    std       $02,s
                    ldd       $0a,s
                    std       ,s
                    ldx       $08,s
                    bra       L0E76

L0E40               ldd       ,s
                    cmpd      $02,s
                    bhi       L0E70
                    ldd       #$0001
                    bra       L0E72

L0E4C               ldd       ,s
                    cmpd      $02,s
                    bcc       L0E70
                    ldd       #$0001
                    bra       L0E72

L0E58               ldd       ,s
                    cmpd      $02,s
                    bcs       L0E70
                    ldd       #$0001
                    bra       L0E72

L0E64               ldd       ,s
                    cmpd      $02,s
                    bls       L0E70
                    ldd       #$0001
                    bra       L0E72

L0E70               clra
                    clrb
L0E72               leas      $04,s
                    puls      pc,u
L0E76               cmpx      #$0060
                    beq       L0E40
                    cmpx      #$0061
                    beq       L0E4C
                    cmpx      #$0062
                    beq       L0E58
                    bra       L0E64
                    leas      $04,s
L0E89               leax      L10E9,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
L0E94               clra
                    clrb
L0E96               puls      pc,u
L0E98               cmpx      #$0050
                    lbeq      L0D33
                    cmpx      #$0051
                    lbeq      L0D39
                    cmpx      #$0052
                    lbeq      L0D3F
                    cmpx      #$0053
                    lbeq      L0D4A
                    cmpx      #$0054
                    lbeq      L0D59
                    cmpx      #$0057
                    lbeq      L0D6E
                    cmpx      #$0058
                    lbeq      L0D76
                    cmpx      #$0059
                    lbeq      L0D7E
                    cmpx      #$0056
                    lbeq      L0D86
                    cmpx      #$0055
                    lbeq      L0D91
                    cmpx      #$005A
                    lbeq      L0D9C
                    cmpx      #$005B
                    lbeq      L0DAB
                    cmpx      #$005F
                    lbeq      L0DBA
                    cmpx      #$005D
                    lbeq      L0DC9
                    cmpx      #$005E
                    lbeq      L0DD8
                    cmpx      #$005C
                    lbeq      L0DE7
                    cmpx      #$0043
                    lbeq      L0DF6
                    cmpx      #$0040
                    lbeq      L0DFE
                    cmpx      #$0044
                    lbeq      L0E0A
                    cmpx      #$0047
                    lbeq      L0E10
                    cmpx      #$0048
                    lbeq      L0E22
                    cmpx      #$0060
                    lbeq      L0E32
                    cmpx      #$0061
                    lbeq      L0E32
                    cmpx      #$0062
                    lbeq      L0E32
                    cmpx      #$0063
                    lbeq      L0E32
                    lbra      L0E89
                    puls      pc,u
L0F4C               pshs      u
                    ldd       #$FFA2
                    lbsr      L010F
                    leas      -$0e,s
                    ldd       L001F
                    std       $04,s
                    ldd       $0043
                    std       $02,s
                    leax      ,s
                    pshs      x
                    leax      $0C,s
                    pshs      x
                    leax      $10,s
                    pshs      x
                    lbsr      L8BA0
                    leas      $06,s
                    std       $08,s
                    pshs      d
                    leax      $0C,s
                    pshs      x
                    leax      $0a,s
                    pshs      x
                    lbsr      L8EF5
                    leas      $06,s
                    std       $08,s
                    leax      >$0027,y
                    pshs      x
                    lbsr      L916F
                    leas      $02,s
                    ldd       $06,s
                    beq       L0F9D
                    leax      $10FB,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
L0F9D               ldd       $02,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    ldd       #$0020
                    pshs      d
                    bsr       L0FD8
                    leas      $0C,s
                    std       $06,s
                    ldd       $08,s
                    std       [$06,s]
                    ldd       $0C,s
                    pshs      d
                    ldd       $0C,s
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    lbsr      L906B
                    leas      $06,s
                    ldd       $06,s
                    leas      $0e,s
                    puls      pc,u
L0FD8               pshs      u
                    ldd       #$FFBA
                    lbsr      L010F
                    ldd       $000D
                    beq       L0FEC
                    ldu       $000D
                    ldd       $0a,u
                    std       $000D
                    bra       L0FF8

L0FEC               ldd       #$0016
                    pshs      d
                    lbsr      L6622
                    leas      $02,s
                    tfr       d,u
L0FF8               ldd       $04,s
                    std       $06,u
                    ldd       $06,s
                    std       $0a,u
                    ldd       $08,s
                    std       $0C,u
                    ldd       $0a,s
                    std       $08,u
                    ldd       $0C,s
                    std       $0e,u
                    ldd       $0e,s
                    std       $10,u
                    clra
                    clrb
                    std       $14,u
                    tfr       u,d
                    puls      pc,u
L101A               pshs      u
                    ldd       #$FFBA
                    lbsr      L010F
                    leax      L110A,pcr
                    pshs      x
                    lbsr      L0450
                    lbra      L107D

L102E               pshs      u
                    ldd       #$FFB6
                    lbsr      L010F
                    ldu       [$04,s]
                    ldx       $06,u
                    bra       L1081

L103D               pshs      u
                    lbsr      L111D
                    leas      $02,s
                    std       [$04,s]
                    tfr       d,u
                    leax      ,s
                    bra       L105D

L104D               ldd       [$08,u]
                    std       ,u
                    pshs      u
                    lbsr      L26D8
                    leas      $02,s
                    ldu       $08,u
                    bra       L105F

L105D               leas      ,x
L105F               ldd       $04,u
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    ldd       ,u
                    pshs      d
                    lbsr      L90F5
                    leas      $06,s
                    puls      pc,u
L1072               pshs      u
                    ldd       #$000C
                    addd      ,s++
                    pshs      d
                    bsr       L102E
L107D               leas      $02,s
                    puls      pc,u
L1081               cmpx      #$0034
                    beq       L104D
                    cmpx      #$0020
                    beq       L105F
                    cmpx      #$0045
                    beq       L1072
                    cmpx      #$0046
                    lbeq      L1072
                    lbra      L103D
                    puls      pc,u
L109C               lsr       L6869
                    fcb       $72
                    lsr       0,y
                    fcb       $65
                    asl       $7072
                    fcb       $65
                    com       $7369
                    clr       $0e,s
                    bra       L111B
                    rol       -$0d,s
                    com       L696E
                    asr       0,x
L10B5               clr       -$10,s
                    fcb       $65
                    fcb       $72
                    fcb       $61
                    jmp       $04,s
                    bra       $1123
                    asl       L7065
                    com       -$0C,s
                    fcb       $65
                    lsr       0,x
L10C6               neg       L7269
                    tst       $01,s
                    fcb       $72
                    rol       $2065
                    asl       L7065
                    com       -$0C,s
                    fcb       $65
                    lsr       0,x
L10D7               com       $0f,s
                    jmp       -$0d,s
                    lsr       $616E
                    lsr       $2072
                    fcb       $65
                    fcb       $71
                    fcb       $75
                    rol       -$0e,s
                    fcb       $65
                    lsr       0,x
L10E9               com       $0f,s
                    jmp       -$0d,s
                    lsr       $616E
                    lsr       $206F
                    neg       $6572
                    fcb       $61
                    lsr       $6F72
                    neg       $006E
                    fcb       $61
                    tst       $05,s
                    bra       L116A
                    jmp       0,y
                    fcb       $61
                    bra       $1169
                    fcb       $61
                    com       $7400
L110A               fcb       $65
                    asl       $7072
                    fcb       $65
                    com       $7369
                    clr       $0e,s
                    bra       $1183
                    rol       -$0d,s
                    com       L696E
L111B               asr       0,x
L111D               pshs      u
                    ldd       #$FFAE
                    lbsr      L010F
                    ldu       $04,s
                    leas      -$0C,s
                    stu       -$02,s
                    lbeq      L1204
                    ldd       $0a,u
                    pshs      d
                    bsr       L111D
                    leas      $02,s
                    std       $0a,u
                    ldd       $0C,u
                    pshs      d
                    lbsr      L111D
                    leas      $02,s
                    std       $0C,u
                    pshs      u
                    lbsr      L1587
                    leas      $02,s
                    tfr       d,u
                    pshs      u
                    lbsr      L1528
                    std       ,s++
                    beq       L115B
                    leax      $0C,s
                    lbra      L1202

L115B               pshs      u
                    lbsr      L120A
                    leas      $02,s
                    tfr       d,u
                    ldd       $0a,u
                    std       $0a,s
                    ldd       $0C,u
L116A               std       $08,s
                    ldd       $06,u
                    std       $04,s
                    cmpd      #$0064
                    bne       L11B9
                    ldx       $0a,s
                    ldd       $06,x
                    cmpd      #$0036
                    bne       L11B9
                    ldx       $0a,s
                    ldd       $08,x
                    beq       L1192
                    ldx       $08,s
                    ldd       $0a,x
                    std       $02,s
                    ldx       $08,s
                    ldd       $0C,x
                    bra       L119C

L1192               ldx       $08,s
                    ldd       $0C,x
                    std       $02,s
                    ldx       $08,s
                    ldd       $0a,x
L119C               pshs      d
                    lbsr      L0598
                    leas      $02,s
                    ldd       $08,s
                    pshs      d
                    lbsr      L05B9
                    leas      $02,s
                    ldd       $0a,s
                    pshs      d
                    lbsr      L05B9
                    leas      $02,s
                    pshs      u
                    bra       L11F9

L11B9               ldd       $04,s
                    cmpd      #$0042
                    bne       L11CB
                    ldx       $0a,s
                    ldd       $06,x
                    cmpd      #$0041
                    beq       L11DD
L11CB               ldd       $04,s
                    cmpd      #$0041
                    bne       L1204
                    ldx       $0a,s
                    ldd       $06,x
                    cmpd      #$0042
                    bne       L1204
L11DD               ldx       $0a,s
                    ldd       $0a,x
                    std       $02,s
                    ldd       ,u
                    std       [$02,s]
                    ldd       $02,u
                    ldx       $02,s
                    std       $02,x
                    pshs      u
                    lbsr      L05B9
                    leas      $02,s
                    ldd       $0a,s
                    pshs      d
L11F9               lbsr      L05B9
                    leas      $02,s
                    ldu       $02,s
                    bra       L1204

L1202               leas      -$0C,x
L1204               tfr       u,d
                    leas      $0C,s
                    puls      pc,u
L120A               pshs      u
                    ldd       #$FFA8
                    lbsr      L010F
                    ldu       $04,s
                    leas      -$0e,s
                    stu       -$02,s
                    bne       L121F
                    clra
                    clrb
                    lbra      L1524

L121F               ldd       $0a,u
                    std       $0C,s
                    ldd       $0C,u
                    std       $0a,s
                    ldd       $06,u
                    std       $06,s
                    pshs      d
                    lbsr      L06A0
                    std       ,s++
                    bne       L1246
                    ldd       $06,s
                    cmpd      #$0047
                    beq       L1246
                    ldd       $06,s
                    cmpd      #$0048
                    lbne      L145D
L1246               ldx       $0C,s
                    ldd       $06,x
                    cmpd      #$0036
                    bne       L1255
                    ldd       #$0001
                    bra       L1257

L1255               clra
                    clrb
L1257               std       $02,s
                    pshs      d
                    ldx       $0C,s
                    ldd       $06,x
                    cmpd      #$0036
                    bne       L126A
                    ldd       #$0001
                    bra       L126C

L126A               clra
                    clrb
L126C               std       $02,s
                    anda      ,s+
                    andb      ,s+
                    std       -$02,s
                    beq       L127B
                    leax      $0e,s
                    lbra      L146E

L127B               ldd       $02,s
                    beq       L12BB
                    ldx       $06,s
                    bra       L129A

L1283               ldd       $0C,s
                    std       $08,s
                    ldd       $0a,s
                    std       $0C,s
                    std       $0a,u
                    ldd       $08,s
                    std       $0a,s
                    std       $0C,u
                    ldd       #$0001
                    std       ,s
                    bra       L12BB

L129A               cmpx      #$0050
                    beq       L1283
                    cmpx      #$0052
                    lbeq      L1283
                    cmpx      #$0057
                    lbeq      L1283
                    cmpx      #$0058
                    lbeq      L1283
                    cmpx      #$0059
                    lbeq      L1283
L12BB               ldx       $06,s
                    lbra      L1429

L12C0               ldd       ,s
                    lbeq      L1522
                    ldx       $0a,s
                    ldd       $08,x
                    lbeq      L13EE
                    lbra      L1522

L12D1               ldd       ,s
                    lbeq      L1522
                    ldx       $0a,s
                    ldd       $08,x
                    lbeq      L13EE
                    ldx       $0C,s
                    ldx       $06,x
                    lbra      L1338

L12E6               ldx       $0C,s
                    ldx       $0a,x
                    ldd       $14,x
                    leax      $14,x
                    pshs      x,d
                    ldx       $0e,s
                    ldd       $08,x
                    addd      ,s++
                    std       [,s++]
                    bra       L12FE

L12FC               leas      -$0e,x
L12FE               ldd       $0C,s
                    std       $08,s
                    pshs      u
                    lbsr      L05B9
                    leas      $02,s
                    ldd       $0a,s
                    pshs      d
                    lbsr      L05B9
                    leas      $02,s
                    ldu       $08,s
                    lbra      L1522

L1317               ldx       $0C,s
                    ldx       $0C,x
                    ldd       $06,x
                    cmpd      #$0036
                    lbne      L1522
                    ldx       $0C,s
                    ldx       $0C,x
                    ldd       $08,x
                    leax      $08,x
                    pshs      x,d
                    ldx       $0e,s
                    ldd       $08,x
                    addd      ,s++
                    lbra      L13D1

L1338               cmpx      #$0041
                    lbeq      L12E6
                    cmpx      #$0050
                    beq       L1317
                    lbra      L1522

L1347               ldd       ,s
                    beq       L1366
                    ldx       $0a,s
                    ldd       $08,x
                    nega
                    negb
                    sbca      #$00
                    ldx       $0a,s
                    std       $08,x
                    ldd       #$0050
                    std       $06,u
                    pshs      u
                    lbsr      L120A
                    leas      $02,s
                    lbra      L1524

L1366               ldd       $02,s
                    lbeq      L1522
                    ldx       $0C,s
                    ldd       $08,x
                    lbne      L1522
                    ldd       #$0043
                    std       $06,u
                    ldd       $0a,s
                    std       $0a,u
                    clra
                    clrb
                    std       $0C,u
                    ldd       $0C,s
                    lbra      L141F

L1386               ldd       ,s
                    lbeq      L1522
                    ldx       $0a,s
                    ldd       $08,x
                    beq       L13A1
                    lbra      L1522

L1395               ldd       ,s
                    lbeq      L1522
                    ldx       $0a,s
                    ldx       $08,x
                    bra       L13D5

L13A1               leax      $0e,s
                    lbra      L1403

L13A6               ldx       $0C,s
                    ldd       $06,x
                    cmpd      #$0052
                    lbne      L1522
                    ldx       $0C,s
                    ldx       $0C,x
                    ldd       $06,x
                    cmpd      #$0036
                    lbne      L1522
                    ldx       $0C,s
                    ldx       $0C,x
                    ldd       $08,x
                    leax      $08,x
                    pshs      x,d
                    ldx       $0e,s
                    ldd       $08,x
                    lbsr      LAF4B
L13D1               std       [,s++]
                    bra       L13EE

L13D5               stx       -$02,s
                    beq       L13A1
                    cmpx      #$0001
                    beq       L13EE
                    bra       L13A6

L13E0               ldd       ,s
                    beq       L13F3
                    ldx       $0a,s
                    ldd       $08,x
                    cmpd      #$0001
                    bne       L13F3
L13EE               leax      $0e,s
                    lbra      L12FC

L13F3               ldd       $02,s
                    lbeq      L1522
                    ldx       $0C,s
                    ldd       $08,x
                    lbne      L1522
                    bra       L1405

L1403               leas      -$0e,x
L1405               ldd       #$0036
                    std       $06,u
                    clra
                    clrb
L140C               std       $08,u
                    clra
                    clrb
                    std       $0C,u
                    std       $0a,u
                    ldd       $0C,s
                    pshs      d
                    lbsr      L05B9
                    leas      $02,s
                    ldd       $0a,s
L141F               pshs      d
                    lbsr      L05B9
L1424               leas      $02,s
                    lbra      L1522

L1429               cmpx      #$0058
                    lbeq      L12C0
                    cmpx      #$0059
                    lbeq      L12C0
                    cmpx      #$0050
                    lbeq      L12D1
                    cmpx      #$0051
                    lbeq      L1347
                    cmpx      #$0057
                    lbeq      L1386
                    cmpx      #$0052
                    lbeq      L1395
                    cmpx      #$0053
                    lbeq      L13E0
                    lbra      L1522

L145D               ldx       $06,s
                    lbra      L150D

L1462               ldx       $0C,s
                    ldd       $06,x
                    cmpd      #$0036
                    bne       L1492
                    bra       L1470

L146E               leas      -$0e,x
L1470               ldd       #$0036
                    std       $06,u
                    clra
                    clrb
                    std       $12,u
                    ldx       $0a,s
                    ldd       $08,x
                    pshs      d
                    ldx       $0e,s
                    ldd       $08,x
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    lbsr      L0D26
                    leas      $06,s
                    lbra      L140C

L1492               ldx       $0C,s
                    ldd       $06,x
                    cmpd      #$004A
                    bne       L14E1
                    leas      -$02,s
                    ldx       $0e,s
                    ldd       $08,x
                    std       ,s
                    bne       L14B2
                    ldd       #$0004
                    pshs      d
                    lbsr      L6622
                    leas      $02,s
                    std       ,s
L14B2               ldx       $08,s
                    bra       L14CF

L14B6               ldx       ,s
                    pshs      x
                    ldx       $02,s
                    lbsr      LAE9F
                    bra       L14CA

L14C1               ldx       ,s
                    pshs      x
                    ldx       $02,s
                    lbsr      LAEB3
L14CA               lbsr      LAEDF
                    bra       L14D9

L14CF               cmpx      #$0043
                    beq       L14B6
                    cmpx      #$0044
                    beq       L14C1
L14D9               ldd       ,s
                    ldx       $0e,s
                    std       $08,x
                    bra       L1501

L14E1               ldx       $0C,s
                    ldd       $06,x
                    cmpd      #$004B
                    bne       L1522
                    leas      -$02,s
                    ldx       $0e,s
                    ldd       $08,x
                    std       ,s
                    beq       L1501
                    ldx       ,s
                    pshs      x
                    ldx       $02,s
                    lbsr      $A74C
                    lbsr      $AE34
L1501               pshs      u
                    lbsr      L05B9
                    leas      $02,s
                    ldu       $0e,s
                    lbra      L1424

L150D               cmpx      #$0040
                    lbeq      L1462
                    cmpx      #$0044
                    lbeq      L1462
                    cmpx      #$0043
                    lbeq      L1462
L1522               tfr       u,d
L1524               leas      $0e,s
                    puls      pc,u
L1528               pshs      u
                    ldd       #$FFC0
                    lbsr      L010F
                    ldu       $04,s
                    stu       -$02,s
                    beq       L156E
                    ldx       $06,u
                    bra       L153F

L153A               ldd       #$0001
                    puls      pc,u
L153F               cmpx      #$0076
                    beq       L153A
                    cmpx      #$006F
                    lbeq      L153A
                    cmpx      #$0036
                    lbeq      L153A
                    cmpx      #$004A
                    lbeq      L153A
                    cmpx      #$004B
                    lbeq      L153A
                    cmpx      #$0034
                    lbeq      L153A
                    cmpx      #$0037
                    lbeq      L153A
L156E               clra
                    clrb
                    puls      pc,u
L1572               pshs      u
                    ldd       #$FFBA
                    lbsr      L010F
                    leax      L287A,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
                    puls      pc,u
L1587               pshs      u
                    ldd       #$FF9C
                    lbsr      L010F
                    leas      -$14,s
                    ldx       $18,s
                    ldu       $0a,x
                    ldx       $18,s
                    ldd       $0C,x
                    std       $12,s
                    ldd       #$0002
                    std       $0a,s
                    std       $08,s
                    clra
                    clrb
                    std       $06,s
                    ldd       #$0001
                    std       $0C,s
                    ldx       $18,s
                    ldd       $06,x
                    std       $0e,s
                    tfr       d,x
                    lbra      L204E

L15BB               ldx       $18,s
                    ldd       $08,x
                    std       $10,s
                    ldx       $10,s
                    ldd       $08,x
                    cmpd      #$001E
                    bne       L15EB
                    leax      L2889,pcr
                    pshs      x
                    ldd       $1a,s
                    pshs      d
                    lbsr      L0498
                    leas      $04,s
                    ldd       $18,s
                    pshs      d
                    lbsr      L27EB
                    leas      $02,s
                    lbra      L2170

L15EB               ldd       [$10,s]
                    std       $0C,s
                    ldx       $10,s
                    ldd       $04,x
                    std       $06,s
                    ldd       $0C,s
                    clra
                    andb      #$0f
                    cmpd      #$000A
                    bne       L162C
                    leas      -$02,s
                    ldx       $12,s
                    ldd       $02,x
                    std       ,s
                    ldd       $0e,s
                    andb      #$F0
                    addd      [,s]
                    std       [$12,s]
                    std       $0e,s
                    ldx       ,s
                    ldd       $02,x
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    ldd       $16,s
                    pshs      d
                    lbsr      L906B
                    leas      $06,s
                    leas      $02,s
L162C               ldx       $10,s
                    ldd       $02,x
                    std       $0a,s
                    ldd       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    beq       L164B
                    ldd       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0030
                    lbne      L16AE
L164B               ldu       $18,s
                    ldd       $0a,s
                    std       $02,u
                    ldx       $18,s
                    ldd       $10,x
                    pshs      d
                    ldx       $1a,s
                    ldd       $0e,x
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    pshs      u
                    ldd       #$0041
                    pshs      d
                    lbsr      L0FD8
                    leas      $0C,s
                    std       $18,s
                    ldd       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    bne       L1699
                    ldd       $06,s
                    pshs      d
                    lbsr      L06B5
                    leas      $02,s
                    std       $06,s
                    ldd       $0C,s
                    pshs      d
                    lbsr      L067C
                    leas      $02,s
                    bra       L169B

L1699               ldd       $0C,s
L169B               std       ,u
                    pshs      d
                    lbsr      L0688
                    leas      $02,s
                    std       $0C,s
                    ldd       #$0001
                    std       $12,u
                    bra       L16D5

L16AE               ldx       $10,s
                    ldd       $08,x
                    std       $04,s
                    tfr       d,x
                    bra       L16C9

L16B9               ldd       $04,s
                    ldx       $18,s
                    std       $06,x
                    clra
                    clrb
                    ldx       $18,s
                    std       $08,x
                    bra       L16D5

L16C9               cmpx      #$0076
                    beq       L16B9
                    cmpx      #$006F
                    lbeq      L16B9
L16D5               ldd       #$0001
                    bra       L16DC

L16DA               clra
                    clrb
L16DC               std       $08,s
                    lbra      L2170

L16E1               ldd       #$0008
                    std       $0C,s
                    ldd       #$0001
                    std       $08,s
                    ldd       #$0004
                    lbra      L1846

L16F1               ldd       #$0006
                    std       $0C,s
                    ldd       #$0001
                    std       $08,s
                    ldd       #$0008
                    lbra      L1846

L1701               ldd       #$0012
                    std       $0C,s
                    ldd       #$0001
                    lbra      L1846

L170C               pshs      u
                    lbsr      L26D8
                    leas      $02,s
                    ldd       [$18,s]
                    std       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0030
                    beq       L172C
                    ldd       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    bne       L1747
L172C               leax      $28A2,pcr
                    pshs      x
                    ldd       $1a,s
                    pshs      d
                    lbsr      L0498
                    leas      $04,s
                    ldd       $0C,s
                    pshs      d
                    lbsr      L0688
                    leas      $02,s
                    std       $0C,s
L1747               ldd       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L1760
                    ldd       #$0001
                    pshs      d
                    pshs      u
                    lbsr      L222C
                    leas      $04,s
                    bra       L176D

L1760               ldd       $0C,s
                    pshs      d
                    pshs      u
                    lbsr      L222C
                    leas      $04,s
                    std       $0C,s
L176D               ldx       $18,s
                    ldd       $04,x
                    std       $06,s
                    ldx       $18,s
                    ldd       $02,x
                    std       $0a,s
                    ldd       $18,s
                    pshs      d
                    lbsr      L05B9
                    leas      $02,s
                    stu       $18,s
                    lbra      L2170

L178B               ldd       #$0001
                    pshs      d
                    pshs      u
                    lbsr      L2668
                    leas      $04,s
                    ldd       $06,u
                    cmpd      #$0076
                    beq       L17A7
                    ldd       $06,u
                    cmpd      #$006F
                    bne       L17BE
L17A7               leax      L28AE,pcr
                    pshs      x
                    ldd       $1a,s
                    pshs      d
                    lbsr      L0498
                    leas      $04,s
                    pshs      u
                    lbsr      L27EB
                    leas      $02,s
L17BE               ldd       $12,u
                    std       $08,s
                    ldd       $02,u
                    std       $0a,s
                    ldd       ,u
                    pshs      d
                    lbsr      L0688
                    leas      $02,s
                    std       $0C,s
                    ldd       $04,u
                    std       $06,s
                    lbra      L2170

L17D9               ldd       $04,u
                    std       $06,s
                    ldd       ,u
                    std       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L181D
                    ldd       $0C,s
                    pshs      d
                    lbsr      L067C
                    leas      $02,s
                    std       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    bne       L183F
                    ldd       $0C,s
                    pshs      d
                    lbsr      L067C
                    std       ,s
                    lbsr      L0688
                    leas      $02,s
                    std       $0C,s
                    ldd       $18,s
                    pshs      d
                    lbsr      L05B9
                    leas      $02,s
                    stu       $18,s
                    bra       L183F

L181D               leax      L28C1,pcr
                    pshs      x
                    pshs      u
                    lbsr      L0498
                    leas      $04,s
                    pshs      u
                    lbsr      L27EB
                    leas      $02,s
                    ldd       #$0011
                    std       ,u
                    ldd       #$0001
                    std       $0C,s
                    clra
                    clrb
                    std       $06,s
L183F               ldd       $12,u
                    std       $08,s
                    ldd       $02,u
L1846               std       $0a,s
                    lbra      L2170

L184B               leax      ,s
                    pshs      x
                    leax      $0e,s
                    pshs      x
                    ldd       $16,s
                    pshs      d
                    lbsr      L2707
                    leas      $06,s
                    std       $0a,s
                    ldx       $12,s
                    ldd       $04,x
                    std       $06,s
                    ldd       #$0001
                    pshs      d
                    pshs      u
                    lbsr      L2668
                    leas      $04,s
                    ldx       $12,s
                    ldd       $08,x
                    bne       L189F
                    ldd       ,s
                    bne       L189F
                    ldd       $12,s
                    pshs      d
                    lbsr      L05B9
                    leas      $02,s
                    ldd       $18,s
                    pshs      d
                    lbsr      L05B9
                    leas      $02,s
                    stu       $18,s
                    ldx       $18,s
                    ldd       $12,x
                    std       $08,s
                    lbra      L1902

L189F               ldd       $12,u
                    std       $08,s
                    ldd       $06,u
                    cmpd      #$0042
                    bne       L18C4
                    ldd       $0a,u
                    std       $10,s
                    pshs      u
                    lbsr      L05B9
                    leas      $02,s
                    ldu       $10,s
                    tfr       u,d
                    ldx       $18,s
                    std       $0a,x
                    bra       L18F7

L18C4               ldd       ,u
                    std       $04,s
                    ldd       $10,u
                    pshs      d
                    ldd       $0e,u
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    pshs      u
                    ldd       #$0041
                    pshs      d
                    lbsr      L0FD8
                    leas      $0C,s
                    ldx       $18,s
                    std       $0a,x
                    tfr       d,u
                    ldd       $04,s
                    pshs      d
                    lbsr      L0688
                    leas      $02,s
                    std       ,u
L18F7               ldd       $08,s
                    std       $12,u
                    leax      $14,s
                    lbra      L1960

L1902               lbra      L2170

L1905               leax      ,s
                    pshs      x
                    leax      $0e,s
                    pshs      x
                    ldd       $16,s
                    pshs      d
                    lbsr      L2707
                    leas      $06,s
                    std       $0a,s
                    ldx       $12,s
                    ldd       $04,x
                    std       $06,s
                    ldd       ,u
                    std       $04,s
                    cmpd      #$0001
                    beq       L1959
                    ldd       $04,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L193A
                    ldd       #$0001
                    bra       L193C

L193A               clra
                    clrb
L193C               bne       L1959
                    leax      L28D2,pcr
                    pshs      x
                    pshs      u
                    lbsr      L0498
                    leas      $04,s
                    ldd       #$0036
                    std       $06,u
                    clra
                    clrb
                    std       $08,u
                    clra
                    clrb
                    std       $12,u
L1959               ldd       $12,u
                    std       $08,s
                    bra       L1963

L1960               leas      -$14,x
L1963               ldd       #$0050
                    ldx       $18,s
                    std       $06,x
                    ldd       $18,s
                    pshs      d
                    lbsr      L120A
                    leas      $02,s
                    std       $18,s
                    ldd       ,s
                    bne       L19C0
                    ldd       $0C,s
                    pshs      d
                    lbsr      L0688
                    leas      $02,s
                    std       [$18,s]
                    ldd       $08,s
                    ldx       $18,s
                    std       $12,x
                    ldd       $0a,s
                    ldx       $18,s
                    std       $02,x
                    ldx       $18,s
                    ldd       $10,x
                    pshs      d
                    ldx       $1a,s
                    ldd       $0e,x
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    ldd       $20,s
                    pshs      d
                    ldd       #$0042
                    pshs      d
                    lbsr      L0FD8
                    leas      $0C,s
                    std       $18,s
L19C0               lbra      L2170

L19C3               ldd       ,u
                    std       $0C,s
                    ldd       $06,u
                    cmpd      #$0041
                    bne       L19FF
                    ldd       $0C,s
                    pshs      d
                    lbsr      L067C
                    leas      $02,s
                    clra
                    andb      #$30
                    cmpd      #$0030
                    bne       L19FF
                    ldd       $0a,u
                    ldx       $18,s
                    std       $0a,x
                    std       $10,s
                    pshs      u
                    lbsr      L05B9
                    leas      $02,s
                    ldd       [$10,s]
L19F5               pshs      d
                    lbsr      L067C
                    leas      $02,s
                    lbra      L1A63

L19FF               ldd       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0030
                    bne       L1A0E
                    ldd       $0C,s
                    bra       L19F5

L1A0E               ldd       $0C,s
                    bne       L1A51
                    ldd       $08,u
                    std       $10,s
                    ldd       #$0031
                    std       [$10,s]
                    ldd       #$0002
                    ldx       $10,s
                    std       $02,x
                    clra
                    clrb
                    ldx       $10,s
                    std       $04,x
                    ldd       #$000E
                    ldx       $10,s
                    std       $08,x
                    clra
                    clrb
                    ldx       $10,s
                    std       $0C,x
                    ldd       #$0006
                    pshs      d
                    pshs      u
                    ldd       $14,s
                    pshs      d
                    lbsr      L03FB
                    leas      $06,s
                    ldd       #$0001
                    bra       L1A63

L1A51               leax      L28EE,pcr
                    pshs      x
                    pshs      u
                    lbsr      L0498
                    leas      $04,s
                    ldd       $0C,s
                    clra
                    andb      #$0f
L1A63               std       $0C,s
                    ldd       $04,u
                    std       $06,s
                    ldd       $02,u
                    std       $0a,s
L1A6D               pshs      u
                    lbsr      L26D8
                    leas      $02,s
                    pshs      u
                    lbsr      L27BA
                    leas      $02,s
                    ldx       ,u
                    bra       L1A92

L1A7F               ldd       #$0001
                    bra       L1A87

L1A84               ldd       #$0006
L1A87               pshs      d
                    pshs      u
                    lbsr      L222C
                    leas      $04,s
                    bra       L1A9C

L1A92               cmpx      #$0002
                    beq       L1A7F
                    cmpx      #$0005
                    beq       L1A84
L1A9C               lbra      L2170

L1A9F               ldx       $12,s
                    ldd       $02,x
                    std       $0a,s
                    ldd       [$12,s]
                    std       $0C,s
                    ldx       $12,s
                    ldd       $04,x
                    std       $06,s
                    lbra      L2170

L1AB5               ldd       ,u
                    clra
                    andb      #$30
                    cmpd      #$0010
                    beq       L1AC7
                    pshs      u
                    lbsr      L21C1
                    leas      $02,s
L1AC7               ldd       #$0001
                    lbra      L2012

L1ACD               pshs      u
                    lbsr      L21C1
                    leas      $02,s
                    lbra      L2012

L1AD7               pshs      u
                    lbsr      L21C1
                    leas      $02,s
                    std       $0C,s
                    cmpd      #$0006
                    lbne      L1BC8
                    pshs      u
                    lbsr      L2861
                    leas      $02,s
                    pshs      u
                    lbra      L1BC3

L1AF4               clra
                    clrb
                    pshs      d
                    pshs      u
                    lbsr      L2668
                    leas      $04,s
                    ldd       $02,u
                    std       $0a,s
                    ldd       ,u
                    std       $0C,s
                    clra
                    andb      #$30
                    beq       L1B25
                    ldd       $04,u
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    lbsr      L067C
                    std       ,s
                    lbsr      L90F5
                    leas      $06,s
                    bra       L1B28

L1B25               ldd       #$0001
L1B28               ldx       $18,s
                    std       $08,x
                    ldd       $12,u
                    std       $08,s
                    ldd       $06,u
                    cmpd      #$0042
                    lbne      L1CAC
                    ldd       $08,s
                    addd      #$0001
                    lbra      L1CAA

L1B44               ldd       ,u
                    clra
                    andb      #$30
                    cmpd      #$0010
                    beq       L1B56
                    pshs      u
                    lbsr      L21C1
                    leas      $02,s
L1B56               ldd       [$12,s]
                    clra
                    andb      #$30
                    cmpd      #$0010
                    lbeq      L1BC8
                    ldd       $12,s
                    pshs      d
                    lbsr      L21C1
                    bra       L1BC6

L1B6E               ldd       $12,s
                    pshs      d
                    pshs      u
                    lbsr      L2545
                    leas      $04,s
                    std       $0C,s
                    cmpd      #$0006
                    bne       L1B87
                    leax      $14,s
                    bra       L1BAB

L1B87               lbra      L2170

L1B8A               pshs      u
                    lbsr      L21C1
                    leas      $02,s
                    std       $0C,s
                    cmpd      #$0006
                    beq       L1BAE
                    ldd       $12,s
                    pshs      d
                    lbsr      L21C1
                    leas      $02,s
                    cmpd      #$0006
                    bne       L1BCB
                    bra       L1BAE

L1BAB               leas      -$14,x
L1BAE               leax      L28FD,pcr
                    pshs      x
                    ldd       $1a,s
                    pshs      d
                    lbsr      L0498
                    leas      $04,s
                    ldd       $18,s
                    pshs      d
L1BC3               lbsr      L27EB
L1BC6               leas      $02,s
L1BC8               lbra      L2170

L1BCB               ldd       #$0001
                    pshs      d
                    ldd       $14,s
                    pshs      d
                    lbsr      L222C
                    lbra      L1C54

L1BDB               ldd       ,u
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L1BF2
                    ldd       [$12,s]
                    clra
                    andb      #$30
                    cmpd      #$0010
                    beq       L1C04
L1BF2               ldd       $12,s
                    pshs      d
                    pshs      u
                    lbsr      L2545
                    leas      $04,s
                    cmpd      #$0007
                    bne       L1C0E
L1C04               ldd       $0e,s
                    addd      #$0004
                    ldx       $18,s
                    std       $06,x
L1C0E               lbra      L2170

L1C11               ldd       ,u
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L1C4A
                    ldd       [$12,s]
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L1C2D
                    ldd       #$0001
                    bra       L1C2F

L1C2D               clra
                    clrb
L1C2F               bne       L1C56
                    ldd       $12,s
                    pshs      d
                    lbsr      L21C1
                    leas      $02,s
                    ldd       #$0001
                    pshs      d
                    ldd       $14,s
                    pshs      d
                    lbsr      L222C
                    bra       L1C54

L1C4A               ldd       $12,s
                    pshs      d
                    pshs      u
                    lbsr      L2545
L1C54               leas      $04,s
L1C56               lbra      L2170

L1C59               ldd       [$12,s]
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L1C78
                    leas      -$02,s
                    stu       ,s
                    ldu       $14,s
                    ldd       ,s
                    std       $14,s
                    leas      $02,s
                    ldx       $18,s
                    stu       $0a,x
L1C78               ldd       $02,u
                    std       $0a,s
                    ldd       ,u
                    std       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L1C93
                    ldd       $04,u
                    std       $06,s
                    leax      $14,s
                    lbra      L1D92

L1C93               ldd       $12,s
                    pshs      d
                    pshs      u
                    lbsr      L2545
                    leas      $04,s
                    std       $0C,s
                    ldd       $12,u
                    ldx       $12,s
                    addd      $12,x
L1CAA               std       $08,s
L1CAC               lbra      L2170

L1CAF               ldd       $12,u
                    ldx       $12,s
                    addd      $12,x
                    std       $08,s
                    ldd       ,u
                    std       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    lbne      L2006
                    ldd       $02,u
                    std       $0a,s
                    ldd       $04,u
                    std       $06,s
                    ldd       [$12,s]
                    clra
                    andb      #$30
                    cmpd      #$0010
                    lbne      L1D95
                    ldd       $08,s
                    ldx       $18,s
                    std       $12,x
                    ldd       $0C,s
                    cmpd      [$12,s]
                    bne       L1CF9
                    ldd       $0a,s
                    ldx       $12,s
                    cmpd      $02,x
                    beq       L1D0C
L1CF9               leax      L2913,pcr
                    pshs      x
                    ldd       $1a,s
                    pshs      d
                    lbsr      L0498
                    leas      $04,s
                    lbra      L1D83

L1D0C               ldd       $0C,s
                    pshs      d
                    lbsr      L067C
                    leas      $02,s
                    std       $0C,s
                    ldd       $06,s
                    pshs      d
                    ldd       $0C,s
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    lbsr      L90F5
                    leas      $06,s
                    std       $0a,s
                    cmpd      #$0001
                    lbeq      L1D83
                    ldd       #$0002
                    std       $08,s
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    lbsr      L0FD8
                    leas      $0C,s
                    std       $10,s
                    ldx       $18,s
                    ldd       $10,x
                    pshs      d
                    ldx       $1a,s
                    ldd       $0e,x
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    ldd       $16,s
                    pshs      d
                    ldd       $20,s
                    pshs      d
                    ldd       #$0053
                    pshs      d
                    lbsr      L0FD8
                    leas      $0C,s
                    std       $18,s
L1D83               ldd       #$0002
                    std       $0a,s
                    clra
                    clrb
                    std       $06,s
                    ldd       #$0001
                    lbra      L2012

L1D92               leas      -$14,x
L1D95               ldd       $12,s
                    pshs      d
                    lbsr      L21C1
                    leas      $02,s
                    ldd       [$12,s]
                    pshs      d
                    lbsr      L2832
                    std       ,s++
                    bne       L1DBF
                    ldd       $12,s
                    pshs      d
                    lbsr      L2861
                    leas      $02,s
                    ldd       $12,s
                    pshs      d
                    lbsr      L27EB
                    leas      $02,s
L1DBF               ldd       #$0001
                    pshs      d
                    ldd       $14,s
                    pshs      d
                    lbsr      L222C
                    leas      $04,s
                    ldd       $12,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    lbsr      L25C9
                    leas      $08,s
                    ldx       $18,s
                    std       $0C,x
                    ldd       $12,u
                    ldx       $12,s
                    addd      $12,x
                    std       $08,s
                    lbra      L2170

L1DF9               clra
                    clrb
                    pshs      d
                    pshs      u
                    lbsr      L2668
                    leas      $04,s
                    ldd       $12,s
                    pshs      d
                    lbsr      L26D8
                    leas      $02,s
                    ldd       $12,s
                    pshs      d
                    lbsr      L27BA
                    leas      $02,s
                    std       $02,s
                    ldd       ,u
                    std       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L1E3F
                    ldd       $02,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    beq       L1E3F
                    ldd       $02,s
                    pshs      d
                    lbsr      L2832
                    std       ,s++
                    lbeq      L1EBF
L1E3F               ldd       $02,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L1E62
                    ldd       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    beq       L1E62
                    ldd       $0C,s
                    pshs      d
                    lbsr      L2832
                    std       ,s++
                    lbeq      L1EBF
L1E62               ldd       $0C,s
                    pshs      d
                    ldd       $14,s
                    pshs      d
                    lbsr      L222C
                    leas      $04,s
                    leax      $14,s
                    lbra      L1F54

L1E76               leas      -$14,x
                    clra
                    clrb
                    pshs      d
                    pshs      u
                    lbsr      L2668
                    leas      $04,s
                    ldd       $12,s
                    pshs      d
                    lbsr      L21C1
                    leas      $02,s
                    ldd       $12,s
                    pshs      d
                    lbsr      L27BA
                    leas      $02,s
                    std       $02,s
                    ldd       ,u
                    std       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L1ED3
                    ldx       $0e,s
                    bra       L1EC5

L1EAB               ldd       #$0001
                    pshs      d
                    ldd       $14,s
                    pshs      d
                    lbsr      L222C
                    leas      $04,s
                    leax      $14,s
                    bra       L1EF5

L1EBF               leax      $14,s
                    lbra      L1F6B

L1EC5               cmpx      #$00A1
                    beq       L1EAB
                    cmpx      #$00A0
                    lbeq      L1EAB
                    bra       L1EBF

L1ED3               ldx       $0e,s
                    lbra      L1F45

L1ED8               ldd       $0C,s
                    cmpd      #$0005
                    bne       L1EE5
                    ldd       #$0006
                    bra       L1EE7

L1EE5               ldd       $0C,s
L1EE7               pshs      d
                    ldd       $14,s
                    pshs      d
                    lbsr      L222C
                    leas      $04,s
                    bra       L1EF8

L1EF5               leas      -$14,x
L1EF8               ldd       $0e,s
                    addd      #$FFB0
                    ldx       $18,s
                    std       $06,x
                    ldd       $18,s
                    pshs      d
                    lbsr      L1587
                    leas      $02,s
                    std       $18,s
                    ldd       $0C,s
                    cmpd      #$0002
                    bne       L1F2F
                    ldd       $0a,u
                    ldx       $18,s
                    std       $0a,x
                    pshs      u
                    lbsr      L05B9
                    leas      $02,s
                    ldx       $18,s
                    ldu       $0a,x
                    ldd       #$0001
                    std       $0C,s
L1F2F               ldd       $0e,s
                    addd      #$FFB0
                    ldx       $18,s
                    cmpd      $06,x
                    bne       L1F57
                    ldd       $0e,s
                    ldx       $18,s
                    std       $06,x
                    bra       L1F57

L1F45               cmpx      #$00A6
                    beq       L1EF8
                    cmpx      #$00A5
                    lbeq      L1EF8
                    lbra      L1ED8

L1F54               leas      -$14,x
L1F57               ldd       $02,u
                    std       $0a,s
                    ldd       $12,u
                    ldx       $12,s
                    addd      $12,x
                    std       $08,s
                    ldd       $04,u
                    lbra      L2028

L1F6B               leas      -$14,x
                    leax      $2924,pcr
                    pshs      x
                    ldd       $1a,s
                    pshs      d
                    lbsr      L0498
                    lbra      L2049

L1F7F               ldd       ,u
                    std       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L1FDE
                    ldd       $02,u
                    std       $0a,s
                    ldd       $12,u
                    std       $08,s
                    ldd       $02,u
                    std       $06,s
                    ldd       [$12,s]
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L1FD1
                    ldd       $0C,s
                    cmpd      [$12,s]
                    bne       L1FB7
                    ldd       $02,u
                    ldx       $12,s
                    cmpd      $02,x
                    beq       L1FCA
L1FB7               leax      $2932,pcr
                    pshs      x
                    ldd       $1a,s
                    pshs      d
                    lbsr      L0498
                    leas      $04,s
                    lbra      L2170

L1FCA               clra
                    clrb
                    std       $06,s
                    lbra      L2170

L1FD1               ldd       $12,s
                    pshs      d
L1FD6               lbsr      L2193
                    leas      $02,s
                    lbra      L2170

L1FDE               ldd       [$12,s]
                    std       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L2006
                    ldx       $12,s
                    ldd       $02,x
                    std       $0a,s
                    ldx       $12,s
                    ldd       $12,x
                    std       $08,s
                    ldx       $12,s
                    ldd       $04,x
L2000               std       $06,s
                    pshs      u
                    bra       L1FD6

L2006               ldd       $12,s
                    pshs      d
                    pshs      u
                    lbsr      L2545
                    leas      $04,s
L2012               std       $0C,s
                    lbra      L2170

L2017               ldd       [$12,s]
                    std       $0C,s
                    ldx       $12,s
                    ldd       $02,x
                    std       $0a,s
                    ldx       $12,s
                    ldd       $04,x
L2028               std       $06,s
L202A               lbra      L2170

L202D               ldd       $0e,s
                    cmpd      #$00A0
                    blt       L203B
                    leax      $14,s
                    lbra      L1E76

L203B               leax      $2943,pcr
                    pshs      x
                    ldd       $1a,s
                    pshs      d
                    lbsr      L0464
L2049               leas      $04,s
                    lbra      L2170

L204E               cmpx      #$0034
                    lbeq      L15BB
                    cmpx      #$0036
                    lbeq      L16DA
                    cmpx      #$004A
L205F               lbeq      L16E1
                    cmpx      #$004B
L2066               lbeq      L16F1
                    cmpx      #$0037
                    lbeq      L1701
                    cmpx      #$0020
L2074               lbeq      L170C
L2078               cmpx      #$0041
                    lbeq      L178B
                    cmpx      #$0042
                    lbeq      L17D9
                    cmpx      #$0045
                    lbeq      L184B
                    cmpx      #$0046
                    lbeq      L1905
                    cmpx      #$0065
                    lbeq      L19C3
                    cmpx      #$000B
                    lbeq      L1A6D
                    cmpx      #$0030
                    lbeq      L1A9F
                    cmpx      #$0040
                    lbeq      L1AB5
                    cmpx      #$0043
                    lbeq      L1ACD
                    cmpx      #$0044
                    lbeq      L1AD7
                    cmpx      #$003C
                    lbeq      L1AF4
                    cmpx      #$003E
                    lbeq      L1AF4
                    cmpx      #$003D
                    lbeq      L1AF4
                    cmpx      #$003F
                    lbeq      L1AF4
                    cmpx      #$0047
                    lbeq      L1B44
                    cmpx      #$0048
                    lbeq      L1B44
                    cmpx      #$0053
                    lbeq      L2006
                    cmpx      #$0052
                    lbeq      L2006
                    cmpx      #$0057
                    lbeq      L1B6E
                    cmpx      #$0058
                    lbeq      L1B6E
                    cmpx      #$0059
                    lbeq      L1B6E
                    cmpx      #$0054
                    lbeq      L1B6E
                    cmpx      #$0056
                    lbeq      L1B8A
                    cmpx      #$0055
                    lbeq      L1B8A
                    cmpx      #$005D
                    lbeq      L1BDB
                    cmpx      #$005F
                    lbeq      L1BDB
                    cmpx      #$005C
                    lbeq      L1BDB
                    cmpx      #$005E
                    lbeq      L1BDB
                    cmpx      #$005A
                    lbeq      L1C11
                    cmpx      #$005B
                    lbeq      L1C11
                    cmpx      #$0050
                    lbeq      L1C59
                    cmpx      #$0051
                    lbeq      L1CAF
                    cmpx      #$0078
                    lbeq      L1DF9
                    cmpx      #$002F
                    lbeq      L1F7F
                    cmpx      #$0064
                    lbeq      L2017
                    lbra      L202D

L2170               ldd       $0C,s
                    std       [$18,s]
                    ldd       $0a,s
                    ldx       $18,s
                    std       $02,x
                    ldd       $08,s
                    ldx       $18,s
                    std       $12,x
                    ldd       $06,s
                    ldx       $18,s
                    std       $04,x
                    ldd       $18,s
                    leas      $14,s
                    puls      pc,u
L2193               pshs      u
                    ldd       #$FFB8
                    lbsr      L010F
                    ldu       $04,s
                    ldd       $06,u
                    cmpd      #$0036
                    bne       L21A9
                    ldd       $08,u
                    beq       L21BF
L21A9               leax      $294E,pcr
                    pshs      x
                    pshs      u
                    lbsr      L0498
                    leas      $04,s
                    ldd       #$0036
                    std       $06,u
                    clra
                    clrb
                    std       $08,u
L21BF               puls      pc,u
L21C1               pshs      u
                    ldd       #$FFB6
                    lbsr      L010F
                    ldu       $04,s
                    leas      -$02,s
                    pshs      u
                    lbsr      L26D8
                    leas      $02,s
                    ldd       ,u
                    std       ,s
                    tfr       d,x
                    bra       L2204

L21DC               ldd       #$0001
                    bra       L21E4

L21E1               ldd       #$0006
L21E4               std       ,s
                    pshs      d
                    pshs      u
                    bsr       L222C
                    leas      $04,s
                    bra       L2224

L21F0               leax      $295D,pcr
                    pshs      x
                    pshs      u
                    lbsr      L0498
                    leas      $04,s
                    ldd       #$0001
                    std       ,s
                    bra       L2224

L2204               cmpx      #$0002
                    beq       L21DC
                    cmpx      #$0005
                    beq       L21E1
                    cmpx      #$0006
                    beq       L2224
                    cmpx      #$0008
                    beq       L2224
                    cmpx      #$0001
                    beq       L2224
                    cmpx      #$0007
                    beq       L2224
                    bra       L21F0

L2224               ldd       ,s
                    std       ,u
                    leas      $02,s
                    puls      pc,u
L222C               pshs      u
                    ldd       #$FFAC
                    lbsr      L010F
                    ldu       $04,s
                    leas      -$04,s
                    clra
                    clrb
                    std       ,s
                    ldx       ,u
                    lbra      L24DB

L2241               ldx       $0a,s
                    bra       L2277

L2245               ldd       #$0085
                    bra       L2258

L224A               ldd       #$0001
                    pshs      d
                    pshs      u
                    bsr       L222C
                    leas      $04,s
                    ldd       #$0083
L2258               std       ,s
                    lbra      L2508

L225D               ldd       #$0001
                    pshs      d
                    pshs      u
                    lbsr      L222C
                    leas      $04,s
                    ldd       $0a,s
                    pshs      d
                    pshs      u
                    lbsr      L222C
                    leas      $04,s
                    lbra      L2508

L2277               cmpx      #$0001
                    beq       L2245
                    cmpx      #$0007
                    lbeq      L2245
                    cmpx      #$0008
                    beq       L224A
                    cmpx      #$0006
                    beq       L225D
                    cmpx      #$0005
                    lbeq      L225D
                    lbra      L2508

L2297               ldd       ,u
                    clra
                    andb      #$30
                    cmpd      #$0010
                    lbne      L2508
L22A4               ldx       $0a,s
                    lbra      L233C

L22A9               ldd       $06,u
                    cmpd      #$0036
                    bne       L22E4
                    ldd       #$0004
                    pshs      d
                    lbsr      L6622
                    leas      $02,s
                    std       $02,s
                    ldd       $08,u
                    ldx       $02,s
                    std       $02,x
                    bge       L22CA
                    ldd       #$FFFF
                    bra       L22CC

L22CA               clra
                    clrb
L22CC               std       [$02,s]
                    ldd       $02,s
                    std       $08,u
                    bra       L22D7

L22D5               leas      -$04,x
L22D7               ldd       #$004A
                    std       $06,u
                    ldd       #$0004
L22DF               std       $02,u
                    lbra      L2508

L22E4               ldd       #$0083
                    bra       L2337

L22E9               ldd       #$0001
                    std       $0a,s
                    lbra      L2508

L22F1               ldd       #$0006
                    pshs      d
                    pshs      u
                    lbsr      L222C
                    leas      $04,s
                    ldd       #$008D
                    bra       L2337

L2302               ldd       $06,u
                    cmpd      #$0036
                    bne       L2334
                    ldd       #$0008
                    pshs      d
                    lbsr      L6622
                    leas      $02,s
                    std       $02,s
                    ldx       $02,s
                    pshs      x
                    ldd       $08,u
                    lbsr      $A791
                    lbsr      $AE34
                    bra       L2326

L2324               leas      -$04,x
L2326               ldd       $02,s
                    std       $08,u
                    ldd       #$004B
                    std       $06,u
                    ldd       #$0008
                    bra       L22DF

L2334               ldd       #$008E
L2337               std       ,s
                    lbra      L2508

L233C               cmpx      #$0008
                    lbeq      L22A9
                    cmpx      #$0002
                    lbeq      L22E9
                    cmpx      #$0005
                    beq       L22F1
                    cmpx      #$0006
                    beq       L2302
                    lbra      L2508

L2357               ldx       $0a,s
                    bra       L2381

L235B               ldd       #$0086
                    bra       L2374

L2360               ldd       #$0006
                    pshs      d
                    pshs      u
                    lbsr      L222C
                    leas      $04,s
                    ldd       #$008D
                    bra       L2374

L2371               ldd       #$0092
L2374               std       ,s
                    lbra      L2508

L2379               ldd       #$0001
                    std       $0a,s
                    lbra      L2508

L2381               cmpx      #$0008
                    beq       L235B
                    cmpx      #$0005
                    beq       L2360
                    cmpx      #$0006
                    beq       L2371
                    cmpx      #$0002
                    beq       L2379
                    lbra      L2508

L2398               ldx       $0a,s
                    lbra      L2410

L239D               ldd       $0a,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    lbne      L2508
L23AA               ldd       $06,u
                    cmpd      #$004A
                    bne       L23CD
                    ldd       $08,u
                    std       $02,s
                    ldx       $02,s
                    ldd       $02,x
                    std       $08,u
                    bra       L23C0

L23BE               leas      -$04,x
L23C0               ldd       #$0036
                    std       $06,u
                    ldd       #$0002
                    std       $02,u
                    lbra      L2508

L23CD               ldd       #$0084
                    bra       L240B

L23D2               ldd       #$0006
                    pshs      d
                    pshs      u
                    lbsr      L222C
                    leas      $04,s
                    ldd       #$008D
                    bra       L240B

L23E3               ldd       $06,u
                    cmpd      #$004A
                    bne       L2408
                    ldd       #$0008
                    pshs      d
                    lbsr      L6622
                    leas      $02,s
                    std       $02,s
                    ldx       $02,s
                    pshs      x
                    ldx       $08,u
                    lbsr      LA780
L2400               lbsr      $AE34
                    leax      $04,s
                    lbra      L2324

L2408               ldd       #$0090
L240B               std       ,s
                    lbra      L2508

L2410               cmpx      #$0001
                    lbeq      L23AA
                    cmpx      #$0007
                    lbeq      L23AA
                    cmpx      #$0002
                    lbeq      L23AA
                    cmpx      #$0005
                    beq       L23D2
                    cmpx      #$0006
                    beq       L23E3
                    lbra      L239D

L2432               ldx       $0a,s
                    bra       L2458

L2436               ldd       #$0006
                    pshs      d
                    pshs      u
                    lbsr      L222C
                    leas      $04,s
                    ldd       $0a,s
                    pshs      d
                    pshs      u
                    lbsr      L222C
                    leas      $04,s
                    lbra      L2508

L2450               ldd       #$008C
                    std       ,s
                    lbra      L2508

L2458               cmpx      #$0008
                    beq       L2436
                    cmpx      #$0007
                    lbeq      L2436
                    cmpx      #$0002
                    lbeq      L2436
                    cmpx      #$0001
                    lbeq      L2436
                    cmpx      #$0006
                    beq       L2450
                    lbra      L2508

L247A               ldx       $0a,s
                    bra       L24BC

L247E               ldd       $06,u
                    cmpd      #$004B
                    bne       L2492
                    ldx       $08,u
                    lbsr      $A77B
                    std       $08,u
                    leax      $04,s
                    lbra      L23BE

L2492               ldd       #$008F
                    bra       L24B8

L2497               ldd       $06,u
                    cmpd      #$004B
                    bne       L24B0
                    ldx       $08,u
                    pshs      x
                    ldx       $08,u
                    lbsr      $A775
                    lbsr      LAEDF
                    leax      $04,s
                    lbra      L22D5

L24B0               ldd       #$0091
                    bra       L24B8

L24B5               ldd       #$008D
L24B8               std       ,s
                    bra       L2508

L24BC               cmpx      #$0002
                    beq       L247E
                    cmpx      #$0007
                    lbeq      L247E
                    cmpx      #$0001
                    lbeq      L247E
                    cmpx      #$0008
                    beq       L2497
                    cmpx      #$0005
                    beq       L24B5
                    bra       L2508

L24DB               cmpx      #$0002
                    lbeq      L2241
                    cmpx      #$0001
                    lbeq      L22A4
                    cmpx      #$0007
                    lbeq      L2357
                    cmpx      #$0008
                    lbeq      L2398
                    cmpx      #$0005
                    lbeq      L2432
                    cmpx      #$0006
                    lbeq      L247A
                    lbra      L2297

L2508               ldd       ,s
                    beq       L2540
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    lbsr      L0FD8
                    leas      $0C,s
                    std       $02,s
                    pshs      d
                    pshs      u
                    lbsr      L05C9
                    leas      $04,s
                    ldd       ,s
                    std       $06,u
                    ldd       $02,s
                    std       $0a,u
                    clra
                    clrb
                    std       $0C,u
L2540               ldd       $0a,s
                    lbra      L25BE

L2545               pshs      u
                    ldd       #$FFB4
                    lbsr      L010F
                    ldu       $04,s
                    leas      -$04,s
                    pshs      u
                    lbsr      L21C1
                    leas      $02,s
                    std       $02,s
                    ldd       $0a,s
                    pshs      d
                    lbsr      L21C1
                    leas      $02,s
L2563               std       ,s
                    ldd       $02,s
                    cmpd      #$0006
                    bne       L2572
                    ldd       #$0006
                    bra       L258A

L2572               ldd       ,s
                    cmpd      #$0006
                    bne       L257F
                    ldd       #$0006
                    bra       L259D

L257F               ldd       $02,s
                    cmpd      #$0008
                    bne       L2592
                    ldd       #$0008
L258A               pshs      d
                    ldd       $0C,s
                    pshs      d
                    bra       L25A1

L2592               ldd       ,s
                    cmpd      #$0008
                    bne       L25A8
                    ldd       #$0008
L259D               pshs      d
                    pshs      u
L25A1               lbsr      L222C
                    leas      $04,s
                    bra       L25C5

L25A8               ldd       $02,s
                    cmpd      #$0007
                    beq       L25B8
                    ldd       ,s
                    cmpd      #$0007
                    bne       L25C2
L25B8               ldd       #$0007
                    std       [$0a,s]
L25BE               std       ,u
                    bra       L25C5

L25C2               ldd       #$0001
L25C5               leas      $04,s
                    puls      pc,u
L25C9               pshs      u
                    ldd       #$FFB0
                    lbsr      L010F
                    ldd       $08,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    lbsr      L067C
                    std       ,s
                    lbsr      L90F5
                    leas      $06,s
                    std       $04,s
                    cmpd      #$0001
                    bne       L25F3
                    ldd       $0a,s
                    puls      pc,u
L25F3               ldx       $0a,s
                    ldd       $10,x
                    pshs      d
                    ldx       $0C,s
                    ldd       $0e,x
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    lbsr      L0FD8
                    leas      $0C,s
                    tfr       d,u
                    ldd       #$0001
                    std       ,u
                    ldx       $0a,s
                    ldd       $10,x
                    pshs      d
                    ldx       $0C,s
                    ldd       $0e,x
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    pshs      u
                    ldd       $12,s
                    pshs      d
                    ldd       #$0052
                    pshs      d
                    lbsr      L0FD8
                    leas      $0C,s
                    pshs      d
                    lbsr      L120A
                    leas      $02,s
                    tfr       d,u
                    ldd       $06,u
                    cmpd      #$0036
                    bne       L2654
                    clra
                    clrb
                    bra       L2657

L2654               ldd       #$0002
L2657               std       $12,u
                    ldd       #$0001
                    std       ,u
                    ldd       #$0002
                    std       $02,u
                    tfr       u,d
                    puls      pc,u
L2668               pshs      u
                    ldd       #$FFB6
                    lbsr      L010F
                    ldu       $04,s
                    leas      -$02,s
                    ldd       $06,u
                    std       ,s
                    tfr       d,x
                    cmpx      #$0076
                    lbeq      L27B6
                    cmpx      #$006F
                    lbeq      L27B6
                    cmpx      #$0042
                    lbeq      L27B6
                    ldd       ,s
                    cmpd      #$0034
                    bne       L26C1
                    pshs      u
                    bsr       L26D8
                    leas      $02,s
                    ldd       $08,s
                    lbne      L27B6
                    ldd       ,u
                    clra
                    andb      #$30
                    cmpd      #$0020
                    bne       L26B3
                    ldd       #$0001
                    bra       L26B5

L26B3               clra
                    clrb
L26B5               bne       L26C1
                    ldd       ,u
                    cmpd      #$0004
                    lbne      L27B6
L26C1               leax      $2968,pcr
                    pshs      x
                    pshs      u
                    lbsr      L0498
                    leas      $04,s
                    pshs      u
                    lbsr      L27EB
                    leas      $02,s
                    lbra      L27B6

L26D8               pshs      u
                    ldd       #$FFB8
                    lbsr      L010F
                    ldu       $04,s
                    ldd       $06,u
                    cmpd      #$0034
                    lbne      L27B8
                    ldd       ,u
                    lbne      L27B8
                    leax      L2978,pcr
                    pshs      x
                    pshs      u
                    lbsr      L0498
                    leas      $04,s
                    pshs      u
                    lbsr      L27EB
                    lbra      L27B6

L2707               pshs      u
                    ldd       #$FFB6
                    lbsr      L010F
                    ldu       $04,s
                    leas      -$02,s
                    ldd       ,u
                    std       [$08,s]
                    ldd       $06,u
                    cmpd      #$0041
                    bne       L2746
                    ldd       #$0001
                    std       [$0a,s]
                    ldd       $0a,u
                    std       ,s
                    ldd       $04,u
                    ldx       ,s
                    std       $04,x
                    pshs      u
                    ldd       $02,s
                    pshs      d
                    lbsr      L05C9
                    leas      $04,s
                    ldd       ,s
                    pshs      d
                    lbsr      L05B9
                    leas      $02,s
                    bra       L274B

L2746               clra
                    clrb
                    std       [$0a,s]
L274B               pshs      u
                    lbsr      L26D8
                    leas      $02,s
                    ldd       $06,u
                    cmpd      #$0034
                    bne       L278B
                    ldd       $08,u
                    std       ,s
                    ldx       ,s
                    ldd       $08,x
                    cmpd      #$0011
                    beq       L276C
                    leax      $02,s
                    bra       L2789

L276C               ldd       #$0036
                    std       $06,u
                    ldx       ,s
                    ldd       $06,x
                    std       $08,u
                    clra
                    clrb
                    std       $12,u
                    ldd       #$0001
                    std       ,u
                    ldx       ,s
                    ldd       $02,x
                    bra       L27B6
                    bra       L278B

L2789               leas      -$02,x
L278B               leax      $298C,pcr
                    pshs      x
                    pshs      u
                    lbsr      L0498
                    leas      $04,s
                    pshs      u
                    lbsr      L27EB
                    leas      $02,s
                    ldd       #$0036
                    std       $06,u
                    clra
                    clrb
                    std       $08,u
                    clra
                    clrb
                    std       $12,u
                    ldd       #$0001
                    std       [$08,s]
                    ldd       #$0002
L27B6               leas      $02,s
L27B8               puls      pc,u
L27BA               pshs      u
                    ldd       #$FFB8
                    lbsr      L010F
                    ldu       $04,s
                    ldd       ,u
                    cmpd      #$0004
                    beq       L27D4
                    ldd       ,u
                    cmpd      #$0003
                    bne       L27E7
L27D4               leax      L29A3,pcr
                    pshs      x
                    pshs      u
                    lbsr      L0498
                    leas      $04,s
                    pshs      u
                    bsr       L27EB
                    leas      $02,s
L27E7               ldd       ,u
                    puls      pc,u
L27EB               pshs      u
                    ldd       #$FFB6
                    lbsr      L010F
                    ldu       $04,s
                    ldd       #$0006
                    pshs      d
                    pshs      u
                    leax      >$0078,y
                    pshs      x
                    lbsr      L03FB
                    leas      $06,s
                    ldd       #$0001
                    std       $12,u
                    ldd       $0a,u
                    pshs      d
                    lbsr      L0598
                    leas      $02,s
                    ldd       $0C,u
                    pshs      d
                    lbsr      L0598
                    leas      $02,s
                    clra
                    clrb
                    std       $0C,u
                    std       $0a,u
                    ldd       #$0034
                    std       $06,u
                    leax      >$0078,y
                    stx       $08,u
                    puls      pc,u
L2832               pshs      u
                    ldd       #$FFC0
                    lbsr      L010F
                    ldx       $04,s
                    bra       L2843

L283E               ldd       #$0001
                    puls      pc,u
L2843               cmpx      #$0001
                    beq       L283E
                    cmpx      #$0002
                    lbeq      L283E
                    cmpx      #$0008
                    lbeq      L283E
                    cmpx      #$0007
                    lbeq      L283E
                    clra
                    clrb
                    puls      pc,u
L2861               pshs      u
                    ldd       #$FFB8
                    lbsr      L010F
                    leax      L29C4,pcr
                    pshs      x
                    ldd       $06,s
                    pshs      d
                    lbsr      L0498
                    leas      $04,s
                    puls      pc,u
L287A               lsr       $09,s
                    ror       $6964
                    fcb       $65
                    bra       L28E4
                    rol       $207A
                    fcb       $65
                    fcb       $72
                    clr       0,x
L2889               lsr       $7970
                    fcb       $65
                    lsr       $05,s
                    ror       0,y
                    blt       $28B3
                    jmp       $0f,s
                    lsr       $2061
                    bra       L2910
                    fcb       $61
                    fcb       $72
                    rol       $01,s
                    fcb       $62
                    inc       $05,s
                    neg       L0063
                    fcb       $61
                    jmp       $0e,s
                    clr       -$0C,s
                    bra       L290D
                    fcb       $61
                    com       $7400
L28AE               com       $01,s
                    jmp       $07,y
                    lsr       L2074
                    fcb       $61
                    fcb       $6b
                    fcb       $65
                    bra       $291B
                    lsr       $04,s
                    fcb       $72
                    fcb       $65
                    com       $7300
L28C1               neg       L6F69
                    jmp       -$0C,s
                    fcb       $65
                    fcb       $72
                    bra       $293C
                    fcb       $65
                    fcb       $71
                    fcb       $75
                    rol       -$0e,s
                    fcb       $65
                    lsr       0,x
L28D2               neg       L6F69
                    jmp       -$0C,s
                    fcb       $65
                    fcb       $72
                    bra       $294A
                    fcb       $72
                    bra       L2947
                    jmp       -$0C,s
                    fcb       $65
                    asr       $05,s
                    fcb       $72
L28E4               bra       $2958
                    fcb       $65
                    fcb       $71
                    fcb       $75
                    rol       -$0e,s
                    fcb       $65
                    lsr       0,x
L28EE               jmp       $0f,s
                    lsr       $2061
                    bra       L295B
                    fcb       $75
                    jmp       $03,s
                    lsr       $696F
                    jmp       0,x
L28FD               fcb       $62
                    clr       -$0C,s
                    asl       0,y
                    tst       -$0b,s
                    com       $7420
                    fcb       $62
                    fcb       $65
                    bra       $2974
                    jmp       -$0C,s
L290D               fcb       $65
                    asr       -$0e,s
L2910               fcb       $61
                    inc       0,x
L2913               neg       L6F69
                    jmp       -$0C,s
                    fcb       $65
                    fcb       $72
                    bra       L2989
                    rol       -$0d,s
                    tst       $01,s
                    lsr       L6368
                    neg       $0074
                    rol       L7065
                    bra       L2997
                    rol       -$0d,s
                    tst       $01,s
                    lsr       L6368
                    neg       L0070
                    clr       $09,s
                    jmp       -$0C,s
                    fcb       $65
                    fcb       $72
                    bra       $29A8
                    rol       -$0d,s
                    tst       $01,s
                    lsr       L6368
                    neg       $0074
                    rol       L7065
L2947               bra       L29AC
                    asl       $05,s
                    com       $0b,s
                    neg       $0073
                    asl       $0f,s
                    fcb       $75
                    inc       $04,s
                    bra       $29B8
                    fcb       $65
                    bra       L29A7
                    fcb       $55
                    inca
L295B               inca
                    neg       $0074
                    rol       L7065
                    bra       $29C8
                    fcb       $72
                    fcb       $72
                    clr       -$0e,s
                    neg       L006C
                    ror       $616C
                    fcb       $75
                    fcb       $65
                    bra       $29E2
                    fcb       $65
                    fcb       $71
                    fcb       $75
                    rol       -$0e,s
                    fcb       $65
                    lsr       0,x
L2978               fcb       $75
                    jmp       $04,s
                    fcb       $65
                    com       $0C,s
                    fcb       $61
                    fcb       $72
                    fcb       $65
                    lsr       0,y
                    ror       L6172
                    rol       $01,s
                    fcb       $62
L2989               inc       $05,s
                    neg       $0073
                    lsr       L7275
                    com       -$0C,s
                    bra       $2A01
                    fcb       $65
                    tst       $02,s
L2997               fcb       $65
                    fcb       $72
                    bra       $2A0D
                    fcb       $65
                    fcb       $71
                    fcb       $75
                    rol       -$0e,s
                    fcb       $65
                    lsr       0,x
L29A3               com       L7472
                    fcb       $75
L29A7               com       -$0C,s
                    fcb       $75
                    fcb       $72
                    fcb       $65
L29AC               bra       $2A1D
                    fcb       $72
                    bra       L2A26
                    jmp       $09,s
                    clr       $0e,s
                    bra       $2A20
                    jmp       $01,s
                    neg       $7072
                    clr       -$10,s
                    fcb       $72
                    rol       $01,s
                    lsr       L6500
L29C4               tst       -$0b,s
                    com       $7420
                    fcb       $62
                    fcb       $65
                    bra       L2A36
                    jmp       -$0C,s
                    fcb       $65
                    asr       -$0e,s
                    fcb       $61
                    inc       0,x
L29D5               pshs      u
                    ldd       #$FFBA
                    lbsr      L010F
                    ldd       $003F
                    cmpd      #$0028
                    beq       L29ED
                    clra
                    clrb
                    std       $002F
                    bra       L29ED

L29EB               leas      ,x
L29ED               ldx       $003F
                    lbra      L2AEC

L29F2               ldx       $0041
                    bra       L2A48

L29F6               lbsr      L2B1C
                    puls      pc,u
L29FB               lbsr      L2BDF
                    puls      pc,u
L2A00               lbsr      L3098
                    lbra      L2B10

L2A06               lbsr      L2DF6
                    puls      pc,u
L2A0B               lbsr      L2C8F
                    puls      pc,u
L2A10               lbsr      L31B8
                    lbra      L2B10

L2A16               lbsr      L31F7
                    lbra      L2B10

L2A1C               lbsr      L2E5E
                    puls      pc,u
L2A21               lbsr      L2F5F
                    puls      pc,u
L2A26               lbsr      L2EB1
                    lbra      L2B10

L2A2C               lbsr      L3235
                    lbra      L2B10

L2A32               leax      L3401,pcr
L2A36               pshs      x
                    lbsr      L0450
                    leas      $02,s
                    lbsr      $5F26
                    lbra      L2A9C

L2A43               leax      ,s
                    lbra      L2AA5

L2A48               cmpx      #$0013
                    beq       L29F6
                    cmpx      #$0014
                    beq       L29FB
                    cmpx      #$0012
                    beq       L2A00
                    cmpx      #$0017
                    beq       L2A06
                    cmpx      #$0016
                    beq       L2A0B
                    cmpx      #$0018
                    beq       L2A10
                    cmpx      #$0019
                    beq       L2A16
                    cmpx      #$001B
                    beq       L2A1C
                    cmpx      #$001C
                    beq       L2A21
                    cmpx      #$001A
                    beq       L2A26
                    cmpx      #start
                    beq       L2A2C
                    cmpx      #$0015
                    beq       L2A32
                    bra       L2A43

L2A86               lbsr      L89B7
                    lbsr      $5F26
                    puls      pc,u
L2A8E               puls      pc,u
L2A90               lbsr      L42B9
                    ldb       $0045
                    cmpb      #$3a
                    bne       L2AA1
                    lbsr      L3280
L2A9C               leax      ,s
                    lbra      L29EB

L2AA1               leax      ,s
                    bra       L2ACD

L2AA5               leas      ,x
L2AA7               lbsr      L0641
                    std       -$02,s
                    bne       L2AB5
                    lbsr      L05DF
                    std       -$02,s
                    beq       L2ACF
L2AB5               leax      L3414,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
L2AC0               lbsr      $5F26
                    ldd       $003F
                    cmpd      #$0028
                    bne       L2AC0
                    bra       L2B10

L2ACD               leas      ,x
L2ACF               clra
                    clrb
                    pshs      d
                    lbsr      L3319
                    std       ,s++
                    bne       L2B10
                    leax      L3428,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
                    lbsr      L0704
                    puls      pc,u
                    bra       L2B10

L2AEC               cmpx      #$0028
                    beq       L2B10
                    cmpx      #$0033
                    lbeq      L29F2
                    cmpx      #$0029
                    lbeq      L2A86
                    cmpx      #$FFFF
                    lbeq      L2A8E
                    cmpx      #$0034
                    lbeq      L2A90
L2B0D               lbra      L2AA7

L2B10               ldd       #$0028
                    pshs      d
                    lbsr      L06C1
                    leas      $02,s
                    puls      pc,u
L2B1C               pshs      u
                    ldd       #$FFAE
                    lbsr      L010F
                    leas      -$06,s
                    lbsr      $5F26
                    lbsr      L337E
                    std       ,s
                    ldd       $000B
                    addd      #$0001
                    std       $000B
                    tfr       d,u
                    ldd       $000B
                    addd      #$0001
                    std       $000B
                    std       $04,s
                    ldd       $003F
                    cmpd      #$0028
                    bne       L2B6B
                    lbsr      $5F26
                    clra
                    clrb
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    ldd       $06,s
                    pshs      d
                    lbsr      L33D7
                    leas      $08,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L57B2
                    leas      $02,s
                    stu       $02,s
                    bra       L2B8D

L2B6B               ldd       #$0001
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    ldd       $06,s
                    pshs      d
                    lbsr      L33D7
                    leas      $08,s
                    pshs      u
                    lbsr      L57B2
                    leas      $02,s
                    lbsr      L29D5
                    ldd       $04,s
                    std       $02,s
L2B8D               ldd       $003F
                    cmpd      #$0033
                    bne       L2BD2
                    ldd       $0041
                    cmpd      #$0015
                    bne       L2BD2
                    lbsr      $5F26
                    ldd       $003F
                    cmpd      #$0028
                    beq       L2BD2
                    cmpu      $02,s
                    beq       L2BCF
                    clra
                    clrb
                    pshs      d
                    ldd       $000B
                    addd      #$0001
                    std       $000B
                    std       $04,s
                    pshs      d
                    ldd       #$007C
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L57B2
                    leas      $02,s
L2BCF               lbsr      L29D5
L2BD2               ldd       $02,s
                    pshs      d
                    lbsr      L57B2
                    leas      $02,s
                    leas      $06,s
                    puls      pc,u
L2BDF               pshs      u
                    ldd       #$FFAA
                    lbsr      L010F
                    leas      -$0a,s
                    ldd       $0033
                    std       $08,s
                    ldd       $0035
                    std       $06,s
                    ldd       $0786,y
                    std       $04,s
                    ldd       $0788,y
                    std       $02,s
                    lbsr      $5F26
                    ldd       $000B
                    addd      #$0001
                    std       $000B
                    std       $0033
                    ldd       $000F
                    std       $0788,y
                    std       $0786,y
                    ldd       $000B
                    addd      #$0001
                    std       $000B
                    std       $0035
                    lbsr      L337E
                    std       ,s
                    ldd       $003F
                    cmpd      #$0028
                    bne       L2C2D
                    ldu       $0035
                    bra       L2C52

L2C2D               clra
                    clrb
                    pshs      d
                    ldd       $0035
                    pshs      d
                    ldd       #$007C
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
                    ldd       $000B
                    addd      #$0001
                    std       $000B
                    tfr       d,u
                    pshs      u
                    lbsr      L57B2
                    leas      $02,s
                    lbsr      L29D5
L2C52               ldd       $0035
                    pshs      d
                    lbsr      L57B2
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    ldd       $0033
                    pshs      d
                    pshs      u
                    ldd       $06,s
                    pshs      d
                    lbsr      L33D7
                    leas      $08,s
                    ldd       $0033
                    pshs      d
                    lbsr      L57B2
                    leas      $02,s
                    ldd       $08,s
                    std       $0033
                    ldd       $06,s
                    std       $0035
                    ldd       $04,s
                    std       $0786,y
                    ldd       $02,s
                    std       $0788,y
                    leas      $0a,s
                    puls      pc,u
L2C8F               pshs      u
                    ldd       #$FFA8
                    lbsr      L010F
                    leas      -$0e,s
                    lbsr      $5F26
                    ldd       $0037
                    addd      #$0001
                    std       $0037
                    ldd       $003B
                    std       ,s
                    ldd       $0039
                    std       $0a,s
                    clra
                    clrb
                    std       $0039
                    ldd       $0033
                    std       $0C,s
                    ldd       $0784,y
                    std       $08,s
                    ldd       $0786,y
                    std       $02,s
                    ldd       $000B
                    addd      #$0001
                    std       $000B
                    std       $0033
                    ldd       $000F
                    std       $0786,y
                    clra
                    clrb
                    std       $0784,y
                    ldd       #$002D
                    pshs      d
                    lbsr      L06C1
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    lbsr      $0785
                    std       ,s
                    lbsr      L111D
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    beq       L2D43
                    pshs      u
                    lbsr      L26D8
                    leas      $02,s
                    ldx       ,u
                    bra       L2D1B

L2CFD               ldd       #$0001
                    pshs      d
                    pshs      u
                    lbsr      L222C
                    leas      $04,s
                    bra       L2D33

L2D0B               pshs      u
                    lbsr      L2861
                    leas      $02,s
                    pshs      u
                    lbsr      L27EB
                    leas      $02,s
                    bra       L2D33

L2D1B               cmpx      #$0002
                    beq       L2CFD
                    cmpx      #$0008
                    lbeq      L2CFD
                    cmpx      #$0001
                    beq       L2D33
                    cmpx      #$0007
                    beq       L2D33
                    bra       L2D0B

L2D33               pshs      u
                    lbsr      L6E76
                    leas      $02,s
                    pshs      u
                    lbsr      L0598
                    leas      $02,s
                    bra       L2D46

L2D43               lbsr      L101A
L2D46               ldd       #$002E
                    pshs      d
                    lbsr      L06C1
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    ldd       $000B
                    addd      #$0001
                    std       $000B
                    std       $08,s
                    pshs      d
                    ldd       #$007C
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
                    lbsr      L29D5
                    ldd       $002F
                    bne       L2D82
                    clra
                    clrb
                    pshs      d
                    ldd       $0033
                    pshs      d
                    ldd       #$007C
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
L2D82               ldd       $06,s
                    pshs      d
                    lbsr      L57B2
                    leas      $02,s
                    ldu       $0039
                    bra       L2DAD

L2D8F               ldd       ,u
                    std       $04,s
                    ldd       $02,u
                    pshs      d
                    ldd       $04,u
                    pshs      d
                    ldd       #$007D
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
                    ldd       L0025
                    std       ,u
                    stu       L0025
                    ldu       $04,s
L2DAD               stu       -$02,s
                    bne       L2D8F
                    ldd       $0784,y
                    beq       L2DCB
                    clra
                    clrb
                    pshs      d
                    ldd       $0784,y
                    pshs      d
                    ldd       #$007C
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
L2DCB               ldd       $0033
                    pshs      d
                    lbsr      L57B2
                    leas      $02,s
                    ldd       $0a,s
                    std       $0039
                    ldd       $08,s
                    std       $0784,y
                    ldd       $0037
                    addd      #$FFFF
                    std       $0037
                    ldd       ,s
                    std       $003B
                    ldd       $0C,s
                    std       $0033
                    ldd       $02,s
                    std       $0786,y
                    lbra      L3094

L2DF6               pshs      u
                    ldd       #$FFB8
                    lbsr      L010F
                    leas      -$02,s
L2E00               lbsr      $5F26
                    clra
                    clrb
                    pshs      d
                    lbsr      L0C54
                    leas      $02,s
                    std       ,s
                    ldd       #$002F
                    pshs      d
                    lbsr      L06C1
                    leas      $02,s
                    ldd       $0037
                    beq       L2E5A
                    ldu       L0025
                    beq       L2E26
                    ldd       ,u
                    std       L0025
                    bra       L2E32

L2E26               ldd       #$0006
                    pshs      d
                    lbsr      L6622
                    leas      $02,s
                    tfr       d,u
L2E32               ldd       $0039
                    beq       L2E3C
                    stu       [$003B,y]
                    bra       L2E3E

L2E3C               stu       $0039
L2E3E               stu       $003B
                    clra
                    clrb
                    std       ,u
                    ldd       ,s
                    std       $02,u
                    ldd       $000B
                    addd      #$0001
                    std       $000B
                    std       $04,u
                    pshs      d
                    lbsr      L57B2
                    leas      $02,s
                    bra       L2EAD

L2E5A               bsr       L2E9C
                    bra       L2EAD

L2E5E               pshs      u
                    ldd       #$FFBA
                    lbsr      L010F
                    lbsr      $5F26
                    ldd       $0037
                    bne       L2E6F
                    bsr       L2E9C
L2E6F               ldd       $0784,y
                    beq       L2E80
L2E75               leax      $3435,pcr
                    pshs      x
                    lbsr      L0450
                    bra       L2E90

L2E80               ldd       $000B
                    addd      #$0001
                    std       $000B
                    std       $0784,y
                    pshs      d
                    lbsr      L57B2
L2E90               leas      $02,s
                    ldd       #$002F
                    pshs      d
                    lbsr      L06C1
                    bra       L2EAD

L2E9C               pshs      u
                    ldd       #$FFBA
                    lbsr      L010F
                    leax      $3447,pcr
                    pshs      x
                    lbsr      L0450
L2EAD               leas      $02,s
                    puls      pc,u
L2EB1               pshs      u
                    ldd       #$FFAA
                    lbsr      L010F
                    leas      -$0a,s
                    ldd       $0033
                    std       $08,s
                    ldd       $0035
                    std       $06,s
                    ldd       $0788,y
                    std       ,s
                    ldd       $0786,y
                    std       $02,s
                    ldd       $000F
                    std       $0788,y
                    std       $0786,y
                    ldd       $000B
                    addd      #$0001
                    std       $000B
                    std       $0035
                    ldd       $000B
                    addd      #$0001
                    std       $000B
                    std       $0033
                    lbsr      $5F26
                    ldd       $000B
                    addd      #$0001
                    std       $000B
                    std       $04,s
                    pshs      d
                    lbsr      L57B2
                    leas      $02,s
                    lbsr      L29D5
                    ldd       $003F
                    cmpd      #$0033
                    bne       L2F11
                    ldd       $0041
                    cmpd      #$0014
                    beq       L2F1C
L2F11               leax      $345B,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
L2F1C               lbsr      $5F26
                    ldd       $0035
                    pshs      d
                    lbsr      L57B2
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    ldd       $0033
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L337E
                    pshs      d
                    lbsr      L33D7
                    leas      $08,s
                    ldd       $0033
                    pshs      d
                    lbsr      L57B2
                    leas      $02,s
                    ldd       $08,s
                    std       $0033
                    ldd       $06,s
                    std       $0035
                    ldd       $02,s
                    std       $0786,y
                    ldd       ,s
                    std       $0788,y
                    leas      $0a,s
                    puls      pc,u
L2F5F               pshs      u
                    ldd       #$FFA6
                    lbsr      L010F
                    leas      -$0e,s
                    clra
                    clrb
                    std       $02,s
                    clra
                    clrb
                    std       ,s
                    ldu       $0033
                    ldd       $0035
                    std       $0C,s
                    ldd       $0786,y
                    std       $06,s
                    ldd       $0788,y
                    std       $04,s
                    ldd       $000F
                    std       $0786,y
                    std       $0788,y
                    ldd       $000B
                    addd      #$0001
                    std       $000B
                    std       $0a,s
                    ldd       $000B
                    addd      #$0001
                    std       $000B
                    std       $0033
                    lbsr      $5F26
                    ldd       #$002D
                    pshs      d
                    lbsr      L06C1
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    lbsr      L3319
                    leas      $02,s
                    ldd       #$0028
                    pshs      d
                    lbsr      L06C1
                    leas      $02,s
                    ldd       $003F
                    cmpd      #$0028
                    beq       L2FE5
                    lbsr      L33A5
                    std       $02,s
                    clra
                    clrb
                    pshs      d
                    ldd       $000B
                    addd      #$0001
                    std       $000B
                    std       $0a,s
                    pshs      d
                    ldd       #$007C
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
L2FE5               ldd       #$0028
                    pshs      d
                    lbsr      L06C1
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    lbsr      $0785
                    std       ,s
                    lbsr      L111D
                    leas      $02,s
                    std       ,s
                    beq       L3013
                    ldd       ,s
                    pshs      d
                    lbsr      L26D8
                    leas      $02,s
                    ldd       $000B
                    addd      #$0001
                    std       $000B
                    bra       L3015

L3013               ldd       $0a,s
L3015               std       $0035
                    ldd       #$002E
                    pshs      d
                    lbsr      L06C1
                    leas      $02,s
                    ldd       $0a,s
                    pshs      d
                    lbsr      L57B2
                    leas      $02,s
                    lbsr      L29D5
                    ldd       ,s
                    beq       L3043
                    ldd       $0035
                    pshs      d
                    lbsr      L57B2
                    leas      $02,s
                    ldd       ,s
                    pshs      d
                    lbsr      L3342
                    leas      $02,s
L3043               ldd       $02,s
                    beq       L3067
                    ldd       $08,s
                    pshs      d
                    lbsr      L57B2
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    ldd       $0033
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L33D7
                    leas      $08,s
                    bra       L3079

L3067               clra
                    clrb
                    pshs      d
                    ldd       $0C,s
                    pshs      d
                    ldd       #$007C
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
L3079               ldd       $0033
                    pshs      d
                    lbsr      L57B2
                    leas      $02,s
                    stu       $0033
                    ldd       $0C,s
                    std       $0035
                    ldd       $06,s
                    std       $0786,y
                    ldd       $04,s
                    std       $0788,y
L3094               leas      $0e,s
                    puls      pc,u
L3098               pshs      u
                    ldd       #$FFB6
                    lbsr      L010F
                    lbsr      $5F26
                    ldd       $003F
                    cmpd      #$0028
                    lbeq      L3197
                    clra
                    clrb
                    pshs      d
                    lbsr      $0785
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    lbeq      L3197
                    pshs      u
                    lbsr      L111D
                    leas      $02,s
                    tfr       d,u
                    pshs      u
                    lbsr      L26D8
                    leas      $02,s
                    pshs      u
                    lbsr      L27BA
                    leas      $02,s
                    ldd       $002D
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L30E5
                    ldd       #$0001
                    bra       L30E7

L30E5               ldd       $002D
L30E7               pshs      d
                    pshs      u
                    lbsr      L222C
                    leas      $04,s
                    ldx       $002D
                    lbra      L3179

L30F5               pshs      u
                    lbsr      L34BE
                    leas      $02,s
                    leax      ,s
                    bra       L3109

L3100               pshs      u
                    lbsr      $3987
                    leas      $02,s
                    bra       L310B

L3109               leas      ,x
L310B               ldd       $06,u
                    cmpd      #$0080
                    lbeq      L3190
                    ldd       #$0080
                    pshs      d
                    ldd       #$006F
                    pshs      d
                    ldd       #$007F
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
                    ldd       #$006F
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
                    ldx       $002D
                    bra       L3162

L313C               ldd       $002D
                    pshs      d
                    ldd       #$0089
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
                    bra       L3190

L3151               ldd       #$0089
                    pshs      d
                    ldd       #$0088
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
                    bra       L3190

L3162               cmpx      #$0005
                    beq       L313C
                    cmpx      #$0006
                    lbeq      L313C
                    bra       L3151

L3170               pshs      u
                    lbsr      L6E42
                    leas      $02,s
                    bra       L3190

L3179               cmpx      #$0008
                    lbeq      L30F5
                    cmpx      #$0005
                    lbeq      L3100
                    cmpx      #$0006
                    lbeq      L3100
                    bra       L3170

L3190               pshs      u
                    lbsr      L0598
                    leas      $02,s
L3197               clra
                    clrb
                    pshs      d
                    lbsr      L57E3
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    ldd       #$0012
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
                    ldd       #$0012
                    lbra      L327C

L31B8               pshs      u
                    ldd       #$FFB6
                    lbsr      L010F
                    lbsr      $5F26
                    ldd       $0033
                    bne       L31D4
                    leax      L346A,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
                    bra       L31F1

L31D4               ldd       $0786,y
                    pshs      d
                    lbsr      L57E3
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    ldd       $0033
                    pshs      d
                    ldd       #$007C
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
L31F1               ldd       #$0018
                    lbra      L327C

L31F7               pshs      u
                    ldd       #$FFB6
                    lbsr      L010F
                    lbsr      $5F26
                    ldd       $0035
                    bne       L3213
                    leax      $3476,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
                    bra       L3230

L3213               ldd       $0788,y
                    pshs      d
                    lbsr      L57E3
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    ldd       $0035
                    pshs      d
                    ldd       #$007C
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
L3230               ldd       #$0019
                    bra       L327C

L3235               pshs      u
                    ldd       #$FFB6
                    lbsr      L010F
                    lbsr      $5F26
                    ldd       $003F
                    cmpd      #$0034
                    beq       L3255
                    leax      $3485,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
                    bra       L3279

L3255               lbsr      L32C2
                    tfr       d,u
                    stu       -$02,s
                    beq       L3276
                    clra
                    clrb
                    pshs      d
                    ldd       $06,u
                    pshs      d
                    ldd       #start
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
                    ldd       $0a,u
                    orb       #$02
                    std       $0a,u
L3276               lbsr      $5F26
L3279               ldd       #start
L327C               std       $002F
                    puls      pc,u
L3280               pshs      u
                    ldd       #$FFB6
                    lbsr      L010F
                    bsr       L32C2
                    tfr       d,u
                    stu       -$02,s
                    beq       L32BA
                    ldd       $08,u
                    cmpd      #$000F
                    bne       L329D
                    lbsr      L0443
                    bra       L32BA

L329D               ldd       #$000F
                    std       $08,u
                    clra
                    clrb
                    pshs      d
                    ldd       $06,u
                    pshs      d
                    ldd       #$0009
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
                    ldd       $0a,u
                    orb       #$01
                    std       $0a,u
L32BA               lbsr      $5F26
                    lbsr      $5F26
                    puls      pc,u
L32C2               pshs      u
                    ldd       #$FFBA
                    lbsr      L010F
                    ldu       $0041
                    ldd       ,u
                    cmpd      #$0009
                    lbeq      L33D3
                    ldd       ,u
                    beq       L32F4
                    ldd       $0C,u
                    beq       L32ED
                    leax      L3494,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
                    clra
                    clrb
                    puls      pc,u
L32ED               pshs      u
                    lbsr      L0382
                    leas      $02,s
L32F4               ldd       #$0009
                    std       ,u
                    ldd       #$000D
                    std       $08,u
                    ldd       $000B
                    addd      #$0001
                    std       $000B
                    std       $06,u
                    clra
                    clrb
                    std       $0a,u
                    ldd       $0031
                    std       $0C,u
                    ldd       $0029
                    std       $10,u
                    stu       $0029
                    lbra      L33D3

L3319               pshs      u
                    ldd       #$FFBA
                    lbsr      L010F
                    ldd       $04,s
                    pshs      d
                    lbsr      $0785
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    lbeq      L33D3
                    pshs      u
                    lbsr      L111D
                    std       ,s
                    bsr       L3342
                    leas      $02,s
                    tfr       d,u
                    lbra      L33D3

L3342               pshs      u
                    ldd       #$FFBA
                    lbsr      L010F
                    ldu       $04,s
                    pshs      u
                    lbsr      L26D8
                    leas      $02,s
                    ldx       $06,u
                    bra       L3363

L3357               ldd       #$003C
                    bra       L335F

L335C               ldd       #$003D
L335F               std       $06,u
                    bra       L336D

L3363               cmpx      #$003E
                    beq       L3357
                    cmpx      #$003F
                    beq       L335C
L336D               pshs      u
                    lbsr      L6F83
                    leas      $02,s
                    tfr       d,u
                    pshs      u
                    lbsr      L0598
                    lbra      L33D1

L337E               pshs      u
                    ldd       #$FFB8
                    lbsr      L010F
                    leas      -$02,s
                    ldd       #$002D
                    pshs      d
                    lbsr      L06C1
                    leas      $02,s
                    bsr       L33A5
                    std       ,s
                    ldd       #$002E
                    pshs      d
                    lbsr      L06C1
                    leas      $02,s
                    ldd       ,s
                    lbra      L33FD

L33A5               pshs      u
                    ldd       #$FFBA
                    lbsr      L010F
                    clra
                    clrb
                    pshs      d
                    lbsr      $0785
                    std       ,s
                    lbsr      L111D
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    beq       L33C8
                    pshs      u
                    lbsr      L26D8
                    bra       L33D1

L33C8               leax      $34AD,pcr
                    pshs      x
                    lbsr      L0450
L33D1               leas      $02,s
L33D3               tfr       u,d
                    puls      pc,u
L33D7               pshs      u
                    ldd       #$FFB4
                    lbsr      L010F
                    ldu       $04,s
                    stu       -$02,s
                    beq       L33FF
                    ldd       $0a,s
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    pshs      u
                    lbsr      L939D
                    leas      $08,s
                    pshs      u
                    lbsr      L0598
L33FD               leas      $02,s
L33FF               puls      pc,u
L3401               jmp       $0f,s
                    bra       $342C
                    rol       $06,s
                    beq       $3429
                    ror       $0f,s
                    fcb       $72
                    bra       $3435
                    fcb       $65
                    inc       -$0d,s
                    fcb       $65
                    beq       L3414
L3414               rol       $0C,s
                    inc       $05,s
                    asr       $01,s
                    inc       0,y
                    lsr       $05,s
                    com       $0C,s
                    fcb       $61
                    fcb       $72
                    fcb       $61
                    lsr       $696F
                    jmp       0,x

L3428               com       L796E
                    lsr       $6178
                    bra       L3495
                    fcb       $72
                    fcb       $72
                    clr       -$0e,s
                    neg       $006D
                    fcb       $75
                    inc       -$0C,s
                    rol       -$10,s
                    inc       $05,s
                    bra       $34A3
                    fcb       $65
                    ror       $01,s
                    fcb       $75
                    inc       -$0C,s
                    com       >$006E
                    clr       0,y
                    com       $7769
                    lsr       L6368
                    bra       $34C5
                    lsr       L6174
                    fcb       $65
                    tst       $05,s
                    jmp       -$0C,s
                    neg       $0077
                    asl       $09,s
                    inc       $05,s
                    bra       $34C7
                    asl       L7065
                    com       -$0C,s
                    fcb       $65
                    lsr       0,x
L346A               fcb       $62
                    fcb       $72
                    fcb       $65
                    fcb       $61
                    fcb       $6b
                    bra       $34D6
                    fcb       $72
                    fcb       $72
                    clr       -$0e,s
                    neg       L0063
                    clr       $0e,s
                    lsr       L696E
                    fcb       $75
                    fcb       $65
                    bra       L34E5
                    fcb       $72
                    fcb       $72
                    clr       -$0e,s
                    neg       L006C
                    fcb       $61
                    fcb       $62
                    fcb       $65
                    inc       0,y
                    fcb       $72
                    fcb       $65
                    fcb       $71
                    fcb       $75
                    rol       -$0e,s
                    fcb       $65
                    lsr       0,x
L3494               fcb       $61
L3495               inc       -$0e,s
                    fcb       $65
                    fcb       $61
                    lsr       -$07,s
                    bra       L34FE
                    bra       L350B
                    clr       $03,s
                    fcb       $61
                    inc       0,y
                    ror       L6172
                    rol       $01,s
                    fcb       $62
                    inc       $05,s
                    neg       L0063
                    clr       $0e,s
                    lsr       $09,s
                    lsr       $696F
                    jmp       0,y
                    jmp       $05,s
                    fcb       $65
                    lsr       $05,s
                    lsr       0,x
L34BE               pshs      u
                    ldd       #$FFBA
                    lbsr      L010F
                    ldd       $04,s
                    pshs      d
                    bsr       L34D9
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L3898
                    leas      $02,s
                    puls      pc,u
L34D9               pshs      u
                    ldd       #$FFAE
                    lbsr      L010F
                    ldu       $04,s
                    leas      -$06,s
L34E5               ldd       $06,u
                    std       $02,s
                    tfr       d,x
                    lbra      L379C

L34EE               pshs      u
                    lbsr      L7BD2
                    leas      $02,s
                    pshs      u
                    lbsr      L77AC
                    leas      $02,s
                    ldx       $06,u
L34FE               bra       L351A

L3500               ldd       $08,u
                    lbeq      L3894
                    pshs      u
                    ldd       #$0077
L350B               pshs      d
                    ldd       #$007B
L3510               pshs      d
                    lbsr      L4623
                    leas      $06,s
                    lbra      L3773

L351A               cmpx      #$0093
                    beq       L3500
                    cmpx      #$0094
                    lbeq      L3500
                    cmpx      #$0095
                    lbeq      L3500
                    lbra      L3894

L3530               ldd       $0a,u
                    pshs      d
                    lbsr      L6E42
                    leas      $02,s
                    ldd       #$0086
                    lbra      L36F5

L353F               ldd       $0a,u
                    pshs      d
                    lbsr      $3987
                    leas      $02,s
                    ldd       $0a,u
                    pshs      d
                    ldd       #$0091
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
                    lbra      L3701

L355E               ldd       $0a,u
                    pshs      d
                    lbsr      L6E42
                    leas      $02,s
                    ldd       #$0083
                    pshs      d
                    ldd       #$0088
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
                    bra       L357A

L3578               leas      -$06,x
L357A               ldd       #$0080
                    std       $06,u
                    lbra      L3894

L3582               ldd       $08,u
                    pshs      d
                    ldd       #$004A
                    pshs      d
                    ldd       #$0088
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
                    bra       L35BB

L3597               leax      L34BE,pcr
                    pshs      x
                    pshs      u
                    lbsr      L7567
                    bra       L35B9

L35A4               ldd       $0a,u
                    pshs      d
                    lbsr      L34BE
                    leas      $02,s
                    ldd       $02,s
                    pshs      d
                    ldd       #$0088
                    pshs      d
                    lbsr      L4623
L35B9               leas      $04,s
L35BB               leax      $06,s
                    lbra      L3771

L35C0               clra
                    clrb
                    pshs      d
                    ldd       #$0080
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$007F
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
                    ldd       #$0071
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
                    ldd       $0a,u
                    pshs      d
                    lbsr      L34BE
                    leas      $02,s
                    ldd       $02,s
                    pshs      d
                    ldd       #$0088
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
                    ldd       #$0089
                    pshs      d
                    ldd       #$0088
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
                    ldd       $02,s
                    cmpd      #$003E
                    bne       L361B
                    ldd       #$003F
                    lbra      L36F5

L361B               ldd       #$003E
                    lbra      L36F5

L3621               pshs      u
                    lbsr      L75E3
                    leas      $02,s
                    lbra      L3701

L362B               ldx       $0a,u
                    ldd       $06,x
                    cmpd      #$004A
                    bne       L3645
                    leas      -$02,s
                    ldd       $0a,u
                    std       ,s
                    ldd       $0C,u
                    std       $0a,u
                    ldd       ,s
                    std       $0C,u
                    leas      $02,s
L3645               ldx       $0C,u
                    ldd       $06,x
                    cmpd      #$004A
                    bne       L3696
                    ldx       $0C,u
                    ldd       $08,x
                    std       $04,s
                    ldd       [$04,s]
                    bne       L3696
                    ldx       $04,s
                    ldd       $02,x
                    pshs      d
                    lbsr      L749E
                    leas      $02,s
                    std       ,s
                    beq       L3696
                    ldd       $0C,u
                    std       $04,s
                    ldd       ,s
                    ldx       $04,s
                    std       $08,x
                    ldd       #$0036
                    ldx       $04,s
                    std       $06,x
                    ldd       #$0001
                    std       [$04,s]
                    ldd       $02,s
                    cmpd      #$0052
                    bne       L368D
                    ldd       #$0056
                    bra       L3690

L368D               ldd       #$0055
L3690               std       $02,s
                    leax      $06,s
                    bra       L36D0

L3696               ldd       $0a,u
                    std       $04,s
                    ldx       $04,s
                    ldd       $06,x
                    cmpd      #$004A
                    bne       L36AF
                    ldd       $04,s
                    pshs      d
                    lbsr      L38E8
                    leas      $02,s
                    bra       L36C7

L36AF               ldd       $04,s
                    pshs      d
                    lbsr      L34BE
                    leas      $02,s
                    ldd       #$006E
                    pshs      d
                    ldd       #$0088
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
L36C7               ldd       $0C,u
                    pshs      d
                    lbsr      L34BE
                    bra       L36F1

L36D0               leas      -$06,x
L36D2               ldd       $0a,u
                    pshs      d
                    lbsr      L34BE
                    leas      $02,s
                    ldd       #$0071
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
                    ldd       $0C,u
                    pshs      d
                    lbsr      L6E42
L36F1               leas      $02,s
                    ldd       $02,s
L36F5               pshs      d
                    ldd       #$0088
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
L3701               leax      $06,s
                    lbra      L3578

L3706               ldd       $0a,u
                    pshs      d
                    lbsr      L34BE
                    leas      $02,s
                    ldd       #$0071
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
                    ldd       $0C,u
                    pshs      d
                    lbsr      L34BE
                    leas      $02,s
                    leax      $06,s
                    bra       L375E

L372B               leas      -$06,x
                    ldd       $0a,u
                    std       $04,s
                    pshs      d
                    lbsr      L34BE
                    leas      $02,s
                    ldd       #$0071
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
                    ldd       $02,s
                    addd      #$FFB0
                    std       $06,u
                    ldd       #$0093
                    ldx       $04,s
                    std       $06,x
                    pshs      u
                    lbsr      L34D9
                    leas      $02,s
                    bra       L3760

L375E               leas      -$06,x
L3760               ldd       #$0089
                    pshs      d
                    ldd       #$0088
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
                    bra       L3773

L3771               leas      -$06,x
L3773               ldd       #$0093
                    std       $06,u
                    clra
                    clrb
                    std       $08,u
                    lbra      L3894

L377F               ldd       $02,s
                    cmpd      #$00A0
                    blt       L378C
                    leax      $06,s
                    lbra      L372B

L378C               leax      L3981,pcr
                    pshs      x
                    pshs      u
                    lbsr      L0464
                    leas      $04,s
                    lbra      L3894

L379C               cmpx      #$0080
                    lbeq      L3894
                    cmpx      #$0093
                    lbeq      L3894
                    cmpx      #$0094
                    lbeq      L3894
                    cmpx      #$0095
                    lbeq      L3894
                    cmpx      #$0034
                    lbeq      L3894
                    cmpx      #$0042
                    lbeq      L34EE
                    cmpx      #$0086
                    lbeq      L3530
                    cmpx      #$0091
                    lbeq      L353F
                    cmpx      #$0083
                    lbeq      L355E
                    cmpx      #$004A
                    lbeq      L3582
                    cmpx      #$0064
                    lbeq      L3597
                    cmpx      #$003C
                    lbeq      L35A4
                    cmpx      #$003D
                    lbeq      L35A4
                    cmpx      #$0044
                    lbeq      L35A4
                    cmpx      #$0043
                    lbeq      L35A4
                    cmpx      #$003E
                    lbeq      L35C0
                    cmpx      #$003F
                    lbeq      L35C0
                    cmpx      #$0065
                    lbeq      L3621
                    cmpx      #$0052
                    lbeq      L362B
                    cmpx      #$0053
                    lbeq      L3696
                    cmpx      #$005A
                    lbeq      L3696
                    cmpx      #$005B
                    lbeq      L3696
                    cmpx      #$005E
                    lbeq      L3696
                    cmpx      #$005C
                    lbeq      L3696
                    cmpx      #$005F
                    lbeq      L3696
                    cmpx      #$005D
                    lbeq      L3696
                    cmpx      #$0050
                    lbeq      L3696
                    cmpx      #$0051
                    lbeq      L3696
                    cmpx      #$0054
                    lbeq      L3696
                    cmpx      #$0057
                    lbeq      L3696
                    cmpx      #$0058
                    lbeq      L3696
                    cmpx      #$0059
                    lbeq      L3696
                    cmpx      #$0056
                    lbeq      L36D2
                    cmpx      #$0055
                    lbeq      L36D2
                    cmpx      #$0078
                    lbeq      L3706
                    lbra      L377F

L3894               leas      $06,s
                    puls      pc,u
L3898               pshs      u
                    ldd       #$FFB4
                    lbsr      L010F
                    ldx       $04,s
                    ldx       $06,x
                    bra       L38D5

L38A6               ldd       $04,s
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$007F
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
                    bra       L38E6

L38C0               ldd       $04,s
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       #$007B
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
                    bra       L38E6

L38D5               cmpx      #$0034
                    beq       L38A6
                    cmpx      #$0094
                    beq       L38C0
                    cmpx      #$0095
                    lbeq      L38C0
L38E6               puls      pc,u
L38E8               pshs      u
                    ldd       #$FFB2
                    lbsr      L010F
                    ldu       $04,s
                    leas      -$02,s
                    ldd       $08,u
                    std       ,s
                    ldx       ,s
                    lda       ,x
                    ora       $01,x
                    ora       $02,x
                    ora       $03,x
                    beq       L3947
                    ldx       ,s
                    ldd       $02,x
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
                    ldd       #$0070
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
                    ldd       [,s]
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
                    bra       L396E

L3947               clra
                    clrb
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
                    ldd       #$0070
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
L396E               ldd       #$0070
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
                    leas      $02,s
                    puls      pc,u
L3981               inc       $0f,s
                    jmp       $07,s
                    com       >$0034
                    nega
                    ldd       #$FFBA
                    lbsr      L010F
                    ldd       $04,s
                    pshs      d
                    bsr       L39A2
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L3898
                    leas      $02,s
                    puls      pc,u
L39A2               pshs      u
                    ldd       #$FFAE
                    lbsr      L010F
                    ldu       $04,s
                    leas      -$08,s
                    ldd       ,u
                    std       $02,s
                    ldd       $06,u
                    std       $06,s
                    tfr       d,x
                    lbra      L3BD7

L39BB               pshs      u
                    lbsr      L34D9
                    leas      $02,s
                    lbra      L3CAC

L39C5               ldd       $0a,u
                    pshs      d
                    lbsr      L6E42
                    leas      $02,s
                    bra       L39D2

L39D0               leas      -$08,x
L39D2               ldd       $06,s
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
                    bra       L39E4

L39E2               leas      -$08,x
L39E4               ldd       #$0080
                    std       $06,u
                    lbra      L3CAC

L39EC               ldd       $0a,u
                    pshs      d
                    lbsr      L34BE
                    bra       L39FC

L39F5               ldd       $0a,u
                    pshs      d
                    lbsr      $3987
L39FC               leas      $02,s
                    leax      $08,s
                    bra       L39D0

L3A02               ldd       $08,u
                    pshs      d
                    ldd       #$004B
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
                    lbra      L3BAE

L3A18               leax      $3987,pcr
                    pshs      x
                    pshs      u
                    lbsr      L7567
                    leas      $04,s
                    bra       L3A42

L3A27               ldd       $0a,u
                    pshs      d
                    lbsr      $3987
                    leas      $02,s
                    ldd       $02,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
L3A42               leax      $08,s
                    lbra      L3BAC

L3A47               ldd       #$0080
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$007F
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
                    ldd       #$0071
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
                    ldd       $0a,u
                    pshs      d
                    lbsr      $3987
                    leas      $02,s
                    ldd       $02,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
                    ldd       $02,s
                    pshs      d
                    ldd       #$0089
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
                    ldd       $02,s
                    pshs      d
                    ldd       $08,s
                    cmpd      #$003E
                    bne       L3AA9
                    ldd       #$003F
                    bra       L3AAC

L3AA9               ldd       #$003E
L3AAC               pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
                    bra       L3AF2

L3ABA               pshs      u
                    lbsr      L75E3
                    leas      $02,s
                    bra       L3AF2

L3AC3               ldd       $0a,u
                    pshs      d
                    lbsr      $3987
                    leas      $02,s
                    ldd       #$006E
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
                    ldd       $0C,u
                    pshs      d
                    lbsr      $3987
                    leas      $02,s
                    ldd       $06,s
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
L3AF2               leax      $08,s
                    lbra      L39E2

L3AF7               ldd       $0a,u
                    pshs      d
                    lbsr      $3987
                    leas      $02,s
                    ldd       #$0071
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
                    ldd       $0C,u
                    pshs      d
                    lbsr      $3987
                    leas      $02,s
                    leax      $08,s
                    lbra      L3B95

L3B1D               leas      -$08,x
                    ldd       $0a,u
                    std       $04,s
                    ldd       $02,s
                    cmpd      #$0005
                    bne       L3B4F
                    ldx       $04,s
                    ldd       $0a,x
                    pshs      d
                    lbsr      $3987
                    leas      $02,s
                    ldd       #$0071
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
                    ldd       #$008C
                    pshs      d
                    ldd       #$0087
                    bra       L3B60

L3B4F               ldd       $04,s
                    pshs      d
                    lbsr      $3987
                    leas      $02,s
                    ldd       #$0071
                    pshs      d
                    ldd       #$007A
L3B60               pshs      d
                    lbsr      L4623
                    leas      $04,s
                    ldd       $06,s
                    addd      #$FFB0
                    std       $06,u
                    ldd       #$0093
                    ldx       $04,s
                    std       $06,x
                    pshs      u
                    lbsr      L39A2
                    leas      $02,s
                    ldd       $02,s
                    cmpd      #$0005
                    bne       L3B97
                    ldd       #$008D
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
                    bra       L3B97

L3B95               leas      -$08,x
L3B97               ldd       $02,s
                    pshs      d
                    ldd       #$0089
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
                    bra       L3BAE

L3BAC               leas      -$08,x
L3BAE               ldd       #$0093
                    std       $06,u
                    clra
                    clrb
                    std       $08,u
                    lbra      L3CAC

L3BBA               ldd       $06,s
                    cmpd      #$00A0
                    blt       L3BC7
                    leax      $08,s
                    lbra      L3B1D

L3BC7               leax      L3CB0,pcr
                    pshs      x
                    pshs      u
                    lbsr      L0464
                    leas      $04,s
                    lbra      L3CAC

L3BD7               cmpx      #$0080
                    lbeq      L3CAC
                    cmpx      #$0093
                    lbeq      L3CAC
                    cmpx      #$0094
                    lbeq      L3CAC
                    cmpx      #$0095
                    lbeq      L3CAC
                    cmpx      #$0034
                    lbeq      L3CAC
                    cmpx      #$0042
                    lbeq      L39BB
                    cmpx      #$0092
                    lbeq      L39C5
                    cmpx      #$008E
                    lbeq      L39C5
                    cmpx      #$0090
                    lbeq      L39EC
                    cmpx      #$008D
                    lbeq      L39F5
                    cmpx      #$008C
                    lbeq      L39F5
                    cmpx      #$004B
                    lbeq      L3A02
                    cmpx      #$0064
                    lbeq      L3A18
                    cmpx      #$003C
                    lbeq      L3A27
                    cmpx      #$003D
                    lbeq      L3A27
                    cmpx      #$0043
                    lbeq      L3A27
                    cmpx      #$003E
                    lbeq      L3A47
                    cmpx      #$003F
                    lbeq      L3A47
                    cmpx      #$0065
                    lbeq      L3ABA
                    cmpx      #$005A
                    lbeq      L3AC3
                    cmpx      #$005B
                    lbeq      L3AC3
                    cmpx      #$005E
                    lbeq      L3AC3
                    cmpx      #$005C
                    lbeq      L3AC3
                    cmpx      #$005F
                    lbeq      L3AC3
                    cmpx      #$005D
                    lbeq      L3AC3
                    cmpx      #$0050
                    lbeq      L3AC3
                    cmpx      #$0051
                    lbeq      L3AC3
                    cmpx      #$0052
                    lbeq      L3AC3
                    cmpx      #$0053
                    lbeq      L3AC3
                    cmpx      #$0078
                    lbeq      L3AF7
                    lbra      L3BBA

L3CAC               leas      $08,s
                    puls      pc,u
L3CB0               ror       $0C,s
                    clr       $01,s
                    lsr       $7300
L3CB7               pshs      u
                    ldd       #$FFB0
                    lbsr      L010F
                    ldu       $04,s
                    leas      -$04,s
                    ldx       $0a,s
                    bra       L3CDD

L3CC7               lbsr      L4203
                    lbra      L3DEE

L3CCD               ldd       #$0001
                    bra       L3CD4

L3CD2               clra
                    clrb
L3CD4               pshs      d
                    lbsr      L5D4E
                    leas      $02,s
                    bra       L3CFE

L3CDD               cmpx      #$001E
                    beq       L3CC7
                    cmpx      #$000E
                    lbeq      L3CC7
                    cmpx      #$0022
                    lbeq      L3CC7
                    cmpx      #$0021
                    beq       L3CCD
                    cmpx      #$0023
                    lbeq      L3CCD
                    bra       L3CD2

L3CFE               ldd       $0031
                    bne       L3D30
                    leax      $14,u
                    stx       $02,s
                    ldd       $0a,s
                    cmpd      #$000F
                    beq       L3D1C
                    ldd       $0a,s
                    cmpd      #$0023
                    beq       L3D1C
                    ldd       #$0001
                    bra       L3D23

L3D1C               ldd       #$000C
                    std       $08,u
                    clra
                    clrb
L3D23               pshs      d
                    ldd       $04,s
                    pshs      d
                    lbsr      L5815
                    leas      $04,s
                    bra       L3D3C

L3D30               ldd       $06,u
                    pshs      d
                    lbsr      L57C3
                    leas      $02,s
                    lbsr      L577A
L3D3C               ldd       $0C,s
                    cmpd      #$0022
                    bne       L3D90
                    ldd       #$0001
                    std       L0056
                    lbsr      $5F26
                    ldd       $003F
                    cmpd      #$0037
                    bne       L3D89
                    ldd       $04,u
                    std       $02,s
                    ldd       [$02,s]
                    bne       L3D64
                    ldd       $0060
                    std       [$02,s]
                    bra       L3D81

L3D64               ldd       [$02,s]
                    subd      $0060
                    std       ,s
                    blt       L3D76
                    ldd       ,s
                    pshs      d
                    lbsr      L6B34
                    bra       L3D7F

L3D76               leax      L4244,pcr
                    pshs      x
                    lbsr      L0450
L3D7F               leas      $02,s
L3D81               lbsr      $5F26
                    leax      $04,s
                    lbra      L3DE5

L3D89               ldd       #$0002
                    std       L0056
                    bra       L3D98

L3D90               ldd       #$0002
                    std       L0056
                    lbsr      $5F26
L3D98               ldd       $0C,s
                    cmpd      #$0004
                    bne       L3DB5
                    clra
                    clrb
                    pshs      d
                    ldd       $0a,u
L3DA6               pshs      d
                    pshs      u
                    ldd       $12,s
                    pshs      d
                    bsr       L3DF2
                    leas      $08,s
                    bra       L3DE7

L3DB5               ldd       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    bne       L3DC8
                    clra
                    clrb
                    pshs      d
                    ldd       $04,u
                    bra       L3DA6

L3DC8               ldd       #$0001
                    pshs      d
                    ldd       $04,u
                    pshs      d
                    pshs      u
                    ldd       $12,s
                    pshs      d
                    bsr       L3DF2
                    leas      $08,s
                    std       -$02,s
                    bne       L3DE7
                    lbsr      L421A
                    bra       L3DE7

L3DE5               leas      -$04,x
L3DE7               lbsr      L5D64
                    clra
                    clrb
                    std       L0056
L3DEE               leas      $04,s
                    puls      pc,u
L3DF2               pshs      u
                    ldd       #$FFA8
                    lbsr      L010F
                    ldu       $06,s
                    leas      -$0C,s
                    ldd       $16,s
                    bne       L3E0F
                    ldd       #$0029
                    pshs      d
                    lbsr      L06C1
                    leas      $02,s
                    bra       L3E25

L3E0F               ldd       $003F
                    cmpd      #$0029
                    bne       L3E21
                    ldd       #$0001
                    std       $0a,s
                    lbsr      $5F26
                    bra       L3E25

L3E21               clra
                    clrb
                    std       $0a,s
L3E25               ldd       $10,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    lbne      L3F13
                    ldd       [$14,s]
                    std       $02,s
                    bne       L3E3F
                    ldd       #$FFFF
                    std       $02,s
L3E3F               ldd       $10,s
                    pshs      d
                    lbsr      L067C
                    leas      $02,s
                    std       $08,s
                    cmpd      #$0004
                    bne       L3E55
                    ldd       $0a,u
                    bra       L3E5A

L3E55               ldx       $14,s
                    ldd       $02,x
L3E5A               std       $04,s
                    clra
                    clrb
                    std       $06,s
                    bra       L3E98

L3E62               ldd       $16,s
                    addd      #$0001
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    ldd       $0e,s
                    pshs      d
                    lbsr      L3DF2
                    leas      $08,s
                    std       -$02,s
                    lbeq      L3FCA
                    ldd       $06,s
                    addd      #$0001
                    std       $06,s
                    cmpd      $02,s
                    bcc       L3EA0
                    ldd       $003F
                    cmpd      #$0030
                    bne       L3EA0
                    lbsr      $5F26
                    bra       L3E98

L3E98               ldd       $003F
                    cmpd      #$002A
                    bne       L3E62
L3EA0               ldd       $02,s
                    cmpd      #$FFFF
                    bne       L3EAF
                    ldd       $06,s
                    std       [$14,s]
                    bra       L3EDE

L3EAF               ldd       $06,s
                    cmpd      $02,s
                    bcc       L3EDE
                    ldx       $14,s
                    ldd       $02,x
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    ldd       $0C,s
                    pshs      d
                    lbsr      L90F5
                    leas      $06,s
                    pshs      d
                    ldd       $04,s
                    subd      $08,s
                    lbsr      LAF4B
                    pshs      d
                    lbsr      L3FD0
                    leas      $02,s
                    bra       L3EDE

L3EDC               leas      -$0C,x
L3EDE               ldd       $16,s
                    beq       L3EE9
                    ldd       $0a,s
                    lbeq      L3FB7
L3EE9               ldd       $003F
                    cmpd      #$0030
                    bne       L3EF4
                    lbsr      $5F26
L3EF4               ldd       $003F
                    cmpd      #$002A
                    bne       L3F02
                    lbsr      $5F26
                    lbra      L3FB7

L3F02               leax      L424D,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
                    lbsr      L421A
                    lbra      L3FB7

L3F13               ldd       $10,s
                    cmpd      #$0004
                    lbne      L3F9E
                    ldd       $14,s
                    std       ,s
                    bne       L3F6C
                    leax      $425F,pcr
                    lbra      L3FC0

L3F2C               ldx       ,s
                    ldu       $02,x
                    ldd       $16,s
                    addd      #$0001
                    pshs      d
                    ldd       ,u
                    cmpd      #$0004
                    bne       L3F44
                    ldd       $0a,u
                    bra       L3F46

L3F44               ldd       $04,u
L3F46               pshs      d
                    pshs      u
                    ldd       ,u
                    pshs      d
                    lbsr      L3DF2
                    leas      $08,s
                    std       -$02,s
                    lbeq      L3FCA
                    ldd       [,s]
                    std       ,s
                    beq       L3F95
                    ldd       $003F
                    cmpd      #$0030
                    bne       L3F95
                    lbsr      $5F26
                    bra       L3F6C

L3F6C               ldd       $003F
                    cmpd      #$002A
                    bne       L3F2C
                    bra       L3F95

L3F76               ldx       ,s
                    ldu       $02,x
                    ldd       $04,u
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    ldd       ,u
                    pshs      d
                    lbsr      L90F5
                    leas      $06,s
                    pshs      d
                    bsr       L3FD0
                    leas      $02,s
                    ldd       [,s]
                    std       ,s
L3F95               ldd       ,s
                    bne       L3F76
                    leax      $0C,s
                    lbra      L3EDC

L3F9E               ldd       $10,s
                    pshs      d
                    bsr       L3FF1
                    std       ,s++
                    beq       L3FBC
                    ldd       $0a,s
                    beq       L3FB7
                    ldd       #$002A
                    pshs      d
                    lbsr      L06C1
                    leas      $02,s
L3FB7               ldd       #$0001
                    bra       L3FCC

L3FBC               leax      L4272,pcr
L3FC0               pshs      x
                    lbsr      L0450
                    leas      $02,s
                    lbsr      L421A
L3FCA               clra
                    clrb
L3FCC               leas      $0C,s
                    puls      pc,u
L3FD0               pshs      u
                    ldd       #$FFBA
                    lbsr      L010F
                    leax      L428F,pcr
                    pshs      x
                    lbsr      L5756
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L57A5
                    leas      $02,s
                    lbsr      L577A
                    puls      pc,u
L3FF1               pshs      u
                    ldd       #$FFAE
                    lbsr      L010F
                    leas      -$08,s
                    ldd       #$0002
                    pshs      d
                    lbsr      $0785
                    std       ,s
                    lbsr      L111D
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    bne       L4015
                    clra
                    clrb
                    lbra      L419B

L4015               clra
                    clrb
                    std       $04,s
                    ldd       #$0001
                    std       $02,s
                    ldd       ,u
                    std       ,s
                    ldd       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L4054
                    ldx       ,s
                    bra       L4043

L4031               ldd       #$0001
                    bra       L407D

L4036               ldd       ,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    beq       L4086
                    bra       L406A

L4043               cmpx      #$0008
                    beq       L4031
                    cmpx      #$0001
                    beq       L4086
                    cmpx      #$0007
                    beq       L4086
                    bra       L4036

L4054               ldd       ,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L406E
                    ldd       $0C,s
                    pshs      d
                    lbsr      L2832
                    std       ,s++
                    bne       L4086
L406A               leax      $08,s
                    bra       L40A6

L406E               ldd       $0C,s
                    cmpd      #$0005
                    bne       L407B
                    ldd       #$0006
                    bra       L407D

L407B               ldd       $0C,s
L407D               pshs      d
                    pshs      u
                    lbsr      L222C
                    leas      $04,s
L4086               ldd       $06,u
                    cmpd      #$0050
                    beq       L4096
                    ldd       $06,u
                    cmpd      #$0051
                    bne       L40DF
L4096               ldd       $0C,u
                    std       $06,s
                    tfr       d,x
                    ldd       $06,x
                    cmpd      #$0036
                    beq       L40B1
                    bra       L40A8

L40A6               leas      -$08,x
L40A8               clra
                    clrb
                    std       $02,s
                    leax      $08,s
                    lbra      L4190

L40B1               ldd       $06,u
                    cmpd      #$0051
                    bne       L40C3
                    ldx       $06,s
                    ldd       $08,x
                    nega
                    negb
                    sbca      #$00
                    bra       L40C7

L40C3               ldx       $06,s
                    ldd       $08,x
L40C7               std       $04,s
                    ldd       $06,s
                    pshs      d
                    lbsr      L0598
                    leas      $02,s
                    stu       $06,s
                    ldu       $0a,u
                    ldd       $06,s
                    pshs      d
                    lbsr      L05B9
                    leas      $02,s
L40DF               ldd       $06,u
                    cmpd      #$0041
                    lbne      L4143
                    ldd       $0a,u
                    std       $06,s
                    tfr       d,x
                    ldx       $08,x
                    ldx       $08,x
                    bra       L4120

L40F5               clra
                    clrb
                    std       $02,s
                    lbra      L4192

L40FC               lbsr      L5D32
                    ldd       #$0001
                    std       $005A
                    ldd       $04,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    lbsr      L5474
                    leas      $06,s
                    clra
                    clrb
                    std       $005A
                    lbsr      L577A
                    lbra      L4192

L4120               cmpx      #$000F
                    beq       L40FC
                    cmpx      #$000E
                    lbeq      L40FC
                    cmpx      #$000C
                    lbeq      L40FC
                    cmpx      #$0021
                    lbeq      L40FC
                    cmpx      #$0022
                    lbeq      L40FC
                    bra       L40F5

L4143               ldx       $06,u
                    bra       L4177

L4147               ldd       $0C,s
                    cmpd      #$0005
                    bne       L415B
                    ldx       $08,u
                    pshs      x
                    ldx       $08,u
                    lbsr      $A7AE
                    lbsr      LAE24
L415B               ldd       $0C,s
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    bsr       L419F
                    leas      $04,s
                    bra       L4192

L4169               lbsr      L5D32
                    ldd       $08,u
                    pshs      d
                    lbsr      L57B2
                    leas      $02,s
                    bra       L4192

L4177               cmpx      #$004B
                    beq       L4147
                    cmpx      #$0036
                    beq       L415B
                    cmpx      #$004A
                    lbeq      L415B
                    cmpx      #$0037
                    beq       L4169
                    lbra      L40F5

L4190               leas      -$08,x
L4192               pshs      u
                    lbsr      L0598
                    leas      $02,s
                    ldd       $02,s
L419B               leas      $08,s
                    puls      pc,u
L419F               pshs      u
                    ldd       #$FFB6
                    lbsr      L010F
                    ldu       $04,s
                    leas      -$02,s
                    ldx       $08,s
                    bra       L41CF

L41AF               lbsr      L5D2A
                    pshs      u
                    lbsr      L57A5
                    leas      $02,s
                    lbsr      L577A
                    bra       L41FF

L41BE               ldd       #$0001
                    bra       L41CB

L41C3               ldd       #$0002
                    bra       L41CB

L41C8               ldd       #$0004
L41CB               std       ,s
                    bra       L41F4

L41CF               cmpx      #$0002
                    beq       L41AF
                    cmpx      #$0001
                    beq       L41BE
                    cmpx      #$0007
                    lbeq      L41BE
                    cmpx      #$0008
                    beq       L41C3
                    cmpx      #$0005
                    lbeq      L41C3
                    cmpx      #$0006
                    beq       L41C8
                    lbra      L41BE

L41F4               ldd       ,s
                    pshs      d
                    pshs      u
                    lbsr      L5170
                    leas      $04,s
L41FF               leas      $02,s
                    puls      pc,u
L4203               pshs      u
                    ldd       #$FFBA
                    lbsr      L010F
                    leax      $4294,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
                    bsr       L421A
                    puls      pc,u
L421A               pshs      u
                    ldd       #$FFBC
                    lbsr      L010F
L4222               ldx       $003F
                    bra       L422D

L4226               puls      pc,u
L4228               lbsr      $5F26
                    bra       L4222

L422D               cmpx      #$0030
                    beq       L4226
                    cmpx      #$0028
                    lbeq      L4226
                    cmpx      #$FFFF
                    lbeq      L4226
                    bra       L4228
                    puls      pc,u
L4244               lsr       $6F6F
                    bra       $42B5
                    clr       $0e,s
                    asr       0,x
L424D               lsr       $6F6F
                    bra       L42BF
                    fcb       $61
                    jmp       -$07,s
                    bra       $42BC
                    inc       $05,s
                    tst       $05,s
                    jmp       -$0C,s
                    com       >L0075
                    jmp       $09,s
                    clr       $0e,s
                    com       $206E
                    clr       -$0C,s
                    bra       $42CC
                    inc       $0C,s
                    clr       -$09,s
                    fcb       $65
                    lsr       0,x
L4272               com       $0f,s
                    jmp       -$0d,s
                    lsr       $616E
                    lsr       $2065
                    asl       $7072
                    fcb       $65
                    com       $7369
                    clr       $0e,s
                    bra       L42F9
                    fcb       $65
                    fcb       $71
                    fcb       $75
                    rol       -$0e,s
                    fcb       $65
                    lsr       0,x
L428F               fcb       $72
                    dec       $6220
                    neg       L0063
                    fcb       $61
                    jmp       $0e,s
                    clr       -$0C,s
                    bra       $4305
                    jmp       $09,s
                    lsr       $6961
                    inc       $09,s
                    dec       L6500
L42A6               pshs      u
                    leax      $0584,y
                    stx       $004A
                    clra
                    clrb
                    stb       $0584,y
                    ldd       #$0020
                    bra       L42DF

L42B9               pshs      u
                    bra       L42BF

L42BD               bsr       L42CF
L42BF               ldb       $0045
                    cmpb      #$20
                    beq       L42BD
                    ldb       $0045
                    cmpb      #$09
                    lbeq      L42BD
                    puls      pc,u
L42CF               pshs      u
                    ldx       $004A
                    leax      $01,x
                    stx       $004A
                    ldb       -$01,x
                    stb       $0045
                    bne       L42E1
                    bsr       L42E3
L42DF               stb       $0045
L42E1               puls      pc,u
L42E3               pshs      u
                    leas      -$08,s
                    ldd       L0058
                    bne       L42F9
                    ldd       #$0001
                    std       L0058
                    leax      L459E,pcr
                    stx       $004A
                    lbra      L44CC

L42F9               clra
                    clrb
                    std       L0058
                    leax      $0584,y
                    pshs      x
                    leax      $0684,y
                    pshs      x
                    lbsr      $A5D9
                    leas      $04,s
L430E               lbsr      L4509
                    std       $004A
                    lbeq      L4403
                    ldb       [$004A,y]
                    cmpb      #$23
                    lbne      L44C5
                    ldx       $004A
                    ldb       $01,x
                    sex
                    std       $04,s
                    lbsr      L4509
                    std       -$02,s
                    lbeq      L4403
                    ldx       $04,s
                    lbra      L4491

L4336               leax      $0584,y
                    pshs      x
                    lbsr      L44D3
                    leas      $02,s
                    std       $0007
                    bra       L430E

L4345               lbsr      L5D40
L4348               leax      $0584,y
                    pshs      x
                    leax      $459F,pcr
                    bra       L43B5

L4354               leax      $0584,y
                    pshs      x
                    leax      $0366,y
                    pshs      x
                    lbsr      $A5D9
                    leas      $04,s
L4365               lbsr      L4509
                    std       -$02,s
                    lbne      L430E
                    lbra      L4403

L4371               leax      $0584,y
                    pshs      x
                    leax      $078a,y
                    pshs      x
                    lbsr      $A5D9
                    leas      $04,s
                    lbsr      L4509
                    std       -$02,s
                    lbeq      L4403
                    leax      $0584,y
                    pshs      x
                    lbsr      L44D3
                    std       ,s
                    leax      $078a,y
                    pshs      x
                    leax      L45A3,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      L9A34
                    leas      $08,s
                    leax      $078a,y
                    pshs      x
                    leax      L45B9,pcr
L43B5               pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      L9A34
                    leas      $06,s
                    lbra      L430E

L43C3               leax      $0584,y
                    pshs      x
                    leax      $078a,y
                    pshs      x
                    lbsr      $A5D9
                    leas      $04,s
                    lbsr      L4509
                    std       -$02,s
                    beq       L4403
                    leax      $0584,y
                    pshs      x
                    lbsr      L44D3
                    leas      $02,s
                    std       $06,s
                    lbsr      L4509
                    std       -$02,s
                    beq       L4403
                    leax      $0584,y
                    pshs      x
                    lbsr      L44D3
                    leas      $02,s
                    std       $02,s
                    lbsr      L4509
                    std       -$02,s
                    bne       L4409
L4403               ldd       #$FFFF
                    lbra      L44CF

L4409               ldd       $06,s
                    beq       L4424
                    ldd       $06,s
                    pshs      d
                    leax      $0366,y
                    pshs      x
                    leax      L45C2,pcr
                    pshs      x
                    lbsr      L9A1F
                    leas      $06,s
                    bra       L442F

L4424               leax      $45D0,pcr
                    pshs      x
                    lbsr      L9A1F
                    leas      $02,s
L442F               leax      $0584,y
                    pshs      x
                    leax      L45DC,pcr
                    pshs      x
                    lbsr      L9A1F
                    leas      $04,s
                    ldb       $078a,y
                    beq       L447A
                    leax      $078a,y
                    pshs      x
                    lbsr      $9F95
                    leas      $02,s
                    bra       L4463

L4453               leax      $0253,y
                    pshs      x
                    ldd       #$0020
                    pshs      d
                    lbsr      $A1CD
                    leas      $04,s
L4463               ldd       $02,s
                    addd      #$FFFF
                    std       $02,s
                    subd      #$FFFF
                    bne       L4453
                    leax      $45EA,pcr
                    pshs      x
                    lbsr      $9F95
                    leas      $02,s
L447A               ldd       $04,s
                    cmpd      #$0031
                    lbne      L430E
                    ldd       #$0001
                    pshs      d
                    lbsr      LB34C
                    leas      $02,s
                    lbra      L430E

L4491               cmpx      #$0035
                    lbeq      L4336
                    cmpx      #$0036
                    lbeq      L4345
                    cmpx      #$0032
                    lbeq      L4348
                    cmpx      #$0037
                    lbeq      L4354
                    cmpx      #$0050
                    lbeq      L4371
                    cmpx      #$0030
                    lbeq      L43C3
                    cmpx      #$0031
                    lbeq      L43C3
                    lbra      L430E

L44C5               ldd       $0007
                    addd      #$0001
                    std       $0007
L44CC               ldd       #$0020
L44CF               leas      $08,s
                    puls      pc,u
L44D3               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    clra
                    clrb
                    bra       L44F0

L44DD               ldd       ,s
                    pshs      d
                    ldd       #$000A
                    lbsr      LAF4B
                    pshs      d
                    ldd       $04,s
                    addd      #$FFD0
                    addd      ,s++
L44F0               std       ,s
                    ldb       ,u+
                    sex
                    std       $02,s
                    leax      $00BA,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$6b
                    beq       L44DD
                    ldd       ,s
                    leas      $04,s
                    puls      pc,u
L4509               pshs      u,d
                    leau      $0584,y
                    ldd       $0003
                    pshs      d
                    lbsr      $A3E4
                    leas      $02,s
                    std       ,s
                    cmpd      #$FFFF
                    lbne      L4579
                    ldx       $0003
                    ldd       $06,x
                    clra
                    andb      #$20
                    beq       L4546
                    leax      $0260,y
                    pshs      x
                    leax      $45EC,pcr
                    pshs      x
                    lbsr      $9FB7
                    leas      $04,s
                    ldd       #$0001
                    pshs      d
                    lbsr      LB34C
                    leas      $02,s
L4546               clra
                    clrb
                    bra       L459A

L454A               ldx       ,s
                    bra       L456B

L454E               clra
                    clrb
                    stb       ,u
                    leax      $0584,y
                    tfr       x,d
                    bra       L459A

L455A               ldd       ,s
                    stb       ,u+
                    ldd       $0003
                    pshs      d
                    lbsr      $A3E4
                    leas      $02,s
                    std       ,s
                    bra       L4579

L456B               cmpx      #$000D
                    beq       L454E
                    cmpx      #$FFFF
                    lbeq      L454E
                    bra       L455A

L4579               cmpu      $00AC,y
                    bne       L454A
                    ldd       $0007
                    addd      #$0001
                    std       $0007
                    std       L001F
                    leax      $0584,y
                    stx       $0043
                    leax      >L460F,pcr
                    pshs      x
                    lbsr      L042D
                    leas      $02,s
L459A               leas      $02,s
                    puls      pc,u
L459E               neg       L0025
                    com       $0D00
L45A3               bra       $4615
                    fcb       $73,$65,$63,$74,$20,$25,$73,$2C
                    fcb       $30,$2C,$30,$2C,$25,$64,$2C,$30
                    fcb       $2C,$30,$0d,$00
L45B9               bra       $4629
                    fcb       $61
                    tst       0,y
                    bcs       $4633
                    tst       $0000
L45C2               bcs       $4637
                    bra       L4600
                    bra       L4634
                    rol       $0e,s
                    fcb       $65
                    bra       L45F2
                    lsr       0,y
                    neg       L0061
                    fcb       $72
                    asr       -$0b,s
                    tst       $05,s
                    jmp       -$0C,s
                    bra       L4614
                    bra       L45DC

L45DC               bpl       L4608
                    bpl       L460A
                    bra       L4607
                    com       L202A
                    bpl       L4611
                    bpl       L45F6
                    neg       $005E
                    neg       L0049
                    fcb       $4e,$50,$55,$54,$20
L45F2               fcb       $46,$49,$4C,$45
L45F6               fcb       $20,$45,$52,$52,$4f,$52,$20,$3a
                    fcb       $20,$54
L4600               fcb       $45,$4d,$50,$4f,$52,$41,$52
L4607               fcb       $59
L4608               fcb       $20,$46
L460A               fcb       $49,$4C,$45,$0d,$00
L460F               rol       $0e,s
L4611               neg       $7574
L4614               bra       $4682
                    rol       $0e,s
                    fcb       $65
                    bra       $468F
                    clr       $0f,s
                    bra       L468B
                    clr       $0e,s
                    asr       0,x
L4623               pshs      u
                    ldu       $0a,s
                    leas      -$08,s
                    ldd       $0C,s
                    cmpd      #$0088
                    bne       L4641
                    ldd       $10,s
L4634               pshs      d
                    ldd       $10,s
                    pshs      d
                    lbsr      L4D79
                    lbra      L4B9E

L4641               ldd       $0C,s
                    cmpd      #$0087
                    bne       L4659
                    ldd       $10,s
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    lbsr      L4F62
                    lbra      L4B9E

L4659               ldx       $0C,s
                    lbra      L48E7

L465E               ldd       $0e,s
                    pshs      d
                    lbsr      L4D27
                    std       ,s
                    leax      L5898,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      L9A34
                    leas      $06,s
                    ldd       $000F
                    subd      #$0002
                    std       $000F
                    cmpd      $001B
                    lbge      L4D75
                    ldd       $000F
                    std       $001B
                    lbra      L4D75

L468B               ldd       $10,s
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$0081
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
                    ldd       $0e,s
                    std       $10,s
                    ldd       #$005A
                    std       $0e,s
L46AE               leax      $58A2,pcr
                    pshs      x
                    lbsr      L5756
                    leas      $02,s
                    ldd       $0e,s
                    pshs      d
                    lbsr      L56D0
                    std       ,s
                    lbra      L479F

L46C5               ldd       $0017
                    beq       L46CC
                    lbsr      L5CEB
L46CC               leax      $58A5,pcr
                    lbra      L4840

L46D3               pshs      u
                    ldd       $12,s
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    lbsr      L5244
                    leas      $06,s
                    lbra      L4D75

L46E7               leax      $58B0,pcr
                    bra       L4715

L46ED               leax      $58B7,pcr
                    bra       L4715

L46F3               leax      $58BE,pcr
                    bra       L4715

L46F9               leax      $58C4,pcr
                    bra       L4715

L46FF               leax      L58CA,pcr
                    bra       L4715

L4705               leax      L58D0,pcr
                    bra       L4715

L470B               leax      $58D6,pcr
                    bra       L4715

L4711               leax      L58DD,pcr
L4715               pshs      x
                    lbsr      L51F1
                    lbra      L4B24

L471D               leax      L58E3,pcr
                    lbra      L4840

L4724               leax      L58F7,pcr
                    lbra      L4840

L472B               leax      $5902,pcr
                    pshs      x
                    lbsr      L5756
                    leas      $02,s
                    ldd       $000F
                    nega
                    negb
                    sbca      #$00
                    pshs      d
                    lbsr      L57A5
                    leas      $02,s
                    ldd       $00B0,y
                    pshs      d
                    lbsr      L5794
                    leas      $02,s
                    lbsr      L577A
L4751               ldd       $00B4,y
                    pshs      d
                    lbsr      L5756
                    leas      $02,s
                    ldd       $0e,s
                    bra       L47A7

L4760               ldd       $00B4,y
                    pshs      d
                    lbsr      L5756
                    leas      $02,s
                    ldd       $000B
                    addd      #$0001
                    std       $000B
                    std       $10,s
                    pshs      d
                    lbsr      L57B2
                    leas      $02,s
                    ldd       $0e,s
                    pshs      d
                    lbsr      L57B2
                    leas      $02,s
                    leax      L5908,pcr
                    pshs      x
                    lbsr      L5756
                    leas      $02,s
                    ldd       $000F
                    pshs      d
                    lbsr      L57A5
                    leas      $02,s
                    leax      L590E,pcr
                    pshs      x
L479F               lbsr      L5794
                    leas      $02,s
                    ldd       $10,s
L47A7               pshs      d
                    lbsr      L57B2
                    lbra      L4B24

L47AF               ldd       #$0004
                    std       $0013
                    ldx       $10,s
                    ldd       $06,x
                    cmpd      #$0034
                    bne       L47E4
                    ldx       $10,s
                    ldd       $08,x
                    std       $04,s
                    beq       L47E4
                    ldd       $00B2,y
                    pshs      d
                    lbsr      L5756
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    ldd       $06,s
                    addd      #$0014
                    pshs      d
                    lbsr      L5815
                    lbra      L4B9E

L47E4               leax      L5912,pcr
                    pshs      x
                    lbsr      L5756
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    ldd       $12,s
                    pshs      d
                    ldd       $12,s
                    pshs      d
                    lbsr      L5474
                    leas      $06,s
                    lbra      L4877

L4805               leax      L5917,pcr
                    bra       L4840

L480B               leax      $591B,pcr
                    pshs      x
                    lbsr      L5756
                    leas      $02,s
                    ldd       #$0002
                    pshs      d
                    ldd       $12,s
                    pshs      d
                    ldd       $12,s
                    pshs      d
                    ldd       #$0064
                    pshs      d
                    lbsr      L5429
                    lbra      L4C78

L4830               leax      L591E,pcr
                    bra       L4840

L4836               leax      $5929,pcr
                    bra       L4840

L483C               leax      $5934,pcr
L4840               pshs      x
                    lbra      L4B21

L4845               leax      $593F,pcr
                    pshs      x
                    lbsr      L5756
                    leas      $02,s
                    leax      $08,s
                    bra       L4861

L4854               leax      L5944,pcr
                    pshs      x
                    lbsr      L5756
                    leas      $02,s
                    bra       L4863

L4861               leas      -$08,x
L4863               ldd       $0e,s
                    pshs      d
                    lbsr      L57A5
                    leas      $02,s
                    ldd       $00B0,y
                    pshs      d
                    lbsr      L5794
                    leas      $02,s
L4877               lbsr      L577A
                    lbra      L4D75

L487D               leax      L5949,pcr
                    pshs      x
                    lbsr      L5756
                    leas      $02,s
                    ldx       $0e,s
                    bra       L48DA

L488C               ldx       $10,s
                    ldd       $06,x
                    std       $06,s
                    cmpd      #$0094
                    bne       L489E
                    ldd       #$0079
                    bra       L48AE

L489E               ldd       $06,s
                    cmpd      #$0095
                    bne       L48AB
                    ldd       #$0075
                    bra       L48AE

L48AB               ldd       #$0078
L48AE               std       $06,s
                    pshs      d
                    ldx       $12,s
                    ldd       $08,x
                    pshs      d
                    leax      L594F,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      L9A34
                    lbra      L4C78

L48C9               ldd       $10,s
                    pshs      d
                    lbsr      L4D27
                    std       ,s
                    leax      $5956,pcr
                    lbra      L4B47

L48DA               cmpx      #$0077
                    beq       L488C
                    cmpx      #$0070
                    beq       L48C9
                    lbra      L4D75

L48E7               cmpx      #$007A
                    lbeq      L465E
                    cmpx      #$007D
                    lbeq      L468B
                    cmpx      #$0082
                    lbeq      L46AE
                    cmpx      #$0012
                    lbeq      L46C5
                    cmpx      #$0057
                    lbeq      L46D3
                    cmpx      #$0058
                    lbeq      L46D3
                    cmpx      #$0059
                    lbeq      L46D3
                    cmpx      #$0052
                    lbeq      L46E7
                    cmpx      #$004E
                    lbeq      L46ED
                    cmpx      #$0053
                    lbeq      L46F3
                    cmpx      #$0056
                    lbeq      L46F9
                    cmpx      #$0055
                    lbeq      L46FF
                    cmpx      #$004D
                    lbeq      L4705
                    cmpx      #$004C
                    lbeq      L470B
                    cmpx      #$0054
                    lbeq      L4711
                    cmpx      #$0043
                    lbeq      L471D
                    cmpx      #$0044
                    lbeq      L4724
                    cmpx      #start
                    lbeq      L472B
                    cmpx      #$007C
                    lbeq      L4751
                    cmpx      #$0009
                    lbeq      L4760
                    cmpx      #$0065
                    lbeq      L47AF
                    cmpx      #$0085
                    lbeq      L4805
                    cmpx      #$0084
                    lbeq      L480B
                    cmpx      #$0098
                    lbeq      L4830
                    cmpx      #$0096
                    lbeq      L4836
                    cmpx      #$0097
                    lbeq      L483C
                    cmpx      #$0076
                    lbeq      L4845
                    cmpx      #$006F
                    lbeq      L4854
                    cmpx      #$007B
                    lbeq      L487D
                    ldd       $0e,s
                    pshs      d
                    lbsr      L4D27
                    leas      $02,s
                    std       $06,s
                    ldd       $10,s
                    cmpd      #$0077
                    lbne      L4A40
                    ldd       $06,u
                    cmpd      #$0085
                    bne       L4A23
                    ldd       $0a,u
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       $12,s
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
                    ldx       $0C,s
                    bra       L4A05

L49EC               leax      $595C,pcr
                    bra       L49FC

L49F2               leax      $5960,pcr
                    bra       L49FC

L49F8               leax      L5968,pcr
L49FC               pshs      x
                    lbsr      L576F
                    leas      $02,s
                    bra       L4A1B

L4A05               cmpx      #$0075
                    beq       L49EC
                    cmpx      #$004F
                    beq       L49F2
                    cmpx      #$0050
                    lbeq      L49F2
                    cmpx      #$0051
                    beq       L49F8
L4A1B               ldd       #$0070
                    std       $06,u
                    lbra      L4D75

L4A23               ldd       ,u
                    cmpd      #$0002
                    bne       L4A40
                    ldd       $0C,s
                    cmpd      #$007F
                    beq       L4A40
                    ldd       $06,s
                    cmpd      #$0078
                    beq       L4A40
                    ldd       #$0062
                    std       $06,s
L4A40               ldx       $0C,s
                    lbra      L4CE6

L4A45               ldd       $10,s
                    cmpd      #$0077
                    lbne      L4B04
                    ldd       $08,u
                    std       ,s
                    ldd       $06,u
                    std       $02,s
                    tfr       d,x
                    lbra      L4AE0

L4A5D               ldd       $0e,s
                    cmpd      #$0070
                    beq       L4A82
                    ldd       $06,s
                    pshs      d
                    lbsr      L5832
                    leas      $02,s
                    ldd       $02,s
                    pshs      d
                    lbsr      L4D27
                    std       ,s
                    ldd       $02,s
                    pshs      d
                    leax      L5970,pcr
                    lbra      L4C6F

L4A82               ldd       #$0064
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    lbsr      L4D27
                    std       ,s
                    lbsr      L4D5E
                    leas      $04,s
                    ldd       ,s
                    lbeq      L4D75
                    ldd       ,s
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0050
                    pshs      d
                    lbsr      L4623
                    lbra      L4C78

L4AB4               ldd       $0e,s
                    cmpd      #$0070
                    lbeq      L4D75
                    ldd       $06,s
                    pshs      d
                    ldd       #$0064
                    lbra      L4B99

L4AC8               ldd       $08,u
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L5849
                    lbra      L4B9E

L4AD6               ldd       #$0036
                    std       $10,s
                    ldu       ,s
                    bra       L4B04

L4AE0               cmpx      #$0071
                    lbeq      L4A5D
                    cmpx      #$0076
                    lbeq      L4A5D
                    cmpx      #$006F
                    lbeq      L4A5D
                    cmpx      #$0070
                    beq       L4AB4
                    cmpx      #$0037
                    beq       L4AC8
                    cmpx      #$0036
                    beq       L4AD6
L4B04               ldd       $0e,s
                    cmpd      #$0070
                    bne       L4B29
                    ldd       $10,s
                    cmpd      #$0036
                    bne       L4B29
                    cmpu      #$0000
                    bne       L4B29
                    leax      $5977,pcr
                    pshs      x
L4B21               lbsr      L576F
L4B24               leas      $02,s
                    lbra      L4D75

L4B29               leax      $5982,pcr
                    lbra      L4BAD

L4B30               ldd       $10,s
                    cmpd      #$0036
                    bne       L4B55
                    cmpu      #$0000
                    bne       L4B55
                    ldd       $06,s
                    pshs      d
                    leax      L5985,pcr
L4B47               pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      L9A34
                    leas      $06,s
                    lbra      L4D75

L4B55               leax      L5991,pcr
                    pshs      x
                    lbsr      L5756
                    leas      $02,s
                    ldd       $06,s
                    cmpd      #$0062
                    bne       L4BB4
                    ldd       #$0064
                    std       $06,s
                    bra       L4BB4

L4B6F               ldd       $10,s
                    cmpd      #$0077
                    bne       L4BA3
                    ldd       $06,u
                    std       $02,s
                    pshs      d
                    lbsr      L8132
                    std       ,s++
                    beq       L4BA3
                    ldd       $02,s
                    cmpd      $0e,s
                    lbeq      L4D75
                    ldd       $02,s
                    pshs      d
                    lbsr      L4D27
                    std       ,s
                    ldd       $08,s
L4B99               pshs      d
                    lbsr      L4D5E
L4B9E               leas      $04,s
                    lbra      L4D75

L4BA3               leax      $5995,pcr
                    bra       L4BAD

L4BA9               leax      $5998,pcr
L4BAD               pshs      x
                    lbsr      L5756
                    leas      $02,s
L4BB4               leax      $08,s
                    bra       L4BC9

L4BB8               ldd       #$0043
                    pshs      d
                    lbsr      L4623
                    leas      $02,s
L4BC2               leax      $599C,pcr
                    lbra      L4C42

L4BC9               leas      -$08,x
                    lbra      L4C49

L4BCE               ldd       $10,s
                    cmpd      #$0077
                    lbne      L4C3E
                    ldx       $08,u
                    ldd       $08,x
                    std       $02,s
                    tfr       d,x
                    bra       L4C2B

L4BE3               ldd       $06,s
                    pshs      d
                    lbsr      L5832
                    leas      $02,s
                    ldd       #$003E
                    pshs      d
                    lbsr      L5785
                    leas      $02,s
                    ldd       $02,s
                    cmpd      #$0023
                    bne       L4C09
                    ldx       $08,u
                    ldd       $06,x
                    pshs      d
                    lbsr      L57C3
                    bra       L4C13

L4C09               ldd       $08,u
                    addd      #$0014
                    pshs      d
                    lbsr      L57D6
L4C13               leas      $02,s
                    ldd       $14,u
                    pshs      d
                    lbsr      L5453
                    leas      $02,s
                    ldd       $00AE,y
                    pshs      d
                    lbsr      L5794
                    lbra      L4CB6

L4C2B               cmpx      #$0021
                    beq       L4BE3
                    cmpx      #$0022
                    lbeq      L4BE3
                    cmpx      #$0023
                    lbeq      L4BE3
L4C3E               leax      $59A0,pcr
L4C42               pshs      x
                    lbsr      L5756
                    leas      $02,s
L4C49               clra
                    clrb
                    pshs      d
                    pshs      u
                    ldd       $14,s
                    pshs      d
                    ldd       $0C,s
                    pshs      d
                    lbsr      L5429
                    bra       L4C78

L4C5D               ldd       $10,s
                    pshs      d
                    lbsr      L4D27
                    std       ,s
                    ldd       $08,s
                    pshs      d
                    leax      $59A4,pcr
L4C6F               pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      L9A34
L4C78               leas      $08,s
                    lbra      L4D75

L4C7D               ldd       $06,s
                    pshs      d
                    lbsr      L5832
                    leas      $02,s
                    ldx       $10,s
                    bra       L4CCC

L4C8B               leax      $59B0,pcr
                    pshs      x
                    lbsr      L5794
                    leas      $02,s
                    leax      $08,s
                    bra       L4CAD

L4C9A               pshs      u
                    lbsr      L57A5
                    leas      $02,s
                    ldd       #$002C
                    pshs      d
                    lbsr      L5785
                    leas      $02,s
                    bra       L4CAF

L4CAD               leas      -$08,x
L4CAF               ldd       $06,s
                    pshs      d
                    lbsr      L5785
L4CB6               leas      $02,s
                    lbsr      L577A
                    lbra      L4D75

L4CBE               leax      L59B3,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
                    lbra      L4D75

L4CCC               cmpx      #$0070
                    beq       L4C8B
                    cmpx      #$0036
                    beq       L4C9A
                    bra       L4CBE

L4CD8               ldd       $00B8,y
                    pshs      d
                    lbsr      L0450
                    leas      $02,s
                    lbra      L4D75

L4CE6               cmpx      #$0075
                    lbeq      L4A45
                    cmpx      #$0081
                    lbeq      L4B30
                    cmpx      #$0079
                    lbeq      L4B6F
                    cmpx      #$0051
                    lbeq      L4BA9
                    cmpx      #$004F
                    lbeq      L4BB8
                    cmpx      #$0050
                    lbeq      L4BC2
                    cmpx      #$007F
                    lbeq      L4BCE
                    cmpx      #$0073
                    lbeq      L4C5D
                    cmpx      #$0074
                    lbeq      L4C7D
                    bra       L4CD8

L4D27               pshs      u
                    ldx       $04,s
                    bra       L4D46

L4D2D               ldd       #$0064
                    puls      pc,u
L4D32               ldd       #$0078
                    puls      pc,u
L4D37               ldd       #$0079
                    puls      pc,u
L4D3C               ldd       #$0075
                    puls      pc,u
L4D41               ldd       #$0020
                    puls      pc,u
L4D46               cmpx      #$0070
                    beq       L4D2D
                    cmpx      #$0071
                    beq       L4D32
                    cmpx      #$0076
                    beq       L4D37
                    cmpx      #$006F
                    beq       L4D3C
                    bra       L4D41
                    puls      pc,u
L4D5E               pshs      u
                    ldd       $06,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    leax      L59BB,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      L9A34
L4D75               leas      $08,s
                    puls      pc,u
L4D79               pshs      u
                    ldx       $04,s
                    lbra      L4E99

L4D80               ldd       #$0002
                    pshs      d
                    ldd       #$0093
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
                    ldd       #$0070
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
                    clra
                    clrb
                    pshs      d
                    ldd       #$0093
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
                    ldd       #$0070
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L4623
                    lbra      L4F75

L4DD0               leax      L59C7,pcr
                    pshs      x
                    lbsr      L576F
                    lbra      L5470

L4DDC               leax      $59EA,pcr
                    bra       L4E1C

L4DE2               leax      $59F1,pcr
                    bra       L4E2F

L4DE8               leax      $59F7,pcr
                    bra       L4E2F

L4DEE               leax      $59FD,pcr
                    bra       L4E2F

L4DF4               leax      L5A03,pcr
                    bra       L4E2F

L4DFA               leax      $5A09,pcr
                    bra       L4E2F

L4E00               leax      $5A0F,pcr
                    bra       L4E2F

L4E06               leax      $5A15,pcr
                    bra       L4E2F

L4E0C               leax      $5A1A,pcr
                    bra       L4E2F

L4E12               leax      $5A20,pcr
                    bra       L4E1C

L4E18               leax      $5A26,pcr
L4E1C               pshs      x
                    lbsr      L520E
                    leas      $02,s
                    ldd       $000F
                    subd      #$0002
                    lbra      L5229

L4E2B               leax      $5A2C,pcr
L4E2F               pshs      x
                    lbsr      L520E
                    lbra      L5470

L4E37               leax      $5A33,pcr
                    bra       L4E59

L4E3D               leax      L5A39,pcr
                    bra       L4E59

L4E43               leax      L5A41,pcr
                    bra       L4E59

L4E49               leax      $5A48,pcr
                    bra       L4E59

L4E4F               leax      $5A4F,pcr
                    bra       L4E59

L4E55               leax      $5A55,pcr
L4E59               pshs      x
                    lbsr      L520E
                    leas      $02,s
                    ldd       $000F
                    subd      #$0004
                    lbra      L5229

L4E68               ldd       #$0002
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbra      L4F72

L4E74               leax      L5A5B,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
                    ldd       $00B8,y
                    pshs      d
                    lbsr      L5794
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L57A5
                    leas      $02,s
                    lbsr      L577A
                    lbra      L4F60

L4E99               cmpx      #$006E
                    lbeq      L4D80
                    cmpx      #$008B
                    lbeq      L4DD0
                    cmpx      #$0089
                    lbeq      L4DDC
                    cmpx      #$0050
                    lbeq      L4DE2
                    cmpx      #$0051
                    lbeq      L4DE8
                    cmpx      #$0052
                    lbeq      L4DEE
                    cmpx      #$0053
                    lbeq      L4DF4
                    cmpx      #$0054
                    lbeq      L4DFA
                    cmpx      #$0057
                    lbeq      L4E00
                    cmpx      #$0058
                    lbeq      L4E06
                    cmpx      #$0059
                    lbeq      L4E0C
                    cmpx      #$0056
                    lbeq      L4E12
                    cmpx      #$0055
                    lbeq      L4E18
                    cmpx      #$005A
                    lbeq      L4E2B
                    cmpx      #$005B
                    lbeq      L4E2B
                    cmpx      #$005E
                    lbeq      L4E2B
                    cmpx      #$005C
                    lbeq      L4E2B
                    cmpx      #$005F
                    lbeq      L4E2B
                    cmpx      #$005D
                    lbeq      L4E2B
                    cmpx      #$0043
                    lbeq      L4E37
                    cmpx      #$0044
                    lbeq      L4E3D
                    cmpx      #$0083
                    lbeq      L4E43
                    cmpx      #$0086
                    lbeq      L4E49
                    cmpx      #$003C
                    lbeq      L4E4F
                    cmpx      #$003E
                    lbeq      L4E4F
                    cmpx      #$003D
                    lbeq      L4E55
                    cmpx      #$003F
                    lbeq      L4E55
                    cmpx      #$004A
                    lbeq      L4E68
                    lbra      L4E74

L4F60               puls      pc,u
L4F62               pshs      u
                    ldu       $06,s
                    ldx       $04,s
                    lbra      L5075

L4F6B               ldd       #$0004
                    pshs      d
                    pshs      u
L4F72               lbsr      L5130
L4F75               leas      $04,s
                    puls      pc,u
L4F79               leax      $5A6A,pcr
                    pshs      x
                    lbsr      L522D
                    leas      $02,s
                    ldd       $000F
                    subd      #$0008
                    lbra      L5229

L4F8C               cmpu      #$0005
                    bne       L4F97
                    ldd       #$0033
                    bra       L4F9A

L4F97               ldd       #$0037
L4F9A               pshs      d
                    leax      $5A72,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      L9A34
                    leas      $06,s
                    puls      pc,u
L4FAD               cmpu      #$0005
                    bne       L4FB9
                    leax      L5A7D,pcr
                    bra       L4FBD

L4FB9               leax      $5A84,pcr
L4FBD               tfr       x,d
                    pshs      d
                    lbsr      L522D
                    lbra      L5205

L4FC7               leax      $5A8B,pcr
                    bra       L4FE3

L4FCD               leax      $5A91,pcr
                    bra       L4FE3

L4FD3               leax      $5A97,pcr
                    bra       L4FE3

L4FD9               leax      L5A9D,pcr
                    bra       L4FE3

L4FDF               leax      $5AA3,pcr
L4FE3               pshs      x
                    lbsr      L522D
                    leas      $02,s
                    ldd       $000F
                    addd      #$0008
                    lbra      L5229

L4FF2               leax      $5AAA,pcr
                    bra       L5048

L4FF8               cmpu      #$0005
                    bne       L5004
                    leax      L5AB0,pcr
                    bra       L501A

L5004               leax      $5AB6,pcr
                    bra       L501A

L500A               cmpu      #$0005
                    bne       L5016
                    leax      $5ABC,pcr
                    bra       L501A

L5016               leax      L5AC2,pcr
L501A               tfr       x,d
                    pshs      d
                    bra       L504A

L5020               leax      L5AC8,pcr
                    bra       L5048

L5026               leax      $5ACE,pcr
                    bra       L5048

L502C               leax      $5AD4,pcr
                    bra       L5048

L5032               leax      $5ADA,pcr
                    bra       L5048

L5038               leax      $5AE0,pcr
                    bra       L5048

L503E               leax      $5AE6,pcr
                    bra       L5048

L5044               leax      $5AEC,pcr
L5048               pshs      x
L504A               lbsr      L522D
                    lbra      L5470

L5050               leax      $5AF2,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
                    ldd       $00B8,y
                    pshs      d
                    lbsr      L5794
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L57A5
                    leas      $02,s
                    lbsr      L577A
                    lbra      L512E

L5075               cmpx      #$004B
                    lbeq      L4F6B
                    cmpx      #$006E
                    lbeq      L4F79
                    cmpx      #$008B
                    lbeq      L4F8C
                    cmpx      #$0089
                    lbeq      L4FAD
                    cmpx      #$0050
                    lbeq      L4FC7
                    cmpx      #$0051
                    lbeq      L4FCD
                    cmpx      #$0052
                    lbeq      L4FD3
                    cmpx      #$0053
                    lbeq      L4FD9
                    cmpx      #$005A
                    lbeq      L4FDF
                    cmpx      #$005B
                    lbeq      L4FDF
                    cmpx      #$005E
                    lbeq      L4FDF
                    cmpx      #$005C
                    lbeq      L4FDF
                    cmpx      #$005F
                    lbeq      L4FDF
                    cmpx      #$005D
                    lbeq      L4FDF
                    cmpx      #$0043
                    lbeq      L4FF2
                    cmpx      #$003C
                    lbeq      L4FF8
                    cmpx      #$003E
                    lbeq      L4FF8
                    cmpx      #$003D
                    lbeq      L500A
                    cmpx      #$003F
                    lbeq      L500A
                    cmpx      #$008D
                    lbeq      L5020
                    cmpx      #$008C
                    lbeq      L5026
                    cmpx      #$0090
                    lbeq      L502C
                    cmpx      #$008E
                    lbeq      L5032
                    cmpx      #$0092
                    lbeq      L5038
                    cmpx      #$0091
                    lbeq      L503E
                    cmpx      #$008F
                    lbeq      L5044
                    lbra      L5050

L512E               puls      pc,u
L5130               pshs      u,d
                    leax      L5B02,pcr
                    pshs      x
                    lbsr      L5756
                    leas      $02,s
                    ldd       $000B
                    addd      #$0001
                    std       $000B
                    std       ,s
                    pshs      d
                    lbsr      L57B2
                    leas      $02,s
                    ldd       $08,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    bsr       L5170
                    leas      $04,s
                    ldd       ,s
                    pshs      d
                    lbsr      L57C3
                    leas      $02,s
                    leax      $5B07,pcr
                    pshs      x
                    lbsr      L576F
                    leas      $02,s
                    lbra      L5470

L5170               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    lbsr      L5D32
                    ldd       $08,s
                    cmpd      #$0001
                    bne       L518B
                    pshs      u
                    lbsr      L57A5
L5186               leas      $02,s
                    lbra      L51EB

L518B               cmpu      #$0000
                    bne       L51BC
                    ldd       #$0001
                    std       ,s
                    bra       L51A3

L5198               leax      $5B0E,pcr
                    pshs      x
                    lbsr      L5794
                    leas      $02,s
L51A3               ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    cmpd      $08,s
                    blt       L5198
                    ldd       #$0030
                    pshs      d
                    lbsr      L5785
                    bra       L5186

L51BC               clra
                    clrb
                    bra       L51E2

L51C0               ldd       ,u++
                    pshs      d
                    lbsr      L57A5
                    leas      $02,s
                    ldd       $08,s
                    addd      #$FFFF
                    cmpd      ,s
                    beq       L51DD
                    ldd       #$002C
                    pshs      d
                    lbsr      L5785
                    leas      $02,s
L51DD               ldd       ,s
                    addd      #$0001
L51E2               std       ,s
                    ldd       ,s
                    cmpd      $08,s
                    blt       L51C0
L51EB               lbsr      L577A
                    lbra      L5470

L51F1               pshs      u
                    ldd       $00B2,y
                    pshs      d
                    lbsr      L5756
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L576F
L5205               leas      $02,s
                    ldd       $000F
                    addd      #$0002
                    bra       L5229

L520E               pshs      u
                    ldd       $00B2,y
                    pshs      d
                    lbsr      L5756
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L576F
                    leas      $02,s
                    ldd       $000F
                    addd      #$0004
L5229               std       $000F
                    puls      pc,u
L522D               pshs      u
                    ldd       $00B2,y
                    pshs      d
                    lbsr      L5756
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L576F
                    lbra      L5470

L5244               pshs      u
                    ldu       $04,s
                    leas      -$06,s
                    clra
                    clrb
                    std       $02,s
                    ldd       $0C,s
                    cmpd      #$0077
                    bne       L5274
                    ldd       [$0e,s]
                    cmpd      #$0002
                    bne       L5264
                    ldd       #$0001
                    bra       L5266

L5264               clra
                    clrb
L5266               std       $02,s
                    ldx       $0e,s
                    ldd       $06,x
                    std       $0C,s
                    ldx       $0e,s
                    ldd       $08,x
                    std       $0e,s
L5274               leax      ,u
                    bra       L528C

L5278               leax      L5B11,pcr
                    bra       L5288

L527E               leax      $5B15,pcr
                    bra       L5288

L5284               leax      $5B18,pcr
L5288               stx       $04,s
                    bra       L529B

L528C               cmpx      #$0057
                    beq       L5278
                    cmpx      #$0058
                    beq       L527E
                    cmpx      #$0059
                    beq       L5284
L529B               ldx       $0C,s
                    lbra      L53FB

L52A0               ldd       $02,s
                    beq       L52C2
                    cmpu      #$0057
                    bne       L52B5
                    ldd       $00B6,y
                    pshs      d
                    lbsr      L576F
                    leas      $02,s
L52B5               ldd       $04,s
                    pshs      d
                    lbsr      L5756
                    leas      $02,s
                    clra
                    clrb
                    bra       L52EF

L52C2               ldd       $04,s
                    pshs      d
                    lbsr      L5756
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    ldd       #$0061
                    pshs      d
                    lbsr      L5429
                    leas      $08,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L5756
                    leas      $02,s
                    ldd       #$0001
L52EF               pshs      d
                    ldd       $10,s
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    ldd       #$0062
                    pshs      d
                    lbsr      L5429
                    leas      $08,s
                    lbra      L5425

L5308               ldd       $0e,s
                    pshs      d
                    ldd       #$0008
                    lbsr      LB069
                    clra
                    std       ,s
                    tfr       d,x
                    bra       L5362

L5319               cmpu      #$0057
                    bne       L536D
                    ldd       $00B6,y
                    pshs      d
                    bra       L5339

L5327               cmpu      #$0057
                    beq       L536D
                    cmpu      #$0059
                    bne       L5340
                    leax      $5B1C,pcr
                    pshs      x
L5339               lbsr      L576F
                    leas      $02,s
                    bra       L536D

L5340               ldd       $04,s
                    pshs      d
                    lbsr      L5756
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       #$0061
                    pshs      d
                    lbsr      L5429
                    leas      $08,s
                    bra       L536D

L5362               stx       -$02,s
                    beq       L5319
                    cmpx      #$00FF
                    beq       L5327
                    bra       L5340

L536D               ldd       $0e,s
                    clra
                    std       ,s
                    tfr       d,x
                    bra       L53C3

L5376               cmpu      #$0057
                    lbne      L5425
                    leax      $5B21,pcr
                    bra       L5396

L5384               cmpu      #$0057
                    lbeq      L5425
                    cmpu      #$0059
                    bne       L53A0
                    leax      $5B26,pcr
L5396               pshs      x
                    lbsr      L576F
                    leas      $02,s
                    lbra      L5425

L53A0               ldd       $04,s
                    pshs      d
                    lbsr      L5756
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       #$0062
                    pshs      d
                    lbsr      L5429
                    leas      $08,s
                    lbra      L5425

L53C3               stx       -$02,s
                    beq       L5376
                    cmpx      #$00FF
                    beq       L5384
                    bra       L53A0

L53CE               ldd       $04,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    leax      $5B2B,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      L9A34
                    leas      $08,s
                    ldd       $000F
                    addd      #$0002
                    std       $000F
                    bra       L5425

L53EE               leax      $5B3E,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
                    bra       L5425

L53FB               cmpx      #$0034
                    lbeq      L52A0
                    cmpx      #$0094
                    lbeq      L52A0
                    cmpx      #$0095
                    lbeq      L52A0
                    cmpx      #$0093
                    lbeq      L52A0
                    cmpx      #$0036
                    lbeq      L5308
                    cmpx      #$006E
                    beq       L53CE
                    bra       L53EE

L5425               leas      $06,s
                    puls      pc,u
L5429               pshs      u
                    ldd       $04,s
                    pshs      d
                    lbsr      L5785
                    leas      $02,s
                    ldd       #$0020
                    pshs      d
                    lbsr      L5785
                    leas      $02,s
                    ldd       $0a,s
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    bsr       L5474
                    leas      $06,s
                    lbsr      L577A
                    puls      pc,u
L5453               pshs      u
                    ldu       $04,s
                    stu       -$02,s
                    beq       L5472
                    cmpu      #$0000
                    ble       L546B
                    ldd       #$002B
                    pshs      d
                    lbsr      L5785
                    leas      $02,s
L546B               pshs      u
                    lbsr      L57A5
L5470               leas      $02,s
L5472               puls      pc,u
L5474               pshs      u,x,d
                    ldd       $08,s
                    anda      #$80
                    clrb
                    std       -$02,s
                    beq       L5489
                    ldd       #$005B
                    pshs      d
                    lbsr      L5785
                    leas      $02,s
L5489               ldd       $08,s
                    anda      #$7f
                    tfr       d,x
                    lbra      L5680

L5492               ldu       $0a,s
                    ldd       $06,u
                    cmpd      #$0041
                    bne       L54B3
                    ldd       #$0023
                    pshs      d
                    lbsr      L5785
                    leas      $02,s
                    ldd       $0C,s
                    pshs      d
                    ldd       $0a,u
                    pshs      d
                    ldd       #$0077
                    bra       L54C0

L54B3               ldd       $0C,s
                    addd      $14,u
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    ldd       $06,u
L54C0               pshs      d
                    bsr       L5474
                    leas      $06,s
                    lbra      L57A1

L54C9               ldd       #$0023
                    pshs      d
                    lbsr      L5785
                    leas      $02,s
                    ldd       $0a,s
                    lbra      L5605

L54D8               leax      $5B4F,pcr
                    pshs      x
                    lbsr      L5794
                    leas      $02,s
                    ldd       $0C,s
                    pshs      d
                    lbsr      L5453
                    leas      $02,s
                    ldd       $00AE,y
                    pshs      d
                    lbsr      L5794
                    lbra      L567C

L54F8               ldu       $0a,s
                    lbeq      L5603
                    ldd       $08,u
                    std       ,s
                    tfr       d,x
                    lbra      L55D0

L5507               ldd       $06,u
                    subd      $000F
                    addd      $0C,s
                    std       $0a,s
                    pshs      d
                    lbsr      L57A5
                    leas      $02,s
                    ldd       $00B0,y
                    lbra      L55C1

L551D               ldd       $005A
                    bne       L5539
                    ldd       $08,s
                    anda      #$80
                    clrb
                    std       -$02,s
                    beq       L552F
                    ldd       #$003E
                    bra       L5532

L552F               ldd       #$003C
L5532               pshs      d
                    lbsr      L5785
                    leas      $02,s
L5539               ldd       $06,u
                    pshs      d
                    lbsr      L57C3
                    leas      $02,s
                    leax      $04,s
                    bra       L5572

L5546               ldd       $005A
                    bne       L5562
                    ldd       $08,s
                    anda      #$80
                    clrb
                    std       -$02,s
                    beq       L5558
                    ldd       #$003E
                    bra       L555B

L5558               ldd       #$003C
L555B               pshs      d
                    lbsr      L5785
                    leas      $02,s
L5562               pshs      u
                    ldd       #$0014
                    addd      ,s++
                    pshs      d
                    lbsr      L57D6
                    leas      $02,s
                    bra       L5574

L5572               leas      -$04,x
L5574               ldd       $0C,s
                    pshs      d
                    lbsr      L5453
                    leas      $02,s
                    ldd       $08,s
                    anda      #$80
                    clrb
                    std       -$02,s
                    bne       L55AA
                    ldd       $005A
                    lbne      L56B8
                    ldd       ,s
                    cmpd      #$0021
                    lbeq      L56B8
                    ldd       ,s
                    cmpd      #$0022
                    lbeq      L56B8
                    ldd       ,s
                    cmpd      #$0023
                    lbeq      L56B8
L55AA               ldd       ,u
                    clra
                    andb      #$30
                    cmpd      #$0030
                    bne       L55BD
                    leax      $5B56,pcr
                    pshs      x
                    bra       L55C3

L55BD               ldd       $00AE,y
L55C1               pshs      d
L55C3               lbsr      L5794
                    lbra      L567C

L55C9               leax      $5B5B,pcr
                    lbra      L5677

L55D0               cmpx      #$000D
                    lbeq      L5507
                    cmpx      #$0023
                    lbeq      L551D
                    cmpx      #$000F
                    lbeq      L5539
                    cmpx      #$0021
                    lbeq      L5546
                    cmpx      #$0022
                    lbeq      L5546
                    cmpx      #$000E
                    lbeq      L5562
                    cmpx      #$000C
                    lbeq      L5562
                    bra       L55C9

L5603               ldd       $0C,s
L5605               pshs      d
                    lbsr      L57A5
                    lbra      L567C

L560D               ldd       $0a,s
                    addd      $0C,s
                    std       $0a,s
                    pshs      d
                    lbsr      L57A5
                    leas      $02,s
                    ldd       #$002C
                    pshs      d
                    lbsr      L5785
                    leas      $02,s
                    ldd       $08,s
                    anda      #$7f
                    tfr       d,x
                    bra       L5643

L562C               ldd       #$0078
                    bra       L5639

L5631               ldd       #$0079
                    bra       L5639

L5636               ldd       #$0075
L5639               pshs      d
                    lbsr      L5785
                    leas      $02,s
                    lbra      L56B8

L5643               cmpx      #$0093
                    beq       L562C
                    cmpx      #$0094
                    beq       L5631
                    cmpx      #$0095
                    beq       L5636
                    bra       L56B8

L5654               ldd       $00B0,y
                    pshs      d
                    lbsr      L5794
                    leas      $02,s
                    leax      $5B69,pcr
                    pshs      x
                    lbsr      L5794
                    leas      $02,s
                    ldd       $000F
                    addd      #$0002
                    std       $000F
                    bra       L56B8

L5673               leax      L5B6C,pcr
L5677               pshs      x
                    lbsr      L0450
L567C               leas      $02,s
                    bra       L56B8

L5680               cmpx      #$0077
                    lbeq      L5492
                    cmpx      #$0036
                    lbeq      L54C9
                    cmpx      #$0080
                    lbeq      L54D8
                    cmpx      #$0034
                    lbeq      L54F8
                    cmpx      #$0093
                    lbeq      L560D
                    cmpx      #$0094
                    lbeq      L560D
                    cmpx      #$0095
                    lbeq      L560D
                    cmpx      #$006E
                    beq       L5654
                    bra       L5673

L56B8               ldd       $08,s
                    anda      #$80
                    clrb
                    std       -$02,s
                    lbeq      L57A1
                    ldd       #$005D
                    pshs      d
                    lbsr      L5785
                    leas      $02,s
                    lbra      L57A1

L56D0               pshs      u
                    ldx       $04,s
                    bra       L571F

L56D6               leax      $5B78,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
L56E1               leax      $5B7F,pcr
                    bra       L571B

L56E7               leax      L5B83,pcr
                    bra       L571B

L56ED               leax      L5B87,pcr
                    bra       L571B

L56F3               leax      L5B8B,pcr
                    bra       L571B

L56F9               leax      L5B8F,pcr
                    bra       L571B

L56FF               leax      L5B93,pcr
                    bra       L571B

L5705               leax      L5B97,pcr
                    bra       L571B

L570B               leax      L5B9B,pcr
                    bra       L571B

L5711               leax      L5B9F,pcr
                    bra       L571B

L5717               leax      L5BA3,pcr
L571B               tfr       x,d
                    puls      pc,u
L571F               cmpx      #$005A
                    beq       L56E1
                    cmpx      #$005B
                    beq       L56E7
                    cmpx      #$005C
                    beq       L56ED
                    cmpx      #$005D
                    beq       L56F3
                    cmpx      #$005E
                    beq       L56F9
                    cmpx      #$005F
                    beq       L56FF
                    cmpx      #$0060
                    beq       L5705
                    cmpx      #$0061
                    beq       L570B
                    cmpx      #$0062
                    beq       L5711
                    cmpx      #$0063
                    beq       L5717
                    lbra      L56D6
                    puls      pc,u
L5756               pshs      u
                    ldd       $0005
                    pshs      d
                    ldd       #$0020
                    pshs      d
                    lbsr      $A1CD
                    leas      $04,s
                    ldd       $04,s
                    pshs      d
                    bsr       L5794
                    lbra      L5811

L576F               pshs      u
                    ldd       $04,s
                    pshs      d
                    bsr       L5756
                    lbra      L582B

L577A               pshs      u
                    ldd       $0005
                    pshs      d
                    ldd       #$000D
                    bra       L578D

L5785               pshs      u
                    ldd       $0005
                    pshs      d
                    ldd       $06,s
L578D               pshs      d
                    lbsr      $A1CD
                    bra       L57A1

L5794               pshs      u
                    ldd       $04,s
                    pshs      d
                    ldd       $0005
                    pshs      d
                    lbsr      L9A34
L57A1               leas      $04,s
                    puls      pc,u
L57A5               pshs      u
                    ldd       $04,s
                    pshs      d
                    leax      L5BA7,pcr
                    lbra      L583C

L57B2               pshs      u
                    ldd       $04,s
                    pshs      d
                    bsr       L57C3
                    leas      $02,s
                    clra
                    clrb
                    std       $002F
                    lbra      L582D

L57C3               pshs      u
                    ldd       #$005F
                    pshs      d
                    bsr       L5785
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    bsr       L57A5
                    bra       L5811

L57D6               pshs      u
                    ldd       $04,s
                    pshs      d
                    leax      $5BAA,pcr
                    lbra      L583C

L57E3               pshs      u,d
                    ldd       $06,s
                    subd      $000F
                    std       ,s
                    beq       L580F
                    leax      $5BAF,pcr
                    pshs      x
                    lbsr      L5756
                    leas      $02,s
                    ldd       ,s
                    pshs      d
                    lbsr      L57A5
                    leas      $02,s
                    ldd       $00B0,y
                    pshs      d
                    lbsr      L5794
                    leas      $02,s
                    lbsr      L577A
L580F               ldd       $06,s
L5811               leas      $02,s
                    puls      pc,u
L5815               pshs      u
                    ldd       $04,s
                    pshs      d
                    bsr       L57D6
                    leas      $02,s
                    ldd       $06,s
                    beq       L582D
                    ldd       #$003A
                    pshs      d
                    lbsr      L5785
L582B               leas      $02,s
L582D               lbsr      L577A
                    puls      pc,u
L5832               pshs      u
                    ldd       $04,s
                    pshs      d
                    leax      L5BB5,pcr
L583C               pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      L9A34
                    leas      $06,s
                    puls      pc,u
L5849               pshs      u
                    ldd       $04,s
                    pshs      d
                    bsr       L5832
                    leas      $02,s
                    ldd       $06,s
                    pshs      d
                    ldd       #$005F
                    pshs      d
                    leax      L5BBD,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      L9A34
                    leas      $08,s
                    puls      pc,u
                    bge       $58E8
                    neg       L002C
                    com       >L006C
                    fcb       $62
                    com       L7220
                    neg       L006C
                    fcb       $62
                    fcb       $72
                    fcb       $61
                    bra       L587F

L587F               com       $0C,s
                    fcb       $72
                    fcb       $61
                    neg       L0075
                    jmp       $0b,s
                    jmp       $0f,s
                    asr       L6E20
                    clr       -$10,s
                    fcb       $65
                    fcb       $72
                    fcb       $61
                    lsr       $6F72
                    bra       L58D0
                    bra       L5898

L5898               bra       L590A
                    com       L6873
                    bra       $58C4
                    com       $0d,x
                    neg       L006C
                    fcb       $62
                    neg       L0070
                    fcb       $75
                    inc       -$0d,s
                    bra       $5920
                    bge       $591D
                    com       $0d,x
                    neg       L0063
                    com       $0d,s
                    fcb       $75
                    inc       -$0C,s
                    neg       L0063
                    com       -$0b,s
                    lsr       $09,s
                    ror       >L0063
                    com       $04,s
                    rol       -$0a,s
                    neg       L0063
                    com       $01,s
                    com       $6C00
L58CA               com       $03,s
                    fcb       $61
                    com       L7200
L58D0               com       $03,s
                    inc       -$0d,s
                    fcb       $72
                    neg       L0063
                    com       -$0b,s
                    tst       $0f,s
                    lsr       0,x
L58DD               com       $03,s
                    tst       $0f,s
                    lsr       0,x
L58E3               jmp       $05,s
                    asr       $01,s
                    tst       $0020
                    jmp       $05,s
                    asr       $02,s
                    tst       $0020
                    com       $6263
                    fcb       $61
                    bra       $5918
                    leax      0,x
L58F7               com       $0f,s
                    tst       $01,s
                    tst       $0020
                    com       $0f,s
                    tst       $02,s
                    neg       L006C
                    fcb       $65
                    fcb       $61
                    asl       L2000
L5908               inc       $05,s
L590A               fcb       $61
                    com       L2000
L590E               bge       $5988
                    tst       $0000
L5912               dec       -$0d,s
                    fcb       $72
                    bra       L5917

L5917               com       $6578
                    neg       L006C
                    lsr       0,x
L591E               fcb       $61
                    com       L6C62
                    tst       $0020
                    fcb       $72
                    clr       $0C,s
                    fcb       $61
                    neg       L0061
                    com       L7261
                    tst       $0020
                    fcb       $72
                    clr       -$0e,s
                    fcb       $62
                    neg       L006C
                    com       L7261
                    tst       $0020
                    fcb       $72
                    clr       -$0e,s
                    fcb       $62
                    neg       L006C
                    lsr       -$07,s
                    bra       L5944

L5944               inc       $04,s
                    fcb       $75
                    bra       L5949

L5949               inc       $05,s
                    fcb       $61
                    asl       L2000
L594F               bcs       L59B5
                    bge       L5978
                    com       $0d,x
                    neg       $0064
                    bge       $597E
                    com       $0d,x
                    neg       $0073
                    fcb       $65
                    asl       >L0061
                    lsr       $03,s
                    fcb       $61
                    bra       $5989
                    leax      0,x
L5968               com       $6263
                    fcb       $61
                    bra       L5991
                    leax      0,x
L5970               bcs       $59D6
                    bge       L5999
                    com       $0d,x
                    neg       L0063
L5978               inc       -$0e,s
                    fcb       $61
                    tst       $0020
                    com       $0C,s
                    fcb       $72
                    fcb       $62
                    neg       L006C
                    lsr       0,x
L5985               bra       L59FA
                    lsr       L2563
                    bra       L59B9
                    leas      $0C,y
                    com       $0D00
L5991               com       $0d,s
                    neg       >$0073
                    lsr       >$0073
L5999               fcb       $75
                    fcb       $62
                    neg       L0061
                    lsr       $04,s
                    neg       L006C
                    fcb       $65
                    fcb       $61
                    neg       $0020
                    fcb       $65
                    asl       $6720
                    bcs       L5A0E
                    bge       L59D2
                    com       $0d,x
                    neg       $0064
                    bge       L59B3
L59B3               inca
                    fcb       $45
L59B5               fcb       $41
                    bra       L5A19
                    fcb       $72
L59B9               asr       0,x
L59BB               bra       L5A31
                    ror       -$0e,s
                    bra       $59E6
                    com       $0C,y
                    bcs       $5A28
                    tst       $0000
L59C7               inc       $04,s
                    fcb       $61
                    bra       L59FC
                    bge       $5A46
                    tst       $0020
                    clr       -$0e,s
L59D2               fcb       $61
                    bra       L5A06
                    bge       $5A4F
                    tst       $0020
                    clr       -$0e,s
                    fcb       $61
                    bra       L5A10
                    bge       L5A58
                    tst       $0020
                    clr       -$0e,s
                    fcb       $61
                    bra       $5A1A
                    bge       $5A61
                    neg       L005F
                    inc       $0d,s
                    clr       -$0a,s
                    fcb       $65
                    neg       L005F
                    inc       $01,s
                    lsr       $04,s
                    neg       L005F
                    inc       -$0d,s
L59FA               fcb       $75
                    fcb       $62
L59FC               neg       L005F
                    inc       $0d,s
                    fcb       $75
                    inc       0,x
L5A03               clrb
                    inc       $04,s
L5A06               rol       -$0a,s
                    neg       L005F
                    inc       $0d,s
                    clr       $04,s
L5A0E               neg       L005F
L5A10               inc       $01,s
                    jmp       $04,s
                    neg       L005F
                    inc       $0f,s
                    fcb       $72
L5A19               neg       L005F
                    inc       -$08,s
                    clr       -$0e,s
                    neg       L005F
                    inc       -$0d,s
                    asl       $0C,s
                    neg       L005F
                    inc       -$0d,s
                    asl       -$0e,s
                    neg       L005F
                    inc       $03,s
                    tst       -$10,s
L5A31               fcb       $72
                    neg       L005F
                    inc       $0e,s
                    fcb       $65
                    asr       0,x
L5A39               clrb
                    inc       $03,s
                    clr       $0d,s
                    neg       $6C00
L5A41               clrb
                    inc       $09,s
                    lsr       $6F6C
                    neg       L005F
                    inc       -$0b,s
                    lsr       $6F6C
                    neg       L005F
                    inc       $09,s
                    jmp       $03,s
                    neg       L005F
                    inc       $04,s
L5A58               fcb       $65
                    com       0,x
L5A5B               com       $0f,s
                    lsr       $07,s
                    fcb       $65
                    jmp       0,y
                    blt       $5A84
                    inc       $0f,s
                    jmp       $07,s
                    com       >L005F
                    lsr       -$0d,s
                    lsr       L6163
                    fcb       $6b
                    neg       $0020
                    inc       $04,s
                    fcb       $61
                    bra       L5A9D
                    com       $0C,y
                    asl       $0D00
L5A7D               clrb
                    ror       $0d,s
                    clr       -$0a,s
                    fcb       $65
                    neg       L005F
                    lsr       $0d,s
                    clr       -$0a,s
                    fcb       $65
                    neg       L005F
                    lsr       $01,s
                    lsr       $04,s
                    neg       L005F
                    lsr       -$0d,s
                    fcb       $75
                    fcb       $62
                    neg       L005F
                    lsr       $0d,s
                    fcb       $75
                    inc       0,x
L5A9D               clrb
                    lsr       $04,s
                    rol       -$0a,s
                    neg       L005F
                    lsr       $03,s
                    tst       -$10,s
                    fcb       $72
                    neg       L005F
                    lsr       $0e,s
                    fcb       $65
                    asr       0,x
L5AB0               clrb
                    ror       $09,s
                    jmp       $03,s
                    neg       L005F
                    lsr       $09,s
                    jmp       $03,s
                    neg       L005F
                    ror       $04,s
                    fcb       $65
                    com       0,x
L5AC2               clrb
                    lsr       $04,s
                    fcb       $65
                    com       0,x
L5AC8               clrb
                    lsr       -$0C,s
                    clr       $06,s
                    neg       L005F
                    ror       -$0C,s
                    clr       $04,s
                    neg       L005F
                    inc       -$0C,s
                    clr       $04,s
                    neg       L005F
                    rol       -$0C,s
                    clr       $04,s
                    neg       L005F
                    fcb       $75
                    lsr       $6F64
                    neg       L005F
                    lsr       -$0C,s
                    clr       $0C,s
                    neg       L005F
                    lsr       -$0C,s
                    clr       $09,s
                    neg       L0063
                    clr       $04,s
                    asr       $05,s
                    jmp       0,y
                    blt       L5B1B
                    ror       $0C,s
                    clr       $01,s
                    lsr       $7300
L5B02               fcb       $62
                    com       L7220
                    neg       L0070
                    fcb       $75
                    inc       -$0d,s
                    bra       L5B85
                    neg       L0030
                    bge       L5B11
L5B11               fcb       $61
                    jmp       $04,s
                    neg       $006F
                    fcb       $72
                    neg       L0065
                    clr       -$0e,s
L5B1B               neg       L0063
                    clr       $0d,s
                    fcb       $61
                    neg       L0063
                    inc       -$0e,s
                    fcb       $62
                    neg       L0063
                    clr       $0d,s
                    fcb       $62
                    neg       $0020
                    bcs       L5BA1
                    fcb       $61
                    bra       $5B5D
                    com       L2B0D
                    bra       $5B5B
                    com       $6220
                    bge       $5BAE
                    bmi       $5B4A
                    neg       L0063
                    clr       $0d,s
                    neg       L696C
                    fcb       $65
                    fcb       $72
                    bra       $5BBC
                    fcb       $72
                    clr       -$0b,s
                    fcb       $62
                    inc       $05,s
                    neg       L005F
                    ror       $0C,s
                    fcb       $61
                    com       $03,s
                    neg       L002C
                    neg       L6372
                    neg       $0073
                    lsr       $6F72
                    fcb       $61
                    asr       $05,s
                    bra       L5BC9
                    fcb       $72
                    fcb       $72
                    clr       -$0e,s
                    neg       $002B
                    bmi       L5B6C
L5B6C               lsr       $05,s
                    fcb       $72
                    fcb       $65
                    ror       $05,s
                    fcb       $72
                    fcb       $65
                    jmp       $03,s
                    fcb       $65
                    neg       $0072
                    fcb       $65
                    inc       0,y
                    clr       -$10,s
                    neg       L0065
                    fcb       $71
                    bra       L5B83

L5B83               jmp       $05,s

L5B85               bra       L5B87

L5B87               inc       $05,s
                    bra       L5B8B

L5B8B               inc       -$0C,s
                    bra       L5B8F

L5B8F               asr       $05,s
                    bra       L5B93

L5B93               asr       -$0C,s
                    bra       L5B97

L5B97               inc       -$0d,s
                    bra       L5B9B

L5B9B               inc       $0f,s
                    bra       L5B9F

L5B9F               asl       -$0d,s
L5BA1               bra       L5BA3

L5BA3               asl       $09,s
                    bra       L5BA7

L5BA7               bcs       $5C0D
                    neg       L0025
                    bgt       L5BE5
                    com       >L006C
                    fcb       $65
                    fcb       $61
                    com       L2000
L5BB5               bra       L5C23
                    fcb       $65
                    fcb       $61
                    bcs       L5C1E
                    bra       L5BBD

L5BBD               bcs       $5C22
                    bcs       L5C25
                    bge       $5C33
                    com       -$0e,s
                    tst       $0000
L5BC7               pshs      u
L5BC9               lbsr      L5D72
                    lbsr      L5D64
                    ldd       $0009
                    lbeq      L5DFF
                    leax      L5E01,pcr
                    lbra      L5D6A

L5BDC               pshs      u
                    ldd       $08,s
                    pshs      d
                    lbsr      L5D4E
L5BE5               leas      $02,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L57C3
                    leas      $02,s
                    ldd       $06,s
                    pshs      d
                    leax      $5E14,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      L9A34
                    bra       L5C2D

L5C03               pshs      u
                    ldd       $08,s
                    pshs      d
                    lbsr      L5D4E
                    leas      $02,s
                    ldd       #$003A
                    bra       L5C21

L5C13               pshs      u
                    ldd       $08,s
                    pshs      d
                    lbsr      L5D4E
                    leas      $02,s
L5C1E               ldd       #$0020
L5C21               pshs      d
L5C23               ldd       $08,s
L5C25               pshs      d
                    ldd       $08,s
                    pshs      d
                    bsr       L5C34
L5C2D               leas      $06,s
                    lbsr      L5D64
                    puls      pc,u
L5C34               pshs      u
                    ldd       $06,s
                    pshs      d
                    ldb       $0b,s
                    sex
                    pshs      d
                    ldd       $08,s
                    addd      #$0014
                    pshs      d
                    leax      $5E1D,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      L9A34
                    leas      $0a,s
                    puls      pc,u
L5C57               pshs      u
                    ldd       $06,s
                    std       $005E
                    pshs      d
                    lbsr      L57C3
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    leax      $5E2C,pcr
                    lbra      L5CF9

L5C6F               pshs      u
                    ldu       $04,s
                    pshs      u
                    leax      L5E40,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      L9A34
                    leas      $06,s
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    lbsr      L5815
                    leas      $04,s
                    leax      L5E4B,pcr
                    pshs      x
                    lbsr      L576F
                    leas      $02,s
                    ldd       $0015
                    bne       L5CB8
                    ldd       $000B
                    addd      #$0001
                    std       $000B
                    std       L005C
                    pshs      d
                    leax      $5E52,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      L9A34
                    leas      $06,s
L5CB8               ldd       $0017
                    lbeq      L5DFF
                    leax      L5E6D,pcr
                    pshs      x
                    lbsr      L5756
                    leas      $02,s
                    ldd       $08,s
                    pshs      d
                    lbsr      L57C3
                    leas      $02,s
                    leax      L5E73,pcr
                    pshs      x
                    lbsr      L5794
                    leas      $02,s
                    pshs      u
                    lbsr      L57D6
                    leas      $02,s
                    leax      L5E87,pcr
                    lbra      L5D46

L5CEB               pshs      u
                    ldd       $0017
                    beq       L5D04
                    ldd       $005E
                    pshs      d
                    leax      L5EAB,pcr
L5CF9               pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      L9A34
                    leas      $06,s
L5D04               puls      pc,u
L5D06               pshs      u
                    ldd       $0015
                    bne       L5D28
                    ldd       $001B
                    subd      $0013
                    addd      #$FFC0
                    pshs      d
                    ldd       L005C
                    pshs      d
                    leax      L5EE9,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      L9A34
                    leas      $08,s
L5D28               puls      pc,u
L5D2A               pshs      u
                    leax      L5EF6,pcr
                    bra       L5D38

L5D32               pshs      u
                    leax      L5EFB,pcr
L5D38               pshs      x
                    lbsr      L5756
                    lbra      L5DFD

L5D40               pshs      u
                    leax      L5F00,pcr
L5D46               pshs      x
                    lbsr      L5794
                    lbra      L5DFD

L5D4E               pshs      u
                    ldd       $04,s
                    beq       L5D5A
                    leax      $5F03,pcr
                    bra       L5D5E

L5D5A               leax      $5F0C,pcr
L5D5E               tfr       x,d
                    pshs      d
                    bra       L5D6C

L5D64               pshs      u
                    leax      $5F12,pcr
L5D6A               pshs      x
L5D6C               lbsr      L576F
                    lbra      L5DFD

L5D72               pshs      u
                    ldd       L004C
                    lbeq      L5DFF
                    ldd       L004C
                    pshs      d
                    lbsr      $A14D
                    leas      $02,s
                    bra       L5D90

L5D85               ldd       $0005
                    pshs      d
                    pshs      u
                    lbsr      $A1CD
                    leas      $04,s
L5D90               ldd       L004C
                    pshs      d
                    lbsr      $A3E4
                    leas      $02,s
                    tfr       d,u
                    cmpu      #$FFFF
                    bne       L5D85
                    ldx       L004C
                    ldd       $06,x
                    clra
                    andb      #$20
                    beq       L5DB5
                    leax      $5F1A,pcr
                    pshs      x
                    lbsr      L042D
                    leas      $02,s
L5DB5               ldd       L004C
                    pshs      d
                    lbsr      $A2BE
                    leas      $02,s
                    leax      $0096,y
                    pshs      x
                    lbsr      $B17D
                    bra       L5DFD

L5DC9               pshs      u,d
                    ldd       $0364,y
                    beq       L5DD7
                    ldd       $0364,y
                    bra       L5DDA

L5DD7               ldd       #$0001
L5DDA               std       ,s
                    ldd       L004C
                    beq       L5DF4
                    ldd       L004C
                    pshs      d
                    lbsr      $A2BE
                    leas      $02,s
                    leax      $0096,y
                    pshs      x
                    lbsr      $B17D
                    leas      $02,s
L5DF4               ldd       ,s
                    pshs      d
                    lbsr      $B352
                    leas      $02,s
L5DFD               leas      $02,s
L5DFF               puls      pc,u
L5E01               ror       $01,s
                    rol       $0C,s
                    bra       $5E7A
                    clr       -$0b,s
                    fcb       $72
                    com       $05,s
                    bra       L5E73
                    fcb       $72
                    fcb       $72
                    clr       -$0e,s
                    com       >$0020
                    fcb       $72
                    tst       $02,s
                    bra       $5E3F
                    lsr       $0d,x
                    neg       L0025
                    bgt       $5E58
                    com       L2563
                    bra       L5E97
                    tst       $02,s
                    bra       L5E4E
                    lsr       $0d,x
                    neg       $0020
                    ror       $03,s
                    com       0,y
                    bhi       $5E58
                    bgt       L5E6D
                    com       $220D
                    bra       L5EA0
                    com       $02,s
                    bra       $5E6E
                    tst       $0000
L5E40               bra       L5EB6
                    lsr       $6C20
                    bcs       L5E75
                    fcb       $38
                    com       $0D00
L5E4B               neg       L7368
L5E4E               com       $2075
                    neg       $0020
                    inc       $04,s
                    lsr       0,y
                    bls       $5EB8
                    bcs       $5EBF
                    tst       $0020
                    inc       $02,s
                    com       L7220
                    clrb
                    com       L746B
                    com       $08,s
                    fcb       $65
                    com       $0b,s
                    tst       $0000
L5E6D               inc       $05,s
                    fcb       $61
                    asl       L2000
L5E73               bge       $5EE5
L5E75               com       -$0e,s
                    tst       $0020
                    neg       L7368
                    com       L2078
                    tst       $0020
                    inc       $05,s
                    fcb       $61
                    asl       L2000
L5E87               bge       L5EF9
                    com       -$0e,s
                    tst       $0020
                    neg       L7368
                    com       L2078
                    tst       $0020
                    inc       $02,s
L5E97               com       L7220
                    clrb
                    neg       L726F
                    ror       $0d,x
L5EA0               bra       $5F0E
                    fcb       $65
                    fcb       $61
                    com       $2034
                    bge       L5F1C
                    tst       $0000
L5EAB               bra       $5F1D
                    com       L6873
                    bra       $5F16
                    tst       $0020
                    inc       $05,s
L5EB6               fcb       $61
                    asl       L205F
                    bcs       $5F20
                    bge       L5F2E
                    com       -$0e,s
                    tst       $0020
                    neg       L7368
                    com       L2078
                    tst       $0020
                    inc       $02,s
                    com       L7220
                    clrb
                    fcb       $65
                    neg       L726F
                    ror       $0d,x
                    bra       $5F44
                    fcb       $65
                    fcb       $61
                    com       $2032
                    bge       L5F52
                    tst       $0020
                    neg       L756C
                    com       $2064
                    tst       $0000
L5EE9               clrb
                    bcs       $5F50
                    bra       $5F53
                    fcb       $71
                    fcb       $75
                    bra       $5F17
                    lsr       $0d,x
                    tst       $0000
L5EF6               ror       $03,s
                    fcb       $62
L5EF9               bra       L5EFB

L5EFB               ror       $04,s
                    fcb       $62
                    bra       L5F00

L5F00               bpl       $5F22
                    neg       $0076
                    com       L6563
                    lsr       $2064
                    neg       >$0076
                    com       L6563
                    lsr       >L0065
                    jmp       $04,s
                    com       L6563
                    lsr       >$0064
                    fcb       $75
L5F1C               tst       -$10,s
                    com       L7472
                    rol       $0e,s
                    asr       -$0d,s
                    neg       $0034
                    nega
                    leas      -$15,s
                    lbsr      L42B9
L5F2E               ldb       $0045
                    sex
                    cmpd      #$FFFF
                    bne       L5F41
                    ldd       #$FFFF
                    std       $003F
                    leas      $15,s
                    puls      pc,u
L5F41               ldd       $004A
                    addd      #$FFFF
                    std       $0043
                    ldd       $0007
                    std       L001F
                    bra       L5F60

L5F4E               leax      L6CDE,pcr
L5F52               pshs      x
                    lbsr      L0450
                    leas      $02,s
                    lbsr      L42CF
                    ldd       $004A
                    std       $0043
L5F60               ldb       $0045
                    sex
                    leax      $00BA,y
                    leax      d,x
                    ldb       ,x
                    sex
                    std       $003F
                    beq       L5F4E
                    ldb       $0045
                    sex
                    leax      $013a,y
                    leax      d,x
                    ldb       ,x
                    sex
                    std       $0041
                    ldx       $003F
                    lbra      L626E

L5F83               leax      $0a,s
                    pshs      x
                    lbsr      L64B7
                    leas      $02,s
                    leax      $0a,s
                    pshs      x
                    lbsr      L652E
                    leas      $02,s
                    tfr       d,u
                    ldd       ,u
                    std       $003F
                    cmpd      #$0033
                    bne       L5FBA
                    ldd       $08,u
                    std       $0041
                    cmpd      #$003B
                    lbne      L628D
                    ldd       #$003B
                    std       $003F
                    ldd       #$000E
                    std       $0041
                    lbra      L628D

L5FBA               ldd       #$0034
                    std       $003F
                    stu       $0041
                    lbra      L628D

L5FC4               leax      ,s
                    pshs      x
                    ldd       #$0001
                    pshs      d
                    lbsr      L6654
                    leas      $04,s
                    std       $13,s
                    bra       L5FDA

L5FD7               leas      -$15,x
L5FDA               leax      ,s
                    stx       $08,s
                    ldx       $13,s
                    bra       L6038

L5FE3               ldd       [$08,s]
                    bra       L602E

L5FE8               ldd       #$0004
                    pshs      d
                    lbsr      L6622
                    leas      $02,s
                    tfr       d,u
                    leax      ,u
                    pshs      x
                    ldx       $0a,s
                    lbsr      LAEDF
                    stu       $0041
                    ldd       #$004A
                    bra       L6033

L6004               ldd       #$0008
                    pshs      d
                    lbsr      L6622
                    leas      $02,s
                    tfr       d,u
                    leax      ,u
                    pshs      x
                    ldx       $0a,s
                    lbsr      $AE34
                    stu       $0041
                    ldd       #$004B
                    bra       L6033

L6020               leax      $6CEC,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
                    ldd       #$0001
L602E               std       $0041
                    ldd       #$0036
L6033               std       $003F
                    lbra      L628D

L6038               cmpx      #$0001
                    beq       L5FE3
                    cmpx      #$0008
                    beq       L5FE8
                    cmpx      #$0006
                    beq       L6004
                    bra       L6020

L6049               lbsr      L69C3
                    ldd       #$0036
                    bra       L6057

L6051               lbsr      L69F3
                    ldd       #$0037
L6057               std       $003F
                    lbra      L628D

L605C               lbsr      L42CF
                    ldx       $003F
                    lbra      L6211

L6064               ldb       $0045
                    sex
                    leax      $00BA,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$6b
                    lbne      L628D
                    leax      ,s
                    pshs      x
                    ldd       #$0006
                    pshs      d
                    lbsr      L6654
                    leas      $04,s
                    std       $13,s
                    leax      $15,s
                    lbra      L5FD7

L608C               ldb       $0045
                    sex
                    tfr       d,x
                    bra       L60AB

L6093               ldd       #$0047
                    std       $003F
                    lbsr      L42CF
                    ldd       #$0005
                    bra       L60EA

L60A0               ldd       #$00A7
                    std       $003F
                    ldd       #$0002
                    lbra      L61F7

L60AB               cmpx      #$0026
                    beq       L6093
                    cmpx      #$003D
                    beq       L60A0
                    lbra      L628D

L60B8               ldb       $0045
                    cmpb      #$3d
                    lbne      L628D
                    ldd       #$005A
                    std       $003F
                    ldd       #$0009
                    lbra      L61F7

L60CB               ldb       $0045
                    sex
                    tfr       d,x
                    bra       L60EF

L60D2               ldd       #$0048
                    std       $003F
                    lbsr      L42CF
                    ldd       #$0004
                    bra       L60EA

L60DF               ldd       #$00A8
L60E2               std       $003F
                    lbsr      L42CF
                    ldd       #$0002
L60EA               std       $0041
                    lbra      L628D

L60EF               cmpx      #$007C
                    beq       L60D2
                    cmpx      #$003D
                    beq       L60DF
                    lbra      L628D

L60FC               ldb       $0045
                    cmpb      #$3d
                    lbne      L628D
                    ldd       #$005B
                    std       $003F
                    lbsr      L42CF
                    ldd       #$0009
                    bra       L60EA

L6111               ldb       $0045
                    cmpb      #$3d
                    lbne      L628D
                    ldd       #$00A2
                    bra       L60E2

L611E               ldb       $0045
                    cmpb      #$3d
                    lbne      L628D
                    ldd       $003F
                    addd      #$0050
                    lbra      L60E2

L612E               ldb       $0045
                    sex
                    tfr       d,x
                    bra       L6160

L6135               ldd       #$0056
                    std       $003F
                    ldd       #$000B
                    std       $0041
                    lbsr      L42CF
                    ldb       $0045
                    cmpb      #$3d
                    lbne      L628D
                    ldd       #$00A6
                    std       $003F
                    ldd       #$0002
                    lbra      L61F7

L6155               ldd       #$005C
                    std       $003F
                    ldd       #$000A
                    lbra      L61F7

L6160               cmpx      #$003C
L6163               beq       L6135
                    cmpx      #$003D
                    beq       L6155
                    lbra      L628D

L616D               ldb       $0045
                    sex
                    tfr       d,x
L6172               bra       L619F

L6174               ldd       #$0055
                    std       $003F
                    ldd       #$000B
                    std       $0041
                    lbsr      L42CF
                    ldb       $0045
                    cmpb      #$3d
                    lbne      L628D
                    ldd       #$00A5
                    std       $003F
                    ldd       #$0002
                    lbra      L61F7

L6194               ldd       #$005E
                    std       $003F
                    ldd       #$000A
                    lbra      L61F7

L619F               cmpx      #$003E
                    beq       L6174
                    cmpx      #$003D
                    beq       L6194
                    lbra      L628D

L61AC               ldb       $0045
                    sex
                    tfr       d,x
                    bra       L61C7

L61B3               ldd       #$003C
                    std       $003F
                    ldd       #$000E
                    bra       L61F7

L61BD               ldd       #$00A0
                    std       $003F
                    ldd       #$0002
                    bra       L61F7

L61C7               cmpx      #$002B
                    beq       L61B3
                    cmpx      #$003D
                    beq       L61BD
                    lbra      L628D

L61D4               ldb       $0045
                    sex
                    tfr       d,x
                    bra       L61FF

L61DB               ldd       #$003D
                    std       $003F
                    ldd       #$000E
                    bra       L61F7

L61E5               ldd       #$00A1
                    std       $003F
                    ldd       #$0002
                    bra       L61F7

L61EF               ldd       #$0046
                    std       $003F
                    ldd       #$000F
L61F7               std       $0041
                    lbsr      L42CF
                    lbra      L628D

L61FF               cmpx      #$002D
                    beq       L61DB
                    cmpx      #$003D
                    beq       L61E5
                    cmpx      #$003E
                    beq       L61EF
                    lbra      L628D

L6211               cmpx      #$0045
                    lbeq      L6064
                    cmpx      #$0041
                    lbeq      L608C
                    cmpx      #$0078
                    lbeq      L60B8
                    cmpx      #$0058
                    lbeq      L60CB
                    cmpx      #$0040
                    lbeq      L60FC
                    cmpx      #$0042
                    lbeq      L6111
                    cmpx      #$0053
                    lbeq      L611E
                    cmpx      #$0054
                    lbeq      L611E
                    cmpx      #$0059
                    lbeq      L611E
                    cmpx      #$005D
                    lbeq      L612E
                    cmpx      #$005F
                    lbeq      L616D
                    cmpx      #$0050
                    lbeq      L61AC
                    cmpx      #$0043
                    lbeq      L61D4
                    bra       L628D

L626E               cmpx      #$006A
                    lbeq      L5F83
                    cmpx      #$006B
                    lbeq      L5FC4
                    cmpx      #$0068
                    lbeq      L6049
                    cmpx      #$0069
                    lbeq      L6051
                    lbra      L605C

L628D               leas      $15,s
                    puls      pc,u
L6292               pshs      u
                    ldd       #$0006
                    pshs      d
                    leax      $6CFE,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$0005
                    pshs      d
                    leax      $6D05,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$001E
                    pshs      d
                    leax      $6D0B,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$000F
                    pshs      d
                    leax      L6D13,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$003B
                    pshs      d
                    leax      $6D1A,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$0001
                    pshs      d
                    leax      $6D21,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$0001
                    std       L0021
                    ldd       #$0001
                    pshs      d
                    leax      $6D25,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$0005
                    pshs      d
                    leax      $6D29,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    clra
                    clrb
                    std       L0021
                    ldd       #$0002
                    pshs      d
                    leax      $6D2F,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$000A
                    pshs      d
                    leax      $6D34,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$000D
                    pshs      d
                    leax      $6D3A,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$000E
                    pshs      d
                    leax      L6D3F,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$0021
                    pshs      d
                    leax      L6D46,pcr
                    pshs      x
L6368               lbsr      L65D0
                    leas      $04,s
                    ldd       #$0010
                    pshs      d
L6372               leax      $6D4D,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #start
                    pshs      d
                    leax      $6D56,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$0012
                    pshs      d
                    leax      L6D5B,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$0013
                    pshs      d
                    leax      L6D62,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$0014
                    pshs      d
                    leax      $6D65,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$0015
                    pshs      d
                    leax      $6D6B,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$0016
                    pshs      d
                    leax      $6D70,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$0017
                    pshs      d
                    leax      $6D77,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$0018
                    pshs      d
                    leax      L6D7C,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$0019
                    pshs      d
                    leax      $6D82,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$001A
                    pshs      d
                    leax      $6D8B,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$001B
                    pshs      d
                    leax      L6D8E,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$001C
                    pshs      d
                    leax      $6D96,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$0004
                    pshs      d
                    leax      $6D9A,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$0003
                    pshs      d
                    leax      $6DA1,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$0007
                    pshs      d
                    leax      $6DA7,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$0008
                    pshs      d
                    leax      L6DB0,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    leax      $6DB5,pcr
                    pshs      x
                    lbsr      L652E
                    leas      $02,s
                    tfr       d,u
                    ldd       #$0001
                    std       ,u
                    ldd       #$000E
                    std       $08,u
                    ldd       #$0002
                    std       $02,u
                    leax      $6DBB,pcr
                    pshs      x
                    lbsr      L652E
                    leas      $02,s
                    tfr       d,u
                    ldd       #$0038
                    std       ,u
                    ldd       #$000C
                    std       $08,u
                    ldd       #$0004
                    std       $02,u
                    puls      pc,u
L64B7               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    ldd       #$0001
                    bra       L64CE

L64C2               ldb       $0045
                    stb       ,u+
                    lbsr      L42CF
                    ldd       ,s
                    addd      #$0001
L64CE               std       ,s
                    ldb       $0045
                    sex
                    pshs      d
                    bsr       L6507
                    std       ,s++
                    beq       L64E3
                    ldd       ,s
                    cmpd      #$0008
                    ble       L64C2
L64E3               ldd       ,s
                    cmpd      #$0002
                    bne       L64F0
                    ldd       #$005F
                    stb       ,u+
L64F0               clra
                    clrb
                    stb       ,u
                    bra       L64F9

L64F6               lbsr      L42CF
L64F9               ldb       $0045
                    sex
                    pshs      d
                    bsr       L6507
L6500               std       ,s++
                    bne       L64F6
                    lbra      L6650

L6507               pshs      u
                    ldd       $04,s
                    leax      $00BA,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$6a
                    beq       L6525
                    ldd       $04,s
                    leax      $00BA,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$6b
                    bne       L652A
L6525               ldd       #$0001
                    bra       L652C

L652A               clra
                    clrb
L652C               puls      pc,u
L652E               pshs      u,y,x,d
                    ldd       L0021
                    beq       L653A
                    leax      $0484,y
                    bra       L653E

L653A               leax      $0384,y
L653E               tfr       x,d
                    std       $02,s
                    ldd       $0a,s
                    pshs      d
                    lbsr      L6602
                    leas      $02,s
                    aslb
                    rola
                    addd      $02,s
                    std       $04,s
                    ldu       [$04,s]
                    bra       L6583

L6556               ldb       $14,u
                    sex
                    pshs      d
                    ldb       [$0C,s]
                    sex
                    cmpd      ,s++
L6563               bne       L6580
L6565               ldd       #$0008
                    pshs      d
                    pshs      u
                    ldd       #$0014
                    addd      ,s++
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    lbsr      $A68C
                    leas      $06,s
                    std       -$02,s
                    beq       L65CA
L6580               ldu       $12,u
L6583               stu       -$02,s
                    bne       L6556
                    ldu       $0062
                    beq       L6592
                    ldd       $12,u
                    std       $0062
                    bra       L659E

L6592               ldd       #$001C
                    pshs      d
                    lbsr      L6622
                    leas      $02,s
                    tfr       d,u
L659E               ldd       #$0008
                    pshs      d
                    ldd       $0C,s
                    pshs      d
                    pshs      u
                    ldd       #$0014
                    addd      ,s++
                    pshs      d
                    lbsr      $A64F
                    leas      $06,s
                    clra
                    clrb
                    std       ,u
                    clra
                    clrb
                    std       $08,u
                    ldd       [$04,s]
                    std       $12,u
                    stu       [$04,s]
                    ldd       $04,s
                    std       $0e,u
L65CA               tfr       u,d
                    leas      $06,s
                    puls      pc,u
L65D0               pshs      u
                    leas      -$09,s
                    ldd       #$0008
                    pshs      d
                    ldd       $0f,s
                    pshs      d
                    leax      $04,s
                    pshs      x
                    lbsr      $A64F
                    leas      $06,s
                    clra
                    clrb
                    stb       $08,s
                    leax      ,s
                    pshs      x
                    lbsr      L652E
                    leas      $02,s
                    tfr       d,u
                    ldd       #$0033
                    std       ,u
                    ldd       $0f,s
                    std       $08,u
                    leas      $09,s
                    puls      pc,u
L6602               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    clra
                    clrb
                    bra       L6610

L660C               ldd       $02,s
                    addd      ,s
L6610               std       $02,s
                    ldb       ,u+
                    sex
                    std       ,s
                    bne       L660C
                    ldd       $02,s
                    clra
                    andb      #$7f
                    leas      $04,s
                    puls      pc,u
L6622               pshs      u,d
                    ldd       $06,s
                    pshs      d
                    lbsr      $B253
                    leas      $02,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       L6640
                    leax      $6DC1,pcr
                    pshs      x
                    lbsr      L042D
                    leas      $02,s
L6640               ldd       L0046
                    bne       L6648
                    ldd       ,s
                    std       L0046
L6648               ldd       ,s
                    addd      $06,s
                    std       L0048
                    ldd       ,s
L6650               leas      $02,s
                    puls      pc,u
L6654               pshs      u
                    ldu       $06,s
                    leas      -$10,s
                    clra
                    clrb
                    std       $02,s
                    leax      $08,s
                    pshs      x
                    bsr       L666C
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
L666C               puls      x
                    lbsr      $AE34
                    leax      $08,s
                    stx       ,s
                    ldd       $14,s
                    cmpd      #$0006
                    bne       L6684
                    leax      $10,s
                    lbra      L67BF

L6684               ldb       $0045
                    cmpb      #$30
                    lbne      L6791
                    leas      -$06,s
                    lbsr      L42CF
                    ldb       $0045
                    cmpb      #$2e
                    bne       L66A0
                    lbsr      L42CF
                    leax      $16,s
                    lbra      L67BF

L66A0               leax      $02,s
                    pshs      x
                    bsr       L66AA
                    neg       $0000
                    neg       $0000
L66AA               puls      x
                    lbsr      LAEDF
                    ldb       $0045
                    cmpb      #$78
                    beq       L66BD
                    ldb       $0045
                    cmpb      #$58
                    lbne      L6733
L66BD               leas      -$02,s
                    bra       L66F6

L66C1               leax      $04,s
                    pshs      x
                    leax      $06,s
                    pshs      x
                    ldd       #$0004
                    lbsr      LAEF5
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $06,s
                    cmpd      #$0041
                    blt       L66E4
                    ldd       #$0037
                    bra       L66E7

L66E4               ldd       #$0030
L66E7               pshs      d
                    ldd       $08,s
                    subd      ,s++
                    lbsr      LAEC6
                    lbsr      LAE51
                    lbsr      LAEDF
L66F6               lbsr      L42CF
                    ldb       $0045
                    sex
                    pshs      d
                    lbsr      L6CB1
                    leas      $02,s
                    std       ,s
                    bne       L66C1
                    leas      $02,s
                    bra       L673F

L670B               leax      $02,s
                    pshs      x
                    leax      $04,s
                    pshs      x
                    ldd       #$0003
                    lbsr      LAEF5
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldb       $0045
                    sex
                    addd      #$FFD0
                    lbsr      LAEC6
                    lbsr      LAE51
                    lbsr      LAEDF
                    lbsr      L42CF
L6733               ldb       $0045
                    sex
                    pshs      d
                    lbsr      L6C9E
                    std       ,s++
                    bne       L670B
L673F               leax      $02,s
                    stx       ,s
                    ldb       $0045
                    cmpb      #$4C
                    beq       L674F
                    ldb       $0045
                    cmpb      #$6C
                    bne       L6757
L674F               lbsr      L42CF
                    leax      $16,s
                    bra       L6766

L6757               ldd       [,s]
                    bne       L6769
                    ldd       $04,s
                    std       ,u
                    ldd       #$0001
                    bra       L6775
                    bra       L6769

L6766               leas      -$16,x
L6769               leax      ,u
                    pshs      x
                    leax      $04,s
                    lbsr      LAEDF
                    ldd       #$0008
L6775               leas      $16,s
                    puls      pc,u
                    bra       L6791

L677C               ldb       $0045
                    sex
                    pshs      d
                    leax      $0a,s
                    pshs      x
                    lbsr      L9990
                    leas      $04,s
                    std       -$02,s
                    bne       L67D5
                    lbsr      L42CF
L6791               ldb       $0045
                    sex
                    leax      $00BA,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$6b
                    beq       L677C
                    ldb       $0045
                    cmpb      #$2e
                    beq       L67B4
                    ldb       $0045
                    cmpb      #$65
                    beq       L67B4
                    ldb       $0045
                    cmpb      #$45
                    lbne      L68BB
L67B4               ldb       $0045
                    cmpb      #$2e
                    bne       L67F4
                    lbsr      L42CF
                    bra       L67E5

L67BF               leas      -$10,x
                    bra       L67E5

L67C3               ldb       $0045
                    sex
                    pshs      d
                    leax      $0a,s
                    pshs      x
                    lbsr      L9990
                    leas      $04,s
                    std       -$02,s
                    beq       L67DB
L67D5               lbsr      L42CF
                    lbra      L68CB

L67DB               lbsr      L42CF
                    ldd       $02,s
                    addd      #$0001
                    std       $02,s
L67E5               ldb       $0045
                    sex
                    leax      $00BA,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$6b
                    beq       L67C3
L67F4               ldd       #$00B8
                    ldx       ,s
                    stb       $07,x
                    leax      $08,s
                    pshs      x
                    leax      $0a,s
                    pshs      x
                    lbsr      $A731
                    leas      $02,s
                    lbsr      $AE34
                    ldb       $0045
                    cmpb      #$45
                    beq       L6819
                    ldb       $0045
                    cmpb      #$65
                    lbne      L6887
L6819               ldd       #$0001
                    std       $04,s
                    lbsr      L42CF
                    ldb       $0045
                    cmpb      #$2b
                    bne       L682C
                    lbsr      L42CF
                    bra       L6839

L682C               ldb       $0045
                    cmpb      #$2d
                    bne       L6839
                    lbsr      L42CF
                    clra
                    clrb
                    std       $04,s
L6839               clra
                    clrb
                    std       $06,s
                    bra       L6858

L683F               ldd       $06,s
                    pshs      d
                    ldd       #$000A
                    lbsr      LAF4B
                    pshs      d
                    ldb       $0045
                    sex
                    addd      #$FFD0
                    addd      ,s++
                    std       $06,s
                    lbsr      L42CF
L6858               ldb       $0045
                    sex
                    leax      $00BA,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$6b
                    beq       L683F
                    ldd       $06,s
L6869               cmpd      #$0028
                    lbge      L68CB
                    ldd       $02,s
L6873               pshs      d
                    ldd       $06,s
                    beq       L6881
                    ldd       $08,s
                    nega
                    negb
                    sbca      #$00
                    bra       L6883

L6881               ldd       $08,s
L6883               addd      ,s++
                    std       $02,s
L6887               ldd       $02,s
                    bge       L6898
                    ldd       $02,s
                    nega
                    negb
                    sbca      #$00
                    std       $02,s
                    ldd       #$0001
                    bra       L689A

L6898               clra
                    clrb
L689A               std       $04,s
                    leax      ,u
                    pshs      x
                    ldd       $06,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    leax      $0e,s
                    lbsr      LAE0D
                    lbsr      L6926
                    leas      $0C,s
                    lbsr      $AE34
                    ldd       #$0006
                    lbra      L6921

L68BB               ldb       [,s]
                    bne       L68CB
                    ldx       ,s
                    ldb       $01,x
                    bne       L68CB
                    ldx       ,s
                    ldb       $02,x
                    beq       L68D0
L68CB               clra
                    clrb
                    lbra      L6921

L68D0               ldb       $0045
                    cmpb      #$6C
                    beq       L68DC
                    ldb       $0045
                    cmpb      #$4C
                    bne       L68FB
L68DC               leas      -$02,s
                    lbsr      L42CF
                    bra       L68E6

L68E3               leas      -$12,x
L68E6               ldd       $02,s
                    addd      #$0003
                    std       ,s
                    leax      ,u
                    pshs      x
                    ldx       $02,s
                    lbsr      LAEDF
                    ldd       #$0008
                    bra       L691C

L68FB               ldx       ,s
                    ldb       $03,x
                    bne       L6907
                    ldx       ,s
                    ldb       $04,x
                    beq       L690C
L6907               leax      $10,s
                    bra       L68E3

L690C               leas      -$02,s
                    ldd       $02,s
                    addd      #$0005
                    std       ,s
                    ldd       [,s]
                    std       ,u
                    ldd       #$0001
L691C               leas      $12,s
                    puls      pc,u
L6921               leas      $10,s
                    puls      pc,u
L6926               pshs      u
                    ldd       $0C,s
                    cmpd      #$0009
                    ble       L6955
                    leax      $04,s
                    pshs      x
                    ldd       $10,s
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    ldd       #$000A
                    lbsr      $AFFF
                    addd      #$0009
                    pshs      d
                    leax      $0a,s
                    lbsr      LAE0D
                    bsr       L6970
                    leas      $0C,s
                    lbsr      $AE34
L6955               ldd       $0e,s
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    ldd       #$000A
                    lbsr      $AFAC
L6963               pshs      d
                    leax      $08,s
                    lbsr      LAE0D
                    bsr       L6970
L696C               leas      $0C,s
L696E               puls      pc,u
L6970               pshs      u
                    ldd       $0C,s
L6974               beq       L69B6
                    leas      -$02,s
                    leax      $01BA,y
                    stx       ,s
                    ldd       ,s
                    pshs      d
                    ldd       $10,s
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    addd      ,s++
                    std       ,s
                    ldd       $10,s
                    beq       L69A0
                    leax      $06,s
                    lbsr      LAE0D
                    ldx       $08,s
                    lbsr      $A765
                    bra       L69AA

L69A0               leax      $06,s
                    lbsr      LAE0D
                    ldx       $08,s
                    lbsr      $A76D
L69AA               leau      $0358,y
                    pshs      u
                    lbsr      $AE34
                    lbra      L6C9A

L69B6               leax      $04,s
                    leau      $0358,y
                    pshs      u
                    lbsr      $AE34
                    puls      pc,u
L69C3               pshs      u
                    lbsr      L42CF
                    ldb       $0045
                    cmpb      #$5C
                    bne       L69D5
                    lbsr      L6B4B
                    std       $0041
                    bra       L69DD

L69D5               ldb       $0045
                    sex
                    std       $0041
                    lbsr      L42CF
L69DD               ldb       $0045
                    cmpb      #$27
                    lbeq      L6ABC
                    leax      $6DCF,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
                    lbra      L6ABF

L69F3               pshs      u
                    ldx       L0056
                    bra       L6A27

L69F9               ldd       L004C
                    bne       L6A1D
                    leax      $6DEF,pcr
                    pshs      x
                    leax      $0096,y
                    pshs      x
                    lbsr      L9F43
                    leas      $04,s
                    std       L004C
                    bne       L6A1D
                    leax      L6DF2,pcr
                    pshs      x
                    lbsr      L042D
                    leas      $02,s
L6A1D               ldd       L004C
                    bra       L6A23

L6A21               ldd       $0005
L6A23               std       $0064
                    bra       L6A37

L6A27               stx       -$02,s
                    beq       L69F9
                    cmpx      #$0002
                    lbeq      L69F9
                    cmpx      #$0001
                    beq       L6A21
L6A37               clra
                    clrb
                    std       $0060
                    ldd       L0056
                    cmpd      #$0001
                    lbeq      L6A99
                    ldd       $000B
                    addd      #$0001
                    std       $000B
                    std       $0041
                    pshs      d
                    ldd       #$005F
                    pshs      d
                    leax      $6E0A,pcr
                    pshs      x
                    ldd       $0064
                    pshs      d
                    lbsr      L9A34
                    leas      $08,s
                    bra       L6A99

L6A66               leax      $0584,y
                    pshs      x
                    ldd       $004A
                    subd      ,s++
                    bne       L6A7F
                    leax      L6E0F,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
                    bra       L6AA2

L6A7F               ldb       $0045
                    cmpb      #$5C
                    bne       L6A90
                    lbsr      L6B4B
                    pshs      d
                    bsr       L6AC1
                    leas      $02,s
                    bra       L6A9C

L6A90               ldb       $0045
                    sex
                    pshs      d
                    bsr       L6AC1
                    leas      $02,s
L6A99               lbsr      L42CF
L6A9C               ldb       $0045
                    cmpb      #$22
                    bne       L6A66
L6AA2               clra
                    clrb
                    pshs      d
                    bsr       L6AC1
                    leas      $02,s
                    ldd       $0064
                    pshs      d
                    ldd       #$000D
                    pshs      d
                    lbsr      $A1CD
                    leas      $04,s
                    clra
                    clrb
                    std       $003D
L6ABC               lbsr      L42CF
L6ABF               puls      pc,u
L6AC1               pshs      u
                    ldd       $003D
                    bne       L6AD6
                    leax      $6E23,pcr
                    pshs      x
                    ldd       $0064
                    pshs      d
                    lbsr      L9A34
                    leas      $04,s
L6AD6               ldd       $04,s
                    cmpd      #$0020
                    blt       L6AE6
                    ldd       $04,s
                    cmpd      #$0022
                    bne       L6AFB
L6AE6               ldd       $04,s
                    pshs      d
                    leax      L6E2A,pcr
                    pshs      x
                    ldd       $0064
                    pshs      d
                    lbsr      L9A34
                    leas      $06,s
                    bra       L6B27

L6AFB               ldd       $0064
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      $A1CD
                    leas      $04,s
                    ldd       $003D
                    addd      #$0001
                    std       $003D
                    subd      #$0001
                    cmpd      #$004B
                    blt       L6B2B
                    leax      L6E36,pcr
                    pshs      x
                    ldd       $0064
                    pshs      d
                    lbsr      L9A34
                    leas      $04,s
L6B27               clra
                    clrb
                    std       $003D
L6B2B               ldd       $0060
                    addd      #$0001
                    std       $0060
                    puls      pc,u
L6B34               pshs      u
                    ldd       $04,s
                    pshs      d
                    leax      $6E39,pcr
                    pshs      x
                    ldd       $0064
                    pshs      d
                    lbsr      L9A34
                    leas      $06,s
                    puls      pc,u
L6B4B               pshs      u,d
                    lbsr      L42CF
                    ldb       $0045
                    sex
                    tfr       d,u
                    lbsr      L42CF
                    leax      ,u
                    bra       L6B86

L6B5C               ldd       #$000A
                    lbra      L6C9A

L6B62               ldd       #$0009
                    lbra      L6C9A

L6B68               ldd       #$0008
                    lbra      L6C9A

L6B6E               ldd       #$000B
                    lbra      L6C9A

L6B74               ldd       #$000D
                    lbra      L6C9A

L6B7A               ldd       #$000C
                    lbra      L6C9A

L6B80               ldd       #$0020
                    lbra      L6C9A

L6B86               cmpx      #$006E
                    beq       L6B74
                    cmpx      #$006C
                    beq       L6B5C
                    cmpx      #$0074
                    beq       L6B62
                    cmpx      #$0062
                    beq       L6B68
                    cmpx      #$0076
                    beq       L6B6E
                    cmpx      #$0072
                    lbeq      L6B74
                    cmpx      #$0066
                    beq       L6B7A
                    cmpx      #$000D
                    beq       L6B80
                    cmpu      #$0078
                    lbne      L6C0C
                    leas      -$02,s
                    clra
                    clrb
                    std       $02,s
                    tfr       d,u
                    bra       L6BE9

L6BC2               tfr       u,d
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    pshs      d
                    ldd       $02,s
                    cmpd      #$0041
                    bge       L6BDD
                    ldd       $02,s
                    addd      #$FFD0
                    bra       L6BE2

L6BDD               ldd       $02,s
                    addd      #$FFC9
L6BE2               addd      ,s++
                    tfr       d,u
                    lbsr      L42CF
L6BE9               ldb       $0045
                    sex
                    pshs      d
                    lbsr      L6CB1
                    leas      $02,s
                    std       ,s
                    beq       L6C07
                    ldd       $02,s
                    addd      #$0001
                    std       $02,s
                    subd      #$0001
                    cmpd      #$0002
                    blt       L6BC2
L6C07               leas      $02,s
                    lbra      L6C98

L6C0C               cmpu      #$0064
                    bne       L6C54
                    clra
                    clrb
                    std       ,s
                    tfr       d,u
                    bra       L6C31

L6C1A               pshs      u
                    ldd       #$000A
                    lbsr      LAF4B
                    pshs      d
                    ldb       $0045
                    sex
                    addd      ,s++
                    addd      #$FFD0
                    tfr       d,u
                    lbsr      L42CF
L6C31               ldb       $0045
                    sex
                    leax      $00BA,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$6b
                    lbne      L6C98
                    ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    cmpd      #$0003
                    blt       L6C1A
                    bra       L6C98

L6C54               pshs      u
                    lbsr      L6C9E
                    std       ,s++
                    beq       L6C98
                    leau      -$30,u
                    clra
                    clrb
L6C62               std       ,s
                    bra       L6C7D

L6C66               tfr       u,d
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    pshs      d
                    ldb       $0045
                    sex
                    addd      #$FFD0
                    addd      ,s++
                    tfr       d,u
                    lbsr      L42CF
L6C7D               ldb       $0045
                    sex
                    pshs      d
                    bsr       L6C9E
                    std       ,s++
                    beq       L6C98
                    ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    cmpd      #$0003
                    blt       L6C66
L6C98               tfr       u,d
L6C9A               leas      $02,s
                    puls      pc,u
L6C9E               pshs      u
                    ldb       $05,s
                    cmpb      #$37
                    bgt       L6CDA
                    ldb       $05,s
                    cmpb      #$30
                    blt       L6CDA
                    ldd       #$0001
                    bra       L6CDC

L6CB1               pshs      u
                    ldb       $05,s
                    sex
                    leax      $00BA,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$6b
                    beq       L6CD5
                    ldb       $05,s
                    clra
                    andb      #$5f
                    stb       $05,s
                    cmpd      #$0041
                    blt       L6CDA
                    ldb       $05,s
                    cmpb      #$46
                    bgt       L6CDA
L6CD5               ldb       $05,s
                    sex
                    bra       L6CDC

L6CDA               clra
                    clrb
L6CDC               puls      pc,u
L6CDE               fcb       $62
                    fcb       $61
                    lsr       0,y
                    com       $08,s
                    fcb       $61
                    fcb       $72
                    fcb       $61
                    com       -$0C,s
                    fcb       $65
                    fcb       $72
                    neg       L0063
                    clr       $0e,s
                    com       $7461
                    jmp       -$0C,s
                    bra       $6D65
                    ror       $6572
                    ror       $0C,s
                    clr       -$09,s
                    neg       $0064
                    clr       -$0b,s
                    fcb       $62
                    inc       $05,s
                    neg       $0066
                    inc       $0f,s
                    fcb       $61
                    lsr       >$0074
                    rol       L7065
                    lsr       $05,s
                    ror       0,x
L6D13               com       $7461
                    lsr       L6963
                    neg       $0073
                    rol       -$06,s
                    fcb       $65
                    clr       $06,s
                    neg       $0069
                    jmp       -$0C,s
                    neg       $0069
                    jmp       -$0C,s
                    neg       $0066
                    inc       $0f,s
                    fcb       $61
                    lsr       >L0063
                    asl       $01,s
                    fcb       $72
                    neg       $0073
                    asl       $0f,s
                    fcb       $72
                    lsr       >L0061
                    fcb       $75
                    lsr       L6F00
L6D3F               fcb       $65
                    asl       $7465
                    fcb       $72
                    jmp       0,x

L6D46               lsr       $09,s
                    fcb       $72
                    fcb       $65
                    com       -$0C,s
                    neg       $0072
                    fcb       $65
                    asr       $09,s
                    com       $7465
                    fcb       $72
                    neg       $0067
                    clr       -$0C,s
                    clr       0,x
L6D5B               fcb       $72
                    fcb       $65
                    lsr       $7572
                    jmp       0,x

L6D62               rol       $06,s
                    neg       $0077
                    asl       $09,s
                    inc       $05,s
                    neg       L0065
                    inc       -$0d,s
                    fcb       $65
                    neg       $0073
                    asr       L6974
                    com       $08,s
                    neg       L0063
                    fcb       $61
                    com       L6500
L6D7C               fcb       $62
                    fcb       $72
                    fcb       $65
                    fcb       $61
                    fcb       $6b
                    neg       L0063
                    clr       $0e,s
                    lsr       L696E
                    fcb       $75
                    fcb       $65
                    neg       $0064
                    clr       0,x
L6D8E               lsr       $05,s
                    ror       $01,s
                    fcb       $75
                    inc       -$0C,s
                    neg       $0066
                    clr       -$0e,s
                    neg       $0073
                    lsr       L7275
                    com       -$0C,s
                    neg       L0075
                    jmp       $09,s
                    clr       $0e,s
                    neg       L0075
                    jmp       -$0d,s
                    rol       $07,s
                    jmp       $05,s
                    lsr       0,x
L6DB0               inc       $0f,s
                    jmp       $07,s
                    neg       L0065
                    fcb       $72
                    fcb       $72
                    jmp       $0f,s
                    neg       L006C
                    com       L6565
                    fcb       $6b
                    neg       $006F
                    fcb       $75
                    lsr       $206F
                    ror       0,y
                    tst       $05,s
                    tst       $0f,s
                    fcb       $72
                    rol       >L0075
                    jmp       -$0C,s
                    fcb       $65
                    fcb       $72
                    tst       $09,s
                    jmp       $01,s
                    lsr       $6564
                    bra       L6E40
                    asl       $01,s
                    fcb       $72
                    fcb       $61
                    com       -$0C,s
                    fcb       $65
                    fcb       $72
                    bra       L6E4A
                    clr       $0e,s
                    com       $7461
                    jmp       -$0C,s
                    neg       $0077
                    bmi       L6DF2
L6DF2               com       $01,s
                    jmp       $07,y
                    lsr       $206F
                    neg       $656E
                    bra       L6E71
                    lsr       L7269
                    jmp       $07,s
                    com       L2066
                    rol       $0C,s
                    fcb       $65
                    neg       L0025
                    com       $05,y
                    lsr       0,x
L6E0F               fcb       $75
                    jmp       -$0C,s
                    fcb       $65
                    fcb       $72
                    tst       $09,s
                    jmp       $01,s
                    lsr       $6564
                    bra       $6E90
                    lsr       L7269
L6E20               jmp       $07,s
                    neg       $0020
                    ror       $03,s
                    com       0,y
                    bhi       L6E2A
L6E2A               bhi       $6E39
                    bra       L6E94
                    com       $02,s
                    bra       $6E56
                    bcs       L6EAC
                    tst       $0000
L6E36               bhi       $6E45
                    neg       $0020
                    fcb       $72
                    dec       $6220
                    bcs       $6EA4
L6E40               tst       $0000
L6E42               pshs      u
                    ldd       #$FFB4
                    lbsr      L010F
L6E4A               ldu       $04,s
                    pshs      u
                    lbsr      L6EAC
                    leas      $02,s
                    ldd       $06,u
                    cmpd      #$0070
                    beq       L6EAA
                    pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
L6E71               ldd       #$0070
L6E74               bra       L6EA8

L6E76               pshs      u
                    ldd       #$FFB4
                    lbsr      L010F
                    ldu       $04,s
                    pshs      u
                    lbsr      L7E9C
                    leas      $02,s
                    ldd       $06,u
                    cmpd      #$0071
                    beq       L6EAA
                    pshs      u
                    ldd       #$0077
L6E94               pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
                    ldd       #$0071
L6EA8               std       $06,u
L6EAA               puls      pc,u
L6EAC               pshs      u
                    ldd       #$FFBA
                    lbsr      L010F
                    ldu       $04,s
                    ldx       ,u
                    bra       L6ED7

L6EBA               pshs      u
                    lbsr      L34BE
                    bra       L6ED3

L6EC1               pshs      u
                    lbsr      $3987
                    bra       L6ED3

L6EC8               pshs      u
                    lbsr      L6F83
                    leas      $02,s
                    pshs      u
                    bsr       L6EEC
L6ED3               leas      $02,s
                    bra       L6EEA

L6ED7               cmpx      #$0008
                    beq       L6EBA
                    cmpx      #$0005
                    beq       L6EC1
                    cmpx      #$0006
                    lbeq      L6EC1
                    bra       L6EC8

L6EEA               puls      pc,u
L6EEC               pshs      u
                    ldd       #$FFB4
                    lbsr      L010F
                    ldu       $04,s
                    ldx       $06,u
                    lbra      L6F5F

L6EFB               pshs      u
                    ldd       #$0077
L6F00               pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
                    ldd       #$0071
                    std       $06,u
                    clra
                    clrb
                    std       $08,u
                    lbra      L6F81

L6F1D               ldd       $0a,u
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$007F
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
                    clra
                    clrb
                    std       $08,u
                    ldd       #$0071
                    bra       L6F5B

L6F3E               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
                    bra       L6F58
                    leas      ,x
L6F58               ldd       #$0070
L6F5B               std       $06,u
                    bra       L6F81

L6F5F               cmpx      #$0037
                    lbeq      L6EFB
                    cmpx      #$0041
L6F69               beq       L6F1D
                    cmpx      #$0071
                    beq       L6F81
                    cmpx      #$0070
                    beq       L6F81
                    cmpx      #$006F
                    beq       L6F81
                    cmpx      #$0076
                    beq       L6F81
                    bra       L6F3E

L6F81               puls      pc,u
L6F83               pshs      u
                    ldd       #$FFB4
                    lbsr      L010F
                    ldu       $04,s
                    leas      -$02,s
                    ldd       $06,u
                    std       ,s
                    cmpd      #$0030
                    bne       L6FCC
                    leas      -$02,s
                    ldd       $0C,u
                    std       ,s
                    ldd       $0a,u
                    pshs      d
                    bsr       L6F83
                    std       ,s
                    lbsr      L0598
                    leas      $02,s
                    pshs      u
                    ldd       $02,s
                    pshs      d
                    lbsr      L05C9
                    leas      $04,s
                    ldd       ,s
                    pshs      d
                    lbsr      L05B9
                    leas      $02,s
                    pshs      u
                    lbsr      L6F83
                    leas      $02,s
                    leas      $02,s
                    lbra      L7176

L6FCC               ldd       ,u
                    cmpd      #$0008
                    bne       L6FDE
                    pshs      u
                    lbsr      L34D9
                    leas      $02,s
                    lbra      L7176

L6FDE               ldd       ,u
                    cmpd      #$0005
                    beq       L6FEE
                    ldd       ,u
                    cmpd      #$0006
                    bne       L6FF8
L6FEE               pshs      u
                    lbsr      L39A2
                    leas      $02,s
                    lbra      L7176

L6FF8               ldd       ,s
                    pshs      d
                    lbsr      L06A0
                    std       ,s++
                    beq       L7011
                    pshs      u
                    ldd       $02,s
                    pshs      d
                    lbsr      L717C
                    leas      $04,s
                    lbra      L7176

L7011               ldx       ,s
                    lbra      L70DD

L7016               pshs      u
                    lbsr      L77E6
                    lbra      L70A6

L701E               ldd       $0a,u
                    pshs      d
                    lbsr      L6F83
                    lbra      L70A6

L7028               ldd       $0a,u
                    pshs      d
                    lbsr      L34D9
                    leas      $02,s
                    ldd       $0a,u
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       #$0084
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
                    bra       L708D

L7046               ldd       $0a,u
                    pshs      d
                    lbsr      $3987
                    leas      $02,s
                    ldd       #$008F
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L4623
                    bra       L708B

L705E               pshs      u
                    lbsr      L7BD2
                    bra       L70A6

L7065               pshs      u
                    lbsr      L74CB
                    bra       L70A6

L706C               ldd       $0a,u
                    pshs      d
                    lbsr      L6E42
                    leas      $02,s
                    ldd       ,s
                    pshs      d
                    lbsr      L4623
                    leas      $02,s
                    bra       L708D

L7080               leax      L6E42,pcr
                    pshs      x
                    pshs      u
                    lbsr      L7567
L708B               leas      $04,s
L708D               ldd       #$0070
                    std       $06,u
                    lbra      L7176

L7095               ldd       #$0070
                    pshs      d
                    pshs      u
                    lbsr      L7D19
                    bra       L70D8

L70A1               pshs      u
                    lbsr      L75E3
L70A6               leas      $02,s
                    lbra      L7176

L70AB               ldd       ,s
                    cmpd      #$00A0
                    blt       L70BE
                    ldd       ,s
                    pshs      d
                    pshs      u
                    lbsr      L794A
                    bra       L70D8

L70BE               leax      L8153,pcr
                    pshs      x
                    pshs      u
                    lbsr      L0464
                    leas      $04,s
                    ldd       ,s
                    pshs      d
                    leax      L815F,pcr
                    pshs      x
                    lbsr      L9A1F
L70D8               leas      $04,s
                    lbra      L7176

L70DD               cmpx      #$0037
                    lbeq      L7176
                    cmpx      #$0034
                    lbeq      L7176
                    cmpx      #$0076
                    lbeq      L7176
                    cmpx      #$006F
                    lbeq      L7176
                    cmpx      #$0041
                    beq       L7176
                    cmpx      #$0036
                    beq       L7176
                    cmpx      #$0078
                    lbeq      L7016
                    cmpx      #$0085
                    lbeq      L701E
                    cmpx      #$0084
                    lbeq      L7028
                    cmpx      #$008F
                    lbeq      L7046
                    cmpx      #$0042
                    lbeq      L705E
                    cmpx      #$0040
                    lbeq      L7065
                    cmpx      #$0047
                    lbeq      L7065
                    cmpx      #$0048
                    lbeq      L7065
                    cmpx      #$0044
                    lbeq      L706C
                    cmpx      #$0043
                    lbeq      L706C
                    cmpx      #$0064
                    lbeq      L7080
                    cmpx      #$003C
                    lbeq      L7095
                    cmpx      #$003E
                    lbeq      L7095
                    cmpx      #$003D
                    lbeq      L7095
                    cmpx      #$003F
                    lbeq      L7095
                    cmpx      #$0065
                    lbeq      L70A1
                    lbra      L70AB

L7176               tfr       u,d
                    leas      $02,s
                    puls      pc,u
L717C               pshs      u
                    ldd       #$FFAE
                    lbsr      L010F
                    leas      -$06,s
                    ldx       $0C,s
                    ldu       $0a,x
                    ldx       $0C,s
                    ldd       $0C,x
                    std       $04,s
                    ldd       ,u
                    cmpd      #$0007
                    bne       L71BE
                    ldx       $0a,s
                    bra       L71AD

L719C               ldd       #$004E
                    bra       L71A9

L71A1               ldd       #$004C
                    bra       L71A9

L71A6               ldd       #$004D
L71A9               std       $0a,s
                    bra       L71F2

L71AD               cmpx      #$0053
                    beq       L719C
                    cmpx      #$0054
                    beq       L71A1
                    cmpx      #$0055
                    beq       L71A6
                    bra       L71F2

L71BE               ldx       $0a,s
                    bra       L71E6

L71C2               ldd       $06,u
                    cmpd      #$0041
                    bne       L71F2
                    ldx       $04,s
                    ldd       $06,x
                    cmpd      #$0036
                    beq       L71F2
                    ldd       $0C,s
                    pshs      d
                    lbsr      L7E9C
                    leas      $02,s
                    clra
                    clrb
                    std       $0066
                    lbra      L75DF
                    bra       L71F2

L71E6               cmpx      #$0050
                    beq       L71C2
                    cmpx      #$0051
                    lbeq      L71C2
L71F2               ldx       $0a,s
                    lbra      L73E6

L71F7               ldd       $04,s
                    pshs      d
                    lbsr      L9754
                    std       ,s++
L7200               bne       L7229
                    ldd       $04,s
                    pshs      d
                    lbsr      L6EAC
                    leas      $02,s
                    ldx       $04,s
                    ldd       $06,x
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
                    ldd       #$006E
                    ldx       $04,s
L7220               std       $06,x
                    pshs      u
                    lbsr      L6E42
                    bra       L7237

L7229               pshs      u
                    lbsr      L6E42
L722E               leas      $02,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L6F83
L7237               leas      $02,s
                    ldd       $04,s
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0051
                    lbra      L72E2

L724D               pshs      u
                    lbsr      L9754
                    std       ,s++
                    beq       L7261
                    ldd       $04,s
                    pshs      d
                    lbsr      L9754
                    std       ,s++
                    beq       L7269
L7261               ldd       $06,u
                    cmpd      #$0036
                    bne       L7275
L7269               leas      -$02,s
                    stu       ,s
                    ldu       $06,s
L726F               ldd       ,s
                    std       $06,s
                    leas      $02,s
L7275               ldd       $06,u
                    pshs      d
                    lbsr      L8132
                    std       ,s++
                    beq       L72A0
                    ldd       $06,u
L7282               pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L6E42
                    leas      $02,s
                    ldd       #$006E
                    ldx       $04,s
                    std       $06,x
                    bra       L72D1

L72A0               pshs      u
                    lbsr      L6E42
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L9754
                    std       ,s++
                    bne       L72B7
                    ldd       #$0070
                    bra       L7282

L72B7               ldd       $04,s
                    pshs      d
                    lbsr      L6F83
                    leas      $02,s
                    ldd       $0a,s
                    cmpd      #$0050
                    beq       L72D1
                    ldd       $04,s
                    pshs      d
                    lbsr      L77AC
                    leas      $02,s
L72D1               ldd       $04,s
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       $10,s
L72E2               pshs      d
                    lbsr      L4623
                    leas      $08,s
                    lbra      L748C

L72EC               ldd       $0C,s
                    pshs      d
                    lbsr      L74CB
                    lbra      L73CF

L72F6               ldx       $04,s
                    ldd       $06,x
                    cmpd      #$0036
                    lbne      L735A
                    ldx       $04,s
                    ldd       $08,x
                    std       ,s
                    bra       L730C

L730A               leas      -$06,x
L730C               ldd       ,s
                    cmpd      #$0004
                    bhi       L735A
                    pshs      u
                    lbsr      L6E42
L7319               leas      $02,s
                    bra       L7344

L731D               ldx       $0a,s
                    bra       L7335

L7321               ldd       #$0098
                    bra       L732E

L7326               ldd       #$0096
                    bra       L732E

L732B               ldd       #$0097
L732E               pshs      d
                    lbsr      L4623
                    bra       L7319

L7335               cmpx      #$0056
                    beq       L7321
                    cmpx      #$0055
                    beq       L7326
                    cmpx      #$004D
                    beq       L732B
L7344               ldd       ,s
                    addd      #$FFFF
                    std       ,s
                    subd      #$FFFF
                    bne       L731D
                    ldd       #$0001
                    std       $0066
                    leax      $06,s
                    lbra      L7492

L735A               leax      $06,s
                    bra       L73A8

L735E               ldd       $06,u
                    cmpd      #$0036
                    bne       L7372
                    leas      -$02,s
L7368               stu       ,s
                    ldu       $06,s
                    ldd       ,s
                    std       $06,s
                    leas      $02,s
L7372               ldx       $04,s
                    ldd       $06,x
                    cmpd      #$0036
                    bne       L73AA
                    ldx       $04,s
                    ldd       $08,x
                    pshs      d
                    lbsr      L749E
                    leas      $02,s
                    std       ,s
                    beq       L73AA
                    ldd       ,s
                    ldx       $04,s
                    std       $08,x
                    ldd       $0a,s
                    cmpd      #$0052
                    bne       L739E
                    ldd       #$0056
                    bra       L73A1

L739E               ldd       #$004D
L73A1               std       $0a,s
                    leax      $06,s
                    lbra      L730A

L73A8               leas      -$06,x
L73AA               pshs      u
                    lbsr      L6EAC
                    leas      $02,s
                    ldd       $06,u
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L6E42
                    leas      $02,s
                    ldd       $0a,s
                    pshs      d
                    lbsr      L4623
L73CF               leas      $02,s
                    lbra      L748C

L73D4               leax      L8163,pcr
                    pshs      x
                    ldd       $0e,s
                    pshs      d
                    lbsr      L0464
                    leas      $04,s
                    lbra      L748C

L73E6               cmpx      #$0051
                    lbeq      L71F7
                    cmpx      #$0057
                    lbeq      L724D
                    cmpx      #$0058
                    lbeq      L724D
                    cmpx      #$0059
                    lbeq      L724D
                    cmpx      #$0050
                    lbeq      L724D
                    cmpx      #$005A
                    lbeq      L72EC
                    cmpx      #$005B
                    lbeq      L72EC
                    cmpx      #$005F
                    lbeq      L72EC
                    cmpx      #$005D
                    lbeq      L72EC
                    cmpx      #$005C
                    lbeq      L72EC
                    cmpx      #$005E
                    lbeq      L72EC
                    cmpx      #$0063
                    lbeq      L72EC
                    cmpx      #$0061
                    lbeq      L72EC
                    cmpx      #$0060
                    lbeq      L72EC
                    cmpx      #$0062
                    lbeq      L72EC
                    cmpx      #$004D
                    lbeq      L72F6
                    cmpx      #$0055
                    lbeq      L72F6
                    cmpx      #$0056
                    lbeq      L72F6
                    cmpx      #$0052
                    lbeq      L735E
L746B               cmpx      #$004E
                    lbeq      L7372
L7472               cmpx      #$0053
                    lbeq      L73AA
                    cmpx      #$004C
                    lbeq      L73AA
                    cmpx      #$0054
                    lbeq      L73AA
                    lbra      L73D4
                    leas      -$06,x
L748C               clra
                    clrb
                    std       $0066
                    bra       L7494

L7492               leas      -$06,x
L7494               ldd       #$0070
                    ldx       $0C,s
                    std       $06,x
                    lbra      L75DF

L749E               pshs      u
                    ldd       #$FFC0
                    lbsr      L010F
                    ldu       #$0000
                    bra       L74C2

L74AB               tfr       u,d
                    leau      $01,u
                    aslb
                    rola
                    leax      $0222,y
                    leax      d,x
                    ldd       ,x
                    cmpd      $04,s
                    bne       L74C2
                    tfr       u,d
                    puls      pc,u
L74C2               cmpu      #$000E
                    blt       L74AB
                    lbra      L77A8

L74CB               pshs      u
                    ldd       #$FFB0
                    lbsr      L010F
                    ldu       $04,s
                    leas      -$04,s
                    ldd       #$0001
                    pshs      d
                    ldd       $000B
                    addd      #$0001
                    std       $000B
                    std       $02,s
                    pshs      d
                    ldd       $000B
                    addd      #$0001
                    std       $000B
                    std       $06,s
                    pshs      d
                    pshs      u
                    lbsr      L939D
                    leas      $08,s
                    ldd       $02,s
                    pshs      d
                    lbsr      L57B2
                    leas      $02,s
                    ldd       #$0001
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
                    ldd       #$0001
                    pshs      d
                    ldd       $000B
                    addd      #$0001
                    std       $000B
                    std       $04,s
                    pshs      d
                    ldd       #$007C
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
                    ldd       ,s
                    pshs      d
                    lbsr      L57B2
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
                    ldd       $02,s
                    pshs      d
                    lbsr      L57B2
                    leas      $02,s
                    ldd       #$0070
                    std       $06,u
                    lbra      L7D15

L7567               pshs      u
                    ldd       #$FFAE
L756C               lbsr      L010F
                    ldu       $04,s
                    leas      -$06,s
                    ldd       #$0001
                    pshs      d
                    ldd       $000B
                    addd      #$0001
                    std       $000B
                    std       $02,s
                    pshs      d
                    ldd       $000B
                    addd      #$0001
                    std       $000B
                    std       $08,s
                    pshs      d
                    ldd       $0a,u
                    pshs      d
                    lbsr      L939D
                    leas      $08,s
                    ldu       $0C,u
                    ldd       $04,s
                    pshs      d
                    lbsr      L57B2
                    leas      $02,s
                    ldd       $0a,u
                    pshs      d
                    jsr       [$0e,s]
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    ldd       $000B
                    addd      #$0001
                    std       $000B
                    std       $04,s
                    pshs      d
                    ldd       #$007C
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
                    ldd       ,s
                    pshs      d
                    lbsr      L57B2
                    leas      $02,s
                    ldd       $0C,u
                    pshs      d
                    jsr       [$0e,s]
                    leas      $02,s
                    ldd       $02,s
                    pshs      d
                    lbsr      L57B2
                    leas      $02,s
L75DF               leas      $06,s
                    puls      pc,u
L75E3               pshs      u
                    ldd       #$FFB2
                    lbsr      L010F
                    leas      -$04,s
                    ldd       $000F
                    std       ,s
                    ldd       $08,s
                    std       $02,s
                    lbra      L7680

L75F8               ldx       $02,s
                    ldu       $0a,x
                    ldd       ,u
                    cmpd      #$0008
                    bne       L7627
                    ldd       $06,u
                    cmpd      #$004A
                    bne       L7616
                    pshs      u
                    lbsr      L38E8
                    leas      $02,s
                    lbra      L7680

L7616               pshs      u
                    lbsr      L34BE
                    leas      $02,s
                    ldd       #$006E
                    pshs      d
                    ldd       #$0088
                    bra       L7679

L7627               ldd       ,u
                    cmpd      #$0005
                    beq       L7637
                    ldd       ,u
                    cmpd      #$0006
                    bne       L7648
L7637               pshs      u
                    lbsr      $3987
                    leas      $02,s
                    ldd       #$006E
                    pshs      d
                    ldd       #$0087
                    bra       L7679

L7648               pshs      u
                    lbsr      L6F83
                    leas      $02,s
                    ldx       $06,u
                    bra       L765C

L7653               pshs      u
                    lbsr      L6EEC
                    leas      $02,s
                    bra       L7672

L765C               cmpx      #$0070
                    beq       L7672
                    cmpx      #$0071
                    beq       L7672
                    cmpx      #$006F
                    beq       L7672
                    cmpx      #$0076
                    beq       L7672
                    bra       L7653

L7672               ldd       $06,u
                    pshs      d
                    ldd       #$007A
L7679               pshs      d
                    lbsr      L4623
                    leas      $04,s
L7680               ldx       $02,s
                    ldd       $0C,x
                    std       $02,s
                    lbne      L75F8
                    ldx       $08,s
                    ldd       $0a,x
                    pshs      d
                    lbsr      L6F83
                    leas      $02,s
                    ldx       $08,s
                    ldd       $0a,x
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       #$0065
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
                    ldd       ,s
                    pshs      d
                    lbsr      L57E3
                    leas      $02,s
                    std       $000F
                    ldd       #$0070
                    ldx       $08,s
                    std       $06,x
                    lbra      L7D15

L76BF               pshs      u
                    ldd       #$FFB8
                    lbsr      L010F
                    ldu       $04,s
                    leas      -$02,s
                    ldx       $06,u
                    bra       L7704

L76CF               ldd       $0a,u
                    std       ,s
                    tfr       d,x
                    ldx       $06,x
                    bra       L76E8

L76D9               ldd       #$0001
                    bra       L7719

L76DE               ldd       ,s
                    pshs      d
                    bsr       L771D
                    leas      $02,s
                    bra       L7719

L76E8               cmpx      #$0036
                    beq       L76D9
                    cmpx      #$0034
                    lbeq      L76D9
                    cmpx      #$0076
                    lbeq      L76D9
                    cmpx      #$006F
                    lbeq      L76D9
                    bra       L76DE

L7704               cmpx      #$0034
                    lbeq      L76D9
                    cmpx      #$0036
                    lbeq      L76D9
                    cmpx      #$0042
                    beq       L76CF
                    clra
                    clrb
L7719               leas      $02,s
                    puls      pc,u
L771D               pshs      u
                    ldd       #$FFBA
                    lbsr      L010F
                    ldu       $04,s
                    ldx       $06,u
                    bra       L774B

L772B               ldx       $0a,u
                    ldd       $06,x
                    pshs      d
                    lbsr      L8132
                    std       ,s++
                    lbeq      L77A8
                    ldx       $0C,u
                    ldd       $06,x
                    cmpd      #$0036
                    lbne      L77A8
                    bra       L7789
                    lbra      L77A8

L774B               cmpx      #$0050
                    beq       L772B
                    cmpx      #$0051
                    lbeq      L772B
                    bra       L77A8

L7759               pshs      u
                    ldd       #$FFC0
                    lbsr      L010F
                    ldx       $04,s
                    ldd       $12,x
                    cmpd      #$0002
                    bge       L77A8
                    ldd       #$0001
                    bra       L77AA

L7771               pshs      u
                    ldd       #$FFC0
                    lbsr      L010F
                    ldu       $04,s
                    ldx       $06,u
                    bra       L7790

L777F               ldx       $0a,u
                    ldd       $06,x
                    cmpd      #$0041
                    bne       L77A8
L7789               ldd       #$0001
                    puls      pc,u
                    bra       L77A8

L7790               cmpx      #$0050
                    beq       L777F
                    cmpx      #$0051
                    lbeq      L777F
                    cmpx      #$0037
                    beq       L7789
                    cmpx      #$0041
                    lbeq      L7789
L77A8               clra
                    clrb
L77AA               puls      pc,u
L77AC               pshs      u
                    ldd       #$FFB4
                    lbsr      L010F
                    ldu       $04,s
                    ldd       $06,u
                    anda      #$80
                    clrb
                    std       -$02,s
                    beq       L77E4
                    ldd       $06,u
                    anda      #$7f
                    std       $06,u
                    pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
                    ldd       #$0093
                    std       $06,u
                    clra
                    clrb
                    std       $08,u
L77E4               puls      pc,u
L77E6               pshs      u
                    ldd       #$FFB0
                    lbsr      L010F
                    leas      -$04,s
                    ldx       $08,s
                    ldd       $0C,x
                    std       ,s
                    ldx       $08,s
                    ldu       $0a,x
                    ldd       $06,u
                    pshs      d
                    lbsr      L8132
                    std       ,s++
                    lbeq      L787C
                    ldd       ,s
                    pshs      d
                    lbsr      L771D
                    std       ,s++
                    beq       L781B
                    ldd       ,s
                    pshs      d
                    lbsr      L7E9C
                    bra       L7822

L781B               ldd       ,s
                    pshs      d
                    lbsr      L6F83
L7822               leas      $02,s
                    ldx       ,s
                    ldx       $06,x
                    bra       L7870

L782A               ldx       ,s
                    ldd       $0a,x
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       $06,u
                    pshs      d
                    ldd       #$007F
                    bra       L7866

L783E               ldd       ,s
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
L7856               ldd       ,s
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       $06,u
                    pshs      d
                    ldd       #$0075
L7866               pshs      d
                    lbsr      L4623
                    leas      $08,s
                    lbra      L7A13

L7870               cmpx      #$0041
                    beq       L782A
                    cmpx      #$0085
                    beq       L783E
                    bra       L7856

L787C               pshs      u
                    lbsr      L76BF
                    std       ,s++
                    beq       L78B4
                    ldd       ,u
                    cmpd      #$0002
                    beq       L78B4
                    ldd       ,s
                    pshs      d
                    lbsr      L771D
                    std       ,s++
                    bne       L78A3
                    ldd       ,s
                    pshs      d
                    lbsr      L7771
                    std       ,s++
                    beq       L78B4
L78A3               pshs      u
                    lbsr      L6F83
                    leas      $02,s
                    ldd       ,s
                    pshs      d
                    lbsr      L7E63
                    lbra      L792A

L78B4               ldx       ,s
                    ldd       $06,x
                    pshs      d
                    lbsr      L8132
                    std       ,s++
                    beq       L78DB
                    pshs      u
                    lbsr      L6F83
                    leas      $02,s
                    ldd       ,u
                    cmpd      #$0002
                    lbne      L792C
                    ldd       ,s
                    pshs      d
                    lbsr      L6E42
                    bra       L792A

L78DB               pshs      u
                    lbsr      L7759
                    std       ,s++
                    beq       L78F4
                    ldd       ,s
                    pshs      d
                    lbsr      L6E42
                    leas      $02,s
                    pshs      u
                    lbsr      L6F83
                    bra       L792A

L78F4               pshs      u
                    lbsr      L6F83
                    leas      $02,s
                    ldd       ,s
                    pshs      d
                    lbsr      L76BF
                    std       ,s++
                    bne       L7923
                    ldd       $06,u
                    anda      #$7f
                    tfr       d,x
                    bra       L7917

L790E               pshs      u
                    lbsr      L7B83
                    leas      $02,s
                    bra       L7923

L7917               cmpx      #$0095
                    beq       L7923
                    cmpx      #$0094
                    beq       L7923
                    bra       L790E

L7923               ldd       ,s
                    pshs      d
                    lbsr      L6EAC
L792A               leas      $02,s
L792C               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldx       $04,s
                    ldd       $06,x
                    pshs      d
                    ldd       #$0079
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
                    ldx       ,s
                    ldd       $06,x
                    lbra      L7A15

L794A               pshs      u
                    ldd       #$FFB0
                    lbsr      L010F
                    leas      -$04,s
                    ldx       $08,s
                    ldd       $0C,x
                    std       $02,s
                    ldx       $08,s
                    ldu       $0a,x
                    pshs      u
                    lbsr      L6F83
                    leas      $02,s
                    ldd       $0a,s
                    addd      #$FFB0
                    std       $0a,s
                    ldd       ,u
L796E               cmpd      #$0007
                    bne       L7998
                    ldx       $0a,s
                    bra       L7989

L7978               ldd       #$004E
                    bra       L7985

L797D               ldd       #$004D
                    bra       L7985

L7982               ldd       #$004C
L7985               std       $0a,s
                    bra       L7998

L7989               cmpx      #$0053
                    beq       L7978
                    cmpx      #$0055
                    beq       L797D
                    cmpx      #$0054
                    beq       L7982
L7998               ldd       $06,u
                    anda      #$7f
                    std       ,s
                    pshs      d
                    lbsr      L8132
                    std       ,s++
                    lbeq      L7A6E
                    ldx       $0a,s
                    lbra      L7A49

L79AE               ldx       $02,s
                    ldd       $06,x
                    cmpd      #$0036
                    bne       L79E5
                    ldd       $0a,s
                    cmpd      #$0050
                    bne       L79C6
                    ldx       $02,s
                    ldd       $08,x
                    bra       L79CE

L79C6               ldx       $02,s
                    ldd       $08,x
                    nega
                    negb
                    sbca      #$00
L79CE               pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    ldd       #$0074
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
                    bra       L7A13

L79E5               ldd       $02,s
                    pshs      d
                    lbsr      L6E42
                    leas      $02,s
                    ldd       $0a,s
                    cmpd      #$0051
                    bne       L7A00
                    ldd       #$0043
                    pshs      d
                    lbsr      L4623
                    leas      $02,s
L7A00               ldd       #$0070
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    ldd       #$0074
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
L7A13               ldd       $06,u
L7A15               ldx       $08,s
                    std       $06,x
                    clra
                    clrb
                    ldx       $08,s
                    std       $08,x
                    lbra      L7D15

L7A22               leax      $04,s
                    bra       L7A6C

L7A26               ldd       $06,u
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
                    ldd       $02,s
                    pshs      d
                    lbsr      L6E42
                    leas      $02,s
                    ldd       $0a,s
                    pshs      d
                    lbsr      L4623
                    leas      $02,s
                    lbra      L7B63

L7A49               cmpx      #$0050
                    lbeq      L79AE
                    cmpx      #$0051
                    lbeq      L79AE
                    cmpx      #$0057
                    beq       L7A22
                    cmpx      #$0058
                    lbeq      L7A22
                    cmpx      #$0059
                    lbeq      L7A22
                    bra       L7A26

L7A6C               leas      -$04,x
L7A6E               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
                    ldd       ,u
                    cmpd      #$0002
                    bne       L7A96
                    ldd       #$0085
                    pshs      d
                    lbsr      L4623
                    leas      $02,s
L7A96               ldx       $0a,s
                    lbra      L7B3D

L7A9B               ldd       $02,s
                    pshs      d
                    lbsr      L76BF
                    std       ,s++
                    beq       L7AEC
                    ldd       $02,s
                    pshs      d
                    lbsr      L6F83
                    leas      $02,s
                    ldx       $0a,s
                    bra       L7ABE

L7AB3               ldd       $02,s
                    pshs      d
                    lbsr      L77AC
                    leas      $02,s
                    bra       L7AD1

L7ABE               cmpx      #$0057
                    beq       L7AB3
                    cmpx      #$0058
                    lbeq      L7AB3
                    cmpx      #$0059
                    lbeq      L7AB3
L7AD1               ldd       $02,s
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
                    lbra      L7B63

L7AEC               ldd       ,s
                    cmpd      #$0094
                    beq       L7B03
                    ldd       ,s
                    cmpd      #$0095
                    beq       L7B03
                    pshs      u
                    lbsr      L7B83
                    leas      $02,s
L7B03               ldd       #$0070
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
                    ldd       $02,s
                    pshs      d
                    lbsr      L6E42
                    leas      $02,s
                    ldd       $0a,s
                    cmpd      #$0051
                    bne       L7B28
                    ldd       #$004F
                    std       $0a,s
L7B28               ldd       #$006E
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
                    bra       L7B63

L7B3D               cmpx      #$0057
                    lbeq      L7A9B
                    cmpx      #$0058
                    lbeq      L7A9B
                    cmpx      #$0059
                    lbeq      L7A9B
                    cmpx      #$0050
                    lbeq      L7A9B
                    cmpx      #$0051
                    lbeq      L7A9B
                    lbra      L7AEC

L7B63               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0079
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
                    ldd       #$0070
                    ldx       $08,s
                    std       $06,x
                    lbra      L7D15

L7B83               pshs      u
                    ldd       #$FFB4
                    lbsr      L010F
                    ldu       $04,s
                    ldd       $06,u
                    anda      #$7f
                    cmpd      #$0034
                    bne       L7B99
                    puls      pc,u
L7B99               pshs      u
                    lbsr      L77AC
                    leas      $02,s
                    ldd       $08,u
                    beq       L7BBC
                    ldd       $08,u
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$0074
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
L7BBC               ldd       #$0071
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
                    ldd       #$806E
                    std       $06,u
                    puls      pc,u
L7BD2               pshs      u
                    ldd       #$FFB0
                    lbsr      L010F
                    ldu       $04,s
                    leas      -$04,s
                    ldd       $0a,u
                    std       $02,s
                    pshs      d
                    lbsr      L7E9C
                    leas      $02,s
                    ldx       $02,s
                    ldd       $06,x
                    std       ,s
                    anda      #$80
                    clrb
                    std       -$02,s
                    lbeq      L7C56
                    ldd       ,s
                    anda      #$7f
                    std       ,s
                    tfr       d,x
                    bra       L7C2E

L7C02               ldx       $02,s
                    ldd       $08,x
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
                    bra       L7C4A

L7C1D               leax      L816E,pcr
                    pshs      x
                    ldd       $04,s
                    pshs      d
                    lbsr      L0464
                    leas      $04,s
                    bra       L7C4A

L7C2E               cmpx      #$0034
                    beq       L7C02
                    cmpx      #$0093
                    lbeq      L7C02
                    cmpx      #$0094
                    lbeq      L7C02
                    cmpx      #$0095
                    lbeq      L7C02
                    bra       L7C1D

L7C4A               ldd       #$8093
                    std       ,s
                    clra
                    clrb
                    std       $08,u
                    lbra      L7D11

L7C56               ldx       ,s
                    lbra      L7CD2

L7C5B               ldd       #$0095
                    bra       L7C6E

L7C60               ldd       #$0094
                    bra       L7C6E

L7C65               ldd       #$0093
                    bra       L7C6E

L7C6A               ldd       ,s
                    ora       #$80
L7C6E               std       ,s
                    leax      $04,s
                    bra       L7C83

L7C74               ldd       #$8034
                    std       ,s
                    ldx       $02,s
                    ldd       $14,x
                    std       $14,u
                    bra       L7C85

L7C83               leas      -$04,x
L7C85               ldx       $02,s
                    ldd       $08,x
                    bra       L7CAA

L7C8B               ldd       $02,s
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
                    ldd       #$0093
                    std       ,s
                    clra
                    clrb
L7CAA               std       $08,u
                    bra       L7D11

L7CAE               clra
                    clrb
                    std       $08,u
                    ldx       $02,s
                    ldd       $08,x
                    std       $14,u
                    ldd       #$0034
                    bra       L7CCE

L7CBE               leax      L817A,pcr
                    pshs      x
                    pshs      u
                    lbsr      L0464
                    leas      $04,s
                    ldd       #$0093
L7CCE               std       ,s
                    bra       L7D11

L7CD2               cmpx      #$006F
                    lbeq      L7C5B
                    cmpx      #$0076
                    lbeq      L7C60
                    cmpx      #$0071
                    lbeq      L7C65
                    cmpx      #$0093
                    lbeq      L7C6A
                    cmpx      #$0094
                    lbeq      L7C6A
                    cmpx      #$0095
                    lbeq      L7C6A
                    cmpx      #$0034
                    lbeq      L7C74
                    cmpx      #$0070
                    lbeq      L7C8B
                    cmpx      #$0036
                    beq       L7CAE
                    bra       L7CBE

L7D11               ldd       ,s
                    std       $06,u
L7D15               leas      $04,s
                    puls      pc,u
L7D19               pshs      u
                    ldd       #$FFAC
                    lbsr      L010F
                    leas      -$08,s
                    ldx       $0C,s
                    ldu       $0a,x
                    pshs      u
                    lbsr      L6F83
                    leas      $02,s
                    ldx       $0C,s
                    ldd       $06,x
                    std       $02,s
                    ldd       $06,u
                    std       ,s
                    pshs      d
                    lbsr      L8132
                    std       ,s++
                    beq       L7D79
                    ldx       $02,s
                    bra       L7D6B

L7D45               ldd       $0e,s
                    cmpd      #$0070
                    bne       L7D65
                    pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       $12,s
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
                    bra       L7DAA

L7D65               ldd       ,s
                    std       $0e,s
                    bra       L7DAA

L7D6B               cmpx      #$003E
                    beq       L7D45
                    cmpx      #$003F
                    lbeq      L7D45
                    bra       L7D65

L7D79               ldd       $0e,s
                    cmpd      #$0071
                    bne       L7D90
                    ldd       ,s
                    anda      #$7f
                    cmpd      #$0034
                    beq       L7D90
                    ldd       #$0070
                    std       $0e,s
L7D90               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       $12,s
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
                    ldd       $0e,s
                    std       ,s
L7DAA               ldx       $0C,s
                    ldd       $08,x
                    std       $06,s
                    ldx       $02,s
                    bra       L7DEF

L7DB4               ldd       $06,s
                    nega
                    negb
                    sbca      #$00
                    std       $06,s
L7DBC               ldd       ,s
                    cmpd      #$0070
                    bne       L7DD6
                    ldd       $06,s
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    ldd       #$0050
                    bra       L7DE6

L7DD6               ldd       $06,s
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    ldd       #$0074
L7DE6               pshs      d
                    lbsr      L4623
                    leas      $08,s
                    bra       L7DFD

L7DEF               cmpx      #$003D
                    beq       L7DB4
                    cmpx      #$003F
                    lbeq      L7DB4
                    bra       L7DBC

L7DFD               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    ldd       #$0079
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
                    ldx       $02,s
                    bra       L7E48

L7E16               clra
                    clrb
                    bra       L7E42

L7E1A               ldd       ,s
                    cmpd      #$0070
                    bne       L7E3C
                    ldd       $06,s
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0051
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
                    bra       L7E56

L7E3C               ldd       $06,s
                    nega
                    negb
                    sbca      #$00
L7E42               ldx       $0C,s
                    std       $08,x
                    bra       L7E56

L7E48               cmpx      #$003E
                    beq       L7E1A
                    cmpx      #$003F
                    lbeq      L7E1A
                    bra       L7E16

L7E56               ldd       $0e,s
                    ldx       $0C,s
                    std       $06,x
                    clra
                    clrb
                    std       $0066
                    lbra      L812E

L7E63               pshs      u
                    ldd       #$FFB4
                    lbsr      L010F
                    ldu       $04,s
                    pshs      u
                    bsr       L7E9C
                    leas      $02,s
                    ldd       $06,u
                    cmpd      #$0071
                    bne       L7E7F
                    ldd       $08,u
                    beq       L7E95
L7E7F               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
L7E95               ldd       #$0071
                    std       $06,u
                    puls      pc,u
L7E9C               pshs      u
                    ldd       #$FFAC
                    lbsr      L010F
                    leas      -$08,s
                    ldx       $0C,s
                    ldu       $0a,x
                    ldx       $0C,s
                    ldd       $0C,x
                    std       $06,s
                    ldd       #$0071
                    std       ,s
                    ldx       $0C,s
                    ldd       $06,x
                    std       $02,s
                    tfr       d,x
                    lbra      L80CE

L7EC0               ldd       $0C,s
                    pshs      d
                    lbsr      L7BD2
                    lbra      L80CA

L7ECA               ldd       #$0071
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    lbsr      L7D19
                    leas      $04,s
                    lbra      L812E

L7EDB               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$007F
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
                    clra
                    clrb
                    lbra      L80BB

L7EF6               ldd       $0C,s
                    pshs      d
                    lbsr      L6E42
                    lbra      L80CA

L7F00               ldd       $06,u
                    cmpd      #$0041
                    beq       L7F11
                    ldx       $06,s
                    ldd       $12,x
                    lbne      L7FAF
L7F11               ldd       $06,u
                    pshs      d
                    lbsr      L8132
                    std       ,s++
                    bne       L7F24
                    ldd       $06,u
                    cmpd      #$0041
                    bne       L7F78
L7F24               ldx       $06,s
                    ldd       $06,x
                    cmpd      #$0036
                    bne       L7F40
                    pshs      u
                    lbsr      L7E9C
                    leas      $02,s
                    ldd       $06,u
                    std       ,s
                    ldx       $06,s
                    ldd       $08,x
                    lbra      L80A5

L7F40               ldd       $06,s
                    pshs      d
                    lbsr      L6E42
                    leas      $02,s
                    pshs      u
                    lbsr      L7E9C
                    leas      $02,s
                    ldd       $02,s
                    cmpd      #$0051
                    bne       L7F62
                    ldd       #$0043
                    pshs      d
                    lbsr      L4623
                    leas      $02,s
L7F62               ldd       $06,u
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$007B
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
                    lbra      L80A3

L7F78               ldd       $02,s
                    cmpd      #$0050
                    bne       L7F97
                    ldd       $12,u
                    ldx       $06,s
                    cmpd      $12,x
                    bge       L7F97
                    leas      -$02,s
                    stu       ,s
                    ldu       $08,s
                    ldd       ,s
                    std       $08,s
                    leas      $02,s
L7F97               ldd       $06,s
                    pshs      d
                    lbsr      L76BF
                    std       ,s++
                    bne       L7FB4
                    ldx       $06,s
                    ldd       $06,x
                    pshs      d
                    lbsr      L8132
                    std       ,s++
                    bne       L7FB4
L7FAF               leax      $08,s
                    lbra      L80C1

L7FB4               pshs      u
                    lbsr      L7E9C
                    leas      $02,s
                    ldd       $06,u
                    anda      #$7f
                    tfr       d,x
                    lbra      L8019

L7FC4               ldd       $02,s
                    cmpd      #$0050
                    bne       L7FE8
                    ldx       $06,s
                    ldd       $06,x
                    cmpd      #$0036
                    beq       L7FE8
                    ldd       $06,s
                    pshs      d
                    lbsr      L6E76
                    leas      $02,s
                    clra
                    clrb
                    std       $08,u
                    leax      $08,s
                    lbra      L8089

L7FE8               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
                    clra
                    clrb
L8000               std       $08,u
L8002               bra       L8054

L8004               ldd       $06,u
                    std       ,s
                    bra       L8054

L800A               leax      L8186,pcr
                    pshs      x
                    pshs      u
                    lbsr      L0464
                    leas      $04,s
                    bra       L8054

L8019               cmpx      #$0070
                    lbeq      L7FC4
                    cmpx      #$0034
                    beq       L7FE8
                    cmpx      #$0037
                    lbeq      L7FE8
                    cmpx      #$0093
                    lbeq      L7FE8
                    cmpx      #$0094
                    lbeq      L7FE8
                    cmpx      #$0095
                    lbeq      L7FE8
                    cmpx      #$0071
                    beq       L8054
                    cmpx      #$0076
                    beq       L8004
                    cmpx      #$006F
                    lbeq      L8004
                    bra       L800A

L8054               ldx       $06,s
                    ldd       $06,x
                    cmpd      #$0036
                    bne       L8064
                    ldx       $06,s
                    ldd       $08,x
                    bra       L80A5

L8064               ldd       $06,s
                    pshs      d
                    lbsr      L6E42
                    leas      $02,s
                    ldd       $02,s
                    cmpd      #$0051
                    bne       L808B
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    ldd       #$0043
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
                    bra       L808B

L8089               leas      -$08,x
L808B               ldd       ,s
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$007B
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
                    ldd       #$0071
                    std       ,s
L80A3               clra
                    clrb
L80A5               std       $04,s
                    ldd       $02,s
                    cmpd      #$0050
                    bne       L80B3
                    ldd       $04,s
                    bra       L80B9

L80B3               ldd       $04,s
                    nega
                    negb
                    sbca      #$00
L80B9               addd      $08,u
L80BB               ldx       $0C,s
                    std       $08,x
                    bra       L8128

L80C1               leas      -$08,x
L80C3               ldd       $0C,s
                    pshs      d
                    lbsr      L6F83
L80CA               leas      $02,s
                    bra       L812E

L80CE               cmpx      #$0042
                    lbeq      L7EC0
                    cmpx      #$0034
                    beq       L812E
                    cmpx      #$0076
                    beq       L812E
                    cmpx      #$006F
                    beq       L812E
                    cmpx      #$0036
                    beq       L812E
                    cmpx      #$0037
                    beq       L812E
                    cmpx      #$003E
                    lbeq      L7ECA
                    cmpx      #$003C
                    lbeq      L7ECA
                    cmpx      #$003D
                    lbeq      L7ECA
                    cmpx      #$003F
                    lbeq      L7ECA
                    cmpx      #$0041
                    lbeq      L7EDB
                    cmpx      #$0085
                    lbeq      L7EF6
                    cmpx      #$0051
                    lbeq      L7F00
                    cmpx      #$0050
                    lbeq      L7F11
                    bra       L80C3

L8128               ldd       ,s
                    ldx       $0C,s
                    std       $06,x
L812E               leas      $08,s
                    puls      pc,u
L8132               pshs      u
                    ldd       #$FFC0
                    lbsr      L010F
                    ldd       $04,s
                    cmpd      #$006F
                    beq       L814A
                    ldd       $04,s
                    cmpd      #$0076
                    bne       L814F
L814A               ldd       #$0001
                    bra       L8151

L814F               clra
                    clrb
L8151               puls      pc,u
L8153               lsr       L7261
                    jmp       -$0d,s
                    inc       $01,s
                    lsr       $696F
                    jmp       0,x

L815F               bcs       $81D9
                    tst       $0000
L8163               fcb       $62
                    rol       $0e,s
                    fcb       $61
                    fcb       $72
                    rol       $206F
                    neg       L2E00
L816E               rol       $0e,s
                    lsr       $09,s
                    fcb       $72
                    fcb       $65
                    com       -$0C,s
                    rol       $0f,s
                    jmp       0,x

L817A               rol       $0e,s
                    lsr       $09,s
                    fcb       $72
                    fcb       $65
                    com       -$0C,s
                    rol       $0f,s
                    jmp       0,x

L8186               asl       L2074
                    fcb       $72
                    fcb       $61
                    jmp       -$0d,s
                    inc       $01,s
                    lsr       L6500
L8192               pshs      u
                    ldd       #$FFA2
                    lbsr      L010F
                    leas      -$14,s
                    bra       L81AD

L819F               leax      L925F,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
                    lbsr      $5F26
L81AD               ldd       $003F
                    cmpd      #$002A
                    beq       L819F
                    ldd       $003F
                    cmpd      #$0029
                    bne       L81E2
                    leax      L9271,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    lbsr      L89B7
                    leas      $02,s
                    leax      >$0029,y
                    pshs      x
                    lbsr      L916F
                    leas      $02,s
                    lbsr      $5F26
                    lbra      L843C

L81E2               lbsr      L8B51
                    std       $0a,s
                    tfr       d,x
                    bra       L81FD

L81EB               leax      L9289,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
L81F6               ldd       #$000C
                    std       $0a,s
                    bra       L820D

L81FD               cmpx      #$0010
                    beq       L81EB
                    cmpx      #$000D
                    lbeq      L81EB
                    stx       -$02,s
                    beq       L81F6
L820D               leax      ,s
                    pshs      x
                    leax      $06,s
                    pshs      x
                    leax      $16,s
                    pshs      x
                    lbsr      L8BA0
                    leas      $06,s
                    std       $08,s
                    bne       L8228
                    ldd       #$0001
                    std       $08,s
L8228               ldd       $04,s
                    std       $0C,s
                    ldd       $08,s
                    pshs      d
                    leax      $0e,s
                    pshs      x
                    leax      $06,s
                    pshs      x
                    lbsr      L8EF5
                    leas      $06,s
                    std       $06,s
                    ldu       $02,s
                    bne       L825C
                    ldd       $06,s
                    cmpd      #$0004
                    beq       L8256
                    ldd       $06,s
                    cmpd      #$0003
                    beq       L8256
                    lbsr      L924A
L8256               leax      $14,s
                    lbra      L841C

L825C               ldd       $06,s
                    clra
                    andb      #$30
                    cmpd      #$0030
                    bne       L8281
                    ldd       $003F
                    cmpd      #$0030
                    beq       L8277
                    ldd       $003F
                    cmpd      #$0028
                    bne       L827C
L8277               ldd       #$000E
                    bra       L8283

L827C               ldd       #$000C
                    bra       L8283

L8281               ldd       $0a,s
L8283               std       $0e,s
                    ldd       ,u
                    beq       L82CF
                    ldd       ,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    pshs      u
                    lbsr      L87E6
                    leas      $06,s
                    std       -$02,s
                    lbne      L83A3
                    ldd       $0e,s
                    cmpd      #$000E
                    lbeq      L83A3
                    ldd       $08,u
                    cmpd      #$000E
                    beq       L82BE
                    ldd       $08,u
                    cmpd      #$0022
                    beq       L82BE
                    lbsr      L0443
                    lbra      L83A3

L82BE               ldd       $0e,s
                    std       $08,u
                    ldd       $0C,s
                    std       $04,u
                    ldd       ,s
                    std       $0a,u
                    leax      $14,s
                    bra       L82E1

L82CF               ldd       $06,s
                    std       ,u
                    clra
                    clrb
                    std       $0C,u
                    ldd       $0e,s
                    std       $08,u
                    ldd       ,s
                    std       $0a,u
                    bra       L82E4

L82E1               leas      -$14,x
L82E4               ldd       $12,s
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    pshs      u
                    lbsr      L906B
                    leas      $06,s
                    std       $10,s
                    ldd       $06,s
                    clra
                    andb      #$30
                    cmpd      #$0030
                    lbeq      L83A3
                    ldd       $003F
                    cmpd      #$0078
                    bne       L831F
                    ldd       $06,s
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    pshs      u
                    lbsr      L3CB7
L831A               leas      $06,s
                    lbra      L8389

L831F               ldd       $10,s
                    bne       L8332
                    ldd       $0e,s
                    cmpd      #$000E
                    beq       L8332
                    lbsr      L923C
                    lbra      L8389

L8332               ldx       $0e,s
                    bra       L8371

L8336               ldd       $0e,s
                    cmpd      #$0023
                    bne       L8343
                    ldd       #$0001
                    bra       L8345

L8343               clra
                    clrb
L8345               pshs      d
                    ldd       $12,s
                    pshs      d
                    pshs      u
                    lbsr      L5C13
                    bra       L831A

L8353               ldd       $0e,s
                    cmpd      #$0021
                    bne       L8360
                    ldd       #$0001
                    bra       L8362

L8360               clra
                    clrb
L8362               pshs      d
                    ldd       $12,s
                    pshs      d
                    pshs      u
                    lbsr      L5C03
                    lbra      L831A

L8371               cmpx      #$0023
                    beq       L8336
                    cmpx      #$000F
                    lbeq      L8336
                    cmpx      #$0021
                    beq       L8353
                    cmpx      #$000C
                    lbeq      L8353
L8389               ldd       $0e,s
                    cmpd      #$000F
                    bne       L8396
                    ldd       #$000C
                    bra       L83A1

L8396               ldd       $0e,s
                    cmpd      #$0023
                    bne       L83A3
                    ldd       #$0021
L83A1               std       $08,u
L83A3               ldd       $06,s
                    clra
                    andb      #$30
                    cmpd      #$0030
                    lbne      L841F
                    ldd       $06,s
                    pshs      d
                    lbsr      L067C
                    leas      $02,s
                    std       $06,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    beq       L83DF
                    ldd       $06,s
                    clra
                    andb      #$30
                    cmpd      #$0030
                    beq       L83DF
                    ldd       $06,s
                    cmpd      #$0004
                    beq       L83DF
                    ldd       $06,s
                    cmpd      #$0003
                    bne       L83F4
L83DF               leax      $9297,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
                    ldd       #$0031
                    std       ,u
                    ldd       #$0001
                    std       $06,s
L83F4               ldd       $0e,s
                    cmpd      #$000E
                    bne       L8409
                    leax      >$0027,y
                    pshs      x
                    lbsr      L916F
                    leas      $02,s
                    bra       L841F

L8409               ldd       $06,s
                    std       $002D
                    ldd       $0a,s
                    pshs      d
                    pshs      u
                    lbsr      L886F
                    leas      $04,s
                    bra       L843C
                    bra       L841F

L841C               leas      -$14,x
L841F               ldd       $003F
                    cmpd      #$0030
                    bne       L842D
                    lbsr      $5F26
                    lbra      L8228

L842D               ldd       #$0028
                    pshs      d
                    lbsr      L06C1
                    std       ,s++
                    beq       L843C
                    lbsr      L0704
L843C               leas      $14,s
                    puls      pc,u
L8441               pshs      u
                    ldd       #$FFA4
                    lbsr      L010F
                    leas      -$12,s
                    lbsr      L8B51
                    std       $10,s
                    tfr       d,x
                    bra       L8469

L8456               leax      $92AB,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
L8461               ldd       #$000D
                    std       $10,s
                    bra       L8474

L8469               stx       -$02,s
                    beq       L8461
                    cmpx      #$0010
                    beq       L8474
                    bra       L8456

L8474               leax      ,s
                    pshs      x
                    leax      $0C,s
                    pshs      x
                    leax      $0C,s
                    pshs      x
                    lbsr      L8BA0
                    leas      $06,s
                    std       $0e,s
                    bne       L848E
                    ldd       #$0001
                    std       $0e,s
L848E               ldd       $0a,s
                    std       $0C,s
                    ldd       $0e,s
                    pshs      d
                    leax      $0e,s
                    pshs      x
                    leax      $06,s
                    pshs      x
                    lbsr      L8EF5
                    leas      $06,s
                    std       $04,s
                    ldu       $02,s
                    ldd       $04,s
                    clra
                    andb      #$30
                    cmpd      #$0030
                    beq       L84C2
                    ldd       $04,s
                    cmpd      #$0004
                    beq       L84C2
                    ldd       $04,s
                    cmpd      #$000A
                    bne       L84CF
L84C2               leax      $92BC,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
                    bra       L8500

L84CF               ldd       $04,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    bne       L84EA
                    ldd       $04,s
                    pshs      d
                    lbsr      L067C
                    std       ,s
                    lbsr      L0688
                    leas      $02,s
                    bra       L84F5

L84EA               ldd       $04,s
                    cmpd      #$0005
                    bne       L84F7
                    ldd       #$0006
L84F5               std       $04,s
L84F7               cmpu      #$0000
                    bne       L8506
                    lbsr      L924A
L8500               leax      $12,s
                    lbra      L8563

L8506               ldd       $04,s
                    pshs      d
                    ldd       $12,s
                    pshs      d
                    lbsr      L881A
                    leas      $04,s
                    std       $06,s
                    ldx       $08,u
                    bra       L8550

L851A               ldd       $04,s
                    std       ,u
                    ldd       $06,s
                    std       $08,u
                    ldd       ,s
                    std       $0a,u
                    ldd       $08,s
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    pshs      u
                    lbsr      L906B
                    leas      $06,s
                    std       -$02,s
                    bne       L8566
                    lbsr      L923C
                    bra       L8566

L853E               lbsr      L0443
                    bra       L8566

L8543               leax      $92CB,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
                    bra       L8566

L8550               cmpx      #$000B
                    beq       L851A
                    cmpx      #$000D
                    beq       L853E
                    cmpx      #$0010
                    lbeq      L853E
                    bra       L8543

L8563               leas      -$12,x
L8566               ldd       $003F
                    cmpd      #$0078
                    bne       L8571
                    lbsr      L4203
L8571               ldd       $003F
                    cmpd      #$0030
                    bne       L857F
                    lbsr      $5F26
                    lbra      L848E

L857F               ldd       #$0028
                    pshs      d
                    lbsr      L06C1
                    std       ,s++
                    lbeq      L87E1
                    lbsr      L0704
                    lbra      L87E1

L8593               pshs      u
                    ldd       #$FF9E
                    lbsr      L010F
                    leas      -$12,s
                    lbsr      L8B51
                    std       $10,s
                    tfr       d,x
                    bra       L85BB

L85A8               leax      $92DB,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
L85B3               ldd       #$000D
                    std       $10,s
                    bra       L85C4

L85BB               cmpx      #$0021
                    beq       L85A8
                    stx       -$02,s
                    beq       L85B3
L85C4               leax      $02,s
                    pshs      x
                    leax      $0C,s
                    pshs      x
                    leax      $0C,s
                    pshs      x
                    lbsr      L8BA0
                    leas      $06,s
                    std       $0e,s
                    bne       L85DE
                    ldd       #$0001
                    std       $0e,s
L85DE               leas      -$06,s
                    ldd       $10,s
                    std       ,s
                    ldd       $14,s
                    pshs      d
                    leax      $02,s
                    pshs      x
                    leax      $0e,s
                    pshs      x
                    lbsr      L8EF5
                    leas      $06,s
                    std       $12,s
                    ldu       $0a,s
                    bne       L861A
                    ldd       $12,s
                    cmpd      #$0004
                    lbeq      L8685
                    ldd       $12,s
                    cmpd      #$0003
                    lbeq      L8685
                    lbsr      L924A
                    lbra      L8685

L861A               ldd       $12,s
                    clra
                    andb      #$30
                    cmpd      #$0030
                    beq       L862F
                    ldd       $16,s
                    cmpd      #$000E
                    bne       L8666
L862F               ldd       ,u
                    bne       L8654
                    ldd       $12,s
                    std       ,u
                    ldd       #$000E
                    std       $08,u
                    clra
                    clrb
                    std       $0C,u
                    ldd       $08,s
                    std       $0a,u
                    ldd       $0e,s
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    pshs      u
                    lbsr      L906B
                    bra       L8662

L8654               ldd       $08,s
                    pshs      d
                    ldd       $14,s
                    pshs      d
                    pshs      u
                    lbsr      L87E6
L8662               leas      $06,s
                    bra       L8685

L8666               ldd       $12,s
                    pshs      d
                    ldd       $18,s
                    pshs      d
                    lbsr      L881A
                    leas      $04,s
                    std       $04,s
                    ldd       ,u
                    beq       L8692
                    ldd       $0C,u
                    cmpd      $0031
                    bne       L868B
                    lbsr      L0443
L8685               leax      $18,s
                    lbra      L87C0

L868B               pshs      u
                    lbsr      L0382
                    leas      $02,s
L8692               ldd       $12,s
                    std       ,u
                    ldd       $04,s
                    std       $08,u
                    ldd       $08,s
                    std       $0a,u
                    ldd       $0031
                    std       $0C,u
                    ldd       $002B
                    std       $10,u
                    stu       $002B
                    ldd       $0e,s
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    pshs      u
                    lbsr      L906B
                    leas      $06,s
                    std       $02,s
                    bne       L86C8
                    ldd       $003F
                    cmpd      #$0078
                    beq       L86C8
                    lbsr      L923C
L86C8               ldx       $04,s
                    bra       L86E1

L86CC               ldd       $0011
                    subd      $02,s
                    std       $0011
                    ldd       $0011
                    bra       L86DD

L86D6               ldd       $000B
                    addd      #$0001
                    std       $000B
L86DD               std       $06,u
                    bra       L86F2

L86E1               cmpx      #$000D
                    beq       L86CC
                    cmpx      #$0023
                    beq       L86D6
                    cmpx      #$000F
                    lbeq      L86D6
L86F2               ldd       $003F
                    cmpd      #$0078
                    lbne      L878F
                    ldd       $04,s
                    cmpd      #$000F
                    beq       L870C
                    ldd       $04,s
                    cmpd      #$0023
                    bne       L871F
L870C               ldd       $12,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    lbsr      L3CB7
L871A               leas      $06,s
                    lbra      L87C3

L871F               lbsr      $5F26
                    ldd       $12,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    lbeq      L878A
                    ldd       $12,s
                    cmpd      #$0004
                    lbeq      L878A
                    ldd       #$0002
                    pshs      d
                    lbsr      $0785
                    leas      $02,s
                    std       $0C,s
                    beq       L878A
                    ldd       $006E
                    beq       L875E
                    ldd       $006E
                    std       $06,s
                    tfr       d,x
                    ldd       ,x
                    std       $006E
                    clra
                    clrb
                    std       [$06,s]
                    bra       L876A

L875E               ldd       #$0006
                    pshs      d
                    lbsr      L6622
                    leas      $02,s
                    std       $06,s
L876A               ldd       $0C,s
                    ldx       $06,s
                    std       $02,x
                    ldx       $06,s
                    stu       $04,x
                    ldd       L006A
                    beq       L8780
                    ldd       $06,s
                    std       [L006C,y]
                    bra       L8784

L8780               ldd       $06,s
                    std       L006A
L8784               ldd       $06,s
                    std       L006C
                    bra       L87C3

L878A               lbsr      L4203
                    bra       L87C3

L878F               ldx       $04,s
                    bra       L87B2

L8793               ldd       $04,s
                    cmpd      #$0023
                    bne       L87A0
                    ldd       #$0001
                    bra       L87A2

L87A0               clra
                    clrb
L87A2               pshs      d
                    ldd       $04,s
                    pshs      d
                    ldd       $06,u
                    pshs      d
                    lbsr      L5BDC
                    lbra      L871A

L87B2               cmpx      #$000F
                    beq       L8793
                    cmpx      #$0023
                    lbeq      L8793
                    bra       L87C3

L87C0               leas      -$18,x
L87C3               ldd       $003F
                    cmpd      #$0030
                    beq       L87CF
                    leas      $06,s
                    bra       L87D7

L87CF               lbsr      $5F26
                    leas      $06,s
                    lbra      L85DE

L87D7               ldd       #$0028
                    pshs      d
                    lbsr      L06C1
                    leas      $02,s
L87E1               leas      $12,s
                    puls      pc,u
L87E6               pshs      u
                    ldd       #$FFBA
                    lbsr      L010F
                    ldu       $04,s
                    ldd       ,u
                    cmpd      $06,s
                    bne       L8806
                    ldd       $06,s
                    cmpd      #$0004
                    bne       L8816
                    ldd       $0a,u
                    cmpd      $08,s
                    beq       L8816
L8806               leax      $92E9,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
                    ldd       #$0001
                    puls      pc,u
L8816               clra
                    clrb
                    puls      pc,u
L881A               pshs      u
                    ldd       #$FFC0
                    lbsr      L010F
                    ldd       $04,s
                    cmpd      #$0010
                    bne       L886B
                    ldd       L0068
                    cmpd      #$0001
                    bge       L8866
                    ldx       $06,s
                    bra       L8858

L8836               ldd       $06,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L8866
L8841               ldd       L0068
                    addd      #$0001
                    std       L0068
                    cmpd      #$0001
                    bne       L8853
                    ldd       #$006F
                    bra       L8856

L8853               ldd       #$0076
L8856               puls      pc,u
L8858               cmpx      #$0001
                    beq       L8841
                    cmpx      #$0007
                    lbeq      L8841
                    bra       L8836

L8866               ldd       #$000D
                    puls      pc,u
L886B               ldd       $04,s
                    puls      pc,u
L886F               pshs      u
                    ldd       #$FFAC
                    lbsr      L010F
                    leas      -$0a,s
                    ldd       #$0001
                    std       $0031
                    clra
                    clrb
                    std       $000F
                    std       $001B
                    std       $0011
                    std       L0068
                    std       $0013
                    bra       L888F

L888C               lbsr      L8441
L888F               ldd       $003F
                    cmpd      #$0029
                    bne       L888C
                    ldd       $0e,s
                    addd      #$0014
                    std       $02,s
                    ldd       $0017
                    beq       L88B6
                    ldd       $000B
                    addd      #$0001
                    std       $000B
                    std       ,s
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    lbsr      L5C57
                    leas      $04,s
L88B6               ldd       ,s
                    pshs      d
                    ldd       $12,s
                    cmpd      #$000F
                    beq       L88C8
                    ldd       #$0001
                    bra       L88CA

L88C8               clra
                    clrb
L88CA               pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L5C6F
                    leas      $06,s
                    ldu       $0027
                    ldd       #$0004
                    std       $08,s
                    lbra      L8953

L88DF               leas      -$02,s
                    ldd       $0a,s
                    std       $06,u
                    ldx       ,u
                    bra       L8901

L88E9               ldd       #$0004
                    bra       L88FD

L88EE               ldd       #$0008
                    bra       L88FD

L88F3               ldd       $06,u
                    addd      #$0001
                    std       $06,u
L88FA               ldd       #$0002
L88FD               std       ,s
                    bra       L8919

L8901               cmpx      #$0008
                    beq       L88E9
                    cmpx      #$0005
                    lbeq      L88E9
                    cmpx      #$0006
                    beq       L88EE
                    cmpx      #$0002
                    beq       L88F3
                    bra       L88FA

L8919               ldd       $08,u
                    std       $08,s
                    tfr       d,x
                    bra       L8937

L8921               ldd       $0a,s
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
                    bra       L8948

L8930               ldd       #$000D
                    std       $08,u
                    bra       L8948

L8937               cmpx      #$006F
                    beq       L8921
                    cmpx      #$0076
                    lbeq      L8921
                    cmpx      #$000B
                    beq       L8930
L8948               ldd       $0a,s
                    addd      ,s
                    std       $0a,s
                    ldu       $10,u
                    leas      $02,s
L8953               stu       -$02,s
                    lbne      L88DF
                    ldd       $0027
                    std       $04,s
                    clra
                    clrb
                    std       $0027
                    lbsr      L89B7
                    leax      $04,s
                    pshs      x
                    lbsr      L916F
                    leas      $02,s
                    leax      >$0029,y
                    pshs      x
                    lbsr      L916F
                    leas      $02,s
                    ldd       $002F
                    cmpd      #$0012
                    beq       L8992
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    ldd       #$0012
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
L8992               clra
                    clrb
                    std       $002F
                    lbsr      L5D06
                    clra
                    clrb
                    std       $0031
                    ldd       $003F
                    cmpd      #$FFFF
                    bne       L89B0
                    leax      $92FE,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
L89B0               lbsr      $5F26
                    leas      $0a,s
                    puls      pc,u
L89B7               pshs      u
                    ldd       #$FFAA
                    lbsr      L010F
                    leas      -$06,s
                    ldd       $002B
                    std       $02,s
                    clra
                    clrb
                    std       $002B
                    lbsr      $5F26
                    ldd       $0031
                    addd      #$0001
                    std       $0031
                    ldd       $0011
                    std       ,s
                    bra       L89DC

L89D9               lbsr      L8593
L89DC               lbsr      L0641
                    std       -$02,s
                    bne       L89D9
                    lbsr      L05DF
                    std       -$02,s
                    lbne      L89D9
                    ldd       $001B
                    cmpd      $0011
                    ble       L89F7
                    ldd       $0011
                    std       $001B
L89F7               ldd       $0011
                    pshs      d
                    lbsr      L57E3
                    leas      $02,s
                    std       $000F
                    lbra      L8A75

L8A05               ldd       L006A
                    std       $04,s
                    ldx       $04,s
                    ldu       $02,x
                    ldd       $10,u
                    pshs      d
                    ldd       $0e,u
                    pshs      d
                    ldx       $08,s
                    ldd       $04,x
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    ldd       #$0034
                    pshs      d
                    lbsr      L0FD8
                    leas      $0C,s
                    tfr       d,u
                    ldd       $10,u
                    pshs      d
                    ldd       $0e,u
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    ldx       $0a,s
                    ldd       $02,x
                    pshs      d
                    pshs      u
                    ldd       #$0078
                    pshs      d
                    lbsr      L0FD8
                    leas      $0C,s
                    tfr       d,u
                    pshs      u
                    lbsr      L111D
                    std       ,s
                    lbsr      L6F83
                    std       ,s
                    lbsr      L0598
                    leas      $02,s
                    ldd       [$04,s]
                    std       $04,s
                    ldd       $006E
                    std       [L006A,y]
                    ldd       L006A
                    std       $006E
                    ldd       $04,s
                    std       L006A
L8A75               ldd       L006A
                    lbne      L8A05
                    bra       L8A80

L8A7D               lbsr      L29D5
L8A80               ldd       $003F
                    cmpd      #$002A
                    beq       L8A90
                    ldd       $003F
                    cmpd      #$FFFF
                    bne       L8A7D
L8A90               leax      >$002b,y
                    pshs      x
                    lbsr      L916F
                    leas      $02,s
                    ldd       $02,s
                    std       $002B
                    ldd       $0031
                    addd      #$FFFF
                    std       $0031
                    ldd       ,s
                    std       $0011
                    ldd       $002F
                    cmpd      #$0012
                    beq       L8ABD
                    ldd       ,s
                    pshs      d
                    lbsr      L57E3
                    leas      $02,s
                    bra       L8ABF

L8ABD               ldd       ,s
L8ABF               std       $000F
                    leas      $06,s
                    puls      pc,u
L8AC5               pshs      u
                    ldd       #$FFB8
                    lbsr      L010F
                    leas      -$02,s
                    clra
                    clrb
                    std       [$06,s]
L8AD4               lbsr      $5F26
L8AD7               ldd       $003F
                    cmpd      #$002E
                    lbeq      L8B45
                    ldd       $003F
                    cmpd      #$0034
                    bne       L8B38
                    ldu       $0041
                    ldd       $08,u
                    cmpd      #$000B
                    bne       L8AFE
                    leax      L9312,pcr
                    pshs      x
                    lbsr      L0450
                    bra       L8B07

L8AFE               ldd       ,u
                    beq       L8B09
                    pshs      u
                    lbsr      L0382
L8B07               leas      $02,s
L8B09               ldd       #$0001
                    std       ,u
                    ldd       #$000B
                    std       $08,u
                    ldd       #$0001
                    std       $0C,u
                    ldd       #$0002
                    std       $02,u
                    ldd       [$06,s]
                    beq       L8B29
                    ldx       ,s
                    stu       $10,x
                    bra       L8B2C

L8B29               stu       [$06,s]
L8B2C               clra
                    clrb
                    std       $10,u
                    stu       ,s
                    lbsr      $5F26
                    bra       L8B3B

L8B38               lbsr      L924A
L8B3B               ldd       $003F
                    cmpd      #$0030
                    lbeq      L8AD4
L8B45               ldd       #$002E
                    pshs      d
                    lbsr      L06C1
                    leas      $02,s
                    bra       L8B9C

L8B51               pshs      u
                    ldd       #$FFBA
                    lbsr      L010F
                    leas      -$02,s
                    lbsr      L0641
                    std       -$02,s
                    beq       L8B9A
                    ldd       $0041
                    std       ,s
                    lbsr      $5F26
                    ldd       $003F
                    cmpd      #$0033
                    bne       L8B96
                    ldd       $0041
                    cmpd      #$0021
                    bne       L8B96
                    ldx       ,s
                    bra       L8B89

L8B7D               ldd       #$0023
                    bra       L8B85

L8B82               ldd       #$0022
L8B85               std       ,s
                    bra       L8B93

L8B89               cmpx      #$000F
                    beq       L8B7D
                    cmpx      #$000E
                    beq       L8B82
L8B93               lbsr      $5F26
L8B96               ldd       ,s
                    bra       L8B9C

L8B9A               clra
                    clrb
L8B9C               leas      $02,s
                    puls      pc,u
L8BA0               pshs      u
                    ldd       #$FF98
                    lbsr      L010F
                    leas      -$1a,s
                    clra
                    clrb
                    std       $02,s
                    ldd       #$0002
                    std       ,s
                    clra
                    clrb
                    std       [$22,s]
                    ldd       $003F
                    cmpd      #$0033
                    lbne      L8EBC
                    ldd       $0041
                    std       $02,s
                    tfr       d,x
                    lbra      L8E7A

L8BCC               ldd       #$0001
                    std       $02,s
L8BD1               lbsr      $5F26
                    ldd       $003F
                    cmpd      #$0033
                    lbne      L8EE4
                    ldd       $0041
                    cmpd      #$0001
                    lbne      L8EE4
                    bra       L8C22

L8BEA               ldd       #$0001
                    bra       L8C20

L8BEF               lbsr      $5F26
                    ldd       #$0004
                    std       ,s
                    ldd       $003F
                    cmpd      #$0033
                    lbne      L8EE4
                    ldd       $0041
                    cmpd      #$0001
                    beq       L8C22
                    ldd       $0041
                    cmpd      #$0005
                    lbne      L8EE4
L8C13               ldd       #$0006
                    std       $02,s
                    ldd       #$0008
                    bra       L8C20

L8C1D               ldd       #$0004
L8C20               std       ,s
L8C22               lbsr      $5F26
                    lbra      L8EE4

L8C28               clra
                    clrb
                    std       $02,s
                    lbra      L8EE4

L8C2F               clra
                    clrb
                    std       $16,s
                    std       ,s
                    ldd       L0021
                    addd      #$0001
                    std       L0021
                    clra
                    clrb
                    std       $18,s
                    lbsr      $5F26
                    ldd       L0021
                    addd      #$FFFF
                    std       L0021
                    ldd       $003F
                    cmpd      #$0034
                    lbne      L8CC8
                    ldd       $0041
                    std       $18,s
                    ldd       [$18,s]
                    bne       L8C70
                    ldd       #$000A
                    std       [$18,s]
                    ldd       #$0008
                    ldx       $18,s
                    std       $08,x
                    bra       L8C86

L8C70               ldx       $18,s
                    ldd       $08,x
                    cmpd      #$0008
                    beq       L8C86
                    leax      $931E,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
L8C86               lbsr      $5F26
                    ldd       $003F
                    cmpd      #$0029
                    beq       L8CBC
                    ldd       [$18,s]
                    cmpd      #$0004
                    bne       L8CB0
                    ldx       $18,s
                    ldd       $02,x
                    std       [$1e,s]
                    ldx       $18,s
                    ldd       $0a,x
                    std       [$22,s]
                    ldd       #$0004
                    lbra      L8EF0

L8CB0               ldd       $18,s
                    std       [$1e,s]
                    ldd       #$000A
                    lbra      L8EF0

L8CBC               ldd       [$18,s]
                    cmpd      #$0004
                    bne       L8CC8
                    lbsr      L0443
L8CC8               ldd       $003F
                    cmpd      #$0029
                    beq       L8CDE
                    leax      L9329,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
                    lbra      L8EE4

L8CDE               ldd       L0021
                    addd      #$0001
                    std       L0021
L8CE5               ldd       L0021
                    std       $10,s
                    clra
                    clrb
                    std       L0021
                    lbsr      $5F26
                    ldd       $10,s
                    std       L0021
                    ldd       $003F
                    cmpd      #$002A
                    lbeq      L8E4D
                    leax      $04,s
                    pshs      x
                    leax      $0e,s
                    pshs      x
                    leax      $18,s
                    pshs      x
                    lbsr      L8BA0
                    leas      $06,s
                    std       $12,s
                    bra       L8D17

L8D17               leas      -$04,s
                    ldd       $10,s
                    std       $02,s
                    ldd       $003F
                    cmpd      #$0028
                    lbeq      L8E37
                    ldd       $0031
                    addd      #$0001
                    std       $0031
                    ldd       $16,s
                    pshs      d
                    leax      $04,s
                    pshs      x
                    leax      $04,s
                    pshs      x
                    lbsr      L8EF5
                    leas      $06,s
                    std       $12,s
                    ldu       ,s
                    ldd       $0031
                    addd      #$FFFF
                    std       $0031
                    cmpu      #$0000
                    bne       L8D5C
                    lbsr      L924A
                    leax      $1e,s
                    lbra      L8E2C

L8D5C               ldd       ,u
                    beq       L8D91
                    ldd       $0C,u
                    cmpd      $0031
                    bne       L8D8A
                    ldd       ,u
                    cmpd      $12,s
                    bne       L8D7F
                    ldd       $08,u
                    cmpd      #$0011
                    bne       L8D7F
                    ldd       $06,u
                    cmpd      $1a,s
                    beq       L8D91
L8D7F               leax      $9337,pcr
                    pshs      x
                    lbsr      L0450
                    bra       L8D8F

L8D8A               pshs      u
                    lbsr      L0382
L8D8F               leas      $02,s
L8D91               ldd       $12,s
                    cmpd      #$000A
                    bne       L8DA5
                    leax      $934E,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
L8DA5               ldd       $12,s
                    std       ,u
                    ldd       #$0011
                    std       $08,u
                    ldd       $1a,s
                    std       $06,u
                    ldd       $08,s
                    std       $0a,u
                    ldd       $18,s
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    pshs      u
                    lbsr      L906B
                    leas      $06,s
                    std       $0e,s
                    beq       L8DEF
                    ldd       $06,s
                    cmpd      #$0004
                    bne       L8DDE
                    ldd       $1a,s
                    addd      $0e,s
                    std       $1a,s
                    bra       L8DEB

L8DDE               ldd       $0e,s
                    cmpd      $04,s
                    ble       L8DE9
                    ldd       $0e,s
                    bra       L8DEB

L8DE9               ldd       $04,s
L8DEB               std       $04,s
                    bra       L8DF2

L8DEF               lbsr      L923C
L8DF2               ldd       $0031
                    std       $0C,u
                    ldd       $002B
                    std       $10,u
                    stu       $002B
                    ldd       $06,s
                    cmpd      #$0004
                    bne       L8E2F
                    ldd       #$0004
                    pshs      d
                    lbsr      L6622
                    leas      $02,s
                    std       $0C,s
                    ldx       $0C,s
                    stu       $02,x
                    ldd       [$26,s]
                    beq       L8E21
                    ldd       $0C,s
                    std       [$0a,s]
                    bra       L8E26

L8E21               ldd       $0C,s
                    std       [$26,s]
L8E26               ldd       $0C,s
                    std       $0a,s
                    bra       L8E2F

L8E2C               leas      -$1e,x
L8E2F               ldd       $003F
                    cmpd      #$0030
                    beq       L8E3B
L8E37               leas      $04,s
                    bra       L8E43

L8E3B               lbsr      $5F26
                    leas      $04,s
                    lbra      L8D17

L8E43               ldd       $003F
                    cmpd      #$0028
                    lbeq      L8CE5
L8E4D               ldd       L0021
                    addd      #$FFFF
                    std       L0021
                    ldd       $18,s
                    beq       L8E6E
                    ldd       ,s
                    ldx       $18,s
                    std       $02,x
                    ldd       #$0004
                    std       [$18,s]
                    ldd       [$22,s]
                    ldx       $18,s
                    std       $0a,x
L8E6E               ldd       #$002A
                    pshs      d
                    lbsr      L06C1
                    leas      $02,s
                    bra       L8EE4

L8E7A               cmpx      #$000A
                    lbeq      L8BCC
                    cmpx      #$0007
                    lbeq      L8BD1
                    cmpx      #$0002
                    lbeq      L8BEA
                    cmpx      #$0001
                    lbeq      L8C22
                    cmpx      #$0008
                    lbeq      L8BEF
                    cmpx      #$0006
                    lbeq      L8C13
                    cmpx      #$0005
                    lbeq      L8C1D
                    cmpx      #$0003
                    lbeq      L8C2F
                    cmpx      #$0004
                    lbeq      L8C2F
                    lbra      L8C28

L8EBC               ldd       $003F
                    cmpd      #$0034
                    bne       L8EE4
                    ldu       $0041
                    ldd       $08,u
                    cmpd      #$001E
                    bne       L8EE4
                    ldd       $02,u
                    std       [$1e,s]
                    ldd       $04,u
                    std       [$20,s]
                    ldd       $0a,u
                    std       [$22,s]
                    lbsr      $5F26
                    ldd       ,u
                    bra       L8EF0

L8EE4               ldd       ,s
                    std       [$1e,s]
                    clra
                    clrb
                    std       [$20,s]
                    ldd       $02,s
L8EF0               leas      $1a,s
                    puls      pc,u
L8EF5               pshs      u
                    ldd       #$FFAA
                    lbsr      L010F
                    leas      -$0C,s
                    clra
                    clrb
                    std       [$10,s]
                    std       $0a,s
                    bra       L8F16

L8F08               ldd       $0a,s
                    pshs      d
                    lbsr      L0688
                    leas      $02,s
                    std       $0a,s
                    lbsr      $5F26
L8F16               ldd       $003F
                    cmpd      #$0042
                    beq       L8F08
                    ldd       $003F
                    cmpd      #$0034
                    bne       L8F30
                    ldd       $0041
                    std       [$10,s]
                    lbsr      $5F26
                    bra       L8F6A

L8F30               ldd       $003F
                    cmpd      #$002D
                    bne       L8F6A
                    lbsr      $5F26
                    ldd       $0031
                    addd      #$0001
                    std       $0031
                    ldd       $14,s
                    pshs      d
                    ldd       $14,s
                    pshs      d
                    ldd       $14,s
                    pshs      d
                    lbsr      L8EF5
                    leas      $06,s
                    std       $14,s
                    ldd       $0031
                    addd      #$FFFF
                    std       $0031
                    ldd       #$002E
                    pshs      d
                    lbsr      L06C1
                    leas      $02,s
L8F6A               ldd       $003F
                    cmpd      #$002D
                    bne       L8FA1
                    ldd       $0a,s
                    aslb
                    rola
                    aslb
                    rola
                    addd      #$0030
                    std       $0a,s
                    ldd       $0031
                    bne       L8F8C
                    leax      >$0027,y
                    pshs      x
                    lbsr      L8AC5
                    bra       L8F9C

L8F8C               leax      ,s
                    pshs      x
                    lbsr      L8AC5
                    leas      $02,s
                    leax      ,s
                    pshs      x
                    lbsr      L916F
L8F9C               leas      $02,s
                    lbra      L9024

L8FA1               clra
                    clrb
                    std       $06,s
                    std       $04,s
                    std       $02,s
                    ldd       L0021
                    std       $08,s
                    clra
                    clrb
                    std       L0021
                    lbra      L9008

L8FB4               ldd       $0a,s
                    aslb
                    rola
                    aslb
                    rola
                    addd      #$0020
                    std       $0a,s
                    lbsr      $5F26
                    ldd       #$0004
                    pshs      d
                    lbsr      L6622
                    leas      $02,s
                    tfr       d,u
                    ldd       $04,s
                    bne       L8FDE
                    ldd       $003F
                    cmpd      #$002C
                    bne       L8FDE
                    clra
                    clrb
                    bra       L8FE7

L8FDE               clra
                    clrb
                    pshs      d
                    lbsr      L0C54
                    leas      $02,s
L8FE7               std       ,u
                    ldd       $06,s
                    beq       L8FF3
                    ldx       $06,s
                    stu       $02,x
                    bra       L8FF5

L8FF3               stu       $02,s
L8FF5               stu       $06,s
                    ldd       #$002C
                    pshs      d
                    lbsr      L06C1
                    leas      $02,s
                    ldd       $04,s
                    addd      #$0001
                    std       $04,s
L9008               ldd       $003F
                    cmpd      #$002B
                    lbeq      L8FB4
                    ldd       $08,s
                    std       L0021
                    ldd       $02,s
                    beq       L9024
                    ldd       [$12,s]
                    std       $02,u
                    ldd       $02,s
                    std       [$12,s]
L9024               ldd       $0a,s
                    pshs      d
                    ldd       $16,s
                    pshs      d
                    bsr       L9035
                    leas      $04,s
                    leas      $0C,s
                    puls      pc,u
L9035               pshs      u
                    ldd       #$FFBC
                    lbsr      L010F
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
                    bra       L905D

L9045               ldd       ,s
                    pshs      d
                    ldd       #$0002
                    lbsr      LB069
                    std       ,s
                    ldd       $08,s
                    pshs      d
                    ldd       #$0002
                    lbsr      LB08C
                    std       $08,s
L905D               ldd       ,s
                    clra
                    andb      #$30
                    bne       L9045
                    ldd       $06,s
                    addd      $08,s
                    lbra      L925B

L906B               pshs      u
                    ldd       #$FFB2
                    lbsr      L010F
                    ldu       $04,s
                    leas      -$04,s
                    ldd       ,u
                    std       $02,s
                    clra
                    andb      #$0f
                    tfr       d,x
                    bra       L90A0

L9082               ldd       #$0001
                    bra       L909C

L9087               ldd       #$0002
                    bra       L909C

L908C               ldd       #$0004
                    bra       L909C

L9091               ldd       #$0008
                    bra       L909C

L9096               ldd       $0C,s
                    bra       L909C

L909A               clra
                    clrb
L909C               std       ,s
                    bra       L90D3

L90A0               cmpx      #$0002
                    beq       L9082
                    cmpx      #$0001
                    beq       L9087
                    cmpx      #$0007
                    lbeq      L9087
                    cmpx      #$0008
                    beq       L908C
                    cmpx      #$0005
                    lbeq      L908C
                    cmpx      #$0006
                    beq       L9091
                    cmpx      #$0003
                    beq       L9096
                    cmpx      #$0004
                    lbeq      L9096
                    cmpx      #$000A
                    beq       L909A
L90D3               ldd       ,s
                    beq       L90DB
                    ldd       ,s
                    bra       L90DD

L90DB               ldd       $0C,s
L90DD               std       $02,u
                    ldd       $0a,s
                    std       $04,u
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    bsr       L90F5
                    leas      $06,s
                    leas      $04,s
                    puls      pc,u
L90F5               pshs      u
                    ldd       #$FFB8
                    lbsr      L010F
                    ldu       $08,s
                    leas      -$02,s
                    ldd       $06,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    beq       L9117
                    ldd       $06,s
                    clra
                    andb      #$30
                    cmpd      #$0030
                    bne       L911D
L9117               ldd       #$0002
                    lbra      L925B

L911D               ldd       $06,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    bne       L916A
                    ldd       #$0001
                    std       ,s
L912D               ldd       ,s
                    pshs      d
                    ldd       ,u
                    lbsr      LAF4B
                    std       ,s
                    ldu       $02,u
                    ldd       $06,s
                    pshs      d
                    lbsr      L067C
                    leas      $02,s
                    std       $06,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    beq       L912D
                    ldd       ,s
                    pshs      d
                    ldd       $08,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L9162
                    ldd       #$0002
                    bra       L9164

L9162               ldd       $0a,s
L9164               lbsr      LAF4B
                    lbra      L925B

L916A               ldd       $08,s
                    lbra      L925B

L916F               pshs      u
                    ldd       #$FF74
                    lbsr      L010F
                    leas      -$40,s
                    ldu       [$44,s]
                    lbra      L922C

L9180               ldd       $10,u
                    std       $3C,s
                    ldd       ,u
                    cmpd      #$0009
                    bne       L91C0
                    ldd       $0a,u
                    clra
                    andb      #$01
                    bne       L91C0
                    ldd       #$0008
                    pshs      d
                    pshs      u
                    ldd       #$0014
                    addd      ,s++
                    pshs      d
                    leax      $9362,pcr
                    pshs      x
                    leax      $06,s
                    pshs      x
                    lbsr      $A5D9
                    leas      $04,s
                    pshs      d
                    lbsr      $A6D1
                    leas      $06,s
                    pshs      d
                    lbsr      L0450
                    leas      $02,s
L91C0               ldx       $08,u
                    bra       L91CD

L91C4               ldd       L0068
                    addd      #$FFFF
                    std       L0068
                    bra       L91D9

L91CD               cmpx      #$006F
                    beq       L91C4
                    cmpx      #$0076
                    lbeq      L91C4
L91D9               ldd       $0e,u
                    std       $3e,s
                    cmpd      L0046
                    bls       L91F4
                    ldd       $3e,s
                    cmpd      L0048
                    bcc       L91F4
                    pshs      u
                    lbsr      L03D4
                    leas      $02,s
                    bra       L9229

L91F4               cmpu      [$3e,s]
                    bne       L9202
                    ldd       $12,u
                    std       [$3e,s]
                    bra       L9222

L9202               ldd       [$3e,s]
                    bra       L920D

L9207               ldx       $3e,s
                    ldd       $12,x
L920D               std       $3e,s
                    ldx       $3e,s
                    cmpu      $12,x
                    bne       L9207
                    ldd       $12,u
                    ldx       $3e,s
                    std       $12,x
L9222               ldd       $0062
                    std       $12,u
                    stu       $0062
L9229               ldu       $3C,s
L922C               stu       -$02,s
                    lbne      L9180
                    clra
                    clrb
                    std       [$44,s]
                    leas      $40,s
                    puls      pc,u
L923C               pshs      u
                    ldd       #$FFBA
                    lbsr      L010F
                    leax      L9375,pcr
                    bra       L9256

L924A               pshs      u
                    ldd       #$FFBA
                    lbsr      L010F
                    leax      $938A,pcr
L9256               pshs      x
                    lbsr      L0450
L925B               leas      $02,s
                    puls      pc,u
L925F               lsr       $6F6F
                    bra       $92D1
                    fcb       $61
                    jmp       -$07,s
                    bra       $92CB
                    fcb       $72
                    fcb       $61
                    com       $0b,s
                    fcb       $65
                    lsr       $7300
L9271               ror       -$0b,s
                    jmp       $03,s
                    lsr       $696F
                    jmp       0,y
                    asl       $05,s
                    fcb       $61
                    lsr       $05,s
                    fcb       $72
                    bra       L92EF
                    rol       -$0d,s
                    com       L696E
                    asr       0,x
L9289               com       $746F
                    fcb       $72
                    fcb       $61
                    asr       $05,s
                    bra       L92F7
                    fcb       $72
                    fcb       $72
                    clr       -$0e,s
                    neg       $0066
                    fcb       $75
                    jmp       $03,s
                    lsr       $696F
                    jmp       0,y
                    lsr       $7970
                    fcb       $65
                    bra       $930B
                    fcb       $72
                    fcb       $72
                    clr       -$0e,s
                    neg       L0061
                    fcb       $72
                    asr       -$0b,s
                    tst       $05,s
                    jmp       -$0C,s
                    bra       $9328
                    lsr       $6F72
                    fcb       $61
                    asr       $05,s
                    neg       L0061
                    fcb       $72
                    asr       -$0b,s
                    tst       $05,s
                    jmp       -$0C,s
                    bra       $932B
                    fcb       $72
                    fcb       $72
                    clr       -$0e,s
                    neg       $006E
                    clr       -$0C,s
                    bra       L9331
                    jmp       0,y
                    fcb       $61
                    fcb       $72
                    asr       -$0b,s
                    tst       $05,s
                    jmp       -$0C,s
                    neg       $0073
                    lsr       $6F72
                    fcb       $61
                    asr       $05,s
                    bra       $9349
                    fcb       $72
                    fcb       $72
                    clr       -$0e,s
                    neg       $0064
                    fcb       $65
                    com       $0C,s
                    fcb       $61
                    fcb       $72
L92EF               fcb       $61
                    lsr       $696F
                    jmp       0,y
                    tst       $09,s
L92F7               com       $6D61
                    lsr       L6368
                    neg       $0066
                    fcb       $75
                    jmp       $03,s
                    lsr       $696F
                    jmp       0,y
                    fcb       $75
                    jmp       $06,s
                    rol       $0e,s
                    rol       -$0d,s
                    asl       $05,s
                    lsr       0,x
L9312               jmp       $01,s
                    tst       $05,s
                    lsr       0,y
                    lsr       $7769
                    com       $05,s
                    neg       $006E
                    fcb       $61
                    tst       $05,s
                    bra       $9387
                    inc       $01,s
                    com       $6800
L9329               com       L7472
                    fcb       $75
                    com       -$0C,s
                    bra       $93A4

L9331               rol       L6E74
                    fcb       $61
                    asl       >$0073
                    lsr       L7275
                    com       -$0C,s
                    bra       $93AC
                    fcb       $65
                    tst       $02,s
                    fcb       $65
                    fcb       $72
                    bra       $93B3
                    rol       -$0d,s
                    tst       $01,s
                    lsr       L6368
                    neg       L0075
                    jmp       $04,s
                    fcb       $65
                    ror       $09,s
                    jmp       $05,s
                    lsr       0,y
                    com       L7472
                    fcb       $75
                    com       -$0C,s
                    fcb       $75
                    fcb       $72
                    fcb       $65
                    neg       L006C
                    fcb       $61
                    fcb       $62
                    fcb       $65
                    inc       0,y
                    fcb       $75
                    jmp       $04,s
                    fcb       $65
                    ror       $09,s
                    jmp       $05,s
                    lsr       0,y
                    abx
                    bra       L9375

L9375               com       $01,s
                    jmp       $0e,s
                    clr       -$0C,s
                    bra       $93E2
                    ror       $616C
                    fcb       $75
                    fcb       $61
                    lsr       $6520
                    com       $697A
                    fcb       $65
                    neg       $0069
                    lsr       $05,s
                    jmp       -$0C,s
                    rol       $06,s
                    rol       $05,s
                    fcb       $72
                    bra       L9403
                    rol       -$0d,s
                    com       L696E
                    asr       0,x
L939D               pshs      u
                    ldd       #$FFAE
                    lbsr      L010F
                    ldu       $04,s
                    leas      -$04,s
                    ldd       $06,u
                    std       $02,s
                    tfr       d,x
                    lbra      L94F9

L93B2               ldd       #$0001
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    ldd       $000B
                    addd      #$0001
                    std       $000B
                    std       $04,s
                    pshs      d
                    ldd       $0a,u
                    pshs      d
                    bsr       L939D
                    leas      $08,s
                    leax      $04,s
                    bra       L93F0

L93D2               clra
                    clrb
                    pshs      d
                    ldd       $000B
                    addd      #$0001
                    std       $000B
                    std       $02,s
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    ldd       $0a,u
                    pshs      d
                    lbsr      L939D
                    leas      $08,s
                    bra       L93F2

L93F0               leas      -$04,x
L93F2               ldd       ,s
                    pshs      d
                    lbsr      L57B2
                    lbra      L945C

L93FC               ldd       #$0001
                    subd      $0e,s
                    pshs      d
L9403               ldd       $0C,s
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    ldd       $0a,u
                    lbra      L946C

L9411               ldd       $0e,s
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    pshs      u
                    ldd       $0a,s
                    pshs      d
                    lbsr      L9577
                    leas      $0a,s
                    lbra      L9573

L942B               ldd       $08,u
                    beq       L943B
                    ldd       $0e,s
                    bne       L943B
                    clra
                    clrb
                    pshs      d
                    ldd       $0C,s
                    bra       L944D

L943B               ldd       $0e,s
                    lbeq      L9573
                    ldd       $08,u
                    lbne      L9573
                    clra
                    clrb
                    pshs      d
                    ldd       $0e,s
L944D               pshs      d
                    ldd       #$007C
                    lbra      L94F0

L9455               ldd       $0a,u
                    pshs      d
                    lbsr      L6F83
L945C               leas      $02,s
                    ldd       $0e,s
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    ldd       $0C,u
L946C               pshs      d
                    lbsr      L939D
                    leas      $08,s
                    lbra      L9573

L9476               ldd       ,u
                    cmpd      #$0008
                    bne       L9496
                    pshs      u
                    lbsr      L34BE
                    leas      $02,s
                    ldd       #$008B
                    pshs      d
                    ldd       #$0088
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
                    bra       L94D7

L9496               ldd       ,u
                    cmpd      #$0005
                    beq       L94A6
                    ldd       ,u
                    cmpd      #$0006
                    bne       L94CC
L94A6               ldd       $06,u
                    cmpd      #$008C
                    bne       L94B0
                    ldu       $0a,u
L94B0               pshs      u
                    lbsr      $3987
                    leas      $02,s
                    ldd       ,u
                    pshs      d
                    ldd       #$008B
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
                    bra       L94D7

L94CC               pshs      u
                    lbsr      L97AE
                    leas      $02,s
                    bra       L94D7
                    leas      -$04,x
L94D7               ldd       $0e,s
                    beq       L94E4
                    ldd       $0C,s
                    pshs      d
                    ldd       #$005A
                    bra       L94EB

L94E4               ldd       $0a,s
                    pshs      d
                    ldd       #$005B
L94EB               pshs      d
                    ldd       #$0082
L94F0               pshs      d
                    lbsr      L4623
                    leas      $06,s
                    bra       L9573

L94F9               cmpx      #$0047
                    lbeq      L93B2
                    cmpx      #$0048
                    lbeq      L93D2
                    cmpx      #$0040
                    lbeq      L93FC
                    cmpx      #$005A
                    lbeq      L9411
                    cmpx      #$005B
                    lbeq      L9411
                    cmpx      #$005C
                    lbeq      L9411
                    cmpx      #$005D
                    lbeq      L9411
                    cmpx      #$005E
                    lbeq      L9411
                    cmpx      #$005F
                    lbeq      L9411
                    cmpx      #$0060
                    lbeq      L9411
                    cmpx      #$0061
                    lbeq      L9411
                    cmpx      #$0062
                    lbeq      L9411
                    cmpx      #$0063
                    lbeq      L9411
                    cmpx      #$0036
                    lbeq      L942B
                    cmpx      #$004B
                    lbeq      L942B
                    cmpx      #$004A
                    lbeq      L942B
                    cmpx      #$0030
                    lbeq      L9455
                    lbra      L9476

L9573               leas      $04,s
                    puls      pc,u
L9577               pshs      u
                    ldd       #$FFAE
                    lbsr      L010F
                    leas      -$06,s
                    ldx       $0C,s
                    ldd       $0a,x
                    std       ,s
                    ldx       $0C,s
                    ldu       $0C,x
                    ldd       $12,s
                    beq       L9595
                    ldd       $10,s
                    bra       L9597

L9595               ldd       $0e,s
L9597               std       $02,s
                    ldd       $12,s
                    beq       L95A9
                    ldd       $0a,s
                    pshs      d
                    lbsr      L98F1
                    leas      $02,s
                    bra       L95AB

L95A9               ldd       $0a,s
L95AB               std       $0a,s
                    ldd       [,s]
                    cmpd      #$0008
                    bne       L95BE
                    ldd       $0C,s
                    pshs      d
                    lbsr      L34D9
                    bra       L95D5

L95BE               ldd       [,s]
                    cmpd      #$0005
                    beq       L95CE
                    ldd       [,s]
                    cmpd      #$0006
                    bne       L95DC
L95CE               ldd       $0C,s
                    pshs      d
                    lbsr      L39A2
L95D5               leas      $02,s
                    leax      $06,s
                    lbra      L973C

L95DC               ldd       ,s
                    pshs      d
                    lbsr      L9971
                    std       ,s++
                    bne       L9613
                    ldd       ,s
                    pshs      d
                    lbsr      L9754
                    std       ,s++
                    beq       L95FB
                    pshs      u
                    lbsr      L9754
                    std       ,s++
                    beq       L9613
L95FB               ldd       $06,u
                    pshs      d
                    lbsr      L8132
                    std       ,s++
                    beq       L9626
                    ldx       ,s
                    ldd       $06,x
                    pshs      d
                    lbsr      L8132
                    std       ,s++
                    bne       L9626
L9613               ldd       ,s
                    std       $04,s
                    stu       ,s
                    ldu       $04,s
                    ldd       $0a,s
                    pshs      d
                    lbsr      L9929
                    leas      $02,s
                    std       $0a,s
L9626               ldx       ,s
                    ldd       $06,x
                    std       $04,s
                    pshs      d
                    lbsr      L8132
                    std       ,s++
                    lbeq      L96A9
                    pshs      u
                    lbsr      L6F83
                    leas      $02,s
                    ldx       $06,u
                    bra       L9682

L9642               pshs      u
                    lbsr      L6EAC
                    leas      $02,s
                    leax      $06,s
                    bra       L966A

L964D               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
                    ldd       #$0070
                    std       $06,u
                    bra       L966C

L966A               leas      -$06,x
L966C               ldd       $06,u
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
                    ldd       #$006E
                    std       $06,u
                    lbra      L9725

L9682               cmpx      #$0041
                    beq       L9642
                    cmpx      #$0085
                    beq       L964D
                    cmpx      #$0071
                    beq       L966C
                    cmpx      #$0076
                    lbeq      L966C
                    cmpx      #$006F
                    lbeq      L966C
                    cmpx      #$0070
                    lbeq      L966C
                    lbra      L9725

L96A9               pshs      u
                    lbsr      L9971
                    std       ,s++
                    beq       L96C6
                    ldd       $0a,s
                    cmpd      #$0060
                    bge       L96C6
                    ldd       ,s
                    pshs      d
                    lbsr      L97AE
                    leas      $02,s
                    lbra      L973E

L96C6               ldd       ,s
                    pshs      d
                    lbsr      L6EAC
                    leas      $02,s
                    ldx       ,s
                    ldd       $06,x
                    std       $04,s
                    pshs      u
                    lbsr      L76BF
                    std       ,s++
                    bne       L96EF
                    ldd       $04,s
                    cmpd      #$0070
                    bne       L96F8
                    pshs      u
                    lbsr      L9754
                    std       ,s++
                    beq       L96F8
L96EF               pshs      u
                    lbsr      L6F83
                    leas      $02,s
                    bra       L9725

L96F8               ldd       $04,s
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
                    ldd       #$006E
                    ldx       ,s
                    std       $06,x
                    pshs      u
                    lbsr      L6EAC
                    leas      $02,s
                    ldd       $06,u
                    std       $04,s
                    ldu       ,s
                    ldd       $0a,s
                    pshs      d
                    lbsr      L9929
                    leas      $02,s
                    std       $0a,s
L9725               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       #$0081
                    pshs      d
                    lbsr      L4623
                    leas      $08,s
                    bra       L973E

L973C               leas      -$06,x
L973E               ldd       $02,s
                    pshs      d
                    ldd       $0C,s
                    pshs      d
                    ldd       #$0082
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
                    leas      $06,s
                    puls      pc,u
L9754               pshs      u
                    ldd       #$FFBA
                    lbsr      L010F
                    ldx       $04,s
                    ldx       $06,x
                    bra       L9772

L9762               ldd       #$0001
                    puls      pc,u
L9767               ldd       $04,s
                    pshs      d
                    lbsr      L7759
                    leas      $02,s
                    puls      pc,u
L9772               cmpx      #$0034
                    beq       L9762
                    cmpx      #$0036
                    lbeq      L9762
                    cmpx      #$0042
                    beq       L9767
                    lbra      L998C
                    pshs      u
                    ldd       #$FFC0
                    lbsr      L010F
                    ldx       $04,s
                    ldd       $06,x
                    cmpd      #$0034
                    lbne      L998C
                    ldx       $04,s
                    ldx       $08,x
                    ldd       $08,x
                    cmpd      #$000D
                    lbne      L998C
                    ldd       #$0001
                    lbra      L998E

L97AE               pshs      u
                    ldd       #$FFB0
                    lbsr      L010F
                    ldu       $04,s
                    leas      -$04,s
                    clra
                    clrb
                    std       ,s
                    ldx       $06,u
                    bra       L9813

L97C2               ldd       $0C,u
                    std       $02,s
                    tfr       d,x
                    ldd       $06,x
                    cmpd      #$0036
                    bne       L980B
                    ldx       $02,s
                    ldd       $08,x
                    cmpd      #$00FF
                    lbls      L9889
                    bra       L980B

L97DE               ldx       $0a,u
                    ldd       $06,x
                    pshs      d
                    lbsr      L8132
                    std       ,s++
                    lbeq      L9889
                    ldd       $0C,u
                    pshs      d
                    lbsr      L9754
                    std       ,s++
                    lbne      L9889
                    bra       L980B

L97FC               ldx       $0a,u
                    ldd       $06,x
                    pshs      d
                    lbsr      L8132
                    std       ,s++
                    lbeq      L9889
L980B               ldd       #$0001
                    std       ,s
                    lbra      L9889

L9813               cmpx      #$0057
                    beq       L97C2
                    cmpx      #$0078
                    beq       L97DE
                    cmpx      #$003E
                    beq       L97FC
                    cmpx      #$003F
                    lbeq      L97FC
                    cmpx      #$003D
                    lbeq      L97FC
                    cmpx      #$003C
                    lbeq      L97FC
                    cmpx      #$00A0
                    lbeq      L97FC
                    cmpx      #$00A1
                    lbeq      L97FC
                    cmpx      #$00A7
                    lbeq      L97FC
                    cmpx      #$00A8
                    lbeq      L97FC
                    cmpx      #$00A9
                    lbeq      L97FC
                    cmpx      #$0076
                    beq       L980B
                    cmpx      #$006F
                    lbeq      L980B
                    cmpx      #$0058
                    lbeq      L980B
                    cmpx      #$0059
                    lbeq      L980B
                    cmpx      #$0044
                    lbeq      L980B
                    cmpx      #$0043
                    lbeq      L980B
                    cmpx      #$0065
                    lbeq      L980B
L9889               clra
                    clrb
                    std       $0066
                    pshs      u
                    lbsr      L6F83
                    leas      $02,s
                    ldx       $06,u
                    bra       L98CC

L9898               ldd       ,s
                    bne       L98A0
                    ldd       $0066
                    beq       L98ED
L98A0               clra
                    clrb
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       $06,u
                    pshs      d
                    ldd       #$0081
                    bra       L98C3

L98B2               ldu       $0a,u
L98B4               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
L98C3               pshs      d
                    lbsr      L4623
                    leas      $08,s
                    bra       L98ED

L98CC               cmpx      #$0071
                    beq       L9898
                    cmpx      #$0070
                    lbeq      L9898
                    cmpx      #$0076
                    lbeq      L9898
                    cmpx      #$006F
                    lbeq      L9898
                    cmpx      #$0085
                    beq       L98B2
                    bra       L98B4

L98ED               leas      $04,s
                    puls      pc,u
L98F1               pshs      u
                    ldd       #$FFC0
                    lbsr      L010F
                    ldx       $04,s
                    bra       L991B

L98FD               ldd       #$005B
                    puls      pc,u
L9902               ldd       #$005A
                    puls      pc,u
L9907               ldd       $04,s
                    cmpd      #$005F
                    ble       L9914
                    ldd       #$00C3
                    bra       L9917

L9914               ldd       #$00BB
L9917               subd      $04,s
                    puls      pc,u
L991B               cmpx      #$005A
                    beq       L98FD
                    cmpx      #$005B
                    beq       L9902
                    bra       L9907
                    puls      pc,u
L9929               pshs      u
                    ldd       #$FFC0
                    lbsr      L010F
                    ldx       $04,s
                    bra       L9947

L9935               ldd       $04,s
                    puls      pc,u
L9939               ldd       $04,s
                    addd      #$0002
                    puls      pc,u
L9940               ldd       $04,s
                    addd      #$FFFE
                    puls      pc,u
L9947               cmpx      #$005A
                    beq       L9935
                    cmpx      #$005B
                    lbeq      L9935
                    cmpx      #$005C
                    beq       L9939
                    cmpx      #$005D
                    lbeq      L9939
                    cmpx      #$0060
                    lbeq      L9939
                    cmpx      #$0061
                    lbeq      L9939
                    bra       L9940
                    puls      pc,u
L9971               pshs      u
                    ldd       #$FFC0
                    lbsr      L010F
                    ldu       $04,s
                    ldd       $06,u
                    cmpd      #$0036
                    bne       L998C
                    ldd       $08,u
                    bne       L998C
                    ldd       #$0001
                    bra       L998E

L998C               clra
                    clrb
L998E               puls      pc,u
L9990               ldx       $02,s
                    leas      -$08,s
                    ldd       $05,x
                    aslb
                    rola
                    std       $05,x
                    std       $05,s
                    ldd       $03,x
                    rolb
                    rola
                    std       $03,x
                    std       $03,s
                    ldd       $01,x
                    rolb
                    rola
                    std       $01,x
                    std       $01,s
                    lda       ,x
                    rola
                    sta       ,x
                    sta       ,s
                    asl       $06,x
                    rol       $05,x
                    rol       $04,x
                    rol       $03,x
                    rol       $02,x
                    rol       $01,x
                    rol       ,x
                    bcs       L9A19
                    asl       $06,x
                    rol       $05,x
                    rol       $04,x
                    rol       $03,x
                    rol       $02,x
                    rol       $01,x
                    rol       ,x
                    bcs       L9A19
                    ldd       $05,x
                    addd      $05,s
                    std       $05,x
                    ldd       $03,x
                    adcb      $04,s
                    adca      $03,s
                    std       $03,x
                    ldd       $01,x
                    adcb      $02,s
                    adca      $01,s
                    std       $01,x
                    ldb       ,x
                    adcb      ,s
                    stb       ,x
                    bcs       L9A19
                    ldb       $0d,s
                    andb      #$0f
                    clra
                    addd      $05,x
                    std       $05,x
                    ldd       #$0000
                    adcb      $04,x
                    adca      $03,x
                    std       $03,x
                    ldd       #$0000
                    adcb      $02,x
                    adca      $01,x
                    std       $01,x
                    lda       #$00
                    adca      ,x
                    sta       ,x
                    bcs       L9A19
                    leas      $08,s
                    clra
                    clrb
                    rts

L9A19               ldd       #$0001
                    leas      $08,s
                    rts

L9A1F               pshs      u
                    leax      $0253,y
                    stx       L0070
                    ldd       #$0001
                    std       $0076
                    leax      $06,s
                    pshs      x
                    ldd       $06,s
                    bra       L9A45

L9A34               pshs      u
                    ldd       $04,s
                    std       L0070
                    ldd       #$0001
                    std       $0076
                    leax      $08,s
                    pshs      x
                    ldd       $08,s
L9A45               pshs      d
                    bsr       L9A6C
                    leas      $04,s
                    puls      pc,u
                    pshs      u
                    ldd       $04,s
                    std       L0070
                    ldd       #$0002
                    std       $0076
                    leax      $08,s
                    pshs      x
                    ldd       $08,s
                    pshs      d
                    bsr       L9A6C
                    leas      $04,s
                    clra
                    clrb
                    stb       [L0070,y]
                    puls      pc,u
L9A6C               pshs      u
                    ldu       $04,s
                    leas      -$0b,s
                    bra       L9A84

L9A74               ldb       $08,s
                    lbeq      L9BE2
                    ldb       $08,s
                    sex
                    pshs      d
                    lbsr      L9DC1
                    leas      $02,s
L9A84               ldb       ,u+
                    stb       $08,s
                    cmpb      #$25
                    bne       L9A74
                    ldb       ,u+
                    stb       $08,s
                    clra
                    clrb
                    std       $02,s
                    std       $06,s
                    ldb       $08,s
                    cmpb      #$2d
                    bne       L9AA7
                    ldd       #$0001
                    std       $0072
                    ldb       ,u+
                    stb       $08,s
                    bra       L9AAB

L9AA7               clra
                    clrb
                    std       $0072
L9AAB               ldb       $08,s
                    cmpb      #$30
                    bne       L9AB6
                    ldd       #$0030
                    bra       L9AB9

L9AB6               ldd       #$0020
L9AB9               std       $0074
                    bra       L9AD7

L9ABD               ldd       $06,s
                    pshs      d
                    ldd       #$000A
                    lbsr      LAF4B
                    pshs      d
                    ldb       $0a,s
                    sex
                    addd      #$FFD0
                    addd      ,s++
                    std       $06,s
                    ldb       ,u+
                    stb       $08,s
L9AD7               ldb       $08,s
                    sex
L9ADA               leax      $00BA,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$6b
                    beq       L9ABD
                    ldb       $08,s
                    cmpb      #$2e
                    bne       L9B1E
                    ldd       #$0001
                    std       $04,s
                    bra       L9B09

L9AF3               ldd       $02,s
                    pshs      d
                    ldd       #$000A
                    lbsr      LAF4B
                    pshs      d
                    ldb       $0a,s
                    sex
                    addd      #$FFD0
                    addd      ,s++
                    std       $02,s
L9B09               ldb       ,u+
                    stb       $08,s
                    ldb       $08,s
                    sex
                    leax      $00BA,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$6b
                    beq       L9AF3
                    bra       L9B22

L9B1E               clra
                    clrb
                    std       $04,s
L9B22               ldb       $08,s
                    sex
                    tfr       d,x
                    lbra      L9BC4

L9B2A               ldd       $06,s
                    pshs      d
                    ldx       $13,s
                    leax      $02,x
                    stx       $13,s
                    ldd       -$02,x
                    pshs      d
                    lbsr      L9BE6
                    bra       L9B52

L9B3F               ldd       $06,s
                    pshs      d
                    ldx       $13,s
                    leax      $02,x
                    stx       $13,s
                    ldd       -$02,x
                    pshs      d
                    lbsr      L9CA7
L9B52               std       ,s
                    lbra      L9BAF

L9B57               ldx       $11,s
                    leax      $02,x
                    stx       $11,s
                    ldd       -$02,x
                    lbra      L9BBA

L9B64               ldx       $11,s
                    leax      $02,x
                    stx       $11,s
                    ldd       -$02,x
                    std       $09,s
                    ldd       $04,s
                    beq       L9BA7
                    ldd       $09,s
                    std       $04,s
                    bra       L9B86

L9B7A               ldb       [$09,s]
                    beq       L9B92
                    ldd       $09,s
                    addd      #$0001
                    std       $09,s
L9B86               ldd       $02,s
                    addd      #$FFFF
                    std       $02,s
                    subd      #$FFFF
                    bne       L9B7A
L9B92               ldd       $06,s
                    pshs      d
                    ldd       $0b,s
                    subd      $06,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L9D66
                    leas      $06,s
                    bra       L9BB4

L9BA7               ldd       $06,s
                    pshs      d
                    ldd       $0b,s
                    pshs      d
L9BAF               lbsr      L9D06
                    leas      $04,s
L9BB4               lbra      L9A84

L9BB7               ldb       $08,s
                    sex
L9BBA               pshs      d
                    lbsr      L9DC1
                    leas      $02,s
                    lbra      L9A84

L9BC4               cmpx      #$0064
                    lbeq      L9B2A
                    cmpx      #$0078
                    lbeq      L9B3F
                    cmpx      #$0063
                    lbeq      L9B57
                    cmpx      #$0073
                    lbeq      L9B64
                    bra       L9BB7

L9BE2               leas      $0b,s
                    puls      pc,u
L9BE6               pshs      u,d
                    leax      $088a,y
                    stx       ,s
                    ldd       $06,s
                    bge       L9C1B
                    ldd       $06,s
                    nega
                    negb
                    sbca      #$00
                    std       $06,s
                    bge       L9C10
                    leax      L9DE6,pcr
                    pshs      x
                    leax      $088a,y
                    pshs      x
                    lbsr      $A5D9
                    leas      $04,s
                    lbra      L9DBD

L9C10               ldd       #$002D
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
L9C1B               ldd       $06,s
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    bsr       L9C30
                    leas      $04,s
                    leax      $088a,y
                    tfr       x,d
                    lbra      L9DBD

L9C30               pshs      u,y,x,d
                    ldu       $0a,s
                    clra
                    clrb
                    std       $02,s
                    clra
                    clrb
                    std       ,s
                    bra       L9C4D

L9C3E               ldd       ,s
                    addd      #$0001
                    std       ,s
                    ldd       $0C,s
                    subd      $023e,y
                    std       $0C,s
L9C4D               ldd       $0C,s
                    blt       L9C3E
                    leax      $023e,y
                    stx       $04,s
                    bra       L9C8F

L9C59               ldd       ,s
                    addd      #$0001
                    std       ,s
L9C60               ldd       $0C,s
                    subd      [$04,s]
                    std       $0C,s
                    bge       L9C59
                    ldd       $0C,s
                    addd      [$04,s]
                    std       $0C,s
                    ldd       ,s
                    beq       L9C79
                    ldd       #$0001
                    std       $02,s
L9C79               ldd       $02,s
                    beq       L9C84
                    ldd       ,s
                    addd      #$0030
                    stb       ,u+
L9C84               clra
                    clrb
                    std       ,s
                    ldd       $04,s
                    addd      #$0002
                    std       $04,s
L9C8F               ldd       $04,s
                    cmpd      $0001
                    bne       L9C60
                    ldd       $0C,s
                    addd      #$0030
                    stb       ,u+
                    clra
                    clrb
                    stb       ,u
                    ldd       $0a,s
                    leas      $06,s
                    puls      pc,u
L9CA7               pshs      u,x,d
                    leax      $088a,y
                    stx       $02,s
                    leau      $0894,y
L9CB3               ldd       $08,s
                    clra
                    andb      #$0f
                    std       ,s
                    pshs      d
                    ldd       $02,s
                    cmpd      #$0009
                    ble       L9CC9
                    ldd       #$0057
                    bra       L9CCC

L9CC9               ldd       #$0030
L9CCC               addd      ,s++
                    stb       ,u+
                    ldd       $08,s
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    anda      #$0f
                    std       $08,s
                    bne       L9CB3
                    bra       L9CEC

L9CE2               ldb       ,u
                    ldx       $02,s
                    leax      $01,x
                    stx       $02,s
                    stb       -$01,x
L9CEC               leau      -$01,u
                    pshs      u
                    leax      $0894,y
                    cmpx      ,s++
                    bls       L9CE2
                    clra
                    clrb
                    stb       [$02,s]
                    leax      $088a,y
                    tfr       x,d
                    lbra      L9DE2

L9D06               pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    pshs      d
                    lbsr      $A5C8
                    leas      $02,s
                    nega
                    negb
                    sbca      #$00
                    leau      d,u
                    ldd       $0072
                    bne       L9D3D
                    bra       L9D2A

L9D21               ldd       $0074
                    pshs      d
                    lbsr      L9DC1
                    leas      $02,s
L9D2A               tfr       u,d
                    leau      -$01,u
                    std       -$02,s
                    bgt       L9D21
                    bra       L9D3D

L9D34               ldd       ,s
                    pshs      d
                    lbsr      L9DC1
                    leas      $02,s
L9D3D               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    sex
                    std       ,s
                    bne       L9D34
                    ldd       $0072
                    lbeq      L9DBD
                    bra       L9D5B

L9D52               ldd       $0074
                    pshs      d
                    lbsr      L9DC1
                    leas      $02,s
L9D5B               tfr       u,d
                    leau      -$01,u
                    std       -$02,s
                    bgt       L9D52
                    lbra      L9DBD

L9D66               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    ldd       $0a,s
                    subd      $08,s
                    std       ,s
                    ldd       $0072
                    bne       L9D97
                    bra       L9D80

L9D78               ldd       $0074
                    pshs      d
                    bsr       L9DC1
                    leas      $02,s
L9D80               ldd       ,s
                    addd      #$FFFF
                    std       ,s
                    subd      #$FFFF
                    bgt       L9D78
                    bra       L9D97

L9D8E               ldb       ,u+
                    sex
                    pshs      d
                    bsr       L9DC1
                    leas      $02,s
L9D97               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bne       L9D8E
                    ldd       $0072
                    beq       L9DBD
                    bra       L9DB1

L9DA9               ldd       $0074
                    pshs      d
                    bsr       L9DC1
                    leas      $02,s
L9DB1               ldd       ,s
                    addd      #$FFFF
                    std       ,s
                    subd      #$FFFF
                    bgt       L9DA9
L9DBD               leas      $02,s
                    puls      pc,u
L9DC1               pshs      u
                    ldd       $0076
                    cmpd      #$0002
                    bne       L9DD7
                    ldd       $04,s
                    ldx       L0070
                    leax      $01,x
                    stx       L0070
                    stb       -$01,x
                    bra       L9DE4

L9DD7               ldd       L0070
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      $A1CD
L9DE2               leas      $04,s
L9DE4               puls      pc,u
L9DE6               blt       $9E1B
                    leas      -$09,y
                    pshu      y,x,dp
                    neg       $0034
                    nega
                    leau      $0246,y
L9DF3               ldd       $06,u
                    clra
                    andb      #$03
                    lbeq      L9E64
                    leau      $0d,u
                    pshs      u
                    leax      $0316,y
                    cmpx      ,s++
                    bhi       L9DF3
                    ldd       #$00C8
                    std       $0364,y
                    lbra      L9E68
                    puls      pc,u
                    pshs      u
                    ldu       $08,s
                    bne       L9E1E
                    bsr       $9DED
                    tfr       d,u
L9E1E               stu       -$02,s
                    beq       L9E68
                    ldd       $04,s
                    std       $08,u
                    ldx       $06,s
                    ldb       $01,x
                    cmpb      #$2b
                    beq       L9E36
                    ldx       $06,s
                    ldb       $02,x
                    cmpb      #$2b
                    bne       L9E3C
L9E36               ldd       $06,u
                    orb       #$03
                    bra       L9E5A

L9E3C               ldd       $06,u
                    pshs      d
                    ldb       [$08,s]
                    cmpb      #$72
                    beq       L9E4E
                    ldb       [$08,s]
                    cmpb      #$64
                    bne       L9E53
L9E4E               ldd       #$0001
                    bra       L9E56

L9E53               ldd       #$0002
L9E56               ora       ,s+
                    orb       ,s+
L9E5A               std       $06,u
                    ldd       $02,u
                    addd      $0b,u
                    std       $04,u
                    std       ,u
L9E64               tfr       u,d
                    puls      pc,u
L9E68               clra
                    clrb
                    puls      pc,u
L9E6C               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    clra
                    clrb
                    std       ,s
                    ldx       $0a,s
                    ldb       $01,x
                    sex
                    tfr       d,x
                    bra       L9E9D

L9E7F               ldx       $0a,s
                    ldb       $02,x
                    cmpb      #$2b
                    bne       L9E8C
                    ldd       #$0007
                    bra       L9E94

L9E8C               ldd       #$0004
                    bra       L9E94

L9E91               ldd       #$0003
L9E94               std       ,s
                    bra       L9EAD

L9E98               leax      $04,s
                    lbra      L9F05

L9E9D               stx       -$02,s
                    beq       L9EAD
                    cmpx      #$0078
                    beq       L9E7F
                    cmpx      #$002B
                    beq       L9E91
                    bra       L9E98

L9EAD               ldb       [$0a,s]
                    sex
                    tfr       d,x
                    lbra      L9F12

L9EB6               ldd       ,s
                    orb       #$01
                    bra       L9EF8

L9EBC               ldd       ,s
                    orb       #$02
                    pshs      d
                    pshs      u
                    lbsr      $B116
                    leas      $04,s
                    std       $02,s
                    cmpd      #$FFFF
                    beq       L9EE7
                    ldd       #$0002
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      $B1EC
                    leas      $08,s
                    bra       L9F2C

L9EE7               ldd       ,s
                    orb       #$02
                    pshs      d
                    pshs      u
                    lbsr      $B137
                    bra       L9EFF

L9EF4               ldd       ,s
                    orb       #$81
L9EF8               pshs      d
                    pshs      u
                    lbsr      $B116
L9EFF               leas      $04,s
                    std       $02,s
                    bra       L9F2C

L9F05               leas      -$04,x
L9F07               ldd       #$00CB
                    std       $0364,y
                    clra
                    clrb
                    bra       L9F2E

L9F12               cmpx      #$0072
                    lbeq      L9EB6
                    cmpx      #$0061
                    lbeq      L9EBC
                    cmpx      #$0077
                    beq       L9EE7
                    cmpx      #$0064
                    beq       L9EF4
                    bra       L9F07

L9F2C               ldd       $02,s
L9F2E               leas      $04,s
                    puls      pc,u
                    pshs      u
                    clra
                    clrb
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbra      $9F8E

L9F43               pshs      u
                    ldd       $06,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L9E6C
                    leas      $04,s
                    tfr       d,u
                    cmpu      #$FFFF
                    bne       L9F5E
                    clra
                    clrb
                    bra       $9F93

L9F5E               clra
                    clrb
                    bra       $9F86

L9F62               pshs      u
                    ldd       $08,s
                    pshs      d
                    lsr       $0017
                    com       $0053
                    leas      $02,s
                    ldd       $06,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      $9E6D
                    leas      $04,s
                    tfr       d,u
                    stu       -$02,s
                    bge       L9F85
                    clra
                    clrb
                    bra       L9F94

L9F85               ldd       $08,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    pshs      u
                    lbsr      $9E15
                    leas      $06,s
L9F94               puls      pc,u
                    pshs      u
                    leax      $0253,y
                    pshs      x
                    ldd       $06,s
                    pshs      d
                    bsr       L9FB8
                    leas      $04,s
                    leax      $0253,y
                    pshs      x
                    ldd       #$000D
                    pshs      d
                    lbsr      LA1CE
                    leas      $04,s
                    puls      pc,u
L9FB8               pshs      u
                    ldu       $04,s
                    leas      -$01,s
                    bra       L9FCE

L9FC0               ldd       $07,s
                    pshs      d
                    ldb       $02,s
                    sex
                    pshs      d
                    lbsr      LA1CE
                    leas      $04,s
L9FCE               ldb       ,u+
                    stb       ,s
                    bne       L9FC0
                    leas      $01,s
                    puls      pc,u
                    pshs      u,d
                    ldu       $06,s
                    bra       L9FE0

L9FDE               leau      $01,u
L9FE0               ldb       ,u
                    sex
                    std       ,s
                    beq       L9FEF
                    ldd       ,s
                    cmpd      #$0058
                    bne       L9FDE
L9FEF               ldd       ,s
                    beq       LA005
                    lbsr      LB2D8
                    pshs      d
                    leax      >LA00B,pcr
                    pshs      x
                    pshs      u
                    lbsr      $9A4E
                    leas      $06,s
LA005               ldd       $06,s
                    leas      $02,s
                    puls      pc,u
LA00B               bcs       LA071
                    neg       $0034
                    nega
                    ldu       $04,s
                    leas      -$06,s
                    cmpu      #$0000
                    beq       LA021
                    ldd       $06,u
                    clra
                    andb      #$03
                    bne       LA027
LA021               ldd       #$FFFF
                    lbra      LA14A

LA027               ldd       $06,u
                    anda      #$80
                    clrb
                    std       -$02,s
                    bne       LA03A
                    pshs      u
                    lbsr      LA539
                    leas      $02,s
                    lbra      LA110

LA03A               ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    beq       LA059
                    pshs      u
                    lbsr      LA2F9
                    leas      $02,s
                    ldd       $06,u
                    anda      #$FE
                    std       $06,u
                    ldd       $02,u
                    addd      $0b,u
                    std       $04,u
                    lbra      LA10E

LA059               ldd       ,u
                    cmpd      $04,u
                    lbcc      LA110
                    leax      $02,s
                    pshs      x
                    leax      $0e,s
                    lbsr      LAEE0
                    ldx       $10,s
                    lbra      LA0DD

LA071               leax      $02,s
                    pshs      x
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    pshs      u
                    lbsr      LA165
                    leas      $02,s
                    lbsr      LAE67
                    lbsr      LAEE0
LA08A               ldd       $0b,u
                    lbsr      LAEC7
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    leax      $06,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    bsr       LA0A7
                    neg       $0000
                    neg       $0000
LA0A7               puls      x
                    lbsr      LAE7C
                    bge       LA0B5
                    leax      $06,s
                    lbsr      LAEA0
                    bra       LA0B7

LA0B5               leax      $06,s
LA0B7               lbsr      LAE7C
                    blt       LA0EA
                    ldd       $04,s
                    addd      ,u
                    std       ,s
                    cmpd      $02,u
                    bcs       LA0EA
                    ldd       ,s
                    cmpd      $04,u
                    bcc       LA0EA
                    ldd       ,s
                    std       ,u
                    ldd       $06,u
                    andb      #$EF
                    std       $06,u
                    lbra      LA148
                    bra       LA0EA

LA0DD               stx       -$02,s
                    lbeq      LA071
                    cmpx      #$0001
                    lbeq      LA08A
LA0EA               ldd       $10,s
                    cmpd      #$0001
                    bne       LA10C
                    leax      $0C,s
                    pshs      x
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $04,u
                    subd      ,u
                    lbsr      LAEC7
                    lbsr      LAE67
                    lbsr      LAEE0
LA10C               ldd       $04,u
LA10E               std       ,u
LA110               ldd       $06,u
                    andb      #$EF
                    std       $06,u
                    ldd       $10,s
                    pshs      d
                    leax      $0e,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      LB1ED
                    leas      $08,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    bsr       $A13C
                    stu       $FFFF
                    stu       L3510
                    lbsr      LAE7C
                    bne       LA148
                    ldd       #$FFFF
                    bra       LA14A

LA148               clra
                    clrb
LA14A               leas      $06,s
                    puls      pc,u
                    pshs      u
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    lbsr      $A00E
                    leas      $08,s
                    puls      pc,u
LA165               pshs      u
                    ldu       $04,s
                    beq       LA172
                    ldd       $06,u
                    clra
                    andb      #$03
                    bne       LA185
LA172               bsr       $A178
                    stu       $FFFF
                    stu       L3510
                    leau      $0358,y
                    pshs      u
                    lbsr      LAEE0
                    puls      pc,u
LA185               ldd       $06,u
                    anda      #$80
                    clrb
                    std       -$02,s
                    bne       LA195
                    pshs      u
                    lbsr      LA539
                    leas      $02,s
LA195               ldd       #$0001
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      LB1ED
                    leas      $08,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    beq       LA1BE
                    ldd       $02,u
                    bra       LA1C0

LA1BE               ldd       $04,u
LA1C0               pshs      d
                    ldd       ,u
                    subd      ,s++
                    lbsr      LAEC7
                    lbsr      LAE52
                    puls      pc,u
LA1CE               pshs      u
                    ldu       $06,s
                    ldd       $06,u
                    anda      #$80
                    andb      #$22
                    cmpd      #$8002
                    beq       LA1F2
                    ldd       $06,u
                    clra
                    andb      #$22
                    cmpd      #$0002
                    lbne      LA30A
                    pshs      u
                    lbsr      LA539
                    leas      $02,s
LA1F2               ldd       $06,u
                    clra
                    andb      #$04
                    beq       LA22E
                    ldd       #$0001
                    pshs      d
                    leax      $07,s
                    pshs      x
                    ldd       $08,u
                    pshs      d
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       LA213
                    leax      LB1DD,pcr
                    bra       LA217

LA213               leax      LB1C4,pcr
LA217               tfr       x,d
                    tfr       d,x
                    jsr       ,x
                    leas      $06,s
                    cmpd      #$FFFF
                    bne       LA26F
                    ldd       $06,u
                    orb       #$20
                    std       $06,u
                    lbra      LA30A

LA22E               ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       LA23E
                    pshs      u
                    lbsr      LA327
                    leas      $02,s
LA23E               ldd       ,u
                    addd      #$0001
                    std       ,u
                    subd      #$0001
                    tfr       d,x
                    ldd       $04,s
                    stb       ,x
                    ldd       ,u
                    cmpd      $04,u
                    bcc       LA264
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       LA26F
                    ldd       $04,s
                    cmpd      #$000D
                    bne       LA26F
LA264               pshs      u
                    lbsr      LA327
                    std       ,s++
                    lbne      LA30A
LA26F               ldd       $04,s
                    puls      pc,u
                    pshs      u
                    ldu       $04,s
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    ldd       #$0008
                    lbsr      LB076
                    pshs      d
                    lbsr      LA1CE
                    leas      $04,s
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    lbsr      LA1CE
                    lbra      LA3E1

LA296               pshs      u,d
                    leau      $0246,y
                    clra
                    clrb
                    std       ,s
                    bra       LA2AC

LA2A2               tfr       u,d
                    leau      $0d,u
                    pshs      d
                    bsr       LA2BF
                    leas      $02,s
LA2AC               ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    cmpd      #$0010
                    blt       LA2A2
                    lbra      LA323

LA2BF               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    cmpu      #$0000
                    beq       LA2CF
                    ldd       $06,u
                    bne       LA2D5
LA2CF               ldd       #$FFFF
                    lbra      LA323

LA2D5               ldd       $06,u
                    clra
                    andb      #$02
                    beq       LA2E4
                    pshs      u
                    bsr       LA2F9
                    leas      $02,s
                    bra       LA2E6

LA2E4               clra
                    clrb
LA2E6               std       ,s
                    ldd       $08,u
                    pshs      d
                    lbsr      LB126
                    leas      $02,s
                    clra
                    clrb
                    std       $06,u
                    ldd       ,s
                    bra       LA323

LA2F9               pshs      u
                    ldu       $04,s
                    beq       LA30A
                    ldd       $06,u
                    clra
                    andb      #$22
                    cmpd      #$0002
                    beq       LA30F
LA30A               ldd       #$FFFF
                    puls      pc,u
LA30F               ldd       $06,u
                    anda      #$80
                    clrb
                    std       -$02,s
                    bne       LA31F
                    pshs      u
                    lbsr      LA539
                    leas      $02,s
LA31F               pshs      u
                    bsr       LA327
LA323               leas      $02,s
                    puls      pc,u
LA327               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       LA359
                    ldd       ,u
                    cmpd      $04,u
                    beq       LA359
                    clra
                    clrb
                    pshs      d
                    pshs      u
                    lbsr      LA165
                    leas      $02,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      LB1ED
                    leas      $08,s
LA359               ldd       ,u
                    subd      $02,u
                    std       $02,s
                    lbeq      LA3D1
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    lbeq      LA3D1
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       LA3A8
                    ldd       $02,u
                    bra       LA3A0

LA379               ldd       $02,s
                    pshs      d
                    ldd       ,u
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      LB1DD
                    leas      $06,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       LA396
                    leax      $04,s
                    bra       LA3C0

LA396               ldd       $02,s
                    subd      ,s
                    std       $02,s
                    ldd       ,u
                    addd      ,s
LA3A0               std       ,u
                    ldd       $02,s
                    bne       LA379
                    bra       LA3D1

LA3A8               ldd       $02,s
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      LB1C4
                    leas      $06,s
                    cmpd      $02,s
                    beq       LA3D1
                    bra       LA3C2

LA3C0               leas      -$04,x
LA3C2               ldd       $06,u
                    orb       #$20
                    std       $06,u
                    ldd       $04,u
                    std       ,u
                    ldd       #$FFFF
                    bra       LA3E1

LA3D1               ldd       $06,u
                    ora       #$01
                    std       $06,u
                    ldd       $02,u
                    std       ,u
                    addd      $0b,u
                    std       $04,u
                    clra
                    clrb
LA3E1               leas      $04,s
                    puls      pc,u
LA3E5               pshs      u
                    ldu       $04,s
                    beq       LA431
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       LA431
                    ldd       ,u
                    cmpd      $04,u
                    bcc       LA40D
                    ldd       ,u
                    addd      #$0001
                    std       ,u
                    subd      #$0001
                    tfr       d,x
                    ldb       ,x
                    clra
                    lbra      LA537

LA40D               pshs      u
                    lbsr      LA480
                    lbra      LA535
                    pshs      u
                    ldu       $06,s
                    beq       LA431
                    ldd       $06,u
                    clra
                    andb      #$01
                    beq       LA431
                    ldd       $04,s
                    cmpd      #$FFFF
                    beq       LA431
                    ldd       ,u
                    cmpd      $02,u
                    bhi       LA436
LA431               ldd       #$FFFF
                    puls      pc,u
LA436               ldd       ,u
                    addd      #$FFFF
                    std       ,u
                    tfr       d,x
                    ldd       $04,s
                    stb       ,x
                    ldd       $04,s
                    puls      pc,u
                    pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    pshs      u
                    lbsr      LA3E5
                    leas      $02,s
                    std       $02,s
                    cmpd      #$FFFF
                    beq       LA46B
                    pshs      u
                    lbsr      LA3E5
                    leas      $02,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       LA470
LA46B               ldd       #$FFFF
                    bra       LA47C

LA470               ldd       $02,s
                    pshs      d
                    ldd       #$0008
                    lbsr      LB08D
                    addd      ,s
LA47C               leas      $04,s
                    puls      pc,u
LA480               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    ldd       $06,u
                    anda      #$80
                    andb      #$31
                    cmpd      #$8001
                    beq       LA4A6
                    ldd       $06,u
                    clra
                    andb      #$31
                    cmpd      #$0001
                    lbne      LA51F
                    pshs      u
                    lbsr      LA539
                    leas      $02,s
LA4A6               leax      $0246,y
                    pshs      x
                    cmpu      ,s++
                    bne       LA4C3
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       LA4C3
                    leax      $0253,y
                    pshs      x
                    lbsr      LA2F9
                    leas      $02,s
LA4C3               ldd       $06,u
                    clra
                    andb      #$08
                    beq       LA4EF
                    ldd       $0b,u
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       LA4E3
                    leax      LB1B4,pcr
                    bra       LA4E7

LA4E3               leax      LB193,pcr
LA4E7               tfr       x,d
                    tfr       d,x
                    jsr       ,x
                    bra       LA501

LA4EF               ldd       #$0001
                    pshs      d
                    leax      $0a,u
                    stx       $02,u
                    pshs      x
                    ldd       $08,u
                    pshs      d
                    lbsr      LB193
LA501               leas      $06,s
                    std       ,s
                    ldd       ,s
                    bgt       LA524
                    ldd       $06,u
                    pshs      d
                    ldd       $02,s
                    beq       LA516
                    ldd       #$0020
                    bra       LA519

LA516               ldd       #$0010
LA519               ora       ,s+
                    orb       ,s+
                    std       $06,u
LA51F               ldd       #$FFFF
                    bra       LA535

LA524               ldd       $02,u
                    addd      #$0001
                    std       ,u
                    ldd       $02,u
                    addd      ,s
                    std       $04,u
                    ldb       [$02,u]
                    clra
LA535               leas      $02,s
LA537               puls      pc,u
LA539               pshs      u
                    ldu       $04,s
                    ldd       $06,u
                    clra
                    andb      #$C0
                    bne       LA571
                    leas      -$20,s
                    leax      ,s
                    pshs      x
                    ldd       $08,u
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    lbsr      LB0A8
                    leas      $06,s
                    ldd       $06,u
                    pshs      d
                    ldb       $02,s
                    bne       LA565
                    ldd       #$0040
                    bra       LA568

LA565               ldd       #$0080
LA568               ora       ,s+
                    orb       ,s+
                    std       $06,u
                    leas      $20,s
LA571               ldd       $06,u
                    ora       #$80
                    std       $06,u
                    clra
                    andb      #$0C
                    beq       LA57E
                    puls      pc,u
LA57E               ldd       $0b,u
                    bne       LA593
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       LA58E
                    ldd       #$0080
                    bra       LA591

LA58E               ldd       #$0100
LA591               std       $0b,u
LA593               ldd       $02,u
                    bne       LA5A8
                    ldd       $0b,u
                    pshs      d
                    lbsr      LB2AB
                    leas      $02,s
                    std       $02,u
                    cmpd      #$FFFF
                    beq       LA5B0
LA5A8               ldd       $06,u
                    orb       #$08
                    std       $06,u
                    bra       LA5BF

LA5B0               ldd       $06,u
                    orb       #$04
                    std       $06,u
                    leax      $0a,u
                    stx       $02,u
                    ldd       #$0001
                    std       $0b,u
LA5BF               ldd       $02,u
                    addd      $0b,u
                    std       $04,u
                    std       ,u
                    puls      pc,u
                    pshs      u
                    ldu       $04,s
LA5CD               ldb       ,u+
                    bne       LA5CD
                    tfr       u,d
                    subd      $04,s
                    addd      #$FFFF
                    puls      pc,u
                    pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
LA5E4               ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       LA5E4
                    bra       LA619
                    pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
LA5FC               ldx       ,s
                    leax      $01,x
                    stx       ,s
                    ldb       -$01,x
                    bne       LA5FC
                    ldd       ,s
                    addd      #$FFFF
                    std       ,s
LA60D               ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       LA60D
LA619               ldd       $06,s
                    leas      $02,s
                    puls      pc,u
                    pshs      u
                    ldu       $04,s
                    bra       LA635

LA625               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    bne       LA633
                    clra
                    clrb
                    puls      pc,u
LA633               leau      $01,u
LA635               ldb       ,u
                    sex
                    pshs      d
                    ldb       [$08,s]
                    sex
                    cmpd      ,s++
                    beq       LA625
                    ldb       [$06,s]
                    sex
                    pshs      d
                    ldb       ,u
                    sex
                    subd      ,s++
                    puls      pc,u
                    pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
LA65A               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    subd      #$FFFF
                    ble       LA67E
                    ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       LA65A
                    bra       LA67E

LA674               clra
                    clrb
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
LA67E               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    subd      #$FFFF
                    bgt       LA674
                    lbra      LA70D
                    pshs      u
                    ldu       $04,s
                    bra       LA6A3

LA693               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    bne       LA6A1
                    clra
                    clrb
                    puls      pc,u
LA6A1               leau      $01,u
LA6A3               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    ble       LA6BD
                    ldb       ,u
                    sex
                    pshs      d
                    ldb       [$08,s]
                    sex
                    cmpd      ,s++
                    beq       LA693
LA6BD               ldd       $08,s
                    bge       LA6C5
                    clra
                    clrb
                    bra       LA6D0

LA6C5               ldb       [$06,s]
                    sex
                    pshs      d
                    ldb       ,u
                    sex
                    subd      ,s++
LA6D0               puls      pc,u
                    pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
LA6DC               ldx       ,s
                    leax      $01,x
                    stx       ,s
                    ldb       -$01,x
                    bne       LA6DC
                    ldd       ,s
                    addd      #$FFFF
                    std       ,s
LA6ED               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    subd      #$FFFF
                    ble       LA705
                    ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       LA6ED
LA705               ldd       $0a,s
                    bge       LA70D
                    clra
                    clrb
                    stb       [,s]
LA70D               ldd       $06,s
                    leas      $02,s
                    puls      pc,u
                    pshs      u
                    ldu       $04,s
LA717               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    stb       ,u+
                    bgt       LA717
                    ldb       -$01,u
                    clra
                    andb      #$7f
                    stb       -$01,u
                    clra
                    clrb
                    stb       ,u
                    ldd       $04,s
                    puls      pc,u
                    ldx       $02,s
                    lbsr      LAE0E
                    bsr       LA73A
                    rts

LA73A               pshs      u
                    leas      -$1e,s
                    tfr       s,u
                    clr       $1d,u
                    clr       $19,u
                    lbsr      LA9B4
                    lbra      LA7D9
                    ldd       ,x
                    eora      #$80
                    lbra      LAD72
                    lbsr      LABCC
                    lbsr      LA8AE
                    lbra      LA7D9
                    lbsr      LABCC
                    lbsr      LA884
                    lbra      LA7D9
                    lbsr      LABCC
                    lbsr      LAA27
                    bra       LA7D9
                    lbsr      LABCC
                    lbsr      LAA53
                    bra       LA7D9

LA776               lbsr      LAD70
                    lbra      LAC70
                    bsr       LA776
                    ldd       $02,x
LA780               rts
                    ldd       ,x
                    std       $0358,y
                    ldd       $02,x
                    leax      $0358,y
                    std       $02,x
                    lbra      LAC10
                    leax      $0358,y
                    std       $02,x
                    tfr       a,b
                    sex
                    tfr       a,b
                    std       ,x
                    lbra      LAC10
                    leax      $0358,y
                    std       $02,x
                    clr       ,x
                    clr       $01,x
                    lbra      LAC10
                    ldd       ,x
                    std       $0358,y
                    lda       $02,x
                    ldb       $07,x
                    leax      $0358,y
                    std       $02,x
                    rts
                    ldd       ,x
                    std       $0358,y
                    ldd       $02,x
                    leax      $0358,y
                    sta       $02,x
                    stb       $07,x
                    clr       $03,x
                    clr       $04,x
                    clr       $05,x
                    clr       $06,x
                    rts

LA7D9               leax      $0358,y
                    ldd       $22,u
                    std       ,x
                    ldd       $24,u
                    std       $02,x
                    ldd       $26,u
                    std       $04,x
                    ldd       $28,u
                    std       $06,x
                    leas      $1e,u
                    puls      u
                    puls      d
                    std       $06,s
                    leas      $06,s
                    rts
                    lda       $02,s
                    eora      ,x
                    bmi       LA86C
                    lda       $02,s
                    bmi       LA83F
                    lda       $09,s
                    beq       LA838
                    ldb       $07,x
                    beq       LA870
                    cmpa      $07,x
                    bne       LA843
                    ldd       $02,s
                    cmpd      ,x
                    bne       LA843
                    ldd       $04,s
                    cmpd      $02,x
                    bne       LA843
                    ldd       $06,s
                    cmpd      $04,x
                    bne       LA843
                    lda       $08,s
                    anda      #$FE
                    pshs      a
                    ldb       $06,x
                    andb      #$FE
                    cmpa      ,s+
                    bne       LA843
                    bra       LA874

LA838               lda       $07,x
                    bne       LA87F
                    clra
                    bra       LA874

LA83F               lda       $07,x
                    cmpa      $09,s
LA843               bhi       LA870
                    bcs       LA87F
                    ldd       ,x
                    cmpd      $02,s
                    bne       LA843
                    ldd       $02,x
                    cmpd      $04,s
                    bne       LA843
                    ldd       $04,x
                    cmpd      $06,s
                    bne       LA843
                    lda       $06,x
                    anda      #$FE
                    pshs      a
                    lda       $08,s
                    anda      #$FE
                    cmpa      ,s+
                    bne       LA843
                    bra       LA874

LA86C               lda       ,x
                    bpl       LA87F
LA870               lda       #$01
                    andcc     #$FE
LA874               pshs      cc
                    ldd       $01,s
                    std       $09,s
                    puls      cc
                    leas      $08,s
                    rts

LA87F               clra
                    cmpa      #$01
                    bra       LA874

LA884               lda       $17,u
                    beq       LA8A5
                    ldb       $1C,u
                    eorb      #$80
                    stb       $1C,u
                    eorb      $18,u
                    stb       $19,u
                    ldb       $29,u
                    bne       LA8B7
                    lbsr      LAD40
                    lda       $22,u
                    lbra      LA9F7

LA8A5               lda       $22,u
                    ldb       $18,u
                    lbra      LA9FA

LA8AE               lbeq      LAD40
                    lda       $17,u
                    beq       LA8A5
LA8B7               suba      $29,u
                    beq       LA8E8
                    sta       ,u
                    bcs       LA8EE
                    ldb       $17,u
                    stb       $29,u
                    ldd       $22,u
LA8C9               lsra
                    rorb
                    ror       $24,u
                    ror       $25,u
                    ror       $26,u
                    ror       $27,u
                    ror       $28,u
                    dec       ,u
                    bne       LA8C9
                    std       $22,u
LA8E1               lda       $19,u
                    bmi       LA95D
                    bra       LA90E

LA8E8               inc       ,u
                    orcc      #$01
                    bra       LA8E1

LA8EE               ldd       $10,u
LA8F1               lsra
                    rorb
                    ror       $12,u
                    ror       $13,u
                    ror       $14,u
                    ror       $15,u
                    ror       $16,u
                    inc       ,u
                    bne       LA8F1
                    std       $10,u
                    lda       $19,u
                    bmi       LA960
LA90E               ldd       $27,u
                    adcb      $16,u
                    adca      $15,u
                    std       $27,u
                    ldd       $25,u
                    adcb      $14,u
                    adca      $13,u
                    std       $25,u
                    ldb       $24,u
                    adcb      $12,u
                    stb       $24,u
                    ldd       $22,u
                    adcb      $11,u
                    adca      $10,u
                    std       $22,u
                    bcc       LA955
                    inc       $29,u
                    ror       $22,u
                    ror       $23,u
                    ror       $24,u
                    ror       $25,u
                    ror       $26,u
                    ror       $27,u
                    ror       $28,u
LA955               lda       $1C,u
                    sta       $19,u
                    bra       LA9B4

LA95D               rola
                    coma
                    asra
LA960               ldd       $27,u
                    sbcb      $16,u
                    sbca      $15,u
                    std       $27,u
                    ldd       $25,u
                    sbcb      $14,u
                    sbca      $13,u
                    std       $25,u
                    ldd       $23,u
                    sbcb      $12,u
                    sbca      $11,u
                    std       $23,u
                    lda       $22,u
                    sbca      $10,u
                    sta       $22,u
                    lda       $18,u
                    bcc       LA9B1
                    com       $22,u
                    com       $23,u
                    com       $24,u
                    com       $25,u
                    com       $26,u
                    com       $27,u
                    com       $28,u
                    lda       ,u
                    beq       LA9AE
                    lbsr      LACFD
LA9AE               lda       $1C,u
LA9B1               sta       $19,u
LA9B4               clr       ,u
LA9B6               lda       $22,u
                    bmi       LA9F7
                    ora       $23,u
                    ora       $24,u
                    ora       $25,u
                    ora       $26,u
                    ora       $27,u
                    ora       $28,u
                    beq       LAA0B
                    ldd       $22,u
LA9D2               dec       $29,u
                    bne       LA9DA
                    dec       $1d,u
LA9DA               asl       ,u
                    rol       $28,u
                    rol       $27,u
                    rol       $26,u
                    rol       $25,u
                    rol       $24,u
                    rolb
                    rola
                    bpl       LA9D2
                    stb       $23,u
                    ldb       $29,u
                    beq       LAA0F
LA9F7               ldb       $19,u
LA9FA               anda      #$7f
                    andb      #$80
                    pshs      b
                    adda      ,s+
                    sta       $22,u
                    tst       $1d,u
                    bne       LAA0F
LAA0A               rts

LAA0B               sta       $29,u
                    rts

LAA0F               lda       $1d,u
                    ldb       $29,u
                    subd      #$0000
                    beq       LAA22
                    bmi       LAA22
LAA1C               ldd       #$0028
                    lbra      LB099

LAA22               lbsr      LAA4D
                    bra       LAA1C

LAA27               beq       LAA4D
                    lda       $17,u
                    beq       LAA4D
                    lbsr      LAAC9
                    clra
                    ldb       $29,u
                    addb      $17,u
                    adca      #$00
                    subd      #$0080
                    stb       $29,u
                    sta       $1d,u
                    lbsr      LA9B6
                    lda       ,u
                    bpl       LAA0A
                    lbra      LACFD

LAA4D               clra
                    sta       $29,u
                    bra       LAAB3

LAA53               ldb       $17,u
                    bne       LAA5E
                    ldd       #$0029
                    lbra      LB099

LAA5E               tsta
                    beq       LAA4D
                    lbsr      LAB27
                    clra
                    ldb       $29,u
                    subb      $17,u
                    sbca      #$00
                    addd      #$0081
                    sta       $1d,u
                    stb       $29,u
                    lda       $06,u
                    coma
                    asra
                    ror       $22,u
                    ror       $23,u
                    ror       $24,u
                    ror       $25,u
                    ror       $26,u
                    ror       $27,u
                    ror       $28,u
                    ror       ,u
                    lbsr      LA9B6
                    lda       ,u
                    bpl       LAAC8
                    lbra      LACFD

LAA9B               pshs      a
                    ldd       $22,u
                    std       ,u
                    ldd       $24,u
                    std       $02,u
                    ldd       $26,u
                    std       $04,u
                    ldb       $28,u
                    stb       $06,u
                    puls      a
LAAB3               sta       $22,u
                    sta       $23,u
                    sta       $24,u
                    sta       $25,u
                    sta       $26,u
                    sta       $27,u
                    sta       $28,u
LAAC8               rts

LAAC9               clra
                    bsr       LAA9B
                    ldb       #$38
                    stb       $08,u
LAAD0               lda       $06,u
                    lsra
                    bcc       LAAFF
                    ldd       $27,u
                    addd      $15,u
                    std       $27,u
                    ldd       $25,u
                    adcb      $14,u
                    adca      $13,u
                    std       $25,u
                    ldd       $23,u
                    adcb      $12,u
                    adca      $11,u
                    std       $23,u
                    lda       $22,u
                    adca      $10,u
                    sta       $22,u
LAAFF               ror       $22,u
                    ror       $23,u
                    ror       $24,u
                    ror       $25,u
                    ror       $26,u
                    ror       $27,u
                    ror       $28,u
                    ror       ,u
                    ror       $01,u
                    ror       $02,u
                    ror       $03,u
                    ror       $04,u
                    ror       $05,u
                    ror       $06,u
                    dec       $08,u
                    bne       LAAD0
                    rts

LAB27               clra
                    lbsr      LAA9B
                    ldb       #$39
                    stb       $08,u
LAB2F               ldb       ,u
                    cmpb      $10,u
                    bcs       LAB66
                    ldd       $05,u
                    subd      $15,u
                    std       $0d,u
                    ldd       $03,u
                    sbcb      $14,u
                    sbca      $13,u
                    std       $0b,u
                    ldb       $02,u
                    sbcb      $12,u
                    stb       $0a,u
                    ldd       ,u
                    sbcb      $11,u
                    sbca      $10,u
                    bcs       LAB66
                    std       ,u
                    lda       $0a,u
                    sta       $02,u
                    ldd       $0b,u
                    std       $03,u
                    ldd       $0d,u
                    std       $05,u
LAB66               rol       $28,u
                    rol       $27,u
                    rol       $26,u
                    rol       $25,u
                    rol       $24,u
                    rol       $23,u
                    rol       $22,u
                    rol       $06,u
                    rol       $05,u
                    rol       $04,u
                    rol       $03,u
                    rol       $02,u
                    rol       $01,u
                    rol       ,u
                    dec       $08,u
                    bhi       LAB2F
                    beq       LABB4
                    ldd       $05,u
                    subd      $15,u
                    std       $05,u
                    ldd       $03,u
                    sbcb      $14,u
                    sbca      $13,u
                    std       $03,u
                    ldd       $01,u
                    sbcb      $12,u
                    sbca      $11,u
                    std       $01,u
                    lda       ,u
                    sbca      $10,u
                    sta       ,u
                    clra
                    bra       LAB66

LABB4               ror       ,u
                    com       $22,u
                    com       $23,u
                    com       $24,u
                    com       $25,u
                    com       $26,u
                    com       $27,u
                    com       $28,u
                    rts

LABCC               puls      d
                    pshs      u
                    leas      -$1e,s
                    tfr       s,u
                    pshs      d
                    clr       $1d,u
                    ldd       $06,x
                    std       $16,u
                    ldd       $04,x
                    std       $14,u
                    ldd       $02,x
                    std       $12,u
                    ldd       ,x
                    stb       $11,u
                    tfr       a,b
                    sta       $1C,u
                    ora       #$80
                    sta       $10,u
                    eorb      $22,u
                    stb       $19,u
                    lda       $22,u
                    sta       $18,u
                    ora       #$80
                    sta       $22,u
                    lda       $29,u
                    rts
                    leax      $22,u
LAC10               lda       #$A0
                    sta       $07,x
                    clr       $04,x
                    clr       $05,x
                    clr       $06,x
                    lda       ,x
                    tfr       a,b
                    orb       $01,x
                    orb       $02,x
                    orb       $03,x
                    beq       LAC5C
                    ldb       $01,x
                    tsta
                    bpl       LAC3E
                    pshs      d
                    clra
                    clrb
                    subd      $02,x
                    std       $02,x
                    ldd       #$0000
                    sbcb      $01,s
                    sbca      ,s
                    leas      $02,s
                    bvs       LAC48
LAC3E               dec       $07,x
                    asl       $03,x
                    rol       $02,x
                    rolb
                    rola
                    bpl       LAC3E
LAC48               anda      #$7f
                    tst       ,x
                    bpl       LAC50
                    ora       #$80
LAC50               std       ,x
                    rts
                    leax      $22,u
                    clr       $04,x
                    clr       $05,x
                    clr       $06,x
LAC5C               clr       $07,x
LAC5E               clr       ,x
                    clr       $01,x
                    clr       $02,x
                    clr       $03,x
                    rts

LAC67               ldd       #$002A
                    lbra      LB099
                    leax      $22,u
LAC70               ldb       $07,x
                    beq       LAC5E
                    subb      #$81
                    bcs       LACEF
                    negb
                    addb      #$1f
                    bmi       LAC67
                    bne       LAC94
                    ldd       ,x
                    cmpd      #$8000
                    bne       LAC67
                    lda       $02,x
                    ora       $03,x
                    ora       $04,x
                    ora       $05,x
                    ora       $06,x
                    bne       LAC67
                    rts

LAC94               pshs      b
                    ldd       ,x
                    bmi       LACAA
                    ora       #$80
LAC9C               lsra
                    rorb
                    ror       $02,x
                    ror       $03,x
                    dec       ,s
                    bne       LAC9C
                    std       ,x
                    puls      pc,b
LACAA               clr       ,-s
LACAC               lsra
                    rorb
                    ror       $02,x
                    ror       $03,x
                    ror       $04,x
                    ror       $05,x
                    ror       $06,x
                    bcc       LACBC
                    inc       ,s
LACBC               dec       $01,s
                    bne       LACAC
                    std       ,x
                    ldd       ,s++
                    bne       LACCE
                    lda       $04,x
                    ora       $05,x
                    ora       $06,x
                    beq       LACDF
LACCE               ldd       $02,x
                    addd      #$0001
                    std       $02,x
                    ldd       ,x
                    adcb      #$00
                    adca      #$00
                    bcs       LAC67
                    std       ,x
LACDF               clra
                    clrb
                    subd      $02,x
                    std       $02,x
                    ldd       #$0000
                    sbcb      $01,x
                    sbca      ,x
                    std       ,x
                    rts

LACEF               lda       ,x
                    lbpl      LAC5E
                    ldd       #$FFFF
                    std       $02,x
                    std       ,x
                    rts

LACFD               inc       $28,u
                    bne       LAD33
                    inc       $27,u
                    bne       LAD33
                    inc       $26,u
                    bne       LAD33
                    inc       $25,u
                    bne       LAD33
                    inc       $24,u
                    bne       LAD33
                    inc       $23,u
                    bne       LAD33
                    ldb       $22,u
                    tfr       b,a
                    anda      #$7f
                    inca
                    bpl       LAD2A
                    inc       $29,u
                    anda      #$7f
LAD2A               andb      #$80
                    pshs      b
                    adda      ,s+
                    sta       $22,u
LAD33               rts

LAD34               neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0081
                    leax      >LAD34,pcr
LAD40               pshs      a
                    ldd       ,x
                    std       $22,u
                    ldd       $02,x
                    std       $24,u
                    ldd       $04,x
                    std       $26,u
                    ldd       $06,x
                    std       $28,u
                    puls      pc,a
LAD58               pshs      a
                    ldd       $22,u
                    std       ,x
                    ldd       $24,u
                    std       $02,x
                    ldd       $26,u
                    std       $04,x
                    ldd       $28,u
                    std       $06,x
                    puls      pc,a
LAD70               ldd       ,x
LAD72               std       $0358,y
                    ldd       $02,x
                    std       $035a,y
                    ldd       $04,x
                    std       $035C,y
                    ldd       $06,x
                    leax      $0358,y
                    std       $06,x
                    rts
                    pshs      x
                    bsr       LAE0E
                    leax      LAD34,pcr
                    pshs      x
                    lbsr      LABCC
                    lbsr      LA8AE
LAD9A               ldx       $2a,u
                    bsr       LAD58
                    ldx       $1e,u
                    leas      $2a,u
                    tfr       x,u
                    puls      pc,x
                    pshs      x
                    bsr       LAE0E
                    leax      >LAD34,pcr
                    pshs      x
                    lbsr      LABCC
                    lbsr      LA884
                    bra       LAD9A
                    pshs      x
                    bsr       LADF7
                    leax      LAD34,pcr
                    pshs      x
                    lbsr      LABCC
                    lbsr      LA8AE
LADCB               ldx       $2a,u
                    ldd       $22,u
                    std       ,x
                    lda       $24,u
                    ldb       $29,u
                    std       $02,x
                    ldx       $1e,u
                    leas      $2a,u
                    tfr       x,u
                    puls      pc,x
                    pshs      x
                    bsr       LADF7
                    leax      LAD34,pcr
                    pshs      x
                    lbsr      LABCC
                    lbsr      LA884
                    bra       LADCB

LADF7               leas      -$08,s
                    ldd       $08,s
                    std       ,s
                    clra
                    clrb
                    std       $05,s
                    std       $07,s
                    ldd       ,x
                    std       $02,s
                    ldd       $02,x
                    sta       $04,s
                    stb       $09,s
LAE0D               rts

LAE0E               leas      -$08,s
                    ldd       $08,s
                    std       ,s
                    ldd       ,x
                    std       $02,s
                    ldd       $02,x
                    std       $04,s
                    ldd       $04,x
                    std       $06,s
                    ldd       $06,x
                    std       $08,s
LAE24               rts
                    pshs      u
                    ldu       $04,s
                    exg       x,u
                    ldd       ,u
                    std       ,x
                    ldd       $02,u
                    std       $02,x
                    bra       LAE4B
                    pshs      u
                    ldu       $04,s
                    exg       x,u
                    ldd       ,u
                    std       ,x
                    ldd       $02,u
                    std       $02,x
                    ldd       $04,u
                    std       $04,x
                    ldd       $06,u
                    std       $06,x
LAE4B               puls      u
                    puls      d
                    std       ,s
LAE51               rts

LAE52               ldd       $04,s
                    addd      $02,x
                    std       $035a,y
                    ldd       $02,s
                    adcb      $01,x
                    adca      ,x
                    std       $0358,y
                    lbra      LAF2E

LAE67               ldd       $04,s
                    subd      $02,x
                    std       $035a,y
                    ldd       $02,s
                    sbcb      $01,x
                    sbca      ,x
                    std       $0358,y
                    lbra      LAF2E

LAE7C               ldd       $02,s
                    cmpd      ,x
                    bne       LAE95
                    ldd       $04,s
                    cmpd      $02,x
                    beq       LAE95
                    bcs       LAE92
                    lda       #$01
                    andcc     #$FE
                    bra       LAE95

LAE92               clra
                    cmpa      #$01
LAE95               pshs      cc
                    ldd       $01,s
                    std       $05,s
                    puls      cc
                    leas      $04,s
LAE9F               rts

LAEA0               lbsr      LAF3D
                    ldd       #$0000
                    subd      $02,x
                    std       $02,x
                    ldd       #$0000
                    sbcb      $01,x
                    sbca      ,x
                    std       ,x
LAEB3               rts
                    ldd       ,x
                    coma
                    comb
                    std       $0358,y
                    ldd       $02,x
                    coma
                    comb
                    leax      $0358,y
                    std       $02,x
LAEC6               rts

LAEC7               leax      $0358,y
                    std       $02,x
                    tfr       a,b
                    sex
                    tfr       a,b
                    std       ,x
                    rts
                    leax      $0358,y
                    std       $02,x
                    clr       ,x
                    clr       $01,x
LAEDF               rts

LAEE0               pshs      y
                    ldy       $04,s
                    ldd       ,x
                    std       ,y
                    ldd       $02,x
                    std       $02,y
                    puls      x
                    exg       y,x
                    puls      d
                    std       ,s
LAEF5               rts
                    ldx       $02,s
                    pshs      b
                    lbsr      LAF3D
                    puls      b
                    tstb
                    beq       LAF0D
LAF02               asl       $03,x
                    rol       $02,x
                    rol       $01,x
                    rol       ,x
                    decb
                    bne       LAF02
LAF0D               puls      d
                    std       ,s
                    rts
                    ldx       $02,s
                    pshs      b
                    lbsr      LAF3D
                    puls      b
                    tstb
                    beq       LAF29
LAF1E               asr       ,x
                    ror       $01,x
                    ror       $02,x
                    ror       $03,x
                    decb
                    bne       LAF1E
LAF29               puls      d
                    std       ,s
                    rts

LAF2E               tfr       cc,a
                    puls      x
                    stx       $02,s
                    leas      $02,s
                    leax      $0358,y
                    tfr       a,cc
                    rts

LAF3D               ldd       ,x
                    std       $0358,y
                    ldd       $02,x
                    leax      $0358,y
                    std       $02,x
LAF4B               rts
                    tsta
                    bne       LAF61
                    tst       $02,s
                    bne       LAF61
                    lda       $03,s
                    mul
                    ldx       ,s
                    stx       $02,s
                    ldx       #$0000
                    std       ,s
                    puls      pc,d
LAF61               pshs      d
                    ldd       #$0000
                    pshs      d
                    pshs      d
                    lda       $05,s
                    ldb       $09,s
                    mul
                    std       $02,s
                    lda       $05,s
                    ldb       $08,s
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       LAF7E
                    inc       ,s
LAF7E               lda       $04,s
                    ldb       $09,s
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       LAF8B
                    inc       ,s
LAF8B               lda       $04,s
                    ldb       $08,s
                    mul
                    addd      ,s
                    std       ,s
                    ldx       $06,s
                    stx       $08,s
                    ldx       ,s
                    ldd       $02,s
                    leas      $08,s
                    rts
                    clr       $089e,y
                    leax      >LAFE7,pcr
                    stx       $089f,y
                    bra       LAFC1
                    leax      >LB000,pcr
                    stx       $089f,y
                    clr       $089e,y
                    tst       $02,s
                    bpl       LAFC1
                    inc       $089e,y
LAFC1               subd      #$0000
                    bne       LAFCC
                    puls      x
                    ldd       ,s++
                    jmp       ,x

LAFCC               ldx       $02,s
                    pshs      x
                    jsr       [$089f,y]
                    ldd       ,s
                    std       $02,s
                    tfr       x,d
                    tst       $089e,y
                    beq       LAFE4
                    nega
                    negb
                    sbca      #$00
LAFE4               std       ,s++
                    rts

LAFE7               subd      #$0000
                    beq       LAFF6
                    pshs      d
                    leas      -$02,s
                    clr       ,s
                    clr       $01,s
                    bra       LB024

LAFF6               puls      d
                    std       ,s
                    ldd       #$002D
                    lbra      LB099

LB000               subd      #$0000
                    beq       LAFF6
                    pshs      d
                    leas      -$02,s
                    clr       ,s
                    clr       $01,s
                    tsta
                    bpl       LB018
                    nega
                    negb
                    sbca      #$00
                    inc       $01,s
                    std       $02,s
LB018               ldd       $06,s
                    bpl       LB024
                    nega
                    negb
                    sbca      #$00
                    com       $01,s
                    std       $06,s
LB024               lda       #$01
LB026               inca
                    asl       $03,s
                    rol       $02,s
                    bpl       LB026
                    sta       ,s
                    ldd       $06,s
                    clr       $06,s
                    clr       $07,s
LB035               subd      $02,s
                    bcc       LB03F
                    addd      $02,s
                    andcc     #$FE
                    bra       LB041

LB03F               orcc      #$01
LB041               rol       $07,s
                    rol       $06,s
                    lsr       $02,s
                    ror       $03,s
                    dec       ,s
                    bne       LB035
                    std       $02,s
                    tst       $01,s
                    beq       LB05B
                    ldd       $06,s
                    nega
                    negb
                    sbca      #$00
                    std       $06,s
LB05B               ldx       $04,s
                    ldd       $06,s
                    std       $04,s
                    stx       $06,s
                    ldx       $02,s
                    ldd       $04,s
                    leas      $06,s
LB069               rts
                    tstb
                    beq       LB080
LB06D               asr       $02,s
                    ror       $03,s
                    decb
                    bne       LB06D
                    bra       LB080

LB076               tstb
                    beq       LB080
LB079               lsr       $02,s
                    ror       $03,s
                    decb
                    bne       LB079
LB080               ldd       $02,s
                    pshs      d
                    ldd       $02,s
                    std       $04,s
                    ldd       ,s
                    leas      $04,s
LB08C               rts

LB08D               tstb
                    beq       LB080
LB090               asl       $03,s
                    rol       $02,s
                    decb
                    bne       LB090
                    bra       LB080

LB099               std       $0364,y
                    pshs      y,b
                    os9       F$ID
                    puls      y,b
                    os9       F$Send
                    rts

LB0A8               lda       $05,s
                    ldb       $03,s
                    beq       LB0DB
                    cmpb      #$01
                    beq       LB0DD
                    cmpb      #$06
                    beq       LB0DD
                    cmpb      #$02
                    beq       LB0C3
                    cmpb      #$05
                    beq       LB0C3
                    ldb       #$D0
                    lbra      LB33F

LB0C3               pshs      u
                    os9       I$GetStt
                    bcc       LB0CF
                    puls      u
                    lbra      LB33F

LB0CF               stx       [$08,s]
                    ldx       $08,s
                    stu       $02,x
                    puls      u
                    clra
                    clrb
                    rts

LB0DB               ldx       $06,s
LB0DD               os9       I$GetStt
                    lbra      LB348
                    lda       $05,s
                    ldb       $03,s
                    beq       LB0F2
                    cmpb      #$02
                    beq       LB0FA
                    ldb       #$D0
                    lbra      LB33F

LB0F2               ldx       $06,s
                    os9       I$SetStt
                    lbra      LB348

LB0FA               pshs      u
                    ldx       $08,s
                    ldu       $0a,s
                    os9       I$SetStt
                    puls      u
                    lbra      LB348
                    ldx       $02,s
                    lda       $05,s
                    os9       I$Open
                    bcs       LB114
                    os9       I$Close
LB114               lbra      LB348
                    ldx       $02,s
                    lda       $05,s
                    os9       I$Open
                    lbcs      LB33F
                    tfr       a,b
                    clra
                    rts

LB126               lda       $03,s
                    os9       I$Close
                    lbra      LB348
                    ldx       $02,s
                    ldb       $05,s
                    os9       I$MakDir
                    lbra      LB348
                    ldx       $02,s
                    lda       $05,s
                    tfr       a,b
                    andb      #$24
                    orb       #$0b
                    os9       I$Create
                    bcs       LB14B
LB147               tfr       a,b
                    clra
                    rts

LB14B               cmpb      #$DA
                    lbne      LB33F
                    lda       $05,s
                    bita      #$80
                    lbne      LB33F
                    anda      #$07
                    ldx       $02,s
                    os9       I$Open
                    lbcs      LB33F
                    pshs      u,a
                    ldx       #$0000
                    leau      ,x
                    ldb       #$02
                    os9       I$SetStt
                    puls      u,a
                    bcc       LB147
                    pshs      b
                    os9       I$Close
                    puls      b
                    lbra      LB33F
                    ldx       $02,s
                    os9       I$Delete
                    lbra      LB348
                    lda       $03,s
                    os9       I$Dup
                    lbcs      LB33F
                    tfr       a,b
                    clra
                    rts

LB193               pshs      y
                    ldx       $06,s
                    lda       $05,s
                    ldy       $08,s
                    pshs      y
                    os9       I$Read
LB1A1               bcc       LB1B0
                    cmpb      #$D3
                    bne       LB1AB
                    clra
                    clrb
                    puls      pc,y,x
LB1AB               puls      y,x
                    lbra      LB33F

LB1B0               tfr       y,d
                    puls      pc,y,x
LB1B4               pshs      y
                    lda       $05,s
                    ldx       $06,s
                    ldy       $08,s
                    pshs      y
                    os9       I$ReadLn
                    bra       LB1A1

LB1C4               pshs      y
                    ldy       $08,s
                    beq       LB1D9
                    lda       $05,s
                    ldx       $06,s
                    os9       I$Write
LB1D2               bcc       LB1D9
                    puls      y
                    lbra      LB33F

LB1D9               tfr       y,d
                    puls      pc,y
LB1DD               pshs      y
                    ldy       $08,s
                    beq       LB1D9
                    lda       $05,s
                    ldx       $06,s
                    os9       I$WritLn
                    bra       LB1D2

LB1ED               pshs      u
                    ldd       $0a,s
                    bne       LB1FB
                    ldu       #$0000
                    ldx       #$0000
                    bra       LB22F

LB1FB               cmpd      #$0001
                    beq       LB226
                    cmpd      #$0002
                    beq       LB21B
                    ldb       #$F7
LB209               clra
                    std       $0364,y
                    ldd       #$FFFF
                    leax      $0358,y
                    std       ,x
                    std       $02,x
                    puls      pc,u
LB21B               lda       $05,s
                    ldb       #$02
                    os9       I$GetStt
                    bcs       LB209
                    bra       LB22F

LB226               lda       $05,s
                    ldb       #$05
                    os9       I$GetStt
                    bcs       LB209
LB22F               tfr       u,d
                    addd      $08,s
                    std       $035a,y
                    tfr       d,u
                    tfr       x,d
                    adcb      $07,s
                    adca      $06,s
                    bmi       LB209
                    tfr       d,x
                    std       $0358,y
                    lda       $05,s
                    os9       I$Seek
                    bcs       LB209
                    leax      $0358,y
                    puls      pc,u
                    ldd       $0356,y
                    pshs      d
                    ldd       $04,s
                    cmpd      $08A1,y
                    bcs       LB288
                    addd      $0356,y
                    pshs      y
                    subd      ,s
                    os9       F$Mem
                    tfr       y,d
                    puls      y
                    bcc       LB27A
                    ldd       #$FFFF
                    leas      $02,s
                    rts

LB27A               std       $0356,y
                    addd      $08A1,y
                    subd      ,s
                    std       $08A1,y
LB288               leas      $02,s
                    ldd       $08A1,y
                    pshs      d
                    subd      $04,s
                    std       $08A1,y
                    ldd       $0356,y
                    subd      ,s++
                    pshs      d
                    clra
                    ldx       ,s
LB2A1               sta       ,x+
                    cmpx      $0356,y
                    bcs       LB2A1
                    puls      pc,d
LB2AB               ldd       $02,s
                    addd      $0360,y
                    bcs       LB2D4
                    cmpd      $0362,y
                    bcc       LB2D4
                    pshs      d
                    ldx       $0360,y
                    clra
LB2C1               cmpx      ,s
                    bcc       LB2C9
                    sta       ,x+
                    bra       LB2C1

LB2C9               ldd       $0360,y
                    puls      x
                    stx       $0360,y
                    rts

LB2D4               ldd       #$FFFF
                    rts

LB2D8               pshs      y
                    os9       F$ID
                    puls      y
                    bcc       LB2E5
                    lbcs      LB33F
LB2E5               tfr       a,b
                    clra
                    rts

LB2E9               pshs      y
                    os9       F$ID
                    bcc       LB2F5
LB2F0               puls      y
                    lbra      LB33F

LB2F5               tfr       y,d
                    puls      pc,y
                    pshs      y
                    bsr       LB2E9
                    std       -$02,s
                    beq       LB305
                    ldb       #$D6
                    bra       LB2F0

LB305               ldy       $04,s
                    os9       F$SUser
                    bcc       LB319
                    cmpb      #$D0
                    bne       LB2F0
                    tfr       y,d
                    ldy       >$004B
                    std       $09,y
LB319               clra
                    clrb
                    puls      pc,y
                    pshs      u
                    tfr       y,u
                    ldx       $04,s
                    stx       $08A3,y
                    leax      >LB333,pcr
                    os9       F$Icpt
                    puls      u
                    lbra      LB348

LB333               tfr       u,y
                    clra
                    pshs      d
                    jsr       [$08A3,y]
                    leas      $02,s
                    rti

LB33F               clra
                    std       $0364,y
                    ldd       #$FFFF
                    rts

LB348               bcs       LB33F
                    clra
                    clrb
LB34C               rts
                    lbsr      LB358
                    lbsr      LA296
                    ldd       $02,s
                    os9       F$Exit
LB358               rts
                    neg       $0003
                    neg       $0002
                    rora
                    fcb       $02
                    ldx       $0000
                    fcb       $01
                    neg       $0002
                    neg       $0000
                    neg       $0000
                    neg       $000C
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       L008C
                    com       -$0d,s
                    lsr       L722E
                    aslb
                    aslb
                    aslb
                    aslb
                    aslb
                    neg       L0078
                    bra       $B3F1
                    asl       L7065
                    com       -$0C,s
                    fcb       $65
                    lsr       0,x
                    ror       $0083
                    aslb
                    tst       -$08,u
                    neg       $5873
                    aslb
                    rol       L587F
                    aslb
                    anda      #$00
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $006D
                    nega
                    rol       0,x
                    neg       L0054
                    fcb       $41
                    asl       $0d,y
                    bgt       LB40F
                    negb
                    leax      $03,u
                    fcb       $45
                    comb
                    fcb       $6b
                    fcb       $6b
                    fcb       $6b
                    fcb       $6b
                    fcb       $6b
                    fcb       $6b
                    fcb       $6b
                    fcb       $6b
                    fcb       $6b
                    fcb       $6b
                    ble       $B406
                    tstb
                    asl       $5F64
                    neg       L006A
                    dec       $0a,s
                    dec       $0a,s
                    dec       $0a,s
                    dec       $0a,s
                    dec       $0a,s
                    dec       $0a,s
                    dec       $0a,s
                    dec       $0a,s
                    dec       $0a,s
                    dec       $0a,s
                    dec       $0a,s
                    dec       $0a,s
                    dec       $0b,y
                    ror       $0C,y
                    rolb
                    dec       0,x
                    dec       $0a,s
                    dec       $0a,s
                    dec       $0a,s
                    dec       $0a,s
                    dec       $0a,s
                    dec       $0a,s
LB40F               dec       $0a,s
                    dec       $0a,s
                    dec       $0a,s
                    dec       $0a,s
                    dec       $0a,s
                    dec       $0a,s
                    dec       $0a,s
                    bvs       $B477
                    bpl       $B465
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    rol       $0000
                    neg       $0000
                    tst       $000E
                    neg       $0000
                    neg       $000E
                    inc       $0001
                    jmp       $000F
                    tst       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0003
                    neg       $000A
                    fcb       $02
                    dec       $0003
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    asr       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    ror       $0000
                    jmp       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0081
                    bra       LB4AC

LB4AC               neg       $0000
                    neg       $0000
                    neg       L0084
                    asla
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    fcb       $87
                    dec       >$0000
                    neg       $0000
                    neg       $0000
                    ora       #$1C
                    nega
                    neg       $0000
                    neg       $0000
                    neg       L008E
                    coma
                    negb
                    neg       $0000
                    neg       $0000
                    neg       $0091
                    lsr       L2400
                    neg       $0000
                    neg       $0000
                    anda      L0018
                    lda       L0080
                    neg       $0000
                    neg       $0000
                    eora      L003E
                    cmpx      L2000
                    neg       $0000
                    neg       $009B
                    jmp       $0b,s
                    bvc       LB4EE
LB4EE               neg       $0000
                    neg       L009E
                    fcb       $15
                    fcb       $02
                    adcb      >$0000
                    neg       $0000
                    sbca      $0d,y
                    asl       $EBC5
                    cmpx      $02,s
                    neg       $00C3
                    rola
                    sbcb      $C9CD
                    lsr       $0067
                    clra
                    andb      0,x
                    fcb       $02
                    neg       $0004
                    neg       $0008
                    neg       $0010
                    neg       $0020
                    neg       $0040
                    neg       L0080
                    fcb       $01
                    neg       $0002
                    neg       $0004
                    neg       $0008
                    neg       $0010
                    neg       $0020
                    neg       $0040
                    neg       $0027
                    fcb       $10
                    com       $00E8
                    neg       $0064
                    neg       $000A
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0001
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    fcb       $02
                    neg       $0001
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    fcb       $42
                    neg       $0002
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0006
                    neg       L00B8
                    neg       L00B6
                    neg       L00B4
                    neg       L00B2
                    neg       L00B0
                    neg       L00AE
                    neg       $0003
                    neg       L0094
                    neg       L00AC
                    neg       $0001
                    com       $0e,y
                    com       $0f,s
                    tst       -$10,s

                    emod
eom                 equ       *
                    end
