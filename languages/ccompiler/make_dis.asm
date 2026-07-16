                    nam       make
                    ttl       program module

                    use       defsfile

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       $12

                    mod       eom,name,tylg,atrv,_start,size

u0000               rmb       6775
size                equ       .

name                equ       *
                    fcs       /make/
                    fcb       edition

copybytes           lda       ,y+
L0014               sta       ,u+
                    leax      -$01,x
                    bne       copybytes
                    rts

_start              pshs      y
L001D               pshs      u
L001F               clra
L0020               clrb
L0021               sta       ,u+
L0023               decb
L0024               bne       L0021
                    ldx       ,s
                    leau      ,x
L002A               leax      $16F7,x
L002E               pshs      x
L0030               leay      L3A9B,pcr
L0034               ldx       ,y++
                    beq       L003C
                    bsr       copybytes
L003A               ldu       $02,s
L003C               leau      >$0029,u
L0040               ldx       ,y++
                    beq       L0047
                    bsr       copybytes
                    clra
L0047               cmpu      ,s
                    beq       L0050
                    sta       ,u+
                    bra       L0047

L0050               ldu       $02,s
                    ldd       ,y++
                    beq       L005D
                    leax      >$0000,pcr
                    lbsr      L014F
L005D               ldd       ,y++
                    beq       L0066
L0061               leax      ,u
L0063               lbsr      L014F
L0066               leas      $04,s
                    puls      x
                    stx       $01EF,u
L006E               pshs      y
L0070               ldy       #$0001
L0074               leax      $02,s
L0076               lda       ,x+
L0078               cmpa      #$0d
L007A               beq       L00BA
                    cmpa      #$20
                    beq       L0076
L0080               cmpa      #$2C
                    beq       L0076
                    cmpa      #$22
                    beq       L00A4
                    cmpa      #$27
                    beq       L00A4
                    leax      -$01,x
                    pshs      x
                    leay      $01,y
L0092               lda       ,x+
                    beq       L00B4
                    cmpa      #$0d
                    beq       L00B4
                    cmpa      #$20
                    beq       L00B4
                    cmpa      #$2C
                    beq       L00B4
                    bra       L0092

L00A4               pshs      x,a
                    leay      $01,y
L00A8               lda       ,x+
                    cmpa      #$0d
                    beq       L00B2
                    cmpa      ,s
                    bne       L00A8
L00B2               puls      b
L00B4               clr       -$01,x
                    cmpa      #$0d
                    bne       L0076
L00BA               tfr       y,d
                    leax      ,s
                    pshs      x,d
                    aslb
                    rola
                    leay      d,x
                    pshs      u
                    bra       L00D0

L00C8               ldd       ,x
                    ldu       ,y
                    std       ,y
                    stu       ,x++
L00D0               leay      -$02,y
                    pshs      y
                    cmpx      ,s++
                    bcs       L00C8
                    puls      y
                    bsr       L00E6
                    puls      d
                    lbsr      L0178
                    clra
                    clrb
                    lbsr      L3949
L00E6               leax      $16F7,y
                    stx       $01F9,y
                    sts       $01ED,y
                    sts       $01FB,y
                    ldd       #$FF82
L00FB               leax      d,s
                    cmpx      $01FB,y
                    bcc       L010D
                    cmpx      $01F9,y
                    bcs       L0127
                    stx       $01FB,y
L010D               rts

L010E               bpl       L013A
                    bpl       $013C
                    bra       $0167
                    lsrb
                    fcb       $41
                    coma
                    fcb       $4B
                    bra       L0169
                    rorb
                    fcb       $45,$52
                    rora
                    inca
                    clra
                    asrb
                    bra       $014D
                    bpl       L014F
                    bpl       L0134
L0127               leax      L010E,pcr
                    ldb       #$CF
                    pshs      b
                    lda       #$02
                    ldy       #$0064
L0134               os9       I$WritLn
                    clra
                    puls      b
L013A               lbsr      L3953
                    ldd       $01ED,y
                    subd      $01FB,y
                    rts
                    ldd       $01FB,y
                    subd      $01F9,y
                    rts

L014F               pshs      x
                    leax      d,y
                    leax      d,x
                    pshs      x
L0157               ldd       ,y++
                    leax      d,u
                    ldd       ,x
                    addd      $02,s
                    std       ,x
                    cmpy      ,s
                    bne       L0157
                    leas      $04,s
                    rts

L0169               pshs      u,d
                    ldd       #$FFBE
                    lbsr      L00FB
                    ldd       ,s
                    std       $0017
                    lbra      L03E0

L0178               pshs      u
                    tfr       d,u
                    ldd       #$FFB2
                    lbsr      L00FB
                    leas      -$08,s
                    clra
                    clrb
                    std       $02,s
                    lbsr      L0290
                    ldd       $0C,s
                    std       $000D
                    leax      -$01,u
                    stx       $0013
                    lbra      L0208

L0196               ldx       $0C,s
                    leax      $02,x
                    stx       $0C,s
                    ldd       ,x
                    std       $04,s
                    tfr       d,x
                    ldb       ,x
                    cmpb      #$2d
                    bne       L01C0
                    ldd       $04,s
                    addd      #$0001
                    std       $04,s
                    lbsr      L02B2
                    ldd       $0013
                    addd      #$FFFF
                    std       $0013
                    clra
                    clrb
                    std       [$0C,s]
                    bra       L0208

L01C0               ldd       $04,s
                    std       $06,s
                    bra       L01F2

L01C6               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    cmpb      #$3d
                    bne       L01F2
                    ldd       $06,s
                    pshs      d
                    ldd       $06,s
                    lbsr      L228E
                    leas      $02,s
                    ldd       $02,s
                    addd      #$0001
                    std       $02,s
                    ldd       $0013
                    addd      #$FFFF
                    std       $0013
                    clra
                    clrb
                    std       [$0C,s]
                    bra       L01F7

L01F2               ldb       [$06,s]
                    bne       L01C6
L01F7               ldd       $02,s
                    beq       L0201
                    clra
                    clrb
                    std       $02,s
                    bra       L0208

L0201               ldd       $0011
                    addd      #$0001
                    std       $0011
L0208               leau      -$01,u
                    stu       -$02,s
                    lbgt      L0196
                    lbsr      L04A4
                    ldd       $01FF,y
                    bne       L0221
                    leax      L09D6,pcr
                    stx       $01FF,y
L0221               ldd       $0201,y
                    lbne      L0285
                    leax      L09D8,pcr
                    stx       $0201,y
                    bra       L0285

L0233               ldd       $04,s
                    lbsr      L2038
                    std       ,s
                    clra
                    clrb
                    lbsr      L3900
                    ldd       $0211,y
                    bne       L024A
                    ldd       ,s
                    lbsr      L0E04
L024A               ldd       ,s
                    lbsr      L1468
                    leax      L0169,pcr
                    tfr       x,d
                    lbsr      L3900
                    ldx       ,s
                    ldd       $04,x
                    beq       L0265
                    tfr       x,d
                    lbsr      L137E
                    bra       L026A

L0265               tfr       x,d
                    lbsr      L16C5
L026A               ldd       $022f,y
                    bne       L0285
                    ldd       $04,s
                    pshs      d
                    leax      L09DA,pcr
                    tfr       x,d
                    lbsr      L28EF
                    leas      $02,s
                    clra
                    clrb
                    std       $022f,y
L0285               lbsr      L0406
                    std       $04,s
                    bne       L0233
                    leas      $08,s
                    puls      pc,u
L0290               pshs      u
                    ldd       #$FFC0
                    lbsr      L00FB
                    leax      L09E9,pcr
                    stx       $020b,y
                    leax      L09EC,pcr
                    stx       $020f,y
                    leax      L09EF,pcr
                    stx       $020d,y
                    puls      pc,u
L02B2               pshs      u
                    tfr       d,u
                    ldd       #$FFBA
                    lbsr      L00FB
                    leas      -$02,s
                    clra
                    clrb
                    std       ,s
                    lbra      L03DA

L02C5               ldb       ,u+
                    sex
                    lbsr      L318C
                    tfr       d,x
                    lbra      L0383

L02D0               ldd       $0211,y
                    addd      #$0001
                    std       $0211,y
                    lbra      L03DA

L02DE               ldd       $0213,y
                    addd      #$0001
                    std       $0213,y
                    lbra      L03DA

L02EC               ldb       ,u
                    cmpb      #$3d
                    bne       L02F4
                    leau      $01,u
L02F4               tfr       u,d
                    std       $0009
                    lbra      L03E0

L02FB               ldd       $0215,y
                    addd      #$0001
                    std       $0215,y
                    lbra      L03DA

L0309               ldd       $0217,y
                    addd      #$0001
                    std       $0217,y
                    lbra      L03DA

L0317               ldd       $0219,y
                    addd      #$0001
                    std       $0219,y
                    lbra      L03DA

L0325               ldd       $021b,y
                    addd      #$0001
                    std       $021b,y
                    lbra      L03DA

L0333               ldd       $021f,y
                    addd      #$0001
                    std       $021f,y
                    lbra      L03DA

L0341               ldd       $021d,y
                    addd      #$0001
                    std       $021d,y
                    lbra      L03DA

L034F               ldd       $0221,y
                    addd      #$0001
                    std       $0221,y
                    ldb       ,u
                    cmpb      #$3d
                    lbne      L03DA
                    ldb       $01,u
                    lbeq      L03DA
                    leax      $01,u
                    stx       $000F
                    lbra      L03E0
                    bra       L03DA

L0371               lbsr      L03E4
                    clra
                    clrb
                    lbsr      L3949
L0379               bsr       L03E4
                    ldd       #$00D7
                    lbsr      L3949
                    bra       L03DA

L0383               cmpx      #$0062
                    lbeq      L02D0
                    cmpx      #$0064
                    lbeq      L02DE
                    cmpx      #$0066
                    lbeq      L02EC
                    cmpx      #$0020
                    beq       L03E0
                    cmpx      #$000D
                    beq       L03E0
                    cmpx      #$0069
                    lbeq      L02FB
                    cmpx      #$006E
                    lbeq      L0309
                    cmpx      #$0073
                    lbeq      L0317
                    cmpx      #$0074
                    lbeq      L0325
                    cmpx      #$0078
                    lbeq      L0333
                    cmpx      #$0075
                    lbeq      L0341
                    cmpx      #$007A
                    lbeq      L034F
                    cmpx      #$003F
                    beq       L0371
                    bra       L0379

L03DA               ldb       ,u
                    lbne      L02C5
L03E0               leas      $02,s
                    puls      pc,u
L03E4               pshs      u
                    ldd       #$FFBA
                    lbsr      L00FB
                    leau      >$002b,y
                    bra       L03FF

L03F2               leax      $00A7,y
                    pshs      x
                    ldd       ,u++
                    lbsr      L280A
                    leas      $02,s
L03FF               cmpu      $0001
                    bcs       L03F2
                    puls      pc,u
L0406               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FB
                    ldb       $0231,y
                    beq       L0426
                    ldd       $0015
                    lbne      L04A0
                    ldd       #$0001
                    std       $0015
                    leax      $0231,y
                    lbra      L049C

L0426               ldd       $0013
                    beq       L043F
                    addd      #$FFFF
                    std       $0013
L042F               ldx       $000D
                    leax      $02,x
                    stx       $000D
                    ldd       ,x
                    beq       L042F
                    ldd       [$000D,y]
                    puls      pc,u
L043F               ldd       $0221,y
                    beq       L04A0
                    ldd       $0281,y
                    bne       L0460
                    ldd       $000F
                    beq       L0458
                    lbsr      L070A
                    std       $0281,y
                    bra       L0460

L0458               leax      $009a,y
                    stx       $0281,y
L0460               ldd       $0281,y
                    pshs      d
                    ldd       #$0050
                    pshs      d
                    leax      $0283,y
                    tfr       x,d
                    lbsr      L2863
                    leas      $04,s
                    std       -$02,s
                    beq       L04A0
                    ldb       $0283,y
                    cmpb      #$0d
                    beq       L04A0
                    leax      $0283,y
                    tfr       x,d
                    lbsr      $33CF
                    addd      #$FFFF
                    leax      $0283,y
                    leax      d,x
                    clra
                    clrb
                    stb       ,x
                    leax      $0283,y
L049C               tfr       x,d
                    puls      pc,u
L04A0               clra
                    clrb
                    puls      pc,u
L04A4               pshs      u
                    ldd       #$FFA0
                    lbsr      L00FB
                    leas      -$18,s
                    clra
                    clrb
                    std       $0019
                    lbsr      L06DE
                    std       $000B
                    lbra      L06C7

L04BB               ldb       ,u
                    cmpb      #$20
                    bne       L0503
                    leau      $01,u
                    tfr       u,d
                    lbsr      L0DDD
                    std       $08,s
                    ldd       $0019
                    std       $10,s
                    beq       L04EF
L04D1               ldd       [$10,s]
                    std       $16,s
                    ldx       [$16,s]
                    ldd       $04,x
                    bne       L04E2
                    ldd       $08,s
                    std       $04,x
L04E2               ldx       $10,s
                    ldd       $02,x
                    std       $10,s
                    bne       L04D1
                    lbra      L06C7

L04EF               leax      L0C70,pcr
                    pshs      x
                    ldd       #$0001
                    lbsr      L2227
                    leas      $02,s
                    lbsr      L3949
                    lbra      L06C7

L0503               ldd       $0019
                    std       $10,s
                    beq       L0521
L050A               ldx       $10,s
                    ldd       $02,x
                    std       $0e,s
                    tfr       x,d
                    lbsr      L3602
                    ldd       $0e,s
                    std       $10,s
                    bne       L050A
                    clra
                    clrb
                    std       $0019
L0521               leax      >$0019,y
                    stx       _start
                    clra
                    clrb
                    std       ,s
                    ldu       $06,s
                    tfr       u,d
                    std       $0C,s
                    bra       L0573

L0533               ldb       ,u+
                    sex
                    tfr       d,x
                    bra       L0563

L053A               pshs      u
                    ldd       $08,s
                    lbsr      L228E
                    leas      $02,s
                    ldd       ,s
                    addd      #$0001
                    std       ,s
                    bra       L0577

L054C               ldd       $0a,s
                    pshs      d
                    leax      L0C95,pcr
                    pshs      x
                    ldd       #$0001
                    lbsr      L2227
                    leas      $04,s
                    lbsr      L3949
                    bra       L0573

L0563               cmpx      #$003D
                    beq       L053A
                    cmpx      #$003A
                    beq       L0577
                    stx       -$02,s
                    beq       L054C
                    bra       L0573

L0573               ldb       ,u
                    bne       L0533
L0577               ldd       ,s
                    beq       L0584
                    clra
                    clrb
                    std       ,s
                    lbra      L06C7

L0582               leau      $01,u
L0584               ldb       ,u
                    cmpb      #$20
                    beq       L0582
                    cmpb      #$09
                    lbeq      L0582
                    std       -$02,s
                    beq       L05A4
                    tfr       u,d
                    lbsr      $33CF
                    pshs      d
                    tfr       u,d
                    lbsr      L0D03
                    leas      $02,s
                    bra       L05A6

L05A4               clra
                    clrb
L05A6               std       $14,s
                    clra
                    clrb
                    std       $02,s
                    ldd       $0C,s
                    std       $0a,s
                    clra
                    clrb
                    std       $04,s
                    lbra      L06C1

L05B8               ldb       [$0C,s]
                    sex
                    tfr       d,x
                    bra       L05D8

L05C0               ldd       #$0001
                    std       $02,s
                    bra       L05E9

L05C7               ldd       $04,s
                    addd      #$0001
                    std       $04,s
                    ldd       $0C,s
                    addd      #$0001
                    std       $0C,s
                    lbra      L06C1

L05D8               cmpx      #$003A
                    beq       L05C0
                    cmpx      #$0020
                    beq       L05E9
                    cmpx      #$0009
                    beq       L05E9
                    bra       L05C7

L05E9               ldd       $04,s
                    lbeq      L06C7
                    clra
                    clrb
                    std       $04,s
                    ldx       $0C,s
                    leax      $01,x
                    stx       $0C,s
                    stb       -$01,x
                    ldd       $0a,s
                    lbsr      L1FF8
                    std       $16,s
L0603               ldx       $16,s
                    ldd       $04,x
                    beq       L063C
                    ldd       $04,x
                    bra       L0613

L060E               ldx       $12,s
                    ldd       $02,x
L0613               std       $12,s
                    ldx       $12,s
                    ldd       $02,x
                    bne       L060E
                    ldd       $02,s
                    beq       L0628
                    ldx       $16,s
                    ldd       $06,x
                    beq       L062D
L0628               ldd       $14,s
                    bne       L0632
L062D               ldd       $14,s
                    bra       L0635

L0632               lbsr      L121F
L0635               ldx       $12,s
                    std       $02,x
                    bra       L0656

L063C               ldd       $02,s
                    beq       L0644
                    ldd       $06,x
                    beq       L0649
L0644               ldd       $14,s
                    bne       L064E
L0649               ldd       $14,s
                    bra       L0651

L064E               lbsr      L121F
L0651               ldx       $16,s
                    std       $04,x
L0656               ldd       $0011
                    bne       L0677
                    ldd       $0221,y
                    bne       L0677
                    ldx       [$16,s]
                    ldd       $02,x
                    pshs      d
                    leax      $0231,y
                    tfr       x,d
                    lbsr      L33E2
                    leas      $02,s
                    ldd       #$0001
                    std       $0011
L0677               ldd       #$0004
                    lbsr      L357F
                    std       $10,s
                    std       [_start,y]
                    beq       L069B
                    ldd       $10,s
                    addd      #$0002
                    std       _start
                    ldd       $16,s
                    std       [$10,s]
                    clra
                    clrb
                    ldx       $10,s
                    std       $02,x
L069B               ldx       $16,s
                    ldd       $06,x
                    std       $16,s
                    lbne      L0603
                    bra       L06B0

L06A9               ldd       $0C,s
                    addd      #$0001
                    std       $0C,s
L06B0               ldb       [$0C,s]
                    cmpb      #$20
                    beq       L06A9
                    cmpb      #$09
                    lbeq      L06A9
                    ldd       $0C,s
                    std       $0a,s
L06C1               ldd       $02,s
                    lbeq      L05B8
L06C7               lbsr      L078C
                    tfr       d,u
                    tfr       u,d
                    std       $06,s
                    lbne      L04BB
                    ldd       $000B
                    lbsr      L305B
                    leas      $18,s
                    puls      pc,u
