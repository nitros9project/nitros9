                    nam       c.pass2
                    ttl       program module

                    use       defsfile

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       $05

                    mod       eom,name,tylg,atrv,_start,size

u0000               rmb       3431
size                equ       .

name                equ       *
                    fcs       /c.pass2/
                    fcb       edition

copybytes           lda       ,y+
L0017               sta       ,u+
L0019               leax      -$01,x
L001B               bne       copybytes
L001D               rts

_start              pshs      y
L0020               pshs      u
L0022               clra
L0023               clrb
L0024               sta       ,u+
                    decb
L0027               bne       L0024
L0029               ldx       ,s
L002B               leau      ,x
L002D               leax      $02E7,x
                    pshs      x
L0033               leay      $6235,pcr
L0037               ldx       ,y++
                    beq       L003F
                    bsr       copybytes
L003D               ldu       $02,s
L003F               leau      >$0027,u
L0043               ldx       ,y++
L0045               beq       L004A
L0047               bsr       copybytes
                    clra
L004A               cmpu      ,s
L004D               beq       L0053
L004F               sta       ,u+
L0051               bra       L004A

L0053               ldu       $02,s
L0055               ldd       ,y++
L0057               beq       L0060
L0059               leax      >$0000,pcr
L005D               lbsr      L0163
L0060               ldd       ,y++
L0062               beq       L0069
L0064               leax      ,u
L0066               lbsr      L0163
L0069               leas      $04,s
                    puls      x
                    stx       $0252,u
L0071               sty       $0212,u
L0076               ldd       #$0001
L0079               std       $024e,u
L007D               leay      $0214,u
L0081               leax      ,s
L0083               lda       ,x+
L0085               ldb       $024f,u
L0089               cmpb      #$1d
L008B               beq       L00E1
L008D               cmpa      #$0d
L008F               beq       L00E1
L0091               cmpa      #$20
L0093               beq       L0099
L0095               cmpa      #$2C
L0097               bne       L009D
L0099               lda       ,x+
L009B               bra       L008D

L009D               cmpa      #$22
                    beq       L00A5
L00A1               cmpa      #$27
                    bne       L00C3
L00A5               stx       ,y++
L00A7               inc       $024f,u
                    pshs      a
L00AD               lda       ,x+
                    cmpa      #$0d
                    beq       L00B7
                    cmpa      ,s
                    bne       L00AD
L00B7               puls      b
                    clr       -$01,x
L00BB               cmpa      #$0d
                    beq       L00E1
                    lda       ,x+
                    bra       L0085

L00C3               leax      -$01,x
                    stx       ,y++
                    leax      $01,x
                    inc       $024f,u
L00CD               cmpa      #$0d
                    beq       L00DD
                    cmpa      #$20
                    beq       L00DD
                    cmpa      #$2C
                    beq       L00DD
                    lda       ,x+
                    bra       L00CD

L00DD               clr       -$01,x
                    bra       L0085

* ------------------------------------------------------------------
* SPURIOUS $00 below (defect in the c.pass2 FCB source, same as c.pass1).
* cstart.a's real crt0 loads 'ldd argc,u' (EC C9 02 4E); the stray $00
* makes it 'ldd 0,x' + 'adcb #2' (EC 00 C9 02 ..).  Here the trailing $4E
* is an undefined 1-byte opcode, so the decode re-syncs at 'pshs d' and
* 'lbsr main' survives.  Bytes below are byte-faithful to the defective
* FCB; the genuine binary uses the clean 'ldd argc,u' form.
* ------------------------------------------------------------------
L00E1               leax      $0212,u
                    pshs      x
                    ldd       0,x
                    adcb      #$02
                    fcb       $4E
                    pshs      d
                    leay      ,u
                    bsr       stkinit
                    lbsr      main
                    clr       ,-s
                    clr       ,-s
                    lbsr      exit
stkinit             leax      $02E7,y
L0100               stx       $025C,y
                    sts       $0250,y
                    sts       $025e,y
                    ldd       #$FF82
stkcheck            leax      d,s
                    cmpx      $025e,y
                    bcc       L0123
                    cmpx      $025C,y
                    bcs       L013D
                    stx       $025e,y
L0123               rts
L0124               fcc       /**** STACK OVERFLOW ****/
                    fcb       $0D
L013D               leax      L0124,pcr
                    ldb       #$CF
                    pshs      b
                    lda       #$02
                    ldy       #$0064
                    os9       I$WritLn
                    clr       ,-s
                    lbsr      $6230
                    ldd       $0250,y
                    subd      $025e,y
                    rts
                    ldd       $025e,y
                    subd      $025C,y
L0163               rts
                    pshs      x
                    leax      d,y
                    leax      d,x
                    pshs      x
L016C               ldd       ,y++
                    leax      d,u
                    ldd       ,x
                    addd      $02,s
                    std       ,x
                    cmpy      ,s
                    bne       L016C
                    leas      $04,s
                    rts

main                pshs      u
                    ldd       #$FF86
                    lbsr      stkcheck
                    leas      -$24,s
                    lbra      L028F

L018C               ldx       $2a,s
                    leax      $02,x
                    stx       $2a,s
                    ldu       ,x
                    ldb       ,u
                    cmpb      #$2d
                    lbne      L023B
                    lbra      L0231

L01A1               ldb       ,u
                    sex
                    tfr       d,x
                    lbra      L0215

L01A9               ldd       #$0001
                    std       $0011
                    lbra      L0231

L01B1               ldd       #$0001
                    std       copybytes
                    leax      L0B05,pcr
                    pshs      x
                    lbsr      L09DC
                    leas      $02,s
                    lbra      L0231

L01C4               leau      $01,u
                    ldb       ,u
                    cmpb      #$3d
                    bne       L01DB
                    leau      $01,u
                    pshs      u
                    lbsr      L09DC
                    leas      $02,s
                    leax      $24,s
                    lbra      L028C

L01DB               leau      -$01,u
                    pshs      u
                    leax      L0B0F,pcr
                    pshs      x
                    leax      $00DB,y
                    pshs      x
                    lbsr      L2D55
                    leas      $06,s
                    lbsr      L0AE0
L01F3               ldd       #$0001
                    std       $0013
                    bra       L0231

L01FA               ldb       ,u
                    sex
                    pshs      d
                    leax      L0B21,pcr
                    pshs      x
                    leax      $00DB,y
                    pshs      x
                    lbsr      L2D55
                    leas      $06,s
                    lbsr      L0AE0
                    bra       L0231

L0215               cmpx      #$0073
                    lbeq      L01A9
                    cmpx      #$006E
                    lbeq      L01B1
                    cmpx      #$006F
                    lbeq      L01C4
                    cmpx      #$0070
                    beq       L01F3
                    bra       L01FA

L0231               leau      $01,u
                    ldb       ,u
                    lbne      L01A1
                    bra       L028F

L023B               ldd       $0003
                    beq       L025F
                    ldd       $0280,y
                    beq       L0259
                    leax      L0B37,pcr
                    pshs      x
                    leax      $00DB,y
                    pshs      x
                    lbsr      L2D55
                    leas      $04,s
                    lbsr      L0AE0
L0259               stu       $0280,y
                    bra       L028F

L025F               leax      L0B46,pcr
                    pshs      x
                    pshs      u
                    lbsr      L4F07
                    leas      $04,s
                    std       $0003
                    bne       L0286
                    pshs      u
                    leax      $0B48,pcr
                    pshs      x
                    leax      $00DB,y
                    pshs      x
                    lbsr      L2D55
                    leas      $06,s
                    lbsr      L0AE0
L0286               stu       $0284,y
                    bra       L028F

L028C               leas      -$24,x
L028F               ldd       $28,s
                    addd      #$FFFF
                    std       $28,s
                    lbne      L018C
                    ldd       $0005
                    bne       L02A6
                    leax      $00CE,y
                    stx       $0005
L02A6               ldd       $0003
                    bne       L02B0
                    leax      $00C1,y
                    stx       $0003
L02B0               ldd       $0280,y
                    bne       L02BE
                    leax      L0B57,pcr
                    stx       $0280,y
L02BE               lbra      L076F

L02C1               ldx       $1a,s
                    lbra      L06D4

L02C7               ldd       $0003
                    pshs      d
                    lbsr      L5376
                    leas      $02,s
                    std       $1a,s
                    cmpd      #$FFFF
                    beq       L02F0
                    ldd       $0005
                    pshs      d
                    ldd       $1C,s
                    pshs      d
                    lbsr      L515F
                    leas      $04,s
                    ldd       $1a,s
                    cmpd      #$000D
                    bne       L02C7
L02F0               lbra      L076F

L02F3               ldd       $0003
                    pshs      d
                    lbsr      L53D8
                    leas      $02,s
                    std       $0007
                    leax      $14,s
                    pshs      x
                    ldd       $0003
                    pshs      d
                    lbsr      L5376
                    leas      $02,s
                    clra
                    lbsr      $5E0B
                    pshs      x
                    ldd       #$0010
                    lbsr      $5E3A
                    lbsr      $5E24
                    leax      $14,s
                    pshs      x
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $0003
                    pshs      d
                    lbsr      L53D8
                    leas      $02,s
                    lbsr      $5E0B
                    lbsr      $5D96
                    lbsr      $5E24
                    leax      $14,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $0007
                    pshs      d
                    lbsr      L4897
                    leas      $06,s
                    lbra      L076F

L0351               ldd       $0003
                    pshs      d
                    lbsr      L53D8
                    leas      $02,s
                    std       $22,s
                    ldd       $0003
                    pshs      d
                    lbsr      L53D8
                    leas      $02,s
                    std       $000B
                    ldd       $0003
                    pshs      d
                    lbsr      L53D8
                    leas      $02,s
                    std       $000D
                    ldd       L0017
                    cmpd      $000D
                    ble       L037E
                    ldd       $000D
                    std       L0017
L037E               ldx       $22,s
                    bra       L03C4

L0383               ldd       $0003
                    pshs      d
                    lbsr      L53D8
                    leas      $02,s
                    std       $1e,s
                    ldd       $0003
                    pshs      d
                    lbsr      L53D8
                    leas      $02,s
                    std       $20,s
                    ldd       $0003
                    pshs      d
                    lbsr      L5376
                    leas      $02,s
                    std       $1C,s
                    bra       L03D3

L03A9               ldd       $0003
                    pshs      d
                    lbsr      L53D8
                    leas      $02,s
                    std       L0023
                    bra       L03D3

L03B6               ldd       $0003
                    pshs      d
                    lbsr      L53D8
                    leas      $02,s
                    std       $18,s
                    bra       L03D3

L03C4               cmpx      #$0002
                    beq       L0383
                    cmpx      #$0005
                    beq       L03A9
                    cmpx      #$0012
                    beq       L03B6
L03D3               lbsr      L0788
                    std       $0282,y
                    ldx       $22,s
                    lbra      L046B

L03E0               ldd       $1C,s
                    pshs      d
                    ldd       $22,s
                    pshs      d
                    ldd       $22,s
                    pshs      d
                    ldd       $0282,y
                    pshs      d
                    lbsr      L1F14
                    leas      $08,s
                    lbra      L048E

L03FD               ldd       $18,s
                    pshs      d
                    ldd       $0282,y
                    pshs      d
                    lbsr      L0A17
                    leas      $04,s
                    lbra      L048E

L0410               ldd       $0282,y
                    pshs      d
                    lbsr      L0D05
                    leas      $02,s
                    std       $0282,y
                    lbra      L048E

L0422               ldd       $0282,y
                    pshs      d
                    lbsr      L0BF8
                    leas      $02,s
                    lbra      L048E

L0430               lbsr      $4B89
                    clra
                    clrb
                    pshs      d
                    ldd       $0282,y
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    lbsr      L40D1
                    leas      $06,s
                    lbsr      L43DD
                    clra
                    clrb
                    std       L0023
                    bra       L048E

L0450               ldd       $22,s
                    pshs      d
                    leax      $0B58,pcr
                    pshs      x
                    leax      $00DB,y
                    pshs      x
                    lbsr      L2D55
                    leas      $06,s
                    lbsr      L0AE0
                    bra       L048E

L046B               cmpx      #$0002
                    lbeq      L03E0
                    cmpx      #$0012
                    lbeq      L03FD
                    cmpx      #$0004
                    lbeq      L0410
                    cmpx      #$0001
                    lbeq      L0422
                    cmpx      #$0005
                    beq       L0430
                    bra       L0450

L048E               ldd       $0282,y
                    pshs      d
                    lbsr      L4A6A
                    lbra      L0511

L049A               ldd       $0003
                    pshs      d
                    lbsr      L53D8
                    std       ,s
                    lbsr      L4415
                    lbra      L0511

L04A9               ldd       $1a,s
                    cmpd      #$0064
                    bne       L04B7
                    ldd       #$0001
                    bra       L04B9

L04B7               clra
                    clrb
L04B9               pshs      d
                    lbsr      L4C3F
                    bra       L0511

L04C0               lbsr      L4C55
                    lbra      L076F

L04C6               ldd       $1a,s
                    cmpd      #$FFFF
                    beq       L04FC
                    ldd       $1a,s
                    cmpd      #$005C
                    bne       L04E4
                    ldd       $0003
                    pshs      d
                    lbsr      L5376
                    leas      $02,s
                    std       $1a,s
L04E4               ldd       $1a,s
                    pshs      d
                    lbsr      L4C93
                    leas      $02,s
L04EE               ldd       $0003
                    pshs      d
                    lbsr      L5376
                    leas      $02,s
                    std       $1a,s
                    bne       L04C6
L04FC               clra
                    clrb
                    pshs      d
                    lbsr      L4C93
                    bra       L0511

L0505               ldd       $0003
                    pshs      d
                    lbsr      L53D8
                    std       ,s
                    lbsr      L0AC3
L0511               leas      $02,s
                    lbra      L076F

L0516               clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    ldd       #$0012
                    lbra      L057E

L0524               ldd       $0003
                    pshs      d
                    lbsr      L53D8
                    leas      $02,s
                    std       $18,s
                    pshs      d
                    ldd       $0003
                    pshs      d
                    lbsr      L53D8
                    std       ,s
                    ldd       #$007D
                    bra       L057E

L0540               clra
                    clrb
                    pshs      d
                    ldd       $0003
                    pshs      d
                    lbsr      L53D8
                    std       ,s
                    ldd       #$001D
                    bra       L057E

L0552               clra
                    clrb
                    pshs      d
                    ldd       $0003
                    pshs      d
                    lbsr      L53D8
                    std       ,s
                    ldd       #$007C
                    bra       L057E

L0564               ldd       $0003
                    pshs      d
                    lbsr      L53D8
                    leas      $02,s
                    std       $18,s
                    pshs      d
                    ldd       $0003
                    pshs      d
                    lbsr      L53D8
                    std       ,s
                    ldd       #$0009
L057E               pshs      d
                    lbsr      L3293
                    leas      $06,s
                    lbra      L076F

L0588               ldd       $0003
                    pshs      d
                    lbsr      L53D8
                    std       ,s
                    ldd       #$0076
                    bra       L05A2

L0596               ldd       $0003
                    pshs      d
                    lbsr      L53D8
                    std       ,s
                    ldd       #$006F
L05A2               pshs      d
                    lbsr      L3293
                    leas      $04,s
                    lbra      L076F

L05AC               ldd       $0003
                    pshs      d
                    lbsr      L5376
                    leas      $02,s
                    std       $18,s
                    ldd       $0011
                    bne       L05C7
                    ldd       $0003
                    pshs      d
                    lbsr      L53D8
                    leas      $02,s
                    std       $000B
L05C7               leau      ,s
                    bra       L05D0

L05CB               ldd       $1a,s
                    stb       ,u+
L05D0               ldd       $0003
                    pshs      d
                    lbsr      L5376
                    leas      $02,s
                    std       $1a,s
                    bne       L05CB
                    clra
                    clrb
                    stb       ,u
                    ldd       $0013
                    beq       L05F2
                    ldd       $0003
                    pshs      d
                    lbsr      L53D8
                    leas      $02,s
                    std       $1a,s
L05F2               ldd       $1a,s
                    pshs      d
                    ldd       $000B
                    pshs      d
                    ldd       $1C,s
                    pshs      d
                    leax      $06,s
                    pshs      x
                    lbsr      L4B97
                    leas      $08,s
                    lbra      L076F

L060C               lbsr      L4C1B
                    lbra      L076F

L0612               leas      -$0a,s
                    ldd       $0003
                    pshs      d
                    lbsr      L53D8
                    leas      $02,s
                    std       ,s
                    ldd       $0003
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    ldd       #$0008
                    pshs      d
                    leax      $08,s
                    pshs      x
                    lbsr      L4F59
                    leas      $08,s
                    leax      $02,s
                    pshs      x
                    lbsr      L095D
                    leas      $02,s
                    ldd       ,s
                    cmpd      #$0006
                    bne       L0655
                    ldd       #$0004
                    pshs      d
                    leax      $04,s
                    pshs      x
                    lbsr      L3DD1
                    bra       L0671

L0655               leas      -$04,s
                    leax      ,s
                    pshs      x
                    leax      $08,s
                    lbsr      L56F3
                    lbsr      $5D69
                    ldd       #$0002
                    pshs      d
                    leax      $02,s
                    pshs      x
                    lbsr      L3DD1
                    leas      $04,s
L0671               leas      $04,s
                    leas      $0a,s
                    lbra      L076F
                    leas      $0a,s
L067A               lbsr      L4C62
                    lbra      L076F

L0680               leau      $0262,y
                    bra       L069F

L0686               ldd       $1a,s
                    cmpd      #$FFFF
                    beq       L06B1
                    leax      $027f,y
                    pshs      x
                    cmpu      ,s++
                    beq       L069F
                    ldd       $1a,s
                    stb       ,u+
L069F               ldd       $0003
                    pshs      d
                    lbsr      L5376
                    leas      $02,s
                    std       $1a,s
                    cmpd      #$000D
                    bne       L0686
L06B1               clra
                    clrb
                    stb       ,u
                    lbra      L076F

L06B8               ldd       $1a,s
                    pshs      d
                    leax      L0B6D,pcr
                    pshs      x
                    leax      $00DB,y
                    pshs      x
                    lbsr      L2D55
                    leas      $06,s
                    lbsr      L0AE0
                    lbra      L076F

L06D4               cmpx      #$002A
                    lbeq      L02C7
                    cmpx      #$004F
                    lbeq      L02F3
                    cmpx      #$0054
                    lbeq      L0351
                    cmpx      #$006C
                    lbeq      L049A
                    cmpx      #$0076
                    lbeq      L04A9
                    cmpx      #$0064
                    lbeq      L04A9
                    cmpx      #$0065
                    lbeq      L04C0
                    cmpx      #$0073
                    lbeq      L04EE
                    cmpx      #$004D
                    lbeq      L0505
                    cmpx      #$0072
                    lbeq      L0516
                    cmpx      #$004A
                    lbeq      L0524
                    cmpx      #$0047
                    lbeq      L0540
                    cmpx      #$006A
                    lbeq      L0552
                    cmpx      #$0044
                    lbeq      L0564
                    cmpx      #$0059
                    lbeq      L0588
                    cmpx      #$0055
                    lbeq      L0596
                    cmpx      #$0053
                    lbeq      L05AC
                    cmpx      #$0045
                    lbeq      L060C
                    cmpx      #$0066
                    lbeq      L0612
                    cmpx      #$0070
                    lbeq      L067A
                    cmpx      #$0046
                    lbeq      L0680
                    cmpx      #$000D
                    beq       L076F
                    lbra      L06B8

L076F               ldd       $0003
                    pshs      d
                    lbsr      L5376
                    leas      $02,s
                    std       $1a,s
                    cmpd      #$FFFF
                    lbne      L02C1
                    leas      $24,s
                    puls      pc,u
L0788               pshs      u
                    ldd       #$FFAA
                    lbsr      stkcheck
                    leas      -$0a,s
                    ldd       $0003
                    pshs      d
                    lbsr      L5376
                    leas      $02,s
                    std       $06,s
                    ldd       #$0016
                    pshs      d
                    lbsr      $3110
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    bne       L07B0
                    lbsr      L4835
L07B0               ldd       $0003
                    pshs      d
                    lbsr      L53D8
                    leas      $02,s
                    std       ,u
                    ldd       $0003
                    pshs      d
                    lbsr      L53D8
                    leas      $02,s
                    std       $02,u
                    ldd       $0003
                    pshs      d
                    lbsr      L53D8
                    leas      $02,s
                    std       $06,u
                    ldd       $0003
                    pshs      d
                    lbsr      L53D8
                    leas      $02,s
                    std       $0e,u
                    ldd       $0003
                    pshs      d
                    lbsr      L5376
                    leas      $02,s
                    clra
                    std       $10,u
                    ldd       $0003
                    pshs      d
                    lbsr      L5376
                    leas      $02,s
                    std       $12,u
                    ldd       $0003
                    pshs      d
                    lbsr      L53D8
                    leas      $02,s
                    std       $14,u
                    ldx       $06,u
                    lbra      L08F5

L0806               ldd       #$000D
                    pshs      d
                    lbsr      $3110
                    leas      $02,s
                    std       $08,s
                    std       $08,u
                    ldd       $08,s
                    bne       L081B
                    lbsr      L4835
L081B               ldd       $0003
                    pshs      d
                    lbsr      L5376
                    leas      $02,s
                    ldx       $08,s
                    std       $02,x
                    ldd       $0003
                    pshs      d
                    lbsr      L5376
                    leas      $02,s
                    std       [$08,s]
                    ldx       [$08,s]
                    bra       L086B

L0839               ldd       $08,s
                    addd      #$0004
                    std       $04,s
L0840               ldd       $0003
                    pshs      d
                    lbsr      L5376
                    leas      $02,s
                    ldx       $04,s
                    leax      $01,x
                    stx       $04,s
                    stb       -$01,x
                    bne       L0840
                    clra
                    clrb
                    stb       [$04,s]
                    lbra      L090A

L085B               ldd       $0003
                    pshs      d
                    lbsr      L53D8
                    leas      $02,s
                    ldx       $08,s
                    std       $04,x
                    lbra      L090A

L086B               cmpx      #$000E
                    beq       L0839
                    cmpx      #$000C
                    lbeq      L0839
                    cmpx      #$0021
                    lbeq      L0839
                    cmpx      #$0022
                    lbeq      L0839
                    bra       L085B

L0887               ldd       #$0004
                    pshs      d
                    lbsr      $3110
                    leas      $02,s
                    std       $02,s
                    bne       L0898
                    lbsr      L4835
L0898               ldd       $0003
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    ldd       #$0004
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L4F59
                    leas      $08,s
                    ldd       $02,s
                    bra       L08F1

L08B3               ldd       #$0008
                    pshs      d
                    lbsr      $3110
                    leas      $02,s
                    std       ,s
                    bne       L08C4
                    lbsr      L4835
L08C4               ldd       $0003
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    ldd       #$0008
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L4F59
                    leas      $08,s
                    ldd       ,s
                    pshs      d
                    lbsr      L095D
                    leas      $02,s
                    ldd       ,s
                    bra       L08F1

L08E8               ldd       $0003
                    pshs      d
                    lbsr      L53D8
                    leas      $02,s
L08F1               std       $08,u
                    bra       L090A

L08F5               cmpx      #$0034
                    lbeq      L0806
                    cmpx      #$004A
                    lbeq      L0887
                    cmpx      #$004B
                    beq       L08B3
                    bra       L08E8

L090A               clra
                    clrb
                    std       $0a,u
                    ldx       $06,s
                    bra       L0941

L0912               lbsr      L0788
                    std       $0a,u
L0917               lbsr      L0788
                    bra       L0923

L091C               lbsr      L0788
                    std       $0a,u
L0921               clra
                    clrb
L0923               std       $0C,u
                    bra       L0957

L0927               ldd       $06,s
                    pshs      d
                    leax      L0B92,pcr
                    pshs      x
                    leax      $00DB,y
                    pshs      x
                    lbsr      L2D55
                    leas      $06,s
                    lbsr      L0AE0
                    bra       L0957

L0941               cmpx      #$0042
                    beq       L0912
                    cmpx      #$0052
                    beq       L0917
                    cmpx      #$004C
                    beq       L091C
                    cmpx      #$004E
                    beq       L0921
                    bra       L0927

L0957               tfr       u,d
                    leas      $0a,s
                    puls      pc,u
L095D               pshs      u
                    ldd       #$FFAE
                    lbsr      stkcheck
                    ldu       $04,s
                    leas      -$08,s
                    stu       $06,s
                    ldx       $06,s
                    ldb       $07,x
                    sex
                    std       $02,s
                    ldd       #$00B8
                    ldx       $06,s
                    stb       $07,x
                    ldb       [$06,s]
                    clra
                    andb      #$80
                    std       ,s
                    beq       L098C
                    ldb       [$06,s]
                    clra
                    andb      #$7f
                    stb       [$06,s]
L098C               leax      ,u
                    pshs      x
                    pshs      u
                    lbsr      L5676
                    leas      $02,s
                    lbsr      L5D79
                    ldd       $02,s
                    bge       L09AA
                    ldd       $02,s
                    nega
                    negb
                    sbca      #$00
                    std       $02,s
                    clra
                    clrb
                    bra       L09AD

L09AA               ldd       #$0001
L09AD               std       $04,s
                    leax      ,u
                    pshs      x
                    ldd       $06,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    leax      ,u
                    lbsr      $5D52
                    lbsr      L55A3
                    leas      $0C,s
                    lbsr      L5D79
                    ldd       ,s
                    beq       L09D8
                    leax      ,u
                    pshs      x
                    leax      ,u
                    lbsr      L5691
                    lbsr      L5D79
L09D8               leas      $08,s
                    puls      pc,u
L09DC               pshs      u
                    ldd       #$FFB6
                    lbsr      stkcheck
                    ldd       $0005
                    beq       L09EA
                    puls      pc,u
L09EA               leax      L0BA7,pcr
                    pshs      x
                    ldd       $06,s
                    pshs      d
                    lbsr      L4F07
                    leas      $04,s
                    std       $0005
                    bne       L0A15
                    ldd       $04,s
                    pshs      d
                    leax      $0BA9,pcr
                    pshs      x
                    leax      $00DB,y
                    pshs      x
                    lbsr      L2D55
                    leas      $06,s
                    lbsr      L0AE0
L0A15               puls      pc,u
L0A17               pshs      u
                    ldd       #$FFB6
                    lbsr      stkcheck
                    ldu       $04,s
                    ldx       $06,s
                    lbra      L0AAA

L0A26               pshs      u
                    lbsr      L2506
                    leas      $02,s
                    leax      ,s
                    bra       L0A3A

L0A31               pshs      u
                    lbsr      L29FD
                    leas      $02,s
                    bra       L0A3C

L0A3A               leas      ,x
L0A3C               ldd       $06,u
                    cmpd      #$0080
                    lbeq      L0AC1
                    ldd       #$0080
                    pshs      d
                    ldd       #$006F
                    pshs      d
                    ldd       #$007F
                    pshs      d
                    lbsr      L3293
                    leas      $06,s
                    ldd       #$006F
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3293
                    leas      $04,s
                    ldx       $06,s
                    bra       L0A93

L0A6D               ldd       $06,s
                    pshs      d
                    ldd       #$0089
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L3293
                    leas      $06,s
                    bra       L0AC1

L0A82               ldd       #$0089
                    pshs      d
                    ldd       #$0088
                    pshs      d
                    lbsr      L3293
                    leas      $04,s
                    bra       L0AC1

L0A93               cmpx      #$0005
                    beq       L0A6D
                    cmpx      #$0006
                    lbeq      L0A6D
                    bra       L0A82

L0AA1               pshs      u
                    lbsr      L0BC4
                    leas      $02,s
                    bra       L0AC1

L0AAA               cmpx      #$0008
                    lbeq      L0A26
                    cmpx      #$0005
                    lbeq      L0A31
                    cmpx      #$0006
                    lbeq      L0A31
                    bra       L0AA1

L0AC1               puls      pc,u
L0AC3               pshs      u
                    ldd       #$FFB6
                    lbsr      stkcheck
                    ldd       $04,s
                    pshs      d
                    leax      L0BB8,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      L2D55
                    leas      $06,s
                    puls      pc,u
L0AE0               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    ldd       $0284,y
                    beq       L0AF9
                    ldd       $0284,y
                    pshs      d
                    lbsr      $60C2
                    leas      $02,s
L0AF9               ldd       #$0001
                    pshs      d
                    lbsr      exit
                    leas      $02,s
                    puls      pc,u
L0B05               fcc       |/dev/null|
                    fcb       $00
L0B0F               fcc       /bad argument: %s/
                    fcb       $0D,$00
L0B21               fcc       /bad option flag: +%c/
                    fcb       $0D,$00
L0B37               fcc       /too many files/
                    fcb       $00
L0B46               fcb       $72
                    neg       $0063
                    fcb       $61
                    jmp       $07,y
                    lsr       $206F
                    neg       $656E
                    bra       L0B79
                    com       $0D00
L0B57               neg       L0062
                    fcc       /ad action code: %d/
                    fcb       $0D,$00
L0B6D               fcc       /bad code in /
L0B79               fcc       /intermediate file: %02x/
                    fcb       $0D,$00
L0B92               fcc       /bad node type: %02x/
                    fcb       $0D,$00
L0BA7               asr       >$0063
                    fcb       $61
                    jmp       $07,y
                    lsr       $206F
                    neg       $656E
                    bra       $0BDA
                    com       $0D00
L0BB8               bra       $0C26
                    fcb       $65,$61
                    com       L2025
                    lsr       $0C,y
                    com       $0D00
