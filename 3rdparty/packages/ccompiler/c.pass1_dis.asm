                    nam       c.pass1
                    ttl       program module

                    use       defsfile

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       $05

                    mod       eom,name,tylg,atrv,start,size

u0000               rmb       3987
size                equ       .

name                equ       *
                    fcs       /c.pass1/
                    fcb       edition

L0015               lda       ,y+
L0017               sta       ,u+
L0019               leax      -$01,x
L001B               bne       L0015
L001D               rts

start               pshs      y
L0020               pshs      u
L0022               clra
L0023               clrb
L0024               sta       ,u+
L0026               decb
L0027               bne       L0024
L0029               ldx       ,s
L002B               leau      ,x
L002D               leax      $0813,x
L0031               pshs      x
L0033               leay      L794C,pcr
L0037               ldx       ,y++
L0039               beq       L003F
L003B               bsr       L0015
L003D               ldu       $02,s
L003F               leau      >$0076,u
L0043               ldx       ,y++
L0045               beq       L004A
L0047               bsr       L0015
L0049               clra
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
L006B               puls      x
L006D               stx       $02C4,u
                    sty       $0284,u
L0076               ldd       #$0001
                    std       $02C0,u
L007D               leay      $0286,u
                    leax      ,s
L0083               lda       ,x+
L0085               ldb       $02C1,u
                    cmpb      #$1d
                    beq       L00E1
L008D               cmpa      #$0d
L008F               beq       L00E1
L0091               cmpa      #$20
                    beq       L0099
                    cmpa      #$2C
                    bne       L009D
L0099               lda       ,x+
                    bra       L008D

L009D               cmpa      #$22
                    beq       L00A5
L00A1               cmpa      #$27
                    bne       L00C3
L00A5               stx       ,y++
L00A7               inc       $02C1,u
                    pshs      a
L00AD               lda       ,x+
                    cmpa      #$0d
                    beq       L00B7
                    cmpa      ,s
                    bne       L00AD
L00B7               puls      b
                    clr       -$01,x
                    cmpa      #$0d
                    beq       L00E1
                    lda       ,x+
                    bra       L0085

L00C3               leax      -$01,x
                    stx       ,y++
                    leax      $01,x
                    inc       $02C1,u
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

L00E1               leax      $0284,u
                    pshs      x
                    ldd       0,x
                    adcb      #$02
                    subb      #$34
                    ror       L0031
                    andb      #$8d
                    dec       L0017
                    rol       -$04,s
                    clr       ,-s
                    clr       ,-s
                    lbsr      L7941
                    leax      $0813,y
L0100               stx       $02CE,y
                    sts       $02C2,y
                    sts       $02D0,y
                    ldd       #$FF82
L0111               leax      d,s
L0113               cmpx      $02D0,y
                    bcc       L0123
                    cmpx      $02CE,y
                    bcs       L013D
                    stx       $02D0,y
L0123               rts
L0124               fcb       $2a,$2a,$2a,$2a,$20,$53,$54,$41
                    fcb       $43,$4b,$20,$4f,$56,$45,$52,$46
                    fcb       $4C,$4f,$57,$20,$2a,$2a,$2a,$2a
                    fcb       $0d
L013D               leax      L0124,pcr
                    ldb       #$CF
                    pshs      b
                    lda       #$02
                    ldy       #$0064
                    os9       I$WritLn
                    clr       ,-s
                    lbsr      L7947
                    ldd       $02C2,y
                    subd      $02D0,y
                    rts
                    ldd       $02D0,y
                    subd      $02CE,y
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
                    pshs      u
L0180               ldu       $04,s
                    leas      -$06,s
                    ldd       L0043
                    std       $02,s
                    beq       L0193
                    ldx       $02,s
                    ldd       $10,x
                    std       L0043
                    bra       L019F

L0193               ldd       #$0012
                    pshs      d
                    lbsr      L5C28
                    leas      $02,s
                    std       $02,s
L019F               ldd       #$0012
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    stu       $08,s
                    pshs      u
                    bsr       L01F7
                    leas      $06,s
                    ldd       #$0009
                    std       ,s
                    bra       L01BB

L01B7               clra
                    clrb
                    std       ,u++
L01BB               ldd       ,s
                    addd      #$FFFF
                    std       ,s
                    subd      #$FFFF
                    bne       L01B7
                    ldd       $02,s
                    ldx       $04,s
                    std       $0e,x
                    lbra      L03D7
                    pshs      u
L01D2               ldu       $04,s
                    leas      -$02,s
                    ldd       $0e,u
                    std       ,s
                    ldd       #$0012
                    pshs      d
                    pshs      u
                    ldd       $04,s
                    pshs      d
                    bsr       L01F7
                    leas      $06,s
                    ldd       L0043
                    ldx       ,s
                    std       $10,x
                    ldd       ,s
                    std       L0043
                    lbra      L03B1

L01F7               pshs      u
L01F9               ldu       $04,s
                    bra       L0207

L01FD               ldb       ,u+
                    ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    stb       -$01,x
L0207               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bne       L01FD
                    puls      pc,u
L0215               pshs      u
                    leax      $03EE,y
                    pshs      x
                    leax      L0521,pcr
                    pshs      x
                    lbsr      L034B
                    lbra      L0390
                    pshs      u
L022B               ldd       $04,s
                    pshs      d
                    bsr       L024C
                    leas      $02,s
                    leax      $01CE,y
                    pshs      x
                    lbsr      $702D
                    lbra      L0344
                    pshs      u
L0241               leax      L0527,pcr
                    pshs      x
                    bsr       L024C
                    lbra      L03B1

L024C               pshs      u
L024E               ldd       L003F
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    leax      $060C,y
                    pshs      x
                    ldd       $0063
                    bra       L02A9
                    pshs      u
L0262               leas      -$32,s
                    leax      L053B,pcr
                    pshs      x
                    leax      $02,s
                    pshs      x
                    lbsr      $7312
                    leas      $04,s
                    ldd       $38,s
                    pshs      d
                    leax      $02,s
                    pshs      x
                    lbsr      $732A
                    leas      $04,s
                    leax      ,s
                    pshs      x
                    ldd       $38,s
                    pshs      d
                    bsr       L0294
                    leas      $04,s
                    leas      $32,s
                    puls      pc,u
L0294               pshs      u
L0296               ldu       $04,s
                    ldd       $0e,u
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    leax      $060C,y
                    pshs      x
                    ldd       $10,u
L02A9               subd      ,s++
                    pshs      d
                    bsr       L02B2
                    lbra      L03D7

L02B2               pshs      u
                    ldu       $04,s
                    lbsr      L0215
                    ldd       $08,s
                    pshs      d
                    leax      L054D,pcr
                    pshs      x
                    lbsr      L034B
                    leas      $04,s
                    ldd       $06,s
                    pshs      d
                    leax      L0557,pcr
                    pshs      x
                    lbsr      L034B
                    leas      $04,s
                    ldd       $08,s
                    cmpd      L0027
                    bne       L02ED
                    leax      $060C,y
                    pshs      x
                    lbsr      L0366
                    leas      $02,s
                    leax      ,s
                    bra       L0304

L02ED               ldd       L0027
                    addd      #$FFFF
                    cmpd      $08,s
                    bne       L0324
                    leax      $070C,y
                    pshs      x
                    lbsr      L0366
                    leas      $02,s
                    bra       L0314

L0304               leas      ,x
                    bra       L0314

L0308               ldd       #$0020
                    pshs      d
                    lbsr      L0380
                    leas      $02,s
                    leau      -$01,u
L0314               cmpu      #$0000
                    bgt       L0308
                    leax      L0567,pcr
                    pshs      x
                    bsr       L0366
                    leas      $02,s
L0324               ldd       L0029
                    addd      #$0001
                    std       L0029
                    cmpd      #start
                    ble       L0349
                    leax      $01CE,y
                    pshs      x
                    lbsr      $702D
                    leas      $02,s
                    leax      $0569,pcr
                    pshs      x
                    bsr       L0366
L0344               leas      $02,s
                    lbsr      $68C2
L0349               puls      pc,u
L034B               pshs      u
                    ldd       $08,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    leax      $01CE,y
                    pshs      x
                    lbsr      L50E4
                    leas      $08,s
                    puls      pc,u
L0366               pshs      u
                    leax      $01CE,y
                    pshs      x
                    ldd       $06,s
                    pshs      d
                    lbsr      $6E62
                    leas      $04,s
                    ldd       #$000D
                    pshs      d
                    bsr       L0380
                    bra       L03B1

L0380               pshs      u
                    leax      $01CE,y
                    pshs      x
                    ldb       $07,s
                    sex
                    pshs      d
                    lbsr      $6F02
L0390               leas      $04,s
                    puls      pc,u
L0394               pshs      u
L0396               ldu       $04,s
                    stu       -$02,s
                    beq       L03B3
                    ldd       $0a,u
                    pshs      d
                    bsr       L0394
                    leas      $02,s
                    ldd       $0C,u
                    pshs      d
                    lbsr      L0394
                    leas      $02,s
                    pshs      u
                    bsr       L03B5
L03B1               leas      $02,s
L03B3               puls      pc,u
L03B5               pshs      u
L03B7               ldu       $04,s
                    stu       -$02,s
                    beq       L03C3
                    ldd       L002D
                    std       $0a,u
                    stu       L002D
L03C3               puls      pc,u
                    pshs      u
L03C7               ldd       #$0016
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L01F7
L03D7               leas      $06,s
                    puls      pc,u
L03DB               pshs      u
L03DD               ldd       $005F
                    cmpd      #$0033
                    bne       L0429
                    ldx       $0061
                    cmpx      #$0001
                    lbeq      L04FB
                    cmpx      #$0002
                    lbeq      L04FB
                    cmpx      #$0007
                    lbeq      L04FB
                    cmpx      #$000A
                    lbeq      L04FB
                    cmpx      #$0008
                    lbeq      L04FB
                    cmpx      #$0004
                    lbeq      L04FB
                    cmpx      #$0003
                    lbeq      L04FB
                    cmpx      #$0006
                    lbeq      L04FB
                    cmpx      #$0005
                    lbeq      L04FB
                    lbra      L04C9

L0429               ldd       $005F
                    cmpd      #$0034
                    lbne      L04C9
                    ldx       $0061
                    ldd       $08,x
                    cmpd      #start
                    bra       L0471
                    pshs      u
L043F               ldd       $005F
                    cmpd      #$0033
                    lbne      L04C9
                    ldx       $0061
                    cmpx      #$000E
                    lbeq      L04FB
                    cmpx      #$000D
                    lbeq      L04FB
                    cmpx      #start
                    lbeq      L04FB
                    cmpx      #$0010
                    lbeq      L04FB
                    cmpx      #$000F
                    lbeq      L04FB
                    cmpx      #$0021
L0471               lbeq      L04FB
                    lbra      L04C9

L0478               pshs      u
L047A               ldd       $04,s
                    asra
                    rorb
                    asra
                    rorb
                    andb      #$F0
                    bra       L0491

L0484               pshs      u
L0486               ldd       $04,s
                    andb      #$F0
                    aslb
                    rola
                    aslb
                    rola
                    addd      #$0010
L0491               pshs      d
                    ldd       $06,s
                    clra
                    andb      #$0f
                    addd      ,s++
                    puls      pc,u
L049C               pshs      u
                    ldu       $04,s
                    cmpu      #$004C
                    blt       L04C9
                    cmpu      #$0063
                    bgt       L04C9
                    ldd       #$0001
                    bra       L04CB

L04B1               pshs      u
                    ldu       $04,s
                    stu       -$02,s
                    beq       L04C9
                    ldd       $02,u
                    bra       L04CB

L04BD               pshs      u
L04BF               ldd       $005F
                    cmpd      $04,s
                    bne       L04CD
                    lbsr      $552C
L04C9               clra
                    clrb
L04CB               puls      pc,u
L04CD               ldu       #$0000
                    bra       L04E4

L04D2               tfr       u,d
                    leax      $0089,y
                    leax      d,x
                    ldb       ,x
                    sex
                    cmpd      $04,s
                    beq       L04EA
                    leau      $01,u
L04E4               cmpu      #$0080
                    blt       L04D2
L04EA               tfr       u,d
                    stb       >$0076,y
                    leax      >$0076,y
                    pshs      x
                    lbsr      L024C
                    leas      $02,s
L04FB               ldd       #$0001
                    puls      pc,u
                    pshs      u
L0502               bra       L0507

L0504               lbsr      $552C
L0507               ldd       $005F
                    cmpd      #$0028
                    beq       L051F
                    ldd       $005F
                    cmpd      #$002A
                    beq       L051F
                    ldd       $005F
                    cmpd      #$FFFF
                    bne       L0504
L051F               puls      pc,u
L0521               bcs       L0596
                    bra       L055F
                    bra       L0527

L0527               tst       -$0b,s
                    inc       -$0C,s
                    rol       -$10,s
                    inc       $05,s
                    bra       L0595
                    fcb       $65
                    ror       $09,s
                    jmp       $09,s
                    lsr       L696F
                    jmp       0,x

L053B               com       $0f,s
                    tst       -$10,s
                    rol       $0C,s
                    fcb       $65
                    fcb       $72
                    bra       L05AA
                    fcb       $72
                    fcb       $72
                    clr       -$0e,s
                    bra       $0578
                    bra       L054D

L054D               inc       $09,s
                    jmp       $05,s
                    bra       $0578
                    lsr       0,y
                    bra       L0557

L0557               bpl       L0583
                    bpl       $0585
                    bra       L057D
                    bcs       $05D2
L055F               bra       $0581
                    bpl       $058D
                    bpl       $058F
                    tst       $0000
L0567               fcb       $5e
                    neg       $0074
                    clr       $0f,s
                    bra       $05DB
                    fcb       $61
                    jmp       -$07,s
                    bra       L05D8
                    fcb       $72
                    fcb       $72
                    clr       -$0e,s
                    com       $202D
                    bra       L05BD
                    fcb       $42
L057D               clra
                    fcb       $52
                    lsrb
                    neg       $0034
                    nega
L0583               ldd       #$FFA2
                    lbsr      L0111
                    leas      -$0e,s
                    lbsr      L0695
                    std       $0C,s
                    lbne      L067A
                    clra
L0595               clrb
L0596               lbra      L0691
                    lbra      L067A

L059C               ldd       $005F
                    std       $0a,s
                    ldd       $0061
                    std       $08,s
                    std       ,s
                    ldd       L003F
                    std       $04,s
L05AA               ldd       $0063
                    std       $02,s
                    lbsr      $552C
                    ldx       $0a,s
                    bra       L05CE

L05B5               ldd       $0a,s
                    cmpd      #$00A0
                    blt       L05C5
L05BD               ldd       $0a,s
                    cmpd      #$00A9
                    ble       L05DA
L05C5               ldd       $08,s
                    addd      #$0001
                    std       ,s
                    bra       L05DA

L05CE               cmpx      #$0064
                    beq       L05DA
                    cmpx      #$0078
                    beq       L05DA
L05D8               bra       L05B5

L05DA               ldd       ,s
                    pshs      d
                    lbsr      $0581
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    lbeq      L066F
                    ldd       $0a,s
                    cmpd      #$0064
                    lbne      L064E
                    ldd       #$002F
                    pshs      d
                    lbsr      L04BD
                    std       ,s++
                    bne       L0643
                    ldd       $0063
                    std       $02,s
                    ldd       L003F
                    std       $04,s
                    ldd       #$0003
                    pshs      d
                    lbsr      $0581
                    leas      $02,s
                    std       $06,s
                    beq       L0638
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
                    lbsr      L0DD4
                    leas      $0C,s
                    tfr       d,u
                    bra       L064E

L0638               leax      L0E98,pcr
                    pshs      x
                    lbsr      L024C
                    leas      $02,s
L0643               pshs      u
                    lbsr      L0394
                    leas      $02,s
                    leax      $0e,s
                    bra       L068D

L064E               ldd       $02,s
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
                    lbsr      L0DD4
                    leas      $0C,s
                    std       $0C,s
                    bra       L067A

L066F               leax      L0EB1,pcr
                    pshs      x
                    lbsr      L024C
                    leas      $02,s
L067A               lbsr      L0A9C
                    std       -$02,s
                    beq       L068F
                    ldd       $12,s
                    cmpd      $0061
                    lble      L059C
                    bra       L068F

L068D               leas      -$0e,x
L068F               ldd       $0C,s
L0691               leas      $0e,s
                    puls      pc,u
L0695               pshs      u
                    ldd       #$FFA4
                    lbsr      L0111
                    leas      -$0C,s
                    ldu       #$0000
                    ldx       $005F
                    lbra      L07FD

L06A7               ldd       $0063
                    pshs      d
                    ldd       L003F
                    pshs      d
                    ldd       $0061
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    ldd       $005F
                    pshs      d
                    lbsr      L0DD4
                    leas      $0C,s
                    tfr       d,u
                    lbsr      $552C
                    lbra      L085F

L06CC               lbsr      $552C
                    lbsr      L03DB
                    std       -$02,s
                    beq       L06FA
                    lbsr      L0D48
                    tfr       d,u
                    ldd       #$002E
                    pshs      d
                    lbsr      L04BD
                    leas      $02,s
                    bsr       L0695
                    std       $0a,u
                    lbne      L085F
                    pshs      u
                    lbsr      L03B5
                    leas      $02,s
                    ldu       #$0000
                    lbra      L085F

L06FA               clra
                    clrb
                    pshs      d
                    lbsr      $0581
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    bne       L0730
                    bra       L070D

L070B               leas      -$0C,x
L070D               lbsr      L0E16
                    ldd       $0063
                    pshs      d
                    ldd       L003F
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
                    lbsr      L0DD4
                    leas      $0C,s
                    tfr       d,u
L0730               ldd       #$002E
                    pshs      d
                    lbsr      L04BD
                    lbra      L07F9

L073B               ldd       $005F
                    std       $08,s
                    ldd       L003F
                    std       $06,s
                    ldd       $0063
                    std       $04,s
                    lbsr      $552C
                    lbsr      L0695
                    std       $0a,s
                    beq       L0776
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
                    lbsr      L0DD4
                    leas      $0C,s
                    tfr       d,u
                    lbra      L085F

L0776               leax      L0EC2,pcr
                    pshs      x
                    lbsr      L024C
                    lbra      L07F9

L0782               ldd       L003F
                    std       $06,s
                    ldd       $0063
                    std       $04,s
                    lbsr      $552C
                    ldd       $005F
                    cmpd      #$002D
                    bne       L07C4
                    lbsr      $552C
                    lbsr      L03DB
                    std       -$02,s
                    beq       L07A6
                    lbsr      L0D48
                    std       $0a,s
                    bra       L07B8

L07A6               clra
                    clrb
                    pshs      d
                    lbsr      $0581
                    leas      $02,s
                    std       $0a,s
                    bne       L07B8
                    leax      $0C,s
                    lbra      L070B

L07B8               ldd       #$002E
                    pshs      d
                    lbsr      L04BD
                    leas      $02,s
                    bra       L07C9

L07C4               lbsr      L0695
                    std       $0a,s
L07C9               ldd       $0a,s
                    std       ,s
                    ldd       $04,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    leax      $04,s
                    pshs      x
                    lbsr      L0E2A
                    std       ,s
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    lbsr      L0DD4
                    leas      $0C,s
                    tfr       d,u
                    ldd       ,s
                    pshs      d
                    lbsr      L0394
L07F9               leas      $02,s
                    bra       L085F

L07FD               cmpx      #$0037
                    lbeq      L06A7
                    cmpx      #$0034
                    lbeq      L06A7
                    cmpx      #$004A
                    lbeq      L06A7
                    cmpx      #$004B
                    lbeq      L06A7
                    cmpx      #$0036
                    lbeq      L06A7
                    cmpx      #$002D
                    lbeq      L06CC
                    cmpx      #$0040
                    lbeq      L073B
                    cmpx      #$0043
                    lbeq      L073B
                    cmpx      #$0044
                    lbeq      L073B
                    cmpx      #$0042
                    lbeq      L073B
                    cmpx      #$003D
                    lbeq      L073B
                    cmpx      #$003C
                    lbeq      L073B
                    cmpx      #$0041
                    lbeq      L073B
                    cmpx      #$003B
                    lbeq      L0782
L085F               cmpu      #$0000
                    bne       L086A
                    clra
                    clrb
                    lbra      L09F1

L086A               ldx       $005F
                    lbra      L0990

L086F               ldd       $0063
                    std       $04,s
                    ldd       L003F
                    std       $06,s
                    lbsr      $552C
                    ldd       $04,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       #$000F
                    pshs      d
                    lbsr      L09F5
                    pshs      d
                    pshs      u
                    ldd       #$0065
                    pshs      d
                    lbsr      L0DD4
                    leas      $0C,s
                    tfr       d,u
                    ldd       #$002E
                    lbra      L0916

L08A0               lbsr      $552C
                    ldd       #$0002
                    pshs      d
                    lbsr      $0581
                    leas      $02,s
                    std       $0a,s
                    bne       L08D4
                    lbsr      L0E16
                    ldd       $0063
                    pshs      d
                    ldd       L003F
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
                    lbsr      L0DD4
                    leas      $0C,s
                    std       $0a,s
L08D4               ldd       $0063
                    pshs      d
                    ldd       L003F
                    pshs      d
                    ldd       #$000C
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    pshs      u
                    ldd       #$0050
                    pshs      d
                    lbsr      L0DD4
                    leas      $0C,s
                    tfr       d,u
                    ldd       $0063
                    pshs      d
                    ldd       L003F
                    pshs      d
                    ldd       #$000F
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    pshs      u
                    ldd       #$0042
                    pshs      d
                    lbsr      L0DD4
                    leas      $0C,s
                    tfr       d,u
                    ldd       #$002C
L0916               pshs      d
                    lbsr      L04BD
                    leas      $02,s
                    lbra      L086A

L0920               ldd       $005F
                    std       $08,s
                    ldd       L003F
                    std       $06,s
                    ldd       $0063
                    std       $04,s
                    ldd       $0041
                    addd      #$0001
                    std       $0041
                    lbsr      $552C
                    ldd       $0041
                    addd      #$FFFF
                    std       $0041
                    ldd       $005F
                    cmpd      #$0034
                    beq       L094B
                    lbsr      L42E0
                    lbra      L09AC

L094B               ldd       $0063
                    pshs      d
                    ldd       L003F
                    pshs      d
                    ldd       $0061
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    ldd       $005F
                    pshs      d
                    lbsr      L0DD4
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
                    lbsr      L0DD4
                    leas      $0C,s
                    tfr       d,u
                    lbsr      $552C
                    lbra      L086A

L0990               cmpx      #$002D
                    lbeq      L086F
                    cmpx      #$002B
                    lbeq      L08A0
                    cmpx      #$0045
                    lbeq      L0920
                    cmpx      #$0046
                    lbeq      L0920
L09AC               ldx       $005F
                    bra       L09E5

L09B0               ldd       #$003E
                    std       $005F
                    leax      $0C,s
                    bra       L09C0

L09B9               ldd       #$003F
                    std       $005F
                    bra       L09C2

L09C0               leas      -$0C,x
L09C2               ldd       $0063
                    pshs      d
                    ldd       L003F
                    pshs      d
                    ldd       #$000E
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    pshs      u
                    ldd       $005F
                    pshs      d
                    lbsr      L0DD4
                    leas      $0C,s
                    tfr       d,u
                    lbsr      $552C
                    bra       L09EF

L09E5               cmpx      #$003C
                    beq       L09B0
                    cmpx      #$003D
                    beq       L09B9
L09EF               tfr       u,d
L09F1               leas      $0C,s
                    puls      pc,u
L09F5               pshs      u
                    ldd       #$FFAE
                    lbsr      L0111
                    leas      -$02,s
                    ldu       #$0000
                    bra       L0A04

L0A04               ldd       $005F
                    cmpd      #$002E
                    beq       L0A4C
                    ldd       #$0002
                    pshs      d
                    lbsr      $0581
                    leas      $02,s
                    std       ,s
                    beq       L0A3F
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
                    lbsr      L0DD4
                    leas      $0C,s
                    std       ,s
                    ldu       ,s
L0A3F               ldd       $005F
                    cmpd      #$0030
                    bne       L0A4C
                    lbsr      $552C
                    bra       L0A04

L0A4C               tfr       u,d
                    bra       L0A98
                    pshs      u
L0A52               ldd       #$FFB8
                    lbsr      L0111
                    leas      -$02,s
                    ldd       $06,s
                    pshs      d
                    lbsr      $0581
                    std       ,s
                    lbsr      L0F19
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    beq       L0A7C
                    ldd       $06,u
                    cmpd      #$0036
                    bne       L0A7C
                    ldd       $08,u
                    std       ,s
                    bra       L0A8B

L0A7C               clra
                    clrb
                    std       ,s
                    leax      L0ED3,pcr
                    pshs      x
                    lbsr      L024C
                    leas      $02,s
L0A8B               stu       -$02,s
                    beq       L0A96
                    pshs      u
                    lbsr      L0394
                    leas      $02,s
L0A96               ldd       ,s
L0A98               leas      $02,s
                    puls      pc,u
L0A9C               pshs      u
                    ldd       #$FFC0
                    lbsr      L0111
                    ldx       $005F
                    bra       L0AF5

L0AA8               ldd       #$0057
                    std       $005F
                    ldd       #$0008
                    bra       L0AC4

L0AB2               ldd       #$0052
                    std       $005F
                    ldd       #$000D
                    bra       L0AC4

L0ABC               ldd       #$0051
                    std       $005F
                    ldd       #$000C
L0AC4               std       $0061
L0AC6               ldd       #$0001
                    puls      pc,u
L0ACB               ldd       $005F
                    cmpd      #$0047
                    blt       L0ADB
                    ldd       $005F
                    cmpd      #$005F
                    ble       L0AEF
L0ADB               ldd       $005F
                    cmpd      #$00A0
                    lblt      L0C90
                    ldd       $005F
                    cmpd      #$00A9
                    lbgt      L0C90
L0AEF               ldd       #$0001
                    lbra      L0C92

L0AF5               cmpx      #$0041
                    beq       L0AA8
                    cmpx      #$0042
                    beq       L0AB2
                    cmpx      #$0043
                    beq       L0ABC
                    cmpx      #$0030
                    beq       L0AC6
                    cmpx      #$0078
                    lbeq      L0AC6
                    cmpx      #$0064
                    lbeq      L0AC6
                    cmpx      #$002F
                    lbeq      L0C90
                    bra       L0ACB
                    puls      pc,u
L0B22               pshs      u
                    ldd       #$FFB8
                    lbsr      L0111
                    ldx       $04,s
                    lbra      L0C94

L0B2F               ldd       $06,s
                    addd      $08,s
                    puls      pc,u
L0B35               ldd       $06,s
                    subd      $08,s
                    puls      pc,u
L0B3B               ldd       $06,s
                    pshs      d
                    ldd       $0a,s
                    lbsr      L7540
                    puls      pc,u
L0B46               ldd       $08,s
                    beq       L0B64
                    ldd       $06,s
                    pshs      d
                    ldd       $0a,s
                    lbsr      L75F4
                    bra       L0B62

L0B55               ldd       $08,s
                    beq       L0B64
                    ldd       $06,s
                    pshs      d
                    ldd       $0a,s
                    lbsr      $75A1
L0B62               puls      pc,u
L0B64               lbsr      L136E
                    lbra      L0C90

L0B6A               ldd       $06,s
                    anda      $08,s
                    andb      $09,s
                    puls      pc,u
L0B72               ldd       $06,s
                    ora       $08,s
                    orb       $09,s
                    puls      pc,u
L0B7A               ldd       $06,s
                    eora      $08,s
                    eorb      $09,s
                    puls      pc,u
L0B82               ldd       $06,s
                    pshs      d
                    ldd       $0a,s
                    lbsr      L7681
                    puls      pc,u
L0B8D               ldd       $06,s
                    pshs      d
                    ldd       $0a,s
                    lbsr      L765E
                    puls      pc,u
L0B98               ldd       $06,s
                    cmpd      $08,s
                    lbne      L0C90
                    ldd       #$0001
                    lbra      L0C92

L0BA7               ldd       $06,s
                    cmpd      $08,s
                    lbeq      L0C90
                    ldd       #$0001
                    lbra      L0C92

L0BB6               ldd       $06,s
                    cmpd      $08,s
                    lble      L0C90
                    ldd       #$0001
                    lbra      L0C92

L0BC5               ldd       $06,s
                    cmpd      $08,s
                    lbge      L0C90
                    ldd       #$0001
                    lbra      L0C92

L0BD4               ldd       $06,s
                    cmpd      $08,s
                    lblt      L0C90
                    ldd       #$0001
                    lbra      L0C92

L0BE3               ldd       $06,s
                    cmpd      $08,s
                    lbgt      L0C90
                    ldd       #$0001
                    lbra      L0C92

L0BF2               ldd       $06,s
                    nega
                    negb
                    sbca      #$00
                    puls      pc,u
L0BFA               ldd       $06,s
                    lbne      L0C90
                    ldd       #$0001
                    lbra      L0C92

L0C06               ldd       $06,s
                    coma
                    comb
                    puls      pc,u
L0C0C               ldd       $06,s
                    lbeq      L0C90
                    ldd       $08,s
                    lbeq      L0C90
                    ldd       #$0001
                    lbra      L0C92

L0C1E               ldd       $06,s
                    bne       L0C28
                    ldd       $08,s
                    lbeq      L0C90
L0C28               ldd       #$0001
                    lbra      L0C92

L0C2E               leas      -$04,s
                    ldd       $0C,s
                    std       $02,s
                    ldd       $0a,s
                    std       ,s
                    ldx       $08,s
                    bra       L0C72

L0C3C               ldd       ,s
                    cmpd      $02,s
                    bhi       L0C6C
                    ldd       #$0001
                    bra       L0C6E

L0C48               ldd       ,s
                    cmpd      $02,s
                    bcc       L0C6C
                    ldd       #$0001
                    bra       L0C6E

L0C54               ldd       ,s
                    cmpd      $02,s
                    bcs       L0C6C
                    ldd       #$0001
                    bra       L0C6E

L0C60               ldd       ,s
                    cmpd      $02,s
                    bls       L0C6C
                    ldd       #$0001
                    bra       L0C6E

L0C6C               clra
                    clrb
L0C6E               leas      $04,s
                    puls      pc,u
L0C72               cmpx      #$0060
                    beq       L0C3C
                    cmpx      #$0061
                    beq       L0C48
                    cmpx      #$0062
                    beq       L0C54
                    bra       L0C60
                    leas      $04,s
L0C85               leax      L0EE5,pcr
                    pshs      x
                    lbsr      L024C
                    leas      $02,s
L0C90               clra
                    clrb
L0C92               puls      pc,u
L0C94               cmpx      #$0050
                    lbeq      L0B2F
                    cmpx      #$0051
                    lbeq      L0B35
                    cmpx      #$0052
                    lbeq      L0B3B
                    cmpx      #$0053
                    lbeq      L0B46
                    cmpx      #$0054
                    lbeq      L0B55
                    cmpx      #$0057
                    lbeq      L0B6A
                    cmpx      #$0058
                    lbeq      L0B72
                    cmpx      #$0059
                    lbeq      L0B7A
                    cmpx      #$0056
                    lbeq      L0B82
                    cmpx      #$0055
                    lbeq      L0B8D
                    cmpx      #$005A
                    lbeq      L0B98
                    cmpx      #$005B
                    lbeq      L0BA7
                    cmpx      #$005F
                    lbeq      L0BB6
                    cmpx      #$005D
                    lbeq      L0BC5
                    cmpx      #$005E
                    lbeq      L0BD4
                    cmpx      #$005C
L0D00               lbeq      L0BE3
                    cmpx      #$0043
                    lbeq      L0BF2
                    cmpx      #$0040
                    lbeq      L0BFA
                    cmpx      #$0044
                    lbeq      L0C06
                    cmpx      #$0047
                    lbeq      L0C0C
                    cmpx      #$0048
                    lbeq      L0C1E
                    cmpx      #$0060
                    lbeq      L0C2E
                    cmpx      #$0061
                    lbeq      L0C2E
                    cmpx      #$0062
                    lbeq      L0C2E
                    cmpx      #$0063
                    lbeq      L0C2E
                    lbra      L0C85
                    puls      pc,u
L0D48               pshs      u
                    ldd       #$FFA2
                    lbsr      L0111
                    leas      -$0e,s
                    ldd       L003F
                    std       $04,s
                    ldd       $0063
                    std       $02,s
                    leax      ,s
                    pshs      x
                    leax      $0C,s
                    pshs      x
                    leax      $10,s
                    pshs      x
                    lbsr      L3C36
                    leas      $06,s
                    std       $08,s
                    pshs      d
                    leax      $0C,s
                    pshs      x
                    leax      $0a,s
                    pshs      x
                    lbsr      L3F8B
                    leas      $06,s
                    std       $08,s
                    leax      >$0047,y
                    pshs      x
                    lbsr      $4205
                    leas      $02,s
                    ldd       $06,s
                    beq       L0D99
                    leax      $0EF7,pcr
                    pshs      x
                    lbsr      L024C
                    leas      $02,s
L0D99               ldd       $02,s
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
                    bsr       L0DD4
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
                    lbsr      $4101
                    leas      $06,s
                    ldd       $06,s
                    leas      $0e,s
                    puls      pc,u
L0DD4               pshs      u
L0DD6               ldd       #$FFBA
                    lbsr      L0111
                    ldd       L002D
                    beq       L0DE8
                    ldu       L002D
                    ldd       $0a,u
                    std       L002D
                    bra       L0DF4

L0DE8               ldd       #$0016
                    pshs      d
                    lbsr      L5C28
                    leas      $02,s
                    tfr       d,u
L0DF4               ldd       $04,s
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
L0E16               pshs      u
L0E18               ldd       #$FFBA
                    lbsr      L0111
                    leax      L0F06,pcr
                    pshs      x
                    lbsr      L024C
                    lbra      L0E79

L0E2A               pshs      u
                    ldd       #$FFB6
                    lbsr      L0111
                    ldu       [$04,s]
                    ldx       $06,u
                    bra       L0E7D

L0E39               pshs      u
                    lbsr      L0F19
                    leas      $02,s
                    std       [$04,s]
                    tfr       d,u
                    leax      ,s
                    bra       L0E59

L0E49               ldd       [$08,u]
                    std       ,u
                    pshs      u
                    lbsr      $24D4
                    leas      $02,s
                    ldu       $08,u
                    bra       L0E5B

L0E59               leas      ,x
L0E5B               ldd       $04,u
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    ldd       ,u
                    pshs      d
                    lbsr      L418B
                    leas      $06,s
                    puls      pc,u
L0E6E               pshs      u
                    ldd       #$000C
                    addd      ,s++
                    pshs      d
                    bsr       L0E2A
L0E79               leas      $02,s
                    puls      pc,u
L0E7D               cmpx      #$0034
                    beq       L0E49
                    cmpx      #$0020
                    beq       L0E5B
                    cmpx      #$0045
                    beq       L0E6E
                    cmpx      #$0046
                    lbeq      L0E6E
                    lbra      L0E39
                    puls      pc,u
L0E98               lsr       L6869
                    fcb       $72
                    lsr       0,y
                    fcb       $65
                    asl       L7072
                    fcb       $65
                    com       $7369
                    clr       $0e,s
                    bra       L0F17
                    rol       -$0d,s
                    com       $696E
                    asr       0,x
L0EB1               clr       -$10,s
                    fcb       $65
                    fcb       $72
                    fcb       $61
                    jmp       $04,s
                    bra       $0F1F
                    asl       $7065
                    com       -$0C,s
                    fcb       $65
                    lsr       0,x
L0EC2               neg       $7269
                    tst       $01,s
                    fcb       $72
                    rol       L2065
                    asl       $7065
                    com       -$0C,s
                    fcb       $65
                    lsr       0,x
L0ED3               com       $0f,s
                    jmp       -$0d,s
                    lsr       $616E
                    lsr       L2072
                    fcb       $65
                    fcb       $71
                    fcb       $75
                    rol       -$0e,s
                    fcb       $65
                    lsr       0,x
L0EE5               com       $0f,s
                    jmp       -$0d,s
                    lsr       $616E
                    lsr       $206F
                    neg       $6572
                    fcb       $61
                    lsr       $6F72
                    neg       $006E
                    fcb       $61
                    tst       $05,s
                    bra       L0F66
                    jmp       0,y
                    fcb       $61
                    bra       $0F65
                    fcb       $61
                    com       L7400
L0F06               fcb       $65
                    asl       L7072
                    fcb       $65
                    com       $7369
                    clr       $0e,s
                    bra       $0F7F
                    rol       -$0d,s
                    com       $696E
L0F17               asr       0,x
L0F19               pshs      u
L0F1B               ldd       #$FFAE
                    lbsr      L0111
                    ldu       $04,s
                    leas      -$0C,s
                    stu       -$02,s
                    lbeq      L1000
                    ldd       $0a,u
                    pshs      d
                    bsr       L0F19
                    leas      $02,s
                    std       $0a,u
                    ldd       $0C,u
                    pshs      d
                    lbsr      L0F19
                    leas      $02,s
                    std       $0C,u
                    pshs      u
                    lbsr      L1383
                    leas      $02,s
                    tfr       d,u
                    pshs      u
                    lbsr      L1324
                    std       ,s++
                    beq       L0F57
                    leax      $0C,s
                    lbra      L0FFE

L0F57               pshs      u
                    lbsr      L1006
                    leas      $02,s
                    tfr       d,u
                    ldd       $0a,u
                    std       $0a,s
                    ldd       $0C,u
L0F66               std       $08,s
                    ldd       $06,u
                    std       $04,s
                    cmpd      #$0064
                    bne       L0FB5
                    ldx       $0a,s
                    ldd       $06,x
                    cmpd      #$0036
                    bne       L0FB5
                    ldx       $0a,s
                    ldd       $08,x
                    beq       L0F8E
                    ldx       $08,s
                    ldd       $0a,x
                    std       $02,s
                    ldx       $08,s
                    ldd       $0C,x
                    bra       L0F98

L0F8E               ldx       $08,s
                    ldd       $0C,x
                    std       $02,s
                    ldx       $08,s
                    ldd       $0a,x
L0F98               pshs      d
                    lbsr      L0394
                    leas      $02,s
                    ldd       $08,s
                    pshs      d
                    lbsr      L03B5
                    leas      $02,s
                    ldd       $0a,s
                    pshs      d
                    lbsr      L03B5
                    leas      $02,s
                    pshs      u
                    bra       L0FF5

