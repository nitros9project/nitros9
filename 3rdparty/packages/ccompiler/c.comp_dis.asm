                    nam       c.comp
                    ttl       program module

                    use       defsfile

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       $05

                    mod       eom,name,tylg,atrv,_start,size

u0000               rmb       4389
size                equ       .

name                equ       *
                    fcs       /c.comp/
                    fcb       edition

copybytes           lda       ,y+
L0016               sta       ,u+
L0018               leax      -$01,x
L001A               bne       copybytes
L001C               rts

_start              pshs      y
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
L003A               bsr       copybytes
L003C               ldu       $02,s
L003E               leau      >$0078,u
L0042               ldx       ,y++
L0044               beq       L0049
L0046               bsr       copybytes
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
                    bsr       stkinit
                    lbsr      main
                    clr       ,-s
                    clr       ,-s
                    lbsr      exit
stkinit             leax      $08A5,y
                    stx       $0360,y
                    sts       $0354,y
                    sts       $0362,y
                    ldd       #$FF82
stkcheck            leax      d,s
                    cmpx      $0362,y
                    bcc       L0121
                    cmpx      $0360,y
                    bcs       L013B
                    stx       $0362,y
L0121               fcb       $39
L0122               fcc       /**** STACK OVERFLOW ****/
                    fcb       $0D
L013B               leax      L0122,pcr
                    ldb       #$CF
                    pshs      b
                    lda       #$02
                    ldy       #$0064
                    os9       I$WritLn
                    clr       ,-s
                    lbsr      LB352
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

main                pshs      u
                    leax      L5DC9,pcr
                    pshs      x
                    lbsr      LB31C
                    leas      $02,s
                    leax      $0096,y
                    pshs      x
                    lbsr      L9FD7
                    leas      $02,s
                    leax      L0300,pcr
                    pshs      x
                    ldd       $0094,y
                    pshs      d
                    lbsr      LA5D9
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
                    lbsr      fprintf
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
                    lbsr      fprintf
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
                    lbsr      L5F26
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
                    leax      L0345,pcr
                    pshs      x
                    lbsr      L042D
                    leas      $02,s
L02CA               leax      $0253,y
                    pshs      x
                    lbsr      LA2F8
                    leas      $02,s
                    ldd       $0009
                    beq       L02F0
                    ldd       $0009
                    pshs      d
                    leax      L0366,pcr
                    pshs      x
                    leax      $0260,y
                    pshs      x
                    lbsr      fprintf
                    leas      $06,s
                    bsr       L02F2
L02F0               puls      pc,u
L02F2               pshs      u
                    ldd       #$0001
                    pshs      d
                    lbsr      exit
                    leas      $02,s
                    puls      pc,u
L0300               clrb
                    fcc       /dummy_/
                    fcb       $00
L0308               asr       >L0063
                    fcb       $61
                    jmp       $07,y
                    lsr       $206F
                    neg       $656E
                    bra       L033B
                    com       $0D00
L0319               fcc       /unknown flag : -%c/
                    fcb       $0D,$00
L032D               fcb       $72
                    neg       L0063
                    fcc       /an't open i/
L033B               fcc       /nput file/
                    fcb       $00
L0345               fcc       /error writing assembly code file/
                    fcb       $00
L0366               fcc       /errors in compilation : %d/
                    fcb       $0D,$00
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
                    lbsr      LA2F8
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
                    lbsr      LA5D9
                    leas      $04,s
                    ldd       $38,s
                    pshs      d
                    leax      $02,s
                    pshs      x
                    lbsr      LA5F1
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
                    lbsr      LA2F8
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
                    lbsr      fprintf
                    leas      $08,s
                    puls      pc,u
L056A               pshs      u
                    leax      $0260,y
                    pshs      x
                    ldd       $06,s
                    pshs      d
                    lbsr      L9FB7
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
                    lbsr      LA1CD
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
                    lbsr      L5F26
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

L0708               lbsr      L5F26
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
L072B               fcc       /multiple definition/
                    fcb       $00
L073F               fcc       /compiler error - /
                    fcb       $00
L0751               fcc       /line %d  /
                    fcb       $00
L075B               bpl       L0787
                    bpl       $0789
                    bra       L0781
                    bcs       $07D6
L0763               bra       L0785
                    bpl       $0791
                    bpl       $0793
                    tst       $0000
L076B               fcb       $5E
                    neg       $0074
                    fcc       /oo many errors - AB/
L0781               fcb       $4F,$52,$54
                    fcb       $00
L0785               pshs      u
L0787               ldd       #$FFA2
                    lbsr      stkcheck
                    leas      -$0e,s
                    lbsr      L0899
                    std       $0C,s
                    lbne      L087E
                    clra
                    clrb
L079A               lbra      L0895
                    lbra      L087E

L07A0               ldd       $003F
                    std       $0a,s
                    ldd       $0041
                    std       $08,s
                    std       ,s
                    ldd       L001F
                    std       $04,s
                    ldd       $0043
                    std       $02,s
                    lbsr      L5F26
                    ldx       $0a,s
                    bra       L07D2

L07B9               ldd       $0a,s
                    cmpd      #$00A0
                    blt       L07C9
                    ldd       $0a,s
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
                    bra       L07B9

L07DE               ldd       ,s
                    pshs      d
                    lbsr      L0785
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
                    lbsr      L0785
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
                    lbsr      stkcheck
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
                    lbsr      L5F26
                    lbra      L0A63

L08D0               lbsr      L5F26
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
                    lbsr      L0785
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
                    lbsr      L5F26
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
                    lbsr      L5F26
                    ldd       $003F
                    cmpd      #$002D
                    bne       L09C8
                    lbsr      L5F26
                    lbsr      L05DF
                    std       -$02,s
                    beq       L09AA
                    lbsr      L0F4C
                    std       $0a,s
                    bra       L09BC

L09AA               clra
                    clrb
                    pshs      d
                    lbsr      L0785
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
                    lbsr      L5F26
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

L0AA4               lbsr      L5F26
                    ldd       #$0002
                    pshs      d
                    lbsr      L0785
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
                    lbsr      L5F26
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
                    lbsr      L5F26
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
                    lbsr      L5F26
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
                    lbsr      stkcheck
                    leas      -$02,s
                    ldu       #$0000
                    bra       L0C08

L0C08               ldd       $003F
                    cmpd      #$002E
                    beq       L0C50
                    ldd       #$0002
                    pshs      d
                    lbsr      L0785
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
                    lbsr      L5F26
                    bra       L0C08

L0C50               tfr       u,d
                    bra       L0C9C

L0C54               pshs      u
                    ldd       #$FFB8
                    lbsr      stkcheck
                    leas      -$02,s
                    ldd       $06,s
                    pshs      d
                    lbsr      L0785
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
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
                    lbsr      LAFFF
                    bra       L0D66

L0D59               ldd       $08,s
                    beq       L0D68
                    ldd       $06,s
                    pshs      d
                    ldd       $0a,s
                    lbsr      LAFAC
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
                    lbsr      stkcheck
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
                    leax      L10FB,pcr
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
                    leax      L110A,pcr
                    pshs      x
                    lbsr      L0450
                    lbra      L107D

L102E               pshs      u
                    ldd       #$FFB6
                    lbsr      stkcheck
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
L109C               fcc       /third expression missing/
                    fcb       $00
L10B5               fcc       /operand expected/
                    fcb       $00
L10C6               fcc       /primary expected/
                    fcb       $00
L10D7               fcc       /constant required/
                    fcb       $00
L10E9               fcc       /constant operator/
                    fcb       $00
L10FB               fcc       /name in a cast/
                    fcb       $00
L110A               fcc       /expression missing/
                    fcb       $00
L111D               pshs      u
                    ldd       #$FFAE
                    lbsr      stkcheck
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
                    std       $08,s
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
                    lbsr      stkcheck
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
                    lbsr      LA74C
                    lbsr      LAE34
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
                    leax      L287A,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
                    puls      pc,u
L1587               pshs      u
                    ldd       #$FF9C
                    lbsr      stkcheck
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
L172C               leax      L28A2,pcr
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
                    leax      L2924,pcr
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
L1FB7               leax      L2932,pcr
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

L203B               leax      L2943,pcr
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
                    lbeq      L16F1
                    cmpx      #$0037
                    lbeq      L1701
                    cmpx      #$0020
                    lbeq      L170C
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
                    lbsr      stkcheck
                    ldu       $04,s
                    ldd       $06,u
                    cmpd      #$0036
                    bne       L21A9
                    ldd       $08,u
                    beq       L21BF
L21A9               leax      L294E,pcr
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
                    lbsr      stkcheck
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

L21F0               leax      L295D,pcr
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
                    lbsr      stkcheck
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
                    lbsr      LA791
                    lbsr      LAE34
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
L2400               lbsr      LAE34
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
                    lbsr      LA77B
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
                    lbsr      LA775
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
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
L26C1               leax      L2968,pcr
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
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
L278B               leax      L298C,pcr
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
                    leax      L29C4,pcr
                    pshs      x
                    ldd       $06,s
                    pshs      d
                    lbsr      L0498
                    leas      $04,s
                    puls      pc,u
L287A               fcc       /divide by zero/
                    fcb       $00
L2889               fcc       /typedef - not a variable/
                    fcb       $00
L28A2               fcc       /cannot cast/
                    fcb       $00
L28AE               fcc       /can't take address/
                    fcb       $00
L28C1               fcc       /pointer required/
                    fcb       $00
L28D2               fcc       /pointer or integer required/
                    fcb       $00
L28EE               fcc       /not a function/
                    fcb       $00
L28FD               fcc       /both must be integral/
                    fcb       $00
L2913               fcc       /pointer mismatch/
                    fcb       $00
L2924               fcc       /type mismatch/
                    fcb       $00
L2932               fcc       /pointer mismatch/
                    fcb       $00
L2943               fcc       /type check/
                    fcb       $00
L294E               fcc       /should be NULL/
                    fcb       $00
L295D               fcc       /type error/
                    fcb       $00
L2968               fcc       /lvalue required/
                    fcb       $00
L2978               fcc       /undeclared variable/
                    fcb       $00
L298C               fcc       /struct member required/
                    fcb       $00
L29A3               fcc       /structure or union inappropriate/
                    fcb       $00
L29C4               fcc       /must be integral/
                    fcb       $00
L29D5               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
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
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
                    lbsr      L5F26
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
                    cmpx      #_start
                    beq       L2A2C
                    cmpx      #$0015
                    beq       L2A32
                    bra       L2A43

L2A86               lbsr      L89B7
                    lbsr      L5F26
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
L2AC0               lbsr      L5F26
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
                    lbra      L2AA7

L2B10               ldd       #$0028
                    pshs      d
                    lbsr      L06C1
                    leas      $02,s
                    puls      pc,u
L2B1C               pshs      u
                    ldd       #$FFAE
                    lbsr      stkcheck
                    leas      -$06,s
                    lbsr      L5F26
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
                    lbsr      L5F26
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
                    lbsr      L5F26
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
                    lbsr      stkcheck
                    leas      -$0a,s
                    ldd       $0033
                    std       $08,s
                    ldd       $0035
                    std       $06,s
                    ldd       $0786,y
                    std       $04,s
                    ldd       $0788,y
                    std       $02,s
                    lbsr      L5F26
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
                    lbsr      stkcheck
                    leas      -$0e,s
                    lbsr      L5F26
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
                    lbsr      L0785
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
                    lbsr      stkcheck
                    leas      -$02,s
                    lbsr      L5F26
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
                    lbsr      stkcheck
                    lbsr      L5F26
                    ldd       $0037
                    bne       L2E6F
                    bsr       L2E9C
L2E6F               ldd       $0784,y
                    beq       L2E80
L2E75               leax      L3435,pcr
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
                    lbsr      stkcheck
                    leax      L3447,pcr
                    pshs      x
                    lbsr      L0450
L2EAD               leas      $02,s
                    puls      pc,u
L2EB1               pshs      u
                    ldd       #$FFAA
                    lbsr      stkcheck
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
                    lbsr      L5F26
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
L2F11               leax      L345B,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
L2F1C               lbsr      L5F26
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
                    lbsr      stkcheck
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
                    lbsr      L5F26
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
                    lbsr      L0785
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
                    lbsr      stkcheck
                    lbsr      L5F26
                    ldd       $003F
                    cmpd      #$0028
                    lbeq      L3197
                    clra
                    clrb
                    pshs      d
                    lbsr      L0785
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
                    lbsr      L3987
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
                    lbsr      stkcheck
                    lbsr      L5F26
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
                    lbsr      stkcheck
                    lbsr      L5F26
                    ldd       $0035
                    bne       L3213
                    leax      L3476,pcr
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
                    lbsr      stkcheck
                    lbsr      L5F26
                    ldd       $003F
                    cmpd      #$0034
                    beq       L3255
                    leax      L3485,pcr
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
                    ldd       #_start
                    pshs      d
                    lbsr      L4623
                    leas      $06,s
                    ldd       $0a,u
                    orb       #$02
                    std       $0a,u
L3276               lbsr      L5F26
L3279               ldd       #_start
L327C               std       $002F
                    puls      pc,u