L0BC4               pshs      u
                    ldd       #$FFB4
                    lbsr      stkcheck
                    ldu       $04,s
                    pshs      u
                    lbsr      L0C2E
                    leas      $02,s
                    ldd       $06,u
                    cmpd      #$0070
                    beq       L0C2C
                    pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3293
                    leas      $08,s
                    ldd       #$0070
                    bra       L0C2A

L0BF8               pshs      u
                    ldd       #$FFB4
                    lbsr      stkcheck
                    ldu       $04,s
                    pshs      u
                    lbsr      L1C1E
                    leas      $02,s
                    ldd       $06,u
                    cmpd      #$0071
                    beq       L0C2C
                    pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3293
                    leas      $08,s
                    ldd       #$0071
L0C2A               std       $06,u
L0C2C               puls      pc,u
L0C2E               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    ldu       $04,s
                    ldx       ,u
                    bra       L0C59

L0C3C               pshs      u
                    lbsr      L2506
                    bra       L0C55

L0C43               pshs      u
                    lbsr      L29FD
                    bra       L0C55

L0C4A               pshs      u
                    lbsr      L0D05
                    leas      $02,s
                    pshs      u
                    bsr       L0C6E
L0C55               leas      $02,s
                    bra       L0C6C

L0C59               cmpx      #$0008
                    beq       L0C3C
                    cmpx      #$0005
                    beq       L0C43
                    cmpx      #$0006
                    lbeq      L0C43
                    bra       L0C4A

L0C6C               puls      pc,u
L0C6E               pshs      u
                    ldd       #$FFB4
                    lbsr      stkcheck
                    ldu       $04,s
                    ldx       $06,u
                    lbra      L0CE1

L0C7D               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3293
                    leas      $08,s
                    ldd       #$0071
                    std       $06,u
                    clra
                    clrb
                    std       $08,u
                    lbra      L0D03

L0C9F               ldd       $0a,u
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$007F
                    pshs      d
                    lbsr      L3293
                    leas      $08,s
                    clra
                    clrb
                    std       $08,u
                    ldd       #$0071
                    bra       L0CDD

L0CC0               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3293
                    leas      $08,s
                    bra       L0CDA
                    leas      ,x
L0CDA               ldd       #$0070
L0CDD               std       $06,u
                    bra       L0D03

L0CE1               cmpx      #$0037
                    lbeq      L0C7D
                    cmpx      #$0041
                    beq       L0C9F
                    cmpx      #$0071
                    beq       L0D03
                    cmpx      #$0070
                    beq       L0D03
                    cmpx      #$006F
                    beq       L0D03
                    cmpx      #$0076
                    beq       L0D03
                    bra       L0CC0

L0D03               puls      pc,u
L0D05               pshs      u
                    ldd       #$FFB4
                    lbsr      stkcheck
                    ldu       $04,s
                    leas      -$02,s
                    ldd       $06,u
                    std       ,s
                    cmpd      #$0030
                    bne       L0D4E
                    leas      -$02,s
                    ldd       $0C,u
                    std       ,s
                    ldd       $0a,u
                    pshs      d
                    bsr       L0D05
                    std       ,s
                    lbsr      L4A6A
                    leas      $02,s
                    pshs      u
                    ldd       $02,s
                    pshs      d
                    lbsr      L4ACE
                    leas      $04,s
                    ldd       ,s
                    pshs      d
                    lbsr      L4A8B
                    leas      $02,s
                    pshs      u
                    lbsr      L0D05
                    leas      $02,s
                    leas      $02,s
                    lbra      L0EF8

L0D4E               ldd       ,u
                    cmpd      #$0008
                    bne       L0D60
                    pshs      u
                    lbsr      L2521
                    leas      $02,s
                    lbra      L0EF8

L0D60               ldd       ,u
                    cmpd      #$0005
                    beq       L0D70
                    ldd       ,u
                    cmpd      #$0006
                    bne       L0D7A
L0D70               pshs      u
                    lbsr      L2A18
                    leas      $02,s
                    lbra      L0EF8

L0D7A               ldd       ,s
                    pshs      d
                    lbsr      L4AF8
                    std       ,s++
                    beq       L0D93
                    pshs      u
                    ldd       $02,s
                    pshs      d
                    lbsr      L0EFE
                    leas      $04,s
                    lbra      L0EF8

L0D93               ldx       ,s
                    lbra      L0E5F

L0D98               pshs      u
                    lbsr      L1568
                    lbra      L0E28

L0DA0               ldd       $0a,u
                    pshs      d
                    lbsr      L0D05
                    lbra      L0E28

L0DAA               ldd       $0a,u
                    pshs      d
                    lbsr      L2521
                    leas      $02,s
                    ldd       $0a,u
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       #$0084
                    pshs      d
                    lbsr      L3293
                    leas      $06,s
                    bra       L0E0F

L0DC8               ldd       $0a,u
                    pshs      d
                    lbsr      L29FD
                    leas      $02,s
                    ldd       #$008F
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L3293
                    bra       L0E0D

L0DE0               pshs      u
                    lbsr      L1954
                    bra       L0E28

L0DE7               pshs      u
                    lbsr      L124D
                    bra       L0E28

L0DEE               ldd       $0a,u
                    pshs      d
                    lbsr      L0BC4
                    leas      $02,s
                    ldd       ,s
                    pshs      d
                    lbsr      L3293
                    leas      $02,s
                    bra       L0E0F

L0E02               leax      L0BC4,pcr
                    pshs      x
                    pshs      u
                    lbsr      L12E9
L0E0D               leas      $04,s
L0E0F               ldd       #$0070
                    std       $06,u
                    lbra      L0EF8

L0E17               ldd       #$0070
                    pshs      d
                    pshs      u
                    lbsr      L1A9B
                    bra       L0E5A

L0E23               pshs      u
                    lbsr      L1365
L0E28               leas      $02,s
                    lbra      L0EF8

L0E2D               ldd       ,s
                    cmpd      #$00A0
                    blt       L0E40
                    ldd       ,s
                    pshs      d
                    pshs      u
                    lbsr      L16CC
                    bra       L0E5A

L0E40               leax      L1ED5,pcr
                    pshs      x
                    pshs      u
                    lbsr      L484C
                    leas      $04,s
                    ldd       ,s
                    pshs      d
                    leax      L1EE1,pcr
                    pshs      x
                    lbsr      L2D40
L0E5A               leas      $04,s
                    lbra      L0EF8

L0E5F               cmpx      #$0037
                    lbeq      L0EF8
                    cmpx      #$0034
                    lbeq      L0EF8
                    cmpx      #$0076
                    lbeq      L0EF8
                    cmpx      #$006F
                    lbeq      L0EF8
                    cmpx      #$0041
                    beq       L0EF8
                    cmpx      #$0036
                    beq       L0EF8
                    cmpx      #$0078
                    lbeq      L0D98
                    cmpx      #$0085
                    lbeq      L0DA0
                    cmpx      #$0084
                    lbeq      L0DAA
                    cmpx      #$008F
                    lbeq      L0DC8
                    cmpx      #$0042
                    lbeq      L0DE0
                    cmpx      #$0040
                    lbeq      L0DE7
                    cmpx      #$0047
                    lbeq      L0DE7
                    cmpx      #$0048
                    lbeq      L0DE7
                    cmpx      #$0044
                    lbeq      L0DEE
                    cmpx      #$0043
                    lbeq      L0DEE
                    cmpx      #$0064
                    lbeq      L0E02
                    cmpx      #$003C
                    lbeq      L0E17
                    cmpx      #$003E
                    lbeq      L0E17
                    cmpx      #$003D
                    lbeq      L0E17
                    cmpx      #$003F
                    lbeq      L0E17
                    cmpx      #$0065
                    lbeq      L0E23
                    lbra      L0E2D

L0EF8               tfr       u,d
                    leas      $02,s
                    puls      pc,u
L0EFE               pshs      u
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
                    bne       L0F40
                    ldx       $0a,s
                    bra       L0F2F

L0F1E               ldd       #$004E
                    bra       L0F2B

L0F23               ldd       #$004C
                    bra       L0F2B

L0F28               ldd       #$004D
L0F2B               std       $0a,s
                    bra       L0F74

L0F2F               cmpx      #$0053
                    beq       L0F1E
                    cmpx      #$0054
                    beq       L0F23
                    cmpx      #$0055
                    beq       L0F28
                    bra       L0F74

L0F40               ldx       $0a,s
                    bra       L0F68

L0F44               ldd       $06,u
                    cmpd      #$0041
                    bne       L0F74
                    ldx       $04,s
                    ldd       $06,x
                    cmpd      #$0036
                    beq       L0F74
                    ldd       $0C,s
                    pshs      d
                    lbsr      L1C1E
                    leas      $02,s
                    clra
                    clrb
                    std       L0019
                    lbra      L1361
                    bra       L0F74

L0F68               cmpx      #$0050
                    beq       L0F44
                    cmpx      #$0051
                    lbeq      L0F44
L0F74               ldx       $0a,s
                    lbra      L1168

L0F79               ldd       $04,s
                    pshs      d
                    lbsr      L22CB
                    std       ,s++
                    bne       L0FAB
                    ldd       $04,s
                    pshs      d
                    lbsr      L0C2E
                    leas      $02,s
                    ldx       $04,s
                    ldd       $06,x
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3293
                    leas      $04,s
                    ldd       #$006E
                    ldx       $04,s
                    std       $06,x
                    pshs      u
                    lbsr      L0BC4
                    bra       L0FB9

L0FAB               pshs      u
                    lbsr      L0BC4
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L0D05
L0FB9               leas      $02,s
                    ldd       $04,s
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0051
                    lbra      L1064

L0FCF               pshs      u
                    lbsr      L22CB
                    std       ,s++
                    beq       L0FE3
                    ldd       $04,s
                    pshs      d
                    lbsr      L22CB
                    std       ,s++
                    beq       L0FEB
L0FE3               ldd       $06,u
                    cmpd      #$0036
                    bne       L0FF7
L0FEB               leas      -$02,s
                    stu       ,s
                    ldu       $06,s
                    ldd       ,s
                    std       $06,s
                    leas      $02,s
L0FF7               ldd       $06,u
                    pshs      d
                    lbsr      L1EB4
                    std       ,s++
                    beq       L1022
                    ldd       $06,u
L1004               pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3293
                    leas      $04,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L0BC4
                    leas      $02,s
                    ldd       #$006E
                    ldx       $04,s
                    std       $06,x
                    bra       L1053

L1022               pshs      u
                    lbsr      L0BC4
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L22CB
                    std       ,s++
                    bne       L1039
                    ldd       #$0070
                    bra       L1004

L1039               ldd       $04,s
                    pshs      d
                    lbsr      L0D05
                    leas      $02,s
                    ldd       $0a,s
                    cmpd      #$0050
                    beq       L1053
                    ldd       $04,s
                    pshs      d
                    lbsr      L152E
                    leas      $02,s
L1053               ldd       $04,s
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       $10,s
L1064               pshs      d
                    lbsr      L3293
                    leas      $08,s
                    lbra      L120E

L106E               ldd       $0C,s
                    pshs      d
                    lbsr      L124D
                    lbra      L1151

L1078               ldx       $04,s
                    ldd       $06,x
                    cmpd      #$0036
                    lbne      L10DC
                    ldx       $04,s
                    ldd       $08,x
                    std       ,s
                    bra       L108E

L108C               leas      -$06,x
L108E               ldd       ,s
                    cmpd      #$0004
                    bhi       L10DC
                    pshs      u
                    lbsr      L0BC4
L109B               leas      $02,s
                    bra       L10C6

L109F               ldx       $0a,s
                    bra       L10B7

L10A3               ldd       #$0098
                    bra       L10B0

L10A8               ldd       #$0096
                    bra       L10B0

L10AD               ldd       #$0097
L10B0               pshs      d
                    lbsr      L3293
                    bra       L109B

L10B7               cmpx      #$0056
                    beq       L10A3
                    cmpx      #$0055
                    beq       L10A8
                    cmpx      #$004D
                    beq       L10AD
L10C6               ldd       ,s
                    addd      #$FFFF
                    std       ,s
                    subd      #$FFFF
                    bne       L109F
                    ldd       #$0001
                    std       L0019
                    leax      $06,s
                    lbra      L1214

L10DC               leax      $06,s
                    bra       L112A

L10E0               ldd       $06,u
                    cmpd      #$0036
                    bne       L10F4
                    leas      -$02,s
                    stu       ,s
                    ldu       $06,s
                    ldd       ,s
                    std       $06,s
                    leas      $02,s
L10F4               ldx       $04,s
                    ldd       $06,x
                    cmpd      #$0036
                    bne       L112C
                    ldx       $04,s
                    ldd       $08,x
                    pshs      d
                    lbsr      L1220
                    leas      $02,s
                    std       ,s
                    beq       L112C
                    ldd       ,s
                    ldx       $04,s
                    std       $08,x
                    ldd       $0a,s
                    cmpd      #$0052
                    bne       L1120
                    ldd       #$0056
                    bra       L1123

L1120               ldd       #$004D
L1123               std       $0a,s
                    leax      $06,s
                    lbra      L108C

L112A               leas      -$06,x
L112C               pshs      u
                    lbsr      L0C2E
                    leas      $02,s
                    ldd       $06,u
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3293
                    leas      $04,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L0BC4
                    leas      $02,s
                    ldd       $0a,s
                    pshs      d
                    lbsr      L3293
L1151               leas      $02,s
                    lbra      L120E

L1156               leax      L1EE5,pcr
                    pshs      x
                    ldd       $0e,s
                    pshs      d
                    lbsr      L484C
                    leas      $04,s
                    lbra      L120E

L1168               cmpx      #$0051
                    lbeq      L0F79
                    cmpx      #$0057
                    lbeq      L0FCF
                    cmpx      #$0058
                    lbeq      L0FCF
                    cmpx      #$0059
                    lbeq      L0FCF
                    cmpx      #$0050
                    lbeq      L0FCF
                    cmpx      #$005A
                    lbeq      L106E
                    cmpx      #$005B
                    lbeq      L106E
                    cmpx      #$005F
                    lbeq      L106E
                    cmpx      #$005D
                    lbeq      L106E
                    cmpx      #$005C
                    lbeq      L106E
                    cmpx      #$005E
                    lbeq      L106E
                    cmpx      #$0063
                    lbeq      L106E
                    cmpx      #$0061
                    lbeq      L106E
                    cmpx      #$0060
                    lbeq      L106E
                    cmpx      #$0062
                    lbeq      L106E
                    cmpx      #$004D
                    lbeq      L1078
                    cmpx      #$0055
                    lbeq      L1078
                    cmpx      #$0056
                    lbeq      L1078
                    cmpx      #$0052
                    lbeq      L10E0
                    cmpx      #$004E
                    lbeq      L10F4
                    cmpx      #$0053
                    lbeq      L112C
                    cmpx      #$004C
                    lbeq      L112C
                    cmpx      #$0054
                    lbeq      L112C
                    lbra      L1156
                    leas      -$06,x
L120E               clra
                    clrb
                    std       L0019
                    bra       L1216

L1214               leas      -$06,x
L1216               ldd       #$0070
                    ldx       $0C,s
                    std       $06,x
                    lbra      L1361

L1220               pshs      u
                    ldd       #$FFC0
                    lbsr      stkcheck
                    ldu       #$0000
                    bra       L1244

L122D               tfr       u,d
                    leau      $01,u
                    aslb
                    rola
                    leax      >$0027,y
                    leax      d,x
                    ldd       ,x
                    cmpd      $04,s
                    bne       L1244
                    tfr       u,d
                    puls      pc,u
L1244               cmpu      #$000E
                    blt       L122D
                    lbra      L152A

L124D               pshs      u
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
                    lbsr      L1F14
                    leas      $08,s
                    ldd       $02,s
                    pshs      d
                    lbsr      L4415
                    leas      $02,s
                    ldd       #$0001
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3293
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
                    lbsr      L3293
                    leas      $06,s
                    ldd       ,s
                    pshs      d
                    lbsr      L4415
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
                    lbsr      L3293
                    leas      $08,s
                    ldd       $02,s
                    pshs      d
                    lbsr      L4415
                    leas      $02,s
                    ldd       #$0070
                    std       $06,u
                    lbra      L1A97

L12E9               pshs      u
                    ldd       #$FFAE
                    lbsr      stkcheck
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
                    lbsr      L1F14
                    leas      $08,s
                    ldu       $0C,u
                    ldd       $04,s
                    pshs      d
                    lbsr      L4415
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
                    lbsr      L3293
                    leas      $06,s
                    ldd       ,s
                    pshs      d
                    lbsr      L4415
                    leas      $02,s
                    ldd       $0C,u
                    pshs      d
                    jsr       [$0e,s]
                    leas      $02,s
                    ldd       $02,s
                    pshs      d
                    lbsr      L4415
                    leas      $02,s
L1361               leas      $06,s
                    puls      pc,u
L1365               pshs      u
                    ldd       #$FFB2
                    lbsr      stkcheck
                    leas      -$04,s
                    ldd       $000D
                    std       ,s
                    ldd       $08,s
                    std       $02,s
                    lbra      L1402

L137A               ldx       $02,s
                    ldu       $0a,x
                    ldd       ,u
                    cmpd      #$0008
                    bne       L13A9
                    ldd       $06,u
                    cmpd      #$004A
                    bne       L1398
                    pshs      u
                    lbsr      L294C
                    leas      $02,s
                    lbra      L1402

L1398               pshs      u
                    lbsr      L2506
                    leas      $02,s
                    ldd       #$006E
                    pshs      d
                    ldd       #$0088
                    bra       L13FB

L13A9               ldd       ,u
                    cmpd      #$0005
                    beq       L13B9
                    ldd       ,u
                    cmpd      #$0006
                    bne       L13CA
L13B9               pshs      u
                    lbsr      L29FD
                    leas      $02,s
                    ldd       #$006E
                    pshs      d
                    ldd       #$0087
                    bra       L13FB

L13CA               pshs      u
                    lbsr      L0D05
                    leas      $02,s
                    ldx       $06,u
                    bra       L13DE

L13D5               pshs      u
                    lbsr      L0C6E
                    leas      $02,s
                    bra       L13F4

L13DE               cmpx      #$0070
                    beq       L13F4
                    cmpx      #$0071
                    beq       L13F4
                    cmpx      #$006F
                    beq       L13F4
                    cmpx      #$0076
                    beq       L13F4
                    bra       L13D5

L13F4               ldd       $06,u
                    pshs      d
                    ldd       #$007A
L13FB               pshs      d
                    lbsr      L3293
                    leas      $04,s
L1402               ldx       $02,s
                    ldd       $0C,x
                    std       $02,s
                    lbne      L137A
                    ldx       $08,s
                    ldd       $0a,x
                    pshs      d
                    lbsr      L0D05
                    leas      $02,s
                    ldx       $08,s
                    ldd       $0a,x
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       #$0065
                    pshs      d
                    lbsr      L3293
                    leas      $06,s
                    ldd       ,s
                    pshs      d
                    lbsr      L4440
                    leas      $02,s
                    std       $000D
                    ldd       #$0070
                    ldx       $08,s
                    std       $06,x
                    lbra      L1A97

L1441               pshs      u
                    ldd       #$FFB8
                    lbsr      stkcheck
                    ldu       $04,s
                    leas      -$02,s
                    ldx       $06,u
                    bra       L1486

L1451               ldd       $0a,u
                    std       ,s
                    tfr       d,x
                    ldx       $06,x
                    bra       L146A

L145B               ldd       #$0001
                    bra       L149B

L1460               ldd       ,s
                    pshs      d
                    bsr       L149F
                    leas      $02,s
                    bra       L149B

L146A               cmpx      #$0036
                    beq       L145B
                    cmpx      #$0034
                    lbeq      L145B
                    cmpx      #$0076
                    lbeq      L145B
                    cmpx      #$006F
                    lbeq      L145B
                    bra       L1460

L1486               cmpx      #$0034
                    lbeq      L145B
                    cmpx      #$0036
                    lbeq      L145B
                    cmpx      #$0042
                    beq       L1451
                    clra
                    clrb
L149B               leas      $02,s
                    puls      pc,u
L149F               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    ldu       $04,s
                    ldx       $06,u
                    bra       L14CD

L14AD               ldx       $0a,u
                    ldd       $06,x
                    pshs      d
                    lbsr      L1EB4
                    std       ,s++
                    lbeq      L152A
                    ldx       $0C,u
                    ldd       $06,x
                    cmpd      #$0036
                    lbne      L152A
                    bra       L150B
                    lbra      L152A

L14CD               cmpx      #$0050
                    beq       L14AD
                    cmpx      #$0051
                    lbeq      L14AD
                    bra       L152A

L14DB               pshs      u
                    ldd       #$FFC0
                    lbsr      stkcheck
                    ldx       $04,s
                    ldd       $12,x
                    cmpd      #$0002
                    bge       L152A
                    ldd       #$0001
                    bra       L152C

L14F3               pshs      u
                    ldd       #$FFC0
                    lbsr      stkcheck
                    ldu       $04,s
                    ldx       $06,u
                    bra       L1512

L1501               ldx       $0a,u
                    ldd       $06,x
                    cmpd      #$0041
                    bne       L152A
L150B               ldd       #$0001
                    puls      pc,u
                    bra       L152A

L1512               cmpx      #$0050
                    beq       L1501
                    cmpx      #$0051
                    lbeq      L1501
                    cmpx      #$0037
                    beq       L150B
                    cmpx      #$0041
                    lbeq      L150B
L152A               clra
                    clrb
L152C               puls      pc,u
L152E               pshs      u
                    ldd       #$FFB4
                    lbsr      stkcheck
                    ldu       $04,s
                    ldd       $06,u
                    anda      #$80
                    clrb
                    std       -$02,s
                    beq       L1566
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
                    lbsr      L3293
                    leas      $08,s
                    ldd       #$0093
                    std       $06,u
                    clra
                    clrb
                    std       $08,u
L1566               puls      pc,u
L1568               pshs      u
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
                    lbsr      L1EB4
                    std       ,s++
                    lbeq      L15FE
                    ldd       ,s
                    pshs      d
                    lbsr      L149F
                    std       ,s++
                    beq       L159D
                    ldd       ,s
                    pshs      d
                    lbsr      L1C1E
                    bra       L15A4

L159D               ldd       ,s
                    pshs      d
                    lbsr      L0D05
L15A4               leas      $02,s
                    ldx       ,s
                    ldx       $06,x
                    bra       L15F2

L15AC               ldx       ,s
                    ldd       $0a,x
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       $06,u
                    pshs      d
                    ldd       #$007F
                    bra       L15E8

L15C0               ldd       ,s
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3293
                    leas      $08,s
L15D8               ldd       ,s
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       $06,u
                    pshs      d
                    ldd       #$0075
L15E8               pshs      d
                    lbsr      L3293
                    leas      $08,s
                    lbra      L1795

L15F2               cmpx      #$0041
                    beq       L15AC
                    cmpx      #$0085
                    beq       L15C0
                    bra       L15D8

L15FE               pshs      u
                    lbsr      L1441
                    std       ,s++
                    beq       L1636
                    ldd       ,u
                    cmpd      #$0002
                    beq       L1636
                    ldd       ,s
                    pshs      d
                    lbsr      L149F
                    std       ,s++
                    bne       L1625
                    ldd       ,s
                    pshs      d
                    lbsr      L14F3
                    std       ,s++
                    beq       L1636
L1625               pshs      u
                    lbsr      L0D05
                    leas      $02,s
                    ldd       ,s
                    pshs      d
                    lbsr      L1BE5
                    lbra      L16AC

L1636               ldx       ,s
                    ldd       $06,x
                    pshs      d
                    lbsr      L1EB4
                    std       ,s++
                    beq       L165D
                    pshs      u
                    lbsr      L0D05
                    leas      $02,s
                    ldd       ,u
                    cmpd      #$0002
                    lbne      L16AE
                    ldd       ,s
                    pshs      d
                    lbsr      L0BC4
                    bra       L16AC

L165D               pshs      u
                    lbsr      L14DB
                    std       ,s++
                    beq       L1676
                    ldd       ,s
                    pshs      d
                    lbsr      L0BC4
                    leas      $02,s
                    pshs      u
                    lbsr      L0D05
                    bra       L16AC

L1676               pshs      u
                    lbsr      L0D05
                    leas      $02,s
                    ldd       ,s
                    pshs      d
                    lbsr      L1441
                    std       ,s++
                    bne       L16A5
                    ldd       $06,u
                    anda      #$7f
                    tfr       d,x
                    bra       L1699

L1690               pshs      u
                    lbsr      L1905
                    leas      $02,s
                    bra       L16A5

L1699               cmpx      #$0095
                    beq       L16A5
                    cmpx      #$0094
                    beq       L16A5
                    bra       L1690

L16A5               ldd       ,s
                    pshs      d
                    lbsr      L0C2E
L16AC               leas      $02,s
L16AE               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldx       $04,s
                    ldd       $06,x
                    pshs      d
                    ldd       #$0079
                    pshs      d
                    lbsr      L3293
                    leas      $08,s
                    ldx       ,s
                    ldd       $06,x
                    lbra      L1797

L16CC               pshs      u
                    ldd       #$FFB0
                    lbsr      stkcheck
                    leas      -$04,s
                    ldx       $08,s
                    ldd       $0C,x
                    std       $02,s
                    ldx       $08,s
                    ldu       $0a,x
                    pshs      u
                    lbsr      L0D05
                    leas      $02,s
                    ldd       $0a,s
                    addd      #$FFB0
                    std       $0a,s
                    ldd       ,u
                    cmpd      #$0007
                    bne       L171A
                    ldx       $0a,s
                    bra       L170B

L16FA               ldd       #$004E
                    bra       L1707

L16FF               ldd       #$004D
                    bra       L1707

L1704               ldd       #$004C
L1707               std       $0a,s
                    bra       L171A

L170B               cmpx      #$0053
                    beq       L16FA
                    cmpx      #$0055
                    beq       L16FF
                    cmpx      #$0054
                    beq       L1704
L171A               ldd       $06,u
                    anda      #$7f
                    std       ,s
                    pshs      d
                    lbsr      L1EB4
                    std       ,s++
                    lbeq      L17F0
                    ldx       $0a,s
                    lbra      L17CB

L1730               ldx       $02,s
                    ldd       $06,x
                    cmpd      #$0036
                    bne       L1767
                    ldd       $0a,s
                    cmpd      #$0050
                    bne       L1748
                    ldx       $02,s
                    ldd       $08,x
                    bra       L1750

L1748               ldx       $02,s
                    ldd       $08,x
                    nega
                    negb
                    sbca      #$00
L1750               pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    ldd       #$0074
                    pshs      d
                    lbsr      L3293
                    leas      $08,s
                    bra       L1795

L1767               ldd       $02,s
                    pshs      d
                    lbsr      L0BC4
                    leas      $02,s
                    ldd       $0a,s
                    cmpd      #$0051
                    bne       L1782
                    ldd       #$0043
                    pshs      d
                    lbsr      L3293
                    leas      $02,s
L1782               ldd       #$0070
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    ldd       #$0074
                    pshs      d
                    lbsr      L3293
                    leas      $06,s
L1795               ldd       $06,u
L1797               ldx       $08,s
                    std       $06,x
                    clra
                    clrb
                    ldx       $08,s
                    std       $08,x
                    lbra      L1A97

L17A4               leax      $04,s
                    bra       L17EE

L17A8               ldd       $06,u
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3293
                    leas      $04,s
                    ldd       $02,s
                    pshs      d
                    lbsr      L0BC4
                    leas      $02,s
                    ldd       $0a,s
                    pshs      d
                    lbsr      L3293
                    leas      $02,s
                    lbra      L18E5

L17CB               cmpx      #$0050
                    lbeq      L1730
                    cmpx      #$0051
                    lbeq      L1730
                    cmpx      #$0057
                    beq       L17A4
                    cmpx      #$0058
                    lbeq      L17A4
                    cmpx      #$0059
                    lbeq      L17A4
                    bra       L17A8

L17EE               leas      -$04,x
L17F0               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3293
                    leas      $08,s
                    ldd       ,u
                    cmpd      #$0002
                    bne       L1818
                    ldd       #$0085
                    pshs      d
                    lbsr      L3293
                    leas      $02,s
L1818               ldx       $0a,s
                    lbra      L18BF

L181D               ldd       $02,s
                    pshs      d
                    lbsr      L1441
                    std       ,s++
                    beq       L186E
                    ldd       $02,s
                    pshs      d
                    lbsr      L0D05
                    leas      $02,s
                    ldx       $0a,s
                    bra       L1840

L1835               ldd       $02,s
                    pshs      d
                    lbsr      L152E
                    leas      $02,s
                    bra       L1853

L1840               cmpx      #$0057
                    beq       L1835
                    cmpx      #$0058
                    lbeq      L1835
                    cmpx      #$0059
                    lbeq      L1835
L1853               ldd       $02,s
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    lbsr      L3293
                    leas      $08,s
                    lbra      L18E5

L186E               ldd       ,s
                    cmpd      #$0094
                    beq       L1885
                    ldd       ,s
                    cmpd      #$0095
                    beq       L1885
                    pshs      u
                    lbsr      L1905
                    leas      $02,s
L1885               ldd       #$0070
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3293
                    leas      $04,s
                    ldd       $02,s
                    pshs      d
                    lbsr      L0BC4
                    leas      $02,s
                    ldd       $0a,s
                    cmpd      #$0051
                    bne       L18AA
                    ldd       #$004F
                    std       $0a,s