L06DE               pshs      u
                    ldd       #$FFBC
                    lbsr      L00FB
                    ldd       $0009
                    bne       L06F2
                    leax      L0CA7,pcr
                    tfr       x,d
                    bra       L0704

L06F2               ldb       [$0009,y]
                    cmpb      #$2d
                    bne       L0702
                    leax      $009a,y
                    stx       $000B
                    bra       L0708

L0702               ldd       $0009
L0704               bsr       L070A
                    std       $000B
L0708               puls      pc,u
L070A               pshs      u,d
                    ldd       #$FFB4
                    lbsr      L00FB
                    leas      -$02,s
                    leax      L0CB0,pcr
                    pshs      x
                    ldd       $04,s
                    lbsr      L279E
                    leas      $02,s
                    std       ,s
                    bne       L073B
                    ldd       $02,s
                    pshs      d
                    ldd       >$0029,y
                    pshs      d
                    ldd       $01FD,y
                    lbsr      L2227
                    leas      $04,s
                    lbsr      L3949
L073B               ldd       ,s
                    leas      $04,s
                    puls      pc,u
L0741               pshs      u
                    tfr       d,u
                    ldd       #$FFB8
                    lbsr      L00FB
                    leas      -$02,s
                    tfr       u,d
                    lbsr      $33CF
                    std       ,s
                    pshs      d
                    ldd       $08,s
                    lbsr      $33CF
                    addd      ,s++
                    cmpd      #$1000
                    ble       L076F
                    leax      L0CB2,pcr
                    pshs      x
                    ldd       #$0001
                    lbra      L09B8

L076F               ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    leax      d,u
                    pshs      x
                    ldx       $08,s
                    leax      $01,x
                    stx       $08,s
                    ldb       -$01,x
                    stb       [,s++]
                    bne       L076F
                    lbra      L09C0

L078C               pshs      u
                    ldd       #$FFB0
                    lbsr      L00FB
                    leas      -$08,s
                    clra
                    clrb
                    std       $04,s
                    std       ,s
                    leax      $06D3,y
                    stx       $06,s
                    leau      $02D3,y
                    ldd       $16D3,y
                    lbne      L096F
L07AE               clra
                    clrb
                    std       $02,s
                    ldb       ,u
                    cmpb      #$20
                    beq       L07BC
                    cmpb      #$09
                    bne       L07F1
L07BC               leau      $01,u
                    ldb       ,u
                    cmpb      #$20
                    beq       L07BC
                    cmpb      #$09
                    lbeq      L07BC
                    tfr       u,d
                    lbsr      L0975
                    std       -$02,s
                    bne       L080E
                    ldd       $04,s
                    beq       L07DB
                    ldd       ,s
                    beq       L07E6
L07DB               ldd       #$0020
                    ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    stb       -$01,x
L07E6               ldd       ,s
                    bne       L0813
                    ldd       #$0001
                    std       $04,s
                    bra       L0813

L07F1               tfr       u,d
                    lbsr      L0975
                    std       -$02,s
                    bne       L080E
                    ldb       ,u
                    cmpb      #$2d
                    bne       L0813
                    ldd       ,s
                    bne       L0813
                    pshs      u
                    ldd       #$0001
                    addd      ,s++
                    lbsr      L02B2
L080E               ldd       #$0001
                    std       $02,s
L0813               ldd       $02,s
                    lbne      L08F8
                    lbra      L08EF

L081C               ldb       ,u
                    sex
                    tfr       d,x
                    lbra      L08D8

L0824               ldb       $01,u
                    sex
                    tfr       d,x
                    bra       L083B

L082B               ldd       $04,s
                    beq       L084E
                    ldd       $06,s
                    addd      #$0001
                    std       $06,s
                    leau      $01,u
                    lbra      L08EF

L083B               cmpx      #$002A
                    beq       L082B
                    cmpx      #$0040
                    lbeq      L082B
                    cmpx      #$003F
                    lbeq      L082B
L084E               tfr       u,d
                    lbsr      $33CF
                    pshs      d
                    tfr       u,d
                    lbsr      L24B7
                    leas      $02,s
                    tfr       d,u
                    lbra      L08EF

L0861               ldx       $06,s
                    ldb       -$01,x
                    cmpb      #$5C
                    bne       L086E
                    ldd       #$0001
                    bra       L0870

L086E               clra
                    clrb
L0870               std       ,s
                    beq       L087E
                    tfr       x,d
                    addd      #$FFFF
                    std       $06,s
                    lbra      L08F8

L087E               ldd       $04,s
                    beq       L08C6
                    tfr       x,d
                    addd      #$0001
                    std       $06,s
                    bra       L08C6

L088B               ldb       $01,u
                    sex
                    leax      $016b,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$08
                    bne       L08CD
L089B               ldx       $06,s
                    leax      -$01,x
                    stx       $06,s
                    ldb       ,x
                    cmpb      #$20
                    beq       L089B
                    ldb       [$06,s]
                    cmpb      #$09
                    lbeq      L089B
                    ldd       $06,s
                    addd      #$0001
                    std       $06,s
                    ldd       $04,s
                    beq       L08C6
                    ldd       #$000D
                    ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    stb       -$01,x
L08C6               clra
                    clrb
                    stb       [$06,s]
                    bra       L08F8

L08CD               leau      $01,u
                    ldd       $06,s
                    addd      #$0001
                    std       $06,s
                    bra       L08EF

L08D8               cmpx      #$0024
                    lbeq      L0824
                    cmpx      #$000D
                    lbeq      L0861
                    cmpx      #$0023
                    lbeq      L088B
                    bra       L08CD

L08EF               ldb       ,u
                    stb       [$06,s]
                    lbne      L081C
L08F8               ldd       $000B
                    pshs      d
                    ldd       #$0400
                    pshs      d
                    leax      $02D3,y
                    tfr       x,d
                    lbsr      L2863
                    leas      $04,s
                    tfr       d,u
                    stu       -$02,s
                    bne       L091F
                    ldd       $16D3,y
                    addd      #$0001
                    std       $16D3,y
                    bra       L093E

L091F               ldd       $04,s
                    beq       L093E
                    ldb       ,u
                    cmpb      #$20
                    beq       L092D
                    cmpb      #$09
                    bne       L0934
L092D               ldd       #$0001
                    std       $02,s
                    bra       L093E

L0934               ldd       ,s
                    bne       L093E
                    clra
                    clrb
                    std       $04,s
                    bra       L0967

L093E               ldd       ,s
                    bne       L0946
                    ldd       $02,s
                    beq       L094E
L0946               ldd       $16D3,y
                    lbeq      L07AE
L094E               ldd       ,s
                    beq       L0963
                    leax      L0CD4,pcr
                    pshs      x
                    ldd       #$0001
                    lbsr      L2227
                    leas      $02,s
                    lbsr      L3949
L0963               ldd       $02,s
                    bne       L096F
L0967               leax      $06D3,y
                    tfr       x,d
                    bra       L0971

L096F               clra
                    clrb
L0971               leas      $08,s
                    puls      pc,u
L0975               pshs      u
                    tfr       d,u
                    ldd       #$FFC0
                    lbsr      L00FB
                    ldb       ,u
                    sex
                    tfr       d,x
                    bra       L098B

L0986               ldd       #$0001
                    puls      pc,u
L098B               cmpx      #$0023
                    beq       L0986
                    cmpx      #$002A
                    lbeq      L0986
                    cmpx      #$000D
                    lbeq      L0986
                    stx       -$02,s
                    lbeq      L0986
                    clra
                    clrb
                    puls      pc,u
L09A8               pshs      u,d
                    ldd       #$FFB8
                    lbsr      L00FB
                    leax      L0CF2,pcr
                    pshs      x
                    ldd       $02,s
L09B8               lbsr      L2227
                    leas      $02,s
                    lbsr      L3949
L09C0               leas      $02,s
                    puls      pc,u
                    fcc       /can't open "%s". /
                    fcb       $00
L09D6               fcb       $2E
                    fcb       $00
L09D8               fcb       $2E
                    fcb       $00
L09DA               fcc       /%s up to date/
                    fcb       $0D,$00
L09E9               fcb       $63,$63
                    fcb       $00
L09EC               fcb       $63,$63
                    fcb       $00
L09EF               fcb       $72,$6D,$61
                    fcb       $00
                    fcc       /Syntax: make {[<-opts>] [< target file >] [< macros >]}/
                    fcb       $0D,$00
                    fcc       /Function: keep track of modules for a file/
                    fcb       $0D,$00
                    fcc       /Options:/
                    fcb       $0D,$00
                    fcc       /    -b        don't use built-in rules/
                    fcb       $0D,$00
                    fcc       /    -d        debug mode, print out the file dates in makefile/
                    fcb       $0D,$00
                    fcc       /    -f=<xxx>  use <xxx> as the makefile  (default: makefile)/
                    fcb       $0D,$00
                    fcc       /    -i        ignore errors on commands and keep going/
                    fcb       $0D,$00
                    fcc       /    -n        don't execute commands, just print them out/
                    fcb       $0D,$00
                    fcc       /    -s        silent mode, execute commands without echoing them/
                    fcb       $0D,$00
                    fcc       /    -t        update the dates without executing the commands/
                    fcb       $0D,$00
                    fcc       /    -u        do the make whether it needs it or not/
                    fcb       $0D,$00
                    fcc       /    -z[=<path>] get list of files to make from stdin or path/
                    fcb       $0D,$00
L0C70               fcc       /no dependency list for command line/
                    fcb       $0D,$00
L0C95               fcc       /syntax error/
                    fcb       $0D
                    fcc       /"%s"/
                    fcb       $00
L0CA7               fcc       /makefile/
                    fcb       $00
L0CB0               fcb       $72
                    fcb       $00
L0CB2               fcc       /buffer overflow -- line too long/
                    fcb       $0D,$00
L0CD4               fcc       /unfinished continuation line/
                    fcb       $0D,$00
L0CF2               fcc       /make terminated/
                    fcb       $0D,$00
L0D03               pshs      u
                    tfr       d,u
                    ldd       #$FFAE
                    lbsr      L00FB
                    leas      -$0C,s
                    leax      $02,s
                    stx       ,s
                    lbra      L0D99

L0D16               clra
                    clrb
                    std       $08,s
                    std       $0a,s
                    bra       L0D29

L0D1E               leau      $01,u
                    ldd       $10,s
                    addd      #$FFFF
                    std       $10,s
L0D29               ldb       ,u
                    cmpb      #$20
                    beq       L0D1E
                    cmpb      #$09
                    lbeq      L0D1E
                    stu       $06,s
                    ldb       ,u
                    lbeq      L0DA0
                    bra       L0D70

L0D3F               ldb       ,u
                    sex
                    tfr       d,x
                    bra       L0D5E

L0D46               clra
                    clrb
                    stb       ,u+
L0D4A               ldd       $0a,s
                    addd      #$0001
                    std       $0a,s
                    bra       L0D70

L0D53               leau      $01,u
                    ldd       $08,s
                    addd      #$0001
                    std       $08,s
                    bra       L0D70

L0D5E               cmpx      #$0020
                    beq       L0D46
                    cmpx      #$0009
                    lbeq      L0D46
                    stx       -$02,s
                    beq       L0D4A
                    bra       L0D53

L0D70               ldd       $0a,s
                    beq       L0D3F
                    ldd       $10,s
                    pshs      d
                    ldd       $0a,s
                    addd      #$0001
                    nega
                    negb
                    sbca      #$00
                    addd      ,s++
                    std       $10,s
                    ldd       $06,s
                    lbsr      L1FC2
                    bsr       L0DA6
                    std       $04,s
                    std       [,s]
                    ldd       $04,s
                    addd      #$0002
                    std       ,s
L0D99               ldd       $10,s
                    lbgt      L0D16
L0DA0               ldd       $02,s
                    leas      $0C,s
                    puls      pc,u
L0DA6               pshs      u
                    tfr       d,u
                    ldd       #$FFBA
                    lbsr      L00FB
                    pshs      u
                    ldd       #$0008
                    lbsr      L21FB
                    bsr       L0DBD
                    lbra      L1248

L0DBD               pshs      u
                    tfr       d,u
                    ldd       #$FFC0
                    lbsr      L00FB
                    clra
                    clrb
                    std       $04,u
                    std       $02,u
                    ldd       $04,s
                    std       ,u
                    ldd       [$04,s]
                    std       $06,u
                    stu       [$04,s]
                    tfr       u,d
                    puls      pc,u
L0DDD               pshs      u
                    tfr       d,u
                    ldd       #$FFB8
                    lbsr      L00FB
                    leas      -$02,s
                    tfr       u,d
                    lbsr      $33CF
                    addd      #$0001
                    lbsr      L21FB
                    std       ,s
                    pshs      u
                    ldd       $02,s
                    lbsr      L33E2
                    leas      $02,s
                    ldd       ,s
                    lbra      L1248

L0E04               pshs      u
                    tfr       d,u
                    ldd       #$FFBA
                    lbsr      L00FB
                    clra
                    clrb
                    std       L0021
                    leax      >$001d,y
                    stx       L001F
                    leax      L124C,pcr
                    tfr       x,d
                    lbsr      L209B
                    clra
                    clrb
                    pshs      d
                    tfr       u,d
                    bsr       L0E4B
                    leas      $02,s
                    leax      L1275,pcr
                    tfr       x,d
                    lbsr      L209B
                    clra
                    clrb
                    pshs      d
                    tfr       u,d
                    lbsr      L0F22
                    leas      $02,s
                    ldd       L0021
                    beq       L0E49
                    ldd       #$0001
                    lbsr      L101B
L0E49               puls      pc,u
L0E4B               pshs      u
                    tfr       d,u
                    ldd       #$FFB0
                    lbsr      L00FB
                    leas      -$08,s
                    clra
                    clrb
                    std       $02,s
                    ldd       $0C,s
                    aslb
                    rola
                    aslb
                    rola
                    std       ,s
L0E63               ldx       ,u
                    ldd       $02,x
                    std       $06,s
                    pshs      d
                    ldd       #$0014
                    subd      $02,s
                    leax      >$0043,y
                    leax      d,x
                    pshs      x
                    leax      L1299,pcr
                    tfr       x,d
                    lbsr      L209B
                    leas      $04,s
                    ldd       $06,s
                    lbsr      L162D
                    std       -$02,s
                    lbeq      L0F02
                    ldd       $06,s
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    leax      L12A5,pcr
                    tfr       x,d
                    lbsr      L209B
                    leas      $04,s
                    ldd       $04,u
                    beq       L0EB8
                    ldd       $0C,s
                    pshs      d
                    leax      L20F7,pcr
                    pshs      x
                    ldd       $04,u
                    lbsr      L0FB4
                    leas      $04,s
                    std       $02,s
L0EB8               ldd       $02,s
                    bne       L0EFC
                    leax      L12C6,pcr
                    tfr       x,d
                    lbsr      L209B
                    ldd       $06,s
                    lbsr      $33CF
                    addd      #$0003
                    lbsr      L357F
                    std       $04,s
                    ble       L0F14
                    leax      L12DD,pcr
                    pshs      x
                    ldd       $08,s
                    pshs      d
                    ldd       $08,s
                    lbsr      L33E2
                    leas      $02,s
                    lbsr      L33FA
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    tfr       u,d
                    lbsr      L11A3
                    leas      $02,s
                    ldd       $04,s
                    lbsr      L3602
                    bra       L0F14

L0EFC               clra
                    clrb
                    std       $02,s
                    bra       L0F14

L0F02               ldd       $04,u
                    beq       L0F14
                    ldd       $0C,s
                    addd      #$0001
                    pshs      d
                    ldd       $04,u
                    lbsr      L0E4B
                    leas      $02,s
L0F14               ldd       $0C,s
                    beq       L0F1E
                    ldu       $02,u
                    lbne      L0E63
L0F1E               leas      $08,s
                    puls      pc,u
L0F22               pshs      u
                    tfr       d,u
                    ldd       #$FFB4
                    lbsr      L00FB
                    leas      -$04,s
                    clra
                    clrb
                    std       $02,s
                    ldd       $08,s
                    aslb
                    rola
                    aslb
                    rola
                    std       ,s
L0F3A               ldx       ,u
                    ldd       $02,x
                    pshs      d
                    ldd       #$0014
                    subd      $02,s
                    leax      >$0043,y
                    leax      d,x
                    pshs      x
                    leax      L12E0,pcr
                    tfr       x,d
                    lbsr      L209B
                    leas      $04,s
                    ldx       ,u
                    ldd       $02,x
                    lbsr      L20F7
                    std       -$02,s
                    beq       L0F93
                    ldd       $04,u
                    beq       L0F79
                    ldd       $08,s
                    pshs      d
                    leax      L20C1,pcr
                    pshs      x
                    ldd       $04,u
                    bsr       L0FB4
                    leas      $04,s
                    std       $02,s
L0F79               ldd       $02,s
                    bne       L0F8D
                    leax      L12EC,pcr
                    tfr       x,d
                    lbsr      L209B
                    tfr       u,d
                    lbsr      L0FF5
                    bra       L0FA5

L0F8D               clra
                    clrb
                    std       $02,s
                    bra       L0FA5

L0F93               ldd       $04,u
                    beq       L0FA5
                    ldd       $08,s
                    addd      #$0001
                    pshs      d
                    ldd       $04,u
                    lbsr      L0F22
                    leas      $02,s
L0FA5               ldd       $08,s
                    lbeq      L121B
                    ldu       $02,u
                    lbne      L0F3A
                    lbra      L121B

L0FB4               pshs      u,d
                    ldd       #$FFB6
                    lbsr      L00FB
L0FBC               ldu       ,s
L0FBE               ldx       ,u
                    ldd       $02,x
                    jsr       [$06,s]
                    std       -$02,s
                    beq       L0FE4
                    ldx       ,u
                    ldd       $02,x
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    leax      L130C,pcr
                    tfr       x,d
                    lbsr      L209B
                    leas      $04,s
                    ldd       #$0001
                    lbra      L1248

L0FE4               ldu       $02,u
                    bne       L0FBE
                    ldx       ,s
                    ldd       $04,x
                    std       ,s
                    bne       L0FBC
                    clra
                    clrb
                    lbra      L1248

L0FF5               pshs      u,d
                    ldd       #$FFBA
                    lbsr      L00FB
                    ldd       #$0004
L1000               lbsr      L21FB
                    tfr       d,u
                    stu       [L001F,y]
                    ldd       ,s
                    std       ,u
                    leax      $02,u
                    stx       L001F
                    ldd       L0021
                    addd      #$0001
                    std       L0021
                    lbra      L1248

