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
L0033               leay      L6235,pcr
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

L00E1               leax      $0212,u
                    pshs      x
                    ldd       $024e,u
                    pshs      d
                    leay      ,u
                    bsr       stkinit
                    lbsr      main
                    clr       ,-s
                    clr       ,-s
                    lbsr      exit
stkinit             leax      $02E7,y
L00FF               stx       $025C,y
                    sts       $0250,y
                    sts       $025e,y
                    ldd       #$FF82
stkcheck            leax      d,s
                    cmpx      $025e,y
                    bcc       L0122
                    cmpx      $025C,y
                    bcs       L013C
                    stx       $025e,y
L0122               rts

L0123               bpl       $014F
                    bpl       L0151
                    bra       L017C
                    lsrb
                    fcb       $41
                    coma
                    fcb       $4B
                    bra       $017E
                    rorb
                    fcb       $45,$52
                    rora
                    inca
                    clra
                    asrb
                    bra       L0162
                    bpl       $0164
                    bpl       L0149
L013C               leax      L0123,pcr
                    ldb       #$CF
                    pshs      b
                    lda       #$02
                    ldy       #$0064
L0149               os9       I$WritLn
                    clr       ,-s
                    lbsr      L622F
L0151               ldd       $0250,y
                    subd      $025e,y
                    rts
                    ldd       $025e,y
                    subd      $025C,y
L0162               rts

L0163               pshs      x
                    leax      d,y
                    leax      d,x
                    pshs      x
L016B               ldd       ,y++
                    leax      d,u
                    ldd       ,x
                    addd      $02,s
                    std       ,x
                    cmpy      ,s
                    bne       L016B
                    leas      $04,s
L017C               rts

main                pshs      u
                    ldd       #$FF86
                    lbsr      stkcheck
                    leas      -$24,s
                    lbra      L028E

L018B               ldx       $2a,s
                    leax      $02,x
                    stx       $2a,s
                    ldu       ,x
                    ldb       ,u
                    cmpb      #$2d
                    lbne      L023A
                    lbra      L0230

L01A0               ldb       ,u
                    sex
                    tfr       d,x
                    lbra      L0214

L01A8               ldd       #$0001
                    std       $0011
                    lbra      L0230

L01B0               ldd       #$0001
                    std       copybytes
                    leax      L0B04,pcr
                    pshs      x
                    lbsr      L09DB
                    leas      $02,s
                    lbra      L0230

L01C3               leau      $01,u
                    ldb       ,u
                    cmpb      #$3d
                    bne       L01DA
                    leau      $01,u
                    pshs      u
                    lbsr      L09DB
                    leas      $02,s
                    leax      $24,s
                    lbra      L028B

L01DA               leau      -$01,u
                    pshs      u
                    leax      L0B0E,pcr
                    pshs      x
                    leax      $00DB,y
                    pshs      x
                    lbsr      fprintf
                    leas      $06,s
                    lbsr      L0ADF
L01F2               ldd       #$0001
                    std       $0013
                    bra       L0230

L01F9               ldb       ,u
                    sex
                    pshs      d
                    leax      L0B20,pcr
                    pshs      x
                    leax      $00DB,y
                    pshs      x
                    lbsr      fprintf
                    leas      $06,s
                    lbsr      L0ADF
                    bra       L0230

L0214               cmpx      #$0073
                    lbeq      L01A8
                    cmpx      #$006E
                    lbeq      L01B0
                    cmpx      #$006F
                    lbeq      L01C3
                    cmpx      #$0070
                    beq       L01F2
                    bra       L01F9

L0230               leau      $01,u
                    ldb       ,u
                    lbne      L01A0
                    bra       L028E

L023A               ldd       $0003
                    beq       L025E
                    ldd       $0280,y
                    beq       L0258
                    leax      L0B36,pcr
                    pshs      x
                    leax      $00DB,y
                    pshs      x
                    lbsr      fprintf
                    leas      $04,s
                    lbsr      L0ADF
L0258               stu       $0280,y
                    bra       L028E

L025E               leax      L0B45,pcr
                    pshs      x
                    pshs      u
                    lbsr      L4F06
                    leas      $04,s
                    std       $0003
                    bne       L0285
                    pshs      u
                    leax      L0B47,pcr
                    pshs      x
                    leax      $00DB,y
                    pshs      x
                    lbsr      fprintf
                    leas      $06,s
                    lbsr      L0ADF
L0285               stu       $0284,y
                    bra       L028E

L028B               leas      -$24,x
L028E               ldd       $28,s
                    addd      #$FFFF
                    std       $28,s
                    lbne      L018B
                    ldd       $0005
                    bne       L02A5
                    leax      $00CE,y
                    stx       $0005
L02A5               ldd       $0003
                    bne       L02AF
                    leax      $00C1,y
                    stx       $0003
L02AF               ldd       $0280,y
                    bne       L02BD
                    leax      L0B56,pcr
                    stx       $0280,y
L02BD               lbra      L076E

L02C0               ldx       $1a,s
                    lbra      L06D3

L02C6               ldd       $0003
                    pshs      d
                    lbsr      L5375
                    leas      $02,s
                    std       $1a,s
                    cmpd      #$FFFF
                    beq       L02EF
                    ldd       $0005
                    pshs      d
                    ldd       $1C,s
                    pshs      d
                    lbsr      L515E
                    leas      $04,s
                    ldd       $1a,s
                    cmpd      #$000D
                    bne       L02C6
L02EF               lbra      L076E

L02F2               ldd       $0003
                    pshs      d
                    lbsr      L53D7
                    leas      $02,s
                    std       $0007
                    leax      $14,s
                    pshs      x
                    ldd       $0003
                    pshs      d
                    lbsr      L5375
                    leas      $02,s
                    clra
                    lbsr      L5E0A
                    pshs      x
                    ldd       #$0010
                    lbsr      L5E39
                    lbsr      L5E23
                    leax      $14,s
                    pshs      x
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $0003
                    pshs      d
                    lbsr      L53D7
                    leas      $02,s
                    lbsr      L5E0A
                    lbsr      L5D95
                    lbsr      L5E23
                    leax      $14,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $0007
                    pshs      d
                    lbsr      L4896
                    leas      $06,s
                    lbra      L076E

L0350               ldd       $0003
                    pshs      d
                    lbsr      L53D7
                    leas      $02,s
                    std       $22,s
                    ldd       $0003
                    pshs      d
                    lbsr      L53D7
                    leas      $02,s
                    std       $000B
                    ldd       $0003
                    pshs      d
                    lbsr      L53D7
                    leas      $02,s
                    std       $000D
                    ldd       L0017
                    cmpd      $000D
                    ble       L037D
                    ldd       $000D
                    std       L0017
L037D               ldx       $22,s
                    bra       L03C3

L0382               ldd       $0003
                    pshs      d
                    lbsr      L53D7
                    leas      $02,s
                    std       $1e,s
                    ldd       $0003
                    pshs      d
                    lbsr      L53D7
                    leas      $02,s
                    std       $20,s
                    ldd       $0003
                    pshs      d
                    lbsr      L5375
                    leas      $02,s
                    std       $1C,s
                    bra       L03D2

L03A8               ldd       $0003
                    pshs      d
                    lbsr      L53D7
                    leas      $02,s
                    std       L0023
                    bra       L03D2

L03B5               ldd       $0003
                    pshs      d
                    lbsr      L53D7
                    leas      $02,s
                    std       $18,s
                    bra       L03D2

L03C3               cmpx      #$0002
                    beq       L0382
                    cmpx      #$0005
                    beq       L03A8
                    cmpx      #$0012
                    beq       L03B5
L03D2               lbsr      L0787
                    std       $0282,y
                    ldx       $22,s
                    lbra      L046A

L03DF               ldd       $1C,s
                    pshs      d
                    ldd       $22,s
                    pshs      d
                    ldd       $22,s
                    pshs      d
                    ldd       $0282,y
                    pshs      d
                    lbsr      L1F13
                    leas      $08,s
                    lbra      L048D

L03FC               ldd       $18,s
                    pshs      d
                    ldd       $0282,y
                    pshs      d
                    lbsr      L0A16
                    leas      $04,s
                    lbra      L048D

L040F               ldd       $0282,y
                    pshs      d
                    lbsr      L0D04
                    leas      $02,s
                    std       $0282,y
                    lbra      L048D

L0421               ldd       $0282,y
                    pshs      d
                    lbsr      L0BF7
                    leas      $02,s
                    lbra      L048D

L042F               lbsr      L4B88
                    clra
                    clrb
                    pshs      d
                    ldd       $0282,y
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    lbsr      L40D0
                    leas      $06,s
                    lbsr      L43DC
                    clra
                    clrb
                    std       L0023
                    bra       L048D

L044F               ldd       $22,s
                    pshs      d
                    leax      L0B57,pcr
                    pshs      x
                    leax      $00DB,y
                    pshs      x
                    lbsr      fprintf
                    leas      $06,s
                    lbsr      L0ADF
                    bra       L048D

L046A               cmpx      #$0002
                    lbeq      L03DF
                    cmpx      #$0012
                    lbeq      L03FC
                    cmpx      #$0004
                    lbeq      L040F
                    cmpx      #$0001
                    lbeq      L0421
                    cmpx      #$0005
                    beq       L042F
                    bra       L044F

L048D               ldd       $0282,y
                    pshs      d
                    lbsr      L4A69
                    lbra      L0510

L0499               ldd       $0003
                    pshs      d
                    lbsr      L53D7
                    std       ,s
                    lbsr      L4414
                    lbra      L0510

L04A8               ldd       $1a,s
                    cmpd      #$0064
                    bne       L04B6
                    ldd       #$0001
                    bra       L04B8

L04B6               clra
                    clrb
L04B8               pshs      d
                    lbsr      L4C3E
                    bra       L0510

L04BF               lbsr      L4C54
                    lbra      L076E

L04C5               ldd       $1a,s
                    cmpd      #$FFFF
                    beq       L04FB
                    ldd       $1a,s
                    cmpd      #$005C
                    bne       L04E3
                    ldd       $0003
                    pshs      d
                    lbsr      L5375
                    leas      $02,s
                    std       $1a,s
L04E3               ldd       $1a,s
                    pshs      d
                    lbsr      L4C92
                    leas      $02,s
L04ED               ldd       $0003
                    pshs      d
                    lbsr      L5375
                    leas      $02,s
                    std       $1a,s
                    bne       L04C5
L04FB               clra
                    clrb
                    pshs      d
                    lbsr      L4C92
                    bra       L0510

L0504               ldd       $0003
                    pshs      d
                    lbsr      L53D7
                    std       ,s
                    lbsr      L0AC2
L0510               leas      $02,s
                    lbra      L076E

L0515               clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    ldd       #$0012
                    lbra      L057D

L0523               ldd       $0003
                    pshs      d
                    lbsr      L53D7
                    leas      $02,s
                    std       $18,s
                    pshs      d
                    ldd       $0003
                    pshs      d
                    lbsr      L53D7
                    std       ,s
                    ldd       #$007D
                    bra       L057D

L053F               clra
                    clrb
                    pshs      d
                    ldd       $0003
                    pshs      d
                    lbsr      L53D7
                    std       ,s
                    ldd       #$001D
                    bra       L057D

L0551               clra
                    clrb
                    pshs      d
                    ldd       $0003
                    pshs      d
                    lbsr      L53D7
                    std       ,s
                    ldd       #$007C
                    bra       L057D

L0563               ldd       $0003
                    pshs      d
                    lbsr      L53D7
                    leas      $02,s
                    std       $18,s
                    pshs      d
                    ldd       $0003
                    pshs      d
                    lbsr      L53D7
                    std       ,s
                    ldd       #$0009
L057D               pshs      d
                    lbsr      L3292
                    leas      $06,s
                    lbra      L076E

L0587               ldd       $0003
                    pshs      d
                    lbsr      L53D7
                    std       ,s
                    ldd       #$0076
                    bra       L05A1

L0595               ldd       $0003
                    pshs      d
                    lbsr      L53D7
                    std       ,s
                    ldd       #$006F
L05A1               pshs      d
                    lbsr      L3292
                    leas      $04,s
                    lbra      L076E

L05AB               ldd       $0003
                    pshs      d
                    lbsr      L5375
                    leas      $02,s
                    std       $18,s
                    ldd       $0011
                    bne       L05C6
                    ldd       $0003
                    pshs      d
                    lbsr      L53D7
                    leas      $02,s
                    std       $000B
L05C6               leau      ,s
                    bra       L05CF

L05CA               ldd       $1a,s
                    stb       ,u+
L05CF               ldd       $0003
                    pshs      d
                    lbsr      L5375
                    leas      $02,s
                    std       $1a,s
                    bne       L05CA
                    clra
                    clrb
                    stb       ,u
                    ldd       $0013
                    beq       L05F1
                    ldd       $0003
                    pshs      d
                    lbsr      L53D7
                    leas      $02,s
                    std       $1a,s
L05F1               ldd       $1a,s
                    pshs      d
                    ldd       $000B
                    pshs      d
                    ldd       $1C,s
                    pshs      d
                    leax      $06,s
                    pshs      x
                    lbsr      L4B96
                    leas      $08,s
                    lbra      L076E

L060B               lbsr      L4C1A
                    lbra      L076E

L0611               leas      -$0a,s
                    ldd       $0003
                    pshs      d
                    lbsr      L53D7
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
                    lbsr      L4F58
                    leas      $08,s
                    leax      $02,s
                    pshs      x
                    lbsr      L095C
                    leas      $02,s
                    ldd       ,s
                    cmpd      #$0006
                    bne       L0654
                    ldd       #$0004
                    pshs      d
                    leax      $04,s
                    pshs      x
                    lbsr      L3DD0
                    bra       L0670

L0654               leas      -$04,s
                    leax      ,s
                    pshs      x
                    leax      $08,s
                    lbsr      L56F2
                    lbsr      L5D68
                    ldd       #$0002
                    pshs      d
                    leax      $02,s
                    pshs      x
                    lbsr      L3DD0
                    leas      $04,s
L0670               leas      $04,s
                    leas      $0a,s
                    lbra      L076E
                    leas      $0a,s
L0679               lbsr      L4C61
                    lbra      L076E

L067F               leau      $0262,y
                    bra       L069E

L0685               ldd       $1a,s
                    cmpd      #$FFFF
                    beq       L06B0
                    leax      $027f,y
                    pshs      x
                    cmpu      ,s++
                    beq       L069E
                    ldd       $1a,s
                    stb       ,u+
L069E               ldd       $0003
                    pshs      d
                    lbsr      L5375
                    leas      $02,s
                    std       $1a,s
                    cmpd      #$000D
                    bne       L0685
L06B0               clra
                    clrb
                    stb       ,u
                    lbra      L076E

L06B7               ldd       $1a,s
                    pshs      d
                    leax      L0B6C,pcr
                    pshs      x
                    leax      $00DB,y
                    pshs      x
                    lbsr      fprintf
                    leas      $06,s
                    lbsr      L0ADF
                    lbra      L076E

L06D3               cmpx      #$002A
                    lbeq      L02C6
                    cmpx      #$004F
                    lbeq      L02F2
                    cmpx      #$0054
                    lbeq      L0350
                    cmpx      #$006C
                    lbeq      L0499
                    cmpx      #$0076
                    lbeq      L04A8
                    cmpx      #$0064
                    lbeq      L04A8
                    cmpx      #$0065
                    lbeq      L04BF
                    cmpx      #$0073
                    lbeq      L04ED
                    cmpx      #$004D
                    lbeq      L0504
                    cmpx      #$0072
                    lbeq      L0515
                    cmpx      #$004A
                    lbeq      L0523
                    cmpx      #$0047
                    lbeq      L053F
                    cmpx      #$006A
                    lbeq      L0551
                    cmpx      #$0044
                    lbeq      L0563
                    cmpx      #$0059
                    lbeq      L0587
                    cmpx      #$0055
                    lbeq      L0595
                    cmpx      #$0053
                    lbeq      L05AB
                    cmpx      #$0045
                    lbeq      L060B
                    cmpx      #$0066
                    lbeq      L0611
                    cmpx      #$0070
                    lbeq      L0679
                    cmpx      #$0046
                    lbeq      L067F
                    cmpx      #$000D
                    beq       L076E
                    lbra      L06B7

L076E               ldd       $0003
                    pshs      d
                    lbsr      L5375
                    leas      $02,s
                    std       $1a,s
                    cmpd      #$FFFF
                    lbne      L02C0
                    leas      $24,s
                    puls      pc,u
L0787               pshs      u
                    ldd       #$FFAA
                    lbsr      stkcheck
                    leas      -$0a,s
                    ldd       $0003
                    pshs      d
                    lbsr      L5375
                    leas      $02,s
                    std       $06,s
                    ldd       #$0016
                    pshs      d
                    lbsr      $310F
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    bne       L07AF
                    lbsr      L4834
L07AF               ldd       $0003
                    pshs      d
                    lbsr      L53D7
                    leas      $02,s
                    std       ,u
                    ldd       $0003
                    pshs      d
                    lbsr      L53D7
                    leas      $02,s
                    std       $02,u
                    ldd       $0003
                    pshs      d
                    lbsr      L53D7
                    leas      $02,s
                    std       $06,u
                    ldd       $0003
                    pshs      d
                    lbsr      L53D7
                    leas      $02,s
                    std       $0e,u
                    ldd       $0003
                    pshs      d
                    lbsr      L5375
                    leas      $02,s
                    clra
                    std       $10,u
                    ldd       $0003
                    pshs      d
                    lbsr      L5375
                    leas      $02,s
                    std       $12,u
                    ldd       $0003
                    pshs      d
                    lbsr      L53D7
                    leas      $02,s
                    std       $14,u
                    ldx       $06,u
                    lbra      L08F4

L0805               ldd       #$000D
                    pshs      d
                    lbsr      $310F
                    leas      $02,s
                    std       $08,s
                    std       $08,u
                    ldd       $08,s
                    bne       L081A
                    lbsr      L4834
L081A               ldd       $0003
                    pshs      d
                    lbsr      L5375
                    leas      $02,s
                    ldx       $08,s
                    std       $02,x
                    ldd       $0003
                    pshs      d
                    lbsr      L5375
                    leas      $02,s
                    std       [$08,s]
                    ldx       [$08,s]
                    bra       L086A

L0838               ldd       $08,s
                    addd      #$0004
                    std       $04,s
L083F               ldd       $0003
                    pshs      d
                    lbsr      L5375
                    leas      $02,s
                    ldx       $04,s
                    leax      $01,x
                    stx       $04,s
                    stb       -$01,x
                    bne       L083F
                    clra
                    clrb
                    stb       [$04,s]
                    lbra      L0909

L085A               ldd       $0003
                    pshs      d
                    lbsr      L53D7
                    leas      $02,s
                    ldx       $08,s
                    std       $04,x
                    lbra      L0909

L086A               cmpx      #$000E
                    beq       L0838
                    cmpx      #$000C
                    lbeq      L0838
                    cmpx      #$0021
                    lbeq      L0838
                    cmpx      #$0022
                    lbeq      L0838
                    bra       L085A

L0886               ldd       #$0004
                    pshs      d
                    lbsr      $310F
                    leas      $02,s
                    std       $02,s
                    bne       L0897
                    lbsr      L4834
L0897               ldd       $0003
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    ldd       #$0004
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L4F58
                    leas      $08,s
                    ldd       $02,s
                    bra       L08F0

L08B2               ldd       #$0008
                    pshs      d
                    lbsr      $310F
                    leas      $02,s
                    std       ,s
                    bne       L08C3
                    lbsr      L4834
L08C3               ldd       $0003
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    ldd       #$0008
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L4F58
                    leas      $08,s
                    ldd       ,s
                    pshs      d
                    lbsr      L095C
                    leas      $02,s
                    ldd       ,s
                    bra       L08F0

L08E7               ldd       $0003
                    pshs      d
                    lbsr      L53D7
                    leas      $02,s
L08F0               std       $08,u
                    bra       L0909

L08F4               cmpx      #$0034
                    lbeq      L0805
                    cmpx      #$004A
                    lbeq      L0886
                    cmpx      #$004B
                    beq       L08B2
                    bra       L08E7

L0909               clra
                    clrb
                    std       $0a,u
                    ldx       $06,s
                    bra       L0940

L0911               lbsr      L0787
                    std       $0a,u
L0916               lbsr      L0787
                    bra       L0922

L091B               lbsr      L0787
                    std       $0a,u
L0920               clra
                    clrb
L0922               std       $0C,u
                    bra       L0956

L0926               ldd       $06,s
                    pshs      d
                    leax      L0B91,pcr
                    pshs      x
                    leax      $00DB,y
                    pshs      x
                    lbsr      fprintf
                    leas      $06,s
                    lbsr      L0ADF
                    bra       L0956

L0940               cmpx      #$0042
                    beq       L0911
                    cmpx      #$0052
                    beq       L0916
                    cmpx      #$004C
                    beq       L091B
                    cmpx      #$004E
                    beq       L0920
                    bra       L0926

L0956               tfr       u,d
                    leas      $0a,s
                    puls      pc,u
L095C               pshs      u
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
                    beq       L098B
                    ldb       [$06,s]
                    clra
                    andb      #$7f
                    stb       [$06,s]
L098B               leax      ,u
                    pshs      x
                    pshs      u
                    lbsr      L5675
                    leas      $02,s
                    lbsr      L5D78
                    ldd       $02,s
                    bge       L09A9
                    ldd       $02,s
                    nega
                    negb
                    sbca      #$00
                    std       $02,s
                    clra
                    clrb
                    bra       L09AC

L09A9               ldd       #$0001
L09AC               std       $04,s
                    leax      ,u
                    pshs      x
                    ldd       $06,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    leax      ,u
                    lbsr      L5D51
                    lbsr      L55A2
                    leas      $0C,s
                    lbsr      L5D78
                    ldd       ,s
                    beq       L09D7
                    leax      ,u
                    pshs      x
                    leax      ,u
                    lbsr      L5690
                    lbsr      L5D78
L09D7               leas      $08,s
                    puls      pc,u
L09DB               pshs      u
                    ldd       #$FFB6
                    lbsr      stkcheck
                    ldd       $0005
                    beq       L09E9
                    puls      pc,u
L09E9               leax      L0BA6,pcr
                    pshs      x
                    ldd       $06,s
                    pshs      d
                    lbsr      L4F06
                    leas      $04,s
                    std       $0005
                    bne       L0A14
                    ldd       $04,s
                    pshs      d
                    leax      L0BA8,pcr
                    pshs      x
                    leax      $00DB,y
                    pshs      x
                    lbsr      fprintf
                    leas      $06,s
                    lbsr      L0ADF
L0A14               puls      pc,u
L0A16               pshs      u
                    ldd       #$FFB6
                    lbsr      stkcheck
                    ldu       $04,s
                    ldx       $06,s
                    lbra      L0AA9

L0A25               pshs      u
                    lbsr      L2505
                    leas      $02,s
                    leax      ,s
                    bra       L0A39

L0A30               pshs      u
                    lbsr      L29FC
                    leas      $02,s
                    bra       L0A3B

L0A39               leas      ,x
L0A3B               ldd       $06,u
                    cmpd      #$0080
                    lbeq      L0AC0
                    ldd       #$0080
                    pshs      d
                    ldd       #$006F
                    pshs      d
                    ldd       #$007F
                    pshs      d
                    lbsr      L3292
                    leas      $06,s
                    ldd       #$006F
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3292
                    leas      $04,s
                    ldx       $06,s
                    bra       L0A92

L0A6C               ldd       $06,s
                    pshs      d
                    ldd       #$0089
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L3292
                    leas      $06,s
                    bra       L0AC0

L0A81               ldd       #$0089
                    pshs      d
                    ldd       #$0088
                    pshs      d
                    lbsr      L3292
                    leas      $04,s
                    bra       L0AC0

L0A92               cmpx      #$0005
                    beq       L0A6C
                    cmpx      #$0006
                    lbeq      L0A6C
                    bra       L0A81

L0AA0               pshs      u
                    lbsr      L0BC3
                    leas      $02,s
                    bra       L0AC0

L0AA9               cmpx      #$0008
                    lbeq      L0A25
                    cmpx      #$0005
                    lbeq      L0A30
                    cmpx      #$0006
                    lbeq      L0A30
                    bra       L0AA0

L0AC0               puls      pc,u
L0AC2               pshs      u
                    ldd       #$FFB6
                    lbsr      stkcheck
                    ldd       $04,s
                    pshs      d
                    leax      L0BB7,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      fprintf
                    leas      $06,s
                    puls      pc,u
L0ADF               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    ldd       $0284,y
                    beq       L0AF8
                    ldd       $0284,y
                    pshs      d
                    lbsr      L60C1
                    leas      $02,s
L0AF8               ldd       #$0001
                    pshs      d
                    lbsr      exit
                    leas      $02,s
                    puls      pc,u
L0B04               fcc       |/dev/null|
                    fcb       $00
L0B0E               fcc       /bad argument: %s/
                    fcb       $0D,$00
L0B20               fcc       /bad option flag: +%c/
                    fcb       $0D,$00
L0B36               fcc       /too many files/
                    fcb       $00
L0B45               fcb       $72
                    fcb       $00
L0B47               fcc       /can't open %s/
                    fcb       $0D,$00
L0B56               fcb       $00
L0B57               fcc       /bad action code: %d/
                    fcb       $0D,$00
L0B6C               fcc       /bad code in intermediate file: %02x/
                    fcb       $0D,$00
L0B91               fcc       /bad node type: %02x/
                    fcb       $0D,$00
L0BA6               fcb       $77
                    fcb       $00
L0BA8               fcc       /can't open %s/
                    fcb       $0D,$00
L0BB7               fcc       / leas %d,s/
                    fcb       $0D,$00
L0BC3               pshs      u
                    ldd       #$FFB4
                    lbsr      stkcheck
                    ldu       $04,s
                    pshs      u
                    lbsr      L0C2D
                    leas      $02,s
                    ldd       $06,u
                    cmpd      #$0070
                    beq       L0C2B
                    pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3292
                    leas      $08,s
                    ldd       #$0070
                    bra       L0C29

L0BF7               pshs      u
                    ldd       #$FFB4
                    lbsr      stkcheck
                    ldu       $04,s
                    pshs      u
                    lbsr      L1C1D
                    leas      $02,s
                    ldd       $06,u
                    cmpd      #$0071
                    beq       L0C2B
                    pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3292
                    leas      $08,s
                    ldd       #$0071
L0C29               std       $06,u
L0C2B               puls      pc,u
L0C2D               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    ldu       $04,s
                    ldx       ,u
                    bra       L0C58

L0C3B               pshs      u
                    lbsr      L2505
                    bra       L0C54

L0C42               pshs      u
                    lbsr      L29FC
                    bra       L0C54

L0C49               pshs      u
                    lbsr      L0D04
                    leas      $02,s
                    pshs      u
                    bsr       L0C6D
L0C54               leas      $02,s
                    bra       L0C6B

L0C58               cmpx      #$0008
                    beq       L0C3B
                    cmpx      #$0005
                    beq       L0C42
                    cmpx      #$0006
                    lbeq      L0C42
                    bra       L0C49

L0C6B               puls      pc,u
L0C6D               pshs      u
                    ldd       #$FFB4
                    lbsr      stkcheck
                    ldu       $04,s
                    ldx       $06,u
                    lbra      L0CE0

L0C7C               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3292
                    leas      $08,s
                    ldd       #$0071
                    std       $06,u
                    clra
                    clrb
                    std       $08,u
                    lbra      L0D02

L0C9E               ldd       $0a,u
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$007F
                    pshs      d
                    lbsr      L3292
                    leas      $08,s
                    clra
                    clrb
                    std       $08,u
                    ldd       #$0071
                    bra       L0CDC

L0CBF               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3292
                    leas      $08,s
                    bra       L0CD9
                    leas      ,x
L0CD9               ldd       #$0070
L0CDC               std       $06,u
                    bra       L0D02

L0CE0               cmpx      #$0037
                    lbeq      L0C7C
                    cmpx      #$0041
                    beq       L0C9E
                    cmpx      #$0071
                    beq       L0D02
                    cmpx      #$0070
                    beq       L0D02
                    cmpx      #$006F
                    beq       L0D02
                    cmpx      #$0076
                    beq       L0D02
                    bra       L0CBF