L18AA               ldd       #$006E
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    lbsr      L3293
                    leas      $06,s
                    bra       L18E5

L18BF               cmpx      #$0057
                    lbeq      L181D
                    cmpx      #$0058
                    lbeq      L181D
                    cmpx      #$0059
                    lbeq      L181D
                    cmpx      #$0050
                    lbeq      L181D
                    cmpx      #$0051
                    lbeq      L181D
                    lbra      L186E

L18E5               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0079
                    pshs      d
                    lbsr      L3293
                    leas      $08,s
                    ldd       #$0070
                    ldx       $08,s
                    std       $06,x
                    lbra      L1A97

L1905               pshs      u
                    ldd       #$FFB4
                    lbsr      stkcheck
                    ldu       $04,s
                    ldd       $06,u
                    anda      #$7f
                    cmpd      #$0034
                    bne       L191B
                    puls      pc,u
L191B               pshs      u
                    lbsr      L152E
                    leas      $02,s
                    ldd       $08,u
                    beq       L193E
                    ldd       $08,u
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$0074
                    pshs      d
                    lbsr      L3293
                    leas      $08,s
L193E               ldd       #$0071
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3293
                    leas      $04,s
                    ldd       #$806E
                    std       $06,u
                    puls      pc,u
L1954               pshs      u
                    ldd       #$FFB0
                    lbsr      stkcheck
                    ldu       $04,s
                    leas      -$04,s
                    ldd       $0a,u
                    std       $02,s
                    pshs      d
                    lbsr      L1C1E
                    leas      $02,s
                    ldx       $02,s
                    ldd       $06,x
                    std       ,s
                    anda      #$80
                    clrb
                    std       -$02,s
                    lbeq      L19D8
                    ldd       ,s
                    anda      #$7f
                    std       ,s
                    tfr       d,x
                    bra       L19B0

L1984               ldx       $02,s
                    ldd       $08,x
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3293
                    leas      $08,s
                    bra       L19CC

L199F               leax      L1EF0,pcr
                    pshs      x
                    ldd       $04,s
                    pshs      d
                    lbsr      L484C
                    leas      $04,s
                    bra       L19CC

L19B0               cmpx      #$0034
                    beq       L1984
                    cmpx      #$0093
                    lbeq      L1984
                    cmpx      #$0094
                    lbeq      L1984
                    cmpx      #$0095
                    lbeq      L1984
                    bra       L199F

L19CC               ldd       #$8093
                    std       ,s
                    clra
                    clrb
                    std       $08,u
                    lbra      L1A93

L19D8               ldx       ,s
                    lbra      L1A54

L19DD               ldd       #$0095
                    bra       L19F0

L19E2               ldd       #$0094
                    bra       L19F0

L19E7               ldd       #$0093
                    bra       L19F0

L19EC               ldd       ,s
                    ora       #$80
L19F0               std       ,s
                    leax      $04,s
                    bra       L1A05

L19F6               ldd       #$8034
                    std       ,s
                    ldx       $02,s
                    ldd       $14,x
                    std       $14,u
                    bra       L1A07

L1A05               leas      -$04,x
L1A07               ldx       $02,s
                    ldd       $08,x
                    bra       L1A2C

L1A0D               ldd       $02,s
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3293
                    leas      $08,s
                    ldd       #$0093
                    std       ,s
                    clra
                    clrb
L1A2C               std       $08,u
                    bra       L1A93

L1A30               clra
                    clrb
                    std       $08,u
                    ldx       $02,s
                    ldd       $08,x
                    std       $14,u
                    ldd       #$0034
                    bra       L1A50

L1A40               leax      L1EFC,pcr
                    pshs      x
                    pshs      u
                    lbsr      L484C
                    leas      $04,s
                    ldd       #$0093
L1A50               std       ,s
                    bra       L1A93

L1A54               cmpx      #$006F
                    lbeq      L19DD
                    cmpx      #$0076
                    lbeq      L19E2
                    cmpx      #$0071
                    lbeq      L19E7
                    cmpx      #$0093
                    lbeq      L19EC
                    cmpx      #$0094
                    lbeq      L19EC
                    cmpx      #$0095
                    lbeq      L19EC
                    cmpx      #$0034
                    lbeq      L19F6
                    cmpx      #$0070
                    lbeq      L1A0D
                    cmpx      #$0036
                    beq       L1A30
                    bra       L1A40

L1A93               ldd       ,s
                    std       $06,u
L1A97               leas      $04,s
                    puls      pc,u
L1A9B               pshs      u
                    ldd       #$FFAC
                    lbsr      stkcheck
                    leas      -$08,s
                    ldx       $0C,s
                    ldu       $0a,x
                    pshs      u
                    lbsr      L0D05
                    leas      $02,s
                    ldx       $0C,s
                    ldd       $06,x
                    std       $02,s
                    ldd       $06,u
                    std       ,s
                    pshs      d
                    lbsr      L1EB4
                    std       ,s++
                    beq       L1AFB
                    ldx       $02,s
                    bra       L1AED

L1AC7               ldd       $0e,s
                    cmpd      #$0070
                    bne       L1AE7
                    pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       $12,s
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3293
                    leas      $08,s
                    bra       L1B2C

L1AE7               ldd       ,s
                    std       $0e,s
                    bra       L1B2C

L1AED               cmpx      #$003E
                    beq       L1AC7
                    cmpx      #$003F
                    lbeq      L1AC7
                    bra       L1AE7

L1AFB               ldd       $0e,s
                    cmpd      #$0071
                    bne       L1B12
                    ldd       ,s
                    anda      #$7f
                    cmpd      #$0034
                    beq       L1B12
                    ldd       #$0070
                    std       $0e,s
L1B12               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       $12,s
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3293
                    leas      $08,s
                    ldd       $0e,s
                    std       ,s
L1B2C               ldx       $0C,s
                    ldd       $08,x
                    std       $06,s
                    ldx       $02,s
                    bra       L1B71

L1B36               ldd       $06,s
                    nega
                    negb
                    sbca      #$00
                    std       $06,s
L1B3E               ldd       ,s
                    cmpd      #$0070
                    bne       L1B58
                    ldd       $06,s
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    ldd       #$0050
                    bra       L1B68

L1B58               ldd       $06,s
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    ldd       #$0074
L1B68               pshs      d
                    lbsr      L3293
                    leas      $08,s
                    bra       L1B7F

L1B71               cmpx      #$003D
                    beq       L1B36
                    cmpx      #$003F
                    lbeq      L1B36
                    bra       L1B3E

L1B7F               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    ldd       #$0079
                    pshs      d
                    lbsr      L3293
                    leas      $08,s
                    ldx       $02,s
                    bra       L1BCA

L1B98               clra
                    clrb
                    bra       L1BC4

L1B9C               ldd       ,s
                    cmpd      #$0070
                    bne       L1BBE
                    ldd       $06,s
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0051
                    pshs      d
                    lbsr      L3293
                    leas      $08,s
                    bra       L1BD8

L1BBE               ldd       $06,s
                    nega
                    negb
                    sbca      #$00
L1BC4               ldx       $0C,s
                    std       $08,x
                    bra       L1BD8

L1BCA               cmpx      #$003E
                    beq       L1B9C
                    cmpx      #$003F
                    lbeq      L1B9C
                    bra       L1B98

L1BD8               ldd       $0e,s
                    ldx       $0C,s
                    std       $06,x
                    clra
                    clrb
                    std       L0019
                    lbra      L1EB0

L1BE5               pshs      u
                    ldd       #$FFB4
                    lbsr      stkcheck
                    ldu       $04,s
                    pshs      u
                    bsr       L1C1E
                    leas      $02,s
                    ldd       $06,u
                    cmpd      #$0071
                    bne       L1C01
                    ldd       $08,u
                    beq       L1C17
L1C01               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3293
                    leas      $08,s
L1C17               ldd       #$0071
                    std       $06,u
                    puls      pc,u
L1C1E               pshs      u
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
                    lbra      L1E50

L1C42               ldd       $0C,s
                    pshs      d
                    lbsr      L1954
                    lbra      L1E4C

L1C4C               ldd       #$0071
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    lbsr      L1A9B
                    leas      $04,s
                    lbra      L1EB0

L1C5D               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$007F
                    pshs      d
                    lbsr      L3293
                    leas      $08,s
                    clra
                    clrb
                    lbra      L1E3D

L1C78               ldd       $0C,s
                    pshs      d
                    lbsr      L0BC4
                    lbra      L1E4C

L1C82               ldd       $06,u
                    cmpd      #$0041
                    beq       L1C93
                    ldx       $06,s
                    ldd       $12,x
                    lbne      L1D31
L1C93               ldd       $06,u
                    pshs      d
                    lbsr      L1EB4
                    std       ,s++
                    bne       L1CA6
                    ldd       $06,u
                    cmpd      #$0041
                    bne       L1CFA
L1CA6               ldx       $06,s
                    ldd       $06,x
                    cmpd      #$0036
                    bne       L1CC2
                    pshs      u
                    lbsr      L1C1E
                    leas      $02,s
                    ldd       $06,u
                    std       ,s
                    ldx       $06,s
                    ldd       $08,x
                    lbra      L1E27

L1CC2               ldd       $06,s
                    pshs      d
                    lbsr      L0BC4
                    leas      $02,s
                    pshs      u
                    lbsr      L1C1E
                    leas      $02,s
                    ldd       $02,s
                    cmpd      #$0051
                    bne       L1CE4
                    ldd       #$0043
                    pshs      d
                    lbsr      L3293
                    leas      $02,s
L1CE4               ldd       $06,u
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$007B
                    pshs      d
                    lbsr      L3293
                    leas      $06,s
                    lbra      L1E25

L1CFA               ldd       $02,s
                    cmpd      #$0050
                    bne       L1D19
                    ldd       $12,u
                    ldx       $06,s
                    cmpd      $12,x
                    bge       L1D19
                    leas      -$02,s
                    stu       ,s
                    ldu       $08,s
                    ldd       ,s
                    std       $08,s
                    leas      $02,s
L1D19               ldd       $06,s
                    pshs      d
                    lbsr      L1441
                    std       ,s++
                    bne       L1D36
                    ldx       $06,s
                    ldd       $06,x
                    pshs      d
                    lbsr      L1EB4
                    std       ,s++
                    bne       L1D36
L1D31               leax      $08,s
                    lbra      L1E43

L1D36               pshs      u
                    lbsr      L1C1E
                    leas      $02,s
                    ldd       $06,u
                    anda      #$7f
                    tfr       d,x
                    lbra      L1D9B

L1D46               ldd       $02,s
                    cmpd      #$0050
                    bne       L1D6A
                    ldx       $06,s
                    ldd       $06,x
                    cmpd      #$0036
                    beq       L1D6A
                    ldd       $06,s
                    pshs      d
                    lbsr      L0BF8
                    leas      $02,s
                    clra
                    clrb
                    std       $08,u
                    leax      $08,s
                    lbra      L1E0B

L1D6A               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3293
                    leas      $08,s
                    clra
                    clrb
                    std       $08,u
                    bra       L1DD6

L1D86               ldd       $06,u
                    std       ,s
                    bra       L1DD6

L1D8C               leax      L1F08,pcr
                    pshs      x
                    pshs      u
                    lbsr      L484C
                    leas      $04,s
                    bra       L1DD6

L1D9B               cmpx      #$0070
                    lbeq      L1D46
                    cmpx      #$0034
                    beq       L1D6A
                    cmpx      #$0037
                    lbeq      L1D6A
                    cmpx      #$0093
                    lbeq      L1D6A
                    cmpx      #$0094
                    lbeq      L1D6A
                    cmpx      #$0095
                    lbeq      L1D6A
                    cmpx      #$0071
                    beq       L1DD6
                    cmpx      #$0076
                    beq       L1D86
                    cmpx      #$006F
                    lbeq      L1D86
                    bra       L1D8C

L1DD6               ldx       $06,s
                    ldd       $06,x
                    cmpd      #$0036
                    bne       L1DE6
                    ldx       $06,s
                    ldd       $08,x
                    bra       L1E27

L1DE6               ldd       $06,s
                    pshs      d
                    lbsr      L0BC4
                    leas      $02,s
                    ldd       $02,s
                    cmpd      #$0051
                    bne       L1E0D
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    ldd       #$0043
                    pshs      d
                    lbsr      L3293
                    leas      $06,s
                    bra       L1E0D

L1E0B               leas      -$08,x
L1E0D               ldd       ,s
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$007B
                    pshs      d
                    lbsr      L3293
                    leas      $06,s
                    ldd       #$0071
                    std       ,s
L1E25               clra
                    clrb
L1E27               std       $04,s
                    ldd       $02,s
                    cmpd      #$0050
                    bne       L1E35
                    ldd       $04,s
                    bra       L1E3B

L1E35               ldd       $04,s
                    nega
                    negb
                    sbca      #$00
L1E3B               addd      $08,u
L1E3D               ldx       $0C,s
                    std       $08,x
                    bra       L1EAA

L1E43               leas      -$08,x
L1E45               ldd       $0C,s
                    pshs      d
                    lbsr      L0D05
L1E4C               leas      $02,s
                    bra       L1EB0

L1E50               cmpx      #$0042
                    lbeq      L1C42
                    cmpx      #$0034
                    beq       L1EB0
                    cmpx      #$0076
                    beq       L1EB0
                    cmpx      #$006F
                    beq       L1EB0
                    cmpx      #$0036
                    beq       L1EB0
                    cmpx      #$0037
                    beq       L1EB0
                    cmpx      #$003E
                    lbeq      L1C4C
                    cmpx      #$003C
                    lbeq      L1C4C
                    cmpx      #$003D
                    lbeq      L1C4C
                    cmpx      #$003F
                    lbeq      L1C4C
                    cmpx      #$0041
                    lbeq      L1C5D
                    cmpx      #$0085
                    lbeq      L1C78
                    cmpx      #$0051
                    lbeq      L1C82
                    cmpx      #$0050
                    lbeq      L1C93
                    bra       L1E45

L1EAA               ldd       ,s
                    ldx       $0C,s
                    std       $06,x
L1EB0               leas      $08,s
                    puls      pc,u
L1EB4               pshs      u
                    ldd       #$FFC0
                    lbsr      stkcheck
                    ldd       $04,s
                    cmpd      #$006F
                    beq       L1ECC
                    ldd       $04,s
                    cmpd      #$0076
                    bne       L1ED1
L1ECC               ldd       #$0001
                    bra       L1ED3

L1ED1               clra
                    clrb
L1ED3               puls      pc,u
L1ED5               fcc       /translation/
                    fcb       $00
L1EE1               bcs       $1F5B
                    tst       $0000
L1EE5               fcc       /binary op./
                    fcb       $00
L1EF0               fcc       /indirection/
                    fcb       $00
L1EFC               fcc       /indirection/
                    fcb       $00
L1F08               fcc       /x translate/
                    fcb       $00
L1F14               pshs      u
                    ldd       #$FFAE
                    lbsr      stkcheck
                    ldu       $04,s
                    leas      -$04,s
                    ldd       $06,u
                    std       $02,s
                    tfr       d,x
                    lbra      L2070

L1F29               ldd       #$0001
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
                    bsr       L1F14
                    leas      $08,s
                    leax      $04,s
                    bra       L1F67

L1F49               clra
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
                    lbsr      L1F14
                    leas      $08,s
                    bra       L1F69

L1F67               leas      -$04,x
L1F69               ldd       ,s
                    pshs      d
                    lbsr      L4415
                    lbra      L1FD3

L1F73               ldd       #$0001
                    subd      $0e,s
                    pshs      d
                    ldd       $0C,s
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    ldd       $0a,u
                    lbra      L1FE3

L1F88               ldd       $0e,s
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    pshs      u
                    ldd       $0a,s
                    pshs      d
                    lbsr      L20EE
                    leas      $0a,s
                    lbra      L20EA

L1FA2               ldd       $08,u
                    beq       L1FB2
                    ldd       $0e,s
                    bne       L1FB2
                    clra
                    clrb
                    pshs      d
                    ldd       $0C,s
                    bra       L1FC4

L1FB2               ldd       $0e,s
                    lbeq      L20EA
                    ldd       $08,u
                    lbne      L20EA
                    clra
                    clrb
                    pshs      d
                    ldd       $0e,s
L1FC4               pshs      d
                    ldd       #$007C
                    lbra      L2067

L1FCC               ldd       $0a,u
                    pshs      d
                    lbsr      L0D05
L1FD3               leas      $02,s
                    ldd       $0e,s
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    ldd       $0C,u
L1FE3               pshs      d
                    lbsr      L1F14
                    leas      $08,s
                    lbra      L20EA

L1FED               ldd       ,u
                    cmpd      #$0008
                    bne       L200D
                    pshs      u
                    lbsr      L2506
                    leas      $02,s
                    ldd       #$008B
                    pshs      d
                    ldd       #$0088
                    pshs      d
                    lbsr      L3293
                    leas      $04,s
                    bra       L204E

L200D               ldd       ,u
                    cmpd      #$0005
                    beq       L201D
                    ldd       ,u
                    cmpd      #$0006
                    bne       L2043
L201D               ldd       $06,u
                    cmpd      #$008C
                    bne       L2027
L2025               ldu       $0a,u
L2027               pshs      u
                    lbsr      L29FD
                    leas      $02,s
                    ldd       ,u
                    pshs      d
                    ldd       #$008B
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L3293
                    leas      $06,s
                    bra       L204E

L2043               pshs      u
                    lbsr      L2324
                    leas      $02,s
                    bra       L204E
                    leas      -$04,x
L204E               ldd       $0e,s
                    beq       L205B
                    ldd       $0C,s
                    pshs      d
                    ldd       #$005A
                    bra       L2062

L205B               ldd       $0a,s
                    pshs      d
                    ldd       #$005B
L2062               pshs      d
                    ldd       #$0082
L2067               pshs      d
                    lbsr      L3293
                    leas      $06,s
                    bra       L20EA

L2070               cmpx      #$0047
                    lbeq      L1F29
                    cmpx      #$0048
                    lbeq      L1F49
                    cmpx      #$0040
                    lbeq      L1F73
                    cmpx      #$005A
                    lbeq      L1F88
                    cmpx      #$005B
                    lbeq      L1F88
                    cmpx      #$005C
                    lbeq      L1F88
                    cmpx      #$005D
                    lbeq      L1F88
                    cmpx      #$005E
                    lbeq      L1F88
                    cmpx      #$005F
                    lbeq      L1F88
                    cmpx      #$0060
                    lbeq      L1F88
                    cmpx      #$0061
                    lbeq      L1F88
                    cmpx      #$0062
                    lbeq      L1F88
                    cmpx      #$0063
                    lbeq      L1F88
                    cmpx      #$0036
                    lbeq      L1FA2
                    cmpx      #$004B
                    lbeq      L1FA2
                    cmpx      #$004A
                    lbeq      L1FA2
                    cmpx      #$0030
                    lbeq      L1FCC
                    lbra      L1FED

L20EA               leas      $04,s
                    puls      pc,u
L20EE               pshs      u
                    ldd       #$FFAE
                    lbsr      stkcheck
                    leas      -$06,s
                    ldx       $0C,s
                    ldd       $0a,x
                    std       ,s
                    ldx       $0C,s
                    ldu       $0C,x
                    ldd       $12,s
                    beq       L210C
                    ldd       $10,s
                    bra       L210E

L210C               ldd       $0e,s
L210E               std       $02,s
                    ldd       $12,s
                    beq       L2120
                    ldd       $0a,s
                    pshs      d
                    lbsr      L2467
                    leas      $02,s
                    bra       L2122

L2120               ldd       $0a,s
L2122               std       $0a,s
                    ldd       [,s]
                    cmpd      #$0008
                    bne       L2135
                    ldd       $0C,s
                    pshs      d
                    lbsr      L2521
                    bra       L214C

L2135               ldd       [,s]
                    cmpd      #$0005
                    beq       L2145
                    ldd       [,s]
                    cmpd      #$0006
                    bne       L2153
L2145               ldd       $0C,s
                    pshs      d
                    lbsr      L2A18
L214C               leas      $02,s
                    leax      $06,s
                    lbra      L22B3

L2153               ldd       ,s
                    pshs      d
                    lbsr      L24E7
                    std       ,s++
                    bne       L218A
                    ldd       ,s
                    pshs      d
                    lbsr      L22CB
                    std       ,s++
                    beq       L2172
                    pshs      u
                    lbsr      L22CB
                    std       ,s++
                    beq       L218A
L2172               ldd       $06,u
                    pshs      d
                    lbsr      L1EB4
                    std       ,s++
                    beq       L219D
                    ldx       ,s
                    ldd       $06,x
                    pshs      d
                    lbsr      L1EB4
                    std       ,s++
                    bne       L219D
L218A               ldd       ,s
                    std       $04,s
                    stu       ,s
                    ldu       $04,s
                    ldd       $0a,s
                    pshs      d
                    lbsr      L249F
                    leas      $02,s
                    std       $0a,s
L219D               ldx       ,s
                    ldd       $06,x
                    std       $04,s
                    pshs      d
                    lbsr      L1EB4
                    std       ,s++
                    lbeq      L2220
                    pshs      u
                    lbsr      L0D05
                    leas      $02,s
                    ldx       $06,u
                    bra       L21F9

L21B9               pshs      u
                    lbsr      L0C2E
                    leas      $02,s
                    leax      $06,s
                    bra       L21E1

L21C4               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3293
                    leas      $08,s
                    ldd       #$0070
                    std       $06,u
                    bra       L21E3

L21E1               leas      -$06,x
L21E3               ldd       $06,u
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3293
                    leas      $04,s
                    ldd       #$006E
                    std       $06,u
                    lbra      L229C

L21F9               cmpx      #$0041
                    beq       L21B9
                    cmpx      #$0085
                    beq       L21C4
                    cmpx      #$0071
                    beq       L21E3
                    cmpx      #$0076
                    lbeq      L21E3
                    cmpx      #$006F
                    lbeq      L21E3
                    cmpx      #$0070
                    lbeq      L21E3
                    lbra      L229C

L2220               pshs      u
                    lbsr      L24E7
                    std       ,s++
                    beq       L223D
                    ldd       $0a,s
                    cmpd      #$0060
                    bge       L223D
                    ldd       ,s
                    pshs      d
                    lbsr      L2324
                    leas      $02,s
                    lbra      L22B5

L223D               ldd       ,s
                    pshs      d
                    lbsr      L0C2E
                    leas      $02,s
                    ldx       ,s
                    ldd       $06,x
                    std       $04,s
                    pshs      u
                    lbsr      L1441
                    std       ,s++
                    bne       L2266
                    ldd       $04,s
                    cmpd      #$0070
                    bne       L226F
                    pshs      u
                    lbsr      L22CB
                    std       ,s++
                    beq       L226F
L2266               pshs      u
                    lbsr      L0D05
                    leas      $02,s
                    bra       L229C

L226F               ldd       $04,s
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3293
                    leas      $04,s
                    ldd       #$006E
                    ldx       ,s
                    std       $06,x
                    pshs      u
                    lbsr      L0C2E
                    leas      $02,s
                    ldd       $06,u
                    std       $04,s
                    ldu       ,s
                    ldd       $0a,s
                    pshs      d
                    lbsr      L249F
                    leas      $02,s
                    std       $0a,s
L229C               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       #$0081
                    pshs      d
                    lbsr      L3293
                    leas      $08,s
                    bra       L22B5

L22B3               leas      -$06,x
L22B5               ldd       $02,s
                    pshs      d
                    ldd       $0C,s
                    pshs      d
                    ldd       #$0082
                    pshs      d
                    lbsr      L3293
                    leas      $06,s
                    leas      $06,s
                    puls      pc,u
L22CB               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    ldx       $04,s
                    ldx       $06,x
                    bra       L22E9

L22D9               ldd       #$0001
                    puls      pc,u
L22DE               ldd       $04,s
                    pshs      d
                    lbsr      L14DB
                    leas      $02,s
                    puls      pc,u
L22E9               cmpx      #$0034
                    beq       L22D9
                    cmpx      #$0036
                    lbeq      L22D9
                    cmpx      #$0042
                    beq       L22DE
                    lbra      L2502
                    pshs      u
                    ldd       #$FFC0
                    lbsr      stkcheck
                    ldx       $04,s
                    ldd       $06,x
                    cmpd      #$0034
                    lbne      L2502
                    ldx       $04,s
                    ldd       [$08,x]
                    cmpd      #$000D
                    lbne      L2502
                    ldd       #$0001
                    lbra      L2504

L2324               pshs      u
                    ldd       #$FFB0
                    lbsr      stkcheck
                    ldu       $04,s
                    leas      -$04,s
                    clra
                    clrb
                    std       ,s
                    ldx       $06,u
                    bra       L2389

L2338               ldd       $0C,u
                    std       $02,s
                    tfr       d,x
                    ldd       $06,x
                    cmpd      #$0036
                    bne       L2381
                    ldx       $02,s
                    ldd       $08,x
                    cmpd      #$00FF
                    lbls      L23FF
                    bra       L2381

L2354               ldx       $0a,u
                    ldd       $06,x
                    pshs      d
                    lbsr      L1EB4
                    std       ,s++
                    lbeq      L23FF
                    ldd       $0C,u
                    pshs      d
                    lbsr      L22CB
                    std       ,s++
                    lbne      L23FF
                    bra       L2381

L2372               ldx       $0a,u
                    ldd       $06,x
                    pshs      d
                    lbsr      L1EB4
                    std       ,s++
                    lbeq      L23FF
L2381               ldd       #$0001
                    std       ,s
                    lbra      L23FF

L2389               cmpx      #$0057
                    beq       L2338
                    cmpx      #$0078
                    beq       L2354
                    cmpx      #$003E
                    beq       L2372
                    cmpx      #$003F
                    lbeq      L2372
                    cmpx      #$003D
                    lbeq      L2372
                    cmpx      #$003C
                    lbeq      L2372
                    cmpx      #$00A0
                    lbeq      L2372
                    cmpx      #$00A1
                    lbeq      L2372
                    cmpx      #$00A7
                    lbeq      L2372
                    cmpx      #$00A8
                    lbeq      L2372
                    cmpx      #$00A9
                    lbeq      L2372
                    cmpx      #$0076
                    beq       L2381
                    cmpx      #$006F
                    lbeq      L2381
                    cmpx      #$0058
                    lbeq      L2381
                    cmpx      #$0059
                    lbeq      L2381
                    cmpx      #$0044
                    lbeq      L2381
                    cmpx      #$0043
                    lbeq      L2381
                    cmpx      #$0065
                    lbeq      L2381
L23FF               clra
L2400               clrb
                    std       L0019
                    pshs      u
                    lbsr      L0D05
                    leas      $02,s
                    ldx       $06,u
                    bra       L2442

L240E               ldd       ,s
                    bne       L2416
                    ldd       L0019
                    beq       L2463
L2416               clra
                    clrb
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       $06,u
                    pshs      d
                    ldd       #$0081
                    bra       L2439

L2428               ldu       $0a,u
L242A               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
L2439               pshs      d
                    lbsr      L3293
                    leas      $08,s
                    bra       L2463

L2442               cmpx      #$0071
                    beq       L240E
                    cmpx      #$0070
                    lbeq      L240E
                    cmpx      #$0076
                    lbeq      L240E
                    cmpx      #$006F
                    lbeq      L240E
                    cmpx      #$0085
                    beq       L2428
                    bra       L242A

L2463               leas      $04,s
                    puls      pc,u
L2467               pshs      u
                    ldd       #$FFC0
                    lbsr      stkcheck
                    ldx       $04,s
                    bra       L2491

L2473               ldd       #$005B
                    puls      pc,u
L2478               ldd       #$005A
                    puls      pc,u
L247D               ldd       $04,s
                    cmpd      #$005F
                    ble       L248A
                    ldd       #$00C3
                    bra       L248D

L248A               ldd       #$00BB
L248D               subd      $04,s
                    puls      pc,u
L2491               cmpx      #$005A
                    beq       L2473
                    cmpx      #$005B
                    beq       L2478
                    bra       L247D
                    puls      pc,u
L249F               pshs      u
                    ldd       #$FFC0
                    lbsr      stkcheck
                    ldx       $04,s
                    bra       L24BD

L24AB               ldd       $04,s
                    puls      pc,u
L24AF               ldd       $04,s
                    addd      #$0002
                    puls      pc,u
L24B6               ldd       $04,s
                    addd      #$FFFE
                    puls      pc,u
L24BD               cmpx      #$005A
                    beq       L24AB
                    cmpx      #$005B
                    lbeq      L24AB
                    cmpx      #$005C
                    beq       L24AF
                    cmpx      #$005D
                    lbeq      L24AF
                    cmpx      #$0060
                    lbeq      L24AF
                    cmpx      #$0061
                    lbeq      L24AF
                    bra       L24B6
                    puls      pc,u
L24E7               pshs      u
                    ldd       #$FFC0
                    lbsr      stkcheck
                    ldu       $04,s
                    ldd       $06,u
                    cmpd      #$0036
                    bne       L2502
                    ldd       $08,u
                    bne       L2502
                    ldd       #$0001
                    bra       L2504

L2502               clra
                    clrb
L2504               puls      pc,u
L2506               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    ldd       $04,s
                    pshs      d
                    bsr       L2521
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L28FC
                    leas      $02,s
                    puls      pc,u
L2521               pshs      u
                    ldd       #$FFAE
                    lbsr      stkcheck
                    ldu       $04,s
                    leas      -$06,s
                    ldd       $06,u
                    std       $02,s
                    tfr       d,x
                    lbra      L2800