L3280               pshs      u
                    ldd       #$FFB6
                    lbsr      stkcheck
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
L32BA               lbsr      L5F26
                    lbsr      L5F26
                    puls      pc,u
L32C2               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
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
                    lbsr      stkcheck
                    ldd       $04,s
                    pshs      d
                    lbsr      L0785
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
                    clra
                    clrb
                    pshs      d
                    lbsr      L0785
                    std       ,s
                    lbsr      L111D
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    beq       L33C8
                    pshs      u
                    lbsr      L26D8
                    bra       L33D1

L33C8               leax      L34AD,pcr
                    pshs      x
                    lbsr      L0450
L33D1               leas      $02,s
L33D3               tfr       u,d
                    puls      pc,u
L33D7               pshs      u
                    ldd       #$FFB4
                    lbsr      stkcheck
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
L3401               fcc       /no 'if' for 'else'/
                    fcb       $00
L3414               fcc       /illegal declaration/
                    fcb       $00
L3428               fcc       /syntax error/
                    fcb       $00
L3435               fcc       /multiple defaults/
                    fcb       $00
L3447               fcc       /no switch statement/
                    fcb       $00
L345B               fcc       /while expected/
                    fcb       $00
L346A               fcc       /break error/
                    fcb       $00
L3476               fcc       /continue error/
                    fcb       $00
L3485               fcc       /label required/
                    fcb       $00
L3494               fcc       /already a local variable/
                    fcb       $00
L34AD               fcc       /condition needed/
                    fcb       $00
L34BE               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
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
                    lbsr      stkcheck
                    ldu       $04,s
                    leas      -$06,s
                    ldd       $06,u
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
                    bra       L351A

L3500               ldd       $08,u
                    lbeq      L3894
                    pshs      u
                    ldd       #$0077
                    pshs      d
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
                    lbsr      L3987
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
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
L3981               fcc       /longs/
                    fcb       $00
L3987               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
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
                    lbsr      stkcheck
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
                    lbsr      L3987
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

L3A18               leax      L3987,pcr
                    pshs      x
                    pshs      u
                    lbsr      L7567
                    leas      $04,s
                    bra       L3A42

L3A27               ldd       $0a,u
                    pshs      d
                    lbsr      L3987
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
                    lbsr      L3987
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
                    lbsr      L3987
                    leas      $02,s
                    ldd       #$006E
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
                    ldd       $0C,u
                    pshs      d
                    lbsr      L3987
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
                    lbsr      L3987
                    leas      $02,s
                    ldd       #$0071
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L4623
                    leas      $04,s
                    ldd       $0C,u
                    pshs      d
                    lbsr      L3987
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
                    lbsr      L3987
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
                    lbsr      L3987
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
L3CB0               fcc       /floats/
                    fcb       $00
L3CB7               pshs      u
                    ldd       #$FFB0
                    lbsr      stkcheck
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
                    lbsr      L5F26
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
L3D81               lbsr      L5F26
                    leax      $04,s
                    lbra      L3DE5

L3D89               ldd       #$0002
                    std       L0056
                    bra       L3D98

L3D90               ldd       #$0002
                    std       L0056
                    lbsr      L5F26
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
                    lbsr      stkcheck
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
                    lbsr      L5F26
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
                    lbsr      L5F26
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
                    lbsr      L5F26
L3EF4               ldd       $003F
                    cmpd      #$002A
                    bne       L3F02
                    lbsr      L5F26
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
                    leax      L425F,pcr
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
                    lbsr      L5F26
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
                    leas      -$08,s
                    ldd       #$0002
                    pshs      d
                    lbsr      L0785
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
                    lbsr      LA7AE
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
                    leax      L4294,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
                    bsr       L421A
                    puls      pc,u
L421A               pshs      u
                    ldd       #$FFBC
                    lbsr      stkcheck
L4222               ldx       $003F
                    bra       L422D

L4226               puls      pc,u
L4228               lbsr      L5F26
                    bra       L4222

L422D               cmpx      #$0030
                    beq       L4226
                    cmpx      #$0028
                    lbeq      L4226
                    cmpx      #$FFFF
                    lbeq      L4226
                    bra       L4228
                    puls      pc,u
L4244               fcc       /too long/
                    fcb       $00
L424D               fcc       /too many elements/
                    fcb       $00
L425F               fcc       /unions not allowed/
                    fcb       $00
L4272               fcc       /constant expression required/
                    fcb       $00
L428F               fcc       /rzb /
                    fcb       $00
L4294               fcc       /cannot initialize/
                    fcb       $00
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
                    lbsr      LA5D9
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
                    lbsr      LA5D9
                    leas      $04,s
L4365               lbsr      L4509
                    std       -$02,s
                    lbne      L430E
                    lbra      L4403

L4371               leax      $0584,y
                    pshs      x
                    leax      $078a,y
                    pshs      x
                    lbsr      LA5D9
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
                    lbsr      fprintf
                    leas      $08,s
                    leax      $078a,y
                    pshs      x
                    leax      L45B9,pcr
L43B5               pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      fprintf
                    leas      $06,s
                    lbra      L430E

L43C3               leax      $0584,y
                    pshs      x
                    leax      $078a,y
                    pshs      x
                    lbsr      LA5D9
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

L4424               leax      L45D0,pcr
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
                    lbsr      L9F95
                    leas      $02,s
                    bra       L4463

L4453               leax      $0253,y
                    pshs      x
                    ldd       #$0020
                    pshs      d
                    lbsr      LA1CD
                    leas      $04,s
L4463               ldd       $02,s
                    addd      #$FFFF
                    std       $02,s
                    subd      #$FFFF
                    bne       L4453
                    leax      $45EA,pcr
                    pshs      x
                    lbsr      L9F95
                    leas      $02,s
L447A               ldd       $04,s
                    cmpd      #$0031
                    lbne      L430E
                    ldd       #$0001
                    pshs      d
                    lbsr      exit
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
                    lbsr      LA3E4
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
                    lbsr      L9FB7
                    leas      $04,s
                    ldd       #$0001
                    pshs      d
                    lbsr      exit
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
                    lbsr      LA3E4
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
L45A3               bra       L4615
                    fcc       /sect %s,0,0,%d,0,0/
                    fcb       $0D,$00
L45B9               bra       $4629
                    fcb       $61
                    tst       0,y
                    bcs       $4633
                    tst       $0000
L45C2               fcc       /%s : line %d /
                    fcb       $00
L45D0               fcc       /argument : /
                    fcb       $00
L45DC               bpl       L4608
                    bpl       L460A
                    bra       L4607
                    com       L202A
                    bpl       L4611
                    bpl       L45F6
                    neg       $005E
                    neg       L0049
                    fcc       /NPUT FILE/
L45F6               fcc       / ERROR : TEMPORAR/
L4607               fcb       $59
L4608               fcb       $20,$46
L460A               fcb       $49,$4C,$45
                    fcb       $0D,$00
L460F               fcb       $69,$6E
L4611               fcc       /put /
L4615               fcc       /line too long/
                    fcb       $00
L4623               pshs      u
                    ldu       $0a,s
                    leas      -$08,s
                    ldd       $0C,s
                    cmpd      #$0088
                    bne       L4641
                    ldd       $10,s
                    pshs      d
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
                    lbsr      fprintf
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

L46ED               leax      L58B7,pcr
                    bra       L4715

L46F3               leax      L58BE,pcr
                    bra       L4715

L46F9               leax      L58C4,pcr
                    bra       L4715

L46FF               leax      L58CA,pcr
                    bra       L4715

L4705               leax      L58D0,pcr
                    bra       L4715

L470B               leax      L58D6,pcr
                    bra       L4715

L4711               leax      L58DD,pcr
L4715               pshs      x
                    lbsr      L51F1
                    lbra      L4B24

L471D               leax      L58E3,pcr
                    lbra      L4840

L4724               leax      L58F7,pcr
                    lbra      L4840

L472B               leax      L5902,pcr
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

L4836               leax      L5929,pcr
                    bra       L4840

L483C               leax      L5934,pcr
L4840               pshs      x
                    lbra      L4B21

L4845               leax      L593F,pcr
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
                    lbsr      fprintf
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
                    cmpx      #_start
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

L4B29               leax      L5982,pcr
                    lbra      L4BAD

L4B30               ldd       $10,s
                    cmpd      #$0036
                    bne       L4B55
                    cmpu      #$0000
                    bne       L4B55
                    ldd       $06,s
                    pshs      d
                    leax      $5985,pcr
L4B47               pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      fprintf
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
                    lbsr      fprintf
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
                    lbsr      fprintf
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

L4DDC               leax      L59EA,pcr
                    bra       L4E1C

L4DE2               leax      L59F1,pcr
                    bra       L4E2F

L4DE8               leax      L59F7,pcr
                    bra       L4E2F

L4DEE               leax      L59FD,pcr
                    bra       L4E2F

L4DF4               leax      L5A03,pcr
                    bra       L4E2F

L4DFA               leax      L5A09,pcr
                    bra       L4E2F

L4E00               leax      L5A0F,pcr
                    bra       L4E2F

L4E06               leax      L5A15,pcr
                    bra       L4E2F

L4E0C               leax      $5A1A,pcr
                    bra       L4E2F

L4E12               leax      L5A20,pcr
                    bra       L4E1C

L4E18               leax      L5A26,pcr
L4E1C               pshs      x
                    lbsr      L520E
                    leas      $02,s
                    ldd       $000F
                    subd      #$0002
                    lbra      L5229

L4E2B               leax      L5A2C,pcr
L4E2F               pshs      x
                    lbsr      L520E
                    lbra      L5470

L4E37               leax      L5A33,pcr
                    bra       L4E59

L4E3D               leax      L5A39,pcr
                    bra       L4E59

L4E43               leax      L5A41,pcr
                    bra       L4E59

L4E49               leax      L5A48,pcr
                    bra       L4E59

L4E4F               leax      L5A4F,pcr
                    bra       L4E59

L4E55               leax      L5A55,pcr
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
L4F79               leax      L5A6A,pcr
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
                    leax      L5A72,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      fprintf
                    leas      $06,s
                    puls      pc,u
L4FAD               cmpu      #$0005
                    bne       L4FB9
                    leax      L5A7D,pcr
                    bra       L4FBD

L4FB9               leax      L5A84,pcr
L4FBD               tfr       x,d
                    pshs      d
                    lbsr      L522D
                    lbra      L5205

L4FC7               leax      L5A8B,pcr
                    bra       L4FE3

L4FCD               leax      L5A91,pcr
                    bra       L4FE3

L4FD3               leax      L5A97,pcr
                    bra       L4FE3

L4FD9               leax      L5A9D,pcr
                    bra       L4FE3

L4FDF               leax      L5AA3,pcr
L4FE3               pshs      x
                    lbsr      L522D
                    leas      $02,s
                    ldd       $000F
                    addd      #$0008
                    lbra      L5229

L4FF2               leax      L5AAA,pcr
                    bra       L5048

L4FF8               cmpu      #$0005
                    bne       L5004
                    leax      L5AB0,pcr
                    bra       L501A

L5004               leax      L5AB6,pcr
                    bra       L501A

L500A               cmpu      #$0005
                    bne       L5016
                    leax      L5ABC,pcr
                    bra       L501A

L5016               leax      L5AC2,pcr
L501A               tfr       x,d
                    pshs      d
                    bra       L504A

L5020               leax      L5AC8,pcr
                    bra       L5048

L5026               leax      L5ACE,pcr
                    bra       L5048

L502C               leax      L5AD4,pcr
                    bra       L5048

L5032               leax      L5ADA,pcr
                    bra       L5048

L5038               leax      L5AE0,pcr
                    bra       L5048

L503E               leax      L5AE6,pcr
                    bra       L5048

L5044               leax      L5AEC,pcr
L5048               pshs      x
L504A               lbsr      L522D
                    lbra      L5470

L5050               leax      L5AF2,pcr
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
                    leax      L5B07,pcr
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

L5198               leax      L5B0E,pcr
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

L5278               leax      $5B11,pcr
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
                    leax      L5B21,pcr
                    bra       L5396

L5384               cmpu      #$0057
                    lbeq      L5425
                    cmpu      #$0059
                    bne       L53A0
                    leax      L5B26,pcr
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
                    leax      L5B2B,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      fprintf
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

L54D8               leax      L5B4F,pcr
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
                    leax      L5B56,pcr
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
                    leax      L5B69,pcr
                    pshs      x
                    lbsr      L5794
                    leas      $02,s
                    ldd       $000F
                    addd      #$0002
                    std       $000F
                    bra       L56B8

L5673               leax      $5B6C,pcr
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

L56D6               leax      L5B78,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
L56E1               leax      L5B7F,pcr
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
                    lbsr      LA1CD
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
                    lbsr      LA1CD
                    bra       L57A1

L5794               pshs      u
                    ldd       $04,s
                    pshs      d
                    ldd       $0005
                    pshs      d
                    lbsr      fprintf
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
                    lbsr      fprintf
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
                    lbsr      fprintf
                    leas      $08,s
                    puls      pc,u
                    bge       $58E8
                    neg       L002C
                    com       >L006C
                    fcc       /bsr /
                    fcb       $00
                    fcc       /lbra /
                    fcb       $00