L0D02               puls      pc,u
L0D04               pshs      u
                    ldd       #$FFB4
                    lbsr      stkcheck
                    ldu       $04,s
                    leas      -$02,s
                    ldd       $06,u
                    std       ,s
                    cmpd      #$0030
                    bne       L0D4D
                    leas      -$02,s
                    ldd       $0C,u
                    std       ,s
                    ldd       $0a,u
                    pshs      d
                    bsr       L0D04
                    std       ,s
                    lbsr      L4A69
                    leas      $02,s
                    pshs      u
                    ldd       $02,s
                    pshs      d
                    lbsr      L4ACD
                    leas      $04,s
                    ldd       ,s
                    pshs      d
                    lbsr      L4A8A
                    leas      $02,s
                    pshs      u
                    lbsr      L0D04
                    leas      $02,s
                    leas      $02,s
                    lbra      L0EF7

L0D4D               ldd       ,u
                    cmpd      #$0008
                    bne       L0D5F
                    pshs      u
                    lbsr      L2520
                    leas      $02,s
                    lbra      L0EF7

L0D5F               ldd       ,u
                    cmpd      #$0005
                    beq       L0D6F
                    ldd       ,u
                    cmpd      #$0006
                    bne       L0D79
L0D6F               pshs      u
                    lbsr      L2A17
                    leas      $02,s
                    lbra      L0EF7

L0D79               ldd       ,s
                    pshs      d
                    lbsr      L4AF7
                    std       ,s++
                    beq       L0D92
                    pshs      u
                    ldd       $02,s
                    pshs      d
                    lbsr      L0EFD
                    leas      $04,s
                    lbra      L0EF7

L0D92               ldx       ,s
                    lbra      L0E5E

L0D97               pshs      u
                    lbsr      L1567
                    lbra      L0E27

L0D9F               ldd       $0a,u
                    pshs      d
                    lbsr      L0D04
                    lbra      L0E27

L0DA9               ldd       $0a,u
                    pshs      d
                    lbsr      L2520
                    leas      $02,s
                    ldd       $0a,u
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       #$0084
                    pshs      d
                    lbsr      L3292
                    leas      $06,s
                    bra       L0E0E

L0DC7               ldd       $0a,u
                    pshs      d
                    lbsr      L29FC
                    leas      $02,s
                    ldd       #$008F
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L3292
                    bra       L0E0C

L0DDF               pshs      u
                    lbsr      L1953
                    bra       L0E27

L0DE6               pshs      u
                    lbsr      L124C
                    bra       L0E27

L0DED               ldd       $0a,u
                    pshs      d
                    lbsr      L0BC3
                    leas      $02,s
                    ldd       ,s
                    pshs      d
                    lbsr      L3292
                    leas      $02,s
                    bra       L0E0E

L0E01               leax      L0BC3,pcr
                    pshs      x
                    pshs      u
                    lbsr      L12E8
L0E0C               leas      $04,s
L0E0E               ldd       #$0070
                    std       $06,u
                    lbra      L0EF7

L0E16               ldd       #$0070
                    pshs      d
                    pshs      u
                    lbsr      L1A9A
                    bra       L0E59

L0E22               pshs      u
                    lbsr      L1364
L0E27               leas      $02,s
                    lbra      L0EF7

L0E2C               ldd       ,s
                    cmpd      #$00A0
                    blt       L0E3F
                    ldd       ,s
                    pshs      d
                    pshs      u
                    lbsr      L16CB
                    bra       L0E59

L0E3F               leax      L1ED4,pcr
                    pshs      x
                    pshs      u
                    lbsr      L484B
                    leas      $04,s
                    ldd       ,s
                    pshs      d
                    leax      L1EE0,pcr
                    pshs      x
                    lbsr      L2D3F
L0E59               leas      $04,s
                    lbra      L0EF7

L0E5E               cmpx      #$0037
                    lbeq      L0EF7
                    cmpx      #$0034
                    lbeq      L0EF7
                    cmpx      #$0076
                    lbeq      L0EF7
                    cmpx      #$006F
                    lbeq      L0EF7
                    cmpx      #$0041
                    beq       L0EF7
                    cmpx      #$0036
                    beq       L0EF7
                    cmpx      #$0078
                    lbeq      L0D97
                    cmpx      #$0085
                    lbeq      L0D9F
                    cmpx      #$0084
                    lbeq      L0DA9
                    cmpx      #$008F
                    lbeq      L0DC7
                    cmpx      #$0042
                    lbeq      L0DDF
                    cmpx      #$0040
                    lbeq      L0DE6
                    cmpx      #$0047
                    lbeq      L0DE6
                    cmpx      #$0048
                    lbeq      L0DE6
                    cmpx      #$0044
                    lbeq      L0DED
                    cmpx      #$0043
                    lbeq      L0DED
                    cmpx      #$0064
                    lbeq      L0E01
                    cmpx      #$003C
                    lbeq      L0E16
                    cmpx      #$003E
                    lbeq      L0E16
                    cmpx      #$003D
                    lbeq      L0E16
                    cmpx      #$003F
                    lbeq      L0E16
                    cmpx      #$0065
                    lbeq      L0E22
                    lbra      L0E2C

L0EF7               tfr       u,d
                    leas      $02,s
                    puls      pc,u
L0EFD               pshs      u
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
                    bne       L0F3F
                    ldx       $0a,s
                    bra       L0F2E

L0F1D               ldd       #$004E
                    bra       L0F2A

L0F22               ldd       #$004C
                    bra       L0F2A

L0F27               ldd       #$004D
L0F2A               std       $0a,s
                    bra       L0F73

L0F2E               cmpx      #$0053
                    beq       L0F1D
                    cmpx      #$0054
                    beq       L0F22
                    cmpx      #$0055
                    beq       L0F27
                    bra       L0F73

L0F3F               ldx       $0a,s
                    bra       L0F67

L0F43               ldd       $06,u
                    cmpd      #$0041
                    bne       L0F73
                    ldx       $04,s
                    ldd       $06,x
                    cmpd      #$0036
                    beq       L0F73
                    ldd       $0C,s
                    pshs      d
                    lbsr      L1C1D
                    leas      $02,s
                    clra
                    clrb
                    std       L0019
                    lbra      L1360
                    bra       L0F73

L0F67               cmpx      #$0050
                    beq       L0F43
                    cmpx      #$0051
                    lbeq      L0F43
L0F73               ldx       $0a,s
                    lbra      L1167

L0F78               ldd       $04,s
                    pshs      d
                    lbsr      L22CA
                    std       ,s++
                    bne       L0FAA
                    ldd       $04,s
                    pshs      d
                    lbsr      L0C2D
                    leas      $02,s
                    ldx       $04,s
                    ldd       $06,x
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3292
                    leas      $04,s
                    ldd       #$006E
                    ldx       $04,s
                    std       $06,x
                    pshs      u
                    lbsr      L0BC3
                    bra       L0FB8

L0FAA               pshs      u
                    lbsr      L0BC3
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L0D04
L0FB8               leas      $02,s
                    ldd       $04,s
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0051
                    lbra      L1063

L0FCE               pshs      u
                    lbsr      L22CA
                    std       ,s++
                    beq       L0FE2
                    ldd       $04,s
                    pshs      d
                    lbsr      L22CA
                    std       ,s++
                    beq       L0FEA
L0FE2               ldd       $06,u
                    cmpd      #$0036
                    bne       L0FF6
L0FEA               leas      -$02,s
                    stu       ,s
                    ldu       $06,s
                    ldd       ,s
                    std       $06,s
                    leas      $02,s
L0FF6               ldd       $06,u
                    pshs      d
                    lbsr      L1EB3
                    std       ,s++
                    beq       L1021
                    ldd       $06,u
L1003               pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3292
                    leas      $04,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L0BC3
                    leas      $02,s
                    ldd       #$006E
                    ldx       $04,s
                    std       $06,x
                    bra       L1052

L1021               pshs      u
                    lbsr      L0BC3
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L22CA
                    std       ,s++
                    bne       L1038
                    ldd       #$0070
                    bra       L1003

L1038               ldd       $04,s
                    pshs      d
                    lbsr      L0D04
                    leas      $02,s
                    ldd       $0a,s
                    cmpd      #$0050
                    beq       L1052
                    ldd       $04,s
                    pshs      d
                    lbsr      L152D
                    leas      $02,s
L1052               ldd       $04,s
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       $10,s
L1063               pshs      d
                    lbsr      L3292
                    leas      $08,s
                    lbra      L120D

L106D               ldd       $0C,s
                    pshs      d
                    lbsr      L124C
                    lbra      L1150

L1077               ldx       $04,s
                    ldd       $06,x
                    cmpd      #$0036
                    lbne      L10DB
                    ldx       $04,s
                    ldd       $08,x
                    std       ,s
                    bra       L108D

L108B               leas      -$06,x
L108D               ldd       ,s
                    cmpd      #$0004
                    bhi       L10DB
                    pshs      u
                    lbsr      L0BC3
L109A               leas      $02,s
                    bra       L10C5

L109E               ldx       $0a,s
                    bra       L10B6

L10A2               ldd       #$0098
                    bra       L10AF

L10A7               ldd       #$0096
                    bra       L10AF

L10AC               ldd       #$0097
L10AF               pshs      d
                    lbsr      L3292
                    bra       L109A

L10B6               cmpx      #$0056
                    beq       L10A2
                    cmpx      #$0055
                    beq       L10A7
                    cmpx      #$004D
                    beq       L10AC
L10C5               ldd       ,s
                    addd      #$FFFF
                    std       ,s
                    subd      #$FFFF
                    bne       L109E
                    ldd       #$0001
                    std       L0019
                    leax      $06,s
                    lbra      L1213

L10DB               leax      $06,s
                    bra       L1129

L10DF               ldd       $06,u
                    cmpd      #$0036
                    bne       L10F3
                    leas      -$02,s
                    stu       ,s
                    ldu       $06,s
                    ldd       ,s
                    std       $06,s
                    leas      $02,s
L10F3               ldx       $04,s
                    ldd       $06,x
                    cmpd      #$0036
                    bne       L112B
                    ldx       $04,s
                    ldd       $08,x
                    pshs      d
                    lbsr      L121F
                    leas      $02,s
                    std       ,s
                    beq       L112B
                    ldd       ,s
                    ldx       $04,s
                    std       $08,x
                    ldd       $0a,s
                    cmpd      #$0052
                    bne       L111F
                    ldd       #$0056
                    bra       L1122

L111F               ldd       #$004D
L1122               std       $0a,s
                    leax      $06,s
                    lbra      L108B

L1129               leas      -$06,x
L112B               pshs      u
                    lbsr      L0C2D
                    leas      $02,s
                    ldd       $06,u
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3292
                    leas      $04,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L0BC3
                    leas      $02,s
                    ldd       $0a,s
                    pshs      d
                    lbsr      L3292
L1150               leas      $02,s
                    lbra      L120D

L1155               leax      L1EE4,pcr
                    pshs      x
                    ldd       $0e,s
                    pshs      d
                    lbsr      L484B
                    leas      $04,s
                    lbra      L120D

L1167               cmpx      #$0051
                    lbeq      L0F78
                    cmpx      #$0057
                    lbeq      L0FCE
                    cmpx      #$0058
                    lbeq      L0FCE
                    cmpx      #$0059
                    lbeq      L0FCE
                    cmpx      #$0050
                    lbeq      L0FCE
                    cmpx      #$005A
                    lbeq      L106D
                    cmpx      #$005B
                    lbeq      L106D
                    cmpx      #$005F
                    lbeq      L106D
                    cmpx      #$005D
                    lbeq      L106D
                    cmpx      #$005C
                    lbeq      L106D
                    cmpx      #$005E
                    lbeq      L106D
                    cmpx      #$0063
                    lbeq      L106D
                    cmpx      #$0061
                    lbeq      L106D
                    cmpx      #$0060
                    lbeq      L106D
                    cmpx      #$0062
                    lbeq      L106D
                    cmpx      #$004D
                    lbeq      L1077
                    cmpx      #$0055
                    lbeq      L1077
                    cmpx      #$0056
                    lbeq      L1077
                    cmpx      #$0052
                    lbeq      L10DF
                    cmpx      #$004E
                    lbeq      L10F3
                    cmpx      #$0053
                    lbeq      L112B
                    cmpx      #$004C
                    lbeq      L112B
                    cmpx      #$0054
                    lbeq      L112B
                    lbra      L1155
                    leas      -$06,x
L120D               clra
                    clrb
                    std       L0019
                    bra       L1215

L1213               leas      -$06,x
L1215               ldd       #$0070
                    ldx       $0C,s
                    std       $06,x
                    lbra      L1360

L121F               pshs      u
                    ldd       #$FFC0
                    lbsr      stkcheck
                    ldu       #$0000
                    bra       L1243

L122C               tfr       u,d
                    leau      $01,u
                    aslb
                    rola
                    leax      >$0027,y
                    leax      d,x
                    ldd       ,x
                    cmpd      $04,s
                    bne       L1243
                    tfr       u,d
                    puls      pc,u
L1243               cmpu      #$000E
                    blt       L122C
                    lbra      L1529

L124C               pshs      u
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
                    lbsr      L1F13
                    leas      $08,s
                    ldd       $02,s
                    pshs      d
                    lbsr      L4414
                    leas      $02,s
                    ldd       #$0001
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3292
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
                    lbsr      L3292
                    leas      $06,s
                    ldd       ,s
                    pshs      d
                    lbsr      L4414
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
                    lbsr      L3292
                    leas      $08,s
                    ldd       $02,s
                    pshs      d
                    lbsr      L4414
                    leas      $02,s
                    ldd       #$0070
                    std       $06,u
                    lbra      L1A96

L12E8               pshs      u
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
                    lbsr      L1F13
                    leas      $08,s
                    ldu       $0C,u
                    ldd       $04,s
                    pshs      d
                    lbsr      L4414
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
                    lbsr      L3292
                    leas      $06,s
                    ldd       ,s
                    pshs      d
                    lbsr      L4414
                    leas      $02,s
                    ldd       $0C,u
                    pshs      d
                    jsr       [$0e,s]
                    leas      $02,s
                    ldd       $02,s
                    pshs      d
                    lbsr      L4414
                    leas      $02,s
L1360               leas      $06,s
                    puls      pc,u
L1364               pshs      u
                    ldd       #$FFB2
                    lbsr      stkcheck
                    leas      -$04,s
                    ldd       $000D
                    std       ,s
                    ldd       $08,s
                    std       $02,s
                    lbra      L1401

L1379               ldx       $02,s
                    ldu       $0a,x
                    ldd       ,u
                    cmpd      #$0008
                    bne       L13A8
                    ldd       $06,u
                    cmpd      #$004A
                    bne       L1397
                    pshs      u
                    lbsr      L294B
                    leas      $02,s
                    lbra      L1401

L1397               pshs      u
                    lbsr      L2505
                    leas      $02,s
                    ldd       #$006E
                    pshs      d
                    ldd       #$0088
                    bra       L13FA

L13A8               ldd       ,u
                    cmpd      #$0005
                    beq       L13B8
                    ldd       ,u
                    cmpd      #$0006
                    bne       L13C9
L13B8               pshs      u
                    lbsr      L29FC
                    leas      $02,s
                    ldd       #$006E
                    pshs      d
                    ldd       #$0087
                    bra       L13FA

L13C9               pshs      u
                    lbsr      L0D04
                    leas      $02,s
                    ldx       $06,u
                    bra       L13DD

L13D4               pshs      u
                    lbsr      L0C6D
                    leas      $02,s
                    bra       L13F3

L13DD               cmpx      #$0070
                    beq       L13F3
                    cmpx      #$0071
                    beq       L13F3
                    cmpx      #$006F
                    beq       L13F3
                    cmpx      #$0076
                    beq       L13F3
                    bra       L13D4

L13F3               ldd       $06,u
                    pshs      d
                    ldd       #$007A
L13FA               pshs      d
                    lbsr      L3292
                    leas      $04,s
L1401               ldx       $02,s
                    ldd       $0C,x
                    std       $02,s
                    lbne      L1379
                    ldx       $08,s
                    ldd       $0a,x
                    pshs      d
                    lbsr      L0D04
                    leas      $02,s
                    ldx       $08,s
                    ldd       $0a,x
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       #$0065
                    pshs      d
                    lbsr      L3292
                    leas      $06,s
                    ldd       ,s
                    pshs      d
                    lbsr      L443F
                    leas      $02,s
                    std       $000D
                    ldd       #$0070
                    ldx       $08,s
                    std       $06,x
                    lbra      L1A96

L1440               pshs      u
                    ldd       #$FFB8
                    lbsr      stkcheck
                    ldu       $04,s
                    leas      -$02,s
                    ldx       $06,u
                    bra       L1485

L1450               ldd       $0a,u
                    std       ,s
                    tfr       d,x
                    ldx       $06,x
                    bra       L1469

L145A               ldd       #$0001
                    bra       L149A

L145F               ldd       ,s
                    pshs      d
                    bsr       L149E
                    leas      $02,s
                    bra       L149A

L1469               cmpx      #$0036
                    beq       L145A
                    cmpx      #$0034
                    lbeq      L145A
                    cmpx      #$0076
                    lbeq      L145A
                    cmpx      #$006F
                    lbeq      L145A
                    bra       L145F

L1485               cmpx      #$0034
                    lbeq      L145A
                    cmpx      #$0036
                    lbeq      L145A
                    cmpx      #$0042
                    beq       L1450
                    clra
                    clrb
L149A               leas      $02,s
                    puls      pc,u
L149E               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    ldu       $04,s
                    ldx       $06,u
                    bra       L14CC

L14AC               ldx       $0a,u
                    ldd       $06,x
                    pshs      d
                    lbsr      L1EB3
                    std       ,s++
                    lbeq      L1529
                    ldx       $0C,u
                    ldd       $06,x
                    cmpd      #$0036
                    lbne      L1529
                    bra       L150A
                    lbra      L1529

L14CC               cmpx      #$0050
                    beq       L14AC
                    cmpx      #$0051
                    lbeq      L14AC
                    bra       L1529

L14DA               pshs      u
                    ldd       #$FFC0
                    lbsr      stkcheck
                    ldx       $04,s
                    ldd       $12,x
                    cmpd      #$0002
                    bge       L1529
                    ldd       #$0001
                    bra       L152B

L14F2               pshs      u
                    ldd       #$FFC0
                    lbsr      stkcheck
                    ldu       $04,s
                    ldx       $06,u
                    bra       L1511

L1500               ldx       $0a,u
                    ldd       $06,x
                    cmpd      #$0041
                    bne       L1529
L150A               ldd       #$0001
                    puls      pc,u
                    bra       L1529

L1511               cmpx      #$0050
                    beq       L1500
                    cmpx      #$0051
                    lbeq      L1500
                    cmpx      #$0037
                    beq       L150A
                    cmpx      #$0041
                    lbeq      L150A
L1529               clra
                    clrb
L152B               puls      pc,u
L152D               pshs      u
                    ldd       #$FFB4
                    lbsr      stkcheck
                    ldu       $04,s
                    ldd       $06,u
                    anda      #$80
                    clrb
                    std       -$02,s
                    beq       L1565
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
                    lbsr      L3292
                    leas      $08,s
                    ldd       #$0093
                    std       $06,u
                    clra
                    clrb
                    std       $08,u
L1565               puls      pc,u
L1567               pshs      u
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
                    lbsr      L1EB3
                    std       ,s++
                    lbeq      L15FD
                    ldd       ,s
                    pshs      d
                    lbsr      L149E
                    std       ,s++
                    beq       L159C
                    ldd       ,s
                    pshs      d
                    lbsr      L1C1D
                    bra       L15A3

L159C               ldd       ,s
                    pshs      d
                    lbsr      L0D04
L15A3               leas      $02,s
                    ldx       ,s
                    ldx       $06,x
                    bra       L15F1

L15AB               ldx       ,s
                    ldd       $0a,x
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       $06,u
                    pshs      d
                    ldd       #$007F
                    bra       L15E7

L15BF               ldd       ,s
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3292
                    leas      $08,s
L15D7               ldd       ,s
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       $06,u
                    pshs      d
                    ldd       #$0075
L15E7               pshs      d
                    lbsr      L3292
                    leas      $08,s
                    lbra      L1794

L15F1               cmpx      #$0041
                    beq       L15AB
                    cmpx      #$0085
                    beq       L15BF
                    bra       L15D7

L15FD               pshs      u
                    lbsr      L1440
                    std       ,s++
                    beq       L1635
                    ldd       ,u
                    cmpd      #$0002
                    beq       L1635
                    ldd       ,s
                    pshs      d
                    lbsr      L149E
                    std       ,s++
                    bne       L1624
                    ldd       ,s
                    pshs      d
                    lbsr      L14F2
                    std       ,s++
                    beq       L1635
L1624               pshs      u
                    lbsr      L0D04
                    leas      $02,s
                    ldd       ,s
                    pshs      d
                    lbsr      L1BE4
                    lbra      L16AB

L1635               ldx       ,s
                    ldd       $06,x
                    pshs      d
                    lbsr      L1EB3
                    std       ,s++
                    beq       L165C
                    pshs      u
                    lbsr      L0D04
                    leas      $02,s
                    ldd       ,u
                    cmpd      #$0002
                    lbne      L16AD
                    ldd       ,s
                    pshs      d
                    lbsr      L0BC3
                    bra       L16AB

L165C               pshs      u
                    lbsr      L14DA
                    std       ,s++
                    beq       L1675
                    ldd       ,s
                    pshs      d
                    lbsr      L0BC3
                    leas      $02,s
                    pshs      u
                    lbsr      L0D04
                    bra       L16AB

L1675               pshs      u
                    lbsr      L0D04
                    leas      $02,s
                    ldd       ,s
                    pshs      d
                    lbsr      L1440
                    std       ,s++
                    bne       L16A4
                    ldd       $06,u
                    anda      #$7f
                    tfr       d,x
                    bra       L1698

L168F               pshs      u
                    lbsr      L1904
                    leas      $02,s
                    bra       L16A4

L1698               cmpx      #$0095
                    beq       L16A4
                    cmpx      #$0094
                    beq       L16A4
                    bra       L168F

L16A4               ldd       ,s
                    pshs      d
                    lbsr      L0C2D
L16AB               leas      $02,s
L16AD               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldx       $04,s
                    ldd       $06,x
                    pshs      d
                    ldd       #$0079
                    pshs      d
                    lbsr      L3292
                    leas      $08,s
                    ldx       ,s
                    ldd       $06,x
                    lbra      L1796

L16CB               pshs      u
                    ldd       #$FFB0
                    lbsr      stkcheck
                    leas      -$04,s
                    ldx       $08,s
                    ldd       $0C,x
                    std       $02,s
                    ldx       $08,s
                    ldu       $0a,x
                    pshs      u
                    lbsr      L0D04
                    leas      $02,s
                    ldd       $0a,s
                    addd      #$FFB0
                    std       $0a,s
                    ldd       ,u
                    cmpd      #$0007
                    bne       L1719
                    ldx       $0a,s
                    bra       L170A

L16F9               ldd       #$004E
                    bra       L1706

L16FE               ldd       #$004D
                    bra       L1706

L1703               ldd       #$004C
L1706               std       $0a,s
                    bra       L1719

L170A               cmpx      #$0053
                    beq       L16F9
                    cmpx      #$0055
                    beq       L16FE
                    cmpx      #$0054
                    beq       L1703
L1719               ldd       $06,u
                    anda      #$7f
                    std       ,s
                    pshs      d
                    lbsr      L1EB3
                    std       ,s++
                    lbeq      L17EF
                    ldx       $0a,s
                    lbra      L17CA

L172F               ldx       $02,s
                    ldd       $06,x
                    cmpd      #$0036
                    bne       L1766
                    ldd       $0a,s
                    cmpd      #$0050
                    bne       L1747
                    ldx       $02,s
                    ldd       $08,x
                    bra       L174F

L1747               ldx       $02,s
                    ldd       $08,x
                    nega
                    negb
                    sbca      #$00
L174F               pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    ldd       #$0074
                    pshs      d
                    lbsr      L3292
                    leas      $08,s
                    bra       L1794

L1766               ldd       $02,s
                    pshs      d
                    lbsr      L0BC3
                    leas      $02,s
                    ldd       $0a,s
                    cmpd      #$0051
                    bne       L1781
                    ldd       #$0043
                    pshs      d
                    lbsr      L3292
                    leas      $02,s
L1781               ldd       #$0070
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    ldd       #$0074
                    pshs      d
                    lbsr      L3292
                    leas      $06,s
L1794               ldd       $06,u
L1796               ldx       $08,s
                    std       $06,x
                    clra
                    clrb
                    ldx       $08,s
                    std       $08,x
                    lbra      L1A96

L17A3               leax      $04,s
                    bra       L17ED

L17A7               ldd       $06,u
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3292
                    leas      $04,s
                    ldd       $02,s
                    pshs      d
                    lbsr      L0BC3
                    leas      $02,s
                    ldd       $0a,s
                    pshs      d
                    lbsr      L3292
                    leas      $02,s
                    lbra      L18E4

L17CA               cmpx      #$0050
                    lbeq      L172F
                    cmpx      #$0051
                    lbeq      L172F
                    cmpx      #$0057
                    beq       L17A3
                    cmpx      #$0058
                    lbeq      L17A3
                    cmpx      #$0059
                    lbeq      L17A3
                    bra       L17A7

L17ED               leas      -$04,x
L17EF               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3292
                    leas      $08,s
                    ldd       ,u
                    cmpd      #$0002
                    bne       L1817
                    ldd       #$0085
                    pshs      d
                    lbsr      L3292
                    leas      $02,s
L1817               ldx       $0a,s
                    lbra      L18BE

L181C               ldd       $02,s
                    pshs      d
                    lbsr      L1440
                    std       ,s++
                    beq       L186D
                    ldd       $02,s
                    pshs      d
                    lbsr      L0D04
                    leas      $02,s
                    ldx       $0a,s
                    bra       L183F

L1834               ldd       $02,s
                    pshs      d
                    lbsr      L152D
                    leas      $02,s
                    bra       L1852

L183F               cmpx      #$0057
                    beq       L1834
                    cmpx      #$0058
                    lbeq      L1834
                    cmpx      #$0059
                    lbeq      L1834
L1852               ldd       $02,s
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    lbsr      L3292
                    leas      $08,s
                    lbra      L18E4

L186D               ldd       ,s
                    cmpd      #$0094
                    beq       L1884
                    ldd       ,s
                    cmpd      #$0095
                    beq       L1884
                    pshs      u
                    lbsr      L1904
                    leas      $02,s
L1884               ldd       #$0070
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3292
                    leas      $04,s
                    ldd       $02,s
                    pshs      d
                    lbsr      L0BC3
                    leas      $02,s
                    ldd       $0a,s
                    cmpd      #$0051
                    bne       L18A9
                    ldd       #$004F
                    std       $0a,s
L18A9               ldd       #$006E
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    lbsr      L3292
                    leas      $06,s
                    bra       L18E4

L18BE               cmpx      #$0057
                    lbeq      L181C
                    cmpx      #$0058
                    lbeq      L181C
                    cmpx      #$0059
                    lbeq      L181C
                    cmpx      #$0050
                    lbeq      L181C
                    cmpx      #$0051
                    lbeq      L181C
                    lbra      L186D

L18E4               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0079
                    pshs      d
                    lbsr      L3292
                    leas      $08,s
                    ldd       #$0070
                    ldx       $08,s
                    std       $06,x
                    lbra      L1A96

L1904               pshs      u
                    ldd       #$FFB4
                    lbsr      stkcheck
                    ldu       $04,s
                    ldd       $06,u
                    anda      #$7f
                    cmpd      #$0034
                    bne       L191A
                    puls      pc,u
L191A               pshs      u
                    lbsr      L152D
                    leas      $02,s
                    ldd       $08,u
                    beq       L193D
                    ldd       $08,u
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$0074
                    pshs      d
                    lbsr      L3292
                    leas      $08,s
L193D               ldd       #$0071
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3292
                    leas      $04,s
                    ldd       #$806E
                    std       $06,u
                    puls      pc,u
L1953               pshs      u
                    ldd       #$FFB0
                    lbsr      stkcheck
                    ldu       $04,s
                    leas      -$04,s
                    ldd       $0a,u
                    std       $02,s
                    pshs      d
                    lbsr      L1C1D
                    leas      $02,s
                    ldx       $02,s
                    ldd       $06,x
                    std       ,s
                    anda      #$80
                    clrb
                    std       -$02,s
                    lbeq      L19D7
                    ldd       ,s
                    anda      #$7f
                    std       ,s
                    tfr       d,x
                    bra       L19AF