L2536               pshs      u
                    lbsr      L1954
                    leas      $02,s
                    pshs      u
                    lbsr      L152E
                    leas      $02,s
                    ldx       $06,u
                    bra       L2562

L2548               ldd       $08,u
                    lbeq      L28F8
                    pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$007B
                    pshs      d
                    lbsr      L3293
                    leas      $06,s
                    lbra      L27D7

L2562               cmpx      #$0093
                    beq       L2548
                    cmpx      #$0094
                    lbeq      L2548
                    cmpx      #$0095
                    lbeq      L2548
                    lbra      L28F8

L2578               ldd       $0a,u
                    pshs      d
                    lbsr      L0BC4
                    leas      $02,s
                    ldd       #$0086
                    lbra      L2759

L2587               ldd       $0a,u
                    pshs      d
                    lbsr      L29FD
                    leas      $02,s
                    ldd       $0a,u
                    pshs      d
                    ldd       #$0091
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L3293
                    leas      $06,s
                    lbra      L2765

L25A6               ldd       $0a,u
                    pshs      d
                    lbsr      L0BC4
                    leas      $02,s
                    ldd       #$0083
                    pshs      d
                    ldd       #$0088
                    pshs      d
                    lbsr      L3293
                    leas      $04,s
                    bra       L25C2

L25C0               leas      -$06,x
L25C2               ldd       #$0080
                    std       $06,u
                    lbra      L28F8

L25CA               ldd       $08,u
                    pshs      d
                    ldd       #$004A
                    pshs      d
                    ldd       #$0088
                    pshs      d
                    lbsr      L3293
                    leas      $06,s
                    ldd       #$0004
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L3204
                    bra       L260D

L25EB               leax      L2506,pcr
                    pshs      x
                    pshs      u
                    lbsr      L12E9
                    bra       L260D

L25F8               ldd       $0a,u
                    pshs      d
                    lbsr      L2506
                    leas      $02,s
                    ldd       $02,s
                    pshs      d
                    ldd       #$0088
                    pshs      d
                    lbsr      L3293
L260D               leas      $04,s
                    leax      $06,s
                    lbra      L27D5

L2614               clra
                    clrb
                    pshs      d
                    ldd       #$0080
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$007F
                    pshs      d
                    lbsr      L3293
                    leas      $08,s
                    ldd       #$0071
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3293
                    leas      $04,s
                    ldd       $0a,u
                    pshs      d
                    lbsr      L2506
                    leas      $02,s
                    ldd       $02,s
                    pshs      d
                    ldd       #$0088
                    pshs      d
                    lbsr      L3293
                    leas      $04,s
                    ldd       #$0089
                    pshs      d
                    ldd       #$0088
                    pshs      d
                    lbsr      L3293
                    leas      $04,s
                    ldd       $02,s
                    cmpd      #$003E
                    bne       L266F
                    ldd       #$003F
                    lbra      L2759

L266F               ldd       #$003E
                    lbra      L2759

L2675               pshs      u
                    lbsr      L1365
                    leas      $02,s
                    lbra      L2765

L267F               ldx       $0a,u
                    ldd       $06,x
                    cmpd      #$004A
                    bne       L2699
                    leas      -$02,s
                    ldd       $0a,u
                    std       ,s
                    ldd       $0C,u
                    std       $0a,u
                    ldd       ,s
                    std       $0C,u
                    leas      $02,s
L2699               ldx       $0C,u
                    ldd       $06,x
                    cmpd      #$004A
                    lbne      L26FA
                    ldx       $0C,u
                    ldd       $08,x
                    std       $04,s
                    ldd       [$04,s]
                    bne       L26FA
                    ldx       $04,s
                    ldd       $02,x
                    pshs      d
                    lbsr      L1220
                    leas      $02,s
                    std       ,s
                    beq       L26FA
                    ldd       #$0004
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L3204
                    leas      $04,s
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
                    bne       L26F1
                    ldd       #$0056
                    bra       L26F4

L26F1               ldd       #$0055
L26F4               std       $02,s
                    leax      $06,s
                    bra       L2734

L26FA               ldd       $0a,u
                    std       $04,s
                    ldx       $04,s
                    ldd       $06,x
                    cmpd      #$004A
                    bne       L2713
                    ldd       $04,s
                    pshs      d
                    lbsr      L294C
                    leas      $02,s
                    bra       L272B

L2713               ldd       $04,s
                    pshs      d
                    lbsr      L2506
                    leas      $02,s
                    ldd       #$006E
                    pshs      d
                    ldd       #$0088
                    pshs      d
                    lbsr      L3293
                    leas      $04,s
L272B               ldd       $0C,u
                    pshs      d
                    lbsr      L2506
                    bra       L2755

L2734               leas      -$06,x
L2736               ldd       $0a,u
                    pshs      d
                    lbsr      L2506
                    leas      $02,s
                    ldd       #$0071
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3293
                    leas      $04,s
                    ldd       $0C,u
                    pshs      d
                    lbsr      L0BC4
L2755               leas      $02,s
                    ldd       $02,s
L2759               pshs      d
                    ldd       #$0088
                    pshs      d
                    lbsr      L3293
                    leas      $04,s
L2765               leax      $06,s
                    lbra      L25C0

L276A               ldd       $0a,u
                    pshs      d
                    lbsr      L2506
                    leas      $02,s
                    ldd       #$0071
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3293
                    leas      $04,s
                    ldd       $0C,u
                    pshs      d
                    lbsr      L2506
                    leas      $02,s
                    leax      $06,s
                    bra       L27C2

L278F               leas      -$06,x
                    ldd       $0a,u
                    std       $04,s
                    pshs      d
                    lbsr      L2506
                    leas      $02,s
                    ldd       #$0071
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3293
                    leas      $04,s
                    ldd       $02,s
                    addd      #$FFB0
                    std       $06,u
                    ldd       #$0093
                    ldx       $04,s
                    std       $06,x
                    pshs      u
                    lbsr      L2521
                    leas      $02,s
                    bra       L27C4

L27C2               leas      -$06,x
L27C4               ldd       #$0089
                    pshs      d
                    ldd       #$0088
                    pshs      d
                    lbsr      L3293
                    leas      $04,s
                    bra       L27D7

L27D5               leas      -$06,x
L27D7               ldd       #$0093
                    std       $06,u
                    clra
                    clrb
                    std       $08,u
                    lbra      L28F8

L27E3               ldd       $02,s
                    cmpd      #$00A0
                    blt       L27F0
                    leax      $06,s
                    lbra      L278F

L27F0               leax      L29F7,pcr
                    pshs      x
                    pshs      u
                    lbsr      L484C
                    leas      $04,s
                    lbra      L28F8

L2800               cmpx      #$0080
                    lbeq      L28F8
                    cmpx      #$0093
                    lbeq      L28F8
                    cmpx      #$0094
                    lbeq      L28F8
                    cmpx      #$0095
                    lbeq      L28F8
                    cmpx      #$0034
                    lbeq      L28F8
                    cmpx      #$0042
                    lbeq      L2536
                    cmpx      #$0086
                    lbeq      L2578
                    cmpx      #$0091
                    lbeq      L2587
                    cmpx      #$0083
                    lbeq      L25A6
                    cmpx      #$004A
                    lbeq      L25CA
                    cmpx      #$0064
                    lbeq      L25EB
                    cmpx      #$003C
                    lbeq      L25F8
                    cmpx      #$003D
                    lbeq      L25F8
                    cmpx      #$0044
                    lbeq      L25F8
                    cmpx      #$0043
                    lbeq      L25F8
                    cmpx      #$003E
                    lbeq      L2614
                    cmpx      #$003F
                    lbeq      L2614
                    cmpx      #$0065
                    lbeq      L2675
                    cmpx      #$0052
                    lbeq      L267F
                    cmpx      #$0053
                    lbeq      L26FA
                    cmpx      #$005A
                    lbeq      L26FA
                    cmpx      #$005B
                    lbeq      L26FA
                    cmpx      #$005E
                    lbeq      L26FA
                    cmpx      #$005C
                    lbeq      L26FA
                    cmpx      #$005F
                    lbeq      L26FA
                    cmpx      #$005D
                    lbeq      L26FA
                    cmpx      #$0050
                    lbeq      L26FA
                    cmpx      #$0051
                    lbeq      L26FA
                    cmpx      #$0054
                    lbeq      L26FA
                    cmpx      #$0057
                    lbeq      L26FA
                    cmpx      #$0058
                    lbeq      L26FA
                    cmpx      #$0059
                    lbeq      L26FA
                    cmpx      #$0056
                    lbeq      L2736
                    cmpx      #$0055
                    lbeq      L2736
                    cmpx      #$0078
                    lbeq      L276A
                    lbra      L27E3

L28F8               leas      $06,s
                    puls      pc,u
L28FC               pshs      u
                    ldd       #$FFB4
                    lbsr      stkcheck
                    ldx       $04,s
                    ldx       $06,x
                    bra       L2939

L290A               ldd       $04,s
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$007F
                    pshs      d
                    lbsr      L3293
                    leas      $08,s
                    bra       L294A

L2924               ldd       $04,s
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       #$007B
                    pshs      d
                    lbsr      L3293
                    leas      $06,s
                    bra       L294A

L2939               cmpx      #$0034
                    beq       L290A
                    cmpx      #$0094
                    beq       L2924
                    cmpx      #$0095
                    lbeq      L2924
L294A               puls      pc,u
L294C               pshs      u
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
                    beq       L29AB
                    ldx       ,s
                    ldd       $02,x
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3293
                    leas      $08,s
                    ldd       #$0070
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3293
                    leas      $04,s
                    ldd       [,s]
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3293
                    leas      $08,s
                    bra       L29D2

L29AB               clra
                    clrb
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3293
                    leas      $08,s
                    ldd       #$0070
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3293
                    leas      $04,s
L29D2               ldd       #$0070
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3293
                    leas      $04,s
                    ldd       #$0004
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    lbsr      L3204
                    leas      $04,s
                    clra
                    clrb
                    std       $08,u
                    leas      $02,s
                    puls      pc,u
L29F7               fcc       /longs/
                    fcb       $00
L29FD               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    ldd       $04,s
                    pshs      d
                    bsr       L2A18
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L28FC
                    leas      $02,s
                    puls      pc,u
L2A18               pshs      u
                    ldd       #$FFAE
                    lbsr      stkcheck
                    ldu       $04,s
                    leas      -$08,s
                    ldd       ,u
                    std       $02,s
                    ldd       $06,u
                    std       $06,s
                    tfr       d,x
                    lbra      L2C60

L2A31               pshs      u
                    lbsr      L2521
                    leas      $02,s
                    lbra      L2D35

L2A3B               ldd       $0a,u
                    pshs      d
                    lbsr      L0BC4
                    leas      $02,s
                    bra       L2A48

L2A46               leas      -$08,x
L2A48               ldd       $06,s
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L3293
                    leas      $04,s
                    bra       L2A5A

L2A58               leas      -$08,x
L2A5A               ldd       #$0080
                    std       $06,u
                    lbra      L2D35

L2A62               ldd       $0a,u
                    pshs      d
                    lbsr      L2506
                    bra       L2A72

L2A6B               ldd       $0a,u
                    pshs      d
                    lbsr      L29FD
L2A72               leas      $02,s
                    leax      $08,s
                    bra       L2A46

L2A78               ldd       $08,u
                    pshs      d
                    ldd       #$004B
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L3293
                    leas      $06,s
                    ldd       #$0093
                    std       $06,u
                    ldd       #$0008
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L3204
                    leas      $04,s
                    lbra      L2C3C

L2AA1               leax      L29FD,pcr
                    pshs      x
                    pshs      u
                    lbsr      L12E9
                    leas      $04,s
                    bra       L2ACB

L2AB0               ldd       $0a,u
                    pshs      d
                    lbsr      L29FD
                    leas      $02,s
                    ldd       $02,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L3293
                    leas      $06,s
L2ACB               leax      $08,s
                    lbra      L2C35

L2AD0               ldd       #$0080
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$007F
                    pshs      d
                    lbsr      L3293
                    leas      $06,s
                    ldd       #$0071
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3293
                    leas      $04,s
                    ldd       $0a,u
                    pshs      d
                    lbsr      L29FD
                    leas      $02,s
                    ldd       $02,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L3293
                    leas      $06,s
                    ldd       $02,s
                    pshs      d
                    ldd       #$0089
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L3293
                    leas      $06,s
                    ldd       $02,s
                    pshs      d
                    ldd       $08,s
                    cmpd      #$003E
                    bne       L2B32
                    ldd       #$003F
                    bra       L2B35

L2B32               ldd       #$003E
L2B35               pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L3293
                    leas      $06,s
                    bra       L2B7B

L2B43               pshs      u
                    lbsr      L1365
                    leas      $02,s
                    bra       L2B7B

L2B4C               ldd       $0a,u
                    pshs      d
                    lbsr      L29FD
                    leas      $02,s
                    ldd       #$006E
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L3293
                    leas      $04,s
                    ldd       $0C,u
                    pshs      d
                    lbsr      L29FD
                    leas      $02,s
                    ldd       $06,s
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L3293
                    leas      $04,s
L2B7B               leax      $08,s
                    lbra      L2A58

L2B80               ldd       $0a,u
                    pshs      d
                    lbsr      L29FD
                    leas      $02,s
                    ldd       #$0071
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3293
                    leas      $04,s
                    ldd       $0C,u
                    pshs      d
                    lbsr      L29FD
                    leas      $02,s
                    leax      $08,s
                    lbra      L2C1E

L2BA6               leas      -$08,x
                    ldd       $0a,u
                    std       $04,s
                    ldd       $02,s
                    cmpd      #$0005
                    bne       L2BD8
                    ldx       $04,s
                    ldd       $0a,x
                    pshs      d
                    lbsr      L29FD
                    leas      $02,s
                    ldd       #$0071
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3293
                    leas      $04,s
                    ldd       #$008C
                    pshs      d
                    ldd       #$0087
                    bra       L2BE9

L2BD8               ldd       $04,s
                    pshs      d
                    lbsr      L29FD
                    leas      $02,s
                    ldd       #$0071
                    pshs      d
                    ldd       #$007A
L2BE9               pshs      d
                    lbsr      L3293
                    leas      $04,s
                    ldd       $06,s
                    addd      #$FFB0
                    std       $06,u
                    ldd       #$0093
                    ldx       $04,s
                    std       $06,x
                    pshs      u
                    lbsr      L2A18
                    leas      $02,s
                    ldd       $02,s
                    cmpd      #$0005
                    bne       L2C20
                    ldd       #$008D
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L3293
                    leas      $04,s
                    bra       L2C20

L2C1E               leas      -$08,x
L2C20               ldd       $02,s
                    pshs      d
                    ldd       #$0089
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L3293
                    leas      $06,s
                    bra       L2C37

L2C35               leas      -$08,x
L2C37               ldd       #$0093
                    std       $06,u
L2C3C               clra
                    clrb
                    std       $08,u
                    lbra      L2D35

L2C43               ldd       $06,s
                    cmpd      #$00A0
                    blt       L2C50
                    leax      $08,s
                    lbra      L2BA6

L2C50               leax      L2D39,pcr
                    pshs      x
                    pshs      u
                    lbsr      L484C
                    leas      $04,s
                    lbra      L2D35

L2C60               cmpx      #$0080
                    lbeq      L2D35
                    cmpx      #$0093
                    lbeq      L2D35
                    cmpx      #$0094
                    lbeq      L2D35
                    cmpx      #$0095
                    lbeq      L2D35
                    cmpx      #$0034
                    lbeq      L2D35
                    cmpx      #$0042
                    lbeq      L2A31
                    cmpx      #$0092
                    lbeq      L2A3B
                    cmpx      #$008E
                    lbeq      L2A3B
                    cmpx      #$0090
                    lbeq      L2A62
                    cmpx      #$008D
                    lbeq      L2A6B
                    cmpx      #$008C
                    lbeq      L2A6B
                    cmpx      #$004B
                    lbeq      L2A78
                    cmpx      #$0064
                    lbeq      L2AA1
                    cmpx      #$003C
                    lbeq      L2AB0
                    cmpx      #$003D
                    lbeq      L2AB0
                    cmpx      #$0043
                    lbeq      L2AB0
                    cmpx      #$003E
                    lbeq      L2AD0
                    cmpx      #$003F
                    lbeq      L2AD0
                    cmpx      #$0065
                    lbeq      L2B43
                    cmpx      #$005A
                    lbeq      L2B4C
                    cmpx      #$005B
                    lbeq      L2B4C
                    cmpx      #$005E
                    lbeq      L2B4C
                    cmpx      #$005C
                    lbeq      L2B4C
                    cmpx      #$005F
                    lbeq      L2B4C
                    cmpx      #$005D
                    lbeq      L2B4C
                    cmpx      #$0050
                    lbeq      L2B4C
                    cmpx      #$0051
                    lbeq      L2B4C
                    cmpx      #$0052
                    lbeq      L2B4C
                    cmpx      #$0053
                    lbeq      L2B4C
                    cmpx      #$0078
                    lbeq      L2B80
                    lbra      L2C43

L2D35               leas      $08,s
                    puls      pc,u
L2D39               fcc       /floats/
                    fcb       $00
L2D40               pshs      u
                    leax      $00CE,y
                    stx       L001B
                    ldd       #$0001
                    std       $0021
                    leax      $06,s
                    pshs      x
                    ldd       $06,s
                    bra       L2D66

L2D55               pshs      u
                    ldd       $04,s
                    std       L001B
                    ldd       #$0001
                    std       $0021
                    leax      $08,s
                    pshs      x
                    ldd       $08,s
L2D66               pshs      d
                    bsr       doprnt
                    leas      $04,s
                    puls      pc,u
                    pshs      u
                    ldd       $04,s
                    std       L001B
                    ldd       #$0002
                    std       $0021
                    leax      $08,s
                    pshs      x
                    ldd       $08,s
                    pshs      d
                    bsr       doprnt
                    leas      $04,s
                    clra
                    clrb
                    stb       [L001B,y]
                    puls      pc,u
doprnt              pshs      u
                    ldu       $04,s
                    leas      -$0b,s
                    bra       L2DA5

L2D95               ldb       $08,s
                    lbeq      L2F05
                    ldb       $08,s
                    sex
                    pshs      d
                    lbsr      L30E4
                    leas      $02,s
L2DA5               ldb       ,u+
                    stb       $08,s
                    cmpb      #$25
                    bne       L2D95
                    ldb       ,u+
                    stb       $08,s
                    clra
                    clrb
                    std       $02,s
                    std       $06,s
                    ldb       $08,s
                    cmpb      #$2d
                    bne       L2DC8
                    ldd       #$0001
                    std       L001D
                    ldb       ,u+
                    stb       $08,s
                    bra       L2DCC

L2DC8               clra
                    clrb
                    std       L001D
L2DCC               ldb       $08,s
                    cmpb      #$30
                    bne       L2DD7
                    ldd       #$0030
                    bra       L2DDA

L2DD7               ldd       #$0020
L2DDA               std       $001F
                    bra       L2DF8

L2DDE               ldd       $06,s
                    pshs      d
                    ldd       #$000A
                    lbsr      $5E90
                    pshs      d
                    ldb       $0a,s
                    sex
                    addd      #$FFD0
                    addd      ,s++
                    std       $06,s
                    ldb       ,u+
                    stb       $08,s
L2DF8               ldb       $08,s
                    sex
                    leax      $0192,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$08
                    bne       L2DDE
                    ldb       $08,s
                    cmpb      #$2e
                    bne       L2E41
                    ldd       #$0001
                    std       $04,s
                    bra       L2E2B

L2E15               ldd       $02,s
                    pshs      d
                    ldd       #$000A
                    lbsr      $5E90
                    pshs      d
                    ldb       $0a,s
                    sex
                    addd      #$FFD0
                    addd      ,s++
                    std       $02,s
L2E2B               ldb       ,u+
                    stb       $08,s
                    ldb       $08,s
                    sex
                    leax      $0192,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$08
                    bne       L2E15
                    bra       L2E45

L2E41               clra
                    clrb
                    std       $04,s
L2E45               ldb       $08,s
                    sex
                    tfr       d,x
                    lbra      L2EE7

L2E4D               ldd       $06,s
                    pshs      d
                    ldx       $13,s
                    leax      $02,x
                    stx       $13,s
                    ldd       -$02,x
                    pshs      d
                    lbsr      L2F09
                    bra       L2E75

L2E62               ldd       $06,s
                    pshs      d
                    ldx       $13,s
                    leax      $02,x
                    stx       $13,s
                    ldd       -$02,x
                    pshs      d
                    lbsr      L2FCA
L2E75               std       ,s
                    lbra      L2ED2

L2E7A               ldx       $11,s
                    leax      $02,x
                    stx       $11,s
                    ldd       -$02,x
                    lbra      L2EDD

L2E87               ldx       $11,s
                    leax      $02,x
                    stx       $11,s
                    ldd       -$02,x
                    std       $09,s
                    ldd       $04,s
                    beq       L2ECA
                    ldd       $09,s
                    std       $04,s
                    bra       L2EA9

L2E9D               ldb       [$09,s]
                    beq       L2EB5
                    ldd       $09,s
                    addd      #$0001
                    std       $09,s
L2EA9               ldd       $02,s
                    addd      #$FFFF
                    std       $02,s
                    subd      #$FFFF
                    bne       L2E9D
L2EB5               ldd       $06,s
                    pshs      d
                    ldd       $0b,s
                    subd      $06,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L3089
                    leas      $06,s
                    bra       L2ED7

L2ECA               ldd       $06,s
                    pshs      d
                    ldd       $0b,s
                    pshs      d
L2ED2               lbsr      L3029
                    leas      $04,s
L2ED7               lbra      L2DA5

L2EDA               ldb       $08,s
                    sex
L2EDD               pshs      d
                    lbsr      L30E4
                    leas      $02,s
                    lbra      L2DA5

L2EE7               cmpx      #$0064
                    lbeq      L2E4D
                    cmpx      #$0078
                    lbeq      L2E62
                    cmpx      #$0063
                    lbeq      L2E7A
                    cmpx      #$0073
                    lbeq      L2E87
                    bra       L2EDA

L2F05               leas      $0b,s
                    puls      pc,u
L2F09               pshs      u,d
                    leax      $0286,y
                    stx       ,s
                    ldd       $06,s
                    bge       L2F3E
                    ldd       $06,s
                    nega
                    negb
                    sbca      #$00
                    std       $06,s
                    bge       L2F33
                    leax      L3109,pcr
                    pshs      x
                    leax      $0286,y
                    pshs      x
                    lbsr      L5600
                    leas      $04,s
                    lbra      L30E0

L2F33               ldd       #$002D
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
L2F3E               ldd       $06,s
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    bsr       L2F53
                    leas      $04,s
                    leax      $0286,y
                    tfr       x,d
                    lbra      L30E0

L2F53               pshs      u,y,x,d
                    ldu       $0a,s
                    clra
                    clrb
                    std       $02,s
                    clra
                    clrb
                    std       ,s
                    bra       L2F70

L2F61               ldd       ,s
                    addd      #$0001
                    std       ,s
                    ldd       $0C,s
                    subd      >$0043,y
                    std       $0C,s
L2F70               ldd       $0C,s
                    blt       L2F61
                    leax      >$0043,y
                    stx       $04,s
                    bra       L2FB2

L2F7C               ldd       ,s
                    addd      #$0001
                    std       ,s
L2F83               ldd       $0C,s
                    subd      [$04,s]
                    std       $0C,s
                    bge       L2F7C
                    ldd       $0C,s
                    addd      [$04,s]
                    std       $0C,s
                    ldd       ,s
                    beq       L2F9C
                    ldd       #$0001
                    std       $02,s
L2F9C               ldd       $02,s
                    beq       L2FA7
                    ldd       ,s
                    addd      #$0030
                    stb       ,u+
L2FA7               clra
                    clrb
                    std       ,s
                    ldd       $04,s
                    addd      #$0002
                    std       $04,s
L2FB2               ldd       $04,s
                    cmpd      $0001
                    bne       L2F83
                    ldd       $0C,s
                    addd      #$0030
                    stb       ,u+
                    clra
                    clrb
                    stb       ,u
                    ldd       $0a,s
                    leas      $06,s
                    puls      pc,u
L2FCA               pshs      u,x,d
                    leax      $0286,y
                    stx       $02,s
                    leau      $0290,y
L2FD6               ldd       $08,s
                    clra
                    andb      #$0f
                    std       ,s
                    pshs      d
                    ldd       $02,s
                    cmpd      #$0009
                    ble       L2FEC
                    ldd       #$0057
                    bra       L2FEF

L2FEC               ldd       #$0030
L2FEF               addd      ,s++
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
                    bne       L2FD6
                    bra       L300F

L3005               ldb       ,u
                    ldx       $02,s
                    leax      $01,x
                    stx       $02,s
                    stb       -$01,x
L300F               leau      -$01,u
                    pshs      u
                    leax      $0290,y
                    cmpx      ,s++
                    bls       L3005
                    clra
                    clrb
                    stb       [$02,s]
                    leax      $0286,y
                    tfr       x,d
                    lbra      L3105

L3029               pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    pshs      d
                    lbsr      L55EF
                    leas      $02,s
                    nega
                    negb
                    sbca      #$00
                    leau      d,u
                    ldd       L001D
                    bne       L3060
                    bra       L304D

L3044               ldd       $001F
                    pshs      d
                    lbsr      L30E4
                    leas      $02,s
L304D               tfr       u,d
                    leau      -$01,u
                    std       -$02,s
                    bgt       L3044
                    bra       L3060

L3057               ldd       ,s
                    pshs      d
                    lbsr      L30E4
                    leas      $02,s
L3060               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    sex
                    std       ,s
                    bne       L3057
                    ldd       L001D
                    lbeq      L30E0
                    bra       L307E

L3075               ldd       $001F
                    pshs      d
                    lbsr      L30E4
                    leas      $02,s
L307E               tfr       u,d
                    leau      -$01,u
                    std       -$02,s
                    bgt       L3075
                    lbra      L30E0

L3089               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    ldd       $0a,s
                    subd      $08,s
                    std       ,s
                    ldd       L001D
                    bne       L30BA
                    bra       L30A3

L309B               ldd       $001F
                    pshs      d
                    bsr       L30E4
                    leas      $02,s
L30A3               ldd       ,s
                    addd      #$FFFF
                    std       ,s
                    subd      #$FFFF
                    bgt       L309B
                    bra       L30BA

L30B1               ldb       ,u+
                    sex
                    pshs      d
                    bsr       L30E4
                    leas      $02,s
L30BA               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bne       L30B1
                    ldd       L001D
                    beq       L30E0
                    bra       L30D4

L30CC               ldd       $001F
                    pshs      d
                    bsr       L30E4
                    leas      $02,s
L30D4               ldd       ,s
                    addd      #$FFFF
                    std       ,s
                    subd      #$FFFF
                    bgt       L30CC
L30E0               leas      $02,s
                    puls      pc,u
L30E4               pshs      u
                    ldd       $0021
                    cmpd      #$0002
                    bne       L30FA
                    ldd       $04,s
                    ldx       L001B
                    leax      $01,x
                    stx       L001B
                    stb       -$01,x
                    bra       L3107

L30FA               ldd       L001B
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L515F
L3105               leas      $04,s
L3107               puls      pc,u
L3109               blt       $313E
                    leas      -$09,y
                    pshu      y,x,dp
                    neg       $0034
                    rorb
                    ldd       $08,s
                    pshs      d
                    lbsr      L31AF
                    leas      $02,s
                    std       ,s
                    lbeq      L31A0
                    ldd       >$004b,y
                    std       $02,s
                    bne       L313F
                    leax      $029a,y
                    stx       $02,s
                    tfr       x,d
                    std       >$004b,y
                    std       $029a,y
                    clra
                    clrb
                    std       $029C,y
L313F               ldu       [$02,s]
L3142               ldd       $02,u
                    cmpd      ,s
                    bcs       L318B
                    ldd       $02,u
                    cmpd      ,s
                    bne       L3157
                    ldd       ,u
                    std       [$02,s]
                    bra       L3167

L3157               ldd       $02,u
                    subd      ,s
                    std       $02,u
                    aslb
                    rola
                    aslb
                    rola
                    leau      d,u
                    ldd       ,s
                    std       $02,u
L3167               ldd       $02,s
                    std       >$004b,y
                    stu       $02,s
                    bra       L317B

L3171               ldx       $02,s
                    leax      $01,x
                    stx       $02,s
                    clra
                    clrb
                    stb       -$01,x
L317B               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bne       L3171
                    tfr       u,d
                    bra       L31AB

L318B               cmpu      >$004b,y
                    bne       L31A4
                    ldd       ,s
                    pshs      d
                    bsr       L31BC
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    bne       L31A4
L31A0               clra
                    clrb
                    bra       L31AB

L31A4               stu       $02,s
                    ldu       ,u
                    lbra      L3142

L31AB               leas      $04,s
                    puls      pc,u
L31AF               pshs      u
                    ldd       $04,s
                    addd      #$0003
                    lsra
                    rorb
                    lsra
                    rorb
                    puls      pc,u
L31BC               pshs      u,d
                    ldd       $06,s
                    addd      #$007F
                    pshs      d
                    ldd       #$0007
                    lbsr      L5FBA
                    pshs      d
                    ldd       #$0007
                    lbsr      $5FD1
                    std       ,s
                    pshs      d
                    ldd       #$0004
                    lbsr      $5E90
                    std       ,s
                    pshs      d
                    lbsr      L6198
                    leas      $02,s
                    tfr       d,u
                    cmpu      #$FFFF
                    bne       L31F3
                    clra
                    clrb
                    lbra      L328F

