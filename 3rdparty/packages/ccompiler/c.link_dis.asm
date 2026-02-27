                    nam       c.link
                    ttl       program module

                    use       defsfile

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       $04

                    mod       eom,name,tylg,atrv,start,size

u0000               rmb       5646
size                equ       .

name                equ       *
                    fcs       /c.link/
                    fcb       edition

L0014               lda       ,y+
L0016               sta       ,u+
L0018               leax      -$01,x
L001A               bne       L0014
L001C               rts

start               pshs      y
                    pshs      u
                    clra
L0022               clrb
L0023               sta       ,u+
L0025               decb
L0026               bne       L0023
L0028               ldx       ,s
L002A               leau      ,x
L002C               leax      $068e,x
L0030               pshs      x
L0032               leay      $3577,pcr
L0036               ldx       ,y++
L0038               beq       L003E
L003A               bsr       L0014
L003C               ldu       $02,s
L003E               leau      >$0060,u
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
                    beq       L005F
L0058               leax      >$0000,pcr
L005C               lbsr      L0162
L005F               ldd       ,y++
L0061               beq       L0068
L0063               leax      ,u
L0065               lbsr      L0162
L0068               leas      $04,s
                    puls      x
L006C               stx       $021a,u
L0070               sty       $01DA,u
L0075               ldd       #$0001
L0078               std       $0216,u
                    leay      $01DC,u
L0080               leax      ,s
                    lda       ,x+
L0084               ldb       $0217,u
                    cmpb      #$1d
                    beq       L00E0
L008C               cmpa      #$0d
                    beq       L00E0
                    cmpa      #$20
                    beq       L0098
                    cmpa      #$2C
                    bne       L009C
L0098               lda       ,x+
                    bra       L008C

L009C               cmpa      #$22
                    beq       L00A4
                    cmpa      #$27
                    bne       L00C2
L00A4               stx       ,y++
                    inc       $0217,u
                    pshs      a
L00AC               lda       ,x+
                    cmpa      #$0d
                    beq       L00B6
                    cmpa      ,s
                    bne       L00AC
L00B6               puls      b
                    clr       -$01,x
                    cmpa      #$0d
                    beq       L00E0
                    lda       ,x+
                    bra       L0084

L00C2               leax      -$01,x
                    stx       ,y++
                    leax      $01,x
L00C8               inc       $0217,u
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

L00E0               leax      $01DA,u
                    pshs      x
                    ldd       $0216,u
                    pshs      d
                    leay      ,u
                    bsr       L00FA
                    lbsr      L017C
                    clr       ,-s
                    clr       ,-s
                    lbsr      L356B
L00FA               leax      $068e,y
                    stx       $0224,y
L0102               sts       $0218,y
                    sts       $0226,y
                    ldd       #$FF82
                    leax      d,s
L0111               cmpx      $0226,y
                    bcc       L0121
                    cmpx      $0224,y
                    bcs       L013B
                    stx       $0226,y
L0121               rts
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
                    lbsr      L3571
                    ldd       $0218,y
                    subd      $0226,y
                    rts
                    ldd       $0226,y
                    subd      $0224,y
                    rts

L0162               pshs      x
                    leax      d,y
                    leax      d,x
                    anda      $0034
                    fcb       $10
L016B               ldd       ,y++
                    leax      d,u
                    ldd       ,x
                    addd      $02,s
L0173               std       ,x
                    cmpy      ,s
                    bne       L016B
L017A               leas      $04,s
L017C               rts
                    pshs      u
                    ldd       #$FFB0
                    lbsr      $0110
                    leas      -$06,s
                    leax      L1E00,pcr
                    pshs      x
                    lbsr      $353C
                    leas      $02,s
                    lbra      L033D

L0195               ldx       $0C,s
                    leax      $02,x
                    stx       $0C,s
                    ldu       ,x
                    ldb       ,u
                    cmpb      #$2d
                    lbne      L0313
                    lbra      L0305

L01A8               ldb       ,u
                    sex
                    tfr       d,x
                    lbra      L02BF

L01B0               leau      $01,u
                    ldb       ,u
                    cmpb      #$3d
                    bne       L01C0
                    leau      $01,u
                    tfr       u,d
                    std       $0273,y
L01C0               ldd       $0271,y
                    lbne      L02A1
                    pshs      u
                    lbsr      L0D9E
                    leas      $02,s
                    std       $0271,y
                    lbra      L02A1

L01D6               leau      $01,u
                    ldb       ,u
                    cmpb      #$3d
                    bne       L0206
                    ldd       $000C
                    cmpd      #$0005
                    bge       L0206
                    ldd       $000C
                    addd      #$0001
                    std       $000C
                    subd      #$0001
                    aslb
                    rola
                    leax      $0266,y
                    leax      d,x
                    pshs      x
                    pshs      u
                    ldd       #$0001
                    addd      ,s++
                    std       [,s++]
                    lbra      L02A1

L0206               pshs      u
                    leax      $0DDE,pcr
                    pshs      x
                    lbsr      $1AB6
                    leas      $04,s
                    lbra      L02A1

L0216               ldd       #$0001
                    std       $000E
                    lbra      L0305

L021E               ldd       #$0001
                    std       $0010
                    lbra      L0305

L0226               leau      $01,u
                    ldb       ,u
                    cmpb      #$3d
                    lbne      L02A1
                    leax      $01,u
                    stx       $0271,y
                    lbra      L02A1

L0239               leau      $01,u
                    ldb       ,u
                    cmpb      #$3d
                    lbne      L02A1
                    pshs      u
                    ldd       #$0001
                    addd      ,s++
                    pshs      d
                    lbsr      L302D
                    leas      $02,s
                    stb       $0270,y
                    bra       L02A1

L0257               leau      $01,u
                    ldb       ,u
                    cmpb      #$3d
                    bne       L027B
                    pshs      u
                    ldd       #$0001
                    addd      ,s++
                    pshs      d
                    lbsr      $1B06
                    leas      $02,s
                    std       ,s
                    cmpd      #$0100
                    bcs       L02A1
                    ldd       ,s
                    std       L0032
                    bra       L02A1

L027B               pshs      u
                    leax      L0E18,pcr
                    pshs      x
                    leax      L0DFE,pcr
                    pshs      x
                    lbsr      $1AB6
                    leas      $06,s
L028E               ldd       #$0001
                    std       L0014
                    leau      $01,u
                    ldb       ,u
                    cmpb      #$3d
                    bne       L02A1
                    leax      $01,u
                    stx       $0275,y
L02A1               leax      $06,s
                    lbra      L030F

L02A6               ldd       #$0001
                    std       L0016
                    bra       L0305

L02AD               ldb       ,u
                    sex
                    pshs      d
                    leax      $0E25,pcr
                    pshs      x
                    lbsr      $1AB6
                    leas      $04,s
                    bra       L0305

L02BF               cmpx      #$006F
                    lbeq      L01B0
                    cmpx      #$006C
                    lbeq      L01D6
                    cmpx      #$006D
                    lbeq      L0216
                    cmpx      #$0073
                    lbeq      L021E
                    cmpx      #$006E
                    lbeq      L0226
                    cmpx      #$0045
                    lbeq      L0239
                    cmpx      #$0065
                    lbeq      L0239
                    cmpx      #$004D
                    lbeq      L0257
                    cmpx      #$0062
                    lbeq      L028E
                    cmpx      #$0074
                    beq       L02A6
                    bra       L02AD

L0305               leau      $01,u
                    ldb       ,u
                    lbne      L01A8
                    bra       L033D

L030F               leas      -$06,x
                    bra       L033D

L0313               ldd       $000A
                    cmpd      #$001E
                    bne       L0326
                    leax      L0E38,pcr
                    pshs      x
                    lbsr      $1AB6
                    leas      $02,s
L0326               ldd       $000A
                    addd      #$0001
                    std       $000A
                    subd      #$0001
                    aslb
                    rola
                    leax      $022a,y
                    leax      d,x
                    ldd       [$0C,s]
                    std       ,x
L033D               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    lbgt      L0195
                    lbsr      L044B
                    lbsr      L1D81
                    std       -$02,s
                    beq       L035D
                    leax      $0E4E,pcr
                    pshs      x
                    lbsr      $1AB6
                    leas      $02,s
L035D               ldd       $0271,y
                    pshs      d
                    lbsr      $2EC5
                    leas      $02,s
                    std       L001A
                    lbsr      L0928
                    lbsr      L0A67
                    ldd       L0014
                    beq       L03A9
                    ldd       L0026
                    bne       L037C
                    ldd       L002A
                    beq       L0387
L037C               leax      $0E64,pcr
                    pshs      x
                    lbsr      L0CE6
                    leas      $02,s
L0387               ldd       L0022
                    beq       L0396
                    leax      L0E79,pcr
                    pshs      x
                    lbsr      L0CE6
                    leas      $02,s
L0396               ldd       L0016
                    bne       L03A9
                    ldd       $001E
                    beq       L03A9
                    leax      L0E8C,pcr
                    pshs      x
                    lbsr      L0CE6
                    leas      $02,s
L03A9               ldd       L0022
                    addd      L002A
                    cmpd      #$0100
                    bls       L03C4
                    ldd       L0022
                    addd      L002A
                    pshs      d
                    leax      L0E9B,pcr
                    pshs      x
                    lbsr      $1AB6
                    leas      $04,s
L03C4               ldd       L0044
                    beq       L03D3
                    leax      $0EBE,pcr
                    pshs      x
                    lbsr      $1AB6
                    leas      $02,s
L03D3               ldd       $0273,y
                    bne       L03E4
                    leax      L0EC9,pcr
                    pshs      x
                    lbsr      $1AB6
                    leas      $02,s
L03E4               ldd       L0014
                    lbeq      L0444
                    ldd       $0275,y
                    bne       L03FB
                    leax      $0ED8,pcr
                    pshs      x
                    lbsr      L0CE6
                    bra       L043D

L03FB               leas      -$02,s
                    ldd       $0275,y
                    pshs      d
                    ldd       $0275,y
                    pshs      d
                    lbsr      $19F8
                    std       ,s
                    lbsr      $1A1D
                    leas      $04,s
                    std       ,s
                    beq       L042C
                    ldx       ,s
                    ldd       $0a,x
                    clra
                    andb      #$07
                    cmpd      #$0004
                    bne       L042C
                    ldx       ,s
                    ldd       $0C,x
                    std       L0030
                    bra       L043D

L042C               ldd       $0275,y
                    pshs      d
                    leax      $0EEC,pcr
                    pshs      x
                    lbsr      L0CE6
                    leas      $04,s
L043D               leas      $02,s
                    ldd       #$2181
                    std       L0018
L0444               lbsr      $1016
                    leas      $06,s
                    puls      pc,u
L044B               pshs      u
                    ldd       #$FF96
                    lbsr      $0110
                    leas      -$1e,s
                    ldd       $000A
                    lbeq      L065B
                    clra
                    clrb
                    lbra      L0595

L0461               ldd       ,s
                    aslb
                    rola
                    leax      $022a,y
                    leax      d,x
                    ldd       ,x
                    std       L0042
                    ldd       L0038
                    pshs      d
                    leax      $0F07,pcr
                    pshs      x
                    ldd       L0042
                    pshs      d
                    lbsr      L22B9
                    leas      $06,s
                    std       L0038
                    bne       L0489
                    lbsr      L0D2E
L0489               ldd       $0003
                    ldx       L0038
                    std       $0b,x
                    ldd       L0038
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    ldd       #$001C
                    pshs      d
                    leax      $08,s
                    pshs      x
                    lbsr      L232E
                    leas      $08,s
                    std       -$02,s
                    bne       L04AD
                    lbsr      L0D85
L04AD               leax      $02,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    bsr       L04BD
                    fcb       $62
                    fcb       $CD
                    bls       L0444
L04BD               puls      x
                    lbsr      $30E8
                    beq       L04C9
                    lbsr      L0D41
                    bra       L0511

L04C9               ldb       $08,s
                    beq       L04D2
                    lbsr      L0D53
                    bra       L0511

L04D2               ldd       L0014
                    beq       L04DF
                    ldd       $06,s
                    beq       L0511
                    lbsr      L0D1C
                    bra       L0511

L04DF               ldd       ,s
                    beq       L04EC
                    ldd       $06,s
                    beq       L0511
                    lbsr      L0D65
                    bra       L0511

L04EC               ldd       $06,s
                    bne       L0501
                    ldd       L0042
                    pshs      d
                    leax      $0F09,pcr
                    pshs      x
                    lbsr      $1AB6
                    leas      $04,s
                    bra       L0505

L0501               ldd       $06,s
                    std       L0018
L0505               ldb       $0270,y
                    bne       L0511
                    ldb       $0e,s
                    stb       $0270,y
L0511               clra
                    clrb
                    pshs      d
                    leax      $04,s
                    pshs      x
                    lbsr      L0660
                    leas      $04,s
                    ldd       ,s
                    lbne      L0590
                    leas      -$02,s
                    ldd       L003E
                    std       ,s
                    ldd       #$0104
                    pshs      d
                    ldd       >$0070,y
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    lbsr      L0B8C
                    leas      $06,s
                    ldd       #$0104
                    pshs      d
                    ldd       >$0078,y
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    lbsr      L0B8C
                    leas      $06,s
                    ldd       #$0101
                    pshs      d
                    ldd       >$0072,y
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    lbsr      L0B8C
                    leas      $06,s
                    ldd       #$0100
                    pshs      d
                    ldd       >$0074,y
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    lbsr      L0B8C
                    leas      $06,s
                    ldd       #$0102
                    pshs      d
                    ldd       >$0076,y
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    lbsr      L0B8C
                    leas      $06,s
                    leas      $02,s
L0590               ldd       ,s
                    addd      #$0001
L0595               std       ,s
                    ldd       ,s
                    cmpd      $000A
                    lblt      L0461
                    clra
                    clrb
                    lbra      L064B

L05A5               ldd       ,s
                    aslb
                    rola
                    leax      $0266,y
                    leax      d,x
                    ldd       ,x
                    std       L0042
                    ldd       L0038
                    pshs      d
                    lbsr      L2B74
                    leas      $02,s
                    leax      $0F23,pcr
                    pshs      x
                    ldd       L0042
                    pshs      d
                    lbsr      $229A
                    leas      $04,s
                    std       L0038
                    lbne      L0629
                    lbsr      L0D2E
                    bra       L0629

L05D6               leax      $02,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    bsr       L05E6
                    fcb       $62
                    fcb       $CD
                    bls       $056D
L05E6               puls      x
                    lbsr      $30E8
                    beq       L05F2
                    lbsr      L0D41
                    bra       L061A

L05F2               ldb       $08,s
                    beq       L05FB
                    lbsr      L0D53
                    bra       L061A

L05FB               ldd       $06,s
                    beq       L060D
                    ldd       L0014
                    beq       L0608
                    lbsr      L0D1C
                    bra       L061A

L0608               lbsr      L0D65
                    bra       L061A

L060D               ldd       #$0001
                    pshs      d
                    leax      $04,s
                    pshs      x
                    bsr       L0660
                    leas      $04,s
L061A               leax      >$0060,y
                    cmpx      >$0060,y
                    bne       L0629
                    leax      $1e,s
                    bra       L0658

L0629               ldd       L0038
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    ldd       #$001C
                    pshs      d
                    leax      $08,s
                    pshs      x
                    lbsr      L232E
                    leas      $08,s
                    std       -$02,s
                    lbne      L05D6
                    ldd       ,s
                    addd      #$0001
L064B               std       ,s
                    ldd       ,s
                    cmpd      $000C
                    lblt      L05A5
                    bra       L065B

L0658               leas      -$1e,x
L065B               leas      $1e,s
                    puls      pc,u
L0660               pshs      u
                    ldd       #$FF8B
                    lbsr      $0110
                    leas      -$29,s
                    ldd       L003C
                    bne       L067E
                    ldd       #$0031
                    pshs      d
                    lbsr      $1C20
                    leas      $02,s
                    std       $27,s
                    bra       L068B

L067E               ldd       L003C
                    std       $27,s
                    ldx       $27,s
                    ldd       $11,x
                    std       L003C
L068B               clra
                    clrb
                    ldx       $27,s
                    std       $2d,x
                    clra
                    clrb
                    ldx       $27,s
                    std       $27,x
                    ldd       $27,s
                    std       $1b,s
                    ldd       #$0010
                    bra       L06B9

L06A6               ldd       $23,s
                    ldx       $1b,s
                    leax      $01,x
                    stx       $1b,s
                    stb       -$01,x
                    ldd       $21,s
                    addd      #$FFFF
L06B9               std       $21,s
                    ldd       $21,s
                    ble       L06CF
                    ldd       L0038
                    pshs      d
                    lbsr      L2C97
                    leas      $02,s
                    std       $23,s
                    bne       L06A6
L06CF               ldx       L0038
                    ldd       $06,x
                    clra
                    andb      #$20
                    beq       L06DB
                    lbsr      L0D85
L06DB               clra
                    clrb
                    stb       [$1b,s]
                    ldd       L0042
                    ldx       $27,s
                    std       $2f,x
                    ldd       #$0010
                    pshs      d
                    ldd       $2f,s
                    addd      #$000C
                    pshs      d
                    ldd       $2b,s
                    addd      #$0015
                    pshs      d
                    lbsr      L30A0
                    leas      $06,s
                    ldd       L0038
                    pshs      d
                    lbsr      L2CF9
                    leas      $02,s
                    std       $1f,s
                    bra       L0750

L0710               lbsr      L0BCD
                    std       $25,s
                    ldx       $27,s
                    ldd       $2d,x
                    ldx       $25,s
                    std       $0e,x
                    ldd       $25,s
                    ldx       $27,s
                    std       $2d,x
                    ldd       $25,s
                    pshs      d
                    lbsr      L1DE1
                    leas      $02,s
                    ldd       L0038
                    pshs      d
                    lbsr      L2C97
                    leas      $02,s
                    ldx       $25,s
                    std       $0a,x
                    ldd       L0038
                    pshs      d
                    lbsr      L2CF9
                    leas      $02,s
                    ldx       $25,s
                    std       $0C,x