L1983               ldx       $02,s
                    ldd       $08,x
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3292
                    leas      $08,s
                    bra       L19CB

L199E               leax      L1EEF,pcr
                    pshs      x
                    ldd       $04,s
                    pshs      d
                    lbsr      L484B
                    leas      $04,s
                    bra       L19CB

L19AF               cmpx      #$0034
                    beq       L1983
                    cmpx      #$0093
                    lbeq      L1983
                    cmpx      #$0094
                    lbeq      L1983
                    cmpx      #$0095
                    lbeq      L1983
                    bra       L199E

L19CB               ldd       #$8093
                    std       ,s
                    clra
                    clrb
                    std       $08,u
                    lbra      L1A92

L19D7               ldx       ,s
                    lbra      L1A53

L19DC               ldd       #$0095
                    bra       L19EF

L19E1               ldd       #$0094
                    bra       L19EF

L19E6               ldd       #$0093
                    bra       L19EF

L19EB               ldd       ,s
                    ora       #$80
L19EF               std       ,s
                    leax      $04,s
                    bra       L1A04

L19F5               ldd       #$8034
                    std       ,s
                    ldx       $02,s
                    ldd       $14,x
                    std       $14,u
                    bra       L1A06

L1A04               leas      -$04,x
L1A06               ldx       $02,s
                    ldd       $08,x
                    bra       L1A2B

L1A0C               ldd       $02,s
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3292
                    leas      $08,s
                    ldd       #$0093
                    std       ,s
                    clra
                    clrb
L1A2B               std       $08,u
                    bra       L1A92

L1A2F               clra
                    clrb
                    std       $08,u
                    ldx       $02,s
                    ldd       $08,x
                    std       $14,u
                    ldd       #$0034
                    bra       L1A4F

L1A3F               leax      L1EFB,pcr
                    pshs      x
                    pshs      u
                    lbsr      L484B
                    leas      $04,s
                    ldd       #$0093
L1A4F               std       ,s
                    bra       L1A92

L1A53               cmpx      #$006F
                    lbeq      L19DC
                    cmpx      #$0076
                    lbeq      L19E1
                    cmpx      #$0071
                    lbeq      L19E6
                    cmpx      #$0093
                    lbeq      L19EB
                    cmpx      #$0094
                    lbeq      L19EB
                    cmpx      #$0095
                    lbeq      L19EB
                    cmpx      #$0034
                    lbeq      L19F5
                    cmpx      #$0070
                    lbeq      L1A0C
                    cmpx      #$0036
                    beq       L1A2F
                    bra       L1A3F

L1A92               ldd       ,s
                    std       $06,u
L1A96               leas      $04,s
                    puls      pc,u
L1A9A               pshs      u
                    ldd       #$FFAC
                    lbsr      stkcheck
                    leas      -$08,s
                    ldx       $0C,s
                    ldu       $0a,x
                    pshs      u
                    lbsr      L0D04
                    leas      $02,s
                    ldx       $0C,s
                    ldd       $06,x
                    std       $02,s
                    ldd       $06,u
                    std       ,s
                    pshs      d
                    lbsr      L1EB3
                    std       ,s++
                    beq       L1AFA
                    ldx       $02,s
                    bra       L1AEC

L1AC6               ldd       $0e,s
                    cmpd      #$0070
                    bne       L1AE6
                    pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       $12,s
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3292
                    leas      $08,s
                    bra       L1B2B

L1AE6               ldd       ,s
                    std       $0e,s
                    bra       L1B2B

L1AEC               cmpx      #$003E
                    beq       L1AC6
                    cmpx      #$003F
                    lbeq      L1AC6
                    bra       L1AE6

L1AFA               ldd       $0e,s
                    cmpd      #$0071
                    bne       L1B11
                    ldd       ,s
                    anda      #$7f
                    cmpd      #$0034
                    beq       L1B11
                    ldd       #$0070
                    std       $0e,s
L1B11               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       $12,s
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3292
                    leas      $08,s
                    ldd       $0e,s
                    std       ,s
L1B2B               ldx       $0C,s
                    ldd       $08,x
                    std       $06,s
                    ldx       $02,s
                    bra       L1B70

L1B35               ldd       $06,s
                    nega
                    negb
                    sbca      #$00
                    std       $06,s
L1B3D               ldd       ,s
                    cmpd      #$0070
                    bne       L1B57
                    ldd       $06,s
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    ldd       #$0050
                    bra       L1B67

L1B57               ldd       $06,s
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    ldd       #$0074
L1B67               pshs      d
                    lbsr      L3292
                    leas      $08,s
                    bra       L1B7E

L1B70               cmpx      #$003D
                    beq       L1B35
                    cmpx      #$003F
                    lbeq      L1B35
                    bra       L1B3D

L1B7E               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    ldd       #$0079
                    pshs      d
                    lbsr      L3292
                    leas      $08,s
                    ldx       $02,s
                    bra       L1BC9

L1B97               clra
                    clrb
                    bra       L1BC3

L1B9B               ldd       ,s
                    cmpd      #$0070
                    bne       L1BBD
                    ldd       $06,s
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0051
                    pshs      d
                    lbsr      L3292
                    leas      $08,s
                    bra       L1BD7

L1BBD               ldd       $06,s
                    nega
                    negb
                    sbca      #$00
L1BC3               ldx       $0C,s
                    std       $08,x
                    bra       L1BD7

L1BC9               cmpx      #$003E
                    beq       L1B9B
                    cmpx      #$003F
                    lbeq      L1B9B
                    bra       L1B97

L1BD7               ldd       $0e,s
                    ldx       $0C,s
                    std       $06,x
                    clra
                    clrb
                    std       L0019
                    lbra      L1EAF

L1BE4               pshs      u
                    ldd       #$FFB4
                    lbsr      stkcheck
                    ldu       $04,s
                    pshs      u
                    bsr       L1C1D
                    leas      $02,s
                    ldd       $06,u
                    cmpd      #$0071
                    bne       L1C00
                    ldd       $08,u
                    beq       L1C16
L1C00               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3292
                    leas      $08,s
L1C16               ldd       #$0071
                    std       $06,u
                    puls      pc,u
L1C1D               pshs      u
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
                    lbra      L1E4F

L1C41               ldd       $0C,s
                    pshs      d
                    lbsr      L1953
                    lbra      L1E4B

L1C4B               ldd       #$0071
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    lbsr      L1A9A
                    leas      $04,s
                    lbra      L1EAF

L1C5C               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$007F
                    pshs      d
                    lbsr      L3292
                    leas      $08,s
                    clra
                    clrb
                    lbra      L1E3C

L1C77               ldd       $0C,s
                    pshs      d
                    lbsr      L0BC3
                    lbra      L1E4B

L1C81               ldd       $06,u
                    cmpd      #$0041
                    beq       L1C92
                    ldx       $06,s
                    ldd       $12,x
                    lbne      L1D30
L1C92               ldd       $06,u
                    pshs      d
                    lbsr      L1EB3
                    std       ,s++
                    bne       L1CA5
                    ldd       $06,u
                    cmpd      #$0041
                    bne       L1CF9
L1CA5               ldx       $06,s
                    ldd       $06,x
                    cmpd      #$0036
                    bne       L1CC1
                    pshs      u
                    lbsr      L1C1D
                    leas      $02,s
                    ldd       $06,u
                    std       ,s
                    ldx       $06,s
                    ldd       $08,x
                    lbra      L1E26

L1CC1               ldd       $06,s
                    pshs      d
                    lbsr      L0BC3
                    leas      $02,s
                    pshs      u
                    lbsr      L1C1D
                    leas      $02,s
                    ldd       $02,s
                    cmpd      #$0051
                    bne       L1CE3
                    ldd       #$0043
                    pshs      d
                    lbsr      L3292
                    leas      $02,s
L1CE3               ldd       $06,u
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$007B
                    pshs      d
                    lbsr      L3292
                    leas      $06,s
                    lbra      L1E24

L1CF9               ldd       $02,s
                    cmpd      #$0050
                    bne       L1D18
                    ldd       $12,u
                    ldx       $06,s
                    cmpd      $12,x
                    bge       L1D18
                    leas      -$02,s
                    stu       ,s
                    ldu       $08,s
                    ldd       ,s
                    std       $08,s
                    leas      $02,s
L1D18               ldd       $06,s
                    pshs      d
                    lbsr      L1440
                    std       ,s++
                    bne       L1D35
                    ldx       $06,s
                    ldd       $06,x
                    pshs      d
                    lbsr      L1EB3
                    std       ,s++
                    bne       L1D35
L1D30               leax      $08,s
                    lbra      L1E42

L1D35               pshs      u
                    lbsr      L1C1D
                    leas      $02,s
                    ldd       $06,u
                    anda      #$7f
                    tfr       d,x
                    lbra      L1D9A

L1D45               ldd       $02,s
                    cmpd      #$0050
                    bne       L1D69
                    ldx       $06,s
                    ldd       $06,x
                    cmpd      #$0036
                    beq       L1D69
                    ldd       $06,s
                    pshs      d
                    lbsr      L0BF7
                    leas      $02,s
                    clra
                    clrb
                    std       $08,u
                    leax      $08,s
                    lbra      L1E0A

L1D69               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3292
                    leas      $08,s
                    clra
                    clrb
                    std       $08,u
                    bra       L1DD5

L1D85               ldd       $06,u
                    std       ,s
                    bra       L1DD5

L1D8B               leax      L1F07,pcr
                    pshs      x
                    pshs      u
                    lbsr      L484B
                    leas      $04,s
                    bra       L1DD5

L1D9A               cmpx      #$0070
                    lbeq      L1D45
                    cmpx      #$0034
                    beq       L1D69
                    cmpx      #$0037
                    lbeq      L1D69
                    cmpx      #$0093
                    lbeq      L1D69
                    cmpx      #$0094
                    lbeq      L1D69
                    cmpx      #$0095
                    lbeq      L1D69
                    cmpx      #$0071
                    beq       L1DD5
                    cmpx      #$0076
                    beq       L1D85
                    cmpx      #$006F
                    lbeq      L1D85
                    bra       L1D8B

L1DD5               ldx       $06,s
                    ldd       $06,x
                    cmpd      #$0036
                    bne       L1DE5
                    ldx       $06,s
                    ldd       $08,x
                    bra       L1E26

L1DE5               ldd       $06,s
                    pshs      d
                    lbsr      L0BC3
                    leas      $02,s
                    ldd       $02,s
                    cmpd      #$0051
                    bne       L1E0C
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    ldd       #$0043
                    pshs      d
                    lbsr      L3292
                    leas      $06,s
                    bra       L1E0C

L1E0A               leas      -$08,x
L1E0C               ldd       ,s
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$007B
                    pshs      d
                    lbsr      L3292
                    leas      $06,s
                    ldd       #$0071
                    std       ,s
L1E24               clra
                    clrb
L1E26               std       $04,s
                    ldd       $02,s
                    cmpd      #$0050
                    bne       L1E34
                    ldd       $04,s
                    bra       L1E3A

L1E34               ldd       $04,s
                    nega
                    negb
                    sbca      #$00
L1E3A               addd      $08,u
L1E3C               ldx       $0C,s
                    std       $08,x
                    bra       L1EA9

L1E42               leas      -$08,x
L1E44               ldd       $0C,s
                    pshs      d
                    lbsr      L0D04
L1E4B               leas      $02,s
                    bra       L1EAF

L1E4F               cmpx      #$0042
                    lbeq      L1C41
                    cmpx      #$0034
                    beq       L1EAF
                    cmpx      #$0076
                    beq       L1EAF
                    cmpx      #$006F
                    beq       L1EAF
                    cmpx      #$0036
                    beq       L1EAF
                    cmpx      #$0037
                    beq       L1EAF
                    cmpx      #$003E
                    lbeq      L1C4B
                    cmpx      #$003C
                    lbeq      L1C4B
                    cmpx      #$003D
                    lbeq      L1C4B
                    cmpx      #$003F
                    lbeq      L1C4B
                    cmpx      #$0041
                    lbeq      L1C5C
                    cmpx      #$0085
                    lbeq      L1C77
                    cmpx      #$0051
                    lbeq      L1C81
                    cmpx      #$0050
                    lbeq      L1C92
                    bra       L1E44

L1EA9               ldd       ,s
                    ldx       $0C,s
                    std       $06,x
L1EAF               leas      $08,s
                    puls      pc,u
L1EB3               pshs      u
                    ldd       #$FFC0
                    lbsr      stkcheck
                    ldd       $04,s
                    cmpd      #$006F
                    beq       L1ECB
                    ldd       $04,s
                    cmpd      #$0076
                    bne       L1ED0
L1ECB               ldd       #$0001
                    bra       L1ED2

L1ED0               clra
                    clrb
L1ED2               puls      pc,u
L1ED4               fcc       /translation/
                    fcb       $00
L1EE0               fcb       $25,$78
                    fcb       $0D,$00
L1EE4               fcc       /binary op./
                    fcb       $00
L1EEF               fcc       /indirection/
                    fcb       $00
L1EFB               fcc       /indirection/
                    fcb       $00
L1F07               fcc       /x translate/
                    fcb       $00
L1F13               pshs      u
                    ldd       #$FFAE
                    lbsr      stkcheck
                    ldu       $04,s
                    leas      -$04,s
                    ldd       $06,u
                    std       $02,s
                    tfr       d,x
                    lbra      L206F

L1F28               ldd       #$0001
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
                    bsr       L1F13
                    leas      $08,s
                    leax      $04,s
                    bra       L1F66

L1F48               clra
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
                    lbsr      L1F13
                    leas      $08,s
                    bra       L1F68

L1F66               leas      -$04,x
L1F68               ldd       ,s
                    pshs      d
                    lbsr      L4414
                    lbra      L1FD2

L1F72               ldd       #$0001
                    subd      $0e,s
                    pshs      d
                    ldd       $0C,s
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    ldd       $0a,u
                    lbra      L1FE2

L1F87               ldd       $0e,s
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    pshs      u
                    ldd       $0a,s
                    pshs      d
                    lbsr      L20ED
                    leas      $0a,s
                    lbra      L20E9

L1FA1               ldd       $08,u
                    beq       L1FB1
                    ldd       $0e,s
                    bne       L1FB1
                    clra
                    clrb
                    pshs      d
                    ldd       $0C,s
                    bra       L1FC3

L1FB1               ldd       $0e,s
                    lbeq      L20E9
                    ldd       $08,u
                    lbne      L20E9
                    clra
                    clrb
                    pshs      d
                    ldd       $0e,s
L1FC3               pshs      d
                    ldd       #$007C
                    lbra      L2066

L1FCB               ldd       $0a,u
                    pshs      d
                    lbsr      L0D04
L1FD2               leas      $02,s
                    ldd       $0e,s
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    ldd       $0C,u
L1FE2               pshs      d
                    lbsr      L1F13
                    leas      $08,s
                    lbra      L20E9

L1FEC               ldd       ,u
                    cmpd      #$0008
                    bne       L200C
                    pshs      u
                    lbsr      L2505
                    leas      $02,s
                    ldd       #$008B
                    pshs      d
L2000               ldd       #$0088
                    pshs      d
                    lbsr      L3292
                    leas      $04,s
                    bra       L204D

L200C               ldd       ,u
                    cmpd      #$0005
                    beq       L201C
                    ldd       ,u
                    cmpd      #$0006
                    bne       L2042
L201C               ldd       $06,u
                    cmpd      #$008C
                    bne       L2026
                    ldu       $0a,u
L2026               pshs      u
                    lbsr      L29FC
                    leas      $02,s
                    ldd       ,u
                    pshs      d
                    ldd       #$008B
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L3292
                    leas      $06,s
                    bra       L204D

L2042               pshs      u
                    lbsr      L2323
                    leas      $02,s
                    bra       L204D
                    leas      -$04,x
L204D               ldd       $0e,s
                    beq       L205A
                    ldd       $0C,s
                    pshs      d
                    ldd       #$005A
                    bra       L2061

L205A               ldd       $0a,s
                    pshs      d
                    ldd       #$005B
L2061               pshs      d
                    ldd       #$0082
L2066               pshs      d
                    lbsr      L3292
                    leas      $06,s
                    bra       L20E9

L206F               cmpx      #$0047
                    lbeq      L1F28
                    cmpx      #$0048
                    lbeq      L1F48
                    cmpx      #$0040
                    lbeq      L1F72
                    cmpx      #$005A
                    lbeq      L1F87
                    cmpx      #$005B
                    lbeq      L1F87
                    cmpx      #$005C
                    lbeq      L1F87
                    cmpx      #$005D
                    lbeq      L1F87
                    cmpx      #$005E
                    lbeq      L1F87
                    cmpx      #$005F
                    lbeq      L1F87
                    cmpx      #$0060
                    lbeq      L1F87
                    cmpx      #$0061
                    lbeq      L1F87
                    cmpx      #$0062
                    lbeq      L1F87
                    cmpx      #$0063
                    lbeq      L1F87
                    cmpx      #$0036
                    lbeq      L1FA1
                    cmpx      #$004B
                    lbeq      L1FA1
                    cmpx      #$004A
                    lbeq      L1FA1
                    cmpx      #$0030
                    lbeq      L1FCB
                    lbra      L1FEC

L20E9               leas      $04,s
                    puls      pc,u
L20ED               pshs      u
                    ldd       #$FFAE
                    lbsr      stkcheck
                    leas      -$06,s
                    ldx       $0C,s
                    ldd       $0a,x
                    std       ,s
                    ldx       $0C,s
                    ldu       $0C,x
                    ldd       $12,s
                    beq       L210B
                    ldd       $10,s
                    bra       L210D

L210B               ldd       $0e,s
L210D               std       $02,s
                    ldd       $12,s
                    beq       L211F
                    ldd       $0a,s
                    pshs      d
                    lbsr      L2466
                    leas      $02,s
                    bra       L2121

L211F               ldd       $0a,s
L2121               std       $0a,s
                    ldd       [,s]
                    cmpd      #$0008
                    bne       L2134
                    ldd       $0C,s
                    pshs      d
                    lbsr      L2520
                    bra       L214B

L2134               ldd       [,s]
                    cmpd      #$0005
                    beq       L2144
                    ldd       [,s]
                    cmpd      #$0006
                    bne       L2152
L2144               ldd       $0C,s
                    pshs      d
                    lbsr      L2A17
L214B               leas      $02,s
                    leax      $06,s
                    lbra      L22B2

L2152               ldd       ,s
                    pshs      d
                    lbsr      L24E6
                    std       ,s++
                    bne       L2189
                    ldd       ,s
                    pshs      d
                    lbsr      L22CA
                    std       ,s++
                    beq       L2171
                    pshs      u
                    lbsr      L22CA
                    std       ,s++
                    beq       L2189
L2171               ldd       $06,u
                    pshs      d
                    lbsr      L1EB3
                    std       ,s++
                    beq       L219C
                    ldx       ,s
                    ldd       $06,x
                    pshs      d
                    lbsr      L1EB3
                    std       ,s++
                    bne       L219C
L2189               ldd       ,s
                    std       $04,s
                    stu       ,s
                    ldu       $04,s
                    ldd       $0a,s
                    pshs      d
                    lbsr      L249E
                    leas      $02,s
                    std       $0a,s
L219C               ldx       ,s
                    ldd       $06,x
                    std       $04,s
                    pshs      d
                    lbsr      L1EB3
                    std       ,s++
                    lbeq      L221F
                    pshs      u
                    lbsr      L0D04
                    leas      $02,s
                    ldx       $06,u
                    bra       L21F8

L21B8               pshs      u
                    lbsr      L0C2D
                    leas      $02,s
                    leax      $06,s
                    bra       L21E0

L21C3               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3292
                    leas      $08,s
                    ldd       #$0070
                    std       $06,u
                    bra       L21E2

L21E0               leas      -$06,x
L21E2               ldd       $06,u
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3292
                    leas      $04,s
                    ldd       #$006E
                    std       $06,u
                    lbra      L229B

L21F8               cmpx      #$0041
                    beq       L21B8
                    cmpx      #$0085
                    beq       L21C3
                    cmpx      #$0071
                    beq       L21E2
                    cmpx      #$0076
                    lbeq      L21E2
                    cmpx      #$006F
                    lbeq      L21E2
                    cmpx      #$0070
                    lbeq      L21E2
                    lbra      L229B

L221F               pshs      u
                    lbsr      L24E6
                    std       ,s++
                    beq       L223C
                    ldd       $0a,s
                    cmpd      #$0060
                    bge       L223C
                    ldd       ,s
                    pshs      d
                    lbsr      L2323
                    leas      $02,s
                    lbra      L22B4

L223C               ldd       ,s
                    pshs      d
                    lbsr      L0C2D
                    leas      $02,s
                    ldx       ,s
                    ldd       $06,x
                    std       $04,s
                    pshs      u
                    lbsr      L1440
                    std       ,s++
                    bne       L2265
                    ldd       $04,s
                    cmpd      #$0070
                    bne       L226E
                    pshs      u
                    lbsr      L22CA
                    std       ,s++
                    beq       L226E
L2265               pshs      u
                    lbsr      L0D04
                    leas      $02,s
                    bra       L229B

L226E               ldd       $04,s
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3292
                    leas      $04,s
                    ldd       #$006E
                    ldx       ,s
                    std       $06,x
                    pshs      u
                    lbsr      L0C2D
                    leas      $02,s
                    ldd       $06,u
                    std       $04,s
                    ldu       ,s
                    ldd       $0a,s
                    pshs      d
                    lbsr      L249E
                    leas      $02,s
                    std       $0a,s
L229B               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       #$0081
                    pshs      d
                    lbsr      L3292
                    leas      $08,s
                    bra       L22B4

L22B2               leas      -$06,x
L22B4               ldd       $02,s
                    pshs      d
                    ldd       $0C,s
                    pshs      d
                    ldd       #$0082
                    pshs      d
                    lbsr      L3292
                    leas      $06,s
                    leas      $06,s
                    puls      pc,u
L22CA               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    ldx       $04,s
                    ldx       $06,x
                    bra       L22E8

L22D8               ldd       #$0001
                    puls      pc,u
L22DD               ldd       $04,s
                    pshs      d
                    lbsr      L14DA
                    leas      $02,s
                    puls      pc,u
L22E8               cmpx      #$0034
                    beq       L22D8
                    cmpx      #$0036
                    lbeq      L22D8
                    cmpx      #$0042
                    beq       L22DD
                    lbra      L2501
                    pshs      u
                    ldd       #$FFC0
                    lbsr      stkcheck
                    ldx       $04,s
                    ldd       $06,x
                    cmpd      #$0034
                    lbne      L2501
                    ldx       $04,s
                    ldd       [$08,x]
                    cmpd      #$000D
                    lbne      L2501
                    ldd       #$0001
                    lbra      L2503

L2323               pshs      u
                    ldd       #$FFB0
                    lbsr      stkcheck
                    ldu       $04,s
                    leas      -$04,s
                    clra
                    clrb
                    std       ,s
                    ldx       $06,u
                    bra       L2388

L2337               ldd       $0C,u
                    std       $02,s
                    tfr       d,x
                    ldd       $06,x
                    cmpd      #$0036
                    bne       L2380
                    ldx       $02,s
                    ldd       $08,x
                    cmpd      #$00FF
                    lbls      L23FE
                    bra       L2380

L2353               ldx       $0a,u
                    ldd       $06,x
                    pshs      d
                    lbsr      L1EB3
                    std       ,s++
                    lbeq      L23FE
                    ldd       $0C,u
                    pshs      d
                    lbsr      L22CA
                    std       ,s++
                    lbne      L23FE
                    bra       L2380

L2371               ldx       $0a,u
                    ldd       $06,x
                    pshs      d
                    lbsr      L1EB3
                    std       ,s++
                    lbeq      L23FE
L2380               ldd       #$0001
                    std       ,s
                    lbra      L23FE

L2388               cmpx      #$0057
                    beq       L2337
                    cmpx      #$0078
                    beq       L2353
                    cmpx      #$003E
                    beq       L2371
                    cmpx      #$003F
                    lbeq      L2371
                    cmpx      #$003D
                    lbeq      L2371
                    cmpx      #$003C
                    lbeq      L2371
                    cmpx      #$00A0
                    lbeq      L2371
                    cmpx      #$00A1
                    lbeq      L2371
                    cmpx      #$00A7
                    lbeq      L2371
                    cmpx      #$00A8
                    lbeq      L2371
                    cmpx      #$00A9
                    lbeq      L2371
                    cmpx      #$0076
                    beq       L2380
                    cmpx      #$006F
                    lbeq      L2380
                    cmpx      #$0058
                    lbeq      L2380
                    cmpx      #$0059
                    lbeq      L2380
                    cmpx      #$0044
                    lbeq      L2380
                    cmpx      #$0043
                    lbeq      L2380
                    cmpx      #$0065
                    lbeq      L2380
L23FE               clra
                    clrb
L2400               std       L0019
                    pshs      u
                    lbsr      L0D04
                    leas      $02,s
                    ldx       $06,u
                    bra       L2441

L240D               ldd       ,s
                    bne       L2415
                    ldd       L0019
                    beq       L2462
L2415               clra
                    clrb
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       $06,u
                    pshs      d
                    ldd       #$0081
                    bra       L2438

L2427               ldu       $0a,u
L2429               pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
L2438               pshs      d
                    lbsr      L3292
                    leas      $08,s
                    bra       L2462

L2441               cmpx      #$0071
                    beq       L240D
                    cmpx      #$0070
                    lbeq      L240D
                    cmpx      #$0076
                    lbeq      L240D
                    cmpx      #$006F
                    lbeq      L240D
                    cmpx      #$0085
                    beq       L2427
                    bra       L2429

L2462               leas      $04,s
                    puls      pc,u
L2466               pshs      u
                    ldd       #$FFC0
                    lbsr      stkcheck
                    ldx       $04,s
                    bra       L2490

L2472               ldd       #$005B
                    puls      pc,u
L2477               ldd       #$005A
                    puls      pc,u
L247C               ldd       $04,s
                    cmpd      #$005F
                    ble       L2489
                    ldd       #$00C3
                    bra       L248C

L2489               ldd       #$00BB
L248C               subd      $04,s
                    puls      pc,u
L2490               cmpx      #$005A
                    beq       L2472
                    cmpx      #$005B
                    beq       L2477
                    bra       L247C
                    puls      pc,u
L249E               pshs      u
                    ldd       #$FFC0
                    lbsr      stkcheck
                    ldx       $04,s
                    bra       L24BC

L24AA               ldd       $04,s
                    puls      pc,u
L24AE               ldd       $04,s
                    addd      #$0002
                    puls      pc,u
L24B5               ldd       $04,s
                    addd      #$FFFE
                    puls      pc,u
L24BC               cmpx      #$005A
                    beq       L24AA
                    cmpx      #$005B
                    lbeq      L24AA
                    cmpx      #$005C
                    beq       L24AE
                    cmpx      #$005D
                    lbeq      L24AE
                    cmpx      #$0060
                    lbeq      L24AE
                    cmpx      #$0061
                    lbeq      L24AE
                    bra       L24B5
                    puls      pc,u
L24E6               pshs      u
                    ldd       #$FFC0
                    lbsr      stkcheck
                    ldu       $04,s
                    ldd       $06,u
                    cmpd      #$0036
                    bne       L2501
                    ldd       $08,u
                    bne       L2501
                    ldd       #$0001
                    bra       L2503

L2501               clra
                    clrb
L2503               puls      pc,u
L2505               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    ldd       $04,s
                    pshs      d
                    bsr       L2520
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L28FB
                    leas      $02,s
                    puls      pc,u
L2520               pshs      u
                    ldd       #$FFAE
                    lbsr      stkcheck
                    ldu       $04,s
                    leas      -$06,s
                    ldd       $06,u
                    std       $02,s
                    tfr       d,x
                    lbra      L27FF

L2535               pshs      u
                    lbsr      L1953
                    leas      $02,s
                    pshs      u
                    lbsr      L152D
                    leas      $02,s
                    ldx       $06,u
                    bra       L2561

L2547               ldd       $08,u
                    lbeq      L28F7
                    pshs      u
                    ldd       #$0077
                    pshs      d
                    ldd       #$007B
                    pshs      d
                    lbsr      L3292
                    leas      $06,s
                    lbra      L27D6

L2561               cmpx      #$0093
                    beq       L2547
                    cmpx      #$0094
                    lbeq      L2547
                    cmpx      #$0095
                    lbeq      L2547
                    lbra      L28F7