L101B               pshs      u
                    ldd       #$FF94
                    lbsr      L00FB
                    leas      -$22,s
                    leax      L132C,pcr
                    pshs      x
                    ldd       $01FF,y
                    lbsr      L279E
                    leas      $02,s
                    std       ,s
                    bne       L1051
                    ldd       $01FF,y
                    pshs      d
                    ldd       >$0029,y
                    pshs      d
                    ldd       $01FD,y
                    lbsr      L2227
                    leas      $04,s
                    lbsr      L3949
L1051               clra
                    clrb
                    pshs      d
                    ldd       #$0040
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    ldd       $06,s
                    lbsr      $2DC1
                    leas      $06,s
                    cmpd      #$FFFF
                    bne       L1093
                    ldd       $01FF,y
                    pshs      d
                    leax      L132E,pcr
                    pshs      x
                    ldd       $01FD,y
                    lbsr      L2227
                    leas      $04,s
                    lbsr      L3949
                    bra       L1093

L1085               ldb       $02,s
                    beq       L1093
                    leax      $02,s
                    tfr       x,d
                    bsr       L10D7
                    std       -$02,s
                    beq       L10AE
L1093               ldd       ,s
                    pshs      d
                    ldd       #$0020
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    leax      $08,s
                    tfr       x,d
                    lbsr      L28A8
                    leas      $06,s
                    std       -$02,s
                    bne       L1085
L10AE               ldd       L0021
                    beq       L10CD
                    ldu       [L001D,y]
                    ldx       ,u
                    ldd       $02,x
                    pshs      d
                    leax      L1341,pcr
                    pshs      x
                    ldd       #$0001
                    lbsr      L2227
                    leas      $04,s
                    lbsr      L3949
L10CD               ldd       ,s
                    lbsr      L305B
                    leas      $22,s
                    puls      pc,u
L10D7               pshs      u
                    tfr       d,u
                    ldd       #$FF90
                    lbsr      L00FB
                    leas      -$28,s
                    clra
                    clrb
                    std       $20,s
                    ldd       L001D
                    std       $22,s
                    pshs      u
                    leax      $02,s
                    tfr       x,d
                    lbsr      L3518
                    leas      $02,s
L10F9               ldd       [$22,s]
                    std       $24,s
                    ldx       [$24,s]
                    ldd       $02,x
                    std       $26,s
                    lbsr      $33CF
                    std       $1e,s
                    bra       L1135

L110F               ldd       $1e,s
                    addd      #$FFFF
                    std       $1e,s
                    addd      $26,s
                    tfr       d,x
                    ldb       ,x
                    cmpb      #$2f
                    bne       L1135
                    ldd       $26,s
                    pshs      d
                    ldd       $20,s
                    addd      #$0001
                    addd      ,s++
                    std       $26,s
                    bra       L113A

L1135               ldd       $1e,s
                    bne       L110F
L113A               leax      ,s
                    pshs      x
                    ldd       $28,s
                    lbsr      L21A3
                    std       ,s++
                    beq       L118A
                    ldd       $20,s
                    beq       L1159
                    ldx       $22,s
                    ldd       $02,x
                    ldx       $20,s
                    std       $02,x
                    bra       L1160

L1159               ldx       $22,s
                    ldd       $02,x
                    std       L001D
L1160               ldx       [$24,s]
                    ldd       $02,x
                    pshs      d
                    leax      $02,s
                    pshs      x
                    leax      L1365,pcr
                    tfr       x,d
                    lbsr      L209B
                    leas      $04,s
                    leax      ,s
                    pshs      x
                    ldd       $26,s
                    bsr       L11C9
                    leas      $02,s
                    ldd       L0021
                    addd      #$FFFF
                    std       L0021
                    bra       L1190

L118A               ldd       $22,s
                    std       $20,s
L1190               ldx       $22,s
                    ldd       $02,x
                    std       $22,s
                    lbne      L10F9
                    ldd       L0021
                    leas      $28,s
                    puls      pc,u
L11A3               pshs      u
                    tfr       d,u
                    ldd       #$FFBA
                    lbsr      L00FB
                    leas      -$02,s
                    ldd       $06,s
                    lbsr      L1FF8
                    lbsr      L121F
                    bra       L11BD

L11B9               ldx       ,s
                    ldd       $02,x
L11BD               std       ,s
                    ldx       ,s
                    ldd       $02,x
                    bne       L11B9
                    ldd       $04,u
                    bra       L11E3

L11C9               pshs      u
                    tfr       d,u
                    ldd       #$FFBA
                    lbsr      L00FB
                    leas      -$02,s
                    ldd       $06,s
                    lbsr      L1FC2
                    lbsr      L0DA6
                    std       ,s
                    ldd       $04,u
                    ldx       ,s
L11E3               std       $02,x
                    tfr       x,d
                    std       $04,u
                    lbra      L1248

L11EC               pshs      u,d
                    ldd       #$FFB8
                    lbsr      L00FB
                    leas      -$02,s
                    ldd       #$0008
                    lbsr      L21FB
                    std       ,s
                    ldd       [$02,s]
                    std       [,s]
                    ldx       $02,s
                    ldd       $06,x
                    ldx       ,s
                    std       $06,x
                    tfr       x,d
                    ldx       $02,s
                    std       $06,x
                    clra
                    clrb
                    ldx       ,s
                    std       $04,x
                    std       $02,x
                    tfr       x,d
L121B               leas      $04,s
                    puls      pc,u
L121F               pshs      u,d
                    ldd       #$FFBA
                    lbsr      L00FB
                    ldd       ,s
                    bsr       L11EC
                    tfr       d,u
                    ldx       ,s
                    ldd       $04,x
                    beq       L1239
                    ldd       $04,x
                    bsr       L121F
                    std       $04,u
L1239               ldx       ,s
                    ldd       $02,x
                    beq       L1246
                    ldd       $02,x
                    lbsr      L121F
                    std       $02,u
L1246               tfr       u,d
L1248               leas      $02,s
                    puls      pc,u
L124C               fcc       /checking for implicit relocatable files/
                    fcb       $0D,$00
L1275               fcc       /checking for implicit source files/
                    fcb       $0D,$00
L1299               fcc       /%sfile: %s/
                    fcb       $0D,$00
L12A5               fcc       /found object file(level %d): %s/
                    fcb       $0D,$00
L12C6               fcc       /no explicit ".r" file/
                    fcb       $0D,$00
L12DD               fcb       $2E,$72
                    fcb       $00
L12E0               fcc       /%sfile: %s/
                    fcb       $0D,$00
L12EC               fcc       /no explicit source file listed/
                    fcb       $0D,$00
L130C               fcc       /found dependent (level %d): %s/
                    fcb       $0D,$00
L132C               fcb       $64
                    fcb       $00
L132E               fcc       /can't read "%s".  /
                    fcb       $00
L1341               fcc       /can't find source file to make "%s"/
                    fcb       $00
L1365               fcc       /found "%s" to make "%s"/
                    fcb       $0D,$00
L137E               pshs      u
                    tfr       d,u
                    ldd       #$FFAE
                    lbsr      L00FB
                    leas      -$0C,s
                    ldd       $04,u
                    std       $0a,s
                    ldd       [$0a,s]
                    addd      #$0006
                    std       $08,s
                    ldd       ,u
                    addd      #$0006
                    std       $06,s
                    clra
                    clrb
                    std       $02,s
                    leax      $02,s
                    stx       ,s
                    lbra      L1427

L13A8               ldd       $0017
                    beq       L13AF
                    lbsr      L09A8
L13AF               ldd       $0a,s
                    lbsr      L1468
                    ldb       [$06,s]
                    cmpb      #$FF
                    beq       L13D2
                    ldd       [$0a,s]
                    addd      #$0006
                    pshs      d
                    ldd       $08,s
                    lbsr      L1667
                    std       ,s++
                    bne       L13D2
                    ldd       $021d,y
                    beq       L13F1
L13D2               ldd       #$0004
                    lbsr      L21FB
                    std       $04,s
                    std       [,s]
                    ldd       $04,s
                    addd      #$0002
                    std       ,s
                    ldx       [$0a,s]
                    ldd       $02,x
                    std       [$04,s]
                    clra
                    clrb
                    ldx       $04,s
                    std       $02,x
L13F1               ldx       $0a,s
                    ldd       $04,x
                    beq       L1403
                    ldd       L0023
                    addd      #$0001
                    std       L0023
                    ldd       $0a,s
                    lbsr      L137E
L1403               ldd       [$0a,s]
                    addd      #$0006
                    cmpd      $08,s
                    beq       L1421
                    pshs      d
                    ldd       $0a,s
                    lbsr      L1667
                    std       ,s++
                    beq       L1421
                    ldd       [$0a,s]
                    addd      #$0006
                    std       $08,s
L1421               ldx       $0a,s
                    ldd       $02,x
                    std       $0a,s
L1427               ldd       $0a,s
                    lbne      L13A8
                    ldx       ,u
                    ldb       $06,x
                    cmpb      #$FF
                    beq       L1452
                    ldd       $08,s
                    pshs      d
                    tfr       x,d
                    addd      #$0006
                    lbsr      L1667
                    std       ,s++
                    bne       L144B
                    ldd       $021d,y
                    beq       L145D
L144B               ldd       #$00FF
                    ldx       ,u
                    stb       $06,x
L1452               ldd       $02,s
                    pshs      d
                    tfr       u,d
                    lbsr      L16C5
                    leas      $02,s
L145D               ldd       L0023
                    addd      #$FFFF
                    std       L0023
                    leas      $0C,s
                    puls      pc,u
L1468               pshs      u
                    tfr       d,u
                    ldd       #$FF4C
                    lbsr      L00FB
                    leas      -$6C,s
                    ldx       ,u
                    ldd       $02,x
                    std       $6a,s
                    clra
                    clrb
                    std       $04,s
                    std       $02,s
                    ldd       $6a,s
                    std       ,s
                    bra       L149E

L1489               ldx       ,s
                    leax      $01,x
                    stx       ,s
                    ldb       -$01,x
                    cmpb      #$2f
                    bne       L149E
                    ldd       $04,s
                    addd      #$0001
                    std       $04,s
                    bra       L14A2

L149E               ldb       [,s]
                    bne       L1489
L14A2               clra
                    clrb
                    stb       $06,s
                    ldd       $6a,s
                    lbsr      L20F7
                    std       -$02,s
                    beq       L14E6
                    ldd       $02,s
                    addd      #$0001
                    std       $02,s
                    ldd       $04,s
                    lbne      L1547
                    ldd       $0227,y
                    lbeq      L1547
                    ldd       $0201,y
                    pshs      d
                    leax      $08,s
                    tfr       x,d
                    lbsr      L33E2
                    leas      $02,s
                    leax      L1E64,pcr
L14D8               pshs      x
                    leax      $08,s
                    tfr       x,d
                    lbsr      L33FA
                    leas      $02,s
                    lbra      L1547

L14E6               ldd       $6a,s
                    lbsr      L162D
                    std       -$02,s
                    beq       L1516
                    ldd       $02,s
                    addd      #$0001
                    std       $02,s
                    ldd       $04,s
                    bne       L1547
                    ldd       $0225,y
                    beq       L1547
                    ldd       $0203,y
                    pshs      d
                    leax      $08,s
                    tfr       x,d
                    lbsr      L33E2
                    leas      $02,s
                    leax      L1E66,pcr
                    bra       L14D8

L1516               ldd       $6a,s
                    lbsr      L20C1
                    std       -$02,s
                    beq       L1540
                    ldd       $04,s
                    bne       L1547
                    ldd       $0223,y
                    beq       L1547
                    ldd       $01FF,y
                    pshs      d
                    leax      $08,s
                    tfr       x,d
                    lbsr      L33E2
                    leas      $02,s
                    leax      L1E68,pcr
                    lbra      L14D8

L1540               ldd       $02,s
                    addd      #$0001
                    std       $02,s
L1547               ldd       $6a,s
                    pshs      d
                    leax      $08,s
                    tfr       x,d
                    lbsr      L33FA
                    leas      $02,s
                    ldx       ,u
                    ldb       $06,x
                    bne       L1569
                    ldd       $02,s
                    pshs      d
                    leax      $08,s
                    pshs      x
                    tfr       u,d
                    bsr       L1584
                    leas      $04,s
L1569               ldd       $0213,y
                    beq       L157F
                    ldd       ,u
                    addd      #$0006
                    pshs      d
                    leax      $08,s
                    tfr       x,d
                    lbsr      L1D6A
                    leas      $02,s
L157F               leas      $6C,s
                    puls      pc,u
L1584               pshs      u,d
                    ldd       #$FFA2
                    lbsr      L00FB
                    ldu       $08,s
                    leas      -$14,s
                    ldd       [$14,s]
                    addd      #$0006
                    std       ,s
                    clra
                    clrb
                    pshs      d
                    ldd       $1C,s
                    lbsr      L36CC
                    leas      $02,s
                    std       $12,s
                    bge       L15E5
                    ldd       #$0080
                    pshs      d
                    ldd       $1C,s
                    lbsr      L36CC
                    leas      $02,s
                    std       $12,s
                    bge       L15E5
                    stu       -$02,s
                    bne       L15C7
                    ldx       $14,s
                    ldd       $04,x
                    beq       L15CE
L15C7               ldd       #$00FF
                    stb       [,s]
                    bra       L15E5

L15CE               ldd       $1a,s
                    pshs      d
                    ldd       >$0029,y
                    pshs      d
                    ldd       $01FD,y
                    lbsr      L2227
                    leas      $04,s
                    lbsr      L3949
L15E5               ldb       [,s]
                    bne       L1628
                    ldd       #$0010
                    pshs      d
                    leax      $04,s
                    pshs      x
                    ldd       $16,s
                    lbsr      L3928
                    leas      $04,s
                    cmpd      #$FFFF
                    bne       L1617
                    ldd       $1a,s
                    pshs      d
                    leax      L1E6A,pcr
                    pshs      x
                    ldd       $01FD,y
                    lbsr      L2227
                    leas      $04,s
                    lbsr      L3949
L1617               leax      $05,s
                    pshs      x
                    ldd       $02,s
                    lbsr      L212D
                    leas      $02,s
                    ldd       $12,s
                    lbsr      L36D9
L1628               leas      $16,s
                    puls      pc,u
L162D               pshs      u
                    tfr       d,u
                    ldd       #$FFB8
                    lbsr      L00FB
                    leas      -$02,s
                    pshs      u
                    tfr       u,d
                    lbsr      $33CF
                    addd      ,s++
                    std       ,s
                    bra       L1656

L1646               ldb       [,s]
                    cmpb      #$2f
                    lbeq      L16BE
                    ldb       [,s]
                    cmpb      #$2e
                    lbeq      L16A2
L1656               ldd       ,s
                    addd      #$FFFF
                    std       ,s
                    pshs      d
                    cmpu      ,s++
                    bls       L1646
                    lbra      L16BE

L1667               pshs      u
                    tfr       d,u
                    ldd       #$FFBC
                    lbsr      L00FB
                    leas      -$02,s
                    ldb       ,u
                    cmpb      #$FF
                    beq       L16A2
                    ldb       [$06,s]
                    cmpb      #$FF
                    beq       L16BE
                    clra
                    clrb
                    std       ,s
                    bra       L16B6

L1686               ldb       ,u
                    sex
                    pshs      d
                    ldb       [$08,s]
                    sex
                    cmpd      ,s++
                    beq       L16A6
                    ldb       ,u
                    sex
                    pshs      d
                    ldb       [$08,s]
                    sex
                    cmpd      ,s++
                    bgt       L16BE
L16A2               clra
                    clrb
                    bra       L16C1

L16A6               ldd       ,s
                    addd      #$0001
                    std       ,s
                    leau      $01,u
                    ldd       $06,s
                    addd      #$0001
                    std       $06,s
L16B6               ldd       ,s
                    cmpd      #$0005
                    blt       L1686
L16BE               ldd       #$0001
L16C1               leas      $02,s
                    puls      pc,u
L16C5               pshs      u,d
                    ldd       #$FFA8
                    lbsr      L00FB
                    leas      -$0C,s
                    ldu       #$0000
                    clra
                    clrb
                    std       $06,s
                    ldd       $0003
                    std       ,s
                    ldx       [$0C,s]
                    ldd       $04,x
                    beq       L16F2
                    ldd       $04,x
                    pshs      d
                    leax      L1E82,pcr
                    tfr       x,d
                    lbsr      L209B
                    leas      $02,s
                    bra       L16FB

L16F2               leax      L1E8F,pcr
                    tfr       x,d
                    lbsr      L209B
L16FB               ldd       #$0001
                    std       $022f,y
                    ldx       [$0C,s]
                    ldd       $04,x
                    std       $04,s
                    bne       L1712
                    ldd       $0C,s
                    lbsr      L19BB
                    std       $04,s
L1712               ldb       [$04,s]
                    cmpb      #$0d
                    lbeq      L192F
                    ldd       ,s
                    cmpd      $04,s
                    lbeq      L1851
                    ldd       $021b,y
                    lbne      L1851
                    lbra      L1840

L172F               ldx       $04,s
                    leax      $01,x
                    stx       $04,s
                    ldb       -$01,x
                    sex
                    tfr       d,x
                    lbra      L1832

L173D               ldx       [$0C,s]
                    ldd       $02,x
                    std       $02,s
                    lbsr      $33CF
                    std       $0a,s
                    ldx       $04,s
                    leax      $01,x
                    stx       $04,s
                    ldb       -$01,x
                    sex
                    tfr       d,x
                    lbra      L17F5

L1757               clra
                    clrb
                    std       $06,s
                    ldd       $0a,s
                    bra       L17A2

L175F               ldx       $02,s
                    ldd       $08,s
                    leax      d,x
                    ldb       ,x
                    sex
                    tfr       d,x
                    bra       L1794

L176C               ldd       $06,s
                    bne       L17A0
                    ldd       $08,s
                    std       $0a,s
                    ldd       $06,s
                    addd      #$0001
                    std       $06,s
                    bra       L17A0

L177D               ldd       $02,s
                    pshs      d
                    ldd       $0a,s
                    addd      #$0001
                    std       $0a,s
                    addd      ,s++
                    std       $02,s
                    ldd       $0a,s
                    subd      $08,s
                    std       $0a,s
                    bra       L17AB

L1794               cmpx      #$002E
                    beq       L176C
                    cmpx      #$002F
                    beq       L177D
                    bra       L17A0

L17A0               ldd       $08,s
L17A2               addd      #$FFFF
                    std       $08,s
                    ldd       $08,s
                    bgt       L175F