L31F3               ldd       ,s
                    pshs      d
                    pshs      u
                    bsr       L3204
                    leas      $04,s
                    ldd       >$004b,y
                    lbra      L328F

L3204               pshs      u,d
                    ldu       $06,s
                    lbeq      L328F
                    ldd       $08,s
                    pshs      d
                    lbsr      L31AF
                    leas      $02,s
                    std       $08,s
                    ldd       >$004b,y
                    bra       L3230

L321D               ldd       ,s
                    cmpd      [,s]
                    bcs       L322E
                    cmpu      ,s
                    bhi       L323E
                    cmpu      [,s]
                    bcs       L323E
L322E               ldd       [,s]
L3230               std       ,s
                    cmpu      ,s
                    bls       L321D
                    cmpu      [,s]
                    lbcc      L321D
L323E               pshs      u
                    ldd       $0a,s
                    aslb
                    rola
                    aslb
                    rola
                    addd      ,s++
                    cmpd      [,s]
                    bne       L3260
                    ldd       $08,s
                    pshs      d
                    ldx       [$02,s]
                    ldd       $02,x
                    addd      ,s++
                    std       $08,s
                    ldx       ,s
                    ldd       [,x]
                    bra       L3262

L3260               ldd       [,s]
L3262               std       ,u
                    ldx       ,s
                    ldd       $02,x
                    aslb
                    rola
                    aslb
                    rola
                    addd      ,s
                    pshs      d
                    cmpu      ,s++
                    bne       L3283
                    ldx       ,s
                    ldd       $02,x
                    addd      $08,s
                    std       $02,x
                    ldd       ,u
                    std       [,s]
                    bra       L3285

L3283               stu       [,s]
L3285               ldd       $08,s
                    std       $02,u
                    ldd       ,s
                    std       >$004b,y
L328F               leas      $02,s
                    puls      pc,u
L3293               pshs      u
                    ldu       $0a,s
                    leas      -$08,s
                    ldd       $0C,s
                    cmpd      #$0088
                    bne       L32B1
                    ldd       $10,s
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    lbsr      L39DA
                    lbra      L3800

L32B1               ldd       $0C,s
                    cmpd      #$0087
                    bne       L32C9
                    ldd       $10,s
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    lbsr      L3BC3
                    lbra      L3800

L32C9               ldx       $0C,s
                    lbra      L3549

L32CE               ldd       $0e,s
                    pshs      d
                    lbsr      L3988
                    std       ,s
                    leax      L44F5,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      L2D55
                    leas      $06,s
                    ldd       $000D
                    subd      #$0002
                    std       $000D
                    cmpd      L0017
                    lbge      L39D6
                    ldd       $000D
                    std       L0017
                    lbra      L39D6

L32FB               ldd       $10,s
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$0081
                    pshs      d
                    lbsr      L3293
                    leas      $08,s
                    ldd       $0e,s
                    std       $10,s
                    ldd       #$005A
                    std       $0e,s
L331E               leax      $44FF,pcr
                    pshs      x
                    lbsr      L43B9
                    leas      $02,s
                    ldd       $0e,s
                    pshs      d
                    lbsr      L4333
                    std       ,s
                    lbra      L3401

L3335               leax      $4502,pcr
                    lbra      L34A2

L333C               pshs      u
                    ldd       $12,s
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    lbsr      L3EA5
                    leas      $06,s
                    lbra      L39D6

L3350               leax      $450D,pcr
                    bra       L337E

L3356               leax      L4514,pcr
                    bra       L337E

L335C               leax      L451B,pcr
                    bra       L337E

L3362               leax      L4521,pcr
                    bra       L337E

L3368               leax      L4527,pcr
                    bra       L337E

L336E               leax      L452D,pcr
                    bra       L337E

L3374               leax      L4533,pcr
                    bra       L337E

L337A               leax      L453A,pcr
L337E               pshs      x
                    lbsr      L3E52
                    lbra      L3786

L3386               leax      L4540,pcr
                    lbra      L34A2

L338D               leax      L4554,pcr
                    lbra      L34A2

L3394               leax      L455F,pcr
                    pshs      x
                    lbsr      L43B9
                    leas      $02,s
                    ldd       $000D
                    nega
                    negb
                    sbca      #$00
                    pshs      d
                    lbsr      L4408
                    leas      $02,s
                    ldd       >$004f,y
                    pshs      d
                    lbsr      L43F7
                    leas      $02,s
                    lbsr      L43DD
L33BA               ldd       >$0053,y
                    pshs      d
                    lbsr      L43B9
                    leas      $02,s
                    ldd       $0e,s
                    bra       L3409

L33C9               ldd       >$0053,y
                    pshs      d
                    lbsr      L43B9
                    leas      $02,s
                    ldd       $10,s
                    pshs      d
                    lbsr      L4415
                    leas      $02,s
                    ldd       $0e,s
                    pshs      d
                    lbsr      L4415
                    leas      $02,s
                    leax      L4565,pcr
                    pshs      x
                    lbsr      L43B9
                    leas      $02,s
                    ldd       $000D
                    pshs      d
                    lbsr      L4408
                    leas      $02,s
                    leax      L456B,pcr
                    pshs      x
L3401               lbsr      L43F7
                    leas      $02,s
                    ldd       $10,s
L3409               pshs      d
                    lbsr      L4415
                    lbra      L3786

L3411               ldd       #$0004
                    std       $000F
                    ldx       $10,s
                    ldd       $06,x
                    cmpd      #$0034
                    bne       L3446
                    ldx       $10,s
                    ldd       $08,x
                    std       $04,s
                    beq       L3446
                    ldd       >$0051,y
                    pshs      d
                    lbsr      L43B9
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    ldd       $06,s
                    addd      #$0004
                    pshs      d
                    lbsr      L4472
                    lbra      L3800

L3446               leax      L456F,pcr
                    pshs      x
                    lbsr      L43B9
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    ldd       $12,s
                    pshs      d
                    ldd       $12,s
                    pshs      d
                    lbsr      L40D1
                    leas      $06,s
                    lbra      L34D9

L3467               leax      L4574,pcr
                    bra       L34A2

L346D               leax      $4578,pcr
                    pshs      x
                    lbsr      L43B9
                    leas      $02,s
                    ldd       #$0002
                    pshs      d
                    ldd       $12,s
                    pshs      d
                    ldd       $12,s
                    pshs      d
                    ldd       #$0064
                    pshs      d
                    lbsr      L4086
                    lbra      L38D9

L3492               leax      L457B,pcr
                    bra       L34A2

L3498               leax      L4586,pcr
                    bra       L34A2

L349E               leax      L4591,pcr
L34A2               pshs      x
                    lbra      L3783

L34A7               leax      L459C,pcr
                    pshs      x
                    lbsr      L43B9
                    leas      $02,s
                    leax      $08,s
                    bra       L34C3

L34B6               leax      L45A1,pcr
                    pshs      x
                    lbsr      L43B9
                    leas      $02,s
                    bra       L34C5

L34C3               leas      -$08,x
L34C5               ldd       $0e,s
                    pshs      d
                    lbsr      L4408
                    leas      $02,s
                    ldd       >$004f,y
                    pshs      d
                    lbsr      L43F7
                    leas      $02,s
L34D9               lbsr      L43DD
                    lbra      L39D6

L34DF               leax      L45A6,pcr
                    pshs      x
                    lbsr      L43B9
                    leas      $02,s
                    ldx       $0e,s
                    bra       L353C

L34EE               ldx       $10,s
                    ldd       $06,x
                    std       $06,s
                    cmpd      #$0094
                    bne       L3500
                    ldd       #$0079
                    bra       L3510

L3500               ldd       $06,s
                    cmpd      #$0095
                    bne       L350D
                    ldd       #$0075
                    bra       L3510

L350D               ldd       #$0078
L3510               std       $06,s
                    pshs      d
                    ldx       $12,s
                    ldd       $08,x
                    pshs      d
                    leax      L45AC,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      L2D55
                    lbra      L38D9

L352B               ldd       $10,s
                    pshs      d
                    lbsr      L3988
                    std       ,s
                    leax      $45B3,pcr
                    lbra      L37A9

L353C               cmpx      #$0077
                    beq       L34EE
                    cmpx      #$0070
                    beq       L352B
                    lbra      L39D6

L3549               cmpx      #$007A
                    lbeq      L32CE
                    cmpx      #$007D
                    lbeq      L32FB
                    cmpx      #$0082
                    lbeq      L331E
                    cmpx      #$0012
                    lbeq      L3335
                    cmpx      #$0057
                    lbeq      L333C
                    cmpx      #$0058
                    lbeq      L333C
                    cmpx      #$0059
                    lbeq      L333C
                    cmpx      #$0052
                    lbeq      L3350
                    cmpx      #$004E
                    lbeq      L3356
                    cmpx      #$0053
                    lbeq      L335C
                    cmpx      #$0056
                    lbeq      L3362
                    cmpx      #$0055
                    lbeq      L3368
                    cmpx      #$004D
                    lbeq      L336E
                    cmpx      #$004C
                    lbeq      L3374
                    cmpx      #$0054
                    lbeq      L337A
                    cmpx      #$0043
                    lbeq      L3386
                    cmpx      #$0044
                    lbeq      L338D
                    cmpx      #$001D
                    lbeq      L3394
                    cmpx      #$007C
                    lbeq      L33BA
                    cmpx      #$0009
                    lbeq      L33C9
                    cmpx      #$0065
                    lbeq      L3411
                    cmpx      #$0085
                    lbeq      L3467
                    cmpx      #$0084
                    lbeq      L346D
                    cmpx      #$0098
                    lbeq      L3492
                    cmpx      #$0096
                    lbeq      L3498
                    cmpx      #$0097
                    lbeq      L349E
                    cmpx      #$0076
                    lbeq      L34A7
                    cmpx      #$006F
                    lbeq      L34B6
                    cmpx      #$007B
                    lbeq      L34DF
                    ldd       $0e,s
                    pshs      d
                    lbsr      L3988
                    leas      $02,s
                    std       $06,s
                    ldd       $10,s
                    cmpd      #$0077
                    lbne      L36A2
                    ldd       $06,u
                    cmpd      #$0085
                    bne       L3685
                    ldd       $0a,u
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       $12,s
                    pshs      d
                    lbsr      L3293
                    leas      $08,s
                    ldx       $0C,s
                    bra       L3667

L364E               leax      $45B9,pcr
                    bra       L365E

L3654               leax      $45BD,pcr
                    bra       L365E

L365A               leax      L45C5,pcr
L365E               pshs      x
                    lbsr      L43D2
                    leas      $02,s
                    bra       L367D

L3667               cmpx      #$0075
                    beq       L364E
                    cmpx      #$004F
                    beq       L3654
                    cmpx      #$0050
                    lbeq      L3654
                    cmpx      #$0051
                    beq       L365A
L367D               ldd       #$0070
                    std       $06,u
                    lbra      L39D6

L3685               ldd       ,u
                    cmpd      #$0002
                    bne       L36A2
                    ldd       $0C,s
                    cmpd      #$007F
                    beq       L36A2
                    ldd       $06,s
                    cmpd      #$0078
                    beq       L36A2
                    ldd       #$0062
                    std       $06,s
L36A2               ldx       $0C,s
                    lbra      L3947

L36A7               ldd       $10,s
                    cmpd      #$0077
                    lbne      L3766
                    ldd       $08,u
                    std       ,s
                    ldd       $06,u
                    std       $02,s
                    tfr       d,x
                    lbra      L3742

L36BF               ldd       $0e,s
                    cmpd      #$0070
                    beq       L36E4
                    ldd       $06,s
                    pshs      d
                    lbsr      L448F
                    leas      $02,s
                    ldd       $02,s
                    pshs      d
                    lbsr      L3988
                    std       ,s
                    ldd       $02,s
                    pshs      d
                    leax      L45CD,pcr
                    lbra      L38D0

L36E4               ldd       #$0064
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    lbsr      L3988
                    std       ,s
                    lbsr      L39BF
                    leas      $04,s
                    ldd       ,s
                    lbeq      L39D6
                    ldd       ,s
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0050
                    pshs      d
                    lbsr      L3293
                    lbra      L38D9

L3716               ldd       $0e,s
                    cmpd      #$0070
                    lbeq      L39D6
                    ldd       $06,s
                    pshs      d
                    ldd       #$0064
                    lbra      L37FB

L372A               ldd       $08,u
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L44A6
                    lbra      L3800

L3738               ldd       #$0036
                    std       $10,s
                    ldu       ,s
                    bra       L3766

L3742               cmpx      #$0071
                    lbeq      L36BF
                    cmpx      #$0076
                    lbeq      L36BF
                    cmpx      #$006F
                    lbeq      L36BF
                    cmpx      #$0070
                    beq       L3716
                    cmpx      #$0037
                    beq       L372A
                    cmpx      #$0036
                    beq       L3738
L3766               ldd       $0e,s
                    cmpd      #$0070
                    bne       L378B
                    ldd       $10,s
                    cmpd      #$0036
                    bne       L378B
                    cmpu      #$0000
                    bne       L378B
                    leax      $45D4,pcr
                    pshs      x
L3783               lbsr      L43D2
L3786               leas      $02,s
                    lbra      L39D6

L378B               leax      L45DF,pcr
                    lbra      L380F

L3792               ldd       $10,s
                    cmpd      #$0036
                    bne       L37B7
                    cmpu      #$0000
                    bne       L37B7
                    ldd       $06,s
                    pshs      d
                    leax      $45E2,pcr
L37A9               pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      L2D55
                    leas      $06,s
                    lbra      L39D6

L37B7               leax      L45EE,pcr
                    pshs      x
                    lbsr      L43B9
                    leas      $02,s
                    ldd       $06,s
                    cmpd      #$0062
                    bne       L3816
                    ldd       #$0064
                    std       $06,s
                    bra       L3816

L37D1               ldd       $10,s
                    cmpd      #$0077
                    bne       L3805
                    ldd       $06,u
                    std       $02,s
                    pshs      d
                    lbsr      L1EB4
                    std       ,s++
                    beq       L3805
                    ldd       $02,s
                    cmpd      $0e,s
                    lbeq      L39D6
                    ldd       $02,s
                    pshs      d
                    lbsr      L3988
                    std       ,s
                    ldd       $08,s
L37FB               pshs      d
                    lbsr      L39BF
L3800               leas      $04,s
                    lbra      L39D6

L3805               leax      $45F2,pcr
                    bra       L380F

L380B               leax      $45F5,pcr
L380F               pshs      x
                    lbsr      L43B9
                    leas      $02,s
L3816               leax      $08,s
                    bra       L382B

L381A               ldd       #$0043
                    pshs      d
                    lbsr      L3293
                    leas      $02,s
L3824               leax      $45F9,pcr
                    lbra      L38A3

L382B               leas      -$08,x
                    lbra      L38AA

L3830               ldd       $10,s
                    cmpd      #$0077
                    lbne      L389F
                    ldd       [$08,u]
                    std       $02,s
                    tfr       d,x
                    bra       L388C

L3844               ldd       $06,s
                    pshs      d
                    lbsr      L448F
                    leas      $02,s
                    ldd       #$003E
                    pshs      d
                    lbsr      L43E8
                    leas      $02,s
                    ldd       $02,s
                    cmpd      #$0023
                    bne       L386A
                    ldx       $08,u
                    ldd       $04,x
                    pshs      d
                    lbsr      L4420
                    bra       L3874

L386A               ldd       $08,u
                    addd      #$0004
                    pshs      d
                    lbsr      L4433
L3874               leas      $02,s
                    ldd       $14,u
                    pshs      d
                    lbsr      L40B0
                    leas      $02,s
                    ldd       >$004d,y
                    pshs      d
                    lbsr      L43F7
                    lbra      L3917

L388C               cmpx      #$0021
                    beq       L3844
                    cmpx      #$0022
                    lbeq      L3844
                    cmpx      #$0023
                    lbeq      L3844
L389F               leax      $45FD,pcr
L38A3               pshs      x
                    lbsr      L43B9
                    leas      $02,s
L38AA               clra
                    clrb
                    pshs      d
                    pshs      u
                    ldd       $14,s
                    pshs      d
                    ldd       $0C,s
                    pshs      d
                    lbsr      L4086
                    bra       L38D9

L38BE               ldd       $10,s
                    pshs      d
                    lbsr      L3988
                    std       ,s
                    ldd       $08,s
                    pshs      d
                    leax      $4601,pcr
L38D0               pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      L2D55
L38D9               leas      $08,s
                    lbra      L39D6

L38DE               ldd       $06,s
                    pshs      d
                    lbsr      L448F
                    leas      $02,s
                    ldx       $10,s
                    bra       L392D

L38EC               leax      $460D,pcr
                    pshs      x
                    lbsr      L43F7
                    leas      $02,s
                    leax      $08,s
                    bra       L390E

L38FB               pshs      u
                    lbsr      L4408
                    leas      $02,s
                    ldd       #$002C
                    pshs      d
                    lbsr      L43E8
                    leas      $02,s
                    bra       L3910

L390E               leas      -$08,x
L3910               ldd       $06,s
                    pshs      d
                    lbsr      L43E8
L3917               leas      $02,s
                    lbsr      L43DD
                    lbra      L39D6

L391F               leax      L4610,pcr
                    pshs      x
                    lbsr      L4824
                    leas      $02,s
                    lbra      L39D6

L392D               cmpx      #$0070
                    beq       L38EC
                    cmpx      #$0036
                    beq       L38FB
                    bra       L391F

L3939               ldd       >$0057,y
                    pshs      d
                    lbsr      L4824
                    leas      $02,s
                    lbra      L39D6

L3947               cmpx      #$0075
                    lbeq      L36A7
                    cmpx      #$0081
                    lbeq      L3792
                    cmpx      #$0079
                    lbeq      L37D1
                    cmpx      #$0051
                    lbeq      L380B
                    cmpx      #$004F
                    lbeq      L381A
                    cmpx      #$0050
                    lbeq      L3824
                    cmpx      #$007F
                    lbeq      L3830
                    cmpx      #$0073
                    lbeq      L38BE
                    cmpx      #$0074
                    lbeq      L38DE
                    bra       L3939

L3988               pshs      u
                    ldx       $04,s
                    bra       L39A7

L398E               ldd       #$0064
                    puls      pc,u
L3993               ldd       #$0078
                    puls      pc,u
L3998               ldd       #$0079
                    puls      pc,u
L399D               ldd       #$0075
                    puls      pc,u
L39A2               ldd       #$0020
                    puls      pc,u
L39A7               cmpx      #$0070
                    beq       L398E
                    cmpx      #$0071
                    beq       L3993
                    cmpx      #$0076
                    beq       L3998
                    cmpx      #$006F
                    beq       L399D
                    bra       L39A2
                    puls      pc,u
L39BF               pshs      u
                    ldd       $06,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    leax      L4618,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      L2D55
L39D6               leas      $08,s
                    puls      pc,u
L39DA               pshs      u
                    ldx       $04,s
                    lbra      L3AFA

L39E1               ldd       #$0002
                    pshs      d
                    ldd       #$0093
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3293
                    leas      $08,s
                    ldd       #$0070
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3293
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
                    lbsr      L3293
                    leas      $08,s
                    ldd       #$0070
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3293
                    lbra      L3BD6

L3A31               leax      L4624,pcr
                    pshs      x
                    lbsr      L43D2
                    lbra      L40CD

L3A3D               leax      L4647,pcr
                    bra       L3A7D

L3A43               leax      L464E,pcr
                    bra       L3A90

L3A49               leax      L4654,pcr
                    bra       L3A90

L3A4F               leax      L465A,pcr
                    bra       L3A90

L3A55               leax      L4660,pcr
                    bra       L3A90

L3A5B               leax      L4666,pcr
                    bra       L3A90

L3A61               leax      L466C,pcr
                    bra       L3A90

L3A67               leax      L4672,pcr
                    bra       L3A90

L3A6D               leax      $4677,pcr
                    bra       L3A90

L3A73               leax      L467D,pcr
                    bra       L3A7D

L3A79               leax      L4683,pcr
L3A7D               pshs      x
                    lbsr      L3E6F
                    leas      $02,s
                    ldd       $000D
                    subd      #$0002
                    lbra      L3E8A

L3A8C               leax      L4689,pcr
L3A90               pshs      x
                    lbsr      L3E6F
                    lbra      L40CD

L3A98               leax      L4690,pcr
                    bra       L3ABA

L3A9E               leax      L4696,pcr
                    bra       L3ABA

L3AA4               leax      L469E,pcr
                    bra       L3ABA

L3AAA               leax      L46A5,pcr
                    bra       L3ABA

L3AB0               leax      L46AC,pcr
                    bra       L3ABA

L3AB6               leax      L46B2,pcr
L3ABA               pshs      x
                    lbsr      L3E6F
                    leas      $02,s
                    ldd       $000D
                    subd      #$0004
                    lbra      L3E8A

L3AC9               ldd       #$0002
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbra      L3BD3

L3AD5               leax      L46B8,pcr
                    pshs      x
                    lbsr      L4824
                    leas      $02,s
                    ldd       >$0057,y
                    pshs      d
                    lbsr      L43F7
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L4408
                    leas      $02,s
                    lbsr      L43DD
                    lbra      L3BC1

L3AFA               cmpx      #$006E
                    lbeq      L39E1
                    cmpx      #$008B
                    lbeq      L3A31
                    cmpx      #$0089
                    lbeq      L3A3D
                    cmpx      #$0050
                    lbeq      L3A43
                    cmpx      #$0051
                    lbeq      L3A49
                    cmpx      #$0052
                    lbeq      L3A4F
                    cmpx      #$0053
                    lbeq      L3A55
                    cmpx      #$0054
                    lbeq      L3A5B
                    cmpx      #$0057
                    lbeq      L3A61
                    cmpx      #$0058
                    lbeq      L3A67
                    cmpx      #$0059
                    lbeq      L3A6D
                    cmpx      #$0056
                    lbeq      L3A73
                    cmpx      #$0055
                    lbeq      L3A79
                    cmpx      #$005A
                    lbeq      L3A8C
                    cmpx      #$005B
                    lbeq      L3A8C
                    cmpx      #$005E
                    lbeq      L3A8C
                    cmpx      #$005C
                    lbeq      L3A8C
                    cmpx      #$005F
                    lbeq      L3A8C
                    cmpx      #$005D
                    lbeq      L3A8C
                    cmpx      #$0043
                    lbeq      L3A98
                    cmpx      #$0044
                    lbeq      L3A9E
                    cmpx      #$0083
                    lbeq      L3AA4
                    cmpx      #$0086
                    lbeq      L3AAA
                    cmpx      #$003C
                    lbeq      L3AB0
                    cmpx      #$003E
                    lbeq      L3AB0
                    cmpx      #$003D
                    lbeq      L3AB6
                    cmpx      #$003F
                    lbeq      L3AB6
                    cmpx      #$004A
                    lbeq      L3AC9
                    lbra      L3AD5

L3BC1               puls      pc,u
L3BC3               pshs      u
                    ldu       $06,s
                    ldx       $04,s
                    lbra      L3CD6

L3BCC               ldd       #$0004
                    pshs      d
                    pshs      u
L3BD3               lbsr      L3D91
L3BD6               leas      $04,s
                    puls      pc,u
L3BDA               leax      L46C7,pcr
                    pshs      x
                    lbsr      L3E8E
                    leas      $02,s
                    ldd       $000D
                    subd      #$0008
                    lbra      L3E8A

L3BED               cmpu      #$0005
                    bne       L3BF8
                    ldd       #$0033
                    bra       L3BFB

L3BF8               ldd       #$0037
L3BFB               pshs      d
                    leax      L46CF,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      L2D55
                    leas      $06,s
                    puls      pc,u
L3C0E               cmpu      #$0005
                    bne       L3C1A
                    leax      L46DA,pcr
                    bra       L3C1E

L3C1A               leax      L46E1,pcr
L3C1E               tfr       x,d
                    pshs      d
                    lbsr      L3E8E
                    lbra      L3E66

L3C28               leax      L46E8,pcr
                    bra       L3C44

L3C2E               leax      L46EE,pcr
                    bra       L3C44

L3C34               leax      L46F4,pcr
                    bra       L3C44

L3C3A               leax      L46FA,pcr
                    bra       L3C44

L3C40               leax      L4700,pcr
L3C44               pshs      x
                    lbsr      L3E8E
                    leas      $02,s
                    ldd       $000D
                    addd      #$0008
                    lbra      L3E8A

L3C53               leax      L4707,pcr
                    bra       L3CA9

L3C59               cmpu      #$0005
                    bne       L3C65
                    leax      L470D,pcr
                    bra       L3C7B

L3C65               leax      L4713,pcr
                    bra       L3C7B

L3C6B               cmpu      #$0005
                    bne       L3C77
                    leax      L4719,pcr
                    bra       L3C7B

L3C77               leax      L471F,pcr
L3C7B               tfr       x,d
                    pshs      d
                    bra       L3CAB

L3C81               leax      L4725,pcr
                    bra       L3CA9

L3C87               leax      L472B,pcr
                    bra       L3CA9

L3C8D               leax      L4731,pcr
                    bra       L3CA9

L3C93               leax      L4737,pcr
                    bra       L3CA9

L3C99               leax      L473D,pcr
                    bra       L3CA9

L3C9F               leax      L4743,pcr
                    bra       L3CA9

L3CA5               leax      L4749,pcr
L3CA9               pshs      x
L3CAB               lbsr      L3E8E
                    lbra      L40CD

L3CB1               leax      L474F,pcr
                    pshs      x
                    lbsr      L4824
                    leas      $02,s
                    ldd       >$0057,y
                    pshs      d
                    lbsr      L43F7
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L4408
                    leas      $02,s
                    lbsr      L43DD
                    lbra      L3D8F

L3CD6               cmpx      #$004B
                    lbeq      L3BCC
                    cmpx      #$006E
                    lbeq      L3BDA
                    cmpx      #$008B
                    lbeq      L3BED
                    cmpx      #$0089
                    lbeq      L3C0E
                    cmpx      #$0050
                    lbeq      L3C28
                    cmpx      #$0051
                    lbeq      L3C2E
                    cmpx      #$0052
                    lbeq      L3C34
                    cmpx      #$0053
                    lbeq      L3C3A
                    cmpx      #$005A
                    lbeq      L3C40
                    cmpx      #$005B
                    lbeq      L3C40
                    cmpx      #$005E
                    lbeq      L3C40
                    cmpx      #$005C
                    lbeq      L3C40
                    cmpx      #$005F
                    lbeq      L3C40
                    cmpx      #$005D
                    lbeq      L3C40
                    cmpx      #$0043
                    lbeq      L3C53
                    cmpx      #$003C
                    lbeq      L3C59
                    cmpx      #$003E
                    lbeq      L3C59
                    cmpx      #$003D
                    lbeq      L3C6B
                    cmpx      #$003F
                    lbeq      L3C6B
                    cmpx      #$008D
                    lbeq      L3C81
                    cmpx      #$008C
                    lbeq      L3C87
                    cmpx      #$0090
                    lbeq      L3C8D
                    cmpx      #$008E
                    lbeq      L3C93
                    cmpx      #$0092
                    lbeq      L3C99
                    cmpx      #$0091
                    lbeq      L3C9F
                    cmpx      #$008F
                    lbeq      L3CA5
                    lbra      L3CB1

L3D8F               puls      pc,u
L3D91               pshs      u,d
                    leax      L475F,pcr
                    pshs      x
                    lbsr      L43B9
                    leas      $02,s
                    ldd       $000B
                    addd      #$0001
                    std       $000B
                    std       ,s
                    pshs      d
                    lbsr      L4415
                    leas      $02,s
                    ldd       $08,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    bsr       L3DD1
                    leas      $04,s
                    ldd       ,s
                    pshs      d
                    lbsr      L4420
                    leas      $02,s
                    leax      L4764,pcr
                    pshs      x
                    lbsr      L43D2
                    leas      $02,s
                    lbra      L40CD

L3DD1               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    lbsr      $4B89
                    ldd       $08,s
                    cmpd      #$0001
                    bne       L3DEC
                    pshs      u
                    lbsr      L4408
L3DE7               leas      $02,s
                    lbra      L3E4C

L3DEC               cmpu      #$0000
                    bne       L3E1D
                    ldd       #$0001
                    std       ,s
                    bra       L3E04

L3DF9               leax      L476B,pcr
                    pshs      x
                    lbsr      L43F7
                    leas      $02,s
L3E04               ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    cmpd      $08,s
                    blt       L3DF9
                    ldd       #$0030
                    pshs      d
                    lbsr      L43E8
                    bra       L3DE7

L3E1D               clra
                    clrb
                    bra       L3E43

L3E21               ldd       ,u++
                    pshs      d
                    lbsr      L4408
                    leas      $02,s
                    ldd       $08,s
                    addd      #$FFFF
                    cmpd      ,s
                    beq       L3E3E
                    ldd       #$002C
                    pshs      d
                    lbsr      L43E8
                    leas      $02,s
L3E3E               ldd       ,s
                    addd      #$0001
L3E43               std       ,s
                    ldd       ,s
                    cmpd      $08,s
                    blt       L3E21
L3E4C               lbsr      L43DD
                    lbra      L40CD

L3E52               pshs      u
                    ldd       >$0051,y
                    pshs      d
                    lbsr      L43B9
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L43D2
L3E66               leas      $02,s
                    ldd       $000D
                    addd      #$0002
                    bra       L3E8A