L0750               ldd       $1f,s
                    addd      #$FFFF
                    std       $1f,s
                    subd      #$FFFF
                    bne       L0710
                    ldd       $2f,s
                    lbeq      L07DD
                    ldx       $27,s
                    ldd       $2d,x
                    bra       L0785

L076D               ldd       #$0001
                    pshs      d
                    ldd       $27,s
                    pshs      d
                    lbsr      $1B83
                    leas      $04,s
                    std       -$02,s
                    bne       L078D
                    ldx       $25,s
                    ldd       $0e,x
L0785               std       $25,s
                    ldd       $25,s
                    bne       L076D
L078D               ldd       $25,s
                    bne       L07DD
                    leas      -$02,s
                    ldx       $29,s
                    ldd       $2d,x
                    pshs      d
                    lbsr      L0CC8
                    leas      $02,s
                    std       ,s
                    ldd       $0001
                    ldx       ,s
                    std       $0e,x
                    ldx       $29,s
                    ldd       $0e,x
                    std       $0001
                    ldd       $29,s
                    pshs      d
                    lbsr      L0BF1
                    leas      $02,s
                    lbsr      L0C3C
                    ldd       L0038
                    pshs      d
                    lbsr      L2CF9
                    std       ,s
                    lbsr      L0C0F
                    leas      $02,s
                    ldd       L003C
                    ldx       $29,s
                    std       $11,x
                    ldd       $29,s
                    std       L003C
                    leas      $2b,s
                    puls      pc,u
L07DD               ldx       $27,s
                    ldd       $2d,x
                    bra       L0818

L07E5               ldd       $25,s
                    pshs      d
                    lbsr      $1A57
                    std       ,s++
                    beq       L0813
                    ldd       $27,s
                    pshs      d
                    ldd       $27,s
                    pshs      d
                    leax      $0F25,pcr
                    pshs      x
                    leax      $00A3,y
                    pshs      x
                    lbsr      L23D0
                    leas      $08,s
                    ldd       L0044
                    addd      #$0001
                    std       L0044
L0813               ldx       $25,s
                    ldd       $0e,x
L0818               std       $25,s
                    ldd       $25,s
                    bne       L07E5
                    ldd       $0040
                    bne       L082D
                    ldd       $27,s
                    std       $0040
                    std       L003E
                    bra       L0837

L082D               ldd       $27,s
                    ldx       $0040
                    std       $11,x
                    std       $0040
L0837               ldx       $27,s
                    leax      $29,x
                    pshs      x
                    ldd       L0038
                    pshs      d
                    lbsr      L2A1B
                    leas      $02,s
                    lbsr      $314C
                    ldd       $27,s
                    pshs      d
                    lbsr      L0BF1
                    leas      $02,s
                    ldd       L0038
                    pshs      d
                    lbsr      L2CF9
                    leas      $02,s
                    std       $1f,s
                    lbra      L08D2

L0864               leax      $01,s
                    pshs      x
                    lbsr      L1DE1
                    leas      $02,s
                    leax      $01,s
                    pshs      x
                    leax      $03,s
                    pshs      x
                    lbsr      $19F8
                    std       ,s
                    lbsr      $1A1D
                    leas      $04,s
                    std       $25,s
                    beq       L088F
                    ldx       $25,s
                    ldd       $0a,x
                    ora       #$01
                    std       $0a,x
                    bra       L08B5

L088F               leas      -$02,s
                    leax      $03,s
                    pshs      x
                    lbsr      $1BD9
                    leas      $02,s
                    std       ,s
                    leax      $03,s
                    pshs      x
                    ldd       $02,s
                    addd      #$0004
                    pshs      d
                    lbsr      L2ED6
                    leas      $04,s
                    ldd       $29,s
                    ldx       ,s
                    std       $0e,x
                    leas      $02,s
L08B5               ldx       $27,s
                    ldd       $27,x
                    leax      $27,x
                    pshs      x,d
                    ldd       L0038
                    pshs      d
                    lbsr      L2CF9
                    std       ,s
                    lbsr      L0C7A
                    leas      $02,s
                    addd      ,s++
                    std       [,s++]
L08D2               ldd       $1f,s
                    addd      #$FFFF
                    std       $1f,s
                    subd      #$FFFF
                    lbne      L0864
                    ldd       L0038
                    pshs      d
                    lbsr      L2CF9
                    leas      $02,s
                    std       $1f,s
                    ldx       L0038
                    ldd       $06,x
                    clra
                    andb      #$20
                    beq       L0915
                    lbsr      L0D85
                    bra       L0915

L08FC               ldx       $27,s
                    ldd       $27,x
                    leax      $27,x
                    pshs      x,d
                    ldd       #$0001
                    pshs      d
                    lbsr      L0C7A
                    leas      $02,s
                    addd      ,s++
                    std       [,s++]
L0915               ldd       $1f,s
                    addd      #$FFFF
                    std       $1f,s
                    subd      #$FFFF
                    bne       L08FC
                    leas      $29,s
                    puls      pc,u
L0928               pshs      u
                    ldd       #$FFB6
                    lbsr      $0110
                    leas      -$02,s
                    clra
                    clrb
                    std       $0034
                    ldd       L003E
                    lbra      L09DD

L093B               ldx       ,s
                    ldu       $2d,x
                    lbra      L09D2

L0943               ldd       $0a,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    lbeq      L09D0
                    ldx       ,s
                    ldd       $13,x
                    ora       #$01
                    std       $13,x
                    ldd       $001E
                    pshs      d
                    ldx       $02,s
                    ldd       $17,x
                    addd      ,s++
                    std       $001E
                    ldd       L0022
                    pshs      d
                    ldx       $02,s
                    ldd       $19,x
                    addd      ,s++
                    std       L0022
                    ldd       L0026
                    pshs      d
                    ldx       $02,s
                    ldd       $1b,x
                    addd      ,s++
                    std       L0026
                    ldd       L002A
                    pshs      d
                    ldx       $02,s
                    ldd       $1d,x
                    addd      ,s++
                    std       L002A
                    ldd       L0032
                    pshs      d
                    ldx       $02,s
                    ldd       $21,x
                    addd      ,s++
                    std       L0032
                    ldd       $002E
                    pshs      d
                    ldx       $02,s
                    ldd       $1f,x
                    addd      ,s++
                    std       $002E
                    ldd       L0036
                    pshs      d
                    ldx       $02,s
                    ldd       $27,x
                    addd      ,s++
                    std       L0036
                    ldx       ,s
                    ldd       $1f,x
                    ldx       ,s
                    addd      $1b,x
                    cmpd      $0034
                    bls       L09D8
                    ldx       ,s
                    ldd       $1f,x
                    ldx       ,s
                    addd      $1b,x
                    std       $0034
                    bra       L09D8

L09D0               ldu       $0e,u
L09D2               stu       -$02,s
                    lbne      L0943
L09D8               ldx       ,s
                    ldd       $11,x
L09DD               std       ,s
                    ldd       ,s
                    lbne      L093B
                    ldd       >$0070,y
                    pshs      d
                    ldd       >$0070,y
                    pshs      d
                    lbsr      $19F8
                    std       ,s
                    lbsr      $1A1D
                    leas      $04,s
                    tfr       d,u
                    stu       -$02,s
                    beq       L0A05
                    ldd       $002E
                    std       $0C,u
L0A05               ldd       >$0072,y
                    pshs      d
                    ldd       >$0072,y
                    pshs      d
                    lbsr      $19F8
                    std       ,s
                    lbsr      $1A1D
                    leas      $04,s
                    tfr       d,u
                    stu       -$02,s
                    beq       L0A25
                    ldd       L0026
                    std       $0C,u
L0A25               ldd       >$0074,y
                    pshs      d
                    ldd       >$0074,y
                    pshs      d
                    lbsr      $19F8
                    std       ,s
                    lbsr      $1A1D
                    leas      $04,s
                    tfr       d,u
                    stu       -$02,s
                    beq       L0A45
                    ldd       $001E
                    std       $0C,u
L0A45               ldd       >$0076,y
                    pshs      d
                    ldd       >$0076,y
                    pshs      d
                    lbsr      $19F8
                    std       ,s
                    lbsr      $1A1D
                    leas      $04,s
                    tfr       d,u
                    stu       -$02,s
                    beq       L0A65
                    ldd       L0022
                    std       $0C,u
L0A65               puls      pc,u,x
L0A67               pshs      u
                    ldd       #$FFB1
                    lbsr      $0110
                    leas      -$05,s
                    lbsr      L0B65
                    ldd       L003E
                    lbra      L0B38

L0A79               ldx       $03,s
                    ldd       $13,x
                    anda      #$01
                    clrb
                    std       -$02,s
                    lbeq      L0B33
                    ldx       $03,s
                    ldu       $2d,x
                    lbra      L0AEC

L0A8F               ldd       $0a,u
                    clra
                    andb      #$07
                    tfr       d,x
                    bra       L0AD0

L0A98               ldd       $0C,u
                    addd      L001C
                    bra       L0AB4

L0A9E               ldd       $0C,u
                    addd      $0024
                    bra       L0AB4

L0AA4               ldd       $0C,u
                    addd      $0020
                    bra       L0AB4

L0AAA               ldd       $0C,u
                    addd      L0028
                    bra       L0AB4

L0AB0               ldd       $0C,u
                    addd      L002C
L0AB4               std       $0C,u
                    bra       L0AEA

L0AB8               ldx       $03,s
                    ldd       $2f,x
                    pshs      d
                    ldd       $05,s
                    pshs      d
                    leax      L0F49,pcr
                    pshs      x
                    lbsr      $1AB6
                    leas      $06,s
                    bra       L0AEA

L0AD0               stx       -$02,s
                    beq       L0A98
                    cmpx      #$0001
                    beq       L0A9E
                    cmpx      #$0002
                    beq       L0AA4
                    cmpx      #$0003
                    beq       L0AAA
                    cmpx      #$0004
                    beq       L0AB0
                    bra       L0AB8

L0AEA               ldu       $0e,u
L0AEC               stu       -$02,s
                    lbne      L0A8F
                    ldd       L001C
                    pshs      d
                    ldx       $05,s
                    ldd       $17,x
                    addd      ,s++
                    std       L001C
                    ldd       $0024
                    pshs      d
                    ldx       $05,s
                    ldd       $1b,x
                    addd      ,s++
                    std       $0024
                    ldd       $0020
                    pshs      d
                    ldx       $05,s
                    ldd       $19,x
                    addd      ,s++
                    std       $0020
                    ldd       L0028
                    pshs      d
                    ldx       $05,s
                    ldd       $1d,x
                    addd      ,s++
                    std       L0028
                    ldd       L002C
                    pshs      d
                    ldx       $05,s
                    ldd       $1f,x
                    addd      ,s++
                    std       L002C
L0B33               ldx       $03,s
                    ldd       $11,x
L0B38               std       $03,s
                    ldd       $03,s
                    lbne      L0A79
                    ldd       >$0078,y
                    pshs      d
                    ldd       >$0078,y
                    pshs      d
                    lbsr      $19F8
                    std       ,s
                    lbsr      $1A1D
                    leas      $04,s
                    tfr       d,u
                    stu       -$02,s
                    beq       L0B60
                    clra
                    clrb
                    std       $0C,u
L0B60               bsr       L0B65
                    lbra      L0CC4

L0B65               pshs      u
                    ldd       #$FFC0
                    lbsr      $0110
                    clra
                    clrb
                    std       L0028
                    ldd       L0028
                    addd      L002A
                    std       $0020
                    ldd       $0020
                    addd      L0022
                    std       $0024
                    ldd       $0024
                    addd      L0026
                    std       L001C
                    ldd       L001A
                    addd      #$000E
                    std       L002C
                    puls      pc,u
L0B8C               pshs      u
                    ldd       #$FFB4
                    lbsr      $0110
                    leas      -$02,s
                    bsr       L0BCD
                    std       ,s
                    ldx       $06,s
                    ldd       $2d,x
                    ldx       ,s
                    std       $0e,x
                    ldd       ,s
                    ldx       $06,s
                    std       $2d,x
                    ldd       #$0009
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    lbsr      L2F4C
                    leas      $06,s
                    ldd       $0a,s
                    ldx       ,s
                    std       $0a,x
                    ldd       ,s
                    pshs      d
                    lbsr      $1A57
                    leas      $02,s
                    puls      pc,u,x
L0BCD               pshs      u
                    ldd       #$FFBA
                    lbsr      $0110
                    ldd       $0001
                    bne       L0BE7
                    ldd       #$0012
                    pshs      d
                    lbsr      $1C20
                    leas      $02,s
                    tfr       d,u
                    bra       L0BED

L0BE7               ldu       $0001
                    ldd       $0e,u
                    std       $0001
L0BED               tfr       u,d
                    puls      pc,u
L0BF1               pshs      u
                    ldd       #$FFB4
                    lbsr      $0110
                    ldd       #$0001
                    pshs      d
                    ldx       $06,s
                    ldd       $1f,x
                    ldx       $06,s
                    addd      $1d,x
                    ldx       $06,s
                    addd      $1b,x
                    bra       L0C26

L0C0F               pshs      u
                    ldd       #$FFB4
                    lbsr      $0110
                    ldd       #$0001
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    ldd       #$0003
                    lbsr      $3180
L0C26               lbsr      $3141
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       L0038
                    pshs      d
                    lbsr      $28C4
                    leas      $08,s
                    puls      pc,u
L0C3C               pshs      u
                    ldd       #$FFAE
                    lbsr      $0110
                    leas      -$0C,s
                    ldd       L0038
                    pshs      d
                    lbsr      L2CF9
                    leas      $02,s
                    std       ,s
                    bra       L0C6A

L0C53               leax      $02,s
                    pshs      x
                    lbsr      L1DE1
                    leas      $02,s
                    ldd       L0038
                    pshs      d
                    lbsr      L2CF9
                    std       ,s
                    lbsr      L0C0F
                    leas      $02,s
L0C6A               ldd       ,s
                    addd      #$FFFF
                    std       ,s
                    subd      #$FFFF
                    bne       L0C53
                    leas      $0C,s
                    puls      pc,u
L0C7A               pshs      u
                    ldd       #$FFAF
                    lbsr      $0110
                    ldu       $04,s
                    leas      -$05,s
                    clra
                    clrb
                    bra       L0CB8

L0C8A               ldd       L0038
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    ldd       #$0003
                    pshs      d
                    leax      $06,s
                    pshs      x
                    lbsr      L232E
                    leas      $08,s
                    std       -$02,s
                    bne       L0CA8
                    lbsr      L0D85
L0CA8               ldb       ,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    beq       L0CBA
                    ldd       $03,s
                    addd      #$0001
L0CB8               std       $03,s
L0CBA               tfr       u,d
                    leau      -$01,u
                    std       -$02,s
                    bne       L0C8A
                    ldd       $03,s
L0CC4               leas      $05,s
                    puls      pc,u
L0CC8               pshs      u
                    ldd       #$FFBE
                    lbsr      $0110
                    ldu       $04,s
                    leas      -$02,s
                    stu       ,s
                    stu       ,s
                    bra       L0CDE

L0CDA               stu       ,s
                    ldu       $0e,u
L0CDE               stu       -$02,s
                    bne       L0CDA
                    ldd       ,s
                    puls      pc,u,x
L0CE6               pshs      u
                    ldd       #$FFB6
                    lbsr      $0110
                    ldd       $06,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    leax      $00A3,y
                    pshs      x
                    lbsr      L23D0
                    leas      $06,s
                    leax      $00A3,y
                    pshs      x
                    ldd       #$000D
                    pshs      d
                    lbsr      L2A84
                    leas      $04,s
                    leax      $0F65,pcr
                    pshs      x
                    lbsr      $1AB6
                    puls      pc,u,x
L0D1C               pshs      u
                    ldd       #$FFBA
                    lbsr      $0110
                    leax      $0F76,pcr
                    pshs      x
                    bsr       L0CE6
                    puls      pc,u,x
L0D2E               pshs      u
                    ldd       #$FFB8
                    lbsr      $0110
                    ldd       L0042
                    pshs      d
                    leax      L0F8A,pcr
                    lbra      L0D95

L0D41               pshs      u
                    ldd       #$FFB8
                    lbsr      $0110
                    ldd       L0042
                    pshs      d
                    leax      L0F9A,pcr
                    bra       L0D95

L0D53               pshs      u
                    ldd       #$FFB8
                    lbsr      $0110
                    ldd       L0042
                    pshs      d
                    leax      $0FBB,pcr
                    bra       L0D95

L0D65               pshs      u
                    ldd       #$FFB6
                    lbsr      $0110
                    ldd       L0042
                    pshs      d
                    ldx       L003E
                    ldd       $2f,x
                    pshs      d
                    leax      $0FD9,pcr
                    pshs      x
                    lbsr      $1AB6
                    leas      $06,s
                    puls      pc,u
L0D85               pshs      u
                    ldd       #$FFB8
                    lbsr      $0110
                    ldd       L0042
                    pshs      d
                    leax      $0FFA,pcr
L0D95               pshs      x
                    lbsr      $1AB6
                    leas      $04,s
                    puls      pc,u
L0D9E               pshs      u
                    ldd       #$FFBE
                    lbsr      $0110
                    ldu       $04,s
                    leas      -$02,s
                    stu       ,s
                    bra       L0DBA

L0DAE               ldb       ,u
                    cmpb      #$2f
                    bne       L0DB8
                    leax      $01,u
                    stx       ,s