L587F               fcc       /clra/
                    fcb       $00
                    fcc       /unknown operator : /
                    fcb       $00
L5898               bra       L590A
                    com       L6873
                    bra       L58C4
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
                    fcc       /cmult/
                    fcb       $00
L58B7               fcc       /ccudiv/
                    fcb       $00
L58BE               fcc       /ccdiv/
                    fcb       $00
L58C4               fcc       /ccasl/
                    fcb       $00
L58CA               fcc       /ccasr/
                    fcb       $00
L58D0               fcc       /cclsr/
                    fcb       $00
L58D6               fcc       /ccumod/
                    fcb       $00
L58DD               fcc       /ccmod/
                    fcb       $00
L58E3               jmp       $05,s
                    asr       $01,s
                    tst       $0020
                    jmp       $05,s
                    asr       $02,s
                    tst       $0020
                    fcc       /sbca #0/
                    fcb       $00
L58F7               com       $0f,s
                    tst       $01,s
                    tst       $0020
                    fcc       /comb/
                    fcb       $00
L5902               fcc       /leax /
                    fcb       $00
L5908               fcb       $6C,$65
L590A               fcb       $61,$73,$20
                    fcb       $00
L590E               bge       $5988
                    tst       $0000
L5912               fcc       /jsr /
                    fcb       $00
L5917               com       $6578
                    neg       L006C
                    lsr       0,x
L591E               fcb       $61
                    com       L6C62
                    tst       $0020
                    fcc       /rola/
                    fcb       $00
L5929               fcb       $61
                    com       L7261
                    tst       $0020
                    fcc       /rorb/
                    fcb       $00
L5934               inc       -$0d,s
                    fcb       $72,$61
                    tst       $0020
                    fcc       /rorb/
                    fcb       $00
L593F               fcc       /ldy /
                    fcb       $00
L5944               fcc       /ldu /
                    fcb       $00
L5949               fcc       /leax /
                    fcb       $00
L594F               bcs       L59B5
                    bge       L5978
                    com       $0d,x
                    neg       $0064
                    bge       L597E
                    com       $0d,x
                    neg       $0073
                    fcb       $65
                    asl       >L0061
                    fcc       /dca #0/
                    fcb       $00
L5968               fcc       /sbca #0/
                    fcb       $00
L5970               bcs       $59D6
                    bge       L5999
                    com       $0d,x
                    neg       L0063
L5978               inc       -$0e,s
                    fcb       $61
                    tst       $0020
                    fcb       $63
L597E               fcb       $6C,$72,$62
                    fcb       $00
L5982               inc       $04,s
                    neg       $0020
                    com       L7425
                    com       0,y
                    blt       L59BF
                    bge       L5A02
                    tst       $0000
L5991               com       $0d,s
                    neg       >$0073
                    lsr       >$0073
L5999               fcb       $75,$62
                    neg       L0061
                    lsr       $04,s
                    neg       L006C
                    fcb       $65,$61
                    neg       $0020
                    fcb       $65
                    asl       $6720
                    bcs       L5A0E
                    bge       L59D2
                    com       $0d,x
                    neg       $0064
                    bge       L59B3
L59B3               fcb       $4C,$45
L59B5               fcc       /A arg/
                    fcb       $00
L59BB               bra       L5A31
                    ror       -$0e,s
L59BF               bra       L59E6
                    com       $0C,y
                    bcs       L5A28
                    tst       $0000
L59C7               inc       $04,s
                    fcb       $61
                    bra       L59FC
                    bge       L5A46
                    tst       $0020
                    clr       -$0e,s
L59D2               fcb       $61
                    bra       L5A06
                    bge       L5A4F
                    tst       $0020
                    clr       -$0e,s
                    fcb       $61
                    bra       L5A10
                    bge       L5A58
                    tst       $0020
                    fcc       /ora /
L59E6               fcb       $33,$2C,$78
                    fcb       $00
L59EA               clrb
                    fcc       /lmove/
                    fcb       $00
L59F1               clrb
                    fcc       /ladd/
                    fcb       $00
L59F7               clrb
                    fcc       /lsub/
L59FC               fcb       $00
L59FD               clrb
                    fcc       /lmul/
L5A02               fcb       $00
L5A03               clrb
                    fcb       $6C,$64
L5A06               fcb       $69,$76
                    fcb       $00
L5A09               clrb
                    fcc       /lmod/
L5A0E               fcb       $00
L5A0F               clrb
L5A10               fcc       /land/
                    fcb       $00
L5A15               clrb
                    inc       $0f,s
                    fcb       $72
                    neg       L005F
                    fcc       /lxor/
                    fcb       $00
L5A20               clrb
                    fcc       /lshl/
                    fcb       $00
L5A26               clrb
                    fcb       $6C
L5A28               fcb       $73,$68,$72
                    fcb       $00
L5A2C               clrb
                    fcc       /lcmp/
L5A31               fcb       $72
                    fcb       $00
L5A33               clrb
                    fcc       /lneg/
                    fcb       $00
L5A39               clrb
                    fcc       /lcompl/
                    fcb       $00
L5A41               clrb
                    fcc       /lito/
L5A46               fcb       $6C
                    fcb       $00
L5A48               clrb
                    fcc       /lutol/
                    fcb       $00
L5A4F               clrb
                    fcc       /linc/
                    fcb       $00
L5A55               clrb
                    fcb       $6C,$64
L5A58               fcb       $65,$63
                    fcb       $00
L5A5B               fcc       /codgen - longs/
                    fcb       $00
L5A6A               clrb
                    fcc       /dstack/
                    fcb       $00
L5A72               bra       L5AE0
                    lsr       $01,s
                    bra       L5A9D
                    com       $0C,y
                    asl       $0D00
L5A7D               clrb
                    fcc       /fmove/
                    fcb       $00
L5A84               clrb
                    fcc       /dmove/
                    fcb       $00
L5A8B               clrb
                    fcc       /dadd/
                    fcb       $00
L5A91               clrb
                    fcc       /dsub/
                    fcb       $00
L5A97               clrb
                    fcc       /dmul/
                    fcb       $00
L5A9D               clrb
                    fcc       /ddiv/
                    fcb       $00
L5AA3               clrb
                    fcc       /dcmpr/
                    fcb       $00
L5AAA               clrb
                    fcc       /dneg/
                    fcb       $00
L5AB0               clrb
                    fcc       /finc/
                    fcb       $00
L5AB6               clrb
                    fcc       /dinc/
                    fcb       $00
L5ABC               clrb
                    fcc       /fdec/
                    fcb       $00
L5AC2               clrb
                    fcc       /ddec/
                    fcb       $00
L5AC8               clrb
                    fcc       /dtof/
                    fcb       $00
L5ACE               clrb
                    fcc       /ftod/
                    fcb       $00
L5AD4               clrb
                    fcc       /ltod/
                    fcb       $00
L5ADA               clrb
                    fcc       /itod/
                    fcb       $00
L5AE0               clrb
                    fcc       /utod/
                    fcb       $00
L5AE6               clrb
                    fcc       /dtol/
                    fcb       $00
L5AEC               clrb
                    fcc       /dtoi/
                    fcb       $00
L5AF2               fcc       /codgen - floats/
                    fcb       $00
L5B02               fcc       /bsr /
                    fcb       $00
L5B07               fcc       /puls x/
                    fcb       $00
L5B0E               leax      $0C,y
                    neg       L0061
                    jmp       $04,s
                    neg       $006F
                    fcb       $72
                    neg       L0065
                    clr       -$0e,s
                    neg       L0063
                    fcb       $6F,$6D,$61
                    fcb       $00
L5B21               fcc       /clrb/
                    fcb       $00
L5B26               fcc       /comb/
                    fcb       $00
L5B2B               bra       L5B52
                    com       L6120
                    bge       L5BA5
                    bmi       L5B41
                    bra       $5B5B
                    com       $6220
                    bge       $5BAE
                    bmi       L5B4A
                    neg       L0063
                    fcb       $6F,$6D
L5B41               fcc       /piler tro/
L5B4A               fcc       /uble/
                    fcb       $00
L5B4F               clrb
                    fcb       $66,$6C
L5B52               fcb       $61,$63,$63
                    fcb       $00
L5B56               bge       $5BC8
                    com       -$0e,s
                    neg       $0073
                    fcc       /torage error/
                    fcb       $00
L5B69               bmi       $5B96
                    neg       $0064
                    fcc       /ereference/
                    fcb       $00
L5B78               fcc       /rel op/
                    fcb       $00
L5B7F               fcb       $65,$71
                    bra       L5B83

L5B83               jmp       $05,s
                    bra       L5B87

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
                    bra       L5BA3

L5BA3               asl       $09,s
L5BA5               bra       L5BA7

L5BA7               bcs       $5C0D
                    neg       L0025
                    bgt       L5BE5
                    com       >L006C
                    fcc       /eas /
                    fcb       $00
L5BB5               bra       L5C23
                    fcc       /ea%c /
                    fcb       $00
L5BBD               bcs       $5C22
                    bcs       L5C25
                    bge       $5C33
                    com       -$0e,s
                    tst       $0000
L5BC7               pshs      u
                    lbsr      L5D72
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
                    leax      L5E14,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      fprintf
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
                    ldd       #$0020
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
                    lbsr      fprintf
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
                    lbsr      fprintf
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
                    leax      L5E52,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      fprintf
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
                    lbsr      fprintf
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
                    lbsr      fprintf
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

L5D5A               leax      L5F0C,pcr
L5D5E               tfr       x,d
                    pshs      d
                    bra       L5D6C

L5D64               pshs      u
                    leax      L5F12,pcr
L5D6A               pshs      x
L5D6C               lbsr      L576F
                    lbra      L5DFD

L5D72               pshs      u
                    ldd       L004C
                    lbeq      L5DFF
                    ldd       L004C
                    pshs      d
                    lbsr      LA14D
                    leas      $02,s
                    bra       L5D90

L5D85               ldd       $0005
                    pshs      d
                    pshs      u
                    lbsr      LA1CD
                    leas      $04,s
L5D90               ldd       L004C
                    pshs      d
                    lbsr      LA3E4
                    leas      $02,s
                    tfr       d,u
                    cmpu      #$FFFF
                    bne       L5D85
                    ldx       L004C
                    ldd       $06,x
                    clra
                    andb      #$20
                    beq       L5DB5
                    leax      L5F1A,pcr
                    pshs      x
                    lbsr      L042D
                    leas      $02,s
L5DB5               ldd       L004C
                    pshs      d
                    lbsr      LA2BE
                    leas      $02,s
                    leax      $0096,y
                    pshs      x
                    lbsr      LB17D
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
                    lbsr      LA2BE
                    leas      $02,s
                    leax      $0096,y
                    pshs      x
                    lbsr      LB17D
                    leas      $02,s
L5DF4               ldd       ,s
                    pshs      d
                    lbsr      LB352
                    leas      $02,s
L5DFD               leas      $02,s
L5DFF               puls      pc,u
L5E01               fcc       /fail source errors/
                    fcb       $00
L5E14               bra       $5E88
                    tst       $02,s
                    bra       $5E3F
                    lsr       $0d,x
                    neg       L0025
                    bgt       L5E58
                    com       L2563
                    bra       L5E97
                    tst       $02,s
                    bra       L5E4E
                    lsr       $0d,x
                    neg       $0020
                    ror       $03,s
                    com       0,y
                    bhi       L5E58
                    bgt       L5E6D
                    com       $220D
                    bra       L5EA0
                    com       $02,s
                    bra       L5E6E
                    tst       $0000
L5E40               bra       L5EB6
                    lsr       $6C20
                    bcs       L5E75
                    fcb       $38
                    com       $0D00
L5E4B               fcb       $70,$73,$68
L5E4E               fcb       $73,$20,$75
                    fcb       $00
L5E52               bra       L5EC0
                    lsr       $04,s
                    bra       $5E7B

L5E58               clrb
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
L5E6D               fcb       $6C
L5E6E               fcc       /eax /
                    fcb       $00
L5E73               bge       $5EE5
L5E75               com       -$0e,s
                    tst       $0020
                    neg       L7368
                    com       L2078
                    tst       $0020
                    fcc       /leax /
                    fcb       $00
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
L5EA0               bra       L5F0E
                    fcb       $65,$61
                    com       $2034
                    bge       L5F1C
                    tst       $0000
L5EAB               bra       L5F1D
                    com       L6873
                    bra       L5F16
                    tst       $0020
                    inc       $05,s
L5EB6               fcb       $61
                    asl       L205F
                    bcs       L5F20
                    bge       L5F2E
                    com       -$0e,s
L5EC0               tst       $0020
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
                    fcb       $65,$61
                    com       $2032
                    bge       L5F52
                    tst       $0020
                    neg       L756C
                    com       $2064
                    tst       $0000
L5EE9               clrb
                    bcs       $5F50
                    bra       $5F53
                    fcb       $71,$75
                    bra       L5F17
                    lsr       $0d,x
                    tst       $0000
L5EF6               fcb       $66,$63,$62
L5EF9               fcb       $20
                    fcb       $00