L17AB               ldd       $0a,s
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    pshs      u
                    ldd       $0003
                    addd      ,s++
                    lbsr      L3455
                    leas      $04,s
                    ldd       $0a,s
                    bra       L17D6

L17C2               ldd       $12,s
                    lbeq      L1840
                    pshs      d
                    pshs      u
                    ldd       $0003
                    addd      ,s++
                    lbsr      L197D
                    leas      $02,s
L17D6               leau      d,u
                    lbra      L1840

L17DB               ldd       $04,s
                    addd      #$FFFE
                    pshs      d
                    leax      L1EA4,pcr
                    pshs      x
                    ldd       #$0001
                    lbsr      L2227
                    leas      $04,s
                    lbsr      L3949
                    bra       L1840

L17F5               cmpx      #$002A
                    lbeq      L1757
                    cmpx      #$0040
                    beq       L17AB
                    cmpx      #$003F
                    beq       L17C2
                    bra       L17DB

L1808               pshs      u
                    ldd       #$0001
                    addd      ,s++
                    addd      $0003
                    tfr       d,x
                    clra
                    clrb
                    stb       ,x
                    ldd       $0C,s
                    pshs      d
                    ldd       $02,s
                    bsr       L1861
                    leas      $02,s
                    ldd       $021b,y
                    lbne      L192F
                    ldu       #$0000
                    bra       L1840

L182E               leau      $01,u
                    bra       L1840

L1832               cmpx      #$0024
                    lbeq      L173D
                    cmpx      #$000D
                    beq       L1808
                    bra       L182E

L1840               ldx       $0003
                    tfr       u,d
                    leax      d,x
                    ldb       [$04,s]
                    stb       ,x
                    lbne      L172F
                    bra       L185B

L1851               ldd       $0C,s
                    pshs      d
                    ldd       $06,s
                    bsr       L1861
                    leas      $02,s
L185B               ldd       #$0001
                    lbra      L192F

L1861               pshs      u
                    tfr       d,u
                    ldd       #$FFA4
                    lbsr      L00FB
                    leas      -$0e,s
                    clra
                    clrb
                    std       $0C,s
                    std       $0a,s
                    ldb       ,u
                    sex
                    tfr       d,x
                    bra       L188E

L187A               ldd       $0C,s
                    addd      #$0001
                    std       $0C,s
                    bra       L188A

L1883               ldd       $0a,s
                    addd      #$0001
                    std       $0a,s
L188A               leau      $01,u
                    bra       L1898

L188E               cmpx      #$0040
                    beq       L187A
                    cmpx      #$002D
                    beq       L1883
L1898               ldd       $0217,y
                    beq       L18AE
                    leax      $00A7,y
                    pshs      x
                    tfr       u,d
                    lbsr      L280A
                    leas      $02,s
                    lbra      L192F

L18AE               ldd       $021b,y
                    beq       L18BF
                    ldx       [$12,s]
                    ldd       $02,x
                    lbsr      L1C76
                    lbra      L192F

L18BF               leax      L1ECA,pcr
                    stx       ,s
                    stu       $02,s
                    clra
                    clrb
                    std       $04,s
                    ldd       $0219,y
                    bne       L18E2
                    ldd       $0C,s
                    bne       L18E2
                    leax      $00A7,y
                    pshs      x
                    tfr       u,d
                    lbsr      L280A
                    leas      $02,s
L18E2               clra
                    clrb
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    pshs      d
                    pshs      u
                    tfr       u,d
                    lbsr      $33CF
                    pshs      d
                    ldd       $0a,s
                    lbsr      L38E4
                    leas      $0a,s
                    std       $06,s
                    cmpd      #$FFFF
                    beq       L191D
                    ldd       $06,s
                    bsr       L1933
                    std       -$02,s
                    beq       L192F
                    ldd       $0215,y
                    bne       L192F
                    ldd       $0a,s
                    bne       L192F
                    leax      L1ED0,pcr
                    bra       L1921

L191D               leax      L1EE7,pcr
L1921               pshs      x
                    ldd       $01FD,y
                    lbsr      L2227
                    leas      $02,s
                    lbsr      L3949
L192F               leas      $0e,s
                    puls      pc,u
L1933               pshs      u,d
                    ldd       #$FFB4
                    lbsr      L00FB
                    leas      -$04,s
L193D               leax      ,s
                    tfr       x,d
                    lbsr      L38A6
                    std       $02,s
                    cmpd      #$FFFF
                    beq       L1977
                    ldd       $02,s
                    bne       L1963
                    ldd       $0017
                    pshs      d
                    ldd       $06,s
                    lbsr      L389C
                    leas      $02,s
                    cmpd      #$FFFF
                    beq       L1972
                    bra       L193D

L1963               cmpd      $04,s
                    lbne      L193D
                    ldd       ,s
                    beq       L1977
                    std       $01FD,y
L1972               ldd       #$FFFF
                    bra       L1979

L1977               clra
                    clrb
L1979               leas      $06,s
                    puls      pc,u
L197D               pshs      u
                    tfr       d,u
                    ldd       #$FFBA
                    lbsr      L00FB
                    ldd       [$04,s]
                    pshs      d
                    tfr       u,d
                    lbsr      L33E2
                    bra       L19AA

L1993               leax      >$0058,y
                    pshs      x
                    tfr       u,d
                    lbsr      L33FA
                    leas      $02,s
                    ldd       [$04,s]
                    pshs      d
                    tfr       u,d
                    lbsr      L0741
L19AA               leas      $02,s
                    ldx       $04,s
                    ldd       $02,x
                    std       $04,s
                    bne       L1993
                    tfr       u,d
                    lbsr      $33CF
                    puls      pc,u
L19BB               pshs      u
                    tfr       d,u
                    ldd       #$FF8A
                    lbsr      L00FB
                    leas      -$2e,s
                    clra
                    clrb
                    std       $28,s
                    std       $26,s
                    std       $24,s
                    ldx       ,u
                    ldd       $02,x
                    std       $2C,s
                    lbsr      L20F7
                    std       -$02,s
                    beq       L19F4
                    ldd       #$0073
L19E4               pshs      d
                    ldd       $04,u
                    lbsr      L1DCF
                    leas      $02,s
                    std       $2a,s
                    bne       L1A19
                    bra       L1A03

L19F4               ldd       $2C,s
                    lbsr      L162D
                    std       -$02,s
                    beq       L1A03
                    ldd       #$0072
                    bra       L19E4

L1A03               ldd       $2C,s
                    pshs      d
                    leax      >$005a,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2227
                    leas      $04,s
                    lbsr      L3949
L1A19               ldd       $2C,s
                    lbsr      L1E1F
                    std       $20,s
                    ldd       $2a,s
                    lbsr      L1E1F
                    std       $1e,s
                    ldd       $2a,s
                    lbsr      $33CF
                    addd      #$FFFF
                    std       $22,s
                    ldx       $2a,s
                    leax      d,x
                    ldb       ,x
                    sex
                    tfr       d,x
                    bra       L1A8D

L1A43               ldd       $28,s
                    addd      #$0001
                    std       $28,s
                    bra       L1AAA

L1A4E               ldd       $26,s
                    addd      #$0001
                    std       $26,s
                    bra       L1AAA

L1A59               ldd       $24,s
                    addd      #$0001
                    std       $24,s
                    bra       L1AAA

L1A64               leax      L1EFE,pcr
                    pshs      x
                    ldd       #$0001
                    lbsr      L2227
                    leas      $02,s
                    lbsr      L3949
L1A75               ldd       $2C,s
                    pshs      d
                    leax      >$005a,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2227
                    leas      $04,s
                    lbsr      L3949
                    bra       L1AAA

L1A8D               cmpx      #$0063
                    beq       L1A43
                    cmpx      #$0061
                    beq       L1A4E
                    cmpx      #$0072
                    beq       L1A59
                    cmpx      #$0066
                    beq       L1A64
                    cmpx      #$0070
                    lbeq      L1A64
                    bra       L1A75

L1AAA               ldd       $28,s
                    lbeq      L1B1C
                    leax      >$0058,y
                    pshs      x
                    ldd       $020b,y
                    pshs      d
                    ldd       $0003
                    lbsr      L33E2
                    leas      $02,s
                    lbsr      L33FA
                    leas      $02,s
                    ldd       $0207,y
                    beq       L1AD8
                    pshs      d
                    ldd       $0003
                    lbsr      L33FA
                    leas      $02,s
L1AD8               ldd       $0227,y
                    beq       L1B02
                    leax      L1F26,pcr
                    pshs      x
                    ldd       $0003
                    lbsr      L33FA
                    leas      $02,s
                    ldd       $0003
                    lbsr      L1E3E
                    ldd       $0003
                    lbsr      $33CF
                    tfr       d,x
                    ldd       $0003
                    leax      d,x
                    ldd       #$0020
                    stb       -$01,x
                    bra       L1B0F

L1B02               leax      L1F2B,pcr
                    pshs      x
                    ldd       $0003
                    lbsr      L33FA
                    leas      $02,s
L1B0F               ldd       $2a,s
                    pshs      d
                    ldd       $0003
                    lbsr      L0741
                    lbra      L1C60

L1B1C               ldd       $26,s
                    lbeq      L1BC8
                    ldd       $022b,y
                    bne       L1B3C
                    ldd       $021f,y
                    beq       L1B3C
                    leax      L1F30,pcr
                    pshs      x
                    ldd       $0003
                    lbsr      L33E2
                    bra       L1B52

L1B3C               leax      >$0058,y
                    pshs      x
                    ldd       $020d,y
                    pshs      d
                    ldd       $0003
                    lbsr      L33E2
                    leas      $02,s
                    lbsr      L33FA
L1B52               leas      $02,s
                    ldd       $0209,y
                    beq       L1B6C
                    leax      >$0058,y
                    pshs      x,d
                    ldd       $0003
                    lbsr      L33FA
                    leas      $02,s
                    lbsr      L33FA
                    leas      $02,s
L1B6C               leax      L1F34,pcr
                    pshs      x
                    ldd       $01FF,y
                    lbsr      L3427
                    std       ,s++
                    beq       L1B9A
                    ldd       $1e,s
                    bne       L1B9A
                    leax      L1F36,pcr
                    pshs      x
                    ldd       $01FF,y
                    pshs      d
                    ldd       $0003
                    lbsr      L33FA
                    leas      $02,s
                    lbsr      L33FA
                    leas      $02,s
L1B9A               leax      L1F38,pcr
                    pshs      x
                    ldd       $2C,s
                    pshs      d
                    ldd       $0003
                    lbsr      L33FA
                    leas      $02,s
                    lbsr      L33FA
                    leas      $02,s
                    ldd       $0227,y
                    lbeq      L1C56
                    ldd       $20,s
                    lbne      L1C56
                    ldd       $0003
                    lbsr      L1E3E
                    lbra      L1C56

L1BC8               ldd       $24,s
                    lbeq      L1C62
                    leax      >$0058,y
                    pshs      x
                    ldd       $020f,y
                    pshs      d
                    ldd       $0003
                    lbsr      L33E2
                    leas      $02,s
                    lbsr      L33FA
                    leas      $02,s
                    ldd       $0205,y
                    beq       L1BFF
                    leax      >$0058,y
                    pshs      x,d
                    ldd       $0003
                    lbsr      L33FA
                    leas      $02,s
                    lbsr      L33FA
                    leas      $02,s
L1BFF               ldd       $1e,s
                    bne       L1C22
                    ldd       $0227,y
                    beq       L1C22
                    leax      L1F3D,pcr
                    pshs      x
                    ldd       $0201,y
                    pshs      d
                    ldd       $0003
                    lbsr      L33FA
                    leas      $02,s
                    lbsr      L33FA
                    leas      $02,s
L1C22               leax      L1F3F,pcr
                    pshs      x
                    ldd       $2C,s
                    pshs      d
                    ldd       $0003
                    lbsr      L33FA
                    leas      $02,s
                    lbsr      L33FA
                    leas      $02,s
                    ldd       $20,s
                    bne       L1C56
                    ldd       $0203,y
                    beq       L1C56
                    leax      L1F44,pcr
                    pshs      x,d
                    ldd       $0003
                    lbsr      L33FA
                    leas      $02,s
                    lbsr      L33FA
                    leas      $02,s
L1C56               ldd       $2C,s
                    pshs      d
                    ldd       $0003
                    lbsr      L33FA
L1C60               leas      $02,s
L1C62               leax      L1F46,pcr
                    pshs      x
                    ldd       $0003
                    lbsr      L33FA
                    leas      $02,s
                    ldd       $0003
                    leas      $2e,s
                    puls      pc,u
L1C76               pshs      u
                    tfr       d,u
                    ldd       #$FF4C
                    lbsr      L00FB
                    leas      -$6a,s
                    clra
                    clrb
                    std       $66,s
                    stu       ,s
                    bra       L1CA3

L1C8C               ldx       ,s
                    leax      $01,x
                    stx       ,s
                    ldb       -$01,x
                    cmpb      #$2f
                    bne       L1CA3
                    ldd       $66,s
                    addd      #$0001
                    std       $66,s
                    bra       L1CA7

L1CA3               ldb       [,s]
                    bne       L1C8C
L1CA7               ldd       $66,s
                    lbne      L1D10
                    ldd       $0227,y
                    beq       L1CCB
                    tfr       u,d
                    lbsr      L20F7
                    std       -$02,s
                    beq       L1CCB
                    pshs      u
                    ldd       $0201,y
                    pshs      d
                    leax      L1F48,pcr
                    bra       L1D03

L1CCB               ldd       $0225,y
                    beq       L1CE8
                    tfr       u,d
                    lbsr      L162D
                    std       -$02,s
                    beq       L1CE8
                    pshs      u
                    ldd       $0203,y
                    pshs      d
                    leax      L1F4E,pcr
                    bra       L1D03

L1CE8               ldd       $0223,y
                    beq       L1D1B
                    tfr       u,d
                    lbsr      L20C1
                    std       -$02,s
                    beq       L1D1B
                    pshs      u
                    ldd       $01FF,y
                    pshs      d
                    leax      L1F54,pcr
L1D03               pshs      x
                    leax      $08,s
                    tfr       x,d
                    lbsr      L291D
                    leas      $06,s
                    bra       L1D1B

L1D10               pshs      u
                    leax      $04,s
                    tfr       x,d
                    lbsr      L33E2
                    leas      $02,s
L1D1B               ldd       #$0002
                    pshs      d
                    leax      $04,s
                    tfr       x,d
                    lbsr      L36CC
                    leas      $02,s
                    std       $68,s
                    bge       L1D44
                    leax      $02,s
                    pshs      x
                    ldd       >$0029,y
                    pshs      d
                    ldd       $01FD,y
                    lbsr      L2227
                    leas      $04,s
                    lbsr      L3949
L1D44               ldd       $0219,y
                    bne       L1D5F
                    leax      $02,s
                    pshs      x
                    leax      L1F5A,pcr
                    pshs      x
                    leax      $00B4,y
                    tfr       x,d
                    lbsr      L2901
                    leas      $04,s
L1D5F               ldd       $68,s
                    lbsr      L36D9
                    leas      $6a,s
                    puls      pc,u
L1D6A               pshs      u
                    tfr       d,u
                    ldd       #$FFA2
                    lbsr      L00FB
                    leas      -$0C,s
                    ldb       [$10,s]
                    sex
                    std       $08,s
                    ldx       $10,s
                    ldb       $01,x
                    sex
                    std       $06,s
                    ldb       $02,x
                    sex
                    std       $04,s
                    ldb       $03,x
                    sex
                    std       $02,s
                    ldb       $04,x
                    sex
                    std       ,s
                    ldd       L0023
                    aslb
                    rola
                    aslb
                    rola
                    std       $0a,s
                    ldd       ,s
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       $0C,s
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    pshs      u
                    ldd       #$0014
                    subd      $16,s
                    leax      >$0078,y
                    leax      d,x
                    pshs      x
                    leax      L1F69,pcr
                    tfr       x,d
                    lbsr      L28EF
                    leas      $0e,s
                    leas      $0C,s
                    puls      pc,u
L1DCF               pshs      u
                    tfr       d,u
                    ldd       #$FFB2
                    lbsr      L00FB
                    leas      -$0a,s
L1DDB               stu       $02,s
L1DDD               ldd       $02,s
                    std       ,s
L1DE1               ldx       [,s]
                    ldd       $02,x
                    std       $04,s
                    ldb       $0f,s
                    cmpb      #$72
                    bne       L1DF8
                    ldd       $04,s
                    lbsr      L20F7
                    std       -$02,s
                    bne       L1E01
                    bra       L1E05

L1DF8               ldd       $04,s
                    lbsr      L20C1
                    std       -$02,s
                    beq       L1E05
L1E01               ldd       $04,s
                    bra       L1E1B

L1E05               ldx       ,s
                    ldd       $02,x
                    std       ,s
                    bne       L1DE1
                    ldx       $02,s
                    ldd       $04,x
                    std       $02,s
                    bne       L1DDD
                    ldu       $02,u
                    bne       L1DDB
                    clra
                    clrb
L1E1B               leas      $0a,s
                    puls      pc,u
L1E1F               pshs      u
                    tfr       d,u
                    ldd       #$FFC0
                    lbsr      L00FB
                    bra       L1E36

L1E2B               ldb       ,u+
                    cmpb      #$2f
                    bne       L1E36
                    ldd       #$0001
                    puls      pc,u
L1E36               ldb       ,u
                    bne       L1E2B
                    clra
                    clrb
                    puls      pc,u
L1E3E               pshs      u
                    tfr       d,u
                    ldd       #$FFBA
                    lbsr      L00FB
                    ldd       $0201,y
                    pshs      d
                    tfr       u,d
                    lbsr      L0741
                    leas      $02,s
                    leax      L1F91,pcr
                    pshs      x
                    tfr       u,d
                    lbsr      L33FA
                    leas      $02,s
                    puls      pc,u
L1E64               fcb       $2F
                    fcb       $00
L1E66               fcb       $2F
                    fcb       $00
L1E68               fcb       $2F
                    fcb       $00
L1E6A               fcc       /getstat error - "%s".  /
                    fcb       $00
L1E82               fcc       /command: %s/
                    fcb       $0D,$00
L1E8F               fcc       /no explicit command/
                    fcb       $0D,$00
L1EA4               fcc       /"%s" - unknown macro on command line/
                    fcb       $0D,$00
L1ECA               fcc       /shell/
                    fcb       $00
L1ED0               fcc       /aborted due to errors/
                    fcb       $0D,$00
L1EE7               fcc       /aborted due to errors/
                    fcb       $0D,$00