L0DB8               leau      $01,u
L0DBA               ldb       ,u
                    bne       L0DAE
                    ldd       ,s
                    puls      pc,u,x
                    fcb       $65
                    lsr       $6578
                    lsr       >L0065
                    lsr       $01,s
                    lsr       $6100
                    fcb       $65
                    jmp       $04,s
                    neg       $0064
                    neg       $7369
                    dec       >$0062
                    lsr       $6578
                    lsr       >L0065
                    fcb       $72,$72,$6f,$72,$20,$73,$70,$65
                    fcb       $63,$69,$66,$79,$69,$6e,$67,$20
                    fcb       $6C,$69,$62,$72,$61,$72,$79,$3a
                    fcb       $20,$2d,$6C,$25,$73,$0d,$00
L0DFE               fcb       $65,$72,$72,$6f,$72,$20,$73,$70
                    fcb       $65,$63,$69,$66,$79,$69,$6e,$67
                    fcb       $20,$25,$73,$20,$2d,$4d,$25,$73
                    fcb       $0d,$00
L0E18               tst       $05,s
                    tst       $0f,s
                    fcb       $72
                    rol       L2073
                    rol       -$06,s
                    fcb       $65
                    abx
                    neg       L0075
                    jmp       $0b,s
                    jmp       $0f,s
                    asr       $6E20
                    clr       -$10,s
                    lsr       $696F
                    jmp       0,y
                    blt       L0E5B
                    com       0,x
L0E38               lsr       $6F6F
                    bra       L0EAA
                    fcb       $61
                    jmp       -$07,s
                    bra       $0EB5
                    clr       -$0b,s
                    fcb       $72
                    com       $05,s
                    bra       $0EAF
                    rol       $0C,s
                    fcb       $65
                    com       >L0075
                    jmp       -$0e,s
                    fcb       $65
                    com       $6F6C
                    ror       $6564
                    bra       $0ECC
                    fcb       $65
L0E5B               ror       $05,s
                    fcb       $72
                    fcb       $65
                    jmp       $03,s
                    fcb       $65
                    com       >$006E
                    clr       0,y
                    rol       $0e,s
                    rol       -$0C,s
                    bra       L0ED1
                    fcb       $61
                    lsr       $6120
                    fcb       $61
                    inc       $0C,s
                    clr       -$09,s
                    fcb       $65
                    lsr       0,x
L0E79               jmp       $0f,s
                    bra       $0EE1
                    neg       $2064
                    fcb       $61
                    lsr       $6120
                    fcb       $61
                    inc       $0C,s
                    clr       -$09,s
                    fcb       $65
                    lsr       0,x
L0E8C               jmp       $0f,s
                    bra       $0F03
                    lsr       $6174
                    rol       $03,s
                    bra       L0EFB
                    fcb       $61
                    lsr       $6100
L0E9B               lsr       $09,s
                    fcb       $72
                    fcb       $65
                    com       -$0C,s
                    bra       L0F13
                    fcb       $61
                    asr       $05,s
                    bra       $0F09
                    inc       $0C,s
L0EAA               clr       $03,s
                    fcb       $61
                    lsr       $696F
                    jmp       0,y
                    rol       -$0d,s
                    bra       L0EDB
                    fcb       $75
                    bra       $0F1B
                    rol       $7465
                    com       >$006E
                    fcb       $61
                    tst       $05,s
                    bra       L0F27
                    inc       $01,s
                    com       $6800
L0EC9               jmp       $0f,s
                    bra       L0F3C
                    fcb       $75
                    lsr       $7075
L0ED1               lsr       L2066
                    rol       $0C,s
                    fcb       $65
                    neg       $006E
                    clr       0,y
L0EDB               fcb       $65
                    jmp       -$0C,s
                    fcb       $72
                    rol       $2070
                    clr       $09,s
                    jmp       -$0C,s
                    bra       $0F56
                    fcb       $61
                    tst       $05,s
                    neg       L0065
                    jmp       -$0C,s
                    fcb       $72
                    rol       $2070
                    clr       $09,s
                    jmp       -$0C,s
                    bra       L0F20
                    bcs       L0F6E
L0EFB               beq       $0F1D
                    jmp       $0f,s
                    lsr       L2066
                    clr       -$0b,s
                    jmp       $04,s
                    neg       $0072
                    neg       $0027
                    bcs       L0F7F
                    beq       L0F2E
                    com       $0f,s
                    jmp       -$0C,s
                    fcb       $61
L0F13               rol       $0e,s
                    com       L206E
                    clr       0,y
                    tst       $01,s
                    rol       $0e,s
                    inc       $09,s
L0F20               jmp       $05,s
                    neg       $0072
                    neg       $0073
                    fcb       $79
L0F27               fcb       $6d,$62,$6f,$6C,$20,$61,$6C
L0F2E               fcb       $72,$65,$61,$64,$79,$20,$64,$65
                    fcb       $66,$69,$6e,$65,$64,$3a
L0F3C               fcb       $20,$25,$2d,$38,$73,$20,$69,$6e
                    fcb       $20,$25,$73,$0d,$00
L0F49               fcb       $75
                    jmp       $0b,s
                    jmp       $0f,s
                    asr       $6E20
                    fcb       $65
                    jmp       -$0C,s
                    fcb       $72
                    rol       $2074
                    rol       $7065
                    bra       $0FC6
                    jmp       0,y
                    bcs       L0FD4
                    abx
                    bcs       L0FD7
                    neg       L0042
                    fcb       $41
                    comb
                    rola
                    coma
                    leax      -$07,y
                    bra       L0FD1

L0F6E               clr       $0e,s
                    ror       $0C,s
                    rol       $03,s
                    lsr       >$006E
                    clr       0,y
                    tst       $01,s
                    rol       $0e,s
                    inc       $09,s
L0F7F               jmp       $05,s
                    bra       $0FE4
                    inc       $0C,s
                    clr       -$09,s
                    fcb       $65
                    lsr       0,x
L0F8A               com       $01,s
                    jmp       $07,y
                    lsr       $206F
                    neg       $656E
                    bra       $0FBD
                    bcs       L100B
                    beq       L0F9A
L0F9A               beq       $0FC1
                    com       L2720
                    rol       -$0d,s
                    bra       L1011
                    clr       -$0C,s
                    bra       $1008
                    bra       L101B
                    fcb       $65
                    inc       $0f,s
                    com       $01,s
                    lsr       $6162
                    inc       $05,s
                    bra       L1022
                    clr       $04,s
                    fcb       $75
                    inc       $05,s
                    neg       $0027
                    bcs       L1031
                    beq       $0FE0
                    com       $0f,s
                    jmp       -$0C,s
                    fcb       $61
                    rol       $0e,s
                    com       $2061
                    com       $7365
                    tst       $02,s
                    inc       -$07,s
L0FD1               bra       L1038
                    fcb       $72
L0FD4               fcb       $72
                    clr       -$0e,s
L0FD7               com       >$006D
                    fcb       $61
                    rol       $0e,s
                    inc       $09,s
                    jmp       $05,s
                    bra       $1049
                    clr       -$0b,s
                    jmp       $04,s
                    bra       $1052
                    jmp       0,y
                    fcb       $62
                    clr       -$0C,s
                    asl       0,y
                    bcs       L1065
                    bra       $1055
                    jmp       $04,s
                    bra       $101D
                    com       >L0065
                    fcb       $72
                    fcb       $72
                    clr       -$0e,s
                    bra       $1073
                    fcb       $65
                    fcb       $61
                    lsr       $09,s
                    jmp       $07,s
                    bra       L1072
                    jmp       -$10,s
L100B               fcb       $75
                    lsr       L2066
                    rol       $0C,s
L1011               fcb       $65
                    bra       $1039
                    com       >$0034
                    nega
                    ldd       #$FFA5
L101B               lbsr      $0110
                    leas      -$0f,s
                    ldd       $0034
L1022               std       L0046
                    pshs      d
                    lbsr      $1C20
                    leas      $02,s
                    std       L0048
                    clra
                    clrb
                    std       L0046
L1031               ldd       #$87CD
                    std       $02,s
                    ldd       L001A
L1038               addd      L0036
                    aslb
                    rola
                    addd      #$000D
                    addd      $002E
                    addd      L0026
                    addd      L002A
                    addd      #$000D
                    std       $04,s
                    ldd       #$000D
                    std       $06,s
                    ldd       L0018
                    pshs      d
                    ldd       #$0008
                    lbsr      $329E
                    stb       $08,s
                    ldd       L0018
                    clra
                    stb       $09,s
                    ldd       #$0008
                    pshs      d
L1065               leax      $04,s
                    pshs      x
                    lbsr      $18C8
                    leas      $04,s
                    stb       $0a,s
                    ldd       L0014
L1072               beq       L1078
                    ldd       L0030
                    bra       L107F

L1078               ldx       L003E
                    ldd       $23,x
                    addd      L002C
L107F               std       $0b,s
                    ldd       L002A
                    addd      L0022
                    addd      L0026
                    addd      $001E
                    addd      L0032
                    std       $0d,s
                    leax      $193F,pcr
                    pshs      x
                    ldd       $0273,y
                    pshs      d
                    lbsr      $229A
                    leas      $04,s
                    std       L003A
                    bne       L10B1
                    bra       L10A6

L10A4               leas      -$0f,x
L10A6               leax      L1943,pcr
                    pshs      x
                    lbsr      $1AB6
                    leas      $02,s
L10B1               ldd       #$0200
                    ldx       L003A
                    std       $0b,x
                    ldd       $04,s
                    pshs      d
                    ldx       L003A
                    ldd       $08,x
                    pshs      d
                    lbsr      $192C
                    leas      $04,s
                    std       -$02,s
                    beq       L10CF
                    leax      $0f,s
                    bra       L10A4

L10CF               leax      >$0005,y
                    pshs      x
                    ldd       #$000D
                    pshs      d
                    leax      $06,s
                    pshs      x
                    lbsr      $3492
                    leas      $06,s
                    ldd       L003A
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    ldd       #$000D
                    pshs      d
                    leax      $08,s
                    pshs      x
                    lbsr      L2374
                    leas      $08,s
                    lbsr      $1908
                    ldd       $0271,y
                    std       ,s
L1103               ldx       ,s
                    leax      $01,x
                    stx       ,s
                    ldb       -$01,x
                    bne       L1103
                    ldd       ,s
                    subd      #$0002
                    std       ,s
                    ldb       [,s]
                    sex
                    orb       #$80
                    stb       [,s]
                    leax      >$0005,y
                    pshs      x
                    ldd       L001A
                    pshs      d
                    ldd       $0271,y
                    pshs      d
                    lbsr      $3492
                    leas      $06,s
                    ldd       $0271,y
                    pshs      d
                    ldd       L003A
                    pshs      d
                    lbsr      L23D0
                    leas      $04,s
                    lbsr      $1908
                    leax      >$0005,y
                    pshs      x
                    ldd       #$0001
                    pshs      d
                    leax      $0270,y
                    pshs      x
                    lbsr      $3492
                    leas      $06,s
                    ldd       L003A
                    pshs      d
                    ldb       $0270,y
                    sex
                    pshs      d
                    lbsr      L2A84
                    leas      $04,s
                    ldb       [,s]
                    clra
                    andb      #$7f
                    stb       [,s]
                    ldd       L0036
                    pshs      d
                    lbsr      L1F8A
                    leas      $02,s
                    leax      $0377,y
                    pshs      x
                    ldd       L003A
                    pshs      d
                    lbsr      L2A1B
                    leas      $02,s
                    lbsr      $314C
                    leax      $037f,y
                    pshs      x
                    leax      $0377,y
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $002E
                    lbsr      $3141
                    lbsr      L30BE
                    lbsr      $314C
                    leax      $037b,y
                    pshs      x
                    leax      $037f,y
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    bsr       L11BF
                    neg       $0000
                    neg       $0002
L11BF               puls      x
                    lbsr      L30BE
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       L002A
                    lbsr      $3141
                    lbsr      L30BE
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    bsr       L11E2
                    neg       $0000
                    neg       $0002
L11E2               puls      x
                    lbsr      L30BE
                    lbsr      $314C
                    leax      $0383,y
                    pshs      x
                    leax      $037b,y
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       L0026
                    lbsr      $3141
                    lbsr      L30BE
                    lbsr      $314C
                    ldd       L003E
                    bra       L1222

L120B               ldx       L0050
                    ldd       $13,x
                    anda      #$01
                    clrb
                    std       -$02,s
                    beq       L121D
                    lbsr      L145E
                    lbsr      $1908
L121D               ldx       L0050
                    ldd       $11,x
L1222               std       L0050
                    ldd       L0050
                    bne       L120B
                    clra
                    clrb
                    pshs      d
                    leax      $037f,y
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       L003A
                    pshs      d
                    lbsr      $28C4
                    leas      $08,s
                    leax      >$0005,y
                    pshs      x
                    ldd       #$0002
                    pshs      d
                    leax      >$002a,y
                    pshs      x
                    lbsr      $3492
                    leas      $06,s
                    ldd       L003A
                    pshs      d
                    ldd       L002A
                    pshs      d
                    lbsr      L2B29
                    leas      $04,s
                    leax      >$0005,y
                    pshs      x
                    ldd       L002A
                    pshs      d
                    leax      $0277,y
                    pshs      x
                    lbsr      $3492
                    leas      $06,s
                    ldd       L003A
                    pshs      d
                    ldd       L002A
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    leax      $0277,y
                    pshs      x
                    lbsr      L2374
                    leas      $08,s
                    lbsr      $1908
                    leax      >$0005,y
                    pshs      x
                    ldd       #$0002
                    pshs      d
                    leax      >$0026,y
                    pshs      x
                    lbsr      $3492
                    leas      $06,s
                    ldd       L003A
                    pshs      d
                    ldd       L0026
                    pshs      d
                    lbsr      L2B29
                    leas      $04,s
                    ldd       L0026
                    beq       L12C4
                    ldd       L0026
                    pshs      d
                    lbsr      L13DC
                    leas      $02,s
L12C4               clra
                    clrb
                    pshs      d
                    leax      $0383,y
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       L003A
                    pshs      d
                    lbsr      $28C4
                    leas      $08,s
                    leax      >$0005,y
                    pshs      x
                    ldd       #$0002
                    pshs      d
                    leax      >$004e,y
                    pshs      x
                    lbsr      $3492
                    leas      $06,s
                    ldd       L003A
                    pshs      d
                    ldd       L004E
                    pshs      d
                    lbsr      L2B29
                    leas      $04,s
                    ldd       L0052
                    pshs      d
                    lbsr      L2092
                    leas      $02,s
                    leax      >$0005,y
                    pshs      x
                    ldd       #$0002
                    pshs      d
                    leax      >$004C,y
                    pshs      x
                    lbsr      $3492
                    leas      $06,s
                    ldd       L003A
                    pshs      d
                    ldd       L004C
                    pshs      d
                    lbsr      L2B29
                    leas      $04,s
                    ldd       L0054
                    pshs      d
                    lbsr      L2092
                    leas      $02,s
                    leax      >$0005,y
                    pshs      x
                    ldd       L001A
                    addd      #$0001
                    pshs      d
                    ldd       $0271,y
                    pshs      d
                    lbsr      $3492
                    leas      $06,s
                    ldd       $0271,y
                    pshs      d
                    ldd       L003A
                    pshs      d
                    lbsr      L23D0
                    leas      $04,s
                    ldd       L003A
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    lbsr      L2A84
                    leas      $04,s
                    ldu       #$0000
                    bra       L1389

L136E               tfr       u,d
                    leax      >$0005,y
                    leax      d,x
                    pshs      x
                    tfr       u,d
                    leax      >$0005,y
                    leax      d,x
                    ldb       ,x
                    sex
                    coma
                    comb
                    stb       [,s++]
                    leau      $01,u
L1389               cmpu      #$0003
                    blt       L136E
                    ldd       L003A
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    ldd       #$0003
                    pshs      d
                    leax      >$0005,y
                    pshs      x
                    lbsr      L2374
                    leas      $08,s
                    lbsr      $1908
                    ldd       L003A
                    pshs      d
                    lbsr      L2B74
                    leas      $02,s
                    ldd       $000E
                    beq       L13BB
                    lbsr      $1CAC
L13BB               ldd       L0014
                    beq       L13D8
                    ldd       L0016
                    beq       L13D8
                    ldd       $001E
                    pshs      d
                    leax      L195C,pcr
                    pshs      x
                    leax      $00A3,y
                    pshs      x
                    lbsr      L23D0
                    leas      $06,s
L13D8               leas      $0f,s
                    puls      pc,u
L13DC               pshs      u
                    ldd       #$FF32
                    lbsr      $0110
                    leas      $FF7E,s
                    clra
                    clrb
                    pshs      d
                    ldd       L003A
                    pshs      d
                    lbsr      L2A1B
                    leas      $02,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       L003A
                    pshs      d
                    lbsr      $28C4
                    leas      $08,s
                    bra       L1437

L1408               lbsr      $1908
                    ldd       ,s
                    cmpd      $0086,s
                    ble       L141A
                    ldd       $0086,s
                    std       ,s
L141A               leax      >$0005,y
                    pshs      x
                    ldd       $02,s
                    pshs      d
                    leax      $06,s
                    pshs      x
                    lbsr      $3492
                    leas      $06,s
                    ldd       $0086,s
                    subd      ,s
                    std       $0086,s
L1437               ldd       $0086,s
                    ble       L1458
                    ldd       L003A
                    pshs      d
                    ldd       #$0080
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    leax      $08,s
                    pshs      x
                    lbsr      L232E
                    leas      $08,s
                    std       ,s
                    bne       L1408
L1458               leas      $0082,s
                    puls      pc,u