L5EFB               fcc       /fdb /
                    fcb       $00
L5F00               bpl       L5F22
                    neg       $0076
                    fcc       /sect dp/
                    fcb       $00
L5F0C               fcb       $76,$73
L5F0E               fcb       $65,$63,$74
                    fcb       $00
L5F12               fcc       /ends/
L5F16               fcb       $65
L5F17               fcb       $63,$74
                    fcb       $00
L5F1A               fcb       $64,$75
L5F1C               fcb       $6D
L5F1D               fcb       $70,$73,$74
L5F20               fcb       $72,$69
L5F22               fcb       $6E,$67,$73
                    fcb       $00
L5F26               pshs      u
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
                    lbsr      LAE34
                    stu       $0041
                    ldd       #$004B
                    bra       L6033

L6020               leax      L6CEC,pcr
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
L6120               cmpb      #$3d
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
                    beq       L6135
                    cmpx      #$003D
                    beq       L6155
                    lbra      L628D

L616D               ldb       $0045
                    sex
                    tfr       d,x
                    bra       L619F

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
                    leax      L6CFE,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$0005
                    pshs      d
                    leax      L6D05,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$001E
                    pshs      d
                    leax      L6D0B,pcr
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
                    leax      L6D1A,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$0001
                    pshs      d
                    leax      L6D21,pcr
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
                    leax      L6D2F,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$000A
                    pshs      d
                    leax      L6D34,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$000D
                    pshs      d
                    leax      L6D3A,pcr
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
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$0010
                    pshs      d
                    leax      L6D4D,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #_start
                    pshs      d
                    leax      L6D56,pcr
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
                    leax      L6D6B,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$0016
                    pshs      d
                    leax      L6D70,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$0017
                    pshs      d
                    leax      L6D77,pcr
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
                    leax      L6D82,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$001A
                    pshs      d
                    leax      L6D8B,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$001B
                    pshs      d
                    leax      $6D8E,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$001C
                    pshs      d
                    leax      L6D96,pcr
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
                    leax      L6DA1,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$0007
                    pshs      d
                    leax      L6DA7,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    ldd       #$0008
                    pshs      d
                    leax      L6DB0,pcr
                    pshs      x
                    lbsr      L65D0
                    leas      $04,s
                    leax      L6DB5,pcr
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
                    leax      L6DBB,pcr
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
                    std       ,s++
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
                    bne       L6580
                    ldd       #$0008
                    pshs      d
                    pshs      u
                    ldd       #$0014
                    addd      ,s++
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    lbsr      LA68C
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
                    lbsr      LA64F
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
                    lbsr      LA64F
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
                    lbsr      LB253
                    leas      $02,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       L6640
                    leax      L6DC1,pcr
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
                    lbsr      LAE34
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
                    lbsr      LA731
                    leas      $02,s
                    lbsr      LAE34
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
                    cmpd      #$0028
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
                    lbsr      LAE34
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
                    lbsr      LAFFF
                    addd      #$0009
                    pshs      d
                    leax      $0a,s
                    lbsr      LAE0D
                    bsr       L6970
                    leas      $0C,s
                    lbsr      LAE34
L6955               ldd       $0e,s
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    ldd       #$000A
                    lbsr      LAFAC
                    pshs      d
                    leax      $08,s
                    lbsr      LAE0D
                    bsr       L6970
                    leas      $0C,s
                    puls      pc,u
L6970               pshs      u
                    ldd       $0C,s
                    beq       L69B6
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
                    lbsr      LA765
                    bra       L69AA

L69A0               leax      $06,s
                    lbsr      LAE0D
                    ldx       $08,s
                    lbsr      LA76D
L69AA               leau      $0358,y
                    pshs      u
                    lbsr      LAE34
                    lbra      L6C9A

L69B6               leax      $04,s
                    leau      $0358,y
                    pshs      u
                    lbsr      LAE34
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
                    leax      L6DCF,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
                    lbra      L6ABF

L69F3               pshs      u
                    ldx       L0056
                    bra       L6A27

L69F9               ldd       L004C
                    bne       L6A1D
                    leax      L6DEF,pcr
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
                    leax      L6E0A,pcr
                    pshs      x
                    ldd       $0064
                    pshs      d
                    lbsr      fprintf
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
                    lbsr      LA1CD
                    leas      $04,s
                    clra
                    clrb
                    std       $003D
L6ABC               lbsr      L42CF
L6ABF               puls      pc,u
L6AC1               pshs      u
                    ldd       $003D
                    bne       L6AD6
                    leax      L6E23,pcr
                    pshs      x
                    ldd       $0064
                    pshs      d
                    lbsr      fprintf
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
                    lbsr      fprintf
                    leas      $06,s
                    bra       L6B27

L6AFB               ldd       $0064
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      LA1CD
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
                    lbsr      fprintf
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
                    lbsr      fprintf
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
L6CDE               fcc       /bad ch/
L6CE4               fcc       /aracter/
                    fcb       $00
L6CEC               fcc       /constant overflow/
                    fcb       $00
L6CFE               fcc       /double/
                    fcb       $00
L6D05               fcc       /float/
                    fcb       $00
L6D0B               fcc       /typedef/
                    fcb       $00
L6D13               fcc       /static/
                    fcb       $00
L6D1A               fcc       /sizeof/
                    fcb       $00
L6D21               rol       $0e,s
                    lsr       >$0069
                    jmp       -$0C,s
                    neg       $0066
                    fcc       /loat/
                    fcb       $00
L6D2F               fcc       /char/
                    fcb       $00
L6D34               fcc       /short/
                    fcb       $00
L6D3A               fcc       /auto/
                    fcb       $00
L6D3F               fcc       /extern/
                    fcb       $00
L6D46               fcc       /direct/
                    fcb       $00
L6D4D               fcc       /register/
                    fcb       $00
L6D56               fcc       /goto/
                    fcb       $00
L6D5B               fcc       /return/
                    fcb       $00
L6D62               rol       $06,s
                    neg       $0077
                    fcc       /hile/
                    fcb       $00
L6D6B               fcc       /else/
                    fcb       $00
L6D70               fcc       /switch/
                    fcb       $00
L6D77               fcc       /case/
                    fcb       $00
L6D7C               fcc       /break/
                    fcb       $00
L6D82               fcc       /continue/
                    fcb       $00
L6D8B               lsr       $0f,s
                    neg       $0064
                    fcc       /efault/
                    fcb       $00
L6D96               ror       $0f,s
                    fcb       $72
                    neg       $0073
                    fcc       /truct/
                    fcb       $00
L6DA1               fcc       /union/
                    fcb       $00
L6DA7               fcc       /unsigned/
                    fcb       $00
L6DB0               fcc       /long/
                    fcb       $00
L6DB5               fcc       /errno/
                    fcb       $00
L6DBB               fcc       /lseek/
                    fcb       $00
L6DC1               fcc       /out of memory/
                    fcb       $00
L6DCF               fcc       /unterminated character constant/
                    fcb       $00
L6DEF               asr       $2B00
L6DF2               fcc       /can't open strings file/
                    fcb       $00
L6E0A               fcc       /%c%d/
                    fcb       $00
L6E0F               fcc       /unterminated string/
                    fcb       $00
L6E23               bra       $6E8B
                    fcc       /cc "/
                    fcb       $00
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
                    tst       $0000
L6E42               pshs      u
                    ldd       #$FFB4
                    lbsr      stkcheck
                    ldu       $04,s
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
                    ldd       #$0070
                    bra       L6EA8

L6E76               pshs      u
                    ldd       #$FFB4
                    lbsr      stkcheck
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
                    lbsr      stkcheck
                    ldu       $04,s
                    ldx       ,u
                    bra       L6ED7

L6EBA               pshs      u
                    lbsr      L34BE
                    bra       L6ED3

L6EC1               pshs      u
                    lbsr      L3987
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
                    lbsr      stkcheck
                    ldu       $04,s
                    ldx       $06,u
                    lbra      L6F5F

L6EFB               pshs      u
                    ldd       #$0077
                    pshs      d
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
                    beq       L6F1D
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
                    lbsr      stkcheck
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
                    lbsr      L3987
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
                    lbsr      stkcheck
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
                    bne       L7229
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
                    leas      $02,s
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
L7425               cmpx      #$005C
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
                    cmpx      #$0053
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
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
L756C               lbsr      stkcheck
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
                    lbsr      stkcheck
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
                    lbsr      L3987
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
                    ldx       $04,s
                    ldd       $12,x
                    cmpd      #$0002
                    bge       L77A8
                    ldd       #$0001
                    bra       L77AA

L7771               pshs      u
                    ldd       #$FFC0
                    lbsr      stkcheck
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
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
                    cmpd      #$0007
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
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
L8153               fcc       /translation/
                    fcb       $00
L815F               bcs       $81D9
                    tst       $0000
L8163               fcc       /binary op./
                    fcb       $00
L816E               fcc       /indirection/
                    fcb       $00
L817A               fcc       /indirection/
                    fcb       $00
L8186               fcc       /x translate/
                    fcb       $00
L8192               pshs      u
                    ldd       #$FFA2
                    lbsr      stkcheck
                    leas      -$14,s
                    bra       L81AD

L819F               leax      L925F,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
                    lbsr      L5F26
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
                    lbsr      L5F26
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
L83DF               leax      L9297,pcr
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
                    lbsr      L5F26
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
                    lbsr      stkcheck
                    leas      -$12,s
                    lbsr      L8B51
                    std       $10,s
                    tfr       d,x
                    bra       L8469

L8456               leax      L92AB,pcr
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
L84C2               leax      L92BC,pcr
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

L8543               leax      L92CB,pcr
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
                    lbsr      L5F26
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
                    lbsr      stkcheck
                    leas      -$12,s
                    lbsr      L8B51
                    std       $10,s
                    tfr       d,x
                    bra       L85BB

L85A8               leax      L92DB,pcr
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

L871F               lbsr      L5F26
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
                    lbsr      L0785
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

L87CF               lbsr      L5F26
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
                    lbsr      stkcheck
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
L8806               leax      L92E9,pcr
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
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
                    leax      L92FE,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
L89B0               lbsr      L5F26
                    leas      $0a,s
                    puls      pc,u
L89B7               pshs      u
                    ldd       #$FFAA
                    lbsr      stkcheck
                    leas      -$06,s
                    ldd       $002B
                    std       $02,s
                    clra
                    clrb
                    std       $002B
                    lbsr      L5F26
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
                    lbsr      stkcheck
                    leas      -$02,s
                    clra
                    clrb
                    std       [$06,s]
L8AD4               lbsr      L5F26
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
                    lbsr      L5F26
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
                    lbsr      stkcheck
                    leas      -$02,s
                    lbsr      L0641
                    std       -$02,s
                    beq       L8B9A
                    ldd       $0041
                    std       ,s
                    lbsr      L5F26
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
L8B93               lbsr      L5F26
L8B96               ldd       ,s
                    bra       L8B9C

L8B9A               clra
                    clrb
L8B9C               leas      $02,s
                    puls      pc,u
L8BA0               pshs      u
                    ldd       #$FF98
                    lbsr      stkcheck
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
L8BD1               lbsr      L5F26
                    ldd       $003F
                    cmpd      #$0033
                    lbne      L8EE4
                    ldd       $0041
                    cmpd      #$0001
                    lbne      L8EE4
                    bra       L8C22

L8BEA               ldd       #$0001
                    bra       L8C20

L8BEF               lbsr      L5F26
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
L8C22               lbsr      L5F26
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
                    lbsr      L5F26
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
                    leax      L931E,pcr
                    pshs      x
                    lbsr      L0450
                    leas      $02,s
L8C86               lbsr      L5F26
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
                    lbsr      L5F26
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
L8D7F               leax      L9337,pcr
                    pshs      x
                    lbsr      L0450
                    bra       L8D8F

L8D8A               pshs      u
                    lbsr      L0382
L8D8F               leas      $02,s
L8D91               ldd       $12,s
                    cmpd      #$000A
                    bne       L8DA5
                    leax      L934E,pcr
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

L8E3B               lbsr      L5F26
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
                    lbsr      L5F26
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
                    lbsr      stkcheck
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
                    lbsr      L5F26
L8F16               ldd       $003F
                    cmpd      #$0042
                    beq       L8F08
                    ldd       $003F
                    cmpd      #$0034
                    bne       L8F30
                    ldd       $0041
                    std       [$10,s]
                    lbsr      L5F26
                    bra       L8F6A

L8F30               ldd       $003F
                    cmpd      #$002D
                    bne       L8F6A
                    lbsr      L5F26
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
                    lbsr      L5F26
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
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
                    leax      L9362,pcr
                    pshs      x
                    leax      $06,s
                    pshs      x
                    lbsr      LA5D9
                    leas      $04,s
                    pshs      d
                    lbsr      LA6D1
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
                    lbsr      stkcheck
                    leax      L9375,pcr
                    bra       L9256

L924A               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    leax      L938A,pcr
L9256               pshs      x
                    lbsr      L0450
L925B               leas      $02,s
                    puls      pc,u
L925F               fcc       /too many brackets/
                    fcb       $00