L2577               ldd       $0a,u
                    pshs      d
                    lbsr      L0BC3
                    leas      $02,s
                    ldd       #$0086
                    lbra      L2758

L2586               ldd       $0a,u
                    pshs      d
                    lbsr      L29FC
                    leas      $02,s
                    ldd       $0a,u
                    pshs      d
                    ldd       #$0091
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L3292
                    leas      $06,s
                    lbra      L2764

L25A5               ldd       $0a,u
                    pshs      d
                    lbsr      L0BC3
                    leas      $02,s
                    ldd       #$0083
                    pshs      d
                    ldd       #$0088
                    pshs      d
                    lbsr      L3292
                    leas      $04,s
                    bra       L25C1

L25BF               leas      -$06,x
L25C1               ldd       #$0080
                    std       $06,u
                    lbra      L28F7

L25C9               ldd       $08,u
                    pshs      d
                    ldd       #$004A
                    pshs      d
                    ldd       #$0088
                    pshs      d
                    lbsr      L3292
                    leas      $06,s
                    ldd       #$0004
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L3203
                    bra       L260C

L25EA               leax      L2505,pcr
                    pshs      x
                    pshs      u
                    lbsr      L12E8
                    bra       L260C

L25F7               ldd       $0a,u
                    pshs      d
                    lbsr      L2505
                    leas      $02,s
                    ldd       $02,s
                    pshs      d
                    ldd       #$0088
                    pshs      d
                    lbsr      L3292
L260C               leas      $04,s
                    leax      $06,s
                    lbra      L27D4

L2613               clra
                    clrb
                    pshs      d
                    ldd       #$0080
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$007F
                    pshs      d
                    lbsr      L3292
                    leas      $08,s
                    ldd       #$0071
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3292
                    leas      $04,s
                    ldd       $0a,u
                    pshs      d
                    lbsr      L2505
                    leas      $02,s
                    ldd       $02,s
                    pshs      d
                    ldd       #$0088
                    pshs      d
                    lbsr      L3292
                    leas      $04,s
                    ldd       #$0089
                    pshs      d
                    ldd       #$0088
                    pshs      d
                    lbsr      L3292
                    leas      $04,s
                    ldd       $02,s
                    cmpd      #$003E
                    bne       L266E
                    ldd       #$003F
                    lbra      L2758

L266E               ldd       #$003E
                    lbra      L2758

L2674               pshs      u
                    lbsr      L1364
                    leas      $02,s
                    lbra      L2764

L267E               ldx       $0a,u
                    ldd       $06,x
                    cmpd      #$004A
                    bne       L2698
                    leas      -$02,s
                    ldd       $0a,u
                    std       ,s
                    ldd       $0C,u
                    std       $0a,u
                    ldd       ,s
                    std       $0C,u
                    leas      $02,s
L2698               ldx       $0C,u
                    ldd       $06,x
                    cmpd      #$004A
                    lbne      L26F9
                    ldx       $0C,u
                    ldd       $08,x
                    std       $04,s
                    ldd       [$04,s]
                    bne       L26F9
                    ldx       $04,s
                    ldd       $02,x
                    pshs      d
                    lbsr      L121F
                    leas      $02,s
                    std       ,s
                    beq       L26F9
                    ldd       #$0004
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L3203
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
                    bne       L26F0
                    ldd       #$0056
                    bra       L26F3

L26F0               ldd       #$0055
L26F3               std       $02,s
                    leax      $06,s
                    bra       L2733

L26F9               ldd       $0a,u
                    std       $04,s
                    ldx       $04,s
                    ldd       $06,x
                    cmpd      #$004A
                    bne       L2712
                    ldd       $04,s
                    pshs      d
                    lbsr      L294B
                    leas      $02,s
                    bra       L272A

L2712               ldd       $04,s
                    pshs      d
                    lbsr      L2505
                    leas      $02,s
                    ldd       #$006E
                    pshs      d
                    ldd       #$0088
                    pshs      d
                    lbsr      L3292
                    leas      $04,s
L272A               ldd       $0C,u
                    pshs      d
                    lbsr      L2505
                    bra       L2754

L2733               leas      -$06,x
L2735               ldd       $0a,u
                    pshs      d
                    lbsr      L2505
                    leas      $02,s
                    ldd       #$0071
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3292
                    leas      $04,s
                    ldd       $0C,u
                    pshs      d
                    lbsr      L0BC3
L2754               leas      $02,s
                    ldd       $02,s
L2758               pshs      d
                    ldd       #$0088
                    pshs      d
                    lbsr      L3292
                    leas      $04,s
L2764               leax      $06,s
                    lbra      L25BF

L2769               ldd       $0a,u
                    pshs      d
                    lbsr      L2505
                    leas      $02,s
                    ldd       #$0071
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3292
                    leas      $04,s
                    ldd       $0C,u
                    pshs      d
                    lbsr      L2505
                    leas      $02,s
                    leax      $06,s
                    bra       L27C1

L278E               leas      -$06,x
                    ldd       $0a,u
                    std       $04,s
                    pshs      d
                    lbsr      L2505
                    leas      $02,s
                    ldd       #$0071
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3292
                    leas      $04,s
                    ldd       $02,s
                    addd      #$FFB0
                    std       $06,u
                    ldd       #$0093
                    ldx       $04,s
                    std       $06,x
                    pshs      u
                    lbsr      L2520
                    leas      $02,s
                    bra       L27C3

L27C1               leas      -$06,x
L27C3               ldd       #$0089
                    pshs      d
                    ldd       #$0088
                    pshs      d
                    lbsr      L3292
                    leas      $04,s
                    bra       L27D6

L27D4               leas      -$06,x
L27D6               ldd       #$0093
                    std       $06,u
                    clra
                    clrb
                    std       $08,u
                    lbra      L28F7

L27E2               ldd       $02,s
                    cmpd      #$00A0
                    blt       L27EF
                    leax      $06,s
                    lbra      L278E

L27EF               leax      L29F6,pcr
                    pshs      x
                    pshs      u
                    lbsr      L484B
                    leas      $04,s
                    lbra      L28F7

L27FF               cmpx      #$0080
                    lbeq      L28F7
                    cmpx      #$0093
                    lbeq      L28F7
                    cmpx      #$0094
                    lbeq      L28F7
                    cmpx      #$0095
                    lbeq      L28F7
                    cmpx      #$0034
                    lbeq      L28F7
                    cmpx      #$0042
                    lbeq      L2535
                    cmpx      #$0086
                    lbeq      L2577
                    cmpx      #$0091
                    lbeq      L2586
                    cmpx      #$0083
                    lbeq      L25A5
                    cmpx      #$004A
                    lbeq      L25C9
                    cmpx      #$0064
                    lbeq      L25EA
                    cmpx      #$003C
                    lbeq      L25F7
                    cmpx      #$003D
                    lbeq      L25F7
                    cmpx      #$0044
                    lbeq      L25F7
                    cmpx      #$0043
                    lbeq      L25F7
                    cmpx      #$003E
                    lbeq      L2613
                    cmpx      #$003F
                    lbeq      L2613
                    cmpx      #$0065
                    lbeq      L2674
                    cmpx      #$0052
                    lbeq      L267E
                    cmpx      #$0053
                    lbeq      L26F9
                    cmpx      #$005A
                    lbeq      L26F9
                    cmpx      #$005B
                    lbeq      L26F9
                    cmpx      #$005E
                    lbeq      L26F9
                    cmpx      #$005C
                    lbeq      L26F9
                    cmpx      #$005F
                    lbeq      L26F9
                    cmpx      #$005D
                    lbeq      L26F9
                    cmpx      #$0050
                    lbeq      L26F9
                    cmpx      #$0051
                    lbeq      L26F9
                    cmpx      #$0054
                    lbeq      L26F9
                    cmpx      #$0057
                    lbeq      L26F9
                    cmpx      #$0058
                    lbeq      L26F9
                    cmpx      #$0059
                    lbeq      L26F9
                    cmpx      #$0056
                    lbeq      L2735
                    cmpx      #$0055
                    lbeq      L2735
                    cmpx      #$0078
                    lbeq      L2769
                    lbra      L27E2

L28F7               leas      $06,s
                    puls      pc,u
L28FB               pshs      u
                    ldd       #$FFB4
                    lbsr      stkcheck
                    ldx       $04,s
                    ldx       $06,x
                    bra       L2938

L2909               ldd       $04,s
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$007F
                    pshs      d
                    lbsr      L3292
                    leas      $08,s
                    bra       L2949

L2923               ldd       $04,s
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       #$007B
                    pshs      d
                    lbsr      L3292
                    leas      $06,s
                    bra       L2949

L2938               cmpx      #$0034
                    beq       L2909
                    cmpx      #$0094
                    beq       L2923
                    cmpx      #$0095
                    lbeq      L2923
L2949               puls      pc,u
L294B               pshs      u
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
                    beq       L29AA
                    ldx       ,s
                    ldd       $02,x
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3292
                    leas      $08,s
                    ldd       #$0070
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3292
                    leas      $04,s
                    ldd       [,s]
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3292
                    leas      $08,s
                    bra       L29D1

L29AA               clra
                    clrb
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3292
                    leas      $08,s
                    ldd       #$0070
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3292
                    leas      $04,s
L29D1               ldd       #$0070
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3292
                    leas      $04,s
                    ldd       #$0004
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    lbsr      L3203
                    leas      $04,s
                    clra
                    clrb
                    std       $08,u
                    leas      $02,s
                    puls      pc,u
L29F6               fcc       /longs/
                    fcb       $00
L29FC               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    ldd       $04,s
                    pshs      d
                    bsr       L2A17
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L28FB
                    leas      $02,s
                    puls      pc,u
L2A17               pshs      u
                    ldd       #$FFAE
                    lbsr      stkcheck
                    ldu       $04,s
                    leas      -$08,s
                    ldd       ,u
                    std       $02,s
                    ldd       $06,u
                    std       $06,s
                    tfr       d,x
                    lbra      L2C5F

L2A30               pshs      u
                    lbsr      L2520
                    leas      $02,s
                    lbra      L2D34

L2A3A               ldd       $0a,u
                    pshs      d
                    lbsr      L0BC3
                    leas      $02,s
                    bra       L2A47

L2A45               leas      -$08,x
L2A47               ldd       $06,s
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L3292
                    leas      $04,s
                    bra       L2A59

L2A57               leas      -$08,x
L2A59               ldd       #$0080
                    std       $06,u
                    lbra      L2D34

L2A61               ldd       $0a,u
                    pshs      d
                    lbsr      L2505
                    bra       L2A71

L2A6A               ldd       $0a,u
                    pshs      d
                    lbsr      L29FC
L2A71               leas      $02,s
                    leax      $08,s
                    bra       L2A45

L2A77               ldd       $08,u
                    pshs      d
                    ldd       #$004B
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L3292
                    leas      $06,s
                    ldd       #$0093
                    std       $06,u
                    ldd       #$0008
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L3203
                    leas      $04,s
                    lbra      L2C3B

L2AA0               leax      L29FC,pcr
                    pshs      x
                    pshs      u
                    lbsr      L12E8
                    leas      $04,s
                    bra       L2ACA

L2AAF               ldd       $0a,u
                    pshs      d
                    lbsr      L29FC
                    leas      $02,s
                    ldd       $02,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L3292
                    leas      $06,s
L2ACA               leax      $08,s
                    lbra      L2C34

L2ACF               ldd       #$0080
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$007F
                    pshs      d
                    lbsr      L3292
                    leas      $06,s
                    ldd       #$0071
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3292
                    leas      $04,s
                    ldd       $0a,u
                    pshs      d
                    lbsr      L29FC
                    leas      $02,s
                    ldd       $02,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L3292
                    leas      $06,s
                    ldd       $02,s
                    pshs      d
                    ldd       #$0089
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L3292
                    leas      $06,s
                    ldd       $02,s
                    pshs      d
                    ldd       $08,s
                    cmpd      #$003E
                    bne       L2B31
                    ldd       #$003F
                    bra       L2B34

L2B31               ldd       #$003E
L2B34               pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L3292
                    leas      $06,s
                    bra       L2B7A

L2B42               pshs      u
                    lbsr      L1364
                    leas      $02,s
                    bra       L2B7A

L2B4B               ldd       $0a,u
                    pshs      d
                    lbsr      L29FC
                    leas      $02,s
                    ldd       #$006E
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L3292
                    leas      $04,s
                    ldd       $0C,u
                    pshs      d
                    lbsr      L29FC
                    leas      $02,s
                    ldd       $06,s
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L3292
                    leas      $04,s
L2B7A               leax      $08,s
                    lbra      L2A57

L2B7F               ldd       $0a,u
                    pshs      d
                    lbsr      L29FC
                    leas      $02,s
                    ldd       #$0071
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3292
                    leas      $04,s
                    ldd       $0C,u
                    pshs      d
                    lbsr      L29FC
                    leas      $02,s
                    leax      $08,s
                    lbra      L2C1D

L2BA5               leas      -$08,x
                    ldd       $0a,u
                    std       $04,s
                    ldd       $02,s
                    cmpd      #$0005
                    bne       L2BD7
                    ldx       $04,s
                    ldd       $0a,x
                    pshs      d
                    lbsr      L29FC
                    leas      $02,s
                    ldd       #$0071
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3292
                    leas      $04,s
                    ldd       #$008C
                    pshs      d
                    ldd       #$0087
                    bra       L2BE8

L2BD7               ldd       $04,s
                    pshs      d
                    lbsr      L29FC
                    leas      $02,s
                    ldd       #$0071
                    pshs      d
                    ldd       #$007A
L2BE8               pshs      d
                    lbsr      L3292
                    leas      $04,s
                    ldd       $06,s
                    addd      #$FFB0
                    std       $06,u
                    ldd       #$0093
                    ldx       $04,s
                    std       $06,x
                    pshs      u
                    lbsr      L2A17
                    leas      $02,s
                    ldd       $02,s
                    cmpd      #$0005
                    bne       L2C1F
                    ldd       #$008D
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L3292
                    leas      $04,s
                    bra       L2C1F

L2C1D               leas      -$08,x
L2C1F               ldd       $02,s
                    pshs      d
                    ldd       #$0089
                    pshs      d
                    ldd       #$0087
                    pshs      d
                    lbsr      L3292
                    leas      $06,s
                    bra       L2C36

L2C34               leas      -$08,x
L2C36               ldd       #$0093
                    std       $06,u
L2C3B               clra
                    clrb
                    std       $08,u
                    lbra      L2D34

L2C42               ldd       $06,s
                    cmpd      #$00A0
                    blt       L2C4F
                    leax      $08,s
                    lbra      L2BA5

L2C4F               leax      L2D38,pcr
                    pshs      x
                    pshs      u
                    lbsr      L484B
                    leas      $04,s
                    lbra      L2D34

L2C5F               cmpx      #$0080
                    lbeq      L2D34
                    cmpx      #$0093
                    lbeq      L2D34
                    cmpx      #$0094
                    lbeq      L2D34
                    cmpx      #$0095
                    lbeq      L2D34
                    cmpx      #$0034
                    lbeq      L2D34
                    cmpx      #$0042
                    lbeq      L2A30
                    cmpx      #$0092
                    lbeq      L2A3A
                    cmpx      #$008E
                    lbeq      L2A3A
                    cmpx      #$0090
                    lbeq      L2A61
                    cmpx      #$008D
                    lbeq      L2A6A
                    cmpx      #$008C
                    lbeq      L2A6A
                    cmpx      #$004B
                    lbeq      L2A77
                    cmpx      #$0064
                    lbeq      L2AA0
                    cmpx      #$003C
                    lbeq      L2AAF
                    cmpx      #$003D
                    lbeq      L2AAF
                    cmpx      #$0043
                    lbeq      L2AAF
                    cmpx      #$003E
                    lbeq      L2ACF
                    cmpx      #$003F
                    lbeq      L2ACF
                    cmpx      #$0065
                    lbeq      L2B42
                    cmpx      #$005A
                    lbeq      L2B4B
                    cmpx      #$005B
                    lbeq      L2B4B
                    cmpx      #$005E
                    lbeq      L2B4B
                    cmpx      #$005C
                    lbeq      L2B4B
                    cmpx      #$005F
                    lbeq      L2B4B
                    cmpx      #$005D
                    lbeq      L2B4B
                    cmpx      #$0050
                    lbeq      L2B4B
                    cmpx      #$0051
                    lbeq      L2B4B
                    cmpx      #$0052
                    lbeq      L2B4B
                    cmpx      #$0053
                    lbeq      L2B4B
                    cmpx      #$0078
                    lbeq      L2B7F
                    lbra      L2C42

L2D34               leas      $08,s
                    puls      pc,u
L2D38               fcc       /floats/
                    fcb       $00
L2D3F               pshs      u
                    leax      $00CE,y
                    stx       L001B
                    ldd       #$0001
                    std       $0021
                    leax      $06,s
                    pshs      x
                    ldd       $06,s
                    bra       L2D65

fprintf             pshs      u
                    ldd       $04,s
                    std       L001B
                    ldd       #$0001
                    std       $0021
                    leax      $08,s
                    pshs      x
                    ldd       $08,s
L2D65               pshs      d
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
                    bra       L2DA4

L2D94               ldb       $08,s
                    lbeq      L2F04
                    ldb       $08,s
                    sex
                    pshs      d
                    lbsr      L30E3
                    leas      $02,s
L2DA4               ldb       ,u+
                    stb       $08,s
                    cmpb      #$25
                    bne       L2D94
                    ldb       ,u+
                    stb       $08,s
                    clra
                    clrb
                    std       $02,s
                    std       $06,s
                    ldb       $08,s
                    cmpb      #$2d
                    bne       L2DC7
                    ldd       #$0001
                    std       L001D
                    ldb       ,u+
                    stb       $08,s
                    bra       L2DCB

L2DC7               clra
                    clrb
                    std       L001D
L2DCB               ldb       $08,s
                    cmpb      #$30
                    bne       L2DD6
                    ldd       #$0030
                    bra       L2DD9

L2DD6               ldd       #$0020
L2DD9               std       $001F
                    bra       L2DF7

L2DDD               ldd       $06,s
                    pshs      d
                    ldd       #$000A
                    lbsr      L5E8F
                    pshs      d
                    ldb       $0a,s
                    sex
                    addd      #$FFD0
                    addd      ,s++
                    std       $06,s
                    ldb       ,u+
                    stb       $08,s
L2DF7               ldb       $08,s
                    sex
                    leax      $0192,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$08
                    bne       L2DDD
                    ldb       $08,s
                    cmpb      #$2e
                    bne       L2E40
                    ldd       #$0001
                    std       $04,s
                    bra       L2E2A

L2E14               ldd       $02,s
                    pshs      d
                    ldd       #$000A
                    lbsr      L5E8F
                    pshs      d
                    ldb       $0a,s
                    sex
                    addd      #$FFD0
                    addd      ,s++
                    std       $02,s
L2E2A               ldb       ,u+
                    stb       $08,s
                    ldb       $08,s
                    sex
                    leax      $0192,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$08
                    bne       L2E14
                    bra       L2E44

L2E40               clra
                    clrb
                    std       $04,s
L2E44               ldb       $08,s
                    sex
                    tfr       d,x
                    lbra      L2EE6

L2E4C               ldd       $06,s
                    pshs      d
                    ldx       $13,s
                    leax      $02,x
                    stx       $13,s
                    ldd       -$02,x
                    pshs      d
                    lbsr      L2F08
                    bra       L2E74

L2E61               ldd       $06,s
                    pshs      d
                    ldx       $13,s
                    leax      $02,x
                    stx       $13,s
                    ldd       -$02,x
                    pshs      d
                    lbsr      L2FC9
L2E74               std       ,s
                    lbra      L2ED1

L2E79               ldx       $11,s
                    leax      $02,x
                    stx       $11,s
                    ldd       -$02,x
                    lbra      L2EDC

L2E86               ldx       $11,s
                    leax      $02,x
                    stx       $11,s
                    ldd       -$02,x
                    std       $09,s
                    ldd       $04,s
                    beq       L2EC9
                    ldd       $09,s
                    std       $04,s
                    bra       L2EA8

L2E9C               ldb       [$09,s]
                    beq       L2EB4
                    ldd       $09,s
                    addd      #$0001
                    std       $09,s
L2EA8               ldd       $02,s
                    addd      #$FFFF
                    std       $02,s
                    subd      #$FFFF
                    bne       L2E9C
L2EB4               ldd       $06,s
                    pshs      d
                    ldd       $0b,s
                    subd      $06,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L3088
                    leas      $06,s
                    bra       L2ED6

L2EC9               ldd       $06,s
                    pshs      d
                    ldd       $0b,s
                    pshs      d
L2ED1               lbsr      L3028
                    leas      $04,s
L2ED6               lbra      L2DA4

L2ED9               ldb       $08,s
                    sex
L2EDC               pshs      d
                    lbsr      L30E3
                    leas      $02,s
                    lbra      L2DA4

L2EE6               cmpx      #$0064
                    lbeq      L2E4C
                    cmpx      #$0078
                    lbeq      L2E61
                    cmpx      #$0063
                    lbeq      L2E79
                    cmpx      #$0073
                    lbeq      L2E86
                    bra       L2ED9

L2F04               leas      $0b,s
                    puls      pc,u
L2F08               pshs      u,d
                    leax      $0286,y
                    stx       ,s
                    ldd       $06,s
                    bge       L2F3D
                    ldd       $06,s
                    nega
                    negb
                    sbca      #$00
                    std       $06,s
                    bge       L2F32
                    leax      L3108,pcr
                    pshs      x
                    leax      $0286,y
                    pshs      x
                    lbsr      L55FF
                    leas      $04,s
                    lbra      L30DF

L2F32               ldd       #$002D
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
L2F3D               ldd       $06,s
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    bsr       L2F52
                    leas      $04,s
                    leax      $0286,y
                    tfr       x,d
                    lbra      L30DF

L2F52               pshs      u,y,x,d
                    ldu       $0a,s
                    clra
                    clrb
                    std       $02,s
                    clra
                    clrb
                    std       ,s
                    bra       L2F6F

L2F60               ldd       ,s
                    addd      #$0001
                    std       ,s
                    ldd       $0C,s
                    subd      >$0043,y
                    std       $0C,s
L2F6F               ldd       $0C,s
                    blt       L2F60
                    leax      >$0043,y
                    stx       $04,s
                    bra       L2FB1

L2F7B               ldd       ,s
                    addd      #$0001
                    std       ,s
L2F82               ldd       $0C,s
                    subd      [$04,s]
                    std       $0C,s
                    bge       L2F7B
                    ldd       $0C,s
                    addd      [$04,s]
                    std       $0C,s
                    ldd       ,s
                    beq       L2F9B
                    ldd       #$0001
                    std       $02,s
L2F9B               ldd       $02,s
                    beq       L2FA6
                    ldd       ,s
                    addd      #$0030
                    stb       ,u+
L2FA6               clra
                    clrb
                    std       ,s
                    ldd       $04,s
                    addd      #$0002
                    std       $04,s
L2FB1               ldd       $04,s
                    cmpd      $0001
                    bne       L2F82
                    ldd       $0C,s
                    addd      #$0030
                    stb       ,u+
                    clra
                    clrb
                    stb       ,u
                    ldd       $0a,s
                    leas      $06,s
                    puls      pc,u
L2FC9               pshs      u,x,d
                    leax      $0286,y
                    stx       $02,s
                    leau      $0290,y
L2FD5               ldd       $08,s
                    clra
                    andb      #$0f
                    std       ,s
                    pshs      d
                    ldd       $02,s
                    cmpd      #$0009
                    ble       L2FEB
                    ldd       #$0057
                    bra       L2FEE

L2FEB               ldd       #$0030
L2FEE               addd      ,s++
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
                    bne       L2FD5
                    bra       L300E

L3004               ldb       ,u
                    ldx       $02,s
                    leax      $01,x
                    stx       $02,s
                    stb       -$01,x
L300E               leau      -$01,u
                    pshs      u
                    leax      $0290,y
                    cmpx      ,s++
                    bls       L3004
                    clra
                    clrb
                    stb       [$02,s]
                    leax      $0286,y
                    tfr       x,d
                    lbra      L3104

L3028               pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    pshs      d
                    lbsr      L55EE
                    leas      $02,s
                    nega
                    negb
                    sbca      #$00
                    leau      d,u
                    ldd       L001D
                    bne       L305F
                    bra       L304C

L3043               ldd       $001F
                    pshs      d
                    lbsr      L30E3
                    leas      $02,s
L304C               tfr       u,d
                    leau      -$01,u
                    std       -$02,s
                    bgt       L3043
                    bra       L305F

L3056               ldd       ,s
                    pshs      d
                    lbsr      L30E3
                    leas      $02,s
L305F               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    sex
                    std       ,s
                    bne       L3056
                    ldd       L001D
                    lbeq      L30DF
                    bra       L307D

L3074               ldd       $001F
                    pshs      d
                    lbsr      L30E3
                    leas      $02,s
L307D               tfr       u,d
                    leau      -$01,u
                    std       -$02,s
                    bgt       L3074
                    lbra      L30DF

L3088               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    ldd       $0a,s
                    subd      $08,s
                    std       ,s
                    ldd       L001D
                    bne       L30B9
                    bra       L30A2

L309A               ldd       $001F
                    pshs      d
                    bsr       L30E3
                    leas      $02,s
L30A2               ldd       ,s
                    addd      #$FFFF
                    std       ,s
                    subd      #$FFFF
                    bgt       L309A
                    bra       L30B9

L30B0               ldb       ,u+
                    sex
                    pshs      d
                    bsr       L30E3
                    leas      $02,s
L30B9               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bne       L30B0
                    ldd       L001D
                    beq       L30DF
                    bra       L30D3

L30CB               ldd       $001F
                    pshs      d
                    bsr       L30E3
                    leas      $02,s
L30D3               ldd       ,s
                    addd      #$FFFF
                    std       ,s
                    subd      #$FFFF
                    bgt       L30CB
L30DF               leas      $02,s
                    puls      pc,u
L30E3               pshs      u
                    ldd       $0021
                    cmpd      #$0002
                    bne       L30F9
                    ldd       $04,s
                    ldx       L001B
                    leax      $01,x
                    stx       L001B
                    stb       -$01,x
                    bra       L3106

L30F9               ldd       L001B
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L515E
L3104               leas      $04,s
L3106               puls      pc,u
L3108               blt       $313D
                    leas      -$09,y
                    pshu      y,x,dp
                    neg       $0034
                    rorb
                    ldd       $08,s
                    pshs      d
                    lbsr      L31AE
                    leas      $02,s
                    std       ,s
                    lbeq      L319F
                    ldd       >$004b,y
                    std       $02,s
                    bne       L313E
                    leax      $029a,y
                    stx       $02,s
                    tfr       x,d
                    std       >$004b,y
                    std       $029a,y
                    clra
                    clrb
                    std       $029C,y
L313E               ldu       [$02,s]
L3141               ldd       $02,u
                    cmpd      ,s
                    bcs       L318A
                    ldd       $02,u
                    cmpd      ,s
                    bne       L3156
                    ldd       ,u
                    std       [$02,s]
                    bra       L3166

L3156               ldd       $02,u
                    subd      ,s
                    std       $02,u
                    aslb
                    rola
                    aslb
                    rola
                    leau      d,u
                    ldd       ,s
                    std       $02,u
L3166               ldd       $02,s
                    std       >$004b,y
                    stu       $02,s
                    bra       L317A

L3170               ldx       $02,s
                    leax      $01,x
                    stx       $02,s
                    clra
                    clrb
                    stb       -$01,x
L317A               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bne       L3170
                    tfr       u,d
                    bra       L31AA

L318A               cmpu      >$004b,y
                    bne       L31A3
                    ldd       ,s
                    pshs      d
                    bsr       L31BB
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    bne       L31A3
L319F               clra
                    clrb
                    bra       L31AA

L31A3               stu       $02,s
                    ldu       ,u
                    lbra      L3141

L31AA               leas      $04,s
                    puls      pc,u
L31AE               pshs      u
                    ldd       $04,s
                    addd      #$0003
                    lsra
                    rorb
                    lsra
                    rorb
                    puls      pc,u