L145E               pshs      u
                    ldd       #$FFA3
                    lbsr      $0110
                    leas      -$07,s
                    ldd       $004A
                    ldx       L0050
                    cmpd      $2f,x
                    beq       L14A0
                    ldd       L0038
                    pshs      d
                    leax      L1982,pcr
                    pshs      x
                    ldx       L0050
                    ldd       $2f,x
                    std       $004A
                    pshs      d
                    lbsr      L22B9
                    leas      $06,s
                    std       L0038
                    bne       L14A0
                    ldx       L0050
                    ldd       $2f,x
                    pshs      d
                    leax      L1984,pcr
                    pshs      x
                    lbsr      $1AB6
                    leas      $04,s
L14A0               clra
                    clrb
                    pshs      d
                    ldx       L0050
                    leax      $29,x
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       L0038
                    pshs      d
                    lbsr      $28C4
                    leas      $08,s
                    ldd       L0038
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    ldx       L0050
                    ldd       $1f,x
                    ldx       L0050
                    addd      $1d,x
                    ldx       L0050
                    addd      $1b,x
                    pshs      d
                    ldd       L0048
                    pshs      d
                    lbsr      L232E
                    leas      $08,s
                    std       -$02,s
                    bne       L14ED
                    ldx       L0050
                    ldd       $2f,x
                    pshs      d
                    lbsr      $18F6
                    leas      $02,s
L14ED               ldd       L0038
                    pshs      d
                    lbsr      L2CF9
                    leas      $02,s
                    std       ,s
                    ldx       L0038
                    ldd       $06,x
                    clra
                    andb      #$20
                    lbeq      L15A6
                    ldx       L0050
                    ldd       $2f,x
                    pshs      d
                    lbsr      $18F6
                    leas      $02,s
                    lbra      L15A6

L1512               leas      -$0a,s
                    leax      ,s
                    pshs      x
                    lbsr      L1DE1
                    leas      $02,s
                    ldd       L0038
                    pshs      d
                    lbsr      L2CF9
                    leas      $02,s
                    tfr       d,u
                    ldx       L0038
                    ldd       $06,x
                    clra
                    andb      #$20
                    beq       L153D
                    ldx       L0050
                    ldd       $2f,x
                    pshs      d
                    lbsr      $18F6
                    leas      $02,s
L153D               leax      ,s
                    pshs      x
                    leax      $02,s
                    pshs      x
                    lbsr      $19F8
                    std       ,s
                    lbsr      $1A1D
                    leas      $04,s
                    std       $0f,s
                    bne       L159C
                    leax      ,s
                    pshs      x
                    leax      $199F,pcr
                    pshs      x
                    lbsr      $1AB6
                    bra       L159A

L1562               ldd       L0038
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    ldd       #$0003
                    pshs      d
                    leax      $12,s
                    pshs      x
                    lbsr      L232E
                    leas      $08,s
                    ldx       L0038
                    ldd       $06,x
                    clra
                    andb      #$20
                    beq       L158F
                    ldx       L0050
                    ldd       $2f,x
                    pshs      d
                    lbsr      $18F6
                    leas      $02,s
L158F               ldd       $0f,s
                    pshs      d
                    leax      $0e,s
                    pshs      x
                    lbsr      $17A1
L159A               leas      $04,s
L159C               tfr       u,d
                    leau      -$01,u
                    std       -$02,s
                    bne       L1562
                    leas      $0a,s
L15A6               ldd       ,s
                    addd      #$FFFF
                    std       ,s
                    subd      #$FFFF
                    lbne      L1512
                    ldd       L0038
                    pshs      d
                    lbsr      L2CF9
                    leas      $02,s
                    std       ,s
                    ldx       L0038
                    ldd       $06,x
                    clra
                    andb      #$20
                    beq       $160F
                    ldx       L0050
                    ldd       $2f,x
                    pshs      d
                    lbsr      $18F6
                    leas      $02,s
                    bra       $160F
                    ldd       L0038
                    pshs      y,dp,a,cc
                    ror       L00CC
                    neg       $0001
                    pshs      d
                    ldd       #$0003
                    pshs      d
                    leax      $08,s
                    pshs      x
                    lbsr      $232F
                    leas      $08,s
                    ldx       L0038
                    ldd       $06,x
                    clra
                    andb      #$20
                    beq       L1603
                    ldx       L0050
                    ldd       $2f,x
                    pshs      d
                    lbsr      L18F7
                    leas      $02,s
L1603               clra
                    clrb
                    pshs      d
                    leax      $04,s
                    pshs      x
                    lbsr      L17A2
                    leas      $04,s
                    ldd       ,s
                    addd      #$FFFF
                    std       ,s
                    subd      #$FFFF
                    bne       $15D7
                    leax      >$0005,y
                    pshs      x
                    ldx       L0050
                    ldd       $1f,x
                    pshs      d
                    ldd       L0048
                    pshs      d
                    lbsr      L3493
                    leas      $06,s
                    ldd       $005A
                    bne       L164F
                    clra
                    clrb
                    pshs      d
                    leax      $0377,y
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       L003A
                    pshs      d
                    lbsr      L28C5
                    leas      $08,s
L164F               ldd       L003A
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    ldx       L0050
                    ldd       $1f,x
                    pshs      d
                    ldd       L0048
                    pshs      d
                    lbsr      $2375
                    leas      $08,s
                    leax      $0377,y
                    pshs      x
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldx       L0050
                    ldd       $1f,x
                    lbsr      L3142
                    lbsr      $30BF
                    lbsr      L314D
                    ldd       #$0001
                    std       $005A
                    lbsr      L1909
                    clra
                    clrb
                    std       ,s
                    ldd       L0048
                    ldx       L0050
                    addd      $1f,x
                    tfr       d,u
                    bra       L16B0

L169B               ldb       ,u+
                    ldx       >$007a,y
                    leax      $01,x
                    stx       >$007a,y
                    stb       -$01,x
                    ldd       ,s
                    addd      #$0001
                    std       ,s
L16B0               ldd       ,s
                    ldx       L0050
                    cmpd      $1d,x
                    bcs       L169B
                    ldx       L0050
                    ldd       $1b,x
                    lbeq      L1722
                    clra
                    clrb
                    pshs      d
                    leax      $037b,y
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       L003A
                    pshs      d
                    lbsr      L28C5
                    leas      $08,s
                    ldd       L003A
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    ldx       L0050
                    ldd       $1b,x
                    pshs      d
                    ldd       L0048
                    ldx       L0050
                    addd      $1f,x
                    ldx       L0050
                    addd      $1d,x
                    pshs      d
                    lbsr      $2375
                    leas      $08,s
                    leax      $037b,y
                    pshs      x
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldx       L0050
                    ldd       $1b,x
                    lbsr      L3142
                    lbsr      $30BF
                    lbsr      L314D
                    lbsr      L1909
                    clra
                    clrb
                    std       $005A
L1722               ldd       L001C
                    pshs      d
                    ldx       L0050
                    ldd       $17,x
                    addd      ,s++
                    std       L001C
                    ldd       $0020
                    pshs      d
                    ldx       L0050
                    ldd       $19,x
                    addd      ,s++
                    std       $0020
                    ldd       $0024
                    pshs      d
                    ldx       L0050
                    ldd       $1b,x
                    addd      ,s++
                    std       $0024
                    ldd       L0028
                    pshs      d
                    ldx       L0050
                    ldd       $1d,x
                    addd      ,s++
                    std       L0028
                    ldd       L002C
                    pshs      d
                    ldx       L0050
                    ldd       $1f,x
                    addd      ,s++
                    std       L002C
                    ldd       L001C
                    ldx       L0050
                    subd      $17,x
                    ldx       L0050
                    std       $17,x
                    ldd       $0020
                    ldx       L0050
                    subd      $19,x
                    ldx       L0050
                    std       $19,x
                    ldd       $0024
                    ldx       L0050
                    subd      $1b,x
                    ldx       L0050
                    std       $1b,x
                    ldd       L0028
                    ldx       L0050
                    subd      $1d,x
                    ldx       L0050
                    std       $1d,x
                    ldd       L002C
                    ldx       L0050
                    subd      $1f,x
                    ldx       L0050
                    std       $1f,x
                    lbra      L18C5

L17A2               pshs      u
                    ldd       #$FFB1
                    lbsr      L0111
                    leas      -$07,s
                    ldx       $0b,s
                    ldd       $01,x
                    addd      L0048
                    std       $05,s
                    ldb       [$0b,s]
                    stb       $02,s
                    ldd       $0d,s
                    beq       L17DA
                    ldx       $0d,s
                    ldd       $0C,x
                    std       $03,s
                    ldx       $0d,s
                    ldd       $0a,x
                    stb       $01,s
                    ldb       $02,s
                    clra
                    andb      #$80
                    lbeq      L1822
                    ldd       $03,s
                    subd      L002C
                    std       $03,s
                    bra       L1822

L17DA               ldb       $02,s
                    stb       $01,s
                    clra
                    andb      #$07
                    tfr       d,x
                    bra       L1808

L17E5               ldd       L001C
                    bra       L17F7

L17E9               ldd       $0024
                    bra       L17F7

L17ED               ldd       $0020
                    bra       L17F7

L17F1               ldd       L0028
                    bra       L17F7

L17F5               ldd       L002C
L17F7               std       $03,s
                    bra       L1822

L17FB               leax      L19BE,pcr
                    pshs      x
                    lbsr      L1AB7
                    leas      $02,s
                    bra       L1822

L1808               stx       -$02,s
                    beq       L17E5
                    cmpx      #$0001
                    beq       L17E9
                    cmpx      #$0002
                    beq       L17ED
                    cmpx      #$0003
                    beq       L17F1
                    cmpx      #$0004
                    beq       L17F5
                    bra       L17FB

L1822               ldb       $02,s
                    clra
                    andb      #$40
                    beq       L1831
                    ldd       $03,s
                    nega
                    negb
                    sbca      #$00
                    std       $03,s
L1831               ldb       $02,s
                    clra
                    andb      #$30
                    stb       ,s
                    cmpb      #$20
                    beq       L185D
                    ldd       $05,s
                    pshs      d
                    ldx       L0050
                    ldd       $1f,x
                    addd      ,s++
                    std       $05,s
                    ldb       ,s
                    clra
                    andb      #$10
                    bne       L185D
                    ldd       $05,s
                    pshs      d
                    ldx       L0050
                    ldd       $1d,x
                    addd      ,s++
                    std       $05,s
L185D               ldb       $02,s
                    clra
                    andb      #$08
                    beq       L186F
                    ldb       [$05,s]
                    sex
                    addd      $03,s
                    stb       [$05,s]
                    bra       L1877

L186F               ldd       [$05,s]
                    addd      $03,s
                    std       [$05,s]
L1877               ldb       ,s
                    cmpb      #$20
                    beq       L18C5
                    ldb       ,s
                    clra
                    andb      #$10
                    beq       L1888
                    ldd       L0028
                    bra       L188A

L1888               ldd       $0024
L188A               ldx       $0b,s
                    addd      $01,x
                    tfr       d,u
                    ldb       $01,s
                    clra
                    andb      #$07
                    cmpd      #$0004
                    bne       L18B1
                    pshs      u
                    leax      >$0052,y
                    pshs      x
                    lbsr      $200F
                    leas      $04,s
                    ldd       L004E
                    addd      #$0001
                    std       L004E
                    bra       L18C5

L18B1               pshs      u
                    leax      >$0054,y
                    pshs      x
                    lbsr      $200F
                    leas      $04,s
                    ldd       L004C
                    addd      #$0001
                    std       L004C
L18C5               leas      $07,s
                    puls      pc,u
                    pshs      u
                    ldd       #$FFBC
                    lbsr      L0111
                    ldu       $04,s
                    leas      -$02,s
                    ldd       #$FFFF
                    bra       L18E5

L18DA               ldd       ,s
                    pshs      d
                    ldb       ,u+
                    sex
                    eora      ,s+
                    eorb      ,s+
L18E5               std       ,s
                    ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bne       L18DA
                    ldd       ,s
                    puls      pc,u,x
L18F7               pshs      u
                    ldd       #$FFB8
                    lbsr      L0111
                    ldd       $04,s
                    pshs      d
                    leax      $19CD,pcr
                    bra       L1924

L1909               pshs      u
                    ldd       #$FFB8
                    lbsr      L0111
                    ldx       L003A
                    ldd       $06,x
                    clra
                    andb      #$20
                    beq       L192B
                    ldd       $0273,y
                    pshs      d
                    leax      $19E3,pcr
L1924               pshs      x
                    lbsr      L1AB7
                    leas      $04,s
L192B               puls      pc,u
                    pshs      u,x,d
                    lda       $09,s
                    ldb       #$02
                    ldx       #$0000
                    ldu       $0a,s
                    os9       I$SetStt
                    puls      u,x,d
                    lbra      L3568
                    asr       $782B
L1943               neg       L0063
                    fcb       $61
                    jmp       $07,y
                    lsr       $2063
                    fcb       $72
                    fcb       $65
                    fcb       $61
                    lsr       $6520
                    clr       -$0b,s
                    lsr       $7075
                    lsr       L2066
                    rol       $0C,s
                    fcb       $65
L195C               neg       L0042
                    fcb       $41,$53,$49,$43,$30,$39,$20,$73
                    fcb       $74,$61,$74,$69,$63,$20,$64,$61
                    fcb       $74,$61,$20,$73,$69,$7a,$65,$20
                    fcb       $69,$73,$20,$25,$64,$20,$62,$79
                    fcb       $74,$65,$73,$0d
L1982               neg       $0072
L1984               neg       L0063
                    fcb       $61
                    jmp       $07,y
                    lsr       $2072
                    fcb       $65
                    clr       -$10,s
                    fcb       $65
                    jmp       0,y
                    rol       $0e,s
                    neg       $7574
                    bra       L19FF
                    rol       $0C,s
                    fcb       $65
                    bra       $19C3
                    com       >$0073
                    rol       $6D62
                    clr       $0C,s
                    bra       $19CD
                    com       L206E
                    clr       -$0C,s
                    bra       $1A15
                    clr       -$0b,s
                    jmp       $04,s
                    bra       L1A1E
                    jmp       0,y
                    com       $0f,s
                    lsr       $07,s
                    fcb       $65
                    jmp       0,x
L19BE               fcb       $72
                    fcb       $65
                    ror       0,y
                    lsr       $7970
                    fcb       $65
                    bra       $1A2D
                    fcb       $72
                    fcb       $72
                    clr       -$0e,s
                    neg       L0065
                    fcb       $72
                    fcb       $72
                    clr       -$0e,s
                    bra       $1A46
                    fcb       $65
                    fcb       $61
                    lsr       $09,s
                    jmp       $07,s
                    bra       L1A42
                    rol       $0C,s
                    fcb       $65
                    bra       $1A06
                    com       >L0065
                    fcb       $72
                    fcb       $72
                    clr       -$0e,s
                    bra       $1A61
                    fcb       $72
                    rol       -$0C,s
                    rol       $0e,s
                    asr       0,y
                    ror       $09,s
                    inc       $05,s
                    bra       L1A1C
                    com       >$0034
                    nega
                    ldu       $04,s
                    leas      -$02,s
L19FF               clra
                    clrb
                    bra       L1A0C

L1A03               ldd       ,s
                    pshs      d
                    ldb       ,u+
                    sex
                    addd      ,s++
L1A0C               std       ,s
                    ldb       ,u
                    bne       L1A03
                    ldd       ,s
                    pshs      d
                    ldd       #$0173
                    lbsr      L31D4
L1A1C               puls      pc,u,x
L1A1E               pshs      u
                    ldd       $04,s
                    aslb
                    rola
                    leax      $0387,y
                    leax      d,x
                    ldu       ,x
                    bra       L1A50

L1A2E               ldb       [$06,s]
                    sex
                    pshs      d
                    ldb       ,u
                    sex
                    cmpd      ,s++
                    bne       L1A4D
                    pshs      u
                    ldd       $08,s
                    pshs      d
L1A42               lbsr      $2F1C
                    leas      $04,s
                    std       -$02,s
                    lbeq      L1C1D
L1A4D               ldu       $10,u
L1A50               stu       -$02,s
                    bne       L1A2E
                    clra
                    clrb
                    puls      pc,u
                    pshs      u,d
                    ldd       $06,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      $19F9
                    leas      $02,s
                    std       $02,s
                    pshs      d
                    lbsr      L1A1E
                    leas      $04,s
                    std       -$02,s
                    bne       L1AB0
                    ldd       ,s
                    aslb
                    rola
                    leax      $0387,y
                    leax      d,x
                    ldd       ,x
                    ldx       $06,s
                    std       $10,x
                    ldd       ,s
                    aslb
                    rola
                    leax      $0387,y
                    leax      d,x
                    ldd       $06,s
                    std       ,x
                    clra
                    clrb
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L1B84
                    leas      $04,s
                    std       -$02,s
                    beq       L1AAC
                    ldx       $06,s
                    ldd       $0a,x
                    ora       #$01
                    std       $0a,x
L1AAC               clra
                    clrb
                    bra       L1AB3

L1AB0               ldd       #$0001
L1AB3               puls      pc,u,x
                    puls      pc,u,x
L1AB7               pshs      u,d
                    ldd       $0228,y
                    std       ,s
                    leax      $1E2E,pcr
                    pshs      x
                    leax      $00A3,y
                    pshs      x
                    lbsr      $23D1
                    leas      $04,s
                    ldd       $0C,s
                    pshs      d
                    ldd       $0C,s
                    pshs      d
                    ldd       $0C,s
                    pshs      d
                    ldd       $0C,s
                    pshs      d
                    leax      $00A3,y
                    pshs      x
                    lbsr      $23D1
                    leas      $0a,s
                    leax      $1E3D,pcr
                    pshs      x
                    leax      $00A3,y
                    pshs      x
                    lbsr      $23D1
                    leas      $04,s
                    ldd       ,s
                    pshs      d
                    lbsr      L356D
                    leas      $02,s
                    puls      pc,u,x
                    pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    clra
                    clrb
                    bra       L1B24