L9271               fcc       /function header missing/
                    fcb       $00
L9289               fcc       /storage error/
                    fcb       $00
L9297               fcc       /function type error/
                    fcb       $00
L92AB               fcc       /argument storage/
                    fcb       $00
L92BC               fcc       /argument error/
                    fcb       $00
L92CB               fcc       /not an argument/
                    fcb       $00
L92DB               fcc       /storage error/
                    fcb       $00
L92E9               fcc       /declaration mismatch/
                    fcb       $00
L92FE               fcc       /function unfinished/
                    fcb       $00
L9312               fcc       /named twice/
                    fcb       $00
L931E               fcc       /name clash/
                    fcb       $00
L9329               fcc       /struct syntax/
                    fcb       $00
L9337               fcc       /struct member mismatch/
                    fcb       $00
L934E               fcc       /undefined structure/
                    fcb       $00
L9362               fcc       /label undefined : /
                    fcb       $00
L9375               fcc       /cannot evaluate size/
                    fcb       $00
L938A               fcc       /identifier missing/
                    fcb       $00
L939D               pshs      u
                    ldd       #$FFAE
                    lbsr      stkcheck
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
                    ldd       $0C,s
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
                    lbsr      L3987
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
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
                    lbsr      stkcheck
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

fprintf             pshs      u
                    ldd       $04,s
                    std       L0070
                    ldd       #$0001
                    std       $0076
                    leax      $08,s
                    pshs      x
                    ldd       $08,s
L9A45               pshs      d
                    bsr       doprnt
                    leas      $04,s
                    puls      pc,u
L9A4D               pshs      u
                    ldd       $04,s
                    std       L0070
                    ldd       #$0002
                    std       $0076
                    leax      $08,s
                    pshs      x
                    ldd       $08,s
                    pshs      d
                    bsr       doprnt
                    leas      $04,s
                    clra
                    clrb
                    stb       [L0070,y]
                    puls      pc,u
doprnt              pshs      u
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
                    lbsr      LA5D9
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
                    lbsr      LA5C8
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
                    lbsr      LA1CD
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
L9E14               pshs      u
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
                    lbsr      LB116
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
                    lbsr      LB1EC
                    leas      $08,s
                    bra       L9F2C

L9EE7               ldd       ,s
                    orb       #$02
                    pshs      d
                    pshs      u
                    lbsr      LB137
                    bra       L9EFF

L9EF4               ldd       ,s
                    orb       #$81
L9EF8               pshs      d
                    pshs      u
                    lbsr      LB116
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
                    lbra      L9F8E

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
                    bra       L9F93

L9F5E               clra
                    clrb
                    bra       L9F86

L9F62               pshs      u
                    ldd       $08,s
                    pshs      d
                    lbsr      LA2BE
                    leas      $02,s
                    ldd       $06,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L9E6C
                    leas      $04,s
                    tfr       d,u
                    stu       -$02,s
                    bge       L9F84
                    clra
                    clrb
                    bra       L9F93

L9F84               ldd       $08,s
L9F86               pshs      d
                    ldd       $08,s
                    pshs      d
                    pshs      u
L9F8E               lbsr      L9E14
                    leas      $06,s
L9F93               puls      pc,u
L9F95               pshs      u
                    leax      $0253,y
                    pshs      x
                    ldd       $06,s
                    pshs      d
                    bsr       L9FB7
                    leas      $04,s
                    leax      $0253,y
                    pshs      x
                    ldd       #$000D
                    pshs      d
                    lbsr      LA1CD
                    leas      $04,s
                    puls      pc,u
L9FB7               pshs      u
                    ldu       $04,s
                    leas      -$01,s
                    bra       L9FCD

L9FBF               ldd       $07,s
                    pshs      d
                    ldb       $02,s
                    sex
                    pshs      d
                    lbsr      LA1CD
                    leas      $04,s
L9FCD               ldb       ,u+
                    stb       ,s
                    bne       L9FBF
                    leas      $01,s
                    puls      pc,u
L9FD7               pshs      u,d
                    ldu       $06,s
                    bra       L9FDF

L9FDD               leau      $01,u
L9FDF               ldb       ,u
                    sex
                    std       ,s
                    beq       L9FEE
                    ldd       ,s
                    cmpd      #$0058
                    bne       L9FDD
L9FEE               ldd       ,s
                    beq       LA004
                    lbsr      LB2D7
                    pshs      d
                    leax      >LA00A,pcr
                    pshs      x
                    pshs      u
                    lbsr      L9A4D
                    leas      $06,s
LA004               ldd       $06,s
                    leas      $02,s
                    puls      pc,u
LA00A               bcs       LA070
                    neg       $0034
                    nega
                    ldu       $04,s
                    leas      -$06,s
                    cmpu      #$0000
                    beq       LA020
                    ldd       $06,u
                    clra
                    andb      #$03
                    bne       LA026
LA020               ldd       #$FFFF
                    lbra      LA149

LA026               ldd       $06,u
                    anda      #$80
                    clrb
                    std       -$02,s
                    bne       LA039
                    pshs      u
                    lbsr      LA538
                    leas      $02,s
                    lbra      LA10F

LA039               ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    beq       LA058
                    pshs      u
                    lbsr      LA2F8
                    leas      $02,s
                    ldd       $06,u
                    anda      #$FE
                    std       $06,u
                    ldd       $02,u
                    addd      $0b,u
                    std       $04,u
                    lbra      LA10D

LA058               ldd       ,u
                    cmpd      $04,u
                    lbcc      LA10F
                    leax      $02,s
                    pshs      x
                    leax      $0e,s
                    lbsr      LAEDF
                    ldx       $10,s
                    lbra      LA0DC

LA070               leax      $02,s
                    pshs      x
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    pshs      u
                    lbsr      LA164
                    leas      $02,s
                    lbsr      LAE66
                    lbsr      LAEDF
LA089               ldd       $0b,u
                    lbsr      LAEC6
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    leax      $06,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    bsr       LA0A6
                    neg       $0000
                    neg       $0000
LA0A6               puls      x
                    lbsr      LAE7B
                    bge       LA0B4
                    leax      $06,s
                    lbsr      LAE9F
                    bra       LA0B6

LA0B4               leax      $06,s
LA0B6               lbsr      LAE7B
                    blt       LA0E9
                    ldd       $04,s
                    addd      ,u
                    std       ,s
                    cmpd      $02,u
                    bcs       LA0E9
                    ldd       ,s
                    cmpd      $04,u
                    bcc       LA0E9
                    ldd       ,s
                    std       ,u
                    ldd       $06,u
                    andb      #$EF
                    std       $06,u
                    lbra      LA147
                    bra       LA0E9

LA0DC               stx       -$02,s
                    lbeq      LA070
                    cmpx      #$0001
                    lbeq      LA089
LA0E9               ldd       $10,s
                    cmpd      #$0001
                    bne       LA10B
                    leax      $0C,s
                    pshs      x
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $04,u
                    subd      ,u
                    lbsr      LAEC6
                    lbsr      LAE66
                    lbsr      LAEDF
LA10B               ldd       $04,u
LA10D               std       ,u
LA10F               ldd       $06,u
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
                    lbsr      LB1EC
                    leas      $08,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    bsr       $A13B
                    stu       $FFFF
                    stu       L3510
                    lbsr      LAE7B
                    bne       LA147
                    ldd       #$FFFF
                    bra       LA149

LA147               clra
                    clrb
LA149               leas      $06,s
                    puls      pc,u
LA14D               pshs      u
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    lbsr      $A00D
                    leas      $08,s
                    puls      pc,u
LA164               pshs      u
                    ldu       $04,s
                    beq       LA171
                    ldd       $06,u
                    clra
                    andb      #$03
                    bne       LA184
LA171               bsr       $A177
                    stu       $FFFF
                    stu       L3510
                    leau      $0358,y
                    pshs      u
                    lbsr      LAEDF
                    puls      pc,u
LA184               ldd       $06,u
                    anda      #$80
                    clrb
                    std       -$02,s
                    bne       LA194
                    pshs      u
                    lbsr      LA538
                    leas      $02,s
LA194               ldd       #$0001
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      LB1EC
                    leas      $08,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    beq       LA1BD
                    ldd       $02,u
                    bra       LA1BF

LA1BD               ldd       $04,u
LA1BF               pshs      d
                    ldd       ,u
                    subd      ,s++
                    lbsr      LAEC6
                    lbsr      LAE51
                    puls      pc,u
LA1CD               pshs      u
                    ldu       $06,s
                    ldd       $06,u
                    anda      #$80
                    andb      #$22
                    cmpd      #$8002
                    beq       LA1F1
                    ldd       $06,u
                    clra
                    andb      #$22
                    cmpd      #$0002
                    lbne      LA309
                    pshs      u
                    lbsr      LA538
                    leas      $02,s
LA1F1               ldd       $06,u
                    clra
                    andb      #$04
                    beq       LA22D
                    ldd       #$0001
                    pshs      d
                    leax      $07,s
                    pshs      x
                    ldd       $08,u
                    pshs      d
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       LA212
                    leax      LB1DC,pcr
                    bra       LA216

LA212               leax      LB1C3,pcr
LA216               tfr       x,d
                    tfr       d,x
                    jsr       ,x
                    leas      $06,s
                    cmpd      #$FFFF
                    bne       LA26E
                    ldd       $06,u
                    orb       #$20
                    std       $06,u
                    lbra      LA309

LA22D               ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       LA23D
                    pshs      u
                    lbsr      LA326
                    leas      $02,s
LA23D               ldd       ,u
                    addd      #$0001
                    std       ,u
                    subd      #$0001
                    tfr       d,x
                    ldd       $04,s
                    stb       ,x
                    ldd       ,u
                    cmpd      $04,u
                    bcc       LA263
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       LA26E
                    ldd       $04,s
                    cmpd      #$000D
                    bne       LA26E
LA263               pshs      u
                    lbsr      LA326
                    std       ,s++
                    lbne      LA309
LA26E               ldd       $04,s
                    puls      pc,u
                    pshs      u
                    ldu       $04,s
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    ldd       #$0008
                    lbsr      LB075
                    pshs      d
                    lbsr      LA1CD
                    leas      $04,s
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    lbsr      LA1CD
                    lbra      LA3E0

LA295               pshs      u,d
                    leau      $0246,y
                    clra
                    clrb
                    std       ,s
                    bra       LA2AB

LA2A1               tfr       u,d
                    leau      $0d,u
                    pshs      d
                    bsr       LA2BE
                    leas      $02,s
LA2AB               ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    cmpd      #$0010
                    blt       LA2A1
                    lbra      LA322

LA2BE               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    cmpu      #$0000
                    beq       LA2CE
                    ldd       $06,u
                    bne       LA2D4
LA2CE               ldd       #$FFFF
                    lbra      LA322

LA2D4               ldd       $06,u
                    clra
                    andb      #$02
                    beq       LA2E3
                    pshs      u
                    bsr       LA2F8
                    leas      $02,s
                    bra       LA2E5

LA2E3               clra
                    clrb
LA2E5               std       ,s
                    ldd       $08,u
                    pshs      d
                    lbsr      LB125
                    leas      $02,s
                    clra
                    clrb
                    std       $06,u
                    ldd       ,s
                    bra       LA322

LA2F8               pshs      u
                    ldu       $04,s
                    beq       LA309
                    ldd       $06,u
                    clra
                    andb      #$22
                    cmpd      #$0002
                    beq       LA30E
LA309               ldd       #$FFFF
                    puls      pc,u
LA30E               ldd       $06,u
                    anda      #$80
                    clrb
                    std       -$02,s
                    bne       LA31E
                    pshs      u
                    lbsr      LA538
                    leas      $02,s
LA31E               pshs      u
                    bsr       LA326
LA322               leas      $02,s
                    puls      pc,u
LA326               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       LA358
                    ldd       ,u
                    cmpd      $04,u
                    beq       LA358
                    clra
                    clrb
                    pshs      d
                    pshs      u
                    lbsr      LA164
                    leas      $02,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      LB1EC
                    leas      $08,s
LA358               ldd       ,u
                    subd      $02,u
                    std       $02,s
                    lbeq      LA3D0
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    lbeq      LA3D0
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       LA3A7
                    ldd       $02,u
                    bra       LA39F

LA378               ldd       $02,s
                    pshs      d
                    ldd       ,u
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      LB1DC
                    leas      $06,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       LA395
                    leax      $04,s
                    bra       LA3BF

LA395               ldd       $02,s
                    subd      ,s
                    std       $02,s
                    ldd       ,u
                    addd      ,s
LA39F               std       ,u
                    ldd       $02,s
                    bne       LA378
                    bra       LA3D0

LA3A7               ldd       $02,s
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      LB1C3
                    leas      $06,s
                    cmpd      $02,s
                    beq       LA3D0
                    bra       LA3C1

LA3BF               leas      -$04,x
LA3C1               ldd       $06,u
                    orb       #$20
                    std       $06,u
                    ldd       $04,u
                    std       ,u
                    ldd       #$FFFF
                    bra       LA3E0

LA3D0               ldd       $06,u
                    ora       #$01
                    std       $06,u
                    ldd       $02,u
                    std       ,u
                    addd      $0b,u
                    std       $04,u
                    clra
                    clrb