L1EFE               fcc       /don't know about 'f' or 'p' compilers./
                    fcb       $0D,$00
L1F26               fcc       / -r=/
                    fcb       $00
L1F2B               fcc       / -r /
                    fcb       $00
L1F30               fcb       $72,$36,$38
                    fcb       $00
L1F34               fcb       $2E
                    fcb       $00
L1F36               fcb       $2F
                    fcb       $00
L1F38               fcc       / -o=/
                    fcb       $00
L1F3D               fcb       $2F
                    fcb       $00
L1F3F               fcc       / -f=/
                    fcb       $00
L1F44               fcb       $2F
                    fcb       $00
L1F46               fcb       $0D,$00
L1F48               fcc       |%s/%s|
                    fcb       $00
L1F4E               fcc       |%s/%s|
                    fcb       $00
L1F54               fcc       |%s/%s|
                    fcb       $00
L1F5A               fcc       /updated: "%s"/
                    fcb       $0D,$00
L1F69               fcc       |%s%-32s date: %02d/%02d/%02d %02d:%02d|
                    fcb       $0D,$00
L1F91               fcb       $2F
                    fcb       $00
L1F93               pshs      u
                    tfr       d,u
                    ldd       #$FFB8
                    lbsr      L00FB
                    leas      -$02,s
                    tfr       u,d
                    lbsr      $33CF
                    addd      #$000E
                    lbsr      L21FB
                    std       ,s
                    pshs      u
                    ldd       $02,s
                    lbsr      L2015
                    leas      $02,s
                    ldd       ,s
                    std       [$0005,y]
                    addd      #$000B
                    std       $0005
L1FC0               bra       L1FF4

L1FC2               pshs      u
                    tfr       d,u
                    ldd       #$FFB8
                    lbsr      L00FB
                    leas      -$02,s
                    ldd       $0025
                    std       ,s
                    beq       L1FE9
L1FD4               pshs      u
                    ldx       $02,s
                    ldd       $02,x
                    lbsr      L3427
                    std       ,s++
                    beq       L1FE9
                    ldx       ,s
                    ldd       $0b,x
                    std       ,s
                    bne       L1FD4
L1FE9               ldd       ,s
                    bne       L1FF4
                    tfr       u,d
                    lbsr      L1F93
                    std       ,s
L1FF4               ldd       ,s
                    bra       L2034

L1FF8               pshs      u
                    tfr       d,u
                    ldd       #$FFBA
                    lbsr      L00FB
                    leas      -$02,s
                    tfr       u,d
                    bsr       L1FC2
                    std       ,s
                    ldd       [,s]
                    bne       L2034
                    ldd       ,s
                    lbsr      L0DA6
                    bra       L2034

L2015               pshs      u
                    tfr       d,u
                    ldd       #$FFBA
                    lbsr      L00FB
                    clra
                    clrb
                    std       $04,u
                    std       $0b,u
                    std       ,u
                    leax      $0d,u
                    stx       $02,u
                    ldd       $04,s
                    pshs      d
                    ldd       $02,u
                    lbsr      L33E2
L2034               leas      $02,s
                    puls      pc,u
L2038               pshs      u,d
                    ldd       #$FFB4
                    lbsr      L00FB
                    leas      -$02,s
                    ldd       $0025
                    std       ,s
                    ldd       $02,s
                    beq       L2065
L204A               ldd       $02,s
                    pshs      d
                    ldx       $02,s
                    ldd       $02,x
                    lbsr      L3427
                    std       ,s++
                    bne       L205D
                    ldd       [,s]
                    bra       L207A

L205D               ldx       ,s
                    ldd       $0b,x
                    std       ,s
                    bne       L204A
L2065               ldd       $02,s
                    pshs      d
                    leax      >L207E,pcr
                    pshs      x
                    ldd       #$0001
                    lbsr      L2227
                    leas      $04,s
                    lbsr      L3949
L207A               leas      $04,s
                    puls      pc,u
L207E               fcc       /can't find target file: %s./
                    fcb       $0D,$00
L209B               pshs      u,d
                    ldd       #$FFB4
                    lbsr      L00FB
                    ldd       $0213,y
                    lbeq      L225E
                    ldd       $0a,s
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    ldd       $06,s
                    lbsr      L28EF
                    leas      $06,s
                    lbra      L225E

L20C1               pshs      u
                    tfr       d,u
                    ldd       #$FFBA
                    lbsr      L00FB
                    leas      -$02,s
                    tfr       u,d
                    lbsr      $33CF
                    std       ,s
                    leax      d,u
                    ldb       -$02,x
                    cmpb      #$2e
                    bne       L2128
                    ldb       -$01,x
                    sex
                    tfr       d,x
                    cmpx      #$0063
                    beq       L2122
                    cmpx      #$0061
                    beq       L2122
                    cmpx      #$0066
                    beq       L2122
                    cmpx      #$0070
                    beq       L2122
                    bra       L2128

L20F7               pshs      u
                    tfr       d,u
                    ldd       #$FFBA
                    lbsr      L00FB
                    leas      -$02,s
                    tfr       u,d
                    lbsr      $33CF
                    std       ,s
                    addd      #$FFFE
                    leax      d,u
                    ldb       ,x
                    cmpb      #$2e
                    bne       L2128
                    ldd       ,s
                    addd      #$FFFF
                    leax      d,u
                    ldb       ,x
                    cmpb      #$72
                    bne       L2128
L2122               ldd       #$0001
                    lbra      L225E

L2128               clra
                    clrb
                    lbra      L225E

L212D               pshs      u
                    tfr       d,u
                    ldd       #$FFBE
                    lbsr      L00FB
                    leas      -$02,s
                    clra
                    clrb
                    std       ,s
                    bra       L2149

L213F               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    stb       ,u+
L2149               ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    cmpd      #$0005
                    blt       L213F
                    lbra      L225E
                    pshs      u
                    tfr       d,u
                    ldd       #$FFBE
                    lbsr      L00FB
                    bra       L217F

L2168               ldb       ,u
                    sex
                    pshs      d
                    ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    sex
                    cmpd      ,s++
                    bne       L2183
                    leau      $01,u
                    bra       L217F

L217F               ldb       ,u
                    bne       L2168
L2183               ldb       ,u
                    lbne      L21F7
                    ldb       [$04,s]
                    cmpb      #$2e
                    lbne      L21F7
                    ldx       $04,s
                    ldb       $01,x
                    cmpb      #$72
                    lbne      L21F7
                    ldb       $02,x
                    beq       L21C3
                    lbra      L21F7

L21A3               pshs      u
                    tfr       d,u
                    ldd       #$FFBE
                    lbsr      L00FB
                    bra       L21E4

L21AF               ldb       ,u+
                    cmpb      #$2e
                    bne       L21E4
                    ldb       [$04,s]
                    sex
                    tfr       d,x
                    bra       L21C8

L21BD               ldx       $04,s
                    ldb       $01,x
                    bne       L21F7
L21C3               ldd       #$0001
                    puls      pc,u
L21C8               cmpx      #$0063
                    beq       L21BD
                    cmpx      #$0061
                    lbeq      L21BD
                    cmpx      #$0070
                    lbeq      L21BD
                    cmpx      #$0066
                    lbeq      L21BD
                    bra       L21F7

L21E4               ldb       ,u
                    sex
                    pshs      d
                    ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    sex
                    cmpd      ,s++
                    beq       L21AF
L21F7               clra
                    clrb
                    puls      pc,u
L21FB               pshs      u
                    tfr       d,u
                    ldd       #$FFB8
                    lbsr      L00FB
                    leas      -$02,s
                    tfr       u,d
                    lbsr      L380B
                    std       ,s
                    cmpd      #$FFFF
                    bne       L225C
                    leax      >L2262,pcr
                    pshs      x
                    ldd       $01FD,y
                    bsr       L2227
                    leas      $02,s
                    lbsr      L3949
                    bra       L225C

L2227               pshs      u,d
                    ldd       #$FFB8
                    lbsr      L00FB
                    leax      $00A7,y
                    pshs      x
                    leax      >L2285,pcr
                    tfr       x,d
                    lbsr      L280A
                    leas      $02,s
                    ldd       $08,s
                    pshs      d
                    ldd       $08,s
                    lbsr      L28EF
                    leas      $02,s
                    leax      $00A7,y
                    pshs      x
                    leax      >L228C,pcr
                    tfr       x,d
                    lbsr      L280A
                    leas      $02,s
L225C               ldd       ,s
L225E               leas      $02,s
                    puls      pc,u
L2262               fcc       / - system memory request denied.  /
                    fcb       $00
L2285               fcc       /make: /
                    fcb       $00
L228C               fcb       $0D,$00
L228E               pshs      u
                    tfr       d,u
                    ldd       #$FFB2
                    lbsr      L00FB
                    leas      -$08,s
                    stu       $04,s
                    ldd       $0213,y
                    beq       L22D3
                    tfr       u,d
                    lbsr      L27EA
                    bra       L22D3

L22A9               ldx       $04,s
                    leax      $01,x
                    stx       $04,s
                    ldb       -$01,x
                    sex
                    tfr       d,x
                    bra       L22BE

L22B6               clra
                    clrb
                    ldx       $04,s
                    stb       -$01,x
                    bra       L22E1

L22BE               cmpx      #$0020
                    beq       L22B6
                    cmpx      #$0009
                    lbeq      L22B6
                    cmpx      #$003D
                    lbeq      L22B6
                    bra       L22D3

L22D3               ldb       [$04,s]
                    bne       L22A9
                    bra       L22E1

L22DA               ldd       $0C,s
                    addd      #$0001
                    std       $0C,s
L22E1               ldb       [$0C,s]
                    cmpb      #$20
                    beq       L22DA
                    cmpb      #$09
                    lbeq      L22DA
                    ldd       $0C,s
                    lbsr      $33CF
                    std       $02,s
                    ldx       $0C,s
                    ldd       $02,s
                    leax      d,x
                    ldb       -$01,x
                    cmpb      #$0d
                    bne       L2310
                    ldd       $02,s
                    addd      #$FFFF
                    std       $02,s
                    addd      $0C,s
                    tfr       d,x
                    clra
                    clrb
                    stb       ,x
L2310               tfr       u,d
                    lbsr      $33CF
                    std       ,s
                    addd      #$0004
                    addd      $02,s
                    addd      #$0002
                    lbsr      L21FB
                    std       $06,s
                    pshs      u
                    ldd       $08,s
                    addd      #$0004
                    lbsr      L33E2
                    leas      $02,s
                    ldd       $0C,s
                    pshs      d
                    ldd       $08,s
                    addd      #$0004
                    addd      $02,s
                    addd      #$0001
                    std       [$08,s]
                    lbsr      L33E2
                    leas      $02,s
                    leax      L260C,pcr
                    pshs      x
                    tfr       u,d
                    lbsr      L3427
                    std       ,s++
                    bne       L2372
                    ldd       $01FF,y
                    lbne      L24B3
                    ldd       [$06,s]
                    std       $01FF,y
                    ldd       $0223,y
                    addd      #$0001
                    std       $0223,y
                    lbra      L24A8

L2372               leax      L2611,pcr
                    pshs      x
                    tfr       u,d
                    lbsr      L3427
                    std       ,s++
                    bne       L239E
                    ldd       $0201,y
                    lbne      L24B3
                    ldd       [$06,s]
                    std       $0201,y
                    ldd       $0227,y
                    addd      #$0001
                    std       $0227,y
                    lbra      L24A8

L239E               leax      L2616,pcr
                    pshs      x
                    tfr       u,d
                    lbsr      L3427
                    std       ,s++
                    bne       L23CA
                    ldd       $0203,y
                    lbne      L24B3
                    ldd       [$06,s]
                    std       $0203,y
                    ldd       $0225,y
                    addd      #$0001
                    std       $0225,y
                    lbra      L24A8

L23CA               leax      L261B,pcr
                    pshs      x
                    tfr       u,d
                    lbsr      L3427
                    std       ,s++
                    bne       L23EB
                    ldd       $0207,y
                    lbne      L24B3
                    ldd       [$06,s]
                    std       $0207,y
                    lbra      L24A8

L23EB               leax      L2622,pcr
                    pshs      x
                    tfr       u,d
                    lbsr      L3427
                    std       ,s++
                    bne       L240C
                    ldd       $0209,y
                    lbne      L24B3
                    ldd       [$06,s]
                    std       $0209,y
                    lbra      L24A8

L240C               leax      L2629,pcr
                    pshs      x
                    tfr       u,d
                    lbsr      L3427
                    std       ,s++
                    bne       L242D
                    ldd       $0205,y
                    lbne      L24B3
                    ldd       [$06,s]
                    std       $0205,y
                    lbra      L24A8

L242D               leax      L2630,pcr
                    pshs      x
                    tfr       u,d
                    lbsr      L3427
                    std       ,s++
                    bne       L2458
                    ldd       $0229,y
                    lbne      L24B3
                    ldd       [$06,s]
                    std       $020b,y
                    ldd       $0229,y
                    addd      #$0001
                    std       $0229,y
                    bra       L24A8

L2458               leax      L2633,pcr
                    pshs      x
                    tfr       u,d
                    lbsr      L3427
                    std       ,s++
                    bne       L2481
                    ldd       $022b,y
                    bne       L24B3
                    ldd       [$06,s]
                    std       $020d,y
                    ldd       $022b,y
                    addd      #$0001
                    std       $022b,y
                    bra       L24A8

L2481               leax      L2636,pcr
                    pshs      x
                    tfr       u,d
                    lbsr      L3427
                    std       ,s++
                    bne       L24A8
                    ldd       $022d,y
                    bne       L24B3
                    ldd       [$06,s]
                    std       $020f,y
                    ldd       $022d,y
                    addd      #$0001
                    std       $022d,y
L24A8               ldd       $06,s
                    std       [$0007,y]
                    addd      #$0002
                    std       $0007
L24B3               leas      $08,s
L24B5               puls      pc,u
L24B7               pshs      u,d
                    ldd       #$FFA6
                    lbsr      L00FB
                    leas      -$10,s
                    ldu       #$0000
                    ldd       $10,s
                    addd      #$0001
                    std       $10,s
                    subd      #$0001
                    std       $06,s
                    std       $02,s
                    ldd       #$0001
                    std       $0a,s
                    ldx       $10,s
                    leax      $01,x
                    stx       $10,s
                    ldb       -$01,x
                    cmpb      #$28
                    bne       L2502
                    ldd       $0a,s
                    addd      #$0001
                    std       $0a,s
                    bra       L24F2

L24F0               leau      $01,u
L24F2               ldx       $10,s
                    leax      $01,x
                    stx       $10,s
                    ldb       -$01,x
                    cmpb      #$29
                    bne       L24F0
                    bra       L2504

L2502               leau      $01,u
L2504               pshs      u
                    ldd       $08,s
                    addd      $0C,s
                    lbsr      L25C3
                    leas      $02,s
                    std       ,s
                    lbeq      L25A7
                    pshs      u
                    ldd       $0C,s
                    addd      ,s++
                    addd      #$0001
                    pshs      d
                    ldd       [$02,s]
                    lbsr      $33CF
                    std       $0e,s
                    cmpd      ,s++
                    bge       L254B
                    ldd       $06,s
                    addd      $0C,s
                    std       $08,s
                    std       $04,s
L2535               ldx       $10,s
                    leax      $01,x
                    stx       $10,s
                    ldb       -$01,x
                    ldx       $08,s
                    leax      $01,x
                    stx       $08,s
                    stb       -$01,x
                    bne       L2535
                    bra       L258A

L254B               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    beq       L2559
                    ldd       #$0003
                    bra       L255C

L2559               ldd       #$0001
L255C               pshs      d
                    pshs      u
                    ldd       $0a,s
                    addd      $1a,s
                    std       $0C,s
                    addd      $10,s
                    subd      ,s++
                    subd      ,s++
                    std       $04,s
                    bra       L2582

L2572               ldx       $08,s
                    leax      -$01,x
                    stx       $08,s
                    ldb       $01,x
                    ldx       $04,s
                    leax      -$01,x
                    stx       $04,s
                    stb       $01,x
L2582               ldd       $08,s
                    cmpd      $10,s
                    bcc       L2572
L258A               ldd       [,s]
                    std       $08,s
                    bra       L25A0

L2590               ldx       $08,s
                    leax      $01,x
                    stx       $08,s
                    ldb       -$01,x
                    ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    stb       -$01,x
L25A0               ldb       [$08,s]
                    bne       L2590
                    bra       L25BC

L25A7               ldd       $06,s
                    pshs      d
                    leax      L2639,pcr
                    pshs      x
                    ldd       #$0001
                    lbsr      L2227
                    leas      $04,s
                    lbsr      L3949
L25BC               ldd       $02,s
                    leas      $12,s
                    puls      pc,u
L25C3               pshs      u
                    tfr       d,u
                    ldd       #$FFB6
                    lbsr      L00FB
                    leas      -$02,s
                    ldd       $0027
                    std       ,s
                    beq       L2606
                    bra       L2602

L25D7               ldd       $06,s
                    pshs      d
                    pshs      u
                    ldd       $04,s
                    addd      #$0004
                    lbsr      L3492
                    leas      $04,s
                    std       -$02,s
                    bne       L25FC
                    ldd       ,s
                    addd      #$0004
                    lbsr      $33CF
                    cmpd      $06,s
                    bne       L25FC
                    ldd       ,s
                    bra       L2608

L25FC               ldx       ,s
                    ldd       $02,x
                    std       ,s
L2602               ldd       ,s
                    bne       L25D7
L2606               clra
                    clrb
L2608               leas      $02,s
                    puls      pc,u
L260C               fcc       /SDIR/
                    fcb       $00
L2611               fcc       /RDIR/
                    fcb       $00
L2616               fcc       /ODIR/
                    fcb       $00
L261B               fcc       /CFLAGS/
                    fcb       $00
L2622               fcc       /RFLAGS/
                    fcb       $00
L2629               fcc       /LFLAGS/
                    fcb       $00
L2630               fcb       $43,$43
                    fcb       $00
L2633               fcb       $52,$43
                    fcb       $00
L2636               fcb       $4C,$43
                    fcb       $00
L2639               fcc       /"%s" - unknown macro/
                    fcb       $00
L264E               pshs      u
                    leau      $009a,y
L2654               ldd       $06,u
                    clra
                    andb      #$03
                    bne       L265F
                    tfr       u,d
                    puls      pc,u
L265F               leau      $0d,u
                    pshs      u
                    leax      $016a,y
                    cmpx      ,s++
                    bhi       L2654
                    ldd       #$00C8
                    std       $01FD,y
                    clra
                    clrb
                    puls      pc,u
                    puls      pc,u