L1B11               ldd       ,s
                    pshs      d
                    ldd       #$000A
                    lbsr      L3181
                    pshs      d
                    ldd       $04,s
                    addd      #$FFD0
                    addd      ,s++
L1B24               std       ,s
                    ldb       ,u+
                    sex
                    std       $02,s
                    leax      $015a,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$08
                    bne       L1B11
                    ldd       $02,s
                    cmpd      #$006B
                    beq       L1B48
                    ldd       $02,s
                    cmpd      #$004B
                    bne       L1B54
L1B48               ldd       ,s
                    pshs      d
                    ldd       #$0004
                    lbsr      L3181
                    std       ,s
L1B54               ldd       ,s
                    pshs      d
                    ldd       #$0008
                    lbsr      L32C2
                    leas      $04,s
                    puls      pc,u
L1B62               pshs      u
                    ldu       $04,s
                    ldd       ,u
                    std       [$02,u]
                    ldd       $02,u
                    ldx       ,u
                    std       $02,x
                    leax      >$0060,y
                    pshs      x
                    cmpu      ,s++
                    beq       L1B82
                    ldd       L005C
                    std       ,u
                    stu       L005C
L1B82               puls      pc,u
L1B84               pshs      u,d
                    clra
                    clrb
                    std       ,s
                    ldu       >$0060,y
                    bra       L1BCB

L1B90               ldb       $04,u
                    sex
                    pshs      d
                    ldb       [$08,s]
                    sex
                    cmpd      ,s++
                    bne       L1BC9
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    ldd       #$0004
                    addd      ,s++
                    pshs      d
                    lbsr      $2F1C
                    leas      $04,s
                    std       -$02,s
                    bne       L1BC9
                    ldd       $08,s
                    beq       L1BBC
                    tfr       u,d
                    puls      pc,u,x
L1BBC               ldd       ,u
                    std       ,s
                    pshs      u
                    lbsr      L1B62
                    leas      $02,s
                    ldu       ,s
L1BC9               ldu       ,u
L1BCB               leax      >$0060,y
                    pshs      x
                    cmpu      ,s++
                    bne       L1B90
                    ldd       ,s
                    puls      pc,u,x
                    pshs      u
                    ldd       #$0001
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L1B84
                    leas      $04,s
                    tfr       d,u
                    stu       -$02,s
                    bne       L1C1D
                    ldd       L005C
                    beq       L1BFC
                    ldu       L005C
                    ldd       ,u
                    std       L005C
                    bra       L1C07

L1BFC               ldd       #$0010
                    pshs      d
                    bsr       L1C21
                    leas      $02,s
                    tfr       d,u
L1C07               leax      >$0060,y
                    stx       $02,u
                    ldd       >$0060,y
                    std       ,u
                    ldx       >$0060,y
                    stu       $02,x
                    stu       >$0060,y
L1C1D               tfr       u,d
                    puls      pc,u
L1C21               pshs      u,d
                    ldd       $06,s
                    pshs      d
                    lbsr      L34B9
                    leas      $02,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       L1C5A
                    ldd       L0046
                    beq       L1C4D
                    ldd       L0046
                    pshs      d
                    leax      $1E3F,pcr
                    pshs      x
                    leax      $00A3,y
                    pshs      x
                    lbsr      $23D1
                    leas      $06,s
L1C4D               leax      L1E5A,pcr
                    pshs      x
                    lbsr      L1AB7
                    leas      $02,s
                    bra       L1C5E

L1C5A               ldd       ,s
                    puls      pc,u,x
L1C5E               puls      pc,u,x
                    pshs      u
                    ldd       $04,s
                    clra
                    andb      #$07
                    tfr       d,x
                    bra       L1C91

L1C6B               leax      $1E68,pcr
                    bra       L1C8D

L1C71               leax      L1E6D,pcr
                    bra       L1C8D

L1C77               leax      $1E72,pcr
                    bra       L1C8D

L1C7D               leax      $1E77,pcr
                    bra       L1C8D

L1C83               leax      $1E7C,pcr
                    bra       L1C8D

L1C89               leax      $1E81,pcr
L1C8D               tfr       x,d
                    puls      pc,u
L1C91               cmpx      #$0004
                    beq       L1C6B
                    stx       -$02,s
                    beq       L1C71
                    cmpx      #$0001
                    beq       L1C77
                    cmpx      #$0002
                    beq       L1C7D
                    cmpx      #$0003
                    beq       L1C83
                    bra       L1C89
                    puls      pc,u
                    pshs      u,d
                    ldd       $0273,y
                    pshs      d
                    ldd       $0271,y
                    pshs      d
                    leax      L1E85,pcr
                    pshs      x
                    lbsr      $23BF
                    leas      $06,s
                    leax      $1EA3,pcr
                    pshs      x
                    lbsr      $22ED
                    leas      $02,s
                    ldd       L003E
                    lbra      $1D4E
                    ldx       ,s
                    ldd       $13,x
                    anda      #$01
                    clrb
                    std       -$02,s
                    lbeq      $1D49
                    ldx       ,s
                    ldd       $2f,x
                    pshs      d
                    ldx       $02,s
                    ldd       $19,x
                    pshs      d
                    ldx       $04,s
                    ldd       $1d,x
                    pshs      d
                    ldx       $06,s
                    ldd       $17,x
                    pshs      d
                    ldx       $08,s
                    ldd       $1b,x
                    pshs      d
                    ldx       $0a,s
                    ldd       $1f,x
                    pshs      d
                    ldd       $0C,s
                    pshs      d
                    leax      L1ED5,pcr
                    pshs      x
                    lbsr      $23BF
                    leas      $10,s
                    ldd       $0010
                    beq       $1D49
                    fcb       $02
                    ldx       ,s
                    ldu       $2d,x
                    bra       L1D46

L1D2A               ldd       $0C,u
                    pshs      d
                    ldd       $0a,u
                    pshs      d
                    lbsr      $1C61
                    std       ,s
                    pshs      u
                    leax      L1EFB,pcr
                    pshs      x
                    lbsr      L23C0
                    leas      $08,s
                    ldu       $0e,u
L1D46               stu       -$02,s
                    bne       L1D2A
                    ldx       ,s
                    ldd       $11,x
                    std       ,s
                    ldd       ,s
                    lbne      $1CD7
                    leax      L1F0E,pcr
                    pshs      x
                    lbsr      L22EE
                    leas      $02,s
                    ldd       L0022
                    pshs      d
                    ldd       L002A
                    pshs      d
                    ldd       $001E
                    pshs      d
                    ldd       L0026
                    pshs      d
                    ldd       $002E
                    pshs      d
                    leax      $1F31,pcr
                    pshs      x
                    lbsr      L23C0
                    leas      $0C,s
L1D81               puls      pc,u,x
                    pshs      u
                    leax      >$0060,y
                    cmpx      >$0060,y
                    beq       L1DDD
                    leax      L1F5D,pcr
                    pshs      x
                    leax      $00A3,y
                    pshs      x
                    lbsr      L23D2
                    leas      $04,s
                    ldu       >$0060,y
                    bra       L1DCD

L1DA6               ldx       $0e,u
                    ldd       $2f,x
                    pshs      d
                    ldd       $0e,u
                    pshs      d
                    pshs      u
                    ldd       #$0004
                    addd      ,s++
                    pshs      d
                    leax      $1F75,pcr
                    pshs      x
                    leax      $00A3,y
                    pshs      x
                    lbsr      L23D2
                    leas      $0a,s
                    ldu       ,u
L1DCD               leax      >$0060,y
                    pshs      x
                    cmpu      ,s++
                    bne       L1DA6
                    ldd       #$0001
                    puls      pc,u
L1DDD               clra
                    clrb
                    puls      pc,u
L1DE1               puls      pc,u
                    pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    bra       L1DEF

L1DEB               ldd       ,s
                    stb       ,u+
L1DEF               ldd       L0038
                    pshs      d
                    lbsr      L2C99
                    leas      $02,s
                    std       ,s
                    bne       L1DEB
                    clra
                    clrb
                    stb       ,u
L1E00               puls      pc,u,x
                    pshs      u,d
                    ldd       $0228,y
                    std       ,s
                    ldd       L003A
                    beq       L1E22
                    ldd       L003A
                    pshs      d
                    lbsr      L2B76
                    leas      $02,s
                    ldd       $0273,y
                    pshs      d
                    lbsr      L33B2
                    leas      $02,s
L1E22               ldd       $0228,y
                    pshs      d
                    lbsr      L356E
                    leas      $02,s
                    puls      pc,u,x
                    inc       $09,s
                    jmp       $0b,s
                    fcb       $65
                    fcb       $72
                    bra       L1E9D
                    fcb       $61
                    lsr       $616C
                    abx
                    bra       L1E3E

L1E3E               tst       $0000
                    fcb       $6e,$65,$65,$64,$20,$25,$64,$20
                    fcb       $62,$79,$74,$65,$73,$20,$66,$6f
                    fcb       $72,$20,$6C,$69,$6e,$6b,$62,$75
                    fcb       $66,$0d
L1E5A               neg       $006F
                    fcb       $75
                    lsr       $206F
                    ror       0,y
                    tst       $05,s
                    tst       $0f,s
                    fcb       $72
                    rol       >L0063
                    clr       $04,s
                    fcb       $65
L1E6D               neg       L0075
                    lsr       $01,s
                    lsr       >$0069
                    lsr       $01,s
                    lsr       >L0075
                    lsr       -$10,s
                    lsr       0,x
                    rol       $04,s
                    neg       $6400
                    swi
                    swi
                    swi

L1E85               neg       L004C
                    rol       $0e,s
                    fcb       $6b
                    fcb       $61
                    asr       $05,s
                    bra       $1EFC
                    fcb       $61
                    neg       L2066
                    clr       -$0e,s
                    bra       L1EBC
                    com       L2020
                    rora
                    rol       $0C,s
L1E9D               fcb       $65
                    bra       L1ECD
                    bra       L1EC7
                    com       >$000D
                    tst       $0053
                    fcb       $65,$63,$74,$69,$6f,$6e,$20,$20
                    fcb       $20,$20,$20,$20,$20,$20,$20,$20
                    fcb       $43,$6f,$64,$65,$20
L1EBC               fcb       $49,$44,$61,$74,$20,$55,$44,$61
                    fcb       $74,$20,$49
L1EC7               fcb       $44,$70,$44,$20,$55,$44
L1ECD               fcb       $70,$44,$20,$46,$69,$6C,$65
                    fcb       $0d
L1ED5               neg       L0025
                    fcb       $2d,$31,$36,$73,$20,$25,$30,$34
                    fcb       $78,$20,$25,$30,$34,$78,$20,$25
                    fcb       $30,$34,$78,$20,$25,$30,$32,$78
                    fcb       $20,$20,$20,$25,$30,$32,$78,$20
                    fcb       $25,$73,$0d,$00
L1EFB               bra       $1F1D
                    bra       $1F1F
                    bra       $1F26
                    blt       L1F3C
                    com       $2025
                    com       $2025
                    leax      -$0C,y
                    asl       $0D00
L1F0E               bra       L1F30
                    bra       L1F32
                    bra       L1F34
                    bra       L1F36
                    bra       L1F38
                    bra       L1F3A
                    bra       L1F3C
                    bra       L1F3E

L1F1E               bra       L1F4D

L1F20               blt       L1F4F
                    blt       L1F44
                    blt       $1F53
                    blt       $1F55
                    bra       L1F57
                    blt       L1F59
                    blt       $1F4E
                    blt       L1F5D
L1F30               neg       $0020
L1F32               bra       L1F54

L1F34               bra       $1F56

L1F36               bra       $1F58

L1F38               bra       $1F5A

L1F3A               bra       $1F5C

L1F3C               bra       L1F5E

L1F3E               bra       L1F60
                    bra       L1F62
                    bcs       L1F74
L1F44               pshs      u,y,x,dp
                    bra       L1F6D
                    leax      -$0C,y
                    asl       $2025
L1F4D               leax      -$0C,y
L1F4F               asl       $2025
                    leax      -$0e,y
L1F54               asl       L2020
L1F57               bcs       L1F89
L1F59               leas      -$08,s
                    tst       $0000
L1F5D               fcb       $55
L1F5E               fcb       $6e,$72
L1F60               fcb       $65,$73
L1F62               fcb       $6f,$6C,$76,$65,$64,$20,$72,$65
                    fcb       $66,$65,$72
L1F6D               fcb       $65,$6e,$63,$65,$73,$3a,$0d
L1F74               neg       $0020
                    fcb       $25,$2d,$31,$36,$73,$20,$25,$2d
                    fcb       $31,$36,$73,$20,$69,$6e,$20,$25
                    fcb       $2d,$31,$36
L1F89               fcb       $73
L1F8A               fcb       $0d,$00
                    pshs      u
                    ldu       >$005C,y
                    bra       L1F9D

L1F94               ldu       ,u
                    ldd       $04,s
                    subd      #$0007
                    std       $04,s
L1F9D               ldd       $04,s
                    ble       L1FA5
                    stu       -$02,s
                    bne       L1F94
L1FA5               ldd       $04,s
                    beq       L1FCC
                    bra       L1FC8

L1FAB               ldd       #$0010
                    pshs      d
                    lbsr      $1C22
                    leas      $02,s
                    tfr       d,u
                    ldd       >$005C,y
                    std       ,u
                    stu       >$005C,y
                    ldd       $04,s
                    subd      #$0007
                    std       $04,s
L1FC8               ldd       $04,s
                    bgt       L1FAB
L1FCC               puls      pc,u
L1FCE               pshs      u
                    ldu       $04,s
                    bra       L1FD9

L1FD4               ldd       #$FFFF
                    std       ,u++
L1FD9               ldd       $06,s
                    addd      #$FFFF
                    std       $06,s
                    subd      #$FFFF
                    bgt       L1FD4
                    puls      pc,u
L1FE7               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    clra
                    clrb
                    std       ,s
                    bra       L2004

L1FF3               ldd       ,u
                    bge       L1FFB
                    tfr       u,d
                    puls      pc,u,x
L1FFB               ldd       ,s
                    addd      #$0001
                    std       ,s
                    leau      $02,u
L2004               ldd       ,s
                    cmpd      #$0007
                    blt       L1FF3
                    clra
                    clrb
                    puls      pc,u,x
                    pshs      u,d
                    ldd       [$06,s]
                    bne       L203E
                    ldd       >$005C,y
                    std       [$06,s]
                    ldx       $06,s
L2020               ldd       [,x]
                    std       >$005C,y
                    clra
                    clrb
                    ldx       $06,s
                    std       [,x]
                    ldd       #$0007
                    pshs      d
                    ldd       [$08,s]
                    addd      #$0002
                    pshs      d
                    lbsr      L1FCE
                    leas      $04,s
L203E               ldd       [$06,s]
                    addd      #$0002
                    pshs      d
                    lbsr      L1FE7
                    leas      $02,s
                    std       ,s
                    bne       L208E
                    ldd       >$005C,y
                    bne       L2060
                    leax      L2134,pcr
                    pshs      x
                    lbsr      $1AB8
                    bra       L208C

L2060               leas      -$02,s
                    ldd       >$005C,y
L2066               std       ,s
                    ldd       [,s]
                    std       >$005C,y
L206E               ldd       [$08,s]
                    std       [,s]
L2073               ldd       ,s
                    std       [$08,s]
                    ldd       #$0007
                    pshs      d
                    ldd       [$0a,s]
                    addd      #$0002
                    std       $04,s
                    pshs      d
                    lbsr      L1FCE
                    leas      $04,s
L208C               leas      $02,s
L208E               ldd       $08,s
                    std       [,s]
L2092               puls      pc,u,x
                    pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    bra       L20CF

L209C               clra
                    clrb
                    std       $02,s
                    leax      $02,u
                    stx       ,s
                    bra       L20C5

L20A6               ldd       [,s]
                    cmpd      #$FFFF
                    beq       L20CD
                    ldx       ,s
                    leax      $02,x
                    stx       ,s
                    ldd       -$02,x
                    pshs      d
                    bsr       L20D9
                    leas      $02,s
                    bra       L20BE

L20BE               ldd       $02,s
                    addd      #$0001
                    std       $02,s
L20C5               ldd       $02,s
                    cmpd      #$0007
                    blt       L20A6
L20CD               ldu       ,u
L20CF               stu       -$02,s
                    bne       L209C
                    bsr       L20F6
                    leas      $04,s
                    puls      pc,u
L20D9               pshs      u
                    ldd       $04,s
                    ldx       $0008
                    leax      $02,x
                    stx       $0008
                    std       -$02,x
                    ldd       $005E
                    addd      #$0002
                    std       $005E
                    cmpd      #$0100
                    blt       L20F4
                    bsr       L20F6
L20F4               puls      pc,u
L20F6               pshs      u
                    leax      >$0005,y
                    pshs      x
                    ldd       $005E
                    pshs      d
                    leax      $0277,y
                    pshs      x
                    lbsr      L3494
                    leas      $06,s
                    ldd       L003A
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    ldd       $005E
                    pshs      d
                    leax      $0277,y
                    pshs      x
                    lbsr      L2376
                    leas      $08,s
                    lbsr      $190A
                    leax      $0277,y
                    stx       $0008
                    clra
                    clrb
                    std       $005E
                    puls      pc,u
L2134               clr       -$0b,s
                    lsr       $206F
                    ror       0,y
                    lsr       -$0e,s
                    fcb       $65
                    ror       0,y
                    jmp       $0f,s
                    lsr       $05,s
                    com       >$0034
                    nega
                    leau      $0089,y
L214C               ldd       $06,u
                    clra
                    andb      #$03
                    lbeq      L21BD
                    leau      $0d,u
                    pshs      u
                    leax      $0159,y
                    cmpx      ,s++
                    bhi       L214C
                    ldd       #$00C8
                    std       $0228,y
                    lbra      L21C1
                    puls      pc,u