L3E6F               pshs      u
                    ldd       >$0051,y
                    pshs      d
                    lbsr      L43B9
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L43D2
                    leas      $02,s
                    ldd       $000D
                    addd      #$0004
L3E8A               std       $000D
                    puls      pc,u
L3E8E               pshs      u
                    ldd       >$0051,y
                    pshs      d
                    lbsr      L43B9
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L43D2
                    lbra      L40CD

L3EA5               pshs      u
                    ldu       $04,s
                    leas      -$06,s
                    clra
                    clrb
                    std       $02,s
                    ldd       $0C,s
                    cmpd      #$0077
                    bne       L3ED5
                    ldd       [$0e,s]
                    cmpd      #$0002
                    bne       L3EC5
                    ldd       #$0001
                    bra       L3EC7

L3EC5               clra
                    clrb
L3EC7               std       $02,s
                    ldx       $0e,s
                    ldd       $06,x
                    std       $0C,s
                    ldx       $0e,s
                    ldd       $08,x
                    std       $0e,s
L3ED5               leax      ,u
                    bra       L3EED

L3ED9               leax      $476E,pcr
                    bra       L3EE9

L3EDF               leax      $4772,pcr
                    bra       L3EE9

L3EE5               leax      $4775,pcr
L3EE9               stx       $04,s
                    bra       L3EFC

L3EED               cmpx      #$0057
                    beq       L3ED9
                    cmpx      #$0058
                    beq       L3EDF
                    cmpx      #$0059
                    beq       L3EE5
L3EFC               ldx       $0C,s
                    lbra      L405C

L3F01               ldd       $02,s
                    beq       L3F23
                    cmpu      #$0057
                    bne       L3F16
                    ldd       >$0055,y
                    pshs      d
                    lbsr      L43D2
                    leas      $02,s
L3F16               ldd       $04,s
                    pshs      d
                    lbsr      L43B9
                    leas      $02,s
                    clra
                    clrb
                    bra       L3F50

L3F23               ldd       $04,s
                    pshs      d
                    lbsr      L43B9
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
                    lbsr      L4086
                    leas      $08,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L43B9
                    leas      $02,s
                    ldd       #$0001
L3F50               pshs      d
                    ldd       $10,s
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    ldd       #$0062
                    pshs      d
                    lbsr      L4086
                    leas      $08,s
                    lbra      L44A2

L3F69               ldd       $0e,s
                    pshs      d
                    ldd       #$0008
                    lbsr      $5FAE
                    clra
                    std       ,s
                    tfr       d,x
                    bra       L3FC3

L3F7A               cmpu      #$0057
                    bne       L3FCE
                    ldd       >$0055,y
                    pshs      d
                    bra       L3F9A

L3F88               cmpu      #$0057
                    beq       L3FCE
                    cmpu      #$0059
                    bne       L3FA1
                    leax      $4779,pcr
                    pshs      x
L3F9A               lbsr      L43D2
                    leas      $02,s
                    bra       L3FCE

L3FA1               ldd       $04,s
                    pshs      d
                    lbsr      L43B9
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
                    lbsr      L4086
                    leas      $08,s
                    bra       L3FCE

L3FC3               stx       -$02,s
                    beq       L3F7A
                    cmpx      #$00FF
                    beq       L3F88
                    bra       L3FA1

L3FCE               ldd       $0e,s
                    clra
                    std       ,s
                    tfr       d,x
                    bra       L4024

L3FD7               cmpu      #$0057
                    lbne      L44A2
                    leax      L477E,pcr
                    bra       L3FF7

L3FE5               cmpu      #$0057
                    lbeq      L44A2
                    cmpu      #$0059
                    bne       L4001
                    leax      L4783,pcr
L3FF7               pshs      x
                    lbsr      L43D2
                    leas      $02,s
                    lbra      L44A2

L4001               ldd       $04,s
                    pshs      d
                    lbsr      L43B9
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
                    lbsr      L4086
                    leas      $08,s
                    lbra      L44A2

L4024               stx       -$02,s
                    beq       L3FD7
                    cmpx      #$00FF
                    beq       L3FE5
                    bra       L4001

L402F               ldd       $04,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    leax      L4788,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      L2D55
                    leas      $08,s
                    ldd       $000D
                    addd      #$0002
                    std       $000D
                    lbra      L44A2

L4050               leax      $479B,pcr
                    pshs      x
                    lbsr      L4824
                    lbra      L432E

L405C               cmpx      #$0034
                    lbeq      L3F01
                    cmpx      #$0094
                    lbeq      L3F01
                    cmpx      #$0095
                    lbeq      L3F01
                    cmpx      #$0093
                    lbeq      L3F01
                    cmpx      #$0036
                    lbeq      L3F69
                    cmpx      #$006E
                    beq       L402F
                    bra       L4050

L4086               pshs      u
                    ldd       $04,s
                    pshs      d
                    lbsr      L43E8
                    leas      $02,s
                    ldd       #$0020
                    pshs      d
                    lbsr      L43E8
                    leas      $02,s
                    ldd       $0a,s
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    bsr       L40D1
                    leas      $06,s
                    lbsr      L43DD
                    puls      pc,u
L40B0               pshs      u
                    ldu       $04,s
                    stu       -$02,s
                    beq       L40CF
                    cmpu      #$0000
                    ble       L40C8
                    ldd       #$002B
                    pshs      d
                    lbsr      L43E8
                    leas      $02,s
L40C8               pshs      u
                    lbsr      L4408
L40CD               leas      $02,s
L40CF               puls      pc,u
L40D1               pshs      u,y,x,d
                    ldd       $0a,s
                    anda      #$80
                    clrb
                    std       -$02,s
                    beq       L40E6
                    ldd       #$005B
                    pshs      d
                    lbsr      L43E8
                    leas      $02,s
L40E6               ldd       $0a,s
                    anda      #$7f
                    tfr       d,x
                    lbra      L42E3

L40EF               ldu       $0C,s
                    ldd       $06,u
                    cmpd      #$0041
                    bne       L4110
                    ldd       #$0023
                    pshs      d
                    lbsr      L43E8
                    leas      $02,s
                    ldd       $0e,s
                    pshs      d
                    ldd       $0a,u
                    pshs      d
                    ldd       #$0077
                    bra       L411D

L4110               ldd       $0e,s
                    addd      $14,u
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    ldd       $06,u
L411D               pshs      d
                    bsr       L40D1
                    leas      $06,s
                    lbra      L44A2

L4126               ldd       #$0023
                    pshs      d
                    lbsr      L43E8
                    leas      $02,s
                    ldd       $0C,s
                    lbra      L4268

L4135               leax      L47AC,pcr
                    pshs      x
                    lbsr      L43F7
                    leas      $02,s
                    ldd       $0e,s
                    pshs      d
                    lbsr      L40B0
                    leas      $02,s
                    ldd       >$004d,y
                    pshs      d
                    lbsr      L43F7
                    lbra      L42DF

L4155               ldd       $0C,s
                    std       ,s
                    lbeq      L4266
                    ldd       [,s]
                    std       $02,s
                    tfr       d,x
                    lbra      L4233

L4166               ldx       ,s
                    ldd       $04,x
                    subd      $000D
                    addd      $0e,s
                    std       $0C,s
                    pshs      d
                    lbsr      L4408
                    leas      $02,s
                    ldd       >$004f,y
                    lbra      L4224

L417E               ldd       L0023
                    bne       L419A
                    ldd       $0a,s
                    anda      #$80
                    clrb
                    std       -$02,s
                    beq       L4190
                    ldd       #$003E
                    bra       L4193

L4190               ldd       #$003C
L4193               pshs      d
                    lbsr      L43E8
                    leas      $02,s
L419A               ldx       ,s
                    ldd       $04,x
                    pshs      d
                    lbsr      L4420
                    leas      $02,s
                    leax      $06,s
                    bra       L41D3

L41A9               ldd       L0023
                    bne       L41C5
                    ldd       $0a,s
                    anda      #$80
                    clrb
                    std       -$02,s
                    beq       L41BB
                    ldd       #$003E
                    bra       L41BE

L41BB               ldd       #$003C
L41BE               pshs      d
                    lbsr      L43E8
                    leas      $02,s
L41C5               ldd       ,s
                    addd      #$0004
                    pshs      d
                    lbsr      L4433
                    leas      $02,s
                    bra       L41D5

L41D3               leas      -$06,x
L41D5               ldd       $0e,s
                    pshs      d
                    lbsr      L40B0
                    leas      $02,s
                    ldd       $0a,s
                    anda      #$80
                    clrb
                    std       -$02,s
                    bne       L420B
                    ldd       L0023
                    lbne      L431B
                    ldd       $02,s
                    cmpd      #$0021
                    lbeq      L431B
                    ldd       $02,s
                    cmpd      #$0022
                    lbeq      L431B
                    ldd       $02,s
                    cmpd      #$0023
                    lbeq      L431B
L420B               ldx       ,s
                    ldd       $02,x
                    clra
                    andb      #$30
                    cmpd      #$0030
                    bne       L4220
                    leax      L47B3,pcr
                    pshs      x
                    bra       L4226

L4220               ldd       >$004d,y
L4224               pshs      d
L4226               lbsr      L43F7
                    lbra      L42DF

L422C               leax      $47B8,pcr
                    lbra      L42DA

L4233               cmpx      #$000D
                    lbeq      L4166
                    cmpx      #$0023
                    lbeq      L417E
                    cmpx      #$000F
                    lbeq      L419A
                    cmpx      #$0021
                    lbeq      L41A9
                    cmpx      #$0022
                    lbeq      L41A9
                    cmpx      #$000E
                    lbeq      L41C5
                    cmpx      #$000C
                    lbeq      L41C5
                    bra       L422C

L4266               ldd       $0e,s
L4268               pshs      d
                    lbsr      L4408
                    lbra      L42DF

L4270               ldd       $0C,s
                    addd      $0e,s
                    std       $0C,s
                    pshs      d
                    lbsr      L4408
                    leas      $02,s
                    ldd       #$002C
                    pshs      d
                    lbsr      L43E8
                    leas      $02,s
                    ldd       $0a,s
                    anda      #$7f
                    tfr       d,x
                    bra       L42A6

L428F               ldd       #$0078
                    bra       L429C

L4294               ldd       #$0079
                    bra       L429C

L4299               ldd       #$0075
L429C               pshs      d
                    lbsr      L43E8
                    leas      $02,s
                    lbra      L431B

L42A6               cmpx      #$0093
                    beq       L428F
                    cmpx      #$0094
                    beq       L4294
                    cmpx      #$0095
                    beq       L4299
                    bra       L431B

L42B7               ldd       >$004f,y
                    pshs      d
                    lbsr      L43F7
                    leas      $02,s
                    leax      L47C6,pcr
                    pshs      x
                    lbsr      L43F7
                    leas      $02,s
                    ldd       $000D
                    addd      #$0002
                    std       $000D
                    bra       L431B

L42D6               leax      $47C9,pcr
L42DA               pshs      x
                    lbsr      L4824
L42DF               leas      $02,s
                    bra       L431B

L42E3               cmpx      #$0077
                    lbeq      L40EF
                    cmpx      #$0036
                    lbeq      L4126
                    cmpx      #$0080
                    lbeq      L4135
                    cmpx      #$0034
                    lbeq      L4155
                    cmpx      #$0093
                    lbeq      L4270
                    cmpx      #$0094
                    lbeq      L4270
                    cmpx      #$0095
                    lbeq      L4270
                    cmpx      #$006E
                    beq       L42B7
                    bra       L42D6

L431B               ldd       $0a,s
                    anda      #$80
                    clrb
                    std       -$02,s
                    lbeq      L44A2
                    ldd       #$005D
                    pshs      d
                    lbsr      L43E8
L432E               leas      $02,s
                    lbra      L44A2

L4333               pshs      u
                    ldx       $04,s
                    bra       L4382

L4339               leax      L47D5,pcr
                    pshs      x
                    lbsr      L4824
                    leas      $02,s
L4344               leax      L47DC,pcr
                    bra       L437E

L434A               leax      L47E0,pcr
                    bra       L437E

L4350               leax      L47E4,pcr
                    bra       L437E

L4356               leax      L47E8,pcr
                    bra       L437E

L435C               leax      L47EC,pcr
                    bra       L437E

L4362               leax      L47F0,pcr
                    bra       L437E

L4368               leax      L47F4,pcr
                    bra       L437E

L436E               leax      L47F8,pcr
                    bra       L437E

L4374               leax      L47FC,pcr
                    bra       L437E

L437A               leax      L4800,pcr
L437E               tfr       x,d
                    puls      pc,u
L4382               cmpx      #$005A
                    beq       L4344
                    cmpx      #$005B
                    beq       L434A
                    cmpx      #$005C
                    beq       L4350
                    cmpx      #$005D
                    beq       L4356
                    cmpx      #$005E
                    beq       L435C
                    cmpx      #$005F
                    beq       L4362
                    cmpx      #$0060
                    beq       L4368
                    cmpx      #$0061
                    beq       L436E
                    cmpx      #$0062
                    beq       L4374
                    cmpx      #$0063
                    beq       L437A
                    lbra      L4339
                    puls      pc,u
L43B9               pshs      u
                    ldd       $0005
                    pshs      d
                    ldd       #$0020
                    pshs      d
                    lbsr      L515F
                    leas      $04,s
                    ldd       $04,s
                    pshs      d
                    bsr       L43F7
                    lbra      L446E

L43D2               pshs      u
                    ldd       $04,s
                    pshs      d
                    bsr       L43B9
                    lbra      L4488

L43DD               pshs      u
                    ldd       $0005
                    pshs      d
                    ldd       #$000D
                    bra       L43F0

L43E8               pshs      u
                    ldd       $0005
                    pshs      d
                    ldd       $06,s
L43F0               pshs      d
                    lbsr      L515F
                    bra       L4404

L43F7               pshs      u
                    ldd       $04,s
                    pshs      d
                    ldd       $0005
                    pshs      d
                    lbsr      L2D55
L4404               leas      $04,s
                    puls      pc,u
L4408               pshs      u
                    ldd       $04,s
                    pshs      d
                    leax      L4804,pcr
                    lbra      L4499

L4415               pshs      u
                    ldd       $04,s
                    pshs      d
                    bsr       L4420
                    lbra      L4488

L4420               pshs      u
                    ldd       #$005F
                    pshs      d
                    bsr       L43E8
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    bsr       L4408
                    bra       L446E

L4433               pshs      u
                    ldd       $04,s
                    pshs      d
                    leax      $4807,pcr
                    lbra      L4499

L4440               pshs      u,d
                    ldd       $06,s
                    subd      $000D
                    std       ,s
                    beq       L446C
                    leax      $480C,pcr
                    pshs      x
                    lbsr      L43B9
                    leas      $02,s
                    ldd       ,s
                    pshs      d
                    lbsr      L4408
                    leas      $02,s
                    ldd       >$004f,y
                    pshs      d
                    lbsr      L43F7
                    leas      $02,s
                    lbsr      L43DD
L446C               ldd       $06,s
L446E               leas      $02,s
                    puls      pc,u
L4472               pshs      u
                    ldd       $04,s
                    pshs      d
                    bsr       L4433
                    leas      $02,s
                    ldd       $06,s
                    beq       L448A
                    ldd       #$003A
                    pshs      d
                    lbsr      L43E8
L4488               leas      $02,s
L448A               lbsr      L43DD
                    puls      pc,u
L448F               pshs      u
                    ldd       $04,s
                    pshs      d
                    leax      L4812,pcr
L4499               pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      L2D55
L44A2               leas      $06,s
                    puls      pc,u
L44A6               pshs      u
                    ldd       $04,s
                    pshs      d
                    bsr       L448F
                    leas      $02,s
                    ldd       $06,s
                    pshs      d
                    ldd       #$005F
                    pshs      d
                    leax      L481A,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      L2D55
                    leas      $08,s
                    puls      pc,u
                    bge       $4545
                    neg       $002C
                    com       >$006C
                    fcc       /bsr /
                    fcb       $00
                    fcc       /lbra /
                    fcb       $00
                    fcc       /clra/
                    fcb       $00
                    fcc       /unknown operator : /
                    fcb       $00
L44F5               bra       L4567
                    com       $6873
                    bra       L4521
                    com       $0d,x
                    neg       $006C
                    fcb       $62
                    neg       $0070
                    fcb       $75
                    inc       -$0d,s
                    bra       $457D
                    bge       $457A
                    com       $0d,x
                    neg       $0063
                    fcc       /cmult/
                    fcb       $00
L4514               fcc       /ccudiv/
                    fcb       $00
L451B               fcc       /ccdiv/
                    fcb       $00
L4521               fcc       /ccasl/
                    fcb       $00
L4527               fcc       /ccasr/
                    fcb       $00
L452D               fcc       /cclsr/
                    fcb       $00
L4533               fcc       /ccumod/
                    fcb       $00
L453A               fcc       /ccmod/
                    fcb       $00
L4540               jmp       $05,s
                    asr       $01,s
                    tst       L0020
                    jmp       $05,s
                    asr       $02,s
                    tst       L0020
                    fcc       /sbca #0/
                    fcb       $00
L4554               com       $0f,s
                    tst       $01,s
                    tst       L0020
                    fcc       /comb/
                    fcb       $00
L455F               fcc       /leax /
                    fcb       $00
L4565               fcb       $6C,$65
L4567               fcb       $61,$73,$20
                    fcb       $00
L456B               bge       $45E5
                    tst       $0000
L456F               fcc       /jsr /
                    fcb       $00
L4574               com       $6578
                    neg       $006C
                    lsr       0,x
L457B               fcb       $61
                    com       $6C62
                    tst       L0020
                    fcc       /rola/
                    fcb       $00
L4586               fcb       $61
                    com       $7261
                    tst       L0020
                    fcc       /rorb/
                    fcb       $00
L4591               inc       -$0d,s
                    fcb       $72,$61
                    tst       L0020
                    fcc       /rorb/
                    fcb       $00
L459C               fcc       /ldy /
                    fcb       $00
L45A1               fcc       /ldu /
                    fcb       $00
L45A6               fcc       /leax /
                    fcb       $00
L45AC               bcs       L4612
                    bge       L45D5
                    com       $0d,x
                    neg       L0064
                    bge       L45DB
                    com       $0d,x
                    neg       $0073
                    fcb       $65
                    asl       >$0061
                    fcc       /dca #0/
                    fcb       $00
L45C5               fcc       /sbca #0/
                    fcb       $00
L45CD               bcs       $4633
                    bge       L45F6
                    com       $0d,x
                    neg       $0063
L45D5               inc       -$0e,s
                    fcb       $61
                    tst       L0020
                    fcb       $63
L45DB               fcb       $6C,$72,$62
                    fcb       $00
L45DF               inc       $04,s
                    neg       L0020
                    com       $7425
                    com       0,y
                    blt       L461C
                    bge       L465F
                    tst       $0000
L45EE               com       $0d,s
                    neg       >$0073
                    lsr       >$0073
L45F6               fcb       $75,$62
                    neg       $0061
                    lsr       $04,s
                    neg       $006C
                    fcb       $65,$61
                    neg       L0020
                    fcb       $65
                    asl       $6720
                    bcs       L466B
                    bge       L462F
                    com       $0d,x
                    neg       L0064
                    bge       L4610
L4610               fcb       $4C,$45
L4612               fcc       /A arg/
                    fcb       $00
L4618               bra       L468E
                    ror       -$0e,s
L461C               bra       L4643
                    com       $0C,y
                    bcs       L4685
                    tst       $0000
L4624               inc       $04,s
                    fcb       $61
                    bra       L4659
                    bge       L46A3
                    tst       L0020
                    clr       -$0e,s
L462F               fcb       $61
                    bra       L4663
                    bge       L46AC
                    tst       L0020
                    clr       -$0e,s
                    fcb       $61
                    bra       L466D
                    bge       L46B5
                    tst       L0020
                    fcc       /ora /
L4643               fcb       $33,$2C,$78
                    fcb       $00
L4647               clrb
                    fcc       /lmove/
                    fcb       $00
L464E               clrb
                    fcc       /ladd/
                    fcb       $00
L4654               clrb
                    fcc       /lsub/
L4659               fcb       $00
L465A               clrb
                    fcc       /lmul/
L465F               fcb       $00
L4660               clrb
                    fcb       $6C,$64
L4663               fcb       $69,$76
                    fcb       $00
L4666               clrb
                    fcc       /lmod/
L466B               fcb       $00
L466C               clrb
L466D               fcc       /land/
                    fcb       $00
L4672               clrb
                    inc       $0f,s
                    fcb       $72
                    neg       $005F
                    fcc       /lxor/
                    fcb       $00
L467D               clrb
                    fcc       /lshl/
                    fcb       $00
L4683               clrb
                    fcb       $6C
L4685               fcb       $73,$68,$72
                    fcb       $00
L4689               clrb
                    fcc       /lcmp/
L468E               fcb       $72
                    fcb       $00
L4690               clrb
                    fcc       /lneg/
                    fcb       $00
L4696               clrb
                    fcc       /lcompl/
                    fcb       $00
L469E               clrb
                    fcc       /lito/
L46A3               fcb       $6C
                    fcb       $00
L46A5               clrb
                    fcc       /lutol/
                    fcb       $00
L46AC               clrb
                    fcc       /linc/
                    fcb       $00
L46B2               clrb
                    fcb       $6C,$64
L46B5               fcb       $65,$63
                    fcb       $00
L46B8               fcc       /codgen - longs/
                    fcb       $00
L46C7               clrb
                    fcc       /dstack/
                    fcb       $00
L46CF               bra       L473D
                    lsr       $01,s
                    bra       L46FA
                    com       $0C,y
                    asl       $0D00
L46DA               clrb
                    fcc       /fmove/
                    fcb       $00
L46E1               clrb
                    fcc       /dmove/
                    fcb       $00
L46E8               clrb
                    fcc       /dadd/
                    fcb       $00
L46EE               clrb
                    fcc       /dsub/
                    fcb       $00
L46F4               clrb
                    fcc       /dmul/
                    fcb       $00
L46FA               clrb
                    fcc       /ddiv/
                    fcb       $00
L4700               clrb
                    fcc       /dcmpr/
                    fcb       $00
L4707               clrb
                    fcc       /dneg/
                    fcb       $00
L470D               clrb
                    fcc       /finc/
                    fcb       $00
L4713               clrb
                    fcc       /dinc/
                    fcb       $00
L4719               clrb
                    fcc       /fdec/
                    fcb       $00
L471F               clrb
                    fcc       /ddec/
                    fcb       $00
L4725               clrb
                    fcc       /dtof/
                    fcb       $00
L472B               clrb
                    fcc       /ftod/
                    fcb       $00
L4731               clrb
                    fcc       /ltod/
                    fcb       $00
L4737               clrb
                    fcc       /itod/
                    fcb       $00
L473D               clrb
                    fcc       /utod/
                    fcb       $00
L4743               clrb
                    fcc       /dtol/
                    fcb       $00
L4749               clrb
                    fcc       /dtoi/
                    fcb       $00
L474F               fcc       /codgen - floats/
                    fcb       $00
L475F               fcc       /bsr /
                    fcb       $00
L4764               fcc       /puls x/
                    fcb       $00
L476B               leax      $0C,y
                    neg       $0061
                    jmp       $04,s
                    neg       $006F
                    fcb       $72
                    neg       $0065
                    clr       -$0e,s
                    neg       $0063
                    fcb       $6F,$6D,$61
                    fcb       $00
L477E               fcc       /clrb/
                    fcb       $00
L4783               fcc       /comb/
                    fcb       $00
L4788               bra       L47AF
                    com       $6120
                    bge       L4802
                    bmi       L479E
                    bra       $47B8
                    com       $6220
                    bge       $480B
                    bmi       L47A7
                    neg       $0063
                    fcb       $6F,$6D
L479E               fcc       /piler tro/
L47A7               fcc       /uble/
                    fcb       $00
L47AC               clrb
                    fcb       $66,$6C
L47AF               fcb       $61,$63,$63
                    fcb       $00
L47B3               bge       $4825
                    com       -$0e,s
                    neg       $0073
                    fcc       /torage error/
                    fcb       $00
L47C6               bmi       $47F3
                    neg       L0064
                    fcc       /ereference/
                    fcb       $00
L47D5               fcc       /rel op/
                    fcb       $00
L47DC               fcb       $65,$71
                    bra       L47E0

L47E0               jmp       $05,s
                    bra       L47E4

L47E4               inc       $05,s
                    bra       L47E8

L47E8               inc       -$0C,s
                    bra       L47EC

L47EC               asr       $05,s
                    bra       L47F0

L47F0               asr       -$0C,s
                    bra       L47F4

L47F4               inc       -$0d,s
                    bra       L47F8

L47F8               inc       $0f,s
                    bra       L47FC

L47FC               asl       -$0d,s
                    bra       L4800

L4800               asl       $09,s
L4802               bra       L4804

L4804               bcs       $486A
                    neg       $0025
                    bgt       $4842
                    com       >$006C
                    fcc       /eas /
                    fcb       $00
L4812               bra       L4880
                    fcc       /ea%c /
                    fcb       $00
L481A               bcs       $487F
                    bcs       L4882
                    bge       $4890
                    com       -$0e,s
                    tst       $0000
L4824               pshs      u
                    ldd       $04,s
                    pshs      d
                    ldd       $0282,y
                    pshs      d
                    bsr       L484C
                    lbra      L4ACA

L4835               pshs      u
                    leax      L4B2F,pcr
                    pshs      x
                    ldd       $0282,y
                    pshs      d
                    bsr       L4880
                    leas      $04,s
                    lbsr      L0AE0
                    puls      pc,u
L484C               pshs      u
                    leas      -$32,s
                    leax      L4B3D,pcr
                    pshs      x
                    leax      $02,s
                    pshs      x
                    lbsr      L5600
                    leas      $04,s
                    ldd       $38,s
                    pshs      d
                    leax      $02,s
                    pshs      x
                    lbsr      L5618
                    leas      $04,s
                    leax      ,s
                    pshs      x
                    ldd       $38,s
                    pshs      d
                    bsr       L4880
                    leas      $04,s
                    leas      $32,s
                    puls      pc,u
L4880               pshs      u
L4882               ldu       $04,s
                    ldd       $0e,u
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       $10,u
                    pshs      d
                    lbsr      L4939
                    lbra      L4ADF

L4897               pshs      u
                    ldd       $02DA,y
                    addd      #$0001
                    pshs      d
                    ldd       #$000A
                    lbsr      L5EF1
                    std       $02DA,y
                    cmpd      $02DC,y
                    bne       L48C6
                    ldd       $02DC,y
                    addd      #$0001
                    pshs      d
                    ldd       #$000A
                    lbsr      L5EF1
                    std       $02DC,y
L48C6               ldd       $02DA,y
                    pshs      d
                    ldd       #$0006
                    lbsr      $5E90
                    leax      $029e,y
                    leax      d,x
                    leau      ,x
                    ldd       $04,s
                    std       ,u
                    leax      $02,u
                    pshs      x
                    leax      $08,s
                    lbsr      $5E24
                    puls      pc,u
L48E9               pshs      u,d
                    ldd       $02DA,y
                    bra       L491A

L48F1               ldd       ,s
                    pshs      d
                    ldd       #$0006
                    lbsr      $5E90
                    leax      $029e,y
                    leax      d,x
                    leau      ,x
                    ldd       ,u
                    cmpd      $06,s
                    bne       L490E
                    leax      $02,u
                    bra       L492D

L490E               ldd       ,s
                    addd      #$FFFF
                    std       ,s
                    bge       L491C
                    ldd       #$0009
L491A               std       ,s
L491C               ldd       ,s
                    cmpd      $02DC,y
                    bne       L48F1
                    bsr       $492B
                    stu       $FFFF
                    stu       L3510
L492D               leau      $0254,y
                    pshs      u
                    lbsr      $5E24
                    lbra      L4A87

L4939               pshs      u
                    leas      -$05,s
                    leax      $0262,y
                    pshs      x
                    leax      L4B4F,pcr
                    pshs      x
                    lbsr      L2D40
                    leas      $04,s
                    ldd       $09,s
                    pshs      d
                    ldd       $0f,s
                    pshs      d
                    leax      L4B54,pcr
                    pshs      x
                    lbsr      L2D40
                    leas      $06,s
                    ldd       $0b,s
                    pshs      d
                    leax      L4B5E,pcr
                    pshs      x
                    lbsr      L2D40
                    leas      $04,s
                    ldd       $02DE,y
                    bne       L498D
                    leax      L4B6E,pcr
                    pshs      x
                    ldd       $0280,y
                    pshs      d
                    lbsr      L4F07
                    leas      $04,s
                    std       $02DE,y
                    beq       L49B2
L498D               leax      $01,s
                    pshs      x
                    ldd       $0f,s
                    pshs      d
                    lbsr      L48E9
                    leas      $02,s
                    lbsr      $5E24
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    bsr       $49AB
                    stu       $FFFF
                    stu       L3510
                    lbsr      $5DC0
                    bne       L49B7
L49B2               leax      $05,s
                    lbra      L4A31

L49B7               clra
                    clrb
                    pshs      d
                    leax      $03,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $02DE,y
                    pshs      d
                    lbsr      L4F9F
                    leas      $08,s
L49D0               leax      $00CE,y
                    pshs      x
                    ldd       $02DE,y
                    pshs      d
                    lbsr      L5376
                    leas      $02,s
                    stb       $02,s
                    sex
                    pshs      d
                    lbsr      L515F
                    leas      $04,s
                    ldb       ,s
                    cmpb      #$0d
                    bne       L49D0
                    bra       L4A03