LA3E0               leas      $04,s
                    puls      pc,u
LA3E4               pshs      u
                    ldu       $04,s
                    beq       LA430
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       LA430
                    ldd       ,u
                    cmpd      $04,u
                    bcc       LA40C
                    ldd       ,u
                    addd      #$0001
                    std       ,u
                    subd      #$0001
                    tfr       d,x
                    ldb       ,x
                    clra
                    lbra      LA536

LA40C               pshs      u
                    lbsr      LA47F
                    lbra      LA534
                    pshs      u
                    ldu       $06,s
                    beq       LA430
                    ldd       $06,u
                    clra
                    andb      #$01
                    beq       LA430
                    ldd       $04,s
                    cmpd      #$FFFF
                    beq       LA430
                    ldd       ,u
                    cmpd      $02,u
                    bhi       LA435
LA430               ldd       #$FFFF
                    puls      pc,u
LA435               ldd       ,u
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
                    lbsr      LA3E4
                    leas      $02,s
                    std       $02,s
                    cmpd      #$FFFF
                    beq       LA46A
                    pshs      u
                    lbsr      LA3E4
                    leas      $02,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       LA46F
LA46A               ldd       #$FFFF
                    bra       LA47B

LA46F               ldd       $02,s
                    pshs      d
                    ldd       #$0008
                    lbsr      LB08C
                    addd      ,s
LA47B               leas      $04,s
                    puls      pc,u
LA47F               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    ldd       $06,u
                    anda      #$80
                    andb      #$31
                    cmpd      #$8001
                    beq       LA4A5
                    ldd       $06,u
                    clra
                    andb      #$31
                    cmpd      #$0001
                    lbne      LA51E
                    pshs      u
                    lbsr      LA538
                    leas      $02,s
LA4A5               leax      $0246,y
                    pshs      x
                    cmpu      ,s++
                    bne       LA4C2
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       LA4C2
                    leax      $0253,y
                    pshs      x
                    lbsr      LA2F8
                    leas      $02,s
LA4C2               ldd       $06,u
                    clra
                    andb      #$08
                    beq       LA4EE
                    ldd       $0b,u
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       LA4E2
                    leax      LB1B3,pcr
                    bra       LA4E6

LA4E2               leax      LB192,pcr
LA4E6               tfr       x,d
                    tfr       d,x
                    jsr       ,x
                    bra       LA500

LA4EE               ldd       #$0001
                    pshs      d
                    leax      $0a,u
                    stx       $02,u
                    pshs      x
                    ldd       $08,u
                    pshs      d
                    lbsr      LB192
LA500               leas      $06,s
                    std       ,s
                    ldd       ,s
                    bgt       LA523
                    ldd       $06,u
                    pshs      d
                    ldd       $02,s
                    beq       LA515
                    ldd       #$0020
                    bra       LA518

LA515               ldd       #$0010
LA518               ora       ,s+
                    orb       ,s+
                    std       $06,u
LA51E               ldd       #$FFFF
                    bra       LA534

LA523               ldd       $02,u
                    addd      #$0001
                    std       ,u
                    ldd       $02,u
                    addd      ,s
                    std       $04,u
                    ldb       [$02,u]
                    clra
LA534               leas      $02,s
LA536               puls      pc,u
LA538               pshs      u
                    ldu       $04,s
                    ldd       $06,u
                    clra
                    andb      #$C0
                    bne       LA570
                    leas      -$20,s
                    leax      ,s
                    pshs      x
                    ldd       $08,u
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    lbsr      LB0A7
                    leas      $06,s
                    ldd       $06,u
                    pshs      d
                    ldb       $02,s
                    bne       LA564
                    ldd       #$0040
                    bra       LA567

LA564               ldd       #$0080
LA567               ora       ,s+
                    orb       ,s+
                    std       $06,u
                    leas      $20,s
LA570               ldd       $06,u
                    ora       #$80
                    std       $06,u
                    clra
                    andb      #$0C
                    beq       LA57D
                    puls      pc,u
LA57D               ldd       $0b,u
                    bne       LA592
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       LA58D
                    ldd       #$0080
                    bra       LA590

LA58D               ldd       #$0100
LA590               std       $0b,u
LA592               ldd       $02,u
                    bne       LA5A7
                    ldd       $0b,u
                    pshs      d
                    lbsr      LB2AA
                    leas      $02,s
                    std       $02,u
                    cmpd      #$FFFF
                    beq       LA5AF
LA5A7               ldd       $06,u
                    orb       #$08
                    std       $06,u
                    bra       LA5BE

LA5AF               ldd       $06,u
                    orb       #$04
                    std       $06,u
                    leax      $0a,u
                    stx       $02,u
                    ldd       #$0001
                    std       $0b,u
LA5BE               ldd       $02,u
                    addd      $0b,u
                    std       $04,u
                    std       ,u
                    puls      pc,u
LA5C8               pshs      u
                    ldu       $04,s
LA5CC               ldb       ,u+
                    bne       LA5CC
                    tfr       u,d
                    subd      $04,s
                    addd      #$FFFF
                    puls      pc,u
LA5D9               pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
LA5E3               ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       LA5E3
                    bra       LA618

LA5F1               pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
LA5FB               ldx       ,s
                    leax      $01,x
                    stx       ,s
                    ldb       -$01,x
                    bne       LA5FB
                    ldd       ,s
                    addd      #$FFFF
                    std       ,s
LA60C               ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       LA60C
LA618               ldd       $06,s
                    leas      $02,s
                    puls      pc,u
                    pshs      u
                    ldu       $04,s
                    bra       LA634

LA624               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    bne       LA632
                    clra
                    clrb
                    puls      pc,u
LA632               leau      $01,u
LA634               ldb       ,u
                    sex
                    pshs      d
                    ldb       [$08,s]
                    sex
                    cmpd      ,s++
                    beq       LA624
                    ldb       [$06,s]
                    sex
                    pshs      d
                    ldb       ,u
                    sex
                    subd      ,s++
                    puls      pc,u
LA64F               pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
LA659               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    subd      #$FFFF
                    ble       LA67D
                    ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       LA659
                    bra       LA67D

LA673               clra
                    clrb
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
LA67D               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    subd      #$FFFF
                    bgt       LA673
                    lbra      LA70C

LA68C               pshs      u
                    ldu       $04,s
                    bra       LA6A2

LA692               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    bne       LA6A0
                    clra
                    clrb
                    puls      pc,u
LA6A0               leau      $01,u
LA6A2               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    ble       LA6BC
                    ldb       ,u
                    sex
                    pshs      d
                    ldb       [$08,s]
                    sex
                    cmpd      ,s++
                    beq       LA692
LA6BC               ldd       $08,s
                    bge       LA6C4
                    clra
                    clrb
                    bra       LA6CF

LA6C4               ldb       [$06,s]
                    sex
                    pshs      d
                    ldb       ,u
                    sex
                    subd      ,s++
LA6CF               puls      pc,u
LA6D1               pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
LA6DB               ldx       ,s
                    leax      $01,x
                    stx       ,s
                    ldb       -$01,x
                    bne       LA6DB
                    ldd       ,s
                    addd      #$FFFF
                    std       ,s
LA6EC               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    subd      #$FFFF
                    ble       LA704
                    ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       LA6EC
LA704               ldd       $0a,s
                    bge       LA70C
                    clra
                    clrb
                    stb       [,s]
LA70C               ldd       $06,s
                    leas      $02,s
                    puls      pc,u
                    pshs      u
                    ldu       $04,s
LA716               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    stb       ,u+
                    bgt       LA716
                    ldb       -$01,u
                    clra
                    andb      #$7f
                    stb       -$01,u
                    clra
                    clrb
                    stb       ,u
                    ldd       $04,s
                    puls      pc,u
LA731               ldx       $02,s
                    lbsr      LAE0D
                    bsr       LA739
                    rts

LA739               pshs      u
                    leas      -$1e,s
                    tfr       s,u
                    clr       $1d,u
                    clr       $19,u
                    lbsr      LA9B3
                    lbra      LA7D8

LA74C               ldd       ,x
                    eora      #$80
                    lbra      LAD71
                    lbsr      LABCB
                    lbsr      LA8AD
                    lbra      LA7D8
                    lbsr      LABCB
                    lbsr      LA883
                    lbra      LA7D8

LA765               lbsr      LABCB
                    lbsr      LAA26
                    bra       LA7D8

LA76D               lbsr      LABCB
                    lbsr      LAA52
                    bra       LA7D8

LA775               lbsr      LAD6F
                    lbra      LAC6F

LA77B               bsr       LA775
                    ldd       $02,x
                    rts

LA780               ldd       ,x
                    std       $0358,y
                    ldd       $02,x
                    leax      $0358,y
                    std       $02,x
                    lbra      LAC0F

LA791               leax      $0358,y
                    std       $02,x
                    tfr       a,b
                    sex
                    tfr       a,b
                    std       ,x
                    lbra      LAC0F
                    leax      $0358,y
                    std       $02,x
                    clr       ,x
                    clr       $01,x
                    lbra      LAC0F

LA7AE               ldd       ,x
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

LA7D8               leax      $0358,y
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
                    bmi       LA86B
                    lda       $02,s
                    bmi       LA83E
                    lda       $09,s
                    beq       LA837
                    ldb       $07,x
                    beq       LA86F
                    cmpa      $07,x
                    bne       LA842
                    ldd       $02,s
                    cmpd      ,x
                    bne       LA842
                    ldd       $04,s
                    cmpd      $02,x
                    bne       LA842
                    ldd       $06,s
                    cmpd      $04,x
                    bne       LA842
                    lda       $08,s
                    anda      #$FE
                    pshs      a
                    ldb       $06,x
                    andb      #$FE
                    cmpa      ,s+
                    bne       LA842
                    bra       LA873

LA837               lda       $07,x
                    bne       LA87E
                    clra
                    bra       LA873

LA83E               lda       $07,x
                    cmpa      $09,s
LA842               bhi       LA86F
                    bcs       LA87E
                    ldd       ,x
                    cmpd      $02,s
                    bne       LA842
                    ldd       $02,x
                    cmpd      $04,s
                    bne       LA842
                    ldd       $04,x
                    cmpd      $06,s
                    bne       LA842
                    lda       $06,x
                    anda      #$FE
                    pshs      a
                    lda       $08,s
                    anda      #$FE
                    cmpa      ,s+
                    bne       LA842
                    bra       LA873

LA86B               lda       ,x
                    bpl       LA87E
LA86F               lda       #$01
                    andcc     #$FE
LA873               pshs      cc
                    ldd       $01,s
                    std       $09,s
                    puls      cc
                    leas      $08,s
                    rts

LA87E               clra
                    cmpa      #$01
                    bra       LA873

LA883               lda       $17,u
                    beq       LA8A4
                    ldb       $1C,u
                    eorb      #$80
                    stb       $1C,u
                    eorb      $18,u
                    stb       $19,u
                    ldb       $29,u
                    bne       LA8B6
                    lbsr      LAD3F
                    lda       $22,u
                    lbra      LA9F6

LA8A4               lda       $22,u
                    ldb       $18,u
                    lbra      LA9F9

LA8AD               lbeq      LAD3F
                    lda       $17,u
                    beq       LA8A4
LA8B6               suba      $29,u
                    beq       LA8E7
                    sta       ,u
                    bcs       LA8ED
                    ldb       $17,u
                    stb       $29,u
                    ldd       $22,u
LA8C8               lsra
                    rorb
                    ror       $24,u
                    ror       $25,u
                    ror       $26,u
                    ror       $27,u
                    ror       $28,u
                    dec       ,u
                    bne       LA8C8
                    std       $22,u
LA8E0               lda       $19,u
                    bmi       LA95C
                    bra       LA90D

LA8E7               inc       ,u
                    orcc      #$01
                    bra       LA8E0

LA8ED               ldd       $10,u
LA8F0               lsra
                    rorb
                    ror       $12,u
                    ror       $13,u
                    ror       $14,u
                    ror       $15,u
                    ror       $16,u
                    inc       ,u
                    bne       LA8F0
                    std       $10,u
                    lda       $19,u
                    bmi       LA95F
LA90D               ldd       $27,u
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
                    bcc       LA954
                    inc       $29,u
                    ror       $22,u
                    ror       $23,u
                    ror       $24,u
                    ror       $25,u
                    ror       $26,u
                    ror       $27,u
                    ror       $28,u
LA954               lda       $1C,u
                    sta       $19,u
                    bra       LA9B3

LA95C               rola
                    coma
                    asra
LA95F               ldd       $27,u
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
                    bcc       LA9B0
                    com       $22,u
                    com       $23,u
                    com       $24,u
                    com       $25,u
                    com       $26,u
                    com       $27,u
                    com       $28,u
                    lda       ,u
                    beq       LA9AD
                    lbsr      LACFC
LA9AD               lda       $1C,u
LA9B0               sta       $19,u
LA9B3               clr       ,u
LA9B5               lda       $22,u
                    bmi       LA9F6
                    ora       $23,u
                    ora       $24,u
                    ora       $25,u
                    ora       $26,u
                    ora       $27,u
                    ora       $28,u
                    beq       LAA0A
                    ldd       $22,u