L2678               pshs      u,d
                    ldu       $08,s
                    bne       L2682
                    bsr       L264E
                    tfr       d,u
L2682               stu       -$02,s
                    beq       L26C7
                    ldd       ,s
                    std       $08,u
                    ldx       $06,s
                    ldb       $01,x
                    cmpb      #$2b
                    beq       L2698
                    ldb       $02,x
                    cmpb      #$2b
                    bne       L269E
L2698               ldd       $06,u
                    orb       #$03
                    bra       L26B8

L269E               ldd       $06,u
                    pshs      d
                    ldb       ,x
                    cmpb      #$72
                    beq       L26AC
                    cmpb      #$64
                    bne       L26B1
L26AC               ldd       #$0001
                    bra       L26B4

L26B1               ldd       #$0002
L26B4               ora       ,s+
                    orb       ,s+
L26B8               std       $06,u
                    ldd       $02,u
                    addd      $0b,u
                    std       $04,u
                    std       ,u
                    tfr       u,d
                    lbra      L27E6

L26C7               clra
                    clrb
                    lbra      L27E6

L26CC               pshs      u
                    tfr       d,u
                    leas      -$04,s
                    clra
                    clrb
                    std       ,s
                    ldx       $08,s
                    ldb       $01,x
                    sex
                    tfr       d,x
                    bra       L26FD

L26DF               ldx       $08,s
                    ldb       $02,x
                    cmpb      #$2b
                    bne       L26EC
                    ldd       #$0007
                    bra       L26F4

L26EC               ldd       #$0004
                    bra       L26F4

L26F1               ldd       #$0003
L26F4               std       ,s
                    bra       L270D

L26F8               leax      $04,s
                    lbra      L2763

L26FD               stx       -$02,s
                    beq       L270D
                    cmpx      #$0078
                    beq       L26DF
                    cmpx      #$002B
                    beq       L26F1
                    bra       L26F8

L270D               ldb       [$08,s]
                    sex
                    tfr       d,x
                    lbra      L2770

L2716               ldd       ,s
                    orb       #$01
                    bra       L2756

L271C               ldd       ,s
                    orb       #$02
                    pshs      d
                    tfr       u,d
                    lbsr      L36CC
                    leas      $02,s
                    std       $02,s
                    cmpd      #$FFFF
                    beq       L2745
                    ldd       #$0002
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    pshs      d
                    ldd       $08,s
                    lbsr      L37A0
                    leas      $06,s
                    bra       L278A

L2745               ldd       ,s
                    orb       #$02
                    pshs      d
                    tfr       u,d
                    lbsr      L36EA
                    bra       L275D

L2752               ldd       ,s
                    orb       #$81
L2756               pshs      d
                    tfr       u,d
                    lbsr      L36CC
L275D               leas      $02,s
                    std       $02,s
                    bra       L278A

L2763               leas      -$04,x
L2765               ldd       #$00CB
                    std       $01FD,y
                    clra
                    clrb
                    bra       L278C

L2770               cmpx      #$0072
                    lbeq      L2716
                    cmpx      #$0061
                    lbeq      L271C
                    cmpx      #$0077
                    beq       L2745
                    cmpx      #$0064
                    beq       L2752
                    bra       L2765

L278A               ldd       $02,s
L278C               leas      $04,s
                    puls      pc,u
                    pshs      u,d
                    clra
                    clrb
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       $04,s
                    bra       L27E1

L279E               pshs      u,d
                    ldd       $06,s
                    pshs      d
                    ldd       $02,s
                    lbsr      L26CC
                    leas      $02,s
                    tfr       d,u
                    cmpu      #$FFFF
                    bne       L27B7
                    clra
                    clrb
                    bra       L27E6

L27B7               clra
                    clrb
                    bra       L27D9
                    pshs      u,d
                    ldd       $08,s
                    lbsr      L305B
                    ldd       $06,s
                    pshs      d
                    ldd       $02,s
                    lbsr      L26CC
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    bge       L27D7
                    clra
                    clrb
                    bra       L27E6

L27D7               ldd       $08,s
L27D9               pshs      d
                    ldd       $08,s
                    pshs      d
                    tfr       u,d
L27E1               lbsr      L2678
                    leas      $04,s
L27E6               leas      $02,s
                    puls      pc,u
L27EA               pshs      u,d
                    leax      $00A7,y
                    pshs      x
                    ldd       $02,s
                    bsr       L280A
                    leas      $02,s
                    leax      $00A7,y
                    pshs      x
                    ldd       #$000D
                    lbsr      L2F72
                    leas      $02,s
                    leas      $02,s
                    puls      pc,u
L280A               pshs      u
                    tfr       d,u
                    leas      -$01,s
                    bra       L281E

L2812               ldd       $05,s
                    pshs      d
                    ldb       $02,s
                    sex
                    lbsr      L2F72
                    leas      $02,s
L281E               ldb       ,u+
                    stb       ,s
                    bne       L2812
                    leas      $01,s
                    puls      pc,u
                    pshs      u,d
                    leas      -$02,s
                    ldu       $02,s
                    bra       L2834

L2830               ldd       ,s
                    stb       ,u+
L2834               leax      $009a,y
                    tfr       x,d
                    lbsr      L31A9
                    std       ,s
                    cmpd      #$000D
                    beq       L284D
                    ldd       ,s
                    cmpd      #$FFFF
                    bne       L2830
L284D               ldd       ,s
                    cmpd      #$FFFF
                    bne       L2859
                    clra
                    clrb
                    bra       L285F

L2859               clra
                    clrb
                    stb       ,u
                    ldd       $02,s
L285F               leas      $04,s
                    puls      pc,u
L2863               pshs      u,d
                    ldu       $06,s
                    leas      -$04,s
                    ldd       $04,s
                    std       ,s
                    bra       L287D

L286F               ldd       $02,s
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    cmpb      #$0d
                    beq       L2892
L287D               tfr       u,d
                    leau      -$01,u
                    std       -$02,s
                    ble       L2892
                    ldd       $0C,s
                    lbsr      L31A9
                    std       $02,s
                    cmpd      #$FFFF
                    bne       L286F
L2892               clra
                    clrb
                    stb       [,s]
                    ldd       $02,s
                    cmpd      #$FFFF
                    bne       L28A2
                    clra
                    clrb
                    bra       L28A4

L28A2               ldd       $04,s
L28A4               leas      $06,s
                    puls      pc,u
L28A8               pshs      u
                    tfr       d,u
                    ldd       #$FFB6
                    lbsr      L00FB
                    leas      -$06,s
                    ldd       $0C,s
                    bra       L28E1

L28B8               ldd       $0a,s
                    bra       L28D2

L28BC               ldd       $0e,s
                    lbsr      L31A9
                    std       ,s
                    cmpd      #$FFFF
                    beq       L28D8
                    ldd       ,s
                    stb       ,u+
                    ldd       $04,s
                    addd      #$FFFF
L28D2               std       $04,s
                    ldd       $04,s
                    bne       L28BC
L28D8               ldd       $04,s
                    bne       L28E7
                    ldd       $02,s
                    addd      #$FFFF
L28E1               std       $02,s
                    ldd       $02,s
                    bne       L28B8
L28E7               ldd       $0C,s
                    subd      $02,s
                    leas      $06,s
                    puls      pc,u
L28EF               pshs      u,d
                    leax      $00A7,y
                    stx       $16D5,y
                    leax      $06,s
                    pshs      x
                    ldd       $02,s
                    bra       L290F

L2901               pshs      u,d
                    ldd       ,s
                    std       $16D5,y
                    leax      $08,s
                    pshs      x
                    ldd       $08,s
L290F               pshs      d
                    leax      L2D95,pcr
                    tfr       x,d
                    bsr       L2943
                    leas      $04,s
                    bra       L293F

L291D               pshs      u,d
                    ldd       ,s
                    std       $16D5,y
                    leax      $08,s
                    pshs      x
                    ldd       $08,s
                    pshs      d
                    leax      L2DA6,pcr
                    tfr       x,d
                    bsr       L2943
                    leas      $04,s
                    clra
                    clrb
                    stb       [$16D5,y]
                    ldd       ,s
L293F               leas      $02,s
                    puls      pc,u
L2943               pshs      u,d
                    ldu       $06,s
                    leas      -$0b,s
                    bra       L2955

L294B               ldb       $08,s
                    lbeq      L2B72
                    sex
                    jsr       [$0b,s]
L2955               ldb       ,u+
                    stb       $08,s
                    cmpb      #$25
                    bne       L294B
                    ldb       ,u+
                    stb       $08,s
                    clra
                    clrb
                    std       $02,s
                    std       $06,s
                    ldb       $08,s
                    cmpb      #$2d
                    bne       L297A
                    ldd       #$0001
                    std       $16EB,y
                    ldb       ,u+
                    stb       $08,s
                    bra       L2980

L297A               clra
                    clrb
                    std       $16EB,y
L2980               ldb       $08,s
                    cmpb      #$30
                    bne       L298B
                    ldd       #$0030
                    bra       L298E

L298B               ldd       #$0020
L298E               std       $16ED,y
                    bra       L29AE

L2994               ldd       $06,s
                    pshs      d
                    ldd       #$000A
                    lbsr      L3A19
                    pshs      d
                    ldb       $0a,s
                    sex
                    addd      #$FFD0
                    addd      ,s++
                    std       $06,s
                    ldb       ,u+
                    stb       $08,s
L29AE               ldb       $08,s
                    sex
                    leax      $016b,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$08
                    bne       L2994
                    ldb       $08,s
                    cmpb      #$2e
                    bne       L29F7
                    ldd       #$0001
                    std       $04,s
                    bra       L29E1

L29CB               ldd       $02,s
                    pshs      d
                    ldd       #$000A
                    lbsr      L3A19
                    pshs      d
                    ldb       $0a,s
                    sex
                    addd      #$FFD0
                    addd      ,s++
                    std       $02,s
L29E1               ldb       ,u+
                    stb       $08,s
                    ldb       $08,s
                    sex
                    leax      $016b,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$08
                    bne       L29CB
                    bra       L29FB

L29F7               clra
                    clrb
                    std       $04,s
L29FB               ldb       $08,s
                    sex
                    tfr       d,x
                    lbra      L2B15

L2A03               ldd       $06,s
                    pshs      d
                    ldx       $15,s
                    leax      $02,x
                    stx       $15,s
                    ldd       -$02,x
                    lbsr      L2B76
                    lbra      L2AE5

L2A17               ldd       $06,s
                    pshs      d
                    ldx       $15,s
                    leax      $02,x
                    stx       $15,s
                    ldd       -$02,x
                    lbsr      L2C31
                    lbra      L2AE5

L2A2B               ldd       $06,s
                    pshs      d
                    ldb       $0a,s
                    sex
                    leax      $016b,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$02
                    pshs      d
                    ldx       $17,s
                    leax      $02,x
                    stx       $17,s
                    ldd       -$02,x
                    lbsr      L2C7B
                    lbra      L2B00

L2A4F               ldd       $06,s
                    pshs      d
                    ldx       $15,s
                    leax      $02,x
                    stx       $15,s
                    ldd       -$02,x
                    pshs      d
                    leax      $16D7,y
                    tfr       x,d
                    lbsr      L2BBA
                    lbra      L2B00

L2A6B               ldd       $04,s
                    bne       L2A74
                    ldd       #$0006
                    std       $02,s
L2A74               ldd       $06,s
                    pshs      d
                    leax      $15,s
                    pshs      x
                    ldd       $06,s
                    pshs      d
                    ldb       $0e,s
                    sex
                    lbsr      $33C4
                    leas      $04,s
                    lbra      L2AE5

L2A8C               ldx       $13,s
                    leax      $02,x
                    stx       $13,s
                    ldd       -$02,x
                    lbra      L2B0F

L2A99               ldx       $13,s
                    leax      $02,x
                    stx       $13,s
                    ldd       -$02,x
                    std       $09,s
                    ldd       $04,s
                    beq       L2ADF
                    ldd       $09,s
                    std       $04,s
                    bra       L2ABB

L2AAF               ldb       [$09,s]
                    beq       L2AC7
                    ldd       $09,s
                    addd      #$0001
                    std       $09,s
L2ABB               ldd       $02,s
                    addd      #$FFFF
                    std       $02,s
                    subd      #$FFFF
                    bne       L2AAF
L2AC7               ldd       $06,s
                    pshs      d
                    ldd       $0b,s
                    subd      $06,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       $11,s
                    lbsr      L2CE9
                    leas      $06,s
                    bra       L2B09

L2ADF               ldd       $06,s
                    pshs      d
                    ldd       $0b,s
L2AE5               pshs      d
                    bra       L2B02

L2AE9               ldb       ,u+
                    stb       $08,s
                    bra       L2AF1
                    leas      -$0d,x
L2AF1               ldd       $06,s
                    pshs      d
                    leax      $15,s
                    pshs      x
                    ldb       $0C,s
                    sex
                    lbsr      L3384
L2B00               std       ,s
L2B02               ldd       $0f,s
                    lbsr      L2D3F
                    leas      $04,s
L2B09               lbra      L2955

L2B0C               ldb       $08,s
                    sex
L2B0F               jsr       [$0b,s]
                    lbra      L2955

L2B15               cmpx      #$0064
                    lbeq      L2A03
                    cmpx      #$006F
                    lbeq      L2A17
                    cmpx      #$0078
                    lbeq      L2A2B
                    cmpx      #$0058
                    lbeq      L2A2B
                    cmpx      #$0075
                    lbeq      L2A4F
                    cmpx      #$0066
                    lbeq      L2A6B
                    cmpx      #$0065
                    lbeq      L2A6B
                    cmpx      #$0067
                    lbeq      L2A6B
                    cmpx      #$0045
                    lbeq      L2A6B
                    cmpx      #$0047
                    lbeq      L2A6B
                    cmpx      #$0063
                    lbeq      L2A8C
                    cmpx      #$0073
                    lbeq      L2A99
                    cmpx      #$006C
                    lbeq      L2AE9
                    bra       L2B0C

L2B72               leas      $0d,s
                    puls      pc,u
L2B76               pshs      u,d
                    leas      -$02,s
                    leax      $16D7,y
                    stx       ,s
                    ldd       $02,s
                    bge       L2BAD
                    nega
                    negb
                    sbca      #$00
                    std       $02,s
                    std       -$02,s
                    bge       L2BA2
                    leax      L2DBA,pcr
                    pshs      x
                    leax      $16D7,y
                    tfr       x,d
                    lbsr      L33E2
                    leas      $02,s
                    lbra      L2C77

L2BA2               ldd       #$002D
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
L2BAD               ldd       $02,s
                    pshs      d
                    ldd       $02,s
                    bsr       L2BBA
                    leas      $02,s
                    lbra      L2C71

L2BBA               pshs      u,d
                    leas      -$06,s
                    ldu       $06,s
                    clra
                    clrb
                    std       $02,s
                    std       ,s
                    bra       L2BD7

L2BC8               ldd       ,s
                    addd      #$0001
                    std       ,s
                    ldd       $0C,s
                    subd      $008d,y
                    std       $0C,s
L2BD7               ldd       $0C,s
                    blt       L2BC8
                    leax      $008d,y
                    stx       $04,s
                    bra       L2C17

L2BE3               ldd       ,s
                    addd      #$0001
                    std       ,s
L2BEA               ldd       $0C,s
                    subd      [$04,s]
                    std       $0C,s
                    bge       L2BE3
                    addd      [$04,s]
                    std       $0C,s
                    ldd       ,s
                    beq       L2C01
                    ldd       #$0001
                    std       $02,s
L2C01               ldd       $02,s
                    beq       L2C0C
                    ldd       ,s
                    addd      #$0030
                    stb       ,u+
L2C0C               clra
                    clrb
                    std       ,s
                    ldd       $04,s
                    addd      #$0002
                    std       $04,s
L2C17               ldd       $04,s
                    cmpd      $0095,y
                    bne       L2BEA
                    ldd       $0C,s
                    addd      #$0030
                    stb       ,u+
                    clra
                    clrb
                    stb       ,u
                    ldd       $06,s
                    leas      $08,s
                    puls      pc,u
L2C31               pshs      u,d
                    leas      -$02,s
                    leax      $16D7,y
                    stx       ,s
                    leau      $16E1,y
L2C3F               ldd       $02,s
                    clra
                    andb      #$07
                    addd      #$0030
                    stb       ,u+
                    ldd       $02,s
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    std       $02,s
                    bne       L2C3F
                    bra       L2C61

L2C57               ldb       ,u
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
L2C61               leau      -$01,u
                    pshs      u
                    leax      $16E1,y
                    cmpx      ,s++
                    bls       L2C57
                    clra
                    clrb
                    stb       [,s]
L2C71               leax      $16D7,y
                    tfr       x,d
L2C77               leas      $04,s
                    puls      pc,u
L2C7B               pshs      u,d
                    leas      -$04,s
                    leax      $16D7,y
                    stx       $02,s
                    leau      $16E1,y
L2C89               ldd       $04,s
                    clra
                    andb      #$0f
                    std       ,s
                    pshs      d
                    ldd       $02,s
                    cmpd      #$0009
                    ble       L2CAB
                    ldd       $0C,s
                    beq       L2CA3
                    ldd       #$0041
                    bra       L2CA6

L2CA3               ldd       #$0061
L2CA6               addd      #$FFF6
                    bra       L2CAE

L2CAB               ldd       #$0030
L2CAE               addd      ,s++
                    stb       ,u+
                    ldd       $04,s
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    anda      #$0f
                    std       $04,s
                    bne       L2C89
                    bra       L2CCE

L2CC4               ldb       ,u
                    ldx       $02,s
                    leax      $01,x
                    stx       $02,s
                    stb       -$01,x
L2CCE               leau      -$01,u
                    pshs      u
                    leax      $16E1,y
                    cmpx      ,s++
                    bls       L2CC4
                    clra
                    clrb
                    stb       [$02,s]
                    leax      $16D7,y
                    tfr       x,d
                    leas      $06,s
                    puls      pc,u
L2CE9               pshs      u,d
                    ldu       $06,s
                    ldd       $0a,s
                    subd      $08,s
                    std       $0a,s
                    ldd       $16EB,y
                    bne       L2D14
                    bra       L2D01

L2CFB               ldd       $16ED,y
                    jsr       [,s]
L2D01               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    subd      #$FFFF
                    bgt       L2CFB
                    bra       L2D14

L2D0F               ldb       ,u+
                    sex
                    jsr       [,s]