L31BB               pshs      u,d
                    ldd       $06,s
                    addd      #$007F
                    pshs      d
                    ldd       #$0007
                    lbsr      L5FB9
                    pshs      d
                    ldd       #$0007
                    lbsr      L5FD0
                    std       ,s
                    pshs      d
                    ldd       #$0004
                    lbsr      L5E8F
                    std       ,s
                    pshs      d
                    lbsr      L6197
                    leas      $02,s
                    tfr       d,u
                    cmpu      #$FFFF
                    bne       L31F2
                    clra
                    clrb
                    lbra      L328E

L31F2               ldd       ,s
                    pshs      d
                    pshs      u
                    bsr       L3203
                    leas      $04,s
                    ldd       >$004b,y
                    lbra      L328E

L3203               pshs      u,d
                    ldu       $06,s
                    lbeq      L328E
                    ldd       $08,s
                    pshs      d
                    lbsr      L31AE
                    leas      $02,s
                    std       $08,s
                    ldd       >$004b,y
                    bra       L322F

L321C               ldd       ,s
                    cmpd      [,s]
                    bcs       L322D
                    cmpu      ,s
                    bhi       L323D
                    cmpu      [,s]
                    bcs       L323D
L322D               ldd       [,s]
L322F               std       ,s
                    cmpu      ,s
                    bls       L321C
                    cmpu      [,s]
                    lbcc      L321C
L323D               pshs      u
                    ldd       $0a,s
                    aslb
                    rola
                    aslb
                    rola
                    addd      ,s++
                    cmpd      [,s]
                    bne       L325F
                    ldd       $08,s
                    pshs      d
                    ldx       [$02,s]
                    ldd       $02,x
                    addd      ,s++
                    std       $08,s
                    ldx       ,s
                    ldd       [,x]
                    bra       L3261

L325F               ldd       [,s]
L3261               std       ,u
                    ldx       ,s
                    ldd       $02,x
                    aslb
                    rola
                    aslb
                    rola
                    addd      ,s
                    pshs      d
                    cmpu      ,s++
                    bne       L3282
                    ldx       ,s
                    ldd       $02,x
                    addd      $08,s
                    std       $02,x
                    ldd       ,u
                    std       [,s]
                    bra       L3284

L3282               stu       [,s]
L3284               ldd       $08,s
                    std       $02,u
                    ldd       ,s
                    std       >$004b,y
L328E               leas      $02,s
                    puls      pc,u
L3292               pshs      u
                    ldu       $0a,s
                    leas      -$08,s
                    ldd       $0C,s
                    cmpd      #$0088
                    bne       L32B0
                    ldd       $10,s
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    lbsr      L39D9
                    lbra      L37FF

L32B0               ldd       $0C,s
                    cmpd      #$0087
                    bne       L32C8
                    ldd       $10,s
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    lbsr      L3BC2
                    lbra      L37FF

L32C8               ldx       $0C,s
                    lbra      L3548

L32CD               ldd       $0e,s
                    pshs      d
                    lbsr      L3987
                    std       ,s
                    leax      L44F4,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      fprintf
                    leas      $06,s
                    ldd       $000D
                    subd      #$0002
                    std       $000D
                    cmpd      L0017
                    lbge      L39D5
                    ldd       $000D
                    std       L0017
                    lbra      L39D5

L32FA               ldd       $10,s
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       #$0071
                    pshs      d
                    ldd       #$0081
                    pshs      d
                    lbsr      L3292
                    leas      $08,s
                    ldd       $0e,s
                    std       $10,s
                    ldd       #$005A
                    std       $0e,s
L331D               leax      L44FE,pcr
                    pshs      x
                    lbsr      L43B8
                    leas      $02,s
                    ldd       $0e,s
                    pshs      d
                    lbsr      L4332
                    std       ,s
                    lbra      L3400

L3334               leax      L4501,pcr
                    lbra      L34A1

L333B               pshs      u
                    ldd       $12,s
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    lbsr      L3EA4
                    leas      $06,s
                    lbra      L39D5

L334F               leax      L450C,pcr
                    bra       L337D

L3355               leax      L4513,pcr
                    bra       L337D

L335B               leax      L451A,pcr
                    bra       L337D

L3361               leax      L4520,pcr
                    bra       L337D

L3367               leax      L4526,pcr
                    bra       L337D

L336D               leax      L452C,pcr
                    bra       L337D

L3373               leax      L4532,pcr
                    bra       L337D

L3379               leax      L4539,pcr
L337D               pshs      x
                    lbsr      L3E51
                    lbra      L3785

L3385               leax      L453F,pcr
                    lbra      L34A1

L338C               leax      L4553,pcr
                    lbra      L34A1

L3393               leax      L455E,pcr
                    pshs      x
                    lbsr      L43B8
                    leas      $02,s
                    ldd       $000D
                    nega
                    negb
                    sbca      #$00
                    pshs      d
                    lbsr      L4407
                    leas      $02,s
                    ldd       >$004f,y
                    pshs      d
                    lbsr      L43F6
                    leas      $02,s
                    lbsr      L43DC
L33B9               ldd       >$0053,y
                    pshs      d
                    lbsr      L43B8
                    leas      $02,s
                    ldd       $0e,s
                    bra       L3408

L33C8               ldd       >$0053,y
                    pshs      d
                    lbsr      L43B8
                    leas      $02,s
                    ldd       $10,s
                    pshs      d
                    lbsr      L4414
                    leas      $02,s
                    ldd       $0e,s
                    pshs      d
                    lbsr      L4414
                    leas      $02,s
                    leax      L4564,pcr
                    pshs      x
                    lbsr      L43B8
                    leas      $02,s
                    ldd       $000D
                    pshs      d
                    lbsr      L4407
                    leas      $02,s
                    leax      L456A,pcr
                    pshs      x
L3400               lbsr      L43F6
                    leas      $02,s
                    ldd       $10,s
L3408               pshs      d
                    lbsr      L4414
                    lbra      L3785

L3410               ldd       #$0004
                    std       $000F
                    ldx       $10,s
                    ldd       $06,x
                    cmpd      #$0034
                    bne       L3445
                    ldx       $10,s
                    ldd       $08,x
                    std       $04,s
                    beq       L3445
                    ldd       >$0051,y
                    pshs      d
                    lbsr      L43B8
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    ldd       $06,s
                    addd      #$0004
                    pshs      d
                    lbsr      L4471
                    lbra      L37FF

L3445               leax      L456E,pcr
                    pshs      x
                    lbsr      L43B8
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    ldd       $12,s
                    pshs      d
                    ldd       $12,s
                    pshs      d
                    lbsr      L40D0
                    leas      $06,s
                    lbra      L34D8

L3466               leax      L4573,pcr
                    bra       L34A1

L346C               leax      L4577,pcr
                    pshs      x
                    lbsr      L43B8
                    leas      $02,s
                    ldd       #$0002
                    pshs      d
                    ldd       $12,s
                    pshs      d
                    ldd       $12,s
                    pshs      d
                    ldd       #$0064
                    pshs      d
                    lbsr      L4085
                    lbra      L38D8

L3491               leax      L457A,pcr
                    bra       L34A1

L3497               leax      L4585,pcr
                    bra       L34A1

L349D               leax      L4590,pcr
L34A1               pshs      x
                    lbra      L3782

L34A6               leax      L459B,pcr
                    pshs      x
                    lbsr      L43B8
                    leas      $02,s
                    leax      $08,s
                    bra       L34C2

L34B5               leax      L45A0,pcr
                    pshs      x
                    lbsr      L43B8
                    leas      $02,s
                    bra       L34C4

L34C2               leas      -$08,x
L34C4               ldd       $0e,s
                    pshs      d
                    lbsr      L4407
                    leas      $02,s
                    ldd       >$004f,y
                    pshs      d
                    lbsr      L43F6
                    leas      $02,s
L34D8               lbsr      L43DC
                    lbra      L39D5

L34DE               leax      L45A5,pcr
                    pshs      x
                    lbsr      L43B8
                    leas      $02,s
                    ldx       $0e,s
                    bra       L353B

L34ED               ldx       $10,s
                    ldd       $06,x
                    std       $06,s
                    cmpd      #$0094
                    bne       L34FF
                    ldd       #$0079
                    bra       L350F

L34FF               ldd       $06,s
                    cmpd      #$0095
                    bne       L350C
                    ldd       #$0075
                    bra       L350F

L350C               ldd       #$0078
L350F               std       $06,s
                    pshs      d
                    ldx       $12,s
                    ldd       $08,x
                    pshs      d
                    leax      L45AB,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      fprintf
                    lbra      L38D8

L352A               ldd       $10,s
                    pshs      d
                    lbsr      L3987
                    std       ,s
                    leax      L45B2,pcr
                    lbra      L37A8

L353B               cmpx      #$0077
                    beq       L34ED
                    cmpx      #$0070
                    beq       L352A
                    lbra      L39D5

L3548               cmpx      #$007A
                    lbeq      L32CD
                    cmpx      #$007D
                    lbeq      L32FA
                    cmpx      #$0082
                    lbeq      L331D
                    cmpx      #$0012
                    lbeq      L3334
                    cmpx      #$0057
                    lbeq      L333B
                    cmpx      #$0058
                    lbeq      L333B
                    cmpx      #$0059
                    lbeq      L333B
                    cmpx      #$0052
                    lbeq      L334F
                    cmpx      #$004E
                    lbeq      L3355
                    cmpx      #$0053
                    lbeq      L335B
                    cmpx      #$0056
                    lbeq      L3361
                    cmpx      #$0055
                    lbeq      L3367
                    cmpx      #$004D
                    lbeq      L336D
                    cmpx      #$004C
                    lbeq      L3373
                    cmpx      #$0054
                    lbeq      L3379
                    cmpx      #$0043
                    lbeq      L3385
                    cmpx      #$0044
                    lbeq      L338C
                    cmpx      #$001D
                    lbeq      L3393
                    cmpx      #$007C
                    lbeq      L33B9
                    cmpx      #$0009
                    lbeq      L33C8
                    cmpx      #$0065
                    lbeq      L3410
                    cmpx      #$0085
                    lbeq      L3466
                    cmpx      #$0084
                    lbeq      L346C
                    cmpx      #$0098
                    lbeq      L3491
                    cmpx      #$0096
                    lbeq      L3497
                    cmpx      #$0097
                    lbeq      L349D
                    cmpx      #$0076
                    lbeq      L34A6
                    cmpx      #$006F
                    lbeq      L34B5
                    cmpx      #$007B
                    lbeq      L34DE
                    ldd       $0e,s
                    pshs      d
                    lbsr      L3987
                    leas      $02,s
                    std       $06,s
                    ldd       $10,s
                    cmpd      #$0077
                    lbne      L36A1
                    ldd       $06,u
                    cmpd      #$0085
                    bne       L3684
                    ldd       $0a,u
                    pshs      d
                    ldd       #$0077
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       $12,s
                    pshs      d
                    lbsr      L3292
                    leas      $08,s
                    ldx       $0C,s
                    bra       L3666

L364D               leax      L45B8,pcr
                    bra       L365D

L3653               leax      L45BC,pcr
                    bra       L365D

L3659               leax      L45C4,pcr
L365D               pshs      x
                    lbsr      L43D1
                    leas      $02,s
                    bra       L367C

L3666               cmpx      #$0075
                    beq       L364D
                    cmpx      #$004F
                    beq       L3653
                    cmpx      #$0050
                    lbeq      L3653
                    cmpx      #$0051
                    beq       L3659
L367C               ldd       #$0070
                    std       $06,u
                    lbra      L39D5

L3684               ldd       ,u
                    cmpd      #$0002
                    bne       L36A1
                    ldd       $0C,s
                    cmpd      #$007F
                    beq       L36A1
                    ldd       $06,s
                    cmpd      #$0078
                    beq       L36A1
                    ldd       #$0062
                    std       $06,s
L36A1               ldx       $0C,s
                    lbra      L3946

L36A6               ldd       $10,s
                    cmpd      #$0077
                    lbne      L3765
                    ldd       $08,u
                    std       ,s
                    ldd       $06,u
                    std       $02,s
                    tfr       d,x
                    lbra      L3741

L36BE               ldd       $0e,s
                    cmpd      #$0070
                    beq       L36E3
                    ldd       $06,s
                    pshs      d
                    lbsr      L448E
                    leas      $02,s
                    ldd       $02,s
                    pshs      d
                    lbsr      L3987
                    std       ,s
                    ldd       $02,s
                    pshs      d
                    leax      L45CC,pcr
                    lbra      L38CF

L36E3               ldd       #$0064
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    lbsr      L3987
                    std       ,s
                    lbsr      L39BE
                    leas      $04,s
                    ldd       ,s
                    lbeq      L39D5
                    ldd       ,s
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0050
                    pshs      d
                    lbsr      L3292
                    lbra      L38D8

L3715               ldd       $0e,s
                    cmpd      #$0070
                    lbeq      L39D5
                    ldd       $06,s
                    pshs      d
                    ldd       #$0064
                    lbra      L37FA

L3729               ldd       $08,u
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L44A5
                    lbra      L37FF

L3737               ldd       #$0036
                    std       $10,s
                    ldu       ,s
                    bra       L3765

L3741               cmpx      #$0071
                    lbeq      L36BE
                    cmpx      #$0076
                    lbeq      L36BE
                    cmpx      #$006F
                    lbeq      L36BE
                    cmpx      #$0070
                    beq       L3715
                    cmpx      #$0037
                    beq       L3729
                    cmpx      #$0036
                    beq       L3737
L3765               ldd       $0e,s
                    cmpd      #$0070
                    bne       L378A
                    ldd       $10,s
                    cmpd      #$0036
                    bne       L378A
                    cmpu      #$0000
                    bne       L378A
                    leax      L45D3,pcr
                    pshs      x
L3782               lbsr      L43D1
L3785               leas      $02,s
                    lbra      L39D5

L378A               leax      L45DE,pcr
                    lbra      L380E

L3791               ldd       $10,s
                    cmpd      #$0036
                    bne       L37B6
                    cmpu      #$0000
                    bne       L37B6
                    ldd       $06,s
                    pshs      d
                    leax      L45E1,pcr
L37A8               pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      fprintf
                    leas      $06,s
                    lbra      L39D5

L37B6               leax      L45ED,pcr
                    pshs      x
                    lbsr      L43B8
                    leas      $02,s
                    ldd       $06,s
                    cmpd      #$0062
                    bne       L3815
                    ldd       #$0064
                    std       $06,s
                    bra       L3815

L37D0               ldd       $10,s
                    cmpd      #$0077
                    bne       L3804
                    ldd       $06,u
                    std       $02,s
                    pshs      d
                    lbsr      L1EB3
                    std       ,s++
                    beq       L3804
                    ldd       $02,s
                    cmpd      $0e,s
                    lbeq      L39D5
                    ldd       $02,s
                    pshs      d
                    lbsr      L3987
                    std       ,s
                    ldd       $08,s
L37FA               pshs      d
                    lbsr      L39BE
L37FF               leas      $04,s
                    lbra      L39D5

L3804               leax      L45F1,pcr
                    bra       L380E

L380A               leax      L45F4,pcr
L380E               pshs      x
                    lbsr      L43B8
                    leas      $02,s
L3815               leax      $08,s
                    bra       L382A

L3819               ldd       #$0043
                    pshs      d
                    lbsr      L3292
                    leas      $02,s
L3823               leax      L45F8,pcr
                    lbra      L38A2

L382A               leas      -$08,x
                    lbra      L38A9

L382F               ldd       $10,s
                    cmpd      #$0077
                    lbne      L389E
                    ldd       [$08,u]
                    std       $02,s
                    tfr       d,x
                    bra       L388B

L3843               ldd       $06,s
                    pshs      d
                    lbsr      L448E
                    leas      $02,s
                    ldd       #$003E
                    pshs      d
                    lbsr      L43E7
                    leas      $02,s
                    ldd       $02,s
                    cmpd      #$0023
                    bne       L3869
                    ldx       $08,u
                    ldd       $04,x
                    pshs      d
                    lbsr      L441F
                    bra       L3873

L3869               ldd       $08,u
                    addd      #$0004
                    pshs      d
                    lbsr      L4432
L3873               leas      $02,s
                    ldd       $14,u
                    pshs      d
                    lbsr      L40AF
                    leas      $02,s
                    ldd       >$004d,y
                    pshs      d
                    lbsr      L43F6
                    lbra      L3916

L388B               cmpx      #$0021
                    beq       L3843
                    cmpx      #$0022
                    lbeq      L3843
                    cmpx      #$0023
                    lbeq      L3843
L389E               leax      L45FC,pcr
L38A2               pshs      x
                    lbsr      L43B8
                    leas      $02,s
L38A9               clra
                    clrb
                    pshs      d
                    pshs      u
                    ldd       $14,s
                    pshs      d
                    ldd       $0C,s
                    pshs      d
                    lbsr      L4085
                    bra       L38D8

L38BD               ldd       $10,s
                    pshs      d
                    lbsr      L3987
                    std       ,s
                    ldd       $08,s
                    pshs      d
                    leax      L4600,pcr
L38CF               pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      fprintf
L38D8               leas      $08,s
                    lbra      L39D5

L38DD               ldd       $06,s
                    pshs      d
                    lbsr      L448E
                    leas      $02,s
                    ldx       $10,s
                    bra       L392C

L38EB               leax      L460C,pcr
                    pshs      x
                    lbsr      L43F6
                    leas      $02,s
                    leax      $08,s
                    bra       L390D

L38FA               pshs      u
                    lbsr      L4407
                    leas      $02,s
                    ldd       #$002C
                    pshs      d
                    lbsr      L43E7
                    leas      $02,s
                    bra       L390F

L390D               leas      -$08,x
L390F               ldd       $06,s
                    pshs      d
                    lbsr      L43E7
L3916               leas      $02,s
                    lbsr      L43DC
                    lbra      L39D5

L391E               leax      L460F,pcr
                    pshs      x
                    lbsr      L4823
                    leas      $02,s
                    lbra      L39D5

L392C               cmpx      #$0070
                    beq       L38EB
                    cmpx      #$0036
                    beq       L38FA
                    bra       L391E

L3938               ldd       >$0057,y
                    pshs      d
                    lbsr      L4823
                    leas      $02,s
                    lbra      L39D5

L3946               cmpx      #$0075
                    lbeq      L36A6
                    cmpx      #$0081
                    lbeq      L3791
                    cmpx      #$0079
                    lbeq      L37D0
                    cmpx      #$0051
                    lbeq      L380A
                    cmpx      #$004F
                    lbeq      L3819
                    cmpx      #$0050
                    lbeq      L3823
                    cmpx      #$007F
                    lbeq      L382F
                    cmpx      #$0073
                    lbeq      L38BD
                    cmpx      #$0074
                    lbeq      L38DD
                    bra       L3938

L3987               pshs      u
                    ldx       $04,s
                    bra       L39A6

L398D               ldd       #$0064
                    puls      pc,u
L3992               ldd       #$0078
                    puls      pc,u
L3997               ldd       #$0079
                    puls      pc,u
L399C               ldd       #$0075
                    puls      pc,u
L39A1               ldd       #$0020
                    puls      pc,u
L39A6               cmpx      #$0070
                    beq       L398D
                    cmpx      #$0071
                    beq       L3992
                    cmpx      #$0076
                    beq       L3997
                    cmpx      #$006F
                    beq       L399C
                    bra       L39A1
                    puls      pc,u
L39BE               pshs      u
                    ldd       $06,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    leax      L4617,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      fprintf
L39D5               leas      $08,s
                    puls      pc,u
L39D9               pshs      u
                    ldx       $04,s
                    lbra      L3AF9

L39E0               ldd       #$0002
                    pshs      d
                    ldd       #$0093
                    pshs      d
                    ldd       #$0070
                    pshs      d
                    ldd       #$0075
                    pshs      d
                    lbsr      L3292
                    leas      $08,s
                    ldd       #$0070
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3292
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
                    lbsr      L3292
                    leas      $08,s
                    ldd       #$0070
                    pshs      d
                    ldd       #$007A
                    pshs      d
                    lbsr      L3292
                    lbra      L3BD5

L3A30               leax      L4623,pcr
                    pshs      x
                    lbsr      L43D1
                    lbra      L40CC

L3A3C               leax      L4646,pcr
                    bra       L3A7C

L3A42               leax      L464D,pcr
                    bra       L3A8F

L3A48               leax      L4653,pcr
                    bra       L3A8F

L3A4E               leax      L4659,pcr
                    bra       L3A8F

L3A54               leax      L465F,pcr
                    bra       L3A8F

L3A5A               leax      L4665,pcr
                    bra       L3A8F

L3A60               leax      L466B,pcr
                    bra       L3A8F

L3A66               leax      L4671,pcr
                    bra       L3A8F

L3A6C               leax      L4676,pcr
                    bra       L3A8F

L3A72               leax      L467C,pcr
                    bra       L3A7C

L3A78               leax      L4682,pcr
L3A7C               pshs      x
                    lbsr      L3E6E
                    leas      $02,s
                    ldd       $000D
                    subd      #$0002
                    lbra      L3E89

L3A8B               leax      L4688,pcr
L3A8F               pshs      x
                    lbsr      L3E6E
                    lbra      L40CC

L3A97               leax      L468F,pcr
                    bra       L3AB9

L3A9D               leax      L4695,pcr
                    bra       L3AB9

L3AA3               leax      L469D,pcr
                    bra       L3AB9

L3AA9               leax      L46A4,pcr
                    bra       L3AB9

L3AAF               leax      L46AB,pcr
                    bra       L3AB9

L3AB5               leax      L46B1,pcr
L3AB9               pshs      x
                    lbsr      L3E6E
                    leas      $02,s
                    ldd       $000D
                    subd      #$0004
                    lbra      L3E89

L3AC8               ldd       #$0002
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbra      L3BD2

L3AD4               leax      L46B7,pcr
                    pshs      x
                    lbsr      L4823
                    leas      $02,s
                    ldd       >$0057,y
                    pshs      d
                    lbsr      L43F6
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L4407
                    leas      $02,s
                    lbsr      L43DC
                    lbra      L3BC0

L3AF9               cmpx      #$006E
                    lbeq      L39E0
                    cmpx      #$008B
                    lbeq      L3A30
                    cmpx      #$0089
                    lbeq      L3A3C
                    cmpx      #$0050
                    lbeq      L3A42
                    cmpx      #$0051
                    lbeq      L3A48
                    cmpx      #$0052
                    lbeq      L3A4E
                    cmpx      #$0053
                    lbeq      L3A54
                    cmpx      #$0054
                    lbeq      L3A5A
                    cmpx      #$0057
                    lbeq      L3A60
                    cmpx      #$0058
                    lbeq      L3A66
                    cmpx      #$0059
                    lbeq      L3A6C
                    cmpx      #$0056
                    lbeq      L3A72
                    cmpx      #$0055
                    lbeq      L3A78
                    cmpx      #$005A
                    lbeq      L3A8B
                    cmpx      #$005B
                    lbeq      L3A8B
                    cmpx      #$005E
                    lbeq      L3A8B
                    cmpx      #$005C
                    lbeq      L3A8B
                    cmpx      #$005F
                    lbeq      L3A8B
                    cmpx      #$005D
                    lbeq      L3A8B
                    cmpx      #$0043
                    lbeq      L3A97
                    cmpx      #$0044
                    lbeq      L3A9D
                    cmpx      #$0083
                    lbeq      L3AA3
                    cmpx      #$0086
                    lbeq      L3AA9
                    cmpx      #$003C
                    lbeq      L3AAF
                    cmpx      #$003E
                    lbeq      L3AAF
                    cmpx      #$003D
                    lbeq      L3AB5
                    cmpx      #$003F
                    lbeq      L3AB5
                    cmpx      #$004A
                    lbeq      L3AC8
                    lbra      L3AD4

L3BC0               puls      pc,u
L3BC2               pshs      u
                    ldu       $06,s
                    ldx       $04,s
                    lbra      L3CD5

L3BCB               ldd       #$0004
                    pshs      d
                    pshs      u
L3BD2               lbsr      L3D90
L3BD5               leas      $04,s
                    puls      pc,u
L3BD9               leax      L46C6,pcr
                    pshs      x
                    lbsr      L3E8D
                    leas      $02,s
                    ldd       $000D
                    subd      #$0008
                    lbra      L3E89

L3BEC               cmpu      #$0005
                    bne       L3BF7
                    ldd       #$0033
                    bra       L3BFA

L3BF7               ldd       #$0037
L3BFA               pshs      d
                    leax      L46CE,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      fprintf
                    leas      $06,s
                    puls      pc,u
L3C0D               cmpu      #$0005
                    bne       L3C19
                    leax      L46D9,pcr
                    bra       L3C1D

L3C19               leax      L46E0,pcr
L3C1D               tfr       x,d
                    pshs      d
                    lbsr      L3E8D
                    lbra      L3E65

L3C27               leax      L46E7,pcr
                    bra       L3C43

L3C2D               leax      L46ED,pcr
                    bra       L3C43

L3C33               leax      L46F3,pcr
                    bra       L3C43

L3C39               leax      L46F9,pcr
                    bra       L3C43

L3C3F               leax      L46FF,pcr
L3C43               pshs      x
                    lbsr      L3E8D
                    leas      $02,s
                    ldd       $000D
                    addd      #$0008
                    lbra      L3E89

L3C52               leax      L4706,pcr
                    bra       L3CA8

L3C58               cmpu      #$0005
                    bne       L3C64
                    leax      L470C,pcr
                    bra       L3C7A

L3C64               leax      L4712,pcr
                    bra       L3C7A

L3C6A               cmpu      #$0005
                    bne       L3C76
                    leax      L4718,pcr
                    bra       L3C7A

L3C76               leax      L471E,pcr
L3C7A               tfr       x,d
                    pshs      d
                    bra       L3CAA

L3C80               leax      L4724,pcr
                    bra       L3CA8

L3C86               leax      L472A,pcr
                    bra       L3CA8

L3C8C               leax      L4730,pcr
                    bra       L3CA8

L3C92               leax      L4736,pcr
                    bra       L3CA8

L3C98               leax      L473C,pcr
                    bra       L3CA8

L3C9E               leax      L4742,pcr
                    bra       L3CA8

L3CA4               leax      L4748,pcr
L3CA8               pshs      x
L3CAA               lbsr      L3E8D
                    lbra      L40CC

L3CB0               leax      L474E,pcr
                    pshs      x
                    lbsr      L4823
                    leas      $02,s
                    ldd       >$0057,y
                    pshs      d
                    lbsr      L43F6
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L4407
                    leas      $02,s
                    lbsr      L43DC
                    lbra      L3D8E

L3CD5               cmpx      #$004B
                    lbeq      L3BCB
                    cmpx      #$006E
                    lbeq      L3BD9
                    cmpx      #$008B
                    lbeq      L3BEC
                    cmpx      #$0089
                    lbeq      L3C0D
                    cmpx      #$0050
                    lbeq      L3C27
                    cmpx      #$0051
                    lbeq      L3C2D
                    cmpx      #$0052
                    lbeq      L3C33
                    cmpx      #$0053
                    lbeq      L3C39
                    cmpx      #$005A
                    lbeq      L3C3F
                    cmpx      #$005B
                    lbeq      L3C3F
                    cmpx      #$005E
                    lbeq      L3C3F
                    cmpx      #$005C
                    lbeq      L3C3F
                    cmpx      #$005F
                    lbeq      L3C3F
                    cmpx      #$005D
                    lbeq      L3C3F
                    cmpx      #$0043
                    lbeq      L3C52
                    cmpx      #$003C
                    lbeq      L3C58
                    cmpx      #$003E
                    lbeq      L3C58
                    cmpx      #$003D
                    lbeq      L3C6A
                    cmpx      #$003F
                    lbeq      L3C6A
                    cmpx      #$008D
                    lbeq      L3C80
                    cmpx      #$008C
                    lbeq      L3C86
                    cmpx      #$0090
                    lbeq      L3C8C
                    cmpx      #$008E
                    lbeq      L3C92
                    cmpx      #$0092
                    lbeq      L3C98
                    cmpx      #$0091
                    lbeq      L3C9E
                    cmpx      #$008F
                    lbeq      L3CA4
                    lbra      L3CB0

L3D8E               puls      pc,u
L3D90               pshs      u,d
                    leax      L475E,pcr
                    pshs      x
                    lbsr      L43B8
                    leas      $02,s
                    ldd       $000B
                    addd      #$0001
                    std       $000B
                    std       ,s
                    pshs      d
                    lbsr      L4414
                    leas      $02,s
                    ldd       $08,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    bsr       L3DD0
                    leas      $04,s
                    ldd       ,s
                    pshs      d
                    lbsr      L441F
                    leas      $02,s
                    leax      L4763,pcr
                    pshs      x
                    lbsr      L43D1
                    leas      $02,s
                    lbra      L40CC