L49F3               leax      $00CE,y
                    pshs      x
                    ldd       #$0020
                    pshs      d
                    lbsr      L515F
                    leas      $04,s
L4A03               ldd       $09,s
                    addd      #$FFFF
                    std       $09,s
                    subd      #$FFFF
                    bgt       L49F3
                    leax      $00CE,y
                    pshs      x
                    ldd       #$005E
                    pshs      d
                    lbsr      L515F
                    leas      $04,s
                    leax      $00CE,y
                    pshs      x
                    ldd       #$000D
                    pshs      d
                    lbsr      L515F
                    leas      $04,s
                    bra       L4A33

L4A31               leas      -$05,x
L4A33               ldd       $0009
                    addd      #$0001
                    std       $0009
                    cmpd      #_start
                    ble       L4A66
                    leax      $00CE,y
                    pshs      x
                    lbsr      L528A
                    leas      $02,s
                    leax      $4B70,pcr
                    pshs      x
                    leax      $00DB,y
                    pshs      x
                    lbsr      L2D55
                    leas      $04,s
                    ldd       #$0001
                    pshs      d
                    lbsr      exit
                    leas      $02,s
L4A66               leas      $05,s
                    puls      pc,u
L4A6A               pshs      u
                    ldu       $04,s
                    stu       -$02,s
                    beq       L4A89
                    ldd       $0a,u
                    pshs      d
                    bsr       L4A6A
                    leas      $02,s
                    ldd       $0C,u
                    pshs      d
                    lbsr      L4A6A
                    leas      $02,s
                    pshs      u
                    bsr       L4A8B
L4A87               leas      $02,s
L4A89               puls      pc,u
L4A8B               pshs      u
                    ldu       $04,s
                    stu       -$02,s
                    beq       L4ACC
                    ldx       $06,u
                    bra       L4AB1

L4A97               ldd       #$000D
                    bra       L4AA4

L4A9C               ldd       #$0008
                    bra       L4AA4

L4AA1               ldd       #$0004
L4AA4               pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L3204
                    leas      $04,s
                    bra       L4AC0

L4AB1               cmpx      #$0034
                    beq       L4A97
                    cmpx      #$004B
                    beq       L4A9C
                    cmpx      #$004A
                    beq       L4AA1
L4AC0               ldd       #$0016
                    pshs      d
                    pshs      u
                    lbsr      L3204
L4ACA               leas      $04,s
L4ACC               puls      pc,u
L4ACE               pshs      u
                    ldd       #$0016
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    bsr       L4B11
L4ADF               leas      $06,s
                    puls      pc,u
                    pshs      u
                    ldd       $04,s
                    asra
                    rorb
                    asra
                    rorb
                    andb      #$F0
                    pshs      d
                    ldd       $06,s
                    clra
                    andb      #$0f
                    addd      ,s++
                    puls      pc,u
L4AF8               pshs      u
                    ldu       $04,s
                    cmpu      #$004C
                    blt       L4B0D
                    cmpu      #$0063
                    bgt       L4B0D
                    ldd       #$0001
                    bra       L4B0F

L4B0D               clra
                    clrb
L4B0F               puls      pc,u
L4B11               pshs      u
                    ldu       $04,s
                    bra       L4B21

L4B17               ldb       ,u+
                    ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    stb       -$01,x
L4B21               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bne       L4B17
                    puls      pc,u
L4B2F               fcc       /out of memory/
                    fcb       $00
L4B3D               fcc       /compiler error - /
                    fcb       $00
L4B4F               bcs       $4BC4
                    abx
                    bra       L4B54
L4B54               fcc       /line %d  /
                    fcb       $00
L4B5E               bpl       L4B8A
                    bpl       $4B8C
                    bra       L4B84
                    bcs       $4BD9
                    bra       L4B88
                    bpl       L4B94
                    bpl       $4B96
                    tst       $0000
L4B6E               fcb       $72
                    neg       $0074
                    fcc       /oo many errors - AB/
L4B84               fcb       $4F,$52,$54
                    fcb       $0D
L4B88               neg       $0034
L4B8A               nega
                    leax      L4D07,pcr
                    pshs      x
                    lbsr      L43B9
L4B94               lbra      L4C8F

L4B97               pshs      u
                    ldu       $04,s
                    pshs      u
                    leax      L4D0C,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      L2D55
                    leas      $06,s
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    lbsr      L4472
                    leas      $04,s
                    clra
                    clrb
                    std       $000D
                    std       $000F
                    std       L0017
                    leax      L4D17,pcr
                    pshs      x
                    lbsr      L43D2
                    leas      $02,s
                    ldd       $0011
                    bne       L4BE3
                    ldd       $08,s
                    std       $0025
                    pshs      d
                    leax      L4D1E,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      L2D55
                    leas      $06,s
L4BE3               ldd       $0013
                    lbeq      L4C91
                    leax      L4D39,pcr
                    pshs      x
                    lbsr      L43B9
                    leas      $02,s
                    ldd       $0a,s
                    pshs      d
                    lbsr      L4420
                    leas      $02,s
                    leax      L4D3F,pcr
                    pshs      x
                    lbsr      L43F7
                    leas      $02,s
                    pshs      u
                    lbsr      L4433
                    leas      $02,s
                    leax      L4D53,pcr
                    pshs      x
                    lbsr      L43F7
                    lbra      L4C8F

L4C1B               pshs      u
                    ldd       $0011
                    bne       L4C3D
                    ldd       L0017
                    subd      $000F
                    addd      #$FFC0
                    pshs      d
                    ldd       $0025
                    pshs      d
                    leax      L4D77,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      L2D55
                    leas      $08,s
L4C3D               puls      pc,u
L4C3F               pshs      u
                    ldd       $04,s
                    beq       L4C4B
                    leax      L4D84,pcr
                    bra       L4C4F

L4C4B               leax      L4D8D,pcr
L4C4F               tfr       x,d
                    pshs      d
                    bra       L4C5D

L4C55               pshs      u
                    leax      L4D93,pcr
                    pshs      x
L4C5D               lbsr      L43D2
                    bra       L4C8F

L4C62               pshs      u,d
                    ldd       $0003
                    pshs      d
                    lbsr      L53D8
                    std       ,s
                    lbsr      L4420
                    bra       L4C78

L4C72               ldd       ,s
                    pshs      d
                    bsr       L4C93
L4C78               leas      $02,s
                    ldd       $0003
                    pshs      d
                    lbsr      L5376
                    leas      $02,s
                    std       ,s
                    bne       L4C72
                    clra
                    clrb
                    pshs      d
                    bsr       L4C93
                    leas      $02,s
L4C8F               leas      $02,s
L4C91               puls      pc,u
L4C93               pshs      u
                    ldd       $02E0,y
                    bne       L4CAA
                    leax      L4D9B,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      L2D55
                    leas      $04,s
L4CAA               ldd       $04,s
                    cmpd      #$0020
                    blt       L4CBA
                    ldd       $04,s
                    cmpd      #$0022
                    bne       L4CCF
L4CBA               ldd       $04,s
                    pshs      d
                    leax      L4DA2,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      L2D55
                    leas      $06,s
                    bra       L4CFF

L4CCF               ldd       $0005
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L515F
                    leas      $04,s
                    ldd       $02E0,y
                    addd      #$0001
                    std       $02E0,y
                    subd      #$0001
                    cmpd      #$004B
                    blt       L4D05
                    leax      L4DAE,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      L2D55
                    leas      $04,s
L4CFF               clra
                    clrb
                    std       $02E0,y
L4D05               puls      pc,u
L4D07               fcc       /fdb /
                    fcb       $00
L4D0C               bra       L4D82
                    lsr       $6C20
                    bcs       L4D41
                    fcb       $38
                    com       $0D00
L4D17               fcc       /pshs u/
                    fcb       $00
L4D1E               bra       L4D8C
                    lsr       $04,s
                    bra       $4D47
                    clrb
                    bcs       L4D8B
                    tst       L0020
                    inc       $02,s
                    com       $7220
                    clrb
                    com       $746B
                    com       $08,s
                    fcb       $65
                    com       $0b,s
                    tst       $0000
L4D39               fcc       /leax /
                    fcb       $00
L4D3F               bge       $4DB1
L4D41               com       -$0e,s
                    tst       L0020
                    neg       $7368
                    com       $2078
                    tst       L0020
                    fcc       /leax /
                    fcb       $00
L4D53               bge       $4DC5
                    com       -$0e,s
                    tst       L0020
                    neg       $7368
                    com       $2078
                    tst       L0020
                    inc       $02,s
                    com       $7220
                    clrb
                    neg       $726F
                    ror       $0d,x
                    bra       L4DDA
                    fcb       $65,$61
                    com       $2034
                    bge       L4DE8
                    tst       $0000
L4D77               clrb
                    bcs       L4DDE
                    bra       $4DE1
                    fcb       $71,$75
                    bra       $4DA5
                    lsr       $0d,x
L4D82               tst       $0000
L4D84               fcc       /vsect d/
L4D8B               fcb       $70
L4D8C               fcb       $00
L4D8D               fcc       /vsect/
                    fcb       $00
L4D93               fcc       /endsect/
                    fcb       $00
L4D9B               bra       $4E03
                    fcc       /cc "/
                    fcb       $00
L4DA2               bhi       $4DB1
                    bra       $4E0C
                    com       $02,s
                    bra       $4DCE
                    bcs       L4E24
                    tst       $0000
L4DAE               bhi       $4DBD
                    neg       $0034
                    nega
                    leau      $00C1,y
L4DB7               ldd       $06,u
                    clra
                    andb      #$03
                    lbeq      L4E28
                    leau      $0d,u
                    pshs      u
                    leax      $0191,y
                    cmpx      ,s++
                    bhi       L4DB7
                    ldd       #$00C8
                    std       $0260,y
                    lbra      L4E2C
                    puls      pc,u
L4DD8               pshs      u
L4DDA               ldu       $08,s
                    bne       L4DE2
L4DDE               bsr       $4DB1
                    tfr       d,u
L4DE2               stu       -$02,s
                    beq       L4E2C
                    ldd       $04,s
L4DE8               std       $08,u
                    ldx       $06,s
                    ldb       $01,x
                    cmpb      #$2b
                    beq       L4DFA
                    ldx       $06,s
                    ldb       $02,x
                    cmpb      #$2b
                    bne       L4E00
L4DFA               ldd       $06,u
                    orb       #$03
                    bra       L4E1E

L4E00               ldd       $06,u
                    pshs      d
                    ldb       [$08,s]
                    cmpb      #$72
                    beq       L4E12
                    ldb       [$08,s]
                    cmpb      #$64
                    bne       L4E17
L4E12               ldd       #$0001
                    bra       L4E1A

L4E17               ldd       #$0002
L4E1A               ora       ,s+
                    orb       ,s+
L4E1E               std       $06,u
                    ldd       $02,u
                    addd      $0b,u
L4E24               std       $04,u
                    std       ,u
L4E28               tfr       u,d
                    puls      pc,u
L4E2C               clra
                    clrb
                    puls      pc,u
L4E30               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    clra
                    clrb
                    std       ,s
                    ldx       $0a,s
                    ldb       $01,x
                    sex
                    tfr       d,x
                    bra       L4E61

L4E43               ldx       $0a,s
                    ldb       $02,x
                    cmpb      #$2b
                    bne       L4E50
                    ldd       #$0007
                    bra       L4E58

L4E50               ldd       #$0004
                    bra       L4E58

L4E55               ldd       #$0003
L4E58               std       ,s
                    bra       L4E71

L4E5C               leax      $04,s
                    lbra      L4EC9

L4E61               stx       -$02,s
                    beq       L4E71
                    cmpx      #$0078
                    beq       L4E43
                    cmpx      #$002B
                    beq       L4E55
                    bra       L4E5C

L4E71               ldb       [$0a,s]
                    sex
                    tfr       d,x
                    lbra      L4ED6

L4E7A               ldd       ,s
                    orb       #$01
                    bra       L4EBC

L4E80               ldd       ,s
                    orb       #$02
                    pshs      d
                    pshs      u
                    lbsr      $605B
                    leas      $04,s
                    std       $02,s
                    cmpd      #$FFFF
                    beq       L4EAB
                    ldd       #$0002
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L6131
                    leas      $08,s
                    bra       L4EF0

L4EAB               ldd       ,s
                    orb       #$02
                    pshs      d
                    pshs      u
                    lbsr      $607C
                    bra       L4EC3

L4EB8               ldd       ,s
                    orb       #$81
L4EBC               pshs      d
                    pshs      u
                    lbsr      $605B
L4EC3               leas      $04,s
                    std       $02,s
                    bra       L4EF0

L4EC9               leas      -$04,x
L4ECB               ldd       #$00CB
                    std       $0260,y
                    clra
                    clrb
                    bra       L4EF2

L4ED6               cmpx      #$0072
                    lbeq      L4E7A
                    cmpx      #$0061
                    lbeq      L4E80
                    cmpx      #$0077
                    beq       L4EAB
                    cmpx      #$0064
                    beq       L4EB8
                    bra       L4ECB

L4EF0               ldd       $02,s
L4EF2               leas      $04,s
                    puls      pc,u
                    pshs      u
                    clra
                    clrb
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbra      L4F52

L4F07               pshs      u
                    ldd       $06,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L4E30
                    leas      $04,s
                    tfr       d,u
                    cmpu      #$FFFF
                    bne       L4F22
                    clra
                    clrb
                    bra       L4F57

L4F22               clra
                    clrb
                    bra       L4F4A
                    pshs      u
                    ldd       $08,s
                    pshs      d
                    lbsr      L5250
                    leas      $02,s
                    ldd       $06,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L4E30
                    leas      $04,s
                    tfr       d,u
                    stu       -$02,s
                    bge       L4F48
                    clra
                    clrb
                    bra       L4F57

L4F48               ldd       $08,s
L4F4A               pshs      d
                    ldd       $08,s
                    pshs      d
                    pshs      u
L4F52               lbsr      L4DD8
                    leas      $06,s
L4F57               puls      pc,u
L4F59               pshs      u
                    ldu       $04,s
                    leas      -$06,s
                    clra
                    clrb
                    bra       L4F90

L4F63               ldd       $0C,s
                    std       $04,s
                    bra       L4F7F

L4F69               ldd       $10,s
                    pshs      d
                    lbsr      L5376
                    leas      $02,s
                    std       ,s
                    cmpd      #$FFFF
                    beq       L4F99
                    ldd       ,s
                    stb       ,u+
L4F7F               ldd       $04,s
                    addd      #$FFFF
                    std       $04,s
                    subd      #$FFFF
                    bgt       L4F69
                    ldd       $02,s
                    addd      #$0001
L4F90               std       $02,s
                    ldd       $02,s
                    cmpd      $0e,s
                    blt       L4F63
L4F99               ldd       $02,s
                    leas      $06,s
                    puls      pc,u
L4F9F               pshs      u
                    ldu       $04,s
                    leas      -$06,s
                    cmpu      #$0000
                    beq       L4FB2
                    ldd       $06,u
                    clra
                    andb      #$03
                    bne       L4FB8
L4FB2               ldd       #$FFFF
                    lbra      L50DB

L4FB8               ldd       $06,u
                    anda      #$80
                    clrb
                    std       -$02,s
                    bne       L4FCB
                    pshs      u
                    lbsr      L54CA
                    leas      $02,s
                    lbra      L50A1

L4FCB               ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    beq       L4FEA
                    pshs      u
                    lbsr      L528A
                    leas      $02,s
                    ldd       $06,u
                    anda      #$FE
                    std       $06,u
                    ldd       $02,u
                    addd      $0b,u
                    std       $04,u
                    lbra      L509F

L4FEA               ldd       ,u
                    cmpd      $04,u
                    lbcc      L50A1
                    leax      $02,s
                    pshs      x
                    leax      $0e,s
                    lbsr      $5E24
                    ldx       $10,s
                    lbra      L506E

L5002               leax      $02,s
                    pshs      x
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    pshs      u
                    lbsr      L50F6
                    leas      $02,s
                    lbsr      $5DAB
                    lbsr      $5E24
L501B               ldd       $0b,u
                    lbsr      $5E0B
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    leax      $06,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    bsr       L5038
                    neg       $0000
                    neg       $0000
L5038               puls      x
                    lbsr      $5DC0
                    bge       L5046
                    leax      $06,s
                    lbsr      $5DE4
                    bra       L5048

L5046               leax      $06,s
L5048               lbsr      $5DC0
                    blt       L507B
                    ldd       $04,s
                    addd      ,u
                    std       ,s
                    cmpd      $02,u
                    bcs       L507B
                    ldd       ,s
                    cmpd      $04,u
                    bcc       L507B
                    ldd       ,s
                    std       ,u
                    ldd       $06,u
                    andb      #$EF
                    std       $06,u
                    lbra      L50D9
                    bra       L507B

L506E               stx       -$02,s
                    lbeq      L5002
                    cmpx      #$0001
                    lbeq      L501B
L507B               ldd       $10,s
                    cmpd      #$0001
                    bne       L509D
                    leax      $0C,s
                    pshs      x
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $04,u
                    subd      ,u
                    lbsr      $5E0B
                    lbsr      $5DAB
                    lbsr      $5E24
L509D               ldd       $04,u
L509F               std       ,u
L50A1               ldd       $06,u
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
                    lbsr      L6131
                    leas      $08,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    bsr       $50CD
                    stu       $FFFF
                    stu       L3510
                    lbsr      $5DC0
                    bne       L50D9
                    ldd       #$FFFF
                    bra       L50DB

L50D9               clra
                    clrb
L50DB               leas      $06,s
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
                    lbsr      L4F9F
                    leas      $08,s
                    puls      pc,u
L50F6               pshs      u
                    ldu       $04,s
                    beq       L5103
                    ldd       $06,u
                    clra
                    andb      #$03
                    bne       L5116
L5103               bsr       $5109
                    stu       $FFFF
                    stu       L3510
                    leau      $0254,y
                    pshs      u
                    lbsr      $5E24
                    puls      pc,u
L5116               ldd       $06,u
                    anda      #$80
                    clrb
                    std       -$02,s
                    bne       L5126
                    pshs      u
                    lbsr      L54CA
                    leas      $02,s
L5126               ldd       #$0001
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L6131
                    leas      $08,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    beq       L514F
                    ldd       $02,u
                    bra       L5151

L514F               ldd       $04,u
L5151               pshs      d
                    ldd       ,u
                    subd      ,s++
                    lbsr      $5E0B
                    lbsr      $5D96
                    puls      pc,u
L515F               pshs      u
                    ldu       $06,s
                    ldd       $06,u
                    anda      #$80
                    andb      #$22
                    cmpd      #$8002
                    beq       L5183
                    ldd       $06,u
                    clra
                    andb      #$22
                    cmpd      #$0002
                    lbne      L529B
                    pshs      u
                    lbsr      L54CA
                    leas      $02,s
L5183               ldd       $06,u
                    clra
                    andb      #$04
                    beq       L51BF
                    ldd       #$0001
                    pshs      d
                    leax      $07,s
                    pshs      x
                    ldd       $08,u
                    pshs      d
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L51A4
                    leax      L6121,pcr
                    bra       L51A8

L51A4               leax      L6108,pcr
L51A8               tfr       x,d
                    tfr       d,x
                    jsr       ,x
                    leas      $06,s
                    cmpd      #$FFFF
                    bne       L5200
                    ldd       $06,u
                    orb       #$20
                    std       $06,u
                    lbra      L529B

L51BF               ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       L51CF
                    pshs      u
                    lbsr      L52B8
                    leas      $02,s
L51CF               ldd       ,u
                    addd      #$0001
                    std       ,u
                    subd      #$0001
                    tfr       d,x
                    ldd       $04,s
                    stb       ,x
                    ldd       ,u
                    cmpd      $04,u
                    bcc       L51F5
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L5200
                    ldd       $04,s
                    cmpd      #$000D
                    bne       L5200
L51F5               pshs      u
                    lbsr      L52B8
                    std       ,s++
                    lbne      L529B
L5200               ldd       $04,s
                    puls      pc,u
                    pshs      u
                    ldu       $04,s
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    ldd       #$0008
                    lbsr      L5FBA
                    pshs      d
                    lbsr      L515F
                    leas      $04,s
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    lbsr      L515F
                    lbra      L5372
                    pshs      u,d
L5229               leau      $00C1,y
                    clra
                    clrb
                    std       ,s
                    bra       L523D

L5233               tfr       u,d
                    leau      $0d,u
                    pshs      d
                    bsr       L5250
                    leas      $02,s
L523D               ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    cmpd      #$0010
                    blt       L5233
                    lbra      L52B4

L5250               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    cmpu      #$0000
                    beq       L5260
                    ldd       $06,u
                    bne       L5266
L5260               ldd       #$FFFF
                    lbra      L52B4

L5266               ldd       $06,u
                    clra
                    andb      #$02
                    beq       L5275
                    pshs      u
                    bsr       L528A
                    leas      $02,s
                    bra       L5277

L5275               clra
                    clrb
L5277               std       ,s
                    ldd       $08,u
                    pshs      d
                    lbsr      L606A
                    leas      $02,s
                    clra
                    clrb
                    std       $06,u
                    ldd       ,s
                    bra       L52B4

L528A               pshs      u
                    ldu       $04,s
                    beq       L529B
                    ldd       $06,u
                    clra
                    andb      #$22
                    cmpd      #$0002
                    beq       L52A0
L529B               ldd       #$FFFF
                    puls      pc,u
L52A0               ldd       $06,u
                    anda      #$80
                    clrb
                    std       -$02,s
                    bne       L52B0
                    pshs      u
                    lbsr      L54CA
                    leas      $02,s
L52B0               pshs      u
                    bsr       L52B8
L52B4               leas      $02,s
                    puls      pc,u
L52B8               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       L52EA
                    ldd       ,u
                    cmpd      $04,u
                    beq       L52EA
                    clra
                    clrb
                    pshs      d
                    pshs      u
                    lbsr      L50F6
                    leas      $02,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L6131
                    leas      $08,s
L52EA               ldd       ,u
                    subd      $02,u
                    std       $02,s
                    lbeq      L5362
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    lbeq      L5362
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L5339
                    ldd       $02,u
                    bra       L5331

L530A               ldd       $02,s
                    pshs      d
                    ldd       ,u
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L6121
                    leas      $06,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       L5327
                    leax      $04,s
                    bra       L5351

L5327               ldd       $02,s
                    subd      ,s
                    std       $02,s
                    ldd       ,u
                    addd      ,s
L5331               std       ,u
                    ldd       $02,s
                    bne       L530A
                    bra       L5362

L5339               ldd       $02,s
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L6108
                    leas      $06,s
                    cmpd      $02,s
                    beq       L5362
                    bra       L5353

L5351               leas      -$04,x
L5353               ldd       $06,u
                    orb       #$20
                    std       $06,u
                    ldd       $04,u
                    std       ,u
                    ldd       #$FFFF
                    bra       L5372

L5362               ldd       $06,u
                    ora       #$01
                    std       $06,u
                    ldd       $02,u
                    std       ,u
                    addd      $0b,u
                    std       $04,u
                    clra
                    clrb
L5372               leas      $04,s
                    puls      pc,u
L5376               pshs      u
                    ldu       $04,s
                    beq       L53C2
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       L53C2
                    ldd       ,u
                    cmpd      $04,u
                    bcc       L539E
                    ldd       ,u
                    addd      #$0001
                    std       ,u
                    subd      #$0001
                    tfr       d,x
                    ldb       ,x
                    clra
                    lbra      L54C8

L539E               pshs      u
                    lbsr      L5411
                    lbra      L54C6
                    pshs      u
                    ldu       $06,s
                    beq       L53C2
                    ldd       $06,u
                    clra
                    andb      #$01
                    beq       L53C2
                    ldd       $04,s
                    cmpd      #$FFFF
                    beq       L53C2
                    ldd       ,u
                    cmpd      $02,u
                    bhi       L53C7
L53C2               ldd       #$FFFF
                    puls      pc,u
L53C7               ldd       ,u
                    addd      #$FFFF
                    std       ,u
                    tfr       d,x
                    ldd       $04,s
                    stb       ,x
                    ldd       $04,s
                    puls      pc,u
L53D8               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    pshs      u
                    lbsr      L5376
                    leas      $02,s
                    std       $02,s
                    cmpd      #$FFFF
                    beq       L53FC
                    pshs      u
                    lbsr      L5376
                    leas      $02,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       L5401
L53FC               ldd       #$FFFF
                    bra       L540D

L5401               ldd       $02,s
                    pshs      d
                    ldd       #$0008
                    lbsr      $5FD1
                    addd      ,s
L540D               leas      $04,s
                    puls      pc,u
L5411               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    ldd       $06,u
                    anda      #$80
                    andb      #$31
                    cmpd      #$8001
                    beq       L5437
                    ldd       $06,u
                    clra
                    andb      #$31
                    cmpd      #$0001
                    lbne      L54B0
                    pshs      u
                    lbsr      L54CA
                    leas      $02,s
L5437               leax      $00C1,y
                    pshs      x
                    cmpu      ,s++
                    bne       L5454
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L5454
                    leax      $00CE,y
                    pshs      x
                    lbsr      L528A
                    leas      $02,s
L5454               ldd       $06,u
                    clra
                    andb      #$08
                    beq       L5480
                    ldd       $0b,u
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L5474
                    leax      L60F8,pcr
                    bra       L5478

L5474               leax      L60D7,pcr
L5478               tfr       x,d
                    tfr       d,x
                    jsr       ,x
                    bra       L5492

L5480               ldd       #$0001
                    pshs      d
                    leax      $0a,u
                    stx       $02,u
                    pshs      x
                    ldd       $08,u
                    pshs      d
                    lbsr      L60D7
L5492               leas      $06,s
                    std       ,s
                    ldd       ,s
                    bgt       L54B5
                    ldd       $06,u
                    pshs      d
                    ldd       $02,s
                    beq       L54A7
                    ldd       #$0020
                    bra       L54AA

L54A7               ldd       #$0010
L54AA               ora       ,s+
                    orb       ,s+
                    std       $06,u
L54B0               ldd       #$FFFF
                    bra       L54C6

L54B5               ldd       $02,u
                    addd      #$0001
                    std       ,u
                    ldd       $02,u
                    addd      ,s
                    std       $04,u
                    ldb       [$02,u]
                    clra
L54C6               leas      $02,s
L54C8               puls      pc,u
L54CA               pshs      u
                    ldu       $04,s
                    ldd       $06,u
                    clra
                    andb      #$C0
                    bne       L5502
                    leas      -$20,s
                    leax      ,s
                    pshs      x
                    ldd       $08,u
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    lbsr      $5FEC
                    leas      $06,s
                    ldd       $06,u
                    pshs      d
                    ldb       $02,s
                    bne       L54F6
                    ldd       #$0040
                    bra       L54F9

L54F6               ldd       #$0080
L54F9               ora       ,s+
                    orb       ,s+
                    std       $06,u
                    leas      $20,s
L5502               ldd       $06,u
                    ora       #$80
                    std       $06,u
                    clra
                    andb      #$0C
                    beq       L550F
                    puls      pc,u
L550F               ldd       $0b,u
                    bne       L5524
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L551F
                    ldd       #$0080
                    bra       L5522

L551F               ldd       #$0100
L5522               std       $0b,u
L5524               ldd       $02,u
                    bne       L5539
                    ldd       $0b,u
                    pshs      d
                    lbsr      L61EF
                    leas      $02,s
                    std       $02,u
                    cmpd      #$FFFF
                    beq       L5541
L5539               ldd       $06,u
                    orb       #$08
                    std       $06,u
                    bra       L5550

L5541               ldd       $06,u
                    orb       #$04
                    std       $06,u
                    leax      $0a,u
                    stx       $02,u
                    ldd       #$0001
                    std       $0b,u
L5550               ldd       $02,u
                    addd      $0b,u
                    std       $04,u
                    std       ,u
                    puls      pc,u
L555A               pshs      u
                    ldd       $0C,s
                    beq       L5596
                    ldd       $0e,s
                    beq       L557D
                    leax      $04,s
                    lbsr      $5D52
                    ldd       $14,s
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    leax      >$0059,y
                    leax      d,x
                    lbsr      L56AA
                    bra       L5598

L557D               leax      $04,s
                    lbsr      $5D52
                    ldd       $14,s
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    leax      >$0059,y
                    leax      d,x
                    lbsr      L56B2
                    bra       L5598

L5596               leax      $04,s
L5598               leau      $0254,y
                    pshs      u
                    lbsr      L5D79
                    puls      pc,u
L55A3               pshs      u
                    ldd       $0C,s
                    cmpd      #$0009
                    ble       L55D3
                    leax      $04,s
                    pshs      x
                    ldd       $10,s
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    ldd       #$000A
                    lbsr      $5F44
                    addd      #$0009
                    pshs      d
                    leax      $0a,s
                    lbsr      $5D52
                    lbsr      L555A
                    leas      $0C,s
                    lbsr      L5D79
L55D3               ldd       $0e,s
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    ldd       #$000A
                    lbsr      L5EF1
                    pshs      d
                    leax      $08,s
                    lbsr      $5D52
                    lbsr      L555A
                    leas      $0C,s
                    puls      pc,u
L55EF               pshs      u
                    ldu       $04,s
L55F3               ldb       ,u+
                    bne       L55F3
                    tfr       u,d
                    subd      $04,s
                    addd      #$FFFF
                    puls      pc,u
L5600               pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
L560A               ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L560A
                    bra       L563F