L0FB5               ldd       $04,s
                    cmpd      #$0042
                    bne       L0FC7
                    ldx       $0a,s
                    ldd       $06,x
                    cmpd      #$0041
                    beq       L0FD9
L0FC7               ldd       $04,s
                    cmpd      #$0041
                    bne       L1000
                    ldx       $0a,s
                    ldd       $06,x
                    cmpd      #$0042
                    bne       L1000
L0FD9               ldx       $0a,s
                    ldd       $0a,x
                    std       $02,s
                    ldd       ,u
                    std       [$02,s]
                    ldd       $02,u
                    ldx       $02,s
                    std       $02,x
                    pshs      u
                    lbsr      L03B5
                    leas      $02,s
                    ldd       $0a,s
                    pshs      d
L0FF5               lbsr      L03B5
                    leas      $02,s
                    ldu       $02,s
                    bra       L1000

L0FFE               leas      -$0C,x
L1000               tfr       u,d
                    leas      $0C,s
                    puls      pc,u
L1006               pshs      u
L1008               ldd       #$FFA8
                    lbsr      L0111
                    ldu       $04,s
                    leas      -$0e,s
                    stu       -$02,s
                    bne       L101B
                    clra
                    clrb
                    lbra      L1320

L101B               ldd       $0a,u
                    std       $0C,s
                    ldd       $0C,u
                    std       $0a,s
                    ldd       $06,u
                    std       $06,s
                    pshs      d
                    lbsr      L049C
                    std       ,s++
                    bne       L1042
                    ldd       $06,s
                    cmpd      #$0047
                    beq       L1042
                    ldd       $06,s
                    cmpd      #$0048
                    lbne      L1259
L1042               ldx       $0C,s
                    ldd       $06,x
                    cmpd      #$0036
                    bne       L1051
                    ldd       #$0001
                    bra       L1053

L1051               clra
                    clrb
L1053               std       $02,s
                    pshs      d
                    ldx       $0C,s
                    ldd       $06,x
                    cmpd      #$0036
                    bne       L1066
                    ldd       #$0001
                    bra       L1068

L1066               clra
                    clrb
L1068               std       $02,s
                    anda      ,s+
                    andb      ,s+
                    std       -$02,s
                    beq       L1077
                    leax      $0e,s
                    lbra      L126A

L1077               ldd       $02,s
                    beq       L10B7
                    ldx       $06,s
                    bra       L1096

L107F               ldd       $0C,s
                    std       $08,s
                    ldd       $0a,s
                    std       $0C,s
                    std       $0a,u
                    ldd       $08,s
                    std       $0a,s
                    std       $0C,u
                    ldd       #$0001
                    std       ,s
                    bra       L10B7

L1096               cmpx      #$0050
                    beq       L107F
                    cmpx      #$0052
                    lbeq      L107F
                    cmpx      #$0057
                    lbeq      L107F
                    cmpx      #$0058
                    lbeq      L107F
                    cmpx      #$0059
                    lbeq      L107F
L10B7               ldx       $06,s
                    lbra      L1225

L10BC               ldd       ,s
                    lbeq      L131E
                    ldx       $0a,s
                    ldd       $08,x
                    lbeq      L11EA
                    lbra      L131E

L10CD               ldd       ,s
                    lbeq      L131E
                    ldx       $0a,s
                    ldd       $08,x
                    lbeq      L11EA
                    ldx       $0C,s
                    ldx       $06,x
                    lbra      L1134

L10E2               ldx       $0C,s
                    ldx       $0a,x
                    ldd       $14,x
                    leax      $14,x
                    pshs      x,d
                    ldx       $0e,s
                    ldd       $08,x
                    addd      ,s++
                    std       [,s++]
                    bra       L10FA

L10F8               leas      -$0e,x
L10FA               ldd       $0C,s
                    std       $08,s
                    pshs      u
                    lbsr      L03B5
                    leas      $02,s
                    ldd       $0a,s
                    pshs      d
                    lbsr      L03B5
                    leas      $02,s
                    ldu       $08,s
                    lbra      L131E

L1113               ldx       $0C,s
                    ldx       $0C,x
                    ldd       $06,x
                    cmpd      #$0036
                    lbne      L131E
                    ldx       $0C,s
                    ldx       $0C,x
                    ldd       $08,x
                    leax      $08,x
                    pshs      x,d
                    ldx       $0e,s
                    ldd       $08,x
                    addd      ,s++
                    lbra      L11CD

L1134               cmpx      #$0041
                    lbeq      L10E2
                    cmpx      #$0050
                    beq       L1113
                    lbra      L131E

L1143               ldd       ,s
                    beq       L1162
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
                    lbsr      L1006
                    leas      $02,s
                    lbra      L1320

L1162               ldd       $02,s
                    lbeq      L131E
                    ldx       $0C,s
                    ldd       $08,x
                    lbne      L131E
                    ldd       #$0043
                    std       $06,u
                    ldd       $0a,s
                    std       $0a,u
                    clra
                    clrb
                    std       $0C,u
                    ldd       $0C,s
                    lbra      L121B

L1182               ldd       ,s
                    lbeq      L131E
                    ldx       $0a,s
                    ldd       $08,x
                    beq       L119D
                    lbra      L131E

L1191               ldd       ,s
                    lbeq      L131E
                    ldx       $0a,s
                    ldx       $08,x
                    bra       L11D1

L119D               leax      $0e,s
                    lbra      L11FF

L11A2               ldx       $0C,s
                    ldd       $06,x
                    cmpd      #$0052
                    lbne      L131E
                    ldx       $0C,s
                    ldx       $0C,x
                    ldd       $06,x
                    cmpd      #$0036
                    lbne      L131E
                    ldx       $0C,s
                    ldx       $0C,x
                    ldd       $08,x
                    leax      $08,x
                    pshs      x,d
                    ldx       $0e,s
                    ldd       $08,x
                    lbsr      L7540
L11CD               std       [,s++]
                    bra       L11EA

L11D1               stx       -$02,s
                    beq       L119D
                    cmpx      #$0001
                    beq       L11EA
                    bra       L11A2

L11DC               ldd       ,s
                    beq       L11EF
                    ldx       $0a,s
                    ldd       $08,x
                    cmpd      #$0001
                    bne       L11EF
L11EA               leax      $0e,s
                    lbra      L10F8

L11EF               ldd       $02,s
                    lbeq      L131E
                    ldx       $0C,s
                    ldd       $08,x
                    lbne      L131E
                    bra       L1201

L11FF               leas      -$0e,x
L1201               ldd       #$0036
                    std       $06,u
                    clra
                    clrb
L1208               std       $08,u
                    clra
                    clrb
                    std       $0C,u
                    std       $0a,u
                    ldd       $0C,s
                    pshs      d
                    lbsr      L03B5
                    leas      $02,s
                    ldd       $0a,s
L121B               pshs      d
                    lbsr      L03B5
L1220               leas      $02,s
                    lbra      L131E

L1225               cmpx      #$0058
                    lbeq      L10BC
                    cmpx      #$0059
                    lbeq      L10BC
                    cmpx      #$0050
                    lbeq      L10CD
                    cmpx      #$0051
                    lbeq      L1143
                    cmpx      #$0057
                    lbeq      L1182
                    cmpx      #$0052
                    lbeq      L1191
                    cmpx      #$0053
                    lbeq      L11DC
                    lbra      L131E

L1259               ldx       $06,s
                    lbra      L1309

L125E               ldx       $0C,s
                    ldd       $06,x
                    cmpd      #$0036
                    bne       L128E
                    bra       L126C

L126A               leas      -$0e,x
L126C               ldd       #$0036
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
                    lbsr      L0B22
                    leas      $06,s
                    lbra      L1208

L128E               ldx       $0C,s
                    ldd       $06,x
                    cmpd      #$004A
                    bne       L12DD
                    leas      -$02,s
                    ldx       $0e,s
                    ldd       $08,x
                    std       ,s
                    bne       L12AE
                    ldd       #$0004
                    pshs      d
                    lbsr      L5C28
                    leas      $02,s
                    std       ,s
L12AE               ldx       $08,s
                    bra       L12CB

L12B2               ldx       ,s
                    pshs      x
                    ldx       $02,s
                    lbsr      L7494
                    bra       L12C6

L12BD               ldx       ,s
                    pshs      x
                    ldx       $02,s
                    lbsr      L74A8
L12C6               lbsr      L74D4
                    bra       L12D5

L12CB               cmpx      #$0043
                    beq       L12B2
                    cmpx      #$0044
                    beq       L12BD
L12D5               ldd       ,s
                    ldx       $0e,s
                    std       $08,x
                    bra       L12FD

L12DD               ldx       $0C,s
                    ldd       $06,x
                    cmpd      #$004B
                    bne       L131E
                    leas      -$02,s
                    ldx       $0e,s
                    ldd       $08,x
                    std       ,s
                    beq       L12FD
                    ldx       ,s
                    pshs      x
                    ldx       $02,s
                    lbsr      $6974
                    lbsr      $6A00
L12FD               pshs      u
                    lbsr      L03B5
                    leas      $02,s
                    ldu       $0e,s
                    lbra      L1220

L1309               cmpx      #$0040
                    lbeq      L125E
                    cmpx      #$0044
                    lbeq      L125E
                    cmpx      #$0043
                    lbeq      L125E
L131E               tfr       u,d
L1320               leas      $0e,s
                    puls      pc,u
L1324               pshs      u
                    ldd       #$FFC0
                    lbsr      L0111
                    ldu       $04,s
                    stu       -$02,s
                    beq       L136A
                    ldx       $06,u
                    bra       L133B

L1336               ldd       #$0001
                    puls      pc,u
L133B               cmpx      #$0076
                    beq       L1336
                    cmpx      #$006F
                    lbeq      L1336
                    cmpx      #$0036
                    lbeq      L1336
                    cmpx      #$004A
                    lbeq      L1336
                    cmpx      #$004B
                    lbeq      L1336
                    cmpx      #$0034
                    lbeq      L1336
                    cmpx      #$0037
                    lbeq      L1336
L136A               clra
                    clrb
                    puls      pc,u
L136E               pshs      u
                    ldd       #$FFBA
                    lbsr      L0111
                    leax      L2676,pcr
                    pshs      x
                    lbsr      L024C
                    leas      $02,s
                    puls      pc,u
L1383               pshs      u
L1385               ldd       #$FF9C
                    lbsr      L0111
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
                    lbra      $1E4A
                    ldx       $18,s
                    ldd       $08,x
                    std       $10,s
                    ldx       $10,s
                    ldd       $08,x
                    cmpd      #start
                    bne       L13E7
                    leax      L2685,pcr
                    pshs      x
                    ldd       $1a,s
                    pshs      d
                    lbsr      L0294
                    leas      $04,s
                    ldd       $18,s
                    pshs      d
                    lbsr      L25E7
                    leas      $02,s
                    lbra      $1F6C

L13E7               ldd       [$10,s]
                    std       $0C,s
                    ldx       $10,s
                    ldd       $04,x
                    std       $06,s
                    ldd       $0C,s
                    clra
                    andb      #$0f
                    cmpd      #$000A
                    bne       L1428
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
                    lbsr      $4101
                    leas      $06,s
                    leas      $02,s
L1428               ldx       $10,s
                    ldd       $02,x
                    std       $0a,s
                    ldd       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    beq       L1447
                    ldd       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0030
                    lbne      L14AA
L1447               ldu       $18,s
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
                    lbsr      L0DD4
                    leas      $0C,s
                    std       $18,s
                    ldd       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    bne       L1495
                    ldd       $06,s
                    pshs      d
                    lbsr      L04B1
                    leas      $02,s
                    std       $06,s
                    ldd       $0C,s
                    pshs      d
                    lbsr      L0478
                    leas      $02,s
                    bra       L1497

L1495               ldd       $0C,s
L1497               std       ,u
                    pshs      d
                    lbsr      L0484
                    leas      $02,s
                    std       $0C,s
                    ldd       #$0001
                    std       $12,u
                    bra       L14D1

L14AA               ldx       $10,s
                    ldd       $08,x
                    std       $04,s
                    tfr       d,x
                    bra       L14C5

L14B5               ldd       $04,s
                    ldx       $18,s
                    std       $06,x
                    clra
                    clrb
                    ldx       $18,s
                    std       $08,x
                    bra       L14D1

L14C5               cmpx      #$0076
                    beq       L14B5
                    cmpx      #$006F
                    lbeq      L14B5
L14D1               ldd       #$0001
                    bra       L14D8
                    clra
                    clrb
L14D8               std       $08,s
                    lbra      $1F6C
                    ldd       #$0008
                    std       $0C,s
                    ldd       #$0001
                    std       $08,s
                    ldd       #$0004
                    lbra      L1642
                    ldd       #$0006
                    std       $0C,s
                    ldd       #$0001
                    std       $08,s
                    ldd       #$0008
                    lbra      L1642
                    ldd       #$0012
                    std       $0C,s
                    ldd       #$0001
                    lbra      L1642
                    pshs      u
L150A               lbsr      $24D4
                    leas      $02,s
                    ldd       [$18,s]
                    std       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0030
                    beq       L1528
                    ldd       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    bne       L1543
L1528               leax      $269E,pcr
                    pshs      x
                    ldd       $1a,s
                    pshs      d
                    lbsr      L0294
                    leas      $04,s
                    ldd       $0C,s
                    pshs      d
                    lbsr      L0484
                    leas      $02,s
                    std       $0C,s
L1543               ldd       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L155C
                    ldd       #$0001
                    pshs      d
                    pshs      u
                    lbsr      L2028
                    leas      $04,s
                    bra       L1569

L155C               ldd       $0C,s
                    pshs      d
                    pshs      u
                    lbsr      L2028
                    leas      $04,s
                    std       $0C,s
L1569               ldx       $18,s
                    ldd       $04,x
                    std       $06,s
                    ldx       $18,s
                    ldd       $02,x
                    std       $0a,s
                    ldd       $18,s
                    pshs      d
                    lbsr      L03B5
                    leas      $02,s
                    stu       $18,s
                    lbra      $1F6C
                    ldd       #$0001
                    pshs      d
                    pshs      u
                    lbsr      L2464
                    leas      $04,s
                    ldd       $06,u
                    cmpd      #$0076
                    beq       L15A3
                    ldd       $06,u
                    cmpd      #$006F
                    bne       L15BA
L15A3               leax      $26AA,pcr
                    pshs      x
                    ldd       $1a,s
                    pshs      d
                    lbsr      L0294
                    leas      $04,s
                    pshs      u
                    lbsr      L25E7
                    leas      $02,s
L15BA               ldd       $12,u
                    std       $08,s
                    ldd       $02,u
                    std       $0a,s
                    ldd       ,u
                    pshs      d
                    lbsr      L0484
                    leas      $02,s
                    std       $0C,s
                    ldd       $04,u
                    std       $06,s
                    lbra      $1F6C
                    ldd       $04,u
L15D7               std       $06,s
                    ldd       ,u
                    std       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L1619
                    ldd       $0C,s
                    pshs      d
                    lbsr      L0478
                    leas      $02,s
                    std       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    bne       L163B
                    ldd       $0C,s
                    pshs      d
                    lbsr      L0478
                    std       ,s
                    lbsr      L0484
                    leas      $02,s
                    std       $0C,s
                    ldd       $18,s
                    pshs      d
                    lbsr      L03B5
                    leas      $02,s
                    stu       $18,s
                    bra       L163B

L1619               leax      $26BD,pcr
                    pshs      x
                    pshs      u
                    lbsr      L0294
                    leas      $04,s
                    pshs      u
                    lbsr      L25E7
                    leas      $02,s
                    ldd       #$0011
                    std       ,u
                    ldd       #$0001
                    std       $0C,s
                    clra
                    clrb
                    std       $06,s
L163B               ldd       $12,u
                    std       $08,s
                    ldd       $02,u
L1642               std       $0a,s
                    lbra      $1F6C
                    leax      ,s
L1649               pshs      x
                    leax      $0e,s
                    pshs      x
                    ldd       $16,s
                    pshs      d
                    lbsr      $2503
                    leas      $06,s
                    std       $0a,s
                    ldx       $12,s
                    ldd       $04,x
                    std       $06,s
                    ldd       #$0001
                    pshs      d
                    pshs      u
                    lbsr      L2464
                    leas      $04,s
                    ldx       $12,s
                    ldd       $08,x
                    bne       L169B
                    ldd       ,s
                    bne       L169B
                    ldd       $12,s
                    pshs      d
                    lbsr      L03B5
                    leas      $02,s
                    ldd       $18,s
                    pshs      d
                    lbsr      L03B5
                    leas      $02,s
                    stu       $18,s
                    ldx       $18,s
                    ldd       $12,x
                    std       $08,s
                    lbra      L16FE

L169B               ldd       $12,u
                    std       $08,s
                    ldd       $06,u
                    cmpd      #$0042
                    bne       L16C0
                    ldd       $0a,u
                    std       $10,s
                    pshs      u
                    lbsr      L03B5
                    leas      $02,s
                    ldu       $10,s
                    tfr       u,d
                    ldx       $18,s
                    std       $0a,x
                    bra       L16F3

L16C0               ldd       ,u
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
                    lbsr      L0DD4
                    leas      $0C,s
                    ldx       $18,s
                    std       $0a,x
                    tfr       d,u
                    ldd       $04,s
                    pshs      d
                    lbsr      L0484
                    leas      $02,s
                    std       ,u
L16F3               ldd       $08,s
                    std       $12,u
                    leax      $14,s
                    lbra      L175C

L16FE               lbra      $1F6C
                    leax      ,s
L1703               pshs      x
                    leax      $0e,s
                    pshs      x
                    ldd       $16,s
                    pshs      d
                    lbsr      $2503
                    leas      $06,s
                    std       $0a,s
                    ldx       $12,s
                    ldd       $04,x
                    std       $06,s
                    ldd       ,u
                    std       $04,s
                    cmpd      #$0001
                    beq       L1755
                    ldd       $04,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L1736
                    ldd       #$0001
                    bra       L1738

L1736               clra
                    clrb
L1738               bne       L1755
                    leax      L26CE,pcr
                    pshs      x
                    pshs      u
                    lbsr      L0294
                    leas      $04,s
                    ldd       #$0036
                    std       $06,u
                    clra
                    clrb
                    std       $08,u
                    clra
                    clrb
                    std       $12,u
L1755               ldd       $12,u
                    std       $08,s
                    bra       L175F

L175C               leas      -$14,x
L175F               ldd       #$0050
                    ldx       $18,s
                    std       $06,x
                    ldd       $18,s
                    pshs      d
                    lbsr      L1006
                    leas      $02,s
                    std       $18,s
                    ldd       ,s
                    bne       L17BC
                    ldd       $0C,s
                    pshs      d
                    lbsr      L0484
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
                    lbsr      L0DD4
                    leas      $0C,s
                    std       $18,s
L17BC               lbra      $1F6C
                    ldd       ,u
L17C1               std       $0C,s
                    ldd       $06,u
                    cmpd      #$0041
                    bne       L17FB
                    ldd       $0C,s
                    pshs      d
                    lbsr      L0478
                    leas      $02,s
                    clra
                    andb      #$30
                    cmpd      #$0030
                    bne       L17FB
                    ldd       $0a,u
                    ldx       $18,s
                    std       $0a,x
                    std       $10,s
                    pshs      u
                    lbsr      L03B5
                    leas      $02,s
                    ldd       [$10,s]
L17F1               pshs      d
                    lbsr      L0478
                    leas      $02,s
                    lbra      L185F

L17FB               ldd       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0030
                    bne       L180A
                    ldd       $0C,s
                    bra       L17F1

L180A               ldd       $0C,s
                    bne       L184D
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
                    lbsr      L01F7
                    leas      $06,s
                    ldd       #$0001
                    bra       L185F

L184D               leax      L26EA,pcr
                    pshs      x
                    pshs      u
                    lbsr      L0294
                    leas      $04,s
                    ldd       $0C,s
                    clra
                    andb      #$0f
L185F               std       $0C,s
                    ldd       $04,u
                    std       $06,s
                    ldd       $02,u
                    std       $0a,s
                    pshs      u
L186B               lbsr      $24D4
                    leas      $02,s
                    pshs      u
                    lbsr      L25B6
                    leas      $02,s
                    ldx       ,u
                    bra       L188E

L187B               ldd       #$0001
                    bra       L1883

L1880               ldd       #$0006
L1883               pshs      d
                    pshs      u
                    lbsr      L2028
                    leas      $04,s
                    bra       L1898

L188E               cmpx      #$0002
                    beq       L187B
                    cmpx      #$0005
                    beq       L1880
L1898               lbra      $1F6C
                    ldx       $12,s
                    ldd       $02,x
                    std       $0a,s
                    ldd       [$12,s]
                    std       $0C,s
                    ldx       $12,s
                    ldd       $04,x
                    std       $06,s
                    lbra      $1F6C
                    ldd       ,u
L18B3               clra
                    andb      #$30
                    cmpd      #$0010
                    beq       L18C3
                    pshs      u
                    lbsr      L1FBD
                    leas      $02,s
L18C3               ldd       #$0001
                    lbra      L1E0E
                    pshs      u
L18CB               lbsr      L1FBD
                    leas      $02,s
                    lbra      L1E0E
                    pshs      u
L18D5               lbsr      L1FBD
                    leas      $02,s
                    std       $0C,s
                    cmpd      #$0006
                    lbne      L19C4
                    pshs      u
                    lbsr      L265D
                    leas      $02,s
                    pshs      u
                    lbra      L19BF
                    clra
                    clrb
L18F2               pshs      d
                    pshs      u
                    lbsr      L2464
                    leas      $04,s
                    ldd       $02,u
                    std       $0a,s
                    ldd       ,u
                    std       $0C,s
                    clra
                    andb      #$30
                    beq       L1921
                    ldd       $04,u
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    lbsr      L0478
                    std       ,s
                    lbsr      L418B
                    leas      $06,s
                    bra       L1924

L1921               ldd       #$0001
L1924               ldx       $18,s
                    std       $08,x
                    ldd       $12,u
                    std       $08,s
                    ldd       $06,u
                    cmpd      #$0042
                    lbne      L1AA8
                    ldd       $08,s
                    addd      #$0001
                    lbra      L1AA6
                    ldd       ,u
L1942               clra
                    andb      #$30
                    cmpd      #$0010
                    beq       L1952
                    pshs      u
                    lbsr      L1FBD
                    leas      $02,s
L1952               ldd       [$12,s]
                    clra
                    andb      #$30
                    cmpd      #$0010
                    lbeq      L19C4
                    ldd       $12,s
                    pshs      d
                    lbsr      L1FBD
                    bra       L19C2
                    ldd       $12,s
                    pshs      d
                    pshs      u
                    lbsr      $2341
                    leas      $04,s
                    std       $0C,s
                    cmpd      #$0006
                    bne       L1983
                    leax      $14,s
                    bra       L19A7

L1983               lbra      $1F6C
                    pshs      u
L1988               lbsr      L1FBD
                    leas      $02,s
                    std       $0C,s
                    cmpd      #$0006
                    beq       L19AA
                    ldd       $12,s
                    pshs      d
                    lbsr      L1FBD
                    leas      $02,s
                    cmpd      #$0006
                    bne       L19C7
                    bra       L19AA

L19A7               leas      -$14,x
L19AA               leax      L26F9,pcr
                    pshs      x
                    ldd       $1a,s
                    pshs      d
                    lbsr      L0294
                    leas      $04,s
                    ldd       $18,s
                    pshs      d
L19BF               lbsr      L25E7
L19C2               leas      $02,s
L19C4               lbra      $1F6C

L19C7               ldd       #$0001
                    pshs      d
                    ldd       $14,s
                    pshs      d
                    lbsr      L2028
                    lbra      L1A50
                    ldd       ,u
L19D9               clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L19EE
                    ldd       [$12,s]
                    clra
                    andb      #$30
                    cmpd      #$0010
                    beq       L1A00
L19EE               ldd       $12,s
                    pshs      d
                    pshs      u
                    lbsr      $2341
                    leas      $04,s
                    cmpd      #$0007
                    bne       L1A0A
L1A00               ldd       $0e,s
                    addd      #$0004
                    ldx       $18,s
                    std       $06,x
L1A0A               lbra      $1F6C
                    ldd       ,u
L1A0F               clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L1A46
                    ldd       [$12,s]
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L1A29
                    ldd       #$0001
                    bra       L1A2B

L1A29               clra
                    clrb
L1A2B               bne       L1A52
                    ldd       $12,s
                    pshs      d
                    lbsr      L1FBD
                    leas      $02,s
                    ldd       #$0001
                    pshs      d
                    ldd       $14,s
                    pshs      d
                    lbsr      L2028
                    bra       L1A50

L1A46               ldd       $12,s
                    pshs      d
                    pshs      u
                    lbsr      $2341
L1A50               leas      $04,s
L1A52               lbra      $1F6C
                    ldd       [$12,s]
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L1A74
                    leas      -$02,s
                    stu       ,s
                    ldu       $14,s
                    ldd       ,s
                    std       $14,s
                    leas      $02,s
                    ldx       $18,s
                    stu       $0a,x
L1A74               ldd       $02,u
                    std       $0a,s
                    ldd       ,u
                    std       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L1A8F
                    ldd       $04,u
                    std       $06,s
                    leax      $14,s
                    lbra      L1B8E

L1A8F               ldd       $12,s
                    pshs      d
                    pshs      u
                    lbsr      $2341
                    leas      $04,s
                    std       $0C,s
                    ldd       $12,u
                    ldx       $12,s
                    addd      $12,x
L1AA6               std       $08,s
L1AA8               lbra      $1F6C
                    ldd       $12,u
                    ldx       $12,s
                    addd      $12,x
                    std       $08,s
                    ldd       ,u
                    std       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    lbne      L1E02
                    ldd       $02,u
                    std       $0a,s
                    ldd       $04,u
                    std       $06,s
                    ldd       [$12,s]
                    clra
                    andb      #$30
                    cmpd      #$0010
                    lbne      L1B91
                    ldd       $08,s
                    ldx       $18,s
                    std       $12,x
                    ldd       $0C,s
                    cmpd      [$12,s]
                    bne       L1AF5
                    ldd       $0a,s
                    ldx       $12,s
                    cmpd      $02,x
                    beq       L1B08
L1AF5               leax      L270F,pcr
                    pshs      x
                    ldd       $1a,s
                    pshs      d
                    lbsr      L0294
                    leas      $04,s
                    lbra      L1B7F

L1B08               ldd       $0C,s
                    pshs      d
                    lbsr      L0478
                    leas      $02,s
                    std       $0C,s
                    ldd       $06,s
                    pshs      d
                    ldd       $0C,s
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    lbsr      L418B
                    leas      $06,s
                    std       $0a,s
                    cmpd      #$0001
                    lbeq      L1B7F
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
                    lbsr      L0DD4
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
                    lbsr      L0DD4
                    leas      $0C,s
                    std       $18,s
L1B7F               ldd       #$0002
                    std       $0a,s
                    clra
                    clrb
                    std       $06,s
                    ldd       #$0001
                    lbra      L1E0E

L1B8E               leas      -$14,x
L1B91               ldd       $12,s
                    pshs      d
                    lbsr      L1FBD
                    leas      $02,s
                    ldd       [$12,s]
                    pshs      d
                    lbsr      L262E
                    std       ,s++
                    bne       L1BBB
                    ldd       $12,s
                    pshs      d
                    lbsr      L265D
                    leas      $02,s
                    ldd       $12,s
                    pshs      d
                    lbsr      L25E7
                    leas      $02,s
L1BBB               ldd       #$0001
                    pshs      d
                    ldd       $14,s
                    pshs      d
                    lbsr      L2028
                    leas      $04,s
                    ldd       $12,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    lbsr      L23C5
                    leas      $08,s
                    ldx       $18,s
                    std       $0C,x
                    ldd       $12,u
                    ldx       $12,s
                    addd      $12,x
                    std       $08,s
                    lbra      $1F6C
                    clra
                    clrb
L1BF7               pshs      d
                    pshs      u
                    lbsr      L2464
                    leas      $04,s
                    ldd       $12,s
                    pshs      d
                    lbsr      $24D4
                    leas      $02,s
                    ldd       $12,s
                    pshs      d
                    lbsr      L25B6
                    leas      $02,s
                    std       $02,s
                    ldd       ,u
                    std       $0b,y
                    inc       $0f,u
                    andb      #$30
                    cmpd      #$0010
                    bne       L1C3C
                    ldd       $02,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    beq       L1C3C
                    ldd       $02,s
                    pshs      d
                    lbsr      $262F
                    std       ,s++
                    lbeq      $1CBC
L1C3C               ldd       $02,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L1C5F
                    ldd       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    beq       L1C5F
                    ldd       $0C,s
                    pshs      d
                    lbsr      $262F
                    std       ,s++
                    lbeq      $1CBC
L1C5F               ldd       $0C,s
                    pshs      d
                    ldd       $14,s
                    pshs      d
                    lbsr      $2029
                    leas      $04,s
                    leax      $14,s
                    lbra      $1D51
                    leas      -$14,x
                    clra
                    clrb
                    pshs      d
                    pshs      u
                    lbsr      $2465
                    leas      $04,s
                    ldd       $12,s
                    pshs      d
                    lbsr      $1FBE
                    leas      $02,s
                    ldd       $12,s
                    pshs      d
                    lbsr      $25B7
                    leas      $02,s
                    std       $02,s
                    ldd       ,u
                    std       $0b,y
                    inc       $0f,u
                    andb      #$30
                    cmpd      #$0010
                    bne       L1CD1
                    ldx       $0e,s
                    bra       L1CC3

L1CA9               ldd       #$0001
                    pshs      d
                    ldd       $14,s
                    pshs      d
                    lbsr      L202A
                    leas      $04,s
                    leax      $14,s
                    bra       L1CF3

L1CBD               leax      $14,s
                    lbra      L1D69

L1CC3               cmpx      #$00A1
                    beq       L1CA9
                    cmpx      #$00A0
                    lbeq      L1CA9
                    bra       L1CBD

L1CD1               ldx       $0e,s
                    lbra      L1D43

L1CD6               ldd       $0C,s
                    cmpd      #$0005
                    bne       L1CE3
                    ldd       #$0006
                    bra       L1CE5

L1CE3               ldd       $0C,s
L1CE5               pshs      d
                    ldd       $14,s
                    pshs      d
                    lbsr      L202A
                    leas      $04,s
                    bra       L1CF6

L1CF3               leas      -$14,x
L1CF6               ldd       $0e,s
                    addd      #$FFB0
                    ldx       $18,s
                    std       $06,x
                    ldd       $18,s
                    pshs      d
                    lbsr      L1385
                    leas      $02,s
                    std       $18,s
                    ldd       $0C,s
                    cmpd      #$0002
                    bne       L1D2D
                    ldd       $0a,u
                    ldx       $18,s
                    std       $0a,x
                    pshs      u
                    lbsr      L03B7
                    leas      $02,s
                    ldx       $18,s
                    ldu       $0a,x
                    ldd       #$0001
                    std       $0C,s
L1D2D               ldd       $0e,s
                    addd      #$FFB0
                    ldx       $18,s
                    cmpd      $06,x
                    bne       L1D55
                    ldd       $0e,s
                    ldx       $18,s
                    std       $06,x
                    bra       L1D55

L1D43               cmpx      #$00A6
                    beq       L1CF6
                    cmpx      #$00A5
                    lbeq      L1CF6
                    lbra      L1CD6
                    leas      -$14,x
L1D55               ldd       $02,u
                    std       $0a,s
                    ldd       $12,u
                    ldx       $12,s
                    addd      $12,x
                    std       $08,s
                    ldd       $04,u
                    lbra      L1E26

L1D69               leas      -$14,x
                    leax      $2722,pcr
                    pshs      x
                    ldd       $1a,s
                    pshs      d
                    lbsr      L0296
                    lbra      L1E47

L1D7D               ldd       ,u
                    std       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L1DDC
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
                    bne       L1DCF
                    ldd       $0C,s
                    cmpd      [$12,s]
                    bne       L1DB5
                    ldd       $02,u
                    ldx       $12,s
                    cmpd      $02,x
                    beq       L1DC8
L1DB5               leax      $2730,pcr
                    pshs      x
                    ldd       $1a,s
                    pshs      d
                    lbsr      L0296
                    leas      $04,s
                    lbra      L1F6E

L1DC8               clra
                    clrb
                    std       $06,s
                    lbra      L1F6E

L1DCF               ldd       $12,s
                    pshs      d
L1DD4               lbsr      L1F91
                    leas      $02,s
                    lbra      L1F6E

L1DDC               ldd       [$12,s]
                    std       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L1E04
                    ldx       $12,s
                    ldd       $02,x
                    std       $0a,s
                    ldx       $12,s
                    ldd       $12,x
                    std       $08,s
                    ldx       $12,s
                    ldd       $04,x
                    std       $06,s
                    pshs      u
L1E02               bra       L1DD4

L1E04               ldd       $12,s
                    pshs      d
                    pshs      u
                    lbsr      L2343
L1E0E               leas      $04,s
                    std       $0C,s
                    lbra      L1F6E

L1E15               ldd       [$12,s]
                    std       $0C,s
                    ldx       $12,s
                    ldd       $02,x
                    std       $0a,s
                    ldx       $12,s
                    ldd       $04,x
L1E26               std       $06,s
                    lbra      L1F6E

L1E2B               ldd       $0e,s
                    cmpd      #$00A0
                    blt       L1E39
                    leax      $14,s
                    lbra      $1C74

L1E39               leax      $2741,pcr
                    pshs      x
                    ldd       $1a,s
                    pshs      d
                    lbsr      L0262
L1E47               leas      $04,s
                    lbra      L1F6E
                    cmpx      #$0034
                    lbeq      $13B9
                    cmpx      #$0036
                    lbeq      L14D8
                    cmpx      #$004A
                    lbeq      $14DF
                    cmpx      #$004B
                    lbeq      $14EF
                    cmpx      #$0037
                    lbeq      $14FF
                    cmpx      #$0020
                    lbeq      L150A
                    cmpx      #$0041
                    lbeq      $1589
                    cmpx      #$0042
                    lbeq      L15D7
                    cmpx      #$0045
                    lbeq      L1649
                    cmpx      #$0046
                    lbeq      L1703
                    cmpx      #$0065
                    lbeq      L17C1
                    cmpx      #$000B
                    lbeq      L186B
                    cmpx      #$0030
                    lbeq      $189D
                    cmpx      #$0040
                    lbeq      L18B3
                    cmpx      #$0043
                    lbeq      L18CB
                    cmpx      #$0044
                    lbeq      L18D5
                    cmpx      #$003C
                    lbeq      L18F2
                    cmpx      #$003E
                    lbeq      L18F2
                    cmpx      #$003D
                    lbeq      L18F2
                    cmpx      #$003F
                    lbeq      L18F2
                    cmpx      #$0047
                    lbeq      L1942
                    cmpx      #$0048
                    lbeq      L1942
                    cmpx      #$0053
                    lbeq      L1E04
                    cmpx      #$0052
                    lbeq      L1E04
                    cmpx      #$0057
                    lbeq      $196C
                    cmpx      #$0058
                    lbeq      $196C
                    cmpx      #$0059
                    lbeq      $196C
                    cmpx      #$0054
                    lbeq      $196C
                    cmpx      #$0056
                    lbeq      L1988
                    cmpx      #$0055
                    lbeq      L1988
                    cmpx      #$005D
                    lbeq      L19D9
                    cmpx      #$005F
                    lbeq      L19D9
                    cmpx      #$005C
                    lbeq      L19D9
                    cmpx      #$005E
                    lbeq      L19D9
                    cmpx      #$005A
                    lbeq      L1A0F
                    cmpx      #$005B
                    lbeq      L1A0F
                    cmpx      #$0050
                    lbeq      $1A57
                    cmpx      #$0051
                    lbeq      $1AAD
                    cmpx      #$0078
                    lbeq      L1BF7
                    cmpx      #$002F
                    lbeq      L1D7D
                    cmpx      #$0064
                    lbeq      L1E15
                    lbra      L1E2B

L1F6E               ldd       $0C,s
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
L1F91               pshs      u
                    ldd       #$FFB8
                    lbsr      L0113
                    ldu       $04,s
                    ldd       $06,u
                    cmpd      #$0036
                    bne       L1FA7
                    ldd       $08,u
                    beq       L1FBD
L1FA7               leax      $274C,pcr
                    pshs      x
                    pshs      u
                    lbsr      L0296
                    leas      $04,s
                    ldd       #$0036
                    std       $06,u
                    clra
                    clrb
                    std       $08,u
L1FBD               puls      pc,u
L1FBF               pshs      u
                    ldd       #$FFB6
                    lbsr      L0113
                    ldu       $04,s
                    leas      -$02,s
                    pshs      u
                    lbsr      L24D6
                    leas      $02,s
                    ldd       ,u
                    std       ,s
                    tfr       d,x
                    bra       L2002

L1FDA               ldd       #$0001
                    bra       L1FE2

L1FDF               ldd       #$0006
L1FE2               std       ,s
                    pshs      d
                    pshs      u
                    bsr       L202A
                    leas      $04,s
                    bra       L2022

L1FEE               leax      $275B,pcr
                    pshs      x
                    pshs      u
                    lbsr      L0296
                    leas      $04,s
                    ldd       #$0001
                    std       ,s
                    bra       L2022

L2002               cmpx      #$0002
                    beq       L1FDA
                    cmpx      #$0005
                    beq       L1FDF
                    cmpx      #$0006
                    beq       L2022
                    cmpx      #$0008
                    beq       L2022
                    cmpx      #$0001
                    beq       L2022
                    cmpx      #$0007
                    beq       L2022
                    bra       L1FEE

L2022               ldd       ,s
                    std       ,u
                    leas      $02,s
L2028               puls      pc,u
L202A               pshs      u
                    ldd       #$FFAC
                    lbsr      L0113
                    ldu       $04,s
                    leas      -$04,s
                    clra
                    clrb
                    std       ,s
                    ldx       ,u
                    lbra      L22D9

L203F               ldx       $0a,s
                    bra       L2075

L2043               ldd       #$0085
                    bra       L2056

L2048               ldd       #$0001
                    pshs      d
                    pshs      u
                    bsr       L202A
                    leas      $04,s
                    ldd       #$0083
L2056               std       ,s
                    lbra      L2306