L3DD0               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    lbsr      L4B88
                    ldd       $08,s
                    cmpd      #$0001
                    bne       L3DEB
                    pshs      u
                    lbsr      L4407
L3DE6               leas      $02,s
                    lbra      L3E4B

L3DEB               cmpu      #$0000
                    bne       L3E1C
                    ldd       #$0001
                    std       ,s
                    bra       L3E03

L3DF8               leax      L476A,pcr
                    pshs      x
                    lbsr      L43F6
                    leas      $02,s
L3E03               ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    cmpd      $08,s
                    blt       L3DF8
                    ldd       #$0030
                    pshs      d
                    lbsr      L43E7
                    bra       L3DE6

L3E1C               clra
                    clrb
                    bra       L3E42

L3E20               ldd       ,u++
                    pshs      d
                    lbsr      L4407
                    leas      $02,s
                    ldd       $08,s
                    addd      #$FFFF
                    cmpd      ,s
                    beq       L3E3D
                    ldd       #$002C
                    pshs      d
                    lbsr      L43E7
                    leas      $02,s
L3E3D               ldd       ,s
                    addd      #$0001
L3E42               std       ,s
                    ldd       ,s
                    cmpd      $08,s
                    blt       L3E20
L3E4B               lbsr      L43DC
                    lbra      L40CC

L3E51               pshs      u
                    ldd       >$0051,y
                    pshs      d
                    lbsr      L43B8
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L43D1
L3E65               leas      $02,s
                    ldd       $000D
                    addd      #$0002
                    bra       L3E89

L3E6E               pshs      u
                    ldd       >$0051,y
                    pshs      d
                    lbsr      L43B8
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L43D1
                    leas      $02,s
                    ldd       $000D
                    addd      #$0004
L3E89               std       $000D
                    puls      pc,u
L3E8D               pshs      u
                    ldd       >$0051,y
                    pshs      d
                    lbsr      L43B8
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L43D1
                    lbra      L40CC

L3EA4               pshs      u
                    ldu       $04,s
                    leas      -$06,s
                    clra
                    clrb
                    std       $02,s
                    ldd       $0C,s
                    cmpd      #$0077
                    bne       L3ED4
                    ldd       [$0e,s]
                    cmpd      #$0002
                    bne       L3EC4
                    ldd       #$0001
                    bra       L3EC6

L3EC4               clra
                    clrb
L3EC6               std       $02,s
                    ldx       $0e,s
                    ldd       $06,x
                    std       $0C,s
                    ldx       $0e,s
                    ldd       $08,x
                    std       $0e,s
L3ED4               leax      ,u
                    bra       L3EEC

L3ED8               leax      L476D,pcr
                    bra       L3EE8

L3EDE               leax      L4771,pcr
                    bra       L3EE8

L3EE4               leax      L4774,pcr
L3EE8               stx       $04,s
                    bra       L3EFB

L3EEC               cmpx      #$0057
                    beq       L3ED8
                    cmpx      #$0058
                    beq       L3EDE
                    cmpx      #$0059
                    beq       L3EE4
L3EFB               ldx       $0C,s
                    lbra      L405B

L3F00               ldd       $02,s
                    beq       L3F22
                    cmpu      #$0057
                    bne       L3F15
                    ldd       >$0055,y
                    pshs      d
                    lbsr      L43D1
                    leas      $02,s
L3F15               ldd       $04,s
                    pshs      d
                    lbsr      L43B8
                    leas      $02,s
                    clra
                    clrb
                    bra       L3F4F

L3F22               ldd       $04,s
                    pshs      d
                    lbsr      L43B8
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
                    lbsr      L4085
                    leas      $08,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L43B8
                    leas      $02,s
                    ldd       #$0001
L3F4F               pshs      d
                    ldd       $10,s
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    ldd       #$0062
                    pshs      d
                    lbsr      L4085
                    leas      $08,s
                    lbra      L44A1

L3F68               ldd       $0e,s
                    pshs      d
                    ldd       #$0008
                    lbsr      L5FAD
                    clra
                    std       ,s
                    tfr       d,x
                    bra       L3FC2

L3F79               cmpu      #$0057
                    bne       L3FCD
                    ldd       >$0055,y
                    pshs      d
                    bra       L3F99

L3F87               cmpu      #$0057
                    beq       L3FCD
                    cmpu      #$0059
                    bne       L3FA0
                    leax      L4778,pcr
                    pshs      x
L3F99               lbsr      L43D1
                    leas      $02,s
                    bra       L3FCD

L3FA0               ldd       $04,s
                    pshs      d
                    lbsr      L43B8
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
                    lbsr      L4085
                    leas      $08,s
                    bra       L3FCD

L3FC2               stx       -$02,s
                    beq       L3F79
                    cmpx      #$00FF
                    beq       L3F87
                    bra       L3FA0

L3FCD               ldd       $0e,s
                    clra
                    std       ,s
                    tfr       d,x
                    bra       L4023

L3FD6               cmpu      #$0057
                    lbne      L44A1
                    leax      L477D,pcr
                    bra       L3FF6

L3FE4               cmpu      #$0057
                    lbeq      L44A1
                    cmpu      #$0059
                    bne       L4000
                    leax      L4782,pcr
L3FF6               pshs      x
                    lbsr      L43D1
                    leas      $02,s
                    lbra      L44A1

L4000               ldd       $04,s
                    pshs      d
                    lbsr      L43B8
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
                    lbsr      L4085
                    leas      $08,s
                    lbra      L44A1

L4023               stx       -$02,s
                    beq       L3FD6
                    cmpx      #$00FF
                    beq       L3FE4
                    bra       L4000

L402E               ldd       $04,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    leax      L4787,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      fprintf
                    leas      $08,s
                    ldd       $000D
                    addd      #$0002
                    std       $000D
                    lbra      L44A1

L404F               leax      L479A,pcr
                    pshs      x
                    lbsr      L4823
                    lbra      L432D

L405B               cmpx      #$0034
                    lbeq      L3F00
                    cmpx      #$0094
                    lbeq      L3F00
                    cmpx      #$0095
                    lbeq      L3F00
                    cmpx      #$0093
                    lbeq      L3F00
                    cmpx      #$0036
                    lbeq      L3F68
                    cmpx      #$006E
                    beq       L402E
                    bra       L404F

L4085               pshs      u
                    ldd       $04,s
                    pshs      d
                    lbsr      L43E7
                    leas      $02,s
                    ldd       #$0020
                    pshs      d
                    lbsr      L43E7
                    leas      $02,s
                    ldd       $0a,s
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    bsr       L40D0
                    leas      $06,s
                    lbsr      L43DC
                    puls      pc,u
L40AF               pshs      u
                    ldu       $04,s
                    stu       -$02,s
                    beq       L40CE
                    cmpu      #$0000
                    ble       L40C7
                    ldd       #$002B
                    pshs      d
                    lbsr      L43E7
                    leas      $02,s
L40C7               pshs      u
                    lbsr      L4407
L40CC               leas      $02,s
L40CE               puls      pc,u
L40D0               pshs      u,y,x,d
                    ldd       $0a,s
                    anda      #$80
                    clrb
                    std       -$02,s
                    beq       L40E5
                    ldd       #$005B
                    pshs      d
                    lbsr      L43E7
                    leas      $02,s
L40E5               ldd       $0a,s
                    anda      #$7f
                    tfr       d,x
                    lbra      L42E2

L40EE               ldu       $0C,s
                    ldd       $06,u
                    cmpd      #$0041
                    bne       L410F
                    ldd       #$0023
                    pshs      d
                    lbsr      L43E7
                    leas      $02,s
                    ldd       $0e,s
                    pshs      d
                    ldd       $0a,u
                    pshs      d
                    ldd       #$0077
                    bra       L411C

L410F               ldd       $0e,s
                    addd      $14,u
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    ldd       $06,u
L411C               pshs      d
                    bsr       L40D0
                    leas      $06,s
                    lbra      L44A1

L4125               ldd       #$0023
                    pshs      d
                    lbsr      L43E7
                    leas      $02,s
                    ldd       $0C,s
                    lbra      L4267

L4134               leax      L47AB,pcr
                    pshs      x
                    lbsr      L43F6
                    leas      $02,s
                    ldd       $0e,s
                    pshs      d
                    lbsr      L40AF
                    leas      $02,s
                    ldd       >$004d,y
                    pshs      d
                    lbsr      L43F6
                    lbra      L42DE

L4154               ldd       $0C,s
                    std       ,s
                    lbeq      L4265
                    ldd       [,s]
                    std       $02,s
                    tfr       d,x
                    lbra      L4232

L4165               ldx       ,s
                    ldd       $04,x
                    subd      $000D
                    addd      $0e,s
                    std       $0C,s
                    pshs      d
                    lbsr      L4407
                    leas      $02,s
                    ldd       >$004f,y
                    lbra      L4223

L417D               ldd       L0023
                    bne       L4199
                    ldd       $0a,s
                    anda      #$80
                    clrb
                    std       -$02,s
                    beq       L418F
                    ldd       #$003E
                    bra       L4192

L418F               ldd       #$003C
L4192               pshs      d
                    lbsr      L43E7
                    leas      $02,s
L4199               ldx       ,s
                    ldd       $04,x
                    pshs      d
                    lbsr      L441F
                    leas      $02,s
                    leax      $06,s
                    bra       L41D2

L41A8               ldd       L0023
                    bne       L41C4
                    ldd       $0a,s
                    anda      #$80
                    clrb
                    std       -$02,s
                    beq       L41BA
                    ldd       #$003E
                    bra       L41BD

L41BA               ldd       #$003C
L41BD               pshs      d
                    lbsr      L43E7
                    leas      $02,s
L41C4               ldd       ,s
                    addd      #$0004
                    pshs      d
                    lbsr      L4432
                    leas      $02,s
                    bra       L41D4

L41D2               leas      -$06,x
L41D4               ldd       $0e,s
                    pshs      d
                    lbsr      L40AF
                    leas      $02,s
                    ldd       $0a,s
                    anda      #$80
                    clrb
                    std       -$02,s
                    bne       L420A
                    ldd       L0023
                    lbne      L431A
                    ldd       $02,s
                    cmpd      #$0021
                    lbeq      L431A
                    ldd       $02,s
                    cmpd      #$0022
                    lbeq      L431A
                    ldd       $02,s
                    cmpd      #$0023
                    lbeq      L431A
L420A               ldx       ,s
                    ldd       $02,x
                    clra
                    andb      #$30
                    cmpd      #$0030
                    bne       L421F
                    leax      L47B2,pcr
                    pshs      x
                    bra       L4225

L421F               ldd       >$004d,y
L4223               pshs      d
L4225               lbsr      L43F6
                    lbra      L42DE

L422B               leax      L47B7,pcr
                    lbra      L42D9

L4232               cmpx      #$000D
                    lbeq      L4165
                    cmpx      #$0023
                    lbeq      L417D
                    cmpx      #$000F
                    lbeq      L4199
                    cmpx      #$0021
                    lbeq      L41A8
                    cmpx      #$0022
                    lbeq      L41A8
                    cmpx      #$000E
                    lbeq      L41C4
                    cmpx      #$000C
                    lbeq      L41C4
                    bra       L422B

L4265               ldd       $0e,s
L4267               pshs      d
                    lbsr      L4407
                    lbra      L42DE

L426F               ldd       $0C,s
                    addd      $0e,s
                    std       $0C,s
                    pshs      d
                    lbsr      L4407
                    leas      $02,s
                    ldd       #$002C
                    pshs      d
                    lbsr      L43E7
                    leas      $02,s
                    ldd       $0a,s
                    anda      #$7f
                    tfr       d,x
                    bra       L42A5

L428E               ldd       #$0078
                    bra       L429B

L4293               ldd       #$0079
                    bra       L429B

L4298               ldd       #$0075
L429B               pshs      d
                    lbsr      L43E7
                    leas      $02,s
                    lbra      L431A

L42A5               cmpx      #$0093
                    beq       L428E
                    cmpx      #$0094
                    beq       L4293
                    cmpx      #$0095
                    beq       L4298
                    bra       L431A

L42B6               ldd       >$004f,y
                    pshs      d
                    lbsr      L43F6
                    leas      $02,s
                    leax      L47C5,pcr
                    pshs      x
                    lbsr      L43F6
                    leas      $02,s
                    ldd       $000D
                    addd      #$0002
                    std       $000D
                    bra       L431A

L42D5               leax      L47C8,pcr
L42D9               pshs      x
                    lbsr      L4823
L42DE               leas      $02,s
                    bra       L431A

L42E2               cmpx      #$0077
                    lbeq      L40EE
                    cmpx      #$0036
                    lbeq      L4125
                    cmpx      #$0080
                    lbeq      L4134
                    cmpx      #$0034
                    lbeq      L4154
                    cmpx      #$0093
                    lbeq      L426F
                    cmpx      #$0094
                    lbeq      L426F
                    cmpx      #$0095
                    lbeq      L426F
                    cmpx      #$006E
                    beq       L42B6
                    bra       L42D5

L431A               ldd       $0a,s
                    anda      #$80
                    clrb
                    std       -$02,s
                    lbeq      L44A1
                    ldd       #$005D
                    pshs      d
                    lbsr      L43E7
L432D               leas      $02,s
                    lbra      L44A1

L4332               pshs      u
                    ldx       $04,s
                    bra       L4381

L4338               leax      L47D4,pcr
                    pshs      x
                    lbsr      L4823
                    leas      $02,s
L4343               leax      L47DB,pcr
                    bra       L437D

L4349               leax      L47DF,pcr
                    bra       L437D

L434F               leax      L47E3,pcr
                    bra       L437D

L4355               leax      L47E7,pcr
                    bra       L437D

L435B               leax      L47EB,pcr
                    bra       L437D

L4361               leax      L47EF,pcr
                    bra       L437D

L4367               leax      L47F3,pcr
                    bra       L437D

L436D               leax      L47F7,pcr
                    bra       L437D

L4373               leax      L47FB,pcr
                    bra       L437D

L4379               leax      L47FF,pcr
L437D               tfr       x,d
                    puls      pc,u
L4381               cmpx      #$005A
                    beq       L4343
                    cmpx      #$005B
                    beq       L4349
                    cmpx      #$005C
                    beq       L434F
                    cmpx      #$005D
                    beq       L4355
                    cmpx      #$005E
                    beq       L435B
                    cmpx      #$005F
                    beq       L4361
                    cmpx      #$0060
                    beq       L4367
                    cmpx      #$0061
                    beq       L436D
                    cmpx      #$0062
                    beq       L4373
                    cmpx      #$0063
                    beq       L4379
                    lbra      L4338
                    puls      pc,u
L43B8               pshs      u
                    ldd       $0005
                    pshs      d
                    ldd       #$0020
                    pshs      d
                    lbsr      L515E
                    leas      $04,s
                    ldd       $04,s
                    pshs      d
                    bsr       L43F6
                    lbra      L446D

L43D1               pshs      u
                    ldd       $04,s
                    pshs      d
                    bsr       L43B8
                    lbra      L4487

L43DC               pshs      u
                    ldd       $0005
                    pshs      d
                    ldd       #$000D
                    bra       L43EF

L43E7               pshs      u
                    ldd       $0005
                    pshs      d
                    ldd       $06,s
L43EF               pshs      d
                    lbsr      L515E
                    bra       L4403

L43F6               pshs      u
                    ldd       $04,s
                    pshs      d
                    ldd       $0005
                    pshs      d
                    lbsr      fprintf
L4403               leas      $04,s
                    puls      pc,u
L4407               pshs      u
                    ldd       $04,s
                    pshs      d
                    leax      L4803,pcr
                    lbra      L4498

L4414               pshs      u
                    ldd       $04,s
                    pshs      d
                    bsr       L441F
                    lbra      L4487

L441F               pshs      u
                    ldd       #$005F
                    pshs      d
                    bsr       L43E7
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    bsr       L4407
                    bra       L446D

L4432               pshs      u
                    ldd       $04,s
                    pshs      d
                    leax      L4806,pcr
                    lbra      L4498

L443F               pshs      u,d
                    ldd       $06,s
                    subd      $000D
                    std       ,s
                    beq       L446B
                    leax      L480B,pcr
                    pshs      x
                    lbsr      L43B8
                    leas      $02,s
                    ldd       ,s
                    pshs      d
                    lbsr      L4407
                    leas      $02,s
                    ldd       >$004f,y
                    pshs      d
                    lbsr      L43F6
                    leas      $02,s
                    lbsr      L43DC
L446B               ldd       $06,s
L446D               leas      $02,s
                    puls      pc,u
L4471               pshs      u
                    ldd       $04,s
                    pshs      d
                    bsr       L4432
                    leas      $02,s
                    ldd       $06,s
                    beq       L4489
                    ldd       #$003A
                    pshs      d
                    lbsr      L43E7
L4487               leas      $02,s
L4489               lbsr      L43DC
                    puls      pc,u
L448E               pshs      u
                    ldd       $04,s
                    pshs      d
                    leax      L4811,pcr
L4498               pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      fprintf
L44A1               leas      $06,s
                    puls      pc,u
L44A5               pshs      u
                    ldd       $04,s
                    pshs      d
                    bsr       L448E
                    leas      $02,s
                    ldd       $06,s
                    pshs      d
                    ldd       #$005F
                    pshs      d
                    leax      L4819,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      fprintf
                    leas      $08,s
                    puls      pc,u
                    fcb       $2C,$79
                    fcb       $00
                    fcb       $2C,$73
                    fcb       $00
L44CF               fcc       /lbsr /
                    fcb       $00
                    fcc       /lbra /
                    fcb       $00
                    fcc       /clra/
                    fcb       $00
                    fcc       /unknown operator : /
                    fcb       $00
L44F4               fcc       / pshs %c/
                    fcb       $0D,$00
L44FE               fcb       $6C,$62
                    fcb       $00
L4501               fcc       /puls u,pc/
                    fcb       $0D,$00
L450C               fcc       /ccmult/
                    fcb       $00
L4513               fcc       /ccudiv/
                    fcb       $00
L451A               fcc       /ccdiv/
                    fcb       $00
L4520               fcc       /ccasl/
                    fcb       $00
L4526               fcc       /ccasr/
                    fcb       $00
L452C               fcc       /cclsr/
                    fcb       $00
L4532               fcc       /ccumod/
                    fcb       $00
L4539               fcc       /ccmod/
                    fcb       $00
L453F               fcc       /nega/
                    fcb       $0D
                    fcc       / negb/
                    fcb       $0D
                    fcc       / sbca #0/
                    fcb       $00
L4553               fcc       /coma/
                    fcb       $0D
                    fcc       / comb/
                    fcb       $00
L455E               fcc       /leax /
                    fcb       $00
L4564               fcc       /leas /
                    fcb       $00
L456A               fcb       $2C,$78
                    fcb       $0D,$00
L456E               fcc       /jsr /
                    fcb       $00
L4573               fcb       $73,$65,$78
                    fcb       $00
L4577               fcb       $6C,$64
                    fcb       $00
L457A               fcc       /aslb/
                    fcb       $0D
                    fcc       / rola/
                    fcb       $00
L4585               fcc       /asra/
                    fcb       $0D
                    fcc       / rorb/
                    fcb       $00
L4590               fcc       /lsra/
                    fcb       $0D
                    fcc       / rorb/
                    fcb       $00
L459B               fcc       /ldy /
                    fcb       $00
L45A0               fcc       /ldu /
                    fcb       $00
L45A5               fcc       /leax /
                    fcb       $00
L45AB               fcc       /%d,%c/
                    fcb       $0D,$00
L45B2               fcc       /d,%c/
                    fcb       $0D,$00
L45B8               fcb       $73,$65,$78
                    fcb       $00
L45BC               fcc       /adca #0/
                    fcb       $00
L45C4               fcc       /sbca #0/
                    fcb       $00
L45CC               fcc       /%d,%c/
                    fcb       $0D,$00
L45D3               fcc       /clra/
                    fcb       $0D
                    fcc       / clrb/
                    fcb       $00
L45DE               fcb       $6C,$64
                    fcb       $00
L45E1               fcc       / st%c -2,s/
                    fcb       $0D,$00
L45ED               fcb       $63,$6D,$70
                    fcb       $00
L45F1               fcb       $73,$74
                    fcb       $00
L45F4               fcb       $73,$75,$62
                    fcb       $00
L45F8               fcb       $61,$64,$64
                    fcb       $00
L45FC               fcb       $6C,$65,$61
                    fcb       $00
L4600               fcc       / exg %c,%c/
                    fcb       $0D,$00
L460C               fcb       $64,$2C
                    fcb       $00
L460F               fcc       /LEA arg/
                    fcb       $00
L4617               fcc       / tfr %c,%c/
                    fcb       $0D,$00
L4623               fcc       /lda 0,x/
                    fcb       $0D
                    fcc       / ora 1,x/
                    fcb       $0D
                    fcc       / ora 2,x/
                    fcb       $0D
                    fcc       / ora 3,x/
                    fcb       $00
L4646               fcc       /_lmove/
                    fcb       $00
L464D               fcc       /_ladd/
                    fcb       $00
L4653               fcc       /_lsub/
                    fcb       $00
L4659               fcc       /_lmul/
                    fcb       $00
L465F               fcc       /_ldiv/
                    fcb       $00
L4665               fcc       /_lmod/
                    fcb       $00
L466B               fcc       /_land/
                    fcb       $00
L4671               fcc       /_lor/
                    fcb       $00
L4676               fcc       /_lxor/
                    fcb       $00
L467C               fcc       /_lshl/
                    fcb       $00
L4682               fcc       /_lshr/
                    fcb       $00
L4688               fcc       /_lcmpr/
                    fcb       $00
L468F               fcc       /_lneg/
                    fcb       $00
L4695               fcc       /_lcompl/
                    fcb       $00
L469D               fcc       /_litol/
                    fcb       $00
L46A4               fcc       /_lutol/
                    fcb       $00
L46AB               fcc       /_linc/
                    fcb       $00
L46B1               fcc       /_ldec/
                    fcb       $00
L46B7               fcc       /codgen - longs/
                    fcb       $00
L46C6               fcc       /_dstack/
                    fcb       $00
L46CE               fcc       / lda %c,x/
                    fcb       $0D,$00
L46D9               fcc       /_fmove/
                    fcb       $00
L46E0               fcc       /_dmove/
                    fcb       $00
L46E7               fcc       /_dadd/
                    fcb       $00
L46ED               fcc       /_dsub/
                    fcb       $00
L46F3               fcc       /_dmul/
                    fcb       $00
L46F9               fcc       /_ddiv/
                    fcb       $00
L46FF               fcc       /_dcmpr/
                    fcb       $00
L4706               fcc       /_dneg/
                    fcb       $00
L470C               fcc       /_finc/
                    fcb       $00
L4712               fcc       /_dinc/
                    fcb       $00
L4718               fcc       /_fdec/
                    fcb       $00
L471E               fcc       /_ddec/
                    fcb       $00
L4724               fcc       /_dtof/
                    fcb       $00
L472A               fcc       /_ftod/
                    fcb       $00
L4730               fcc       /_ltod/
                    fcb       $00
L4736               fcc       /_itod/
                    fcb       $00
L473C               fcc       /_utod/
                    fcb       $00
L4742               fcc       /_dtol/
                    fcb       $00
L4748               fcc       /_dtoi/
                    fcb       $00
L474E               fcc       /codgen - floats/
                    fcb       $00
L475E               fcc       /bsr /
                    fcb       $00
L4763               fcc       /puls x/
                    fcb       $00
L476A               fcb       $30,$2C
                    fcb       $00
L476D               fcb       $61,$6E,$64
                    fcb       $00
L4771               fcb       $6F,$72
                    fcb       $00
L4774               fcb       $65,$6F,$72
                    fcb       $00
L4778               fcc       /coma/
                    fcb       $00
L477D               fcc       /clrb/
                    fcb       $00
L4782               fcc       /comb/
                    fcb       $00
L4787               fcc       / %sa ,s+/
                    fcb       $0D
                    fcc       / %sb ,s+/
                    fcb       $0D,$00
L479A               fcc       /compiler trouble/
                    fcb       $00
L47AB               fcc       /_flacc/
                    fcb       $00
L47B2               fcc       /,pcr/
                    fcb       $00
L47B7               fcc       /storage error/
                    fcb       $00
L47C5               fcb       $2B,$2B
                    fcb       $00
L47C8               fcc       /dereference/
                    fcb       $00
L47D4               fcc       /rel op/
                    fcb       $00
L47DB               fcb       $65,$71,$20
                    fcb       $00
L47DF               fcb       $6E,$65,$20
                    fcb       $00
L47E3               fcb       $6C,$65,$20
                    fcb       $00
L47E7               fcb       $6C,$74,$20
                    fcb       $00
L47EB               fcb       $67,$65,$20
                    fcb       $00
L47EF               fcb       $67,$74,$20
                    fcb       $00
L47F3               fcb       $6C,$73,$20
                    fcb       $00
L47F7               fcb       $6C,$6F,$20
                    fcb       $00
L47FB               fcb       $68,$73,$20
                    fcb       $00
L47FF               fcb       $68,$69,$20
                    fcb       $00
L4803               fcb       $25,$64
                    fcb       $00
L4806               fcc       /%.8s/
                    fcb       $00
L480B               fcc       /leas /
                    fcb       $00
L4811               fcc       / lea%c /
                    fcb       $00
L4819               fcc       /%c%d,pcr/
                    fcb       $0D,$00
L4823               pshs      u
                    ldd       $04,s
                    pshs      d
                    ldd       $0282,y
                    pshs      d
                    bsr       L484B
                    lbra      L4AC9

L4834               pshs      u
                    leax      L4B2E,pcr
                    pshs      x
                    ldd       $0282,y
                    pshs      d
                    bsr       L487F
                    leas      $04,s
                    lbsr      L0ADF
                    puls      pc,u
L484B               pshs      u
                    leas      -$32,s
                    leax      L4B3C,pcr
                    pshs      x
                    leax      $02,s
                    pshs      x
                    lbsr      L55FF
                    leas      $04,s
                    ldd       $38,s
                    pshs      d
                    leax      $02,s
                    pshs      x
                    lbsr      L5617
                    leas      $04,s
                    leax      ,s
                    pshs      x
                    ldd       $38,s
                    pshs      d
                    bsr       L487F
                    leas      $04,s
                    leas      $32,s
                    puls      pc,u
L487F               pshs      u
                    ldu       $04,s
                    ldd       $0e,u
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       $10,u
                    pshs      d
                    lbsr      L4938
                    lbra      L4ADE

L4896               pshs      u
                    ldd       $02DA,y
                    addd      #$0001
                    pshs      d
                    ldd       #$000A
                    lbsr      L5EF0
                    std       $02DA,y
                    cmpd      $02DC,y
                    bne       L48C5
                    ldd       $02DC,y
                    addd      #$0001
                    pshs      d
                    ldd       #$000A
                    lbsr      L5EF0
                    std       $02DC,y
L48C5               ldd       $02DA,y
                    pshs      d
                    ldd       #$0006
                    lbsr      L5E8F
                    leax      $029e,y
                    leax      d,x
                    leau      ,x
                    ldd       $04,s
                    std       ,u
                    leax      $02,u
                    pshs      x
                    leax      $08,s
                    lbsr      L5E23
                    puls      pc,u
L48E8               pshs      u,d
                    ldd       $02DA,y
                    bra       L4919

L48F0               ldd       ,s
                    pshs      d
                    ldd       #$0006
                    lbsr      L5E8F
                    leax      $029e,y
                    leax      d,x
                    leau      ,x
                    ldd       ,u
                    cmpd      $06,s
                    bne       L490D
                    leax      $02,u
                    bra       L492C

L490D               ldd       ,s
                    addd      #$FFFF
                    std       ,s
                    bge       L491B
                    ldd       #$0009
L4919               std       ,s
L491B               ldd       ,s
                    cmpd      $02DC,y
                    bne       L48F0
                    bsr       L492A
                    fcb       $FF,$FF,$FF,$FF
L492A               puls      x
L492C               leau      $0254,y
                    pshs      u
                    lbsr      L5E23
                    lbra      L4A86