LA9D1               dec       $29,u
                    bne       LA9D9
                    dec       $1d,u
LA9D9               asl       ,u
                    rol       $28,u
                    rol       $27,u
                    rol       $26,u
                    rol       $25,u
                    rol       $24,u
                    rolb
                    rola
                    bpl       LA9D1
                    stb       $23,u
                    ldb       $29,u
                    beq       LAA0E
LA9F6               ldb       $19,u
LA9F9               anda      #$7f
                    andb      #$80
                    pshs      b
                    adda      ,s+
                    sta       $22,u
                    tst       $1d,u
                    bne       LAA0E
LAA09               rts

LAA0A               sta       $29,u
                    rts

LAA0E               lda       $1d,u
                    ldb       $29,u
                    subd      #$0000
                    beq       LAA21
                    bmi       LAA21
LAA1B               ldd       #$0028
                    lbra      LB098

LAA21               lbsr      LAA4C
                    bra       LAA1B

LAA26               beq       LAA4C
                    lda       $17,u
                    beq       LAA4C
                    lbsr      LAAC8
                    clra
                    ldb       $29,u
                    addb      $17,u
                    adca      #$00
                    subd      #$0080
                    stb       $29,u
                    sta       $1d,u
                    lbsr      LA9B5
                    lda       ,u
                    bpl       LAA09
                    lbra      LACFC

LAA4C               clra
                    sta       $29,u
                    bra       LAAB2

LAA52               ldb       $17,u
                    bne       LAA5D
                    ldd       #$0029
                    lbra      LB098

LAA5D               tsta
                    beq       LAA4C
                    lbsr      LAB26
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
                    lbsr      LA9B5
                    lda       ,u
                    bpl       LAAC7
                    lbra      LACFC

LAA9A               pshs      a
                    ldd       $22,u
                    std       ,u
                    ldd       $24,u
                    std       $02,u
                    ldd       $26,u
                    std       $04,u
                    ldb       $28,u
                    stb       $06,u
                    puls      a
LAAB2               sta       $22,u
                    sta       $23,u
                    sta       $24,u
                    sta       $25,u
                    sta       $26,u
                    sta       $27,u
                    sta       $28,u
LAAC7               rts

LAAC8               clra
                    bsr       LAA9A
                    ldb       #$38
                    stb       $08,u
LAACF               lda       $06,u
                    lsra
                    bcc       LAAFE
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
LAAFE               ror       $22,u
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
                    bne       LAACF
                    rts

LAB26               clra
                    lbsr      LAA9A
                    ldb       #$39
                    stb       $08,u
LAB2E               ldb       ,u
                    cmpb      $10,u
                    bcs       LAB65
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
                    bcs       LAB65
                    std       ,u
                    lda       $0a,u
                    sta       $02,u
                    ldd       $0b,u
                    std       $03,u
                    ldd       $0d,u
                    std       $05,u
LAB65               rol       $28,u
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
                    bhi       LAB2E
                    beq       LABB3
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
                    bra       LAB65

LABB3               ror       ,u
                    com       $22,u
                    com       $23,u
                    com       $24,u
                    com       $25,u
                    com       $26,u
                    com       $27,u
                    com       $28,u
                    rts

LABCB               puls      d
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
LAC0F               lda       #$A0
                    sta       $07,x
                    clr       $04,x
                    clr       $05,x
                    clr       $06,x
                    lda       ,x
                    tfr       a,b
                    orb       $01,x
                    orb       $02,x
                    orb       $03,x
                    beq       LAC5B
                    ldb       $01,x
                    tsta
                    bpl       LAC3D
                    pshs      d
                    clra
                    clrb
                    subd      $02,x
                    std       $02,x
                    ldd       #$0000
                    sbcb      $01,s
                    sbca      ,s
                    leas      $02,s
                    bvs       LAC47
LAC3D               dec       $07,x
                    asl       $03,x
                    rol       $02,x
                    rolb
                    rola
                    bpl       LAC3D
LAC47               anda      #$7f
                    tst       ,x
                    bpl       LAC4F
                    ora       #$80
LAC4F               std       ,x
                    rts
                    leax      $22,u
                    clr       $04,x
                    clr       $05,x
                    clr       $06,x
LAC5B               clr       $07,x
LAC5D               clr       ,x
                    clr       $01,x
                    clr       $02,x
                    clr       $03,x
                    rts

LAC66               ldd       #$002A
                    lbra      LB098
                    leax      $22,u
LAC6F               ldb       $07,x
                    beq       LAC5D
                    subb      #$81
                    bcs       LACEE
                    negb
                    addb      #$1f
                    bmi       LAC66
                    bne       LAC93
                    ldd       ,x
                    cmpd      #$8000
                    bne       LAC66
                    lda       $02,x
                    ora       $03,x
                    ora       $04,x
                    ora       $05,x
                    ora       $06,x
                    bne       LAC66
                    rts

LAC93               pshs      b
                    ldd       ,x
                    bmi       LACA9
                    ora       #$80
LAC9B               lsra
                    rorb
                    ror       $02,x
                    ror       $03,x
                    dec       ,s
                    bne       LAC9B
                    std       ,x
                    puls      pc,b
LACA9               clr       ,-s
LACAB               lsra
                    rorb
                    ror       $02,x
                    ror       $03,x
                    ror       $04,x
                    ror       $05,x
                    ror       $06,x
                    bcc       LACBB
                    inc       ,s
LACBB               dec       $01,s
                    bne       LACAB
                    std       ,x
                    ldd       ,s++
                    bne       LACCD
                    lda       $04,x
                    ora       $05,x
                    ora       $06,x
                    beq       LACDE
LACCD               ldd       $02,x
                    addd      #$0001
                    std       $02,x
                    ldd       ,x
                    adcb      #$00
                    adca      #$00
                    bcs       LAC66
                    std       ,x
LACDE               clra
                    clrb
                    subd      $02,x
                    std       $02,x
                    ldd       #$0000
                    sbcb      $01,x
                    sbca      ,x
                    std       ,x
                    rts

LACEE               lda       ,x
                    lbpl      LAC5D
                    ldd       #$FFFF
                    std       $02,x
                    std       ,x
                    rts

LACFC               inc       $28,u
                    bne       LAD32
                    inc       $27,u
                    bne       LAD32
                    inc       $26,u
                    bne       LAD32
                    inc       $25,u
                    bne       LAD32
                    inc       $24,u
                    bne       LAD32
                    inc       $23,u
                    bne       LAD32
                    ldb       $22,u
                    tfr       b,a
                    anda      #$7f
                    inca
                    bpl       LAD29
                    inc       $29,u
                    anda      #$7f
LAD29               andb      #$80
                    pshs      b
                    adda      ,s+
                    sta       $22,u
LAD32               rts

LAD33               neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0081
                    leax      >LAD33,pcr
LAD3F               pshs      a
                    ldd       ,x
                    std       $22,u
                    ldd       $02,x
                    std       $24,u
                    ldd       $04,x
                    std       $26,u
                    ldd       $06,x
                    std       $28,u
                    puls      pc,a
LAD57               pshs      a
                    ldd       $22,u
                    std       ,x
                    ldd       $24,u
                    std       $02,x
                    ldd       $26,u
                    std       $04,x
                    ldd       $28,u
                    std       $06,x
                    puls      pc,a
LAD6F               ldd       ,x
LAD71               std       $0358,y
                    ldd       $02,x
                    std       $035a,y
                    ldd       $04,x
                    std       $035C,y
                    ldd       $06,x
                    leax      $0358,y
                    std       $06,x
                    rts
                    pshs      x
                    bsr       LAE0D
                    leax      LAD33,pcr
                    pshs      x
                    lbsr      LABCB
                    lbsr      LA8AD
LAD99               ldx       $2a,u
                    bsr       LAD57
                    ldx       $1e,u
                    leas      $2a,u
                    tfr       x,u
                    puls      pc,x
                    pshs      x
                    bsr       LAE0D
                    leax      >LAD33,pcr
                    pshs      x
                    lbsr      LABCB
                    lbsr      LA883
                    bra       LAD99
                    pshs      x
                    bsr       LADF6
                    leax      LAD33,pcr
                    pshs      x
                    lbsr      LABCB
                    lbsr      LA8AD
LADCA               ldx       $2a,u
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
                    bsr       LADF6
                    leax      LAD33,pcr
                    pshs      x
                    lbsr      LABCB
                    lbsr      LA883
                    bra       LADCA

LADF6               leas      -$08,s
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
                    rts

LAE0D               leas      -$08,s
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
                    rts

LAE24               pshs      u
                    ldu       $04,s
                    exg       x,u
                    ldd       ,u
                    std       ,x
                    ldd       $02,u
                    std       $02,x
                    bra       LAE4A

LAE34               pshs      u
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
LAE4A               puls      u
                    puls      d
                    std       ,s
                    rts

LAE51               ldd       $04,s
                    addd      $02,x
                    std       $035a,y
                    ldd       $02,s
                    adcb      $01,x
                    adca      ,x
                    std       $0358,y
                    lbra      LAF2D

LAE66               ldd       $04,s
                    subd      $02,x
                    std       $035a,y
                    ldd       $02,s
                    sbcb      $01,x
                    sbca      ,x
                    std       $0358,y
                    lbra      LAF2D

LAE7B               ldd       $02,s
                    cmpd      ,x
                    bne       LAE94
                    ldd       $04,s
                    cmpd      $02,x
                    beq       LAE94
                    bcs       LAE91
                    lda       #$01
                    andcc     #$FE
                    bra       LAE94

LAE91               clra
                    cmpa      #$01
LAE94               pshs      cc
                    ldd       $01,s
                    std       $05,s
                    puls      cc
                    leas      $04,s
                    rts

LAE9F               lbsr      LAF3C
                    ldd       #$0000
                    subd      $02,x
                    std       $02,x
                    ldd       #$0000
                    sbcb      $01,x
                    sbca      ,x
                    std       ,x
                    rts

LAEB3               ldd       ,x
                    coma
                    comb
                    std       $0358,y
                    ldd       $02,x
                    coma
                    comb
                    leax      $0358,y
                    std       $02,x
                    rts

LAEC6               leax      $0358,y
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
                    rts

LAEDF               pshs      y
                    ldy       $04,s
                    ldd       ,x
                    std       ,y
                    ldd       $02,x
                    std       $02,y
                    puls      x
                    exg       y,x
                    puls      d
                    std       ,s
                    rts

LAEF5               ldx       $02,s
                    pshs      b
                    lbsr      LAF3C
                    puls      b
                    tstb
                    beq       LAF0C
LAF01               asl       $03,x
                    rol       $02,x
                    rol       $01,x
                    rol       ,x
                    decb
                    bne       LAF01
LAF0C               puls      d
                    std       ,s
                    rts
                    ldx       $02,s
                    pshs      b
                    lbsr      LAF3C
                    puls      b
                    tstb
                    beq       LAF28
LAF1D               asr       ,x
                    ror       $01,x
                    ror       $02,x
                    ror       $03,x
                    decb
                    bne       LAF1D
LAF28               puls      d
                    std       ,s
                    rts

LAF2D               tfr       cc,a
                    puls      x
                    stx       $02,s
                    leas      $02,s
                    leax      $0358,y
                    tfr       a,cc
                    rts

LAF3C               ldd       ,x
                    std       $0358,y
                    ldd       $02,x
                    leax      $0358,y
                    std       $02,x
                    rts

LAF4B               tsta
                    bne       LAF60
                    tst       $02,s
                    bne       LAF60
                    lda       $03,s
                    mul
                    ldx       ,s
                    stx       $02,s
                    ldx       #$0000
                    std       ,s
                    puls      pc,d
LAF60               pshs      d
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
                    bcc       LAF7D
                    inc       ,s
LAF7D               lda       $04,s
                    ldb       $09,s
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       LAF8A
                    inc       ,s
LAF8A               lda       $04,s
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
                    leax      >LAFE6,pcr
                    stx       $089f,y
                    bra       LAFC0

LAFAC               leax      >LAFFF,pcr
                    stx       $089f,y
                    clr       $089e,y
                    tst       $02,s
                    bpl       LAFC0
                    inc       $089e,y
LAFC0               subd      #$0000
                    bne       LAFCB
                    puls      x
                    ldd       ,s++
                    jmp       ,x

LAFCB               ldx       $02,s
                    pshs      x
                    jsr       [$089f,y]
                    ldd       ,s
                    std       $02,s
                    tfr       x,d
                    tst       $089e,y
                    beq       LAFE3
                    nega
                    negb
                    sbca      #$00
LAFE3               std       ,s++
                    rts

LAFE6               subd      #$0000
                    beq       LAFF5
                    pshs      d
                    leas      -$02,s
                    clr       ,s
                    clr       $01,s
                    bra       LB023

LAFF5               puls      d
                    std       ,s
                    ldd       #$002D
                    lbra      LB098

LAFFF               subd      #$0000
                    beq       LAFF5
                    pshs      d
                    leas      -$02,s
                    clr       ,s
                    clr       $01,s
                    tsta
                    bpl       LB017
                    nega
                    negb
                    sbca      #$00
                    inc       $01,s
                    std       $02,s