L205B               ldd       #$0001
                    pshs      d
                    pshs      u
                    lbsr      L202A
L2065               leas      $04,s
                    ldd       $0a,s
                    pshs      d
                    pshs      u
                    lbsr      L202A
                    leas      $04,s
L2072               lbra      L2306

L2075               cmpx      #$0001
                    beq       L2043
L207A               cmpx      #$0007
                    lbeq      L2043
                    cmpx      #$0008
                    beq       L2048
                    cmpx      #$0006
                    beq       L205B
                    cmpx      #$0005
                    lbeq      L205B
                    lbra      L2306

L2095               ldd       ,u
                    clra
                    andb      #$30
                    cmpd      #$0010
                    lbne      L2306
L20A2               ldx       $0a,s
                    lbra      L213A

L20A7               ldd       $06,u
                    cmpd      #$0036
                    bne       L20E2
                    ldd       #$0004
                    pshs      d
                    lbsr      L5C2A
                    leas      $02,s
                    std       $02,s
                    ldd       $08,u
                    ldx       $02,s
                    std       $02,x
                    bge       L20C8
                    ldd       #$FFFF
                    bra       L20CA

L20C8               clra
                    clrb
L20CA               std       [$02,s]
                    ldd       $02,s
                    std       $08,u
                    bra       L20D5

L20D3               leas      -$04,x
L20D5               ldd       #$004A
                    std       $06,u
                    ldd       #$0004
L20DD               std       $02,u
                    lbra      L2306

L20E2               ldd       #$0083
                    bra       L2135

L20E7               ldd       #$0001
                    std       $0a,s
                    lbra      L2306

L20EF               ldd       #$0006
                    pshs      d
                    pshs      u
                    lbsr      L202A
                    leas      $04,s
                    ldd       #$008D
                    bra       L2135

L2100               ldd       $06,u
                    cmpd      #$0036
                    bne       L2132
                    ldd       #$0008
                    pshs      d
                    lbsr      L5C2A
                    leas      $02,s
                    std       $02,s
                    ldx       $02,s
                    pshs      x
                    ldd       $08,u
                    lbsr      L6A1F
                    lbsr      $6A02
                    bra       L2124

L2122               leas      -$04,x
L2124               ldd       $02,s
                    std       $08,u
                    ldd       #$004B
                    std       $06,u
                    ldd       #$0008
                    bra       L20DD

L2132               ldd       #$008E
L2135               std       ,s
                    lbra      L2306

L213A               cmpx      #$0008
                    lbeq      L20A7
                    cmpx      #$0002
                    lbeq      L20E7
                    cmpx      #$0005
                    beq       L20EF
                    cmpx      #$0006
                    beq       L2100
                    lbra      L2306

L2155               ldx       $0a,s
                    bra       L217F

L2159               ldd       #$0086
                    bra       L2172

L215E               ldd       #$0006
                    pshs      d
                    pshs      u
                    lbsr      L202A
                    leas      $04,s
                    ldd       #$008D
                    bra       L2172

L216F               ldd       #$0092
L2172               std       ,s
                    lbra      L2306

L2177               ldd       #$0001
                    std       $0a,s
                    lbra      L2306

L217F               cmpx      #$0008
                    beq       L2159
                    cmpx      #$0005
                    beq       L215E
                    cmpx      #$0006
                    beq       L216F
                    cmpx      #$0002
                    beq       L2177
                    lbra      L2306

L2196               ldx       $0a,s
                    lbra      L220E

L219B               ldd       $0a,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    lbne      L2306
L21A8               ldd       $06,u
                    cmpd      #$004A
                    bne       L21CB
                    ldd       $08,u
                    std       $02,s
                    ldx       $02,s
                    ldd       $02,x
                    std       $08,u
                    bra       L21BE

L21BC               leas      -$04,x
L21BE               ldd       #$0036
                    std       $06,u
                    ldd       #$0002
                    std       $02,u
                    lbra      L2306

L21CB               ldd       #$0084
                    bra       L2209

L21D0               ldd       #$0006
                    pshs      d
                    pshs      u
                    lbsr      L202A
                    leas      $04,s
                    ldd       #$008D
                    bra       L2209

L21E1               ldd       $06,u
                    cmpd      #$004A
                    bne       L2206
                    ldd       #$0008
                    pshs      d
                    lbsr      L5C2A
                    leas      $02,s
                    std       $02,s
                    ldx       $02,s
                    pshs      x
                    ldx       $08,u
                    lbsr      $6A3F
                    lbsr      $6A02
                    leax      $04,s
                    lbra      L2122

L2206               ldd       #$0090
L2209               std       ,s
                    lbra      L2306

L220E               cmpx      #$0001
                    lbeq      L21A8
                    cmpx      #$0007
                    lbeq      L21A8
                    cmpx      #$0002
                    lbeq      L21A8
                    cmpx      #$0005
                    beq       L21D0
                    cmpx      #$0006
                    beq       L21E1
                    lbra      L219B

L2230               ldx       $0a,s
                    bra       L2256

L2234               ldd       #$0006
                    pshs      d
                    pshs      u
                    lbsr      L202A
                    leas      $04,s
                    ldd       $0a,s
                    pshs      d
                    pshs      u
                    lbsr      L202A
                    leas      $04,s
                    lbra      L2306

L224E               ldd       #$008C
                    std       ,s
                    lbra      L2306

L2256               cmpx      #$0008
                    beq       L2234
                    cmpx      #$0007
                    lbeq      L2234
                    cmpx      #$0002
                    lbeq      L2234
                    cmpx      #$0001
                    lbeq      L2234
                    cmpx      #$0006
                    beq       L224E
                    lbra      L2306

L2278               ldx       $0a,s
                    bra       L22BA

L227C               ldd       $06,u
                    cmpd      #$004B
                    bne       L2290
                    ldx       $08,u
                    lbsr      L697F
                    std       $08,u
                    leax      $04,s
                    lbra      L21BC

L2290               ldd       #$008F
                    bra       L22B6

L2295               ldd       $06,u
                    cmpd      #$004B
                    bne       L22AE
                    ldx       $08,u
                    pshs      x
                    ldx       $08,u
                    lbsr      L6984
                    lbsr      L74D6
                    leax      $04,s
                    lbra      L20D3

L22AE               ldd       #$0091
                    bra       L22B6

L22B3               ldd       #$008D
L22B6               std       ,s
                    bra       L2306

L22BA               cmpx      #$0002
                    beq       L227C
                    cmpx      #$0007
                    lbeq      L227C
                    cmpx      #$0001
                    lbeq      L227C
                    cmpx      #$0008
                    beq       L2295
                    cmpx      #$0005
                    beq       L22B3
                    bra       L2306

L22D9               cmpx      #$0002
                    lbeq      L203F
                    cmpx      #$0001
                    lbeq      L20A2
                    cmpx      #$0007
                    lbeq      L2155
                    cmpx      #$0008
                    lbeq      L2196
                    cmpx      #$0005
                    lbeq      L2230
                    cmpx      #$0006
                    lbeq      L2278
                    lbra      L2095

L2306               ldd       ,s
                    beq       L233E
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
                    lbsr      L0DD6
                    leas      $0C,s
                    std       $02,s
                    pshs      d
                    pshs      u
                    lbsr      L03C7
                    leas      $04,s
                    ldd       ,s
                    std       $06,u
                    ldd       $02,s
                    std       $0a,u
                    clra
                    clrb
                    std       $0C,u
L233E               ldd       $0a,s
                    lbra      L23BC

L2343               pshs      u
                    ldd       #$FFB4
                    lbsr      L0113
                    ldu       $04,s
                    leas      -$04,s
                    pshs      u
                    lbsr      L1FBF
                    leas      $02,s
                    std       $02,s
                    ldd       $0a,s
                    pshs      d
                    lbsr      L1FBF
                    leas      $02,s
                    std       ,s
                    ldd       $02,s
                    cmpd      #$0006
                    bne       L2370
                    ldd       #$0006
                    bra       L2388

L2370               ldd       ,s
                    cmpd      #$0006
                    bne       L237D
                    ldd       #$0006
                    bra       L239B

L237D               ldd       $02,s
                    cmpd      #$0008
                    bne       L2390
                    ldd       #$0008
L2388               pshs      d
                    ldd       $0C,s
                    pshs      d
                    bra       L239F

L2390               ldd       ,s
                    cmpd      #$0008
                    bne       L23A6
                    ldd       #$0008
L239B               pshs      d
                    pshs      u
L239F               lbsr      L202A
                    leas      $04,s
                    bra       L23C3

L23A6               ldd       $02,s
                    cmpd      #$0007
                    beq       L23B6
                    ldd       ,s
                    cmpd      #$0007
                    bne       L23C0
L23B6               ldd       #$0007
                    std       [$0a,s]
L23BC               std       ,u
                    bra       L23C3

L23C0               ldd       #$0001
L23C3               leas      $04,s
L23C5               puls      pc,u
                    pshs      u
                    ldd       #$FFB0
                    lbsr      L0113
                    ldd       $08,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    lbsr      L047A
                    std       ,s
                    lbsr      L418D
                    leas      $06,s
                    std       $04,s
                    cmpd      #$0001
                    bne       L23F1
                    ldd       $0a,s
                    puls      pc,u
L23F1               ldx       $0a,s
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
                    lbsr      L0DD6
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
                    lbsr      L0DD6
                    leas      $0C,s
                    pshs      d
                    lbsr      L1008
                    leas      $02,s
                    tfr       d,u
                    ldd       $06,u
                    cmpd      #$0036
                    bne       L2452
                    clra
                    clrb
                    bra       L2455

L2452               ldd       #$0002
L2455               std       $12,u
                    ldd       #$0001
                    std       ,u
                    ldd       #$0002
                    std       $02,u
                    tfr       u,d
L2464               puls      pc,u
                    pshs      u
                    ldd       #$FFB6
                    lbsr      L0113
                    ldu       $04,s
                    leas      -$02,s
                    ldd       $06,u
                    std       ,s
                    tfr       d,x
                    cmpx      #$0076
                    lbeq      L25B4
                    cmpx      #$006F
                    lbeq      L25B4
                    cmpx      #$0042
                    lbeq      L25B4
                    ldd       ,s
                    cmpd      #$0034
                    bne       L24BF
                    pshs      u
                    bsr       L24D6
                    leas      $02,s
                    ldd       $08,s
                    lbne      L25B4
                    ldd       ,u
                    clra
                    andb      #$30
                    cmpd      #$0020
                    bne       L24B1
                    ldd       #$0001
                    bra       L24B3

L24B1               clra
                    clrb
L24B3               bne       L24BF
                    ldd       ,u
                    cmpd      #$0004
                    lbne      L25B4
L24BF               leax      $2766,pcr
                    pshs      x
                    pshs      u
                    lbsr      L0296
                    leas      $04,s
                    pshs      u
                    lbsr      L25E9
                    leas      $02,s
                    lbra      L25B4

L24D6               pshs      u
                    ldd       #$FFB8
                    lbsr      L0113
                    ldu       $04,s
                    ldd       $06,u
                    cmpd      #$0034
                    lbne      L25B6
                    ldd       ,u
                    lbne      L25B6
                    leax      L2776,pcr
                    pshs      x
                    pshs      u
                    lbsr      L0296
                    leas      $04,s
                    pshs      u
                    lbsr      L25E9
                    lbra      L25B4
                    pshs      u
                    ldd       #$FFB6
                    lbsr      L0113
                    ldu       $04,s
                    leas      -$02,s
                    ldd       ,u
                    std       [$08,s]
                    ldd       $06,u
                    cmpd      #$0041
                    bne       L2544
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
                    lbsr      L03C7
                    leas      $04,s
                    ldd       ,s
                    pshs      d
                    lbsr      L03B7
                    leas      $02,s
                    bra       L2549

L2544               clra
                    clrb
                    std       [$0a,s]
L2549               pshs      u
                    lbsr      L24D6
                    leas      $02,s
                    ldd       $06,u
                    cmpd      #$0034
                    bne       L2589
                    ldd       $08,u
                    std       ,s
                    ldx       ,s
                    ldd       $08,x
                    cmpd      #$0011
                    beq       L256A
                    leax      $02,s
                    bra       L2587

L256A               ldd       #$0036
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
                    bra       L25B4
                    bra       L2589

L2587               leas      -$02,x
L2589               leax      $278A,pcr
                    pshs      x
                    pshs      u
                    lbsr      L0296
                    leas      $04,s
                    pshs      u
                    lbsr      L25E9
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
L25B4               leas      $02,s
L25B6               puls      pc,u
L25B8               pshs      u
                    ldd       #$FFB8
                    lbsr      L0113
                    ldu       $04,s
                    ldd       ,u
                    cmpd      #$0004
                    beq       L25D2
                    ldd       ,u
                    cmpd      #$0003
                    bne       L25E5
L25D2               leax      L27A1,pcr
                    pshs      x
                    pshs      u
                    lbsr      L0296
                    leas      $04,s
                    pshs      u
                    bsr       L25E9
                    leas      $02,s
L25E5               ldd       ,u
L25E7               puls      pc,u
L25E9               pshs      u
                    ldd       #$FFB6
                    lbsr      L0113
                    ldu       $04,s
                    ldd       #$0006
                    pshs      d
                    pshs      u
                    leax      $018b,y
                    pshs      x
                    lbsr      L01F9
                    leas      $06,s
                    ldd       #$0001
                    std       $12,u
                    ldd       $0a,u
                    pshs      d
                    lbsr      L0396
                    leas      $02,s
                    ldd       $0C,u
                    pshs      d
                    lbsr      L0396
                    leas      $02,s
                    clra
                    clrb
                    std       $0C,u
                    std       $0a,u
                    ldd       #$0034
                    std       $06,u
                    leax      $018b,y
                    stx       $08,u
L262E               puls      pc,u
L2630               pshs      u
                    ldd       #$FFC0
                    lbsr      L0113
                    ldx       $04,s
                    bra       L2641

L263C               ldd       #$0001
                    puls      pc,u
L2641               cmpx      #$0001
                    beq       L263C
                    cmpx      #$0002
                    lbeq      L263C
                    cmpx      #$0008
                    lbeq      L263C
                    cmpx      #$0007
                    lbeq      L263C
                    clra
                    clrb
L265D               puls      pc,u
L265F               pshs      u
                    ldd       #$FFB8
                    lbsr      L0113
                    leax      L27C2,pcr
                    pshs      x
                    ldd       $06,s
                    pshs      d
                    lbsr      L0296
                    leas      $04,s
L2676               puls      pc,u
                    lsr       $09,s
                    ror       $6964
                    fcb       $65
                    bra       L26E2
                    rol       L207A
                    fcb       $65
                    fcb       $72
L2685               clr       0,x
                    lsr       L7970
                    fcb       $65
                    lsr       $05,s
                    ror       0,y
                    blt       $26B1
                    jmp       $0f,s
                    lsr       $2061
                    bra       L270E
                    fcb       $61
                    fcb       $72
                    rol       $01,s
                    fcb       $62
                    inc       $05,s
                    neg       $0063
                    fcb       $61
                    jmp       $0e,s
                    clr       -$0C,s
                    bra       L270B
                    fcb       $61
                    com       L7400
                    com       $01,s
                    jmp       $07,y
                    lsr       $2074
                    fcb       $61
                    fcb       $6b
                    fcb       $65
                    bra       $2719
                    lsr       $04,s
                    fcb       $72
                    fcb       $65
                    com       L7300
                    neg       L6F69
                    jmp       -$0C,s
                    fcb       $65
                    fcb       $72
                    bra       $273A
                    fcb       $65
                    fcb       $71
                    fcb       $75
                    rol       -$0e,s
                    fcb       $65
L26CE               lsr       0,x
                    neg       L6F69
                    jmp       -$0C,s
                    fcb       $65
                    fcb       $72
                    bra       $2748
                    fcb       $72
                    bra       L2745
                    jmp       -$0C,s
                    fcb       $65
                    asr       $05,s
                    fcb       $72
L26E2               bra       $2756
                    fcb       $65
                    fcb       $71
                    fcb       $75
                    rol       -$0e,s
                    fcb       $65
L26EA               lsr       0,x
                    jmp       $0f,s
                    lsr       $2061
                    bra       L2759
                    fcb       $75
                    jmp       $03,s
                    lsr       L696F
L26F9               jmp       0,x
                    fcb       $62
                    clr       -$0C,s
                    asl       0,y
                    tst       -$0b,s
                    com       $7420
                    fcb       $62
                    fcb       $65
                    bra       $2772
                    jmp       -$0C,s
L270B               fcb       $65
                    asr       -$0e,s
L270E               fcb       $61
L270F               inc       0,x
                    neg       L6F69
                    jmp       -$0C,s
                    fcb       $65
                    fcb       $72
                    bra       L2787
                    rol       -$0d,s
                    tst       $01,s
                    lsr       $6368
                    neg       $0074
                    rol       $7065
                    bra       L2795
                    rol       -$0d,s
                    tst       $01,s
                    lsr       $6368
                    neg       $0070
                    clr       $09,s
                    jmp       -$0C,s
                    fcb       $65
                    fcb       $72
                    bra       $27A6
                    rol       -$0d,s
                    tst       $01,s
                    lsr       $6368
                    neg       $0074
                    rol       $7065
L2745               bra       L27AA
                    asl       $05,s
                    com       $0b,s
                    neg       $0073
                    asl       $0f,s
                    fcb       $75
                    inc       $04,s
                    bra       $27B6
                    fcb       $65
                    bra       L27A5
                    fcb       $55
                    inca
L2759               inca
                    neg       $0074
                    rol       $7065
                    bra       $27C6
                    fcb       $72
                    fcb       $72
                    clr       -$0e,s
                    neg       $006C
                    ror       L616C
                    fcb       $75
                    fcb       $65
                    bra       $27E0
                    fcb       $65
                    fcb       $71
                    fcb       $75
                    rol       -$0e,s
                    fcb       $65
                    lsr       0,x
L2776               fcb       $75
                    jmp       $04,s
                    fcb       $65
                    com       $0C,s
                    fcb       $61
                    fcb       $72
                    fcb       $65
                    lsr       0,y
                    ror       $6172
                    rol       $01,s
                    fcb       $62
L2787               inc       $05,s
                    neg       $0073
                    lsr       $7275
                    com       -$0C,s
                    bra       $27FF
                    fcb       $65
                    tst       $02,s
L2795               fcb       $65
                    fcb       $72
                    bra       $280B
                    fcb       $65
                    fcb       $71
                    fcb       $75
                    rol       -$0e,s
                    fcb       $65
                    lsr       0,x
L27A1               com       $7472
                    fcb       $75
L27A5               com       -$0C,s
                    fcb       $75
                    fcb       $72
                    fcb       $65
L27AA               bra       $281B
                    fcb       $72
                    bra       L2824
                    jmp       $09,s
                    clr       $0e,s
                    bra       $281E
                    jmp       $01,s
                    neg       L7072
                    clr       -$10,s
                    fcb       $72
                    rol       $01,s
                    lsr       $6500
L27C2               tst       -$0b,s
                    com       $7420
                    fcb       $62
                    fcb       $65
                    bra       L2834
                    jmp       -$0C,s
                    fcb       $65
                    asr       -$0e,s
                    fcb       $61
                    inc       0,x
L27D3               pshs      u
                    ldd       #$FFBA
                    lbsr      L0113
                    ldd       $005F
                    cmpd      #$0028
                    beq       L27EB
                    clra
                    clrb
                    std       L004F
                    bra       L27EB

L27E9               leas      ,x
L27EB               ldx       $005F
                    lbra      L28EA

L27F0               ldx       $0061
                    bra       L2846

L27F4               lbsr      L291A
                    puls      pc,u
L27F9               lbsr      L29DD
                    puls      pc,u
L27FE               lbsr      L2E96
                    lbra      L290E

L2804               lbsr      L2BF4
                    puls      pc,u
L2809               lbsr      L2A8D
                    puls      pc,u
L280E               lbsr      L2F24
                    lbra      L290E

L2814               lbsr      L2F63
                    lbra      L290E

L281A               lbsr      L2C5C
                    puls      pc,u
L281F               lbsr      L2D5D
                    puls      pc,u
L2824               lbsr      L2CAF
                    lbra      L290E

L282A               lbsr      L2FA1
                    lbra      L290E

L2830               leax      L316D,pcr
L2834               pshs      x
                    lbsr      L024E
                    leas      $02,s
                    lbsr      L552E
                    lbra      L289A

L2841               leax      ,s
                    lbra      L28A3

L2846               cmpx      #$0013
                    beq       L27F4
                    cmpx      #$0014
                    beq       L27F9
                    cmpx      #$0012
                    beq       L27FE
                    cmpx      #$0017
                    beq       L2804
                    cmpx      #$0016
                    beq       L2809
                    cmpx      #$0018
                    beq       L280E
                    cmpx      #$0019
                    beq       L2814
                    cmpx      #$001B
                    beq       L281A
                    cmpx      #$001C
                    beq       L281F
                    cmpx      #$001A
                    beq       L2824
                    cmpx      #$001D
                    beq       L282A
                    cmpx      #$0015
                    beq       L2830
                    bra       L2841

L2884               lbsr      L3A4F
                    lbsr      L552E
                    puls      pc,u
L288C               puls      pc,u
L288E               lbsr      $6348
                    ldb       $0065
                    cmpb      #$3a
                    bne       L289F
                    lbsr      L2FEC
L289A               leax      ,s
                    lbra      L27E9

L289F               leax      ,s
                    bra       L28CB

L28A3               leas      ,x
L28A5               lbsr      L043F
                    std       -$02,s
                    bne       L28B3
                    lbsr      L03DD
                    std       -$02,s
                    beq       L28CD
L28B3               leax      L3180,pcr
                    pshs      x
                    lbsr      L024E
                    leas      $02,s
L28BE               lbsr      L552E
                    ldd       $005F
                    cmpd      #$0028
                    bne       L28BE
                    bra       L290E

L28CB               leas      ,x
L28CD               clra
                    clrb
                    pshs      d
                    lbsr      L3085
                    std       ,s++
                    bne       L290E
                    leax      L3194,pcr
                    pshs      x
                    lbsr      L024E
                    leas      $02,s
                    lbsr      L0502
                    puls      pc,u
                    bra       L290E

L28EA               cmpx      #$0028
                    beq       L290E
                    cmpx      #$0033
                    lbeq      L27F0
                    cmpx      #$0029
                    lbeq      L2884
                    cmpx      #$FFFF
                    lbeq      L288C
                    cmpx      #$0034
                    lbeq      L288E
                    lbra      L28A5

L290E               ldd       #$0028
                    pshs      d
                    lbsr      L04BF
                    leas      $02,s
                    puls      pc,u
L291A               pshs      u
                    ldd       #$FFAE
                    lbsr      L0113
                    leas      -$06,s
                    lbsr      L552E
                    lbsr      L30EA
                    std       ,s
                    ldd       L002B
                    addd      #$0001
                    std       L002B
                    tfr       d,u
                    ldd       L002B
                    addd      #$0001
                    std       L002B
                    std       $04,s
                    ldd       $005F
                    cmpd      #$0028
                    bne       L2969
                    lbsr      L552E
                    clra
                    clrb
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    ldd       $06,s
                    pshs      d
                    lbsr      L3143
                    leas      $08,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L4AC7
                    leas      $02,s
                    stu       $02,s
                    bra       L298B

L2969               ldd       #$0001
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    ldd       $06,s
                    pshs      d
                    lbsr      L3143
                    leas      $08,s
                    pshs      u
                    lbsr      L4AC7
                    leas      $02,s
                    lbsr      L27D3
                    ldd       $04,s
                    std       $02,s
L298B               ldd       $005F
                    cmpd      #$0033
                    bne       L29D0
                    ldd       $0061
                    cmpd      #$0015
                    bne       L29D0
                    lbsr      L552E
                    ldd       $005F
                    cmpd      #$0028
                    beq       L29D0
                    cmpu      $02,s
                    beq       L29CD
                    clra
                    clrb
                    pshs      d
                    ldd       L002B
                    addd      #$0001
                    std       L002B
                    std       $04,s
                    pshs      d
                    ldd       #$007C
                    pshs      d
                    lbsr      L4B61
                    leas      $06,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L4AC7
                    leas      $02,s
L29CD               lbsr      L27D3
L29D0               ldd       $02,s
                    pshs      d
                    lbsr      L4AC7
                    leas      $02,s
                    leas      $06,s
                    puls      pc,u
L29DD               pshs      u
                    ldd       #$FFAA
                    lbsr      L0113
                    leas      -$0a,s
                    ldd       L0053
                    std       $08,s
                    ldd       L0055
                    std       $06,s
                    ldd       $02D6,y
                    std       $04,s
                    ldd       $02D8,y
                    std       $02,s
                    lbsr      L552E
                    ldd       L002B
                    addd      #$0001
                    std       L002B
                    std       L0053
                    ldd       $002F
                    std       $02D8,y
                    std       $02D6,y
                    ldd       L002B
                    addd      #$0001
                    std       L002B
                    std       L0055
                    lbsr      L30EA
                    std       ,s
                    ldd       $005F
                    cmpd      #$0028
                    bne       L2A2B
                    ldu       L0055
                    bra       L2A50

L2A2B               clra
                    clrb
                    pshs      d
                    ldd       L0055
                    pshs      d
                    ldd       #$007C
                    pshs      d
                    lbsr      L4B61
                    leas      $06,s
                    ldd       L002B
                    addd      #$0001
                    std       L002B
                    tfr       d,u
                    pshs      u
                    lbsr      L4AC7
                    leas      $02,s
                    lbsr      L27D3
L2A50               ldd       L0055
                    pshs      d
                    lbsr      L4AC7
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    ldd       L0053
                    pshs      d
                    pshs      u
                    ldd       $06,s
                    pshs      d
                    lbsr      L3143
                    leas      $08,s
                    ldd       L0053
                    pshs      d
                    lbsr      L4AC7
                    leas      $02,s
                    ldd       $08,s
                    std       L0053
                    ldd       $06,s
                    std       L0055
                    ldd       $04,s
                    std       $02D6,y
                    ldd       $02,s
                    std       $02D8,y
                    leas      $0a,s
                    puls      pc,u
L2A8D               pshs      u
                    ldd       #$FFA8
                    lbsr      L0113
                    leas      -$0e,s
                    lbsr      L552E
                    ldd       L0057
                    addd      #$0001
                    std       L0057
                    ldd       $005B
                    std       ,s
                    ldd       L0059
                    std       $0a,s
                    clra
                    clrb
                    std       L0059
                    ldd       L0053
                    std       $0C,s
                    ldd       $02D4,y
                    std       $08,s
                    ldd       $02D6,y
                    std       $02,s
                    ldd       L002B
                    addd      #$0001
                    std       L002B
                    std       L0053
                    ldd       $002F
                    std       $02D6,y
                    clra
                    clrb
                    std       $02D4,y
                    ldd       #$002D
                    pshs      d
                    lbsr      L04BF
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    lbsr      L0583
                    std       ,s
                    lbsr      L0F1B
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    beq       L2B41
                    pshs      u
                    lbsr      L24D6
                    leas      $02,s
                    ldx       ,u
                    bra       L2B19

L2AFB               ldd       #$0001
                    pshs      d
                    pshs      u
                    lbsr      L202A
                    leas      $04,s
                    bra       L2B31

L2B09               pshs      u
                    lbsr      L265F
                    leas      $02,s
                    pshs      u
                    lbsr      L25E9
                    leas      $02,s
                    bra       L2B31

L2B19               cmpx      #$0002
                    beq       L2AFB
                    cmpx      #$0008
                    lbeq      L2AFB
                    cmpx      #$0001
                    beq       L2B31
                    cmpx      #$0007
                    beq       L2B31
                    bra       L2B09

L2B31               pshs      u
                    lbsr      L4C1E
                    leas      $02,s
                    pshs      u
                    lbsr      L0396
                    leas      $02,s
                    bra       L2B44

L2B41               lbsr      L0E18
L2B44               ldd       #$002E
                    pshs      d
                    lbsr      L04BF
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    ldd       L002B
                    addd      #$0001
                    std       L002B
                    std       $08,s
                    pshs      d
                    ldd       #$007C
                    pshs      d
                    lbsr      L4B61
                    leas      $06,s
                    lbsr      L27D3
                    ldd       L004F
                    bne       L2B80
                    clra
                    clrb
                    pshs      d
                    ldd       L0053
                    pshs      d
                    ldd       #$007C
                    pshs      d
                    lbsr      L4B61
                    leas      $06,s
L2B80               ldd       $06,s
                    pshs      d
                    lbsr      L4AC7
                    leas      $02,s
                    ldu       L0059
                    bra       L2BAB

L2B8D               ldd       ,u
                    std       $04,s
                    ldd       $02,u
                    pshs      d
                    ldd       $04,u
                    pshs      d
                    ldd       #$007D
                    pshs      d
                    lbsr      L4B61
                    leas      $06,s
                    ldd       L0045
                    std       ,u
                    stu       L0045
                    ldu       $04,s
L2BAB               stu       -$02,s
                    bne       L2B8D
                    ldd       $02D4,y
                    beq       L2BC9
                    clra
                    clrb
                    pshs      d
                    ldd       $02D4,y
                    pshs      d
                    ldd       #$007C
                    pshs      d
                    lbsr      L4B61
                    leas      $06,s
L2BC9               ldd       L0053
                    pshs      d
                    lbsr      L4AC7
                    leas      $02,s
                    ldd       $0a,s
                    std       L0059
                    ldd       $08,s
                    std       $02D4,y
                    ldd       L0057
                    addd      #$FFFF
                    std       L0057
                    ldd       ,s
                    std       $005B
                    ldd       $0C,s
                    std       L0053
                    ldd       $02,s
                    std       $02D6,y
                    lbra      L2E92

L2BF4               pshs      u
                    ldd       #$FFB8
                    lbsr      L0113
                    leas      -$02,s
                    lbsr      L552E
                    clra
                    clrb
                    pshs      d
                    lbsr      L0A52
                    leas      $02,s
                    std       ,s
                    ldd       #$002F
                    pshs      d
                    lbsr      L04BF
                    leas      $02,s
                    ldd       L0057
                    beq       L2C58
                    ldu       L0045
                    beq       L2C24
                    ldd       ,u
                    std       L0045
                    bra       L2C30

L2C24               ldd       #$0006
                    pshs      d
                    lbsr      L5C2A
                    leas      $02,s
                    tfr       d,u
L2C30               ldd       L0059
                    beq       L2C3A
                    stu       [$005B,y]
                    bra       L2C3C

L2C3A               stu       L0059
L2C3C               stu       $005B
                    clra
                    clrb
                    std       ,u
                    ldd       ,s
                    std       $02,u
                    ldd       L002B
                    addd      #$0001
                    std       L002B
                    std       $04,u
                    pshs      d
                    lbsr      L4AC7
                    leas      $02,s
                    bra       L2CAB

L2C58               bsr       L2C9A
                    bra       L2CAB

L2C5C               pshs      u
                    ldd       #$FFBA
                    lbsr      L0113
                    lbsr      L552E
                    ldd       L0057
                    bne       L2C6D
                    bsr       L2C9A
L2C6D               ldd       $02D4,y
                    beq       L2C7E
                    leax      $31A1,pcr
                    pshs      x
                    lbsr      L024E
                    bra       L2C8E

L2C7E               ldd       L002B
                    addd      #$0001
                    std       L002B
                    std       $02D4,y
                    pshs      d
                    lbsr      L4AC7
L2C8E               leas      $02,s
                    ldd       #$002F
L2C93               pshs      d
                    lbsr      L04BF
                    bra       L2CAB

L2C9A               pshs      u
                    ldd       #$FFBA
                    lbsr      L0113
                    leax      $31B3,pcr
                    pshs      x
                    lbsr      L024E
L2CAB               leas      $02,s
                    puls      pc,u
L2CAF               pshs      u
                    ldd       #$FFAA
                    lbsr      L0113
                    leas      -$0a,s
                    ldd       L0053
                    std       $08,s
                    ldd       L0055
                    std       $06,s
                    ldd       $02D8,y
                    std       ,s
                    ldd       $02D6,y
                    std       $02,s
                    ldd       $002F
                    std       $02D8,y
                    std       $02D6,y
                    ldd       L002B
                    addd      #$0001
                    std       L002B
                    std       L0055
                    ldd       L002B
                    addd      #$0001
                    std       L002B
                    std       L0053
                    lbsr      L552E
                    ldd       L002B
                    addd      #$0001
                    std       L002B
                    std       $04,s
                    pshs      d
                    lbsr      L4AC7
                    leas      $02,s
                    lbsr      L27D3
                    ldd       $005F
                    cmpd      #$0033
                    bne       L2D0F
                    ldd       $0061
                    cmpd      #$0014
                    beq       L2D1A
L2D0F               leax      $31C7,pcr
                    pshs      x
                    lbsr      L024E
                    leas      $02,s
L2D1A               lbsr      L552E
                    ldd       L0055
                    pshs      d
                    lbsr      L4AC7
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    ldd       L0053
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L30EA
                    pshs      d
                    lbsr      L3143
                    leas      $08,s
                    ldd       L0053
                    pshs      d
                    lbsr      L4AC7
                    leas      $02,s
                    ldd       $08,s
                    std       L0053
                    ldd       $06,s
                    std       L0055
                    ldd       $02,s
                    std       $02D6,y
                    ldd       ,s
                    std       $02D8,y
                    leas      $0a,s
                    puls      pc,u
L2D5D               pshs      u
                    ldd       #$FFA6
                    lbsr      L0113
                    leas      -$0e,s
                    clra
                    clrb
                    std       $02,s
                    clra
                    clrb
                    std       ,s
                    ldu       L0053
                    ldd       L0055
                    std       $0C,s
                    ldd       $02D6,y
                    std       $06,s
                    ldd       $02D8,y
                    std       $04,s
                    ldd       $002F
                    std       $02D6,y
                    std       $02D8,y
                    ldd       L002B
                    addd      #$0001
                    std       L002B
                    std       $0a,s
                    ldd       L002B
                    addd      #$0001
                    std       L002B
                    std       L0053
                    lbsr      L552E
                    ldd       #$002D
                    pshs      d
                    lbsr      L04BF
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    lbsr      L3085
                    leas      $02,s
                    ldd       #$0028
                    pshs      d
                    lbsr      L04BF
                    leas      $02,s
                    ldd       $005F
                    cmpd      #$0028
                    beq       L2DE3
                    lbsr      L3111
                    std       $02,s
                    clra
                    clrb
                    pshs      d
                    ldd       L002B
                    addd      #$0001
                    std       L002B
                    std       $0a,s
                    pshs      d
                    ldd       #$007C
                    pshs      d
                    lbsr      L4B61
                    leas      $06,s
L2DE3               ldd       #$0028
                    pshs      d
                    lbsr      L04BF
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    lbsr      L0583
                    std       ,s
                    lbsr      L0F1B
                    leas      $02,s
                    std       ,s
                    beq       L2E11
                    ldd       ,s
                    pshs      d
                    lbsr      L24D6
                    leas      $02,s
                    ldd       L002B
                    addd      #$0001
                    std       L002B
                    bra       L2E13

L2E11               ldd       $0a,s
L2E13               std       L0055
                    ldd       #$002E
                    pshs      d
                    lbsr      L04BF
                    leas      $02,s
                    ldd       $0a,s
                    pshs      d
                    lbsr      L4AC7
                    leas      $02,s
                    lbsr      L27D3
                    ldd       ,s
                    beq       L2E41
                    ldd       L0055
                    pshs      d
                    lbsr      L4AC7
                    leas      $02,s
                    ldd       ,s
                    pshs      d
                    lbsr      L30AE
                    leas      $02,s
L2E41               ldd       $02,s
                    beq       L2E65
                    ldd       $08,s
                    pshs      d
                    lbsr      L4AC7
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    ldd       L0053
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L3143
                    leas      $08,s
                    bra       L2E77

L2E65               clra
                    clrb
                    pshs      d
                    ldd       $0C,s
                    pshs      d
                    ldd       #$007C
                    pshs      d
                    lbsr      L4B61
                    leas      $06,s
L2E77               ldd       L0053
                    pshs      d
                    lbsr      L4AC7
                    leas      $02,s
                    stu       L0053
                    ldd       $0C,s
                    std       L0055
                    ldd       $06,s
                    std       $02D6,y
                    ldd       $04,s
                    std       $02D8,y
L2E92               leas      $0e,s
                    puls      pc,u
L2E96               pshs      u
                    ldd       #$FFB6
                    lbsr      L0113
                    lbsr      L552E
                    ldd       $005F
                    cmpd      #$0028
                    lbeq      L2F03
                    clra
                    clrb
                    pshs      d
                    lbsr      L0583
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    beq       L2F03
                    pshs      u
                    lbsr      L0F1B
                    leas      $02,s
                    tfr       d,u
                    pshs      u
                    lbsr      L24D6
                    leas      $02,s
                    pshs      u
                    lbsr      L25B8
                    leas      $02,s
                    ldd       L004D
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L2EE1
                    ldd       #$0001
                    bra       L2EE3

L2EE1               ldd       L004D
L2EE3               pshs      d
                    pshs      u
                    lbsr      L202A
                    leas      $04,s
                    ldd       L004D
                    pshs      d
                    pshs      u
                    ldd       #$0012
                    pshs      d
                    lbsr      L4C6B
                    leas      $06,s
                    pshs      u
                    lbsr      L0396
                    leas      $02,s
L2F03               clra
                    clrb
                    pshs      d
                    lbsr      L4B33
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    ldd       #$0012
                    pshs      d
                    lbsr      L4B61
                    leas      $06,s
                    ldd       #$0012
                    lbra      L2FE8

L2F24               pshs      u
                    ldd       #$FFB6
                    lbsr      L0113
                    lbsr      L552E
                    ldd       L0053
                    bne       L2F40
                    leax      L31D6,pcr
                    pshs      x
                    lbsr      L024E
                    leas      $02,s
                    bra       L2F5D

L2F40               ldd       $02D6,y
                    pshs      d
                    lbsr      L4B33
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    ldd       L0053
                    pshs      d
                    ldd       #$007C
                    pshs      d
                    lbsr      L4B61
                    leas      $06,s
L2F5D               ldd       #$0018
                    lbra      L2FE8

L2F63               pshs      u
                    ldd       #$FFB6
                    lbsr      L0113
                    lbsr      L552E
                    ldd       L0055
                    bne       L2F7F
                    leax      $31E2,pcr
                    pshs      x
                    lbsr      L024E
                    leas      $02,s
                    bra       L2F9C