L4938               pshs      u
                    leas      -$05,s
                    leax      $0262,y
                    pshs      x
                    leax      L4B4E,pcr
                    pshs      x
                    lbsr      L2D3F
                    leas      $04,s
                    ldd       $09,s
                    pshs      d
                    ldd       $0f,s
                    pshs      d
                    leax      L4B53,pcr
                    pshs      x
                    lbsr      L2D3F
                    leas      $06,s
                    ldd       $0b,s
                    pshs      d
                    leax      L4B5D,pcr
                    pshs      x
                    lbsr      L2D3F
                    leas      $04,s
                    ldd       $02DE,y
                    bne       L498C
                    leax      L4B6D,pcr
                    pshs      x
                    ldd       $0280,y
                    pshs      d
                    lbsr      L4F06
                    leas      $04,s
                    std       $02DE,y
                    beq       L49B1
L498C               leax      $01,s
                    pshs      x
                    ldd       $0f,s
                    pshs      d
                    lbsr      L48E8
                    leas      $02,s
                    lbsr      L5E23
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    bsr       L49AA
                    fcb       $FF,$FF,$FF,$FF
L49AA               puls      x
                    lbsr      L5DBF
                    bne       L49B6
L49B1               leax      $05,s
                    lbra      L4A30

L49B6               clra
                    clrb
                    pshs      d
                    leax      $03,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $02DE,y
                    pshs      d
                    lbsr      L4F9E
                    leas      $08,s
L49CF               leax      $00CE,y
                    pshs      x
                    ldd       $02DE,y
                    pshs      d
                    lbsr      L5375
                    leas      $02,s
                    stb       $02,s
                    sex
                    pshs      d
                    lbsr      L515E
                    leas      $04,s
                    ldb       ,s
                    cmpb      #$0d
                    bne       L49CF
                    bra       L4A02

L49F2               leax      $00CE,y
                    pshs      x
                    ldd       #$0020
                    pshs      d
                    lbsr      L515E
                    leas      $04,s
L4A02               ldd       $09,s
                    addd      #$FFFF
                    std       $09,s
                    subd      #$FFFF
                    bgt       L49F2
                    leax      $00CE,y
                    pshs      x
                    ldd       #$005E
                    pshs      d
                    lbsr      L515E
                    leas      $04,s
                    leax      $00CE,y
                    pshs      x
                    ldd       #$000D
                    pshs      d
                    lbsr      L515E
                    leas      $04,s
                    bra       L4A32

L4A30               leas      -$05,x
L4A32               ldd       $0009
                    addd      #$0001
                    std       $0009
                    cmpd      #_start
                    ble       L4A65
                    leax      $00CE,y
                    pshs      x
                    lbsr      L5289
                    leas      $02,s
                    leax      L4B6F,pcr
                    pshs      x
                    leax      $00DB,y
                    pshs      x
                    lbsr      fprintf
                    leas      $04,s
                    ldd       #$0001
                    pshs      d
                    lbsr      exit
                    leas      $02,s
L4A65               leas      $05,s
                    puls      pc,u
L4A69               pshs      u
                    ldu       $04,s
                    stu       -$02,s
                    beq       L4A88
                    ldd       $0a,u
                    pshs      d
                    bsr       L4A69
                    leas      $02,s
                    ldd       $0C,u
                    pshs      d
                    lbsr      L4A69
                    leas      $02,s
                    pshs      u
                    bsr       L4A8A
L4A86               leas      $02,s
L4A88               puls      pc,u
L4A8A               pshs      u
                    ldu       $04,s
                    stu       -$02,s
                    beq       L4ACB
                    ldx       $06,u
                    bra       L4AB0

L4A96               ldd       #$000D
                    bra       L4AA3

L4A9B               ldd       #$0008
                    bra       L4AA3

L4AA0               ldd       #$0004
L4AA3               pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L3203
                    leas      $04,s
                    bra       L4ABF

L4AB0               cmpx      #$0034
                    beq       L4A96
                    cmpx      #$004B
                    beq       L4A9B
                    cmpx      #$004A
                    beq       L4AA0
L4ABF               ldd       #$0016
                    pshs      d
                    pshs      u
                    lbsr      L3203
L4AC9               leas      $04,s
L4ACB               puls      pc,u
L4ACD               pshs      u
                    ldd       #$0016
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    bsr       L4B10
L4ADE               leas      $06,s
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
L4AF7               pshs      u
                    ldu       $04,s
                    cmpu      #$004C
                    blt       L4B0C
                    cmpu      #$0063
                    bgt       L4B0C
                    ldd       #$0001
                    bra       L4B0E

L4B0C               clra
                    clrb
L4B0E               puls      pc,u
L4B10               pshs      u
                    ldu       $04,s
                    bra       L4B20

L4B16               ldb       ,u+
                    ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    stb       -$01,x
L4B20               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bne       L4B16
                    puls      pc,u
L4B2E               fcc       /out of memory/
                    fcb       $00
L4B3C               fcc       /compiler error - /
                    fcb       $00
L4B4E               fcc       /%s: /
                    fcb       $00
L4B53               fcc       /line %d  /
                    fcb       $00
L4B5D               fcc       /****  %s  ****/
                    fcb       $0D,$00
L4B6D               fcb       $72
                    fcb       $00
L4B6F               fcc       /too many errors - ABORT/
                    fcb       $0D,$00
L4B88               pshs      u
                    leax      L4D06,pcr
                    pshs      x
                    lbsr      L43B8
                    lbra      L4C8E

L4B96               pshs      u
                    ldu       $04,s
                    pshs      u
                    leax      L4D0B,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      fprintf
                    leas      $06,s
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    lbsr      L4471
                    leas      $04,s
                    clra
                    clrb
                    std       $000D
                    std       $000F
                    std       L0017
                    leax      L4D16,pcr
                    pshs      x
                    lbsr      L43D1
                    leas      $02,s
                    ldd       $0011
                    bne       L4BE2
                    ldd       $08,s
                    std       $0025
                    pshs      d
                    leax      L4D1D,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      fprintf
                    leas      $06,s
L4BE2               ldd       $0013
                    lbeq      L4C90
                    leax      L4D38,pcr
                    pshs      x
                    lbsr      L43B8
                    leas      $02,s
                    ldd       $0a,s
                    pshs      d
                    lbsr      L441F
                    leas      $02,s
                    leax      L4D3E,pcr
                    pshs      x
                    lbsr      L43F6
                    leas      $02,s
                    pshs      u
                    lbsr      L4432
                    leas      $02,s
                    leax      L4D52,pcr
                    pshs      x
                    lbsr      L43F6
                    lbra      L4C8E

L4C1A               pshs      u
                    ldd       $0011
                    bne       L4C3C
                    ldd       L0017
                    subd      $000F
                    addd      #$FFC0
                    pshs      d
                    ldd       $0025
                    pshs      d
                    leax      L4D76,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      fprintf
                    leas      $08,s
L4C3C               puls      pc,u
L4C3E               pshs      u
                    ldd       $04,s
                    beq       L4C4A
                    leax      L4D83,pcr
                    bra       L4C4E

L4C4A               leax      L4D8C,pcr
L4C4E               tfr       x,d
                    pshs      d
                    bra       L4C5C

L4C54               pshs      u
                    leax      L4D92,pcr
                    pshs      x
L4C5C               lbsr      L43D1
                    bra       L4C8E

L4C61               pshs      u,d
                    ldd       $0003
                    pshs      d
                    lbsr      L53D7
                    std       ,s
                    lbsr      L441F
                    bra       L4C77

L4C71               ldd       ,s
                    pshs      d
                    bsr       L4C92
L4C77               leas      $02,s
                    ldd       $0003
                    pshs      d
                    lbsr      L5375
                    leas      $02,s
                    std       ,s
                    bne       L4C71
                    clra
                    clrb
                    pshs      d
                    bsr       L4C92
                    leas      $02,s
L4C8E               leas      $02,s
L4C90               puls      pc,u
L4C92               pshs      u
                    ldd       $02E0,y
                    bne       L4CA9
                    leax      L4D9A,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      fprintf
                    leas      $04,s
L4CA9               ldd       $04,s
                    cmpd      #$0020
                    blt       L4CB9
                    ldd       $04,s
                    cmpd      #$0022
                    bne       L4CCE
L4CB9               ldd       $04,s
                    pshs      d
                    leax      L4DA1,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      fprintf
                    leas      $06,s
                    bra       L4CFE

L4CCE               ldd       $0005
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L515E
                    leas      $04,s
                    ldd       $02E0,y
                    addd      #$0001
                    std       $02E0,y
                    subd      #$0001
                    cmpd      #$004B
                    blt       L4D04
                    leax      L4DAD,pcr
                    pshs      x
                    ldd       $0005
                    pshs      d
                    lbsr      fprintf
                    leas      $04,s
L4CFE               clra
                    clrb
                    std       $02E0,y
L4D04               puls      pc,u
L4D06               fcc       /fdb /
                    fcb       $00
L4D0B               fcc       / ttl %.8s/
                    fcb       $0D,$00
L4D16               fcc       /pshs u/
                    fcb       $00
L4D1D               fcc       / ldd #_%d/
                    fcb       $0D
                    fcc       / lbsr _stkcheck/
                    fcb       $0D,$00
L4D38               fcc       /leax /
                    fcb       $00
L4D3E               fcc       /,pcr/
                    fcb       $0D
                    fcc       / pshs x/
                    fcb       $0D
                    fcc       / leax /
                    fcb       $00
L4D52               fcc       /,pcr/
                    fcb       $0D
                    fcc       / pshs x/
                    fcb       $0D
                    fcc       / lbsr _prof/
                    fcb       $0D
                    fcc       / leas 4,s/
                    fcb       $0D,$00
L4D76               fcc       /_%d equ %d/
                    fcb       $0D,$0D,$00
L4D83               fcc       /vsect dp/
                    fcb       $00
L4D8C               fcc       /vsect/
                    fcb       $00
L4D92               fcc       /endsect/
                    fcb       $00
L4D9A               fcc       / fcc "/
                    fcb       $00
L4DA1               fcb       $22
                    fcb       $0D
                    fcc       / fcb $%x/
                    fcb       $0D,$00
L4DAD               fcb       $22
                    fcb       $0D,$00
L4DB0               pshs      u
                    leau      $00C1,y
L4DB6               ldd       $06,u
                    clra
                    andb      #$03
                    lbeq      L4E27
                    leau      $0d,u
                    pshs      u
                    leax      $0191,y
                    cmpx      ,s++
                    bhi       L4DB6
                    ldd       #$00C8
                    std       $0260,y
                    lbra      L4E2B
                    puls      pc,u
L4DD7               pshs      u
                    ldu       $08,s
                    bne       L4DE1
                    bsr       L4DB0
                    tfr       d,u
L4DE1               stu       -$02,s
                    beq       L4E2B
                    ldd       $04,s
                    std       $08,u
                    ldx       $06,s
                    ldb       $01,x
                    cmpb      #$2b
                    beq       L4DF9
                    ldx       $06,s
                    ldb       $02,x
                    cmpb      #$2b
                    bne       L4DFF
L4DF9               ldd       $06,u
                    orb       #$03
                    bra       L4E1D

L4DFF               ldd       $06,u
                    pshs      d
                    ldb       [$08,s]
                    cmpb      #$72
                    beq       L4E11
                    ldb       [$08,s]
                    cmpb      #$64
                    bne       L4E16
L4E11               ldd       #$0001
                    bra       L4E19

L4E16               ldd       #$0002
L4E19               ora       ,s+
                    orb       ,s+
L4E1D               std       $06,u
                    ldd       $02,u
                    addd      $0b,u
                    std       $04,u
                    std       ,u
L4E27               tfr       u,d
                    puls      pc,u
L4E2B               clra
                    clrb
                    puls      pc,u
L4E2F               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    clra
                    clrb
                    std       ,s
                    ldx       $0a,s
                    ldb       $01,x
                    sex
                    tfr       d,x
                    bra       L4E60

L4E42               ldx       $0a,s
                    ldb       $02,x
                    cmpb      #$2b
                    bne       L4E4F
                    ldd       #$0007
                    bra       L4E57

L4E4F               ldd       #$0004
                    bra       L4E57

L4E54               ldd       #$0003
L4E57               std       ,s
                    bra       L4E70

L4E5B               leax      $04,s
                    lbra      L4EC8

L4E60               stx       -$02,s
                    beq       L4E70
                    cmpx      #$0078
                    beq       L4E42
                    cmpx      #$002B
                    beq       L4E54
                    bra       L4E5B

L4E70               ldb       [$0a,s]
                    sex
                    tfr       d,x
                    lbra      L4ED5

L4E79               ldd       ,s
                    orb       #$01
                    bra       L4EBB

L4E7F               ldd       ,s
                    orb       #$02
                    pshs      d
                    pshs      u
                    lbsr      L605A
                    leas      $04,s
                    std       $02,s
                    cmpd      #$FFFF
                    beq       L4EAA
                    ldd       #$0002
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L6130
                    leas      $08,s
                    bra       L4EEF

L4EAA               ldd       ,s
                    orb       #$02
                    pshs      d
                    pshs      u
                    lbsr      L607B
                    bra       L4EC2

L4EB7               ldd       ,s
                    orb       #$81
L4EBB               pshs      d
                    pshs      u
                    lbsr      L605A
L4EC2               leas      $04,s
                    std       $02,s
                    bra       L4EEF

L4EC8               leas      -$04,x
L4ECA               ldd       #$00CB
                    std       $0260,y
                    clra
                    clrb
                    bra       L4EF1

L4ED5               cmpx      #$0072
                    lbeq      L4E79
                    cmpx      #$0061
                    lbeq      L4E7F
                    cmpx      #$0077
                    beq       L4EAA
                    cmpx      #$0064
                    beq       L4EB7
                    bra       L4ECA

L4EEF               ldd       $02,s
L4EF1               leas      $04,s
                    puls      pc,u
                    pshs      u
                    clra
                    clrb
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbra      L4F51

L4F06               pshs      u
                    ldd       $06,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L4E2F
                    leas      $04,s
                    tfr       d,u
                    cmpu      #$FFFF
                    bne       L4F21
                    clra
                    clrb
                    bra       L4F56

L4F21               clra
                    clrb
                    bra       L4F49
                    pshs      u
                    ldd       $08,s
                    pshs      d
                    lbsr      L524F
                    leas      $02,s
                    ldd       $06,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L4E2F
                    leas      $04,s
                    tfr       d,u
                    stu       -$02,s
                    bge       L4F47
                    clra
                    clrb
                    bra       L4F56

L4F47               ldd       $08,s
L4F49               pshs      d
                    ldd       $08,s
                    pshs      d
                    pshs      u
L4F51               lbsr      L4DD7
                    leas      $06,s
L4F56               puls      pc,u
L4F58               pshs      u
                    ldu       $04,s
                    leas      -$06,s
                    clra
                    clrb
                    bra       L4F8F

L4F62               ldd       $0C,s
                    std       $04,s
                    bra       L4F7E

L4F68               ldd       $10,s
                    pshs      d
                    lbsr      L5375
                    leas      $02,s
                    std       ,s
                    cmpd      #$FFFF
                    beq       L4F98
                    ldd       ,s
                    stb       ,u+
L4F7E               ldd       $04,s
                    addd      #$FFFF
                    std       $04,s
                    subd      #$FFFF
                    bgt       L4F68
                    ldd       $02,s
                    addd      #$0001
L4F8F               std       $02,s
                    ldd       $02,s
                    cmpd      $0e,s
                    blt       L4F62
L4F98               ldd       $02,s
                    leas      $06,s
                    puls      pc,u
L4F9E               pshs      u
                    ldu       $04,s
                    leas      -$06,s
                    cmpu      #$0000
                    beq       L4FB1
                    ldd       $06,u
                    clra
                    andb      #$03
                    bne       L4FB7
L4FB1               ldd       #$FFFF
                    lbra      L50DA

L4FB7               ldd       $06,u
                    anda      #$80
                    clrb
                    std       -$02,s
                    bne       L4FCA
                    pshs      u
                    lbsr      L54C9
                    leas      $02,s
                    lbra      L50A0

L4FCA               ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    beq       L4FE9
                    pshs      u
                    lbsr      L5289
                    leas      $02,s
                    ldd       $06,u
                    anda      #$FE
                    std       $06,u
                    ldd       $02,u
                    addd      $0b,u
                    std       $04,u
                    lbra      L509E

L4FE9               ldd       ,u
                    cmpd      $04,u
                    lbcc      L50A0
                    leax      $02,s
                    pshs      x
                    leax      $0e,s
                    lbsr      L5E23
                    ldx       $10,s
                    lbra      L506D

L5001               leax      $02,s
                    pshs      x
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    pshs      u
                    lbsr      L50F5
                    leas      $02,s
                    lbsr      L5DAA
                    lbsr      L5E23
L501A               ldd       $0b,u
                    lbsr      L5E0A
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    leax      $06,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    bsr       L5037
                    fcb       $00,$00,$00,$00
L5037               puls      x
                    lbsr      L5DBF
                    bge       L5045
                    leax      $06,s
                    lbsr      L5DE3
                    bra       L5047

L5045               leax      $06,s
L5047               lbsr      L5DBF
                    blt       L507A
                    ldd       $04,s
                    addd      ,u
                    std       ,s
                    cmpd      $02,u
                    bcs       L507A
                    ldd       ,s
                    cmpd      $04,u
                    bcc       L507A
                    ldd       ,s
                    std       ,u
                    ldd       $06,u
                    andb      #$EF
                    std       $06,u
                    lbra      L50D8
                    bra       L507A

L506D               stx       -$02,s
                    lbeq      L5001
                    cmpx      #$0001
                    lbeq      L501A
L507A               ldd       $10,s
                    cmpd      #$0001
                    bne       L509C
                    leax      $0C,s
                    pshs      x
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $04,u
                    subd      ,u
                    lbsr      L5E0A
                    lbsr      L5DAA
                    lbsr      L5E23
L509C               ldd       $04,u
L509E               std       ,u
L50A0               ldd       $06,u
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
                    lbsr      L6130
                    leas      $08,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    bsr       L50CC
                    fcb       $FF,$FF,$FF,$FF
L50CC               puls      x
                    lbsr      L5DBF
                    bne       L50D8
                    ldd       #$FFFF
                    bra       L50DA

L50D8               clra
                    clrb
L50DA               leas      $06,s
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
                    lbsr      L4F9E
                    leas      $08,s
                    puls      pc,u
L50F5               pshs      u
                    ldu       $04,s
                    beq       L5102
                    ldd       $06,u
                    clra
                    andb      #$03
                    bne       L5115
L5102               bsr       L5108
                    fcb       $FF,$FF,$FF,$FF
L5108               puls      x
                    leau      $0254,y
                    pshs      u
                    lbsr      L5E23
                    puls      pc,u
L5115               ldd       $06,u
                    anda      #$80
                    clrb
                    std       -$02,s
                    bne       L5125
                    pshs      u
                    lbsr      L54C9
                    leas      $02,s
L5125               ldd       #$0001
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L6130
                    leas      $08,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    beq       L514E
                    ldd       $02,u
                    bra       L5150

L514E               ldd       $04,u
L5150               pshs      d
                    ldd       ,u
                    subd      ,s++
                    lbsr      L5E0A
                    lbsr      L5D95
                    puls      pc,u
L515E               pshs      u
                    ldu       $06,s
                    ldd       $06,u
                    anda      #$80
                    andb      #$22
                    cmpd      #$8002
                    beq       L5182
                    ldd       $06,u
                    clra
                    andb      #$22
                    cmpd      #$0002
                    lbne      L529A
                    pshs      u
                    lbsr      L54C9
                    leas      $02,s
L5182               ldd       $06,u
                    clra
                    andb      #$04
                    beq       L51BE
                    ldd       #$0001
                    pshs      d
                    leax      $07,s
                    pshs      x
                    ldd       $08,u
                    pshs      d
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L51A3
                    leax      L6120,pcr
                    bra       L51A7

L51A3               leax      L6107,pcr
L51A7               tfr       x,d
                    tfr       d,x
                    jsr       ,x
                    leas      $06,s
                    cmpd      #$FFFF
                    bne       L51FF
                    ldd       $06,u
                    orb       #$20
                    std       $06,u
                    lbra      L529A

L51BE               ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       L51CE
                    pshs      u
                    lbsr      L52B7
                    leas      $02,s
L51CE               ldd       ,u
                    addd      #$0001
                    std       ,u
                    subd      #$0001
                    tfr       d,x
                    ldd       $04,s
                    stb       ,x
                    ldd       ,u
                    cmpd      $04,u
                    bcc       L51F4
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L51FF
                    ldd       $04,s
                    cmpd      #$000D
                    bne       L51FF
L51F4               pshs      u
                    lbsr      L52B7
                    std       ,s++
                    lbne      L529A
L51FF               ldd       $04,s
                    puls      pc,u
                    pshs      u
                    ldu       $04,s
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    ldd       #$0008
                    lbsr      L5FB9
                    pshs      d
                    lbsr      L515E
                    leas      $04,s
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    lbsr      L515E
                    lbra      L5371

L5226               pshs      u,d
                    leau      $00C1,y
                    clra
                    clrb
                    std       ,s
                    bra       L523C

L5232               tfr       u,d
                    leau      $0d,u
                    pshs      d
                    bsr       L524F
                    leas      $02,s
L523C               ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    cmpd      #$0010
                    blt       L5232
                    lbra      L52B3

L524F               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    cmpu      #$0000
                    beq       L525F
                    ldd       $06,u
                    bne       L5265
L525F               ldd       #$FFFF
                    lbra      L52B3

L5265               ldd       $06,u
                    clra
                    andb      #$02
                    beq       L5274
                    pshs      u
                    bsr       L5289
                    leas      $02,s
                    bra       L5276

L5274               clra
                    clrb
L5276               std       ,s
                    ldd       $08,u
                    pshs      d
                    lbsr      L6069
                    leas      $02,s
                    clra
                    clrb
                    std       $06,u
                    ldd       ,s
                    bra       L52B3

L5289               pshs      u
                    ldu       $04,s
                    beq       L529A
                    ldd       $06,u
                    clra
                    andb      #$22
                    cmpd      #$0002
                    beq       L529F
L529A               ldd       #$FFFF
                    puls      pc,u
L529F               ldd       $06,u
                    anda      #$80
                    clrb
                    std       -$02,s
                    bne       L52AF
                    pshs      u
                    lbsr      L54C9
                    leas      $02,s
L52AF               pshs      u
                    bsr       L52B7
L52B3               leas      $02,s
                    puls      pc,u
L52B7               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       L52E9
                    ldd       ,u
                    cmpd      $04,u
                    beq       L52E9
                    clra
                    clrb
                    pshs      d
                    pshs      u
                    lbsr      L50F5
                    leas      $02,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L6130
                    leas      $08,s
L52E9               ldd       ,u
                    subd      $02,u
                    std       $02,s
                    lbeq      L5361
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    lbeq      L5361
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L5338
                    ldd       $02,u
                    bra       L5330

L5309               ldd       $02,s
                    pshs      d
                    ldd       ,u
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L6120
                    leas      $06,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       L5326
                    leax      $04,s
                    bra       L5350

L5326               ldd       $02,s
                    subd      ,s
                    std       $02,s
                    ldd       ,u
                    addd      ,s
L5330               std       ,u
                    ldd       $02,s
                    bne       L5309
                    bra       L5361

L5338               ldd       $02,s
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L6107
                    leas      $06,s
                    cmpd      $02,s
                    beq       L5361
                    bra       L5352

L5350               leas      -$04,x
L5352               ldd       $06,u
                    orb       #$20
                    std       $06,u
                    ldd       $04,u
                    std       ,u
                    ldd       #$FFFF
                    bra       L5371

L5361               ldd       $06,u
                    ora       #$01
                    std       $06,u
                    ldd       $02,u
                    std       ,u
                    addd      $0b,u
                    std       $04,u
                    clra
                    clrb
L5371               leas      $04,s
                    puls      pc,u
L5375               pshs      u
                    ldu       $04,s
                    beq       L53C1
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       L53C1
                    ldd       ,u
                    cmpd      $04,u
                    bcc       L539D
                    ldd       ,u
                    addd      #$0001
                    std       ,u
                    subd      #$0001
                    tfr       d,x
                    ldb       ,x
                    clra
                    lbra      L54C7

L539D               pshs      u
                    lbsr      L5410
                    lbra      L54C5
                    pshs      u
                    ldu       $06,s
                    beq       L53C1
                    ldd       $06,u
                    clra
                    andb      #$01
                    beq       L53C1
                    ldd       $04,s
                    cmpd      #$FFFF
                    beq       L53C1
                    ldd       ,u
                    cmpd      $02,u
                    bhi       L53C6
L53C1               ldd       #$FFFF
                    puls      pc,u
L53C6               ldd       ,u
                    addd      #$FFFF
                    std       ,u
                    tfr       d,x
                    ldd       $04,s
                    stb       ,x
                    ldd       $04,s
                    puls      pc,u
L53D7               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    pshs      u
                    lbsr      L5375
                    leas      $02,s
                    std       $02,s
                    cmpd      #$FFFF
                    beq       L53FB
                    pshs      u
                    lbsr      L5375
                    leas      $02,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       L5400
L53FB               ldd       #$FFFF
                    bra       L540C

L5400               ldd       $02,s
                    pshs      d
                    ldd       #$0008
                    lbsr      L5FD0
                    addd      ,s
L540C               leas      $04,s
                    puls      pc,u
L5410               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    ldd       $06,u
                    anda      #$80
                    andb      #$31
                    cmpd      #$8001
                    beq       L5436
                    ldd       $06,u
                    clra
                    andb      #$31
                    cmpd      #$0001
                    lbne      L54AF
                    pshs      u
                    lbsr      L54C9
                    leas      $02,s
L5436               leax      $00C1,y
                    pshs      x
                    cmpu      ,s++
                    bne       L5453
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L5453
                    leax      $00CE,y
                    pshs      x
                    lbsr      L5289
                    leas      $02,s
L5453               ldd       $06,u
                    clra
                    andb      #$08
                    beq       L547F
                    ldd       $0b,u
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L5473
                    leax      L60F7,pcr
                    bra       L5477

L5473               leax      L60D6,pcr
L5477               tfr       x,d
                    tfr       d,x
                    jsr       ,x
                    bra       L5491

L547F               ldd       #$0001
                    pshs      d
                    leax      $0a,u
                    stx       $02,u
                    pshs      x
                    ldd       $08,u
                    pshs      d
                    lbsr      L60D6
L5491               leas      $06,s
                    std       ,s
                    ldd       ,s
                    bgt       L54B4
                    ldd       $06,u
                    pshs      d
                    ldd       $02,s
                    beq       L54A6
                    ldd       #$0020
                    bra       L54A9

L54A6               ldd       #$0010
L54A9               ora       ,s+
                    orb       ,s+
                    std       $06,u
L54AF               ldd       #$FFFF
                    bra       L54C5

L54B4               ldd       $02,u
                    addd      #$0001
                    std       ,u
                    ldd       $02,u
                    addd      ,s
                    std       $04,u
                    ldb       [$02,u]
                    clra
L54C5               leas      $02,s
L54C7               puls      pc,u
L54C9               pshs      u
                    ldu       $04,s
                    ldd       $06,u
                    clra
                    andb      #$C0
                    bne       L5501
                    leas      -$20,s
                    leax      ,s
                    pshs      x
                    ldd       $08,u
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    lbsr      L5FEB
                    leas      $06,s
                    ldd       $06,u
                    pshs      d
                    ldb       $02,s
                    bne       L54F5
                    ldd       #$0040
                    bra       L54F8

L54F5               ldd       #$0080
L54F8               ora       ,s+
                    orb       ,s+
                    std       $06,u
                    leas      $20,s
L5501               ldd       $06,u
                    ora       #$80
                    std       $06,u
                    clra
                    andb      #$0C
                    beq       L550E
                    puls      pc,u
L550E               ldd       $0b,u
                    bne       L5523
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L551E
                    ldd       #$0080
                    bra       L5521

L551E               ldd       #$0100
L5521               std       $0b,u
L5523               ldd       $02,u
                    bne       L5538
                    ldd       $0b,u
                    pshs      d
                    lbsr      L61EE
                    leas      $02,s
                    std       $02,u
                    cmpd      #$FFFF
                    beq       L5540
L5538               ldd       $06,u
                    orb       #$08
                    std       $06,u
                    bra       L554F

L5540               ldd       $06,u
                    orb       #$04
                    std       $06,u
                    leax      $0a,u
                    stx       $02,u
                    ldd       #$0001
                    std       $0b,u
L554F               ldd       $02,u
                    addd      $0b,u
                    std       $04,u
                    std       ,u
                    puls      pc,u