LB017               ldd       $06,s
                    bpl       LB023
                    nega
                    negb
                    sbca      #$00
                    com       $01,s
                    std       $06,s
LB023               lda       #$01
LB025               inca
                    asl       $03,s
                    rol       $02,s
                    bpl       LB025
                    sta       ,s
                    ldd       $06,s
                    clr       $06,s
                    clr       $07,s
LB034               subd      $02,s
                    bcc       LB03E
                    addd      $02,s
                    andcc     #$FE
                    bra       LB040

LB03E               orcc      #$01
LB040               rol       $07,s
                    rol       $06,s
                    lsr       $02,s
                    ror       $03,s
                    dec       ,s
                    bne       LB034
                    std       $02,s
                    tst       $01,s
                    beq       LB05A
                    ldd       $06,s
                    nega
                    negb
                    sbca      #$00
                    std       $06,s
LB05A               ldx       $04,s
                    ldd       $06,s
                    std       $04,s
                    stx       $06,s
                    ldx       $02,s
                    ldd       $04,s
                    leas      $06,s
                    rts

LB069               tstb
                    beq       LB07F
LB06C               asr       $02,s
                    ror       $03,s
                    decb
                    bne       LB06C
                    bra       LB07F

LB075               tstb
                    beq       LB07F
LB078               lsr       $02,s
                    ror       $03,s
                    decb
                    bne       LB078
LB07F               ldd       $02,s
                    pshs      d
                    ldd       $02,s
                    std       $04,s
                    ldd       ,s
                    leas      $04,s
                    rts

LB08C               tstb
                    beq       LB07F
LB08F               asl       $03,s
                    rol       $02,s
                    decb
                    bne       LB08F
                    bra       LB07F

LB098               std       $0364,y
                    pshs      y,b
                    os9       F$ID
                    puls      y,b
                    os9       F$Send
                    rts

LB0A7               lda       $05,s
                    ldb       $03,s
                    beq       LB0DA
                    cmpb      #$01
                    beq       LB0DC
                    cmpb      #$06
                    beq       LB0DC
                    cmpb      #$02
                    beq       LB0C2
                    cmpb      #$05
                    beq       LB0C2
                    ldb       #$D0
                    lbra      LB33E

LB0C2               pshs      u
                    os9       I$GetStt
                    bcc       LB0CE
                    puls      u
                    lbra      LB33E

LB0CE               stx       [$08,s]
                    ldx       $08,s
                    stu       $02,x
                    puls      u
                    clra
                    clrb
                    rts

LB0DA               ldx       $06,s
LB0DC               os9       I$GetStt
                    lbra      LB347
                    lda       $05,s
                    ldb       $03,s
                    beq       LB0F1
                    cmpb      #$02
                    beq       LB0F9
                    ldb       #$D0
                    lbra      LB33E

LB0F1               ldx       $06,s
                    os9       I$SetStt
                    lbra      LB347

LB0F9               pshs      u
                    ldx       $08,s
                    ldu       $0a,s
                    os9       I$SetStt
                    puls      u
                    lbra      LB347
                    ldx       $02,s
                    lda       $05,s
                    os9       I$Open
                    bcs       LB113
                    os9       I$Close
LB113               lbra      LB347

LB116               ldx       $02,s
                    lda       $05,s
                    os9       I$Open
                    lbcs      LB33E
                    tfr       a,b
                    clra
                    rts

LB125               lda       $03,s
                    os9       I$Close
                    lbra      LB347
                    ldx       $02,s
                    ldb       $05,s
                    os9       I$MakDir
                    lbra      LB347

LB137               ldx       $02,s
                    lda       $05,s
                    tfr       a,b
                    andb      #$24
                    orb       #$0b
                    os9       I$Create
                    bcs       LB14A
LB146               tfr       a,b
                    clra
                    rts

LB14A               cmpb      #$DA
                    lbne      LB33E
                    lda       $05,s
                    bita      #$80
                    lbne      LB33E
                    anda      #$07
                    ldx       $02,s
                    os9       I$Open
                    lbcs      LB33E
                    pshs      u,a
                    ldx       #$0000
                    leau      ,x
                    ldb       #$02
                    os9       I$SetStt
                    puls      u,a
                    bcc       LB146
                    pshs      b
                    os9       I$Close
                    puls      b
                    lbra      LB33E

LB17D               ldx       $02,s
                    os9       I$Delete
                    lbra      LB347
                    lda       $03,s
                    os9       I$Dup
                    lbcs      LB33E
                    tfr       a,b
                    clra
                    rts

LB192               pshs      y
                    ldx       $06,s
                    lda       $05,s
                    ldy       $08,s
                    pshs      y
                    os9       I$Read
LB1A0               bcc       LB1AF
                    cmpb      #$D3
                    bne       LB1AA
                    clra
                    clrb
                    puls      pc,y,x
LB1AA               puls      y,x
                    lbra      LB33E

LB1AF               tfr       y,d
                    puls      pc,y,x
LB1B3               pshs      y
                    lda       $05,s
                    ldx       $06,s
                    ldy       $08,s
                    pshs      y
                    os9       I$ReadLn
                    bra       LB1A0

LB1C3               pshs      y
                    ldy       $08,s
                    beq       LB1D8
                    lda       $05,s
                    ldx       $06,s
                    os9       I$Write
LB1D1               bcc       LB1D8
                    puls      y
                    lbra      LB33E

LB1D8               tfr       y,d
                    puls      pc,y
LB1DC               pshs      y
                    ldy       $08,s
                    beq       LB1D8
                    lda       $05,s
                    ldx       $06,s
                    os9       I$WritLn
                    bra       LB1D1

LB1EC               pshs      u
                    ldd       $0a,s
                    bne       LB1FA
                    ldu       #$0000
                    ldx       #$0000
                    bra       LB22E

LB1FA               cmpd      #$0001
                    beq       LB225
                    cmpd      #$0002
                    beq       LB21A
                    ldb       #$F7
LB208               clra
                    std       $0364,y
                    ldd       #$FFFF
                    leax      $0358,y
                    std       ,x
                    std       $02,x
                    puls      pc,u
LB21A               lda       $05,s
                    ldb       #$02
                    os9       I$GetStt
                    bcs       LB208
                    bra       LB22E

LB225               lda       $05,s
                    ldb       #$05
                    os9       I$GetStt
                    bcs       LB208
LB22E               tfr       u,d
                    addd      $08,s
                    std       $035a,y
                    tfr       d,u
                    tfr       x,d
                    adcb      $07,s
                    adca      $06,s
                    bmi       LB208
                    tfr       d,x
                    std       $0358,y
                    lda       $05,s
                    os9       I$Seek
                    bcs       LB208
                    leax      $0358,y
                    puls      pc,u
LB253               ldd       $0356,y
                    pshs      d
                    ldd       $04,s
                    cmpd      $08A1,y
                    bcs       LB287
                    addd      $0356,y
                    pshs      y
                    subd      ,s
                    os9       F$Mem
                    tfr       y,d
                    puls      y
                    bcc       LB279
                    ldd       #$FFFF
                    leas      $02,s
                    rts

LB279               std       $0356,y
                    addd      $08A1,y
                    subd      ,s
                    std       $08A1,y
LB287               leas      $02,s
                    ldd       $08A1,y
                    pshs      d
                    subd      $04,s
                    std       $08A1,y
                    ldd       $0356,y
                    subd      ,s++
                    pshs      d
                    clra
                    ldx       ,s
LB2A0               sta       ,x+
                    cmpx      $0356,y
                    bcs       LB2A0
                    puls      pc,d
LB2AA               ldd       $02,s
                    addd      $0360,y
                    bcs       LB2D3
                    cmpd      $0362,y
                    bcc       LB2D3
                    pshs      d
                    ldx       $0360,y
                    clra
LB2C0               cmpx      ,s
                    bcc       LB2C8
                    sta       ,x+
                    bra       LB2C0

LB2C8               ldd       $0360,y
                    puls      x
                    stx       $0360,y
                    rts

LB2D3               ldd       #$FFFF
                    rts

LB2D7               pshs      y
                    os9       F$ID
                    puls      y
                    bcc       LB2E4
                    lbcs      LB33E
LB2E4               tfr       a,b
                    clra
                    rts

LB2E8               pshs      y
                    os9       F$ID
                    bcc       LB2F4
LB2EF               puls      y
                    lbra      LB33E

LB2F4               tfr       y,d
                    puls      pc,y
                    pshs      y
                    bsr       LB2E8
                    std       -$02,s
                    beq       LB304
                    ldb       #$D6
                    bra       LB2EF

LB304               ldy       $04,s
                    os9       F$SUser
                    bcc       LB318
                    cmpb      #$D0
                    bne       LB2EF
                    tfr       y,d
                    ldy       >$004B
                    std       $09,y
LB318               clra
                    clrb
                    puls      pc,y
LB31C               pshs      u
                    tfr       y,u
                    ldx       $04,s
                    stx       $08A3,y
                    leax      >LB332,pcr
                    os9       F$Icpt
                    puls      u
                    lbra      LB347

LB332               tfr       u,y
                    clra
                    pshs      d
                    jsr       [$08A3,y]
                    leas      $02,s
                    rti

LB33E               clra
                    std       $0364,y
                    ldd       #$FFFF
                    rts

LB347               bcs       LB33E
                    clra
                    clrb
                    rts

exit                lbsr      LB357
                    lbsr      LA295
LB352               ldd       $02,s
                    os9       F$Exit
LB357               rts

* ------------------------------------------------------------------
* LB358 - cc1-style init image for the work block (see _start):
* rts stub + count/block table + relocation dirs + module-name string.
* ------------------------------------------------------------------
LB358               fcb       $00,$03,$00,$02 init table / work-block image
                    fcb       $46
                    fcb       $02,$9E,$00,$01,$00,$02,$00,$00
                    fcb       $00,$00,$00,$0C,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$8C
                    fcc       /cstr.XXXXX/
                    fcb       $00
                    fcc       /x expected/
                    fcb       $00,$06,$83
                    fcc       /XmXpXsXyX/
                    fcb       $7F
                    fcb       $58
                    fcb       $84,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00
                    fcb       $6D,$40,$69
                    fcb       $00,$00
                    fcc       |TAh-.BP0CESkkkkkkkkkk/(]x_d|
                    fcb       $00
                    fcc       /jjjjjjjjjjjjjjjjjjjjjjjjjj+f,Yj/
                    fcb       $00
                    fcc       /jjjjjjjjjjjjjjjjjjjjjjjjjj)X*D/
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$09,$00,$00,$00,$0D,$0E
                    fcb       $00,$00,$00,$0E,$0C,$01,$0E,$0F
                    fcb       $0D,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$03,$00,$0A,$02,$0A
                    fcb       $03,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$07
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$06,$00,$0E
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $81
                    fcb       $20
                    fcb       $00,$00,$00,$00,$00,$00,$84
                    fcb       $48
                    fcb       $00,$00,$00,$00,$00,$00,$87
                    fcb       $7A
                    fcb       $00,$00,$00,$00,$00,$00,$8A,$1C
                    fcb       $40
                    fcb       $00,$00,$00,$00,$00,$8E
                    fcb       $43,$50
                    fcb       $00,$00,$00,$00,$00,$91
                    fcb       $74,$24
                    fcb       $00,$00,$00,$00,$00,$94,$18,$96
                    fcb       $80,$00,$00,$00,$00,$98
                    fcb       $3E
                    fcb       $BC
                    fcb       $20
                    fcb       $00,$00,$00,$00,$9B
                    fcb       $6E,$6B,$28
                    fcb       $00,$00,$00,$00,$9E,$15,$02,$F9
                    fcb       $00,$00,$00,$00,$A2
                    fcb       $2D,$78
                    fcb       $EB,$C5,$AC
                    fcb       $62
                    fcb       $00,$C3
                    fcb       $49
                    fcb       $F2,$C9,$CD,$04
                    fcb       $67,$4F
                    fcb       $E4,$00,$02,$00,$04,$00,$08,$00
                    fcb       $10,$00
                    fcb       $20
                    fcb       $00
                    fcb       $40
                    fcb       $00,$80,$01,$00,$02,$00,$04,$00
                    fcb       $08,$00,$10,$00
                    fcb       $20
                    fcb       $00
                    fcb       $40
                    fcb       $00
                    fcb       $27
                    fcb       $10,$03,$E8,$00
                    fcb       $64
                    fcb       $00,$0A,$00,$00,$00,$00,$00,$00
                    fcb       $00,$01,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$02,$00
                    fcb       $01,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00
                    fcb       $42
                    fcb       $00,$02,$00,$00,$00,$00,$00,$00
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
                    fcb       $00,$00,$00,$00,$00,$00,$00,$06
                    fcb       $00,$B8,$00,$B6,$00,$B4,$00,$B2
                    fcb       $00,$B0,$00,$AE,$00,$03,$00,$94
                    fcb       $00,$AC,$00,$01
                    fcc       /c.comp/
                    fcb       $00
                    emod
eom                 equ       *
                    end