L2F7F               ldd       $02D8,y
                    pshs      d
                    lbsr      L4B33
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    ldd       L0055
                    pshs      d
                    ldd       #$007C
                    pshs      d
                    lbsr      L4B61
                    leas      $06,s
L2F9C               ldd       #$0019
                    bra       L2FE8

L2FA1               pshs      u
                    ldd       #$FFB6
                    lbsr      L0113
                    lbsr      L552E
                    ldd       $005F
                    cmpd      #$0034
                    beq       L2FC1
                    leax      $31F1,pcr
                    pshs      x
                    lbsr      L024E
                    leas      $02,s
                    bra       L2FE5

L2FC1               lbsr      L302E
                    tfr       d,u
                    stu       -$02,s
                    beq       L2FE2
                    clra
                    clrb
                    pshs      d
                    ldd       $06,u
                    pshs      d
                    ldd       #$001D
                    pshs      d
                    lbsr      L4B61
                    leas      $06,s
                    ldd       $0a,u
                    orb       #$02
                    std       $0a,u
L2FE2               lbsr      L552E
L2FE5               ldd       #$001D
L2FE8               std       L004F
                    puls      pc,u
L2FEC               pshs      u
                    ldd       #$FFB6
                    lbsr      L0113
                    bsr       L302E
                    tfr       d,u
                    stu       -$02,s
                    beq       L3026
                    ldd       $08,u
                    cmpd      #$000F
                    bne       L3009
                    lbsr      L0241
                    bra       L3026

L3009               ldd       #$000F
                    std       $08,u
                    clra
                    clrb
                    pshs      d
                    ldd       $06,u
                    pshs      d
                    ldd       #$0009
                    pshs      d
                    lbsr      L4B61
                    leas      $06,s
                    ldd       $0a,u
                    orb       #$01
                    std       $0a,u
L3026               lbsr      L552E
                    lbsr      L552E
                    puls      pc,u
L302E               pshs      u
                    ldd       #$FFBA
                    lbsr      L0113
                    ldu       $0061
                    ldd       ,u
                    cmpd      #$0009
                    lbeq      L313F
                    ldd       ,u
                    beq       L3060
                    ldd       $0C,u
                    beq       L3059
                    leax      L3200,pcr
                    pshs      x
                    lbsr      L024E
                    leas      $02,s
                    clra
                    clrb
                    puls      pc,u
L3059               pshs      u
                    lbsr      L0180
                    leas      $02,s
L3060               ldd       #$0009
                    std       ,u
                    ldd       #$000D
                    std       $08,u
                    ldd       L002B
                    addd      #$0001
                    std       L002B
                    std       $06,u
                    clra
                    clrb
                    std       $0a,u
                    ldd       L0051
                    std       $0C,u
                    ldd       L0049
                    std       $10,u
                    stu       L0049
                    lbra      L313F

L3085               pshs      u
                    ldd       #$FFBA
                    lbsr      L0113
                    ldd       $04,s
                    pshs      d
                    lbsr      L0583
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    lbeq      L313F
                    pshs      u
                    lbsr      L0F1B
                    std       ,s
                    bsr       L30AE
                    leas      $02,s
                    tfr       d,u
                    lbra      L313F

L30AE               pshs      u
                    ldd       #$FFBA
                    lbsr      L0113
                    ldu       $04,s
                    pshs      u
                    lbsr      L24D6
                    leas      $02,s
                    ldx       $06,u
                    bra       L30CF

L30C3               ldd       #$003C
                    bra       L30CB

L30C8               ldd       #$003D
L30CB               std       $06,u
                    bra       L30D9

L30CF               cmpx      #$003E
                    beq       L30C3
                    cmpx      #$003F
                    beq       L30C8
L30D9               pshs      u
                    lbsr      L4C52
                    leas      $02,s
                    tfr       d,u
                    pshs      u
                    lbsr      L0396
                    lbra      L313D

L30EA               pshs      u
                    ldd       #$FFB8
                    lbsr      L0113
                    leas      -$02,s
                    ldd       #$002D
                    pshs      d
                    lbsr      L04BF
                    leas      $02,s
                    bsr       L3111
                    std       ,s
                    ldd       #$002E
                    pshs      d
                    lbsr      L04BF
                    leas      $02,s
                    ldd       ,s
                    lbra      L3169

L3111               pshs      u
                    ldd       #$FFBA
                    lbsr      L0113
                    clra
                    clrb
                    pshs      d
                    lbsr      L0583
                    std       ,s
                    lbsr      L0F1B
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    beq       L3134
                    pshs      u
                    lbsr      L24D6
                    bra       L313D

L3134               leax      $3219,pcr
                    pshs      x
                    lbsr      L024E
L313D               leas      $02,s
L313F               tfr       u,d
                    puls      pc,u
L3143               pshs      u
                    ldd       #$FFB4
                    lbsr      L0113
                    ldu       $04,s
                    stu       -$02,s
                    beq       L316B
                    ldd       $0a,s
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    pshs      u
                    lbsr      L4C2F
                    leas      $08,s
                    pshs      u
                    lbsr      L0396
L3169               leas      $02,s
L316B               puls      pc,u
L316D               jmp       $0f,s
                    bra       $3198
                    rol       $06,s
                    beq       $3195
                    ror       $0f,s
                    fcb       $72
                    bra       $31A1
                    fcb       $65
                    inc       -$0d,s
                    fcb       $65
                    beq       L3180
L3180               rol       $0C,s
                    inc       $05,s
                    asr       $01,s
                    inc       0,y
                    lsr       $05,s
                    com       $0C,s
                    fcb       $61
                    fcb       $72
                    fcb       $61
                    lsr       L696F
                    jmp       0,x

L3194               com       L796E
                    lsr       L6178
                    bra       L3201
                    fcb       $72
                    fcb       $72
                    clr       -$0e,s
                    neg       L006D
                    fcb       $75
                    inc       -$0C,s
                    rol       -$10,s
                    inc       $05,s
                    bra       $320F
                    fcb       $65
                    ror       $01,s
                    fcb       $75
                    inc       -$0C,s
                    com       >$006E
                    clr       0,y
                    com       L7769
                    lsr       $6368
                    bra       $3231
                    lsr       $6174
                    fcb       $65
                    tst       $05,s
                    jmp       -$0C,s
                    neg       $0077
                    asl       $09,s
                    inc       $05,s
                    bra       $3233
                    asl       $7065
                    com       -$0C,s
                    fcb       $65
                    lsr       0,x
L31D6               fcb       $62
                    fcb       $72
                    fcb       $65
                    fcb       $61
                    fcb       $6b
                    bra       L3242
                    fcb       $72
                    fcb       $72
                    clr       -$0e,s
                    neg       $0063
                    clr       $0e,s
                    lsr       $696E
                    fcb       $75
                    fcb       $65
                    bra       $3251
                    fcb       $72
                    fcb       $72
                    clr       -$0e,s
                    neg       $006C
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
L3200               fcb       $61
L3201               inc       -$0e,s
                    fcb       $65
                    fcb       $61
                    lsr       -$07,s
                    bra       $326A
                    bra       L3277
                    clr       $03,s
                    fcb       $61
                    inc       0,y
                    ror       $6172
                    rol       $01,s
                    fcb       $62
                    inc       $05,s
                    neg       $0063
                    clr       $0e,s
                    lsr       $09,s
                    lsr       L696F
                    jmp       0,y
                    jmp       $05,s
                    fcb       $65
                    lsr       $05,s
                    lsr       0,x
                    pshs      u
                    ldd       #$FFA2
                    lbsr      L0113
                    leas      -$14,s
                    bra       L3245

L3237               leax      L42F7,pcr
                    pshs      x
                    lbsr      L024E
                    leas      $02,s
L3242               lbsr      L552E
L3245               ldd       $005F
                    cmpd      #$002A
                    beq       L3237
                    ldd       $005F
                    cmpd      #$0029
                    bne       L327A
                    leax      L4309,pcr
                    pshs      x
                    lbsr      L024E
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    lbsr      L3A4F
                    leas      $02,s
                    leax      >$0049,y
                    pshs      x
                    lbsr      L4207
                    leas      $02,s
                    lbsr      L552E
L3277               lbra      L34D4

L327A               lbsr      L3BE9
                    std       $0a,s
                    tfr       d,x
                    bra       L3295

L3283               leax      L4321,pcr
                    pshs      x
                    lbsr      L024E
                    leas      $02,s
L328E               ldd       #$000C
                    std       $0a,s
                    bra       L32A5

L3295               cmpx      #$0010
                    beq       L3283
                    cmpx      #$000D
                    lbeq      L3283
                    stx       -$02,s
                    beq       L328E
L32A5               leax      ,s
                    pshs      x
                    leax      $06,s
                    pshs      x
                    leax      $16,s
                    pshs      x
                    lbsr      L3C38
                    leas      $06,s
                    std       $08,s
                    bne       L32C0
                    ldd       #$0001
                    std       $08,s
L32C0               ldd       $04,s
                    std       $0C,s
                    ldd       $08,s
                    pshs      d
                    leax      $0e,s
                    pshs      x
                    leax      $06,s
                    pshs      x
                    lbsr      L3F8D
                    leas      $06,s
                    std       $06,s
                    ldu       $02,s
                    bne       L32F4
                    ldd       $06,s
                    cmpd      #$0004
                    beq       L32EE
                    ldd       $06,s
                    cmpd      #$0003
                    beq       L32EE
                    lbsr      L42E2
L32EE               leax      $14,s
                    lbra      L34B4

L32F4               ldd       $06,s
                    clra
                    andb      #$30
                    cmpd      #$0030
                    bne       L3319
                    ldd       $005F
                    cmpd      #$0030
                    beq       L330F
                    ldd       $005F
                    cmpd      #$0028
                    bne       L3314
L330F               ldd       #$000E
                    bra       L331B

L3314               ldd       #$000C
                    bra       L331B

L3319               ldd       $0a,s
L331B               std       $0e,s
                    ldd       ,u
                    beq       L3367
                    ldd       ,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    pshs      u
                    lbsr      L387E
                    leas      $06,s
                    std       -$02,s
                    lbne      L343B
                    ldd       $0e,s
                    cmpd      #$000E
                    lbeq      L343B
                    ldd       $08,u
                    cmpd      #$000E
                    beq       L3356
                    ldd       $08,u
                    cmpd      #$0022
                    beq       L3356
                    lbsr      L0241
                    lbra      L343B

L3356               ldd       $0e,s
                    std       $08,u
                    ldd       $0C,s
                    std       $04,u
                    ldd       ,s
                    std       $0a,u
                    leax      $14,s
                    bra       L3379

L3367               ldd       $06,s
                    std       ,u
                    clra
                    clrb
                    std       $0C,u
                    ldd       $0e,s
                    std       $08,u
                    ldd       ,s
                    std       $0a,u
                    bra       L337C

L3379               leas      -$14,x
L337C               ldd       $12,s
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    pshs      u
                    lbsr      L4103
                    leas      $06,s
                    std       $10,s
                    ldd       $06,s
                    clra
                    andb      #$30
                    cmpd      #$0030
                    lbeq      L343B
                    ldd       $005F
                    cmpd      #$0078
                    bne       L33B7
                    ldd       $06,s
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    pshs      u
                    lbsr      L4435
L33B2               leas      $06,s
                    lbra      L3421

L33B7               ldd       $10,s
                    bne       L33CA
                    ldd       $0e,s
                    cmpd      #$000E
                    beq       L33CA
                    lbsr      L42D4
                    lbra      L3421

L33CA               ldx       $0e,s
                    bra       L3409

L33CE               ldd       $0e,s
                    cmpd      #$0023
                    bne       L33DB
                    ldd       #$0001
                    bra       L33DD

L33DB               clra
                    clrb
L33DD               pshs      d
                    ldd       $12,s
                    pshs      d
                    pshs      u
                    lbsr      $66FB
                    bra       L33B2

L33EB               ldd       $0e,s
                    cmpd      #$0021
                    bne       L33F8
                    ldd       #$0001
                    bra       L33FA

L33F8               clra
                    clrb
L33FA               pshs      d
                    ldd       $12,s
                    pshs      d
                    pshs      u
                    lbsr      $66EB
                    lbra      L33B2

L3409               cmpx      #$0023
                    beq       L33CE
                    cmpx      #$000F
                    lbeq      L33CE
                    cmpx      #$0021
                    beq       L33EB
                    cmpx      #$000C
                    lbeq      L33EB
L3421               ldd       $0e,s
                    cmpd      #$000F
                    bne       L342E
                    ldd       #$000C
                    bra       L3439

L342E               ldd       $0e,s
                    cmpd      #$0023
                    bne       L343B
                    ldd       #$0021
L3439               std       $08,u
L343B               ldd       $06,s
                    clra
                    andb      #$30
                    cmpd      #$0030
                    lbne      L34B7
                    ldd       $06,s
                    pshs      d
                    lbsr      L047A
                    leas      $02,s
                    std       $06,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    beq       L3477
                    ldd       $06,s
                    clra
                    andb      #$30
                    cmpd      #$0030
                    beq       L3477
                    ldd       $06,s
                    cmpd      #$0004
                    beq       L3477
                    ldd       $06,s
                    cmpd      #$0003
                    bne       L348C
L3477               leax      $432F,pcr
                    pshs      x
                    lbsr      L024E
                    leas      $02,s
                    ldd       #$0031
                    std       ,u
                    ldd       #$0001
                    std       $06,s
L348C               ldd       $0e,s
                    cmpd      #$000E
                    bne       L34A1
                    leax      >$0047,y
                    pshs      x
                    lbsr      L4207
                    leas      $02,s
                    bra       L34B7

L34A1               ldd       $06,s
                    std       L004D
                    ldd       $0a,s
                    pshs      d
                    pshs      u
                    lbsr      L3907
                    leas      $04,s
                    bra       L34D4
                    bra       L34B7

L34B4               leas      -$14,x
L34B7               ldd       $005F
                    cmpd      #$0030
                    bne       L34C5
                    lbsr      L552E
                    lbra      L32C0

L34C5               ldd       #$0028
                    pshs      d
                    lbsr      L04BF
                    std       ,s++
                    beq       L34D4
                    lbsr      L0502
L34D4               leas      $14,s
                    puls      pc,u
L34D9               pshs      u
                    ldd       #$FFA4
                    lbsr      L0113
                    leas      -$12,s
                    lbsr      L3BE9
                    std       $10,s
                    tfr       d,x
                    bra       L3501

L34EE               leax      $4343,pcr
                    pshs      x
                    lbsr      L024E
                    leas      $02,s
L34F9               ldd       #$000D
                    std       $10,s
                    bra       L350C

L3501               stx       -$02,s
                    beq       L34F9
                    cmpx      #$0010
                    beq       L350C
                    bra       L34EE

L350C               leax      ,s
                    pshs      x
                    leax      $0C,s
                    pshs      x
                    leax      $0C,s
                    pshs      x
                    lbsr      L3C38
                    leas      $06,s
                    std       $0e,s
                    bne       L3526
                    ldd       #$0001
                    std       $0e,s
L3526               ldd       $0a,s
                    std       $0C,s
                    ldd       $0e,s
                    pshs      d
                    leax      $0e,s
                    pshs      x
                    leax      $06,s
                    pshs      x
                    lbsr      L3F8D
                    leas      $06,s
                    std       $04,s
                    ldu       $02,s
                    ldd       $04,s
                    clra
                    andb      #$30
                    cmpd      #$0030
                    beq       L355A
                    ldd       $04,s
                    cmpd      #$0004
                    beq       L355A
                    ldd       $04,s
                    cmpd      #$000A
                    bne       L3567
L355A               leax      $4354,pcr
                    pshs      x
                    lbsr      L024E
                    leas      $02,s
                    bra       L3598

L3567               ldd       $04,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    bne       L3582
                    ldd       $04,s
                    pshs      d
                    lbsr      L047A
                    std       ,s
                    lbsr      L0486
                    leas      $02,s
                    bra       L358D

L3582               ldd       $04,s
                    cmpd      #$0005
                    bne       L358F
                    ldd       #$0006
L358D               std       $04,s
L358F               cmpu      #$0000
                    bne       L359E
                    lbsr      L42E2
L3598               leax      $12,s
                    lbra      L35FB

L359E               ldd       $04,s
                    pshs      d
                    ldd       $12,s
                    pshs      d
                    lbsr      L38B2
                    leas      $04,s
                    std       $06,s
                    ldx       $08,u
                    bra       L35E8

L35B2               ldd       $04,s
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
                    lbsr      L4103
                    leas      $06,s
                    std       -$02,s
                    bne       L35FE
                    lbsr      L42D4
                    bra       L35FE

L35D6               lbsr      L0241
                    bra       L35FE

L35DB               leax      $4363,pcr
                    pshs      x
                    lbsr      L024E
                    leas      $02,s
                    bra       L35FE

L35E8               cmpx      #$000B
                    beq       L35B2
                    cmpx      #$000D
                    beq       L35D6
                    cmpx      #$0010
                    lbeq      L35D6
                    bra       L35DB

L35FB               leas      -$12,x
L35FE               ldd       $005F
                    cmpd      #$0078
                    bne       L3609
                    lbsr      L4980
L3609               ldd       $005F
                    cmpd      #$0030
                    bne       L3617
                    lbsr      L552E
                    lbra      L3526

L3617               ldd       #$0028
                    pshs      d
                    lbsr      L04BF
                    std       ,s++
                    lbeq      L3879
                    lbsr      L0502
                    lbra      L3879

L362B               pshs      u
                    ldd       #$FF9E
                    lbsr      L0113
                    leas      -$12,s
                    lbsr      L3BE9
                    std       $10,s
                    tfr       d,x
                    bra       L3653

L3640               leax      $4373,pcr
                    pshs      x
                    lbsr      L024E
                    leas      $02,s
L364B               ldd       #$000D
                    std       $10,s
                    bra       L365C

L3653               cmpx      #$0021
                    beq       L3640
                    stx       -$02,s
                    beq       L364B
L365C               leax      $02,s
                    pshs      x
                    leax      $0C,s
                    pshs      x
                    leax      $0C,s
                    pshs      x
                    lbsr      L3C38
                    leas      $06,s
                    std       $0e,s
                    bne       L3676
                    ldd       #$0001
                    std       $0e,s
L3676               leas      -$06,s
                    ldd       $10,s
                    std       ,s
                    ldd       $14,s
                    pshs      d
                    leax      $02,s
                    pshs      x
                    leax      $0e,s
                    pshs      x
                    lbsr      L3F8D
                    leas      $06,s
                    std       $12,s
                    ldu       $0a,s
                    bne       L36B2
                    ldd       $12,s
                    cmpd      #$0004
                    lbeq      L371D
                    ldd       $12,s
                    cmpd      #$0003
                    lbeq      L371D
                    lbsr      L42E2
                    lbra      L371D

L36B2               ldd       $12,s
                    clra
                    andb      #$30
                    cmpd      #$0030
                    beq       L36C7
                    ldd       $16,s
                    cmpd      #$000E
                    bne       L36FE
L36C7               ldd       ,u
                    bne       L36EC
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
                    lbsr      L4103
                    bra       L36FA

L36EC               ldd       $08,s
                    pshs      d
                    ldd       $14,s
                    pshs      d
                    pshs      u
                    lbsr      L387E
L36FA               leas      $06,s
                    bra       L371D

L36FE               ldd       $12,s
                    pshs      d
                    ldd       $18,s
                    pshs      d
                    lbsr      L38B2
                    leas      $04,s
                    std       $04,s
                    ldd       ,u
                    beq       L372A
                    ldd       $0C,u
                    cmpd      L0051
                    bne       L3723
                    lbsr      L0241
L371D               leax      $18,s
                    lbra      L3858

L3723               pshs      u
                    lbsr      L0180
                    leas      $02,s
L372A               ldd       $12,s
                    std       ,u
                    ldd       $04,s
                    std       $08,u
                    ldd       $08,s
                    std       $0a,u
                    ldd       L0051
                    std       $0C,u
                    ldd       $004B
                    std       $10,u
                    stu       $004B
                    ldd       $0e,s
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    pshs      u
                    lbsr      L4103
                    leas      $06,s
                    std       $02,s
                    bne       L3760
                    ldd       $005F
                    cmpd      #$0078
                    beq       L3760
                    lbsr      L42D4
L3760               ldx       $04,s
                    bra       L3779

L3764               ldd       L0031
                    subd      $02,s
                    std       L0031
                    ldd       L0031
                    bra       L3775

L376E               ldd       L002B
                    addd      #$0001
                    std       L002B
L3775               std       $06,u
                    bra       L378A

L3779               cmpx      #$000D
                    beq       L3764
                    cmpx      #$0023
                    beq       L376E
                    cmpx      #$000F
                    lbeq      L376E
L378A               ldd       $005F
                    cmpd      #$0078
                    lbne      L3827
                    ldd       $04,s
                    cmpd      #$000F
                    beq       L37A4
                    ldd       $04,s
                    cmpd      #$0023
                    bne       L37B7
L37A4               ldd       $12,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    lbsr      L4435
L37B2               leas      $06,s
                    lbra      L385B

L37B7               lbsr      L552E
                    ldd       $12,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    lbeq      L3822
                    ldd       $12,s
                    cmpd      #$0004
                    lbeq      L3822
                    ldd       #$0002
                    pshs      d
                    lbsr      L0583
                    leas      $02,s
                    std       $0C,s
                    beq       L3822
                    ldd       $0009
                    beq       L37F6
                    ldd       $0009
                    std       $06,s
                    tfr       d,x
                    ldd       ,x
                    std       $0009
                    clra
                    clrb
                    std       [$06,s]
                    bra       L3802

L37F6               ldd       #$0006
                    pshs      d
                    lbsr      L5C2A
                    leas      $02,s
                    std       $06,s
L3802               ldd       $0C,s
                    ldx       $06,s
                    std       $02,x
                    ldx       $06,s
                    stu       $04,x
                    ldd       $0005
                    beq       L3818
                    ldd       $06,s
                    std       [$0007,y]
                    bra       L381C

L3818               ldd       $06,s
                    std       $0005
L381C               ldd       $06,s
                    std       $0007
                    bra       L385B

L3822               lbsr      L4980
                    bra       L385B

L3827               ldx       $04,s
                    bra       L384A

L382B               ldd       $04,s
                    cmpd      #$0023
                    bne       L3838
                    ldd       #$0001
                    bra       L383A

L3838               clra
                    clrb
L383A               pshs      d
                    ldd       $04,s
                    pshs      d
                    ldd       $06,u
                    pshs      d
                    lbsr      $66C1
                    lbra      L37B2

L384A               cmpx      #$000F
                    beq       L382B
                    cmpx      #$0023
                    lbeq      L382B
                    bra       L385B

L3858               leas      -$18,x
L385B               ldd       $005F
                    cmpd      #$0030
                    beq       L3867
                    leas      $06,s
                    bra       L386F

L3867               lbsr      L552E
                    leas      $06,s
                    lbra      L3676

L386F               ldd       #$0028
                    pshs      d
                    lbsr      L04BF
                    leas      $02,s
L3879               leas      $12,s
                    puls      pc,u
L387E               pshs      u
                    ldd       #$FFBA
                    lbsr      L0113
                    ldu       $04,s
                    ldd       ,u
                    cmpd      $06,s
                    bne       L389E
                    ldd       $06,s
                    cmpd      #$0004
                    bne       L38AE
                    ldd       $0a,u
                    cmpd      $08,s
                    beq       L38AE
L389E               leax      $4381,pcr
                    pshs      x
                    lbsr      L024E
                    leas      $02,s
                    ldd       #$0001
                    puls      pc,u
L38AE               clra
                    clrb
                    puls      pc,u
L38B2               pshs      u
                    ldd       #$FFC0
                    lbsr      L0113
                    ldd       $04,s
                    cmpd      #$0010
                    bne       L3903
                    ldd       $0003
                    cmpd      #$0001
                    bge       L38FE
                    ldx       $06,s
                    bra       L38F0

L38CE               ldd       $06,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L38FE
L38D9               ldd       $0003
                    addd      #$0001
                    std       $0003
                    cmpd      #$0001
                    bne       L38EB
                    ldd       #$006F
                    bra       L38EE

L38EB               ldd       #$0076
L38EE               puls      pc,u
L38F0               cmpx      #$0001
                    beq       L38D9
                    cmpx      #$0007
                    lbeq      L38D9
                    bra       L38CE

L38FE               ldd       #$000D
                    puls      pc,u
L3903               ldd       $04,s
                    puls      pc,u
L3907               pshs      u
                    ldd       #$FFAC
                    lbsr      L0113
                    leas      -$0a,s
                    ldd       #$0001
                    std       L0051
                    clra
                    clrb
                    std       $002F
                    std       L003B
                    std       L0031
                    std       $0003
                    std       L0033
                    bra       L3927

L3924               lbsr      L34D9
L3927               ldd       $005F
                    cmpd      #$0029
                    bne       L3924
                    ldd       $0e,s
                    addd      #$0014
                    std       $02,s
                    ldd       L0037
                    beq       L394E
                    ldd       L002B
                    addd      #$0001
                    std       L002B
                    std       ,s
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    lbsr      $679F
                    leas      $04,s
L394E               ldd       ,s
                    pshs      d
                    ldd       $12,s
                    cmpd      #$000F
                    beq       L3960
                    ldd       #$0001
                    bra       L3962

L3960               clra
                    clrb
L3962               pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      $6742
                    leas      $06,s
                    ldu       L0047
                    ldd       #$0004
                    std       $08,s
                    lbra      L39EB

L3977               leas      -$02,s
                    ldd       $0a,s
                    std       $06,u
                    ldx       ,u
                    bra       L3999

L3981               ldd       #$0004
                    bra       L3995

L3986               ldd       #$0008
                    bra       L3995

L398B               ldd       $06,u
                    addd      #$0001
                    std       $06,u
L3992               ldd       #$0002
L3995               std       ,s
                    bra       L39B1

L3999               cmpx      #$0008
                    beq       L3981
                    cmpx      #$0005
                    lbeq      L3981
                    cmpx      #$0006
                    beq       L3986
                    cmpx      #$0002
                    beq       L398B
                    bra       L3992

L39B1               ldd       $08,u
                    std       $08,s
                    tfr       d,x
                    bra       L39CF

L39B9               ldd       $0a,s
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    lbsr      L4B61
                    leas      $04,s
                    bra       L39E0

L39C8               ldd       #$000D
                    std       $08,u
                    bra       L39E0

L39CF               cmpx      #$006F
                    beq       L39B9
                    cmpx      #$0076
                    lbeq      L39B9
                    cmpx      #$000B
                    beq       L39C8
L39E0               ldd       $0a,s
                    addd      ,s
                    std       $0a,s
                    ldu       $10,u
                    leas      $02,s
L39EB               stu       -$02,s
                    lbne      L3977
                    ldd       L0047
                    std       $04,s
                    clra
                    clrb
                    std       L0047
                    lbsr      L3A4F
                    leax      $04,s
                    pshs      x
                    lbsr      L4207
                    leas      $02,s
                    leax      >$0049,y
                    pshs      x
                    lbsr      L4207
                    leas      $02,s
                    ldd       L004F
                    cmpd      #$0012
                    beq       L3A2A
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    ldd       #$0012
                    pshs      d
                    lbsr      L4B61
                    leas      $06,s
L3A2A               clra
                    clrb
                    std       L004F
                    lbsr      $67D1
                    clra
                    clrb
                    std       L0051
                    ldd       $005F
                    cmpd      #$FFFF
                    bne       L3A48
                    leax      $4396,pcr
                    pshs      x
                    lbsr      L024E
                    leas      $02,s
L3A48               lbsr      L552E
                    leas      $0a,s
                    puls      pc,u
L3A4F               pshs      u
                    ldd       #$FFAA
                    lbsr      L0113
                    leas      -$06,s
                    ldd       $004B
                    std       $02,s
                    clra
                    clrb
                    std       $004B
                    lbsr      L552E
                    ldd       L0051
                    addd      #$0001
                    std       L0051
                    ldd       L0031
                    std       ,s
                    bra       L3A74

L3A71               lbsr      L362B
L3A74               lbsr      L043F
                    std       -$02,s
                    bne       L3A71
                    lbsr      L03DD
                    std       -$02,s
                    lbne      L3A71
                    ldd       L003B
                    cmpd      L0031
                    ble       L3A8F
                    ldd       L0031
                    std       L003B
L3A8F               ldd       L0031
                    pshs      d
                    lbsr      L4B33
                    leas      $02,s
                    std       $002F
                    lbra      L3B0D

L3A9D               ldd       $0005
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
                    lbsr      L0DD6
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
                    lbsr      L0DD6
                    leas      $0C,s
                    tfr       d,u
                    pshs      u
                    lbsr      L0F1B
                    std       ,s
                    lbsr      L4C52
                    std       ,s
                    lbsr      L0396
                    leas      $02,s
                    ldd       [$04,s]
                    std       $04,s
                    ldd       $0009
                    std       [$0005,y]
                    ldd       $0005
                    std       $0009
                    ldd       $04,s
                    std       $0005
L3B0D               ldd       $0005
                    lbne      L3A9D
                    bra       L3B18

L3B15               lbsr      L27D3
L3B18               ldd       $005F
                    cmpd      #$002A
                    beq       L3B28
                    ldd       $005F
                    cmpd      #$FFFF
                    bne       L3B15
L3B28               leax      >$004b,y
                    pshs      x
                    lbsr      L4207
                    leas      $02,s
                    ldd       $02,s
                    std       $004B
                    ldd       L0051
                    addd      #$FFFF
                    std       L0051
                    ldd       ,s
                    std       L0031
                    ldd       L004F
                    cmpd      #$0012
                    beq       L3B55
                    ldd       ,s
                    pshs      d
                    lbsr      L4B33
                    leas      $02,s
                    bra       L3B57

L3B55               ldd       ,s
L3B57               std       $002F
                    leas      $06,s
                    puls      pc,u
L3B5D               pshs      u
                    ldd       #$FFB8
                    lbsr      L0113
                    leas      -$02,s
                    clra
                    clrb
                    std       [$06,s]
L3B6C               lbsr      L552E
                    ldd       $005F
                    cmpd      #$002E
                    lbeq      L3BDD
                    ldd       $005F
                    cmpd      #$0034
                    bne       L3BD0
                    ldu       $0061
                    ldd       $08,u
                    cmpd      #$000B
                    bne       L3B96
                    leax      L43AA,pcr
                    pshs      x
                    lbsr      L024E
                    bra       L3B9F

L3B96               ldd       ,u
                    beq       L3BA1
                    pshs      u
                    lbsr      L0180
L3B9F               leas      $02,s
L3BA1               ldd       #$0001
                    std       ,u
                    ldd       #$000B
                    std       $08,u
                    ldd       #$0001
                    std       $0C,u
                    ldd       #$0002
                    std       $02,u
                    ldd       [$06,s]
                    beq       L3BC1
                    ldx       ,s
                    stu       $10,x
                    bra       L3BC4

L3BC1               stu       [$06,s]
L3BC4               clra
                    clrb
                    std       $10,u
                    stu       ,s
                    lbsr      L552E
                    bra       L3BD3

L3BD0               lbsr      L42E2
L3BD3               ldd       $005F
                    cmpd      #$0030
                    lbeq      L3B6C
L3BDD               ldd       #$002E
                    pshs      d
                    lbsr      L04BF
                    leas      $02,s
                    bra       L3C34

L3BE9               pshs      u
                    ldd       #$FFBA
                    lbsr      L0113
                    leas      -$02,s
                    lbsr      L043F
                    std       -$02,s
                    beq       L3C32
                    ldd       $0061
                    std       ,s
                    lbsr      L552E
                    ldd       $005F
                    cmpd      #$0033
                    bne       L3C2E
                    ldd       $0061
                    cmpd      #$0021
                    bne       L3C2E
                    ldx       ,s
                    bra       L3C21

L3C15               ldd       #$0023
                    bra       L3C1D

L3C1A               ldd       #$0022
L3C1D               std       ,s
                    bra       L3C2B

L3C21               cmpx      #$000F
                    beq       L3C15
                    cmpx      #$000E
                    beq       L3C1A
L3C2B               lbsr      L552E
L3C2E               ldd       ,s
                    bra       L3C34

L3C32               clra
                    clrb
L3C34               leas      $02,s
L3C36               puls      pc,u
L3C38               pshs      u
                    ldd       #$FF98
                    lbsr      L0113
                    leas      -$1a,s
                    clra
                    clrb
                    std       $02,s
                    ldd       #$0002
                    std       ,s
                    clra
                    clrb
                    std       [$22,s]
                    ldd       $005F
                    cmpd      #$0033
                    lbne      L3F54
                    ldd       $0061
                    std       $02,s
                    tfr       d,x
                    lbra      L3F12

L3C64               ldd       #$0001
                    std       $02,s
L3C69               lbsr      L552E
                    ldd       $005F
                    cmpd      #$0033
                    lbne      L3F7C
                    ldd       $0061
                    cmpd      #$0001
                    lbne      L3F7C
                    bra       L3CBA

L3C82               ldd       #$0001
                    bra       L3CB8

L3C87               lbsr      L552E
                    ldd       #$0004
                    std       ,s
                    ldd       $005F
                    cmpd      #$0033
                    lbne      L3F7C
                    ldd       $0061
                    cmpd      #$0001
                    beq       L3CBA
                    ldd       $0061
                    cmpd      #$0005
                    lbne      L3F7C
L3CAB               ldd       #$0006
                    std       $02,s
                    ldd       #$0008
                    bra       L3CB8

L3CB5               ldd       #$0004
L3CB8               std       ,s
L3CBA               lbsr      L552E
                    lbra      L3F7C

L3CC0               clra
                    clrb
                    std       $02,s
                    lbra      L3F7C

L3CC7               clra
                    clrb
                    std       $16,s
                    std       ,s
                    ldd       $0041
                    addd      #$0001
                    std       $0041
                    clra
                    clrb
                    std       $18,s
                    lbsr      L552E
                    ldd       $0041
                    addd      #$FFFF
                    std       $0041
                    ldd       $005F
                    cmpd      #$0034
                    lbne      L3D60
                    ldd       $0061
                    std       $18,s
                    ldd       [$18,s]
                    bne       L3D08
                    ldd       #$000A
                    std       [$18,s]
                    ldd       #$0008
                    ldx       $18,s
                    std       $08,x
                    bra       L3D1E

L3D08               ldx       $18,s
                    ldd       $08,x
                    cmpd      #$0008
                    beq       L3D1E
                    leax      $43B6,pcr
                    pshs      x
                    lbsr      L024E
                    leas      $02,s
L3D1E               lbsr      L552E
                    ldd       $005F
                    cmpd      #$0029
                    beq       L3D54
                    ldd       [$18,s]
                    cmpd      #$0004
                    bne       L3D48
                    ldx       $18,s
                    ldd       $02,x
                    std       [$1e,s]
                    ldx       $18,s
                    ldd       $0a,x
                    std       [$22,s]
                    ldd       #$0004
                    lbra      L3F88

L3D48               ldd       $18,s
                    std       [$1e,s]
                    ldd       #$000A
                    lbra      L3F88

L3D54               ldd       [$18,s]
                    cmpd      #$0004
                    bne       L3D60
                    lbsr      L0241
L3D60               ldd       $005F
                    cmpd      #$0029
                    beq       L3D76
                    leax      L43C1,pcr
                    pshs      x
                    lbsr      L024E
                    leas      $02,s
                    lbra      L3F7C

L3D76               ldd       $0041
                    addd      #$0001
                    std       $0041
L3D7D               ldd       $0041
                    std       $10,s
                    clra
                    clrb
                    std       $0041
                    lbsr      L552E
                    ldd       $10,s
                    std       $0041
                    ldd       $005F
                    cmpd      #$002A
                    lbeq      L3EE5
                    leax      $04,s
                    pshs      x
                    leax      $0e,s
                    pshs      x
                    leax      $18,s
                    pshs      x
                    lbsr      L3C38
                    leas      $06,s
                    std       $12,s
                    bra       L3DAF

L3DAF               leas      -$04,s
                    ldd       $10,s
                    std       $02,s
                    ldd       $005F
                    cmpd      #$0028
                    lbeq      L3ECF
                    ldd       L0051
                    addd      #$0001
                    std       L0051
                    ldd       $16,s
                    pshs      d
                    leax      $04,s
                    pshs      x
                    leax      $04,s
                    pshs      x
                    lbsr      L3F8D
                    leas      $06,s
                    std       $12,s
                    ldu       ,s
                    ldd       L0051
                    addd      #$FFFF
                    std       L0051
                    cmpu      #$0000
                    bne       L3DF4
                    lbsr      L42E2
                    leax      $1e,s
                    lbra      L3EC4

L3DF4               ldd       ,u
                    beq       L3E29
                    ldd       $0C,u
                    cmpd      L0051
                    bne       L3E22
                    ldd       ,u
                    cmpd      $12,s
                    bne       L3E17
                    ldd       $08,u
                    cmpd      #$0011
                    bne       L3E17
                    ldd       $06,u
                    cmpd      $1a,s
                    beq       L3E29
L3E17               leax      $43CF,pcr
                    pshs      x
                    lbsr      L024E
                    bra       L3E27

L3E22               pshs      u
                    lbsr      L0180
L3E27               leas      $02,s
L3E29               ldd       $12,s
                    cmpd      #$000A
                    bne       L3E3D
                    leax      $43E6,pcr
                    pshs      x
                    lbsr      L024E
                    leas      $02,s
L3E3D               ldd       $12,s
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
                    lbsr      L4103
                    leas      $06,s
                    std       $0e,s
                    beq       L3E87
                    ldd       $06,s
                    cmpd      #$0004
                    bne       L3E76
                    ldd       $1a,s
                    addd      $0e,s
                    std       $1a,s
                    bra       L3E83

L3E76               ldd       $0e,s
                    cmpd      $04,s
                    ble       L3E81
                    ldd       $0e,s
                    bra       L3E83

L3E81               ldd       $04,s
L3E83               std       $04,s
                    bra       L3E8A

L3E87               lbsr      L42D4
L3E8A               ldd       L0051
                    std       $0C,u
                    ldd       $004B
                    std       $10,u
                    stu       $004B
                    ldd       $06,s
                    cmpd      #$0004
                    bne       L3EC7
                    ldd       #$0004
                    pshs      d
                    lbsr      L5C2A
                    leas      $02,s
                    std       $0C,s
                    ldx       $0C,s
                    stu       $02,x
                    ldd       [$26,s]
                    beq       L3EB9
                    ldd       $0C,s
                    std       [$0a,s]
                    bra       L3EBE