L5559               pshs      u
                    ldd       $0C,s
                    beq       L5595
                    ldd       $0e,s
                    beq       L557C
                    leax      $04,s
                    lbsr      L5D51
                    ldd       $14,s
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    leax      >$0059,y
                    leax      d,x
                    lbsr      L56A9
                    bra       L5597

L557C               leax      $04,s
                    lbsr      L5D51
                    ldd       $14,s
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    leax      >$0059,y
                    leax      d,x
                    lbsr      L56B1
                    bra       L5597

L5595               leax      $04,s
L5597               leau      $0254,y
                    pshs      u
                    lbsr      L5D78
                    puls      pc,u
L55A2               pshs      u
                    ldd       $0C,s
                    cmpd      #$0009
                    ble       L55D2
                    leax      $04,s
                    pshs      x
                    ldd       $10,s
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    ldd       #$000A
                    lbsr      L5F43
                    addd      #$0009
                    pshs      d
                    leax      $0a,s
                    lbsr      L5D51
                    lbsr      L5559
                    leas      $0C,s
                    lbsr      L5D78
L55D2               ldd       $0e,s
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    ldd       #$000A
                    lbsr      L5EF0
                    pshs      d
                    leax      $08,s
                    lbsr      L5D51
                    lbsr      L5559
                    leas      $0C,s
                    puls      pc,u
L55EE               pshs      u
                    ldu       $04,s
L55F2               ldb       ,u+
                    bne       L55F2
                    tfr       u,d
                    subd      $04,s
                    addd      #$FFFF
                    puls      pc,u
L55FF               pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
L5609               ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L5609
                    bra       L563E

L5617               pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
L5621               ldx       ,s
                    leax      $01,x
                    stx       ,s
                    ldb       -$01,x
                    bne       L5621
                    ldd       ,s
                    addd      #$FFFF
                    std       ,s
L5632               ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L5632
L563E               ldd       $06,s
                    leas      $02,s
                    puls      pc,u
                    pshs      u
                    ldu       $04,s
                    bra       L565A

L564A               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    bne       L5658
                    clra
                    clrb
                    puls      pc,u
L5658               leau      $01,u
L565A               ldb       ,u
                    sex
                    pshs      d
                    ldb       [$08,s]
                    sex
                    cmpd      ,s++
                    beq       L564A
                    ldb       [$06,s]
                    sex
                    pshs      d
                    ldb       ,u
                    sex
                    subd      ,s++
                    puls      pc,u
L5675               ldx       $02,s
                    lbsr      L5D51
                    bsr       L567D
                    rts

L567D               pshs      u
                    leas      -$1e,s
                    tfr       s,u
                    clr       $1d,u
                    clr       $19,u
                    lbsr      L58F7
                    lbra      L571C

L5690               ldd       ,x
                    eora      #$80
                    lbra      L5CB5
                    lbsr      L5B0F
                    lbsr      L57F1
                    lbra      L571C
                    lbsr      L5B0F
                    lbsr      L57C7
                    lbra      L571C

L56A9               lbsr      L5B0F
                    lbsr      L596A
                    bra       L571C

L56B1               lbsr      L5B0F
                    lbsr      L5996
                    bra       L571C

L56B9               lbsr      L5CB3
                    lbra      L5BB3
                    bsr       L56B9
                    ldd       $02,x
                    rts
                    ldd       ,x
                    std       $0254,y
                    ldd       $02,x
                    leax      $0254,y
                    std       $02,x
                    lbra      L5B53
                    leax      $0254,y
                    std       $02,x
                    tfr       a,b
                    sex
                    tfr       a,b
                    std       ,x
                    lbra      L5B53
                    leax      $0254,y
                    std       $02,x
                    clr       ,x
                    clr       $01,x
                    lbra      L5B53

L56F2               ldd       ,x
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

L571C               leax      $0254,y
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
                    bmi       L57AF
                    lda       $02,s
                    bmi       L5782
                    lda       $09,s
                    beq       L577B
                    ldb       $07,x
                    beq       L57B3
                    cmpa      $07,x
                    bne       L5786
                    ldd       $02,s
                    cmpd      ,x
                    bne       L5786
                    ldd       $04,s
                    cmpd      $02,x
                    bne       L5786
                    ldd       $06,s
                    cmpd      $04,x
                    bne       L5786
                    lda       $08,s
                    anda      #$FE
                    pshs      a
                    ldb       $06,x
                    andb      #$FE
                    cmpa      ,s+
                    bne       L5786
                    bra       L57B7

L577B               lda       $07,x
                    bne       L57C2
                    clra
                    bra       L57B7

L5782               lda       $07,x
                    cmpa      $09,s
L5786               bhi       L57B3
                    bcs       L57C2
                    ldd       ,x
                    cmpd      $02,s
                    bne       L5786
                    ldd       $02,x
                    cmpd      $04,s
                    bne       L5786
                    ldd       $04,x
                    cmpd      $06,s
                    bne       L5786
                    lda       $06,x
                    anda      #$FE
                    pshs      a
                    lda       $08,s
                    anda      #$FE
                    cmpa      ,s+
                    bne       L5786
                    bra       L57B7

L57AF               lda       ,x
                    bpl       L57C2
L57B3               lda       #$01
                    andcc     #$FE
L57B7               pshs      cc
                    ldd       $01,s
                    std       $09,s
                    puls      cc
                    leas      $08,s
                    rts

L57C2               clra
                    cmpa      #$01
                    bra       L57B7

L57C7               lda       $17,u
                    beq       L57E8
                    ldb       $1C,u
                    eorb      #$80
                    stb       $1C,u
                    eorb      $18,u
                    stb       $19,u
                    ldb       $29,u
                    bne       L57FA
                    lbsr      L5C83
                    lda       $22,u
                    lbra      L593A

L57E8               lda       $22,u
                    ldb       $18,u
                    lbra      L593D

L57F1               lbeq      L5C83
                    lda       $17,u
                    beq       L57E8
L57FA               suba      $29,u
                    beq       L582B
                    sta       ,u
                    bcs       L5831
                    ldb       $17,u
                    stb       $29,u
                    ldd       $22,u
L580C               lsra
                    rorb
                    ror       $24,u
                    ror       $25,u
                    ror       $26,u
                    ror       $27,u
                    ror       $28,u
                    dec       ,u
                    bne       L580C
                    std       $22,u
L5824               lda       $19,u
                    bmi       L58A0
                    bra       L5851

L582B               inc       ,u
                    orcc      #$01
                    bra       L5824

L5831               ldd       $10,u
L5834               lsra
                    rorb
                    ror       $12,u
                    ror       $13,u
                    ror       $14,u
                    ror       $15,u
                    ror       $16,u
                    inc       ,u
                    bne       L5834
                    std       $10,u
                    lda       $19,u
                    bmi       L58A3
L5851               ldd       $27,u
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
                    bcc       L5898
                    inc       $29,u
                    ror       $22,u
                    ror       $23,u
                    ror       $24,u
                    ror       $25,u
                    ror       $26,u
                    ror       $27,u
                    ror       $28,u
L5898               lda       $1C,u
                    sta       $19,u
                    bra       L58F7

L58A0               rola
                    coma
                    asra
L58A3               ldd       $27,u
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
                    bcc       L58F4
                    com       $22,u
                    com       $23,u
                    com       $24,u
                    com       $25,u
                    com       $26,u
                    com       $27,u
                    com       $28,u
                    lda       ,u
                    beq       L58F1
                    lbsr      L5C40
L58F1               lda       $1C,u
L58F4               sta       $19,u
L58F7               clr       ,u
L58F9               lda       $22,u
                    bmi       L593A
                    ora       $23,u
                    ora       $24,u
                    ora       $25,u
                    ora       $26,u
                    ora       $27,u
                    ora       $28,u
                    beq       L594E
                    ldd       $22,u
L5915               dec       $29,u
                    bne       L591D
                    dec       $1d,u
L591D               asl       ,u
                    rol       $28,u
                    rol       $27,u
                    rol       $26,u
                    rol       $25,u
                    rol       $24,u
                    rolb
                    rola
                    bpl       L5915
                    stb       $23,u
                    ldb       $29,u
                    beq       L5952
L593A               ldb       $19,u
L593D               anda      #$7f
                    andb      #$80
                    pshs      b
                    adda      ,s+
                    sta       $22,u
                    tst       $1d,u
                    bne       L5952
L594D               rts

L594E               sta       $29,u
                    rts

L5952               lda       $1d,u
                    ldb       $29,u
                    subd      #$0000
                    beq       L5965
                    bmi       L5965
L595F               ldd       #$0028
                    lbra      L5FDC

L5965               lbsr      L5990
                    bra       L595F

L596A               beq       L5990
                    lda       $17,u
                    beq       L5990
                    lbsr      L5A0C
                    clra
                    ldb       $29,u
                    addb      $17,u
                    adca      #$00
                    subd      #$0080
                    stb       $29,u
                    sta       $1d,u
                    lbsr      L58F9
                    lda       ,u
                    bpl       L594D
                    lbra      L5C40

L5990               clra
                    sta       $29,u
                    bra       L59F6

L5996               ldb       $17,u
                    bne       L59A1
                    ldd       #$0029
                    lbra      L5FDC

L59A1               tsta
                    beq       L5990
                    lbsr      L5A6A
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
                    lbsr      L58F9
                    lda       ,u
                    bpl       L5A0B
                    lbra      L5C40

L59DE               pshs      a
                    ldd       $22,u
                    std       ,u
                    ldd       $24,u
                    std       $02,u
                    ldd       $26,u
                    std       $04,u
                    ldb       $28,u
                    stb       $06,u
                    puls      a
L59F6               sta       $22,u
                    sta       $23,u
                    sta       $24,u
                    sta       $25,u
                    sta       $26,u
                    sta       $27,u
                    sta       $28,u
L5A0B               rts

L5A0C               clra
                    bsr       L59DE
                    ldb       #$38
                    stb       $08,u
L5A13               lda       $06,u
                    lsra
                    bcc       L5A42
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
L5A42               ror       $22,u
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
                    bne       L5A13
                    rts

L5A6A               clra
                    lbsr      L59DE
                    ldb       #$39
                    stb       $08,u
L5A72               ldb       ,u
                    cmpb      $10,u
                    bcs       L5AA9
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
                    bcs       L5AA9
                    std       ,u
                    lda       $0a,u
                    sta       $02,u
                    ldd       $0b,u
                    std       $03,u
                    ldd       $0d,u
                    std       $05,u
L5AA9               rol       $28,u
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
                    bhi       L5A72
                    beq       L5AF7
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
                    bra       L5AA9

L5AF7               ror       ,u
                    com       $22,u
                    com       $23,u
                    com       $24,u
                    com       $25,u
                    com       $26,u
                    com       $27,u
                    com       $28,u
                    rts

L5B0F               puls      d
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
L5B53               lda       #$A0
                    sta       $07,x
                    clr       $04,x
                    clr       $05,x
                    clr       $06,x
                    lda       ,x
                    tfr       a,b
                    orb       $01,x
                    orb       $02,x
                    orb       $03,x
                    beq       L5B9F
                    ldb       $01,x
                    tsta
                    bpl       L5B81
                    pshs      d
                    clra
                    clrb
                    subd      $02,x
                    std       $02,x
                    ldd       #$0000
                    sbcb      $01,s
                    sbca      ,s
                    leas      $02,s
                    bvs       L5B8B
L5B81               dec       $07,x
                    asl       $03,x
                    rol       $02,x
                    rolb
                    rola
                    bpl       L5B81
L5B8B               anda      #$7f
                    tst       ,x
                    bpl       L5B93
                    ora       #$80
L5B93               std       ,x
                    rts
                    leax      $22,u
                    clr       $04,x
                    clr       $05,x
                    clr       $06,x
L5B9F               clr       $07,x
L5BA1               clr       ,x
                    clr       $01,x
                    clr       $02,x
                    clr       $03,x
                    rts

L5BAA               ldd       #$002A
                    lbra      L5FDC
                    leax      $22,u
L5BB3               ldb       $07,x
                    beq       L5BA1
                    subb      #$81
                    bcs       L5C32
                    negb
                    addb      #$1f
                    bmi       L5BAA
                    bne       L5BD7
                    ldd       ,x
                    cmpd      #$8000
                    bne       L5BAA
                    lda       $02,x
                    ora       $03,x
                    ora       $04,x
                    ora       $05,x
                    ora       $06,x
                    bne       L5BAA
                    rts

L5BD7               pshs      b
                    ldd       ,x
                    bmi       L5BED
                    ora       #$80
L5BDF               lsra
                    rorb
                    ror       $02,x
                    ror       $03,x
                    dec       ,s
                    bne       L5BDF
                    std       ,x
                    puls      pc,b
L5BED               clr       ,-s
L5BEF               lsra
                    rorb
                    ror       $02,x
                    ror       $03,x
                    ror       $04,x
                    ror       $05,x
                    ror       $06,x
                    bcc       L5BFF
                    inc       ,s
L5BFF               dec       $01,s
                    bne       L5BEF
                    std       ,x
                    ldd       ,s++
                    bne       L5C11
                    lda       $04,x
                    ora       $05,x
                    ora       $06,x
                    beq       L5C22
L5C11               ldd       $02,x
                    addd      #$0001
                    std       $02,x
                    ldd       ,x
                    adcb      #$00
                    adca      #$00
                    bcs       L5BAA
                    std       ,x
L5C22               clra
                    clrb
                    subd      $02,x
                    std       $02,x
                    ldd       #$0000
                    sbcb      $01,x
                    sbca      ,x
                    std       ,x
                    rts

L5C32               lda       ,x
                    lbpl      L5BA1
                    ldd       #$FFFF
                    std       $02,x
                    std       ,x
                    rts

L5C40               inc       $28,u
                    bne       L5C76
                    inc       $27,u
                    bne       L5C76
                    inc       $26,u
                    bne       L5C76
                    inc       $25,u
                    bne       L5C76
                    inc       $24,u
                    bne       L5C76
                    inc       $23,u
                    bne       L5C76
                    ldb       $22,u
                    tfr       b,a
                    anda      #$7f
                    inca
                    bpl       L5C6D
                    inc       $29,u
                    anda      #$7f
L5C6D               andb      #$80
                    pshs      b
                    adda      ,s+
                    sta       $22,u
L5C76               rts

L5C77               neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       L0081
                    leax      >L5C77,pcr
L5C83               pshs      a
                    ldd       ,x
                    std       $22,u
                    ldd       $02,x
                    std       $24,u
                    ldd       $04,x
                    std       $26,u
                    ldd       $06,x
                    std       $28,u
                    puls      pc,a
L5C9B               pshs      a
                    ldd       $22,u
                    std       ,x
                    ldd       $24,u
                    std       $02,x
                    ldd       $26,u
                    std       $04,x
                    ldd       $28,u
                    std       $06,x
                    puls      pc,a
L5CB3               ldd       ,x
L5CB5               std       $0254,y
                    ldd       $02,x
                    std       $0256,y
                    ldd       $04,x
                    std       $0258,y
                    ldd       $06,x
                    leax      $0254,y
                    std       $06,x
                    rts
                    pshs      x
                    bsr       L5D51
                    leax      L5C77,pcr
                    pshs      x
                    lbsr      L5B0F
                    lbsr      L57F1
L5CDD               ldx       $2a,u
                    bsr       L5C9B
                    ldx       $1e,u
                    leas      $2a,u
                    tfr       x,u
                    puls      pc,x
                    pshs      x
                    bsr       L5D51
                    leax      >L5C77,pcr
                    pshs      x
                    lbsr      L5B0F
                    lbsr      L57C7
                    bra       L5CDD
                    pshs      x
                    bsr       L5D3A
                    leax      L5C77,pcr
                    pshs      x
                    lbsr      L5B0F
                    lbsr      L57F1
L5D0E               ldx       $2a,u
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
                    bsr       L5D3A
                    leax      L5C77,pcr
                    pshs      x
                    lbsr      L5B0F
                    lbsr      L57C7
                    bra       L5D0E

L5D3A               leas      -$08,s
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

L5D51               leas      -$08,s
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

L5D68               pshs      u
                    ldu       $04,s
                    exg       x,u
                    ldd       ,u
                    std       ,x
                    ldd       $02,u
                    std       $02,x
                    bra       L5D8E

L5D78               pshs      u
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
L5D8E               puls      u
                    puls      d
                    std       ,s
                    rts

L5D95               ldd       $04,s
                    addd      $02,x
                    std       $0256,y
                    ldd       $02,s
                    adcb      $01,x
                    adca      ,x
                    std       $0254,y
                    lbra      L5E71

L5DAA               ldd       $04,s
                    subd      $02,x
                    std       $0256,y
                    ldd       $02,s
                    sbcb      $01,x
                    sbca      ,x
                    std       $0254,y
                    lbra      L5E71

L5DBF               ldd       $02,s
                    cmpd      ,x
                    bne       L5DD8
                    ldd       $04,s
                    cmpd      $02,x
                    beq       L5DD8
                    bcs       L5DD5
                    lda       #$01
                    andcc     #$FE
                    bra       L5DD8

L5DD5               clra
                    cmpa      #$01
L5DD8               pshs      cc
                    ldd       $01,s
                    std       $05,s
                    puls      cc
                    leas      $04,s
                    rts

L5DE3               lbsr      L5E80
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

L5E0A               leax      $0254,y
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

L5E23               pshs      y
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

L5E39               ldx       $02,s
                    pshs      b
                    lbsr      L5E80
                    puls      b
                    tstb
                    beq       L5E50
L5E45               asl       $03,x
                    rol       $02,x
                    rol       $01,x
                    rol       ,x
                    decb
                    bne       L5E45
L5E50               puls      d
                    std       ,s
                    rts
                    ldx       $02,s
                    pshs      b
                    lbsr      L5E80
                    puls      b
                    tstb
                    beq       L5E6C
L5E61               asr       ,x
                    ror       $01,x
                    ror       $02,x
                    ror       $03,x
                    decb
                    bne       L5E61
L5E6C               puls      d
                    std       ,s
                    rts

L5E71               tfr       cc,a
                    puls      x
                    stx       $02,s
                    leas      $02,s
                    leax      $0254,y
                    tfr       a,cc
                    rts

L5E80               ldd       ,x
                    std       $0254,y
                    ldd       $02,x
                    leax      $0254,y
                    std       $02,x
                    rts

L5E8F               tsta
                    bne       L5EA4
                    tst       $02,s
                    bne       L5EA4
                    lda       $03,s
                    mul
                    ldx       ,s
                    stx       $02,s
                    ldx       #$0000
                    std       ,s
                    puls      pc,d
L5EA4               pshs      d
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
                    bcc       L5EC1
                    inc       ,s
L5EC1               lda       $04,s
                    ldb       $09,s
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L5ECE
                    inc       ,s
L5ECE               lda       $04,s
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
                    leax      >L5F2A,pcr
                    stx       $02E3,y
                    bra       L5F04

L5EF0               leax      >L5F43,pcr
                    stx       $02E3,y
                    clr       $02E2,y
                    tst       $02,s
                    bpl       L5F04
                    inc       $02E2,y
L5F04               subd      #$0000
                    bne       L5F0F
                    puls      x
                    ldd       ,s++
                    jmp       ,x

L5F0F               ldx       $02,s
                    pshs      x
                    jsr       [$02E3,y]
                    ldd       ,s
                    std       $02,s
                    tfr       x,d
                    tst       $02E2,y
                    beq       L5F27
                    nega
                    negb
                    sbca      #$00
L5F27               std       ,s++
                    rts

L5F2A               subd      #$0000
                    beq       L5F39
                    pshs      d
                    leas      -$02,s
                    clr       ,s
                    clr       $01,s
                    bra       L5F67

L5F39               puls      d
                    std       ,s
                    ldd       #$002D
                    lbra      L5FDC

L5F43               subd      #$0000
                    beq       L5F39
                    pshs      d
                    leas      -$02,s
                    clr       ,s
                    clr       $01,s
                    tsta
                    bpl       L5F5B
                    nega
                    negb
                    sbca      #$00
                    inc       $01,s
                    std       $02,s
L5F5B               ldd       $06,s
                    bpl       L5F67
                    nega
                    negb
                    sbca      #$00
                    com       $01,s
                    std       $06,s
L5F67               lda       #$01
L5F69               inca
                    asl       $03,s
                    rol       $02,s
                    bpl       L5F69
                    sta       ,s
                    ldd       $06,s
                    clr       $06,s
                    clr       $07,s
L5F78               subd      $02,s
                    bcc       L5F82
                    addd      $02,s
                    andcc     #$FE
                    bra       L5F84

L5F82               orcc      #$01
L5F84               rol       $07,s
                    rol       $06,s
                    lsr       $02,s
                    ror       $03,s
                    dec       ,s
                    bne       L5F78
                    std       $02,s
                    tst       $01,s
                    beq       L5F9E
                    ldd       $06,s
                    nega
                    negb
                    sbca      #$00
                    std       $06,s
L5F9E               ldx       $04,s
                    ldd       $06,s
                    std       $04,s
                    stx       $06,s
                    ldx       $02,s
                    ldd       $04,s
                    leas      $06,s
                    rts

L5FAD               tstb
                    beq       L5FC3
L5FB0               asr       $02,s
                    ror       $03,s
                    decb
                    bne       L5FB0
                    bra       L5FC3

L5FB9               tstb
                    beq       L5FC3
L5FBC               lsr       $02,s
                    ror       $03,s
                    decb
                    bne       L5FBC
L5FC3               ldd       $02,s
                    pshs      d
                    ldd       $02,s
                    std       $04,s
                    ldd       ,s
                    leas      $04,s
                    rts

L5FD0               tstb
                    beq       L5FC3
L5FD3               asl       $03,s
                    rol       $02,s
                    decb
                    bne       L5FD3
                    bra       L5FC3

L5FDC               std       $0260,y
                    pshs      y,b
                    os9       F$ID
                    puls      y,b
                    os9       F$Send
                    rts

L5FEB               lda       $05,s
                    ldb       $03,s
                    beq       L601E
                    cmpb      #$01
                    beq       L6020
                    cmpb      #$06
                    beq       L6020
                    cmpb      #$02
                    beq       L6006
                    cmpb      #$05
                    beq       L6006
                    ldb       #$D0
                    lbra      L621B

L6006               pshs      u
                    os9       I$GetStt
                    bcc       L6012
                    puls      u
                    lbra      L621B

L6012               stx       [$08,s]
                    ldx       $08,s
                    stu       $02,x
                    puls      u
                    clra
                    clrb
                    rts

L601E               ldx       $06,s
L6020               os9       I$GetStt
                    lbra      L6224
                    lda       $05,s
                    ldb       $03,s
                    beq       L6035
                    cmpb      #$02
                    beq       L603D
                    ldb       #$D0
                    lbra      L621B

L6035               ldx       $06,s
                    os9       I$SetStt
                    lbra      L6224

L603D               pshs      u
                    ldx       $08,s
                    ldu       $0a,s
                    os9       I$SetStt
                    puls      u
                    lbra      L6224
                    ldx       $02,s
                    lda       $05,s
                    os9       I$Open
                    bcs       L6057
                    os9       I$Close
L6057               lbra      L6224

L605A               ldx       $02,s
                    lda       $05,s
                    os9       I$Open
                    lbcs      L621B
                    tfr       a,b
                    clra
                    rts

L6069               lda       $03,s
                    os9       I$Close
                    lbra      L6224
                    ldx       $02,s
                    ldb       $05,s
                    os9       I$MakDir
                    lbra      L6224

L607B               ldx       $02,s
                    lda       $05,s
                    tfr       a,b
                    andb      #$24
                    orb       #$0b
                    os9       I$Create
                    bcs       L608E
L608A               tfr       a,b
                    clra
                    rts

L608E               cmpb      #$DA
                    lbne      L621B
                    lda       $05,s
                    bita      #$80
                    lbne      L621B
                    anda      #$07
                    ldx       $02,s
                    os9       I$Open
                    lbcs      L621B
                    pshs      u,a
                    ldx       #$0000
                    leau      ,x
                    ldb       #$02
                    os9       I$SetStt
                    puls      u,a
                    bcc       L608A
                    pshs      b
                    os9       I$Close
                    puls      b
                    lbra      L621B

L60C1               ldx       $02,s
                    os9       I$Delete
                    lbra      L6224
                    lda       $03,s
                    os9       I$Dup
                    lbcs      L621B
                    tfr       a,b
                    clra
                    rts

L60D6               pshs      y
                    ldx       $06,s
                    lda       $05,s
                    ldy       $08,s
                    pshs      y
                    os9       I$Read
L60E4               bcc       L60F3
                    cmpb      #$D3
                    bne       L60EE
                    clra
                    clrb
                    puls      pc,y,x
L60EE               puls      y,x
                    lbra      L621B

L60F3               tfr       y,d
                    puls      pc,y,x
L60F7               pshs      y
                    lda       $05,s
                    ldx       $06,s
                    ldy       $08,s
                    pshs      y
                    os9       I$ReadLn
                    bra       L60E4

L6107               pshs      y
                    ldy       $08,s
                    beq       L611C
                    lda       $05,s
                    ldx       $06,s
                    os9       I$Write
L6115               bcc       L611C
                    puls      y
                    lbra      L621B

L611C               tfr       y,d
                    puls      pc,y
L6120               pshs      y
                    ldy       $08,s
                    beq       L611C
                    lda       $05,s
                    ldx       $06,s
                    os9       I$WritLn
                    bra       L6115

L6130               pshs      u
                    ldd       $0a,s
                    bne       L613E
                    ldu       #$0000
                    ldx       #$0000
                    bra       L6172

L613E               cmpd      #$0001
                    beq       L6169
                    cmpd      #$0002
                    beq       L615E
                    ldb       #$F7
L614C               clra
                    std       $0260,y
                    ldd       #$FFFF
                    leax      $0254,y
                    std       ,x
                    std       $02,x
                    puls      pc,u
L615E               lda       $05,s
                    ldb       #$02
                    os9       I$GetStt
                    bcs       L614C
                    bra       L6172

L6169               lda       $05,s
                    ldb       #$05
                    os9       I$GetStt
                    bcs       L614C
L6172               tfr       u,d
                    addd      $08,s
                    std       $0256,y
                    tfr       d,u
                    tfr       x,d
                    adcb      $07,s
                    adca      $06,s
                    bmi       L614C
                    tfr       d,x
                    std       $0254,y
                    lda       $05,s
                    os9       I$Seek
                    bcs       L614C
                    leax      $0254,y
                    puls      pc,u
L6197               ldd       $0252,y
                    pshs      d
                    ldd       $04,s
                    cmpd      $02E5,y
                    bcs       L61CB
                    addd      $0252,y
                    pshs      y
                    subd      ,s
                    os9       F$Mem
                    tfr       y,d
                    puls      y
                    bcc       L61BD
                    ldd       #$FFFF
                    leas      $02,s
                    rts

L61BD               std       $0252,y
                    addd      $02E5,y
                    subd      ,s
                    std       $02E5,y
L61CB               leas      $02,s
                    ldd       $02E5,y
                    pshs      d
                    subd      $04,s
                    std       $02E5,y
                    ldd       $0252,y
                    subd      ,s++
                    pshs      d
                    clra
                    ldx       ,s
L61E4               sta       ,x+
                    cmpx      $0252,y
                    bcs       L61E4
                    puls      pc,d
L61EE               ldd       $02,s
                    addd      $025C,y
                    bcs       L6217
                    cmpd      $025e,y
                    bcc       L6217
                    pshs      d
                    ldx       $025C,y
                    clra
L6204               cmpx      ,s
                    bcc       L620C
                    sta       ,x+
                    bra       L6204

L620C               ldd       $025C,y
                    puls      x
                    stx       $025C,y
                    rts

L6217               ldd       #$FFFF
                    rts

L621B               clra
                    std       $0260,y
                    ldd       #$FFFF
                    rts

L6224               bcs       L621B
                    clra
                    clrb
                    rts

exit                lbsr      L6234
                    lbsr      L5226
L622F               ldd       $02,s
                    os9       F$Exit
L6234               rts

* ------------------------------------------------------------------
* L6235 - cc1-style init image for the work block (see _start):
* rts stub + count/block table + relocation dirs + module-name string.
* ------------------------------------------------------------------
L6235               fcb       $00,$03,$00,$00 init table / work-block image
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
                    fcc       /c.pass2/
                    fcb       $00
                    emod
eom                 equ       *
                    end