L216D               pshs      u
                    ldu       $08,s
                    bne       L2177
                    bsr       $2146
                    tfr       d,u
L2177               stu       -$02,s
                    beq       L21C1
                    ldd       $04,s
                    std       $08,u
                    ldx       $06,s
L2181               ldb       $01,x
                    cmpb      #$2b
                    beq       L218F
                    ldx       $06,s
                    ldb       $02,x
                    cmpb      #$2b
                    bne       L2195
L218F               ldd       $06,u
                    orb       #$03
                    bra       L21B3

L2195               ldd       $06,u
                    pshs      d
                    ldb       [$08,s]
                    cmpb      #$72
                    beq       L21A7
                    ldb       [$08,s]
                    cmpb      #$64
                    bne       L21AC
L21A7               ldd       #$0001
                    bra       L21AF

L21AC               ldd       #$0002
L21AF               ora       ,s+
                    orb       ,s+
L21B3               std       $06,u
                    ldd       $02,u
                    addd      $0b,u
                    std       $04,u
                    std       ,u
L21BD               tfr       u,d
                    puls      pc,u
L21C1               clra
                    clrb
                    puls      pc,u
L21C5               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    clra
                    clrb
                    std       ,s
                    ldx       $0a,s
                    ldb       $01,x
                    sex
                    tfr       d,x
                    bra       L21F6

L21D8               ldx       $0a,s
                    ldb       $02,x
                    cmpb      #$2b
                    bne       L21E5
                    ldd       #$0007
                    bra       L21ED

L21E5               ldd       #$0004
                    bra       L21ED

L21EA               ldd       #$0003
L21ED               std       ,s
                    bra       L2206

L21F1               leax      $04,s
                    lbra      L225E

L21F6               stx       -$02,s
                    beq       L2206
                    cmpx      #$0078
                    beq       L21D8
                    cmpx      #$002B
                    beq       L21EA
                    bra       L21F1

L2206               ldb       [$0a,s]
                    sex
                    tfr       d,x
                    lbra      L226B

L220F               ldd       ,s
                    orb       #$01
                    bra       L2251

L2215               ldd       ,s
                    orb       #$02
                    pshs      d
                    pshs      u
                    lbsr      L334D
                    leas      $04,s
                    std       $02,s
                    cmpd      #$FFFF
                    beq       L2240
                    ldd       #$0002
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L3421
                    leas      $08,s
                    bra       L2285

L2240               ldd       ,s
                    orb       #$0b
                    pshs      d
                    pshs      u
                    lbsr      L336E
                    bra       L2258

L224D               ldd       ,s
                    orb       #$81
L2251               pshs      d
                    pshs      u
                    lbsr      L334D
L2258               leas      $04,s
                    std       $02,s
                    bra       L2285

L225E               leas      -$04,x
L2260               ldd       #$00CB
                    std       $0228,y
                    clra
                    clrb
                    bra       L2287

L226B               cmpx      #$0072
                    lbeq      L220F
                    cmpx      #$0061
                    lbeq      L2215
                    cmpx      #$0077
                    beq       L2240
                    cmpx      #$0064
                    beq       L224D
                    bra       L2260

L2285               ldd       $02,s
L2287               leas      $04,s
                    puls      pc,u
                    pshs      u
                    clra
                    clrb
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbra      L22E7
                    pshs      u
                    ldd       $06,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L21C5
                    leas      $04,s
                    tfr       d,u
                    cmpu      #$FFFF
                    bne       L22B7
                    clra
                    clrb
                    bra       L22EC

L22B7               clra
                    clrb
L22B9               bra       L22DF
                    pshs      u
                    ldd       $08,s
                    pshs      d
                    lbsr      L2B76
                    leas      $02,s
                    ldd       $06,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L21C5
                    leas      $04,s
                    tfr       d,u
                    stu       -$02,s
                    bge       L22DD
                    clra
                    clrb
                    bra       L22EC

L22DD               ldd       $08,s
L22DF               pshs      d
                    ldd       $08,s
                    pshs      d
                    pshs      u
L22E7               lbsr      L216D
                    leas      $06,s
L22EC               puls      pc,u
L22EE               pshs      u
                    leax      $0096,y
                    pshs      x
                    ldd       $06,s
                    pshs      d
                    bsr       L2310
                    leas      $04,s
                    leax      $0096,y
                    pshs      x
                    ldd       #$000D
                    pshs      d
                    lbsr      L2A86
                    leas      $04,s
                    puls      pc,u
L2310               pshs      u
                    ldu       $04,s
                    leas      -$01,s
                    bra       L2326

L2318               ldd       $07,s
                    pshs      d
                    ldb       $02,s
                    sex
                    pshs      d
                    lbsr      L2A86
                    leas      $04,s
L2326               ldb       ,u+
                    stb       ,s
                    bne       L2318
                    leas      $01,s
L232E               puls      pc,u
                    pshs      u
                    ldu       $04,s
                    leas      -$06,s
                    clra
                    clrb
                    bra       L2367

L233A               ldd       $0C,s
                    std       $04,s
                    bra       L2356

L2340               ldd       $10,s
                    pshs      d
                    lbsr      L2C99
                    leas      $02,s
                    std       ,s
                    cmpd      #$FFFF
                    beq       L2370
                    ldd       ,s
                    stb       ,u+
L2356               ldd       $04,s
                    addd      #$FFFF
                    std       $04,s
                    subd      #$FFFF
                    bgt       L2340
                    ldd       $02,s
                    addd      #$0001
L2367               std       $02,s
                    ldd       $02,s
                    cmpd      $0e,s
                    blt       L233A
L2370               ldd       $02,s
                    leas      $06,s
L2374               puls      pc,u
L2376               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    clra
                    clrb
                    bra       L23B1

L2380               clra
                    clrb
                    std       ,s
                    bra       L239D

L2386               ldd       $0e,s
                    pshs      d
                    ldb       ,u+
                    sex
                    pshs      d
                    lbsr      L2A86
                    leas      $04,s
                    ldx       $0e,s
                    ldd       $06,x
                    clra
                    andb      #$20
                    bne       L23BA
L239D               ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    cmpd      $0a,s
                    blt       L2386
                    ldd       $02,s
                    addd      #$0001
L23B1               std       $02,s
                    ldd       $02,s
                    cmpd      $0C,s
                    blt       L2380
L23BA               ldd       $02,s
                    leas      $04,s
                    puls      pc,u
L23C0               pshs      u
                    leax      $0096,y
                    stx       $066d,y
                    leax      $06,s
                    pshs      x
                    ldd       $06,s
L23D0               bra       L23E0

L23D2               pshs      u
                    ldd       $04,s
                    std       $066d,y
                    leax      $08,s
                    pshs      x
                    ldd       $08,s
L23E0               pshs      d
                    leax      L289A,pcr
                    pshs      x
                    bsr       L2412
                    leas      $06,s
                    puls      pc,u
                    pshs      u
                    ldd       $04,s
                    std       $066d,y
                    leax      $08,s
                    pshs      x
                    ldd       $08,s
                    pshs      d
                    leax      L28AD,pcr
                    pshs      x
                    bsr       L2412
                    leas      $06,s
                    clra
                    clrb
                    stb       [$066d,y]
                    ldd       $04,s
                    puls      pc,u
L2412               pshs      u
                    ldu       $06,s
                    leas      -$0b,s
                    bra       L242A

L241A               ldb       $08,s
                    lbeq      L265B
                    ldb       $08,s
                    sex
                    pshs      d
                    jsr       [$11,s]
                    leas      $02,s
L242A               ldb       ,u+
                    stb       $08,s
                    cmpb      #$25
                    bne       L241A
                    ldb       ,u+
                    stb       $08,s
                    clra
                    clrb
                    std       $02,s
                    std       $06,s
                    ldb       $08,s
                    cmpb      #$2d
                    bne       L244F
                    ldd       #$0001
                    std       $0683,y
                    ldb       ,u+
                    stb       $08,s
                    bra       L2455

L244F               clra
                    clrb
                    std       $0683,y
L2455               ldb       $08,s
                    cmpb      #$30
                    bne       L2460
                    ldd       #$0030
                    bra       L2463

L2460               ldd       #$0020
L2463               std       $0685,y
                    bra       L2483

L2469               ldd       $06,s
                    pshs      d
                    ldd       #$000A
                    lbsr      L3182
                    pshs      d
                    ldb       $0a,s
                    sex
                    addd      #$FFD0
                    addd      ,s++
                    std       $06,s
                    ldb       ,u+
                    stb       $08,s
L2483               ldb       $08,s
                    sex
                    leax      $015a,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$08
                    bne       L2469
                    ldb       $08,s
                    cmpb      #$2e
                    bne       L24CC
                    ldd       #$0001
                    std       $04,s
                    bra       L24B6

L24A0               ldd       $02,s
                    pshs      d
                    ldd       #$000A
                    lbsr      L3182
                    pshs      d
                    ldb       $0a,s
                    sex
                    addd      #$FFD0
                    addd      ,s++
                    std       $02,s
L24B6               ldb       ,u+
                    stb       $08,s
                    ldb       $08,s
                    sex
                    leax      $015a,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$08
                    bne       L24A0
                    bra       L24D0

L24CC               clra
                    clrb
                    std       $04,s
L24D0               ldb       $08,s
                    sex
                    tfr       d,x
                    lbra      L25FE

L24D8               ldd       $06,s
                    pshs      d
                    ldx       $15,s
                    leax      $02,x
                    stx       $15,s
                    ldd       -$02,x
                    pshs      d
                    lbsr      L265F
                    bra       L2500

L24ED               ldd       $06,s
                    pshs      d
                    ldx       $15,s
                    leax      $02,x
                    stx       $15,s
                    ldd       -$02,x
                    pshs      d
                    lbsr      L2720
L2500               std       ,s
                    lbra      L25E4

L2505               ldd       $06,s
                    pshs      d
                    ldb       $0a,s
                    sex
                    leax      $015a,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$02
                    pshs      d
                    ldx       $17,s
                    leax      $02,x
                    stx       $17,s
                    ldd       -$02,x
                    pshs      d
                    lbsr      L2766
                    lbra      L25E0

L252B               ldd       $06,s
                    pshs      d
                    ldx       $15,s
                    leax      $02,x
                    stx       $15,s
                    ldd       -$02,x
                    pshs      d
                    leax      $066f,y
                    pshs      x
                    lbsr      L26A7
                    lbra      L25E0

L2547               ldd       $04,s
                    bne       L2550
                    ldd       #$0006
                    std       $02,s
L2550               ldd       $06,s
                    pshs      d
                    leax      $15,s
                    pshs      x
                    ldd       $06,s
                    pshs      d
                    ldb       $0e,s
                    sex
                    pshs      d
                    lbsr      $2EBC
                    leas      $06,s
                    lbra      L25E2

L256A               ldx       $13,s
                    leax      $02,x
                    stx       $13,s
                    ldd       -$02,x
                    lbra      L25F4

L2577               ldx       $13,s
                    leax      $02,x
                    stx       $13,s
                    ldd       -$02,x
                    std       $09,s
                    ldd       $04,s
                    beq       L25BF
                    ldd       $09,s
                    std       $04,s
                    bra       L2599

L258D               ldb       [$09,s]
                    beq       L25A5
                    ldd       $09,s
                    addd      #$0001
                    std       $09,s
L2599               ldd       $02,s
                    addd      #$FFFF
                    std       $02,s
                    subd      #$FFFF
                    bne       L258D
L25A5               ldd       $06,s
                    pshs      d
                    ldd       $0b,s
                    subd      $06,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       $15,s
                    pshs      d
                    lbsr      L27D1
                    leas      $08,s
                    bra       L25EE

L25BF               ldd       $06,s
                    pshs      d
                    ldd       $0b,s
                    bra       L25E2

L25C7               ldb       ,u+
                    stb       $08,s
                    bra       L25CF
                    leas      -$0b,x
L25CF               ldd       $06,s
                    pshs      d
                    leax      $15,s
                    pshs      x
                    ldb       $0C,s
                    sex
                    pshs      d
                    lbsr      L2E7E
L25E0               leas      $04,s
L25E2               pshs      d
L25E4               ldd       $13,s
                    pshs      d
                    lbsr      L2833
                    leas      $06,s
L25EE               lbra      L242A

L25F1               ldb       $08,s
                    sex
L25F4               pshs      d
                    jsr       [$11,s]
                    leas      $02,s
                    lbra      L242A

L25FE               cmpx      #$0064
                    lbeq      L24D8
                    cmpx      #$006F
                    lbeq      L24ED
                    cmpx      #$0078
                    lbeq      L2505
                    cmpx      #$0058
                    lbeq      L2505
                    cmpx      #$0075
                    lbeq      L252B
                    cmpx      #$0066
                    lbeq      L2547
                    cmpx      #$0065
                    lbeq      L2547
                    cmpx      #$0067
                    lbeq      L2547
                    cmpx      #$0045
                    lbeq      L2547
                    cmpx      #$0047
                    lbeq      L2547
                    cmpx      #$0063
                    lbeq      L256A
                    cmpx      #$0073
                    lbeq      L2577
                    cmpx      #$006C
                    lbeq      L25C7
                    bra       L25F1

L265B               leas      $0b,s
                    puls      pc,u
L265F               pshs      u,d
                    leax      $066f,y
                    stx       ,s
                    ldd       $06,s
                    bge       L2693
                    ldd       $06,s
                    nega
                    negb
                    sbca      #$00
                    std       $06,s
                    bge       L2688
                    leax      L28BF,pcr
                    pshs      x
                    leax      $066f,y
                    pshs      x
                    lbsr      L2ED8
                    leas      $04,s
                    puls      pc,u,x
L2688               ldd       #$002D
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
L2693               ldd       $06,s
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    bsr       L26A7
                    leas      $04,s
                    leax      $066f,y
                    tfr       x,d
                    puls      pc,u,x
L26A7               pshs      u,y,x,d
                    ldu       $0a,s
                    clra
                    clrb
                    std       $02,s
                    clra
                    clrb
                    std       ,s
                    bra       L26C4

L26B5               ldd       ,s
                    addd      #$0001
                    std       ,s
                    ldd       $0C,s
                    subd      >$007C,y
                    std       $0C,s
L26C4               ldd       $0C,s
                    blt       L26B5
                    leax      >$007C,y
                    stx       $04,s
                    bra       L2706

L26D0               ldd       ,s
                    addd      #$0001
                    std       ,s
L26D7               ldd       $0C,s
                    subd      [$04,s]
                    std       $0C,s
                    bge       L26D0
                    ldd       $0C,s
                    addd      [$04,s]
                    std       $0C,s
                    ldd       ,s
                    beq       L26F0
                    ldd       #$0001
                    std       $02,s
L26F0               ldd       $02,s
                    beq       L26FB
                    ldd       ,s
                    addd      #$0030
                    stb       ,u+
L26FB               clra
                    clrb
                    std       ,s
                    ldd       $04,s
                    addd      #$0002
                    std       $04,s
L2706               ldd       $04,s
                    cmpd      $0084,y
                    bne       L26D7
                    ldd       $0C,s
                    addd      #$0030
                    stb       ,u+
                    clra
                    clrb
                    stb       ,u
                    ldd       $0a,s
                    leas      $06,s
                    puls      pc,u
L2720               pshs      u,d
                    leax      $066f,y
                    stx       ,s
                    leau      $0679,y
L272C               ldd       $06,s
                    clra
                    andb      #$07
                    addd      #$0030
                    stb       ,u+
                    ldd       $06,s
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    std       $06,s
                    bne       L272C
                    bra       L274E

L2744               ldb       ,u
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
L274E               leau      -$01,u
                    pshs      u
                    leax      $0679,y
                    cmpx      ,s++
                    bls       L2744
                    clra
                    clrb
                    stb       [,s]
                    leax      $066f,y
                    tfr       x,d
                    puls      pc,u,x
L2766               pshs      u,x,d
                    leax      $066f,y
                    stx       $02,s
                    leau      $0679,y
L2772               ldd       $08,s
                    clra
                    andb      #$0f
                    std       ,s
                    pshs      d
                    ldd       $02,s
                    cmpd      #$0009
                    ble       L2794
                    ldd       $0C,s
                    beq       L278C
                    ldd       #$0041
                    bra       L278F

L278C               ldd       #$0061
L278F               addd      #$FFF6
                    bra       L2797

L2794               ldd       #$0030
L2797               addd      ,s++
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
                    bne       L2772
                    bra       L27B7

L27AD               ldb       ,u
                    ldx       $02,s
                    leax      $01,x
                    stx       $02,s
                    stb       -$01,x
L27B7               leau      -$01,u
                    pshs      u
                    leax      $0679,y
                    cmpx      ,s++
                    bls       L27AD
                    clra
                    clrb
                    stb       [$02,s]
                    leax      $066f,y
                    tfr       x,d
                    lbra      L28A9

L27D1               pshs      u
                    ldu       $06,s
                    ldd       $0a,s
                    subd      $08,s
                    std       $0a,s
                    ldd       $0683,y
                    bne       L2806
                    bra       L27EE

L27E3               ldd       $0685,y
                    pshs      d
                    jsr       [$06,s]
                    leas      $02,s
L27EE               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    subd      #$FFFF
                    bgt       L27E3
                    bra       L2806

L27FC               ldb       ,u+
                    sex
                    pshs      d
                    jsr       [$06,s]
                    leas      $02,s
L2806               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bne       L27FC
                    ldd       $0683,y
                    beq       L2831
                    bra       L2825

L281A               ldd       $0685,y
                    pshs      d
                    jsr       [$06,s]
                    leas      $02,s
L2825               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    subd      #$FFFF
                    bgt       L281A