L2D14               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bne       L2D0F
                    ldd       $16EB,y
                    lbeq      L2DB6
                    bra       L2D30

L2D2A               ldd       $16ED,y
                    jsr       [,s]
L2D30               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    subd      #$FFFF
                    bgt       L2D2A
                    lbra      L2DB6

L2D3F               pshs      u,d
                    ldu       $06,s
                    ldd       $08,s
                    pshs      d
                    tfr       u,d
                    lbsr      $33CF
                    nega
                    negb
                    sbca      #$00
                    addd      ,s++
                    std       $08,s
                    ldd       $16EB,y
                    bne       L2D75
                    bra       L2D62

L2D5C               ldd       $16ED,y
                    jsr       [,s]
L2D62               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bgt       L2D5C
                    bra       L2D75

L2D70               ldb       ,u+
                    sex
                    jsr       [,s]
L2D75               ldb       ,u
                    bne       L2D70
                    ldd       $16EB,y
                    beq       L2DB6
                    bra       L2D87

L2D81               ldd       $16ED,y
                    jsr       [,s]
L2D87               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bgt       L2D81
                    bra       L2DB6

L2D95               pshs      u,d
                    ldd       $16D5,y
                    pshs      d
                    ldd       $02,s
                    lbsr      L2F72
                    leas      $02,s
                    bra       L2DB6

L2DA6               pshs      u,d
                    ldd       ,s
                    ldx       $16D5,y
                    leax      $01,x
                    stx       $16D5,y
                    stb       -$01,x
L2DB6               leas      $02,s
                    puls      pc,u
L2DBA               blt       L2DEF
                    leas      -$09,y
                    pshu      y,x,dp
                    neg       L0034
                    nega
                    tfr       d,u
                    leas      -$06,s
                    cmpu      #$0000
                    beq       L2DD4
                    ldd       $06,u
                    clra
                    andb      #$03
                    bne       L2DDA
L2DD4               ldd       #$FFFF
                    lbra      L2EEE

L2DDA               ldd       $06,u
                    anda      #$80
                    clrb
                    std       -$02,s
                    bne       L2DEB
                    tfr       u,d
                    lbsr      L32F8
                    lbra      L2EB7

L2DEB               ldd       $06,u
                    anda      #$01
L2DEF               clrb
                    std       -$02,s
                    beq       L2E08
                    tfr       u,d
                    lbsr      L3090
                    ldd       $06,u
                    anda      #$FE
                    std       $06,u
                    ldd       $02,u
                    addd      $0b,u
                    std       $04,u
                    lbra      L2EB5

L2E08               ldd       ,u
                    cmpd      $04,u
                    lbcc      L2EB7
                    leax      $02,s
                    pshs      x
                    leax      $0C,s
                    lbsr      L39E5
                    ldx       $0e,s
                    lbra      L2E85

L2E1F               leax      $02,s
                    pshs      x
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    tfr       u,d
                    lbsr      L2F09
                    lbsr      L396C
                    lbsr      L39E5
L2E36               ldd       $0b,u
                    lbsr      L39CC
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    leax      $06,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    bsr       L2E53
                    fcb       $00,$00,$00,$00
L2E53               puls      x
                    lbsr      L3981
                    bge       L2E61
                    leax      $06,s
                    lbsr      L39A5
                    bra       L2E63

L2E61               leax      $06,s
L2E63               lbsr      L3981
                    blt       L2E92
                    ldd       $04,s
                    addd      ,u
                    std       ,s
                    cmpd      $02,u
                    bcs       L2E92
                    cmpd      $04,u
                    bcc       L2E92
                    std       ,u
                    ldd       $06,u
                    andb      #$EF
                    std       $06,u
                    lbra      L2EEC
                    bra       L2E92

L2E85               stx       -$02,s
                    lbeq      L2E1F
                    cmpx      #$0001
                    lbeq      L2E36
L2E92               ldd       $0e,s
                    cmpd      #$0001
                    bne       L2EB3
                    leax      $0a,s
                    pshs      x
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $04,u
                    subd      ,u
                    lbsr      L39CC
                    lbsr      L396C
                    lbsr      L39E5
L2EB3               ldd       $04,u
L2EB5               std       ,u
L2EB7               ldd       $06,u
                    andb      #$EF
                    std       $06,u
                    ldd       $0e,s
                    pshs      d
                    leax      $0C,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $08,u
                    lbsr      L37A0
                    leas      $06,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    bsr       L2EE0
                    fcb       $FF,$FF,$FF,$FF
L2EE0               puls      x
                    lbsr      L3981
                    bne       L2EEC
                    ldd       #$FFFF
                    bra       L2EEE

L2EEC               clra
                    clrb
L2EEE               leas      $06,s
                    puls      pc,u
                    pshs      u,d
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    pshs      d
                    ldd       $06,s
                    lbsr      $2DC1
                    leas      $06,s
                    leas      $02,s
                    puls      pc,u
L2F09               pshs      u
                    tfr       d,u
                    cmpu      #$0000
                    beq       L2F1A
                    ldd       $06,u
                    clra
                    andb      #$03
                    bne       L2F2D
L2F1A               bsr       L2F20
                    fcb       $FF,$FF,$FF,$FF
L2F20               puls      x
                    leau      $01F1,y
                    pshs      u
                    lbsr      L39E5
                    puls      pc,u
L2F2D               ldd       $06,u
                    anda      #$80
                    clrb
                    std       -$02,s
                    bne       L2F3B
                    tfr       u,d
                    lbsr      L32F8
L2F3B               ldd       #$0001
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    pshs      d
                    ldd       $08,u
                    lbsr      L37A0
                    leas      $06,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    beq       L2F62
                    ldd       $02,u
                    bra       L2F64

L2F62               ldd       $04,u
L2F64               pshs      d
                    ldd       ,u
                    subd      ,s++
                    lbsr      L39CC
                    lbsr      L3957
                    puls      pc,u
L2F72               pshs      u,d
                    ldu       $06,s
                    ldd       $06,u
                    anda      #$80
                    andb      #$22
                    cmpd      #$8002
                    beq       L2F94
                    ldd       $06,u
                    clra
                    andb      #$22
                    cmpd      #$0002
                    lbne      L306B
                    tfr       u,d
                    lbsr      L32F8
L2F94               ldd       $06,u
                    clra
                    andb      #$04
                    beq       L2FD0
                    ldd       #$0001
                    pshs      d
                    leax      $03,s
                    pshs      x
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L2FB1
                    leax      L3787,pcr
                    bra       L2FB5

L2FB1               leax      L3777,pcr
L2FB5               tfr       x,d
                    tfr       d,x
                    ldd       $08,u
                    jsr       ,x
                    leas      $04,s
                    cmpd      #$FFFF
                    lbne      L308A
                    ldd       $06,u
                    orb       #$20
                    std       $06,u
                    lbra      L306B

L2FD0               ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       L2FDE
                    tfr       u,d
                    lbsr      L30BE
L2FDE               ldd       ,u
                    addd      #$0001
                    std       ,u
                    subd      #$0001
                    tfr       d,x
                    ldd       ,s
                    stb       ,x
                    ldd       ,u
                    cmpd      $04,u
                    bcc       L3008
                    ldd       $06,u
                    clra
                    andb      #$40
                    lbeq      L308A
                    ldd       ,s
                    cmpd      #$000D
                    lbne      L308A
L3008               tfr       u,d
                    lbsr      L30BE
                    std       -$02,s
                    lbne      L306B
                    lbra      L308A
                    pshs      u
                    tfr       d,u
                    ldd       $04,s
                    pshs      d
                    pshs      u
                    ldd       #$0008
                    lbsr      L3A78
                    lbsr      L2F72
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    tfr       u,d
                    lbsr      L2F72
                    lbra      L308C

L3037               pshs      u,d
                    leau      $009a,y
                    clra
                    clrb
                    std       ,s
                    bra       L3049

L3043               tfr       u,d
                    leau      $0d,u
                    bsr       L305B
L3049               ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    cmpd      #$0010
                    blt       L3043
                    bra       L308C

L305B               pshs      u
                    tfr       d,u
                    leas      -$02,s
                    cmpu      #$0000
                    beq       L306B
                    ldd       $06,u
                    bne       L3070
L306B               ldd       #$FFFF
                    bra       L308C

L3070               ldd       $06,u
                    clra
                    andb      #$02
                    beq       L307D
                    tfr       u,d
                    bsr       L3090
                    bra       L307F

L307D               clra
                    clrb
L307F               std       ,s
                    ldd       $08,u
                    lbsr      L36D9
                    clra
                    clrb
                    std       $06,u
L308A               ldd       ,s
L308C               leas      $02,s
                    puls      pc,u
L3090               pshs      u
                    tfr       d,u
                    cmpu      #$0000
                    beq       L30A5
                    ldd       $06,u
                    clra
                    andb      #$22
                    cmpd      #$0002
                    beq       L30AA
L30A5               ldd       #$FFFF
                    puls      pc,u
L30AA               ldd       $06,u
                    anda      #$80
                    clrb
                    std       -$02,s
                    bne       L30B8
                    tfr       u,d
                    lbsr      L32F8
L30B8               tfr       u,d
                    bsr       L30BE
                    puls      pc,u
L30BE               pshs      u
                    tfr       d,u
                    leas      -$04,s
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       L30EC
                    ldd       ,u
                    cmpd      $04,u
                    beq       L30EC
                    clra
                    clrb
                    pshs      d
                    tfr       u,d
                    lbsr      L2F09
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $08,u
                    lbsr      L37A0
                    leas      $06,s
L30EC               ldd       ,u
                    subd      $02,u
                    std       $02,s
                    lbeq      L3160
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    lbeq      L3160
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L3139
                    ldd       $02,u
                    bra       L3131

L310C               ldd       $02,s
                    pshs      d
                    ldd       ,u
                    pshs      d
                    ldd       $08,u
                    lbsr      L3787
                    leas      $04,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       L3127
                    leax      $04,s
                    bra       L314F

L3127               ldd       $02,s
                    subd      ,s
                    std       $02,s
                    ldd       ,u
                    addd      ,s
L3131               std       ,u
                    ldd       $02,s
                    bne       L310C
                    bra       L3160

L3139               ldd       $02,s
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    ldd       $08,u
                    lbsr      L3777
                    leas      $04,s
                    cmpd      $02,s
                    beq       L3160
                    bra       L3151

L314F               leas      -$04,x
L3151               ldd       $06,u
                    orb       #$20
                    std       $06,u
                    ldd       $04,u
                    std       ,u
                    ldd       #$FFFF
                    bra       L3170

L3160               ldd       $06,u
                    ora       #$01
                    std       $06,u
                    ldd       $02,u
                    std       ,u
                    addd      $0b,u
                    std       $04,u
                    clra
                    clrb
L3170               leas      $04,s
                    puls      pc,u
                    pshs      u,d
                    ldd       ,s
                    leax      $016b,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$04
                    beq       L31A3
                    ldd       ,s
                    clra
                    andb      #$DF
                    bra       L31A5

L318C               pshs      u,d
                    ldd       ,s
                    leax      $016b,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$02
                    beq       L31A3
                    ldd       ,s
                    orb       #$20
                    bra       L31A5

L31A3               ldd       ,s
L31A5               leas      $02,s
                    puls      pc,u
L31A9               pshs      u
                    tfr       d,u
                    cmpu      #$0000
                    beq       L31BC
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    beq       L31C1
L31BC               ldd       #$FFFF
                    puls      pc,u
L31C1               ldd       ,u
                    cmpd      $04,u
                    bcc       L31D7
                    addd      #$0001
                    std       ,u
                    subd      #$0001
                    tfr       d,x
                    ldb       ,x
                    clra
                    bra       L31DC

L31D7               tfr       u,d
                    lbsr      L3247
L31DC               puls      pc,u
                    pshs      u,d
                    ldu       $06,s
                    lbeq      L32DE
                    ldd       $06,u
                    clra
                    andb      #$01
                    lbeq      L32DE
                    ldd       ,s
                    cmpd      #$FFFF
                    lbeq      L32DE
                    ldd       ,u
                    cmpd      $02,u
                    lbls      L32DE
                    ldd       ,u
                    addd      #$FFFF
                    std       ,u
                    tfr       d,x
                    ldd       ,s
                    stb       ,x
                    lbra      L32F4
                    pshs      u
                    tfr       d,u
                    leas      -$04,s
                    tfr       u,d
                    lbsr      L31A9
                    std       $02,s
                    cmpd      #$FFFF
                    beq       L3232
                    tfr       u,d
                    lbsr      L31A9
                    std       ,s
                    cmpd      #$FFFF
                    bne       L3237
L3232               ldd       #$FFFF
                    bra       L3243

L3237               ldd       $02,s
                    pshs      d
                    ldd       #$0008
                    lbsr      L3A8F
                    addd      ,s
L3243               leas      $04,s
                    puls      pc,u
L3247               pshs      u
                    tfr       d,u
                    leas      -$02,s
                    ldd       $06,u
                    anda      #$80
                    andb      #$31
                    cmpd      #$8001
                    beq       L326B
                    ldd       $06,u
                    clra
                    andb      #$31
                    cmpd      #$0001
                    lbne      L32DE
                    tfr       u,d
                    lbsr      L32F8
L326B               leax      $009a,y
                    pshs      x
                    cmpu      ,s++
                    bne       L3286
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L3286
                    leax      $00A7,y
                    tfr       x,d
                    lbsr      L3090
L3286               ldd       $06,u
                    clra
                    andb      #$08
                    beq       L32B0
                    ldd       $0b,u
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L32A2
                    leax      L3761,pcr
                    bra       L32A6

L32A2               leax      L3753,pcr
L32A6               tfr       x,d
                    tfr       d,x
                    ldd       $08,u
                    jsr       ,x
                    bra       L32C0

L32B0               ldd       #$0001
                    pshs      d
                    leax      $0a,u
                    stx       $02,u
                    pshs      x
                    ldd       $08,u
                    lbsr      L3753
L32C0               leas      $04,s
                    std       ,s
                    ldd       ,s
                    bgt       L32E3
                    ldd       $06,u
                    pshs      d
                    ldd       $02,s
                    beq       L32D5
                    ldd       #$0020
                    bra       L32D8

L32D5               ldd       #$0010
L32D8               ora       ,s+
                    orb       ,s+
                    std       $06,u
L32DE               ldd       #$FFFF
                    bra       L32F4

L32E3               ldd       $02,u
                    addd      #$0001
                    std       ,u
                    ldd       $02,u
                    addd      ,s
                    std       $04,u
                    ldb       [$02,u]
                    clra
L32F4               leas      $02,s
                    puls      pc,u
L32F8               pshs      u
                    tfr       d,u
                    ldd       #$FF98
                    lbsr      L00FB
                    ldd       $06,u
                    clra
                    andb      #$C0
                    bne       L3330
                    leas      -$22,s
                    leax      ,s
                    pshs      x
                    ldd       $08,u
                    lbsr      L391C
                    leas      $02,s
                    ldd       $06,u
                    pshs      d
                    ldb       $02,s
                    bne       L3324
                    ldd       #$0040
                    bra       L3327

L3324               ldd       #$0080
L3327               ora       ,s+
                    orb       ,s+
                    std       $06,u
                    leas      $22,s
L3330               ldd       $06,u
                    ora       #$80
                    std       $06,u
                    clra
                    andb      #$0C
                    beq       L333D
                    puls      pc,u
L333D               ldd       $0b,u
                    bne       L3352
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L334D
                    ldd       #$0080
                    bra       L3350

L334D               ldd       #$0100
L3350               std       $0b,u
L3352               ldd       $02,u
                    bne       L3363
                    ldd       $0b,u
                    lbsr      L3871
                    std       $02,u
                    cmpd      #$FFFF
                    beq       L336B
L3363               ldd       $06,u
                    orb       #$08
                    std       $06,u
                    bra       L337A

L336B               ldd       $06,u
                    orb       #$04
                    std       $06,u
                    leax      $0a,u
                    stx       $02,u
                    ldd       #$0001
                    std       $0b,u
L337A               ldd       $02,u
                    addd      $0b,u
                    std       $04,u
                    std       ,u
                    puls      pc,u
L3384               pshs      u,d
                    ldb       $01,s
                    sex
                    tfr       d,x
                    bra       L33AA

L338D               ldd       [$06,s]
                    addd      #$0004
                    std       [$06,s]
                    leax      >L33C3,pcr
                    bra       L33A6

L339C               ldb       $01,s
                    stb       $0098,y
                    leax      $0097,y
L33A6               tfr       x,d
                    bra       L33BF

L33AA               cmpx      #$0064
                    beq       L338D
                    cmpx      #$006F
                    lbeq      L338D
                    cmpx      #$0078
                    lbeq      L338D
                    bra       L339C

L33BF               leas      $02,s
                    puls      pc,u
L33C3               neg       L0034
                    nega
                    leax      >L33CE,pcr
                    tfr       x,d
                    puls      pc,u
L33CE               neg       L0034
                    rora
                    ldu       ,s
L33D3               ldb       ,u+
                    bne       L33D3
                    tfr       u,d
                    subd      ,s
                    addd      #$FFFF
                    leas      $02,s
                    puls      pc,u
L33E2               pshs      u,d
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $02,s
                    std       ,s
L33EC               ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L33EC
                    bra       L3421

L33FA               pshs      u,d
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $02,s
                    std       ,s
L3404               ldx       ,s
                    leax      $01,x
                    stx       ,s
                    ldb       -$01,x
                    bne       L3404
                    ldd       ,s
                    addd      #$FFFF
                    std       ,s
L3415               ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L3415
L3421               ldd       $02,s
                    leas      $04,s
                    puls      pc,u
L3427               pshs      u
                    tfr       d,u
                    bra       L343D

L342D               ldx       $04,s
                    leax      $01,x
                    stx       $04,s
                    ldb       -$01,x
                    bne       L343B
                    clra
                    clrb
                    puls      pc,u
L343B               leau      $01,u
L343D               ldb       ,u
                    sex
                    pshs      d
                    ldb       [$06,s]
                    sex
                    cmpd      ,s++
                    beq       L342D
                    sex
                    pshs      d
                    ldb       ,u
                    sex
                    subd      ,s++
                    puls      pc,u
L3455               pshs      u,d
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $02,s
                    std       ,s
L345F               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    subd      #$FFFF
                    ble       L3483
                    ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L345F
                    bra       L3483

L3479               clra
                    clrb
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
L3483               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    subd      #$FFFF
                    bgt       L3479
                    lbra      L3512

L3492               pshs      u
                    tfr       d,u
                    bra       L34A8