L3EB9               ldd       $0C,s
                    std       [$26,s]
L3EBE               ldd       $0C,s
                    std       $0a,s
                    bra       L3EC7

L3EC4               leas      -$1e,x
L3EC7               ldd       $005F
                    cmpd      #$0030
                    beq       L3ED3
L3ECF               leas      $04,s
                    bra       L3EDB

L3ED3               lbsr      L552E
                    leas      $04,s
                    lbra      L3DAF

L3EDB               ldd       $005F
                    cmpd      #$0028
                    lbeq      L3D7D
L3EE5               ldd       $0041
                    addd      #$FFFF
                    std       $0041
                    ldd       $18,s
                    beq       L3F06
                    ldd       ,s
                    ldx       $18,s
                    std       $02,x
                    ldd       #$0004
                    std       [$18,s]
                    ldd       [$22,s]
                    ldx       $18,s
                    std       $0a,x
L3F06               ldd       #$002A
                    pshs      d
                    lbsr      L04BF
                    leas      $02,s
                    bra       L3F7C

L3F12               cmpx      #$000A
                    lbeq      L3C64
                    cmpx      #$0007
                    lbeq      L3C69
                    cmpx      #$0002
                    lbeq      L3C82
                    cmpx      #$0001
                    lbeq      L3CBA
                    cmpx      #$0008
                    lbeq      L3C87
                    cmpx      #$0006
                    lbeq      L3CAB
                    cmpx      #$0005
                    lbeq      L3CB5
                    cmpx      #$0003
                    lbeq      L3CC7
                    cmpx      #$0004
                    lbeq      L3CC7
                    lbra      L3CC0

L3F54               ldd       $005F
                    cmpd      #$0034
                    bne       L3F7C
                    ldu       $0061
                    ldd       $08,u
                    cmpd      #start
                    bne       L3F7C
                    ldd       $02,u
                    std       [$1e,s]
                    ldd       $04,u
                    std       [$20,s]
                    ldd       $0a,u
                    std       [$22,s]
                    lbsr      L552E
                    ldd       ,u
                    bra       L3F88

L3F7C               ldd       ,s
                    std       [$1e,s]
                    clra
                    clrb
                    std       [$20,s]
                    ldd       $02,s
L3F88               leas      $1a,s
L3F8B               puls      pc,u
L3F8D               pshs      u
                    ldd       #$FFAA
                    lbsr      L0113
                    leas      -$0C,s
                    clra
                    clrb
                    std       [$10,s]
                    std       $0a,s
                    bra       L3FAE

L3FA0               ldd       $0a,s
                    pshs      d
                    lbsr      L0486
                    leas      $02,s
                    std       $0a,s
                    lbsr      L552E
L3FAE               ldd       $005F
                    cmpd      #$0042
                    beq       L3FA0
                    ldd       $005F
                    cmpd      #$0034
                    bne       L3FC8
                    ldd       $0061
                    std       [$10,s]
                    lbsr      L552E
                    bra       L4002

L3FC8               ldd       $005F
                    cmpd      #$002D
                    bne       L4002
                    lbsr      L552E
                    ldd       L0051
                    addd      #$0001
                    std       L0051
                    ldd       $14,s
                    pshs      d
                    ldd       $14,s
                    pshs      d
                    ldd       $14,s
                    pshs      d
                    lbsr      L3F8D
                    leas      $06,s
                    std       $14,s
                    ldd       L0051
                    addd      #$FFFF
                    std       L0051
                    ldd       #$002E
                    pshs      d
                    lbsr      L04BF
                    leas      $02,s
L4002               ldd       $005F
                    cmpd      #$002D
                    bne       L4039
                    ldd       $0a,s
                    aslb
                    rola
                    aslb
                    rola
                    addd      #$0030
                    std       $0a,s
                    ldd       L0051
                    bne       L4024
                    leax      >$0047,y
                    pshs      x
                    lbsr      L3B5D
                    bra       L4034

L4024               leax      ,s
                    pshs      x
                    lbsr      L3B5D
                    leas      $02,s
                    leax      ,s
                    pshs      x
                    lbsr      L4207
L4034               leas      $02,s
                    lbra      L40BC

L4039               clra
                    clrb
                    std       $06,s
                    std       $04,s
                    std       $02,s
                    ldd       $0041
                    std       $08,s
                    clra
                    clrb
                    std       $0041
                    lbra      L40A0

L404C               ldd       $0a,s
                    aslb
                    rola
                    aslb
                    rola
                    addd      #$0020
                    std       $0a,s
                    lbsr      L552E
                    ldd       #$0004
                    pshs      d
                    lbsr      L5C2A
                    leas      $02,s
                    tfr       d,u
                    ldd       $04,s
                    bne       L4076
                    ldd       $005F
                    cmpd      #$002C
                    bne       L4076
                    clra
                    clrb
                    bra       L407F

L4076               clra
                    clrb
                    pshs      d
                    lbsr      L0A52
                    leas      $02,s
L407F               std       ,u
                    ldd       $06,s
                    beq       L408B
                    ldx       $06,s
                    stu       $02,x
                    bra       L408D

L408B               stu       $02,s
L408D               stu       $06,s
                    ldd       #$002C
                    pshs      d
                    lbsr      L04BF
                    leas      $02,s
                    ldd       $04,s
                    addd      #$0001
                    std       $04,s
L40A0               ldd       $005F
                    cmpd      #$002B
                    lbeq      L404C
                    ldd       $08,s
                    std       $0041
                    ldd       $02,s
                    beq       L40BC
                    ldd       [$12,s]
                    std       $02,u
                    ldd       $02,s
                    std       [$12,s]
L40BC               ldd       $0a,s
                    pshs      d
                    ldd       $16,s
                    pshs      d
                    bsr       L40CD
                    leas      $04,s
                    leas      $0C,s
                    puls      pc,u
L40CD               pshs      u
                    ldd       #$FFBC
                    lbsr      L0113
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
                    bra       L40F5

L40DD               ldd       ,s
                    pshs      d
                    ldd       #$0002
                    lbsr      L7660
                    std       ,s
                    ldd       $08,s
                    pshs      d
                    ldd       #$0002
                    lbsr      L7683
                    std       $08,s
L40F5               ldd       ,s
                    clra
                    andb      #$30
                    bne       L40DD
                    ldd       $06,s
                    addd      $08,s
                    lbra      L42F3

L4103               pshs      u
                    ldd       #$FFB2
                    lbsr      L0113
                    ldu       $04,s
                    leas      -$04,s
                    ldd       ,u
                    std       $02,s
                    clra
                    andb      #$0f
                    tfr       d,x
                    bra       L4138

L411A               ldd       #$0001
                    bra       L4134

L411F               ldd       #$0002
                    bra       L4134

L4124               ldd       #$0004
                    bra       L4134

L4129               ldd       #$0008
                    bra       L4134

L412E               ldd       $0C,s
                    bra       L4134

L4132               clra
                    clrb
L4134               std       ,s
                    bra       L416B

L4138               cmpx      #$0002
                    beq       L411A
                    cmpx      #$0001
                    beq       L411F
                    cmpx      #$0007
                    lbeq      L411F
                    cmpx      #$0008
                    beq       L4124
                    cmpx      #$0005
                    lbeq      L4124
                    cmpx      #$0006
                    beq       L4129
                    cmpx      #$0003
                    beq       L412E
                    cmpx      #$0004
                    lbeq      L412E
                    cmpx      #$000A
                    beq       L4132
L416B               ldd       ,s
                    beq       L4173
                    ldd       ,s
                    bra       L4175

L4173               ldd       $0C,s
L4175               std       $02,u
                    ldd       $0a,s
                    std       $04,u
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    bsr       L418D
                    leas      $06,s
                    leas      $04,s
L418B               puls      pc,u
L418D               pshs      u
                    ldd       #$FFB8
                    lbsr      L0113
                    ldu       $08,s
                    leas      -$02,s
                    ldd       $06,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    beq       L41AF
                    ldd       $06,s
                    clra
                    andb      #$30
                    cmpd      #$0030
                    bne       L41B5
L41AF               ldd       #$0002
                    lbra      L42F3

L41B5               ldd       $06,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    bne       L4202
                    ldd       #$0001
                    std       ,s
L41C5               ldd       ,s
                    pshs      d
                    ldd       ,u
                    lbsr      L7542
                    std       ,s
                    ldu       $02,u
                    ldd       $06,s
                    pshs      d
                    lbsr      L047A
                    leas      $02,s
                    std       $06,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    beq       L41C5
                    ldd       ,s
                    pshs      d
                    ldd       $08,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L41FA
                    ldd       #$0002
                    bra       L41FC

L41FA               ldd       $0a,s
L41FC               lbsr      L7542
                    lbra      L42F3

L4202               ldd       $08,s
                    lbra      L42F3

L4207               pshs      u
                    ldd       #$FF74
                    lbsr      L0113
                    leas      -$40,s
                    ldu       [$44,s]
                    lbra      L42C4

L4218               ldd       $10,u
                    std       $3C,s
                    ldd       ,u
                    cmpd      #$0009
                    bne       L4258
                    ldd       $0a,u
                    clra
                    andb      #$01
                    bne       L4258
                    ldd       #$0008
                    pshs      d
                    pshs      u
                    ldd       #$0014
                    addd      ,s++
                    pshs      d
                    leax      $43FA,pcr
                    pshs      x
                    leax      $06,s
                    pshs      x
                    lbsr      $7314
                    leas      $04,s
                    pshs      d
                    lbsr      $740C
                    leas      $06,s
                    pshs      d
                    lbsr      L024E
                    leas      $02,s
L4258               ldx       $08,u
                    bra       L4265

L425C               ldd       $0003
                    addd      #$FFFF
                    std       $0003
                    bra       L4271

L4265               cmpx      #$006F
                    beq       L425C
                    cmpx      #$0076
                    lbeq      L425C
L4271               ldd       $0e,u
                    std       $3e,s
                    cmpd      L0066
                    bls       L428C
                    ldd       $3e,s
                    cmpd      $0068
                    bcc       L428C
                    pshs      u
                    lbsr      L01D2
                    leas      $02,s
                    bra       L42C1

L428C               cmpu      [$3e,s]
                    bne       L429A
                    ldd       $12,u
                    std       [$3e,s]
                    bra       L42BA

L429A               ldd       [$3e,s]
                    bra       L42A5

L429F               ldx       $3e,s
                    ldd       $12,x
L42A5               std       $3e,s
                    ldx       $3e,s
                    cmpu      $12,x
                    bne       L429F
                    ldd       $12,u
                    ldx       $3e,s
                    std       $12,x
L42BA               ldd       L0019
                    std       $12,u
                    stu       L0019
L42C1               ldu       $3C,s
L42C4               stu       -$02,s
                    lbne      L4218
                    clra
                    clrb
                    std       [$44,s]
                    leas      $40,s
                    puls      pc,u
L42D4               pshs      u
                    ldd       #$FFBA
                    lbsr      L0113
                    leax      L440D,pcr
L42E0               bra       L42EE

L42E2               pshs      u
                    ldd       #$FFBA
                    lbsr      L0113
                    leax      $4422,pcr
L42EE               pshs      x
                    lbsr      L024E
L42F3               leas      $02,s
                    puls      pc,u
L42F7               lsr       $6F6F
                    bra       $4369
                    fcb       $61
                    jmp       -$07,s
                    bra       $4363
                    fcb       $72
                    fcb       $61
                    com       $0b,s
                    fcb       $65
                    lsr       L7300
L4309               ror       -$0b,s
                    jmp       $03,s
                    lsr       L696F
                    jmp       0,y
                    asl       $05,s
                    fcb       $61
                    lsr       $05,s
                    fcb       $72
                    bra       L4387
                    rol       -$0d,s
                    com       $696E
                    asr       0,x
L4321               com       L746F
                    fcb       $72
                    fcb       $61
                    asr       $05,s
                    bra       L438F
                    fcb       $72
                    fcb       $72
                    clr       -$0e,s
                    neg       L0066
                    fcb       $75
                    jmp       $03,s
                    lsr       L696F
                    jmp       0,y
                    lsr       L7970
                    fcb       $65
                    bra       $43A3
                    fcb       $72
                    fcb       $72
                    clr       -$0e,s
                    neg       $0061
                    fcb       $72
                    asr       -$0b,s
                    tst       $05,s
                    jmp       -$0C,s
                    bra       $43C0
                    lsr       $6F72
                    fcb       $61
                    asr       $05,s
                    neg       $0061
                    fcb       $72
                    asr       -$0b,s
                    tst       $05,s
                    jmp       -$0C,s
                    bra       $43C3
                    fcb       $72
                    fcb       $72
                    clr       -$0e,s
                    neg       $006E
                    clr       -$0C,s
                    bra       L43C9
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
                    bra       $43E1
                    fcb       $72
                    fcb       $72
                    clr       -$0e,s
                    neg       L0064
                    fcb       $65
                    com       $0C,s
                    fcb       $61
                    fcb       $72
L4387               fcb       $61
                    lsr       L696F
                    jmp       0,y
                    tst       $09,s
L438F               com       L6D61
                    lsr       $6368
                    neg       L0066
                    fcb       $75
                    jmp       $03,s
                    lsr       L696F
                    jmp       0,y
                    fcb       $75
                    jmp       $06,s
                    rol       $0e,s
                    rol       -$0d,s
                    asl       $05,s
                    lsr       0,x
L43AA               jmp       $01,s
                    tst       $05,s
                    lsr       0,y
                    lsr       L7769
                    com       $05,s
                    neg       $006E
                    fcb       $61
                    tst       $05,s
                    bra       $441F
                    inc       $01,s
                    com       $6800
L43C1               com       $7472
                    fcb       $75
                    com       -$0C,s
                    bra       $443C

L43C9               rol       L6E74
                    fcb       $61
                    asl       >$0073
                    lsr       $7275
                    com       -$0C,s
                    bra       $4444
                    fcb       $65
                    tst       $02,s
                    fcb       $65
                    fcb       $72
                    bra       L444B
                    rol       -$0d,s
                    tst       $01,s
                    lsr       $6368
                    neg       $0075
                    jmp       $04,s
                    fcb       $65
                    ror       $09,s
                    jmp       $05,s
                    lsr       0,y
                    com       $7472
                    fcb       $75
                    com       -$0C,s
                    fcb       $75
                    fcb       $72
                    fcb       $65
                    neg       $006C
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
                    bra       L440D

L440D               com       $01,s
                    jmp       $0e,s
                    clr       -$0C,s
                    bra       L447A
                    ror       L616C
                    fcb       $75
                    fcb       $61
                    lsr       $6520
                    com       $697A
                    fcb       $65
                    neg       L0069
                    lsr       $05,s
                    jmp       -$0C,s
                    rol       $06,s
                    rol       $05,s
                    fcb       $72
                    bra       $449B
                    rol       -$0d,s
                    com       $696E
                    asr       0,x
L4435               pshs      u
                    ldd       #$FFB0
                    lbsr      L0113
                    ldu       $04,s
                    leas      -$04,s
                    ldx       $0a,s
                    bra       L445B

L4445               lbsr      L4980
                    lbra      L456F

L444B               ldd       #$0001
                    bra       L4452

L4450               clra
                    clrb
L4452               pshs      d
                    lbsr      $6814
                    leas      $02,s
                    bra       L447C

L445B               cmpx      #start
                    beq       L4445
                    cmpx      #$000E
                    lbeq      L4445
                    cmpx      #$0022
                    lbeq      L4445
                    cmpx      #$0021
                    beq       L444B
                    cmpx      #$0023
                    lbeq      L444B
L447A               bra       L4450

L447C               ldd       L0051
                    bne       L44AE
                    leax      $14,u
                    stx       $02,s
                    ldd       $0a,s
                    cmpd      #$000F
                    beq       L449A
                    ldd       $0a,s
                    cmpd      #$0023
                    beq       L449A
                    ldd       #$0001
                    bra       L44A1

L449A               ldd       #$000C
                    std       $08,u
                    clra
                    clrb
L44A1               pshs      d
                    ldd       $04,s
                    pshs      d
                    lbsr      L4A23
                    leas      $04,s
                    bra       L44BD

L44AE               lbsr      L4BEF
                    ldd       $06,u
                    pshs      d
                    lbsr      L4B04
                    leas      $02,s
                    lbsr      L4A77
L44BD               ldd       $0C,s
                    cmpd      #$0022
                    bne       L4511
                    ldd       #$0001
                    std       $000B
                    lbsr      L552E
                    ldd       $005F
                    cmpd      #$0037
                    bne       L450A
                    ldd       $04,u
                    std       $02,s
                    ldd       [$02,s]
                    bne       L44E5
                    ldd       L0017
                    std       [$02,s]
                    bra       L4502

L44E5               ldd       [$02,s]
                    subd      L0017
                    std       ,s
                    blt       L44F7
                    ldd       ,s
                    pshs      d
                    lbsr      $603F
                    bra       L4500

L44F7               leax      L49C1,pcr
                    pshs      x
                    lbsr      L024E
L4500               leas      $02,s
L4502               lbsr      L552E
                    leax      $04,s
                    lbra      L4566

L450A               ldd       #$0002
                    std       $000B
                    bra       L4519

L4511               ldd       #$0002
                    std       $000B
                    lbsr      L552E
L4519               ldd       $0C,s
                    cmpd      #$0004
                    bne       L4536
                    clra
                    clrb
                    pshs      d
                    ldd       $0a,u
L4527               pshs      d
                    pshs      u
                    ldd       $12,s
                    pshs      d
                    bsr       L4573
                    leas      $08,s
                    bra       L4568

L4536               ldd       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    bne       L4549
                    clra
                    clrb
                    pshs      d
                    ldd       $04,u
                    bra       L4527

L4549               ldd       #$0001
                    pshs      d
                    ldd       $04,u
                    pshs      d
                    pshs      u
                    ldd       $12,s
                    pshs      d
                    bsr       L4573
                    leas      $08,s
                    std       -$02,s
                    bne       L4568
                    lbsr      L4997
                    bra       L4568

L4566               leas      -$04,x
L4568               lbsr      $6824
                    clra
                    clrb
                    std       $000B
L456F               leas      $04,s
                    puls      pc,u
L4573               pshs      u
                    ldd       #$FFA8
                    lbsr      L0113
                    ldu       $06,s
                    leas      -$0C,s
                    ldd       $16,s
                    bne       L4590
                    ldd       #$0029
                    pshs      d
                    lbsr      L04BF
                    leas      $02,s
                    bra       L45A6

L4590               ldd       $005F
                    cmpd      #$0029
                    bne       L45A2
                    ldd       #$0001
                    std       $0a,s
                    lbsr      L552E
                    bra       L45A6

L45A2               clra
                    clrb
                    std       $0a,s
L45A6               ldd       $10,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    lbne      L4694
                    ldd       [$14,s]
                    std       $02,s
                    bne       L45C0
                    ldd       #$FFFF
                    std       $02,s
L45C0               ldd       $10,s
                    pshs      d
                    lbsr      L047A
                    leas      $02,s
                    std       $08,s
                    cmpd      #$0004
                    bne       L45D6
                    ldd       $0a,u
                    bra       L45DB

L45D6               ldx       $14,s
                    ldd       $02,x
L45DB               std       $04,s
                    clra
                    clrb
                    std       $06,s
                    bra       L4619

L45E3               ldd       $16,s
                    addd      #$0001
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    ldd       $0e,s
                    pshs      d
                    lbsr      L4573
                    leas      $08,s
                    std       -$02,s
                    lbeq      L474B
                    ldd       $06,s
                    addd      #$0001
                    std       $06,s
                    cmpd      $02,s
                    bcc       L4621
                    ldd       $005F
                    cmpd      #$0030
                    bne       L4621
                    lbsr      L552E
                    bra       L4619

L4619               ldd       $005F
                    cmpd      #$002A
                    bne       L45E3
L4621               ldd       $02,s
                    cmpd      #$FFFF
                    bne       L4630
                    ldd       $06,s
                    std       [$14,s]
                    bra       L465F

L4630               ldd       $06,s
                    cmpd      $02,s
                    bcc       L465F
                    ldx       $14,s
                    ldd       $02,x
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    ldd       $0C,s
                    pshs      d
                    lbsr      L418D
                    leas      $06,s
                    pshs      d
                    ldd       $04,s
                    subd      $08,s
                    lbsr      L7542
                    pshs      d
                    lbsr      L4751
                    leas      $02,s
                    bra       L465F

L465D               leas      -$0C,x
L465F               ldd       $16,s
                    beq       L466A
                    ldd       $0a,s
                    lbeq      L4738
L466A               ldd       $005F
                    cmpd      #$0030
                    bne       L4675
                    lbsr      L552E
L4675               ldd       $005F
                    cmpd      #$002A
                    bne       L4683
                    lbsr      L552E
                    lbra      L4738

L4683               leax      L49CA,pcr
                    pshs      x
                    lbsr      L024E
                    leas      $02,s
                    lbsr      L4997
                    lbra      L4738

L4694               ldd       $10,s
                    cmpd      #$0004
                    lbne      L471F
                    ldd       $14,s
                    std       ,s
                    bne       L46ED
                    leax      $49DC,pcr
                    lbra      L4741

L46AD               ldx       ,s
                    ldu       $02,x
                    ldd       $16,s
                    addd      #$0001
                    pshs      d
                    ldd       ,u
                    cmpd      #$0004
                    bne       L46C5
                    ldd       $0a,u
                    bra       L46C7

L46C5               ldd       $04,u
L46C7               pshs      d
                    pshs      u
                    ldd       ,u
                    pshs      d
                    lbsr      L4573
                    leas      $08,s
                    std       -$02,s
                    lbeq      L474B
                    ldd       [,s]
                    std       ,s
                    beq       L4716
                    ldd       $005F
                    cmpd      #$0030
                    bne       L4716
                    lbsr      L552E
                    bra       L46ED

L46ED               ldd       $005F
                    cmpd      #$002A
                    bne       L46AD
                    bra       L4716

L46F7               ldx       ,s
                    ldu       $02,x
                    ldd       $04,u
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    ldd       ,u
                    pshs      d
                    lbsr      L418D
                    leas      $06,s
                    pshs      d
                    bsr       L4751
                    leas      $02,s
                    ldd       [,s]
                    std       ,s
L4716               ldd       ,s
                    bne       L46F7
                    leax      $0C,s
                    lbra      L465D

L471F               ldd       $10,s
                    pshs      d
                    bsr       L4775
                    std       ,s++
                    beq       L473D
                    ldd       $0a,s
                    beq       L4738
                    ldd       #$002A
                    pshs      d
                    lbsr      L04BF
                    leas      $02,s
L4738               ldd       #$0001
                    bra       L474D

L473D               leax      L49EF,pcr
L4741               pshs      x
                    lbsr      L024E
                    leas      $02,s
                    lbsr      L4997
L474B               clra
                    clrb
L474D               leas      $0C,s
                    puls      pc,u
L4751               pshs      u
                    ldd       #$FFBA
                    lbsr      L0113
                    lbsr      L4BEF
                    leax      L4A0C,pcr
                    pshs      x
                    lbsr      L4A47
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L4AB4
                    leas      $02,s
                    lbsr      L4A77
                    puls      pc,u
L4775               pshs      u
                    ldd       #$FFB0
                    lbsr      L0113
                    leas      -$08,s
                    ldd       #$0002
                    pshs      d
                    lbsr      L0583
                    std       ,s
                    lbsr      L0F1B
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    bne       L4799
                    clra
                    clrb
                    lbra      L4912

L4799               clra
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
                    bne       L47D8
                    ldx       ,s
                    bra       L47C7

L47B5               ldd       #$0001
                    bra       L4801

L47BA               ldd       ,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    beq       L480A
                    bra       L47EE

L47C7               cmpx      #$0008
                    beq       L47B5
                    cmpx      #$0001
                    beq       L480A
                    cmpx      #$0007
                    beq       L480A
                    bra       L47BA

L47D8               ldd       ,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L47F2
                    ldd       $0C,s
                    pshs      d
                    lbsr      L2630
                    std       ,s++
                    bne       L480A
L47EE               leax      $08,s
                    bra       L482A

L47F2               ldd       $0C,s
                    cmpd      #$0005
                    bne       L47FF
                    ldd       #$0006
                    bra       L4801

L47FF               ldd       $0C,s
L4801               pshs      d
                    pshs      u
                    lbsr      L202A
                    leas      $04,s
L480A               ldd       $06,u
                    cmpd      #$0050
                    beq       L481A
                    ldd       $06,u
                    cmpd      #$0051
                    bne       L4863
L481A               ldd       $0C,u
                    std       $06,s
                    tfr       d,x
                    ldd       $06,x
                    cmpd      #$0036
                    beq       L4835
                    bra       L482C

L482A               leas      -$08,x
L482C               clra
                    clrb
                    std       $02,s
                    leax      $08,s
                    lbra      L4907

L4835               ldd       $06,u
                    cmpd      #$0051
                    bne       L4847
                    ldx       $06,s
                    ldd       $08,x
                    nega
                    negb
                    sbca      #$00
                    bra       L484B

L4847               ldx       $06,s
                    ldd       $08,x
L484B               std       $04,s
                    ldd       $06,s
                    pshs      d
                    lbsr      L0396
                    leas      $02,s
                    stu       $06,s
                    ldu       $0a,u
                    ldd       $06,s
                    pshs      d
                    lbsr      L03B7
                    leas      $02,s
L4863               ldd       $06,u
                    cmpd      #$0041
                    bne       L48BA
                    ldd       $0a,u
                    std       $06,s
                    tfr       d,x
                    ldx       $08,x
                    ldx       $08,x
                    bra       L4897

L4877               clra
                    clrb
                    std       $02,s
                    lbra      L4909

L487E               ldd       #$0001
                    std       $000D
                    ldd       $04,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L50A1
                    leas      $04,s
                    clra
                    clrb
                    std       $000D
                    lbra      L4909

L4897               cmpx      #$000F
                    beq       L487E
                    cmpx      #$000E
                    lbeq      L487E
                    cmpx      #$000C
                    lbeq      L487E
                    cmpx      #$0021
                    lbeq      L487E
                    cmpx      #$0022
                    lbeq      L487E
                    bra       L4877

L48BA               ldx       $06,u
                    bra       L48EE

L48BE               ldd       $0C,s
                    cmpd      #$0005
                    bne       L48D2
                    ldx       $08,u
                    pshs      x
                    ldx       $08,u
                    lbsr      L695C
                    lbsr      $6A02
L48D2               ldd       $0C,s
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    bsr       L4916
                    leas      $04,s
                    bra       L4909

L48E0               lbsr      $67F2
                    ldd       $08,u
                    pshs      d
                    lbsr      L4AEB
                    leas      $02,s
                    bra       L4909

L48EE               cmpx      #$004B
                    beq       L48BE
                    cmpx      #$0036
                    beq       L48D2
                    cmpx      #$004A
                    lbeq      L48D2
                    cmpx      #$0037
                    beq       L48E0
                    lbra      L4877

L4907               leas      -$08,x
L4909               pshs      u
                    lbsr      L0396
                    leas      $02,s
                    ldd       $02,s
L4912               leas      $08,s
                    puls      pc,u
L4916               pshs      u
                    ldd       #$FFB6
                    lbsr      L0113
                    ldu       $04,s
                    leas      -$02,s
                    ldx       $08,s
                    bra       L494C

L4926               lbsr      $67E7
                    pshs      u
                    lbsr      L4AB4
                    leas      $02,s
                    lbsr      L4A77
                    bra       L497C

L4935               ldd       #$0001
                    bra       L493D

L493A               ldd       #$0002
L493D               std       ,s
                    bra       L4971

L4941               ldd       $08,s
                    pshs      d
                    pshs      u
                    lbsr      L5069
                    bra       L497A

L494C               cmpx      #$0002
                    beq       L4926
                    cmpx      #$0001
                    beq       L4935
                    cmpx      #$0007
                    lbeq      L4935
                    cmpx      #$0008
                    beq       L493A
                    cmpx      #$0005
                    beq       L4941
                    cmpx      #$0006
                    lbeq      L4941
                    lbra      L4935

L4971               ldd       ,s
                    pshs      d
                    pshs      u
                    lbsr      L4FE1
L497A               leas      $04,s
L497C               leas      $02,s
                    puls      pc,u
L4980               pshs      u
                    ldd       #$FFBA
                    lbsr      L0113
                    leax      $4A11,pcr
                    pshs      x
                    lbsr      L024E
                    leas      $02,s
                    bsr       L4997
                    puls      pc,u
L4997               pshs      u
                    ldd       #$FFBC
                    lbsr      L0113
L499F               ldx       $005F
                    bra       L49AA

L49A3               puls      pc,u
L49A5               lbsr      L552E
                    bra       L499F

L49AA               cmpx      #$0030
                    beq       L49A3
                    cmpx      #$0028
                    lbeq      L49A3
                    cmpx      #$FFFF
                    lbeq      L49A3
                    bra       L49A5
                    puls      pc,u
L49C1               lsr       $6F6F
                    bra       L4A32
                    clr       $0e,s
                    asr       0,x
L49CA               lsr       $6F6F
                    bra       $4A3C
                    fcb       $61
                    jmp       -$07,s
                    bra       L4A39
                    inc       $05,s
                    tst       $05,s
                    jmp       -$0C,s
                    com       >$0075
                    jmp       $09,s
                    clr       $0e,s
                    com       $206E
                    clr       -$0C,s
                    bra       L4A49
                    inc       $0C,s
                    clr       -$09,s
                    fcb       $65
                    lsr       0,x
L49EF               com       $0f,s
                    jmp       -$0d,s
                    lsr       $616E
                    lsr       L2065
                    asl       L7072
                    fcb       $65
                    com       $7369
                    clr       $0e,s
                    bra       $4A76
                    fcb       $65
                    fcb       $71
                    fcb       $75
                    rol       -$0e,s
                    fcb       $65
                    lsr       0,x
L4A0C               fcb       $72
                    dec       L6220
                    neg       $0063
                    fcb       $61
                    jmp       $0e,s
                    clr       -$0C,s
                    bra       $4A82
                    jmp       $09,s
                    lsr       $6961
                    inc       $09,s
                    dec       $6500
L4A23               pshs      u
                    ldd       #$FFBA
                    lbsr      L0113
                    lbsr      L4BEF
                    ldd       $04,s
                    pshs      d
L4A32               lbsr      L4B20
                    leas      $02,s
                    ldd       $06,s
L4A39               lbeq      L4AFF
                    ldd       #$003A
                    pshs      d
                    bsr       L4A88
                    lbra      L4AFD

L4A47               pshs      u
L4A49               ldd       #$FFB8
                    lbsr      L0113
                    ldd       $0025
                    pshs      d
                    ldd       #$0020
                    pshs      d
                    lbsr      $6F04
                    leas      $04,s
                    ldd       $04,s
                    pshs      d
                    bsr       L4A9E
                    lbra      L5065
                    pshs      u
                    ldd       #$FFBA
                    lbsr      L0113
                    ldd       $04,s
                    pshs      d
                    bsr       L4A47
                    lbra      L4AFD

L4A77               pshs      u
                    ldd       #$FFB8
                    lbsr      L0113
                    ldd       $0025
                    pshs      d
                    ldd       #$000D
                    bra       L4A96

L4A88               pshs      u
                    ldd       #$FFB8
                    lbsr      L0113
                    ldd       $0025
                    pshs      d
                    ldd       $06,s
L4A96               pshs      d
                    lbsr      $6F04
                    lbra      L4BC4

L4A9E               pshs      u
                    ldd       #$FFB8
                    lbsr      L0113
                    ldd       $04,s
                    pshs      d
                    ldd       $0025
                    pshs      d
                    lbsr      L50E6
                    lbra      L4BC4

L4AB4               pshs      u
                    ldd       #$FFB6
                    lbsr      L0113
                    ldd       $04,s
                    pshs      d
                    leax      L50C1,pcr
                    lbra      L4C12

L4AC7               pshs      u
                    ldd       #$FFB8
                    lbsr      L0113
                    ldd       #$006C
                    pshs      d
                    bsr       L4A88
                    leas      $02,s
                    ldd       $0025
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      $6FA9
                    leas      $04,s
                    clra
                    clrb
                    std       L004F
                    puls      pc,u
L4AEB               pshs      u
                    ldd       #$FFBA
                    lbsr      L0113
                    clra
                    clrb
                    std       L004F
                    ldd       $04,s
                    pshs      d
                    bsr       L4B04
L4AFD               leas      $02,s
L4AFF               lbsr      L4A77
                    puls      pc,u
L4B04               pshs      u
                    ldd       #$FFBA
                    lbsr      L0113
                    ldd       #$005F
                    pshs      d
                    lbsr      L4A88
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L4AB4
                    lbra      L5065

L4B20               pshs      u
                    ldd       #$FFB6
                    lbsr      L0113
                    ldd       $04,s
                    pshs      d
                    leax      $50C4,pcr
                    lbra      L4C12

L4B33               pshs      u
                    ldd       #$FFB6
                    lbsr      L0113
                    leas      -$02,s
                    ldd       $06,s
                    subd      $002F
                    std       ,s
                    beq       L4B5C
                    ldd       #$004D
                    pshs      d
                    lbsr      L4A88
                    leas      $02,s
                    ldd       $0025
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    lbsr      $6FA9
                    leas      $04,s
L4B5C               ldd       $06,s
                    lbra      L5065

L4B61               pshs      u
                    ldd       #$FFB8
                    lbsr      L0113
                    ldu       $0025
                    ldx       $04,s
                    lbra      L4BC8

L4B70               ldd       #$004A
                    pshs      d
                    lbsr      L4A88
                    leas      $02,s
                    pshs      u
                    ldd       $0a,s
                    bra       L4BA3

L4B80               ldd       #$0072
                    lbra      L4BFA

L4B86               ldd       #$0047
                    bra       L4BB4

L4B8B               ldd       #$006A
                    bra       L4BB4

L4B90               ldd       #$0044
                    pshs      d
                    lbsr      L4A88
                    leas      $02,s
                    pshs      u
                    ldd       L002B
                    addd      #$0001
                    std       L002B
L4BA3               pshs      d
                    lbsr      $6FA9
                    leas      $04,s
                    bra       L4BBB

L4BAC               ldd       #$0059
                    bra       L4BB4

L4BB1               ldd       #$0055
L4BB4               pshs      d
                    lbsr      L4A88
                    leas      $02,s
L4BBB               pshs      u
                    ldd       $08,s
                    pshs      d
                    lbsr      $6FA9
L4BC4               leas      $04,s
                    puls      pc,u
L4BC8               cmpx      #$007D
                    lbeq      L4B70
                    cmpx      #$0012
                    beq       L4B80
                    cmpx      #$001D
                    beq       L4B86
                    cmpx      #$007C
                    beq       L4B8B
                    cmpx      #$0009
                    beq       L4B90
                    cmpx      #$0076
                    beq       L4BAC
                    cmpx      #$006F
                    beq       L4BB1
                    puls      pc,u
L4BEF               pshs      u
                    ldd       #$FFBA
                    lbsr      L0113
                    ldd       #$002A
L4BFA               pshs      d
                    lbsr      L4A88
                    lbra      L5065
                    pshs      u
                    ldd       #$FFB6
                    lbsr      L0113
                    ldd       $04,s
                    pshs      d
                    leax      $50C9,pcr
L4C12               pshs      x
                    ldd       $0025
                    pshs      d
                    lbsr      L50E6
                    lbra      L4E18

L4C1E               pshs      u
                    ldd       #$FFB8
                    lbsr      L0113
                    ldd       $04,s
                    pshs      d
                    ldd       #$0001
                    bra       L4C61

L4C2F               pshs      u
                    ldd       #$FFB2
                    lbsr      L0113
                    ldd       $0a,s
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    ldd       #$0002
                    pshs      d
                    bsr       L4C6B
                    leas      $0a,s
                    bra       L4C67

L4C52               pshs      u
                    ldd       #$FFB8
                    lbsr      L0113
                    ldd       $04,s
                    pshs      d
                    ldd       #$0004
L4C61               pshs      d
                    bsr       L4C6B
                    leas      $04,s
L4C67               ldd       $04,s
                    puls      pc,u
L4C6B               pshs      u
                    ldd       #$FFB6
                    lbsr      L0113
                    ldu       $0025
                    pshs      u
                    ldd       #$0054
                    pshs      d
                    lbsr      $6F04
                    leas      $04,s
                    pshs      u
                    ldd       $06,s
                    pshs      d
                    lbsr      $6FA9
                    leas      $04,s
                    pshs      u
                    ldd       L002B
                    pshs      d
                    lbsr      $6FA9
                    leas      $04,s
                    pshs      u
                    ldd       $002F
                    pshs      d
                    lbsr      $6FA9
                    leas      $04,s
                    ldx       $04,s
                    bra       L4CDA

L4CA6               pshs      u
                    ldd       $0a,s
                    pshs      d
                    lbsr      $6FA9
                    leas      $04,s
                    pshs      u
                    ldd       $0C,s
                    pshs      d
                    lbsr      $6FA9
                    leas      $04,s
                    pshs      u
                    ldd       $0e,s
                    pshs      d
                    lbsr      $6F04
                    bra       L4CD6

L4CC7               pshs      u
                    ldd       $000D
                    bra       L4CD1

L4CCD               pshs      u
                    ldd       $0a,s
L4CD1               pshs      d
                    lbsr      $6FA9
L4CD6               leas      $04,s
                    bra       L4CE9

L4CDA               cmpx      #$0002
                    beq       L4CA6
                    cmpx      #$0005
                    beq       L4CC7
                    cmpx      #$0012
                    beq       L4CCD
L4CE9               ldd       L002B
                    pshs      d
                    ldd       $06,s
                    cmpd      #$0002
                    bne       L4CFA
                    ldd       #$0001
                    bra       L4CFC

L4CFA               clra
                    clrb
L4CFC               pshs      d
                    ldd       $0a,s
                    pshs      d
                    bsr       L4D0F
                    leas      $04,s
                    addd      ,s++
                    std       L002B
                    ldd       $06,s
                    lbra      L4E3C

L4D0F               pshs      u
                    ldd       #$FFB0
                    lbsr      L0113
                    ldu       $04,s
                    leas      -$06,s
                    stu       -$02,s
                    lbeq      L4E16
                    ldx       $06,u
                    lbra      L4D81