L2831               puls      pc,u
L2833               pshs      u
                    ldu       $06,s
                    ldd       $08,s
                    pshs      d
                    pshs      u
                    lbsr      $2EC7
                    leas      $02,s
                    nega
                    negb
                    sbca      #$00
                    addd      ,s++
                    std       $08,s
                    ldd       $0683,y
                    bne       L2875
                    bra       L285D

L2852               ldd       $0685,y
                    pshs      d
                    jsr       [$06,s]
                    leas      $02,s
L285D               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bgt       L2852
                    bra       L2875

L286B               ldb       ,u+
                    sex
                    pshs      d
                    jsr       [$06,s]
                    leas      $02,s
L2875               ldb       ,u
                    bne       L286B
                    ldd       $0683,y
                    beq       L2898
                    bra       L288C

L2881               ldd       $0685,y
                    pshs      d
                    jsr       [$06,s]
                    leas      $02,s
L288C               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bgt       L2881
L2898               puls      pc,u
L289A               pshs      u
                    ldd       $066d,y
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L2A86
L28A9               leas      $04,s
                    puls      pc,u
L28AD               pshs      u
                    ldd       $04,s
                    ldx       $066d,y
                    leax      $01,x
                    stx       $066d,y
                    stb       -$01,x
                    puls      pc,u
L28BF               blt       L28F4
                    leas      -$09,y
                    pshu      y,x,dp
L28C5               neg       $0034
                    nega
                    ldu       $04,s
                    leas      -$06,s
                    cmpu      #$0000
                    beq       L28D9
                    ldd       $06,u
                    clra
                    andb      #$03
                    bne       L28DF
L28D9               ldd       #$FFFF
                    lbra      L2A02

L28DF               ldd       $06,u
                    anda      #$80
                    clrb
                    std       -$02,s
                    bne       L28F2
                    pshs      u
                    lbsr      L2DEE
                    leas      $02,s
                    lbra      L29C8

L28F2               ldd       $06,u
L28F4               anda      #$01
                    clrb
                    std       -$02,s
                    beq       L2911
                    pshs      u
                    lbsr      L2BAF
                    leas      $02,s
                    ldd       $06,u
                    anda      #$FE
                    std       $06,u
                    ldd       $02,u
                    addd      $0b,u
                    std       $04,u
                    lbra      L29C6

L2911               ldd       ,u
                    cmpd      $04,u
                    lbcc      L29C8
                    leax      $02,s
                    pshs      x
                    leax      $0e,s
                    lbsr      L314E
                    ldx       $10,s
                    lbra      L2995

L2929               leax      $02,s
                    pshs      x
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    pshs      u
                    lbsr      L2A1D
                    leas      $02,s
                    lbsr      L30D5
                    lbsr      L314E
L2942               ldd       $0b,u
                    lbsr      L3135
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    leax      $06,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    bsr       L295F
                    neg       $0000
                    neg       $0000
L295F               puls      x
                    lbsr      L30EA
                    bge       L296D
                    leax      $06,s
                    lbsr      L310E
                    bra       L296F

L296D               leax      $06,s
L296F               lbsr      L30EA
                    blt       L29A2
                    ldd       $04,s
                    addd      ,u
                    std       ,s
                    cmpd      $02,u
                    bcs       L29A2
                    ldd       ,s
                    cmpd      $04,u
                    bcc       L29A2
                    ldd       ,s
                    std       ,u
                    ldd       $06,u
                    andb      #$EF
                    std       $06,u
                    lbra      L2A00
                    bra       L29A2

L2995               stx       -$02,s
                    lbeq      L2929
                    cmpx      #$0001
                    lbeq      L2942
L29A2               ldd       $10,s
                    cmpd      #$0001
                    bne       L29C4
                    leax      $0C,s
                    pshs      x
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $04,u
                    subd      ,u
                    lbsr      L3135
                    lbsr      L30D5
                    lbsr      L314E
L29C4               ldd       $04,u
L29C6               std       ,u
L29C8               ldd       $06,u
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
                    lbsr      L3421
                    leas      $08,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    bsr       $29F4
                    stu       $FFFF
                    stu       $3510
                    lbsr      L30EA
                    bne       L2A00
                    ldd       #$FFFF
                    bra       L2A02

L2A00               clra
                    clrb
L2A02               leas      $06,s
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
                    lbsr      $28C6
                    leas      $08,s
L2A1B               puls      pc,u
L2A1D               pshs      u
                    ldu       $04,s
                    beq       L2A2A
                    ldd       $06,u
                    clra
                    andb      #$03
                    bne       L2A3D
L2A2A               bsr       $2A30
                    stu       $FFFF
                    stu       $3510
                    leau      $021C,y
                    pshs      u
                    lbsr      L314E
                    puls      pc,u
L2A3D               ldd       $06,u
                    anda      #$80
                    clrb
                    std       -$02,s
                    bne       L2A4D
                    pshs      u
                    lbsr      L2DEE
                    leas      $02,s
L2A4D               ldd       #$0001
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L3421
                    leas      $08,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    beq       L2A76
                    ldd       $02,u
                    bra       L2A78

L2A76               ldd       $04,u
L2A78               pshs      d
                    ldd       ,u
                    subd      ,s++
                    lbsr      L3135
                    lbsr      L30C0
L2A84               puls      pc,u
L2A86               pshs      u
                    ldu       $06,s
                    ldd       $06,u
                    anda      #$80
                    andb      #$22
                    cmpd      #$8002
                    beq       L2AAA
                    ldd       $06,u
                    clra
                    andb      #$22
                    cmpd      #$0002
                    lbne      L2BC0
                    pshs      u
                    lbsr      L2DEE
                    leas      $02,s
L2AAA               ldd       $06,u
                    clra
                    andb      #$04
                    beq       L2AE6
                    ldd       #$0001
                    pshs      d
                    leax      $07,s
                    pshs      x
                    ldd       $08,u
                    pshs      d
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L2ACB
                    leax      L3411,pcr
                    bra       L2ACF

L2ACB               leax      L33F8,pcr
L2ACF               tfr       x,d
                    tfr       d,x
                    jsr       ,x
                    leas      $06,s
                    cmpd      #$FFFF
                    bne       L2B27
                    ldd       $06,u
                    orb       #$20
                    std       $06,u
                    lbra      L2BC0

L2AE6               ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       L2AF6
                    pshs      u
                    lbsr      L2BDB
                    leas      $02,s
L2AF6               ldd       ,u
                    addd      #$0001
                    std       ,u
                    subd      #$0001
                    tfr       d,x
                    ldd       $04,s
                    stb       ,x
                    ldd       ,u
                    cmpd      $04,u
                    bcc       L2B1C
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L2B27
                    ldd       $04,s
                    cmpd      #$000D
                    bne       L2B27
L2B1C               pshs      u
                    lbsr      L2BDB
                    std       ,s++
                    lbne      L2BC0
L2B27               ldd       $04,s
L2B29               puls      pc,u
                    pshs      u
                    ldu       $04,s
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    ldd       #$0008
                    lbsr      L32AC
                    pshs      d
                    lbsr      L2A86
                    leas      $04,s
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    lbsr      L2A86
                    lbra      L2C95

L2B4E               pshs      u,d
                    leau      $0089,y
                    clra
                    clrb
                    std       ,s
                    bra       L2B64

L2B5A               tfr       u,d
                    leau      $0d,u
                    pshs      d
                    bsr       L2B76
                    leas      $02,s
L2B64               ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    cmpd      #$0010
                    blt       L2B5A
L2B74               puls      pc,u,x
L2B76               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    cmpu      #$0000
                    beq       L2B86
                    ldd       $06,u
                    bne       L2B8B
L2B86               ldd       #$FFFF
                    puls      pc,u,x
L2B8B               ldd       $06,u
                    clra
                    andb      #$02
                    beq       L2B9A
                    pshs      u
                    bsr       L2BAF
                    leas      $02,s
                    bra       L2B9C

L2B9A               clra
                    clrb
L2B9C               std       ,s
                    ldd       $08,u
                    pshs      d
                    lbsr      L335C
                    leas      $02,s
                    clra
                    clrb
                    std       $06,u
                    ldd       ,s
                    puls      pc,u,x
L2BAF               pshs      u
                    ldu       $04,s
                    beq       L2BC0
                    ldd       $06,u
                    clra
                    andb      #$22
                    cmpd      #$0002
                    beq       L2BC5
L2BC0               ldd       #$FFFF
                    puls      pc,u
L2BC5               ldd       $06,u
                    anda      #$80
                    clrb
                    std       -$02,s
                    bne       L2BD5
                    pshs      u
                    lbsr      L2DEE
                    leas      $02,s
L2BD5               pshs      u
                    bsr       L2BDB
                    puls      pc,u,x
L2BDB               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       L2C0D
                    ldd       ,u
                    cmpd      $04,u
                    beq       L2C0D
                    clra
                    clrb
                    pshs      d
                    pshs      u
                    lbsr      L2A1D
                    leas      $02,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L3421
                    leas      $08,s
L2C0D               ldd       ,u
                    subd      $02,u
                    std       $02,s
                    lbeq      L2C85
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    lbeq      L2C85
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L2C5C
                    ldd       $02,u
                    bra       L2C54

L2C2D               ldd       $02,s
                    pshs      d
                    ldd       ,u
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L3411
                    leas      $06,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       L2C4A
                    leax      $04,s
                    bra       L2C74

L2C4A               ldd       $02,s
                    subd      ,s
                    std       $02,s
                    ldd       ,u
                    addd      ,s
L2C54               std       ,u
                    ldd       $02,s
                    bne       L2C2D
                    bra       L2C85

L2C5C               ldd       $02,s
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L33F8
                    leas      $06,s
                    cmpd      $02,s
                    beq       L2C85
                    bra       L2C76

L2C74               leas      -$04,x
L2C76               ldd       $06,u
                    orb       #$20
                    std       $06,u
                    ldd       $04,u
                    std       ,u
                    ldd       #$FFFF
                    bra       L2C95

L2C85               ldd       $06,u
                    ora       #$01
                    std       $06,u
                    ldd       $02,u
                    std       ,u
                    addd      $0b,u
                    std       $04,u
                    clra
                    clrb
L2C95               leas      $04,s
L2C97               puls      pc,u
L2C99               pshs      u
                    ldu       $04,s
                    beq       L2CE5
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       L2CE5
                    ldd       ,u
                    cmpd      $04,u
                    bcc       L2CC0
                    ldd       ,u
                    addd      #$0001
                    std       ,u
                    subd      #$0001
                    tfr       d,x
                    ldb       ,x
                    clra
                    bra       L2CC7

L2CC0               pshs      u
                    lbsr      L2D34
                    leas      $02,s
L2CC7               puls      pc,u
                    pshs      u
                    ldu       $06,s
                    beq       L2CE5
                    ldd       $06,u
                    clra
                    andb      #$01
                    beq       L2CE5
                    ldd       $04,s
                    cmpd      #$FFFF
                    beq       L2CE5
                    ldd       ,u
                    cmpd      $02,u
                    bhi       L2CEA
L2CE5               ldd       #$FFFF
                    puls      pc,u
L2CEA               ldd       ,u
                    addd      #$FFFF
                    std       ,u
                    tfr       d,x
                    ldd       $04,s
                    stb       ,x
                    ldd       $04,s
L2CF9               puls      pc,u
                    pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    pshs      u
                    lbsr      L2C99
                    leas      $02,s
                    std       $02,s
                    cmpd      #$FFFF
                    beq       L2D1F
                    pshs      u
                    lbsr      L2C99
                    leas      $02,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       L2D24
L2D1F               ldd       #$FFFF
                    bra       L2D30

L2D24               ldd       $02,s
                    pshs      d
                    ldd       #$0008
                    lbsr      L32C3
                    addd      ,s
L2D30               leas      $04,s
                    puls      pc,u
L2D34               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    ldd       $06,u
                    anda      #$80
                    andb      #$31
                    cmpd      #$8001
                    beq       L2D5D
                    ldd       $06,u
                    clra
                    andb      #$31
                    cmpd      #$0001
                    beq       L2D56
                    ldd       #$FFFF
                    puls      pc,u,x
L2D56               pshs      u
                    lbsr      L2DEE
                    leas      $02,s
L2D5D               leax      $0089,y
                    pshs      x
                    cmpu      ,s++
                    bne       L2D7A
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L2D7A
                    leax      $0096,y
                    pshs      x
                    lbsr      L2BAF
                    leas      $02,s
L2D7A               ldd       $06,u
                    clra
                    andb      #$08
                    beq       L2DA6
                    ldd       $0b,u
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L2D9A
                    leax      L33E8,pcr
                    bra       L2D9E

L2D9A               leax      L33C7,pcr
L2D9E               tfr       x,d
                    tfr       d,x
                    jsr       ,x
                    bra       L2DB8

L2DA6               ldd       #$0001
                    pshs      d
                    leax      $0a,u
                    stx       $02,u
                    pshs      x
                    ldd       $08,u
                    pshs      d
                    lbsr      L33C7
L2DB8               leas      $06,s
                    std       ,s
                    ldd       ,s
                    bgt       L2DDB
                    ldd       $06,u
                    pshs      d
                    ldd       $02,s
                    beq       L2DCD
                    ldd       #$0020
                    bra       L2DD0

L2DCD               ldd       #$0010
L2DD0               ora       ,s+
                    orb       ,s+
                    std       $06,u
                    ldd       #$FFFF
                    puls      pc,u,x
L2DDB               ldd       $02,u
                    addd      #$0001
                    std       ,u
                    ldd       $02,u
                    addd      ,s
                    std       $04,u
                    ldb       [$02,u]
                    clra
                    puls      pc,u,x
L2DEE               pshs      u
                    ldu       $04,s
                    ldd       $06,u
                    clra
                    andb      #$C0
                    bne       L2E26
                    leas      -$20,s
                    leax      ,s
                    pshs      x
                    ldd       $08,u
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    lbsr      L32DE
                    leas      $06,s
                    ldd       $06,u
                    pshs      d
                    ldb       $02,s
                    bne       L2E1A
                    ldd       #$0040
                    bra       L2E1D

L2E1A               ldd       #$0080
L2E1D               ora       ,s+
                    orb       ,s+
                    std       $06,u
                    leas      $20,s
L2E26               ldd       $06,u
                    ora       #$80
                    std       $06,u
                    clra
                    andb      #$0C
                    beq       L2E33
                    puls      pc,u
L2E33               ldd       $0b,u
                    bne       L2E48
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L2E43
                    ldd       #$0080
                    bra       L2E46

L2E43               ldd       #$0100
L2E46               std       $0b,u
L2E48               ldd       $02,u
                    bne       L2E5D
                    ldd       $0b,u
                    pshs      d
                    lbsr      L3511
                    leas      $02,s
                    std       $02,u
                    cmpd      #$FFFF
                    beq       L2E65
L2E5D               ldd       $06,u
                    orb       #$08
                    std       $06,u
                    bra       L2E74

L2E65               ldd       $06,u
                    orb       #$04
                    std       $06,u
                    leax      $0a,u
                    stx       $02,u
                    ldd       #$0001
                    std       $0b,u
L2E74               ldd       $02,u
                    addd      $0b,u
                    std       $04,u
                    std       ,u
                    puls      pc,u
L2E7E               pshs      u
                    ldb       $05,s
                    sex
                    tfr       d,x
                    bra       L2EA4

L2E87               ldd       [$06,s]
                    addd      #$0004
                    std       [$06,s]
                    leax      >L2EBB,pcr
                    bra       L2EA0

L2E96               ldb       $05,s
                    stb       $0087,y
                    leax      $0086,y
L2EA0               tfr       x,d
                    puls      pc,u
L2EA4               cmpx      #$0064
                    beq       L2E87
                    cmpx      #$006F
                    lbeq      L2E87
                    cmpx      #$0078
                    lbeq      L2E87
                    bra       L2E96
                    puls      pc,u
L2EBB               neg       $0034
                    nega
                    leax      >L2EC6,pcr
                    tfr       x,d
                    puls      pc,u
L2EC6               neg       $0034
                    nega
                    ldu       $04,s
L2ECB               ldb       ,u+
                    bne       L2ECB
                    tfr       u,d
                    subd      $04,s
                    addd      #$FFFF
L2ED6               puls      pc,u
L2ED8               pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
L2EE2               ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L2EE2
                    ldd       $06,s
                    puls      pc,u,x
                    pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
L2EFC               ldx       ,s
                    leax      $01,x
                    stx       ,s
                    ldb       -$01,x
                    bne       L2EFC
                    ldd       ,s
                    addd      #$FFFF
                    std       ,s
L2F0D               ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L2F0D
                    ldd       $06,s
                    puls      pc,u,x
                    pshs      u
                    ldu       $04,s
                    bra       L2F33

L2F23               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    bne       L2F31
                    clra
                    clrb
                    puls      pc,u
L2F31               leau      $01,u
L2F33               ldb       ,u
                    sex
                    pshs      d
                    ldb       [$08,s]
                    sex
                    cmpd      ,s++
                    beq       L2F23
                    ldb       [$06,s]
                    sex
                    pshs      d
                    ldb       ,u
                    sex
                    subd      ,s++
L2F4C               puls      pc,u
                    pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
L2F58               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    subd      #$FFFF
                    ble       L2F7C
                    ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L2F58
                    bra       L2F7C

L2F72               clra
                    clrb
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
L2F7C               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    subd      #$FFFF
                    bgt       L2F72
                    ldd       $06,s
                    puls      pc,u,x
                    pshs      u
                    ldu       $04,s
                    bra       L2FA2

L2F92               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    bne       L2FA0
                    clra
                    clrb
                    puls      pc,u
L2FA0               leau      $01,u
L2FA2               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    ble       L2FBC
                    ldb       ,u
                    sex
                    pshs      d
                    ldb       [$08,s]
                    sex
                    cmpd      ,s++
                    beq       L2F92
L2FBC               ldd       $08,s
                    bge       L2FC4
                    clra
                    clrb
                    bra       L2FCF