L3498               ldx       $04,s
                    leax      $01,x
                    stx       $04,s
                    ldb       -$01,x
                    bne       L34A6
                    clra
                    clrb
                    puls      pc,u
L34A6               leau      $01,u
L34A8               ldd       $06,s
                    addd      #$FFFF
                    std       $06,s
                    subd      #$FFFF
                    ble       L34C2
                    ldb       ,u
                    sex
                    pshs      d
                    ldb       [$06,s]
                    sex
                    cmpd      ,s++
                    beq       L3498
L34C2               ldd       $06,s
                    bge       L34CA
                    clra
                    clrb
                    bra       L34D5

L34CA               ldb       [$04,s]
                    sex
                    pshs      d
                    ldb       ,u
                    sex
                    subd      ,s++
L34D5               puls      pc,u
                    pshs      u,d
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $02,s
                    std       ,s
L34E1               ldx       ,s
                    leax      $01,x
                    stx       ,s
                    ldb       -$01,x
                    bne       L34E1
                    ldd       ,s
                    addd      #$FFFF
                    std       ,s
L34F2               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    subd      #$FFFF
                    ble       L350A
                    ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L34F2
L350A               ldd       $0a,s
                    bge       L3512
                    clra
                    clrb
                    stb       [,s]
L3512               ldd       $02,s
                    leas      $04,s
                    puls      pc,u
L3518               pshs      u,d
                    ldu       ,s
L351C               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    stb       ,u+
                    bgt       L351C
                    ldb       -$01,u
                    clra
                    andb      #$7f
                    stb       -$01,u
                    clra
                    clrb
                    stb       ,u
                    ldd       ,s
                    leas      $02,s
                    puls      pc,u
L3539               pshs      u,d
                    leas      -$04,s
                    ldd       $04,s
                    addd      #$00FF
                    pshs      d
                    ldd       #$0008
                    lbsr      L3A78
                    pshs      d
                    ldd       #$0008
                    lbsr      L3A8F
                    std       ,s
                    aslb
                    rola
                    aslb
                    rola
                    lbsr      L380B
                    tfr       d,u
                    cmpu      #$FFFF
                    bne       L3567
                    clra
                    clrb
                    bra       L357B

L3567               stu       $02,s
                    ldd       ,s
                    ldx       $02,s
                    std       $02,x
                    tfr       x,d
                    addd      #$0004
                    lbsr      L3602
                    ldd       $01EB,y
L357B               leas      $06,s
                    puls      pc,u
L357F               pshs      u,d
                    leas      -$06,s
                    ldd       $06,s
                    addd      #$0003
                    lsra
                    rorb
                    lsra
                    rorb
                    addd      #$0001
                    std       ,s
                    ldd       $01EB,y
                    std       $04,s
                    bne       L35AF
                    leax      $16EF,y
                    stx       $04,s
                    tfr       x,d
                    std       $01EB,y
                    std       $16EF,y
                    clra
                    clrb
                    std       $16F1,y
L35AF               ldu       [$04,s]
L35B2               ldd       $02,u
                    cmpd      ,s
                    bcs       L35E2
                    cmpd      ,s
                    bne       L35C5
                    ldd       ,u
                    std       [$04,s]
                    bra       L35D3

L35C5               subd      ,s
                    std       $02,u
                    aslb
                    rola
                    aslb
                    rola
                    leau      d,u
                    ldd       ,s
                    std       $02,u
L35D3               ldd       $04,s
                    std       $01EB,y
                    pshs      u
                    ldd       #$0004
                    addd      ,s++
                    bra       L35FE

L35E2               cmpu      $01EB,y
                    bne       L35F8
                    ldd       ,s
                    lbsr      L3539
                    tfr       d,u
                    stu       -$02,s
                    bne       L35F8
                    clra
                    clrb
                    bra       L35FE

L35F8               stu       $04,s
                    ldu       ,u
                    bra       L35B2

L35FE               leas      $08,s
                    puls      pc,u
L3602               pshs      u,d
                    leas      -$02,s
                    ldd       $02,s
                    addd      #$FFFC
                    tfr       d,u
                    ldd       $01EB,y
                    bra       L3628

L3613               ldd       ,s
                    cmpd      [,s]
                    bcs       L3626
                    pshs      d
                    cmpu      ,s++
                    bhi       L3636
                    cmpu      [,s]
                    bcs       L3636
L3626               ldd       [,s]
L3628               std       ,s
                    cmpu      ,s
                    bls       L3613
                    cmpu      [,s]
                    lbcc      L3613
L3636               pshs      u
                    ldd       $02,u
                    aslb
                    rola
                    aslb
                    rola
                    addd      ,s++
                    cmpd      [,s]
                    bne       L3656
                    ldd       $02,u
                    pshs      d
                    ldx       [$02,s]
                    ldd       $02,x
                    addd      ,s++
                    std       $02,u
                    ldd       ,x
                    bra       L3658

L3656               ldd       [,s]
L3658               std       ,u
                    ldx       ,s
                    ldd       $02,x
                    aslb
                    rola
                    aslb
                    rola
                    addd      ,s
                    pshs      d
                    cmpu      ,s++
                    bne       L3677
                    ldd       $02,x
                    addd      $02,u
                    std       $02,x
                    ldd       ,u
                    std       ,x
                    bra       L3679

L3677               stu       ,x
L3679               tfr       x,d
                    std       $01EB,y
                    bra       L36A5
                    pshs      u,d
                    leas      -$02,s
                    ldd       $02,s
                    pshs      d
                    ldd       $0a,s
                    lbsr      L3A19
                    std       ,s
                    lbsr      L357F
                    tfr       d,u
                    stu       -$02,s
                    beq       L36A3
                    ldd       ,s
                    pshs      d
                    tfr       u,d
                    bsr       L36A9
                    leas      $02,s
L36A3               tfr       u,d
L36A5               leas      $04,s
                    puls      pc,u
L36A9               pshs      u
                    tfr       d,u
                    bra       L36B3

L36AF               clra
                    clrb
                    stb       ,u+
L36B3               ldd       $04,s
                    addd      #$FFFF
                    std       $04,s
                    subd      #$FFFF
                    bne       L36AF
                    puls      pc,u
                    tfr       d,x
                    lda       $03,s
                    os9       I$Open
                    bcc       L36DB
                    bra       L36DE

L36CC               tfr       d,x
                    lda       $03,s
                    os9       I$Open
                    bcs       L372D
                    tfr       a,b
                    clra
                    rts

L36D9               tfr       b,a
L36DB               os9       I$Close
L36DE               lbra      L3944
                    tfr       d,x
                    ldb       $03,s
                    os9       I$MakDir
                    bra       L36DE

L36EA               pshs      d
                    ldx       ,s
                    lda       $05,s
                    tfr       a,b
                    andb      #$24
                    orb       #$0b
                    os9       I$Create
                    bcs       L3701
L36FB               leas      $02,s
                    tfr       a,b
                    clra
                    rts

L3701               cmpb      #$DA
                    bne       L372B
                    lda       $05,s
                    bita      #$80
                    bne       L372B
                    anda      #$07
                    ldx       ,s
                    os9       I$Open
                    bcs       L372B
                    pshs      u,a
                    ldx       #$0000
                    leau      ,x
                    ldb       #$02
                    os9       I$SetStt
                    puls      u,a
                    bcc       L36FB
                    pshs      b
                    os9       I$Close
                    puls      b
L372B               leas      $02,s
L372D               lbra      L393B
                    tfr       d,x
                    lda       $03,s
                    ldb       $05,s
                    os9       I$Create
                    lbcs      L393B
                    tfr       a,b
                    clra
                    rts
                    tfr       d,x
                    os9       I$Delete
                    bra       L36DE
                    tfr       b,a
                    os9       I$Dup
                    bcs       L372D
                    tfr       a,b
                    clra
                    rts

L3753               pshs      y
                    tfr       b,a
                    ldx       $04,s
                    ldy       $06,s
                    os9       I$Read
                    bra       L376D

L3761               pshs      y
                    tfr       b,a
                    ldx       $04,s
                    ldy       $06,s
                    os9       I$ReadLn
L376D               bcc       L3797
                    cmpb      #$D3
                    bne       L379B
                    clra
                    clrb
                    puls      pc,y
L3777               pshs      y
                    ldy       $06,s
                    beq       L3797
                    tfr       b,a
                    ldx       $04,s
                    os9       I$Write
                    bra       L3795

L3787               pshs      y
                    ldy       $06,s
                    beq       L3797
                    tfr       b,a
                    ldx       $04,s
                    os9       I$WritLn
L3795               bcs       L379B
L3797               tfr       y,d
                    puls      pc,y
L379B               puls      y
                    lbra      L393B

L37A0               pshs      u,d
                    ldd       $0a,s
                    bne       L37AE
                    ldu       #$0000
                    ldx       #$0000
                    bra       L37E4

L37AE               cmpd      #$0001
                    beq       L37DB
                    cmpd      #$0002
                    beq       L37D0
                    ldb       #$F7
L37BC               clra
                    std       $01FD,y
                    ldd       #$FFFF
                    leax      $01F1,y
                    std       ,x
                    std       $02,x
                    leas      $02,s
                    puls      pc,u
L37D0               lda       $01,s
                    ldb       #$02
                    os9       I$GetStt
                    bcs       L37BC
                    bra       L37E4

L37DB               lda       $01,s
                    ldb       #$05
                    os9       I$GetStt
                    bcs       L37BC
L37E4               tfr       u,d
                    addd      $08,s
                    tfr       d,u
                    tfr       x,d
                    adcb      $07,s
                    adca      $06,s
                    bmi       L37BC
                    tfr       d,x
                    stx       $01F1,y
                    stu       $01F3,y
                    lda       $01,s
                    os9       I$Seek
                    bcs       L37BC
                    leax      $01F1,y
                    leas      $02,s
                    puls      pc,u
L380B               pshs      y,d
                    cmpd      $16F3,y
                    bls       L3842
                    subd      $16F3,y
                    addd      $01EF,y
                    subd      $02,s
                    os9       F$Mem
                    tfr       y,d
                    ldy       $02,s
                    bcc       L382E
                    ldd       #$FFFF
                    leas      $04,s
                    rts

L382E               ldx       $01EF,y
                    std       $01EF,y
                    pshs      x
                    subd      ,s++
                    addd      $16F3,y
                    std       $16F3,y
L3842               ldd       $01EF,y
                    subd      $16F3,y
                    tfr       d,x
                    ldd       $16F3,y
                    subd      ,s
                    std       $16F3,y
                    ldd       ,s
                    stx       ,s
                    bitb      #$01
                    beq       L3861
                    clr       ,x+
                    decb
L3861               tfr       d,y
                    leay      ,y
                    beq       L386F
                    clra
                    clrb
L3869               std       ,x++
                    leay      -$02,y
                    bne       L3869
L386F               puls      pc,y,d
L3871               addd      $01F9,y
                    bcs       L3898
                    cmpd      $01FB,y
                    bcc       L3898
                    pshs      d
                    ldx       $01F9,y
                    clra
                    bra       L3889

L3887               sta       ,x+
L3889               cmpx      ,s
                    bcs       L3887
                    ldd       $01F9,y
                    puls      x
                    stx       $01F9,y
                    rts

L3898               ldd       #$FFFF
                    rts

L389C               tfr       b,a
                    ldb       $03,s
                    os9       F$Send
                    lbra      L3944

L38A6               tfr       d,x
                    clra
                    clrb
                    os9       F$Wait
                    lbcs      L393B
                    stx       -$02,s
                    beq       L38B9
                    stb       $01,x
                    clr       ,x
L38B9               tfr       a,b
                    clra
                    rts
                    tfr       b,a
                    ldb       $03,s
                    os9       F$SPrior
                    lbra      L3944
                    leau      $02,s
                    leas      $00FF,y
                    tfr       d,x
                    ldy       ,u
                    lda       $05,u
                    asla
                    asla
                    asla
                    asla
                    ora       $07,u
                    ldb       $09,u
                    ldu       $02,u
                    os9       F$Chain
                    os9       F$Exit
L38E4               pshs      u,y
                    tfr       d,x
                    ldy       $06,s
                    ldu       $08,s
                    lda       $0b,s
                    ora       $0d,s
                    ldb       $0f,s
                    os9       F$Fork
                    puls      u,y
                    lbcs      L393B
                    tfr       a,b
                    clra
                    rts

L3900               pshs      u
                    tfr       y,u
                    std       $16F5,y
                    leax      >L3914,pcr
                    os9       F$Icpt
                    puls      u
                    lbra      L3944

L3914               tfr       u,y
                    clra
                    jsr       [$16F5,y]
                    rti

L391C               tfr       b,a
                    ldb       #$00
                    ldx       $02,s
                    os9       I$GetStt
                    lbra      L3944

L3928               tfr       b,a
                    ldb       #$0f
                    ldx       $02,s
                    pshs      y
                    ldy       $06,s
                    os9       I$GetStt
                    puls      y
                    lbra      L3944

L393B               clra
                    std       $01FD,y
                    ldd       #$FFFF
                    rts

L3944               bcs       L393B
                    clra
                    clrb
                    rts

L3949               pshs      d
                    lbsr      L3956
                    lbsr      L3037
                    puls      d
L3953               os9       F$Exit
L3956               rts

L3957               ldd       $04,s
                    addd      $02,x
                    std       $01F3,y
                    ldd       $02,s
                    adcb      $01,x
                    adca      ,x
                    std       $01F1,y
                    lbra      L39FB

L396C               ldd       $04,s
                    subd      $02,x
                    std       $01F3,y
                    ldd       $02,s
                    sbcb      $01,x
                    sbca      ,x
                    std       $01F1,y
                    lbra      L39FB

L3981               ldd       $02,s
                    cmpd      ,x
                    bne       L399A
                    ldd       $04,s
                    cmpd      $02,x
                    beq       L399A
                    bcs       L3997
                    lda       #$01
                    andcc     #$FE
                    bra       L399A

L3997               clra
                    cmpa      #$01
L399A               pshs      cc
                    ldd       $01,s
                    std       $05,s
                    puls      cc
                    leas      $04,s
                    rts

L39A5               lbsr      L3A0A
                    ldd       #$0000
                    subd      $02,x
                    std       $02,x
                    ldd       #$0000
                    sbcb      $01,x
                    sbca      ,x
                    std       ,x
                    rts
                    ldd       ,x
                    coma
                    comb
                    std       $01F1,y
                    ldd       $02,x
                    coma
                    comb
                    leax      $01F1,y
                    std       $02,x
                    rts

L39CC               leax      $01F1,y
                    std       $02,x
                    tfr       a,b
                    sex
                    tfr       a,b
                    std       ,x
                    rts
                    leax      $01F1,y
                    std       $02,x
                    clr       ,x
                    clr       $01,x
                    rts

L39E5               pshs      y
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

L39FB               tfr       cc,a
                    puls      x
                    stx       $02,s
                    leas      $02,s
                    leax      $01F1,y
                    tfr       a,cc
                    rts

L3A0A               ldd       ,x
                    std       $01F1,y
                    ldd       $02,x
                    leax      $01F1,y
                    std       $02,x
                    rts

L3A19               tsta
                    bne       L3A2E
                    tst       $02,s
                    bne       L3A2E
                    lda       $03,s
                    mul
                    ldx       ,s
                    stx       $02,s
                    ldx       #$0000
                    std       ,s
                    puls      pc,d
L3A2E               pshs      d
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
                    bcc       L3A4B
                    inc       ,s
L3A4B               lda       $04,s
                    ldb       $09,s
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L3A58
                    inc       ,s
L3A58               lda       $04,s
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
                    tstb
                    beq       L3A82
L3A6F               asr       $02,s
                    ror       $03,s
                    decb
                    bne       L3A6F
                    bra       L3A82

L3A78               tstb
                    beq       L3A82
L3A7B               lsr       $02,s
                    ror       $03,s
                    decb
                    bne       L3A7B
L3A82               ldd       $02,s
                    pshs      d
                    ldd       $02,s
                    std       $04,s
                    ldd       ,s
                    leas      $04,s
                    rts

L3A8F               tstb
                    beq       L3A82
L3A92               asl       $03,s
                    rol       $02,s
                    decb
                    bne       L3A92
                    bra       L3A82
* ------------------------------------------------------------------
* L3A9B - cc1-style init image for the work block (see _start):
* rts stub + count/block table + relocation dirs + module-name string.
* ------------------------------------------------------------------
L3A9B               fcb       $00,$09,$00,$00
                    fcb       $43
                    fcb       $06,$D3,$00
                    fcb       $25
                    fcb       $00
                    fcb       $27
                    fcb       $01,$C4,$09,$C4,$09,$F3,$0A
                    fcb       $2C
                    fcb       $0A
                    fcb       $58
                    fcb       $0A
                    fcb       $62
                    fcb       $0A,$8A,$0A,$CA,$0B,$08,$0B
                    fcb       $40
                    fcb       $0B
                    fcb       $7B
                    fcb       $0B,$BD,$0B,$FC,$0C
                    fcc       /2                    /
                    fcb       $00
                    fcb       $20
                    fcb       $00
                    fcc       /don't know how to mak/
                    fcc       /e /
                    fcb       $22
                    fcc       /%s/
                    fcb       $22,$2E
                    fcb       $0D,$00
                    fcc       /                    /
                    fcb       $00
                    fcb       $27
                    fcb       $10,$03,$E8,$00
                    fcb       $64
                    fcb       $00,$0A,$00,$95
                    fcc       /lx/
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $42
                    fcb       $00,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$11,$11,$01,$11,$11,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
                    fcc       /0               HHHHH/
                    fcc       /HHHHH       BBBBBB/
                    fcb       $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
                    fcc       /      DDDDDD/
                    fcb       $04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04
                    fcc       /    /
                    fcb       $01,$00,$00,$00,$0D,$00
                    fcb       $33
                    fcb       $00
                    fcb       $31
                    fcb       $00
                    fcb       $2F
                    fcb       $00
                    fcb       $2D
                    fcb       $00
                    fcb       $2B
                    fcb       $00
                    fcb       $29
                    fcb       $00
                    fcb       $41
                    fcb       $00
                    fcb       $3F
                    fcb       $00
                    fcb       $3D
                    fcb       $00
                    fcb       $3B
                    fcb       $00
                    fcb       $39
                    fcb       $00
                    fcb       $37
                    fcb       $00
                    fcb       $35
                    fcb       $00,$05,$00,$01,$00,$03,$00,$05,$00,$07,$00,$95
                    fcc       /make/
                    fcb       $00

                    emod
eom                 equ       *
                    end