L4D26               ldd       $0C,s
                    beq       L4D2F
                    ldd       #$0001
                    bra       L4D32

L4D2F               ldd       #$0004
L4D32               std       $04,s
                    ldd       #$0001
                    bra       L4D6E

L4D39               ldd       #$0003
                    std       $04,s
                    ldd       #$0001
                    bra       L4D70

L4D43               ldd       $0C,s
                    beq       L4D4B
                    clra
                    clrb
                    bra       L4D4E

L4D4B               ldd       #$0003
L4D4E               std       $04,s
                    clra
                    clrb
                    bra       L4D6E

L4D54               ldd       #$0003
                    std       $04,s
                    ldd       #$0001
                    std       $02,s
                    clra
                    clrb
                    std       ,s
                    lbra      L4DF4

L4D65               ldd       #$0001
                    std       $04,s
                    clra
                    clrb
                    std       $0C,s
L4D6E               std       ,s
L4D70               std       $02,s
                    lbra      L4DF4

L4D75               clra
                    clrb
                    std       $0C,s
                    std       ,s
                    std       $02,s
                    std       $04,s
                    bra       L4DF4

L4D81               cmpx      #$0047
                    lbeq      L4D26
                    cmpx      #$0048
                    lbeq      L4D26
                    cmpx      #$0040
                    lbeq      L4D39
                    cmpx      #$005A
                    lbeq      L4D43
                    cmpx      #$005B
                    lbeq      L4D43
                    cmpx      #$005C
                    lbeq      L4D43
                    cmpx      #$005D
                    lbeq      L4D43
                    cmpx      #$005E
                    lbeq      L4D43
                    cmpx      #$005F
                    lbeq      L4D43
                    cmpx      #$0060
                    lbeq      L4D43
                    cmpx      #$0061
                    lbeq      L4D43
                    cmpx      #$0062
                    lbeq      L4D43
                    cmpx      #$0063
                    lbeq      L4D43
                    cmpx      #$0064
                    lbeq      L4D54
                    cmpx      #$004B
                    lbeq      L4D65
                    cmpx      #$004A
                    lbeq      L4D65
                    lbra      L4D75

L4DF4               ldd       $02,s
                    pshs      d
                    ldd       $0a,u
                    pshs      d
                    lbsr      L4D0F
                    leas      $04,s
                    addd      $04,s
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    ldd       $0C,u
                    pshs      d
                    lbsr      L4D0F
                    leas      $04,s
                    addd      ,s++
                    bra       L4E18

L4E16               clra
                    clrb
L4E18               leas      $06,s
                    puls      pc,u
L4E1C               pshs      u
                    ldd       #$FFBA
                    lbsr      L0113
                    ldu       $04,s
                    stu       -$02,s
                    lbeq      L5067
                    pshs      u
                    bsr       L4E44
                    leas      $02,s
                    ldd       $0a,u
                    pshs      d
                    bsr       L4E1C
                    leas      $02,s
                    ldd       $0C,u
L4E3C               pshs      d
                    lbsr      L4E1C
                    lbra      L5065

L4E44               pshs      u
                    ldd       #$FFAA
                    lbsr      L0113
                    ldu       $04,s
                    leas      -$02,s
                    ldd       $0a,u
                    beq       L4E5D
                    ldd       $0C,u
                    beq       L4E5D
                    ldd       #$0042
                    bra       L4E72

L4E5D               ldd       $0a,u
                    beq       L4E66
                    ldd       #$004C
                    bra       L4E72

L4E66               ldd       $0C,u
                    beq       L4E6F
                    ldd       #$0052
                    bra       L4E72

L4E6F               ldd       #$004E
L4E72               std       ,s
                    ldd       $0025
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    lbsr      $6F04
                    leas      $04,s
                    ldd       $0025
                    pshs      d
                    ldd       ,u
                    pshs      d
                    lbsr      $6FA9
                    leas      $04,s
                    ldd       $0025
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    lbsr      $6FA9
                    leas      $04,s
                    ldd       $0025
                    pshs      d
                    ldd       $06,u
                    pshs      d
                    lbsr      $6FA9
                    leas      $04,s
                    ldd       $0025
                    pshs      d
                    ldd       $0e,u
                    pshs      d
                    lbsr      $6FA9
                    leas      $04,s
                    ldd       $0025
                    pshs      d
                    leax      $060C,y
                    pshs      x
                    ldd       $10,u
                    subd      ,s++
                    pshs      d
                    lbsr      $6F04
                    leas      $04,s
                    ldd       $0025
                    pshs      d
                    ldd       $12,u
                    pshs      d
                    lbsr      $6F04
                    leas      $04,s
                    ldd       $0025
                    pshs      d
                    ldd       $14,u
                    pshs      d
                    lbsr      $6FA9
                    leas      $04,s
                    ldd       $06,u
                    cmpd      #$0034
                    lbne      L4F52
                    ldu       $08,u
                    ldd       $0025
                    pshs      d
                    ldd       ,u
                    pshs      d
                    lbsr      $6F04
                    leas      $04,s
                    ldd       $0025
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      $6F04
                    leas      $04,s
                    ldx       $08,u
                    bra       L4F36

L4F11               pshs      u
                    ldd       #$0014
                    addd      ,s++
                    pshs      d
                    lbsr      L4B20
                    leas      $02,s
                    ldd       $0025
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    lbsr      $6F04
                    lbra      L4FDC

L4F2D               ldd       $0025
                    pshs      d
                    ldd       $06,u
                    lbra      L4FD7

L4F36               cmpx      #$000E
                    beq       L4F11
                    cmpx      #$000C
                    lbeq      L4F11
                    cmpx      #$0021
                    lbeq      L4F11
                    cmpx      #$0022
                    lbeq      L4F11
                    bra       L4F2D

L4F52               ldd       $06,u
                    cmpd      #$004A
                    bne       L4F8E
                    leas      -$04,s
                    leax      ,s
                    pshs      x
                    bsr       L4F66
                    neg       $0000
                    neg       $0000
L4F66               puls      x
                    lbsr      L74D6
                    ldd       $0025
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    ldd       #$0004
                    pshs      d
                    ldu       $08,u
                    beq       L4F81
                    tfr       u,d
                    bra       L4F85

L4F81               leax      $06,s
                    tfr       x,d
L4F85               pshs      d
                    lbsr      L6EBA
                    leas      $08,s
                    bra       L4FDC

L4F8E               ldd       $06,u
                    cmpd      #$004B
                    bne       L4FD1
                    leas      -$08,s
                    leax      ,s
                    pshs      x
                    bsr       L4FA6
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
L4FA6               puls      x
                    lbsr      $6A02
                    ldd       $0025
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    ldd       #$0008
                    pshs      d
                    ldu       $08,u
                    beq       L4FC1
                    tfr       u,d
                    bra       L4FC5

L4FC1               leax      $06,s
                    tfr       x,d
L4FC5               pshs      d
                    lbsr      L6EBA
                    leas      $08,s
                    leas      $08,s
                    lbra      L5065

L4FD1               ldd       $0025
                    pshs      d
                    ldd       $08,u
L4FD7               pshs      d
                    lbsr      $6FA9
L4FDC               leas      $04,s
                    lbra      L5065

L4FE1               pshs      u
                    ldd       #$FFB8
                    lbsr      L0113
                    ldu       $04,s
                    leas      -$02,s
                    lbsr      $67F2
                    ldd       $08,s
                    cmpd      #$0001
                    bne       L5002
                    pshs      u
                    lbsr      L4AB4
L4FFD               leas      $02,s
                    lbra      L5062

L5002               cmpu      #$0000
                    bne       L5033
                    ldd       #$0001
                    std       ,s
                    bra       L501A

L500F               leax      L50CE,pcr
                    pshs      x
                    lbsr      L4A9E
                    leas      $02,s
L501A               ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    cmpd      $08,s
                    blt       L500F
                    ldd       #$0030
                    pshs      d
                    lbsr      L4A88
                    bra       L4FFD

L5033               clra
                    clrb
                    bra       L5059

L5037               ldd       ,u++
                    pshs      d
                    lbsr      L4AB4
                    leas      $02,s
                    ldd       $08,s
                    addd      #$FFFF
                    cmpd      ,s
                    beq       L5054
                    ldd       #$002C
                    pshs      d
                    lbsr      L4A88
                    leas      $02,s
L5054               ldd       ,s
                    addd      #$0001
L5059               std       ,s
                    ldd       ,s
                    cmpd      $08,s
                    blt       L5037
L5062               lbsr      L4A77
L5065               leas      $02,s
L5067               puls      pc,u
L5069               pshs      u
                    ldd       #$FFB4
                    lbsr      L0113
                    ldu       $04,s
                    ldd       #$0066
                    pshs      d
                    lbsr      L4A88
                    leas      $02,s
                    ldd       $0025
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      $6FA9
                    leas      $04,s
                    ldd       $0025
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    ldd       #$0008
                    pshs      d
                    pshs      u
                    lbsr      L6EBA
                    leas      $08,s
                    puls      pc,u
L50A1               pshs      u
                    ldd       #$FFB8
                    lbsr      L0113
                    ldu       $04,s
                    ldd       $14,u
                    addd      $06,s
                    std       $14,u
                    pshs      u
                    ldd       #$0005
                    pshs      d
                    lbsr      L4C6B
                    leas      $04,s
                    puls      pc,u
L50C1               bcs       $5127
                    neg       $0025
                    bgt       L50FF
                    com       >$0046
                    bcs       $513F
                    tst       $0000
L50CE               leax      $0C,y
                    neg       $0034
L50D2               nega
                    leax      $01C1,y
                    stx       $000F
                    ldd       #$0001
                    std       L0015
                    leax      $06,s
                    pshs      x
                    ldd       $06,s
L50E4               bra       L50F7

L50E6               pshs      u
                    ldd       $04,s
                    std       $000F
                    ldd       #$0001
                    std       L0015
                    leax      $08,s
                    pshs      x
                    ldd       $08,s
L50F7               pshs      d
                    bsr       L511E
                    leas      $04,s
                    puls      pc,u
L50FF               pshs      u
                    ldd       $04,s
                    std       $000F
                    ldd       #$0002
                    std       L0015
                    leax      $08,s
                    pshs      x
                    ldd       $08,s
                    pshs      d
                    bsr       L511E
                    leas      $04,s
                    clra
                    clrb
                    stb       [$000F,y]
                    puls      pc,u
L511E               pshs      u
                    ldu       $04,s
                    leas      -$0b,s
                    bra       L5136

L5126               ldb       $08,s
                    lbeq      L5294
                    ldb       $08,s
                    sex
                    pshs      d
                    lbsr      L5473
                    leas      $02,s
L5136               ldb       ,u+
                    stb       $08,s
                    cmpb      #$25
                    bne       L5126
                    ldb       ,u+
                    stb       $08,s
                    clra
                    clrb
                    std       $02,s
                    std       $06,s
                    ldb       $08,s
                    cmpb      #$2d
                    bne       L5159
                    ldd       #$0001
                    std       $0011
                    ldb       ,u+
                    stb       $08,s
                    bra       L515D

L5159               clra
                    clrb
                    std       $0011
L515D               ldb       $08,s
                    cmpb      #$30
                    bne       L5168
                    ldd       #$0030
                    bra       L516B

L5168               ldd       #$0020
L516B               std       $0013
                    bra       L5189

L516F               ldd       $06,s
                    pshs      d
                    ldd       #$000A
                    lbsr      L7542
                    pshs      d
                    ldb       $0a,s
                    sex
                    addd      #$FFD0
                    addd      ,s++
                    std       $06,s
                    ldb       ,u+
                    stb       $08,s
L5189               ldb       $08,s
                    sex
                    leax      $0089,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$6b
                    beq       L516F
                    ldb       $08,s
                    cmpb      #$2e
                    bne       L51D0
                    ldd       #$0001
                    std       $04,s
                    bra       L51BB

L51A5               ldd       $02,s
                    pshs      d
                    ldd       #$000A
                    lbsr      L7542
                    pshs      d
                    ldb       $0a,s
                    sex
                    addd      #$FFD0
                    addd      ,s++
                    std       $02,s
L51BB               ldb       ,u+
                    stb       $08,s
                    ldb       $08,s
                    sex
                    leax      $0089,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$6b
                    beq       L51A5
                    bra       L51D4

L51D0               clra
                    clrb
                    std       $04,s
L51D4               ldb       $08,s
                    sex
                    tfr       d,x
                    lbra      L5276

L51DC               ldd       $06,s
                    pshs      d
                    ldx       $13,s
                    leax      $02,x
                    stx       $13,s
                    ldd       -$02,x
                    pshs      d
                    lbsr      L5298
                    bra       L5204

L51F1               ldd       $06,s
                    pshs      d
                    ldx       $13,s
                    leax      $02,x
                    stx       $13,s
                    ldd       -$02,x
                    pshs      d
                    lbsr      L5359
L5204               std       ,s
                    lbra      L5261

L5209               ldx       $11,s
                    leax      $02,x
                    stx       $11,s
                    ldd       -$02,x
                    lbra      L526C

L5216               ldx       $11,s
                    leax      $02,x
                    stx       $11,s
                    ldd       -$02,x
                    std       $09,s
                    ldd       $04,s
                    beq       L5259
                    ldd       $09,s
                    std       $04,s
                    bra       L5238

L522C               ldb       [$09,s]
                    beq       L5244
                    ldd       $09,s
                    addd      #$0001
                    std       $09,s
L5238               ldd       $02,s
                    addd      #$FFFF
                    std       $02,s
                    subd      #$FFFF
                    bne       L522C
L5244               ldd       $06,s
                    pshs      d
                    ldd       $0b,s
                    subd      $06,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L5418
                    leas      $06,s
                    bra       L5266

L5259               ldd       $06,s
                    pshs      d
                    ldd       $0b,s
                    pshs      d
L5261               lbsr      L53B8
                    leas      $04,s
L5266               lbra      L5136

L5269               ldb       $08,s
                    sex
L526C               pshs      d
                    lbsr      L5473
                    leas      $02,s
                    lbra      L5136

L5276               cmpx      #$0064
                    lbeq      L51DC
                    cmpx      #$0078
                    lbeq      L51F1
                    cmpx      #$0063
                    lbeq      L5209
                    cmpx      #$0073
                    lbeq      L5216
                    bra       L5269

L5294               leas      $0b,s
                    puls      pc,u
L5298               pshs      u,d
                    leax      $02DA,y
                    stx       ,s
                    ldd       $06,s
                    bge       L52CD
                    ldd       $06,s
                    nega
                    negb
                    sbca      #$00
                    std       $06,s
                    bge       L52C2
                    leax      L5498,pcr
                    pshs      x
                    leax      $02DA,y
                    pshs      x
                    lbsr      $7314
                    leas      $04,s
                    lbra      L546F

L52C2               ldd       #$002D
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
L52CD               ldd       $06,s
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    bsr       L52E2
                    leas      $04,s
                    leax      $02DA,y
                    tfr       x,d
                    lbra      L546F

L52E2               pshs      u,y,x,d
                    ldu       $0a,s
                    clra
                    clrb
                    std       $02,s
                    clra
                    clrb
                    std       ,s
                    bra       L52FF

L52F0               ldd       ,s
                    addd      #$0001
                    std       ,s
                    ldd       $0C,s
                    subd      $0081,y
                    std       $0C,s
L52FF               ldd       $0C,s
                    blt       L52F0
                    leax      $0081,y
                    stx       $04,s
                    bra       L5341

L530B               ldd       ,s
                    addd      #$0001
                    std       ,s
L5312               ldd       $0C,s
                    subd      [$04,s]
                    std       $0C,s
                    bge       L530B
                    ldd       $0C,s
                    addd      [$04,s]
                    std       $0C,s
                    ldd       ,s
                    beq       L532B
                    ldd       #$0001
                    std       $02,s
L532B               ldd       $02,s
                    beq       L5336
                    ldd       ,s
                    addd      #$0030
                    stb       ,u+
L5336               clra
                    clrb
                    std       ,s
                    ldd       $04,s
                    addd      #$0002
                    std       $04,s
L5341               ldd       $04,s
                    cmpd      $0001
                    bne       L5312
                    ldd       $0C,s
                    addd      #$0030
                    stb       ,u+
                    clra
                    clrb
                    stb       ,u
                    ldd       $0a,s
                    leas      $06,s
                    puls      pc,u
L5359               pshs      u,x,d
                    leax      $02DA,y
                    stx       $02,s
                    leau      $02E4,y
L5365               ldd       $08,s
                    clra
                    andb      #$0f
                    std       ,s
                    pshs      d
                    ldd       $02,s
                    cmpd      #$0009
                    ble       L537B
                    ldd       #$0057
                    bra       L537E

L537B               ldd       #$0030
L537E               addd      ,s++
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
                    bne       L5365
                    bra       L539E

L5394               ldb       ,u
                    ldx       $02,s
                    leax      $01,x
                    stx       $02,s
                    stb       -$01,x
L539E               leau      -$01,u
                    pshs      u
                    leax      $02E4,y
                    cmpx      ,s++
                    bls       L5394
                    clra
                    clrb
                    stb       [$02,s]
                    leax      $02DA,y
                    tfr       x,d
                    lbra      L5494

L53B8               pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    pshs      d
                    lbsr      $7303
                    leas      $02,s
                    nega
                    negb
                    sbca      #$00
                    leau      d,u
                    ldd       $0011
                    bne       L53EF
                    bra       L53DC

L53D3               ldd       $0013
                    pshs      d
                    lbsr      L5473
                    leas      $02,s
L53DC               tfr       u,d
                    leau      -$01,u
                    std       -$02,s
                    bgt       L53D3
                    bra       L53EF

L53E6               ldd       ,s
                    pshs      d
                    lbsr      L5473
                    leas      $02,s
L53EF               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    sex
                    std       ,s
                    bne       L53E6
                    ldd       $0011
                    lbeq      L546F
                    bra       L540D

L5404               ldd       $0013
                    pshs      d
                    lbsr      L5473
                    leas      $02,s
L540D               tfr       u,d
                    leau      -$01,u
                    std       -$02,s
                    bgt       L5404
                    lbra      L546F

L5418               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    ldd       $0a,s
                    subd      $08,s
                    std       ,s
                    ldd       $0011
                    bne       L5449
                    bra       L5432

L542A               ldd       $0013
                    pshs      d
                    bsr       L5473
                    leas      $02,s
L5432               ldd       ,s
                    addd      #$FFFF
                    std       ,s
                    subd      #$FFFF
                    bgt       L542A
                    bra       L5449

L5440               ldb       ,u+
                    sex
                    pshs      d
                    bsr       L5473
                    leas      $02,s
L5449               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bne       L5440
                    ldd       $0011
                    beq       L546F
                    bra       L5463

L545B               ldd       $0013
                    pshs      d
                    bsr       L5473
                    leas      $02,s
L5463               ldd       ,s
                    addd      #$FFFF
                    std       ,s
                    subd      #$FFFF
                    bgt       L545B
L546F               leas      $02,s
                    puls      pc,u
L5473               pshs      u
                    ldd       L0015
                    cmpd      #$0002
                    bne       L5489
                    ldd       $04,s
                    ldx       $000F
                    leax      $01,x
                    stx       $000F
                    stb       -$01,x
                    bra       L5496

L5489               ldd       $000F
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      $6F04
L5494               leas      $04,s
L5496               puls      pc,u
L5498               blt       $54CD
                    leas      -$09,y
                    pshu      y,x,dp
                    neg       $00AE
                    fcb       $62
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
                    bcs       L5528
                    asl       $06,x
                    rol       $05,x
                    rol       $04,x
                    rol       $03,x
                    rol       $02,x
                    rol       $01,x
                    rol       ,x
                    bcs       L5528
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
                    bcs       L5528
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
                    bcs       L5528
                    leas      $08,s
                    clra
                    clrb
                    rts

L5528               ldd       #$0001
                    leas      $08,s
                    rts

L552E               pshs      u
                    leas      -$15,s
                    lbsr      $6348
                    ldb       $0065
                    sex
                    cmpd      #$FFFF
                    bne       L5549
                    ldd       #$FFFF
                    std       $005F
                    leas      $15,s
                    puls      pc,u
L5549               ldd       $006A
                    addd      #$FFFF
                    std       $0063
                    ldd       L0027
                    std       L003F
                    bra       L5568

L5556               leax      $61EC,pcr
                    pshs      x
                    lbsr      L024E
                    leas      $02,s
                    lbsr      $635E
                    ldd       $006A
                    std       $0063
L5568               ldb       $0065
                    sex
                    leax      $0089,y
                    leax      d,x
                    ldb       ,x
                    sex
                    std       $005F
                    beq       L5556
                    ldb       $0065
                    sex
                    leax      $0109,y
                    leax      d,x
                    ldb       ,x
                    sex
                    std       $0061
                    ldx       $005F
                    lbra      L5876

L558B               leax      $0a,s
                    pshs      x
                    lbsr      L5ABF
                    leas      $02,s
                    leax      $0a,s
                    pshs      x
                    lbsr      L5B36
                    leas      $02,s
                    tfr       d,u
                    ldd       ,u
                    std       $005F
                    cmpd      #$0033
                    bne       L55C2
                    ldd       $08,u
                    std       $0061
                    cmpd      #$003B
                    lbne      L5895
                    ldd       #$003B
                    std       $005F
                    ldd       #$000E
                    std       $0061
                    lbra      L5895

L55C2               ldd       #$0034
                    std       $005F
                    stu       $0061
                    lbra      L5895

L55CC               leax      ,s
                    pshs      x
                    ldd       #$0001
                    pshs      d
                    lbsr      L5C5C
                    leas      $04,s
                    std       $13,s
                    bra       L55E2

L55DF               leas      -$15,x
L55E2               leax      ,s
                    stx       $08,s
                    ldx       $13,s
                    bra       L5640

L55EB               ldd       [$08,s]
                    bra       L5636

L55F0               ldd       #$0004
                    pshs      d
                    lbsr      L5C2A
                    leas      $02,s
                    tfr       d,u
                    leax      ,u
                    pshs      x
                    ldx       $0a,s
                    lbsr      L74D6
                    stu       $0061
                    ldd       #$004A
                    bra       L563B

L560C               ldd       #$0008
                    pshs      d
                    lbsr      L5C2A
                    leas      $02,s
                    tfr       d,u
                    leax      ,u
                    pshs      x
                    ldx       $0a,s
                    lbsr      $6A02
                    stu       $0061
                    ldd       #$004B
                    bra       L563B

L5628               leax      L61FA,pcr
                    pshs      x
                    lbsr      L024E
                    leas      $02,s
                    ldd       #$0001
L5636               std       $0061
                    ldd       #$0036
L563B               std       $005F
                    lbra      L5895

L5640               cmpx      #$0001
                    beq       L55EB
                    cmpx      #$0008
                    beq       L55F0
                    cmpx      #$0006
                    beq       L560C
                    bra       L5628

L5651               lbsr      L5F03
                    ldd       #$0036
                    bra       L565F

L5659               lbsr      L5F33
                    ldd       #$0037
L565F               std       $005F
                    lbra      L5895

L5664               lbsr      $635E
                    ldx       $005F
                    lbra      L5819

L566C               ldb       $0065
                    sex
                    leax      $0089,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$6b
                    lbne      L5895
                    leax      ,s
                    pshs      x
                    ldd       #$0006
                    pshs      d
                    lbsr      L5C5C
                    leas      $04,s
                    std       $13,s
                    leax      $15,s
                    lbra      L55DF

L5694               ldb       $0065
                    sex
                    tfr       d,x
                    bra       L56B3

L569B               ldd       #$0047
                    std       $005F
                    lbsr      $635E
                    ldd       #$0005
                    bra       L56F2

L56A8               ldd       #$00A7
                    std       $005F
                    ldd       #$0002
                    lbra      L57FF

L56B3               cmpx      #$0026
                    beq       L569B
                    cmpx      #$003D
                    beq       L56A8
                    lbra      L5895

L56C0               ldb       $0065
                    cmpb      #$3d
                    lbne      L5895
                    ldd       #$005A
                    std       $005F
                    ldd       #$0009
                    lbra      L57FF

L56D3               ldb       $0065
                    sex
                    tfr       d,x
                    bra       L56F7

L56DA               ldd       #$0048
                    std       $005F
                    lbsr      $635E
                    ldd       #$0004
                    bra       L56F2

L56E7               ldd       #$00A8
L56EA               std       $005F
                    lbsr      $635E
                    ldd       #$0002
L56F2               std       $0061
                    lbra      L5895

L56F7               cmpx      #$007C
                    beq       L56DA
                    cmpx      #$003D
                    beq       L56E7
                    lbra      L5895

L5704               ldb       $0065
                    cmpb      #$3d
                    lbne      L5895
                    ldd       #$005B
                    std       $005F
                    lbsr      $635E
                    ldd       #$0009
                    bra       L56F2

L5719               ldb       $0065
                    cmpb      #$3d
                    lbne      L5895
                    ldd       #$00A2
                    bra       L56EA

L5726               ldb       $0065
                    cmpb      #$3d
                    lbne      L5895
                    ldd       $005F
                    addd      #$0050
                    lbra      L56EA

L5736               ldb       $0065
                    sex
                    tfr       d,x
                    bra       L5768

L573D               ldd       #$0056
                    std       $005F
                    ldd       #$000B
                    std       $0061
                    lbsr      $635E
                    ldb       $0065
                    cmpb      #$3d
                    lbne      L5895
                    ldd       #$00A6
                    std       $005F
                    ldd       #$0002
                    lbra      L57FF

L575D               ldd       #$005C
                    std       $005F
                    ldd       #$000A
                    lbra      L57FF

L5768               cmpx      #$003C
                    beq       L573D
                    cmpx      #$003D
                    beq       L575D
                    lbra      L5895

L5775               ldb       $0065
                    sex
                    tfr       d,x
                    bra       L57A7

L577C               ldd       #$0055
                    std       $005F
                    ldd       #$000B
                    std       $0061
                    lbsr      $635E
                    ldb       $0065
                    cmpb      #$3d
                    lbne      L5895
                    ldd       #$00A5
                    std       $005F
                    ldd       #$0002
                    lbra      L57FF

L579C               ldd       #$005E
                    std       $005F
                    ldd       #$000A
                    lbra      L57FF

L57A7               cmpx      #$003E
                    beq       L577C
                    cmpx      #$003D
                    beq       L579C
                    lbra      L5895

L57B4               ldb       $0065
                    sex
                    tfr       d,x
                    bra       L57CF

L57BB               ldd       #$003C
                    std       $005F
                    ldd       #$000E
                    bra       L57FF

L57C5               ldd       #$00A0
                    std       $005F
                    ldd       #$0002
                    bra       L57FF

L57CF               cmpx      #$002B
                    beq       L57BB
                    cmpx      #$003D
                    beq       L57C5
                    lbra      L5895

L57DC               ldb       $0065
                    sex
                    tfr       d,x
                    bra       L5807

L57E3               ldd       #$003D
                    std       $005F
                    ldd       #$000E
                    bra       L57FF

L57ED               ldd       #$00A1
                    std       $005F
                    ldd       #$0002
                    bra       L57FF

L57F7               ldd       #$0046
                    std       $005F
                    ldd       #$000F
L57FF               std       $0061
                    lbsr      $635E
                    lbra      L5895

L5807               cmpx      #$002D
                    beq       L57E3
                    cmpx      #$003D
                    beq       L57ED
                    cmpx      #$003E
                    beq       L57F7
                    lbra      L5895

L5819               cmpx      #$0045
                    lbeq      L566C
                    cmpx      #$0041
                    lbeq      L5694
                    cmpx      #$0078
                    lbeq      L56C0
                    cmpx      #$0058
                    lbeq      L56D3
                    cmpx      #$0040
                    lbeq      L5704
                    cmpx      #$0042
                    lbeq      L5719
                    cmpx      #$0053
                    lbeq      L5726
                    cmpx      #$0054
                    lbeq      L5726
                    cmpx      #$0059
                    lbeq      L5726
                    cmpx      #$005D
                    lbeq      L5736
                    cmpx      #$005F
                    lbeq      L5775
                    cmpx      #$0050
                    lbeq      L57B4
                    cmpx      #$0043
                    lbeq      L57DC
                    bra       L5895

L5876               cmpx      #$006A
                    lbeq      L558B
                    cmpx      #$006B
                    lbeq      L55CC
                    cmpx      #$0068
                    lbeq      L5651
                    cmpx      #$0069
                    lbeq      L5659
                    lbra      L5664

L5895               leas      $15,s
                    puls      pc,u
                    pshs      u
                    ldd       #$0006
                    pshs      d
                    leax      L620C,pcr
                    pshs      x
                    lbsr      L5BD8
                    leas      $04,s
                    ldd       #$0005
                    pshs      d
                    leax      L6213,pcr
                    pshs      x
                    lbsr      L5BD8
                    leas      $04,s
                    ldd       #start
                    pshs      d
                    leax      $6219,pcr
                    pshs      x
                    lbsr      L5BD8
                    leas      $04,s
                    ldd       #$000F
                    pshs      d
                    leax      $6221,pcr
                    pshs      x
                    lbsr      L5BD8
                    leas      $04,s
                    ldd       #$003B
                    pshs      d
                    leax      L6228,pcr
                    pshs      x
                    lbsr      L5BD8
                    leas      $04,s
                    ldd       #$0001
                    pshs      d
                    leax      L622F,pcr
                    pshs      x
                    lbsr      L5BD8
                    leas      $04,s
                    ldd       #$0001
                    std       $0041
                    ldd       #$0001
                    pshs      d
                    leax      L6233,pcr
                    pshs      x
                    lbsr      L5BD8
                    leas      $04,s
                    ldd       #$0005
                    pshs      d
                    leax      L6237,pcr
                    pshs      x
                    lbsr      L5BD8
                    leas      $04,s
                    clra
                    clrb
                    std       $0041
                    ldd       #$0002
                    pshs      d
                    leax      $623D,pcr
                    pshs      x
                    lbsr      L5BD8
                    leas      $04,s
                    ldd       #$000A
                    pshs      d
                    leax      L6242,pcr
                    pshs      x
                    lbsr      L5BD8
                    leas      $04,s
                    ldd       #$000D
                    pshs      d
                    leax      $6248,pcr
                    pshs      x
                    lbsr      L5BD8
                    leas      $04,s
                    ldd       #$000E
                    pshs      d
                    leax      $624D,pcr
                    pshs      x
                    lbsr      L5BD8
                    leas      $04,s
                    ldd       #$0021
                    pshs      d
                    leax      $6254,pcr
                    pshs      x
                    lbsr      L5BD8
                    leas      $04,s
                    ldd       #$0010
                    pshs      d
                    leax      L625B,pcr
                    pshs      x
                    lbsr      L5BD8
                    leas      $04,s
                    ldd       #$001D
                    pshs      d
                    leax      L6264,pcr
                    pshs      x
                    lbsr      L5BD8
                    leas      $04,s
                    ldd       #$0012
                    pshs      d
                    leax      $6269,pcr
                    pshs      x
                    lbsr      L5BD8
                    leas      $04,s
                    ldd       #$0013
                    pshs      d
                    leax      $6270,pcr
                    pshs      x
                    lbsr      L5BD8
                    leas      $04,s
                    ldd       #$0014
                    pshs      d
                    leax      L6273,pcr
                    pshs      x
                    lbsr      L5BD8
                    leas      $04,s
                    ldd       #$0015
                    pshs      d
                    leax      L6279,pcr
                    pshs      x
                    lbsr      L5BD8
                    leas      $04,s
                    ldd       #$0016
                    pshs      d
                    leax      L627E,pcr
                    pshs      x
                    lbsr      L5BD8
                    leas      $04,s
                    ldd       #$0017
                    pshs      d
                    leax      L6285,pcr
                    pshs      x
                    lbsr      L5BD8
                    leas      $04,s
                    ldd       #$0018
                    pshs      d
                    leax      $628A,pcr
                    pshs      x
                    lbsr      L5BD8
                    leas      $04,s
                    ldd       #$0019
                    pshs      d
                    leax      L6290,pcr
                    pshs      x
                    lbsr      L5BD8
                    leas      $04,s
                    ldd       #$001A
                    pshs      d
                    leax      L6299,pcr
                    pshs      x
                    lbsr      L5BD8
                    leas      $04,s
                    ldd       #$001B
                    pshs      d
                    leax      $629C,pcr
                    pshs      x
                    lbsr      L5BD8
                    leas      $04,s
                    ldd       #$001C
                    pshs      d
                    leax      L62A4,pcr
                    pshs      x
                    lbsr      L5BD8
                    leas      $04,s
                    ldd       #$0004
                    pshs      d
                    leax      L62A8,pcr
                    pshs      x
                    lbsr      L5BD8
                    leas      $04,s
                    ldd       #$0003
                    pshs      d
                    leax      L62AF,pcr
                    pshs      x
                    lbsr      L5BD8
                    leas      $04,s
                    ldd       #$0007
                    pshs      d
                    leax      L62B5,pcr
                    pshs      x
                    lbsr      L5BD8
                    leas      $04,s
                    ldd       #$0008
                    pshs      d
                    leax      $62BE,pcr
                    pshs      x
                    lbsr      L5BD8
                    leas      $04,s
                    leax      L62C3,pcr
                    pshs      x
                    lbsr      L5B36
                    leas      $02,s
                    tfr       d,u
                    ldd       #$0001
                    std       ,u
                    ldd       #$000E
                    std       $08,u
                    ldd       #$0002
                    std       $02,u
                    leax      L62C9,pcr
                    pshs      x
                    lbsr      L5B36
                    leas      $02,s
                    tfr       d,u
                    ldd       #$0038
                    std       ,u
                    ldd       #$000C
                    std       $08,u
                    ldd       #$0004
                    std       $02,u
                    puls      pc,u
L5ABF               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    ldd       #$0001
                    bra       L5AD6

L5ACA               ldb       $0065
                    stb       ,u+
                    lbsr      $635E
                    ldd       ,s
                    addd      #$0001
L5AD6               std       ,s
                    ldb       $0065
                    sex
                    pshs      d
                    bsr       L5B0F
                    std       ,s++
                    beq       L5AEB
                    ldd       ,s
                    cmpd      #$0008
                    ble       L5ACA
L5AEB               ldd       ,s
                    cmpd      #$0002
                    bne       L5AF8
                    ldd       #$005F
                    stb       ,u+
L5AF8               clra
                    clrb
                    stb       ,u
                    bra       L5B01

L5AFE               lbsr      $635E
L5B01               ldb       $0065
                    sex
                    pshs      d
                    bsr       L5B0F
                    std       ,s++
                    bne       L5AFE
                    lbra      L5C58

L5B0F               pshs      u
                    ldd       $04,s
                    leax      $0089,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$6a
                    beq       L5B2D
                    ldd       $04,s
                    leax      $0089,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$6b
                    bne       L5B32
L5B2D               ldd       #$0001
                    bra       L5B34

L5B32               clra
                    clrb
L5B34               puls      pc,u
L5B36               pshs      u,y,x,d
                    ldd       $0041
                    beq       L5B42
                    leax      $050C,y
                    bra       L5B46

L5B42               leax      $040C,y
L5B46               tfr       x,d
                    std       $02,s
                    ldd       $0a,s
                    pshs      d
                    lbsr      L5C0A
                    leas      $02,s
                    aslb
                    rola
                    addd      $02,s
                    std       $04,s
                    ldu       [$04,s]
                    bra       L5B8B

L5B5E               ldb       $14,u
                    sex
                    pshs      d
                    ldb       [$0C,s]
                    sex
                    cmpd      ,s++
                    bne       L5B88
                    ldd       #$0008
                    pshs      d
                    pshs      u
                    ldd       #$0014
                    addd      ,s++
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    lbsr      $73C7
                    leas      $06,s
                    std       -$02,s
                    beq       L5BD2
L5B88               ldu       $12,u
L5B8B               stu       -$02,s
                    bne       L5B5E
                    ldu       L0019
                    beq       L5B9A
                    ldd       $12,u
                    std       L0019
                    bra       L5BA6

L5B9A               ldd       #$001C
                    pshs      d
                    lbsr      L5C2A
                    leas      $02,s
                    tfr       d,u
L5BA6               ldd       #$0008
                    pshs      d
                    ldd       $0C,s
                    pshs      d
                    pshs      u
                    ldd       #$0014
                    addd      ,s++
                    pshs      d
                    lbsr      $738A
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
L5BD2               tfr       u,d
                    leas      $06,s
                    puls      pc,u
L5BD8               pshs      u
                    leas      -$09,s
                    ldd       #$0008
                    pshs      d
                    ldd       $0f,s
                    pshs      d
                    leax      $04,s
                    pshs      x
                    lbsr      $738A
                    leas      $06,s
                    clra
                    clrb
                    stb       $08,s
                    leax      ,s
                    pshs      x
                    lbsr      L5B36
                    leas      $02,s
                    tfr       d,u
                    ldd       #$0033
                    std       ,u
                    ldd       $0f,s
                    std       $08,u
                    leas      $09,s
                    puls      pc,u
L5C0A               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    clra
                    clrb
                    bra       L5C18

L5C14               ldd       $02,s
                    addd      ,s
L5C18               std       $02,s
                    ldb       ,u+
                    sex
                    std       ,s
                    bne       L5C14
                    ldd       $02,s
                    clra
                    andb      #$7f
                    leas      $04,s
L5C28               puls      pc,u
L5C2A               pshs      u,d
                    ldd       $06,s
                    pshs      d
                    lbsr      $784A
                    leas      $02,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       L5C48
                    leax      L62CF,pcr
                    pshs      x
                    lbsr      L022B
                    leas      $02,s
L5C48               ldd       L0066
                    bne       L5C50
                    ldd       ,s
                    std       L0066
L5C50               ldd       ,s
                    addd      $06,s
                    std       $0068
                    ldd       ,s
L5C58               leas      $02,s
                    puls      pc,u
L5C5C               pshs      u
                    ldu       $06,s
                    leas      -$10,s
                    clra
                    clrb
                    std       $02,s
                    leax      $08,s
                    pshs      x
                    bsr       L5C74
                    neg       $0000
                    neg       $0000
                    neg       $0000
                    neg       $0000
L5C74               puls      x
                    lbsr      $6A02
                    leax      $08,s
                    stx       ,s
                    ldd       $14,s
                    cmpd      #$0006
                    bne       L5C8C
                    leax      $10,s
                    lbra      L5DC7