L5618               pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
L5622               ldx       ,s
                    leax      $01,x
                    stx       ,s
                    ldb       -$01,x
                    bne       L5622
                    ldd       ,s
                    addd      #$FFFF
                    std       ,s
L5633               ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L5633
L563F               ldd       $06,s
                    leas      $02,s
                    puls      pc,u
                    pshs      u
                    ldu       $04,s
                    bra       L565B

L564B               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    bne       L5659
                    clra
                    clrb
                    puls      pc,u
L5659               leau      $01,u
L565B               ldb       ,u
                    sex
                    pshs      d
                    ldb       [$08,s]
                    sex
                    cmpd      ,s++
                    beq       L564B
                    ldb       [$06,s]
                    sex
                    pshs      d
                    ldb       ,u
                    sex
                    subd      ,s++
                    puls      pc,u
L5676               ldx       $02,s
                    lbsr      $5D52
                    bsr       L567E
                    rts

L567E               pshs      u
                    leas      -$1e,s
                    tfr       s,u
                    clr       $1d,u
                    clr       $19,u
                    lbsr      $58F8
                    lbra      L571D

L5691               ldd       ,x
                    eora      #$80
                    lbra      $5CB6
                    lbsr      L5B10
                    lbsr      L57F2
                    lbra      L571D
                    lbsr      L5B10
                    lbsr      L57C8
                    lbra      L571D

L56AA               lbsr      L5B10
                    lbsr      $596B
                    bra       L571D

L56B2               lbsr      L5B10
                    lbsr      $5997
                    bra       L571D

L56BA               lbsr      $5CB4
                    lbra      $5BB4
                    bsr       L56BA
                    ldd       $02,x
                    rts
                    ldd       ,x
                    std       $0254,y
                    ldd       $02,x
                    leax      $0254,y
                    std       $02,x
                    lbra      $5B54
                    leax      $0254,y
                    std       $02,x
                    tfr       a,b
                    sex
                    tfr       a,b
                    std       ,x
                    lbra      $5B54
                    leax      $0254,y
                    std       $02,x
                    clr       ,x
                    clr       $01,x
                    lbra      $5B54

L56F3               ldd       ,x
                    std       $0254,y
                    lda       $02,x
                    ldb       $07,x
                    leax      $0254,y
                    std       $02,x
                    rts
                    ldd       ,x
                    std       $0254,y
                    ldd       $02,x
                    leax      $0254,y
                    sta       $02,x
                    stb       $07,x
                    clr       $03,x
                    clr       $04,x
                    clr       $05,x
                    clr       $06,x
                    rts

L571D               leax      $0254,y
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
                    bmi       L57B0
                    lda       $02,s
                    bmi       L5783
                    lda       $09,s
                    beq       L577C
                    ldb       $07,x
                    beq       L57B4
                    cmpa      $07,x
                    bne       L5787
                    ldd       $02,s
                    cmpd      ,x
                    bne       L5787
                    ldd       $04,s
                    cmpd      $02,x
                    bne       L5787
                    ldd       $06,s
                    cmpd      $04,x
                    bne       L5787
                    lda       $08,s
                    anda      #$FE
                    pshs      a
                    ldb       $06,x
                    andb      #$FE
                    cmpa      ,s+
                    bne       L5787
                    bra       L57B8

L577C               lda       $07,x
                    bne       L57C3
                    clra
                    bra       L57B8

L5783               lda       $07,x
                    cmpa      $09,s
L5787               bhi       L57B4
                    bcs       L57C3
                    ldd       ,x
                    cmpd      $02,s
                    bne       L5787
                    ldd       $02,x
                    cmpd      $04,s
                    bne       L5787
                    ldd       $04,x
                    cmpd      $06,s
                    bne       L5787
                    lda       $06,x
                    anda      #$FE
                    pshs      a
                    lda       $08,s
                    anda      #$FE
                    cmpa      ,s+
                    bne       L5787
                    bra       L57B8

L57B0               lda       ,x
                    bpl       L57C3
L57B4               lda       #$01
                    andcc     #$FE
L57B8               pshs      cc
                    ldd       $01,s
                    std       $09,s
                    puls      cc
                    leas      $08,s
                    rts

L57C3               clra
                    cmpa      #$01
                    bra       L57B8

L57C8               lda       $17,u
                    beq       L57E9
                    ldb       $1C,u
                    eorb      #$80
                    stb       $1C,u
                    eorb      $18,u
                    stb       $19,u
                    ldb       $29,u
                    bne       L57FB
                    lbsr      $5C84
                    lda       $22,u
                    lbra      $593B

L57E9               lda       $22,u
                    ldb       $18,u
                    lbra      $593E

L57F2               lbeq      $5C84
                    lda       $17,u
                    beq       L57E9
L57FB               suba      $29,u
                    beq       $582C
                    sta       ,u
                    bcs       $5832
                    ldb       $17,u
                    stb       $29,u
                    ldd       $22,u
                    lsra
L580E               rorb
                    ror       $24,u
                    ror       $25,u
                    ror       $26,u
                    ror       $0f,x
                    eorb      #$27
                    ror       $28,u
                    dec       ,u
                    bne       L580E
                    std       $22,u
L5826               lda       $19,u
                    bmi       L58A2
                    bra       L5853
                    inc       ,u
                    orcc      #$01
                    bra       L5826
                    ldd       $10,u
L5836               lsra
                    rorb
                    ror       $12,u
                    ror       $13,u
                    ror       $14,u
                    ror       $15,u
                    ror       $16,u
                    inc       ,u
                    bne       L5836
                    std       $10,u
                    lda       $19,u
                    bmi       L58A5
L5853               ldd       $27,u
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
                    bcc       L589A
                    inc       $29,u
                    ror       $22,u
                    ror       $23,u
                    ror       $24,u
                    ror       $25,u
                    ror       $26,u
                    ror       $27,u
                    ror       $28,u
L589A               lda       $1C,u
                    sta       $19,u
                    bra       L58F9

L58A2               rola
                    coma
                    asra
L58A5               ldd       $27,u
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
                    bcc       L58F6
                    com       $22,u
                    com       $23,u
                    com       $24,u
                    com       $25,u
                    com       $26,u
                    com       $27,u
                    com       $28,u
                    lda       ,u
                    beq       L58F3
                    lbsr      L5C42
L58F3               lda       $1C,u
L58F6               sta       $19,u
L58F9               clr       ,u
L58FB               lda       $22,u
                    bmi       L593C
                    ora       $23,u
                    ora       $24,u
                    ora       $25,u
                    ora       $26,u
                    ora       $27,u
                    ora       $28,u
                    beq       L5950
                    ldd       $22,u
L5917               dec       $29,u
                    bne       L591F
                    dec       $1d,u
L591F               asl       ,u
                    rol       $28,u
                    rol       $27,u
                    rol       $26,u
                    rol       $25,u
                    rol       $24,u
                    rolb
                    rola
                    bpl       L5917
                    stb       $23,u
                    ldb       $29,u
                    beq       L5954
L593C               ldb       $19,u
                    anda      #$7f
                    andb      #$80
                    pshs      b
                    adda      ,s+
                    sta       $22,u
                    tst       $1d,u
                    bne       L5954
L594F               rts

L5950               sta       $29,u
                    rts

L5954               lda       $1d,u
                    ldb       $29,u
                    subd      #$0000
                    beq       L5967
                    bmi       L5967
L5961               ldd       #$0028
                    lbra      $5FDE

L5967               lbsr      L5992
                    bra       L5961
                    beq       L5992
                    lda       $17,u
                    beq       L5992
                    lbsr      L5A0E
                    clra
                    ldb       $29,u
                    addb      $17,u
                    adca      #$00
                    subd      #$0080
                    stb       $29,u
                    sta       $1d,u
                    lbsr      L58FB
                    lda       ,u
                    bpl       L594F
                    lbra      L5C42

L5992               clra
                    sta       $29,u
                    bra       L59F8
                    ldb       $17,u
                    bne       L59A3
                    ldd       #$0029
                    lbra      $5FDE

L59A3               tsta
                    beq       L5992
                    lbsr      L5A6C
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
                    lbsr      L58FB
                    lda       ,u
                    bpl       L5A0D
                    lbra      L5C42

L59E0               pshs      a
                    ldd       $22,u
                    std       ,u
                    ldd       $24,u
                    std       $02,u
                    ldd       $26,u
                    std       $04,u
                    ldb       $28,u
                    stb       $06,u
                    puls      a
L59F8               sta       $22,u
                    sta       $23,u
                    sta       $24,u
                    sta       $25,u
                    sta       $26,u
                    sta       $27,u
                    sta       $28,u
L5A0D               rts

L5A0E               clra
                    bsr       L59E0
                    ldb       #$38
                    stb       $08,u
L5A15               lda       $06,u
                    lsra
                    bcc       L5A44
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
L5A44               ror       $22,u
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
                    bne       L5A15
                    rts

L5A6C               clra
                    lbsr      L59E0
                    ldb       #$39
                    stb       $08,u
L5A74               ldb       ,u
                    cmpb      $10,u
                    bcs       L5AAB
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
                    bcs       L5AAB
                    std       ,u
                    lda       $0a,u
                    sta       $02,u
                    ldd       $0b,u
                    std       $03,u
                    ldd       $0d,u
                    std       $05,u
L5AAB               rol       $28,u
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
                    bhi       L5A74
                    beq       L5AF9
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
                    bra       L5AAB

L5AF9               ror       ,u
                    com       $22,u
                    com       $23,u
                    com       $24,u
                    com       $25,u
                    com       $26,u
                    com       $27,u
                    com       $28,u
L5B10               rts

L5B11               puls      d
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
                    lda       #$A0
                    sta       $07,x
                    clr       $04,x
                    clr       $05,x
                    clr       $06,x
                    lda       ,x
                    tfr       a,b
                    orb       $01,x
                    orb       $02,x
                    orb       $03,x
                    beq       L5BA1
                    ldb       $01,x
                    tsta
                    bpl       L5B83
                    pshs      d
                    clra
                    clrb
                    subd      $02,x
                    std       $02,x
                    ldd       #$0000
                    sbcb      $01,s
                    sbca      ,s
                    leas      $02,s
                    bvs       L5B8D
L5B83               dec       $07,x
                    asl       $03,x
                    rol       $02,x
                    rolb
                    rola
                    bpl       L5B83
L5B8D               anda      #$7f
                    tst       ,x
                    bpl       L5B95
                    ora       #$80
L5B95               std       ,x
                    rts
                    leax      $22,u
                    clr       $04,x
                    clr       $05,x
                    clr       $06,x
L5BA1               clr       $07,x
L5BA3               clr       ,x
                    clr       $01,x
                    clr       $02,x
                    clr       $03,x
                    rts

L5BAC               ldd       #$002A
                    lbra      $5FDE
                    leax      $22,u
                    ldb       $07,x
                    beq       L5BA3
                    subb      #$81
                    bcs       L5C34
                    negb
                    addb      #$1f
                    bmi       L5BAC
                    bne       L5BD9
                    ldd       ,x
                    cmpd      #$8000
                    bne       L5BAC
                    lda       $02,x
                    ora       $03,x
                    ora       $04,x
                    ora       $05,x
                    ora       $06,x
                    bne       L5BAC
                    rts

L5BD9               pshs      b
                    ldd       ,x
                    bmi       L5BEF
                    ora       #$80
L5BE1               lsra
                    rorb
                    ror       $02,x
                    ror       $03,x
                    dec       ,s
                    bne       L5BE1
                    std       ,x
                    puls      pc,b
L5BEF               clr       ,-s
L5BF1               lsra
                    rorb
                    ror       $02,x
                    ror       $03,x
                    ror       $04,x
                    ror       $05,x
                    ror       $06,x
                    bcc       L5C01
                    inc       ,s
L5C01               dec       $01,s
                    bne       L5BF1
                    std       ,x
                    ldd       ,s++
                    bne       L5C13
                    lda       $04,x
                    ora       $05,x
                    ora       $06,x
                    beq       L5C24
L5C13               ldd       $02,x
                    addd      #$0001
                    std       $02,x
                    ldd       ,x
                    adcb      #$00
                    adca      #$00
                    bcs       L5BAC
                    std       ,x
L5C24               clra
                    clrb
                    subd      $02,x
                    std       $02,x
                    ldd       #$0000
                    sbcb      $01,x
                    sbca      ,x
                    std       ,x
                    rts

L5C34               lda       ,x
                    lbpl      L5BA3
                    ldd       #$FFFF
                    std       $02,x
                    std       ,x
                    rts

L5C42               inc       $28,u
                    bne       L5C78
                    inc       $27,u
                    bne       L5C78
                    inc       $26,u
                    bne       L5C78
                    inc       $25,u
                    bne       L5C78
                    inc       $24,u
                    bne       L5C78
                    inc       $23,u
                    bne       L5C78
                    ldb       $22,u
                    tfr       b,a
                    anda      #$7f
                    inca
                    bpl       L5C6F
                    inc       $29,u
                    anda      #$7f
L5C6F               andb      #$80
                    pshs      b
                    adda      ,s+
                    sta       $22,u
L5C78               rts

L5C79               neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       L0081
                    leax      >L5C79,pcr
                    pshs      a
                    ldd       ,x
                    std       $22,u
                    ldd       $02,x
                    std       $24,u
                    ldd       $04,x
                    std       $26,u
                    ldd       $06,x
                    std       $28,u
                    puls      pc,a
L5C9D               pshs      a
                    ldd       $22,u
                    std       ,x
                    ldd       $24,u
                    std       $02,x
                    ldd       $26,u
                    std       $04,x
                    ldd       $28,u
                    std       $06,x
                    puls      pc,a
                    ldd       ,x
                    std       $0254,y
                    ldd       $02,x
                    std       $0256,y
                    ldd       $04,x
                    std       $0258,y
                    ldd       $06,x
                    leax      $0254,y
                    std       $06,x
                    rts
                    pshs      x
                    bsr       L5D53
                    leax      L5C79,pcr
                    pshs      x
                    lbsr      L5B11
                    lbsr      $57F3
L5CDF               ldx       $2a,u
                    bsr       L5C9D
                    ldx       $1e,u
                    leas      $2a,u
                    tfr       x,u
                    puls      pc,x
                    pshs      x
                    bsr       L5D53
                    leax      >L5C79,pcr
                    pshs      x
                    lbsr      L5B11
                    lbsr      $57C9
                    bra       L5CDF
                    pshs      x
                    bsr       $5D3C
                    leax      L5C79,pcr
                    pshs      x
                    lbsr      L5B11
                    lbsr      $57F3
                    ldx       $2a,u
                    ldd       $22,u
                    std       ,x
                    lda       $24,u
                    ldb       $29,u
                    std       $02,x
                    ldx       $0f,u
                    exg       u,y
                    eorb      #$2a
                    tfr       x,u
                    puls      pc,x
                    pshs      x
                    bsr       L5D3D
                    leax      $5C7A,pcr
                    pshs      x
                    lbsr      $5B12
                    lbsr      $57CA
                    bra       $5D11

L5D3D               leas      -$08,s
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
L5D53               rts
                    leas      -$08,s
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
                    pshs      u
                    ldu       $04,s
                    exg       x,u
                    ldd       ,u
                    std       ,x
                    ldd       $02,u
                    std       $02,x
L5D79               bra       L5D91
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
L5D91               puls      u
                    puls      d
                    std       ,s
                    rts
                    ldd       $04,s
                    addd      $02,x
                    std       $0256,y
                    ldd       $02,s
                    adcb      $01,x
                    adca      ,x
                    std       $0254,y
                    lbra      L5E74
                    ldd       $04,s
                    subd      $02,x
                    std       $0256,y
                    ldd       $02,s
                    sbcb      $01,x
                    sbca      ,x
                    std       $0254,y
                    lbra      L5E74
                    ldd       $02,s
                    cmpd      ,x
                    bne       L5DDB
                    ldd       $04,s
                    cmpd      $02,x
                    beq       L5DDB
                    bcs       L5DD8
                    lda       #$01
                    andcc     #$FE
                    bra       L5DDB

L5DD8               clra
                    cmpa      #$01
L5DDB               pshs      cc
                    ldd       $01,s
                    std       $05,s
                    puls      cc
                    leas      $04,s
                    rts
                    lbsr      L5E83
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
                    std       $0254,y
                    ldd       $02,x
                    coma
                    comb
                    leax      $0254,y
                    std       $02,x
                    rts
                    leax      $0254,y
                    std       $02,x
                    tfr       a,b
                    sex
                    tfr       a,b
                    std       ,x
                    rts
                    leax      $0254,y
                    std       $02,x
                    clr       ,x
                    clr       $01,x
                    rts
                    pshs      y
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
                    ldx       $02,s
                    pshs      b
                    lbsr      L5E83
                    puls      b
                    tstb
                    beq       L5E53
L5E48               asl       $03,x
                    rol       $02,x
                    rol       $01,x
                    rol       ,x
                    decb
                    bne       L5E48
L5E53               puls      d
                    std       ,s
                    rts
                    ldx       $02,s
                    pshs      b
                    lbsr      L5E83
                    puls      b
                    tstb
                    beq       L5E6F
L5E64               asr       ,x
                    ror       $01,x
                    ror       $02,x
                    ror       $03,x
                    decb
                    bne       L5E64
L5E6F               puls      d
                    std       ,s
                    rts

L5E74               tfr       cc,a
                    puls      x
                    stx       $02,s
                    leas      $02,s
                    leax      $0254,y
                    tfr       a,cc
                    rts

L5E83               ldd       ,x
                    std       $0254,y
                    ldd       $02,x
                    leax      $0254,y
                    std       $02,x
                    rts
                    tsta
                    bne       L5EA7
                    tst       $02,s
                    bne       L5EA7
                    lda       $03,s
                    mul
                    ldx       ,s
                    stx       $02,s
                    ldx       #$0000
                    std       ,s
                    puls      pc,d
L5EA7               pshs      d
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
                    bcc       L5EC4
                    inc       ,s
L5EC4               lda       $04,s
                    ldb       $09,s
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L5ED1
                    inc       ,s
L5ED1               lda       $04,s
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
                    clr       $02E2,y
                    leax      >L5F2D,pcr
                    stx       $02E3,y
L5EF1               bra       L5F07
                    leax      >L5F46,pcr
                    stx       $02E3,y
                    clr       $02E2,y
                    tst       $02,s
                    bpl       L5F07
                    inc       $02E2,y
L5F07               subd      #$0000
                    bne       L5F12
                    puls      x
                    ldd       ,s++
                    jmp       ,x

L5F12               ldx       $02,s
                    pshs      x
                    jsr       [$02E3,y]
                    ldd       ,s
                    std       $02,s
                    tfr       x,d
                    tst       $02E2,y
                    beq       L5F2A
                    nega
                    negb
                    sbca      #$00
L5F2A               std       ,s++
                    rts

L5F2D               subd      #$0000
                    beq       L5F3C
                    pshs      d
                    leas      -$02,s
                    clr       ,s
                    clr       $01,s
                    bra       L5F6A

L5F3C               puls      d
                    std       ,s
                    ldd       #$002D
                    lbra      L5FDF

L5F46               subd      #$0000
                    beq       L5F3C
                    pshs      d
                    leas      -$02,s
                    clr       ,s
                    clr       $01,s
                    tsta
                    bpl       L5F5E
                    nega
                    negb
                    sbca      #$00
                    inc       $01,s
                    std       $02,s
L5F5E               ldd       $06,s
                    bpl       L5F6A
                    nega
                    negb
                    sbca      #$00
                    com       $01,s
                    std       $06,s
L5F6A               lda       #$01
L5F6C               inca
                    asl       $03,s
                    rol       $02,s
                    bpl       L5F6C
                    sta       ,s
                    ldd       $06,s
                    clr       $06,s
                    clr       $07,s
L5F7B               subd      $02,s
                    bcc       L5F85
                    addd      $02,s
                    andcc     #$FE
                    bra       L5F87

L5F85               orcc      #$01
L5F87               rol       $07,s
                    rol       $06,s
                    lsr       $02,s
                    ror       $03,s
                    dec       ,s
                    bne       L5F7B
                    std       $02,s
                    tst       $01,s
                    beq       L5FA1
                    ldd       $06,s
                    nega
                    negb
                    sbca      #$00
                    std       $06,s
L5FA1               ldx       $04,s
                    ldd       $06,s
                    std       $04,s
                    stx       $06,s
                    ldx       $02,s
                    ldd       $04,s
                    leas      $06,s
                    rts
                    tstb
                    beq       L5FC6
L5FB3               asr       $02,s
                    ror       $03,s
                    decb
                    bne       L5FB3
L5FBA               bra       L5FC6
                    tstb
                    beq       L5FC6
L5FBF               lsr       $02,s
                    ror       $03,s
                    decb
                    bne       L5FBF
L5FC6               ldd       $02,s
                    pshs      d
                    ldd       $02,s
                    std       $04,s
                    ldd       ,s
                    leas      $04,s
                    rts
                    tstb
                    beq       L5FC6
L5FD6               asl       $03,s
                    rol       $02,s
                    decb
                    bne       L5FD6
                    bra       L5FC6

L5FDF               std       $0260,y
                    pshs      y,b
                    os9       F$ID
                    puls      y,b
                    os9       F$Send
                    rts
                    lda       $05,s
                    ldb       $03,s
                    beq       L6021
                    cmpb      #$01
                    beq       L6023
                    cmpb      #$06
                    beq       L6023
                    cmpb      #$02
                    beq       L6009
                    cmpb      #$05
                    beq       L6009
                    ldb       #$D0
                    lbra      L621E

L6009               pshs      u
                    os9       I$GetStt
                    bcc       L6015
                    puls      u
                    lbra      L621E

L6015               stx       [$08,s]
                    ldx       $08,s
                    stu       $02,x
                    puls      u
                    clra
                    clrb
                    rts

L6021               ldx       $06,s
L6023               os9       I$GetStt
                    lbra      L6227
                    lda       $05,s
                    ldb       $03,s
                    beq       L6038
                    cmpb      #$02
                    beq       L6040
                    ldb       #$D0
                    lbra      L621E

L6038               ldx       $06,s
                    os9       I$SetStt
                    lbra      L6227

L6040               pshs      u
                    ldx       $08,s
                    ldu       $0a,s
                    os9       I$SetStt
                    puls      u
                    lbra      L6227
                    ldx       $02,s
                    lda       $05,s
                    os9       I$Open
                    bcs       L605A
                    os9       I$Close
L605A               lbra      L6227
                    ldx       $02,s
                    lda       $05,s
                    os9       I$Open
                    lbcs      L621E
                    tfr       a,b
L606A               clra
                    rts
                    lda       $03,s
                    os9       I$Close
                    lbra      L6227
                    ldx       $02,s
                    ldb       $05,s
                    os9       I$MakDir
                    lbra      L6227
                    ldx       $02,s
                    lda       $05,s
                    tfr       a,b
                    andb      #$24
                    orb       #$0b
                    os9       I$Create
                    bcs       L6091
L608D               tfr       a,b
                    clra
                    rts

L6091               cmpb      #$DA
                    lbne      L621E
                    lda       $05,s
                    bita      #$80
                    lbne      L621E
                    anda      #$07
                    ldx       $02,s
                    os9       I$Open
                    lbcs      L621E
                    pshs      u,a
                    ldx       #$0000
                    leau      ,x
                    ldb       #$02
                    os9       I$SetStt
                    puls      u,a
                    bcc       L608D
                    pshs      b
                    os9       I$Close
                    puls      b
                    lbra      L621E
                    ldx       $02,s
                    os9       I$Delete
                    lbra      L6227
                    lda       $03,s
                    os9       I$Dup
                    lbcs      L621E
                    tfr       a,b
L60D7               clra
                    rts
                    pshs      y
                    ldx       $06,s
                    lda       $05,s
                    ldy       $08,s
                    pshs      y
                    os9       I$Read
L60E7               bcc       L60F6
                    cmpb      #$D3
                    bne       L60F1
                    clra
                    clrb
                    puls      pc,y,x
L60F1               puls      y,x
                    lbra      L621E

L60F6               tfr       y,d
L60F8               puls      pc,y,x
                    pshs      y
                    lda       $05,s
                    ldx       $06,s
                    ldy       $08,s
                    pshs      y
                    os9       I$ReadLn
L6108               bra       L60E7
                    pshs      y
                    ldy       $08,s
                    beq       L611F
                    lda       $05,s
                    ldx       $06,s
                    os9       I$Write
L6118               bcc       L611F
                    puls      y
                    lbra      L621E

L611F               tfr       y,d
L6121               puls      pc,y
                    pshs      y
                    ldy       $08,s
                    beq       L611F
                    lda       $05,s
                    ldx       $06,s
                    os9       I$WritLn
L6131               bra       L6118
                    pshs      u
                    ldd       $0a,s
                    bne       L6141
                    ldu       #$0000
                    ldx       #$0000
                    bra       L6175

L6141               cmpd      #$0001
                    beq       L616C
                    cmpd      #$0002
                    beq       L6161
                    ldb       #$F7
L614F               clra
                    std       $0260,y
                    ldd       #$FFFF
                    leax      $0254,y
                    std       ,x
                    std       $02,x
                    puls      pc,u
L6161               lda       $05,s
                    ldb       #$02
                    os9       I$GetStt
                    bcs       L614F
                    bra       L6175

L616C               lda       $05,s
                    ldb       #$05
                    os9       I$GetStt
L6173               bcs       L614F
L6175               tfr       u,d
                    addd      $08,s
                    std       $0256,y
                    tfr       d,u
                    tfr       x,d
                    adcb      $07,s
                    adca      $06,s
                    bmi       L614F
                    tfr       d,x
                    std       $0254,y
                    lda       $05,s
                    os9       I$Seek
                    bcs       L614F
                    leax      $0254,y
L6198               puls      pc,u
                    ldd       $0252,y
                    pshs      d
                    ldd       $04,s
                    cmpd      $02E5,y
                    bcs       L61CE
                    addd      $0252,y
                    pshs      y
                    subd      ,s
                    os9       F$Mem
                    tfr       y,d
                    puls      y
                    bcc       L61C0
                    ldd       #$FFFF
                    leas      $02,s
                    rts

L61C0               std       $0252,y
                    addd      $02E5,y
                    subd      ,s
                    std       $02E5,y
L61CE               leas      $02,s
                    ldd       $02E5,y
                    pshs      d
                    subd      $04,s
                    std       $02E5,y
                    ldd       $0252,y
                    subd      ,s++
                    pshs      d
                    clra
                    ldx       ,s
L61E7               sta       ,x+
                    cmpx      $0252,y
                    bcs       L61E7
L61EF               puls      pc,d
                    ldd       $02,s
                    addd      $025C,y
                    bcs       L621A
                    cmpd      $025e,y
                    bcc       L621A
                    pshs      d
                    ldx       $025C,y
                    clra
L6207               cmpx      ,s
                    bcc       L620F
                    sta       ,x+
                    bra       L6207

L620F               ldd       $025C,y
                    puls      x
                    stx       $025C,y
                    rts

L621A               ldd       #$FFFF
                    rts

L621E               clra
                    std       $0260,y
                    ldd       #$FFFF
                    rts

L6227               bcs       L621E
                    clra
exit                clrb
                    rts
                    lbsr      L6237
                    lbsr      L5229
                    ldd       $02,s
                    os9       F$Exit
* ------------------------------------------------------------------
* L6237 - cc1-style init image for the work block (see _start);
* pure data: rts stub + count/block table + reloc dirs + module name.
* ------------------------------------------------------------------
L6237               fcb       $39       init table / work-block image
                    fcb       $00,$03,$00,$00
                    fcb       $4B
                    fcb       $01,$EB,$00,$02,$00,$04,$00,$08
                    fcb       $00,$10,$00
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
                    fcb       $00,$0A,$00,$00
                    fcb       $44
                    fcb       $C9
                    fcb       $44
                    fcb       $CC
                    fcb       $44
                    fcb       $CF
                    fcb       $44
                    fcb       $D5
                    fcb       $44
                    fcb       $DB
                    fcb       $44
                    fcb       $E0,$00,$00,$00,$00,$00,$00,$00
                    fcb       $80
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
                    fcb       $E4,$00,$00,$00,$00,$00,$00,$00
                    fcb       $01,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$02,$00,$01
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00
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
                    fcb       $00,$00,$00,$00,$00,$00,$00,$01
                    fcb       $01,$01,$01,$01,$01,$01,$01,$01
                    fcb       $11,$11,$01,$11,$11,$01,$01,$01
                    fcb       $01,$01,$01,$01,$01,$01,$01,$01
                    fcb       $01,$01,$01,$01,$01,$01,$01
                    fcc       /0               HHHHHHHHHH       BBBBBB/
                    fcb       $02,$02,$02,$02,$02,$02,$02,$02
                    fcb       $02,$02,$02,$02,$02,$02,$02,$02
                    fcb       $02,$02,$02,$02
                    fcc       /      DDDDDD/
                    fcb       $04,$04,$04,$04,$04,$04,$04,$04
                    fcb       $04,$04,$04,$04,$04,$04,$04,$04
                    fcb       $04,$04,$04,$04
                    fcc       /    /
                    fcb       $01,$00,$06,$00
                    fcb       $57
                    fcb       $00
                    fcb       $55
                    fcb       $00
                    fcb       $53
                    fcb       $00
                    fcb       $51
                    fcb       $00
                    fcb       $4F
                    fcb       $00
                    fcb       $4D
                    fcb       $00,$01,$00,$01
                    fcc       /c.pas/
                    emod
eom                 equ       *
                    end