L2FC4               ldb       [$06,s]
                    sex
                    pshs      d
                    ldb       ,u
                    sex
                    subd      ,s++
L2FCF               puls      pc,u
                    pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
L2FDB               ldx       ,s
                    leax      $01,x
                    stx       ,s
                    ldb       -$01,x
                    bne       L2FDB
                    ldd       ,s
                    addd      #$FFFF
                    std       ,s
L2FEC               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    subd      #$FFFF
                    ble       L3004
                    ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L2FEC
L3004               ldd       $0a,s
                    bge       L300C
                    clra
                    clrb
                    stb       [,s]
L300C               ldd       $06,s
                    puls      pc,u,x
                    pshs      u
                    ldu       $04,s
L3014               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    stb       ,u+
                    bgt       L3014
                    ldb       -$01,u
                    clra
                    andb      #$7f
                    stb       -$01,u
                    clra
                    clrb
                    stb       ,u
                    ldd       $04,s
L302D               puls      pc,u
                    pshs      u
                    ldu       $04,s
                    leas      -$05,s
                    clra
                    clrb
                    std       $01,s
L3039               ldb       ,u+
                    stb       ,s
                    cmpb      #$20
                    beq       L3039
                    ldb       ,s
                    cmpb      #$09
                    lbeq      L3039
                    ldb       ,s
                    cmpb      #$2d
                    bne       L3054
                    ldd       #$0001
                    bra       L3056

L3054               clra
                    clrb
L3056               std       $03,s
                    ldb       ,s
                    cmpb      #$2d
                    beq       L307C
                    ldb       ,s
                    cmpb      #$2b
                    bne       L3080
                    bra       L307C

L3066               ldd       $01,s
                    pshs      d
                    ldd       #$000A
                    lbsr      L3182
                    pshs      d
                    ldb       $02,s
                    sex
                    addd      ,s++
                    addd      #$FFD0
                    std       $01,s
L307C               ldb       ,u+
                    stb       ,s
L3080               ldb       ,s
                    sex
                    leax      $015a,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$08
                    bne       L3066
                    ldd       $03,s
                    beq       L309C
                    ldd       $01,s
                    nega
                    negb
                    sbca      #$00
                    bra       L309E

L309C               ldd       $01,s
L309E               leas      $05,s
L30A0               puls      pc,u
                    pshs      u
                    ldu       $04,s
                    bra       L30B2

L30A8               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    stb       ,u+
L30B2               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bgt       L30A8
L30BE               puls      pc,u
L30C0               ldd       $04,s
                    addd      $02,x
                    std       $021e,y
                    ldd       $02,s
                    adcb      $01,x
                    adca      ,x
                    std       $021C,y
                    lbra      L3164

L30D5               ldd       $04,s
                    subd      $02,x
                    std       $021e,y
                    ldd       $02,s
                    sbcb      $01,x
                    sbca      ,x
                    std       $021C,y
                    lbra      L3164

L30EA               ldd       $02,s
                    cmpd      ,x
                    bne       L3103
                    ldd       $04,s
                    cmpd      $02,x
                    beq       L3103
                    bcs       L3100
                    lda       #$01
                    andcc     #$FE
                    bra       L3103

L3100               clra
                    cmpa      #$01
L3103               pshs      cc
                    ldd       $01,s
                    std       $05,s
                    puls      cc
                    leas      $04,s
                    rts

L310E               lbsr      L3173
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
                    std       $021C,y
                    ldd       $02,x
                    coma
                    comb
                    leax      $021C,y
                    std       $02,x
                    rts

L3135               leax      $021C,y
                    std       $02,x
                    tfr       a,b
                    sex
                    tfr       a,b
                    std       ,x
L3142               rts
                    leax      $021C,y
                    std       $02,x
                    clr       ,x
                    clr       $01,x
L314D               rts

L314E               pshs      y
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

L3164               tfr       cc,a
                    puls      x
                    stx       $02,s
                    leas      $02,s
                    leax      $021C,y
                    tfr       a,cc
                    rts

L3173               ldd       ,x
                    std       $021C,y
                    ldd       $02,x
                    leax      $021C,y
                    std       $02,x
L3181               rts

L3182               tsta
                    bne       L3197
                    tst       $02,s
                    bne       L3197
                    lda       $03,s
                    mul
                    ldx       ,s
                    stx       $02,s
                    ldx       #$0000
                    std       ,s
                    puls      pc,d
L3197               pshs      d
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
                    bcc       L31B4
                    inc       ,s
L31B4               lda       $04,s
                    ldb       $09,s
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L31C1
                    inc       ,s
L31C1               lda       $04,s
                    ldb       $08,s
                    mul
                    addd      ,s
                    std       ,s
                    ldx       $06,s
                    stx       $08,s
                    ldx       ,s
                    ldd       $02,s
                    leas      $08,s
L31D4               rts
                    clr       $0687,y
                    leax      >L321D,pcr
                    stx       $0688,y
                    bra       L31F7
                    leax      >L3236,pcr
                    stx       $0688,y
                    clr       $0687,y
                    tst       $02,s
                    bpl       L31F7
                    inc       $0687,y
L31F7               subd      #$0000
                    bne       L3202
                    puls      x
                    ldd       ,s++
                    jmp       ,x

L3202               ldx       $02,s
                    pshs      x
                    jsr       [$0688,y]
                    ldd       ,s
                    std       $02,s
                    tfr       x,d
                    tst       $0687,y
                    beq       L321A
                    nega
                    negb
                    sbca      #$00
L321A               std       ,s++
                    rts

L321D               subd      #$0000
                    beq       L322C
                    pshs      d
                    leas      -$02,s
                    clr       ,s
                    clr       $01,s
                    bra       L325A

L322C               puls      d
                    std       ,s
                    ldd       #$002D
                    lbra      L32CF

L3236               subd      #$0000
                    beq       L322C
                    pshs      d
                    leas      -$02,s
                    clr       ,s
                    clr       $01,s
                    tsta
                    bpl       L324E
                    nega
                    negb
                    sbca      #$00
                    inc       $01,s
                    std       $02,s
L324E               ldd       $06,s
                    bpl       L325A
                    nega
                    negb
                    sbca      #$00
                    com       $01,s
                    std       $06,s
L325A               lda       #$01
L325C               inca
                    asl       $03,s
                    rol       $02,s
                    bpl       L325C
                    sta       ,s
                    ldd       $06,s
                    clr       $06,s
                    clr       $07,s
L326B               subd      $02,s
                    bcc       L3275
                    addd      $02,s
                    andcc     #$FE
                    bra       L3277

L3275               orcc      #$01
L3277               rol       $07,s
                    rol       $06,s
                    lsr       $02,s
                    ror       $03,s
                    dec       ,s
                    bne       L326B
                    std       $02,s
                    tst       $01,s
                    beq       L3291
                    ldd       $06,s
                    nega
                    negb
                    sbca      #$00
                    std       $06,s
L3291               ldx       $04,s
                    ldd       $06,s
                    std       $04,s
                    stx       $06,s
                    ldx       $02,s
                    ldd       $04,s
                    leas      $06,s
                    rts
                    tstb
                    beq       L32B6
L32A3               asr       $02,s
                    ror       $03,s
                    decb
                    bne       L32A3
                    bra       L32B6

L32AC               tstb
                    beq       L32B6
L32AF               lsr       $02,s
                    ror       $03,s
                    decb
                    bne       L32AF
L32B6               ldd       $02,s
                    pshs      d
                    ldd       $02,s
                    std       $04,s
                    ldd       ,s
                    leas      $04,s
L32C2               rts

L32C3               tstb
                    beq       L32B6
L32C6               asl       $03,s
                    rol       $02,s
                    decb
                    bne       L32C6
                    bra       L32B6

L32CF               std       $0228,y
                    pshs      y,b
                    os9       F$ID
                    puls      y,b
                    os9       F$Send
                    rts

L32DE               lda       $05,s
                    ldb       $03,s
                    beq       L3311
                    cmpb      #$01
                    beq       L3313
                    cmpb      #$06
                    beq       L3313
                    cmpb      #$02
                    beq       L32F9
                    cmpb      #$05
                    beq       L32F9
                    ldb       #$D0
                    lbra      L3560

L32F9               pshs      u
                    os9       I$GetStt
                    bcc       L3305
                    puls      u
                    lbra      L3560

L3305               stx       [$08,s]
                    ldx       $08,s
                    stu       $02,x
                    puls      u
                    clra
                    clrb
                    rts

L3311               ldx       $06,s
L3313               os9       I$GetStt
                    lbra      L3569
                    lda       $05,s
                    ldb       $03,s
                    beq       L3328
                    cmpb      #$02
                    beq       L3330
                    ldb       #$D0
                    lbra      L3560

L3328               ldx       $06,s
                    os9       I$SetStt
                    lbra      L3569

L3330               pshs      u
                    ldx       $08,s
                    ldu       $0a,s
                    os9       I$SetStt
                    puls      u
                    lbra      L3569
                    ldx       $02,s
                    lda       $05,s
                    os9       I$Open
                    bcs       L334A
                    os9       I$Close
L334A               lbra      L3569

L334D               ldx       $02,s
                    lda       $05,s
                    os9       I$Open
                    lbcs      L3560
                    tfr       a,b
                    clra
                    rts

L335C               lda       $03,s
                    os9       I$Close
                    lbra      L3569
                    ldx       $02,s
                    ldb       $05,s
                    os9       I$MakDir
                    lbra      L3569

L336E               ldx       $02,s
                    ldb       $05,s
                    tfr       b,a
                    anda      #$07
                    os9       I$Create
                    bcs       L337F
L337B               tfr       a,b
                    clra
                    rts

L337F               cmpb      #$DA
                    lbne      L3560
                    lda       $05,s
                    bita      #$80
                    lbne      L3560
                    anda      #$07
                    ldx       $02,s
                    os9       I$Open
                    lbcs      L3560
                    pshs      u,a
                    ldx       #$0000
                    leau      ,x
                    ldb       #$02
                    os9       I$SetStt
                    puls      u,a
                    bcc       L337B
                    pshs      b
                    os9       I$Close
                    puls      b
                    lbra      L3560

L33B2               ldx       $02,s
                    os9       I$Delete
                    lbra      L3569
                    lda       $03,s
                    os9       I$Dup
                    lbcs      L3560
                    tfr       a,b
                    clra
                    rts

L33C7               pshs      y
                    ldx       $06,s
                    lda       $05,s
                    ldy       $08,s
                    pshs      y
                    os9       I$Read
L33D5               bcc       L33E4
                    cmpb      #$D3
                    bne       L33DF
                    clra
                    clrb
                    puls      pc,y,x
L33DF               puls      y,x
                    lbra      L3560

L33E4               tfr       y,d
                    puls      pc,y,x
L33E8               pshs      y
                    lda       $05,s
                    ldx       $06,s
                    ldy       $08,s
                    pshs      y
                    os9       I$ReadLn
                    bra       L33D5

L33F8               pshs      y
                    ldy       $08,s
                    beq       L340D
                    lda       $05,s
                    ldx       $06,s
                    os9       I$Write
L3406               bcc       L340D
                    puls      y
                    lbra      L3560

L340D               tfr       y,d
                    puls      pc,y
L3411               pshs      y
                    ldy       $08,s
                    beq       L340D
                    lda       $05,s
                    ldx       $06,s
                    os9       I$WritLn
                    bra       L3406

L3421               pshs      u
                    ldd       $0a,s
                    bne       L342F
                    ldu       #$0000
                    ldx       #$0000
                    bra       L3463

L342F               cmpd      #$0001
                    beq       L345A
                    cmpd      #$0002
                    beq       L344F
                    ldb       #$F7
L343D               clra
                    std       $0228,y
                    ldd       #$FFFF
                    leax      $021C,y
                    std       ,x
                    std       $02,x
                    puls      pc,u
L344F               lda       $05,s
                    ldb       #$02
                    os9       I$GetStt
                    bcs       L343D
                    bra       L3463

L345A               lda       $05,s
                    ldb       #$05
                    os9       I$GetStt
                    bcs       L343D
L3463               tfr       u,d
                    addd      $08,s
                    std       $021e,y
                    tfr       d,u
                    tfr       x,d
                    adcb      $07,s
                    adca      $06,s
                    bmi       L343D
                    tfr       d,x
                    std       $021C,y
                    lda       $05,s
                    os9       I$Seek
                    bcs       L343D
                    leax      $021C,y
                    puls      pc,u
                    rts
                    ldx       #$0000
                    clrb
                    os9       F$Sleep
                    lbra      L3560

L3493               rts

L3494               pshs      u,y
                    ldx       $06,s
                    ldy       $08,s
                    ldu       $0a,s
                    os9       F$CRC
                    puls      pc,u,y
                    lda       $03,s
                    ldb       $05,s
                    os9       F$Perr
                    lbcs      L3560
                    rts
                    ldx       $02,s
                    os9       F$Sleep
                    lbcs      L3560
                    tfr       x,d
L34B9               rts
                    ldd       $021a,y
                    pshs      d
                    ldd       $04,s
                    cmpd      $068a,y
                    bcs       L34EE
                    addd      $021a,y
                    pshs      y
                    subd      ,s
                    os9       F$Mem
                    tfr       y,d
                    puls      y
                    bcc       L34E0
                    ldd       #$FFFF
                    leas      $02,s
                    rts

L34E0               std       $021a,y
                    addd      $068a,y
                    subd      ,s
                    std       $068a,y
L34EE               leas      $02,s
                    ldd       $068a,y
                    pshs      d
                    subd      $04,s
                    std       $068a,y
                    ldd       $021a,y
                    subd      ,s++
                    pshs      d
                    clra
                    ldx       ,s
L3507               sta       ,x+
                    cmpx      $021a,y
                    bcs       L3507
                    puls      pc,d
L3511               ldd       $02,s
                    addd      $0224,y
                    bcs       L353A
                    cmpd      $0226,y
                    bcc       L353A
                    pshs      d
                    ldx       $0224,y
                    clra
L3527               cmpx      ,s
                    bcc       L352F
                    sta       ,x+
                    bra       L3527

L352F               ldd       $0224,y
                    puls      x
                    stx       $0224,y
                    rts

L353A               ldd       #$FFFF
                    rts
                    pshs      u
                    tfr       y,u
                    ldx       $04,s
                    stx       $068C,y
                    leax      >L3554,pcr
                    os9       F$Icpt
                    puls      u
                    lbra      L3569

L3554               tfr       u,y
                    clra
                    pshs      d
                    jsr       [$068C,y]
                    leas      $02,s
                    rti

L3560               clra
                    std       $0228,y
                    ldd       #$FFFF
L3568               rts

L3569               bcs       L3560
L356B               clra
                    clrb
L356D               rts

L356E               lbsr      L3579
L3571               lbsr      L2B4E
                    ldd       $02,s
                    os9       F$Exit
L3579               rts
                    neg       $000A
                    neg       $0000
                    neg       $0004
                    neg       $00FF
                    stu       $FF02
                    asr       L017A
                    neg       $0060
                    neg       $0060
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    tst       $00C1
                    tst       $00C7
                    tst       $00CD
                    tst       $00D1
                    tst       $00D7
                    fcb       $02
                    asr       $2710
                    com       $00E8
                    neg       $0064
                    neg       $000A
                    neg       L0084
                    inc       -$08,s
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    fcb       $01
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
                    neg       $0001
                    fcb       $01
                    fcb       $01
                    fcb       $01
                    fcb       $01
                    fcb       $01
                    fcb       $01
                    fcb       $01
                    fcb       $01
                    fcb       $11
                    fcb       $11
                    fcb       $01
                    fcb       $11
                    fcb       $11
                    fcb       $01
                    fcb       $01
                    fcb       $01
                    fcb       $01
                    fcb       $01
                    fcb       $01
                    fcb       $01
                    fcb       $01
                    fcb       $01
                    fcb       $01
                    fcb       $01
                    fcb       $01
                    fcb       $01
                    fcb       $01
                    fcb       $01
                    fcb       $01
                    fcb       $01
                    fcb       $01
                    leax      0,y
                    bra       L36C6
                    bra       L36C8
                    bra       L36CA
                    bra       L36CC
                    bra       L36CE
                    bra       L36D0
                    bra       L36D2
                    asla
                    asla
                    asla
                    asla
                    asla
                    asla
                    asla
                    asla
                    asla
                    asla
                    bra       $36DE
                    bra       $36E0
                    bra       $36E2
                    bra       L3706
                    fcb       $42
                    fcb       $42
L36C6               fcb       $42
                    fcb       $42
L36C8               fcb       $42
                    fcb       $02
L36CA               fcb       $02
                    fcb       $02
L36CC               fcb       $02
                    fcb       $02
L36CE               fcb       $02
                    fcb       $02
L36D0               fcb       $02
                    fcb       $02
L36D2               fcb       $02
                    fcb       $02
                    fcb       $02
                    fcb       $02
                    fcb       $02
                    fcb       $02
                    fcb       $02
                    fcb       $02
                    fcb       $02
                    fcb       $02
                    fcb       $02
                    bra       L36FF
                    bra       L3701
                    bra       $3703
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra
                    lsr       $0004
                    lsr       $0004
                    lsr       $0004
                    lsr       $0004
                    lsr       $0004
                    lsr       $0004
                    lsr       $0004
                    lsr       $0004
                    lsr       $0004
                    lsr       $0004
                    bra       $371F

L36FF               bra       $3721
L3701               fcb       $01
                    neg       $0005
                    neg       L0078
L3706               neg       $0076
                    neg       $0074
                    neg       $0072
                    neg       L0070
                    neg       $0005
                    neg       $0062
                    neg       $0060
                    neg       $007A
                    neg       $0008
                    neg       L0084
                    com       $0e,y
                    inc       $09,s

                    emod
eom                 equ       *
                    end