L5C8C               ldb       $0065
                    cmpb      #$30
                    lbne      L5D99
                    leas      -$06,s
                    lbsr      $635E
                    ldb       $0065
                    cmpb      #$2e
                    bne       L5CA8
                    lbsr      $635E
                    leax      $16,s
                    lbra      L5DC7

L5CA8               leax      $02,s
                    pshs      x
                    bsr       L5CB2
                    neg       $0000
                    neg       $0000
L5CB2               puls      x
                    lbsr      L74D6
                    ldb       $0065
                    cmpb      #$78
                    beq       L5CC5
                    ldb       $0065
                    cmpb      #$58
                    lbne      L5D3B
L5CC5               leas      -$02,s
                    bra       L5CFE

L5CC9               leax      $04,s
                    pshs      x
                    leax      $06,s
                    pshs      x
                    ldd       #$0004
                    lbsr      L74EC
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $06,s
                    cmpd      #$0041
                    blt       L5CEC
                    ldd       #$0037
                    bra       L5CEF

L5CEC               ldd       #$0030
L5CEF               pshs      d
                    ldd       $08,s
                    subd      ,s++
                    lbsr      L74BD
                    lbsr      $746C
                    lbsr      L74D6
L5CFE               lbsr      $635E
                    ldb       $0065
                    sex
                    pshs      d
                    lbsr      $61BF
                    leas      $02,s
                    std       ,s
                    bne       L5CC9
                    leas      $02,s
                    bra       L5D47

L5D13               leax      $02,s
                    pshs      x
                    leax      $04,s
                    pshs      x
                    ldd       #$0003
                    lbsr      L74EC
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldb       $0065
                    sex
                    addd      #$FFD0
                    lbsr      L74BD
                    lbsr      $746C
                    lbsr      L74D6
                    lbsr      $635E
L5D3B               ldb       $0065
                    sex
                    pshs      d
                    lbsr      $61AC
                    std       ,s++
                    bne       L5D13
L5D47               leax      $02,s
                    stx       ,s
                    ldb       $0065
                    cmpb      #$4C
                    beq       L5D57
                    ldb       $0065
                    cmpb      #$6C
                    bne       L5D5F
L5D57               lbsr      $635E
                    leax      $16,s
                    bra       L5D6E

L5D5F               ldd       [,s]
                    bne       L5D71
                    ldd       $04,s
                    std       ,u
                    ldd       #$0001
                    bra       L5D7D
                    bra       L5D71

L5D6E               leas      -$16,x
L5D71               leax      ,u
                    pshs      x
                    leax      $04,s
                    lbsr      L74D6
                    ldd       #$0008
L5D7D               leas      $16,s
                    puls      pc,u
                    bra       L5D99

L5D84               ldb       $0065
                    sex
                    pshs      d
                    leax      $0a,s
                    pshs      x
                    lbsr      $549F
                    leas      $04,s
                    std       -$02,s
                    bne       L5DDD
                    lbsr      $635E
L5D99               ldb       $0065
                    sex
                    leax      $0089,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$6b
                    beq       L5D84
                    ldb       $0065
                    cmpb      #$2e
                    beq       L5DBC
                    ldb       $0065
                    cmpb      #$65
                    beq       L5DBC
                    ldb       $0065
                    cmpb      #$45
                    lbne      L5E98
L5DBC               ldb       $0065
                    cmpb      #$2e
                    bne       L5DFC
                    lbsr      $635E
                    bra       L5DED

L5DC7               leas      -$10,x
                    bra       L5DED

L5DCB               ldb       $0065
                    sex
                    pshs      d
                    leax      $0a,s
                    pshs      x
                    lbsr      $549F
                    leas      $04,s
                    std       -$02,s
                    beq       L5DE3
L5DDD               lbsr      $635E
                    lbra      L5EA8

L5DE3               lbsr      $635E
                    ldd       $02,s
                    addd      #$0001
                    std       $02,s
L5DED               ldb       $0065
                    sex
                    leax      $0089,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$6b
                    beq       L5DCB
L5DFC               ldb       $0065
                    cmpb      #$45
                    beq       L5E0A
                    ldb       $0065
                    cmpb      #$65
                    lbne      L5E78
L5E0A               ldd       #$0001
                    std       $04,s
                    lbsr      $635E
                    ldb       $0065
                    cmpb      #$2b
                    bne       L5E1D
                    lbsr      $635E
                    bra       L5E2A

L5E1D               ldb       $0065
                    cmpb      #$2d
                    bne       L5E2A
                    lbsr      $635E
                    clra
                    clrb
                    std       $04,s
L5E2A               clra
                    clrb
                    std       $06,s
                    bra       L5E49

L5E30               ldd       $06,s
                    pshs      d
                    ldd       #$000A
                    lbsr      L7542
                    pshs      d
                    ldb       $0065
                    sex
                    addd      #$FFD0
                    addd      ,s++
                    std       $06,s
                    lbsr      $635E
L5E49               ldb       $0065
                    sex
                    leax      $0089,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$6b
                    beq       L5E30
                    ldd       $06,s
                    cmpd      #$0028
                    lbge      L5EA8
                    ldd       $02,s
                    pshs      d
                    ldd       $06,s
                    beq       L5E72
                    ldd       $08,s
                    nega
                    negb
                    sbca      #$00
                    bra       L5E74

L5E72               ldd       $08,s
L5E74               addd      ,s++
                    std       $02,s
L5E78               ldd       $02,s
                    nega
                    negb
                    sbca      #$00
                    ldx       ,s
                    stb       $07,x
                    ldb       [,s]
                    clra
                    andb      #$7f
                    stb       [,s]
                    leax      ,u
                    pshs      x
                    leax      $0a,s
                    lbsr      $6A02
                    ldd       #$0006
                    lbra      L5EFE

L5E98               ldb       [,s]
                    bne       L5EA8
                    ldx       ,s
                    ldb       $01,x
                    bne       L5EA8
                    ldx       ,s
                    ldb       $02,x
                    beq       L5EAD
L5EA8               clra
                    clrb
                    lbra      L5EFE

L5EAD               ldb       $0065
                    cmpb      #$6C
                    beq       L5EB9
                    ldb       $0065
                    cmpb      #$4C
                    bne       L5ED8
L5EB9               leas      -$02,s
                    lbsr      $635E
                    bra       L5EC3

L5EC0               leas      -$12,x
L5EC3               ldd       $02,s
                    addd      #$0003
                    std       ,s
                    leax      ,u
                    pshs      x
                    ldx       $02,s
                    lbsr      L74D6
                    ldd       #$0008
                    bra       L5EF9

L5ED8               ldx       ,s
                    ldb       $03,x
                    bne       L5EE4
                    ldx       ,s
                    ldb       $04,x
                    beq       L5EE9
L5EE4               leax      $10,s
                    bra       L5EC0

L5EE9               leas      -$02,s
                    ldd       $02,s
                    addd      #$0005
                    std       ,s
                    ldd       [,s]
                    std       ,u
                    ldd       #$0001
L5EF9               leas      $12,s
                    puls      pc,u
L5EFE               leas      $10,s
                    puls      pc,u
L5F03               pshs      u
                    lbsr      $635E
                    ldb       $0065
                    cmpb      #$5C
                    bne       L5F15
                    lbsr      $6059
                    std       $0061
                    bra       L5F1D

L5F15               ldb       $0065
                    sex
                    std       $0061
                    lbsr      $635E
L5F1D               ldb       $0065
                    cmpb      #$27
                    lbeq      $6008
                    leax      $62DD,pcr
                    pshs      x
                    lbsr      L024E
                    leas      $02,s
                    lbra      $600B

L5F33               pshs      u
                    ldx       $000B
                    bra       $5F67
                    ldd       $006C
                    bne       $5F5D
                    leax      L62FD,pcr
                    pshs      x
                    leax      $01A9,y
                    pshs      x
                    lbsr      $6DF0
                    leas      $04,s
                    std       $006C
                    bne       $5F5D
                    leax      $0d,y
                    bsr       L5F59
                    ora       -$0C,y
                    fcb       $10
L5F59               lbsr      $022C
                    leas      $02,s
                    ldd       $006C
                    bra       L5F64

L5F62               ldd       $0025
L5F64               std       L001B
                    bra       L5F78
                    stx       -$02,s
                    beq       $5F3A
                    cmpx      #$0002
                    lbeq      $5F3A
                    cmpx      #$0001
                    beq       L5F62
L5F78               clra
                    clrb
                    std       L0017
                    ldd       $000B
                    cmpd      #$0001
                    beq       L5FA6
                    ldd       L001B
                    pshs      d
                    ldd       #$006C
                    pshs      d
                    lbsr      L6F05
                    leas      $04,s
                    ldd       L001B
                    pshs      d
                    ldd       L002B
                    addd      #$0001
                    std       L002B
                    std       $0061
                    pshs      d
                    lbsr      L6FAA
                    leas      $04,s
L5FA6               lbsr      L635F
                    ldd       L001B
                    pshs      d
                    ldd       #$0073
                    pshs      d
                    lbsr      L6F05
                    leas      $04,s
                    bra       L5FEF

L5FB9               leax      $060C,y
                    pshs      x
                    ldd       $006A
                    subd      ,s++
                    bne       L5FD2
                    leax      $6319,pcr
                    pshs      x
                    lbsr      $024F
                    leas      $02,s
                    bra       L5FF5

L5FD2               ldb       $0065
                    cmpb      #$5C
                    bne       L5FE3
                    lbsr      L605A
                    pshs      d
                    bsr       L600E
                    leas      $02,s
                    bra       L5FEF

L5FE3               ldb       $0065
                    sex
                    pshs      d
                    bsr       L600E
                    leas      $02,s
                    lbsr      L635F
L5FEF               ldb       $0065
                    cmpb      #$22
                    bne       L5FB9
L5FF5               ldd       L001B
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    lbsr      L6F05
                    leas      $04,s
                    ldd       L0017
                    addd      #$0001
                    std       L0017
                    lbsr      L635F
                    puls      pc,u
L600E               pshs      u
                    ldd       $04,s
                    beq       L601C
                    ldd       $04,s
                    cmpd      #$005C
                    bne       L602A
L601C               ldd       L001B
                    pshs      d
                    ldd       #$005C
                    pshs      d
                    lbsr      L6F05
                    leas      $04,s
L602A               ldd       L001B
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L6F05
                    leas      $04,s
                    ldd       L0017
                    addd      #$0001
                    std       L0017
                    puls      pc,u
                    pshs      u
                    lbsr      $4BF0
                    ldd       $04,s
                    pshs      d
                    leax      $632D,pcr
                    pshs      x
                    ldd       L001B
                    pshs      d
                    lbsr      $50E7
                    leas      $06,s
                    puls      pc,u
L605A               pshs      u,d
                    lbsr      L635F
                    ldb       $0065
                    sex
                    tfr       d,u
                    lbsr      L635F
                    leax      ,u
                    bra       L6095

L606B               ldd       #$000A
                    lbra      L61A9

L6071               ldd       #$0009
                    lbra      L61A9

L6077               ldd       #$0008
                    lbra      L61A9

L607D               ldd       #$000B
                    lbra      L61A9

L6083               ldd       #$000D
                    lbra      L61A9

L6089               ldd       #$000C
                    lbra      L61A9

L608F               ldd       #$0020
                    lbra      L61A9

L6095               cmpx      #$006E
                    beq       L6083
                    cmpx      #$006C
                    beq       L606B
                    cmpx      #$0074
                    beq       L6071
                    cmpx      #$0062
                    beq       L6077
                    cmpx      #$0076
                    beq       L607D
                    cmpx      #$0072
                    lbeq      L6083
                    cmpx      #$0066
                    beq       L6089
                    cmpx      #$000D
                    beq       L608F
                    cmpu      #$0078
                    lbne      L611B
                    leas      -$02,s
                    clra
                    clrb
                    std       $02,s
                    tfr       d,u
                    bra       L60F8

L60D1               tfr       u,d
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
                    bge       L60EC
                    ldd       $02,s
                    addd      #$FFD0
                    bra       L60F1

L60EC               ldd       $02,s
                    addd      #$FFC9
L60F1               addd      ,s++
                    tfr       d,u
                    lbsr      L635F
L60F8               ldb       $0065
                    sex
                    pshs      d
                    lbsr      L61C0
                    leas      $02,s
                    std       ,s
                    beq       L6116
                    ldd       $02,s
                    addd      #$0001
                    std       $02,s
                    subd      #$0001
                    cmpd      #$0002
                    blt       L60D1
L6116               leas      $02,s
                    lbra      L61A7

L611B               cmpu      #$0064
                    bne       L6163
                    clra
                    clrb
                    std       ,s
                    tfr       d,u
                    bra       L6140

L6129               pshs      u
                    ldd       #$000A
                    lbsr      L7543
                    pshs      d
                    ldb       $0065
                    sex
                    addd      ,s++
                    addd      #$FFD0
                    tfr       d,u
                    lbsr      L635F
L6140               ldb       $0065
                    sex
                    leax      $0089,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$6b
                    lbne      L61A7
                    ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    cmpd      #$0003
                    blt       L6129
                    bra       L61A7

L6163               pshs      u
                    lbsr      L61AD
                    std       ,s++
                    beq       L61A7
L616C               leau      -$30,u
                    clra
                    clrb
                    std       ,s
                    bra       L618C

L6175               tfr       u,d
                    aslb
L6178               rola
                    aslb
                    rola
                    aslb
                    rola
                    pshs      d
                    ldb       $0065
                    sex
                    addd      #$FFD0
                    addd      ,s++
                    tfr       d,u
                    lbsr      L635F
L618C               ldb       $0065
                    sex
                    pshs      d
                    bsr       L61AD
                    std       ,s++
                    beq       L61A7
                    ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    cmpd      #$0003
                    blt       L6175
L61A7               tfr       u,d
L61A9               leas      $02,s
                    puls      pc,u
L61AD               pshs      u
                    ldb       $05,s
                    cmpb      #$37
                    bgt       L61E9
                    ldb       $05,s
                    cmpb      #$30
                    blt       L61E9
                    ldd       #$0001
                    bra       L61EB

L61C0               pshs      u
                    ldb       $05,s
                    sex
                    leax      $0089,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$6b
                    beq       L61E4
                    ldb       $05,s
                    clra
                    andb      #$5f
                    stb       $05,s
                    cmpd      #$0041
                    blt       L61E9
                    ldb       $05,s
                    cmpb      #$46
                    bgt       L61E9
L61E4               ldb       $05,s
                    sex
                    bra       L61EB

L61E9               clra
                    clrb
L61EB               puls      pc,u
                    fcb       $62
                    fcb       $61
                    lsr       0,y
                    com       $08,s
                    fcb       $61
                    fcb       $72
                    fcb       $61
                    com       -$0C,s
                    fcb       $65
                    fcb       $72
L61FA               neg       $0063
                    clr       $0e,s
                    com       L7461
                    jmp       -$0C,s
                    bra       $6274
                    ror       $6572
                    ror       $0C,s
                    clr       -$09,s
L620C               neg       L0064
                    clr       -$0b,s
                    fcb       $62
                    inc       $05,s
L6213               neg       L0066
                    inc       $0f,s
                    fcb       $61
                    lsr       >$0074
                    rol       $7065
                    lsr       $05,s
L6220               ror       0,x
                    com       L7461
                    lsr       L6963
L6228               neg       $0073
                    rol       -$06,s
                    fcb       $65
                    clr       $06,s
L622F               neg       L0069
                    jmp       -$0C,s

L6233               neg       L0069
                    jmp       -$0C,s

L6237               neg       L0066
                    inc       $0f,s
                    fcb       $61
                    lsr       >$0063
                    asl       $01,s
                    fcb       $72
L6242               neg       $0073
                    asl       $0f,s
                    fcb       $72
                    lsr       >$0061
                    fcb       $75
                    lsr       $6F00
                    fcb       $65
                    asl       L7465
                    fcb       $72
                    jmp       0,x
                    lsr       $09,s
                    fcb       $72
                    fcb       $65
                    com       -$0C,s
L625B               neg       $0072
                    fcb       $65
                    asr       $09,s
                    com       L7465
                    fcb       $72
L6264               neg       $0067
                    clr       -$0C,s
                    clr       0,x
                    fcb       $72
                    fcb       $65
                    lsr       $7572
                    jmp       0,x
                    rol       $06,s
L6273               neg       $0077
                    asl       $09,s
                    inc       $05,s
L6279               neg       $0065
                    inc       -$0d,s
                    fcb       $65
L627E               neg       $0073
                    asr       $6974
                    com       $08,s
L6285               neg       $0063
                    fcb       $61
                    com       $6500
                    fcb       $62
                    fcb       $72
                    fcb       $65
                    fcb       $61
                    fcb       $6b
L6290               neg       $0063
                    clr       $0e,s
                    lsr       $696E
                    fcb       $75
                    fcb       $65
L6299               neg       L0064
                    clr       0,x
                    lsr       $05,s
                    ror       $01,s
                    fcb       $75
                    inc       -$0C,s
L62A4               neg       L0066
                    clr       -$0e,s
L62A8               neg       $0073
                    lsr       $7275
                    com       -$0C,s
L62AF               neg       $0075
                    jmp       $09,s
                    clr       $0e,s
L62B5               neg       $0075
                    jmp       -$0d,s
                    rol       $07,s
                    jmp       $05,s
                    lsr       0,x
                    inc       $0f,s
                    jmp       $07,s

L62C3               neg       $0065
                    fcb       $72
                    fcb       $72
                    jmp       $0f,s

L62C9               neg       $006C
                    com       L6565
                    fcb       $6b
L62CF               neg       $006F
                    fcb       $75
                    lsr       $206F
                    ror       0,y
                    tst       $05,s
                    tst       $0f,s
                    fcb       $72
                    rol       >$0075
                    jmp       -$0C,s
                    fcb       $65
                    fcb       $72
                    tst       $09,s
                    jmp       $01,s
                    lsr       $6564
                    bra       L634F
                    asl       $01,s
                    fcb       $72
                    fcb       $61
                    com       -$0C,s
                    fcb       $65
                    fcb       $72
                    bra       L6359
                    clr       $0e,s
                    com       L7461
                    jmp       -$0C,s

L62FD               neg       $0077
                    bmi       L6301
L6301               com       $01,s
                    jmp       $07,y
                    lsr       $206F
                    neg       $656E
                    bra       L6380
                    lsr       $7269
                    jmp       $07,s
                    com       $2066
                    rol       $0C,s
                    fcb       $65
                    neg       $0075
                    jmp       -$0C,s
                    fcb       $65
                    fcb       $72
                    tst       $09,s
                    jmp       $01,s
                    lsr       $6564
                    bra       $639A
                    lsr       $7269
                    jmp       $07,s
                    neg       L0020
                    fcb       $72
                    dec       L6220
                    bcs       $6398
                    tst       $0000
L6336               pshs      u
                    leax      $060C,y
                    stx       $006A
                    clra
                    clrb
                    stb       $060C,y
                    ldd       #$0020
                    bra       L636F
                    pshs      u
                    bra       L634F

L634D               bsr       L635F
L634F               ldb       $0065
                    cmpb      #$20
                    beq       L634D
                    ldb       $0065
                    cmpb      #$09
L6359               lbeq      L634D
                    puls      pc,u
L635F               pshs      u
                    ldx       $006A
                    leax      $01,x
                    stx       $006A
                    ldb       -$01,x
                    stb       $0065
                    bne       L6371
                    bsr       L6373
L636F               stb       $0065
L6371               puls      pc,u
L6373               pshs      u
                    leas      -$08,s
                    ldd       L001D
                    bne       L6389
                    ldd       #$0001
                    std       L001D
L6380               leax      L6635,pcr
                    stx       $006A
                    lbra      L656A

L6389               clra
                    clrb
                    std       L001D
                    leax      $060C,y
                    pshs      x
                    leax      $070C,y
                    pshs      x
                    lbsr      L7315
                    leas      $04,s
L639E               lbsr      L65A7
                    std       $006A
                    lbeq      L64A8
                    ldb       [$006A,y]
                    cmpb      #$23
                    lbne      L6563
                    ldx       $006A
                    ldb       $01,x
                    sex
                    std       $04,s
                    lbsr      L65A7
                    std       -$02,s
                    lbeq      L64A8
                    ldx       $04,s
                    lbra      L652F

L63C6               leax      $060C,y
                    pshs      x
                    lbsr      L6571
                    leas      $02,s
                    std       L0027
                    bra       L639E

L63D5               lbsr      L6804
L63D8               lbsr      $4BF0
                    leax      $060C,y
                    pshs      x
                    leax      $6636,pcr
                    lbra      L645A

L63E8               leax      $060C,y
                    pshs      x
                    leax      $03EE,y
                    pshs      x
                    lbsr      L7315
                    leas      $04,s
                    leax      $03EE,y
                    pshs      x
                    lbsr      $4C03
                    leas      $02,s
                    lbsr      L65A7
                    std       -$02,s
                    lbne      L639E
                    lbra      L64A8

L6410               leax      $060C,y
                    pshs      x
                    leax      $02EE,y
                    pshs      x
                    lbsr      L7315
                    leas      $04,s
                    lbsr      L65A7
                    std       -$02,s
                    lbeq      L64A8
                    lbsr      $4BF0
                    leax      $060C,y
                    pshs      x
                    lbsr      L6571
                    std       ,s
                    leax      $02EE,y
                    pshs      x
                    leax      L663A,pcr
                    pshs      x
                    ldd       $0025
                    pshs      d
                    lbsr      $50E7
                    leas      $08,s
                    lbsr      $4BF0
                    leax      $02EE,y
                    pshs      x
                    leax      L6650,pcr
L645A               pshs      x
                    ldd       $0025
                    pshs      d
                    lbsr      $50E7
                    leas      $06,s
                    lbra      L639E

L6468               leax      $060C,y
                    pshs      x
                    leax      $02EE,y
                    pshs      x
                    lbsr      L7315
                    leas      $04,s
                    lbsr      L65A7
                    std       -$02,s
                    beq       L64A8
                    leax      $060C,y
                    pshs      x
                    lbsr      L6571
                    leas      $02,s
                    std       $06,s
                    lbsr      L65A7
                    std       -$02,s
                    beq       L64A8
                    leax      $060C,y
                    pshs      x
                    lbsr      L6571
                    leas      $02,s
                    std       $02,s
                    lbsr      L65A7
                    std       -$02,s
                    bne       L64AE
L64A8               ldd       #$FFFF
                    lbra      L656D

L64AE               ldd       $06,s
                    beq       L64C9
                    ldd       $06,s
                    pshs      d
                    leax      $03EE,y
                    pshs      x
                    leax      L6659,pcr
                    pshs      x
                    lbsr      L50D2
                    leas      $06,s
                    bra       L64D4

L64C9               leax      $6667,pcr
                    pshs      x
                    lbsr      L50D2
                    leas      $02,s
L64D4               leax      $060C,y
                    pshs      x
                    leax      L6673,pcr
                    pshs      x
                    lbsr      L50D2
                    leas      $04,s
                    ldb       $02EE,y
                    beq       L651F
                    leax      $02EE,y
                    pshs      x
                    lbsr      L6E43
                    leas      $02,s
                    bra       L6508

L64F8               leax      $01C1,y
                    pshs      x
                    ldd       #$0020
                    pshs      d
                    lbsr      L6F05
                    leas      $04,s
L6508               ldd       $02,s
                    addd      #$FFFF
                    std       $02,s
                    subd      #$FFFF
                    bne       L64F8
                    leax      $6681,pcr
                    pshs      x
                    lbsr      L6E43
                    leas      $02,s
L651F               ldd       $04,s
                    cmpd      #$0031
                    lbne      L639E
                    lbsr      L68C5
                    lbra      L639E

L652F               cmpx      #$0035
                    lbeq      L63C6
                    cmpx      #$0036
                    lbeq      L63D5
                    cmpx      #$0032
                    lbeq      L63D8
                    cmpx      #$0037
                    lbeq      L63E8
                    cmpx      #$0050
                    lbeq      L6410
                    cmpx      #$0030
                    lbeq      L6468
                    cmpx      #$0031
                    lbeq      L6468
                    lbra      L639E

L6563               ldd       L0027
L6565               addd      #$0001
                    std       L0027
L656A               ldd       #$0020
L656D               leas      $08,s
                    puls      pc,u
L6571               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    clra
                    clrb
                    bra       L658E

L657B               ldd       ,s
                    pshs      d
                    ldd       #$000A
                    lbsr      L7543
                    pshs      d
                    ldd       $04,s
                    addd      #$FFD0
                    addd      ,s++
L658E               std       ,s
                    ldb       ,u+
                    sex
                    std       $02,s
                    leax      $0089,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$6b
                    beq       L657B
                    ldd       ,s
                    leas      $04,s
                    puls      pc,u
L65A7               pshs      u,d
                    leau      $060C,y
                    ldd       L0023
                    pshs      d
                    lbsr      L7120
                    leas      $02,s
                    std       ,s
                    cmpd      #$FFFF
                    lbne      L6610
                    ldx       L0023
                    ldd       $06,x
                    clra
                    andb      #$20
                    beq       L65DD
                    leax      $01CE,y
                    pshs      x
                    leax      $6683,pcr
                    pshs      x
                    lbsr      L6E65
                    leas      $04,s
                    lbsr      L68C5
L65DD               clra
                    clrb
                    bra       L6631

L65E1               ldx       ,s
                    bra       L6602

L65E5               clra
                    clrb
                    stb       ,u
                    leax      $060C,y
                    tfr       x,d
                    bra       L6631

L65F1               ldd       ,s
                    stb       ,u+
                    ldd       L0023
                    pshs      d
                    lbsr      L7120
                    leas      $02,s
                    std       ,s
                    bra       L6610

L6602               cmpx      #$000D
                    beq       L65E5
                    cmpx      #$FFFF
                    lbeq      L65E5
                    bra       L65F1

L6610               cmpu      $0189,y
                    bne       L65E1
                    ldd       L0027
                    addd      #$0001
                    std       L0027
                    std       L003F
                    leax      $060C,y
                    stx       $0063
                    leax      >L66A6,pcr
                    pshs      x
                    lbsr      $022C
                    leas      $02,s
L6631               leas      $02,s
                    puls      pc,u
L6635               neg       $0025
                    com       L0D00
L663A               bra       $66AC
                    fcb       $73,$65,$63,$74,$20,$25,$73,$2C
                    fcb       $30,$2C,$30,$2C,$25,$64,$2C,$30
                    fcb       $2C,$30,$0d,$00
L6650               bra       $66C0
                    fcb       $61
                    tst       0,y
                    bcs       $66CA
                    tst       $0000
L6659               bcs       $66CE
                    bra       L6697
                    bra       L66CB
                    rol       $0e,s
                    fcb       $65
                    bra       L6689
                    lsr       0,y
                    neg       $0061
                    fcb       $72
                    asr       -$0b,s
                    tst       $05,s
                    jmp       -$0C,s
                    bra       L66AB
                    bra       L6673

L6673               bpl       L669F
                    bpl       L66A1
                    bra       L669E
                    com       L202A
                    bpl       L66A8
                    bpl       L668D
                    neg       $005E
                    neg       L0049
                    fcb       $4e,$50,$55,$54,$20
L6689               fcb       $46,$49,$4C,$45
L668D               fcb       $20,$45,$52,$52,$4f,$52,$20,$3a
                    fcb       $20,$54
L6697               fcb       $45,$4d,$50,$4f,$52,$41,$52
L669E               fcb       $59
L669F               fcb       $20,$46
L66A1               fcb       $49,$4C,$45,$0d,$00
L66A6               rol       $0e,s
L66A8               neg       $7574
L66AB               bra       $6719
                    rol       $0e,s
                    fcb       $65
                    bra       L6726
                    clr       $0f,s
                    bra       L6722
                    clr       $0e,s
                    asr       0,x
L66BA               pshs      u
                    lbsr      L6871
                    lbra      L6718
                    pshs      u
                    ldd       $08,s
                    pshs      d
                    lbsr      L6815
L66CB               leas      $02,s
                    lbsr      $4BF0
                    ldd       $04,s
                    pshs      d
                    lbsr      $4B05
                    leas      $02,s
                    ldd       $06,s
                    pshs      d
                    leax      L691E,pcr
                    pshs      x
                    ldd       $0025
                    pshs      d
                    lbsr      $50E7
                    bra       L6716
                    pshs      u
                    ldd       $08,s
                    pshs      d
                    lbsr      L6815
                    leas      $02,s
                    ldd       #$003A
                    bra       L670A
                    pshs      u
                    ldd       $08,s
                    pshs      d
                    lbsr      L6815
                    leas      $02,s
                    ldd       #$0020
L670A               pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    bsr       L671D
L6716               leas      $06,s
L6718               lbsr      L6825
                    puls      pc,u
L671D               pshs      u
                    lbsr      $4BF0
L6722               ldd       $06,s
                    pshs      d
L6726               ldb       $0b,s
                    sex
                    pshs      d
                    ldd       $08,s
                    addd      #$0014
                    pshs      d
                    leax      $6927,pcr
                    pshs      x
                    ldd       $0025
                    pshs      d
                    lbsr      $50E7
                    leas      $0a,s
                    puls      pc,u
                    pshs      u
                    ldd       $0025
                    pshs      d
                    ldd       #$0053
                    pshs      d
                    lbsr      L6F05
                    leas      $04,s
                    ldd       $0025
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L6F05
                    leas      $04,s
                    ldd       $0035
                    bne       L6776
                    ldd       $0025
                    pshs      d
                    ldd       L002B
                    addd      #$0001
                    std       L002B
                    pshs      d
                    lbsr      L6FAA
                    leas      $04,s
L6776               clra
                    clrb
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    leax      $6936,pcr
                    pshs      x
                    ldd       $0025
                    pshs      d
                    lbsr      $50E7
                    leas      $08,s
                    ldd       L0037
                    lbeq      L67E6
                    ldd       $0025
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    lbsr      L6FAA
                    bra       L67E4
                    pshs      u
                    ldd       #$0070
                    pshs      d
                    lbsr      $4A89
                    leas      $02,s
                    ldd       $0025
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L6FAA
                    leas      $04,s
                    clra
                    clrb
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    leax      $693D,pcr
                    pshs      x
                    ldd       $0025
                    pshs      d
                    lbsr      $50E7
                    leas      $08,s
                    puls      pc,u
                    pshs      u
                    ldd       $0035
                    bne       L67E6
                    ldd       $0025
                    pshs      d
                    ldd       #$0045
                    pshs      d
                    lbsr      L6F05
L67E4               leas      $04,s
L67E6               puls      pc,u
                    pshs      u
                    lbsr      $4BF0
                    leax      $6944,pcr
                    bra       L67FC
                    pshs      u
                    lbsr      $4BF0
                    leax      L6949,pcr
L67FC               pshs      x
                    lbsr      $4A48
                    lbra      L691A

L6804               pshs      u
                    lbsr      $4BF0
                    leax      L694E,pcr
                    pshs      x
                    lbsr      $4A9F
                    lbra      L691A

L6815               pshs      u
                    ldd       $04,s
                    beq       L6820
                    ldd       #$0064
                    bra       L682A

L6820               ldd       #$0076
                    bra       L682A

L6825               pshs      u
                    ldd       #$0065
L682A               pshs      d
                    lbsr      $4A89
                    lbra      L691A

L6832               pshs      u
                    ldd       $04,s
                    pshs      d
                    lbsr      L7030
                    leas      $02,s
                    ldx       $04,s
                    ldd       $02,x
                    ldx       $04,s
                    addd      $0b,x
                    ldx       $04,s
                    std       $04,x
                    std       [$04,s]
                    ldx       $04,s
                    ldd       $06,x
                    anda      #$FE
                    andb      #$EF
                    std       $06,x
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    pshs      d
                    ldx       $0a,s
                    ldd       $08,x
                    pshs      d
                    lbsr      L77E4
L6869               leas      $08,s
                    ldd       $02C8,y
                    puls      pc,u
L6871               pshs      u
                    ldd       $006C
                    lbeq      L691C
                    ldd       $006C
                    pshs      d
                    bsr       L6832
                    leas      $02,s
                    bra       L688E

L6883               ldd       $0025
                    pshs      d
                    pshs      u
                    lbsr      L6F05
                    leas      $04,s
L688E               ldd       $006C
                    pshs      d
                    lbsr      L7120
                    leas      $02,s
                    tfr       d,u
                    cmpu      #$FFFF
                    bne       L6883
                    ldx       $006C
                    ldd       $06,x
                    clra
                    andb      #$20
                    beq       L68B1
                    leax      $6951,pcr
                    ldd       $06,x
                    clra
                    andb      #$20
L68B1               ldd       $006C
                    pshs      d
                    lbsr      L6FF6
                    leas      $02,s
                    leax      $01A9,y
                    pshs      x
                    lbsr      L7775
                    bra       L691A

L68C5               pshs      u,d
                    ldd       $02D2,y
                    beq       L68D3
                    ldd       $02D2,y
                    bra       L68D6

L68D3               ldd       #$0001
L68D6               std       ,s
                    leax      $01C1,y
                    pshs      x
                    lbsr      L7030
                    leas      $02,s
                    ldd       $006C
                    beq       L68FB
                    ldd       $006C
                    pshs      d
                    lbsr      L6FF6
                    leas      $02,s
                    leax      $01A9,y
                    pshs      x
                    lbsr      L7775
                    leas      $02,s
L68FB               ldd       $001F
                    beq       L6911
                    ldd       L0023
                    pshs      d
                    lbsr      L6FF6
                    leas      $02,s
                    ldd       $001F
                    pshs      d
                    lbsr      L7775
                    leas      $02,s
L6911               ldd       ,s
                    pshs      d
                    lbsr      L794A
                    leas      $02,s
L691A               leas      $02,s
L691C               puls      pc,u
L691E               bra       $6992
                    tst       $02,s
                    bra       L6949
                    lsr       $0d,x
                    neg       $0025
                    bgt       $6962
                    com       $2563
                    bra       L69A1
                    tst       $02,s
                    bra       L6958
                    lsr       $0d,x
                    neg       $0025
                    bgt       L6971
                    com       $2563
                    neg       $0025
                    bgt       $6978
                    com       $2563
                    neg       L0066
                    com       $02,s
                    bra       L6949

L6949               ror       $04,s
                    fcb       $62
                    bra       L694E

L694E               bpl       $6970
                    neg       L0064
                    fcb       $75
                    tst       -$10,s
                    com       $7472
L6958               rol       $0e,s
                    asr       -$0d,s
L695C               neg       $0034
                    nega
                    leau      $02C6,y
L6963               ldd       ,x
                    std       ,u
                    ldd       $02,x
                    std       $02,u
                    ldd       $04,x
                    std       $04,u
L696F               ldd       $06,x
L6971               std       $06,u
                    tfr       u,x
                    puls      pc,u
                    bsr       $695D
                    lda       ,x
                    eora      #$80
                    sta       ,x
L697F               rts
                    bsr       L6985
                    ldd       $02,x
L6984               rts

L6985               lda       ,x
                    pshs      a
                    bsr       $695D
                    bsr       L6997
                    leax      $03,x
                    lda       ,s+
                    bpl       L6996
                    lbra      L749A

L6996               rts

L6997               lda       $07,x
                    blt       L69C5
                    pshs      x
                    leax      $07,x
                    pshs      x,a
L69A1               bra       L69BD

L69A3               ldx       $01,s
                    ldb       #$06
                    pshs      b
                    clra
L69AA               pshs      a
                    lda       #$0a
                    ldb       ,-x
                    mul
                    addb      ,s+
                    adca      #$00
                    stb       ,x
                    dec       ,s
                    bpl       L69AA
                    leas      $01,s
L69BD               dec       ,s
                    bge       L69A3
                    leas      $03,s
                    puls      pc,x
L69C5               pshs      u,x,a
                    leau      $07,x
                    pshs      u
L69CB               cmpx      ,s
                    bcc       L69FF
                    lda       ,x+
                    beq       L69CB
                    leax      -$01,x
                    pshs      x
                    clrb
                    asl       ,x
                    rolb
                    asl       ,x
                    rolb
                    asl       ,x
                    rolb
                    lda       #$05
L69E3               asl       ,x
                    rolb
                    cmpb      #$0a
                    bcs       L69EE
                    subb      #$0a
                    inc       ,x
L69EE               deca
                    bne       L69E3
                    lda       #$08
                    leax      $01,x
                    cmpx      $02,s
                    bcs       L69E3
                    puls      x
                    inc       $02,s
                    bne       L69CB
L69FF               leas      $03,s
                    puls      pc,u,x
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
                    puls      u
                    puls      d
                    std       ,s
L6A1F               rts
                    leax      $02C6,y
                    std       -$02,s
                    bpl       L6A3B
                    nega
                    negb
                    sbca      #$00
                    std       $05,x
                    lda       #$80
L6A30               sta       ,x
                    clra
                    clrb
                    std       $01,x
                    std       $03,x
                    sta       $07,x
                    rts

L6A3B               std       $05,x
                    clra
                    bra       L6A30
                    pshs      u
                    leau      $02C6,y
                    clra
                    clrb
                    std       ,u
                    std       $02,u
                    ldd       ,x
                    pshs      d
                    std       $03,u
                    ldd       $02,x
                    std       $05,u
                    clr       $07,u
                    ldd       ,s++
                    bpl       L6A70
                    lda       #$80
                    sta       ,u
                    ldd       #$0000
                    subd      $05,u
                    std       $05,u
                    ldd       #$0000
                    sbcb      $04,u
                    sbca      $03,u
                    std       $03,u
L6A70               tfr       u,x
                    puls      pc,u
                    pshs      u
                    leax      L68C5,pcr
                    pshs      x
                    lbsr      L7914
                    leas      $02,s
                    leax      $01A9,y
                    pshs      x
                    lbsr      L6E85
                    leas      $02,s
                    leax      L6C19,pcr
                    pshs      x
                    ldd       $01A7,y
                    pshs      d
                    lbsr      L7315
                    leas      $04,s
                    lbsr      $589B
                    leax      $01B4,y
                    stx       L0023
                    leax      $01C1,y
                    stx       $0025
                    lbra      L6BA1

L6AAF               ldx       $06,s
                    leax      $02,x
                    stx       $06,s
                    ldu       ,x
                    ldb       ,u
                    cmpb      #$2d
                    lbne      L6B6C
                    lbra      L6B5E

L6AC2               ldb       ,u
                    sex
                    tfr       d,x
                    lbra      L6B3B

L6ACA               ldd       #$0001
                    std       $0021
                    lbra      L6B5E

L6AD2               ldd       #$0001
                    std       $0035
                    lbra      L6B5E

L6ADA               ldd       L0039
                    addd      #$0001
                    std       L0039
                    lbra      L6B5E

L6AE4               leau      $01,u
                    ldb       ,u
                    cmpb      #$3d
                    bne       L6B15
                    leax      L6C21,pcr
                    pshs      x
                    leau      $01,u
                    pshs      u
                    lbsr      L6DF1
                    leas      $04,s
                    std       $0025
                    bne       L6B15
                    pshs      u
                    leax      $6C23,pcr
                    pshs      x
                    leax      $01CE,y
                    pshs      x
                    lbsr      $50E7
                    leas      $06,s
                    lbsr      L6BFE
L6B15               leax      ,s
                    bra       L6B68

L6B19               ldd       #$0001
                    std       L0037
                    bra       L6B5E

L6B20               ldb       ,u
                    sex
                    pshs      d
                    leax      L6C32,pcr
                    pshs      x
                    leax      $01CE,y
                    pshs      x
                    lbsr      $50E7
                    leas      $06,s
                    lbsr      L6BFE
                    bra       L6B5E

L6B3B               cmpx      #$0065
                    lbeq      L6ACA
                    cmpx      #$0073
                    lbeq      L6AD2
                    cmpx      #$006E
                    lbeq      L6ADA
                    cmpx      #$006F
                    lbeq      L6AE4
                    cmpx      #$0070
                    beq       L6B19
                    bra       L6B20

L6B5E               leau      $01,u
                    ldb       ,u
                    lbne      L6AC2
                    bra       L6BA1

L6B68               leas      ,x
                    bra       L6BA1

L6B6C               ldd       $0072
                    bne       L6BA1
                    ldd       $0072
                    addd      #$0001
                    std       $0072
                    leax      $01B4,y
                    pshs      x
                    leax      L6C46,pcr
                    pshs      x
                    ldd       [$0a,s]
                    pshs      d
                    lbsr      L6E10
                    leas      $06,s
                    std       L0023
                    bne       L6B9C
                    leax      $6C48,pcr
                    pshs      x
                    lbsr      $022C
                    leas      $02,s
L6B9C               ldd       [$06,s]
                    std       $001F
L6BA1               ldd       $04,s
                    addd      #$FFFF
                    std       $04,s
                    lbgt      L6AAF
                    lbsr      L6336
                    lbsr      $552F
                    bra       L6BB7

L6BB4               lbsr      $322B
L6BB7               ldd       $005F
                    cmpd      #$FFFF
                    bne       L6BB4
                    lbsr      L66BA
                    ldx       $0025
                    ldd       $06,x
                    clra
                    andb      #$20
                    beq       L6BD6
                    leax      $6C5E,pcr
                    pshs      x
                    lbsr      $022C
                    leas      $02,s
L6BD6               leax      $01C1,y
                    pshs      x
                    lbsr      L7030
                    leas      $02,s
                    ldd       L0029
                    beq       L6BFC
                    ldd       L0029
                    pshs      d
                    leax      $6C7F,pcr
                    pshs      x
                    leax      $01CE,y
                    pshs      x
                    lbsr      $50E7
                    leas      $06,s
                    bsr       L6BFE
L6BFC               puls      pc,u
L6BFE               pshs      u
                    ldd       $001F
                    beq       L6C0D
                    ldd       $001F
                    pshs      d
                    lbsr      L7775
                    leas      $02,s
L6C0D               ldd       #$0001
                    pshs      d
                    lbsr      L7944
                    leas      $02,s
                    puls      pc,u
L6C19               clrb
                    lsr       -$0b,s
                    tst       $0d,s
                    rol       $5F00
L6C21               asr       >$0063
                    fcb       $61
                    jmp       $07,y
                    lsr       $206F
                    neg       $656E
                    bra       L6C54
                    com       L0D00
L6C32               fcb       $75,$6e,$6b,$6e,$6f,$77,$6e,$20
                    fcb       $66,$6C,$61,$67,$20,$3a,$20,$2d
                    fcb       $25,$63,$0d,$00
L6C46               fcb       $72
                    neg       $0063
                    fcb       $61
                    jmp       $07,y
                    lsr       $206F
                    neg       $656E
                    bra       L6CBD

L6C54               jmp       -$10,s
                    fcb       $75
                    lsr       $2066
                    rol       $0C,s
                    fcb       $65
                    neg       $0065
                    fcb       $72
                    fcb       $72
                    clr       -$0e,s
                    bra       L6CDC
                    fcb       $72
                    rol       -$0C,s
                    rol       $0e,s
                    asr       0,y
                    fcb       $61
                    com       $7365
                    tst       $02,s
                    inc       -$07,s
                    bra       $6CD9
                    clr       $04,s
                    fcb       $65
                    bra       $6CE1
                    rol       $0C,s
                    fcb       $65
                    neg       $0065
                    fcb       $72,$72,$6f,$72,$73,$20,$69,$6e
                    fcb       $20,$63,$6f,$6d,$70,$69,$6C,$61
                    fcb       $74,$69,$6f,$6e,$20,$3a,$20,$25
                    fcb       $64,$0d,$00
L6C9B               pshs      u
                    leau      $01B4,y
L6CA1               ldd       $06,u
                    clra
                    andb      #$03
                    lbeq      L6D12
                    leau      $0d,u
                    pshs      u
                    leax      $0284,y
                    cmpx      ,s++
                    bhi       L6CA1
                    ldd       #$00C8
                    std       $02D2,y
L6CBD               lbra      L6D16
                    puls      pc,u
L6CC2               pshs      u
                    ldu       $08,s
                    bne       L6CCC
                    bsr       L6C9B
                    tfr       d,u
L6CCC               stu       -$02,s
                    beq       L6D16
                    ldd       $04,s
                    std       $08,u
                    ldx       $06,s
                    ldb       $01,x
                    cmpb      #$2b
                    beq       L6CE4
L6CDC               ldx       $06,s
                    ldb       $02,x
                    cmpb      #$2b
                    bne       L6CEA
L6CE4               ldd       $06,u
                    orb       #$03
                    bra       L6D08

L6CEA               ldd       $06,u
                    pshs      d
                    ldb       [$08,s]
                    cmpb      #$72
                    beq       L6CFC
                    ldb       [$08,s]
                    cmpb      #$64
                    bne       L6D01
L6CFC               ldd       #$0001
                    bra       L6D04

L6D01               ldd       #$0002
L6D04               ora       ,s+
                    orb       ,s+
L6D08               std       $06,u
                    ldd       $02,u
                    addd      $0b,u
                    std       $04,u
                    std       ,u
L6D12               tfr       u,d
                    puls      pc,u
L6D16               clra
                    clrb
                    puls      pc,u
L6D1A               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    clra
                    clrb
                    std       ,s
                    ldx       $0a,s
                    ldb       $01,x
                    sex
                    tfr       d,x
                    bra       L6D4B

L6D2D               ldx       $0a,s
                    ldb       $02,x
                    cmpb      #$2b
                    bne       L6D3A
                    ldd       #$0007
                    bra       L6D42

L6D3A               ldd       #$0004
                    bra       L6D42

L6D3F               ldd       #$0003
L6D42               std       ,s
                    bra       L6D5B

L6D46               leax      $04,s
                    lbra      L6DB3

L6D4B               stx       -$02,s
                    beq       L6D5B
                    cmpx      #$0078
                    beq       L6D2D
                    cmpx      #$002B
                    beq       L6D3F
                    bra       L6D46

L6D5B               ldb       [$0a,s]
                    sex
                    tfr       d,x
L6D61               lbra      L6DC0

L6D64               ldd       ,s
                    orb       #$01
                    bra       L6DA6

L6D6A               ldd       ,s
                    orb       #$02
                    pshs      d
                    pshs      u
                    lbsr      L770E
                    leas      $04,s
                    std       $02,s
                    cmpd      #$FFFF
                    beq       L6D95
                    ldd       #$0002
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L77E4
                    leas      $08,s
                    bra       L6DDA

L6D95               ldd       ,s
                    orb       #$02
                    pshs      d
                    pshs      u
                    lbsr      L772F
                    bra       L6DAD

L6DA2               ldd       ,s
                    orb       #$81
L6DA6               pshs      d
                    pshs      u
                    lbsr      L770E
L6DAD               leas      $04,s
                    std       $02,s
                    bra       L6DDA

L6DB3               leas      -$04,x
L6DB5               ldd       #$00CB
                    std       $02D2,y
                    clra
                    clrb
                    bra       L6DDC

L6DC0               cmpx      #$0072
                    lbeq      L6D64
                    cmpx      #$0061
                    lbeq      L6D6A
                    cmpx      #$0077
                    beq       L6D95
                    cmpx      #$0064
                    beq       L6DA2
                    bra       L6DB5

L6DDA               ldd       $02,s
L6DDC               leas      $04,s
                    puls      pc,u
                    pshs      u
                    clra
                    clrb
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbra      L6E3C

L6DF1               pshs      u
                    ldd       $06,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L6D1A
                    leas      $04,s
                    tfr       d,u
                    cmpu      #$FFFF
                    bne       L6E0C
                    clra
                    clrb
                    bra       L6E41

L6E0C               clra
                    clrb
                    bra       L6E34

L6E10               pshs      u
                    ldd       $08,s
                    pshs      d
                    lbsr      L6FF6
                    leas      $02,s
                    ldd       $06,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L6D1A
                    leas      $04,s
                    tfr       d,u
                    stu       -$02,s
                    bge       L6E32
                    clra
                    clrb
                    bra       L6E41

L6E32               ldd       $08,s
L6E34               pshs      d
                    ldd       $08,s
                    pshs      d
                    pshs      u
L6E3C               lbsr      L6CC2
                    leas      $06,s
L6E41               puls      pc,u
L6E43               pshs      u
                    leax      $01C1,y
                    pshs      x
                    ldd       $06,s
                    pshs      d
                    bsr       L6E65
                    leas      $04,s
                    leax      $01C1,y
                    pshs      x
                    ldd       #$000D
                    pshs      d
                    lbsr      L6F05
                    leas      $04,s
                    puls      pc,u
L6E65               pshs      u
                    ldu       $04,s
                    leas      -$01,s
                    bra       L6E7B

L6E6D               ldd       $07,s
                    pshs      d
                    ldb       $02,s
                    sex
L6E74               pshs      d
                    lbsr      L6F05
                    leas      $04,s
L6E7B               ldb       ,u+
                    stb       ,s
                    bne       L6E6D
                    leas      $01,s
                    puls      pc,u
L6E85               pshs      u,d
                    ldu       $06,s
                    bra       L6E8D

L6E8B               leau      $01,u
L6E8D               ldb       ,u
                    sex
                    std       ,s
                    beq       L6E9C
                    ldd       ,s
                    cmpd      #$0058
                    bne       L6E8B
L6E9C               ldd       ,s
                    beq       L6EB2
                    lbsr      L78CF
                    pshs      d
                    leax      >L6EB8,pcr
                    pshs      x
                    pshs      u
                    lbsr      $5100
                    leas      $06,s
L6EB2               ldd       $06,s
                    leas      $02,s
                    puls      pc,u
L6EB8               bcs       L6F1E
L6EBA               neg       $0034
                    nega
                    ldu       $04,s
                    leas      -$04,s
                    clra
                    clrb
                    bra       L6EF6

L6EC5               clra
                    clrb
                    std       ,s
                    bra       L6EE2

L6ECB               ldd       $0e,s
                    pshs      d
                    ldb       ,u+
                    sex
                    pshs      d
                    lbsr      L6F05
                    leas      $04,s
                    ldx       $0e,s
                    ldd       $06,x
                    clra
                    andb      #$20
                    bne       L6EFF
L6EE2               ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    cmpd      $0a,s
                    blt       L6ECB
                    ldd       $02,s
                    addd      #$0001
L6EF6               std       $02,s
                    ldd       $02,s
                    cmpd      $0C,s
                    blt       L6EC5
L6EFF               ldd       $02,s
                    leas      $04,s
                    puls      pc,u
L6F05               pshs      u
                    ldu       $06,s
                    ldd       $06,u
                    anda      #$80
                    andb      #$22
                    cmpd      #$8002
                    beq       L6F29
                    ldd       $06,u
                    clra
                    andb      #$22
                    cmpd      #$0002
L6F1E               lbne      L7041
                    pshs      u
                    lbsr      L7274
                    leas      $02,s
L6F29               ldd       $06,u
                    clra
                    andb      #$04
                    beq       L6F65
                    ldd       #$0001
                    pshs      d
                    leax      $07,s
                    pshs      x
                    ldd       $08,u
                    pshs      d
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L6F4A
                    leax      L77D4,pcr
                    bra       L6F4E

L6F4A               leax      L77BB,pcr
L6F4E               tfr       x,d
                    tfr       d,x
                    jsr       ,x
                    leas      $06,s
                    cmpd      #$FFFF
                    bne       L6FA6
                    ldd       $06,u
                    orb       #$20
                    std       $06,u
                    lbra      L7041

L6F65               ldd       $06,u
                    anda      #$01
L6F69               clrb
                    std       -$02,s
                    bne       L6F75
                    pshs      u
                    lbsr      L705E
                    leas      $02,s
L6F75               ldd       ,u
                    addd      #$0001
                    std       ,u
                    subd      #$0001
                    tfr       d,x
                    ldd       $04,s
                    stb       ,x
                    ldd       ,u
                    cmpd      $04,u
                    bcc       L6F9B
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L6FA6
                    ldd       $04,s
                    cmpd      #$000D
                    bne       L6FA6
L6F9B               pshs      u
                    lbsr      L705E
                    std       ,s++
                    lbne      L7041
L6FA6               ldd       $04,s
                    puls      pc,u
L6FAA               pshs      u
                    ldu       $04,s
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    ldd       #$0008
                    lbsr      L766D
                    pshs      d
                    lbsr      L6F05
                    leas      $04,s
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    lbsr      L6F05
                    lbra      L7118

L6FCD               pshs      u,d
                    leau      $01B4,y
                    clra
                    clrb
                    std       ,s
                    bra       L6FE3

L6FD9               tfr       u,d
                    leau      $0d,u
                    pshs      d
                    bsr       L6FF6
                    leas      $02,s
L6FE3               ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    cmpd      #$0010
                    blt       L6FD9
                    lbra      L705A

L6FF6               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    cmpu      #$0000
                    beq       L7006
                    ldd       $06,u
                    bne       L700C
L7006               ldd       #$FFFF
                    lbra      L705A

L700C               ldd       $06,u
                    clra
                    andb      #$02
                    beq       L701B
                    pshs      u
                    bsr       L7030
                    leas      $02,s
                    bra       L701D

L701B               clra
                    clrb
L701D               std       ,s
                    ldd       $08,u
                    pshs      d
                    lbsr      L771D
                    leas      $02,s
                    clra
                    clrb
                    std       $06,u
                    ldd       ,s
                    bra       L705A

L7030               pshs      u
                    ldu       $04,s
                    beq       L7041
                    ldd       $06,u
                    clra
                    andb      #$22
                    cmpd      #$0002
                    beq       L7046
L7041               ldd       #$FFFF
                    puls      pc,u
L7046               ldd       $06,u
                    anda      #$80
                    clrb
                    std       -$02,s
                    bne       L7056
                    pshs      u
                    lbsr      L7274
                    leas      $02,s
L7056               pshs      u
                    bsr       L705E
L705A               leas      $02,s
                    puls      pc,u
L705E               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       L7090
                    ldd       ,u
                    cmpd      $04,u
L7072               beq       L7090
                    clra
                    clrb
                    pshs      d
                    pshs      u
                    lbsr      L711C
                    leas      $02,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L77E4
                    leas      $08,s
L7090               ldd       ,u
                    subd      $02,u
                    std       $02,s
                    lbeq      L7108
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    lbeq      L7108
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L70DF
                    ldd       $02,u
                    bra       L70D7

L70B0               ldd       $02,s
                    pshs      d
                    ldd       ,u
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L77D4
                    leas      $06,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       L70CD
                    leax      $04,s
                    bra       L70F7

L70CD               ldd       $02,s
                    subd      ,s
                    std       $02,s
                    ldd       ,u
                    addd      ,s
L70D7               std       ,u
                    ldd       $02,s
                    bne       L70B0
                    bra       L7108

L70DF               ldd       $02,s
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L77BB
                    leas      $06,s
                    cmpd      $02,s
                    beq       L7108
                    bra       L70F9

L70F7               leas      -$04,x
L70F9               ldd       $06,u
                    orb       #$20
                    std       $06,u
                    ldd       $04,u
                    std       ,u
                    ldd       #$FFFF
                    bra       L7118

L7108               ldd       $06,u
                    ora       #$01
                    std       $06,u
                    ldd       $02,u
                    std       ,u
                    addd      $0b,u
                    std       $04,u
                    clra
                    clrb
L7118               leas      $04,s
                    puls      pc,u
L711C               pshs      u
                    puls      pc,u
L7120               pshs      u
                    ldu       $04,s
                    beq       L716C
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       L716C
                    ldd       ,u
                    cmpd      $04,u
                    bcc       L7148
                    ldd       ,u
                    addd      #$0001
                    std       ,u
                    subd      #$0001
                    tfr       d,x
                    ldb       ,x
                    clra
                    lbra      L7272

L7148               pshs      u
                    lbsr      L71BB
                    lbra      L7270
                    pshs      u
                    ldu       $06,s
                    beq       L716C
                    ldd       $06,u
                    clra
                    andb      #$01
                    beq       L716C
                    ldd       $04,s
                    cmpd      #$FFFF
                    beq       L716C
                    ldd       ,u
                    cmpd      $02,u
                    bhi       L7171
L716C               ldd       #$FFFF
                    puls      pc,u
L7171               ldd       ,u
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
                    lbsr      L7120
                    leas      $02,s
                    std       $02,s
                    cmpd      #$FFFF
                    beq       L71A6
                    pshs      u
                    lbsr      L7120
                    leas      $02,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       L71AB
L71A6               ldd       #$FFFF
                    bra       L71B7

L71AB               ldd       $02,s
                    pshs      d
                    ldd       #$0008
                    lbsr      L7684
                    addd      ,s
L71B7               leas      $04,s
                    puls      pc,u
L71BB               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    ldd       $06,u
                    anda      #$80
                    andb      #$31
                    cmpd      #$8001
                    beq       L71E1
                    ldd       $06,u
                    clra
                    andb      #$31
                    cmpd      #$0001
                    lbne      L725A
                    pshs      u
                    lbsr      L7274
                    leas      $02,s
L71E1               leax      $01B4,y
                    pshs      x
                    cmpu      ,s++
                    bne       L71FE
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L71FE
                    leax      $01C1,y
                    pshs      x
                    lbsr      L7030
                    leas      $02,s
L71FE               ldd       $06,u
                    clra
                    andb      #$08
                    beq       L722A
                    ldd       $0b,u
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L721E
                    leax      L77AB,pcr
                    bra       L7222

L721E               leax      L778A,pcr
L7222               tfr       x,d
                    tfr       d,x
                    jsr       ,x
                    bra       L723C

L722A               ldd       #$0001
                    pshs      d
                    leax      $0a,u
                    stx       $02,u
                    pshs      x
                    ldd       $08,u
                    pshs      d
                    lbsr      L778A
L723C               leas      $06,s
                    std       ,s
                    ldd       ,s
                    bgt       L725F
                    ldd       $06,u
                    pshs      d
                    ldd       $02,s
                    beq       L7251
                    ldd       #$0020
                    bra       L7254

L7251               ldd       #$0010
L7254               ora       ,s+
                    orb       ,s+
                    std       $06,u
L725A               ldd       #$FFFF
                    bra       L7270

L725F               ldd       $02,u
                    addd      #$0001
                    std       ,u
                    ldd       $02,u
                    addd      ,s
                    std       $04,u
                    ldb       [$02,u]
                    clra
L7270               leas      $02,s
L7272               puls      pc,u
L7274               pshs      u
                    ldu       $04,s
                    ldd       $06,u
                    clra
                    andb      #$C0
                    bne       L72AC
                    leas      -$20,s
                    leax      ,s
                    pshs      x
                    ldd       $08,u
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    lbsr      L769F
                    leas      $06,s
                    ldd       $06,u
                    pshs      d
                    ldb       $02,s
                    bne       L72A0
                    ldd       #$0040
                    bra       L72A3

L72A0               ldd       #$0080
L72A3               ora       ,s+
                    orb       ,s+
                    std       $06,u
                    leas      $20,s
L72AC               ldd       $06,u
                    ora       #$80
                    std       $06,u
                    clra
                    andb      #$0C
                    beq       L72B9
                    puls      pc,u
L72B9               ldd       $0b,u
                    bne       L72CE
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L72C9
                    ldd       #$0080
                    bra       L72CC

L72C9               ldd       #$0100
L72CC               std       $0b,u
L72CE               ldd       $02,u
                    bne       L72E3
                    ldd       $0b,u
                    pshs      d
                    lbsr      L78A2
                    leas      $02,s
                    std       $02,u
                    cmpd      #$FFFF
                    beq       L72EB
L72E3               ldd       $06,u
                    orb       #$08
                    std       $06,u
                    bra       L72FA

L72EB               ldd       $06,u
                    orb       #$04
                    std       $06,u
                    leax      $0a,u
                    stx       $02,u
                    ldd       #$0001
                    std       $0b,u
L72FA               ldd       $02,u
                    addd      $0b,u
                    std       $04,u
L7300               std       ,u
                    puls      pc,u
                    pshs      u
                    ldu       $04,s
L7308               ldb       ,u+
                    bne       L7308
                    tfr       u,d
                    subd      $04,s
                    addd      #$FFFF
                    puls      pc,u
L7315               pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
L731F               ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L731F
                    bra       L7354
                    pshs      u
                    ldu       $06,s
L7331               leas      -$02,s
                    ldd       $06,s
                    std       ,s
L7337               ldx       ,s
                    leax      $01,x
                    stx       ,s
                    ldb       -$01,x
                    bne       L7337
                    ldd       ,s
                    addd      #$FFFF
                    std       ,s
L7348               ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L7348
L7354               ldd       $06,s
                    leas      $02,s
                    puls      pc,u
                    pshs      u
                    ldu       $04,s
                    bra       L7370

L7360               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    bne       L736E
                    clra
                    clrb
                    puls      pc,u
L736E               leau      $01,u
L7370               ldb       ,u
                    sex
                    pshs      d
                    ldb       [$08,s]
                    sex
                    cmpd      ,s++
                    beq       L7360
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
L7395               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    subd      #$FFFF
                    ble       L73B9
                    ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L7395
                    bra       L73B9

L73AF               clra
                    clrb
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
L73B9               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    subd      #$FFFF
                    bgt       L73AF
                    lbra      L7448
                    pshs      u
                    ldu       $04,s
                    bra       L73DE

L73CE               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    bne       L73DC
                    clra
                    clrb
                    puls      pc,u
L73DC               leau      $01,u
L73DE               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    ble       L73F8
                    ldb       ,u
                    sex
                    pshs      d
                    ldb       [$08,s]
                    sex
                    cmpd      ,s++
                    beq       L73CE
L73F8               ldd       $08,s
                    bge       L7400
                    clra
                    clrb
                    bra       L740B

L7400               ldb       [$06,s]
                    sex
                    pshs      d
                    ldb       ,u
                    sex
                    subd      ,s++
L740B               puls      pc,u
                    pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
L7417               ldx       ,s
                    leax      $01,x
                    stx       ,s
                    ldb       -$01,x
                    bne       L7417
                    ldd       ,s
                    addd      #$FFFF
                    std       ,s
L7428               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    subd      #$FFFF
                    ble       L7440
                    ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L7428
L7440               ldd       $0a,s
                    bge       L7448
                    clra
                    clrb
                    stb       [,s]
L7448               ldd       $06,s
                    leas      $02,s
                    puls      pc,u
                    pshs      u
                    ldu       $04,s
L7452               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    stb       ,u+
                    bgt       L7452
                    ldb       -$01,u
                    clra
L7461               andb      #$7f
                    stb       -$01,u
L7465               clra
                    clrb
                    stb       ,u
                    ldd       $04,s
                    puls      pc,u
                    ldd       $04,s
L746F               addd      $02,x
                    std       $02C8,y
                    ldd       $02,s
                    adcb      $01,x
                    adca      ,x
                    std       $02C6,y
                    lbra      L7525
                    ldd       $04,s
                    subd      $02,x
                    std       $02C8,y
                    ldd       $02,s
                    sbcb      $01,x
                    sbca      ,x
                    std       $02C6,y
L7494               lbra      L7525
                    lbsr      L7534
L749A               ldd       #$0000
                    subd      $02,x
                    std       $02,x
                    ldd       #$0000
                    sbcb      $01,x
                    sbca      ,x
L74A8               std       ,x
                    rts
                    ldd       ,x
                    coma
                    comb
                    std       $02C6,y
                    ldd       $02,x
                    coma
                    comb
                    leax      $02C6,y
                    std       $02,x
L74BD               rts
                    leax      $02C6,y
                    std       $02,x
                    tfr       a,b
                    sex
                    tfr       a,b
                    std       ,x
                    rts
                    leax      $02C6,y
                    std       $02,x
                    clr       ,x
L74D4               clr       $01,x
L74D6               rts
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
L74EC               rts
                    ldx       $02,s
                    pshs      b
                    lbsr      L7534
                    puls      b
                    tstb
                    beq       L7504
L74F9               asl       $03,x
                    rol       $02,x
                    rol       $01,x
                    rol       ,x
                    decb
                    bne       L74F9
L7504               puls      d
                    std       ,s
                    rts
                    ldx       $02,s
                    pshs      b
                    lbsr      L7534
                    puls      b
                    tstb
                    beq       L7520
L7515               asr       ,x
                    ror       $01,x
                    ror       $02,x
                    ror       $03,x
                    decb
                    bne       L7515
L7520               puls      d
                    std       ,s
                    rts

L7525               tfr       cc,a
                    puls      x
                    stx       $02,s
                    leas      $02,s
                    leax      $02C6,y
                    tfr       a,cc
                    rts

L7534               ldd       ,x
                    std       $02C6,y
                    ldd       $02,x
                    leax      $02C6,y
L7540               std       $02,x
L7542               rts

L7543               tsta
                    bne       L7558
                    tst       $02,s
                    bne       L7558
                    lda       $03,s
                    mul
                    ldx       ,s
                    stx       $02,s
                    ldx       #$0000
                    std       ,s
                    puls      pc,d
L7558               pshs      d
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
                    bcc       L7575
                    inc       ,s
L7575               lda       $04,s
                    ldb       $09,s
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L7582
                    inc       ,s
L7582               lda       $04,s
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
                    clr       $080C,y
                    leax      >L75DE,pcr
                    stx       $080d,y
                    bra       L75B8
                    leax      >L75F7,pcr
                    stx       $080d,y
                    clr       $080C,y
                    tst       $02,s
                    bpl       L75B8
                    inc       $080C,y
L75B8               subd      #$0000
                    bne       L75C3
                    puls      x
                    ldd       ,s++
                    jmp       ,x

L75C3               ldx       $02,s
                    pshs      x
                    jsr       [$080d,y]
                    ldd       ,s
                    std       $02,s
                    tfr       x,d
                    tst       $080C,y
                    beq       L75DB
                    nega
                    negb
                    sbca      #$00
L75DB               std       ,s++
                    rts

L75DE               subd      #$0000
                    beq       L75ED
                    pshs      d
                    leas      -$02,s
                    clr       ,s
                    clr       $01,s
                    bra       L761B

L75ED               puls      d
                    std       ,s
                    ldd       #$002D
L75F4               lbra      L7690

L75F7               subd      #$0000
                    beq       L75ED
                    pshs      d
                    leas      -$02,s
                    clr       ,s
                    clr       $01,s
                    tsta
                    bpl       L760F
                    nega
                    negb
                    sbca      #$00
                    inc       $01,s
                    std       $02,s
L760F               ldd       $06,s
                    bpl       L761B
                    nega
                    negb
                    sbca      #$00
                    com       $01,s
                    std       $06,s
L761B               lda       #$01
L761D               inca
                    asl       $03,s
                    rol       $02,s
                    bpl       L761D
                    sta       ,s
                    ldd       $06,s
                    clr       $06,s
                    clr       $07,s
L762C               subd      $02,s
                    bcc       L7636
                    addd      $02,s
                    andcc     #$FE
                    bra       L7638

L7636               orcc      #$01
L7638               rol       $07,s
                    rol       $06,s
                    lsr       $02,s
                    ror       $03,s
                    dec       ,s
                    bne       L762C
                    std       $02,s
                    tst       $01,s
                    beq       L7652
                    ldd       $06,s
                    nega
                    negb
                    sbca      #$00
                    std       $06,s
L7652               ldx       $04,s
                    ldd       $06,s
                    std       $04,s
                    stx       $06,s
                    ldx       $02,s
                    ldd       $04,s
L765E               leas      $06,s
L7660               rts
                    tstb
                    beq       L7677
L7664               asr       $02,s
                    ror       $03,s
                    decb
                    bne       L7664
                    bra       L7677

L766D               tstb
                    beq       L7677
L7670               lsr       $02,s
                    ror       $03,s
                    decb
                    bne       L7670
L7677               ldd       $02,s
                    pshs      d
                    ldd       $02,s
                    std       $04,s
                    ldd       ,s
L7681               leas      $04,s
L7683               rts

L7684               tstb
                    beq       L7677
L7687               asl       $03,s
                    rol       $02,s
                    decb
                    bne       L7687
                    bra       L7677

L7690               std       $02D2,y
                    pshs      y,b
                    os9       F$ID
                    puls      y,b
                    os9       F$Send
                    rts

L769F               lda       $05,s
                    ldb       $03,s
                    beq       L76D2
                    cmpb      #$01
                    beq       L76D4
                    cmpb      #$06
                    beq       L76D4
                    cmpb      #$02
                    beq       L76BA
                    cmpb      #$05
                    beq       L76BA
                    ldb       #$D0
                    lbra      L7936

L76BA               pshs      u
                    os9       I$GetStt
                    bcc       L76C6
                    puls      u
                    lbra      L7936

L76C6               stx       [$08,s]
                    ldx       $08,s
                    stu       $02,x
                    puls      u
                    clra
                    clrb
                    rts

L76D2               ldx       $06,s
L76D4               os9       I$GetStt
                    lbra      L793F
                    lda       $05,s
                    ldb       $03,s
                    beq       L76E9
                    cmpb      #$02
                    beq       L76F1
                    ldb       #$D0
                    lbra      L7936

L76E9               ldx       $06,s
                    os9       I$SetStt
                    lbra      L793F

L76F1               pshs      u
                    ldx       $08,s
                    ldu       $0a,s
                    os9       I$SetStt
                    puls      u
                    lbra      L793F
                    ldx       $02,s
                    lda       $05,s
                    os9       I$Open
                    bcs       L770B
                    os9       I$Close
L770B               lbra      L793F

L770E               ldx       $02,s
                    lda       $05,s
                    os9       I$Open
                    lbcs      L7936
                    tfr       a,b
                    clra
                    rts

L771D               lda       $03,s
                    os9       I$Close
                    lbra      L793F
                    ldx       $02,s
                    ldb       $05,s
                    os9       I$MakDir
                    lbra      L793F

L772F               ldx       $02,s
                    lda       $05,s
                    tfr       a,b
                    andb      #$24
                    orb       #$0b
                    os9       I$Create
                    bcs       L7742
L773E               tfr       a,b
                    clra
                    rts

L7742               cmpb      #$DA
                    lbne      L7936
                    lda       $05,s
                    bita      #$80
                    lbne      L7936
                    anda      #$07
                    ldx       $02,s
                    os9       I$Open
                    lbcs      L7936
                    pshs      u,a
                    ldx       #$0000
                    leau      ,x
                    ldb       #$02
                    os9       I$SetStt
                    puls      u,a
L7769               bcc       L773E
                    pshs      b
                    os9       I$Close
                    puls      b
                    lbra      L7936

L7775               ldx       $02,s
                    os9       I$Delete
                    lbra      L793F
                    lda       $03,s
                    os9       I$Dup
                    lbcs      L7936
                    tfr       a,b
                    clra
                    rts

L778A               pshs      y
                    ldx       $06,s
                    lda       $05,s
                    ldy       $08,s
                    pshs      y
                    os9       I$Read
L7798               bcc       L77A7
                    cmpb      #$D3
                    bne       L77A2
                    clra
                    clrb
                    puls      pc,y,x
L77A2               puls      y,x
                    lbra      L7936

L77A7               tfr       y,d
                    puls      pc,y,x
L77AB               pshs      y
                    lda       $05,s
                    ldx       $06,s
                    ldy       $08,s
                    pshs      y
                    os9       I$ReadLn
                    bra       L7798

L77BB               pshs      y
                    ldy       $08,s
                    beq       L77D0
                    lda       $05,s
                    ldx       $06,s
                    os9       I$Write
L77C9               bcc       L77D0
                    puls      y
                    lbra      L7936

L77D0               tfr       y,d
                    puls      pc,y
L77D4               pshs      y
                    ldy       $08,s
                    beq       L77D0
                    lda       $05,s
                    ldx       $06,s
                    os9       I$WritLn
                    bra       L77C9

L77E4               pshs      u
                    ldd       $0a,s
                    bne       L77F2
                    ldu       #$0000
                    ldx       #$0000
                    bra       L7826

L77F2               cmpd      #$0001
                    beq       L781D
                    cmpd      #$0002
                    beq       L7812
                    ldb       #$F7
L7800               clra
                    std       $02D2,y
                    ldd       #$FFFF
                    leax      $02C6,y
                    std       ,x
                    std       $02,x
                    puls      pc,u
L7812               lda       $05,s
                    ldb       #$02
                    os9       I$GetStt
                    bcs       L7800
                    bra       L7826

L781D               lda       $05,s
                    ldb       #$05
                    os9       I$GetStt
                    bcs       L7800
L7826               tfr       u,d
                    addd      $08,s
                    std       $02C8,y
                    tfr       d,u
                    tfr       x,d
                    adcb      $07,s
                    adca      $06,s
                    bmi       L7800
                    tfr       d,x
                    std       $02C6,y
                    lda       $05,s
                    os9       I$Seek
                    bcs       L7800
                    leax      $02C6,y
                    puls      pc,u
                    ldd       $02C4,y
                    pshs      d
                    ldd       $04,s
                    cmpd      $080f,y
                    bcs       L787F
                    addd      $02C4,y
                    pshs      y
                    subd      ,s
                    os9       F$Mem
                    tfr       y,d
                    puls      y
                    bcc       L7871
                    ldd       #$FFFF
                    leas      $02,s
                    rts

L7871               std       $02C4,y
                    addd      $080f,y
                    subd      ,s
                    std       $080f,y
L787F               leas      $02,s
                    ldd       $080f,y
                    pshs      d
                    subd      $04,s
                    std       $080f,y
                    ldd       $02C4,y
                    subd      ,s++
                    pshs      d
                    clra
                    ldx       ,s
L7898               sta       ,x+
                    cmpx      $02C4,y
                    bcs       L7898
                    puls      pc,d
L78A2               ldd       $02,s
                    addd      $02CE,y
                    bcs       L78CB
                    cmpd      $02D0,y
                    bcc       L78CB
                    pshs      d
                    ldx       $02CE,y
                    clra
L78B8               cmpx      ,s
                    bcc       L78C0
                    sta       ,x+
                    bra       L78B8

L78C0               ldd       $02CE,y
                    puls      x
                    stx       $02CE,y
                    rts

L78CB               ldd       #$FFFF
                    rts

L78CF               pshs      y
                    os9       F$ID
                    puls      y
                    bcc       L78DC
                    lbcs      L7936
L78DC               tfr       a,b
                    clra
                    rts

L78E0               pshs      y
                    os9       F$ID
                    bcc       L78EC
L78E7               puls      y
                    lbra      L7936

L78EC               tfr       y,d
                    puls      pc,y
                    pshs      y
                    bsr       L78E0
                    std       -$02,s
                    beq       L78FC
                    ldb       #$D6
                    bra       L78E7

L78FC               ldy       $04,s
                    os9       F$SUser
                    bcc       L7910
                    cmpb      #$D0
                    bne       L78E7
                    tfr       y,d
                    ldy       >$004B
                    std       $09,y
L7910               clra
                    clrb
                    puls      pc,y
L7914               pshs      u
                    tfr       y,u
                    ldx       $04,s
                    stx       $0811,y
                    leax      >L792A,pcr
                    os9       F$Icpt
                    puls      u
                    lbra      L793F

L792A               tfr       u,y
                    clra
                    pshs      d
                    jsr       [$0811,y]
                    leas      $02,s
                    rti

L7936               clra
                    std       $02D2,y
                    ldd       #$FFFF
                    rts

L793F               bcs       L7936
L7941               clra
                    clrb
                    rts

L7944               lbsr      L794F
L7947               lbsr      L6FCD
L794A               ldd       $02,s
L794C               os9       F$Exit
L794F               rts
                    neg       $0003
                    neg       $0000
                    adca      #$02
                    jmp       $0078
                    bra       $79BF
                    asl       $7065
                    com       -$0C,s
                    fcb       $65
                    lsr       0,x
                    beq       L7974
                    com       $00E8
                    neg       L0064
                    neg       $000A
                    neg       $0000
                    neg       $0000
L796E               neg       $0000
L7970               neg       $0000
                    neg       $0000
L7974               neg       $0000
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
                    tst       0,u
                    rol       0,x
                    neg       $0054
                    fcb       $41
                    asl       $0d,y
                    bgt       L79D7
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
                    ble       $79CE
                    tstb
                    asl       L5F64
                    neg       $006A
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
L79D7               dec       $0a,s
                    dec       $0a,s
                    dec       $0a,s
                    dec       $0a,s
                    dec       $0a,s
                    dec       $0a,s
                    dec       $0a,s
                    bvs       $7A3F
                    bpl       $7A2D
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
                    asr       $000B
                    neg       $0001
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
                    fcb       $01
                    stx       $0063
                    com       $7472
                    bgt       $7AE8
                    aslb
                    aslb
                    aslb
                    aslb
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
                    neg       $0000
                    neg       $0003
                    neg       $0001
                    fcb       $01
                    adca      #$01
                    sta       $03,s
                    bgt       $7BE2
                    fcb       $61

                    emod
eom                 equ       *
                    end
